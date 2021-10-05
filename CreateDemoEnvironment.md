# Create Demo Environment

You can use the demoEnvironment.bicep template to create the environment for the environment.

```bash
az deployment sub create --location <azure region> --template-file demoEnvironment.bicep --parameters resourceGroup=<resource group name> keyVaultName=<keyvault name> sqlAdminPassword=<pwd>
```

Example:

```bash
$resourceGroupName="myDemo-rg"
$keyVaultName="mykvDemo"
$sqlAdminPassword="Password1234"

az deployment sub create \
    --location northeurope \
    --template-file demoEnvironment.bicep \
    --parameters resourceGroupName=$resourceGroupName \
                 keyVaultName=$keyVaultName \
                 sqlAdminPassword=$sqlAdminPassword
```

## Deploy bicep steps
Remember to use the resource group and keyvault you created in the previous step when you deploy every single step of the demo

The command to deploy each step is

```bash
az deployment group create \
    --location northeurope \
    --resource-group <resource group name> \
    --template-file main.bicep \
    --parameters <set of parameters>
```
