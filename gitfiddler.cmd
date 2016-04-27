@echo off 

if [%1] equ [] (
  call :enable
  pause
  call :disable
  goto :eof
)

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
  @echo off 
goto :eof

:disable
  echo on
  git config --global --unset http.proxy
  git config --global --unset http.sslVerify
  @echo off 
goto :eof

:help
  echo USAGE: gitfiddler.cmd [1^|0]
  echo 1: sets proxy to localhost:8888 in git config
  echo 0: unsets proxy in git config
  echo no params: sets, pauses, then unsets
goto :eof
