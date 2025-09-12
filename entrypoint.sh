#!/bin/bash
set -euo pipefail

print_debug_env() {
  echo "=== Environment variables ==="
  env | sort
  echo
  echo "=== GitHub-provided variables (GITHUB_*) ==="
  env | sort | grep '^GITHUB_' || echo "No GITHUB_* variables found."
  echo "==========================================="
}

# Check input (GitHub normalizes booleans to lowercase strings "true"/"false")
if [[ "${INPUT_DEBUG:-false}" == "true" ]]; then
  print_debug_env
fi

# get github action inputs from env variables
SCAN_PATH=$GITHUB_WORKSPACE
if [[ -n "$INPUT_PATH" && "$INPUT_PATH" != "." ]]; then
  SCAN_PATH="$GITHUB_WORKSPACE/$INPUT_PATH"
fi

echo "Repo Scan Action - Entrypoint"
echo "Input: path: $INPUT_PATH"
echo "Input: debug: $INPUT_DEBUG"
echo ""
echo "Scan path: $SCAN_PATH"
echo ""

# Create a temporary file to capture the script output
OUTPUT_FILE=$(mktemp)

# Execute the custom script and capture both stdout and stderr
echo "Executing custom scan script..."
set +e  # Temporarily disable exit on error to capture exit code
#/usr/local/bin/script.sh "$SCAN_PATH" 2>&1 | tee "$OUTPUT_FILE"
cd /app || exit 1
uv run ./scan.py "$SCAN_PATH" 2>&1 | tee "$OUTPUT_FILE"
SCRIPT_EXIT_CODE=$?
set -e  # Re-enable exit on error

echo ""
echo "Script execution completed with exit code: $SCRIPT_EXIT_CODE"

# Read the captured output
SCAN_OUTPUT=$(cat "$OUTPUT_FILE")

# Set GitHub Action outputs
# The output needs to be properly escaped for multiline content
if [ -n "$GITHUB_OUTPUT" ]; then
  {
    echo "scan-output<<EOF"
    cat "$OUTPUT_FILE"
    echo "EOF"
  } >> "$GITHUB_OUTPUT"

  echo "exit-code=$SCRIPT_EXIT_CODE" >> "$GITHUB_OUTPUT"
  
  echo ""
  echo "GitHub Action outputs have been set:"
  echo "- scan-output: Contains the full scan output"
  echo "- exit-code: $SCRIPT_EXIT_CODE"
else
  echo ""
  echo "GitHub Action outputs (would be set if GITHUB_OUTPUT was available):"
  echo "- scan-output: Contains the full scan output"
  echo "- exit-code: $SCRIPT_EXIT_CODE"
fi

# Clean up temporary file
rm -f "$OUTPUT_FILE"

# Exit with the same code as the script
exit $SCRIPT_EXIT_CODE