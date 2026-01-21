@description('AI Foundry account name')
param accountName string

@description('Project name')
param projectName string

@description('Cosmos DB connection name (project level)')
param cosmosDbConnectionName string

@description('Storage connection name (project level)')
param storageConnectionName string

@description('AI Search connection name (project level)')
param aiSearchConnectionName string

// Reference to existing AI Foundry account
resource account 'Microsoft.CognitiveServices/accounts@2025-04-01-preview' existing = {
  name: accountName
}

// Reference to existing project
resource project 'Microsoft.CognitiveServices/accounts/projects@2025-04-01-preview' existing = {
  name: projectName
  parent: account
}

// Account-level capability host for Agents
resource accountCapabilityHost 'Microsoft.CognitiveServices/accounts/capabilityHosts@2025-04-01-preview' = {
  name: 'Agents'
  parent: account
  properties: {
    capabilityHostKind: 'Agents'
  }
}

// Project-level capability host for Agents
resource projectCapabilityHost 'Microsoft.CognitiveServices/accounts/projects/capabilityHosts@2025-04-01-preview' = {
  name: 'Agents'
  parent: project
  properties: {
    capabilityHostKind: 'Agents'
    vectorStoreConnections: [aiSearchConnectionName]
    storageConnections: [storageConnectionName]
    threadStorageConnections: [cosmosDbConnectionName]
  }
  dependsOn: [
    accountCapabilityHost
  ]
}

output accountCapabilityHostId string = accountCapabilityHost.id
output projectCapabilityHostId string = projectCapabilityHost.id
