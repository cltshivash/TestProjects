try
{
    $Destination = (join-path $env:Agent_TempDirectory "TestHangDumps")
    if (!(Test-Path $Destination)) {
        $null = New-Item -Path $Destination -ItemType Directory
    }
    
    # Create the log path
    $log = Join-Path $Destination ('dmp_{0}.log' -f [Guid]::NewGuid())
    
    # Parsing the inputs ahead for loggging purpose..
    $TimeoutInMinutes=[int]$env:TimeoutInMinutes
    if ($TimeoutInMinutes -le 0)
    {
        Write-Host "*********** Defaulting timeout to 30 minutes *********************"
        $TimeoutInMinutes=30
    }
    
	Write-Host "Timeout (Minutes) : " $TimeoutInMinutes
    
    $processNamesString=$env:ProcessNamesToTrack;
    if ([string]::IsNullOrEmpty($processNamesString)) {
        Write-Host "*********** Defaulting the processes to track *********************"
        $processNamesString="testhost*,vstest.console*,dotnet*"
    }
    
    Write-Host "ProcessNamesToTrack : " $processNamesString
    $ProcessNames = $processNamesString.split(",")
    
    # File that serves to indicate whether to wait or not..
    $waitEnabledPath = Join-Path $Destination '.waitfortargetprocess'
    $procdumpPath = Join-Path $Destination 'procdump.exe'
    if (![System.IO.File]::Exists($waitEnabledPath)) {
        
        # Download procdump
		Invoke-WebRequest -Uri "https://raw.githubusercontent.com/cltshivash/TestProjects/master/TestHang/procdump.exe" -OutFile $procdumpPath

        # Setup the next pass to capture dumps...
        "Enabling the wait for timeout to expire" | Out-File $waitEnabledPath
        
        # Create the params to be passed..
        [string[]] $params = @('-File') + $MyInvocation.MyCommand.Path

        Write-Host "TEMP Location :" $Destination
        Write-Host "Parameters for the invocation : " $params

        Start-Process -FilePath "${env:WINDIR}\System32\WindowsPowerShell\v1.0\powershell.exe" -ArgumentList $params
        Write-Host "Ending..."
        return
    }
    
    "Waiting for $TimeoutInMinutes minutes before creating dumps for process(es): $ProcessNames" | Out-File $log -Append
    Write-Host "Waiting for $TimeoutInMinutes minutes before creating dumps for process(es): $ProcessNames"
    Start-Sleep -Seconds ($TimeoutInMinutes*60)
    
    "Checking for process(es): $ProcessNames" | Out-File $log
    $processesToTerminate = @()
    Get-Process -Name $ProcessNames | ForEach-Object {
        try {
            # Create the params to be passed..
			[string[]] $procDumpParams = @('-s', '15', '-n', '2', '-accepteula') + $_.Id + $Destination
			Write-Host "Procdumppath : " $procdumpPath
			Write-Host "Parameters for the invocation : " $procDumpParams

			$process = Start-Process -FilePath $procdumpPath -ArgumentList $procDumpParams -Wait 
			Write-Host "Process Exit code" $process.ExitCode
			
			"Successfully wrote dump" | Out-File $log -Append

            # Add the process to be terminated later..
            $processesToTerminate+=$_.Id
        }
        catch {
            "Error: Failed to write dump: error: $_" | Out-File $log -Append
			Write-Host "Error: Failed to write dump: error: $_"
        }
    }
    
    foreach ($processId in $processesToTerminate) {
        try {
            # Attempt to kill the process to free any file locks.
            # $_ | Stop-Process
            Stop-Process -Id $processId
        }
        catch {
            "Error: Failed to terminate process : $processId" | Out-File $log -Append
			Write-Host "Error: Failed to terminate process : $processId"
        }
    }
}
catch {
    # Write error and continue processing
    "Error: $_" | Out-File $log -Append
    Write-Host "Error: $_"
}

#Cleanup the tracking file at the end...
if ([System.IO.File]::Exists($waitEnabledPath)) {
    [System.IO.File]::Delete($waitEnabledPath)
}