Import-Module "$PSScriptRoot\..\GPoZaurr.psd1" -Force

# You can set owner per guid if you want to have more control.
$LImitProcessing = 2

# check what is there now
$GPOs = Get-GPOZaurr #-GPOName 'New Group Policy Object'
$GPOs | Format-Table DisplayName, Owner, OwnerSID
$Count = 0

# loop thru all GPOS (or use LimitProcessing)
foreach ($GPO in $GPOS) {
    $Count++
    Set-GPOZaurrOwner -GPOID $GPO.GUID -Verbose -Principal 'przemyslaw.klys@evotec.pl' #-WhatIf
    if ($Count -eq $LImitProcessing) {
        break
    }
}

# Confirm what changed
$GPOs = Get-GPOZaurr #-GPOName 'New Group Policy Object'
$GPOs | Format-Table DisplayName, Owner, OwnerSID