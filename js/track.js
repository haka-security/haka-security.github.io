(function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
	(i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
})(window,document,'script','//www.google-analytics.com/analytics.js','ga');

ga('create', 'UA-52597895-1', 'auto');
ga('send', 'pageview');

/* Track external links */
$(document).ready(function() {
	$.expr[':'].external = function (obj) {
		return !obj.href.match(/^mailto\:/) && !obj.href.match(/^javascript\:/)
			&& (obj.hostname != window.location.hostname);
	};

	$("a:external").on('click', function(e) {
		var href = $(this).attr("href");
		var target = $(this).attr("target");

		e.preventDefault();

		var t = setTimeout(function() {
				window.open(href, (!target ? "_self" : target))
			}, 250);

		ga('send', {
			'hitType': 'event',
			'eventCategory': 'external link',
			'eventAction': 'click',
			'eventLabel': href,
			'hitCallback': function() {
				clearTimeout(t);
				window.open(href, (!target ? "_self" : target));
			}
		});
	});
});
