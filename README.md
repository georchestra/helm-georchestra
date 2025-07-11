# Helm charts geOrchestra project

This repository holds all the Helm charts for the geOrchestra project.

Here is the list:
- [geOrchestra](./georchestra/): Official Helm chart to install geOrchestra in Kubernetes.
- [Maelstro](./maelstro/): For deploying [Maelstro](https://github.com/georchestra/maelstro)

# WARNING: New structure for the Helm charts

The geOrchestra helm is now under a subfolder and the GitHub repository name has changed.

- Make sure to change the git remote if you are using the helm chart as a submodule. And now point to the subfolder "georchestra".

- When using OCI, change from:  
  ```
  oci://ghcr.io/georchestra/helm-georchestra/georchestra
  ```
  to:
  ```
  oci://ghcr.io/georchestra/helm-charts/georchestra
  ```

# How to publish a new version of an helm chart

Consult the README.md located in the Helm chart directory.

# How to create a new helm chart

1. Create a new branch.
2. Create a new folder with the name of your helm chart.
3. Do your changes inside the folder.
3. Make sure to add it to dependabot: [dependabot.yml](https://github.com/georchestra/helm-charts/blob/main/.github/dependabot.yml)
4. Make a commit and create a pull request. Wait for someone to review it.
