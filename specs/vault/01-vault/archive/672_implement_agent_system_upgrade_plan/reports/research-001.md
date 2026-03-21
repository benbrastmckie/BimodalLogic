# Research Report: .opencode System Upgrade Plan Implementation

**Task**: 672 - implement_agent_system_upgrade_plan  
**Started**: 2026-01-22T12:52:47Z  
**Completed**: 2026-01-22T13:25:30Z  
**Effort**: 2 hours  
**Priority**: High  
**Dependencies**: None  
**Sources/Inputs**: 
- specs/agent_system_upgrade_plan.md
- specs/implementation_roadmap.md
- .claude/hooks/ (source reference patterns)
- .claude/context/core/formats/ (source reference patterns)  
- Web research on metadata exchange and agent patterns

---

## Executive Summary

The .opencode system upgrade is a comprehensive 6-week, 4-phase initiative to integrate key .claude innovations while preserving formal verification specialization. Based on research findings, this upgrade is technically feasible with clear implementation paths. The primary innovations to port are: (1) File-Based Metadata Exchange for artifact tracking, (2) Meta System Builder for dynamic extension, and (3) Forked Subagent Pattern for token efficiency. The hook system remains valuable but can be deferred until after the foundation work stabilizes.

---

## Context & Scope

This upgrade involves migrating .opencode from its current 2-layer architecture (Commands → Subagents) to incorporate proven .claude patterns while maintaining the formal verification focus. The upgrade must preserve existing functionality while adding workflow safety, extensibility, and performance improvements.

**Current State Analysis**:
- .opencode has 19 subagents but no hooks system
- Research subagent already updated for complete workflow ownership
- Missing file-based metadata exchange pattern
- No Meta System Builder capability
- Subagents use direct loading vs .claude's forked pattern

---

## Key Findings

### 1. File-Based Metadata Exchange (Phase 1)

**Finding**: File-based metadata exchange provides reliable artifact tracking without console pollution.

**Evidence**: .claude uses `specs/{N}_{SLUG}/.return-meta.json` files with structured schema for:
- Status tracking (researched, planned, implemented, etc.)
- Artifact arrays with type, path, and summary
- Session metadata and delegation tracking
- Error handling with recovery information

**Implementation Path**:
1. Add `.opencode/context/core/formats/return-metadata-file.md`
2. Update subagents to write metadata files instead of console JSON
3. Update command logic to read metadata files during postflight
4. Add cleanup protocol for metadata files

**Key Schema Fields**:
```json
{
  "status": "researched|planned|implemented|partial|failed",
  "artifacts": [{"type": "report|plan|summary", "path": "...", "summary": "..."}],
  "metadata": {"session_id": "...", "agent_type": "...", "duration_seconds": N},
  "completion_data": {"completion_summary": "...", "claudemd_suggestions": "..."}
}
```

**Complexity**: Low - schema already defined and tested
**Effort**: 4-6 hours

### 2. Hook System Implementation (Deferred)

**Finding**: Hook system is well-documented, but can be deferred until metadata exchange and state validation stabilize.

**Evidence**: The .claude/hooks/ directory contains three core hooks:
- `subagent-postflight.sh` - Prevents premature workflow termination using marker files
- `log-session.sh` - Session tracking and logging
- `validate-state-sync.sh` - Consistency validation between TODO.md and state.json

