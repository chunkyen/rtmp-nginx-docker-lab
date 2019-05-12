#NGINX1 dockerfile 
FROM mcr.microsoft.com/windows/servercore:ltsc2019 

#copy nginx1 files
COPY /nginx1-src /nginx

WORKDIR /nginx

#run command after container startup
CMD ["/nginx/nginx.exe"]