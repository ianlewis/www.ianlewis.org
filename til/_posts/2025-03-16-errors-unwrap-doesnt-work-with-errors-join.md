---
layout: post
title: "TIL: Go's errors.Unwrap doesn't work with errors.Join"
date: "2025-03-16 00:00:00 +0900"
blog: til
tags: go programming
render_with_liquid: false
---

Go 1.20 included the ability to wrap multiple errors at once.

```go
joinWrapped := fmt.Errorf("%w:%w", errors.New("error1"), errors.New("error2"))
```

However, this is implemented using [`errors.Join`](https://pkg.go.dev/errors#Join) which returns an `error` that implements the `Unwrap() []error` method. This means that the returned error cannot be used with `errors.Unwrap`.

```go
fmt.Println(errors.Unwrap(joinedErr)) // nil
```

There doesn't seem to be an equivalent to `errors.Unwrap` for errors returned by `errors.Join` so it seems impossible to traverse errors using only `errors.Unwrap`. You'll need to cast the error to an interface that implements `Unwrap []error`.

```go
type joinedError interface {
  Unwrap() []error
}

jw := joinWrapped.(joinedError)
fmt.Println(jw.Unwrap()) // [error1 error2]
```
