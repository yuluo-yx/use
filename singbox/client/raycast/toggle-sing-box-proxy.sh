#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title 切换 sing-box 代理
# @raycast.mode compact

# Optional parameters:
# @raycast.packageName 网络工具
# @raycast.icon 🌐
# @raycast.description 启动或关闭本次归档的 Hysteria2 代理与 macOS 系统代理

set -u

SING_BOX_BIN="${HOME}/.local/bin/sing-box"
SING_BOX_CONFIG="${HOME}/.config/sing-box-proxy/client.json"
SERVICE_LABEL="com.example.sing-box-proxy"
SERVICE_PLIST="${HOME}/Library/LaunchAgents/${SERVICE_LABEL}.plist"
SERVICE_DOMAIN="gui/$(/usr/bin/id -u)/${SERVICE_LABEL}"
LISTEN_PORT="18080"

is_running() {
  /usr/sbin/lsof -nP -iTCP:"${LISTEN_PORT}" -sTCP:LISTEN -a -c sing-box >/dev/null 2>&1
}

if is_running; then
  if /bin/launchctl print "$SERVICE_DOMAIN" >/dev/null 2>&1; then
    if ! /bin/launchctl bootout "$SERVICE_DOMAIN" >/dev/null 2>&1; then
      echo "停止 sing-box 失败"
      exit 1
    fi
  else
    echo "端口 ${LISTEN_PORT} 被非托管 sing-box 进程占用"
    exit 1
  fi

  for _ in {1..16}; do
    if ! is_running; then
      echo "sing-box 代理：已关闭"
      exit 0
    fi
    /bin/sleep 0.25
  done
  echo "sing-box 未能在 4 秒内停止"
  exit 1
fi

if [[ ! -x "$SING_BOX_BIN" ]]; then
  echo "未找到 sing-box 可执行文件"
  exit 1
fi
if [[ ! -r "$SING_BOX_CONFIG" || ! -r "$SERVICE_PLIST" ]]; then
  echo "未找到 sing-box 配置或 LaunchAgent"
  exit 1
fi
if ! "$SING_BOX_BIN" check -c "$SING_BOX_CONFIG" >/dev/null 2>&1; then
  echo "sing-box 配置校验失败"
  exit 1
fi

/bin/mkdir -p "${HOME}/Library/Logs/sing-box-proxy"
if /bin/launchctl print "$SERVICE_DOMAIN" >/dev/null 2>&1; then
  if ! /bin/launchctl kickstart -k "$SERVICE_DOMAIN" >/dev/null 2>&1; then
    echo "重启 sing-box 失败"
    exit 1
  fi
else
  if ! /bin/launchctl bootstrap "gui/$(/usr/bin/id -u)" "$SERVICE_PLIST" >/dev/null 2>&1; then
    echo "载入 sing-box LaunchAgent 失败"
    exit 1
  fi
  if ! /bin/launchctl kickstart -k "$SERVICE_DOMAIN" >/dev/null 2>&1; then
    echo "启动 sing-box LaunchAgent 失败"
    exit 1
  fi
fi

for _ in {1..24}; do
  if is_running; then
    PROXY_IP="$(/usr/bin/curl -fsS --max-time 8 --proxy http://127.0.0.1:${LISTEN_PORT} https://api.ipify.org 2>/dev/null || true)"
    if [[ -n "$PROXY_IP" ]]; then
      echo "sing-box 代理：已开启（${PROXY_IP}）"
    else
      echo "sing-box 代理：已开启（等待连通）"
    fi
    exit 0
  fi
  /bin/sleep 0.25
done

echo "sing-box 启动失败，请检查 ~/Library/Logs/sing-box-proxy"
exit 1
