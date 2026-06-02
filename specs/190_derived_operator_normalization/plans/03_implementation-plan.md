# Implementation Plan: Task #190 - Derived Operator Normalization (Fold Direction)

- **Task**: 190 - Derived operator normalization (fold direction)
- **Status**: [NOT STARTED]
- **Effort**: 6 hours
- **Dependencies**: None
- **Research Inputs**: reports/01_normalization-seed.md, reports/02_modal-norm-research.md
- **Artifacts**: plans/03_implementation-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Implement the fold direction for derived operator normalization: a greedy pattern-matching algorithm that reconstitutes defined operators (neg, top, and, or, diamond, etc.) from their primitive expansions (atom, bot, imp, box, untl, snce). The unfold direction (defined-to-primitives) is already designed in the research reports via `_unfold` simp lemmas. This plan covers: (1) the core unfold lemmas and `modal_norm` tactic, (2) a computable `Formula.foldFormula` function producing an `EnrichedFormula` ADT with enriched operator tags, (3) conservative ambiguity handling with explicit documentation, (4) JSON/string serialization for the enriched representation, (5) fold-direction simp lemmas for unambiguous patterns, and (6) the round-trip property test `unfold(fold(f)) = f`.

### Research Integration

From report 02 (modal-norm-research):
- All 15 derived operators are `def` abbreviations, so unfold lemmas are trivially `rfl`.
- The operator dependency graph has 7 levels (Level 0 primitives through Level 6 sometimes).
- Term size blowup for full normalization: `always` ~15x, `sometimes` ~20x. Selective normalization is essential.
- The plain macro approach is recommended for `modal_norm` (zero infrastructure, no `registerSimpAttr`).
- Folding is non-deterministic for ambiguous patterns. The research identifies `imp(imp(A, bot), B)` as matching both `or(A, B)` and `imp(neg(A), B)`.
- 350 existing call sites across 26 files manually enumerate operator unfolding via `simp only [Formula.neg, ...]`.

From report 01 (normalization-seed):
- The existing `@[aesop norm unfold]` rules in AesopRules.lean are DEPRECATED and cover only 4 operators.
- `Formula.toJson` currently exports only primitive constructors (6 tags).
- BimodalHarness needs enriched representations alongside primitives for training data.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No specific ROADMAP.md items for normalization/fold tactic work.

## Goals & Non-Goals

**Goals**:
- Implement unfold-direction simp lemmas and `modal_norm` tactic (primitives from derived operators)
- Implement `Formula.foldFormula` computable function (primitives to enriched `EnrichedFormula`)
- Handle ambiguous patterns conservatively (only fold unambiguous patterns)
- Document all ambiguous patterns explicitly with rationale
- Provide `EnrichedFormula.toJson` for training data export
- Add fold-direction simp lemmas (`_fold`) where unambiguous
- Verify round-trip property: for any formula `f` constructed using derived operators, `unfold(fold(f)) = f`

**Non-Goals**:
- Replacing all 350 existing `simp only [Formula.neg, ...]` call sites (deferred to task 193)
- Integrating `modal_norm` into `modal_search` as a preprocessing step (deferred)
- Custom simp attribute `@[modal_norm_unfold]` registration (deferred; plain macro is sufficient)
- Modifying the existing `Formula.toJson` to produce enriched output (separate `EnrichedFormula.toJson`)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Ambiguous fold patterns produce wrong enriched representation | H | M | Conservative approach: only fold unambiguous patterns; document all ambiguities |
| `simp` lemma ordering causes fold to produce unexpected results | M | M | Test extensively; list higher-level operators first in fold macro |
| `EnrichedFormula` ADT adds significant compilation overhead | L | L | Keep in separate file; lazy import only where needed |
| Round-trip property fails for some edge cases | M | L | Test with enumerated formulas at small complexity; add exhaustive `#eval` checks |
| `lake build` regression from new file imports | M | L | Phase 5 dedicated to lakefile integration and full build verification |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3, 4 | 2 |
| 4 | 5 | 3, 4 |

Phases within the same wave can execute in parallel.

### Phase 1: Unfold Lemmas and modal_norm Tactic [COMPLETED]

**Goal**: Create the core normalization infrastructure -- all 15 unfold lemmas and the `modal_norm` family of tactics.

**Tasks**:
- [x] Create `Theories/Bimodal/Automation/Normalization.lean`
- [x] Define 15 unfold lemmas organized by dependency level (all `rfl`):
  - Level 1: `neg_unfold`, `top_unfold`, `next_unfold`, `prev_unfold`
  - Level 2: `and_unfold`, `or_unfold`, `diamond_unfold`, `some_future_unfold`, `some_past_unfold`
  - Level 3: `all_future_unfold`, `all_past_unfold`
  - Level 4: `weak_future_unfold`, `weak_past_unfold`
  - Level 5: `always_unfold`
  - Level 6: `sometimes_unfold`
