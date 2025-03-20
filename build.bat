@echo off
SETLOCAL
TITLE PureBasic OpenAL SDK
PUSHD "%~dp0"

REM Try to locate the PureBasic 32-bit installation directory
SET PB32_HOME=%ProgramFiles(X86)%
IF "%ProgramFiles(X86)%" == "" SET PB32_HOME=%ProgramFiles%
SET PB32_HOME=%PB_HOME%\PureBasic
IF EXIST "%PB32_HOME%\SDK\LibraryMaker.exe" GOTO PB32FOUND
FOR /f "tokens=2*" %%i IN ('reg query "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\PureBasic (x86)_is1" /s 2^>nul ^| find "InstallLocation"') DO SET PB32_HOME=%%j
IF EXIST "%PB32_HOME%\SDK\LibraryMaker.exe" GOTO PB32FOUND
FOR /f "tokens=2*" %%i IN ('reg query "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\PureBasic_is1" /s 2^>nul ^| find "InstallLocation"') DO SET PB32_HOME=%%j
IF EXIST "%PB32_HOME%\SDK\LibraryMaker.exe" GOTO PB32FOUND
SET PB32_HOME=
:PB32FOUND
REM Try to locate the PureBasic 64-bit installation directory
SET PB64_HOME=%ProgramW6432%\PureBasic
IF EXIST "%PB64_HOME%\SDK\LibraryMaker.exe" GOTO PB64FOUND
FOR /f "tokens=2*" %%i IN ('reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\PureBasic (x64)_is1" /s 2^>nul ^| find "InstallLocation"') DO SET PB64_HOME=%%j
IF EXIST "%PB64_HOME%\SDK\LibraryMaker.exe" GOTO PB54FOUND
SET PB64_HOME=
:PB64FOUND
IF NOT "%PB32_HOME%%PB64_HOME%" == "" GOTO PBFOUND
ECHO -ERR: PureBasic not found. It is required to generate the User-Libs.
GOTO EXIT

:PBFOUND
REM Convert to short path format. Othewise the LibraryMaker will fail.
SET PB_HOME=%PB64_HOME%
IF "%PB_HOME%" == "" SET PB_HOME=%PB32_HOME%
for %%x in ("%PB_HOME%\") do set SH_PBHOME=%%~dpsx
IF EXIST %SH_PBHOME%\Compilers\fasm.exe GOTO FASMFOUND
ECHO -ERR: FASM not found in the PureBasic installation directory.
GOTO EXIT
:FASMFOUND
echo Compiling the OpenAL32 and OpenAL64 import libraries for PureBasic
echo.
%SH_PBHOME%\Compilers\fasm src\openal32.def src\Pbopenal.lib
IF %ERRORLEVEL% NEQ 0 GOTO EXIT
%SH_PBHOME%\Compilers\fasm src\openal64.def src\Pbopenal64.lib
IF %ERRORLEVEL% NEQ 0 GOTO EXIT

REM Run LibraryMaker to convert the import libraries to User-Lib format
IF EXIST %SH_PBHOME%\SDK\LibraryMaker.exe GOTO SDKFOUND
ECHO -ERR: PureBasic SDK not found.
GOTO EXIT
:SDKFOUND
echo.
echo Generating the User-Libs for PureBasic.
echo.
%SH_PBHOME%\SDK\LibraryMaker src\PBopenal.desc
IF %ERRORLEVEL% NEQ 0 GOTO EXIT
IF NOT "%PB32_HOME%" == "" move /Y PBopenal "%PB32_HOME%\PureLibraries\UserLibraries\"
%SH_PBHOME%\SDK\LibraryMaker src\PBopenal64.desc
IF %ERRORLEVEL% NEQ 0 GOTO EXIT
IF NOT "%PB64_HOME%" == "" move /Y PBopenal64 "%PB64_HOME%\PureLibraries\UserLibraries\"

echo.
echo Compiling the sample PureBasic applications

IF "%PB32_HOME%" == "" GOTO NO32PB
mkdir samples\bin\x86 2>nul
FOR %%i IN (EFXEnumerate EFXFilter Enumerate PlayStatic PlayStream) DO CALL :BLD "%PB32_HOME%" x86 %%i
GOTO PB64BUILD
:NO32PB
ECHO -WNG: The User-Lib PBopenal was created, but no 32-bit PureBasic compiler was found to build the sample projects in 32-bit mode.

:PB64BUILD
IF "%PB64_HOME%" == "" GOTO NO64PB
mkdir samples\bin\x64 2>nul
FOR %%i IN (EFXEnumerate EFXFilter Enumerate PlayStatic PlayStream) DO CALL :BLD "%PB64_HOME%" x64 %%i
GOTO EXIT
:NO64PB
ECHO -WNG: The User-Lib PBopenal64 was created, but no 64-bit PureBasic compiler was found to build the sample projects in 64-bit mode.

:EXIT
pause
POPD
ENDLOCAL
@echo on
GOTO :EOF

:BLD
echo.
"%~1\Compilers\pbcompilerc" /CONSOLE -z /EXE samples\bin\%2\%~n3.exe samples\%~n3\%~n3.pb
