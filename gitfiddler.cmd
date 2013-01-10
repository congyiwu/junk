@echo off 

if [%1] equ [1] (
  call :enable
  goto :eof
)

if [%1] equ [0] (
  call :disable
  goto :eof
)

call :help
goto :eof

:enable
  echo on
  git config --global http.proxy localhost:8888
  git config --global http.sslVerify 0
  netsh winhttp set proxy localhost:8888
  @echo off 
goto :eof

:disable
  echo on
  git config --global --unset http.proxy
  git config --global --unset http.sslVerify
  netsh winhttp reset proxy
  @echo off 
goto :eof

:help
  echo USAGE: gitfiddler.cmd 1^|0
  echo 1: Set git config and winhttp to use proxy
  echo 0: disable proxy for git config and winhttp
goto :eof