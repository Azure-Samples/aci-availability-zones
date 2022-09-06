#!/bin/bash

# <FullScript>
# Route traffic for high availability of applications

# Variables for Contrainer Intances Group and Traffic Manager resources
resourceGroup="aci-az"
location="eastus"
container1="container-aci-az-1"
container2="container-aci-az-2"
dnsNameLabelZone1="aci-az-dns-eastuszone1"
dnsNameLabelZone2="aci-az-dns-eastuszone2"
trafficManagerProfile="traffic-manager-profile-aci-az"
uniqueDnsName="uniqie-dns-name-aci-az"

# Create a resource resourceGroupName
echo "Creating Resource Group $resourceGroup in $location..."
az group create \
    --name $resourceGroup \
    --location $location

# Create the first Container group in availibility zone 1
echo "Creating first Contrainer Group $container1 in $location in zone 1..."
az container create \
    --resource-group $resourceGroup \
    --name $container1 \
    --image mcr.microsoft.com/azuredocs/aci-helloworld \
    --dns-name-label $dnsNameLabelZone1 \
    --location $location --zone 1

# Create the first Container group in availibility zone 2
echo "Creating first Contrainer Group $container2 in $location in zone 2..."
az container create \
    --resource-group $resourceGroup \
    --name $container2 \
    --image mcr.microsoft.com/azuredocs/aci-helloworld \
    --dns-name-label $dnsNameLabelZone2 \
    --location $location --zone 2


#Create an Azure Traffic Manager resource with endpoints for  Zone 1 and Zone 2​
echo "Creating Azure Traffic Manager resource..."
az network traffic-manager profile create\
    --resource-group $resourceGroup \
    --name $trafficManagerProfile \
    --routing-method Priority \
    --unique-dns-name $uniqueDnsName \
    --ttl 10 --interval 10 --max-failures 3 --timeout 5

echo "Creating Azure Traffic Manager endpoint for $location Zone 1..."
az network traffic-manager endpoint create \
    --resource-group $resourceGroup \
    --name zonalendpoint1 \
    --profile-name $trafficManagerProfile \
    --type externalEndpoints \
    --priority 1 \
    --target $dnsNameLabelZone1.$location.azurecontainer.io

echo "Creating Azure Traffic Manager endpoint for $location Zone 2..."
az network traffic-manager endpoint create \
    --resource-group $resourceGroup \
    --name zonalendpoint2 \
    --profile-name $trafficManagerProfile \
    --type externalEndpoints \
    --priority 2 \
    --target $dnsNameLabelZone2.$location.azurecontainer.io
# </FullScript>

# echo "Deleting all resources"
# az group delete --name $resourceGroup -y