- [x] Define `modal_norm` macro (full normalization to primitives)
- [x] Define selective variants: `prop_norm`, `modal_op_norm`, `temporal_norm`
- [x] Define hypothesis variants: `modal_norm_at`, `modal_norm_all`
- [x] Add basic `#check` and `example` tests verifying each lemma and macro works

**Timing**: 1 hour

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Automation/Normalization.lean` -- NEW file, all content

**Verification**:
- All 15 unfold lemmas typecheck as `rfl`
- `modal_norm` reduces a formula with `always` to primitives in an `example`
- Selective variants preserve non-targeted operators

---

### Phase 2: EnrichedFormula ADT and Fold Algorithm [NOT STARTED]

**Goal**: Implement the `EnrichedFormula` inductive type and the greedy `Formula.foldFormula` function that pattern-matches primitive trees against derived operator patterns.

**Tasks**:
- [ ] Define `EnrichedFormula` inductive type with 21 constructors:
  - 6 primitive: `atom`, `bot`, `imp`, `box`, `untl`, `snce`
  - 15 enriched: `neg`, `top`, `and_`, `or_`, `diamond`, `some_future`, `some_past`, `all_future`, `all_past`, `next`, `prev`, `weak_future`, `weak_past`, `always`, `sometimes`
- [ ] Document the complete ambiguity analysis table:
  - `imp φ bot` -- unambiguous: always `neg φ`
  - `imp bot bot` -- unambiguous: always `top`
  - `imp (imp φ bot) ψ` -- AMBIGUOUS: `or φ ψ` vs `imp (neg φ) ψ`. Conservative: fold to `or` only when ψ is not `bot`; if ψ is `bot`, fold the inner to `neg` then the outer to `neg(neg φ)` which simplifies
  - `imp (imp φ (imp ψ bot)) bot` -- unambiguous: `and φ ψ`
  - `imp (box (imp φ bot)) bot` -- unambiguous: `diamond φ`
  - `untl φ (imp bot bot)` -- unambiguous: `some_future φ` (guard is `top`)
  - `snce φ (imp bot bot)` -- unambiguous: `some_past φ` (guard is `top`)
  - `untl φ bot` -- unambiguous: `next φ` (guard is `bot`)
  - `snce φ bot` -- unambiguous: `prev φ` (guard is `bot`)
  - Higher-level operators (`all_future`, `all_past`, `weak_future`, `weak_past`, `always`, `sometimes`) are composed from the above; fold bottom-up then recognize compositions
- [ ] Implement `Formula.foldFormula : Formula -> EnrichedFormula` using bottom-up recursive pattern matching:
  1. Recursively fold subformulas first
  2. At each node, attempt to match against defined operator patterns from highest level down
  3. For ambiguous `imp(neg(A), B)` pattern: fold to `or` when B is not further reducible to `neg`; otherwise leave as `imp(neg A, B)`
  4. Conservative default: if no unambiguous match, keep the primitive constructor
- [ ] Add `EnrichedFormula.toPrimitive : EnrichedFormula -> Formula` for the inverse direction (unfold each enriched tag back to its definition)
- [ ] Add `#eval` tests demonstrating fold on representative formulas

**Timing**: 2 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Automation/Normalization.lean` -- add `EnrichedFormula` type, `foldFormula`, `toPrimitive`

**Verification**:
- `foldFormula` on `imp (atom p) bot` produces `neg (atom p)`
- `foldFormula` on `imp (box (imp (atom p) bot)) bot` produces `diamond (atom p)`
- `foldFormula` on `imp (imp (atom p) (imp (atom q) bot)) bot` produces `and_ (atom p) (atom q)`
- `toPrimitive` inverts `foldFormula` for all test cases

---

### Phase 3: Fold-Direction Simp Lemmas and Round-Trip Tests [NOT STARTED]

**Goal**: Add simp lemmas for the fold direction (primitives to derived operators) where unambiguous, and verify the round-trip property.

**Tasks**:
- [ ] Define fold-direction simp lemmas for unambiguous patterns:
  - `neg_fold`: `φ.imp .bot = φ.neg`
  - `top_fold`: `Formula.bot.imp .bot = Formula.top`
  - `and_fold`: `(φ.imp ψ.neg).neg = φ.and ψ`
  - `diamond_fold`: `φ.neg.box.neg = φ.diamond`
  - `some_future_fold`: `Formula.untl φ Formula.top = φ.some_future`
  - `some_past_fold`: `Formula.snce φ Formula.top = φ.some_past`
  - `next_fold`: `Formula.untl φ .bot = φ.next`
  - `prev_fold`: `Formula.snce φ .bot = φ.prev`
  - `all_future_fold`: `(φ.neg.some_future).neg = φ.all_future`
  - `all_past_fold`: `(φ.neg.some_past).neg = φ.all_past`
  - Note: `or_fold` is deliberately omitted due to ambiguity with `imp(neg A, B)`
- [ ] Define `modal_fold` macro using `<- _unfold` pattern
- [ ] Add round-trip `example` tests: for formulas built with derived operators, verify `modal_norm` then `modal_fold` recovers the original (modulo `or` ambiguity)
- [ ] Add `#eval` round-trip test using `foldFormula` and `toPrimitive`: verify `toPrimitive (foldFormula f) = f` for enumerated formulas at complexity <= 5
- [ ] Document which fold lemmas are omitted and why (ambiguity analysis)

