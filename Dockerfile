FROM registry.access.redhat.com/ubi9/ubi

WORKDIR /app

RUN curl -LO https://github.com/tektoncd/cli/releases/download/v0.20.0/tkn_0.20.0_Linux_x86_64.tar.gz
RUN tar xvzf tkn_0.20.0_Linux_x86_64.tar.gz -C /usr/local/bin

COPY pipelines/* /app/pipelines/*
COPY scripts/* /app/scripts/*

RUN tkn pipeline start my-pipeline -f /app/pipelines/pipeline-simple.yaml

# ENTRYPOINT ["/usr/bin/bash"]
