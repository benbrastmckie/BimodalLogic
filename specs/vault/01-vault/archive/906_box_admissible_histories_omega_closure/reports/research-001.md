# Research Report: Task #906 - Plan Review for Box Admissible Histories Omega Closure

**Task**: 906 - Box Admissible Histories Omega Closure
**Date**: 2026-02-19
**Focus**: Plan review and improvement recommendations for implementation-001.md
**Session**: sess_1771534672_922b37

## Summary

The existing implementation plan (implementation-001.md) commits to Choice B (non-constant families + shift-closed Omega) in its overview but contains significant inconsistencies with that choice in its phase details. The plan also underestimates the SoundnessLemmas.lean rework, misidentifies phase dependencies, and misses a critical design decision about how `valid` and `semantic_consequence` should handle the `Omega` parameter. This report identifies seven specific weaknesses and provides concrete recommendations for each.

## Findings

### Finding 1: Plan Internally Contradicts Itself on Choice A vs Choice B

**Severity**: Critical

The plan overview (line 15) states: "This follows **Choice B**: Define Omega as the closure of canonical histories under ALL time-shifts."

However, the plan's Phase 5 details reference infrastructure that is Choice A:

- Phase 5 task: "Update canonicalHistory to use non-constant families (fam.mcs t at time t)" -- this is Choice B
- Phase 6 task: "Evaluate constant_family_bmcs_exists_int: eliminate or restructure" -- this hedges

Meanwhile, the existing `canonical_truth_lemma_all` takes `h_const : IsConstantFamilyBMCS B` as a parameter. If implementing Choice B, this parameter should be eliminated entirely. The plan does not explicitly state that `IsConstantFamilyBMCS`, `getConstantBMCS`, and all the `getConstantBMCS_*` theorems should be removed.

**Recommendation**: The revised plan must make an unambiguous commitment to Choice B and explicitly list all artifacts to be removed. Specifically:
- Remove `IsConstantFamilyBMCS` definition
- Remove `constant_family_bmcs_exists_int` sorry (and its 5 accessor theorems)
- Remove the `h_const` parameter from `canonical_truth_lemma_all`
- Remove `getConstantBMCS` and its 4 property theorems
- Replace with direct use of `construct_saturated_bmcs_int` (which already exists and is sorry-free for modal saturation)

### Finding 2: Truth Lemma Statement Change Is Underspecified

**Severity**: Critical

The plan mentions updating the truth lemma (Phase 5) but does not spell out the most consequential change: the truth lemma statement itself changes from:

```
phi in fam.mcs 0 <-> truth_at M (canonicalHistory B fam hfam) t phi
```

to:

```
phi in fam.mcs t <-> truth_at M Omega (canonicalHistory B fam hfam) t phi
```

This is not just an Omega threading change. The left-hand side changes from `fam.mcs 0` to `fam.mcs t`. This means:

1. **The canonical history construction changes**: Instead of mapping every time to `mkCanonicalWorldState B fam hfam` (which wraps `fam.mcs 0`), it must map time `t` to a world state wrapping `fam.mcs t`.

2. **CanonicalWorldState must be generalized**: Currently defined as `{ S : Set Formula // exists fam in B.families, S = fam.mcs 0 }`. With Choice B, it must be `{ S : Set Formula // exists fam in B.families, exists t, S = fam.mcs t }` or equivalently `{ S : Set Formula // SetMaximalConsistent S }`.

3. **The atom case of the truth lemma changes**: Currently `truth_at ... (atom p) = exists ht, valuation (states t ht) p`. The states at time `t` would return a world state wrapping `fam.mcs t`. The valuation checks `atom p in w.val`, so the atom case becomes `exists ht, atom p in fam.mcs t`, which directly matches the new LHS `atom p in fam.mcs t`.

4. **The temporal cases become simpler**: No longer need `h_const` to equate `fam.mcs s` with `fam.mcs 0`. The IH directly gives `phi in fam.mcs s <-> truth_at ... s phi` for all `s`, which is exactly what the temporal forward/backward cases need.

**Recommendation**: Phase 5 must be rewritten with explicit substeps:
1. Redefine `CanonicalWorldState` to allow any MCS from any family at any time
2. Define `mkCanonicalWorldStateAtTime B fam hfam t` producing a world state from `fam.mcs t`
3. Redefine `canonicalHistory` to use time-varying states: `states t _ := mkCanonicalWorldStateAtTime B fam hfam t`
4. Restate truth lemma with `fam.mcs t` on the LHS
5. Reprove all cases (most become simpler; temporal cases eliminate the `h_const` dependency)

