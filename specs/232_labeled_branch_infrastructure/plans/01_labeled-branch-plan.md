# Implementation Plan: Labeled Branch Infrastructure (World/Time-Indexed Types)

- **Task**: 232 - Labeled branch infrastructure (world/time-indexed types)
- **Status**: [NOT STARTED]
- **Effort**: 6 hours
- **Dependencies**: None
- **Research Inputs**: specs/232_labeled_branch_infrastructure/reports/01_labeled-branch-research.md
- **Artifacts**: plans/01_labeled-branch-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Replace the flat `SignedFormula` (`{ sign, formula }`) and `Branch` (`List SignedFormula`) types in `Metalogic/Decidability/` with world/time-indexed types that support proper multi-world modal and time-indexed temporal reasoning. The change surface is 9 files totaling 2369 lines, but the dependency chain is strictly linear (SignedFormula -> Tableau -> Closure -> Saturation -> downstream), so the migration can be done file-by-file following the import DAG. The FMP subsystem (7 files) is completely unaffected. Propositional rules propagate labels unchanged; modal/temporal rules remain identity-collapse placeholders (tasks 233/234 will replace them). The build must stay sorry-free throughout.

### Research Integration

Key research findings integrated into this plan:
- **Label design**: Use a `Label` structure grouping `WorldIndex := Nat` and `TimeIndex := Nat`, with `Label.initial` at `(0, 0)` for the starting world+time. This is cleaner than flat fields and easier to thread through rule application.
- **Change surface**: 9 files total. SignedFormula.lean (376 lines, HIGH impact), Tableau.lean (379 lines, MEDIUM), Closure.lean (375 lines, MEDIUM), Saturation.lean (233 lines, LOW), and 5 downstream files (LOW/NONE impact). Correctness.lean has zero SignedFormula/Branch usage.
- **Monotonicity lemmas**: 6 theorems in Closure.lean need re-proving. The proofs are structural (list membership under cons) and translate cleanly with label matching.
- **`deriving` strategy**: `DecidableEq`, `BEq`, `Hashable` can all be auto-derived since `Nat` has these instances. `LawfulBEq` needs manual re-proof (3 theorems).

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No ROADMAP.md found.

## Goals & Non-Goals

**Goals**:
- Define `WorldIndex`, `TimeIndex`, and `Label` types in SignedFormula.lean
- Extend `SignedFormula` structure with a `label : Label` field
- Update all `Branch` helper functions to account for labels
- Migrate all 8 propositional rules to thread labels (input label preserved in output)
- Update `Closure.lean` contradiction detection to match within same world+time
- Update `Saturation.lean` to create initial branch at `Label.initial`
- Ensure all 5 downstream files compile with the new types
- Maintain sorry-free compilation throughout (`lake build` passes at each phase)

**Non-Goals**:
- Replacing the identity-collapse modal rules with correct S5 rules (task 233)
- Replacing the identity-collapse temporal rules with correct time-indexed rules (task 234)
- Adding Until/Since rules (task 235)
- Adding `Branch` operations for world/time querying (nextWorld, nextTime, atLabel, etc.) -- these are needed by tasks 233/234 and can be added then
- Modifying the FMP subsystem

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `LawfulBEq` re-proof fails with `deriving` | M | L | Manual proofs following existing pattern; `Nat` and `Sign` already have `LawfulBEq` |
| Monotonicity lemma re-proofs are harder than expected | M | L | Proofs are structural (list membership); label field adds one more conjunction but pattern is identical |
| Downstream files have unexpected SignedFormula field access | L | L | Research report audited all 9 files; only CountermodelExtraction and EnrichedCountermodel directly access fields |
| `deriving DecidableEq` fails for `Label` or updated `SignedFormula` | M | L | All component types (`Nat`, `Sign`, `Formula`) already have `DecidableEq`; fallback to manual instance |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5 | 4 |

Phases are fully sequential following the import DAG.

### Phase 1: Core Type Definitions and SignedFormula Update [COMPLETED]

**Goal**: Define `WorldIndex`, `TimeIndex`, `Label` types and update `SignedFormula` to carry a label. Update all `Branch` helpers. Re-derive/re-prove typeclass instances.

