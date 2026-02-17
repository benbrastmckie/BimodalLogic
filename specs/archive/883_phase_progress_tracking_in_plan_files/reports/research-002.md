# Research Report: Task #883 (Context Loading Analysis)

**Task**: 883 - Phase Progress Tracking in Plan Files
**Date**: 2026-02-16
**Focus**: Context file analysis for /implement workflow - identify improvements, consolidation opportunities, and loading efficiency gains

## Summary

The /implement command-skill-agent workflow loads context across three delegation layers with significant redundancy and suboptimal loading patterns. Key findings: (1) progress tracking context is fragmented across 3 formats (progress-file.md, handoff-artifact.md, plan-format.md) with no Progress subsection defined; (2) general-implementation-agent and lean-implementation-agent have nearly identical Context References sections that could be unified; (3) several context files are eagerly referenced but rarely needed; (4) the plan-format.md lacks the Progress subsection that research-001.md recommends adding to artifact-formats.md.

## Analysis Methodology

Traced context loading through:
1. `/implement` command (`.claude/commands/implement.md`)
2. `skill-implementer` / `skill-lean-implementation` skills
3. `general-implementation-agent` / `lean-implementation-agent` agents
4. Referenced context files in `.claude/context/`

## Findings

### 1. Context Loading Chain for /implement

| Layer | Component | Context Files Referenced | Load Timing |
|-------|-----------|-------------------------|-------------|
| Command | implement.md | None (minimal) | Immediate |
| Skill | skill-implementer/SKILL.md | 4 context refs (lazy) | Before Task |
| Agent | general-implementation-agent.md | 5 context refs (lazy) | After Stage 0 |

**Current References (skill-implementer)**:
- `.claude/context/core/formats/return-metadata-file.md` - REQUIRED
- `.claude/context/core/patterns/postflight-control.md` - REQUIRED
- `.claude/context/core/patterns/file-metadata-exchange.md` - RARELY NEEDED
- `.claude/context/core/patterns/jq-escaping-workarounds.md` - RARELY NEEDED

**Current References (general-implementation-agent)**:
- `.claude/context/core/formats/return-metadata-file.md` - REQUIRED (duplicate)
- `.claude/context/core/formats/summary-format.md` - SOMETIMES NEEDED
- `.claude/CLAUDE.md` - META TASKS ONLY
- `.claude/context/index.md` - META TASKS ONLY
- Existing skill/agent files as templates - META TASKS ONLY

### 2. Redundancy Analysis

**High Redundancy**:
| File | Referenced By | Issue |
|------|---------------|-------|
| `return-metadata-file.md` | skill-implementer, general-impl-agent, lean-impl-agent | 3x duplicate reference |
| `summary-format.md` | multiple agents | Could be consolidated with artifact-formats.md |
| `postflight-control.md` | skill-implementer | 266 lines, rarely needed - marker file is self-documenting |

**Low Value Context**:
| File | Lines | Issue |
|------|-------|-------|
| `file-metadata-exchange.md` | ~100 | Rarely needed - jq patterns are standard |
| `postflight-control.md` | ~266 | Marker protocol is simple, file is over-documented |

**Missing Context for Progress Tracking**:
- No unified "Progress Subsection Format" document exists
- progress-file.md (252 lines) covers JSON progress tracking
- handoff-artifact.md (198 lines) covers context exhaustion handoffs
- plan-format.md (273 lines) defines phase structure but NO Progress subsection

### 3. Progress Tracking Context Gap

The implementation plan (implementation-001.md) specifies adding Progress subsection to artifact-formats.md. However, there are THREE related progress tracking documents:

| Document | Purpose | Relation to Progress Subsection |
|----------|---------|--------------------------------|
| `progress-file.md` | JSON progress during phase | Per-session state, ephemeral |
| `handoff-artifact.md` | Context exhaustion handoffs | Single-point-in-time snapshot |
| `plan-format.md` | Phase structure in plans | MISSING Progress subsection |

**Gap**: progress-file.md and handoff-artifact.md serve intra-phase tracking. The Progress subsection (to be added) serves cumulative cross-session tracking. These are complementary, not redundant.

### 4. Context Loading Efficiency Issues

**Eager vs Lazy Loading**:

| Current Pattern | Better Pattern |
|-----------------|----------------|
| skill-implementer references 4 files | Only return-metadata-file.md is essential |
| general-impl-agent references 5 files | Only 2 needed for non-meta tasks |
| lean-impl-agent references lean-implementation-flow.md | CORRECT - lazy load after Stage 0 |

**Recommendation**: Use language-conditional loading:
```
If language == "meta":
  Load: return-metadata-file.md, CLAUDE.md, index.md
If language == "lean":
  Load: return-metadata-file.md, lean-implementation-flow.md
If language == "general":
  Load: return-metadata-file.md
```

