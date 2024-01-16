#!/bin/bash
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
    echo; echo; echo "============== $HOST =============="
    ping -c 3 $HOST.bearcove.cloud
    curl -w "${curl_format}" -o /dev/null -s "https://fasterthanli.me" --connect-to fasterthanli.me:443:$HOST.bearcove.cloud:443
done
