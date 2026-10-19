#!/bin/bash

set -u
export LC_ALL=C

OUTPUT="${HOME}/.local/share/sing-box-proxy/runcat.json"
TEMP_OUTPUT="${OUTPUT}.tmp.$$"
LISTEN_PORT="18080"
PROXY_URL="http://127.0.0.1:${LISTEN_PORT}"
ENDPOINT="proxy.example.com:443"
INTERVAL=2
HEALTH_INTERVAL=30
JQ="/opt/homebrew/bin/jq"

previous_pid=""
previous_received=0
previous_sent=0
previous_time=0
last_health_time=0
exit_ip="--"
latency="--"

cleanup() {
  /bin/rm -f "$TEMP_OUTPUT"
}
trap cleanup EXIT
trap 'exit 0' INT TERM

human_rate() {
  /usr/bin/awk -v bytes="$1" 'BEGIN {
    if (bytes >= 1048576) printf "%.1f MB/s", bytes / 1048576;
    else if (bytes >= 1024) printf "%.1f KB/s", bytes / 1024;
    else printf "%.0f B/s", bytes;
  }'
}

normalized_rate() {
  /usr/bin/awk -v bytes="$1" 'BEGIN {
    value = bytes / 12500000;
    if (value < 0) value = 0;
    if (value > 1) value = 1;
    printf "%.6f", value;
  }'
}

default_interface() {
  local interface
  interface="$(/sbin/route -n get default 2>/dev/null | /usr/bin/awk '/interface:/{print $2; exit}')"
  if [[ -z "$interface" ]]; then
    interface="en0"
  fi
  printf '%s' "$interface"
}

/bin/mkdir -p "$(/usr/bin/dirname "$OUTPUT")"

