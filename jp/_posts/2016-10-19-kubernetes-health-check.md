---
layout: post
title: "Kubernetesヘルスチェックの使い方"
date: 2016-10-19 11:00:00 +0000
permalink: /jp/kubernetes-health-check
blog: jp
tags: kubernetes
render_with_liquid: false
locale: ja
---

最近、Kubernetesのヘルスチェックについての質問をよく見ています。ここでヘルスチェックの種類の違いや、どう使うか説明してみます。

## Liveness Probe

Kubernetesのヘルスチェックは2種類があって、一つ目は`livenessProbe`と、2つ目は`readinessProbe`というやつです。`livenessProbe`の役目はアプリケーションが生きてるかどうかをチェックすること。普段、エラーが起きた時に、アプリがクラッシュで終了して、Kubernetesがそれを見て、再起動してくれるんですけど、`livenessProbe`はアプリが終了せずに動かなくなったり、デッドロックしたりする場合にもアプリを再起動して直すために存在する。アプリがちゃんと動いているだけをチェックしているので、単純にHTTPレスポンスを返せばいいはず。

簡単な例として、以下はGoアプリの`livenessProbe`の実装。

```go
http.HandleFunc("/healthz", func(w http.ResponseWriter, r *http.Request) {
  w.Write([]byte("OK"))
}
http.ListenAndServe(":8080", nil)
```

`Deployment`のほうはこんな感じ

```yaml
livenessProbe:
    # an http probe
    httpGet:
        path: /healthz
        port: 8080
    initialDelaySeconds: 15
    timeoutSeconds: 1
```

この`livenessProbe`はアプリケーションが生きているだけをチェックします。`initialDelaySeconds`はアプリを起動してから、何秒後にヘルスチェックを始めるかを示している。例えば、起動するまで時間かかるようなアプリケーションだとこの設定を指定すると便利。`timeoutSeconds`はヘルスチェックのレスポンスを何秒待つかを示す。`livenessProbe`の場合はこれをできるだけ短くしたほうが早く検知するので復活が速い。でも、注意すべき点があって、負荷がかかっている状態でも適切なタイムアウトを設定しないと、一番忙しい時なのにアプリが再起動されてしまったり、パフォーマンスに影響がでる。なので、適切な`timeoutSeconds`を指定するのが大事。

アプリケーションの`livenessProbe`に接続できなかったり、HTTPエラーコードが返ってきた場合、Kubernetesはコンテナを素早く再起動しますし、アプリケーションの障害の可能性になるので、`livenessProbe`では複雑な処理などをしないほうが良い。

## Readiness Probe

`readinesProbe`は`livelinessProbe`と似ているものだけど、`readinessProbe`が失敗した結果が違います。`readinessProbe`はアプリケーションが生きているかどうかじゃなくて、トラフィックを受けられるかどうかを確認するためのヘルスチェック。`livelinessProbe`とは微妙に違います。例えば、アプリケーションがデータベースや、memcachedに依存している場合、この二つのサービスが動いていて、接続もできて、さらにアプリケーションも大丈夫な状態じゃないとトラフィックを受けられない。

`readinessProbe`が失敗した場合、そのパッドがサービスのエンドポイントから外される。そうすると、Kubernetesのサービスディスカバリー機能でトラフィックを受けられないポッドにトラフィックを転送しない。例えば、ローリングアップデートの時や、スケールアップした時、新しいポッドが機能されていたんだけど、まだトラフィック受けられないタイミングでリクエストが来たら、困るので、`readinessProbe`でそういうことを防ぐ。

`readinessProbe`の書き方は`livenessProbe`と同じ。`Deployment`の中に書く:

```yaml
readinessProbe:
    # an http probe
    httpGet:
        path: /readiness
        port: 8080
    initialDelaySeconds: 20
    timeoutSeconds: 5
```

`readinesProbe`の実装では、アプリケーションの依存サービスに接続できるかどうかをチェックする。一つの例として、データベースとmemcachedに依存するアプリケーションの`readinessProbe`を実装する。

以下のハンドラーのような感じになります。ここでは memcachedへ書き込みができるかどうか、かつ、データベースへの接続ができるかどうかをチェックします。どっちかがダメな場合は503を返す。

```go
http.HandleFunc("/readiness", func(w http.ResponseWriter, r *http.Request) {
  ok := true
  errMsg = ""

  // Check memcache
  if mc != nil {
    err := mc.Set(&memcache.Item{Key: "healthz", Value: []byte("test")})
  }
  if mc == nil || err != nil {
    ok = false
    errMsg += "Memcached not ok.¥n"
  }

  // Check database
  if db != nil {
    _, err := db.Query("SELECT 1;")
  }
  if db == nil || err != nil {
    ok = false
    errMsg += "Database not ok.¥n"
  }

  if ok {
    w.Write([]byte("OK"))
  } else {
    // Send 503
    http.Error(w, errMsg, http.StatusServiceUnavailable)
  }
})
http.ListenAndServe(":8080", nil)
```

## より安定性のあるアプリケーション

`livenessProbe`と`readinessProbe`はどっちもアプリケーションの安定性に助かる機能。トラフィックを受けられるコンテナだけにトラフィックを転送しないようにしてくれるし、クラッシュしたコンテナや、固まったコンテナを再起動してくれるし、非常に便利。そして、私の同僚のKelsey Hightowerが解説した [12 Fractured Apps](https://medium.com/@kelseyhightower/12-fractured-apps-1080c73d481c)の解決策でもある。ヘルスチェックがあれば、依存するサービスの起動を待ったりする複雑なEntrypointスクリプトはいらない。トラフィックを受けられる時だけ受けるし、ローリングアップデートやスケールアップがスムーズに動きます。
