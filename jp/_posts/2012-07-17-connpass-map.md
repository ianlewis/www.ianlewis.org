---
layout: post
title: "connpass のイベントマップのマッシュアップを作って見た。"
date: 2012-07-17 13:00:00 +0000
permalink: /jp/connpass-map
blog: jp
---

最近、僕が作っているサイト、 [connpass](http://connpass.com/)
では、関西や、札幌のイベントが増えって来て、connpass
のイベントは東京意外、どのくらいあるか、どこにあるかが見たかったのがきっかけ。

connpass の API ではイベントに緯度と経度を簡単に取れるので、Google マップのマッシュアップは簡単に作れるのかた思って、
[作ってみました](http://connpass-map.ian-test-hr.appspot.com/) 。

URL: <http://connpass-map.ian-test-hr.appspot.com/>

Google Maps v3 はわりと簡単で、 [connpass
の検索API](http://connpass.com/about/api/) からデータを取得して、Google Maps
の上に表示するだけですが、イベントが地図の上に多い場合は、見づらいので、近いイベントをまとめたいと思った。イベントを纏めるには、
[google maps utility
library](https://code.google.com/p/google-maps-utility-library-v3/) の
MarkerClusterer を利用した。

データが終わるまで繰り返す処理もありますが、主なロジックはこんな感じです。AJAXでデータを取得して、MarkerCLusterer
のオブジェクトインスタンスにマーカー追加する。検索APIは最大100件しか返さないので、

``` javascript
var map = new google.maps.Map(document.getElementById("map_canvas"), {
  center: new google.maps.LatLng(36.738884,139.614258),
  zoom: 5,
  mapTypeId: google.maps.MapTypeId.ROADMAP
});
var mc = new MarkerClusterer(map, [], {
  gridSize: 50,
  maxZoom: 12
});

$.ajax({
  url: 'http://connpass.com/api/v1/event/',
  dataType: 'jsonp',
  jsonp: 'callback',
  data: {
    'start': start, 
    'count': count, 
  },
  success: function(data) {
    if (data.results_returned > 0) {
      console.log(data);
      if (data.events) {
        // Start getting next events
        get_events(start=start+100);

        // Add markers to the clusterer
        mc.addMarkers($.map(data.events, create_marker));
      }
    }
  }
});
}
```

表示はこんな感じになります。

![image](https://storage.googleapis.com/static.ianlewis.org/prod/img/680/connpass_map_big.png)

マーカーは
create\_marker()という関数で作れれている。マーカーにクリックすれば、ツールチップが出るためのコードがいろいろあって、ここにまとめた。

``` javascript
var activeInfoWindow;

function create_marker(event) {
  if (event.lat && event.lon) {
    var marker = new google.maps.Marker({
      position: new google.maps.LatLng(
        event.lat,
        event.lon
      ),
      title: event.title
    });
    marker.infowindow = new google.maps.InfoWindow({
        content: '<p><strong>' + event.title + '</strong></p>' +
        '<p>' + event.catch + '</p>' +
        '<p>参加者数: ' + (event.accepted + event.waiting) + (event.limit ? ('/' + event.limit) : '') + '</p>' +
        '<p>場所: ' + event.place + ' (' + event.address + ')</p>' +
        '<p>時間: ' + event.started_at + '</p>' +
        '<p>URL: <a href="' + event.event_url + '" target="_blank">' + event.event_url + '</a></p>'
    });
    google.maps.event.addListener(marker, 'click', function() {
      if ( activeInfoWindow == this.infowindow ) {
          return;
      }
      if ( activeInfoWindow ) {
          activeInfoWindow.close();
      }
      this.infowindow.open(map, this);
      activeInfoWindow = this.infowindow;
    });

    return marker;
  } else {
    return null;
  }
}
```

ツールチップはこんな感じです。

![image](https://storage.googleapis.com/static.ianlewis.org/prod/img/680/connpass_map_tooltip_big.png)

こういうのはわりと簡単に出来るので、これからもっと作ってみたいなと思っている。
