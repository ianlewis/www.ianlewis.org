---
layout: post
title: "Using less and grep with logs"
date: 2008-04-17 17:34:43 +0000
permalink: /en/using-less-and-grep-with-logs
blog: en
tags: tech linux unix
render_with_liquid: false
---

<p>Recently I&apos;ve been doing a decent amount of debugging a database conversion process and looking at log files on the Red Hat servers at work. This has meant looking at some rather big (10 or so megabytes) log files. Normally I just fire up vim when looking at text files but opening a text file in a text editor that is a number of megabytes is a no-no since pretty much any text editor will load the whole file.</p>

<p>Text viewers like more and less, however, however can skip this little bit since  you aren&apos;t going to be changing an arbitrary part of the file. So you can skip through the file with relative ease. While I know my way around a <a href="http://en.wikipedia.org/wiki/Linux" title="Linux">Linux</a> system, I am unfortunately woefully lacking in knowledge (sed-fu, grep-fu, find-fu or whatever) more than *very* basic usage of rather common *nix tools.</p>

<p>Anyway, I picked up a little bit about how to use less and found that I used a few commands often. Less normally opens a file starting at the beginning of the file but normally you want to look towards the end of logs and tail is not terribly useful for looking backwards through a log file. </p>

<pre>less +G &lt;file&gt;</pre>

<p>will open the file from the end and allow you to scroll backwards through it. In this context, like vi, using a slash &apos;/&apos; followed by a string can help you search forward through a file but going backward, I learned, is achieved with the question mark &apos;?&apos; character.</p>

<p>Another command that is pretty useful is grep, and when searching log files you might want to find a particular part of the file, like an error message but also some text before or after the error. You can do this with the -A and -B commands, meaning &apos;After&apos; and &apos;Before&apos; respectively.</p>

<pre>grep -A 5 -B 10 error &lt;file&gt;</pre>

<p>will give print the lines matching the string &apos;error&apos; in the given file, but also give 5 lines of context after and 10 lines of context before the matched line. This is pretty useful when searching log files but can get confusing sorting out what is context and what is a match when it matches many lines.</p>
