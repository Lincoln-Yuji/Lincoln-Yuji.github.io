---
title: '(Contributions to FOSS) Next steps with KW'
categories: [USP, MAC0470]
tags: [linux, kworkflow]
---

As someone still interested to keep contributing to the Linux
ecossystem, but not really into contributing to the kernel itself,
there are a lot of ways we can help to build this empire apart from
the very kernel.

One of these ways is to help the development of tools some Linux
developers use, such as kworkflow. I've decided to keep working
and cotributing to kworkflow because I am a big fan of shell scripts
as tools to automate tasks for our desktop and workflow environments
and, even though I'm not a Linux developer myself, I do believe
that Linux plays a massive important role for us nowadays and I
want to keep learning and contributing to this amazing ecossystem.

Since we have already made previous contributions to kw, we already
have a basic understanding of project's structure, workflow and
contribution process. On this blog post I'm going to present some
new updates PR's we have been working on.

# Improving 'kw maintainers' test coverage

The `kw maintainers` feature lacks tests for its multiple corner cases
where it should fail. Adding such tests ensures a larger test coverage
for expected behaviors of this feature, possibly preventing future accidental
undesirable changes.

We've open a pull-request which raids this exact problem:
[kworkflow/pull/1118](https://github.com/kworkflow/kworkflow/pull/1118).

The idea itself is rather simple, even so it's quite hard to get your
PR accepted in the first try. We've got some suggestion from Rodrigo
Siqueira and possible additional changes we can make with test script,
since it's a very old file that hasn't been properly maintained for a
long time.

# Handling trailer lines with kw

Both [#1049](https://github.com/kworkflow/kworkflow/issues/1049) and
[#1051](https://github.com/kworkflow/kworkflow/issues/1051) represent similar issues,
regarding trailer line manipulation of commits and patches. The idea is to deliver
a new feature that can make such tasks easier and quicker to deal with.

However, my group and I are not totally sure how this should be implemented. If we
should create a new features such as `kw handle-trailer` or implement this inside
an already existing kw's feature.

We have decided to go with the first idea and have open this pull-request:
[kworkflow/pull/1121](https://github.com/kworkflow/kworkflow/pull/1121).

It's still too early to tell if this PR will be accepted or not at the moment.
I'll be making a new blog post telling how this feature development is going on
and if should be optimistc about it getting accepted or not.
