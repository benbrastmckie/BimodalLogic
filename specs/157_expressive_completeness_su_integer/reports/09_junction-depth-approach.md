# Junction-Depth Approach: Eliminating 8 Temporal Closure Axioms

## Executive Summary

The 8 axioms in `SeparationThm.lean` assert that temporal operators preserve separability. The circular dependency described in the Phase 6 handoff is REAL but not as severe as estimated. This report identifies the **simplest viable path**: a single well-founded induction on `junction_depth` that simultaneously proves all 4 weak temporal closure lemmas (and by mirroring, all 4 proper ones).

**Recommended approach**: Replace `all_separable` with a proof by well-founded induction on `junction_depth`, which handles all temporal cases uniformly. Estimated LOC: 400-600 (versus the 1200-1500 previously estimated).

---

## 1. What `is_syntactically_separated` Actually Checks

From `Defs.lean` (lines 130-138):

```lean
def is_syntactically_separated : Formula -> Bool
  | .atom _ => true
  | .bot => true
  | .imp phi psi => is_syntactically_separated phi && is_syntactically_separated psi
  | .box _ => true
  | .all_past phi => is_U_free phi
  | .all_future phi => is_S_free phi
  | .untl phi psi => is_S_free phi && is_S_free psi
  | .snce phi psi => is_U_free phi && is_U_free psi
```

**Key observations**:

1. A separated formula MAY contain `untl` (if its args are S-free) and MAY contain `snce` (if its args are U-free). It is a boolean combination of:
   - Atoms and bot (present)
   - `untl`/`all_future` with S-free args (future)
   - `snce`/`all_past` with U-free args (past)

2. `all_past phi` is separated iff `is_U_free phi = true` (phi contains NO `untl` anywhere).
3. `all_future phi` is separated iff `is_S_free phi = true` (phi contains NO `snce` anywhere).
4. `snce phi psi` is separated iff BOTH phi and psi are U-free.
5. `untl phi psi` is separated iff BOTH phi and psi are S-free.

---

## 2. Whether the Problematic Patterns Actually Arise

### The blocker IS real

Consider proving `snce_separable`:
- Given: `is_separable phi`, `is_separable psi`
- Get: separated `phi'` equiv to `phi`, separated `psi'` equiv to `psi`
- Form: `.snce phi' psi'`
- Need: `is_separable (.snce phi' psi')`

Since `phi'` is separated, it CAN contain `untl` subformulas (at top-level boolean positions). For example, `phi' = .untl p q` is separated (with S-free args). Then `.snce (.untl p q) psi'` requires `is_U_free (.untl p q) = false` -- NOT separated directly. We must eliminate the `untl` from under the `snce`.

This is exactly the "U-under-S" problem. The elimination Cases 1-8 handle this for a SINGLE U-formula type. After elimination, U appears only at top level (not under S).

### The circular dependency IS real

To prove `all_future_separable`:
- Given: `is_separable phi`
- Get: separated `phi'`
- Form: `.all_future phi'`
- Need: `is_S_free phi' = true` for direct separation

But `phi'` may contain `snce` (at top-level boolean positions). Must eliminate S from under `all_future`. The base case for S-elimination involves S-free formulas containing U (like `all_future (untl A B)`), which needs `untl_separable` to separate.

And `untl_separable` in turn needs `all_future_separable` for similar reasons.

### WHY junction_depth resolves the circularity

The `junction_depth` mutual definition (Defs.lean lines 203-236) measures the maximum alternation nesting:
- `junction_depth (.untl phi psi)` uses `junction_depth_U` on args, which ADDS 1 when encountering `snce`
- `junction_depth (.snce phi psi)` uses `junction_depth_S` on args, which ADDS 1 when encountering `untl`

When we take separated `phi'` and put it under `snce`, the problematic `untl` subformulas have junction_depth_U = 0 (no S under them, since they have S-free args in a separated formula). After elimination, the result has LOWER junction_depth.

Similarly, taking separated `phi'` and putting it under `all_future`, the problematic `snce` subformulas have junction_depth_S = 0 (no U under them). After elimination, lower junction_depth.

The KEY insight: **in a syntactically separated formula, all temporal subformulas have junction_depth 0 for cross-type nesting**. So `.snce (separated) (separated)` has junction_depth at most 1, and elimination always reduces to junction_depth 0.

---

## 3. The Simplest Viable Proof Strategy

### Strategy: Combined theorem by WF induction on junction_depth

Replace the current `all_separable` (which uses axioms for temporal cases) with a proof by well-founded induction on `junction_depth`. The proof DOES NOT need the full GHR94 hierarchy (Lemmas 10.2.4-10.2.8) because:

