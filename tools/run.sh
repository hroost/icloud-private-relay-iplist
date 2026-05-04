#!/bin/sh

set -eu

feed_url="https://mask-api.icloud.com/egress-ip-ranges.csv"
tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT HUP INT TERM

write_ipset() {
  input_file=$1
  output_file=$2
  set_name=$3

  {
    printf 'create %s hash:net\n' "$set_name"
    while IFS= read -r ip; do
      [ -n "$ip" ] || continue
      printf 'add %s %s\n' "$set_name" "$ip"
    done < "$input_file"
  } > "$output_file"
}

write_json() {
  input_file=$1
  output_file=$2

  jq -Rcs 'split("\n") | map(select(length > 0))' < "$input_file" > "$output_file"
}

fetch_ranges() {
  curl -fsSL --retry 3 --retry-delay 2 --retry-connrefused "$feed_url" \
    | cut -d ',' -f 1 > "$tmpdir/egress-ip-ranges.txt"

  [ -s "$tmpdir/egress-ip-ranges.txt" ]

  grep -E '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+(/[0-9]+)?$' "$tmpdir/egress-ip-ranges.txt" > "$tmpdir/ipv4-only.txt"
  grep -E '^[0-9a-fA-F:]+(/[0-9]+)?$' "$tmpdir/egress-ip-ranges.txt" > "$tmpdir/ipv6-only.txt"

  total_count=$(wc -l < "$tmpdir/egress-ip-ranges.txt")
  ipv4_count=$(wc -l < "$tmpdir/ipv4-only.txt")
  ipv6_count=$(wc -l < "$tmpdir/ipv6-only.txt")

  [ "$total_count" -gt 0 ]
  [ $((ipv4_count + ipv6_count)) -eq "$total_count" ]

  printf '%s %s\n' "$total_count" "$tmpdir/egress-ip-ranges.txt"
  printf '%s %s\n' "$ipv4_count" "$tmpdir/ipv4-only.txt"
  printf '%s %s\n' "$ipv6_count" "$tmpdir/ipv6-only.txt"
}

build_ranges() {
  cidr-merger -eo "$tmpdir/ip-ranges.txt" "$tmpdir/egress-ip-ranges.txt"
  cidr-merger -eo "$tmpdir/ipv4-ranges.txt" "$tmpdir/ipv4-only.txt"
  cidr-merger -eo "$tmpdir/ipv6-ranges.txt" "$tmpdir/ipv6-only.txt"

  wc -l "$tmpdir/ip-ranges.txt"
  wc -l "$tmpdir/ipv4-ranges.txt"
  wc -l "$tmpdir/ipv6-ranges.txt"
}

publish_outputs() {
  write_ipset "$tmpdir/ip-ranges.txt" "$tmpdir/ip-ranges.ipset" "icloudrelay"
  write_ipset "$tmpdir/ipv4-ranges.txt" "$tmpdir/ipv4-ranges.ipset" "icloudrelayipv4"
  write_ipset "$tmpdir/ipv6-ranges.txt" "$tmpdir/ipv6-ranges.ipset" "icloudrelayipv6"

  write_json "$tmpdir/ip-ranges.txt" "$tmpdir/ip-ranges.json"
  write_json "$tmpdir/ipv4-ranges.txt" "$tmpdir/ipv4-ranges.json"
  write_json "$tmpdir/ipv6-ranges.txt" "$tmpdir/ipv6-ranges.json"

  mv "$tmpdir/egress-ip-ranges.txt" egress-ip-ranges.txt
  mv "$tmpdir/ipv4-only.txt" ipv4-only.txt
  mv "$tmpdir/ipv6-only.txt" ipv6-only.txt
  mv "$tmpdir/ip-ranges.txt" ip-ranges.txt
  mv "$tmpdir/ip-ranges.ipset" ip-ranges.ipset
  mv "$tmpdir/ip-ranges.json" ip-ranges.json
  mv "$tmpdir/ipv4-ranges.txt" ipv4/ipv4-ranges.txt
  mv "$tmpdir/ipv4-ranges.ipset" ipv4/ipv4-ranges.ipset
  mv "$tmpdir/ipv4-ranges.json" ipv4/ipv4-ranges.json
  mv "$tmpdir/ipv6-ranges.txt" ipv6/ipv6-ranges.txt
  mv "$tmpdir/ipv6-ranges.ipset" ipv6/ipv6-ranges.ipset
  mv "$tmpdir/ipv6-ranges.json" ipv6/ipv6-ranges.json
}

fetch_ranges
build_ranges
publish_outputs
