#Requires -Version 5.0.0
#Requires -Modules IsilonPlatform

enum Ensure {
    Absent
    Present
}

[DscResource()]
class IsilonQuota {
    [DscProperty(key)]
    [string]$Path

    [DscProperty()]
    [Ensure]$Ensure = [ensure]::Present

    [DscProperty(Mandatory)]
    [string]$Cluster

    [DscProperty(Mandatory)]
    [pscredential]$Credential

    [DscProperty()]
    [ValidateSet('directory', 'user', 'group', 'default-user', 'default-group')]
    [string]$Type = 'directory'

    [DscProperty()]
    [bool]$ShowQuotaSize = $true

    [DscProperty()]
    [bool]$Enforced = $true

    [DscProperty()]
    [string]$AccessZone

    [DscProperty()]
    [bool]$IncludeOverhead = $false

    [DscProperty()]
    [bool]$IncludeSnapshots = $false

    [DscProperty()]
    [bool]$Force = $false

    [DscProperty()]
    [hashtable]$Thresholds

    [DscProperty(NotConfigurable)]
    [string]$Id

    [DscProperty(NotConfigurable)]
    [bool]$Ready

    [DscProperty(NotConfigurable)]
    [int]$Inodes

    [DscProperty(NotConfigurable)]
    [int]$LogicalSize

    [DscProperty(NotConfigurable)]
    [int]$PhysicalSize

    [IsilonQuota]Get() {
        $quota = [IsilonQuota]::new()
        $quota.Path = $this.Path
        $quota.Cluster = $this.Cluster
        $quota.Credential = $this.Credential
        $quota.AccessZone = $this.AccessZone

        if (Login -Cluster $this.Cluster -Credential $this.Credential) {
            Write-Verbose -Message "Getting quota [$($this.Path)]"
            $existingQuota = Get-IsiQuotas -Path $this.Path -Cluster $this.Cluster -ErrorAction SilentlyContinue
            if ($existingQuota) {
                Write-Verbose -Message "Quota found"
                $quota.Ensure = [ensure]::Present
                $quota.Id = $existingQuota.Id
                $quota.ShowQuotaSize = $existingQuota.container
                $quota.Enforced = $existingQuota.enfored
                $quota.Type = $existingQuota.type
                $quota.IncludeOverhead = $existingQuota.threshold_include_overhead
                $quota.IncludeSnapshots = $existingQuota.include_snapshots
                $quota.Thresholds = $existingQuota.thresholds
                $quota.Ready = $existingQuota.ready
                $quota.Inodes = $existingQuota.usage.inodes
                $quota.LogicalSize = $existingQuota.usage.logical
                $quota.PhysicalSize = $existingQuota.usage.physical
            } else {
                Write-Verbose -Message "Quota not found"
                $quota.Ensure = [ensure]::Absent
            }
            return $quota
        } else {
            Write-Error -Message "Unable to log into Isilon [$($this.Cluster)]"
        }
        
        return $quota        
    }

    [void]Set() {
        $quota = $this.Get()
        try {
            switch ($this.Ensure) {
                'Present' {
                    if ($quota.Ensure -eq [ensure]::Present) {
                        # Perform addition checks against quota
                        # TODO
                    } else {
                        # Create quota
                        $params = @{
                            path = $this.Path
                            cluster = $this.Cluster
                            type = $this.Type
                            container = $this.ShowQuotaSize
                            enforced = $this.Enforced
                            force = $this.Force
                            include_snapshots = $this.IncludeSnapshots
                            thresholds_include_overhead = $this.IncludeOverhead
                        }
                        if ($this.AccessZone -ne [string]::empty -and $null -ne $this.AccessZone) {
                            $params.access_zone = $this.AccessZone
                        }
                        New-IsiQuotas @params
                    }                    
                }
                'Absent' {
                    if ($quota.Ensure -eq [ensure]::Present) {
                        # Delete quota
                        # TODO
                    }
                }
            }
        } catch {
            WriteException -Exception $_
        }
    }

    [bool]Test() {
        $quota = $this.Get()
        if ($this.Ensure -ne $quota.Ensure) {
            return $false
        } else {
            # Do the values match?
            # TODO
            $match = $true
            if ($match) {
                return $true
            } else {
                return $false
            }
        }
    }
}

[DscResource()]
class IsilonSmbShare {
    [DscProperty(Key)]
    [string]$Name

    [DscProperty()]
    [Ensure]$Ensure = [ensure]::Present

    [DscProperty(Mandatory)]
    [string]$Path

    [DscProperty(Mandatory)]
    [string]$Cluster

    [DscProperty(Mandatory)]
    [pscredential]$Credential

    [DscProperty()]
    [string]$Description

    [DscProperty()]
    [string]$AccessZone

    [DscProperty(NotConfigurable)]
    [string]$Id

    [IsilonSmbShare]Get() {
        $share = [IsilonSmbShare]::new()
        $share.Name = $this.Name
        $share.Path = $this.Path

        if (Login -Cluster $this.Cluster -Credential $this.Credential) {
            Write-Verbose -Message "Getting share [$($this.Path)]"
            if ($this.AccessZone -ne [string]::Empty -and $null -ne $this.AccessZone) {
                $existingShare = Get-isiSmbSharev3 -Name $this.Name -Cluster $this.Cluster -access_zone $this.AccessZone -ErrorAction SilentlyContinue
            } else {
                $existingShare = Get-isiSmbSharev3 -Name $this.Name -Cluster $this.Cluster -ErrorAction SilentlyContinue
            }

            if ($existingShare) {
                Write-Verbose -Message "Share found"
                $share.Ensure = [ensure]::Present
                $share.Id = $existingShare.id
                $share.Path = $existingShare.path
                $share.Description = $existingShare.description
            } else {
                Write-Verbose -Message "Share not found"
                $share.Ensure = [ensure]::Absent
            }
            return $share
        } else {
            Write-Error -Message "Unable to log into Isilon [$($this.Cluster)]"
        }
        
        return $share        
    }

    [void]Set() {
        $share = $this.Get()
        try {
            switch ($this.Ensure) {
                'Present' {
                    if ($share.Ensure -eq [ensure]::Present) {
                        # Perform addition checks against share
                        # TODO
                    } else {
                        # Create share
                        $params = @{
                            name = $this.Name
                            path = $this.Path
                            cluster = $this.Cluster
                            description = $this.Description
                        }
                        if ($this.AccessZone -ne [string]::empty -and $null -ne $this.AccessZone) {
                            $params.access_zone = $this.AccessZone
                        }
                        New-IsiSmbSharesv3 @params
                    }                    
                }
                'Absent' {
                    if ($share.Ensure -eq [ensure]::Present) {
                        # Delete share
                        # TODO
                    }
                }
            }
        } catch {
            WriteException -Exception $_
        }
    }


    [bool]Test() {
        $share = $this.Get()
        if ($this.Ensure -ne $share.Ensure) {
            return $false
        } else {
            # Do the values match?
            # TODO
            $match = $true
            if ($match) {
                return $true
            } else {
                return $false
            }
        }
    }
}



