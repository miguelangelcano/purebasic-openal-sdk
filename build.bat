@echo off
SETLOCAL
TITLE PureBasic OpenAL SDK
PUSHD "%~dp0"

REM Try to locate the PureBasic (32-bit) installation directory
SET PB64=0
SET PB_HOME=%ProgramFiles(X86)%
IF "%ProgramFiles(X86)%" == "" SET PB_HOME=%ProgramFiles%
SET PB_HOME=%PB_HOME%\PureBasic
IF EXIST "%PB_HOME%\SDK\LibraryMaker.exe" GOTO PBFOUND
FOR /f "tokens=2*" %%i IN ('reg query "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\PureBasic (x86)_is1" /s 2^>nul ^| find "InstallLocation"') DO SET PB_HOME=%%j
IF EXIST "%PB_HOME%\SDK\LibraryMaker.exe" GOTO PBFOUND
FOR /f "tokens=2*" %%i IN ('reg query "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\PureBasic_is1" /s 2^>nul ^| find "InstallLocation"') DO SET PB_HOME=%%j
IF EXIST "%PB_HOME%\SDK\LibraryMaker.exe" GOTO PBFOUND

REM Check if 64-bit version is available
SET PB64=1
SET PB_HOME=%ProgramW6432%\PureBasic
IF EXIST "%PB_HOME%\SDK\LibraryMaker.exe" GOTO PBFOUND
FOR /f "tokens=2*" %%i IN ('reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\PureBasic (x64)_is1" /s 2^>nul ^| find "InstallLocation"') DO SET PB_HOME=%%j
IF EXIST "%PB_HOME%\SDK\LibraryMaker.exe" GOTO PBFOUND

ECHO -ERR: PureBasic not found. It is required to generate the User-Lib.
GOTO EXIT

:PBFOUND
REM Convert to short path format. Othewise the LibraryMaker will fail.
for %%x in ("%PB_HOME%\") do set SH_PBHOME=%%~dpsx

IF EXIST "%SH_PBHOME%\Compilers\fasm.exe" GOTO FASMFOUND
ECHO FASM not found in the PureBasic installation directory.
GOTO EXIT
:FASMFOUND
echo Compiling the OpenAL32 import library for PureBasic
echo.
"%SH_PBHOME%\Compilers\fasm" src\openal32.def src\Pbopenal.lib
IF %ERRORLEVEL% NEQ 0 GOTO EXIT

REM Run LibraryMaker to convert the import library to User-Lib format
IF EXIST "%SH_PBHOME%\SDK\LibraryMaker.exe" GOTO PBFOUND
ECHO -ERR: PureBasic SDK not found.
GOTO EXIT
:PBFOUND
echo.
IF %PB64% == 0 GOTO BUILD_32

echo Creating the User-Lib: PBopenal
%SH_PBHOME%\SDK\LibraryMaker src\PBopenal.desc
IF %ERRORLEVEL% NEQ 0 GOTO EXIT
ECHO -WNG: The User-Lib was created, but the sample projects require a 32-bit PureBasic compiler to create the executables.
GOTO EXIT

:BUILD_32
echo Creating the User-Lib: %PB_HOME%\PureLibraries\UserLibraries\PBopenal
%SH_PBHOME%\SDK\LibraryMaker src\PBopenal.desc /TO %SH_PBHOME%\PureLibraries\UserLibraries\
IF %ERRORLEVEL% NEQ 0 GOTO EXIT

echo.
echo Compiling the sample PureBasic applications:

mkdir samples\bin 2>nul
FOR %%i IN (EFXEnumerate EFXFilter Enumerate PlayStatic PlayStream) DO CALL :BLD "%%i"
pause
POPD
ENDLOCAL
@echo on
GOTO :EOF

:BLD
echo.
%SH_PBHOME%\Compilers\pbcompilerc /CONSOLE -z /EXE samples\bin\%~n1.exe samples\%~n1\%~n1.pb
