---
layout: post
title: "Using Daemontools"
date: 2009-10-06 11:15:29 +0000
permalink: /en/using-daemontools
blog: en
---

# Introduction

[Daemontools](http://cr.yp.to/daemontools.html) is a set of programs for
monitoring daemon programs and also restarts them immediately if they
crash or are terminated. I generally use daemontools for daemons that
are required and are always running web sites. These include webservers,
mail servers, monitoring servers and fastcgi servers.

# Processes

Daemons usually run in the background so they don't hold up the
terminal. But Daemontools works by keeping the standard pipe to the
process open so that it can monitor when the process terminates. It
knows when the process terminates because the pipe to the process is
closed. This means that daemons need to be set to run in the foreground.
Daemons usually run as background processes so many require an option to
be set to run in the foreground.

# Services

Services consist of a script called 'run' which starts the application
and a supervise directory. The run script is run by daemon tools in the
foreground to start the process. A 'supervise' directory is created
automatically but you should never have to touch it. You can also enable
logging of standard output for daemon tools which is itself a daemon run
by daemon tools.

Here's a simple example run script for lighttpd. The -D option here
specifies that the server runs in the foreground.

``` bash
#!/bin/sh
exec /usr/sbin/lighttpd -D -f /etc/lighttpd/lighttpd.conf 2>&1
```

Available services normally reside in the /var/service directory. You
put your services here. You might have a directory listing like this:

``` text
[root@admin:/var/service] ls -lh
合計 28K
drwxr-x--- 4 root root 4.0K  8月 24 14:45 lighttpd
drwxr-x--- 4 root root 4.0K  8月 24 14:35 memcached
drwxr-x--- 4 root root 4.0K  8月 24 14:35 nagios
drwxr-x--- 4 root root 4.0K  3月 24 11:39 snmpd
drwxr-x--- 4 root root 4.0K  8月 24 14:37 myapp
```

These services aren't enabled yet as they are simply the available
services on the server. You enable services my symbolic linking them to
the /service directory which is the standard location for daemontools
services. Your /service directory might look like:

``` text
lrwxrwx--- 1 root root 21  3月 24 11:52 lighttpd -> /var/service/lighttpd
lrwxrwx--- 1 root root 22  3月 24 11:50 memcached -> /var/service/memcached
lrwxrwx--- 1 root root 19  3月 24 11:53 nagios -> /var/service/nagios
lrwxrwx--- 1 root root 18  3月 24 11:39 snmpd -> /var/service/snmpd
lrwxrwx--- 1 root root 18  3月 24 11:50 myapp -> /var/service/myapp
```

# Commands

## svstat

Once you create these symbolic links the supervise daemon should start
the daemons immediately. You can confirm that it is running by using the
[svstat](http://cr.yp.to/daemontools/svstat.html) command. svstat and
the other daemontools commands take the directory as their argument for
which service you are talking about you you need to give it the
directory where the service resides.

``` text
[root@admin:~] cd /var/service
[root@admin:/service] svstat memcached
memcached: up (pid 2226) 220460 seconds
```

Sometimes however daemon tools will report the service is up but it
really isn't as it is trying to continually start the process and it's
failing every time. In that case daemontools will say it's up but each
time you run the svstat command it will show a new pid and the uptime
will have been reset.

``` text
[root@admin:~] cd /var/service
[root@admin:/service] svstat memcached
memcached: up (pid 1842) 1 seconds
[root@admin:/service] svstat memcached
memcached: up (pid 1854) 1 seconds
[root@admin:/service] svstat memcached
memcached: up (pid 1859) 0 seconds
```

In that case you can try to figure out why the process is not starting
by examining the logs or look for a "readproctitle" error message.
readproctitle is a process that is part of daemontools that shows the
last 400 bytes of error messages that are produced by the svscan
process. You can check it by running a command like:

``` text
ps -Af | grep readproctitle
```

## svc

[svc](http://cr.yp.to/daemontools/svc.html) allows you to control
services. You use svc to start, stop, and restart services. Services are
specified by the directory they live in.

You can start a service using the -u option.

``` text
svc -u <service dir>
```

You can then run svstat to make sure it's up.

``` text
$ svstat memcached/
memcached/: up (pid 3499) 1 seconds
```

You can stop a service using the -d option.

``` text
$ svc -d memcached/
$ svstat memcached
memcached/: down 3 seconds, normally up
```

That wraps up a basic use of daemontools to manage processes. Using
daemontools can be pretty frustrating as many processes refuse to run in
the foreground and don't handle UNIX signals properly but if you get it
running properly it can really improve the reliability of your services.
