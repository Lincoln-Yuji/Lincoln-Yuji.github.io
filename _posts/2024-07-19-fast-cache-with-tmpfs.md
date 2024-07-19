---
title: 'Faster KDE cache access with tmpfs'
categories: [Linux, Unix]
tags: [linux, tutorial, kde]
---

I've had recently upgraded my laptop's system which is running Fedora 40. And I've
realized that the **KDE Plasma** desktop reached the major *version 6*.

I really like many of the new features and changes they made, and a lot of bugs
that came with `Plasma 6.0` were quickly fixed in `Plasma 6.1`. Almost a flawless
experience if it wasn't for a really annoying issue involving animations.

KDE Plasma has a lot of neat and cool animations to provide a more polished user
experience, however many of them are causing heavy stuttering and visual glitches
on my machine. After some basic googling I've found that other users were having
the same issue and managed to find some people discussing the cause of all this.

These are the two major references I'm linking in this blog post:

- **Open KDE bug report:** [Bug 487043](https://bugs.kde.org/show_bug.cgi?id=487043)
- **Brodie Robertson's coverage:** [KDE Plasma Constantly Stuttering, Try This!!](https://www.youtube.com/watch?v=sCoioLCT5_o)

I want to leave here that the KDE version I'm using at the moment is `Plasma 6.1.2`.

# KDE's window manager is loading QML from slow memory

In short, QML is a declarative language designed to create visual effects and
animations for applications using the **Qt** graphics library.

You can find detailed information about this language here: [QML Applications](https://doc.qt.io/qt-6/qmlapplications.html)

KDE's window manager is called **Kwin** and it's the background process responsible
for handling your desktop's windows. It's also the program that handles such
animations we are talking about.

By default, Kwin has some cached files located at `~/.cache/kwin`. Such files exist to
decrease loading times and improve the application's overall perfomance. Specially,
inside this directory we have the `qmlcache` that contains all the cached QML animations
and effects used by Kwin window manager.

The problem is, these QML cached files are not getting properly loaded and kept into RAM
after being rescued from the slow memory (usually an HDD, SSD, etc). Everytime an
animation needs to be loaded and executed, some small spikes of *disk I/O* usage happen,
indicating that KDE is loading those QML scripts from slow memory everytime an animation
plays in your desktop.

After indetifying the problem, we can quickly discuss some questions I have related
to low level protocols and why this is happening.

# A small discussion about the Principle of Locality

Every time your system reads blocks of memory from Secondary Memory, such data is
then kept into pages in your Primary Memory. This is the base of **Principle of Locality**.

It's a fundamental concept in Computer Science that refers to the tendency of computer
programs to access a relatively small portion of its address space in Virtual Memory
at any given time. In short, if a memory location is accessed at a certain time,
it is likely that either this location or nearby locations are likely to be accessed
in the near future.

This principle can be exploited by some programs to quickly access cached data. I do
believe that these QML files are being loaded into RAM pages like any other data that
is read from slow memory, however there might be something affecting the amount of time
such data is being kept into the Primary Memory.

If those animations are getting requested from Secondary Memory everytime they are
needed, then it means that the blocks containing the necessary data are not in the
Primary Memory in any given time (always a *Page Miss*, never a *Page Hit*).

It's quite hard to imagine possible causes for that without tracking the pages your
Memory Controller is handling. This is a very low level *kernel to hardware* discussion
and, honestly, trying to solve this problem investigating at such low level is something
that even your average Linux Developer might find hard and demanding.

I may assume this might be related to priority issues with KDE's Wayland compositor,
since other DEs using Wayland such as Gnome or window managers like Sway or Hyprland
are not having such issues. This is something specific to KDE. But it's hard to precisely
point the cause at the moment.

# A temporary workaround using Linux tmpfs

You can use this workaround while this issue is not fixed in KDE Plasma.

In a nutshell, `tmpfs` is a **volatile memory** that can be mounted in your filesystem.
This memory is located at your RAM and basically contains a filesytem like your
typical Linux root filesytem. You might be familiar with this concept if you have ever
studied something about **initramfs** and *Virtual File Systems*.

Anyway, this is not that important to understand. The only thing we really need to know
is that any file that we put in this volatile partition follows two basic behaviors:

- Any file here can be quickly accessed from your RAM;
- Data is not persistent and will be lost when your RAM refreshes;

These two characteristics make `tmpfs` perfect to optimize KDE's cache requests. First,
add the following line to your `/etc/fstab` file:

```text
tmpfs   /mnt/kwin-qmlcache  tmpfs  defaults,size=4M  0  0
```

This line tells the system to mount a `tmpfs` volume at `/mnt/kwin-qmlcache` with a
size of 4MB on boot.

Then create the mounting pointing in your filesystem:

```bash
mkdir '/mnt/kwin-qmlcache'
```

Next, remove your current `~/.cache/kwin/qmlcache` folder and then create a symlink
to the to the mounted `tmpfs`. You don't need to backup these files.

```bash
rm -rf "${HOME}/.cache/kwin/qmlcache"
ln -s '/mnt/kwin-qmlcache' "${HOME}/.cache/kwin/qmlcache"
```

Now you can either `reboot` or run the following commands:

```bash
# Remount the filesystems listed in /etc/fstab
sudo mount -a
# Reload systemd daemons
systemctl daemon-reload
```

You can check if everything is ok using the following commands:

```bash
# Check if the `tmpfs` partition is mounted
df -h '/mnt/kwin-qmlcache'
# Check if the symbolic link is pointing to the mounted partition
ls -l "${HOME}/.cache/kwin"
```

After this, we should have way more smooth and responsive animations in our
desktop. Hopefully this is information might be useful for any readers and,
for any of us facing this problem (mainly in old machines with very slow
hard drives), we can only wait for this issue to be fixed in the future.
