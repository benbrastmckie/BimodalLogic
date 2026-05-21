# Lean 4 Pigeonhole Patterns for `pigeonhole_definable_formula`

## Context

The sorry at line 604 of `ExpressivenessGeneral.lean` needs a pigeonhole argument:
- `NormalForm sig r 1` is `Fintype` with cardinality `N = nfCount (Fintype.card sig.preds) r 1`
- A chain of failure points `u_0, u_1, ...` is constructed with pairwise distinct NF types
- After `N+1` steps, too many distinct elements for a finite type, giving contradiction

The proof sits inside `pigeonhole_definable_formula` which argues by contradiction:
`h_no_cofinal` says every formula eventually holds in the cut, and `h_cofinal_failure`
says some formula always fails above any cut point. The chain construction forces
the failing formula to keep changing, which forces distinct NF types.

## Key Mathlib Lemmas

### 1. `Fintype.card_le_of_injective` (RECOMMENDED -- Primary Tool)

```
-- Import: Mathlib.Data.Fintype.Card
Fintype.card_le_of_injective :
  {alpha : Type} {beta : Type} [Fintype alpha] [Fintype beta]
  (f : alpha -> beta) -> Function.Injective f -> Fintype.card alpha <= Fintype.card beta
```

**Usage**: Build `u : Fin (N+1) -> NormalForm sig r 1` injective, then
`Fintype.card (Fin (N+1)) <= Fintype.card (NormalForm sig r 1)` gives `N+1 <= N`,
contradiction via `omega`.

Verified compilation:
```lean
example {alpha : Type} [Fintype alpha] [DecidableEq alpha]
    (N : Nat) (hN : N = Fintype.card alpha)
    (f : Fin (N + 1) -> alpha) (hf : Function.Injective f) : False := by
  have h1 : Fintype.card (Fin (N + 1)) <= Fintype.card alpha :=
    Fintype.card_le_of_injective f hf
  simp [Fintype.card_fin] at h1
  omega
```

### 2. `Fintype.exists_ne_map_eq_of_card_lt` (Alternative -- Gives Witnesses)

```
-- Import: Mathlib.Data.Fintype.Pigeonhole
Fintype.exists_ne_map_eq_of_card_lt :
  {alpha : Type} {beta : Type} [Fintype alpha] [Fintype beta]
  (f : alpha -> beta) -> Fintype.card beta < Fintype.card alpha ->
  exists x y, x != y and f x = f y
```

**Usage**: Same setup, but instead of showing `f` is injective and deriving
contradiction, you get explicit `x != y` with `f x = f y`, then show this
contradicts the chain's distinct-NF-type property.

Verified compilation:
```lean
example {alpha : Type} [Fintype alpha] [DecidableEq alpha]
    (N : Nat) (hN : N = Fintype.card alpha)
    (f : Fin (N + 1) -> alpha) (hf : Function.Injective f) : False := by
  have hcard : Fintype.card alpha < Fintype.card (Fin (N + 1)) := by
    simp [Fintype.card_fin]; omega
  obtain <x, y, hne, heq> := Fintype.exists_ne_map_eq_of_card_lt f (hN |> hcard)
  exact hne (hf heq)
```

### 3. `Finset.le_card_of_inj_on_range` (Alternative -- Uses `Nat` Directly)

```
-- Import: Mathlib.Data.Finset.Card
Finset.le_card_of_inj_on_range :
  {alpha : Type} {s : Finset alpha} {n : Nat} (f : Nat -> alpha) ->
  (forall i < n, f i in s) ->
  (forall i < n, forall j < n, f i = f j -> i = j) ->
  n <= s.card
```

**Usage**: Build `f : Nat -> NormalForm sig r 1` via Nat.rec, show it is injective
on `{0, ..., N}`. Then `N+1 <= Finset.univ.card = N`, contradiction.

Verified compilation:
```lean
example {alpha : Type} [Fintype alpha] [DecidableEq alpha]
    (f : Nat -> alpha) (N : Nat) (hN : N = Fintype.card alpha)
    (hinj : forall i < N + 1, forall j < N + 1, f i = f j -> i = j) : False := by
  have h1 : N + 1 <= (Finset.univ : Finset alpha).card := by
    apply Finset.le_card_of_inj_on_range f
    . intro i _; exact Finset.mem_univ _
    . exact hinj
  simp [Finset.card_univ] at h1
  omega
```

### 4. `not_injective_infinite_finite` (For Infinite-Source Arguments)

