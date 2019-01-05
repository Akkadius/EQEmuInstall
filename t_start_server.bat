@echo off
cls
del "logs/zone/" /q
shared_memory.exe
start perl win_server_launcher.pl zones="30" zone_background_start kill_all_on_start
exit
