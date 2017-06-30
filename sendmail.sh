#!/bin/bash
cat | sendmail -t -i "$@" &
