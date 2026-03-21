# Research Report: Task #922

**Task**: Strategy study: Audit TruthLemma BOTH directions for forward_F/backward_P requirements
**Date**: 2026-02-24
**Focus**: CRITICAL CONCERN about plan v4 -- does the approach work for BOTH directions of TruthLemma?
**Session**: sess_1771980095_933d07

## Summary

This research performs a complete audit of both directions of `bmcs_truth_lemma` in TruthLemma.lean to validate plan v4's claim that weakening forward_F to reflexive (t <= s instead of t < s) works for the entire proof.

**VERDICT: Plan v4 is VALID. Both directions work correctly with reflexive forward_F/backward_P.**

The user's concern was that research-005 and plan v4 might only analyze one direction while the TruthLemma is a biconditional requiring BOTH directions. The audit confirms:

1. The **forward direction** (phi in mcs(t) -> bmcs_truth phi at t) does NOT use forward_F or backward_P at all. It uses only `forward_G` and `backward_H` (which use STRICT inequalities and are separate from the TemporalCoherentFamily properties).

2. The **backward direction** (bmcs_truth phi at t -> phi in mcs(t)) uses forward_F and backward_P ONLY via the `temporal_backward_G` and `temporal_backward_H` theorems, and only in the G and H cases. These proofs work identically with reflexive witnesses.

3. **Neither forward_F nor backward_P appear anywhere in the forward direction.** This is the key fact that makes plan v4 safe.

## Findings

### 1. Complete TruthLemma Audit: Six Cases, Both Directions

The `bmcs_truth_lemma` (TruthLemma.lean line 286-424) proves:

```
phi in fam.mcs t <-> bmcs_truth_at B fam t phi
```

by structural induction on phi. Each case has a forward (mp, left-to-right) and backward (mpr, right-to-left) direction.

#### Case 1: Atom (lines 291-293)
- **Forward**: `atom p in mcs(t) -> atom p in mcs(t)` -- trivial by definition (`simp only [bmcs_truth_at]`)
- **Backward**: Same
- **forward_F usage**: NONE
- **backward_P usage**: NONE

#### Case 2: Bot (lines 294-304)
- **Forward**: `bot in mcs(t) -> False` -- by MCS consistency
- **Backward**: `False -> bot in mcs(t)` -- by False.elim
- **forward_F usage**: NONE
- **backward_P usage**: NONE

#### Case 3: Imp (lines 305-346)
- **Forward** (line 312-317): `(psi -> chi) in mcs(t) -> (bmcs_truth psi -> bmcs_truth chi)`
  - Uses `ih_psi.mpr` (backward IH on psi) and `ih_chi.mp` (forward IH on chi)
  - Uses MCS modus ponens (`set_mcs_implication_property`)
  - **forward_F usage**: NONE
  - **backward_P usage**: NONE

- **Backward** (line 318-346): `(bmcs_truth psi -> bmcs_truth chi) -> (psi -> chi) in mcs(t)`
  - Uses MCS negation completeness, classical tautologies
  - Uses both `ih_psi.mp` and `ih_chi.mpr` (cross-dependency between directions!)
  - **forward_F usage**: NONE
  - **backward_P usage**: NONE

**Note**: The imp case has a cross-dependency between forward and backward directions on sub-formulas. This is why the TruthLemma is proven as a single biconditional, not split into two separate lemmas. However, this cross-dependency does NOT involve forward_F or backward_P.

#### Case 4: Box (lines 347-372)
- **Forward** (line 359-364): `Box(psi) in mcs(t) -> forall fam' in families, bmcs_truth psi at fam'`
  - Uses `B.modal_forward` and `ih.mp`
  - **forward_F usage**: NONE
  - **backward_P usage**: NONE

- **Backward** (line 365-372): `(forall fam' in families, bmcs_truth psi at fam') -> Box(psi) in mcs(t)`
  - Uses `B.modal_backward` and `ih.mpr`
  - **forward_F usage**: NONE
  - **backward_P usage**: NONE

The box case is THE crucial case of the BMCS approach and is fully proven with no temporal dependency whatsoever.

#### Case 5: all_future / G (lines 373-399) -- THIS IS THE CRITICAL CASE

- **Forward** (line 377-380): `G(psi) in mcs(t) -> forall s >= t, bmcs_truth psi at s`
  - Uses `mcs_all_future_implies_phi_at_future` helper (line 101-113)
  - That helper uses:
    - For s > t: `fam.forward_G` (STRICT inequality, from BFMCS structure, NOT from TemporalCoherentFamily)
    - For s = t: T axiom (`G phi -> phi`)
  - Uses `ih.mp` (forward IH)
  - **forward_F usage**: NONE
  - **backward_P usage**: NONE

