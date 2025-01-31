---
layout: post
title: "virtualenv, virtualenvwrapper, pip を使う方法"
date: 2009-07-12 10:47:17 +0000
permalink: /jp/virtualenv-pip-fabric
blog: jp
tags: python pip virtualenv virtualenvwrapper 仮想化
render_with_liquid: false
locale: ja
---

あるプロジェクトの依存は特定なバージョンじゃないとダメな場合が結構多いと思いますけど、最近、pythonの仮想環境を簡単に作れるようになりました。virtualenv
と virtualenvwrapper と pip の組み合わせを紹介します。

virtualenvは環境を作ってくれるライブラリで、virtualenvwrapperはその作った環境を簡単に管理してくれるツールになります。

# まず、virtualenv と virtualenvwrapper をインストール

```text
easy_install virtualenv
easy_install virtualenvwrapper
```

これで、virtualenvwrapperのコマンドを使うには、bashスクリプトを設定しないといけない。以下の行を `.bashrc` に追加

```bash
export WORKON_HOME=$HOME/.virtualenvs
source /usr/local/bin/virtualenvwrapper_bashrc
```

<div class="note">

<div class="title">

Note

</div>

**Update**: virtualenvwrapper 2.0+ の場合ですと、Bash 意外の端末シェルにも対応しているので、
`virtualenvwrapper_bashrc` は `virtualenvwrapper.sh` にかわりました。 `PATH`
には入るので、

```bash
export WORKON_HOME=$HOME/.virtualenvs
source `which virtualenvwrapper.sh`
```

を `.bashrc` に追加してください。

</div>

コンソールを再起動して終わり。仮想環境を作りましょう。

```text
mkvirtualenv myproj
```

これで、プロジェクトの仮想環境ができました。
これで、pythonのバージョンも確定し、仮想環境にインストールするライブラリのバージョンも確定になる。mkvirtualenvを実行すると、作った環境に入る。また、次に使う時は
workon myproj を実行して、環境に入る。

しかし、よく使われてるeasy_install は virtualenv
と連携できなくて、どうしても、システムのpythonディレクトリにパッケージをインストールしてしまう。

# pip が助かる

easy_install　が簡単すぎて、分けわかんないメッセージも出したりして、virtualenvと相性悪くて、何とかできませんか？って話があったきかっけ、pipが生まれた。pipをインストールすればvirtualenvにすいすいとパッケージをインストールできる。virtualenvを使っている間にインストールする。

```text
wget http://pypi.python.org/packages/source/p/pip/pip-0.4.tar.gz
tar xzf pip-0.4.tar.gz
cd pip-0.4
python setup.py install
```

<div class="note">

<div class="title">

Note

</div>

**Update**: pipはちゃんと、virtualenvに入ってくれるので、easy_install でもインストールできる。

```text
workon myproject
easy_install pip
```

</div>

<div class="note">

<div class="title">

Note

</div>

**Update**: pip をグローバルにインストールしたい場合は、環境変数 PIP_RESPECT_VIRTUALENV
を設定すると、今使っている virtualenv を pip も使ってくれる。

```text
export PIP_RESPECT_VIRTUALENV=true
```

</div>

pip -E でも、virtualenvの環境パスを指定できます。

```text
pip -E /path/to/my/virtualenv install mymod
```

これで、pip が仮想環境にインストールする。これから、pip install
で仮想環境にパッケージをインストールできるようになった。それで、プロジェクトに必要なパッケージをインストールし、pythonのsite-packagesが汚くならないので、安心
