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


## Result

```JSON
{
    "log": "severity=INFO pid=1 -- Greeting matey\n",
    "stream": "stdout",
    "docker": {
        "container_id": "6b4d83d36d71fe34ca24194f4f88532285bf97793a66ae7a932ab5c92d83af76"
    },
    "kubernetes": {
        "namespace_name": "default",
        "pod_name": "whale-carcass-production-1513909789-lfpm7",
        "pod_id": "b4cffc59-fea0-11e6-877f-022db3968493",
        "labels": {
            "app": "whale-carcass-app",
            "pod-template-hash": "1513909789",
            "stage": "production"
        },
        "host": "ip-172-20-88-33.ap-southeast-2.compute.internal",
        "container_name": "whale-carcass-app"
    }
}
```
