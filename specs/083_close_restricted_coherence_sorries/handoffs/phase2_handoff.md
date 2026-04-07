# Handoff: BX Refactor Phase 2 -- Axiom Type Change Cascade

## Session: sess_1775599347_408ff8

## Status: Phase 2 IN PROGRESS

## What Was Done

### Phase 1: COMPLETED
- Truth.lean: Changed Until/Since from strict to reflexive semantics
  - `t < s` -> `t <= s` for Until witness, `s < t` -> `s <= t` for Since witness
  - Guard intervals: Until `t <= r -> r < s`, Since `s < r -> r <= t`
  - Fixed time_shift_preserves_truth for both untl and snce cases
  - Updated TemporalCoherence.lean: `until_since_coherent` definition updated
  - Fixed pre-existing bug in DovetailedChain.lean (rw on non-existent subterm)
  - Full build passes after Phase 1

### Phase 2: IN PROGRESS
- Axioms.lean: FULLY REWRITTEN with 25 BX constructors
  - Layer 1: prop_k, prop_s, ex_falso, peirce (4)
  - Layer 2: modal_t, modal_4, modal_b, modal_5_collapse, modal_k_dist (5)
  - Layer 3 BX: temp_t_future/past, left_mono_until/since, right_mono_until/since,
    connect_until_since/connect_since_until, self_accum_until/since, absorb_until/since,
    linear_until/since (14)
  - Layer 4: modal_future, temp_future (2)
  - Classification: isBase/isDenseCompatible/isDiscreteCompatible all True (all are base)
- Substitution.lean: Updated match cases for new BX constructors -- BUILDS
- SoundnessLemmas.lean: Updated match blocks, BX cases sorry'd -- BUILDS
- Soundness.lean: Updated 4 match blocks, BX soundness proofs sorry'd -- BUILDS
- Compatibility.lean: Removed old discrete instances -- BUILDS
- MCSProperties.lean: Sorry'd temp_4 derivations -- BUILDS
- GeneralizedNecessitation.lean: Sorry'd temp_k_dist derivations -- BUILDS
- Discreteness.lean: Sorry'd discreteness_forward derivation -- BUILDS
- ProofSearch.lean: Sorry'd removed axiom cases -- PARTIALLY FIXED

## What Remains (Phase 2 Cascade)

The Axiom type change creates a cascade of 5+ files that still reference old constructors
and don't build. These were NOT caught by the initial build because they're downstream
of already-broken files:

### Files Still Broken (by old Axiom constructor references)

1. **TemporalDerived.lean** -- References seriality_future, seriality_past, F_until_equiv,
   P_since_equiv, temp_k_dist, until_induction. These derived theorems need to be either:
   - Re-derived from BX axioms (Phase 3 work)
   - Sorry'd temporarily

2. **RestrictedMCS.lean** (line 1421) -- References Axiom.temp_k_dist

3. **ConservativeExtension/ExtDerivation.lean** -- References ~12 old axiom constructors.
   The ExtAxiom type also needs to be updated to mirror the BX Axiom type.

4. **ConservativeExtension/Lifting.lean** -- References ~20+ old axiom constructors across
   3 match blocks. Needs comprehensive update.

5. **ProofSearch.lean** -- Some references already sorry'd, but may have more issues from
   the type change affecting pattern matching logic.

### Strategy for Remaining Work

The fastest path: sorry ALL remaining references to old axiom constructors. Each file should:
1. Replace `Axiom.old_name` with `sorry` in term expressions
2. Replace `| old_name ...` with `sorry` in match blocks

Then in Phase 3, derive the needed theorems from BX axioms.

## BX Soundness Proofs (Phase 2 Main Goal)

The 12 new BX axiom soundness proofs (BX2-BX7 x 2) are currently sorry'd everywhere.
These need proper semantic proofs. Each proof structure:

- **BX2 (left_mono)**: If G(phi -> chi) and phi U psi, take same witness s.
  Guard: chi holds at r in [t,s) because G(phi->chi) at t gives phi->chi at r, and phi at r.
- **BX3 (right_mono)**: If G(phi -> psi) and chi U phi, take same witness s.
  psi at s because G(phi->psi) at t gives phi->psi at s, and phi at s.
- **BX4 (connect)**: If phi at t and chi U psi (witness s >= t), then chi U (psi /\ chi S phi).
  The Since witness is t (phi at t, chi on [t,s) is the guard).
- **BX5 (self_accum)**: If phi U psi (witness s), then (phi /\ (phi U psi)) U psi.
  At each r in [t,s): phi holds (guard), and phi U psi holds with same witness s (since r <= s).
- **BX6 (absorb)**: If phi U (phi /\ phi U psi) (witness s1), then at s1: phi /\ phi U psi.
  So phi U psi holds at s1 with witness s2. Use s2 as the new witness.
- **BX7 (linear)**: Given phi U psi (witness s1) and chi U theta (witness s2),
  by trichotomy on s1 vs s2, distribute into three disjuncts.

## Key File Paths

- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/ProofSystem/Axioms.lean` -- NEW BX system
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Semantics/Truth.lean` -- Reflexive U/S
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Soundness.lean` -- Updated
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/TemporalCoherence.lean` -- Updated
- `/home/benjamin/Projects/ProofChecker/specs/083_close_restricted_coherence_sorries/plans/33_bx-refactor.md` -- Plan

## Current Build Status

`lake build` fails on ~5 files due to remaining old Axiom constructor references.
Fixable by sorry-ing all old references.
