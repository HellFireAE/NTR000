<?php defined( 'ABSPATH' ) || exit; ?>

<div class="sidebar sticky-lg-top z-1">
	<nav class="navbar navbar-expand-lg p-0">
        <button class="btn btn-primary d-lg-none" type="button" data-bs-toggle="offcanvas" data-bs-target="#filter" aria-controls="filter" aria-label="Toggle filter">
            <span>Narrow Results</span>
        </button>

		<div class="offcanvas offcanvas-start" tabindex="-1" id="filter" aria-labelledby="filterLabel">
			<div class="offcanvas-header d-lg-none border-bottom">
				<h5 class="offcanvas-title" id="filterLabel">Filter</h5>
				<button type="button" class="btn-close" data-bs-dismiss="offcanvas" aria-label="Close"></button>
			</div>

			<div class="offcanvas-body">
				<?php if ( is_active_sidebar( 'woo' ) ) : ?>
				<div class="widgets" style="--bs-link-color-rgb: var(--bs-secondary-color-rgb) !important;">
					<?php dynamic_sidebar( 'woo' ) ?>
				</div>
				<?php endif ?>
			</div>

			<div class="offcanvas-header border-top text-bg-black justify-content-end d-lg-none">
				<button type="button" data-bs-dismiss="offcanvas" aria-label="Close" class="btn btn-primary">Show Results</button>
			</div>
		</div>
	</nav>
</div>