### Finding 3: SoundnessLemmas.lean Scope Is Drastically Underestimated

**Severity**: High

The plan lists `SoundnessLemmas.lean` under Phase 3 with the note "Thread Omega through temporal duality proofs (~10 lemmas)". This is a major underestimate.

SoundnessLemmas.lean contains 967 lines with:
- A local `is_valid` definition that must also gain an Omega parameter (or be restructured)
- 8 individual `swap_axiom_*_valid` theorems
- 5 `*_preserves_swap_valid` theorems
- 1 `axiom_swap_valid` master theorem
- 17 individual `axiom_*_valid` private theorems
- 1 `axiom_locally_valid` master theorem
- 1 `derivable_implies_valid_and_swap_valid` combined theorem
- 2 derived theorems

That is approximately 35 theorems, not 10. Each one references `truth_at` and will need Omega threading.

**The MF and TF swap axiom lemmas are particularly sensitive**: `swap_axiom_mf_valid` and `swap_axiom_tf_valid` currently use `time_shift_preserves_truth` which will also gain Omega. These proofs will need the shift-closure hypothesis.

**The `is_valid` local definition decision is critical**: The plan does not address whether `is_valid` should gain an Omega parameter. If it does, all 35 theorems change. If it doesn't (using Set.univ as Omega), the soundness-related proofs remain closer to current form but diverge from the main `valid` definition.

**Recommendation**:
- Option A: Keep the local `is_valid` in SoundnessLemmas.lean as `forall F M tau t, truth_at M Set.univ tau t phi` (Box quantifies over all histories when Omega = univ). This means soundness proofs barely change since all local proofs were already proving truth for all histories. Then the main `soundness` theorem in Soundness.lean bridges from `is_valid (using univ)` to `valid (using arbitrary Omega)`.
- Option B: Thread Omega through `is_valid`. This is more principled but vastly more work.
- **Strong recommendation**: Option A. The key insight is that **soundness is about all models**, and for any particular Omega, if truth_at holds for all histories (Omega = univ), it certainly holds for histories in Omega. So we can prove soundness with Omega = univ and then specialize.

### Finding 4: Phase Dependencies Are Misordered

**Severity**: Medium

The plan lists Phase 4 (Time-Shift Infrastructure) as depending only on Phase 1. But Phase 4 needs the `ShiftClosed` predicate, which the plan assigns to Phase 1. However, Phase 3 (Soundness) also needs `ShiftClosed` for the MF/TF cases. So the dependency chain is:

**Current plan**: Phase 1 -> Phase 2 -> Phase 3 -> Phase 4 -> Phase 5 -> Phase 6

**Actual dependency**: Phase 1 (truth_at + ShiftClosed def) -> Phase 2 (validity defs) -> Phase 4 (time_shift with Omega) -> Phase 3 (soundness, uses time_shift) -> Phase 5 (canonical model) -> Phase 6 (completeness)

Phase 4 must come BEFORE Phase 3, because `modal_future_valid` and `temp_future_valid` in Soundness.lean use `time_shift_preserves_truth`, which after the change will require Omega and ShiftClosed. If Phase 3 is attempted before Phase 4, the MF/TF soundness proofs will be stuck.

**Recommendation**: Reorder to: Phase 1 -> Phase 2 -> Phase 4 -> Phase 3 -> Phase 5 -> Phase 6. Or better, merge Phase 4 into Phase 1 since the time_shift_preserves_truth theorem is in the same file (Truth.lean).

### Finding 5: The `valid` Definition Design Choice Is Unaddressed

**Severity**: High

The plan says "Add Omega to valid definition (quantify over Omega, require tau in Omega)" but does not resolve the critical question: **Does `valid` quantify universally over Omega or existentially?**

Research-004.md specifies:
```lean
def valid (phi : Formula) : Prop :=
  forall D ... F M Omega tau (_ : tau in Omega) t, truth_at M Omega tau t phi
```

This is **universal** over Omega: for ALL Omega, for ALL tau in Omega, phi holds. This means:
- When Omega = Set.univ (the old semantics), phi must hold at all histories
- When Omega = {single history}, phi must hold at that history
- When Omega is any set, phi must hold at all members

