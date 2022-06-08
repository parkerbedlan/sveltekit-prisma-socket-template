# SvelteKit with Prisma Template
### Implements Prisma in a SvelteKit app and deploys to a Dokku server.

#### Before running:
1. Create a Postgres database on your machine for testing
2. Create a file called `.env` and put inside: `DATABASE_URL="postgres://<postgres-username>:<postgres-password>@localhost:5432/<postgres-schema>"`
3. Create an empty file called `.env.production`
4. `npm i`
5. `npx prisma generate` and `npx prisma migrate dev`
6. `npm run dev`

#### Steps to deploy:
##### Setting up the server:
1. Create a Docker Hub repo
2. Buy a DigitalOcean Linux Droplet with Dokku pre-installed
3. Buy a domain from Namecheap (e.g. `my-domain.com`) and create an `A Record` directed towards the `<server-ip-address>` of the Droplet
4. Set up the Dokku app
	```
	ssh root@<server-ip-address>
	dokku apps:create <app-name>
	dokku domains:set <app-name> my-domain.com
	dokku proxy:ports-set <app-name> http:80:8080
	dokku postgres:create <app-name>-db
	dokku postgres:link <app-name>-db <app-name>
	# *Push to the server* (instructions below)
	# first time: dokku plugin:install https://github.com/dokku/dokku-letsencrypt.git
	dokku letsencrypt:enable <app-name> # this automatically sets https:443:8080 if it works
	```
##### Pushing to the server:
1. Build with `npm run build`
2. Containerize the code using Docker and upload to Docker Hub:
	```
	docker build -t <dockerhub-username>/<repo-name>:<tag-name> .
	docker push <dockerhub-username>/<repo-name>:<tag-name>
	```
3. Deploy it to your Dokku app:
	```
	ssh root@<server-ip-address>
	docker pull <dockerhub-username>/<repo-name>:<tag-name>
	dokku git:from-image <app-name> <dockerhub-username>/<repo-name>:<tag-name>
	```
	> Note: If coding on a Windows computer, `deploy_windows.bat` will run the above pushing steps for you.
