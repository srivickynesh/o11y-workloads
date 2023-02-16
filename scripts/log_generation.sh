#!/usr/bin/env bash
#!/usr/bin/env bash
echo "Starting LOG Generation!"
head -c 1G < /dev/urandom > $TESTS_PATH/random-data.log || exit 1
ls -lh $TESTS_PATH/random-data.log
if [ ! -f $TESTS_PATH/random-data.log ]; then
    echo "Log Generation Failed"
else
    echo "Log Generation Successful"
fi
