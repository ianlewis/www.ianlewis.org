---
layout: post
title: "Jaiku on App Engine"
date: 2009-03-16 00:52:31 +0000
permalink: /en/jaiku-on-appengine-1
blog: en
tags: tech cloud
render_with_liquid: false
---

<!-- TODO(#339): Add alt text to images. -->
<!-- markdownlint-disable MD045 -->

![](/assets/images/516/jaiku.png){:style="width: 60%; display:block; margin-left:auto; margin-right:auto"}

Yesterday Google's Twitter-like service, [Jaiku](http://www.jaiku.com/) was
[released](http://code.google.com/p/jaikuengine/) as open source running on
[Google App Engine](http://code.google.com/appengine/) so I decided to take it
for a spin. It has a lot of neat parts like XMPP and google contacts
integration, but what I'm interested in most is how it implements it's
publisher/subscriber model.

I brought the code down from svn and tried to follow the instructions, but I
got a "No module named django" error. One of the problems currently with
App Engine is that you have a limit of 1000 files you can upload. Because of
this limit when deploying jaiku you need to zip a bunch of libraries into a zip
file and use zipimport. Accordingly you have to prevent the source files from
being uploaded because you get an error saying you can't upload more than 1000
files.

The problem there is that the newest (1.1.9) SDK prevents you from loading
modules and/or accessing files that are specified in the skip-files directive
in your app.yaml. This prevented me from importing django because it's a zipped
module.

At first I tried just zipping the files up using the zip_all command in the
Makefile (make zip_all) but I still got the same error so I just commented out
the relevant parts in app.yaml.

```yaml
skip_files: |
    ^(.*/)?(
    (app\.yaml)|
    (app\.yml)|
    (index\.yaml)|
    (index\.yml)|
    (#.*#)|
    (.*~)|
    (.*\.py[co])|
    (.*/RCS/.*)|
    # (\..*)|
    # (manage.py)|
    # (google_appengine.*)|
    # (simplejson/.*)|
    # (gdata/.*)|
    # (atom/.*)|
    # (tlslite/.*)|
    # (oauth/.*)|
    # (beautifulsoup/.*)|
    # (django/.*)|
    # (docutils/.*)|
    # (epydoc/.*)|
    # (appengine_django/management/commands/.*)|
    # (README)|
    # (CHANGELOG)|
    # (Makefile)|
    # (bin/.*)|
    # (images/ads/.*)|
    # (images/ext/.*)|
    # (wsgiref/.*)|
    # (elementtree/.*)|
    # (doc/.*)|
    # (profiling/.*)
    )$
```

From there it should have worked but I got an error about the pstats module.
That just happened to not be installed on my machine so installed
python-profiler and Jaiku ran from there.

<!-- markdownlint-enable MD045 -->
