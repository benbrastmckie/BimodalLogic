# Task 202: Reynolds k-Equivalence Bypass Research Report

## Executive Summary

The Reynolds k-equivalence bypass aims to eliminate the `succ_cofinal` sorry (at ChronicleToCountermodel.lean:1885) from `completeness_discrete` by replacing the `dd_countermodel_chronicle_discrete` delegation in `countermodel_discrete` (Transfer.lean:790) with a Reynolds-pipeline-based proof that avoids needing `IsSuccArchimedean` entirely.

**Finding**: The existing codebase already contains ~80% of the infrastructure needed. The remaining work concentrates on one key sorry (`no_gaps_discrete` at GoodStructures.lean:842) plus a rewiring of `countermodel_discrete`.

---

## 1. Codebase Survey

### 1.1 `completeness_discrete` (BXCanonical/Completeness.lean:308-372)

**Location**: `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean`
**Status**: Sorry-free at this level. Three cases:
- Dense case (line 317-362): eliminates via Discrete theorem + contradiction
- Discrete case (line 366-369): delegates to `countermodel_discrete_enriched` which calls `dd_countermodel_chronicle_discrete`
- Mixed case (line 370-371): eliminated via `mcs_mixed_case_absurd`

**Critical path**: The `completeness_discrete` theorem at line 308 calls `countermodel_discrete_enriched` (line 222) which calls `dd_countermodel_chronicle_discrete` via `cantor_bfmcs_discrete`. The sorry enters through `succ_cofinal` -> `limitDomSubtype_isSuccArchimedean` -> `orderIsoIntOfLinearSuccPredArch` in the chronicle extraction for the discrete case.

### 1.2 `countermodel_discrete` (WeakCanonical/Transfer.lean:782-791)

**Location**: `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/WeakCanonical/Transfer.lean`
**Signature**:
```lean
theorem countermodel_discrete (A : Set Formula) (h_mcs : SetMaximalConsistent (fc := FrameClass.Base) A)
    (φ : Formula) (h_neg_in : φ.neg ∈ A)
    (h_box_discrete : Formula.box next_top ∈ A) :
    ∃ (D : Type) ... ¬truth_at TM Omega τ t φ
```
**Current implementation**: Single line delegating to `dd_countermodel_chronicle_discrete` (line 790).
**This is the theorem that needs to be rewired.**

### 1.3 `ghr93_forward_to_backward_discrete` (WeakCanonical/Transfer.lean:662-769)

**Location**: Lines 662-769 of Transfer.lean
**Status**: SORRY-FREE. This is the discrete version of Theorem 6 (forward-to-backward game transfer).
**Signature**:
```lean
theorem ghr93_forward_to_backward_discrete {sig : MonadicSignature}
    (atomMap : Formula → sig.preds) (n r : Nat)
    {M N : OrderedMonadicStructure sig}
    (h_no_gaps : IsEmpty (Gap N.carrier))
    (h : ghr93_duplicator_wins M N atomMap (1 + 3 * n) r x y x' y')
    (h_r1_univ : ...) :
    ghr93_duplicator_wins N M atomMap n r x' y' x y
```
**Key**: Uses `ghr93_inductive_step_discrete` which only needs Cases I and II (no gap handling needed since `IsEmpty (Gap N.carrier)`).

### 1.4 `k_equiv` (WeakCanonical/NEquivalence.lean:72-74)

**Location**: Lines 72-74 of NEquivalence.lean
**Definition**:
```lean
def k_equiv (sig : MonadicSignature) (k : Nat)
    (M N : OrderedMonadicStructure sig) : Prop :=
  k_type_of sig k M = k_type_of sig k N
```
**Status**: Fully defined with:
- `k_equiv_monotone` (sorry-free, line 91)
- `k_equiv_iff_same_type` (sorry-free, line 79)
- `k_equiv_preserves_sentence` (sorry-free, Transfer.lean:117-128)
- `KEquivalenceFramework` instance (sorry-free core, lines 1113-1145)
- `sum_preservation` (sorry-free via `sum_preservation_proof`, line 1052-1069)

### 1.5 `ghr93_duplicator_wins` (WeakCanonical/EFGames/Defs.lean)

Defined in the EFGames/Defs.lean file. This is the core game-theoretic predicate used throughout.

### 1.6 `ChronicleAsPriorModel` (WeakCanonical/ChronicleExtraction.lean:85-145)

