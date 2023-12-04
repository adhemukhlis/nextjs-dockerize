FROM node:20.9.0-alpine as build
WORKDIR /app
COPY . /app/

RUN test -f yarn.lock && rm yarn.lock || true
RUN yarn install --network-timeout 900000
RUN yarn build

EXPOSE 3000
CMD ["yarn", "start"]