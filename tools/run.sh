#!/bin/sh
set -x

## build basics
curl -sL "https://mask-api.icloud.com/egress-ip-ranges.csv" | cut -d ',' -f 1 > egress-ip-ranges.txt && \
  grep -E '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+(/[0-9]+)?$' egress-ip-ranges.txt > ipv4-only.txt && \
  grep -E '^[0-9a-fA-F:]+(/[0-9]+)?$' egress-ip-ranges.txt > ipv6-only.txt && \
  wc -l egress-ip-ranges.txt && \
  wc -l ipv4-only.txt && \
  wc -l ipv6-only.txt && \
  cidr-merger -eo ip-ranges.txt egress-ip-ranges.txt && \
  cidr-merger -eo ipv4-ranges.txt ipv4-only.txt && \
  cidr-merger -eo ipv6-ranges.txt ipv6-only.txt && \
  wc -l ip-ranges.txt && \
  wc -l ipv4-ranges.txt && \
  wc -l ipv6-ranges.txt


## ipset list
echo "create icloudrelay hash:net" > ip-ranges.ipset.txt
for ip in $(cat ip-ranges.txt); do
  echo "add icloudrelay $ip" >> ip-ranges.ipset.txt
done

echo "create icloudrelayipv4 hash:net" > ipv4-ranges.ipset.txt
for ip in $(cat ipv4-ranges.txt); do
  echo "add icloudrelayipv4 $ip" >> ipv4-ranges.ipset.txt
done

echo "create icloudrelayipv6 hash:net" > ipv6-ranges.ipset.txt
for ip in $(cat ipv6-ranges.txt); do
  echo "add icloudrelayipv6 $ip" >> ipv6-ranges.ipset.txt
done

## json files
cat ip-ranges.txt | jq -R --slurp 'split("\n") | .[:-1]' > ip-ranges.json
cat ipv4-ranges.txt | jq -R --slurp 'split("\n") | .[:-1]' > ipv4-ranges.json
cat ipv6-ranges.txt | jq -R --slurp 'split("\n") | .[:-1]' > ipv6-ranges.json
