#!/bin/bash
set -u

echo "fasterthanli.me resolves to: "
dig fasterthanli.me +short

IFS=$'\n' read -r -d '' -a nodes < <(dig +short +trace fasterthanli.me CNAME | grep CNAME | cut -d ' ' -f 2 | sed 's/[.]$//g')
read -d '\n' curl_format << EOF
        time_connect:  %{time_connect}s
     time_appconnect:  %{time_appconnect}s
    time_pretransfer:  %{time_pretransfer}s
  time_starttransfer:  %{time_starttransfer}s
                       --------------------------
          time_total:  %{time_total}s
EOF

for node in ${nodes[@]}; do
    for ip in -4 -6; do
        echo; echo "============== $node $ip =============="  
        if [ $ip == -6 ]; then
            ping6 -c 1 $node
        else
            ping -c 1 $node
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
        # if curl exit code isn't 0 print something in red
        [ $curl_exit_code -ne 0 ] && printf "\e[31mCurl failed\e[0m\n"
    done
done
