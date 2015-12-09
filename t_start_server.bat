@echo off
cls
echo *** CLEARING OLD LOGS ***
del "logs/zone/" /q
shared_memory.exe
start world.exe
echo waiting for the world to finish before starting zone...
ping -n 10 127.0.0.1 > nul
start queryserv.exe
start ucs.exe
start eqlaunch.exe zone
exit
