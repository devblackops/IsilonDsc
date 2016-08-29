#requires -modules SSLValidation

function Login {
    [outputtype([bool])]
    [cmdletbinding()]
    param(
        [parameter(Mandatory)]
        [string]$Cluster,

        [parameter(Mandatory)]
        [pscredential]
        [System.Management.Automation.Credential()]$Credential
    )

    try {
        Disable-SSLValidation
        New-IsiSession -ComputerName $Cluster -Credential $Credential -Verbose:$false
        return $true
    } catch {
        Write-Error -Exception $_
        return $false
    }
}

function WriteException($Exception) {
    Write-Error -Message 'There was a problem setting the resource'
    Write-Error -Message "$($Exception.InvocationInfo.ScriptName)($($Exception.InvocationInfo.ScriptLineNumber)): $($Exception.InvocationInfo.Line)"
    if ($Exception -is [System.Management.Automation.ErrorRecord]) {
        Write-Error -ErrorRecord $Exception
    } else {
        Write-Error -Exception $Exception
    }    
}

function Test-Quota {

}

function Test-SmbShare {

}

Export-ModuleMember -Function *
