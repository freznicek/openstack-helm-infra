#!/bin/bash

#    Licensed under the Apache License, Version 2.0 (the "License"); you may
#    not use this file except in compliance with the License. You may obtain
#    a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
#    WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
#    License for the specific language governing permissions and limitations
#    under the License.

set -xe

#NOTE: Lint and package chart
make elastic-packetbeat

tee /tmp/packetbeat.yaml << EOF
images:
  tags:
    filebeat: docker.elastic.co/beats/packetbeat:7.1.0
conf:
  packetbeat:
    setup:
      ilm:
        enabled: false
endpoints:
  elasticsearch:
    namespace: osh-infra
  kibana:
    namespace: osh-infra
EOF

#NOTE: Deploy command
helm upgrade --install elastic-packetbeat ./elastic-packetbeat \
    --namespace=kube-system \
    --values=/tmp/packetbeat.yaml

#NOTE: Wait for deploy
./tools/deployment/common/wait-for-pods.sh kube-system

#NOTE: Validate Deployment info
helm status elastic-packetbeat
