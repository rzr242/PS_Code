# param(
#     [Parameter(Mandatory=$true)]
#     [string]$SiteUrl
# )

Import-Module PnP.PowerShell
$SiteUrl = "https://m365x98556761.sharepoint.com/sites/contentTypeHub/"
# Connect to SharePoint using the provided SiteUrl
Connect-PnPOnline -Url $siteUrl -LaunchBrowser -Interactive



# Class representing a site column
class SiteColumn {
    [string]$DisplayName
    [string]$InternalName
    [string]$FieldType
    [string]$Choices
    [bool]$Required
    [string]$Group
}

# Class representing a taxonomy field
class TaxonomyField {
    [string]$DisplayName
    [string]$InternalName
    [string]$TaxonomyItemId
    [string]$Group
    [bool]$Required
}

# Class representing a content type
class ContentType {
    [string]$Name
    [string]$Id
    [string]$Group
    [string]$ParentContentTypeId
    # Array of site columns to be added to the content type
    [SiteColumn[]]$SiteColumns
    # Array of taxonomy fields to be added to the content type
    [TaxonomyField[]]$TaxonomyFields
}



# Function to create a content type
function CreateContentType {
    param(
        [ContentType]$ContentTypeDefinition
    )

    $contentType = Get-PnPContentType -Identity $ContentTypeDefinition.Id -ErrorAction SilentlyContinue
    if ($null -eq $contentType) {
        Add-PnPContentType -Name $ContentTypeDefinition.Name -ContentTypeId $ContentTypeDefinition.Id -Group $ContentTypeDefinition.Group
        Write-Host "Content type $($ContentTypeDefinition.Name) created"
        # Add columns to Content Type
        foreach ($siteColumn in $ContentTypeDefinition.SiteColumns) {
            AddSiteColumnToContentType -ContentTypeId $ContentTypeDefinition.Id -SiteColumnDefinition $siteColumn
        }
        # Add taxonomy fields to Content Type
        foreach ($taxonomyField in $ContentTypeDefinition.TaxonomyFields) {
            AddTaxonomyFieldToContentType -ContentTypeId $ContentTypeDefinition.Id -TaxonomyField $taxonomyField
        }


    } else {
        Write-Host "Content type $($ContentTypeDefinition.Name) already exists"
    }
}

# Function to add a site column to a content type
function AddSiteColumnToContentType {
    param(
        [string]$ContentTypeId,
        [SiteColumn]$SiteColumnDefinition
    )

    $siteColumn = Get-PnPField -Identity $SiteColumnDefinition.InternalName -ErrorAction SilentlyContinue
    if ($null -eq $siteColumn) {
        Write-Host "Site column $($SiteColumnDefinition.DisplayName) not found, creating it first"
        AddFieldToSite -SiteColumn $SiteColumnDefinition
        $siteColumn = Get-PnPField -Identity $SiteColumnDefinition.InternalName
        Add-PnPFieldToContentType -Field $siteColumn -ContentType $ContentTypeId -Required:$SiteColumnDefinition.Required
        Write-Host "Site column $($SiteColumnDefinition.DisplayName) added to content type $ContentTypeId"    
    } else {
        Add-PnPFieldToContentType -Field $siteColumn -ContentType $ContentTypeId -Required:$SiteColumnDefinition.Required 
        Write-Host "Site column $($SiteColumnDefinition.DisplayName) added to content type $ContentTypeId"        
    }
}

# Function to add a taxonomy field to a content type
function AddTaxonomyFieldToContentType {
    param(
        [string]$ContentTypeId,
        [TaxonomyField]$TaxonomyField
    )

    $siteColumn = Get-PnPField -Identity $TaxonomyField.InternalName -ErrorAction SilentlyContinue
    if ($null -eq $siteColumn) {
        Write-Host "Site column $($TaxonomyField.DisplayName) not found, creating it first"
        AddTaxonomyFieldToSite -TaxField $TaxonomyField
        $siteColumn = Get-PnPField -Identity $TaxonomyField.InternalName
        Add-PnPFieldToContentType -Field $siteColumn -ContentType $ContentTypeId -Required:$SiteColumnDefinition.Required
        Write-Host "Site column $($TaxonomyField.DisplayName) added to content type $ContentTypeId"    
    } else {
        Add-PnPFieldToContentType -Field $siteColumn -ContentType $ContentTypeId -Required:$SiteColumnDefinition.Required 
        Write-Host "Site column $($TaxonomyField.DisplayName) added to content type $ContentTypeId"        
    }
}

# Function to add a field to a site
function AddFieldToSite {
    param(
        [SiteColumn]$SiteColumn
    )

    $field = Get-PnPField -Identity $SiteColumn.InternalName -ErrorAction SilentlyContinue
    if ($null -eq $field) {
        switch ($SiteColumn.FieldType) {
            Choice {  Add-PnPField -DisplayName $SiteColumn.DisplayName -InternalName $SiteColumn.InternalName -Type $SiteColumn.FieldType -Group $SiteColumn.Group -Choices $Choices }            
            Default { Add-PnPField -DisplayName $SiteColumn.DisplayName -InternalName $SiteColumn.InternalName -Type $SiteColumn.FieldType -Group $Group}
        }
    
        Write-Host "Field $($SiteColumn.DisplayName) created"
        
    } else {
        Write-Host "Field $($SiteColumn.DisplayName) already exists"
    }
}

# Function to add a taxonomy field to a site
function AddTaxonomyFieldToSite {
    param(
        [TaxonomyField]$TaxField
    )

    $field = Get-PnPField -Identity $TaxField.InternalName -ErrorAction SilentlyContinue
    if ($null -eq $field) {
        Add-PnPTaxonomyField -DisplayName $TaxField.DisplayName -InternalName $TaxField.InternalName -TaxonomyItemId $TaxField.TaxonomyItemId -Group $TaxField.Group
        Write-Host "Taxonomy field $($TaxField.DisplayName) created"
    } else {
        Write-Host "Taxonomy field $($TaxField.DisplayName) already exists"
    }
}


# List of field types

    # Text
    # Note
    # Number
    # DateTime
    # Boolean
    # Choice
    # URL
    # User


# Common property for Group name for columns and Content types
$group = "Svenska Handelsbanken"

# Array of content types to be created
$contentTypes = @(
    [ContentType]@{Name = "SHB Page"; Id = "0x0101009D1CB255DA76424F860D91F20E6C411801"; Group = $group; ParentContentTypeId = "0x0101009D1CB255DA76424F860D91F20E6C4118"; 
        SiteColumns = @(
            [SiteColumn]@{DisplayName = "Innehållsägare"; InternalName = "ContentOwner"; FieldType = "User"; Choices = ""; Required = $true; Group = $group; }
            [SiteColumn]@{DisplayName = "Relaterat styrdokument"; InternalName = "RelatedGuidingDoc"; FieldType = "URL"; Choices = ""; Required = $true; Group = $group;}
        ); 
        TaxonomyFields = @(
            [TaxonomyField]@{DisplayName = "Operations"; InternalName = "Operations"; Group = $group; Required = $true; TaxonomyItemId = "907a9c01-b3ea-4887-8184-f91cc3be1500" }
        )
    }
)


#Create non-tax site columns
foreach ($contentType in $contentTypes) {
    CreateContentType -ContentType $contentType
}

Write-Host "Content types created, thank you for using this script" -ForegroundColor Green
