# Phase 6 Handoff: Domain Guard Infrastructure

## Session
sess_1778114001_749277

## Status
PARTIAL -- Infrastructure added, 5 sorries remain (up from 2), analysis complete.

## What Was Done

### Tasks 6.1 and 6.2: Strengthened omega_chain_c5_witness (DONE)
- `omega_chain_c5_witness` now returns: witness y + event + adj_guard + domain_guard
- `omega_chain_c5'_witness` (Since mirror) similarly strengthened
- Both compile. Callers updated with `_, _` for unused fields in weak versions.

### Walk Infrastructure: domain_guard Field (DONE)
Added `domain_guard` field to both `C5ForwardWalkResult` and `C5BackwardWalkResult`:
```
domain_guard : forall w in chi.dom, start < w -> w < witness -> xi in val.f w
```

Proved in ALL cases of both walks:
- **Base case**: Vacuously true (start = max/min of dom, no domain points beyond start)
- **Condition (i)**: Uses `conj_left_mcs` at x' (from `xi /\ (xi U eta) in f(x')`) plus recursive domain_guard
- **Split cases**: Vacuously true (witness = midpoint between adjacent pair, no old domain points in interval)

### EliminationResult Strengthened (PARTIAL)
Changed `c5_forward_witness` and `c5_backward_witness` return types to include domain_guard:
```
exists y, ... /\ adj_guard /\ domain_guard
```

**Walk cases**: Use `r.witness_guard, r.domain_guard` from walk result. COMPILES.

**Identity cases** (line 2322 and 2817): `sorry` -- when the C5 counterexample was ALREADY eliminated and `val = chi` (identity), the existing witness has adj_guard but not domain_guard. The domain_guard asks `forall w in chi.dom, x < w -> w < y -> xi in chi.f w`, which cannot be derived from adj_guard alone.

## 5 Sorry Sites

1. **CounterexampleElimination.lean:2322** -- Identity case forward C5 domain_guard
2. **CounterexampleElimination.lean:2817** -- Identity case backward C5 domain_guard
3. **ChronicleConstruction.lean:1552** -- w in dom(n+1) \ dom(n) case in limit_satisfies_c5_strong
4. **ChronicleConstruction.lean:1566** -- w not in dom(n+1) case in limit_satisfies_c5_strong (needs adj pair finder)
5. **ChronicleConstruction.lean:1578** -- limit_satisfies_c5'_strong (Since mirror, original sorry)

## Root Cause Analysis

The `limit_g` definition: `limit_g(x,y) = {phi | forall w in limit_dom, x < w -> w < y -> phi in limit_f(w)}`.

Proving `xi in limit_g(x,y)` requires `xi in limit_f(w)` for ALL `w` between x and y. The adj_guard gives `xi in g_{n+1}(a,b)` for adjacent pairs at stage n+1, which via `adj_g_mem_limit_f` gives `xi in limit_f(w)` for `w NOT in dom(n+1)`. But for `w IN dom(n+1)`, there is no adjacent pair strictly containing w, so `adj_g_mem_limit_f` cannot be applied.

### Three cases for w in limit_dom with x < w < y:

1. **w not in dom(n+1)**: SOLVED by adj_g_mem_limit_f. Need helper lemma to find containing adjacent pair in finite domain.

2. **w in dom(n) (old point)**: The walk's condition (i) check gives `xi /\ (xi U eta) in f(x')` at each intermediate walk point x', hence `xi in f(x')`. This is captured by `domain_guard` field. SOLVED.

3. **w in dom(n+1) \ dom(n) (new point)**: The walk inserts at most one new point. In the walk's split case, the new point IS the witness, so `w < y` with `w = witness` is impossible (w = y). In condition (i), no new point is inserted between start and x'. So the new point comes from the recursive call, which is AFTER x'. In this case, `w` is between x' and witness. The recursive walk's `domain_guard` covers points in `chi.dom` between x' and witness. But `w` is NOT in `chi.dom` (it's new). However, `g_sub_f_insert` gives `g_{prev}(a', b') subset f_{new}(w)` when w is inserted between adjacent (a', b'). If `xi in g_{prev}(a', b')`, then `xi in f(w)`.

### The Identity Case Problem

When `eliminate_potential_counterexample` finds that the counterexample was already resolved (witness exists), it returns the identity (`val = chi`). The existing witness has adj_guard but the domain_guard (`forall w in dom, x < w -> w < y -> xi in f(w)`) cannot be derived from adj_guard alone using chronicle axioms.

## Recommended Next Steps

### Option A: Change the by_cases condition (RECOMMENDED)
Change the condition to check for BOTH adj_guard AND domain_guard. In the positive case (neither exists), the walk can be called because `not (exists y, adj /\ dom)` is WEAKER than `not (exists y, adj)`. BUT: the walk's h_no_wit uses `not (exists y, adj)`. So the walk would need to be modified to accept the weaker assumption. Inside the walk, h_no_wit is used to derive contradictions -- when a witness with adj_guard is found, it contradicts h_no_wit. With the weaker assumption, we'd also need domain_guard for the contradiction. But domain_guard at intermediate walk steps follows from condition (i) check (xi in f(x')).

Concretely:
1. Change walk's h_no_wit type to `not (exists y, adj /\ dom)`
2. In each contradiction site inside the walk, also provide domain_guard (which follows from condition (i) checks)
3. Change by_cases condition in eliminate_potential_counterexample similarly
4. Identity case automatically gets domain_guard from push_neg

This is ~30-50 lines of changes inside the walk.

### Option B: Prove separate theorem
Prove that at any omega chain stage where a C5 witness exists with adj_guard, the domain_guard also holds. This follows by induction on the stage number, using the walk's properties at the stage where the witness was created.

### Option C: Close ChronicleConstruction directly
For case 3 (new point), prove `xi in g_n(a', b')` from the walk structure. The walk's g_sub_f_insert gives g_n ⊆ f_{n+1}. If we can show xi is in the OLD g-value, we're done. In condition (i), xi in g(start, x') is given. The new point from the recursive call is between x' and witness. The g-value g_n(x', next_of_x') would contain xi (from condition (i) at x'). Then g_sub_f_insert gives xi in f(new_point).

## Files Modified
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean`
  - Added `domain_guard` to `C5ForwardWalkResult` and `C5BackwardWalkResult`
  - Strengthened `EliminationResult.c5_forward_witness` and `c5_backward_witness` return types
  - 2 new sorries in identity cases (lines 2322, 2817)
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleConstruction.lean`
  - Strengthened `omega_chain_c5_witness` and `omega_chain_c5'_witness`
  - Partially rewrote `limit_satisfies_c5_strong` with case analysis
  - 3 sorries remain (lines 1552, 1566, 1578)
