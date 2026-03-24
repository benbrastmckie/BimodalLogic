# D=CanonicalMCS Removal Analysis

## Executive Summary

The D=CanonicalMCS pattern can be removed from the active completeness pipeline with minimal risk. The SuccChain completeness path (D=Int) already provides an independent, complete pipeline from `SuccChainFMCS.lean` through `SuccChainCompleteness.lean` that does NOT reference CanonicalMCS at any point. The "algebraic" completeness path (`AlgebraicBaseCompleteness.lean`) uses CanonicalMCS indirectly through `DirectMultiFamilyBFMCS`, but this path has 4 unsolved sorries of its own and is not the primary completeness theorem.

---

## 1. The Two Completeness Paths

### Path A: SuccChain Completeness (D=Int, ACTIVE)

```
SuccChainFMCS.lean       -- Int-indexed FMCS from Succ-chains
  -> SuccChainTaskFrame.lean   -- TaskFrame Int from CanonicalTask
  -> SuccChainWorldHistory.lean -- WorldHistory respecting CanonicalTask
  -> SuccChainTruth.lean       -- Truth lemma (phi in MCS <-> truth_at)
    -> SuccChainCompleteness.lean -- "valid phi -> provable phi"
```

**CanonicalMCS usage**: ZERO. This entire chain does not import CanonicalFMCS.lean or reference CanonicalMCS anywhere.

**Sorries in this path**:
1. `f_nesting_is_bounded` (SuccChainFMCS.lean:735) -- **mathematically false** for arbitrary MCS, deprecated, restricted version proven
2. `p_nesting_is_bounded` (SuccChainFMCS.lean:970) -- **mathematically false** for arbitrary MCS, deprecated, restricted version proven
3. `Box backward` (SuccChainTruth.lean:254) -- explicitly not needed for completeness

**Status**: The completeness theorem `succ_chain_completeness_standard` is proven modulo the 2 deprecated nesting sorries. The restricted versions (`f_nesting_boundary_restricted`, `p_nesting_boundary_restricted`) are fully proven for `RestrictedMCS`. Migration of `succ_chain_forward_F` and `succ_chain_backward_P` to use the restricted versions is the blocking work item (task 48).

### Path B: Algebraic Completeness (D=Int via BFMCS, BLOCKED)

```
CanonicalFMCS.lean           -- D=CanonicalMCS construction
  -> FMCSTransfer.lean         -- Transfer CanonicalMCS -> D
  -> ChainFMCS.lean            -- Chain-based FMCS over CanonicalMCS flags
  -> ClosedFlagBundle.lean     -- Closed flag set construction
  -> ClosedFlagIntBFMCS.lean   -- Int BFMCS from closed flags
  -> DirectMultiFamilyBFMCS.lean -- Multi-family BFMCS Int
    -> AlgebraicBaseCompleteness.lean -- "valid phi -> provable phi"
```

**CanonicalMCS usage**: HEAVY. This path fundamentally depends on D=CanonicalMCS for the intermediate steps, then transfers to D=Int.

**Sorries in this path** (4 active):
1. `directFamilies_modal_forward` -- cross-family transfer (S5 not provable in TM)
2. `directFamilies_modal_backward` at t!=0 -- chains leave closed set
3. `intFMCS_forward_F` -- F witness existence (dovetailing gap)
4. `intFMCS_backward_P` -- P witness existence (dovetailing gap)

**Status**: BLOCKED. The BFMCS cross-family modal coherence requirement is architecturally unprovable (documented in task 28 analysis). The file itself says the Succ-chain path is the "correct path for discrete completeness."

---

## 2. What Theorems Depend on D=CanonicalMCS?

### Direct Definitions/Theorems in CanonicalFMCS.lean

