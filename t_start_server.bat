@echo off
cls
echo *** CLEARING OLD LOGS ***
del "logs/zone/" /q
shared_memory.exe
start perl win_server_launcher.pl zones="60" zone_background_start loginserver kill_all_on_start
exit
