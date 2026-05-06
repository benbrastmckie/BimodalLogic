# Handoff: Phase 2 Analysis — Guard Propagation Strategy

## Session
- **Session ID**: sess_1778085791_d0f727
- **Plan**: plans/63_implementation-plan.md
- **Phase**: 2 (Thread Guard Through EliminationResult and Omega Chain)
- **Status**: Analysis complete, strategy determined, implementation not started

## Summary

Phase 2's goal is to propagate `ξ ∈ B` (guard in interval DCS from Phase 1's `lemma_2_4_with_guard`) through the omega chain to close the FUC/FSC sorry sites.

After thorough analysis, I determined that **the plan's approach (A) and (B) are both insufficient** due to a structural gap: the finite-stage chronicle does NOT maintain Burgess's C3 property, and `lemma_2_7` does not preserve `B_old ⊆ B'` for the left g-value. A C3-based approach is needed.

## The FUC/FSC Sorry Goals (ChronicleToCountermodel.lean:634,638)

```
FUC (line 634):
⊢ ∃ s_1, t < s_1 ∧ ψ ∈ mcs(s_1) ∧ ∀ r, t < r → r < s_1 → φ ∈ mcs(r)

FSC (line 638): (mirror for Since)
```

The guard condition `∀ r, t < r → r < s_1 → φ ∈ mcs(r)` expands (via the Cantor isomorphism) to `φ ∈ limit_g(x, y_wit)`, which by definition equals `∀ w ∈ limit_dom, x < w → w < y_wit → φ ∈ limit_f(w)`.

## What Already Exists

1. **limit_g definition** (ChronicleConstruction.lean:845-849): `{φ | ∀ y ∈ limit_dom, x < y → y < z → φ ∈ limit_f y}`
2. **limit_c3** (ChronicleConstruction.lean:862): `limit_g(x,z) = limit_g(x,y) ∩ limit_f(y) ∩ limit_g(y,z)`
3. **limit_c3_interval_subset_point** (ChronicleConstruction.lean:888): `limit_g(x,z) ⊆ limit_f(y)` for x < y < z
4. **limit_satisfies_c5_weak** (ChronicleConstruction.lean:590): gives `∃ y, η ∈ limit_f(y)` but NOT the guard
5. **lemma_2_4_with_guard** (PointInsertion.lean:4942): gives `ξ ∈ B` where B = g(x, y_wit) at stage n+1
6. **EliminationResult.g_agrees**: old g-values preserved for old pairs
7. **All splitting lemmas**: `B ⊆ D` (old g-value ⊆ new f-value)

## Analysis of Approaches

### Approach (A): Thread guard through EliminationResult

**Idea**: Add `c5_forward_guard` field to EliminationResult; thread `ξ ∈ g_{n+1}(x, y)` through `omega_chain_c5_witness`.

**Problem**: This gives `ξ ∈ g_{n+1}(x, y_wit)` but does NOT prove `ξ ∈ limit_g(x, y_wit)`, because `limit_g` is defined as a universal over ALL intermediate limit_dom points, including those added at LATER stages. Bridging from finite-stage g to limit_g requires showing `g_{n+1}(x, y_wit) ⊆ limit_f(w)` for all later-inserted w — which requires C3 at finite stages.

### Approach (B): Direct limit-level guard propagation

**Idea**: Prove `ξ ∈ limit_f(w)` for intermediate w directly from c2' + absorption, without modifying EliminationResult.

**Problem**: At later stages m > n+1, when a point w is inserted between x and y_wit, `f_m(w) = D` where D comes from a splitting lemma. While `B_old ⊆ D` (old g-value ⊆ new f-value), the g_old for the pair being split might NOT contain B_orig (the original g(x, y_wit)). Specifically:

- **lemma_2_6_splitting**: B_old ⊆ B', B_old ⊆ D, B_old ⊆ B'' (OK)
- **lemma_2_7**: DC({xi_new}) ⊆ B', B_old ⊆ D, B_old ⊆ B'' (B' does NOT necessarily contain B_old)
- **lemma_2_8**: B_old ⊆ B', B_old ⊆ D, B_old ⊆ B'' (OK)

When lemma_2_7 creates a pair (a, z) with g(a,z) = B' ⊉ B_old, a subsequent splitting of (a, z) uses B' as the starting point. Since ξ might not be in B', the chain `B_orig ⊆ B_old ⊆ D` breaks.

