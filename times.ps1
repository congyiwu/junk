# Show elapsed time for last N commands
function times
{
    $count = if ($args[0]) { $args[0] } else { 5 }

    Get-History -Count $count |
    % { $_ | Add-Member -PassThru Elapsed ($_.EndExecutionTime - $_.StartExecutionTime).ToString('c') } |
    Format-Table Elapsed, CommandLine
}
