---
layout: post
title: "Google Appengine フレームワーク Tipfy の紹介"
date: 2010-12-24 13:27:15 +0000
permalink: /jp/google-appengine-framework-tipfy
blog: jp
tags: python google appengine tipfy
render_with_liquid: false
locale: ja
---

> この記事は[Python Webフレームワークアドベントカレンダー2010](http://atnd.org/events/10465)のために書いた12/24の記事です。他の記事を読むには <http://atnd.org/events/10465> をご覧ください

私は普段、[kay フレームワーク](http://code.google.com/p/kay-framework/)を使いますが、最近、[Tipfy](http://www.tipfy.org/) (<http://www.tipfy.org>)というフレームワークを試してみました。TipfyはKayと同じく、Google Appengine専用フレームワークです。Kayは[Django](http://www.djangoproject.com)に似ているものの、TipfyはAppengine SDKの[Webapp フレームワーク](http://code.google.com/intl/ja/appengine/docs/python/gettingstarted/usingwebapp.html)に似ているように作りました。

## インストール

Tipfyは[buildout](http://www.buildout.org/)という環境管理ツールの利用を推進しています。

まずは、[Tipfy の配布プロジェクトテンプレート](http://www.tipfy.org/tipfy.zip)をダウンロードします。

```shell
wget http://www.tipfy.org/tipfy.zip
unzip tipfy.zip
```

次に、buildoutで環境を構築。buildoutはAppengine SDKと依存ライブラリをすべて、[pypi](http://pypi.python.org/)から落としてくれます。

```shell
cd project
python2.5 bootstrap.py --distribute
./bin/buildout
```

それから、dev_appserverや、appcfgのスクリプトファイルが`bin`ディレクトリに入っています。開発サーバーを起動するには、`./bin/dev_appserver`を実行します。

```shell
./bin/dev_appserver
```

## ディレクトリ構造

この時点でファイルディレクトリ構造が出来ているはず。

```text
app/ - GAE アプリ
    apps/ - アプリケーションモジュール
        hello_world - デフォールト Hello World アプリケーション
    lib/ - 第三者ライブラリ
    distlib/ - buildout が入れたライブラリ (buildout を実行する度、クリアされる)
    locale/ - 翻訳ファイル
    static/ - 静的ファイル
    templates/ - HTMLテンプレートなど
    main.py - メインアプリ入り口 (main())
    app.yaml - GAE アプリの app.yaml
    config.py - アプリの設定ファイル
    urls.py - アプリのURLルーティング
eggs/ - buildout が作った開発用ライブラリファイル
etc/ - 設定ファイル
    develop-eggs - 開発用ライブラリ
    downloads - ダウンロードキャッシュ
    parts - buildout の開発用ファイル
bootstrap.py - buildout のブットストラップスクリプト
buildout.cfg - buildout の設定ファイル
babel.cfg - 翻訳システムの設定ファイル
gaetools.cfg - gae SDK に関するの設定
versions.cfg - バージョン管理ファイル (デフォールトは空)
```

## 設定

設定は`app/config.py`に入っています。設定は`config`という辞書オブジェクトに定義します。

第三者モジュールの設定はモジュール名のキーで設定します。以下で`tipfy.ext.session`のセッション対応モジュールの設定をします。

`apps_installed`はアプリケーションモジュールの設定です。アプリモジュールで定義したURLを自動で登録します。

```python
# Configurations for the 'tipfy' module.
config['tipfy'] = {
    # Enable debugger. It will be loaded only in development.
    'middleware': [
        'tipfy.ext.debugger.DebuggerMiddleware',
    ],
    # Enable the Hello, World! app example.
    'apps_installed': [
        'apps.hello_world',
    ],
}
config['tipfy.ext.session'] = {
    'secret_key': '<Secret Key>',
}
```

## URLルーティング

URLルーティングは`urls.py`の`make_rules()`関数で定義します。

`app/apps/hello_world/urls.py`を見るとこんな感じです。

```python
from tipfy import Rule

def get_rules(app):
    """Returns a list of URL rules for the Hello, World! application.

    :param app:
        The WSGI application instance.
    :return:
        A list of class:`tipfy.Rule` instances.
    """
    rules = [
        Rule('/', endpoint='hello-world', handler='apps.hello_world.handlers.HelloWorldHandler'),
        Rule('/pretty', endpoint='hello-world-pretty', handler='apps.hello_world.handlers.PrettyHelloWorldHandler'),
    ]

    return rules
```

## リクエストハンドラー

リクエストハンドラーでアプリケーションのロジックを実装します。TipfyはJinja2のテンプレートレンダリングエンジンをデフォルトで使います。

```python
from tipfy import RequestHandler, Response
from tipfy.ext.jinja2 import render_response

class HelloWorldHandler(RequestHandler):
    def get(self):
        """Simply returns a rendered template with an enigmatic salutation."""
        return render_response('hello_world.html', message='Hello, World!')
```

## ハンドラー Mixin の使い方

ハンドラーに機能を追加するには、ハンドラーMixinを使います。普段は、毎回ハンドラーに追加するのではなく、アプリケーション用のベースハンドラーで使う機能のMixinを追加する。例えば、ミドルウエアの設定、セッション処理とかがベースハンドラーで設定することができます。

```python
from tipfy import RequestHandler, Response
from tipfy.ext.jinja2 import Jinja2Mixin
from tipfy.ext.session import SecureCookieMixin, SessionMixin

class BaseHandler(RequestHandler, Jinja2Mixin, SecureCookieMixin, SessionMixin):
    middleware = ['tipfy.ext.session.SessionMiddleware']

class HelloWorldHandler(BaseHandler):
    def get(self):
        """Simply returns a rendered template with an enigmatic salutation."""
        return self.render_response('hello_world.html',
            message='Hello, World!',
            somevalue=self.session.get('somevalue')
        )
```

## 拡張モジュール

`tipfy.ext`というモジュールの中にいろな拡張モジュールがあります。`app/distlib/tipfy/ext`ディレクトリに入っています。メール受信ハンドラーとか、i18nとかのサポートモジュールが入っています。英語ドキュメントしかないのですが、以下のドキュメントに拡張の使い方について書いています。

1. [標準拡張のドキュメント](http://www.tipfy.org/wiki/extensions/#extension-pages)
2. [拡張をプロジェクトに追加](http://www.tipfy.org/wiki/guide/extensions/#adding-or-removing-extensions)
3. [拡張を作る方法](http://www.tipfy.org/wiki/guide/extensions/create/#creating-extensions)

## まとめ

TipfyはMixinの使い方ですとかがPythonの初心者に分かりにくいかもしれないけど、Webappに似ていて、コードのクオリティがかなり高いと思います。GAEプロジェクトは普通のPythonプロジェクトと違っていて、全てのコードがプロジェクトディレクトリの下に入っていないといけないから、拡張モジュールの配布に問題ありますが、Tipfyは`buildout`を使っていて、その問題を解決しているのがうまい使い方なと思いました。これから、Kayも同じように拡張を配布できるようにして、Tipfyのいいところを勉強していきたいと思っています。そして、Kayを気にいっていない開発者にTipfyを試してみるのがおすすめします。
