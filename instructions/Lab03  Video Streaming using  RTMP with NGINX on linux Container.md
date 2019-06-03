# LAB03 Video Streaming using RTMP with NGINX on Linux Container

In lab01, we used Windows server container to host NGINX and use RTMP to perform video streaming. In this lab we will perform the same but with Linux container.


###  1 Pre-requisites
Before proceeding, make sure you have cleared all the container and images used during previous lab.

**1.1 OS and Software**

You need either a Linux OS with container installed or use Docker for Windows Desktop in Linux container mode. The instructions here is based on Docker for Windows in Linux container mode.


**1.2 Extract the labfiles**

After cloning or downloading the repo, extract/copy lab03 folder (found in the labfiles folder) to c:\

The folder structure should look something like this

c:\
 
* lab03
  * nginx1
  * nginx2
  * nginx-lb
  * nbinx-base


**1.3 Install OBS**

_Note: You shold have this if you perform lab01._

Download and install OBS. [OBS download](https://obsproject.com/download)

You will need a video file to stream. You can use the infamous big buck bunny video. [Big buck bunny](https://peach.blender.org/download/)


###  2 Build container images with docerfile
This section will outline the steps that will be used to deploy the various container images container using Dockerfile.

**2.1 Build base image**
This base image will be the basis of the other conatiners used in this lab.

The Dockerfile for the base image container is located in the lab03 c:\lab03\nginx-base\dockerfile

Reproduced below:

```
ARG NGINX_VERSION=1.16.0
ARG NGINX_RTMP_VERSION=1.2.1

##############################
# Build the NGINX-build image.
FROM alpine:3.8 as build-nginx
ARG NGINX_VERSION
ARG NGINX_RTMP_VERSION

# Build dependencies.
RUN apk add --update \
  build-base \
  ca-certificates \
  curl \
  gcc \
  libc-dev \
  libgcc \
  linux-headers \
  make \
  musl-dev \
  openssl \
  openssl-dev \
  pcre \
  pcre-dev \
  pkgconf \
  pkgconfig \
  zlib-dev

# Get nginx source.
RUN cd /tmp && \
  wget https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz && \
  tar zxf nginx-${NGINX_VERSION}.tar.gz && \
  rm nginx-${NGINX_VERSION}.tar.gz

# Get nginx-rtmp module.
RUN cd /tmp && \
  wget https://github.com/arut/nginx-rtmp-module/archive/v${NGINX_RTMP_VERSION}.tar.gz && \
  tar zxf v${NGINX_RTMP_VERSION}.tar.gz && rm v${NGINX_RTMP_VERSION}.tar.gz

# Compile nginx with nginx-rtmp module.
RUN cd /tmp/nginx-${NGINX_VERSION} && \
  ./configure \
  --prefix=/opt/nginx \
  --add-module=/tmp/nginx-rtmp-module-${NGINX_RTMP_VERSION} \
  --conf-path=/opt/nginx/nginx.conf \
  --with-threads \
  --with-stream_ssl_module \
  --with-stream  \
  --with-file-aio \
  --with-http_ssl_module \
  --error-log-path=/opt/nginx/logs/error.log \
  --http-log-path=/opt/nginx/logs/access.log \
  --with-debug && \
  cd /tmp/nginx-${NGINX_VERSION} && make && make install

##########################
# Build the release image.
FROM alpine:3.8


RUN apk add --update \
  ca-certificates \
  openssl \
  pcre \
  lame \
  libogg \
  libass \
  libvpx \
  libvorbis \
  libwebp \
  libtheora \
  opus \
  rtmpdump \
  x264-dev \
  x265-dev

COPY --from=build-nginx /opt/nginx /opt/nginx


# Add NGINX config and static files.
ADD nginx.conf /opt/nginx/nginx.conf
RUN mkdir -p /opt/data

EXPOSE 1935
EXPOSE 80

CMD ["/opt/nginx/sbin/nginx"]
```

The basic steps are

- pull alpine as base image OS
- pull nginx/rtmp source code and compile
- complie nginx with rtmp module
- expose port 1935 and 80
- run nginx when the container starts

Run the following command to build the base image

> cd c:\lab03\nginx-base

> docker build . -t nginx-rtmp-base

**2.2 Building the rest of the images**

Before proceeding, make sure to have the nginx-rtmp-base image ready.
You can run the following command to verify

> docker images

Make sure you can see the nginx-rtmp-base image


We will run the following command to build the NGINX1 image:
> cd c:\lab03\nginx1

> docker build . -t nginx1-image

The main tasks in the dockerfile is to copy the customized nginx.conf and html files for each container to the image.

Perform the steps below to build the image for nginx2 and nginxlb

>cd c:\lab02\nginx2

>docker build . -t nginx2-image

> cd c:\lab03\nginx-lb

> docker build . -t nginx-lb-image

Run docker images to ensure you have nginx1-image, nginx2-image and nginx-lb-image.

**2.3 Running containers**

We will use the following command to run nginx2 container.
>docker run -d -p 8081:80 -p 1936:1935 --name nginx2 nginx2-image

*Note we need to start nginx2 first as we are referencing nginx2 name in the config file of nginx1. If nginx2 name cannot be found when nginx1 container starts, nginx will not start sucessfully.*

It will use the nginx2-image and the container host will proxy port 8081 - 80 and 1936 - 1935 to the container.

Run the command below to verify

> docker ps

Repeat the steps for nginx1.

It will use the nginx1-image and the container host will proxy port 8080 - 80 and 1935 - 1935 to the container.

> docker run -d -p 8080:80 -p 1935:1935 --name nginx1 --link=nginx2 nginx1-image

Note the use of the link option so that nginx1 container can communicate with nginx2 using the container name.


Next for nginx-lb, we will run the following command.

> docker run -d -p 80:80  --name nginx-lb --link=nginx1 --link=nginx2  nginx-lb-image

It will use the nginx-lb-image and the container host will only proxy port 80 - 80 to the container.

*Note similar to the note given above, nginx-lb can only start after nginx1 and nginx2 are started. *
**2.3 Testing the containers functionalities**

Next we will verify if the containers are working.

Use a browser to browse to http://localhost:8080

You should see an nginx1 page


Browse to http://localhost:8081 and you should see an nginx2 page.

If you browse to http://localhost you should see either the nginx1 or nginx2 page because the nginx-lb is distributing to the 2 backend nginx containers using round robin. You might need to refresh multiple times or close the browser and start again to see the result.

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

Clean up the containers and images used in this lab if you want by using *docker rm* and *docker rmi*

### End