<#
        .NOTES
===========================================================================
        Created on:   2024-01-17
        Created by:   Wallace Chen
        Modified by:
        Modified on:
        Filename:     QS_MultiNodeServiceRestart.ps1
===========================================================================
        .DESCRIPTION
            To restart qlik sense services in different node(s)
#>


# Specify Qlik Sense node names
$qlikSenseNodes = @(
    #"CentralNodeHostName",
    #"ServerName1"
    # Add more node hostnames as needed
)

# Specify Qlik Sense services to restart
$servicesToRestart = @(
    "Qlik Sense Service Dispatcher"
    "Qlik Sense Service Engine",
    "Qlik Sense Proxy Service",
    "Qlik Sense Repository Service"
    # Add more services as needed
)


# Function to restart services on a specific node
function Restart-ServicesOnNode {
    param (
        [string]$nodeName,
        [string[]]$services
    )

    $InvokeCommandParams = @{}
    if ($nodeName -ne $env:COMPUTERNAME) {
        $InvokeCommandParams.Session = New-PSSession -ComputerName $nodeName -Verbose
    }

    Invoke-Command -ScriptBlock {
        param($serviceName)
        Write-Host "Restarting service: $serviceName on $($env:COMPUTERNAME)"
        Stop-Service -DisplayName $serviceName -Force -Verbose
        Start-Service -DisplayName $serviceName -Verbose
        Write-Host "Service Restarted: $serviceName on $($env:COMPUTERNAME)"
    } -ArgumentList $services -Session $InvokeCommandParams.Session

    If ($null -ne $InvokeCommandParams.Session) {
        Remove-PSSession $InvokeCommandParams.Session
    }

    Write-Host "Services on $nodeName restarted."
}

# Restart services on each Qlik Sense node
foreach ($qlikSenseNode in $qlikSenseNodes) {
    Restart-ServicesOnNode -nodeName $qlikSenseNode -services $servicesToRestart
}