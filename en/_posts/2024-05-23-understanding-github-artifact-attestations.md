---
layout: post
title: "Understanding GitHub Artifact Attestations"
date: 2024-05-23 00:00:00 +0000
permalink: /en/understanding-github-artifact-attestations
blog: en
tags: security slsa
render_with_liquid: false
---

GitHub recently released [GitHub Actions Artifact
Attestations](https://github.blog/2024-05-02-introducing-artifact-attestations-now-in-public-beta/)
in beta.

Artifact Attestations are a great step forward in improving the supply chain
security of Open Source software. It links an artifact to its source code
repository and to GitHub Actions. This means that we can be sure that it wasn’t
built with some unknown, potentially malicious source code or on a random
person’s laptop.

GitHub did a great job explaining how it works in their blog post. They also
have some more comprehensive
[documentation](https://docs.github.com/en/actions/security-guides/using-artifact-attestations-to-establish-provenance-for-builds#about-slsa-levels-for-artifact-attestations)
on artifact attestations. However, there are a few questions one might ask and
aren't covered. What does verification do and why is it secure? Why does it say
that artifact attestations achieve [SLSA v1.0 Build Level 2 and not
L3](https://docs.github.com/en/actions/security-guides/using-artifact-attestations-to-establish-provenance-for-builds#about-slsa-levels-for-artifact-attestations)?
How could you achieve L3 with artifact attestations?

I’ll do my best to answer some of these questions here. But first we need to
understand a bit about how GitHub Artifact Attestations work and their relation
to SLSA levels.

## Architecture

Generating attestations is done using the
[`attest-build-provenance`](https://github.com/actions/attest-build-provenance)
GitHub action. Github’s blog post does a good job of explaining how it works so
I won’t rehash it fully here. I’ll just summarize the flow and highlight some
additional information that will be important later.

1. `attest-build-provenance` requests an OIDC token from the GitHub OIDC
   provider. This OIDC token contains [information about the
   build](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect#understanding-the-oidc-token)
   in the token claims.
2. The OIDC token is sent to a [Sigstore
   Fulcio](https://github.com/sigstore/fulcio) server (either the public
   instance or GitHub’s private one). [Fulcio can recognize and validate GitHub’s
   OIDC
   tokens](https://docs.sigstore.dev/certificate_authority/oidc-in-fulcio/#github)
   and, after verifying its signature, issues a certificate in exchange for the
   OIDC token. This certificate includes much of the information from the OIDC
   token [mapped into its OID extension
   fields](https://github.com/sigstore/fulcio/blob/main/docs/oid-info.md#mapping-oidc-token-claims-to-fulcio-oids)
   as claims.
3. A SLSA attestation
   [predicate](https://github.com/in-toto/attestation/blob/main/spec/v1/predicate.md)
   is generated and the provenance statement is signed with the returned
   certificate’s private key. The resulting signature is combined with the
   provenance to create a full attestation bundle and this bundle is recorded in
   GitHub’s attestation store.

I'm leaving out some details but this is the general flow for attestation. So
as a result we have an attestation bundle in JSON format and a Sigstore
certificate with some OID claims set.

After we have an artifact and attestation, as a user, we need to be able to
verify it before we use it. Verification works something like the following.
The code for this is found in the [`gh attestations verify
command`](https://github.com/cli/cli/tree/trunk/pkg/cmd/attestation/verify)
for GitHub’s official CLI tool.

1. The attestation is downloaded from the GitHub Attestations API using the
   artifact’s digest.
2. The attestation’s signature is verified against the public key used to sign
   it, and to the certificate chain for either the GitHub Fulcio instance, or
   the public Sigstore Fulcio instance (the root certificates are managed using
   [TUF](https://theupdateframework.io/)).
3. The expected values for the owner or repo given by the user are matched
   against the signing certificate’s OID claims.

Notice that nowhere here did we actually use the contents of the SLSA
predicate for verification. We’ll discuss why this is below.

## A Good User Experience

By providing a GitHub Action, GitHub gives users the maximum amount of
flexibility when integrating this into their GitHub Actions workflows. It’s
really easy to add a job step to your workflow and pass it a path to your
artifact file.

```
- name: Attest Build Provenance
  uses: actions/attest-build-provenance@897ed5eab6ed058a474202017ada7f40bfa52940 # v1.0.0
  with:
    subject-path: "bin/my-artifact.tar.gz"
```

Easy-to-use UX is really important for security because it increases adoption.
This can’t be understated and is an often overlooked aspect of security
software.

## Why SLSA Build L2?

But if this is a fairly secure solution, why is this SLSA Build L2 and not L3?
The main reason is that, by itself, the `attest-build-provenance` action
doesn’t meet this requirement for [SLSA Build
L3](https://slsa.dev/spec/v1.0/levels#build-l3-hardened-builds):

prevent secret material used to sign the provenance from being accessible to the user-defined build steps.

Because GitHub Actions are run in the same job VM with other build steps there
is a chance that the user-defined build steps could access the secret material,
namely the certificate’s private key provided by Fulcio, and use it for
nefarious purposes. Normally an attacker, by compromising the build, might be
able to use this key material to make up their own provenance for a malicious
artifact and sign it with the key.

However, as we’ll see, this kind of attack is mostly mitigated by using Sigstore.

## SLSA Build L2+?

By using Sigstore’s Fulcio, the certificate used to sign the provenance
contains much of the SLSA predicate's information in its OID claims. These
claims are signed by part of Fulcio instance’s certificate chain and thus
cannot be modified by the user-defined build steps unless the Sigstore instance
or GitHub’s OIDC provider are compromised.

So while the SLSA predicate itself might be modified the certificate OID
claims cannot. So GitHub can check the OID claims against the expected values
in order to verify them even though the user-defined build steps had access to
the signing key. So this is why verification doesn’t rely on the predicate
and instead relies on the certificate’s OID claims for verification.

Some folks have colloquially referred to this combination of Sigstore and SLSA
Build L2 as SLSA Build L2+ since it provides some of the benefits of SLSA Build
L3 without actually fulfilling all of the requirements of L3.

## Limits of SLSA Build L2+

However, this comes with a caveat. This means that if the user-defined build
steps could have access to the signing keys then **only** the information in
the certificate’s OID claims are trustworthy. No information that isn’t
included in these claims can be included in the SLSA predicate because it can’t
be verified later.

Crucially this includes values like the GitHub Actions workflow
[`inputs`](https://docs.github.com/en/actions/learn-github-actions/contexts#inputs-context)
and
[`vars`](https://docs.github.com/en/actions/learn-github-actions/contexts#vars-context)
contexts. These include the inputs into a build and could potentially be used
for script injection attacks. While they can’t be used to attack the provenance
itself, they could be used to attack the build without leaving any trace in the
provenance.

This means that while GitHub Artifact Attestations can be used with policy
engines/tools like Rego, Cue, and OPA, these policies can’t be evaluated on the
build inputs. For example, to verify that the build had no inputs etc. in order
to prevent these kinds of attacks.

This architecture also relies heavily on Sigstore’s Fulcio Certificate
Authority to map the OID claims. This means that it’s hard to use separate
private PKI, such as static keys, to sign and verify provenance. While this
isn’t likely a problem for Open Source projects, some enterprises have these
kinds of requirements.

## Achieving SLSA Build L3 with GitHub Artifact Attestations

In the documentation [SLSA Build L3 is described as
achievable](https://github.blog/2024-05-02-introducing-artifact-attestations-now-in-public-beta/#an-effortless-user-experience)
but it focuses on SLSA Build L2(+) and L3 is left as an exercise for the
reader. So what would it take to achieve SLSA Build L3 with GitHub Artifact
Attestations?

The solution is somewhat complex so I will just summarize the requirements here
and leave the details for a later blog post. In order to achieve L3 you, at a
minimum, would roughly need to do the following things:

- The artifact build would need to be done in a separate job from the call to
  `attest-build-provenance`. This ensures that the build and provenance signing
  happen on [separate virtual
  machines](https://docs.github.com/en/actions/learn-github-actions/understanding-github-actions#the-components-of-github-actions)
  and that the artifact build steps will not have access to the signing
  material. This job should **not** have `attestations: write` permissions.
- The `attest-build-provenance` action is passed a path to the artifact. Jobs
  execute on separate VMs so the artifact itself would need to be passed from
  the build job to the attestation job. This will need to be done by uploading
  the artifact file as a [workflow
  artifact](https://docs.github.com/en/actions/using-workflows/storing-workflow-data-as-artifacts)
  from the first job and downloading it in the second job. However, this
  artifact could be overwritten by concurrently running build steps. So you
  will need to take a checksum (sha256 etc.) and pass it from the build job to
  the provenance signing job using job inputs/outputs, and verify it after
  download.

## Conclusion

Trust in GitHub’s Artifact Attestations trust really lies in the Sigstore
certificate and its OID claims. The signed SLSA provenance is really only nice
to have. GitHub ensures that the JSON printed by the `gh` client’s `--format
json` option is trustworthy simply by forbidding values in the SLSA provenance
JSON that are different from the certificate’s OID claims. This means that the
certificate itself effectively functions as the provenance. This is fine, SLSA
doesn’t even mandate that provenance be in SLSA format, but it’s an important
point to understand.

As an aside, it’s interesting to note that GitHub’s [npm package
provenance](https://github.blog/2023-04-19-introducing-npm-package-provenance/),
which was announced last year, shares many of the same architectural benefits
and shortcomings we’ve discussed here.

In the future I’d like to see more CI/CD systems that are more conducive to
verifiable software supply chains.

1. Well defined build inputs and outputs.
2. Builds that are isolated from each other. More build primitives for isolation.
3. Provenance generation that is decoupled from signing
4. More options for verifiable reproducibility.
5. Multi-tenant transparency logs for organizations and private repos

Maybe one day.

In the meantime, GitHub’s Artifact attestations are a really exciting new
feature on GitHub and a great step in the right direction. I would strongly
consider integrating it into your workflows, and artifact verification into your
deployments.
