# Overview

There are 3 things running:

* app is a simple Python Flask app that serves up `/acl` for an allow/denylist
  and a `check_cid` endpoint. Note: its running in dev mode and will be
  sloooooooow, the point of only hitting it for novel CIDs is that it should not
  matter too much. THERE IS ZERO EXPECTATION ANYONE WOULD PUT THIS PYTHON APP IN
  PRODUCTION
* go-ipfs for the upstream connection (commented out to benchmark the other
  stuff)
* nginx

# Nginx / Lua

The best diagram for what where the lua hooks are is
[here](https://openresty-reference.readthedocs.io/en/latest/Directives/)

We use the following phases

## `init_by_lua`

Usually just to require all the modules before forking to save RAM and speed up
later requires, simmilar to puma in ruby etc.

## `init_worker_by_lua`

This runs once per nginx worker and can be used to schedule things periodically

## `content_by_lua`

I have a `/refresh` and `/status` page for testing, with `lua_code_cache off;`
you can have a reasonable flow for testing changes w/o creating an elaborate
test harness

## `rewrite_by_lua`

Runs on every request, we have 3 strategies, all using shared (thread safe)
dictionaries set by `lua_shared_dict` called `allow` and `deny`:

### `rewrite-allow`

For when you want to only serve a list of CIDs. Assumes a periodic refresh of
the allow/deny dict from the api, looks if CID is allowed, then checks if
CID/PATH is disallowed.

Note if you dont `ngx.exit()` this script it goes to the next phase (ie proxying the
backend)

### `rewrite-deny`

Like allow but just looks if CID/PATH is denyed, more like the use case where
you block "bad" or legally taken-down content.

### `rewrite-check`

This only allows/denys at the CID level (assumption you have lots of them and
that you dont want to block paths underneath them)

Will hit the api and add into the allow/deny dict, if you can allow some
requests to slip past, you could do the api call and dict update in another
co-routine with `ngx.timer.at(0, fn)`

Note the early `return` if the CID is allowed, that exits the processing of the
request.

# Notes

The shape of the api has been tweaked a little but should not be considered
canonical or even good, especially `check_cid` (the shape of whats returned just
matches `/acl` as I wrote that first and didnt want to re-work for a PoC), you
probably want to return less (maybe even just a code?) on that call.

# Performance

It performs ok, I took one days worth of URIs from a PL gateway and ran 20k
requests (I made sure nginx only started one worker)

## hitting the (slooooow) api

```
() $ baton -u http://localhost:3000/ -c 30 -r 20000 -z urls.txt
Configuring to send requests from file. (Read 594884 requests)
Generating the requests...
Finished generating the requests
Sending the requests to the server...
Finished sending the requests
Processing the results...
=========================== Results ========================================
Total requests:                                 20000
Time taken to complete requests:        21.422449757s
Requests per second:                              934
Max response time (ms):                           199
Min response time (ms):                             0
Avg response time (ms):                         31.55
========= Percentage of responses by status code ==========================
Number of connection errors:                        0
Number of 1xx responses:                            0
Number of 2xx responses:                            0
Number of 3xx responses:                            0
Number of 4xx responses:                        20000
Number of 5xx responses:                            0
========= Percentage of responses received within a certain time (ms)======
        64% : 19 ms
        64% : 38 ms
        64% : 57 ms
        64% : 76 ms
        94% : 95 ms
        99% : 114 ms
        99% : 133 ms
        99% : 152 ms
        99% : 171 ms
       100% : 199 ms
===========================================================================
```

## Rerun (presumably now all cached in the dicts)

```
() $ baton -u http://localhost:3000/ -c 30 -r 20000 -z urls.txt
Configuring to send requests from file. (Read 594884 requests)
Generating the requests...
Finished generating the requests
Sending the requests to the server...
Finished sending the requests
Processing the results...
=========================== Results ========================================
Total requests:                                 20000
Time taken to complete requests:         1.853002984s
Requests per second:                            10793
Max response time (ms):                            21
Min response time (ms):                             0
Avg response time (ms):                          2.26
========= Percentage of responses by status code ==========================
Number of connection errors:                        0
Number of 1xx responses:                            0
Number of 2xx responses:                            0
Number of 3xx responses:                            0
Number of 4xx responses:                        20000
Number of 5xx responses:                            0
========= Percentage of responses received within a certain time (ms)======
        80% : 2 ms
        96% : 4 ms
        98% : 6 ms
        99% : 8 ms
        99% : 10 ms
        99% : 12 ms
        99% : 14 ms
        99% : 16 ms
        99% : 18 ms
       100% : 21 ms
===========================================================================
```

Might want to experiment more with dict sizes and different amounts of novel CIDs 