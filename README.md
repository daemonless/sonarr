# Sonarr

Sonarr TV series management on FreeBSD.

| | |
|---|---|
| **Port** | 8989 |
| **Registry** | `ghcr.io/daemonless/sonarr` |
| **Source** | [https://github.com/Sonarr/Sonarr](https://github.com/Sonarr/Sonarr) |
| **Website** | [https://sonarr.tv/](https://sonarr.tv/) |

## Deployment

### Podman Compose

```yaml
services:
  sonarr:
    image: ghcr.io/daemonless/sonarr:latest
    container_name: sonarr
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=UTC
    volumes:
      - /path/to/containers/sonarr:/config
      - /path/to/tv:/tv # optional
      - /path/to/downloads:/downloads # optional
    ports:
      - 8989:8989
    annotations:
      org.freebsd.jail.allow.mlock: "true"
    restart: unless-stopped
```

### Podman CLI

```bash
podman run -d --name sonarr \
  -p 8989:8989 \
  --annotation 'org.freebsd.jail.allow.mlock=true' \
  -e PUID=@PUID@ \
  -e PGID=@PGID@ \
  -e TZ=@TZ@ \
  -v /path/to/containers/sonarr:/config \ 
  -v /path/to/tv:/tv \  # optional
  -v /path/to/downloads:/downloads \  # optional
  ghcr.io/daemonless/sonarr:latest
```
Access at: `http://localhost:8989`

### Ansible

```yaml
- name: Deploy sonarr
  containers.podman.podman_container:
    name: sonarr
    image: ghcr.io/daemonless/sonarr:latest
    state: started
    restart_policy: always
    env:
      PUID: "@PUID@"
      PGID: "@PGID@"
      TZ: "@TZ@"
    ports:
      - "8989:8989"
    volumes:
      - "/path/to/containers/sonarr:/config"
      - "/path/to/tv:/tv" # optional
      - "/path/to/downloads:/downloads" # optional
    annotation:
      org.freebsd.jail.allow.mlock: "true"
```

## Configuration
### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `PUID` | `1000` | User ID for the application process |
| `PGID` | `1000` | Group ID for the application process |
| `TZ` | `UTC` | Timezone for the container |
### Volumes

| Path | Description |
|------|-------------|
| `/config` | Configuration directory |
| `/tv` | TV Series library (Optional) |
| `/downloads` | Download directory (Optional) |
### Ports

| Port | Protocol | Description |
|------|----------|-------------|
| `8989` | TCP | Web UI |

## Notes

- **User:** `bsd` (UID/GID set via PUID/PGID)
- **Base:** Built on `ghcr.io/daemonless/base` (FreeBSD)
- **.NET App:** Requires `--annotation 'org.freebsd.jail.allow.mlock=true'` and a [patched ocijail](https://daemonless.io/guides/ocijail-patch).