| Name | Type | Used By |
|------|------|---------|
| `CanonicalMCS` (structure) | Type definition | ChainFMCS, FMCSTransfer, ClosedFlagBundle, WitnessFamilyBundle, ModallyCoherentBFMCS, DirectMultiFamilyBFMCS, SaturatedBFMCSConstruction, MultiFamilyBFMCS, CanonicalQuot, LogicVariants |
| `Preorder CanonicalMCS` | Instance | All of the above |
| `canonicalMCSBFMCS` | `FMCS CanonicalMCS` | ModallyCoherentBFMCS, MultiFamilyBFMCS |
| `canonicalMCS_forward_F` | sorry-free F witness | temporal_coherent_family_exists_CanonicalMCS |
| `canonicalMCS_backward_P` | sorry-free P witness | temporal_coherent_family_exists_CanonicalMCS |
| `temporal_coherent_family_exists_CanonicalMCS` | Main theorem | LogicVariants.dense_components_export (broken reference) |

### Key Observation

`temporal_coherent_family_exists_CanonicalMCS` is the crown jewel of the D=CanonicalMCS approach: it is sorry-free because every MCS is trivially in the domain. However, it produces an `FMCS CanonicalMCS`, not an `FMCS Int`. No consumer actually uses this for a final completeness proof -- the SuccChain path builds `FMCS Int` directly, and the Algebraic path goes through `DirectMultiFamilyBFMCS` which has its own sorries.

---

## 3. FMCSTransfer Analysis

**File**: `Bundle/FMCSTransfer.lean`

**Purpose**: Transfer temporal coherence from CanonicalMCS to any target domain D via an embedding/retraction pair.

**Structure**: `FMCSTransfer D` with:
- `embed : CanonicalMCS ->o D` (monotone)
- `retract : D -> CanonicalMCS` (left inverse)
- Strict monotonicity conditions

**Usage**: Imported by `ClosedFlagIntBFMCS.lean` and referenced in comments of `AlgebraicBaseCompleteness.lean`. The algebraic completeness references `IntFMCSTransfer.construct_bfmcs_from_mcs_Int` but the import has been REMOVED (line 4: "REMOVED (Task 15)"). The actual `construct_bfmcs_from_mcs_Int` used is `construct_bfmcs_from_mcs_Int_v4` from DirectMultiFamilyBFMCS.

**Verdict**: FMCSTransfer is dead infrastructure. It was an attempt to bridge CanonicalMCS to Int that was superseded by DirectMultiFamilyBFMCS (which also has blocking sorries). No active code instantiates `FMCSTransfer`.

---

## 4. File-by-File Impact Assessment

### Files to DELETE (dead code, only used by D=CanonicalMCS path):

| File | Reason |
|------|--------|
| `Bundle/CanonicalFMCS.lean` | Defines D=CanonicalMCS. Core of the pattern being removed. |
| `Bundle/FMCSTransfer.lean` | Dead infrastructure for CanonicalMCS -> D transfer. |
| `Bundle/ChainFMCS.lean` | Chain FMCS over `Flag CanonicalMCS`. Only imported by ModalWitnessData and WitnessFamilyBundle. |
| `Bundle/ClosedFlagBundle.lean` | Closed flag set construction. Only imported by ClosedFlagIntBFMCS. |
| `Bundle/ClosedFlagIntBFMCS.lean` | Int BFMCS from closed flags. Superseded by DirectMultiFamilyBFMCS. |
| `Bundle/WitnessFamilyBundle.lean` | Witness family for CanonicalMCS diamonds. Not used by any completeness path. |
| `Bundle/SaturatedBFMCSConstruction.lean` | Modal saturation over CanonicalMCS. Not imported by completeness files. |
| `Bundle/ModalWitnessData.lean` | Modal witness data using CanonicalMCS. Not imported by completeness files. |
| `Algebraic/CanonicalQuot.lean` | Antisymmetrization of CanonicalMCS. Not imported by any active code. |
| `Algebraic/MultiFamilyBFMCS.lean` | Multi-family BFMCS over CanonicalMCS. Not imported by completeness files. |

### Files to REFACTOR (remove CanonicalMCS references):

