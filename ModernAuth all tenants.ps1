#
# Manage Exchange Online Delegated Tenants.ps1
#

# Setup credentials
$cred = Get-Credential
Connect-MsolService -Credential $cred

# Get list of tenants & loop
Get-MsolPartnerContract -All | ForEach { 
    $tenantprefix = [string]$_.DefaultDomainName

    # Configure the connection url - note the DelegatedOrg parameter
    $ConnectionUri = "https://ps.outlook.com/powershell-liveid?DelegatedOrg=$tenantprefix"
    
    # Connect to Exchange & import session
    $Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri $ConnectionUri -Credential $cred -Authentication Basic -AllowRedirection 
    Import-PSSession $Session -AllowClobber

    Get-OrganizationConfig | Format-Table -Auto Name,OAuth*

    Set-OrganizationConfig -OAuth2ClientProfileEnabled $true

    Get-OrganizationConfig | Format-Table -Auto Name,OAuth*

    # Remove the session - avoid hitting 3 session limit
    Remove-PSSession $Session
}