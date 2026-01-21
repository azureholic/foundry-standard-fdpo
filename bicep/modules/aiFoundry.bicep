@description('Azure AI Foundry account name')
param name string

@description('Location for the resource')
param location string

@description('Tags to apply to the resource')
param tags object = {}

@description('Default project name')
param defaultProjectName string

@description('SKU name for the AI Foundry account')
param skuName string = 'S0'

@description('Enable public network access')
param publicNetworkAccess bool = true

@description('Embedding model name')
param embeddingModelName string = 'text-embedding-3-small'

@description('Embedding model version')
param embeddingModelVersion string = '1'

@description('Embedding deployment name')
param embeddingDeploymentName string = 'text-embedding-3-small'

@description('Embedding deployment capacity (TPM in thousands)')
param embeddingDeploymentCapacity int = 120

// AI Foundry Account (Cognitive Services)
resource aiFoundryAccount 'Microsoft.CognitiveServices/accounts@2025-04-01-preview' = {
  name: name
  location: location
  tags: tags
  sku: {
    name: skuName
  }
  kind: 'AIServices'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    apiProperties: {}
    customSubDomainName: name
    allowProjectManagement: true
    networkAcls: {
      defaultAction: publicNetworkAccess ? 'Allow' : 'Deny'
      ipRules: []
      virtualNetworkRules: []
    }
    publicNetworkAccess: publicNetworkAccess ? 'Enabled' : 'Disabled'
    restrictOutboundNetworkAccess: false
    disableLocalAuth: false
  }
}

// AI Foundry Project
resource aiFoundryProject 'Microsoft.CognitiveServices/accounts/projects@2025-04-01-preview' = {
  parent: aiFoundryAccount
  name: defaultProjectName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    description: 'Default AI Foundry project with managed identity authentication'
    displayName: defaultProjectName
  }
}

// Embedding Model Deployment
resource embeddingDeployment 'Microsoft.CognitiveServices/accounts/deployments@2025-04-01-preview' = {
  parent: aiFoundryAccount
  name: embeddingDeploymentName
  sku: {
    name: 'GlobalStandard'
    capacity: embeddingDeploymentCapacity
  }
  properties: {
    model: {
      format: 'OpenAI'
      name: embeddingModelName
      version: embeddingModelVersion
    }
    versionUpgradeOption: 'OnceNewDefaultVersionAvailable'
    raiPolicyName: 'Microsoft.DefaultV2'
  }
}

output resourceId string = aiFoundryAccount.id
output name string = aiFoundryAccount.name
output principalId string = aiFoundryAccount.identity.principalId
output endpoint string = aiFoundryAccount.properties.endpoint
output projectResourceId string = aiFoundryProject.id
output projectPrincipalId string = aiFoundryProject.identity.principalId
output embeddingDeploymentName string = embeddingDeployment.name
