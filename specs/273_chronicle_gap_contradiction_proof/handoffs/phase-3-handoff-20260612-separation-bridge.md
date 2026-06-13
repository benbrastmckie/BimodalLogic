# Phase 3 Handoff: Separation Bridge Attempt

**Date**: 2026-06-12
**Session**: sess_1781317454_8ea0c4
**Phase**: 3 REVISED (Expressive Completeness Bridge)
**Status**: PARTIAL (1 of 4 tasks completed)

## What Was Accomplished

### 1. GHR94 Lemma 10.2.2 on Prior Structures (SeparationBridge.lean)

Created `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/SeparationBridge.lean` with two
sorry-free theorems:

- `neg_until_equiv_prior`: On Prior-UZ structures, ¬U(A,B) ↔ G(¬A) ∨ U(¬A ∧ ¬B, ¬A)
- `neg_since_equiv_prior`: On Prior-SZ structures, ¬S(A,B) ↔ H(¬A) ∨ S(¬A ∧ ¬B, ¬A)

These establish that the GHR94 elimination equivalences for integer time also hold on
Prior structures. The backward direction uses Prior-UZ/SZ (first/last occurrence property)
in place of integer discreteness.

**Build status**: Clean, 0 sorries, axioms: propext, Classical.choice, Quot.sound.

### 2. Deep Analysis of the Composition Lemma Blocker

Thorough analysis confirmed that the root blocker (`nf_2var_exist_formula_prior` sorry at
NfCharFormula.lean:572) cannot be bypassed by:

1. **Direct bridge from `US_expressively_complete_over_Z`**: The Z-based result uses
   `IntStructureFromSig` with carrier = Z. Prior structures have arbitrary carriers.
   The formula A from Z uses integer-specific separation (Lemma 10.2.2 negation
   equivalences). While these equivalences DO hold on Prior structures (proved above),
   the full transfer requires showing EVERY step of the expressiveness construction
   preserves Prior-structure correctness, which is effectively reproving Theorem 9.3.1.

2. **Modified formula approach**: Using a different formula A for `nf_2var_exist_formula_prior`
   that encodes more 2-var information. For k > 0, the 2-var NF's quantifier part involves
   depth-(k-1) 3-var NFs, which require the composition lemma to reconstruct from 2-var
   projections. No formula choice avoids this mathematical dependency.

3. **NF-bypassing approach**: Proving `kamp_prior_expressive_completeness` directly without
   going through NF characterization. This is circular because the theorem's proof structure
   requires NF decomposition (via `doets_lemma_1_1` + `nf_exists_unique`).

## Precise Blocker Description

**Root cause**: Feferman-Vaught composition lemma for NormalForms at depth >= 1 over
discrete linear orders.

**Lean location**: `nf_3var_from_1var_nfs` in NfComposition.lean (2 sorries at lines 113, 115).

**Mathematical statement**: Given three points x, y, z in a linear order with known
depth-k 1-var NFs, determine the depth-k 3-var NF of (x, y, z). Specifically:
witness transfer -- if a depth-(k-1) 4-var NF is realized at (w, x, y, z), reconstruct
it from the 2-var NF projections at (w,x), (w,y), (w,z).

**Why it matters**: The backward direction of `nf_2var_exist_formula_prior` needs to
reconstruct a depth-k 2-var NF from a depth-k 1-var NF. The quantifier part of the
2-var NF involves depth-(k-1) 3-var NFs, which requires depth-(k-1) composition.

**At depth 0**: Composition is trivial (purely atomic -- determined by predicate/order
assignments which are local). This is why P2(0) is sorry-free in `master_induction`.

**At depth >= 1**: Composition requires the Feferman-Vaught lemma. Five attempts have
failed (documented in NfComposition.lean).

## What Would Actually Work

### Option A: Prove GHR94 Theorem 9.3.1 directly on Prior structures

Reimplement the proof of `separation_implies_expressiveness` (currently in
ExpressiveCompleteness/Theorem.lean) to work on Prior structures instead of Z. This requires:

1. Showing that `q_exists` works on Prior structures (likely true -- P ∨ A ∨ F captures ∃z)
2. Showing that the atom elimination step (using separation) works on Prior structures
3. The separation theorem itself -- would need to prove separation on Prior structures,
   or show the Z-separation result transfers

Estimated effort: 8-12 hours. This is the cleanest mathematical path.

### Option B: Prove the composition lemma at depth 0

Since depth-0 composition is trivial (purely atomic), prove `nf_3var_from_1var_nfs` for
k=0 only. This would give:
- P2(1) sorry-free
- P1(2) sorry-free
- But P2(k) for k >= 2 still sorry

This doesn't close the general case but advances the induction base.
Estimated effort: 2-4 hours.

### Option C: Prove separation on Prior structures

Show that every {U,S}-formula is separable on Prior structures (not just on Z).
The elimination equivalences (Lemma 10.2.2) are already proved in SeparationBridge.lean.
The remaining work is showing the full hierarchical induction (junction depth) works
on Prior structures.

Estimated effort: 10-16 hours (similar to the existing Separation/ module).

## Sorry Inventory

| # | File | Line | Statement | Status | Blocker |
|---|------|------|-----------|--------|---------|
| 1 | NfCharFormula.lean | 572 | nf_2var_exist_formula_prior | OPEN | Composition lemma |
| 2 | NegationClosure.lean | 1379 | nf_exist_formula_nested_backward | OPEN | Composition lemma |
| 3 | NfComposition.lean | 113 | nf_3var_from_1var_nfs (witness) | OPEN | Core math blocker |
| 4 | NfComposition.lean | 115 | nf_3var_from_1var_nfs (core) | OPEN | Core math blocker |
| 5 | VecEADecomposition.lean | 285 | neg_bracket_syn_iff | QUARANTINE | Dead code |

## Immediate Next Action

Research Option A (GHR94 Theorem 9.3.1 on Prior structures) in detail. Specifically:
1. Can `q_exists` be made to work on arbitrary linear orders (not just Z)?
2. Does the atom elimination step (the separation substitution trick) work on Prior structures?
3. Is there a way to reuse the existing Z-separation without re-proving it on Prior structures?

If Option A is viable, the next dispatch should implement it. If not, fall back to Option B
(depth-0 composition) as incremental progress.
