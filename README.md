# conjure-up.io

***Archived: The https://cloud-init.io website has been retired, and the traffic redirected to https://juju.is. The repository will now be archived.***

---

[![CircleCI build status](https://circleci.com/gh/canonical-web-and-design/conjure-up.io.svg?style=shield)](https://circleci.com/gh/canonical-web-and-design/conjure-up.io) [![Code coverage](https://codecov.io/gh/canonical-web-and-design/conjure-up.io/branch/master/graph/badge.svg)](https://codecov.io/gh/canonical-web-and-design/conjure-up.io)

Deployments so easy it's almost magical.

## Local development

The simplest way to run the site locally is to first [install Docker](https://docs.docker.com/engine/installation/) (on Linux you may need to [add your user to the `docker` group](https://docs.docker.com/engine/installation/linux/linux-postinstall/)), and then use the `./run` script:

``` bash
./run
```

Once the containers are setup, you can visit <http://127.0.0.1:8005> in your browser.

### Building CSS

For working on [Sass files](static/css), you may want to dynamically watch for changes to rebuild the CSS whenever something changes.

To setup the watcher, open a new terminal window and run:

``` bash
./run watch
```

# Deploy
You can find the deployment config in the deploy folder.
