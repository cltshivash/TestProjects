$Destination = (join-path $env:TEMP "TestHangDumps")
Get-ChildItem $Destination -Filter *.dmp | 
Foreach-Object {
    $path=$_.FullName
    Write-Host "##vso[task.uploadfile]$($path)"
}