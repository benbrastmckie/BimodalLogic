# Implementation Roadmap for .opencode Upgrade

## Phase 1: Foundation - Workflow Safety (Week 1)

### Objective
Establish reliable workflow patterns that eliminate user friction and prevent system failures.

### Tasks

#### 1.1 Implement Hook System (8 hours)
**Owner**: System Architecture  
**Deliverables**:
- `.opencode/hooks/subagent-postflight.sh`
- `.opencode/hooks/log-session.sh`  
- `.opencode/hooks/validate-state-sync.sh`
- Hook integration documentation

**Implementation**:
```bash
# Copy from .claude and adapt paths
cp .claude/hooks/subagent-postflight.sh .opencode/hooks/
# Update .claude → .opencode in file paths
# Test hook activation with marker files
```

#### 1.2 Add File-Based Metadata Exchange (6 hours)
**Owner**: Agent Development  
**Deliverables**:
- `.opencode/context/core/formats/return-metadata-file.md`
- Updated subagent templates
- Metadata parsing utilities

**Migration Steps**:
1. Add metadata file schema
2. Update researcher subagent to write `.return-meta.json`
3. Add postflight logic to read metadata
4. Test data exchange reliability

#### 1.3 Update State Management (4 hours)
**Owner**: System Integration  
**Deliverables**:
- Consistent state sync patterns
- Error handling improvements
- Validation scripts

**Changes**:
- Adopt atomic two-phase commit from .claude
- Add rollback mechanisms
- Implement validation hooks

### Acceptance Criteria
- [ ] Hooks prevent premature workflow termination
- [ ] Metadata files created and parsed reliably
- [ ] State synchronization passes validation tests
- [ ] No "continue" prompts in basic workflows

---

## Phase 2: Workflow Ownership Migration (Week 2)

### Objective
Transfer postflight responsibilities from commands to subagents for seamless user experience.

### Tasks

#### 2.1 Update Research Subagent (12 hours)
**Owner**: Agent Development  
**Deliverables**:
- `researcher.md` with complete workflow ownership
- Status transition logic
- Git commit integration
- Artifact linking

**New Workflow**:
```markdown
<workflow>
1. Parse delegation context
2. Update status to [RESEARCHING]
3. Execute research
4. Create report
5. Update status to [RESEARCHED]
6. Link artifacts in TODO.md
7. Create git commit
8. Return standardized result
</workflow>
```

#### 2.2 Update Other Subagents (16 hours)
**Owner**: Agent Development  
**Deliverables**:
- Updated `planner.md`
- Updated `implementer.md`
- Updated `lean-research-agent.md`
- Updated `lean-implementation-agent.md`

#### 2.3 Remove Postflight from Commands (4 hours)
**Owner**: Command Development  
**Deliverables**:
- Clean `/research.md`
- Clean `/plan.md`
- Clean `/implement.md`
- Simplified command templates

### Acceptance Criteria
- [ ] All workflows complete without "continue" prompts
- [ ] Status updates happen immediately on start
- [ ] Git commits created automatically
- [ ] Artifacts linked correctly

---

## Phase 3: Meta System Builder Port (Weeks 3-4)

### Objective
Enable dynamic system extension for formal verification domains.

### Tasks

#### 3.1 Port Core Subagents (24 hours)
**Owner**: System Architecture  
**Deliverables**:
- `.opencode/agent/subagents/domain-analyzer.md`
- `.opencode/agent/subagents/agent-generator.md`
- `.opencode/agent/subagents/context-organizer.md`
- `.opencode/agent/subagents/workflow-designer.md`
- `.opencode/agent/subagents/command-creator.md`

**Formal Verification Adaptations**:
```markdown
## Domain-Specific Templates

### Coq Integration
- Coq tactics and strategies
- Proof script patterns
- Compilation and verification workflows

### Isabelle/HOL Support  
- Theory file structures
- Proof method patterns
- Sledgehammer integration

### Lean 4 Enhancements
- Mathlib integration patterns
- Lake build workflows
- LSP integration strategies
```

