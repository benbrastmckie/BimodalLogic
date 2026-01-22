# .opencode System Upgrade Plan
**Version**: 1.0  
**Date**: 2026-01-21  
**Purpose**: Upgrade .opencode with key .claude innovations while preserving formal verification strengths

---

## Executive Summary

This upgrade plan identifies the most valuable innovations from .claude that should be incorporated into .opencode to achieve feature parity while maintaining .opencode's specialization for formal verification. The upgrade focuses on three high-impact areas: Workflow Safety, Meta System Builder, and Agent Architecture Patterns.

## Key Differences Analysis

### Architecture Overview
| Aspect | .claude (3-Layer) | .opencode (2-Layer) |
|--------|------------------|-------------------|
| **Pattern** | Skills (thin wrappers) → Agents → Specialists | Commands → Subagents |
| **Context Loading** | Forked subagent pattern with isolation | Direct loading with lazy strategy |
| **Workflow Ownership** | Skills own complete workflow (preflight→postflight) | Subagents own execution only |
| **Return Handling** | File-based metadata exchange | Direct JSON returns |

### Critical Innovations in .claude

1. **Forked Subagent Pattern** - Token-efficient isolation
2. **Skill-Internal Postflight** - Eliminates "continue" prompts
3. **Meta System Builder** - Interactive architecture generation
4. **Hook System** - Automated workflow guardrails
5. **File-Based Metadata Exchange** - Reliable data transfer

---

## Upgrade Components by Priority

### Priority 1: Workflow Safety & Reliability

#### 1.1 Implement Skill-Internal Postflight Pattern
**Impact**: Eliminates user frustration with "continue" prompts  
**Complexity**: Medium  
**Effort**: 16 hours

**Current Problem**: .opencode commands wait for subagent returns, then perform postflight operations at the command level, creating UX friction.

**Solution**: Adopt .claude's pattern where subagents handle their own postflight:

```markdown
# .opencode/command/research.md (updated)
<workflow_execution>
  <stage id="0" name="Preflight">
    <!-- Update status BEFORE delegation -->
  </stage>
  <stage id="1" name="Delegate">
    <!-- Invoke researcher with postflight responsibility -->
  </stage>
  <!-- No postflight stages - handled by subagent -->
</workflow_execution>
```

