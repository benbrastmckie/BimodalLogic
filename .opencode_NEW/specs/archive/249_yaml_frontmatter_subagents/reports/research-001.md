# YAML Frontmatter Standards for AI Agent Configuration

## Research Scope

**Topic**: YAML frontmatter standards for AI agent configuration systems  
**Context**: Task 249 - Add comprehensive YAML frontmatter to all 6 subagents  
**Dependencies**: Task 245 (Phase 2 Phases 1-5 and 8 completed)  
**Research Date**: 2025-12-29  
**Tools Used**: Web research (YAML specification, Jekyll documentation), File analysis (existing subagent frontmatter)

## Executive Summary

This research identifies comprehensive YAML frontmatter standards for AI agent configuration, drawing from the YAML 1.2 specification, Jekyll frontmatter conventions, and analysis of existing subagent implementations in the ProofChecker project. The research covers five key areas: YAML syntax standards, agent configuration fields, context loading patterns, safety/validation mechanisms, and template design.

## 1. YAML Frontmatter Syntax and Structure

### 1.1 YAML 1.2 Specification Standards

**Source**: YAML Ain't Markup Language (YAML™) version 1.2.2 (2021-10-01)

**Key Syntax Rules**:
- Triple-dashed lines (`---`) delimit frontmatter blocks
- Must be first thing in file (no content before opening `---`)
- YAML uses indentation (spaces only, no tabs) for structure
- Supports three data primitives: scalars (strings/numbers), sequences (arrays), mappings (key-value pairs)
- Comments begin with `#` character
- Strings can be unquoted, single-quoted (`'`), or double-quoted (`"`)
- Multi-line strings support literal (`|`) and folded (`>`) styles

**Character Encoding**:
- UTF-8 is recommended default encoding
- Byte order mark (BOM) optional but recommended for non-UTF-8
- Printable subset of Unicode only (excludes C0 control block except TAB, LF, CR)

**Data Types**:
- Null: `null`, `Null`, `NULL`, `~`, or empty
- Boolean: `true`, `True`, `TRUE`, `false`, `False`, `FALSE`
- Integer: Decimal (`-19`), octal (`0o7`), hexadecimal (`0x3A`)
- Float: Scientific notation (`12e03`), infinity (`.inf`), NaN (`.nan`)
- String: Default type for untagged scalars

### 1.2 Jekyll Frontmatter Conventions

