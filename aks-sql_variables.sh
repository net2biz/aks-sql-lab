RGNAME="azsql-10131013-RG" 
LOCATION="AustraliaEast"  
SQLNAME='az1013m16sql'$RANDOM$RANDOM 
DBNAME=mhcdb 
ACRNAME='az1013m16acr'$RANDOM$RANDOM 
AKSNAME='az1013m16aks'$RANDOM$RANDOM  


#--------------------------------------------------TAGS
TAG1="team-pod=cloud"  
TAG2="platform=digital"  
TAG3="infra-app=infrastructure"  
TAG4="environment=prod"  
TAG5="data-classification=internal-use-only"  
TAG6="business-service=infrastructure-services"  
TAG7="application-service=system" 
#--------------------------------------------------AKS VAraiables 
AKS_RESOURCEGROUP="rg-contoso-video97" 
AKS_LOCATION="australiaeast"
AKS_CLUSTER_NAME="aks-contoso-video97"
AKS_LOAD_BALANCER_SKU="standard"
AKS_NODE_COUNT=2
AKS_MAX_NODE_COUNT=3
AKS_MAX_POD_DEPLOYABLE=5
AKS_NODE_VM_SIZE="Standard_DS2_v2"
AKS_ZONES="1 2 3"
#------------------------------------------------vnet variables
VNET_NAME="sanjay-vnet2"
VNET_LOCATION="australiaeast"
VNET_RG="sanjay-vnet-rg"
VNET_RG_LOCATION="australiaeast"
VNET_ADDRESS_PREFIX="192.168.0.0/22"
#------------------------------------------------Subnets
SUBNET1_NAME="sydney2"
SUBNET1_address_prefixes="192.168.0.0/24"

SUBNET2_NAME="melbourne2"
SUBNET2_address_prefixes="192.168.1.0/24"

SUBNET3_NAME="perth2"
SUBNET3_address_prefixes="192.168.2.0/24"

#-------------------------------------------------NSG Variables
NSG_NAME="sanjay-nsg2"
NSG_LOCATION=$VNET_RG_LOCATION
NSG_RG=$VNET_RG
#------------------------------------------------ACR variables
ACR_NAME="sanjayacr98"
ACR_RG=$AKS_RESOURCEGROUP
ACR_LOCATION=$AKS_LOCATION
ACR_SKU="Basic"
