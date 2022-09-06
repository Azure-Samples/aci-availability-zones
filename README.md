# ACI Availability Zone (Preview)

## Deploy an Azure Container Instances (ACI) container group in an availability zone (preview)

An availability zone is a physically separate zone in an Azure region. You can
use availability zones to protect your containerized applications from an
unlikely failure or loss of an entire data center. Azure Container Instances
(ACI) supports zonal container group deployments, meaning the instance is pinned
to a specific, self-selected availability zone. The availability zone is
specified at the container group level. Containers within a container group
cannot have unique availability zones. To change your container group's
availability zone, you must delete the container group and create another
container group with the new availability zone.

## Components

![image](https://github.com/sopacifi/aci-availability-zones/blob/main/diagram.png)

## Prerequisites

The following tools are required before using this example:

- Azure CLI, version 2.30.0 or later

Login to `az` and select your subscription (if necessary):

```sh
az login
az account set --subscription "YOUR_SUBSCRIPTION_ID"
```

## Deploy with Bicep

First, copy the `main.parameters.sample.json` file to `main.parameters.json`.
Then, update the values of `containerGroupBaseName` and `trafficManagerName` to
something unique.

Next, create the resource group that you will be deploying into:

```sh
# Change location and resource-group to your preferred values
az group create --location eastus --resource-group rg-your-resource-group-name
```

Finally, deploy the bicep template with `az`:

```sh
az deployment group create -n DeployingAciToMultipleAvailabilityZones --resource-group rg-your-resource-group-name --template-file main.bicep --parameters main.parameters.json
```

Wait for the deployment to finish, then check the Azure Portal for the status of
the resources.

## Deploy using Bash script

Open a bash session and execute the following steps

- Open the file `aci-availability-zones.sh` edit all the variables with your
  unique values.
- Save and close.

```sh
#Run the following command
sh aci-availability-zones.sh
```

Wait for the deployment to finish, then check the Azure Portal for the status of
the resources.

## More Information

For more information, see the following Microsoft Docs:

- [Deploy an Azure Container Instances (ACI) container group in an availability zone (preview)](https://docs.microsoft.com/azure/container-instances/availability-zones)
