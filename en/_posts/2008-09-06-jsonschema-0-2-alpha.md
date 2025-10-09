---
layout: post
title: "jsonschema 0.2 alpha"
date: 2008-09-06 20:04:08 +0000
permalink: /en/jsonschema-0-2-alpha
blog: en
tags: tech programming projects python
render_with_liquid: false
---

I just released a new version of jsonschema 0.2 alpha over at [http://code.google.com/p/jsonschema](http://code.google.com/p/jsonschema)

The source can be downloaded here: [`jsonschema-0.2a.tar.gz`](http://jsonschema.googlecode.com/files/jsonschema-0.2a.tar.gz)
The documentation can be found here: [jsonschema (version `0.2a`) documentation](http://www.bitbucket.org/IanLewis/jsonschema/raw/4ad1ade5779d/docs/jsonschema.html)

The new release includes the following notable changes.

- The `additionalProperties` attribute is now validated.
- Using schemas in the type attribute now works properly.
- Changed support for unique attribute to the "identity" attribute (Note: this
  is not a backwards compatible change)
- Fixed a bug where the original schema object/dictionary was modified by the
  validator
- Added a new "interactive mode" which will add default values to objects if not
  specified as read-only by the schema
- Made error messages a bit more friendly.
- Fixed bugs with validating Unicode strings

The
[`additionalProperties`](http://groups.google.com/group/json-schema/web/json-schema-proposal---second-draft)
attribute is used to define the format of additional properties that aren't
explicitly specified in the properties attribute. This is useful for JSON like
the following where you have some things like game scores and the name of the
attribute is someone's name which can't be defined in schema.

```javascript
{
  bob: 10,
  sue: 20,
  bill: 30
}
```

You can use it like so:

```javascript
{
  "type": "object",
  "additionalProperties": "integer"
}
```

The type field was also fixed so that it handles adding schemas as types, so now
you can define,

```javascript
{
  "type": [
    { "type": "array",  "minItems": 10 },
    { "type": "string", "pattern": "^0+$" }
  ]
}
```

This can let you define more complex types for use in schema.
