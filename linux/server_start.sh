#!/usr/bin/env bash

if test -f "bin/shared_memory"; then
   ./bin/shared_memory
fi

if test -f "./shared_memory"; then
   ./shared_memory
fi

perl server_launcher.pl zones="30" silent_launcher &
echo "Server started - use server_status.sh to check server status"