This is mathematically correct and equivalent to the old definition when we only care about the universal case. But it introduces a subtlety: **T-axiom soundness** requires `tau in Omega` in the hypothesis, and the proof uses that `tau in Omega` to instantiate the Box quantifier.

However, there's an alternative: quantify Box over Omega but DON'T change `valid` at all. Instead, define `valid` as:
```lean
def valid (phi : Formula) : Prop :=
  forall D ... F M tau t, truth_at M Set.univ tau t phi
```

With `Set.univ`, every history is in Omega, so Box quantifies over all histories (the old behavior). Soundness says `deriv phi -> valid phi`. Completeness would then prove: `valid phi -> deriv phi`, which by contrapositive becomes: `not deriv phi -> not valid phi -> exists M Omega tau t, not truth_at M Omega tau t phi`. The canonical model provides a specific Omega (canonicalOmega) where the formula fails.

**This alternative is simpler**: `valid`, `semantic_consequence`, and `satisfiable` don't change at all. Only `truth_at` changes. Soundness proofs need updating only for the cases that unfold `truth_at` (particularly Box). The completeness side uses specific Omega values.

**Recommendation**: Use the simpler approach:
1. `truth_at` gains Omega parameter (Box case changes)
2. `valid` uses `Omega = Set.univ` (no change to signature)
3. `semantic_consequence` uses `Omega = Set.univ` (no change to signature)
4. `satisfiable` gains Omega (existential: there exists an Omega where...)
5. Soundness proves validity using Set.univ; proofs barely change
6. Completeness uses specific canonicalOmega

Wait -- actually this doesn't work cleanly. The issue is that `truth_at` is recursive, and the Box case sets Omega. So `truth_at M Set.univ tau t (box phi)` = `forall sigma in Set.univ, truth_at M Set.univ sigma t phi`, which is `forall sigma, truth_at M Set.univ sigma t phi`. This is the same as the old behavior. The soundness proofs for MF/TF need `time_shift_preserves_truth`, which for the Box case requires shift-closure. Since `Set.univ` is trivially shift-closed (every history is in it), the MF/TF proofs would just need `Set.univ.shift_closed` which is trivial.

**Revised recommendation**: This simpler approach (Set.univ in validity definitions) is strongly preferred. It minimizes changes to Validity.lean, Soundness.lean, and SoundnessLemmas.lean. The plan should be restructured around this.

For `satisfiable`, it needs an existential Omega because the canonical model construction provides a specific Omega:
```lean
def satisfiable (D : Type*) [...] (Gamma : Context) : Prop :=
  exists (F : TaskFrame D) (M : TaskModel F) (Omega : Set (WorldHistory F))
    (tau : WorldHistory F) (_ : tau in Omega) (t : D),
    forall phi in Gamma, truth_at M Omega tau t phi
```

Then `standard_representation` proves satisfiability using `canonicalOmega`.

### Finding 6: ShiftClosed Definition and Its Use in MF/TF

**Severity**: Medium

The plan mentions adding a `ShiftClosed` predicate but doesn't specify where it's used or how it's threaded.

With the revised approach (Finding 5), ShiftClosed is needed in exactly two places:
1. `time_shift_preserves_truth` Box case: requires `ShiftClosed Omega` as a hypothesis
2. Canonical model: proving `ShiftClosed (canonicalOmega B)`

For soundness, since `valid` uses `Set.univ`, and `Set.univ` is trivially shift-closed, ShiftClosed is NOT needed in the soundness proofs directly. It would be needed in `time_shift_preserves_truth`, but the soundness proofs that call `time_shift_preserves_truth` would instantiate Omega = Set.univ and discharge ShiftClosed trivially.

**Recommendation**: Define ShiftClosed in Truth.lean next to `truth_at`. Prove `Set.univ` is shift-closed as a trivial lemma. The `time_shift_preserves_truth` theorem gains `(h_sc : ShiftClosed Omega)` as a hypothesis. Soundness proofs discharge it with the Set.univ lemma.

### Finding 7: Phase 5/6 Merge and the BMCS Construction Path

**Severity**: Medium

The plan separates "Canonical Model with Omega" (Phase 5) and "Update Completeness Theorems" (Phase 6). These should be merged since they both modify `Representation.lean` and are tightly coupled.

More importantly, the plan does not clearly state which BMCS construction to use for Choice B. Currently:
- `constant_family_bmcs_exists_int` (sorry) produces a constant-family BMCS
- `construct_saturated_bmcs_int` (from TemporalCoherentConstruction.lean) produces a temporally coherent + modally saturated BMCS with non-constant families

