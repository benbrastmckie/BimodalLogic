# Teammate B Findings: Infrastructure Inventory and Gap Analysis

**Task**: 154 - sum_preservation_ef_games
**Angle**: Infrastructure inventory of NormalForm.lean and NEquivalence.lean; precise gap analysis for closing the 4 sorry sites
**Date**: 2025-05-15

## 1. NormalForm.lean Infrastructure Inventory

All definitions and theorems below are in namespace `Bimodal.Metalogic.WeakCanonical`, file `Theories/Bimodal/Metalogic/WeakCanonical/NormalForm.lean`. None contain sorry -- this file is fully proven.

### Core Types

| Name | Signature | Purpose |
|------|-----------|---------|
| `AtomKind sig n` | `inductive` with `.pred p i` and `.order i j h` | Concrete enumeration of atomic propositions at `n` free vars |
| `NormalForm sig k n` | `def` recursive: depth-0 = `AtomKind sig n -> Bool`, depth-(k+1) = pair of atom-assgn and quant-assgn | Doets n-characteristics at depth `k`, `n` vars |
| `NormalForm.atom_assgn` | `{k n} -> NormalForm sig k n -> (AtomKind sig n -> Bool)` | Extract atom assignment from any NF |
| `NormalForm.quant_assgn` | `{k n} -> NormalForm sig (k+1) n -> (NormalForm sig k (n+1) -> Bool)` | Extract quantifier assignment from depth-(k+1) NF |

### Semantic Evaluation

| Name | Signature | Purpose |
|------|-----------|---------|
| `atom_eval M env a` | `OrderedMonadicStructure sig -> (Fin n -> M.carrier) -> AtomKind sig n -> Prop` | Semantic eval of an atom: `.pred p i => M.interp p (env i)`, `.order i j _ => env i < env j` |
| `nf_eval_nf M k n env nf` | `OrderedMonadicStructure sig -> Nat -> Nat -> (Fin n -> M.carrier) -> NormalForm sig k n -> Prop` | Semantic eval of a normal form: depth 0 = all atoms match; depth k+1 = atoms match AND for each sub-NF, existential realization matches |

### Key Theorems (Exact Signatures)

**`nf_characteristic`**:
```lean
noncomputable def nf_characteristic {sig} (M : OrderedMonadicStructure sig) 
    (k n : Nat) (env : Fin n -> M.carrier) : NormalForm sig k n
```
Returns the unique NF that M,env satisfies. Uses `Classical.dec` for decidability.

**`nf_characteristic_satisfies`**:
```lean
theorem nf_characteristic_satisfies {sig} (M : OrderedMonadicStructure sig) 
    (k n : Nat) (env : Fin n -> M.carrier) : 
    nf_eval_nf M k n env (nf_characteristic M k n env)
```
The characteristic NF is actually satisfied. Used extensively in sorry site scaffolding.

**`nf_eval_unique`**:
```lean
theorem nf_eval_unique {sig} (M : OrderedMonadicStructure sig) (k n : Nat)
    (env : Fin n -> M.carrier) (nf1 nf2 : NormalForm sig k n) 
    (h1 : nf_eval_nf M k n env nf1) (h2 : nf_eval_nf M k n env nf2) : 
    nf1 = nf2
```
If two NFs are both satisfied, they are equal. The uniqueness half of `nf_exists_unique`.

**`nf_agreement_from_shared_nf`**:
```lean
theorem nf_agreement_from_shared_nf {sig} {k n : Nat}
    (M : OrderedMonadicStructure sig) (env_M : Fin n -> M.carrier)
    (N : OrderedMonadicStructure sig) (env_N : Fin n -> N.carrier)
    (nf : NormalForm sig k n) 
    (hM : nf_eval_nf M k n env_M nf) (hN : nf_eval_nf N k n env_N nf) 
    (nf' : NormalForm sig k n) :
    nf_eval_nf M k n env_M nf' <-> nf_eval_nf N k n env_N nf'
```
If M and N both satisfy the same NF, they agree on ALL NFs at that depth. This is the bridge from "shared characteristic NF" to "full NF agreement". Used in every sorry site to convert component NF matching to full agreement.

