# Quick Access Alfresco (QAA)

QAA is a script written in PowerShell, QAA queries Alfresco for the current logged in user to retrieve the sites that they are a member of, it creates and maintains quick access(Windows 10) or favourites(Windows 7) links in Windows Explorer. 

QAA Should be deployed using GPO to client machines. Currently, QAA defaults to the CIFS protocol when setting up links.

# Features:
    1. Sets up a schedule to run hourly. (TODO)
    2. Caches result so that updates run when needed.
    3. QAA supports multiple protocols such as CIFS, FTPS, WebDAV and SharePoint.
    4. QAA creates Home and Shared links.
    5. Ability to apply a custom folder icon to folders.
    6. Retrieve favourite sites and place other sites within a sites folder. (TODO)

# Requires
    * Powershell version 3+
    * SSO enabled Alfresco
    * TLS version 1.2+ enabled client for WebDAV/SharePoint to work correctly.

## Running 
Edit bootstrapQuickAccessAlfresco.bat and append the desired params.

`powershell -executionpolicy bypass -file \\path\to\QuickAccessAlfresco.ps1 -domainName "mydomain.com" -mapDomain "ifmydomainisdiff.com" -prependToLinkTitle "Alfresco Site - " -icon "\\path\to\icon.ico" -protocol webdav`

## Todo
- [x] Strip out hardcoded values.
- [x] Test Kerberos.
- [x] An init function to process params set by the bootstrap script.
- [x] Create and enable scheduling.
