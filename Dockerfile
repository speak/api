FROM ruby:latest
ADD ./Gemfile ./Gemfile
RUN bundle install
ADD . /api
WORKDIR /api
