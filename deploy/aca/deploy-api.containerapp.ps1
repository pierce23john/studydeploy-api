#Requires -Version 7.0
<#!
.SYNOPSIS
    Creates or updates the API container app using Azure CLI.

.DESCRIPTION
    Deploys the API container app using api.containerapp.yaml directly with --yaml.
    No template replacements are performed.
#>

param(
    [Parameter(Mandatory = $false)]
    [string]$SubscriptionId,

    [Parameter(Mandatory = $false)]
    [string]$ResourceGroupName = "AZ-LRN-ACA-RG",

    [Parameter(Mandatory = $false)]
    [string]$EnvironmentName = "az-lrn-studydeploy-env",

    [Parameter(Mandatory = $false)]
    [string]$AppName = "studydeploy-api"
)

$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$yamlPath = Join-Path $scriptDir "api.containerapp.exported.yaml"

if (-not (Test-Path $yamlPath)) {
    throw "YAML file not found: $yamlPath"
}

Write-Host "======================================"
Write-Host "Deploy API Container App"
Write-Host "======================================"

if ($SubscriptionId) {
    az account set --subscription $SubscriptionId
}

$null = az --version

$rgExists = az group exists --name $ResourceGroupName
if ($rgExists -eq "false") {
    throw "Resource group not found: $ResourceGroupName"
}

if (-not $AppName) {
    $yamlNameMatch = Select-String -Path $yamlPath -Pattern '^name:\s*(.+)$'
    if (-not $yamlNameMatch) {
        throw "Could not determine app name from YAML. Set -AppName or add a top-level name in $yamlPath."
    }

    $AppName = $yamlNameMatch.Matches[0].Groups[1].Value.Trim()
}

$exists = az containerapp show --name $AppName --resource-group $ResourceGroupName --query "name" -o tsv 2>$null

if (-not $exists) {
    Write-Host "Creating $AppName using --yaml ..."
    az containerapp create `
        --name $AppName `
        --resource-group $ResourceGroupName `
        --environment $EnvironmentName `
        --yaml $yamlPath
}
else {
    Write-Host "Updating $AppName using --yaml ..."
    az containerapp update `
        --name $AppName `
        --resource-group $ResourceGroupName `
        --yaml $yamlPath
}

$fqdn = az containerapp show --name $AppName --resource-group $ResourceGroupName --query "properties.configuration.ingress.fqdn" -o tsv
Write-Host "API deployed: https://$fqdn" -ForegroundColor Green
