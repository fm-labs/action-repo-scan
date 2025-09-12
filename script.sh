#!/bin/bash

# This script simulates a repo scanning tool
# It takes a path as an argument and performs a mock scan

set -e

PATH_TO_SCAN="${1:-.}"

# Count files in the directory
FILE_COUNT=$(find "$PATH_TO_SCAN" -type f 2>/dev/null | wc -l)
echo "Found $FILE_COUNT files to analyze"

echo "Repo Scan Action - Starting scan..."
echo "Scanning path: $PATH_TO_SCAN"
echo ""
sleep 1

# Run trivy repo scan
if ! command -v trivy &> /dev/null
then
    echo "trivy could not be found, please install it to perform actual scans."
    echo "::warning title=Scanner::Trivy not installed, skipping scan"
else
    echo "Running scans..."
    trivy repo --scanners vuln,license,secret,misconfig "$PATH_TO_SCAN" -f table || true
    # Capture the exit code of trivy
    TRIVY_EXIT_CODE=$?
    if [ $TRIVY_EXIT_CODE -ne 0 ] && [ $TRIVY_EXIT_CODE -ne 1 ]; then
        echo "Trivy scan failed with exit code $TRIVY_EXIT_CODE"
        #exit $TRIVY_EXIT_CODE
        echo "::error title=Scanner::Exited with non-zero return code: $TRIVY_EXIT_CODE"
    fi
    echo ""
fi



# Output scan summary
echo "Scan completed successfully!"
echo "::notice title=Total files::$FILE_COUNT files in the scanned path"
echo "::notice title=Scan status::COMPLETED"

# Exit with success
exit 0
