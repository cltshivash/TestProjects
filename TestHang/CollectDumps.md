## Collect Dumps (mini) to debug hangs in pipeline
- Step 1: Dump Collection Monitor Start
     - Add a powershell task before your test task (to start monitoring for dump collection)
     -  The task script contents would be inline.
        `$scripLocation='https://raw.githubusercontent.com/cltshivash/TestProjects/master/TestHang/DumpCollect.ps1'`
        
        `iex ((New-Object System.Net.WebClient).DownloadString($scripLocation))`
       
   - Set the below environment variables in the task
   
      `TimeoutInMinutes <time to wait in minutes before attempting dump collection>`
      
      `ProcessNamesToTrack <comma separated processe names to collect dumps for.`
      
      `Recommended value : testhost*,dotnet*,vstest.console*`
      ![CollectDumps](https://raw.githubusercontent.com/cltshivash/TestProjects/master/TestHang/Images/CollectDumps.PNG)
- Step 2: Upload Collected Dumps (to the build logs)
    -Add a powershell task after your test task 
    -  The task script contents would be inline.
    
       `$scripLocation='https://raw.githubusercontent.com/cltshivash/TestProjects/master/TestHang/UploadDumpFiles.ps1'`
        
       `iex ((New-Object System.Net.WebClient).DownloadString($scripLocation))`
        
    - Ensure that under control options select "Even if a previous task has failed, unless the build was canceled"
    ![UploadDumps](https://raw.githubusercontent.com/cltshivash/TestProjects/master/TestHang/Images/UploadDumps.PNG)

- Sample definition can be referred here : 
     - ![TaskOrdering](https://raw.githubusercontent.com/cltshivash/TestProjects/master/TestHang/Images/TaskOrdering.PNG)
     https://cltshivash.visualstudio.com/PublicProject/_build/index?definitionId=37&_a=completed
