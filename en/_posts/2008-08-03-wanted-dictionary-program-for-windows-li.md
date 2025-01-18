---
layout: post
title: "Wanted: Dictionary program for Windows/Linux"
date: 2008-08-03 18:21:00 +0000
permalink: /en/wanted-dictionary-program-for-windows-li
blog: en
tags: tech projects c++ c
render_with_liquid: false
---

<p>I have wanted a good dictionary application that supports a number of dictionaries/dictionary formats for studying Japanese but I've been sort of frustrated that there is no single application that does what I would like. I have looked mostly at <a href="http://stardict.sourceforge.net/">stardict</a> and <a href="http://epwing.sourceforge.net/">epwing</a> because they are closest to the type of dictionary I want. Specifically I have the following requirements:</p>
<ol>
<li>It must work in <a href="http://en.wikipedia.org/wiki/Linux" title="Linux">Linux</a> (epwing and stardict)<br /></li>
<li>It must work in Windows (epwing and stardict)<br /></li>
<li>It must support epwing format (epwing)<br /></li>
<li>It should ideally support an open dictionary format like stardict. (stardict)<br /></li>
<li>It must support lookup via a <a href="http://stardict.sourceforge.net/images/stardict03e.gif">popup</a> (epwing and stardict) </li>
<li>It must support installing dictionaries as a non-root user (epwing)<br /></li>
<li>It should support minimization to the system tray (stardict)<br /></li>
</ol>
<p>1 and 2 and 5 are supported by both stardict and epwing but epwing's popup support is less than ideal and epwing supports nothing but epwing and doesn't minimize to the system tray. The way epwing looks up words from multiple dictionaries is also less than ideal,</p>
<p>Stardict on the other hand supports most of the things I want but doesn't support epwing or any way of converting the dictionaries from epwing to stardict format. There are a number of tools to read epwing dictionaries so I think this could be done, but I don't think stardict dictionaries currently support images or media like epwing dictionaries support so converting epwing dictionaries would lose that data. Stardict also has a  number of strange plugins and a net dictionary protocol which seems strange. I'm not sure if the server side code is open either.</p>
<p>I've been looking ot the code for each of the dictionaries and it seems like while epwing's code is simpler and easier to read, stardict supports most of the features I want already so it would be better to explore how to add the features I want to add. Development on both projects is pretty much halted so I should be able to add features at my own pace without stepping on current development.</p>
<p>I'm not looking forward to spending a lot of time on it but my frustration with dictionaries has reached a bit of a boiling point.</p>