### 5. artifact-formats.md vs plan-format.md Overlap

Both files document phase structures:

| Section | artifact-formats.md | plan-format.md |
|---------|---------------------|----------------|
| Phase Status Markers | Yes (basic) | Yes (detailed) |
| Phase Structure | No | Yes (comprehensive) |
| Phase Dependencies | No | Yes (new feature) |
| Sorry Characterization | No | Yes (Lean-only) |
| Progress Subsection | **TO BE ADDED** | **SHOULD ALSO ADD** |

**Issue**: The plan adds Progress subsection to artifact-formats.md but not plan-format.md. These should be kept in sync or consolidated.

### 6. Agent Definition Similarity

general-implementation-agent.md and lean-implementation-agent.md share ~60% structure:

| Section | Identical | Different |
|---------|-----------|-----------|
| Stage 0 (Early Metadata) | 95% | Session path differs |
| Stage 1 (Parse Context) | 100% | N/A |
| Context Management | 90% | Lean adds tool counts |
| Critical Requirements | 80% | Lean adds MCP rules |
| Return Format Examples | Structure identical | Content differs |

**Consolidation Opportunity**: Extract shared agent base patterns to a template or shared context file.

### 7. Recommendations for Implementation Plan Improvements

Based on this analysis, the implementation plan (implementation-001.md) should consider:

**Phase 1 (artifact-formats.md)**: Good as specified. Add Progress subsection.

**Phase 2 (lean-implementation-agent.md)**: Consider also:
- Remove duplicate return-metadata-file.md reference (skill already loads it)
- Add lean-implementation-flow.md reference for progress update stage

**Phase 3 (general-implementation-agent.md)**: Consider also:
- Remove duplicate return-metadata-file.md reference
- Add language-conditional context loading pattern

**Phase 4 (lean-implementation-flow.md)**: Good as specified. Add Stage 4E.

**Additional Phase (Optional)**: Update plan-format.md to include Progress subsection format. This ensures the plan format spec matches what agents actually write.

### 8. Context File Consolidation Opportunities

| Opportunity | Files Involved | Estimated Savings |
|-------------|----------------|-------------------|
| Merge summary-format.md into artifact-formats.md | 2 files | 60 lines |
| Remove file-metadata-exchange.md (unused) | 1 file | ~100 lines |
| Simplify postflight-control.md | 1 file | ~150 lines |
| Unify agent base patterns | 2 agents | ~200 lines (shared sections) |

**Total Potential Reduction**: ~510 lines across context files

### 9. Loading Precision Improvements

Current state: Agents reference context files with "Load on-demand" notes but don't specify WHEN.

Better pattern from lean-implementation-agent.md:
```markdown
**Always Load**:
- @.claude/context/core/formats/return-metadata-file.md

**Load After Stage 0**:
- @.claude/context/project/lean4/agents/lean-implementation-flow.md

**Load for Implementation**:
- @.claude/context/project/lean4/patterns/tactic-patterns.md (only if needed)
```

**Recommendation**: All agent definitions should use this tiered loading pattern.

## Recommendations for Task 883 Plan Revision

1. **Keep Phases 1-4 as specified** - They address the core Progress subsection gap

2. **Add reference to plan-format.md** - Phase 1 should update both artifact-formats.md AND plan-format.md to keep formats in sync

3. **Simplify context references** - Phase 2 and 3 can remove duplicate references that skill already loads

4. **Add Stage 4E to lean-implementation-flow.md** - Phase 4 is critical for making Progress subsection operational

5. **Future work (separate task)**: Context consolidation opportunities (510 lines) should be tracked as a separate task

## References

- implement.md: `.claude/commands/implement.md`
- skill-implementer: `.claude/skills/skill-implementer/SKILL.md`
- general-implementation-agent: `.claude/agents/general-implementation-agent.md`
- lean-implementation-agent: `.claude/agents/lean-implementation-agent.md`
- lean-implementation-flow: `.claude/context/project/lean4/agents/lean-implementation-flow.md`
- artifact-formats.md: `.claude/rules/artifact-formats.md`
- plan-format.md: `.claude/context/core/formats/plan-format.md`
- progress-file.md: `.claude/context/core/formats/progress-file.md`
- handoff-artifact.md: `.claude/context/core/formats/handoff-artifact.md`
- return-metadata-file.md: `.claude/context/core/formats/return-metadata-file.md`
- context index: `.claude/context/index.md`

## Next Steps

Review this analysis when executing `/implement 883`. The plan can be followed as-is, but consider:
1. Updating plan-format.md alongside artifact-formats.md in Phase 1
2. Removing redundant context references when updating agent definitions
3. Adding the tiered loading pattern to agent Context References sections
