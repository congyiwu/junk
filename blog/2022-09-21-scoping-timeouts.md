# Scoping timeouts

In general, timeouts higher up in the stack are going to be less effective at mitigating problems. Above a threshold, there simply isn't enough information to work with.

Imagine if you had a simple job that just uploads a set of files of various sizes via HTTPS. What you really need is different timeouts for different scopes and levels, roughly:

At the lowest level, you'd have timeouts for sending a single TCP packet or reading a single disk block.
* It's relatively easy to pick short, precise timeouts, since packets and blocks are uniform sizes
* Timeouts help you recover with minimal impact to the overall job, assuming retries succeed
  * Retries are cheap since a tiny amount of work is repeated
  * It's not a big deal if we accidentally timeout a slow operation that would have succeeded

A layer up, you might have timeouts for:
* SSL handshakes
* The time it takes to upload each HTTP chunk (it's common to use chunked encoding with moderately sized size chunks)
* The HTTP response time (between sending the last byte of a request and receiving the first byte of the response)

At this layer:
* I'd expect SSL handshake and HTTP chunk upload time to be short and predictable, although lower level variances will compound
* Expected HTTP response times will depend on the specific API call, but since we know what calls we're making, we can make good guesses
* Timeouts at this level enable recovery if:
  * There are repeated timeouts in the layer below, even if lower levels aren't smart enough to abort the entire job after N retries
  * There are gaps that lower level timeouts forget to cover or can't cover. Maybe the TCP connection is fine, but the remote end got stuck while computing the HTTP response
* Retries are more expensive. You might have to restart the SSL handshake or HTTP upload from scratch.

This pattern continues recursively, for every layer you go up, timeouts are less able to prevent impact:
* It's harder to pick precise timeouts since variances compound.
  * If one layer times out successfully and retries, that eats into the timeout for the layer above and so on.
  * You have to conservatively increase your timeouts in higher layers to avoid accidentally giving up after lower levels successfully recovered
* Adding timeouts still increase coverage of repeated timeouts and gaps in lower levels
* Timeouts and retries are more expensive:
  * The best case is you have to repeat even more work
  * Retries are more likely to fail or timeout, since there's more layers underneath that need to succeed in time, and some of them already failed to recover in time!
  * The penalty increases for timing out a slow operation that would have succeeded, so you have to conservatively increase your timeouts

So the top-level job timeout is just a final backstop. It's better and cheaper to handle timeouts in lower levels, but we'll always have gaps.
