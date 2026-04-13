# Research Report: Task #93 — Round 7

**Task**: 93 - Close TaskModel embedding sorry (sole remaining active-path sorry)
**Date**: 2026-04-13
**Mode**: Team Research (4 teammates)

## Summary

This round performed deep analysis of the forward_F blocker and proposed approaches. A critical consistency gap was discovered in the leading proposed fix ("doubly-enriched resolving seed"), invalidating it as a direct solution. The forward_F problem is confirmed as genuinely hard within the scheduling chain architecture. Two secondary findings are positive: (1) `G_neg_kills_until` IS provable without the missing Until Induction axiom, and (2) the BX11 linearity axiom provides a partial mechanism for F-formula compatibility that may yield a restricted forward_F proof.

## Key Findings

### 1. The f_carry Gap (Confirmed by All 4 Teammates)

The scheduling chain's `fwd_succ` has two branches:
- **Resolving** (when `F(ψ) ∈ M`): seed = `{ψ} ∪ g_content(M)` — f_carry ABSENT
- **Non-resolving**: seed = `g_content(M) ∪ f_carry(M)` — f_carry present

At resolving steps for formula χ ≠ ψ, `F(ψ)` is NOT in the resolving seed `{χ} ∪ g_content(M)`. The Lindenbaum extension may choose `¬F(ψ) = G(¬ψ)`, permanently losing `F(ψ)` from the chain. The existing `f_carry` mechanism only preserves F-formulas through non-resolving steps.

### 2. CRITICAL: Doubly-Enriched Resolving Seed Has a Consistency Gap

Teammates A, C, and D converged on adding f_carry(M) to the resolving seed: `{ψ} ∪ g_content(M) ∪ f_carry(M)`. Teammate C claimed this is consistent because it's a subset of `{ψ} ∪ M`, and Teammate D concurred.

**This claim is WRONG.** `{ψ} ∪ M` is inconsistent when `ψ ∉ M` (since `¬ψ ∈ M` by MCS completeness). The existing `forward_temporal_witness_seed_consistent` proves `{ψ} ∪ g_content(M)` consistent via a specialized **generalized temporal K argument** — NOT by subset-of-M reasoning. The temporal K argument lifts derivations using G-distribution: from `L ⊢ ¬ψ` where all elements of L have G-wrapped versions in M, derive `G(¬ψ) ∈ M`, contradicting `F(ψ) ∈ M`. This mechanism **does not extend** to f_carry elements because `F(χ) ∈ M` does NOT imply `G(F(χ)) ∈ M`.

**Concrete counterexample**: Let M contain `F(G(¬χ))` and `F(χ)` (compatible: χ happens then stops). Resolving ψ = G(¬χ), the enriched seed contains `{G(¬χ)} ∪ g_content(M) ∪ f_carry(M)`. Since `F(χ) ∈ f_carry(M)` and `G(¬χ) = ¬F(χ)`, the seed contains both `¬F(χ)` and `F(χ)` — **inconsistent**.

Teammate A correctly flagged this gap (lines 55-67 of their report). This is the same category of error as Plan 06's `until_neg_carry`: assuming elements can be safely added to seeds without verifying the resulting set remains consistent.

### 3. Deterministic Chain Is Fundamentally Broken for BX (Confirmed by All)

The deterministic chain (Boneyard) requires `x_det`, `y_det`, `x_k_dist`, `y_k_dist` — discrete-only axioms genuinely removed from BX (which targets all linear orders, not just discrete). These cannot be derived. The `x_content_mcs` theorem (x_content of MCS is MCS) collapses without them.

**Note**: `temp_4` (G → GG) IS in BX despite anachronistic Boneyard comments saying "removed" (Teammate C finding, confirmed).

### 4. G_neg_kills_until IS Provable Without Until Induction (New Finding)

The FiniteDeferral.lean code at line 325 uses `sorry /- until_induction removed in BX -/` for `G_neg_kills_until`. However, the theorem has a trivial proof NOT requiring Until Induction:

1. Assume `G(¬ψ) ∈ chain(t)` and `(⊤ U ψ) ∈ chain(t)`
2. By BX10: `(⊤ U ψ) → F(ψ)`, so `F(ψ) ∈ chain(t)`
3. By temporal duality: `G(¬ψ) = ¬F(ψ)`, so `¬F(ψ) ∈ chain(t)`
4. Contradiction with `F(ψ) ∈ chain(t)` (MCS consistency)

This uses only BX10 + temporal duality (definitional in BX). The 170-line proof in FiniteDeferral.lean can be replaced with ~10 lines. This unblocks the FiniteDeferral infrastructure's `G_neg_kills_until` lemma.

### 5. FiniteDeferral Step 5 Remains Hard

Even with `G_neg_kills_until` available, the FiniteDeferral argument for forward_F has a remaining gap: deriving `G(¬ψ) ∈ chain(t)` from "restricted theories cycle." Restricted theory cycling (pigeonhole) shows two positions have the same deferralClosure signature, but:
- The schedule is NOT periodic (Cantor pairing), so restricted theory cycling does NOT imply full chain cycling
- Deriving G(¬ψ) from "¬ψ at all positions > t" requires backward G reasoning, which needs forward_F (circular)

