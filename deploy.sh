#!/usr/bin/env bash
# deploy.sh — usage: ./deploy.sh mac-01 mac-02 ...
for h in "$@"; do
  ( scp -q secrets.env setup.sh bekkadmin@$h.local:~/ &&
    ssh bekkadmin@$h.local 'set -a; . ~/secrets.env; set +a; bash ~/setup.sh' \
      > logs/$h.log 2>&1 &&
    echo "$h ok" || echo "$h FAILED — see logs/$h.log" ) &
done; wait
