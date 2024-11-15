---
# Feel free to add content and custom Front Matter to this file.
# To modify the layout, see https://jekyllrb.com/docs/themes/#overriding-theme-defaults
# title: Ian Lewis

layout: home
permalink: /
---

# Hi, I'm Ian

I am an engineer based in Tokyo, Japan since 2006. I am fluent in Japanese
passing
[JLPT](https://en.wikipedia.org/wiki/Japanese-Language_Proficiency_Test) N1 in 2013.

My current interests are in Container Native Security, Supply Chain Security,
Containers, and [Kubernetes](https://kubernetes.io/). I previously worked as
a Developer Advocate for [Google Cloud Platform](https://cloud.google.com/).
The opinions stated here are my own, not necessarily those of my company.

## Recent blog posts

{% assign posts = site.posts | slice: 0, 5 %}
{% for post in posts %}- {{ post.date | date: "%Y/%m" }} [{{ post.title }}]({{ post.url }})
{% endfor %}

## Past work

While at Google I've worked on a projects and services relating to containers,
security, and open-source, including the [SLSA framework](https://slsa.dev/)
and [gVisor](https://gvisor.dev/).

Prior to Google I focused on developer communities developing
[Connpass](https://connpass.com/), the largest IT meetup event tool in Japan
with hundreds of thousands of users. I also co-founded and served on the board
of [PyCon JP](https://www.pycon.jp/), the largest Python event in Japan.

During this time I was a [Google Developer
Expert](https://developers.google.com/experts/) specializing in the Python
language version of [App Engine](https://cloud.google.com/appengine/).

I wrote _[Perfect Python](https://amzn.asia/d/bAWDVkk)_ with other Japanese
Python community members, and have written articles for [Nikkei Linux
Magazine](https://info.nikkeibp.co.jp/media/LIN/).

## Contact

You can contact me via my email at [ianmlewis@gmail.com](mailto:ianmlewis@gmail.com).
