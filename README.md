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
