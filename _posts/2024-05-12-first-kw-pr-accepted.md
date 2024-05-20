---
title: First PR to kworkflow (Part 2)
categories: [USP, MAC0470]
tags: [linux, git, kworkflow, bash]
---

After some feedbacks and tweeks we had our first pull request **accepted for kworkflow**.
I am using this blog post to tell how the process was and lessons I learned.
The [pull request's thread can found here](https://github.com/kworkflow/kworkflow/pull/1100).

# Issues with readability

The first feedbacks we got basically told us to adjust some "minor" issues
such us bad file names and specific case tests. Nothing that can be classified as "feature breaking".
However, one thing that was indeed good to pay more attention to and improve was readability and what
exactly the code is doing.

As we can see here:

![Wall of text](/assets/img/2024-05-12/pr-code-block.png)

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
sed --expression ':a' --expression 'N' --expression '$!ba'
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

# Process to update our PR

After we got our first wave of changes requested, we added some new commits
fixing our first devlivered code. However, the maintainers told us to
`squash` all these commits into one:

```bash
$ git rebase --interactive HEAD~4
```

This command will catch last 4 commits in the current branch
starting from `HEAD` pointer. Then we basically selected:

```
pick ...First Commit...
squash ...Second Commit...
squash ...Third Commit...
squash ...Fourth Commit...
```

This will squash all the 3 new commits into the first one, sort of
merging them all into a single one.

Then we just had to update our remote fork's branch:

```
$ git push --force-with-lease origin issue69
```

Such that `issue69` is the branch's name we 've created
to attack this issue specifically.

# Final tweeks and pull request resolution

We've improved our code's readability by splitting it into different
sections and adding some comments to make it easier to understand.

Note how we decided to remove that "unknown" code since it's not
required to make our new function work:

![Better code readability](/assets/img/2024-05-12/better_read_code.png)

We also made a new test file which covers the multi line use of `MODULE_AUTHOR`:

![New test file](/assets/img/2024-05-12/new_test_file.png)

There weare also discussions regarding code style, other good practices, etc.
However I don't think they add too much to this blog post.

If the reader is curious to see all the discussions, take a look at
this link:
[kworkflow/pull/1100](https://github.com/kworkflow/kworkflow/pull/1100)

### Changes merged into kw's upstream

We had our changes accepted and merged into kw's upstream. They first get
merged into **unstable** and then the maintainers will periodically merge
it into **master**.

Our contribution can be found here:
[commit/328449c949d5a7e71baa4bdec4ca326ebcbc77c1](https://github.com/kworkflow/kworkflow/commit/328449c949d5a7e71baa4bdec4ca326ebcbc77c1)