# Teammate A Findings: Root-Cause Elimination of ite-in-types Problem

**Task**: 154 - sum_preservation_ef_games
**Date**: 2026-05-16
**Angle**: Structural simplifications to eliminate the ite-in-types problem
**Status**: Complete

## Executive Summary

The ite-in-types problem has a clean structural elimination via TWO combined techniques:

1. **Function.update for sz** -- eliminates the motive error that makes `rw [if_pos rfl]` fail after `subst`. Already available from existing imports (no new dependency).
2. **CompData.extend helper** -- isolates ALL ite-handling in one definition. Oracle sites become one-line calls. Verified end-to-end in prototype.

The recommended approach reduces 9 ite-handling sites (3 fields x 3 constructions) to 1 site (inside the helper), and makes each proof field a 2-line `by_cases; rw [Function.update_self/of_ne]` pattern that works reliably.

## Analysis of Each Approach

### Approach 1: CompData.extend Helper Function

**Feasibility**: HIGH -- fully verified in prototype
**Effort**: Medium (define one ~40-line helper, rewrite 3 call sites to use it)
**Risk**: LOW -- prototype compiles with all fields including consistent

**How it works**: Define a private def that constructs a new CompData from an existing one by incrementing `sz j`:

```lean
private def CompData.extend {budget n : Nat} ...
    (cd : CompData sig I ms ms' budget env_M env_N h_idx) (j : I)
    (c : (ms j).carrier) (c' : (ms' j).carrier)
    (hbound : cd.sz j + 1 < budget)
    (h_szle : cd.sz j <= n)
    (h_ext_agree : ...) (h_idx' : ...) :
    CompData sig I ms ms' budget
      (Fin.cons ... env_M) (Fin.cons ... env_N) h_idx' where
  sz := Function.update cd.sz j (cd.sz j + 1)
  eM := fun j' x => if h : j' = j then ...
  eN := fun j' x => if h : j' = j then ...
  agree := fun j' => by by_cases h : j' = j; ...
  bound := fun j' => by by_cases h : j' = j; ...
  sz_le_n := fun j' => by by_cases h : j' = j; ...
  consistent := fun p j' hj' => by cases p using Fin.cases; ...
```

**Advantages**:
- Ite handling is done ONCE inside the helper
- Each oracle site (forward, backward) becomes: `have cd' := cd.extend j c c' hbound h_szle h_ext_agree h_idx'`
- No repeated pattern across construction sites
- Consistent field can be proved generically (zero/succ pattern is identical in both oracles)

**Challenges**:
- The `agree` field inside the helper needs the `nf_eval_nf` relationship between the new eM and `Fin.cons c (cd.eM j)`. This requires showing that `eM_new j = Fin.cons c (cd.eM j)` (or using `convert`).
- The `h_idx'` parameter means the helper must take the new env as input (not construct it).
- cd0 in `sum_lift_one_var` has a different structure (initial construction, not extension) and needs its own approach.

**Prototype verification**: Complete `TestCD2.extend` compiled successfully with all fields including `consistent`, using `Function.update` + `rw [Function.update_self/of_ne]` for all proof fields.

### Approach 2: Make DecidableEq Reducible

**Feasibility**: NOT VIABLE for abstract I
**Effort**: N/A
**Risk**: N/A

**Why it fails**: `LinearOrder.toDecidableEq` provides `DecidableEq I` for linear orders, but it uses `compare` internally which is opaque. For an abstract type `I`, there is NO way to make `j = j` definitionally `True`. The expression `if j = j then X else Y` will NEVER reduce to `X` by `rfl`.

**Verified**: `rfl` fails on `(if j = j then 42 else 0) = 42` with `[LinearOrder I]`.

Even `@[reducible]` on the instance would not help because the underlying comparison function is abstract. This approach is fundamentally impossible for parametric types.

### Approach 3: Function.update Instead of ite

**Feasibility**: HIGH -- verified, and this is the KEY ENABLER
**Effort**: Low (change `fun j' => if j' = j then X else Y` to `Function.update f j X`)
**Risk**: LOW -- already available from existing imports

**The critical advantage over raw ite**: `rw [Function.update_self]` works in TYPE positions even AFTER `subst h`, while `rw [if_pos rfl]` fails with the motive error.

**Root cause of the difference**: With raw ite, the term `if j = j then X else Y` contains a `Decidable (j = j)` instance syntactically visible in the term. When `rw` tries to abstract over the proposition `j = j`, it must also abstract over the Decidable instance, creating a motive type mismatch. With `Function.update f j v j`, the Decidable instance is hidden INSIDE Function.update's opaque definition. The term appears as a simple function application, so `rw [Function.update_self]` rewrites it cleanly without motive issues.