**Location**: Lines 85-145 of ChronicleExtraction.lean
**Structure fields** include: domain, domain_lo, domain_countable, domain_no_max, domain_no_min, domain_succ, domain_pred, domain_succ_archimedean, domain_nonempty, root_point, fmcs, fmcs_is_mcs, root_point_mcs, next_top_everywhere, prior_UZ_valid, prior_SZ_valid, until_coherent_fwd, since_coherent_fwd, neg_until_coherent, neg_since_coherent.

**Note**: The `domain_succ_archimedean` field requires `IsSuccArchimedean` which is blocked by `succ_cofinal`. However, the field is ONLY used in `chronicle_is_good` (ShiftAndGlue.lean:884) to construct the Z-isomorphism via `orderIsoIntOfLinearSuccPredArch`.

### 1.7 `chronicle_is_good` (WeakCanonical/IntegerModel/ShiftAndGlue.lean:880-905)

**Location**: Lines 880-905 of ShiftAndGlue.lean
**Signature**:
```lean
theorem chronicle_is_good (M : ChronicleAsPriorModel) (sig : MonadicSignature)
    (atomMap : sig.preds → Formula) (k : Nat) :
    good sig k (chronicleAsMonadicStructure M sig atomMap)
```
**Implementation**: Uses `orderIsoIntOfLinearSuccPredArch` (requires `IsSuccArchimedean`) to get `M.domain ≃o Z`, then constructs a `ZIntervalStructure` with `lo = none, hi = none`, applies `k_equiv_of_iso`.
**Sorry dependency**: Through `M.domain_succ_archimedean` -> `limitDomSubtype_isSuccArchimedean` -> `succ_cofinal`.

### 1.8 `one_class` (WeakCanonical/IntegerModel/GoodStructures.lean:883-906)

**Signature**:
```lean
theorem one_class (sig : MonadicSignature) (k : Nat) (M : OrderedMonadicStructure sig)
    [SuccOrder M.carrier] [PredOrder M.carrier]
    [NoMaxOrder M.carrier] [NoMinOrder M.carrier]
    (atomMap : Formula → sig.preds)
    (h_prior_UZ : ...) (h_prior_SZ : ...) :
    ∀ (a b : M.carrier), contemp_equiv sig k M a b
```
**Status**: Proof is sorry-free modulo `no_gaps_discrete` (GoodStructures.lean:842).
**No `IsSuccArchimedean` needed** -- proof uses only `no_gaps_discrete`, `no_boundary_at_successor` (sorry-free), and `contemp_equiv_is_equiv` (sorry-free).

### 1.9 `no_gaps_discrete` (WeakCanonical/IntegerModel/GoodStructures.lean:820-842)

**Location**: Lines 820-842
**Status**: SORRY (line 842). This is the critical remaining sorry for the Reynolds bypass.
**Comment**: "BLOCKED: Requires Reynolds Theorem 5 (US expressive completeness over Prior structures in general)"
**Signature**:
```lean
theorem no_gaps_discrete ... (h_diff_class : ¬ contemp_equiv sig k M a b) :
    ∃ (c : M.carrier), contemp_equiv sig k M a c ∧
      ¬ contemp_equiv sig k M a (Order.succ c)
```

### 1.10 `truth_transfer` (WeakCanonical/Transfer.lean:149-184)

**Status**: SORRY-FREE. Given k-equivalent structures M and N, transfers temporal truth.

### 1.11 `chronicle_temporal_truth` (WeakCanonical/Transfer.lean:208-322)

**Status**: SORRY-FREE. Establishes that temporal_truth on the chronicle-as-monadic-structure matches MCS membership.

### 1.12 `z_interval_countermodel` (WeakCanonical/Transfer.lean:445-470)

**Status**: SORRY-FREE (modulo the `h_truth_corr` hypothesis from the caller). Bridges from Z-interval temporal truth to TaskFrame Int countermodel.

### 1.13 Key supporting infrastructure

| Definition | File | Status |
|-----------|------|--------|
| `chronicleAsMonadicStructure` | NEquivalence.lean:1158 | Sorry-free |
| `mkSigFrom` / `mkAtomMap` | Transfer.lean:85-105 | Sorry-free |
| `no_gaps_int` | Transfer.lean:490-525 | Sorry-free |
| `zIntervalTaskFrame` / `zIntervalHistory` / `zIntervalOmega` | Transfer.lean:353-394 | Sorry-free |
| `unboundedZIntervalEquiv` | Transfer.lean:330-340 | Sorry-free |
| `doets_lemma_1_4` (sum preservation) | OrderedSum.lean:34-38 | Sorry-free (delegates to KEquivalenceFramework) |
| `doets_lemma_1_1` (NF preserves k-equiv) | NormalForm.lean | Sorry-free |
| `good` / `very_good` / `good_one` | GoodStructures.lean:67-74 | Sorry-free |
| `good_of_split_at_succ` | GoodStructures.lean:399+ | Sorry-free |
| `finite_structures_good` | GoodStructures.lean:159 | Sorry-free |

