# LAB01 Deploying NGINX for video streaming using RTMP with Windows Container

### Pre-requisites
1.  Windows Server 2019
You will first need a Windows Server 2019 as your container host. You will need internet access on the container host for the lab to work.

_Note: The docker deployment steps should work mostly on Docker for Windows Desktop for Windows 10 with some tweaking._

Run the following powershell code on Windows Server 2019 to install the container feature
> Install-WindowsFeature -Name Containers

> Restart-Computer -Force  

After the server rebooted, launch Powershell and run the following command to install docker
> Install-Module -Name DockerMsftProvider -Repository PSGallery -Force

>Install-Package -Name docker -ProviderName DockerMsftProvider -Force -RequiredVersion 18.03

This command starts the docker service
> Start-Service docker    

Type the following command to ensure that docker is working
> docker info

> docker --version
