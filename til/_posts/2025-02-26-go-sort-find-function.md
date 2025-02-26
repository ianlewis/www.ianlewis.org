---
layout: post
title: "Go's sort.Find function"
date: "2025-02-26 00:00:00 +0900"
blog: til
tags: go programming
render_with_liquid: false
---

Today I learned about the `sort.Find` function in the Go standard library. It performs a binary search over a sorted array when provided with a comparator function.

```go
sorted := make([]string, 150)
slices.SortFunc(sorted, strings.Compare)

// Search for target in sorted from [0,n)
target := "some query"
n := len(sorted)
if i, found := sort.Find(n, func(i int) int {
    return strings.Compare(target, sorted[i])
}); found {
    fmt.Println("value found at index %d", i)
}
```

This worked well for a searching simple dictionary index in the [`go-stardict`](https://github.com/ianlewis/go-stardict) library I've been working on.