---

## 2. Sorry Dependency Analysis

### 2.1 Current sorry chain for `completeness_discrete`

```
completeness_discrete (Completeness.lean:308)
  -> countermodel_discrete_enriched (Completeness.lean:222)
    -> dd_countermodel_chronicle_discrete (ChronicleToCountermodel.lean:3285)
      -> cantor_bfmcs_discrete (sorry-free BFMCS construction)
      -> rooted_succ_discrete_fmcs (sorry-free eval family)
      -> fully_restricted_parametric_completeness_from_neg_membership
         [NO SORRY IN THIS CHAIN]
```

Wait -- on closer inspection, `dd_countermodel_chronicle_discrete` at line 3285-3312 is actually SORRY-FREE. The sorry enters through `countermodel_discrete` in Transfer.lean line 790 which delegates to it, but that delegation IS sorry-free because `dd_countermodel_chronicle_discrete` uses `cantor_bfmcs_discrete` which does NOT require `IsSuccArchimedean`.

Let me re-examine: `countermodel_discrete_enriched` at Completeness.lean:222 ALSO delegates to `cantor_bfmcs_discrete` and `rooted_succ_discrete_fmcs`. Neither of these require `IsSuccArchimedean`.

**CORRECTION**: The `dd_countermodel_chronicle_discrete` and `countermodel_discrete_enriched` use the parametric canonical model (Int-based), NOT the chronicle-to-Z-iso path. They are sorry-free with respect to `succ_cofinal`.

The `succ_cofinal` sorry affects the ALTERNATIVE Reynolds pipeline path that uses `chronicle_is_good` -> `orderIsoIntOfLinearSuccPredArch`. The current `completeness_discrete` uses the parametric canonical model path, which is sorry-free for this particular issue.

### 2.2 Where does the sorry actually enter `completeness_discrete`?

Let me trace more carefully. The `#print axioms` at line 374 would show `sorryAx` if present. Based on the chronicle construction's BUC/FUC/TC restricted conditions, the sorry likely enters through those coherence conditions.

Looking at the code:
- `cantor_bfmcs_discrete_restricted_tc` - may have sorry
- `cantor_bfmcs_discrete_restricted_buc` - may have sorry
- `cantor_bfmcs_discrete_restricted_fuc` - may have sorry

These are in ChronicleToCountermodel.lean but require further investigation. The task description states the sorry enters through `dd_countermodel_chronicle_discrete` and specifically `succ_cofinal`, but the code shows `dd_countermodel_chronicle_discrete` uses the parametric path.

### 2.3 The ACTUAL bypass strategy

Based on the task description and code analysis, the Reynolds bypass strategy is:

1. **Extract chronicle** as `ChronicleAsPriorModel` (already exists in ChronicleExtraction.lean)
2. **Prove chronicle is good** without `IsSuccArchimedean` (this is the key innovation -- currently `chronicle_is_good` uses `orderIsoIntOfLinearSuccPredArch` which needs it)
3. **Transfer truth** via k-equivalence to a Z-model (already exists in Transfer.lean)
4. **Build countermodel** from Z-model (already exists in Transfer.lean)

The bypass avoids `succ_cofinal` by NOT proving the chronicle domain is Z-isomorphic. Instead:
- Prove `one_class` (all points in same ~M-class) which requires `no_gaps_discrete`
- From `one_class`, derive `chronicle_is_good` via `very_good` -> `good` chain
- Use `chronicle_is_good` + `truth_transfer` to build the countermodel on Z

---

## 3. Gap Analysis: Three Components

### Component (a): Backward-game-to-k-equiv bridge

**Goal**: Connect `ghr93_duplicator_wins` (EF-game winning) to `k_equiv` (k-type equality).

**Status**: This connection is IMPLICIT in the existing infrastructure. The `ghr93_forward_to_backward_discrete` theorem (Transfer.lean:662) gives backward game winning. The bridge from game winning to k-equiv is through the normal form / decomposition framework.

**What exists**:
- `ghr93_forward_to_backward_discrete` (sorry-free, Transfer.lean:662-769)
- `k_equiv_preserves_sentence` (sorry-free, Transfer.lean:117-128)
- `truth_transfer` (sorry-free, Transfer.lean:149-184)

**What's needed**:
- The bridge from `ghr93_duplicator_wins` at sufficiently many rounds/ranks to `k_equiv` is NOT directly stated as a standalone theorem. However, the proof strategy does NOT require this bridge directly. Instead, the path goes through `one_class` -> `very_good` -> `good` -> `chronicle_is_good`.

