---
layout: post
title: "Zero Copy Readers in Go"
date: 2025-03-31 00:00:00 +0000
permalink: /en/zero-copy-readers-in-go
blog: en
tags: tech programming golang
render_with_liquid: false
---

The `io.Reader` interface is a small interface that defines a single `Read`
method. Callers to a `Reader` implementation pass a byte slice which is then
filled with bytes from the underlying source. This source could be a file, a
network socket, etc.

```go
type Reader interface {
   Read(p []byte) (n int, err error)
}
```

However, this interface presents a challenge. It necessitates that the bytes
from the source be copied into the byte slice which is given by the caller. In
the case where the source is already in memory, it would be more efficient to
allow the caller to read directly from the array that is already in memory. In
this post I’ll go over a couple of examples of this scenario.

## Slices and Arrays in Go

It’s useful to quickly review slices in Go. The post [Go Slices: usage and
internals](https://go.dev/blog/slices-intro) from the Go blog provides a good
overview of their implementation.

Slices are backed by an array in memory and the slice provides a “view” of sorts
over a subset of the array.

```go
a := [10]int{0, 1, 2, 3, 4, 5, 6, 7, 8, 9}
s := a[3:6] // 3,4,5
fmt.Println(cap(s)) // 7, indicating the capacity from slice start to end of array
```

[Go Playground](https://go.dev/play/p/X6rD2o1Xxp9)

The slice however will retain the full backing array in memory. This means that
you can create slices to view subsets of the data without allocating a new array
and copying data into it. One caveat is that if you overwrite data in the slice
the original array will be modified.

We would like to use this property of slices to be able to read over arrays
without making unnecessary copies.

## bytes.Reader

[`bytes.Reader`](https://pkg.go.dev/bytes#Reader) is a popular type which
implements the `io.Reader` interface over a byte slice. Unfortunately, this
doesn't allow for zero copy reads from the underlying `[]byte` by directly using
the methods. Instead, you have to take a more indirect route and use `WriteTo`
in which `bytes.Reader` will pass a slice of the underlying `[]byte` to the
given `io.Writer`. This allows us to read the underlying data without making
copies.

```go
type zeroCopyWriter struct{}

func (w *zeroCopyWriter) Write(b []byte) (int, error) {
    fmt.Printf("%v", b)
    return len(b), nil
}

func main() {
    r := bytes.NewReader([]byte("Hello, 世界"))
    r.WriteTo(&zeroCopyWriter{})
}
```

[Go Playground](https://go.dev/play/p/kItYT6Cr9KX)

## `bufio.Reader`

The [`bufio.Reader`](https://pkg.go.dev/bufio#Reader) in Go reads from an
underlying `io.Reader` and stores the data in a buffer. This allows the program
to make fewer read system calls by batching them, and allowing the caller to
read from the stored buffer instead.

When a call to `bufio.Reader.Read` is made, if the reader’s buffer does not have
enough bytes the `bufio.Reader` makes a call to the underlying `io.Reader` to
fill the buffer whose default size is 4096 bytes. Usually this results in a
`read` system call to read from a file or network socket. The bytes are then
returned from the buffer. Once the buffer is filled however, any subsequent
calls can be read directly from the buffer provided it contains enough data.
This is very helpful as many programs will make many small calls to `Read` which
could degrade performance if every call resulted in a system call to the
operating system.

This first copy into the buffer can’t be avoided but we can avoid a second copy
from the buffer into another array. We can’t do this with the `Read` method but
we can use a combination of the `Buffered`, `Peek`, and `Discard` methods.

```go
b := []byte("Hello, 世界")
r := bufio.NewReader(bytes.NewReader(b))

// Determine how many bytes to read.
numBytesToRead := r.Buffered()
if numBytesToRead < 5 {
    numBytesToRead = 5
}


// Get a slice of the buffer.
p, _ := r.Peek(numBytesToRead)
fmt.Println(string(p))

// Discard the bytes read.
_, _ = r.Discard(len(p))
```

[Go Playground](https://go.dev/play/p/Sqc1IhuokPl)

`Peek` gives us a slice of the underlying buffer which allows us to read from
the buffer directly. We can then call `Discard` to advance the reader after
processing the bytes. Because the slice returned by `Peek` points to the
underlying byte array it is no longer valid after the reader is advanced because
the buffer could have been overwritten.

I used this style when implementing my buffered rune reader in
[`ianlewis/runeio`](https://github.com/ianlewis/runeio) so that callers can peek
at the rune stream without advancing the reader with zero copy semantics.
