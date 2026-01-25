# Implementation Plan: Minimal Refactor to Orchestrator Pattern

**Version**: 1.0  
**Created**: 2026-01-24  
**Purpose**: Refactor new system to use proven orchestrator pattern with minimal changes  
**Scope**: Bridge old working pattern with new system architecture  

---

## Executive Summary

**Problem**: New command system uses modern format (`command:`, `mode:`, `arguments:`) but the current OpenCode orchestrator expects the legacy orchestrator pattern (`name:`, `agent:`, `routing:`). This causes commands to not register properly.

**Solution**: Implement a **Hybrid Adapter Pattern** that:
1. Maintains new system's improved architecture and context organization
2. Adds minimal orchestrator compatibility layer 
3. Preserves all current investments in new system
4. Enables graceful migration path to full new system

---

## Current State Analysis

### New System Strengths (Preserve)
✅ **Better Context Organization**: 3-level loading, modular files  
✅ **Improved Documentation**: Consolidated standards, patterns  
✅ **Modern Architecture**: Clear separation of concerns  
✅ **Research-Backed**: XML optimization, performance patterns  

### Old System Strengths (Adopt)
✅ **Working Command Registration**: Proven orchestrator pattern  
✅ **Language-Based Routing**: Battle-tested routing logic  
✅ **Robust Workflow**: 4-stage validation process  
✅ **Status Management**: Two-phase status updates  

### Integration Challenge
❌ **Incompatible Frontmatter**: New format vs old format  
❌ **Different Execution Models**: Command vs orchestrator pattern  
❌ **Context Loading Differences**: Lazy vs strategic loading  

---

## Implementation Strategy

### Phase 1: Hybrid Frontmatter Adapter (Low Risk)

#### 1.1 Create Orchestrator Compatibility Layer
**File**: `.opencode/context/core/orchestration/hybrid-adapter.md`

Add **dual frontmatter support** that accepts both formats:

```yaml
# NEW FORMAT (primary)
command: implement
description: Execute implementation with resume support
version: "1.0"
mode: command

# LEGACY COMPATIBILITY (adapter)
name: implement  # Extracted from command
agent: orchestrator  # Fixed for all commands
routing:
  language_based: true
  # ... routing config extracted from arguments/structure
```

#### 1.2 Frontmatter Transformation Rules
**Priority Order**:
1. **Legacy fields**: `name:`, `agent:`, `routing:` (if present)
2. **New fields**: `command:`, `mode:`, `arguments:` (if legacy missing)
3. **Hybrid mode**: Both present, use legacy for routing, new for validation

#### 1.3 Update Command Discovery Logic
**File**: `.opencode/context/core/orchestration/command-discovery.md`

```bash
# Hybrid discovery algorithm
discover_command() {
  local cmd_file="$1"
  
  # Try legacy pattern first
  if grep -q "^name:" "$cmd_file"; then
    extract_legacy_routing "$cmd_file"
    return 0
  fi
  
  # Fallback to new pattern  
  if grep -q "^command:" "$cmd_file"; then
    extract_new_routing "$cmd_file"
    return 0
  fi
  
  return 1  # No valid pattern found
}
```

### Phase 2: Unified Workflow Engine (Medium Risk)

#### 2.1 Create Universal Workflow Executor
**File**: `.opencode/context/core/orchestration/universal-workflow.md`

Support **both execution models**:

```yaml
workflow_engine:
  legacy_mode:
    stages: [ParseAndValidate, Preflight, Delegate, ValidateReturn, Postflight, RelayResult]
    format: "xml_stages"
    validation: "checkpoint_based"
  
  new_mode:
    sections: [argument_parsing, workflow_execution]
    format: "markdown_sections"
    validation: "section_based"
  
  hybrid_adapter:
    auto_detect: "frontmatter_analysis"
    prefer_legacy: "for_routing"
    prefer_new: "for_context_loading"
```

#### 2.2 Argument Normalization
**File**: `.opencode/context/core/orchestration/argument-normalizer.md`

```bash
# Universal argument extraction
normalize_arguments() {
  local mode="$1"
  local arguments="$2"
  
  case "$mode" in
    "legacy")
      parse_legacy_args "$arguments"  # $ARGUMENTS based
      ;;
    "new")
      parse_new_args "$arguments"    # predefined args structure
      ;;
    "hybrid")
      # Try legacy first, fallback to new
      parse_legacy_args "$arguments" || parse_new_args "$arguments"
      ;;
  esac
}
```

