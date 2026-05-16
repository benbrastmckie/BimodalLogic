# Teammate A Findings: Backward Analysis from Sorry Sites

**Task**: 154 - sum_preservation_ef_games
**Agent**: Backward-analysis agent
**Date**: 2026-05-15

## Executive Summary

All 4 sorry sites have identical structure. The gap is between **component-level** NF agreement and **ordered-sum-level** NF agreement. The existing `sum_nf_lift_gen` can close all 4 sorries IF we can construct `BiCompat`. The missing piece is a recursive helper `sum_bicompat_from_comp` that builds `BiCompat` from component equivalence with index-matched environments.

## Sorry Site Analysis

### Goal State (Identical Pattern for All 4)

All 4 sorry sites (lines 429, 451, 476, 496) produce goals of the same form:

```
⊢ ∃ x, nf_eval_nf (orderedSum sig I ms[']) k (0 + 1) (Fin.cons x Fin.elim0) sub_nf
```

The variations are:
| Sorry | Line | Case       | Target sum | Have eval in | Witness direction |
|-------|------|------------|-----------|--------------|-------------------|
| 1     | 429  | succ.mp.mp | ms        | ms' (hb_eval) | ms' → ms (find a from b) |
| 2     | 451  | succ.mp.mpr| ms'       | ms (ha_eval)  | ms → ms' (find b from a) |
| 3     | 476  | succ.mpr.mp| ms'       | ms (ha_eval)  | ms → ms' (find b from a) |
| 4     | 496  | succ.mpr.mpr| ms       | ms' (hb_eval) | ms' → ms (find a from b) |

### Available Hypotheses at Each Sorry Site

Each sorry site has the following in context (example from sorry 1, others are symmetric):

1. **IH** (`ih_k`): Ordered-sum depth-k sentence-level (n=0) NF agreement from component equivalence
2. **Component equivalence** (`h_comp`): `∀ m ≤ k+1, ∀ i, nf_eval_nf (ms i) ... ↔ nf_eval_nf (ms' i) ...` at sentence level
3. **Component witnesses** (`a`, `b`): Elements in `ms i` and `ms' i` respectively
4. **Component NF agreement** (`h_agree_comp`): `∀ nf', nf_eval_nf (ms i) k (0+1) (Fin.cons a Fin.elim0) nf' ↔ nf_eval_nf (ms' i) k (0+1) (Fin.cons b Fin.elim0) nf'`
5. **Ordered-sum eval** (`hb_eval` or `ha_eval`): One side already satisfies `sub_nf` in the ordered sum

### The Gap

The gap at every sorry site is:
- **Have**: `nf_eval_nf (orderedSum ms') k 1 (Fin.cons ⟨i,b⟩ Fin.elim0) sub_nf`
- **Have**: Component NF agreement: `(ms i, Cons a) ≡_k (ms' i, Cons b)` at 1 var
- **Need**: `nf_eval_nf (orderedSum ms) k 1 (Fin.cons ⟨i,a⟩ Fin.elim0) sub_nf`
- **Missing link**: Component-level NF agreement does NOT imply ordered-sum-level NF agreement

**Root cause**: At depth k > 0, the quantifier step introduces elements from ALL components of the ordered sum, not just component i. The resulting `AtomKind sig 2` includes order atoms `x_0 < x_1` which, when `x_0` and `x_1` are from different components, depend on the index comparison. Component-level agreement knows nothing about cross-component order relationships.

## Approach Analysis

### Approach 1: Use sum_nf_lift_gen (requires BiCompat construction)

**Confirmed working**: `sum_nf_lift_gen sig k 1 I ms ms' h_comp env_M env_N h_atoms h_bc sub_nf` type-checks and can close the sorry when `h_atoms` and `h_bc` are provided.

**h_atoms obligation** (SOLVED):
```
∀ a : AtomKind sig 1,
  atom_eval (orderedSum sig I ms) (Fin.cons ⟨i,a⟩ Fin.elim0) a ↔
  atom_eval (orderedSum sig I ms') (Fin.cons ⟨i,b⟩ Fin.elim0) a
```
This is closable because `AtomKind sig 1` has **no order atoms** (Fin 1 has no distinct pairs). Every atom is `.pred p 0`, and `orderedSum` interp at `⟨i,a⟩` reduces to `(ms i).interp p a`. The component NF agreement gives pred agreement via `atom_agreement_from_nf`.

Proof sketch (verified by lean_multi_attempt):
```lean
intro ak
obtain ⟨p, hp⟩ := atomKind_one_pred_only ak
subst hp
simp only [atom_eval, Fin.cons_zero, orderedSum]
have h_comp_atoms := atom_agreement_from_nf (ms i) (Fin.cons a Fin.elim0)
  (ms' i) (Fin.cons b Fin.elim0) h_agree_comp
exact h_comp_atoms (.pred p 0)
```

