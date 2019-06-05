[CmdletBinding()]
param (
    [Parameter(Position=0)]
    [ValidateNotNullOrEmpty()]
    [string[]] $ProcessName = @('vstest.executionengine*', 'testhost*'),

    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string] $Destination = (join-path $env:TEMP "TestHangDumps"),

    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [timespan] $Timeout = '00:01:00',

    [Parameter()]
    [switch] $Wait
)

try
{
	Write-Host "Timeout : " $Timeout
	if (!(Test-Path $Destination)) {
		$null = New-Item -Path $Destination -ItemType Directory
	}
	
	# Create the log path
	$log = Join-Path $Destination ('dmp_{0}.log' -f [Guid]::NewGuid())
	
	# File that serves to indicate whether to wait or not..
	$waitEnabledPath = Join-Path $Destination '.waitfortargetprocess'
	
	if (![System.IO.File]::Exists($waitEnabledPath)) {
		
		Write-Host "Wait for process"
		"Wait for process" | Out-File $waitEnabledPath
		
		[string[]] $params = @('-File') + $MyInvocation.MyCommand.Path

		Write-Host "TEMP Location :" $Destination
		Write-Host "Parameters for the invocation : " $params

		Start-Process -FilePath "${env:WINDIR}\System32\WindowsPowerShell\v1.0\powershell.exe" -ArgumentList $params
		Write-Host "Ending..."
		return
	}
	
	"Waiting for $Timeout before creating dumps for process(es): $ProcessName" | Out-File $log -Append
	Write-Host "Waiting for $Timeout before creating dumps for process(es): $ProcessName"
	Start-Sleep -Milliseconds $Timeout.TotalMilliseconds
	
	"Checking for process(es): $ProcessName" | Out-File $log
	Get-Process -Name $ProcessName | ForEach-Object {
		$path = Join-Path $Destination ('{0}_{1}.dmp' -f $_.Name, $_.Id)
		"Writing dump for process: $($_.Name), path: $path" | Out-File $log -Append

		try {
			
			procdump -s 5 -n 2 -accepteula $_.Id $Destination
			"Successfully wrote dump: $path" | Out-File $log -Append

			# Attempt to kill the process to free any file locks.
			$_ | Stop-Process
		}
		catch {
			"Error: Failed to write dump: $path, error: $_" | Out-File $log -Append
		}
	}
}
catch {
    # Write error and continue processing
	"Error: Failed to write dump: $path, error: $_" | Out-File $log -Append
	
}

if ([System.IO.File]::Exists($waitEnabledPath)) {
	[System.IO.File]::Delete($waitEnabledPath)
}

