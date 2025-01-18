---
layout: post
title: "apt pinning"
date: 2008-04-15 00:00:48 +0000
permalink: /en/apt_pinning
blog: en
tags: tech devops
render_with_liquid: false
---

<p>Many people who are new to <a href="http://www.debian.org/" title="Debian">Debian</a> might be thinking that <a href="http://www.debian.org/" title="Debian">Debian</a> stable releases are slow. You are right. Many do look at this and turn to <a href="http://www.ubuntu.com/" title="Ubuntu">Ubuntu</a> because of their relatively quick releases. It's true that <a href="http://www.ubuntu.com/" title="Ubuntu">Ubuntu</a> does release &quot;stable&quot; versions more often but I would encourage people to sit back down and give <a href="http://www.debian.org/" title="Debian">Debian</a> another try. Especially with the cool feature of <a href="http://www.debian.org/" title="Debian">Debian</a>'s packaging system, <a href="http://en.wikipedia.org/wiki/Advanced_Packaging_Tool">apt</a>, called <a href="http://wiki.debian.org/AptPinning">apt pinning</a>.</p>

<p>Apt pinning allows you to get the best of both worlds. You get the stability of stable packages from stable, with the new software of testing and unstable as needed. Of course you will need to be a bit careful because some packages from testing or unstable can include packages that are unstable or otherwise broken. Installing packages from multiple distributions makes your system inherently more unstable since that kind of setup isn't tested as well as a normal setup.</p>

<p>Apt pinning requires that you modify two files. These files are <em>/etc/apt/sources.list</em> and <em>/etc/apt/preferences</em>. These files control where you get packages from and the priority of each repository respectively. First in your <em>sources.list</em> file you will want to add references to the testing and unstable repositories. Those references will look pretty similar to your existing references to the stable repository but will simply have references to testing and unstable rather than stable. Your <em>sources.list</em> might look like the following.</p>

<pre>#Stable<br />deb http://ftp.us.debian.org/debian stable main non-free contrib<br />deb http://non-us.debian.org/debian-non-US stable/non-US main contrib non-free<br /><br />#Testing<br />deb http://ftp.us.debian.org/debian testing main non-free contrib<br />deb http://non-us.debian.org/debian-non-US testing/non-US main contrib non-free<br /><br />#Unstable<br />deb http://ftp.us.debian.org/debian unstable main non-free contrib<br />deb http://non-us.debian.org/debian-non-US unstable/non-US main contrib non-free </pre>

<p>Mine looks like the following because I live in Japan. I also run testing as my base system and include packages from unstable when needed. I also include the references to the package source repositories. </p>

<pre>#Testing<br />deb ftp://ftp.jp.debian.org/debian/ lenny main<br />deb-src ftp://ftp.jp.debian.org/debian/ lenny main<br /><br />deb http://security.debian.org/ lenny/updates main contrib<br />deb-src http://security.debian.org/ lenny/updates main contrib<br /><br />deb http://http.us.debian.org/debian/ lenny main<br /><br />deb ftp://ftp.debian.or.jp/debian/ lenny main contrib non-free<br /><br /><br />#Unstable<br />deb ftp://ftp.jp.debian.org/debian/ sid main<br />deb-src ftp://ftp.jp.debian.org/debian/ sid main<br /><br />deb http://http.us.debian.org/debian/ sid main<br /><br />deb ftp://ftp.debian.or.jp/debian/ sid main contrib non-free</pre>

<p>Once you have that set up you will need to create your <em>preferences</em> file to set up the priority for getting packages. We are going to set a priority of stable -&gt; testing -&gt; unstable which means that if a package is found is more than one repository it will take the one from stable first, then the one from testing if the package doesn't exist in stable, then from unstable if the package doesn't exist in either stable or testing. This will have the effect of giving us the most stable package while allowing us to install newer packages.</p>

<pre>Package: *<br />Pin: release a=stable<br />Pin-Priority: 700<br /><br />Package: *<br />Pin: release a=testing<br />Pin-Priority: 650<br /><br />Package: *<br />Pin: release a=unstable<br />Pin-Priority: 600</pre>

<p>Once that is set up you can open up synaptic. One thing that is nice about synaptic is that it can support pinning. So the packages list in synaptic will show us the list of packages as we can install based on the priority we set up. According to <a href="http://jaqque.sbih.org/kplug/apt-pinning.html">this page</a> one of the problems you might run into is this error:</p>
E: Dynamic MMap ran out of room
E: Error occured while processing sqlrelay-sqlite (NewPackage)
E: Problem with MergeList /var/lib/apt/lists/ftp.us.debian.org_debian_dists_woody_contrib_binary-i386_Packages
E: The package lists or status file could not be parsed or opened.
<p>This is caused because apt's cache is too small to handle all of the packages that are included with stable, testing, and unstable. This is also very easy to fix. Add the following line to  /etc/apt/apt.conf</p>
<pre>APT::Cache-Limit &quot;8388608&quot;;</pre>

<p>Now that that is taken care of, lets say you have a particular package you want to install the newest version of, but the newest version of that packages isn't in stable yet. Synaptic will show you the version that's in stable because we set that as the highest priority. But you know there is a newer version out there. You can check <a href="http://packages.debian.org/">packages.debian.org</a> to see if the package you want is included in either testing or unstable but the quicker way is to check in synaptic itself. </p>

<p><a rel="lightbox" href="/assets/images/gallery/wget.png"><img src="/assets/images/gallery/wget.png" alt="wget" title="Different versions of wget" hspace="10" width="150" height="135" align="left" /></a>If there is a package that has a newer version in testing or unstable that you would like to install then you can do so by opening the properties for the package. Then click on the versions tab. There it will show you what versions you can install from different repositories. You can then select which version to install by choosing Package -&gt; Force version... or Package -&gt; Versions...  The name of the option might be slightly different as it changes a bit in different versions of synaptic. </p>
