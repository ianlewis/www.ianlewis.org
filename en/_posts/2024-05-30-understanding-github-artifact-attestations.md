---
layout: post
title: "Understanding GitHub Artifact Attestations"
date: 2024-05-30 00:00:00 +0000
permalink: /en/understanding-github-artifact-attestations
blog: en
tags: security slsa
render_with_liquid: false
---

GitHub recently introduced [Artifact
Attestations](https://github.blog/2024-05-02-introducing-artifact-attestations-now-in-public-beta/),
a beta feature that enhances the security of Open Source software supply
chains. By linking artifacts to their source code repositories and GitHub
Actions, it ensures that artifacts are not built with malicious or unknown code
or on potentially compromised devices.

GitHub's blog post and
[documentation](https://docs.github.com/en/actions/security-guides/using-artifact-attestations-to-establish-provenance-for-builds#about-slsa-levels-for-artifact-attestations)
provides a comprehensive explanation of how Artifact Attestations work.
However, some questions remain unanswered, such as the specific security
measures implemented by the verification process, the reasons behind achieving
[SLSA Build Level
2](https://docs.github.com/en/actions/security-guides/using-artifact-attestations-to-establish-provenance-for-builds#about-slsa-levels-for-artifact-attestations)
instead of L3, and potential avenues for further improvement.

I’ll try to shed some light on these aspects, explore areas where enhancements
could be made, and discuss how Artifact Attestations can be leveraged to
achieve SLSA Build Level 3. But first we need to understand its architectural
details and their relationship with SLSA levels.

### Architecture

Generating attestations is done using the
[`attest-build-provenance`](https://github.com/actions/attest-build-provenance)
GitHub action. Github’s blog post does a good job of explaining how it works so
I won’t rehash it fully here. Instead, I’ll summarize the flow and highlight
some additional information that will be important later.

![Architecture Diagram](/assets/images/2024-05-30-understanding-github-artifact-attestations/sigstore.png "Architecture Diagram")

1. `attest-build-provenance` requests an OIDC token from the GitHub OIDC
   provider. This OIDC token contains [information about the
   build](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect#understanding-the-oidc-token)
   in the token claims.

   Here's what a typical OIDC token's fields look like:

   ```json
   {
     "aud": "https://github.com/octo-org",
     "iss": "https://token.actions.githubusercontent.com",
     "job_workflow_ref": "octo-org/octo-automation/.github/workflows/oidc.yml@refs/heads/main",
     "runner_environment": "github-hosted",
     "repository": "octo-org/octo-repo",
     "sha": "example-sha",
     "ref": "refs/heads/main",
     "repository_id": "74",
     "repository_owner": "octo-org",
     "repository_owner_id": "65",
     "workflow": "example-workflow",
     "event_name": "workflow_dispatch",
     "run_id": "example-run-id",
     "run_number": "10",
     "run_attempt": "2",
     "repository_visibility": "private"
     // ...
   }
   ```

2. The OIDC token is sent to a [Sigstore
   Fulcio](https://github.com/sigstore/fulcio) server (either the public
   instance or GitHub’s private one). [Fulcio can recognize and validate
   GitHub’s OIDC
   tokens](https://docs.sigstore.dev/certificate_authority/oidc-in-fulcio/#github)
   and, after verifying its signature, issues a certificate in exchange for the
   OIDC token. This certificate includes much of the information from the OIDC
   token [mapped into its OID extension
   fields](https://github.com/sigstore/fulcio/blob/main/docs/oid-info.md#mapping-oidc-token-claims-to-fulcio-oids)
   as OID claims.

   ```shell
   $ openssl x509 -in certificate.crt -text -noout
   ...
   X509v3 extensions:
       X509v3 Key Usage: critical
           Digital Signature
       X509v3 Extended Key Usage:
           Code Signing
       X509v3 Subject Key Identifier:
           40:16:4D:A9:02:0E:97:E7:40:BA:A1:72:87:1A:1B:D0:FF:A4:30:FF
       X509v3 Authority Key Identifier:
           DF:D3:E9:CF:56:24:11:96:F9:A8:D8:E9:28:55:A2:C6:2E:18:64:3F
       X509v3 Subject Alternative Name: critical
           URI:https://github.com/ianlewis/gha-artifact-attestations-test/.github/workflows/artifact-attestations.basic.yml@refs/heads/main
       1.3.6.1.4.1.57264.1.1:
           https://token.actions.githubusercontent.com
       1.3.6.1.4.1.57264.1.2:
           push
       1.3.6.1.4.1.57264.1.3:
           9e68bb76632788dc01c6596298fb015f46b7fe0f
       1.3.6.1.4.1.57264.1.4:
           Test Artifact Attestations
       1.3.6.1.4.1.57264.1.5:
          ianlewis/gha-artifact-attestations-test
       1.3.6.1.4.1.57264.1.6:
          refs/heads/main
       1.3.6.1.4.1.57264.1.8:
          .+https://token.actions.githubusercontent.com
       1.3.6.1.4.1.57264.1.9:
          .|https://github.com/ianlewis/gha-artifact-attestations-test/.github/workflows/artifact-attestations.basic.yml@refs/heads/main
       1.3.6.1.4.1.57264.1.10:
          .(9e68bb76632788dc01c6596298fb015f46b7fe0f
       1.3.6.1.4.1.57264.1.11:
          github-hosted   .
       1.3.6.1.4.1.57264.1.12:
          .:https://github.com/ianlewis/gha-artifact-attestations-test
   ...
   ```

3. A SLSA
   [predicate](https://github.com/in-toto/attestation/blob/main/spec/v1/predicate.md)
   is generated and the provenance statement is signed with the returned
   certificate’s private key. The resulting signature is combined with the
   provenance to create a full attestation bundle and this bundle is recorded
   in GitHub’s attestation store.

   The SLSA predicate looks something like this:

   ```json
   {
     "buildDefinition": {
       "buildType": "https://slsa-framework.github.io/github-actions-buildtypes/workflow/v1",
       "externalParameters": {
         "workflow": {
           "ref": "refs/heads/main",
           "repository": "https://github.com/ianlewis/gha-artifact-attestations-test",
           "path": ".github/workflows/artifact-attestations.basic.yml"
         }
       },
       "internalParameters": {
         "github": {
           "event_name": "push",
           "repository_id": "803607921",
           "repository_owner_id": "49289"
         }
       },
       "resolvedDependencies": [
         {
           "uri": "git+https://github.com/ianlewis/gha-artifact-attestations-test@refs/heads/main",
           "digest": {
             "gitCommit": "9e68bb76632788dc01c6596298fb015f46b7fe0f"
           }
         }
       ]
     },
     "runDetails": {
       "builder": {
         "id": "https://github.com/actions/runner/github-hosted"
       },
       "metadata": {
         "invocationId": "https://github.com/ianlewis/gha-artifact-attestations-test/actions/runs/9171197474/attempts/1"
       }
     }
   }
   ```

I'm leaving out some details but this is the general flow for attestation. So as
a result we have _both_ an attestation bundle in JSON format _and_ this
includes the Sigstore certificate with some OID claims set.

After we have an artifact and attestation, as a user, we need to be able to
verify it before we use it. Verification works something like the following. The
code for this is found in the [`gh attestations verify`
command](https://github.com/cli/cli/tree/trunk/pkg/cmd/attestation/verify)
for GitHub’s official CLI tool.

1. The attestation is downloaded from the GitHub Attestations API using the
   artifact’s digest.
2. The attestation’s signature is verified against the public key used to sign
   it, and to the certificate chain for either the GitHub Fulcio instance, or
   the public Sigstore Fulcio instance (the root certificates are managed using
   [TUF](https://theupdateframework.io/)).
3. The expected values for the owner or repo given by the user are matched
   against the signing certificate’s OID claims.

Notice that nowhere here is it actually necessary use the contents of the SLSA
predicate for verification. It isn't really necessary if you are treat the
certificate itself as the provenance.

Next, let's discuss some of the trade-offs of this architecture.

### A Good User Experience

One of the positive aspects of Artifact Attestations is its user experience. By
providing a GitHub Action, GitHub gives users flexibility when integrating this
into their GitHub Actions workflows. All it takes is to add a job step to your
workflow and pass it a path to your artifact file.

```
- name: Attest Build Provenance
  uses: actions/attest-build-provenance@897ed5eab6ed058a474202017ada7f40bfa52940 # v1.0.0
  with:
    subject-path: "bin/my-artifact.tar.gz"
```

Easy-to-use UX is really important for security because it increases adoption.
This can’t be understated and is an often overlooked aspect of security
software.

### Why SLSA Build L2 and not L3?

If this is a fairly secure solution, why is this SLSA Build L2 and not L3? The
main reason is that, by itself, the `attest-build-provenance` action doesn’t
meet this requirement for [SLSA Build
L3](https://slsa.dev/spec/v1.0/levels#build-l3-hardened-builds):

_> prevent secret material used to sign the provenance from being accessible to the user-defined build steps._

Because GitHub Actions are run in the same job VM with other build steps there
is a chance that the user-defined build steps could access the secret material,
namely the certificate’s private key provided by Fulcio, and use it for
nefarious purposes. Normally an attacker, by compromising the build, might be
able to use this key material to make up their own provenance for a malicious
artifact and sign it with the key.

However, as we’ll see, this kind of attack is somewhat mitigated by using Sigstore.

### SLSA Build L2+?

By using Sigstore’s Fulcio, the certificate used to sign the provenance contains
much of the SLSA predicate's information in its OID claims. These claims are
signed by part of Fulcio instance’s certificate chain and thus cannot be
modified by the user-defined build steps unless the Sigstore instance or
GitHub’s OIDC provider are compromised.

While the SLSA predicate itself might be modified the certificate OID claims
cannot. So GitHub can check the OID claims against the expected values to verify
them even though the user-defined build steps had access to the signing key.
This is why verification doesn’t rely on the predicate and instead relies on the
certificate’s OID claims for verification.

Some folks have colloquially referred to this combination of Sigstore and SLSA
Build L2 as SLSA Build L2+ since it provides some of the benefits of SLSA Build
L3 without actually fulfilling all of the requirements of L3.

### The Limits of SLSA Build L2+

However, this comes with a few caveats.

**First**, a compromised build with access to signing keys poses the threat of
using the key to sign and [publish malicious packages on a mirror
repository](https://checkmarx.com/blog/over-170k-users-affected-by-attack-using-fake-python-infrastructure/).
Sigstore's Fulcio mitigates this by providing short-lived keys with a validity
of 10 minutes, but attackers could still exfiltrate the key and use the key
within this time period to leave less evidence.

**Second**, if user-defined build steps have access to the signing keys,
**only** the information in the certificate's OID claims is trustworthy.
Information not in the OID claims can't be included in the SLSA predicate,
affecting more complex data like GitHub Actions workflow
[inputs](https://docs.github.com/en/actions/learn-github-actions/contexts#inputs-context)
and
[vars](https://docs.github.com/en/actions/learn-github-actions/contexts#vars-context)
contexts. While these can't attack the provenance, they could be used to attack
the build without leaving a trace, making incident response more challenging.

**Third**, the architecture heavily relies on Sigstore's Fulcio Certificate
Authority for mapping OID claims, making it difficult to use private PKI to sign
and verify provenance. While this isn't necessarily a significant concern for
open-source projects, some enterprises have such requirements.

### Achieving SLSA Build L3 with GitHub Artifact Attestations

In the documentation [SLSA Build L3 is described as
achievable](https://github.blog/2024-05-02-introducing-artifact-attestations-now-in-public-beta/#an-effortless-user-experience)
but it focuses on SLSA Build L2(+) and L3 is left as an exercise for the reader.
So what would it take to achieve SLSA Build L3 with GitHub Artifact
Attestations?

One way that we have used in the
[slsa-github-generator](https://github.com/slsa-framework/slsa-github-generator/tree/main)
project is to use [reusable
workflows](https://docs.github.com/en/actions/using-workflows/reusing-workflows).
This uses the fact that code in reusable workflows are isolated from the main
workflow because they run on jobs executed on [separate virtual
machines](https://docs.github.com/en/actions/learn-github-actions/understanding-github-actions#the-components-of-github-actions).

However, this comes with the downside that it is not quite as user friendly as a
simple GitHub Action. Passing data, especially files, between jobs is more
complicated and we are sometimes forced to expose that complexity to the user.
Given that there are significant security improvements, I think it’s worth it.

### Conclusion

Trust in GitHub’s Artifact Attestations trust really lies in the Sigstore
certificate and its OID claims so the certificate itself effectively functions
as the provenance. SLSA doesn’t even mandate that provenance be in SLSA format,
but the architecture of Artifact Attestations does make it a bit more
complicated to reason about the security implications. You shouldn't need to
trust the build when creating attestations.

Artifact attestations are a really exciting new feature on GitHub and a great
step in the right direction. I would strongly consider integrating it into your
workflows, but first take a look at
[slsa-github-generator](https://github.com/slsa-framework/slsa-github-generator/)
and see if SLSA L3 isn’t achievable for your projects.

_Thanks to [Hayden Blauzvern](https://twitter.com/haydentherapper), [Ramon
Petgrave](https://twitter.com/thePetgrave), and [Laurent
Simon](https://twitter.com/lsim99) for reviewing this post._
