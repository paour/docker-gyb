Docker Mailbox Sync
===================

Forked from [https://github.com/JakeWharton/docker-mbsync](Jake Wharton's) great mbsync docker container.

A Docker container which runs the [`gyb`][1] tool automatically to synchronize your email.

 [1]: https://github.com/jay0lee/got-your-back

[![Docker Image Version](https://img.shields.io/docker/v/paour/gyb?sort=semver)][hub]
[![Docker Image Size](https://img.shields.io/docker/image-size/paour/gyb)][layers]

 [hub]: https://hub.docker.com/r/paour/gyb/
 [layers]: https://microbadger.com/images/paour/gyb


Setup
-----

Select and create two directories:

 * The "mail" directory where email will be stored. (From now on referred to as `/path/to/mail`)
 * The "config" directory where your configuration file will be stored. (From now on referred to as `/path/to/config`)


### Config

Use environment varibales to configure sync:

- `CRON`: a cron time expression like `0 * * * *`
- `EMAIL`: the email adress of the account to back up
- `CMD`: `gyb` command arguments, like `--fast_incremental`
- `HEALTHCHECK_ID` and `HEAKTHCHECK_HOST` (optional): to ping healthchecks.io

For multiple actions, provide `CRON_i`, `EMAIL_i`… where `i` is incremented for various values from 1 up to 20).

It's possible to provide a `oauth2service.json` file to use a service account (use the `--service-account` argument).

Initial sync requires using docker exec described below.

### Initial Sync

The first time this container runs, it will download all of your historical emails.

It is not required, but if you'd like to run this sync manually you can choose to do so.
This allows you to temporarily interrupt it at any point and also restart if it gets stuck.

```bash
$ docker run -it --rm
    -v /path/to/config:/config \
    -v /path/to/mail:/mail \
    paour/gyb \
    /app/sync.sh
```

This will run until all emails have been downloaded. At this point, you should set it up to run automatically on a schedule.


### Running Automatically

To run the sync automatically on a schedule, pass a valid cron specifier as the `CRON` environment variable.

```bash
$ docker run -it --rm
    -v /path/to/config:/config \
    -v /path/to/mail:/mail \
    -e "CRON=0 * * * *" \
    paour/gyb
```

The above version will run every hour and download any new emails. For help creating a valid cron specifier, visit [cron.help][2].

 [2]: https://cron.help/#0_*_*_*_*


### More

To be notified when sync is failing visit https://healthchecks.io, create a check, and specify the ID to the container using the `HEALTHCHECK_ID` environment variable.

Because the sync can occasionally fail, it's best to set a grace period on the check which is a multiple of your cron period. For example, if you run sync hourly give a grace period of two hours.

To write data as a particular user, the `PUID` and `PGID` environment variables can be set to your user ID and group ID, respectively.


### Docker Compose

```yaml
version: '2'
services:
  mbsync:
    image: paour/gyb:latest
    restart: unless-stopped
    volumes:
      - /path/to/config:/config
      - /path/to/mail:/mail
    environment:
      - "CRON=0 * * * *"
      #Optional:
      - "HEALTHCHECK_ID=..."
      - "PUID=..."
      - "PGID=..."
```

Note: You may want to specify an explicit version rather than `latest`.
See https://hub.docker.com/r/paour/gyb/tags.



LICENSE
======

MIT. See `LICENSE.txt`.

    Copyright 2022 Pierre-Luc Paour