### Phase 3: Context Bridge (Low Risk)

#### 3.1 Create Context Loading Adapter
**File**: `.opencode/context/core/orchestration/context-bridge.md`

Bridge **both context loading strategies**:

```yaml
context_bridge:
  legacy_strategy:
    loading: "lazy"
    index: ".opencode/context/index.md"
    required_files: [
      "core/orchestration/delegation.md",
      "core/orchestration/state-management.md"
    ]
  
  new_strategy:
    loading: "selective"
    required_context: "core/workflows/command-lifecycle.md"
  
  hybrid_strategy:
    auto_merge: true
    priority: "legacy_for_routing_new_for_metadata"
    conflict_resolution: "new_overrides_legacy"
```

#### 3.2 Update Index.md
**Modification**: Add hybrid loading rules to existing index.md

Add section:
```markdown
## Hybrid Context Loading (Phase 1)

**Commands with dual frontmatter**: Load using hybrid strategy
- Legacy routing data takes precedence for agent selection
- New context structure takes precedence for validation and standards
- Conflict resolution: New overrides legacy for metadata fields

**Migration Path**: Gradual migration supported
- Legacy-only commands continue to work
- New-only commands get enhanced capabilities  
- Hybrid commands get best of both worlds
```

### Phase 4: Selective Migration (Medium Risk)

#### 4.1 Migrate High-Impact Commands First
**Priority Order**:

1. **implement** (your immediate need) ✅
2. **research** (high usage)
3. **plan** (dependency chain)
4. **task** (core functionality)
5. **meta** (system building)
6. **Other commands** (low usage)

**Migration Pattern**:
```bash
# Per-command migration
migrate_command() {
  local cmd="$1"
  
  # Step 1: Add hybrid frontmatter (preserve existing)
  add_hybrid_frontmatter ".opencode/command/${cmd}.md"
  
  # Step 2: Create workflow bridge
  create_workflow_bridge ".opencode/command/${cmd}.md"
  
  # Step 3: Update index references
  update_context_references "$cmd"
  
  # Step 4: Validate compatibility
  validate_hybrid_command ".opencode/command/${cmd}.md"
}
```

#### 4.2 Preserve New System Investments
**What to Keep**:
- ✅ **Modular Context Structure**: All new context files
- ✅ **Consolidated Documentation**: All new standards and patterns
- ✅ **Performance Optimizations**: 3-level context loading, lazy loading
- ✅ **XML Optimization**: Component ordering, routing patterns
- ✅ **Research-Backed Architecture**: All proven patterns

**What to Enhance**:
- 🔄 **Add Orchestrator Compatibility**: Minimal adapter layer
- 🔄 **Bridge Execution Models**: Universal workflow engine
- 🔄 **Maintain Backward Compatibility**: Legacy commands still work

### Phase 5: Testing & Validation (Low Risk)

#### 5.1 Compatibility Test Matrix
**File**: `.opencode/testing/hybrid-compatibility.md`

```markdown
## Test Matrix

| Command | Legacy Mode | New Mode | Hybrid Mode | Auto-Detection |
|---------|---------------|------------|--------------|----------------|
| implement | ✅ | ❌ | ✅ | ✅ |
| research | ✅ | ❌ | ✅ | ✅ |
| plan | ✅ | ❌ | ✅ | ✅ |
| task | ❌ | ✅ | ✅ | ✅ |
| meta | ❌ | ✅ | ✅ | ✅ |

## Test Scenarios

1. **Command Discovery**: Verify all commands appear in autocomplete
2. **Argument Parsing**: Test both `$ARGUMENTS` and structured args
3. **Routing**: Verify language-based routing works
4. **Context Loading**: Verify hybrid strategy works
5. **Workflow Execution**: Verify complete 4-stage process
6. **Status Management**: Verify two-phase updates work
```

#### 5.2 Gradual Rollout Plan
**Stage 1**: Deploy hybrid adapter for `implement` command only
**Stage 2**: Extend to research/plan commands
**Stage 3**: Migrate all core commands
**Stage 4**: Optional migration of remaining commands
**Rollback**: Keep legacy fallback option

---

## Implementation Tasks

### Task 1: Create Core Adapter Files
- [ ] `context/core/orchestration/hybrid-adapter.md`
- [ ] `context/core/orchestration/command-discovery.md` 
- [ ] `context/core/orchestration/universal-workflow.md`
- [ ] `context/core/orchestration/argument-normalizer.md`
- [ ] `context/core/orchestration/context-bridge.md`

