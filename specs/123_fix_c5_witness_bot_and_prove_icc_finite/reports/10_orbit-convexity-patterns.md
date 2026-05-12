# Orbit Convexity and Stage Induction Patterns

Focused research for plan v9 implementation of `limitDomSubtype_isSuccArchimedean`.

## Part 1: succ_orbit_convex

### Location

File: `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean`
Lines: 1107-1132
Visibility: `private theorem`

### Exact Type Signature

```lean
private theorem succ_orbit_convex (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (h_discrete : ∀ x ∈ limit_dom A h_mcs, next_top ∈ limit_f A h_mcs x)
    (a b : LimitDomSubtype A h_mcs) (n : ℕ)
    (h_le : a ≤ b)
    (h_ub : b ≤ (limitDomSubtype_succ A h_mcs h_discrete)^[n] a) :
    ∃ k ≤ n, (limitDomSubtype_succ A h_mcs h_discrete)^[k] a = b
```

### Input/Output Summary

**Inputs:**
- `a, b : LimitDomSubtype A h_mcs` -- two domain points
- `n : Nat` -- iteration count
- `h_le : a ≤ b` -- a is at most b
- `h_ub : b ≤ succ^[n] a` -- b is at most succ^[n](a)

**Output:**
- `∃ k ≤ n, succ^[k] a = b` -- there exists k ≤ n such that succ^[k](a) = b

### Proof Structure (sorry-free)

The proof is complete, uses induction on `n`:
- **Base case (n=0):** `b ≤ succ^[0] a = a` combined with `a ≤ b` gives `a = b`, so `k = 0`.
- **Inductive step (n+1):** Case split `b ≤ succ^[n] a` vs `b > succ^[n] a`:
  - If `b ≤ succ^[n] a`: apply IH, get `k ≤ n`, weaken to `k ≤ n+1`.
  - If `b > succ^[n] a`: then `succ(succ^[n] a) ≤ b` (from `limitDomSubtype_succ_le_iff`), combined with `b ≤ succ^[n+1] a = succ(succ^[n] a)` gives equality, so `k = n+1`.

### Circularity Check: NONE

`succ_orbit_convex` does NOT depend on `IsSuccArchimedean`. It only uses:
- `limitDomSubtype_succ_le_iff` (characterizes succ in terms of <)
- Standard `le_antisymm`, `le_or_gt`, `Function.iterate_succ_apply'`

There is no circularity. `succ_orbit_convex` is a lemma USED BY the `IsSuccArchimedean` proof, not dependent on it.

### How It Is Used in the IsSuccArchimedean Proof

At line 1199-1202, the `IsSuccArchimedean` proof reduces to:
```lean
suffices ∃ n, b ≤ (limitDomSubtype_succ A h_mcs h_discrete)^[n] a by
  obtain ⟨n, hn⟩ := this
  exact (succ_orbit_convex A h_mcs h_discrete a b n hab hn).imp fun k ⟨_, hk⟩ => hk
```

So the strategy is: prove `∃ n, b ≤ succ^[n] a` (orbit cofinality), then `succ_orbit_convex` extracts exact equality.

## Part 2: The Sorry — Orbit Cofinality

### Location of the Sorry

File: `ChronicleToCountermodel.lean`, line 1402.
Inside: `limitDomSubtype_isSuccArchimedean` (lines 1190-1402).

### What Is Already Proved (sorry-free)

The proof establishes these helper lemmas before the sorry:

1. **h_below_L_is_orbit** (lines 1276-1299): Any domain point `w` with `a ≤ w` and `w.val < L` (as reals) is an orbit element `w = s^[k] a` for some `k`.

2. **h_pred_below_L_contradiction** (lines 1301-1321): Any domain point `c` above the orbit with `(pred c).val < L` leads to `False`.

3. **h_pred_at_L_contradiction** (lines 1323-1372): Any domain point `c` above the orbit with `(pred c).val = L` leads to `False`.

4. **h_orbit_lt_pred** (lines 1230-1250): `succ^[n] a < pred^[k] b` for all `n, k` (orbit stays below the pred-chain from b).

5. **h_succ_pred_iter** (lines 1219-1229): `succ^[k](pred^[k](x)) = x` (cancellation).

