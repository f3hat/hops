#!/bin/bash

set -euo pipefail

RST="\033[0m"
FMT_BOLD="\033[1m"
FMT_ITALIC="\033[3m"
FG_BLACK="\033[38;2;0;0;0m"
FG_GREEN="\033[38;2;0;255;0m"
FG_PURPLE="\033[38;2;255;0;255m"
BG_RED="\033[48;2;255;0;0m"
BG_GREEN="\033[48;2;0;255;0m"

VERSION="v1.0.2"

VALID_OPTIONS=("-d" "-d4" "-d6" "-ns" "-a" "-ptr" "-json" "-v" "-h")

err() {
  printf '%s\n\n' "$1" >&2
  exit 1
}

banner() {
  echo -e "$FG_GREEN$FMT_BOLD"
  cat << "EOF"
          _____                   _______                   _____                    _____
         /\    \                 /::\    \                 /\    \                  /\    \
        /::\____\               /::::\    \               /::\    \                /::\    \
       /:::/    /              /::::::\    \             /::::\    \              /::::\    \
      /:::/    /              /::::::::\    \           /::::::\    \            /::::::\    \
     /:::/    /              /:::/~~\:::\    \         /:::/\:::\    \          /:::/\:::\    \
    /:::/____/              /:::/    \:::\    \       /:::/__\:::\    \        /:::/__\:::\    \
   /::::\    \             /:::/    / \:::\    \     /::::\   \:::\    \       \:::\   \:::\    \
  /::::::\    \   _____   /:::/____/   \:::\____\   /::::::\   \:::\    \    ___\:::\   \:::\    \
 /:::/\:::\    \ /\    \ |:::|    |     |:::|    | /:::/\:::\   \:::\____\  /\   \:::\   \:::\    \
/:::/  \:::\    /::\____\|:::|____|     |:::|    |/:::/  \:::\   \:::|    |/::\   \:::\   \:::\____\
\::/    \:::\  /:::/    / \:::\    \   /:::/    / \::/    \:::\  /:::|____|\:::\   \:::\   \::/    /
 \/____/ \:::\/:::/    /   \:::\    \ /:::/    /   \/_____/\:::\/:::/    /  \:::\   \:::\   \/____/
          \::::::/    /     \:::\    /:::/    /             \::::::/    /    \:::\   \:::\    \
           \::::/    /       \:::\__/:::/    /               \::::/    /      \:::\   \:::\____\
           /:::/    /         \::::::::/    /                 \::/____/        \:::\  /:::/    /
          /:::/    /           \::::::/    /                   ~~               \:::\/:::/    /
         /:::/    /             \::::/    /                                      \::::::/    /
        /:::/    /               \::/____/                                        \::::/    /
        \::/    /                 ~~                                               \::/    /
         \/____/                                                                    \/____/
EOF
  echo -e "                                                                                             $FG_PURPLE$VERSION"
  echo -e "                                                                             $FG_GREEN github.com/f3hat/hops"
  echo -e "                                                                          halbritter@member.fsf.org$RST\n"
}

require() {
  command -v "$1" >/dev/null || err "Missing dependency: $1"
}

validate_domain() {
  local domain="$1"

  if ! LC_ALL=C grep -qE '^[a-zA-Z0-9.-]+$' <<< "$domain"; then
    err "Invalid domain: $domain"
  fi

  [[ "$domain" =~ ^[-.] || "$domain" =~ [-.]$ ]] && err "Invalid domain: $domain"
  [[ "$domain" =~ \.\. ]] && err "Invalid domain: $domain"

  local parts part
  IFS='.' read -ra parts <<< "$domain"
  for part in "${parts[@]}"; do
    [[ "$part" =~ ^- || "$part" =~ -$ ]] && err "Invalid domain: $domain"
  done

  [[ "$domain" =~ ^([a-zA-Z0-9][-a-zA-Z0-9]*\.)+[a-zA-Z]{2,}$ ]] || err "Invalid domain: $domain"
}

resolve_ipv4() {
  timeout 5 dig A +short "$1" 2>/dev/null | grep -E '^[0-9.]+$' | head -n1 || echo ""
}

resolve_ipv6() {
  timeout 5 dig AAAA +short "$1" 2>/dev/null | grep -E '^[0-9a-fA-F:]+$' | head -n1 || echo ""
}

resolve_ptr() {
  [ -z "$1" ] && echo "" && return
  timeout 5 dig -x "$1" +short 2>/dev/null | paste -sd ',' - || echo ""
}

get_cymru() {
  timeout 5 whois -h whois.cymru.com " -v $1" 2>/dev/null | awk '
    NR==2 {
      asn = ($1 == "NA" ? "" : "ASN" $1)
      prefix = ($5 == "NA" ? "" : " | " $5 " | ")
      org = ""
      for (i = 13; i <= NF; i++) org = org (i == 13 ? "" : " ") $i
      if (org == "NA") org = ""
      print "        " asn prefix org
    }'
}

show_ip() {
  local ipv4 ipv6
  ipv4=$(resolve_ipv4 "$1")
  ipv6=$(resolve_ipv6 "$1")
  echo -e "\n        IPv4: ${ipv4:-Not found} <- $1"
  echo -e "\n        IPv6: ${ipv6:-Not found} <- $1"
}

show_ip4() {
  local ip
  ip=$(resolve_ipv4 "$1")
  echo -e "\n        IPv4: ${ip:-Not found} <- $1"
}

show_ip6() {
  local ip
  ip=$(resolve_ipv6 "$1")
  echo -e "\n        IPv6: ${ip:-Not found} <- $1"
}