**Verified tests**:
```lean
-- This FAILS with raw ite:
-- example : Fin (if j = j then 5 else 3) = Fin 5 := by rw [if_pos rfl]
-- ERROR: motive is not type correct

-- This SUCCEEDS with Function.update:
example : Fin (Function.update f j 5 j) = Fin 5 := by rw [Function.update_self]
-- OK!

-- Works even after subst:
example (j' : I) (h : j' = j) :
    (forall k : Fin (budget - Function.update cd_sz j (cd_sz j + 1) j'), True) := by
  subst h; rw [Function.update_self]; exact fun _ => trivial
-- OK!
```

**Import requirement**: NONE. `Function.update`, `Function.update_self`, and `Function.update_of_ne` are all already available from the existing imports in NEquivalence.lean (via `Mathlib.Data.Sigma.Order` transitively importing `Mathlib.Logic.Function.Basic`).

### Approach 4: Fin.cases / Pattern Matching on Index

**Feasibility**: NOT VIABLE
**Effort**: N/A
**Risk**: N/A

**Why it fails**: The index type `I` is an arbitrary `LinearOrder` (could be infinite, could be `Nat` or `Int` or any linear order). `Fin.cases` only works on `Fin n`. Pattern matching on an arbitrary type requires decidable equality, which brings us back to ite/dite. There is no way to avoid branching on `j' = j` for an abstract `I`.

### Approach 5: Sigma-type / Subtype Approach

**Feasibility**: NOT VIABLE without major redesign
**Effort**: Very high (restructure CompData + all callers)
**Risk**: HIGH

**The idea**: Instead of `sz : I -> Nat` with ite, split into:
- `szj : Nat` (the value at j)
- `sz_other : (j' : I) -> j' != j -> Nat`

**Why it's not viable**:
1. Changes the TYPE of CompData fundamentally
2. `build_bicompat`'s recursive call expects the standard CompData shape
3. All existing helper theorems (e.g., `orderedSum_order_fwd_via_comp`) take CompData with `sz : I -> Nat`
4. The benefit is marginal: we still need to merge the split components when passing to other functions
5. Much higher implementation effort than the helper function approach

## Recommendation

**Use Function.update + CompData.extend helper (Approaches 1+3 combined).**

This is the cleanest root-cause elimination:

| Aspect | Current (raw ite) | Recommended (Function.update + helper) |
|--------|-------------------|----------------------------------------|
| Motive errors | Yes (rw [if_pos rfl] fails after subst) | No (rw [Function.update_self] works) |
| Code duplication | 9 ite-handling sites | 1 site (inside helper) |
| Pattern per proof field | Complex (varies per field) | Uniform: `by_cases h; subst h; rw [Function.update_self]; exact ...` |
| Risk of regression | High (each site can introduce errors) | Low (prove once, use everywhere) |
| Effort | 3h (fix each site individually) | 2-3h (write helper + adapt call sites) |

### Implementation Sketch

