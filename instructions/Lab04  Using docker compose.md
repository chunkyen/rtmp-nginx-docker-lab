# LAB04 Using Docker compose

In previous labs, we manually build each container image and run each container with a seperate docker command. Wouldn't it be good if we can define all these steps in a file and have it build and run automatically? This is where Docker compose come into the picture.




###  1 Pre-requisites
Before proceeding, make sure you have cleared all the container and images used during previous lab.

_Note: The pre-requisites are essencially the same as Lab03. You are strongly advised to complete Lab03 before proceeding_

**1.1 OS and Software**

You need either a Linux OS with container installed or use Docker for Windows Desktop in Linux container mode. The instructions here is based on Docker for Windows in Linux container mode.


**1.2 Extract the labfiles**

After cloning or downloading the repo, extract/copy lab04 folder (found in the labfiles folder) to c:\

The folder structure should look something like this

c:\
 
* lab04
  * nginx1
  * nginx2
  * nginx-lb
  * nbinx-base


**1.3 Install OBS**

_Note: You shold have this if you perform lab01/lab02/lab03._

Download and install OBS. [OBS download](https://obsproject.com/download)

You will need a video file to stream. You can use the infamous big buck bunny video. [Big buck bunny](https://peach.blender.org/download/)


###  2 Build the nginx container base image with dockerfile
While we can define the build steps in a docker compose file, it must still be based off a base container image. In a real world, we would have this stored in a private or public container registry. But for the purpose of this lab, we would just build the base image seperately using the provided dockerfile.

_Note: This is the same base image that we build for lab03._


The Dockerfile for the base image container is located in the lab03 c:\lab04\nginx-base\dockerfile

The basic steps are

- pull alpine as base image OS
- pull nginx/rtmp source code and compile
- complie nginx with rtmp module
- expose port 1935 and 80
- run nginx when the container starts

Run the following command to build the base image

> cd c:\lab04\nginx-base

> docker build . -t nginx-rtmp-base

###  3 Creating the docker compose file

Similar to dockerfile, docker compose need a file to define the various parameters of the container. It is a text file with a yml extension (also called a yaml file). The default file name where docker-compose command will read from is docker-compose.yml, if an alternate file name is not specified.

 The basic structures of a docker compose file is as follow:

- version - specifies the version of the Compose file reference
- services - specifies the services in your application
- networks - you can define the networking set-up of your application here
- volumes - you can define the volumes used by your applicaiton here
- secrets - secrets are related to Swarm mode only, you can use them to provide secret information like passwords in a secure way to your application services
- configs - configs lets you add external configuration to your containers. Keeping configurations external will make your containers more generic. Configs is available both in Compose and in Swarm mode

**3.1 Editing the docker-compose file**

The lab guide will only provide a sample of the docker compose file. You will have to complete the rest of the file before running the docker-compose command.

The sample docker-compose file is located in c:\lab04\docker-compose.yml

Reproduced below:

```
version: '3'


services:
  nginx2:
    build: ./nginx2
    image: nginx2-image
    ports: 
      - 8081:80
      - 1936:1935
    container_name: nginx2
    
  nginx1:
    build: 
    image: 
    ports: 
      - 
      - 
    container_name: 
    links:
      - 

  nginx-lb:
    build: 
    image: 
    ports: 
      
    container_name: 
    links:
      - 
      - 
```



The basic syntax of the compose file is:

- version - On the first line we specify the version of the Compose file format as version: '3'. Docker Compose file format has various versions as new features are added to the Compose file
- services - This section defines the different components of your application. Here we will define nginx2, nginx1 and nginx-lb
- build - where the dockerfile for each service components are located
- image - the name of the image after it is built
- ports - the port mapping of the container
- container name - the name of the container. If not specified, the default name will be assigned.
- links - if we need container to connect to each other using name, we need to specify here

_Additional Note: There is actually no need to enter the links parameters in the Docker compose file. This is because when we use a compose file to create the containers, it will automatically create a custom network. With this custom network, the containers in the compose file can reference each other using the container name_

Fill in the rest of the missing values for nginx1 and nginx-lb in the file. You can reference lab03 section 2.3 for more info.

**3.2 Executing the docker-compose command**

To execute the docker-compose command, first cd to the lab04 directory.

> cd c:\lab04

Next, run the docker-compose command with the up option (so that the conatiner starts) and -d (the detach option). Note that it will look for the docker-compose.yml file in the same directory which you have previously edited.

> docker-compose up -d

You should see that it is building each container based on the dockerfile.

You can see all 3 containers running by executing the following command:

> docker-compose ps


**3.3 Testing the containers functionalities**

Next we will verify if the containers are working.

Use a browser to browse to http://localhost:8080

You should see an nginx1 page


Browse to http://localhost:8081 and you should see an nginx2 page.

If you browse to http://localhost you should see either the nginx1 or nginx2 page because the nginx-lb is distributing to the 2 backend nginx containers using round robin. You might need to refresh multiple times or close the browser and start again to see the result.

**3.4 Streaming and viewing videos**

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

You can stop and remove all containers by running the following *docker-compose* command:

>docker-compose stop

Clean up the containers images used in this lab if you want by using *docker rmi* command

### End