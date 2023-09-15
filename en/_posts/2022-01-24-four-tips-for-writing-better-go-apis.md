---
layout: post
title: "Four Tips for Writing Better Go APIs"
date: 2022-01-24 00:00:00 +0000
permalink: /en/four-tips-for-writing-better-go-apis
blog: en
render_with_liquid: false
---

Go is a really powerful programming language that allows you to write concurrent code that is still easy to understand. But designing APIs can be hard, even for seasoned Go programmers. When designing APIs for libraries and applications in Go it's important to keep in mind the strengths of the language to make your APIs easier to use and avoid pitfalls like goroutine leaks. With that in mind, here are a few common issues I see often with Go APIs and some tips for how to make them better.

## Don't Take APIs Out of Context

The context package is a very powerful package that takes some getting used to but provides developers with a really easy way to implement timeouts and cancellation. I often see APIs that don't make full use of the Context object or, even worse, don't take one at all. Let's look at some examples of times when you should use Contexts.

Many APIs allow users to pass a timeout parameter so that the API doesn't block forever.

```golang
func DoSomething(stream chan struct{}, timeout time.Duration) bool {
	select {
	case <-stream:
		return true
	case <-time.After(timeout):
		return false
	}
}
```

Instead of a timeout parameter, add a context to your method or API whenever it might be doing something that takes some time like reading a network request or even a large file. Allowing folks to timeout or cancel calls themselves will make for a much more robust API.

```golang
func DoSomething(ctx context.Context, stream chan struct{}) error {
	select {
	case <-stream:
		return nil
	case <-ctx.Done():
		return ctx.Err()
	}
}

ctx, cancel := context.WithTimeout(context.Background(), 60*time.Second)
defer cancel()
DoSomething(ctx)
```

## Look for the Exit

If your API is creating goroutines you should always provide a way for the [goroutine to exit](https://dave.cheney.net/2016/12/22/never-start-a-goroutine-without-knowing-how-it-will-stop). If your goroutine has no way to exit it will exist forever. This is another place where `Context` objects come in handy but you can provide other ways for the goroutine to exit, such as "done channels" or, if used with care, timeouts.

Let's look at an example where we use a `Context`. Contexts will allow the caller of the method to stop the goroutines when it makes sense for them. First, here's an example of some [code](https://github.com/rakyll/launchpad/blob/3466ac178db810c093a899a87b29a454c037b378/mk2/launchpad.go#L59-L77) I wrote some time ago that could be improved. You can see here that the code will loop forever since there is no exit condition. (Even worse, if the inputStream used in the call to `Read` is closed it will go into an even tighter loop. If I didn't just happen to have a call to `Sleep` in there, it would consume all the CPU.)

```golang
func (l *Launchpad) Listen() <-chan Hit {
	ch := make(chan Hit)
	go func(pad *Launchpad, ch chan Hit) {
		for {
			// sleep for a while before the new polling tick,
			// otherwise operation is too intensive and blocking
			time.Sleep(10 * time.Millisecond)
			hits, err := pad.Read()
			if err != nil {
				continue
			}
			for i := range hits {
				ch <- hits[i]
			}
		}
	}(l, ch)
	return ch
}
```

As you can see, the goroutine here never terminates so a new immortal goroutine will be created every time this method is called.

Here's a simple way we could make it better with a `Context` to allow the caller to cancel and a done channel to stop the goroutines when the `Close` method is called.

```golang
func (l *Launchpad) Listen(ctx context.Context) <-chan Hit {
	ch := make(chan Hit)
	go func(pad *Launchpad, ch chan Hit) {
		for {
			// Stop the goroutine if the context has been canceled or timed out.
			select{
			case <-ctx.Done():
				return
			case <-l.done:
				return
			default:
			}
			// ...
		}
	}(l, ch)
	return ch
}

func (l *Launchpad) Close() {
	// ...
	l.done <- struct{}{}
}
```

## Concrete Types

Go packages sometimes implement interfaces implemented in other packages. When doing this it might feel right to return an instance of the interface.

```golang
import "github.com/user/somepkg"

type impl struct { /* … */ }

func New() somepkg.Interface {
	return &impl{}
}
```

However, in this scenario there may be extra options or functions on your concrete implementation that could be used by your users, or other functions defined specifically for your implementation. This also leaves some room for expansion. In that case it's better to return a [pointer to your implementation](https://medium.com/@cep21/what-accept-interfaces-return-structs-means-in-go-2fe879e25ee8) so that your users can use those methods if needed.

```golang
func New(c *Config) *Impl {
	return &Impl{c}
}

func (i *Impl) Config() *Config {
	return i.c
}

func SomeFunc(i Impl) {
	/* ... */
}
```

This also doesn't diminish your implementation since it still implements `Interface` and can be used anywhere that it is required.

```golang
i := myimpl.New()
myimpl.SomeFunc(i)
somepkg.InterfaceNeeded(i)
```

## Change the Channel

Often you'll see an API return a channel to communicate with any created goroutines.


```golang
func (o *myObj) Start() ->chan struct{} {
	data := make(chan struct{})
	go func() {
		for {
			d := <-data
			// do something with d
		}
	}()
	return data
}
```

However, this means that if the caller already has a channel that accepts that kind of data, they would need to copy the data from one channel to another. Often this means creating a new goroutine with all the lifecycle management that goes along with it.

```golang
func StartObj(o &myObj, ch chan struct{}) {
	otherCh := o.Start()
	go func() {
		for {
			d := <-ch
			otherCh <- d
			// NOTE: lifecycle management abbreviated.
		}
	}()
}
```

Instead, it's often a better idea to accept a channel from the caller and use that.

```golang
func (o *myObj) Start(data <-chan struct{}) {
    go func() {
		for {
			d := <-data
			// do something with d
		}
	}()
}
```

That way, connecting up different goroutines with channels becomes much easier.

```golang
func StartObj(o &myObj, ch chan struct{}) {
	o.Start(ch)
}
```

## Any Others?

As always, Dave Cheney's website is a goldmine for [resources on this](https://dave.cheney.net/2016/08/20/solid-go-design). Be sure to check out his posts as well.

Hopefully these tips are helpful to you when designing your next Go API. Let me know if you run across any other examples of good (or bad!) practices by sending me a message on [Twitter](https://twitter.com/IanMLewis).

_Thanks to [Eno Compton](https://twitter.com/enocom_) for reviewing this post and offering lots of improvements._