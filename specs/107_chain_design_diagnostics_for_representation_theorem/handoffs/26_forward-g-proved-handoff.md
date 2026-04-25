# Handoff: Task 107 — forward_G Proved, Non-Domain Extension Remains

**Date**: 2026-04-25
**Session**: sess_1777144238_76db8b
**Branch**: irr_until
**Build**: passes (1055 jobs)
**Sorry count**: 11 across 3 Chronicle files (down from 13)

---

## What Was Done (This Session)

### Round 25 Research: C4 Argument Swap Identified
- Burgess's U(α,β): α=EVENT, β=GUARD. Codebase's untl(γ,δ): γ=GUARD, δ=EVENT.
- C4 was checking GUARD at f(y) and negating EVENT — should check EVENT and negate GUARD.
- Fixed: C4 now checks δ (EVENT) at f(y), produces γ.neg (GUARD neg) at f(z).

### Round 26 Research: Adjacent Restriction Identified
- Burgess C4a says `x < y` — no adjacency requirement.
- Codebase had `Adjacent χ.dom x y` — vacuously true at dense limit.
- Fixed: C4/C4' now use `x ∈ χ.dom → y ∈ χ.dom → x < y`.

### Plan v11 Phase 1: C4 Argument Swap + g_ordered Deletion
- C4/C4' arguments swapped. g_ordered/h_ordered deleted from ChronicleInvariant.

### Plan v12 Phase 1: Adjacent Restriction Removed
- C4/C4' definitions changed from `Adjacent` to `x < y`.
- C4Counterexample/C4'Counterexample structures updated.
- Omega chain enumeration processes ALL pairs.

### Plan v12 Phase 4: forward_G/backward_H Proved Sorry-Free
- `limit_forward_G` (ChronicleConstruction.lean:979-1039): Full proof via generalized C4 + C0.
  - G(φ) ∈ f(x) → G(φ.neg.neg) ∈ f(x) [via DNI + temporal necessitation]
  - → F(φ.neg) ∉ f(x) [MCS consistency]
  - → (⊤ U φ.neg) ∉ f(x) [via BX10: Until implies F]
  - → neg(⊤ U φ.neg) ∈ f(x) [MCS negation completeness]
  - → ∃z: ⊤.neg ∈ f(z) [by generalized C4 with δ=φ.neg at f(y)]
  - → ⊤ ∈ f(z) and ⊤.neg ∈ f(z) — contradiction with MCS consistency
- `limit_backward_H` (ChronicleConstruction.lean:1048+): Mirror using C4' and past axioms.
- Both proved sorry-free. Build passes.

---

## What Remains (11 Sorry Sites)

| File | Line | What | Blocker |
|------|------|------|---------|
| CounterexampleElimination.lean | 319 | C4 hard case | Lemma 2.6 full |
| CounterexampleElimination.lean | 383 | C4' hard case | Lemma 2.6 full |
| PointInsertion.lean | 762 | lemma_2_6_full | Seed construction |
| ChronicleToCountermodel.lean | 195 | chronicle_fmcs.forward_G | Non-domain extension |
| ChronicleToCountermodel.lean | 200 | chronicle_fmcs.backward_H | Non-domain extension |
| ChronicleToCountermodel.lean | 372 | restricted_tc forward | Non-domain extension |
| ChronicleToCountermodel.lean | 375 | restricted_tc backward | Non-domain extension |
| ChronicleToCountermodel.lean | 394 | restricted_buc Until | Until truth lemma wiring |
| ChronicleToCountermodel.lean | 397 | restricted_buc Since | Since truth lemma wiring |
| ChronicleToCountermodel.lean | 426 | restricted_fuc Until | C5 witness transfer |
| ChronicleToCountermodel.lean | 429 | restricted_fuc Since | C5' witness transfer |

### Dependency Graph

```
Lemma 2.6 full (762)
  → C4 hard case (319), C4' hard case (383)
    → omega chain C4 elimination complete
      → (contributes to limit C4, already proved for forward_G)

Non-domain extension fix
  → chronicle_fmcs.forward_G (195), backward_H (200)
  → restricted_tc (372, 375)

Until/Since truth lemma wiring
  → restricted_buc (394, 397)
  → restricted_fuc (426, 429)
```

---

## Two Independent Workstreams

### Workstream A: Non-Domain Extension (8 sorry sites)

`extended_limit_f` maps non-domain rationals to the root MCS A. Under strict semantics, G(φ) ∈ A does NOT imply φ ∈ A (no T axiom). This makes `chronicle_fmcs.forward_G` unprovable at non-domain points.

**Validated solution**: Cantor isomorphism (report 24, Option B).
- `Order.iso_of_countable_dense` from Mathlib produces `limit_dom ≃o ℚ`
- Prerequisites (Countable, DenselyOrdered, NoMinOrder, NoMaxOrder, Nonempty) all provable
- Define `cantor_f(q) = limit_f(iso.symm(q).val)` — every rational is a domain point
- forward_G reduces purely to `limit_forward_G` (now sorry-free)
- Estimated: 8-10 hours

### Workstream B: Lemma 2.6 + C4 Hard Cases (3 sorry sites)

The C4 hard case (δ ∈ both f(x) and f(y)) requires the full Lemma 2.6 seed construction. This is independent of the non-domain extension.

- Burgess's Lemma 2.6 seed: {neg γ} ∪ B ∪ r-relation formulas
- Consistency from R3Maximality (r3Maximal_neg_of_not_mem is sorry-free)
- Estimated: 5-8 hours

**These two workstreams are independent and can be parallelized.**

---

## What's Sorry-Free (Reusable)

All of the following are proved without sorry:
- **limit_forward_G** (ChronicleConstruction.lean:979) — THE former root blocker
- **limit_backward_H** (ChronicleConstruction.lean:1048) — dual
- **limit_satisfies_c4** / **limit_satisfies_c4'** — generalized C4 at limit
- r3Relation, R3Maximal, C3, c3_interval_subset_point/left/right
- Duality: g_content_sub_imp_h_content_sub, h_content_sub_imp_g_content_sub
- lemma_2_5b, lemma_2_5b_past (transitivity)
- burgessR3_absorption via BX6
- r3Maximal_neg_of_not_mem (negation completeness)
- forward_temporal_witness_seed_consistent, dcs_neg_union_consistent
- singleton_invariant (4 fields: hc0, hc1, hc2', hc3)
- C5/C5' easy cases, density elimination
- limit_dom_dense, limit_c0, limit_c1
- box_stable_in_chronicle_fmcs (uses forward_G — correct once FMCS forward_G closes)

---

## Key Insight Log

| Round | Finding | Impact |
|-------|---------|--------|
| 25 | C4 argument swap (EVENT/GUARD reversed) | Fixed. forward_G argument now produces ⊥ not φ.neg.neg |
| 26 | C4 Adjacent restriction (Burgess uses ALL pairs) | Fixed. Generalized C4 at limit. forward_G proved. |
| 24 | Cantor isomorphism for non-domain extension | Validated. Next implementation target. |
| 24 | Two-sided seeds have fatal consistency gap | Abandoned. g_content(f(x)) ∪ f(x) not consistent under strict semantics. |
| 25 | Burgess uses strict semantics (not reflexive) | Confirmed. No reflexive/strict adaptation needed. |
