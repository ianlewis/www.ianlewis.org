---
title: Projects
layout: page
permalink: /projects
---

These are some of the projects I have worked on.

{% for project in site.data.projects.projects %}

---

{% if project.image_light %}
![{{ project.name }} logo](/assets/images/ianlewis/{{ project.image_light }}){: .light}{:style="float: left; margin-right: 10px; max-width: 25%;"}
{% endif %}
{% if project.image_dark and site.plainwhite.dark_mode %}
![{{ project.name }} logo](/assets/images/ianlewis/{{ project.image_dark }}){: .dark}{:style="float:left; margin-right: 10px; max-width: 25%;"}
{% endif %}

{{ project.description }}
{% endfor %}
