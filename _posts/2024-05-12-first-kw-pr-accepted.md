---
title: First PR to kworkflow (Part 2)
categories: [USP, MAC0470]
tags: [linux, git, kworkflow, bash]
---

After some feedbacks and tweeks we had our first pull request accepted
for kworkflow. I am using this blog post to tell how the process was
and lessons I learned.
The [pull request's thread can found here](https://github.com/kworkflow/kworkflow/pull/1100).

# Improving readability

The first feedbacks we got basically told us to adjust some "minor" issues
such us bad file names and specific case tests. Nothing that can be classified as "feature breaking".
However, one thing that was indeed good to pay more attention to and improve was readability and what
exactly the code is doing.

As we can see here:

![Desktop View](/assets/img/2024-05-12/pr-code-block.png)

This is the part of the code reponsible for capturing the content inside the `MODULE_AUTHOR`'s
macro, trimming and formatting the content to be printed by the function.

This block of code is actually a single line of commands piped one after another and is
quite hard to understand what is happening. The suggestion was breaking this huge commands
into a small set of separeted blocks and adding some comments to improve readbility and
documentation of the changes and features.

# A better understanding of the code

While we were following the suggestions and working on improving our pull request, we
started contemplating the code we've wirtten a little more and we started questioning
what exactly the following code is, in fact, doing:

```bash
$ sed --expression ':a' --expression 'N' --expression '$!ba'
```

After some research, we didn't find out what this piece of code is supposed to do.
We tried checking the `sed` documentations and also the original commit when `--authors`
was introduced on kw.

But the problem was that we really didn't know what kind of
impact or purpose this code previously had. We tried removing it and it didnt't seem
to impact the output in any way. Then, after some wait for more feedback from the
maintainers we got some help from [@davidbtadokoro](https://github.com/davidbtadokoro) and he
helped us a lot to understand what this code's purpose is.

It looks like this was an attempt to solve the exact problem we are trying to solve with
this pull request: getting authors from multi line statements. His explanation can be found
in details at the PR's thread.

# Final tweeks and pull request resolution

WORK IN PROGRESS...