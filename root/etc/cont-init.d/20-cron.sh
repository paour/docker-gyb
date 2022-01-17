#!/usr/bin/with-contenv bash

if [ -z "$CRON" ]; then
	echo "
Not running in cron mode
"
	exit 0
fi

if [ -z "$EMAIL" ]; then
	echo "
ERROR: Define EMAIL address
"
	exit 0
fi

if [ ! -d /config ]; then
	echo "
ERROR: '/config' directory must be mounted
"
	exit 1
fi

if [ -z "$HEALTHCHECK_ID" ]; then
	echo "
NOTE: Define HEALTHCHECK_ID with https://healthchecks.io to monitor sync job"
fi

# Set up the cron schedule.
echo -e "\nInitializing cron\n\n$CRON $EMAIL\n"
# crontab -u abc -d # Delete any existing crontab.
echo "$CRON /usr/bin/flock -n /app/sync.lock /app/sync.sh > /proc/1/fd/1 2>/proc/1/fd/2" > /tmp/crontab.tmp

for ((i = 1; i <= 20; i++)); do
	EMAILI="EMAIL_$i"
	CRONI="CRON_$i"
	CMDI="CMD_$i"
	HII="HEALTHCHECK_ID_$i"
	HHI="HEALTHCHECK_HOST_$i"
	if [ -n "${!EMAILI}" ]; then
		echo -e "\nInitializing cron\n\n{!CRONI} {!EMAILI}\n"
		echo "${!CRONI:-$CRON} /usr/bin/flock -n /app/sync.lock /app/sync.sh -e ${!EMAILI:-$EMAIL} -c \"${!CMDI:-$CMD}\" -i ${!HII:-$HEALTHCHECK_ID} -h ${!HHI:-$HEALTHCHECK_HOST} > /proc/1/fd/1 2>/proc/1/fd/2" >> /tmp/crontab.tmp
	else
		break
	fi
done

crontab -u abc /tmp/crontab.tmp
rm /tmp/crontab.tmp

service cron start