```
-- Import: Mathlib.Data.Fintype.EquivFin
not_injective_infinite_finite :
  {alpha : Sort} {beta : Sort} [Infinite alpha] [Finite beta]
  (f : alpha -> beta) -> not (Function.Injective f)
```

**Usage**: If you can show the cut is `Infinite` as a type, this gives non-injectivity
of any function to a finite type directly. Less useful here because the cut is a subset,
not a standalone type.

### 5. `Finite.exists_infinite_fiber` (For Direct Cofinal Extraction)

```
-- Import: Mathlib.Data.Fintype.Pigeonhole
Finite.exists_infinite_fiber :
  {alpha : Type} {beta : Type} [Infinite alpha] [Finite beta]
  (f : alpha -> beta) -> exists y, Infinite (f ^-1' {y})
```

**Usage**: If the cut were shown to be `Infinite` as a subtype, this gives an
infinite fiber under the NF map. Could potentially replace the chain construction.
See Section 5 below for analysis.

### 6. `Fintype.false` (Simple Contradiction)

```
-- Import: Mathlib.Data.Fintype.EquivFin
Fintype.false : {alpha : Type} [Infinite alpha] (h : Fintype alpha) -> False
```

**Usage**: If you derive both `Infinite` and `Fintype` on the same type.

## Recommended Approach for `pigeonhole_definable_formula`

### Why the Chain Is Needed

The chain construction cannot be replaced by a simpler argument because:

1. `h_cofinal_failure` gives: for each cut point `p`, there exists `u >= p` in the cut
   and SOME formula `A` that fails at `u`.
2. `h_no_cofinal` gives: for each specific formula `D`, there is a bound above which
   `D` holds at all cut points.
3. The formula that fails keeps CHANGING at each step. The pigeonhole argument
   must show that after enough steps, the NF type repeats, which means the same
   formulas hold at two points, but one was chosen specifically because a formula fails
   there -- contradiction.

A direct infinite-fiber argument (Approach 5) would need the cut to be `Infinite` as a
subtype and would need `nf_determines_stavi_truth` anyway. It saves the chain
construction but adds the overhead of proving the cut is infinite. Overall, the chain
approach is simpler and more self-contained.

### Concrete Proof Sketch

```lean
private theorem pigeonhole_definable_formula ... := by
  by_contra h_no_cofinal
  push_neg at h_no_cofinal
  -- h_no_cofinal : forall D, stavi_depth D <= r -> ... ->
  --   exists t in cut, forall u >= t in cut, stavi_truth u D

  -- Let N = Fintype.card (NormalForm sig r 1)
  set N := Fintype.card (NormalForm sig r 1) with hN_def

  -- Build chain data: for each i in Fin (N+1), produce
  --   (u_i : carrier, A_i : StaviFormula, b_i : carrier)
  -- where:
  --   u_i in cut, depth A_i <= r, A_i holds on interval, not truth(u_i, A_i)
  --   b_i is bound from h_no_cofinal for A_i
  --   u_{i+1} >= max(u_i, b_i) (so A_i holds at u_{i+1})

  -- Step 1: Build the chain by recursion on Fin (N+1)
  -- Use Fin.rec or define a helper function via Nat.rec

  -- The chain ensures: for i < j,
  --   u_j >= b_i, so stavi_truth u_j A_i (A_i holds above bound b_i)
  --   but not stavi_truth u_i A_i (by construction)
  --   Therefore nf(u_i) != nf(u_j) (by nf_determines_stavi_truth)

  -- Step 2: Define nf_map : Fin (N+1) -> NormalForm sig r 1
  --   nf_map i = nf_characteristic ... u_i

  -- Step 3: Show nf_map is injective
  --   If nf_map i = nf_map j for i < j, then by nf_determines_stavi_truth:
  --   stavi_truth u_i A_i <-> stavi_truth u_j A_i
  --   But stavi_truth u_j A_i (since u_j >= b_i) and not stavi_truth u_i A_i.
  --   Contradiction.

  -- Step 4: Apply pigeonhole
  have : Fintype.card (Fin (N + 1)) <= Fintype.card (NormalForm sig r 1) :=
    Fintype.card_le_of_injective nf_map nf_map_injective
  simp [Fintype.card_fin] at this
  omega -- N + 1 <= N is False
```

### Chain Construction Detail

The recursive construction at each step needs:
1. A current cut point `p` (starting from `p_0` given by `h_cut_start`)
2. Apply `h_cofinal_failure` to `p` to get failure point `u` and formula `A`
3. Apply `h_no_cofinal` to `A` to get bound `b`
4. The next starting point is `max(u, b)` (or a cut point above both)
5. Record `(u, A, b)` as the chain data for this step

