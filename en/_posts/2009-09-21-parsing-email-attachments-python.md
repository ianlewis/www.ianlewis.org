---
layout: post
title: "Parsing email with attachments in python"
date: 2009-09-21 11:33:31 +0000
permalink: /en/parsing-email-attachments-python
blog: en
tags: tech programming python
render_with_liquid: false
---

Recently I needed to be able to parse out attachments and body from
multipart emails and use the resulting data to post to a service. So I
wrote the code below to parse out text and html portions of the email
and also parse out attachments.

The code below is the result. I used a StringIO object from the python
StringIO module to hold attachment data because the PIL module seemed to
not be able to recognize images unless I either used a python file
object or a StringIO object. Since it relies on the python StringIO
module rather than the C one that portion should probably be rewritten.
But it currently works as is so I'll post it for posterity.

```python
#!/usr/local/bin/python
# vim:fileencoding=utf8

from email.Header import decode_header
import email
from base64 import b64decode
import sys
from email.Parser import Parser as EmailParser
from email.utils import parseaddr
# cStringIOはダメ
from StringIO import StringIO

class NotSupportedMailFormat(Exception):
    pass

def parse_attachment(message_part):
    content_disposition = message_part.get("Content-Disposition", None)
    if content_disposition:
        dispositions = content_disposition.strip().split(";")
        if bool(content_disposition and dispositions[0].lower() == "attachment"):

            file_data = message_part.get_payload(decode=True)
            attachment = StringIO(file_data)
            attachment.content_type = message_part.get_content_type()
            attachment.size = len(file_data)
            attachment.name = None
            attachment.create_date = None
            attachment.mod_date = None
            attachment.read_date = None

            for param in dispositions[1:]:
                name,value = param.split("=")
                name = name.lower()

                if name == "filename":
                    attachment.name = value
                elif name == "create-date":
                    attachment.create_date = value  #TODO: datetime
                elif name == "modification-date":
                    attachment.mod_date = value #TODO: datetime
                elif name == "read-date":
                    attachment.read_date = value #TODO: datetime
            return attachment

    return None

def parse(content):
    """
    Eメールのコンテンツを受け取りparse,encodeして返す
    """
    p = EmailParser()
    msgobj = p.parse(content)
    if msgobj['Subject'] is not None:
        decodefrag = decode_header(msgobj['Subject'])
        subj_fragments = []
        for s , enc in decodefrag:
            if enc:
                s = unicode(s , enc).encode('utf8','replace')
            subj_fragments.append(s)
        subject = ''.join(subj_fragments)
    else:
        subject = None

    attachments = []
    body = None
    html = None
    for part in msgobj.walk():
        attachment = parse_attachment(part)
        if attachment:
            attachments.append(attachment)
        elif part.get_content_type() == "text/plain":
            if body is None:
                body = ""
            body += unicode(
                part.get_payload(decode=True),
                part.get_content_charset(),
                'replace'
            ).encode('utf8','replace')
        elif part.get_content_type() == "text/html":
            if html is None:
                html = ""
            html += unicode(
                part.get_payload(decode=True),
                part.get_content_charset(),
                'replace'
            ).encode('utf8','replace')
    return {
        'subject' : subject,
        'body' : body,
        'html' : html,
        'from' : parseaddr(msgobj.get('From'))[1], # 名前は除いてメールアドレスのみ抽出
        'to' : parseaddr(msgobj.get('To'))[1], # 名前は除いてメールアドレスのみ抽出
        'attachments': attachments,
    }
```
