---
layout: post
title: "pytyrantはpython-tokyotyrantよりずっと速い"
date: 2010-01-16 20:27:37 +0000
permalink: /jp/tokyotyrantpython
blog: jp
tags: python tokyotyrant python-tokyotyrant pytyrant
render_with_liquid: false
locale: ja
---

[夏のPython温泉](http://d.hatena.ne.jp/Voluntas/20090516/1242482537) で [Bob様](http://bob.pythonmac.org/) が作ってくれたピュアーパイソンクライアント [pytyrant](http://code.google.com/p/pytyrant/) は [酒徳さん](http://d.hatena.ne.jp/perezvon/) の [python-tokyotyrant](http://code.google.com/p/python-tokyotyrant/) より速いという話を 聞いたと [moriyoshiさん](http://d.hatena.ne.jp/moriyoshi/) に言った。それで、moriyoshiさんはprofileのテストを作ってくれたけど、結果として、pytyrantとpython-tokyotyrantはあまり変わらないのが出た。</p>

```python
# http://www.smipple.net/snippet/moriyoshi/Benchmark%20code%20for%20pytyrant%20and%20python-tokyotyrant

from cProfile import run
import tokyotyrant
from pytyrant import Tyrant

class PyTyrantTest(object):
    def create_many(self):
        data = 'a' * self.size
        d = Tyrant.open('127.0.0.1', 1978)
        for i in xrange(self.num_attr):
            d.put("attr_%s" % i, data)
        d.close()

    def delete_all_stupid(self):
        d = Tyrant.open('127.0.0.1', 1978)
        for i in xrange(self.num_attr):
            d.out("attr_%s" % i)
        d.close()

    def delete_all(self):
        d = Tyrant.open('127.0.0.1', 1978)
        d.vanish()
        d.close()

class PyTokyoTyrantTest(object):
    def create_many(self):
        data = 'a' * self.size
        d = tokyotyrant.open('127.0.0.1', 1978)
        for i in xrange(self.num_attr):
            d.put("attr_%s" % i, data)
        d.close()

    def delete_all_stupid(self):
        d = tokyotyrant.open('127.0.0.1', 1978)
        for i in xrange(self.num_attr):
            d.out("attr_%s" % i)
        d.close()

    def delete_all(self):
        d = tokyotyrant.open('127.0.0.1', 1978)
        d.vanish()
        d.close()

def doit(suite, **kwarg):
    s = suite()
    for k, v in kwarg.iteritems():
        setattr(s, k, v)
    s.create_many()
    s.delete_all_stupid()
    s.create_many()
    s.delete_all_stupid()

run('doit(PyTyrantTest, size=10, num_attr=10000)')
run('doit(PyTokyoTyrantTest, size=10, num_attr=10000)')

run('doit(PyTyrantTest, size=100, num_attr=50000)')
run('doit(PyTokyoTyrantTest, size=100, num_attr=50000)')
```

でも、このコードは一つのスレッドでテストしている。複数のクライアントが同時に接続している場合はどうかと思って、今日テストを作ってみた。

```python
# http://www.smipple.net/snippet/IanLewis/Multi-client%20benchmark%20for%20python-tokyotyrant%20and%20pytyrant

import tokyotyrant
from pytyrant import Tyrant
import threading
import time

class PyTyrantTest(object):
    def create_many(self):
        data = 'a' * self.size
        d = Tyrant.open('127.0.0.1', 1978)
        for i in xrange(self.start, self.stop):
            d.put("attr_%s" % i, data)
        d.close()

    def delete_all_stupid(self):
        d = Tyrant.open('127.0.0.1', 1978)
        for i in xrange(self.start, self.stop):
            d.out("attr_%s" % i)
        d.close()

    def delete_all(self):
        d = Tyrant.open('127.0.0.1', 1978)
        d.vanish()
        d.close()

class PyTokyoTyrantTest(object):
    def create_many(self):
        data = 'a' * self.size
        d = tokyotyrant.open('127.0.0.1', 1978)
        for i in xrange(self.start, self.stop):
            d.put("attr_%s" % i, data)
        d.close()

    def delete_all_stupid(self):
        d = tokyotyrant.open('127.0.0.1', 1978)
        for i in xrange(self.start, self.stop):
            d.out("attr_%s" % i)
        d.close()

    def delete_all(self):
        d = tokyotyrant.open('127.0.0.1', 1978)
        d.vanish()
        d.close()

class Client(threading.Thread):
    def __init__(self, suite, **kwarg):
        self.suite = suite
        self.kwarg = kwarg
        super(Client,self).__init__()

    def run(self):
        s = self.suite()
        for k, v in self.kwarg.iteritems():
            setattr(s, k, v)
        s.create_many()
        s.delete_all_stupid()
        s.create_many()
        s.delete_all_stupid()

def doit(suite, num_attr, **kwarg):
    num_threads = 20
    set_size = num_attr/num_threads

    threads = [Client(suite, start=(set_size*x)+1, stop=set_size*x+set_size, **kwarg) for x in xrange(num_threads)]
    for thread in threads:
        thread.start()
    for thread in threads:
        thread.join()

print "pytyrant"
print "*" * 20
for x in range(3):
    starttime = time.time()
    doit(PyTyrantTest, size=10, num_attr=10000)
    stoptime = time.time()

    print "Running 20 threads took %.3f seconds" % (stoptime-starttime)

for x in range(3):
    starttime = time.time()
    doit(PyTyrantTest, size=100, num_attr=50000)
    stoptime = time.time()

    print "Running 20 threads took %.3f seconds" % (stoptime-starttime)

print "python-tokyotyrant"
print "*" * 20
for x in range(3):
    starttime = time.time()
    doit(PyTokyoTyrantTest, size=10, num_attr=10000)
    stoptime = time.time()

    print "Running 20 threads took %.3f seconds" % (stoptime-starttime)

for x in range(3):
    starttime = time.time()
    doit(PyTokyoTyrantTest, size=100, num_attr=50000)
    stoptime = time.time()

    print "Running 20 threads took %.3f seconds" % (stoptime-starttime)
```

これを実行するとpytyrantのほうがずっと速い.

```text
python-tokyotyrant
********************
Running 20 threads took 6.755 seconds
Running 20 threads took 5.392 seconds
Running 20 threads took 5.516 seconds
Running 20 threads took 27.191 seconds
Running 20 threads took 30.575 seconds
Running 20 threads took 34.699 seconds
```

```text
********************
Running 20 threads took 1.748 seconds
Running 20 threads took 1.736 seconds
Running 20 threads took 1.716 seconds
Running 20 threads took 8.922 seconds
Running 20 threads took 8.716 seconds
Running 20 threads took 8.746 seconds</pre>
```

理由が分からないけども、python-tokyotyrantは [PyRex](http://www.cosc.canterbury.ac.nz/greg.ewing/python/Pyrex/) を使ったわけですかね
