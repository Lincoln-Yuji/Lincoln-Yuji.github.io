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
