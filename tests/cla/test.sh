#!/bin/bash
vim=$1
verbose=$2
test_name="cla snippet"
ref_file=reference
test_file=cla.cpp
log=log.txt
tmux_session=SimpleSnippetsTest

cd $(dirname $0)
touch $test_file
start_size=$(stat -c %s $test_file)

tmux new-session -d -n $tmux_session
tmux send-keys -t SimpleSnippetsTest "$1 -n -u ../testrc $test_file" enter "ggdGi/* test start */" enter "cla" escape "a" tab "travis" tab "TRAVIS_H" tab "int trav" c-k c-k "SimpleSnippets" c-j "char simple" c-k "SIMPLE_SNIPPETS_H" tab tab enter "/* test end */Qw"

while [[ $start_size == $(stat -c %s $test_file) ]]; do
    sleep 0.1
done

sha_ref=$(sha256sum $ref_file  | awk '{print $1}')
sha_res=$(sha256sum $test_file | awk '{print $1}')

if [[ $sha_ref != $sha_res ]]; then
    if [[ $verbose != 0 ]]; then
        echo "[ERR]: $test_name test"
    fi
    mv $test_file $log
    error=1
else
    if [[ $verbose != 0 ]]; then
        echo "[OK]: $test_name test"
    fi
    rm $test_file
    error=0
fi

tmux kill-window -t $tmux_session
exit $error
