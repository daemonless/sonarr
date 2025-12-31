ARG BASE_VERSION=15
FROM ghcr.io/daemonless/arr-base:${BASE_VERSION}

ARG FREEBSD_ARCH=amd64
ARG PACKAGES="sonarr"
ARG SONARR_BRANCH="main"
ARG UPSTREAM_URL="https://services.sonarr.tv/v1/releases"
ARG UPSTREAM_JQ=".\"v4-stable\".version"
ARG HEALTHCHECK_ENDPOINT="http://localhost:8989/ping"

ENV HEALTHCHECK_URL="${HEALTHCHECK_ENDPOINT}"

LABEL org.opencontainers.image.title="Sonarr" \
    org.opencontainers.image.description="Sonarr TV show management on FreeBSD" \
    org.opencontainers.image.source="https://github.com/daemonless/sonarr" \
    org.opencontainers.image.url="https://sonarr.tv/" \
    org.opencontainers.image.documentation="https://wiki.servarr.com/sonarr" \
    org.opencontainers.image.licenses="GPL-3.0-only" \
    org.opencontainers.image.vendor="daemonless" \
    org.opencontainers.image.authors="daemonless" \
    io.daemonless.port="8989" \
    io.daemonless.arch="${FREEBSD_ARCH}" \
    io.daemonless.volumes="/tv,/downloads" \
    org.freebsd.jail.allow.mlock="required" \
    io.daemonless.category="Media Management" \
    io.daemonless.upstream-url="${UPSTREAM_URL}" \
    io.daemonless.upstream-jq="${UPSTREAM_JQ}" \
    io.daemonless.healthcheck-url="${HEALTHCHECK_ENDPOINT}" \
    io.daemonless.packages="${PACKAGES}"

# Install Sonarr from FreeBSD packages
RUN pkg update && \
    pkg install -y ${PACKAGES} && \
    pkg clean -ay && \
    rm -rf /var/cache/pkg/* /var/db/pkg/repos/*

# Download and install Sonarr
RUN mkdir -p /usr/local/share/sonarr /config && \
    SONARR_VERSION=$(fetch -qo - "https://services.sonarr.tv/v1/releases" | \
    grep -o '"v4-stable":{[^}]*"version":"[^"]*"' | grep -o '"version":"[^"]*"' | cut -d'"' -f4) && \
    fetch -qo - "https://services.sonarr.tv/v1/download/${SONARR_BRANCH}/latest?version=4&os=freebsd" | \
    tar xzf - -C /usr/local/share/sonarr --strip-components=1 && \
    rm -rf /usr/local/share/sonarr/Sonarr.Update && \
    chmod +x /usr/local/share/sonarr/Sonarr && \
    chmod -R o+rX /usr/local/share/sonarr && \
    printf "UpdateMethod=docker\nBranch=main\nPackageVersion=%s\nPackageAuthor=[daemonless](https://github.com/daemonless/daemonless)\n" "$SONARR_VERSION" > /usr/local/share/sonarr/package_info && \
    mkdir -p /app && echo "$SONARR_VERSION" > /app/version && \
    chown -R bsd:bsd /usr/local/share/sonarr /config

# Copy service definition and init scripts
COPY root/ /

# Make scripts executable
RUN chmod +x /etc/services.d/sonarr/run /etc/cont-init.d/* 2>/dev/null || true

EXPOSE 8989
VOLUME /config


