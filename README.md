# **RTMP NGINX docker lab**

# Background
I was looking for some application to demonstrate the container concept. Most of the examples on the web involve either simple application or more complex stuff that requires you to copy and paste code that only a developer can understand. As I am an infrastructure guy, I am looking for a no code application that is also complex enough to illustruate various container concept.

I chance upon RTMP and NGINX and these will be the focus for this lab.

The initial focus for the lab will be to explore containers on Windows servers but can be expanded to other platform, such as Linux.

# Objective
To have a lab that is targeted at IT Professioinal looking to learn containers and Dockers.

# Lab architecture
The lab will demonstrate how to stream video content to NGINX via RTMP. The live stream is then viewed via HLS from the NGINX.

See the diagram below for the various components
![alt text](https://github.com/chunkyen/rtmp-nginx-docker-lab/blob/master/rtmp-nginx-docker-lab-arch.jpg?raw=true)
