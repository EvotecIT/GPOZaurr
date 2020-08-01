function Get-XMLRegistryPolicies {
    [cmdletBinding()]
    param(
        [PSCustomObject] $GPO,
        [System.Xml.XmlElement[]] $GPOOutput,
        [string] $Splitter = [System.Environment]::NewLine,
        [switch] $FullObjects
    )
    $LinksInformation = Get-LinksFromXML -GPOOutput $GPOOutput -Splitter $Splitter -FullObjects:$FullObjects
    foreach ($Type in @('User', 'Computer')) {
        if ($GPOOutput.$Type.ExtensionData.Extension) {
            foreach ($ExtensionType in $GPOOutput.$Type.ExtensionData.Extension) {
                foreach ($Key in $ExtensionType.Policy) {
                    [PSCustomObject] @{
                        DisplayName     = $GPO.DisplayName
                        DomainName      = $GPO.DomainName
                        GUID            = $GPO.Guid
                        Linked          = $LinksInformation.Linked
                        LinksCount      = $LinksInformation.LinksCount
                        Links           = $LinksInformation.Links
                        GpoType         = $Type
                        PolicyName      = $Key.Name
                        PolicyState     = $Key.State
                        PolicyCategory  = $Key.Category
                        PolicySupported = $Key.Supported
                        PolicyExplain   = $Key.Explain
                        PolicyCheckBox  = $Key.CheckBox
                        PolicyText      = $Key.Text
                        DropDownList    = $Key.DropDownList
                        PolicyEditText  = $Key.EditText
                        <#
                        Name                                State   Value
                        ----                                -----   -----
                        Target group name for this computer Enabled de00_wsus3_measuring_devices
                        #>
                    }
                }
            }
        }
    }
}