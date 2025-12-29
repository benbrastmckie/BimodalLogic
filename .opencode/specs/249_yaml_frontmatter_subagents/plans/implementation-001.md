# Implementation Plan: Phase 2 Follow-up - Add YAML Frontmatter to All 6 Subagents

## Metadata

- **Task Number**: 249
- **Task Title**: Phase 2 Follow-up: Add YAML Frontmatter to All 6 Subagents (Task 245 Phase 6)
- **Status**: [NOT STARTED]
- **Estimated Effort**: 4.5 hours
- **Language**: markdown
- **Priority**: High
- **Dependencies**: Task 245 (Phase 2 Phases 1-5 and 8 completed)
- **Plan Version**: 001
- **Created**: 2025-12-29
- **Research Integrated**: Yes
- **Research Report**: `.opencode/specs/249_yaml_frontmatter_subagents/reports/research-001.md`

## Overview

### Problem Statement

Task 245 Phase 2 successfully migrated commands to frontmatter delegation pattern and simplified the orchestrator, but Phase 6 (adding comprehensive YAML frontmatter to all 6 subagents) was deferred. Currently, only planner.md has comprehensive frontmatter from Task 245. The remaining 5 subagents (researcher.md, implementer.md, task-executor.md, lean-research-agent.md, lean-implementation-agent.md) have minimal frontmatter lacking critical fields for tools, permissions, context loading, and delegation configuration.

### Scope

This plan implements comprehensive YAML frontmatter for all 6 subagents following the standards identified in research report 001. The implementation will:

1. Create frontmatter template and JSON schema for validation
2. Add comprehensive frontmatter to 5 remaining subagents (planner.md already complete)
3. Enhance planner.md frontmatter with missing fields (name, version, agent_type)
4. Validate all frontmatter parses correctly
5. Verify permissions deny 30+ dangerous commands identified in research
6. Test tools and permissions enforcement
7. Document frontmatter standard for future subagent development

### Constraints

- Must preserve existing subagent functionality (no breaking changes)
- Must follow YAML 1.2 specification standards
- Must use text-based status indicators (no emojis)
- Must deny all dangerous commands identified in research (rm -rf, sudo, chmod, dd, etc.)
- Must validate frontmatter with 3-tier approach (syntax, schema, semantic)
- Must maintain lazy directory creation pattern
- Temperature must match agent type (research: 0.3, planning: 0.2, implementation: 0.2)

### Definition of Done

- All 6 subagents have comprehensive YAML frontmatter with 13 essential fields
- Frontmatter template created with all fields documented
- JSON schema created for validation
- Validation script created and tested
- All frontmatter parses without YAML syntax errors
- All required fields present (name, version, description, mode, agent_type, temperature, tools, permissions)
- Permissions deny 30+ dangerous commands from research
- Context loading references correct files
- Delegation configuration matches agent capabilities
- Tools and permissions enforcement tested
- Frontmatter standard documented

## Goals and Non-Goals

### Goals

1. **Standardize Frontmatter**: All 6 subagents use consistent frontmatter structure with 13 essential fields
2. **Security**: Permissions deny dangerous commands (rm -rf, sudo, chmod, dd, package managers, etc.)
3. **Validation**: 3-tier validation (syntax, schema, semantic) ensures frontmatter correctness
4. **Documentation**: Comprehensive field reference and best practices guide
5. **Testing**: Validation script tests all frontmatter files
6. **Template**: Reusable template for future subagent development

### Non-Goals

1. **Runtime Enforcement**: Permission enforcement implementation (future work)
2. **Context Loading Implementation**: Lazy loading implementation (future work)
3. **Delegation Implementation**: Delegation routing implementation (future work)
4. **CI/CD Integration**: GitHub Actions validation workflow (future work)
5. **Subagent Functionality Changes**: No changes to subagent logic or workflows

## Risks and Mitigations

### Risk 1: YAML Syntax Errors

**Likelihood**: Medium  
**Impact**: High (breaks subagent loading)  
**Mitigation**: 
- Use YAML linter during development
- Test parsing with `yaml.safe_load()` before committing
- Validate all frontmatter with validation script

### Risk 2: Breaking Existing Functionality

**Likelihood**: Low  
**Impact**: High (breaks workflow commands)  
**Mitigation**:
- Preserve existing frontmatter fields
- Add new fields without removing old ones
- Test all 4 workflow commands after changes
- Create backup before modifications

