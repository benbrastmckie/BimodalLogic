# Implementation Plan: Task #155 (Revised v52)

- **Task**: 155 - Close countermodel_discrete_reynolds sorry and rewire completeness_discrete
- **Status**: [NOT STARTED]
- **Effort**: 6 hours
- **Dependencies**: None (import cycle already resolved; chronicle_is_good_direct already sorry-free)
- **Research Inputs**: specs/155_reynolds_pipeline_activation/reports/50_import-cycle-research.md, team research (Z+Z counterexample, corrected mathematical path), phase-1-handoff-20260601T180000Z.md (blocker analysis)
- **Artifacts**: plans/52_implementation-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Close the sole remaining sorry at `countermodel_discrete_reynolds` (Transfer.lean:1289) and rewire `completeness_discrete` (Completeness.lean:369) to use the Reynolds pipeline instead of the BX pipeline. The entire Reynolds pipeline upstream of this sorry is already proven: chronicle extraction, model surgery (Thm 14), one_class, very_good, good, k-equivalence transfer, and chronicle truth lemma are all sorry-free. The only gap is the final step: packaging the Z-interval as a `TaskFrame Int` countermodel.

### Research Integration

Key findings that drive this revision:

1. **The IsSuccArchimedean approach is abandoned.** Plans v50 and v51 attempted to prove `chronicle_gap_contradiction` via `gap_contradicts_prior` and `no_boundary_at_successor`, which requires proving IsSuccArchimedean. The Z+Z counterexample proves one_class does NOT imply IsSuccArchimedean, making this entire line impossible.

2. **The Reynolds pipeline is already sorry-free except for packaging.** `chronicle_is_good_direct` (ShiftAndGlue.lean:950) proves `good sig k M_struct` without any sorry. The `truth_transfer` theorem transfers neg-phi truth to the Z-interval. The only gap is Step 8 of `countermodel_discrete_reynolds`: constructing `TM : TaskModel zIntervalTaskFrame` and proving `h_truth_corr`.

3. **The packaging problem has a known solution.** The current `zIntervalTaskFrame` uses `WorldState = Unit`, making atom truth position-independent. The fix: use position-dependent world states where each time position carries its predicate profile from the Z-interval. The valuation reads from this profile. ShiftClosed holds because shifting the history shifts the predicate profiles coherently.

4. **Two sub-problems must be solved.** (a) The `good` existential does not expose `Z.lo = none` and `Z.hi = none`, even though the internal construction in `very_good_implies_good` produces an unbounded Z-interval. Either strengthen `chronicle_is_good_direct` or define a `good_unbounded` variant. (b) Construct the TaskModel with position-dependent WorldState and prove the truth correspondence.

### Prior Plan Reference

Plan v51 was blocked at Phase 1 because its mathematical strategy (gap_contradicts_prior + no_boundary_at_successor to prove IsSuccArchimedean) is unsound. This plan abandons the IsSuccArchimedean approach entirely and instead closes the Z-interval-to-TaskFrame packaging sorry directly.

## Goals & Non-Goals

**Goals**:
- Close the sorry at `countermodel_discrete_reynolds` (Transfer.lean:1289)
- Rewire `completeness_discrete` to call `countermodel_discrete_reynolds` instead of `countermodel_discrete_enriched`
- Verify `#print axioms completeness_discrete` shows no `sorryAx`
- Full `lake build` passes with zero errors

