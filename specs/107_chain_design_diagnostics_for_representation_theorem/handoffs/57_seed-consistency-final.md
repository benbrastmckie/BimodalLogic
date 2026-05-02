# Handoff: Burgess D0 Seed Consistency - Analysis Complete

**Session**: sess_1777696621_abe53e
**Date**: 2026-05-01
**Status**: Analysis complete, no code changes made
**Agent**: lean-implementation-agent

## Summary

Conducted exhaustive analysis of the 3 remaining sorry sites in PointInsertion.lean. All require the same core proof technique: Burgess compression (showing SetConsistent for a seed containing formulas from multiple MCSs/DCSs).

## Sorry Sites

| # | Line | Theorem | Goal |
|---|------|---------|------|
| 1 | ~1126 | `burgess_D0_finite_subset_consistent` | `SetConsistent (burgess_D0_seed A B C beta)` with hypotheses: h_mcs_A, h_r3m, h_neg_cons, h_F_beta_neg |
| 2 | ~1150 | `burgess_D0_finite_subset_consistent_incons` | Same goal, with h_beta_neg_in_B instead of h_neg_cons/h_F_beta_neg |
| 3 | ~1586 | `lemma_2_7_seed_consistent` | `SetConsistent (lemma_2_7_seed A B C xi eta)` with h_mcs_A, h_mcs_C, h_r3m, h_gc, h_until, h_eta_not_B |

## Core Difficulty

The seed `burgess_D0_seed A B C beta = B cup {beta.neg} cup {untl(b',g) : b' in B, g in C} cup {snce(b',a) : b' in B, a in A}` spans THREE different sets:
- B elements: in B (DCS, not necessarily in A or C)
- untl formulas: in A (by burgessR3)
- snce formulas: in C (by burgessR3)

No single MCS contains all of D0. Therefore `SetConsistent_of_subset` to a single MCS does NOT work.

## Approaches Exhaustively Ruled Out

1. **D0 subset of single MCS**: B is not subset of A, snce formulas not in A.
2. **D0 subset of {beta.neg} cup g_content(A)**: B subset of g_content(A) requires density (unprovable in BX).
3. **D0 subset of {beta.neg} cup g_content(A) cup h_content(C)**: The union can be inconsistent (G(p) in A + H(neg p) in C gives {p, neg p} in the seed).
4. **Deduction theorem separation**: Separating A-formulas and C-formulas from B-elements does not yield a contradiction because the resulting iterated implication is NOT absurd.
5. **Forward-temporal lifting**: Cannot uniformly lift via G because seed contains formulas from C (snce) that have no G-relationship to A.

## Correct Approach: Burgess Compression (Plan-Compliant)

The ONLY approach that works is Burgess's original (1982, p.370-371):

### Bridge Lemma (to prove first)

```
theorem seed_consistent_of_F_covering {A : Set Formula} {S : Set Formula}
    (h_mcs_A : SetMaximalConsistent A)
    (h_cover : forall L : List Formula, (forall phi in L, phi in S) ->
      exists zeta, F(zeta) in A and (forall phi in L, DerivationTree [zeta] phi)) :
    SetConsistent S
```

Proof: Given L subset S with L derives bot. Get zeta from h_cover. {zeta} cup g_content(A) consistent (from F(zeta) in A via forward_temporal_witness_seed_consistent). Lindenbaum to MCS M. zeta in M. Each phi in L derivable from [zeta], hence in M (MCS closed_under_derivation). So L subset M. M consistent, contradiction.

### Event Construction (for each finite L subset D0)

Given finite L subset D0:
1. **B-compression**: b = conjunction of B-elements in L. b in B (DCS conj-closed).
   Include beta0 from h_neg_until_exists in the conjunction (take b = beta0 AND b1 AND ... AND bk).
2. **BX chain for b**: Since b in B and b implies beta0:
   - untl(b, gamma0) in A (burgessR3 with b in B, gamma0 in C)
   - BX5: untl(b AND untl(b,gamma0), gamma0) in A
   - neg-untl(b AND beta, gamma0) in A (from neg-untl(beta0 AND beta, gamma0) via left_mono contrapositive, using derives b implies beta0)
   - BX14: untl(q, q AND (b AND beta).neg) in A where q = b AND untl(b, gamma0)
   - BX10: F(q AND (b AND beta).neg) in A
3. **F-mono strengthening**: The event q AND (b AND beta).neg implies b and beta.neg.
   Use F_mono_mcs to get F(b AND beta.neg) in A.
4. **Enrichment via BX13**: From untl(b, gamma_i) in A (each i) and snce(b, alpha_j) in A???

   **BLOCKER**: BX13 requires p in A. snce(b, alpha_j) is in C, not A!

### The BX13 Blocker for Since Formulas

BX13: `p AND U(phi,psi) implies U(phi, psi AND S(phi, p))`

