# fluentd-aws-k8s

## Assumptions

* Your cluster is on AWS
* You want your logs on CloudWatch
* Your pod can get the proper IAM creds to put logstream data.
* You want to enrich your events w/ k8s data

It will run on a k8s cluster, deployed on AWS, and want your pod logs forwarded to AWS CloudWatch logs, and enriched with K8s data.

With a config like this:

```
<source>
  @type forward
  port 24224
  bind 0.0.0.0
</source>

<filter kubernetes.var.log.containers.**.log>
  type kubernetes_metadata
  bearer_token_file /var/run/secrets/kubernetes.io/serviceaccount/token
  ca_file /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
</filter>

<match **>
  type cloudwatch_logs
  log_group_name reaio-cluster
  # log_stream_name log-stream-name
  auto_create_stream true
  #message_keys key1,key2,key3,...
  #max_message_length 32768
  #use_tag_as_group false
  use_tag_as_stream true
  include_time_key true
  #localtime true
  #log_group_name_key group_name_key
  #log_stream_name_key stream_name_key
  #remove_log_group_name_key true
  #remove_log_stream_name_key true
  #put_log_events_retry_wait 1s
  #put_log_events_retry_limit 17
  #put_log_events_disable_retry_limit false
</match>
```

You will also need another fluentd daemonset, which forwards everything to this service.
