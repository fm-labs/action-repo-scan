

def parse_trivy_results_vulns(trivy_results):
    """
    Parse Trivy scan results to extract vulnerabilities.

    Args:
        trivy_results (list): List of Trivy scan results.

    Returns:
        list: List of parsed vulnerabilities.
    """
    vulnerabilities = []
    for result in trivy_results:
        if 'Vulnerabilities' in result and result['Vulnerabilities']:
            for vuln in result['Vulnerabilities']:
                vulnerability = {
                    'Target': result.get('Target', ''),
                    'Type': result.get('Type', ''),
                    'VulnerabilityID': vuln.get('VulnerabilityID', ''),
                    'PkgName': vuln.get('PkgName', ''),
                    'InstalledVersion': vuln.get('InstalledVersion', ''),
                    'FixedVersion': vuln.get('FixedVersion', ''),
                    'Severity': vuln.get('Severity', ''),
                    'Title': vuln.get('Title', ''),
                    'Description': vuln.get('Description', ''),
                    'References': vuln.get('References', []),
                }
                vulnerabilities.append(vulnerability)
    return vulnerabilities


def parse_trivy_results_misconfigs(trivy_results):
    """
    Parse Trivy scan results to extract misconfigurations.

    Args:
        trivy_results (list): List of Trivy scan results.

    Returns:
        list: List of parsed misconfigurations.
    """
    misconfigurations = []
    for result in trivy_results:
        if 'Misconfigurations' in result and result['Misconfigurations']:
            for misconf in result['Misconfigurations']:
                misconfiguration = {
                    'Target': result.get('Target', ''),
                    'Type': result.get('Type', ''),
                    'ID': misconf.get('ID', ''),
                    'Title': misconf.get('Title', ''),
                    'Description': misconf.get('Description', ''),
                    'Severity': misconf.get('Severity', ''),
                    'References': misconf.get('References', []),
                }
                misconfigurations.append(misconfiguration)
    return misconfigurations


def parse_trivy_results_licenses(trivy_results):
    """
    Parse Trivy scan results to extract license issues.

    Args:
        trivy_results (list): List of Trivy scan results.

    Returns:
        list: List of parsed license issues.
    """
    license_issues = []
    for result in trivy_results:
        if 'Licenses' in result and result['Licenses']:
            for license in result['Licenses']:
                license_issue = {
                    'Target': result.get('Target', ''),
                    'Type': result.get('Type', ''),
                    'PkgName': license.get('PkgName', ''),
                    'InstalledVersion': license.get('InstalledVersion', ''),
                    'License': license.get('License', ''),
                    'Severity': license.get('Severity', ''),
                    'Title': license.get('Title', ''),
                    'Description': license.get('Description', ''),
                    'References': license.get('References', []),
                }
                license_issues.append(license_issue)
    return license_issues


def parse_trivy_results_secrets(trivy_results):
    """
    Parse Trivy scan results to extract secrets.

    Args:
        trivy_results (list): List of Trivy scan results.

    Returns:
        list: List of parsed secrets.
    """
    secrets = []
    for result in trivy_results:
        if 'Secrets' in result and result['Secrets']:
            for secret in result['Secrets']:
                secret_issue = {
                    'Target': result.get('Target', ''),
                    'Type': result.get('Type', ''),
                    'RuleID': secret.get('RuleID', ''),
                    'Category': secret.get('Category', ''),
                    'Severity': secret.get('Severity', ''),
                    'Title': secret.get('Title', ''),
                    'Description': secret.get('Description', ''),
                    'Match': secret.get('Match', ''),
                    'StartLine': secret.get('StartLine', 0),
                    'EndLine': secret.get('EndLine', 0),
                    'References': secret.get('References', []),
                }
                secrets.append(secret_issue)
    return secrets


def parse_trivy_results(trivy_results):
    """
    Parse Trivy scan results to extract vulnerabilities, misconfigurations, license issues, and secrets.

    Args:
        trivy_results (list): List of Trivy scan results.

    Returns:
        dict: Dictionary containing parsed vulnerabilities, misconfigurations, license issues, and secrets.
    """
    return {
        'vulnerabilities': parse_trivy_results_vulns(trivy_results),
        'misconfigurations': parse_trivy_results_misconfigs(trivy_results),
        'license_issues': parse_trivy_results_licenses(trivy_results),
        'secrets': parse_trivy_results_secrets(trivy_results),
    }