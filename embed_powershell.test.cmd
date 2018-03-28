@REM Test cases for embed_powershell.cmd

@echo off
setlocal EnableDelayedExpansion

set EMBED=%~dp0\embed_powershell.cmd
set TEST0=%TEMP%\test0.cmd
set BASELINE=%~dp0\embed_powershell.test.bsl
set RESULT=%TEMP%\embed_powershell.test.new

type %EMBED% > %TEST0% || goto :eof
echo Write-Host '$args.Length = ' $args.Length >> %TEST0% || goto :eof
echo for ($i = 0; $i -lt $args.Length; $i++) { Write-Host "`$args[$i] = `"$($args[$i])`"" } >> %TEST0% || goto :eof
echo Write-Host DONE >> %TEST0% || goto :eof
echo Write-Host >> %TEST0% || goto :eof

type nul > %RESULT% || goto :eof

echo TEST: no params >> %RESULT% || goto :eof
call %TEST0% >> %RESULT% || goto :eof

echo TEST: 1 param >> %RESULT% || goto :eof
call %TEST0% apple >> %RESULT% || goto :eof

echo TEST: 2 params >> %RESULT% || goto :eof
call %TEST0% apple banana >> %RESULT% || goto :eof

echo TEST: 3 params >> %RESULT% || goto :eof
call %TEST0% apple BANANA cake >> %RESULT% || goto :eof

echo TEST: 1 params w/ spaces >> %RESULT% || goto :eof
call %TEST0% "apple pie" >> %RESULT% || goto :eof

echo TEST: 3 params w/ spaces >> %RESULT% || goto :eof
call %TEST0% "apple pie" "bananas" cake >> %RESULT% || goto :eof

echo TEST: 3 params w/ spaces/quotes >> %RESULT% || goto :eof
%TEST0% "apple pie" 'bananas' "bob's cake pops" >> %RESULT% || goto :eof

goto :eof

fail:
echo FAILED
goto eof