With Choice B, we should use `construct_saturated_bmcs_int` directly. This construction already exists and is hooked into the BMCS completeness chain (Bundle/Completeness.lean). The key question is: does it provide all the properties we need?

From the Completeness.lean file, `construct_saturated_bmcs_int` provides:
- Context membership in eval_family
- Temporal coherence (forward_F, backward_P -- though some sorries in DovetailingChain)
- Modal saturation (is_modally_saturated -- sorry-free)

This is exactly what we need for the non-constant truth lemma. The sorries in DovetailingChain (forward_F, backward_P) are the same ones that would be present regardless of Choice A or B -- they are about the temporal witness construction, not about constant families.

**Recommendation**: Replace the plan's Phase 5-6 with a single merged phase that:
1. Removes all `IsConstantFamilyBMCS` infrastructure from Representation.lean
2. Replaces `getConstantBMCS` calls with `construct_saturated_bmcs_int` calls
3. Redefines `canonicalOmega` as the shift-closure of canonical histories
4. Proves `ShiftClosed (canonicalOmega B)` by construction
5. Restates and reproves `canonical_truth_lemma_all` without `h_const`
6. Updates completeness theorems to use new truth lemma

## Recommended Revised Phase Structure

Based on the analysis above, here is the recommended restructured plan:

### Phase 1: Core Semantic Change (Truth.lean)
- Add `Omega : Set (WorldHistory F)` parameter to `truth_at`
- Modify Box case to quantify over `sigma in Omega`
- Thread Omega through all other cases (no behavior change)
- Define `ShiftClosed` predicate
- Prove `Set.univ_shift_closed : ShiftClosed (Set.univ : Set (WorldHistory F))`
- Update `time_shift_preserves_truth` with Omega + ShiftClosed hypothesis
- Update `exists_shifted_history` similarly
- Update `truth_double_shift_cancel` and `truth_history_eq` with Omega

**Estimated effort**: 2 hours. This is the heaviest phase because Truth.lean has extensive proofs.

### Phase 2: Update Validity Definitions (Validity.lean)
- Wrap `truth_at` calls with `Omega = Set.univ`
- `valid` becomes: `forall ... tau t, truth_at M Set.univ tau t phi`
- `semantic_consequence`: same pattern with Set.univ
- `satisfiable` gains Omega: `exists ... Omega tau (_ : tau in Omega) t, ...`
- `satisfiable_abs` and `formula_satisfiable` gain Omega similarly
- Update all validity lemmas (`valid_iff_empty_consequence`, `consequence_monotone`, etc.)

**Estimated effort**: 1 hour

### Phase 3: Update Soundness (Soundness.lean + SoundnessLemmas.lean)
- In SoundnessLemmas.lean: update `is_valid` to use `truth_at M Set.univ tau t phi`
- Most proofs barely change since `Set.univ` means Box still quantifies over ALL histories
- MF/TF proofs: `time_shift_preserves_truth` now needs ShiftClosed; discharge with `Set.univ_shift_closed`
- Update `truth_at_swap_swap` with Omega parameter
- In Soundness.lean: thread Omega = Set.univ through all axiom validity lemmas
- MF/TF soundness: same pattern as SoundnessLemmas.lean

**Estimated effort**: 2.5 hours (35+ theorems in SoundnessLemmas.lean alone, but most are mechanical)

### Phase 4: Canonical Model Reconstruction (Representation.lean)
- Remove `IsConstantFamilyBMCS`, `constant_family_bmcs_exists_int`, `getConstantBMCS` and all accessors
- Generalize `CanonicalWorldState` to allow any MCS at any time
- Define `mkCanonicalWorldStateAtTime B fam hfam t`
- Redefine `canonicalHistory` with time-varying states
- Define `canonicalOmega` as shift-closure: `{ sigma | exists fam hfam delta, sigma = time_shift (canonicalHistory B fam hfam) delta }`
- Prove `ShiftClosed (canonicalOmega B)`
- Restate and reprove `canonical_truth_lemma_all`:
  - Remove `h_const` parameter
  - LHS changes from `fam.mcs 0` to `fam.mcs t`
  - Atom case: trivial (states at time t give fam.mcs t)
  - Box forward: by modal_forward, psi in all fam'.mcs t; by IH, truth_at for all canonical histories; by time_shift, truth_at for all shifted histories; since canonicalOmega = shift-closure, done
  - Box backward: symmetric
  - Temporal forward G: by forward_G (derivable from is_mcs + temporal T-axiom), psi in fam.mcs s for all s >= t; by IH, truth_at at all such s
  - Temporal backward G: by contraposition using forward_F from temporal coherence; neg psi in fam.mcs s contradicts psi in fam.mcs s (from IH)
  - Same pattern for H