**Non-Goals**:
- Proving IsSuccArchimedean for the chronicle (abandoned; Z+Z counterexample proves it impossible from available hypotheses)
- Closing sorries in `succ_cofinal`, `limitDomSubtype_isSuccArchimedean`, or `chronicle_gap_contradiction` (dead code on the BX pipeline path)
- Modifying the GHR93 expressiveness machinery (not on this path)
- Archiving dead BX code (separate task 255)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `good` existential does not expose Z.lo/hi = none; strengthening it requires modifying `very_good_implies_good` return type | M | M | Option A: Define `good_unbounded` that returns Z with explicit bounds alongside k_equiv. Option B: Modify `chronicle_is_good_direct` to use the old `chronicle_is_good` pattern (OrderIso) for the Z-interval construction while keeping the sorry-free one_class proof. Option C: Bypass `z_interval_countermodel` entirely and construct the existential package directly |
| ShiftClosed proof for position-dependent WorldState is non-trivial | M | L | The Z-interval has `interp p z` for integer z. Shifting history by Delta maps position z to z-Delta. If the Z-interval interp is shift-invariant (which it is for the shift-and-glue construction), then the shifted history equals the original. Even if not shift-invariant, the shifted history is still IN Omega because Omega is a singleton and the shifted history IS the same as zIntervalHistory |
| truth_at / temporal_truth correspondence for box formulas requires careful handling | M | L | With singleton Omega, `truth_at (.box psi) ↔ truth_at psi` (transparent). temporal_truth box psi = M.interp (atomMap (.box psi)) t. The correspondence follows from the chronicle truth lemma: both reduce to `(.box psi) in CM.fmcs t` |
| Changing the signature of `countermodel_discrete_reynolds` to match `countermodel_discrete_enriched` | L | L | Both return the same existential package shape (D, AddCommGroup D, ..., not truth_at). The key difference is `countermodel_discrete_enriched` returns `F : TaskFrame Int` directly, while `countermodel_discrete_reynolds` returns generic D. We may need to specialize D=Int at the call site |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |

Phases within the same wave can execute in parallel.

### Phase 1: Expose Unbounded Z-Interval from Good [COMPLETED]

**Goal**: Make `chronicle_is_good_direct` (or a new variant) return a Z-interval with `lo = none` and `hi = none` alongside the k-equivalence proof, so the downstream packaging can use `z_interval_countermodel` which requires these bounds.

**Strategy**: Two options, try in order:

**Option A (preferred)**: Define `good_unbounded` in GoodStructures.lean:
```lean
def good_unbounded (sig : MonadicSignature) (k : Nat) (M : OrderedMonadicStructure sig) : Prop :=
  exists (Z : ZIntervalStructure sig), Z.lo = none /\ Z.hi = none /\ k_equiv sig k M (Z.toOrdered sig)
```
Then prove `very_good_implies_good_unbounded` by following the existing `very_good_implies_good` proof (which internally constructs `Z_result` with `lo := none, hi := none` at ShiftAndGlue.lean:607-612). The only change is exposing the bounds in the return type. Update `chronicle_is_good_direct` to return `good_unbounded` instead of `good`.

**Option B (fallback)**: Skip defining `good_unbounded`. Instead, modify `countermodel_discrete_reynolds` to NOT use `z_interval_countermodel`. Construct the existential package directly: use the Z-interval carrier (which is a subtype of Int) as D, build TaskFrame/TaskModel on it, and package. This avoids needing lo/hi = none but requires more work in Phase 2.

**Tasks**:
- [ ] **Task 1.1**: Define `good_unbounded` predicate in GoodStructures.lean *(deviation: skipped — countermodel_discrete_reynolds was rewritten to use parametric canonical model approach, bypassing the Z-interval packaging entirely; good_unbounded is not needed)*
- [ ] **Task 1.2**: Prove `very_good_implies_good_unbounded` in ShiftAndGlue.lean *(deviation: skipped — same reason as 1.1)*
- [ ] **Task 1.3**: Update `chronicle_is_good_direct` to return `good_unbounded` *(deviation: skipped — same reason as 1.1)*
- [ ] **Task 1.4**: Update `countermodel_discrete_reynolds` Step 4 to destructure `good_unbounded` output *(deviation: skipped — the entire proof body was rewritten)*
- [x] **Task 1.5**: Verify `lake build Bimodal.Metalogic.WeakCanonical.IntegerModel.ShiftAndGlue` passes *(deviation: altered — verified Transfer.lean instead since ShiftAndGlue was not modified)*