**`atom_agreement_from_nf`**:
```lean
theorem atom_agreement_from_nf {sig} {k n : Nat}
    (M : OrderedMonadicStructure sig) (env_M : Fin n -> M.carrier)
    (N : OrderedMonadicStructure sig) (env_N : Fin n -> N.carrier)
    (h_same_nf : forall nf, nf_eval_nf M k n env_M nf <-> nf_eval_nf N k n env_N nf)
    (a : AtomKind sig n) : atom_eval M env_M a <-> atom_eval N env_N a
```
Extracts atom agreement from depth-k NF agreement. Useful for deriving predicate and order agreement from NF matching.

**`nf_agreement_monotone`**:
```lean
theorem nf_agreement_monotone {sig} (m k n : Nat) (hkm : m <= k)
    (M : OrderedMonadicStructure sig) (env_M : Fin n -> M.carrier)
    (N : OrderedMonadicStructure sig) (env_N : Fin n -> N.carrier)
    (h_agree_k : forall nf, nf_eval_nf M k n env_M nf <-> nf_eval_nf N k n env_N nf)
    (nf_m : NormalForm sig m n) :
    nf_eval_nf M m n env_M nf_m <-> nf_eval_nf N m n env_N nf_m
```
NF agreement at depth k implies NF agreement at any depth m <= k. Fully proven by induction on m.

### Cardinality and Finiteness

| Name | Status | Purpose |
|------|--------|---------|
| `normalForm_fintype` | Proven | `Fintype (NormalForm sig k n)` |
| `normalForm_decEq` | Proven | `DecidableEq (NormalForm sig k n)` |
| `atomKind_card` | Proven | Card correspondence with `atomCount` |
| `normalForm_card` | Proven | Card correspondence with `nfCount` |
| `normalForm_equiv_fin` | Proven | Bijection to `NormalFormIdx` |

## 2. NEquivalence.lean Infrastructure Inventory

File: `Theories/Bimodal/Metalogic/WeakCanonical/NEquivalence.lean`. Contains 4 sorry sites, all in `sum_nf_agree_sentence`.

### Fully Proven Components

**`orderedSum`** (line 122):
```lean
noncomputable def orderedSum (sig : MonadicSignature) (I : Type) [LinearOrder I]
    (ms : I -> OrderedMonadicStructure sig) : OrderedMonadicStructure sig
```
Carrier = `Sigma fun i => (ms i).carrier`, order = `Sigma.Lex.linearOrder`. Interpretation: `interp p x = (ms x.1).interp p x.2`.

**`BiCompat`** (line 160, fully defined, no sorry):
```lean
private noncomputable def BiCompat (sig : MonadicSignature) :
    Nat -> (n : Nat) -> (I : Type) -> [LinearOrder I] ->
    (ms ms' : I -> OrderedMonadicStructure sig) ->
    (env_M : Fin n -> (orderedSum sig I ms).carrier) -> 
    (env_N : Fin n -> (orderedSum sig I ms').carrier) -> Prop
```
Recursion on depth d. At d=0: `True`. At d+1: forward oracle (given j, c', find c with atom agreement + BiCompat at d) AND backward oracle (given j, c, find c' with atom agreement + BiCompat at d).

**`component_extend_fwd`** (line 187, fully proven):
```lean
private theorem component_extend_fwd {sig} {K r : Nat} {I : Type} [LinearOrder I] (j : I)
    (ms ms' : I -> OrderedMonadicStructure sig)
    (eM : Fin r -> (ms j).carrier) (eN : Fin r -> (ms' j).carrier)
    (h : forall nf, nf_eval_nf (ms j) (K+1) r eM nf <-> nf_eval_nf (ms' j) (K+1) r eN nf)
    (c' : (ms' j).carrier) :
    exists c, forall nf, nf_eval_nf (ms j) K (r+1) (Fin.cons c eM) nf <-> 
                          nf_eval_nf (ms' j) K (r+1) (Fin.cons c' eN) nf
```
From component (K+1)-var-r NF agreement and element c' in ms' j, find c in ms j giving depth-K (r+1)-var agreement. This "peels one quantifier" from the component equivalence.

**`component_extend_bwd`** (line 208, fully proven): Symmetric version finding c' from c.

