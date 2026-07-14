# Implementation Plan: Re-Add Derived Binary Temporal Operators (Task #296)

- **Task**: 296 - Re-add derived binary temporal operators with dedup fix
- **Status**: [NOT STARTED]
- **Effort**: 6.5 hours (7.5 with optional Phase 5)
- **Dependencies**: 295 (removal commit `8943e3356`, reverted here)
- **Research Inputs**: specs/296_re_add_derived_binary_operators_with_dedup_fix/reports/01_derived-binary-operators.md
- **Artifacts**: plans/01_derived-binary-operators-plan.md (this file)
- **Standards**: plan-format.md; status-markers.md; artifact-management.md; tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Task 295 removed the 6 derived binary temporal operators (`release`, `weak_until`, `trigger`,
`weak_since`, `strong_release`, `strong_trigger`) from the enumerator on the premise that their
canonical representations collapsed with primitives, contributing zero unique formulas. The
research report **refutes** this: direct measurement shows the operators contribute **690 new
canonical equivalence classes at c4 (+33%)** and **7,722 at c5 (+60.5%)**. The reported
"zero presence" was a **measurement artifact** — the fold layer (`Normalization.lean`) has no
`EnrichedFormula` constructors nor fold-recognition patterns for these operators, so a folded-tag
census was structurally guaranteed to return zero regardless of dataset content.

The correct fix (report Section 4, approach 5) requires **no dedup-machinery adjustment**. It has
two independent parts: (1) re-add the enumerator branches verbatim (reverse of commit
`8943e3356`), and (2) complete the *representation layer* so the operators are correctly tagged,
serialized, and measurable. Definition of done: all 13 derived operators appear with nonzero
presence in the unique pipeline output of a freshly-generated c4 dataset (Phase 4 acceptance
test).

### Research Integration

Key findings integrated:
- **Dedup does NOT need fixing** (report §10.1): re-add branches verbatim; all 4 task-description
  candidate approaches are rejected (report §4). The synthesized approach 5 is adopted.
- **Real gap is the fold/representation layer** (report §10.2): 4 missing `EnrichedFormula`
  constructors, 0/6 fold-recognition patterns, 4 missing unfold lemmas — all in
  `Normalization.lean`.
- **Measurement method must change** (report §10.3): prior presence checks were fold-tag based and
  structurally blind; use value-level pattern counting cross-checked with the now-correct tags.
- **Pipeline-count discrepancy** (report §6): the published June-8 c4 dataset (806 records) does
  not match a first-principles replica of the post-removal HEAD pipeline (2,076 classes); the most
  plausible cause is a checkpoint-reload/relabel path. Phase 1 must generate **fresh** (clear
  `.checkpoint`) and record stage-by-stage counts, and Phase 4 must confirm the live compiled
  pipeline behavior.
- **Parity gap** (report §2.2): `partitionCrossProduct` (:2064-2070) never had the binary-derived
  branches even before removal; Phase 1 adds them there too.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No ROADMAP.md consulted for this task (no roadmap_path / roadmap_flag in delegation context).

## Goals & Non-Goals

**Goals**:
- Re-add the 6 derived binary operator branches to all enumeration paths (`enumExactHelper`,
  `sampleOne`, `sampleOneRandom`, `randomSubFormula`, `partitionCrossProduct`).
- Complete the `Normalization.lean` representation layer: 4 `EnrichedFormula` constructors, fold
  recognition for all 6 binary operators, serialization cases, and 4 unfold lemmas.
- Replace fold-tag-only presence measurement with a value-level operator census.
- Prove (acceptance test) via a fresh c4 generator run that all 13 derived operators appear in the
  unique pipeline output.
- Zero proof debt: no sorries, no axioms (all changes are computational defs, exhaustive-match
  extensions, `rfl` lemmas, and `#eval` tests).

