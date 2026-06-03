# Task 268: Reynolds Pipeline Bridge — Research Report

## 1. Boneyard Inventory

### 1.1 ReynoldsModelSurgery.lean (DEAD — archive entire file)

**Path**: `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/ReynoldsModelSurgery.lean`
**Lines**: 407 total
**Status**: Header at line 289 explicitly says "DEPRECATED: BX Pipeline Dead Code (task 225)"

Dead definitions:
- `PriorModelData` (lines 55-96): Structure wrapping discrete linear order with MCS but without IsSuccArchimedean. Used only by the dead BX pipeline.
- `priorModelAsMonadicStructure` (lines 107-112): Converts PriorModelData to OrderedMonadicStructure.
- `effectiveFormula_raw` (lines 126-136): Local copy of effectiveFormula to avoid circular import with Transfer.lean.
- `temporal_truth_effective_raw` (lines 145-211): temporal_truth iff effectiveFormula membership for PriorModelData.
- `semantic_prior_UZ_raw` (lines 219-250): Semantic Prior-UZ for PriorModelData.
- `semantic_prior_SZ_raw` (lines 256-287): Semantic Prior-SZ for PriorModelData.
- `no_gaps_faithful` (lines 329-331): **MATHEMATICALLY FALSE** — the Z+Z counterexample disproves it. Contains `sorry`.
- `prior_model_is_succ_archimedean` (lines 343-406): Depends on `no_gaps_faithful` (false). Dead.

