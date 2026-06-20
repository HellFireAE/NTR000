<?php
defined( 'ABSPATH' ) || exit;

// Revert the following to default WordPress template structure for WooCommerce pages.
// This allows the theme to control the layout and design of certain WooCommerce pages without relying on WooCommerce's default templates.
// For shop and product category pages, use the 'archive-product.php' template from the theme.
if ( is_shop() || is_product_category() ) {
	get_template_part( 'archive', 'product' );

	return;
}

// For single product pages, use the 'single-product.php' template from the theme.
elseif ( is_product() ) {
	get_template_part( 'single', 'product' );

	return;
}

// For other WooCommerce pages, use the default template structure.
get_header();
woocommerce_content();
get_footer();
