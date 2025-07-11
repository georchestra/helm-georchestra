# 1.9.0

- Add ability to set podAnnotations (#156)
- Remove all chown in the initContainers and replace with a cron (#160)
- Add support for ES 8 (#153 and #159)

# 1.8.1
- remove chmod permission initcontainer on geoserver_tiles (#148)
- fix the healthcheck for geoserver related to control flow (#151)

# 1.8.0

- add ability to customize all docker images through values.yaml (#147)
- remove all jmx + monitoring in the helm chart (#136)

# 1.7.0

- change the way how automatic restart of the Deployments on geOrchestra datadir works. (#130)  
  now you can only restart some applications based on which folder in the datadir was modified.

# 1.6.0

- add support for requests and limits into the helm chart. (#127)  
  with a part in the README about that

# 1.5.0
- disable cas and header by default. (#129)  
   you need to enable them back if you still want them.

# 1.4.0

- add automatic restart of the Deployments on geOrchestra datadir changes (#126)

# 1.3.0

- add hostAliases (#109)
- add required values validation for database secrets (#113)

# 1.2.0

- remove extractorapp and mapfishapp (#106)

# 1.1.0

- Add support for geowebcache (#103)
- Disable geOrchestra analytics by default (doesn't work with gateway)
- Fix PostgreSQL usage builtin the helm chart
- Switch geoserver rolling strategy to rolling update

# 1.0.1

Changelog after 2 years!!! Stable release 1.0!

- Update RabbitMQ and PostgreSQL Helm charts
- Change healthcheck to a local layer for avoiding geoserver to be down due to external databases being down. (#88)
- Remove override of entrypoint of geonetwork component (#31)
- Upgrade to Elasticsearch 7.17.21 for Geonetwork (#89)
- geOrchestra gateway now by default in the helm chart!

# 0.2.11

"Label ALL THE THING !"

Setting a more convenient label to be able to select each pod individually. Before this,
when trying to connect onto a pod with `kubectl exec` we could end up in the wrong one,
because the same labels were shared across each objects.

# 0.2.10

variables for the `ogc_api_records` geonetwork microservice have been renamed.

Please double-check your `values.yaml` before upgrading to this version.

# 0.2.9

Persistent volumes have been reworked:

Some cloud providers automatically create & assign a PV to a PVC. This is the
case for our projects running on the `Azure` cloud services.

Some other need to create a PV first, then map the PVC to the manually created
PV, using the `spec.volumeName` property on the PVC yaml description.

If you want to use this version, please review your `values.yaml` file to make
sure it complies with the expected structure.

# 0.2.8

Setting `strategy.type: Recreate` for each component making use of PV/PVC.

# 0.2.7

Being able to use a secret for images on private registries

# 0.2.6

Variabilizing in the `values.yaml` file the docker images to be deployed

# 0.2.5

CAS - being able to override the themes / templates if provided in the datadir

# 0.2.4

Geoserver - being able to pass environment variables

# 0.2.2

Adding some basic tests on the most common georchestra webapps

# 0.2.1

Renaming 'app' label to something more precise ('org.georchestra.service/name')

# 0.2.0

Minor changes (updating description of the chart)

# 0.1.0

Initial commit, created via `helm create`.
