FROM fluent/fluentd
USER root

RUN apk update && apk add ruby-dev && apk add build-base
RUN fluent-gem install fluent-plugin-cloudwatch-logs
RUN fluent-gem install fluent-plugin-kubernetes_metadata_filter
