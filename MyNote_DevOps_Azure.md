# DevOps #

## 環境構築 ##

### ソース管理(git) ###

1. AzureDevOps依存しない方法Docker

   [Docker for Gogs](https://github.com/gogs/gogs/tree/main/docker)

   ~~~bash
   docker pull gogs/gogs
   mkdir -p /var/gogs
   docker run --name=gogs -p 10022:22 -p 10080:3000 -v /var/gogs:/data gogs/gogs
   docker start gogs
   ~~~

2. AzureDevOps依存する方法

### 文書管理(svn) ###

## Azure DevOps Sevice ##

[TestProject](https://dev.azure.com/linxuesong2012/TestProject)
