#!/bin/bash
url="https://prometheus-k8s-openshift-monitoring.apps.test151.lab.psi.pnq2.redhat.com/api/v1/query_range?query"
query="last_over_time(container_network_transmit_bytes_total{namespace="test", pod=~".*-upload-95mb-pod"}[1h])"

response=$(curl -s -w "%{http_code}" -G "$url" --data-urlencode "query=$query")
status_code=$(echo "$response" | tail -n1)
if [[ $status_code -ne 200 ]]; then
  echo "Error: HTTP status code $status_code"
  exit 1
fi

#oc -n openshift-monitoring edit configmap ../configs/cluster-monitoring-config.yaml

#oc -n openshift-user-workload-monitoring get pod


#oc policy add-role-to-user monitoring-rules-edit sri -n test

#oc -n openshift-user-workload-monitoring adm policy add-role-to-user user-workload-monitoring-config-edit sri --role-namespace openshift-user-workload-monitoring

SECRET=`oc get secret -n openshift-user-workload-monitoring | grep  prometheus-user-workload-token | head -n 1 | awk '{print $1 }'`

TOKEN=`echo $(oc get secret $SECRET -n openshift-user-workload-monitoring -o json | jq -r '.data.token') | base64 -d`

THANOS_QUERIER_HOST=`oc get route thanos-querier -n openshift-monitoring -o json | jq -r '.spec.host'`

NAMESPACE=default

echo "sample query"
curl -X GET -kG "https://$THANOS_QUERIER_HOST/api/v1/query?" --data-urlencode "query=up{namespace='$NAMESPACE'}" -H "Authorization: Bearer $TOKEN"

echo "Full Data list"
curl -X GET -kG "http://localhost:8080/api/v1/query" --data-urlencode 'query=last_over_time(container_network_transmit_bytes_total{namespace="test"}[24h])' | jq -r '.data.result[].value[1]'

echo "Total Egress sumed up value "
curl -X GET -kG $url --data-urlencode 'query=$query' | jq -r '.data.result[].value[1]' | awk '{s+=$1} END {print s}'

# Calculate vcpu minutes
oc get pods -n o11y-e2e-tenant -o json | jq '.items[] | .spec.containers[] | .resources' | grep -E 'limits:|cpu' | awk 'NR%2{printf "%s ",$0;next;}1'

# calculate memory limit
oc get pods -n o11y-e2e-tenant -o json | jq '.items[] | .spec.containers[] | .resources' | grep -E 'limits:|memory' | awk 'NR%2{printf "%s ",$0;next;}1'

oc delete secret o11y-tests-token -n o11y-e2e-pipelieruns-tenant; oc delete secret o11y-tests-token -n o11y-e2e-deployments-tenant ; oc delete deployments deployment-vcpu deployment-egress -n o11y-e2e-deployments; oc project o11y-e2e-pipelineruns-tenant; declare -a arr=("tr" "pr" "pipeline" "task"); for i in "${arr[@]}"; do yes|tkn "$i" delete `tkn "$i" list | sed 1d | awk '{print $1}'`; done
