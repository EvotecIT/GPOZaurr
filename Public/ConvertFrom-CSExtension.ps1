﻿function ConvertFrom-CSExtension {
    <#
    .SYNOPSIS
    Converts Client-side Extension (CSE) GUIDs to their corresponding names.

    .DESCRIPTION
    This function takes an array of CSE GUIDs and returns their corresponding names. It can be used to easily identify the purpose of each CSE GUID.

    .PARAMETER CSE
    Specifies an array of Client-side Extension (CSE) GUIDs to be converted to names.

    .PARAMETER Limited
    Indicates whether the conversion should be limited to a predefined set of CSE GUIDs.

    .EXAMPLE
    ConvertFrom-CSExtension -CSE '{35378EAC-683F-11D2-A89A-00C04FBBCFA2}', '{0F6B957E-509E-11D1-A7CC-0000F87571E3}' -Limited
    Converts the specified CSE GUIDs to their corresponding names, limited to a predefined set.

    .EXAMPLE
    ConvertFrom-CSExtension -CSE '{D02B1F73-3407-48AE-BA88-E8213C6761F1}', '{0ACDD40C-75AC-47ab-BAA0-BF6DE7E7FE63}'
    Converts the specified CSE GUIDs to their corresponding names without any limitations.

    #>
    [cmdletBinding()]
    param(
        [string[]] $CSE,
        [switch] $Limited
    )
    $GUIDs = @{
        # https://docs.microsoft.com/en-us/openspecs/windows_protocols/ms-gpreg/f0dba6b8-704f-45d5-999f-1a0a694a6df9
        '{35378EAC-683F-11D2-A89A-00C04FBBCFA2}' = 'Client-side extension GUID (CSE GUID)'
        '{0F6B957E-509E-11D1-A7CC-0000F87571E3}' = 'Tool Extension GUID (User Policy Settings)'
        '{D02B1F73-3407-48AE-BA88-E8213C6761F1}' = 'Tool Extension GUID (User Policy Settings)'
        '{0F6B957D-509E-11D1-A7CC-0000F87571E3}' = 'Tool Extension GUID (Computer Policy Settings)'
        '{D02B1F72-3407-48AE-BA88-E8213C6761F1}' = 'Tool Extension GUID (Computer Policy Settings)'
        '{0ACDD40C-75AC-47ab-BAA0-BF6DE7E7FE63}' = 'Wireless Group Policy'
        '{0E28E245-9368-4853-AD84-6DA3BA35BB75}' = 'Group Policy Environment'
        '{16be69fa-4209-4250-88cb-716cf41954e0}' = 'Central Access Policy Configuration'
        '{17D89FEC-5C44-4972-B12D-241CAEF74509}' = 'Group Policy Local Users and Groups'
        '{1A6364EB-776B-4120-ADE1-B63A406A76B5}' = 'Group Policy Device Settings'
        '{25537BA6-77A8-11D2-9B6C-0000F8080861}' = 'Folder Redirection'
        '{2A8FDC61-2347-4C87-92F6-B05EB91A201A}' = 'MitigationOptions'
        '{346193F5-F2FD-4DBD-860C-B88843475FD3}' = 'ConfigMgr User State Management Extension.'
        '{3610eda5-77ef-11d2-8dc5-00c04fa31a66}' = 'Microsoft Disk Quota'
        '{3A0DBA37-F8B2-4356-83DE-3E90BD5C261F}' = 'Group Policy Network Options'
        '{426031c0-0b47-4852-b0ca-ac3d37bfcb39}' = 'QoS Packet Scheduler'
        '{42B5FAAE-6536-11d2-AE5A-0000F87571E3}' = 'Scripts'
        '{4bcd6cde-777b-48b6-9804-43568e23545d}' = 'Remote Desktop USB Redirection'
        '{4CFB60C1-FAA6-47f1-89AA-0B18730C9FD3}' = 'Internet Explorer Zonemapping'
        '{4D2F9B6F-1E52-4711-A382-6A8B1A003DE6}' = 'RADCProcessGroupPolicyEx'
        '{4d968b55-cac2-4ff5-983f-0a54603781a3}' = 'Work Folders'
        '{5794DAFD-BE60-433f-88A2-1A31939AC01F}' = 'Group Policy Drive Maps'
        '{6232C319-91AC-4931-9385-E70C2B099F0E}' = 'Group Policy Folders'
        '{6A4C88C6-C502-4f74-8F60-2CB23EDC24E2}' = 'Group Policy Network Shares'
        '{7150F9BF-48AD-4da4-A49C-29EF4A8369BA}' = 'Group Policy Files'
        '{728EE579-943C-4519-9EF7-AB56765798ED}' = 'Group Policy Data Sources'
        '{74EE6C03-5363-4554-B161-627540339CAB}' = 'Group Policy Ini Files'
        '{7933F41E-56F8-41d6-A31C-4148A711EE93}' = 'Windows Search Group Policy Extension'
        '{7B849a69-220F-451E-B3FE-2CB811AF94AE}' = 'Internet Explorer User Accelerators'
        '{827D319E-6EAC-11D2-A4EA-00C04F79F83A}' = 'Security'
        '{8A28E2C5-8D06-49A4-A08C-632DAA493E17}' = 'Deployed Printer Connections'
        '{91FBB303-0CD5-4055-BF42-E512A681B325}' = 'Group Policy Services'
        '{A3F3E39B-5D83-4940-B954-28315B82F0A8}' = 'Group Policy Folder Options'
        '{AADCED64-746C-4633-A97C-D61349046527}' = 'Group Policy Scheduled Tasks'
        '{B087BE9D-ED37-454f-AF9C-04291E351182}' = 'Group Policy Registry'
        '{B587E2B1-4D59-4e7e-AED9-22B9DF11D053}' = '802.3 Group Policy'
        '{BA649533-0AAC-4E04-B9BC-4DBAE0325B12}' = 'Windows To Go Startup Options'
        '{BC75B1ED-5833-4858-9BB8-CBF0B166DF9D}' = 'Group Policy Printers'
        '{C34B2751-1CF4-44F5-9262-C3FC39666591}' = 'Windows To Go Hibernate Options'
        '{C418DD9D-0D14-4efb-8FBF-CFE535C8FAC7}' = 'Group Policy Shortcuts'
        '{C631DF4C-088F-4156-B058-4375F0853CD8}' = 'Microsoft Offline Files'
        '{c6dc5466-785a-11d2-84d0-00c04fb169f7}' = 'Software Installation'
        '{cdeafc3d-948d-49dd-ab12-e578ba4af7aa}' = 'TCPIP'
        '{CF7639F3-ABA2-41DB-97F2-81E2C5DBFC5D}' = 'Internet Explorer Machine Accelerators'
        '{e437bc1c-aa7d-11d2-a382-00c04f991e27}' = 'IP Security'
        '{E47248BA-94CC-49c4-BBB5-9EB7F05183D0}' = 'Group Policy Internet Settings'
        '{E4F48E54-F38D-4884-BFB9-D4D2E5729C18}' = 'Group Policy Start Menu Settings'
        '{E5094040-C46C-4115-B030-04FB2E545B00}' = 'Group Policy Regional Options'
        '{E62688F0-25FD-4c90-BFF5-F508B9D2E31F}' = 'Group Policy Power Options'
        '{F312195E-3D9D-447A-A3F5-08DFFA24735E}' = 'ProcessVirtualizationBasedSecurityGroupPolicy'
        '{f3ccc681-b74c-4060-9f26-cd84525dca2a}' = 'Audit Policy Configuration'
        '{F9C77450-3A41-477E-9310-9ACD617BD9E3}' = 'Group Policy Applications'
        '{FB2CA36D-0B40-4307-821B-A13B252DE56C}' = 'Enterprise QoS'
        '{fbf687e6-f063-4d9f-9f4f-fd9a26acdd5f}' = 'CP'
        '{FC491EF1-C4AA-4CE1-B329-414B101DB823}' = 'ProcessConfigCIPolicyGroupPolicy'
        '{169EBF44-942F-4C43-87CE-13C93996EBBE}' = 'UEV Policy'
        '{2BFCC077-22D2-48DE-BDE1-2F618D9B476D}' = 'AppV Policy'
        '{4B7C3B0F-E993-4E06-A241-3FBE06943684}' = 'Per-process Mitigation Options'
        '{7909AD9E-09EE-4247-BAB9-7029D5F0A278}' = 'MDM Policy'
        '{CFF649BD-601D-4361-AD3D-0FC365DB4DB7}' = 'Delivery Optimization GP extension'
        '{D76B9641-3288-4f75-942D-087DE603E3EA}' = 'AdmPwd'
        '{9650FDBC-053A-4715-AD14-FC2DC65E8330}' = 'Unknown'
        '{B1BE8D72-6EAC-11D2-A4EA-00C04F79F83A}' = 'EFS Recovery'
        '{A2E30F80-D7DE-11d2-BBDE-00C04F86AE3B}' = 'Internet Explorer Maintenance Policy Processing'
        '{FC715823-C5FB-11D1-9EEF-00A0C90347FF}' = 'Internet Explorer Maintenance Extension Protocol' # https://docs.microsoft.com/en-us/openspecs/windows_protocols/ms-gpie/f566a58a-4114-4981-b1e2-30b9d1a3c0e6
    }
    foreach ($C in $CSE) {
        if (-not $Limited) {
            if ($GUIDs[$C]) {
                [PSCustomObject] @{ Name = $C; Description = $GUIDs[$C] }
            } else {
                [PSCustomObject] @{ Name = $C; Description = $C }
            }
        } else {
            if ($GUIDs[$C]) {
                $GUIDs[$C]
            } else {
                $CSE
            }
        }
    }
}