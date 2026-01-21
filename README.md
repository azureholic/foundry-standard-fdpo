# Azure AI Foundry Infrastructure

Infrastructure as Code (IaC) for deploying a complete Azure AI Foundry environment with integrated services for AI applications and agent development.

## Overview

This Bicep deployment creates a production-ready Azure AI Foundry environment with:

- **Azure AI Foundry** - AI Services account with project management
- **AI Search** - Cognitive search service for RAG patterns
- **Cosmos DB** - NoSQL database for application data
- **Storage Account** - Blob storage with "knowledge" container for document indexing
- **Key Vault** - Secure secrets management
- **Application Insights** - Monitoring and telemetry
- **Embedding Model** - text-embedding-3-small deployment (configurable)

All resources are configured with:
- ✅ **Managed Identity authentication** (keyless)
- ✅ **RBAC role assignments** for secure cross-service access
- ✅ **Service connections** between AI Foundry and dependent resources
- ✅ **Production-ready defaults**

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Azure AI Foundry                         │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  Project (with System Assigned MI)                   │  │
│  │  └─ Embedding Model: text-embedding-3-small          │  │
│  └──────────────────────────────────────────────────────┘  │
│                           │                                  │
│  Connections (AAD Auth):  │                                  │
│  ├─ AI Search ────────────┼─────────────────────────────────┤
│  ├─ Cosmos DB ────────────┼─────────────────────────────────┤
│  └─ Storage Account ──────┼─────────────────────────────────┤
└───────────────────────────┼──────────────────────────────────┘
                            │
              ┌─────────────┴──────────────┐
              │                            │
         ┌────▼─────┐               ┌─────▼──────┐
         │ AI Search│               │  Storage   │
         │          │               │  Account   │
         │ (indexes │◄──────────────┤            │
         │documents)│   reads from  │ Container: │
         └──────────┘               │ knowledge  │
                                    └────────────┘
```

## Prerequisites

- Azure CLI installed and authenticated
- Azure subscription with sufficient permissions
- Resource group created (or use deployment command to create)

## Quick Start

### 1. Review Parameters

Edit `bicep/main.bicepparam` to customize resource names and settings:

```bicep
param name = 'foundry-hub-prod'
param location = 'swedencentral'
param defaultProjectName = 'proj-default'
// ... other parameters
```

### 2. Deploy

```bash
cd bicep

# Preview changes
az deployment group create \
  --resource-group rg-foundry-prod \
  --template-file main.bicep \
  --parameters '@main.bicepparam' \
  --confirm-with-what-if

# Deploy
az deployment group create \
  --resource-group rg-foundry-prod \
  --template-file main.bicep \
  --parameters '@main.bicepparam' \
  --name foundry-deployment
```

### 3. Verify Deployment

```bash
# Get deployment outputs
az deployment group show \
  --resource-group rg-foundry-prod \
  --name foundry-deployment \
  --query properties.outputs
