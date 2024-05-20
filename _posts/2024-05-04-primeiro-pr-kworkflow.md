---
title: First PR to kworkflow (Part 1)
categories: [USP, MAC0470]
tags: [linux, git, kworkflow, bash]
---

# What is kworkflow?

Kworfklow, or `kw`, is command line tool under development of some IME-USP students. Its
goal is to reduce the overhead with infrastructure setup for Linux development, that is,
it's a tool **made for developers to developers**.

For more details, it's recommender to take a look at [kw's repository](https://github.com/kworkflow/kworkflow).

# First Pull-Request to kworkflow

There are some interesting issues to be solved e might be a good option for newcomers. After looking for some
issues, our group decided to attack the issue [#69](https://github.com/kworkflow/kworkflow/issues/69).

The details can be found at the issue's thread itself, but basically what we need to do is immprove the function
responsible for capturing and printing drivers' authors defined through the macro `MODULE_AUTHOR`. However,
the old implementation of this function only can do that for *single-line* statements of this macro.
If the authors are defined in *multi-line* statements, then no author is caught by the function.

Our modifications can be found in this page:
[kworkflow/pull/1100/commits](https://github.com/kworkflow/kworkflow/pull/1100/commits)

# Contribution process for KW

This blog post is a short explanation of the process. For more details, check
[this link](https://kworkflow.org/content/howtocontribute.html#development-cycle-and-branches)
from the documentation.

- **Step 1:** Create a KW's fork

Access the *upstream* page and press the `Fork` button at the top of the page.

Note that your fork is now automatically synchronized with upstream when something
is updated in **unstable**. Because of the, it's recommended to frequentely, in your
fork, select **unstable** and then click `Sync Fork`.

- **Step 2:** Clone your fork to your local machine

To avoid trouble with any permissions from Github everytime you try
to perform a `git push`, clone your repo using SSH:

```bash
$ git clone git@github.com:<username>/kworkflow.git
```

If you don't have your machine's SSH key associated to your Github
profile, then you can configure this through Github's interface.

- **Step 3:** Switch to branch **unstable** locally

```bash
$ git switch unstable
```

If it doesn't work, try this:

```bash
$ git checkout --track origin/unstable
```

- **Step 4:** Install kworkflow

In the repository's root, run `./setup.sh --install`. If you want to install kw with no *man pages*
(which is a lot faster by the way), you can run: `./setup.sh --install --skip-docs`.

- **Step 5:** Install developer's dependencies

There are 3 tools that you need to have installed to be able to contribute to kw: **shfmt** as code
formatter, **shellcheck** as linter and **pre-commit** to create the pre-commit hooks.

In **Ubuntu**, these tools can be installes via `apt`:

```bash
$ sudo apt install shfmt shellcheck pre-commit
```

- **Step 6:** Install shUnit2

This is test framework used by the kw's maintainers. You can simply execute:

```bash
$ cd tests/
$ git clone https://github.com/kward/shunit2
```

- **Step 7:** Initial development setup

We can now run `pre-commit install` in kw's root. From now on, every time
you call `git commit`, these commits will check if your changes follow codestyle
rules defined by our development tools.

# Overall Workflow

Every time you wish to start making new changes, you must follow these steps:

- **Step 1:** Synchronize your fork and local clone

Sync your fork with kw's **upstream** via Github's iterface. Then, pull all the changes to
your local clone:

```bash
$ git pull origin unstable
```

- **Step 2:** Create a new branch for your changes

```bash
$ git checkout -b <branch-name>
```

After this, you can start making changes to kw's source code.

- **Step 3:** Execute kw's tests

After you've made some changes, check kw's tests to see if you didn't break anything. If
your changes need to be covered by new tests, then create new tests as well and execute them.

```bash
$ ./run_tests.sh --unit
```

The previous command runs all the kw's unit tests. This might take some time and, sometimes,
it doesn't make sense to run all unit tests when our changes have a very limited scope.

You can run single unit tests by running:

```bash
$ ./run_tests.sh test tests/unit/<script-name>
```

- **Step 4:** Update your remote fork

After commiting your new changes, you must update your remote fork:

```bash
$ git push --set-upstream origin <branch-name>
```

This will add your new branch to your remote fork, carrying all the changes you've
made.

- **Step 5:** Open Pull-Request

Once the new branch is in your remote fork, you can use Github's interface
to open a pull request to kw's upstream.

**Check if the base branch and target branch re correct!** You must
pull request to `kworkflow:unstable`.

- **Step 6:** Update Pull-Request 

After getting your pull request reviwed, you'll probably have
to update it. To do so, you need to update your last`n-commits`:

```bash
$ git rebase --interactive HEAD~<n-commits>
```

After updating your local branch, update your remote one with:

```bash
$ git push --force-with-lease origin <branch-name>
```

After that, the pull request on Github will be automatically
updated and kw's maintainers will already be able to see the
changes you've made.

# Pull-Request's discussion and adjustments

Before your PR is accepted and merged into kw's upstream, some maintainer will
check if everything is ok. Things like commit messages, organization, readability, etc.
They probably suggest some changes before merging your contribution to upstream's **unstable**.

The github-actions testes, discussion and changes can found here:
[kworkflow/pull/1100](https://github.com/kworkflow/kworkflow/pull/1100)

At the moment we are working on it, performing the requested changes and waiting for
more feedback from maintainers to have our first contribution accepted.

There will be a new blog post telling future updates as soon as possible.