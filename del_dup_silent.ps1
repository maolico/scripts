# PowerShell Script to Find Duplicate Files and Delete Them in Folder

    
    while ($true)
    {
        Write-Output ""
        $path = Read-Host "Please Enter a Directory Path to Scan"
        $path = $path -replace '"', ""
        
        
        if (Test-Path $path)
        {
            Write-Host "Valid directory path: $path"
            break
        }
        else
        {
            Write-Host "Invalid directory path, please try again."
        }
    }
    
    
    Clear-Host
    
    Write-Output "Scanning Directory: $path"
    

# Define the directory to scan
    $directoryPath = $path
    
    # Get all files in the directory
    $files = Get-ChildItem -Recurse -Path $directoryPath -File
    
    # Create a hash table to store file hashes
    $fileHashes = @{ }
    
    # Variable to track if duplicates are found
    $duplicatesFound = $false
    
    # Iterate through each file in the directory
    foreach ($file in $files)
    {
        # Compute the hash of the file
        $fileHash = Get-FileHash -Path $file.FullName -Algorithm MD5
        
        # Check if the hash already exists in the hash table
        if ($fileHashes.ContainsKey($fileHash.Hash))
        {
            Write-Output ""
            # Duplicate found
            Write-Host "Duplicate found: $($file.FullName)"
            $duplicatesFound = $true
            Write-Output ""
        }
        else
        {
            # Add the hash to the hash table
            $fileHashes[$fileHash.Hash] = $file.FullName
        }
    }
    
    # Notify the user if no duplicates were found
    if (-not $duplicatesFound)
    {
        Clear-Host
        Write-Output ""
        Write-Host "No duplicates found in the ""$directoryPath"" directory."
        Write-Output ""
        Exit
        
        
    }

    
    
    # Prompt the user for confirmation
    $confirmation = Read-Host "Are you sure you want to delete the files in $path directory? (Y/N)"
    
    if ($confirmation -eq 'Y' -or $confirmation -eq 'y')
    {
        Clear-Host
        # Define the directory to search for duplicate files
        $directory = $path
        
        # Get all files in the directory and subdirectories
        $files = Get-ChildItem -Path $directory -Recurse -File
        
        # Group files by their hash value
        $duplicates = $files | Group-Object -Property { (Get-FileHash $_.FullName).Hash } | Where-Object { $_.Count -gt 1 }
        
        
        foreach ($group in $duplicates)
        {
            #define an empty array to be used as a menu
            $menu = @()
            foreach ($file in $group.Group){
                #fill the menu array with the files in this group
                $menu+=$file
            }
            #write the custom menu
            write-host "========================"
            for ($i=0;$i -lt $menu.Length; $i++){
                write-host $($i + 1) - $menu[$i]
            }
            $answer = 2

            #Check if the user supplied a valid number.  There could be some error checking here as it just checks
            #that the user supplied a number greater than 0 and less than the length + 1 because humans don't count from 0
            #It will just exit if the user submits something other than a valid number
            if (($answer -le $($menu.Length + 1)) -and ($answer -gt 0)){
                #remove the selected file from the array
                $menu[$($answer-1)] = $null
                foreach ($file in $menu){
                    #delete the files silentlycontinue because there will probably be an error from trying to delete $null
                Remove-Item -Path $menu.FullName -ErrorAction SilentlyContinue -Force
                
                }
            }

            
        }
        
        
    }