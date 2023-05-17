param environment_name string
param location string

var logAnalyticsWorkspaceName = 'logs-${environment_name}'

resource logAnalyticsWorkspace'Microsoft.OperationalInsights/workspaces@2020-03-01-preview' = {
  name: logAnalyticsWorkspaceName
  location: location
  properties: any({
    retentionInDays: 30
    features: {
      searchVersion: 1
    }
    sku: {
      name: 'PerGB2018'
    }
  })
}

resource environment 'Microsoft.App/managedEnvironments@2022-03-01' = {
  name: environment_name
  location: location
  properties: {
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: reference(logAnalyticsWorkspace.id, '2020-03-01-preview').customerId
        sharedKey: listKeys(logAnalyticsWorkspace.id, '2020-03-01-preview').primarySharedKey
      }
    }
  }
}

resource nginxcontainerapp 'Microsoft.App/containerApps@2022-03-01' = {
  name: 'nginxcontainerapp'
  location: location
  properties: {
    managedEnvironmentId: environment.id
    configuration: {
      ingress: {
        external: true
        targetPort: 80
      }
    }
    template: {
      containers: [
        {
          image: 'jobjingjo/nginx:job'
          name: 'nginxcontainerapp'
          resources: {
            cpu: '0.5'
            memory: '1.0Gi'
          }
        }
        {
          image: 'bbyars/mountebank:latest'
          name: 'mountebank'
          resources: {
            cpu: '0.5'
            memory: '1.0Gi'
          }
        }
        // {
        //   image: 'alpine/curl'
        //   name: 'alpine'
        //   resources: {
        //     cpu: '0.5'
        //     memory: '1.0Gi'
        //   }
        // }
        {
          image: 'jobjingjo/dotnet6:webapi'
          name: 'dotnet6'
          resources: {
            cpu: '0.5'
            memory: '1.0Gi'
          }
          env:[
            {
              name:'ASPNETCORE_URLS'
              value:'http://+:8080'
            }
          ]
        }
      ]
      scale: {
        minReplicas: 1
        maxReplicas: 1
      }
    }
  }
}