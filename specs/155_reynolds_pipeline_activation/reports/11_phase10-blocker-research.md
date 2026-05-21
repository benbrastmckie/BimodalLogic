# Phase 10 Blocker Research: h_truth_corr Discharge

## Problem Analysis

### The Sorry

Transfer.lean:574 contains a sorry for `h_truth_corr`:

```lean
have h_truth_corr : forall (psi : Formula) (t : Z_wit.intervalCarrier),
    truth_at TM_wit zIntervalOmega zIntervalHistory
      ((unboundedZIntervalEquiv Z_wit h_lo h_hi) t) psi <->
      temporal_truth (Z_wit.toOrdered sig) atomMap_fwd t psi
```

This asserts that truth in the TaskModel (`truth_at`) corresponds to temporal truth on the Z-interval structure (`temporal_truth`) for all formulas and all positions.

### Why It Is Unprovable

The sorry is fundamentally unprovable with the current architecture. Two independent structural mismatches prevent discharge:

**Mismatch 1 -- Atom truth is position-independent.** `zIntervalTaskFrame` (Transfer.lean:351) uses `WorldState = Unit`. The `truth_at` definition for atoms is:
```
truth_at ... z (atom p) = exists ht, TM.valuation (tau.states z ht) p
```
With `WorldState = Unit`, `tau.states z ht = ()` for all z, making `TM.valuation () p` constant across all positions. But `temporal_truth` for atoms is:
```
temporal_truth ... z (atom p) = Z.interp (atomMap (.atom p)) z
```
which varies with z (the Z-interval has position-dependent predicate interpretations). No valuation `Unit -> Atom -> Prop` can match a position-varying function.

**Mismatch 2 -- Box semantics disagree.** With singleton `Omega = {zIntervalHistory}`, box quantification is transparent:
```
truth_at ... z (box psi) <-> truth_at ... z psi
```
(by `zIntervalBox_transparent`, Transfer.lean:398). But `temporal_truth` treats box as a flat predicate lookup:
```
temporal_truth ... z (box psi) = Z.interp (atomMap (.box psi)) z
```
which is `(.box psi) in chron.fmcs(f.symm z) <-> (.box psi) in A` (constant by box stability). So h_truth_corr for box becomes `truth_at ... z psi <-> (.box psi) in A`, equating a local property (psi at z) with a global property (box psi in the root MCS). This is not valid for arbitrary psi and z.

### Critical Discovery: Existing succ_cofinal Dependency

The current `countermodel_discrete` ALREADY depends on `succ_cofinal` through the Z-interval construction at Transfer.lean:521:

```lean
let f : chron.domain ≃o Z := orderIsoIntOfLinearSuccPredArch
```

`orderIsoIntOfLinearSuccPredArch` requires `IsSuccArchimedean`, which comes from `ChronicleAsPriorModel.domain_succ_archimedean`, which traces to `succ_cofinal` (ChronicleToCountermodel.lean:1885, sorry).

This means `countermodel_discrete` currently carries TWO sorry sources:
1. `h_truth_corr` (Transfer.lean:574)
2. `succ_cofinal` / `IsSuccArchimedean` (Transfer.lean:521, via `orderIsoIntOfLinearSuccPredArch`)

The `chronicle_is_good` theorem (IntegerModel.lean:1245) has the same `succ_cofinal` dependency (line 1249).

## Literature Review

### Reynolds 1994, Theorem 18

Reynolds' completeness proof (p. 982-1008) works entirely within temporal structures `(T, <, h)`:

1. Start with chronicle M0 from Burgess-Xu (countable, discrete, no endpoints, Prior-UZ/SZ valid)
2. Apply Theorem 6 (gap elimination): chronicle is k-equivalent to Z-interval Z with integer flow
3. Transfer: M0 satisfies `exists t. table(A0)(t)`, so Z does too by k-equivalence
4. Extract witness b in Z where `table(A0)(b)` holds; conclude Z satisfies A0(b)

**Key observation**: Reynolds never constructs a TaskFrame. The countermodel IS the temporal structure `(Z, <, h)`. The concept of WorldState, TaskModel, Omega, and WorldHistory does not appear in the original proof. The h_truth_corr problem arises solely because the formalization wraps the countermodel in a TaskFrame.

### How the ParametricCanonical Approach Solves Box

The `dd_countermodel_chronicle_discrete` (ChronicleToCountermodel.lean:3285) uses `ParametricCanonicalTaskFrame Int` with `WorldState = {M : Set Formula // SetMaximalConsistent M}`. The truth lemma (`fully_restricted_parametric_shifted_truth_lemma`, RestrictedParametricTruthLemma.lean:264) handles box correctly by:

- Using BFMCS families (multiple histories in Omega, one per box-equivalent MCS)
- `modal_forward`: Box phi in fam -> Box phi in A -> phi in every family (by box-equivalence)
- `modal_backward`: phi in every family -> Box phi (contrapositive via modal witness)
- This gives `truth_at (.box psi) <-> box psi in fam.mcs(t)`, NOT `truth_at psi`

The singleton Omega approach (zIntervalTaskFrame) cannot replicate this because box quantification over a singleton degenerates to identity.

## Solution Options (Ranked by Feasibility)

### Option 1: Delegate to dd_countermodel_chronicle_discrete [RECOMMENDED]

**Description**: Replace the body of `countermodel_discrete` with a single call to `dd_countermodel_chronicle_discrete`, which already has the same type signature.

**Code change** (Transfer.lean:501-575 replaced with):
```lean
theorem countermodel_discrete (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (phi : Formula) (h_neg_in : phi.neg in A)
    (h_box_discrete : Formula.box next_top in A) :
    exists (D : Type) ... := by
  exact dd_countermodel_chronicle_discrete A h_mcs phi h_neg_in h_box_discrete
```

**Sorry impact**: Eliminates `h_truth_corr` sorry (Transfer.lean:574). Retains `succ_cofinal` sorry (which `countermodel_discrete` already carries through line 521). Net effect: FEWER sorry sources (1 instead of 2).

**Lines of new code**: ~5 (replacing ~80).

**Feasibility**: Trivial to implement. The type signatures match exactly. All imports are already present.

**Concern addressed**: The prior revert (commit 4ac2184e) objected that "delegation still carries sorryAx." However, the current code ALSO carries sorryAx from the same `succ_cofinal` dependency. Delegation is strictly better: same sorryAx source, fewer total sorry sites.

**Alignment with literature**: Acceptable. The ParametricCanonical path uses the Burgess chronicle directly with MCS-based world states, which is mathematically equivalent to Reynolds' construction.

**After Phases 6-9**: When gap elimination provides `chronicle_is_good` without `IsSuccArchimedean`, we can ALSO fix `dd_countermodel_chronicle_discrete` by replacing `succ_embed_surjective` with a new surjectivity proof derived from `one_class` / `no_gaps_discrete`. This would make both functions sorry-free simultaneously.

### Option 2: Build MCS-enriched TaskFrame inline [COMPLEX]

**Description**: Replace `zIntervalTaskFrame` (WorldState=Unit) with a new TaskFrame using `WorldState = ParametricCanonicalWorldState`, define a WorldHistory mapping each integer to the chronicle's MCS, and use the MCS membership valuation. Build a BFMCS inline within countermodel_discrete.

**Code change**: ~200-350 lines. Would need to:
1. Define new TaskFrame with MCS world states (~20 lines)
2. Define FMCS from chronicle via the Z-interval mapping (~30 lines)
3. Build BFMCS with rooted families for each box-equivalent MCS (~80 lines)
4. Prove restricted temporal coherence, backward/forward U/S coherence (~100-150 lines)
5. Invoke the restricted truth lemma (~20 lines)

**Sorry impact**: Would still need `succ_cofinal` for the chronicle-to-integer mapping (to build the FMCS on Z, we need `f : chron.domain ≃o Z`).

**Feasibility**: High effort, duplicates existing infrastructure from ChronicleToCountermodel.lean. Would essentially re-implement `dd_countermodel_chronicle_discrete` inline.

**Why not recommended**: This is exactly what `dd_countermodel_chronicle_discrete` already does. Duplicating it is wasteful.

### Option 3: Wait for Phases 6-9, then construct Z-interval countermodel [BLOCKED]

**Description**: After gap elimination provides `chronicle_is_good` without `IsSuccArchimedean`, refactor countermodel_discrete to:
1. Use `chronicle_is_good` to get Z-interval (no `succ_cofinal`)
2. Use truth_transfer to move neg(phi) to Z-interval
3. Construct TaskFrame countermodel from Z-interval using a new BFMCS on Z

**Sorry impact**: Would eventually be sorry-free after Phases 6-9.

**Problem**: Still needs to solve the box semantics mismatch. Would need either (a) a BFMCS on Z with rooted families (requiring surjectivity again) or (b) a new way to handle box that doesn't use BFMCS.

**Feasibility**: High uncertainty. The box mismatch is structural and may require fundamentally new infrastructure regardless of gap elimination completion.

### Option 4: Reformulate validity to avoid TaskFrame [REJECTED]

**Description**: Change the `valid` definition to use temporal structures `(T, <, h)` instead of TaskFrames.

**Why rejected**: Would require rewriting the entire soundness proof, all frame-class validity theorems, and the completeness theorem itself. Estimated 2000+ lines of changes. Architecturally unsound.

