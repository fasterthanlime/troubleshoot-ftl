#!/bin/bash
set -u

echo "fasterthanli.me resolves to: "
dig fasterthanli.me +short

read -d '\n' curl_format << EOF
        time_connect:  %{time_connect}s
     time_appconnect:  %{time_appconnect}s
    time_pretransfer:  %{time_pretransfer}s
  time_starttransfer:  %{time_starttransfer}s
                       --------------------------
          time_total:  %{time_total}s
EOF

HOSTS=(pari falk ginz szaw hell flam marl safo pore)
for HOST in ${HOSTS[@]}; do
    for ip in -4 -6; do
        echo; echo "============== $HOST $ip =============="  
        # run ping6 if $ip is -6
        if [ $ip == -6 ]; then
            ping6 -c 3 $HOST.bearcove.cloud
        else
            ping -c 3 $HOST.bearcove.cloud
        fi
        curl $ip \
            --write-out "${curl_format}" \
            --output /dev/null \
            --fail \
            --connect-timeout 5 \
            --connect-to fasterthanli.me:443:$HOST.bearcove.cloud:443 \
            "https://fasterthanli.me"
        echo "curl exit code: $?"
    done
done
