#!/usr/bin/env bash
# This script performs a fresh installation of WordPress and all necessary setup.
# Note: generated comments, helpers, formatting, and product creation loop optimization.

# Exit immediately if a command exits with a non-zero status, if an undefined variable is used, or if any command in a pipeline fails
set -euo pipefail

# ── Configuration ─────────────────────────────────────────────────────────────
SITE_TITLE="Ntara Test #1"
SITE_URL="https://localhost"
ADMIN_USER="admin"
ADMIN_EMAIL="admin@example.local"
ADMIN_PASSWORD="password"

PHONE="217-837-2790"
ADDRESS_STREET="123 Main St"
ADDRESS_CITY="Anytown"
ADDRESS_STATE="CA"   # ISO state/region code
ADDRESS_COUNTRY="US" # ISO 3166-1 alpha-2 country code
ADDRESS_ZIP="12345"
ADDRESS_DIRECTIONS="https://www.google.com/maps"

# ── Helpers ───────────────────────────────────────────────────────────────────
# Allow running as root inside the Docker container (instead of using --allow-root every time)
wp() { command wp --allow-root "$@"; }

# Wait for the database port to be reachable (max 30s)
echo "Waiting for database..."
WAIT=0
until (echo > /dev/tcp/database/3306) 2>/dev/null; do
    if [ $WAIT -ge 30 ]; then
        echo "Database not ready after 30s. Aborting."
        exit 1
    fi
    sleep 2
    WAIT=$((WAIT + 2))
done

# ── Core ──────────────────────────────────────────────────────────────────────
if wp core is-installed 2>/dev/null; then
    echo "WordPress is already installed."
else
    echo "Installing WordPress..."
    wp core install \
        --url="$SITE_URL" \
        --title="$SITE_TITLE" \
        --admin_user="$ADMIN_USER" \
        --admin_email="$ADMIN_EMAIL" \
        --admin_password="$ADMIN_PASSWORD" \
        --skip-email
fi

# ── Permalinks (set before WooCommerce activates so page slugs register) ──────
wp rewrite structure '/%postname%/'
wp rewrite flush --hard

# ── Theme ─────────────────────────────────────────────────────────────────────
wp theme activate website-wp-theme-ntara-test

# ── Plugins (Composer-managed — already on disk, just activate) ───────────────
wp plugin activate woocommerce

# ── Options ───────────────────────────────────────────────────────────────────
wp option update woocommerce_coming_soon no
wp option update posts_per_page 12

# Site icon (idempotent — skip if already set)
ICON_PATH=$(wp eval 'echo get_template_directory();' 2>/dev/null)/assets/images/logos/ntara-logo.svg
if [ -f "$ICON_PATH" ] && [ "$(wp option get site_icon 2>/dev/null)" = "0" ]; then
    site_icon_id=$(wp media import "$ICON_PATH" --porcelain 2>/dev/null)
    wp option update site_icon "$site_icon_id"
    echo "Site icon set (attachment $site_icon_id)"
fi

# ── Pages ─────────────────────────────────────────────────────────────────────
# Helper: get existing page by slug, or create it
page_id() { local id; id=$(wp post list --post_type=page --pagename="$2" --fields=ID --format=ids --posts_per_page=1 2>/dev/null); [ -n "$id" ] && echo "$id" || wp post create --post_type=page --post_title="$1" --post_content="Lorem ipsum dolor sit amet, consectetur adipiscing elit. Pellentesque blandit, odio quis tincidunt facilisis, ipsum justo maximus sapien, vel sagittis nunc mi quis est. Duis ac justo augue. Fusce vel odio odio. Vestibulum auctor diam ac sem mattis, vitae scelerisque felis ultrices. Integer imperdiet, ante sed rutrum porttitor, arcu urna tempus quam, sit amet tempor tellus justo vitae quam. Fusce nec magna et orci dapibus finibus. Phasellus ultrices scelerisque ultrices." --post_status=publish --porcelain; }

