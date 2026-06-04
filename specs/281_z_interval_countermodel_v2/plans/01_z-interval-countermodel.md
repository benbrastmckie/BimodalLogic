# Implementation Plan: Z-Interval Countermodel v2

- **Task**: 281 - Complete countermodel_discrete_reynolds_v2 to bypass chronicle_gap_contradiction
- **Status**: [NOT STARTED]
- **Effort**: 8 hours
- **Dependencies**: None (all required infrastructure is sorry-free)
- **Research Inputs**: specs/273_chronicle_gap_contradiction_proof/reports/01_gap-contradiction-research.md, specs/273_chronicle_gap_contradiction_proof/reports/02_deep-analysis.md
- **Artifacts**: plans/01_z-interval-countermodel.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

This plan completes the sorry at `ReynoldsBridge.lean:489` (`countermodel_discrete_reynolds_v2`), providing an alternative discrete countermodel construction that completely bypasses the `chronicle_gap_contradiction` sorry chain.

### Why This Approach

Eight research agents exhaustively investigated proving `chronicle_gap_contradiction` directly. All approaches failed:

1. **Model surgery / gap_contradicts_prior**: Dead. `reynolds_model_surgery_core` proves all contemp_equiv classes are the entire carrier whenever Prior-UZ/SZ holds, making `h_bounded_above` unsatisfiable. The gap is invisible to monadic FO at every depth k.
2. **Z1 direct instantiation**: Dead. `G(Gψ→ψ)` is not a theorem (G is strict future). The standard Doets argument requires choosing a valuation encoding orbit membership — impossible in the MCS setting.
3. **ReynoldsBridge truth transfer**: The v2 approach bypasses chronicle_gap_contradiction entirely.
4. **Direct order-theoretic**: No order-theory-only argument works for countable subsets of Q.
5. **Construction-specific**: Z+Z consistent with all C0/C4/C5 conditions in constant-MCS case.
6. **Prior-UZ iteration**: Chains have no termination guarantee in Q.

**Root cause**: The distinction between Z1-validity (for ALL valuations → IsSuccArchimedean) and Z1-satisfaction (for ONE fixed valuation → no constraint). The chronicle gives the latter.

**The fix**: Don't prove IsSuccArchimedean for the chronicle domain. Build the countermodel directly on Z (which has IsSuccArchimedean for free) using the sorry-free `limitdom_is_good` + `truth_transfer` pipeline.

### Existing Sorry-Free Infrastructure

| Component | Location | Lines |
|-----------|----------|-------|
| `limitdom_is_good` | ReynoldsBridge.lean:343 | Chronicle domain k-equivalent to Z-interval |
| `limitdom_semantic_prior_UZ/SZ` | ReynoldsBridge.lean:244-326 | Prior-UZ/SZ for chronicle |
| `limitdom_root_neg_truth` | ReynoldsBridge.lean:429 | φ.neg temporally true at root |
| `effectiveFormula_id_self/neg` | ReynoldsBridge.lean:408-418 | Effective formula = identity on φ |
| `truth_transfer` | Transfer.lean:337 | Transfer temporal_truth across k-equiv structures |
| `zIntervalTaskFrame` | Transfer.lean:541 | TaskFrame on Z (WorldState=Unit) |
| `zIntervalHistory/Omega` | Transfer.lean:553-581 | Singleton history set, shift-closed |
| `zIntervalBox_transparent` | Transfer.lean:588 | Box quantification = identity |
| `z_interval_countermodel` | Transfer.lean:633 | Packaging lemma (needs TM + h_truth_corr) |
| `unboundedZIntervalEquiv` | Transfer.lean:518 | Z-interval carrier ≃o Z |
| Reynolds pipeline (Theorem 14) | GoodStructuresModelSurgery.lean | 2168 lines, sorry-free |
| `countermodel_discrete_reynolds` (active) | Transfer.lean:1203 | Current path (goes through sorry) |
| `completeness_discrete` | Completeness.lean:309 | Top-level theorem |

