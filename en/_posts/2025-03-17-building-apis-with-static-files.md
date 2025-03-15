---
layout: post
title: "Building APIs with Static Files"
date: 2025-03-17 00:00:00 +0000
permalink: /en/building-apis-with-static-files
blog: en
tags: tech programming python
render_with_liquid: false
---

APIs are really useful for pulling in data from different sources for analysis in tools like [Datasette](https://datasette.io/) or spreadsheets. However, APIs are often hard to build and often require writing specialized servers which then need to be deployed and maintained. What if this could be as easy as deploying a static website?

I recently had the idea of creating a published API that was built much like static sites generated from static site generators like [Hugo](https://gohugo.io/) or [Jekyll](https://jekyllrb.com/), where the data used to generate the site was tracked in a git repository. I also wanted to do this cheaply using the free tier of a website hosting service.

To do that, I wrote a [static API generation app](https://github.com/ianlewis/fx/tree/main) in Python. Python is a great choice because it’s easy to write, doesn’t require additional compilation steps, and is installed almost everywhere.

## Background

While working on my tax returns, I had to calculate currency exchange rates, which led me down a rabbit hole. In Japan, when you acquire foreign stock, you often need to calculate gains in Japanese Yen. The standard way to calculate it is to use the [exchange rates published by Mitsubishi UFJ Financial Group (MUFG)](https://murc-kawasesouba.jp/fx/index.php). Unfortunately, finding these rates requires combing through their website and manually collecting the rates for each day.

I recently found a [repo](https://github.com/making/usd-to-jpy/) from someone who pulls the data and publishes via a static API. However, I noticed that each rate corresponded to a single endpoint that returned the rate as text and that the data needs to be refreshed manually. I wondered what it would be like to do this as a proper auto-updated API with JSON and CSV endpoints.

## Storing the data

Since historical exchange rate data doesn’t generally change and I wanted to store the data in a compact format, I chose to store data using [Protocol Buffers](https://protobuf.dev/) (protobuf) wire format. That way the data checked into the git repository is structured and doesn’t take up too much space.

There are other ways to do this. It could be [tracked as a sqlite database](https://garrit.xyz/posts/2023-11-01-tracking-sqlite-database-changes-in-git), for example. For data that will be updated frequently however, it might be better to just store it in a text format that git can track changes and compress better. A SQL dump or [Protocol Buffers text format](https://protobuf.dev/reference/protobuf/textformat-spec/) are reasonable choices.

For exchange rate quotes I defined a `Quote` protobuf message and `QuoteList` message to hold a list of quotes.

```protobuf
// Quote is a currency conversion quote.
message Quote {
    // provider_code is the code of the provider that provides the quote.
    string provider_code = 1;

    // date is the date on which the quote was given.
    google.type.Date date = 2;

    // base_currency_code is the currency pair base currency alphabetic code.
    string base_currency_code = 3;


    // quote_currency_code is the currency pair quote currency (target) alphabetic code.
    string quote_currency_code = 4;

    // ask is the ask/sell price in the quote currency.
    google.type.Money ask = 5;

    // bid is the bid/buy price in the quote currency.
    google.type.Money bid = 6;

    // mid is the middle rate in the quote currency.
    google.type.Money mid = 7;
}

// QuoteList represents a list of Quote objects.
message QuoteList {
    repeated Quote quotes = 1;
}
```

Using the `protoc` compiler, I can then generate Python code for these types along with serialization and deserialization methods.

```shell
protoc --proto_path=. --python_out=. quote.proto
```

I then serialized a `QuoteList` of the quotes for each currency pair by year into files and checked them into the git repository. Breaking the files up by year and currency pair make them easier to work with and prevent the files from becoming too large, as git doesn’t handle large files well. Serialization to protobuf wire format is as easy as calling the `SerializeToString` method on a protobuf object.

```python
quote_list = QuoteList()
quote_list.quotes.extend(quotes)
with open("path/to/quote.binpb", "wb") as f:
    logger.debug(f"writing {f.name}...")
    f.write(quote_list.SerializeToString())
```

## Refreshing the data

By storing the data in a git repository I can easily refresh the data by using a [GitHub Actions scheduled job](https://docs.github.com/en/actions/writing-workflows/choosing-when-your-workflow-runs/events-that-trigger-workflows#schedule) that scrapes the new data and commits it back to the repo. The job looks something like this:

```yaml
on:
  schedule:
    - cron: "0 0 * * *"

jobs:
  update:
    permissions:
      contents: write
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683 # v4.2.2
        with:
          # NOTE: Needed so we can check in the changes.
          persist-credentials: true
      - uses: actions/setup-node@1d0ff469b7ec7b3cb9d8673fde0c81c44821de2a # v4.2.0
        with:
          node-version-file: "package.json"
      - uses: actions/setup-python@42375524e23c412d93fb67b49958b491fce71c38 # v5.4.0
        with:
          python-version: "3.10"
      - run: make update
      - run: |
          git config --global user.name github-actions
          git config --global user.email github-actions@github.com
          git add .
          git commit -m "Update data $(date +"%Y-%m-%d")" || true
          git push
```

This will create a new commit containing the new data scraped each day.

> **Note:** This job has access to write to the repository, so it’s important that something like this doesn’t run on a `pull_request` if you are taking outside contributions.

## Building & Publishing the site

To build the site I write static files in JSON and CSV format for various slices of the data to a `_site` directory. For example, a list of quotes in JSON format is written by year, by month, and for each day. The files are stored in the `_site` directory in folders corresponding to the desired API endpoint, for example `/v1/provider/MUFG/quote/USD/JPY/2025/03/11.json`.

Serializing the JSON can be done with the `MessageToJson` function.

```python
from google.protobuf.json_format import MessageToJson

quote_list = QuoteList()
quote_list.quotes.extend(quotes)
with open("_site/v1/provider/MUFG/quote/USD/JPY/2025/03/11.json", "wb") as f:
    logger.debug(f"writing {f.name}...")
    f.write(MessageToJson(quote_list))
```

The site can then be served locally using the handy `python -m http.server` command.

For the production endpoint, I decided to publish the site using [Netlify](https://www.netlify.com/). The reason for this was that Netlify doesn’t have any limits on the number of files or total file size that can be published with each site. Depending on the requirements [GitHub Pages](https://pages.github.com/), [Cloudflare Pages](https://pages.cloudflare.com/), [AWS S3/Amplify](https://docs.aws.amazon.com/amplify/latest/userguide/welcome.html), or [Google Cloud Storage](https://cloud.google.com/storage/docs/hosting-static-website) would also be reasonable options.

## Summary

I enjoyed working on this and will likely make use of it from time to time. You can check out the [project repo](https://github.com/ianlewis/fx/tree/main) and [API](https://fx.ianlewis.org/) if you are interested in doing something similar.

Publishing data this way does have some downsides including the large number of files and total file size. Because the files tend to be under the filesystem block size (typically 4096 bytes) for file storage they can take up a significant amount of space on disk. The number of files is also pretty large due to data duplication for different formats and list views.

However, this can be a nice way to deploy an API like this because it’s simple, and inexpensive. It could be a good option if the data does not change too often.
