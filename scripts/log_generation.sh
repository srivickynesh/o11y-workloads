#!/usr/bin/bash

for ns in test ; do 
  # If 'get' returns 0, then the namespace exists. 
  oc get namespace $ns
  if [ $? -ne 0 ]; then
    oc new-project $ns
  fi
done

if [ -f ../pipelines/pipeline-simple.yaml ]  ; then
  oc project $ns
  oc create -f ../pipelines/pipeline-simple.yaml
  sleep 10
fi

if [ ! -f test.log ]; then
    nohup oc logs -f test-pipeline-simple-log-generation-pod -c step-generate-random-echo > test.log 2>&1 &
else
    rm -rf test.log
    nohup oc logs -f test-pipeline-simple-log-generation-pod -c step-generate-random-echo > test.log 2>&1 &
fi
for i in {1..25}
do
    # Prints log size
    echo "Current Log Size is : `ls -l test.log | awk '{print $5}'`"
    if [ $? -ne 0 ]; then
        echo "Failure $?"
        exit 1
    fi
    echo "Sleeping for 1m"
    sleep 1m
done

# Cleanup pipeline and log

yes | tkn pr delete test-pipeline-simple
if [ $? -ne 0 ]; then
    echo "Failure $?"
    exit 1
fi

rm -rf test.log
if [ -f test.log ]; then
    echo "File exists"
    exit 1
fi

for ns in test ; do 
  # If 'get' returns 0, then the namespace exists. 
  if oc get namespace $ns ; then
    # Issue delete. 
    oc delete namespace $ns
    # Wait up to 30 seconds for deletion.
    oc wait --for=delete namespace $ns --timeout=30s
  else
    # Get returned an error. Assume namespace does not exist.
    echo "$ns does not exist; skipping delete"
  fi
done
echo "Test Completed successfully"
