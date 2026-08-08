# Tailscale 懒猫应用

这个仓库把 [Tailscale](https://tailscale.com/) 打包为懒猫应用。

## 安装参数

安装时可以配置这些参数：

- `tailscale 认证密钥`：可选，用于自动加入 tailnet。
- `tailscale 登录服务器`：可选，自定义控制服务器 URL。使用 Headscale 时填写，例如 `https://headscale.example.com`。留空则使用 Tailscale 官方控制服务器。
- `tailscale 主机名`：显示在 tailnet 里的节点名。
- `tailscale 额外参数`：传给 `tailscale up` 的额外参数，例如 `--accept-routes --accept-dns=true`。参考 Tailscale CLI 文档：https://tailscale.com/kb/1080/cli

自定义登录服务器必须包含协议头，通常是 `https://`。如果连接 Headscale，这里必须填写 Headscale 配置里的公网 `server_url`。

如果节点已经加入过一个网络，之后再修改这个登录服务器地址，需要先清理旧的 Tailscale 状态，或者卸载应用时删除应用数据后重新安装，再加入新的控制服务器。

懒猫可选参数留空时，容器环境变量里可能显示为 `<no value>`；启动脚本会把它当作空值处理，不会传给 Tailscale。

## Headscale 示例

如果 Headscale 对外地址是：

```text
https://headscale.example.com
```

安装时填写：

```text
tailscale 登录服务器 = https://headscale.example.com
tailscale 认证密钥 = <你的 Headscale 预授权密钥>
```

应用启动时会按类似方式加入网络：

```text
tailscale up --login-server=https://headscale.example.com --authkey=<key> ...
```

## 路由和出口节点

接受其他节点发布的子网路由：

```text
tailscale 额外参数 = --accept-routes --accept-dns=true
```

把这台懒猫设备发布为出口节点：

```text
tailscale 额外参数 = --advertise-exit-node --accept-dns=true
```

发布子网路由或出口节点后，还需要在 Tailscale 管理后台或 Headscale 管理界面里批准。

## 域名说明

`tailscale 登录服务器` 是控制服务器地址，不是 MagicDNS 域名。使用 Headscale 时，它应该是客户端可以访问到的 Headscale 公网 HTTPS 地址，例如 `https://headscale.example.com`。

如果你的 Headscale 放在懒猫应用里，对外域名、反向代理和 HTTPS 要在 Headscale 应用侧先配置好。Tailscale 客户端只需要填写最终可访问的 `server_url`。

## 运行方式

本应用使用内核网络模式，需要 `/dev/net/tun`、`NET_ADMIN`、`NET_RAW` 和 host 网络。Tailscale 状态保存在容器内 `/var/lib/tailscale`，并映射到懒猫应用数据目录，因此重启后节点身份会保留。

官方 Docker 参数文档说明了 `TS_AUTHKEY`、`TS_STATE_DIR`、`TS_HOSTNAME`、`TS_ROUTES`、`TS_USERSPACE` 和 `TS_EXTRA_ARGS` 等参数：https://tailscale.com/docs/features/containers/docker/docker-params
