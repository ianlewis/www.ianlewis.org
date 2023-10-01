---
layout: post
title: "Setting output of a program to a variable in Windows Batch"
date: 2007-11-07 18:03:39 +0000
permalink: /en/setting_output_of_a_program_to_a_variabl
blog: en
tags: mercurial
render_with_liquid: false
---

I recently had to do this to get [TortoiseMerge](http://tortoisesvn.tigris.org/TortoiseMerge.html) working with [Mercurial](http://www.selenic.com/mercurial/) within [Cygwin](http://www.cygwin.com/). It turned out to be pretty easy and I couldn't believe that a [lot](http://www.infionline.net/~wtnewton/batch/batchfaq.html#9) [of](http://www.student.northpark.edu/pemente/sed/bat_env.htm#sed) [people](http://www.tomshardware.com/forum/230090-45-windows-batch-file-output-program-variable) were saying that you had to route the output to a temporary file and then read it back into your program or some such garbage. Anyway, behold!!

```bat
for /f &quot;tokens=1&quot; %%A in (
    '"cygpath -w %1"' ) do set TMergePath1=%%A
```

It's kind of a hack using the [FOR /f](http://www.robvanderwoude.com/ntfortokens.html) but it basically allows you to set the output of a program to a variable. You can even parse the output to pull out a particular piece of the output to put in the variable. This is particularly useful with windows commandline programs which weren't really made to be piped and redirected.

Anyway, in my case I'm setting the output of cygpath called on a cygwin path to convert it into a windows path and then set the output to the TMergePath variable. The `tokens=1` part tells the program that I only want to call the code after `do` for the first token. In my case there is only one anyway. You can set `tokens=1,2,4` if you want to loop for the first, second and forth tokens. You can also set the delimiter like `tokens=1,2,4 delims=;` if your output looks like token1;token2;token3;token4
