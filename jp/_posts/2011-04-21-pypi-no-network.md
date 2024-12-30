---
layout: post
title: "PYPI を使わないでデプロイする方法"
date: 2011-04-21 09:37:34 +0000
permalink: /jp/pypi-no-network
blog: jp
tags: python pip pypi
render_with_liquid: false
---

<!-- textlint-disable rousseau -->

pip、buildout などを使うとデプロイする時に Python ライブラリの依存関係はややこしいことがあります。
普段はデプロイスクリプトで、 pip に requirements.txt
を指定して、もしくは、 buildoutを実行して、 依存ライブラリを落としてインストールしますが、
PYPI がダウンしている場合、環境によって、PYPIにアクセス 出来ない場合もありますので、デプロイが止まってしまって困ります。
PYPIはダウンしている時に pip は PYPI
のミラーを使うことができますが、ミラーに必要がパッケージバージョンが入っていない、
[ミラーの最後のIDのDNS](http://www.python.org/dev/peps/pep-0381/#how-a-client-can-use-pypi-and-its-mirrors)
が ちゃんと動いていないときに、 pip は当然ちゃんと動かない場合も。 bitbucket や、 github
からのリポジトリに依存している場合、
接続できなかったら、ミラーがないので、当然インストールできます。

**つもり、デプロイは外部サイトに依存していて、デプロイを邪魔する問題が出てくる可能性が高いです。**

ローカルで必要なライブラリは既にインストールしているので、それを使えばいいじゃん！と自然に思います。
実は、情報がなくて、あまり使われてないみたいですが、
pip はバンドルを作成する機能があります。バンドルは `requirements.txt` の依存ライブラリを zip に固めて、そして、
`install` コマンドで、バンドルから
ライブラリをインストールしてくれる機能です。つもり、バンドルさえあれば、PYPIにアクセスしたくても良い。

# やったぜ！ これを使おう

バンドルを作成するのが簡単:

```shell
pip bundle -r requirements.txt mybundle.pybundle
```

インストールも簡単:

```shell
pip install mybundle.pybundle
```

もちろん、 [virtualenv](/jp/virtualenv-pip-fabric) と組み合わせて使えます。

**注意：** ファイルの拡張子は pybundle じゃないと install コマンドがバンドルを認識してくれない

バンドルは単の zip ファイル:

```shell
$ unzip mybundle.pybundle
...
$ ls
build/  pip-manifest.txt  mybundle.pybundle  src/
$ cat pip-manifest.txt
# This is a pip bundle file, that contains many source packages
# that can be installed as a group.  You can install this like:
#     pip this_file.zip
# The rest of the file contains a list of all the packages included:
# These packages were installed to satisfy the above requirements:
Django==1.3
django-debug-toolbar==0.8.4
South==0.7.3
...
```

# デプロイ

デプロイは Fabric を使います。ローカルで、バンドルを一回作っておけば、依存ライブラリを修正しない限り、 そのまま使えます。

まずは、 バンドルを作成するコマンドを作る。 `runs_once()` デコレータで一回しか実行しないようにします。 `local()`
メソッドでローカルコマンドを叩きます。

```python
from fabric.decorators import runs_once
from fabric.api import local

@runs_once
def create_bundle():
    u""" 依存ライブラリのバンドルを作り直す """
    local('pip bundle mybundle.pybundle -r requirements.txt')
    print 'Created bundle mybundle.pybundle'
```

次は、コード自体をアップするコマンドを作ります。下記は、 mercurial を ssh で push しています。

```python
from fabric.api import sudo, cd, local

def _hg_pull():
    local("hg push -r %(revision)s ssh://%(host_string)s/%(base_path)s" % env

def _hg_update():
    with cd(env.base_path):
        sudo("hg update -C -r %(revision)s" % env, user=env.deploy_user)

def push():
    u""" 最新バージョンに更新 """
    _hg_pull(rev)
    _hg_update(rev)
```

次は依存関係の更新

```python
import os
from fabric.api import sudo, cd, put, local

def update_deps():
    if not os.path.exists('mybundle.pybundle'):
        create_bundle()
    put('mybundle.pybundle', '%(base_path)s/mybundle.pybundle' % env, use_sudo=True)
    with cd(env.base_path):
        sudo('chown %(deploy_user)s:%(deploy_user)s mybundle.pybundle' % env)
        sudo('pip install -E %(venv_path)s mybundle.pybundle' % env)
```

mercurial の代わりに rsync を使う場合はこんな感じで、一発でできる。

```python
from fabric.contrib.project import rsync_project

RSYNC_EXCLUDE=[".hg"]

def push():
    if not os.path.exists('mybundle.pybundle'):
        create_bundle()
    rsync_project(
        env.base_path,
        exclude=RSYNC_EXCLUDE,
        delete=True,
    )
    with cd(env.base_path):
        sudo('chown %(deploy_user)s:%(deploy_user)s mybundle.pybundle' % env)
        sudo('pip install -E %(venv_path)s mybundle.pybundle' % env)
```

最後は、deploy コマンドを作る

```python
def deploy():
    push()
    update_deps()

    # DB を更新
    migrate_db()

    # ウェブサーバーを再起動
    reboot_server()
```

こういう感じで、ローカルとサーバーの接続さえできれば、デプロイできます。 外部サイトに依存したいのが楽過ぎて、逆にいい意味で困ります。

<!-- textlint-enable rousseau -->
