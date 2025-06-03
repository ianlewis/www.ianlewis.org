---
layout: post
title: "Kubernetes + Mesos の組み合わせ"
date: 2014-12-19 17:15:00 +0000
permalink: /jp/kubernetes-mesos
blog: jp
tags: gcp kubernetes mesos
render_with_liquid: false
locale: ja
---

_この記事は [Kubernetes Advent Calendar 2014](http://qiita.com/advent-calendar/2014/kubernetes)の19日目の記事です。18日の記事は [kazunori279](http://qiita.com/kazunori279) の[GKE＋BQがうまく動かなかった話](http://qiita.com/kazunori279/items/974c8b848af079d48d9c)。_

Kubernetes (Kubernetes)とMesosがやっていることが似ているように見えて、何が違うかイマイチわからない開発者が多いと思います。それぞれがやっていることと、役割について書いて、その後、組み合わせて使うにはどうしたらいいか少し書いてみたいと思います。

## Kubernetesについて

まず、Kubernetesはどこまで何をしてくれるの？ という疑問がよくあると思う。コンテナーのクラスターが作れるみたいだけど、自動的にスケールしてくれるのかな？とか、考えてくるよね。

KubernetesはDockerコンテナーのクラスターを管理してくれるものだ。Docker自体はコンテナーを管理してくれるからKubernetesはなんで必要かと思っていしまうかもしれないけど、Dockerはローカルに動かしているコンテナーしか面倒見てくれない。そのため、１台以上のクラスタになってくると、それぞれのサーバーに入っているDockerコンテナーをどうやって管理するかってことになる。Kubernetes はそれぞれのサーバー (Node)の中にコンテナーをグループ化 (Pod)して、管理してくれます。そのコンテナーに動かしているものをどうやってアクセスするかをサービス(Service)という定義で設定します。それぞれのサーバーとコンテナーとネットワークなどの面倒をしてくれる。

![Kubernetes](/assets/images/727/k8s_big.png)

その上に、クラスターを管理するために API を用意してる。そのAPIを使って、コンテナーを追加したら、減らしたりすることができます。コンテナーを追加したり、減らしたりすると Kubernetes のスケジューラーでどのサーバーのどのPodに対して、コンテナーを追加・削除するかが決まる。そのスケジューラーは今のところかなりシンプルで、クラスターのリソースを見たりしないので、同じサーバーの中に Kubernetes 以外のものを動かしているとメモリーや、CPUを使ってしまったり、リソースを取り合ってしまうと思います。

k8sもauto-scalingなどができると聞いたことあるかもしれませんが、それはGoogleが提供している
k8sのホステッド版、Google Container Engineの機能です。ホステッドだとロードバランサーや、
サーバーの状況がわかるので、そういうのが提供できるんですが、k8s自体はAutoscalingを提供しない。

## Mesos

[Mesos](http://mesos.apache.org/) はクラスターのサーバーのメモリや、CPUを抽象的に使えるようにするサービスで、空いてるCPUやメモリのところにアプリを動かせるようにしてくれる。あるクラスターにあるアプリを実行しようって思った時に、Mesosでどこに動かしたらいいかが決まっていて、
アプリをそこに動かすようにスケジュリングを提供してくれる。ようするに、k8sがやってくれないことをしっかりやってくれるやつだ！と思いきや、実は、Mesosはリソースを見てくれるけど、Autoscalingは提供しない。あくまで、追加したり、減らしたりしたい場合は、どこから削除するか、どこに追加すればいいかしか提供しない。けど、Autoscalingの一部にはなるし、Autoscalingがなくても、結構助かると思います。

## Kubernetes + Mesosの組み合わせ

実は、k8s + Mesosの話をチャレンジしたいと思っていたが、僕はそんなにMesos詳しくないから、動かすにはいろいろ苦労した。

Mesosの会社MesosphereはMesosのでもイメージを作ってくれたので、以下の`Vagrantfile`でとりあえずMesosを動かせると思います。

```ruby
# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  config.vm.box = "km-demo"
  config.vm.box_url = "http://downloads.mesosphere.io/demo/km-demo.box"

  config.vm.synced_folder ".", "/vagrant", :disabled => true
  config.vm.synced_folder "./", "/home/vagrant/hostfiles"

  config.ssh.forward_agent = true

  config.vm.provider :virtualbox do |vb|
    vb.customize ["modifyvm", :id, "--ioapic", "on"]
    vb.customize ["modifyvm", :id, "--cpus", "1"]
    vb.customize ["modifyvm", :id, "--memory", "512"]
  end

  config.vm.provision "shell", path: "provision.sh"
end
```

そして、k8sとMesosを連動して動かせるのかなって調べてみたら、Mesosphereが作り中の[`kubernetes-mesos`](https://github.com/mesosphere/kubernetes-mesos)プロジェクトがあった。

このプロジェクトはk8sを拡張して、Mesosが使えるようにしている。k8sのコードはかなりパッケージ化してそのままインポートして、[Mesosスケジューラを実装しているみたい](https://github.com/mesosphere/kubernetes-mesos/blob/master/kubernetes-mesos/main.go)。

まずは、buildしてみましょう。まずは、上の`Vagrantfile`で起動したVMでGoをインストールする必要がある。

```shell
$ mkdir -p /usr/local/opt/gopath
$ curl -L https://storage.googleapis.com/golang/go1.4.linux-amd64.tar.gz | tar xvz
...
$ export GOROOT=/usr/local/opt/go
$ export GOPATH=/usr/local/opt/gopath
$ export PATH=$GOROOT/bin:$GOPATH/bin:$PATH
$ cat <<EOF > /etc/profile.d/gopath.sh
> export GOROOT=$GOROOT
> export GOPATH=$GOPATH
> export PATH=\$GOROOT/bin:\$GOPATH/bin:\$PATH
> EOF
```

次は`kubernetes-mesos`をビルドする

```shell
$ go get github.com/tools/godep
$ cd $GOPATH
$ mkdir -p src/github.com/mesosphere/kubernetes-mesos
$ git clone https://github.com/mesosphere/kubernetes-mesos.git src/github.com/mesosphere/kubernetes-mesos
...
$ cd src/github.com/mesosphere/kubernetes-mesos
$ godep restore
$ go install github.com/GoogleCloudPlatform/kubernetes/cmd/{proxy,kubecfg}
$ go install github.com/mesosphere/kubernetes-mesos/kubernetes-{mesos,executor}
$ go install github.com/mesosphere/kubernetes-mesos/controller-manager
```

そうすると、`kubernetes-mesos`サービスを起動できる

```shell
$ export servicehost=127.0.0.1
$ export KUBERNETES_MASTER=http://${servicehost}:8888
$ nohup kubernetes-mesos \
>   -address=${servicehost} \
>   -mesos_master=${servicehost}:5050 \
>   -etcd_servers=http://${servicehost}:4001 \
>   -executor_path=$(pwd)/bin/kubernetes-executor \
>   -proxy_path=$(pwd)/bin/proxy -v=2  2>&1 >> /var/log/kubernetes-mesos.log &
```

```shell
$ nohup controller-manager \
>   -master=${KUBERNETES_MASTER#http://*} \
>   -v=2 2>&1 >> /var/log/controller-manager.log &
```

サービスが起動できたら、`kubectl`でPodを起動できるはずだが、なぜかステータスが`Waiting`になっている。

```shell
$ sudo kubecfg -c /usr/local/opt/gopath/src/github.com/mesosphere/kubernetes-mesos/examples/pod-nginx.json create pods
ID                  Image(s)            Host                Labels                 Status
----------          ----------          ----------          ----------             ----------
nginx-id-01         dockerfile/nginx    <unassigned>        cluster=gce,name=foo   Waiting
```

ログを見てみると、Mesosから適切なホストはないように書いている:

```shell
$ sudo less +GF /var/log/kubernetes-mesos.log
...
I1219 07:57:23.312624 22873 scheduler.go:473] About to try and schedule pod nginx-id-01
I1219 07:57:23.312654 22873 scheduler.go:435] Try to schedule pod nginx-id-01
I1219 07:57:23.312669 22873 scheduler.go:810] failed to find a fit for pod: nginx-id-01
I1219 07:57:23.312680 22873 scheduler.go:479] Error scheduling nginx-id-01: No suitable offers for pod/task; retrying
...
```

Mesosのログを見てみると以下のログが大量に出ている:

```shell
$ sudo less +G /var/log/mesos/mesos-master.WARNING
...
W1219 08:00:04.636499  1297 master.cpp:751] Dropping 'mesos.internal.RegisterFrameworkMessage' message since not elected yet
...
```

Mesosのマスターは当選されてないような感じなのか？よくわからん (MesosphereのサンプルVMの問題なのかな？)

まだちゃんと動かないのですが、上のことをもっと簡単にできるために、サンプル用の`VagrantFile`を作って、[GitHub](https://github.com/ianlewis/k8s-mesos-demo)に上げた。

## 感想

Kubernetesのスケジューラーがまだそんなに賢くなくて、そして、まだ簡単にプラガブルではなく差し替えにくいので、`kubernetes-mesos`は組み合わせて使うものではなく、Kubernetesを「フレームワーク」として使って、自前でサービスを作っているっぽい（知っている人は少ないと思うが、[Jubatus](http://jubat.us/ja/)の使い方を思い出した)。

Kubernetesのスケジューラーがもっとプラガブルになったら、MesosでKubernetesや、Hadoopや、Impalaなどを同じリソースプールで動かせるので、本当に強力になると思う。