### The Sorry Chain Being Eliminated

```
completeness_discrete (Completeness.lean:309)
  → countermodel_discrete_reynolds (Transfer.lean:1203)
    → cantor_bfmcs_discrete_restricted_tc (ChronicleToCountermodel.lean:2037)
      → succ_embed_surjective (ChronicleToCountermodel.lean:1711)
        → limitDomSubtype_isSuccArchimedean
          → succ_cofinal → chronicle_gap_contradiction → sorry ← THE GAP
    → cantor_bfmcs_discrete_restricted_fuc (ChronicleToCountermodel.lean:2093)
      → succ_embed_surjective (same chain)
```

After this task: `completeness_discrete` calls `countermodel_discrete_reynolds_v2` instead, which goes through `limitdom_is_good` + `truth_transfer` (both sorry-free) and builds the countermodel on Z directly.

### Key Technical Obstacle: Box Semantics

The `z_interval_countermodel` (Transfer.lean:633) requires `h_truth_corr`: a proof that `truth_at` matches `temporal_truth` for all subformulas. The obstacle:

- `temporal_truth` treats box as an **opaque predicate lookup**: `temporal_truth(.box ψ) = Z.interp(atomMap(.box ψ)) t`
- `truth_at` treats box as **universal quantification**: `truth_at(.box ψ) = ∀ σ ∈ Omega, truth_at σ t ψ`
- With `zIntervalBox_transparent` (singleton Omega): `truth_at(.box ψ) = truth_at ψ`
- So `h_truth_corr` at box ψ requires: `truth_at ψ ↔ Z.interp(atomMap(.box ψ)) t`
- By IH: `truth_at ψ ↔ temporal_truth ψ`
- Need: `temporal_truth ψ ↔ Z.interp(atomMap(.box ψ)) t` — recursive eval vs predicate lookup

**Resolution**: The box predicate IS constant on the Z-interval (proven via the S5 box-uniformity of the chronicle BFMCS). And `zIntervalBox_transparent` makes truth_at(.box ψ) = truth_at(ψ). So we need: the constant box-predicate value equals temporal_truth(ψ) at every point. This holds because:
- On the chronicle: `.box ψ ∈ limit_f(t)` iff `ψ ∈ limit_f(s)` for all s (S5 single-class)
- The chronicle truth lemma: `temporal_truth ψ ↔ ψ ∈ limit_f(t)` for subformulas
- So `.box ψ ∈ limit_f(t)` iff `temporal_truth ψ` at all points (constant)
- By k-equivalence: the Z-interval preserves this relationship at sufficient depth

The proof strategy: prove `h_truth_corr` by induction on formula complexity, with the box case using the constant-box-predicate property inherited from the chronicle's S5 structure.

## Goals & Non-Goals

**Goals**:
- Complete the sorry at `ReynoldsBridge.lean:489`
- Make `completeness_discrete` sorry-free by wiring it to v2
- Eliminate dependency on `chronicle_gap_contradiction`, `succ_cofinal`, `limitDomSubtype_isSuccArchimedean`, `succ_embed_surjective`
- Ensure `lake build` succeeds with no sorry in the completeness chain
- Verify `#print axioms completeness_discrete` shows no `sorryAx`

