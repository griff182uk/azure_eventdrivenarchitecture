function Connect-DgAzure {
    <#
    .SYNOPSIS
    Connects to Azure subscription.

    .DESCRIPTION
    Connects to Azure subscription.

    .PARAMETER SUbscription
    Name of Azure subscription to connect to.

    .EXAMPLE
    $subscription = 'dataGriff Teaching'
    Connect-DgAzure -subscription $subscription

#>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [String]$subscription
    )
    Write-Host("Start Connect-DgAzure...")

    if ([string]::IsNullOrEmpty($(Get-AzContext).Account)) {    
        Connect-AzAccount
    }
    Set-AzContext -Subscription $subscription

    Write-Host("Completed Connect-DgAzure.")
}

function Get-DgAzureRegionShortCode {
    <#
    .SYNOPSIS
    Returns a region shortcode string for region.

    .DESCRIPTION
    Returns a region shortcode string for region.

    .PARAMETER Region
    Name of Azure region.

    .EXAMPLE
    $region = 'northeurope'
    Get-DgAzureRegionShortCode -region $region

#>
    [CmdletBinding()]
    param (
        [ValidateSet("northeurope", "westeurope")]
        [Parameter(Mandatory = $true)]
        [String]$region
    )

    Write-Host("Start Get-DgAzureRegionShortCode...")

    switch ( $region ) {
        'northeurope' { $regionshortcode = 'eun' }
        'westeurope' { $regionshortcode = 'euw' }
    }

    Write-Host("Completed Get-DgAzureRegionShortCode.")
             
    return $regionshortcode
}

function Get-DgAzureResourceTypeShortCode {
    <#
    .SYNOPSIS
    Returns a resource type shortcode string for region.

    .DESCRIPTION
    Returns a resource type shortcode string for region.

    .PARAMETER Resource Type
    Name of Azure resource type.

    .EXAMPLE
    $resourceType = 'storageaccount'
    Get-DgAzureResourceTypeShortCode -resourceType $resourceType

#>
    [CmdletBinding()]
    param (
        [ValidateSet("cosmos","storage","virtualnetwork", "eventhub","databricks","function","logicapp","datafactory","sql","keyvault")]
        [Parameter(Mandatory = $true)]
        [String]$resourceType
    )

    Write-Host("Start Get-DgAzureResourceTypeShortCode...")

    switch ( $resourceType ) {
        'cosmos' { $resourceTypeShortCode = 'cosdb' }
        'storage' { $resourceTypeShortCode = 'sa' }
        'virtualnetwork' { $resourceTypeShortCode = 'vnet' }
        'eventhub' { $resourceTypeShortCode = 'eh' }
        'databricks' { $resourceTypeShortCode = 'dbw' }
        'function' { $resourceTypeShortCode = 'azfn' }
        'logicapp' { $resourceTypeShortCode = 'la' }
        'datafactory' { $resourceTypeShortCode = 'adf' }
        'sql' { $resourceTypeShortCode = 'sql' }
        'keyvault' { $resourceTypeShortCode = 'kv' }
    }

    Write-Host("Completed Get-DgAzureResourceTypeShortCode.")
             
    return $resourceTypeShortCode
}


function Get-DgAzureResourceName {
    <#
    .SYNOPSIS
    Returns a resource name meeting naming standards.

    .DESCRIPTION
    Returns a resource name meeting naming standards.

    .PARAMETER Subscription
    Name of Azure subscription to connect to.

    .EXAMPLE
    $uniqueNamespace = [System.Environment]::GetEnvironmentVariable('AZURE_UNIQUE_NAMESPACE')
    $resourcetype = 'eventhub'
    $region = 'northeurope'
    $environment = 'dv'
    $service = 'events001'
    Get-DgAzureResourceName -uniqueNamespace $uniqueNamespace `
    -resourcetype $resourcetype `
    -region $region `
    -environment $environment `
    -service $service

    $uniqueNamespace = [System.Environment]::GetEnvironmentVariable('AZURE_UNIQUE_NAMESPACE')
    $resourcetype = 'storage'
    $region = 'northeurope'
    $environment = 'dv'
    $service = 'events001'
    Get-DgAzureResourceName -uniqueNamespace $uniqueNamespace `
    -resourcetype $resourcetype `
    -region $region `
    -environment $environment `
    -service $service
#>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [String]$uniqueNamespace,
        [Parameter(Mandatory = $true)]
        [String]$resourcetype,
        [Parameter(Mandatory = $true)]
        [String]$region,
        [ValidateSet("dv","qa","lv")]
        [Parameter(Mandatory = $true)]
        [String]$environment,
        [Parameter(Mandatory = $true)]
        [String]$service
    )
    Write-Host("Start Get-DgAzureResourceName...")

    $regionShortCode = Get-DgAzureRegionShortCode($region)
    $resourceTypeShortCode = Get-DgAzureResourceTypeShortCode($resourceType)

    if($resourcetype -in ('keyvault','storage')){
        $resourceName = "$environment$service$resourceTypeShortCode$regionShortCode$uniqueNamespace"
    }
    else {
        $resourceName = "$environment-$service-$resourceTypeShortCode-$regionShortCode-$uniqueNamespace"
    }

    Write-Host("Completed Get-DgAzureResourceName.")
             
    return $resourceName
}

