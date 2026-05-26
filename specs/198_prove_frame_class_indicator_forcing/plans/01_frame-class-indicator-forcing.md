# Implementation Plan: Task #198

- **Task**: 198 - Prove frame-class indicator forcing in MCS
- **Status**: [NOT STARTED]
- **Effort**: 4 hours
- **Dependencies**: Task 168 (parameterize DerivationTree over FrameClass) -- COMPLETED
- **Research Inputs**: specs/198_prove_frame_class_indicator_forcing/reports/01_frame-class-indicator-forcing.md
- **Artifacts**: plans/01_frame-class-indicator-forcing.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Eliminate two `sorry` sites in `Completeness.lean` (lines 285 and 317) that guard the frame-class-specific completeness theorems `completeness_dense` and `completeness_discrete`. Research established that the dense sorry requires adding a new axiom `dense_indicator` (= `neg(U(T,bot))`) because the existing density schema `GG(phi) -> G(phi)` is provably insufficient to derive it (conservativity argument). The discrete sorry is solvable with existing axioms via a derivation chain: `identity` -> `serial_future` -> `prior_UZ` -> guard weakening via `left_mono_until_G` -> `theorem_in_mcs` -> contradiction with `set_consistent_not_both`.

### Research Integration

Research report `01_frame-class-indicator-forcing.md` provides:
- Proof that the density schema is insufficient for the dense sorry (conservativity argument via Z-model)
- Complete derivation chain for the discrete sorry using existing axioms
- Recommendation to add `dense_indicator` as an additional Dense axiom (Option A: alongside existing `density`)
- Identification of all key lemmas needed: `theorem_in_mcs`, `set_consistent_not_both`, `identity`, `serial_future`, `prior_UZ`, `left_mono_until_G`, `temporal_necessitation`

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

- Advances Phase 2 of the roadmap (frame hierarchy + axiom cleanup): adds the density indicator axiom `neg(U(T,bot))` as a Dense axiom, consistent with the planned four-tier hierarchy
- Reduces sorry count in `completeness_dense` and `completeness_discrete`, advancing the goal of sorry-free frame-class-specific completeness

## Goals & Non-Goals

**Goals**:
- Add `dense_indicator` axiom constructor to `Axiom` with `minFrameClass = .Dense`
- Prove soundness of `dense_indicator` on densely ordered frames
- Eliminate the sorry in `completeness_dense` (line 285) using the new axiom
- Eliminate the sorry in `completeness_discrete` (line 317) using existing axioms
- All changes compile with `lake build`, no new sorries introduced

**Non-Goals**:
- Replacing the existing `density` schema with `dense_indicator` (we add alongside, not replace)
- Proving sorry-free base completeness (that depends on Chronicle pipeline sorries)
- Refactoring the completeness proof structure beyond the two target sorries
- Modifying downstream consumers of the axiom system beyond Soundness.lean

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Guard weakening derivation chain for discrete case fails in Lean (step count or typing issues) | H | L | Research provides complete step-by-step derivation; use `lean_multi_attempt` to test each step |
| Soundness proof of `dense_indicator` requires DenselyOrdered infrastructure not available | M | L | `density_valid` already uses identical DenselyOrdered pattern; follow same structure |
| Adding axiom constructor breaks downstream pattern matches | M | L | Only Soundness.lean has exhaustive matches on Axiom; update in Phase 1 |
| `neg(T) -> bot` derivation is non-trivial in the proof system | M | L | Research provides explicit proof: assume `(bot->bot)->bot`, derive `bot` via identity+MP |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 3 | 1 |
| 3 | 4 | 2, 3 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Add dense_indicator Axiom and Soundness Proof [COMPLETED]

**Goal**: Add the `dense_indicator` axiom constructor to the `Axiom` inductive and prove its soundness on densely ordered frames.

