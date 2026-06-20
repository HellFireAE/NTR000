function stickyHeader() {
	var t = document.querySelector(".sentinal + .sticky-top");

	if ( ! document.body.contains( t ) ) return;

	const e = document.querySelector(".sentinal"),
		o = new window.IntersectionObserver(e => {
			e[0].isIntersecting ? t.classList.remove("shadow-lg") : t.classList.add("shadow-lg")
		});
	o.observe(e)
}

document.addEventListener("DOMContentLoaded", () => {
	stickyHeader()
});
