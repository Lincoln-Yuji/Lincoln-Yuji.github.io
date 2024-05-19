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

In particular, we'll be using these great tutorials made by **Joenio Marques da Costa**:

- [Parte 1: Tutorial de empacotamento Debian](https://joenio.me/tutorial-pacote-debian-parte1/)

- [Parte 2: Criando o seu próprio pacote Debian](https://joenio.me/tutorial-pacote-debian-parte2/)

I'll try to focus more on my experience while doing these tutorial and
lessons I learned. But of course, I'll be showing the steps I followed as well and
do my best to explain how I aproached these tutorials.

# Installing Debian Testing

The recommended version of Debian to work with packages is the **Testing** version. It has
a nice balance between **Unstable** and **Stable**. The installer can be found
[here](https://www.debian.org/devel/debian-installer/).

We don't need ay sort of insane setup to start working with packaging software for Debian.
We can simply use a virtual machine to install and run the operating system.

I decided to use [virt manager](https://virt-manager.org/) to install Debian Testing
and start working on this task.

We also don't need an installation with too much stuff. A very basic and raw Debian
installation is enough. Any additional software can be installed after we have
the system operating and running.

# Configuring a development environment for Debian Packages
Having a Debian Testing working in a virtual machine, we start doing some
preparations. First of all, ensure we have **ssh-server** enabled and running
in the VM's Debian:

```bash
$ sudo apt upgrade && sudo apt update
$ sudo apt install openssh-server
$ sudo systemctl enable sshd
```

You can check the VM's public IP by running `ip a` in the command line.
Now we can access the VM through ssh:

```bash
$ ssh <username>@<VM-public-IP-address>
```

Type `yes` in the terminal and press **Enter**.

Now we can start installing some useful development tools to work with the packaging process:

```bash
$ sudo apt install devscripts debhelper debian-policy git-buildpackage pkg-perl-tools
```

You should also install `apt-file` and update your data base so `dh-make-perl` can
find Debian packages referred by some Perl library:

```bash
$ sudo apt install apt-file
$ sudo apt-file update
```

Next it's recommended to condigure your `git` so all the dev tools can properly set
the correct information when installing any sort of template and make your
**git log** with commits more meaningful.

```bash
$ git config --global user.email "you@example.com"
$ git config --global user.name "Your Name"
```

The tool `dh-make-perl` also uses some variables to correctly fill some fields
inside the `debian/` directory with data when you install the repository:

```bash
$ export EMAIL=you@example.com
$ export DEBFULLNAME="Your Name"
```

You can write those line inside `~/.bash_profile` so it automatically sets these
variables whenever the system restarts.

Finally, if this is the **first time** you are using `cpan`, you must run the following
command **before** running `dh-make-perl` so we have all the base configuration ready
to go.

```bash
$ cpan
```

# Creating package for the Perl library Hash::Wrap

**Important: check if the library you chose is not a Debian Package already!**

```bash
$ dh-make-perl locate Hash::Wrap
== dh-make-perl 0.124 ==
Parsing Contents files:
	ll.lz4
	md64.lz4
Hash::Wrap is not found in any Debian package
```

This is where we start diverging from the tutorial. Of course we don't want to use
the Hello World library beacuse it does not provide ny real utility apart from
learning how packages are structured in Debian.

And, again, it's important to choose a library that is not a Debian package yet.
At the time this blog post is published, this lirary will already be in a Debian
package probably and the reader will have to choose another library to work with.

Howerver, keep in mind that you can use any library of your interest to create
packages for Debian. Don't feel limited by the few option the tutorial shows you.

Our next step is to create the first version of our package. This can be done by
executing the following commands. They will download and install the code from
the **upstream** and setup some template files inside `debian/`:

```bash
$ mkdir hash_wrap_pack && cd hash_wrap_pack
$ dh-make-perl --pkg-perl --cpan Hash::Wrap
```

This created a new directory, along with a `tar` file, named `libhash-wrap-perl`.
You can just `cd` into this directory and start working with the package.

# First base changes

For this package in particular, and actually most packages you will work with,
you need to check three files in `debian/` and see if everything is ok:
`copyright`, `control` and `changelog`. 

### debian/copyright:

Check for the copyrights of the pacages with the following commands:

```bash
$ grep -i -r --exclude-dir=.git --exclude-dir=debian copyright
$ licensecheck --shortname-scheme=debian,spdx --copyright --recursive .
$ scan-copyrights
```

They will help you find the copyright information you need without having to check
all the files inside the repository. After using those commands, we've checked that
the copyright information was incomplete and we need to re-organize some other
stuff in the file.

The final result is this:

![debian/copyright](/assets/img/debian_package_tutorial/debian_copyright.png)

Then you can remove the **DISCLAIMER** message, then commit these changes and
you are good to go.

### debian/control:

At the moment this blog was in production, the policy we should use for
`Standards-Version` inside `control` is **4.7.0** and the version
`debhelper-compat` is **13**.

However, those changes were not necessary beacuse the base configuration
we received from `dh-make-perl` didn't mess this up, but keep in mind that
you might have to chage this with other packages.

You can use the following command to check `Standards-Version` and
`debheper-compat`'s version, respectively:

```bash
$ dpkg-query --show --showformat '${Version}\n' debian-policy
$ rmadison --suite=unstable debhelper | cut -d"|" -f 2 | sed 's/\s\+//'
```

Often you will need to update the **Description** beacuse `dh-make-perl`
uses the description from the upstream to write it onto the file. However,
this description is usually not good enough to keep in this file. It's
bery likely will have to change it to something more meaningful.

The final result of our changes was this:

![debian/control](/assets/img/debian_package_tutorial/debian_control.png)

Check if everything is ok with this file:

```bash
$ cme check dpkg-control debian/control
Reading package lists... Done
Building dependency tree... Done
Reading state information... Done
```

If no further changes are needed you can just commit this file and proceed
to the following steps.

### debian/changelog