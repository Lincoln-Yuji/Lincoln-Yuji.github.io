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

You can find the hardware bus channel used by your touchpad using the following command:

```sh
grep -iA2 touchpad /proc/bus/input/devices
```

In my case, I can clearly see that the `i2c` channel is the one. We can check the loaded
modules using it by running:

```sh
sudo lsmod | grep i2c
```

My VAIO laptop uses the `i2c_hid` driver. More precisely the `i2c_hid_acpi` to work
with the Linux Kernel.

Everytime the `i2c_hid_acpi` moudules fails, my touchpad dies. It can happen either
on boot or suspend/wake. When that happens, we can check the kernel's log running:

```sh
sudo dmesg | grep i2c_hid_acpi
```

When you have your touchpad working just fine, you can confirm the driver is used
by your touchpad's hardware by running `sudo rmmod i2c_hid_acpi`. In this case, you
should replace **i2c_hid_acpi** with the module your laptop is using.

If your touchpad stops working after running this command, then you found the exact
driver, otherwise you need to keep looking for the correct one.

To load back the module we've just removed we can just run `sudo modprobe i2c_hid_acpi`
and then have our touchpad working once again.

Additionaly, you can check your **tocuhpad model** running the following command:

```sh
ls /sys/bus/i2c/devices
```

This will prompt the loaded devices using the `i2c` bus channel. Apart from the
multiple `i2c-<index>` you will find something like `i2c-SYNA3602:00` as well.

In my case, this is the factory model of my hardware's touchpad. And you will that
this will match the model you found when the command
`grep -iA2 touchpad /proc/bus/input/devices` was used earlier.

# Permanent (janky) solution for Linux distros using Systemd

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
#!/bin/env bash

LOG_FILE='/tmp/systemd-suspend-touchpad'
TOUCHPAD_DRIVER='i2c_hid_acpi'
TOUCHPAD_MODEL='SYNA3602:00'

if [[ "$1" == "pre" ]]; then
    modprobe -r "$TOUCHPAD_DRIVER"
    echo "[STATUS] modprobe returned $?" >> "$LOG_FILE"
    echo "[REMOVE] ${TOUCHPAD_DRIVER} driver | $(date)" >> "$LOG_FILE"
elif [[ "$1" == "post" ]]; then
    sleep 1
    modprobe "$TOUCHPAD_DRIVER"
    echo "[STATUS] modprobe returned $?" >> "$LOG_FILE"
    while true; do
        grep --quiet "$TOUCHPAD_MODEL" /proc/bus/input/devices
        if [[ "$?" -gt 0 ]]; then
	        modprobe -r "$TOUCHPAD_DRIVER" && modprobe "$TOUCHPAD_DRIVER"
	    else
	        break
        fi
    done
    echo "[ADDING] ${TOUCHPAD_DRIVER} driver | $(date)" >> "$LOG_FILE"
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

# Booting using Legacy rather than UEFI

Most of machines nowadays have the UEFI boot mode enabled by default, and that
happens they come with Windows installed from factory. Some of them might not
even have the option to change the boot to Legacy mode.

However, if you have intentions to install Linux into your machine and have
the option use Legacy, I strongly recommend you to do so. The UEFI mode is
a tool developed to make it difficult for the average user to uninstall their
Operating System and nuke their computer. On top of that, most machines have
also Secure Boot enabled as an extra layer of protection.

In fact, UEFI was originally made to avoid users trying to install different
Operating Systems into their machines, including Linux, and lock them into
using Windows by default.

You maybe will not face this sort of issue when using Legacy boot, but it's
not guaranteed and also you may not have this option in your BIOS configuration.

Hopefuly this information is useful and good luck with your Troubleshooting!
