---
layout: post
title: "TIL: August 25, 2025 - Weekly Reading: Kubernetes swap, and beating Dijkstra's algorithm"
date: "2025-08-25 00:00:00 +0900"
blog: til
tags: weekly-reading kubernetes programming
render_with_liquid: false
---

## Kubernetes

- [Tuning Linux Swap for Kubernetes: A Deep
  Dive](https://kubernetes.io/blog/2025/08/19/tuning-linux-swap-for-kubernetes-a-deep-dive/)
  -- _Ajay Sundar Karuppasamy_

    With the new [`NodeSwap`
    feature](https://kubernetes.io/docs/concepts/cluster-administration/swap-memory-management/)
    becoming stable in Kubernetes 1.34, using Linux swap in Kubernetes clusters
    becomes more viable as a way to deal with memory management. Starting with
    Kubernetes 1.34, pods will be able to use swap memory without enabling
    unstable features.

    Swap limits and usage are configured automatically by Kubernetes and set by
    the container runtime via the cgroups v2 (cgroups v1 is not supported)
    `memory.swap.max` parameter. Pods need to have the `Burstable` memory QoS
    class (`BestEffort` and `Guaranteed` pods cannot use swap) and the limit is
    [calculated](https://kubernetes.io/docs/concepts/cluster-administration/swap-memory-management/#how-is-the-swap-limit-being-determined-with-limitedswap)
    proportionate to the memory request and total swap space available on the
    node.

## Programming

- [Breaking the Sorting Barrier for Directed Single-Source Shortest
  Paths](https://arxiv.org/abs/2504.17033) -- _Ran Duan, Jiayi Mao, Xiao Mao,
  Xinkai Shu, Longhui Yin_

    A faster alternative to Dijkstra's algorithm has been developed by a team of
    researchers at Tsinghua University, led by Professor Duan Ran. The new
    algorithm improves the time complexity of finding the shortest path in a
    graph from `O(m + n log n)` (where `n` = nodes, `m` = edges) to
    `O(m * log^(2/3) n)`.

    Dijkstra's algorithm, used a priority queue to rank all unexplored nodes by
    their distances. The new algorithm, avoids this sorting by using the
    [Bellman-Ford
    algorithm](https://en.wikipedia.org/wiki/Bellman%E2%80%93Ford_algorithm) and
    the [recursive partial ordering method](https://arxiv.org/abs/1808.10658)
    previously developed by Duan and others.
