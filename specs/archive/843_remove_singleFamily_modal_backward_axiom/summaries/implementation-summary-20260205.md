# Implementation Summary: Task #843 (Phase 1)

**Completed**: 2026-02-05
**Phase**: 1 of 6 (Temporal Dovetailing Chain)
**Session**: sess_1770322343_975168

## Changes Made

### Phase 1: Temporal Dovetailing Chain

Replaced the `temporal_coherent_family_exists` **axiom** with a **theorem** backed by a dovetailing chain construction. This removes one of two axioms from the completeness proof chain.

#### Key Achievement

`#print axioms bmcs_strong_completeness` no longer lists `temporal_coherent_family_exists`. The axiom has been moved from the trusted kernel to honest sorry debt.

**Before**: 2 axioms (`singleFamily_modal_backward_axiom`, `temporal_coherent_family_exists`)
**After**: 1 axiom (`singleFamily_modal_backward_axiom`) + `sorryAx` (honest debt)

### New Files

- **`Theories/Bimodal/Metalogic/Bundle/DovetailingChain.lean`** (460 lines)
  - Forward chain: `dovetailForwardChainMCS` using `GContent` seeds
  - Backward chain: `dovetailBackwardChainMCS` using `HContent` seeds
  - Unified `dovetailChainSet` mapping `Int -> Set Formula`
  - Proven: `forward_G` for non-negative pairs, `backward_H` for non-positive pairs
  - Proven: `past_temporal_witness_seed_consistent` (novel contribution)
  - Proven: `dovetail_GContent_consistent`, `dovetail_HContent_consistent`
  - Theorem: `temporal_coherent_family_exists_theorem`

- **`Theories/Bimodal/Metalogic/Bundle/TemporalContent.lean`** (28 lines)
  - Extracted `GContent` and `HContent` definitions to break import cycle

### Modified Files

- **`Theories/Bimodal/Metalogic/Bundle/TemporalCoherentConstruction.lean`**
  - Replaced `axiom temporal_coherent_family_exists` with `theorem` (sorry-backed)
  - Added import of `TemporalContent.lean` and `DovetailingChain.lean` (via TemporalContent)
  - Removed local `GContent`/`HContent` definitions (now imported)

## Sorry Inventory (4 in DovetailingChain.lean)

1. `forward_G` cross-sign case (t < 0 < t'): requires backward-to-forward chain propagation
2. `backward_H` cross-sign case (t' < 0 < t): requires forward-to-backward chain propagation
3. `forward_F` witness construction: requires dovetailing enumeration
4. `backward_P` witness construction: requires dovetailing enumeration

Plus 1 sorry in TemporalCoherentConstruction.lean (generic D version of the theorem).

## Verification

- `lake build Bimodal.Metalogic.Bundle.Completeness` succeeds
- `#print axioms bmcs_strong_completeness` shows: `propext, sorryAx, Classical.choice, Lean.ofReduceBool, Lean.trustCompiler, Quot.sound, singleFamily_modal_backward_axiom`
- No `temporal_coherent_family_exists` in axiom list

## Remaining Work (Phases 2-6)

- Phase 2: S5 Box Invariance Lemma
- Phase 3: Generalized Diamond-BoxContent Consistency
- Phase 4: Time-Shifted Temporal Chains
- Phase 5: S5 Canonical BMCS Construction
- Phase 6: Integration and Axiom Removal (eliminate `singleFamily_modal_backward_axiom`)

---

## Phase 2 Analysis (2026-02-05, Session sess_1770325123_e65ce6)

### Status: BLOCKED - Mathematical Error in Plan

Phase 2 calls for proving S5 Box Invariance:
```
s5_box_invariance : SetMaximalConsistent M -> SetMaximalConsistent M' ->
    Formula.box phi in M -> Formula.box phi in M'
```

**This statement is mathematically false.** See detailed analysis below.

### Counterexample

For `phi = Formula.atom "p"`:
- `Box(atom "p")` is neither provable nor refutable in the TM proof system
- Both `Box(atom "p")` and `neg(Box(atom "p"))` are consistent
- By Lindenbaum, there exist MCS M1 with `Box(atom "p")` and MCS M2 with `neg(Box(atom "p"))`
- So `Box(atom "p") in M1` but `Box(atom "p") not in M2`

### Root Cause

Research-015 conflated two distinct claims:
1. **True**: In the S5 canonical model (universal accessibility), Box phi true at one world implies
   true at all worlds.
2. **False**: For arbitrary MCS of the proof system, Box phi in one MCS implies in all MCS.

Statement (1) is about a specific model's structure. Statement (2) would require all MCS to
agree on Box formulas, which is false for contingent atoms.

### Proof Circularity

All attempted proof approaches encounter circularity:
- The "negative 5" theorem `neg(Box psi) -> Box(neg(Box psi))` can be derived.
- But using it to transfer Box formulas between MCS requires Box invariance itself.
- No mechanism exists in pure MCS theory to transfer Box-formulas between unrelated MCS.

### Impact on Phases 3-6

- **Phase 3** (Diamond-BoxContent): Independent, can proceed.
- **Phase 4** (Shifted Chains): Independent, can proceed.
- **Phase 5** (BMCS Construction): modal_backward is correct (no S5 invariance needed).
  modal_forward DOES depend on S5 invariance and needs reformulation.
- **Phase 6**: Depends on Phase 5.

### Recommended Alternatives for modal_forward

1. **Canonical accessibility approach**: Define R(M,M') = BoxContent(M) subset M'. Prove R is
   universal using modal_b (symmetry argument). Derive modal_forward from universal R.
2. **Structural coherence**: Restrict family set to MCS sharing BoxContent (CoherentBundle approach).
3. **EvalBMCS approach**: Use already-proven eval_saturated_bundle_exists (avoids full modal_forward).

### Plan Revision Required

Plan v006 Phase 2 needs substantial redesign. Recommend creating v007 with revised Phase 2 that
either (a) constructs the canonical accessibility relation or (b) uses structural coherence.
