@description('AI Foundry account name')
param aiFoundryName string

@description('AI Foundry Project name')
param projectName string

@description('AI Search resource ID')
param aiSearchResourceId string

@description('AI Search name')
param aiSearchName string

@description('AI Search endpoint')
param aiSearchEndpoint string

@description('Cosmos DB resource ID')
param cosmosDbResourceId string

@description('Cosmos DB name')
param cosmosDbName string

@description('Cosmos DB endpoint')
param cosmosDbEndpoint string

@description('Application Insights resource ID')
param applicationInsightsResourceId string

@description('Application Insights name')
param applicationInsightsName string

@description('Application Insights connection string')
@secure()
param applicationInsightsConnectionString string

// Reference to existing AI Foundry
resource aiFoundry 'Microsoft.CognitiveServices/accounts@2025-04-01-preview' existing = {
  name: aiFoundryName
}

// Reference to existing AI Foundry Project
resource aiFoundryProject 'Microsoft.CognitiveServices/accounts/projects@2025-04-01-preview' existing = {
  parent: aiFoundry
  name: projectName
}

// AI Search Connection at Foundry level
resource aiSearchFoundryConnection 'Microsoft.CognitiveServices/accounts/connections@2025-04-01-preview' = {
  parent: aiFoundry
  name: '${aiSearchName}-foundry-connection'
  properties: {
    authType: 'AAD'
    category: 'CognitiveSearch'
    target: aiSearchEndpoint
    useWorkspaceManagedIdentity: true
    isSharedToAll: true
    sharedUserList: []
    peRequirement: 'NotRequired'
    peStatus: 'NotApplicable'
    metadata: {
      displayName: aiSearchName
      type: 'azure_ai_search'
      ApiType: 'Azure'
      ResourceId: aiSearchResourceId
      ApiVersion: '2024-05-01-preview'
      DeploymentApiVersion: '2023-11-01'
    }
  }
}

// AI Search Connection at Project level
resource aiSearchProjectConnection 'Microsoft.CognitiveServices/accounts/projects/connections@2025-04-01-preview' = {
  parent: aiFoundryProject
  name: '${aiSearchName}-proj-connection'
  properties: {
    authType: 'AAD'
    category: 'CognitiveSearch'
    target: aiSearchEndpoint
    useWorkspaceManagedIdentity: true
    isSharedToAll: true
    sharedUserList: []
    peRequirement: 'NotRequired'
    peStatus: 'NotApplicable'
    metadata: {
      displayName: aiSearchName
      type: 'azure_ai_search'
      ApiType: 'Azure'
      ResourceId: aiSearchResourceId
      ApiVersion: '2024-05-01-preview'
      DeploymentApiVersion: '2023-11-01'
    }
  }
}

// Cosmos DB Connection at Foundry level
resource cosmosDbFoundryConnection 'Microsoft.CognitiveServices/accounts/connections@2025-04-01-preview' = {
  parent: aiFoundry
  name: '${cosmosDbName}-foundry-connection'
  properties: {
    authType: 'AAD'
    category: 'CosmosDB'
    target: cosmosDbEndpoint
    useWorkspaceManagedIdentity: true
    isSharedToAll: true
    sharedUserList: []
    peRequirement: 'NotRequired'
    peStatus: 'NotApplicable'
    metadata: {
      displayName: cosmosDbName
      type: 'azure_cosmos_db'
      ApiType: 'Azure'
      ResourceId: cosmosDbResourceId
      ApiVersion: '2024-05-15'
      DeploymentApiVersion: '2023-11-01'
    }
  }
}

// Application Insights Connection at Foundry level
resource appInsightsFoundryConnection 'Microsoft.CognitiveServices/accounts/connections@2025-04-01-preview' = {
  parent: aiFoundry
  name: '${applicationInsightsName}-foundry-connection'
  properties: {
    authType: 'ApiKey'
    category: 'AppInsights'
    target: applicationInsightsResourceId
    isSharedToAll: true
    sharedUserList: []
    peRequirement: 'NotRequired'
    peStatus: 'NotApplicable'
    credentials: {
      key: applicationInsightsConnectionString
    }
    metadata: {
      ApiType: 'Azure'
      ResourceId: applicationInsightsResourceId
    }
  }
}

// Application Insights Connection at Project level
resource appInsightsProjectConnection 'Microsoft.CognitiveServices/accounts/projects/connections@2025-04-01-preview' = {
  parent: aiFoundryProject
  name: '${applicationInsightsName}-proj-connection'
  properties: {
    authType: 'ApiKey'
    category: 'AppInsights'
    target: applicationInsightsResourceId
    isSharedToAll: true
    sharedUserList: []
    peRequirement: 'NotRequired'
    peStatus: 'NotApplicable'
    credentials: {
      key: applicationInsightsConnectionString
    }
    metadata: {
      ApiType: 'Azure'
      ResourceId: applicationInsightsResourceId
    }
  }
}

// Cosmos DB Connection at Project level
resource cosmosDbProjectConnection 'Microsoft.CognitiveServices/accounts/projects/connections@2025-04-01-preview' = {
  parent: aiFoundryProject
  name: '${cosmosDbName}-proj-connection'
  properties: {
    authType: 'AAD'
    category: 'CosmosDB'
    target: cosmosDbEndpoint
    useWorkspaceManagedIdentity: true
    isSharedToAll: true
    sharedUserList: []
    peRequirement: 'NotRequired'
    peStatus: 'NotApplicable'
    metadata: {
      displayName: cosmosDbName
      type: 'azure_cosmos_db'
      ApiType: 'Azure'
      ResourceId: cosmosDbResourceId
      ApiVersion: '2024-05-15'
      DeploymentApiVersion: '2023-11-01'
    }
  }
}

output aiSearchFoundryConnectionId string = aiSearchFoundryConnection.id
output aiSearchProjectConnectionId string = aiSearchProjectConnection.id
output cosmosDbFoundryConnectionId string = cosmosDbFoundryConnection.id
output cosmosDbProjectConnectionId string = cosmosDbProjectConnection.id
output appInsightsFoundryConnectionId string = appInsightsFoundryConnection.id
output appInsightsProjectConnectionId string = appInsightsProjectConnection.id
