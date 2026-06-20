<?php
defined( 'ABSPATH' ) || exit;

woocommerce_product_loop_start();

while ( have_posts() ) {
	the_post();

	get_template_part( 'template-parts/loop', 'product' );
}

woocommerce_product_loop_end();

the_posts_pagination( [
	'prev_text' => 'Previous',
	'next_text' => 'Next',
	'type' => 'list',
	'end_size' => 3,
	'mid_size' => 3,
	'class' => 'woocommerce-pagination'
] );

wp_reset_query();
