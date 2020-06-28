function Invoke-GPOTranslation {
    [cmdletBinding()]
    param(
        [System.Collections.IDictionary] $InputData,
        [string] $Report,
        [string] $Category,
        [string] $Settings
    )
    if ($Category -and $Settings -and $InputData) {

    } else {
        return
    }
    # This section basically makes sure we check for all properties in GPO Types.
    # It's possible given small input of GPOs that I work with that this is not all... and needs updates
    <#
    $AllProperties = Select-Properties -AllProperties -Objects $InputData.$Category.$Settings
    $MissingProperties = $AllProperties | Where-Object { $_ -notin 'DisplayName', 'DomainName', 'GUID', 'Linked', 'LinksCount', 'Links', 'GPOType', 'GPOCategory', 'GPOSettings' }
    [Array] $ConsiderAdding = foreach ($Property in $MissingProperties) {
        if ($Property -notin $Script:GPODitionary[$Report]['PossibleProperties']) {
            $Property
        }
    }
    #>
    $ConsiderAdding = Find-MissingProperties -Objects $InputData.$Category.$Settings -PossibleProperties $Script:GPODitionary[$Report]['PossibleProperties']
    if ($ConsiderAdding.Count -gt 0) {
        Write-Warning "Invoke-Translation - We're missing property for $Category / $Settings - ($($ConsiderAdding -join ','))"
    }
    # Here we try to translate given GPO entries according to predefined dictionary - so called prettify
    # Dictionary will need a lot of work and engine some improvements
    foreach ($GPOEntry in $InputData.$Category.$Settings) {
        # Create new GPO Entry with minimal required properties
        if ($Script:GPODitionary[$Report]['LoopOver'].Keys) {
            foreach ($Key in $Script:GPODitionary[$Report]['LoopOver'].Keys) {
                foreach ($DataObject in $GPOEntry.$Key) {
                    #Set-SpecialObject -GPOEntry $GPOEntry -DataDictionaryLoop $Script:GPODitionary[$Report]['LoopOver'][$Key] -DataDictionary $Script:GPODitionary[$Report] -DataObject $DataObject -Key $Key

                    #$Script:GPODitionary[$Report]['LoopOver'][$Key].GetEnumerator() | Where-Object { $_.Value -is [System.Collections.IDictionary] }

                    $CreateGPO = [ordered]@{
                        DisplayName = $GPOEntry.DisplayName   #: WO_SEC_NTLM_Auth_Level
                        DomainName  = $GPOEntry.DomainName    #: area1.local
                        GUID        = $GPOEntry.GUID          #: 364B095E-C7BF-4CC1-9BFA-393BD38975E5
                        GpoType     = $GPOEntry.GpoType       #: Computer
                        GpoCategory = $GPOEntry.GpoCategory   #: SecuritySettings
                        GpoSettings = $GPOEntry.GpoSettings   #: SecurityOptions
                    }



                    foreach ($PropertyName in $Script:GPODitionary[$Report]['LoopOver'][$Key].Keys) {
                        # We get property that we expect on our $GPOEntry object
                        $Property = $Script:GPODitionary[$Report]['LoopOver'][$Key][$PropertyName]

                        # Since it's possible we may be interested in something that is a nested property we need to do some looping into the object
                        $Value = $DataObject
                        foreach ($P in $Property) {
                            $Value = $Value.$P
                        }
                        # Now we simply assing that value to new GPO Entry
                        # But before we do so, we need to check if it has required type
                        if ($Script:GPODitionary[$Report]['Types'][$PropertyName]) {
                            # This basically checks in dictionary if we want to convert the type from a string to lets say boolean or something else
                            $CreateGPO["$PropertyName"] = Invoke-Command -Command $Script:GPODitionary[$Report]['Types'][$PropertyName] -ArgumentList $Value
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
            }

        } else {
            #Set-SpecialObject -GPOEntry $GPOEntry -DataDictionaryLoop $Script:GPODitionary[$Report]['Translate'] -DataDictionary $Script:GPODitionary[$Report] -DataObject $GPOEntry
            $CreateGPO = [ordered]@{
                DisplayName = $GPOEntry.DisplayName   #: WO_SEC_NTLM_Auth_Level
                DomainName  = $GPOEntry.DomainName    #: area1.local
                GUID        = $GPOEntry.GUID          #: 364B095E-C7BF-4CC1-9BFA-393BD38975E5
                GpoType     = $GPOEntry.GpoType       #: Computer
                GpoCategory = $GPOEntry.GpoCategory   #: SecuritySettings
                GpoSettings = $GPOEntry.GpoSettings   #: SecurityOptions
            }

            # Lets loop thru each Translate Property
            foreach ($PropertyName in $Script:GPODitionary[$Report]['Translate'].Keys) {
                # We get property that we expect on our $GPOEntry object
                $Property = $Script:GPODitionary[$Report]['Translate'][$PropertyName]

                # Since it's possible we may be interested in something that is a nested property we need to do some looping into the object
                $Value = $GPOEntry
                foreach ($P in $Property) {
                    $Value = $Value.$P
                }
                # Now we simply assing that value to new GPO Entry
                # But before we do so, we need to check if it has required type
                if ($Script:GPODitionary[$Report]['Types'][$PropertyName]) {
                    # This basically checks in dictionary if we want to convert the type from a string to lets say boolean or something else
                    $CreateGPO["$PropertyName"] = Invoke-Command -Command $Script:GPODitionary[$Report]['Types'][$PropertyName] -ArgumentList $Value
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
    }
}