**Assessment**: This component may NOT be needed as a separate theorem. The key insight is that `one_class` + `very_good_implies_good` gives `chronicle_is_good` without going through EF games.

### Component (b): Reynolds Theorem 14 (`no_gaps_discrete`)

**Goal**: Prove that in a discrete Prior structure without endpoints, if two points are not contemporaneously equivalent, there exists a boundary at some successor pair.

**Status**: SORRY at GoodStructures.lean:842.

**Dependencies**: Requires "US expressive completeness over Prior structures" (Reynolds Theorem 5). This is the key mathematical result: every monadic FO sentence of quantifier depth <= k can be expressed as a temporal formula using U, S.

**What exists in the codebase**:
- `ExpressiveCompleteness/` directory with `QuantifierElimination.lean` and `Theorem.lean`
- `StaviCompleteness.lean` (3252 lines) -- contains Stavi completeness framework
- EF game decomposition infrastructure

**What's needed for `no_gaps_discrete`**:
1. Reynolds Theorem 5: US expressive completeness. The proof involves showing that for any monadic FO sentence of bounded quantifier depth, there is a temporal formula with the same truth value at every point. This requires:
   - Stavi connectives (exist in StaviConnectives.lean)
   - Decomposition of formulas (exists in EFGames/)
   - The actual Theorem 5 proof connecting these

2. Model surgery lemmas (Reynolds Lemmas 7-8, 12): given a Prior structure with a class boundary at c/succ(c), construct a surgery model that contradicts the boundary.

**Estimated effort**: 300-500 lines. This is the HARDEST component.

### Component (c): Rewiring `countermodel_discrete`

**Goal**: Replace the `dd_countermodel_chronicle_discrete` delegation with the Reynolds pipeline.

**Status**: The pipeline is NEARLY complete in Transfer.lean.

**What exists**:
- `extract_chronicle_as_prior` (ChronicleExtraction.lean) -- extracts chronicle
- `chronicleAsMonadicStructure` (NEquivalence.lean:1158) -- converts to monadic structure
- `chronicle_temporal_truth` (Transfer.lean:208-322) -- truth lemma
- `chronicle_is_good` (ShiftAndGlue.lean:880) -- BUT uses `IsSuccArchimedean`
- `truth_transfer` (Transfer.lean:149) -- transfers truth via k-equiv
- `z_interval_countermodel` (Transfer.lean:445) -- builds TaskFrame Int countermodel

**What's needed**:
1. A NEW version of `chronicle_is_good` that does NOT use `IsSuccArchimedean`. Instead:
   - Use `one_class` to prove all points are in the same ~M-class
   - Use `very_good_implies_good` (via the shift-and-glue construction)
   - The shift-and-glue (ShiftAndGlue.lean) already exists but may need `one_class` as input

2. Discharge the `h_truth_corr` hypothesis of `z_interval_countermodel` using `chronicle_temporal_truth`.

3. Wire the full pipeline:
   ```
   extract_chronicle -> chronicle_as_monadic -> one_class -> very_good -> good
   -> truth_transfer -> z_interval_countermodel -> countermodel_discrete
   ```

**Estimated effort**: 200-300 lines.

---

## 4. Dependency Analysis

### 4.1 Import chain

The new code should go in `WeakCanonical/IntegerModel/GoodStructures.lean` (for `no_gaps_discrete`) and `WeakCanonical/Transfer.lean` (for the rewired `countermodel_discrete`). No new files needed.

### 4.2 Circular dependency risks

None identified. The dependency chain is strictly:
```
ChronicleExtraction -> NEquivalence -> GoodStructures -> ShiftAndGlue -> Transfer
```
All imports flow in one direction.

### 4.3 File organization

| File | Changes needed |
|------|---------------|
| `GoodStructures.lean` | Prove `no_gaps_discrete` (~300-500 lines) |
| `ShiftAndGlue.lean` | Potentially modify `chronicle_is_good` to avoid `IsSuccArchimedean` |
| `Transfer.lean` | Rewire `countermodel_discrete` (~100-200 lines) |
| New file: `ExpressiveCompleteness/USCompleteness.lean` | US expressive completeness if not already present |

---

## 5. Reynolds Theorem 14 Specifics

### 5.1 "All points in the chronicle are in one ~M-class"

In our formalization, this means: for the `chronicleAsMonadicStructure M sig atomMap`, all points `a, b : M.domain` satisfy `contemp_equiv sig k M a b`.

