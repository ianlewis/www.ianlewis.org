---
layout: post
title: "bpssl のDjango SSL対応アプリをリリースしました"
date: 2010-11-09 11:09:23 +0000
permalink: /jp/bpssl-django-ssl
blog: jp
tags: python django ssl
render_with_liquid: false
---

今日、 bpssl をリリースしました。bpsslは [BeProud](http://www.beproud.jp/) で欲使っている
Django用のSSL対応アプリです。 アクセスする時にHTTPSが必須なURLを指定することがよくありますよね？ 例えば、
ログイン画面をHTTPSでしかアクセスできないようにする。ただし、 HTTPでアクセスした場合、
HTTPSのほうのURLにリダイレクトしたいこともよくあります。 bpssl はその対応を簡単にできるようなアプリです。

ウェブサーバーで対応することもありますが、設定変更も面倒だし、アプリケーション
ロジックをラップしたいことが多いので、アプリケーションレベルで対応します。

# 使い方は結構簡単

まずは、ポッケージを PIP でインストールします:

    $ pip install bpssl

もしくは `easy_install` で:

    $ easy_install bpssl

次に、 `'beproud.django.ssl'` を `settings.py` の
[INSTALLED_APPS](http://djangoproject.jp/doc/ja/1.0/ref/settings.html#installed-apps)
に追加してください。

```python
INSTALLED_APPS = (
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.sites',
    'django.contrib.messages',
    #...
    'beproud.django.ssl',
    #...
)
```

それから、
'[beproud.django.ssl.middleware.SSLRedirectMiddleware](http://beproud.bitbucket.org/bpssl-1.0/ja/usage.html#beproud.django.ssl.middleware.SSLRedirectMiddleware)'
を
[MIDDLEWARE_CLASSES](http://djangoproject.jp/doc/ja/1.0/ref/settings.html#setting-MIDDLEWARE_CLASSES)
に追加してください。

```python
MIDDLEWARE_CLASSES = (
    'django.middleware.common.CommonMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    #...
    'beproud.django.ssl.middleware.SSLRedirectMiddleware',
    #...
)
```

次は
[SSL_URLS](http://beproud.bitbucket.org/bpssl-1.0/ja/settings.html#setting-ssl-urls)
の正規表現んを設定する。

```python
SSL_URLS = (
    '^/login/',
    '^/purchase/'
    # ...
)
```

[ssl_view()](http://beproud.bitbucket.org/bpssl-1.0/ja/usage.html#beproud.django.ssl.decorators.ssl_view)
というビューデコレータもありますので、ビューレベルでもSSL対応ができます。

Django 側はこれで以上ですが、やっぱりウェブサーバーでの設定も必要ですが、それも簡単です。

もともと、bpssl は <http://www.djangosnippets.org> に投稿したSSLミドルウエアから、
インスピレーションを得た。以下のスニペットの機能にほぼ対応しています。

- <http://djangosnippets.org/snippets/880/>
- <http://djangosnippets.org/snippets/240/>
- <http://djangosnippets.org/snippets/1999/>

詳しくは [bpssl のドキュメント](http://beproud.bitbucket.org/bpssl-1.0/ja/) もしくは、
[ソースコード](http://bitbucket.org/beproud/bpssl/) を見ててください！
