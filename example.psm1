<#
.SYNOPSIS
    List modules internal haves and external wants for a set of workstreams
.DESCRIPTION
    For a set of workstreams:
    * Dumps list of all design modules into have.txt in working dir
    * Dumps list of all modules required by design modules, but not in have.txt, into want.txt
.PARAMETER Root
    Path to folder to generate repos underneath (defaults to $PWD)
.PARAMETER Clone
    Clone fresh copies of each repo into new/empty dir
.EXAMPLE
    .\ListExternalModules.ps1 C:\temp\repos
    .\ListExternalModules.ps1 C:\temp\repos -Clone
#>

param (
    [Parameter(Mandatory=1)] [string]$Root,
    [Switch] [bool]$Clone
)

#Requires -Version 3
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


# keep in sync w/ graph on http://vscswiki/index.php?title=Skyrise
$repos = @(
'Search.Service', 'ServiceInsights', 'TestAgent', 'VSIntegration', 'CodeLens', 'Ibiza',
'Tfs',
'ServiceHooks.Service', 'ProjectDiscovery', 'CodeInsights.Service',
'ServiceHooks.Client', 'AccountAdmin', 'CodeInsights.Client', 'Packaging', 'Search.Client', 'VssfSdkSample',
'Vssf',
'TestFramework',
'DeploymentTools',
'Toolsets'
)

# a few people decided to stick hand generated lineups in their stores, instead of using the Externals.ALM.Filtered lineup.
# detect these as haves, for now.
$hackyHavesLineups = @(
    # Ibiza repo
    [pscustomobject]@{
        Store = '\\ddfiles\airstream\tfs\store\MSEng\_CloudStores\VSOnline_Ibiza';
        Lineups = @('External.AzurePortalSdk');
    },

    # Packaging repo
    [pscustomobject]@{
        Store = '\\ddfiles\airstream\tfs\store\MSEng\_CloudStores\VSOnline';
        Lineups = @('NuGet');
    },

    # Tfs repo
    [pscustomobject]@{
        Store = '\\ddfiles\airstream\tfs\store\MSEng\DistributedTask';
        Lineups = @('DistributedTask.Latest');
    }
)


if (!(Test-Path $Root))
{
    if ($Clone)
    {
        $null = mkdir $Root
    }
    else
    {
        Write-Failure '-Root path does not exist and -Clone was not provided.'
    }
}

$Root = Resolve-Path $Root # resolve relative paths and wildcards

if ($Root -is [array])
{
    Write-Failure '-Root path is not allowed to resolve to multiple paths (e.g. with a wildcard)'
}

if ($Clone)
{
    if (Test-Path (Join-Path $Root '*'))
    {
        Write-Failure '-Clone argument is not allowed for nonempty -Root paths'
    }

    foreach ($repo in $repos)
    {
        LogAndRun "git clone 'https://mseng.visualstudio.com/DefaultCollection/VSOnline/_git/$repo' '$(Join-Path $Root $repo)'"
        CheckExitCode
    }
}


# find DeploymentItem.xml and get DeploymentModules from it
$deploymentToolsRepo = Join-Path $Root 'DeploymentTools'

$deploymentToolsWorkstreamXml = [xml](Get-Content -LiteralPath (Join-Path $deploymentToolsRepo 'DeploymentTools.workstream'))
$tffcRelPath = ($deploymentToolsWorkstreamXml.SharedWorkstreamData.DesignModuleDescriptor | Where-Object { $_.ModuleId -eq 'TfsFileCopy' }).ModuleLocation
$tffcDir = Split-Path (Join-Path $deploymentToolsRepo $tffcRelPath) -Parent

$deploymentManifestXml = [xml](Get-Content -LiteralPath (Join-Path $tffcDir 'DeploymentManifest.xml'))

$magicComponentModules = $deploymentManifestXml.GetElementsByTagName('DeploymentModule') |% { $_.Id } | Select-Object -Unique


# walk through all module requrements in each repo
$workstreamPaths = Resolve-Path (Join-Path $Root *\*.workstream)

$designModules = New-Object System.Collections.Generic.SortedSet[string]
$requirements = New-Object System.Collections.Generic.SortedSet[string]

foreach ($wp in $workstreamPaths) {
    Write-Host $wp
    $workstreamXml = [xml](Get-Content -LiteralPath $wp)

    $workstreamXmlDesignMod = $workstreamXml.SharedWorkstreamData.DesignModuleDescriptor
    $workstreamXmlDesignMod.ModuleId |% { $null = $designModules.Add($_) }

    $workstreamDir = Split-Path $wp

    #TODO: XPath is is case-sensitive.  consider making this case insensitive instead

    foreach ($dm in $workstreamXmlDesignMod) {
        $designModAbsPath = Join-Path $workstreamDir $dm.ModuleLocation
        $designModXml = [xml](Get-Content -LiteralPath $designModAbsPath)
        $nsMgr = New-Object System.Xml.XmlNamespaceManager $designModXml.NameTable
        $nsMgr.AddNamespace('a', 'http://schemas.microsoft.com/developer/modules/2012')
        $newReqsInDesignMod = $designModXml.SelectNodes('//a:Facet[@Domain="build" or @Domain="runtime" or @Domain="packaging"]/a:Requirement/@Id', $nsMgr)
        $newReqsInDesignMod |% { $null = $requirements.Add($_.Value) }


        if ($dm.ModuleId -in $magicComponentModules) {
            $componentXmlPaths = Resolve-Path (Join-Path $designModAbsPath '..\components\*.xml')
            foreach ($cmpXmlPath in $componentXmlPaths) {
                $cmpXml = [xml](Get-Content -LiteralPath $cmpXmlPath)
                $newReqsInCmpXml = $cmpXml.SelectNodes('//File/@ModuleSource')
                $newReqsInCmpXml |% {
                    if ($_.Value -match '^artifact://([^/]+)/.*$') {
                        $null = $requirements.Add($Matches[1])
                    }
                }
            }
        }
    }
}


# add haves from hacky non-official external lineups
foreach ($hhl in $hackyHavesLineups)
{
    foreach ($lineup in $hhl.Lineups)
    {
        $haves += LogAndRun "airstream lineup/list /store:'$($hhl.Store)' /id:'$lineup'" |
            Select-Object -Skip 1 |% {
                if ($_ -match '^([^@]+)@.+$')
                {
                    $null = $designModules.Add($Matches[1])
                }
                else
                {
                    Write-Failure "store: $($hhl.Store), lineup: $lineup, had malformed module id: $_"
                }
            }
        CheckExitCode
    }
}


Export-ModuleMember -Function Copy-SnappedRepos, New-SnappedRepoSpec