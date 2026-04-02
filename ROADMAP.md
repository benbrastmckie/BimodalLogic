# Roadmap: Completeness and Publication

## Overview

The repository has ~33 `sorry` statements across Lean source files. These fall into distinct categories:

| Category | Count | Files | Status |
|----------|-------|-------|--------|
| SuccChain FMCS | 4 | SuccChainFMCS.lean | Legacy (bypassed by restricted path) |
| Restricted coherence | 2 | UltrafilterChain.lean | **CRITICAL PATH** |
| Restricted truth lemma | 2 | RestrictedTruthLemma.lean | May be unnecessary |
| Canonical construction | 2 | CanonicalConstruction.lean | Legacy (bypassed) |
| Completeness (old path) | 1 | Completeness.lean | Legacy (bypassed) |
| Dense completeness | 1 | Completeness.lean | Separate track (task 68) |
| Discrete completeness | 1 | DiscreteCompleteness.lean | Blocked on custom axiom |
| Soundness extensions | 1 | Soundness.lean | Frame-dependent |
| FMP truth preservation | 2 | TruthPreservation.lean | Separate track (task 82) |
| Simplified chain | 1 | SimplifiedChain.lean | Infrastructure |
| SuccChain truth | 1 | SuccChainTruth.lean | Legacy |
| Boneyard/dead code | 2 | FPreservingSeed.lean | Archived |
| Examples/pedagogical | 14 | Demo, ModalProofs, etc. | Expected |

## The Completeness Gap (Priority 1)

### Architecture: Two Parallel Paths

There are currently **two parallel completeness paths** in the codebase. The restricted path is the active approach; the original path is retained for reference but bypassed.

#### Path A: Original (Full Temporal Coherence) -- BYPASSED

```
completeness_over_Int
  -> bundle_validity_implies_provability
       -> shifted_truth_lemma (SORRY-FREE, but needs full coherence)
       -> bfmcs_from_mcs_temporally_coherent (SORRY at Completeness.lean:237)
            -> Z_chain_forward_F / Z_chain_backward_P (sorry)
```

This path requires proving that every family in the BFMCS satisfies `forward_F` and `backward_P` for ALL formulas. This is intractable because arbitrary MCS chains can defer F-obligations indefinitely through unbounded F-nesting.

**Status**: Bypassed. The sorry at `bfmcs_from_mcs_temporally_coherent` remains but is no longer on the critical path. `completeness_over_Int` now delegates to the restricted path.

#### Path B: Restricted Coherence -- ACTIVE (Task 81, completed)

```
completeness_over_Int
  -> restricted_bundle_validity_implies_provability
       -> restricted_shifted_truth_lemma (SORRY-FREE)
       -> bfmcs_restricted_temporally_coherent
            -> shifted_restricted_forward_F (SORRY-FREE)
            -> succ_chain_restricted_forward_F (SORRY) <-- ONLY BLOCKER
            -> succ_chain_restricted_backward_P (SORRY) <-- ONLY BLOCKER
```

This path only requires `forward_F` and `backward_P` for formulas in `deferralClosure(root)`, where `root` is the formula being evaluated. Since the truth lemma only invokes temporal coherence on subformulas of `root`, and these all lie within `deferralClosure(root)`, restricted coherence suffices.

**Key insight**: The truth lemma's G backward case uses `forward_F` on `neg(psi)` where `G(psi)` is a subformula of root. Since `neg(psi) in closureWithNeg(root) subset deferralClosure(root)`, the restricted hypothesis is sufficient.

**Status**: Structurally complete. The only remaining sorries are:
- `succ_chain_restricted_forward_F` (UltrafilterChain.lean:3762)
- `succ_chain_restricted_backward_P` (UltrafilterChain.lean:3772)

These are **strictly more precise** than the original sorry: restricted to `deferralClosure` formulas in a single SuccChainFMCS, rather than all formulas across all families.

### What "Closing the Gap" Means (Task 83)

To achieve sorry-free canonical completeness, we need to prove:

> Given `F(psi) in succ_chain_fam S n` with `psi in deferralClosure(root)`, there exists `m >= n` with `psi in succ_chain_fam S m`.

**Why this might be tractable now**: `deferralClosure(root)` is finite. The chain can only defer F-obligations within this finite set. A pigeonhole or fair-scheduling argument may show that deferral cannot continue indefinitely.

**Why it's still hard**: In a full MCS, `F(psi) in MCS` implies `F^k(psi) in MCS` for all k (by the temporal axiom). So F-nesting depth is not bounded even within `deferralClosure`. The persistence count (number of steps before resolution) is unbounded even though the formula set is bounded.

**Candidate approaches** (task 83):
1. **Finite deferral argument**: `deferralClosure` is finite, so the set of pending F-obligations is bounded. Show that `constrained_successor`'s f_step cannot defer ALL of them indefinitely.
2. **Dovetailed chain with fair scheduling**: Build a modified chain that cycles through pending F-obligations, resolving each in turn.
3. **Ultrafilter/algebraic argument**: Use R_G accessibility in the Lindenbaum algebra to establish resolution at the algebraic level.

### Completeness Chain (Sorry-Free Modulo Task 83)

Everything below is sorry-free EXCEPT the two sorries in task 83:

