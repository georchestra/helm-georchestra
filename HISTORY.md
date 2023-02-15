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