while true; do
  current_time="$(/bin/date +%s)"
  updated_at="$(/bin/date -u '+%Y-%m-%dT%H:%M:%SZ')"
  interface="$(default_interface)"
  download_bps=0
  upload_bps=0

  pid="$(/usr/sbin/lsof -nP -iTCP:"${LISTEN_PORT}" -sTCP:LISTEN -a -c sing-box -t 2>/dev/null | /usr/bin/head -n 1)"
  if [[ -n "$pid" ]]; then
    process_counters="$(/usr/bin/nettop -P -L 1 -n -x -p "$pid" -J bytes_in,bytes_out 2>/dev/null | /usr/bin/awk -F, -v target="sing-box.${pid}" '$1 == target {print $2, $3; exit}')"
    received="${process_counters%% *}"
    sent="${process_counters##* }"
    if [[ "$received" =~ ^[0-9]+$ && "$sent" =~ ^[0-9]+$ ]]; then
      if [[ "$pid" == "$previous_pid" && "$previous_time" -gt 0 ]]; then
        elapsed=$((current_time - previous_time))
        (( elapsed > 0 )) || elapsed=1
        (( received >= previous_received )) && download_bps=$(((received - previous_received) / elapsed))
        (( sent >= previous_sent )) && upload_bps=$(((sent - previous_sent) / elapsed))
      fi
      previous_pid="$pid"
      previous_received="$received"
      previous_sent="$sent"
      previous_time="$current_time"
    else
      previous_pid=""
      previous_time=0
    fi

    proxy_status="已连接"
    process_values="$(/bin/ps -p "$pid" -o %cpu= -o rss= -o etime= 2>/dev/null | /usr/bin/xargs)"
    process_cpu="$(printf '%s\n' "$process_values" | /usr/bin/awk '{print $1}')"
    process_rss="$(printf '%s\n' "$process_values" | /usr/bin/awk '{print $2}')"
    process_uptime="$(printf '%s\n' "$process_values" | /usr/bin/awk '{print $3}')"
    [[ "$process_cpu" =~ ^[0-9.]+$ ]] || process_cpu="0"
    [[ "$process_rss" =~ ^[0-9]+$ ]] || process_rss="0"
    [[ -n "$process_uptime" ]] || process_uptime="--"
    memory_mb="$(/usr/bin/awk -v kb="$process_rss" 'BEGIN {printf "%.1f MB", kb / 1024}')"

    proxy_settings="$(/usr/sbin/scutil --proxy 2>/dev/null)"
    if printf '%s\n' "$proxy_settings" | /usr/bin/grep -Eq 'HTTPEnable[[:space:]]*:[[:space:]]*1|SOCKSEnable[[:space:]]*:[[:space:]]*1'; then
      system_proxy="已启用"
    else
      system_proxy="未启用"
    fi

    if (( current_time - last_health_time >= HEALTH_INTERVAL )); then
      health_result="$(/usr/bin/curl -fsS --max-time 8 --proxy "$PROXY_URL" -w '\n%{time_total}' https://api.ipify.org 2>/dev/null || true)"
      health_seconds="$(printf '%s\n' "$health_result" | /usr/bin/tail -n 1)"
      health_ip="$(printf '%s\n' "$health_result" | /usr/bin/head -n 1)"
      if [[ "$health_seconds" =~ ^[0-9.]+$ && "$health_ip" =~ ^[0-9a-fA-F:.]+$ ]]; then
        exit_ip="$health_ip"
        latency="$(/usr/bin/awk -v seconds="$health_seconds" 'BEGIN {printf "%.0f ms", seconds * 1000}')"
      else
        exit_ip="不可用"
        latency="超时"
      fi
      last_health_time="$current_time"
    fi
  else
    previous_pid=""
    previous_received=0
    previous_sent=0
    previous_time=0
    proxy_status="已停止"
    system_proxy="未启用"
    process_cpu="0"
    memory_mb="0 MB"
    process_uptime="--"
    exit_ip="--"
    latency="--"
    last_health_time=0
  fi

  download_rate="$(human_rate "$download_bps")"
  upload_rate="$(human_rate "$upload_bps")"
  download_normalized="$(normalized_rate "$download_bps")"
  upload_normalized="$(normalized_rate "$upload_bps")"
  if [[ -n "$pid" ]]; then
    metrics_bar="ON ${download_rate}"
  else
    metrics_bar="OFF"
  fi

  "$JQ" -n \
    --arg status "$proxy_status" \
    --arg systemProxy "$system_proxy" \
    --arg download "$download_rate" \
    --arg upload "$upload_rate" \
    --arg interface "$interface" \
    --arg endpoint "$ENDPOINT" \
    --arg exitIP "$exit_ip" \
    --arg latency "$latency" \
    --arg cpu "${process_cpu}%" \
    --arg memory "$memory_mb" \
    --arg uptime "$process_uptime" \
    --arg bar "$metrics_bar" \
    --arg updated "$updated_at" \
    --argjson downloadNormalized "$download_normalized" \
    --argjson uploadNormalized "$upload_normalized" \
    '{
      title: "sing-box 代理",
      symbol: "network",
      metricsBarValue: $bar,
      metrics: [
        {title: "代理", formattedValue: $status},
        {title: "系统代理", formattedValue: $systemProxy},
        {title: "代理下载", formattedValue: $download, normalizedValue: $downloadNormalized},
        {title: "代理上传", formattedValue: $upload, normalizedValue: $uploadNormalized},
        {title: "网络接口", formattedValue: $interface},
        {title: "节点", formattedValue: $endpoint},
        {title: "出口 IP", formattedValue: $exitIP},
        {title: "代理延迟", formattedValue: $latency},
        {title: "进程", formattedValue: ("CPU " + $cpu + " / " + $memory)},
        {title: "运行时间", formattedValue: $uptime}
      ],
      lastUpdatedDate: $updated
    }' > "$TEMP_OUTPUT" && /bin/mv -f "$TEMP_OUTPUT" "$OUTPUT"

  /bin/sleep "$INTERVAL"
done
