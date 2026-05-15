# Implementation Summary: Task #141

- **Task**: 141 - canonical_truth_lemma_until_since
- **Status**: Partial
- **Session**: sess_1778824110_c99890
- **Date**: 2026-05-14

## Outcome

Closed 1 of 8 target sorries. The remaining 7 sorries (1 in ReflexiveCanonical, 6 in TruthLemma) are blocked by fundamental infrastructure gaps caused by the removal of BX8/BX9 axioms under open-guard semantics.

## Changes Made

### Phase 1: canS5R_symm (COMPLETED)
- **File**: `Theories/Bimodal/Metalogic/WeakCanonical/ReflexiveCanonical.lean`
- **Sorry closed**: `canS5R_symm` (line 424, now proved)
- **Proof technique**: modal_b + negation completeness + modal_k_dist + dni (double negation intro)
- **Key steps**: By contradiction. From phi not in x, derive neg phi in x, apply modal_b to get box(diamond(neg phi)) in x, transfer to y via canS5R, derive box(neg neg phi) in y from box phi via dni + modal_k_dist, contradiction with diamond(neg phi) = neg box(neg neg phi) in y.

### Phase 2: reflCanR_linear (BLOCKED)
- **File**: `Theories/Bimodal/Metalogic/WeakCanonical/ReflexiveCanonical.lean`
- **Sorry**: `reflCanR_linear` (line 144, remains sorry)
- **Blocker**: The standard proof (Doets 1987 Claim 8) uses the l-lin axiom (Pp -> H(Pp v p v Fp)) which is not in our BX axiom system. BX11 (temp_linearity) is a different axiom (F(a) ^ F(b) -> three disjuncts) and the case analysis after applying BX11 cannot derive contradictions without relating the new MCS witness to y and z. The theorem is never used in the codebase (no references outside its definition), so it is non-critical.
- **What would unblock**: Either derive Doets' l-lin from BX4 + BX4' + BX11, or find a proof strategy that works with BX11 directly. The challenge is that BX11 creates a new MCS w but there's no way to establish tempR_fwd between y/z and w without assuming linearity (circular).

### Phases 3-5: Until/Since backward and forward guard (BLOCKED)
- **Files**: `Theories/Bimodal/Metalogic/WeakCanonical/TruthLemma.lean`
- **6 sorries remain** (lines 426, 443, 479, 494, 548, 563)
- **Root cause**: The removal of BX8 (until_step) and BX9 (until_elim) under open-guard semantics (task 113) broke the standard chain construction for Until/Since. Specifically:
  - The **forward guard condition** (lines 426, 479) requires propagating psi2 through intermediate MCS between x and the witness y. U(psi1,psi2) is not a G-formula, so it does not propagate via g_content. BX5 (self_accum_until) enriches the guard but the enriched guard still doesn't propagate.
  - The **backward direction** (lines 443, 494, 548, 563) requires constructing U(phi,psi) in x from a semantic witness. The Burgess approach (C4a counter-witness lemma) requires chain infrastructure that doesn't exist in ReflCanDomain. The BXCanonical module has `c4_hard_case_G_neg_delta` but it requires G(guard) in the MCS, which the semantic witness doesn't provide.
  - Even in the BXCanonical module, `until_backward_refl_mcs` is sorry'd with the note "psi -> (phi U psi) is NOT axiomatically valid (no reflexive witness)."
- **What would unblock**: 
  1. Rebuild the chain construction from DefectChain.lean / Frame.lean for ReflCanDomain, adapting the BXPoint-based infrastructure to work with the simpler (but less structured) g_content-based accessibility.
  2. Or: use the Burgess enriched seed (BX13) with a Since-based encoding, which requires proving consistency of `{psi1} union {S(alpha, psi2) | alpha in x.val} union g_content(x)`.
  3. Or: establish a well-founded induction principle on the interval between x and y in tempR_fwd, which requires prior_UZ (discrete nearest-point) and possibly z1 (IsSuccArchimedean).

### Phase 6: Final Verification (COMPLETED)
- `lake build` passes with no errors
- No new axioms introduced
- No vacuous definitions
- Sorry count in ReflexiveCanonical.lean: 2 -> 1
- Sorry count in TruthLemma.lean: unchanged (6 sorry statements)

## Plan Deviations

- **Phase 1**: Completed as planned, no deviations.
- **Phase 2**: Blocked. The plan's BX11 proof strategy doesn't work because the case analysis after BX11 is circular (needs linearity to prove linearity). The theorem is unused in the codebase. *(deviation: blocked -- BX11 case analysis insufficient, Doets l-lin axiom not derivable from BX system)*
- **Phase 3**: Blocked. The backward direction requires chain infrastructure that doesn't exist in ReflCanDomain. *(deviation: blocked -- chain construction not portable from BXCanonical/Chronicle to ReflCanDomain)*
- **Phase 4**: Blocked. The forward guard condition has the same chain infrastructure dependency. *(deviation: blocked -- g_content propagation insufficient for U-formula guard)*
- **Phase 5**: Blocked by Phases 3-4.

## Artifacts

- Modified: `Theories/Bimodal/Metalogic/WeakCanonical/ReflexiveCanonical.lean` (canS5R_symm proved)
- Created: `specs/141_canonical_truth_lemma_until_since/summaries/01_truth-lemma-summary.md` (this file)
- Updated: `specs/141_canonical_truth_lemma_until_since/plans/01_truth-lemma-plan.md` (phase status markers)
