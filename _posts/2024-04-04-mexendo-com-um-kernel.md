---
title: Ambiente de desenvolvimento de um Kernel
categories: [USP, MAC0470]
tags: [linux, bash]     # TAG names should always be lowercase
---

# Criando um ambiente de desenvolvimento para o Kernel Linux

Assim como qualquer outro software, contribuir para o kernel do
Linux exige que o desenvolvedor teste as mudanças implementadas
antes de aplicá-las em uma versão que será publicada. Geralmente o
desenvolvedor altera o código, compila e então executa
essa versão de desenvolvimento modificada em sua máquina para
realizar os testes, manuais ou automatizados.

No caso do kernel, isso não é tão simples. Estamos falando de um software de extremo baixo nível, a base do sistema operacional que está rodando no nosso computador. Alterar o código fonte do kernel instalado na nossa máquina, recompilá-lo e inicializá-lo é uma tarefa com sérias consequêncas em caso de falhas. Dependendo do tipo de erro, a falha pode resultar em uma perda total do sistema e exigir que o desenvolvedor reinstale o sistema operacional de sua máquina.

Para evitar essa dor de cabeça, é muito comum que qualquer um interessado em contribuir para o kernel do Linux utilize `Máquinas Virtuais`. Em particular, utilizei alguns tutorias disponibilizados pelo grupo de extensão universitário FLUSP a fim de aprender como criar um ambiente e entender como funciona o fluxo de desenvolvimento de um kernel.

Isso não será um tutorial passo a passo. Se o leitor estiver interessado no tutorial detalhado, as referências serão disponibilizadas em cada uma das seções a seguir. O foco é mostar como foi a minha experiência nesse processo, mencionando algumas coisa que não estavam claras no começo para mim e alguns problemas ou dificuldades que encontrei.

## Parte 1: Usando QEMU e libvirt

Tutorial: [Setting up a Linux Kernel Test environment](https://flusp.ime.usp.br/kernel/qemu-libvirt-setup/)

A primeira coisa que lembro quando penso em quais dificuldades que tive para começar esses tutorias certamente é a quantidade de pacotes que precisei baixar. Se você é alguém com uma instalação recente de uma distro Linux ou é uma pessoa que nunca mexeu muito com máquinas virtuais, então vai se surpreender com a quantidade de dependências que você terá que baixar a cada etapa.

Outro problema extremamente irritante, pelo menos no Ubuntu, é que muitos comandos do libvirt requerem permissões de root para serem executados. Porém, mais tarde eu percebi que não é exatamente isso. O libvirt só permite que usuários do grupo `libvirt` e `kvm` possam manipular as máquinas virtuais. Forçar a barra usando `sudo` funciona, mas definitivamente pode representar um risco de segurança e certamente é algo que deveria ser evitado.

O usuário padrão do sistema é adicionado automaticamente a esses grupos ao instalar esses pacotes em algumas distros. Porém, no meu caso, tive que fazer isso após a instalação dos pacotes. Para adicionar o seu usuário nesses grupos, basta executar:

```bash
sudo usermod -a -G libvirt '<username>'
sudo usermod -a -G kvm '<username>'
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
