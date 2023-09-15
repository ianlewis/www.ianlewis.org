---
layout: post
title: "Python Sets"
date: 2011-09-12 20:00:00 +0000
permalink: /en/python-sets
blog: en
---

I had an application with two lists of unique items that I wanted to
take the intersection of. I had figured that using a python set would be
faster but I didn't realize that it would be faster than the simple list
comprehension by this much.

``` text
~$  python -m timeit -n 1000 "range1500=range(500, 1500);[x for x in range(1000) if x in range1500]"
1000 loops, best of 3: 18.2 msec per loop

~$ python -m timeit -n 1000 "set(range(1000)).intersection(range(500, 1500))"
1000 loops, best of 3: 120 usec per loop
```

It's about 150 times faster (notice the difference in order of
magnitude, usec vs. msec). It's not actually because of the list
comprehension but rather because of the repeated use of `in` within the
list comprehension. The check for `x in range1500` is executed 1000
times which adds up.

To find out what actually takes so much time lets first check the
range() function.

``` text
~$ python -m timeit -n 1000 "range(500, 1500)"
1000 loops, best of 3: 12.9 usec per loop
```

We only call this twice so this isn't what's taking several
milliseconds.

Next lets try the `in` statement.

``` text
~$ python -m timeit -n 1000 "1 in range(1000)"
1000 loops, best of 3: 12.3 usec per loop
```

Here we go. The `in` statement only takes 12.3 microseconds but it's run
1000 times. That adds up to 12.3 microseconds. We can safely say this is
what's taking a majority of the time. But there is still about 5 micro
seconds unaccounted for.

What we did was check this in the best case where it finds a match at
the beginning of the list. What if it's at the end?

``` text
~$ python -m timeit -n 1000 "1000 in range(1000)"
1000 loops, best of 3: 35.2 usec per loop
```

Here we see it takes a lot more time to run the inclusion check. What's
happening in the example is that, since I was using a simple range
statement, it slowly goes from a the best case scenario to the worst
case scenario so we end of getting an average of somewhere in between.

In any case sets are a very useful tool to avoid having to do inclusion
checks on lists when you need to get the intersection, union, or diff of
a list.