- We are NOT proving a standalone `snce_separable` that works for arbitrary formulas
- We are proving `all_separable` directly, where the IH gives us separated equivalents for subformulas
- The junction_depth of the recomposed formula is bounded by the original

### Detailed Proof Sketch

```lean
theorem all_separable (phi : Formula) : is_separable phi := by
  -- Well-founded induction on junction_depth
  have := phi.junction_depth  -- the measure
  induction phi using WellFounded.induction (measure_wf junction_depth) with
  ...
```

Wait -- this won't work directly because `junction_depth` of subformulas isn't necessarily smaller. We need structural induction COMBINED with junction_depth on the recomposed formula.

### Revised Strategy: Structural induction + helper lemmas

The actual approach that works:

**Step 1**: Prove the "one-step elimination" lemmas:
```lean
-- If phi is U-free (may contain S), then all_future phi is separable
theorem all_future_U_free_separable (phi : Formula) (h : is_U_free phi = true) : 
    is_separable (.all_future phi)

-- If phi is S-free (may contain U), then all_past phi is separable  
theorem all_past_S_free_separable (phi : Formula) (h : is_S_free phi = true) :
    is_separable (.all_past phi)

-- If phi, psi are U-free, then snce phi psi is separable
theorem snce_U_free_separable (phi psi : Formula) 
    (h1 : is_U_free phi = true) (h2 : is_U_free psi = true) :
    is_separable (.snce phi psi)

-- If phi, psi are S-free, then untl phi psi is separable
theorem untl_S_free_separable (phi psi : Formula)
    (h1 : is_S_free phi = true) (h2 : is_S_free psi = true) :
    is_separable (.untl phi psi)
```

**Step 2**: Prove temporal closure for SEPARATED arguments:
```lean
-- Key lemma: snce of separated formulas is separable
theorem snce_of_separated (phi psi : Formula)
    (h1 : is_syntactically_separated phi = true) 
    (h2 : is_syntactically_separated psi = true) :
    is_separable (.snce phi psi)
```

This is the CORE lemma. The proof:
1. If `phi` and `psi` are already U-free: trivially separated (existing `snce_U_free_separable`)
2. If they contain `untl` subformulas: these `untl` have S-free args (by separation)
3. Apply `abstract_untl` to replace each `untl` subformula with a fresh atom
4. The result is U-free (hence `snce (abstracted phi) (abstracted psi)` is separated)
5. Substitute back using `abstract_untl_correct`
6. The substituted formula has `untl (S-free) (S-free)` in the positions -- which ARE separated terms
7. The final formula is separable (composition of separated terms via substitution)

But wait -- step 7 needs `subst_atom_separable` (substituting a separated formula for an atom in a separated formula gives a separable formula). Is THIS provable without circularity?

### The Substitution Re-separation Problem

```lean
theorem subst_atom_separable (psi : Formula) (p : Atom) (repl : Formula)
    (h_sep_psi : is_syntactically_separated psi = true)
    (h_sep_repl : is_syntactically_separated repl = true) :
    is_separable (subst_formula psi p repl)
```

This ISN'T generally true! If `psi` has `p` inside an S-argument and `repl` contains U, substitution creates U-under-S.

However, in our specific case:
- `psi` is the ABSTRACTED formula (U-free after abstraction)
- `repl` is `untl A B` where A, B are S-free (from the original separated formula)

So `subst_formula psi p (.untl A B)` introduces `untl` only where `p` appeared in `psi`. Since `psi` is separated + U-free, the atom `p` appears:
- At top level (under `imp`): substituting gives `untl A B` at top level, which IS separated
- Inside `snce` args (under U-free constraint): atom p appears here. After substitution, `snce (... (untl A B) ...) (...)`. This has U-under-S! This IS the problematic case.

So the substitution approach DOES require handling U-under-S... but only for a SINGLE `untl` type (the one we substituted), and the S-nesting depth is exactly 1.

### The Resolution: Direct application of Cases 1-4

The critical observation for the simplest path:

After substituting `untl A B` for atom `p` in the U-free separated formula `psi`:
- `psi` has `p` appearing only in positions allowed by separation + U-freeness:
  - At `imp` positions (top-level boolean)
  - Inside `snce` args (since `psi` is separated, `snce` args are U-free, and `p` is an atom, so it can appear there)
  - Inside `all_past` args (since `is_U_free` allows atoms, and `all_past phi` in separated requires `is_U_free phi`)
  - NOT inside `untl` or `all_future` args (psi is U-free, so no untl; and `all_future phi` requires `is_S_free phi` which allows atoms)

