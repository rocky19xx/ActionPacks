#Requires -Version 4.0

<#
.SYNOPSIS
    Imports a scheduled task definition on the computer

.DESCRIPTION

.NOTES
    This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
    The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
    The terms of use for ScriptRunner do not apply to this script. In particular, AppSphere AG assumes no liability for the function, 
    the use and the consequences of the use of this freely available script.
    PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of AppSphere AG.
    © AppSphere AG

.COMPONENT

.LINK
    https://github.com/scriptrunner/ActionPacks/tree/master/WinSystemManagement/ScheduledTasks

.Parameter TaskName
    Specifies the name of a scheduled task

.Parameter ImportFile
    Specifies the XML file that contains a task definition

.Parameter ComputerName
    Specifies the name of the computer on which to import the schedule task
    
.Parameter AccessAccount
    Specifies a user account that has permission to perform this action. If Credential is not specified, the current user account is used.
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$TaskName,
    [Parameter(Mandatory = $true)]
    [string]$ImportFile,
    [string]$ComputerName,
    [PSCredential]$AccessAccount
)

$Script:Cim=$null
[string[]]$Properties = @("TaskName","TaskPath","State","Description","URI","Author")
try{
    if([System.String]::IsNullOrWhiteSpace($ComputerName)){
        $ComputerName=[System.Net.DNS]::GetHostByName('').HostName
    }          
    if($null -eq $AccessAccount){
        $Script:Cim =New-CimSession -ComputerName $ComputerName -ErrorAction Stop
    }
    else {
        $Script:Cim =New-CimSession -ComputerName $ComputerName -Credential $AccessAccount -ErrorAction Stop
    }
    $null = Register-ScheduledTask -CimSession $Script:Cim -TaskName $TaskName -Force -Xml (Get-Content $ImportFile | Out-String) -ErrorAction Stop
    $output = Get-ScheduledTask -CimSession $Script:Cim -TaskName $TaskName | Select-Object $Properties
    if(-not [System.String]::IsNullOrWhiteSpace($ExportFile)){
        $output | Out-File $ExportFile
    }
    if($SRXEnv) {
        $SRXEnv.ResultMessage = $output
    }
    else{
        Write-Output $output
    }
}
catch{
    throw
}
finally{
    if($null -ne $Script:Cim){
        Remove-CimSession $Script:Cim 
    }
}