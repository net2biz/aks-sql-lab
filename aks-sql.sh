#!/bin/bash
source ../credentials.sh
source aks-common_variables.sh

clear
az account clear
az login --service-principal -u $AZ_CLIENT_ID -p $AZ_CLIENT_SECRET --tenant $AZ_TENANT_ID


if [[ -z $(az account set --subscription $AZ_SUBSCRIPTION_ID --only-show-errors) ]]; then
    echo "Login Success"
    AZ_SUBSCRIPTION_FLAG=true
    #az account show
else
    echo "Login failure"
    exit 1
fi

# creating the resource group for AKS
#---------------------------------------
echo "processing further"

if [[ -z $( az group list --query "[].{name:name}" | grep $AKS_RESOURCEGROUP ) ]]; then
    az group create --name $AKS_RESOURCEGROUP --location $AKS_LOCATION --subscription $AZ_SUBSCRIPTION_ID --tags $TAG1 $TAG2 $TAG3 $TAG4 $TAG5 $TAG6 $TAG7
    AKS_RG_ID=$(az group show --name ${AKS_RESOURCEGROUP} --query "id")
else 
    echo "AKS RG existing"
    AKS_RG_ID=$(az group show --name ${AKS_RESOURCEGROUP} --query "id")
fi
echo "AKS RG ID: ${AKS_RG_ID}"

# creating the resource group for VNET
#---------------------------------------
if [[ -z $( az group list --query "[].{name:name}" | grep $VNET_RG ) ]]; then
    az group create --name $VNET_RG --location $VNET_LOCATION --subscription $AZ_SUBSCRIPTION_ID --tags $TAG1 $TAG2 $TAG3 $TAG4 $TAG5 $TAG6 $TAG7
    VNET_RG_ID=$(az group show --name ${VNET_RG} --query "id")
else 
    echo "VNET RG existing"
    VNET_RG_ID=$(az group show --name ${VNET_RG} --query "id")
fi
echo "VNET RG ID: ${VNET_RG_ID}"

# creating the NSG in the VNET RG
#---------------------------------------
if [[ -z $( az network nsg list --query "[].{name:name}" | grep $NSG_NAME ) ]]; then
    az network nsg create --name $NSG_NAME --resource-group $NSG_RG --location $NSG_LOCATION --subscription $AZ_SUBSCRIPTION_ID --tags $TAG1 $TAG2 $TAG3 $TAG4 $TAG5 $TAG6 $TAG7
    NSG_ID=$(az network nsg show -n $NSG_NAME -g $NSG_RG --query "id")
else
    echo "NSG is existing"
    NSG_ID=$(az network nsg show -n $NSG_NAME -g $NSG_RG --query "id")
fi
echo "NSG ID: ${NSG_ID}"

# creating the VNET 
if [[ -z $( az network vnet list  --query "[].{name:name}" | grep $VNET_NAME ) ]]; then
    az network vnet create --name ${VNET_NAME} --resource-group ${VNET_RG} --location ${VNET_LOCATION} \
    --network-security-group $NSG_NAME \
    --subscription $AZ_SUBSCRIPTION_ID \
    --tags $TAG1 $TAG2 $TAG3 $TAG4 $TAG5 $TAG6 $TAG7 \
    --address-prefixes $VNET_ADDRESS_PREFIX

    VNET_ID=$(az network vnet show --name ${VNET_NAME} --resource-group ${VNET_RG} --query "id")
else
    echo "VNET is existing"
    VNET_ID=$(az network vnet show --name ${VNET_NAME} --resource-group ${VNET_RG} --query "id")
fi
echo "VNET ID: ${VNET_ID}"

# creating the Subnet1
#----------------------
if [[ -z $( az network vnet subnet list --resource-group ${VNET_RG} --vnet-name ${VNET_NAME} --query "[].{name:name}" | grep $SUBNET1_NAME ) ]]; then
    echo "Creating Subnet1"
    az network vnet subnet create --resource-group ${VNET_RG} --vnet-name ${VNET_NAME} --name $SUBNET1_NAME \
    --address-prefixes $SUBNET1_address_prefixes --network-security-group $NSG_NAME --subscription $AZ_SUBSCRIPTION_ID
    SUBNET1_ID=$(az network vnet subnet show --resource-group ${VNET_RG} --vnet-name ${VNET_NAME} --name $SUBNET1_NAME --query "id")
else
    echo "Subnet1 is existing"
    SUBNET1_ID=$(az network vnet subnet show --resource-group ${VNET_RG} --vnet-name ${VNET_NAME}  --name $SUBNET1_NAME --query "id")
fi
echo "Subnet1 ID : $SUBNET1_ID"


# creating the Subnet2
#----------------------
if [[ -z $( az network vnet subnet list --resource-group ${VNET_RG} --vnet-name ${VNET_NAME} --query "[].{name:name}" | grep $SUBNET2_NAME ) ]]; then
    echo "Creating Subnet2"
    az network vnet subnet create --resource-group ${VNET_RG} --vnet-name ${VNET_NAME} --name $SUBNET2_NAME \
    --address-prefixes $SUBNET2_address_prefixes --network-security-group $NSG_NAME --subscription $AZ_SUBSCRIPTION_ID
    SUBNET2_ID=$(az network vnet subnet show --resource-group ${VNET_RG} --vnet-name ${VNET_NAME} --name $SUBNET2_NAME --query "id")
