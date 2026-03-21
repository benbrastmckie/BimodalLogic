# Research Report: Task #591 - Architectural Options Comparison

**Task**: 591 - Find and Fix Double Forking in Skill-Agent Delegation
**Date**: 2026-01-18
**Type**: Comparative Analysis
**Focus**: Compare Option A (current plan) vs Option B (alternative strategy)

## Executive Summary

This report compares two architectural strategies for eliminating redundant context overhead in thin wrapper skills:

- **Option A** (Current Plan): Remove `context: fork`, keep explicit Task tool delegation
- **Option B** (Alternative): Keep `context: fork` + `agent:` field, remove Task tool calls

**Key Finding**: Both options eliminate the redundancy, but they represent fundamentally different architectural philosophies. Option A favors **explicit delegation** with skills as routers. Option B favors **declarative configuration** with automatic context forking.

**Recommendation**: Option A remains the safer choice for current implementation, but Option B offers cleaner architecture if `context: fork` proves reliable long-term.

## Option A: Remove `context: fork`, Keep Task Tool

### Description

**Current Configuration**:
```yaml
---
name: skill-researcher
context: fork                    # REMOVE THIS
agent: general-research-agent    # REMOVE THIS
allowed-tools: Task              # KEEP THIS
---

# Skill body
Invoke Task tool with subagent_type: "general-research-agent"
```

**After Option A**:
```yaml
---
name: skill-researcher
allowed-tools: Task              # Only this remains
---

# Skill body (unchanged)
Invoke Task tool with subagent_type: "general-research-agent"
```

### Execution Flow

```
User invokes: Skill(skill-researcher)
  ↓
Skill instructions loaded in MAIN CONTEXT (~100 tokens overhead)
  ↓
Skill executes: Task(subagent_type="general-research-agent")
  ↓
Agent spawns in ISOLATED SUBPROCESS with own context window
  ↓
Agent executes research logic
  ↓
Agent returns JSON result
  ↓
Skill propagates result to caller
```

### Advantages

1. **Explicit Delegation Pattern**
   - Clear where subprocess boundary occurs (Task tool call)
   - Easy to trace execution flow
   - Skill body shows exactly what happens

2. **Proven Reliability**
   - Task tool delegation works today, no bugs
   - No dependency on recently-fixed `context: fork` behavior
   - Lower risk of regression

3. **Flexibility**
   - Commands can invoke agents directly via Task tool (bypass skills)
   - Orchestrator can route to any agent without skill wrapper
   - Agent selection can be dynamic (runtime decision)

4. **Simpler Mental Model**
   - Skill = router/validator in main context
   - Agent = executor in subprocess
   - Clear separation of concerns

5. **Debugging Transparency**
   - Tool calls visible in conversation
   - Easy to see when subprocess spawned
   - Stack traces show delegation point

6. **Compatibility with Orchestrator**
   - Orchestrator currently uses direct Task tool calls
   - Skills become optional convenience wrappers
   - No need to refactor orchestrator routing

### Disadvantages

1. **Skill Instructions in Main Context**
   - ~100 tokens per skill invocation added to main conversation
   - Cumulative token cost over multiple skill calls
   - Main context window grows faster

2. **Duplication of Agent Specification**
   - Agent name appears in skill body (Task call)
   - Agent tools/description in agent file
   - Two places to maintain

3. **More Verbose Frontmatter**
   - Skills need `allowed-tools: Task`
   - No automatic agent binding
   - Manual tool specification

4. **Instruction Redundancy**
   - Skill body describes what agent does
   - Agent file also describes what agent does
   - Documentation duplication

### Implementation Complexity

**Low** - Simple frontmatter field removal:
- Remove 2 lines from 8 skill files
- No changes to skill body or agent files
- No changes to command files (they already invoke via Skill tool)

**Effort**: 1.5 hours (30min implementation + 30min testing + 30min documentation)

### Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Skill behavior changes | Low | Low | Skills become thinner wrappers, functionality in agents unchanged |
| Token overhead grows | Medium | Low | ~800 tokens total (100 per skill × 8 skills) acceptable |
| Maintenance burden increases | Low | Low | Fewer frontmatter fields to maintain |

---

## Option B: Keep `context: fork`, Remove Task Tool

### Description

**Current Configuration**:
```yaml
---
name: skill-researcher
context: fork                    # KEEP THIS
agent: general-research-agent    # KEEP THIS
allowed-tools: Task              # REMOVE THIS (add agent's tools)
---

# Skill body - REMOVE Task tool call, move agent logic here
```

**After Option B**:
```yaml
---
name: skill-researcher
context: fork
agent: general-research-agent
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, WebSearch, WebFetch
---

# Skill body - Agent execution logic moves here
# (merge agent instructions into skill body)
```

### Execution Flow

```
User invokes: Skill(skill-researcher)
  ↓
Claude Code automatically spawns context for "general-research-agent"
  (based on context: fork + agent: field)
  ↓
Skill instructions execute IN THE AGENT CONTEXT (isolated subprocess)
  ↓
Skill body contains research logic (previously in agent file)
  ↓
Skill returns JSON result
```

**Key Difference**: The `context: fork` + `agent:` fields tell Claude Code to automatically spawn the specified agent context. No explicit Task tool call needed.

### Advantages

1. **Declarative Configuration**
   - Single source of truth: frontmatter specifies agent
   - No explicit delegation code needed
   - Cleaner separation of "what" (frontmatter) vs "how" (body)

2. **Zero Main Context Overhead**
   - Skill instructions never loaded in main context
   - Automatic context forking before skill execution
   - Better token efficiency (saves ~100 tokens per invocation)

3. **Single Configuration Point**
   - Merge skill and agent into one file
   - Agent tools specified in skill frontmatter
   - Simpler architecture (fewer files)

4. **Consistent with Claude Code Intent**
   - `context: fork` + `agent:` designed for this use case
   - Follows official Claude Code subagent pattern
   - Bug #17283 fix enables this workflow

5. **Implicit Subprocessing**
   - No need to manually invoke Task tool
   - Less boilerplate in skill body
   - More concise skill definitions

### Disadvantages

1. **Depends on Recently-Fixed Bug**
   - Bug #17283 (context: fork ignored) only fixed ~Jan 10, 2026
   - Less battle-tested than Option A
   - Higher risk of regressions in future Claude Code updates

2. **Opaque Delegation Boundary**
   - No visible Task tool call showing subprocess creation
   - Harder to trace when context switching occurs
   - Less explicit control flow

3. **Skill-Agent File Merge Required**
   - Agent instructions must move into skill body
   - Lose separation between skill (router) and agent (executor)
   - More complex skill files (no longer "thin wrappers")

4. **Inflexible Routing**
   - Agent specified statically in frontmatter
   - Can't dynamically select agent at runtime
   - Commands can't bypass skill to invoke agent directly

5. **Incompatible with Current Orchestrator**
   - Orchestrator uses direct Task tool calls
   - Would need refactoring to use Skill tool instead
   - Breaks current /research, /plan, /implement routing

6. **Tool Configuration Duplication**
   - Agent tools must be listed in skill frontmatter
   - Same tool list maintained in agent documentation
   - Two places to update when tools change

7. **Nested Skills Bug Risk**
   - Bug #17351 (nested skills context return) still open
   - If skill-orchestrator invokes a forked skill, context handling may break
   - Limits compositional patterns

### Implementation Complexity

**High** - Requires architectural refactoring:
- Merge 8 agent files into skill files
- Update frontmatter with full tool lists
- Refactor orchestrator to use Skill tool instead of Task tool
- Test context forking behavior for each skill
- Verify no regression from bug #17283

**Effort**: 4-5 hours (2hr implementation + 1hr testing + 1hr refactoring orchestrator + 1hr documentation)

### Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Bug #17283 regression | Medium | High | Test thoroughly, document rollback plan |
| Bug #17351 affects composition | High | Medium | Avoid nested skill calls, use direct Task delegation |
| Orchestrator refactoring breaks routing | Medium | High | Extensive testing of all commands |
| Skill files become too complex | Low | Medium | Keep skill body focused, use agent pattern docs |
| Future Claude Code changes break context: fork | Low | High | Monitor Claude Code release notes |

---

## Side-by-Side Comparison

| Dimension | Option A (Remove context:fork) | Option B (Keep context:fork) |
|-----------|-------------------------------|------------------------------|
| **Token Overhead** | +100 tokens/invocation in main | 0 tokens in main (forked) |
| **Delegation Clarity** | Explicit (Task tool visible) | Implicit (automatic fork) |
| **Implementation Effort** | 1.5 hours | 4-5 hours |
| **Risk Level** | Low | Medium-High |
| **Bug Dependencies** | None (Task tool stable) | Bug #17283 fix, #17351 risk |
| **File Count** | Skills + Agents (separate) | Skills only (merged) |
| **Orchestrator Impact** | No changes needed | Requires refactoring |
| **Runtime Flexibility** | Dynamic agent selection | Static agent binding |
| **Mental Model** | Router → Executor | Declarative auto-fork |
| **Debugging** | Transparent (tool calls visible) | Opaque (automatic fork) |
| **Rollback Complexity** | Trivial (re-add 2 lines) | Complex (un-merge files) |

---

## Architectural Philosophy

The choice between these options reflects a deeper architectural question:

### Option A: Explicit Delegation (Imperative)
- **Philosophy**: Skills are thin routers that explicitly delegate
- **Model**: "Tell me exactly what to do and when"
- **Analogy**: Function call with explicit subprocess.Popen()
- **Transparency**: High (every delegation visible)
- **Flexibility**: High (can change delegation target at runtime)

### Option B: Declarative Forking (Declarative)
- **Philosophy**: Skills declare their execution context
- **Model**: "Configure once, automatic execution"
- **Analogy**: Decorator pattern (@run_in_subprocess)
- **Transparency**: Low (automatic magic)
- **Flexibility**: Low (static configuration)

---

## Recommendation

### Primary Recommendation: **Option A** (Current Plan)

**Rationale**:
1. **Lower Risk**: No dependency on recently-fixed bugs
2. **Less Work**: 1.5 hours vs 4-5 hours
3. **Reversible**: Trivial rollback (add 2 lines back)
4. **Proven**: Task tool delegation battle-tested
5. **Compatible**: No orchestrator refactoring needed
6. **Transparent**: Delegation boundaries visible

**Acceptable Cost**: ~100 tokens per skill invocation is negligible compared to:
- Agent work (5,000-20,000 tokens)
- Main conversation context (typically <10,000 tokens)
- Total savings of only 800 tokens (100 × 8 skills) in rare cases where all skills invoked

**When to Use**:
- Immediate deployment (task 591)
- Risk-averse environments
- When explicit control flow matters
- When orchestrator refactoring is not feasible

### Alternative Recommendation: **Option B** (Future Consideration)

**Rationale**:
1. **Cleaner Architecture**: Single file per skill, declarative
2. **Better Token Efficiency**: Zero main context overhead
3. **Aligned with Claude Code**: Official subagent pattern
4. **Simpler Configuration**: Fewer moving parts after merge

