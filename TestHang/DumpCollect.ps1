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
	if (!(Test-Path $Destination)) {
		$null = New-Item -Path $Destination -ItemType Directory
	}
	$log = Join-Path $Destination ('dmp_{0}.log' -f [Guid]::NewGuid())
	
	# Do not block the current process unless -Wait is passed.
	if (!$Wait) {
		
		[string[]] $params = @('-File') + $MyInvocation.MyCommand.Path
		$params += '-Wait'

		Write-Host "Invoking with Wait..."
		"Invoking with Wait..." | Out-File $log
		Write-Host "TEMP Location :" $Destination
		"TEMP Location :" $Destination  | Out-File $log
		Write-Host $params
		$params | Out-File $log
		Start-Process -FilePath "${env:WINDIR}\System32\WindowsPowerShell\v1.0\powershell.exe" -ArgumentList $params
		Start-Sleep -Milliseconds 10000
		Write-Host "Ending..."
		return
	}
	
	"Waiting for $Timeout before creating dumps for process(es): $ProcessName" | Out-File $log
	Start-Sleep -Milliseconds $Timeout.TotalMilliseconds

	$log = Join-Path $Destination ('dmp_{0}.log' -f [Guid]::NewGuid())
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

"Error: Failed to write dump: $path, error: $_" | Out-File $log -Append