| File | Change Needed |
|------|---------------|
| `Bundle/ModallyCoherentBFMCS.lean` | Remove CanonicalFMCS import. Some theorems about `discreteClosedMCS` use CanonicalMCS -- check if DirectMultiFamilyBFMCS depends on these. |
| `Bundle/DirectMultiFamilyBFMCS.lean` | Uses CanonicalMCS for `discreteClosedMCS M0`. This is the root parameterization. Refactor to accept `(M : Set Formula) (h_mcs : SetMaximalConsistent M)` directly. |
| `Bundle/FMCSDef.lean` | Only comments reference CanonicalMCS. Remove comments. |
| `Algebraic/AlgebraicBaseCompleteness.lean` | Remove CanonicalFMCS import. Remove deprecated `singleFamilyBFMCS` and `construct_bfmcs_from_mcs` (both sorry). The actual completeness uses `construct_bfmcs_from_mcs_Int` which goes through DirectMultiFamilyBFMCS. |
| `Algebraic/DiscreteInstantiation.lean` | Only comment references. Clean up. |
| `Algebraic/ParametricRepresentation.lean` | Only comment references. Clean up. |
| `BaseCompleteness.lean` | Remove CanonicalFMCS import. Only comment references. |
| `DenseCompleteness.lean` | Remove CanonicalFMCS import. Only comment references. |
| `DiscreteCompleteness.lean` | Remove CanonicalFMCS import. Only comment references. |
| `Completeness.lean` | Remove CanonicalMCS comment. |
| `LogicVariants.lean` | Remove CanonicalFMCS import. The `dense_components_export` theorem references `DenseCompleteness.dense_components_proven` which does NOT EXIST. This is already broken. Remove or rewrite. |

### Files UNAFFECTED (SuccChain path):

| File | Status |
|------|--------|
| `Bundle/SuccChainFMCS.lean` | No CanonicalMCS references |
| `Bundle/SuccChainTaskFrame.lean` | No CanonicalMCS references |
| `Bundle/SuccChainWorldHistory.lean` | No CanonicalMCS references |
| `Bundle/SuccChainTruth.lean` | No CanonicalMCS references |
| `Completeness/SuccChainCompleteness.lean` | No CanonicalMCS references |

---

## 5. The DirectMultiFamilyBFMCS Dependency

`DirectMultiFamilyBFMCS.lean` is the most complex dependency. It uses CanonicalMCS for:

1. **`variable (M0 : CanonicalMCS)`** -- the root MCS parameterization
2. **`discreteClosedMCS M0`** -- from ModallyCoherentBFMCS, a set of CanonicalMCS elements
3. **`DirectClosedFamily` struct** with `root : CanonicalMCS`
4. **`directFamilyFromRoot (w : CanonicalMCS)`** -- family construction

However, DirectMultiFamilyBFMCS has 4 blocking sorries and its own documentation says "the Succ-chain infrastructure bypasses BFMCS entirely" and recommends the SuccChain path.

**Decision point**: If the AlgebraicBaseCompleteness path is also being removed (or deprioritized), then DirectMultiFamilyBFMCS can be deleted entirely. If it is retained for future work, it needs refactoring to use a wrapper `struct MCSWrapper` instead of CanonicalMCS.

---

## 6. The 2 Remaining Sorries (f/p_nesting_is_bounded)

These are in `SuccChainFMCS.lean` and block the SuccChain completeness path:

### `f_nesting_is_bounded` (line 731-735)
```lean
@[deprecated f_nesting_is_bounded_restricted]
theorem f_nesting_is_bounded (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (phi : Formula) (h_F : Formula.some_future phi ∈ M) :
    ∃ n, n ≥ 2 ∧ iter_F n phi ∉ M := by
  sorry
```

**Status**: MATHEMATICALLY FALSE for arbitrary MCS. The restricted version `f_nesting_is_bounded_restricted` is proven for `RestrictedMCS`.

### `p_nesting_is_bounded` (line 966-970)
Symmetric. Also mathematically false for arbitrary MCS, restricted version proven.

### Migration Path

The callers are `succ_chain_forward_F` (line 811) and `succ_chain_backward_P` (line 1083). Both call the unrestricted `f/p_nesting_boundary`, which calls the sorry-backed `f/p_nesting_is_bounded`.

To eliminate these sorries:
1. Show that `succ_chain_fam M0 n` satisfies `RestrictedMCS` for an appropriate target formula
2. Call `f/p_nesting_boundary_restricted` instead of `f/p_nesting_boundary`

