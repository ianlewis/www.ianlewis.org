---
layout: post
title: "Python date range iterator"
date: 2008-12-19 15:27:30 +0000
permalink: /en/python-date-range-iterator
blog: en
tags: tech programming python
render_with_liquid: false
---

I couldn't find something that gave me quite what I wanted so I created
a simple [Python](http://www.python.org/) generator to give me the dates
between two datetimes.

```python
def datetimeIterator(from_date, to_date):
    from datetime import timedelta
    if from_date > to_date:
        return
    else:
        while from_date <= to_date:
            yield from_date
            from_date = from_date + timedelta(days = 1)
        return
```

> **Update**: It didn't take me long to realize that it wasn't as nice as
> it could have been.
> 
> ```python
> from datetime import datetime,timedelta
> 
> def datetimeIterator(from_date=datetime.now(), to_date=None):
>     while to_date is None or from_date <= to_date:
>         yield from_date
>         from_date = from_date + timedelta(days = 1)
>     return
> ```

> **Another Update** based on the comments below:
> 
> ```python
> from datetime import datetime,timedelta
> 
> def datetimeIterator(from_date=None, to_date=None, delta=timedelta(days=1)):
>     from_date = from_date or datetime.now()
>     while to_date is None or from_date <= to_date:
>         yield from_date
>         from_date = from_date + delta
>     return
> ```
