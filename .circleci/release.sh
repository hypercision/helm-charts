#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

# GitHub Auth Token. We're using the token of user hclabsbuildkite
: "${CR_TOKEN:?Environment variable CR_TOKEN must be set}"
: "${GIT_REPOSITORY_URL:?Environment variable GIT_REPOSITORY_URL must be set}"
: "${GIT_USERNAME:?Environment variable GIT_USERNAME must be set}"
: "${GIT_EMAIL:?Environment variable GIT_EMAIL must be set}"
: "${AWS_REGION:?Environment variable AWS_REGION must be set}"
: "${ECR_URL:?Environment variable ECR_URL must be set}"

readonly REPO_ROOT="${REPO_ROOT:-$(git rev-parse --show-toplevel)}"

export HELM_EXPERIMENTAL_OCI=1

main() {
    pushd "$REPO_ROOT" > /dev/null

    echo "Fetching tags..."
    git fetch --tags

    local latest_tag
    latest_tag=$(find_latest_tag)

    local latest_tag_rev
    latest_tag_rev=$(git rev-parse --verify "$latest_tag")
    echo "$latest_tag_rev $latest_tag (latest tag)"

    local head_rev
    head_rev=$(git rev-parse --verify HEAD)
    echo "$head_rev HEAD"

    if [[ "$latest_tag_rev" == "$head_rev" ]]; then
        echo "No code changes. Nothing to release."
        exit
    fi

    # TODO: install the AWS CLI or have this executed on a different image since I think the aws-cli orb needs phython
    echo "Authenticate the Helm client to the Amazon ECR registry..."
    aws ecr get-login-password \
     --region "$AWS_REGION" | helm registry login \
     --username AWS \
     --password-stdin "$ECR_URL"


    rm -rf .cr-release-packages
    mkdir -p .cr-release-packages

    rm -rf .cr-index
    mkdir -p .cr-index

    echo "Identifying changed charts since tag '$latest_tag'..."

    local changed_charts=()
    readarray -t changed_charts <<< "$(git diff --find-renames --name-only "$latest_tag_rev" -- charts | cut -d '/' -f 2 | uniq)"

    if [[ -n "${changed_charts[*]}" ]]; then
        add_chart_repos

        for chart in "${changed_charts[@]}"; do
            echo "Packaging chart '$chart'..."
            package_chart "charts/$chart"
        done

        release_charts
        update_index
    else
        echo "Nothing to do. No chart changes detected."
    fi

    popd > /dev/null
}

find_latest_tag() {
    if ! git describe --tags --abbrev=0 2> /dev/null; then
        git rev-list --max-parents=0 --first-parent HEAD
    fi
}

add_chart_repos() {
    helm repo add bitnami https://charts.bitnami.com/bitnami
}

package_chart() {
    local chart="$1"
    helm package "$chart" --destination .cr-release-packages --dependency-update
    # TODO edit this command so it return's the version of the chart
    chart_version=$(helm show chart "$chart")
    # TODO figure out how to extract the chart's name so that is parameterized too
    chart_name="thub"
    helm chart save "$chart" "342628741687.dkr.ecr.us-west-2.amazonaws.com/helm-charts/$chart_name:$chart_version"
    helm chart push "$chart" "342628741687.dkr.ecr.us-west-2.amazonaws.com/helm-charts/$chart_name:$chart_version"
}

release_charts() {
    cr upload -o hypercision -r helm-charts
}

update_index() {
    cr index -o hypercision -r helm-charts -c https://hypercision.github.io/helm-charts

    git config user.email "$GIT_EMAIL"
    git config user.name "$GIT_USERNAME"

    git reset --hard
    git checkout gh-pages
    cp --force .cr-index/index.yaml index.yaml
    git add index.yaml
    git commit --message="Update index.yaml" --signoff
    git push "$GIT_REPOSITORY_URL" gh-pages
}

main
