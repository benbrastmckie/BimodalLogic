# Handoff: dom_new_unique closed, C5 guard analysis complete

## Status: 2 sorries remain (down from 3)

### What was done

1. **Closed `omega_chain_dom_new_unique`** (sorry #1):
   - Added `dom_new_unique` field to `EliminationResult` structure in CounterexampleElimination.lean
   - Field: `∀ u v, u ∈ val.dom → u ∉ χ.dom → v ∈ val.dom → v ∉ χ.dom → u = v`
   - Proved for all 18 cases: 7 unchanged (vacuously true) and 11 insert (`Finset.mem_insert` reasoning)
   - Proved `omega_chain_dom_new_unique` using the new field
   - Build passes

2. **Analyzed the C5 strong guard problem in depth**

### Why the C5 guard is hard

The 2 remaining sorries are `limit_satisfies_c5_strong` (line 1445) and `limit_satisfies_c5'_strong` (line 1457).

Goal: given `U(ξ,η) ∈ limit_f(x)`, find `y > x` with `η ∈ limit_f(y)` AND `ξ ∈ limit_f(w)` for all `w ∈ limit_dom` with `x < w < y`.

**Three approaches were analyzed and all have obstacles:**

#### Approach A: Add guard to EliminationResult.c5_forward_witness

The previous agent attempted:
```
∀ a b, Adjacent val.dom a b → pc.x ≤ a → b ≤ y → pc.ξ ∈ val.g a b
```

This CANNOT be proved for the "not actual counterexample" case and the "condition (i) with eta in u_next" case, because:
- In those cases, val = χ (unchanged chronicle)
- The witness y is already in χ.dom
- The forward walk gives ξ ∈ f(z) for intermediate z, NOT ξ ∈ g(a,b) for adjacent pairs
- g-values are independent sets (BurgessR3Maximal), not determined by f-values

#### Approach B: Syntactic/axiomatic argument

Attempted to use BX5 (self-accumulation) + C4 (contrapositive) to derive ξ ∈ limit_f(w) from U(ξ,η) ∈ limit_f(x).

**Blocked by**: BX9 (until_elim: U(ξ,η) → η ∨ ξ) was REMOVED as unsound under open guard semantics. Without BX9, U(ξ,η) at x does NOT imply ξ at x. The guard only holds at points STRICTLY between x and the witness.

#### Approach C: Multi-stage omega chain induction

The guard propagation happens across MULTIPLE omega chain stages, not in a single elimination step:
1. Stage n: U(ξ,η) ∈ f_n(x). Condition (i) gives ξ ∈ g(x, x').
2. Stage n+k: the sub-counterexample (x', ξ, η) is processed, giving ξ ∈ g(x', x'').
3. Continue until the entire interval [x, y] is covered.

This is the Burgess argument but formalized across the omega chain. It requires either:
- Strengthening the "not actual counterexample" condition to check g-values (matching Burgess exactly)
- Or proving a complex omega-chain-level induction tracking guard accumulation

### Recommended approach

**Strengthen the counterexample condition** to match Burgess:

Currently:
```lean
¬∃ y ∈ χ.dom, pc.x < y ∧ pc.η ∈ χ.f y ∧
  ∀ z ∈ χ.dom, pc.x < z → z < y →
    pc.ξ ∈ χ.f z ∧ Formula.untl pc.ξ pc.η ∈ χ.f z
```

Strengthen to include g-value check:
```lean
¬∃ y ∈ χ.dom, pc.x < y ∧ pc.η ∈ χ.f y ∧
  ∀ a b, Adjacent χ.dom a b → pc.x ≤ a → b ≤ y → pc.ξ ∈ χ.g a b
```

With this:
- "Not actual" case directly provides the guard
- "Actual" case gets MORE situations to handle, but ALL involve inserting new points where the elimination explicitly sets g-values with ξ

The "condition (i)" walk then becomes: at each walk step w → w', check ξ ∈ g(w, w') (which is exactly what condition (i) provides). If ξ ∈ g at every step, the walk continues. If not, the splitting handles it.

This is a significant refactor of CounterexampleElimination.lean (~50-100 lines changed in the condition checks and case analysis).

### Files modified
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean`: Added `dom_new_unique` field
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleConstruction.lean`: Closed `omega_chain_dom_new_unique` sorry

### Remaining sorries
1. **ChronicleConstruction.lean:1445** — `limit_satisfies_c5_strong` guard (Until)
2. **ChronicleConstruction.lean:1457** — `limit_satisfies_c5'_strong` guard (Since mirror)
