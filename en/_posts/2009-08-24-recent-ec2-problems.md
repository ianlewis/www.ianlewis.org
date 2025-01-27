---
layout: post
title: "Recent EC2 Problems"
date: 2009-08-24 15:33:36 +0000
permalink: /en/recent-ec2-problems
blog: en
tags: tech devops cloud aws
render_with_liquid: false
---

Over the weekend we had some some problems with EC2 in which some
instances could not be connected to via a network. This happened to us
for a nginx load balancing server on Friday and a database master on
Saturday for two different web services. Several posts in the forums
also indicated
[similar](http://developer.amazonwebservices.com/connect/thread.jspa?threadID=35468&tstart=30)
[problems](http://developer.amazonwebservices.com/connect/thread.jspa?threadID=35466&tstart=30)
though rebooting the instance did not work for us.
[Bitbucket](http://www.bitbucket.org) also went down on Saturday which I
assume is related. I figured I would document what happened as Amazon
didn't release any information about it over the weekend and it wasn't
immediately clear what we should do but it turned out to be fastest for
us to replace the offending instance.

Connecting via ssh or any other means was impossible. Manipulating the
instance via the dashboard seemed to work but connecting via ssh
internally or externally was impossible rendering the instance useless.
This situation continued indefinitely as the instances in question were
never restored to the network.

We ultimately decided to replace our instances with new ones using the
same image and migrating the data on them to the new instance. This
required several hours of downtime for both sites. Migrating the data
and getting mysql replication restarted for the database master was
particularly annoying. The ebs volume holding the data could not be
detached (I assume) because it was still mounted to the offending
instance. I attempted to shut down the instance to get it to unmount the
drive but this didn't work either as the instance got stuck (and is
still stuck as of this writing) in a "shutting down" state. This meant
that I couldn't reattach the volume to another instance.

I was eventually able to take a consistent snapshot from the master
since it only held mysql data and wasn't being written to at the time.
If it had log data or other data on it I probably wouldn't have been
able to take a consistent snapshot. If I wasn't able to take a snapshot
I would have had to take data from one of the slaves which were in
different stages of replication (their replication log positions were
different) or used a daily backup. Neither of which felt good. Daily
backup means loosing the day's worth of data which sucks. I eventually
discarded the replicated data which was at various positions and took
the safe route and copied it from the master.

I created new volumes based on the snapshot for each slave and attached
them, ran RESET MASTER to reset the binary log data, ran CHANGE MASTER
on the slaves to reset the binary log position and master server host,
and then eventually SLAVE START to restart replication.

This episode makes me rethink ec2 as a provider. They still provide the
best virtualization service for the money but not being able to connect
to the instances directly via a console in emergencies like you would be
able to if you had your own Xen server is frustrating. There is no way
of knowing the state of the dead server. The forums are pretty much
useless for time sensitive issues, and it's hard to consider paying
Amazon for a support plan when their service is acting up.
