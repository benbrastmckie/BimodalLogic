# Handoff: c2' Weakening Approach (Task 107, Plan v20)

## Session
- **Session ID**: sess_1777305935_d9720c
- **Date**: 2026-04-26
- **Agent**: lean-implementation-agent

## What Was Done

### 1. Weakened c2' Definition (ChronicleTypes.lean)
- **Changed** `Chronicle.c2'` from requiring `BurgessR3Maximal` to requiring `SetDeductivelyClosed ∧ burgessR3`
- Rationale: The C4 hard case only uses DCS + burgessR3, not maximality. At the limit, domain is dense (no adjacent pairs), so c2' is vacuously true regardless.
- Impact: All downstream code that used `h_R3M.1` (DCS) and `h_R3M.2.1` (burgessR3) from BurgessR3Maximal now uses `h.1` (DCS) and `h.2` (burgessR3) from the pair.

### 2. Updated C4/C4' Hard Case (CounterexampleElimination.lean)
- Changed `h_R3M` destructuring to `⟨h_dcs_wn, h_r3_wn⟩` for C4 and `⟨h_dcs_pw, h_r3_pw⟩` for C4'
- Replaced `h_R3M.2.1` with `h_r3_wn`/`h_r3_pw` and `h_R3M.1` with `h_dcs_wn`/`h_dcs_pw`

### 3. Implemented Density Case with Modified g (CounterexampleElimination.lean)
- Defined `g'` as: for new pairs (pc.x, z) and (z, pc.y), use `χ.g pc.x pc.y`; for old pairs, use `χ.g a b`
- Successfully proved c2' for:
  - The (z, pc.y) sub-pair: uses `h_c2' pc.x pc.y h_adj` directly (same endpoint MCSes)
  - Old adjacent pairs: carries over from `h_c2'` with adjacency proof
  - g_agrees for old domain pairs: follows from the if-then-else construction
- **Remaining sorry**: The (pc.x, z) sub-pair requires `burgessR3(χ.f pc.x, χ.g pc.x pc.y, χ.f pc.x)` which is a "self-pair" -- the third argument is f(pc.x) not f(pc.y). This does NOT follow from the old c2'.

## Build Status
- `lake build` succeeds (1097 jobs, 0 errors)

## Sorry Count
- **Before**: 9 (7 c2' in elimination + 2 FUC)
- **After**: 9 (6 original c2' + 1 density self-pair + 2 FUC)
- Net: 0 change in count, but architecture is improved and one case (density) is ~80% done

## The Self-Pair Blocker

### The Problem
For the density case with f(z) = f(x), the new pair (x, z) needs:
```
burgessR3(f(x), g(x,y), f(x))
```
where we have `burgessR3(f(x), g(x,y), f(y))` from the old c2'.

These are DIFFERENT because:
- `burgessRSet(f(x), g(x,y), f(x))` requires `untl(β, γ) ∈ f(x)` for all `γ ∈ f(x)` -- different from `γ ∈ f(y)`
- `burgessRSetSince(f(x), g(x,y), f(x))` requires `snce(β, γ) ∈ f(x)` for all `γ ∈ f(x)` -- different from `snce(β, γ) ∈ f(y)`

### Why It's Hard
Every DCS B contains all theorems. In particular, ⊤ = (⊥ → ⊥) ∈ B. Then:
- `burgessR(A, ⊤, C)` = for all γ ∈ C, `untl(⊤, γ) ∈ A` = for all γ ∈ C, `F(γ) ∈ A`

So `burgessR3(A, B, A)` with B a DCS requires `F(γ) ∈ A` for ALL `γ ∈ A`. Under strict (irreflexive) semantics, this is NOT guaranteed.

### Possible Approaches
1. **Change f(z) for density case**: Use f(z) ≠ f(x) and f(z) ≠ f(y). Construct f(z) specifically to be temporally compatible. E.g., use lemma_2_6 or a Lindenbaum extension of g(x,y) ∪ {temporal connectives}. The challenge: need burgessR3 to hold with f(z) as one endpoint.

2. **Add a new axiom/lemma**: Prove that for MCS A arising from the omega chain at an adjacent pair, `F(γ) ∈ A` for all `γ ∈ A`. This would be implied by the forward seriality of the canonical frame, but we haven't proved it at the finite-stage level.

3. **Restructure density elimination**: Don't insert z with a specific f(z). Instead, use a non-deterministic construction that simultaneously picks f(z) and g-values.

4. **Remove density from omega chain**: Prove limit density differently, e.g., from C4/C5 eliminations alone. This is a major architectural change.

5. **Delay c2' to the limit**: Prove c2' only at the limit (vacuously, since dense domain has no adjacent pairs). But C4 hard case needs c2' at finite stages for the specific pair it uses.

6. **Track c2' per-pair**: Maintain c2' only for pairs where both endpoints were in the domain at the same stage. Fresh pairs from the current step don't need c2' until the next step. At the next step, the fresh pair might get c2' through a different mechanism.

### Recommendation
Approach 5/6 seems most promising: the C4 hard case at step n+1 uses c2' of step n's chronicle. The pairs it examines (w, w_next) are in step n's domain. If (w, w_next) was an old pair with established c2', we're fine. If (w, w_next) involves a point inserted at step n, that point was added by step n's elimination. Step n had c2' as input, and the C4/C5 elimination uses c2' for pairs in the PREVIOUS domain, not for newly created pairs.

So the KEY insight: the C4 hard case at step n+1 only uses c2' for pairs that existed in step n's INPUT (step n-1's output). It never uses c2' for pairs created by step n's elimination. This means c2' for NEW pairs at step n is only needed at step n+2 or later. And at that point, the pair may have been further split, making it non-adjacent.

This needs formal verification but could lead to a clean solution.

## Files Modified
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleTypes.lean` -- c2' weakened
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean` -- C4/C4' hard case updated, density case partially implemented

## What Remains

### Closing the 6 Original c2' Sorry Sites
Apply the same density-case approach (modified g with if-then-else) to:
- C5 (line 786): endpoint case, need g for (max(dom), y)
- C5' (line 824): endpoint case, need g for (y, min(dom))
- C4 (line 864): splitting case, z between x and y
- C4' (line 902): mirror
- g_prop (line 938): splitting case
- h_prop (line 970): splitting case

### Resolving the Self-Pair Blocker
The density sorry at line 1086 and potentially similar sorries in the other 6 cases.

### Phases 4-5 (from plan v20)
- Phase 4: limit_g definition, g-immutability, limit C3
- Phase 5: FUC closure (2 sorries in ChronicleToCountermodel.lean)
