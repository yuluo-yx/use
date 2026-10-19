# sing-box 代理配置

| 目录 | 文件 | 来源 |
| --- | --- | --- |
| `server` | [config.example.json](server/config.example.json) |
| `client` | [config.example.json](client/config.example.json) |

## 客户端

保留本机的混合 HTTP/SOCKS 入口 `127.0.0.1:18080` 和 `set_system_proxy: true`。启动后会设置 macOS 系统代理。

在 `client` 目录执行：

```sh
cp -n config.example.json config.json
# 编辑 config.json，填写服务器、端口、密码、TLS 域名、企业 DNS/域名和有效的二进制 .srs 规则地址。
# 将可信的服务器证书放到本目录 cert.pem，或修改 certificate_path。
sing-box check -c config.json
sing-box run -c config.json
```

## 服务端

保留 Hysteria2 入站、TLS、ALPN `h3` 和直连出站。示例监听 `[::]:443`，需要相应的端口绑定权限，并开放该端口的 UDP。两端密码必须一致，服务器证书必须匹配客户端的 `tls.server_name`。

在 `server` 目录执行：

```sh
cp -n config.example.json config.json
# 编辑 config.json，填写实际监听端口和密码。
# 将服务器证书和私钥放到本目录 cert.pem、private.key，或修改对应路径。
chmod 600 config.json private.key
sing-box check -c config.json
sing-box run -c config.json
```

相对路径以进程工作目录为准；使用 systemd 或 LaunchAgent 时设置对应工作目录，或改为绝对路径。示例保留证书验证，不设置 `insecure`。
