@description('Cosmos DB account name')
param name string

@description('Location for the resource')
param location string

@description('Database name for agent threads')
param databaseName string = 'AgentThreads'

resource cosmosDb 'Microsoft.DocumentDB/databaseAccounts@2024-05-15' = {
  name: name
  location: location
  kind: 'GlobalDocumentDB'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    consistencyPolicy: {
      defaultConsistencyLevel: 'Session'
    }
    locations: [
      {
        locationName: location
        failoverPriority: 0
        isZoneRedundant: false
      }
    ]
    databaseAccountOfferType: 'Standard'
    enableAutomaticFailover: false
    enableMultipleWriteLocations: false
    disableLocalAuth: false // Allow both AAD and key-based auth during transition
    publicNetworkAccess: 'Enabled'
  }
}

// Database for Foundry Agent Threads (Standard Agent Setup)
resource database 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2024-05-15' = {
  parent: cosmosDb
  name: databaseName
  properties: {
    resource: {
      id: databaseName
    }
    options: {
      throughput: 400 // Shared throughput across containers
    }
  }
}

// Container 1: End-user messages
resource threadMessageStore 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2024-05-15' = {
  parent: database
  name: 'thread-message-store'
  properties: {
    resource: {
      id: 'thread-message-store'
      partitionKey: {
        paths: ['/threadId']
        kind: 'Hash'
      }
      indexingPolicy: {
        indexingMode: 'consistent'
        automatic: true
        includedPaths: [
          {
            path: '/*'
          }
        ]
      }
    }
  }
}

// Container 2: Internal/system messages
resource systemThreadMessageStore 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2024-05-15' = {
  parent: database
  name: 'system-thread-message-store'
  properties: {
    resource: {
      id: 'system-thread-message-store'
      partitionKey: {
        paths: ['/threadId']
        kind: 'Hash'
      }
      indexingPolicy: {
        indexingMode: 'consistent'
        automatic: true
        includedPaths: [
          {
            path: '/*'
          }
        ]
      }
    }
  }
}

// Container 3: Agent inputs, outputs, metadata
resource agentEntityStore 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2024-05-15' = {
  parent: database
  name: 'agent-entity-store'
  properties: {
    resource: {
      id: 'agent-entity-store'
      partitionKey: {
        paths: ['/id']
        kind: 'Hash'
      }
      indexingPolicy: {
        indexingMode: 'consistent'
        automatic: true
        includedPaths: [
          {
            path: '/*'
          }
        ]
      }
    }
  }
}

output resourceId string = cosmosDb.id
output name string = cosmosDb.name
output endpoint string = cosmosDb.properties.documentEndpoint
output principalId string = cosmosDb.identity.principalId
output databaseName string = database.name
