---
layout: post
title: "(より)小さいDockerイメージを作ろう"
date: 2015-11-27 14:30:00 +0000
permalink: /jp/small-docker-images
blog: jp
render_with_liquid: false
---

最近、コンテナ技術が流行っていていろなツールを興味深く触っている。その中の一番人気のはみんな大好きなDocker。Dockerは docker
runでコンテナの実行環境を簡単に作ってくれる上、docker build でコンテナのイメージの構築も簡単にできる。Dockerのイメージ構築はDockerfileというMakefileのようなファイルを元にその中のコマンドを順番に実行して構築していくもの。

例えば、

```docker
FROM debian:jessie

RUN apt-get update
RUN apt-get install -y python
RUN mkdir -p /data

VOLUME ["/data"]

WORKDIR /data

EXPOSE 8000

CMD [ "python", "-m", "SimpleHTTPServer", "8000" ]
```

これは非常にシンプルなDockerイメージなんですが、実際にビルドして、イメージのサイズを見てみると：

```
VIRTUAL SIZE
167.4 MB
```

シンプルなアプリだったのに、結構大きいんだね。

## なんで大きいんだ？

上のDockerfileの1行目は `FROM debian:jessie` って書いているんだけど、イメージが大きくなっているのは、Debian 8.x がまるまるイメージに入るわけです。さらに、Dockerfileの中に何かをgccやg++をビルドする必要があれば、アプリを実行するのに必要ないのに、ビルドするたにツールやライブラリがイメージに入っていて、結構な量になる。

じゃ、例えばredisのイメージを作る場合はこうするのが一番わかりやすくて概念的にいいんだが

```docker
FROM debian:jessie

RUN apt-get update
RUN apt-get install -y gcc libc6-dev make
RUN curl -sSL "http://download.redis.io/releases/redis-3.0.5.tar.gz" -o
redis.tar.gz
RUN mkdir -p /usr/src/redis
RUN tar -xzf redis.tar.gz -C /usr/src/redis
RUN make -C /usr/src/redis
RUN make -C /usr/src/redis install

# 全部削除
RUN rm -f redis.tar.gz
RUN rm -f /usr/src/redis
RUN apt-get purge -y --auto-remove gcc libc6-dev make

...

```

Dockerは RUNコマンドを実行するたびに、イメージの「レイヤー」を保存して、その状態をイメージにキャッシュする。最後に削除しても、途中でレイヤーにコミットしちゃっているから、結局イメージのサイズがそのまま大きくなる

## どうやって小さくするのか

結局 RUN を実行するたびにコミットするので、全部１個のRUNコマンドで実行しなければならない。

以下、は[実際のredisのDockerfile](https://github.com/docker-library/redis/blob/8929846148513a1e35e4212003965758112f8b55/3.0/Dockerfile) ([Docker BSD LICENSE](https://github.com/docker-library/redis/blob/8929846148513a1e35e4212003965758112f8b55/LICENSE))からとったスニペット

```docker
ENV REDIS_VERSION 3.0.5
ENV REDIS_DOWNLOAD_URL http://download.redis.io/releases/redis-3.0.5.tar.gz
ENV REDIS_DOWNLOAD_SHA1 ad3ee178c42bfcfd310c72bbddffbbe35db9b4a6

# for redis-sentinel see: http://redis.io/topics/sentinel
RUN buildDeps='gcc libc6-dev make' \
	&& set -x \
	&& apt-get update && apt-get install -y $buildDeps --no-install-recommends \
	&& rm -rf /var/lib/apt/lists/* \
	&& mkdir -p /usr/src/redis \
	&& curl -sSL "$REDIS_DOWNLOAD_URL" -o redis.tar.gz \
	&& echo "$REDIS_DOWNLOAD_SHA1 *redis.tar.gz" | sha1sum -c - \
	&& tar -xzf redis.tar.gz -C /usr/src/redis --strip-components=1 \
	&& rm redis.tar.gz \
	&& make -C /usr/src/redis \
	&& make -C /usr/src/redis install \
	&& rm -r /usr/src/redis \
	&& apt-get purge -y --auto-remove $buildDeps
```

これでビルド用のライブラリのインステール、ビルド、片付け、全部一個のRUNコマンドでやる。こうするとイメージが大きくならない。

## 依存関係の地獄

Dockerイメージが大抵DebianやUbuntuのイメージから継承して、大きくなっているのは、アプリケーションをコンテナの中に実行すると、そのアプリの依存する動的にリンクするライブラリが全部入ってないと当然クラッシュするから。そうして、イメージを構築するときに、apt-get
などを使うのが便利。

[Googleではすべてのアプケーションがコンテナで動いている](https://speakerdeck.com/jbeda/containers-at-scale?slide=2)。コンテナのアプリを実行するために必要ないものがいっぱい入っているのが無駄なので、コンテナの外にスタティックバイナリにビルドして、そのバイナリと必要なファイルだけイメージに入れるのがGoogleのやり方。このやり方はイメージは小さくなって、依存ライブラリの管理は簡単なので、なかなか賢いと思う。これは Go がデフォールトでスタティックバイナリにコンパイルする理由のひとつ。
