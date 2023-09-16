---
layout: post
title: "Using Mercurial MQ"
date: 2009-08-18 10:04:44 +0000
permalink: /en/using-mercurial-mq
blog: en
render_with_liquid: false
---

I recently started using mercurial's [mq
extension](http://mercurial.selenic.com/wiki/MqExtension) at work as I
found myself switching between changes a lot. I often had to set changes
I was currently working on aside to do a merge or fix something that was
more urgent. The mq extension makes that possible by managing patches
and allowing you to put away changes into the patch queue.

mq is included in mercurial's distribution by default but you need to
enable it in your .hgrc

```text
[extensions]
mq =
```

Ok, so now I'll run through the most used commands.

```text
hg qinit
```

When you want to create a new patch you use the qnew command.

```text
hg qnew
```

My original use case for mq was as a place to put my current changes so
I could do back to a normal state and do some work without actually
having to commit it to the repository. Originally I thought that because
qnew spit out errors when I tried to create a new patch, I figured I
would have do the following in order to get it back to a normal state
and create my patch.

```text
hg diff -U > my.diff
hg revert --all
hg qnew mypatch
patch -p1 < my.diff
```

But a friend informed me that the -f option to qnew does exactly what I
needed. It takes your current changes and then rolls them into the new
patch.

```text
hg qnew -f mypatch
```

The patch shows in your revision history while it's applied but it's not
really committed.

After you make some more changes you can update the patch by running
qrefresh.

```text
hg qrefresh
```

You run qrefresh with the -e option to set the commit message that is
used later when you actually commit to the repository.

```text
hg qrefresh -e
```

Once you set it you can just run qrefresh without the -e and it will
retain the message.

Here's the fun part. If you need to put the changes away you can unapply
them off by running qpop with the name of your patch

```text
hg qpop mypatch
```

or qpop -a which unapplies all the patches.

```text
hg qpop -a
```

This will bring you back to the normal repository version. You can then
merge or fix a bug or do what you need to do. After you are done and you
want to work on your changes again you can reapply them with qpush.

```text
hg qpush mypatch
```

or

```text
hg qpush -a
```

Mq doesn't care about the revision history so you can try to apply the
patch anywhere in the revision history. Be careful though since the
patch might not apply if there were changes to the files updated by the
patch.

Once you are done with all your changes you can run qfinish to commit
them to the regular repository.

```text
hg qfinish mypatch
```

You can call it with a range also. MQ gives you qbase and qtip labels
which are attached to the base patch and the tip patch. This effectively
finishes all the patches.

```text
hg qfinish qbase:qtip
```

That's it\!
