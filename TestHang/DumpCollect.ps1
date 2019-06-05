[CmdletBinding()]
param (
    [Parameter(Position=0)]
    [ValidateNotNullOrEmpty()]
    [string[]] $ProcessName = @('vstest.executionengine*', 'testhost*'),

    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string] $Destination = (join-path $env:TEMP ([Guid]::NewGuid().ToString('n'))),

    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [timespan] $Timeout = '00:00:10',

    [Parameter()]
    [switch] $Wait
)

# Do not block the current process unless -Wait is passed.
if (!$Wait) {
    
    [string[]] $params = @('-File') + $MyInvocation.MyCommand.Path
    $params += '-Wait'

    Write-Host "Invoking with Wait..."
    Write-Host $params
    Start-Process -FilePath "${env:WINDIR}\System32\WindowsPowerShell\v1.0\powershell.exe" -ArgumentList $params
    return
}

Write-Host "Actual Process"
