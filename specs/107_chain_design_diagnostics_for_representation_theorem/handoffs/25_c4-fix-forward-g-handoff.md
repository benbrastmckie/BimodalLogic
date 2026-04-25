# Handoff: Task 107 — C4 Fix Complete, forward_G Remains Blocked

**Date**: 2026-04-25
**Session**: sess_1777135521_5c1fd8
**Branch**: irr_until
**Build**: passes (1055 jobs, 0 errors)
**Sorry count**: 13 across 4 Chronicle files

---

## What Was Done

### C4 Definition Fix (Phase 1, COMPLETED)

The codebase's C4/C4' definitions (ChronicleTypes.lean:304-319) were swapped to match Burgess 1982:

| | Before (wrong) | After (correct, Burgess C4a) |
|---|---|---|
| C4 checks at f(y) | γ (GUARD, 1st arg of untl) | δ (EVENT, 2nd arg of untl) |
| C4 produces at f(z) | δ.neg (EVENT negation) | γ.neg (GUARD negation) |

In `untl(γ, δ)`: γ = GUARD, δ = EVENT. Burgess's U(α, β): α = EVENT, β = GUARD.

### g_ordered Eliminated

- `hg_ord` and `hh_ord` removed from `ChronicleInvariant` (ChronicleTypes.lean:429)
- `omega_chain_g_ordered` and `omega_chain_h_ordered` deleted from ChronicleConstruction.lean
- `singleton_invariant` simplified to 4 fields: hc0, hc1, hc2', hc3

### Files Modified

- `ChronicleTypes.lean` — C4/C4' definitions, C4Counterexample/C4'Counterexample structures, ChronicleInvariant
- `ChronicleConstruction.lean` — deleted g_ordered/h_ordered, updated limit_forward_G/backward_H docs
- `CounterexampleElimination.lean` — updated C4/C4' elimination to match new field names

---

## What Remains Blocked

### forward_G / backward_H (2 sorry sites, ChronicleConstruction.lean:853, 870)

The C4+C0 one-step proof works **in principle**: G(φ) = ¬(⊤ U ¬φ). Correct C4 with δ=¬φ (EVENT) at f(y) gives γ.neg = ⊤.neg = ⊥ at f(z). ⊥ in MCS contradicts C0.

**But this requires GENERALIZED C4 for all pairs at the limit.** The codebase's C4 is defined for adjacent pairs only. At the dense limit, there are no adjacent pairs, so adjacent C4 is vacuously true.

### Root Cause: Seeding Asymmetry in the Omega Chain

The omega chain construction seeds new points asymmetrically:

| Insertion type | Seed includes | Missing |
|---|---|---|
| C5 (forward witness, y > all) | `g_content(f(x))` | h_content of right neighbor |
| C5' (backward witness, y < all) | `h_content(f(x))` | g_content of left neighbor |
| C4 (midpoint) | `f(left)` or `f(right)` copy | both-sided content |
| Density (midpoint) | `f(left)` copy | h_content of right |
| g_prop (forward propagation) | `g_content(f(x))` | h_content |
| h_prop (backward propagation) | `h_content(f(x))` | g_content |

Because C5' and h_prop seed from h_content only, a backward-inserted point y between w and x (w < y < x) can have G(α) ∈ f(w) but α ∉ f(y). The f-immutability of the omega chain makes this permanent.

### Why Burgess Doesn't Have This Problem

Burgess's Lemma 2.9 (C4 counterexample elimination) handles **non-adjacent** pairs directly by induction on the number of intermediate domain points. When eliminating a C4 counterexample (x, y, γ, δ) with n points between x and y:
- **n=0 (adjacent)**: Insert z directly between x and y
- **n>0**: Find intermediate w. By case analysis on the formulas at w, either reduce to a sub-problem (x, w) or (w, y), each with fewer intermediate points.

**The codebase only implements the n=0 case** (C4 for adjacent pairs). The generalized case would require the omega chain to enumerate and eliminate C4 counterexamples for ALL pairs, not just adjacent ones.

---

## Sorry Inventory (13 total)

| File | Line | What | Root Dependency |
|------|------|------|-----------------|
| ChronicleConstruction.lean | 853 | limit_forward_G | Generalized C4 at limit |
| ChronicleConstruction.lean | 870 | limit_backward_H | Dual of forward_G |
| CounterexampleElimination.lean | 280 | C4 hard case (δ ∈ both f(x) and f(y)) | Lemma 2.6 full |
| CounterexampleElimination.lean | 350 | C4' hard case (mirror) | Lemma 2.6 full |
| PointInsertion.lean | 762 | lemma_2_6_full | Seed construction |
| ChronicleToCountermodel.lean | 195 | chronicle_fmcs.forward_G | limit_forward_G |
| ChronicleToCountermodel.lean | 200 | chronicle_fmcs.backward_H | limit_backward_H |
| ChronicleToCountermodel.lean | 372 | restricted_tc forward | F resolution at limit |
| ChronicleToCountermodel.lean | 375 | restricted_tc backward | P resolution at limit |
| ChronicleToCountermodel.lean | 394 | restricted_buc Until | Until backward coherence |
| ChronicleToCountermodel.lean | 397 | restricted_buc Since | Since backward coherence |
| ChronicleToCountermodel.lean | 426 | restricted_fuc Until | Until forward coherence |
| ChronicleToCountermodel.lean | 429 | restricted_fuc Since | Since forward coherence |

