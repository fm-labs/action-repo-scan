import os
import subprocess

def run_trivy_repo_scan(repo: str, scanners: str, output_format: str = "json", output: str = None, env: dict = None):
    """
    Scan docker images for vulnerabilities using trivy
    """
    try:
        print(f"Run trivy for repo={repo} format={output_format} ...")
        #cmd = ["trivy", "repo", "--scanners", scanners, "--quiet", "--skip-update", "--ignore-unfixed"]
        cmd = ["trivy", "repo", "--scanners", scanners, "--quiet", "--ignore-unfixed"]
        if output_format:
            cmd += ["-f", output_format]
        if output:
            cmd += ["-o", output]
        cmd += [repo]

        print("CMD", cmd, env)
        _env = os.environ.copy()
        _env["GIT_TERMINAL_PROMPT"] = "0"  # disable git prompts
        #_env["GITHUB_TOKEN"] = os.getenv("GITHUB_TOKEN", "")  # use GitHub token if available
        if env:
            _env.update(env)
        result = subprocess.run(cmd, check=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, env=_env)

        # Print the output
        # print(result.stdout.decode())
        return result.stdout.decode()
    except subprocess.CalledProcessError as e:
        print(f"Error: {e.stderr.decode()}")
        raise e

