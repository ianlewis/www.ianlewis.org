---
title: Talks &amp; Publications
layout: page
permalink: /publications
---

These are some of the talks talks I've given, podcasts I've been on, books I've
written, etc.

{% for publication in site.data.publications.publications %}

{%- assign session_year = nil -%}
{% if publication.type == "podcast" -%}
{%- assign session_year = publication.session.date | date: "%Y" -%}
{% else -%}
{%- for session in publication.sessions -%}
{%- assign current_session_year = session.date | date: "%Y" -%}
{%- unless session_year -%}
{%- assign session_year = current_session_year -%}
{%- else -%}
{%- if current_session_year > session_year -%}
{%- assign session_year = current_session_year -%}
{%- endif -%}
{%- endunless -%}
{%- endfor %}
{% endif %}

{%- unless current_year -%}
{%- assign current_year = session_year -%}
{% else -%}
{%- if session_year < current_year -%}
{%- assign current_year = session_year -%}
{%- endif -%}
{%- endunless -%}

{% unless last_year == current_year %}

## {{ current_year }}

{% assign last_year = current_year %}
{% endunless %}

### {% if publication.type == "podcast" %}🎧 {% else %}{% if publication.type == "talk" %}🎙️ {% endif %}{% endif %}{{ publication.name }}{% if publication.type == "podcast" -%}{% if publication.session.podcast.url %} - [{{ publication.session.podcast.name }}]({{ publication.session.podcast.url }}){% else %} - {{ publication.session.podcast.name }}{% endif %}{% else %}{% for session in publication.sessions -%}{% if forloop.first %} - {% endif %}{% if session.url %}[{{ session.event.name }}]({{ session.url }}){% else %}{% if session.event.url %}[{{ session.event.name }}]({{ session.event.url }}){% else %}{{ session.event.name }}{% endif %}{% endif %}{% if session.event.location.city %} ({{ session.event.location.city }}{% endif %}){% unless forloop.last %}, {% endunless %}{%- endfor %}{% endif %}

{% if publication.video and publication.video contains "www.youtube.com" -%}
{% assign url_parts = publication.video | split: 'v=' %}
{% assign youtube_id = url_parts[1] | split: '&' | first %}
<iframe
    title="YouTube video player"
    src="https://www.youtube-nocookie.com/embed/{{ youtube_id }}"
    class="youtube"
    allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share"
    referrerpolicy="strict-origin-when-cross-origin"
    allowfullscreen>
</iframe>
{%- endif %}

{% if publication.abstract %}{{ publication.abstract }}{% endif %}

{% if publication.video %}- 🎥 [Video]({{ publication.video }}){% endif %}
{% if publication.slides %}- 📄 [Slides]({{ publication.slides }}){% endif %}

{% endfor %}
