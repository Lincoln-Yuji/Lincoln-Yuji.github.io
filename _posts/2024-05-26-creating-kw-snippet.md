---
title: 'Adding a new feature to kw'
categories: [USP, MAC0470]
tags: [linux, kworkflow]
---

As someone still interested to keep contributing to the Linux
ecossystem, but not really into contributing to the kernel itself,
there are a lot of ways we can help to build this empire apart from
the kernel.

One of these ways is to help the development of tools some Linux
developers use, such as kworkflow. I've decided to keep working
and cotributing to kworkflow because I am a big fan of shell scripts
as tools to automate tasks for our desktop and workflow environments
and, even though I'm not a Linux developer myself, I do believe
that Linux plays a massive important role for us nowadays and I
want to keep learning and contributing to this amazing ecossystem.

# Next steps with kworkflow

Since we have already made previous contributions to kw, we already
have a basic understanding of project's structure, workflow and
contribution process. On this blog post I will focus more on the
feature itself, explaining how it works and every addition/change
I made to integrate a full new feature.

The motivation to start this contribution was the [issue #83](https://github.com/kworkflow/kworkflow/issues/83).

# New feature option: kw explore --snippet

This PR's thread can be found [here](https://github.com/kworkflow/kworkflow/pull/1114).

Often when exploring code in the Linux Kernel, it's usually desirable to not only see the paths and
matched lines, but also the content from near lines. This option allows 'kw explore' to show small
previews of the matched files interactively, helping the process of finding the right code.

The idea is very simple, we don't want to change any previous behavior of `kw explore`.
Adding `--snippet` will force a new behavior on top, displaying a list of snippet previews
of all grepped files with the matched lines.

This feature can be combined with either `default`, `--all` or `--grep`. For example:

```bash
$ kw explore --snippet "<regex>"
$ kw explore --snippet --all "<regex>"
$ kw explore --snippet --grep "<regex>"
```

# Code and changes explanation

**WORK IN PROGRESS...**

This section will be updated once we have more feedback regarding code
from the maintainers. The idea is to show how the changes were made,
how they affect `kw explore` and details we might find interest to
talk about.

# Pull Request resolution

**WORK IN PROGRESS...**

This section will be updated with all the convenient information
when we finish working on this PR, either by being accepted/rejected
and then closed.