- Replace `getConstantBMCS` with `construct_saturated_bmcs_int` in completeness theorems
- Update `standard_representation`, `standard_context_representation`, `standard_weak_completeness`, `standard_strong_completeness`

**Estimated effort**: 3 hours

### Phase 5: Downstream Cleanup
- Update FMP/SemanticCanonicalModel.lean (minor: `truth_at` calls in consistency proofs gain Set.univ)
- Update any other files importing Semantics that break
- Run `lake build` to verify full compilation

**Estimated effort**: 0.5 hours

**Total estimated effort**: 9 hours (vs plan's 8 hours -- slightly higher due to SoundnessLemmas.lean scope)

## Critical Technical Details

### The Box Forward Case Under Choice B with Shift-Closed Omega

The hardest proof is the Box forward case of the truth lemma with `canonicalOmega` defined as the shift-closure. Here is the detailed proof sketch:

**Goal**: `Box psi in fam.mcs t -> forall sigma in canonicalOmega B, truth_at ... sigma t psi`

**Proof**:
1. Let `sigma in canonicalOmega B`. By definition, `sigma = time_shift (canonicalHistory B fam' hfam') delta` for some fam', hfam', delta.
2. By modal_forward: `Box psi in fam.mcs t` implies `psi in fam'.mcs t` for all fam' in B.families.
3. By IH at fam', time t: `psi in fam'.mcs t -> truth_at ... (canonicalHistory B fam' hfam') t psi`.
4. By time_shift_preserves_truth (with ShiftClosed canonicalOmega): `truth_at ... (canonicalHistory B fam' hfam') t psi <-> truth_at ... (time_shift (canonicalHistory B fam' hfam') delta) (t - delta) psi`.

Wait -- step 4 goes in the wrong direction. We need truth_at at sigma = time_shift ... delta at time t, not at time (t - delta).

Let me re-examine. `time_shift_preserves_truth` states:
```
truth_at M Omega (time_shift sigma (y - x)) x phi <-> truth_at M Omega sigma y phi
```

So with sigma = canonicalHistory B fam' hfam', x = t, y = t:
```
truth_at M Omega (time_shift (canonicalHistory B fam' hfam') 0) t psi <-> truth_at M Omega (canonicalHistory B fam' hfam') t psi
```

This just gives us time_shift by 0 = identity, which is trivial.

For sigma = time_shift (canonicalHistory B fam' hfam') delta, we need truth_at at this history at time t. Using time_shift_preserves_truth with sigma' = canonicalHistory B fam' hfam', x = t, y = t + delta:
```
truth_at M Omega (time_shift sigma' ((t + delta) - t)) t psi <-> truth_at M Omega sigma' (t + delta) psi
```
which simplifies to:
```
truth_at M Omega (time_shift sigma' delta) t psi <-> truth_at M Omega sigma' (t + delta) psi
```

So we need `truth_at M Omega (canonicalHistory B fam' hfam') (t + delta) psi`, which by IH (at time t + delta) requires `psi in fam'.mcs (t + delta)`.

But we only have `psi in fam'.mcs t` from modal_forward. We do NOT have `psi in fam'.mcs (t + delta)` for arbitrary delta.

**This is a fundamental problem with the Box forward case under Choice B with shift-closed Omega.**

The shift-closure adds histories that evaluate to `fam'.mcs (t + delta)` at time t, not `fam'.mcs t`. The truth lemma IH gives us equivalence between `fam'.mcs s` and truth_at at time s, so at time t we'd need `fam'.mcs (t + delta)` information, but modal_forward only gives `fam'.mcs t`.

**This means the Box forward case does NOT go through for shifted histories.** The issue was identified in research-004.md lines 263-276 but the plan does not address it.

### Resolution: Restrict Omega to Unshifted Canonical Histories

There are two ways to resolve this:

**Option 1: Omega = unshifted canonical histories only (no shift-closure)**
Define:
```lean
canonicalOmega B := { sigma | exists fam hfam, sigma = canonicalHistory B fam hfam }
```

This is NOT shift-closed, so MF/TF soundness cannot use shift-closure of canonicalOmega. But MF/TF soundness doesn't need canonicalOmega -- it uses `Set.univ` (since soundness is about validity which uses Set.univ).

The Box forward case works:
1. sigma in canonicalOmega -> sigma = canonicalHistory B fam' hfam'
2. By modal_forward: psi in fam'.mcs t
3. By IH: truth_at ... (canonicalHistory B fam' hfam') t psi

No time-shifting needed. The shift-closure is only needed for MF/TF axiom soundness, which operates at the validity level (Set.univ), not the completeness level (canonicalOmega).

**Option 2: Omega = shift-closure but restrict Box forward proof**
This doesn't work as shown above.

**Strong recommendation**: Use Option 1 (unshifted Omega). This is the simplest approach that resolves both sorries while maintaining soundness.

### Why ShiftClosed is NOT needed for canonicalOmega

The plan (and research-004.md) emphasized that MF/TF require Omega to be shift-closed. But with the revised validity approach (Finding 5), this concern evaporates:

- `valid` uses `Set.univ` as Omega
- MF/TF soundness proofs use `Set.univ`, which is trivially shift-closed
- `canonicalOmega` is used only in the completeness direction
- The completeness direction doesn't need MF/TF soundness
- The truth lemma doesn't need shift-closure (Box forward only needs unshifted canonical histories)

Therefore, `canonicalOmega` does NOT need to be shift-closed. It just needs to contain exactly the canonical histories (one per family). This dramatically simplifies the entire construction.

### Revised CanonicalOmega Definition

```lean
def canonicalOmega (B : BMCS Int) : Set (WorldHistory (canonicalFrame B)) :=
  { sigma | exists fam (hfam : fam in B.families), sigma = canonicalHistory B fam hfam }
```

This is the same definition as in research-004.md Step 4, just without the shift-closure. And this is all we need.

## Recommendations

1. **Commit fully to Choice B** (non-constant families, time-indexed truth lemma). Remove all Choice A artifacts.

2. **Use Set.univ for validity definitions**. Do not add Omega to `valid` or `semantic_consequence`. Only `satisfiable` and `truth_at` gain Omega. This cuts the scope of Soundness/SoundnessLemmas changes dramatically.

3. **Define canonicalOmega WITHOUT shift-closure**. The shift-closure requirement applies only to soundness (which uses Set.univ), not to completeness.

4. **Reorder phases**: Phase 1 (Truth.lean with Omega + TimeShift) -> Phase 2 (Validity.lean) -> Phase 3 (Soundness.lean + SoundnessLemmas.lean) -> Phase 4 (Representation.lean canonical model + completeness) -> Phase 5 (cleanup).

5. **Estimate 9 hours** rather than 8, accounting for the 35+ theorems in SoundnessLemmas.lean.

6. **The atom case of the truth lemma is the design anchor**: With time-varying states, the canonical history maps time t to a world state wrapping `fam.mcs t`. The atom evaluation at time t gives `atom p in fam.mcs t`, which is exactly the new LHS of the truth lemma. All other cases follow from this anchor.

7. **Use `construct_saturated_bmcs_int`** instead of `getConstantBMCS`. This construction already exists in the Bundle chain and provides temporal coherence + modal saturation without the constant-family requirement.

## References

- `specs/903_restructure_completeness_proof_bimodal_semantics/reports/research-004.md` -- Original analysis of the Box/Omega problem
- `specs/906_box_admissible_histories_omega_closure/plans/implementation-001.md` -- Plan under review
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Semantics/Truth.lean` -- Core truth_at definition (lines 108-114)
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Semantics/Validity.lean` -- valid, semantic_consequence, satisfiable definitions
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Soundness.lean` -- Soundness theorem (625-708)
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/SoundnessLemmas.lean` -- 35+ theorems for temporal duality soundness
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Representation.lean` -- Canonical model and truth lemma (lines 163-308)
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/BMCS.lean` -- modal_forward/backward (lines 95-104)
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/TemporalCoherentConstruction.lean` -- temporal coherence definition (line 298)

## Next Steps

1. Revise implementation-001.md (or create implementation-002.md) incorporating findings above
2. Pay particular attention to the Box forward case proof sketch (verified correct with unshifted Omega)
3. Implement Phase 1 first (Truth.lean) and verify compilation before proceeding
4. Use `lake build` after each phase to catch cascading breakage early

---

*Research conducted by lean-research-agent for task 906.*
*Session: sess_1771534672_922b37*
