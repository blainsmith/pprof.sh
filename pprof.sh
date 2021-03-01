#!/bin/sh

if [ $# -eq 0 ]
    then
        printf "Runs a specified benchmark test func and opens the profile in Chrome.\n\n"
        printf "Usage:\n"
        printf "\t./pprof.sh <cpu|mem|mutex|trace> <dir> <function>\n\n"
        printf "Example:\n"
        printf "\t./pprof.sh cpu ./path/to/specific/package BenchmarkWickedFast\n\n"
        exit 0
fi

case ${1} in
    "trace")
        go test -bench=${3} -trace trace.out -o trace.test ${2}
        go tool trace -http=:6060 trace.test trace.out
        ;;
    "cpu")
        go test -bench=${3} -cpuprofile profile.out -o bench.test ${2}
        go tool pprof -http=:6060 bench.test profile.out
        ;;
    "memory")
        go test -bench=${3} -benchmem -memprofile profile.out -o bench.test ${2}
        go tool pprof -http=:6060 bench.test profile.out
        ;;
    "mutex")
        go test -bench=${3} -mutexprofilefraction 5 -${1}profile profile.out -o bench.test ${2}
        go tool pprof -http=:6060 bench.test profile.out
        ;;
    *)
        printf "unknown profile: ${1}"
        exit 1
esac