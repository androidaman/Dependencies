#!/bin/bash

# Dependency File (Update this file name if different)
DEP_FILE="dependencies.txt"

# Create a temporary file for updates
TMP_FILE="dependencies_new.txt"

# Read each dependency and get the latest version
while IFS='=' read -r dependency current_version; do
    # Extract dependency name (group:artifact)
    dep_name=$(echo "$dependency" | tr -d ' ')

    # Fetch latest version using Gradle/Maven metadata
    latest_version=$(curl -s "https://search.maven.org/solrsearch/select?q=g:$dep_name&rows=1&wt=json" | jq -r '.response.docs[0].latestVersion')

    # Check if an update is needed
    if [[ ! -z "$latest_version" && "$latest_version" != "null" && "$latest_version" != "$current_version" ]]; then
        echo "$dep_name=$latest_version" >> "$TMP_FILE"
        echo "Updated: $dep_name from $current_version to $latest_version"
    else
        echo "$dep_name=$current_version" >> "$TMP_FILE"
    fi
done < "$DEP_FILE"

# Replace old dependencies file with updated one
mv "$TMP_FILE" "$DEP_FILE"