This is the subject of task 48 ("prove succ_chain_fam bounded f_depth") which has active research/planning.

**Important**: These sorries have NOTHING to do with D=CanonicalMCS. They exist in the SuccChain (D=Int) path and would need to be resolved regardless of whether CanonicalMCS is removed.

---

## 7. Recommended Refactoring Plan

### Phase 1: Delete Dead Code (Low Risk)

Delete these files (or move to Boneyard):
- `Bundle/FMCSTransfer.lean`
- `Bundle/ChainFMCS.lean`
- `Bundle/ClosedFlagBundle.lean`
- `Bundle/WitnessFamilyBundle.lean`
- `Bundle/SaturatedBFMCSConstruction.lean`
- `Bundle/ModalWitnessData.lean`
- `Algebraic/CanonicalQuot.lean`
- `Algebraic/MultiFamilyBFMCS.lean`

These files are not imported by any active completeness proof.

### Phase 2: Clean Imports (Low Risk)

Remove `import Bimodal.Metalogic.Bundle.CanonicalFMCS` from:
- `BaseCompleteness.lean` (only comments reference it)
- `DenseCompleteness.lean` (only comments reference it)
- `DiscreteCompleteness.lean` (only comments reference it)
- `LogicVariants.lean` (also fix broken `dense_components_proven` reference)

### Phase 3: Decide on Algebraic Path (Medium Risk)

Two options:

**Option A (Recommended): Delete Algebraic Path**
- Delete `Bundle/DirectMultiFamilyBFMCS.lean` (4 blocking sorries)
- Delete `Bundle/ClosedFlagIntBFMCS.lean`
- Delete/simplify `Algebraic/AlgebraicBaseCompleteness.lean`
- Delete `Bundle/ModallyCoherentBFMCS.lean`
- The SuccChain completeness becomes THE completeness theorem

**Option B: Retain Algebraic Path**
- Refactor DirectMultiFamilyBFMCS to not use CanonicalMCS
- Replace with a simple `(M : Set Formula, h_mcs : SetMaximalConsistent M)` wrapper
- 4 sorries remain, but they are independent of CanonicalMCS

### Phase 4: Delete CanonicalFMCS.lean (Depends on Phase 1-3)

Once all importers are removed, delete `Bundle/CanonicalFMCS.lean` itself.

### Phase 5: Clean FMCSDef.lean Comments

Remove D=CanonicalMCS commentary from `Bundle/FMCSDef.lean`.

---

## 8. Risk Assessment

| Risk | Level | Mitigation |
|------|-------|------------|
| Breaking SuccChain completeness | **None** | SuccChain never references CanonicalMCS |
| Breaking Algebraic completeness | **Low** | Already blocked by 4 sorries |
| Losing proven infrastructure | **Low** | `canonicalMCS_forward_F/backward_P` proofs are elegant but unused by any completeness theorem |
| Build breakage from import removal | **Medium** | Transitive imports may bring in CanonicalFMCS unexpectedly; need careful build testing |
| Losing dense completeness infrastructure | **None** | DenseCompleteness.lean only has comment references; the actual dense path uses SuccChain |

---

## 9. Summary

The D=CanonicalMCS pattern is an elegant proof-theoretic trick that trivializes F/P witness obligations, but it:

1. **Never feeds into a complete completeness proof** -- the temporally coherent family it produces (FMCS CanonicalMCS) is never successfully transferred to a concrete domain in a sorry-free manner
2. **Is architecturally orphaned** -- FMCSTransfer is dead, the Algebraic path has 4 blocking sorries
3. **Is completely bypassed** by the SuccChain path which builds D=Int directly
4. **Conflates world states with timeline positions** as the user correctly identifies

The SuccChain completeness path is already the primary completeness theorem. Removing D=CanonicalMCS is primarily a cleanup operation -- deleting 8-10 files of dead infrastructure and cleaning imports from 5-6 files. The two blocking sorries in the codebase (`f/p_nesting_is_bounded`) are in the SuccChain path and are unrelated to CanonicalMCS.
