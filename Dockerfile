FROM ruby:3.1.2-buster

RUN mkdir -p /htwk2ical
WORKDIR /htwk2ical

RUN apt update && apt install -y nodejs postgresql-client

# fix issue with Bundler 2.3.7
# https://github.com/rubygems/rubygems/issues/5351
ENV BUNDLER_VERSION=2.3.10
RUN gem install bundler -v ${BUNDLER_VERSION}

# loading Nokogiri fails with error: "It looks like you're trying to use
# Nokogiri as a precompiled native gem on a system with glibc < 2.17". Setting
# the config value for `force_ruby_platform` is the recommended fix in the error
# message itself.
RUN bundle config set force_ruby_platform true
