# syntax = docker/dockerfile:1.0-experimental
FROM ruby:2.6.3-alpine as build-env

ARG RAILS_ROOT=/app
ARG BUILD_PACKAGES="build-base curl-dev git"
ARG DEV_PACKAGES="icu-dev libsodium-dev postgresql-dev yaml-dev zlib-dev nodejs yarn"
ARG RUBY_PACKAGES="tzdata"

ENV RAILS_ENV=production
ENV BUNDLE_APP_CONFIG="$RAILS_ROOT/.bundle"

WORKDIR $RAILS_ROOT
# install packages

RUN apk update \
    && apk upgrade \
    && apk add --update --no-cache $BUILD_PACKAGES $DEV_PACKAGES $RUBY_PACKAGES

COPY Gemfile Gemfile.lock $RAILS_ROOT/

RUN gem install bundler:2.1.4 \
    && bundle config --global frozen 1 \
    && bundle config set without 'development:test:assets' \
    && bundle install -j4 --retry 3 --path=vendor/bundle \
    && rm -rf vendor/bundle/ruby/2.*/cache/*.gem \
    && find vendor/bundle/ruby/2.*/gems/ -name "*.c" -delete \
    && find vendor/bundle/ruby/2.*/gems/ -name "*.o" -delete

COPY . .
#RUN --mount=type=secret,id=masterkey,dst=./config/master.key bin/rails assets:precompile

# Remove folders not needed in resulting image
#RUN rm -rf node_modules tmp/cache app/assets vendor/assets spec

############### Build step done ###############

FROM ruby:2.6.3-alpine

ARG RAILS_ROOT=/app
ARG PACKAGES="tzdata icu-libs libsodium postgresql-client nodejs bash"
ENV RAILS_ENV=production
ENV BUNDLE_APP_CONFIG="$RAILS_ROOT/.bundle"
ENV PORT=80
ENV NO_SSL=party

WORKDIR $RAILS_ROOT

# install packages
RUN apk update \
    && apk upgrade \
    && apk add --update --no-cache $PACKAGES \
    && gem install bundler:2.1.4

COPY --from=build-env $RAILS_ROOT $RAILS_ROOT

EXPOSE $PORT
ENTRYPOINT ["bundle", "exec", "puma", "--config=config/puma.rb"]