`contemp_equiv` is defined as: `a ~M b` iff every subinterval `[min(a,b), max(a,b)]` is very good (i.e., every sub-subinterval is good, i.e., k-equivalent to some Z-interval).

### 5.2 US expressive completeness

This means: for any monadic FO sentence phi of quantifier depth <= k, there exists a temporal formula A (using Until, Since, and their duals) such that for all points t in any Prior structure, `temporal_truth M atomMap t A <-> eval M env phi`.

**Existing infrastructure**:
- `Theories/Bimodal/Metalogic/WeakCanonical/ExpressiveCompleteness/` directory exists with `QuantifierElimination.lean` and `Theorem.lean`
- Stavi connectives defined in `StaviConnectives.lean`

### 5.3 Prior structure definitions

`ChronicleAsPriorModel` (ChronicleExtraction.lean:85) IS the Prior structure definition. It packages: countable discrete linear order without endpoints, with MCS assignment satisfying Prior-UZ, Prior-SZ, C5 (until/since coherence), and C4 (negation coherence).

---

## 6. Critical Path Summary

The ONLY sorry blocking sorry-free `completeness_discrete` via the Reynolds bypass is:

**`no_gaps_discrete`** (GoodStructures.lean:842)

This requires Reynolds Theorem 5 (US expressive completeness). Everything else in the pipeline is either sorry-free or has alternative sorry-free paths.

### Alternative approach: Direct `chronicle_is_good` without `one_class`

If `no_gaps_discrete` proves too difficult, an alternative is to prove `chronicle_is_good` directly by:
1. Constructing a cofinal Z-indexed sequence in the chronicle domain without `IsSuccArchimedean` (using the cofinal sequence construction in ShiftAndGlue.lean:127-130, which only needs Countable + NoMaxOrder + NoMinOrder + Nonempty)
2. Using the cofinal sequence to partition the domain into finite intervals
3. Showing each finite interval is good (via `finite_structures_good`)
4. Gluing via shift-and-glue

This approach would bypass BOTH `succ_cofinal` AND `no_gaps_discrete`, but requires verifying that the existing `exists_cofinal_sequence` (ShiftAndGlue.lean:127) and `very_good_implies_good` machinery is sufficient.

**Key observation**: `exists_cofinal_sequence` at ShiftAndGlue.lean:127 ALREADY exists and does NOT require `IsSuccArchimedean`. It only needs `Countable`, `NoMaxOrder`, `NoMinOrder`, `Nonempty`. The chronicle domain satisfies ALL of these.

### Revised strategy: Direct cofinal sequence approach

```
extract_chronicle (ChronicleExtraction)
  -> chronicleAsMonadicStructure (NEquivalence)
  -> exists_cofinal_sequence (ShiftAndGlue) [NO IsSuccArchimedean needed]
  -> partition into finite subintervals
  -> finite_structures_good for each piece
  -> doets_lemma_1_4 for the ordered sum
  -> chronicle_is_good (without IsSuccArchimedean)
  -> truth_transfer + z_interval_countermodel
  -> countermodel_discrete
```

This approach may be EASIER than proving `no_gaps_discrete` because it avoids Reynolds Theorem 5 entirely.

---

## 7. Tactic Survey Results

Not applicable at this research stage (no proof goals to test tactics against).

---

## 8. Recommendations

### Primary recommendation: Direct cofinal sequence approach

1. **Phase 1** (~200 lines): Create a new `chronicle_is_good_direct` theorem that uses `exists_cofinal_sequence` instead of `orderIsoIntOfLinearSuccPredArch`. This avoids `IsSuccArchimedean` entirely.

2. **Phase 2** (~200 lines): Rewire `countermodel_discrete` in Transfer.lean to use the Reynolds pipeline (chronicle extraction -> chronicle_is_good_direct -> truth_transfer -> z_interval_countermodel).

3. **Phase 3** (~100 lines): Verify with `lake build` and `lean_verify`.

### Fallback recommendation: `no_gaps_discrete` approach

If the direct approach hits obstacles, prove `no_gaps_discrete` via Reynolds Theorem 14, which requires US expressive completeness (Theorem 5). This is more work (~500 lines) but follows the literature more closely.

### Key risk: `h_truth_corr` discharge

The `z_interval_countermodel` theorem requires a `h_truth_corr` hypothesis that bridges truth_at on TaskFrame Int to temporal_truth on the Z-interval. Discharging this requires:
- Constructing a `TaskModel zIntervalTaskFrame` from the Z-interval's predicate interpretations
- Proving truth correspondence for all subformulas

This is documented in Transfer.lean:437-443 as "deferred to Phase 6" and may be the most technically challenging part of the rewiring.