### Purely limit-level approaches

**BX5 self-accumulation**: From `untl(ξ,η) ∈ f(x)`, BX5 gives `untl(ξ ∧ untl(ξ,η), η) ∈ f(x)`. This enriches the guard but doesn't avoid the need for strong C5 (circular).

**C4 contrapositive**: C4 says `¬U(ξ,η) ∈ f(x) ∧ η ∈ f(y) → ∃ z, ξ.neg ∈ f(z)`. We have `U(ξ,η) ∈ f(x)` (not its negation), so C4 doesn't apply.

**BX14 separation**: `U(ξ,η) ∧ ¬U(r,η) → U(ξ, ξ∧¬r)`. Doesn't directly help.

## Recommended Strategy: Add C3 to Omega Chain

### What needs to change

Burgess says "let C3 determine the other values of g'(w,z) and g'(z,w)" when inserting a new point. The Lean code currently sets g only for new adjacent pairs and preserves old pairs via g_agrees, leaving g for non-adjacent pairs involving the new point as garbage values.

**Fix**: Redefine the g-function in each elimination case to satisfy C3 for ALL pairs (not just adjacent). Specifically, for any pair (a, b) in the new domain with a < b:

```
g'(a, b) = ⋂ { f'(w) | w ∈ dom', a < w < b }
```

This is the C3-derived g. It automatically satisfies C3 by construction. For adjacent pairs (no intermediate points), it equals the old g value (empty intersection = the g-value from the splitting, which already satisfies BurgessR3Maximal).

Wait — that's not quite right. For adjacent pairs (a, b), the intersection is empty (no intermediate points), so g'(a, b) would be... undefined or Set.univ (empty intersection). The adjacent pair's g-value should be the BurgessR3Maximal B from the splitting.

**Better definition**: 

```
g'(a, b) = if a and b are adjacent in dom' then
             (the explicit B from the splitting/old g)
           else
             g'(a, m) ∩ f'(m) ∩ g'(m, b)  -- for some m between a and b
```

This is a recursive definition that's well-founded on the number of domain points between a and b.

### Simpler alternative: Add C3 field to EliminationResult

Instead of changing the g-function definition, add a `c3` field to `EliminationResult`:

```lean
c3 : val.c3
```

Then prove C3 for each elimination case. This requires:
1. Singleton has C3 (already proved: `singleton_invariant.hc3`)
2. Each elimination preserves C3

For preservation: The key insight is that C3 is about ALL triples (x, y, z) with x < y < z in dom. For triples not involving the new point, C3 is preserved by g_agrees. For triples involving the new point w:

- g'(a, b) for a < w < b: g'(a, b) = old g(a, b) (by g_agrees, since a, b ∈ old dom). C3 says g'(a, b) = g'(a, w) ∩ f'(w) ∩ g'(w, b). But g'(a, w) and g'(w, b) are the NEW g values from the splitting. So we need:

  `old_g(a, b) = B'(a,w) ∩ f(w) ∩ B''(w,b)`

This is exactly the Lemma 2.5 absorption equality: `B = B' ∩ D ∩ B''`. Burgess states this in Lemma 2.6's proof. But it's NOT currently proved in the codebase.

### Recommended implementation path

1. **Prove `B = B' ∩ D ∩ B''` (Lemma 2.5 absorption equality)**: This is the key missing piece. From BurgessR3Maximal(A, B, C) and the splitting into B', D, B'' with B ⊆ B', B ⊆ D, B ⊆ B'', prove B = B' ∩ D ∩ B''. This uses the maximality of B together with the absorption lemma.

2. **Add C3 field to EliminationResult** and prove it for each case.

3. **Track C3 through the omega chain** (add `omega_chain_c3`).

4. **Prove finite-stage g(x, y_wit) ⊆ f_m(w)** using C3 at finite stages.

5. **Prove `limit_satisfies_c5_strong`** using the finite-stage guard propagation.

6. **Close FUC/FSC** using limit_satisfies_c5_strong + Cantor isomorphism transfer.

### Alternative: Weaker C3 sufficient for guard

Instead of full C3, we might only need:

**Weak C3**: For the SPECIFIC pair (x, y_wit) from the C5 elimination:
`g_m(x, y_wit) ⊆ f_m(w)` for all w ∈ dom(m) between x and y_wit.

