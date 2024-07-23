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

I'll try to cover some possible solutions for common issues regarding this process.
Yeah... dealing with Arch Linux keyrings is a pain in the ass and veteran Arch users
know that very well.

## Dowloading the keyring package directly from Arch Archives

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

## Bypassing Arch's GPG verification (be careful with this!!)

If everything mentioned previously failed to enable your system to upgrade properly, then
you might use this as a last resort. You can access the file `/etc/pacman.conf` and
alter the following line:

```bash
SigLevel = Required DatabaseOptional  # Before
SigLevel = Never                      # After
```

This will make `pacman` skip the GPG Key verification step and directly upgrade the packages.
As you might correctly think, this is very dangerous and I really recommend changing this
configuration back once your system fully upgraded:

1. Update your keyrings with `pacman -Sy archlinux-keyring`
2. Change back `SigLevel` to **Required DatabaseOptional**
3. Finish your system update with `pacman -Su`

This is a very well known and old issue with Arch Linux packages and it's incredible how
the Arch maintainers refuse to fix this crap. There are some third party scripts you might
find that try to automate typical Arch systems upgrades. Some are very robust and handle multiple
issues and errors `pacman` might spill. You can take a look at the Garuda Linux scripts to take
some inspirations and examples.
