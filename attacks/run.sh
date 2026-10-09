#!/bin/sh
# Run every scenario in order, or just the one named as an argument.
# Example: ./run.sh 02-sqli/a-search
cd "$(dirname "$0")"
if [ $# -eq 1 ]; then
    exec sh "${1%.sh}.sh"
fi
for s in 01-recon/* 02-sqli/* 03-bruteforce/* 04-logging/* 05-persistence/*; do
    case "$s" in */*.sh)
        echo "=== $s"
        sh "$s" || echo "($s a échoué)"
        echo
    esac
done
