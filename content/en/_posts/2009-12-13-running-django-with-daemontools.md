---
layout: post
title: "Running django with daemontools"
date: 2009-12-13 21:38:59 +0000
permalink: /en/running-django-with-daemontools
blog: en
tags: tech programming python django
render_with_liquid: false
---

Running django fastcgi with daemontools is rather easy but getting it to run in the foreground with the proper user takes a bit of knowledge about how bash works and the tools in daemontools.

In order to run the fastcgi daemon in the foreground you need to specify the daemonize=false option to the fastcgi command.

Next the daemon will be started as the root user unless the daemon has an option to change the user itself. The fastcgi daemon doesn't so we will use a tool from daemontools called setuidgid to set the user to www which is the user we want to run the daemon as.

Finally since we are using setuidgid we need to use the exec command in bash so that the standard process pipe established with the fastcgi process.

## /service/myapp/run

```bash
#!/bin/bash

BASEDIR="/home/www/"
PIDFILE="$BASEDIR/app.pid"

exec setuidgid www python /home/www/django-prj/manage.py runfcgi \
    --settings=settings_production method=threaded  port=8001 \
    pidfile=$PIDFILE daemonize=false 2>&1
```
