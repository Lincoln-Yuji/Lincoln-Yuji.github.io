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

Usamos o próprio git para criar e enviar o patch para os nossos monitores da disciplina:

```bash
$ git format-patch --to=<EMAIL> HEAD~1
$ git send-email *.patch
```

Talvez você pode acabar encontrando problemas com a configuração do SMTP na hora que rodar o comando `git send-email`. Uma maneira de resolver isso facilmente é usando o próprio `kworkflow` para a tarefa:

```bash
$ kw mail --interactive
```

Siga os passos que serão mostrados e então, com essa configuração, rode o comando novamente para enviar os patches por email.
**Essa configuração é importante, pois o kw usa o send-email por baixo dos panos para enviar os emails para os mantenedores**.

Para enviar o patch para os contribuidores do kernel, podemos usar o [kworkflow](https://github.com/kworkflow/kworkflow) a fim de facilitar a tarefa. Como a nossa contribuição possui apenas um commit, para criar e enviar esse patch por email para
os mantenedores basta certificarmos que estamos no diretório raíz do diretório e então:

```bash
$ kw mail --send
```

Esse comando irá automaticamente detectar qual é o email dos mantenedores e para quais emails esse pacth será mandado além
dos próprios mantenedores, por exemplo o autor e co-autores do commit.

Algo que pode ser útil caso a sua contribuição tenha múltiplos commits:

```bash
$ kw mail --send HEAD~<N>
```

Com esse comando, o kw irá criar um `patchset` com os últimos `N` commits da sua branch modificada a partir da `HEAD`.

## Patch aceito pelos mantenedores

As primeiras versões de patch que enviamos tiveram alguns erros de formatação da mensagem de commit que tiveram que ser
consertados:

- Utilização desnecessária da tag `From:` que causou um erro de match dos emails. Nada muito grave, mas deixa a mensagem inconsistente e pode ficar consfuso caso entre no histórico do projeto.

- A mensagem estava excedendo o limite de 75 colunas por linha que os contribuidores exigem na formatação dos commits.

- Na seguda versão do patch que enviamos, esquecemos de indicar `[PATCH v2]` no título e também esquecemos de colocar `Reviewed-by: Marcelo Schmitt <marcelo.schmitt1@gmail.com>`, sendo Marcelo a pessoa que revisou a primeira versão que enviamos.

Para especificar a versão do patch na hora que for enviar o email para os manetenedores, você pode usar a flag `-v`. No nosso caso, após fazer as devidas correções, enviamos um **terceiro patch** d seguinte forma:

```bash
$ kw mail --send -v3
```

Essa versão foi **aceita** e esse patch pode ser encontrado [nesse link](https://lore.kernel.org/all/20240429132233.6266-1-lincolnyuji@usp.br/).

## Alguns agradecimentos

Essa foi a minha primeira contribuição para o kernel do Linux e achei uma experiência muito interessante. Gostaria de agradecer ao professor Paulo Meirelles e às integrantes do grupo Luiza Soezima e Sabrina Araújo por terem tornado esse processo de aprendizado possível, além claro dos membros do FLUSP que criaram e disponibilizaram os tutoriais utilizados, compartilhando o conhecimento que eles adquiriram ao longo dos últimos anos.