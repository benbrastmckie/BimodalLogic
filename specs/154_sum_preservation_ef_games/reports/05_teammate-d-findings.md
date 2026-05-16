# Teammate D Findings: BiCompat Decomposition into Independent Lemmas

**Task**: 154 - sum_preservation_ef_games
**Date**: 2026-05-15
**Angle**: Carve the BiCompat construction into independently-provable lemmas

## Executive Summary

The BiCompat construction can be decomposed into 6 independent lemmas plus 1 recursive construction. The main dependent-type-cast problem identified in the handoffs is solvable with a clean pattern using `Sigma.Lex.lt_def` and `Eq.rec`-based order transfer. The per-component NF state tracking (CompNFState) from the Phase 2 handoff is necessary but can be formulated simply. Total estimated new code: ~250 lines.

## 1. BiCompat Definition Analysis

**Exact type** (from lean_hover_info):
```lean
BiCompat sig : Nat -> (n : Nat) -> (I : Type) -> [LinearOrder I] ->
    (ms ms' : I -> OrderedMonadicStructure sig) ->
    (env_M : Fin n -> (orderedSum sig I ms).carrier) ->
    (env_N : Fin n -> (orderedSum sig I ms').carrier) -> Prop
```

At depth 0: `True`.
At depth d+1: forward oracle (forall j c', exists c, atom_agree AND BiCompat d (n+1)) AND backward oracle.

**Sorry site goal** (all 4 are structurally identical):
```
exists x, nf_eval_nf (orderedSum sig I ms) k (0+1) (Fin.cons x Fin.elim0) sub_nf
```
or the ms' variant. Available hypotheses at each sorry:
- `h_agree_comp`: depth-k 1-var component NF agreement for `(ms i, [a])` vs `(ms' i, [b])`
- `h_comp`: component sentence equiv at all depths <= k+1
- `h_q_ms_to_ms'` / `h_q_ms'_to_ms`: component quantifier transfer
- `ih_k`: induction hypothesis for depth k (sentence-level ordered-sum NF agreement)

## 2. Key Building Blocks (Already Proved)

### component_extend_fwd
```lean
component_extend_fwd : (K+1)-depth r-var NF agreement for (ms j, eM) vs (ms' j, eN)
    -> c' : (ms' j).carrier
    -> exists c : (ms j).carrier, K-depth (r+1)-var NF agreement for (ms j, [c] ++ eM) vs (ms' j, [c'] ++ eN)
```
Consumes 1 depth level, adds 1 variable. Symmetric version: `component_extend_bwd`.

### extend_atoms
```lean
extend_atoms : h_idx -> h_atoms -> j -> c -> c' -> h_pred -> h_ord_fwd -> h_ord_bwd
    -> forall ak, atom_eval (orderedSum ms) (Fin.cons <j,c> env_M) ak <-> atom_eval (orderedSum ms') (Fin.cons <j,c'> env_N) ak
```
Requires: index matching (h_idx), existing atom agreement (h_atoms), predicate agreement for new element (h_pred), and bidirectional order agreement for new element vs all existing elements (h_ord_fwd, h_ord_bwd).

### sum_nf_lift_gen
```lean
sum_nf_lift_gen : h_comp -> h_atoms -> BiCompat sig d n -> forall nf, nf_eval_nf (orderedSum ms) d n env_M nf <-> nf_eval_nf (orderedSum ms') d n env_N nf
```
Already proved sorry-free. Consumes BiCompat to produce ordered-sum NF agreement.

## 3. Proposed Lemma Decomposition

### Lemma A: orderedSum_order_transfer (VERIFIED COMPILES)

**Purpose**: Bridge between orderedSum order and component order via Sigma.Lex.lt_def.

```lean
theorem orderedSum_order_transfer
    {sig : MonadicSignature} {I : Type} [LinearOrder I]
    {ms ms' : I -> OrderedMonadicStructure sig}
    (j idx : I)
    (c : (ms j).carrier) (c' : (ms' j).carrier)
    (v : (ms idx).carrier) (w : (ms' idx).carrier)
    (h_same : forall (h : j = idx),
      @LT.lt _ (ms idx).carrier_order.toLT (h |> c) v <->
      @LT.lt _ (ms' idx).carrier_order.toLT (h |> c') w) :
    orderedSum_lt <j, c> <idx, v> <-> orderedSum_lt <j, c'> <idx, w>
```

**Proof**: Apply `Sigma.Lex.lt_def` on both sides, then case split on the disjunction. Left disjunct (j < idx) is index comparison only. Right disjunct (exists h : j = idx, h cast c < v) uses h_same.

**Verified**: Compiles successfully in prototype.

**Dependent type handling**: The hypothesis `h_same` takes `h : j = idx` and uses `h |> c` (i.e., `Eq.rec c h`) to cast `c : (ms j).carrier` to `(ms idx).carrier`. This cleanly handles the dependent type cast without requiring definitional equality.

### Lemma B: cast_order_equiv (VERIFIED COMPILES)

**Purpose**: Allow moving the `h |>` cast from one side of `<` to the other.

```lean
theorem cast_order_equiv (h : j = idx) (c : (ms j).carrier) (v : (ms idx).carrier) :
    (h |> c) < v <-> c < (h.symm |> v)
```

**Proof**: `subst h; rfl`

**Why needed**: When deriving the `h_same` hypothesis for orderedSum_order_transfer from component NF agreement, the component NF operates on `(ms j).carrier` values, while the full environment has `(ms idx).carrier` values. This lemma bridges the two.

### Lemma C: comp_nf_to_order_fwd / comp_nf_to_order_bwd

**Purpose**: Extract orderedSum order atoms from component NF agreement.

```lean
theorem comp_nf_to_order_fwd
    {K r : Nat} (j : I)
    (comp_eM : Fin (r+1) -> (ms j).carrier) (comp_eN : Fin (r+1) -> (ms' j).carrier)
    (h_nf : forall nf, nf_eval_nf (ms j) K (r+1) comp_eM nf <-> nf_eval_nf (ms' j) K (r+1) comp_eN nf)
    (p q : Fin (r+1)) (hpq : p != q) :
    @LT.lt (ms j).carrier (ms j).carrier_order.toLT (comp_eM p) (comp_eM q) <->
    @LT.lt (ms' j).carrier (ms' j).carrier_order.toLT (comp_eN p) (comp_eN q)
```

**Proof**: Direct application of `atom_agreement_from_nf` to extract `.order p q hpq`, then unfold `atom_eval`.

**Note**: This is a thin wrapper around `atom_agreement_from_nf`. It may not need to be a separate lemma if `atom_agreement_from_nf` is used directly.

### Lemma D: comp_nf_to_pred

**Purpose**: Extract predicate agreement from component NF agreement.

```lean
theorem comp_nf_to_pred
    {K r : Nat} (j : I)
    (comp_eM : Fin r -> (ms j).carrier) (comp_eN : Fin r -> (ms' j).carrier)
    (h_nf : NF agreement at any depth >= 0)
    (c : (ms j).carrier) (c' : (ms' j).carrier)
    (h_ext_nf : NF agreement for Fin.cons c comp_eM vs Fin.cons c' comp_eN) :
    forall p, (ms j).interp p c <-> (ms' j).interp p c'
```

**Proof**: From `atom_agreement_from_nf` on the extended NF, extract `.pred p 0` atom, unfold `atom_eval` and `Fin.cons_zero`.

### Lemma E: CompNFState and build_bicompat (THE HARD PART)

**Purpose**: Recursive construction of BiCompat from per-component NF state.

#### CompNFState Definition

```lean
/-- Per-component NF state: tracks projected environments and NF agreement depth for each component. -/
structure CompNFState (sig : MonadicSignature) (I : Type) [LinearOrder I]
    (ms ms' : I -> OrderedMonadicStructure sig) (remaining_depth : Nat) where
  /-- For each component j, the number of elements projected to it -/
  comp_size : I -> Nat
  /-- Projected component environments -/
  comp_eM : (j : I) -> Fin (comp_size j) -> (ms j).carrier
  comp_eN : (j : I) -> Fin (comp_size j) -> (ms' j).carrier
  /-- NF agreement at depth (remaining_depth + comp_size j - comp_size j) for comp j -/
  -- Actually: depth for component j = initial_depth_j - (comp_size j - initial_size_j)
  -- This is complex. Simpler: just require NF agreement at depth >= remaining_depth
  comp_agree : (j : I) ->
    forall nf : NormalForm sig remaining_depth (comp_size j),
      nf_eval_nf (ms j) remaining_depth (comp_size j) (comp_eM j) nf <->
      nf_eval_nf (ms' j) remaining_depth (comp_size j) (comp_eN j) nf
```

**WAIT**: This formulation requires `remaining_depth + comp_size j` to be constant, which it isn't across components. The budget is: `remaining_depth + n <= k + 1` where `n` is total env size. But per-component depth depends on how many elements are in that component.

**Revised insight**: The NF agreement depth for component j should be `remaining_depth + (comp_size j - initial_comp_size j)`. But this is complex.

**Simpler alternative**: Don't use a fixed `remaining_depth` for all components. Instead, have each component carry its OWN remaining depth:

```lean
structure CompNFState ... where
  comp_depth : I -> Nat  -- NF agreement depth for each component
  comp_size : I -> Nat
  comp_eM : (j : I) -> Fin (comp_size j) -> (ms j).carrier
  comp_eN : (j : I) -> Fin (comp_size j) -> (ms' j).carrier
  comp_agree : (j : I) ->
    forall nf, nf_eval_nf (ms j) (comp_depth j) (comp_size j) (comp_eM j) nf <->
               nf_eval_nf (ms' j) (comp_depth j) (comp_size j) (comp_eN j) nf
  depth_budget : forall j, comp_depth j >= 1
    -- Need comp_depth j >= 1 to apply component_extend
```

**Budget invariant**: `comp_depth j + comp_size j` is constant for each component j. Specifically:
- Component i (initial element a): `comp_depth i + comp_size i = k + 1` (starts as k + 1 = k + 1)
- Component j != i: `comp_depth j + comp_size j = k + 1` (starts as (k+1) + 0 = k + 1)

So `comp_depth j = k + 1 - comp_size j` for all j.

This means when BiCompat remaining depth is d, we need `comp_depth j >= d` for all j, i.e., `k + 1 - comp_size j >= d`, i.e., `comp_size j <= k + 1 - d`. Since total elements = n = k + 1 - d (from d + n = k + 1), and comp_size j <= n for any j, this always holds.

Actually the invariant is even simpler: we need `comp_depth j >= 1` to be able to call component_extend_fwd/bwd. This means `comp_size j <= k`. Since total n elements are distributed across components, and n <= k (from d >= 1 meaning d + n <= k + 1 means n <= k), we have comp_size j <= n <= k. So the budget always suffices as long as BiCompat depth d >= 1.

#### build_bicompat

```lean
private noncomputable def build_bicompat (sig : MonadicSignature)
    (k : Nat) (I : Type) [LinearOrder I]
    (ms ms' : I -> OrderedMonadicStructure sig)
    (h_comp : forall m, m <= k + 1 -> forall i nf, nf_eval_nf ...) :
    forall (d n : Nat) (hdn : d + n = k + 1)
    (env_M : Fin n -> (orderedSum sig I ms).carrier)
    (env_N : Fin n -> (orderedSum sig I ms').carrier)
    (h_idx : forall p, (env_M p).1 = (env_N p).1)
    (h_atoms : atom agreement at n vars)
    (state : CompNFState ...),
    BiCompat sig d n I ms ms' env_M env_N
```

**Proof by induction on d**:
- d = 0: `True`, trivial.
- d + 1: Provide forward and backward oracles.
  - Forward oracle: given j, c', call component_extend_fwd on state for component j to get c with extended NF. Derive h_pred and h_ord from extended NF + cast bridge. Apply extend_atoms. Update CompNFState (increment comp_size j, decrement comp_depth j). Apply IH at depth d.
  - Backward oracle: symmetric using component_extend_bwd.

### Lemma F: bicompat_initial_state

**Purpose**: Construct the initial CompNFState at the sorry sites.

```lean
theorem bicompat_initial_state
    (h_agree_comp : depth-k 1-var NF agreement for (ms i, [a]) vs (ms' i, [b]))
    (h_comp : component sentence equiv at depths <= k+1) :
    CompNFState sig I ms ms' with
      comp_size i = 1, comp_size j = 0 (j != i)
      comp_eM i = ![a], comp_eN i = ![b]
      comp_eM j = Fin.elim0, comp_eN j = Fin.elim0 (j != i)
      comp_agree from h_agree_comp (for i) and h_comp (for j != i)
```

## 4. The Dependent Type Cast Problem: RESOLVED

The handoffs identified the main challenge as: when `(env_M k).1 = j` propositionally (not definitionally), we need to cast between `(ms (env_M k).1).carrier` and `(ms j).carrier`.

**Resolution**: The cast is handled cleanly by `Sigma.Lex.lt_def` which already uses `Eq.rec` (the `h |>` notation). The pattern is:

1. `Sigma.Lex.lt_def` decomposes orderedSum order into index comparison OR same-component order with an `h : j = idx` cast.
2. `orderedSum_order_transfer` (Lemma A) handles both branches uniformly.
3. `cast_order_equiv` (Lemma B) allows moving the cast to whichever side is convenient for matching component NF.
4. `subst` eliminates the cast entirely when the equality proof can be used to substitute a free variable.

**No cast is needed at the INITIAL level** (env = `![<i,a>]`) because all environment elements have definitionally-known component indices. At subsequent levels, the cast is handled by the `h |>` pattern in orderedSum_order_transfer.

## 5. Projection Consistency

The CompNFState must maintain consistency between the projected component environments and the full orderedSum environments:

```
forall k : Fin n, (env_M k).1 = j ->
  exists q : Fin (comp_size j),
    (env_M k).2 = (h_eq |> comp_eM j q)  -- cast comp value to env type
```

This is maintainable through Fin.cons extension:
- When oracle adds element to component j: `comp_eM j` gets Fin.cons c
- The new `env_M 0 = <j, c>`, matching `comp_eM j 0 = c` exactly (same type, no cast)
- Old elements: positions shift by 1 in both full env and component env

The projection consistency is straightforward for position 0 (the most recent element). For older positions, it follows from the inductive hypothesis.

## 6. Implementation Risks and Mitigations

### Risk 1: CompNFState complexity
**Risk**: The CompNFState definition and update may be harder than expected due to dependent types.
**Mitigation**: Use existential formulation -- CompNFState as a Prop, not a Structure. Each component just needs `exists eM eN, NF agreement AND consistency`. The existential witnesses are provided by component_extend at each step.

### Risk 2: Fin indexing in projection
**Risk**: Tracking which Fin positions in the full env correspond to which component positions.
**Mitigation**: The projection mapping doesn't need to be explicit. We only need:
(a) For the NEW element at position 0: it's definitionally in the oracle component j, so no mapping needed.
(b) For OLD elements at positions 1..n-1: inherited from the previous level's CompNFState, shifted by 1.

### Risk 3: Budget exhaustion
**Risk**: Component NF depth might be insufficient for remaining BiCompat depth.
**Mitigation**: The budget invariant `comp_depth j + comp_size j = k + 1` and total `d + n = k + 1` guarantee sufficiency. Formally: `comp_depth j = k + 1 - comp_size j >= k + 1 - n = d`. So `comp_depth j >= d >= 1` when `d >= 1`, which is exactly when component_extend is needed.

### Risk 4: h_comp bound mismatch
**Risk**: component_extend_fwd needs `(K+1)`-depth NF, but CompNFState tracks `comp_depth j`-depth NF.
**Mitigation**: When calling component_extend, we need comp_depth j >= 1, which gives (comp_depth j - 1 + 1) = comp_depth j depth NF, producing (comp_depth j - 1)-depth NF for the extension. This matches the budget decrement.

## 7. Recommended Implementation Order

1. **orderedSum_order_transfer** (~20 lines) - VERIFIED, compile-ready
2. **cast_order_equiv** (~5 lines) - VERIFIED, compile-ready  
3. **CompNFState as Prop** (~25 lines) - define the compatibility predicate
4. **bicompat_initial_state** (~40 lines) - construct initial state at sorry sites
5. **build_bicompat** (~80 lines) - recursive construction (THE MAIN LEMMA)
6. **sorry site closure** (~30 lines each, x4 = 120 lines) - apply build_bicompat + sum_nf_lift_gen

**Total estimate**: ~290 lines of new code.

## 8. Prototype Results

All critical type-level operations were verified to compile:

| Operation | Status | Key Finding |
|-----------|--------|-------------|
| `Sigma.Lex.lt_def` on orderedSum carrier | COMPILES | Decomposes to index comparison OR cast + component order |
| Same-component order reduction | COMPILES | `<j,c> < <j,a>` iff `c < a` with `rfl` cast |
| Cross-component order | COMPILES | `j != i` eliminates same-component branch |
| orderedSum_order_transfer | COMPILES | Clean h_same pattern with `h |> c` |
| cast_order_equiv | COMPILES | `subst h; rfl` |
| DecidableEq I from LinearOrder | COMPILES | `infer_instance` |
| atom_agreement_from_nf for order atoms | EXISTS | Already proved in NormalForm.lean |
| component_extend budget check | VERIFIED | Budget invariant holds for all d >= 1 |
