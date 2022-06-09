@echo off

echo -------------------------------------------------------------------------
echo First, update `_.env.production` as described by the comment in the file.
echo -------------------------------------------------------------------------
pause

echo -------------------------------------------------------------------------
echo Next, start a publicly hosted server running Dokku. Redirect a domain you own to that server's IP address using an A Record.
echo -------------------------------------------------------------------------
set /p serveripaddress="server ip address: "
set /p domain="domain to run the app on (e.g. subdomain.mydomain.com or mydomain.com): "

echo -------------------------------------------------------------------------
echo Then, create an account and repo at https://hub.docker.com/
echo -------------------------------------------------------------------------
set /p username="dockerhub username: "
set /p reponame="dockerhub repo name: "

echo -------------------------------------------------------------------------
set /p appname="dokku app name (e.g. my-app): "
set /p email="email address (for notifications about ssl certificate): "


@REM generate deploy.bat
echo @echo off > deploy.bat
echo call npm run build >> deploy.bat
echo echo old tags: >> deploy.bat
echo docker image ls %username%/%reponame% >> deploy.bat
echo echo. >> deploy.bat
echo set /p tagname="What should the next tag name be? " >> deploy.bat
echo docker build -t %username%/%reponame%:%%tagname%% . >> deploy.bat
echo docker push %username%/%reponame%:%%tagname%% >> deploy.bat
echo ssh root@%serveripaddress% "docker pull %username%/%reponame%:%%tagname%% && dokku git:from-image %appname% %username%/%reponame%:%%tagname%%" >> deploy.bat


@REM create dokku app
ssh root@%serveripaddress% "dokku apps:create %appname% && dokku domains:set %appname% %domain% && dokku proxy:ports-set %appname% http:80:8080 && dokku postgres:create %appname%-db && dokku postgres:link %appname%-db %appname%"
@REM deploy to dokku
call deploy.bat
@REM set up SSL certificate
ssh root@%serveripaddress% "dokku plugin:install https://github.com/dokku/dokku-letsencrypt.git || true && dokku config:set --no-restart %appname% DOKKU_LETSENCRYPT_EMAIL=%email% && dokku letsencrypt:enable %appname%"
start "" https://%domain%


echo -------------------------------------------------------------------------
echo Run ./deploy.bat anytime you want to deploy changes made to the codebase!
echo -------------------------------------------------------------------------