To pack snce(b, alpha_j) into the event, we'd need snce(b, alpha_j) in A. But snce(b,alpha_j) in C.

**Burgess's resolution** (semantic intuition): The Since formula S(beta,alpha) at the new point D says "in the past (towards A), alpha held and beta was the guard." This is consistent with U(beta,gamma) at the same point. The axiom system cannot DERIVE a contradiction between them because semantically they CAN coexist.

**Syntactic resolution**: Use a different strategy for the snce-elements of L.

### Proposed Resolution Strategy

**Option A**: Show that for any finite L subset D0, the sublist of snce-formulas can be handled separately:
- The untl/B/beta.neg part: consistent via the BX chain (F(event) in A covers these)
- Adding snce formulas: doesn't create inconsistency because snce(b,alpha) in C and C is consistent

Formally: from L = L_base ++ L_snce with L derives bot:
- By deduction theorem: L_base derives (iterated_implication ending in bot)
- This gives L_base derives neg(conj of L_snce elements)
- Show this contradicts... something about C's consistency

This approach requires: showing that neg(conj of snce-formulas) is NOT derivable from the base+untl elements. Since all snce(b,alpha_j) in C (MCS, consistent), their conjunction is in C, so its negation is NOT in C. But we need it to not be derivable from A-elements either.

**Option B** (cleaner): Use the DUAL of the BX chain.
- BX13' (enrichment_since): `p AND S(phi,psi) implies S(phi, psi AND U(phi,p))`
- Work from the C-side: get P(event') in C where event' implies snce-formulas
- Combine with the A-side result

**Option C** (simplest, may work): Show F(full_event) in A where full_event implies ALL of L.
- Use BX13 with p = untl(b, gamma_i) IN A to pack U-formulas into the event
- The event then contains S(q, untl(b,gamma_i)) which is a Since-formula with guard q
- Show this event implies the original untl(b',gamma_i) via left_mono_since + derivation
- For snce-formulas: show the event implies snce(b', alpha_j) via a different derivation
  (the event contains b which implies b', and the Until structure at the event point
  means there's a past connection to where alpha_j holds)

### Recommended Next Steps

1. **Prove the bridge lemma** `seed_consistent_of_F_covering` (clean, self-contained)
2. **Implement Option C**: BX13 with p = untl(b, gamma_i) (in A!) to enrich the event
3. **Show event implies each L element** via derivation-level left_mono + conj_elim
4. **Handle snce separately** using the dual BX13' from C-side, or show it's absorbed

### Available Infrastructure

All exist and are usable:
- `derivation_from_implied` (line 1061): list-level cut
- `enrichment_until_mcs` (line 988): BX13 at MCS level
- `separation_until_mcs` (line 975): BX14 at MCS level  
- `self_accum_until_mcs` (line 966): BX5 at MCS level
- `until_implies_F_mcs` (line 1000): BX10 at MCS level
- `F_mono_mcs` (line 1009): F-monotonicity at MCS level
- `untl_left_mono_thm` (RRelation.lean:1019): left-mono for Until
- `snce_left_mono_thm` (RRelation.lean:1037): left-mono for Since
- `dcs_conj_closed` (ChronicleTypes.lean:113): DCS conjunction closure
- `forward_temporal_witness_seed_consistent` (Bundle/WitnessSeed.lean:81)
- `set_lindenbaum` (Core/MaximalConsistent.lean:291)
- `SetMaximalConsistent.closed_under_derivation` (Core/MCSProperties.lean)
- `h_neg_until_exists` (line 1219): specific beta0, gamma0 from maximality

### Key Formulas (for implementer reference)

```
burgess_D0_seed A B C beta =
  B cup {beta.neg} cup
  {phi | exists b' in B, exists g in C, phi = Formula.untl b' g} cup
  {phi | exists b' in B, exists a in A, phi = Formula.snce b' a}

lemma_2_7_seed A B C xi eta =
  B cup {xi} cup {phi | exists b in B, exists g in C, phi = Formula.untl b g} cup
  {phi | exists b in B, exists a in A, phi = Formula.snce b a} cup
  {phi | exists b in B, exists a in A, phi = Formula.snce (Formula.and b eta) a}
```

### Estimated Effort

- Bridge lemma: 1 hour
- Event construction with BX13 for A-elements: 3 hours
- Handling snce (C-elements): 3 hours
- Connecting everything + closing sorry sites: 2 hours
- Total: ~9 hours

### Plan Update Suggestion

The plan (v52) may need revision for Phase 2 remaining work. Specifically:
- The BX5+BX14+BX10 chain is DONE (lines 1258-1317)
- What remains is the SEED CONSISTENCY proof which requires BX13 enrichment for A-elements
- The snce-element handling needs clarification (BX13 cannot directly pack C-elements into A's Until chain)
- Consider whether a plan revision (`/revise 107`) would help clarify the exact decomposition of this proof
