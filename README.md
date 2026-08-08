# Tailscale LazyCat App

This repository packages [Tailscale](https://tailscale.com/) as a LazyCat application.

## Configuration

During installation, configure these parameters:

- `tailscale auth key`: optional auth key used to join the tailnet automatically.
- `tailscale login server`: optional custom control server URL. Use this for Headscale, for example `https://headscale.example.com`. Leave it empty to use the official Tailscale control server.
- `tailscale hostname`: the node name shown in the tailnet.
- `tailscale extra args`: extra flags passed to `tailscale up`, for example `--accept-routes --accept-dns=true`. See the Tailscale CLI reference: https://tailscale.com/kb/1080/cli

The custom login server value must include the scheme, usually `https://`. For Headscale, it must match the public `server_url` configured on the Headscale server.

If you change this value after the node has already joined a network, remove the old Tailscale state or reinstall the app with cleared app data before joining the new control server.

When the LazyCat optional field is left empty, the container environment may show `<no value>`; the startup script treats that as empty and does not pass a custom login server to Tailscale.

## Headscale Example

If your Headscale server is published at:

```text
https://headscale.example.com
```

Set:

```text
tailscale login server = https://headscale.example.com
tailscale auth key = <your Headscale preauth key>
```

The app starts Tailscale with:

```text
tailscale up --login-server=https://headscale.example.com --authkey=<key> ...
```

## Routes And Exit Node

To accept routes advertised by other nodes:

```text
tailscale extra args = --accept-routes --accept-dns=true
```

To advertise this LazyCat device as an exit node:

```text
tailscale extra args = --advertise-exit-node --accept-dns=true
```

After advertising routes or an exit node, approve them in the Tailscale admin console or Headscale admin UI.

## Notes

The app uses kernel networking with `/dev/net/tun`, `NET_ADMIN`, `NET_RAW`, and host networking. Tailscale state is persisted under `/var/lib/tailscale` inside the container, backed by LazyCat app data, so the node identity survives restarts.

The official Docker parameter reference documents `TS_AUTHKEY`, `TS_STATE_DIR`, `TS_HOSTNAME`, `TS_ROUTES`, `TS_USERSPACE`, and `TS_EXTRA_ARGS`: https://tailscale.com/docs/features/containers/docker/docker-params
