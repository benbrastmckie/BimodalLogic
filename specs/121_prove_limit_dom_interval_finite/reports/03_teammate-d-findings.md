# Teammate D (Downstream Impact) Findings: Task #121 Round 3

**Focus**: Blast radius analysis of each fix strategy for the discrete completeness blocker
**Date**: 2026-05-11

## 1. Sorry Dependency Chain

The two sorries in `ChronicleToCountermodel.lean` and their full dependency graph:

```
limitDomSubtype_Icc_finite (line 1064, SORRY)
  └── limitDomSubtype_isSuccArchimedean (line 1074, uses Icc_finite at line 1100)
       └── discrete_iso (line 1124, uses isSuccArchimedean at line 1129)
            ├── discrete_f (line 1133, uses discrete_iso)
            ├── discrete_zero (line 1139, uses discrete_iso)
            ├── discrete_f_at_zero (line 1145, uses discrete_f, discrete_zero)
            ├── discrete_f_is_mcs (line 1153, uses discrete_iso)
            └── discrete_fmcs (line 1164, uses discrete_f, discrete_f_is_mcs, discrete_iso)
                 └── dd_countermodel_chronicle_nondense_sorry (line 828, SORRY — cites discrete_fmcs)
                      └── bx_completeness (Completeness.lean:128, line 156)
```

**All definitions from `discrete_iso` through `discrete_fmcs` are sorry-free** — they compile and type-check because they only REFERENCE the sorry-carrying lemma transitively. The sorry at line 836 is the top-level blocker.

**Sorry-free definitions that would be UNAFFECTED by any fix** (lines 855-1048):
- `limit_dom_has_succ` (855) — sorry-free, uses `limit_satisfies_c5_strong`
- `limit_dom_has_pred` (870) — sorry-free
- `next_top_gives_since` (885) — sorry-free
- `limitDomSubtype_succ` (898) — sorry-free
- `limitDomSubtype_succ_le_iff` (909) — sorry-free
- `limitDomSubtype_succOrder` (938) — sorry-free
- `limitDomSubtype_pred` (949) — sorry-free
- `limitDomSubtype_le_pred_iff` (961) — sorry-free
- `limitDomSubtype_predOrder` (991) — sorry-free
- `limitDomSubtype_succ_pred` (1004) — sorry-free
- `limitDomSubtype_le_pred_of_lt` (1034) — sorry-free
- `limitDomSubtype_pred_lt` (1043) — sorry-free

These ALL remain valid regardless of fix approach. They describe the successor/predecessor structure of the limit domain, which is correct (every point has an immediate successor/predecessor). The issue is only with Archimedeanity (succ chain reaching its target in finitely many steps).

## 2. Sorry-Free Chain at Risk (Construction Modification)

If CounterexampleElimination.lean is modified (skip C5 for ξ=⊥), these sorry-free proofs in ChronicleConstruction.lean might be affected:

| Lemma | Line | Risk | Why |
|-------|------|------|-----|
| `omega_chain_c5_witness` | 391 | **HIGH** | Directly uses `c5_forward_witness` from EliminationResult |
| `omega_chain_c5'_witness` | 430 | **HIGH** | Mirror for Since |
| `omega_chain_c5_forward_resolved_no_new` | 1212 | MEDIUM | Uses `c5_forward_resolved_no_new` |
| `omega_chain_c5_backward_resolved_no_new` | 1235 | MEDIUM | Mirror |
| `limit_satisfies_c5_strong` | 1440 | **HIGH** | Uses `omega_chain_c5_witness` |
| `limit_satisfies_c5'_strong` | 1483 | **HIGH** | Mirror |
| `omega_chain_dom_new_unique` | 1196 | LOW | Uses `dom_new_unique` from EliminationResult |
| `adj_g_mem_limit_f` | 1263 | LOW | Uses g-value inheritance |

**Key observation**: `limit_satisfies_c5_strong` is the foundation for `limit_dom_has_succ`. If the C5 walk no longer inserts midpoints for ξ=⊥, the witness mechanism changes. Currently:
- The witness `y` comes from `omega_chain_c5_witness` at some stage n
- For U(⊤,⊥), `y` is a midpoint (newly inserted)
- The guard `⊥ ∈ limit_g(x,y)` is proved vacuously (any w between x and y would need ⊥ ∈ limit_f(w), impossible)

If we skip C5 for ξ=⊥, `omega_chain_c5_witness` would NOT produce a witness for U(⊤,⊥). But `limit_satisfies_c5_strong` would need to find one anyway. The existing dom-successor c would serve, and the guard would be vacuously true — but the PROOF would break because it relies on `omega_chain_c5_witness`.

## 3. "Skip ξ=⊥" Change Impact

### How `eliminate_potential_counterexample` works (line 1811)

The function matches on `pc.kind`:
- `.c5_forward`: checks `h_actual` (is this a live counterexample?). If live AND no existing witness, calls `c5_forward_walk` to insert a midpoint. If NOT live or already satisfied, returns identity chronicle.
- `.c4_forward`, `.c4_backward`, `.c5_backward`: similar patterns.

The "is it live?" check at line 1825:
```lean
by_cases h_actual : pc.x ∈ χ.dom ∧ Formula.untl pc.η pc.ξ ∈ χ.f pc.x ∧
    ¬∃ y ∈ χ.dom, pc.x < y ∧ pc.η ∈ χ.f y ∧ ...
```

