#!/bin/bash

# Check if the correct number of arguments is provided
if [ "$#" -ne 4 ]; then
  echo "Usage: $0 <SPACEKIT_HASH> <PACKAGE_NAME> <TARGET_NAME> <SPACEKIT_VERSION>"
  exit 1
fi

# Arguments from the terminal
SPACEKIT_HASH=$1
PACKAGE_NAME=$2
TARGET_NAME=$3
SPACEKIT_VERSION=$4

# Folder names
TEMPLATE_FOLDER="TemplateSpaceKitABIGenerator"
TEMPLATE_SOURCES="${TEMPLATE_FOLDER}//Sources/SpaceKitABIGenerator"
TARGET_FOLDER="SpaceKitABIGenerator"
TARGET_SOURCES="${TARGET_FOLDER}/Sources/SpaceKitABIGenerator"

# File names
TEMPLATE_MAIN="${TEMPLATE_SOURCES}/TemplateMain.swift"
TEMPLATE_PACKAGE="${TEMPLATE_FOLDER}/TemplatePackage.swift"
TARGET_MAIN="${TARGET_SOURCES}/main.swift"
TARGET_PACKAGE="${TARGET_FOLDER}/Package.swift"

# Remove the target folder if it exists and create a new one
if [ -d "$TARGET_FOLDER" ]; then
  rm -rf "$TARGET_FOLDER"
fi
mkdir "$TARGET_FOLDER"

# Remove the sources folder if it exists and create a new one
if [ -d "$TARGET_SOURCES" ]; then
  rm -rf "$TARGET_SOURCES"
fi
mkdir -p "$TARGET_SOURCES"

# Function to replace placeholders in a file and save as a new file
replace_placeholders() {
  local input_file=$1
  local output_file=$2

  sed \
    -e "s/##SPACEKIT_HASH##/$SPACEKIT_HASH/g" \
    -e "s/##PACKAGE_NAME##/$PACKAGE_NAME/g" \
    -e "s/##TARGET_NAME##/$TARGET_NAME/g" \
    -e "s/##SPACEKIT_VERSION##/$SPACEKIT_VERSION/g" \
    "$input_file" > "$output_file"
}

# Copy and modify TemplateMain.swift
if [ -f "$TEMPLATE_MAIN" ]; then
  replace_placeholders "$TEMPLATE_MAIN" "$TARGET_MAIN"
else
  echo "Error: $TEMPLATE_MAIN not found."
  exit 1
fi

# Copy and modify TemplatePackage.swift
if [ -f "$TEMPLATE_PACKAGE" ]; then
  replace_placeholders "$TEMPLATE_PACKAGE" "$TARGET_PACKAGE"
else
  echo "Error: $TEMPLATE_PACKAGE not found."
  exit 1
fi

echo "SpaceKitABIGenerator has been successfully created with the specified parameters."
