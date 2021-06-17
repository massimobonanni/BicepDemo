# Create Demo Environment

You can use the demoEnvironment.bicep template to create the environment for the environment.

```bash
az deployment sub create --template-file demoEnvironment.bicep --parameters resourceGroup=<resource group name> keyVaultName=<keyvault name> sqlAdminPassword=<pwd>
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
Remebre to use the resource group and keyvault you created in the previous step when you deploy every single step of the demo

