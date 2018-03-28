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
        Write-Failure "exit code was $LastExitCode" $LastExitCode
    }
}


$tgt = Join-Path $PSScriptRoot 'Autohotkey.ahk'
$link = Join-Path ([System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::MyDocuments)) 'Autohotkey.ahk'
LogAndRun "cmd /c mklink '$link' '$tgt'"