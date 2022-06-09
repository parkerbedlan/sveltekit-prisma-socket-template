@echo off

echo First, start a publicly hosted server running Dokku. Redirect a domain you own to that server's IP address using an A Record.
set /p serveripaddress="server ip address: "
set /p domain="domain to run the app on (e.g. subdomain.mydomain.com or mydomain.com): "

pause
echo Then, create an account and repo at https://hub.docker.com/
set /p username="dockerhub username: "
set /p reponame="dockerhub repo name: "

pause
set /p appname="dokku app name (e.g. my-app): "
set /p email="email address (for notifications about ssl certificate): "


@REM generate deploy.bat
echo @echo off > deploy2.bat
echo call npm run build >> deploy2.bat
echo echo old tags: >> deploy2.bat
echo docker image ls %username%/%reponame% >> deploy2.bat
echo echo. >> deploy2.bat
echo set /p tagname="What should the next tag name be? " >> deploy2.bat
echo docker build -t %username%/%reponame%:%%tagname%% . >> deploy2.bat
echo docker push %username%/%reponame%:%%tagname%% >> deploy2.bat
echo ssh root@%serveripaddress% "docker pull %username%/%reponame%:%%tagname%% && dokku git:from-image %appname% %username%/%reponame%:%%tagname%%" >> deploy2.bat


ssh root@%serveripaddress% "dokku apps:create <app-name> && dokku domains:set <app-name> <my-domain.com> && dokku proxy:ports-set <app-name> http:80:8080 && dokku postgres:create <app-name>-db && dokku postgres:link <app-name>-db <app-name>"
call ./deploy.bat
ssh root@%serveripaddress% "dokku plugin:install https://github.com/dokku/dokku-letsencrypt.git || true && dokku config:set --no-restart <app-name> DOKKU_LETSENCRYPT_EMAIL=<e-mail> && dokku letsencrypt:enable <app-name>"
start "" https://<my-domain.com>


echo -------------------------------------------------------------------------
echo Run ./deploy.bat anytime you want to deploy changes made to the codebase!
echo -------------------------------------------------------------------------