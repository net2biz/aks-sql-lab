#!/bin/bash
source ../credentials.sh
source aks-sql_variables.sh

clear
az account clear
az login --service-principal -u $AZ_CLIENT_ID -p $AZ_CLIENT_SECRET --tenant $AZ_TENANT_ID

                       #   (az account list-locations -o table      to see the list of locations) 
VERSION=$(az aks get-versions --location $LOCATION --query 'orchestrators[-1].orchestratorVersion' --output tsv)   # get the latest version of AKS 
az group create --name $RGNAME --location $LOCATION 

printf "\n create AKS Cluster \n" 
az aks create --location $LOCATION --resource-group $RGNAME --name $AKSNAME --enable-addons monitoring --kubernetes-version $VERSION --generate-ssh-keys 

 
printf "\n run the following to create the logical server to host the Azure SQL database \n"
az sql server create --location $LOCATION --resource-group $RGNAME --name $SQLNAME --admin-user sqladmin --admin-password P2ssw0rd1234 

printf "\n run the following to allow access from Azure to the newly provisioned logical server \n"
az sql server firewall-rule create --resource-group $RGNAME --server $SQLNAME --name allowAzure --start-ip-address 0.0.0.0 --end-ip-address 0.0.0.0 


printf "\n run the following to create the Azure SQL database you will be using \n" 
az sql db create --resource-group $RGNAME --server $SQLNAME --name $DBNAME --service-objective S0 --no-wait 


printf "\n run the following to create the Azure Container registry you will be using in this lab \n"
az acr create --location $LOCATION --resource-group $RGNAME --name $ACRNAME --sku Standard 


printf "\n run the following to grant the AKS-generated managed identity to access to the newly created ACR"
printf "\n Retrieve the id of the service principal configured for AKS \n"
CLIENT_ID=$(az aks show --resource-group $RGNAME --name $AKSNAME --query "identityProfile.kubeletidentity.clientId" --output tsv) 
printf "\n CLient ID : $CLIENT_ID \n"

 
printf "\n Retrieve the ACR registry resource id \n"
ACR_ID=$(az acr show --name $ACRNAME --resource-group $RGNAME --query "id" --output tsv) 
printf "\n ACR_ID : $ACR_ID \n"

printf "\n force pause 120 seconds \n"
sleep 120 

printf "\n Create role assignment \n"
printf "\n ClientID : $CLIENT_ID \n"
printf "\n ACR_ID:  $ACR_ID \n"
az role assignment create --assignee $CLIENT_ID --role acrpull --scope $ACR_ID 


printf "\n run the following to display the name of logical server hosting the Azure SQL database you created earlier in this task \n"
echo $(az sql server list --resource-group $RGNAME --query '[].name' --output tsv)'.database.windows.net' 


printf "\n run the following to display the name of the login server of the Azure Container registry you created earlier in this task \n"
az acr show --name $ACRNAME --resource-group $RGNAME --query "loginServer" --output tsv 
