# Storing our Helm Charts in AWS ECR

Helm 3 supports OCI for package distribution so we could store our helm charts privately in AWS ECR repos,
although currently OCI support is considered experimental so I'm not sure we should use it.

You have to enable OCI support for Helm 3

    export HELM_EXPERIMENTAL_OCI=1

Then authenticate your Helm client to the Amazon ECR registry to which you intend to push your Helm chart.

    aws ecr get-login-password \
     --region us-west-2 | helm registry login \
     --username AWS \
     --password-stdin 342628741687.dkr.ecr.us-west-2.amazonaws.com

To package your chart, run

    helm chart save charts/thub 342628741687.dkr.ecr.us-west-2.amazonaws.com/helm-charts/thub:<chart-version>

And then push your chart:

    helm chart push 342628741687.dkr.ecr.us-west-2.amazonaws.com/helm-charts/thub:<chart-version>

Another could pull the chart:

    helm chart pull 342628741687.dkr.ecr.us-west-2.amazonaws.com/helm-charts/thub:<chart-version>

And then to install the chart on a cluster, they'd need to first export the chart to a local directory.

    helm chart export 342628741687.dkr.ecr.us-west-2.amazonaws.com/helm-charts/thub:<chart-version>
    helm install thub ./helm-charts/thub

## Documentation

https://helm.sh/docs/topics/registries/

https://medium.com/@Oskarr3/giving-your-charts-a-home-in-docker-registry-d195d08e4eb3

https://docs.aws.amazon.com/AmazonECR/latest/userguide/push-oci-artifact.html