This follows from:
- g_m(x, y_wit) = g_{n+1}(x, y_wit) = B_orig (by g_agrees)  
- B_orig ⊆ D = f_m(w) (by the chain: B_orig ⊆ g_m(a,b) ⊆ D when lemma_2_6 or lemma_2_8 is used)

The problem is with lemma_2_7 in the left g-value. But we could work around this by noting that `B_orig ⊆ D` always holds (even in lemma_2_7), so `ξ ∈ f_m(w)` for the DIRECT insertion. The issue is only for SUBSEQUENT insertions into the (a, z) sub-interval where g(a, z) = B' ⊉ B_orig.

For this subsequent case: when a further point w2 is inserted between a and z by splitting (a, z), we need ξ ∈ D2. We have g(a,z) = B' and B' ⊆ D2. If ξ ∉ B', then ξ ∉ D2 (potentially).

But wait: f_m(z) = D already contains ξ. And f_m(a) also contains ξ (by induction on f-values). When we split (a, z), the D2 comes from lemma_2_6/2_7/2_8 applied to f(a), g(a,z), f(z). The seed for D2 includes g(a,z) = B'. But ξ ∈ f(a) and ξ ∈ f(z), which are both MCS at the endpoints. Is ξ necessarily in D2?

From BurgessR3Maximal(f(a), B', f(z)): B' is a maximal DCS with burgessR3(f(a), B', f(z)). If g_content(f(a)) ⊆ B' (which follows from BurgessR3Maximal), and G(ξ) ∈ f(a), then ξ ∈ g_content(f(a)) ⊆ B'. But G(ξ) ∈ f(a) is NOT guaranteed just from ξ ∈ f(a).

**Conclusion**: The purely g-invariant approach fails at lemma_2_7. Full C3 or the absorption equality is needed.

## Key Files and Line References

- **EliminationResult**: CounterexampleElimination.lean:602
- **eliminate_potential_counterexample**: CounterexampleElimination.lean:640
- **C5 forward (n=0)**: CounterexampleElimination.lean:664-748 (uses lemma_2_4)
- **C5 forward (Walk A)**: CounterexampleElimination.lean:818-904 (uses lemma_2_4)
- **C5 forward (Walk B)**: CounterexampleElimination.lean:905-1129 (uses lemma_2_6/2_7/2_8)
- **C5 forward (not cond i)**: CounterexampleElimination.lean:1130-1299 (uses lemma_2_6/2_7/2_8)
- **C4 forward**: CounterexampleElimination.lean:1913-2165 (uses lemma_2_6_splitting)
- **Density**: CounterexampleElimination.lean:2405-2578 (uses lemma_2_6_splitting)
- **lemma_2_6_splitting**: PointInsertion.lean:2798 (B ⊆ B', B ⊆ D, B ⊆ B'')
- **lemma_2_7**: PointInsertion.lean:3616 (DC({xi}) ⊆ B', B ⊆ D, B ⊆ B'')
- **lemma_2_8**: PointInsertion.lean:4098 (B ⊆ B', B ⊆ D, B ⊆ B'')
- **burgessR3Maximal_extension_exists**: RRelation.lean:760 (S ⊆ B output)
- **burgessR3_absorption**: RRelation.lean:591 (Lemma 2.5)
- **limit_g**: ChronicleConstruction.lean:845
- **limit_c3_interval_subset_point**: ChronicleConstruction.lean:888
- **FUC sorry**: ChronicleToCountermodel.lean:634
- **FSC sorry**: ChronicleToCountermodel.lean:638

## Effort Estimate

- Proving B = B' ∩ D ∩ B'' (absorption equality): 3-4 hours
- Adding C3 to EliminationResult and proving for each case: 4-6 hours  
- Threading C3 through omega chain: 1-2 hours
- Proving guard propagation + limit_satisfies_c5_strong: 2-3 hours
- Closing FUC/FSC: 2-3 hours
- Total: 12-18 hours (significantly more than the plan's 8-10 hours for Phases 2-5)

## Alternative: Plan Revision Recommended

Given the structural gap, I recommend running `/revise` on the plan to:
1. Account for the C3 maintenance requirement
2. Restructure Phases 2-4 around the absorption equality proof
3. Consider whether a weaker property suffices (e.g., tracking a specific f-value invariant instead of full C3)

The current plan's approach (A/B) assumes that guard propagation "may follow from c2' + absorption" without needing full C3. This is incorrect because lemma_2_7's left g-value doesn't preserve the old B.