**`extend_atoms`** (line 233, fully proven):
```lean
private theorem extend_atoms {sig} {n : Nat} {I : Type} [LinearOrder I]
    {ms ms' : I -> OrderedMonadicStructure sig}
    {env_M : Fin n -> (orderedSum sig I ms).carrier}
    {env_N : Fin n -> (orderedSum sig I ms').carrier}
    (h_idx : forall p, (env_M p).fst = (env_N p).fst)
    (h_atoms : forall a, atom_eval (orderedSum sig I ms) env_M a <-> 
                          atom_eval (orderedSum sig I ms') env_N a)
    (j : I) (c : (ms j).carrier) (c' : (ms' j).carrier)
    (h_pred : forall p, (ms j).interp p c <-> (ms' j).interp p c')
    (h_ord_fwd : forall k, <j,c> < env_M k <-> <j,c'> < env_N k)
    (h_ord_bwd : forall k, env_M k < <j,c> <-> env_N k < <j,c'>) :
    forall ak, atom_eval (orderedSum ..) (Fin.cons <j,c> env_M) ak <-> 
               atom_eval (orderedSum ..) (Fin.cons <j,c'> env_N) ak
```
Extends atom agreement by one variable. Requires: index matching (`h_idx`), existing atom agreement, and for the new element: pred agreement, forward order agreement, backward order agreement.

**`atomKind_zero_elim`** (line 136, proven): `AtomKind sig 0` is empty.

**`atomKind_one_pred_only`** (line 145, proven): Every `a : AtomKind sig 1` is `.pred p 0`. No order atoms at `Fin 1`.

**`sum_nf_lift_gen`** (line 296, FULLY PROVEN):
```lean
private noncomputable def sum_nf_lift_gen (sig : MonadicSignature) :
    forall (d n : Nat) (I : Type) [LinearOrder I]
    (ms ms' : I -> OrderedMonadicStructure sig)
    (h_comp : forall m, m <= d + n -> forall i nf, 
      nf_eval_nf (ms i) m 0 Fin.elim0 nf <-> nf_eval_nf (ms' i) m 0 Fin.elim0 nf)
    (env_M : Fin n -> (orderedSum sig I ms).carrier)
    (env_N : Fin n -> (orderedSum sig I ms').carrier)
    (h_atoms : forall a, atom_eval (orderedSum ..) env_M a <-> atom_eval (orderedSum ..) env_N a)
    (h_bc : BiCompat sig d n I ms ms' env_M env_N)
    (nf : NormalForm sig d n),
    nf_eval_nf (orderedSum ..) d n env_M nf <-> nf_eval_nf (orderedSum ..) d n env_N nf
```
The generalized lifting lemma. Requires 4 inputs: component sentence equivalence (`h_comp`), atom agreement (`h_atoms`), BiCompat witness oracle (`h_bc`), and the NF. Already fully proven by induction on d.

### Components with Sorry

**`sum_nf_agree_sentence`** (line 367): 4 sorry sites at lines 429, 451, 476, 496.

**`sum_preservation_proof`** (line 501): No sorry of its own, but transitively sorry'd because it delegates to `sum_nf_agree_sentence`.

**`KEquivalenceFramework` instance** (line 562): `sum_preservation` field delegates to `sum_preservation_proof`. Transitively sorry'd.

## 3. The 4 Sorry Sites: Exact Goal Analysis

All 4 sorry sites have structurally identical goals. They differ only in direction and which environment is the source.

### Common Context Available at All Sites

- `ih_k`: inductive hypothesis from `sum_nf_agree_sentence` at depth k
- `h_comp : forall m <= k+1, forall i nf, nf_eval_nf (ms i) ... <-> nf_eval_nf (ms' i) ...`
- Index `i : I`, elements `a : (ms i).carrier` and `b : (ms' i).carrier`
- `h_agree_comp : forall nf', nf_eval_nf (ms i) k 1 (![a]) nf' <-> nf_eval_nf (ms' i) k 1 (![b]) nf'`
  (Component depth-k 1-var NF agreement between a and b)
- Component transfer infrastructure: `hMi_q`, `hNi_q`, `h_q_ms_to_ms'`, `h_q_ms'_to_ms`
- One of `ha_eval` or `hb_eval`: the source NF evaluation at ordered-sum level

### The Goals

| Sorry | Line | Goal | Available source |
|-------|------|------|-----------------|
| #1 | 429 | `exists x, nf_eval_nf (orderedSum .. ms) k 1 (![x]) sub_nf` | `hb_eval` on ms' side |
| #2 | 451 | `exists x, nf_eval_nf (orderedSum .. ms') k 1 (![x]) sub_nf` | `ha_eval` on ms side |
| #3 | 476 | `exists x, nf_eval_nf (orderedSum .. ms') k 1 (![x]) sub_nf` | `ha_eval` on ms side |
| #4 | 496 | `exists x, nf_eval_nf (orderedSum .. ms) k 1 (![x]) sub_nf` | `hb_eval` on ms' side |

