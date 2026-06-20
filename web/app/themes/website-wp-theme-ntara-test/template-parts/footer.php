<?php
defined( 'ABSPATH' ) || exit;

$is_administrator = current_user_can( 'administrator' );
$nav_about = get_transient( 'nav-about' );
$nav_service = get_transient( 'nav-service' );
$bootstrap_walker = class_exists( 'WP_Bootstrap_Navwalker' ) ? new WP_Bootstrap_Navwalker() : '';

if ( $is_administrator || $nav_about === false ) {
	$nav_about = wp_nav_menu( [
		'container' => '',
		'theme_location' => 'about',
		'menu_class' => 'nav flex-column gap-2 text-body-secondary',
        'items_wrap' => '<ul id="%1$s" class="%2$s" style="--bs-nav-link-font-weight: 400;">%3$s</ul>',
		'li_class' => 'nav-item',
		'link_class' => 'nav-link p-0',
		'item_spacing' => 'discard',
		'fallback_cb' => false,
        'walker' => $bootstrap_walker,
		'echo' => 0
	] );

	set_transient( 'nav-about', $nav_about, HOUR_IN_SECONDS );
}

if ( $is_administrator || $nav_service === false ) {
	$nav_service = wp_nav_menu( [
		'container' => '',
		'theme_location' => 'service',
		'menu_class' => 'nav flex-column gap-2 text-body-secondary',
        'items_wrap' => '<ul id="%1$s" class="%2$s" style="--bs-nav-link-font-weight: 400;">%3$s</ul>',
		'li_class' => 'nav-item',
		'link_class' => 'nav-link p-0',
		'item_spacing' => 'discard',
		'fallback_cb' => false,
        'walker' => $bootstrap_walker,
		'echo' => 0
	] );

	set_transient( 'nav-service', $nav_service, HOUR_IN_SECONDS );
}
?>

<footer>
    <div class="footer-content border-top border-2 border-light">
        <div class="container py-3">
            <div class="row g-5 align-items-center">
                <div class="col-md-3 text-primary">
                    <?= file_get_contents( get_template_directory() . '/assets/images/logos/ntara-logo.svg' ) ?>
                </div>
                <div class="col-md-9">
                    <div class="row g-4">
                        <div class="col-md-4">
                            <h5 class="h6 mb-3 text-uppercase fw-bold text-primary">About Us</h5>

                            <?= $nav_about ?>
                        </div>
                        <div class="col-md-4">
                            <h5 class="h6 mb-3 text-uppercase fw-bold text-primary">Customer Service</h5>

                            <?= $nav_service ?>
                        </div>
                        <div class="col-md-4">
                            <h5 class="h6 mb-3 text-primary text-uppercase fw-bold">Follow Us</h5>

                            <div class="hstack gap-2 mb-3">
                                <a href="#" target="_blank" class="text-decoration-none bg-body-secondary text-body-secondary rounded-circle p-1">
                                    <?= file_get_contents( get_template_directory() . '/assets/images/logos/f.svg' ) ?>
                                    <span class="visually-hidden">Facebook</span>
                                </a>
                                <a href="#" target="_blank" class="text-decoration-none bg-body-secondary text-body-secondary rounded-circle p-1">
                                    <?= file_get_contents( get_template_directory() . '/assets/images/logos/x.svg' ) ?>
                                    <span class="visually-hidden">X or Twitter</span>
                                </a>
                            </div>

                            <a href="#" class="btn btn-outline-primary border-2 text-uppercase w-100">Get Directions</a>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <div class="footer-copyright border-top border-2 border-light">
        <div class="container py-4">
            <p class="m-0 text-center text-muted">&copy;<?= date( 'Y' ) ?> Ntara Partners, Inc.</p>
        </div>
    </div>
</footer>
