#!/bin/sh
set -x

curl -sL "https://mask-api.icloud.com/egress-ip-ranges.csv" | cut -d ',' -f 1 > egress-ip-ranges.txt && \
  grep -E '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+(/[0-9]+)?$' egress-ip-ranges.txt > ipv4-only.txt && \
  grep -E '^[0-9a-fA-F:]+(/[0-9]+)?$' egress-ip-ranges.txt > ipv6-only.txt && \
  wc -l egress-ip-ranges.txt && \
  wc -l ipv4-only.txt && \
  wc -l ipv6-only.txt && \
  cidr-merger -eo ip-ranges.txt egress-ip-ranges.txt && \
  cidr-merger -eo ip-ranges.txt ipv4-only.txt && \
  cidr-merger -eo ip-ranges.txt ipv6-only.txt && \
  wc -l ip-ranges.txt && \
  wc -l ipv4-ranges.txt && \
  wc -l ipv6-ranges.txt
