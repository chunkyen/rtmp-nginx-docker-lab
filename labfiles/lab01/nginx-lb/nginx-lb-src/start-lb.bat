@ECHO OFF
REM Start Nginx
tasklist /FI "IMAGENAME eq nginx.exe" 2>NUL | find /I /N "nginx.exe">NUL
IF NOT "%ERRORLEVEL%"=="0" (
   REM Nginx is NOT running, so start it
   c:
   cd \nginx
   start nginx.exe -c .\conf\nginx-lb.conf
   ECHO Nginx started.
) else (
   ECHO Nginx is already running.
)