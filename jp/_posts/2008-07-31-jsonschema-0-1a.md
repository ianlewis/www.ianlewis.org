---
layout: post
title: "jsonschema ヴァリデーター 0.1a"
date: 2008-07-31 15:29:07 +0000
permalink: /jp/jsonschema-0-1a
blog: jp
tags: projects python json jsonschema
render_with_liquid: false
locale: ja
---

昨日、[JSONSchema](http://tinyurl.com/32qd4v)　ヴァリデーターを漸くリリースしました。XML Schemaと同じようなJSONSchemaはJSON文書の構造が正しいかどうかを検証するための文書。さらに、jsonschemaヴァリデーターはそのJSONSchema文書に従ってJSON文書が正しいかどうかを検証するPythonモジュール。[JSON Schema Proposal Second Draft](http://groups.google.com/group/json-schema/web/json-schema-proposal---second-draft)を基にしています。

ソースコードはこちらからダウンロードできます: [`jsonschema-0.1a.tar.gz`](http://jsonschema.googlecode.com/files/jsonschema-0.1a.tar.gz)

ドキュメンテーションはこちら: [jsonschema (version `0.1a`) documentation](http://hg.monologista.jp/json-schema/raw-file/41132f2b2b57/docs/jsonschema.html)（[日本語 README](http://hg.monologista.jp/json-schema/raw-file/41132f2b2b57/README.ja.utf8.txt)）

JSONSchemaはJSON文書の構造を検証するために作られている。JSON文書の構造、データ形式を定義することが出来る。例えば、連絡先のデータがあるとしましょう。

```json
{
    "name": "Ian Lewis",
    "email": "IanLewis@xyz.com",
    "address": "123 Main St.",
    "phone": "080-1942-9494"
}
```

その文書をJSONSchemaで定義すると、以下のようのJSONSchemaが出る

```json
{
  "type":"object",
  "properties":{
    "name": {"type":"string"},
    "age": {"type":"int", "optional":True},
    "email": {
      "type":"string",
      "pattern":"^[A-Za-z0-9][A-Za-z0-9\.]*@([A-Za-z0-9]+\.)+[A-Za-z0-9]+$"
    },
    "address": {"type":"string"},
    "phone": {"type":"string"}
  }
}
```

さらに、以下の [Python](http://www.python.org/) コードでこのJSON文書は当てるかどうかを検証するこどができる。

```python
import jsonschema, simplejson

data = """{
  "name": "Ian Lewis",
  "email": "IanLewis@xyz.com",
  "address": "123 Main St.",
  "phone": "080-1942-9494"
}"""

schema = """{
  "type":"object",
  "properties":{
    "name": {"type":"string"},
    "age": {"type":"int", "optional":True},
    "email": {
      "type":"string",
      "pattern":"^[A-Za-z0-9][A-Za-z0-9\.]*@([A-Za-z0-9]+\.)+[A-Za-z0-9]+$"
    },
    "address": {"type":"string"},
    "phone": {"type":"string"}
  }
}"""

x = simplejson.loads(data)
s = simplesjson.loads(schema)
jsonschema.validate(x,s)
```

JSONSchemaに拡張プロパティを付けることや、デフォルト検証処理を変更することができるので、
とても柔軟なモジュールだと思っています (自分が作ったことについて言えるかなぁ ^^; )
。僕自身は[GAE](http://code.google.com/appengine/)のプロジェクトで使うつもりだし、
皆さんのご意見を是非聞かせてもらいたいと思います。
