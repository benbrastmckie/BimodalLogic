# Code Review Report

**Date**: 2026-07-26
**Scope**: Refactor/rename/cleanup readiness before further substantive work
**Reviewed by**: Claude

## Summary

- Live `.lean` files reviewed: 288 (185,825 lines, excluding Boneyard/)
- Critical issues: 1
- High priority issues: 4
- Medium priority issues: 4
- Low priority issues: 3

**Headline**: the cleanup program is gated on a single unblocked task. Task 341's completion
(this session) released **131 refactor_module_organization**, which is the sole remaining
predecessor of **402 systematic_mathlib_naming_upgrade**, which in turn gates 193, 180, 177,
and 178. Nothing else in the cleanup cluster can start until 131 lands. The correct next
action is 131, and it is ready now.

## Critical Issues

### Cleanup cluster is a strict serial chain with one open gate
**File**: `specs/state.json` (dependency graph)
**Description**: The five remaining cleanup tasks form a linear chain, not a parallelizable
set:

```
341 [COMPLETED] ──> 131 ──> 402 ──> 193 ──> 177
                                 └─> 180      └─> 178
```

Measured dependency edges: `131 deps=[341]` (satisfied), `402 deps=[341,131,394]` (341 and 394
satisfied; 131 open), `193 deps=[402]`, `180 deps=[292,402]` (292 satisfied), `177 deps=[131,193,402]`,
`178 deps=[131,193,402]`.

**Impact**: There is no way to shorten this by running tasks concurrently — every edge is a
genuine ordering constraint, and both 131 and 402 state the reason explicitly (renaming 24,000+
reference sites across a directory structure that is about to change would churn the rewrite
twice). Attempting 402 before 131 is the specific failure both charters were written to prevent.
**Recommended fix**: Run 131 next, alone. It is unblocked as of this session.

## High Priority Issues

### 402 is the single largest and highest-risk work item in the repository
**File**: `Theories/Bimodal/` (whole tree), `docs/development/NAMING_CONVENTION_DEVIATION.md`
**Description**: Task 402 combines three renames (Part A directory/namespace `Bimodal ->
FormalSystem`, Part B snake_case -> lowerCamelCase, Part C semantic renaming) over one reference
graph. Measured from resolved `.ilean` references: 24,364 usages across 258 of 300 modules (86%
of the project); 398 of 873 names (45.6%) are proper prefixes of another project identifier; a
naive substring pass would touch 68,076 sites of which 46.4% would be wrong.
**Impact**: Identifier-prefix collision is the norm here, not an edge case. Position-anchored
replacement driven by resolved references is mandatory; global substring replace is disqualified.
**Recommended fix**: Do not plan 402 until 131 has fixed the directory layout. When planning,
treat the `.ilean`-resolved reference set as the only acceptable input.

### 131's own charter goal (6) overlaps 402 Part A and must be decided in 131
**File**: `Theories/Bimodal/`
**Description**: `Theories/Bimodal/` currently holds three non-Lean directories — `docs/`,
`latex/`, `typst/` — alongside nine Lean directories. 131 goal (6) asks whether these move to
the project root; 402 Part A renames the source root itself.
**Impact**: If 131 defers the docs/latex/typst decision, 402 inherits an ambiguous move and the
directory rename churns twice — the exact double-rewrite both charters exist to prevent.
**Recommended fix**: Force the placement decision inside 131, as its charter already directs
("decide the docs/latex/typst placement HERE and leave the source-root rename to that task").

### Automation/ macros are built but not yet systematically applied — adoption undetermined
**File**: `Theories/Bimodal/Automation/` (21,576 lines)
**Description**: All 10 tactic macros defined in `Automation/` currently have zero call sites
outside `Automation/` itself. Measured total references (including the definition line):

| Macro | Total refs | Current use |
|-------|-----------|-------------|
| `order_rev` | 1 | definition only — no call sites yet |
| `modal_norm_all` | 2 | 1 use, internal |
| `modal_op_norm`, `prop_norm`, `same_order_type_grid_uh` | 3 | internal only |
| `game_tuple_unfold`, `temporal_norm` | 4 | internal only |
| `same_order_type_grid` | 5 | internal only |
| `modal_fold` | 8 | internal only |
| `modal_norm` | 26 | internal only |

**This is an unadopted-inventory finding, not a dead-code finding.** These macros were written
but never systematically rolled out across the proof corpus, so low reference counts measure
*absence of an adoption pass*, not absence of value. Nothing here should be deleted on the
strength of a reference count alone.

