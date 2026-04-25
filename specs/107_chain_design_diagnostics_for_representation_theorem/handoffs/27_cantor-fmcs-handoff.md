# Handoff: Task 107 — Cantor FMCS Complete, 4 Active Sorries Remain

**Date**: 2026-04-25
**Session**: sess_1777147765_1e9aa4
**Branch**: irr_until
**Build**: passes (1097 jobs)
**Active sorry count**: 4 (+ 8 legacy dead code)

---

## Summary of This Session's Progress

Starting state: 13 sorry sites across 4 files, forward_G blocked.

| What | Status | Sorry delta |
|------|--------|-------------|
| C4 argument swap (EVENT/GUARD) | Fixed (round 25) | 0 |
| Adjacent restriction removed | Fixed (round 26) | 0 |
| g_ordered deleted | Done | 0 (2 moved, not removed) |
| limit_forward_G / limit_backward_H | **Sorry-free** | -2 |
| lemma_2_6_full | **Sorry-free** (R3Maximal forces MCS) | -1 |
| Cantor iso + cantor_fmcs | **Sorry-free** (forward_G, backward_H, box_stable) | 0 (new infrastructure) |
| cantor_bfmcs modal_forward/backward | **Sorry-free** | 0 |
| restricted_tc (F/P resolution) | **Sorry-free** | -2 (of new stubs) |
| restricted_buc (backward Until/Since) | **Sorry-free** | -2 (of new stubs) |
| C4 hard case decomposition | 2 of 3 sub-cases closed | net 0 |
| **Net sorry change** | | **13 → 4 active** |

---

## Active Sorry Sites (4)

### 1-2. cantor_bfmcs_restricted_fuc (ChronicleToCountermodel.lean:964, 968)

**What**: Forward Until/Since coherence — given `untl(γ,δ) ∈ f(t)`, produce semantic witness y > t with δ ∈ f(y) and γ at all intermediates.

**Blocker**: C5 gives the endpoint witness y with δ ∈ f(y), but proving γ ∈ f(z) for ALL intermediate z requires the limit interval function g(t,y) + C3 (`c3_interval_subset_point`). The current `limit_g` is a placeholder that ignores its second argument.

**Resolution path**: Implement a proper `limit_g` as the union of finite-stage g-values (using the first stage where both arguments are domain points). Then C3 at the limit + `c3_interval_subset_point` gives the guard at intermediates. This is well-understood infrastructure — Teammate B of round 22 provided the complete paper proof.

### 3-4. C4/C4' hard sub-case (CounterexampleElimination.lean:329, 439)

**What**: The sub-case where G(γ) ∈ f(x) AND H(γ) ∈ f(y) — both endpoints have the guard in their temporal content.

**Blocker**: Need to produce z between x and y with γ.neg ∈ f(z). The easier sub-cases (G(γ) ∉ f(x) or H(γ) ∉ f(y)) are closed using F/P witnesses. The hard sub-case requires a fundamentally different argument.

**Resolution paths**:
1. Show the configuration G(γ) ∈ f(x) ∧ H(γ) ∈ f(y) is unreachable when neg(untl(γ,δ)) ∈ f(x) — this would require proving that G(γ) ∈ f(x) implies untl(γ,δ) ∈ f(x) for some δ, contradicting neg(untl(γ,δ)) ∈ f(x). But G(γ) does NOT imply any Until formula.
2. Use the interval function g(x,y) — by R3Maximal_is_mcs, g(x,y) is an MCS. If γ ∉ g(x,y), then γ.neg ∈ g(x,y) and we can use g(x,y) as f(z). If γ ∈ g(x,y), the sub-sub-case remains open. This requires C2' (R3Maximal for the pair) which the function doesn't currently have access to.
3. Defer: these sorry sites are in the omega chain construction, not the limit-to-countermodel wiring. dd_countermodel_chronicle can be sorry-free even if these remain, since the limit C4 is proved by a different path (direct enumeration + elimination).

---

## Architecture After This Session

```
cantor_iso : LimitDomSubtype ≃o Rat          (sorry-free)
cantor_f : Rat → Set Formula                  (sorry-free)
cantor_fmcs : FMCS Rat                        (sorry-free: forward_G, backward_H)
rooted_cantor_fmcs : FMCS Rat                 (sorry-free: shifted version)
cantor_bfmcs : BFMCS Rat                      (sorry-free: modal_forward, modal_backward)
box_stable_in_rooted_cantor_fmcs              (sorry-free)
cantor_bfmcs_restricted_tc                    (sorry-free)
cantor_bfmcs_restricted_buc                   (sorry-free)
cantor_bfmcs_restricted_fuc                   (2 SORRY — needs limit_g + C3)
dd_countermodel_chronicle                     (depends on restricted_fuc)
```

Legacy `chronicle_fmcs`, `chronicle_bfmcs`, and their coherence conditions are DEAD CODE — nothing routes through them.

---

## What's Needed to Close All 4

### For restricted_fuc (2 sorry sites):
1. Implement proper `limit_g` — union of finite-stage g values
2. Prove C3 at the limit
3. Use `c3_interval_subset_point` to extract guard at intermediates
4. Transfer through Cantor iso

### For C4 hard sub-case (2 sorry sites):
1. Pass C2' (ChronicleInvariant) into `eliminate_C4_counterexample`
2. Use `R3Maximal_is_mcs` to get g(x,y) as MCS
3. Case split on γ ∈ g(x,y) vs γ ∉ g(x,y)
4. γ ∉ g(x,y) case: γ.neg ∈ g(x,y), use as f(z). Done.
5. γ ∈ g(x,y) case: still open (may need Lemma 2.9 induction or A4a equivalent)

**Estimated remaining effort**: 10-15 hours for all 4 sorry sites.
