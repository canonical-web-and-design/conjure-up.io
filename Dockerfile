# syntax=docker/dockerfile:experimental

# Build stage: Install python dependencies
# ===
FROM ubuntu:bionic AS python-dependencies
RUN apt-get update && apt-get install --no-install-recommends --yes python3-pip python3-setuptools
ADD requirements.txt /tmp/requirements.txt
RUN --mount=type=cache,target=/root/.cache/pip pip3 install --user --requirement /tmp/requirements.txt




FROM ubuntu:xenial

RUN apt-get update && apt-get install --yes nginx

# Set git commit ID
ARG REVISION_ID
RUN test -n "${REVISION_ID}"

# Copy over files
WORKDIR /srv
ADD _site .
ADD nginx.conf /etc/nginx/sites-enabled/default
RUN sed -i "s/~REVISION_ID~/${REVISION_ID}/" /etc/nginx/sites-enabled/default

STOPSIGNAL SIGTERM

CMD ["nginx", "-g", "daemon off;"]

# syntax=docker/dockerfile:experimental

# Build stage: Install yarn dependencies
# ===
FROM node:10-slim AS yarn-dependencies
WORKDIR /srv
ADD package.json .
RUN --mount=type=cache,target=/usr/local/share/.cache/yarn yarn install

# Build stage: Run "yarn run build-css"
# ===
FROM yarn-dependencies AS build-css
ADD . .
RUN yarn run build


# Build the production image
# ===
FROM ubuntu:bionic
RUN apt-get update && apt-get --no-install-recommends --yes install nginx

# Set up environment
ENV LANG C.UTF-8
WORKDIR /srv


# Import code, build assets and mirror list
ADD . .
RUN rm -rf package.json yarn.lock .babelrc webpack.config.js
COPY --from=build-css /srv/css css
ENV PATH="/root/.local/bin:${PATH}"

ARG BUILD_ID
WORKDIR /srv
ADD _site .
ADD nginx.conf /etc/nginx/sites-enabled/default
RUN sed -i "s/~BUILD_ID~/${BUILD_ID}/" /etc/nginx/sites-enabled/default

# Setup commands to run server
CMD ["nginx", "-g", "daemon off;"]



# syntax=docker/dockerfile:experimental

# Build stage: Install python dependencies
# ===
FROM ubuntu:bionic AS python-dependencies
RUN apt-get update && apt-get install --no-install-recommends --yes python3-pip python3-setuptools
ADD requirements.txt /tmp/requirements.txt
RUN --mount=type=cache,target=/root/.cache/pip pip3 install --user --requirement /tmp/requirements.txt

# Build stage: Install yarn dependencies
# ===
FROM node:10-slim AS yarn-dependencies
WORKDIR /srv
ADD package.json .
RUN --mount=type=cache,target=/usr/local/share/.cache/yarn yarn install

# Build stage: Run "yarn run build-css"
# ===
FROM yarn-dependencies AS build-css
ADD static/sass static/sass
RUN yarn run build-css

# Set up environment
ENV LANG C.UTF-8
WORKDIR /srv

# Build the production image
# ===
FROM ubuntu:bionic

# Install python and import python dependencies
RUN apt-get update && apt-get install --no-install-recommends --yes python3-lib2to3 python3-pkg-resources
COPY --from=python-dependencies /root/.local/lib/python3.6/site-packages /root/.local/lib/python3.6/site-packages
COPY --from=python-dependencies /root/.local/bin /root/.local/bin
ENV PATH="/root/.local/bin:${PATH}"

# Import code, build assets and mirror list
ADD . .
RUN rm -rf package.json yarn.lock .babelrc webpack.config.js
COPY --from=build-css /srv/static/css static/css
ADD http://launchpad.net/ubuntu/+cdmirrors-rss etc/ubuntu-mirrors-rss.xml


# Set build ID
ARG BUILD_ID
ENV TALISKER_REVISION_ID "${BUILD_ID}"


# Setup commands to run server
ENTRYPOINT ["./entrypoint"]
CMD ["0.0.0.0:80"]