```

## Configuration

### Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `name` | AI Foundry account name | - |
| `location` | Azure region | swedencentral |
| `defaultProjectName` | Project name | proj-default |
| `applicationInsightsName` | App Insights name | - |
| `keyVaultConnectionName` | Key Vault name | - |
| `aiSearchName` | AI Search service name | - |
| `storageAccountName` | Storage account name | - |
| `cosmosDbName` | Cosmos DB account name | - |
| `embeddingModelName` | Embedding model | text-embedding-3-small |
| `embeddingModelVersion` | Model version | 1 |
| `embeddingDeploymentName` | Deployment name | text-embedding-3-small |
| `embeddingDeploymentCapacity` | TPM capacity (thousands) | 120 |

### Customizing Embedding Model

To use a different embedding model:

```bicep
param embeddingModelName = 'text-embedding-3-large'
param embeddingModelVersion = '1'
param embeddingDeploymentCapacity = 80  // Lower TPM for larger model
```

## Resources Deployed

### Module 1: Application Insights
Monitoring and telemetry for all services.

### Module 2: Key Vault
Secure storage for secrets and keys. AI Foundry has Secrets User and Officer roles.

### Module 3: AI Search
Search service with system-assigned managed identity. Has Storage Blob Data Reader role for indexing.

### Module 4: Storage Account
- Includes blob service with "knowledge" container
- Configured for managed identity access
- Used by AI Search for document indexing

### Module 5: Cosmos DB
NoSQL database with system-assigned managed identity and data plane RBAC.

### Module 6: AI Foundry
- AI Services account with project management enabled
- Default project with system-assigned managed identity
- Embedding model deployment

### Module 7: Role Assignments
Configures RBAC permissions:
- **AI Foundry** → Key Vault (Secrets User/Officer)
- **AI Search** → Storage (Blob Data Reader)
- **Project** → AI Search (Index Data Contributor, Service Contributor)
- **Project** → Storage (Blob Data Contributor, Owner, Queue Contributor)
- **Project** → Cosmos DB (Account Reader, Data Contributor)

### Module 8: Project Connections
Creates service connections using AAD authentication:
- AI Search connections (Foundry + Project level)
- Cosmos DB connections (Foundry + Project level)

## Outputs

The deployment provides the following outputs:

```json
{
  "aiFoundryId": "Resource ID",
  "aiFoundryName": "Account name",
  "aiFoundryProjectId": "Project resource ID",
  "embeddingDeploymentName": "Embedding deployment name",
  "applicationInsightsId": "App Insights resource ID",
  "keyVaultId": "Key Vault resource ID",
  "aiSearchId": "AI Search resource ID",
  "storageAccountId": "Storage account resource ID",
  "cosmosDbId": "Cosmos DB resource ID",
  "aiSearchFoundryConnectionId": "AI Search connection ID (Foundry)",
  "aiSearchProjectConnectionId": "AI Search connection ID (Project)",
  "cosmosDbFoundryConnectionId": "Cosmos DB connection ID (Foundry)",
  "cosmosDbProjectConnectionId": "Cosmos DB connection ID (Project)"
}
```

## Using the Deployed Resources

### Access AI Foundry

```bash
# Portal
https://ai.azure.com

# Get endpoint
az cognitiveservices account show \
  --name <foundry-name> \
  --resource-group <rg-name> \
  --query properties.endpoint
```

### Upload Documents for Indexing

```bash
# Upload to knowledge container
az storage blob upload \
  --account-name <storage-account-name> \
  --container-name knowledge \
  --name document.pdf \
  --file ./document.pdf \
  --auth-mode login
```

### Access Cosmos DB

The project has full data plane access via managed identity. Use Azure SDKs with DefaultAzureCredential.

### Create AI Search Index

The AI Search service can index documents from the "knowledge" container using its managed identity.

## Security Features

- 🔐 **Keyless authentication** - All services use managed identities
- 🔐 **Least privilege RBAC** - Minimal required permissions
- 🔐 **No local auth** - Key-based auth disabled where possible
- 🔐 **TLS 1.2+** - Enforced for all storage operations
- 🔐 **Private blob access** - Public access disabled

## Monitoring

Application Insights is deployed and configured for monitoring. Access metrics and logs via:

```bash
az monitor app-insights component show \
  --app <app-insights-name> \
  --resource-group <rg-name>
```

## Troubleshooting

### Deployment Fails with RBAC Errors

Role assignments can take a few minutes to propagate. Wait 60 seconds and retry.

### AI Search Can't Index Storage

Verify:
1. AI Search managed identity has "Storage Blob Data Reader" role
2. Storage account allows Azure services access
3. Documents exist in "knowledge" container

### Connection Authentication Fails

Ensure:
1. Role assignments module completed successfully
2. Managed identities are enabled on all resources
3. Service connections use `authType: 'AAD'`

## Clean Up

To delete all resources:

```bash
az group delete --name <resource-group-name> --yes --no-wait
```

## Contributing

1. Test changes with `--confirm-with-what-if` before deploying
2. Follow existing naming conventions
3. Update this README for new features
4. Ensure all resources use managed identities

## License

MIT License - See LICENSE file for details
