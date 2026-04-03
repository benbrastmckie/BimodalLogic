# Roadmap: Completeness and Publication

## Overview

The repository has ~220 `sorry` statements across Lean source files (excluding Boneyard).
This count expanded from ~33 after the strict semantics migration (Task 81, March 2026)
which invalidated T-axiom-dependent proofs. Categories:

| Category | Count | Files | Status |
|----------|-------|-------|--------|
| Completeness (old path) | ~39 | Completeness.lean | Legacy (bypassed by restricted path) |
| Frame-class soundness | ~20 | Soundness.lean | Independent track (task 83 phase 6) |
| SuccChain FMCS | ~18 | SuccChainFMCS.lean | T-axiom sorries + seed redesign (task 83 phase 3) |
| UltrafilterChain | ~13 | UltrafilterChain.lean | **CRITICAL PATH** (task 83 phases 4-5) |
| Modal bridge | ~13 | Bridge.lean | Infrastructure |
| Canonical construction | ~9 | CanonicalConstruction.lean | Legacy (bypassed) |
| Dovetailed chain | ~8 | DovetailedChain.lean | Legacy dead end |
| Restricted truth lemma | ~7 | RestrictedTruthLemma.lean | Depends on g_content resolution |
| SuccChain truth | ~7 | SuccChainTruth.lean | Legacy |
| Temporal derived | ~5 | TemporalDerived.lean | **CRITICAL PATH** (task 83 phase 2) |
| Simplified chain | ~6 | SimplifiedChain.lean | Infrastructure |
| MCS witness | ~12 | MCSWitnessSuccessor/Chain.lean | Infrastructure |
| Targeted chain | ~5 | TargetedChain.lean | Partially archived |
| Dense completeness | ~1 | DenseCompleteness.lean | Separate track (task 68) |
| Discrete completeness | ~3 | DiscreteCompleteness.lean | Blocked on custom axiom |
| Examples/pedagogical | ~16 | Demo, ModalProofs, etc. | Expected (intentional) |
| Other | ~38 | Various | Mixed legacy/infrastructure |

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

Task 83 addresses three blockers for sorry-free canonical completeness:

**Blocker 1: Foundational derived theorems** (Phase 2)
Four theorems in TemporalDerived.lean (`X_bot_absurd`, `Y_bot_absurd`,
`until_implies_some_future`, `since_implies_some_past`) needed for Until/Since
truth lemma cases.

**Blocker 2: Seed redesign and g_content resolution** (Phase 3)
`g_content_subset_deferral_restricted_mcs` uses a sorry where the T-axiom was
invoked. Under strict semantics, `g_content(u) ⊆ u` requires a different proof
strategy (seriality-based F-deferrals instead of T-axiom).

**Blocker 3: Until/Since truth lemma** (Phases 4-5)
The restricted forward_F/backward_P proofs require X-content propagation through
successor chains and Until/Since persistence. The contrapositive approach with
Until-complexity induction is the most promising strategy.

> Given `F(psi) in succ_chain_fam S n` with `psi in deferralClosure(root)`, there exists `m > n` with `psi in succ_chain_fam S m`.

**Why this might be tractable now**: `deferralClosure(root)` is finite. The chain can only defer F-obligations within this finite set. A pigeonhole or fair-scheduling argument may show that deferral cannot continue indefinitely.

**Why it's still hard**: In a full MCS, `F(psi) in MCS` implies `F^k(psi) in MCS` for all k (by the temporal axiom). So F-nesting depth is not bounded even within `deferralClosure`. The persistence count (number of steps before resolution) is unbounded even though the formula set is bounded.

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

### Task 81 Contribution (March-April 2026)

Migrated from reflexive to strict temporal semantics and refactored completeness:
- **Strict semantics**: G/H quantify over s > t / s < t (not s >= t / s <= t)
- **T-axiom removal**: `temp_t_future` and `temp_t_past` axioms removed from the proof system
- **X/Y-based Until/Since**: Replaced reflexive Until/Since with X-based (next-step) variants
- Defined `BFMCS.restricted_temporally_coherent` (forward_F/backward_P within `deferralClosure` only)
- Proved sorry-free `restricted_temporal_backward_G/H`
- Proved sorry-free `restricted_shifted_truth_lemma`
- Wired `completeness_over_Int` through the restricted path
- Narrowed the completeness gap from "all formulas, all families" to "deferralClosure formulas, single chain"
- Expanded sorry count from ~33 to ~220 (T-axiom removal cascaded; most are on non-critical paths)

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

1. **Task 83** (in progress): Representation theorem via canonical completeness
   - Phase 2: Foundational derived theorems (TemporalDerived.lean)
   - Phase 3: Seed redesign (g_content without T-axiom)
   - Phase 4-5: Until/Since truth lemma via contrapositive approach
   - Phase 6: Frame-class soundness proofs (19 sites, parallel track)
2. **Task 58**: Wire completeness to FrameConditions (unblocked once task 83 done)
3. **Task 82**: Close FMP TruthPreservation sorries -- requires strict-semantics FMP redesign
4. **Task 68**: Dense completeness via Rat canonical model
5. **Task 60**: Remove `discrete_Icc_finite_axiom` custom axiom
