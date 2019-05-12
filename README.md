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
![alt text](https://github.com/chunkyen/rtmp-nginx-docker-lab/blob/master/rtmp-nginx-docker-lab-arch1.jpg?raw=true)
- Open Broadcaster Studio (OBS) will stream the video to NGINX1 via RTMP (via port 1935)
- Client will connect to the HLS webpage running on the NGINX servers (via HTTP port 80)
- NGINX-LB container will load balance and proxy the HLS webpage  to the backend container (NGINX1 via port 8080  and NGINX2 via port 8081)
- NGINX1 container will receive RTMP from the OBS (via port 1935). It will also push the video stream to NGINX2 container (via port 1936) so that it is also viewable from there. NGINX1 will also host the HLS webpage (via port 8080) for client to stream video.
-  NGINX2 container will receive RTMP from NGINX1 (via port 1936). It will also host the HLS webpage (via port 8081) for client to stream video.
- NGINX-LB function as a load balancer to proxy the client request (via port 80) to the 2 backend NGINX container (8080 and 8081)
