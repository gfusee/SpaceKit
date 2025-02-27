#!/bin/bash

# Check if URL is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <git-https-url>"
  exit 1
fi

# Set the Git URL
GIT_URL=$1
REPO_NAME=$(basename "$GIT_URL" .git)

# Clone the repository as a bare clone in the current directory
if [ -d "$REPO_NAME" ]; then
  echo "Directory $REPO_NAME already exists. Please remove it or specify a different repository."
  exit 1
fi

git clone --quiet --bare "$GIT_URL" "$REPO_NAME"

# Check if clone was successful
if [ $? -ne 0 ]; then
  echo "Failed to clone repository from $GIT_URL"
  exit 1
fi

# Change into the cloned repository directory
cd "$REPO_NAME" || exit 1

# Create the dynamic script
OUTPUT_SCRIPT="../get_tag_hash.sh"
echo "#!/bin/bash" > "$OUTPUT_SCRIPT"
echo "" >> "$OUTPUT_SCRIPT"
echo "# This script takes a tag as input and prints its hash" >> "$OUTPUT_SCRIPT"
echo "" >> "$OUTPUT_SCRIPT"

# Add function to lookup tag hash
echo "function get_tag_hash() {" >> "$OUTPUT_SCRIPT"
echo "  local tag=\$1" >> "$OUTPUT_SCRIPT"
echo "  case \"\$tag\" in" >> "$OUTPUT_SCRIPT"

# Populate case statements for each tag
git show-ref --tags | while read -r hash ref; do
  tag_name=$(basename "$ref" | sed 's/refs\/tags\///')
  echo "    \"$tag_name\") echo \"$hash\" ;;" >> "$OUTPUT_SCRIPT"
done

# End the function
echo "    *) echo \"Tag not found\" ;;" >> "$OUTPUT_SCRIPT"
echo "  esac" >> "$OUTPUT_SCRIPT"
echo "}" >> "$OUTPUT_SCRIPT"
echo "" >> "$OUTPUT_SCRIPT"

# Add script usage and main execution
echo "if [ -z \"\$1\" ]; then" >> "$OUTPUT_SCRIPT"
echo "  echo \"Usage: \$0 <tag>\"" >> "$OUTPUT_SCRIPT"
echo "  exit 1" >> "$OUTPUT_SCRIPT"
echo "fi" >> "$OUTPUT_SCRIPT"
echo "" >> "$OUTPUT_SCRIPT"
echo "# Call the function with provided tag" >> "$OUTPUT_SCRIPT"
echo "get_tag_hash \"\$1\"" >> "$OUTPUT_SCRIPT"

# Make the generated script executable
chmod +x "$OUTPUT_SCRIPT"
echo "Generated script: $OUTPUT_SCRIPT"

# Clean up by removing the bare repository
cd ..
rm -rf "$REPO_NAME"
