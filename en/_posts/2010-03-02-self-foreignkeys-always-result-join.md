---
layout: post
title: "'self' ForeignKeys always result in a JOIN"
date: 2010-03-02 12:21:13 +0000
permalink: /en/self-foreignkeys-always-result-join
blog: en
tags: django orm sql
render_with_liquid: false
---

I came across a little annoyance in Django today. I found that
ForeignKeys that reference 'self', i.e. they point to the same table,
always result in a join in a filter.

Take this normal foreign key reference.

```python
class Customer(models.Models):
    user = models.ForeignKey(User)

>>> Customer.objects.filter(user__isnull)._as_sql()
('SELECT U0."id" FROM "accounts_customer" U0 WHERE U0."customer_id" IS NULL',
())
```

Now lets look at a version of the customer model with a self reference.

```python
class Customer(models.Models):
    user = models.ForeignKey(User)
    other_cust = models.ForeignKey('self')

>>> Customer.objects.filter(user__isnull)._as_sql()
('SELECT U0."id" FROM "accounts_customer" U0 LEFT OUTER JOIN "accounts_customer" U1 ON (U0."other_cust_id" = U1."id") WHERE U1."id" IS NULL',
())
```

Hmm, yuck. That little extra JOIN is going to kill performance if the
table is big. Let's do it the right way.

```python
>>> Customer.objects.extra(where=["other_cust_id IS NULL"])
('SELECT U0."id" FROM "accounts_customer" U0 WHERE other_cust_id IS NULL', ())
```

Ahh, that's better. I don't really like using extra() but in situations
like these I'm glad it's there.
