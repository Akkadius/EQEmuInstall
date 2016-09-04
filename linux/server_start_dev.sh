#!/usr/bin/env bash
./shared_memory
perl server_launcher.pl zones="10" no_status_update & 
echo "Server started - use server_status.sh to check server status"  
