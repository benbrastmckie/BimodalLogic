# Research Report: Teammate C - Multi-BRS Induction Strategies

**Task**: 58 - wire_completeness_to_frame_conditions
**Focus**: Induction strategies for multi-BRS element consistency
**Date**: 2026-03-27
**Agent**: math-research-agent

---

## Executive Summary

The naive induction scheme fails because the G-wrapping proof technique requires ALL elements of `L \ {psi}` to come from `g_content(u)` in order to apply `generalized_temporal_k`. When multiple BRS elements are present, deduction theorem iterations produce cross-element implications that exit `deferralClosure`. Two viable induction strategies emerge: (1) simultaneous consistency via G-wrapping structure, and (2) strong induction on non-u elements using `classical_merge`.

---

## Key Findings

### 1. Why Naive Induction Fails (Root Cause Analysis)

The naive approach attempts:
```
Base: g_content(u) ∪ {psi_1} consistent [PROVEN: single_brs_element_with_g_content_consistent]
Step: If g_content(u) ∪ {psi_1, ..., psi_k} consistent, then g_content(u) ∪ {psi_1, ..., psi_{k+1}} consistent
```

**The step fails because:**

1. When proving `g_content(u) ∪ {psi_1, ..., psi_{k+1}}` consistent, suppose `L ⊆ seed` and `L ⊢ ⊥`.

2. If `psi_{k+1} ∈ L`, deduction theorem gives `L \ {psi_{k+1}} ⊢ psi_{k+1}.neg`

3. To apply G-wrapping (generalized_temporal_k), we need `L \ {psi_{k+1}} ⊆ g_content(u)`.

4. **But `L \ {psi_{k+1}}` may contain `psi_1, ..., psi_k`**, which are NOT in `g_content(u)`.

5. The G-wrapping argument requires `G(chi) ∈ u` for each `chi ∈ L'`, which fails for BRS elements `psi_i ∉ g_content(u)`.

**Concrete example:**
- Let `L = [psi_1, psi_2, chi]` where `chi ∈ g_content(u)` and `psi_1, psi_2 ∈ BRS`.
- `L ⊢ ⊥` (hypothetical inconsistency).
- Deduction: `[psi_1, chi] ⊢ psi_2.neg`.
- To G-wrap: need `G([psi_1, chi]) ⊢ G(psi_2.neg)`.
- **Problem**: `G(psi_1)` is NOT in `u` (since `psi_1 ∈ BRS` means `psi_1 ∉ u` by the BRS definition requiring `psi_1 ∉ u` implicitly through maximality).

### 2. BRS Element Independence (False Hope)

**Question**: Are BRS elements "independent" in some proof-theoretic sense?

**Answer**: NO, at least not trivially.

The BRS elements share a common structure:
- Each `psi ∈ BRS` satisfies `F(psi) ∈ u`
- Each `psi.neg ∉ seed` (proven: `neg_not_in_seed_when_in_brs`)

However, a derivation from `g_content(u) ∪ BRS` can use **multiple** BRS elements in a single reasoning chain. There is no pigeonhole-style argument that reduces to a single BRS element because:

```
{psi_1, psi_2, chi} ⊢ ⊥ does NOT imply {psi_1, chi} ⊢ ⊥ or {psi_2, chi} ⊢ ⊥
```

**Example**: `psi_1 = A`, `psi_2 = A → B`, `chi = B.neg` where `chi ∈ g_content(u)`.
- `{A, A → B, B.neg} ⊢ ⊥` via MP + contradiction.
- Neither `{A, B.neg}` nor `{A → B, B.neg}` alone derives `⊥`.

### 3. Strong Induction Hypothesis (Promising Direction)

Instead of proving "`g_content(u) ∪ S` consistent" directly, consider:

**Strong IH**: "For any `L ⊆ g_content(u) ∪ BRS` with `|L ∩ BRS| = k`, if `L ⊢ ⊥`, then there exists `L' ⊆ u` with `L' ⊢ ⊥`."

**Why this might work:**
- Base `k = 0`: `L ⊆ g_content(u) ⊆ u`, contradiction immediate.
- Step `k + 1`: Pick `psi ∈ L ∩ BRS`. By DRM maximality, `psi.neg ∈ u`.

  The key idea: construct `L'' = (L \ {psi}) ∪ {psi.neg}` and show `L'' ⊢ ⊥`.

  Then `|L'' ∩ BRS| = k` (since `psi.neg ∉ BRS` by `brs_mutual_exclusion`).

  By IH, there exists `L''' ⊆ u` with `L''' ⊢ ⊥`. Contradiction.

**The gap**: Showing `(L \ {psi}) ∪ {psi.neg} ⊢ ⊥` from `L ⊢ ⊥`.