**Non-Goals**:
- Proving `chronicle_gap_contradiction` (task 273 — remains blocked/separate)
- Modifying the dense completeness pipeline
- Refactoring the existing `countermodel_discrete_reynolds` (retained for compilation)
- Changing the `valid_discrete` definition or completeness theorem statement

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Box predicate constancy on Z-interval not provable at finite k | H | M | The S5 property gives constancy on the chronicle; k-equivalence at k ≥ 2 transfers it. Verify by checking `cantor_bfmcs_discrete_restricted_buc` (sorry-free) for the pattern. |
| Z-interval unboundedness proof blocked | M | L | NoMaxOrder/NoMinOrder on limitdom makes the depth-2 sentence "∃x.∀y.y≤x" false; k-equivalence at k≥2 transfers this to the Z-interval. |
| `truth_transfer` gives wrong atomMap or effective formula mismatch | M | L | `effectiveFormula_id_self/neg` already proved; use `mkAtomMapFwd` consistently. |
| Until/Since cases in h_truth_corr require witnesses outside the Z-interval carrier | M | L | Z-interval is unbounded (proved in Phase 1), so witnesses always exist within the carrier. |
| Wiring v2 into completeness_discrete breaks existing proofs | M | L | The change is a single call-site swap in Completeness.lean:369. Existing `countermodel_discrete_reynolds` remains for backward compatibility. |
| Proof exceeds estimated line count (>500 lines) | M | M | Factor helper lemmas into ReynoldsBridge.lean sections. The truth_corr induction is the largest component (~150 lines). |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |

---

### Phase 1: Z-Interval Unboundedness and Box Constancy [PARTIAL]

**Goal**: Prove the Z-interval extracted from `limitdom_is_good` is unbounded (`lo = none`, `hi = none`), and that box predicates are constant on it.

**Tasks**:
- [ ] Prove `limitdom_good_unbounded`: Given `good sig k M` where M is the limitdom structure with `NoMaxOrder` and `NoMinOrder`, the extracted `Z : ZIntervalStructure sig` has `Z.lo = none` and `Z.hi = none`. Proof: a bounded Z-interval has a maximum or minimum element. The sentence `∃x. ∀y. y ≤ x` has quantifier depth 2. Since k ≥ 2 (k = operator_depth(φ) + 2 ≥ 2) and k-equivalence preserves depth-k sentences, if the Z-interval had a maximum, the limitdom would too, contradicting `NoMaxOrder`. Similarly for minimum.
- [ ] Prove `limitdom_box_constant`: For any box formula `.box ψ` with `.box ψ ∈ φ.predFormulas`, the Z-interval predicate `Z.interp (mkAtomMapFwd φ (.box ψ))` is constant (same value at all points). Proof: on the chronicle, `cantor_bfmcs_discrete_restricted_buc` (sorry-free) establishes box uniformity. Box formulas have the same MCS membership at all chronicle points. The chronicle truth lemma gives `temporal_truth(.box ψ) ↔ .box ψ ∈ limit_f(t)` = constant. By k-equivalence, the Z-interval's box predicate matches at depth k, hence is also constant.
- [ ] Alternative for box constancy: prove directly from the Z-interval's k-equivalence to the chronicle that the box predicate at any two points agrees, using the `k_equiv_preserves_sentence` machinery for the depth-1 sentence `∀x. interp(box_pred)(x) ↔ interp(box_pred)(0)`.

