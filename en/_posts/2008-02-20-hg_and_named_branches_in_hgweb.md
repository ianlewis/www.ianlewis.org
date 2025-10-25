---
layout: post
title: "Mercurial and named branches and hgweb"
date: 2008-02-20 12:19:59 +0000
permalink: /en/hg_and_named_branches_in_hgweb
blog: en
tags: tech programming
render_with_liquid: false
---

[Mercurial](http://www.selenic.com/mercurial/) is a nice distributed SCM system
written in Python which I have been using at work and at on OSS projects for a
little while now. [Mercurial](http://www.selenic.com/mercurial/) allows three
types of branching, cloning, named branches, and local branches. Each of these
has it's uses but I have only really used cloning and named branches in my own
development.

[Cloning](http://www.selenic.com/mercurial/wiki/index.cgi/TutorialClone) simply
allows you to create a new branch of a repository by creating a copy of it.
Simple. You make a copy of the repo, make changes in that copy, and you can
merge the changes back into the original branch using `push` or merge
changes in the original into your copy using `pull`. This is by far the
simplest way to do branching. Each branch is self contained and easily
managed/copied/deleted (which may or may not be a good thing depending on how
you see things).

[Named branches](http://www.selenic.com/mercurial/wiki/index.cgi/NamedBranches)
are branches that live in the same repo. You can create a new branch make a
commit, and switch back to the original branch all within the same repo. This is
achieved using the `branch` command in mercurial. You can switch your branch
like so:

```bash
hg branch mybranch
```

Here we just created a branch off of the current version and called it
`mybranch`. Now if we make a change and commit it this change will be marked as
part of our new branch. This is kind of nice because we can switch between
branches quickly and easily. Also, long lived branches can be split off within
the same repo and merged easily using the `merge` command. You can switch
between branches by updating your local repo with the following command:

```bash
hg update -C mybranch
```

This command figures out what changes need to be removed and what needs to be
added to get you to the `HEAD` of the another branch.

Unfortunately, this is where the good things about named branches end. Named
branches live in the same repository so you can't selectively push or pull
changes. So if you have a bunch of changes in your main branch that are ready
for pushing to your shared repo, but you have a named branch full of changes
that aren't ready to see the light of day, you can't selectively push the stuff
in your main branch without pushing the stuff in your test branch. This is a big
problem because it can clutter up your shared repo.

Also, the hgweb and hgwebdir cgi scripts that show you changes to your
repository in a easy to understand way simply fail to break changes out by named
branch. This was the biggest problem for me because I lost track of what changes
I had put in what branch so I had trouble compiling all the changes I wanted to
for a release. I really wanted to look at the web interface and see the
`CHANGELOG` for a particular branch but the hgweb interface simply shows all
changesets in chronological order regardless of what branch you clicked on. It
also doesn't show what branch a change was committed to so it's impossible to
find out where a particular change was committed without looking at the parent
changeset and backtracking to where it was split off from the main branch (this
is not reasonably achievable.

Named branches are also not deletable. Meaning once you figure out all of the
downsides of using them your repository is already full of these named branches
and you can't delete them. This also exasperates the push problem because you
might push some changes in a test branch to a shared repo inadvertently but once
you realize this the damage is already done because you can't delete the branch
from the shared repo without backing out all of the changes you made, nor can
you delete them from your local repo and then push, or selectively push only one
named branch. Basically you're stuck with them forever.

This is probably why there has been
[talk](http://www.selenic.com/pipermail/mercurial/2008-February/017024.html)
[on](http://www.selenic.com/pipermail/mercurial/2008-February/017026.html) the
[Mercurial mailing list](http://www.selenic.com/pipermail/mercurial/) this month
about fixing named branches and recommending that developers not use them until
they are.
