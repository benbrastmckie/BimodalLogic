# Handoff: CE:861 Burgess 2.10 Condition (i) — Implemented

## Summary

The sorry at CE:861 (CounterexampleElimination.lean, condition (i) of Burgess 2.10) has been eliminated.

## What Was Done

Restructured `eliminate_potential_counterexample` in the n>=1 forward (Until) C5 case to handle Burgess 2.10 condition (i) — where xi AND untl(xi,eta) persist into f(x').

### Approach: Forward Walk + Max Point

Instead of trying to split between f(pc.x) and f(x') (which fails in condition (i) because neither lemma_2_7 nor lemma_2_8 applies), the code now:

1. **Checks condition (i) upfront** with `by_cases h_cond_i : xi AND untl(xi,eta) IN f(x')`.

2. **In condition (i)**, defines a "walk set" U = {w in dom | pc.x <= w AND untl(xi,eta) IN f(w)}, finds its maximum u_max, then:
   - **Case A (u_max = max_old)**: Applies `lemma_2_4` at f(max_old) to create a new point y after max_old with eta in f(y). The only new adjacent pair (max_old, y) gets BurgessR3Maximal from lemma_2_4.
   - **Case B (u_max < max_old)**: Finds u_next (successor of u_max). By maximality, untl(xi,eta) is NOT in f(u_next), so condition (i) fails at (u_max, u_next). Sub-cases:
     - If eta IN f(u_next): returns unchanged chronicle (u_next is already a C5 witness).
     - If eta NOT IN f(u_next): applies the full splitting case analysis at (u_max, u_next) — all branches succeed because condition (i) is excluded.

3. **Not condition (i)**: the existing splitting code at (pc.x, x') works as before, with the original sorry replaced by `exact absurd h_conj_x' h_cond_i`.

### Key Insight

The `c5_forward_witness` field of `EliminationResult` only requires `exists y > pc.x, eta IN val.f(y)` — no guard condition. This means:
- If eta already exists at some domain point > pc.x, we can return the unchanged chronicle.
- The walk to u_max finds the right anchor point where the existing splitting lemmas apply.

## Files Modified

- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean`
  - Lines 792-1299 (approximately): restructured condition (i) handling

## Remaining Sorries

- **CE:1485** (was CE:1197): Since mirror of the forward walk. Requires implementing `lemma_2_7_since` or `lemma_2_8_since`, plus the mirror of the forward walk for the backward (Since) case.
- **CTC:634, CTC:638**: FUC/FSC coherence in ChronicleToCountermodel.lean (pre-existing, separate scope).

## Build Status

Build passes with zero new sorries introduced. The sorry count in CounterexampleElimination.lean decreased from 2 to 1.
