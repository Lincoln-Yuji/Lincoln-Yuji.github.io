---
title: Começando a contribuir para o kworkflow
categories: [USP, MAC0470]
tags: [linux, git, kworkflow, bash]
---

# O que é o kworkflow?

O kworkflow, ou `kw`, é uma ferramenta de linha de comando que está sendo desenvolvida por alunos
do IME-USP há alguns anos. Ela tem como objetivo facilitar e auxiliar pessoas que estão desenvolvendo
para o kernel do Linux, ou seja, é uma ferramenta **feita por desenvolvedores para desenvolvedores**.

Para mais detalhes, recomendo dar uma olhada no [repositório do projeto](https://github.com/kworkflow/kworkflow).

# Primeiro Pull-Request para o kworkflow

Na disciplina de MAC0470 nós tivemos que fazer algumas contribuições para o Kernel. Não somente isso, mas também tivemos
que realizar ao menos uma contriuição para o projeto do kw.

O projeto se encontra no Github e existem algumas issues bem interessantes para serem resolvidas e podem ser boas
para quem ainda está começando a contribuir ou não entende muito de shell script.

Após procurar um pouco, o nosso grupo decidiu resolver a issue [#69](https://github.com/kworkflow/kworkflow/issues/69).

Os detalhes podem ser encontrados no link da própria issue, mas basicamente o que precisamos fazer é melhorar a função
responsável por capturar e imprimir os autores dos drivers definidos através do uso da macro `MODULE_AUTHOR`. No entanto,
a implementação antiga dessa função só consegue fazer isso para *single-line statements* dessa macro. Caso os autores
estejam definidos em *multi-line statements*, nenhum autor será capturado pela função.

As nossas modificações podem ser encontradas nessa página: https://github.com/kworkflow/kworkflow/pull/1100/commits

# Processo de contribuição para o KW

Esse é um explicação bem breve do processo. Para mais detalhes, por favor
acesse [esse link](https://kworkflow.org/content/howtocontribute.html#development-cycle-and-branches) da documentação.

- **Step 1:** Crie um fork pessoal do kw

Para realizar essa etapa, acesse a página do *upstream* e clique no botão `Fork` no topo da página.

Note que o seu fork do kw não é sincronizado automaticamente com o *upstream*
quando há atualizações na **unstable**. Para isso, no seu fork, selecione **unstable**
e clique em `Sync fork`.

- **Step 2:** Clone o seu repositório do kw na sua máquina

Para evitar dor de cabeça com permissões do Github toda vez que precisar
subir uma mudança para o seu fork remoto, clone através do SSH:

```bash
$ git clone git@github.com:<nome-de-usuario>/kworkflow.git
```

Caso você não tenha o SSH da sua máquina associada ao seu perfil,
você deverá ter que configurar isso pela própria interface do Github.

- **Step 3:** Mude para a branch **unstable** localmente

Lembre que todas as mudanças são feitas na **unstable**. Para trocar de branch, execute:

```bash
$ git switch unstable
```

Caso não funcione, rode:

```bash
$ git checkout --track origin/unstable
```

- **Step 4:** Instale o kw

Na raíz do diretório do projeto, rode: `./setup.sh --install`. Se quiser instalar o kw sem as *man pages* (o que é muito mais rápido) rode: `./setup.sh --install --skip-docs`.

- **Step 5:** Instale as dependências de desenvolvedor

Existem 3 ferramentas que você precisa ter instaladas para conseguir contribuir para o kw: o **shfmt** como formatter, o **shellcheck** como linter e o **pre-commit** para criar os hooks de pré commits.

No caso do **Ubuntu**, essas três ferramentas podem ser instaladas usando o `apt`:

```bash
$ sudo apt install shfmt shellcheck pre-commit
```

- **Step 6:** Instale o shUnit2

Esse é um framework de testes de unidade que o kw utiliza. Você pode simplesmente rodar:

```bash
$ cd tests/
$ git clone https://github.com/kward/shunit2
```

- **Step 7:** Setup inicial de desenvolvimento

Com o **shfmt**, **shellcheck** e **pre-commit** instalados podemos
rodar o comando `pre-commit install` na raíz do repositório. A partir
desse ponto, toda vez que você fizer um commit, esses hooks pré commit irão checar se seu commit segue as regras de coding style gerais.

# Fluxo de desenvolvimento

Para qualquer nova mudança você deve seguir os seguintes passos:

- **Step 1:** Sincronizar o seu repositório com o original

Atualize sua branch **unstable local** com a **unstable do upstream**.
Caso a **unstable do seu fork do kw** não esteja sincronizada com a do upstream, faça isto na interface do GitHub. Após isto, rode no seu repositório local do kw:

```bash
$ git pull origin unstable
```

- **Step 2:** Crie uma branch dedicada para a mudança

```bash
$ git checkout -b <NOME_DA_BRANCH>
```

- **Step 3:** Execução de testes

Sempre se certifiue de rodar os testes, tanto os antigos quantos os novos que você criou, para garantir que tudo está funcionando como deveria antes de tentar criar o seu commit:

```bash
$ ./run_tests.sh --unit
```

Esses testes de unidade podem demorar muito para terminar e, dependendo da mudança, não faz sentido rodar todos os testes para testá-la. Você pode rodar alguns testes de unidade específicos usando:

```bash
$ ./run_tests.sh test tests/unit/<SCRIPT_DE_TESTE>
```

- **Step 4:** Atualizar o repositório remoto com as mudanças

Após fazer seus commits e todos eles terem passado pelos checks de
desenvolvedor. Está na hora de atualizar o seu repositório no Github.
Para fazer isso, basta rodar:

```bash
$ git pull --set-upstream origin
```

Isso irá adicionar a sua nova branch local com as mudanças ao seu repositório remoto.

- **Step 5:** Abrir um pull-request

Após a nova branch se encontrar no Github você pode abrir um PR pela
própria interface do site. **Certifique que a branch que as branches estão corretas!**

- **Step 6:** Atualizar um pull-request

Com o processo de revisão, você possivelment terá que atualizar o PR.
Para isto, você deve atualizar os commits necessário com:

```bash
$ git rebase --interactive unstable
```

Assinale os commits que deseja editar com `e`.

Após atualizar a branch local, atualize a branch remota com:

```bash
$ git push --force-with-lease origin <NOME_DA_BRANCH>
```

Após isso, o pull-request no Github será atualizado automaticamente
e os mantenedores já podem ver as mudanças que você fez.

# Discussão e ajustes do Pull-Request

Antes do seu PR ser aceito e agregado ao projeto original, algum mantenedor do kw irá averiguar se está tudo certo.
Coisas como mensagens de commit, organização, legibilidade, etc. Eles possivelmente irão sugerir mudanças
antes de agregarem a sua contribuição à branch **unstable**.

Os testes do github-actions, discussões e ajustes podem ser vistos na própria [página
do Pull-Request](https://github.com/kworkflow/kworkflow/pull/1100) do pull-request no github.

No momento da escrita desse blog post, ainda estamos trabalhando com essa contribuição, fazendo os ajustes
necessários e esperando mais feedbacks dos mantenedores para que a nossa contribuição seja aceita.

Farei um novo blog post relatando futuras atualizações assim que possível.