**Timing**: 2 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/GoodStructures.lean` -- add `good_unbounded` definition
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/ShiftAndGlue.lean` -- add `very_good_implies_good_unbounded`, update `chronicle_is_good_direct`
- `Theories/Bimodal/Metalogic/WeakCanonical/Transfer.lean` -- update Step 4 destructuring in `countermodel_discrete_reynolds`

**Verification**:
- `lake build Bimodal.Metalogic.WeakCanonical.IntegerModel.ShiftAndGlue` passes
- `chronicle_is_good_direct` returns `good_unbounded`

---

### Phase 2: Construct Position-Dependent TaskFrame and TaskModel [COMPLETED]

**Goal**: Replace the sorry at Transfer.lean:1289 with a concrete construction. Build a TaskFrame with position-dependent WorldState and a TaskModel whose atom valuation reads from the Z-interval's predicate interpretation.

**Strategy**:

The current `zIntervalTaskFrame` uses `WorldState = Unit`, which makes atom truth position-independent. This is wrong for position-dependent Z-intervals. Replace with a new TaskFrame construction.

Define (in Transfer.lean, near the existing `zIntervalTaskFrame`):

```lean
noncomputable def zIntervalTaskFramePD (sig : MonadicSignature) : TaskFrame Int where
  WorldState := sig.preds -> Prop
  task_rel := fun _ _ _ => True
  nullity_identity := fun w u => ...
  forward_comp := ...
  converse := ...
```

The world state at each time t is the function `fun p => Z.interp p t` -- the predicate profile at that position.

Define the history:
```lean
noncomputable def zIntervalHistoryPD (sig : MonadicSignature) (Z : ZIntervalStructure sig)
    (h_lo : Z.lo = none) (h_hi : Z.hi = none) :
    WorldHistory (zIntervalTaskFramePD sig) where
  domain := fun _ => True
  convex := ...
  states := fun t _ => fun p => Z.interp p t
  respects_task := ...
```

The singleton Omega = {zIntervalHistoryPD ...} is shift-closed because:
- Shifting by Delta maps states at t to states at (t - Delta)
- `Z.interp p (t - Delta)` generally differs from `Z.interp p t`, so the shifted history is NOT propositionally equal to the original
- BUT: shift-closed requires `time_shift tau Delta in Omega`. With singleton Omega, we need `time_shift tau Delta = tau`. This FAILS if Z.interp is not shift-invariant.

**Critical issue**: ShiftClosed with position-dependent states and singleton Omega is problematic. The standard resolution: use ALL time-shifts as Omega. Define:
```lean
def zIntervalOmegaPD := {sigma | exists Delta, sigma = time_shift (zIntervalHistoryPD ...) Delta}
```
Then ShiftClosed holds by construction: shifting any element by Delta' gives another element (shift by Delta + Delta').

For box transparency: `truth_at (.box psi) tau t = forall sigma in Omega, truth_at psi sigma t`. With Omega = all shifts of tau, box universally quantifies over all shifted histories at the same time t. Since each shifted history at time t has states `fun p => Z.interp p (t - Delta)` for various Delta, box truth at t requires psi to hold for ALL predicate profiles, not just the one at t.

This is TOO STRONG -- we need box to be transparent (truth_at box psi = truth_at psi).

**Resolution**: Use `WorldState = Unit` (the existing `zIntervalTaskFrame`) but with a DIFFERENT approach to truth correspondence. Instead of requiring `truth_at phi t <-> temporal_truth phi t` for ALL phi, we only need it for the target formula neg-phi. The key is that `z_interval_countermodel` already parameterizes over an arbitrary TM and h_truth_corr. We can construct TM and prove h_truth_corr using structural induction on phi.

