ARG BASE_VERSION=15
FROM ghcr.io/daemonless/arr-base:${BASE_VERSION}

ARG FREEBSD_ARCH=amd64
LABEL org.opencontainers.image.title="sonarr" \
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
      org.freebsd.jail.allow.mlock="required"

# Download and install Sonarr (fetch latest v4-stable FreeBSD URL from API)
RUN mkdir -p /usr/local/share/sonarr && \
    SONARR_VERSION=$(fetch -qo - "https://services.sonarr.tv/v1/releases" | \
        grep -o '"version":"[^"]*"' | head -n 1 | cut -d '"' -f 4) && \
    SONARR_URL=$(fetch -qo - "https://services.sonarr.tv/v1/releases" | \
        grep -o '"freeBsd":{"x64":{"archive":{"url":"[^"]*"' | \
        sed -n '1s/.*"url":"\([^"]*\)".*/\1/p') && \
    echo "Downloading Sonarr $SONARR_VERSION from: $SONARR_URL" && \
    fetch -qo - "$SONARR_URL" | \
        tar xzf - -C /usr/local/share/sonarr --strip-components=1 && \
    rm -rf /usr/local/share/sonarr/Sonarr.Update && \
    chmod +x /usr/local/share/sonarr/Sonarr && \
    chmod -R o+rX /usr/local/share/sonarr && \
    printf "UpdateMethod=docker\nBranch=main\nPackageVersion=%s\nPackageAuthor=[daemonless](https://github.com/daemonless/daemonless)\n" "$SONARR_VERSION" > /usr/local/share/sonarr/package_info && \
    mkdir -p /app && echo "$SONARR_VERSION" > /app/version

# Create config directory
RUN mkdir -p /config && \
    chown -R bsd:bsd /usr/local/share/sonarr /config

# Copy service definition and init scripts
COPY root/ /

# Make scripts executable
RUN chmod +x /etc/services.d/sonarr/run /etc/cont-init.d/* 2>/dev/null || true

EXPOSE 8989
VOLUME /config


