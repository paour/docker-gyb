FROM debian:stable-slim
LABEL maintainer="Pierre-Luc Paour <docker@paour.com>"

ADD https://github.com/just-containers/s6-overlay/releases/download/v2.2.0.1/s6-overlay-amd64-installer /tmp/
RUN chmod +x /tmp/s6-overlay-amd64-installer && \
    /tmp/s6-overlay-amd64-installer /

# Install socklog-overlay
ADD https://github.com/just-containers/socklog-overlay/releases/download/v3.1.2-0/socklog-overlay-amd64.tar.gz /tmp/
RUN tar xzf /tmp/socklog-overlay-amd64.tar.gz -C / && \
    echo -e "+\n1" > /etc/socklog.rules/forward-stdout

ENV \
    # Fail if cont-init scripts exit with non-zero code.
    S6_BEHAVIOUR_IF_STAGE2_FAILS=2 \
    CRON="" \
    HEALTHCHECK_ID="" \
    HEALTHCHECK_HOST="https://hc-ping.com" \
    PUID="" \
    PGID="" \
    EMAIL="" \
    CMD=""

RUN apt-get update && \
    apt-get install -y \
			curl \
			python \
			cron \
    && \
    rm -rf /var/lib/apt/lists/*

COPY root/ /

VOLUME ["/config", "/backup"]

ADD https://git.io/gyb-install /tmp/
RUN chmod +x /tmp/gyb-install && \
    /tmp/gyb-install -l && \
    rm -rf /tmp/*

ENTRYPOINT ["/init"]
