#!/bin/sh

doit() {
  echo "Processing: $1"
  mkdir -p $2ipv4 $2ipv6
  [ -z "$1" ] && dash="" || { dash="-"; grep ",$1," egress-ip-ranges.csv > $2egress-ip-ranges.csv; }
  cut -d ',' -f 1 $2egress-ip-ranges.csv > $2egress-ip-ranges.txt && \
    grep -E '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+(/[0-9]+)?$' $2egress-ip-ranges.txt > $2ipv4-only.txt && \
    grep -E '^[0-9a-fA-F:]+(/[0-9]+)?$' $2egress-ip-ranges.txt > $2ipv6-only.txt && \
    wc -l $2egress-ip-ranges.txt && \
    wc -l $2ipv4-only.txt && \
    wc -l $2ipv6-only.txt && \
    cidr-merger -eo $2ip-ranges.txt $2egress-ip-ranges.txt && \
    cidr-merger -eo $2ipv4/$1${dash}ipv4-ranges.txt $2ipv4-only.txt && \
    cidr-merger -eo $2ipv6/$1${dash}ipv6-ranges.txt $2ipv6-only.txt && \
    wc -l $2ip-ranges.txt && \
    wc -l $2ipv4/$1${dash}ipv4-ranges.txt && \
    wc -l $2ipv6/$1${dash}ipv6-ranges.txt

  ## ipset list
  echo "create icloudrelay hash:net" > $2ip-ranges.ipset
  for ip in $(cat $2ip-ranges.txt); do
    echo "add icloudrelay $ip" >> $2ip-ranges.ipset
  done

  echo "create icloudrelayipv4 hash:net" > $2ipv4/$1${dash}ipv4-ranges.ipset
  for ip in $(cat $2ipv4/$1${dash}ipv4-ranges.txt); do
    echo "add icloudrelayipv4 $ip" >> $2ipv4/$1${dash}ipv4-ranges.ipset
  done

  echo "create icloudrelayipv6 hash:net" > $2ipv6/$1${dash}ipv6-ranges.ipset
  for ip in $(cat $2ipv6/$1${dash}ipv6-ranges.txt); do
    echo "add icloudrelayipv6 $ip" >> $2ipv6/$1${dash}ipv6-ranges.ipset
  done

  ## json files
  cat $2ip-ranges.txt | jq -R --slurp 'split("\n") | .[:-1]' > $2ip-ranges.json
  cat $2ipv4/$1${dash}ipv4-ranges.txt | jq -R --slurp 'split("\n") | .[:-1]' > $2ipv4/$1${dash}ipv4-ranges.json
  cat $2ipv6/$1${dash}ipv6-ranges.txt | jq -R --slurp 'split("\n") | .[:-1]' > $2ipv6/$1${dash}ipv6-ranges.json
}

## build basics
curl -sLO "https://mask-api.icloud.com/egress-ip-ranges.csv"

[ ! -e egress-ip-ranges.csv ] && echo "File does not exists egress-ip-ranges.csv" && exit 1

cut -d ',' -f 2 egress-ip-ranges.csv | sort | uniq | sed '/^[[:space:]]*$/d' > egress-countries.txt

# Do first the complete list, after do each country
doit "" ""
while IFS= read -r line; do
    doit "$line" "geo_country/$line/$line-"
done < egress-countries.txt

find . -name "*egress-ip-ranges.csv" -delete
find . -name "*egress*.txt" -delete
find . -name "*only.txt" -delete
