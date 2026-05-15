# Implementation Plan: Add U(T,bot) -> box(U(T,bot)) Structural Axiom

- **Task**: 142 - mixed_case_countermodel
- **Status**: [NOT STARTED]
- **Effort**: 8 hours
- **Dependencies**: None (builds on existing sorry-free soundness infrastructure)
- **Research Inputs**: specs/142_mixed_case_countermodel/reports/01_mixed-case-research.md, specs/142_mixed_case_countermodel/reports/02_team-research.md, specs/142_mixed_case_countermodel/reports/03_case-c-deep-dive.md, specs/142_mixed_case_countermodel/reports/04_team-research.md
- **Artifacts**: plans/04_structural-axiom-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

The mixed-case sorry at `dd_countermodel_chronicle_mixed_sorry` (ChronicleToCountermodel.lean:3327) is not a construction problem -- it is a completeness gap in the BX axiom system. The formula box(U(T,bot)) v box(F'T) is valid on all TaskFrame models (because every ordered abelian group is either globally dense or globally discrete) but not BX-derivable. This plan adds `U(T,bot) -> box(U(T,bot))` as a new BX axiom, proves it sound via the existing translation-invariance pattern, derives a lemma that every MCS contains either box(F'T) or box(U(T,bot)), and eliminates the mixed case in `bx_completeness` via `False.elim`. The definition of done is: `sorry` removed from `dd_countermodel_chronicle_mixed_sorry`, `lake build` passes, and `#print axioms bx_completeness` shows no new `sorryAx` dependency from this change.

### Research Integration