Concretely: define `TM : TaskModel zIntervalTaskFrame` with `valuation := fun () a => Z.interp (atomMap_fwd (.atom a)) (iso.symm t_current).val` -- but this is position-independent (bad).

**Better resolution (the actual fix)**: Do NOT use `z_interval_countermodel` at all. Construct the existential package directly by induction on the formula structure, using `truth_transfer` which already gives us `not (temporal_truth ... s phi)`. We need to package this as `not (truth_at ... t phi)`. The packaging constructs TM such that truth_at and temporal_truth agree on phi and all its subformulas.

Define TM using the Z-interval interpretation:
```lean
noncomputable def zIntervalTM (sig : MonadicSignature) (Z : ZIntervalStructure sig)
    (h_lo : Z.lo = none) (h_hi : Z.hi = none)
    (atomMap_fwd : Formula -> sig.preds) : TaskModel zIntervalTaskFrame where
  valuation := fun () a => Z.interp (atomMap_fwd (.atom a)) ((unboundedZIntervalEquiv Z h_lo h_hi).symm 0).val
```
No -- this is still constant.

**Correct approach**: Use `WorldState = sig.preds -> Prop` BUT with `task_rel := fun _ _ _ => True` and Omega defined so that box IS transparent. The trick: define Omega as a SINGLETON containing the specific history. For ShiftClosed, we need `time_shift tau Delta in Omega` for all Delta. With Omega = {tau}, this requires `time_shift tau Delta = tau` -- which means the history must be shift-invariant.

The Z-interval's interpretation is NOT shift-invariant in general. But we can MAKE it shift-invariant by choosing Z.interp to be constant (all positions have the same predicates). This is what the existing Unit-based approach does, and it doesn't work.

**Final correct approach**: Use the existing `zIntervalTaskFrame` (WorldState = Unit) and `zIntervalOmega` (singleton, shift-closed). Construct `zIntervalTM` with `valuation := fun () _ => False` (all atoms false). Then prove `h_truth_corr` by induction on the formula. The key insight:

- For `.atom a`: `truth_at (.atom a) = TM.valuation () a = False`. And `temporal_truth (.atom a) = Z.interp (atomMap (.atom a)) t`. These do NOT match in general. But we don't need them to match for ALL formulas -- only for the TARGET formula neg-phi. If neg-phi has no atom subformulas at the top level (which is generally false), this works. But atoms DO appear.

Actually, re-reading the existing `z_interval_countermodel` theorem (Transfer.lean:641-666), it takes `h_truth_corr` as a PARAMETER. The question is whether this parameter CAN be satisfied at the call site. The comment at line 620-638 says it IS satisfiable. But how?

Let me re-read the approach more carefully.

**Tasks**:
- [x] **Task 2.1**: Choose the correct TaskFrame approach *(deviation: altered — used parametric canonical model approach instead of position-dependent TaskFrame; the Z-interval packaging problem is bypassed entirely by reusing ParametricCanonicalTaskFrame/TaskModel/BFMCS)*
- [x] **Task 2.2**: Construct `TM : TaskModel` for the chosen TaskFrame *(deviation: altered — used ParametricCanonicalTaskModel directly)*
- [ ] **Task 2.3**: Construct WorldHistory with position-dependent states *(deviation: skipped — not needed with parametric approach)*
- [ ] **Task 2.4**: Prove `h_truth_corr` by induction on psi *(deviation: skipped — not needed; parametric truth lemma handles this)*
- [x] **Task 2.5**: Close the sorry at countermodel_discrete_reynolds *(completed via parametric approach)*
- [x] **Task 2.6**: Verify `lake build Bimodal.Metalogic.WeakCanonical.Transfer` passes

