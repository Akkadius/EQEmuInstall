#!/usr/bin/env bash

if test -f "bin/shared_memory"; then
   ./bin/shared_memory
fi

if test -f "./shared_memory"; then
   ./shared_memory
fi

perl server_launcher.pl zones="10" no_status_update &
echo "Server started - use server_status.sh to check server status"
