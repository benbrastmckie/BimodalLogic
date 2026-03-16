# Research Report: Unified Truth Definition to Eliminate Bridge Theorems (Task 968)

**Task**: 968 - prove_shift_closure_canonical_fmcs_bridge
**Session ID**: sess_1773623046_07f34d
**Started**: 2026-03-15
**Status**: Complete

## Executive Summary

This research investigates whether bridge theorems between BFMCS truth and standard semantics can be eliminated through better architectural choices. Key findings:

1. **The gap is artificial**: `bmcs_truth_at` and `truth_at` are structurally identical when canonical definitions are aligned. The "bridge theorem" is really just proving this equivalence.

2. **CanonicalConstruction.lean already eliminates the intermediate**: The `canonical_truth_lemma` in `CanonicalConstruction.lean` (lines 327-476) proves MCS membership directly corresponds to `truth_at` with `CanonicalOmega`, bypassing `bmcs_truth_at` entirely.

3. **ShiftClosed is the remaining requirement**: The only bridge needed is from `CanonicalOmega` (not shift-closed) to `ShiftClosedCanonicalOmega` (shift-closed). This is needed because `valid` and `semantic_consequence` quantify over shift-closed Omega.

4. **Recommendation**: The shifted_truth_lemma in Boneyard/IntRepresentation/Representation.lean already implements the shift-closure bridge pattern. Port this to the active codebase.

## Detailed Analysis

### 1. Current Architecture and the "Gap"

**Two Truth Predicates**:

| Predicate | Location | Box Clause | Temporal Clause |
|-----------|----------|------------|-----------------|
| `bmcs_truth_at B fam t phi` | BFMCSTruth.lean:86 | `forall fam' in B.families, bmcs_truth_at B fam' t phi` | `forall s, t < s -> bmcs_truth_at B fam s phi` |
| `truth_at M Omega tau t phi` | Truth.lean:113 | `forall sigma in Omega, truth_at M Omega sigma t phi` | `forall s, t <= s -> truth_at M Omega tau s phi` |

**Observation**: These are structurally identical when:
- `Omega` = `{ tau | exists fam in B.families, tau = to_history fam }`
- `M.valuation w p` = `Formula.atom p in w.val`
- The temporal inequality aligns (strict vs reflexive)

### 2. Why bmcs_truth_at Exists (Historical Context)

The `bmcs_truth_at` predicate was introduced to:
1. Isolate the BFMCS bundle structure from TaskFrame/TaskModel
2. Enable proving the truth lemma before the canonical TaskFrame was defined
3. Work with `Preorder D` rather than `LinearOrderedAddCommGroup D`

**Key insight from research-006 (task 945)**: Once `CanonicalTaskFrame` and `CanonicalTaskModel` are defined correctly, `bmcs_truth_at` becomes redundant.

### 3. CanonicalConstruction.lean: The Direct Approach

`CanonicalConstruction.lean` implements the direct truth lemma:

```lean
theorem canonical_truth_lemma
    (B : BFMCS Int) (h_tc : B.temporally_coherent)
    (fam : FMCS Int) (hfam : fam in B.families)
    (t : Int) (phi : Formula) :
    phi in fam.mcs t <->
      truth_at CanonicalTaskModel (CanonicalOmega B) (to_history fam) t phi
```

This theorem directly connects MCS membership to `truth_at` WITHOUT going through `bmcs_truth_at`. The intermediate is eliminated.

**Design choices that enable this**:
1. `CanonicalWorldState` = `{ M : Set Formula // SetMaximalConsistent M }` (MCS pairs)
2. `to_history` has full domain: `domain := fun _ => True`
3. `CanonicalOmega B` = `{ tau | exists fam in B.families, tau = to_history fam }`

### 4. The Remaining Gap: Shift-Closure

**Problem**: `valid` and `semantic_consequence` require `ShiftClosed Omega`:

```lean
def valid (phi : Formula) : Prop :=
  forall ... (Omega : Set (WorldHistory F)) (h_sc : ShiftClosed Omega) ...,
    truth_at M Omega tau t phi
```

But `CanonicalOmega B` is **NOT** shift-closed (as noted in CanonicalConstruction.lean:295-296).

**Why not shift-closed**: `CanonicalOmega B` contains exactly one history per FMCS family. Shifting a history `to_history fam` by Delta gives a history that does NOT correspond to any family in `B.families` (unless we explicitly add it).

### 5. Options to Achieve Shift-Closure

#### Option A: Enlarge Omega (Boneyard Approach)