### Risk 3: Incomplete Dangerous Command List

**Likelihood**: Medium  
**Impact**: Medium (security gaps)  
**Mitigation**:
- Use comprehensive list from research (30+ commands)
- Review security best practices
- Document rationale for each denied command
- Plan for periodic review and updates

### Risk 4: Context File References Incorrect

**Likelihood**: Medium  
**Impact**: Medium (context loading failures)  
**Mitigation**:
- Validate all context file paths exist
- Use semantic validation to check file existence
- Document context file organization
- Test context loading with sample files

## Implementation Phases

### Phase 1: Create Frontmatter Template and Schema [NOT STARTED]

**Estimated Effort**: 1 hour

**Objective**: Create comprehensive frontmatter template with all 13 essential fields and JSON schema for validation.

**Tasks**:
1. Create `.opencode/context/common/templates/subagent-frontmatter-template.yaml` with all fields
2. Create `.opencode/context/common/schemas/frontmatter-schema.json` for validation
3. Document all 13 essential fields (name, version, description, mode, agent_type, temperature, tools, permissions, context_loading, delegation, lifecycle, max_tokens, timeout)
4. Include comprehensive dangerous command deny list (30+ commands from research)
5. Add field descriptions and examples
6. Validate template parses correctly

**Acceptance Criteria**:
- [NOT STARTED] Template includes all 13 essential fields
- [NOT STARTED] JSON schema defines required fields, types, enums, ranges
- [NOT STARTED] Template includes 30+ dangerous commands in deny list
- [NOT STARTED] Template parses without YAML syntax errors
- [NOT STARTED] All fields documented with types and examples

**Artifacts**:
- `.opencode/context/common/templates/subagent-frontmatter-template.yaml`
- `.opencode/context/common/schemas/frontmatter-schema.json`

---

### Phase 2: Add Frontmatter to researcher.md [NOT STARTED]

**Estimated Effort**: 0.5 hours

**Objective**: Add comprehensive frontmatter to researcher.md with research-specific configuration.

**Tasks**:
1. Read existing researcher.md frontmatter
2. Add missing fields: name, version, agent_type, tools, permissions, context_loading, delegation
3. Set temperature: 0.3 (research agent)
4. Configure tools: [read, write, bash, webfetch, grep, glob]
5. Configure permissions:
   - Allow: read (**/*.md, .opencode/**/*), write (.opencode/specs/**/*), bash (grep, find, wc, date, mkdir)
   - Deny: bash (rm -rf, sudo, chmod +x, dd), write (.git/**/*), read (.env, **/*.key)
6. Configure context_loading: lazy strategy with index.md
7. Configure delegation: max_depth 3, can_delegate_to [web-research-specialist]
8. Validate frontmatter parses correctly

**Acceptance Criteria**:
- [NOT STARTED] All 13 essential fields present
- [NOT STARTED] Temperature set to 0.3 (research agent)
- [NOT STARTED] Tools include webfetch for web research
- [NOT STARTED] Permissions deny dangerous commands
- [NOT STARTED] Context loading references correct files
- [NOT STARTED] Delegation configured for web-research-specialist
- [NOT STARTED] Frontmatter parses without errors

**Artifacts**:
- `.opencode/agent/subagents/researcher.md` (updated)

---

### Phase 3: Add Frontmatter to implementer.md [NOT STARTED]

**Estimated Effort**: 0.5 hours

**Objective**: Add comprehensive frontmatter to implementer.md with implementation-specific configuration.

**Tasks**:
1. Read existing implementer.md frontmatter
2. Add missing fields: name, version, agent_type, tools, permissions, context_loading, delegation
3. Set temperature: 0.2 (implementation agent)
4. Configure tools: [read, write, edit, bash, grep, glob]
5. Configure permissions:
   - Allow: read (**/*), write (**/*), bash (grep, find, wc, date, mkdir, git)
   - Deny: bash (rm -rf, sudo, chmod +x, dd), write (.git/config, .git/HEAD)
6. Configure context_loading: lazy strategy with index.md
7. Configure delegation: max_depth 3, can_delegate_to [lean-implementation-agent, status-sync-manager]
8. Validate frontmatter parses correctly

**Acceptance Criteria**:
- [NOT STARTED] All 13 essential fields present
- [NOT STARTED] Temperature set to 0.2 (implementation agent)
- [NOT STARTED] Tools include edit for file modification
- [NOT STARTED] Permissions allow git commands for commits
- [NOT STARTED] Permissions deny dangerous commands
- [NOT STARTED] Context loading references correct files
- [NOT STARTED] Delegation configured for lean-implementation-agent
- [NOT STARTED] Frontmatter parses without errors

**Artifacts**:
- `.opencode/agent/subagents/implementer.md` (updated)

---

### Phase 4: Add Frontmatter to task-executor.md [NOT STARTED]

**Estimated Effort**: 0.5 hours

**Objective**: Add comprehensive frontmatter to task-executor.md with execution-specific configuration.

**Tasks**:
1. Read existing task-executor.md frontmatter
2. Add missing fields: name, version, agent_type, tools, permissions, context_loading, delegation
3. Set temperature: 0.2 (execution agent)
4. Configure tools: [read, write, bash, grep, glob]
5. Configure permissions:
   - Allow: read (.opencode/**/*), write (.opencode/specs/**/*), bash (grep, wc, date, mkdir, git)
   - Deny: bash (rm -rf, sudo, chmod +x, dd), write (.git/config)