**Timing**: 2.5 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Transfer.lean` -- replace sorry at line 1289 with concrete construction

**Verification**:
- `countermodel_discrete_reynolds` has no sorry
- `lake build Bimodal.Metalogic.WeakCanonical.Transfer` passes

**Detailed Strategy for h_truth_corr**:

The truth correspondence must handle all formula constructors:

1. **Atom case**: `truth_at (.atom a) tau t = exists ht, TM.valuation (tau.states t ht) a`. With domain = True, ht always exists. Need: `TM.valuation (states t _) a <-> Z.interp (atomMap_fwd (.atom a)) (iso.symm t).val`.

   If we use `WorldState = sig.preds -> Prop` and `states t _ = fun p => Z.interp p (iso.symm t).val`, and `valuation w a = w (atomMap_fwd (.atom a))`, then this holds definitionally.

2. **Bot case**: Both sides are False. Trivial.

3. **Imp case**: Follows from IH.

4. **Box case**: `truth_at (.box psi) = forall sigma in Omega, truth_at psi sigma t`. With ALL-shifts Omega and position-dependent states, this universally quantifies over all time-shifted copies. `temporal_truth (.box psi) = Z.interp (atomMap_fwd (.box psi)) (iso.symm t).val`.

   The bridge: `Z.interp (atomMap_fwd (.box psi)) z` encodes whether `.box psi` is in the MCS at position z of the chronicle. By the chronicle truth lemma, this is equivalent to `(.box psi) being true at every world in the MCS at z`. In the S5 setting with one_class, this means psi is true at z (modal T). And truth_at (.box psi) with all-shifts Omega means psi is true at t in all shifted versions of the history.

   This is the hard case. The simplest approach: DON'T prove the full correspondence. Instead, observe that `temporal_truth` is DEFINED so that box formulas are just predicate lookups. The `truth_transfer` theorem gives us `temporal_truth (Z.toOrdered sig) atomMap_fwd s phi.neg`. We need `not (truth_at TM Omega tau (iso s) phi)`. We can prove this by a DIRECT induction using `temporal_truth_neg_implies_not_truth_at` as a helper lemma.

   Alternatively: since the existing `z_interval_countermodel` requires h_truth_corr for ALL subformulas, the simplest path is to NOT use z_interval_countermodel and instead construct the existential directly. Define the TaskFrame and TM, define Omega, then prove `not truth_at TM Omega tau (iso s) phi` by induction on phi, using the temporal_truth negation at each step.

**Recommended approach (bypass z_interval_countermodel)**: Construct the existential package directly in `countermodel_discrete_reynolds` without calling `z_interval_countermodel`. Define:
- TaskFrame: `zIntervalTaskFramePD sig` with WorldState = sig.preds -> Prop
- TaskModel: valuation reads from world state -- `valuation w a = w (atomMap_fwd (.atom a))`
- History: states at time t = Z's predicate profile at iso.symm(t)
- Omega: all time-shifts of this history
- Prove ShiftClosed by construction
- Prove `not (truth_at TM Omega tau (iso s) phi)` by structural induction on phi, using:
  - Atom: definitional from valuation/states construction
  - Bot: trivial
  - Imp: from IH
  - Box: from the all-shifts Omega construction + one_class property (all shifts have equivalent predicate profiles at any given time)
  - Untl/Snce: from the Z-interval temporal structure

The box case is the crux. With Omega = all shifts, `truth_at (.box psi) tau t = forall Delta, truth_at psi (shift tau Delta) t`. At shifted position, `states t _ = Z.interp _ (t - Delta)`, so atom truth at time t in the shifted history reads the Z-interval at position `t - Delta`. This means box psi at t requires psi to hold at t for every Delta -- i.e., psi must hold when the predicate profile at t is replaced by the profile at any other position. This is STRONGER than just psi holding at t.

Actually, this won't work for proving truth_at neg-phi at a specific point. Let me reconsider.

**Simplest working approach**: Use WorldState = Unit (constant) and zIntervalTaskFrame. Define TM with `valuation () _ = False`. Then truth_at (.atom a) = False at all points. And temporal_truth (.atom a) = Z.interp (atomMap (.atom a)) t, which can be True. So we CANNOT prove truth_at <-> temporal_truth for atoms.

But we DON'T need the full correspondence. We need `not (truth_at TM Omega tau (iso s) phi)`. We have `temporal_truth (Z.toOrdered sig) atomMap_fwd s phi.neg`, which means `temporal_truth ... s phi -> False`.

For `not (truth_at ... phi)`: if truth_at phi were True, we'd need to derive a contradiction. But truth_at depends on TM.valuation, and if we set all atoms to False, truth_at phi will be False for any formula that requires an atom to be True.

This doesn't help because phi.neg being temporally true doesn't mean phi can't be truth_at true with a weird TM.

**The correct fix (from research)**: The `WorldState` approach with predicates. The all-shifts Omega issue is resolved by noting that in the Reynolds pipeline, box is TRANSPARENT: the chronicle has one_class, meaning all points are contemp_equiv, so box phi <-> phi. The Z-interval inherits this via k_equiv. So temporal_truth (.box psi) t = temporal_truth psi t (because the box predicate and the psi truth coincide via one_class). Similarly, truth_at (.box psi) = truth_at psi in a singleton Omega.

So: use the SINGLETON Omega (not all-shifts). The ShiftClosed issue for position-dependent WorldState must be handled differently.

**ShiftClosed with singleton Omega and position-dependent states**: ShiftClosed requires `time_shift tau Delta in Omega` for all Delta. With Omega = {tau}, we need `time_shift tau Delta = tau`. With position-dependent states (`states t _ = f(t)` for some f), `time_shift` gives states at `t + Delta`, so `(time_shift tau Delta).states t _ = tau.states (t + Delta) _ = f(t + Delta)`. For this to equal `tau.states t _ = f(t)`, we need `f(t + Delta) = f(t)` for all t, Delta -- i.e., f is constant. Which brings us back to the Unit problem.

**The real solution**: Omega must contain ALL time-shifts. ShiftClosed is then trivial. Box transparency is NOT needed for the full correspondence -- it's needed ONLY for the target formula. And the target formula's truth can be proved by induction WITHOUT requiring box transparency for the model.

Actually, re-reading the `z_interval_countermodel` theorem more carefully: it does NOT assume box transparency. It takes `h_truth_corr` which must hold for ALL psi (subformulas). The box case of h_truth_corr requires: `truth_at (.box psi) tau (iso t) <-> temporal_truth (.box psi) t` = `Z.interp (atomMap (.box psi)) t.val`. The left side (with ALL-shifts Omega) is: `forall sigma in Omega, truth_at psi sigma (iso t)`. With all shifts: `forall Delta, truth_at psi (shift tau Delta) (iso t)`.

If truth_at psi at time (iso t) in the shifted history depends on the predicate profile at (iso t) - Delta for various positions (via Until/Since witnesses), this won't reduce to a single predicate lookup.

I think the correct approach is actually much simpler. Let me reconsider from scratch.

**The actual simplest correct construction**:

Use the old `chronicle_is_good` (line 886-907) approach as a TEMPLATE. It explicitly builds Z with `lo := none, hi := none` and `interp p z = (atomMap p) in M.fmcs (f.symm z)` where `f : M.domain <=>o Int` is the OrderIso from `orderIsoIntOfLinearSuccPredArch`. The problem is that `orderIsoIntOfLinearSuccPredArch` requires `IsSuccArchimedean`.

But `chronicle_is_good_direct` does NOT use `orderIsoIntOfLinearSuccPredArch`. It goes through the cofinal decomposition path. The resulting Z_final has lo=none, hi=none by construction (ShiftAndGlue.lean:607), but the interp is defined via the shift-and-glue pieces, NOT directly from the chronicle MCS.

The bridge from temporal_truth to truth_at must go through the k_equiv: `truth_transfer` gives temporal_truth on Z-interval -> we need truth_at on TaskFrame Int. The k_equiv relates the CHRONICLE's temporal truth to the Z-interval's temporal truth, but truth_at is a DIFFERENT notion defined on TaskFrames.

Actually wait. Let me re-read `truth_transfer` to understand what it actually gives us.

**Tasks** (continued):
- [x] **Task 2.7**: Study `truth_transfer` output carefully *(deviation: altered — determined that truth_transfer is not needed; parametric approach bypasses the entire Reynolds pipeline)*
- [x] **Task 2.8**: Determine minimal viable construction *(completed — parametric canonical model approach)*
- [x] **Task 2.9**: Implement and verify *(completed)*

**Timing**: 2.5 hours

**Depends on**: 1

---

### Phase 3: Rewire completeness_discrete [COMPLETED]

**Goal**: Change `completeness_discrete` in Completeness.lean to use `countermodel_discrete_reynolds` instead of `countermodel_discrete_enriched`.

**Strategy**:

`completeness_discrete` at Completeness.lean:369 currently calls:
```lean
obtain <F, TM, Omega, h_sc, tau, h_mem, t, h_not_true> :=
  countermodel_discrete_enriched M hM_mcs (le_refl _) phi h_neg_in h_box_discrete
