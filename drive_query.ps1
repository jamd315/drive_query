# Query the registry to get user security IDs on the computer.  Redirect stddout/stderr to null because you can't access some of the registry keys for protected builtin accounts with Get-ChildItem so it errors every time
($SIDs = Get-ChildItem "REGISTRY::HKEY_USERS" | Where { $_.Name -match "S-1-5-21" -and -not $_.Name.EndsWith("_Classes") }) > $null 2> $null

$SIDs | ForEach-Object {
    $SID = $_.Name
    #Write-Host $SID
    $username = (Get-ItemProperty "REGISTRY::$($SID)\Volatile Environment\").USERNAME  # Query the registry to get the username for each SID
    Write-Output $username
    (Get-ChildItem "REGISTRY::$($SID)\Network") | ForEach-Object {  # Check for any mapped drives and print the info
        $drive_reg = $_.Name
        $drive_letter = $drive_reg.SubString($drive_reg.length-1).ToUpper()
        $remote_path = (Get-ItemProperty "REGISTRY::$($drive_reg)").RemotePath
        Write-Output "$($drive_letter): $($remote_path)"
    }
}