## Recommended Approach

**Option 1: Delegate to `dd_countermodel_chronicle_discrete`.**

### Rationale

1. **It is strictly better than the status quo.** The current code has TWO sorry sources (h_truth_corr + succ_cofinal). Delegation has ONE (succ_cofinal). The `succ_cofinal` dependency exists in both cases.

2. **The delegation is type-compatible.** Both functions have identical signatures:
   ```
   (A : Set Formula) (h_mcs : SetMaximalConsistent A) (phi : Formula)
   (h_neg_in : phi.neg in A) (h_box_discrete : Formula.box next_top in A) :
   exists (D : Type) ... not truth_at TM Omega tau t phi
   ```

3. **All imports are already present.** Transfer.lean imports ChronicleToCountermodel.lean (line 7).

4. **The approach is compatible with future phases.** When Phases 6-9 complete gap elimination, `succ_cofinal` can be resolved independently (either by proving it from `one_class`, or by refactoring `dd_countermodel_chronicle_discrete` to use the Reynolds pipeline's iso). At that point, `countermodel_discrete` inherits the fix for free.

5. **The Reynolds pipeline's non-BFMCS infrastructure (chronicle_temporal_truth, truth_transfer, etc.) remains useful** for the broader project even if countermodel_discrete delegates the final packaging step. These theorems (Phases 1-5) are independently valuable.

### Addressing the Prior Revert

The commit f446497a was reverted because "delegation still carries sorryAx." This concern is valid but incomplete:

- The current code also carries sorryAx (from succ_cofinal via orderIsoIntOfLinearSuccPredArch)
- Delegation REMOVES one sorry source (h_truth_corr) while keeping the other (succ_cofinal)
- The net sorry count goes DOWN, not up
- The remaining sorry (succ_cofinal) is on the critical path regardless and will be resolved by gap elimination

The revert was premature. The correct action is to delegate now and resolve succ_cofinal through Phases 6-9.

### Dead Code Cleanup

After delegation, the following definitions in Transfer.lean become unused:
- `zIntervalTaskFrame` (line 351)
- `zIntervalHistory` (line 363)
- `zIntervalHistory_shift_eq` (line 374)
- `zIntervalOmega` (line 381)
- `zIntervalOmega_shiftClosed` (line 384)
- `zIntervalHistory_mem_omega` (line 390)
- `zIntervalBox_transparent` (line 398)
- `z_interval_countermodel` (line 443)
- `unboundedZIntervalEquiv` (line 328)

These can either be removed or kept for documentation purposes. The Reynolds pipeline infrastructure (lines 52-320: mkSigFrom, mkAtomMap, k_equiv_preserves_sentence, truth_transfer, chronicle_temporal_truth) remains valuable and should be preserved.

## Implementation Sketch

```lean
-- Transfer.lean, replace lines 501-575 with:
theorem countermodel_discrete (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (phi : Formula) (h_neg_in : phi.neg in A)
    (h_box_discrete : Formula.box next_top in A) :
    exists (D : Type) (_ : AddCommGroup D) (_ : LinearOrder D) (_ : IsOrderedAddMonoid D)
      (_ : Nontrivial D) (F : TaskFrame D) (TM : TaskModel F)
      (Omega : Set (WorldHistory F)) (_ : ShiftClosed Omega)
      (tau : WorldHistory F) (_ : tau in Omega) (t : D),
      not (truth_at TM Omega tau t phi) := by
  exact Bimodal.Metalogic.BXCanonical.Chronicle.dd_countermodel_chronicle_discrete
    A h_mcs phi h_neg_in h_box_discrete
```

The docstring should be updated to note:
- The Reynolds pipeline (Steps 1-6 in the old proof) established chronicle_temporal_truth and truth_transfer
- The final packaging delegates to the ParametricCanonical infrastructure
- The remaining sorryAx is from succ_cofinal, to be resolved by gap elimination (Phases 6-9)

## Confidence Level

**High confidence** that Option 1 (delegation) is correct and implementable. The type signatures match exactly, all imports exist, and the mathematical content is equivalent. The only risk is if the user objects to delegation on principle (as in the prior revert), but the analysis here shows it is strictly better than the status quo.

**Medium confidence** that this is the FINAL solution. After Phases 6-9 complete gap elimination, the team should revisit whether to:
(a) Keep the delegation (simplest), or
(b) Inline a new proof that uses the Reynolds pipeline's gap elimination directly to construct the BFMCS on Z without succ_cofinal

Option (b) would make `countermodel_discrete` truly independent of the BXCanonical path, but would require ~200-350 lines of new code and is only worth doing if there is a specific architectural reason to avoid the dependency.
