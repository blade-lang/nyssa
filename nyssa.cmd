@ECHO OFF
SETLOCAL
SET "NYSSA_DIR=%~dp0"

@REM Find Blade executable
for %%i in (blade.exe) do SET "BLADE_EXE=%%~$PATH:i"

if defined BLADE_EXE (
    GOTO :RUN
) else (
    GOTO :ERROR
)

:ERROR
SET msgboxTitle=Nyssa
SET msgboxBody=Blade is not installed or not in path.
SET tmpmsgbox=%temp%\~tmpmsgbox.vbs
IF EXIST "%tmpmsgbox%" DEL /F /Q "%tmpmsgbox%"
ECHO msgbox "%msgboxBody%",0,"%msgboxTitle%">"%tmpmsgbox%"
WSCRIPT "%tmpmsgbox%"
EXIT /B 1

:RUN
cd /D %USERPROFILE%

:: Remove the executable name and script path from the commands 
:: passed to the running script.

%BLADE_EXE% %NYSSA_DIR% %*
EXIT /B 0