POST_ID_ABOUT_US=$(page_id "About Us" about-us)
POST_ID_STORES=$(page_id "Stores" stores)
POST_ID_DEALS=$(page_id "Deals" deals)
POST_ID_CONTACT_US=$(page_id "Contact Us" contact-us)
POST_ID_OUR_TEAM=$(page_id "Our Team" our-team)
POST_ID_HISTORY=$(page_id "History" history)
POST_ID_MISSION=$(page_id "Mission" mission)
POST_ID_SHIPPING=$(page_id "Shipping" shipping)
POST_ID_RETURNS=$(page_id "Returns" returns)
POST_ID_PRIVACY_POLICY=$(wp option get wp_page_for_privacy_policy)

# WooCommerce creates its own pages (Shop, Cart, Checkout, My Account) on activation
POST_ID_SHOP=$(wp option get woocommerce_shop_page_id)
POST_ID_CART=$(wp option get woocommerce_cart_page_id)
POST_ID_CHECKOUT=$(wp option get woocommerce_checkout_page_id)
POST_ID_MY_ACCOUNT=$(wp option get woocommerce_myaccount_page_id)

# Remove the default WordPress placeholder pages
wp post delete "$(wp post list --post_type=page --pagename=sample-page --fields=ID --format=ids)" --force 2>/dev/null || true

# ── Menus ─────────────────────────────────────────────────────────────────────
if ! wp menu list --fields=name --format=csv 2>/dev/null | grep -q "Quick Menu"; then
    wp menu create "Quick Menu"
    wp menu create "Default Menu"
    wp menu create "About Menu"
    wp menu create "Service Menu"

    wp menu location assign "Quick Menu" quick
    wp menu location assign "Default Menu" default
    wp menu location assign "About Menu" about
    wp menu location assign "Service Menu" service

    wp menu item add-post "Quick Menu" "$POST_ID_CONTACT_US"
    wp menu item add-custom "Quick Menu" "Directions" "$ADDRESS_DIRECTIONS"
    wp menu item add-custom "Quick Menu" "$PHONE" "tel:$PHONE"

    wp menu item add-post "Default Menu" "$POST_ID_SHOP"
    wp menu item add-post "Default Menu" "$POST_ID_ABOUT_US"
    wp menu item add-post "Default Menu" "$POST_ID_STORES"
    wp menu item add-post "Default Menu" "$POST_ID_DEALS"

    wp menu item add-post "About Menu" "$POST_ID_OUR_TEAM"
    wp menu item add-custom "About Menu" "Directions" "$ADDRESS_DIRECTIONS"
    wp menu item add-post "About Menu" "$POST_ID_HISTORY"
    wp menu item add-post "About Menu" "$POST_ID_MISSION"

    wp menu item add-post "Service Menu" "$POST_ID_CONTACT_US"
    wp menu item add-post "Service Menu" "$POST_ID_SHIPPING"
    wp menu item add-post "Service Menu" "$POST_ID_RETURNS"
    wp menu item add-post "Service Menu" "$POST_ID_PRIVACY_POLICY"
else
    echo "Menus already exist. Skipping."
fi

# ── WooCommerce ────────────────────────────────────────────────────────────────
if ! wp widget list woo --format=ids 2>/dev/null | grep -q .; then
    # wp widget add woocommerce_product_search woo --title="Search"
    wp widget add woocommerce_product_categories woo --title="Menu" --hierarchical=1
    # wp widget add woocommerce_price_filter woo --title="Pricing"
    wp widget add woocommerce_layered_nav woo --title="Size" --attribute="pa_size" --display_type="list" --query_type="or"
    wp widget add woocommerce_rating_filter woo --title="Average rating"
fi

# ── Products (CSV import) ──────────────────────────────────────────────────────
if wp wc product list --user=1 --format=ids --per_page=1 2>/dev/null | grep -q .; then
    echo "Products already exist. Skipping."
