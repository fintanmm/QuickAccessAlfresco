SET whoAmI=%USERNAME%
SET webDir=alfresco\service\api\people\%whoAmI%\sites\
mkdir %webDir%
copy stub\sites.json %webDir%\index.json
type NUL > alfresco_careers_icon.ico
powershell.exe "Start-Process powershell.exe .\server.ps1 -Verb runAs" 
powershell.exe -noexit Invoke-Pester .\QuickAccessAlfresco.Tests.ps1 -CodeCoverage .\QuickAccessAlfresco.ps1