Define `ShiftClosedCanonicalOmega B` to include all shifts:

```lean
def ShiftClosedCanonicalOmega (B : BFMCS Int) : Set (WorldHistory CanonicalTaskFrame) :=
  { tau | exists fam in B.families, exists delta : Int,
    tau = WorldHistory.time_shift (to_history fam) delta }
```

**Pros**: Already implemented in Boneyard/IntRepresentation/Representation.lean
**Cons**: Requires `shifted_truth_lemma` to handle the box case (since shifted histories aren't directly from FMCS families)

#### Option B: Close BFMCS Under Shifting

Require `B.families` to be closed under FMCS shifting:

```lean
def FMCS.shift (fam : FMCS D) (Delta : D) : FMCS D where
  mcs := fun t => fam.mcs (t + Delta)
  is_mcs := fun t => fam.is_mcs (t + Delta)
  forward_G := -- translate fam.forward_G
  backward_H := -- translate fam.backward_H

-- Property on BFMCS
def BFMCS.shift_closed (B : BFMCS D) : Prop :=
  forall fam in B.families, forall delta : D, fam.shift delta in B.families
```

**Pros**: `CanonicalOmega B` would be automatically shift-closed
**Cons**: Changes BFMCS construction requirements; may affect `construct_saturated_bfmcs_int`

#### Option C: Redefine validity to NOT require shift-closure

This would require proving MF/TF axioms sound without shift-closure, which is mathematically incorrect. The box case of `time_shift_preserves_truth` fundamentally needs shifted histories to remain in Omega.

**Rejected**: Not mathematically sound.

### 6. Analysis: Why Option A Works

The `shifted_truth_lemma` from Boneyard handles the box case differently:

**Box Forward (the hard case)**:
- Have: `Box psi in fam.mcs t`
- Need: `truth_at M (ShiftClosedCanonicalOmega B) sigma t psi` for all sigma in enlarged Omega
- sigma = `time_shift (to_history fam') delta` for some fam', delta

**Solution (box_persistent)**:
1. By TF axiom: `Box psi -> G(Box psi)` is in MCS
2. By past-TF (temporal duality): `Box psi -> H(Box psi)` is in MCS
3. Therefore: `Box psi in fam.mcs (t + delta)` for any delta
4. By modal_forward: `psi in fam'.mcs (t + delta)`
5. By IH: `truth_at M ShiftClosedCanonicalOmega (to_history fam') (t + delta) psi`
6. By time_shift_preserves_truth: `truth_at M ShiftClosedCanonicalOmega (time_shift (to_history fam') delta) t psi`

The key insight: `box_persistent` (Representation.lean:251-276) proves that if Box phi is in an MCS at any time, it's in the MCS at ALL times. This uses TF and its temporal dual.

### 7. Architectural Recommendation

**Use Option A (Enlarge Omega)** because:

1. It's already implemented and proven in Boneyard
2. It doesn't change the BFMCS construction
3. It cleanly separates concerns:
   - `canonical_truth_lemma`: MCS membership <-> truth at CanonicalOmega
   - `shifted_truth_lemma`: MCS membership <-> truth at ShiftClosedCanonicalOmega
   - The connection uses `box_persistent` + `time_shift_preserves_truth`

### 8. Is This Really a "Bridge Theorem"?

**Technically yes**, but it's architecturally clean:

The `shifted_truth_lemma` is not bridging between two DIFFERENT semantics. It's extending the truth lemma from a smaller Omega to a larger shift-closed Omega. Both use the same `truth_at` predicate.

**More precisely**:
- `canonical_truth_lemma`: works for CanonicalOmega
- `shifted_truth_lemma`: works for ShiftClosedCanonicalOmega
- The difference is ONLY in which set of histories the box quantifies over

The box forward case requires extra work because shifted histories aren't directly canonical. But this is unavoidable: we need ShiftClosed for soundness of interaction axioms.

### 9. Can We Avoid ANY Bridge?

**Only if we change the definitions fundamentally**:

1. **Change `valid` to NOT require ShiftClosed**: Mathematically unsound.

2. **Require BFMCS families to be shift-closed (Option B)**: This pushes the "bridge" into the BFMCS construction. Instead of bridging truth lemmas, we'd bridge BFMCS construction.

3. **Use BFMCS truth directly for completeness**: This is what `bmcs_truth_lemma` + `bmcs_valid` do. But then we have a different notion of validity (`bmcs_valid` vs `valid`), and we'd need to prove they're equivalent anyway.

**Conclusion**: Some form of bridge is unavoidable. The cleanest architecture is:
- Prove `canonical_truth_lemma` at CanonicalOmega (done in CanonicalConstruction.lean)
- Extend to `shifted_truth_lemma` at ShiftClosedCanonicalOmega (Boneyard pattern)
- Use ShiftClosedCanonicalOmega for standard completeness proofs

### 10. Gap Between Reflexive and Strict Temporal Semantics

**Current state**:
- `truth_at` uses REFLEXIVE temporal semantics: `s <= t` (task 967)
- `bmcs_truth_at` uses STRICT temporal semantics: `t < s`
- FMCS `forward_G`/`backward_H` use STRICT: `t < t'`

**Impact**: The truth lemmas must account for this difference. In `canonical_truth_lemma` (CanonicalConstruction.lean), the all_future case handles this correctly because:
- Forward: `forward_G` gives phi at strictly future times; reflexive case is immediate by MCS membership
- Backward: `temporal_backward_G` via temporally_coherent gives the contraposition argument

The reflexive semantics actually SIMPLIFIES the truth lemma because the base case (t = s) is handled by MCS membership directly.

## Summary of Findings

| Question | Answer |
|----------|--------|
| Can we avoid bridge theorems? | No, shift-closure is mathematically required |
| What's the minimal bridge? | `shifted_truth_lemma` extending canonical_truth_lemma |
| Is bmcs_truth_at necessary? | No, CanonicalConstruction.lean bypasses it |
| What should task 968 do? | Port shifted_truth_lemma from Boneyard to active codebase |

## Implementation Recommendation

### Phase 1: FMCS Shift-Closure Infrastructure

Add to `FMCSDef.lean` or new `FMCSShift.lean`:

```lean
def FMCS.shift (fam : FMCS D) (Delta : D) : FMCS D where
  mcs := fun t => fam.mcs (t + Delta)
  is_mcs := fun t => fam.is_mcs (t + Delta)
  forward_G := fun t t' phi htt' hG =>
    fam.forward_G (t + Delta) (t' + Delta) phi (by omega) hG
  backward_H := fun t s phi hst hH =>
    fam.backward_H (t + Delta) (s + Delta) phi (by omega) hH
```

### Phase 2: ShiftClosedCanonicalOmega in Active Codebase

Port from Boneyard/IntRepresentation/Representation.lean to CanonicalConstruction.lean:

```lean
def ShiftClosedCanonicalOmega (B : BFMCS Int) : Set (WorldHistory CanonicalTaskFrame) :=
  { tau | exists fam in B.families, exists delta : Int,
    tau = WorldHistory.time_shift (to_history fam) delta }

theorem ShiftClosedCanonicalOmega_is_shift_closed (B : BFMCS Int) :
    ShiftClosed (ShiftClosedCanonicalOmega B)
```

### Phase 3: box_persistent and shifted_truth_lemma

Port `box_persistent` (Representation.lean:251-276) and `shifted_truth_lemma` (Representation.lean:438-554) to active codebase.

### Phase 4: Standard Completeness

Use `shifted_truth_lemma` to prove:
- `standard_representation`
- `standard_weak_completeness`
- `standard_strong_completeness`

## Sorries Analysis

### Current State

From `TemporalCoherentConstruction.lean`:
- `temporal_coherent_family_exists_Int` (line 422) - 1 sorry for F/P witnesses
- `fully_saturated_bfmcs_exists_int` (line 516) - 1 sorry for combined construction

### Task 968 Expected Sorries

All theorems in task 968 scope are sorry-free given the existing infrastructure:
- FMCS shift-closure: trivial proofs using translation invariance
- ShiftClosedCanonicalOmega construction: constructive
- ShiftClosedCanonicalOmega_is_shift_closed: trivial
- box_persistent: uses TF axiom + temporal duality (both proven)
- shifted_truth_lemma: uses box_persistent + time_shift_preserves_truth (both proven)

Upstream sorry in `fully_saturated_bfmcs_exists_int` affects the completeness theorems that consume the BFMCS, but NOT the shift-closure/bridge infrastructure itself.

## References

- CanonicalConstruction.lean: Direct truth lemma implementation
- Boneyard/IntRepresentation/Representation.lean: Working shift-closure pattern
- Truth.lean: ShiftClosed definition and time_shift_preserves_truth
- TruthLemma.lean: bmcs_truth_lemma (historical, now bypassed)
- research-001.md: Prior research on task 968
- specs/0_shift_closure_research/reports/research-001.md: Deep shift-closure analysis
