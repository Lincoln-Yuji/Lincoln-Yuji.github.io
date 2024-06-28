---
title: 'MAC0470 Retrospective'
categories: [USP, MAC0470]
tags: [linux]
---

I would like to deticate this blog post to talk about my overall
experience with MAC0470 at IME-USP (2024-01).

# Kernel Pacthes

I had the opportunity to study and learn how to setup an evironment
for Kernel development using Virual Machines. Not only that, but I also
could make my own contribution to the Linux Kernel and go through the
entire process of modifying the code, deploying the kernel image,
testing the changes and then sending the patches to maintainers of
a specific submodule.

This phase was tough due to my lack of experience with such tools and
also some issues I faced while following the tutorials. However, I would
say it was a really cool experience.

I've tweaked a lot with Linux in the past, but never really went low
enough to modify a kernel tree and deploy it into a new image to test it.

This was a really nice opportunity and experience and overall and I believe
that anyone who is interested on Linux in general would love it.

# Kworkflow contributions

Contributing to `kw` was also nice. I had the opportunity to work with
a large code base and very robust project. Also, it's really impressive how
such large project was made in basically pure bash script.

The development workflow was similar to what we've seen with the Linux Kernel,
which makes sense since this is a tool made for kernel developers and it's
not crazy to imagine that the maintainers of such project will try to follow
a similar proccess for contributions.

I had the opportunity to not only learn more about bash scripting (which was a lot
by the way), but also learned more about development workflow in general.
Working in a project at the same time with mutiple other developers really makes
you fully understand why `git` actually exists and forces you to learn and keep track
of potential conflicting changes. I'm sure that I did more **rebases** in the last
few months than the previous 4 years combined.

It was great overall and, as much as I find bash confusing and weird sometimes,
it was a nice experience to have.

# Packaging for Debian Linux

This experience was also interesting. I had no idea how HARD actually is
to package software to a linux distribution. And also, we need to be reminded
that people maintaining packages for Debian are doing that out of pure volutarism,
which makes it even more impressive in my opinion.

Unfortunetly we couldn't complete the tutorial to its very end since the Perl Team
did not respond any of our emails. But we still managed to build and create the `.deb`
package, which was enough to exerience the whole process of packaging a Perl library
to the Debian's ecossystem.

# Conclusion

It was an overall great experience. There were moments of frustration and confusion,
but we managed to go through every obstacle thanks to classmates' support and determination
to look up solutions for every issue we eventually had. I've learned a lot about `git` and
`bash` during these last months and I feel my knowledge about `FOSS` and `Linux` in general
was significantly improved.
