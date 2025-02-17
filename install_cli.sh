#!/bin/zsh

# Exit immediately if a command exits with a non-zero status
set -e

INITIAL_DIR=$(pwd)

# Define the installation paths
INSTALL_PATH="$HOME/.space"
INSTALL_BIN_PATH="$INSTALL_PATH/space"

# Create a temporary directory
TEMP_DIR=$(mktemp -d)
trap "echo \"Removing temp directories...\" && rm -rf $TEMP_DIR" EXIT INT TERM ERR

cd $TEMP_DIR
git clone https://github.com/gfusee/SpaceKit.git
cd SpaceKitCLI

# Create the installation directory if it doesn't exist
mkdir -p "$INSTALL_PATH"

# Build the Swift product
swift build --product SpaceKitCLI

# Copy the built product to the installation bin path
cp -f .build/debug/SpaceKitCLI "$INSTALL_BIN_PATH"

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
