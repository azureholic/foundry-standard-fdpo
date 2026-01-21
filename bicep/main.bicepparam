using './main.bicep'

// Core resource names
param name = 'rbrfoundry-test-005'
param location = 'swedencentral'
param defaultProjectName = 'proj-default'

// Monitoring
param logAnalyticsWorkspaceName = 'log-rbrfoundry-test-005'
param applicationInsightsName = 'appi-rbrfoundry-test-005'

// AI Services
param aiSearchName = 'srch-rbrfoundry-test-005'

// Storage
param storageAccountName = 'stfdryrbrtest005'
// Database
param cosmosDbName = 'cosmos-foundry-test-005'
// Tags
param tagValues = {
  Environment: 'Test'
  ManagedBy: 'Bicep'
  Project: 'AI Foundry'
}
