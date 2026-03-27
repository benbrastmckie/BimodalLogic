# Research Report: Task #58 — Seed Consistency Proof Techniques

**Task**: 58 - wire_completeness_to_frame_conditions
**Date**: 2026-03-27
**Mode**: Team Research (4 teammates)
**Session**: sess_1774638161_5c3cd4
**Focus**: Proof-theoretic cut lemma for BRS-containing derivations + alternative approaches

---

## Summary

All 4 teammates converge on a precise diagnosis: the `constrained_successor_seed_restricted_consistent` sorry cannot be closed by any of the four previously-proposed approaches without new proof-theoretic machinery. The fundamental obstacle is that the deduction theorem transforms `L ⊢ ⊥` into `L_rest ⊢ psi.neg`, losing the `⊢ ⊥` conclusion — and no available mechanism recovers it. Two viable paths forward were identified.

---

## Key Findings

### 1. All Four Approaches Hit the Same Wall (ALL teammates agree)

| Approach | Why It Fails | Teammates |
|----------|-------------|-----------|
| Direct substitution (psi → psi ∨ F(psi)) | Derivation substitution invalid in Hilbert systems | A, C |
| Deduction theorem elimination | Gives `L_rest ⊢ psi.neg`, not `L_rest ⊢ ⊥` | A, B, C, D |
| "No contradictory pairs" | FALSE in Hilbert systems — `{A, A→B, ¬B}` derives ⊥ without a contradictory pair | A, C |
| Cut-style transformation | Right structure but requires "hypothesis replacement" lemma | A, B, C, D |

