#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

INITIAL_DIR=$(pwd)

# Define the installation paths
INSTALL_PATH="$HOME/.space"
mkdir -p $INSTALL_PATH

INSTALL_BIN_PATH="$INSTALL_PATH/space"

# Create a temporary directory
TEMP_DIR=$(mktemp -d)
trap "echo \"Removing temp directories...\" && rm -rf $TEMP_DIR" EXIT INT TERM ERR

# Retrieve the first argument if provided
SPACEKIT_VERSION="$1"

# Validate the argument: must be either 'local' or a version in 'a.b.c' format (or not specified)
if [ -n "$SPACEKIT_VERSION" ]; then
    if [[ ! "$SPACEKIT_VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ && "$SPACEKIT_VERSION" != "local" ]]; then
        echo "Error: Invalid SPACEKIT_VERSION '$SPACEKIT_VERSION'. Must be 'local' or a semantic version (e.g., 1.2.3)."
        exit 1
    fi
fi

# Clone or copy the repository based on the argument
if [ "$SPACEKIT_VERSION" = "local" ]; then
    echo "Copying local repository to $TEMP_DIR..."
    rsync -av --exclude='.git' --exclude='.build' --exclude='.space' --exclude='docs' ./ "$TEMP_DIR/"
else
    echo "Cloning from GitHub repository to $TEMP_DIR..."
    rm -rf "$TEMP_DIR" # Ensure TEMP_DIR is clean
    git clone --depth 1 "https://github.com/gfusee/SpaceKit.git" "$TEMP_DIR"
fi

# Navigate into the cloned directory
cd "$TEMP_DIR" || exit 1

# Resolve version if not explicitly provided
if [ -z "$SPACEKIT_VERSION" ]; then
    echo "Retrieving the latest version tag from the cloned repository..."

    # Get the list of tags sorted by version
    TAGS=$(git tag -l --sort=-v:refname | grep -E '^[0-9]+\.[0-9]+\.[0-9]+$')

    if [ -z "$TAGS" ]; then
        echo "Error: No valid version tags found in the repository."
        exit 1
    fi

    # Function to check if a tag exists on GHCR
    check_docker_tag() {
        local tag=$1
        local token=$(curl -s "https://ghcr.io/token?scope=repository:gfusee/spacekit/spacekit-cli:pull" | jq -r '.token')
        local status_code=$(curl -H "Authorization: Bearer $token" \
                                -H "Accept: application/vnd.oci.image.index.v1+json, application/vnd.docker.distribution.manifest.list.v2+json" \
                                -s -o /dev/null -w "%{http_code}" \
                                "https://ghcr.io/v2/gfusee/spacekit/spacekit-cli/manifests/$tag")

        if [ "$status_code" -eq 200 ]; then
            return 0  # Exists
        else
            return 1  # Not found
        fi
    }

    # Loop through tags and find the first one with an existing Docker image
    for tag in $TAGS; do
        echo "Checking if Docker image exists for tag: $tag..."
        if check_docker_tag "$tag"; then
            SPACEKIT_VERSION="$tag"
            echo "Found existing Docker image for tag: $SPACEKIT_VERSION"
            break
        fi
    done

    # If no valid image tag was found, exit with an error
    if [ -z "$SPACEKIT_VERSION" ]; then
        echo "Error: No matching Docker image found for any version tag."
        exit 1
    fi
fi

# If local was provided, set the version to 0.0.0
if [ "$SPACEKIT_VERSION" = "local" ]; then
    SPACEKIT_VERSION="0.0.0"
fi

echo "Resolved SpaceKit version: ${SPACEKIT_VERSION}"

# If "local" was provided, skip Git operations
if [ "$SPACEKIT_VERSION" != "0.0.0" ]; then
    echo "Checking out to tag $SPACEKIT_VERSION..."
    git fetch --tags
    git checkout "tags/$SPACEKIT_VERSION" -b "release-$SPACEKIT_VERSION"
fi

echo "let spaceKitVersion = \"$SPACEKIT_VERSION\"" > $TEMP_DIR/Sources/CLI/utils/version/spaceKitVersion.swift

# Create the installation directory if it doesn't exist
mkdir -p "$INSTALL_PATH"

# Build the Swift product
swift build --product SpaceKitCLI

# Copy the built product to the installation bin path
cp -f .build/debug/SpaceKitCLI "$INSTALL_BIN_PATH"
chmod +x "$INSTALL_BIN_PATH"

# Check if the installation path is already in the PATH environment variable
if [[ ":$PATH:" != *":$INSTALL_PATH:"* ]]; then
    echo "Adding $INSTALL_PATH to PATH..."

    # Append the path to ~/.bashrc if using Bash
    if [ -f "$HOME/.bashrc" ]; then
        sed -i -e '$a\' "$HOME/.bashrc" && echo "export PATH=\"\$PATH:$INSTALL_PATH\"" >> "$HOME/.bashrc"
        echo "PATH updated in ~/.bashrc"
        source "$HOME/.bashrc"
    fi

    # Append the path to ~/.zshrc if using Zsh
    if [ -f "$HOME/.zshrc" ]; then
        sed -i -e '$a\' "$HOME/.zshrc" && echo "export PATH=\"\$PATH:$INSTALL_PATH\"" >> "$HOME/.zshrc"
        echo "PATH updated in ~/.zshrc"
    fi

    echo "$INSTALL_PATH has been added to your PATH."
    echo "Please restart your terminal or run 'source ~/.zshrc' if using zsh."
else
    echo "$INSTALL_PATH is already in your PATH. No changes made."
fi
