# Implementation Plan: Optimize NO EMOJI Validation to Eliminate Redundant Checks

- **Task**: 241 - Optimize NO EMOJI validation to eliminate redundant checks and reduce system overhead
- **Status**: [NOT STARTED]
- **Effort**: 4-6 hours
- **Priority**: Medium
- **Dependencies**: 238 (completed)
- **Research Inputs**: 
  - Research Report: .opencode/specs/241_optimize_no_emoji_validation/reports/research-001.md
  - Key Finding: 95 validation lines across 18 files (4.7KB, ~1,200 tokens per invocation)
  - Recommended Solution: AGENTS.md centralization (80-98% overhead reduction)
- **Artifacts**: 
  - plans/implementation-001.md (this file)
  - summaries/implementation-summary-YYYYMMDD.md (upon completion)
- **Standards**:
  - .opencode/context/core/standards/plan.md
  - .opencode/context/core/standards/status-markers.md
  - .opencode/context/core/system/artifact-management.md
  - .opencode/context/core/standards/tasks.md
- **Language**: markdown
- **Lean Intent**: false

## Overview

Task 238 successfully eliminated 88 emoji instances from 24 .opencode system files but introduced extensive validation overhead: 95 validation lines consuming 4.7KB across 18 files, representing ~1,200 tokens per command invocation. This creates maintenance burden (18 files to update for any change) and context window bloat (12,000 tokens per session). The solution is to centralize the NO EMOJI rule in AGENTS.md (automatically loaded by OpenCode) and remove redundant validation from all agent, command, and other files. This achieves 98% token reduction per session and 94% fewer files to maintain while preserving enforcement through OpenCode's native rule loading mechanism.

**Definition of Done**: AGENTS.md created with centralized NO EMOJI rule, redundant validation removed from 17 files, documentation.md updated to reference AGENTS.md, validation testing confirms enforcement still works, performance measurements document savings.

## Goals & Non-Goals

**Goals**:
- Create AGENTS.md with minimal, self-contained NO EMOJI rule (Option 1: 20 lines, ~1KB, ~250 tokens)
- Remove redundant emoji validation from 7 agent files (researcher, planner, implementer, task-executor, lean-research-agent, lean-implementation-agent, reviewer)
- Remove redundant emoji validation from 6 command files (research, plan, implement, revise, task, review)
- Remove redundant emoji validation from 4 other files (errors, todo, error-diagnostics-agent, command-template)
- Keep documentation.md NO EMOJI Policy section as reference (not loaded in every invocation)
- Validate that NO EMOJI enforcement still works via AGENTS.md
- Measure and document performance improvements (context window savings, maintenance reduction)
- Achieve 98% token reduction per session (12,000 → 250 tokens)
- Achieve 94% maintenance reduction (18 → 1 file)

**Non-Goals**:
- Not implementing git pre-commit hooks for emoji scanning (optional future enhancement)
- Not modifying the NO EMOJI standard itself (only centralizing enforcement)
- Not removing mathematical symbols (→, ∧, ∨, ¬, □, ◇) which are NOT emojis
- Not changing documentation.md reference content (keep as detailed reference)

## Risks & Mitigations

**Risk 1: AGENTS.md not loaded by OpenCode**
- **Likelihood**: Very low (OpenCode automatically loads AGENTS.md per documentation)
- **Impact**: NO EMOJI rule not enforced, emojis could reappear
- **Mitigation**: Test AGENTS.md loading in Phase 1 before removing validation
- **Fallback**: Revert to distributed validation if AGENTS.md doesn't load

**Risk 2: LLM ignores AGENTS.md rule**
- **Likelihood**: Very low (LLMs follow system prompt instructions)
- **Impact**: Emojis could appear in artifacts despite rule
- **Mitigation**: Monitor first few command invocations in Phase 6 validation
- **Fallback**: Add git pre-commit hook for automated emoji scanning

**Risk 3: Contributors unaware of NO EMOJI rule**
- **Likelihood**: Low (AGENTS.md visible in project root)
- **Impact**: Manual edits might introduce emojis
- **Mitigation**: AGENTS.md is first file contributors see, add note in CONTRIBUTING.md
- **Fallback**: Code review catches violations