show_ptr() {
  local ip ptr
  ip=$(resolve_ipv4 "$1")
  if [ -z "$ip" ]; then
    echo -e "\n        IPv4: Not found <- $1"
    echo -e "\n        PTR: Not available"
    return
  fi
  ptr=$(resolve_ptr "$ip")
  if [ -n "$ptr" ]; then
    echo -e "\n        $ip <- $ptr"
  else
    echo -e "\n        $ip <- PTR not found or unavailable"
  fi
}

show_ns() {
  local ns_list ns nsip info
  ns_list=$(timeout 5 dig "$1" NS +short 2>/dev/null)
  if [ -z "$ns_list" ]; then
    echo -e "\n        Nameservers not found <- $1"
    return
  fi
  echo "$ns_list" | while IFS= read -r ns; do
    nsip=$(timeout 5 dig +short "$ns" 2>/dev/null | head -n1)
    info=$(get_cymru "$nsip")
    echo -e "\n        ${nsip:-Not found} <- $ns\n$info"
  done
}

show_hops() {
  local ip info
  ip=$(resolve_ipv4 "$1")
  if [ -z "$ip" ]; then
    echo -e "\n        Hops not available <- $1"
    return
  fi

  local hops=()
  mapfile -t hops < <(timeout 10 traceroute -n "$1" 2>/dev/null | awk 'NR>1 {print $2}')
  if [ ${#hops[@]} -eq 0 ]; then
    echo -e "\n        Hops not found or traceroute failed <- $1"
    return
  fi

  local hop
  for hop in "${hops[@]}"; do
    if [ "$hop" != "*" ]; then
      info=$(get_cymru "$hop")
      echo -e "\n $FMT_BOLD$FG_BLACK$BG_GREEN$FMT_ITALIC hop! $RST $hop\n$info"
    else
      echo -e "\n $FMT_BOLD$FG_BLACK$BG_RED$FMT_ITALIC ops! $RST *"
    fi
  done
}

show_all() {
  local ip
  ip=$(resolve_ipv4 "$1")
  echo -e "\n$FMT_BOLD$FG_PURPLE Domain $RST\n\n        ${ip:-Not found} <- $1"
  echo -e "\n$FMT_BOLD$FG_PURPLE Nameservers (NS) $RST"
  show_ns "$1"
  echo -e "\n$FMT_BOLD$FG_PURPLE Hops $RST"
  show_hops "$1"
  echo -e "\n$FMT_BOLD$FG_PURPLE Reverse DNS (PTR) $RST"
  show_ptr "$1"
  echo
}

show_json() {
  local ipv4 ipv6 ptr resolved_ptr ns
  ipv4=$(resolve_ipv4 "$1")
  ipv6=$(resolve_ipv6 "$1")
  ptr="null"
  if [ -n "$ipv4" ]; then
    resolved_ptr=$(resolve_ptr "$ipv4")
    [ -n "$resolved_ptr" ] && ptr="$resolved_ptr"
  fi
  ns=$(timeout 5 dig "$1" NS +short 2>/dev/null | paste -sd ',' - || echo "")
  echo "{\"domain\":\"$1\",\"ipv4\":\"${ipv4:-null}\",\"ipv6\":\"${ipv6:-null}\",\"ptr\":\"$ptr\",\"nameservers\":\"${ns:-null}\"}"
}

usage() {
  banner
  echo -e "$FG_PURPLE$FMT_BOLD\nUsage:$RST hops [option] <domain>"
  echo -e "\nOptions:"
  echo -e "  -d       Show both IPv4 and IPv6 addresses"
  echo -e "  -d4      Show only the IPv4 address"
  echo -e "  -d6      Show only the IPv6 address"
  echo -e "  -ns      Show only the nameservers"
  echo -e "  -a       Show only the hops (traceroute)"
  echo -e "  -ptr     Show only the reverse DNS (PTR)"
  echo -e "  -json    Output domain info in JSON format"
  echo -e "  -v       Show version"
  echo -e "  -h       Show this help message"
  echo -e "\nNo option: show all information."
  echo -e "\nFor more details, see: man hops\n"
  exit 1
}

main() {
  require dig
  require traceroute
  require whois

  if [ $# -eq 1 ]; then
    case "$1" in
      -v)
        banner
        echo "hops $VERSION"
        echo
        exit 0
        ;;
      -h)
        usage
        ;;
      *)
        validate_domain "$1"
        banner
        show_all "$1"
        exit 0
        ;;
    esac
  elif [ $# -eq 2 ]; then
    [[ " ${VALID_OPTIONS[*]} " =~ " $1 " ]] || usage
    validate_domain "$2"
  else
    usage
  fi

  case "$1" in
    -d)    echo -e "\n$FMT_BOLD$FG_PURPLE Domain $RST"; show_ip "$2"; echo ;;
    -d4)   echo -e "\n$FMT_BOLD$FG_PURPLE Domain $RST"; show_ip4 "$2"; echo ;;
    -d6)   echo -e "\n$FMT_BOLD$FG_PURPLE Domain $RST"; show_ip6 "$2"; echo ;;
    -ns)   echo -e "\n$FMT_BOLD$FG_PURPLE Nameservers (NS) $RST"; show_ns "$2"; echo ;;
    -a)    echo -e "\n$FMT_BOLD$FG_PURPLE Hops $RST"; show_hops "$2"; echo ;;
    -ptr)  echo -e "\n$FMT_BOLD$FG_PURPLE Reverse DNS (PTR) $RST"; show_ptr "$2"; echo ;;
    -json) show_json "$2"; echo ;;
    -v)    banner; echo "hops $VERSION"; echo ;;
    -h)    usage ;;
  esac
}

main "$@"

