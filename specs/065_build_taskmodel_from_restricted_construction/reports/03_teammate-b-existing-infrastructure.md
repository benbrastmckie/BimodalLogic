# Teammate B: Existing Infrastructure Analysis

## Summary

The codebase has substantial infrastructure for bundle-to-Omega completeness that is **mostly complete** but with one **remaining gap**: the model-theoretic glue connecting `BFMCS_Bundle` to `valid_over Int`. The algebraic core is sorry-free; only the semantic wiring has sorries.

**Key insight**: The existing `construct_bfmcs_bundle` uses **bundle-level temporal coherence** (F-witnesses in ANY family) rather than family-level (F-witnesses in SAME family). This is the correct approach for completeness and is fully implemented.

## Key Findings

### 1. Existing Omega Definitions

**Found**: Two parallel constructions exist:

| Component | Location | Purpose |
|-----------|----------|---------|
| `CanonicalOmega` | `Bundle/CanonicalConstruction.lean:317` | `{ tau | exists fam in B.families, tau = to_history fam }` |
| `ShiftClosedCanonicalOmega` | `Bundle/CanonicalConstruction.lean:337` | Enlargement with all time-shifts, proven shift-closed |
| `ParametricCanonicalOmega` | `Algebraic/ParametricHistory.lean:109` | Parametric (generic D) version |
| `ShiftClosedParametricCanonicalOmega` | `Algebraic/ParametricHistory.lean:122` | Parametric shift-closed version |

**Status**: Both are complete with shift-closure proofs.

The construction pattern:
```lean
def CanonicalOmega (B : BFMCS Int) : Set (WorldHistory CanonicalTaskFrame) :=
  { tau | exists fam in B.families, tau = to_history fam }

def ShiftClosedCanonicalOmega (B : BFMCS Int) : Set (WorldHistory CanonicalTaskFrame) :=
  { sigma | exists (fam : FMCS Int) (_ : fam in B.families) (delta : Int),
    sigma = WorldHistory.time_shift (to_history fam) delta }
```

### 2. History-from-Bundle Construction

**Found**: `to_history` and `parametric_to_history` convert FMCS to WorldHistory.

**Location**: `Bundle/CanonicalConstruction.lean:287`

```lean
def to_history (fam : FMCS Int) : WorldHistory CanonicalTaskFrame where
  domain := fun _ => True  -- Full Int domain
  convex := fun _ _ _ _ _ _ _ => True.intro
  states := fun t _ => <fam.mcs t, fam.is_mcs t>
  respects_task := ... -- Proven from FMCS forward_G
```

**Key design**: One history per FMCS family. The bundle contains **multiple families** (all shifted SuccChainFMCS from MCSes with same box-content). Each family becomes one history in Omega.

**How time shifts fit**: `ShiftClosedCanonicalOmega` includes `time_shift (to_history fam) delta` for all deltas. Theorem `shiftClosedCanonicalOmega_is_shift_closed` proves this is indeed shift-closed.

### 3. Bundle vs Family Coherence Resolution

**Found**: The codebase **explicitly uses bundle-level coherence**.

**Key distinction** (from `UltrafilterChain.lean:2745-2757`):

| Coherence Level | Definition | Used For |
|-----------------|------------|----------|
| Family-level | F-witness in SAME family | `BFMCS.temporally_coherent` (blocked) |
| Bundle-level | F-witness in ANY family | `BFMCS_Bundle` (working) |

**Implementation**:
```lean
structure BFMCS_Bundle where
  families : Set (FMCS Int)
  nonempty : families.Nonempty
  modal_forward : ... -- Box in any -> phi in ALL
  modal_backward : ... -- phi in ALL -> Box in any
  bundle_forward_F : forall fam in families, forall phi t,
    F(phi) in fam.mcs t ->
    exists fam' in families, exists s > t, phi in fam'.mcs s  -- ANY family!
  bundle_backward_P : ... -- Symmetric for P
  eval_family : FMCS Int
  eval_family_mem : eval_family in families
```

**Resolution**: The `boxClassFamilies` construction collects all shifted SuccChainFMCS from MCSes with the same box-content as M0. When F(phi) appears at time t in one family, `temporal_theory_witness_exists` provides an MCS W with phi. A new family is built from W and added to the bundle. The witness is in a DIFFERENT family but that's allowed by bundle-level coherence.

### 4. TaskFrame-from-Bundle

**Found**: `CanonicalTaskFrame` is constructed.

**Location**: `Bundle/CanonicalConstruction.lean:124-157`

```lean
def CanonicalWorldState : Type :=
  { M : Set Formula // SetMaximalConsistent M }

def canonical_task_rel (M : CanonicalWorldState) (d : Int) (N : CanonicalWorldState) : Prop :=
  if d > 0 then ExistsTask M.val N.val
  else if d < 0 then ExistsTask N.val M.val
  else M = N  -- d = 0
```

**CanonicalTaskFrame** (inferred from usage):
- `WorldState = CanonicalWorldState` (subtype of MCS)
- `D = Int`
- `task_rel = canonical_task_rel`

**CanonicalTaskModel**:
- Valuation: atomic p is true at MCS M iff `Formula.atom p in M`

### 5. Gap Analysis for Target Sorries

**Target sorries** (from `FrameConditions/Completeness.lean`):

| Sorry | Line | Status | Gap |
|-------|------|--------|-----|
| `bundle_validity_implies_provability` | 186-214 | Has sorry | Model-theoretic glue |
| `dense_completeness_fc` | 115-120 | Has sorry | Depends on above |
| `discrete_completeness_fc` | 158-163 | Has sorry | Depends on above |

