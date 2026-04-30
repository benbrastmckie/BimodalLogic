# Burgess 1982 Alignment Audit

**Task**: 107 -- chain_design_diagnostics_for_representation_theorem
**Session**: sess_1777516628_acef45
**Date**: 2026-04-29
**Artifact**: 49

## 1. Burgess-to-Codebase Mapping Table

| Burgess | Statement | Codebase Equivalent | File | Status | Notes |
|---------|-----------|---------------------|------|--------|-------|
| **2.1 Replacement** | Substitution equivalence preservation | `DerivationTree.subst` / Substitution.lean | Substitution.lean | OK | Standard, not explicitly named |
| **2.2 Consistency** | U(gamma, delta) in MCS A implies gamma consistent | `until_witness_seed_consistent` (partial) | PointInsertion.lean:139 | DEVIATED | Burgess 2.2 is FALSE under strict semantics for gamma=bot (documented in RRelation.lean). Our codebase does not formalize 2.2 directly; instead uses BX10 (until_F) for the seed consistency role. This is correct. |
| **2.3 Lemma** | r(A, beta, C) equivalence: (a) forall gamma in C, U(gamma, beta) in A <=> (b) forall alpha in A, S(alpha, beta) in C | `burgessR`, `burgessRSince`, `burgessR_implies_burgessRSince`, `burgessRSince_implies_burgessR` | ChronicleTypes.lean:279-301, RRelation.lean:1219-1330 | OK | Correctly formalized with both directions proved sorry-free. |
| **r(A, B, C)** | B is DCS, r(A, beta, C) for all beta in B | `burgessR3` = `burgessRSet` AND `burgessRSetSince` | ChronicleTypes.lean:310-311 | OK | Three-argument version correctly includes both forward and backward. |
| **R(A, B, C)** | B maximal DCS with r(A, B, C) | `BurgessR3Maximal` | ChronicleTypes.lean:320-323 | OK | Uses `SetDeductivelyClosed` (correct, matches Burgess's DCS maximality). Changed from `ClosedUnderDerivation` in Phase 8a -- this was the right fix. |
| **2.4 Lemma** | U(gamma, beta) in A implies exist B, C with R(A,B,C), beta in B, gamma in C | `lemma_2_4` (noncomputable def) | PointInsertion.lean:153 | OK | Sorry-free. Uses BX4/BX5/BX10 instead of A3a (correct for strict semantics). |
| **2.5 Lemma** | R(A,B,C) + r(A,B',D) + r(D,B'',C) + B subset B' cap D cap B'' implies B = B' cap D cap B'' | `burgessR3_absorption` + `burgessR_absorption` + related | RRelation.lean:480-605 | PARTIAL | The absorption lemmas exist and are sorry-free. The full 2.5 intersection equality is NOT explicitly stated as a standalone theorem but the components are present. `lemma_2_5b` in PointInsertion.lean provides the needed transitivity. Lemma 2.5 as stated is not needed because our construction uses `burgessR3Maximal_from_g_content_sub` instead of direct B maximality. |
| **2.6 Lemma** | R(A,B,C) + delta not in B implies exist B', D, B'' with neg-delta in D, R(A,B',D), R(D,B'',C), B = B' cap D cap B'' | `lemma_2_6_splitting` | PointInsertion.lean:909-934 | ARCHITECTURALLY WRONG | Uses seed `{beta.neg} union g_content(A) union h_content(C)`, NOT Burgess's seed `{S(alpha,beta) : alpha in A, beta in B} union B union {neg-delta} union {U(gamma,beta) : gamma in C, beta in B}`. This deviation requires `g_content_sub_B_of_BurgessR3Maximal` (which has sorry). See Section 4. |
| **2.7 Lemma** | R(A,B,C) + U(xi,eta) in A + eta not in B implies exist B', D, B'' with eta in B', xi in D | `lemma_2_7` | PointInsertion.lean:1033-1053 | SORRY | Entire body is sorry. Strategy documented in docstring uses BX5+BX7+BX13 chain. See Section 4. |
| **2.8 Lemma** | Like 2.7 but with neg(xi or (eta and U(xi,eta))) in C | Not formalized | -- | NOT NEEDED | Handoff correctly identifies this as not needed. Burgess uses 2.8 as an alternative for the C5 n=m+1 case. Our C5 elimination uses a different induction scheme. |
| **2.9 C4 Elim** | Counterexample to C4a can be eliminated | `eliminate_C4_counterexample` | CounterexampleElimination.lean:304 | 1 SORRY | Hard case (gamma in f(x) AND gamma in f(y)) has sorry at line 412. Needs c2' (BurgessR3Maximal for adjacent pair) + Lemma 2.6. |
| **2.9' C4' Elim** | Mirror for C4b (Since) | `eliminate_C4'_counterexample` | CounterexampleElimination.lean:426 | 1 SORRY | Mirror of 2.9. Sorry at line 510. |
| **2.10 C5 Elim** | Counterexample to C5a can be eliminated | `eliminate_C5_counterexample` | CounterexampleElimination.lean:167 | OK | Sorry-free. Appends point after domain, uses `lemma_2_4`. |
| **2.10' C5' Elim** | Mirror for C5b (Since) | `eliminate_C5'_counterexample` | CounterexampleElimination.lean:211 | OK | Sorry-free. |
| **2.11 Truth Lemma** | (+) holds for all alpha | `cantor_bfmcs_restricted_fuc` (FUC/FSC parts) | ChronicleToCountermodel.lean:604 | 2 SORRY | Forward Until coherence and Forward Since coherence each have sorry. Requires full C5 with guard (the interval g function). |
| **C0-C3** | Chronicle conditions | `Chronicle.c0` through `Chronicle.c3` | ChronicleTypes.lean:347-385 | OK | All correctly formalized. C3 uses three-way intersection (correct). |
| **C4a/C4b** | Counterexample conditions | `Chronicle.c4`, `Chronicle.c4'` | ChronicleTypes.lean:401-421 | OK | Correctly applies to ALL pairs (not just adjacent). |
| **C5a/C5b** | Witness conditions | `Chronicle.c5`, `Chronicle.c5'` | ChronicleTypes.lean:427-442 | OK | Note: C5 currently uses weaker guard (guard at domain points only), which may need strengthening for the full truth lemma. |

## 2. Archive Candidates (Move to Boneyard/)

These theorems/definitions exist because of the architectural deviation from Burgess's seed and should be archived once the seed is restructured.

### 2.1 `g_content_sub_B_of_BurgessR3Maximal` (PointInsertion.lean:824-850)

**Rationale**: This theorem tries to prove `g_content(A) subset B` when `BurgessR3Maximal(A, B, C)`. Burgess NEVER needs this -- his seed D0 includes all of B directly, so the question "is g_content inside B?" never arises. The theorem has 1 sorry (the inconsistent case, which is semantically impossible on dense orders but syntactically unprovable in BX).

**Dependents**: Called by `splitting_seed_consistent` (line 898). When the seed is restructured, this caller disappears.

### 2.2 `h_content_sub_B_of_BurgessR3Maximal` (PointInsertion.lean:853-875)

**Rationale**: Dual of 2.1. Same architectural problem. 1 sorry.

**Dependents**: Called by `splitting_seed_consistent` (line 899). Same as above.

### 2.3 `splitting_seed_consistent` (PointInsertion.lean:890-907)

**Rationale**: This is the non-Burgess seed consistency proof. It uses the wrong seed `{beta.neg} union g_content(A) union h_content(C)` instead of Burgess's D0. The ENTIRE function needs replacement, not patching.

**Dependents**: Called by `lemma_2_6_splitting` (line 920).

### 2.4 Helper functions supporting the wrong seed

The following private helpers in PointInsertion.lean exist to support the g_content/h_content seed approach and become dead code after restructuring:

- `g_content_consistent_case` (line 785) -- used only by `g_content_sub_B_of_BurgessR3Maximal`
- `G_conj_strengthen` (line 772) -- used only by `g_content_consistent_case`
- `H_conj_strengthen` (line 803) -- used only by `h_content_sub_B_of_BurgessR3Maximal`

## 3. Delete Candidates (Not Worth Archiving)

### 3.1 Comments referencing removed code

Lines 1055-1067 in PointInsertion.lean contain comments about removed code already archived in `Boneyard/ClosedGuardLegacy/ClosedGuardRRelation.lean`. These are pure comments and can be kept or removed -- no functional impact.

### 3.2 Stale docstrings

The docstring at PointInsertion.lean:877-886 documents the wrong seed approach. Should be replaced with documentation of the Burgess seed when restructured.

Nothing in the codebase is worth deleting outright -- the dead code is small and documented. Archive to Boneyard is preferable for traceability.

## 4. Seed Restructuring Plan

### 4.1 The Problem

Our `lemma_2_6_splitting` uses seed `{beta.neg} union g_content(A) union h_content(C)`. This requires proving `g_content(A) subset B` and `h_content(C) subset B` to show the seed is subset of `{beta.neg} union B` (and hence consistent via `dcs_neg_union_consistent`). But `g_content_sub_B_of_BurgessR3Maximal` has an unprovable sorry.

Burgess's seed is fundamentally different: `D0 = {S(alpha, beta) : alpha in A, beta in B} union B union {neg-delta} union {U(gamma, beta) : gamma in C, beta in B}`. He proves D0 consistent by reducing to showing each particular

    zeta = S(alpha, beta) AND beta AND neg-delta AND U(gamma, beta)

is consistent, using A4a, A5a, A7a, A3a (pp. 370-371).

### 4.2 Adaptation for Strict/Open-Guard Semantics

Burgess uses A3a (`p AND U(q,r) -> U(q AND S(p,r), r)`) and A4a (`U(p,q) AND neg-U(p,r) -> U(q AND neg-r, q)`). Neither A3a nor A4a is valid under strict semantics (documented in PointInsertion.lean header).

Our BX system has replacements:
- **A3a's role**: BX4 (`connect_future: phi -> G(P(phi))`) provides the S-formula embedding
- **A4a's role**: BX5 (`self_accum_until`) + BX7 (`linear_until`) provide the structural split
- **A5a**: BX5 is essentially equivalent (self-accumulation)
- **A7a**: We have `Axiom.linear_until_a7a` (added Phase 8b) which IS Burgess's A7a

The key question is whether Burgess's D0 consistency proof can be adapted to use BX axioms instead of A3a/A4a. The structure of the argument is:

1. From R(A,B,C) with delta not in B: obtain beta0 in B, gamma0 in C with neg-U(gamma0, beta0 AND delta) in A
2. WLOG beta0=beta, gamma0=gamma (by replacing with beta AND beta0, gamma AND gamma0)
3. From U(gamma,beta) in A and neg-U(gamma, beta AND delta) in A: by A5a get U(gamma, beta AND U(gamma,beta)) in A
4. A4a gives U(beta AND U(gamma,beta) AND neg-delta, beta) in A
5. A3a gives U(beta AND U(gamma,beta) AND neg-delta AND S(alpha,beta), beta) in A
6. By 2.2 (consistency criterion): zeta is consistent

Steps 3-5 use A5a (=BX5), A4a, A3a. The adaptation:

- Step 3: BX5 gives `U(gamma AND U(gamma,beta), beta) in A` -- same as Burgess's `U(gamma, beta AND U(gamma,beta))` modulo guard/event swap (our Until convention). OK.
- Step 4: A4a combines U(gamma,beta) with neg-U(gamma, beta AND delta). In BX, we need: from `U(gamma,beta)` and `neg-U(gamma, beta AND delta)`, derive `U(beta AND U(gamma,beta) AND neg-delta, beta)`. This is where BX7 (linear_until) comes in: the two Until formulas with the same structure but different guards can be decomposed.
- Step 5: A3a embeds the S-formula. In BX, BX4 (`phi -> G(P(phi))`) gives S-like content.

**Assessment**: The adaptation is non-trivial but likely feasible. The core technique is the same (reduce to showing a single conjunction is consistent via Until-in-MCS + consistency criterion). The BX axioms provide the same algebraic operations in a different packaging.

### 4.3 Alternative: Keep Our Seed but Fix the Sorry

The sorry in `g_content_sub_B_of_BurgessR3Maximal` is in the "inconsistent case": `{phi} union B` inconsistent implies `phi.neg in B`. This is algebraically true (deduction theorem). The issue is showing this leads to a contradiction with `G(phi) in A` and `burgessR3(A, B, C)`.

The proof attempt says: `G(phi) in A` and `U(phi.neg, gamma) in A` (from burgessR3 with phi.neg in B). On dense orders, this is contradictory because U(phi.neg, gamma) requires phi.neg at some point in (t,s), but G(phi) means phi holds everywhere. However, BX has no density axiom.

**Verdict**: This sorry is UNFIXABLE without a density axiom. The Burgess seed approach bypasses the problem entirely.

### 4.4 Recommended Changes

**Phase A: Replace splitting_seed_consistent with Burgess's D0 seed**

1. Define `burgess_D0` as a function:
   ```
   def burgess_D0 (A B C : Set Formula) (delta : Formula) : Set Formula :=
     { Formula.snce alpha beta | (alpha : Formula) (beta : Formula) (_ : alpha ∈ A) (_ : beta ∈ B) }
     ∪ B
     ∪ {delta.neg}
     ∪ { Formula.untl gamma beta | (gamma : Formula) (beta : Formula) (_ : gamma ∈ C) (_ : beta ∈ B) }
   ```

2. Prove `burgess_D0_consistent`: reduce to showing each particular `zeta = S(alpha, beta) AND beta AND neg-delta AND U(gamma, beta)` with alpha in A, beta in B, gamma in C is consistent. Use BX5 + BX7 + BX4 chain (adapted from Burgess pp. 370-371).

3. Prove `burgess_D0_extends_B`: `B subset burgess_D0 A B C delta` (immediate from definition).

4. Replace `splitting_seed_consistent` with `burgess_D0_consistent`.

5. Update `lemma_2_6_splitting` to use `burgess_D0` as seed, then Lindenbaum to MCS D, then extract:
   - `delta.neg in D` (from seed)
   - `B subset D` (from seed)
   - `r(A, B', D)` and `r(D, B'', C)` from the S/U-formulas in the seed (immediate from seed membership in MCS D)
   - `B subset B'` and `B subset B''` (from seed structure)
   - `B = B' cap D cap B''` (from Lemma 2.5 / maximality)

6. Archive `g_content_sub_B_of_BurgessR3Maximal`, `h_content_sub_B_of_BurgessR3Maximal`, and old `splitting_seed_consistent` to Boneyard.

**Phase B: Restructure Lemma 2.7 similarly**

1. Define `burgess_D0_until` for the Lemma 2.7 seed:
   ```
   D0 = { S(alpha, beta AND eta) | alpha in A, beta in B }
        ∪ B ∪ {xi}
        ∪ { U(gamma, beta) | gamma in C, beta in B }
   ```
   (Burgess p. 371, with beta AND eta in the Since formulas and xi as the event witness)

2. Prove `burgess_D0_until_consistent` using BX5 + BX7 (linear_until) + A7a (linear_until_a7a). This is where A7a gets used -- the three-way disjunction from A7a eliminates two branches via neg-U(gamma, beta AND eta).

3. Update `lemma_2_7` to use this seed. Extract xi in D, eta in B' (from maximality of B' with B subset B').

**Phase C: Fix C4 hard case**

With Lemma 2.6 sorry-free, the C4 hard case (CounterexampleElimination.lean:412) reduces to:
1. Get BurgessR3Maximal for the adjacent pair (w, w_next) from c2'
2. Show gamma not in g(w, w_next) using `burgessR3_gamma_not_in_B`
3. Apply `lemma_2_6_splitting` to get D with neg-gamma in D

The sorry disappears once c2' is in the omega chain invariant and lemma_2_6 is sorry-free.

**Phase D: Fix C5/truth lemma**

The 2 sorries in `cantor_bfmcs_restricted_fuc` (ChronicleToCountermodel.lean:615, 619) require the full interval function g at the limit, with C3 providing guard membership. This depends on the omega chain maintaining C1+C3 (which it does via `limit_g` and `limit_c3` in ChronicleConstruction.lean). The remaining gap is connecting the limit g-values to the BFMCS structure.

## 5. SoundnessLemmas Fix

The handoff said 6 match arms were missing. Checking the current code:

**Current state**: All 4 functions in SoundnessLemmas.lean ALREADY HAVE `linear_until_a7a` and `linear_since_a7a` match arms (8 entries total at lines 766, 792, 1396, 1422, 1887, 1912, 2199, 2225).

**BUT**: Functions 3 and 4 have TYPE ERRORS in the A7a cases. The build output shows:

```
SoundnessLemmas.lean:2242:42: Application type mismatch
  h_guard₁ r ... has type truth_at M Omega tau r phi
  but expected truth_at M Omega tau r psi
```

The fix is the guard order swap documented in the handoff: for the D3 case, swap `(h_guard₂ r ...) (h_guard₁ r ...)` to `(h_guard₁ r ...) (h_guard₂ r ...)` (or vice versa depending on direction). The BX7 D3 branch has guards in a different order than A7a's D3 branch because A7a conjoins the guards differently.

**Specific fixes needed** (2 errors, not 6):
1. `axiom_locally_valid_general` (~line 2242): swap guard arguments in D3 case
2. `axiom_locally_valid_general` (~line 2249): swap guard arguments in D3 Since case

The other functions (axiom_swap_valid at 766/792, axiom_locally_valid at 1396/1422, axiom_swap_valid_general at 1887/1912) appear to compile clean based on the error output showing only SoundnessLemmas.lean errors in the 2200+ range.

## 6. Dependency Analysis

### Dependency Graph

```
Lemma 2.6 (seed restructuring)
  ├── enables: C4 hard case sorry elimination
  │     └── enables: omega chain maintains C4 at limit
  └── enables: Lemma 2.7 (same seed pattern)
        └── enables: C5 full guard (with interval function)
              └── enables: FUC/FSC in truth lemma

SoundnessLemmas fix (guard swap)
  └── INDEPENDENT of all above

g_content_sub_B archive
  └── depends on: Lemma 2.6 seed restructuring (to remove callers)

c2' in omega chain
  └── depends on: point insertion maintaining c2' (which it does via g-values defined by C3)
  └── enables: C4 hard case
```

### Independent Workstreams

1. **SoundnessLemmas guard swap** -- can be done immediately, no dependencies
2. **Lemma 2.6 seed restructuring** -- core work, no blockers
3. **Lemma 2.7 seed restructuring** -- depends on Lemma 2.6 pattern (same technique)
4. **C4 hard case** -- depends on Lemma 2.6 + c2' invariant
5. **FUC/FSC truth lemma** -- depends on everything above
6. **Archive to Boneyard** -- depends on Lemma 2.6 restructuring completing

### Recommended Execution Order

1. SoundnessLemmas guard swap (5 minutes, unblocks build)
2. Lemma 2.6 seed restructuring (core)
3. Archive dead code
4. Lemma 2.7 seed restructuring
5. C4 hard case
6. FUC/FSC truth lemma

## 7. Sorry Census (Current)

| File | Count | Description |
|------|-------|-------------|
| PointInsertion.lean | 2 | `g_content_sub_B_of_BurgessR3Maximal` (ELIMINATE via seed) |
| PointInsertion.lean | 1 | `lemma_2_7` (REWRITE with Burgess seed) |
| CounterexampleElimination.lean | 1 | C4 hard case (DEPENDS on Lemma 2.6 + c2') |
| CounterexampleElimination.lean | 1 | C4' hard case (mirror of C4) |
| ChronicleToCountermodel.lean | 2 | FUC/FSC (DEPENDS on full C5 with guard) |
| **Total** | **7** | |

After seed restructuring: the 2 g_content_sub_B sorries are eliminated. The lemma_2_7 sorry is replaced with a real proof. Net: 4 sorries remaining (C4/C4' hard + FUC/FSC).

## 8. Build Status

Current build FAILS on `SoundnessLemmas.lean` (type errors in A7a match arms, lines ~2242-2250). Fix is mechanical: swap guard variable references. After fix, build should succeed (with sorry warnings in PointInsertion, CounterexampleElimination, ChronicleToCountermodel).
