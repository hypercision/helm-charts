# hyperCision Helm Charts

This repo holds Helm charts that we use for deploying our applications. We are using GitHub pages as a means for hosting a Helm chart repository for these charts.

Add the repo as follows:

```console
$ helm repo add hypercision https://hypercision.github.io/helm-charts
```

## Developing the Helm charts

Any change to a chart requires a version bump following [semver](https://semver.org/) principles.
If you version bump a child chart, you must also version bump the parent chart.
