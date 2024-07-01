---
title: 'Updating old Arch Linux keyrings'
categories: [Linux, Arch Linux]
tags: [linux, tutorial]
---

Updating your Arch Linux system should be as easy as just running:

```bash
$ sudo pacman -Syu
```

However we all know that's not the case. Since Arch is a bleeding
edge distro, it's expected that some updates might fail or break.

In particular, one thing that happens quite often is a failed upgrade
due to outdated or missing GPG signatures.

# Update your archlinux-keyring package

Assume `pacman -Syu` failed because of old GPG signature keys. 

Ensure your system clock is correct:

```bash
$ sudo timedatectl set-ntp true
```

Then just update your `archlinux-keyring` package:

```bash
$ sudo pacman -Sy archlinux-keyring
```

It's done! After that, you can just run `pacman -Su` to finish
your system upgrade. Refer to `Troubleshoot` for possible issues
you might have with this process.

# Troubleshoot

It once happened to me that the GPG signatures of the `archlinux-keyring`
package itself were outdated, which might completely lock your
package manager updates since you can't upgrade this package when that happens.
You can follow these steps to solve that.

Reinitialize the keyring and refresh the keys:

```bash
$ sudo pacman-key --init
$ sudo pacman-key --populate archlinux
```

Download the most recent version of the `archlinux-keyring` package from
the Arch's archive:
[Arch Linux keyring archive](https://archive.archlinux.org/packages/a/archlinux-keyring/)

Then install the package in your local system:

```bash
$ sudo pacman -U archlinux-keyring-*.pkg.tar.zst
```

After all that, you can run `pacman -Su` to finish upgrading your system.