The distinction matters because task **193 is re-scoped to exactly this adoption pass** — a
soundness-layer macro application pass. Its purpose is to determine, by attempting application,
which of these macros actually earn their place. Treating them as dead beforehand would
pre-empt the very evaluation 193 exists to perform.

The abandonment of 186, 192, and 199 does **not** generalize to these macros. Those three were
abandoned for specific, individually-established reasons — 199's target goals were dissolved by
an unrelated proof restructuring and its blocking helper lemma was mathematically false; 186 and
192 had never had their scope written down. None of that is evidence about `modal_norm` or
`prop_norm`.

**Impact**: Real but unquantified. Until 193 runs, the value of a 21,576-line `Automation/` layer
is genuinely unknown in both directions — it may be latent leverage or it may be scaffolding.
**Recommended fix**: Let 193 make this determination empirically. Its output should be a
per-macro verdict (adopt and roll out / keep for `Automation/`-internal use / retire), with
retirement justified by a failed application attempt rather than by a grep count. `order_rev`
having zero call sites makes it the cheapest first probe, not the first deletion.

### `nolints.json` carries 860 suppressions that are a checkpoint, not an asset
**File**: `scripts/nolints.json`
**Description**: 860 `defsWithUnderscore` findings are currently suppressed. 402's charter is
explicit that these rows "are expected to be DELETED as this migration lands, not maintained."
**Impact**: Until 402 runs, the linter reports clean while 860 genuine deviations persist. Any
review that trusts the linter output alone will misread naming compliance as solved.
**Recommended fix**: Treat `nolints.json` line count as the naming-debt metric until 402 lands.

## Medium Priority Issues

### Three `[EXPANDED]` tasks sit permanently in the active list
**File**: `specs/state.json`
**Description**: Tasks 161, 175, and 321 have status `expanded`, which CLAUDE.md lists as a
terminal state — but `/todo` archives only `completed` and `abandoned`, so these never leave.
**Impact**: The active list overstates outstanding work by three tasks. 175's content was
already absorbed into 402 Part C, and 161's into 402 Part A, so both are genuinely finished.
**Recommended fix**: Either extend `/todo`'s archival filter to include `expanded`, or convert
these three to `abandoned` with a completion note pointing at their absorbing task.

### One task carries a malformed status value
**File**: `specs/state.json`
**Description**: Task 378 has status `"not started"` (space) where every other task uses
`"not_started"` (underscore). Status distribution: 20 `not_started`, 1 `not started`, 4 `partial`,
3 `expanded`, 2 `researched`, 1 `blocked`.
**Impact**: Any consumer matching on the exact string `not_started` will silently skip task 378.
The `/orchestrate` state machine handles both spellings, but scripts filtering state.json may not.
**Recommended fix**: Normalize 378 to `not_started`.

### ROADMAP.md is structurally invisible to its own tooling
**File**: `specs/ROADMAP.md` (1,617 lines)
**Description**: `roadmap-integration.sh` parses **0 phases** and finds **0 checkboxes** (neither
`- [ ]` nor `- [x]`) in the entire file. The document is organized as prose sections with status
tables (`## BX Axiom System`, `### Layer 1: Propositional (4)`, …) rather than the phase +
checkbox format the parser and `/todo`'s annotation step both expect.
**Impact**: Roadmap annotation is a permanent no-op. This session's `/todo` run archived 21 tasks
and annotated zero roadmap items; this review's integration pass made zero annotations (1 match
skipped, `line_not_found_exact`). The producer/consumer contract described in CLAUDE.md
(`/implement` populates `completion_summary` + `roadmap_items`; `/todo` consumes them) is not
running end to end — no archived task carried a `roadmap_items` field either.
**Recommended fix**: Decide deliberately whether ROADMAP.md is a hand-maintained narrative
document (in which case remove the automated annotation steps that silently do nothing) or a
tool-maintained checklist (in which case convert it to the expected format). The current state
is the worst of both: tooling that reports success while doing nothing.

### Boneyard is 32% of the tree by line count
**File**: `Theories/Bimodal/Boneyard/` (92 files, 58,476 lines, 160 `sorry` tactics)
**Description**: Boneyard is not imported from the live tree and does not build — verified: no
`import` of any Boneyard module exists outside Boneyard itself.
**Impact**: Low correctness risk (it cannot affect the build), but it is 58,476 lines that every
grep, survey, and rename pass must be explicitly filtered against. Several stale charters in this
repository have already mis-measured the codebase by failing to exclude it.
**Recommended fix**: 131 goal (5) already covers auditing Boneyard organization. Keep it in
scope there; do not spawn a separate task.

