---
layout: post
title: "TIL: August 19, 2025 - Weekly Reading: AI and more AI"
date: "2025-08-18 00:00:00 +0900"
blog: til
tags: ai weekly-reading
render_with_liquid: false
---

## Artificial Intelligence

- [Vibe code is legacy code](https://blog.val.town/vibe-code) -- _Steve Krouse_

    This is an interesting take on vibe code. The idea is that vibe code that was
    written entirely by an LLM is the same as legacy code because neither are code
    that is well understood. Essentially, vibe code became legacy code the
    instant it's written.

    I mostly agree with the idea, but I'd add that that legacy code is a bit more
    nuanced in that it is code where maintaining it is not worth the cost. Even
    then I agree with his point because vibe code is basically not worth the cost
    of maintaining it the moment it's created.

- [Innovation, not Productivity: Why we Built
  Windsurf](https://windsurf.com/blog/why-we-built-windsurf) -- _Windsurf_

    I've been thinking about AI IDEs a bit recently and this is Windsurf's
    reasoning for building a full AI IDE rather than just an IDE extension. They
    mention that more powerful models are available now, but their reasoning
    seemed flimsy. The rest of the post basically says the reason we need AI IDEs
    is for the user experience. User experience is great and all but I'm not sure
    we need a full IDE fork just so that the UI can be snappier.

    I plan on writing a bit more about my thoughts on AI IDEs pretty soon.

- [Why LLMs Can't Really Build
  Software](https://zed.dev/blog/why-llms-cant-build-software) -- _Conrad Irwin_

    Conrad writes that the reason LLMs can't really build software is that they
    lack the ability to maintain mental models. I've long thought that this is
    the reason they can't do a lot of reasoning tasks. They are just basically
    predicting the next word over and over again. They have a model but it's
    built around the next word prediction task, not any kind of conceptual or
    spacial model.

- [AIにはAI原則が必要](https://lestrrat.medium.com/ai%E3%81%AB%E3%81%AFai%E5%8E%9F%E5%89%87%E3%81%8C%E5%BF%85%E8%A6%81-cfe3429618d7)
  -- _Daisuke Maki_

    Daisuke Maki writes about the need for AI principles. He observes that the
    AI will shirk responsibilities like avoiding writing complex code
    and just write stub code that passes some very basic stub tests.

    He argues we should have AI principles that are similar to the Isaac
    Asimov's Three Laws of Robotics to guide AI do the right thing. He provides
    some links to [OpenAI
    research](https://openai.com/index/chain-of-thought-monitoring/) and
    [Anthropic
    research](https://www.anthropic.com/research/agentic-misalignment) on this
    topic.

- [Your MCP Doesn't Need 30 Tools: It Needs
  Code](https://lucumr.pocoo.org/2025/8/18/code-mcps/) -- _Armin Ronacher_

    Armin writes about how connecting more MCP tools to AI coding agents often
    results in more confusion and not less. He notes that AI models aren't good
    at using tools that can run in complex environments, like on different
    CPU architectures or operating systems.

    He narrows in on a solution for debugging with an AI agent using `pexpect`
    which is an older system with lots of existing code that the model has been
    trained on. This creates better results but means you need to have an MCP
    server that executes arbitrary `pexpect` code.

    Armin also notes that the security implications of this are pretty terrible.
    I hope to write a bit more about this soon, but I think that the only way to
    have anything sane is to sandbox the AI agent and all MCP servers. It's a
    bit of a tall order to manage the sandboxing, on top of managing least
    privilege access for the MCP servers.