**Tasks**:
- [ ] Add `dense_indicator` constructor to `Axiom` in Axioms.lean: `| dense_indicator : Axiom (Formula.untl (Formula.bot.imp Formula.bot) Formula.bot).neg`
- [ ] Set `minFrameClass` for `dense_indicator` to `.Dense` in `Axiom.minFrameClass`
- [ ] Update the `axiom_valid` exhaustive match in Soundness.lean to exclude `dense_indicator` (same pattern as `density`: `exact absurd h_fc (by simp [Axiom.minFrameClass, LE.le])`)
- [ ] Add soundness theorem in Soundness.lean: `theorem dense_indicator_valid : valid_dense (Formula.untl (Formula.bot.imp Formula.bot) Formula.bot).neg` proving `neg(U(T,bot))` is valid on dense orders. Proof: by contradiction -- `U(T,bot)` at t requires s > t with empty interval (t,s), contradicting `DenselyOrdered`
- [ ] Update `axiom_dense_valid` match to handle `dense_indicator` case using `dense_indicator_valid`
- [ ] Update `axiom_discrete_valid` match to exclude `dense_indicator` (`.Dense` is incomparable with `.Discrete`)
- [ ] Update axiom docstring count from 41 to 42 in Axioms.lean
- [ ] Run `lake build Bimodal.Metalogic.Soundness` to verify Phase 1 compiles

**Timing**: 1.5 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/ProofSystem/Axioms.lean` -- add constructor, update minFrameClass, update counts
- `Theories/Bimodal/Metalogic/Soundness.lean` -- add soundness proof, update exhaustive matches
- `Theories/Bimodal/Metalogic/DenseSoundness.lean` -- potentially update if it has its own match

**Verification**:
- `lake build Bimodal.Metalogic.Soundness` passes
- `lake build Bimodal.Metalogic.DenseSoundness` passes
- No new sorries introduced (verify with `#print axioms`)

---

### Phase 2: Prove completeness_dense Sorry [NOT STARTED]

**Goal**: Eliminate the sorry at line 285 in `completeness_dense` by showing that a Dense-MCS must contain `box(next_top.neg)`, making the non-dense branch unreachable.

**Tasks**:
- [ ] In the `h_not_box_dense` branch of `completeness_dense`, build the derivation tree for `next_top.neg` (= `neg(U(T,bot))`) using the new `dense_indicator` axiom: `DerivationTree.axiom [] _ Axiom.dense_indicator (by trivial)` (or appropriate `minFrameClass` proof)
- [ ] Apply `DerivationTree.necessitation` to get `[] ⊢ box(next_top.neg)`
- [ ] Use `theorem_in_mcs hM_mcs` to place `box(next_top.neg)` in M
- [ ] Derive contradiction: `h_not_box_dense : next_top.neg.box.neg ∈ M` and `box(next_top.neg) ∈ M`, apply `set_consistent_not_both hM_mcs.1 _ _ _` to get `False`
- [ ] Verify the Formula representations match exactly (next_top.neg vs the axiom output)

**Timing**: 1 hour

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` -- replace sorry at line 285

**Verification**:
- `lean_goal` at the sorry location shows `False` and the proof closes it
- `lake build Bimodal.Metalogic.BXCanonical.Completeness` passes
- `#print axioms completeness_dense` shows no `sorryAx`

---

### Phase 3: Prove completeness_discrete Sorry [NOT STARTED]

**Goal**: Eliminate the sorry at line 317 in `completeness_discrete` by showing that a Discrete-MCS cannot contain `box(next_top.neg)`, since `next_top` (= `U(T,bot)`) is derivable from discrete axioms.