else
    echo "Subnet2 is existing"
    SUBNET2_ID=$(az network vnet subnet show --resource-group ${VNET_RG} --vnet-name ${VNET_NAME} --name $SUBNET2_NAME --query "id")
fi
echo "Subnet2 ID : $SUBNET2_ID"

# creating the Subnet3
#----------------------
if [[ -z $( az network vnet subnet list --resource-group ${VNET_RG} --vnet-name ${VNET_NAME} --query "[].{name:name}" | grep $SUBNET3_NAME ) ]]; then
    echo "Creating Subnet3"
    az network vnet subnet create --resource-group ${VNET_RG} --vnet-name ${VNET_NAME} --name $SUBNET3_NAME \
    --address-prefixes $SUBNET3_address_prefixes --network-security-group $NSG_NAME --subscription $AZ_SUBSCRIPTION_ID --output json 
    SUBNET3_ID=$(az network vnet subnet show --resource-group ${VNET_RG} --vnet-name ${VNET_NAME} --name $SUBNET3_NAME --query "id")
else
    echo "Subnet3 is existing"
    SUBNET3_ID=$(az network vnet subnet show --resource-group ${VNET_RG} --vnet-name ${VNET_NAME} --name $SUBNET3_NAME --query "id")
fi
echo "Subnet3 ID : $SUBNET3_ID"


# # # creating AKS Cluster across availability zones
# # #---------------------------------------------------
# echo "creating aks cluser .. pls wait"
# az aks create \
#     --resource-group $AKS_RESOURCEGROUP \
#     --name $AKS_CLUSTER_NAME \
#     --generate-ssh-keys \
#     --vm-set-type VirtualMachineScaleSets \
#     --load-balancer-sku $AKS_LOAD_BALANCER_SKU \
#     --node-count $AKS_NODE_COUNT \
#     --zones $AKS_ZONES \
#     --service-principal $AZ_CLIENT_ID \
#     --client-secret $AZ_CLIENT_SECRET
#     --subscription $AZ_SUBSCRIPTION_ID \
#     --tags $TAG1 $TAG2 $TAG3 $TAG4 $TAG5 $TAG6 $TAG7 \
#     --enable-managed-identity \
#     --enable-rbac \
#     --vnet-subnet-id $SUBNET3_ID \
#     --enable-private-cluster

echo "creating acr"
if [[ -z $( az acr list --resource-group $ACR_RG --subscription $AZ_SUBSCRIPTION_ID --query "[].{name:name}" | grep $ACR_NAME ) ]]; then
   az acr create --resource-group $ACR_RG --name $ACR_NAME --sku $ACR_SKU --location $ACR_LOCATION --subscription $AZ_SUBSCRIPTION_ID --tags $TAG1 $TAG2 $TAG3 $TAG4 $TAG5 $TAG6 $TAG7 
   ACR_ID=$(az acr show --resource-group $ACR_RG --subscription $AZ_SUBSCRIPTION_ID --name $ACR_NAME --query "id")
else
    echo "ACR is existing"
    ACR_ID=$(az acr show --resource-group $ACR_RG --subscription $AZ_SUBSCRIPTION_ID --name $ACR_NAME --query "id")
fi
echo "ACR ID : $ACR_ID"   

echo "Logging to ACR"
az acr login --name $ACR_NAME --expose-token


if [[ -z $( az aks list --resource-group $AKS_RESOURCEGROUP --subscription $AZ_SUBSCRIPTION_ID --query "[].{name:name}" | grep $AKS_CLUSTER_NAME ) ]]; then
    echo "Creating the AKS cluster"
    # az aks create \
    #     --resource-group $AKS_RESOURCEGROUP \
    #     --name $AKS_CLUSTER_NAME \
    #     --node-count 2 \
    #     --enable-addons http_application_routing \
    #     --enable-managed-identity \
    #     --generate-ssh-keys \
    #     --node-vm-size Standard_B2s

    az aks create \
        --resource-group $AKS_RESOURCEGROUP \
        --name $AKS_CLUSTER_NAME \
        --enable-addons monitoring \
        --generate-ssh-keys \
        --node-vm-size $AKS_NODE_VM_SIZE \
        --node-count 3

    AKS_ID=$(az aks show --resource-group $AKS_RESOURCEGROUP --subscription $AZ_SUBSCRIPTION_ID --name $AKS_CLUSTER_NAME --query "id")
else
    echo "AKS cluster $AKS_CLUSTER_NAME is existing"
    AKS_ID=$(az aks show --resource-group $AKS_RESOURCEGROUP --subscription $AZ_SUBSCRIPTION_ID --name $AKS_CLUSTER_NAME --query "id")
fi
echo "AKS ID : $AKS_ID" 

echo "linking Kubernetes cluster with kubectl"
az aks get-credentials --name $AKS_CLUSTER_NAME --resource-group $AKS_RESOURCEGROUP --overwrite-existing

echo "Your AKS nodes"
kubectl get nodes

echo "applying deployment-cards.yaml"
kubectl apply -f deployment-cards.yaml



