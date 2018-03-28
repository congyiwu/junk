@{}# 2>nul & setlocal & PowerShell -NoProfile "& {Set-ExecutionPolicy Unrestricted -Force; Invoke-Command ([scriptblock]::Create((Get-Content '%~f0' | Select-Object -Skip 1) -join [Environment]::NewLine)) -ArgumentList $Args}" %* & goto :eof
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$WarningPreference = 'Continue'
# The magic header above allows us to embed a powershell script in a batch file

# Write failure message and exit immediately
function Write-Failure([string]$str) {
  $host.UI.WriteErrorLine('FAILURE: ' + $str)
  exit -1
}

####################
#SCRIPT BODY
if ($args.Length -eq 0) {
  Write-Host @'
USAGE: shadowize.cmd program [args...]
  program   Must be a .NET program.
  args      Passed through to program
'@

  exit -2
}

[System.Management.Automation.ApplicationInfo]$exe = (Get-Command -Name $args[0] -CommandType Application)[0]
[string]$exeName = $exe.Name
[string]$exePath = $exe.Path
[string[]]$passArgs = $args[1 .. ($args.Length - 1)]

[System.AppDomainSetup]$shadowDomainSetup = New-Object System.AppDomainSetup 
$shadowDomainSetup.ShadowCopyFiles = "true"
[System.AppDomain]$shadowDomain = [System.AppDomain]::CreateDomain($exeName);

[int]$exitCode = $shadowDomain.ExecuteAssembly($exePath, $passArgs);
exit $exitCode