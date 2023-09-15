---
layout: post
title: "Androidで日本語入力 simeji の最新版をインストールしてみた"
date: 2009-06-07 21:34:26 +0000
permalink: /jp/simeji-installed
blog: jp
render_with_liquid: false
---

<p>最近参加してきた <a href="http://code.google.com/events/io/">Google I/O</a> でもらったAndroid 開発フォンはアメリカ型で日本語入力出来なかったので、Social IME <a href="http://www.adamrocker.com/blog/236/simeji_android_japanese_input.html">simeji</a>という入力メソッドをインストールしてみた。意外と簡単だった。Android Marketでsimejiが出てるけど、最新版ではなく、日本語キーボードがついてないバージョンです。インストールしたいのが<a href="http://www.adamrocker.com/blog/257/simeji-for-android-bell-input.html">これ</a>。</p>

<p><object classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000" codebase="http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=9,0,0,0" width="326px" height="504px" id="99" align="">
				<param name="allowFullScreen" value="true" />
				<param name="movie" value="http://www.adamrocker.com/blog/wp-content/uploads/2009/05/simeji_bell_input.swf" />
				<param name="menu" value="false" />

				<param name="scale" value="noscale" /><embed src="http://www.adamrocker.com/blog/wp-content/uploads/2009/05/simeji_bell_input.swf" enu="false" scale="noscale" allowFullScreen="true" width="326px" height="504px" name="99" align="" type="application/x-shockwave-flash" pluginspage="http://www.macromedia.com/go/getflashplayer"></embed></object></p>

<p><a href="http://www.android-unleashed.com/2008/11/howto-install-non-market-apk-apps-on.html">このブログ</a> によると、3rd partyをアプリをインストールするには SDK の toolsに入ってる adbアプリを使います。じゃ、まず、<a href="http://developer.android.com/sdk/1.5_r2/index.html">SDK 1.5</a> をインストールします。</p>

<p>SDKのインストールが簡単。自分のOSのSDKのzipを解凍しておしまい。でも、USBでつなぐには、ちょっと手続きが必要。<a href="http://developer.android.com/guide/developing/device.html">このページ</a>を読む。</p>

<p>Windowsの場合、ドライバが必要。USBをさしたら、新しいハードウエアウィザードが出てきて、SDKのusb_driver/x86の中にドライバを検索。Finish。</p>

<p>Linuxの場合はudevの設定は必要。僕はこれをやった。rootユーザで以下のコマンドを実行</p>

<p><pre>    echo "SUBSYSTEM==\"usb\", SYSFS{idVendor}==\"0bb4\", MODE=\"0666\"" > /etc/udev/rules.d/50-android.rules
    chmod a+rx /etc/udev/rules.d/50-android.rules</pre></p>

<p>chmodはいらないとは思うけど、一応ドキュメントに入ってるので、実行してみた。</p>

<p>Macの場合は特に何も必要がない。</p>

<p>そして、adbを実行する。初めて実行する時にdaemonを立ち上げるので、rootでやります。ユーザで普通に実行できるけど、usb読めないみたいので、デバイスを認識できない。</p>

<p><pre>    # ./adb devices
    * daemon not running. starting it now *
    * daemon started successfully *
    List of devices attached 
    HT95DLV00094	device</pre></p>

<p>おお、繋げてるね。それで、USBをマウントしないでください。マインド中の時にアプリをインストールできないみたいわけです。マウントしちゃった場合。携帯でアンマウントして、ストレージを無効にしないとダメみたいです。</p>

<p>後、もうひとつ。SettingsのApplicationsで、Unknown Sourcesを有効にする。インストールができたら、また無効にするのがいいかも。</p>

<p>さ、漸くインストールしてみよう。<a href="http://www.adamrocker.com/blog/257/simeji-for-android-bell-input.html">このページ</a>の<a href="http://www.adamrocker.com/blog/wp-content/uploads/2009/05/Simeji2.4.1.apk">APKパッケージ</a>をダウンロード。</p>

<p><pre># ./adb install /home/ian/tmp/simeji/Simeji2.4.1.apk 
1002 KB/s (212793 bytes in 0.207s)
	pkg: /data/local/tmp/Simeji2.4.1.apk
Success</pre></p>

<p>これでできた。SettingsのLocale &amp; Text でSimejiがでるはず。有効にしたら、上のビデオと同じようにsimejiのインプットメソッドが使える。iPhoneとほぼ同じで快適。こんな感じで</p>

<p><object width="425" height="344"><param name="movie" value="http://www.youtube.com/v/F9cmA70cSiA&hl=en&fs=1&"></param><param name="allowFullScreen" value="true"></param><param name="allowscriptaccess" value="always"></param><embed src="http://www.youtube.com/v/F9cmA70cSiA&hl=en&fs=1&" type="application/x-shockwave-flash" allowscriptaccess="always" allowfullscreen="true" width="425" height="344"></embed></object></p>