This requires a "hypothesis substitution" lemma:
```lean
-- If psi :: Γ ⊢ ⊥ and psi.neg ∈ u (i.e., derivable from u), then Γ ∪ {psi.neg} ⊢ ⊥
```

This is NOT trivially true. From `psi :: Γ ⊢ ⊥`, deduction theorem gives `Γ ⊢ psi.neg`.
This does NOT give `Γ ∪ {psi.neg} ⊢ ⊥` unless there's additional structure.

### 4. `classical_merge` Approach (Key Insight)

The `classical_merge` lemma proves:
```lean
⊢ (P → Q) → ((P.neg → Q) → Q)
```

This enables proof by cases on `P ∨ P.neg`.

**Application to BRS consistency:**

For a single BRS element `psi` in `L`:
- Case 1: `psi ∈ L` gives `L \ {psi} ⊢ psi.neg` via deduction theorem.
- Case 2: We want to show `L_with_psi_neg ⊢ ⊥` where `L_with_psi_neg = (L \ {psi}) ∪ {psi.neg}`.

But `classical_merge` requires BOTH branches to derive the SAME formula Q. In our case:
- Branch 1: `psi ∈ L` leads to `L \ {psi} ⊢ psi.neg`
- Branch 2: `psi.neg ∈ L` leads to `L \ {psi.neg} ⊢ psi` (deduction theorem)

For the consistency proof, we need Q = ⊥, but deduction theorem gives implications, not ⊥.

**The crucial observation**: The `proof_by_cases_bot` pattern IS provable:
```lean
-- If (A :: Γ) ⊢ ⊥ AND (A.neg :: Γ) ⊢ ⊥, then Γ ⊢ ⊥
```

Proof sketch:
1. From `(A :: Γ) ⊢ ⊥`, deduction gives `Γ ⊢ A.neg`.
2. From `(A.neg :: Γ) ⊢ ⊥`, deduction gives `Γ ⊢ A.neg.neg`.
3. Apply `derives_bot_from_phi_neg_phi` to get `Γ ⊢ ⊥`.

**But for BRS**: We have `(psi :: L_rest) ⊢ ⊥` but NOT `(psi.neg :: L_rest) ⊢ ⊥`.

In fact, `(psi.neg :: L_rest) ⊢ ⊥` is FALSE when `L_rest ⊆ u` because:
- `psi.neg ∈ u` (by DRM maximality)
- `L_rest ⊆ u`
- So `{psi.neg} ∪ L_rest ⊆ u`, consistent by u's consistency.

This definitively rules out `proof_by_cases_bot` for the BRS case.

### 5. Simultaneous G-Wrapping (Most Promising)

The WitnessSeed proof works because `{psi} ∪ g_content(u)` has a special structure: ALL non-psi elements are from `g_content`, enabling G-wrapping.

**Key insight**: The full seed `g_content(u) ∪ BRS` might STILL admit G-wrapping if we handle ALL BRS elements simultaneously.

**Proposed scheme:**

Given `L ⊆ g_content(u) ∪ BRS` with `L ⊢ ⊥`:

1. Partition `L = L_gc ∪ L_brs` where `L_gc ⊆ g_content(u)` and `L_brs ⊆ BRS`.

2. Apply deduction theorem `|L_brs|` times to get:
   ```
   L_gc ⊢ psi_1 → (psi_2 → ... → (psi_k → ⊥)...)
   ```

3. G-wrap the entire implication:
   ```
   G(L_gc) ⊢ G(psi_1 → (psi_2 → ... → (psi_k → ⊥)...))
   ```

4. Use temporal K distribution `k` times:
   ```
   G(L_gc) ⊢ G(psi_1) → (G(psi_2) → ... → (G(psi_k) → G(⊥))...)
   ```

5. **The critical question**: Can we derive `G(⊥)` from `u`?

   - `G(L_gc) ⊆ u` (since `L_gc ⊆ g_content(u)` means `G(chi) ∈ u` for each `chi`).
   - For each `psi_i ∈ BRS`, `F(psi_i) ∈ u`, so `G(psi_i.neg) ∉ u` (by MCS consistency with `F = ¬G¬`).
   - But we need `G(psi_i) ∈ u`, NOT `G(psi_i.neg) ∉ u`.

6. **Gap**: `F(psi) ∈ u` does NOT imply `G(psi) ∈ u`. They are independent.

   - `F(psi) = ¬G(¬psi)` means `G(¬psi) ∉ u`.
   - But `G(psi) ∈ u` is a separate claim.
   - By negation completeness: either `G(psi) ∈ u` or `G(psi).neg = ¬G(psi) = F(¬psi) ∈ u`.

**Conclusion**: Simultaneous G-wrapping FAILS at step 5.

### 6. Order Independence (Does Not Help)

**Question**: Can we choose a "good" order for adding BRS elements?

**Answer**: Order doesn't matter for the fundamental obstruction.