**Risk 4: Incomplete removal of validation**
- **Likelihood**: Medium (17 files to modify, easy to miss one)
- **Impact**: Residual validation overhead remains
- **Mitigation**: Use grep to verify all emoji references removed in Phase 6
- **Fallback**: Additional cleanup pass if needed

## Implementation Phases

### Phase 1: Create and Test AGENTS.md [COMPLETED]

- **Completed**: 2025-12-28T10:00:00Z
- **Goal**: Create AGENTS.md with centralized NO EMOJI rule and verify OpenCode loads it correctly
- **Tasks**:
  - [ ] Create .opencode/AGENTS.md file in project root
  - [ ] Write Option 1 (Minimal) content: rule, rationale, text alternatives, validation command, mathematical symbol exception
  - [ ] Content should be ~20 lines, ~1KB, ~250 tokens
  - [ ] Test that OpenCode loads AGENTS.md at session start (verify in agent context)
  - [ ] Run test command (/research or /plan) to confirm rule appears in system prompt
  - [ ] Verify NO EMOJI enforcement works before removing distributed validation
- **Timing**: 30 minutes
- **Acceptance Criteria**:
  - AGENTS.md exists at .opencode/AGENTS.md
  - Contains complete NO EMOJI rule with rationale and alternatives
  - OpenCode loads file automatically (confirmed via test command)
  - Rule enforced in test command output (no emojis in artifacts)

### Phase 2: Remove Validation from Agent Files [COMPLETED]

- **Completed**: 2025-12-28T10:15:00Z
- **Goal**: Remove redundant emoji validation from 7 agent files
- **Tasks**:
  - [ ] Update .opencode/agent/subagents/researcher.md: Remove emoji constraints and validation blocks
  - [ ] Update .opencode/agent/subagents/planner.md: Remove emoji constraints and validation blocks
  - [ ] Update .opencode/agent/subagents/implementer.md: Remove emoji constraints and validation blocks
  - [ ] Update .opencode/agent/subagents/task-executor.md: Remove emoji constraints and validation blocks
  - [ ] Update .opencode/agent/subagents/lean-research-agent.md: Remove emoji constraints and validation blocks
  - [ ] Update .opencode/agent/subagents/lean-implementation-agent.md: Remove emoji constraints and validation blocks
  - [ ] Update .opencode/agent/subagents/reviewer.md: Remove emoji constraints and validation blocks
  - [ ] Keep references to text-based status indicators (still useful guidance)
  - [ ] Remove: `<must>Follow NO EMOJI standard per documentation.md</must>`
  - [ ] Remove: `<must>Validate artifacts are emoji-free before returning</must>`
  - [ ] Remove: `<must_not>Use checkmark, cross mark, or warning emojis</must_not>`
  - [ ] Remove: `<must_not>Use any Unicode emoji characters in artifacts</must_not>`
  - [ ] Remove: Validation checks for emojis in `<validation>` blocks
- **Timing**: 1 hour
- **Acceptance Criteria**:
  - All 7 agent files updated
  - ~8 lines removed per file (~56 lines total, ~2.8KB)
  - No emoji validation constraints remain
  - Text-based status indicator references preserved
  - Files still valid markdown and well-formed

### Phase 3: Remove Validation from Command Files [COMPLETED]

- **Completed**: 2025-12-28T10:25:00Z
- **Goal**: Remove redundant emoji validation from 6 command files
- **Tasks**:
  - [ ] Update .opencode/command/research.md: Remove `<no_emojis>` tag and validation
  - [ ] Update .opencode/command/plan.md: Remove `<no_emojis>` tag and validation
  - [ ] Update .opencode/command/implement.md: Remove `<no_emojis>` tag and validation
  - [ ] Update .opencode/command/revise.md: Remove `<no_emojis>` tag and validation
  - [ ] Update .opencode/command/task.md: Remove `<no_emojis>` tag and validation
  - [ ] Update .opencode/command/review.md: Remove `<no_emojis>` tag and validation
  - [ ] Keep references to text-based status indicators in examples
  - [ ] Remove: `<no_emojis>` sections with emoji replacement instructions
  - [ ] Remove: Emoji validation from `<validation>` blocks
- **Timing**: 45 minutes
- **Acceptance Criteria**:
  - All 6 command files updated
  - ~5 lines removed per file (~30 lines total, ~1.5KB)
  - No `<no_emojis>` tags remain
  - Text-based status indicator examples preserved
  - Files still valid markdown and well-formed

