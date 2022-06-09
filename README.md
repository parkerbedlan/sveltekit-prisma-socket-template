# SvelteKit with Prisma and Socket<span>.<span/>IO Template
### Implements [Prisma](https://www.prisma.io/) and [Socket.IO](https://socket.io/) in a [SvelteKit](https://kit.svelte.dev/) app that  deploys to a [Dokku](https://dokku.com/) server.


## Running the dev server
0. `degit parkerbedlan/sveltekit-prisma-socket-template`
1. `npm i`
2. Update `_.env` and `_.env.local` as described by the comments in the files.
3. Update `prisma/schema.prisma` to your liking and then run `npx prisma generate` and `npx prisma migrate dev`
4. `npm run dev`

## Deploying to Dokku (for developers using Windows)
1. Run `setup_dokku.bat` and walk through its instructions.
2. To deploy code changes, run `deploy.bat` (which gets generated when you run `setup_dokku.bat`)

## Deploying to Dokku (manually)
### Setting up the server:
1. Update `_.env.production` as described by the comment in the file.
2. Create a Docker Hub repo
3. Buy a DigitalOcean Linux Droplet with Dokku pre-installed
4. Buy a domain from Namecheap (e.g. `my-domain.com`) and create an `A Record` directed towards the `<server-ip-address>` of the Droplet
5. Set up the Dokku app
	```
	ssh root@<server-ip-address>
	dokku apps:create <app-name>
	dokku domains:set <app-name> my-domain.com
	dokku proxy:ports-set <app-name> http:80:8080
	dokku postgres:create <app-name>-db
	dokku postgres:link <app-name>-db <app-name>
	# *Deploy to the server* (instructions below)
	dokku plugin:install https://github.com/dokku/dokku-letsencrypt.git
	dokku letsencrypt:enable <app-name> # this automatically sets https:443:8080 if it works
	```
### Deploying code changes:
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
