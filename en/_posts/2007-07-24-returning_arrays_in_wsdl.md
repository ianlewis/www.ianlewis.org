---
layout: post
title: "Returning Arrays in WSDL"
date: 2007-07-24 18:41:28 +0000
permalink: /en/returning_arrays_in_wsdl
blog: en
tags: tech programming
render_with_liquid: false
---

This week I've been working on setting up several web service for a project I'm
working on for work. Because we are creating these web services from scratch we
had to start by creating a [WSDL](http://en.wikipedia.org/wiki/WSDL) file to
describe the web service and it's functions.

WSDL is a type of XML document that describes the inputs and outputs
from a web service. This can be done using a number of ways but in my
case I'm using [SOAP](http://en.wikipedia.org/wiki/SOAP) so I described
my inputs and outputs using [XML Schema](http://www.w3.org/XML/Schema).

WSDL I found a number of documents helpful. Uche Ogbuji ([Forthought
Inc.](http://fourthought.com/)) always seems to write good articles and [Using
WSDL in SOAP
applications](http://www.ibm.com/developerworks/library/ws-soap/?dwzone=ws) no
exception. Also, examining existing documents that are publicly available was
also a big help. Such as this example [Stock
Quote](http://www.webservicex.net/stockquote.asmx?WSDL) web service. Or the
Google [SOAP web service definition](http://api.google.com/GoogleSearch.wsdl).

> **Update:** The Google SOAP web service has been deprecated and removed. See
> the blog post on the Official Google Code Blog:
> [A well earned retirement for the SOAP Search API](http://googlecode.blogspot.jp/2009/08/well-earned-retirement-for-soap-search.html)

Though after reading all of those, while returning base types like int
or string or even custom objects was easy to define, I had a hard time
figuring out how to define how to return arrays of objects (Actually,
Google's WSDL shows an example of what I'm about to describe).

I originally thought that returning a list of objects would simply
involve returning more than one of the object. Like if I defined this in
my types section:

```xml
<types>
  <xsd:complexType name='StaffList'>
    <xsd:element
      minOccurs='0'
      maxOccurs='unbounded'
      name='staffname'
      type='Staff'/>
  </xsd:complexType>
  <xsd:complexType name='Staff'>
    <xsd:all>
      <xsd:element
        minOccurs='0'
        maxOccurs='1'
        name='staffname'
        type='xsd:string'/>
      <xsd:element
        minOccurs='0'
        maxOccurs='1'
        name='staffposition'
        type='xsd:string'/>
      <xsd:element
        minOccurs='0'
        maxOccurs='1'
        name='salary'
        type='xsd:int'/>
    </xsd:all>
  </xsd:complexType>
</types>
```

For reference this is my message definition:

```xml
<message name='GetStaffRequest'>
  <part name='sessionid' type='xsd:string'/>
  <part name='staffid' type='xsd:int'/>
</message>
<message name='GetStaffResponse'>
  <part name='Result' type='StaffList'/>
</message>
```

That's a perfectly fine piece of XML Schema but unfortunately web services
clients and servers won't recognize it. Instead, you need to put a restriction
on your returned type to define the array you are returning as a
`http://schemas.xmlsoap.org/soap/encoding/:Array` type. Sounds hard but it is
really just a matter of following the pattern below instead of what I did above.

```xml
<xsd:complexType name='StaffList'>
  <xsd:complexContent mixed='false'>
    <xsd:restriction base='soapenc:Array'>
      <xsd:attribute wsdl:arrayType='Staff[]' ref='soapenc:arrayType' />
    </xsd:restriction>
  </xsd:complexContent>
</xsd:complexType>
<xsd:complexType name='Staff'>
  <xsd:all>
    <xsd:element
      minOccurs='0'
      maxOccurs='1'
      name='staffname'
      type='xsd:string'/>
    <xsd:element
      minOccurs='0'
      maxOccurs='1'
      name='staffposition'
      type='xsd:string'/>
    <xsd:element
      minOccurs='0'
      maxOccurs='1'
      name='salary'
      type='xsd:int'/>
  </xsd:all>
</xsd:complexType>
```

The message definition doesn't need to change from above. After doing
that your favorite web services client or server that supports WSDL
should recognize that what you are returning is an array type properly.
