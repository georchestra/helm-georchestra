# About

This repository holds a helm chart for geOrchestra. This README file aims to present
some of the features and/or implementation choices.

# Maintainers

## How to create a new chart release
IMPORTANT: Don't create too many versions, test your changes using git submodules for example. Create new versions with a batch of features if possible.

1. Change and push the version in the Chart.yaml.  
   Please follow https://semver.org, if you are adding a new feature bump the MINOR version, otherwise if it's a bugfix bump the PATCH version.
2. Write a changelog in the CHANGELOG.md
3. Execute `git tag 1.X.X` (with the same version as the chart)
4. Execute `git push --tags`

# Usage

## Install

### Quick start

1. Install a Ingress Controller if you don't already have one.   
   NGINX Ingress controller is a good example:
   ````
   helm upgrade --install ingress-nginx ingress-nginx \
      --repo https://kubernetes.github.io/ingress-nginx \
      --namespace ingress-nginx --create-namespace
   ````
3. Execute these commands for installing the georchestra chart:  
   ```
   helm repo add georchestra https://charts.georchestra.org
   helm repo update
   helm install georchestra georchestra/georchestra --set fqdn=YOURDOMAIN
   ```
   Note: For the domain you can use `georchestra-127-0-1-1.traefik.me`, just replace `127-0-1-1` with the IP address of your server.

4. Go to [https://YOURDOMAIN](https://YOURDOMAIN)

### Customized installation
1. Create a new separate 'values' file (or edit the existing one, not recommended).  
   Edit the parameters like `fqdn`, `database` or `ldap` if needed.
2. Install a Ingress Controller if you don't already have one.   
   NGINX Ingress controller is a good example:
   ````
   helm upgrade --install ingress-nginx ingress-nginx \
      --repo https://kubernetes.github.io/ingress-nginx \
      --namespace ingress-nginx --create-namespace
   ````
3. Execute these commands for installing the georchestra chart:  
   ```
   helm repo add georchestra https://charts.georchestra.org
   helm repo update
   helm install -f your-values.yaml georchestra georchestra/georchestra
   ```

4. Go to [https://YOURDOMAIN](https://YOURDOMAIN)

## Upgrade

Apply only for a customized installation.

```
helm upgrade -f your-values.yaml georchestra georchestra/georchestra
```

# geOrchestra Datadir bootstrap

The helm chart provides the possibility to clone the datadir from a remote repository using git. A
secret SSH key can be provided to do so.

# JMX monitoring

A flag can be set in the `values.yaml` so that a collectd-based container is running next to the
main Java one, on the following deployments:

* `geoserver`
* `geonetwork`
* `security-proxy`

If the flag is set to `true` (e.g. `georchestra.webapps.proxy.jetty_monitoring: true`),
then a `collectd` process along with a minimal configuration to scrape common Java and Jetty specific
exposed JMX metrics will be configured. The following annotations will be set on the deployed pod as well:

```
    prometheus.io/path: /metrics
    prometheus.io/port: "9103"
    prometheus.io/scrape: "true"
```

Some `podMonitor` objects will be created as well for each concerned pods (sp, gn, gs).

As a result, if the `prometheus` operator is deployed into the cluster, it will configure itself and be able to scrape the
exposed metrics.

# Mapstore2 / geOrchestra datadir

On the mapstore2 webapp, we are using the following strategy:

* the `georchestra_datadir` is bootstrapped from a git repository the same way as the other geOrchestra components
* we mount the mapstore dynamic datadir onto `/mnt/mapstore2`

# CAS 6 theme customizations

An initContainer will take care of overriding the `themes` and `templates` subdirectory from the webapp classpath, if
such ones exist into the georchestra data directory.

As a result, it is possible to override the default georchestra theme by creating a `cas/themes` and a `cas/templates` subdirectory
into the georchestra datadir.


# About livenessProbes

The healthchecks for the different webapps have been implemented using `livenessProbe`s and `startupProbe`s.
Checking in the logs how long the webapps needed to bootstrap themselves, then multiplying the needed time per 3,
to keep a safety margin.

Here is an example with the `analytics` webapp:


```
2022-02-21 20:53:49.500:INFO:oejs.AbstractConnector:main: Started ServerConnector@587d1d39{HTTP/1.1, (http/1.1)}{0.0.0.0:8080}
2022-02-21 20:53:49.500:INFO:oejs.Server:main: Started @2865ms
```

If we round the `2865ms` to 3 seconds, then multiplying per 3 gives us 9 seconds. Let's round it to 10 seconds.

It gives the following yaml specification:

```
livenessProbe:
  httpGet:
    path: /analytics/
    port: 8080
  periodSeconds: 10
startupProbe:
  tcpSocket:
    port: 8080
  failureThreshold: 5
  periodSeconds: 10
```

Actually, the container will benefit from 5 trials of 10 seconds before failing to start. Afterwards, the containers
will be tested every 10 seconds onto its `/analytics/` endpoint during its lifetime, to check if it still alive.
If not, after 2 other trials (`failurethreshold` being set to 3), the container will be considered as failing and be restarted.

CAS takes 26 seconds to boot. Multiplying per 3 might be a bit overkill, considering 60 seconds instead. The threshold will allow 5 60-second trials anyway.

GeoNetwork is particular, as the `httpGet` request can take longer than expected depending on the wro4j cache. A custom `timeoutSeconds` has been set to 5 seconds.

About the `livenessProbe`s, we kept the default `failureThreshold` to 3, meaning that 3 successive failing attempts will need to be performed before the container is considered as failing.

The `mapstore` docker image is making use of Tomcat instead of Jetty, so we will use a `startupProbe` based on `httpGet`,
similar to the one used for `livenessProbe`, instead of a tcpSocket one which is used on the other Jetty-based containers.

The `ldap` deployment object has been configured with only a `livenessProbe`, as we cannot tell if the ldap database has
already been initialized or not. Doing some tries with a single pod, it has been estimated that 30 seconds should be
sufficient to populate the database initially.

The `datafeeder` (backend) requires now a valid account passed as a base64-encoded HTTP header (the `sec-user` header, maybe some others). As a result, testing via a HTTP request for liveness is not easy. We still can pass some headers to the request, but if it requires a valid account,
then maybe we shall stick to a simpler `tcpSocket` one.

# Update strategy

The default update strategy in kubernetes being RollingUpdate, we can fall into a situation where new containers are created but never started because waiting for the volumes to be released from the former pods.

As a result, several containers run with a `.strategy.type` set to `recreate` instead of `RollingUpdate`. This is basically the case for
every deployments which are making use of Persistent volumes:

* elasticsearch (used by GeoNetwork4)
* geonetwork
* geoserver
* mapstore
* openldap