**h_bc obligation** (UNSOLVED -- the main blocker):
```
BiCompat sig k 1 I ms ms' (Fin.cons ⟨i,a⟩ Fin.elim0) (Fin.cons ⟨i,b⟩ Fin.elim0)
```

`BiCompat` unfolds recursively:
- Depth 0: `True` (trivial)
- Depth d+1, n vars: forward + backward oracle producing witnesses with `AtomKind sig (n+1)` agreement AND `BiCompat sig d (n+1)` at extended envs

For our case (d=k, n=1), BiCompat requires k levels of nesting, with env sizes growing from 1 to k+1. The total construction depth is k.

### Approach 2: Direct nf_agreement_from_shared_nf at ordered-sum level

**Fails**: Would require showing `nf_characteristic (orderedSum ms) k 1 (Fin.cons ⟨i,a⟩ ...) = nf_characteristic (orderedSum ms') k 1 (Fin.cons ⟨i,b⟩ ...)`, which IS the same as proving ordered-sum NF agreement -- circular.

### Approach 3: Use IH (ih_k) directly

**Fails**: `ih_k` operates at depth k with n=0 (sentence level). We need depth k with n=1. Type mismatch: `NormalForm sig k (0+1)` vs `NormalForm sig k 0`.

### Approach 4: Component-to-sum NF equivalence at n=1

At n=1, `AtomKind sig 1` has no order atoms, so ordered-sum evaluation and component evaluation agree for atomic formulas. However, at depth > 0, quantifiers introduce elements from all components with `AtomKind sig 2` order atoms that component evaluation cannot model. So the equivalence breaks at depth > 0.

**Conclusion**: This approach only works for depth 0. Not sufficient.

### Approach 5: Eliminate BiCompat by restructuring sum_nf_lift_gen

Replace BiCompat with index-matching + atom agreement as hypotheses (the original plan v5 approach before BiCompat was introduced). The IH step would need to BUILD atom agreement at n+1 from:
- atom agreement at n (existing)
- component conditional transfer (for the new witness)
- extend_atoms (already proved)

This avoids the recursive BiCompat predicate but requires the same recursive witness construction inside the IH step. The advantage is that the construction happens once inside `sum_nf_lift_gen` rather than needing a separate `BiCompat` builder.

**This is the most promising alternative**, effectively merging the BiCompat construction into sum_nf_lift_gen's induction step.

## Recommended Solution

### Primary Recommendation: Build `sum_bicompat_from_comp` helper

A new private recursive definition that constructs `BiCompat` from component equivalence:

```lean
private noncomputable def sum_bicompat_from_comp (sig : MonadicSignature) :
    ∀ (d n : Nat) (I : Type) [LinearOrder I]
    (ms ms' : I → OrderedMonadicStructure sig)
    (h_comp : ∀ m, m ≤ d + n → ∀ i, ∀ nf : NormalForm sig m 0,
      nf_eval_nf (ms i) m 0 Fin.elim0 nf ↔ nf_eval_nf (ms' i) m 0 Fin.elim0 nf)
    (env_M : Fin n → (orderedSum sig I ms).carrier)
    (env_N : Fin n → (orderedSum sig I ms').carrier)
    (h_idx : ∀ p : Fin n, (env_M p).1 = (env_N p).1)
    (h_atoms : ∀ a : AtomKind sig n,
      atom_eval (orderedSum sig I ms) env_M a ↔
      atom_eval (orderedSum sig I ms') env_N a),
    BiCompat sig d n I ms ms' env_M env_N
```

**Construction sketch** (by recursion on d):
- **d = 0**: `True` by definition
- **d + 1**: For each `j : I`, `c' : (ms' j).carrier`:
  1. Extract component-level depth-(d+n) r-var NF agreement for component j, where r = number of env elements in component j. This is done by iterating `component_extend_fwd` starting from component `(d+n+1)`-equiv.
  2. Use `component_extend_fwd` one more time with `c'` to find `c` in `ms j` with component NF agreement at the right depth and var count.
  3. From this component NF agreement, extract:
     - Pred agreement for c/c' (via `atom_agreement_from_nf` on component)
     - Order agreement within component j for c vs same-component env elements
  4. For cross-component env elements: order between `⟨j,c⟩` and `⟨idx_p, val_p⟩` with `j ≠ idx_p` is determined by index comparison. Since `h_idx` ensures `idx_p` is the same on both sides, the order is preserved.
  5. Apply `extend_atoms` to combine into ordered-sum atom agreement at n+1.
  6. Recursively call `sum_bicompat_from_comp` at depth d, n+1.

### Alternative Recommendation: Restructure sum_nf_lift_gen

