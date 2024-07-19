---
title: Development environments for the Linux Kernel
categories: [USP, MAC0470]
tags: [linux, bash]
---

On today's post I would like to share an experience I'm having this semester at the moment.
I'm having classes about Free and Open-Source Software and one of our goals is to make
contributions to the Linux Kernel.

This is not a trivial task at all. It involves knoledge regarding operating systems, bash,
the programming language C, virtual machines, git an so on. Even experienced programmers
might find it quite a hard task.

Fortunately there are old students at FLUSP (IME-USP) that have already learned how to
go through all these and decied to share such knowledge with us newcomers.

I'll be explaining how I managed to setup a basic development environment and workflow
for the Linux Kernel and the tutorials I've used to achieve this.

# Creating a development environment for the Linux Kernel

Similar to any other software, contributing to the Linux Kernel demands testing changes
before publishing from the developer. Usually a developer modifies the code or add new ones,
compile them and then execute the new modified version, performing manual or automated testes.

However, when we are talking about a kernel, this is not that simple. We are talking about a
very low-level software, the base and core of the operating system running in our computer.
Altering the source code may result in serious consequences and might require a complete
re-instalation of your operating system.

For that reason, it's usual for anyone interested to make use of **Virtual Machines**.
In particular, we've used some tutorials shared by FLUSP, an extension group from University
of São Paulo, to learn how to create and use a development environment for the Linux Kernel.

This post is not a step-by-step tutorial though. If the reader wishes to take a look at
the detailed tutorials, the due references will be made in each folloing section of
this blog-post. My focus here is just to show my experience with this process, mentioning
things either I've learnt, had difficulties with or had issues with.

## Part 1: Using QEMU and libvirt

Tutorial: [Setting up a Linux Kernel Test environment](https://flusp.ime.usp.br/kernel/qemu-libvirt-setup/)

The first this I remember when it comes to difficulties I had t start these tutorials
was the giant amount of packages I had to install. There are a lot of commands that
required me to install some additional tools to properly run and complete. I believe
the tutorials could have some kind of session for required dependencies before proceeding.

Also, many libvirt commands will need some special permission to be executed. By default,
libvirt only allows users from `libvirt`. On top of that, you might have some permission
errors with the kvm hypervisor if your user is not in the `kvm` group.

Solving those issues is very simple. Simply add your user to those groups:

```bash
sudo usermod -a -G libvirt '<username>'
sudo usermod -a -G kvm '<username>'
```

The last headache I had on this first part was during the virtual disk expansion step
using the following command:

```bash
virt-resize --expand '/dev/sda1' base_iio_arm64.qcow2 iio_arm64.qcow2
```

O problema desse comando é que algumas vezes ele pode trocar a partição do rootfs
do `sda1` para o `sda2`. O tutorial menciona que você deve ter esse cuidado, pois
caso isso aconteça será necessário ajustar os próximos comandos do tutorial para
usar a partição correta. Se você cegamente copiar e colar todos os comandos sem prestar
muito atenção, então terá alguns problemas. No meu caso, ao rodar o script
`launch_vm_iio_workshop.sh` a máquina virtual não deu boot e o meu terminal travou
completamente.

The issue with this command is that sometimes it can change the **rootfs** partition
from **sda1** to **sda2**. This is warned n the tutorial but I was not payting too much
attention and was just copying and pasting commands at this point. When I tried running
the script `launch_vm_iio_workshop.sh` my virtual machine couldn't boot and my entire
tty session crashed.

I had some problems setting up SSH, but the *Troubleshooting* session solved them.
No drama.

## Parte 2: Fazendo a build do Kernel Linux

Tutorrial: [Building the Linux Kernel for ARM](https://flusp.ime.usp.br/kernel/build-linux-for-arm/)

Não tive muitos problemas nessa etapa. Após várias frustações na primeira etapa, é natural seguir com cautela para os próximos passos. O tutorial explica muito bem o que você está fazendo a cada comando e por quê estamos fazendo cada ação.

No entanto, certifique-se de que sua conexão com a internet é boa. Eu realizei essa etapa do tutorial enquanto estava com meu notebook conectado a uma rede WiFi muito fraca. Clonar o repositório do Kernel levou quase 1 hora.

Outra coisa é que a primeira vez que você decidir compilar o Kernel e gerar a nova imagem, que será apontada pelos novos scripts, pode levar um tempo considerável também. Se quiser ganhar o máximo de eficiência possível e tiver confiança na sua máquina, rode o comando `make` usando `-j${nproc}` igual foi mostrado no tutorial:

```bash
$ make -j$(nproc) ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- Image.gz modules
```

## Parte 3: Entendendo configurações de build e módulos

Tutorial: [Introduction to Kernel build configuration and modules](https://flusp.ime.usp.br/kernel/modules-intro/)

Pessoalmente, também não tive grandes problemas com essa etapa. Talvez a única coisa que pode ficar confusa e acabarmos nos perdendo é a recompilação do Kernel. Certifique-se de modificar os Makefiles corretamente e não esqueça de rodar o `make menuconfig` para adicionar os novos módulos. Após recompilar o Kernel, basta jogar as mudanças para a VM do mesmo jeito que fizemos na Parte 2 usando:

```bash
$ make INSTALL_MOD_PATH=$VM_DIR/mountpoint_arm64/ modules_install
```

Se esquecer dessa etapa, vai ficar se perguntando porque as mudanças não estão afetando a VM, assim como eu fiquei por alguns bons minutos.
