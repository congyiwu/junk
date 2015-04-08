#Requires -Version 5.1 # Shipped w/ Windows 10 1607 and Windows Server 2016
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$WarningPreference = 'Continue'
trap { $host.UI.WriteErrorLine($_.ScriptStackTrace) }

function LogAndRun([string] $cmd) {
    Write-Host "RUNNING: $cmd"
    Invoke-Expression $cmd
}

# Exit if last exit code is non-zero
function CheckExitCode {
    if ($LastExitCode -ne 0) {
        throw "exit code was $LASTEXITCODE"
    }
}

LogAndRun 'cmd /c abcdefg'
CheckExitCode