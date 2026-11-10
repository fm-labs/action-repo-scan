#!/bin/bash
set -euo pipefail

#print_debug_env() {
#  echo "=== Environment variables ==="
#  env | sort
#  echo
#  echo "=== GitHub-provided variables (GITHUB_*) ==="
#  env | sort | grep '^GITHUB_' || echo "No GITHUB_* variables found."
#  echo "==========================================="
#}

# Check input
# INPUT_PATH: Sub-path to scan (default: None, meaning root of the repo)
# INPUT_DEBUG: Enable debug output (true/false, default: false)

#if [[ "${INPUT_DEBUG:-false}" == "true" ]]; then
#  print_debug_env
#fi

# Determine the scan path
SCAN_PATH=$GITHUB_WORKSPACE
if [[ -n "$INPUT_PATH" && "$INPUT_PATH" != "." ]]; then
  SCAN_PATH="$GITHUB_WORKSPACE/$INPUT_PATH"
fi

echo "Repo Scan Action - Entrypoint"
echo "Input: path: $INPUT_PATH"
#echo "Input: debug: $INPUT_DEBUG"
echo ""
echo "Scan path: $SCAN_PATH"
echo ""

# Write the result somewhere the runner can see it (bind-mounted from the host)
RESULT_DIR="$GITHUB_WORKSPACE/.repo-scan"
mkdir -p "$RESULT_DIR"
OUTPUT_FILE="$RESULT_DIR/scan-result.json"

# Execute the custom script and capture both stdout and stderr
echo "Executing custom scan script..."
set +e  # Temporarily disable exit on error to capture exit code
#/usr/local/bin/script.sh "$SCAN_PATH" 2>&1 | tee "$OUTPUT_FILE"
cd /app || exit 1
uv run ./scan.py "$SCAN_PATH" "$OUTPUT_FILE" 2>&1
SCRIPT_EXIT_CODE=$?
set -e  # Re-enable exit on error

echo ""
echo "Script execution completed with exit code: $SCRIPT_EXIT_CODE"

# Read the captured output
SCAN_OUTPUT=$(cat "$OUTPUT_FILE")
echo "-- SCAN OUTPUT START --"
cat "$OUTPUT_FILE"
echo "-- SCAN OUTPUT END --"

# Set GitHub Action outputs
# The output needs to be properly escaped for multiline content
if [ -n "$GITHUB_OUTPUT" ]; then
  #{
  #  echo "scan-output<<EOF"
  #  cat "$OUTPUT_FILE"
  #  echo "EOF"
  #} >> "$GITHUB_OUTPUT"

  # Path as seen from the runner: /github/workspace inside == ${{ github.workspace }} outside,
  # so return a workspace-relative path
  echo "scan-file=.repo-scan/scan-result.json" >> "$GITHUB_OUTPUT"
  echo "exit-code=$SCRIPT_EXIT_CODE" >> "$GITHUB_OUTPUT"

  # keep the inline output too, with a unique delimiter
  DELIM="EOF_$(openssl rand -hex 8 2>/dev/null || date +%s%N)"
  { echo "scan-output<<$DELIM"; cat "$OUTPUT_FILE"; echo "$DELIM"; } >> "$GITHUB_OUTPUT"

  
  echo ""
  echo "GitHub Action outputs have been set:"
  echo "- scan-output: Contains the full scan output"
  echo "- scan-file": Path to scan result json file
  echo "- exit-code: $SCRIPT_EXIT_CODE"
fi

## Clean up temporary file
#rm -f "$OUTPUT_FILE"

# Exit with the same code as the script
exit $SCRIPT_EXIT_CODE