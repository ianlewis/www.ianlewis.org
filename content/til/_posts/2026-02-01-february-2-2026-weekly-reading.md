---
layout: post
title: "TIL: February 2, 2026 - Weekly Reading: AI and Security"
date: "2026-02-02 09:00:00 +0900"
blog: til
tags: weekly-reading ai security
render_with_liquid: false
---

## Artificial Intelligence

- [Moltbook is the most interesting place on the internet right
  now](https://simonwillison.net/2026/Jan/30/moltbook/) -- _Simon Willison_

    Moltbook is a "social network for bots" where people's
    [OpenClaw](https://openclaw.ai/) bots can interact with each other by
    posting messages in the style of Reddit.

    I'm scared because folks give these bots full access to their accounts,
    email inboxes, calendars, and filesystems. And now, they give them the
    ability to publish what they're doing on the internet!

    I can't imagine a world where we just give bots access to our own identity.
    It seems to me that we would treat it much like a human administrative
    assistant and include it on emails, meetings, and such. However, it would
    have its own identity and not have access to our personal accounts.

    It heartens me that Simon approaches this in a very grounded way;
    acknowledging the potential value while also acknowledging the risks.

    My notes are on
    [Readwise](https://readwise.io/reader/shared/01kg934dbwvpac97pa9kqgv592).

## Artificial Intelligence & Security

- [<!-- textlint-disable spelling -->On the Coming Industrialisation of Exploit Generation with
  LLMs<!-- textlint-enable spelling -->](https://sean.heelan.io/2026/01/18/on-the-coming-industrialisation-of-exploit-generation-with-llms/)
  -- _Sean Heelan_

    Sean Heelan discusses how large language models (LLMs) are making it easier
    to generate exploits for software vulnerabilities. He did an experiment
    where he asked agents to create exploits for a QuickJS vulnerability.

    It is interesting to see that they didn't invent novel techniques but did
    combine existing techniques in novel ways. Other than the fact that it was
    successful, it seems like a fairly boring experiment.

    It does make you think about the future where vulnerabilities could be
    exploited with much more regularity and speed than before. I also think that
    it's only a matter of time before we see agents being used to fully automate
    remote attacks.

    My notes are on
    [Readwise](https://readwise.io/reader/shared/01kg6hc4t4cdc8xd4b3m68tt2d).

## Kubernetes & Security

- [Kubernetes Remote Code Execution Via Nodes/Proxy GET Permission](https://grahamhelton.com/blog/nodes-proxy-rce) -- _Graham Helton_

    Graham Helton brings up the issue that the `nodes/proxy GET` permission in
    Kubernetes can be exploited for remote code execution (RCE) on cluster
    nodes. The reason for this is that it is a somewhat special permission that
    allows users to proxy requests to the kubelet API on nodes. This includes
    websocket APIs like the `/exec` and `/run` endpoints, which can be used to
    execute commands in a container.

    This has been brought up before by Rory McCune in his post [When is
    read-only not
    read-only?](https://raesene.github.io/blog/2024/11/11/When-Is-Read-Only-Not-Read-Only/)
    where he talked about the `pods/exec GET` permission. It seems that he also
    did some
    [research](https://github.com/raesene/container-security-site/blob/main/security_research/node_proxy.md) on `nodes/proxy` in 2022.

    Since `nodes/proxy GET` is a fairly common permission to give to service
    accounts used for monitoring and observability tools it is pretty relevant.
    Graham doesn't emphasize enough that `nodes/proxy GET` does not
    differentiate between the pods you exec on since it's a proxy to the kubelet
    API. It will grant permissions to all kinds of privileged pods running on
    the node because nodes are a cluster-wide resource.

    However, Graham seems mostly to be caught up on the fact that it's a `GET`
    request rather than a `CREATE` request. The `nodes/proxy GET` permission
    grants you the ability to proxy requests to the kubelet API, but doesn't
    make any assumptions about what those proxied requests do.

    I get that having supposedly read-only `GET` permissions potentially
    allowing you to potentially do write operations is confusing but I mostly
    agree with the response by the Kubernetes maintainers that
    [KEP-2862](https://github.com/kubernetes/enhancements/blob/master/keps/sig-node/2862-fine-grained-kubelet-authz/README.md)
    is the answer. Folks should have a separate role-based access control (RBAC)
    sub-resource for monitoring and should not really be granting `nodes/proxy`
    permissions at all. Though the fact that `pods/exec` requires `CREATE`
    permissions is a solid precedent for requiring `CREATE`.

    My notes are on
    [Readwise](https://readwise.io/reader/shared/01kg4f0wf5tnv2v5hz0mgt970q).