**Timing**: 1.5 hours

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Automation/Normalization.lean` -- add fold lemmas, `modal_fold` macro, round-trip tests

**Verification**:
- All fold lemmas typecheck as `rfl`
- Round-trip `example`: `modal_norm; modal_fold` closes `phi.diamond.imp phi.diamond` goals
- `#eval` round-trip: `toPrimitive (foldFormula f) == f` for all formulas at complexity <= 5

---

### Phase 4: JSON Serialization for Enriched Formulas [NOT STARTED]

**Goal**: Provide JSON and string serialization for `EnrichedFormula` so the fold output can be exported for BimodalHarness training data.

**Tasks**:
- [ ] Implement `EnrichedFormula.toJson : EnrichedFormula -> String` using enriched constructor tags:
  - Primitive tags: `"atom"`, `"bot"`, `"imp"`, `"box"`, `"untl"`, `"snce"`
  - Enriched tags: `"neg"`, `"top"`, `"and"`, `"or"`, `"diamond"`, `"some_future"`, `"some_past"`, `"all_future"`, `"all_past"`, `"next"`, `"prev"`, `"weak_future"`, `"weak_past"`, `"always"`, `"sometimes"`
  - Use same JSON structure as `Formula.toJson` (tag + child/left/right fields)
- [ ] Implement `EnrichedFormula.prettyPrint : EnrichedFormula -> String` using standard operator notation:
  - `neg φ` -> `"(~phi)"`, `and_ φ ψ` -> `"(phi & psi)"`, `or_ φ ψ` -> `"(phi | psi)"`, `diamond φ` -> `"<>phi"`, etc.
- [ ] Implement `EnrichedFormula.toSExpr : EnrichedFormula -> String` for S-expression output with enriched tags
- [ ] Implement convenience `Formula.toEnrichedJson : Formula -> String` that composes `foldFormula` then `toJson`
- [ ] Add `#eval` tests verifying JSON output matches expected format

**Timing**: 1 hour

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Automation/Normalization.lean` -- add serialization functions

**Verification**:
- `EnrichedFormula.toJson` on `neg (atom p)` produces `{"tag": "neg", "child": {"tag": "atom", "name": "p"}}`
- `Formula.toEnrichedJson` on `(atom p).diamond` produces JSON with `"tag": "diamond"`
- All serialization functions produce valid JSON (manually verifiable by inspection)

---

### Phase 5: Lakefile Integration and Full Build Verification [NOT STARTED]

**Goal**: Integrate the new `Normalization.lean` into the project build and verify zero regressions.

**Tasks**:
- [ ] Add `import Bimodal.Automation.Normalization` to the appropriate aggregator file (e.g., `Theories/Bimodal/Automation/Automation.lean` or similar module root)
- [ ] Run `lake build` to verify full project compiles with zero errors
- [ ] Fix any import conflicts or naming collisions
- [ ] Verify existing tests still pass
- [ ] Run `#eval` round-trip tests at complexity 5 to confirm correctness

**Timing**: 0.5 hours

**Depends on**: 3, 4

**Files to modify**:
- `lakefile.lean` or aggregator `.lean` file -- add import
- Any files with naming collisions (unlikely, but check)

**Verification**:
- `lake build` completes with zero errors
- No `sorryAx` introduced (`#print axioms` on key definitions)
- All `#eval` tests pass

## Testing & Validation

- [ ] All 15 unfold lemmas are `rfl` (definitional equality)
- [ ] `modal_norm` reduces `always (atom p)` to a formula with only `atom`, `bot`, `imp`, `box`, `untl`, `snce`
- [ ] `foldFormula` correctly identifies: `neg`, `top`, `and`, `diamond`, `some_future`, `some_past`, `all_future`, `all_past`, `next`, `prev`
- [ ] `foldFormula` conservatively handles ambiguous `or` vs `imp(neg, _)` pattern
- [ ] Round-trip property: `toPrimitive (foldFormula f) = f` for all formulas at complexity <= 5
- [ ] `EnrichedFormula.toJson` produces valid JSON with enriched operator tags
- [ ] `lake build` passes with zero errors after integration

## Artifacts & Outputs

- `Theories/Bimodal/Automation/Normalization.lean` -- all normalization infrastructure (unfold lemmas, fold algorithm, EnrichedFormula ADT, serialization)
- `specs/190_derived_operator_normalization/plans/03_implementation-plan.md` -- this plan

## Rollback/Contingency

The entire implementation is contained in a single new file (`Normalization.lean`) with no modifications to existing files beyond the aggregator import. Rollback is straightforward: remove the import line and delete the file. No existing behavior is modified.
