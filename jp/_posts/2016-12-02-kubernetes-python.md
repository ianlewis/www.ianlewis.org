---
layout: post
title: "Kubernetes Python クライアントを使ってみる"
date: 2016-12-02 12:00:00 +0000
permalink: /jp/kubernetes-python
blog: jp
tags: python kubernetes
render_with_liquid: false
locale: ja
---

> この記事は [pyspa Advent Calendar 2016](http://www.adventar.org/calendars/1435#list-2016-12-02) の第２日目の記事。第１目はakisuteさんの「[今年の話](http://akisute.com/2016/12/pyspa-advent-calendar-2016-1.html)」だった。

「斧さんの記事凄かった。pyspa の二日目の人まじかわいそう」というかわいそうなイアンです。よろしくです。

私はGoogleに入ってもうすぐ２年が経つのですが、今年はコンテナオーケストレーションシステムの[Kubernetes](http://kubernetes.io/)をだいぶ触るようになった。と同時にPythonを使うシーンが結構減ってしまったんですけど、今回は両方使うことにした。

## Kubernetesはなんっすか

みんなDocker触ったことあるけど、Kubernetesなんで触ったことない人がまだ結構いると思うけど、ちょっと説明してみる。Kubernetesは今までやっていたことを自分なりに自動化したものだと考えるといい。今まで、ChefやAnsibleでウェブアプリをサーバーにダウンロードして起動してsupervisordか何かの方法で監視して、その前にロードバランサを作って外からアクセスすることができるようにしたと思う。sshを使わないし、内部でやっていることがだいぶ違うけど、ハイレベルで考えるとKubernetesはアプリのパッケージフォーマットとしてDockerイメージを使って以前にChefやAnsibleでやったことをAPIでできるようにしているもの。

簡単な例ですが、`nginx`をデプロイしてみる。KubernetesのAPIを簡単に使えるために`kubectl`というCLIがあります。

```shell
$ kubectl run nginx --image=nginx:1.10 --replicas=5
deployment "nginx" created
```

こうするとnginxのをデプロイするために[Deployment](http://kubernetes.io/docs/user-guide/deployments/)を作ります。これでKubernetesクラスタの中で`nginx:1.10`をDocker Hubからダウンロードして、nginxのコンテナを５台起動する。以下のコマンドで確認できる。

```shell
$ kubectl get deployments
NAME      DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
nginx     5         5         5            5           54s

$ kubectl get pods
nginx-527866857-1o78v   1/1       Running            0          54s
nginx-527866857-l0z3f   1/1       Running            0          54s
nginx-527866857-lub8r   1/1       Running            0          54s
nginx-527866857-rdvgf   1/1       Running            0          54s
nginx-527866857-w12s7   1/1       Running            0          54s
```

`kubectl`がKubernetesのREST API経由で`Deployment`を作ったことで、アプリをデプロイした。もちろん、APIでアプリコンテナを数を増やしたり、減らしたりすることもできるし、アプリを完全に削除することもできる。

外からアクセスしたい時は[Service](http://kubernetes.io/docs/user-guide/services/)を作れば、クラスタの外からアクセスすることができる。GCPやAWSを使っている場合は、クラウドのAPIと連動してロードバランサを作ってくれます。

```shell
$ kubectl expose deployment nginx --type=LoadBalancer --port=80
service "nginx" exposed

$ kubectl get svc
NAME         CLUSTER-IP       EXTERNAL-IP       PORT(S)   AGE
kubernetes   10.239.240.1     <none>            443/TCP   57d
nginx        10.239.249.220   104.155.215.220   80/TCP    1m

$ curl -s http://104.155.215.220/ | grep title
<title>Welcome to nginx!</title>
```

そして、`Deployment`だけじゃなくて、設定をもつ[`ConfigMap`](http://kubernetes.io/docs/user-guide/configmap/)や[Secret](http://kubernetes.io/docs/user-guide/secrets/)もあるし、永住ストーレッジの[`PersistentVolume`](http://kubernetes.io/docs/user-guide/persistent-volumes/)もあるし、必要なものはたいていあって全部APIから制御できる。

## PythonからAPIを触ってみる

KubernetesはREST APIを提供しているので、基本的にどの言語でもKubernetesクラスタを制御できる。私の一番好きな言語の一つがPythonだし、最近新しい[正式Pythonクライアント](https://github.com/kubernetes-incubator/client-python)が`kubernetes-incubator`に出たので、使ってみようと思う。

インストールはいつもどおり`pip`を使う

```shell
pip install kubernetes
```

そうしたら、わりと簡単にAPIを使える。以下のアプリはdefault名前空間のポッドの名前、ステータス、IPアドレスを表示する。

```python
import os
from kubernetes import client, config

config.load_kube_config(
    os.path.join(os.environ["HOME"], '.kube/config'))

v1 = client.CoreV1Api()

pod_list = v1.list_namespaced_pod("default")
for pod in pod_list.items:
    print("%s\t%s\t%s" % (pod.metadata.name,
                          pod.status.phase,
                          pod.status.pod_ip))
```

実行すると

```shell
$ python list_pods.py
nginx-2048367498-2000v  Running 10.236.2.16
nginx-2048367498-a4otw  Running 10.236.0.15
nginx-2048367498-eblzn  Running 10.236.1.20
nginx-2048367498-tqy6j  Running 10.236.2.17
nginx-2048367498-zwkfg  Running 10.236.0.16
```

このクライアントはKubernetesの[swaggerスペック](http://kubernetes.io/kubernetes/third_party/swagger-ui/)から生成しているっぽいので、基本的に[APIの全部のエンドポイント](https://github.com/kubernetes-incubator/client-python/tree/master/kubernetes#documentation-for-api-endpoints)に対応している。

すべてのオブジェクトタイプをウォッチすることもできる。なにかのオブジェクトが変更されたらイベントを拾って何か処理する。

```python
import os
from kubernetes import client, config, watch

config.load_kube_config(
    os.path.join(os.environ["HOME"], '.kube/config'))

v1 = client.CoreV1Api()

stream = watch.Watch().stream(v1.list_namespaced_pod, "default")
for event in stream:
    print("Event: %s %s" % (event['type'], event['object'].metadata.name))
```

```shell
$ python watch_pods.py
Event: ADDED nginx-2048367498-zwkfg
Event: ADDED nginx-2048367498-2000v
Event: ADDED nginx-2048367498-a4otw
Event: ADDED nginx-2048367498-eblzn
Event: ADDED nginx-2048367498-tqy6j
Event: MODIFIED nginx-2048367498-a4otw
Event: MODIFIED nginx-2048367498-zwkfg
```

## まとめ

このところまで読んだら「んじゃ、APIで何ができる？なんのメリットある？」って思っているかもしれない。APIの上に作れるものは幅広いんだけど、便利なUI (例: [`kubernetes/dashboard`](https://github.com/kubernetes/dashboard))や、CIシステムのパイプライン(例: [fabric8](https://fabric8.io/))や、監視ツールや、フルフルなPaaS(例: [Deis](http://deis.io/), [OpenShift](https://www.openshift.com/))、やserverless的なFaaS(Function as a Service, 例: [`fission.io`](http://fission.io/), [Funktion](https://github.com/fabric8io/funktion))が作れるだろう。

[client-python](https://github.com/kubernetes-incubator/client-python)をインストールして、Pythonでアプリを作ってみよう。もし、興味がある方は [Kubernetes Slackチャンネル](http://slack.kubernetes.io/)にジョインすると、他のKubernetes開発者と話せる。Pythonクライアントを担当しているのが `#sig-api-machinery` というチャンネルですが、英語得意じゃない方はぜひ `#jp-users` にジョインしていただけると幸い
