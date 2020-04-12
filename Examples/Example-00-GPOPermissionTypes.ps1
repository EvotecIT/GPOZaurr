$GPPermissions = [ordered] @{
    GpoApply                    = 'The trustee can apply the GPO; corresponds to the READ and APPLY Group Policy access rights being set to "Allow" for a user.'
    GpoCustom                   = 'The trustee has custom permissions for the GPO.'
    GpoEdit                     = 'The trustee can read and edit the policy settings for the GPO; corresponds to the READ, WRITE, CREATE CHILD OBJECT, and DELETE CHILD OBJECT Group Policy access rights set to "Allow" for a user.'
    GpoEditDeleteModifySecurity = 'The trustee can read, edit and delete the permissions for the GPO; corresponds to the Group Policy access rights specified by GpoEdit plus the DELETE, MODIFY PERMISSIONS, and MODIFY OWNER access rights set to "Allow" for a user.'
    GpoRead                     = 'The trustee can read the GPO; corresponds to the READ Group Policy access right set to "Allow" for a user.'
    None                        = 'This value is reserved for internal use by the Group Policy Windows PowerShell cmdlets.'
    SomCreateGpo                = 'The trustee can create GPOs in the domain. Applies to domains only.'
    SomCreateStarterGpo         = 'The trustee can create Starter GPOs in the domain. Applies to domains only.'
    SomCreateWmiFilter          = 'The trustee can create WMI filters in the domain. Applies to domains only.'
    SomLink                     = 'The trustee can link GPOs to the SOM. Applies to sites, domains and OUs.'
    SomLogging                  = 'The trustee can generate RSoP logging data for the SOM. Applies to domains and OUs.'
    SomPlanning                 = 'The trustee can generate RSoP planning data for the SOM. Applies to domains and OUs.'
    SomWmiFilterFullControl     = 'The trustee has full control over all WMI filters in the domain. Applies to domains only.'
    StarterGpoCustom            = 'The trustee has custom permissions for the Starter GPO.'
    StarterGpoEdit              = 'The trustee can read and edit the administrative template policy settings for the Starter GPO; corresponds to the READ, WRITE, CREATE CHILD OBJECT, and DELETE CHILD OBJECT Group Policy access rights set to "Allow" for a user.'
    StarterGpoFullControl       = 'The trustee has full control for the Starter GPO. Applies to domains only.'
    StarterGpoRead              = 'The trustee can read the Starter GPO; corresponds to the READ Group Policy access right set to "Allow" for a user.'
    WmiFilterCustom             = 'The trustee has custom permissions for the WMI filter.'
    WmiFilterEdit               = 'The trustee can edit the WMI filter.'
    WmiFilterFullControl        = 'The trustee has full control over the WMI filter.'
}

$GPPermissions | Format-Table