**Root cause**: Every approach requires transforming `L ⊢ ⊥` (where L ⊆ seed, containing BRS elements outside u) into `L' ⊢ ⊥` (where L' ⊆ u). The deduction theorem removes a BRS element psi from L but produces `psi.neg` as conclusion instead of `⊥`. Since `psi ∉ u` and `psi.neg ∈ u`, we cannot derive `psi` from u to feed into the implication.

### 2. The `proof_by_cases_bot` Lemma EXISTS But Cannot Be Applied (Teammate A)

Teammate A discovered that the following lemma IS provable in the system:

```lean
-- If A :: Γ ⊢ ⊥ AND A.neg :: Γ ⊢ ⊥, then Γ ⊢ ⊥
-- Proof: deduction theorem on both branches gives Γ ⊢ A.neg and Γ ⊢ A.neg.neg
-- Then derives_bot_from_phi_neg_phi closes the goal
```

However, applying this to the BRS case requires BOTH branches:
- Branch 1: `psi :: L_rest ⊢ ⊥` — available (from L ⊢ ⊥)
- Branch 2: `psi.neg :: L_rest ⊢ ⊥` — NOT available

In the base case (k=1 BRS element), `psi.neg :: L_u ⊆ u`, so Branch 2 is FALSE (u is consistent). This definitively rules out the `proof_by_cases_bot` approach.

### 3. The WitnessSeed G-Wrapping Trick Does NOT Transfer (Teammate B)

Teammate B identified `WitnessSeed.lean`'s consistency proof as the closest analogue. That proof works by:
1. From `L ⊢ ⊥` where `L ⊆ {psi} ∪ g_content(M)`: deduction gives `L_filt ⊢ psi.neg`
2. G-wrap: `G(L_filt) ⊢ G(psi.neg)` using temporal necessitation
3. Since `G(L_filt) ⊆ M` and `G(psi.neg) = ¬F(psi)`: contradicts `F(psi) ∈ M`

This fails for the full seed because deferralDisjunctions, p_step_blocking, and BRS elements are NOT all from g_content(u) — they lack the G-wrapping structure needed for step 2.

### 4. The Predecessor Seed Avoids This Problem Entirely (Teammate C)

Key structural asymmetry: `constrained_predecessor_seed_restricted ⊆ u` always holds (no predecessor BRS exists). The predecessor consistency proof is trivial. The successor seed is fundamentally harder because BRS elements live OUTSIDE u. This is intrinsic to the bimodal Task Semantics — not a bug in the formalization.

### 5. The BRS Definition Is Correct — No Reformulation Needed (Teammates C, D)

Both teammates confirmed:
- Fix A1 (`Formula.some_future chi.neg ∉ u`) is correctly implemented
- `brs_mutual_exclusion` prevents `{psi, psi.neg}` both in BRS
- `neg_not_in_seed_when_in_brs` is proven and sorry-free
- Removing BRS or adding `chi ∈ u` (Fix A3) would break the bounded-witness termination proof

### 6. Semantic Satisfiability Argument Is Circular (Teammates A, B)

The standard textbook approach (Fitting, Blackburn et al.) proves seed consistency via:
1. Seed is satisfiable (has a model)
2. Satisfiable → consistent (by soundness)

This is circular in our completeness proof: we need the seed to be consistent to BUILD the canonical model (via Lindenbaum), so we cannot appeal to that model to prove consistency.

---

## Viable Paths Forward

### Path A: G-Wrapping on Restricted Seed (adapted from Teammate B + A analysis)

**Idea**: Decompose the consistency proof into two stages:

**Stage 1**: Prove `g_content(u) ∪ BRS(phi, u)` is consistent.
- This is structurally similar to WitnessSeed's case
- For each BRS element psi, F(psi) ∈ u, so G(psi.neg) = ¬F(psi) would contradict F(psi) ∈ u
- Requires handling MULTIPLE BRS elements simultaneously (WitnessSeed handles only ONE witness)
- The single-BRS-element case should work directly via the WitnessSeed pattern

**Stage 2**: Adding `deferralDisjunctions ∪ p_step_blocking_restricted` preserves consistency.
- These are all subsets of u
- Adding subset-of-u elements to a consistent set THAT IS ITSELF a subset of deferralClosure should preserve consistency
- Key lemma needed: "if S is consistent, S ⊆ deferralClosure, and T ⊆ u, then S ∪ T is consistent" — this follows because any derivation from S ∪ T that derives ⊥ would, after applying the deduction theorem to remove the T-elements, give a derivation from S of something, which by DRM closure lands in u, combined with S elements also in u (after G-wrapping), gives a contradiction

**Confidence**: Medium. The multi-BRS case in Stage 1 may require its own induction.

### Path B: Direct Proof via Iterated Deduction + Modus Ponens Chain (Teammate B's approach)

**Idea**: From `L_u ++ [psi_1, ..., psi_k] ⊢ ⊥`, apply deduction theorem k times:
```
L_u ⊢ psi_1 → (psi_2 → ... → (psi_k → ⊥)...)
```

Then construct `L_u ++ [psi_1.neg, ..., psi_k.neg] ⊢ ⊥` by:
1. All of `psi_i.neg ∈ u`, so `L_u ++ [psi_i.neg] ⊆ u`
2. Apply modus ponens chain: `psi_1.neg` does NOT directly match `psi_1 → (...)` — we need `psi_1`, not `psi_1.neg`

**Problem**: This approach ALSO fails at the modus ponens step. `psi_1 → Q` with `psi_1.neg = psi_1 → ⊥` gives `¬psi_1` but we need `psi_1` to apply MP.

**Status**: BLOCKED. Teammate B documented this as failing after detailed analysis.

### Path C: Reformulate to Avoid Proving Seed Consistency Directly

**Idea**: Instead of proving the seed is consistent and THEN applying Lindenbaum, restructure the construction:

1. Start with u (consistent DRM)
2. Use a modified Lindenbaum that enumerates formulas in deferralClosure and greedily adds them while maintaining consistency AND the seed properties (g_content, F-step, P-step, BRS resolution)
3. The resulting set is consistent by construction

This avoids proving seed consistency because the Lindenbaum process STARTS from u (consistent) and never breaks consistency. The challenge is ensuring the resulting MCS contains all required seed formulas.

**Confidence**: Low-Medium. Requires significant restructuring of the chain construction.

---

## Synthesis: Conflicts and Gaps

### Conflicts Resolved

| Issue | Teammate D View | Teammate A/C View | Resolution |
|-------|----------------|-------------------|------------|
| Proof difficulty | "~40 lines with auxiliary lemma" | "Genuinely hard; high risk" | D assumes the cut lemma exists; A/C show it's the hard part |
| "No contradictory pairs" | Can be used as part of argument | Insufficient on its own | Correct: it's necessary but not sufficient |

### Gaps Identified

1. **No teammate found a complete, mechanizable proof path** that avoids all known blockers
2. **The multi-BRS G-wrapping approach (Path A)** has not been fully verified — it's the most promising but untested
3. **No one checked whether `⊥ ∈ deferralClosure phi`** — if true, `drm_closed_under_derivation` could be applied more directly
4. **The `cut_with_proven` lemma** (`if Γ ⊢ A and A :: Γ ⊢ C then Γ ⊢ C`) IS trivially provable — Teammate A noted this. The question is whether we can use it (requires `Γ ⊢ psi`, which contradicts u's consistency)

### Recommended Action

1. **Investigate Path A (G-wrapping on restricted seed)** with highest priority — it leverages existing WitnessSeed infrastructure and has the clearest mathematical structure
2. **Check if `⊥ ∈ deferralClosure phi`** — this is a quick win/fail check
3. **If Path A fails, pursue Path C** (reformulate construction) as a more invasive but architecturally sound alternative
4. **Do NOT pursue**: iterated deduction (Path B, proven to fail), semantic satisfiability (circular), "no contradictory pairs" alone (insufficient)

---

## Approaches Definitively Ruled Out

| Approach | Why Blocked | Reference |
|----------|-------------|-----------|
| Direct substitution psi → psi ∨ F(psi) | Derivation substitution invalid in Hilbert calculus | Teammates A, C |
| Deduction theorem elimination alone | Produces `⊢ psi.neg`, not `⊢ ⊥` at each step | All 4 |
| "No contradictory pairs" as sole argument | FALSE in Hilbert systems | Teammates A, C |
| Semantic satisfiability + soundness | Circular in canonical model construction | Teammates A, B |
| proof_by_cases_bot | Requires both branches; second branch is FALSE | Teammate A |
| Fix A3 (add chi ∈ u to BRS) | Defeats BRS purpose; breaks termination proof | Teammates C, D |
| Iterated deduction + MP chain | psi_i.neg cannot feed into the implication chain | Teammate B |
| `neg_not_in_boundary_resolution_set` | Theorem is mathematically FALSE | Prior research (Report 65) |

---

## Teammate Contributions

| Teammate | Angle | Status | Confidence | Key Contribution |
|----------|-------|--------|------------|------------------|
| A | Cut lemma machinery | completed | high | Found proof_by_cases_bot (provable but inapplicable); catalogued all available proof tools; showed semantic path is correct for textbooks but circular here |
| B | Semantic alternatives | completed | medium | Identified WitnessSeed as closest analogue; showed G-wrapping doesn't transfer; proposed fold-implication approach (also fails); identified drm_closed_under_derivation limitations |
| C | Risk analysis | completed | high | Systematically showed all 4 approaches hit same wall; identified predecessor/successor asymmetry; analyzed 6 edge cases; confirmed Fix A1 handles all |
| D | Critical analysis | completed | high | Confirmed neg_not_in_seed_when_in_brs proven; BRS definition correct; identified concrete cut lemma formulation; verified Task Semantics constraints are non-negotiable |

---

## File References

| File | Lines | Content |
|------|-------|---------|
| SuccChainFMCS.lean | 1408-1425 | `neg_not_in_seed_when_in_brs` (PROVEN) |
| SuccChainFMCS.lean | 1441-1454 | `augmented_seed_consistent` (sorry) |
| SuccChainFMCS.lean | 1481-1756 | `constrained_successor_seed_restricted_consistent` (TARGET sorry) |
| SuccExistence.lean | 284-300 | `boundary_resolution_set` (Fix A1, correct) |
| SuccExistence.lean | 344-352 | `constrained_successor_seed_restricted` definition |
| WitnessSeed.lean | 79-177 | `forward_temporal_witness_seed_consistent` (analogue) |
| MaximalConsistent.lean | 88-89 | `SetConsistent` definition |
| DeductionTheorem.lean | - | Deduction theorem infrastructure |
| Propositional.lean | - | `classical_merge`, `de` (disjunction elimination) |
