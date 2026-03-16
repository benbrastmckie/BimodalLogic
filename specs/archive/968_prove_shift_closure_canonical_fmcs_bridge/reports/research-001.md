# Research Report: Shift-Closure and BFMCS-to-Standard Bridge (Task 968)

**Task**: 968 - prove_shift_closure_canonical_fmcs_bridge
**Session ID**: sess_1773620518_ce6f70
**Started**: 2026-03-15
**Status**: Complete

## Executive Summary

This research examines task 968 in light of completed tasks 967 (reflexive temporal semantics + T-axioms) and 969 (TaskFrame refactoring to forward_comp + converse). Key findings:

1. **ShiftClosed infrastructure is complete** - `ShiftClosed`, `time_shift`, `time_shift_preserves_truth` are all implemented and sorry-free
2. **CanonicalOmega is NOT shift-closed** by design (comment in CanonicalConstruction.lean:295)
3. **Boneyard has working shift-closure enlargement** - `shiftClosedCanonicalOmega` pattern can be adapted
4. **Tasks 967/969 do not change the fundamental shift-closure approach** but simplify the proof structure
5. **The BFMCS-to-standard bridge requires a shifted truth lemma** (proven in Boneyard)

## Changes from Tasks 967 and 969

### Task 967: Reflexive Temporal Semantics

**Key Changes**:
- Temporal operators G/H use `<=` instead of `<` (reflexive semantics)
- T-axioms (`G phi -> phi`, `H phi -> phi`) are now valid and proven
- `temp_t_future` and `temp_t_past` soundness proofs added
- Gabbay IRR proof completed (canonicalR_irreflexive is now a theorem)

**Impact on Task 968**:
- FMCSDef.lean still uses STRICT inequalities (`t < t'`) for `forward_G`/`backward_H`
- This is CORRECT: FMCS coherence is about propagation to strictly different times
- The reflexive semantics enables T-axioms at the semantic level, not the FMCS level
- No changes needed to shift-closure approach

### Task 969: TaskFrame Refactoring

**Key Changes**:
- `nullity + compositionality` replaced with `nullity_identity + forward_comp + converse`
- `canonical_task_rel` handles negative durations via `CanonicalR N.val M.val`
- `converse` axiom: `task_rel M d N <-> task_rel N (-d) M`
- Compositionality restricted to non-negative durations

**Impact on Task 968**:
- The `to_history` function in CanonicalConstruction.lean is already compatible
- `respects_task` only evaluates at `d = t - s >= 0` (when `s <= t`)
- No changes needed to WorldHistory construction from FMCS
- The converse axiom may simplify some time-shift proofs

## Current Infrastructure Analysis

### ShiftClosed Definition (Truth.lean:232)

```lean
def ShiftClosed (Omega : Set (WorldHistory F)) : Prop :=
  forall sigma in Omega, forall (Delta : D), WorldHistory.time_shift sigma Delta in Omega
```

**Status**: Complete, sorry-free

### time_shift_preserves_truth (Truth.lean:345-499)

The key theorem that truth is preserved under time-shift. Requires `ShiftClosed Omega` for the box case.

**Status**: Complete, sorry-free

### CanonicalOmega (CanonicalConstruction.lean:298)

```lean
def CanonicalOmega (B : BFMCS Int) : Set (WorldHistory CanonicalTaskFrame) :=
  { tau | exists fam in B.families, tau = to_history fam }
```

**Important Comment (line 295-296)**:
> "This set is NOT necessarily ShiftClosed. ShiftClosed is not needed for the TruthLemma (only for the connection to standard validity)."

**Status**: Deliberately not shift-closed; shift-closure is a completeness-level concern

### Boneyard Shift-Closure Pattern (Boneyard/IntRepresentation/Representation.lean)

The Boneyard contains a complete pattern for shift-closed canonical Omega:

```lean
-- Line 180
def shiftClosedCanonicalOmega (B : BFMCS Int) : Set (WorldHistory (canonicalFrame B)) :=
  { sigma | exists (fam : FMCS Int) (hfam : fam in B.families) (delta : Int),
    sigma = WorldHistory.time_shift (canonicalHistory B fam hfam) delta }

-- Line 205
theorem shiftClosedCanonicalOmega_is_shift_closed (B : BFMCS Int) :
    ShiftClosed (shiftClosedCanonicalOmega B)
```

