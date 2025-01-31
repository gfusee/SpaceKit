#!/bin/bash

set -e
set -o pipefail

SIMULATOR_FOLDER_PATH="../../../../../Utils/Scenarios/Simulator"

echo "Running chain simulator..."

# Start the background process in a subshell with the specified working directory
(
    cd "$SIMULATOR_FOLDER_PATH" || exit
    ./chainsimulator > /dev/null 2>&1 &
    echo $! > /tmp/simulator_pid
)

# Capture its PID from the temporary file
BG_PROCESS_PID=$(cat /tmp/simulator_pid)

sleep 10

# Function to clean up the background process on script exit
cleanup() {
    echo "Stopping background process..."
    kill $BG_PROCESS_PID 2>/dev/null
    rm -f /tmp/simulator_pid
}
# Ensure cleanup is called on script exit
trap cleanup EXIT

# Main script logic
echo "Simulator is running. Background process PID: $BG_PROCESS_PID"

echo "Setting test wallet balance..."

curl -X POST http://localhost:8085/simulator/set-state \
-H "Content-Type: application/json" \
-d '[
  {
    "address": "erd1gtwpjmp7vkjcfe0pznfwt7apxu2dvnavtwv63c034slfwkumazxspalrel",
    "balance": "1000000000000000000000"
  }
]'

echo "Executing the following test: test-issue-fungible.yaml ⏳"
(yes | mxops data delete -n devnet -s spacekit_test_issue_fungible_token) || mxops execute -n devnet -s spacekit_test_issue_fungible_token test-issue-fungible.yaml
echo "test-issue-fungible.yaml passed ✅"

echo "Executing the following test: test-issue-non-fungible.yaml ⏳"
(yes | mxops data delete -n devnet -s spacekit_test_issue_non_fungible_token) || mxops execute -n devnet -s spacekit_test_issue_non_fungible_token test-issue-non-fungible.yaml
echo "test-issue-non-fungible.yaml passed ✅"

echo "Executing the following test: test-issue-semi-fungible.yaml ⏳"
(yes | mxops data delete -n devnet -s spacekit_test_issue_semi_fungible_token) || mxops execute -n devnet -s spacekit_test_issue_semi_fungible_token test-issue-semi-fungible.yaml
echo "test-issue-semi-fungible.yaml passed ✅"

echo "Executing the following test: test-issue-semi-fungible.yaml ⏳"
(yes | mxops data delete -n devnet -s spacekit_test_issue_semi_fungible_token) || mxops execute -n devnet -s spacekit_test_issue_semi_fungible_token test-issue-semi-fungible.yaml
echo "test-issue-semi-fungible.yaml passed ✅"

echo "Executing the following test: test-register-meta.yaml ⏳"
(yes | mxops data delete -n devnet -s spacekit_test_register_meta_token) || mxops execute -n devnet -s spacekit_test_register_meta_token test-register-meta.yaml
echo "test-register-meta.yaml passed ✅"

echo "Executing the following test: test-special-roles.yaml ⏳"
(yes | mxops data delete -n devnet -s spacekit_test_special_roles) || mxops execute -n devnet -s spacekit_test_special_roles test-set-special-roles.yaml
echo "test-special-roles.yaml passed ✅"
