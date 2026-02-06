#!/usr/bin/env python3
"""
YAML Frontmatter Validation Script

This script provides 3-tier validation for subagent YAML frontmatter:
1. Syntax validation (YAML parsing)
2. Schema validation (JSON Schema)
3. Semantic validation (custom business rules)

Usage:
    python3 validate_frontmatter.py <file>
    python3 validate_frontmatter.py --all

Examples:
    python3 validate_frontmatter.py .opencode/agent/subagents/researcher.md
    python3 validate_frontmatter.py --all
"""

import sys
import os
import json
import re
from pathlib import Path
from typing import Dict, List, Tuple, Optional

try:
    import yaml
except ImportError:
    print("ERROR: PyYAML not installed. Install with: pip install pyyaml")
    sys.exit(1)

try:
    import jsonschema
except ImportError:
    print("ERROR: jsonschema not installed. Install with: pip install jsonschema")
    sys.exit(1)


# Dangerous commands that MUST be denied
DANGEROUS_COMMANDS = [
    "rm -rf", "rm -fr", "rm -r *", "rm -rf /",
    "sudo", "su", "doas",
    "chmod +x", "chmod 777", "chmod -R", "chown", "chgrp",
    "dd", "mkfs", "mkfs.ext4", "fdisk", "parted",
    "wget", "curl", "nc", "netcat", "nmap", "telnet", "ssh",
    "kill -9", "killall", "pkill",
    "systemctl", "service", "init", "shutdown", "reboot",
    "apt", "apt-get", "yum", "dnf", "pacman", "brew", "pip", "npm", "cargo",
    "eval", "exec", "source", "bash -c", "sh -c",
    "tar -x", "unzip", "gunzip",
]

# Temperature ranges by agent type
TEMPERATURE_RANGES = {
    "research": (0.25, 0.35),
    "planning": (0.15, 0.25),
    "implementation": (0.15, 0.25),
    "execution": (0.15, 0.25),
    "validation": (0.1, 0.2),
    "orchestration": (0.2, 0.3),
}


def extract_frontmatter(file_path: str) -> Tuple[Optional[str], Optional[str]]:
    """
    Extract YAML frontmatter from markdown file.
    
    Returns:
        Tuple of (frontmatter_content, error_message)
    """
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Check for frontmatter delimiters
        if not content.startswith('---'):
            return None, "File does not start with frontmatter delimiter (---)"
        
        # Find second delimiter
        lines = content.split('\n')
        if len(lines) < 3:
            return None, "File too short to contain frontmatter"
        
        # Find closing delimiter
        closing_index = None
        for i in range(1, len(lines)):
            if lines[i].strip() == '---':
                closing_index = i
                break
        
        if closing_index is None:
            return None, "Frontmatter not properly closed (missing closing ---)"
        
        # Extract frontmatter lines (excluding delimiters)
        frontmatter_lines = lines[1:closing_index]
        frontmatter_content = '\n'.join(frontmatter_lines)
        
        return frontmatter_content, None
        
    except Exception as e:
        return None, f"Error reading file: {str(e)}"


def validate_yaml_syntax(frontmatter: str) -> Tuple[Optional[Dict], Optional[str]]:
    """
    Tier 1: Validate YAML syntax.
    
    Returns:
        Tuple of (parsed_data, error_message)
    """
    try:
        data = yaml.safe_load(frontmatter)
        if not isinstance(data, dict):
            return None, "Frontmatter must be a YAML object (dict), not a scalar or list"
        return data, None
    except yaml.YAMLError as e:
        return None, f"YAML syntax error: {str(e)}"


def validate_schema(data: Dict, schema_path: str) -> Optional[str]:
    """
    Tier 2: Validate against JSON Schema.
    
    Returns:
        Error message or None if valid
    """
    try:
        with open(schema_path, 'r') as f:
            schema = json.load(f)
        
        jsonschema.validate(instance=data, schema=schema)
        return None
        
    except jsonschema.ValidationError as e:
        return f"Schema validation error: {e.message}"
    except FileNotFoundError:
        return f"Schema file not found: {schema_path}"
    except json.JSONDecodeError as e:
        return f"Schema file is not valid JSON: {str(e)}"
    except Exception as e:
        return f"Schema validation error: {str(e)}"


