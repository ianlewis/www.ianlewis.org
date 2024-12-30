---
layout: post
title: "JSON Schema Validator 0.1a for Python"
date: 2008-07-31 01:01:32 +0000
permalink: /en/json-schema-validator-0-1a-for-python
blog: en
tags: projects python json jsonschema
render_with_liquid: false
---

<!-- textlint-disable rousseau -->

I just released the first version for a project that I've been working on since
the [Python Onsen](http://www.ianlewis.org/index.php/en/python-onsen). It's a
validator for [JSON Schema](http://www.json.com/category/json-schema/) written
in Python. It's based on the [JSON Schema Proposal Second
Draft](http://groups.google.com/group/json-schema/web/json-schema-proposal---second-draft).</p>

<!-- TODO(#67): Fix 404s -->

The source tarball is [jsonschema-0.1a.tar.gz](http://jsonschema.googlecode.com/files/jsonschema-0.1a.tar.gz). The source itself is on [Bitbucket](https://bitbucket.org/IanLewis/jsonschema/).

JSON Schema's purpose is to allow validation of JSON documents much like XML
Schema, DTD. You can use it to define what kind of data should be present in the
document as well as the structure of the data. You might have some JSON for a
contact like so:

```json
{
  "name": "Ian Lewis",
  "email": "IanLewis@xyz.com",
  "address": "123 Main St.",
  "phone": "080-1942-9494"
}
```

And you could describe this in JSON Schema with the following:

```json
{
  "type":"object",
  "properties":{
    "name": {"type":"string"},
    "age": {"type":"int", "optional":True},
    "email": {
      "type":"string",
      "pattern":"^[A-Za-z0-9][A-Za-z0-9\.]*@([A-Za-z0-9]+\.)+[A-Za-z0-9]+$"
    },
    "address": {"type":"string"},
    "phone": {"type":"string"}
  }
}
```

This can be validated with something like the following Python code:

```python
import jsonschema, simplejson

data = """{
  "name": "Ian Lewis",
  "email": "IanLewis@xyz.com",
  "address": "123 Main St.",
  "phone": "080-1942-9494"
}"""

schema = """{
  "type":"object",
  "properties":{
    "name": {"type":"string"},
    "age": {"type":"int", "optional":True},
    "email": {
      "type":"string",
      "pattern":"^[A-Za-z0-9][A-Za-z0-9\.]*@([A-Za-z0-9]+\.)+[A-Za-z0-9]+$"
    },
    "address": {"type":"string"},
    "phone": {"type":"string"}
  }
}"""

x = simplejson.loads(data)
s = simplesjson.loads(schema)
jsonschema.validate(x,s)
```

It can be easily extended to include support for new properties or to override
the default validation for standard properties so I think it could be used for a
wide range of applications. I plan to use it for a Form Maker application
([code](http://www.ianlewis.org/hg/formmaker-appengine/)) on
[GAE](http://code.google.com/appengine/). Let me know what you think!

<!-- textlint-enable rousseau -->
