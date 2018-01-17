#!/usr/bin/env bash
./shared_memory
perl server_launcher.pl loginserver zones="30" silent_launcher &
echo "Server started - use server_status.sh to check server status"