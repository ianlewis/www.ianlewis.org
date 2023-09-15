---
layout: post
title: "Fabric デプロイツールのPythonicな書き方"
date: 2010-09-08 11:41:40 +0000
permalink: /jp/fabric-pythonic
blog: jp
render_with_liquid: false
---

Pythonで作られたデプロイ・自動化ツール [Fabric](http://www.fabfile.org/)
があります。デプロイスクリプトなどをPythonで書くことができます。最近、
Fabric で結構複雑なこともしたかったんですけど、 Fabric のAPIが結構
Python的で楽だったので、みんなに共有しようかなと思いました。

まず、 Fabric は fabfile.py という Python スクリプトを書く必要があります。 fab
コマンドを実行すると、現在のディレクトリに探して、このファイルをロードしてくれます。

Hello World 書きましょう

``` python
def hello():
    print("Hello world!")
```

``` text
$ fab hello
Hello world!
```

Fabric
は指定したコマンドを各ホストで実行する実行モデルです。この場合は特にホストの指定がなかったので、全部ローカルで、一回実行することになります。

これは結構つまんないので、本当の例を見ましょう。これは最近、仕事で作ったコマンドです。 nginx
サーバーでメンテ画面を出すようなコマンドです。
各ロードバランサーで実行します。

``` python
from fabric.api import run, cd, abort, require, sudo, env
from fabric.decorators import runs_once, roles
from fabric.contrib.console import confirm

...

@roles('loadbalancers')
def start_maintenance():
    """ メンテナンス画面に切り替える """
    _production_check()
    pull()
    with cd("/etc/nginx/sites-enabled"):
        sudo("rm -f %(lb_settings)s" % env)
        sudo("ln -s ../sites-available/%(lb_maintenance_settings)s" % env)
        sudo("/etc/init.d/nginx reload")

...
```

最初は動きは分からないと思うのですが、一個一個説明します。

# 環境辞書

`env` という環境辞書があります。 これで、どの環境で実行するかを設定することができます。
普段は環境を設定するコマンドを実装するのが多いです。

``` python
def production():
    """ 本番 """
    env.environment = "production"
    env.user = 'www-data'
    env.roledefs.update({
        'loadbalancers': ['lb'],
        'webservers': ['web'],
    })
    env.rev = 'default'
    env.app_path = '/var/www/example-prj'
    env.buildout_cfg = 'prod.cfg'
    env.lb_settings = 'example'
    env.lb_maintenance_settings = 'example-maintenance'
```

これで、以下のように `fab` を実行する。

``` text
$ fab production start_maintenance
```

# ホスト

ホスト設定は `env.hosts` でグローバルで設定することができます。 `hosts` というデコレータでも設定することができます。

``` python
def production():
    """ 本番 """
    env.hosts = ["host1", "host2"]

@hosts("host3", "host4")
def mycommand():
    # do something
```

コマンドにホスト設定がなかったら、グローバルの `env.hosts` を使います。

ロール(役）という設定もあります。 ロールというのは、サーバーの種類毎で設定します。 hosts と同じようにデコレータを使えます。

``` python
def production():
    """ 本番 """
    env.roledefs.update({
        'loadbalancers': ['lb'],
        'webservers': ['web'],
    })

@roles("webservers")
def mycommand():
    # do something
```

# サブコマンド

上のコマンドで、 `_production_check()` と `pull()` というコードがありますけど、これはサブコマンドになります。

``` python
@runs_once
def _production_check():
    if "prod" in env.environment:
        if not confirm('Is it ok to deploy to production?', default=False):
            abort('Production deploy cancelled.')

def _hg_pull(rev=None):
    if rev is None:
        rev = env.rev
    with cd(env.app_path):
        run("hg pull -r %s" % rev)

def _hg_update(rev=None):
    if rev is None:
        rev = env.rev
    with cd(env.app_path):
        run("hg update -C -r %s" % rev)

@roles('webservers', 'loadbalancers')
def pull(rev=None):
    u""" 最新バージョンに更新 """
    _production_check()
    _hg_pull(rev)
    _hg_update(rev)
```

`runs_once` デコレータは付けた関数が一回しか実行されないように指定しています。 `_production_check()`
で本番環境に反映してもいいかどうかをチェックする。 `pull` で本番環境のサーバーを更新する。

# コマンドを実行する

Fabric は３つのコマンドを実行する関数があります。

1.  local - ローカルで実行する。
2.  run - リモートホストで実行する
3.  sudo - sudo を使って他のユーザーでコマンドを実行する。

# with の素敵な書き方

Python 2.5 から入っている `with` 文を使って、あるディレクトリに入った状態でコマンドを実行する。ここで、nginx
の設定ファイルのシンボリックリンクを置き換えています。 環境設定コマンドで設定した `lb_settings`
などを使っています。

``` python
with cd("/etc/nginx/sites-enabled"):
    sudo("rm -f %(lb_settings)s" % env)
    sudo("ln -s ../sites-available/%(lb_maintenance_settings)s" % env)
    sudo("/etc/init.d/nginx reload")
```

Python 2.5 の場合、 future モジュールからインポートする必要があります。

``` python
from __future__ import with_statement 
```

この with の書き方で、Python的でかなり好きです。
