<?php
defined( 'ABSPATH' ) || exit;

$is_administrator = current_user_can( 'administrator' );
$nav_quick = get_transient( 'nav-quick' );
$nav_default = get_transient( 'nav-default' );
$bootstrap_walker = class_exists( 'WP_Bootstrap_Navwalker' ) ? new WP_Bootstrap_Navwalker() : '';

if ( $is_administrator || $nav_quick === false ) {
	$nav_quick = wp_nav_menu( [
		'container' => '',
		'theme_location' => 'quick',
		'menu_class' => 'nav navbar-nav flex-row gap-3',
        'items_wrap' => '<ul id="%1$s" class="%2$s" style="--bs-nav-link-font-weight: 400;">%3$s</ul>',
		'item_spacing' => 'discard',
		'fallback_cb' => false,
        'walker' => $bootstrap_walker,
		'echo' => 0
	] );

	set_transient( 'nav-quick', $nav_quick, HOUR_IN_SECONDS );
}

if ( $is_administrator || $nav_default === false ) {
	$nav_default = wp_nav_menu( [
		'container' => '',
		'theme_location' => 'default',
		'menu_class' => 'nav navbar-nav',
        'items_wrap' => '<ul id="%1$s" class="%2$s">%3$s</ul>',
		'item_spacing' => 'discard',
		'fallback_cb' => false,
        'walker' => $bootstrap_walker,
		'echo' => 0
	] );

	set_transient( 'nav-default', $nav_default, HOUR_IN_SECONDS );
}
?>
<div class="sentinal"></div>

<header class="sticky-top">
    <nav class="navbar bg-body-secondary border-bottom border-light py-1 small">
        <div class="container justify-content-center justify-content-md-end">
            <?= $nav_quick ?>
        </div>
    </nav>

    <nav class="navbar navbar-expand-lg bg-body border-bottom border-2 border-light">
        <div class="container">
            <a class="navbar-brand text-body" href="<?= esc_url( home_url() ) ?>">
                <span class="d-none"><?= file_get_contents( get_template_directory() . '/assets/images/logos/ntara-logo.svg' ) ?></span>
                <span><?= str_replace( '="234"', '="56"', file_get_contents( get_template_directory() . '/assets/images/logos/ntara-text-logo.svg' ) ) ?></span>
            </a>

            <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navigation-menu" aria-controls="navigation-menu" aria-expanded="false" aria-label="Toggle navigation">
                <span class="navbar-toggler-icon"></span>
            </button>

            <div class="collapse navbar-collapse justify-content-center" id="navigation-menu">
                <?= $nav_default ?>

                <form role="search" method="get" class="woocommerce-product-search ms-auto" action="<?= esc_url( home_url() ) ?>">
                    <label class="screen-reader-text" for="woocommerce-product-search-field-0">Search for:</label>

                    <div class="hstack gap-2">
                        <input type="search" id="woocommerce-product-search-field-0" class="form-control" placeholder="Search products…" value="" name="s">
                        <button type="submit" value="Search" class="btn btn-outline-primary text-uppercase">Search</button>
                    </div>

                    <input type="hidden" name="post_type" value="product">
                </form>
            </div>
        </div>
    </nav>
</header>
