---
layout: post
title: "Python の JSONライブラリのパフォーマンステスト"
date: 2011-03-23 11:03:23 +0000
permalink: /jp/python-json-library-perf-test
blog: jp
tags: python json jsonlib jsonlib2 simplejson
render_with_liquid: false
locale: ja
---

## 概要

最近、あるお客さんから、 快速なので、 [cjson](http://pypi.python.org/pypi/python-cjson/)
を使おうという要望をいただきましたが、 以前、僕は cjson
は色なエッジケースの処理が微妙と分かっていて、実際に他のライブラリより早いのかなと思いました。
[cjsonのPyPiページ](http://pypi.python.org/pypi/python-cjson/)
いろなコメントが書かれています。しかも、 最新パージョンは 2007
リリースでかなり古い。バグがあるのに、直っていないし、あんまりメンテしてないライブラリに見える。

[simplejson](http://pypi.python.org/pypi/simplejson/) も
[jsonlib](http://pypi.python.org/pypi/jsonlib/) もCで拡張があり、
かなり最適化されていると思ったので、テストしてみようと思いました。

というわけで、パフォーマンステストを作って、bitbucket にアップしました

<https://bitbucket.org/IanLewis/jsonlib-test>

## 準備

buildout を使って、環境を作ります

```shell
python bootstrap.py --distribute
./bin/bootstrap
```

## テストを実行

`./bin/run_test` を実行します。オプションはいくつかあります。

1. `-c`, `--concurrency`: プロセス数。
   これは、少なくとも、プロダクション環境になるべく近いようにするには、コアの台数にするのがおすすめです。デフォールトは
   1プロセス
2. `-l`, `--loops`: テストのループ回数。最終的に、ループ毎の秒間のオペレーション数の平均を取ります。デフォールトは 10回
3. `-i`, `--iterations`: 1つのループのオペレーション回数。 デフォールトは 100回
4. `-f`, `--file`: テストJSONファイル。デフォールトはリポジトリ内の `schema.json`

## テスト結果

ローカルの MacBook Pro に動かしました。

```shell
$ ./bin/run_test -c 2 -i 500
Running 10 loops with 500 iterations with 2 processes
Python 2.6.5 (r265:79063, Apr 16 2010, 13:09:56)
[GCC 4.4.3]

encode
========================================

simplejson:       3175.44574 /s
jsonlib2:         2925.55263 /s
cjson:            2901.22826 /s
jsonlib:          2860.49601 /s
json:             1489.21863 /s
demjson:           250.03410 /s

decode
========================================

simplejson:       3224.92945 /s
jsonlib2:         2980.32737 /s
cjson:            2940.61543 /s
jsonlib:          2847.47568 /s
json:              673.22381 /s
demjson:           145.67908 /s
```

## まとめ

cjson はやはり早いのですが、現代の simplejson と jsonlib2 は cjson
より早くなっています。あんまり差が出ないけど、
メンテされていないし、 パーフォマンスのため、わざわざ cjson を選ぶメリットは特にないと思います。

Pythonの世界で、 Cを名前に付けているライブラリが早いとイメージですが、他のライブラリより必ずしも早いというわけではない。

ちなみに、Python 2.6+ に入っている json ライブラリは simplejson
ではありますが、古いバージョンになっているし、必ずC拡張がコンパイルされているわけではないので、simplejsonの最新版を使うのがおすすめです。