**Timing**: 2 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/ReynoldsBridge.lean` — add lemmas after `limitdom_is_good` (line 367)

**Verification**:
- All new lemmas compile without sorry
- `lake build Bimodal.Metalogic.WeakCanonical.IntegerModel.ReynoldsBridge` succeeds

---

### Phase 2: TaskModel Construction and Truth Correspondence [PARTIAL]

**Goal**: Construct a `TaskModel zIntervalTaskFrame` from the Z-interval's predicate interpretation and prove `h_truth_corr` — the correspondence between `truth_at` and `temporal_truth`.

**Tasks**:
- [ ] Define `zIntervalTaskModel_v2`: a `TaskModel zIntervalTaskFrame` whose atom valuation is derived from the Z-interval. Since `zIntervalTaskFrame` has `WorldState = Unit`, the valuation `V : Unit → Atom → Prop` is constant in the world-state argument. Define `V () a := Z.interp (mkAtomMapFwd φ (.atom a)) (iso⁻¹ 0)` — the atom's truth at the origin. NOTE: This makes atoms constant, which means `h_truth_corr` at atoms requires `Z.interp(atomMap(.atom a)) t` to be constant too. This is NOT generally true for atoms (only for box predicates). See alternative below.
- [ ] **Alternative TaskModel (PREFERRED)**: Instead of using `zIntervalTaskFrame` (WorldState=Unit), build a position-dependent TaskModel. Define:
  ```
  zIntervalTaskFrame_v2 : TaskFrame Z where
    WorldState := Z
    task_rel w d u := u = w + d
    ...
  ```
  With `WorldState = Z` and deterministic time evolution, define:
  ```
  zIntervalTaskModel_v2 : TaskModel zIntervalTaskFrame_v2 where
    V w a := Z.interp (mkAtomMapFwd φ (.atom a)) (iso⁻¹ w)
  ```
  History: `states t _ := t` (state = current time). This makes atoms position-dependent, matching `temporal_truth` at atoms.
  
  **Box handling with WorldState = Z**: With deterministic task_rel and ShiftClosed Omega containing all time-shifted histories, `truth_at(.box ψ) = ∀ σ ∈ Omega, truth_at σ t ψ`. Time-shifted histories have `states t = t + Δ` for various offsets Δ. So box quantification ranges over all offsets. This makes `truth_at(.box ψ) = ∀ Δ : Z, truth_at(ψ) with shifted state`. For atoms: `V (t+Δ) a = Z.interp(atomMap(.atom a)) (t+Δ)` — evaluates at shifted position. So box at t = "ψ true at every position" = `∀ s, temporal_truth ψ s`.
  
  On the Z-interval, `temporal_truth(.box ψ) = Z.interp(atomMap(.box ψ)) t` (predicate lookup). By box constancy (Phase 1), this equals some constant c. And `∀ s, temporal_truth ψ s` is ALSO a constant (either all-true or exists-false). The proof needs: `Z.interp(atomMap(.box ψ)) t ↔ ∀ s, temporal_truth ψ s`. This is the S5 content: the box predicate encodes "ψ true everywhere."
  
  This requires an additional lemma: `box_pred_iff_forall_temporal_truth` — the box predicate on the Z-interval equals the universal temporal truth of the subformula.

- [ ] Prove `h_truth_corr`: For all formulas ψ with ψ ∈ subformulaClosure(φ) and all points t in the Z-interval:
  ```
  truth_at TM Omega σ (iso t) ψ ↔ temporal_truth (Z.toOrdered sig) (mkAtomMapFwd φ) t ψ
  ```
  By structural induction on ψ:
  - **Atom a**: `truth_at ... (.atom a) = V (states t _) a = Z.interp(atomMap(.atom a)) (states t) = Z.interp(atomMap(.atom a)) t` (when states = id). RHS: `temporal_truth(.atom a) = Z.interp(atomMap(.atom a)) t`. Direct equality. ✓
  - **Bot**: Both False. ✓
  - **Imp f₁ f₂**: By IH on f₁ and f₂. ✓
  - **Box f**: LHS = `∀ σ' ∈ Omega, truth_at σ' t f`. By IH (for each shifted σ'), this equals `∀ Δ, temporal_truth f (t + Δ)`, which equals `∀ s, temporal_truth f s` (substituting s = t + Δ). RHS = `temporal_truth(.box f) = Z.interp(atomMap(.box f)) t`. By `box_pred_iff_forall_temporal_truth`: `Z.interp(atomMap(.box f)) t ↔ ∀ s, temporal_truth f s`. ✓
  - **Until f₁ f₂**: LHS = `∃ s > t, truth_at σ s f₁ ∧ ∀ r, t < r < s → truth_at σ r f₂`. The history domain is `fun _ => True` (all of Z), so domain conditions are trivially satisfied. By IH: this equals `∃ s > t, temporal_truth f₁ s ∧ ∀ r, t < r < s → temporal_truth f₂ r`. RHS = temporal_truth of Until. These match by definition. ✓
  - **Since f₁ f₂**: Symmetric to Until. ✓

- [ ] Handle the ShiftClosed Omega construction for `zIntervalTaskFrame_v2`. Need to define the set of all time-shifted histories and prove shift-closure. With deterministic task_rel, each history is determined by its "base state" w₀, with states t = w₀ + t. The shift by Δ produces a history with base state w₀ + Δ. Omega = {all histories with any base state} is shift-closed.

**Timing**: 3 hours

**Depends on**: Phase 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/ReynoldsBridge.lean` — add TaskModel, truth_corr proof

