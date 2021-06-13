# Create Demo Environment

To create the demo environment you need to create a resource group, a KeyVault, and, then, deploy all the steps using Azure CLI or Azure Powershell

## Create Resource Group
You can use the portal or the Azure CLI command

```bash
az grou create <resource group name>
```

## Create KeyVault
You can use the template `keyvault.bicep` to create the KeyVault you use in the step number 7 (regarding teh secrets).

```bash
az deployment group create --resource-group <resource Group Name> --template-file keyVault.bicep --parameters keyVaultName=<keyvault name>
```

## Deploy bicep steps
Remebre to use the resource group and keyvault you created in the previous step when you deploy every single step of the demo

