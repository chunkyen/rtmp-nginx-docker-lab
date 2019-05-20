# LAB02 Building container images the right way

In lab01, we used dockerfile to create the container image of the 3 containers. But if you examine the dockerfile and the content of the respective src folder, we are basically re-copying the content of the nginx folder multiple times. This is an inefficient way of creating container image, even though the content is small. What if we need to create 10 of these containers? Imagine the time and resources wasted.

A better way is to build a rtmp nginx base image, with all the neccesary nginx executable and html code, and only copy in the "differential" files for each container image. This will be the objective of this lab

###  1 Pre-requisites
*Note: You are strongly advised to complete lab01 before proceeding*

**1.1 OS and Software**

Same as the pre-req for lab01. You can also use Docker For Windows on Windows 10 in Windows container mode. Make sure to have OBS installed if you want to test out streaming.

*Note: If you have performed lab01, remember to clean up all nginx container and images using docker rm and docker rmi command.*


**1.2 Extract the labfiles**

After cloning or downloading the repo, extract/copy lab02 folder (found in the labfiles folder) to c:\

The folder structure should look something like this

c:\
 
* lab02
  * nginx1
  * nginx2
  * nginx-lb
  * nginx-base

###  2 Creating NGINX base image
This section will outline the steps that will be used to deploy the base image required using Dockerfile.

You can take a look at the content of nginx-base Dockerfile at c:\lab02\nginx-base\dockerfile
The content is re-produced below

```
#NGINX-base dockerfile 
FROM mcr.microsoft.com/windows/servercore:ltsc2019

#download rtmp nginx zip from github
#Extract files to c:\, rename folder to nginx and delete nginx-rtmp-win32.zip
#rename the extracted folder to c:\nginx
#delete the zip file
RUN powershell.exe -Command \
  $ErrorActionPreference = 'Stop'; \
  Invoke-WebRequest 'https://github.com/illuspas/nginx-rtmp-win32/archive/dev.zip' -OutFile 'c:\nginx-rtmp-win32.zip' ;\
  Expand-archive 'c:\nginx-rtmp-win32.zip' 'c:\' ;\
  Rename-item 'c:\nginx-rtmp-win32-dev' 'c:\nginx' ;\
  Remove-Item 'c:\nginx-rtmp-win32.zip' -Force


#Label
LABEL maintainer="me@email.local"
```

The basic steps are

- use servercore:ltsc2019 as base image
- Run powershell commands that performed the following
  - download rtmp nginx zip from github
  - Extract the zip to c:\
  - Rename the extracted folder to nginx
  - delete the zip file
- Set maintainer label

**2.1 Building the NGINX base image**

Run the following docker command to build nginx base image
> cd c:\lab02\nginx-base

> docker build . -t nginx-base

To verify, run

> docker images

You should see the nginx-base image.

Each steps in the dockerfile layered the changes on top of each other.

You can observe this by typing the following command

>docker history nginx-base

Question: Notice that multiple powershell command are stringed together in one Run Powershell command. Why is this better than executing each command with a seperate Run Powershell command?


**2.2 Building the rest of the containers**

The dockerfile for each container is located in the c:\lab02\nginx?? folder. But noticed that they are all blank. This is intentional. You can take reference from the dockerfile in lab01 for each container (nginx1, nginx2 etc), but you will need to change the FROM instruction for things to work. If you are feeling lazy, you can use the dockerfile.ans but please try not to.

*Make sure you have modified the dockerfile before continuing*

Building nginx1 image
>cd c:\lab02\nginx1
>docker build . -t nginx1-image

Building nginx2 image
>cd c:\lab02\nginx2
>docker build . -t nginx2-image

Building nginx lb image
>cd c:\lab02\nginx-lb
>docker build . -t nginx-lb-image

Verify image creation with the appropriate commands.

**2.3 Running and testing the containers**

You can refer to lab01 section 2.2, 2.3 and 2.4 for the steps for these, I will not repeat them here again as they are the same.

You should be able to browse, push video stream via OBS and view the streaming video from the nginx web page if everything was done correctly.


###  3 Additional challenges
If you have completed the above lab, congratulations!

Here are some additional challenges for you. (Warning, only semi guded)

Clean up all containers and images if you want by using *docker rm* and *docker rmi*

**3.1 Creating the base image using the local zip file**

If you browse to c:\lab02\nginx-base, you wil see a file named 'nginx-rtmp-win32-dev.zip'. Your "mission" is to modify the nginx-base dockerfile to use this zip file instead of downloading from the internet as per the original dockerfile.

Re-build the nginx-base image using this docker file as per section 2.2.

**3.2 Publishing your base image to docker hub**

What if you need to run the nginx-base image again on another computer without having to re-build it all the time?

One of the way is to push it to a container registry, such as docker hub.

The objective of this challenge is to push the nginx-base image to docker hub container registry. The high level steps is as follow

- Create an account at https://hub.docker.com/ if you have not done so already
- Login to the docker hub account from your lab workstation using the docker cli
> docker login
- Enter your username and password, your login should be sucessful
- Re-tag the nginx-base image with your account name
> docker tag nginx-base:latest (your_acct_name)/nginx-base:1.0 
- List the images. Note the image id of nginx-base:latest and (your_acct_name)/nginx-base:1.0
- Push the image to your repository
> docker push (your_acct_name)/nginx-base:1.0  
- Note the size of the "pushed" image. Is it as big as the original image? Why not?
- Browse to your repository https://cloud.docker.com/repository/list, logon with your account. You should see the container image that you have just pushed.

Next, you can re-build your container image using the base image in the cloud container registry.
- Remove your local images
> docker rmi (your_acct_name)/nginx-base:1.0 
> docker rmi nginx-base
> docker rmi nginx1-image
> docker rmi nginx2-image
> docker rmi nginx-lb-image
- modify the dockerfile for nginx1, nginx2 and nginx-lb in c:\lab02 folder, so that the FROM instruction is from the nginx-base image in your docker hub registry
> FROM (your_acct_name)/nginx-base:1.0
- Re-build the image for nginx1, nginx2 and nginx-lb as per section 2.2
- Test out the container as per section 2.3

### End