# Login to Azure
Connect-AzAccount

# Change directory to the location of the .cspkg and .cscfg file
cd "C:\Data\Source\MyCloudServiceRepo\CloudServicesDeployment\CloudServiceToDeploy\bin\Debug\app.publish"

# Upload the package file to blob storage and obtain a SAS Uri for the newly created blob
$tokenStartTime = Get-Date 
$tokenEndTime = $tokenStartTime.AddYears(1) 
$storAcc = Get-AzStorageAccount -ResourceGroupName cloudservice-extended-rg -Name cloudserviceext
$cspkgBlob = Set-AzStorageBlobContent -File CloudServiceToDeploy.cspkg -Container psdeploy -Blob CloudServiceToDeploy.cspkg -Context $storAcc.Context -Force
$csPkgToken = New-AzStorageBlobSASToken -Container psdeploy -Blob $cspkgBlob.Name -Permission rwd -StartTime $tokenStartTime -ExpiryTime $tokenEndTime -Context $storAcc.Context
$cspkgUrl = $csPkgBlob.ICloudBlob.Uri.AbsoluteUri + $csPkgToken

# Retrieve the contents of the configuration file
$configuration = Get-Content -Path ServiceConfiguration.Cloud.cscfg | Out-String

# Retrieve the cloud service definition
$cloudService = Get-AzCloudService -ResourceGroupName "cloudservice-extended-rg" -CloudServiceName "cloudservice-extended"

# Update the cloud service
$cloudService.Configuration = $configuration
$cloudService.PackageUrl = $cspkgUrl
$cloudService | Update-AzCloudService