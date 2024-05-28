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

## Parte 1: Usando QEMU e libvirt

Tutorial: [Setting up a Linux Kernel Test environment](https://flusp.ime.usp.br/kernel/qemu-libvirt-setup/)

A primeira coisa que lembro quando penso em quais dificuldades que tive para começar esses tutorias certamente é a quantidade de pacotes que precisei baixar. Se você é alguém com uma instalação recente de uma distro Linux ou é uma pessoa que nunca mexeu muito com máquinas virtuais, então vai se surpreender com a quantidade de dependências que você terá que baixar a cada etapa.

Outro problema extremamente irritante, pelo menos no Ubuntu, é que muitos comandos do libvirt requerem permissões de root para serem executados. Porém, mais tarde eu percebi que não é exatamente isso. O libvirt só permite que usuários do grupo `libvirt` e `kvm` possam manipular as máquinas virtuais. Forçar a barra usando `sudo` funciona, mas definitivamente pode representar um risco de segurança e certamente é algo que deveria ser evitado.

O usuário padrão do sistema é adicionado automaticamente a esses grupos ao instalar esses pacotes em algumas distros. Porém, no meu caso, tive que fazer isso após a instalação dos pacotes. Para adicionar o seu usuário nesses grupos, basta executar:

```bash
$ sudo adduser USERNAME libvirt
$ sudo adduser USERNAME kvm
```

A última dor de cabeça que eu tive com essa etapa foi com as partições geradas dentro das máquinas virtuais.

No tutorial precisamos fazer o resize do disco da nova imagem `iio_arm64.qcow` usando o comando:

```bash
$ virt-resize --expand /dev/sda1 base_iio_arm64.qcow2 iio_arm64.qcow2
```

O problema desse comando é que algumas vezes ele pode trocar a partição do rootfs do `sda1` para o `sda2`. O tutorial menciona que você deve ter esse cuidado, pois caso isso aconteça será necessário ajustar os próximos comandos do tutorial para usar a partição correta. Se você cegamente copiar e colar todos os comandos sem prestar muito atenção, então terá alguns problemas. No meu caso, ao rodar o script `launch_vm_iio_workshop.sh` a máquina virtual não deu boot e o meu terminal travou completamente.

Após repetir o tutorial desde o começo, prestando atenção nesse detalhe, consegui concluir essa etapa sem mais problemas.

Apesar de ter enfrentado alguns erros na hora de configurar o SSH, a seção de Troubleshooting do tutorial foi o suficiente para resolvê-los.

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