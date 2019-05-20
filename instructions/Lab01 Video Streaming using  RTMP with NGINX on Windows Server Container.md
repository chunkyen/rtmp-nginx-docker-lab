# LAB01 Deploying NGINX for video streaming using RTMP with Windows Container

###  1 Pre-requisites

**1.1 Windows Server 2019**

You need a Windows Server 2019 as your container host. You will need internet access on the container host for the lab to work.

_Note: The lab guide should mostly work on Docker for Windows Desktop with some minor tweaking. If you are going to use this instead of Windows Server 2019, do not follow the steps below to install docker. Instead take a look at [Installing Docker for Windows](https://docs.docker.com/v17.09/docker-for-windows/install/)_ remember to switch to Windows Container mode before proceeding.

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

~~**1.3 Edit the NGINX conf file**~~

~~As the NGINX container need to reference the host IP address, we will need to replace the config file with your actual host IP.~~

~~First type IPCONFIG in a command prompt to determine your container host IP. There should be multiple address, just pick the first address.~~

~~There are 2 files to edit, use your favorite text editor, such as VS code or Notepad++.~~

~~- Open c:\lab01\nginx1\nginx1-src\conf\nginx.conf~~

~~- Find the line **_push rtmp://172.27.192.1:1936/live/demo;_**~~

~~- And replace with **_push rtmp://your_container_host_ip:1936/live/demo;_**~~

~~- Open c:\lab01\nginx-lb\nginx-lb-src\conf\nginx.conf~~

~~- Find the line **_server 172.27.192.1:8080;_** and **_server 172.27.192.1:8081;_**~~

~~- Replace with **_server your_container_host_ip:8080;_** and **_server your_container_host_ip:8081;_**~~

~~- Save the files after making the change~~

~~_Note: There should be an easier way to do this without manually modifying the conf file. For future enhancements_~~

**1.4 Install OBS**

Download and install OBS. [OBS download](https://obsproject.com/download)

You will need a video file to stream. You can use the infamous big buck bunny video. [Big buck bunny](https://peach.blender.org/download/)


###  2 Deploying RTMP NGINX containers using Dockerfile
This section will outline the steps that will be used to deploy all the containers required using Dockerfile.
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

**2.1 building images**

Run the following docker command to build nginx1 image
> cd c:\lab01\nginx1

> docker build . -t nginx1-image

To verify, run

> docker images

You should see an nginx1-image

Repeat the steps for nginx2 and nginxlb

>cd c:\lab01\nginx2

>docker build . -t nginx2-image

> cd c:\docker\nginx-lb

> docker build . -t nginx-lb-image

**2.2 Running containers**

We will use the following command to run nginx2 container.
>docker run -d --name nginx2 -p 8081:80 -p 1936:1935 nginx2-image

*Note we need to start nginx2 first as we are referencing nginx2 name in the config file of nginx1. If nginx2 name cannot be found when nginx1 container starts, nginx will not start sucessfully.*

It will use the nginx2-image and the container host will proxy port 8081 - 80 and 1936 - 1935 to the container.

Run the command below to verify

> docker ps

Repeat the steps for nginx1.

It will use the nginx1-image and the container host will proxy port 8080 - 80 and 1935 - 1935 to the container.

> docker run -d --name nginx1 -p 8080:80 -p 1935:1935 nginx1-image


Next nginx-lb. It will use the nginx-lb-image and the container host will only proxy port 80 - 80 to the container.

*Note similar to the note given above, nginx-lb can only start after nginx1 and nginx2 are started. *

> docker run -d --name nginx-lb -p 80:80 nginx-lb-image

**2.3 Testing the containers functionalities**

Next we will verify if the containers are working.

Use a browser to browse to http://localhost:8080

You should see an nginx1 page

*Note: If the page failed to load, check if Windows Firewall is disabled. You can also dobule check by attaching an cmd to the running container and ping from the container to the host and vice versa.*

Browse to http://localhost:8081 and you should see an nginx2 page.

If you browse to http://localhost you should see either the nginx1 or nginx2 page because the nginx-lb is distributing to the 2 backend nginx containers using round robin. You might need to refresh multiple times or close the browser and start again to see the result.


_Tip you can also use the powershell code below to test http connection_

> iwr -method head http://localhost -UseBasicParsing

**2.4 Streaming and viewing videos**

We will use OBS to publish the video stream to nginx1.

Launch OBS, go to settings, click the stream on the left column.

- under stream type, select custom

- under server type **rtmp://localhost/live**

- under stream key, enter **demo**

Back to the OBS screen, click on the + under media sources and select  a media source.
In the media source dialog, accept the default name and click ok. Under local file, browse to the bunny video file you have downloaded previously and click ok. If you see a green icon at the bottom right of OBS, it means the rtmp stream has sucessfully connect to the nginx1 container.

To view video on the container host, browse to http://localhost/player.html

Click on the play icon and wait for the stream to load. You should see the video playing.

Refresh or close the browser window again and browse to http://localhost/player.html, you should connect to either nginx1 or nginx2.

Browse to http://localhost/stats to see the video streaming stats.

###  3 Deploying RTMP NGINX containers manually
The steps here shows how you can manually build a container image without a dockerfile. You will use the docker commit command but as you will learn, you will hardly use this in the real world. 

Think of dockerfile as a recipie for a cook, the steps and ingredients of a dish is listed down in detail in the dockerfile. It is clear and repeatable (which leads to less error).

The analogy of building a container image without a dockerfile is like a cooking without recording down the steps. You might still get the same dish, but no one knows (except the cook) what is inside the dish. It is difficult for others (even the original cook himself) to reproduce the exact same dish. Using a recipie is clearly the better approach.

So the main purpose of this section is to compare and contrast with building with a dockerfile. You can cross reference the steps with the dockerfile used for the steps in section 2.

**3.1 Building images with docker commit**

First lets run a plain vanilla servercore image. The reason why we are publishing port 8080 is so that we can verify nginx is running correctly in the container later on.

>docker run -dti --name nginx-base -p8080:80 mcr.microsoft.com/windows/servercore:ltsc2019

Next we will need to copy the nginx executable, scripts and html files into the docker container.

>docker cp c:\lab01\nginx1\nginx1-src\ nginx-base:c:\nginx

We can attach into the nginx-image container to verify the files.

>docker attach nginx-base

You can cd to *c:\nginx* and do a *dir* to check that the files are copied. Press Ctrl + P follow by Ctrl + Q to exit the cmd of the running container.

To verify that the nginx is running properly with the correct conf file, let's run nginx.exe in the container.

>docker exec nginx-base c:\nginx\start.bat

You should see an *Nginx started* message

Open up a browser and navigate to http://localhost:8080, you should see the Nginx1 webpage.Let's convert this into an image.

Stop the container

>docker stop nginx-base

Commit it into an image named nginx-base-image

>docker commit nginx-base nginx-base-image

Run *docker images* to verify that nginx-base-image is created. Notice that the *latest* tag was appended since we did not explicitly specify the tag.

Finally, we will go through the steps of creating a new container based on this new nginx base image.

>docker run -dti --name mynginx1 -p 8080:80 nginx-base-image cmd /k c:\nginx\start.bat

Open up your browser again and navigate to http://localhost:8080, you should see the Nginx1 webpage. We will not continue with building Nginx2 and Nginx-lb since this is for demonstration purposes only, but you can see how tedious it is to manually build an image when compared with using a dockerfile.

Clean up all containers and images if you want by using *docker rm* and *docker rmi*

### End