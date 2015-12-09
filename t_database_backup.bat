@echo off
perl eqemu_update.pl db_dump_compress
echo Database backup should be contained in backups folder...
explorer backups
pause