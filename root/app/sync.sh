#!/usr/bin/with-contenv sh

echo "INFO: Starting sync.sh PID $$ $(date)"

if [ -n "$HEALTHCHECK_ID" ]; then
	curl -sS -X POST -o /dev/null "$HEALTHCHECK_HOST/$HEALTHCHECK_ID/start"
fi

set -e

/root/bin/gyb/gyb --fast-incremental --email $EMAIL --local-folder /backup $CMD

echo "INFO: Completed sync.sh PID $$ $(date)"

if [ -n "$HEALTHCHECK_ID" ]; then
	curl -sS -X POST -o /dev/null --fail "$HEALTHCHECK_HOST/$HEALTHCHECK_ID"
fi
