function New-GPOZaurrReportConsole {
    [cmdletBinding()]
    param(
        [System.Collections.IDictionary] $Results,
        [string] $ComputerName
    )
    Begin {
        $GPODeny = @{
            Color       = 'Yellow', 'Red', 'Yellow', 'Red'
            StartSpaces = 6
        }
        $GPOSuccess = @{
            Color       = 'Yellow', 'Green', 'Yellow', 'Green'
            StartSpaces = 6
        }
        $WriteSummary = @{
            Color       = 'Yellow', 'Blue'
            StartSpaces = 3
        }
        $ComputerWhereApplied = ($Results.ComputerResults.GroupPolicies | Sort-Object -Property DomainName, Name).Where( { $_.Status -eq 'Applied' }, 'split')
        $UserWhereApplied = ($Results.UserResults.GroupPolicies | Sort-Object -Property Name).Where( { $_.Status -eq 'Applied' }, 'split')
    }
    Process {
        if ($Results.ComputerResults) {
            Write-Color -Text 'Computer Settings' -Color Yellow -LinesBefore 1
            Write-Color -Text '[>] Last time Group Policy was applied: ', $Results.ComputerResults.Summary.ReadTime @WriteSummary
            Write-Color -Text '[>] Computer Name: ', $Results.ComputerResults.Summary.ComputerName @WriteSummary
            Write-Color -Text '[>] Domain Name: ', $Results.ComputerResults.Summary.DomainName @WriteSummary
            Write-Color -Text '[>] Organizational Unit: ', $Results.ComputerResults.Summary.OrganizationalUnit @WriteSummary
            Write-Color -Text '[>] Site: ', $Results.ComputerResults.Summary.Site @WriteSummary
            Write-Color -Text '[>] GPO Types: ', ($Results.ComputerResults.Summary.GPOTypes -replace [System.Environment]::NewLine, ', ') @WriteSummary
            Write-Color -Text '[>] Slow link: ', ($Results.ComputerResults.Summary.SlowLink) @WriteSummary

            Write-Color -Text 'Applied Group Policy Objects' -StartSpaces 3 -LinesBefore 1
            foreach ($GPO in $ComputerWhereApplied[0]) {
                Write-Color -Text '[+] [', $GPO.DomainName, '] ', $GPO.Name @GPOSuccess
            }

            Write-Color -Text 'Denied Group Policy Objects' -StartSpaces 3
            foreach ($GPO in $ComputerWhereApplied[1]) {
                Write-Color -Text '[-] [', $GPO.DomainName, '] ', $GPO.Name @GPODeny
            }
        } else {
            Write-Color -Text 'Computer Settings' -Color Yellow -LinesBefore 1
            Write-Color -Text '[>] Last time Group Policy was applied: ', 'Unable to get? No administrative permission?' @WriteSummary
            Write-Color -Text '[>] Computer Name: ', $ComputerName @WriteSummary
        }

        Write-Color -Text 'User Settings' -Color Yellow -LinesBefore 1
        Write-Color -Text '[>] Last time Group Policy was applied: ', $Results.UserResults.Summary.ReadTime @WriteSummary
        Write-Color -Text '[>] Computer Name: ', $Results.UserResults.Summary.ComputerName @WriteSummary
        Write-Color -Text '[>] Domain Name: ', $Results.UserResults.Summary.DomainName @WriteSummary
        Write-Color -Text '[>] Organizational Unit: ', $Results.UserResults.Summary.OrganizationalUnit @WriteSummary
        Write-Color -Text '[>] Site: ', $Results.UserResults.Summary.Site @WriteSummary
        Write-Color -Text '[>] GPO Types: ', ($Results.UserResults.Summary.GPOTypes -replace [System.Environment]::NewLine, ', ') @WriteSummary
        Write-Color -Text '[>] Slow link: ', ($Results.UserResults.Summary.SlowLink) @WriteSummary

        Write-Color -Text 'Applied Group Policy Objects' -StartSpaces 3
        foreach ($GPO in $UserWhereApplied[0] ) {
            Write-Color -Text '[+] [', $GPO.DomainName, '] ', $GPO.Name @GPOSuccess
        }

        Write-Color -Text 'Denied Group Policy Objects' -StartSpaces 3
        foreach ($GPO in $UserWhereApplied[1]) {
            Write-Color -Text '[-] [', $GPO.DomainName, '] ', $GPO.Name @GPODeny
        }
    }
}