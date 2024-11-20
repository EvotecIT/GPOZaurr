function ConvertTo-XMLRestrictedGroups {
    [cmdletBinding()]
    param(
        [PSCustomObject] $GPO,
        [switch] $SingleObject
    )
    if ($SingleObject) {
        $CreateGPO = [ordered]@{
            DisplayName = $GPO.DisplayName
            DomainName  = $GPO.DomainName
            GUID        = $GPO.GUID
            GpoType     = $GPO.GpoType
            #GpoCategory = $GPOEntry.GpoCategory
            #GpoSettings = $GPOEntry.GpoSettings
            Count       = 0
            Settings    = $null
        }
        [Array] $CreateGPO['Settings'] = foreach ($Script in $GPO.DataSet) {
            $Members = foreach ($Member in $Group.Member) {
                if ($($Member.SID.'#text')) {
                    "$($Member.Name.'#text') ($($Member.SID.'#text'))"
                } else {
                    $Member.Name.'#text'
                }
            }
            $MemberOf = foreach ($Member in $Group.MemberOf) {
                if ($($Member.SID.'#text')) {
                    "$($Member.Name.'#text') ($($Member.SID.'#text'))"
                } else {
                    $Member.Name.'#text'
                }
            }
            [PSCustomObject]@{
                GroupName = $Group.GroupName.Name
                GroupSID  = $Group.GroupName.SID.'#text'
                Members   = $Members -join ', '
                MembersOf = $MemberOf -join ', '
            }
        }
        $CreateGPO['DataCount'] = $CreateGPO['Settings'].Count
        $CreateGPO['Linked'] = $GPO.Linked
        $CreateGPO['LinksCount'] = $GPO.LinksCount
        $CreateGPO['Links'] = $GPO.Links
        [PSCustomObject] $CreateGPO
    } else {
        foreach ($Group in $GPO.DataSet) {
            $Members = foreach ($Member in $Group.Member) {
                if ($($Member.SID.'#text')) {
                    "$($Member.Name.'#text') ($($Member.SID.'#text'))"
                } else {
                    $Member.Name.'#text'
                }
            }
            $MemberOf = foreach ($Member in $Group.MemberOf) {
                if ($($Member.SID.'#text')) {
                    "$($Member.Name.'#text') ($($Member.SID.'#text'))"
                } else {
                    $Member.Name.'#text'
                }
            }
            $CreateGPO = [ordered]@{
                DisplayName = $GPO.DisplayName
                DomainName  = $GPO.DomainName
                GUID        = $GPO.GUID
                GpoType     = $GPO.GpoType
                GroupName   = $Group.GroupName.Name.'#text'
                GroupSID    = $Group.GroupName.SID.'#text'
                Members     = $Members -join ', '
                MembersOf   = $MemberOf -join ', '
            }
            $CreateGPO['Linked'] = $GPO.Linked
            $CreateGPO['LinksCount'] = $GPO.LinksCount
            $CreateGPO['Links'] = $GPO.Links
            [PSCustomObject] $CreateGPO
        }
    }
}