The bound `b` from `h_no_cofinal` needs to be in the cut and above `p`. The
hypothesis `h_no_cofinal` as stated gives: for formula `D` with depth <= r and
holding on interval, there exists `t` in cut such that all cut points `u >= t`
have `stavi_truth u D`. This `t` serves as `b`.

### Key Dependency: `nf_determines_stavi_truth`

The chain construction requires the sorry'd lemma at line 532:
```lean
private theorem nf_determines_stavi_truth ...
    (h_same_nf : nf_characteristic ... p = nf_characteristic ... q)
    (A : StaviFormula) (hA : stavi_depth A <= r) :
    stavi_temporal_truth N atomMap p A <-> stavi_temporal_truth N atomMap q A
```

This is the bridge from NormalForm equality to formula-truth equality. Without it,
the chain construction cannot derive the needed contradiction. This lemma should
be resolved first (or simultaneously).

## Can the Chain Be Replaced?

### Option A: Direct Max-of-Bounds (DOES NOT WORK)

Take the max bound over all formulas. This fails because `StaviFormula` is an
infinite inductive type -- there is no finite set of "all formulas with depth <= r"
available as a Lean term (even though the set is logically finite via NormalForm
correspondence).

### Option B: `Finite.exists_infinite_fiber` (POSSIBLE BUT HARDER)

1. Show the cut is `Set.Infinite` (follows from `h_cofinal_failure` by induction)
2. Coerce to subtype, show `Infinite` instance
3. Apply `Finite.exists_infinite_fiber` to `nf : cut_subtype -> NormalForm`
4. Get infinite fiber (infinitely many cut points with same NF type)
5. Within that fiber, for any formula D, `h_no_cofinal` gives a bound
6. Above the bound, D holds at all fiber points
7. But `h_cofinal_failure` gives a failure point above any bound
8. If the failure point is in the fiber, it must agree on all formulas (same NF type),
   but some formula fails there -- contradiction

This avoids building the explicit chain but requires:
- Proving `Set.Infinite (inf_carrier_cut S_C)` (straightforward)
- Converting between `Set.Infinite` and `Infinite` subtype instance
- Working with the fiber as a subtype
- More bookkeeping overall

**Verdict**: The explicit chain with `Fin (N+1)` is cleaner and more direct.

### Option C: `exists_seq_of_forall_finset_exists` (ELEGANT BUT OVERKILL)

```
exists_seq_of_forall_finset_exists :
  (P : alpha -> Prop) (r : alpha -> alpha -> Prop) ->
  (forall s : Finset alpha, (forall x in s, P x) ->
    exists y, P y and forall x in s, r x y) ->
  exists f, (forall n, P (f n)) and forall m n, m < n -> r (f m) (f n)
```

This builds an infinite sequence with properties, which could construct the
chain automatically. However, it produces `f : Nat -> alpha` (infinite sequence),
and we only need `Fin (N+1) -> alpha`. Using it would add unnecessary complexity.

## Existing Pigeonhole Usage in ProofChecker

The codebase uses `Finset.card_lt_card` in `Construction.lean` (lines 250, 307)
for a decreasing defect-set argument. This is a different pattern (strict subset
implies smaller cardinality) rather than the injective-into-finite pigeonhole.

No existing usage of `Fintype.card_le_of_injective`, `not_injective_infinite_finite`,
or `Fintype.exists_ne_map_eq_of_card_lt` was found in the codebase.

## Required Imports

```lean
import Mathlib.Data.Fintype.Card        -- Fintype.card_le_of_injective, Fintype.card_fin
import Mathlib.Data.Fintype.Pigeonhole   -- Fintype.exists_ne_map_eq_of_card_lt (alternative)
```

Both are likely already transitively imported via the existing
`import Mathlib.Data.Finset.Sort` at line 2 of `ExpressivenessGeneral.lean`.

## Summary of Recommendations

1. **Best lemma**: `Fintype.card_le_of_injective` from `Mathlib.Data.Fintype.Card`
2. **Proof pattern**: Build chain `u : Fin (N+1) -> carrier` by recursion, define
   `nf_map = nf_characteristic ... o u`, show injective via `nf_determines_stavi_truth`,
   apply `Fintype.card_le_of_injective`, derive `N+1 <= N` contradiction with `omega`
3. **Chain cannot be replaced** with a simpler argument -- the explicit chain is the
   cleanest approach
4. **Resolve `nf_determines_stavi_truth` first** -- the pigeonhole body depends on it
5. **No existing pigeonhole pattern** in the codebase to follow; this will be the first
   injective-into-finite argument
