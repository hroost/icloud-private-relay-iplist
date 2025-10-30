#!/bin/sh

doit() {
  echo "Processing: $1"
  mkdir -p $2ipv4 $2ipv6
  [ -z "$1" ] && dash="" || { dash="-"; grep ",$1," egress-ip-ranges.csv > $2egress-ip-ranges.csv; }
  awk -v p="$2" 'BEGIN { FS="," } 
    {
    ip = $1
    print ip > p "egress-ip-ranges.txt"
        if (ip ~ /^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+(\/[0-9]+)?$/) {
            print ip > p "ipv4-only.txt"
        } 
        else if (ip ~ /^[0-9a-fA-F:]+(\/[0-9]+)?$/) {
            print ip > p "ipv6-only.txt"
        }
    }
  ' "$2egress-ip-ranges.csv"
  cidr-merger -eo $2ip-ranges.txt $2egress-ip-ranges.txt && \
  cidr-merger -eo $2ipv4/$1${dash}ipv4-ranges.txt $2ipv4-only.txt && \
  cidr-merger -eo $2ipv6/$1${dash}ipv6-ranges.txt $2ipv6-only.txt && \
  wc -l --total=never $2egress-ip-ranges.txt $2ipv4-only.txt $2ipv6-only.txt $2ip-ranges.txt $2ipv4/$1${dash}ipv4-ranges.txt $2ipv6/$1${dash}ipv6-ranges.txt

  ## ipset list
  echo "create icloudrelay hash:net" > "$2ip-ranges.ipset"
  awk '{print "add icloudrelay " $1}' "$2ip-ranges.txt" >> "$2ip-ranges.ipset"
  
  echo "create icloudrelayipv4 hash:net" > "$2ipv4/$1${dash}ipv4-ranges.ipset"
  awk '{print "add icloudrelayipv4 " $1}' "$2ipv4/$1${dash}ipv4-ranges.txt" >> "$2ipv4/$1${dash}ipv4-ranges.ipset"
  
  echo "create icloudrelayipv6 hash:net" > "$2ipv6/$1${dash}ipv6-ranges.ipset"
  awk '{print "add icloudrelayipv6 " $1}' "$2ipv6/$1${dash}ipv6-ranges.txt" >> "$2ipv6/$1${dash}ipv6-ranges.ipset"

  ## json files
  jq -R --slurp 'split("\n") | .[:-1]' "$2ip-ranges.txt" > "$2ip-ranges.json"
  jq -R --slurp 'split("\n") | .[:-1]' "$2ipv4/$1${dash}ipv4-ranges.txt" > "$2ipv4/$1${dash}ipv4-ranges.json"
  jq -R --slurp 'split("\n") | .[:-1]' "$2ipv6/$1${dash}ipv6-ranges.txt" > "$2ipv6/$1${dash}ipv6-ranges.json"
}

## build basics
curl -sLO "https://mask-api.icloud.com/egress-ip-ranges.csv"

[ ! -e egress-ip-ranges.csv ] && echo "File does not exists egress-ip-ranges.csv" && exit 1

cut -d ',' -f 2 egress-ip-ranges.csv | sort -u | sed '/^[[:space:]]*$/d' > egress-countries.txt

# Do first the complete list, after do each country
doit "" ""
while IFS= read -r line; do
    doit "$line" "geo_country/$line/$line-"
done < egress-countries.txt

find . \( -name "*egress-ip-ranges.csv" -o -name "*egress*.txt" -o -name "*only.txt" \) -delete
