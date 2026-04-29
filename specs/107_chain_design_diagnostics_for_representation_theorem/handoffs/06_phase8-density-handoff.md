# Phase 8 Handoff: Density Fix — g_content Invariant Gap

## Status

Phase 8 is [IN PROGRESS]. The density sorry site at line 1130 of
`CounterexampleElimination.lean` has been analyzed in full. The plan says to apply
`lemma_2_6_splitting`, but a structural gap prevents this: `lemma_2_6_splitting` requires
`h_gc : g_content A ⊆ C`, and this is NOT available from the current
`eliminate_potential_counterexample` API (which only takes `h_c0` and `h_c2'`).

## The Sorry Site

File: `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean`
Line: 1130

The goal at the sorry (after `simp only [ite_false, ha]`) is:
```
BurgessR3Maximal (χ.f pc.x) (if True ∨ False ∧ z = pc.y then χ.g pc.x pc.y else χ.g pc.x z) (χ.f pc.x)
```
which simplifies to:
```
BurgessR3Maximal (χ.f pc.x) (χ.g pc.x pc.y) (χ.f pc.x)
```

This is the **self-pair problem**: the current density construction sets `f(z) = χ.f pc.x`,
making the new pair (pc.x, z) have identical left and right endpoints A and A.

## Root Cause Analysis

### What `lemma_2_6_splitting` requires

```
theorem lemma_2_6_splitting {A B C : Set Formula}
    (h_mcs_A : SetMaximalConsistent A)
    (h_mcs_C : SetMaximalConsistent C)
    (h_r3m : BurgessR3Maximal A B C)
    (h_gc : g_content A ⊆ C)       -- ← THIS IS THE PROBLEM
    (β : Formula)
    (h_β_not_B : β ∉ B) :
    ∃ B' D B'', BurgessR3Maximal A B' D ∧
      BurgessR3Maximal D B'' C ∧
      SetMaximalConsistent D ∧ β.neg ∈ D
```

The `h_gc : g_content A ⊆ C` hypothesis is essential — it drives the seed consistency
proof inside `splitting_seed_consistent`. Without it, the seed `{β.neg} ∪ g_content A ∪ h_content C`
cannot be shown consistent.

### Why `h_gc` cannot be derived

The current `eliminate_potential_counterexample` signature:
```
noncomputable def eliminate_potential_counterexample
    (χ : Chronicle) (h_c0 : χ.c0) (h_c2' : χ.c2')
    (pc : PotentialCounterexample) : EliminationResult χ pc
```

From `h_c2' pc.x pc.y h_adj : BurgessR3Maximal (χ.f pc.x) (χ.g pc.x pc.y) (χ.f pc.y)`,
we CANNOT derive `g_content (χ.f pc.x) ⊆ χ.f pc.y` because:

1. `g_content_sub_B_of_BurgessR3Maximal` requires `h_gc : g_content A ⊆ C` as INPUT (circular!)
2. `g_content_subset_mcs` (which would give `g_content A ⊆ A`) is sorry'd because
   `G(φ) → φ` is INVALID under strict semantics (BX9 removed)
3. No other lemma derives `g_content A ⊆ C` from `BurgessR3Maximal A B C` alone

### Other approaches that fail

- Using `f(z) = χ.f pc.y`: creates self-pair for (z, pc.y)
- Using the empty set as g': ∅ is NOT ClosedUnderDerivation (⊤ ∉ ∅)
- Using `{⊤}` as seed for Lindenbaum: gives arbitrary D with no BurgessR3Maximal guarantee
- `g_content A ⊆ A`: not provable under strict semantics (G(φ) → φ invalid)

## Required Fix: Add `h_gc_adj` Invariant

The correct fix requires adding a new invariant tracking `g_content (χ.f x) ⊆ χ.f y`
for adjacent pairs throughout the omega-chain.

### Step 1: Add hypothesis to `eliminate_potential_counterexample`

```lean
noncomputable def eliminate_potential_counterexample
    (χ : Chronicle) (h_c0 : χ.c0) (h_c2' : χ.c2')
    -- NEW: g_content ordering for adjacent pairs
    (h_gc_adj : ∀ x y : Rat, Adjacent χ.dom x y → g_content (χ.f x) ⊆ χ.f y)
    (pc : PotentialCounterexample) : EliminationResult χ pc
```

### Step 2: Add `gc_adj` field to `EliminationResult`