6. Configure context_loading: lazy strategy with plan.md required
7. Configure delegation: max_depth 3, can_delegate_to [implementer, lean-implementation-agent, status-sync-manager]
8. Validate frontmatter parses correctly

**Acceptance Criteria**:
- [NOT STARTED] All 13 essential fields present
- [NOT STARTED] Temperature set to 0.2 (execution agent)
- [NOT STARTED] Tools configured for task execution
- [NOT STARTED] Permissions allow git commands for per-phase commits
- [NOT STARTED] Permissions deny dangerous commands
- [NOT STARTED] Context loading includes plan.md for phase execution
- [NOT STARTED] Delegation configured for implementer agents
- [NOT STARTED] Frontmatter parses without errors

**Artifacts**:
- `.opencode/agent/subagents/task-executor.md` (updated)

---

### Phase 5: Add Frontmatter to lean-research-agent.md [NOT STARTED]

**Estimated Effort**: 0.5 hours

**Objective**: Add comprehensive frontmatter to lean-research-agent.md with Lean-specific research configuration.

**Tasks**:
1. Read existing lean-research-agent.md frontmatter
2. Add missing fields: name, version, agent_type, tools, permissions, context_loading, delegation
3. Set temperature: 0.3 (research agent)
4. Configure tools: [read, write, bash, webfetch, grep, glob]
5. Configure permissions:
   - Allow: read (**/*.lean, **/*.md, .opencode/**/*), write (.opencode/specs/**/*), bash (grep, find, wc, date, mkdir, loogle)
   - Deny: bash (rm -rf, sudo, chmod +x, dd), write (.git/**/* , **/*.lean, lakefile.lean)
6. Configure context_loading: lazy strategy with lean-patterns.md required
7. Configure delegation: max_depth 3, can_delegate_to [web-research-specialist]
8. Validate frontmatter parses correctly

**Acceptance Criteria**:
- [NOT STARTED] All 13 essential fields present
- [NOT STARTED] Temperature set to 0.3 (research agent)
- [NOT STARTED] Tools include webfetch for Lean library research
- [NOT STARTED] Permissions allow loogle command for Lean search
- [NOT STARTED] Permissions deny Lean file modification
- [NOT STARTED] Context loading includes lean-patterns.md
- [NOT STARTED] Delegation configured for web-research-specialist
- [NOT STARTED] Frontmatter parses without errors

**Artifacts**:
- `.opencode/agent/subagents/lean-research-agent.md` (updated)

---

### Phase 6: Add Frontmatter to lean-implementation-agent.md [NOT STARTED]

**Estimated Effort**: 0.5 hours

**Objective**: Add comprehensive frontmatter to lean-implementation-agent.md with Lean-specific implementation configuration.

**Tasks**:
1. Read existing lean-implementation-agent.md frontmatter
2. Add missing fields: name, version, agent_type, tools, permissions, context_loading, delegation
3. Set temperature: 0.2 (implementation agent)
4. Configure tools: [read, write, edit, bash, grep, glob]
5. Configure permissions:
   - Allow: read (**/*.lean, **/*.md, .opencode/**/*), write (**/*.lean, .opencode/specs/**/*), bash (grep, find, wc, date, mkdir, lake)
   - Deny: bash (rm -rf, sudo, chmod +x, dd), write (.git/**/* , lakefile.lean, lean-toolchain)
