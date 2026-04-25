# Research Report: Task #107 — Non-Domain Extension + Lemma 2.6 Resolution

**Task**: 107 - Burgess chronicle construction for BX representation theorem
**Date**: 2026-04-25
**Mode**: Team Research (4 teammates, Opus)
**Session**: sess_1777146648_ff8ffd

## Summary

Two independent workstreams remain: (A) non-domain extension (8 sorry sites), (B) Lemma 2.6 + C4 hard cases (3 sorry sites). All four teammates converge: **Cantor isomorphism is the correct and lowest-effort solution for workstream A** (8-10 hours). Workstream B has a complication: **Burgess's Lemma 2.6 proof uses axiom A4a, which is not sound under strict semantics** — a replacement proof using BX5/BX6/BX7 is needed.

## Key Findings

### 1. Cantor Isomorphism Is the Correct Path (Teammates A + D — UNANIMOUS)

**What it solves**: All 8 ChronicleToCountermodel sorry sites share a root cause: the BFMCS coherence conditions quantify over ALL rationals, but the chronicle only provides guarantees at domain points. `extended_limit_f` assigns root MCS A to non-domain points, and G(φ) ∈ A ↛ φ ∈ A under strict semantics.

**The fix**: `Order.iso_of_countable_dense` from Mathlib maps `limit_dom ≃o ℚ`, making every rational a domain point. Then `cantor_f(q) = limit_f(iso.symm(q).val)`.

**Prerequisites (all provable from sorry-free infrastructure)**:
- LinearOrder: automatic from ℚ subtype
- Countable: countable union of Finsets
- DenselyOrdered: from sorry-free `limit_dom_dense`
- NoMinOrder/NoMaxOrder: from BX seriality + `limit_P/F_resolution`
- Nonempty: from `zero_mem_limit_dom`

**Shifting works**: The iso is order-preserving but not additive — and that's fine. `cantor_fmcs.mcs(t - s) = limit_f(iso.symm(t - s))`. Subtraction happens in ℚ (AddCommGroup), iso.symm preserves order, forward_G transfers.

**No viable alternative**: limit_dom has no AddCommGroup (not closed under +). The BFMCS framework requires AddCommGroup D. Cantor iso is the necessary bridge.

**Estimated effort**: 8-10 hours.

### 2. ChronicleToCountermodel Sorry Sites: Individual Analysis (Teammate C — HIGH)

The 8 sorry sites break into 3 categories:

| Category | Sites | With Cantor Iso |
|----------|-------|-----------------|
| forward_G/backward_H at non-domain | 195, 200 | **Trivially closable** — all points are domain |
| restricted_tc (F/P witness) | 372, 375 | **Closable** — `limit_F/P_resolution` applies everywhere |
| restricted_buc (Until completeness) | 394, 397 | **Needs truth lemma backward direction** |
| restricted_fuc (Until soundness) | 426, 429 | **Needs C5 witness transfer + C3** |

After Cantor iso, the `restricted_buc` and `restricted_fuc` sorry sites become pure truth-lemma-level arguments over domain points. These use C3 (interval containment), C4 (generalized, now proved), and C5 (witness existence) — all available in the limit.

### 3. Lemma 2.6 Uses A4a — Not Sound Under Strict Semantics (Teammate B — CRITICAL)

Burgess's Lemma 2.6 consistency proof crucially uses:
- **A4a**: `U(p,q) ∧ ¬U(p,r) → U(q ∧ ¬r, q)` — a "witness splitting" axiom
- **A3a**: `p ∧ U(q,r) → U(q ∧ S(p,r), r)` — a "connectedness" axiom

Both A3a and A4a are **not sound under strict (irreflexive) semantics** (documented in PointInsertion.lean:16-22). The codebase replaces them with BX4 (connect_future) + BX5 (self_accum_until) + BX6 (absorb_until) + BX7 (linear_until).

**Impact**: The Lemma 2.6 seed consistency argument must be reproved using BX axioms instead of A3a/A4a. This is a genuine mathematical challenge — not just a translation exercise.

**Partial mitigation**: `r3Maximal_neg_of_not_mem` (sorry-free) gives δ.neg ∈ B when δ ∉ B, and `dcs_neg_union_consistent` (sorry-free) gives `{neg δ} ∪ B` is consistent. The gap is extending this to the FULL Lemma 2.6 seed with r-relation formulas.