**Tasks**:
- [ ] Define `abbrev WorldIndex := Nat` before the `Sign` type (after line 37)
- [ ] Define `abbrev TimeIndex := Nat` alongside `WorldIndex`
- [ ] Define `structure Label` with fields `world : WorldIndex` and `time : TimeIndex`, deriving `Repr, DecidableEq, BEq, Hashable`
- [ ] Add `Label.initial : Label := { world := 0, time := 0 }` in a `Label` namespace
- [ ] Prove `LawfulBEq Label` (manual proof following the `Sign` pattern at lines 70-85)
- [ ] Update `SignedFormula` structure (lines 101-106) to add `label : Label` field, keeping `deriving Repr, DecidableEq, BEq, Hashable`
- [ ] Update `SignedFormula.pos` (line 111) to accept optional label: `def pos (φ : Formula) (l : Label := Label.initial) : SignedFormula := ⟨.pos, φ, l⟩`
- [ ] Update `SignedFormula.neg` (line 114) similarly: `def neg (φ : Formula) (l : Label := Label.initial) : SignedFormula := ⟨.neg, φ, l⟩`
- [ ] Update `SignedFormula.flip` (line 117) to preserve label: `def flip (sf : SignedFormula) : SignedFormula := ⟨sf.sign.flip, sf.formula, sf.label⟩`
- [ ] Re-prove `SignedFormula.beq_eq` (line 133) to include the label field in the BEq decomposition
- [ ] Re-prove `SignedFormula.beq_refl` (line 138) for the 3-field structure
- [ ] Re-prove `SignedFormula.eq_of_beq` (lines 146-157) for the 3-field structure
- [ ] Update `LawfulBEq SignedFormula` instance (lines 159-161)
- [ ] Update `Branch.hasPos` (line 188) to use the label-aware `SignedFormula.pos`
- [ ] Update `Branch.hasNeg` (line 192) to use the label-aware `SignedFormula.neg`
- [ ] Add `Branch.hasNegAt (b : Branch) (φ : Formula) (l : Label) : Bool` -- checks for `F(φ)` at a specific label
- [ ] Add `Branch.hasPosAt (b : Branch) (φ : Formula) (l : Label) : Bool` -- checks for `T(φ)` at a specific label
- [ ] Update `Branch.hasBotPos` (line 196) -- note this currently uses `SignedFormula.pos .bot` which now needs a label; use a check that matches any label for T(bot) since T(bot) is a contradiction regardless of world+time
- [ ] Update `Branch.findContradiction` (lines 203-206) to match within same label
- [ ] Update `Branch.positives` and `Branch.negatives` (lines 213-218) -- these remain unchanged since they filter on sign only
- [ ] Verify `lake build Bimodal.Metalogic.Decidability.SignedFormula` compiles

**Timing**: 2 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/Decidability/SignedFormula.lean` - Add WorldIndex/TimeIndex/Label types, update SignedFormula structure, update Branch helpers, re-prove LawfulBEq

**Verification**:
- `lake build Bimodal.Metalogic.Decidability.SignedFormula` compiles without errors or sorries
- `Label.initial` is `{ world := 0, time := 0 }`
- `SignedFormula.pos (.atom 0)` still works (label defaults to initial)
- `SignedFormula.pos (.atom 0) { world := 1, time := 2 }` also works

---

### Phase 2: Tableau Rule Migration [COMPLETED]

**Goal**: Thread labels through all 16 tableau rules in `applyRule`. Propositional rules (8) preserve the input label. Modal/temporal rules (8) also preserve labels for now (they remain identity-collapse placeholders; tasks 233/234 will replace them).

**Tasks**:
- [ ] Update `applyRule` (lines 217-283) to thread `sf.label` into all output `SignedFormula` values:
  - `andPos` (line 222): `SignedFormula.pos ψ sf.label, SignedFormula.pos χ sf.label`
  - `andNeg` (line 227): `SignedFormula.neg ψ sf.label`, `SignedFormula.neg χ sf.label`
  - `orPos` (line 232): `SignedFormula.pos ψ sf.label`, `SignedFormula.pos χ sf.label`
  - `orNeg` (line 237): `SignedFormula.neg ψ sf.label`, `SignedFormula.neg χ sf.label`
  - `impPos` (line 241): `SignedFormula.neg ψ sf.label`, `SignedFormula.pos χ sf.label`
  - `impNeg` (line 244): `SignedFormula.pos ψ sf.label`, `SignedFormula.neg χ sf.label`
  - `negPos` (line 248): `SignedFormula.neg ψ sf.label`
  - `negNeg` (line 252): `SignedFormula.pos ψ sf.label`
  - `boxPos` (line 257): `SignedFormula.pos ψ sf.label` (identity-collapse, task 233 replaces)
  - `boxNeg` (line 260): `SignedFormula.neg ψ sf.label` (identity-collapse, task 233 replaces)
  - `diamondPos` (line 264): `SignedFormula.pos ψ sf.label` (identity-collapse, task 233 replaces)
  - `diamondNeg` (line 269): `SignedFormula.neg ψ sf.label` (identity-collapse, task 233 replaces)
  - `allFuturePos` (line 273): `SignedFormula.pos ψ sf.label` (identity-collapse, task 234 replaces)
  - `allFutureNeg` (line 276): `SignedFormula.neg ψ sf.label` (identity-collapse, task 234 replaces)
  - `allPastPos` (line 279): `SignedFormula.pos ψ sf.label` (identity-collapse, task 234 replaces)
  - `allPastNeg` (line 282): `SignedFormula.neg ψ sf.label` (identity-collapse, task 234 replaces)
- [ ] Verify `isApplicable` (lines 180-207) does not need changes (it only inspects sign and formula, not label)
- [ ] Verify `findApplicableRule` (lines 309-314) does not need changes (passes `sf` as-is)
- [ ] Verify `isExpanded`/`findUnexpanded` do not need changes (check formula structure only)
- [ ] Verify `expandOnce` filter `b.filter (· != sf)` works correctly (BEq now includes label, which is correct behavior)
- [ ] Verify `lake build Bimodal.Metalogic.Decidability.Tableau` compiles

**Timing**: 45 minutes

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/Decidability/Tableau.lean` - Thread labels through all `applyRule` cases

