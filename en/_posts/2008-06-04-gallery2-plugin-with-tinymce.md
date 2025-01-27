---
layout: post
title: "Gallery2 plugin with TinyMCE"
date: 2008-06-04 18:18:21 +0000
permalink: /en/gallery2-plugin-with-tinymce
blog: en
tags: tech programming projects php
render_with_liquid: false
---

I made some changes to the [TinyMCE
plugin](http://manual.b2evolution.net/Plugins/tinymce_plugin) for
[b2evolution](http://www.b2evolution.net/) to support some callbacks which will
allow other b2evolution plugins to register TinyMCE plugins automatically. This
is especially useful for the
[Gallery2 plugin](http://manual.b2evolution.net/Plugins/gallery2_plugin) because
it will allow me to add a button that allows users to add photos from Gallery2
to their blog posts to TinyMCE automatically when the Gallery2 plugin is
installed. Currently
[it's a pain to get it to work](http://manual.b2evolution.net/Plugins/gallery2_plugin#Using_the_Gallery2_Plugin_with_the_TinyMCE_Plugin)
because the standard gallery2 image chooser button doesn't work with TinyMCE
and installing it requires you to copy the g2image directory to another
location.

Fortunately these sorts of callbacks are implemented in the
[b2evolution Plugin API](http://doc.b2evolution.net/v-2-4/plugins/Plugin.html)
already. I just needed to specify that the TinyMCE plugin has some extra
callbacks and then fire the associated events at the right time. The code is a
bit awkward but it serves it's purpose.

The first part is specifying the extra events.

```php
function GetExtraEvents()
{
  return array(
    "tinymce_before_init" => "Event that is called before tinymce is initialized",
    "tinymce_extend_plugins" => "Event called to allow other plugins to extend the plugin list",
    "tinymce_extend_buttons" => "Event called to allow other plugins to extend the button list"
  );
}
```

Then I fire the events like so. The `tinymce_extend_plugins` and
`tinymce_extend_buttons` events allow other plugins to modify the plugins list
and buttons list via a special `get_trigger_event` call.

```php
$tmce_plugins_array =
  $Plugins->get_trigger_event("tinymce_extend_plugins",
    array("tinymce_plugins" => $tmce_plugins_array),
      "tinymce_plugins");
```

The plugins list is modified on the Gallery2 plugin side by adding an
implementation of the event hook. In this case the `tinymce_plugins` key in the
$params array is a reference that can be modified and passed back to the
TinyMCE plugin.

```php
function tinymce_extend_plugins( &$params ) {
  array_push($params["tinymce_plugins"], "-g2image");
}
```

You can view the changes made in the checked in code
[here](http://evocms-plugins.svn.sourceforge.net/viewvc/evocms-plugins?view=rev&revision=714).
