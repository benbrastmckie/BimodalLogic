# Handoff Artifact Schema

## Overview

Handoff artifacts enable graceful context exhaustion recovery by providing minimal, structured context for successor teammates. When a teammate approaches context limits, they write a handoff document that the lead agent uses to spawn a successor.

**Design Principle**: Plan FOR context exhaustion, not against it. Handoffs are expected events, not failures.

## File Location

```
specs/{N}_{SLUG}/handoffs/phase-{P}-handoff-{TIMESTAMP}.md
```

Where:
- `{N}` = Task number (unpadded)
- `{SLUG}` = Task slug in snake_case
- `{P}` = Phase number (unpadded)
- `{TIMESTAMP}` = ISO8601 timestamp (e.g., `20260212T143022Z`)

Example: `specs/259_prove_completeness/handoffs/phase-3-handoff-20260212T143022Z.md`

## Directory Structure

```
specs/{N}_{SLUG}/
├── reports/          # Research reports
├── plans/            # Implementation plans
├── summaries/        # Implementation summaries
├── progress/         # Progress tracking files
└── handoffs/         # Handoff artifacts (NEW)
    ├── phase-2-handoff-20260212T100000Z.md
    ├── phase-2-handoff-20260212T120000Z.md  # Second handoff in same phase
    └── phase-3-handoff-20260212T140000Z.md
```

## Handoff Document Template

The handoff document must be **one screen maximum** (~40 lines). It uses progressive disclosure - successor reads only what they need.

```markdown
# Phase {P} Handoff - {timestamp}

## Immediate Next Action
{Single specific step - not a list. Be concrete about what to do next.}

## Current State
- **File**: {absolute path to file being worked on}
- **Location**: Line {N}, after {tactic/statement/function name}
- **Goal state**: {current proof goal, expected output, or work state}

## Key Decisions Made
1. {Decision}: {Brief rationale (one sentence)}
2. {Decision}: {Brief rationale}

## What NOT to Try
1. {Approach}: {Why it failed (one sentence)}
2. {Approach}: {Why it failed}

## Critical Context (max 5 items)
- {Essential fact 1}
- {Essential fact 2}
- {Essential fact 3}

## References (read only if stuck)
- Plan: {path}, Phase {P}
- Research: {path}, Section {X}
- Related file: {path}
```

### Section Guidelines

**Immediate Next Action**:
- Must be a single, specific step
- Should be actionable without reading anything else
- Example: "Apply `simp [List.map_cons]` to close the `map (a :: as)` case"
- NOT: "Continue working on the proof" (too vague)

**Current State**:
- Precise location in the codebase
- For Lean: Include the exact goal state from `lean_goal`
- For code: Include relevant function/class being modified

**Key Decisions Made**:
- Only decisions that affect the successor's approach
- Include rationale to prevent re-evaluation
- Max 3-4 decisions

**What NOT to Try**:
- Approaches that were attempted and failed
- Include brief reason to prevent retries
- Max 3-4 items

**Critical Context**:
- Facts the successor needs but might not discover
- Lemma names, type constraints, edge cases
- Max 5 items

**References**:
- Paths to documents for deeper context
- Successor reads these ONLY if stuck
- Keep to 2-3 references maximum

## Handoff Artifact Type

Add `handoff` as a valid artifact type in metadata:

```json
{
  "artifacts": [
    {
      "type": "handoff",
      "path": "specs/259_prove_completeness/handoffs/phase-3-handoff-20260212T143022Z.md",
      "summary": "Context exhaustion handoff for phase 3 with goal state and approach constraints"
    }
  ]
}
```

## Integration with partial_progress

When writing a handoff, the metadata file includes `handoff_path` in `partial_progress`:

```json
{
  "status": "partial",
  "partial_progress": {
    "stage": "context_exhaustion_handoff",
    "details": "Approaching context limit. Handoff written with current proof state.",
    "handoff_path": "specs/259_prove_completeness/handoffs/phase-3-handoff-20260212T143022Z.md",
    "phases_completed": 2,
    "phases_total": 4
  }
}
```

## Handoff Triggers

Teammates should write handoffs when:
1. Context estimate reaches ~80% (based on tool call volume and file reads)
2. About to attempt an operation that might push over the limit
3. Completing any objective (natural boundary for clean handoff)
4. Finding themselves re-reading the same context repeatedly (signal of pressure)

## Successor Pattern

Successors read the handoff document, NOT full history. The lead spawns successors with minimal context:

1. **Quick Start**: Immediate Next Action + Current State (read first)
2. **If Stuck**: Key Decisions + What NOT to Try
3. **Escape Hatch**: References section (read only if truly stuck)

See `.claude/utils/team-wave-helpers.md` for the Successor Teammate section.

## Example: Lean Proof Handoff

```markdown
# Phase 3 Handoff - 20260212T143022Z

## Immediate Next Action
Apply `rcases` on `h_ih` to extract the induction hypothesis, then use `exact` with `ih_coherent`.

## Current State
- **File**: /home/user/Projects/ProofChecker/Theories/Bimodal/Lindenbaum.lean
- **Location**: Line 342, inside `theorem lindenbaum_extension`
- **Goal state**:
  ```
  case step
  step_hyp : GHExtensionStep ...
  h_ih : GHCoherent prev_F prev_P ...
  ⊢ GHCoherent (insert_F step_hyp.new_formula prev_F) prev_P
  ```

## Key Decisions Made
1. Use GHCoherentPartialFamily approach: Easier to maintain coherence than direct MCS construction
2. Forward_F before Backward_P: Process F-extensions first to simplify P-consistency checks

## What NOT to Try
1. `simp` alone: Insufficient for structural coherence goals - need explicit rcases
2. Direct induction on formula structure: Goal is about state, not formula

## Critical Context (max 5 items)
- `GHCoherent` requires both `F_consistent` and `P_complete` subgoals
- `insert_F` is defined in line 156
- The IH provides coherence for `prev_F`, need to extend to `insert_F ... prev_F`

## References (read only if stuck)
- Plan: specs/870_zorn/plans/implementation-001.md, Phase 3
- Research: specs/870_zorn/reports/research-002.md, Section "GH Coherence"
```

## Related Documentation

- `.claude/context/core/formats/return-metadata-file.md` - Metadata schema (includes handoff_path)
- `.claude/context/core/formats/progress-file.md` - Progress tracking
- `.claude/utils/team-wave-helpers.md` - Successor teammate patterns
- `.claude/rules/error-handling.md` - Context exhaustion recovery