### Task 2: Update Context Index
- [ ] Add hybrid loading section to `context/index.md`
- [ ] Update discovery references
- [ ] Add migration guidelines

### Task 3: Migrate Implement Command (Priority 1)
- [ ] Add hybrid frontmatter to `command/implement.md`
- [ ] Create workflow bridge section
- [ ] Test compatibility with existing workflows
- [ ] Validate argument parsing (`/implement 674` works)

### Task 4: Migrate Core Commands (Priority 2)
- [ ] `command/research.md` - hybrid migration
- [ ] `command/plan.md` - hybrid migration  
- [ ] `command/task.md` - hybrid migration
- [ ] `command/meta.md` - hybrid migration

### Task 5: Create Testing Framework
- [ ] `testing/hybrid-compatibility.md` test matrix
- [ ] `testing/compatibility-validator.sh` script
- [ ] Manual testing procedures

### Task 6: Documentation Updates
- [ ] Update `README.md` with hybrid approach
- [ ] Create `MIGRATION.md` guide
- [ ] Update architecture documentation

---

## Risk Assessment

### Low Risk Components
✅ **Core Adapter Files**: New files, no breaking changes  
✅ **Index Updates**: Additive changes only  
✅ **Implement Command**: Fixes immediate issue  

### Medium Risk Components  
🔄 **Command Migration**: Requires careful testing per command  
🔄 **Workflow Bridge**: Complex integration logic  

### Risk Mitigation
🛡️ **Gradual Rollout**: Migrate one command at a time  
🛡️ **Fallback Support**: Keep legacy detection working  
🛡️ **Comprehensive Testing**: Test matrix for all scenarios  
🛡️ **Rollback Plan**: Quick revert to legacy if needed  

---

## Success Criteria

### Immediate (Task 3 Complete)
- [ ] `/implement 674` works without errors
- [ ] Command appears in autocomplete
- [ ] Arguments parsed correctly
- [ ] Routing to appropriate agent works
- [ ] Status updates function properly

### Full Migration (All Tasks Complete)
- [ ] All commands work with hybrid system
- [ ] No regressions in existing functionality
- [ ] New system architecture preserved
- [ ] Legacy compatibility maintained
- [ ] Documentation updated and accurate

### Long-term (Future Enhancement)
- [ ] Migration path to full new system documented
- [ ] Performance optimizations preserved/enhanced
- [ ] Architecture debt eliminated
- [ ] System is maintainable and extensible

---

## Next Steps

1. **Review Plan**: Examine this plan for completeness and accuracy
2. **Approve Implementation**: Confirm approach aligns with your goals
3. **Execute Task 1**: Create core adapter files
4. **Test Implement Command**: Validate `/implement 674` works
5. **Iterative Migration**: Proceed with remaining commands
6. **Monitor & Refine**: Address issues as they arise

---

## Estimated Timeline

| Phase | Duration | Dependencies |
|-------|------------|--------------|
| Task 1: Core Adapters | 2-3 hours | None |
| Task 2: Index Updates | 1 hour | Task 1 |
| Task 3: Implement Command | 1-2 hours | Tasks 1-2 |
| Task 4: Core Commands | 4-6 hours | Task 3 |
| Task 5: Testing | 2-3 hours | Tasks 1-4 |
| Task 6: Documentation | 1-2 hours | Task 5 |
| **Total** | **11-17 hours** | - |

---

## Architecture Decision Rationale

### Why Hybrid vs Complete Migration

**Preserve Investments**: New system has significant architectural improvements
**Minimize Disruption**: Legacy system is working and battle-tested  
**Enable Migration**: Path to future full new system adoption  
**Reduce Risk**: Incremental changes vs big-bang migration  

### Why Orchestrator Pattern

**Proven Working**: Your `/implement` command worked in old system  
**Robust Routing**: Language-based agent selection is reliable  
**Status Management**: Two-phase updates ensure consistency  
**Clear Architecture**: 4-stage workflow is well-documented  

### Hybrid Bridge Benefits

✅ **Immediate Fix**: Solve current `/implement` issue quickly  
✅ **Future-Proof**: Enable gradual migration to new system  
✅ **Best of Both**: Legacy routing + new context organization  
✅ **Minimal Changes**: Don't break what's already working  

---

**Prepared by**: Meta Builder Agent  
**Target Date**: 2026-01-24  
**Review Status**: Ready for your review and approval