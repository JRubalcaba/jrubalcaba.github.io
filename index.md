---
layout: archive
permalink: /
title: "Latest Posts"
image:
  feature: Mt Kenya.JPG
---

<div class="tiles">
{% for post in site.posts %}
	{% include post-grid.html %}
{% endfor %}
</div><!-- /.tiles -->
