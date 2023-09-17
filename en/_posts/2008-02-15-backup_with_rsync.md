---
layout: post
title: "Backup with rsync"
date: 2008-02-15 14:18:00 +0000
permalink: /en/backup_with_rsync
blog: en
tags: windows linux rsync
render_with_liquid: false
---

<p>I wanted to have a simple incremental backup system I could use on my machine to backup to an external drive so I came across <a href="http://benno.id.au/blog/2007/05/30/rsync-backup">this post</a> on <a href="http://benno.id.au/blog/">Benno's blog</a>. Basically it involves using rsync with the --link-dest option to compare files you are backing up against an previous backup and only create new copies when the files have been modified since the previous backup. The rsync command would look something like the following:</p>
<pre>rsync -a --link-dest=backup.0/ /dir.to.backup/ backups.1/. </pre>
<p>If the files have not been modified then it creates a hard link to the files so it doesn't have to create a copy in order for the backup folder to have references to all the files in the backup. Without something like that, restoring is hard because in order to get all the files during a restore because the latest backup would only contain files that have been updated.</p><p>The problem is that if you have an external drive that you want to be able to use with windows you need to use the vfat file system which doesn't support hard or soft links. I have looked around for ideas about how do get around this problem and it might just be that I need to split the drive into two partitions, vfat and ext2/3, and and use the ext part for backups. There at least seems to be some <a href="http://www.fs-driver.org/">ext2/3 support for windows</a> which seems promising but using it would mean that not every windows machine would be able to read it, just the ones with support installed. Also, the software does not support permissions or soft links in any way so using it might be difficult in some situations. </p><p>Both ways have downsides but I don't use windows much at all so I'm leaning towards just making a ext3 partition. Maybe I'll do that this weekend. </p>
