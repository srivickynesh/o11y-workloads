#!/bin/bash

# Function to create and validate a Tekton PipelineRun
function create_pipeline_run() {
  # Get PipelineRun YAML file name from argument
  local yaml_file="$1"

  # Apply PipelineRun YAML file to create PipelineRun
  tkn -n my-namespace apply -f "$yaml_file"

  # Watch PipelineRun status until it completes
  # watch -n 1 "tkn -n my-namespace pipelinerun list | grep -q -E 'Running|Starting' || pkill watch"

  # Check if the PipelineRun completed successfully
  local status=$(tkn -n my-namespace pipelinerun list | grep "$yaml_file" | awk '{print $3}')
  if [ "$status" == "Succeeded" ]; then
    echo "PipelineRun $yaml_file completed successfully."
  else
    echo "PipelineRun $yaml_file failed."
    exit 1
  fi
}

# Create and validate multiple PipelineRuns
create_pipeline_run "../pipelines/pipeline-egress.yaml"
create_pipeline_run "../pipelines/pipeline-network.yaml"
create_pipeline_run "../pipelines/pipeline-resource-constraint.yaml"


