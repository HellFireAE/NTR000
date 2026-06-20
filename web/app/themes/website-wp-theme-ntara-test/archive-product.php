<?php defined( 'ABSPATH' ) || exit; ?>
<?php get_header() ?>

<div class="container">
  <div class="row gx-5">
    <div class="col-lg order-last py-4">
        <?php do_action( 'woocommerce_shop_loop_header' ); ?>
        <?php do_action( 'woocommerce_before_shop_loop' ); ?>
        <?php get_template_part( 'template-parts/content', 'archive-product' ) ?>
    </div>

    <div class="col-lg-auto py-4" style="min-width: 246px;">
      <?php get_sidebar( 'woo' ) ?>
    </div>

    <div class="d-none d-lg-block col-auto p-0 bg-light" style="width: 2px;">&nbsp;</div>
  </div>
</div>

<?php get_footer() ?>