**Source**: Jekyll documentation (https://jekyllrb.com/docs/front-matter/)

**Standard Structure**:
```yaml
---
layout: post
title: Blogging Like a Hacker
published: true
date: 2025-12-29
category: research
tags: [yaml, frontmatter, agents]
---
```

**Predefined Global Variables**:
- `layout`: Specifies layout file to use (without extension)
- `permalink`: Custom URL for processed content
- `published`: Boolean to control visibility (default true)

**Custom Variables**:
- Any YAML-valid key-value pair
- Accessible via Liquid tags: `{{ page.variable_name }}`
- No restrictions on custom field names

**Best Practices**:
- Keep frontmatter minimal and focused
- Use consistent naming conventions (snake_case or camelCase)
- Document custom variables in project README
- Validate frontmatter with YAML linters

### 1.3 Existing ProofChecker Subagent Frontmatter

**Analysis of Current Implementation**:

All 6 subagents currently use minimal YAML frontmatter:

```yaml
---
description: "{agent_purpose}"
mode: subagent
temperature: 0.1-0.3
---
```

**Planner.md Extended Frontmatter** (Task 245 Phase 2):
```yaml
---
description: "Implementation plan creation following plan.md standard with research integration"
mode: subagent
temperature: 0.2
tools:
  - read
  - write
  - bash
  - grep
  - glob
permissions:
  allow:
    - read: [".opencode/**/*", "**/*.md"]
    - write: ["specs/**/*"]
    - bash: ["grep", "wc", "date", "mkdir"]
  deny:
    - bash: ["rm -rf", "sudo", "chmod +x"]
    - write: [".git/**/*", "**/*.lean"]
context_loading:
  lazy: true
  index: ".opencode/context/index.md"
  required:
    - "core/workflows/command-lifecycle.md"
    - "core/standards/subagent-return-format.md"
    - "core/standards/status-markers.md"
    - "core/standards/plan.md"
delegation:
  max_depth: 3
  can_delegate_to:
    - "status-sync-manager"
    - "git-workflow-manager"
  timeout_default: 1800
---
```

**Key Observations**:
- Planner.md demonstrates comprehensive frontmatter structure
- Tools array lists available tools (read, write, bash, grep, glob)
- Permissions use allow/deny lists with glob patterns
- Context loading supports lazy loading with index-based discovery
- Delegation configuration includes depth limits and timeout

## 2. Agent Configuration Fields

### 2.1 Essential Metadata Fields

**Recommended Core Fields**:

```yaml
---
# Agent Identity
name: "researcher"
version: "1.0.0"
description: "General research agent for non-Lean tasks"
mode: subagent
agent_type: research

# Execution Configuration
temperature: 0.3
max_tokens: 4000
timeout: 3600

# Capabilities
tools:
  - read
  - write
  - bash
  - webfetch
  - grep
  - glob

# Safety Configuration
permissions:
  allow:
    - read: ["**/*.md", ".opencode/**/*"]
    - write: ["specs/**/*"]
    - bash: ["grep", "find", "wc", "date"]
  deny:
    - bash: ["rm -rf", "sudo", "chmod", "dd"]
    - write: [".git/**/*", "**/*.lean"]

# Context Management
context_loading:
  strategy: lazy
  index: ".opencode/context/index.md"
  required:
    - "core/workflows/command-lifecycle.md"
    - "core/standards/subagent-return-format.md"
  optional:
    - "project/research/research-patterns.md"

# Delegation Configuration
delegation:
  max_depth: 3
  can_delegate_to:
    - "web-research-specialist"
    - "status-sync-manager"
  timeout_default: 1800
  timeout_max: 3600

# Lifecycle Integration
lifecycle:
  stage: 4
  command: "/research"
  return_format: "subagent-return-format.md"
---
```

### 2.2 Field Definitions and Types

| Field | Type | Required | Purpose | Example Values |
|-------|------|----------|---------|----------------|
| `name` | string | Yes | Agent identifier | "researcher", "planner" |
| `version` | string | Yes | Semantic version | "1.0.0", "2.1.3" |
| `description` | string | Yes | Human-readable purpose | "General research agent" |
| `mode` | string | Yes | Execution mode | "subagent", "orchestrator" |
| `agent_type` | string | Yes | Agent category | "research", "planning", "implementation" |
| `temperature` | float | Yes | LLM sampling temperature | 0.0-1.0 (research: 0.3, implementation: 0.2) |
| `max_tokens` | integer | No | Max output tokens | 4000, 8000 |
| `timeout` | integer | No | Execution timeout (seconds) | 1800, 3600 |
| `tools` | array | Yes | Available tools | ["read", "write", "bash"] |
| `permissions` | object | Yes | Access control rules | See permissions section |
| `context_loading` | object | No | Context loading config | See context section |
| `delegation` | object | No | Delegation rules | See delegation section |
| `lifecycle` | object | No | Lifecycle metadata | See lifecycle section |

### 2.3 Temperature Configuration by Agent Type

**Research Agents** (researcher.md, lean-research-agent.md):
- Temperature: 0.3
- Rationale: Moderate creativity for exploring diverse sources
- Balance: Factual accuracy vs. creative search strategies

**Planning Agents** (planner.md):
- Temperature: 0.2
- Rationale: Structured, deterministic planning
- Balance: Consistency vs. adaptive planning

**Implementation Agents** (implementer.md, lean-implementation-agent.md, task-executor.md):
- Temperature: 0.2
- Rationale: Precise, deterministic code generation
- Balance: Correctness vs. creative solutions

**Temperature Guidelines**:
- 0.0-0.1: Highly deterministic (testing, validation)
- 0.1-0.3: Structured tasks (planning, implementation)
- 0.3-0.5: Creative tasks (research, design)
- 0.5-0.7: Exploratory tasks (brainstorming)
- 0.7-1.0: Highly creative (not recommended for agents)

## 3. Tools Configuration

### 3.1 Available Tools

**Core Tools** (all agents):
- `read`: Read files from filesystem
- `write`: Write files to filesystem
- `bash`: Execute bash commands
- `grep`: Search file contents
- `glob`: Find files by pattern
- `list`: List directory contents
- `edit`: Edit files with string replacement

**Specialized Tools**:
- `webfetch`: Fetch web content (research agents)
- `lean-lsp-mcp_*`: Lean language server tools (Lean agents)
- `git`: Git operations (workflow managers)

**Tool Specification Format**:

```yaml
tools:
  - read
  - write
  - bash
  - webfetch
  - grep
  - glob
```

**Alternative Object Format** (with configuration):

```yaml
tools:
  read:
    enabled: true
    max_file_size: 10485760  # 10MB
  write:
    enabled: true
    allowed_extensions: [".md", ".json", ".yaml"]
  bash:
    enabled: true
    timeout: 30
    allowed_commands: ["grep", "find", "wc"]
  webfetch:
    enabled: true
    timeout: 60
    max_redirects: 5
```

### 3.2 Tool Permissions

**Permission Structure**:

```yaml
permissions:
  allow:
    - read: ["**/*.md", ".opencode/**/*", "docs/**/*"]
    - write: ["specs/**/*", ".opencode/context/**/*"]
    - bash: ["grep", "find", "wc", "date", "mkdir"]
  deny:
    - bash: ["rm -rf", "sudo", "chmod +x", "dd", "mkfs"]
    - write: [".git/**/*", "**/*.lean", "lakefile.lean"]
    - read: [".env", "**/*.key", "**/*.pem"]
```

**Glob Pattern Syntax**:
- `*`: Matches any characters except `/`
- `**`: Matches any characters including `/` (recursive)
- `?`: Matches single character
- `[abc]`: Matches any character in set
- `{a,b}`: Matches either pattern

**Permission Evaluation**:
1. Check deny list first (deny takes precedence)
2. If not denied, check allow list
3. If not in allow list, deny by default
4. Log all permission denials for audit

## 4. Context Loading Configuration

### 4.1 Context Loading Strategies

**Lazy Loading** (recommended):
```yaml
context_loading:
  strategy: lazy
  index: ".opencode/context/index.md"
  required:
    - "core/workflows/command-lifecycle.md"
    - "core/standards/subagent-return-format.md"
  optional:
    - "project/lean4/lean-patterns.md"
  max_context_size: 50000  # tokens
```

**Eager Loading**:
```yaml
context_loading:
  strategy: eager
  files:
    - ".opencode/context/core/workflows/command-lifecycle.md"
    - ".opencode/context/core/standards/subagent-return-format.md"
  max_context_size: 50000
```

**Filtered Loading**:
```yaml
context_loading:
  strategy: filtered
  index: ".opencode/context/index.md"
  filters:
    - category: "workflows"
    - category: "standards"
    - language: "lean"
  max_context_size: 50000
```

### 4.2 Context File Reference Formats

**Relative Paths** (from `.opencode/context/`):
```yaml
required:
  - "core/workflows/command-lifecycle.md"
  - "core/standards/plan.md"
  - "project/lean4/lean-patterns.md"
```

**Absolute Paths**:
```yaml
required:
  - ".opencode/context/core/workflows/command-lifecycle.md"
  - ".opencode/context/core/standards/plan.md"
```

**Index-Based Discovery**:
```yaml
context_loading:
  index: ".opencode/context/index.md"
  categories:
    - workflows
    - standards
  tags:
    - lean
    - research
```

### 4.3 Context Loading Levels

**Level 0: Isolated** (no context):
- Agent receives only task parameters
- No access to project context
- Use for: Simple, stateless operations

**Level 1: Task-Only**:
- Agent receives task description and parameters
- No access to broader project context
- Use for: Focused, single-purpose tasks

**Level 2: Standards + Rules**:
- Agent receives task + relevant standards/rules
- Limited project context
- Use for: Validation, formatting, structured tasks

**Level 3: Full Context**:
- Agent receives task + full project context
- Access to all relevant documentation
- Use for: Complex, multi-faceted tasks

## 5. Safety and Validation

### 5.1 Dangerous Command Patterns

**Critical Deny List** (all agents):

```yaml
permissions:
  deny:
    # Destructive filesystem operations
    - bash: ["rm -rf", "rm -fr", "rm -r *", "rm -rf /"]
    
    # Privilege escalation
    - bash: ["sudo", "su", "doas"]
    
    # Permission changes
    - bash: ["chmod +x", "chmod 777", "chown"]
    
    # Disk operations
    - bash: ["dd", "mkfs", "fdisk", "parted"]
    
    # Network operations
    - bash: ["wget", "curl", "nc", "netcat"]
    
    # Process manipulation
    - bash: ["kill -9", "killall", "pkill"]
    
    # System modification
    - bash: ["systemctl", "service", "init"]
    
    # Package management
    - bash: ["apt", "yum", "dnf", "pacman", "brew"]
    
    # Sensitive file access
    - read: [".env", "**/*.key", "**/*.pem", "**/*.p12", ".ssh/**/*"]
    
    # Critical file modification
    - write: [".git/**/*", "**/*.lean", "lakefile.lean", "lean-toolchain"]
```

**Pattern Matching**:
- Exact match: `"rm -rf"` matches only exact string
- Prefix match: `"rm -rf*"` matches any command starting with "rm -rf"
- Regex match: `/^rm\s+-rf/` matches "rm -rf" with any whitespace

### 5.2 YAML Validation Tools

**Recommended Validation Approach**:

1. **Syntax Validation** (YAML parser):
   ```python
   import yaml
   
   def validate_yaml_syntax(content):
       try:
           yaml.safe_load(content)
           return True, None
       except yaml.YAMLError as e:
           return False, str(e)
   ```

2. **Schema Validation** (JSON Schema):
   ```yaml
   # frontmatter-schema.json
   {
     "$schema": "http://json-schema.org/draft-07/schema#",
     "type": "object",
     "required": ["name", "version", "description", "mode", "tools", "permissions"],
     "properties": {
       "name": {"type": "string", "pattern": "^[a-z-]+$"},
       "version": {"type": "string", "pattern": "^\\d+\\.\\d+\\.\\d+$"},
       "description": {"type": "string", "minLength": 10},
       "mode": {"type": "string", "enum": ["subagent", "orchestrator"]},
       "temperature": {"type": "number", "minimum": 0.0, "maximum": 1.0},
       "tools": {"type": "array", "items": {"type": "string"}},
       "permissions": {
         "type": "object",
         "required": ["allow", "deny"],
         "properties": {
           "allow": {"type": "array"},
           "deny": {"type": "array"}
         }
       }
     }
   }
   ```

3. **Semantic Validation** (custom rules):
   ```python
   def validate_frontmatter_semantics(data):
       errors = []
       
       # Check temperature range by agent type
       if data.get('agent_type') == 'implementation':
           if data.get('temperature', 0) > 0.3:
               errors.append("Implementation agents should use temperature <= 0.3")
       
       # Check required context files exist
       if 'context_loading' in data:
           for file in data['context_loading'].get('required', []):
               if not os.path.exists(f".opencode/context/{file}"):
                   errors.append(f"Required context file not found: {file}")
       
       # Check delegation depth
       if 'delegation' in data:
           if data['delegation'].get('max_depth', 0) > 5:
               errors.append("Delegation max_depth should not exceed 5")
       
       return errors
   ```

### 5.3 Permission Enforcement Mechanisms

**Pre-Execution Validation**:

```python
def check_permission(action, resource, permissions):
    """
    Check if action on resource is permitted.
    
    Args:
        action: Tool name (read, write, bash)
        resource: Resource path or command
        permissions: Permissions dict from frontmatter
    
    Returns:
        (allowed: bool, reason: str)
    """
    # Check deny list first
    for deny_rule in permissions.get('deny', []):
        if action in deny_rule:
            patterns = deny_rule[action]
            for pattern in patterns:
                if matches_pattern(resource, pattern):
                    return False, f"Denied by rule: {pattern}"
    
    # Check allow list
    for allow_rule in permissions.get('allow', []):
        if action in allow_rule:
            patterns = allow_rule[action]
            for pattern in patterns:
                if matches_pattern(resource, pattern):
                    return True, "Allowed"
    
    # Default deny
    return False, "Not in allow list (default deny)"

def matches_pattern(resource, pattern):
    """Match resource against glob pattern."""
    import fnmatch
    return fnmatch.fnmatch(resource, pattern)
```

**Runtime Enforcement**:

```python
def execute_with_permissions(tool, args, permissions):
    """Execute tool with permission checking."""
    # Extract resource from args
    if tool == 'read':
        resource = args.get('filePath')
    elif tool == 'write':
        resource = args.get('filePath')
    elif tool == 'bash':
        resource = args.get('command')
    else:
        resource = str(args)
    
    # Check permission
    allowed, reason = check_permission(tool, resource, permissions)
    
    if not allowed:
        raise PermissionError(f"Permission denied: {reason}")
    
    # Execute tool
    return execute_tool(tool, args)
```

### 5.4 Frontmatter Parsing Validation

**Validation Checklist**:

- [x] YAML syntax is valid (no parse errors)
- [x] All required fields present (name, version, description, mode, tools, permissions)
- [x] Field types match schema (string, number, array, object)
- [x] Enum values valid (mode: subagent|orchestrator)
- [x] Numeric ranges valid (temperature: 0.0-1.0)
- [x] Array items valid (tools: known tool names)
- [x] Permission patterns valid (glob syntax)
- [x] Context files exist (required context paths)
- [x] Delegation targets valid (can_delegate_to: known agents)
- [x] No dangerous commands in allow list
- [x] Frontmatter is first thing in file (before any content)

**Validation Error Handling**:

```python
class FrontmatterValidationError(Exception):
    """Raised when frontmatter validation fails."""
    def __init__(self, errors):
        self.errors = errors
        super().__init__(f"Frontmatter validation failed: {len(errors)} errors")

def validate_frontmatter(file_path):
    """Validate frontmatter in file."""
    try:
        # Extract frontmatter
        with open(file_path, 'r') as f:
            content = f.read()
        
        if not content.startswith('---\n'):
            raise FrontmatterValidationError(["Frontmatter must be first thing in file"])
        
        # Parse YAML
        parts = content.split('---\n', 2)
        if len(parts) < 3:
            raise FrontmatterValidationError(["Frontmatter not properly closed"])
        
        frontmatter = yaml.safe_load(parts[1])
        
        # Validate schema
        errors = validate_schema(frontmatter)
        if errors:
            raise FrontmatterValidationError(errors)
        
        # Validate semantics
        errors = validate_semantics(frontmatter)
        if errors:
            raise FrontmatterValidationError(errors)
        
        return frontmatter
        
    except yaml.YAMLError as e:
        raise FrontmatterValidationError([f"YAML parse error: {e}"])
```

## 6. Template Design

### 6.1 Frontmatter Template Structure

**Comprehensive Template**:

```yaml
---
# ============================================================================
# Agent Identity
# ============================================================================
name: "{agent_name}"
version: "1.0.0"
description: "{brief_description}"
mode: subagent
agent_type: "{research|planning|implementation|execution}"

# ============================================================================
# Execution Configuration
# ============================================================================
temperature: {0.1-0.3}
max_tokens: 4000
timeout: 3600

# ============================================================================
# Tool Configuration
# ============================================================================
tools:
  - read
  - write
  - bash
  - grep
  - glob
  # Add specialized tools as needed:
  # - webfetch  # For research agents
  # - lean-lsp-mcp_*  # For Lean agents

# ============================================================================
# Permission Configuration
# ============================================================================
permissions:
  allow:
    # Read permissions
    - read:
      - "**/*.md"
      - ".opencode/**/*"
      - "docs/**/*"
    
    # Write permissions
    - write:
      - "specs/**/*"
      - ".opencode/context/**/*"
    
    # Bash permissions
    - bash:
      - "grep"
      - "find"
      - "wc"
      - "date"
      - "mkdir"
  
  deny:
    # Destructive operations
    - bash:
      - "rm -rf"
      - "sudo"
      - "chmod +x"
      - "dd"
    
    # Critical files
    - write:
      - ".git/**/*"
      - "**/*.lean"
      - "lakefile.lean"
    
    # Sensitive files
    - read:
      - ".env"
      - "**/*.key"
      - "**/*.pem"

# ============================================================================
# Context Loading Configuration
# ============================================================================
context_loading:
  strategy: lazy
  index: ".opencode/context/index.md"
  required:
    - "core/workflows/command-lifecycle.md"
    - "core/standards/subagent-return-format.md"
  optional:
    - "project/{domain}/{specific_context}.md"
  max_context_size: 50000

# ============================================================================
# Delegation Configuration
# ============================================================================
delegation:
  max_depth: 3
  can_delegate_to:
    - "{specialist_agent_1}"
    - "{specialist_agent_2}"
  timeout_default: 1800
  timeout_max: 3600

# ============================================================================
# Lifecycle Integration
# ============================================================================
lifecycle:
  stage: 4
  command: "/{command_name}"
  return_format: "subagent-return-format.md"
  status_markers:
    - "[NOT STARTED]"
    - "[IN PROGRESS]"
    - "[COMPLETED]"

# ============================================================================
# Metadata
# ============================================================================
metadata:
  created: "2025-12-29"
  updated: "2025-12-29"
  author: "system"
  tags:
    - "{tag1}"
    - "{tag2}"
---
```

### 6.2 Template Documentation Standard

**Field Documentation Format**:

```markdown
## Frontmatter Field Reference

### Agent Identity

#### `name`
- **Type**: string
- **Required**: Yes
- **Pattern**: `^[a-z-]+$` (lowercase with hyphens)
- **Description**: Unique identifier for the agent
- **Example**: `"researcher"`, `"lean-implementation-agent"`

#### `version`
- **Type**: string
- **Required**: Yes
- **Pattern**: `^\d+\.\d+\.\d+$` (semantic versioning)
- **Description**: Agent version following semver
- **Example**: `"1.0.0"`, `"2.1.3"`

#### `description`
- **Type**: string
- **Required**: Yes
- **Min Length**: 10 characters
- **Description**: Brief, human-readable description of agent purpose
- **Example**: `"General research agent for non-Lean tasks"`

#### `mode`
- **Type**: string
- **Required**: Yes
- **Enum**: `["subagent", "orchestrator"]`
- **Description**: Execution mode of the agent
- **Example**: `"subagent"`

#### `agent_type`
- **Type**: string
- **Required**: Yes
- **Enum**: `["research", "planning", "implementation", "execution", "validation"]`
- **Description**: Category of agent for routing and configuration
- **Example**: `"research"`

### Execution Configuration

#### `temperature`
- **Type**: number
- **Required**: Yes
- **Range**: 0.0 - 1.0
- **Description**: LLM sampling temperature for response generation
- **Guidelines**:
  - Research agents: 0.3 (moderate creativity)
  - Planning agents: 0.2 (structured)
  - Implementation agents: 0.2 (deterministic)
- **Example**: `0.3`

#### `max_tokens`
- **Type**: integer
- **Required**: No
- **Default**: 4000
- **Description**: Maximum output tokens for agent response
- **Example**: `4000`, `8000`

#### `timeout`
- **Type**: integer
- **Required**: No
- **Default**: 3600
- **Description**: Maximum execution time in seconds
- **Example**: `1800`, `3600`

### Tool Configuration

#### `tools`
- **Type**: array of strings
- **Required**: Yes
- **Description**: List of available tools for the agent
- **Valid Tools**:
  - `read`: Read files from filesystem
  - `write`: Write files to filesystem
  - `bash`: Execute bash commands
  - `grep`: Search file contents
  - `glob`: Find files by pattern
  - `list`: List directory contents
  - `edit`: Edit files with string replacement
  - `webfetch`: Fetch web content (research agents)
  - `lean-lsp-mcp_*`: Lean language server tools (Lean agents)
- **Example**: `["read", "write", "bash", "grep", "glob"]`

### Permission Configuration

#### `permissions`
- **Type**: object
- **Required**: Yes
- **Properties**:
  - `allow`: Array of permission rules
  - `deny`: Array of permission rules
- **Description**: Access control configuration for tools
- **Evaluation**: Deny list checked first, then allow list, default deny

#### `permissions.allow`
- **Type**: array of objects
- **Required**: Yes
- **Description**: Whitelist of permitted operations
- **Format**: `[{tool: [patterns]}]`
- **Example**:
  ```yaml
  allow:
    - read: ["**/*.md", ".opencode/**/*"]
    - write: ["specs/**/*"]
    - bash: ["grep", "find", "wc"]
  ```

#### `permissions.deny`
- **Type**: array of objects
- **Required**: Yes
- **Description**: Blacklist of forbidden operations
- **Format**: `[{tool: [patterns]}]`
- **Example**:
  ```yaml
  deny:
    - bash: ["rm -rf", "sudo", "chmod +x"]
    - write: [".git/**/*", "**/*.lean"]
  ```

### Context Loading Configuration

#### `context_loading`
- **Type**: object
- **Required**: No
- **Description**: Configuration for loading project context
- **Properties**:
  - `strategy`: Loading strategy (lazy, eager, filtered)
  - `index`: Path to context index file
  - `required`: Array of required context files
  - `optional`: Array of optional context files
  - `max_context_size`: Maximum context size in tokens

#### `context_loading.strategy`
- **Type**: string
- **Required**: Yes (if context_loading present)
- **Enum**: `["lazy", "eager", "filtered"]`
- **Description**: Context loading strategy
- **Recommended**: `"lazy"` for most agents
- **Example**: `"lazy"`

#### `context_loading.index`
- **Type**: string
- **Required**: Yes (if strategy is lazy or filtered)
- **Description**: Path to context index file
- **Example**: `".opencode/context/index.md"`

#### `context_loading.required`
- **Type**: array of strings
- **Required**: No
- **Description**: List of required context files (relative to .opencode/context/)
- **Example**:
  ```yaml
  required:
    - "core/workflows/command-lifecycle.md"
    - "core/standards/subagent-return-format.md"
  ```

#### `context_loading.optional`
- **Type**: array of strings
- **Required**: No
- **Description**: List of optional context files (loaded if available)
- **Example**:
  ```yaml
  optional:
    - "project/lean4/lean-patterns.md"
  ```

#### `context_loading.max_context_size`
- **Type**: integer
- **Required**: No
- **Default**: 50000
- **Description**: Maximum context size in tokens
- **Example**: `50000`

### Delegation Configuration

#### `delegation`
- **Type**: object
- **Required**: No
- **Description**: Configuration for delegating to other agents
- **Properties**:
  - `max_depth`: Maximum delegation depth
  - `can_delegate_to`: Array of agent names
  - `timeout_default`: Default timeout for delegated tasks
  - `timeout_max`: Maximum timeout for delegated tasks

#### `delegation.max_depth`
- **Type**: integer
- **Required**: Yes (if delegation present)
- **Range**: 1-5
- **Recommended**: 3
- **Description**: Maximum delegation depth to prevent infinite loops
- **Example**: `3`

#### `delegation.can_delegate_to`
- **Type**: array of strings
- **Required**: Yes (if delegation present)
- **Description**: List of agent names this agent can delegate to
- **Example**: `["web-research-specialist", "status-sync-manager"]`

#### `delegation.timeout_default`
- **Type**: integer
- **Required**: No
- **Default**: 1800
- **Description**: Default timeout for delegated tasks in seconds
- **Example**: `1800`

#### `delegation.timeout_max`
- **Type**: integer
- **Required**: No
- **Default**: 3600
- **Description**: Maximum timeout for delegated tasks in seconds
- **Example**: `3600`

### Lifecycle Integration

#### `lifecycle`
- **Type**: object
- **Required**: No
- **Description**: Integration with command lifecycle
- **Properties**:
  - `stage`: Lifecycle stage number
  - `command`: Command that invokes this agent
  - `return_format`: Return format specification
  - `status_markers`: Array of valid status markers

#### `lifecycle.stage`
- **Type**: integer
- **Required**: Yes (if lifecycle present)
- **Range**: 1-8
- **Description**: Command lifecycle stage where agent is invoked
- **Example**: `4`

#### `lifecycle.command`
- **Type**: string
- **Required**: Yes (if lifecycle present)
- **Pattern**: `^/[a-z-]+$`
- **Description**: Command that invokes this agent
- **Example**: `"/research"`, `"/plan"`, `"/implement"`

#### `lifecycle.return_format`
- **Type**: string
- **Required**: Yes (if lifecycle present)
- **Description**: Return format specification file
- **Example**: `"subagent-return-format.md"`

#### `lifecycle.status_markers`
- **Type**: array of strings
- **Required**: No
- **Description**: Valid status markers for this agent's tasks
- **Example**: `["[NOT STARTED]", "[IN PROGRESS]", "[COMPLETED]"]`
```

### 6.3 Validation Script Template

```python
#!/usr/bin/env python3
"""
Frontmatter validation script for subagent files.

Usage:
    python validate_frontmatter.py <file_path>
    python validate_frontmatter.py --all  # Validate all subagents
"""

import sys
import yaml
import json
import os
from pathlib import Path
from typing import Dict, List, Tuple

# Load JSON Schema
SCHEMA_PATH = ".opencode/context/common/schemas/frontmatter-schema.json"

def load_schema() -> dict:
    """Load frontmatter JSON schema."""
    with open(SCHEMA_PATH, 'r') as f:
        return json.load(f)

def extract_frontmatter(file_path: str) -> Tuple[bool, str, dict]:
    """
    Extract frontmatter from file.
    
    Returns:
        (success, error_message, frontmatter_dict)
    """
    try:
        with open(file_path, 'r') as f:
            content = f.read()
        
        # Check frontmatter exists and is first
        if not content.startswith('---\n'):
            return False, "Frontmatter must be first thing in file", {}
        
        # Split on frontmatter delimiters
        parts = content.split('---\n', 2)
        if len(parts) < 3:
            return False, "Frontmatter not properly closed with ---", {}
        
        # Parse YAML
        frontmatter = yaml.safe_load(parts[1])
        return True, "", frontmatter
        
    except yaml.YAMLError as e:
        return False, f"YAML parse error: {e}", {}
    except Exception as e:
        return False, f"Error reading file: {e}", {}

def validate_schema(frontmatter: dict, schema: dict) -> List[str]:
    """Validate frontmatter against JSON schema."""
    from jsonschema import validate, ValidationError
    
    errors = []
    try:
        validate(instance=frontmatter, schema=schema)
    except ValidationError as e:
        errors.append(f"Schema validation error: {e.message}")
    
    return errors

def validate_semantics(frontmatter: dict) -> List[str]:
    """Validate frontmatter semantics."""
    errors = []
    
    # Check temperature range by agent type
    agent_type = frontmatter.get('agent_type', '')
    temperature = frontmatter.get('temperature', 0)
    
    if agent_type in ['implementation', 'planning']:
        if temperature > 0.3:
            errors.append(f"{agent_type} agents should use temperature <= 0.3 (got {temperature})")
    
    # Check required context files exist
    if 'context_loading' in frontmatter:
        for file in frontmatter['context_loading'].get('required', []):
            full_path = f".opencode/context/{file}"
            if not os.path.exists(full_path):
                errors.append(f"Required context file not found: {full_path}")
    
    # Check delegation depth
    if 'delegation' in frontmatter:
        max_depth = frontmatter['delegation'].get('max_depth', 0)
        if max_depth > 5:
            errors.append(f"Delegation max_depth should not exceed 5 (got {max_depth})")
    
    # Check dangerous commands not in allow list
    if 'permissions' in frontmatter:
        dangerous = ['rm -rf', 'sudo', 'chmod +x', 'dd']
        for allow_rule in frontmatter['permissions'].get('allow', []):
            if 'bash' in allow_rule:
                for cmd in allow_rule['bash']:
                    if any(d in cmd for d in dangerous):
                        errors.append(f"Dangerous command in allow list: {cmd}")
    
    return errors

def validate_file(file_path: str) -> Tuple[bool, List[str]]:
    """
    Validate frontmatter in file.
    
    Returns:
        (success, errors)
    """
    # Extract frontmatter
    success, error, frontmatter = extract_frontmatter(file_path)
    if not success:
        return False, [error]
    
    # Load schema
    schema = load_schema()
    
    # Validate schema
    errors = validate_schema(frontmatter, schema)
    if errors:
        return False, errors
    
    # Validate semantics
    errors = validate_semantics(frontmatter)
    if errors:
        return False, errors
    
    return True, []

def main():
    """Main validation entry point."""
    if len(sys.argv) < 2:
        print("Usage: python validate_frontmatter.py <file_path>")
        print("       python validate_frontmatter.py --all")
        sys.exit(1)
    
    if sys.argv[1] == '--all':
        # Validate all subagent files
        subagent_dir = Path(".opencode/agent/subagents")
        files = list(subagent_dir.glob("*.md"))
        
        all_valid = True
        for file_path in files:
            success, errors = validate_file(str(file_path))
            if success:
                print(f"✓ {file_path.name}: VALID")
            else:
                print(f"✗ {file_path.name}: INVALID")
                for error in errors:
                    print(f"  - {error}")
                all_valid = False
        
        sys.exit(0 if all_valid else 1)
    
    else:
        # Validate single file
        file_path = sys.argv[1]
        success, errors = validate_file(file_path)
        
        if success:
            print(f"✓ {file_path}: VALID")
            sys.exit(0)
        else:
            print(f"✗ {file_path}: INVALID")
            for error in errors:
                print(f"  - {error}")
            sys.exit(1)

if __name__ == '__main__':
    main()
```

## 7. Recommended Implementation

### 7.1 Frontmatter Fields for Each Subagent

**researcher.md**:
```yaml
---
name: "researcher"
version: "1.0.0"
description: "General research agent for non-Lean tasks with topic subdivision support"
mode: subagent
agent_type: research
temperature: 0.3
tools: [read, write, bash, webfetch, grep, glob]
permissions:
  allow:
    - read: ["**/*.md", ".opencode/**/*", "docs/**/*"]
    - write: ["specs/**/*"]
    - bash: ["grep", "find", "wc", "date", "mkdir"]
  deny:
    - bash: ["rm -rf", "sudo", "chmod +x", "dd"]
    - write: [".git/**/*"]
context_loading:
  strategy: lazy
  index: ".opencode/context/index.md"
  required:
    - "core/workflows/command-lifecycle.md"
    - "core/standards/subagent-return-format.md"
delegation:
  max_depth: 3
  can_delegate_to: ["web-research-specialist"]
  timeout_default: 1800
---
```

**planner.md** (already has comprehensive frontmatter from Task 245):
```yaml
---
description: "Implementation plan creation following plan.md standard with research integration"
mode: subagent
temperature: 0.2
tools: [read, write, bash, grep, glob]
permissions:
  allow:
    - read: [".opencode/**/*", "**/*.md"]
    - write: ["specs/**/*"]
    - bash: ["grep", "wc", "date", "mkdir"]
  deny:
    - bash: ["rm -rf", "sudo", "chmod +x"]
    - write: [".git/**/*", "**/*.lean"]
context_loading:
  lazy: true
  index: ".opencode/context/index.md"
  required:
    - "core/workflows/command-lifecycle.md"
    - "core/standards/subagent-return-format.md"
    - "core/standards/status-markers.md"
    - "core/standards/plan.md"
delegation:
  max_depth: 3
  can_delegate_to: ["status-sync-manager", "git-workflow-manager"]
  timeout_default: 1800
---
```

**implementer.md**:
```yaml
---
name: "implementer"
version: "1.0.0"
description: "General implementation agent for non-Lean tasks"
mode: subagent
agent_type: implementation
temperature: 0.2
tools: [read, write, edit, bash, grep, glob]
permissions:
  allow:
    - read: ["**/*"]
    - write: ["**/*"]
    - bash: ["grep", "find", "wc", "date", "mkdir", "git"]
  deny:
    - bash: ["rm -rf", "sudo", "chmod +x", "dd"]
    - write: [".git/config", ".git/HEAD"]
context_loading:
  strategy: lazy
  index: ".opencode/context/index.md"
  required:
    - "core/workflows/command-lifecycle.md"
    - "core/standards/subagent-return-format.md"
delegation:
  max_depth: 3
  can_delegate_to: ["lean-implementation-agent", "status-sync-manager"]
  timeout_default: 1800
---
```

**task-executor.md**:
```yaml
---
name: "task-executor"
version: "1.0.0"
description: "Multi-phase task execution with resume support and per-phase git commits"
mode: subagent
agent_type: execution
temperature: 0.2
tools: [read, write, bash, grep, glob]
permissions:
  allow:
    - read: [".opencode/**/*", "**/*.md"]
    - write: ["specs/**/*"]
    - bash: ["grep", "wc", "date", "mkdir", "git"]
  deny:
    - bash: ["rm -rf", "sudo", "chmod +x", "dd"]
    - write: [".git/config"]
context_loading:
  strategy: lazy
  index: ".opencode/context/index.md"
  required:
    - "core/workflows/command-lifecycle.md"
    - "core/standards/subagent-return-format.md"
    - "core/standards/plan.md"
delegation:
  max_depth: 3
  can_delegate_to: ["implementer", "lean-implementation-agent", "status-sync-manager"]
  timeout_default: 1800
---
```

**lean-research-agent.md**:
```yaml
---
name: "lean-research-agent"
version: "1.0.0"
description: "Lean 4 library research agent with LeanExplore/Loogle/LeanSearch integration"
mode: subagent
agent_type: research
temperature: 0.3
tools: [read, write, bash, webfetch, grep, glob]
permissions:
  allow:
    - read: ["**/*.lean", "**/*.md", ".opencode/**/*", "docs/**/*"]
    - write: ["specs/**/*"]
    - bash: ["grep", "find", "wc", "date", "mkdir", "loogle"]
  deny:
    - bash: ["rm -rf", "sudo", "chmod +x", "dd"]
    - write: [".git/**/*", "**/*.lean", "lakefile.lean"]
context_loading:
  strategy: lazy
  index: ".opencode/context/index.md"
  required:
    - "core/workflows/command-lifecycle.md"
    - "core/standards/subagent-return-format.md"
    - "project/lean4/lean-patterns.md"
delegation:
  max_depth: 3
  can_delegate_to: ["web-research-specialist"]
  timeout_default: 1800
---
```

**lean-implementation-agent.md**:
```yaml
---
name: "lean-implementation-agent"
version: "1.0.0"
description: "Lean 4 proof implementation using lean-lsp-mcp with graceful degradation"
mode: subagent
agent_type: implementation
temperature: 0.2
tools: [read, write, edit, bash, grep, glob]
permissions:
  allow:
    - read: ["**/*.lean", "**/*.md", ".opencode/**/*"]
    - write: ["**/*.lean", "specs/**/*"]
    - bash: ["grep", "find", "wc", "date", "mkdir", "lake"]
  deny:
    - bash: ["rm -rf", "sudo", "chmod +x", "dd"]
    - write: [".git/**/*", "lakefile.lean", "lean-toolchain"]
context_loading:
  strategy: lazy
  index: ".opencode/context/index.md"
  required:
    - "core/workflows/command-lifecycle.md"
    - "core/standards/subagent-return-format.md"
    - "project/lean4/lean-patterns.md"
    - "project/lean4/proof-strategies.md"
delegation:
  max_depth: 3
  can_delegate_to: ["status-sync-manager"]
  timeout_default: 1800
---
```

### 7.2 Dangerous Commands to Deny

**Critical Deny List** (all agents):

```yaml
permissions:
  deny:
    - bash:
      # Destructive filesystem
      - "rm -rf"
      - "rm -fr"
      - "rm -r *"
      - "rm -rf /"
      - "rm -rf ~"
      - "rm -rf ."
      
      # Privilege escalation
      - "sudo"
      - "su"
      - "doas"
      
      # Permission changes
      - "chmod +x"
      - "chmod 777"
      - "chmod -R"
      - "chown"
      - "chgrp"
      
      # Disk operations
      - "dd"
      - "mkfs"
      - "fdisk"
      - "parted"
      - "mount"
      - "umount"
      
      # Network operations
      - "wget"
      - "curl"
      - "nc"
      - "netcat"
      - "ssh"
      - "scp"
      - "rsync"
      
      # Process manipulation
      - "kill -9"
      - "killall"
      - "pkill"
      
      # System modification
      - "systemctl"
      - "service"
      - "init"
      - "shutdown"
      - "reboot"
      
      # Package management
      - "apt"
      - "apt-get"
      - "yum"
      - "dnf"
      - "pacman"
      - "brew"
      - "pip install"
      - "npm install -g"
      
      # Compression (potential zip bombs)
      - "tar xf"
      - "unzip"
      - "gunzip"
      
      # Shell spawning
      - "bash -c"
      - "sh -c"
      - "eval"
      - "exec"
    
    - read:
      # Sensitive files
      - ".env"
      - ".env.*"
      - "**/*.key"
      - "**/*.pem"
      - "**/*.p12"
      - "**/*.pfx"
      - ".ssh/**/*"
      - ".gnupg/**/*"
      - "/etc/passwd"
      - "/etc/shadow"
    
    - write:
      # Git internals
      - ".git/**/*"
      - ".gitignore"
      
      # Build configuration
      - "lakefile.lean"
      - "lean-toolchain"
      - "Makefile"
      - "CMakeLists.txt"
      
      # System files
      - "/etc/**/*"
      - "/usr/**/*"
      - "/bin/**/*"
      - "/sbin/**/*"
```

### 7.3 YAML Validation Approach

**Recommended Validation Pipeline**:

1. **Syntax Validation** (YAML parser):
   - Use `yaml.safe_load()` to parse frontmatter
   - Catch `yaml.YAMLError` for syntax errors
   - Validate frontmatter is first thing in file

2. **Schema Validation** (JSON Schema):
   - Define JSON schema for frontmatter structure
   - Use `jsonschema` library to validate
   - Check required fields, types, enums, ranges

3. **Semantic Validation** (custom rules):
   - Validate temperature ranges by agent type
   - Check context files exist
   - Validate delegation depth limits
   - Check for dangerous commands in allow lists

4. **Integration Testing**:
   - Test frontmatter parsing in agent initialization
   - Test permission enforcement with sample operations
   - Test context loading with sample files
   - Test delegation with sample agent calls

**Validation Tools**:
- `pyyaml`: YAML parsing
- `jsonschema`: Schema validation
- `pytest`: Integration testing
- Custom validation script (see template above)

### 7.4 Template Structure Recommendation

**Recommended Template Organization**:

```
.opencode/
├── context/
│   └── common/
│       ├── schemas/
│       │   └── frontmatter-schema.json
│       └── templates/
│           ├── subagent-frontmatter-template.yaml
│           └── subagent-template.md
├── agent/
│   └── subagents/
│       ├── researcher.md
│       ├── planner.md
│       ├── implementer.md
│       ├── task-executor.md
│       ├── lean-research-agent.md
│       └── lean-implementation-agent.md
└── scripts/
    └── validate_frontmatter.py
```

**Template Files**:

1. **frontmatter-schema.json**: JSON schema for validation
2. **subagent-frontmatter-template.yaml**: YAML template with all fields
3. **subagent-template.md**: Complete subagent template with frontmatter
4. **validate_frontmatter.py**: Validation script

## 8. Examples from Similar Systems

### 8.1 Jekyll Frontmatter

**Source**: Jekyll static site generator

```yaml
---
layout: post
title: "YAML Frontmatter Best Practices"
date: 2025-12-29 10:00:00 -0500
categories: [documentation, yaml]
tags: [frontmatter, configuration, agents]
author: system
published: true
excerpt: "Comprehensive guide to YAML frontmatter for AI agents"
---
```

**Key Takeaways**:
- Simple, flat structure
- Clear separation of metadata and content
- Predefined variables with custom extensions
- Boolean flags for control (published)
- Date/time with timezone support

### 8.2 Hugo Frontmatter

**Source**: Hugo static site generator

```yaml
---
title: "Agent Configuration"
date: 2025-12-29T10:00:00-05:00
draft: false
type: "subagent"
weight: 10
categories: ["research", "planning"]
tags: ["yaml", "configuration"]
params:
  temperature: 0.3
  max_tokens: 4000
  tools: ["read", "write", "bash"]
---
```

**Key Takeaways**:
- Hierarchical structure with `params` section
- ISO 8601 date format
- Weight for ordering
- Type classification
- Extensible params object

### 8.3 Obsidian Frontmatter

**Source**: Obsidian knowledge management

```yaml
---
title: "Research Agent"
aliases: ["researcher", "research-specialist"]
tags: [agent, research, automation]
created: 2025-12-29
modified: 2025-12-29
status: active
version: 1.0.0
---
```

**Key Takeaways**:
- Aliases for alternative names
- Created/modified timestamps
- Status tracking
- Version tracking
- Simple tag array

### 8.4 GitHub Actions Workflow

**Source**: GitHub Actions YAML configuration

```yaml
name: Validate Frontmatter
on:
  push:
    paths:
      - '.opencode/agent/subagents/*.md'
  pull_request:
    paths:
      - '.opencode/agent/subagents/*.md'
jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Set up Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.11'
      - name: Install dependencies
        run: |
          pip install pyyaml jsonschema
      - name: Validate frontmatter
        run: |
          python .opencode/scripts/validate_frontmatter.py --all
```

**Key Takeaways**:
- Event-driven configuration
- Path-based triggers
- Job/step structure
- Dependency management
- Validation automation

## 9. References and Sources

### 9.1 YAML Specification

- **YAML Ain't Markup Language (YAML™) version 1.2.2** (2021-10-01)
  - URL: https://yaml.org/spec/1.2.2/
  - Key sections: Chapter 2 (Language Overview), Chapter 5 (Character Productions), Chapter 6 (Structural Productions)
  - Relevance: Official YAML syntax and structure standards

### 9.2 Jekyll Documentation

- **Jekyll Front Matter**
  - URL: https://jekyllrb.com/docs/front-matter/
  - Key sections: Predefined Variables, Custom Variables
  - Relevance: Frontmatter conventions and best practices

### 9.3 Existing ProofChecker Implementation

- **planner.md** (Task 245 Phase 2)
  - Path: `.opencode/agent/subagents/planner.md`
  - Sections: YAML frontmatter (lines 1-33)
  - Relevance: Comprehensive frontmatter example with tools, permissions, context loading, delegation

- **lean-research-agent.md**
  - Path: `.opencode/agent/subagents/lean-research-agent.md`
  - Sections: YAML frontmatter (lines 1-5)
  - Relevance: Minimal frontmatter example for research agent

- **lean-implementation-agent.md**
  - Path: `.opencode/agent/subagents/lean-implementation-agent.md`
  - Sections: YAML frontmatter (lines 1-5)
  - Relevance: Minimal frontmatter example for implementation agent

### 9.4 Additional Resources

- **JSON Schema Specification**
  - URL: https://json-schema.org/
  - Relevance: Schema validation for YAML frontmatter

- **PyYAML Documentation**
  - URL: https://pyyaml.org/wiki/PyYAMLDocumentation
  - Relevance: Python YAML parsing library

- **jsonschema Python Library**
  - URL: https://python-jsonschema.readthedocs.io/
  - Relevance: JSON schema validation in Python

## 10. Recommendations

### 10.1 Essential YAML Frontmatter Fields

**Minimum Required Fields** (all subagents):
1. `name`: Agent identifier (string, lowercase-hyphen format)
2. `version`: Semantic version (string, "X.Y.Z" format)
3. `description`: Brief purpose description (string, 10+ chars)
4. `mode`: Execution mode (enum: "subagent" | "orchestrator")
5. `agent_type`: Agent category (enum: "research" | "planning" | "implementation" | "execution")
6. `temperature`: LLM sampling temperature (number, 0.0-1.0)
7. `tools`: Available tools (array of strings)
8. `permissions`: Access control (object with allow/deny arrays)

**Recommended Optional Fields**:
9. `context_loading`: Context loading configuration (object)
10. `delegation`: Delegation rules (object)
11. `lifecycle`: Lifecycle integration metadata (object)
12. `max_tokens`: Maximum output tokens (integer)
13. `timeout`: Execution timeout in seconds (integer)

### 10.2 Dangerous Commands to Deny

**Critical Deny List** (all agents):

**Filesystem Destruction**:
- `rm -rf`, `rm -fr`, `rm -r *`, `rm -rf /`, `rm -rf ~`

**Privilege Escalation**:
- `sudo`, `su`, `doas`

**Permission Changes**:
- `chmod +x`, `chmod 777`, `chmod -R`, `chown`, `chgrp`

**Disk Operations**:
- `dd`, `mkfs`, `fdisk`, `parted`, `mount`, `umount`

**Network Operations**:
- `wget`, `curl`, `nc`, `netcat`, `ssh`, `scp`, `rsync`

**Process Manipulation**:
- `kill -9`, `killall`, `pkill`

**System Modification**:
- `systemctl`, `service`, `init`, `shutdown`, `reboot`

**Package Management**:
- `apt`, `yum`, `dnf`, `pacman`, `brew`, `pip install`, `npm install -g`

**Sensitive File Access**:
- `.env`, `**/*.key`, `**/*.pem`, `.ssh/**/*`, `/etc/passwd`

**Critical File Modification**:
- `.git/**/*`, `lakefile.lean`, `lean-toolchain`, `Makefile`

### 10.3 YAML Validation Approach

**Recommended Validation Pipeline**:

1. **Syntax Validation** (YAML parser):
   - Parse with `yaml.safe_load()`
   - Validate frontmatter is first in file
   - Check proper delimiter usage (`---`)

2. **Schema Validation** (JSON Schema):
   - Define comprehensive JSON schema
   - Validate required fields present
   - Check field types and formats
   - Validate enum values
   - Check numeric ranges

3. **Semantic Validation** (custom rules):
   - Validate temperature by agent type
   - Check context files exist
   - Validate delegation depth limits
   - Check for dangerous commands in allow lists
   - Validate tool names are known

4. **Integration Testing**:
   - Test frontmatter parsing
   - Test permission enforcement
   - Test context loading
   - Test delegation

**Validation Tools**:
- `pyyaml`: YAML parsing
- `jsonschema`: Schema validation
- Custom validation script (see template)
- CI/CD integration (GitHub Actions)

### 10.4 Template Structure

**Recommended Template Organization**:

```
.opencode/
├── context/
│   └── common/
│       ├── schemas/
│       │   └── frontmatter-schema.json
│       └── templates/
│           ├── subagent-frontmatter-template.yaml
│           └── subagent-template.md
├── agent/
│   └── subagents/
│       ├── researcher.md
│       ├── planner.md
│       ├── implementer.md
│       ├── task-executor.md
│       ├── lean-research-agent.md
│       └── lean-implementation-agent.md
└── scripts/
    └── validate_frontmatter.py
```

**Template Components**:
1. **JSON Schema**: Formal validation schema
2. **YAML Template**: Comprehensive frontmatter template
3. **Markdown Template**: Complete subagent template with frontmatter
4. **Validation Script**: Automated validation tool
5. **Documentation**: Field reference and best practices

### 10.5 Implementation Priority

**Phase 1: Core Fields** (all 6 subagents):
- Add `name`, `version`, `agent_type` fields
- Standardize `temperature` by agent type
- Add `tools` array
- Add basic `permissions` (allow/deny)

**Phase 2: Context Loading** (all 6 subagents):
- Add `context_loading` configuration
- Define required context files
- Implement lazy loading strategy

**Phase 3: Delegation** (delegating agents):
- Add `delegation` configuration
- Define `can_delegate_to` lists
- Set `max_depth` limits
- Configure timeouts

**Phase 4: Validation** (infrastructure):
- Create JSON schema
- Implement validation script
- Add CI/CD integration
- Document frontmatter fields

**Phase 5: Documentation** (all):
- Create field reference
- Document best practices
- Provide examples
- Update subagent template

## 11. Conclusion

This research provides comprehensive standards for YAML frontmatter in AI agent configuration systems, drawing from the YAML 1.2 specification, Jekyll frontmatter conventions, and analysis of existing ProofChecker subagent implementations.

**Key Findings**:
1. YAML frontmatter provides structured, human-readable configuration
2. Essential fields include name, version, description, mode, agent_type, temperature, tools, and permissions
3. Permissions use allow/deny lists with glob patterns for fine-grained access control
4. Context loading supports lazy, eager, and filtered strategies
5. Delegation configuration includes depth limits, target agents, and timeouts
6. Dangerous commands must be explicitly denied (rm -rf, sudo, chmod, etc.)
7. Validation requires syntax, schema, and semantic checks
8. Templates should include comprehensive documentation and examples

**Recommended Next Steps**:
1. Create JSON schema for frontmatter validation
2. Implement validation script with syntax, schema, and semantic checks
3. Add comprehensive frontmatter to all 6 subagents following template
4. Document frontmatter fields with types, descriptions, and examples
5. Integrate validation into CI/CD pipeline
6. Update subagent template with frontmatter best practices

**Implementation Estimate**:
- Phase 1 (Core Fields): 2 hours
- Phase 2 (Context Loading): 2 hours
- Phase 3 (Delegation): 1 hour
- Phase 4 (Validation): 2 hours
- Phase 5 (Documentation): 1 hour
- **Total**: 8 hours

This research provides a solid foundation for standardizing YAML frontmatter across all ProofChecker subagents, ensuring consistent configuration, robust validation, and comprehensive documentation.
