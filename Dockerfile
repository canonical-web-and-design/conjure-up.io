# syntax=docker/dockerfile:experimental

# Build stage: Install ruby dependencies
# ===
FROM ruby:2.6 AS build-jekyll
WORKDIR /srv
ADD . .
RUN bundle install
RUN bundle exec jekyll build

# Build stage: Install yarn dependencies
# ===
FROM node:10-slim AS yarn-dependencies
WORKDIR /srv
ADD package.json .
RUN --mount=type=cache,target=/usr/local/share/.cache/yarn yarn install

# Build stage: Run "yarn run build-js"
# ===
FROM yarn-dependencies AS build-js
ADD . .
RUN yarn run build-js

# Build stage: Run "yarn run build-css"
# ===
FROM yarn-dependencies AS build-css
ADD . .
RUN yarn run build-css


# Import code, build assets and mirror list
RUN rm -rf package.json yarn.lock .babelrc webpack.config.js
COPY --from=build-jekyll srv/_site .
COPY --from=build-css srv/css css
COPY --from=build-js srv/js js

ARG BUILD_ID
ADD nginx.conf /etc/nginx/sites-enabled/default
RUN sed -i "s/~BUILD_ID~/${BUILD_ID}/" /etc/nginx/sites-enabled/default

STOPSIGNAL SIGTERM

# Setup commands to run server
CMD ["nginx", "-g", "daemon off;"]
