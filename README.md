# Quick Access Alfresco

Quiries Alfresco for the current logged in user to retrieve the sites that they belong to. Then creates and maintains quick access(favourites) links in Windows Explorer. 

Should be deployed using GPO.

# Requires
Powershell version 3+
SSO enabled Alfresco

## Running 
Edit bootstrapQuickAccessAlfresco.bat and append the desired params.

`powershell -executionpolicy bypass -file \\path\to\QuickAccessAlfresco.ps1 -domainName "mydomain.com" -mapDomain "ifmydomainisdiff.com" -prependText "Alfresco Site - " -icon "\\path\to\icon.ico"`

## Todo
- [ ] Strip out hardcoded values.
- [ ] Test Kerberos.
- [ ] An init function to process params set by the bootstrap script.
- [ ] Create and enable schedule.
