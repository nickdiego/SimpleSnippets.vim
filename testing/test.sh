#!/bin/bash
test_name=$1
vim=$2
verbose=$3
timeout=600
ref_file=reference
tmux_session=SimpleSnippetsTest

cd $(dirname $0)
cd tests/$test_name/

if [[ $verbose != 0 ]]; then
    echo -n "$test_name test: "
fi

tmux new-session -d -n $tmux_session

source test.sh

before_test
test_func
after_test

while [[ $(stat -c %s $test_file) == 0 ]]; do
    sleep 0.1
    ((--timeout))
    if [[ $timeout == 0 ]]; then
        echo "Timeout"
        error=0
    fi
done

sha_ref=$(sha256sum $ref_file  | awk '{print $1}')
sha_res=$(sha256sum $test_file | awk '{print $1}')

if [[ $sha_ref != $sha_res ]]; then
    if [[ $verbose != 0 ]]; then
        echo "Error"
    fi
    rm $test_file
    error=1
else
    if [[ $verbose != 0 ]]; then
        echo "Ok"
    fi
    rm $test_file
    error=0
fi

tmux kill-window -t $tmux_session
exit $error