---
layout: post
title: "cp interactive copy"
date: 2007-11-24 18:50:40 +0000
permalink: /en/cp_interactive_copy
blog: en
render_with_liquid: false
---

Is it just me or has the behavior of cp in linux distributions changed recently? cp is non-interactive by default so a lot of people, myself included, set an alias to include the -i flag so that cp was interactive by default.

```bash
alias cp=cp -i
```

But I used to enjoy the fact that if I set this alias it would prompt me when overwriting files but if there was a situation where I wanted it to be non-interactive I could do that by specifying -f. Basically, the last -i or -f would win. I want interative by default but the ability to specify non-interactive at my discretion.</p><p>However, recently or so, I noticed that several linux distributions include a cp that if you specify a cp -i alias you cannot specify -f to use non-interactive mode. The -f is ignored or at least doesn't cancel out the -i. Perhaps there is another way do to what I want but I'm unaware of it at the moment. Currently I have to remove the alias, do the non-interactive copy, and then reinstate the alias. Super annoying.

**Update:** You can bypass an alias by putting quotes around the command like so,

```console
$ "cp" source destination
```