Actually wait -- psi IS U-free (from abstraction). So:
- `psi` has no `untl` nodes
- `psi` IS separated
- U-free + separated = atoms + bot + imp + box + all_past(U-free) + all_future(S-free) + snce(U-free, U-free)
- But since psi is U-free: no untl at all. So psi = atoms + bot + imp + box + all_past(U-free) + all_future(S-free ∩ U-free) + snce(U-free, U-free)

After substituting atom p with `.untl A B` (S-free A, B):
- At `imp` position: `untl A B` at top level is separated -- fine
- Inside `all_future` args: `all_future(... untl A B ...)` -- the arg WAS S-free AND U-free, after substitution it contains untl but is still S-free (since A,B are S-free). So `all_future(still-S-free)` is separated!
- Inside `all_past` args: `all_past(... untl A B ...)` -- the arg WAS U-free, after substitution it contains untl, so NOT U-free. NOT separated. Must eliminate.
- Inside `snce` args: `snce(... untl A B ..., ...)` -- args were U-free, after substitution they contain untl. NOT separated. Must eliminate.

So the problematic positions are:
1. atom p inside `all_past` args
2. atom p inside `snce` args

For case (2): `snce(C[untl A B/p], D[untl A B/p])` where C, D were U-free+S-free (they appeared as snce args in a separated+U-free formula, so they must be U-free; and snce args in separated require U-free). After substitution: C has untl but no snce (original was S-free since it was inside all_future? No -- snce args don't need to be S-free, they need to be U-free). Let me re-examine.

Actually, in a U-free separated formula `psi`:
- `snce` nodes require U-free args (from `is_syntactically_separated`). Since psi is already U-free, this is automatic.
- The snce args are U-free. They may or may not be S-free.

After substituting p with `untl A B`:
- snce args become not-U-free (they now contain untl A B)
- This is exactly the situation Cases 1-8 handle!
- Moreover, it's a SINGLE U-formula type (untl A B) at top level in the S-arguments
- This is EXACTLY Lemma 10.2.4's setup

And Lemma 10.2.4 IS provable using Cases 1-4 + Cases 5-8. Cases 5-8 are currently proved via `all_separable` (which uses the axioms). But we can use a DIFFERENT argument here.

### The Key Simplification: cases 5-8 have junction_depth 0

In our specific substitution scenario, the `snce` containing `untl A B` has:
- S-args that are U-free EXCEPT for the single `untl A B`
- The `untl A B` has S-free args (A, B are S-free by hypothesis)
- `junction_depth (.snce (C[untl A B/p]) (D[untl A B/p]))`:
  - Uses `junction_depth_S` on the args
  - `junction_depth_S (.untl A B) = 1 + max (junction_depth A) (junction_depth B)`
  - Since A, B are S-free AND U-free (from original separated formula), `junction_depth A = junction_depth B = 0`
  - So `junction_depth_S (.untl A B) = 1`
  - Overall junction_depth of snce = max of junction_depth_S of args = 1

Meanwhile, the ORIGINAL formula `phi` that we're proving separable -- if it had junction_depth > 1, the substituted formula has junction_depth exactly 1 (regardless of original). If original had junction_depth = 1, substituted also has junction_depth 1. If original had junction_depth 0, it was already separated.

This means WE DON'T NEED full WF induction on junction_depth for the main theorem. We need junction_depth induction only for the HELPER that handles junction_depth = 1.

### Simplest Path: Prove separability for junction_depth <= 1

For formulas with `junction_depth = 0`: These are formulas where U never appears under S and S never appears under U. They are already separated (or trivially separable). This needs a proof.

For formulas with `junction_depth = 1`: These have at most one level of cross-nesting. This is exactly the case that Cases 1-4 handle (for the S-over-U direction), plus the existing dual/hierarchy infrastructure.

**Actually, the simplest approach is to prove `separated_implies_separable_under_temporal`**:

```lean
-- If phi is separated, then all_past phi, all_future phi, snce phi psi, untl phi psi
-- are separable (for separated psi).
-- This replaces all 4 weak temporal closure axioms.
```

The proof for each:
1. `snce (sep phi) (sep psi)`: abstract out all untl from phi, psi. Result is U-free snce (directly separated). Substitute back. Each substitution introduces exactly one untl type in snce-args. Apply Cases 1-4 (or Lemma 10.2.4 which is already proved) for each.
2. `untl (sep phi) (sep psi)`: dual. abstract out all snce. Result is S-free untl (directly separated). Substitute back. Apply dual cases. BUT dual cases have sorry!
3. `all_past (sep phi)`: if phi is U-free, directly separated. Otherwise abstract untl, get U-free all_past (separated!), substitute back. Similar to case 1.
4. `all_future (sep phi)`: dual to case 3.

### The Dual Problem

Cases 1-8 handle "U out of S" (eliminating untl from under snce). Their duals handle "S out of U" (eliminating snce from under untl). The dual cases in `DualEliminations.lean` are ALL sorry.

This means the `untl_separable` and `all_future_separable` directions CANNOT be proved without either:
(a) Proving the dual elimination cases, OR
(b) Using duality (swap_temporal) to derive them from the primary cases

Option (b) is the correct approach. The duality infrastructure exists in `Duality.lean`:
- `swap_temporal_int_truth`: truth under swap is truth in reversed structure
- `dual_separated`: separation preserved by swap

The approach for `untl_separable`:
1. `untl phi psi` where phi, psi are separable
2. `swap_temporal (untl phi psi) = snce (swap phi) (swap psi)`
3. swap of separable is separable (need to prove this)
4. `snce (swap phi') (swap psi')` is separable (by the snce direction, already proved)
5. swap back: `untl phi psi` equiv to swap(snce(swap phi')(swap psi'))
6. swap of separable is separable => done

Step 3 requires: `swap_temporal` of a separated formula is separated. This follows from `dual_separated` which should already exist.

Let me verify the duality chain works.

---

## 4. Concrete Implementation Plan

### Step 1: Prove `swap_separable` (if not already proved)

```lean
theorem swap_separable {phi : Formula} (h : is_separable phi) : 
    is_separable phi.swap_temporal
```

Using: `dual_separated` (swap preserves is_syntactically_separated) + `swap_temporal_int_truth` (equiv preserved under swap).

### Step 2: Prove `snce_of_separated`

```lean
theorem snce_of_separated (phi psi : Formula)
    (h1 : is_syntactically_separated phi = true)
    (h2 : is_syntactically_separated psi = true) :
    is_separable (.snce phi psi)
```

Proof sketch:
- If both phi, psi are U-free: trivially `⟨.snce phi psi, by simp [...], int_equiv_refl _⟩`
- Otherwise: use `abstract_untl` for each untl-type in phi and psi (one at a time), producing a U-free formula
- The abstracted formula `snce (abs_phi) (abs_psi)` is separated (U-free args)
- `abstract_untl_correct` gives the semantic equivalence
- Need: separable after re-substitution (this is Lemma 10.2.4 applied iteratively)

For the re-substitution: after abstracting ALL untl-types, we have `snce (U-free phi') (U-free psi')` which is separated. The substitution of each fresh atom back with `untl A_i B_i` (S-free args) creates U-under-S at junction_depth 1. Apply Lemma 10.2.4 (already proved, via event-splitting + Cases 1-4 + Cases 5-8-via-all_separable).

**PROBLEM**: Cases 5-8 are currently proved via `all_separable` which USES the axioms. This is circular if we're trying to ELIMINATE the axioms.

### The Actual Minimal Path: Prove Cases 5-8 independently or avoid them

Looking at the codebase more carefully:
- `case5_separable` through `case8_separable` in NormalForm.lean use `all_separable _`
- `all_separable` in SeparationThm.lean uses the temporal closure AXIOMS
- The temporal closure axioms are what we want to eliminate

So to eliminate the axioms, we need Cases 5-8 proved WITHOUT `all_separable`. But Report 08 shows Cases 5-8 are circularly dependent when proved standalone.

### Resolution: The junction_depth WF induction IS needed

The correct minimal approach is:

```lean
theorem all_separable' : (phi : Formula) -> is_separable phi := by
  intro phi
  -- Well-founded induction on junction_depth
  apply WellFoundedRecursion ...
```

Where the induction hypothesis gives `is_separable psi` for all `psi` with `junction_depth psi < junction_depth phi`. The key cases:

- `snce phi psi` at junction_depth n:
  - IH gives separated phi', psi' for phi, psi (which have junction_depth < n... NO, subformulas don't have lower junction_depth necessarily)

This doesn't work directly because `junction_depth (snce phi psi) = max (junction_depth_S phi) (junction_depth_S psi)` and the components phi, psi can have HIGHER junction_depth.

### FINAL RESOLUTION: Structural induction IS sufficient, but need mutual lemmas

The correct approach that avoids all circularity:

**Observation**: The theorem `all_separable` currently works perfectly by structural induction on the formula. The ONLY thing preventing it from being axiom-free is that the temporal cases (`snce`, `untl`, `all_past`, `all_future`) need to show that "if my subformulas are separable, then I am separable." This is EXACTLY what the temporal closure axioms state.

The temporal closure axioms can be proved if we use a DIFFERENT induction measure for their proofs -- one that decreases across the "get separated equiv, then eliminate cross-nesting" operation.

**The correct measure**: For proving `snce_separable` (given separated phi', psi'), the formula `snce phi' psi'` has a specific junction_depth. After applying elimination cases, the resulting formula has LOWER junction_depth. We can prove this by well-founded induction on junction_depth.

But the base case (junction_depth = 0) of snce means the args are already U-free -- trivially separated. And junction_depth 1 means single-level cross-nesting, handleable by Cases 1-4 alone (since the U-args are S-free in a separated formula).

**CRITICAL INSIGHT**: For a separated formula phi' placed as arg of snce, any `untl A B` subformula in phi' has S-free A, B (because phi' is separated: `is_syntactically_separated` requires S-free args for untl). So after forming `snce phi' psi'`:
- Each U-subformula (untl A B) has S-free args
- These U-subformulas are at "top level" w.r.t. other S-operators (since phi' is separated, any snce in phi' has U-free args, so no untl appears under snce within phi')
- This means: `no_S_nested_in_U (.snce phi' psi')` is TRUE when phi', psi' are separated!

Wait, let me verify: `no_S_nested_in_U (.snce phi' psi')` requires that under every `untl` node, args are S-free. In `.snce phi' psi'`, the untl nodes are inside phi' or psi'. Since phi' is separated, its untl nodes have S-free args. Same for psi'. So YES: `no_S_nested_in_U (.snce phi' psi') = True`.

And `multi_U_formula_separable` already exists:
```lean
theorem multi_U_formula_separable (phi : Formula) (h : no_S_nested_in_U phi) :
    is_separable phi := all_separable phi
```

This currently uses `all_separable` (which uses axioms). But if we can prove `multi_U_formula_separable` WITHOUT axioms, we're done!

### Can `multi_U_formula_separable` be proved without axioms?

`no_S_nested_in_U phi` means: every `untl` in phi has S-free args. This does NOT mean phi is already separated -- it might have `snce` nodes whose args contain `untl` (just not under another S).

For `no_S_nested_in_U phi` to be separable:
- The `snce` nodes need U-free args for separation
- But `snce` args might contain `untl` (just with S-free args, satisfying the predicate)
- We need to eliminate these `untl` from inside `snce` args

This is EXACTLY what the hierarchy (Lemmas 10.2.4-10.2.6) does. And Cases 5-8 appear when we apply the elimination.

**However**, in our specific scenario, the formula is `snce phi' psi'` where phi', psi' are separated. The `untl` nodes in phi' have S-free args, AND they are NOT under any `snce` within phi' (because within phi', snce args must be U-free, which excludes untl). So the untl nodes in phi' are at "S-nesting depth 0" relative to the outer snce -- they are directly in phi' at boolean-combination level.

This means the `snce phi' psi'` formula has untl nodes DIRECTLY inside the snce args (not under nested snce). This is exactly Lemma 10.2.4's setup: a single S with U at top level (not under nested S). And Lemma 10.2.4 IS proved (using Cases 1-4 for the positions where U appears only in event or only in guard).

The remaining question: does event-splitting always reduce to Cases 1-4, or do Cases 5-8 appear?

Cases 5-8 appear when U is in BOTH event and guard of the same S. In our formula `snce phi' psi'`:
- phi' = event, psi' = guard
- If untl A B appears in BOTH phi' and psi', that's Cases 5-8 territory

Can the same `untl A B` appear in both separated phi' and psi'? YES -- nothing prevents `phi' = untl p q` and `psi' = untl p q`. Then `snce (untl p q) (untl p q)` hits Case 5.

SO: Cases 5-8 ARE needed, and they DO create the circular dependency as documented.

---

## 5. THE Simplest Viable Path (Final Answer)

Given the analysis above, the truly simplest path is a **staged bootstrap with duality**:

### Approach A: Junction-depth mutual WF induction (~400-600 LOC)

Define a SINGLE theorem:
```lean
theorem temporal_closure_jd (phi : Formula) :
    (forall psi, junction_depth psi < junction_depth phi -> is_separable psi) ->
    is_separable phi
```

Then use `WellFounded.fix` on `junction_depth` to get `all_separable`.

The junction_depth argument works because:
- `junction_depth (.snce phi' psi')` where phi', psi' are separated = max over junction_depth_S of phi' and psi'
- `junction_depth_S` of a separated formula: for untl nodes (which have S-free args), `junction_depth_S (untl A B) = 1 + max (junction_depth A) (junction_depth B)`. Since A, B are S-free AND appear in a separated formula's untl-args (so S-free, and they're subformulas of the original), their junction_depth might not be smaller.

Actually, this approach has the same problem: junction_depth of the RECOMPOSED formula isn't necessarily smaller than the original.

### Approach B: Strengthened structural induction (~400-500 LOC, RECOMMENDED)

Prove a STRONGER theorem by structural induction that avoids needing temporal closure as separate lemmas:

```lean
/-- Every formula is separable. The proof uses structural induction where
    temporal cases use the `no_S_nested_in_U` + `no_U_nested_in_S` properties
    of separated formulas, combined with the already-proved elimination Cases 1-4
    and duality. -/
theorem all_separable' (phi : Formula) : is_separable phi := by
  induction phi with
  | atom a => exact ⟨.atom a, rfl, int_equiv_refl _⟩
  | bot => exact ⟨.bot, rfl, int_equiv_refl _⟩
  | imp phi psi ih1 ih2 => exact imp_separable ih1 ih2
  | box phi _ih => exact ⟨.box phi, rfl, int_equiv_refl _⟩
  | all_past phi ih => exact all_past_sep_helper phi ih
  | all_future phi ih => exact all_future_sep_helper phi ih
  | untl phi psi ih1 ih2 => exact untl_sep_helper phi psi ih1 ih2
  | snce phi psi ih1 ih2 => exact snce_sep_helper phi psi ih1 ih2
```

Where `snce_sep_helper` does:
1. Get separated phi', psi' from ih1, ih2
2. Form `snce phi' psi'` (equiv to `snce phi psi`)
3. Note: phi' separated => all untl in phi' have S-free args
4. Abstract ALL untl-types from phi' and psi' using `abstract_untl` iteratively (or multi-abstract)
5. Result: `snce (U-free-phi'') (U-free-psi'')` which IS separated
6. For semantic equivalence: use `abstract_untl_correct` chain
7. Substitute back: need `subst_preserves_separability_in_this_context`
8. The key: after substituting each `untl A_i B_i` back, it appears at junction_depth 1
9. Prove separability of the substituted formula by...

This is where we get stuck again. Substituting back requires proving the result is separable, which requires Cases 5-8 for the "U in both event and guard" scenarios.

### Approach C: Accept DualEliminations.sorry and prove weak closure only (~200 LOC)

For the WEAK temporal closure axioms (`is_separable`-based, not `is_properly_separable`):
- `snce_separable` and `all_past_separable` need "U out of S" (primary direction, Cases 1-8 available via `all_separable`)
- `untl_separable` and `all_future_separable` need "S out of U" (dual direction, DualEliminations has sorry)

If we prove only the S-direction axioms (`snce_separable`, `all_past_separable`) and derive the U-direction (`untl_separable`, `all_future_separable`) by duality, the duality proof needs `swap_temporal` preserving separability.

The duality approach:
```lean
theorem untl_separable (phi psi : Formula) (h1 : is_separable phi) (h2 : is_separable psi) :
    is_separable (.untl phi psi) := by
  -- swap_temporal(.untl phi psi) = .snce (swap phi) (swap psi)
  -- swap of separable is separable (via dual_separated)
  -- snce_separable gives separability of swap result
  -- swap back preserves separability
  ...
```

This requires the `snce_separable` direction to be proved axiom-free, which still needs Cases 5-8.

### Approach D: THE ACTUAL SIMPLEST PATH -- Use `all_separable` itself as the WF measure

**THE KEY INSIGHT I MISSED**: The current proof structure already works! The axioms CAN be eliminated by a single well-founded induction because:

The theorem `all_separable` by structural induction is CORRECT -- it terminates because Lean's structural recursion on the `Formula` inductive type is well-founded. The temporal cases call `snce_separable` etc., which need to show that `snce (of-subformula) (of-subformula)` is separable.

But `snce_separable` as stated takes ARBITRARY separable formulas, not just subformulas. The trick is to NOT prove `snce_separable` as a standalone lemma. Instead, prove `all_separable` directly with the temporal cases INLINED.

For `| snce phi psi ih1 ih2`:
1. ih1 : is_separable phi (from structural IH -- phi is a subformula!)
2. ih2 : is_separable psi (from structural IH -- psi is a subformula!)
3. Get separated phi', psi'
4. `snce phi' psi'` is equiv to `snce phi psi`
5. Need: `is_separable (.snce phi' psi')`

The formula `.snce phi' psi'` is NOT a subformula of the original `snce phi psi` (it could be much larger!). So structural IH doesn't apply to it.

We need an EXTERNAL argument that `.snce phi' psi'` is separable, using ONLY the fact that phi', psi' are separated. This argument IS the content of the temporal closure axiom. We cannot avoid it.

### FINAL VERDICT: The junction_depth WF induction is needed

There is no way to avoid a well-founded induction argument. The structural IH does not suffice because the recomposed formula can be larger. The junction_depth (or similar combined measure) provides the necessary decreasing quantity.

**The recommended implementation**:

```lean
-- Strengthen the IH: prove separability for all formulas of junction_depth < n simultaneously
theorem all_separable_aux : (n : Nat) -> (forall phi, junction_depth phi <= n -> is_separable phi) := by
  intro n
  induction n with
  | zero => ... -- junction_depth 0 means no cross-nesting; these are easy
  | succ k ih => ... -- use ih for junction_depth <= k
```

For junction_depth 0: formula has no U-under-S and no S-under-U. It might contain both U and S but never nested inside each other. Such formulas are boolean combinations of atoms, U-with-S-free-args, S-with-U-free-args, all_past-of-U-free, all_future-of-S-free. These are EXACTLY the syntactically separated formulas. So junction_depth 0 => already separated.

Wait -- that's not quite right. `junction_depth (.snce (.untl p q) r) = junction_depth_S (.untl p q) = 1 + ...`. So any formula with U-under-S or S-under-U has junction_depth >= 1.

Actually, let me re-read the definition:
```
junction_depth (.snce phi psi) = max (junction_depth_S phi) (junction_depth_S psi)
junction_depth_S (.untl phi psi) = 1 + max (junction_depth phi) (junction_depth psi)
```

So `junction_depth (.snce (.untl p q) r) = max (junction_depth_S (.untl p q)) (junction_depth_S r) = max (1 + 0) 0 = 1`.

And `junction_depth (.untl p q) = max (junction_depth_U p) (junction_depth_U q) = max 0 0 = 0` (since p, q have no snce under them to increment junction_depth_U).

So: junction_depth 0 formulas have no cross-nesting at all. They are exactly the separated formulas (modulo the boolean-combination structure).

Hmm, that's not quite right either. `junction_depth (.imp (.snce p q) (.untl r s)) = max (junction_depth (.snce p q)) (junction_depth (.untl r s)) = max 0 0 = 0`. This formula has both S and U but not nested, so junction_depth 0. And it IS separated (imp of separated components).

**Junction_depth 0 => is_syntactically_separated = true** -- this needs a proof (~50 LOC), but should be straightforward by mutual induction.

For the inductive step (junction_depth n+1):
- Apply structural induction on the formula
- For temporal cases (snce phi psi), get separated equivalents phi', psi' using the outer structural IH on subformulas
- Form `snce phi' psi'` -- this has junction_depth <= the junction_depth of the cross-nesting in phi', psi'
- But phi', psi' are separated (junction_depth 0), so `junction_depth_S` of components in phi' that are untl: `junction_depth_S (.untl A B) = 1 + max (jd A) (jd B)`. Since A, B are S-free (from separation), they have no snce, so `junction_depth A = junction_depth B = 0` (no snce nodes means junction_depth_S is irrelevant, and the base junction_depth just propagates through). So `junction_depth_S (.untl A B) = 1`.
- Therefore `junction_depth (.snce phi' psi') <= 1`.
- We need to prove formulas with junction_depth <= 1 are separable.
- For junction_depth 1: apply the elimination cases (abstract out the offending U subformulas, eliminate via Cases 1-4, check that Cases 5-8 situation can be handled at this level)

At junction_depth 1, after applying the elimination cases (which produce formulas with U at "top level" not under S), the result has junction_depth 0 -- hence is separated by the base case.

**BUT**: Cases 5-8 at junction_depth 1 involve U in both event AND guard of a single S. After elimination (using neg_until_equiv to expand negU), we get a formula with junction_depth... still 1? or 0?

The neg_until_equiv expansion: `not U(A,B) <-> G(notA) v U(notA^notB, notA)`. The result U(A', B') where A'=notA^notB, B'=notA -- these are U-free and S-free (since A, B were). So this new U has S-free args.

After expanding in a Case 5 formula `S(a ^ U(A,B), q v U(A,B))`:
- Using Case 3 semantics: we get formulas where U(A,B) has been moved to top level in various forms
- But this uses neg_until_equiv which introduces ANOTHER U-formula type
- Two U-types under one S: `junction_depth_S` for either is 1, so overall junction_depth is still 1

The junction_depth doesn't decrease across Case 5-8 reductions! This is exactly why GHR94 uses the full hierarchy with the compound measure.

---

## 6. FINAL Recommendation

After thorough analysis, the simplest viable approach requires:

### Minimum Viable Path: Abstract-then-Substitute with WF on `(count_U_subformulas_under_S, sizeOf)`

**Total estimated LOC: 500-700 across 2 new files + modifications**

**Core insight**: Instead of eliminating axioms one-by-one, prove a SINGLE master lemma:

```lean
/-- A separated formula wrapped in a temporal operator is separable.
    Proved by WF induction on the "cross-nesting complexity" of the result. -/
theorem separated_under_temporal_is_separable (phi : Formula) 
    (h : no_S_nested_in_U phi) : is_separable phi
```

Then `snce_separable`, `untl_separable`, etc. follow immediately since:
- `snce (separated phi') (separated psi')` satisfies `no_S_nested_in_U` (untl args in separated formulas are S-free)
- `untl (separated phi') (separated psi')` satisfies the dual

The WF induction on `count_U_subformulas` (already defined):
- Base (count=0): phi is U-free. Need `is_separable phi` for U-free phi.
  - Sub-case: phi also S-free => separated trivially
  - Sub-case: phi has S but no U. Like `all_future (snce p q)` -- needs S elimination
  - **THIS is where the dual problem lives**

**The dual is unavoidable**. The U-direction and S-direction must be proved simultaneously.

### Recommended Final Strategy

**Mutual WF induction on `junction_depth`**:

```lean
mutual
theorem u_elim (phi : Formula) (h : no_S_nested_in_U phi) : is_separable phi := ...
theorem s_elim (phi : Formula) (h : no_U_nested_in_S phi) : is_separable phi := ...
end
```

Each calls the other at strictly lower junction_depth. This works because:
- `u_elim` handles U-under-S: after abstracting U-subterms and applying Cases 1-4 (and Cases 5-8 via the compound measure), produces formulas with NO U-under-S but potentially S-under-U at lower depth
- `s_elim` (dual): after abstracting S-subterms and applying dual Cases 1-4, produces formulas with no S-under-U but potentially U-under-S at lower depth
- They call each other, but junction_depth strictly decreases

**Implementation breakdown**:

| Component | LOC | Status |
|-----------|-----|--------|
| `no_U_nested_in_S` predicate + helpers | 50 | New |
| `abstract_snce` (dual of abstract_untl) | 100 | New |
| `abstract_snce_*` preservation lemmas | 150 | New |
| `junction_depth_decrease` proofs | 100 | New |
| `u_elim` theorem | 100 | New (uses existing Cases 1-4 + hierarchy) |
| `s_elim` theorem | 100 | New (uses duality on Cases 1-4) |
| Replace axioms in SeparationThm.lean | 50 | Modify |
| Remove DualEliminations.sorry | -150 | Can replace with duality call |
| **Total** | **~650** | |

### Why Cases 5-8 Are Not a Blocker for This Approach

In the mutual `u_elim`/`s_elim` approach, Cases 5-8 situations (U in both event AND guard) are resolved by:
1. The compound WF measure `(junction_depth, count_U_subformulas)` strictly decreases
2. After one application of abstract+substitute, at least one of these decreases
3. The abstract_untl approach reduces count_U while preserving junction_depth
4. Cases 1-4 reduce junction_depth while possibly increasing count
5. Lexicographic ordering ensures termination

The Cases 5-8 theorems in NormalForm.lean currently use `all_separable _` which IS the axiom-laden proof. In the new approach, they would be REPLACED by direct calls to `u_elim` (which has the WF argument built in).

---

## 7. Estimated LOC and Risk

| Approach | LOC | Risk | Axioms Eliminated |
|----------|-----|------|-------------------|
| Mutual WF induction (recommended) | 600-800 | Medium | All 8 |
| Junction-depth only (simpler but harder termination) | 800-1200 | High | All 8 |
| Abstract+Cases 1-4 only (partial) | 300-400 | Low | 4 (weak only) |
| Status quo (keep axioms) | 0 | None | 0 |

**Recommended**: The mutual WF approach (600-800 LOC). The DualEliminations.sorry values can be eliminated in the same pass, since `s_elim` subsumes them.

The proper-separation axioms (4 additional) follow from the weak ones by the same argument applied to `is_properly_separated` instead of `is_syntactically_separated`.
