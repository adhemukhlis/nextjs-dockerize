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