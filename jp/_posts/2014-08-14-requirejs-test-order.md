---
layout: post
title: "プラグインなしで、require.js のテストの順番を保証する"
date: 2014-08-14 11:00:00 +0000
permalink: /jp/requirejs-test-order
blog: jp
tags: javascript require.js qunit
render_with_liquid: false
locale: ja
---

> ```text
> AMD の仕様では、「JSファイルのリストを順番通りに読み込み/実行する」
> ということができない。実際何が困ったかというと、分割した mocha
> テストケースを順番通りに実行できなくなったということ。結果は変わらなくても、
> 順番通りに実行されないと結果が見辛いし、問題が起こった時に発見が難しい。
> ```
>
> たしかにテストケースは毎回同じ順番に並べたいですね。
> 実はorderプラグインというのがあって簡単にロード順を制御できたのですが、RequireJS 2.0からはshimがあるんだからそれ使え！っていうことでサポートされなくなってしまいました。そのかわり、stepプラグインで若干設定が面倒ですが順番指定が可能です。テストの順番指定という用途であれば使えそう。

[http://teppeis.hatenablog.com/entry/re-requirejs](http://teppeis.hatenablog.com/entry/re-requirejs)

結構古い記事だけど、最近読んだので、僕がやっていることを書いてみようかなと思った。[Connpass](http://connpass.com/) では Require.js ばりばり使っていて、ユニットテストもそこそこ書いています。
mocha はいろいろAPIがよかったが、ブラウザ内のテストランナーがクソイので、僕達の場合は
QUnitを使っています。

テストの順番の問題は確かにあったけど、すぐ解決したので、特に面倒と感じてなかった。テストの
順番を保証するために、 `runTests()` というメソッドが付いているオブジェクトを
各テストモジュールで返しています。コードで書いてみるとこんな感じ。

```javascript
define(["jquery"], function ($) {
  return {
    runTests: function () {
      module("test/module");

      test("Test 1", function () {
        // Test Code here
      });

      test("Test 2", function () {
        // Test Code here
      });

      // ...
    },
  };
});
```

自分がやってないけど、もし、インデントが多くて、嫌って思う人は簡単にラッパー作れるはず。

```javascript
function testmod(mod) {
    return function() {
        var self = this;
        var depends = arguments;
        return {
            runTests: function() {
                mod.apply(self, depends);
            }
        }
    };
}

define(["jquery"], testmod(function($) {
    module("test/module");

    test(/* ... */);

    // ...
});
```

順番保証は、テストランナーの html ファイルでやっています。
それぞれのテストモジュールを読み込んで、 `runTests()`
を呼び出しています。こうすると、requireする順番で実行される。

```html
<script>
  QUnit.config.autostart = false;
  QUnit.config.testTimeout = 30000; // 30 Seconds

  require([
    // 順番保証
    "testmod1",
    "testmod2",
  ], function () {
    QUnit.start();

    for (i = 0; i < arguments.length; i++) {
      TestModule = arguments[i];
      TestModule.runTests();
    }
  });
</script>
```
