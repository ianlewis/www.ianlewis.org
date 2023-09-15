---
layout: post
title: "ipython と virtualenv を同時に使う方法"
date: 2010-05-08 10:26:32 +0000
permalink: /jp/ipython-virtualenv
blog: jp
render_with_liquid: false
---

# 概要

python の皆さんはみんな使っている ipython は virtualenv を使う時に virtualenv
に入っているモジュールをインポートできないことが起こります。 ipython は特に
virtualenv に対応していないわけです。 ipython をグローバルじゃなくて、virtualenv
毎にインストールすると解決できるのですけど、 ipython
を落とすのが重いし、PIP\_DOWNLOAD\_CACHE (
[pipを使うべきだぞ](/jp/virtualenv-pip-fabric) )
を使わない限り、絶対にイライラする。

# ipython と virtualenv を使う方法第一

ということで、第一方法は PIP\_DOWNLOAD\_CACHE を設定して、virtualenv
を作る時に、virtualenvwrapper (
[virtualenvwrapperも使うべきだぞ](/jp/virtualenv-pip-fabric) )
のフックを使って ipython を自動的にインストールする。自分の virtualenv ディレクトリ
(WORKON\_HOME) に `postmkvirtualenv`
というスクリプトを入れると、環境を作った後に実行してくれます。それで、作るときに、毎回
ipython 入れます。

自分の .bashrc かどこかで、 PIP\_DOWNLOAD\_CACHE
を設定する。これで、一回ダウンロードしたら、毎回ダウンロードしなくてもいい。

``` text
PIP_DOWNLOAD_CACHE=~/.pip_cache
```

それから、$WORKON\_HOME/postmkvirtualenv にこう書きます。

``` text
# virtualenv毎に pip をインストールする場合
#easy_install pip

pip install ipython

# pudb も便利かもよ
#pip install pudb
```

それで、mkvirtualenv naninani を実行するときに virtualenv をちゃんと使う ipython
をインストールしてくれます。

# ipython と virtualenv を使う方法第二

ipython はpython
で書くユーザ設定ファイル機能があります。それを使えば、PYTHONPATHをいじれたりすることができるので、それで
virtualenv を使うこともできます。 ユーザ設定は `~/.ipython/ipy_user_conf.py` に入っています。

こう書きます。

``` python
# Most of your config files and extensions will probably start with this import
import os

import IPython.ipapi
ip = IPython.ipapi.get()

# You probably want to uncomment this if you did %upgrade -nolegacy
# import ipy_defaults    

def main():
    # Handy tab-completers for %cd, %run, import etc.
    # Try commenting this out if you have completion problems/slowness
    # import ipy_stock_completers

    # uncomment if you want to get ipython -p sh behaviour
    # without having to use command line switches

    # import ipy_profile_sh


    o = ip.options
    # An example on how to set options
    #o.autocall = 1
    o.system_verbose = 0

    import_all("os sys")
    execf('~/.ipython/virtualenv.py')

# some config helper functions you can use 
def import_all(modules):
    """ Usage: import_all("os sys") """ 
    for m in modules.split():
        ip.ex("from %s import *" % m)

def execf(fname):
    """ Execute a file in user namespace """
    ip.ex('execfile("%s")' % os.path.expanduser(fname))

main()
```

main() の中、 `virtualenv.py` という設定ファイルを呼び出す。 `virtualenv.py`
というファイルはこう書きます。

``` python
import site
from os import environ
from os.path import join
from sys import version_info

if 'VIRTUAL_ENV' in environ:
    virtual_env = join(environ.get('VIRTUAL_ENV'),
                       'lib',
                       'python%d.%d' % version_info[:2],
                       'site-packages')
    site.addsitedir(virtual_env)
    print 'VIRTUAL_ENV ->', virtual_env
    del virtual_env
del site, environ, join, version_info
```

これで、 `VIRTUAL_ENV` という環境変数が設定してある場合、それを python のサイトディレクトリとして登録する。

これで、ipython を実行するときに こうなるはず。

``` text
土  5月 08 10:22:57
ian@macbook-ian:~$ workon django-hgwebproxy
(django-hgwebproxy)土  5月 08 10:23:15
ian@macbook-ian:~$ ipython
VIRTUAL_ENV -> /home/ian/.virtualenvs/django-hgwebproxy/lib/python2.6/site-packages
Python 2.6.4 (r264:75706, Dec  7 2009, 18:45:15) 
Type "copyright", "credits" or "license" for more information.

IPython 0.10 -- An enhanced Interactive Python.
?         -> Introduction and overview of IPython's features.
%quickref -> Quick reference.
help      -> Python's own help system.
object?   -> Details about 'object'. ?object also works, ?? prints more.

In [1]:
```

ここに、 `VIRTUAL_ENV ->
/home/ian/.virtualenvs/django-hgwebproxy/lib/python2.6/site-packages`
が出て、virtualenv を使っていることが確認できる。

それでは、それでは、
