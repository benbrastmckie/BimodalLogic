# Phase 3 Results: Point Insertion Lemmas (2.4-2.8)

## Status: PARTIAL

## Summary

Created `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean` implementing
the core point insertion machinery for the Burgess chronicle construction, adapted for
strict (irreflexive) temporal semantics.

## Fully Proved (sorry-free)

### Helper Lemmas
- `F_neg_of_G_not`: If G(phi) not in MCS A, then F(neg phi) in A. Key helper for converting
  absence of G-formulas into presence of F-formulas via double-negation elimination under G.
- `until_witness_seed_consistent`: {beta} union g_content(A) is consistent when U(gamma, beta) in A.
  Uses BX10 (until_F) + forward_temporal_witness_seed_consistent.
- `until_elim_mcs`: BX9 at MCS level: U(gamma, beta) implies gamma or beta.
- `until_F_mcs`: BX10 at MCS level: U(gamma, beta) implies F(beta).
- `self_accum_until_mcs`: BX5 at MCS level: U(gamma, beta) implies U(gamma and U(gamma,beta), beta).
- `connect_future_mcs`: BX4 at MCS level: phi implies G(P(phi)).
- `conj_mcs`: Conjunction introduction at MCS level.
- `conj_left_mcs`, `conj_right_mcs`: Conjunction elimination at MCS level.
- `lemma_2_7_guard`: Guard extraction -- U(xi, eta) with eta not in A gives xi in A.

### Lemma 2.4 (Until Witness Endpoint Construction)
Fully proved. Given MCS A with U(gamma, beta) in A, constructs MCS C with:
- beta in C (witness)
- g_content(A) subset C (temporal coherence)
- P(U(gamma, beta)) in C (past Until evidence via BX4)

Adapted for strict semantics: gamma in C is NOT guaranteed (guard covers [t,s) not {s}).
The chronicle's interval DCS handles the guard in Phase 4.

### Lemma 2.5b (g_content Ordering Composition)
Fully proved. If g_content(A) subset D and g_content(D) subset C, then g_content(A) subset C.
Uses temp_4 (G implies GG). Also proved the past dual (lemma_2_5b_past).

### Lemma 2.6 (Counterexample Insertion)
Fully proved. Given g_content(A) subset C with delta not in C, constructs MCS D with:
- neg delta in D
- g_content(A) subset D

Uses F_neg_of_G_not + forward_temporal_witness_seed_consistent + Lindenbaum.

### Lemma 2.7 (D1 and D3 cases)
The BX7 (linear_until) application and three-way case split is fully implemented:
- D1 case (F(eta and neg eta) absurd): Fully proved via DNI temporal necessitation argument.
  Shows G(neg neg(eta implies neg neg eta)) in A contradicts F(eta and neg eta) in A.
- D3 case (F((xi and U(xi,eta)) and neg eta)): Fully proved. Extracts xi from the conjunction
  in the extended MCS.

### Lemma 2.8 (eta not in C case)
The eta not in C case reduces to Lemma 2.7 directly.

## Sorry Sites (4 total)

### 1. `lemma_2_6_strong` (line 360)
- Phase 2 dependency: requires h_content/g_content duality argument for the enriched seed
  {neg delta} union g_content(A) union h_content(C).
- The simpler `lemma_2_6` (without g_content(D) subset C guarantee) is fully proved and
  sufficient for Phase 4's counterexample elimination.

### 2-3. `lemma_2_7` D2 cases (lines 807, 814)
- D2 = U(phi and top, eta and top): the case where eta's witness comes BEFORE neg eta.
- Guard case (phi and top in A): xi is extractable at A's time, but propagating it to a
  FUTURE point D requires showing the Until guard persists at intermediate points.
  Under strict semantics, this needs a chain of BX axiom applications (BX5 self-accumulation
  on D2, then BX7 again, or BX4 connect_future).
- Witness case (eta and top in A): similar complexity.
- Mathematical strategy is documented in the file but formal derivation chains are complex.

### 4. `lemma_2_8` eta in C case (line 936)
- When eta in C but U(xi,eta) not in C: requires BX7 applied to U(xi,eta) and
  (top U neg U(xi,eta)), which is a variant of the Lemma 2.7 argument.

## Key Adaptation: Strict Semantics

The fundamental challenge identified and addressed: under strict Until semantics with
half-open guard [t,s), the guard gamma holds at t and at all intermediate points in (t,s),
but NOT at the witness point s. This means:

1. Lemma 2.4 cannot guarantee gamma at the endpoint MCS C (adapted to provide P(U(gamma,beta))
   as evidence instead)
2. Lemma 2.7's D2 case requires showing the guard persists at intermediate points via
   complex BX axiom chains (BX5 self-accumulation + BX7 linearity + BX12 F-Until bridge)
3. The interval DCS (Phase 2/4) must handle guard formulas separately from endpoint formulas

## Build Verification

- `lake build` succeeds (949 jobs, no errors)
- No new axioms introduced
- 4 sorry sites (all documented with clear mathematical strategies)
- No regressions in existing modules

## Files

- Created: `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean`
- Modified: `specs/107_.../plans/06_implementation-plan.md` (Phase 3 status: PARTIAL)