### 6. BX11 Linearity Provides Partial F-Formula Compatibility

BX11: `F(φ) ∧ F(ψ) → F(φ ∧ ψ) ∨ F(φ ∧ F(ψ)) ∨ F(F(φ) ∧ ψ)`. When the middle disjunct `F(ψ ∧ F(χ)) ∈ M` holds, the generalized temporal K argument CAN be adapted to prove `{ψ, F(χ)} ∪ g_content(M)` consistent (using `ψ ∧ F(χ)` as the resolved formula). This doesn't hold for all disjuncts, but provides a case analysis that could work for a linearity-aware chain construction.

### 7. Backward Until Is a Separate Open Problem

`bx_bfmcs_restricted_buc` (sorry at line 621) requires the step transfer property: `(φ U ψ) ∈ chain(r+1) ∧ φ ∈ chain(r) → (φ U ψ) ∈ chain(r)`. The scheduling chain has NO X-operator property, so the deterministic chain's backward Until proof (which uses `x_mem_chain_general` via `until_intro`) cannot be ported. This is independent of forward_F.

Teammate D proposed a "u_carry" mechanism: carry Until formulas from `subformulaClosure(root)` in the seed. This has the SAME consistency issue as f_carry enrichment — adding `(φ U ψ)` to a resolving seed could conflict with the resolving formula.

## Synthesis

### Conflicts Resolved

| Conflict | Teammate A | Teammates C, D | Resolution |
|----------|-----------|----------------|------------|
| Enriched seed consistency | Flagged gap (lines 55-67) | Claimed consistent (HIGH confidence) | **A is correct**: counterexample ψ=G(¬χ), F(χ)∈f_carry |
| f_carry as solution | "Plausible but needs new proof" | "THE fix, HIGH confidence" | **Neither**: not just unproven, but proven INCONSISTENT in some cases |

### Gaps Identified

1. **No known consistent seed enrichment** that preserves ALL F-formulas through resolving steps
2. **FiniteDeferral Step 5**: restricted theory cycling → G(¬ψ) derivation (backward G circularity)
3. **Backward Until step transfer**: no mechanism in the scheduling chain
4. **BX11 case analysis**: only covers one of three disjuncts; the other two don't yield F-formula compatibility

### Recommendations

**Immediate (high confidence, no new math needed):**
- Fix `G_neg_kills_until` in FiniteDeferral.lean with the simple BX10 + duality proof (~10 lines replacing 170)

**Short-term investigation needed:**
- **BX11-based restricted forward_F**: For each pair (F(ψ), F(χ)), BX11 gives three cases. In `deferralClosure(root)` (finite), we can analyze all pairs. If Case 2 (`F(ψ ∧ F(χ)) ∈ M`) holds for the relevant pairs, a selective seed enrichment is consistent. This requires a new chain construction parameterized by `root` that uses linearity case analysis.
- **Alternative: FiniteDeferral with scheduling-aware cycle argument**: Instead of restricted theory cycling, argue that the schedule's surjectivity + F-formula persistence through NON-resolving steps gives enough structure to eventually resolve each F-formula. The key lemma: if `F(ψ) ∈ chain(t)`, then either ψ appears at some `chain(s)` for `s > t`, or `F(ψ)` is lost at some resolving step `k` where `schedule(k) = χ` and `F(χ) ∈ chain(k)` — but then we can trace the RESOLVING formula χ and argue about ITS resolution using the same structure.

**Long-term (high confidence but high effort):**
- **Quasimodel approach**: Build explicit witness sets rather than incremental chain. Standard method in temporal logic literature. Avoids the forward_F circularity entirely. Estimated ~500-1000 lines of new infrastructure.

## Teammate Contributions

| Teammate | Angle | Status | Key Finding | Confidence |
|----------|-------|--------|-------------|------------|
| A | Primary/forward_F | completed | Two independent blockers (f_carry gap + Until Induction); correctly flagged seed consistency gap | high |
| B | Alternatives | completed | Options A/B/C blocked; FiniteDeferral Steps 1-4 proved; recommends quasimodel | high (on facts) |
| C | Critic | completed | Validated approaches 1-3 flaws; **ERROR**: claimed enriched seed consistent (HIGH confidence) | mixed |
| D | Horizons | completed | Doubly-enriched seed approach; u_carry for Until; minimality for forward Until guard | medium |

## References

- `Theories/Bimodal/Metalogic/BXCanonical/CanonicalModel.lean` — Active chain with 6 sorries
- `Theories/Bimodal/Metalogic/Bundle/WitnessSeed.lean` — Temporal K consistency proof
- `Theories/Bimodal/Boneyard/ChainCompleteness/Algebraic/FiniteDeferral.lean` — Steps 1-4 of deferral argument
- `Theories/Bimodal/Boneyard/ChainCompleteness/Algebraic/DeterministicFMCS.lean` — Sorry-free backward Until (but blocked by removed axioms)
- `Theories/Bimodal/ProofSystem/Axioms.lean` — BX axiom inventory (37 constructors, no Until Induction, no X/Y operators)