```

Replace with a call to `countermodel_discrete_reynolds`:
```lean
obtain <D, _, _, _, _, F, TM, Omega, h_sc, tau, h_mem, t, h_not_true> :=
  countermodel_discrete_reynolds M hM_mcs phi h_neg_in h_box_discrete
```

Note: `countermodel_discrete_reynolds` returns a more general existential (generic D instead of F : TaskFrame Int). The `h_not_true : not truth_at TM Omega tau t phi` and `h_valid_discrete` call must be adjusted. Currently:
```lean
exact h_not_true (h_valid_discrete Int F TM Omega h_sc tau h_mem t)
```
With generic D:
```lean
exact h_not_true (h_valid_discrete D F TM Omega h_sc tau h_mem t)
```

But `valid_discrete` requires `SuccOrder D` and `PredOrder D`. If D = Int this is fine. If `countermodel_discrete_reynolds` returns generic D, we need SuccOrder/PredOrder instances in the existential.

**Check**: `countermodel_discrete_reynolds`'s return type includes `D : Type` with `AddCommGroup D`, `LinearOrder D`, `IsOrderedAddMonoid D`, `Nontrivial D`. But `valid_discrete` also needs `SuccOrder D`, `PredOrder D`. So we need to either:
(a) Specialize `countermodel_discrete_reynolds` to return `D = Int` directly, or
(b) Add `SuccOrder D` and `PredOrder D` to its existential return type.

Option (a) is simpler and matches what `countermodel_discrete_enriched` does.

**Tasks**:
- [x] **Task 3.1**: Add `SuccOrder D`, `PredOrder D`, `IsSuccArchimedean D`, `IsPredArchimedean D` to the existential of `countermodel_discrete_reynolds`
- [x] **Task 3.2**: Update `completeness_discrete` discrete branch to call `countermodel_discrete_reynolds`
- [x] **Task 3.3**: Adjust destructuring pattern to match the new existential shape
- [x] **Task 3.4**: Update the `h_valid_discrete` application to use the returned D
- [x] **Task 3.5**: Verify `lake build Bimodal.Metalogic.BXCanonical.Completeness` passes

**Timing**: 45 minutes

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Transfer.lean` -- potentially adjust return type of `countermodel_discrete_reynolds`
- `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` -- rewire discrete branch

