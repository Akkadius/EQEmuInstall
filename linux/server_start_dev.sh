#!/usr/bin/env bash
./shared_memory
perl server_launcher.pl zones="30" &
echo "Server started - use server_status.sh to check server status"  