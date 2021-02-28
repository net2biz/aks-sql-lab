#!/bin/bash
source ../credentials.sh
source aks-sql_variables.sh


LOCATION="AustraliaEast"                         #   (az account list-locations -o table      to see the list of locations) 
VERSION=$(az aks get-versions --location $LOCATION --query 'orchestrators[-1].orchestratorVersion' --output tsv)   # get the latest version of AKS 


RGNAME=az400m16l01a-RG 
az group create --name $RGNAME --location $LOCATION 

 

# run the following to create the logical server to host the Azure SQL database 

SQLNAME='az400m16sql'$RANDOM$RANDOM 
az sql server create --location $LOCATION --resource-group $RGNAME --name $SQLNAME --admin-user sqladmin --admin-password P2ssw0rd1234 

 

# run the following to allow access from Azure to the newly provisioned logical server: 
az sql server firewall-rule create --resource-group $RGNAME --server $SQLNAME --name allowAzure --start-ip-address 0.0.0.0 --end-ip-address 0.0.0.0 

 

# run the following to create the Azure SQL database you will be using  
DBNAME=mhcdb 
az sql db create --resource-group $RGNAME --server $SQLNAME --name $DBNAME --service-objective S0 --no-wait 

 

# run the following to create the Azure Container registry you will be using in this lab: 
ACRNAME='az400m16acr'$RANDOM$RANDOM 
az acr create --location $LOCATION --resource-group $RGNAME --name $ACRNAME --sku Standard 

 

# run the following to grant the AKS-generated managed identity to access to the newly created ACR: 
# Retrieve the id of the service principal configured for AKS 
CLIENT_ID=$(az aks show --resource-group $RGNAME --name $AKSNAME --query "identityProfile.kubeletidentity.clientId" --output tsv) 


# Retrieve the ACR registry resource id 
ACR_ID=$(az acr show --name $ACRNAME --resource-group $RGNAME --query "id" --output tsv) 
 

 
# Create role assignment 
az role assignment create --assignee $CLIENT_ID --role acrpull --scope $ACR_ID 


# run the following to display the name of logical server hosting the Azure SQL database you created earlier in this task: 
echo $(az sql server list --resource-group $RGNAME --query '[].name' --output tsv)'.database.windows.net' 


# run the following to display the name of the login server of the Azure Container registry you created earlier in this task: 
az acr show --name $ACRNAME --resource-group $RGNAME --query "loginServer" --output tsv 

 

 