**Verification**:
- `completeness_discrete` uses `countermodel_discrete_reynolds` (not `countermodel_discrete_enriched`)
- `lake build Bimodal.Metalogic.BXCanonical.Completeness` passes

---

### Phase 4: Verification and Documentation [NOT STARTED]

**Goal**: Full build verification, axiom audit, and documentation updates.

**Tasks**:
- [ ] Run full `lake build` and verify zero errors
- [ ] Add `#print axioms completeness_discrete` temporarily in Completeness.lean, verify no `sorryAx` appears, then remove
- [ ] Update docstring on `countermodel_discrete_reynolds` to remove the sorry-status note
- [ ] Update the sorry-chain comment block in Completeness.lean (lines 377-430) to reflect the new sorry-free status of the discrete case
- [ ] Update the module-level docstring in Transfer.lean to reflect that `countermodel_discrete_reynolds` is now sorry-free and is the active path
- [ ] Add a note near `countermodel_discrete_enriched` marking it as bypassed by the Reynolds pipeline

**Timing**: 45 minutes

**Depends on**: 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Transfer.lean` -- update docstrings
- `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` -- update axiom audit comments, temporary #print axioms

**Verification**:
- `#print axioms completeness_discrete` shows no `sorryAx`
- `lake build` passes with zero errors
- All docstrings accurately reflect current proof state

