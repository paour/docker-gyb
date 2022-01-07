#!/usr/bin/with-contenv sh

while getopts "e:h:i:c:" opt; do
  case "$opt" in
    e)  EMAIL=$OPTARG
      ;;
    h)  HEALTHCHECK_HOST=$OPTARG
      ;;
    i)  HEALTHCHECK_ID=$OPTARG
      ;;
    c)  CMD=$OPTARG
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      #exit 1
      ;;
    esac
done

echo "INFO: Starting sync.sh PID $$ $(date)"

if [ -n "$HEALTHCHECK_ID" ]; then
	curl -sS -X POST -o /dev/null "$HEALTHCHECK_HOST/$HEALTHCHECK_ID/start"
fi

set -e

/root/bin/gyb/gyb --fast-incremental --email $EMAIL --local-folder /backup/$EMAIL $CMD

echo "INFO: Completed sync.sh PID $$ $(date)"

if [ -n "$HEALTHCHECK_ID" ]; then
	curl -sS -X POST -o /dev/null --fail "$HEALTHCHECK_HOST/$HEALTHCHECK_ID"
fi
