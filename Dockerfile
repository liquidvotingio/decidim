ARG ruby_version=2.7.1
FROM ruby:${ruby_version}

ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8
ENV RAILS_ENV development
ENV PORT 3000
ENV SECRET_KEY_BASE=no_need_for_such_secrecy
ENV RAILS_SERVE_STATIC_FILES=true

WORKDIR /code

COPY . .

RUN apt-get install -y git imagemagick wget \
  && apt-get clean

RUN curl -sL https://deb.nodesource.com/setup_10.x | bash - \
  && apt-get install -y nodejs \
  && apt-get clean

RUN npm install -g npm@6.3.0

RUN gem install bundler --version '>= 2.1.4'

RUN bundle install

# Not yet available on decidim/decidim - will be submitted soon
RUN bundle exec rake decidim:generate_stateless_demo_app

WORKDIR /code/staging_app

RUN bundle install

RUN bundle exec rails assets:precompile

# Before this can be run, there'll need to be a docker exec to run migrations
# and seeding through rake. This of course can only be done once container is up
# and running and with access to a database.
CMD ["bundle", "exec", "rails", "s", "-b", "0.0.0.0"]

# So far trying to avoid using an entrypoint script
ENTRYPOINT []