**Imports**: Only imports `PriorExpressiveness`, `EFGames.Defs`, `MCSProperties`, `BXCanonical.TruthLemma`. No downstream code imports this file (verified — it is not in any other file's import list).

**Action**: Move entire file to `Theories/Bimodal/Boneyard/BXPipelineDeadCode/ReynoldsModelSurgery.lean` (or similar). Remove from lakefile if listed.

### 1.2 ChronicleToCountermodel.lean — Dead BX Pipeline Functions

**Path**: `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean`
**Lines**: ~2227 total, 28 sorry instances

Dead BX pipeline functions (lines 55-806):
- `succ_reaches_dom_N` (line 98): Private, sorry at lines 236 and 392. Stage induction helper — dead.
- `chronicle_gap_contradiction` (line 472): Private, sorry at line 486. The core sorry site. Dead.
- `succ_cofinal` (line 773): Private. Depends on `chronicle_gap_contradiction`. Dead.
- `limitDomSubtype_isSuccArchimedean` (line 789): Depends on `succ_cofinal`. **SUPERSEDED** (see below).

**CRITICAL**: These functions are `private`, so they cannot be referenced from outside the file. They ARE still used within the file:
- `limitDomSubtype_isSuccArchimedean` is used at line 1673 by `succ_embed_surjective`.

**Shared code (DO NOT archive)**:
- `succ_embed_surjective` (line 1666): Used by `cantor_bfmcs_discrete_restricted_tc` (line 2012), `cantor_bfmcs_discrete_restricted_fuc` (line 2065), and `dd_countermodel_chronicle_discrete` (line 2131+). This is on the ACTIVE path for `completeness_discrete` (via Transfer.lean's `countermodel_discrete_reynolds`).
- `collapse_equiv`, `collapse_setoid`, `CollapseClass` (lines 825-1009): Used by succ_embed infrastructure. Shared.
- `succ_discrete_f`, `succ_discrete_fmcs`, `rooted_succ_discrete_fmcs` (lines 1740+): Used by Transfer.lean's `countermodel_discrete_reynolds`. Active path.
- `cantor_bfmcs_discrete`, `cantor_bfmcs_discrete_restricted_tc/buc/fuc` (lines 1992+): Active path — called directly from `countermodel_discrete_reynolds` in Transfer.lean (lines 1238-1246).

### 1.3 Transfer.lean — `countermodel_discrete` (deprecated)

**Path**: `Theories/Bimodal/Metalogic/WeakCanonical/Transfer.lean`
**Lines**: 1299 total

- `countermodel_discrete` (line 1281): Deprecated BX path. Contains `sorry` at line 1296 (passes `sorry` as `h_fc` argument). Header at line 1249 says "DEPRECATED: BX Pipeline Dead Code (task 225)".
- `countermodel_discrete_reynolds` (line 1203): **ACTIVE path**. Used by `completeness_discrete` in Completeness.lean (line 369).

**Action**: `countermodel_discrete` can be moved to Boneyard, but it's a small function (17 lines). Lower priority than ReynoldsModelSurgery.lean.

## 2. Bridge Wiring

### 2.1 Current Sorry Chain for `completeness_discrete`

The active path is:
```
completeness_discrete (BXCanonical/Completeness.lean:309)
  → countermodel_discrete_reynolds (Transfer.lean:1203) -- sorry-free itself
    → cantor_bfmcs_discrete_restricted_tc (ChronicleToCountermodel.lean:1992)
    → cantor_bfmcs_discrete_restricted_fuc (ChronicleToCountermodel.lean:2048)
      → succ_embed_surjective (ChronicleToCountermodel.lean:1666)
        → limitDomSubtype_isSuccArchimedean (ChronicleToCountermodel.lean:789)
          → succ_cofinal (ChronicleToCountermodel.lean:773)
            → chronicle_gap_contradiction (ChronicleToCountermodel.lean:472) [SORRY]
```

### 2.2 The Reynolds Pipeline (Sorry-Free)

The Reynolds pipeline in `IntegerModel/` is sorry-free:
```
NoGapsDiscreteProof.lean:
  no_gaps_discrete (line 51) -- sorry-free, delegates to:
    → no_gaps_discrete_model_surgery (GoodStructuresModelSurgery.lean) -- sorry-free

NoGapsDiscreteProof.lean:
  one_class (line 88) -- sorry-free, uses:
    → no_gaps_discrete + no_boundary_at_successor + contemp_equiv_is_equiv

ReynoldsNoGaps.lean:
  one_class_archimedean (line 82) -- sorry-free
  gap_of_not_succ_archimedean (line 158) -- sorry-free
  no_gaps_prior (line 276) -- SORRY but not needed
  prior_implies_succ_archimedean (line 299) -- depends on no_gaps_prior [SORRY], not needed
```

### 2.3 What the Bridge Needs to Do

The bridge must replace `limitDomSubtype_isSuccArchimedean` with a proof that goes through the Reynolds pipeline instead of through `chronicle_gap_contradiction`.

**Option A: Direct approach** — Prove `IsSuccArchimedean` for `LimitDomSubtype` by:
1. Building an `OrderedMonadicStructure` on `LimitDomSubtype`
2. Proving `semantic_prior_UZ/SZ` for it (using `limit_satisfies_c5_strong`, `limit_satisfies_c4`, etc.)
3. Providing `h_surj` (atom surjectivity)
4. Applying `one_class` from `NoGapsDiscreteProof.lean`
5. Using `gap_of_not_succ_archimedean` contrapositively to conclude `IsSuccArchimedean`

This is essentially what `chronicle_gap_contradiction` was trying to do but failed. The key difference is that `one_class` is now sorry-free (via model surgery), whereas the old approach tried to use `no_gaps_faithful` (which is false).

**Option B: `one_class_archimedean` shortcut** — If we can prove `IsSuccArchimedean` for `LimitDomSubtype`, then `one_class_archimedean` gives us the one-class result directly. But this is circular — we need `IsSuccArchimedean` as input.

**Option C: Contrapositive via `one_class`** — The correct approach:
1. By contradiction: assume NOT `IsSuccArchimedean` for `LimitDomSubtype`.
2. By `gap_of_not_succ_archimedean`: there exists a `Gap` in `LimitDomSubtype`.
3. Build the monadic structure and prove `semantic_prior_UZ/SZ`.
4. Apply `one_class`: all points are `contemp_equiv`.
5. But `no_gaps_discrete` says: if two points are NOT contemp_equiv, there's a boundary. Since all ARE equiv, no boundaries. And `one_class` gives this.
6. Actually the simplest path: apply `one_class` to get all points equiv. Then apply `one_class_archimedean`... no, that's circular again.

Let me re-examine. The correct non-circular path:

**Option D: From `one_class` to `IsSuccArchimedean`**:
1. Build `OrderedMonadicStructure` on `LimitDomSubtype` with appropriate sig/atomMap.
2. Prove `h_surj`, `h_prior_UZ`, `h_prior_SZ` for this structure.
3. Apply `one_class`: all points are `contemp_equiv sig k M a b` for all a, b.
4. From one_class, derive `IsSuccArchimedean`:
   - By contradiction: assume NOT `IsSuccArchimedean`.
   - By `gap_of_not_succ_archimedean`: there exists a `Gap`.
   - But `one_class` says the `no_gaps_discrete` theorem's premise (NOT contemp_equiv) is vacuously false. This means `no_gaps_discrete` is vacuously satisfied, but that doesn't directly give us NO gaps.
   - Actually, `no_gaps_discrete_archimedean` (ReynoldsNoGaps.lean:111) requires `IsSuccArchimedean` already.
   - The real path: `one_class` gives us "all contemp_equiv" WITHOUT needing `IsSuccArchimedean`. Then `gap_of_not_succ_archimedean` says "NOT arch → Gap exists". And the Gap existence contradicts... what? We need "no gaps exist" which requires either proving it directly or using `no_gaps_int` (which is for Z, not LimitDomSubtype).
   
Let me reconsider. The proof sketch from task 155:

**Option E: `one_class` → `no Gap` → `IsSuccArchimedean`** (the correct approach):
1. Build monadic structure on `LimitDomSubtype`. Prove `h_surj`, `semantic_prior_UZ/SZ`.
2. Apply `one_class` (sorry-free): all points are `contemp_equiv`.
3. Now suppose NOT `IsSuccArchimedean`. By `gap_of_not_succ_archimedean`: Gap exists.
4. The Gap gives two points a, b on opposite sides. But `one_class` says a ~M b.
5. `one_class` being universal means `no_gaps_discrete`'s hypothesis (NOT contemp_equiv) is false for ALL pairs, so it doesn't directly help.
6. Instead: the Gap structure says the cut has no supremum and complement has no infimum. But in a discrete order, the cut being successor-closed means succ(max_cut) is in the cut (contradiction with no sup). Wait — that IS the proof of `gap_of_not_succ_archimedean` which constructs the Gap. We need the reverse.
7. Actually: we need NO Gap. If `one_class` gives us all equiv, can we derive no Gap?

The answer is: NOT directly from `one_class` alone. The `one_class` theorem tells us about contemp_equiv classes, but Gap is a topological property of the order.

**The actual bridge**: The key insight is that `chronicle_gap_contradiction` can now be proved using the sorry-free `one_class` + model surgery tools that were inaccessible before due to the import cycle (which was broken in task 155). The bridge should:

1. In `chronicle_gap_contradiction` (line 472): Build an `OrderedMonadicStructure` on `LimitDomSubtype`.
2. Prove `semantic_prior_UZ/SZ` (the commented-out proof at lines 488-762 shows exactly how to do this — the code is already written but commented out).
3. Apply `gap_contradicts_prior` from `GoodStructuresModelSurgery.lean` (sorry-free).

This is exactly what the commented-out proof at lines 488-762 attempts. The remaining sorry at line 741 (k=0 doesn't suffice, need k>=1) needs to be fixed by using k>=1 instead of k=0.

### 2.4 Type Signatures

**`gap_contradicts_prior`** (GoodStructuresModelSurgery.lean):
```lean
theorem gap_contradicts_prior (sig : MonadicSignature) (k : Nat)
    (M : OrderedMonadicStructure sig)
    [SuccOrder M.carrier] [PredOrder M.carrier]
    [NoMaxOrder M.carrier] [NoMinOrder M.carrier]
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (h_prior_UZ : semantic_prior_UZ M atomMap)
    (h_prior_SZ : semantic_prior_SZ M atomMap)
    (a : M.carrier)
    (h_succ_closed : ∀ c, contemp_equiv sig k M a c →
      contemp_equiv sig k M a (Order.succ c))
    (h_bounded : ∃ y, a < y ∧ ¬ contemp_equiv sig k M a y) :
    False
```

**`one_class`** (NoGapsDiscreteProof.lean):
```lean
theorem one_class (sig : MonadicSignature) (k : Nat) (M : OrderedMonadicStructure sig)
    [SuccOrder M.carrier] [PredOrder M.carrier]
    [NoMaxOrder M.carrier] [NoMinOrder M.carrier]
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (h_prior_UZ : semantic_prior_UZ M atomMap)  -- expanded form
    (h_prior_SZ : semantic_prior_SZ M atomMap)  -- expanded form
    : ∀ (a b : M.carrier), contemp_equiv sig k M a b
```

**`gap_of_not_succ_archimedean`** (ReynoldsNoGaps.lean):
```lean
theorem gap_of_not_succ_archimedean {T : Type} [LinearOrder T]
    [SuccOrder T] [PredOrder T] [NoMaxOrder T] [NoMinOrder T]
    (h_not_arch : ¬ @IsSuccArchimedean T inferInstance inferInstance) :
    Nonempty (Gap T)
```

### 2.5 Required Inputs to Build the Bridge

To apply `one_class` on `LimitDomSubtype`, we need:

1. **`OrderedMonadicStructure sig` on `LimitDomSubtype`**: carrier = LimitDomSubtype, interp maps predicates to MCS membership.
2. **`SuccOrder`, `PredOrder` instances**: Already exist as `limitDomSubtype_succOrder`, `limitDomSubtype_predOrder`.
3. **`NoMaxOrder`, `NoMinOrder` instances**: Already exist for LimitDomSubtype.
4. **`atomMap : Formula → sig.preds`**: Can use a singleton signature (Unit preds), mapping all formulas to ().
5. **`h_surj : ∀ p, ∃ a, atomMap (.atom a) = p`**: Trivially true for singleton sig.
6. **`semantic_prior_UZ/SZ`**: Must be proved using `limit_satisfies_c5_strong`, `limit_satisfies_c4`, etc. The commented-out code at lines 488-762 shows exactly how.

## 3. h_surj Analysis

### 3.1 h_surj Requirement

`h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p`

This says: every predicate symbol in the signature is the image of some atom formula.

### 3.2 Where h_surj is Used

- `no_gaps_discrete_model_surgery` requires `h_surj` (line 2133 of GoodStructuresModelSurgery.lean).
- `one_class` requires `h_surj` (line 88 of NoGapsDiscreteProof.lean).
- `gap_contradicts_prior` requires `h_surj`.

### 3.3 Satisfying h_surj

For the bridge, we use a **singleton signature** (as in the commented-out code at lines 512-534 of ChronicleToCountermodel.lean):
```lean
let sig : MonadicSignature := { preds := Unit, fintypePreds := inferInstance, decEqPreds := inferInstance }
let atomMap : Formula → sig.preds := fun _ => ()
have h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p := by
  intro (); exact ⟨⟨0⟩, rfl⟩
```

This trivially satisfies `h_surj` because there is only one predicate, and `atomMap (.atom ⟨0⟩) = ()`.

### 3.4 Transfer.lean's `countermodel_discrete_reynolds`

Transfer.lean uses `mkSigFrom φ` and `mkAtomMapFwd φ` to build an enriched signature with surjective forward atom map. The `mkAtomMapFwd_surj` theorem (line 291-293) provides the surjectivity:
```lean
theorem mkAtomMapFwd_surj (φ : Formula) :
    ∀ p : (mkSigFrom φ).preds, ∃ a : Atom, mkAtomMapFwd φ (.atom a) = p
```

This is already used by `countermodel_discrete_reynolds` and does NOT need modification. The `h_surj` for the bridge is separate — it's about building a monadic structure on `LimitDomSubtype`, not about Transfer.lean's signature.

## 4. Import Cycle Analysis

### 4.1 Current Import Graph (DAG)

```
ChronicleToCountermodel
  → ChronicleToCountermodelBasic
  → GoodStructuresModelSurgery
    → GoodStructures
    → ReynoldsNoGaps
    → NEquivalence → ChronicleExtraction → ChronicleToCountermodelBasic

Transfer
  → GoodStructures
  → ShiftAndGlue → GoodStructuresModelSurgery
  → ChronicleToCountermodel
```

### 4.2 Bridge Location Options

**Option 1: Modify `chronicle_gap_contradiction` in ChronicleToCountermodel.lean**

This is the simplest approach. `ChronicleToCountermodel.lean` already imports `GoodStructuresModelSurgery.lean` (line 2), so all Reynolds tools are accessible:
- `gap_contradicts_prior` (from GoodStructuresModelSurgery)
- `no_boundary_at_successor` (from GoodStructures, transitively)
- `contemp_equiv_is_equiv` (from GoodStructures, transitively)
- `one_class` (from NoGapsDiscreteProof, transitively via GoodStructuresModelSurgery)

Wait — does ChronicleToCountermodel import NoGapsDiscreteProof? Let me check:
- ChronicleToCountermodel imports GoodStructuresModelSurgery (line 2).
- NoGapsDiscreteProof imports GoodStructuresModelSurgery.
- But GoodStructuresModelSurgery does NOT import NoGapsDiscreteProof.

So `one_class` from NoGapsDiscreteProof is NOT accessible from ChronicleToCountermodel. However, `gap_contradicts_prior` IS accessible (it's in GoodStructuresModelSurgery itself).

The approach should use `gap_contradicts_prior` directly rather than `one_class`. The proof:
1. Build monadic structure on LimitDomSubtype.
2. Prove semantic_prior_UZ/SZ.
3. Pick arbitrary `a` in LimitDomSubtype.
4. Show `h_succ_closed` for `a`'s class (via `no_boundary_at_successor`).
5. Pick any `b > a` and check if `contemp_equiv`.
6. If NOT equiv: `gap_contradicts_prior` gives False. So there's no bounded orbit.
7. This eliminates `chronicle_gap_contradiction`.

But wait — `gap_contradicts_prior` requires that class(a) IS bounded above (by some y with a < y and NOT equiv). The current proof of `chronicle_gap_contradiction` has `a < b` and `h_orbit_bounded : ∀ n, succ^[n] a < b`. We need to show that a and b are NOT contemp_equiv (or rather, that the bounded orbit implies a gap).

The connection: the commented-out code at lines 488-762 already implements this approach. The issue was at line 741: `contemp_equiv` at depth k=0 is trivially true (no distinguishing formulas). The fix is to use k >= 1. With a singleton signature that has one predicate mapping to a distinguishing formula between `limit_f(a.val)` and `limit_f(b.val)`, contemp_equiv at k=1 can detect the difference.

**No new file needed.** The bridge code goes directly into `chronicle_gap_contradiction` in ChronicleToCountermodel.lean, replacing the sorry at line 486.

**No import cycle issues.** ChronicleToCountermodel already imports GoodStructuresModelSurgery.

### 4.3 Alternative: New file `IntegerModel/ReynoldsBridge.lean`

Not needed. The bridge is a modification of `chronicle_gap_contradiction`, not a new theorem. Creating a new file would require restructuring the private functions, which adds unnecessary complexity.

## 5. Recommended Implementation Order

### Phase 1: Boneyard Archive (Low risk, housekeeping)

1. Move `ReynoldsModelSurgery.lean` to `Boneyard/BXPipelineDeadCode/`.
2. Verify `lake build` still succeeds (no downstream imports).
3. Optionally move `countermodel_discrete` from Transfer.lean to Boneyard.

### Phase 2: Bridge Implementation (Core work, ~200-400 lines)

1. In `ChronicleToCountermodel.lean`, replace the sorry at line 486 in `chronicle_gap_contradiction` with:
   a. Build singleton `MonadicSignature` and `OrderedMonadicStructure` on `LimitDomSubtype`.
   b. Prove `semantic_prior_UZ` using `limit_satisfies_c5_strong` + `limit_satisfies_c4` + Prior-UZ axiom in MCS.
   c. Prove `semantic_prior_SZ` symmetrically.
   d. Case split on `limit_f(a.val) = limit_f(b.val)`:
      - **Different MCS case**: Pick distinguishing formula ψ. Build sig with one predicate tracking ψ-membership. Use k=1 (NOT k=0). Show a and b are NOT contemp_equiv. Apply `gap_contradicts_prior`.
      - **Same MCS case**: This is the hard case. The Z+Z counterexample applies to abstract structures, but chronicles have additional structure. The constant-MCS case requires showing that if limit_f is constant on the orbit, then the orbit actually covers all of LimitDomSubtype (making the bounded-orbit hypothesis vacuously false). This may still require a sorry or a separate lemma.

2. If the constant-MCS case proves intractable:
   - Focus on the different-MCS case (which covers the generic scenario).
   - For the constant-MCS case, use the structural property that chronicle construction generates non-constant MCS (the omega-chain inserts new points with different MCS values at each stage).

### Phase 3: Verification

1. Run `lake build` on the full project.
2. Run `#print axioms completeness_discrete` and verify `sorryAx` is gone.
3. Clean up deprecated comments and docstrings.

### Difficulty Assessment

- **Phase 1**: Trivial (file move + build check).
- **Phase 2, different-MCS case**: Medium. The commented-out code at lines 488-762 is essentially complete except for the k=0 bug. Fixing to k>=1 and cleaning up should be ~100-200 lines.
- **Phase 2, constant-MCS case**: Hard. This is the genuine blocker that was never resolved. The Z+Z counterexample means abstract arguments don't work. A chronicle-specific argument showing omega-chain stages produce non-constant MCS values is needed. Estimated ~100-300 lines if the proof is direct, or may require separate lemmas.

### Key Risk

The constant-MCS case (lines 493-500 in the commented-out code) may still require a sorry. If `limit_f(a.val) = limit_f(b.val)` for all pairs in the bounded orbit, no temporal formula distinguishes them, and `gap_contradicts_prior` cannot be applied. The resolution requires proving that the omega-chain construction guarantees non-constant MCS in any bounded orbit segment — this is plausible but non-trivial.
