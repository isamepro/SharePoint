@ECHO OFF
C:\Windows\System32\WindowsPowerShell\v1.0\PowerShell.exe -ExecutionPolicy Unrestricted -file SharePoint.Deploy.PS1 "http://sharepoint.domain.com/"
if NOT "%1" == "g" pause
