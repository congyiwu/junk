@{}# 2>nul & setlocal & set EMBED_ARGS=%* & PowerShell -NoProfile "& {Invoke-Command ([scriptblock]::Create((Get-Content '%~f0' | Select-Object -Skip 1) -join [Environment]::NewLine)) -ArgumentList $(if ($env:EMBED_ARGS) { [string[]]([System.Management.Automation.PSParser]::Tokenize($env:EMBED_ARGS,[ref]$null) |%% { $_.Content }) } else { @() }) }" & goto :eof
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$WarningPreference = 'Continue'
# The magic header above allows us to embed a powershell script in a batch file
echo $env:EMBED_ARGS