**Tasks**:
- [ ] Build the derivation chain for `next_top` in the Discrete proof system:
  1. `identity Formula.bot` gives `⊢ bot.imp bot` (= top_formula = T)
  2. `serial_future` axiom gives `⊢ T -> F(T)`
  3. MP with steps 1 and 2 gives `⊢ F(T)`
  4. `prior_UZ top_formula` axiom gives `⊢ F(T) -> U(T, neg(T))`
  5. MP with steps 3 and 4 gives `⊢ U(T, neg(T))`
  6. Build `⊢ neg(T) -> bot`: from `identity (Formula.bot.imp Formula.bot)` get `⊢ T -> T`, then use deduction to get `⊢ (T -> bot) -> bot` which is `⊢ neg(T) -> bot`
  7. Apply `temporal_necessitation` to step 6 to get `⊢ G(neg(T) -> bot)`
  8. Apply `left_mono_until_G` axiom: `⊢ G(neg(T) -> bot) -> (U(T, neg(T)) -> U(T, bot))`
  9. MP steps 7 and 8 gives `⊢ U(T, neg(T)) -> U(T, bot)`
  10. MP steps 5 and 9 gives `⊢ U(T, bot)` = `next_top`
- [ ] Apply `theorem_in_mcs hM_mcs` to place `next_top` in M
- [ ] From `h_box_dense : box(next_top.neg) ∈ M`, extract `next_top.neg ∈ M` via Modal T:
  - Build `modal_t next_top.neg` axiom: `⊢ box(next_top.neg) -> next_top.neg`
  - Use `hM_mcs.implication_property` or `closed_under_derivation` with Modal T and `h_box_dense` to get `next_top.neg ∈ M`
- [ ] Apply `set_consistent_not_both hM_mcs.1 next_top h_next_top_in h_next_top_neg_in` to get `False`
- [ ] Verify all Formula term representations match exactly

**Timing**: 1.5 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` -- replace sorry at line 317

**Verification**:
- `lean_goal` at the sorry location shows `False` and the proof closes it
- `lake build Bimodal.Metalogic.BXCanonical.Completeness` passes
- `#print axioms completeness_discrete` shows no `sorryAx`

---

### Phase 4: Full Build Verification [NOT STARTED]

**Goal**: Verify the entire project compiles with no new sorries and the axiom audit is clean.

**Tasks**:
- [ ] Run `lake build` (full project build)
- [ ] Check `#print axioms completeness_dense` output -- should show no `sorryAx`
- [ ] Check `#print axioms completeness_discrete` output -- should show no `sorryAx`
- [ ] Verify that no downstream files broke due to the new axiom constructor (exhaustive match sites)
- [ ] Update the module docstring in Completeness.lean to reflect that the frame-class-specific sorries are eliminated

**Timing**: 0.5 hours (mostly build time)

**Depends on**: 2, 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` -- update docstrings only

**Verification**:
- `lake build` passes with 0 errors
- No new `sorryAx` dependencies in `completeness_dense` or `completeness_discrete`
- All existing tests pass

## Testing & Validation

- [ ] `lake build Bimodal.Metalogic.Soundness` passes after Phase 1
- [ ] `lake build Bimodal.Metalogic.BXCanonical.Completeness` passes after Phases 2-3
- [ ] `lake build` (full project) passes after Phase 4
- [ ] `#print axioms completeness_dense` shows no `sorryAx`
- [ ] `#print axioms completeness_discrete` shows no `sorryAx`
- [ ] No new sorry sites introduced anywhere in the project

## Artifacts & Outputs

- `Theories/Bimodal/ProofSystem/Axioms.lean` -- updated with `dense_indicator` constructor
- `Theories/Bimodal/Metalogic/Soundness.lean` -- updated with soundness proof and match cases
- `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` -- two sorries eliminated
- `specs/198_prove_frame_class_indicator_forcing/plans/01_frame-class-indicator-forcing.md` -- this plan

## Rollback/Contingency

If the implementation fails:
- Phase 1 (axiom addition) is self-contained; revert Axioms.lean and Soundness.lean to HEAD
- Phases 2-3 are independent sorry replacements; either can be reverted independently by restoring `sorry` at the target line
- `git stash` or `git checkout -- Theories/` reverts all changes
- If the derivation chain in Phase 3 proves intractable, the sorry can remain while Phase 2 (simpler, just axiom invocation) proceeds independently
