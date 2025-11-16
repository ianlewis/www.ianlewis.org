---
layout: post
title: "TIL: November 16, 2025 - Weekly Reading: Security and AI"
date: "2025-11-16 00:00:00 +0900"
blog: til
tags: weekly-reading ai security programming rust
render_with_liquid: false
---

## Security

- [Rust in Android: move fast and fix things](https://security.googleblog.com/2025/11/rust-in-android-move-fast-fix-things.html) - _Jeff Vander Stoep, Android_

    More new Rust code is now being added to Android's codebase than C++ and
    requires less time to review. Rust seems to be a win/win for both security
    and productivity in Android development. It's nice to see they are using the
    Rust support in the Linux kernel and writing drivers in Rust.

    I have a feeling that C++ isn't really a good choice for projects anymore.
    You'll likely get better value from a memory-safe language like Rust or Go.
    If you need performance that Rust can't provide, you're probably better off
    writing the hot paths in assembly or offloading to specialized hardware than
    using C++.

- [FFmpeg to Google: Fund Us or Stop Sending Bugs](https://thenewstack.io/ffmpeg-to-google-fund-us-or-stop-sending-bugs/) - _Steven J. Vaughan-Nichols_

    FFmpeg is used by a lot of companies like Google for video processing. Given
    that FFmpeg supports lots of video formats and codecs, and is written in C,
    new security vulnerabilities are frequently discovered.

    FFmpeg folks complained that Google doesn't give them enough time to fix the
    vulnerabilities before making them public. This applies pressure to FFmpeg
    developers who are working without compensation. I have a lot of sympathy
    with this point of view.

    Dan Lorenc's (Chainguard) position is that vulnerability disclosures are
    also a contribution to the commons (by Google in this case) and FFmpeg folks
    should be grateful I guess? While I agree that complaining loudly in public
    isn't likely to do FFmpeg any favors, I feel like companies like Google
    aren't really going to contribute meaningfully to open source projects
    unless they absolutely have to. So it makes sense for FFmpeg to use what
    leverage they have.

## Artificial Intelligence (Machine Learning)

- MPI Tutorial for Machine Learning - [Part 1](https://medium.com/@thiwankajayasiri/mpi-tutorial-for-machine-learning-part-1-3-6b052abe3f29), [Part 2](https://medium.com/@thiwankachameerajayasiri/mpi-tutorial-for-machine-learning-part-2-3-ebe72d0a0b04), [Part 3](https://medium.com/@thiwankachameerajayasiri/mpi-tutorial-for-machine-learning-part-3-3-1a3f219ee6bc) -- _Thiwanka Chameera Jayasiri_

    A nice tutorial series on using Message Passing Interface (MPI) for
    distributed machine learning. MPI is a protocol for message-passing in
    distributed applications. It's often used in machine learning to pass model
    parameters and gradients between multiple nodes during training.

    The series covers the basics of MPI, setting up the environment, and
    implementing distributed training using data parallelism in some popular
    frameworks.