- **Backward** (line 381-399): `(forall s >= t, bmcs_truth psi at s) -> G(psi) in mcs(t)`
  - Extracts `forward_F` and `backward_P` from `h_tc` (the temporally_coherent hypothesis)
  - Constructs a `TemporalCoherentFamily` from these
  - Applies `temporal_backward_G`
  - Uses `ih.mpr` (backward IH)
  - **forward_F usage**: YES -- via `h_tc fam hfam` which gives `h_forward_F`
  - **backward_P usage**: YES -- via `h_tc fam hfam` which gives `h_backward_P`

  The backward direction constructs a TemporalCoherentFamily (line 389-393) using:
  ```lean
  let tcf : TemporalCoherentFamily D := {
    toBFMCS := fam
    forward_F := h_forward_F
    backward_P := h_backward_P
  }
  ```

  Then calls `temporal_backward_G tcf t psi h_all_mcs` (line 399).

#### Case 6: all_past / H (lines 400-424) -- SYMMETRIC TO CASE 5

- **Forward** (line 404-407): `H(psi) in mcs(t) -> forall s <= t, bmcs_truth psi at s`
  - Uses `mcs_all_past_implies_phi_at_past` helper
  - Uses `fam.backward_H` (STRICT, from BFMCS) and T axiom
  - **forward_F usage**: NONE
  - **backward_P usage**: NONE

- **Backward** (line 408-424): `(forall s <= t, bmcs_truth psi at s) -> H(psi) in mcs(t)`
  - Extracts forward_F and backward_P from h_tc
  - Constructs TemporalCoherentFamily
  - Applies `temporal_backward_H`
  - **forward_F usage**: YES
  - **backward_P usage**: YES

### 2. Summary: Where forward_F and backward_P Are Used

| Case | Forward Direction | Backward Direction |
|------|-------------------|-------------------|
| atom | No F/P | No F/P |
| bot | No F/P | No F/P |
| imp | No F/P | No F/P |
| box | No F/P | No F/P |
| all_future (G) | No F/P (uses forward_G from BFMCS) | **YES: forward_F and backward_P** |
| all_past (H) | No F/P (uses backward_H from BFMCS) | **YES: forward_F and backward_P** |

**Critical distinction**: There are TWO different sets of temporal properties:

1. **BFMCS properties** (defined in BFMCS.lean):
   - `forward_G`: G(phi) in mcs(t) and t < t' -> phi in mcs(t') -- **STRICT**, used in forward direction
   - `backward_H`: H(phi) in mcs(t) and t' < t -> phi in mcs(t') -- **STRICT**, used in forward direction

2. **TemporalCoherentFamily properties** (defined in TemporalCoherentConstruction.lean):
   - `forward_F`: F(phi) in mcs(t) -> exists s with t < s (currently strict) and phi in mcs(s) -- used ONLY in backward direction
   - `backward_P`: P(phi) in mcs(t) -> exists s with s < t (currently strict) and phi in mcs(s) -- used ONLY in backward direction

Plan v4 proposes weakening ONLY the second set (forward_F, backward_P). The first set (forward_G, backward_H) remains strict and is NOT changed.

### 3. Why Reflexive forward_F Works in temporal_backward_G

The `temporal_backward_G` theorem (TemporalCoherentConstruction.lean, lines 225-249):

```lean
theorem temporal_backward_G (fam : TemporalCoherentFamily D) (t : D) (phi : Formula)
    (h_all : forall s : D, t <= s -> phi in fam.mcs s) :
    Formula.all_future phi in fam.mcs t := by
  by_contra h_not_G
  -- Step 1: neg(G phi) in mcs(t) [MCS maximality]
  -- Step 2: F(neg phi) in mcs(t) [temporal duality]
  -- Step 3: exists s, t < s and neg(phi) in mcs(s)   <-- CURRENT (strict)
  -- Step 4: phi in mcs(s) [from h_all, using le_of_lt]
  -- Step 5: contradiction
```

With reflexive forward_F, step 3 becomes:
```
  -- Step 3: exists s, t <= s and neg(phi) in mcs(s)  <-- PROPOSED (reflexive)
```

And step 4 becomes:
```
  -- Step 4: phi in mcs(s) [from h_all s h_le, directly]
```

The current proof at line 246: `have h_phi_s : phi in fam.mcs s := h_all s (le_of_lt h_lt)`

With reflexive forward_F, this becomes: `have h_phi_s : phi in fam.mcs s := h_all s h_le`

The contradiction at step 5 (line 249): `set_consistent_not_both (fam.is_mcs s).1 phi h_phi_s h_neg_phi_s`

This works regardless of whether s = t or s > t, because MCS consistency is a property of any single MCS, and having both phi and neg(phi) in any MCS (whether at time t or time s) is a contradiction.

### 4. The Forward Direction Does NOT Need Weakening

The forward direction for G (line 101-113, `mcs_all_future_implies_phi_at_future`) uses:
- `fam.forward_G t s phi h_lt hG` for the s > t case (STRICT, from BFMCS)
- T axiom for the s = t case

This function uses `forward_G` (from BFMCS), NOT `forward_F` (from TemporalCoherentFamily). These are completely different properties:
- `forward_G`: G(phi) at t propagates phi to all future times (a UNIVERSAL property)
- `forward_F`: F(phi) at t witnesses phi at some future time (an EXISTENTIAL property)

