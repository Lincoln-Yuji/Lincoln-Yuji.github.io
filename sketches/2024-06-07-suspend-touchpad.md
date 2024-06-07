---
title: 'Using Systemd's sleep service to fix my touchpad'
categories: [Linux, Troubleshoot]
tags: [linux, systemd, bash]
---

I've been having a really annoying issue involving my VAIO laptop with Linux
from the very beginning. Every time my machine suspends, my touchpad stops working
after waking up back. Often the solution is to completely shutdown the computer
and then wait a few minutes before powering it on.

However, I've finally found a solution to this! I'll be sharing it here and give
some tips for people with possibly similar issues. Because some few details will
depend on your hardware's manufactor.

# Base idea of the solution

This is an issue whose solution I've been searching for a few months. I found
several sources with different ways to solve this problem but not a single one
particularly worked for me. Most of them comes to unload and reload a specific
Linux driver to fix the issue:

```sh
sudo modprobe -r <driver-name> && sudo modprobe <driver-name>
```

Some of them involves modifying GRUB's default variables to properly load your
drives on boot. The following forum link discusses this issue for both keyboard
and touchpads on some laptops with Ubuntu systems:
[Ubuntu Forum Link](https://askubuntu.com/questions/916465/ubuntu-17-04-keyboard-not-responding-after-suspend/940323#940323).

In fact, the first approach is more suitable for the issue I'm facing here. But
the problem is how do I find `<driver-name>`?

# Finding the driver your touchpad uses

The Linux kernel has multiple drivers for handling inputs from several different
laptop models. The most common driver I've seen being talked about when searching
for a solution was the `psmouse` driver. But that's not the case for my hardware
specifically.

So the idea is to find the driver your machine's touchpad uses. And you can do that
following a few steps.

**[ WORKING IN PROGRESS ]**

# Solution for Linux distros using Systemd

In my case, distros I usually use have Systemd as their base system's service
manager. The idea is to take advantage of this creating a script that will be
executed once everytime our system either suspends or comes back from suspension.

This can be easily achieved with Systemd by creating a script under the
`/usr/lib/systemd/system-sleep/` directory. You can give any name to this script.
For example:

```sh
sudo vim /usr/lib/systemd/system-sleep/touchpad-vaio
```

A very basic script will unload the driver before the system suspends and load it
back when it wakes up. The following script does exactely this and also prints some
log message in a `/tmp` file for debugging purposes.

**It's important that you change TOUCHPAD_DRIVER with the name of whatever driver your hardware is using!**

```sh
#!/bin/sh

LOG_FILE='/tmp/systemd-suspend-touchpad'
TOUCHPAD_DRIVER='i2c_hid_acpi'

if [ "$1" = "pre" ]; then
    modprobe -r "$TOUCHPAD_DRIVER"
    echo "[REMOVE] Removing ${TOUCHPAD_DRIVER} driver." >> "$LOG_FILE"
elif [ "$1" = "post" ]; then
    modprobe "$TOUCHPAD_DRIVER"
    echo "[LOAD] Loading ${TOUCHPAD_DRIVER} driver." >> "$LOG_FILE"
fi
```

After that, you MUST make it executable by running:

```sh
sudo chmod +x /usr/lib/systemd/system-sleep/touchpad-vaio
```

We are done after that. From now on every time our system suspends, we will not
have (hopefuly) issues with our laptop's touchpad getting nuked everytime
our system suspends.

Of course this is sort of a janky workaround and a regular user might have
huge problems with this kind of approach. If you are having issues with that
on your laptop, then try contacting your hardware manufactor and pray they
will patch these problems in future driver updates.

Since this is a kernel level bug, most users (even advanced ones) will
have to do some kind of workaround to have their hardware working properly.

Hopefuly this information is useful and good luck with your Troubleshooting!