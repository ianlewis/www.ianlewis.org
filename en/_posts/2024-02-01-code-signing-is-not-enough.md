---
layout: post
title: "Code Signing is not Enough"
date: 2024-02-01 00:00:00 +0000
permalink: /en/code-signing-is-not-enough
blog: en
tags: tech security
render_with_liquid: false
---

Code signing is often used as a method for ensuring that software artifacts
like binaries, drivers, and software packages haven’t been modified by a third
party before they are used. Many folks may be familiar with packages that were
`gpg` signed and distributed with an Armored ASCII (`.asc`) file. Code signing
is a great step towards securing the software supply chain above simply
providing software as-is, but has a number of downsides that can be addressed
with other methods like software provenance.

## Signing Code

Code signing is the name given to cryptographically signing release artifacts
with a cryptographic key. In the past, PGP and the GNU implementation `gpg`
have been popular methods used for code signing. Another method that has gained
popularity recently is to use the [sigstore](https://www.sigstore.dev/)
project’s `cosign` tool to sign artifacts with short-lived keys.

By signing an artifact your users can cryptographically guarantee that the
artifact they are using is byte-for-byte identical to the artifact that was
signed using the developer’s key. The key itself can contain a bit of metadata
about the company name, timestamps, etc. and this information can be used to
ensure it is coming from a trusted party before the artifact is executed.

However, there are a number of ways that code signing doesn’t go far enough to
protect users from malicious artifacts. Software provenance achieves the same
goals using a similar method but goes farther by tackling the problem of
verifying software artifacts more directly.

Let’s take a look at what provenance is, then we can compare it with code
signing to see how it goes further to protect users.

## Software Provenance

Provenance is a set of metadata that is produced along with a software artifact
when it is created that describes how the software artifact was created.
Typically this is done as part of a CI/CD build pipeline and includes
information such as the source code repository and revision used to build the
artifact, and the CI/CD build system itself.

Provenance metadata is usually created and stored in a machine readable format
like JSON. To ensure the integrity of the metadata, provenance is then signed
using a cryptographic key much like code signing and distributed with the
resulting signature. It can contain more information specific to each build
such as the builder (e.g. GitHub Actions), source code repo & commit, and build
inputs. By combining the metadata and the signature together we get what's
called a provenance “attestation” because it _attests_ to how the software was
built.

One important aspect of provenance is that it can be created in a more
trustworthy way, typically by the CI/CD system itself. This means that the
metadata cannot be tampered with by normal users of the CI/CD build system like
code contributors.

## Attestations over Inferences

One of the key tenets of the [Supply-chain Levels for Software Artifacts (SLSA)
framework](https://slsa.dev/) is [“Prefer attestations over
inferences”](https://slsa.dev/spec/v1.0/principles#prefer-attestations-over-inferences).
The slsa.dev website says:

> _Require explicit attestations about an artifact’s provenance; do not infer
> security properties from a platform’s configurations._

What this means is that we should avoid making assumptions about a software
artifact based on how we _think_ it was created. Code signing makes exactly
these kinds of implied assumptions.

For example, let’s assume that we have a software artifact that was signed by a
key that is owned by the software’s author.

How do we know where the software was built? We can _assume_ that it was built
by the normal release pipeline on GitHub but can we really know for sure?

How do we know what source code was used? We can _assume_ that it was built
using the source code in the GitHub repo but the code signature says nothing
about that.

Even if we are satisfied that this artifact was built using a secure process
and is not compromised, can we be sure of that for other artifacts released by
other developers?

We can think of code signing as creating an attestation but that attestation is
empty or at least provides very little information explicitly. All information
about how the software was built is _implied_ by the signing itself.

## Example Supply Chain Attacks

GitHub Actions security vulnerabilities are an often written about topic. One
typical attack is to exploit vulnerabilities in the PR checks. One such example
is with the `workflow_run` trigger which is triggered when another workflow
completes. If the triggered workflow does not properly validate its inputs from
a PR’s workflow run then it could allow [privilege
escalation](https://www.legitsecurity.com/blog/github-privilege-escalation-vulnerability)
via its `GITHUB_TOKEN`.

Attackers gaining access to a repository could use these elevated permissions
to overwrite released binaries or make changes to the codebase. In these
situations attackers often try to cover their tracks by
[deleting the logs of workflow runs](https://adnanthekhan.com/2023/12/20/one-supply-chain-attack-to-rule-them-all/?utm_source=pocket_saves)
or other measures.

However, if generating trustworthy provenance that is generated by GitHub or a
separate trusted mechanism, attackers would be more limited in the attacks they
can achieve. Attackers would not be able to simply overwrite release binaries
because the associated provenance would then fail verification. If attackers
modify the source code, the corresponding artifact that was built would be tied
back to a compromised commit leaving evidence of the attack and making it
easier for downstream users to respond by rejecting those binaries.

The [Deliberately Vulnerable GitHub Actions
repo](https://github.com/step-security/github-actions-goat) is also a fun
repository to explore and learn more about common attacks on GitHub Actions
workflows.

## How to SLSA 💃

In order to make it easier to generate provenance on GitHub Actions we have
built the
[`slsa-github-generator`](https://github.com/slsa-framework/slsa-github-generator/tree/main)
project which provides a number of GitHub Actions reusable workflows that can
generate SLSA provenance safely.

This can be as simple as adding a call to the SLSA generator reusable workflow
at the end of your release workflow. For example generating provenance for
binary built by GoReleaser might look like the following:

```yaml
jobs:
  goreleaser:
    outputs:
      hashes: ${{ steps.hash.outputs.hashes }}

    steps:
      - name: Checkout repository
        uses: actions/checkout@2541b1294d2704b0964813337f33b291d3f8596b # tag=v3

      - name: Run GoReleaser
        id: run-goreleaser
        uses: goreleaser/goreleaser-action@b953231f81b8dfd023c58e0854a721e35037f28b # tag=v3

      - name: Generate subject
        id: hash
        env:
          ARTIFACTS: "${{ steps.run-goreleaser.outputs.artifacts }}"
        run: |
          set -euo pipefail

          hashes=$(echo $ARTIFACTS | jq --raw-output '.[] | {name, "digest": (.extra.Digest // .extra.Checksum)} | select(.digest) | {digest} + {name} | join("  ") | sub("^sha256:";"")' | base64 -w0)
          if test "$hashes" = ""; then # goreleaser < v1.13.0
            checksum_file=$(echo "$ARTIFACTS" | jq -r '.[] | select (.type=="Checksum") | .path')
            hashes=$(cat $checksum_file | base64 -w0)
          fi
          echo "hashes=$hashes" >> $GITHUB_OUTPUT

  provenance:
    needs: [goreleaser]
    permissions:
      actions: read # To read the workflow path.
      id-token: write # To sign the provenance.
      contents: write # To add assets to a release.
    uses: slsa-framework/slsa-github-generator/.github/workflows/generator_generic_slsa3.yml@v1.9.0
    with:
      base64-subjects: "${{ needs.goreleaser.outputs.hashes }}"
      upload-assets: true # upload to a new release
```

This will generate a signed provenance file that is uploaded to your GitHub
release along with the compiled binary. Users can then verify its authenticity
with the slsa-verifier tool.

```shell
$ slsa-verifier verify-artifact my-go-app \
  --provenance-path my-go-app.intoto.jsonl \
  --builder-id "https://github.com/slsa-framework/slsa-github-generator/.github/workflows/generator_generic_slsa3.yml" \
  --source-uri github.com/ianlewis/my-go-app \
  --source-tag v1.0.0
```

This way we can be sure that `my-go-app` was built by GitHub Actions from the
appropriate repository’s source code.

## Explicit is Better than Implicit

Many folks have read [The Zen of Python](https://peps.python.org/pep-0020/). It
outlines the principles of the Python language and community. But many of its
precepts are broadly applicable. The principle of “Explicit is Better than
Implicit” is one such example that provenance and the SLSA framework take to
heart.

[Dan Lorenc](https://twitter.com/lorenc_dan) at
[Chainguard](https://www.chainguard.dev/) said it best:

[![Bingo! Signatures are empty attestations, or even Implicit Attestations where the subject and predicate are defined out of band by the context of how the signature was generated. Explicit is better than implicit in security!](/assets/images/2024-02-01-code-signing-is-not-enough/6dGDemchbsY5Yj9.png "image_tooltip")](https://twitter.com/lorenc_dan/status/1720818749102575710)

Learn more about the SLSA framework and supply chain security for open source
at [slsa.dev](https://slsa.dev). Also check out the
[slsa-github-generator](https://github.com/slsa-framework/slsa-github-generator)
and [slsa-verifier](https://github.com/slsa-framework/slsa-verifier) projects.

Now let’s all go make some provenance!
