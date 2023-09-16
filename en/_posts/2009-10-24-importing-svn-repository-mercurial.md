---
layout: post
title: "Importing an svn repository into mercurial"
date: 2009-10-24 11:09:58 +0000
permalink: /en/importing-svn-repository-mercurial
blog: en
render_with_liquid: false
---

Recently I've been forking svn repositories by converting them to
mercurial repositories and uploading them to
[bitbucket](http://www.bitbucket.org/). It's fairly easy with the
[mercurial convert
extension](http://mercurial.selenic.com/wiki/ConvertExtension). Convert
is distributed with mercurial so if you have a recent version all you
should have to do is put the following in your hgrc.

```text
[extensions]
hgext.convert=
```

Converting a repository over http by running convert using the
repository url can be very slow so it's generally much faster to sync
the svn repository locally and then convert it to hg. First you need to
use [svnsync](http://svn.collab.net/repos/svn/trunk/notes/svnsync.txt)
to copy the repository.

```text
$ svnadmin create foomirror
$ echo '#!/bin/sh' > foomirror/hooks/pre-revprop-change   # make insecure dummy hook
$ chmod +x foomirror/hooks/pre-revprop-change
$ svnsync init --username svnsync file://`pwd`/foomirror https://foo.svn.sourceforge.net/svnroot/foo
Copied properties for revision 0.
$ svnsync sync file://`pwd`/foomirror
Committed revision 1.
Copied properties for revision 1.
Committed revision 2.
Copied properties for revision 2.
...
```

Once the mirror is set up you can run hg convert on the local mirror.
This turns out to be much faster than trying to convert the svn
repository remotely.

```text
$ hg convert foomirror   # convert directly from repo mirror to foomirror-hg
...
```
