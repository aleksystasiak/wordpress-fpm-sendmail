#!/bin/bash
service sendmail start &
exec docker-entrypoint.sh "$@"
