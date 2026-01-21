using './main.bicep'

// Core resource names
param name = 'rbrfoundry-test-003'
param location = 'swedencentral'
param defaultProjectName = 'proj-default'

// Monitoring
param logAnalyticsWorkspaceName = 'log-rbrfoundry-test-003'
param applicationInsightsName = 'appi-rbrfoundry-test-003'

// AI Services
param aiSearchName = 'srch-rbrfoundry-test-003'

// Storage
param storageAccountName = 'stfdryrbrtest003'
// Database
param cosmosDbName = 'cosmos-foundry-test-003'
// Tags
param tagValues = {
  Environment: 'Test'
  ManagedBy: 'Bicep'
  Project: 'AI Foundry'
}
