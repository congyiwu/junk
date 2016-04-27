REM 1) myuninst.exe /stab myqueue.csv
REM 2) open myqueue.csv in Excel and sort by install date
REM 3) copy the MsiExec.exe /X{GUID} entries for packages you would like to remove to myqueue.txt, one per line
setlocal enabledelayedexpansion
for /f "eol=^ delims=" %%i in (%~dp0myqueue.txt) do (
REM OR /silent
start /wait %%i /passive /log log.txt IGNOREDEPENDENCIES=ALL
if %ERRORLEVEL% neq 0 goto :end
)
:end