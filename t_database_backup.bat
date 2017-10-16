@echo off
perl eqemu_server.pl backup_database_compressed
echo Database backup should be contained in backups folder...
explorer backups
pause
