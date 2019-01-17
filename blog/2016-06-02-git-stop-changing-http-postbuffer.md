# Git: Stop changing http.postBuffer…

**This was a post that I originally wrote on 2016/06/02 at https://blogs.msdn.microsoft.com/congyiw/2016/06/02/git-stop-changing-http-postbuffer/.  That blog no longer exists.**

**EDIT (5/26/2017):** added "Check if these hotfixes are applicable if your TFS server is running Windows 2012 R2 or earlier" section

If you see an `RPC failed` error during `git push`, like...
```
error: RPC failed; result=22, HTTP code = 404
```
or
```
error: RPC failed; result=22, HTTP code = 411
```
or
```
Unable to rewind rpc post data - try increasing http.postBuffer
error: RPC failed; result=56, HTTP code = 0
```
... and search for help on [Stack Overflow](https://stackoverflow.com/questions/2702731/git-fails-when-pushing-commit-to-github) or [MSDN forums](https://social.msdn.microsoft.com/Forums/vstudio/en-US/cdeb11b8-5c79-4563-bf7d-db969e2e951d/tfs-2013-visual-studio-online-git-push-size-limitation?forum=TFService), you'll see a lot of old recommendations to set `http.postBuffer`.

**Don't do it!** At least not blindly. Instead:

## Upgrade Git
If you're still running a Git client that's version 1.9.5 or older(!) you should really upgrade Git first (we’re up to 2.8+ now). There are a bug fixes (like [this one](https://github.com/git/git/commit/c80d96ca0c3cf948c5062bf6591a46c625620b6d)) in newer versions of Git that should obviate the need to set `http.postBuffer`.

We had enough support requests from internal users and external customers hitting bugs in older versions of Git that we decided to add a server-side reminder to TFS/VSTS a few sprints ago:

```
M:\tmp\foo>git fetch
remote: Microsoft (R) Visual Studio (R) Team Services
remote: We noticed you're using an older version of Git. For a better experience, upgrade to the latest version at https://git-scm.com/downloads
remote: Found 4 objects to send. (6 ms)
Unpacking objects: 100% (4/4), done.
```

## Check if these hotfixes are applicable if your TFS server is running Windows 2012 R2 or earlier
* [A large file upload or a large repository clone fails on VSO in Windows Server 2012 R2](https://support.microsoft.com/en-us/help/3100477/a-large-file-upload-or-a-large-repository-clone-fails-on-vso-in-window)
* [Pushing large files to Team Foundation Server by Git client hangs](https://support.microsoft.com/en-us/help/4017691/pushing-large-files-to-team-foundation-server-by-git-client-hangs)

## Check if you're using a proxy or load balancer
If you're using a terrible proxy that's buggy or doesn’t support chunked encoding, you'll see errors for larger pushes. The same thing can happen if you put on-prem TFS behind a misconfigured load balancer. If the same push succeeds when bypassing the proxy, or bypassing the load balancer (e.g. by pushing to localhost from the server itself), then fix your proxy or load balancer instead!

## What if my proxy or load balancer is broken, but I don't have any control over it?
This is the only scenario that I've seen where setting `http.PostBuffer` is useful for newer versions of Git.

## Is setting `http.postBuffer` harmful?
AFAICT, it's more unnecessary than harmful, but there are a few negative side effects:
* Increasing it above the default may increase latency for larger pushes (since the client will buffer the HTTP request into larger chunks).
* If you set it larger than the HTTP chunk size limit for your HTTP server (e.g. `maxAllowedContentLength` and `maxRequestLength` in `web.config` for TFS servers), then all pushes larger than the chunk size limit will start failing.

## How do I unset `http.postBuffer` if I've already set it?
To check if it's set, run:
```
git config --show-origin --get-all http.postBuffer
```

You may have to unset it in both your global `.gitconfig` file:
```
git config --global --unset http.postBuffer
```

As well as in your repo level `.git/config` (which overrides the global setting):
```
git config --local --unset http.postBuffer
```