**Verification**:
- `h_truth_corr` compiles without sorry
- `lake build Bimodal.Metalogic.WeakCanonical.IntegerModel.ReynoldsBridge` succeeds

---

### Phase 3: Complete countermodel_discrete_reynolds_v2 [NOT STARTED]

**Goal**: Assemble the full countermodel from Phases 1-2 and fill the sorry at ReynoldsBridge.lean:489.

**Tasks**:
- [ ] Chain the pipeline:
  1. `limitdom_is_good` → `⟨Z, h_k_equiv⟩` (Z-interval + k-equivalence)
  2. `limitdom_good_unbounded` → `h_lo : Z.lo = none`, `h_hi : Z.hi = none`
  3. `limitdom_root_neg_truth` → `h_root : temporal_truth M atomMap_fwd root φ.neg`
  4. `truth_transfer` with `h_k_equiv`, `φ.neg`, depth bound → `⟨s, h_neg_truth⟩ : ∃ s, temporal_truth Z.toOrdered atomMap_fwd s φ.neg`
  5. Construct `TM : TaskModel zIntervalTaskFrame_v2` from Phase 2
  6. Construct `Omega` and prove `ShiftClosed Omega` from Phase 2
  7. Apply `h_truth_corr` to convert `temporal_truth` of φ.neg to `¬truth_at` of φ
  8. Package the existential: `⟨Z, ..., SuccOrder Z, ..., IsSuccArchimedean Z, ..., TM, Omega, σ, t, ¬truth_at φ⟩`

- [ ] Verify the depth bound: `operator_depth φ.neg + 1 ≤ k`. We have `k = operator_depth φ + 2` and `operator_depth φ.neg = operator_depth φ`, so `operator_depth φ + 1 ≤ operator_depth φ + 2`. ✓

- [ ] Verify the return type matches `countermodel_discrete_reynolds_v2`'s signature (lines 467-472): needs `AddCommGroup D`, `LinearOrder D`, `IsOrderedAddMonoid D`, `Nontrivial D`, `SuccOrder D`, `PredOrder D`, `IsSuccArchimedean D`, `IsPredArchimedean D`. With `D = Z`, all are Mathlib instances: `Int.instAddCommGroup`, `Int.instLinearOrder`, `Int.instSuccOrder`, `Int.instIsSuccArchimedean`, etc.

- [ ] Ensure `effectiveFormula_id_neg` is used correctly: truth_transfer works with `mkAtomMapFwd φ` as atomMap. The effective formula of φ.neg equals φ.neg by `effectiveFormula_id_neg`. So temporal_truth of the effective formula = temporal_truth of φ.neg.

**Timing**: 1.5 hours

**Depends on**: Phase 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/ReynoldsBridge.lean` — replace sorry at line 489

**Verification**:
- `countermodel_discrete_reynolds_v2` compiles without sorry
- `lake build Bimodal.Metalogic.WeakCanonical.IntegerModel.ReynoldsBridge` succeeds with no sorry

---

### Phase 4: Wire into completeness_discrete and Verify [NOT STARTED]

**Goal**: Replace the call to `countermodel_discrete_reynolds` with `countermodel_discrete_reynolds_v2` in `completeness_discrete`, verify the full build, and audit axioms.

**Tasks**:
- [ ] In `Completeness.lean:369`, change:
  ```lean
  -- OLD:
  Bimodal.Metalogic.WeakCanonical.countermodel_discrete_reynolds
    M hM_mcs φ h_neg_in h_box_discrete
  -- NEW:
  Bimodal.Metalogic.WeakCanonical.countermodel_discrete_reynolds_v2
    M hM_mcs φ h_neg_in h_box_discrete
  ```
  Note: Both theorems have compatible signatures (same hypotheses and existential return type).

- [ ] Run `lake build` for the full project.

- [ ] Run `#print axioms completeness_discrete` and verify `sorryAx` is absent.