Replace `BiCompat` parameter with `h_idx` + `h_atoms` and fold the witness construction into the IH step. This eliminates the need for a separate BiCompat builder but makes `sum_nf_lift_gen` more complex.

**Trade-off**: The BiCompat approach is more modular (clear separation of concerns) but requires more code. The merged approach is more compact but harder to maintain.

## Detailed Findings per Sorry Site

### Sorry 1 (line 429) - succ.mp.mp (Backward: ms' → ms)

**Context**: Have `⟨i, b⟩` in orderedSum ms' satisfying sub_nf. Found `a` in `ms i` via component transfer.

**Closing pattern**:
```lean
refine ⟨⟨i, a⟩, ?_⟩
have h_lift := sum_nf_lift_gen sig k 1 I ms ms'
  (fun m hm => h_comp m (by omega))
  (Fin.cons ⟨i, a⟩ Fin.elim0)
  (Fin.cons ⟨i, b⟩ Fin.elim0)
  h_atoms_1  -- proved via atomKind_one_pred_only + component NF agreement
  h_bc_1     -- BiCompat sig k 1, THE MISSING PIECE
exact (h_lift sub_nf).mpr hb_eval
```

### Sorry 2 (line 451) - succ.mp.mpr (Forward: ms → ms')

Same structure, but proving `∃ x ∈ orderedSum ms'`. Uses `.mp` instead of `.mpr`.

### Sorry 3 (line 476) - succ.mpr.mp (Forward: ms → ms')

Same as sorry 2, in the symmetric branch of the iff.

### Sorry 4 (line 496) - succ.mpr.mpr (Backward: ms' → ms)

Same as sorry 1, in the symmetric branch of the iff.

## Key Dependencies

| Component | Status | Location |
|-----------|--------|----------|
| `sum_nf_lift_gen` | Sorry-free | NEquivalence.lean:296-348 |
| `BiCompat` definition | Complete | NEquivalence.lean:160-180 |
| `component_extend_fwd` | Sorry-free | NEquivalence.lean:187-205 |
| `component_extend_bwd` | Sorry-free | NEquivalence.lean:208-226 |
| `extend_atoms` | Sorry-free | NEquivalence.lean:233-280 |
| `atomKind_one_pred_only` | Sorry-free | NEquivalence.lean:145-149 |
| `atom_agreement_from_nf` | Sorry-free | NormalForm.lean:315-326 |
| `nf_agreement_from_shared_nf` | Sorry-free | NormalForm.lean:291-306 |
| `sum_bicompat_from_comp` | **MISSING** | Needs creation |

## Complexity Assessment

**Estimated effort for `sum_bicompat_from_comp`**: 3-5 hours

The main complexity is in the witness construction at each BiCompat level:
1. Tracking which env elements share a component with the new witness (subset selection)
2. Iterating component_extend_fwd/bwd for same-component env elements
3. Establishing order agreement for cross-component env elements via Sigma.Lex reasoning
4. Combining into extend_atoms call
5. Recursive BiCompat construction with the extended environment

The `extend_atoms` helper already handles the atom combination, and `component_extend_fwd/bwd` handle the within-component transfer. The gap is the orchestration layer that:
- Classifies env elements by component membership
- Builds the component NF agreement chain
- Handles the cross-component order reasoning

## Alternative: n=1 Specialization

Since ALL 4 sorry sites call `sum_nf_lift_gen` at n=1, we could build a specialized `BiCompat` constructor that only works for n=1 environments. At n=1:
- The single existing env element is `⟨i, a⟩`/`⟨i, b⟩`
- For a new witness `⟨j, c⟩`/`⟨j, c'⟩`:
  - If j ≠ i: cross-component, order automatic from index comparison
  - If j = i: same-component, use component_extend_fwd

This is significantly simpler than the general case because we only track one existing element's component membership. But the RECURSIVE levels of BiCompat (depth k-1 at n=2, depth k-2 at n=3, ...) still need the general construction.

**However**: at each recursive level, we can observe that the new environments are STILL index-matched (we always pick witnesses in the same component as the query). So the recursive call can use the same construction pattern.

## Conclusion

The 4 sorry sites are all closable by the same mechanism: `sum_nf_lift_gen` + `BiCompat` construction. The h_atoms part is already solved. The sole remaining blocker is constructing `BiCompat sig k 1 I ms ms' (Fin.cons ⟨i,a⟩ Fin.elim0) (Fin.cons ⟨i,b⟩ Fin.elim0)`.

**Recommended next step**: Implement `sum_bicompat_from_comp` as a recursive helper that builds BiCompat from component equivalence with index-matched environments. This helper, combined with the already-proved `h_atoms` construction, closes all 4 sorry sites.