Sorry #1 and #4 are symmetric (ms' -> ms direction).
Sorry #2 and #3 are symmetric (ms -> ms' direction).

### What Each Goal Requires

Take sorry #1 as representative. The witness should be `⟨i, a⟩`. We need:
```
nf_eval_nf (orderedSum sig I ms) k 1 (Fin.cons ⟨i,a⟩ Fin.elim0) sub_nf
```

To derive this from `hb_eval : nf_eval_nf (orderedSum sig I ms') k 1 (Fin.cons ⟨i,b⟩ Fin.elim0) sub_nf`, we need ordered-sum depth-k 1-var NF agreement between `(![⟨i,a⟩])` and `(![⟨i,b⟩])`.

This can be obtained by calling `sum_nf_lift_gen` at `d=k, n=1`, which requires:
1. **h_comp**: `forall m <= k+1, ...` -- available directly (the outer `h_comp` gives `m <= k+1`)
2. **h_atoms**: `forall a : AtomKind sig 1, atom_eval (orderedSum ..) (![⟨i,a⟩]) a <-> ...`
3. **h_bc**: `BiCompat sig k 1 I ms ms' (![⟨i,a⟩]) (![⟨i,b⟩])`

## 4. Precise Gap Analysis

### Gap 1: Constructing `h_atoms` at n=1 (SMALL)

`AtomKind sig 1` has no order atoms (proven by `atomKind_one_pred_only`). Every atom is `.pred p 0`. So:
```
atom_eval (orderedSum ..) (![⟨i,a⟩]) (.pred p 0)
  = (ms i).interp p a    -- by orderedSum.interp definition
```
and similarly for ms'. Component depth-k 1-var NF agreement (`h_agree_comp`) gives us `atom_agreement_from_nf`, which transfers pred atoms. This is straightforward.

**Estimated effort**: ~10-15 lines per sorry site, or factor into a helper lemma.

### Gap 2: Constructing `BiCompat sig k 1 I ms ms'` (MAIN GAP)

This is the critical missing piece. `BiCompat sig k 1` is defined recursively:

- `BiCompat sig 0 1 ...` = `True` (trivial)
- `BiCompat sig (k+1) 1 ...` = forward + backward witness oracles at depth k+1 producing atom agreement + `BiCompat sig k 2`

To construct `BiCompat sig k 1`, we need a recursion on k (or an inner induction). At each step:

**Given** (at recursion step for `BiCompat sig (d+1) n`):
- Component `(d+1+n)`-equivalence (from `h_comp m <= k+1` where `k+1 >= d+1+n` when `d+1 <= k` and `n <= 1`)
- Existing environments with same-component index matching

**Need to produce** (for each `j : I` and `c' : (ms' j).carrier`):
1. A witness `c : (ms j).carrier` 
2. Atom agreement for extended envs (n+1 vars)
3. `BiCompat sig d (n+1)` for the extended envs

The witness `c` comes from `component_extend_fwd`: given component (K+1)-var-r NF agreement, peel one quantifier to get depth-K (r+1)-var agreement.