### What the Sorry Needs

The sorry at line 1402 needs to prove `False` from the "gap at L" scenario:
- For ALL domain points `c` above the orbit: `(pred c).val > L`
- The orbit values converge to `L` from below
- The pred-chain from `b` stays above `L`
- There is a "gap" in the domain at the real value `L`

The comment (lines 1392-1401) explains the needed argument:
> Between any orbit element s^[n] a and any pred-chain element p^[k] b,
> the omega-chain construction processes counterexamples that either:
> (1) insert a domain point in the gap, eventually producing one with
>     pred value ≤ L, or
> (2) directly resolve the gap by connecting the orbit to the pred-chain.
> The key properties are omega_chain_dom_new_unique (at most one new point
> per stage), omega_chain_c5_forward_resolved_no_new (resolved counterexamples
> stay resolved), and the surjectivity of counterexample_enum (every
> counterexample is eventually processed).

## Part 3: Stage Induction Infrastructure

### omega_chain_val Definition

File: `ChronicleConstruction.lean`, lines 265-267
```lean
noncomputable def omega_chain_val (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (n : Nat) : Chronicle :=
  (omega_chain A h_mcs n).val
```

### omega_chain Definition

File: `ChronicleConstruction.lean`, lines 253-260
```lean
noncomputable def omega_chain (A : Set Formula) (h_mcs : SetMaximalConsistent A) :
    (n : Nat) → { χ : Chronicle // χ.c0 ∧ χ.c2' }
  | 0 => ⟨singleton_chronicle A, ⟨singleton_c0 h_mcs, singleton_c2' h_mcs⟩⟩
  | n + 1 =>
    let prev := omega_chain A h_mcs n
    let pc := counterexample_enum (Nat.unpair n).2
    let elim := eliminate_potential_counterexample prev.val prev.property.1 prev.property.2 pc
    ⟨elim.val, ⟨elim.c0, elim.c2'⟩⟩
```

### Chronicle.dom Type

File: `ChronicleTypes.lean`, line 380
```lean
dom : Finset Rat
```

Each finite stage has `dom : Finset Rat`. The limit domain is `Set Rat`:
```lean
noncomputable def limit_dom (A : Set Formula) (h_mcs : SetMaximalConsistent A) : Set Rat :=
  { x | ∃ n : Nat, x ∈ (omega_chain_val A h_mcs n).dom }
```

### omega_chain_dom_new_unique

File: `ChronicleConstruction.lean`, lines 1196-1208
```lean
theorem omega_chain_dom_new_unique (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (n : Nat)
    (u v : Rat)
    (hu : u ∈ (omega_chain_val A h_mcs (n + 1)).dom)
    (hu_not : u ∉ (omega_chain_val A h_mcs n).dom)
    (hv : v ∈ (omega_chain_val A h_mcs (n + 1)).dom)
    (hv_not : v ∉ (omega_chain_val A h_mcs n).dom) :
    u = v
```

**Meaning:** At most ONE new point is inserted per elimination step. If both `u` and `v` are in `dom(n+1)` but not `dom(n)`, then `u = v`.

**What it does NOT say:** It does not tell you WHERE the new point is inserted (its rational value relative to existing points). For that, you need the `EliminationResult` fields like `new_point_after` from `C5ForwardWalkResult`.

### eliminate_potential_counterexample

This takes a chronicle and a potential counterexample and processes it. Each step either:
1. Inserts a new point (if the counterexample is unresolved)
2. Does nothing (if already resolved)

The `EliminationResult` structure (line 595-618) provides:
- `dom_sub : χ.dom ⊆ val.dom` -- domain grows
- `dom_new_unique` -- at most one new point
- `g_sub_f_insert` -- old g-values inherited at new point's f
- `c5_forward_resolved_no_new` / `c5_backward_resolved_no_new` -- no new point when already resolved

### counterexample_enum Surjectivity

File: `ChronicleConstruction.lean`, lines 209-210, 223-224
```lean
theorem counterexample_enum_surjective :
    ∀ pc : PotentialCounterexample, ∃ n : Nat, counterexample_enum n = pc

theorem counterexample_enum_surjective_above (pc : PotentialCounterexample) (k : Nat) :
    ∃ n : Nat, n ≥ k ∧ counterexample_enum (Nat.unpair n).2 = pc
```

