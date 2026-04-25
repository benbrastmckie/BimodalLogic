# Teammate D Findings: Deep Codebase Analysis of Shared Infrastructure

**Task**: 107 - Burgess chronicle construction
**Date**: 2026-04-24
**Role**: Horizons/Code researcher - actual code analysis

---

## Mission 1: Map the Deterministic Chain's Sorry Sites

### File Locations (Corrected)

The Boneyard files are NOT at the paths mentioned in the task description. Actual locations:

- `Theories/Bimodal/Boneyard/ChainCompleteness/Algebraic/DeterministicFMCS.lean`
- `Theories/Bimodal/Boneyard/ChainCompleteness/Algebraic/DeterministicChain.lean`
- `Theories/Bimodal/Boneyard/ChainCompleteness/Algebraic/FiniteDeferral.lean`

OrderedSeedConsistency is NOT in Boneyard -- it is LIVE code:
- `Theories/Bimodal/Metalogic/BXCanonical/OrderedSeedConsistency.lean` (sorry-free, 255 lines)

### DeterministicFMCS.lean Sorry Inventory (4 sorries)

| # | Line | Definition | Goal | Closable? |
|---|------|-----------|------|-----------|
| 1 | 68 | `deterministic_forward_F` | `exists s > t, psi in chain(s)` given `F(psi) in chain(t)` | **ROOT BLOCKER** - circular with backward G |
| 2 | 74 | `deterministic_backward_P` | `exists s < t, psi in chain(s)` given `P(psi) in chain(t)` | Symmetric to #1 |
| 3 | 484 | `usc` forward Until | Depends on `deterministic_forward_F` | Blocked by #1 |
| 4 | 496 | `usc` forward Since | Depends on `deterministic_backward_P` | Blocked by #2 |

**Key observation**: Backward Until/Since (lines 486-505) are **sorry-free** using `backward_until_chain`/`backward_since_chain` with `until_intro`/`since_intro` + induction on chain distance. This is a solved problem.

### DeterministicChain.lean Sorry Inventory

The file has a `#exit` at line 786. Above it, ALL code compiles, but several proofs use `sorry` for:

| Pattern | Count | Lines | Nature |
|---------|-------|-------|--------|
| `temp_4 removed in BX` | 5 | 411, 525, 555, 598, 802+ | Uses BX `temp_4` axiom (Gp -> GGp) which IS in the axiom set but the derivation tree isn't being constructed properly |
| `x_det removed in BX` | 2 | 192, 217 | X-Det axiom removed from BX system |
| `y_det removed in BX` | 2 | 192, 220 | Y-Det axiom removed from BX system |
| `x_k_dist removed in BX` | 1 | 227 | X-K axiom removed from BX system |
| `y_k_dist removed in BX` | 1 | 201 | Y-K axiom removed from BX system |

**Critical finding**: The `temp_4` sorries are **false alarms** -- `temp_4` (Gp -> GGp) IS axiom `Axiom.temp_4` in the current BX system (Axioms.lean:112). The sorry annotations saying "temp_4 removed in BX" are STALE COMMENTS from an earlier refactoring. These could potentially be closed by constructing the actual `DerivationTree`.

**However**: The `x_det`, `y_det`, `x_k_dist`, `y_k_dist` removals are GENUINE -- BX8/BX8' were removed in the irreflexive semantics switch (task 93). These axioms are critical for:
- `YX_round_trip`: phi in M -> Y(X(phi)) in M
- `XY_round_trip`: phi in M -> X(Y(phi)) in M

Without BX8/BX8', the deterministic chain's XY-roundtrip identities fail, which means `x_mem_chain_general` and `y_mem_chain_general` are broken for negative indices.

### FiniteDeferral.lean Sorry Inventory (2 sorries)

| # | Line | Definition | Nature |
|---|------|-----------|--------|
| 1 | 325 | `G_neg_kills_until` | Uses `until_induction removed in BX` -- another axiom removed in the irreflexive switch |
| 2 | 381 | `forward_F_via_deferral` | The main theorem, which depends on breaking the forward_F / backward_G circularity |

**The FiniteDeferral approach is fundamentally blocked**: even if `G_neg_kills_until` were closed, `forward_F_via_deferral` has a genuine circularity documented at lines 340-377: deriving G(neg psi) from "neg psi in chain(s) for all s > t" requires backward G reasoning, which requires forward_F -- the very thing being proved.

### Assessment of Deterministic Chain

**The deterministic chain is DEAD under irreflexive semantics.** Three independent blockers:

1. **BX8 removal kills XY-roundtrip**: `x_mem_chain_general` for negative indices depends on `YX_round_trip` which needs BX8 (`sorry /- y_det removed in BX -/`)
2. **Forward F/P circularity**: The root cause is that F(psi) in chain(t) cannot be resolved without controlling Lindenbaum extensions (same Lindenbaum opacity as BXCanonical)
3. **Until induction axiom removed**: `G_neg_kills_until` depends on an axiom not in the current system

However, the **backward Until/Since proofs ARE reusable** (see Mission 2).

---

## Mission 2: Map Shared Infrastructure

### PointInsertion.lean -- CHRONICLE ONLY, NOT USABLE BY DETERMINISTIC

- **Location**: `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean` (558 lines)
- **Status**: Sorry-free
- **Imports**: `Frame.lean`, `OrderedSeedConsistency.lean`, `TemporalDerived`
- **Key sorry-free lemmas**:
  - `lemma_2_4`: Until witness endpoint (beta, g_content(A), P(U(gamma,beta)))
  - `lemma_2_5b`: g_content ordering transitivity (uses `temp_4`)
  - `lemma_2_6`: Negative insertion (neg delta, g_content(A))
  - `lemma_2_7_guard`: Guard extraction (BX9)
  - `G_implies_F_mcs`: G(alpha) -> F(alpha) in MCS (seriality + BX3 + BX10 + BX12)
  - `H_implies_P_mcs`: Dual
  - `g_propagation_witness`: G(alpha) -> exists D with alpha and g_content
- **NOT importable by deterministic chain**: Uses `BXCanonical.Frame` which the Boneyard files don't import

### RRelation.lean -- CHRONICLE ONLY