Atom agreement for extended envs comes from `extend_atoms`, which needs:
- `h_idx` (index matching for existing env elements)
- `h_pred` (pred agreement for new element c, c')
- `h_ord_fwd`, `h_ord_bwd` (order agreement for new element vs existing elements)

The pred agreement comes from component NF agreement via `atom_agreement_from_nf`.

The order agreement comes from the component multi-var NF agreement: since `a/b` (and any same-component env elements) share the same component NF which includes order atoms, the relative ordering is preserved.

The recursive `BiCompat sig d (n+1)` requires the SAME construction at one depth lower and one more variable. This recurse terminates because depth decreases.

**Key insight**: Constructing `BiCompat sig k n` requires a mutual recursion on `k` (depth peeling) and `n` (variable accumulation). The component `(k+n)`-equivalence provides enough "budget" for both.

**Estimated effort**: This is the hard part -- a recursive construction of BiCompat from component equivalence. Likely 80-150 lines, potentially factored into a helper `build_bicompat`.

### Gap 3: Order Atom Transfer for Same-Component Elements (MEDIUM)

When constructing `h_ord_fwd/h_ord_bwd` for `extend_atoms`, the cross-component case (different indices) is trivial: `⟨j, c⟩ < ⟨j', c'⟩ iff j < j'` by the lexicographic order, and indices match by `h_idx`.

The same-component case (`j = (env_M k).1`) requires: `c < (env_M k).2 iff c' < (env_N k).2` in the component order. This follows from the component multi-var NF agreement (which includes `.order` atoms between the elements), but extracting it requires:

1. Building a chain of `component_extend_fwd/bwd` calls to accumulate multi-var NF agreement
2. Using `atom_agreement_from_nf` on the component to extract order agreement

**Critical Sigma.Lex infrastructure needed**:

| Mathlib Lemma | Signature | Use |
|--------------|-----------|-----|
| `Sigma.Lex.lt_def` | `a < b <-> a.1 < b.1 or (exists h : a.1 = b.1, h.rec a.2 < b.2)` | Decompose ordered-sum `<` into index vs component cases |
| `Sigma.mk_lt_mk_iff` | `⟨i, a⟩ < ⟨i, b⟩ <-> a < b` | Same-component case (uses `Sigma.LT`, not `Sigma.Lex`) |
| `Sigma.Lex.linearOrder` | `LinearOrder (Lex (Sigma ...))` | The order instance used by `orderedSum` |

**WARNING**: There is a potential type coercion issue. The `orderedSum` carrier is `Sigma fun i => (ms i).carrier` (plain `Sigma`), but `carrier_order` is assigned `Sigma.Lex.linearOrder` which operates on `Lex (Sigma ...)` = `Sigmalex i, (ms i).carrier`. The `<` comparison in `atom_eval` uses `(orderedSum ..).carrier_order.toLT`, which should be the `Lex` order. Using `Sigma.mk_lt_mk_iff` (which is for the componentwise `Sigma.LT`) may NOT directly apply -- one may need `Sigma.Lex.lt_def` with the `h : a.1 = b.1` existential instead. This is a source of bureaucratic overhead.

**Estimated effort**: ~30-50 lines for the Sigma.Lex order reasoning, possibly simplified by a helper simp lemma.

## 5. Component Transfer Chain Analysis

The key operation chain for building `BiCompat`:

```
Component (k+1)-equiv at 0 vars  [h_comp at m = k+1]
    |
    v (component_extend_fwd/bwd, peels 1 quantifier)
Component k-NF agreement at 1 var  [for a, b pair]
    |
    v (atom_agreement_from_nf, extract pred + order atoms)
Pred and order agreement for a/b  [feeds h_pred, h_ord in extend_atoms]
    |
    v (extend_atoms)
Atom agreement at n+1 vars for extended ordered-sum envs  [feeds h_atoms in sum_nf_lift_gen]
    |
    v (recursive BiCompat construction at depth d, n+1 vars)
BiCompat sig d (n+1)  [from component (d+n+1)-equiv, recursive]
```

The budget analysis: component `(k+1)`-equiv provides `k+1` peeling levels. Starting from `sum_nf_agree_sentence` at depth `k+1`, we call `sum_nf_lift_gen` at `d=k, n=1`. For BiCompat at depth k, n=1:
- Need component `m <= k+1` (available from h_comp)
- At each BiCompat recursion step: peel 1 depth, add 1 var
- After r steps: depth `k-r`, vars `1+r`, need component `m <= (k-r)+(1+r) = k+1` -- always satisfied!

So the budget is ALWAYS sufficient. No off-by-one issue.

## 6. Factoring Recommendation

The gap can be factored into 3 independent lemmas:

### Lemma A: `sum_atoms_from_component_nf` (~20 lines)
```lean
-- From component depth-k r-var NF agreement, derive ordered-sum atom agreement at n vars
-- when environments are single-element (n=1) and all in same component
private theorem sum_atoms_from_component_nf {sig} {k : Nat} {I : Type} [LinearOrder I]
    (i : I) (ms ms' : I -> OrderedMonadicStructure sig)
    (a : (ms i).carrier) (b : (ms' i).carrier)
    (h_agree : forall nf, nf_eval_nf (ms i) k 1 (![a]) nf <-> nf_eval_nf (ms' i) k 1 (![b]) nf) :
    forall ak : AtomKind sig 1, 
      atom_eval (orderedSum ..) (![⟨i,a⟩]) ak <-> atom_eval (orderedSum ..) (![⟨i,b⟩]) ak
```
Uses `atomKind_one_pred_only` + `atom_agreement_from_nf` on the component.

### Lemma B: `build_bicompat` (~100 lines, recursive)
```lean
-- Construct BiCompat from component sentence-level equivalence
private noncomputable def build_bicompat (sig : MonadicSignature) :
    forall (d n : Nat) (I : Type) [LinearOrder I]
    (ms ms' : I -> OrderedMonadicStructure sig)
    (h_comp : forall m, m <= d + n -> forall i nf, ...)
    (env_M : Fin n -> (orderedSum ..).carrier)
    (env_N : Fin n -> (orderedSum ..).carrier)
    (h_idx : forall p, (env_M p).1 = (env_N p).1)
    (h_comp_env : forall j, ... component multi-var NF agreement ...),
    BiCompat sig d n I ms ms' env_M env_N
```
Recursion on d. At d=0: trivial. At d+1: use `component_extend_fwd/bwd` to find witnesses, `extend_atoms` for atom agreement, recurse at d.

### Lemma C: Sorry site closures (~15 lines each, 4 sites)
At each sorry site, assemble:
1. `h_atoms` via Lemma A
2. `h_bc` via Lemma B
3. Call `sum_nf_lift_gen` to get NF agreement
4. Provide witness `⟨i,a⟩` or `⟨i,b⟩`

## 7. Sigma.Lex Order Infrastructure Summary

### Available from Mathlib (via `import Mathlib.Data.Sigma.Order`)

| Lemma | Statement | Already imported |
|-------|-----------|-----------------|
| `Sigma.Lex.lt_def` | `a < b <-> a.1 < b.1 or exists h, h.rec a.2 < b.2` | Yes (Sigma.Order) |
| `Sigma.Lex.le_def` | `a <= b <-> a.1 < b.1 or exists h, h.rec a.2 <= b.2` | Yes |
| `Sigma.Lex.linearOrder` | `LinearOrder (Lex (Sigma ..))` | Yes (used in orderedSum) |
| `Sigma.mk_lt_mk_iff` | `⟨i,a⟩ < ⟨i,b⟩ <-> a < b` (for `Sigma.LT`) | Yes, but for non-Lex order |

### Potential Issue: Sigma.LT vs Sigma.Lex.LT

The `orderedSum` carrier order is `Sigma.Lex.linearOrder`, which puts `LT` via `Sigma.Lex.LT` (lexicographic). The lemma `Sigma.mk_lt_mk_iff` operates on `Sigma.LT` (the componentwise order on non-Lex sigma). These are DIFFERENT `LT` instances.

For same-component comparison in the Lex order, use `Sigma.Lex.lt_def` with the second disjunct: `exists h : a.1 = b.1, h.rec a.2 < b.2`. When `a.1 = b.1 = i` (literally equal, not just heq), this simplifies to `a.2 < b.2` via `rfl.rec`.

For cross-component comparison, use the first disjunct: `a.1 < b.1`.

**Recommendation**: Define a small simp lemma `orderedSum_lt_same_component` and `orderedSum_lt_diff_component` for cleanliness, or use inline `show` and `Sigma.Lex.lt_def` directly.

## 8. Overall Assessment

### What Exists and Works

1. The NormalForm.lean infrastructure is 100% complete and sorry-free
2. `sum_nf_lift_gen` is fully proven -- the generalized lifting lemma works
3. `BiCompat`, `component_extend_fwd/bwd`, `extend_atoms` are all proven
4. `atomKind_zero_elim` and `atomKind_one_pred_only` are proven
5. The sorry site scaffolding (characteristic NF extraction, component transfer) is correct

### What's Missing

1. **Constructing `h_atoms` at n=1 from component NF agreement** -- straightforward, ~15 lines each
2. **Constructing `BiCompat sig k 1` from component equivalence** -- the main gap, requires recursive construction ~100 lines
3. **Sigma.Lex order reasoning** for same-component elements -- ~30 lines of boilerplate

### Estimated Total Effort

- Lemma A (h_atoms construction): 1 hour
- Lemma B (build_bicompat): 3-4 hours (main difficulty)
- Lemma C (sorry closures): 1 hour
- Order bureaucracy: 1 hour
- Testing and debugging: 1-2 hours
- **Total: 7-9 hours**

The primary risk is Lemma B (`build_bicompat`), which requires careful handling of the multi-var component NF agreement chain and the Sigma.Lex order coercion for `extend_atoms` hypotheses.
