# Blog posts showing my Computer Science journey

Blog Site generated using Github Pages and the `Chirpy` theme for `Jekyll`.

The blog itself can be accessed [here](https://lincoln-yuji.github.io/).

## Useful commands

Run local server to test changes before deploying them

```bash
# This service will run at port 4000 by default
$ bundle exec jekyll s
```

Change the GEM_HOME and BUNDLE_HOME variables to local user directory to avoid headache while running `bundle exec jekyll s`:

```bash
$ export GEM_HOME="${HOME}/.local/gems"
$ export BUNDLE_HOME="${HOME}/.local/bundle"
```

# Using docker to test the deploy inside containers

This might be useful if you don't want to install Jekyll's dependencies into your local system.
Also, using Docker allows you easily and quickly test your application in multiple systems without
worrying about installing the correct environment.

You can create a basic Docker image with the following Dockerfile:

```Dockerfile
# Use Ruby's docker image as base.
# I had a lot of issues trying the Jekyll's image...
FROM ruby:3.3.2

WORKDIR /usr/src/app

# Copy the Gemfile first and install the dependencies inside the container.
COPY Gemfile ./
RUN bundle install

# Copy our blog files into docker and expose the port 4000
COPY . .
EXPOSE 4000

# By default Jekyll binds to localhost inside the Docker container,
# which makes it inaccessible from the host machine.
#
# You need to make Jekyll bind to 0.0.0.0 so that it listens on all network
# interfaces, including the ones used by Docker.
CMD [ "bundle", "exec", "jekyll", "s", "--host", "0.0.0.0"]
```

Create and run the container:

```bash
$ docker build -t chirpy-jekyll-blogs ./                 # Create container
$ docker run --rm -it -p '4000:4000' chirpy-jekyll-blogs # Run
```

Then access the service using a web browser at `http://0.0.0.0:4000`.
