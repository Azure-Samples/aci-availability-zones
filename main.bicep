// Parameters
////////////////////////////////////////////////////////////////////////////////

@description('Location for all resources.')
param location string = resourceGroup().location

@description('The base name to be used for container groups.')
param containerGroupBaseName string

@description('The number of zones to deploy to (1-3).')
@allowed([
  1
  2
  3
])
param containerGroupNumberOfZones int = 2

@description('Container image to deploy. Should be of the form repoName/imagename:tag for images stored in public Docker Hub, or a fully qualified URI for other registries. Images from private registries require additional registry credentials.')
param containerImage string = 'mcr.microsoft.com/azuredocs/aci-helloworld'

@description('Port to open on the container and the public IP address.')
param containerPort int = 80

@description('The behavior of Azure runtime if container has stopped.')
@allowed([
  'Always'
  'Never'
  'OnFailure'
])
param containerRestartPolicy string = 'Always'

@description('The name to be used for traffic manager.')
param trafficManagerName string

// Resources
////////////////////////////////////////////////////////////////////////////////

// Create the container group resources by looping through our config variable
resource containerGroups 'Microsoft.ContainerInstance/containerGroups@2021-09-01' = [for i in range(1, containerGroupNumberOfZones): {
  name: '${containerGroupBaseName}-zone${i}'
  location: location
  zones: [
    string(i)
  ]
  properties: {
    containers: [
      {
        name: '${containerGroupBaseName}-zone${i}'
        properties: {
          image: containerImage
          ports: [
            {
              port: containerPort
              protocol: 'TCP'
            }
          ]
          resources: {
            requests: {
              cpu: 1
              memoryInGB: 2
            }
          }
        }
      }
    ]
    osType: 'Linux'
    restartPolicy: containerRestartPolicy
    ipAddress: {
      type: 'Public'
      dnsNameLabel: '${containerGroupBaseName}-zone${i}'
      ports: [
        {
          port: containerPort
          protocol: 'TCP'
        }
      ]
    }
  }
}]

// Create a traffic manager instance to route traffic to the container groups
resource trafficManagerProfile 'Microsoft.Network/trafficManagerProfiles@2018-04-01' = {
  name: trafficManagerName
  location: 'global'
  properties: {
    profileStatus: 'Enabled'
    trafficRoutingMethod: 'Priority'
    dnsConfig: {
      relativeName: trafficManagerName
      ttl: 10
    }
    monitorConfig: {
      protocol: 'HTTP'
      port: 80
      path: '/'
      intervalInSeconds: 10
      toleratedNumberOfFailures: 3
      timeoutInSeconds: 5
    }
    endpoints: [for i in range(1, containerGroupNumberOfZones): {
      name: '${containerGroupBaseName}-zone${i}'
      type: 'Microsoft.Network/trafficManagerProfiles/externalEndpoints'
      properties: {
        target: containerGroups[i - 1].properties.ipAddress.fqdn
        priority: i
      }
    }]
  }
}
