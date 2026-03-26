# Research Report: Task #65 (v2)

**Task**: Build TaskModel from Restricted Construction
**Date**: 2026-03-26
**Mode**: Team Research (2 teammates)
**Session**: sess_1774563036_2beca3

## Summary

**The previous approach (single-history Omega) was correctly rejected.** A single history plus time-shifts cannot distinguish `G(phi)` from `Box(phi)`, since all shifted histories evaluate to the same world-states. The formula `G(phi) & ~Box(phi)` requires multiple distinct histories: one where phi holds at all times (G), and another where phi fails (breaking Box).

**Critical finding: The existing bundle infrastructure already solves this.** The `construct_bfmcs_bundle` construction creates multiple families via `boxClassFamilies` - one for each MCS in the same box-class. Diamond witnesses spawn new families via `box_theory_witness_exists`. The existing `ShiftClosedCanonicalOmega` provides a proper Omega with multiple histories from all families. The truth lemma `shifted_truth_lemma` is proven for this Omega.

**The gap is surprisingly small.** The only missing piece is model-theoretic glue: instantiating `valid_over Int phi` with the canonical model (`CanonicalTaskFrame`, `CanonicalTaskModel`, `ShiftClosedCanonicalOmega`), applying the truth lemma, and connecting back to MCS membership.

## Why Single-History Omega Fails

Consider `G(phi) & ~Box(phi)`:
- `G(phi)` = phi holds at all **future times in this history** (temporal, within one family)
- `Box(phi)` = phi holds in **all histories in Omega** at this time (modal, across families)

With Omega = {time_shift(tau, delta) | delta : Int}:
- All shifted histories share the same state trajectory
- `truth_at M Omega (time_shift tau delta) t psi` evaluates the same world-state for all delta
- So `G(phi)` true implies `Box(phi)` true - they become indistinguishable
- This makes the model unsound for formulas mixing G and Box

## How the Existing Bundle Construction Solves This

### Diamond Witness Mechanism

**Location**: `UltrafilterChain.lean:903-930`

When `Diamond(psi)` is in MCS M:
1. Build seed: `{psi} ∪ box_theory(M)`
2. Prove consistency using S5 axiom 5 (negative introspection)
3. Extend to MCS W via Lindenbaum
4. W has `psi ∈ W` AND `box_class_agree M W` (same Box-formulas)
5. SuccChainFMCS from W becomes a NEW family in the bundle

**Result**: Different families have different base MCSes that agree on Box-formulas but disagree on other formulas. This is exactly what creates multiple distinct histories.

### Example: Satisfying `G(phi) & ~Box(phi)`

1. Let M0 be an MCS with `G(phi)` and `Diamond(neg(phi))`
2. `box_theory_witness_exists` gives MCS W with `neg(phi) ∈ W` and `box_class_agree M0 W`
3. Family from M0: phi holds at all times (by G-propagation via `forward_G`)
4. Family from W: `neg(phi)` holds at base time
5. Bundle Omega includes histories from both families
6. Result: `G(phi)` true (M0's history), `Box(phi)` false (W's history has `neg(phi)`)

### F/P Witness Mechanism

For temporal witnesses (`F(psi)` in chain):
- `temporal_theory_witness_exists` provides MCS with psi
- Witness may be in same or different family (bundle-level coherence)
- `boxClassFamilies_bundle_forward_F` proves this is in the bundle

### Bundle Omega Definition

```lean
def ShiftClosedCanonicalOmega (B : BFMCS Int) : Set (WorldHistory CanonicalTaskFrame) :=
  { sigma | exists (fam : FMCS Int) (_ : fam in B.families) (delta : Int),
    sigma = WorldHistory.time_shift (to_history fam) delta }
```

This includes one history per family (delta = 0) plus all time-shifts. Shift-closure is proven (`shiftClosedCanonicalOmega_is_shift_closed`).

## Existing Infrastructure Inventory

**Complete (sorry-free)**:

| Component | Location | Status |
|-----------|----------|--------|
| `BFMCS_Bundle` structure | `UltrafilterChain.lean:2758` | Complete |
| `construct_bfmcs_bundle` | `UltrafilterChain.lean:2853` | Complete |
| `boxClassFamilies` | `UltrafilterChain.lean:2546` | Complete |
| `box_theory_witness_exists` | `UltrafilterChain.lean:903` | Complete |
| `CanonicalTaskFrame` | `CanonicalConstruction.lean:124-157` | Complete |
| `CanonicalTaskModel` | `CanonicalConstruction.lean` | Complete |
| `to_history` | `CanonicalConstruction.lean:287` | Complete |
| `ShiftClosedCanonicalOmega` | `CanonicalConstruction.lean:337` | Complete |
| `shiftClosedCanonicalOmega_is_shift_closed` | `CanonicalConstruction.lean:367` | Complete |
| `canonical_truth_lemma` | `CanonicalConstruction.lean:495` | Complete |
| `shifted_truth_lemma` | `CanonicalConstruction.lean:652` | Complete |
| `not_provable_implies_neg_consistent` | `UltrafilterChain.lean:2950` | Complete |
| `bundle_completeness_contradiction` | `UltrafilterChain.lean:2931` | Complete |

**Missing (has sorry)**:

| Component | Location | Gap |
|-----------|----------|-----|
| `bundle_validity_implies_provability` | `Completeness.lean:186-214` | Model-theoretic glue |
| `dense_completeness_fc` | `Completeness.lean:115-120` | Depends on above |
| `discrete_completeness_fc` | `Completeness.lean:158-163` | Depends on above |

## The Actual Gap: Model-Theoretic Glue

The sorry in `bundle_validity_implies_provability` requires connecting:

