FROM registry.access.redhat.com/ubi9/ubi

ENV SCRIPTS_PATH="/project/scripts"
ENV TESTS_PATH="/project/tests"

COPY scripts $SCRIPTS_PATH
COPY pipelines $SCRIPTS_PATH

ENTRYPOINT ["/usr/bin/bash"]
