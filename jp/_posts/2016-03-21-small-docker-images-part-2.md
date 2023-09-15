---
layout: post
title: "小さいDockerイメージを作ろう Part #2"
date: 2016-03-21 16:00:00 +0000
permalink: /jp/small-docker-images-part-2
blog: jp
render_with_liquid: false
---

この記事は小さいDockerイメージの作成について第２版目の記事。[前回の記事](/jp/small-docker-images)で小さいDockerイメージの作り方について書きましたが、その方法を使った場合、どのくらい小さくできるかは限られている。イメージに追加するレイヤーを小さくする方法を使ったんですが、その方法が使えない場合がある。Dockerfileを実行するコマンドを特定な順番で実行しなければならない場合はどうすることもできない。例えば、ある中間ステップでファイルを追加しなければならない場合：

```docker
RUN ...
ADD some_file /
RUN ...
```

最初のRUNコマンドで何かの処理をしてから、ファイルを追加して、2番目のRUNコマンドでまた処理が必要な場合は、Dockerは一行一行にイメージのレイヤーを作ってしまう。

大きいイメージを継承する場合も、イメージを小さくすることができない。イメージを継承しているので、この場合でもその大きいイメージレイヤーはもう作らてしまっているので、Dockerではイメージを小さくすることができない。

```docker
FROM large-image

RUN ...
```

## Docker Squash

Docker単体では、Dockerfileのコマンドとイメージレイヤーの作成を切り離すことができない設計になっている。普段、この設計は大丈夫だけど、必要より大きなイメージができてしまう場合がある。レイヤーの数を減らすのとレイヤーの大きさを小さくするには、Dockerイメージのレイヤーを[gitのコミットと同じように圧縮する](http://www.backlog.jp/git-guide/stepup/stepup7_5.html)かっこいいツール[docker-squash](https://github.com/jwilder/docker-squash)がある。

![Vise](https://storage.googleapis.com/static.ianlewis.org/prod/img/748/vise.jpg)

*[Creative Commons Attribution](https://creativecommons.org/licenses/by/2.0/) by [Communications Mann](https://www.flickr.com/photos/spenceannaaug18/7069654045/in/photolist-bLHPQZ-aF3qHd-aEq79z-8yQzQt-5jDvQ8-aEYmdF-aEx66j-5EZwFg-dSBZFb-2Ypqdi-5Uw2gF-3b1dmA-3aVF7M-dZF1V5-a55maH-6tXnaY-qAJkzw-bEVr7X-e4dngq-2ystn-eA1PU6-aFMxwn-9YReBh-4jkvuR-efUaTT-dZEXQU-dZFrq5-f4AToE-ngJPnE-7Hc1gx-bDaK7t-dnGexK-d9J17o-kwCjdU-snrBcV-dg7aAX-tTDMUC-7NFwDp-iYLYD7-tTMWt6-cYuZob-64Tpi-ekJEBJ-dvB96q-7NFwRR-8H7DAm-8H7DzL-747sy4-bLjCEX-bxpW8E)*

docker-squashを使うと、イメージレイヤーを圧縮して、中間ステップでキャッシュされたデータを除外することができる。ちょっと使ってみよう

## Pythonイメージを圧縮してみよう

Docker Hubにある[python:2.7.11の標準イメージ](https://hub.docker.com/_/python/)を圧縮してみる。[Dockerfile](https://github.com/docker-library/python/blob/master/2.7/Dockerfile)を見てみると、継承しているイメージに入っていたpythonパッケージを削除してから、自前でPythonをダウンロードしてビルドしているのがわかる。でも、Pythonパッケージを削除しているのに、
レイヤーにすでに入っているから、イメージの容量に含まれている。他にいくつかのイメージを継承していて、それぞれのイメージはレイヤーを追加している。圧縮することでどのくらい小さくなるかみてみよう。

まずはローカルPCにpullする。

```console
$ docker pull python:2.7.11
2.7.11: Pulling from library/python
7a01cc5f27b1: Pull complete 
3842411e5c4c: Pull complete 
...
127e6c8b9452: Pull complete 
88690041a8a3: Pull complete 
Digest: sha256:590ee32a8cab49d2e7aaa92513e40a61abc46a81e5fdce678ea74e6d26e574b9
Status: Downloaded newer image for python:2.7.11
```

このイメージはたくさんのレイヤーがあって、容量は676MBくらいになっているのがすぐわかる。


```console
$ docker images python:2.7.11
REPOSITORY          TAG                 IMAGE ID            CREATED
VIRTUAL SIZE
python              2.7.11              88690041a8a3        2 weeks ago
676.1 MB
```

Dockerのローカルリポジトリに入っているイメージを圧縮することができないのが少し面倒くさいけど、`docker save`コマンドでイメージファイルを簡単にエクスポートできる。以下でファイルをエクスポートして、圧縮したイメージを作成する。


```console
$ docker save python:2.7.11 > python-2.7.11.tar
$ sudo bin/docker-squash -i python-2.7.11.tar -o python-squashed-2.7.11.tar
```

これで新しいファイルは75MBくらい小さくなっているのがわかる。


```console
~$ ls -lh python-*.tar
-rw-rw-r-- 1 ian  ian  666M Feb 15 16:32 python-2.7.11.tar
-rw-r--r-- 1 root root 590M Feb 15 16:33 python-squashed-2.7.11.tar
```

`docker load`でファイルをインポートしたら、小さくなっているのがわかる。


```console
$ cat python-squashed-2.7.11.tar | docker load
$ docker images python-squashed
REPOSITORY          TAG                 IMAGE ID            CREATED
VIRTUAL SIZE
python-squashed     latest              18d8ebf067fd        11 days ago
599.9 MB
```

## Virtual Size

上でDockerがイメージのVirtual Sizeを表示している。イメージの大きさは、「仮想サイズ」として表示しているのは Dockerがイメージレイヤーを再利用するので、このサイズは単に全てのレイヤーのサイズを合わせた数字になる。実際に利用される容量はそれより小さい場合がある。例えば、`debian:jessie`を継承するイメージが複数あると、`debian:jessie`の分は再利用される。[`git merge --squash`](http://www.backlog.jp/git-guide/stepup/stepup7_7.html)と同じように`docker-squash`はレイヤーを圧縮するとまったく新しいレイヤーが作成する。でも、へたにやってしまうと以前に再利用された分は再利用できなくなって、全体的に利用されるサイズが大きくなる。

![Docker Images](https://storage.googleapis.com/static.ianlewis.org/prod/img/749/images.svg)

`docker-squash`はこの問題を軽減するのに、あるレイヤーIDから圧縮して、そのレイヤーの親レイヤーを再利用する。デフォルトでは最初のFROMレイヤーから圧縮する。そのデフォルトだと、`debian:jessie`など、よく継承されるイメージを再利用できて、そのレイヤーの内容は毎回ダウンロードしなくてもいいけど、`-from`オプションを指定すると、指定したレイヤーIDから圧縮することができる。そうすると、例えば、社内用のベースイメージを再利用できる。

```console
$ docker-squash -from 18d8ebf067fd -i ... -o ...
```

Docker Squashは万能ではないけど、Docker利用者のツールの一つとしてかなり便利だと思います。[使ってみて](https://github.com/jwilder/docker-squash)、もし何かコメントや意見があれば、下にコメントや[Twitter](https://twitter.com/IanMLewis)で教えてください。これからの記事で、Dockerイメージを小さくするまた別の方法の話を書いてみますので、ぜひ期待してください。