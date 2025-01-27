---
layout: post
title: "Google Analytics for Mobile Sites"
date: 2008-05-23 20:13:41 +0000
permalink: /en/google-analytics-for-mobile-sites
blog: en
tags: tech programming php javascript
render_with_liquid: false
---

I implemented tracking using [Google Analytics](http://www.google.com/analytics/) for my company's mobile sites using a technique described by Peter van der Graff on [his site](http://www.vdgraaf.info/google-analytics-without-javascript.html). The technique involves performing a GET to to an image on Google's server and passing it a bunch of options. Incidentally this is because JavaScript can perform gets of images but not gets for any other kinds of content (as an aside, this kind of protection seems usless since the server could return any kind of content in wants to the JavaScript even though the GET has an image in the url. Maybe someone could enlighten me).

Peter originally came up with the idea because he wanted to track hits to a RSS xml url (which also seemed strange to me since the rss aggregator could read it as many times as it wants and doesn't give much insight into the number of readers, but I digress), or to another type of file download (image, pdf, etc) which wouldn't trigger the JavaScript that Google uses for Analytics.

One important difference between his motives and mine were that I'm tracking hits to a mobile site. Doing analytics on the server side are important since most phones (in Japan at least) don't support JavaScript. I also, because of the differences in what I was doing, needed to make some changes to how his script worked. Since I'm not tracking downloads or rss hits, I care about things like sessions, language, and user agent (why Peter didn't also care about this I'm not sure).

So I modified his code as follows. I forward the language and user agent of the client to Google Analytics so that I can track these things properly. I also pass my own cookie number so that Google Analytics can aggregate page hits from the same user into a session. I also make use of the user var to track hits to different customer's web pages. The example is in PHP but it could be easily translated into another language.

_Note that, because of the use of stream contexts, this code will require a version of PHP >= 4.3.0._

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
