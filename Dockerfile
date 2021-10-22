FROM debian
LABEL maintainer="Pierre-Luc Paour <docker@paour.com>"

ADD https://github.com/just-containers/s6-overlay/releases/download/v2.2.0.1/s6-overlay-amd64-installer /tmp/
RUN chmod +x /tmp/s6-overlay-amd64-installer && /tmp/s6-overlay-amd64-installer /

ENV \
    # Fail if cont-init scripts exit with non-zero code.
    S6_BEHAVIOUR_IF_STAGE2_FAILS=2 \
    CRON="" \
    HEALTHCHECK_ID="" \
    HEALTHCHECK_HOST="https://hc-ping.com" \
    PUID="" \
    PGID=""

RUN apt-get update && apt-get install -y \
    curl \
    python

RUN curl -s -S -L https://git.io/gyb-install -o /gyb-install && chmod +x /gyb-install && /gyb-install -l && rm /gyb-install

COPY root/ /