Four research rounds converged independently on the same discovery:
- **Report 01**: Identified the sorry, explored 5 strategies (all failed), noted the mixed case as genuine.
- **Report 02**: Discovered the algebraic constraint that ordered abelian groups are either globally dense or globally discrete. Proposed formula-guided domain selection (ultimately unnecessary).
- **Report 03**: Traced the truth lemma's box case to show the real blocker is Until backward coherence at wrong-type families, not the box case itself. Identified Case C-hard as the irreducible blocker.
- **Report 04 (breakthrough)**: Proved box(U(T,bot)) v box(F'T) is semantically valid but not BX-derivable. Corrected Report 01's erroneous claim that the mixed case is satisfiable on Q. Recommended adding U(T,bot) -> box(U(T,bot)) as a structural axiom.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

- Advances the critical path item: "Task 142 (mixed-case countermodel)" from the ROADMAP.md
- Reduces the sorry count for `bx_completeness` by eliminating the mixed-case branch
- Moves toward the target state of sorry-free `bx_completeness`

## Goals & Non-Goals

**Goals**:
- Add `U(T,bot) -> box(U(T,bot))` as a new axiom constructor in Axioms.lean
- Prove the new axiom sound on all TaskFrame models via translation-invariance
- Derive the completeness consequence: every MCS has box(F'T) or box(U(T,bot))
- Eliminate the mixed case sorry via `False.elim`
- Update all exhaustive pattern matches on `Axiom` that break after adding the constructor
- Verify `lake build` passes with no new sorry dependencies

**Non-Goals**:
- Adding the contrapositive axiom `F'T -> box(F'T)` (derivable from the primary axiom via S5 + uniformity, but not needed for the mixed-case fix)
- Formal verification that box(U(T,bot)) v box(F'T) is NOT a BX theorem (interesting but not required)
- Resolving other sorry sites in the completeness proof (tasks 139, 140)
- Updating the decidability/FMP module (the axiom is sound, so existing FMP completeness is unaffected; adding the axiom to FMP is a separate task if needed)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Exhaustive match cascade: adding an Axiom constructor breaks many `cases h with` blocks | M | H | Systematic grep for all `cases` on `Axiom`, update in dependency order |
| Soundness proof harder than expected (translation-invariance subtlety) | M | L | Existing `discrete_propagate_fwd_valid` uses identical argument; adapt directly |
| Frame class classification unclear for new axiom | L | M | Classify as `Base` (valid on ALL ordered abelian groups, not just dense or discrete) |
| MCS derivation chain for False.elim is nontrivial | M | M | Use `theorem_in_mcs` + `mcs_closed_mp` + `negation_complete`; same pattern as existing cases |
| `lake build` timeout from large rebuild | L | L | Build incrementally; the change touches few files in the dependency graph |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5 | 4 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Add Axiom Constructor and Fix Exhaustive Matches [COMPLETED]

**Goal**: Add `discrete_box_necessity` (or equivalent name) to the `Axiom` inductive type and fix all pattern match exhaustiveness errors.

**Tasks**:
- [x] Add new axiom constructor to `Axiom` inductive in Axioms.lean
- [x] Update `Axiom.frameClass` to return `.Base` for the new constructor *(deviation: altered -- wildcard match already handles it)*
- [x] Update `Axiom.isBase` to return `True` for the new constructor *(deviation: altered -- wildcard match already handles it)*
- [x] Update `Axiom.isDenseCompatible` to return `True` for the new constructor *(deviation: altered -- wildcard match already handles it)*
- [x] Update `Axiom.isDiscreteCompatible` to return `True` for the new constructor *(deviation: altered -- wildcard match already handles it)*
- [x] Update doc comment: axiom count from 41 to 42, and Layer 5 uniformity axioms from 4 to 5
- [x] Run `lake build Bimodal.ProofSystem.Axioms` to confirm the module compiles
- [x] Grep for all exhaustive matches on `Axiom` in the codebase
- [x] Fix exhaustive matches in Soundness.lean: `axiom_base_valid`, `axiom_valid_dense`, `axiom_valid_discrete` *(deviation: altered -- filled in full proof immediately rather than sorry placeholder, merging Phase 2 work)*
- [x] Fix exhaustive matches in the `soundness` theorem and `soundness_dense`/`soundness_discrete` inductions *(deviation: altered -- soundness_discrete uses wildcard, no update needed)*
- [x] Fix exhaustive matches in DenseSoundness.lean and DiscreteSoundness.lean if they have their own case splits *(deviation: skipped -- these files do not exist)*
- [x] Fix exhaustive matches in Derivation.lean (`isDenseCompatible`, `isDiscreteCompatible`) *(deviation: skipped -- these use wildcard matches that already handle new constructors)*
- [x] Fix any exhaustive matches in SoundnessLemmas.lean (swap preservation lemmas)
- [x] Fix exhaustive match in Substitution.lean (axiom substitution lemma)
- [x] Run `lake build` to verify all exhaustiveness errors are resolved

**Timing**: 2 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/ProofSystem/Axioms.lean` -- add constructor, update predicates
- `Theories/Bimodal/Metalogic/Soundness.lean` -- fix exhaustive matches (placeholder sorry for validity proof)
- `Theories/Bimodal/Metalogic/DenseSoundness.lean` -- fix if needed
- `Theories/Bimodal/Metalogic/DiscreteSoundness.lean` -- fix if needed
- `Theories/Bimodal/ProofSystem/Derivation.lean` -- fix isDenseCompatible/isDiscreteCompatible
- `Theories/Bimodal/Metalogic/SoundnessLemmas.lean` -- fix swap preservation if needed
- Any other files with exhaustive Axiom matches

**Verification**:
- `lake build` passes (with expected sorry in soundness validity proof)
- `Axiom.discrete_box_necessity` is a well-typed constructor
- All `isBase`, `isDenseCompatible`, `isDiscreteCompatible` return correct values for the new axiom

---

### Phase 2: Prove Soundness of the New Axiom [COMPLETED]

**Goal**: Prove `discrete_box_necessity_valid : ⊨ (U(T,bot).imp (box (U(T,bot))))` using the translation-invariance argument.

**Tasks**:
- [ ] Create the soundness theorem `discrete_box_necessity_valid` in Soundness.lean (near the existing uniformity axiom validity proofs, lines 762-844)
- [ ] The proof structure follows `discrete_propagate_fwd_valid` (line 812) closely:
  1. Assume `truth_at M Omega tau t (U(T,bot))`, i.e., there exists `s > t` with `(t,s)` empty in D
  2. For any history `sigma in Omega`, we need `truth_at M Omega sigma t (U(T,bot))`
  3. The key: `U(T,bot)` truth depends ONLY on D's order structure, not on tau/sigma/Omega/M
  4. Since `s > t` and `(t,s)` is empty in D, this is true for ANY history at time `t`
  5. The box quantifies over all `sigma in Omega` at the SAME time `t`, so the result follows
- [x] The proof should be approximately 10-20 lines, mirroring the translation-invariance pattern *(deviation: altered -- 5 lines; the proof is trivial since box quantifies over histories at the same time)*
- [x] Replace the placeholder sorry in `axiom_base_valid` (Phase 1) with `exact discrete_box_necessity_valid` *(deviation: altered -- done in Phase 1, no placeholder needed)*
- [x] Replace placeholder sorries in `axiom_valid_dense` and `axiom_valid_discrete` *(deviation: altered -- done in Phase 1)*
- [x] Replace placeholder sorries in the full `soundness` / `soundness_dense` / `soundness_discrete` theorems *(deviation: altered -- done in Phase 1)*
- [x] Run `lake build` to verify all soundness-related sorries are eliminated

**Timing**: 2 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/Soundness.lean` -- add validity theorem, wire into exhaustive matches

**Verification**:
- `discrete_box_necessity_valid` compiles without sorry
- `axiom_base_valid`, `axiom_valid_dense`, `axiom_valid_discrete` have no sorry for the new case
- `lake build Bimodal.Metalogic.Soundness` passes without sorry
- All soundness theorems remain sorry-free

---

### Phase 3: Derive MCS Consequence -- Every MCS Has box(F'T) or box(U(T,bot)) [COMPLETED]

**Goal**: Prove that in the presence of the new axiom, every MCS A satisfies `box(F'T) in A` or `box(U(T,bot)) in A`, making the mixed case hypotheses contradictory.

**Tasks**:
- [x] Create `mcs_mixed_case_absurd` in ChronicleToCountermodel.lean *(deviation: altered -- used the direct False approach instead of the disjunction; 8-step derivation chain via contraposition + necessitation + K-distribution + S5 negative introspection)*
- [x] Also created `dd_countermodel_chronicle_mixed_sorry` proof via `False.elim (mcs_mixed_case_absurd ...)`
- [x] Verify the derivation chain compiles

**Timing**: 2 hours

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` -- add the MCS consequence lemma (near the existing `dd_countermodel_chronicle_mixed_sorry`)
- Possibly `Theories/Bimodal/Metalogic/Core/MCSProperties.lean` or a helper file for intermediate derivation lemmas

**Verification**:
- `mcs_mixed_case_absurd` (or `mcs_box_dense_or_discrete`) compiles without sorry
- The derivation chain from the new axiom to the contradiction is correct
- `lake build` passes for the affected modules

---

### Phase 4: Eliminate the Mixed Case Sorry [COMPLETED]

**Goal**: Replace `sorry` in `dd_countermodel_chronicle_mixed_sorry` with `False.elim` using the contradiction derived in Phase 3, and update `bx_completeness` accordingly.

**Tasks**:
- [x] Replace the `sorry` in `dd_countermodel_chronicle_mixed_sorry` with `exact False.elim (mcs_mixed_case_absurd ...)` *(completed in Phase 3)*
- [x] Update the docstring on `dd_countermodel_chronicle_mixed_sorry` to note it is now proved via `False.elim` *(completed in Phase 3)*
- [x] Update the Completeness.lean module docstring and axiom audit comments *(deferred to Phase 5)*
- [x] Run `lake build Bimodal.Metalogic.BXCanonical.Completeness` to verify the sorry is gone *(deviation: altered -- kept bx_completeness calling dd_countermodel_chronicle_mixed_sorry which now uses False.elim internally; no restructuring needed)*

**Timing**: 1 hour

**Depends on**: 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` -- replace sorry with False.elim
- `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` -- update docstrings and possibly restructure the mixed case branch

**Verification**:
- `dd_countermodel_chronicle_mixed_sorry` compiles without `sorry`
- `bx_completeness` compiles without `sorry` contribution from the mixed case
- `lake build Bimodal.Metalogic.BXCanonical.Completeness` passes

---

### Phase 5: Full Build Verification and Documentation [COMPLETED]

**Goal**: Verify the entire project builds cleanly, update documentation, and confirm the axiom audit shows improvement.

**Tasks**:
- [x] Run `lake build` on the full project to verify no regressions
- [x] Run `#print axioms bx_completeness` and verify `sorryAx` dependency from mixed case is eliminated (confirmed: `mcs_mixed_case_absurd` and `dd_countermodel_chronicle_mixed_sorry` have no `sorryAx`)
- [x] Update ROADMAP.md: mixed case 0 sorries, axiom count 42, Layer 5 uniformity 5 with new axiom entry
- [x] Update Axioms.lean doc header *(completed in Phase 1)*
- [x] Update Completeness.lean module docstring
- [x] Verify no other files reference the mixed case sorry or assume it exists

**Timing**: 1 hour

**Depends on**: 4

**Files to modify**:
- Full project build verification
- `specs/ROADMAP.md` -- update sorry counts and axiom description
- `Theories/Bimodal/ProofSystem/Axioms.lean` -- update doc header
- `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` -- update axiom audit

**Verification**:
- `lake build` passes with no new errors
- `#print axioms bx_completeness` shows expected axioms (no new `sorryAx` from mixed case)
- ROADMAP.md accurately reflects the new state
- All documentation is consistent with the changes

## Testing & Validation

- [ ] `lake build` passes with no errors
- [ ] `#print axioms bx_completeness` does not show `sorryAx` as a dependency from the mixed case
- [ ] `#print axioms Bimodal.Metalogic.BXCanonical.Chronicle.dd_countermodel_chronicle_mixed_sorry` shows no `sorryAx`
- [ ] All soundness theorems remain sorry-free
- [ ] The new axiom `discrete_box_necessity` is correctly typed and its frame class predicates are consistent
- [ ] Existing tests in `Tests/BimodalTest/` still pass

## Artifacts & Outputs

- `Theories/Bimodal/ProofSystem/Axioms.lean` -- new axiom constructor `discrete_box_necessity`
- `Theories/Bimodal/Metalogic/Soundness.lean` -- soundness proof `discrete_box_necessity_valid`
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` -- MCS consequence lemma + sorry elimination
- `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` -- updated completeness proof
- `specs/ROADMAP.md` -- updated sorry counts and axiom documentation

## Rollback/Contingency

If the implementation fails at any phase:
1. **Phase 1 failure** (exhaustive match cascade too large): Use `| _ => sorry` temporarily in non-critical match sites and iterate
2. **Phase 2 failure** (soundness proof doesn't close): The argument is mathematically identical to `discrete_propagate_fwd_valid`; if the Lean encoding differs, adapt the proof to match the exact `truth_at` unfolding. Check that `box` quantifies over histories in `Omega` at the same time `t`, not over all times
3. **Phase 3 failure** (derivation chain too complex): Simplify by adding a helper derivation lemma in MCSProperties.lean, or use a direct semantic argument instead of a syntactic derivation chain
4. **Full rollback**: `git stash` or `git checkout` to restore the pre-change state; no external dependencies are affected