This is critical: every potential counterexample is eventually processed, and for any lower bound `k`, there's a stage `n ≥ k` that processes it.

### Key Domain Monotonicity Lemmas

```lean
-- dom(n) ⊆ dom(n+1)
theorem omega_chain_dom_mono : (omega_chain_val A h_mcs n).dom ⊆ (omega_chain_val A h_mcs (n + 1)).dom

-- dom(m) ⊆ dom(n) for m ≤ n
theorem omega_chain_dom_mono_le {m n} (h : m ≤ n) :
    (omega_chain_val A h_mcs m).dom ⊆ (omega_chain_val A h_mcs n).dom

-- f agrees on old points
theorem omega_chain_f_agrees (n) (x) (hx : x ∈ dom(n)) :
    f_{n+1}(x) = f_n(x)

-- g agrees on old pairs
theorem omega_chain_g_agrees (n) (x y) (hx : x ∈ dom(n)) (hy : y ∈ dom(n)) :
    g_{n+1}(x,y) = g_n(x,y)
```

### New Point Location Information

The `C5ForwardWalkResult` (line 626-649) provides:
```lean
new_point_after : ∀ w ∈ val.dom, w ∉ χ.dom → start < w
```
New points are always AFTER the starting point of the counterexample.

The `g_sub_f_insert` field:
```lean
g_sub_f_insert : ∀ a b, Adjacent χ.dom a b → ∀ w ∈ val.dom, w ∉ χ.dom →
    a < w → w < b → χ.g a b ⊆ val.f w
```
New points are inserted BETWEEN adjacent pairs `a < w < b`, inheriting the old `g(a,b)` into `f(w)`.

## Part 4: The IsSuccArchimedean Instance

### Constructor Signature (from Mathlib)

```lean
IsSuccArchimedean.mk {α : Type u_3} [Preorder α] [SuccOrder α]
    (exists_succ_iterate_of_le : ∀ {a b : α}, a ≤ b → ∃ n, Order.succ^[n] a = b) :
    IsSuccArchimedean α
```

### How the Codebase Constructs It

File: `ChronicleToCountermodel.lean`, lines 1190-1196
```lean
noncomputable def limitDomSubtype_isSuccArchimedean
    (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (h_discrete : ∀ x ∈ limit_dom A h_mcs, next_top ∈ limit_f A h_mcs x) :
    @IsSuccArchimedean (LimitDomSubtype A h_mcs)
      inferInstance
      (limitDomSubtype_succOrder A h_mcs h_discrete) :=
  @IsSuccArchimedean.mk _ _ (limitDomSubtype_succOrder A h_mcs h_discrete) <| by
    intro a b hab
    change ∃ n, (limitDomSubtype_succ A h_mcs h_discrete)^[n] a = b
    ...
```