### 4. C4 Hard Cases Depend on Lemma 2.6 (Teammate B — HIGH)

The 2 C4 hard case sorry sites (lines 319, 383) need Lemma 2.6 to produce a fresh MCS D with γ.neg between the endpoints. The `eliminate_C4_counterexample` function signature also needs extending to include C2' (R3Maximal for the interval).

### 5. No Alternative Architecture Is Warranted (Teammate D — HIGH)

- **Venema 1993**: "Completeness via completeness" technique — inapplicable (assumes base completeness as black box)
- **Verbrugge 2004**: Step-by-step method — architecturally equivalent to what the chronicle already does
- **Generalize FMCS to partial domains**: 15-25 hours across 10+ files — not worth it
- **Current architecture is correct**: Cantor iso is the lowest-effort bridge

## Synthesis

### Two Independent Workstreams

**Workstream A: Cantor Isomorphism (8 sorry sites, 8-10 hours)**
1. Prove limit_dom subtype instances (Countable, DenselyOrdered, NoMinOrder, NoMaxOrder)
2. Extract isomorphism via `Order.iso_of_countable_dense`
3. Define `cantor_f` and `cantor_fmcs`
4. Rewire `chronicle_fmcs` to use `cantor_fmcs`
5. Close forward_G/backward_H (trivial — all domain)
6. Close restricted_tc (F/P witness via limit_F/P_resolution)
7. Close restricted_buc (Until backward via C4 + truth lemma structure)
8. Close restricted_fuc (Until forward via C5 + C3)

**Workstream B: Lemma 2.6 Under Strict Semantics (3 sorry sites, 8-12 hours)**
1. Develop the BX-axiom replacement for the A4a-based seed consistency argument
2. Implement lemma_2_6_full with the new proof
3. Close C4/C4' hard cases using Lemma 2.6
4. Extend eliminate_C4_counterexample signature to include C2'

**These workstreams are independent and can be parallelized.** Workstream A enables sorry-free `dd_countermodel_chronicle` even if Workstream B remains sorry'd (the C4 hard cases are in the omega chain construction, not the limit-to-countermodel wiring).

### The A4a Problem

This is the only new mathematical challenge identified. Options:
1. **Derive the Lemma 2.6 result using BX5+BX6+BX7**: The self-accumulation (BX5), absorption (BX6), and linearity (BX7) axioms together should provide enough structure to prove the seed consistency. This needs a paper proof first.
2. **Add A4a as a derived theorem in BX**: If A4a is derivable from BX axioms (it might be, since BX has a richer axiom set than Burgess's J_0), prove it and use Burgess's proof directly.
3. **Use R3Maximal negation completeness more directly**: Since `r3Maximal_neg_of_not_mem` gives δ.neg ∈ B, and `dcs_neg_union_consistent` gives `{neg δ} ∪ B` consistent, perhaps the full seed can be built incrementally without A4a.

## Recommendations

1. **Start with Workstream A** (Cantor iso) — it closes 8 of 11 sorry sites and is well-understood
2. **Investigate A4a derivability from BX** before attempting the full Lemma 2.6 reproof
3. **If A4a is derivable**: Lemma 2.6 follows Burgess directly (5-8 hours)
4. **If A4a is not derivable**: Need alternative seed consistency argument (10-15 hours, paper proof first)

**Total estimated effort**: 16-22 hours to sorry-free `dd_countermodel_chronicle`.

## Teammate Contributions

| Teammate | Angle | Status | Confidence | Key Contribution |
|----------|-------|--------|------------|------------------|
| A | Cantor iso design | completed | HIGH | All prerequisites provable; shifting works; eval point shifts to cantor_zero |
| B | Lemma 2.6 seed | completed | HIGH | **A4a not sound under strict semantics** — critical finding |
| C | Sorry site analysis | completed | HIGH | 3 categories (not uniform); restricted_buc/fuc need truth lemma wiring |
| D | Venema/alternatives | completed | HIGH | No alternative warranted; Cantor iso is lowest effort |

## References

- Burgess 1982, Lemma 2.6 (lines 160-190): Seed construction using A4a
- PointInsertion.lean:16-22: A3a/A4a not sound under strict semantics
- Mathlib.Order.CountableDenseLinearOrder: `Order.iso_of_countable_dense`
- ChronicleToCountermodel.lean:195-429: 8 sorry sites
- PointInsertion.lean:762: lemma_2_6_full sorry
