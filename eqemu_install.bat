@echo off
if not "%1" == "max" start /MAX cmd /c %0 max & exit/b

goto check_Permissions

:check_Permissions
    echo Administrative permissions required. Detecting permissions...	
    net session >nul 2>&1
    if %errorLevel% == 0 (
        echo Success: Administrative permissions confirmed.
		
		GOTO :PRE_MAIN
    ) else (
        echo Failed: Run eqemu_install.bat as Administrator Right click - Run as Administrator
		pause
		exit
    )

pause

:PRE_MAIN

echo #########################################################
echo #::: EverQuest Emulator Modular Installer
echo #::: Installer Author: Akkadius
echo #:::
echo #::: EQEmulator Server Software is developed and maintained 
echo #:::	by the EQEmulator Developement team
echo #:::
echo #::: Everquest is a registered trademark
echo #::: Daybreak Game Company LLC.
echo #::: 
echo #::: EQEmulator is not associated or 
echo #::: affiliated in any way with Daybreak Game Company LLC.
echo #########################################################
echo :
echo #########################################################
echo #::: To be installed:
echo #########################################################
echo - Server running folder - Will be installed to the folder you ran this script
echo - MariaDB (MySQL) - Database engine
echo - Heidi SQL (Comes with MariaDB)
echo - Perl 5.12.3 :: Scripting language for quest engines
echo - LUA Configured :: Scripting language for quest engines
echo - Latest PEQ Database
echo - Latest PEQ Quests
echo - Latest Plugins repository
echo - Automatically added Firewall rules
echo - Maps (Latest V2) formats are loaded
echo - New Path files are loaded
echo - Optimized server binaries
echo #########################################################

:MAIN

cd "%~dp0" 
%~d0%

SET has_winrar=0

IF EXIST "%ProgramFiles(x86)%\WinRAR" (
	SET has_winrar=1
	REM echo WinRAR Exists... 32-Bit
)
IF EXIST "%ProgramFiles%\WinRAR" (
	SET has_winrar=1
	REM echo WinRAR Exists... 64-Bit
)
IF %has_winrar% == 0 (
	echo Installing WinRAR...
	WinRARSetup.exe /S
	del WinRARSetup.exe
)

IF NOT EXIST "C:\Perl\bin" (
	GOTO :INSTALL_PERL
)


IF NOT EXIST "C:\Program Files\MariaDB 10.0" (
	GOTO :INSTALL_MARIADB
)

:GET_EQEMU_UPDATE
IF NOT EXIST "eqemu_update.pl" (
	C:\Perl\bin\perl.exe -MLWP::UserAgent -e "require LWP::UserAgent;  my $ua = LWP::UserAgent->new; $ua->timeout(10); $ua->env_proxy; my $response = $ua->get('https://raw.githubusercontent.com/EQEmu/Server/master/utils/scripts/eqemu_update.pl'); if ($response->is_success){ open(FILE, '> eqemu_update.pl'); print FILE $response->decoded_content; close(FILE); }
)
IF NOT EXIST "eqemu_update.pl" GOTO GET_EQEMU_UPDATE

:GET_EQEMU_CONFIG
IF NOT EXIST "eqemu_config.xml" (
	C:\Perl\bin\perl.exe -MLWP::UserAgent -e "require LWP::UserAgent;  my $ua = LWP::UserAgent->new; $ua->timeout(10); $ua->env_proxy; my $response = $ua->get('https://raw.githubusercontent.com/Akkadius/EQEmuInstall/master/eqemu_config.xml'); if ($response->is_success){ open(FILE, '> eqemu_config.xml'); print FILE $response->decoded_content; close(FILE); }
)
IF NOT EXIST "eqemu_config.xml" GOTO GET_EQEMU_UPDATE

IF EXIST "vcredist_x86.exe" (
	vcredist_x86.exe /passive /norestart
	del vcredist_x86.exe
)

C:\Perl\bin\perl.exe eqemu_update.pl installer

pause

GOTO :EXIT

:INSTALL_PERL
	echo Installing Perl... LOADING... PLEASE WAIT...
	start /wait msiexec /i ActivePerl-5.12.3.1204-MSWin32-x86-294330.msi PERL_PATH="Yes" /q
	"C:\Program Files (x86)\WinRAR\unrar" x -o- Perl.rar C:\
	del ActivePerl-5.12.3.1204-MSWin32-x86-294330.msi
	del Perl.rar
	SET PATH=%path%;C:\Perl\site\bin
	SET PATH=%path%;C:\Perl\bin
	
	assoc .pl=Perl
	ftype Perl="C:\Perl\bin\perl.exe" %%1 %%* 
	
	GOTO :MAIN
	
:INSTALL_MARIADB
	echo Installing MariaDB (Root Password: eqemu) LOADING... PLEASE WAIT...
	start /wait msiexec /i mariadb-10.0.21-winx64.msi SERVICENAME=MySQL PORT=3306 PASSWORD=eqemu /qn
	setx /M path "%path%;C:\Program Files\MariaDB 10.0\bin"
	SET PATH=%path%;C:\Program Files\MariaDB 10.0\bin
	del mariadb-10.0.21-winx64.msi
	
	GOTO :MAIN
	
:EXIT
	exit
