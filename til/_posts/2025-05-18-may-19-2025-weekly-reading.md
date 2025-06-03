---
layout: post
title: "TIL: May 19, 2025 - Weekly Reading: The Go Scheduler, CNCF/NATS Drama, and Signalgate"
date: "2025-05-19 09:45:00 +0900"
blog: til
tags: programming, go, security
render_with_liquid: false
---

Here are some of the things I was reading this last week or two.

## Go

- [Go Scheduler](https://nghiant3223.github.io/2025/04/15/go-scheduler.html) -
  _Nguyen Trong Nghia_

    This is a really good write up of how the Go scheduler works. It covers the
    GMP model, Goroutine creation, the schedule loop and preemption, integration
    with network and file I/O, and much more. It is written in a very approachable
    way with lots of diagrams and examples. Highly recommended reading.

- [Leaving Google](https://www.airs.com/blog/archives/670) - _Ian Lance Taylor_

    Ian Taylor is a well known name in the Go community and has been at Google
    for almost two decades. He was a key engineer on the Go compiler, especially
    in the early days, and was also key to the eventual addition of generics to
    Go. He faults himself for being slow to come around to ideas like the Go
    module proxy and Go vulnerability database, but I personally think it was
    partly the slow and careful process in adding features to Go that has made
    it such a good language.

## CNCF/NATS Drama

- [Protecting NATS and the integrity of open source: CNCF’s commitment to the
  community](https://www.cncf.io/blog/2025/05/01/protecting-nats-and-the-integrity-of-open-source-cncfs-commitment-to-the-community/) - _CNCF_

    The CNCF issued a statement about the NATS trademark dispute. Synadia, the
    seward of the NATS project, want to withdraw from the CNCF and reclaim the
    NATS trademark. The problem there is that the CNCF isn't a program that you
    enter into with a process for withdrawing. You basically donate the
    project's trademark to the CNCF in order to protect against license
    rug-pulls like what Synadia wants to do here.

    Apparently the trademark transfer of NATS to the CNCF was never officially
    completed so Synadia is trying to weasel out of their deal.

- [Looking Ahead with Clarity and Purpose for
  NATS.io](https://www.synadia.com/blog/synadia-response-to-cncf) - _Derek
  Collison_

    This is Synadia's response to the CNCF's statement. They say they are
    committed to maintaining an open source Apache 2.0 license for NATS, but
    I kind of have my doubts. If that's the case, why do they need to withdraw
    from the CNCF? It sounded like they wanted to release future versions under
    the BUSL license, which sure sounds like a rug-pull to me.

    This response doesn't really make any of that clear though. If they really
    want to become proprietary they can fork the project just like any other
    open-source project and continue development. It really sounds like they
    wanted all the benefits of being in an OSS foundation without any of the
    costs.

    Derek Collison, the CEO of Synadia, used to be the CEO of Apcera. I met him
    one time and I sort of remember some strangeness with how they dealt with
    the open-source community in the past which kept me away from their
    projects. I can't remember exactly what it was though.

- [Shootout at the CNCF Corral](https://oxide-and-friends.transistor.fm/episodes/shootout-at-the-cncf-corral) - _Oxide and Friends_

    Oxide and Friends had an episode about the dispute. Oxide folks come down on
    the side of NATS mostly and don't really like Open Source foundations. Many
    of the criticisms they bring up are fair and valid, like no clear way to get
    benefit from or make progress out of the Sandbox stage without outside
    contributions.

    I think most folks forget what it was like before the Linux Foundation and
    the CNCF existed. Companies were constantly re-licensing OSS projects out
    from under their users and it was a terrible experience. The big-company
    donation model leaves a lot to be desired, but The Linux Foundation and the
    CNCF did a pretty good job in restoring trust in open source projects.

    The podcast was good listen even though I don't really agree with their
    overall view on the situation.

- [CNCF and Synadia Align on Securing the Future of the NATS.io Project](https://www.cncf.io/announcements/2025/05/01/cncf-and-synadia-align-on-securing-the-future-of-the-nats-io-project/) - _CNCF_

    The CNCF and Synadia have come to an agreement on the future of NATS. The
    CNCF will continue to host the NATS project and Synadia will continue to
    maintain it. Ultimately, Synadia did decide to fork the project for their
    own server-side proprietary NATS service. This seems like it was the only
    possible outcome.

## Security

- [Despite misleading marketing, Israeli company TeleMessage, used by Trump
  officials, can access plaintext chat logs](https://micahflee.com/despite-misleading-marketing-israeli-company-telemessage-used-by-trump-officials-can-access-plaintext-chat-logs/) - _Micah Lee_

    Apparently, the White House folks weren't actually using the official Signal
    distribution but were using one made by TeleMessage.

    It seems that TeleMessage uses a folk of the OSS Signal client with the main
    added feature being the archival of messages. Most folks have criticized the
    Trump admin for not using the official app, but this seems to me like it
    this might have been simply adopted to comply with the [US Federal Records
    Act](https://en.wikipedia.org/wiki/Federal_Records_Act). It's unclear what
    the actual archival setup is and where the data is hosted. If I'm right that
    it's to comply with the Federal Records Act, then I would assume the data is
    stored on US government servers and not servers controlled by TeleMessage.

    Yes, the archival of messages breaks the e2e encryption of Signal, but that
    is the nature of having to archive the messages for compliance. I haven't
    seen much evidence that TeleMessage actually has access to the plaintext of
    the messages.

    There seem to be a few problems though. First, TeleMessage themselves got
    [hacked](https://www.nbcnews.com/tech/security/telemessage-suspends-services-hackers-say-breached-app-rcna204925a)
    and some archival messages were leaked. I haven't seen any evidence that the
    leaked messages contain any White House data though so I'm leaning towards
    my initial thought that the government archives are maintained on government
    servers. Still, it doesn't speak well for the security of TeleMessage.

    Second, the White House folks seem to be using Signal incorrectly. It should
    be used for non-sensitive communications but they've been recently using it
    to discuss sensitive topics like the [attack on the Houthis in
    Yemen](https://en.wikipedia.org/wiki/United_States_government_group_chat_leaks).
