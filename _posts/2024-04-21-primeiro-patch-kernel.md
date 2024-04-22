---
title: Primeiro patch para o Kernel
categories: [USP, MAC0470]
tags: [linux, git]     # TAG names should always be lowercase
---

# Nosso primeiro patch para o Linux Kernel

Eu e meu grupo de MAC0470 - Desenvolvimento de Software Livre finalizamos o nosso primeiro patch
de contribuição para o Linux Kernel. Aqui estarei relatando um pouco do que fizemos e qual foi
nossa experiência nesse processo.

## Procurando algo para fazer

Existem várias coisas que alguém pode fazer para contribuir para o kernel. O nível de complexidade
dessa contribuição pode variar desde alterações de estilo no código ou supressão de warnings até
resolução de bugs bem obscuros ou criação de novos módulos ou drivers.

Um meio termo que escolhemos foi utilizar uma macro disponível no kernel cujo objetivo é facilitar a iteração sobre nodes de
firmware, simplificando o tratamento de erros em saídas precoces
desse loop e evitando possíveis bugs por causa disso.

## Versão "scoped" de uma macro no kernel

A macro da qual estamos falando é `device_for_each_child_node_scoped()`
e foi introduzida no commit `365130fd47af`. Essa nova versão
"scoped" da macro remove a necessidade de chamar manualmente a `fwnode_handle_put()` em todo fluxo de código que precocemente deixa o loop.

Alguns drivers iteram sobre nodes de firmware (`struct fwnode_handle`) e incrementam (`_get`) uma referência para o node à medida que a iteração avança. Deixar o loop cedo requer que o driver libere (`_put`) a referência para que outros drivers possam usar esse node. Isso é uma potencial fonte de bugs caso o desenvolvedor não tome cuidado com esse detalhe. Usar essa nova macro ajuda a mitigar essa possibilidade e, aleḿ disso, faz com que o código fique mais limpo.

Apesar dessa nova macro ter sido aceita e introduzida no kernel a um certo tempo, ainda existem diversos drivers que ainda estão usando a antiga. Essa é uma boa oportunidade para refatorar o código de alguns arquivos fazendo uso dela.

Em particular o driver que modificamos é `drivers/iio/adc/ti-ads1015.c`.

As alterações podem ser vistas olhando para esse `git diff`:

![Desktop View](/assets/img/iio_diff.png){: w="700" h="400" }

Como é possível observar, fazendo uso dessa macro, podemos remover as chamadas de `fwnode_handle_put()`
do código. Com isso, estamos evitando que possíveis bugs de futuras alterações possam ocorrer caso
algum desenvolvedor esqueça de adicionar essa chamada em saídas precoces do loop. Padronizar o uso
dessa macro ao invés da antiga também facilita a vida de novos ou futuros desenvolvedores que
irão trabalhar em novos drivers do kernel.

Um patchset com mais exemplos de patches com modificações que usam essa macro podem ser encontradas [aqui](https://lore.kernel.org/linux-iio/20240330190849.1321065-1-jic23@kernel.org/).

## Criação e envio do patch

Tendo as devidas alterações no driver, escrevemos a mensagem de commit e devidamente assinamos a mensagem como é mostrado a seguir:

![Desktop View](/assets/img/iio_log.png){: w="700" h="400" }

Usamos o prórprio git para criar e enviar o patch para os nossos monitores da disciplina:

```bash
$ git format-patch --to=<EMAIL> HEAD~1
$ git send-email *.patch
```

Para enviar o patch para os contribuidores do kernel, podemos usar o [kworkflow](https://github.com/kworkflow/kworkflow) a fim de facilitar a tarefa.

No entanto, estamos aguardando a avaliação e aprovação dos nossos monitores antes de fazer o envio.