**Key Insight**: The shift-closure enlargement works by including ALL time-shifts of canonical histories, not just the originals.

### Shifted Truth Lemma (Boneyard/IntRepresentation/Representation.lean:442)

```lean
theorem shifted_truth_lemma (B : BFMCS Int) (h_tc : B.temporally_coherent)
    (fam : FMCS Int) (hfam : fam in B.families) (t : Int) (phi : Formula) :
    phi in fam.mcs t <->
    truth_at (canonicalModel B) (shiftClosedCanonicalOmega B) (canonicalHistory B fam hfam) t phi
```

This theorem bridges BFMCS truth to standard `truth_at` with shift-closed Omega.

## FMCS Shift-Closure Theorem

### Theorem Statement

**Theorem (FMCS Shift-Closure)**: If `fam : FMCS D` is a valid FMCS family, then for any `Delta : D`, the shifted family `fam_Delta(t) := fam(t + Delta)` is also a valid FMCS.

### Proof Sketch

1. **is_mcs**: `fam_Delta(t) = fam(t + Delta)` is an MCS because `fam(t + Delta)` is an MCS (trivial)

2. **forward_G**: Need: if `t < t'` and `G phi in fam_Delta(t)`, then `phi in fam_Delta(t')`.
   - `fam_Delta(t) = fam(t + Delta)` and `fam_Delta(t') = fam(t' + Delta)`
   - `G phi in fam(t + Delta)`
   - `t < t'` implies `t + Delta < t' + Delta` (order-preserving translation)
   - By `fam.forward_G`: `phi in fam(t' + Delta) = fam_Delta(t')`

3. **backward_H**: Symmetric to forward_G.

**Key Insight**: All coherence conditions transfer because they are purely order-theoretic, and the order on D is translation-invariant.

### Theorem for TemporalCoherentFamily

If `fam` has `forward_F` and `backward_P` properties, then `fam_Delta` also has them:

- **forward_F**: Need: if `F phi in fam_Delta(t)`, then exists `s > t` with `phi in fam_Delta(s)`.
  - `F phi in fam(t + Delta)`
  - By `fam.forward_F`: exists `s' > t + Delta` with `phi in fam(s')`
  - Let `s = s' - Delta`. Then `s > t` and `fam_Delta(s) = fam(s') contains phi`.

- **backward_P**: Symmetric.

## Implementation Strategy

### Option A: Adapt Boneyard Pattern (Recommended)

The Boneyard `IntRepresentation/Representation.lean` contains complete, working infrastructure for:

1. `shiftClosedCanonicalOmega` construction
2. Proof that it is shift-closed
3. Shifted truth lemma connecting BFMCS to standard semantics

**Approach**:
1. Port `shiftClosedCanonicalOmega` pattern to active codebase
2. Adapt to use `CanonicalTaskFrame` from `CanonicalConstruction.lean`
3. Port `shifted_truth_lemma` using the existing `canonical_truth_lemma`

### Option B: FMCS Shift-Closure Theorem (Simpler but Different)

Instead of enlarging Omega with time-shifts, prove that if B.families is closed under shifting, then CanonicalOmega is already shift-closed.

**Approach**:
1. Define `FMCS.shift (fam : FMCS D) (Delta : D) : FMCS D`
2. Prove `FMCS.shift_is_fmcs`
3. Add condition to BFMCS that families are closed under shifting
4. Prove `CanonicalOmega_shift_closed` under this condition

**Issue**: This changes the BFMCS construction requirements, which may have downstream effects.

### Option C: Direct Bridge (Most Direct)

Prove the bridge theorem directly:
```lean
theorem bmcs_truth_to_truth_at (B : BFMCS Int) (h_tc : B.temporally_coherent)
    (fam : FMCS Int) (hfam : fam in B.families) (t : Int) (phi : Formula) :
    phi in fam.mcs t <-> truth_at CanonicalTaskModel Omega tau t phi
```

Where `Omega = shiftClosedCanonicalOmega B` and `tau = to_history fam`.

## Dependency Analysis

### Task 956 (Canonical Task Relation)