### Phase 4: Remove Validation from Other Files [COMPLETED]

- **Completed**: 2025-12-28T10:30:00Z
- **Goal**: Remove redundant emoji validation from 4 other system files
- **Tasks**:
  - [ ] Update .opencode/command/errors.md: Remove emoji validation references
  - [ ] Update .opencode/command/todo.md: Remove emoji validation references
  - [ ] Update .opencode/agent/subagents/error-diagnostics-agent.md: Remove emoji validation references
  - [ ] Update .opencode/context/core/templates/command-template.md: Remove emoji validation from template
  - [ ] Ensure template no longer includes emoji validation in generated commands
- **Timing**: 30 minutes
- **Acceptance Criteria**:
  - All 4 files updated
  - ~3 lines removed per file (~12 lines total, ~0.6KB)
  - No emoji validation references remain
  - command-template.md generates commands without emoji validation
  - Files still valid markdown and well-formed

### Phase 5: Update Documentation References [COMPLETED]

- **Completed**: 2025-12-28T10:35:00Z
- **Goal**: Update documentation.md to reference AGENTS.md as primary enforcement mechanism
- **Tasks**:
  - [ ] Read .opencode/context/core/standards/documentation.md
  - [ ] Update NO EMOJI Policy section to reference AGENTS.md
  - [ ] Add note: "Enforcement: See .opencode/AGENTS.md for centralized rule (automatically loaded)"
  - [ ] Keep detailed policy content as reference (not loaded in every invocation)
  - [ ] Ensure documentation.md remains authoritative for edge cases and rationale
  - [ ] Update any other references to distributed validation approach
- **Timing**: 15 minutes
- **Acceptance Criteria**:
  - documentation.md references AGENTS.md as enforcement mechanism
  - NO EMOJI Policy section preserved as detailed reference
  - Clear distinction between enforcement (AGENTS.md) and reference (documentation.md)
  - No contradictory guidance about validation approach

### Phase 6: Validation and Testing [COMPLETED]

- **Completed**: 2025-12-28T10:45:00Z
- **Goal**: Verify NO EMOJI enforcement still works and measure performance improvements
- **Tasks**:
  - [ ] Run /research command on test task: Verify no emojis in research report
  - [ ] Run /plan command on test task: Verify no emojis in implementation plan
  - [ ] Run /implement command on test task: Verify no emojis in implementation artifacts
  - [ ] Run /task command to create test task: Verify no emojis in TODO.md entry
  - [ ] Use grep to scan all .opencode files for residual emoji validation references
  - [ ] Verify AGENTS.md is only file with emoji validation content (except documentation.md reference)
  - [ ] Measure context window usage: Compare before (12,000 tokens/session) vs after (~250 tokens/session)
  - [ ] Measure file count: Confirm 17 files no longer have validation (18 → 1)
  - [ ] Measure total validation lines: Confirm reduction from 95 to ~20 lines
  - [ ] Document performance improvements in implementation summary
- **Timing**: 1 hour
- **Acceptance Criteria**:
  - All test commands produce emoji-free artifacts
  - NO EMOJI rule enforced via AGENTS.md (behavioral enforcement confirmed)
  - No residual emoji validation in 17 modified files
  - Context window savings measured: ~98% reduction (12,000 → 250 tokens)
  - Maintenance reduction measured: 94% fewer files (18 → 1)
  - File size reduction measured: ~79% reduction (4.7KB → 1KB)

### Phase 7: Documentation and Summary [COMPLETED]

- **Completed**: 2025-12-28T10:55:00Z
- **Goal**: Document implementation and create summary artifact
- **Tasks**:
  - [ ] Create implementation summary at summaries/implementation-summary-YYYYMMDD.md
  - [ ] Document changes made: AGENTS.md created, 17 files modified, validation removed
  - [ ] Document performance improvements: 98% token reduction, 94% maintenance reduction
  - [ ] Include before/after metrics: lines, file size, token usage, file count
  - [ ] Document validation testing results: all commands produce emoji-free output
  - [ ] Include recommendations: Consider git pre-commit hook as optional enhancement
  - [ ] Update TODO.md task 241 status to [COMPLETED]
  - [ ] Link implementation summary in TODO.md