| Component | File | Status |
|-----------|------|--------|
| `not_provable_implies_neg_consistent` | Completeness.lean | Sorry-free |
| `neg_consistent_gives_mcs_without_phi` | Completeness.lean | Sorry-free |
| `construct_bfmcs_bundle` | UltrafilterChain.lean | Sorry-free |
| `bundle_to_bfmcs` | Completeness.lean | Sorry-free |
| `boxClassFamilies_modal_backward` | UltrafilterChain.lean | Sorry-free |
| `restricted_shifted_truth_lemma` | CanonicalConstruction.lean | Sorry-free |
| `restricted_temporal_backward_G` | TemporalCoherence.lean | Sorry-free |
| `restricted_temporal_backward_H` | TemporalCoherence.lean | Sorry-free |
| `bfmcs_restricted_temporally_coherent` | Completeness.lean | Depends on task 83 |
| `restricted_bundle_validity_implies_provability` | Completeness.lean | Depends on task 83 |
| `completeness_over_Int` | Completeness.lean | Depends on task 83 |
| `discrete_completeness_fc` | Completeness.lean | Depends on task 83 |

### Algebraic Perspective

The algebraic path (`Algebraic/`) provides sorry-free infrastructure:

```
LindenbaumQuotient -> BooleanStructure -> InteriorOperators
         -> UltrafilterMCS -> ParametricCanonical -> ParametricTruthLemma
         -> ParametricRepresentation (SORRY-FREE, conditional)
```

The gap is `construct_bfmcs`: given MCS M0, produce a temporally coherent BFMCS.

#### Modal Completeness (Box Forward/Backward) -- SOLVED

The modal direction is complete. `boxClassFamilies_modal_backward` (UltrafilterChain.lean:1678) is sorry-free.

## Temporal Coherence Resolution History

### Dead Ends (Archived)

1. **CoherentZChain**: Forward chain preserves G but not H; backward preserves H but not G. Unfixable.

2. **`f_preserving_seed_consistent` sub-case A**: Mathematically unprovable. Vacuous implication yields no contradiction.

3. **`omega_true_dovetailed_forward_F_resolution`**: Unfixable. Lindenbaum extension can add `G(neg phi)` when `F(phi)` was present.

4. **Bundle-level temporal coherence**: Insufficient for truth lemma. G/H operators are intrinsically single-history.

5. **Fuel-based bounded witness recursion** (tasks 48, 67, 81 plan v13): Repeatedly failed. Fuel conflates F-nesting depth (bounded) with persistence count (unbounded).

6. **Bidirectional Temporal Witness (plan v4)**: BLOCKED. H_theory elements are not G-liftable.

### Working Infrastructure: SuccChainFMCS

**Sorry-Free Properties**:
- `succ_chain_forward_G`: G(phi) at t implies phi at all t' > t
- `succ_chain_backward_H`: H(phi) at t implies phi at all t' < t
- `SuccChainFMCS`: FMCS structure with `forward_G` and `backward_H`

**Known Gaps (F/P Existential Witnesses)**:
- `forward_F` / `backward_P` for full MCS: sorry (bypassed by restricted path)
- `succ_chain_restricted_forward_F` / `backward_P` for deferralClosure: sorry (task 83)

### Task 81 Contribution (April 2026)

Refactored the completeness proof to use restricted temporal coherence:
- Defined `BFMCS.restricted_temporally_coherent` (forward_F/backward_P within `deferralClosure` only)
- Proved sorry-free `restricted_temporal_backward_G/H`
- Proved sorry-free `restricted_shifted_truth_lemma`
- Wired `completeness_over_Int` through the restricted path
- Narrowed the completeness gap from "all formulas, all families" to "deferralClosure formulas, single chain"

## Investigated Dead Ends: Logic Weakening (Task 77)

**Conclusion**: Weakening TM by using a preorder (instead of linear order) for D does NOT provide a viable path to completeness. The F/P witness blocker is independent of the order structure on D.

### Representation Theorem Goal

> "TM is complete with respect to TaskFrames over totally ordered abelian groups."

**Only the algebraic/canonical model approach is to be pursued for completeness.** FMP proves decidability but does not provide frame class characterization.

## Other Open Items

### FMP Truth Preservation (task 82, 2 sorries)
- `mcs_all_future_closure` and `mcs_all_past_closure` in TruthPreservation.lean
- Filtration-based truth preservation for finite model property
- **Decidability track only** -- not a path to the completeness representation theorem
- Independent of the restricted coherence work

### Dense Completeness (task 68, 1 sorry)
- `dense_completeness_fc` needs a separate proof using dense canonical model (e.g., over Rat)
- Cannot reduce to `completeness_over_Int` since Int is not densely ordered
- Independent of the restricted coherence work

### Soundness Extensions (1 sorry in Soundness.lean)
- `density`: requires `DenselyOrdered D`
- Frame-condition-dependent; architecture is sound

### SuccChain FMCS Legacy Sorries (4 sorries)
- In SuccChainFMCS.lean -- part of the original (bypassed) full-coherence path
- Not on the critical path since `completeness_over_Int` now uses the restricted path
- Could be cleaned up but not blocking

### Examples/Pedagogical (14 sorries)
- Demo.lean, ModalProofs.lean, ModalProofStrategies.lean, TemporalProofs.lean
- Expected and intentional (exercises, demonstrations)

## Recommended Priority Order

1. **Task 83**: Close `succ_chain_restricted_forward_F/backward_P` -- sole blocker for sorry-free completeness
2. **Task 82**: Close FMP TruthPreservation sorries -- gives weak completeness / decidability
3. **Task 68**: Dense completeness via Rat canonical model
4. **Task 58**: Wire completeness to FrameConditions (unblocked once task 83 done)
5. **Task 60**: Remove `discrete_Icc_finite_axiom` custom axiom
6. **Cleanup**: Remove legacy Path A sorries, archive dead code
