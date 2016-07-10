#!/bin/bash

# arguments:
# user: ciscozeus user name
# token: ciscozeus data token
# Without these, the container will not be able to post data.
#
# optionally, you can also pass a new shared key:
# shared_key:
#
# And a new data source name:
# self_hostname:
#
# And a data server:
# data_server:

user=${user:-none}
token=${token:-none}
shared_key=${shared_key:-cisco_zeus_log_metric_pipline}
self_hostname=${self_hostname:-fluentd-client1.ciscozeus.io}
data_server=${data_server:-data01.ciscozeus.io}
master=${masger:-127.0.0.1}

cat > /etc/td-agent/td-agent.conf <<EOF
<match fluent.**>
  type null
</match>


<source>
  type tail
  path /var/lib/docker/containers/*/*-json.log
  pos_file /var/log/td-agent/fluentd-docker.pos
  time_format %Y-%m-%dT%H:%M:%S
  tag docker.*
  format json
  read_from_head true
</source>

<match docker.var.lib.docker.containers.*.*.log>
  type kubernetes
  container_id \${tag_parts[5]}
  tag docker.\${name}
</match>

<source>
  type systemd
  path /varlog/journal
  filters [{ "_SYSTEMD_UNIT": "flanneld.service" }]
  pos_file /var/log/td-agent/flanneld.pos
  tag systemd.flannel
  read_from_head true
</source>

<source>
  type systemd
  path /varlog/journal
  filters [{ "_SYSTEMD_UNIT": "fleet.service" }]
  pos_file /var/log/td-agent/fleet.pos
  tag systemd.fleet
  read_from_head true
</source>

<source>
  type systemd
  path /varlog/journal
  filters [{ "_SYSTEMD_UNIT": "etcd2.service" }]
  pos_file /var/log/td-agent/etcd2.pos
  tag systemd.etcd2
  read_from_head true
</source>

<source>
  type systemd
  path /varlog/journal
  filters [{ "_SYSTEMD_UNIT": "kubelet.service" }]
  pos_file /var/log/td-agent/kubelet.pos
  tag systemd.kubelet
  read_from_head true
</source>

<source>
  type cadvisor
  host ${master}
  port 4194
  stats_interval 30
  tag_prefix cadvisor.
</source>

<match systemd.** cadvisor.** kubernetes.**>
  type record_reformer
  tag logs.\${tag}.${user}-${token}
  <record>
    @timestamp \${time}
  </record>
</match>

<match logs.**>
  type secure_forward
  shared_key ${shared_key}
  self_hostname ${self_hostname}
  secure false
  keepalive 10
  <server>
     host ${data_server}
  </server>
</match>
EOF

exec td-agent $@
