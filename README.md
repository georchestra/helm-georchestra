# About

This repository holds a helm chart for geOrchestra. This README file aims to present
some of the features and/or implementation choices.

# Usage

## Install

```
% helm install -f path/to/my/values.yaml georchestra .
```

## Upgrade

```
% helm upgrade -f path/to/my/values.yaml georchestra .
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

If a `prometheus` instance is deployed into the cluster, it will configure itself and be able to scrape the
exposed metrics.

# Mapstore2 / geOrchestra datadir

The strategy is a bit different compared to the other deployments from geOrchestra. `Mapstore2` requires to be able
to write into its datadir (e.g. plugins uploaded by the administrators).

Then a default datadir is present in the git repository, the Mapstore deployment provides 2 options:

* If the Mapstore2 part of the geOrchestra datadir is not present, or
* If the `FORCE_MAPSTORE_DATADIR` environment variable is set

then the Mapstore2 datadir is (re)initialized.

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