- **Location**: `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/RRelation.lean` (345 lines)
- **Status**: Sorry-free
- **Key results**: `rMaximal_extension_exists` (Zorn's lemma), `deductiveClosure_is_dcs`, `rRelation_guard_continues'`
- **Used by**: Chronicle construction only (imports `ChronicleTypes.lean`)

### SuccRelation.lean -- LEGACY, USED BY DETERMINISTIC CHAIN

- **Location**: `Theories/Bimodal/Metalogic/Bundle/SuccRelation.lean` (627 lines)
- **Status**: 3 sorries (`g_content_subset_mcs`, `h_content_subset_mcs`, `until_persists_through_succ`)
- **Key sorry-free results**:
  - `single_step_forcing` (lines 232-268): If F(phi) in u, FF(phi) not in u, Succ u v -> phi in v
  - `single_step_forcing_past` (lines 353-501): Dual for P direction
  - `or_until_in_mcs` / `or_since_in_mcs`: Disjunction -> Until/Since in MCS
- **Irreflexive blockers**:
  - `g_content_subset_mcs` (line 613-617): `g_content(u) subset u` -- FALSE under irreflexive semantics (requires BX1: Gp -> p)
  - `h_content_subset_mcs` (line 620-626): Dual, also false
  - `until_persists_through_succ` (line 542-548): Blocked, documented as needing X-content propagation

### OrderedSeedConsistency.lean -- LIVE, SHARED

- **Location**: `Theories/Bimodal/Metalogic/BXCanonical/OrderedSeedConsistency.lean` (255 lines)
- **Status**: Entirely sorry-free
- **Key results**:
  - `enriched_resolving_seed_consistent`: F(psi AND alpha) in M -> {psi, alpha} union g_content(M) consistent
  - `ordered_two_defect_seed_consistent`: F(psi1 AND F(psi2)) -> {psi1, F(psi2)} union g_content(M) consistent
  - `temp_linearity_mcs`: BX11 at MCS level
  - `two_defect_consistent_seed`: Given two F-defects, produces consistent resolving seed
  - `no_new_f_defects`: G(neg alpha) propagation blocks new F-defects
- **Importable by**: Both paths (chronicle and any future chain construction)

### Boneyard Files Assessment

| File | Status | Relevant? |
|------|--------|-----------|
| `DeterministicChain.lean` | Broken (BX8 removal) | **Backward Until/Since proof pattern reusable** |
| `DeterministicFMCS.lean` | 4 sorries, root-blocked | BFMCS wiring pattern reusable |
| `FiniteDeferral.lean` | 2 sorries, fundamentally blocked | Pigeonhole infrastructure reusable |

---

## Mission 3: ROADMAP Minimum Sorry Path

### ROADMAP Goal
> "TM is complete with respect to TaskFrames over totally ordered abelian groups."

This is D=Rat completeness (not general completeness).

### Current Sorry Count by Path

**Chronicle path** (12 sorries across 3 files):
- `ChronicleConstruction.lean`: 1 sorry (`g_content_chain_property`, line 748)
- `CounterexampleElimination.lean`: 2 sorries (C4 sub-case 1a at lines 289, 355)
- `ChronicleToCountermodel.lean`: 9 sorries (temporal/Until/Since coherence wiring)

**BXCanonical path** (19 sorries across 7 files): Blocked by Lindenbaum opacity.

### Minimum Sorry Path Analysis

The 12 chronicle sorries decompose as follows:

**Root cause sorries** (close these and others cascade):

1. **`g_content_chain_property`** (ChronicleConstruction.lean:748): For x < y in limit_dom, g_content(limit_f(x)) subset limit_f(y). This is the SINGLE ROOT CAUSE. Closing it gives:
   - `limit_forward_G` (trivial corollary)
   - `limit_backward_H` (via proven `g_content_sub_imp_h_content_sub` duality)

2. **C4 sub-case 1a** (CounterexampleElimination.lean:289, 355): When delta in f(x) AND delta in f(y) for adjacent x,y. The comment says "C3 + r-relation structure prevents this sub-case from arising." If C3 is maintained through the omega-chain (i.e., `g_content_chain_property` is proved), these 2 sorries become provable.

**Dependent sorries** (cascade from root cause):

3. **`chronicle_fmcs` forward_G/backward_H** (ChronicleToCountermodel.lean:192-196): Directly depends on `g_content_chain_property`
4. **`box_stable_in_chronicle_fmcs`** (line 234): Uses forward_G/backward_H
5. **`chronicle_bfmcs_restricted_tc`** (lines 321-323): F/P resolution -- needs domain-point case analysis + limit_F_resolution (already proved!)
6. **`chronicle_bfmcs_restricted_buc`** (lines 342-344): Backward Until/Since -- the deterministic chain's `backward_until_chain`/`backward_since_chain` pattern applies here
7. **`chronicle_bfmcs_restricted_fuc`** (lines 374-377): Forward Until/Since -- uses `limit_satisfies_c5_weak` (already proved!)

### Can we close fewer than 12 sorries?

**Yes. The true dependency count is 3 independent sorries:**

1. `g_content_chain_property` (1 sorry) -- ROOT CAUSE for G/H coherence
2. C4 sub-case 1a forward (1 sorry) -- may cascade from #1
3. C4 sub-case 1a backward (1 sorry) -- may cascade from #1

If `g_content_chain_property` is proved, all 9 ChronicleToCountermodel sorries become closable using:
- `limit_forward_G` / `limit_backward_H` (for forward_G/backward_H in FMCS)
- `limit_F_resolution` / `limit_P_resolution` (already sorry-free, for restricted_tc)
- `limit_satisfies_c5_weak` / `limit_satisfies_c5'_weak` (already sorry-free, for restricted_fuc)
- The backward_until_chain pattern from DeterministicFMCS (for restricted_buc)

**Using infrastructure from BOTH paths**: The backward Until/Since proof pattern from the deterministic chain (DeterministicFMCS.lean:341-452) can be adapted for the chronicle. It uses `until_intro`/`since_intro` and induction on distance, requiring only that chain positions are linked by X/Y operators or by g_content/h_content ordering. In the chronicle setting, the analog would use the dense Rat ordering with the chronicle's C5 witnesses providing the induction base.

### Minimum Path to ROADMAP Goal

**1 root sorry to close**: `g_content_chain_property`

This requires modifying the omega-chain to maintain the invariant that g_content(f(x)) subset f(y) for adjacent x < y. The ChronicleConstruction.lean comment (lines 706-742) identifies three approaches and recommends a two-pass approach: (a) insert witness point, (b) propagate g_content to new point.

Once `g_content_chain_property` is closed:
- The 2 C4 sub-case sorries likely cascade (use C3 invariant)
- The 9 ChronicleToCountermodel sorries become engineering work using existing infrastructure
- Total: **1 root sorry + ~11 cascade closures = 12 sorries eliminated**

---

## Mission 4: x_content Analysis

### Definition

`x_content` is defined implicitly through the deterministic chain construction. There is no standalone `def x_content` in the codebase. Instead:

```lean
-- DeterministicChain.lean:49-52
noncomputable def iterate_x_content (M : Set Formula) : Nat -> Set Formula
  | 0 => M
  | n + 1 => x_content (iterate_x_content M n)
```

The `x_content` function itself is referenced via `mem_x_content_iff` simp lemmas, meaning:

**phi in x_content(M) iff X(phi) in M** where X(phi) = bot U phi.

Similarly:
**phi in y_content(M) iff Y(phi) in M** where Y(phi) = bot S phi.

### What x_content preserves from input MCS

Given MCS M, x_content(M) = {phi | (bot U phi) in M}. This means:
- phi in x_content(M) iff there exists a strict next-step witness for phi
- Under discrete semantics (Z), bot U phi at t means phi at t+1 with empty interval (t,t+1)
- Under dense semantics (Q), bot U phi is **unsatisfiable** (no empty open intervals exist)

### What x_content adds

x_content DOES NOT ADD formulas. It EXTRACTS the "next-step content" from M. Specifically:
- If G(phi) in M, then by `G_implies_X` (TemporalDerived), X(phi) = bot U phi in M, so phi in x_content(M)
- If Box(phi) in M, then by `temp_future` + `G_implies_X`, Box(phi) in x_content(M)
- `until_unfold_in_mcs` gives: (phi U psi) in M -> X(psi or (phi AND (phi U psi))) in M, so the disjunction is in x_content(M)

### F(psi) behavior

**If F(psi) in M**:
- F(psi) = neg(G(neg(psi)))
- This does NOT imply X(psi) in M (would need G(psi) in M)
- This does NOT imply F(psi) in x_content(M) (would need X(F(psi)) = bot U F(psi) in M, which needs G(F(psi)) in M, which needs temp_4 applied to F(psi), but temp_4 gives Gp -> GGp, not Fp -> GFp)

**Critical**: F(psi) in M does NOT guarantee psi in x_content^n(M) for any n. This is precisely the "forward F resolution" problem that kills the deterministic chain. The chain can propagate universal content (G) but NOT existential content (F).

### Proof/counterexample for F(psi) in M -> psi in x_content^n(M)

**This is FALSE in general.** Here is the argument:

1. x_content(M) = {phi | bot U phi in M}
2. x_content^2(M) = {phi | bot U phi in x_content(M)} = {phi | bot U (bot U phi) in M}
3. x_content^n(M) = {phi | X^n(phi) in M} where X^n is n-fold application of bot U _

For psi in x_content^n(M), we need X^n(psi) in M. Under discrete semantics, X^n(psi) at t means psi at t+n. But F(psi) at t only means psi at SOME s > t, not necessarily at t+n.

The gap: F(psi) gives an existential witness, but x_content^n requires a specific witness at exactly n steps. Without BX8 (which was removed), there is no axiom forcing the witness to be at any particular distance.

**Under the old reflexive semantics with BX8**: X(alpha) -> alpha was derivable (bot U alpha at t, witness at t, empty guard), so x_content(M) subset M. Combined with F -> G... no, this doesn't help either.

**Conclusion**: The deterministic chain fundamentally cannot resolve F-obligations because x_content is a DETERMINISTIC step (forced by bot U), while F-resolution requires NON-DETERMINISTIC witness finding (Lindenbaum extension). This is why the chronicle construction uses PointInsertion (controlled Lindenbaum) rather than x_content iteration.

---

## Strategic Assessment

### Confidence Levels

| Finding | Confidence |
|---------|-----------|
| Deterministic chain is dead under irreflexive semantics | **95%** - BX8 removal kills XY-roundtrip |
| `g_content_chain_property` is the single root cause for chronicle | **90%** - verified all dependency chains |
| C4 sub-cases cascade from g_content chain property | **75%** - the argument is sketched in comments but not verified |
| Backward Until/Since pattern is reusable | **95%** - `backward_until_chain` is sorry-free in DeterministicFMCS |
| OrderedSeedConsistency is fully reusable | **100%** - sorry-free, imports only Frame + CanonicalChain |
| x_content cannot resolve F-obligations | **99%** - mathematical argument is sound |

### Key Findings Summary

1. **The deterministic chain is dead** -- 3 independent blockers from BX8 removal, forward_F circularity, and until_induction removal. Do not attempt to revive.

2. **g_content_chain_property is THE bottleneck** -- 1 sorry that blocks 12. The omega-chain needs modification to maintain g_content propagation at insertion time.

3. **Significant sorry-free infrastructure exists**:
   - PointInsertion (lemmas 2.4-2.7) -- sorry-free
   - RRelation + rMaximal extension -- sorry-free
   - OrderedSeedConsistency (BX11 + enriched seeds) -- sorry-free
   - g/h duality bridge (`g_content_sub_imp_h_content_sub`) -- sorry-free
   - limit_F/P_resolution via BX12 + C5 -- sorry-free
   - limit_satisfies_c5/c5'_weak -- sorry-free
   - Backward Until/Since chain induction pattern -- sorry-free in DeterministicFMCS

4. **The chronicle-to-countermodel wiring is mostly plumbing** -- ChronicleToCountermodel.lean's 9 sorries are all consequences of the root g_content_chain_property sorry, using infrastructure that is already proved.

5. **x_content is the wrong tool for F-resolution** -- it extracts deterministic next-step content but cannot find existential witnesses. The chronicle's PointInsertion with Lindenbaum extension is the correct mechanism.