The problem is NOT about which BRS element to remove first. The problem is that ANY removal via deduction theorem leaves OTHER BRS elements in the remaining list, preventing G-wrapping.

The obstruction is structural, not ordering-dependent.

---

## Proposed Induction Scheme (If Any)

**No complete scheme found.**

The closest viable approach is the **strong induction on non-u elements** (Finding 3), but it requires a "hypothesis substitution" lemma that does not exist.

**Alternative path**: Reformulate the construction to avoid proving seed consistency directly. Instead of:
1. Prove seed consistent
2. Apply Lindenbaum to get MCS

Consider:
1. Start with `u` (consistent)
2. Build MCS incrementally by adding formulas while maintaining consistency AND seed properties

This avoids proving seed consistency a priori because the Lindenbaum process never breaks consistency.

---

## Detailed Analysis: The Deduction Theorem Cross-Element Problem

### Setup

Let `BRS = {psi_1, psi_2}` and `L = [psi_1, psi_2, chi_1, chi_2]` where `chi_i ∈ g_content(u)`.

Suppose `L ⊢ ⊥`.

### Attempt 1: Remove `psi_2` first

Deduction theorem: `[psi_1, chi_1, chi_2] ⊢ psi_2.neg`

To G-wrap: need `G([psi_1, chi_1, chi_2]) ⊢ G(psi_2.neg)`

**Problem**: `G(psi_1) ∈ u` is NOT guaranteed. Since `psi_1 ∈ BRS`:
- We know `F(psi_1) ∈ u`.
- This means `G(psi_1.neg) ∉ u`.
- But `G(psi_1)` could be either in or out of `u`.

If `G(psi_1) ∉ u`, we cannot derive `G(psi_2.neg)` from `u`, blocking the contradiction.

### Attempt 2: Remove both simultaneously

Apply deduction theorem twice:
`[chi_1, chi_2] ⊢ psi_1 → (psi_2 → ⊥)`

G-wrap: `G([chi_1, chi_2]) ⊢ G(psi_1 → (psi_2 → ⊥))`

Distribute K: `G([chi_1, chi_2]) ⊢ G(psi_1) → G(psi_2 → ⊥)`

Distribute K again: `G([chi_1, chi_2]) ⊢ G(psi_1) → (G(psi_2) → G(⊥))`

Since `G(chi_i) ∈ u`, we have: `u ⊢ G(psi_1) → (G(psi_2) → G(⊥))`

**To get contradiction**: Need `G(psi_1), G(psi_2) ∈ u` to derive `G(⊥) ∈ u`.

But `G(psi_i) ∈ u` is NOT guaranteed by `F(psi_i) ∈ u`.

**This is the fundamental gap.**

---

## Confidence Level

| Finding | Confidence |
|---------|------------|
| Naive induction fails | **High** - Concrete counterexample structure identified |
| BRS independence false | **High** - Explicit counterexample given |
| Strong IH gap identified | **High** - Missing hypothesis substitution lemma |
| classical_merge blocked | **High** - Both branches requirement fails |
| Simultaneous G-wrapping blocked | **High** - G(psi) ∈ u not derivable from F(psi) ∈ u |
| Order independence | **High** - Structural, not ordering issue |

**Overall confidence that no simple induction scheme exists**: **HIGH**

The problem appears to require either:
1. A new proof-theoretic lemma (hypothesis substitution under G-wrapping constraints)
2. A reformulation that avoids proving seed consistency directly
3. Additional structure in the BRS definition that provides G-wrapping resources

---

## Recommendations

1. **Investigate whether `G(psi) ∈ u` is ACTUALLY required** — perhaps a weaker condition suffices for the canonical model construction.

2. **Consider alternative seed formulations** that include `psi ∨ F(psi)` instead of bare `psi` for BRS elements. This might provide the G-wrapping resources.

3. **Explore the reformulated Lindenbaum approach** (Path C from Report 63) — build the MCS incrementally while maintaining both consistency and seed properties.

4. **Do NOT pursue**: naive induction, independent BRS claims, proof_by_cases_bot, order-sensitive schemes.

---

## File References

| File | Lines | Content |
|------|-------|---------|
| SuccChainFMCS.lean | 1444-1590 | `single_brs_element_with_g_content_consistent` (Phase 1, PROVEN) |
| SuccChainFMCS.lean | 1646-1921 | `constrained_successor_seed_restricted_consistent` (TARGET sorry) |
| WitnessSeed.lean | 79-177 | `forward_temporal_witness_seed_consistent` (analogue for single witness) |
| SuccExistence.lean | 284-300 | `boundary_resolution_set` definition (BRS) |
| Propositional.lean | 785-850 | `classical_merge` definition |
| Propositional.lean | 1614-1670 | `de` (disjunction elimination) |
