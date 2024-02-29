# thub

All of the TraingHub applications, including OJT, are packaged in this Helm chart; there is a sub-chart for each application.

## Installing the Chart

To install the chart with the release name `thub`:

```console
helm install thub hypercision/thub
```

## Uninstalling the Chart

To uninstall the `thub` deployment:

```console
helm uninstall thub
```

## Developing the Helm charts

Any change to a chart requires a version bump following [SemVer](https://semver.org/) principles.

To see what manifest files would be generated and applied when installing one of our helm charts,
run a command like one of the following in the root directory of the repository:

```console
helm install --generate-name --dry-run --debug charts/thub -f hclabs-dev.yaml -n hclabs-dev
helm install --generate-name --dry-run --debug charts/thub/charts/keycloak-config
helm install --generate-name --dry-run --debug charts/thub/charts/keycloak-config -f keycloak-config-staging.yaml -n keycloak
helm install --generate-name --dry-run --debug charts/thub/charts/user-service
helm install --generate-name --dry-run --debug charts/thub/charts/assigned-item-service
```

Note that you will need to supply a values file for most, if not all, of the charts
since we purposefully do not set default values for things such as passwords and usernames.
You can use the `hclabs-dev.yaml` file found in the [`thub-deploy` repository](https://github.com/hypercision/thub-deploy#helm-values-files)
or you could use the [test-values file](/charts/thub/ci/test-values.yaml) we use for testing in our CircleCI pipeline i.e.

```console
helm install --generate-name --dry-run --debug charts/thub -f charts/thub/ci/test-values.yaml
```

Also note that most of the subcharts cannot be installed standalone (such as `user-service`)
because they rely on global values defined in the parent chart.
