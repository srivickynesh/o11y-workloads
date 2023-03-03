#!/usr/bin/bash

oc create -f ../pipelines/pipeline-simple.yaml

sleep 10

oc project test

oc logs test-pipeline-simple-log-generation-pod -c step-generate-random-echo > test.log
if [ ! -f test.log ]; then
    echo "File Not Found"
    exit 1
fi

# Print log size

echo "Log Size is : `ls -l test.log | awk '{print $5}'`"
if [ $? -ne 0 ]; then
    echo "Failure $?"
    exit 1
fi

# Cleanup pipeline and log

yes | tkn pr delete test-pipeline-simple
if [ $? -ne 0 ]; then
    echo "Failure $?"
    exit 1
fi

rm -rf test.log
if [  -f test.log ]; then
    echo "File Found"
    exit 1
fi