6. Configure context_loading: lazy strategy with lean-patterns.md and proof-strategies.md required
7. Configure delegation: max_depth 3, can_delegate_to [status-sync-manager]
8. Validate frontmatter parses correctly

**Acceptance Criteria**:
- [NOT STARTED] All 13 essential fields present
- [NOT STARTED] Temperature set to 0.2 (implementation agent)
- [NOT STARTED] Tools include edit for Lean file modification
- [NOT STARTED] Permissions allow Lean file writes and lake commands
- [NOT STARTED] Permissions deny lakefile.lean and lean-toolchain modification
- [NOT STARTED] Context loading includes lean-patterns.md and proof-strategies.md
- [NOT STARTED] Delegation configured for status-sync-manager
- [NOT STARTED] Frontmatter parses without errors

**Artifacts**:
- `.opencode/agent/subagents/lean-implementation-agent.md` (updated)

---

### Phase 7: Enhance planner.md Frontmatter [NOT STARTED]

**Estimated Effort**: 0.25 hours

**Objective**: Add missing fields to planner.md frontmatter (name, version, agent_type) to match comprehensive standard.

**Tasks**:
1. Read existing planner.md frontmatter (already comprehensive from Task 245)
2. Add missing fields: name ("planner"), version ("1.0.0"), agent_type ("planning")
3. Verify all 13 essential fields present
4. Validate frontmatter parses correctly
5. Verify permissions deny dangerous commands

**Acceptance Criteria**:
- [NOT STARTED] All 13 essential fields present
- [NOT STARTED] Name field added: "planner"
- [NOT STARTED] Version field added: "1.0.0"
- [NOT STARTED] Agent_type field added: "planning"
- [NOT STARTED] Existing fields preserved (tools, permissions, context_loading, delegation)
- [NOT STARTED] Frontmatter parses without errors

**Artifacts**:
- `.opencode/agent/subagents/planner.md` (updated)

---

### Phase 8: Create Validation Script and Test [NOT STARTED]

**Estimated Effort**: 1 hour

**Objective**: Create validation script with 3-tier validation (syntax, schema, semantic) and test all 6 subagents.

**Tasks**:
1. Create `.opencode/scripts/validate_frontmatter.py` with validation logic
2. Implement syntax validation (YAML parsing with yaml.safe_load)
3. Implement schema validation (JSON schema with jsonschema library)
4. Implement semantic validation (temperature ranges, context files exist, delegation depth, dangerous commands)
5. Add --all flag to validate all subagents
6. Test validation script on all 6 subagents
7. Fix any validation errors found
8. Document validation script usage

**Acceptance Criteria**:
- [NOT STARTED] Validation script created with 3-tier validation
- [NOT STARTED] Syntax validation catches YAML parse errors
- [NOT STARTED] Schema validation checks required fields, types, enums, ranges
- [NOT STARTED] Semantic validation checks temperature, context files, delegation, dangerous commands
- [NOT STARTED] --all flag validates all 6 subagents
- [NOT STARTED] All 6 subagents pass validation
- [NOT STARTED] Validation script documented

**Artifacts**:
- `.opencode/scripts/validate_frontmatter.py`

---

### Phase 9: Document Frontmatter Standard [NOT STARTED]

**Estimated Effort**: 0.75 hours

**Objective**: Create comprehensive frontmatter documentation with field reference, best practices, and examples.

**Tasks**:
1. Create `.opencode/context/common/standards/frontmatter-standard.md`
2. Document all 13 essential fields with types, descriptions, examples
3. Document dangerous command deny list with rationale
4. Document temperature guidelines by agent type
5. Document context loading strategies (lazy, eager, filtered)
6. Document delegation configuration patterns
7. Document validation approach (syntax, schema, semantic)
8. Provide examples for each agent type (research, planning, implementation, execution)
9. Document best practices and common pitfalls

**Acceptance Criteria**:
- [NOT STARTED] Frontmatter standard documented
- [NOT STARTED] All 13 fields documented with types and examples
- [NOT STARTED] Dangerous command list documented with rationale
- [NOT STARTED] Temperature guidelines documented by agent type
- [NOT STARTED] Context loading strategies documented
- [NOT STARTED] Delegation patterns documented
- [NOT STARTED] Validation approach documented
- [NOT STARTED] Examples provided for each agent type
- [NOT STARTED] Best practices documented

