function ConvertTo-SystemServicesNT {
    [cmdletBinding()]
    param(
        [Array] $GPOList
    )
    foreach ($GPOEntry in $GPOList) {
        foreach ($Service in $GPOEntry.NTService) {
            $CreateGPO = [ordered]@{
                DisplayName          = $GPOEntry.DisplayName   #: WO_SEC_NTLM_Auth_Level
                DomainName           = $GPOEntry.DomainName    #: area1.local
                GUID                 = $GPOEntry.GUID          #: 364B095E-C7BF-4CC1-9BFA-393BD38975E5
                GpoType              = $GPOEntry.GpoType       #: Computer
                GpoCategory          = $GPOEntry.GpoCategory   #: SecuritySettings
                GpoSettings          = $GPOEntry.GpoSettings   #: SecurityOptions
                Changed              = [DateTime] $Service.Changed
                GPOSettingOrder      = $Service.GPOSettingOrder
                #ServiceName          = $Service.Name
                ServiceName          = $Service.Properties.serviceName          #: AppIDSvc: AppIDSvc
                ServiceStartupType   = $Service.Properties.startupType          #: NOCHANGE: NOCHANGE
                ServiceAction        = $Service.Properties.serviceAction        #: START: START
                Timeout              = $Service.Properties.timeout              #: 50: 50
                FirstFailure         = $Service.Properties.firstFailure         #: REBOOT: REBOOT
                SecondFailure        = $Service.Properties.secondFailure        #: REBOOT: REBOOT
                ThirdFailure         = $Service.Properties.thirdFailure         #: REBOOT: REBOOT
                ResetFailCountDelay  = $Service.Properties.resetFailCountDelay  #: 0: 0
                RestartComputerDelay = $Service.Properties.restartComputerDelay #: 60000: 60000
                Filter               = $Service.Filter

            }
            $CreateGPO['Linked'] = $GPOEntry.Linked        #: True
            $CreateGPO['LinksCount'] = $GPOEntry.LinksCount    #: 1
            $CreateGPO['Links'] = $GPOEntry.Links         #: area1.local
            [PSCustomObject] $CreateGPO
        }
    }
}