**What's proven (sorry-free)**:
- `construct_bfmcs_bundle`: Build BFMCS_Bundle from MCS
- `boxClassFamilies_bundle_temporally_coherent`: Bundle-level F/P coherence
- `not_provable_implies_neg_consistent`: Contrapositive setup
- `mcs_neg_gives_countermodel`: phi NOT in MCS containing neg(phi)
- `bundle_completeness_contradiction`: Core algebraic completeness

**What's missing**:
The sorry in `bundle_validity_implies_provability` is at line 214:
```lean
-- The algebraic completeness path is sorry-free. The gap is in connecting
-- to the semantic valid_over definition.
sorry
```

**The gap**: Need to show that `valid_over Int phi` (semantic validity) implies `phi in M` for all MCS M. This requires:

1. Building `TaskModel` from `BFMCS_Bundle` (done: `CanonicalTaskModel`)
2. Building `Omega` from bundle (done: `ShiftClosedCanonicalOmega`)
3. Proving that `valid_over Int phi` implies truth in the canonical model
4. Proving the truth lemma: `truth_at CanonicalTaskModel Omega (to_history fam) t phi <-> phi in fam.mcs t`

**Truth lemma status**:
- `canonical_truth_lemma` (line 495): Proven for `CanonicalOmega`
- `shifted_truth_lemma` (line 652): Proven for `ShiftClosedCanonicalOmega`

**The actual gap**: The connection between `valid_over Int` (which quantifies over ALL TaskFrames, TaskModels, and shift-closed Omegas) and the SPECIFIC canonical model. Need to instantiate `valid_over Int phi` with the canonical model to get `truth_at CanonicalTaskModel ShiftClosedCanonicalOmega (to_history fam) 0 phi`, then apply the truth lemma.

## Existing Infrastructure Inventory

| Component | Location | Status |
|-----------|----------|--------|
| `BFMCS_Bundle` structure | `UltrafilterChain.lean:2758` | Complete |
| `construct_bfmcs_bundle` | `UltrafilterChain.lean:2853` | Complete |
| `boxClassFamilies` | `UltrafilterChain.lean:2546` | Complete |
| `CanonicalWorldState` | `CanonicalConstruction.lean:124` | Complete |
| `canonical_task_rel` | `CanonicalConstruction.lean:154` | Complete |
| `CanonicalTaskFrame` (implicit) | `CanonicalConstruction.lean` | Complete |
| `CanonicalTaskModel` | `CanonicalConstruction.lean` | Complete |
| `to_history` | `CanonicalConstruction.lean:287` | Complete |
| `CanonicalOmega` | `CanonicalConstruction.lean:317` | Complete |
| `ShiftClosedCanonicalOmega` | `CanonicalConstruction.lean:337` | Complete |
| `shiftClosedCanonicalOmega_is_shift_closed` | `CanonicalConstruction.lean:367` | Complete |
| `canonical_truth_lemma` | `CanonicalConstruction.lean:495` | Complete |
| `shifted_truth_lemma` | `CanonicalConstruction.lean:652` | Complete |
| `box_persistent` | `CanonicalConstruction.lean:415` | Complete |
| `mcs_neg_gives_countermodel` | `UltrafilterChain.lean:2915` | Complete |
| `bundle_completeness_contradiction` | `UltrafilterChain.lean:2931` | Complete |
| `not_provable_implies_neg_consistent` | `UltrafilterChain.lean:2950` | Complete |
| `bundle_validity_implies_provability` | `Completeness.lean:186` | **HAS SORRY** |
| `dense_completeness_fc` | `Completeness.lean:115` | **HAS SORRY** |
| `discrete_completeness_fc` | `Completeness.lean:158` | **HAS SORRY** |

## Recommended Path Forward

**Do NOT build new restricted construction**. The existing infrastructure is almost complete.

**The remaining work** for task 65/66 should be:

1. **Instantiate `valid_over Int`**: Given `h_valid : valid_over Int phi`, instantiate with:
   - `F := CanonicalTaskFrame`
   - `M := CanonicalTaskModel`
   - `Omega := ShiftClosedCanonicalOmega B`
   - `tau := to_history B.eval_family`
   - `t := 0`

   This gives: `truth_at CanonicalTaskModel (ShiftClosedCanonicalOmega B) (to_history B.eval_family) 0 phi`

2. **Apply truth lemma**: The `shifted_truth_lemma` gives:
   `phi in B.eval_family.mcs 0 <-> truth_at CanonicalTaskModel (ShiftClosedCanonicalOmega B) (to_history B.eval_family) 0 phi`

3. **Conclude**: From (1) and (2): `phi in B.eval_family.mcs 0`

4. **Connect to MCS**: `B.eval_family.mcs 0 = M` (by `construct_bfmcs_bundle_eval_at_zero`)

**Estimated effort**: Small - the pieces exist, just need wiring.

## Confidence Level

**High** (90%)

The infrastructure analysis is based on direct code inspection. The gap is clearly identified in the comments at `Completeness.lean:207-214`. The existing truth lemmas (`canonical_truth_lemma`, `shifted_truth_lemma`) are complete and directly applicable.

The only uncertainty is whether there's a subtle type mismatch when instantiating `valid_over` with the canonical model (e.g., universe levels, implicit arguments). This should be checkable by attempting the instantiation in Lean.

## Key Code References

- **Bundle construction**: `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean:2853`
- **Truth lemma**: `Theories/Bimodal/Metalogic/Bundle/CanonicalConstruction.lean:652`
- **Target sorry**: `Theories/Bimodal/FrameConditions/Completeness.lean:214`
- **valid_over definition**: `Theories/Bimodal/FrameConditions/Validity.lean:53`