**Prior Research Indicated**: Task 968 depends on task 956 for the canonical task relation.

**Current Status**: The canonical task relation is COMPLETE in `CanonicalConstruction.lean`:
- `canonical_task_rel` is defined with `d > 0 -> CanonicalR M N`, `d = 0 -> M = N`, `d < 0 -> CanonicalR N M`
- `nullity_identity`, `forward_comp`, and `converse` are proven
- `CanonicalTaskFrame` is constructed

**Conclusion**: Task 956 dependency appears to be satisfied. The "canonical task relation" infrastructure is in place.

### Remaining Work for Task 968

1. **FMCS shift-closure theorem** (new theorem, trivial)
2. **ShiftClosedCanonicalOmega construction** (port from Boneyard or new)
3. **Shifted truth lemma** (port from Boneyard or prove directly)
4. **Standard completeness connection** (use shifted truth lemma)

## Recommendations

### Phase 1: FMCS Shift Infrastructure

Create `FMCSShift.lean` or add to `FMCSDef.lean`:

```lean
def FMCS.shift (fam : FMCS D) (Delta : D) : FMCS D where
  mcs := fun t => fam.mcs (t + Delta)
  is_mcs := fun t => fam.is_mcs (t + Delta)
  forward_G := -- translate fam.forward_G
  backward_H := -- translate fam.backward_H

theorem FMCS.shift_of_temporal_coherent (fam : TemporalCoherentFamily D) (Delta : D) :
    -- forward_F and backward_P also shift
```

### Phase 2: ShiftClosedCanonicalOmega

Port the pattern from Boneyard to `CanonicalConstruction.lean`:

```lean
def ShiftClosedCanonicalOmega (B : BFMCS Int) : Set (WorldHistory CanonicalTaskFrame) :=
  { tau | exists fam hfam delta, tau = WorldHistory.time_shift (to_history fam) delta }

theorem ShiftClosedCanonicalOmega_is_shift_closed (B : BFMCS Int) :
    ShiftClosed (ShiftClosedCanonicalOmega B)
```

### Phase 3: Shifted Truth Lemma

Port or prove:

```lean
theorem shifted_canonical_truth_lemma (B : BFMCS Int) (h_tc : B.temporally_coherent)
    (fam : FMCS Int) (hfam : fam in B.families) (t : Int) (phi : Formula) :
    phi in fam.mcs t <->
    truth_at CanonicalTaskModel (ShiftClosedCanonicalOmega B) (to_history fam) t phi
```

### Phase 4: Completeness Connection

Connect to `semantic_consequence`:

```lean
theorem context_completeness (Gamma : List Formula) (phi : Formula) :
    (Gamma proves phi) <-> (Gamma semantic_consequence phi)
```

## Sorries Analysis

### Current Active Codebase Sorries

From `TemporalCoherentConstruction.lean`:
- `temporal_coherent_family_exists_Int` (line 422) - 1 sorry for F/P witnesses
- `fully_saturated_bfmcs_exists_int` (line 516) - 1 sorry for combined construction

### Task 968 Expected Sorries

Following zero-debt policy:
- FMCS shift-closure: 0 sorries (trivial proofs)
- ShiftClosedCanonicalOmega: 0 sorries (constructive)
- Shifted truth lemma: depends on upstream sorries in `fully_saturated_bfmcs_exists_int`

## Conclusion

Task 968 is **feasible** with current infrastructure:

1. **ShiftClosed infrastructure is complete** and sorry-free
2. **Boneyard contains working patterns** that can be ported
3. **Tasks 967/969 do not block** this work - they simplify it
4. **Task 956 dependency appears satisfied** - canonical task relation is in place

**Recommended Approach**: Port the `shiftClosedCanonicalOmega` and `shifted_truth_lemma` patterns from `Boneyard/IntRepresentation/Representation.lean` to the active codebase, adapting for `CanonicalTaskFrame` from `CanonicalConstruction.lean`.

**Estimated Effort**: Medium - mostly porting and adapting existing proven code.

**Risk**: The upstream `fully_saturated_bfmcs_exists_int` sorry affects whether completeness proofs can be fully sorry-free. However, the shift-closure and bridge theorems themselves can be sorry-free.
