FROM ruby:3.2-alpine

RUN apk add --no-cache bash git \
 && gem install asciidoctor rouge

ADD lib /project/lib
ADD asciidoctor-git-include.gemspec /project/asciidoctor-git-include.gemspec

WORKDIR /project
RUN gem build asciidoctor-git-include.gemspec
RUN gem install asciidoctor-git-include-*.gem
