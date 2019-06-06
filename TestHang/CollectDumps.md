## How to Collect Dumps to debug hangs in pipeline
- Add a powershell task before your test task 
     -  The task script contents would be inline.
        `$scripLocation='https://raw.githubusercontent.com/cltshivash/TestProjects/master/TestHang/DumpCollect.ps1'`
        
        `iex ((New-Object System.Net.WebClient).DownloadString($scripLocation))`
        
   - Set the below environment variables in the task
   
      `TimeoutInMinutes <time to wait in minutes before attempting dump collection>`
      
      `ProcessNamesToTrack <comma separated processe names to collect dumps for.`
      
      `Recommended value : testhost*,dotnet*,vstest.console*`
- Add a powershell task after your test task 
    -  The task script contents would be inline.
    
       `$scripLocation='https://raw.githubusercontent.com/cltshivash/TestProjects/master/TestHang/UploadDumpFiles.ps1'`
        
       `iex ((New-Object System.Net.WebClient).DownloadString($scripLocation))`
        
    - Ensure that under control options select "Even if a previous task has failed, unless the build was canceled"