**When to Consider**:
- After 3-6 months of `context: fork` stability (prove bug #17283 fix holds)
- If bug #17351 (nested skills) gets fixed
- If main context token pressure becomes an issue
- As part of larger architecture refactoring (e.g., rewrite orchestrator)

**Migration Path**: Implement Option A now, revisit Option B in 6 months if:
- No `context: fork` regressions observed
- Nested skills bug fixed
- Token efficiency becomes priority
- Willing to invest in orchestrator refactoring

---

## Hybrid Option C: Use Both Patterns Contextually

**Possibility**: Different skills could use different strategies based on their usage patterns:

### Use Option A (No fork) for:
- **skill-orchestrator**: Needs runtime flexibility, routes to multiple agents
- **skill-status-sync**: Direct execution skill, no subprocess needed
- High-frequency skills where explicit routing helps debugging

### Use Option B (context:fork) for:
- **skill-document-converter**: Complex multi-step, benefits from isolated context
- **skill-meta**: Interactive interview, long-running forked context
- Low-frequency skills where token savings matter

**Advantage**: Optimize each skill for its use case

**Disadvantage**: Inconsistent architecture, higher cognitive load, harder to maintain

**Verdict**: **Not Recommended** - Consistency more valuable than marginal gains

---

## Implementation Decision Matrix

| Criterion | Weight | Option A Score | Option B Score | Winner |
|-----------|--------|----------------|----------------|--------|
| Implementation Speed | High | 9/10 | 4/10 | A |
| Risk Level | High | 9/10 | 5/10 | A |
| Token Efficiency | Medium | 6/10 | 10/10 | B |
| Architectural Clarity | Medium | 8/10 | 7/10 | A |
| Long-term Maintainability | Medium | 7/10 | 8/10 | B |
| Rollback Simplicity | High | 10/10 | 3/10 | A |
| Bug Dependency | High | 10/10 | 6/10 | A |
| **Weighted Total** | - | **8.5/10** | **6.1/10** | **A** |

---

## Verification Testing Strategy

### If Option A Selected (Current Plan)

**Phase 1: Frontmatter Validation**
```bash
# Verify no syntax errors
for skill in skill-{researcher,lean-research,planner,implementer,lean-implementation,latex-implementation,meta,document-converter}; do
  echo "Checking $skill..."
  # YAML frontmatter should parse
  grep -A 10 "^---$" .claude/skills/$skill/SKILL.md | head -n -1
done
```

**Phase 2: Skill Invocation Test**
```bash
# Test each skill via command
/research 999  # Tests skill-researcher or skill-lean-research
/plan 999      # Tests skill-planner
/implement 999 # Tests skill-implementer, skill-lean-implementation, or skill-latex-implementation
/meta --analyze # Tests skill-meta
```

**Phase 3: Behavior Verification**
- Verify agents still spawn correctly
- Verify return format unchanged
- Verify artifacts created in correct locations
- Check git log for proper commits

### If Option B Selected (Alternative)

**Phase 1: File Merge**
- Copy agent instructions into skill body
- Update skill frontmatter with agent's tools
- Remove original agent file (or archive)
- Test YAML frontmatter parsing

**Phase 2: Orchestrator Refactoring**
- Update /research command to use Skill(skill-researcher) not Task(general-research-agent)
- Update /plan command to use Skill(skill-planner)
- Update /implement command to use Skill(skill-implementer)
- Test all commands with real tasks

**Phase 3: Context Fork Verification**
- Instrument skill execution to verify context isolation
- Check that skill instructions don't appear in main context
- Verify agent tools available in forked context
- Test nested skill calls (if any) for bug #17351

**Phase 4: Regression Testing**
- Run full workflow: /research → /plan → /implement
- Verify all 8 skills function correctly
- Check artifact creation
- Verify git commits
- Monitor for memory issues

---

## Documentation Updates Required

### Option A Documentation

**Files to Update**:
1. `.claude/CLAUDE.md` - Skill Architecture section
   - Remove `context: fork` from thin wrapper pattern
   - Clarify when to use context: fork (direct execution skills only)
   - Update skill-to-agent mapping table

2. `.claude/context/core/templates/thin-wrapper-skill.md`
   - Remove context: fork from template
   - Emphasize explicit Task tool delegation

3. `.claude/context/core/orchestration/delegation.md`
   - Document that skills execute in main context
   - Clarify subprocess boundary at Task tool call

### Option B Documentation

**Files to Update**:
1. `.claude/CLAUDE.md` - Skill Architecture section
   - Document merged skill-agent pattern
   - Update skill-to-agent mapping (agents removed)
   - Explain automatic context forking

2. `.claude/context/core/templates/thin-wrapper-skill.md`
   - Rename to forked-skill.md (no longer "thin wrapper")
   - Update template with context: fork + agent: fields
   - Remove Task tool invocation pattern

3. `.claude/context/core/orchestration/delegation.md`
   - Document declarative forking pattern
   - Explain orchestrator skill invocation

4. Command files (plan.md, research.md, implement.md)
   - Change Task tool calls to Skill tool calls
   - Update delegation context preparation

---

## Rollback Procedures

### Option A Rollback (if needed)

**Trigger**: Skills malfunction after removing context: fork

**Steps**:
```bash
# 1. Revert the commit
git revert HEAD

# 2. Verify frontmatter restored
grep -A 5 "^---$" .claude/skills/skill-researcher/SKILL.md
# Should show:
#   context: fork
#   agent: general-research-agent

# 3. Restart Claude Code session (if needed)
# 4. Test skill invocation
```

**Time to Rollback**: 5 minutes
**Data Loss**: None (skills never modified, only frontmatter)

### Option B Rollback (if needed)

**Trigger**: Context forking breaks, or orchestrator routing fails

**Steps**:
```bash
# 1. Restore agent files from archive
cp -r .claude/agents-backup/* .claude/agents/

# 2. Restore skill files from git
git checkout HEAD~1 -- .claude/skills/

# 3. Restore command files
git checkout HEAD~1 -- .claude/commands/

# 4. Rebuild skill-agent separation
# (Manual work: un-merge skill bodies)

# 5. Restart Claude Code session
```

**Time to Rollback**: 30-60 minutes (requires manual file editing)
**Data Loss Risk**: Medium (merged files need manual separation)

---

## Conclusion

**For Task 591**: Proceed with **Option A** (current plan in implementation-001.md)

**Reasons**:
1. Lower risk, faster implementation
2. No dependency on recently-fixed bugs
3. Trivial rollback if issues arise
4. No orchestrator refactoring needed
5. Token overhead (~100 per skill) is negligible

**Future Work**: Consider Option B in 6 months if:
- `context: fork` proves stable over time
- Nested skills bug (#17351) fixed
- Token efficiency becomes critical
- Willing to invest in architecture refactoring

**Next Steps**:
1. Review this comparative analysis
2. Confirm Option A selection
3. Run `/implement 591` to execute current plan
4. Monitor for any issues over next 2-4 weeks
5. Document decision rationale for future reference

---

## Appendix: Third-Party Options (Not Recommended)

### Option C: Hybrid Approach
Mix Option A and Option B across different skills. **Rejected** due to inconsistency.

### Option D: Remove All Skills, Use Agents Directly
Commands invoke Task tool directly without skill wrappers. **Rejected** because:
- Loses skill-level documentation
- Loses skill-level validation/routing logic
- Commands become more complex
- No abstraction layer between commands and agents

### Option E: Keep Current Redundant Architecture
Do nothing, accept ~100 token overhead per skill. **Rejected** because:
- Known inefficiency with easy fix
- No advantage over Option A
- Wastes context window unnecessarily

---

## References

- research-001.md - Original double forking investigation
- implementation-001.md - Current plan (Option A)
- [Claude Code Skills Documentation](https://code.claude.com/docs/en/skills)
- [GitHub Issue #17283](https://github.com/anthropics/claude-code/issues/17283) - context: fork bug (FIXED)
- [GitHub Issue #17351](https://github.com/anthropics/claude-code/issues/17351) - Nested skills bug (OPEN)
- `.claude/CLAUDE.md` - Current architecture documentation
