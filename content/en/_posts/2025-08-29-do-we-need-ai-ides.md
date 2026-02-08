---
layout: post
title: "Do we need AI IDEs?"
date: 2025-08-29 00:00:00 +0000
permalink: /en/do-we-need-ai-ides
blog: en
tags: tech ai programming
render_with_liquid: false
---

AI integrated development environments (IDEs) are all the rage.
[Cursor](https://cursor.com/) was one of the first AI-focused IDEs and emerged
as a fork of VSCode. [Kiro](https://kiro.dev/), another VSCode fork, was just
released by AWS. Windsurf, yet another VSCode fork, recently had their [top
talent poached and sold the
rest](https://www.cnbc.com/2025/07/14/cognition-to-buy-ai-startup-windsurf-days-after-google-poached-ceo.html).
Clearly, a lot of folks at AI companies thought striking it out on their own was
a good idea.

Many developers seem to be getting value out of these editors, but there also
seems to be a fair amount of hype. All this activity has me thinking: What about
AI necessitates having a new IDE? Why are these IDEs a fork of VSCode and not an
extension? Why are there so many? What do developers actually get out of it? Do
we even need them?

I'm not a total AI skeptic—I think it can be helpful for some things, and I've
seen some compelling use-cases and environments. However, I think we should be
honest about what AI companies want and their motivations. With that in mind,
let's take a look at what these IDEs actually do, the motivations behind
releasing them, and what editors making use of AI should look like.

## What do these IDEs do that's so special?

AI IDEs aren't that different from regular IDEs. The main difference seems to be
that they have more built-in AI features and integrate them nicely into the
editor. This is good, but depending on the features you use, you might be able
to get the same experience using plugins or extensions.

Let's take a closer look at what makes AI IDEs special (or not so special) and
whether that's justification for creating whole new IDEs rather than integrating
into existing ones.

### Chat Windows

AI IDEs almost always include a Chat UI pane to chat directly with the agent and
have it respond to questions or perform actions. Often there are some UI
elements in the chat window itself marking some of the changes it's making.
These show things like “Edited index.html” and give you a button to open the
diff directly for review.

![A screenshot of the WindSurf IDE. There is an open chat window with a planning and editing conversation.](/assets/images/2025-08-25-do-we-need-ai-ides/chat.png){: .align-center}

This seems to me to be something that could be easily added into an existing
editor like VSCode or Neovim. Indeed, many tools like
[Kilo Code](https://kilo.ai/), [Copilot Chat for
Neovim](https://github.com/CopilotC-Nvim/CopilotChat.nvim), or even the
[Windsurf extension for
VSCode](https://marketplace.visualstudio.com/items?itemName=Codeium.codeium)
provide a chat pane into existing editors with similar UI elements.

### Diff view

The editor also usually includes a diff view that will show changes being made
directly in the window. This can helpfully show the changes that the AI is
making so that you can review and approve them.

![A screenshot of the Windsurf IDE showing a diff view](/assets/images/2025-08-25-do-we-need-ai-ides/diff.png){: .align-center}

While this is very nice to have when working with AI, almost all of the VSCode
or Neovim plugins have this feature as well. VSCode has the ability to [compare
files](https://learn.microsoft.com/en-us/visualstudio/ide/compare-with) natively
in the editor. Neovim includes a standard [diff
view](https://neovim.io/doc/user/diff.html) that plugins can use to show diffs
to users. These features can merely be invoked by plugins to show the diff
views. The previously mentioned plugins already do a pretty good job showing
diffs of changes they are making.

When combined with version control systems like git, reviewing and accepting
changes should be fairly easy.

### Autocomplete

Using AI to autocomplete the code you're typing was one of the first really
productive uses of AI in coding. When you type some text the editor will show
you an AI-generated snippet of code that you can hit TAB to complete. The AI
often gets this wrong but it can save a lot of typing.

![A screenshot of the Windsurf IDE showing an unfinished autocomplete of an html
div tag](/assets/images/2025-08-25-do-we-need-ai-ides/autocomplete.png){: .align-center}

Almost all code editors have some kind of plugin that allows you to do this even
before AI IDEs started being released. We've had auto-complete snippets plugins
and LSP-like introspection in IDEs for a long time, so it's obviously not
necessary to use a whole new editor to make use of AI-generated autocomplete.

### Application deployment

Some editors like Windsurf have serverless [application
deployment](https://docs.windsurf.com/windsurf/cascade/app-deploys) options.
These are convenient but don't really have anything to do with AI or editors
themselves. With Windsurf, you can click a deploy button which will ask the AI
to deploy the application.

![A screenshot of the Windsurf deployment button](/assets/images/2025-08-25-do-we-need-ai-ides/app-deploys-ui.png){: .align-center}

_From:
[`https://docs.windsurf.com/windsurf/cascade/app-deploys`](https://docs.windsurf.com/windsurf/cascade/app-deploys)_

This is convenient, but it doesn't have anything to do with the editor itself.
It has also existed as a convenience within IDEs for
[various](https://devcenter.heroku.com/articles/deploy-to-heroku-from-vscode)
[cloud](https://cloud.google.com/tools/visual-studio/docs/deploy-asp-net-app)
[platforms](https://learn.microsoft.com/en-us/azure/azure-functions/functions-add-output-binding-cosmos-db-vs-code?pivots=programming-language-csharp#redeploy-and-verify-the-updated-app)
for many years.

Whether you deploy from the editor or not, developers should be free to choose
where to deploy their applications that makes the most sense rather than just
whatever comes bundled with the editor.

### Paid plans

Most of the new editors that have been released recently, like
[Cursor](https://cursor.com/pricing), [Windsurf](https://windsurf.com/pricing),
[Kiro](https://kiro.dev/pricing/), and [Trae](https://www.trae.ai/pricing)
include paid models which only allow using the editor for free during a short
trial period. The cost of the editors is in addition to any costs incurred
through the use of AI models.

I think it's fine for editors to charge money, but I don't think that technology
should require us to pay money to specific companies due to arbitrary
restrictions. For example, that would happen if developers were forced to use an
AI model's editor in order to use that model fully.

Going forward, it will be crucial for developers to understand the benefits they
are receiving from using these editors separately from the AI models given that
they incur separate costs.

### Developer experience and rich integration

One unique feature that these new editors do have is rich integration between
the AI and editor as an out of the box experience. You can sign up and start a
free trial with Windsurf very easily and things mostly just work. This can be a
real help for new developers without a lot of experience in setting up their
development environment.

There is no need to search for, install, and configure various plugins only to
have trouble trying to get them to integrate well together. The necessary
functionality is already included in the base install and is maintained by the
editor developers themselves ensuring a smooth experience.

It's clear that some thought has gone into the developer experience though I
think we also have to be clear about what developers are trading for that
experience. For example, I think it might be valuable for new developers to pay
for that experience if they know that is what they are paying for, and that AI
model features are available outside the editor.

## Dreams of vendor lock-in

When thinking about whether to use AI IDEs, it's useful to consider the
motivation behind the companies building them. I think the motivation behind the
current gold rush to release AI IDEs has less to do with the needs of developers
and more with the ambitions of the companies creating them.

Much like how companies sought to control the [web
browser](https://en.wikipedia.org/wiki/Browser_wars) or [mobile
OS](https://en.wikipedia.org/wiki/Smartphone_patent_wars), AI companies will
seek to control the platform on which their products are used. For example,
Windsurf has [said](https://windsurf.com/blog/why-we-built-windsurf) _“We
believe Windsurf will become a platform that will extend across the entire
software development life cycle”_. Companies want to control the whole platform
for a few different reasons.

First, companies can give their own models preferential treatment. This can be
done by making their model the default, or by outright requiring its use. We can
already see this with some of the local coding agents like [Claude
Code](https://www.anthropic.com/claude-code) which only supports Anthropic's
models. AI companies can also limit access to their models to competing editors.
For example, after Windsurf announced its acquisition agreement with OpenAI,
Anthropic [restricted the use of its
models](https://techcrunch.com/2025/06/05/anthropic-co-founder-on-cutting-access-to-windsurf-it-would-be-odd-for-us-to-sell-claude-to-openai/)
within the Windsurf platform. This isn't good for developers who just want to
use the tools that work best for them.

Second, tools like IDEs can be sticky for users. Developers get used to their
IDE so there may be some obstacles to switching that don't have to do with
specific features. Preferential treatment of AI models could make this problem
worse as well. Companies could make it harder for developers to switch and
attempt to lock them into their walled-garden ecosystem.

Finally, as developing software becomes more and more dependent on AI models and
the tools these companies create, these companies can amass incredible power.
They can charge high prices. They can amass very personalized data on individual
developers and the companies they work for.

Right now, anyone with a cheap laptop can run Linux and develop software using
open-source tools. If software development in the future requires a yearly
license fee to a handful of gate-keeping corporations, they can essentially
decide who succeeds and who fails. I'm not sure I would want to be a software
developer in that kind of future.

It's worth remembering that companies may seem reasonable right now as they are
growing, but they can change once they gain more power over their users. IDEs
may not, by themselves, lock-in developers, but I think that they could set the
stage for a new round of software vendor lock–in.

## Separation of concerns

If AI IDEs aren't going to be an essential part of software development, what
would the right way forward look like? To be clear, I don't think it would be
too different from where it is now. I think the main difference would be in a
proper [separation of
concerns](https://en.wikipedia.org/wiki/Separation_of_concerns).

By using AI IDEs, developers can lose out on a large ecosystem of plugins and
extensions. VSCode, JetBrains IDEs, Vim, Emacs all have large ecosystems of
developers creating extensions that make developers more productive.

AI companies are primarily providing access to AI models. Like most other
services, this is primarily an API that can be integrated into a wide variety of
applications. Editors and IDEs are just one of them. There currently isn't a
technical reason why AI models and editors need to be tightly integrated except
for perhaps for a highly integrated new developer experience.

Without a technical reason why AI models and editors should be integrated, the
editor and AI models should separate their logic and interact via a well-known
interface (e.g. an API). That allows for the most flexibility with using various
tools, makes it easier to switch, and improves competition since each tool can
be evaluated on its own merits.

## Final thoughts

The main thing that AI editors provide is a fully integrated developer
experience for software development. The AI models and features themselves
aren't unique to AI IDEs; they are just wrapped up into a nice package.

Developer experience is nice and all, but I'm at a loss to figure out why we
need so many AI IDEs all of a sudden. And why they are getting multi-billion
dollar valuations if the main feature is developer experience. To be honest,
given that we've been told that we'll all just be AI babysitters in the future,
I wonder why companies think we even need editors or IDEs at all. Shouldn't a
chat box be all we need?

Maybe one day that will be true. In the meantime, I think that whether you use
an AI IDE or another editor may depend on whether you are already a developer or
not. AI IDEs may be great for new developers getting into the field and trying
to make use of AI. Those developers may need a good early developer experience,
and not care about customizing their IDE as much as existing developers.

For existing developers though, I'm skeptical that using a forked IDE is the way
forward for AI in software development. AI extensions to IDEs seem like a much
better architecture that allows for greater flexibility and productivity.

As for me, I'll use AI here and there but I'll be sticking with Neovim plugins
and the terminal for development.
