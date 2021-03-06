
param (
    #If this param is not supplied when calling the script then set the cache size to 10GB
    $CacheSize = 10240    
)

function Set-CCMCacheSize {
    <#
    .Synopsis
       Sets the CCMCache to a size of your choosing in MB
    .DESCRIPTION
       Sets the CCMCache to a size of your choosing in MB.  By default, if no parameters are supplied then the cache size is resized to 10GB.
       To use this in Configuration Manager, on the Programs tab on the Deployment Type, set the 'Program' to be: powershell -ExecutionPolicy Bypass -file .\SetCCMCacheSize.ps1 -cachesize 6144
       Where the number after -cacheSize reflects the size in MB that you want the CCMCache size to be.  If you leave out the -CacheSize parameter then the size defaults to 10GB.
    .EXAMPLE
       Set-CCMCacheSize -Size 6144
       Sets the cache size to 6GB (6 * 1024)
    .NOTES
        Created: 06-Nov-2014
        Author: OH
    #>


    [CmdletBinding()]    
    Param
    (        
        [Parameter(Mandatory=$false,
                    ValueFromPipelineByPropertyName=$true,
                    Position=0)]
        [String[]]
        $Computername = 'localhost',
        [int]
        $Size
    )

    foreach ($Computer in $Computername) {          
            write-verbose "Initialising the com object"
            $CCM = New-Object -com UIResource.UIResourceMGR
                
            write-verbose "Setting Cache Size on: $computer ..."  
            ($ccm.GetCacheInfo()).totalsize = $Size             
            Write-verbose "Done`n"

            write-verbose "Updating registry..."
            #Create the reg Key that we will use for checking installation via SCCM
            New-Item -Path HKLM:\System\CSU\CCMCache -force

            #Add size that ccmcache was changed to in MB
            New-ItemProperty -path HKLM:\System\CSU\CCMCache -name 'SizeInMB' -Value $Size -PropertyType string -force
    }
}

#Script entry point
Set-CCMCacheSize -Size $CacheSize
