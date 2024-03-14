param(
    [Parameter(Mandatory=$true)]
    [string]$SiteUrl,

    [Parameter(Mandatory=$true)]
    [string]$ListName,

    [Parameter(Mandatory=$false)]
    [string]$SkipItemName
)

# Import the PnP PowerShell module
Import-Module -Name PnP.PowerShell

# Check if the SkipItemId parameter is provided, otherwise set it to empty string
if ([string]::IsNullOrEmpty($SkipItemName)) {
    $SkipItemName = "Home.aspx"
}



Write-Host "Deleting all items in the list $ListName on the site $SiteUrl except the item with Name $SkipItemName..."

Write-Host "Connecting to SharePoint..."

# Connect to SharePoint using the provided SiteUrl
Connect-PnPOnline -Url $SiteUrl -UseWebLogin

# Get the list by its name
$List = Get-PnPList -Identity $ListName

# Delete all items in the list
$ListItems = Get-PnPListItem -List $List

Write-Host "Found $($ListItems.Count) items in the list $ListName"

# Prompt user to confirm before proceeding
$Confirmation = Read-Host "Are you sure you want to delete $($ListItems.Count) items in the list $ListName on the site $SiteUrl except the item with Name $SkipItemName? (Y/N)"
if ($Confirmation -ne "Y") {
    Write-Host "Operation cancelled by user."
    return
}

# Loop through all items in the list and delete them
#Function to delete all items in a folder - and sub-folders recursively
Function Remove-AllFilesFromFolder($Folder, $SkipName)
{
    #Get the site relative path of the Folder
    If($Folder.Context.web.ServerRelativeURL -eq "/")
    {
        $FolderSiteRelativeURL = $Folder.ServerRelativeUrl
    }
    Else
    {       
        $FolderSiteRelativeURL = $Folder.ServerRelativeUrl.Replace($Folder.Context.web.ServerRelativeURL,[string]::Empty)
    }
 
    #Get All files in the folder
    $Files = Get-PnPFolderItem -FolderSiteRelativeUrl $FolderSiteRelativeURL -ItemType File

    $countFiles = $Files.Count
    $progress = 0
    $processed = 0

    #Delete all files except the one with SkipName
    ForEach ($File in $Files)
    {
        if ($File.Name -ne $SkipName) {
            #Write-Host ("Deleting File: '{0}' at '{1}'" -f $File.Name, $File.ServerRelativeURL)
             
            #Delete Item
            #Remove-PnPFile -ServerRelativeUrl $File.ServerRelativeURL -Force -Recycle

            $processed++

            # Update progress bar
            $progress = ($processed / $countFiles) * 100
            Write-Progress -Activity "Deleting Files" -Status "Progress: $progress%" -PercentComplete $progress
        }
    }
 
    #Process all Sub-Folders
    $SubFolders = Get-PnPFolderItem -FolderSiteRelativeUrl $FolderSiteRelativeURL -ItemType Folder
    Foreach($Folder in $SubFolders)
    {
        #Exclude "Forms" and Hidden folders
        If( ($Folder.Name -ne "Forms") -and (-Not($Folder.Name.StartsWith("_"))))
        {
            #Call the function recursively
            Remove-AllFilesFromFolder -Folder $Folder -SkipItemId $SkipName
        }
    }
}


Remove-AllFilesFromFolder -Folder $List.RootFolder -SkipItemId $SkipItemName
# Disconnect from SharePoint
Disconnect-PnPOnline