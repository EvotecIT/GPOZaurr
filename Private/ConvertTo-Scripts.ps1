function ConvertTo-Scripts {
    [cmdletBinding()]
    param(
        [Array] $GPOList
    )
    foreach ($GPOEntry in $GPOList) {
        $CreateGPO = [ordered]@{
            DisplayName = $GPOEntry.DisplayName   #: WO_SEC_NTLM_Auth_Level
            DomainName  = $GPOEntry.DomainName    #: area1.local
            GUID        = $GPOEntry.GUID          #: 364B095E-C7BF-4CC1-9BFA-393BD38975E5
            GpoType     = $GPOEntry.GpoType       #: Computer
            GpoCategory = $GPOEntry.GpoCategory   #: SecuritySettings
            GpoSettings = $GPOEntry.GpoSettings   #: SecurityOptions
            Command     = $GPOEntry.Command
            Parameters  = $GPOEntry.Parameters
            Type        = $GPOEntry.Type
            Order       = $GPOEntry.Order
            RunOrder    = $GPOEntry.RunOrder
        }
        $CreateGPO['Linked'] = $GPOEntry.Linked        #: True
        $CreateGPO['LinksCount'] = $GPOEntry.LinksCount    #: 1
        $CreateGPO['Links'] = $GPOEntry.Links         #: area1.local
        [PSCustomObject] $CreateGPO

    }
}