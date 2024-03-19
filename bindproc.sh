#!/bin/bash

cmd1="$1"
cmd2="$2"

cleanup() {
    echo "kill $pid1 $pid2" 
    [[ -n $pid1 ]] && kill "$pid1" 2>/dev/null
    [[ -n $pid2 ]] && kill "$pid2" 2>/dev/null
    exit
}

trap cleanup SIGINT SIGTERM

eval "$cmd1" &
pid1=$!

eval "$cmd2" &
pid2=$!

wait "$pid1" "$pid2"

cleanup