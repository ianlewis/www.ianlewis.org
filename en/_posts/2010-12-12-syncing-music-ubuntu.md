---
layout: post
title: "Syncing music on Ubuntu"
date: 2010-12-12 12:33:57 +0000
permalink: /en/syncing-music-ubuntu
blog: en
---

I recently played around with and figured out how to get syncing working
with my iPhone 3GS and Ubuntu Lucid. Syncing is supported out of the box
so not hard, but you do have to know what packages to install to get the
support you need. This should work for iPods as well.

I am using rhythmbox so the following packages are required if using
rhythmbox:

  - rhythmbox
  - rhythmbox-plugins - Without these pretty much nothing but playback
    works.
  - gstreamer0.10-plugins-good
  - gstreamer0.10-plugins-ugly - for mp3 playback
  - gstreamer0.10-plugins - for on the fly ogg -\> mp3 encoding (this is
    good since iPod doesn't support vorbis)

After installing these packages I could get rhythmbox to add my iphone
to the menu on the left and I could drag files into it to sync. Ogg
files were converted to mp3 automatically (though with some quality
loss).
