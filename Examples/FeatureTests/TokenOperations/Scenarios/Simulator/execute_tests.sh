#!/bin/bash

SIMULATOR_FOLDER_PATH="../../../../../Utils/Scenarios/Simulator"

# Start the background process in a subshell with the specified working directory
(
    cd "$SIMULATOR_FOLDER_PATH" || exit
    ./chainsimulator > /dev/null 2>&1 &
    echo $! > /tmp/simulator_pid
)

# Capture its PID from the temporary file
BG_PROCESS_PID=$(cat /tmp/simulator_pid)

sleep 3

# Function to clean up the background process on script exit
cleanup() {
    echo "Stopping background process..."
    kill $BG_PROCESS_PID 2>/dev/null
    rm -f /tmp/simulator_pid
}
# Ensure cleanup is called on script exit
trap cleanup EXIT

# Main script logic
echo "Script is running. Background process PID: $BG_PROCESS_PID"

curl -X POST http://localhost:8085/simulator/set-state \
-H "Content-Type: application/json" \
-d '[
  {
    "address": "erd1gtwpjmp7vkjcfe0pznfwt7apxu2dvnavtwv63c034slfwkumazxspalrel",
    "balance": "1000000000000000000000"
  }
]'

yes | mxops data delete -n devnet -s spacekit_test_issue_tokens && mxops execute -n devnet -s spacekit_test_issue_tokens test-issue-fungible.yaml
