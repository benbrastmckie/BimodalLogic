# OpenCode Conventions Standard

**Purpose**: Comprehensive documentation of OpenCode (.opencode/) directory conventions based on .opencode_EXAMPLE/ from OpenAgentsControl.

**Version**: 1.0
**Source**: .opencode_EXAMPLE/, opencode.ai, OpenAgentsControl GitHub

---

## 1. Directory Structure

The .opencode/ directory follows this hierarchy:

```
.opencode/
├── agent/                    # Agent definitions
│   ├── core/                 # Primary orchestration agents
│   │   ├── 0-category.json   # Category metadata
│   │   └── *.md              # Primary agents (mode: primary)
│   ├── subagents/            # Specialized subagents (mode: subagent)
│   │   ├── core/             # Core subagents (ContextScout, TaskManager, etc.)
│   │   ├── planning/         # Planning subagents
│   │   ├── code/             # Coding subagents
│   │   └── {domain}/         # Domain-specific subagents
│   ├── meta/                 # Meta/system-builder agents
│   ├── content/              # Content creation agents
│   └── data/                 # Data analysis agents
│
├── command/                  # Slash commands
│   └── *.md                  # Command definitions
│
├── context/                  # Context files for discovery
│   ├── navigation.md         # Root navigation (required)
│   ├── core/                 # Universal standards
│   │   ├── navigation.md
│   │   ├── standards/
│   │   └── workflows/
│   └── {domain}/             # Domain-specific context
│       └── navigation.md
│
├── skills/                   # Skill modules
│   └── {skill-name}/
│       ├── SKILL.md          # Documentation
│       └── router.sh         # Bash entry point
│
├── docs/                     # System documentation
│   ├── README.md
│   └── guides/
│
├── profiles/                 # Configuration profiles (optional)
│   └── *.json
│
└── config.json               # Root configuration
```

### Key Differences from .claude/

| Component | .claude/ | .opencode/ |
|-----------|----------|------------|
| Root config | CLAUDE.md | config.json + AGENTS.md at project root |
| Agents | agents/*.md (flat) | agent/**/*.md (hierarchical) |
| Agent hierarchy | None | core/ vs subagents/ distinction |
| Context discovery | index.json | navigation.md files |
| Commands | commands/*.md | command/*.md (simplified) |
| Skills | skills/*/SKILL.md | skills/*/router.sh + SKILL.md |

---

## 2. Agent Definition Format

### YAML Frontmatter Schema

```yaml
---
name: AgentName                     # PascalCase display name
description: "Agent description"    # Brief description
mode: primary|subagent              # Agent type
temperature: 0.1                    # Model temperature (0.0-1.0)
permission:                         # Permission patterns
  bash:
    "rm -rf *": "ask"               # Dangerous commands
    "sudo *": "deny"                # Denied commands
    "curl *": "ask"                 # Network commands
  edit:
    "**/*.env*": "deny"             # Protected files
    "**/*.key": "deny"
    ".git/**": "deny"
  task:
    "contextscout": "allow"         # Subagent access
    "*": "deny"
  read:
    "*": "allow"                    # File read access
  grep:
    "*": "allow"                    # Search access
  glob:
    "*": "allow"                    # Pattern matching
  write:
    "*": "allow"                    # Write access (primary only)
---
```

### Mode Types

| Mode | Description | Typical Permissions |
|------|-------------|---------------------|
| `primary` | Orchestration agent, full tool access | edit, write, bash, task |
| `subagent` | Specialized agent, limited scope | Often read-only or restricted |

### Permission Values

| Value | Behavior |
|-------|----------|
| `allow` | Automatically permitted |
| `deny` | Blocked, cannot override |
| `ask` | Requires user confirmation |

### Agent Body Structure

After frontmatter, use XML-like tags for structured content:

```markdown
---
name: AgentName
mode: subagent
---

# Agent Name

> **Mission**: One-line purpose statement

<critical_rules priority="absolute" enforcement="strict">
  <rule id="rule_name" scope="all_execution">
    Rule description
  </rule>
</critical_rules>

<workflow>
  <stage id="1" name="StageName" required="true">
    Stage description and steps
  </stage>
</workflow>

<constraints enforcement="absolute">
  1. Constraint one
  2. Constraint two
</constraints>
```

---

## 3. Navigation.md Pattern

Each context directory has a navigation.md file for dynamic discovery.

### Header Format

```markdown
<!-- Context: {path} | Priority: critical|high|medium | Version: 1.0 | Updated: YYYY-MM-DD -->

# {Directory} Navigation

**Purpose**: Brief description

---
```

### Structure Section

```markdown
## Structure

```
{directory}/
├── navigation.md
├── file1.md
├── subdirectory/
│   └── navigation.md
└── file2.md
```
```

### Quick Routes Table

```markdown
## Quick Routes

| Task | Path |
|------|------|
| **Task name** | `relative/path/to/file.md` |
| **Another task** | `another/file.md` |
```

### Related Context Links

```markdown
## Related Context

- **Domain Name** -> `../domain/navigation.md`
- **Another Domain** -> `../other/navigation.md`
```

### Example

```markdown
<!-- Context: core/navigation | Priority: critical | Version: 1.0 -->

