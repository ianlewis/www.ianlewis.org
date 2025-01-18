---
layout: post
title: "Introduction to Algorithms"
date: 2008-12-15 18:10:37 +0000
permalink: /en/introduction_to_algorithms
blog: en
tags: tech programming python
render_with_liquid: false
---

![](/assets/images/2008-12-15-introduction_to_algorithms/intro_to_algorithms.jpg){:style="display:block; margin-left:auto; margin-right:auto"}

Today my copy of Introduction to Algorithms came in the mail (a gift from the
family). I've decided, mostly inspired by [Peteris
Krumins](http://www.catonmat.net/) to revisit classic algorithms as it's been a
while since I've taken a look at them.

I have decided to also take a look at the MIT Intro to Algorithms course in
order to revisit algorithms and concepts. I won't provide any lecture notes or
anything since Peteris did a much better job of of writing [lecture
notes](http://www.catonmat.net/blog/mit-introduction-to-algorithms-part-one/)
that I ever could but I did go ahead and create some python implementations of
the sorting algorithms covered in the first lecture. These haven't been tested
extensively so there might be bugs but I'm pretty sure they're working. I'd be
interested to see how well these work with large input data, particularly the
merge sort.

**insertion-sort.py**

```python
def sort(array):
  for j in xrange(1, len(array)):
    i = j - 1
    key = array[j]
    while i >= 0 and key < array[i]:
      array[i+1] = array[i]
      i = i - 1
    array[i+1] = key
  return array
```

**merge-sort.py**

```python
def sort(array):
  mergesort(array, 0, len(array))
 
def mergesort(array, start, end):
  if end > start + 1:
    pivot = (start + end) / 2
    mergesort(array, start, pivot)
    mergesort(array, pivot, end)
    merge(array, start, pivot, end)
 
def merge(array, start, pivot, end):
  l = array[start:pivot]
  lenl = pivot - start
  r = array[pivot:end]
  lenr = end - pivot
  i = j = 0
  for k in xrange(start,end):
    if j >= lenr or (i < lenl and l[i] <= r[j]):
      array[k] = l[i]
      i += 1
    else:
      array[k] = r[j]
      j += 1
```
