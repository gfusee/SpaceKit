#!/bin/bash

# Run the initial test with the skip option
echo "Running the initial test with --skip ."
swift test --skip .

# Retrieve the list of tests
echo "Retrieving the list of tests"
TESTS=$(swift test list)

# Loop through each test and run it sequentially
while IFS= read -r TEST; do
    if [[ -n "$TEST" ]]; then
        echo "➡️ Running test: $TEST"
        swift test --filter "^$TEST$" --skip-build
        STATUS=$?
        if [ "$STATUS" -ne 0 ]; then
            echo "❌ A test failed, stopping execution."
            exit 1
        fi
    fi

done <<< "$TESTS"

echo "✅ All tests have been executed successfully."

