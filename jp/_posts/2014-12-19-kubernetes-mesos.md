---
layout: post
title: "Kubernetes + Mesos の組み合わせ"
date: 2014-12-19 17:15:00 +0000
permalink: /jp/kubernetes-mesos
blog: jp
---

_この記事は [Kubernetes Advent Calendar 2014](http://qiita.com/advent-calendar/2014/kubernetes)
の19日目の記事です。18日の記事は [kazunori279](http://qiita.com/kazunori279) の
[GKE＋BQがうまく動かなかった話](http://qiita.com/kazunori279/items/974c8b848af079d48d9c)。_

Kubernetes (k8s)とMesosがやっていることが似ているように見えて、
何が違うかイマイチわからない開発者が多いと思います。
それぞれがやっていることと、役割について書いて、その後、
組み合わせて使うにはどうしたらいいか少し書いてみたいと思います。

## k8s について

まず、k8s はどこまで何をしてくれるの？ という疑問がよくあると思う。
コンテナーのクラスターが作れるみたいだけど、
自動的にスケールしてくれるのかな？とか、考えてくるよね。

k8s は Docker コンテナーのクラスターを管理してくれるものだ。Docker自体はコンテナーを管理してくれるから k8s は
なんで必要かと思っていしまうかもしれないけど、Dockerはローカルに動かしているコンテナーしか面倒見てくれない。
そのため、１台以上のクラスタになってくると、それぞれのサーバーに入っているDockerコンテナーをどうやって
管理するかってことになる。k8s はそれぞれのサーバー (Node)の中にコンテナーをグループ化 (Pod)して、
管理してくれます。そのコンテナーに動かしているものをどうやってアクセスするかをサービス(Service)という定義で
設定します。それぞれのサーバーとコンテナーとネットワークなどの面倒をしてくれる。

![Kubernetes](https://storage.googleapis.com/static.ianlewis.org/prod/img/727/k8s_big.png)

その上に、クラスターを管理するために API を用意してる。そのAPIを使って、コンテナーを追加したら、
減らしたりすることができます。コンテナーを追加したり、減らしたりすると k8s のスケジューラーで
どのサーバーのどのPodに対して、コンテナーを追加・削除するかが決まる。そのスケジューラーは今のところ
かなりシンプルで、クラスターのリソースを見たりしないので、同じサーバーの中に k8s 以外のものを動かしていると
メモリーや、CPUを使ってしまったり、リソースを取り合ってしまうと思います。

k8sもAutoScalingなどができると聞いたことあるかもしれませんが、それはGoogleが提供している
k8sのホステッド版、Google Container Engineの機能です。ホステッドだとロードバランサーや、
サーバーの状況がわかるので、そういうのが提供できるんですが、k8s自体はAuto Scalingを提供しない。

## Mesos

[Mesos](http://mesos.apache.org/) はクラスターのサーバーのメモリや、CPUを抽象的に使えるようにするサービスで、空いてるCPUやメモリのところにアプリを動かせるようにしてくれる。あるクラスターにあるアプリを実行しようって思った時に、Mesosでどこに動かしたらいいかが決まっていて、
アプリをそこに動かすようにスケジュリングを提供してくれる。ようするに、k8sがやってくれないことをしっかりやってくれるやつだ！と思いきや、実は、Mesosはリソースを見てくれるけど、Auto Scalingは提供しない。あくまで、追加したり、減らしたりしたい場合は、どこから削除するか、どこに追加すればいいかしか提供しない。けど、Auto Scalingの一部にはなるし、Auto Scalingがなくても、結構助かると思います。

## k8s + Mesosの組み合わせ

実は、k8s + Mesos の話をチャレンジしたいと思っていたが、僕はそんなに mesos 詳しくないから、動かすにはいろいろ苦労した。

Mesos の会社 MesosphereはMesosのでもイメージを作ってくれたので、以下の ~~VagrantFile`` でとりあえず Mesos を動かせると思います。

```
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

そして、k8sとMesosを連動して動かせるのかなって調べてみたら、Mesosphereが作り中の
[kubernetes-mesos](https://github.com/mesosphere/kubernetes-mesos) プロジェクトがあった。

このプロジェクトはk8sを拡張して、Mesosが使えるようにしている。 k8s のコードはかなりパッケージ化して
そのままインポートして、Mesosスケジューラを実装しているみたい。

[https://github.com/mesosphere/kubernetes-mesos/blob/master/kubernetes-mesos/main.go](https://github.com/mesosphere/kubernetes-mesos/blob/master/kubernetes-mesos/main.go)

まずは、buildしてみましょう。まずは、上のVagrantFileで起動したVMで Go をインストールする必要がある。

```
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

次は kubernetes-mesos をビルドする

```
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

そうすると、kubernetes-mesosサービスを起動できる

```
    $ export servicehost=127.0.0.1
    $ export KUBERNETES_MASTER=http://${servicehost}:8888
    $ nohup kubernetes-mesos \
    >   -address=${servicehost} \
    >   -mesos_master=${servicehost}:5050 \
    >   -etcd_servers=http://${servicehost}:4001 \
    >   -executor_path=$(pwd)/bin/kubernetes-executor \
    >   -proxy_path=$(pwd)/bin/proxy -v=2  2>&1 >> /var/log/kubernetes-mesos.log &
```

```
    $ nohup controller-manager \
    >   -master=${KUBERNETES_MASTER#http://*} \
    >   -v=2 2>&1 >> /var/log/controller-manager.log &
```

サービスが起動できたら、 `kubectl` で Pod を起動できるはずだが、なぜかステータスが Waiting になっている。

```
    $ sudo kubecfg -c /usr/local/opt/gopath/src/github.com/mesosphere/kubernetes-mesos/examples/pod-nginx.json create pods
    ID                  Image(s)            Host                Labels                 Status
    ----------          ----------          ----------          ----------             ----------
    nginx-id-01         dockerfile/nginx    <unassigned>        cluster=gce,name=foo   Waiting
```

ログを見てみると、Mesosから適切なホストはないように書いている:

```
    $ sudo less +GF /var/log/kubernetes-mesos.log
    ...
    I1219 07:57:23.312624 22873 scheduler.go:473] About to try and schedule pod nginx-id-01
    I1219 07:57:23.312654 22873 scheduler.go:435] Try to schedule pod nginx-id-01
    I1219 07:57:23.312669 22873 scheduler.go:810] failed to find a fit for pod: nginx-id-01
    I1219 07:57:23.312680 22873 scheduler.go:479] Error scheduling nginx-id-01: No suitable offers for pod/task; retrying
    ...
```

Mesosのログを見てみると以下のログが大量に出ている:

```
    $ sudo less +G /var/log/mesos/mesos-master.WARNING
    ...
    W1219 08:00:04.636499  1297 master.cpp:751] Dropping 'mesos.internal.RegisterFrameworkMessage' message since not elected yet
    ...
```

Mesosのマスターは当選されてないような感じなのか？よくわからんorz (MesosphereのサンプルVMの問題なのかな？)

まだちゃんと動かないのですが、上のことをもっと簡単にできるために、サンプル用の `VagrantFile` を作って、
[github](https://github.com/IanLewis/k8s-mesos-demo) に上げた。

## 感想

Kubernetesのスケジューラーがまだそんなに賢くなくて、そして、まだ簡単にプラガブルではなく差し替えにくいので、
kubernetes-mesosは組み合わせて使うものではなく、Kubernetesを「フレームワーク」として使って、
自前でサービスを作っているっぽい（知っている人は少ないと思うが、 [jubatus](http://jubat.us/ja/)
の使い方を思い出した)。

Kubernetesのスケジューラーがもっとプラガブルになったら、MesosでKubernetesや、
Hadoopや、Impalaなどを同じリソースプールで動かせるので、本当に強力になると思う。