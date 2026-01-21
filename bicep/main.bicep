@description('The name of the AI Foundry')
param name string

@description('Location for all resources')
param location string = resourceGroup().location

@description('Tags to apply to resources')
param tagValues object = {}

@description('Default project name')
param defaultProjectName string

@description('Application Insights name')
param applicationInsightsName string

@description('Log Analytics workspace name')
param logAnalyticsWorkspaceName string

@description('AI Search service name')
param aiSearchName string

@description('Storage account name')
param storageAccountName string

@description('Cosmos DB account name')
param cosmosDbName string

@description('Embedding model name')
param embeddingModelName string = 'text-embedding-3-small'

@description('Embedding model version')
param embeddingModelVersion string = '1'

@description('Embedding deployment name')
param embeddingDeploymentName string = 'text-embedding-3-small'

@description('Embedding deployment capacity (TPM in thousands)')
param embeddingDeploymentCapacity int = 120

// Module 1: Log Analytics Workspace
module logAnalytics 'modules/logAnalytics.bicep' = {
  name: 'logAnalytics-deployment'
  params: {
    name: logAnalyticsWorkspaceName
    location: location
    tags: tagValues[?'Microsoft.OperationalInsights/workspaces'] ?? {}
  }
}

// Module 2: Application Insights
module appInsights 'modules/appInsights.bicep' = {
  name: 'appInsights-deployment'
  params: {
    name: applicationInsightsName
    location: location
    tags: tagValues[?'Microsoft.Insights/components'] ?? {}
    workspaceResourceId: logAnalytics.outputs.resourceId
  }
}

// Module 3: AI Search
module aiSearch 'modules/aiSearch.bicep' = {
  name: 'aiSearch-deployment'
  params: {
    name: aiSearchName
    location: location
  }
}

// Module 4: Storage Account (for agent data)
module storageAccount 'modules/storageAccount.bicep' = {
  name: 'storageAccount-deployment'
  params: {
    name: storageAccountName
    location: location
  }
}

// Module 5: Cosmos DB
module cosmosDb 'modules/cosmosDb.bicep' = {
  name: 'cosmosDb-deployment'
  params: {
    name: cosmosDbName
    location: location
  }
}

// Module 6: AI Foundry (Modern Resource) with System Assigned MI
module aiFoundry 'modules/aiFoundry.bicep' = {
  name: 'aiFoundry-deployment'
  params: {
    name: name
    location: location
    tags: tagValues[?'Microsoft.CognitiveServices/accounts'] ?? {}
    defaultProjectName: defaultProjectName
    embeddingModelName: embeddingModelName
    embeddingModelVersion: embeddingModelVersion
    embeddingDeploymentName: embeddingDeploymentName
    embeddingDeploymentCapacity: embeddingDeploymentCapacity
  }
}

// Module 7: Role Assignments for Managed Identity Access
module roleAssignments 'modules/roleAssignments.bicep' = {
  name: 'roleAssignments-deployment'
  params: {
    aiFoundryProjectPrincipalId: aiFoundry.outputs.projectPrincipalId
    aiSearchPrincipalId: aiSearch.outputs.principalId
    aiSearchName: aiSearch.outputs.name
    storageAccountName: storageAccount.outputs.name
    cosmosDbName: cosmosDb.outputs.name
    aiFoundryName: aiFoundry.outputs.name
  }
}

// Module 8: Project Connections for AI Search and Cosmos DB
module projectConnections 'modules/projectConnections.bicep' = {
  name: 'projectConnections-deployment'
  dependsOn: [
    roleAssignments // Ensure role assignments are complete before creating connections
  ]
  params: {
    aiFoundryName: aiFoundry.outputs.name
    projectName: defaultProjectName
    aiSearchResourceId: aiSearch.outputs.resourceId
    aiSearchName: aiSearch.outputs.name
    aiSearchEndpoint: aiSearch.outputs.endpoint
    cosmosDbResourceId: cosmosDb.outputs.resourceId
    cosmosDbName: cosmosDb.outputs.name
    cosmosDbEndpoint: cosmosDb.outputs.endpoint
    applicationInsightsResourceId: appInsights.outputs.resourceId
    applicationInsightsName: applicationInsightsName
    applicationInsightsConnectionString: appInsights.outputs.connectionString
  }
}

// Outputs
output aiFoundryId string = aiFoundry.outputs.resourceId
output aiFoundryName string = aiFoundry.outputs.name
output aiFoundryProjectId string = aiFoundry.outputs.projectResourceId
output embeddingDeploymentName string = aiFoundry.outputs.embeddingDeploymentName
output logAnalyticsWorkspaceId string = logAnalytics.outputs.resourceId
output applicationInsightsId string = appInsights.outputs.resourceId
output aiSearchId string = aiSearch.outputs.resourceId
output storageAccountId string = storageAccount.outputs.resourceId
output cosmosDbId string = cosmosDb.outputs.resourceId
output aiSearchFoundryConnectionId string = projectConnections.outputs.aiSearchFoundryConnectionId
output aiSearchProjectConnectionId string = projectConnections.outputs.aiSearchProjectConnectionId
output cosmosDbFoundryConnectionId string = projectConnections.outputs.cosmosDbFoundryConnectionId
output cosmosDbProjectConnectionId string = projectConnections.outputs.cosmosDbProjectConnectionId
output appInsightsFoundryConnectionId string = projectConnections.outputs.appInsightsFoundryConnectionId
output appInsightsProjectConnectionId string = projectConnections.outputs.appInsightsProjectConnectionId
