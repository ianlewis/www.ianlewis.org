---
layout: post
title: "Redmine で reStructuredText を使う方法"
date: 2012-04-16 13:00:00 +0000
permalink: /jp/redmine-restructuredtext
blog: jp
tags: python programming tech work
render_with_liquid: false
locale: ja
---

<!-- TODO(#339): Add alt text to images. -->
<!-- markdownlint-disable MD045 -->

我々BeProudのRedmineのWikiやチケットの説明文やチケットのコメント文にはreStructuredTextを使っている。RedmineのデフォルトのTextileはPythonが好きな弊社で使うのは以ての外。なので、reSTを使うようにした。そして、生のreSTしか使わなければ、出来ることが少ないので、`blockdiag`や、コードの構文ハイライト（Pygments）を使っている。

Redmineはテキストフォマッターを入れ換えるように作られている。プラグインを入れるとWikiやチケットの内容のフォーマットを変えることができます。BeProudではRedmine reStructuredText Formatterの`RbST`/`docutils`ブランチを使っている。

[`http://glacialis.postmodo.com/posts/zyd1ig`](http://glacialis.postmodo.com/posts/zyd1ig)

## インストール

> ここには説明しないんですけど、Redmine を先にインストールする必要があります。

まずは、Redmine reStructuredText Formatterプラグインを入れる。その為、`RbST`ライブラリをインストールする必要がある。

## `RbST`

`RbST`の`docutils`バージョンはデータをフォーマットする時に、Pythonプロセスを実行して、そのプログラムの標準入力にreSTコンテンツを送信して、標準出力でHTMLコンテンツを受け取ると言う形になっている。

![image](/assets/images/673/redmine-rest.png)

```shell
gem install RbST
```

`RbST`も日本語をレンダーする場合のバグがありますので、修正する必要があります。 (興味ある人は僕の[GitHub](https://github.com/IanLewis/rbst) を見ててください)

````shell
cd /path/to/ruby/gems/RbST-0.1.3/lib/rst2parts
vim rst2html.py
```

最後のほうに、データを print する行があって、それを修正します。

```python
if __name__ == '__main__':
    try:
        output = main()
        if output:
            # ここを修正して、 print ではなくて、sys.stdout.write()にする
            sys.stdout.write(output)
    except Exception, e:
        sys.stdout.write('<strong style="color:red">Error Parsing ReSt: %r</strong>' % e)
````

そして、Redmine のインストールディレクトリに移動して、プラグインをインストール (Pythonと`docutils`もインストールしておいてください。

```shell
cd path/to/redmine
script/plugin install git://github.com/alphabetum/redmine_restructuredtext_formatter.git
```

そうしたら、Redmineを起動・再起動します。

そうすると、Redmineの「管理」=\>「設定」に行くと、フォーマッターとして、reST
を選択できます。該当の設定は「ッテキスト書式」と書いています。reSTをレンダーする度に、外部
Python プロセスをたたくので、次のチェックボックスで、レンダーを出力をキャシューするように設定しておいてください。

![](/assets/images/673/settings.png)

設定画面でせっていし後にWikiやチケットにreSTを書けばちゃんと表示されます。

reSTでWiki 書きましょう

![](/assets/images/673/rest-input.png)

ちゃんと表示されます。

![](/assets/images/673/html-rest.png)

Textile 書かなくてもよくて、気持ちいいですね！

## Wikiリンク

デフォルトでリンクを書く時に、そのまま表示するURL書かないといけないのでWikiで簡単にリンク書けるようにしょう。

`RbST`のインストール先の`gems`ディレクトリに行って、`rst2html.py`を修正しよう

```shell
cd /path/to/ruby/gems/RbST-0.1.3/lib/rst2parts
vim rst2html.py
```

そして、下記のコードを加えましょう。 ([`moinmoin`](http://moinmo.in/)からコピーした。

```python
from docutils.writers.html4css1 import Writer

class WikiWriter(Writer):
    def __init__(self, *args, **kwargs):
        Writer.__init__(self, *args, **kwargs)
        self.unknown_reference_resolvers = [self.wiki_resolver]
        self.nodes = []
    def wiki_resolver(self, node):
        """
            Normally an unknown reference would be an error in an reST document.
            However, this is how new documents are created in the wiki. This
            passes on unknown references to eventually be handled by
            MoinMoin.
        """
        if hasattr(node, 'indirect_reference_name'):
            node['refuri'] = node.indirect_reference_name
        elif (len(node['ids']) != 0):
            # If the node has an id then it's probably an internal link. Let
            # docutils generate an error.
            return False
        elif node.hasattr('name'):
            node['refuri'] = node['name']
        else:
            node['refuri'] = node['refname']
        del node['refname']
        if hasattr(self, 'nodes'):
            node.resolved = 1
            self.nodes.append(node)
            return True
        else:
            return False
    wiki_resolver.priority = 1
```

レンダーする時に、`WikiWriter`を利用するように、`main()`関数も修正しよう。

```python
def main():
    #ここは修正して、writerの引数を追加
    return transform(writer=WikiWriter(), part='html_body')
```

それで、Wikiでこういうように他のWikiページへのリンクを作ることができる。

```rst
* これは「リンク」というページの `リンク`_ です。
* リンクのテキストが異なる場合は、`こう書く <リンク>`_
```

それ以外のリンクの使い方は [はやわかり reStructuredText](http://www.planewave.org/translations/rst/quickref.html#hyperlink-targets)を参考にしてください。

> 外部 Python プログラムを叩いてるだけなのでRedmineのパスなどがレンダーする時にわかる用がないので
> 相対パスを吐き出すようにしているだけ。従って、プレビューする時などパスが違うのでレンダーするリンクが
> おかしくなる。それだけは我慢してください (´･ω･\`)

## コードブロック

標準のreSTじゃつまらないので、コードハイライトできるようにしょう。まずはライブラリをインストールするので、virtualenv を作ろう

```shell
cd /path/to/ruby/gems/RbST-0.1.3/lib/rst2parts
virtualenv venv
```

次はPygmentsをvirtualenvにインストールする

```shell
pip install pygments -E venv
```

そして、`rst2html.py`で virtualenv を使うようにしよう。`rst2html.py`の上にこのコードを加えましょう

```python
import site

site.addsitedir(os.path.join(os.path.dirname(__file__), 'venv', 'lib', 'python2.7', 'site-packages'))
```

> Python のバージョンによってパスが異なるので、ご注意を

`rst2html.py`を修正して、 `code-block`ディレクティブを追加する。

```python
from docutils import nodes
from docutils.parsers.rst import directives
from pygments import highlight
from pygments.formatters import HtmlFormatter
from pygments.lexers import get_lexer_by_name, TextLexer

############### code-block, sourcecode ##############

VARIANTS = {}

def pygments_directive(name, arguments, options, content, lineno,
                       content_offset, block_text, state, state_machine):
    try:
        lexer = get_lexer_by_name(arguments[0])
    except (ValueError, IndexError):
        # no lexer found - use the text one instead of an exception
        lexer = TextLexer()
    parsed = highlight(u"\n".join(content), lexer, HtmlFormatter(noclasses=True))
    return [nodes.raw("", parsed, format="html")]
pygments_directive.arguments = (0, 1, False)
pygments_directive.content = 1
pygments_directive.options = dict([(key, directives.flag) for key in VARIANTS])
directives.register_directive("sourcecode", pygments_directive)
directives.register_directive("code-block", pygments_directive)
```

そうすると、Wiki で code-block ディレクティブを使うと

```rst
.. code-block:: python

    class PythonRocks(object):
        """Python Rocks! を出力"""
        def rock(self):
            print "Python Rocks!"
```

ハイライトされたコードが書けます

![](/assets/images/673/highlight.png)

## まとめ

とにかく、Redmineは大変だから、だけか、Python版を作ってほしい！

それができるまでは、`rst2html.py`は普通のpythonプログラムなので、Pythonで対応出来る限り、何でもできます。実は僕達は[`blockdiag`](http://blockdiag.com/ja/blockdiag/index.html) もRedmineのWikiで書けます。[`seqdiag`](http://blockdiag.com/en/seqdiag/) もあって、可能性がいろいろあります。いろいろ試してみてください！

<!-- markdownlint-enable MD045 -->
