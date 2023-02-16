#!/usr/bin/env bash
head -c 95M < /dev/urandom > $TESTS_PATH/random-upload_data.log || exit 1
if [ ! -f $TESTS_PATH/random-upload_data.log ]; then
    echo "Log Generation Failed"
fi
echo "Uploading"
curl --limit-rate 1M -F "file=@/tests/random-upload_data.log" https://tmpfiles.org/api/v1/upload
echo "Upload Success"
echo "Starting Download"
curl --limit-rate 1M -o /tests/network.bin https://speed.hetzner.de/1GB.bin
echo "Download Complete"
ls -lh /tests/network.bin