**Implementation Path (Deferred)**:
1. Copy .claude/hooks/* to .opencode/hooks/
2. Update paths from .claude → .opencode in hook scripts
3. Create .opencode/hooks/ directory structure
4. Test hook activation with marker file protocol

**Complexity**: Low - direct port with path updates
**Effort**: 6-8 hours

### 3. Workflow Ownership Migration (Phase 2)

**Finding**: The researcher subagent already shows partial migration but needs complete ownership transfer.

**Evidence**: Current researcher.md has conflicting notes about ownership (line 141-153 says command handles status, but constraints say subagent handles it). Need to clarify and complete the pattern.

**Current State**:
- Researcher has complete workflow specification but contradictory notes
- Other subagents (planner, implementer) need similar updates
- Commands need postflight stages removed

**Implementation Path**:
1. Resolve researcher.md ownership contradictions
2. Update all subagents to own complete workflow (preflight→postflight)
3. Remove postflight stages from command files
4. Add postflight control marker protocol
5. Test workflow continuity

**Complexity**: Medium - requires careful coordination across multiple files
**Effort**: 16-20 hours

### 4. Meta System Builder Port (Phase 3)

**Finding**: Meta System Builder enables dynamic architecture generation with domain-specific customization.

**Evidence**: Based on research, Meta System Builder includes:
- Interactive interview workflow (8 stages)
- System builder subagents: domain-analyzer, agent-generator, context-organizer, workflow-designer, command-creator
- Skill-to-agent mapping for clear routing
- Formal verification template adaptations

**Formal Verification Adaptations Required**:
- Coq integration templates (tactics, proof scripts)
- Isabelle/HOL support (theory files, proof methods)
- Enhanced Lean 4 patterns (Mathlib, Lake, LSP)
- Theorem prover integration options

**Implementation Path**:
1. Port 5 core subagents from .claude/agent/subagents/
2. Create .opencode/command/meta.md with interview workflow
3. Add formal verification domain templates
4. Create skill-to-agent mapping documentation
5. Test architecture generation

**Complexity**: High - multiple interconnected components
**Effort**: 32-40 hours

### 5. Forked Subagent Pattern (Phase 4)

**Finding**: Forked subagent pattern provides 15-20% token efficiency through context isolation.

**Evidence**: Research shows benefits:
- Clean context windows for each subagent call
- Reduced token bloat from shared context
- Isolated execution environment
- Better resource utilization

**Implementation Path**:
1. Create skill wrappers: skill-researcher, skill-planner, skill-implementer
2. Migrate agents to full context loading pattern
3. Update command routing to invoke skills instead of direct agents
4. Add fallback mechanisms
5. Performance test and optimize

**Skill Template Structure**:
```yaml
---
name: skill-{name}
allowed-tools: Task
context: fork
agent: {target-agent}
---
# Thin wrapper implementation
```

**Complexity**: Medium - requires architectural changes
**Effort**: 16-24 hours

---

## Detailed Analysis by Phase

### Phase 1: Foundation (Week 1)
**Deliverables**:
- File-based metadata exchange schema
- Updated state management patterns
- Workflow reliability testing

**Risks**: 
- Metadata file cleanup reliability

**Mitigations**:
- Automated cleanup protocols

### Phase 2: Workflow Ownership (Week 2)  
**Deliverables**:
- Updated subagents with complete ownership
- Cleaned command files
- Postflight control markers
- User experience validation

**Risks**:
- Breaking existing workflows
- Status synchronization issues
- Deferred hook coverage gaps

**Mitigations**:
- Feature flags for gradual rollout
- Atomic two-phase commits
- Manual validation before hooks

### Phase 3: Meta Builder (Weeks 3-4)
**Deliverables**:
- 5 ported subagents
- Interactive /meta command
- Formal verification templates
- Architecture generation testing

**Risks**:
- System complexity increase
- Template quality issues

**Mitigations**:
- Start with basic templates
- User feedback loops

### Phase 4: Forked Pattern (Weeks 5-6)
**Deliverables**:
- Skill wrapper layer
- Updated routing logic
- Performance optimization
- Token efficiency validation

**Risks**:
- Performance regression
- Debugging complexity

**Mitigations**:
- Benchmark at each step
- Fallback to direct calls

---

## Implementation Approach Recommendations

### 1. Use Gradual Migration Strategy
- Keep old subagents during transition
- Feature flags to enable new patterns incrementally
- Rollback documentation at each phase

### 2. Prioritize Workflow Safety First
- Implement metadata exchange and state validation before other changes
- Defer hooks until workflows stabilize
- Test thoroughly before proceeding

### 3. Leverage Existing .claude Patterns
- Direct port of proven implementations
- Adapt paths and contexts for .opencode
- Preserve .claude's error handling and recovery mechanisms

### 4. Maintain Formal Verification Focus
- Customize Meta Builder templates for theorem provers
- Preserve .opencode's specialized context
- Add Coq, Isabelle/HOL integration options

---

## Code Examples

### Hook System Integration
```bash
# .opencode/hooks/subagent-postflight.sh (ported)
MARKER_FILE="specs/.postflight-pending"
LOOP_GUARD_FILE="specs/.postflight-loop-guard"

# Updated path from .claude → .opencode
LOG_DIR=".opencode/logs"
```

### Metadata Exchange Pattern  
```bash
# In subagent execution
metadata_file="specs/${task_number}_${slug}/.return-meta.json"
cat > "$metadata_file" << EOF
{
  "status": "researched",
  "artifacts": [{"type": "report", "path": "...", "summary": "..."}],
  "metadata": {"session_id": "$session_id", "agent_type": "researcher"}
}
EOF
```

### Skill Wrapper Template
```yaml
---
name: skill-researcher
description: Thin wrapper for researcher agent
allowed-tools: Task
context: fork
agent: researcher
---
# Postflight control pattern implementation
```

---

## Decisions

### Decision 1: Implement Hook System First
**Rationale**: Foundation for all subsequent phases
**Impact**: Enables reliable workflow control
**Confidence**: High - proven pattern from .claude

### Decision 2: Use File-Based Metadata Exchange
**Rationale**: Eliminates console pollution, provides reliable tracking
**Impact**: Better artifact management and debugging
**Confidence**: High - schema already tested in .claude

### Decision 3: Phase 2 Before Phase 3
**Rationale**: Workflow ownership must be stable before adding complexity
**Impact**: Reduces risk of breaking changes during Meta Builder port
**Confidence**: Medium-High - logical dependency ordering

---

## Recommendations

### Immediate Actions (Week 1)
1. Create .opencode/hooks/ directory and port 3 hook scripts
2. Add return-metadata-file.md to .opencode context
3. Update researcher.md contradictions and test complete workflow ownership
4. Begin gradual migration testing with feature flags

### Medium-term Actions (Weeks 2-4)
1. Complete workflow ownership migration for all subagents
2. Remove postflight from commands after validation
3. Port Meta System Builder subagents with formal verification templates
4. Create interactive /meta command

### Long-term Actions (Weeks 5-6)
1. Implement forked subagent pattern for key agents
2. Create skill wrapper layer
3. Performance optimization and token efficiency testing
4. Documentation and training materials

---

## Risks & Mitigations

### High Risk: Breaking Existing Workflows
**Probability**: Medium
**Impact**: High
**Mitigation**: Feature flags, gradual rollout, rollback documentation

### Medium Risk: Meta System Complexity
**Probability**: Medium  
**Impact**: Medium
**Mitigation**: Start simple, user feedback, iterative improvement

### Low Risk: Performance Regression
**Probability**: Low
**Impact**: Medium
**Mitigation**: Benchmarking, fallback mechanisms, optimization

---

## Appendix: Sources and Citations

### Primary Sources
1. **agent_system_upgrade_plan.md** - Comprehensive upgrade specification with 4-phase approach
2. **implementation_roadmap.md** - Detailed task breakdown and acceptance criteria
3. **.claude/hooks/subagent-postflight.sh** - Hook system reference implementation
4. **.claude/context/core/formats/return-metadata-file.md** - Metadata exchange schema specification

### Secondary Sources
1. Claude Code Documentation - Hook system patterns and best practices
2. Agent Skills Standards (Medium, Jan 2026) - Modular agent architecture patterns
3. Subagents Guide (CometAPI, Oct 2025) - Context isolation and forked pattern benefits
4. Multi-Agent Systems Guide (DEV, Jan 2026) - Design patterns for agent orchestration

### Research Sources
- https://claude.com/blog/how-to-configure-hooks - Hook configuration patterns
- https://www.cometapi.com/how-to-create-and-use-subagents-in-claude-code/ - Subagent implementation
- https://nayakpplaban.medium.com/agent-skills-standard-for-smarter-ai - Skill system architecture
- https://github.com/anthropics/skills - Agent skills repository
- https://docs.anthropic.com/en/docs/claude-code/hooks - Official hooks reference

---

## Next Steps

1. **Approve Research Findings** - Review and validate implementation approach
2. **Allocate Resources** - Assign developers to each phase with clear ownership
3. **Set Up Infrastructure** - Create feature flags and testing frameworks
4. **Begin Phase 1** - Start with hook system and metadata exchange implementation
5. **Establish Monitoring** - Set up token usage and workflow completion tracking