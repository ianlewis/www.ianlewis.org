---
layout: post
title: "arduino で音楽を流す HTTP サーバー"
date: 2012-10-28 09:56:40 +0000
permalink: /jp/arduino-http
blog: jp
tags: tech programming
render_with_liquid: false
locale: ja
---

今週末のPython温泉で、最近買った、Arduinoを初めて触った。[Arduino+Pythonハッキング勉強会](http://connpass.com/event/1107/)の[資料](http://kitagami.org/Study/arduinopy20120917.html)を見て、何か同じようなもの作れないかと思った。

Starter Kitを買ったので、Arduinoだけじゃなくて、いろなものが付いてきた。そのなかの一つはピエゾブザー。ブザーの動作を確認した後に、HTTPでbuzzerを操作できたらいいんじゃないかと思って、簡単なHTTP APIを作った。

サーバーは最近作った[`namake`](http://github.com/IanLewis/namake)ベースで、Arduinoとの通信はPySerialでシリアルUSB。音のピッチと長さ(ms)をHTTP `GET`パラメターで受け取って、Arduinoに流す。

シリアルUSBはバイト通信なので、普通な整数でも通信が結構面倒くさいです。下のサーバーで`struct`モジュールで`int`
データをバイナリに変換して、通信している「`pack_int`」.

```python
#:coding=utf-8:

import serial
import struct
from namake import Application, Response

def force_int(v, default=None):
    try:
        return int(v)
    except (ValueError, TypeError):
        return default

def pack_int(val):
    return struct.pack('I', val)

def buzz(request):
    pitch = force_int(request.GET.get('p'), 1000)
    duration = force_int(request.GET.get('d'), 200)

    # Validate
    if not (50 <= pitch <= 4000):
        return Response("50 < p < 4000", status=400)
    if not (0 <= duration <= 1000):
        return Response("0 <= d <= 1000", status=400)

    # Write pitch and duration to arduino.
    request.app.ser.write(pack_int(pitch))
    request.app.ser.write(pack_int(duration))

    # Wait for response.
    if request.app.ser.readline().strip() == "ok":
        return "OK"
    else:
        return "NG"

class BuzzApp(Application):
    def __init__(self):
        super(BuzzApp, self).__init__(__name__)
        self.ser = serial.Serial("/dev/ttyACM0")
        self.ser.baudrate = 115200
        self.ser.timeout = 1

app = BuzzApp()
app.add_route('/$', buzz)

if __name__ == '__main__':
    from namake.contrib.devserver import run_devserver
    run_devserver(app)
```

Arduino の方はこの感じ。ピエゾブザーを出力PIN 8 につながっていて、非常に簡単。

[![arduinoがピエゾブザーと繋がっています](/assets/images/682/2012-10-28_09.41.22_small.jpg)](/assets/images/682/2012-10-28_09.41.22_big.jpg)

Arduinoのコードは以下の通り。ArduinoのIDEで入力するコードは基本的にC++。２つの整数の８バイト(4バイトずつ)を受け取る。Arduinoが呼び出している`loop()`で`Serial.read()`して、`u_tag`の`union`データの埋めこむ。

8バイト読んだら、Arduinoの`tone()`関数を呼び出して、音を鳴らす。読み込み中の間に、組み込まれている LEDをデバグの為、電気をつく。

```cpp
// digital pin 2 has a pushbutton attached to it. Give it a name:
int LED1 = 13;

int i = -1;
union u_tag {
    byte b[8];
    struct {
        unsigned long pitch_val;
        unsigned long dur_val;
    };
} u;

void startRead() {
    u.pitch_val = 0;
    u.dur_val = 0;
    i = 0;
}

void finishRead() {
    i = -1;
}

// the setup routine runs once when you press reset:
void setup() {
  Serial.begin(115200);
  pinMode(LED1, OUTPUT);
}

// the loop routine runs over and over again forever:
void loop() {
    unsigned long pitch, dur;

    if (i != -1) {
        if (i < sizeof (union u_tag)) {
            if (Serial.available()) {
                u.b[i++] = Serial.read();
            }
        } else {
            pitch = u.pitch_val;
            dur = u.dur_val;

            if (pitch >= 50 && pitch <= 4000 && dur >= 0 && dur <= 1000) {
                tone(8, pitch, dur);
            }

            finishRead();
            delay(dur);
            digitalWrite(LED1, LOW);

            Serial.println("ok");
        }
    } else if (Serial.available()) {
        digitalWrite(LED1, HIGH);
        startRead();
    }
}
```

これで余裕で音楽鳴らせるべ！ってもりよしさんともりあがって、もりよしさんが JavaScript からHTTPで叩きまくった。

<iframe
    title="YouTube video player"
    src="https://www.youtube-nocookie.com/embed/9X_8mkjM06M?si=LxQf3TctQ-VFtMt-"
    class="youtube"
    allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share"
    allowfullscreen>
</iframe>
