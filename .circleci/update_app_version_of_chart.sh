#!/usr/bin/env bash

# Note when testing this script that on macOS grep -oP is not supported so you can use homebrew to install grep.
# https://stackoverflow.com/a/22704387/8049180
# And for the sed commands to work you will need to add '' -e after -i
# https://stackoverflow.com/a/19457213/8049180

# GitHub Auth Token. We're using the token of user hclabsbuildkite
: "${CR_TOKEN:?Environment variable CR_TOKEN must be set}"
: "${GIT_REPOSITORY_URL:?Environment variable GIT_REPOSITORY_URL must be set}"
: "${GIT_USERNAME:?Environment variable GIT_USERNAME must be set}"
: "${GIT_EMAIL:?Environment variable GIT_EMAIL must be set}"
: "${GIT_BRANCH:?Environment variable GIT_BRANCH must be set}"
: "${application_name:?Environment variable application_name must be set}"
: "${application_version:?Environment variable application_version must be set}"

get_chart_path() {
    if [[ $application_name = 'assigned-item-service' ]]; then
        echo "charts/thub/charts/assigned-item-service"
    elif [[ $application_name = 'item-service' ]]; then
        echo "charts/thub/charts/item-service"
    elif [[ $application_name = 'lms-data-service' ]]; then
        echo "charts/thub/charts/lms-data-service"
    elif [[ $application_name = 'ojt' ]]; then
        echo "charts/thub/charts/ojt"
    elif [[ $application_name = 'user-service' ]]; then
        echo "charts/thub/charts/user-service"
    else
        echo "$1 is not a valid chart name"
        exit 1
    fi
}

commit_changes() {
    git config user.email "$GIT_EMAIL"
    git config user.name "$GIT_USERNAME"

    git checkout "$GIT_BRANCH"
    git add .
    git commit --message="Update appVersion of chart $application_name" --signoff
    git push "$GIT_REPOSITORY_URL" "$GIT_BRANCH"
}

application_chart_path="$(get_chart_path "$application_name")/Chart.yaml"
echo "application_chart_path is $application_chart_path"

# Edit the chart.yaml file of application_name, updating its appVersion bumping its chart version

search=$(grep -oP 'appVersion: v?.+' "$application_chart_path")
replace="appVersion: $application_version"
# Replace the current appVersion with the new appVersion
sed -i "s/$search/$replace/" "$application_chart_path"

# Extract the current chart version
subchart_version=$(grep -oP '(?<=^version: ).+' "$application_chart_path")
echo "subchart_version is $subchart_version"
# Get the incremented chart version
new_subchart_version=$(.circleci/version.sh "$subchart_version" bug)
echo "new_subchart_version is $new_subchart_version"

search="version: $subchart_version"
replace="version: $new_subchart_version"
# Replace the current chart version with the new chart version
sed -i "s/$search/$replace/" "$application_chart_path"

# Edit the thub chart.yaml, bumping its chart version and the version of the subchart being updated.
thub_chart_path="charts/thub/Chart.yaml"
# Extract the current chart version
chart_version=$(grep -oP '(?<=^version: ).+' $thub_chart_path)
echo "thub chart_version is $chart_version"
# Get the incremented chart version
new_chart_version=$(.circleci/version.sh "$chart_version" bug)
echo "thub new_chart_version is $new_chart_version"

search="version: $chart_version"
replace="version: $new_chart_version"
# Replace the current chart version with the new chart version
sed -i "s/$search/$replace/" $thub_chart_path

echo "About to modify and print the updated $thub_chart_path file..."
# Create a temporary file for safe editing
temp_file=$(mktemp)
# This searches for the specific subchart entry and updates its version
awk -v app_name="$application_name" -v old_version="$subchart_version" -v new_version="$new_subchart_version" '
BEGIN { in_dependencies = 0; found_chart = 0 }
/^dependencies:/ { in_dependencies = 1 }
/^[a-zA-Z]/ && !/^dependencies:/ && !/^  / { in_dependencies = 0 }
in_dependencies && /^  - name:/ {
    if ($3 == app_name) {
        found_chart = 1
        print $0
        next
    }
    found_chart = 0
}
in_dependencies && found_chart && /^    version:/ {
    if ($2 == old_version) {
        print "    version: " new_version
        found_chart = 0
        next
    }
}
{ print }
' "$thub_chart_path" >"$temp_file"

# Replace the original file with the modified version
mv "$temp_file" "$thub_chart_path"

echo "Updated $thub_chart_path file contents:"
cat "$thub_chart_path"

commit_changes