#### 3.2 Create Meta Command (8 hours)
**Owner**: Command Development  
**Deliverables**:
- `.opencode/command/meta.md`
- Interview workflow scripts
- System generation orchestration

#### 3.3 Add Documentation (8 hours)
**Owner**: Documentation  
**Deliverables**:
- Meta system builder guide
- Domain extension examples
- Troubleshooting guide

### Acceptance Criteria
- [ ] `/meta` command launches interactive interview
- [ ] System generates complete agent architecture
- [ ] Formal verification templates included
- [ ] Generated systems pass validation

---

## Phase 4: Forked Subagent Pattern (Weeks 5-6)

### Objective
Achieve token efficiency through context isolation.

### Tasks

#### 4.1 Create Skill Wrappers (16 hours)
**Owner**: Agent Development  
**Deliverables**:
- `.opencode/skills/skill-researcher/SKILL.md`
- `.opencode/skills/skill-planner/SKILL.md`
- `.opencode/skills/skill-lean-research/SKILL.md`
- Skill-to-agent mapping documentation

**Skill Template**:
```yaml
---
name: skill-{name}
description: {description}
allowed-tools: Task
context: fork
agent: {target-agent}
---
# Thin wrapper implementation
```

#### 4.2 Update Agent Files (12 hours)
**Owner**: Agent Development  
**Deliverables**:
- Migrated agents with full context loading
- Isolated execution environment
- File-based returns

#### 4.3 Update Command Routing (4 hours)
**Owner**: Command Development  
**Deliverables**:
- Updated command logic to invoke skills
- Routing table for skill-to-agent mapping
- Fallback mechanisms

### Acceptance Criteria
- [ ] Token usage reduced by 15-20%
- [ ] Context isolation working
- [ ] Skill wrappers transparent to users
- [ ] Performance benchmarks met

---

## Testing Strategy

### Unit Tests
Each component tested in isolation:
```bash
# Hook testing
.test/test_hooks.sh

# Metadata exchange testing
.test/test_metadata_exchange.sh

# Workflow ownership testing  
.test/test_workflow_ownership.sh
```

### Integration Tests
Full workflow validation:
```bash
# Research workflow
.test/integration/test_research_workflow.sh

# Meta system builder
.test/integration/test_meta_builder.sh

# Forked subagents
.test/integration/test_forked_pattern.sh
```

### Performance Tests
Token efficiency measurement:
```bash
# Before/after token usage
.test/performance/measure_tokens.sh

# Context loading benchmarks
.test/performance/context_loading.sh
```

---

## Risk Management

### High-Risk Items
1. **Breaking existing workflows**
   - Mitigation: Feature flags for gradual rollout
   - Rollback: Keep old subagents during transition

2. **Meta system complexity**
   - Mitigation: Start with basic templates
   - Rollback: Disable /meta until stable

3. **Performance regression**
   - Mitigation: Benchmark at each phase
   - Rollback: Revert to direct agent calls

### Monitoring
- Token usage tracking
- Workflow completion rates
- Error frequency measurement
- User satisfaction metrics

---

## Success Metrics

### Phase 1
- 100% elimination of "continue" prompts
- 95% reduction in state sync errors
- 90% automated error recovery

### Phase 2  
- Seamless workflow completion
- Automatic git commits on all operations
- Proper artifact linking

### Phase 3
- Ability to generate domain-specific systems
- Formal verification template quality
- User satisfaction with /meta command

### Phase 4
- 15-20% token usage reduction
- Context isolation verified
- No performance regression

---

## Timeline Summary

| Phase | Duration | Key Deliverable |
|-------|----------|-----------------|
| 1 | Week 1 | Reliable workflows |
| 2 | Week 2 | Seamless UX |
| 3 | Weeks 3-4 | Extensible system |
| 4 | Weeks 5-6 | Token efficiency |

Total: 6 weeks for complete upgrade with measurable improvements at each phase.