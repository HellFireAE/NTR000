<?php defined( 'ABSPATH' ) || exit; ?>
<?php global $product; ?>

<li>
    <div class="card text-center border-light-subtle rounded-1">
        <div class="m-3 mb-2 border border-2 border-light-subtle rounded-circle overflow-hidden">
            <div class="ratio ratio-1x1 bg-white">
                <div class="d-flex align-items-center justify-content-center">
                    <?php the_post_thumbnail( 'medium', array( 'class' => 'object-fit-cover' ) ) ?>
                </div>
            </div>
        </div>

        <div class="card-body">
            <p class="card-title m-0 text-primary fw-bold"><span class="price"><?php echo $product->get_price_html() ?></span></p>
            <?php the_title( '<h5 class="card-text h6 mb-3">', '</h5>' ) ?>

            <div class="py-2">
                <a href="<?php the_permalink() ?>" class="btn btn-sm btn-primary text-uppercase rounded-1 stretched-link">View More Info</a>
            </div>
        </div>
    </div>
</li>
