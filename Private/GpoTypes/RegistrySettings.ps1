$RegistrySettings = [ordered] @{
    Category           = 'RegistrySettings'
    Settings           = 'RegistrySettings'
    # This is to make sure we're not loosing anything
    # We will detect this and if something is missing provide details
    PossibleProperties = @(
        'clsid', 'Registry', 'Collection'
    )
    LoopOver           = [ordered] @{
        Registry = @{
            'Hive'            = 'Properties', 'Hive'
            'Key'             = 'Properties', 'Key'
            'Name'            = 'Properties', 'Name'
            'Type'            = 'Properties', 'Type'
            'action'          = 'Properties', 'action'
            'displayDecimal'  = 'Properties', 'displayDecimal'
            'default'         = 'Properties', 'default'
            'Value'           = 'Properties', 'Value'
            'Changed'         = 'Changed'
            'GPOSettingOrder' = 'GPOSettingOrder'
            'Filters'         = 'Filters'
        }
    }
    Translate          = [ordered] @{

    }
    Types              = [ordered] @{
        'Changed' = { try { [datetime]::Parse($args) } catch { $null } }
    }
}



function Set-SpecialObject {
    [cmdletbInding()]
    param(
        $GPOEntry,
        $DataDictionaryLoop,
        $DataDictionary,
        $DataObject,
        $Key = 'Translate'
    )
    $CreateGPO = [ordered]@{
        DisplayName = $GPOEntry.DisplayName   #: WO_SEC_NTLM_Auth_Level
        DomainName  = $GPOEntry.DomainName    #: area1.local
        GUID        = $GPOEntry.GUID          #: 364B095E-C7BF-4CC1-9BFA-393BD38975E5
        GpoType     = $GPOEntry.GpoType       #: Computer
        GpoCategory = $GPOEntry.GpoCategory   #: SecuritySettings
        GpoSettings = $GPOEntry.GpoSettings   #: SecurityOptions
    }
    foreach ($PropertyName in $DataDictionaryLoop.Keys) {
        # We get property that we expect on our $GPOEntry object
        $Property = $DataDictionaryLoop[$Key][$PropertyName]

        # Since it's possible we may be interested in something that is a nested property we need to do some looping into the object
        $Value = $DataObject
        foreach ($P in $Property) {
            $Value = $Value.$P
        }
        # Now we simply assing that value to new GPO Entry
        # But before we do so, we need to check if it has required type
        if ($DataDictionary[$Report]['Types'][$PropertyName]) {
            # This basically checks in dictionary if we want to convert the type from a string to lets say boolean or something else
            $CreateGPO["$PropertyName"] = Invoke-Command -Command $DataDictionary[$Report]['Types'][$PropertyName] -ArgumentList $Value
        } else {
            $CreateGPO["$PropertyName"] = $Value
        }
    }

    # return GPO Entry
    $CreateGPO['Linked'] = $GPOEntry.Linked        #: True
    $CreateGPO['LinksCount'] = $GPOEntry.LinksCount    #: 1
    $CreateGPO['Links'] = $GPOEntry.Links         #: area1.local
    [PSCustomObject] $CreateGPO

}