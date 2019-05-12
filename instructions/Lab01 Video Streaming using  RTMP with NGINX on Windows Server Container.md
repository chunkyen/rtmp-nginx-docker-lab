# LAB01 Deploying NGINX for video streaming using RTMP with Windows Container

###  1 Pre-requisites

**1.1 Windows Server 2019**

You need a Windows Server 2019 as your container host. You will need internet access on the container host for the lab to work.

_Note: The lab guide should mostly work on Docker for Windows Desktop with some minor tweaking. If you are going to use this instead of Windows Server 2019, do not follow the steps below to install docker. Instead take a look at [Installing Docker for Windows](https://docs.docker.com/v17.09/docker-for-windows/install/)_

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

Pull some images
>docker pull mcr.microsoft.com/windows/servercore:ltsc2019

>docker image pull mcr.microsoft.com/windows/nanoserver:1809

**1.2 Extract the labfiles**

After cloning or downloading the repo, extract/copy lab01 folder (found in the labfiles folder) to c:\

The folder structure should look something like this

c:\
 
* lab01
  * nginx1
  * nginx2
  * nginx-lb

**1.3 Edit the NGINX conf file**

As the NGINX container need to reference the host IP address, we will need to replace the config file with your actual host IP.

First type IPCONFIG in a command prompt to determine your container host IP. There should be multiple address, just pick the first address.

There are 2 files to edit, use your favorite text editor, such as VS code or Notepad++.

- Open c:\lab01\nginx1\nginx1-src\conf\nginx.conf
- Find the line **_push rtmp://172.27.192.1:1936/live/demo;_**
- And replace with **_push rtmp://your_container_host_ip:1936/live/demo;_**
- Open c:\lab01\nginx-lb\nginx-lb-src\conf\nginx.conf
- Find the line **_server 172.27.192.1:8080;_** and **_server 172.27.192.1:8081;_**
- Replace with **_server your_container_host_ip:8080;_** and **_server your_container_host_ip:8081;_**
- Save the files after making the change

_Note: There should be an easier way to do this without manually modifying the conf file. For future enhancements_
	
###  2 Deploying RTMP NGINX containers using Dockerfile
This section will outline the steps that will deploy all the containers required using Dockerfile.
The Dockerfile for each container are located in the lab01, container name subfolder.
You can take a look at the content of each Dockerfile (e.g. c:\lab01\nginx1\dockerfile)
Sample below

```
#NGINX1 dockerfile 
FROM mcr.microsoft.com/windows/servercore:ltsc2019 

#copy nginx1 files
COPY /nginx1-src /nginx

WORKDIR /nginx

#run command after container startup
CMD ["/nginx/nginx.exe"]
```

The basic steps are

- use servercore:ltsc2019 as base image
 
- copy the nginx source files
- run nginx when the container starts

**1.1 building images**

Run the following docker command to build nginx1 image
> cd c:\docker\nginx1

> docker build . -t nginx1-image

To verify, run

> docker images

You should see an nginx1-image

Repeat the steps for nginx2 and nginxlb

>cd c:\docker\nginx2

>docker build . -t nginx2-image

> cd c:\docker\nginx-lb

> docker build . -t nginx-lb-image
