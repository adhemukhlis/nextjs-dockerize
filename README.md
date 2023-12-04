# NextJS Dockerize

| Alias                | value                   | Description                                                                                                                                                                                        |
| -------------------- | ----------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **<NODE_VERSION>**   | `20.9.0`                | node version want to use                                                                                                                                                                           |
| **<PROJECT_PORT>**   | `3000`                  | port used by the project, it should have the same value in the `Dockerfile` in the `EXPOSE` config                                                                                                 |
| **<CONTAINER_PORT>** | `80`                    | port used by docker container, this port should be consumed by the web server like NGINX or Apache, `80` is just default of IP server port, otherwise you can use the available port on the server |
| **<IMAGE_NAME>**     | `my-next-app`           | docker image name                                                                                                                                                                                  |
| **<CONTAINER_NAME>** | `my-next-app-container` | docker container name, to make it "easier", use naming with `-container` postfix                                                                                                                   |

---

## create `Dockerfile` file

1. create `Dockerfile` in root project
2. set file with

   ```
   FROM node:<NODE_VERSION>-alpine as build
   WORKDIR /app
   COPY . /app/

   RUN test -f yarn.lock && rm yarn.lock || true
   RUN yarn install --network-timeout 900000
   RUN yarn build

   EXPOSE <PROJECT_PORT>
   CMD ["yarn", "start"]
   ```

   > find current node alpine version [here](https://hub.docker.com/_/node/tags?page=1&name=alpine)

   > for a more consistent version, try using the constant version like `node:<NODE_VERSION>-alpine`

## create `.dockerignore` file

1. create `.dockerignore` in root project
2. set file with
   ```
   .DS_Store
   node_modules
   yarn.lock
   package-lock.json
   .next
   ```

## deploy steps

1. build docker image
   ```bash
   docker build -t <IMAGE_NAME> .
   ```
   > you can replace `my-next-app` with image name you want
2. stop and remove container
   > [!WARNING]
   > (skip this if currently first deploy)
   ```bash
   docker stop <CONTAINER_NAME> && docker rm <CONTAINER_NAME>
   ```
   > you can replace `my-next-app-container` with container name you want, its different with image name, to make it "easier", use naming with `-container` postfix like `<IMAGE_NAME>-container`.
3. run container

   ```bash
   docker run -p <CONTAINER_PORT>:<PROJECT_PORT> -d --name <CONTAINER_NAME> <IMAGE_NAME>
   ```

   > replace `my-next-app-container` with your container name, and `my-next-app` with your image name.

4. remove unused image `(optional)`

   > [!NOTE]
   > This command aims to lighten the load on server storage by deleting unused docker images.

   > [!WARNING]
   > This command is not recommended if the development system uses revert/rollback version mitigation, because this command deletes the previous image version so it is not possible to revert/rollback. Alternative way, if you still want to run this command, you can still revert using git and rebuild the docker image.

   ```bash
   docker image prune --force --filter='dangling=true'
   ```

5. remove build time dependencies `(optional)`
   ```bash
   docker builder prune --force
   ```

---

# addition

## git without auth

1. add origin to your project

   ```bash
   git remote add origin_server https://<USERNAME>:<ACCESS_TOKEN>@gitlab.com/<USERNAME_OR_REPO_GROUP>/<REPO_NAME>.git
   ```

2. pull the git repo

   ```bash
   git pull origin_server development --force
   ```

## single line deploy

1. create `deploy.sh` file in root project with

   ```bash
   # Exit immediately if any command fails
   set -e

   git checkout development
   git pull origin_server development --force || true

   docker build -t my-next-app .
   docker stop my-next-app-container || true
   docker rm my-next-app-container || true
   docker run -p 3040:3000 -d --name my-next-app-container my-next-app
   docker image prune --force --filter='dangling=true'
   docker builder prune --force
   ```

2. set permission to sh file

   ```bash
   chmod +x deploy.sh
   ```

3. run the `deploy.sh`
   ```bash
   nohup ./deploy.sh &
   ```
