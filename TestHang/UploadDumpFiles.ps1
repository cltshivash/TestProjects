$Destination = (join-path $env:Agent_TempDirectory "TestHangDumps")
Get-ChildItem $Destination -Filter *.dmp | 
Foreach-Object {
    $path=$_.FullName
    Write-Host "##vso[task.uploadfile]$($path)"
}