# Self-Healing Infrastructure Guide

**Version**: 1.0.0
**Purpose**: Enable automatic recovery from missing infrastructure files
**Last Updated**: 2025-12-27

---

## Overview

The OpenCode agent system implements **self-healing** to automatically recover from missing infrastructure files. This prevents commands from failing due to missing state.json, errors.json, or other critical files.

**Key Concept**: When a command needs an infrastructure file that doesn't exist, the system automatically creates it from a template using data from TODO.md.

---

## File Classification

### Tier 1: Auto-Created from Templates

**state.json** - Main state tracking file
- Template: `.opencode/context/common/templates/state-template.json`
- Auto-created from TODO.md data on first run or after deletion
- Contains: active projects, health metrics, task counters

**errors.json** - Error tracking file
- Minimal JSON structure: `{"_schema_version": "1.0.0", "errors": []}`
- Auto-created if missing

**archive/state.json, maintenance/state.json** - Specialized state files
- Auto-created from respective templates when needed

### Tier 2: Required (Cannot Auto-Create)

**TODO.md** - User-authored task list
- Cannot be auto-created (requires user content)
- Failure to load TODO.md stops execution with clear error message

**context/** files - Version-controlled system context
- Should be present in git repository
- Missing context files fail with recovery instructions

### Tier 3: Optional (Skip If Missing)

- Project-specific configurations
- Environment-dependent resources
- Tool-specific integrations

---

## Self-Healing Pattern

Commands validate infrastructure in preflight and auto-create missing files from templates:

1. Check if state.json exists → Auto-create from template if missing
2. Load TODO.md → Required, fail if missing
3. Continue with command execution

**Implementation**: See `self-healing-implementation-details.md` for complete pseudo-code

---

## User-Facing Behavior

### First Run (state.json Missing)

```
Note: Infrastructure file was missing and has been auto-created.
- Created: .opencode/specs/state.json (from template)
- Initialized with 37 tasks from TODO.md
- Next project number set to 200

This is normal for first-time setup.
```

### Template Missing (Degraded Mode)

```
Warning: Could not auto-create state.json
Reason: Template file missing
Fallback: Created minimal state.json (degraded mode)

To restore full functionality:
git checkout HEAD -- .opencode/context/common/templates/state-template.json
```

### TODO.md Missing (Cannot Auto-Create)

```
Error: Required file not found: .opencode/specs/TODO.md

This file is essential and cannot be auto-created.

Recovery steps:
1. Restore from git: git checkout HEAD -- .opencode/specs/TODO.md
2. Restore from backup if available
3. Create new TODO.md following standard format
```

---

## Error Recovery

### If Self-Healing Fails

1. **Check TODO.md exists** - Required for state.json creation
2. **Restore template from git**:
   ```bash
   git checkout HEAD -- .opencode/context/common/templates/state-template.json
   ```
3. **Restore from backup**:
   ```bash
   cp .opencode.backup.*/context/common/templates/state-template.json \
      .opencode/context/common/templates/
   ```
4. **Create manually** following schema in `state-schema.md`

---

## Best Practices

1. **Check Before Operations**: Validate infrastructure in preflight
2. **Log Transparently**: Record all self-healing actions
3. **Fail Clearly**: Provide actionable errors for unrecoverable failures
4. **Keep Templates Updated**: Sync templates with schema evolution
5. **Never Overwrite**: Self-healing only creates missing files, never overwrites existing ones

---

## Testing Self-Healing

### Test 1: Missing state.json

```bash
rm .opencode/specs/state.json
/research 197  # Should auto-create and continue
```

### Test 2: Normal operation

```bash
/research 197  # Should work without self-healing
```

---

## Related Documentation

- **Implementation Details**: `.opencode/context/project/repo/self-healing-implementation-details.md`
- **Schema Reference**: `.opencode/context/common/system/state-schema.md`
- **Schema Evolution**: See state-schema.md section "Schema Evolution and Versioning"
- **Context Organization**: `.opencode/context/common/system/context-guide.md`
- **Template**: `.opencode/context/common/templates/state-template.json`