## Testing & Validation

- [ ] `lake build Bimodal.Metalogic.WeakCanonical.IntegerModel.ShiftAndGlue` passes after Phase 1
- [ ] `lake build Bimodal.Metalogic.WeakCanonical.Transfer` passes after Phase 2
- [ ] `countermodel_discrete_reynolds` contains no `sorry` keyword after Phase 2
- [ ] `lake build Bimodal.Metalogic.BXCanonical.Completeness` passes after Phase 3
- [ ] `#print axioms completeness_discrete` shows no `sorryAx` after Phase 3
- [ ] Full `lake build` passes with zero errors after Phase 4

## Artifacts & Outputs

- plans/52_implementation-plan.md (this file)
- summaries/52_execution-summary.md (to be created at implementation completion)

## Rollback/Contingency

If Phase 2 (position-dependent TaskFrame construction) proves intractable:

1. **Fallback A (bypass z_interval_countermodel)**: Instead of using the existing `z_interval_countermodel` helper, construct the entire existential package from scratch. Define a custom TaskFrame with WorldState carrying the chronicle's MCS assignments, build Omega as all time-shifts, and prove truth_at negation directly by induction on the formula without requiring a general truth correspondence.

2. **Fallback B (direct chronicle countermodel)**: Skip the Z-interval entirely. Use the chronicle itself as the countermodel domain. The chronicle is countable, discrete, and has NoMin/NoMaxOrder. Construct an OrderIso to Int (this is the `orderIsoIntOfLinearSuccPredArch` approach, but we'd need to prove IsSuccArchimedean first -- which is the dead approach). Not viable unless a different OrderIso construction is found.

3. **Fallback C (partial)**: Close the sorry with a weaker result. Instead of `countermodel_discrete_reynolds` returning generic D, make it return D=Int by using `chronicle_is_good` (which uses `orderIsoIntOfLinearSuccPredArch` and thus depends on `IsSuccArchimedean`) but with a sorry for the IsSuccArchimedean step. This adds a sorry upstream but may help isolate the remaining work. NOT recommended -- does not achieve the goal.

4. **Fallback D (refactor good)**: If exposing lo/hi=none from `good` is difficult, create a completely new version of `chronicle_is_good_direct` that constructs the Z-interval directly (like `chronicle_is_good` at line 886-907) but uses the sorry-free `one_class` proof from `chronicle_is_good_direct` to first establish that all points are contemp_equiv, then constructs the trivial Z-interval (whole of Z with MCS-based interp) plus the k_equiv by showing the OMS is order-isomorphic to Z via a custom OrderIso construction that avoids `orderIsoIntOfLinearSuccPredArch`. The OrderIso could be built from the cofinal sequence (a : Z -> M.carrier, StrictMono, cofinal) if we show it's actually surjective -- which is NOT guaranteed for general countable orders.