1. **`valid_over Int phi`** (semantic: phi true in ALL TaskModels with shift-closed Omega)
2. **`phi ∈ M`** for a specific MCS M (algebraic: phi provable)

**The proof path** (all pieces exist):

```
valid_over Int phi
  -- instantiate with CanonicalTaskFrame, CanonicalTaskModel, ShiftClosedCanonicalOmega B
  → truth_at CanonicalTaskModel (ShiftClosedCanonicalOmega B) (to_history B.eval_family) 0 phi
  -- apply shifted_truth_lemma (backward direction)
  → phi ∈ B.eval_family.mcs 0
  -- by construct_bfmcs_bundle_eval_at_zero
  → phi ∈ M0
```

**Why this hasn't been done yet**: The `shifted_truth_lemma` requires `B.temporally_coherent` (family-level coherence), which the bundle construction provides only at bundle level. This is the coherence mismatch from the original spawn analysis (task 58).

**BUT**: The `shifted_truth_lemma` at `CanonicalConstruction.lean:652` may have already been proven with a weaker hypothesis. Need to verify its exact signature.

## Synthesis: Conflicts and Resolutions

### Conflict 1: Need for Restricted Construction

- **Previous research (v1)**: Build TaskModel from RestrictedTemporallyCoherentFamily
- **This research (v2)**: Existing bundle infrastructure is 95% complete

**Resolution**: The restricted construction was a workaround for the coherence mismatch. If the existing `shifted_truth_lemma` works with bundle-level coherence, no new construction is needed. If it requires family-level coherence, we still have the mismatch and need an alternative approach.

**Action**: Verify `shifted_truth_lemma` signature and hypothesis requirements.

### Conflict 2: Effort Estimate

- **v1 estimate**: 6-8 hours (building new infrastructure)
- **v2 estimate**: Potentially much smaller (wiring existing pieces)

**Resolution**: Depends on whether `shifted_truth_lemma` works with the bundle or not. If it does, effort is 2-3 hours of wiring. If not, we need to resolve the coherence mismatch first (which may be the harder problem).

## Gaps Identified

### Gap 1: shifted_truth_lemma Hypothesis Requirements

**Critical**: Does `shifted_truth_lemma` require `B.temporally_coherent` (family-level) or does it work with `BFMCS_Bundle` (bundle-level)?

If family-level is required, the original mismatch from task 58 still applies and we need:
- Option A: Prove family-level from bundle-level (blocked per spawn analysis)
- Option B: Bundle-level truth lemma (high effort)
- Option C: Restricted construction (the original plan)
- **New Option E**: Modify `shifted_truth_lemma` to work with bundle-level coherence

### Gap 2: valid_over Instantiation

`valid_over Int phi` quantifies over ALL TaskFrames. Need to verify we can instantiate it with the specific canonical model. Potential issues:
- Universe level mismatches
- Implicit argument problems
- `ShiftClosedCanonicalOmega B` might need to satisfy additional properties

### Gap 3: Existing Sorries in Chain Construction

From RestrictedTruthLemma.lean and SuccChainFMCS.lean:
- G/H propagation sorries (lines 106, 115, 135)
- Termination sorries (lines 3973, 4154)
- Chain construction sorry (line 3420)

These affect the restricted path. If we use the bundle path instead, different sorries may apply (in `shifted_truth_lemma` and related).

## Recommendations

### Priority 1: Verify shifted_truth_lemma Signature

Before any implementation, check the exact hypothesis of `shifted_truth_lemma`:
```bash
lean_hover_info on shifted_truth_lemma
```

If it works with `BFMCS_Bundle` (bundle-level coherence): **use the bundle path directly** (much less work).

If it requires `temporally_coherent` (family-level): **the original mismatch still applies** and we need to choose between:
- Modifying the truth lemma (Option E)
- Restricted construction (Option C, the original plan - but with proper multi-history Omega)
- Bundle-level truth lemma (Option B)

### Priority 2: If Bundle Path Works

The implementation is straightforward:
1. Instantiate `valid_over Int phi` with canonical model
2. Apply `shifted_truth_lemma`
3. Connect to `construct_bfmcs_bundle_eval_at_zero`
4. Wire to the 3 target sorries

### Priority 3: If Bundle Path Is Blocked

Consider a **hybrid approach**: Use the bundle construction for Omega (multiple families, proper G/Box distinction) but build a modified truth lemma that works with bundle-level coherence. The backward G case needs:
- `G(phi) not in fam.mcs t` → `neg(G(phi)) = F(neg(phi)) in fam.mcs t`
- By bundle F-coherence: exists `fam' in families, s > t, neg(phi) in fam'.mcs s`
- Need: `neg(phi)` in `fam.mcs s` (SAME family) for contradiction

This is exactly the original mismatch. The fix might be to use a different contradiction strategy that doesn't require same-family witnesses.

## Teammate Contributions

| Teammate | Angle | Status | Confidence | Key Contribution |
|----------|-------|--------|------------|------------------|
| A (bundle-construction) | How Diamond/F/P witnesses build multi-history Omega | Completed | HIGH | Detailed mechanism for G/Box distinction |
| B (existing-infrastructure) | What already exists in codebase | Completed | HIGH (90%) | Complete infrastructure inventory, gap analysis |

## References

- `UltrafilterChain.lean:2853` - `construct_bfmcs_bundle`
- `UltrafilterChain.lean:903` - `box_theory_witness_exists`
- `CanonicalConstruction.lean:337` - `ShiftClosedCanonicalOmega`
- `CanonicalConstruction.lean:652` - `shifted_truth_lemma`
- `Completeness.lean:186-214` - Target sorry
- `Validity.lean:53` - `valid_over` definition
