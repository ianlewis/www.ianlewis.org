---
layout: post
title: "Androidで日本語入力 simeji の最新版をインストールしてみた"
date: 2009-06-07 21:34:26 +0000
permalink: /jp/simeji-installed
blog: jp
tags: 日本語 simeji android
render_with_liquid: false
locale: ja
---

最近参加してきた [Google I/O](http://code.google.com/events/io/)
でもらったAndroid 開発フォンはアメリカ型で日本語入力出来なかったので、Social
IME [simeji](http://www.adamrocker.com/blog/236/simeji_android_japanese_input.html)
という入力メソッドをインストールしてみた。意外と簡単だった。Android
Marketでsimejiが出てるけど、最新版ではなく、日本語キーボードがついてないバージョンです。
インストールしたいのが[これ](http://www.adamrocker.com/blog/257/simeji-for-android-bell-input.html)。

[このブログ](http://www.android-unleashed.com/2008/11/howto-install-non-market-apk-apps-on.html") によると、3rd partyをアプリをインストールするには SDK の toolsに入ってる `adb`アプリを使います。じゃ、まず、[SDK 1.5](http://developer.android.com/sdk/1.5_r2/index.html) をインストールします。

SDKのインストールが簡単。自分のOSのSDKのzipを解凍しておしまい。でも、USBでつなぐには、ちょっと手続きが必要。
[このページ](http://developer.android.com/guide/developing/device.html)を読む。

Windowsの場合、ドライバが必要。USBをさしたら、新しいハードウエアウィザードが出てきて、
SDKのusb_driver/x86の中にドライバを検索。Finish。

Linuxの場合はudevの設定は必要。僕はこれをやった。rootユーザで以下のコマンドを実行

```shell
echo "SUBSYSTEM==\"usb\", SYSFS{idVendor}==\"0bb4\", MODE=\"0666\"" > /etc/udev/rules.d/50-android.rules
chmod a+rx /etc/udev/rules.d/50-android.rules
```

chmodはいらないとは思うけど、一応ドキュメントに入ってるので、実行してみた。

Macの場合は特に何も必要がない。

そして、`adb`を実行する。初めて実行する時にdaemonを立ち上げるので、rootでやります。ユーザで普通に実行できるけど、usb読めないみたいので、デバイスを認識できない。

```shell
# ./adb devices
* daemon not running. starting it now *
* daemon started successfully *
List of devices attached
HT95DLV00094  device
```

おお、繋げてるね。それで、USBをマウントしないでください。マインド中の時にアプリをインストールできないみたいわけです。
マウントしちゃった場合。携帯でアンマウントして、ストレージを無効にしないとダメみたいです。

後、もうひとつ。SettingsのApplicationsで、Unknown Sourcesを有効にする。インストールができたら、また無効にするのがいいかも。

さ、漸くインストールしてみよう。[このページ](http://www.adamrocker.com/blog/257/simeji-for-android-bell-input.html)の
[APKパッケージ](http://www.adamrocker.com/blog/wp-content/uploads/2009/05/Simeji2.4.1.apk)をダウンロード。

```shell
# ./adb install /home/ian/tmp/simeji/Simeji2.4.1.apk
1002 KB/s (212793 bytes in 0.207s)
  pkg: /data/local/tmp/Simeji2.4.1.apk
Success
```

これでできた。SettingsのLocale & Text でSimejiがでるはず。有効にしたら、上のビデオと同じようにsimejiのインプットメソッドが使える。
iPhoneとほぼ同じで快適。こんな感じで

<iframe width="560" height="315" src="https://www.youtube.com/embed/F9cmA70cSiA?si=kUAJZ3TKDXCLTiM0" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" allowfullscreen></iframe>
