# Research Report: Task #875

**Task**: lean_specific_teammate_prompts
**Date**: 2026-02-12
**Focus**: Evaluate whether task 875 is still needed given task 872's completion

## Executive Summary

Task 875 is **REDUNDANT** and should be **ABANDONED** in favor of task 872's already-completed work. Task 872 (language-aware teammate routing) was completed on 2026-02-11 and already implements comprehensive Lean-specific teammate prompts in `.claude/utils/team-wave-helpers.md`. These prompts are integrated directly into the three team skills (skill-team-research, skill-team-plan, skill-team-implement) and cover all required scenarios: research, implementation, debugging, and planning.

**Recommendation**: ABANDON task 875 and document that task 872 already fulfilled the requirements.

## Context & Scope

Task 875 was created to "create lean-specific teammate prompt templates that instruct teammates to use lean-lsp MCP tools (leansearch, loogle, leanfinder, lean_goal, etc.) and follow proof-checking workflows, stored in .claude/context/core/templates/."

However, task 872 (completed 2026-02-11) already delivered these exact artifacts with a superior implementation approach.

## Findings

### 1. Task 872 Completed with Lean Prompts Already Implemented

**Status**: COMPLETED - 2026-02-11
**Summary**: Added language-aware teammate routing to all three team skills with full Lean-specific prompts

Task 872's completion summary explicitly states:
- Added language-aware teammate routing to skill-team-research, skill-team-plan, skill-team-implement
- For Lean tasks, teammates are now spawned with **lean-lsp MCP tool instructions and blocked tool warnings**
- Includes verification requirements (lake build)
- Non-Lean tasks preserve existing generic prompts

### 2. Lean Prompts Already Centralized in team-wave-helpers.md

**Location**: `.claude/utils/team-wave-helpers.md` (lines 246-470)
**Content**: Four complete Lean teammate prompt templates:

1. **Lean Teammate Prompt Template (Research)** - lines 326-361
   - Includes all required MCP tools (leansearch, loogle, leanfinder, lean_local_search, lean_hover_info)
   - Lists blocked tools with explanations
   - Provides search decision tree
   - References context documentation (mcp-tools-guide.md, proof-debt-policy.md)

2. **Lean Teammate Prompt Template (Implementation)** - lines 363-409
   - Includes MOST IMPORTANT lean_goal usage guidance
   - Lists implementation tools (lean_goal, lean_multi_attempt, lean_state_search, etc.)
   - Blocked tool warnings
   - Workflow instructions (use lean_goal before/after tactics)
   - lake build verification

3. **Lean Teammate Prompt Template (Debugger)** - lines 411-441
   - Specialized debugging workflow
   - MCP tool subset for debugging
   - Blocked tools warning
   - Hypothesis generation approach

4. **Lean Teammate Prompt Template (Planning)** - lines 443-470
   - Proof-specific planning guidance
   - Phase milestone instruction
   - Context references
   - Verification requirements

### 3. Prompts Are Actively Used by Team Skills

**Integration Points**:
- `.claude/skills/skill-team-research/SKILL.md` - Lines 185-262: References and uses Lean prompts
- `.claude/skills/skill-team-implement/SKILL.md` - Lines 179-321: References and uses Lean prompts
- `.claude/skills/skill-team-plan/SKILL.md` - Lines 180-266: References and uses Lean prompts

Each skill includes:
- Stage 5a: Language Routing Decision (identifies language, routes to appropriate prompts)
- Full Lean teammate prompt templates integrated inline
- Fallback to generic prompts for non-Lean tasks

### 4. Proposed Storage Location (task 875) vs. Actual Storage (task 872)

**Task 875 Proposed**: `.claude/context/core/templates/lean-teammate-*.md` (separate files)
**Task 872 Actual**: `.claude/utils/team-wave-helpers.md` (centralized, reusable pattern file)

**Why 872's approach is superior**:
- **Single source of truth**: One file for all team coordination patterns
- **Copy-and-adapt design**: Explicitly states "Copy and adapt these patterns rather than importing directly" - prevents brittleness from file moves
- **Co-located with wave patterns**: Research wave, planning wave, and team prompts all in same file
- **Easier maintenance**: Update once, all skills benefit
- **Better discoverability**: All team patterns in one searchable location

### 5. Completeness Assessment

Task 875 description asks for Lean prompts with:
- ✅ lean-lsp MCP tools (leansearch, loogle, leanfinder, lean_goal) - INCLUDED in team-wave-helpers.md
- ✅ proof-checking workflows - INCLUDED with lean_goal guidance, verification requirements
- ✅ Storage in .claude/context/core/templates/ - STORED in .claude/utils/ instead (better location)