## Low Priority Issues

### Next size tier after the SharedWitness split
**File**: `Theories/Bimodal/Metalogic/WeakCanonical/`
**Description**: Task 341 split the largest file (SharedWitness, 13,386 lines) into ten modules.
The largest remaining files are now `EFGames/GapDetection.lean` (5,090) and
`Expressiveness/SplitPoint.lean` (4,906) — neither was in 341's scope. Current distribution:
13 files over 2,000 lines, 44 between 1,000 and 2,000, 68 between 500 and 1,000, 163 under 500.
**Impact**: Task 180 (`line_limit_compliance_and_publication_residue`) is the natural owner, and
it is blocked behind 402.
**Recommended fix**: No action now. Record GapDetection and SplitPoint as 180's first two targets.

### `Bridge.lean` rename is decided but unscheduled
**File**: `Theories/Bimodal/.../Bridge.lean`
**Description**: 402 Part C's research established that `Bridge.lean` holds 25–34 substantive
definitions and must not be deleted wholesale; only 3–4 trivial wrappers inline. A rename to
something descriptive (e.g. `MonotonicityDuality.lean`) was flagged as "worth considering."
**Recommended fix**: Resolve during 402 planning; no separate task.

### Review-state statistics undercount
**File**: `specs/reviews/state.json`
**Description**: 12 prior reviews recorded, 91 total issues, 21 tasks created.
**Recommended fix**: None; informational.

## Code Quality Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Live `.lean` files | 288 | Info |
| Live lines (excl. Boneyard) | 185,825 | Info |
| Live `sorry` tactics | **1** (`Metalogic/WeakCanonical/Transfer.lean`) | OK |
| Boneyard `sorry` tactics | 160 (not built) | Info |
| `axiom` declarations outside Boneyard | 0 | OK |
| `lake build` | green, 1884 jobs | Pass |
| TODO markers | 1 | OK |
| FIXME markers | 0 | OK |
| `nolints.json` suppressions | 860 | Warning |
| Files > 2,000 lines | 13 | Warning |

**Note on the sorry count**: a naive grep reports 234 matches in the live tree. After stripping
Lean line- and block-comments, the true count is **1**. The inflated figure is prose discussion
of sorries in docstrings and comments. Both task 131's charter and the automation survey state
1; that figure is correct and was independently re-verified here.

## Roadmap Progress

Roadmap integration ran successfully (exit 0) but produced **0 annotations** — see the
ROADMAP.md structural issue above. No Current Focus table can be built because 0 phases parsed.

## Recommendations

1. **Run 131 next, alone.** It is the sole gate on the entire cleanup program and is unblocked
   as of this session. Force its goal (6) docs/latex/typst placement decision rather than
   deferring it into 402.
2. **Then 402, planned from resolved `.ilean` references only.** It is the largest and
   highest-risk item in the repository (24,364 usages, 45.6% prefix overlap). Its Part C research
   already exists and must be read, not re-derived.
3. **Let 193 settle the Automation/ question empirically** rather than spawning a cleanup task.
   The 10 macros are unadopted, not established as dead — 193's re-scope *is* the adoption pass
   that determines their value. Ask it for a per-macro verdict backed by attempted application,
   not by reference counts.
4. **Resolve the ROADMAP.md tooling mismatch as a deliberate decision** — either convert the
   format or remove the no-op annotation steps. Silent-success tooling is the actual defect.
5. **Normalize task 378's status string and dispose of the three `[EXPANDED]` tasks** — small,
   mechanical, and they are distorting the active task list.

## Gaps Remaining After Cleanup

Cleanup does not touch these; they are the substantive work waiting behind it:

| Area | Tasks | Gate |
|------|-------|------|
| Dedekind completeness | 390, 391 | 390 unblocked now (389 landed) |
| Kamp/Rabinovich transcription | 377 (partial), 378 | 378 unblocked now (341 landed) |
| Strong completeness | 361, 362, 169, 170 | 361 unblocked |
| Dataset enhancement | 282, 296, 298 (all partial), 231, 219, 257 (blocked) | 257 externally blocked |
| Completeness audit | 95, 165 | unblocked |

Three dataset tasks (282, 296, 298) are `[PARTIAL]` and one (257) is `[BLOCKED]` on external
storage — that cluster is the least healthy area outside the cleanup chain and is not addressed
by any current cleanup task.