**Verification**:
- `lake build Bimodal.Metalogic.Decidability.Tableau` compiles without errors or sorries
- All 16 rule cases produce output formulas at the same label as the input formula

---

### Phase 3: Closure Detection Update [NOT STARTED]

**Goal**: Update `ClosureReason` to carry labels. Update contradiction detection to match within same world+time. Re-prove all 6 monotonicity lemmas and 2 derived closure theorems.

**Tasks**:
- [ ] Update `ClosureReason` (lines 50-57) to carry label information:
  - `contradiction (φ : Formula) (label : Label)` -- add label parameter
  - `botPos (label : Label)` -- add label parameter
  - `axiomNeg (φ : Formula) (witness : Axiom φ) (label : Label)` -- add label parameter
- [ ] Update `ClosureReason.describe` (lines 62-66) to include label in the description string
- [ ] Update `checkBotPos` (lines 76-77) to find T(bot) and record its label:
  ```lean
  def checkBotPos (b : Branch) : Option ClosureReason :=
    b.findSome? fun sf =>
      if sf.sign == .pos && sf.formula == .bot then some (.botPos sf.label) else none
  ```
- [ ] Update `checkContradiction` (lines 83-88) to match within same label:
  ```lean
  def checkContradiction (b : Branch) : Option ClosureReason :=
    b.findSome? fun sf =>
      if sf.isPos ∧ b.hasNegAt sf.formula sf.label then
        some (.contradiction sf.formula sf.label)
      else none
  ```
- [ ] Update `checkAxiomNeg` (lines 94-105) to record the label:
  ```lean
  -- Change: some (.axiomNeg φ witness) → some (.axiomNeg φ witness sf.label)
  ```
- [ ] Re-prove `hasNeg_mono` (lines 177-183) -- add label parameter or adjust for label-aware matching
- [ ] Re-prove `hasPos_mono` (lines 188-194) -- same pattern
- [ ] Re-prove `hasBotPos_mono` (lines 199+) -- adjust for label-aware bot check
- [ ] Re-prove `checkBotPos_mono` -- follows from hasBotPos_mono
- [ ] Re-prove `checkContradiction_mono` -- follows from hasNeg_mono with label matching
- [ ] Re-prove `checkAxiomNeg_mono` -- same structural pattern
- [ ] Re-prove `closed_extend_closed` and `add_neg_causes_closure` if present
- [ ] Verify `lake build Bimodal.Metalogic.Decidability.Closure` compiles

**Timing**: 1.5 hours

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/Decidability/Closure.lean` - Update ClosureReason, update checks for label matching, re-prove monotonicity lemmas

**Verification**:
- `lake build Bimodal.Metalogic.Decidability.Closure` compiles without errors or sorries
- `checkContradiction` only triggers when T(phi) and F(phi) share the same label
- `checkBotPos` finds T(bot) at any label but records which label it was at
- All monotonicity lemmas proved without sorry

---

### Phase 4: Saturation and Initial Branch [NOT STARTED]

**Goal**: Update `buildTableau` to start with `Label.initial`. Ensure expansion loop, saturation checks, and all types compile through.

**Tasks**:
- [ ] Update `buildTableau` (line 157) initial branch:
  ```lean
  let initialBranch : Branch := [SignedFormula.neg φ Label.initial]
  ```
- [ ] Verify `expandBranchWithFuel` compiles (uses `findClosure`, `expandOnce`, and `BranchListResult` -- all compile-through changes)
- [ ] Verify `ExpandedTableau` type compiles (uses `ClosedBranch` and `findUnexpanded`)
- [ ] Verify `buildTableauAuto`, `recommendedFuel`, `isSaturated`, `isAtomicBranch` compile
- [ ] Verify `lake build Bimodal.Metalogic.Decidability.Saturation` compiles

**Timing**: 30 minutes

**Depends on**: 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/Decidability/Saturation.lean` - Update initial branch label, compile-through adjustments

**Verification**:
- `lake build Bimodal.Metalogic.Decidability.Saturation` compiles without errors or sorries
- `buildTableau` starts with `F(phi)` at `Label.initial`

