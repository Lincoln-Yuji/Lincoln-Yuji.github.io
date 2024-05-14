---
title: Learning how to create Debian packages
categories: [Linux, Debian]
tags: [linux, git, perl]
---

Since this is my first blog post talking about something specific
to Debian, I belive introducing it first is a good a idea.

Debian is a Free Open-Source Linux distribution that is known
for its stability, security and extensive software repository.
It is actively developed by a community-driven workflow, which
emphasizes its open-source principles.

# Package Management

You probably have already heard about Debian's package manager called
`APT` (Advanced Package Tool). It's a complex system responsible for
managing a massive set of repositories and software packages, making
it easy for the users to do basic things like installing, udpadating
and removing software in their machines.

# Why and how to contribute with packages for Debian?

There are several reasons to why contribute, but the main one is that
not only Debian, but a lot of Linux distributions that branch out from it
such as Ubuntu or Linux Mint are largely used in commercial fields and
backend servers. Debian plays a huge role in our lives nowadays and
multiple systems are built on top of a Debian "core".

Regarding how we can contribute, if you have any software the you would
like to make it more easily accessible to other people then this is
already a good start. How you create and publish this package to be
downloadable by `apt` is something that we should take a better look at.

In particular, we'll be using these great tutorials made by **Joel Marques da Costa**:

[Part 1: Tutorial de empacotamento Debian](https://joenio.me/tutorial-pacote-debian-parte1/)

I'll try to focus more on my experience while doing these tutorial and
lesson I learned.

# Configuring a development environment for Debian Packages

WORK IN PROGRESS...