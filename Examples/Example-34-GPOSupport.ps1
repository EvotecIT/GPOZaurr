Import-Module "$PSScriptRoot\..\GPoZaurr.psd1" -Force

#Invoke-GPOZaurrSupport -ComputerName 'AD1' -UserName 'przemyslaw.klys' -Type HTML
#$Support1 = Invoke-GPOZaurrSupport -ComputerName 'AD1' -UserName 'przemyslaw.klys' -Type Object
#$Support = Invoke-GPOZaurrSupport -ComputerName 'AD1' -UserName 'EVOTEC\Administrator' -Type Object
#$Support.ComputerResults.ExtensionData


foreach ($GpoType in @('UserResults', 'ComputerResults')) {
    if ($Support.$GpoType.ExtensionData) {
        foreach ($Extension in $Support.$GpoType.ExtensionData) {
            $GPOSettingTypeSplit = ($Extension.type -split ':')
            #$Extension
            #$Extension | Get-Member -MemberType Properties -ErrorAction Stop
            $KeysToLoop = $Extension | Get-Member -MemberType Properties -ErrorAction Stop | Where-Object { $_.Name -notin @($GPOSettingTypeSplit[0], 'xmlns', 'blocked', 'type') }
            foreach ($GpoSettings in $KeysToLoop.Name) {
                $Extension.$GpoSettings | Format-Table
            }
        }
    }
}

# $env:LOGONSERVER
# if($env:LOGONSERVER -match "MicrosoftAccount") {"Logged on with Windows account"}

# If it reports \\MicrosoftAccount, they are using their Windows account to sign in instead of domain credentials.
#You can check this by using the IF statement as shown here:


#[System.DirectoryServices.ActiveDirectory.ActiveDirectorySite]::GetComputerSite().Name

#[System.DirectoryServices.ActiveDirectory.DomainController]::

# https://concurrency.com/blog/may-2018/domain-controller-selection
#echo %logonserver% - This shows the DC that was used to authenticate and log in the current user
#nltest /dsgetsite - This shows the AD site that the current server has detected that it's in
#nltest /dclist: (include the colon at the end) - This shows the list of DCs in the current domain, including which site each is in.
# nslookup -type=srv _ldap._tcp.mydomain.local. - This will query the primary DNS server for all domain controller SRV records.  This should return all of the DCs in the domain.  In this example, MGLABDC4 and MGLABDC5 are returned.
# nslookup -type=srv _ldap._tcp.mysitename._sites.dc._msdcs.mydomain.local. - This will query the primary DNS server for domain controllers that are registered in "mysitename".  In this example, only MGLABDC4 is in the site that was queried, which matches the information we found with nltest /dclist: previously.


# Windows 10

#Add-WindowsCapability -Online -Name 'Rsat.ActiveDirectory.DS-LDS.Tools~~~~0.0.1.0'
#Add-WindowsCapability -Online -Name 'Rsat.GroupPolicy.Management.Tools~~~~0.0.1.0'
#Remove-WindowsCapability -Online -Name 'Rsat.ActiveDirectory.DS-LDS.Tools~~~~0.0.1.0'

echo %logonserver%
nltest /dsgetsite
nltest /dclist:

$env:LOGONSERVER
[System.DirectoryServices.ActiveDirectory.ActiveDirectorySite]::GetComputerSite().Name
nslookup -type=srv _ldap._tcp.ad.colmore.com.
nslookup -type=srv _ldap._tcp.birmingham._sites.dc._msdcs.ad.colmore.com.