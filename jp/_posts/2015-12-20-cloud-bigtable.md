---
layout: post
title: "Googleのほとんどのサービスを支えるBigtableの誰でも使える版 Cloud Bigtable"
date: 2015-12-20 16:00:00 +0000
permalink: /jp/cloud-bigtable
blog: jp
tags: cloud-bigtable google-cloud-platform
render_with_liquid: false
locale: ja
---

> これは [Google Cloud Platform Advent Calendar 2015](http://qiita.com/advent-calendar/2015/gcp)の19日目の記事です。

<img alt="Cloud Bigtable" title="Cloud Bigtable" class="align-center" src="/assets/images/746/bigtable.png">

そろそろ僕がGoogleに入って1年になります。ほんとにあっという間に2015年が終わった感じです。「Developer Advocate」という肩書のエバンジェリストのような、エバンジェリストじゃないような仕事をしています。
僕の仕事の一つが、今年の5月にbetaとして公開した「[Cloud Bigtable](https://cloud.google.com/bigtable/)」のリリース支援です。Cloud Bigtable というのは、Googleの有名な大規模分散データベースの「Bigtable」をGoogleの開発者以外でも使えるようにしたサービス。このBigtableはGoogleのサービス、検索、Maps、Gmailなど、ほとんどのサービスを支えています。

Bigtableは分散データベースでスケーラービリティが高い...というところまではわかりやすいのですが、実際にどれだけスケールできるのかはGoogleの外ではあまり知られていないと思います。

Googleの検索インデクスは [100,000,000 Gb 以上の容量があります](https://www.google.com/insidesearch/howsearchworks/crawling-indexing.html)。つまり **100 Petabyte** ！　しかも実際の内部的な数字はこれよりかなり大きく(おそらく何倍か)。100Petabyteは現在公開されているひかえめな数字に過ぎません。

GoogleではBigtableを約10年前から使っていますが、2006年にその設計について書かれた[ホワイトペーパー](http://research.google.com/archive/bigtable.html)を公開しました。このホワイトペーパーの著者はGoogleの**レジェンド級開発者** Jeff Dean, Sanjay Ghemawat, Andrew Fikes など、自分と同じ会社に勤めていると思えない超人たち。このホワイトペーパーからオープンソースのBigDataエコシステムが生まれました。具体的には、MapReduceを実装するHadoopや、GFS(Google File System)をインスパイアしたHDFSがIT産業を変えています。Bigtableの設計を元にしたHBaseも利用者を集めました。

## Bigtableのパフォーマンス

Googleでは（当然のことながら）検索結果をものすごい速いスピードでユーザーに返さないといけません。Bigtableが遅いとGoogleはお金いくら損しちゃうのかな……1時間で検索結果が1秒遅くなったら、私の1年分の給料がぶっ飛んでしまうのが想像できます。

そのために、Bigtableはかなり効率化されています。例えば、Bigtableクラスターと同じリージョンにあるGCEのインスタンスから書き込みも、読み込みも、せいぜい10ms以内に返ってくる。これは速い。しかも、p99 (99%のリクエストは10ms以内に返ってくる)です。とんでもない速い。これはクライアントから計測したネットワーク通信を含んだレイテンシー。サーバーから計測すると6msになります。

そしてコストパフォマンスも高い。書き込みスループットで考えると MB/s per $ はHBaseやCassandraの倍以上です。

[![Cloud Bigtable Performance](/assets/images/746/big%20table%205-6%20-%20GCP.png)](/assets/images/746/big%20table%205-6%20-%20GCP.png)

ちなみに、以下のグラフはリアルタイムのパフォーマンスです。僕が作ったデモアプリで作成しています。上のグラフはリクエスト数、下のグラフはレイテンシー（黒い線がp50 、青い線がp99）です。1.5万 QPS (query per second)の状態で、レイテンシーのp99が大体10ms以内 なのがわかります。

[![Cloud Bigtable Demo](/assets/images/746/demo.png)](/assets/images/746/demo.png)

## Bigtableの設計

BigtableはNoSQLの概念を人気にさせたと言われています。でもNoSQLはその幅が広いので、Bigtableがどんな設計になっているのかを説明しましょう。

BigtableはいわゆるKey/Valueデータベースですが、単純なKey/Valueデータベースにはないいくつか特殊な機能を持っています。
まずは、一つのキーに複数の値を持つ機能があります。これはRDBMSと同じようなコラムとして表現されるけど、RDBMSと違ってテーブルスキーマがなく、rowデータに含まれているコラムがrowごとに変わってもよいのです。図にすると、

![BigTable rows](/assets/images/746/rows.png)

rowもキーによってソートされているので、rowキーを指定してスキャンができます。しかしそれぞれのコラムに入っているデータでのクエリーやスキャンができません。RDBMS的に言うとprimary key indexがあるけど、secondary indexがない、ということですね。

![BigTable scan](/assets/images/746/scan.png)

row間のトランザクションはないけど、一つのrowに含まれているコラムに対して、書き込みの整合性はあります。

## 技術を秘密にする罠

GoogleはMapReduceやBigtableの**技術**をホワイトペーパーとして公開しましたが、その**コード**は公開しませんでした。
その状況でOSSの実装が出てきたけれど、そこには当然Googleのノウハウが使われておらず、GoogleがMapReduceやBigtableほどの性能がありません。

最近のGoogleは、OSSやIT産業にノウハウやその技術を貢献できるように、もっとOSSやAPIを作ろうという傾向があります。これは最近公開した [Kubernetes](http://kubernetes.io/)や、[Tensorflow](http://tensorflow.io/)で具体的に実現しています。
ただ、Bigtableに関しては時すでに遅しなので、技術的に一番近いHBase 互換のAPIをBigtagleで提供することになりました。つまり、HBaseを使っていた開発者はコードを変えずにそのままBigtableを使えるし、Bigtableにベンダーロックされることもありません。

## HBase API

HBaseネィティブAPIは割とよく出来てきて、データの読み書きが簡単です。 (Javaしかないのは私的には悲しいけどw)

たとえばこんな感じでConnectionを作って、一つのRowを取得できます。

```java
try {
    Connection connection  = ConnectionFactory.createConnection();
    try {
        Table table = connection.getTable(TableName.valueOf(tableName));

        // rowIdをもとにGetリクエストを作成して、テーブルにリクエストを実行
        Result result = table.get(new Get("rowId".getBytes()));

        // 結果を回して、それぞれのコラムと値をstdoutに出力
        for (Cell cell : result.listCells()) {
            String row = new String(CellUtil.cloneRow(cell));
            String family = new String(CellUtil.cloneFamily(cell));
            String column = new String(CellUtil.cloneQualifier(cell));
            String value = new String(CellUtil.cloneValue(cell));
            long timestamp = cell.getTimestamp();
            System.out.printf("%-20s column=%s:%s, timestamp=%s, value=%s\n", row, family, column, timestamp, value);
        }
    } finally {
        // 最後にコネクションを閉じる
        connection.close();
    }
} catch (IOException e) {
    e.printStackTrace();
}
```

Putはこんな感じ

```java
// Putリクエストを作成
Put put = new Put(Bytes.toBytes(rowId));

put.addColumn(Bytes.toBytes(columnFamily), Bytes.toBytes(column), Bytes.toBytes(value));
// 複数のコラムを一発でputできる
// put.addColumn(Bytes.toBytes(columnFamily), Bytes.toBytes(column), Bytes.toBytes(value));

// テーブルにリクエストを実行
table.put(put);
```

Scanはこういうふうにできます。

```java
// Create a new Scan instance.
Scan scan = new Scan();

// スキャンのフィルターがいくつかあります。
scan.setFilter(new SingleColumnValueFilter(columnFamily, columnName, CompareFilter.CompareOp.EQUAL, "mycolumn"));

ResultScanner resultScanner = table.getScanner(scan);

// スキャンのrowを回す
for (Result result : resultScanner) {
    // rowの中のコラムと値を回す
    for (Cell cell : result.listCells()) {
        // 結果を出力する
        String row = new String(CellUtil.cloneRow(cell));
        String family = new String(CellUtil.cloneFamily(cell));
        String column = new String(CellUtil.cloneQualifier(cell));
        String value = new String(CellUtil.cloneValue(cell));
        long timestamp = cell.getTimestamp();
        System.out.printf("%-20s column=%s:%s, timestamp=%s, value=%s\n", row, family, column, timestamp, value);
    }
}
```

## Bigtableのこれから

Cloud Bigtableは現在betaで、来年GA (一般公開)するように頑張っています。まず安定性にフォーカスして、GAのあとに新しい機能や改善にフォーカスすることになるでしょう。

Betaの間は誰でも使えるので、[ぜひ試してみてください](https://cloud.google.com/bigtable/)。