Key pattern:
1. Uses `@IsSuccArchimedean.mk` with explicit `SuccOrder` instance (because it's not a typeclass instance, it's a def)
2. Uses `change` to unfold `Order.succ` to `limitDomSubtype_succ` (they're definitionally equal via `SuccOrder.ofSuccLeIff`)
3. Reduces to proving `∃ n, (limitDomSubtype_succ ...)^[n] a = b`
4. Then uses the `suffices` trick: prove `∃ n, b ≤ succ^[n] a` and apply `succ_orbit_convex`

### Downstream Usage

Once `IsSuccArchimedean` is established, it is used at line 2316:
```lean
letI := limitDomSubtype_isSuccArchimedean A h_mcs h_discrete
```
This enables `exists_succ_iterate_of_le` (Mathlib's API) which is used in `succ_embed_surjective` at line 2337:
```lean
obtain ⟨n, hn⟩ := exists_succ_iterate_of_le h_le
```

### LimitDomSubtype Definition

```lean
abbrev LimitDomSubtype (A : Set Formula) (h_mcs : SetMaximalConsistent A) :=
  {q : Rat // q ∈ limit_dom A h_mcs}
```

It is a subtype of `Rat`, inheriting `LinearOrder` from `Rat`.

## Part 5: Finset Sort and Walk Patterns

### Finset.sort for Rationals

Mathlib provides:
```lean
-- Sort a finset into a list using a relation
Finset.sort (s : Finset α) (r : α → α → Prop) : List α

-- The sorted list is strictly increasing
Finset.sort_sorted_lt {α} [LinearOrder α] (s : Finset α) :
    (s.sort (· ≤ ·)).SortedLT

-- sort_cons: prepending minimum element
Finset.sort_cons (r) {a} (h : ∀ b ∈ s, r a b) (h₂ : a ∉ s) :
    (Finset.cons a s h₂).sort r = a :: s.sort r
```

### Pattern for Walking Through dom(N) ∩ [a,b]

The dom at stage N is `(omega_chain_val A h_mcs N).dom : Finset Rat`. To get the points between `a` and `b`:

```lean
-- Filter to get points in [a, b]
let points := (omega_chain_val A h_mcs N).dom.filter (fun x => a ≤ x ∧ x ≤ b)

-- Sort them
let sorted := points.sort (· ≤ ·)

-- The sorted list is strictly increasing
have h_sorted := Finset.sort_sorted_lt points
```

### List.Chain for Adjacency

`List.Chain` is available (imported in `Quasimodel/Construction.lean`):
```lean
import Mathlib.Data.List.Chain
```

`List.Chain R a l` means `R a (head l)`, `R (head l) (head (tail l))`, etc.

### Adjacent Definition

```lean
def Adjacent (dom : Finset Rat) (x y : Rat) : Prop :=
  x ∈ dom ∧ y ∈ dom ∧ x < y ∧ ∀ z ∈ dom, ¬(x < z ∧ z < y)
```

### Recommended Induction Pattern

For walking through `dom(N) ∩ [a,b]` using succ, the most natural approach is NOT Finset induction but rather Nat induction on the number of steps, using `succ_orbit_convex` and the orbit structure.

Given `a ≤ b` in the limit domain, and both `a, b ∈ dom(N)` for some stage N:
1. The points in dom(N) between a and b form a finite set
2. Since dom(N) is finite with a linear order, the points can be enumerated as `a = x_0 < x_1 < ... < x_m = b`
3. Each consecutive pair `(x_i, x_{i+1})` is Adjacent in dom(N)

However, the actual proof of `IsSuccArchimedean` does NOT use a finite walk through dom(N). Instead, it uses real analysis (monotone bounded convergence) to derive a contradiction from the assumption that the orbit never reaches `b`.

## Part 6: Summary of the Sorry and What Is Needed

### The Single Sorry

Location: `ChronicleToCountermodel.lean:1402`
In: `limitDomSubtype_isSuccArchimedean`

### Proof State at the Sorry

At the sorry, we have:
- `a ≤ b` in `LimitDomSubtype`
- `h_not_cofinal : ∀ n, succ^[n] a < b` (the orbit never reaches b)
- `L : Real` = supremum of orbit values, `L ≤ pred^[k] b` for all k
- For all domain points c above the orbit: `(pred c).val > L` (gap scenario)
- The orbit fills all domain points with values < L
- The pred-chain from b stays above L

### What Must Be Proved

`False` -- i.e., the gap scenario is impossible.

### Strategy (from comment)

Use the omega-chain construction: between any orbit element and any pred-chain element, there are counterexamples that eventually get processed, inserting points that close the gap. Specifically:
1. Pick orbit element `s^[n] a` and pred-chain element `p^[k] b`
2. There exists a C5 counterexample involving some point in the gap
3. `counterexample_enum_surjective_above` ensures it gets processed
4. Processing either inserts a point with `pred` value ≤ L (contradiction via helper) or connects the orbit to the pred-chain

The key difficulty: identifying WHICH counterexample to use and showing that its processing actually inserts a point in the right location.

### Dependencies for the Sorry Fix

The fix needs:
- `counterexample_enum_surjective_above` (exists)
- `omega_chain_dom_new_unique` (exists)
- `omega_chain_c5_forward_resolved_no_new` (exists)
- `h_pred_below_L_contradiction` and `h_pred_at_L_contradiction` (exist, in scope)
- `h_below_L_is_orbit` (exists, in scope)
- Construction-specific knowledge about WHICH counterexamples arise from the gap