### Dependency Graph

```
Generalized C4 at limit
  → limit_forward_G (853), limit_backward_H (870)
    → chronicle_fmcs.forward_G (195), backward_H (200)
      → box_stable_in_chronicle_fmcs
        → dd_countermodel_chronicle

Lemma 2.6 full (762)
  → C4 hard case (280), C4' hard case (350)
    → (used by omega chain elimination)

Limit C5/C5' + density
  → restricted_tc (372, 375)
  → restricted_fuc (426, 429)

Limit C4 + C3 + truth lemma structure
  → restricted_buc (394, 397)
```

---

## Three Resolution Options

### Option 1: Two-Sided Seeds (g_ordered as inductive invariant)

Modify ALL point insertion functions to seed with both `g_content(f(left))` AND `h_content(f(right))`.

**Pros**: Conservative change; duality theorems (sorry-free) prove seed consistency when g_ordered holds at stage n (IH); lemma_2_5b gives transitivity.

**Cons**: Re-introduces g_ordered as an explicit invariant (was just deleted); the seed consistency proof needs the duality theorem which requires g_ordered as IH (circular but standard inductive pattern); C5 witness placement must change (insert between points, not at boundary).

**Estimated effort**: 15-20 hours.

**Key theorem needed**: `g_content(f(x)) ∪ h_content(f(y))` is consistent when g_ordered holds at stage n. By duality: h_content(f(y)) ⊆ f(x), so the union is a subset of `g_content(f(x)) ∪ f(x)`. Under strict semantics, g_content(f(x)) ⊄ f(x), but the union IS consistent — see report 24 analysis.

### Option 2: Non-Dense Construction + Cantor Isomorphism

Keep the omega chain finite-stage (don't add density points). The limit domain is countable but NOT dense. Apply `Order.iso_of_countable_dense` from Mathlib to embed into ℚ.

**Pros**: Avoids the dense-domain issue entirely; adjacent C4 is meaningful at every stage; forward_G follows from C4+C0 for adjacent pairs + induction through the (finite) chain.

**Cons**: Requires proving the limit domain satisfies Cantor prerequisites (countable, DenselyOrdered, NoMinOrder, NoMaxOrder); the density comes from C4 elimination filling in all gaps. Wait — if we don't add density points, the limit domain may NOT be dense. This option needs C4 counterexamples for ALL pairs to be eliminated (not just adjacent), which is exactly Burgess's Lemma 2.9 for n>0.

**Actually**: This option reduces to implementing Burgess's Lemma 2.9 generalization (induction on n intermediate points). If we implement that, the omega chain eliminates C4 counterexamples for ALL pairs, making the limit dense as a consequence. Then forward_G follows from C4+C0 at the limit.

**Estimated effort**: 10-15 hours (Lemma 2.9 generalization + Cantor iso from report 24).

### Option 3: Remove forward_G from FMCS, Route Through Truth Lemma

Restructure the FMCS/BFMCS to not require forward_G as a field. Instead, the truth lemma proves `x ∈ V(G(φ)) ↔ G(φ) ∈ f(x)` using the Until truth lemma + negation, as Burgess does.

**Pros**: Most faithful to Burgess's actual proof; eliminates the forward_G sorry entirely by architectural change; no g_ordered needed.

**Cons**: Requires refactoring FMCS/BFMCS (Theories/Bimodal/Metalogic/BXCanonical/FMCS.lean and BFMCS.lean); the parametric representation theorem currently requires forward_G as a field; ripple effects through Completeness.lean.

**Estimated effort**: 20-30 hours (significant refactor of the parametric framework).

---

## Recommendation

**Option 2 (Lemma 2.9 generalization)** is the most promising:
- Burgess's own proof handles non-adjacent pairs via Lemma 2.9 induction
- This is the step we've been missing — we only implemented the n=0 case
- Once generalized C4 holds at the limit, the C4+C0 argument closes forward_G
- The Cantor isomorphism (already analyzed in report 24) handles non-domain extension

The key implementation task is: **generalize `eliminate_C4_counterexample` to handle n>0 intermediate points** (induction on n, using the existing n=0 case as base).

---

## What's Sorry-Free (Reusable)

All of the following are proved without sorry and should be preserved:

- r3Relation infrastructure (ChronicleTypes.lean)
- R3Maximal negation completeness (PointInsertion.lean:676)
- Three-way C3 decomposition (ChronicleTypes.lean:292)
- c3_interval_subset_point/left/right (ChronicleTypes.lean:373-404)
- Duality: g_content_sub_imp_h_content_sub, h_content_sub_imp_g_content_sub (ChronicleConstruction.lean:701-784)
- lemma_2_5b, lemma_2_5b_past (PointInsertion.lean:262-291)
- burgessR3_absorption via BX6 (RRelation.lean)
- forward_temporal_witness_seed_consistent (PointInsertion.lean)
- dcs_neg_union_consistent (PointInsertion.lean)
- singleton_invariant (ChronicleConstruction.lean)
- C5/C5' elimination for adjacent cases (CounterexampleElimination.lean)
- C4/C4' elimination — easy cases (CounterexampleElimination.lean)
- limit_dom_dense, limit_c0, limit_c1 (ChronicleConstruction.lean)
- box_stable_in_chronicle_fmcs (ChronicleToCountermodel.lean) — uses forward_G, so correct once forward_G closes