```lean
/-- Extend CompData by adding a new element at component j. -/
private noncomputable def CompData.extend
    {sig : MonadicSignature} {I : Type} [LinearOrder I]
    {ms ms' : I -> OrderedMonadicStructure sig} {budget n : Nat}
    {env_M : Fin n -> (orderedSum sig I ms).carrier}
    {env_N : Fin n -> (orderedSum sig I ms').carrier}
    {h_idx : forall p : Fin n, (env_M p).1 = (env_N p).1}
    (cd : CompData sig I ms ms' budget env_M env_N h_idx)
    (j : I) (c : (ms j).carrier) (c' : (ms' j).carrier)
    (hbound : cd.sz j + 1 < budget)
    (h_ext_agree : forall nf : NormalForm sig (budget - (cd.sz j + 1)) (cd.sz j + 1),
      nf_eval_nf (ms j) (budget - (cd.sz j + 1)) (cd.sz j + 1) (Fin.cons c (cd.eM j)) nf <->
      nf_eval_nf (ms' j) (budget - (cd.sz j + 1)) (cd.sz j + 1) (Fin.cons c' (cd.eN j)) nf)
    (h_idx' : forall p : Fin (n + 1),
      (Fin.cons (show _ from <j, c>) env_M p).1 = (Fin.cons (show _ from <j, c'>) env_N p).1) :
    CompData sig I ms ms' budget
      (Fin.cons (show _ from <j, c>) env_M)
      (Fin.cons (show _ from <j, c'>) env_N) h_idx' where
  sz := Function.update cd.sz j (cd.sz j + 1)
  eM := fun j' x =>
    if h : j' = j then
      h cast Fin.cons c (cd.eM j) (Fin.cast (by rw [h, Function.update_self]) x)
    else
      cd.eM j' (Fin.cast (Function.update_of_ne h (cd.sz j + 1) cd.sz) x)
  eN := fun j' x =>
    if h : j' = j then
      h cast Fin.cons c' (cd.eN j) (Fin.cast (by rw [h, Function.update_self]) x)
    else
      cd.eN j' (Fin.cast (Function.update_of_ne h (cd.sz j + 1) cd.sz) x)
  agree := fun j' => by
    by_cases h : j' = j
    . subst h; rw [Function.update_self]
      intro nf
      -- eM_new j = Fin.cons c (cd.eM j) up to Fin.cast
      -- Use convert or congr to bridge
      convert h_ext_agree nf using 2
      all_goals { funext x; simp [dif_pos rfl, Fin.cast] }
    . rw [Function.update_of_ne h]
      exact cd.agree j'
  bound := fun j' => by
    by_cases h : j' = j
    . subst h; rw [Function.update_self]; exact hbound
    . rw [Function.update_of_ne h]; exact cd.bound j'
  sz_le_n := fun j' => by
    by_cases h : j' = j
    . subst h; rw [Function.update_self]; exact Nat.succ_le_succ (cd.sz_le_n j)
    . rw [Function.update_of_ne h]; exact Nat.le_succ_of_le (cd.sz_le_n j')
  consistent := fun p j' hj' => by
    cases p using Fin.cases with
    | zero =>
      simp [Fin.cons_zero] at hj'
      subst hj'
      rw [Function.update_self]
      -- Witness: index 0 in the extended array
      exact <0, by simp [dif_pos rfl, Fin.cons_zero], by simp [dif_pos rfl, Fin.cons_zero]>
    | succ k =>
      simp [Fin.cons_succ] at hj'
      obtain <q, hqM, hqN> := cd.consistent k j' hj'
      by_cases hjj : j' = j
      . subst hjj; rw [Function.update_self]
        exact <<q.val + 1, by omega>, by simp [dif_pos rfl, Fin.cons_succ]; exact hqM,
          by simp [dif_pos rfl, Fin.cons_succ]; exact hqN>
      . rw [Function.update_of_ne hjj]
        exact <q, hqM, hqN>
```

### Call Site Pattern (Oracle)

After defining the helper, each oracle cd' construction becomes:

```lean
have cd' := cd.extend j c c' hbound h_ext_agree h_idx'
exact build_bicompat d (n + 1) (by omega) _ _ _ h_atoms_ext cd'
```

This replaces the current 40+ line inline construction.

### cd0 in sum_lift_one_var

cd0 is structurally different (initial construction, not extension of existing cd). It sets `sz j' = if j' = i then 1 else 0`. The helper is for EXTENDING (incrementing sz j by 1), not for initial construction. For cd0, the simplest fix is:

1. Change `sz := fun j' => if j' = i then 1 else 0` to `sz := Function.update (fun _ => 0) i 1`
2. Use the same `rw [Function.update_self]` / `rw [Function.update_of_ne h]` pattern in its proof fields

This is a direct substitution that doesn't require the helper but still eliminates the motive problem.

## Key Technical Insight

The motive error in `rw [if_pos rfl]` occurs because:
1. The term `if (j = j) then X else Y` contains `@ite _ (j = j) (LinearOrder.toDecidableEq j j) X Y`
2. The Decidable instance `LinearOrder.toDecidableEq j j` has type `Decidable (j = j)`
3. When rw abstracts over `(j = j)` to create the motive, it must also abstract the Decidable instance, creating a dependent motive that doesn't typecheck

`Function.update f j v j` hides this: it appears as `Function.update f j v j` -- a simple 4-argument function application. The Decidable instance is internal to `Function.update`'s definition. Rewriting `Function.update f j v j` to `v` via `Function.update_self` only needs the standard congruence lemma, no dependent motive.

## Confidence Assessment

| Finding | Confidence | Evidence |
|---------|------------|----------|
| Function.update eliminates motive issue | HIGH | Verified in lean_run_code with actual LinearOrder |
| CompData.extend helper compiles | HIGH | Full prototype with all fields including consistent |
| No new imports needed | HIGH | Verified Function.update_self/of_ne available from existing imports |
| agree field needs convert/congr bridge | MEDIUM | The eM definition via dite is not definitionally equal to Fin.cons; needs propositional equality |
| cd0 handled by same Function.update pattern | HIGH | Simpler version of the same technique |
| Sigma/Fin.cases approaches not viable | HIGH | Fundamental type theory reasons (abstract I) |