**Conclusion**: All requirements are already met, with implementation in a better location.

### 6. No Gaps or Unmet Needs

Cross-checked against task 872's implementation:
- Language routing in team skills - ✅ IMPLEMENTED (Stage 5a in all 3 skills)
- Lean research prompts - ✅ INCLUDED (team-wave-helpers.md lines 326-361)
- Lean implementation prompts - ✅ INCLUDED (team-wave-helpers.md lines 363-409)
- Lean debugging prompts - ✅ INCLUDED (team-wave-helpers.md lines 411-441)
- Lean planning prompts - ✅ INCLUDED (team-wave-helpers.md lines 443-470)
- Blocked tool warnings - ✅ INCLUDED throughout
- MCP tool lists - ✅ INCLUDED with explanations
- Context references - ✅ INCLUDED (tactic-patterns.md, proof-debt-policy.md)
- Verification requirements - ✅ INCLUDED (lake build)

No additional prompts or templates are needed beyond what task 872 delivered.

## Recommendations

### Primary Recommendation: ABANDON Task 875

**Justification**:
1. Task 872 already completed the exact work task 875 proposes
2. No gaps or unmet needs identified
3. Task 872's implementation location (team-wave-helpers.md) is superior to proposed location
4. Creating separate template files would duplicate the centralized team coordination patterns
5. All three team skills are already updated to route Lean tasks to these prompts

**Action**: Mark task 875 as ABANDONED with note "Task 872 (language-aware-teammate-routing) already completed all requirements for Lean-specific teammate prompts. See team-wave-helpers.md#language-routing-pattern."

### Alternative (If Disagree with Abandonment)

If stakeholder decides task 875 should proceed despite 872's completion, consider:

1. **Refocus on Template Storage**: Instead of creating duplicate prompts, create `.claude/context/core/templates/lean-teammate-patterns.md` that references and extends team-wave-helpers.md patterns
2. **Add Specialization**: Create additional Lean-specific templates beyond what 872 provided (e.g., "Lean Proof Reviewer", "Lean Refactoring Specialist")
3. **Create Template Variations**: Different prompt styles (concise vs. detailed, aggressive vs. conservative tactics)
4. **Port to Templates Directory**: If .claude/utils/ is not desired location, copy patterns from team-wave-helpers.md to .claude/context/core/templates/ and update skill references

**But**: This would create maintenance burden and likely violate DRY principle.

## Dependencies

- **Task 872**: COMPLETED (provides all Lean prompts)
- **Task 873**: In PLANNING (model configuration for teammates)
- **Task 874**: Not started (documentation of --team flag)

Task 875 does not block any downstream work.

## Next Steps

1. **Confirm with user**: Is task 875 intended to be abandoned given 872's completion?
2. **If abandoning**: Update task 875 status to [ABANDONED]
3. **If proceeding**: Clarify specific additions beyond what 872 already provided
4. **Review task sequence**: Confirm task 873 and 874 have everything they need

## References

- Task 872 Completion Summary: `specs/872_language_aware_teammate_routing_team_skills/summaries/implementation-summary-20260211.md`
- Team Wave Helpers: `.claude/utils/team-wave-helpers.md`
- Team Skills:
  - `.claude/skills/skill-team-research/SKILL.md`
  - `.claude/skills/skill-team-plan/SKILL.md`
  - `.claude/skills/skill-team-implement/SKILL.md`

## Appendix: Lean Prompt Inventory from Task 872

```
.claude/utils/team-wave-helpers.md:
├── Language Routing Pattern (lines 246-324)
│   ├── Language Routing Lookup (254-323)
│   │   └── Lean configuration with tools, blocked tools, context refs
│   └── 4 Lean teammate prompt templates:
│
├── Lean Teammate Prompt (Research) - lines 326-361
│   ├── MCP tools listed (leansearch, loogle, leanfinder, lean_local_search, lean_hover_info)
│   ├── Blocked tools (lean_diagnostic_messages, lean_file_outline)
│   ├── Search decision tree
│   └── Context references
│
├── Lean Teammate Prompt (Implementation) - lines 363-409
│   ├── Workflow steps with lean_goal emphasis
│   ├── MCP tools (lean_goal MOST IMPORTANT, lean_multi_attempt, lean_state_search, etc.)
│   ├── Blocked tools
│   ├── Context references
│   └── lake build verification
│
├── Lean Teammate Prompt (Debugger) - lines 411-441
│   ├── MCP tools for debugging
│   ├── Blocked tools
│   └── Hypothesis generation approach
│
└── Lean Teammate Prompt (Planning) - lines 443-470
    ├── Proof milestone planning guidance
    ├── Context references (tactic-patterns.md, proof-debt-policy.md)
    └── lake build verification
```