```lean
structure EliminationResult (χ : Chronicle) (pc : PotentialCounterexample) where
  val : Chronicle
  dom_sub : χ.dom ⊆ val.dom
  c0 : val.c0
  c2' : val.c2'
  -- NEW: the g_content ordering is preserved for the new chronicle
  gc_adj : ∀ x y : Rat, Adjacent val.dom x y → g_content (val.f x) ⊆ val.f y
  f_agrees : ∀ x ∈ χ.dom, val.f x = χ.f x
  g_agrees : ∀ a b, a ∈ χ.dom → b ∈ χ.dom → val.g a b = χ.g a b
  ... (other fields unchanged)
```

### Step 3: Prove `gc_adj` in each case

**Density case** (the problematic one):
- From `h_gc_adj pc.x pc.y h_adj_orig` we get `h_gc : g_content (χ.f pc.x) ⊆ χ.f pc.y`
- Now apply `lemma_2_6_splitting` with β = Formula.bot (∉ B since B is consistent)
- Get `B', D, B''` with `BurgessR3Maximal(f(x), B', D)` and `BurgessR3Maximal(D, B'', f(y))`
- New chronicle: `f(z) = D`, `g(x,z) = B'`, `g(z,y) = B''`
- New adjacent pairs are (x,z) with `BurgessR3Maximal(f(x), B', D)` and (z,y) with `BurgessR3Maximal(D, B'', f(y))`
- For `gc_adj` of new chronicle: adjacent pairs in new dom are:
  - (x, z): need `g_content(f(x)) ⊆ D`. Since `lemma_2_6_splitting` gives D with `β.neg ∈ D` and `g_content A ⊆ D` (from the splitting_seed construction in `lemma_2_6_splitting`), we have `g_content(f(x)) ⊆ D`. ← VERIFY this comes out of lemma_2_6_splitting
  - (z, y): need `g_content(D) ⊆ f(y)`. The splitting gives `BurgessR3Maximal(D, B'', C)`. For this we need `g_content D ⊆ C`. This may require separate argument.
  - Old adjacent pairs (unchanged): `h_gc_adj` carries over since f and g are unchanged

Note: The `lemma_2_6_splitting` currently outputs `β.neg ∈ D` and `BurgessR3Maximal A B' D ∧ BurgessR3Maximal D B'' C`, but does NOT directly output `g_content A ⊆ D` or `g_content D ⊆ C`. Check the internal proof to see what IS proved.

### Looking inside `lemma_2_6_splitting`

From the proof at lines 923-937 of PointInsertion.lean:
```lean
  have h_gc_AD : g_content A ⊆ D :=
    fun φ hφ => h_sup (Set.mem_union_left _ (Set.mem_union_right _ hφ))
  have h_hc_CD : h_content C ⊆ D :=
    fun φ hφ => h_sup (Set.mem_union_right _ hφ)
  have h_gc_DC : g_content D ⊆ C :=
    h_content_subset_implies_g_content_reverse C D h_mcs_C h_D_mcs h_hc_CD
```

So internally, `lemma_2_6_splitting` proves both:
- `g_content A ⊆ D`
- `g_content D ⊆ C`

But these are NOT returned in the output type! The output is:
```
∃ B' D B'', BurgessR3Maximal A B' D ∧ BurgessR3Maximal D B'' C ∧ SetMaximalConsistent D ∧ β.neg ∈ D
```

## Full Implementation Plan

### Task A: Extend `lemma_2_6_splitting` return type

Add `g_content A ⊆ D` and `g_content D ⊆ C` to the return type:
```lean
theorem lemma_2_6_splitting ... :
    ∃ B' D B'', BurgessR3Maximal A B' D ∧
      BurgessR3Maximal D B'' C ∧
      SetMaximalConsistent D ∧ β.neg ∈ D ∧
      g_content A ⊆ D ∧ g_content D ⊆ C   -- NEW
```

These are already proved internally (h_gc_AD, h_gc_DC), just not returned.

### Task B: Add `h_gc_adj` to `EliminationResult`

Add the `gc_adj` field to `EliminationResult` in CounterexampleElimination.lean.

### Task C: Add `h_gc_adj` parameter to `eliminate_potential_counterexample`

Update the signature to take `h_gc_adj` as an additional hypothesis.

### Task D: Prove `gc_adj` in the density case