**Artifacts**:
- `.opencode/context/common/standards/frontmatter-standard.md`

---

## Testing and Validation

### Unit Testing

**Validation Script Tests**:
1. Test YAML syntax validation with valid and invalid YAML
2. Test schema validation with missing required fields
3. Test schema validation with invalid field types
4. Test semantic validation with incorrect temperature ranges
5. Test semantic validation with non-existent context files
6. Test semantic validation with dangerous commands in allow list
7. Test --all flag validates all 6 subagents

**Expected Results**:
- Valid frontmatter passes all validation tiers
- Invalid YAML syntax caught by syntax validation
- Missing required fields caught by schema validation
- Invalid field types caught by schema validation
- Incorrect temperature ranges caught by semantic validation
- Non-existent context files caught by semantic validation
- Dangerous commands in allow list caught by semantic validation

### Integration Testing

**Frontmatter Parsing Tests**:
1. Test each subagent frontmatter parses with yaml.safe_load()
2. Test all required fields present in parsed frontmatter
3. Test all field types match expected types
4. Test all enum values valid
5. Test all numeric ranges valid

**Expected Results**:
- All 6 subagents parse without YAML errors
- All required fields present
- All field types correct
- All enum values valid
- All numeric ranges valid

### Validation Checklist

- [ ] All 6 subagents have comprehensive YAML frontmatter
- [ ] All 13 essential fields present in each subagent
- [ ] Frontmatter template created with all fields
- [ ] JSON schema created for validation
- [ ] Validation script created and tested
- [ ] All frontmatter parses without YAML syntax errors
- [ ] All required fields present (name, version, description, mode, agent_type, temperature, tools, permissions)
- [ ] Permissions deny 30+ dangerous commands from research
- [ ] Context loading references correct files (validated with semantic checks)
- [ ] Delegation configuration matches agent capabilities
- [ ] Temperature matches agent type (research: 0.3, planning: 0.2, implementation: 0.2)
- [ ] Tools configured appropriately for each agent type
- [ ] Frontmatter standard documented
- [ ] Validation script passes on all 6 subagents

## Artifacts and Outputs

### Primary Artifacts

1. **Frontmatter Template**: `.opencode/context/common/templates/subagent-frontmatter-template.yaml`
   - Comprehensive template with all 13 essential fields
   - Dangerous command deny list (30+ commands)
   - Field descriptions and examples

2. **JSON Schema**: `.opencode/context/common/schemas/frontmatter-schema.json`
   - Formal validation schema
   - Required fields, types, enums, ranges
   - Used by validation script

3. **Validation Script**: `.opencode/scripts/validate_frontmatter.py`
   - 3-tier validation (syntax, schema, semantic)
   - --all flag for batch validation
   - Detailed error reporting

4. **Frontmatter Standard**: `.opencode/context/common/standards/frontmatter-standard.md`
   - Field reference with types and examples
   - Best practices and guidelines
   - Examples for each agent type

### Updated Subagents

1. **researcher.md**: Research agent frontmatter (temperature: 0.3, webfetch tool)
2. **planner.md**: Planning agent frontmatter (enhanced with name, version, agent_type)
3. **implementer.md**: Implementation agent frontmatter (temperature: 0.2, edit tool)
4. **task-executor.md**: Execution agent frontmatter (temperature: 0.2, git commands)
5. **lean-research-agent.md**: Lean research frontmatter (loogle command, lean-patterns.md)
6. **lean-implementation-agent.md**: Lean implementation frontmatter (lake command, proof-strategies.md)

### Documentation

1. **Field Reference**: Complete documentation of all 13 essential fields
2. **Dangerous Command List**: 30+ commands with rationale
3. **Temperature Guidelines**: By agent type (research, planning, implementation)
4. **Context Loading Strategies**: Lazy, eager, filtered
5. **Delegation Patterns**: max_depth, can_delegate_to, timeouts
6. **Validation Approach**: Syntax, schema, semantic tiers
7. **Best Practices**: Common patterns and pitfalls

## Rollback/Contingency

### Rollback Plan

If frontmatter changes break subagent functionality:

