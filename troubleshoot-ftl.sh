#!/bin/bash
set -u

echo "fasterthanli.me resolves to: "
dig fasterthanli.me +short

IFS=$',' read -r -d '' -a nodes < <(dig +short _servers.bearcove.cloud TXT | tr -d '"')
echo "Found ${#nodes[@]} nodes through TXT"
curl_format="conn %{time_connect}s | appconn %{time_appconnect}s | pretrans %{time_pretransfer}s | starttrans %{time_starttransfer}s | total: %{time_total}s"

# find whether to use ping6 or ping -6
# if the output of `ping --help 2>&1` contains `-6` then use `ping -6`
if [[ $(ping --help 2>&1) =~ "-6" ]]; then
    echo "ping supports -6"
    ping4="ping -4"
    ping6="ping -6"
else
    echo "ping does not support -6"
    ping4="ping"
    ping6="ping6"
fi

for node in ${nodes[@]}; do
    if [[ "$node" == "djin" ]]; then
        continue
    fi

    host="${node}.bearcove.cloud"
    for ip in -4 -6; do
        echo
        if [ $ip == -6 ]; then
            ${ping6} -c 1 $host | head -2
        else
            ${ping4} -c 1 $host | head -2
        fi
        curl $ip \
            --write-out "${curl_format}" \
            --silent \
            --fail \
            --connect-timeout 3 \
            --connect-to fasterthanli.me:443:$host:443 \
            "https://fasterthanli.me/api/sponsors"
        curl_exit_code=$?
        echo
        # if curl exit code isn't 0 print something in red
        if [ $curl_exit_code -ne 0 ]; then
            printf "\e[31m❌ curl failed for $node $ip\e[0m\n"
        fi
    done
done
