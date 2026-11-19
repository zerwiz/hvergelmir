#!/usr/bin/env bash
# stop.sh — lower the API this release raised (by its port, loopback only).
set -euo pipefail
port="${DNA_PORT:-4850}"
pids="$(ss -ltnpH "sport = :$port" 2>/dev/null | grep -o 'pid=[0-9]*' | cut -d= -f2 | sort -u)"
[ -n "$pids" ] || { printf 'hvergelmir: nothing listens on :%s\n' "$port"; exit 0; }
kill $pids && printf 'hvergelmir: stopped (%s)\n' "$pids"
