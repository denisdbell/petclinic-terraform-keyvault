#!/bin/bash

# ==========================================
# CONFIGURATION
# ==========================================
RESOURCE_GROUP="rg-tfstate"
KV_NAME="kv-petclinic-prod-xoa"
TEMPLATE_FILE="keyvault.json"

# SAFETY: Strip invisible Windows characters just in case
KV_NAME=$(echo "$KV_NAME" | tr -d '\r')
RESOURCE_GROUP=$(echo "$RESOURCE_GROUP" | tr -d '\r')

# ==========================================
# 1. GET OBJECT ID
# ==========================================
echo "Fetching Object ID..."
CURRENT_USER_ID=$(az ad signed-in-user show --query id -o tsv 2>/dev/null)

if [ -z "$CURRENT_USER_ID" ]; then
    echo "User lookup failed, checking Service Principal..."
    CLIENT_ID=$(az account show --query user.name -o tsv)
    CURRENT_USER_ID=$(az ad sp show --id "$CLIENT_ID" --query id -o tsv)
fi

echo "Using Object ID: $CURRENT_USER_ID"

# ==========================================
# 2. ENSURE KEY VAULT EXISTS
# ==========================================
echo "Deploying/Updating Key Vault ($KV_NAME)..."

az deployment group create \
  --resource-group "$RESOURCE_GROUP" \
  --template-file "$TEMPLATE_FILE" \
  --parameters keyVaultName="$KV_NAME" objectId="$CURRENT_USER_ID" \
  --output none

echo "Key Vault ready."

# ==========================================
# 3. ADD SECRETS INDIVIDUALLY
# ==========================================
echo "Uploading Secrets..."

# 1. Database Password
echo " -> Setting db-admin-password"
az keyvault secret set \
  --vault-name "$KV_NAME" \
  --name "db-admin-password" \
  --value "YourStrongPassword123!" \
  --output none

# 2. Azure Service Connection Name
echo " -> Setting azureServiceConnection"
az keyvault secret set \
  --vault-name "$KV_NAME" \
  --name "azureServiceConnection" \
  --value "azurerm-terraform-backend" \
  --output none

# 3. Resource Group Name
echo " -> Setting resourceGroup"
az keyvault secret set \
  --vault-name "$KV_NAME" \
  --name "resourceGroup" \
  --value "rg-tfstate" \
  --output none

# 4. Storage Account Name
echo " -> Setting storageAccount"
az keyvault secret set \
  --vault-name "$KV_NAME" \
  --name "storageAccount" \
  --value "tfstate7a4c4iw4gbetk" \
  --output none

# 5. Container Name
echo " -> Setting container"
az keyvault secret set \
  --vault-name "$KV_NAME" \
  --name "container" \
  --value "terraform-state" \
  --output none

# 6. Terraform State Key
echo " -> Setting tfStateKey"
az keyvault secret set \
  --vault-name "$KV_NAME" \
  --name "tfStateKey" \
  --value "petclinic.tfstate" \
  --output none

echo "-------------------------------------"
echo "Success! All secrets have been uploaded to $KV_NAME."