else
    wp eval --allow-root '
        wp_set_current_user(1);
        require_once WP_PLUGIN_DIR . "/woocommerce/includes/import/abstract-wc-product-importer.php";
        require_once WP_PLUGIN_DIR . "/woocommerce/includes/import/class-wc-product-csv-importer.php";
        $file = get_template_directory() . "/data/products.csv";
        $importer = new WC_Product_CSV_Importer($file, ["update_existing" => false, "lines" => 500, "parse" => true]);
        $results = $importer->import();
        echo "Imported: " . count($results["imported"]) . ", Failed: " . count($results["failed"]) . PHP_EOL;
    '
fi

# ── Product Images ────────────────────────────────────────────────────────────
# Place images in data/images/{category-slug}/ to assign them to products.
# Images are round-robined across products in each category (idempotent).
THEME_DIR=$(wp eval 'echo get_template_directory();' 2>/dev/null)
IMAGES_DIR="$THEME_DIR/data/images"

if [ -d "$IMAGES_DIR" ] && find "$IMAGES_DIR" -maxdepth 2 \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" -o -name "*.webp" \) 2>/dev/null | grep -q .; then
    echo "Importing product images..."
    for cat_dir in "$IMAGES_DIR"/*/; do
        [ -d "$cat_dir" ] || continue
        slug=$(basename "$cat_dir" | tr '[:upper:]' '[:lower:]')

        # Get product IDs for this category slug
        product_ids=$(wp eval "
            \$term = get_term_by('slug', '$slug', 'product_cat');
            if (\$term) {
                \$ids = get_posts(['post_type'=>'product','numberposts'=>-1,'fields'=>'ids',
                    'tax_query'=>[['taxonomy'=>'product_cat','field'=>'term_id','terms'=>\$term->term_id]]]);
                echo implode(' ', \$ids);
            }
        " 2>/dev/null || true)
        [ -z "$product_ids" ] && continue

        # Collect image files
        mapfile -t images < <(find "$cat_dir" -maxdepth 1 \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" -o -name "*.webp" \) | sort)
        [ ${#images[@]} -eq 0 ] && continue

        i=0
        for pid in $product_ids; do
            # Skip if product already has a featured image
            thumb=$(wp post meta get "$pid" _thumbnail_id 2>/dev/null || true)
            [ -n "$thumb" ] && { (( i++ )) || true; continue; }
            img="${images[$((i % ${#images[@]}))]}"
            wp media import "$img" --post_id="$pid" --featured_image --quiet 2>/dev/null || true
            (( i++ )) || true
        done
    done
else
    echo "No product images found in data/images/. Skipping."
fi

# ── Reviews ───────────────────────────────────────────────────────────────────
SHOES_ID=$(wp post list --post_type=product --name="sample-shoes-product-1" --fields=ID --format=ids 2>/dev/null | head -1)
if [ -n "$SHOES_ID" ] && ! wp comment list --post_id="$SHOES_ID" --comment_type=review --format=ids 2>/dev/null | grep -q .; then
    cid1=$(wp comment create \
        --comment_post_ID="$SHOES_ID" \
        --comment_content="LIKE MAGIC!!!" \
        --comment_author="$ADMIN_USER" \
        --comment_author_email="$ADMIN_EMAIL" \
        --comment_type=review \
        --comment_approved=1 \
        --porcelain 2>/dev/null)
    wp comment meta add "$cid1" rating 5 2>/dev/null

    cid2=$(wp comment create \
        --comment_post_ID="$SHOES_ID" \
        --comment_content="Glorious response" \
        --comment_author="$ADMIN_USER" \
        --comment_author_email="$ADMIN_EMAIL" \
        --comment_type=review \
        --comment_approved=1 \
        --porcelain 2>/dev/null)
    wp comment meta add "$cid2" rating 5 2>/dev/null
fi

echo "✓ Install complete."
