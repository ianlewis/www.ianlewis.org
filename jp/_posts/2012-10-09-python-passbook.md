---
layout: post
title: "Python でPassbookファイルを作成する"
date: 2012-10-09 10:25:51 +0000
permalink: /jp/python-passbook
blog: jp
tags: python ios passbook
render_with_liquid: false
locale: ja
---

最近、iPhoneのiOS6でPassbookという機能が出ました。Passbookはイベントのチケットや、飛行機や船の搭乗券や、クーポンや、ポイントカードを管理出来る地味に便利なアプリ。

僕は興味があって、Pythonでどう作るかを調べてみたので、ここで共有しようと思っている。Passbookはパスの更新の仕組みもありますが、とりあえず、パスを作るとところまで説明しようと。まずは、Appleの日本語ドキュメントの[「Passbook プログラミングガイド」](https://developer.apple.com/jp/devcenter/ios/library/japanese.html)をざっと見たほうがいいかもしれない。

基礎の仕組み的に、Passbookはサーバーからダウンロードしたzipファイル。パスの内容は`pass.json`というJSONファイルの中に入っている。中身のファイル毎にsha1ハッシュを取って、`manifest.json`というファイルに書いている。そして、`manifest.json`の中身の署名を作成して、`signature`というファイルに入れます。

## まずは準備

この準備は一番面倒くさい部分なんだけど、結構はまりそうなので、丁寧に説明する。

署名を作るために、Appleのルート証明書が必要。「Passbook プログラミングガイド」の「パスタイプIDを要求する」というところに書いていますが、情報が少ないので、これでやり方が絶対わからないから、わかりやすく説明する。まずは後で使うキーペア(公開鍵、秘密鍵のペア)を作ります。MacのKeychain Accessでキーペアを作成する。

キーチェーンアクセスメニューから、「証明書アシスタント」の「証明局に証明書を要求...」を選ぶ。情報を入力したら、「ディスクに保存」を選んで、作成する。それで、CSRを保存する。

Pass Type IDを要求する。まずは、[iOS Dev Center](https://developer.apple.com/devcenter/ios/index.action)にログインする。

そして、右側の「iOS Provisioning Portal」に移動して、左側の「Pass Type IDs」をクリックする。

[![](/assets/images/681/provisioning_portal_thumbnail.png)](/assets/images/681/provisioning_portal_big.png)
[![](/assets/images/681/pass_type_ids_thumbnail.png)](/assets/images/681/pass_type_ids_big.png)

Pass Type IDs画面で、「New Pass Type ID」ボタンをクリックしてください。

[![](/assets/images/681/new_pass_type_small.png)](/assets/images/681/new_pass_type_big.png)

これで適当なDescription と Identifierを入力してください。Identifierは`pass.<ドメイン名>.<パス名>`という風に設定するのがおすすめ。「Submit」を押したら、ファイルアップロードの画面が出ます。ここに自分が作った公開鍵をアップします。

アップしたら、Apple側でサインした証明書をダウンロードします。このファイルを保存して、ダブルクリックすることで、キーチェーンアシスタントにインポートします。

[![](/assets/images/681/install_cert_small.png)](/assets/images/681/install_cert_big.png)

次は、[Apple のルート証明書](http://developer.apple.com/certificationauthority/AppleWWDRCA.cer)をダウンロードして、キーチェーンアシスタントにインポートします。

その手順が終わったら、Keychain Accessから鍵を.p12ファイルとして、エクスポートする(以降、cert.p12というファイル名とする)。エクスポートするときに、以前に作った秘密鍵ではなく、「Pass Type ID: ほげほげ」という証明書を選択して、右クリックして、「ほげほげを書き出す」というオプションを選びます。ここにパスワードを指定出来ます。パスワードを後で使いますので、覚えておいてください。

[![](/assets/images/681/export_cert_small.png)](/assets/images/681/export_cert_big.png)

次に、「Apple Developer Relations Certification Authority」の証明書を`pem`ファイルとして書きだす。(これ以降、`AppleWWDRCA.pem`のファイル名とする)

書きだした`p12`ファイルに対して、下記のコマンドを実行して、証明書(`certificate.pem`)と公開鍵(`key.pem`)を書き出す。ここに`p12`ファイルのパスワードを使います。`pem`ファイルのパスワードを指定できます。`pem`ファイルのパスワードは後で使うので、覚えておいてください。

```text
$ openssl pkcs12 -in cert.p12 -clcerts -nokeys -out certificate.pem
...
$ openssl pkcs12 -in cert.p12 -nocerts -out key.pem
...
```

この３つのファイル`AppleWWDRCA.pem`、`certificate.pem`、`key.pem`を後で使います。

## ライブラリー

Passbookの`signature`ファイルを作成するために、M2Crypto というライブラリが必要です。Python virtualenvを作って、インストールします。

```text
$ mkvirtualenv passbook-test
...
(passbook-test)
$ pip install M2Crypto
....
```

やっと、準備完了。ハァハァ

## 漸くコーディングできる

まずは、`pass.json`ファイルのデータを作成する。

```python
passinfo = json.dumps({
     'description': 'Acme Airlines',
     'formatVersion': 1,
     'organizationName': 'Acme Airlines',
     'passTypeIdentifier': 'pass.example.com.examplepass',
     'serialNumber': "123", # パスのユニークなID
     'teamIdentifier': "ABCDE12345", # Apple のチームID
     'backgroundColor': 'rgb(255,255,255)',
     'logoText': 'Acme Airlines',
     'locations': [],
     'barcode': {
         'format': 'PKBarcodeFormatQR',
         'message': "http://example.com/",
         'messageEncoding': 'iso-8859-1',
     },
     'boardingPass': {
         'transitType': 'PKTransitTypeAir',
         "primaryFields": [
             {
                 "key" : "origin",
                 "label" : "Tokyo",
                 "value" : "NRT"
             },
             {
                 "key" : "destination",
                 "label" : "New York",
                 "value" : "NYC"
             }
         ],
     },
 })
```

次に、画像データを読み込む。僕は[`PHP-PKPass`](https://github.com/tschoffelen/PHP-PKPass/tree/master/images)のexampleの画像を使いました。

```python
filepaths = [
    ('logo.png', os.path.join('img', 'logo.png')),
    ('icon.png', os.path.join('img', 'icon.png')),
    ('icon@2x.png', os.path.join('img', 'icon@2x.png')),
]

fileinfo = []
for name, path in filepaths:
    with open(path, "rb") as fd:
        fileinfo.append(name, fd.read())
```

次に、`manifest.json`を作成します。

```python
manifest = {
    'pass.json': hashlib.sha1(passinfo).hexdigest(),
}
for filename, filedata in fileinfo:
    manifest[filename] = hashlib.sha1(filedata).hexdigest()

manifest = json.dumps(manifest)
```

次に、`signature`ファイルを作成する。ここに、`AppleWWDRCA.pem`、`key.pem`、`certificate.pem`のパスを指定します。そして、証明書のパスワードをここに指定します。

```python
smime = SMIME.SMIME()
#we need to attach wwdr cert as X509
wwdrcert = X509.load_cert('AppleWWDRCA.pem')
stack = X509_Stack()
stack.push(wwdrcert)
smime.set_x509_stack(stack)

# 公開鍵、証明書、パスワードを使います。
smime.load_key('key.pem', 'certificate.pem', callback=lambda p: 'password')
pk7 = smime.sign(SMIME.BIO.MemoryBuffer(manifest), flags=SMIME.PKCS7_DETACHED | SMIME.PKCS7_BINARY)

der = SMIME.BIO.MemoryBuffer()
pk7.write_der(der)

signature = der.getvalue()
```

漸く最後に、zip ファイルを作成します。

```python
zipfileobj = StringIO()
zf = zipfile.ZipFile(zipfileobj, 'w')
zf.writestr('signature', signature)
zf.writestr('manifest.json', manifest)
zf.writestr('pass.json', passinfo)
for filename, filedata in fileinfo:
    zf.writestr(filename, filedata)
zf.close()

zipfiledata = zipfileobj.getvalue()
```

iPhone のブラウザに渡すときに、`application/vnd.apple.pkpass`というコンテントタイプを指定しないといけない。僕はDjango をよく使うので、この例をDjangoで書きますが、どのフレームワークでも、出来るはずです。

```python
response = HttpResponse(
    content=zipfiledata,
    content_type='application/vnd.apple.pkpass',
)
response['Pragma'] = 'no-cache'
response['Content-Disposition'] = 'attachment; filename=pass.pkpass'
```

これで、zipファイルがダウンロードできて、iPhoneで見れるはず。

![](/assets/images/681/passbook_big.png)