- **Timing**: 30 minutes
- **Acceptance Criteria**:
  - Implementation summary created with complete metrics
  - TODO.md updated to [COMPLETED] with summary link
  - All performance improvements documented
  - Clear before/after comparison provided
  - Recommendations for future enhancements included

## Testing & Validation

**Functional Testing**:
- [ ] AGENTS.md loads automatically at session start (Phase 1)
- [ ] NO EMOJI rule enforced in /research command output (Phase 6)
- [ ] NO EMOJI rule enforced in /plan command output (Phase 6)
- [ ] NO EMOJI rule enforced in /implement command output (Phase 6)
- [ ] NO EMOJI rule enforced in /task command output (Phase 6)
- [ ] Mathematical symbols (→, ∧, ∨, ¬, □, ◇) preserved in Lean artifacts (Phase 6)

**Validation Testing**:
- [ ] Grep scan confirms no residual emoji validation in 17 modified files (Phase 6)
- [ ] Grep scan confirms AGENTS.md is only file with emoji validation (except documentation.md) (Phase 6)
- [ ] All modified files are valid markdown and well-formed (Phases 2-4)
- [ ] command-template.md generates commands without emoji validation (Phase 4)

**Performance Testing**:
- [ ] Context window usage measured: Before vs After (Phase 6)
- [ ] File count measured: 18 files before → 1 file after (Phase 6)
- [ ] Total validation lines measured: 95 lines before → 20 lines after (Phase 6)
- [ ] File size measured: 4.7KB before → 1KB after (Phase 6)
- [ ] Token usage measured: ~12,000 tokens/session before → ~250 tokens/session after (Phase 6)

**Regression Testing**:
- [ ] All workflow commands function identically to before optimization (Phase 6)
- [ ] No functional changes to command behavior (Phase 6)
- [ ] Text-based status indicators still referenced in agent/command files (Phases 2-3)

## Artifacts & Outputs

**Primary Artifacts**:
- .opencode/AGENTS.md (new file, ~20 lines, ~1KB)
- plans/implementation-001.md (this file)
- summaries/implementation-summary-YYYYMMDD.md (upon completion)

**Modified Files** (17 total):
- Agent files (7): researcher.md, planner.md, implementer.md, task-executor.md, lean-research-agent.md, lean-implementation-agent.md, reviewer.md
- Command files (6): research.md, plan.md, implement.md, revise.md, task.md, review.md
- Other files (4): errors.md, todo.md, error-diagnostics-agent.md, command-template.md

**Updated Files** (1):
- .opencode/context/core/standards/documentation.md (reference to AGENTS.md added)

**Performance Metrics**:
- Context window savings: 98% reduction (12,000 → 250 tokens per session)
- Maintenance reduction: 94% fewer files (18 → 1)
- File size reduction: 79% reduction (4.7KB → 1KB)
- Line count reduction: 79% reduction (95 → 20 lines)

## Rollback/Contingency

**If AGENTS.md enforcement fails**:
1. Verify AGENTS.md exists at .opencode/AGENTS.md (not .opencode/context/AGENTS.md)
2. Verify AGENTS.md content is valid markdown
3. Test with minimal AGENTS.md content (Option 2: Ultra-Minimal)
4. If still failing, revert to distributed validation:
   - Restore emoji validation in 7 agent files (git revert)
   - Restore emoji validation in 6 command files (git revert)
   - Restore emoji validation in 4 other files (git revert)
   - Keep AGENTS.md as additional enforcement (belt-and-suspenders)

**If performance improvements not realized**:
1. Measure actual context window usage with profiling tools
2. Verify AGENTS.md is loaded only once per session (not per command)
3. Check for other sources of emoji validation overhead
4. Document actual improvements vs expected improvements
5. Adjust expectations if OpenCode architecture differs from documentation

**If emojis reappear in artifacts**:
1. Check AGENTS.md content for completeness
2. Verify LLM is following AGENTS.md instructions
3. Add git pre-commit hook for automated emoji scanning
4. Consider hybrid approach: AGENTS.md + selective validation in critical paths
5. Report issue to OpenCode if AGENTS.md not being loaded correctly

**Partial Rollback Strategy**:
- Can rollback individual file modifications independently
- AGENTS.md can coexist with distributed validation (redundant but safe)
- Phases can be rolled back in reverse order (7 → 6 → 5 → 4 → 3 → 2 → 1)
- Git history preserves all previous states for selective reversion
