---
layout: post
title: "Client-side Rate Limiting on Google Apps Script"
date: "2026-05-26 00:00:00 +0900"
blog: en
tags:
    - tech
    - programming
    - javascript
    - typescript
permalink: /en/client-side-rate-limiting-on-google-apps-script
render_with_liquid: false
---

I was recently writing a custom function for Google Sheets using Google Apps
Script, and was running into rate limiting errors. It turns out that, even with
authenticated requests, the GitHub API has a rate limit of
[30 requests per minute](https://docs.github.com/en/rest/search/search?apiVersion=2026-03-10#rate-limit)
for the issues search endpoint.

I needed to implement client-side rate limiting to prevent exceeding
API quotas. I ran into a number of challenges while implementing it though. For
one, Google Apps Script is invoked separately and in parallel for each call to
the custom function. This means that it can get called in parallel for each cell
that uses the function.

Second, Google Apps Script's `UrlFetchApp` does not support request queuing or
throttling. Any logic for rate limiting has to be implemented manually within
the script. I didn't see any existing libraries or blog posts about how to do
this so implemented a basic windowing rate limiter by combining the
`CacheService` and the `LockService`.

We store the number of requests made in the current window in the cache, and use
the `LockService` to ensure that only one execution can update the cache at a
time. First, the current window is calculated using the current time.

```javascript
var cachePrefix = "github_api_rate_limit";
var concurrentRequests = 0;
const now = Date.now();
const currentBlock = Math.floor(now / (WINDOW_SEC * 1000));
const cacheKey = `${cachePrefix}:${currentBlock}`;
```

Then we acquire a lock using the `LockService`. While the lock is held, the
`CacheService` is then used to maintain the number of requests made in the
current window.

```javascript
var lock = LockService.getScriptLock();
try {
    lock.waitLock(timeout);

    const cache = CacheService.getScriptCache();
    concurrentRequests = parseInt(cache.get(cacheKey), 10) || 0;
    if (concurrentRequests < MAX_REQUESTS_PER_WINDOW) {
        cache.put(cacheKey, concurrentRequests + 1, WINDOW_SEC + 1);
    }
} catch (e) {
    throw Error(`failed to obtain lock: ${e}`);
} finally {
    // Always release the lock
    lock.releaseLock();
}
```

If the number of requests exceeds the limit, the function will wait until the
next window before retrying the request.

```javascript
// Check if we are rate limited.
if (concurrentRequests >= MAX_REQUESTS_PER_WINDOW) {
    // Calculate the time to wait until the next window starts.
    const waitMS = WINDOW_SEC * 1000 - (now % (WINDOW_SEC * 1000));

    Utilities.sleep(waitMS);

    // Retry the request.
    return fetchWithClientSideRateLimiting(url);
}

// We are within the rate limit, so we can proceed with the request.
let response = UrlFetchApp.fetch(url);
```

Since execution time is limited to 30 seconds for custom functions, we need to
maintain a timeout of 30 seconds or less for our rate limiting logic. This
includes time waiting for the lock, waiting for open windows, and time
performing the request and all retries.

I've left out the timeout logic in the code above for simplicity, but
the actual implementation maintains the timeout throughout and quits if it is
exceeded.

I've open sourced the full implementation of the client-side rate limiter on
GitHub. I also maintain the rate limiting client as a Google Apps Script library
that you can import into your projects. You can find instructions for how to use
it in the README.