---

### Phase 5: Downstream Files and Full Build [NOT STARTED]

**Goal**: Update all remaining downstream files to compile with the new types. Run full `lake build` to verify the entire project remains sorry-free.

**Tasks**:
- [ ] Update `ProofExtraction.lean` (221 lines):
  - Update pattern matches on `ClosureReason` constructors to account for the new `label` field
  - `extractFromClosureReason` and related functions: destructure the new label field (likely just ignore it since proof extraction cares about the formula, not the label)
- [ ] Update `CountermodelExtraction.lean` (181 lines):
  - `extractTrueAtoms`/`extractFalseAtoms`: access `sf.formula` (unchanged pattern) -- label field can be ignored for now since the simplified countermodel does not model worlds/times
  - `extractCountermodelSimple`: may need adjustment if it constructs `SignedFormula` values
  - `branchTruthLemma`: placeholder proof (`True`) -- compile-through only
- [ ] Update `DecisionProcedure.lean` (268 lines):
  - Uses `buildTableau`, `DecisionResult`, `ExpandedTableau` -- mostly compile-through
  - Check `extractDecision` for any `ClosureReason` pattern matches
- [ ] Verify `Correctness.lean` (124 lines) compiles -- research confirmed zero SignedFormula/Branch usage
- [ ] Update `Automation/EnrichedCountermodel.lean` (212 lines):
  - `SignedFormula.toJson`: add `label` field to JSON serialization (include world and time indices)
  - `isModalFormula`/`isTemporalFormula`: access `sf.formula` only -- unchanged
  - `extractEnrichedCountermodel`: check for `SignedFormula` construction sites
- [ ] Run `lake build` to verify full project compiles
- [ ] Verify sorry-free: `grep -rn "sorry" Theories/Bimodal/Metalogic/Decidability/ | grep -v "^\s*--" | grep -v "sorryAx"` shows no new sorries (existing count should be unchanged)

**Timing**: 1.25 hours

**Depends on**: 4

**Files to modify**:
- `Theories/Bimodal/Metalogic/Decidability/ProofExtraction.lean` - Update ClosureReason pattern matches
- `Theories/Bimodal/Metalogic/Decidability/CountermodelExtraction.lean` - Update atom extraction, ignore labels for simple model
- `Theories/Bimodal/Metalogic/Decidability/DecisionProcedure.lean` - Compile-through updates
- `Theories/Bimodal/Metalogic/Decidability/Correctness.lean` - Verify compiles (likely no changes)
- `Theories/Bimodal/Automation/EnrichedCountermodel.lean` - Update JSON serialization to include label

**Verification**:
- `lake build` passes with zero errors
- `grep -rn "sorry" Theories/Bimodal/Metalogic/Decidability/` shows no new sorries
- All 9 files in the change surface compile cleanly
- The FMP subsystem (7 files) is unaffected (no imports of SignedFormula or Branch)

## Testing & Validation

- [ ] `lake build` passes with zero errors (full project)
- [ ] No new `sorry` introduced in any Decidability file
- [ ] No new `sorry` introduced in Automation/EnrichedCountermodel.lean
- [ ] `SignedFormula.pos (.atom 0)` defaults to `Label.initial` (backward-compatible API)
- [ ] `SignedFormula.pos (.atom 0) { world := 1, time := 2 }` creates a labeled formula at world 1, time 2
- [ ] `checkContradiction` correctly finds `T(p) @ (0,0)` and `F(p) @ (0,0)` as a contradiction
- [ ] `checkContradiction` correctly does NOT flag `T(p) @ (0,0)` and `F(p) @ (1,0)` as a contradiction (different world)
- [ ] Existing `buildTableau` calls produce the same validity results for propositional formulas (label threading is identity for propositional-only formulas)

## Artifacts & Outputs

- `specs/232_labeled_branch_infrastructure/plans/01_labeled-branch-plan.md` (this file)
- `specs/232_labeled_branch_infrastructure/summaries/01_labeled-branch-summary.md` (post-implementation)
- Modified files: `SignedFormula.lean`, `Tableau.lean`, `Closure.lean`, `Saturation.lean`, `ProofExtraction.lean`, `CountermodelExtraction.lean`, `DecisionProcedure.lean`, `EnrichedCountermodel.lean`

## Rollback/Contingency

All changes are confined to `Metalogic/Decidability/` and `Automation/EnrichedCountermodel.lean`. If the migration fails at any phase, `git checkout -- Theories/Bimodal/Metalogic/Decidability/ Theories/Bimodal/Automation/EnrichedCountermodel.lean` reverts all changes. The linear phase structure means partial progress can be preserved (e.g., if Phase 3 monotonicity lemmas prove difficult, Phases 1-2 are independently valuable and can be committed).
