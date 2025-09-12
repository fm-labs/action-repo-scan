# Repo Scan Action

A GitHub Action that scans repositories for vulnerabilities.

## Description

The script analyzes files in a specified path and provides vulnerability scan results.

## Usage

```yaml
name: Repo Scan
on: [push, pull_request]

jobs:
  scan:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    
    - name: Run Repo Scan
      id: scan
      uses: fm-labs/action-repo-scan@v1
      with:
        path: '.'  # Optional: defaults to '.'
        
    - name: Display scan results
      run: |
        echo "Exit code: ${{ steps.scan.outputs.exit-code }}"
        echo "Scan output:"
        echo "${{ steps.scan.outputs.scan-output }}"
```

## Inputs

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `path` | A path within the source code repo to scan | No | `.` |

## Outputs

| Output | Description |
|--------|-------------|
| `scan-output` | Complete output from the repo scan script |
| `exit-code` | Exit code from the scan script (0 = success) |

## Features

- Scans for vulnerabilities
- Scans for misconfigurations
- Scans for secret leaks
- Scans for license compliance issues


## License

This project is licensed under the MIT License.
