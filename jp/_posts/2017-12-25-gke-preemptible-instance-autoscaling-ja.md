---
layout: post
title: "Preemptible InstanceでGKEクラスターのオートスケーリング"
date: 2017-12-25 15:30:00 +0000
permalink: /jp/gke-preemptible-instance-autoscaling-ja
blog: jp
tags: kubernetes google-container-engine
render_with_liquid: false
locale: ja
---

> このポストは [Kubernetes Advent Calendar Day 25](https://qiita.com/advent-calendar/2017/kubernetes)の記事です。

Google Compute Engine (GCE)ではPreemptible Instanceを作ることができます。Preemptible Instanceを使うと変動するようなワークロードにかなりコストを削減できます。

Google Kubernetes Engine (GKE)は標準にクラスターオートスケーラーがついています。
クラスターオートスケーラーを有効にするとクラスターの要求されているワークロードに
対してクラスターを自動的にスケールできます。GKEクラスターのノードはGCEのVMに
なっているので
[preemptible instanceのノードプール](https://cloud.google.com/kubernetes-engine/docs/concepts/preemptible-vm)の
作成にサポートしています。

この記事ではこの２つの機能を組み合わせて安くて自動的にスケールするリソースの作成をやってみたい。
一緒にやってみたい方はGCPの[$300無料トライアル](https://cloud.google.com/free/)を使うといいと思います。

## Preemptible Instances

[Preemptible instance](https://cloud.google.com/compute/docs/instances/preemptible)はGCEの単価が
安く一時的なVMを作成できる機能です。GCEゾーンのデータセンターの余裕キャパを買うような感じですので、
かなり安く提供できるけど、VMのアベイラビリティが普段より低い。

例えば、普通のn1-standard-1のインスタンスは東京リージョンですと$0.0610ですが、 Preemptibleですと$0.01325で、1/4以下の値段。

Preemptible Instanceの欠点はいくつかある。その一つはVMがいつでも停止される可能性があることです。GCEのシステム状況によって
ACPI G2 Soft OffメッセージをVMに送ってきます。そのあと、VMに動いているアプリケーションが安全に停止する時間があります。

もう一つの欠点は、Preemptible VMが最大24時間で停止される。そして、新しいインスタンスを作るには必要なリソースを確保できない
可能性は普通のインスタンスより低い。VMを作れないゔ可能性は低いけれど、たまに作れない時がある。

欠点がありますが、たくさんのユースケースをローコストで満たせます。Preemptible instanceを`--preemptibleフラグで作れます：`

```shell
gcloud compute instances create preemptible-instance --preemptible
```

## GKE Cluster Autoscaler

GKEはクラスターノードを動的にスケールする[cluster autoscaler](https://cloud.google.com/kubernetes-engine/docs/concepts/cluster-autoscaler)機能があります。オートスケーラーはクラスターのノードプールを利用してソートスケーリングを有効にすることができます。

クラスターオートスケーラーはスケジュールされてなく、リソースの確保を待っているPodを監視し、スケールすれば、スケジュールできるようになったら、VMノードを追加して、クラスターをスケールアップします。

オートスケーラーを有効にするには`--enable-autoscalingをクラスター作成時に指定します。最大と最低のPod数を指定できます。このコマンドはオートスケーラーを有効にしたノードプールが含まれるクラスターを作ります：`

```shell
gcloud container clusters create autoscaled-cluster \
  --enable-autoscaling \
  --min-nodes=1 \
  --max-nodes=5
```

オートスケーリングするノードプールをあとでも追加できます：

```shell
gcloud container node-pools create autoscaled-pool \
  --cluster=autoscaled-cluster \
  --enable-autoscaling \
  --min-nodes=1 \
  --max-nodes=5
```

## Preemptibleノードプールのオートスケーリング

クラスターオートスケーラーとPreemptibleインスタンスを組み合わせることで、動的にスケールするクラスターをオーコストで実現できる。

> メモ：Preemptibleノードプールは現在ベータなのでSLAやDeprecation policyがまだありません。

GKEベータAPIを使うために、以下のコマンドを実行する：

```shell
gcloud config set container/use_v1_api_client false
```

Preemptibleインスタンスを確保できない場合があるので、一般的なユースケースとして、普通のノードプールを固定したインスタンス数で作って、そして、別のPreemptibleノードプールでオートスケーリングをする。まずは普通のノードプールを作成：

```shell
gcloud container clusters create burstable-cluster --num-nodes 3
```

次ぐにオートスケーリングするPreemptibleノードプールを作成：

```shell
gcloud beta container node-pools create preemptible-pool \
    --cluster burstable-cluster \
    --preemptible \
    --num-nodes 0 \
    --enable-autoscaling \
    --min-nodes 0 \
    --max-nodes 5 \
    --node-taints=pod=preemptible:PreferNoSchedule
```

このノードプールは必要なリソースに対して、スケールするけど、低コストのPreemptibleインスタンスを使ってくれます。Preemptibleリソースは取れない場合があるので、[node taint](https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/) を設定して、こういう変動するようなリソース状況を耐えるアプリケーションだけが実行を許可する。

どれで普通のノードプールとPreemptibleノードプール両方に動くようなDeploymentを作成できる：

```shell
cat <<EOF | kubectl apply -f -
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  labels:
    run: hello-web
  name: hello-preempt
spec:
  replicas: 10
  selector:
    matchLabels:
      run: hello-web
  template:
    metadata:
      labels:
        run: hello-web
    spec:
      containers:
      - image: gcr.io/google-samples/hello-app:1.0
        name: hello-web
        ports:
        - containerPort: 8080
          protocol: TCP
        resources:
          requests:
            cpu: "200m"
      tolerations:
      - key: pod
        operator: Equal
        value: preemptible
        effect: PreferNoSchedule
EOF
```

クラスターは最初にリソースが足りないので、`Pending`ステータスのPodをいくつか見れるはず。そのあとにノードが追加されることにつれて、`Running` ステータスに変わる。

```shell
kubectl get pods -o wide
```

## まとめ

上のコマンドを実行して、試してみた場合はいかのコマンドでリソースを削除できます。

```shell
gcloud compute instances delete preemptible-instance
gcloud container clusters delete autoscaled-cluster
gcloud container clusters delete burstable-cluster
```

GKEの高度な機能を組み合わせることで、低コストとアプリケーションアベイラビリティのバランスをとった構成が作れます。ベータ機能なのでクラスターを作れば、誰でもオートスケーラーとPreemtibleノードプールが利用できます。

もっとKubernetes知りたい方は、以下のアイテムをどうぞ:

- GKEの [how-to guides](https://cloud.google.com/kubernetes-engine/docs/how-to/) を読む。
- [Google Cloud Platform Slack](https://gcp-slack.appspot.com/) (`#kubernetes-engine` チャンネルに参加してください。)
- [GCPUG Slack](https://docs.google.com/forms/d/e/1FAIpQLScYxAGwuosFFNvH-5yOj-_p-pAKdqZpmM2cgKh9Q8Zu6531Bw/viewform)に参加する (`#gke_ja`チャンネルに参加してください）
- [Kubernetes Slack](http://slack.k8s.io/)に参加すfる (`#gke`チャンネルに注目)

ではまた！