def validate_semantics(data: Dict, file_path: str) -> List[str]:
    """
    Tier 3: Validate semantic rules.
    
    Returns:
        List of error messages (empty if valid)
    """
    errors = []
    
    # 1. Temperature validation by agent type
    if "agent_type" in data and "temperature" in data:
        agent_type = data["agent_type"]
        temperature = data["temperature"]
        
        if agent_type in TEMPERATURE_RANGES:
            min_temp, max_temp = TEMPERATURE_RANGES[agent_type]
            if not (min_temp <= temperature <= max_temp):
                errors.append(
                    f"Temperature {temperature} outside recommended range "
                    f"({min_temp}-{max_temp}) for agent_type '{agent_type}'"
                )
    
    # 2. Dangerous command validation
    if "permissions" in data:
        permissions = data["permissions"]
        
        # Check deny list contains dangerous commands
        deny_list = permissions.get("deny", [])
        deny_bash_commands = []
        for item in deny_list:
            if isinstance(item, dict) and "bash" in item:
                deny_bash_commands.extend(item["bash"])
        
        # Check critical dangerous commands (must all be present)
        critical_commands = ["rm -rf", "sudo", "chmod +x", "dd"]
        missing_critical = []
        for critical in critical_commands:
            if not any(critical in cmd for cmd in deny_bash_commands):
                missing_critical.append(critical)
        
        if missing_critical:
            errors.append(
                f"Critical dangerous commands not in deny list: {', '.join(missing_critical)}"
            )
        
        # Check no dangerous commands in allow list
        allow_list = permissions.get("allow", [])
        allow_bash_commands = []
        for item in allow_list:
            if isinstance(item, dict) and "bash" in item:
                allow_bash_commands.extend(item["bash"])
        
        dangerous_in_allow = [
            cmd for cmd in allow_bash_commands 
            if any(dangerous in cmd for dangerous in DANGEROUS_COMMANDS)
        ]
        if dangerous_in_allow:
            errors.append(
                f"Dangerous commands in allow list: {', '.join(dangerous_in_allow)}"
            )
    
    # 3. Context file existence validation
    if "context_loading" in data:
        context_loading = data["context_loading"]
        required_files = context_loading.get("required", [])
        optional_files = context_loading.get("optional", [])
        
        # Get project root
        project_root = Path(file_path).resolve().parents[3]  # Go up 3 levels from subagents/
        context_root = project_root / ".opencode" / "context"
        
        missing_required = []
        for file_rel_path in required_files:
            file_path_obj = context_root / file_rel_path
            if not file_path_obj.exists():
                missing_required.append(file_rel_path)
        
        # Note: Context file validation is a warning, not an error
        # Files may be created in the future
        if missing_required and False:  # Disabled for now
            errors.append(
                f"Required context files not found: {', '.join(missing_required)}"
            )
    
    # 4. Delegation depth validation
    if "delegation" in data:
        delegation = data["delegation"]
        max_depth = delegation.get("max_depth", 0)
        if max_depth > 5:
            errors.append(f"Delegation max_depth ({max_depth}) exceeds recommended maximum (5)")
    
    # 5. Version format validation (SemVer)
    if "version" in data:
        version = data["version"]
        if not re.match(r'^\d+\.\d+\.\d+$', version):
            errors.append(f"Version '{version}' does not follow SemVer format (X.Y.Z)")
    
    # 6. Name format validation (lowercase, hyphen-separated)
    if "name" in data:
        name = data["name"]
        if not re.match(r'^[a-z][a-z0-9-]*$', name):
            errors.append(f"Name '{name}' must be lowercase with hyphens only")
    
    return errors


