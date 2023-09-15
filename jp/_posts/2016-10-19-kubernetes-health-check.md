---
layout: post
title: "Kubernetesヘルスチェックの使い方"
date: 2016-10-19 11:00:00 +0000
permalink: /jp/kubernetes-health-check
blog: jp
---

[comment]: # (I've seen a lot of questions about Kubernetes health checks recently and how they should be used. I'll do my best to explain them and the difference between the types of health checks and how each will affect your application.)

最近、Kubernetesのヘルスチェックについての質問をよく見ています。ここでヘルスチェックの種類の違いや、どう使うか説明してみます。

## Liveness Probe

[comment]: # (Kubernetes health checks are divided into liveness and readiness probes. The purpose of liveness probes are to indicate that your application is running. Normally your app could just crash and Kubernetes will see that the app has terminated and restart it but the goal of liveness probes is to catch situations when an app has crashed or deadlocked without terminating. So a simple HTTP response should suffice here.)

Kubernetesのヘルスチェックは2種類があって、一つ目は`livenessProbe`と、2つ目は`readinessProbe`というやつです。`livenessProbe`の役目はアプリケーションが生きてるかどうかをチェックすること。普段、エラーが起きた時に、アプリがクラッシュで終了して、Kubernetesがそれを見て、再起動してくれるんですけど、`livenessProbe`はアプリが終了せずに動かなくなったり、デッドロックしたりする場合にもアプリを再起動して直すために存在する。アプリがちゃんと動いているだけをチェックしているので、単純にHTTPレスポンスを返せばいいはず。

[comment]: # (As a simple example here is a health check I often use for my Go applications.)

簡単な例として、以下はGoアプリの`livenessProbe`の実装。

```go
http.HandleFunc("/healthz", func(w http.ResponseWriter, r *http.Request) {
	w.Write([]byte("OK"))
}
http.ListenAndServe(":8080", nil)
```

[comment]: # (and in the deployment:)

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

[comment]: # (This just tells Kubernetes that the application is up and running. The `initialDelaySeconds` tells Kubernetes to delay starting the health checks for this number of seconds after it sees the pod is started. If your application takes a while to start up, you can play with this setting to help it out. The `timeoutSeconds` tells Kubernetes how long it should wait for responses for the health check. For liveness probes, this shouldn't be very long but you do want to give your app enough time to respond even in cases where it's under load.)

この`livenessProbe`はアプリケーションが生きているだけをチェックします。`initialDelaySeconds`はアプリを起動してから、何秒後にヘルスチェックを始めるかを示している。例えば、起動するまで時間かかるようなアプリケーションだとこの設定を指定すると便利。`timeoutSeconds`はヘルスチェックのレスポンスを何秒待つかを示す。`livenessProbe`の場合はこれをできるだけ短くしたほうが早く検知するので復活が速い。でも、注意すべき点があって、負荷がかかっている状態でも適切なタイムアウトを設定しないと、一番忙しい時なのにアプリが再起動されてしまったり、パフォーマンスに影響がでる。なので、適切な`timeoutSeconds`を指定するのが大事。

[comment]: # (If the app never starts up or responds with an HTTP error code then Kubernetes will restart the pod. You will want to do your best to not do anything too fancy in liveness probes since it could cause disruptions in your app if your liveness probes start failing.)

アプリケーションの`livenessProbe`に接続できなかったり、HTTPエラーコードが返ってきた場合、Kubernetesはコンテナを素早く再起動しますし、アプリケーションの障害の可能性になるので、`livenessProbe`では複雑な処理などをしないほうが良い。

## Readiness Probe

[comment]: # (Readiness probes are very similar to liveness probes except that the result of a failed probe is different. Readiness probes are meant to check if your application is ready to serve traffic. This is subtly different than liveness. For instance, say your application depends on a database and memcached. If both of these need to be up and running for your app to serve traffic, then you could say that both are required for your app's "readiness".)

`readinesProbe`は`livelinessProbe`と似ているものだけど、`readinessProbe`が失敗した結果が違います。`readinessProbe`はアプリケーションが生きているかどうかじゃなくて、トラフィックを受けられるかどうかを確認するためのヘルスチェック。`livelinessProbe`とは微妙に違います。例えば、アプリケーションがデータベースや、memcachedに依存している場合、この二つのサービスが動いていて、接続もできて、さらにアプリケーションも大丈夫な状態じゃないとトラフィックを受けられない。

[comment]: # (If the readiness probe for your app fails, then that pod is removed from the endpoints that make up a service. This makes it so that pods that are not ready will not have traffic sent to them by Kubernetes' service discovery mechanism. This is really helpful for situations where a new pod for a service gets started; scale up events, rolling updates, etc. Readiness probes make sure that pods are not sent traffic in the time between when they start up, and and when they are ready to serve traffic.)

`readinessProbe`が失敗した場合、そのパッドがサービスのエンドポイントから外される。そうすると、Kubernetesのサービスディスカバリー機能でトラフィックを受けられないポッドにトラフィックを転送しない。例えば、ローリングアップデートの時や、スケールアップした時、新しいポッドが機能されていたんだけど、まだトラフィック受けられないタイミングでリクエストが来たら、困るので、`readinessProbe`でそういうことを防ぐ。

[comment]: # (The definition of a readiness probe is the same as liveness probes. Readiness probes are defined as part of a Deployment like so:)

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

[comment]: # (You will want to check that you can connect to all of your application's dependencies in your readiness probe. To use the example where we depend on a database, we will want to check that we are able to connect to both.)

`readinesProbe`の実装では、アプリケーションの依存サービスに接続できるかどうかをチェックする。一つの例として、データベースとmemcachedに依存するアプリケーションの`readinessProbe`を実装する。

[comment]: # (Here's what that might look like. Here I check memcached and the database and if one is not available I return a 503 response status.)

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

[comment]: # (Liveness and Readiness probes really help with the stability of applications. They help to make sure that traffic only goes to instances that are ready for it, as well as self heal when apps become unresponsive. They are a better solution to what my colleage Kelsey Hightower called [12 Fractured Apps](https://medium.com/@kelseyhightower/12-fractured-apps-1080c73d481c). With proper health checks in place you can deploy your applications in any order without having to worry about dependencies or complicated entrypoint scripts. And applications will start serving traffic when they are ready so auto-scaling and rolling updates work smoothly.)

`livenessProbe`と`readinessProbe`はどっちもアプリケーションの安定性に助かる機能。トラフィックを受けられるコンテナだけにトラフィックを転送しないようにしてくれるし、クラッシュしたコンテナや、固まったコンテナを再起動してくれるし、非常に便利。そして、私の同僚のKelsey Hightowerが解説した [12 Fractured Apps](https://medium.com/@kelseyhightower/12-fractured-apps-1080c73d481c)の解決策でもある。ヘルスチェックがあれば、依存するサービスの起動を待ったりする複雑なEntrypointスクリプトはいらない。トラフィックを受けられる時だけ受けるし、ローリングアップデートやスケールアップがスムーズに動きます。