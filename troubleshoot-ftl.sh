#!/bin/bash
set -u

echo "fasterthanli.me resolves to: "
dig fasterthanli.me +short

IFS=$'\n' read -r -d '' -a nodes < <(dig +short +trace fasterthanli.me CNAME | grep CNAME | cut -d ' ' -f 2 | sed 's/[.]$//g')
curl_format="conn %{time_connect}s | appconn %{time_appconnect}s | pretrans %{time_pretransfer}s | starttrans %{time_starttransfer}s | total: %{time_total}s"

for node in ${nodes[@]}; do
    for ip in -4 -6; do
        echo
        if [ $ip == -6 ]; then
            ping6 -c 1 $node | head -2
        else
            ping -c 1 $node | head -2
        fi
        curl $ip \
            --write-out "${curl_format}" \
            --silent \
            --output /dev/null \
            --fail \
            --connect-timeout 3 \
            --connect-to fasterthanli.me:443:$node:443 \
            "https://fasterthanli.me"
        curl_exit_code=$?
        echo
        # if curl exit code isn't 0 print something in red
        if [ $curl_exit_code -ne 0 ]; then
            printf "\e[31m❌ curl failed for $node $ip\e[0m\n"
        fi
    done
done
