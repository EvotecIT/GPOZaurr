Import-Module "$PSScriptRoot\..\GPoZaurr.psd1" -Force

# search by guid or name for specific GPOs
#Get-GPOZaurrMissingFiles -GPOGUID '{2F326111-C21B-4892-B7BC-9BDCB201FFCC}' | Format-Table

# search for all GPOs with missing files
#Get-GPOZaurrMissingFiles -BrokenOnly | Format-Table

# search for all GPOs with missing files for everythin
Invoke-GPOZaurr -Type GPOBrokenPartially #, GPOBroken, GPOBrokenLink