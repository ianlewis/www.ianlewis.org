---
layout: post
title: "Go! Appengine"
date: 2011-06-07 10:22:34 +0000
permalink: /jp/go-appengine
blog: jp
tags: appengine golang
render_with_liquid: false
---

<!-- textlint-disable rousseau -->

昨日、 [Go\! 言語](http://golang.org/) の trusted tester 権限を頂いたので、以前に作っていた
[Guestbook](https://bitbucket.org/IanLewis/golang_guestbook) アプリを本番
Appengine にデプロイしてみた。

<http://golang-guestbook.ian-test-hr.appspot.com/>

結構シンプルなアプリだけど、いくつかのところのコードをピックアップして紹介しようと思います。

まずは、ログイン。 Google アカウントの認証を使っているのですが、こんな感じでできています。

```golang
c := appengine.NewContext(request)
current_user := user.Current(c)
if current_user == nil {
    login_url, _ := user.LoginURL(c, "/")
    http.Redirect(w, request, login_url, http.StatusFound)
    return
}
```

次はデータの読み込み。ここで Greeting エンティティのデータをクエリーで取得しています。 データを取得した後に GetAll()
メソッドで greetings というスライス (配列ポインター) に突っ込んでいます。

```golang
greetings := &[]Greeting{}
datastore.NewQuery("Greeting").
          Order("-Date").
          GetAll(c, greetings)
```

データの書き込みはこんな感じ。POST したデータを FormValue() メソッドで取得して、新しい Greeting struct
のインスタンスに突っ込んで、 datastore.Put() 関数で、データストアに新しいエンティティを書き込んでいます。
新しいデータを書き込むときに、 datastore.NewIncompleteKey() を使います。未確定キーオブジェクトで、
datastore.Put() は新しいキーを取得するかどうかを判断するみたいです。

```golang
body := request.FormValue("body")
if (len(body) > 0) {
    g := &Greeting{
        Body: body,
        AccountId: current_user.Id,
        AccountEmail: current_user.Email,
        Date: datastore.SecondsToTime(time.Seconds()),
    }
    datastore.Put(c, datastore.NewIncompleteKey("Greeting"), g)
}
```

次は template パッケージの使いを紹介します。html テンプレートをレンダーしてくれるパッケージです。こんな感じで書けます。 if
文の処理は section どいうタグで実現できます。 for は repeated section で実現できます。

```html
<body>
  <div style="float:right">
    {.section CurrentUser} {CurrentUser} <a href="{LoginUrl}">Sign Out</a>
    {.or}
    <a href="{LoginUrl}">Sign In</a>
    {.end}
  </div>

  <h1>Appengine Go! Guestbook <img src="/static/img/appengine-go.png" /></h1>
  <a href="https://bitbucket.org/IanLewis/golang_guestbook/">Source Code</a>
  <form action="/save" method="POST" style="margin-bottom: 50px">
    <div><textarea name="body" rows="10" cols="80"></textarea></div>
    <div><input type="submit" value="Save" /></div>
  </form>
  {.repeated section Greetings}
  <div>
    User: {AccountEmail|userName}<br />
    {Date|date}
    <p style="padding-left:10px">{Body|html}</p>
  </div>
  {.end}

  <div style="text-align:center"></div>
</body>
```

デートの表示フォーマットを変更するのに、データフォーマッターという機能があります。 `{{ hoge|fuga }}` みたいに、バーで hoge
データを fuga フォーマッターでデータ変更ができる。 HTML をエスケープする `html`
というフォーマッターが標準にあります。上に Body
データをエスケープしています。

他のフォーマッターはこんな感じで登録できます。テンプレートを解析するときに、 FormatterMap オブジェクトを渡してあげます。

```golang
func userNameFormatter(wr io.Writer, formatter string, data ...interface{}) {
    for _, item := range data {
        s, _ := item.(string)
        splits := strings.Split(s, "@", 2)
        fmt.Fprint(wr, splits[0][0:len(splits[0])/2] + "...@" + splits[1])
    }
}

func dateFormatter(wr io.Writer, formatter string, data ...interface{}) {
    for _, item := range data {
        date, _ := item.(datastore.Time)
        fmt.Fprintf(wr, TimeToTime(date).Format("2006-01-02 15:04:05"))
    }
}

// ...

fm := template.FormatterMap{}
fm["date"] = dateFormatter
fm["userName"] = userNameFormatter
t, _ := template.ParseFile("templates/base.html", fm)
```

テンプレートをレンダーするときに、 struct データをテンプレートに渡します。 golang は Python
とかより固い言語なので、stuct
の変数型を全部定義しないといけません。面倒くさいからインラインでやっています。

```golang
w.Header().Set("Content-Type", "text/html")
err := t.Execute(w, struct{
     CurrentUser *user.User
     Greetings *[]Greeting
     LoginUrl string
}{
    CurrentUser: current_user,
    Greetings: greetings,
    LoginUrl: login_url,
})
```

本番 Appengine で見るとアプリのインスタンスレイテンシーは、最大50ms、 平均は大体
20ms。データストアからデータ取得しているにも関わらず、結構早いなと思いました。スピンアップ時間も全然気付きませんでした。もしかして、もっと大きいアプリを作ると変わりますが、
golang は appengine に動かすのが結構面白いかなと思った。

それでは、みんな、 [Guestbook
でメッセージ残してください！](http://golang-guestbook.ian-test-hr.appspot.com/)

<!-- textlint-enable rousseau -->
