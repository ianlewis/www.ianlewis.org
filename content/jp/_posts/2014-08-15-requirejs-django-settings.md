---
layout: post
title: "require.js + Django 設定の組み合わせ"
date: 2014-08-15 11:00:00 +0000
permalink: /jp/requirejs-django-settings
blog: jp
tags: django javascript python programming tech
render_with_liquid: false
locale: ja
---

JavaScriptをよく書いている場合、普通のアプリケーションと同じように設定を
書きたい場合があると思う。たとえば、開発の場合によく `DEBUG` フラグとか設定するよね？
たとえば、 Djangoを使っている場合、 `settings.DEBUG` が `True` と時に、JavaScriptにも
`console.log()` でデバグメッセージの流したりしたい場合がよくあると思う。

だけど、JavaScriptは静的ファイルなので、どうやって、DEBUGを設定するんだ？

それで、 `require.js` を使って入れば、便利な `config()` 機能がある。その機能を使えば、
モジュールの設定を書けるようになる。

Djangoの設定はこんな感じで、JavaScriptに渡せる。

```html
<script src="{{ STATIC_URL }}js/require.js"></script>
<script>
    require.config({
        // require.js の i18n プラグインにも便利！！！
        locale: '{{ LANGUAGE_CODE }}',
        config: {
            settings: {
                {% if debug %}DEBUG: true,{% endif %}
                MEDIA_URL: "{{ MEDIA_URL|escapejs }}",
                STATIC_URL: "{{ STATIC_URL|escapejs }}",
            }
        }
    });
</script>
```

そうすると、JavaScriptの `settings` モジュールで、 `module` という特別なモジュールを
`require`する。

```javascript
define(["module", "jquery"], function (module, $) {
    // underscore.js の extend() でもいい
    return $.extend(
        {
            // Default settings
            DEBUG: false,
            MEDIA_URL: "/media/",
            STATIC_URL: "/static/",

            // Other settings
            SALES_TAX: 0.05,
        },
        module.config(),
    );
});
```

これで、Djangoの`settings`モジュールと同じようにRequireJSで`settings`をインポートできる。

```javascript
define(["jquery", "settings"], function ($, settings) {
    $("#salestax").html(
        '<img src="' +
            settings.STATIC_URL +
            'img/money.gif"> ' +
            String(settings.SALES_TAX),
    );

    if (settings.DEBUG) {
        console.log("[DEBUG] Set sales tax.");
    }

    // etc.
});
```

もちろん、Django じゃなくても、Ruby on Rails や、Pyramid で同じ仕組みを使えるはず。