Plan v4 does not modify `forward_G` or `backward_H` at all. The forward direction of TruthLemma is completely unaffected.

### 5. The Completeness Chain Dependencies

The completeness proof in Completeness.lean:
1. Calls `construct_saturated_bmcs_int` to build a BMCS
2. Uses `construct_saturated_bmcs_int_temporally_coherent` to get `B.temporally_coherent`
3. Passes `h_tc` to `bmcs_truth_lemma`
4. `bmcs_truth_lemma` uses `h_tc` in the backward direction of G and H cases only

The `temporally_coherent` property is defined as (TemporalCoherentConstruction.lean line 298-301):
```lean
def BMCS.temporally_coherent (B : BMCS D) : Prop :=
  forall fam in B.families,
    (forall t phi, F(phi) in fam.mcs t -> exists s, t < s and phi in fam.mcs s) and
    (forall t phi, P(phi) in fam.mcs t -> exists s, s < t and phi in fam.mcs s)
```

Plan v4 would change this to use `t <= s` and `s <= t`. The ONLY consumer is `bmcs_truth_lemma`'s backward direction for G and H, where the weakened version suffices as shown in section 3.

### 6. Assessment of Plan v4

**Plan v4 is VALID for both directions of the TruthLemma.**

Specific validation points:

| Concern | Status | Evidence |
|---------|--------|----------|
| Forward direction of G uses forward_F? | NO | Uses forward_G (BFMCS property), lines 101-113 |
| Forward direction of H uses backward_P? | NO | Uses backward_H (BFMCS property), lines 124-136 |
| Backward direction of G needs strict forward_F? | NO | Contradiction works for s = t too, line 246-249 |
| Backward direction of H needs strict backward_P? | NO | Same argument, line 280-286 |
| Imp case uses forward_F indirectly? | NO | Only uses MCS properties + sub-formula IH |
| Box case uses forward_F indirectly? | NO | Only uses modal_forward/modal_backward |
| bmcs_truth_at definition references forward_F? | NO | Purely recursive on formula structure |

### 7. One Clarification on Research-005's Language

Research-005 stated: "only the backward direction of TruthLemma uses forward_F". This statement is CORRECT but could be clearer. A more precise statement:

**"forward_F and backward_P appear ONLY in the backward direction (right-to-left) of the G and H cases of bmcs_truth_lemma. The forward direction (left-to-right) of ALL cases, including G and H, uses only the BFMCS structural properties forward_G and backward_H, which are separate from forward_F/backward_P and are not modified by plan v4."**

The user's concern about BOTH directions needing to be proven sorry-free is entirely valid as a general principle. However, the specific dependency analysis shows that forward_F/backward_P are not involved in the forward direction at all, so weakening them cannot affect the forward direction.

### 8. Additional Verification: forward_G and backward_H Are Unchanged

Plan v4 modifies ONLY:
- `TemporalCoherentFamily.forward_F` (strict -> reflexive)
- `TemporalCoherentFamily.backward_P` (strict -> reflexive)
- `BMCS.temporally_coherent` (matches new signatures)

Plan v4 does NOT modify:
- `BFMCS.forward_G` (remains strict: t < t')
- `BFMCS.backward_H` (remains strict: t' < t)

The BFMCS structure (BFMCS.lean lines 80-98) keeps its strict temporal coherence conditions. These are used in the forward direction of TruthLemma and are completely orthogonal to the TemporalCoherentFamily properties.

## Recommendations

1. **Proceed with plan v4 as-is.** The approach is valid for both directions of the TruthLemma.

2. **Phase 1 (weaken forward_F/backward_P) is safe.** The change affects only:
   - `TemporalCoherentFamily` definition (forward_F, backward_P signatures)
   - `BMCS.temporally_coherent` definition
   - `temporal_backward_G` proof (replace `le_of_lt h_lt` with direct `h_le`)
   - `temporal_backward_H` proof (same change)
   - Downstream signature alignment in DovetailingChain.lean

3. **The forward direction of TruthLemma requires zero changes** under plan v4.

4. **Risk assessment remains at 98% confidence** as stated in research-005. The audit in this report confirms the finding with complete line-by-line evidence.

## References

- TruthLemma.lean: `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/TruthLemma.lean`
- TemporalCoherentConstruction.lean: `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/TemporalCoherentConstruction.lean`
- BFMCS.lean: `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/BFMCS.lean`
- BMCS.lean: `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/BMCS.lean`
- BMCSTruth.lean: `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/BMCSTruth.lean`
- Completeness.lean: `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/Completeness.lean`
- Research-005: `specs/922_strategy_study_fp_witness_completeness_blockers/reports/research-005.md`
- Plan v4: `specs/922_strategy_study_fp_witness_completeness_blockers/plans/implementation-004.md`

## Next Steps

1. Plan v4 is validated. Proceed directly to implementation Phase 1 (weaken forward_F).
2. No plan modifications needed.
3. After Phase 1, verify with `lake build` that TruthLemma.lean compiles without changes (the forward direction is untouched, and the backward direction adapts via temporal_backward_G/H which are the only consumers of the weakened properties).
