Import-Module PnP.PowerShell

Connect-PnPOnline -Url "https://m365x98556761.sharepoint.com/sites/contentTypeHub/" -LaunchBrowser -Interactive


# Function to create a content type
function CreateContentType {
    param(
        [string]$ContentTypeName,
        [string]$ContentTypeId,
        [string]$ContentTypeGroup,
        [string]$ParentContentTypeId
    )

    $contentType = Get-PnPContentType -Identity $ContentTypeId -ErrorAction SilentlyContinue
    if ($null -eq $contentType) {
        Add-PnPContentType -Name $ContentTypeName -Id $ContentTypeId -Group $ContentTypeGroup -ParentContentType $ParentContentTypeId
        Write-Host "Content type $ContentTypeName created"
    } else {
        Write-Host "Content type $ContentTypeName already exists"
    }
}

# Function to add a site column to a content type
function AddSiteColumnToContentType {
    param(
        [string]$ContentTypeId,
        [string]$SiteColumnName,
        [bool]$Required
    )

    $siteColumn = Get-PnPSiteColumn -Identity $SiteColumnName -ErrorAction SilentlyContinue
    if ($null -ne $siteColumn) {
        Add-PnPFieldToContentType -Field $siteColumn -ContentType $ContentTypeId -Required $Required -UpdateChildren $true
        Write-Host "Site column $SiteColumnName added to content type $ContentTypeId"
    } else {
        Write-Host "Site column $SiteColumnName not found"
    }
}


# Add-PnPTaxonomyField -DisplayName "My Managed Metadata Field 2" -InternalName "MyManagedMetadataField2" -TaxonomyItemId "907a9c01-b3ea-4887-8184-f91cc3be1500" -Id 6A15ADB5-DA89-4E75-993E-CB13D435D179 -Group "My Group"

