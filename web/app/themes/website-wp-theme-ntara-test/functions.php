<?php
defined( 'ABSPATH' ) || exit;

// Theme class setup and initialization
class WP_THEME_INIT {
    function __construct() {
        // Theme support features
        add_action( 'after_setup_theme', [ $this, 'theme_supports' ] );

        // Theme assets
        add_action( 'wp_enqueue_scripts', [ $this, 'theme_assets' ] );

        // Initialize theme customizations
        add_action( 'init', [ $this, 'init' ] );
    }

    function theme_supports() {
        add_theme_support( 'title-tag' );
        add_theme_support( 'post-thumbnails' );
        add_theme_support( 'custom-logo' );
        add_theme_support( 'html5' , [ 'search-form', 'comment-form', 'comment-list', 'gallery', 'caption', 'style', 'script' ] );
        add_theme_support( 'responsive-embeds' );
        add_theme_support( 'align-wide' );
        add_theme_support( 'block-templates' );
        add_theme_support( 'wp-block-styles' );
        add_theme_support( 'woocommerce', [
            'thumbnail_image_width' => 300,
            'single_image_width' => 1024,
            'gallery_thumbnail_image_width' => 150,
            'product_grid' => [
                'default_columns' => 3,
                'default_rows' => 4,
                'min_columns' => 2,
                'max_columns' => 3,
            ],
        ] );

	    remove_theme_support( 'widgets-block-editor' );

        if ( ! class_exists( 'WP_Bootstrap_Navwalker' ) ) {
            include_once 'assets/php/class-wp-bootstrap-nav-walker.php';
        }
    }

    function theme_assets() {
		wp_enqueue_style( 'theme', get_stylesheet_uri() );

		wp_enqueue_script( 'bootstrap-bundle', get_template_directory_uri() . '/assets/js/bootstrap.bundle.min.js', [], false, true );
		wp_enqueue_script( 'theme-script', get_template_directory_uri() . '/assets/js/script.min.js', [], false, true );
    }

    function init() {
        // Navigation menus
        register_nav_menus( [
            'quick' => 'Quick Menu',
            'default' => 'Default Menu',
            'about' => 'About Menu',
            'service' => 'Service Menu',
        ] );

        // Sidebar(s)
        register_sidebar( [
            'id' => 'woo',
            'name' => 'Woo',
            'before_sidebar' => '',
            'before_widget' => '<div id="%1$s" class="widget %2$s">',
            'after_widget' => '</div>',
            'after_sidebar' => '',
        ] );

        // Important template parts
        add_action( 'wp_head', fn() => get_template_part( 'template-parts/head' ) );
        add_action( 'wp_body_open', fn() => get_template_part( 'template-parts/header' ) );
        add_action( 'wp_footer', fn() => get_template_part( 'template-parts/footer' ) );

        // WooCommerce Customizations
        add_action( 'woocommerce_init', [ $this, 'woocommerce_init' ] );

        // Allow SVG uploads
        add_filter( 'upload_mimes', fn( $mimes ) => array_merge( $mimes, [ 'svg' => 'image/svg+xml' ] ) );
        add_filter( 'wp_check_filetype_and_ext', function( $data, $file, $filename, $mimes ) {
            if ( ! $data['type'] && str_ends_with( strtolower( $filename ), '.svg' ) ) {
                $data['type'] = 'image/svg+xml';
                $data['ext']  = 'svg';
            }
            return $data;
        }, 10, 4 );

        // Remove default WooCommerce styles on non-shop and non-category pages
        add_filter( 'woocommerce_enqueue_styles', fn( $styles ) => ( is_shop() || is_product_category() ) ? [] : $styles );
    }

    function woocommerce_init() {
        // Customize WooCommerce pagination text
        add_filter( 'woocommerce_pagination_args', fn( $args ) => array_merge( $args, [ 'prev_text' => 'Previous', 'next_text' => 'Next' ] ) );
    }
}

$WP_THEME_INIT = new WP_THEME_INIT();
