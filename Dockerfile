FROM fluent/fluentd:v1.1.0-debian-onbuild

USER root

RUN buildDeps="sudo make gcc g++ libc-dev ruby-dev" \
 && apt-get update \
 && apt-get install -y --no-install-recommends $buildDeps \
 && sudo gem install \
        fluent-plugin-rewrite-tag-filter

RUN gem install jaeger-client

EXPOSE 24284
