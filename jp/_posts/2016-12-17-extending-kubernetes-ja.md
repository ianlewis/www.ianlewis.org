---
layout: post
title: "Kubernetesを拡張しよう"
date: 2016-12-17 20:30:00 +0000
permalink: /jp/extending-kubernetes-ja
blog: jp
render_with_liquid: false
---

> この記事は [Kubernetes Advent Calendar 2016](http://qiita.com/advent-calendar/2016/kubernetes) の第17日目の記事。第１6目は[yuanying](https://twitter.com/yuanying)さんの「[Openstack で Kubernetes を使う](http://www.fraction.jp/log/archives/2016/12/16/openstack-kubernetes)」でした。

Kubernetesは`Deployment`, `Secret`, `ConfigMap`, `Ingress`など、いろいろ機能があります。それぞれの機能はあることを自動化しているようなものです。 例えば、`Deployment`はアプリケーションのデプロイ・更新を自動化するもの。Ingressはロードバランサーの作成・管理を自動化しているようなもの。その機能は便利ですが、ある程度Kubernetesに取り込んだら、自分で拡張したくなる場合がが多くなる。例えば、[証明書の更新・管理](https://github.com/kelseyhightower/kube-cert-manager)の自動化だとか、[etcdクラスターの管理](https://coreos.com/blog/introducing-the-etcd-operator.html)の自動化だとか。

## Kubernetesアーキテクチャ

Kubernetesをどうやって拡張するかを説明する前に、そもそもKubernetesのアーキテクチャを説明しなくちゃいけない。KubernetesのマスターにAPIサーバーはもちろんあるんですが、APIサーバーは基本的にKubernetesのオブジェクトデータのCRUDオペレーションくらいしかやっていない。例えば、`Deployment`の動きの実装はAPIサーバーには入っていない。ノードが落ちたら、そこに入っていたポッドを別のサーバーに移動したり、ローリングアップデートの動きなどはDeploymentコントローラーで実装されていて、コントローラーマネジャー(kube-controller-manager)というデーモンに入っている。コントローラーマネジャーは何かというと管理に便利だったため、Kubernetesの標準オブジェクト(`Deployment`, `ReplicaSet`, `DaemonSet`, `StatefulSet`など)の複数のコントローラーが合わせて入っているデーモン。

![](https://storage.googleapis.com/static.ianlewis.org/prod/img/759/kube-controller-manager.png)

コントローラーは何かと言いますと、コントロールループで、クラスタのあるべき状態（APIサーバー・etcdに入っているデータ)とクラスタの実際の状態を常に比較して、クラスタのあるべき状態をクラスタに実現させるデーモン。ユーザーがAPIサーバーにあるべき状態を保存したあとに動作するものなので、必然的に非同期のアーキテクチャになる。

![](https://storage.googleapis.com/static.ianlewis.org/prod/img/759/control-loop.jpg)

APIサーバーにオブジェクトの追加、変更、削除を監視できるWatch APIがある。コントローラーマネジャーのコントローラーたちは、APIサーバーのWatch APIを使って、該当のオブジェクトを監視して、他のオブジェクトを作ったり、更新したりする。例えば、`Deployment`コントローラーは`Deployment`が新しく作られたら、その`Deployment`に紐づく`ReplicaSet`を作くったり、`Deployment`の`replicas`が更新されたら、紐づく`ReplicaSet`の`replicas`を更新したりします。

![](https://storage.googleapis.com/static.ianlewis.org/prod/img/759/controller.png)

このコントローラーを組み合わせることもできます。例えば、`ReplicaSet`のコントローラーがさらにあります。`Deployment`コントローラーが`ReplicaSet`を更新したりするけど、`ReplicaSet`の`replicas`に従って、Podを作成したり、監視するのが`ReplicaSet`コントローラーの役目です。

![](https://storage.googleapis.com/static.ianlewis.org/prod/img/759/deployment.png)

Kubernetesオブジェクトではなくて、`Ingress`や`Service`のように外部APIを使う場合もあるだろう。`type=LoadBalancer`の`Service`を作ったら、クラウドプロバイダーの`Service`コントローラーが勝手にロードバランサーを作ってくれることもできます。

![](https://storage.googleapis.com/static.ianlewis.org/prod/img/759/cloud.png)

## Kubernetes を拡張する

Kubernetesを拡張するには標準コントローラーと同じことをする。あるオブジェクトを監視して、追加、変更などがあったら、必要なアクションをするコントローラーを作ります。ただ、標準オブジェクトはAPIがあるんですけど、カスタムオブジェクトを作りたい場合はどうするか？ Kubernetes自体を修正して再コンパイルしてデプロイしたくないので、Kubernetesでは[`ThirdPartyResource`](http://kubernetes.io/docs/user-guide/thirdpartyresources/)というカスタムオブジェクトの定義を作ることができます。`ThirdPartyResource`を作れば、APIサーバーに新しいAPI URLができて、そのURLでカスタムオブジェクトを作ることができます。簡単な例をみてみよう。

## ThirdPartyResourceを定義する

この例では定期的にバッチ`Job`を作るCronコントローラーを作ります。以下の`ThirdPartyResource`では`CronTab`というオブジェクト形を作ります。

```yaml
metadata:
  name: cron-tab.alpha.ianlewis.org
apiVersion: extensions/v1beta1
kind: ThirdPartyResource
description: "A specification of a Job to run on a cron style schedule"
versions:
  - name: v1
```

この`CronTab`を`resource.yaml`に保存して、`kubectl`で作成する。`CronTab`のオブジェクト名は`cron-tab.alpha.ianlewis.org`の最初の部分`cron-tab`をCamel Caseにした名称になる。

```console
$ kubectl create -f resource.yaml
thirdpartyresource "cron-tab.alpha.ianlewis.org" created
```

こうするとAPIサーバーで`/apis/alpha.ianlewis.org/v1/namespaces/<namespace>/crontabs/`というURLエンドポイントが使えるようになります。このURLを使うと`CronTab`オブジェクトを作ることができますが、簡単な操作は`kubectl`を使えます。

```console
$ kubectl get crontab
```

`CronTab`オブジェクトを作ってみましょう。`ThirdPartyResource`のオブジェクトはKubernetesオブジェクトの標準フィールド`apiVersion`, `kind`, `metadata`が必要ですが、それ以外のフィールドはすべて任意JSONデータ。`CronTab`は`spec`というフィールドに[`Job`オブジェクトの`spec`](http://kubernetes.io/docs/user-guide/jobs/#writing-a-job-spec)と同じデータを入れます。以下のYamlを`backup.yaml`に保存します。

```yaml
apiVersion: "alpha.ianlewis.org/v1"
kind: "CronTab"
metadata:
  name: backup
spec:
  schedule: "@daily"
  jobTemplate:
    containers:
      - image: mybackupscript:v9
        name: backup
    restartPolicy: Never
```

`backup`の`CronTab`を作成する

```console
$ kubectl create -f backup.yaml
crontab "backup" created
```

## コントローラーを作る

`ThirdPartyResource`を作ることでAPIサーバーでオブジェクトを保存してくれるんだけど、特に何も処理、動作はしない。処理をするコントローラーを書かなくちゃいけない。コントローラーは非同期処理は多いので、Goでは一番書きやすいと思う。

基本のロジックを書いておく

```go
package main

import (
    "net/http"
    "time"
    "fmt"
    "encoding/json"

    "github.com/robfig/cron"
)

// CronTabの処理をやってくれるcron.CronとCronTabオブジェクトのマッピング
type cronServer struct {
    Server *cron.Cron
    Object cronTab
}

var cronServers = make(map[string]cronServer, 0)

// Kubernetesオブジェクトの`metadata`フィールド
type objectMeta struct {
    Name            string `json:"name"`
    UID             string `json:"uid,omitempty"`
    ResourceVersion string `json:"resourceVersion,omitempty"`
}

// リストで取ってきた場合のJSON型
type cronTabList struct {
    Items []cronTab `json:"items"`
}

type cronTabSpec struct {
    Schedule    string          `json:"schedule"`
    JobTemplate json.RawMessage `json:"jobTemplate"`
}

// CronTabオブジェクト
type cronTab struct {
    // The following fields mirror the fields in the third party resource.
    ObjectMeta objectMeta  `json:"metadata"`
    Spec       cronTabSpec `json:"spec"`
}

func main() {
    for {
        // APIを15秒ごとにポーリングする
        time.Sleep(15 * time.Second)
        resp, err := http.Get("http://localhost:8001/apis/alpha.ianlewis.org/v1/namespaces/default/crontabs")
        if err != nil {
            log.Printf("Could not connect to Kubernetes API: %v", err)
            continue
        }

        // APIから取ってきたJSONをデコード
        decoder := json.NewDecoder(resp.Body)
        var l cronTabList

        err = decoder.Decode(&l)
        if err != nil {
            log.Printf("Could not decode JSON event object: %v", err)
            continue
        }

        // 削除されたCronTabを処理する
        removeDeletedCronTabs(l)

        // 追加、更新されたCronTabを処理
        updateCronTabs(l)
    }
}
```

上の処理で15秒ごとにAPIを叩いて、コントローラーの内部の状態を更新する。`removeDeletedCronTabs()`と`updateCronTabs()`でCronサーバーを操作する。まずは`removeDeletedCronTabs()`を実装する。APIサーバーがつくてくれる`UID`でオブジェクトを特定する。

```go
func removeDeletedCrontabs(l cronTabList) {
    for _, s := range cronServers {
        found := false
        for _, c := range l.Items {
            if c.ObjectMeta.UID == s.Object.ObjectMeta.UID {
                found = true
            }
        }
        if !found {
            removeCronTab(s.Object)
        }
    }
}
```

次、`updateCronTabs()`を実装する。ここにも`UID`でオブジェクトを特定する上、オブジェクトが更新されているかどうかを`resourceVersion`でチェックする。

```go
func updateCronTabs(l cronTabList) {
    for _, c := range l.Items {
        found := false
        for _, s := range cronServers {
            if c.ObjectMeta.UID == s.Object.ObjectMeta.UID {
                if c.ObjectMeta.ResourceVersion != s.Object.ObjectMeta.ResourceVersion {
                    log.Printf("Updating crontab %s", c.ObjectMeta.Name)
                    removeCronTab(s.Object)
                    err := addCronTab(c)
                    if err != nil {
                        log.Printf("Could not create crontab %#v: %v", c, err)
                    }
                }
                found = true
            }
        }
        if !found {
            err := addCronTab(c)
            if err != nil {
                log.Printf("Could not create crontab %#v: %v", c, err)
            }
        }
    }
}
```

`addCronTab()`はこんな感じで`cron.Cron`のサーバーオブジェクトを起動する。このオブジェクトは`goroutine`でスケジュールに従って`addFunc()`で指定した関数を呼び出す。

```go
func addCronTab(c cronTab) error {
    server := cron.New()

    // robfig/cronのCronは秒間のスケジュールに対応しているけど、
    // ここに標準のcronに追従して分間単位でスケジュールする
    spec := c.Spec.Schedule
    if !strings.HasPrefix(c.Spec.Schedule, "@") {
        spec = "0 " + c.Spec.Schedule
    }
    
    err := server.AddFunc(spec, func() {
        if err := runCronJob(c); err != nil {
            log.Printf("Error running cron job: %v", err)
        }
    })
    if err != nil {
        return fmt.Errorf("error adding crontab: %v", err)
    }

    cronServers[c.ObjectMeta.UID] = cronServer{
        Server: server,
        Object: c,
    }

    server.Start()

    log.Printf("Added crontab: %s", c.ObjectMeta.Name)

    return nil
}
```

`removeCronTab()`はこんな感じ

```go
func removeCronTab(c cronTab) {
    if server, ok := cronServers[c.ObjectMeta.UID]; ok {
        server.Server.Stop()
        delete(cronServers, c.ObjectMeta.UID)
        log.Printf("Removed crontab: %s", c.ObjectMeta.Name)
    }
}
```

最後に`runCronJob()`の実際にCronジョブを実行してくれる関数を定義する。ここにKubernetesの`Job`オブジェクトを作ってその後、Kubernetesに任せる。

```go
type labels *map[string]string

type selector struct {
	MatchLabels labels `json:"matchLabels,omitempty"`
}

type jobTemplate struct {
	ObjectMeta      objectMeta       `json:"metadata"`
	JobTemplateSpec json.RawMessage `json:"spec,omitempty"`
}

type jobSpec struct {
	Selector *selector    `json:"selector,omitempty"`
	Template *jobTemplate `json:"template,omitempty"`
}

func runCronJob(c cronTab) error {
    name := makeJobName(c)
    log.Printf("Creating job %s for crontab %s", name, c.ObjectMeta.Name)

    job := job{
        ObjectMeta: objectMeta{
            Name: name,
        },
        JobSpec: jobSpec{
            Selector: &selector{
                MatchLabels: &map[string]string{
                    "name": name,
                },
            },
            Template: &jobTemplate{
                ObjectMeta: objectMeta{
                    Name: name,
                    Labels: &map[string]string{
                        "name": name,
                    },
                },
                JobTemplateSpec: &c.Spec.JobTemplate,
            },
        }
    }

    j, err := json.Marshal(job)
    if err != nil {
        return fmt.Errorf("could not marshal job to JSON: %s", err)
    }

    resp, err := http.Post("http://localhost:8001/apis/extensions/v1beta1/namespaces/default/jobs", "application/json", bytes.NewReader(j))
    if err != nil {
        return fmt.Errorf("HTTP request failed: %s", err)
    }

    return nil
}
```

## コントローラーをデプロイする

このコントローラーはローカルPCなどAPIサーバーにアクセスさえできれば、どこにも動かしてもいいんだけど、最終的にクラスターにデプロイした方が良い。上のコントローラーのコードにはどこにもAPIの認証の処理をやっていないけど、`kubectl proxy`を使えば、認証を`kubectl`に任せることができる。Kubernetesクラスタにデプロイすれば、サービスアカウントがPodに紐付けられる。[デフォルトサービスアカウント](http://kubernetes.io/docs/user-guide/service-accounts/)を使えば、Podの`/var/run/secrets/kubernetes.io/serviceaccount/`に認証用のトークンをマウントして、クラスタ内のPodからAPIへアクセスさせる。`kubectl`はこういうトークンファイルを探していて、自動的に認証してくれますので、使うのが非常に便利。

```yaml
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: cron-controller
spec:
  replicas: 1
  template:
    metadata:
      labels:
        name: cron-controller
    spec:
      containers: 
        - name: cron
          image: my.registry.com/cron-controller:0.0.1
        # 認証するためにkubectl proxyを使う
        - name: kubectl
          image: my.registry.com/kubectl:v1.5.1
          args:
            - "proxy"
          ports:
            - name: proxy
              containerPort: 8001
```

これでクラスタにデプロイして、Cronサーバーを動かす。

```console
$ kubectl create -f deploy.yaml
deployment "cron-controller" created
```

うまく行けば、CronTabのスケジュールに従って、`Job`が作成される 
 
```console
$ kubectl logs cron-controller-3711479224-7z3t0
2016/12/16 04:28:33 Watching for crontab objects...
2016/12/16 04:28:48 Added crontab: backup
2016/12/17 00:00:00 Creating job backup-8dasy for crontab backup
```

それで`Job`オブジェクトが見れるはず。

```console
$ kubectl get jobs
NAME                    DESIRED   SUCCESSFUL   AGE
backup-8dasy            1         1            5m
```

## まとめ

`ThirdPartyResource`とコントローラーの組み合わせでKubernetesの標準機能と同じように、Kubernetesらしく拡張できる。このアーキテクチャを使うと安定性の高いシステム作るができるでしょう。

また、もし興味がある方は [Kubernetes Slackチャンネル](http://slack.kubernetes.io/)にジョインすると、他のKubernetes開発者と話せますし、`#jp-users` に日本のユーザーもいるのでぜひジョインしてみてください。

以上、 [Kubernetes Advent Calendar 2016](http://qiita.com/advent-calendar/2016/kubernetes) の第17日の記事でした。明日は、[hiyosi](https://twitter.com/hiyosi)さんの「認証関連で何か」を期待しましょう。