---
layout: post
title: "Rust First Impressions: Error Handling"
date: 2025-02-03 00:00:00 +0000
permalink: /en/rust-first-impressions-error-handling
blog: en
tags: tech programming rust rust-first-impressions
render_with_liquid: false
image: /assets/images/2025-02-03-rust-first-impressions-error-handling/Gemini_Generated_Image_61aptz61aptz61ap.jpeg
---

![An cartoon image of a crab that was alerted to some danger, showing an exclamation point above the crab's head](/assets/images/2025-02-03-rust-first-impressions-error-handling/Gemini_Generated_Image_61aptz61aptz61ap.jpeg){:style="width: 50%; display:block; margin-left:auto; margin-right:auto"}

For the 2024 edition of Advent of Code I decided to finally give Rust a try and
implement the puzzle solutions in the language. Rust has been pretty stable for
more than a decade so I suppose learning it was far past due.

I want to write some of my first impressions of the language as much to help
sharpen and collect my thoughts as much as to share them with others. I’ll also
be coming at this mostly from the perspective of a Go programmer since that’s
probably my strongest language at the moment.

Given that I was mostly focusing on Advent of Code puzzles I haven’t really had
a chance to dive into the many popular crates that are out there, so I’ll
mostly be talking about core language features. Three big ones jump out as
being different enough that they would trip up new learners, myself included.
Those three are error handling, the type inference engine, and the ownership &
borrowing model. I will be writing about each of these in separate blog posts.
In this post I’ll be focusing on error handling.

## The Result type

Rust returns errors as part of the [Result
type](https://doc.rust-lang.org/std/result/). Results are implemented as an
`enum` with a return value XOR a error value and include a number of methods
like `expect`, `unwrap`, `unwrap_or`, `unwrap_or_default`, and `unwrap_or_else`
that simplify error handling. Each of these methods are basically an `if`
statement that does different things in the case that an error is encountered.
This heavily favors the style in Rust of chaining logic together and using
closures which can easily get unwieldy.

```rust
// Why this?
if result.is_err_and(|x| x.kind() == ErrorKind::NotFound) { /* … */ }

// … when you could do this? (unfortunately, combining the ifs is unstable(?))
if let Err(e) = result {
  if e.kind() == ErrorKind::NotFound { /* … */ }
}
```

In Go errors are generally returned in a simple tuple and checked with `if`
statements. This removes the need for wrapper type and makes the logic easier
to follow. Go’s `fmt` package also includes errors that can be wrapped in other
errors allowing error types to be retained at each stack level.

```go
x, err := SomeFunc()
if err != nil && errors.Is(err, fs.IsNotExist) {
    // …
}
```

In Rust, the fact that the Result can have only one of either a return value or
an error means that there is less of a chance that someone will attempt to use
the return value when an error is given. In practice, I haven't found this to
be too much of an issue with Go and in some cases it's useful to have both a
return value and error but I suppose Rust's approach is a bit safer overall.

One other thing that is nice about the Result type is that it is annotated with
the `#[must_use]` attribute which allows the compiler to issue a warning if the
error isn’t handled. In Go, popular linters will make this check but it’s nice
that it’s built into the compiler for Rust.

## Errors are values

Rust’s error handling is probably the easiest to grasp of the three features I
mention here. Rust joins Go in taking the approach that [errors are
values](https://go.dev/blog/errors-are-values). Rust doesn’t have exceptions as
they have gone out of favor due to their tendency to cause jumps to unexpected
areas of the codebase. Instead of exceptions, recoverable errors are returned
as return values to be handled by the caller. Unrecoverable errors will
generally be represented by the program panicking. Both Rust and Go are similar
in that manner.

I am personally sympathetic to this given the general lack of ways to help
programmers handle exceptions in other languages. For languages like
JavaScript, Ruby, and Python functions are not annotated with the exceptions
they throw so it’s very hard to know what errors could occur when calling it.
Some languages like Java have checked exceptions. Java also makes the
distinction between “exceptions”, which are recoverable errors, and “errors”
which are (generally) not.

While widely used by languages, exceptions can cause programs to jump to
unexpected areas of the codebase and it can be very hard to follow what code
will be executed next after an exception is thrown. Even in the best case
scenario you need to follow the function’s call chain all the way back to where
the exception is caught, and even then it could be re-thrown!

Treating errors as values handles these issues by returning errors from
function calls. It also allows for more creative handling of errors by
recording them or composing them with other user-defined types. In Go, errors
can be composed to great effect to [simplify repetitive error
handling](https://go.dev/blog/error-handling-and-go).

```go
type errWriter struct {
    w   io.Writer
    err error
}

func (ew *errWriter) write(buf []byte) {
    if ew.err != nil {
        return
    }
    _, ew.err = ew.w.Write(buf)
}

ew := &errWriter{w: fd}
ew.write(p0[a:b])
ew.write(p1[c:d])
ew.write(p2[e:f])
// and so on
if ew.err != nil {
    return ew.err
}
```

This doesn’t seem to be done as much in Rust as it has opted to have the
built-in question mark for [repetitive error
propagation](https://doc.rust-lang.org/book/ch09-02-recoverable-errors-with-result.html#a-shortcut-for-propagating-errors-the--operator).
So there isn’t as much opportunity to make use of the idea that errors are
values quite as much.

```rust
w.write(buf[a:b])?;
w.write(buf[c:d])?;
w.write(buf[e:f])?;
```

## The Error trait

In Rust errors returned in a `Result` must implement the [Error
trait](https://doc.rust-lang.org/std/error/trait.Error.html). Rust allows you
to create user-defined error types but the `Error` trait is rather verbose to
implement. Here is probably the shortest way to create a custom error using the
standard library.

```rust
use std::error::Error;
use std::fmt;

#[derive(Debug)]
struct SomeError;

impl fmt::Display for SomeError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "Some error happened")
    }
}

impl Error for SomeError {}
```

Go’s `error` interface is rather simple by comparison and only requires you to
implement the `Error` method which returns the error as a string. There are
some Rust crates like [anyhow](https://docs.rs/anyhow/latest/anyhow/) and
[thiserror](https://docs.rs/thiserror/latest/thiserror/) to make creating error
types easier but right now I find them to be a bit overkill.

```go
type SomeError struct {}

func (e SomeError) Error() string {
return "Some error happened"
}
```

## Questions but not many answers

I mentioned that treating errors as values can create repetitive error handling
code. Rust has the built-in question mark (?) which inserts logic to the effect
of:

```rust
// This is equivalent
SomeFunc()?;

// … to this.
let result = SomeFunc();
if let Err(e) = result {
    return Err(e);
}
```

This is nice because it can make the code much more concise. However, it can
also make it harder to follow where the errors are coming from. Rust’s use of
question marks and long method chains can also make it hard to know what code
is covered by tests and if all error conditions are being tested since coverage
tools often look at code lines.

```rust
// Are all of these errors being tested?
SomeFunc()?.parse::<usize>()?.checked_add_signed(i).ok_or_else(|| 0)?;
```

Propagating errors in Rust is a bit tricky and it took me a while to figure out
how to do it right. To return an `Error` from a function that may return any
number of error types, it needs to be returned as a `Box<dyn Error>`. The
aforementioned `anyhow` and `thiserror` libraries have more features and are
widely used. Error types are also returned directly and pre-defined as an
`enum` and/or converted between error types with the [`From
trait`](https://doc.rust-lang.org/std/convert/trait.From.html).

```rust
#[derive(Debug)]
enum SomeError {
    ParseError(std::num::ParseIntError),
    IoError(std::io::Error),
}

impl From<std::num::ParseIntError> for SomeError {
    fn from(err: std::num::ParseIntError) -> Self {
        NumFromFileErr::ParseError(err)
    }
}

impl From<std::io::Error> for NumFromFileErr {
    fn from(err: std::io::Error) -> Self {
        NumFromFileErr::IoError(err)
    }
}
```

Now we can define a function that returns the `SomeError` error type.

```rust
fn some_func() -> Result<(), SomeError> {
    // We can return std::num::ParseIntError and std::io::Error here and it will be converted to SomeError.
}
```

Though, perhaps providing more specificity with regard to errors, this seems to
me to be just needlessly complicated. I need to implement conversions between
error types and enumerate every error type that could possibly be returned from
the function. Go just allows us to return errors by wrapping them and test the
error types later.

```go
func SomeFunc() error {
    // This could be strconv.NumError or io.EOF
    err := SomeOtherFunc()

    // Using SomeError declared above. Both the error returned by SomeOtherFunc
    // and the SomeError are wrapped.
    return fmt.Errorf(“%w: %w”, SomeError{}, err)
}
```

Now, most of the time we don’t need to care about the underlying error types
but if we did we can use the `errors` package. No need to convert between
types. Go’s wrapped errors also allow us to return an error that is multiple
error types (in this case `SomeError` and `io.EOF`) providing for greater
flexibility in how the errors are handled.

```go
var numErr *strconv.NumError
if errors.Is(err, io.EOF) {
    // Matches io.EOF but not strconv.NumError
}

var someErr *SomeError
if errors.As(err, &SomeError) {
    // Matches all SomeErrors
}
```

## Final Thoughts

While I wish error handling in Rust was as simple as Go, I appreciate the lack
of exceptions and I think the `Result` type fits well into Rust code. However,
I’m more of a fan of Go’s simpler approach to errors and error handling. The
more code I’ve written the more I appreciate having fewer language features and
syntactic sugar, preferring code that is optimized for reading.

Go has some esoteric issues like using `errors.Is` for static error values vs.
using `errors.As` for matching against an instance of an error type but this
complexity pales in comparison to Rust’s error handling. A Rust-like question
mark [proposal](https://github.com/golang/go/issues/71203), and [continuing
discussion](https://github.com/golang/go/discussions/71460), was introduced to
reduce repetition but I see introducing features like this as mostly a
misadventure.

> **Update:** This post used to include language where I compared Rust's
> `Result` type to a tuple. This is technically incorrect and I updated the
> language to be more clear about the differences between returning a tuple
> with an error vs. an `enum` (tagged union) type.
