# 🚀 Azure Terraform Setup Guide (Backend + Key Vault + Pipeline)

This guide provides the exact sequence to initialize your Azure
infrastructure, secure your secrets in Key Vault, and configure Azure
DevOps to deploy the PetClinic application.

------------------------------------------------------------------------

## 📋 Prerequisites

-   Azure CLI installed and logged in:

    ``` bash
    az login
    ```

-   Azure DevOps project created

-   Bash terminal (WSL, Linux, or Git Bash)

------------------------------------------------------------------------

## 🛠 Step 1: Create Terraform Backend (State Storage)

**Goal:** Create the Resource Group and Storage Account where Terraform
will save its state file (`petclinic.tfstate`).

``` bash
chmod +x create-backend.sh
./create-backend.sh
```

Copy the Storage Account name from the output.

------------------------------------------------------------------------

## 🔐 Step 2: Create Key Vault & Secrets

Update `create-keyvault-and-secrets.sh`:

-   `KV_NAME` (globally unique)
-   `STORAGE_ACCOUNT` (from Step 1)
-   `SERVICE_CONN` (Azure DevOps connection name)

Run:

``` bash
chmod +x create-keyvault-and-secrets.sh
./create-keyvault-and-secrets.sh
```

Verify in Azure Portal → Key Vaults.

------------------------------------------------------------------------

## 🔌 Step 3: Create Service Connection

Azure DevOps → Project Settings → Pipelines → Service Connections

Create:

-   Type: Azure Resource Manager
-   Auth: Service principal (automatic)
-   Resource Group: rg-tfstate
-   Name: terraform-service-connection-2
-   Grant access: Enabled

------------------------------------------------------------------------

## 📦 Step 4: Create Variable Group

Pipelines → Library → Variable Groups

-   Name: terraform-prod-vars
-   Link to Key Vault: Enabled
-   Service Connection: terraform-service-connection-2
-   Key Vault: kv-petclinic-prod-xoa

Add all secrets.

------------------------------------------------------------------------

## 🚀 Step 5: Run Pipeline

Ensure `azure-pipelines.yml`:

``` yaml
variables:
  - name: azureServiceConnection
    value: 'terraform-service-connection-2'
  - group: terraform-prod-vars
```

Push code and run pipeline.

------------------------------------------------------------------------

## ⚠️ First Run Permission

Approve permission when prompted.

------------------------------------------------------------------------

## ✅ Summary

-   Secure backend
-   Centralized secrets
-   Automated authentication
-   CI/CD ready
