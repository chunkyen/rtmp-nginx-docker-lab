#NGINX1 dockerfile 
FROM mcr.microsoft.com/windows/servercore:ltsc2019 

#copy nginx2 files
COPY /nginx2-src /nginx

WORKDIR /nginx

#run command after container startup
CMD ["/nginx/nginx.exe"]