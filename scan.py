import sys
import json
from tempfile import mktemp

from reposcan.trivy_helper import run_trivy_repo_scan


def print_github_annotation(annotation: str = "warning", file: str = None, line: int = None, col: int = None, title: str = None, message: str = None):
    """
    Print a GitHub annotation to stdout
    """
    output = f"::{annotation}"
    if file:
        output += f" file={file}"
    if line:
        output += f",line={line}"
    if col:
        output += f",col={col}"
    if title:
        output += f",title={title}"
    if message:
        output += f"::{message}"
    print(output)


if __name__ == "__main__":

    arg_path = None
    if len(sys.argv) > 1:
        arg_path = sys.argv[1]

    if arg_path is None:
        print("Path argument is required")
        sys.exit(1)

    # get temp dir
    tmp_out_file = mktemp()

    print(f"Scanning path '{arg_path}' ...")
    print(f"Output file is '{tmp_out_file}'")

    try:
        run_trivy_repo_scan(arg_path, scanners="vuln,misconfig,license,secret", output_format="json", output=tmp_out_file)
        print("Scan completed. Results saved to", tmp_out_file)

        # parse the json output and print a summary
        with open(tmp_out_file, "r") as f:
            data = json.load(f)
            results = data.get("Results", [])
            print("Scan Summary:")
            for result in data.get("Results", []):
                target = result.get("Target", "unknown")
                vulnerabilities = result.get("Vulnerabilities", [])
                misconfigurations = result.get("Misconfigurations", [])
                secrets = result.get("Secrets", [])
                licenses = result.get("Licenses", [])

                print(f"- Target: {target}")
                print(f"  Vulnerabilities found: {len(vulnerabilities)}")
                print(f"  Misconfigurations found: {len(misconfigurations)}")
                print(f"  Secrets found: {len(secrets)}")
                print(f"  License issues found: {len(licenses)}")

                # Print summary in GitHub annotation format
                if vulnerabilities:
                    print_github_annotation(annotation="warning", file=target, title="Vulnerabilities found", message=f"{len(vulnerabilities)} vulnerabilities found in {target}")
                if misconfigurations:
                    print_github_annotation(annotation="warning", file=target, title="Misconfigurations found", message=f"{len(misconfigurations)} misconfigurations found in {target}")
                if secrets:
                    print_github_annotation(annotation="warning", file=target, title="Secrets found", message=f"{len(secrets)} secrets found in {target}")
                if licenses:
                    print_github_annotation(annotation="notice", file=target, title="License issues found", message=f"{len(licenses)} license issues found in {target}")

    except Exception as e:
        print("Error during scan:", e)
        sys.exit(1)