# Core Context Navigation

**Purpose**: Universal standards and workflows for all development

---

## Structure

```
core/
├── navigation.md
├── standards/
│   ├── navigation.md
│   └── code-quality.md
└── workflows/
    └── navigation.md
```

---

## Quick Routes

| Task | Path |
|------|------|
| **Write code** | `standards/code-quality.md` |
| **Review code** | `workflows/code-review.md` |

---

## Related Context

- **Development** -> `../development/navigation.md`
```

---

## 4. Command Format

Commands are simpler markdown files without the checkpoint system.

### Structure

```markdown
---
description: Brief command description
---

# Command Name

You are an AI agent that [command purpose]. Follow these instructions exactly.

## Instructions for Agent

When the user runs this command:

1. **Step one**:
   - Detail
   - Detail

2. **Step two**:
   - Detail

## Guidelines

- Guideline one
- Guideline two

## Agent Behavior Notes

- Behavior note
```

### Key Differences from .claude/

| Feature | .claude/ | .opencode/ |
|---------|----------|------------|
| Argument parsing | XML sections with patterns | Simple $ARGUMENTS variable |
| Checkpoints | GATE IN/DELEGATE/GATE OUT/COMMIT | None (direct execution) |
| Session ID | Generated at GATE IN | Not required |
| Skill invocation | Uses Skill tool | Direct execution or router.sh |

---

## 5. Skill Format

### Directory Structure

```
skills/{skill-name}/
├── SKILL.md          # Documentation only
└── router.sh         # Bash entry point (actual execution)
```

### router.sh Pattern

```bash
#!/bin/bash
# {skill-name} router

action="$1"
shift

case "$action" in
    status)
        # Status check logic
        ;;
    run)
        # Main execution
        ;;
    *)
        echo "Usage: router.sh {status|run} [args]"
        exit 1
        ;;
esac
```

### SKILL.md Pattern

```markdown
# {Skill Name}

## Purpose

What this skill does.

## Usage

```bash
.opencode/skills/{skill-name}/router.sh [action] [args]
```

## Actions

| Action | Description |
|--------|-------------|
| status | Check status |
| run | Execute skill |
```

---

## 6. Category Files

Each agent subdirectory can have a 0-category.json metadata file:

```json
{
  "name": "Category Name",
  "description": "Category description",
  "icon": "emoji-icon",
  "agents": {
    "agent-slug": {
      "description": "Agent description",
      "commonSubagents": [
        "subagents/core/subagent-name",
        "subagents/code/*"
      ],
      "commonTools": [
        "tool-name"
      ],
      "commonContext": [
        "core/standards/*",
        "core/workflows/*"
      ]
    }
  }
}
```

---

## 7. Config.json

Root configuration at .opencode/config.json:

```json
{
  "context_root": ".opencode/context/",
  "agent_root": ".opencode/agent/",
  "default_agent": "core/logos-coder"
}
```

---

## 8. AGENTS.md (Project Root)

A root-level AGENTS.md file links to the .opencode/ system:

```markdown
# Project Agents

This project uses OpenCode for AI agent orchestration.

## Quick Start

- Primary agent: `.opencode/agent/core/logos-coder.md`
- Context discovery: `.opencode/context/navigation.md`

## Commands

See `.opencode/command/` for available commands.

## Documentation

Full system documentation at `.opencode/docs/README.md`.
```

---

## 9. Profile System (Optional)

Profiles configure agent loading at .opencode/profiles/:

```json
{
  "name": "lean-developer",
  "description": "Lean 4 theorem proving development",
  "agents": {
    "primary": "core/logos-coder",
    "enabled_subagents": [
      "subagents/lean/*",
      "subagents/core/*"
    ]
  },
  "context": {
    "auto_load": [
      "core/standards/code-quality.md"
    ]
  }
}
```

---

## 10. Migration Notes

### Converting .claude/agents/ to .opencode/agent/

1. **Add mode**: `mode: subagent` (or `primary` for orchestrators)
2. **Add temperature**: `temperature: 0.1` (typical for code tasks)
3. **Convert allowed-tools**: Map to permission patterns
4. **Relocate file**: Place in appropriate subagents/{category}/
5. **Add XML tags**: Wrap sections in `<workflow>`, `<critical_rules>`, etc.

### Converting .claude/commands/ to .opencode/command/

1. **Remove checkpoints**: Delete GATE IN/DELEGATE/GATE OUT/COMMIT sections
2. **Simplify arguments**: Use $ARGUMENTS variable
3. **Direct execution**: Remove skill invocation, execute directly

### Converting .claude/context/ to .opencode/context/

1. **Copy files**: rsync or cp entire directory
2. **Path substitution**: Replace `.claude/` with `.opencode/`
3. **Remove index.json**: Replace with navigation.md files
4. **Update @-references**: Change @.claude/ to @.opencode/

---

## References

- .opencode_EXAMPLE/ (local reference implementation)
- https://github.com/darrenhinde/OpenAgentsControl
- https://opencode.ai/docs
