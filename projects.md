---
title: Projects
layout: page
permalink: /projects
---

These are some of the projects I have worked on.

{% for project in site.data.projects.projects %}

---

<img align="left" class="light" src="/assets/images/ianlewis/{{ project.image_light }}" height="80" style="margin-right: 10px">
{% if project.image_dark and site.plainwhite.dark_mode %}
<img align="left" class="dark" src="/assets/images/ianlewis/{{ project.image_dark }}" height="80" style="margin-right: 10px">
{% endif %}

{{ project.description }}
{% endfor %}
