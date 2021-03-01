#!/bin/sh

set -e
set -u

usage() {
    printf "Usage:\n"
    printf "\t${0} -tpfh\n\n"
    printf "\t-t cpu, memory, mutex, or trace\n"
    printf "\t-p path to the package\n"
    printf "\t-f name of the function\n"
    printf "\t-h hostname to consume from /debug/* urls\n\n"
    printf "Example:\n"
    printf "\t./pprof.sh -t cpu -p ./path/to/specific/package -f BenchmarkWickedFast\n\n"
    printf "\t./pprof.sh -b ./path/to/main/binary -u http://localhost:8080/debug/pprof/profile?seconds=10\n\n"
    exit 0
}

if [ $# -eq 0 ]
    then
        usage
fi

optstring=":t:p:f:b:h:"

type=""
package=""
function=""
binary=""
url=""

while getopts ${optstring} arg; do
  case "${arg}" in
    t) type=${OPTARG} ;;
    p) package=${OPTARG} ;;
    f) function=${OPTARG} ;;
    b) binary=${OPTARG} ;;
    u) url=${OPTARG} ;;

    ?)
      echo "Invalid option: -${OPTARG}."
      echo
      usage
      ;;
  esac
done
shift $((OPTIND -1))

if [ ! -z "${url}" ] && [ ! -z "${binary}" ]
    then
        curl -Ss -o pprof.${host}.pb.gz ${url}
        go tool pprof -http=:6060 ${binary} pprof.${host}.pb.gz
        exit 0
fi

case ${type} in
    "trace")
        go test -bench=${function} -trace trace.out -o trace.test ${package}
        go tool trace -http=:6060 trace.test trace.out
        ;;
    "cpu")
        go test -bench=${function} -cpuprofile profile.out -o bench.test ${package}
        go tool pprof -http=:6060 bench.test profile.out
        ;;
    "memory")
        go test -bench=${function} -benchmem -memprofile profile.out -o bench.test ${package}
        go tool pprof -http=:6060 bench.test profile.out
        ;;
    "mutex")
        go test -bench=${function} -mutexprofilefraction 5 -mutexprofile profile.out -o bench.test ${package}
        go tool pprof -http=:6060 bench.test profile.out
        ;;
    *)
        printf "unknown profile type: ${type}"
        exit 1
esac