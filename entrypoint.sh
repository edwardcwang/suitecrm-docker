#!/bin/sh
set -e

# Avoid PID files pre-existing warnings
rm -f /var/run/httpd.pid

exec apache2 -DFOREGROUND