1. **Identify Failure**: Determine which subagent(s) affected
2. **Restore Backup**: Restore subagent file from git history
3. **Isolate Issue**: Test frontmatter parsing in isolation
4. **Fix Syntax**: Correct YAML syntax errors
5. **Revalidate**: Run validation script to verify fix
6. **Retest**: Test subagent functionality
7. **Commit Fix**: Commit corrected frontmatter

### Contingency Measures

**If YAML Parsing Fails**:
- Use YAML linter to identify syntax errors
- Validate indentation (spaces only, no tabs)
- Check for unquoted special characters
- Verify proper delimiter usage (---)

**If Schema Validation Fails**:
- Check required fields present
- Verify field types match schema
- Check enum values valid
- Verify numeric ranges valid

**If Semantic Validation Fails**:
- Verify temperature matches agent type
- Check context files exist
- Verify delegation depth <= 5
- Check no dangerous commands in allow list

**If Subagent Functionality Breaks**:
- Restore from git backup
- Test frontmatter parsing in isolation
- Compare with working frontmatter (planner.md)
- Incrementally add fields to identify issue

### Backup Strategy

1. **Pre-Implementation Backup**: Create git commit before any changes
2. **Per-Phase Backup**: Commit after each phase completes
3. **Validation Checkpoint**: Commit after validation passes
4. **Documentation Backup**: Commit documentation separately

## Success Metrics

### Quantitative Metrics

1. **Frontmatter Coverage**: 6/6 subagents have comprehensive frontmatter (100%)
2. **Field Completeness**: 13/13 essential fields in each subagent (100%)
3. **Validation Pass Rate**: 6/6 subagents pass validation (100%)
4. **Dangerous Command Coverage**: 30+ commands denied in all subagents
5. **Context File Validation**: 100% of referenced context files exist
6. **Temperature Compliance**: 100% of agents use correct temperature for type

### Qualitative Metrics

1. **Consistency**: All subagents use identical frontmatter structure
2. **Security**: Comprehensive dangerous command deny list
3. **Documentation**: Clear field reference and best practices
4. **Maintainability**: Template and validation script for future subagents
5. **Validation**: 3-tier validation ensures correctness

### Acceptance Criteria Summary

- [NOT STARTED] All 6 subagents have comprehensive YAML frontmatter
- [NOT STARTED] Frontmatter template created with all fields documented
- [NOT STARTED] JSON schema created for validation
- [NOT STARTED] Validation script created and tested
- [NOT STARTED] All frontmatter parses without YAML syntax errors
- [NOT STARTED] All required fields present and validated
- [NOT STARTED] Permissions deny 30+ dangerous commands
- [NOT STARTED] Context loading references correct files
- [NOT STARTED] Delegation configuration matches capabilities
- [NOT STARTED] Tools and permissions enforcement tested
- [NOT STARTED] Frontmatter standard documented

## Notes

### Research Integration

This plan integrates comprehensive research findings from `.opencode/specs/249_yaml_frontmatter_subagents/reports/research-001.md`:

- **13 Essential Fields**: name, version, description, mode, agent_type, temperature, tools, permissions, context_loading, delegation, lifecycle, max_tokens, timeout
- **30+ Dangerous Commands**: rm -rf, sudo, chmod, dd, package managers, network operations, etc.
- **3-Tier Validation**: Syntax (YAML parser), Schema (JSON schema), Semantic (custom rules)
- **Temperature Configuration**: Research (0.3), Planning (0.2), Implementation (0.2)
- **Context Loading**: Lazy strategy with index-based discovery
- **Delegation Patterns**: max_depth 3, can_delegate_to lists, timeouts

### Reference Implementation

planner.md from Task 245 demonstrates comprehensive frontmatter pattern:
- Tools array with 5 core tools
- Permissions with allow/deny lists using glob patterns
- Context loading with lazy strategy and required files
- Delegation with max_depth 3 and can_delegate_to list

This plan extends that pattern to all 6 subagents with agent-specific configurations.

### Future Work

- **Runtime Enforcement**: Implement permission checking in tool execution
- **Context Loading**: Implement lazy loading with index-based discovery
- **Delegation Routing**: Implement delegation with depth limits and cycle detection
- **CI/CD Integration**: Add GitHub Actions workflow for frontmatter validation
- **MCP Tool Configuration**: Add lean-lsp-mcp tools to lean-implementation-agent.md (Task 218)
