#$AzureCredential = Get-Credential -Message 'AzureAdmin' -UserName 'user@irgendwas.onmicrosoft.com'

if ($AzureSubscription -eq $null) {
    Add-AzureRmAccount
    $AzureSubscription = Get-AzureRMSubscription | Out-GridView -Title 'Select Azure Subscription' -OutputMode Single
}

Set-AzureRmContext -SubscriptionId $AzureSubscription.SubscriptionId

$DeploymentName = (New-Guid).Guid
$AzureResourceGroupName = 'CWVNetPeering01'
$AzureLocation = 'West Europe'


New-AzureRmResourceGroup -Name $AzureResourceGroupName -Location $AzureLocation -Force

#Find templates in current directory
$Templates = Get-ChildItem -Path $PSScriptRoot -Recurse -File | Where-Object { ($_.Extension -eq '.json') -and ($_.Name -NotLike '*parameter*') }
if ($Templates -is [System.Array]) {
    $Template = $Templates | Out-GridView -Title 'Select Template' -OutputMode Single
} else {
    $Template = $Templates
}

#Find Template Configs in current directory

$TemplateConfigs = Get-ChildItem -Path $PSScriptRoot -Recurse -File | Where-Object Name -like '*.parameter.json'
if ($TemplateConfigs -is [System.Array]) {
    $TemplateConfig = $TemplateConfigs | Out-GridView -Title 'Select TemplateConfig' -OutputMode Single
} else {
    $TemplateConfig = $TemplateConfigs
}


New-AzureRMResourceGroupDeployment -Name $DeploymentName `
                                   -ResourceGroupName $AzureResourceGroupName `
                                   -TemplateFile $Template.FullName `
                                   -TemplateParameterFile $TemplateConfig.FullName `
                                   -Force `
                                   -Mode Incremental `
                                   -Verbose `
                                   -DeploymentDebugLogLevel All


#Get-AzureRmResourceGrou p -Name $AzureResourceGroupName | Remove-AzureRmResourceGroup