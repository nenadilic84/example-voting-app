FROM node:5.11.0-slim

WORKDIR /src
ADD . /src

ADD package.json /app/package.json
RUN npm config set registry http://registry.npmjs.org
RUN npm install && npm ls

LABEL tugbot.test=true
LABEL tugbot.results.dir=/src/test-results
LABEL tugbot.event.docker=start

CMD ["npm", "test"]

