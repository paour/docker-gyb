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

In `/path/to/config`, create a file `mbsync.rc` for configuration.
See the [`mbsync`][1] documentation for the syntax of this file.

The examples in this README mount the destination `/path/to/mail` directory as `/mail` inside of the container.
If you are going to follow that, you should use `/mail` as the path in your configuration.

Here is an example, minimal configuration for synchronizing everything in a mailbox:
```
IMAPAccount example
Host imap.example.com
User me@example.com
Pass abc123
AuthMechs LOGIN
SSLType IMAPS
PipelineDepth 50

IMAPStore example-remote
Account example

MaildirStore example-local
Path /mail/
Inbox /mail/Inbox
SubFolders Verbatim

Channel example
Master :example-remote:
Slave :example-local:
Patterns *
Create Slave
Expunge Slave
SyncState *
Sync Pull
```


### Initial Sync

The first time this container runs, it will download all of your historical emails.

It is not required, but if you'd like to run this sync manually you can choose to do so.
This allows you to temporarily interrupt it at any point and also restart if it gets stuck.

```bash
$ docker run -it --rm
    -v /path/to/config:/config \
    -v /path/to/mail:/mail \
    jakewharton/mbsync \
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
    jakewharton/mbsync
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
    image: jakewharton/mbsync:latest
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
See https://hub.docker.com/r/jakewharton/mbsync/tags.



LICENSE
======

MIT. See `LICENSE.txt`.

    Copyright 2020 Jake Wharton