**Implementation Steps**:
1. Update all .opencode/agent/subagents/*.md to own complete workflow
2. Remove postflight stages from commands
3. Add postflight control pattern (marker files)
4. Test workflow continuity

#### 1.2 Implement Hook System
**Impact**: Prevents workflow failures and provides automated recovery  
**Complexity**: Low  
**Effort**: 8 hours

**Components**:
- `.opencode/hooks/subagent-postflight.sh` - Block premature termination
- `.opencode/hooks/log-session.sh` - Session tracking
- `.opencode/hooks/validate-state-sync.sh` - Consistency checks

#### 1.3 Add File-Based Metadata Exchange
**Impact**: Reliable artifact tracking without console pollution  
**Complexity**: Low  
**Effort**: 6 hours

**Implementation**:
1. Add `.opencode/context/core/formats/return-metadata-file.md`
2. Update subagents to write metadata files
3. Remove JSON console returns

### Priority 2: Meta System Builder

#### 2.1 Port Meta System Builder
**Impact**: Enables dynamic system extension for new domains  
**Complexity**: High  
**Effort**: 40 hours

**Key Components to Port**:
- Interactive interview workflow (8 stages)
- System builder subagents:
  - domain-analyzer
  - agent-generator  
  - context-organizer
  - workflow-designer
  - command-creator

**Formal Verification Adaptation**:
- Add proof-oriented templates
- Include theorem prover integration options
- Add verification workflow patterns

#### 2.2 Add Skill-to-Agent Mapping
**Impact**: Clear routing architecture and extensibility  
**Complexity**: Low  
**Effort**: 4 hours

**Implementation**:
```markdown
<!-- .opencode/CLAUDE.md updated -->
## Skill-to-Agent Mapping

| Skill | Agent | Domain |
|-------|-------|--------|
| skill-lean-research | lean-research-agent | Lean 4/Mathlib research |
| skill-researcher | researcher | General research |
| skill-planner | planner | Implementation planning |
```

### Priority 3: Agent Architecture Improvements

#### 3.1 Implement Forked Subagent Pattern
**Impact**: 15-20% token efficiency improvement  
**Complexity**: Medium  
**Effort**: 20 hours

**Migration Path**:
1. Convert key subagents to forked pattern:
   - researcher → general-research-agent
   - planner → planner-agent
   - implementer → general-implementation-agent
2. Create thin wrapper skills:
   - skill-researcher
   - skill-planner
   - skill-implementer

#### 3.2 Add Lazy Directory Creation
**Impact**: Cleaner project structure, reduced filesystem ops  
**Complexity**: Low  
**Effort**: 4 hours

Update all subagents to create directories only when writing files.

---

## Implementation Roadmap

### Phase 1: Foundation (Week 1)
- [ ] Implement hook system
- [ ] Add file-based metadata exchange
- [ ] Update state management patterns
- [ ] Test workflow reliability

### Phase 2: Workflow Ownership (Week 2)  
- [ ] Migrate subagents to own complete workflows
- [ ] Remove postflight from commands
- [ ] Add postflight control markers
- [ ] Test user experience improvements

### Phase 3: Meta Builder (Weeks 3-4)
- [ ] Port meta system builder subagents
- [ ] Adapt for formal verification context
- [ ] Add theorem prover integration options
- [ ] Test architecture generation

### Phase 4: Architecture Migration (Weeks 5-6)
- [ ] Implement forked subagent pattern
- [ ] Create skill wrappers
- [ ] Update routing logic
- [ ] Performance testing and optimization

---

## Migration Strategy

### Backward Compatibility
1. **Gradual Migration**: Keep old subagents during transition
2. **Feature Flags**: Use flags to enable new patterns
3. **Rollback Plan**: Document reversion steps

### Testing Strategy
1. **Unit Tests**: Each component in isolation
2. **Integration Tests**: Full workflows
3. **Performance Tests**: Token usage before/after
4. **User Acceptance**: Formal verification workflows

### Risk Mitigation
| Risk | Mitigation |
|------|------------|
| Breaking changes | Feature flags + gradual rollout |
| Token bloat | Monitor and optimize context loading |
| Complexity | Clear documentation and examples |
| Performance | Benchmark at each phase |

---

## Expected Outcomes

### User Experience Improvements
- No more "continue" prompts between workflow stages
- Faster command execution (15-20% token savings)
- More reliable state synchronization
- Self-healing workflows with hooks

### Developer Experience Improvements
- Easy system extension via /meta command
- Clear separation of concerns (skills= routing, agents=execution)
- Better debugging with file-based metadata
- Consistent patterns across all components

### System Capabilities
- Dynamic architecture generation
- Domain-specific customization
- Formal verification integration
- Extensible tool integration

---

## Success Metrics

### Quantitative
- Token usage reduction: 15-20%
- Command completion time: 25% improvement
- Error recovery rate: 90% automated
- System extension time: 50% faster with /meta

### Qualitative
- User satisfaction: Eliminate "continue" prompts
- Maintainability: Clear separation of concerns
- Extensibility: Easy domain addition
- Reliability: Self-healing workflows

---

## Next Steps

1. **Approve Plan**: Review and prioritize components
2. **Allocate Resources**: Assign developers to phases
3. **Set Milestones**: Define phase completion criteria
4. **Begin Implementation**: Start with Phase 1 foundation

---

## Appendix: Detailed Migration Examples

### Example 1: Research Workflow Migration

**Before (.opencode current)**:
```
User: /research 259
Command: Parse → Preflight → Delegate → Receive → Postflight → Return
Result: "continue" prompt after research completes
```

**After (with .claude patterns)**:
```
User: /research 259
Command: Parse → Preflight → Delegate → Return
Subagent: Execute → Status Update → Git Commit → Return to User
Result: Seamless completion, no prompts
```

### Example 2: Meta System Builder Usage

**New Capability**:
```
User: /meta
System: I'll help you build a custom agent system. What domain?
User: Coq theorem proving
System: [Generates complete architecture with Coq integration]
```

This upgrade plan provides a clear path to achieving feature parity with .claude while enhancing .opencode's formal verification capabilities. The phased approach ensures manageable implementation with measurable benefits at each stage.