- [ ] Verify the sorry chain is fully bypassed: `chronicle_gap_contradiction`, `succ_cofinal`, `limitDomSubtype_isSuccArchimedean`, `succ_embed_surjective` should NOT appear in `#print axioms completeness_discrete`.

- [ ] Update docstrings:
  - `ReynoldsBridge.lean` header: document that v2 is now the active path
  - `countermodel_discrete_reynolds_v2` docstring: remove "sorry" references
  - `Transfer.lean:1201` comment: update to note v2 is preferred

- [ ] Verify existing tests in `Tests/BimodalTest/` continue to pass.

- [ ] Grep verification: `grep -rn "sorry" Theories/ --include="*.lean"` — ensure no NEW sorry introduced (existing dead-code sorries in `succ_reaches_dom_N`, `chronicle_gap_contradiction` remain but are off the critical path).

**Timing**: 1.5 hours

**Depends on**: Phase 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` — swap call site (line 369)
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/ReynoldsBridge.lean` — docstring updates

**Verification**:
- `lake build` succeeds for the full project
- `#print axioms Bimodal.Metalogic.BXCanonical.completeness_discrete` does not include `sorryAx`
- No new sorry introduced
- Existing tests pass

## Testing & Validation

- [ ] `lake build` completes without errors
- [ ] `#print axioms Bimodal.Metalogic.BXCanonical.completeness_discrete` shows only `[propext, Classical.choice, Lean.ofReduceBool, Lean.trustCompiler, Quot.sound]` (no `sorryAx`)
- [ ] Existing tests in `Tests/BimodalTest/` continue to pass
- [ ] No new `sorry` introduced: `grep -rn "sorry" Theories/ --include="*.lean" | grep -v "sorryAx\|sorry_in\|sorry_free\|-- sorry\|block comment\|dead code"` shows no unexpected sorry
- [ ] The dead code sorries in `chronicle_gap_contradiction`, `succ_reaches_dom_N` do not affect `#print axioms completeness_discrete`
- [ ] Import graph remains acyclic

## Artifacts & Outputs

- `specs/281_z_interval_countermodel_v2/plans/01_z-interval-countermodel.md` (this file)
- Modified `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/ReynoldsBridge.lean` (v2 completion + helpers)
- Modified `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` (call site swap)
- `specs/281_z_interval_countermodel_v2/summaries/01_z-interval-countermodel-summary.md`

## Rollback/Contingency

- If the box constancy proof (Phase 1) is blocked: try proving `h_truth_corr` only for box-free subformulas of φ, then handle box cases via a separate MCS-level argument using `cantor_bfmcs_discrete_restricted_buc` directly.
- If `zIntervalTaskFrame_v2` (position-dependent WorldState) creates ShiftClosed issues: fall back to `zIntervalTaskFrame` (WorldState=Unit) and restrict the truth correspondence to formulas where atom predicates happen to be constant (leveraging the specific Z-interval structure).
- If the truth_corr induction has unforeseen cases: factor the proof into a separate helper file `ZIntervalTruthCorrespondence.lean` to isolate complexity.
- If wiring v2 into completeness_discrete reveals type mismatches: verify the existential package matches exactly by comparing the `obtain` pattern at Completeness.lean:368.
- Git revert to the commit before implementation if any phase introduces regressions.