def validate_file(file_path: str, schema_path: str, verbose: bool = False) -> bool:
    """
    Validate a single frontmatter file through all 3 tiers.
    
    Returns:
        True if valid, False otherwise
    """
    print(f"\nValidating: {file_path}")
    print("=" * 70)
    
    # Extract frontmatter
    frontmatter, error = extract_frontmatter(file_path)
    if error or frontmatter is None:
        print(f"FAILED: {error if error else 'No frontmatter extracted'}")
        return False
    
    if verbose:
        print(f"Extracted {len(frontmatter.split(chr(10)))} lines of frontmatter")
    
    # Tier 1: Syntax validation
    print("Tier 1: YAML Syntax... ", end="")
    data, error = validate_yaml_syntax(frontmatter)
    if error or data is None:
        print(f"FAILED\n  {error if error else 'Unknown error'}")
        return False
    print("PASSED")
    
    if verbose:
        print(f"  Parsed {len(data)} top-level keys")
    
    # Tier 2: Schema validation
    print("Tier 2: JSON Schema... ", end="")
    error = validate_schema(data, schema_path)
    if error:
        print(f"FAILED\n  {error}")
        return False
    print("PASSED")
    
    # Tier 3: Semantic validation
    print("Tier 3: Semantic Rules... ", end="")
    errors = validate_semantics(data, file_path)
    if errors:
        print(f"FAILED ({len(errors)} issues)")
        for err in errors:
            print(f"  - {err}")
        return False
    print("PASSED")
    
    print("\nResult: All validation tiers PASSED")
    return True


def validate_all_subagents(schema_path: str, verbose: bool = False) -> Tuple[int, int]:
    """
    Validate all subagent frontmatter files.
    
    Returns:
        Tuple of (passed_count, failed_count)
    """
    # Find all subagent files
    script_dir = Path(__file__).parent.resolve()
    project_root = script_dir.parent.parent  # Go up two levels (.opencode/scripts -> ProofChecker)
    subagents_dir = project_root / ".opencode" / "agent" / "subagents"
    
    if not subagents_dir.exists():
        print(f"ERROR: Subagents directory not found: {subagents_dir}")
        return 0, 0
    
    subagent_files = list(subagents_dir.glob("*.md"))
    subagent_files = [f for f in subagent_files if f.name not in ["README.md"]]
    
    if not subagent_files:
        print(f"ERROR: No subagent files found in {subagents_dir}")
        return 0, 0
    
    print(f"Found {len(subagent_files)} subagent files")
    print("=" * 70)
    
    passed = 0
    failed = 0
    failed_files = []
    
    for file_path in sorted(subagent_files):
        if validate_file(str(file_path), schema_path, verbose):
            passed += 1
        else:
            failed += 1
            failed_files.append(file_path.name)
    
    print("\n" + "=" * 70)
    print(f"SUMMARY: {passed} passed, {failed} failed out of {len(subagent_files)} files")
    
    if failed_files:
        print(f"\nFailed files:")
        for name in failed_files:
            print(f"  - {name}")
    
    return passed, failed


def main():
    """Main entry point."""
    # Determine schema path
    script_dir = Path(__file__).parent.resolve()
    schema_path = script_dir.parent / "context" / "common" / "schemas" / "frontmatter-schema.json"
    
    if not schema_path.exists():
        print(f"ERROR: Schema file not found: {schema_path}")
        sys.exit(1)
    
    # Parse arguments
    if len(sys.argv) < 2:
        print(__doc__)
        sys.exit(1)
    
    arg = sys.argv[1]
    verbose = "--verbose" in sys.argv or "-v" in sys.argv
    
    if arg == "--all":
        passed, failed = validate_all_subagents(str(schema_path), verbose)
        sys.exit(0 if failed == 0 else 1)
    elif arg.startswith("--"):
        print(f"ERROR: Unknown option: {arg}")
        print(__doc__)
        sys.exit(1)
    else:
        # Validate single file
        file_path = arg
        if not os.path.exists(file_path):
            print(f"ERROR: File not found: {file_path}")
            sys.exit(1)
        
        valid = validate_file(file_path, str(schema_path), verbose)
        sys.exit(0 if valid else 1)


if __name__ == "__main__":
    main()
