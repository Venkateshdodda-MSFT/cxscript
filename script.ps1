Install-Module -Name Az.* -Scope CurrentUser -Force
Get-InstalledModule -Name Az.ResourceGraph
 
$subscriptions = Get-AzSubscription 
 
$a=@()
 
# Loop through each subscription
 
foreach ($subscription in $subscriptions) {
 
    # Set the current subscription
 
    Set-AzContext -SubscriptionId $subscription.SubscriptionId
 
    $a+=Search-AzGraph -Query "patchinstallationresources| where type has ""softwarepatches"" and properties !has ""version""| extend machineName = tostring(split(id, ""/"", 8)), resourceType = tostring(split(type, ""/"", 0)), tostring(rgName = split(id, ""/"", 4)), tostring(RunID = split(id, ""/"", 10))| extend prop = parse_json(properties)| extend lTime = todatetime(prop.lastModifiedDateTime), patchName = tostring(prop.patchName), kbId = tostring(prop.kbId), installationState = tostring(prop.installationState), classifications = tostring(prop.classifications)| where lTime > ago(30d)| project lTime, RunID, machineName, rgName, resourceType, patchName, kbId, classifications, installationState| sort by RunID" 
 
}
 
$a | Select-Object -Property lTime,RunID,machineName,rgName,resourceType,patchName,kbId,classifications,installationState | Export-Csv ./testgraph.csv
