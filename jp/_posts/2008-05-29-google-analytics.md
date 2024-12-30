---
layout: post
title: "モバイルサイトで Google Analytics"
date: 2008-05-29 16:46:49 +0000
permalink: /jp/google-analytics
blog: jp
tags: モバイル ソフトウエア開発 php javascript google analytics
render_with_liquid: false
---

<!-- textlint-disable rousseau -->

会社のモバイルサイトで、 [Google Analytics](http://www.google.com/analytics/ja-JP/)
のトラッキングを導入した。Google
Analyticsはブラウザーでいろな情報を集めてGoogleサーバに送るものなので、トラッキングをするには
JavaScriptが必要な部分がある。しかし、モバイルや、携帯は
JavaScriptに徐々に対応しようとしてると思うけど、現在はほとんど対応してない。なので、サーバ側でトラッキングするほうが標準。他の携帯向けのサイトもあるけども、そのサイトは大体、そのサイトのURLをお客さんに渡して、それで、お客さんがそのサイトに行ってトラッキングデータを記載して、それから、自分のサイトにリダイレクトするやつだから、嫌な部分がたくさんある。

一つははお客さんに自分のサイトじゃなくて、別のサイトの変なurlを渡すから、お客さんに嫌な気分をかける。二つ目はサイトに入る後にサイトの中にどんなページを見に行ってるかがトラッキングできない。もっとあるけど、結局はGoogle
Analyticsにした。

具体的に、Peter van der Graffっていう人の
[ブログ](http://www.vdgraaf.info/google-analytics-without-javascript.html)
から、PHPコードを写したけど、Peterさんの目的は僕の目的と違うらしい。彼は RSS
とか、ファイルダウンロードのトラッキングをする前提で、コードを書きましたから、携帯機種や、セッションや、ユーザ変数を記載してなかった。なので、Peterさんのコードを以下のコードに書き直した。セッションを渡して、USER_AGENTというHTTPヘーダを送る携帯の機種とかもちゃんと転送するようにした。

```php
$var_utmac=MOBILE_GOOGLE_ANALYTICS_CODE; //enter the new urchin code
$var_utmhn=WEB_DOMAIN; //enter your domain
$var_utmn=rand(1000000000,9999999999);//random request number
$var_cookie=$session; //cookie number
$var_random=rand(1000000000,2147483647); //number under 2147483647
$var_today=time(); //today
$var_referer=$_SERVER['HTTP_REFERER']; //referer url
$var_uservar=$storeinfo['storeid']; //enter your own user defined variable
$var_utmp=$_SERVER['REQUEST_URI']; // request uri

$urchinUrl='http://www.google-analytics.com/__utm.gif?utmwv=1&utmn='.$var_utmn.'&utmsr=-&utmsc=-&utmul=-&utmje=0&utmfl=-&utmdt=-&utmhn='.$var_utmhn.'&utmr='.$var_referer.'&utmp='.$var_utmp.'&utmac='.$var_utmac.'&utmcc=__utma%3D'.$var_cookie.'.'.$var_random.'.'.$var_today.'.'.$var_today.'.'.$var_today.'.2%3B%2B__utmb%3D'.$var_cookie.'%3B%2B__utmc%3D'.$var_cookie.'%3B%2B__utmz%3D'.$var_cookie.'.'.$var_today.'.2.2.utmccn%3D(direct)%7Cutmcsr%3D(direct)%7Cutmcmd%3D(none)%3B%2B__utmv%3D'.$var_cookie.'.'.$var_uservar.'%3B';

$header = '';

//Set the language to that of the client so analytics can track it.
if (!empty($_SERVER['HTTP_ACCEPT_LANGUAGE'])) {
  $header = 'Accept-language: '.$_SERVER['HTTP_ACCEPT_LANGUAGE'].'\r\n';
}
//Set the user agent to that of the client so analytics can track it.
if (!empty($_SERVER['HTTP_USER_AGENT'])) {
  $header = 'User-Agent: '.$_SERVER['HTTP_USER_AGENT'].'\r\n';
}

$opts = array(
  'http'=>array(
    'method'=>'GET',
    'header'=>$header
  )
);

$handle = fopen($urchinUrl, 'r', false, stream_context_create($opts));
$test = fgets($handle);
fclose($handle);
```

<!-- textlint-enable rousseau -->