**Non-Goals**:
- Adjusting the dedup / canonicalization machinery (report proves this is unnecessary and wrong).
- Full c6/c7 dataset regeneration (c6 is a ~25min run; c7 is blocked by task 298's labeling bug).
  Optional/follow-up only.
- Resolving the `Formula.complexity` pattern ambiguity that yields complexity-5 records in c4
  (pre-existing, orthogonal; documented as a risk only).

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Fold pattern mis-ordering shadows existing tags (e.g. G vs `release(φ,⊥)`) | M | M | ⊥/⊤-guard folding happens in children first; add regression `#eval`s for `release(p,⊥)→all_future` and extend the existing 21-formula round-trip suite (report §8) |
| Ground-truth run reveals an additional suppression stage (report §6) | H | L | Phase 1 records stage-by-stage `[gen]`/`Deduplicated` counts before/after; if a suppressor exists it becomes the actual fix target and is surfaced immediately |
| c4 generator run is slow (triggers full C rebuild) | M | H | Phase 4 budgets for one run only; clear `.checkpoint` once, run once, capture logs; do not iterate on the live binary |
| `EnrichedFormula` exhaustiveness misses a serialization site | L | L | Compiler enforces exhaustive matches on `toJson`/`prettyPrint`/`toSExpr`/`toPrimitive` — build failure names every missed case |
| `complexity`-5 records in a "c4" dataset confuse validation | L | M | Pre-existing behavior, orthogonal to this task; documented, not fixed |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2 | -- |
| 2 | 3 | 1, 2 |
| 3 | 4 | 1, 2, 3 |
| 4 | 5 | 4 |

Phases within the same wave can execute in parallel. Phases 1 and 2 touch disjoint files
(`FormulaEnumerator.lean` vs `Normalization.lean`) and are independent. Phase 5 is optional
(see phase note).

### Phase 1: Re-add enumerator branches + fresh ground-truth baseline [COMPLETED]

**Goal**: All 6 derived binary operators are enumerable again on every enumeration path, verified
by `#eval` membership assertions, with a fresh stage-by-stage count baseline recorded.

**Tasks**:
- [ ] Re-apply the `enumExactHelper` hunk of commit `8943e3356` in reverse: 6 cross-product
  builders after `snces` (FormulaEnumerator.lean:~295), concatenated into a `temporalBinaries`
  array, following the exact pre-removal cross-product shape (`tLefts × tRights` at
  `temporalBudget - 1`).
- [ ] Re-add the corresponding branches in `sampleOne` (binary-derived slot), `sampleOneRandom`
  (branch 11), and `randomSubFormula` (branch 9).
- [ ] Add the 6 branches to `partitionCrossProduct` (:2064-2070) — the parallel path never had
  them (pre-existing parity gap vs the sequential path).
- [ ] Extend the existing `#eval` membership checks (~:1980-2000) with `release(p,q)` and
  `weak_until(p,q)` membership assertions at the appropriate level.
- [ ] Run a fresh c4 baseline via the real binary with `--valid-seed-count 0`, **clearing any
  `.checkpoint`** first; capture `[gen]`/`Deduplicated`/labeled counts before and after the
  re-add. Expected delta: raw +~2,400, final +~690 canonical at c4. If the observed delta
  diverges materially, surface it (possible hidden suppressor per report §6) before proceeding.
  *(deviation: deferred — the live-binary baseline run triggers the same ~264MB C rebuild as P4;
  per orchestrator directive "code now, defer heavy regen" it is deferred to P4. Enumeration-level
  delta captured instead via `#eval`: `enumExactHelper` c4 count = 7852, c5 = 75914, up from the
  post-removal baseline; `#guard` membership for `release(p,q)`/`weak_until(p,q)` at c3 passes.)*

**Timing**: 2 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Automation/FormulaEnumerator.lean` - re-add 6 branches across
  `enumExactHelper`, `sampleOne`, `sampleOneRandom`, `randomSubFormula`, `partitionCrossProduct`;
  extend `#eval` assertions.

**Verification**:
- `lake build` green.
- `#eval` membership assertions for `release`/`weak_until` return `true`.
- Baseline count log captured showing the +~690 c4 canonical delta (or a flagged divergence).
- Zero sorries (all changes computational).

---

### Phase 2: Representation-layer completion (Normalization.lean) [NOT STARTED]

**Goal**: The fold/enrichment layer recognizes, tags, serializes, and round-trips all 6 derived
binary operators, so folded-tag presence becomes real and measurable.

**Tasks**:
- [ ] Add 4 `EnrichedFormula` constructors: `release`, `weak_until`, `trigger`, `weak_since`
  (`strong_release`/`strong_trigger` constructors already exist).
- [ ] Extend `toPrimitive`, `recognizeComposites` recursion, `toJson`, `prettyPrint`, `toSExpr`
  (4 cases each; compiler enforces exhaustiveness).
- [ ] Add fold recognition:
  - `foldImp`: `| .untl (.neg φ) (.neg ψ), .bot => .release φ ψ` and the snce-dual for `trigger`.
    Verify the ⊥-guard ordering routes `release(φ,⊥)` to `all_future` via the earlier
    `.some_future (.neg φ), .bot` case (do not shadow existing G/H tags).
  - `foldFormula` untl/snce nodes: `| .and_ a b, g` with `a == g` → `strong_release b g`, plus the
    snce-dual for `strong_trigger`.
  - `recognizeComposites` or_ node: `.or_ (.untl φ ψ) (.all_future ψ')` with `ψ == ψ'` →
    `weak_until φ ψ`, plus the snce/all_past-dual for `weak_since`.
- [ ] Add 4 `@[simp]` `rfl` unfold lemmas (`release_unfold`, `weak_until_unfold`, `trigger_unfold`,
  `weak_since_unfold`); extend the `modal_norm`/`modal_fold` macro lists (:157-162, :192, :202).
- [ ] Extend the existing round-trip `#eval` suite (currently 21 formulas) with representative
  instances of all 6 operators, asserting `toPrimitive ∘ foldFormulaFull = id` and the
  `release(p,⊥) → all_future` regression.

**Timing**: 2 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Automation/Normalization.lean` - 4 constructors, fold/serialization/unfold
  additions, extended `#eval` round-trip suite.

**Verification**:
- `lake build` green (exhaustive-match extensions compile).
- Round-trip `#eval`s pass for all 6 operators.
- `release(p,q)` now folds to a `release` tag (not `neg (untl …)`); `strong_release(p,q)` folds to
  a `strong_release` tag; regression `#eval` confirms `release(p,⊥)` still folds to `all_future`.
- Zero sorries; `normalizeFormula_id` unaffected (matches only the 6 primitive constructors).

---

### Phase 3: Measurement-protocol fix (value-level census) [NOT STARTED]

**Goal**: A value-level operator census exists and cross-checks the now-correct fold tags, so
presence is measured on the formula value, not fold tags alone.

**Tasks**:
- [ ] Add a value-level operator census utility using primitive-pattern matchers (precedent:
  `FormulaMutator.lean:320`, which already matches trigger/strong_trigger primitive patterns),
  covering all 13 derived operators.
- [ ] Cross-check the value-level census against the folded-tag census (now correct after Phase 2)
  on a small sample; assert agreement via `#eval`.

**Timing**: 1 hour

**Depends on**: 1, 2

**Files to modify**:
- `Theories/Bimodal/Automation/` - census utility (new helper alongside enumerator/normalization;
  implementer selects the precise host file — `FormulaEnumerator.lean` or a small new module).

**Verification**:
- `lake build` green.
- `#eval` census agrees with folded-tag census on the sample (both nonzero for the 6 binary ops).
- Zero sorries.

---

### Phase 4: Fresh c4 generation + acceptance test (all 13 operators present) [NOT STARTED]

**Goal**: A freshly-generated c4 dataset demonstrably contains all 13 derived operators with
nonzero presence in the unique pipeline output — the deferred research acceptance test.

**Tasks**:
- [ ] Delete/bypass any `.checkpoint` next to the c4 output so Step 1b takes the fresh-enumeration
  path (not a checkpoint relabel — report §6). Add/inspect a log assertion confirming the
  fresh-enumeration path was taken.
- [ ] Run `lake exe dataset_generator -- --max-complexity 4 --output data/bmlogic-c4.jsonl`
  **once**. NOTE: this triggers a full C rebuild and is slow; budget for a single run and do not
  iterate on the live binary. Capture the full stage log (`[gen]`, `Deduplicated`, labeled
  counts).
- [ ] Run the Phase 3 value-level census (and the folded-tag census as a cross-check) over the
  generated JSONL; confirm **all 13 derived operators** have nonzero presence.
- [ ] Record the surviving-formula counts and confirm the +~690-class c4 delta materialized in the
  live pipeline (reconciling the report §6 discrepancy against real output).

**Timing**: 1 hour (mostly the single generator/rebuild run)

**Depends on**: 1, 2, 3

**Files to modify**:
- `data/bmlogic-c4.jsonl` - regenerated fresh (output artifact, not source).

**Verification**:
- Generator run completes; fresh-enumeration path confirmed in logs.
- Census over the JSONL shows nonzero presence for all 13 derived operators (the 6 binary ops are
  the critical new additions).
- If any of the 13 is still absent (candidate: `always`/`sometimes`, gated by `passesFilter ≥ 3`),
  record which and proceed to optional Phase 5.

---

### Phase 5 (optional): always/sometimes complexity gate [NOT STARTED]

**Goal**: If Phase 4 finds `always`/`sometimes` absent, complete the "all 13" goal by addressing
the `passesFilter` complexity-2 exclusion.

**Note**: Execute ONLY if Phase 4 finds `always(p)`/`sometimes(p)` (pattern complexity 2) missing.
The 6 binary operators are unaffected by `passesFilter` (they score 3-4). This phase closes the
295-P2 gap for the two complexity-2 unary derived operators.

**Tasks**:
- [ ] Re-measure `always`/`sometimes` presence with the Phase 3 fixed census (the 295 claim that
  higher-complexity `always` formulas "get deduplicated" carries the same measurement-artifact
  suspicion — confirm before acting).
- [ ] If genuinely excluded: lower the `passesFilter` gate to 2 for formulas matching
  always/sometimes patterns (pattern-aware, not a blanket `≥ 2`), or document that representation
  is accepted only at complexity ≥ 3 arguments.
- [ ] Re-run the census on a fresh c4 slice to confirm presence.

**Timing**: 1 hour

**Depends on**: 4

**Files to modify**:
- `Theories/Bimodal/Automation/FormulaEnumerator.lean` - `passesFilter` (:721) gate adjustment
  (only if warranted).

**Verification**:
- `lake build` green.
- `always`/`sometimes` present in the census (or a documented decision that they remain gated).
- Zero sorries.

---

## Testing & Validation

- [ ] `lake build` green after each phase (lean4 phase-sizing: every phase ends at a green build).
- [ ] `#eval` membership assertions for `release`/`weak_until` in the enumerator (Phase 1).
- [ ] Round-trip `#eval` suite passes for all 6 binary operators; `release(p,⊥)→all_future`
  regression holds (Phase 2).
- [ ] Value-level census agrees with folded-tag census on a sample (Phase 3).
- [ ] Fresh c4 generation shows all 13 derived operators with nonzero presence (Phase 4 acceptance
  test).
- [ ] Zero sorries and zero axioms across all phases.

## Artifacts & Outputs

- `Theories/Bimodal/Automation/FormulaEnumerator.lean` (modified — enumerator branches, census,
  optional gate).
- `Theories/Bimodal/Automation/Normalization.lean` (modified — representation layer).
- `data/bmlogic-c4.jsonl` (regenerated fresh — validation output).
- `specs/296_re_add_derived_binary_operators_with_dedup_fix/summaries/01_derived-binary-operators-summary.md`
  (implementation summary, written at completion).

## Rollback/Contingency

- All source changes are additive (re-added branches, new constructors/lemmas). If a build breaks,
  fix forward per `.claude/context/contracts/recovery.md`; do not discard uncommitted work.
- If Phase 4's fresh generation reveals a hidden suppression stage (report §6 residual risk),
  stop and treat that stage as the real fix target rather than forcing the operators through —
  surface it in the implementation summary and, if out of scope, spawn a follow-up task.
- The June-8 `data/bmlogic-c4.jsonl` is already stale relative to HEAD independent of this task;
  regenerating it is a net improvement, but the prior file is recoverable via git if needed.
- To fully revert: re-apply commit `8943e3356` (removes the branches again) and revert the
  `Normalization.lean` additions.