Using the extended `lemma_2_6_splitting` output:
- New f(z) = D, g(x,z) = B', g(z,y) = B''
- For (x,z): `g_content(f(x)) ⊆ D` — from `h_gc_AD`
- For (z,y): `g_content(D) ⊆ f(y)` — from `h_gc_DC`
- For old pairs: use `h_gc_adj` directly (f and g unchanged for old points)

### Task E: Prove `gc_adj` in C5/C5' cases

For the C5 case: new point y' has f(y') = C from lemma_2_4. We have `g_content A ⊆ C`
from `lemma_2_4`'s return. So adjacent pairs involving y' can be handled.

For C4 cases: similarly verify the new pairs satisfy `g_content` condition.

### Task F: Update `omega_chain` to pass `h_gc_adj`

Add `gc_adj` to the `omega_chain` invariant:
```lean
noncomputable def omega_chain (A : Set Formula) (h_mcs : SetMaximalConsistent A) :
    (n : Nat) → { χ : Chronicle // χ.c0 ∧ χ.c2' ∧
        (∀ x y, Adjacent χ.dom x y → g_content (χ.f x) ⊆ χ.f y) }
```

Initial case: singleton chronicle has no adjacent pairs — vacuously true.

## What NOT to Change

- The `BurgessR3Maximal` definition — it's correct
- The `EliminationResult` dom_sub/f_agrees/g_agrees/witness fields
- The `ChronicleInvariant` structure (C0, C1, C2', C3)
- The strategy of using `lemma_2_6_splitting` for the density case

## Files to Modify

1. `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean`
   - Extend `lemma_2_6_splitting` return type to include `g_content A ⊆ D ∧ g_content D ⊆ C`

2. `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean`
   - Add `h_gc_adj` parameter to `eliminate_potential_counterexample`
   - Add `gc_adj` field to `EliminationResult`
   - Restructure density case: use `lemma_2_6_splitting` instead of self-pair
   - Prove `gc_adj` in all cases (density + C5/C5' + C4/C4')

3. `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleConstruction.lean`
   - Update `omega_chain` type signature to carry `gc_adj`
   - Pass `h_gc_adj` to `eliminate_potential_counterexample`

## Key Lemma References

- `lemma_2_6_splitting` (PointInsertion.lean:913)
  - Internal proofs h_gc_AD, h_gc_DC (lines 929, 933) that need to be exported
- `g_content_sub_B_of_BurgessR3Maximal` (PointInsertion.lean:824) - requires h_gc
- `h_content_subset_implies_g_content_reverse` (ChronicleConstruction.lean or PointInsertion.lean)
- `dcs_ssubset_univ` (PointInsertion.lean:703) - used to show Formula.bot ∉ B

## Beta Choice

Use `β = Formula.bot`:
- `Formula.bot ∉ χ.g pc.x pc.y`: From `h_r3m.1.1 : SetConsistent (χ.g pc.x pc.y)`,
  if `Formula.bot ∈ χ.g pc.x pc.y` then `SetConsistent` applied to `[Formula.bot]`
  gives `Consistent [Formula.bot]`, which is false since `DerivationTree [Formula.bot] Formula.bot`
  holds (assumption). Prove as: `dcs_ssubset_univ h_r3m.1` gives `B ⊂ Set.univ`,
  which means B ≠ Set.univ, so ∃ φ ∉ B. More directly: show `Formula.bot ∉ B` via `h_r3m.1.1`.

Actually cleaner: use `dcs_ssubset_univ` to get `B ⊂ Set.univ`, then conclude `Formula.bot ∉ B` from:
```lean
have h_B_ssubset : B ⊂ Set.univ := dcs_ssubset_univ h_r3m.1
-- B ⊂ Set.univ means B ≠ Set.univ, so ∃ φ ∉ B
-- Bot specifically: if bot ∈ B, then consistency fails (show directly)
have h_bot_not_B : Formula.bot ∉ B := fun h_bot =>
  h_r3m.1.1 [Formula.bot] (fun ψ hψ => by simp at hψ; rw [hψ]; exact h_bot)
    ⟨DerivationTree.assumption [Formula.bot] Formula.bot (by simp)⟩
```

## Session Information

- Session started: 2026-04-29T22:20Z
- Context at handoff: ~70% (estimated)
- Work completed: Full analysis of the sorry site, root cause identified, complete fix plan
- Work remaining: Implementation (Tasks A-F above)
