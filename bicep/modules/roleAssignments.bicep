@description('AI Foundry Project principal ID (System Assigned MI)')
param aiFoundryProjectPrincipalId string

@description('AI Search name')
param aiSearchName string

@description('Storage account name')
param storageAccountName string

@description('Cosmos DB name')
param cosmosDbName string

@description('AI Foundry account name')
param aiFoundryName string

@description('AI Search principal ID (System Assigned MI)')
param aiSearchPrincipalId string

// Reference existing resources for scope
resource aiSearch 'Microsoft.Search/searchServices@2024-06-01-preview' existing = {
  name: aiSearchName
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' existing = {
  name: storageAccountName
}

resource cosmosDb 'Microsoft.DocumentDB/databaseAccounts@2024-05-15' existing = {
  name: cosmosDbName
}

resource aiFoundry 'Microsoft.CognitiveServices/accounts@2025-04-01-preview' existing = {
  name: aiFoundryName
}

// Built-in Azure RBAC Role Definition IDs
var cognitiveServicesOpenAIUserRole = '5e0bd9bd-7b93-4f28-af87-19fc36ad61bd' // Cognitive Services OpenAI User
var searchIndexDataContributorRole = '8ebe5a00-799e-43f5-93ac-243d3dce84a7' // Search Index Data Contributor
var searchServiceContributorRole = '7ca78c08-252a-4471-8644-bb5ff32d4ba0' // Search Service Contributor
var storageBlobDataContributorRole = 'ba92f5b4-2d11-453d-a403-e96b0029c9fe' // Storage Blob Data Contributor
var storageBlobDataOwnerRole = 'b7e6dc6d-f1e8-4753-8033-0f276bb0955b' // Storage Blob Data Owner
var storageQueueDataContributorRole = '974c5e8b-45b9-4653-ba55-5f855dd0fb88' // Storage Queue Data Contributor
var cosmosDBAccountReaderRole = 'fbdf93bf-df7d-467e-a4d2-9458aa1360c8' // Cosmos DB Account Reader Role
var cosmosDBDataContributorRole = '00000000-0000-0000-0000-000000000002' // Cosmos DB Built-in Data Contributor
var cosmosDBOperatorRole = '230815da-be43-4aae-9cb4-875f7bd000aa' // Cosmos DB Operator (control plane)

// ========================================
// AI Search Role Assignments
// ========================================

// Grant AI Search access to Storage (Blob Data Reader) for indexing
resource storageBlobDataReaderRoleSearch 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(storageAccount.id, 'Storage Blob Data Reader', aiSearchPrincipalId)
  scope: storageAccount
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '2a2b9908-6ea1-4ae2-8e65-a410df84e7d1') // Storage Blob Data Reader
    principalId: aiSearchPrincipalId
    principalType: 'ServicePrincipal'
  }
}

// Grant AI Search access to AI Foundry (Cognitive Services OpenAI User) for embedding vectorization
resource cognitiveServicesOpenAIUserRoleSearch 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(aiFoundry.id, cognitiveServicesOpenAIUserRole, aiSearchPrincipalId)
  scope: aiFoundry
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', cognitiveServicesOpenAIUserRole)
    principalId: aiSearchPrincipalId
    principalType: 'ServicePrincipal'
  }
}

// ========================================
// AI Foundry Project Role Assignments
// ========================================

// Grant Project access to AI Search (Index Data Contributor)
resource searchIndexDataContributorRoleProject 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(aiSearch.id, searchIndexDataContributorRole, aiFoundryProjectPrincipalId)
  scope: aiSearch
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', searchIndexDataContributorRole)
    principalId: aiFoundryProjectPrincipalId
    principalType: 'ServicePrincipal'
  }
}

// Grant Project access to AI Search (Service Contributor)
resource searchServiceContributorRoleProject 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(aiSearch.id, searchServiceContributorRole, aiFoundryProjectPrincipalId)
  scope: aiSearch
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', searchServiceContributorRole)
    principalId: aiFoundryProjectPrincipalId
    principalType: 'ServicePrincipal'
  }
}

// Grant Project access to Storage (Blob Data Contributor)
resource storageBlobDataContributorRoleProject 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(storageAccount.id, storageBlobDataContributorRole, aiFoundryProjectPrincipalId)
  scope: storageAccount
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', storageBlobDataContributorRole)
    principalId: aiFoundryProjectPrincipalId
    principalType: 'ServicePrincipal'
  }
}

// Grant Project access to Storage (Blob Data Owner)
resource storageBlobDataOwnerRoleProject 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(storageAccount.id, storageBlobDataOwnerRole, aiFoundryProjectPrincipalId)
  scope: storageAccount
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', storageBlobDataOwnerRole)
    principalId: aiFoundryProjectPrincipalId
    principalType: 'ServicePrincipal'
  }
}

// Grant Project access to Storage (Queue Data Contributor)
resource storageQueueDataContributorRoleProject 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(storageAccount.id, storageQueueDataContributorRole, aiFoundryProjectPrincipalId)
  scope: storageAccount
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', storageQueueDataContributorRole)
    principalId: aiFoundryProjectPrincipalId
    principalType: 'ServicePrincipal'
  }
}

// Grant Project access to Cosmos DB (Account Reader for metadata)
resource cosmosDBAccountReaderRoleProject 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(cosmosDb.id, cosmosDBAccountReaderRole, aiFoundryProjectPrincipalId)
  scope: cosmosDb
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', cosmosDBAccountReaderRole)
    principalId: aiFoundryProjectPrincipalId
    principalType: 'ServicePrincipal'
  }
}

// Grant Project access to Cosmos DB (Operator for control plane - create databases/containers)
resource cosmosDBOperatorRoleProject 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(cosmosDb.id, cosmosDBOperatorRole, aiFoundryProjectPrincipalId)
  scope: cosmosDb
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', cosmosDBOperatorRole)
    principalId: aiFoundryProjectPrincipalId
    principalType: 'ServicePrincipal'
  }
}

// Grant Project access to Cosmos DB (Built-in Data Contributor for data plane operations)
resource cosmosDBDataContributorRoleProject 'Microsoft.DocumentDB/databaseAccounts/sqlRoleAssignments@2024-05-15' = {
  name: guid(cosmosDb.id, cosmosDBDataContributorRole, aiFoundryProjectPrincipalId)
  parent: cosmosDb
  properties: {
    roleDefinitionId: '${cosmosDb.id}/sqlRoleDefinitions/${cosmosDBDataContributorRole}'
    scope: cosmosDb.id
    principalId: aiFoundryProjectPrincipalId
  }
}

output searchIndexDataContributorRoleAssignment string = searchIndexDataContributorRoleProject.id
output searchServiceContributorRoleAssignment string = searchServiceContributorRoleProject.id
output storageBlobDataContributorRoleAssignment string = storageBlobDataContributorRoleProject.id
output storageBlobDataOwnerRoleAssignment string = storageBlobDataOwnerRoleProject.id
output storageQueueDataContributorRoleAssignment string = storageQueueDataContributorRoleProject.id
output cosmosDBAccountReaderRoleAssignment string = cosmosDBAccountReaderRoleProject.id
output cosmosDBOperatorRoleAssignment string = cosmosDBOperatorRoleProject.id
output storageBlobDataReaderRoleAssignmentSearch string = storageBlobDataReaderRoleSearch.id
output cognitiveServicesOpenAIUserRoleAssignmentSearch string = cognitiveServicesOpenAIUserRoleSearch.id
