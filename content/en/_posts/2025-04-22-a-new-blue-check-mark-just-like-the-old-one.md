---
layout: post
title: "A New Blue Check Mark, Just Like the Old One"
date: 2025-04-22 00:00:00 +0000
permalink: /en/a-new-blue-check-mark-just-like-the-old-one
blog: en
tags: tech
render_with_liquid: false
---

Bluesky continued their trend of replicating X/Twitter's features in a slightly
different way and just released their new [account verification
feature](https://bsky.social/about/blog/04-21-2025-verification). This seems
like a pretty big milestone in the social network's growth and a lot of the
prolific members are talking about it. Folks are reacting to being some of the
first people to receive one.

Bluesky verified themselves.

[![here is the PDS record of Bluesky verifying itself](/assets/images/2025-04-22-a-new-blue-check-mark-just-like-the-old-one/Screenshot%202025-04-22%20103142.png){: .align-center}](https://bsky.app/profile/dame.is/post/3lndqd7fx6c2q)

Kelsey Hightower was doped out.

[![Extra dope!](/assets/images/2025-04-22-a-new-blue-check-mark-just-like-the-old-one/Screenshot%202025-04-22%20103304.png){: .align-center}](https://bsky.app/profile/kelseyhightower.com/post/3lndulltmys2u)

Steve Klabnik was tongue in cheek but got to the heart of the matter.

[![it's true: my posts are real, and true](/assets/images/2025-04-22-a-new-blue-check-mark-just-like-the-old-one/Screenshot%202025-04-22%20103552.png){: .align-center}](https://bsky.app/profile/steveklabnik.com/post/3lndqq5ykgc2g)

A [verification bot](https://bsky.app/profile/verified.pds.mmatt.net) was
created in record time.

[![Good morning everyone, sorry for the pings, and congrats on your Blue Checks!](/assets/images/2025-04-22-a-new-blue-check-mark-just-like-the-old-one/Screenshot%202025-04-22%20104827.png){: .align-center}](https://bsky.app/profile/verified.pds.mmatt.net/post/3lndqgaqj6s2j)

Most folks who received one are pretty happy about receiving their check mark
and folks in general seem to be pretty receptive and happy about the new
feature. It seems like this would be a very positive development. Users can see
which accounts are who they say they are and that can help with the spread of
disinformation and bots. Right?

What follows are some of my thoughts on what I think this means for Bluesky.
However, in keeping with my [new year's
resolutions](https://www.ianlewis.org/en/2025-new-years-resolutions), I thought
I should write about it in a blog post rather than using social media itself.
To do that, I think it's worth looking at what this new check mark is, what
happened to X/Twitter's check mark, how Bluesky's check mark is different, and
whether that matters.

## A Decentralized Model

Up until now, Bluesky only had an [internet domain-based verification
model](https://bsky.social/about/blog/4-28-2023-domain-handle-tutorial). This
has some similarities with the [verification mechanism on
Mastodon](https://joinmastodon.org/verification) which ties your account to
your online presence on your own site or 3rd party sites. However, the
domain-based verification is a bit technical and not many people own their own
and operate their own domain name so it won't work as a general solution.

For their new verification system, Bluesky has taken some inspiration from a
web browser's [certificate
authority](https://en.wikipedia.org/wiki/Certificate_authority) system and
adopted a decentralized model where there are a set of "Trusted Verifiers" who
serve as a trust root. One key difference is that there doesn't seem to be a
delegation scheme; at least for now. That's getting into the weeds a bit, but
if you want to learn a bit more about how it works you can read [Steve's
post](https://steveklabnik.com/writing/thoughts-on-bluesky-verification/) or
read more on the [ATProto
wiki](https://wiki.atprotocol.community/en/wiki/reference/verification).

<!-- textlint-disable spelling -->

[![In ATProto – the open network we're built on – anybody can publish verifications. In the Bluesky app, Bluesky chooses whose verifications to show. This means that other apps could choose a different set of trusted verifiers, or use a different model entirely.](/assets/images/2025-04-22-a-new-blue-check-mark-just-like-the-old-one/Screenshot%202025-04-22%20111837.png){: .align-center}](https://bsky.app/profile/jay.bsky.team/post/3lnem7rmx3k24)

<!-- textlint-enable spelling -->

Bluesky has only a few trusted verifiers so far, but one can assume that there will be more very soon.

<!-- textlint-disable spelling -->

[![@bsky.app @nytimes.com @wired.com @theathletic.bsky.social](/assets/images/2025-04-22-a-new-blue-check-mark-just-like-the-old-one/Screenshot%202025-04-22%20122137.png){: .align-center}](https://bsky.app/profile/samuel.bsky.team/post/3lndyqyyr4k2k)

<!-- textlint-enable spelling -->

On its face, it seems like a decentralized verification scheme would be an
improvement from what we used to have on Twitter. Individual Bluesky/ATProto
clients can decide which root accounts they want to trust. Theoretically,
individual users could decide which verifiers they want to trust and which they
don't.

In practical terms though, I think that it won't matter a whole lot. For HTTPS,
browsers do [occasionally
distrust](https://security.googleblog.com/2024/06/sustaining-digital-certificate-security.html)
root certificate authorities (CAs) and this can have an impact but in ATProto's
case there is a de-facto client that controls the protocol and its evolution.
While I applaud Bluesky for picking the decentralized route, the set of
verifiers that Bluesky trusts will be a strong gold standard. And that is to say
nothing of what individual users trust. No individual users will be picking
their own trusted verifiers.

## The status symbol

When Twitter first released their check mark, it was meant as a way to verify
that [accounts were who they said they
were](https://www.huffpost.com/entry/twitter-verified-accounts_b_2863282). It
was created in response to impersonators on the platform and not being able to
tell which accounts were which because some impersonator accounts were able to
attract large amounts of followers.

However, it quickly became a status symbol. Only the most important and popular
accounts were being impersonated so it was associated with accounts that had
value. At first, it was mostly only celebrities and journalists that got check
marks but it was opened up to other users later. The rarity of the check mark
and association with the value of the account made it highly sought after and
many people viewed getting a check mark as a kind of accomplishment.

[![I'm fine with verification by domain (obviously) but not everyone has a domain or wants to get one. I just hope any new Bluesky verification works like it's supposed to: a simple, widely-accessible verification of personal identity rather than a "prize."](/assets/images/2025-04-22-a-new-blue-check-mark-just-like-the-old-one/Screenshot%202025-04-22%20104411.png){: .align-center}](https://bsky.app/profile/scalzi.com/post/3ln624egpp226)

At Twitter this formed a kind of class system of haves and have-nots. The check
mark was a highly visible way to stand out on the platform. By being deemed
worthy of verifying you were, in essence, saying that they are important and
not one of the non-verified hoi polloi. I can envision that there will be
Bluesky [feeds](https://bsky.app/feeds) with only verified users for example.

In that way I see a lot of parallels with how the check marks are being rolled
out at Bluesky. It has much the same presentation as it does on Twitter, the
user base is largely composed of folks coming from there, and Bluesky's outward
features mirror that of Twitter very closely. So folks are primed to interpret
the check mark as a status symbol in the same way it was on Twitter. The cynic
in me says that Bluesky wants this to happen because having clear indications
of who are the winners and losers in social media will drive more engagement
overall. Everyone will be hustling to be noticed enough to get their check
mark. Some organizations might be hustling to be let into the exclusive club of
verifiers trusted by Bluesky. This elevates Bluesky's standing and prestige in
ATProto and on their own platform.

## Final Thoughts

As someone who doesn't have many followers on Bluesky, I wonder if I'm just
bitter that I'm not likely to get a check mark myself. However, the fact that I
feel that way just kind of reinforces the idea that the check mark is more of a
status symbol than a verification mechanism.

<!-- textlint-disable spelling -->

[![bluesky adding verification is only good if they verify me otherwise it's bad](/assets/images/2025-04-22-a-new-blue-check-mark-just-like-the-old-one/Screenshot%202025-04-22%20121800.png){: .align-center}](https://bsky.app/profile/crimew.gay/post/3lndrium5dk24)

<!-- textlint-enable spelling -->

So if it's just going to be a status symbol, is this verification really
needed? Given
[how](https://www.technologyreview.com/2020/05/21/1002105/covid-bot-twitter-accounts-push-to-reopen-america/)
[many](https://engineering.gwu.edu/quantifying-impact-bots-online-political-discussions)
[bots](https://www.statista.com/statistics/1264226/human-and-bot-web-traffic-share/)
spreading
[misinformation](https://www.statista.com/topics/9713/misinformation-on-social-media/#topicOverview)
is out there and how much it [affects our
biases](https://pmc.ncbi.nlm.nih.gov/articles/PMC10673860/), I think it very
likely is necessary. Most users aren't likely to use the domain-based
verification system and that doesn't solve all of the issues with trust on
social platforms.

However, I wish Bluesky had taken a bit more inspiration from how HTTPS was
handled rather than how it was handled at Twitter. For HTTPS, a lot of thought
was put into how it was presented to the user in web browsers so as to
communicate the right message to users. A website using HTTPS doesn't indicate
that the website's content has more value but rather that the connection to the
website is more secure. The UI and presentation was more subtle and browsers
actively tried to avoid making some websites look more authoritative than
others. This is largely absent from the Bluesky verification roll out and I see
Bluesky making many of the same mistakes that Twitter made.

There was also a push to get all websites to use HTTPS. Browsers started
[reducing features on unencrypted
websites](https://www.chromium.org/Home/chromium-security/deprecating-powerful-features-on-insecure-origins/).
Organizations like [Let's Encrypt](https://letsencrypt.org/) cropped up to
become a verifying CA for the masses through a very simple user experience.

I realize that the problem that Bluesky, and social media in general, needs to
solve is very different from HTTPS. But I hope that much of the same push to
get all users verified could happen on Bluesky through a well built and well
thought out collective web of trust. For example, it might be cool to have an
easy way to trust the accounts that are trusted by some of the accounts that I
trust. But unless that happens I see a future for verification that is mostly a
rehashing of what we've seen before.
