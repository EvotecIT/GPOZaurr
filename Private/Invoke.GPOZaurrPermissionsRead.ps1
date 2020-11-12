$GPOZaurrPermissionsRead = [ordered] @{
    Name       = 'Group Policy Authenticated Users Permissions'
    Enabled    = $true
    Action     = $null
    Data       = $null
    Execute    = {
        Get-GPOZaurrPermission -Type AuthenticatedUsers -ReturnSecurityWhenNoData
    }
    Processing = {
        # Create Per Domain Variables
        $Script:Reporting['GPOPermissionsRead']['Variables']['WillFixPerDomain'] = @{}
        $Script:Reporting['GPOPermissionsRead']['Variables']['WillNotTouchPerDomain'] = @{}
        foreach ($GPO in $Script:Reporting['GPOPermissionsRead']['Data']) {
            # Create Per Domain Variables
            if (-not $Script:Reporting['GPOPermissionsRead']['Variables']['WillFixPerDomain'][$GPO.DomainName]) {
                $Script:Reporting['GPOPermissionsRead']['Variables']['WillFixPerDomain'][$GPO.DomainName] = 0
            }
            if (-not $Script:Reporting['GPOPermissionsRead']['Variables']['WillNotTouchPerDomain'][$GPO.DomainName]) {
                $Script:Reporting['GPOPermissionsRead']['Variables']['WillNotTouchPerDomain'][$GPO.DomainName] = 0
            }
            # Checks
            if ($GPO.Permission -in 'GpoApply', 'GpoRead') {
                $Script:Reporting['GPOPermissionsRead']['Variables']['WillNotTouch']++
                $Script:Reporting['GPOPermissionsRead']['Variables']['WillNotTouchPerDomain'][$GPO.DomainName]++
            } else {
                $Script:Reporting['GPOPermissionsRead']['Variables']['WillFix']++
                $Script:Reporting['GPOPermissionsRead']['Variables']['WillFixPerDomain'][$GPO.DomainName]++
            }
        }
        if ($Script:Reporting['GPOPermissionsRead']['Variables']['WillFix'].Count -gt 0) {
            $Script:Reporting['GPOPermissionsRead']['ActionRequired'] = $true
        } else {
            $Script:Reporting['GPOPermissionsRead']['ActionRequired'] = $false
        }
    }
    Variables  = @{
        WillFix               = 0
        WillNotTouch          = 0
        WillFixPerDomain      = $null
        WillNotTouchPerDomain = $ull
    }
    Overview   = {

    }
    Summary = {

    }
    Solution   = {
        New-HTMLTable -DataTable $Script:Reporting['GPOPermissions']['Data'] -Filtering
        if ($Script:Reporting['GPOPermissions']['WarningsAndErrors']) {
            New-HTMLSection -Name 'Warnings & Errors to Review' {
                New-HTMLTable -DataTable $Script:Reporting['GPOPermissions']['WarningsAndErrors'] -Filtering {
                    New-HTMLTableCondition -Name 'Type' -Value 'Warning' -BackgroundColor SandyBrown -ComparisonType string -Row
                    New-HTMLTableCondition -Name 'Type' -Value 'Error' -BackgroundColor Salmon -ComparisonType string -Row
                }
            }
        }
    }
}