For U(⊤,⊥): `pc.ξ = ⊥`, `pc.η = ⊤`. The witness check requires `⊥ ∈ χ.g a b` for adjacent pairs — which is never true for consistent g-values. So the check ALWAYS finds "no witness exists" → ALWAYS inserts a midpoint.

### Proposed modification: add early return for ξ=⊥

Before the `h_actual` check, add:
```lean
by_cases h_bot : pc.ξ = Formula.bot
· -- ξ = ⊥: return identity (C5 for U(η,⊥) is vacuously satisfied in the limit)
  exact { val := χ, dom_sub := le_refl _, ... }  
```

This would:
- NOT insert any midpoint for U(η,⊥)
- Return the identity chronicle (dom unchanged)
- The C5 witness guarantee becomes: "the dom-successor satisfies vacuously"

### What breaks

1. **`c5_forward_witness` field**: Currently promises witness y with guard ξ ∈ g(a,b). For ξ=⊥, this would need to promise ⊥ ∈ g(a,b), which is false. The field signature would need to handle the ξ=⊥ case differently, OR the witness field would need weakening.

2. **`omega_chain_c5_witness` (ChronicleConstruction.lean:391)**: References `c5_forward_witness` directly. Would need to handle the ξ=⊥ case.

3. **`limit_satisfies_c5_strong` (ChronicleConstruction.lean:1440)**: Uses `omega_chain_c5_witness` to get the witness. For ξ=⊥, would need alternative reasoning (any dom-successor works since guard is vacuously true in the limit).

### Estimated changes

| File | Lines at risk | Nature of change |
|------|--------------|------------------|
| CounterexampleElimination.lean (3488 lines) | ~50-100 | Add ξ=⊥ early return in `eliminate_potential_counterexample` + modify `c5_forward_witness` field |
| ChronicleConstruction.lean (1520 lines) | ~100-200 | Modify `omega_chain_c5_witness` + `limit_satisfies_c5_strong` for ξ=⊥ |
| ChronicleToCountermodel.lean (1188 lines) | ~50 | Prove `limitDomSubtype_Icc_finite` (now provable) + remove sorry |

**Total: ~200-350 lines changed in sorry-free code.**

## 4. "Quotient" Change Impact

### Where would the quotient be inserted?

After `limit_dom` is constructed (ChronicleConstruction.lean:551) and before the discrete path in ChronicleToCountermodel.lean. The quotient would:
1. Define equivalence: `x ~ y` iff `succ^n(x) = y` or `succ^n(y) = x` for some n
2. Quotient `limit_dom / ~` to collapse convergent succ-chains
3. Show the quotient is isomorphic to ℤ

### What needs to be transported?

- `limit_f`: f-values at quotient representatives → need well-definedness proof
- `limit_g`: g-values → these don't exist between points in the same equivalence class
- FMCS properties: forward_G, backward_H → need to go through the quotient
- The Cantor/ℤ isomorphism → build on the quotient

### Does Algebraic/ care about domain type?

Yes: `ParametricCanonicalTaskFrame` requires `AddCommGroup D`, `LinearOrder D`, `IsOrderedAddMonoid D`, `Nontrivial D`. The domain type D is fixed to ℚ in the dense case and ℤ in the discrete case. Any quotient type would need all four instances.

### Estimated changes

| File | Lines | Nature |
|------|-------|--------|
| ChronicleToCountermodel.lean | ~300-500 new | Define quotient, transport f, prove FMCS on quotient |
| ChronicleConstruction.lean | 0 | Unchanged |
| CounterexampleElimination.lean | 0 | Unchanged |

**Total: ~300-500 new lines, 0 lines of existing sorry-free code modified.**

## 5. Sorry-Free LOC at Risk Summary

| Approach | Existing sorry-free LOC modified | New LOC | Total effort |
|----------|--------------------------------|---------|-------------|
| **Skip ξ=⊥** | ~200-350 (across 3 files) | ~50-100 | 15-25 hours |
| **Quotient** | 0 | ~300-500 | 20-30 hours |
| **Direct IsSuccArchimedean** | ~50 (ChronicleToCountermodel only) | ~200-400 | 15-25 hours |
| **Separate construction** | 0 | ~1000+ | 40-80 hours |
| **Reynolds full bypass** | 0 (+ restructure ~500) | ~800-1500 | 60-120 hours |

### Risk assessment per approach

**Skip ξ=⊥**: Lowest total effort but highest risk — modifies sorry-free construction code. The `c5_forward_witness` field change propagates through `omega_chain_c5_witness` → `limit_satisfies_c5_strong` → `limit_dom_has_succ`. All are sorry-free. Risk of introducing bugs or making existing proofs break.

**Quotient**: Zero risk to existing code but more new code. The quotient approach is mathematically clean but formalizing quotients of ordered structures with FMCS properties is non-trivial. The ℤ structure on the quotient needs careful construction.

**Direct IsSuccArchimedean**: Smallest blast radius — only touches ChronicleToCountermodel.lean. Would bypass both `Icc_finite` AND the ℤ-isomorphism entirely. Instead, prove `IsSuccArchimedean` directly from the omega chain stages. The challenge: proving the succ chain from a reaches b requires showing the infinite midpoint chain eventually covers all points.

**Separate construction**: Cleanest but most effort. Build a second omega chain construction specifically for the discrete case that doesn't insert midpoints for U(⊤,⊥). Mirrors Burgess's "routine exercise" comment.

**Reynolds bypass**: Most effort, most architectural risk. Requires formalizing EF games, expressive completeness, and restructuring the entire parametric representation pipeline.
