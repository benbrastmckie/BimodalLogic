# Guard API Map for U(T,bot) C5 Witnesses

## 1. ChronicleConstruction.lean API

### 1.1 `limit_satisfies_c5_strong` (line 1440)

```lean
theorem limit_satisfies_c5_strong (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (x : Rat) (hx : x ∈ limit_dom A h_mcs)
    (ξ η : Formula)
    (h_until : Formula.untl η ξ ∈ limit_f A h_mcs x) :
    ∃ y ∈ limit_dom A h_mcs, x < y ∧ η ∈ limit_f A h_mcs y ∧
      ξ ∈ limit_g A h_mcs x y
```

**English**: Given `U(η,ξ) ∈ limit_f(x)`, produces witness `y > x` in `limit_dom` with `η ∈ limit_f(y)` and the full guard `ξ ∈ limit_g(x,y)`, meaning `ξ ∈ limit_f(w)` for ALL `w ∈ limit_dom` between `x` and `y`.

**Key for U(T,bot)**: When `ξ = bot` and `η = top`, the guard says `bot ∈ limit_f(w)` for all `w` between `x` and `y`. Since `bot` is never in any MCS (`bot_not_in_mcs`), this means there are NO limit_dom points between `x` and `y`. This is exactly the successor property.

### 1.2 `limit_satisfies_c5_weak` (line 636)

```lean
theorem limit_satisfies_c5_weak (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (x : Rat) (hx : x ∈ limit_dom A h_mcs)
    (ξ η : Formula)
    (h_until : Formula.untl η ξ ∈ limit_f A h_mcs x) :
    ∃ y ∈ limit_dom A h_mcs, x < y ∧ η ∈ limit_f A h_mcs y
```

**English**: Weaker version without the guard. Only provides witness `y` with `η ∈ limit_f(y)`.

### 1.3 `adj_g_mem_limit_f` (line 1367)

```lean
theorem adj_g_mem_limit_f (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (k : Nat)
    (a b : Rat) (h_adj : Adjacent (omega_chain_val A h_mcs k).dom a b)
    (φ : Formula) (hφ : φ ∈ (omega_chain_val A h_mcs k).g a b)
    (w : Rat) (hw : w ∈ limit_dom A h_mcs) (haw : a < w) (hwb : w < b) :
    φ ∈ limit_f A h_mcs w
```

**English**: If `φ ∈ g_k(a,b)` at finite stage `k` for adjacent pair `(a,b)` in `dom(k)`, then `φ ∈ limit_f(w)` for any `w ∈ limit_dom` between `a` and `b`.

**Proof mechanism**: By strong induction on the first stage `m` where `w` enters the domain. Uses `g_sub_f_insert` (old g-values flow into new f-values when a point is inserted) and `g_sub_g_new` (old g-values split into new g-values of sub-intervals).

### 1.4 `exists_containing_adjacent` (line 1389)

```lean
theorem exists_containing_adjacent (D : Finset Rat) (x y w : Rat)
    (hx : x ∈ D) (hy : y ∈ D) (hxy : x < y) (hw_not : w ∉ D)
    (hxw : x < w) (hwy : w < y) :
    ∃ a b, Adjacent D a b ∧ x ≤ a ∧ b ≤ y ∧ a < w ∧ w < b
```

**English**: Given `x, y ∈ D` with `x < w < y` and `w ∉ D`, there exists an adjacent pair `(a,b)` in `D` containing `w` (i.e., `a < w < b`), with `x ≤ a` and `b ≤ y`. Uses max/min of filtered sets.

### 1.5 `omega_chain_c5_forward_resolved_no_new` (line 1212)

```lean
theorem omega_chain_c5_forward_resolved_no_new (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (n : Nat) (x : Rat) (ξ η : Formula)
    (hn_eq : counterexample_enum (Nat.unpair n).2 = ⟨x, 0, ξ, η, .c5_forward⟩)
    (hx : x ∈ (omega_chain_val A h_mcs n).dom)
    (h_until : Formula.untl η ξ ∈ (omega_chain_val A h_mcs n).f x)
    (h_wit : ∃ y ∈ (omega_chain_val A h_mcs n).dom, x < y ∧
      η ∈ (omega_chain_val A h_mcs n).f y ∧
      (∀ a b, Adjacent (omega_chain_val A h_mcs n).dom a b →
        x ≤ a → b ≤ y → ξ ∈ (omega_chain_val A h_mcs n).g a b) ∧
      (∀ w ∈ (omega_chain_val A h_mcs n).dom,
        x < w → w < y → ξ ∈ (omega_chain_val A h_mcs n).f w))
    (u : Rat) (hu : u ∈ (omega_chain_val A h_mcs (n + 1)).dom) :
    u ∈ (omega_chain_val A h_mcs n).dom
```

**English**: When the C5 forward counterexample at step `n` is ALREADY resolved (a witness with proper guard exists in `dom_n`), the elimination is identity: `dom_{n+1} ⊆ dom_n`. No new points are added.

### 1.6 `omega_chain_dom_new_unique` (line 1196)

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

**English**: Each elimination step inserts AT MOST one new domain point. If both `u` and `v` are new at step `n+1`, then `u = v`.

### 1.7 `omega_chain_g_sub_f_insert` (line 1262)

```lean
theorem omega_chain_g_sub_f_insert (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (n : Nat)
    (a b : Rat) (h_adj : Adjacent (omega_chain_val A h_mcs n).dom a b)
    (w : Rat) (hw : w ∈ (omega_chain_val A h_mcs (n + 1)).dom)
    (hw_not : w ∉ (omega_chain_val A h_mcs n).dom)
    (haw : a < w) (hwb : w < b) :
    (omega_chain_val A h_mcs n).g a b ⊆
    (omega_chain_val A h_mcs (n + 1)).f w
```

**English**: When a new point `w` is inserted between adjacent `(a,b)` in `dom(n)`, the old interval set `g_n(a,b)` is contained in `f_{n+1}(w)`. This is the key property that makes `adj_g_mem_limit_f` work.

### 1.8 `omega_chain_g_sub_g_new` (line 1276)

```lean
theorem omega_chain_g_sub_g_new (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (n : Nat)
    (a b : Rat) (h_adj : Adjacent (omega_chain_val A h_mcs n).dom a b)
    (w : Rat) (hw : w ∈ (omega_chain_val A h_mcs (n + 1)).dom)
    (hw_not : w ∉ (omega_chain_val A h_mcs n).dom)
    (haw : a < w) (hwb : w < b) :
    (omega_chain_val A h_mcs n).g a b ⊆
    (omega_chain_val A h_mcs (n + 1)).g a w ∧
    (omega_chain_val A h_mcs n).g a b ⊆
    (omega_chain_val A h_mcs (n + 1)).g w b
```

**English**: When `w` splits adjacent `(a,b)`, old g-values propagate to both new sub-intervals: `g_n(a,b) ⊆ g_{n+1}(a,w)` and `g_n(a,b) ⊆ g_{n+1}(w,b)`.

### 1.9 `omega_chain_c5_witness` (line 391)

```lean
theorem omega_chain_c5_witness (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (n : Nat) (x : Rat) (ξ η : Formula)
    (hx : x ∈ (omega_chain_val A h_mcs n).dom)
    (h_until : Formula.untl η ξ ∈ (omega_chain_val A h_mcs n).f x)
    (hn_eq : counterexample_enum (Nat.unpair n).2 = ⟨x, 0, ξ, η, .c5_forward⟩) :
    ∃ y ∈ (omega_chain_val A h_mcs (n + 1)).dom,
      x < y ∧ η ∈ (omega_chain_val A h_mcs (n + 1)).f y ∧
      (∀ a b, Adjacent (omega_chain_val A h_mcs (n + 1)).dom a b →
        x ≤ a → b ≤ y → ξ ∈ (omega_chain_val A h_mcs (n + 1)).g a b) ∧
      (∀ w ∈ (omega_chain_val A h_mcs n).dom,
        x < w → w < y → ξ ∈ (omega_chain_val A h_mcs (n + 1)).f w) ∧
      (y ∉ (omega_chain_val A h_mcs n).dom ∨
        ∀ u ∈ (omega_chain_val A h_mcs (n + 1)).dom,
          u ∈ (omega_chain_val A h_mcs n).dom)
```

**English**: The finite-stage C5 witness theorem. When the counterexample `(x, ξ, η)` is processed at step `n`, produces:
1. Witness `y` in `dom(n+1)` with `η ∈ f_{n+1}(y)`
2. Adjacent-pair guard: `ξ ∈ g_{n+1}(a,b)` for all adjacent `(a,b)` between `x` and `y`
3. Domain guard: `ξ ∈ f_{n+1}(w)` for all `w ∈ dom(n)` between `x` and `y`
4. Either `y` is new OR no new points were added (identity case)

### 1.10 Other g/f/dom lemmas

- `omega_chain_f_agrees` (line 323): `f_{n+1}(x) = f_n(x)` for `x ∈ dom(n)`
- `omega_chain_f_agrees_le` (line 344): `f_n(x) = f_m(x)` for `m ≤ n`, `x ∈ dom(m)`
- `omega_chain_g_agrees` (line 359): `g_{n+1}(x,y) = g_n(x,y)` for `x,y ∈ dom(n)`
- `omega_chain_g_agrees_le` (line 370): `g_n(x,y) = g_m(x,y)` for `m ≤ n`, `x,y ∈ dom(m)`
- `omega_chain_dom_mono` (line 314): `dom(n) ⊆ dom(n+1)`
- `omega_chain_dom_mono_le` (line 334): `dom(m) ⊆ dom(n)` for `m ≤ n`
- `limit_f_eq` (line 574): `limit_f(x) = f_n(x)` for any `n` with `x ∈ dom(n)`
- `limit_c0` (line 590): `limit_f(x)` is an MCS for `x ∈ limit_dom`

### 1.11 `limit_g` definition (line 830)

```lean
noncomputable def limit_g (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    : Rat → Rat → Set Formula :=
  fun x z => { φ | ∀ y ∈ limit_dom A h_mcs, x < y → y < z → φ ∈ limit_f A h_mcs y }
```

**English**: `limit_g(x,z)` is the set of formulas in `limit_f(y)` for ALL `y ∈ limit_dom` strictly between `x` and `z`. This is the C3-derived definition. For the C5 strong guard, `ξ ∈ limit_g(x,y)` means exactly that `ξ ∈ limit_f(w)` for all intermediate domain points.


## 2. CounterexampleElimination.lean API

### 2.1 `EliminationResult` structure (line 561)

```lean
structure EliminationResult (χ : Chronicle) (pc : PotentialCounterexample) where
  val : Chronicle
  dom_sub : χ.dom ⊆ val.dom
  c0 : val.c0
  f_agrees : ∀ x ∈ χ.dom, val.f x = χ.f x
  g_agrees : ∀ a b, a ∈ χ.dom → b ∈ χ.dom → val.g a b = χ.g a b
  c2' : val.c2'
  c5_forward_witness : ...  -- (see omega_chain_c5_witness)
  c5_backward_witness : ... -- (mirror)
  c4_forward_witness : ...
  c4_backward_witness : ...
  g_sub_f_insert : ...      -- old g flows into new f
  g_sub_g_new : ...         -- old g splits into new sub-interval g
  dom_new_unique : ...      -- at most one new point
  c5_forward_resolved_no_new : ... -- identity when resolved
  c5_backward_resolved_no_new : ... -- mirror
```

### 2.2 Condition (i) — split vs reuse (line 858)

The condition (i) check at each step of the C5 forward walk is:

```lean
by_cases h_cond_i : Formula.and ξ (Formula.untl η ξ) ∈ χ.f x' ∧ ξ ∈ χ.g pt x'
```

Where `pt` = current start point, `x'` = successor of `pt` in `dom`.

- **Condition (i) holds** (`ξ ∧ U(η,ξ) ∈ f(x')` AND `ξ ∈ g(pt,x')`): Recurse at `x'`, composing the guard. The walk continues forward.
- **Condition (i) fails**: Split at `(pt, x')` using `lemma_2_6_splitting` / `lemma_2_7` / `lemma_2_8`. Insert a new midpoint `z` between `pt` and `x'`.

For U(T,bot) specifically, ξ = bot:
- `Formula.and bot (Formula.untl top bot)` would require `bot ∈ f(x')`, which is impossible (MCS). So condition (i) NEVER holds for the U(T,bot) counterexample.
- This means the U(T,bot) elimination always takes the SPLIT path, inserting a midpoint between the start point and its successor.


## 3. ChronicleToCountermodel.lean API

### 3.1 `limit_dom_has_succ` (line 858)

```lean
theorem limit_dom_has_succ (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (x : Rat) (hx : x ∈ limit_dom A h_mcs)
    (h_next : next_top ∈ limit_f A h_mcs x) :
    ∃ y ∈ limit_dom A h_mcs, x < y ∧
      ∀ w ∈ limit_dom A h_mcs, x < w → w < y → False
```

**English**: When `U(T,bot) ∈ limit_f(x)`, there exists an immediate successor `y` with no limit_dom points between `x` and `y`. Direct consequence of `limit_satisfies_c5_strong` + `bot_not_in_mcs`.

### 3.2 `limitDomSubtype_succ` (line 901)

```lean
noncomputable def limitDomSubtype_succ (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (h_discrete : ∀ x ∈ limit_dom A h_mcs, next_top ∈ limit_f A h_mcs x) :
    LimitDomSubtype A h_mcs → LimitDomSubtype A h_mcs
```

**English**: The noncomputable successor function. Uses `Classical.choose` on `limit_dom_has_succ`.

### 3.3 `limitDomSubtype_succ_le_iff` (line 912)

```lean
theorem limitDomSubtype_succ_le_iff ... (a b : LimitDomSubtype A h_mcs) :
    limitDomSubtype_succ A h_mcs h_discrete a ≤ b ↔ a < b
```

**English**: The key property for `SuccOrder.ofSuccLeIff`. `succ(a) ≤ b iff a < b`.

### 3.4 `succ_orbit_convex` (line 1112)

```lean
private theorem succ_orbit_convex ... (a b : LimitDomSubtype A h_mcs) (n : ℕ)
    (h_le : a ≤ b)
    (h_ub : b ≤ (limitDomSubtype_succ A h_mcs h_discrete)^[n] a) :
    ∃ k ≤ n, (limitDomSubtype_succ A h_mcs h_discrete)^[k] a = b
```

**English**: If `a ≤ b ≤ succ^[n](a)`, then `b = succ^[k](a)` for some `k ≤ n`. Between consecutive succ-iterates there are no domain points.

### 3.5 `limitDomSubtype_isSuccArchimedean` (line 1190) -- THE SORRY

```lean
noncomputable def limitDomSubtype_isSuccArchimedean
    (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (h_discrete : ∀ x ∈ limit_dom A h_mcs, next_top ∈ limit_f A h_mcs x) :
    @IsSuccArchimedean (LimitDomSubtype A h_mcs)
      inferInstance
      (limitDomSubtype_succOrder A h_mcs h_discrete)
```

**Status**: Has a single `sorry` at line 1402. The proof is ~210 lines long and establishes:
- `h_not_cofinal`: assuming `succ^[n](a) < b` for all `n`
- Succ-orbit cast to R converges to supremum `L`
- Pred-chain from `b` stays above `L`
- Three helpers handle `pred(c).val < L`, `pred(c).val = L`, both leading to contradiction
- **The gap case** (`pred(c).val > L` for all `c` above orbit) is the sorry

### 3.6 `bot_not_in_mcs` (TruthLemma.lean, line 63)

```lean
theorem bot_not_in_mcs {S : Set Formula} (h_mcs : SetMaximalConsistent S) :
    Formula.bot ∉ S
```

**English**: Bottom is never in any MCS. Proof: if `bot ∈ S`, then `[bot]` witnesses inconsistency.


## 4. Mathlib API

### 4.1 `IsSuccArchimedean` constructor

```lean
IsSuccArchimedean.mk :
  ∀ {α : Type u_3} [inst : Preorder α] [inst_1 : SuccOrder α],
    (∀ {a b : α}, a ≤ b → ∃ n, Order.succ^[n] a = b) → IsSuccArchimedean α
```

**What it needs**: A proof that for any `a ≤ b`, iterating `Order.succ` from `a` eventually reaches `b`.

### 4.2 `Function.Iterate` key lemmas

- `Function.iterate_zero : f^[0] = id`
- `Function.iterate_one : f^[1] = f`
- `Function.iterate_succ' : f^[n+1] = f ∘ f^[n]`
- `Function.iterate_succ : f^[n+1] = f^[n] ∘ f` (note different order)
- `Function.iterate_add_apply : f^[m+n] x = f^[m] (f^[n] x)`
- `Function.Commute.iterate_self : Function.Commute f (f^[n])` (f commutes with its own iterates)


## 5. The Exact Proof Chain for "No limit_dom Between x and w"

This is the chain the plan v9 needs. Here it is with exact lemma invocations:

### Step 1: Get the C5 witness

```
limit_satisfies_c5_strong A h_mcs x hx Formula.bot top_formula h_next
```
where `h_next : next_top ∈ limit_f A h_mcs x` (i.e., `U(T,bot) ∈ limit_f(x)`).

This gives: `⟨y, hy, hxy, h_top_y, h_guard⟩` where:
- `hy : y ∈ limit_dom A h_mcs`
- `hxy : x < y`
- `h_top_y : top_formula ∈ limit_f A h_mcs y`
- `h_guard : Formula.bot ∈ limit_g A h_mcs x y`

### Step 2: Guard means bot is in limit_f of all intermediate points

`h_guard` unfolds to: `∀ w ∈ limit_dom A h_mcs, x < w → w < y → Formula.bot ∈ limit_f A h_mcs w`

### Step 3: But bot is never in any MCS

For any `w ∈ limit_dom`:
```
bot_not_in_mcs (limit_c0 A h_mcs w hw) : Formula.bot ∉ limit_f A h_mcs w
```

### Step 4: Contradiction gives emptiness

Combining steps 2 and 3: for any `w ∈ limit_dom` with `x < w < y`:
```
h_guard w hw hxw hwy  -- gives: Formula.bot ∈ limit_f A h_mcs w
bot_not_in_mcs (limit_c0 A h_mcs w hw)  -- gives: Formula.bot ∉ limit_f A h_mcs w
```
These contradict, so no such `w` exists.

### This is EXACTLY `limit_dom_has_succ`

The theorem `limit_dom_has_succ` (line 858) does exactly this chain:
```lean
theorem limit_dom_has_succ ... :
    ∃ y ∈ limit_dom A h_mcs, x < y ∧
      ∀ w ∈ limit_dom A h_mcs, x < w → w < y → False := by
  obtain ⟨y, hy, hxy, _, h_guard⟩ :=
    limit_satisfies_c5_strong A h_mcs x hx Formula.bot top_formula h_next
  refine ⟨y, hy, hxy, fun w hw hxw hwy => ?_⟩
  have h_bot := h_guard w hw hxw hwy
  exact bot_not_in_mcs (limit_c0 A h_mcs w hw) h_bot
```


## 6. The Sorry: What Exactly Is Needed

The sorry is in `limitDomSubtype_isSuccArchimedean` at line 1402. The proof has already established:

1. **`h_not_cofinal`**: `∀ n, succ^[n](a) < b` (by contradiction assumption)
2. **`h_below_L_is_orbit`**: any domain point `w` with `a ≤ w` and `w.val < L` (real supremum of orbit) is an orbit element
3. **`h_pred_below_L_contradiction`**: any domain point `c` above the orbit with `pred(c).val < L` leads to False
4. **`h_pred_at_L_contradiction`**: any domain point `c` above the orbit with `pred(c).val = L` leads to False

**What remains** (the sorry): Show that the "gap at L" scenario is impossible. This is the case where for ALL domain points `c` above the orbit, `pred(c).val > L`. In this case there is a "gap" in the rationals at `L` where the orbit sits below and all above-orbit points sit strictly above.

**The construction-specific argument needed**: The omega-chain construction eventually processes the counterexample `(s^[n](a), 0, bot, top, c5_forward)` for each orbit element `s^[n](a)`. The C5 witness for this counterexample is `s^[n+1](a)` (the next orbit element). Since the witness already exists in the domain (at the stage where `s^[n+1](a)` entered), `omega_chain_c5_forward_resolved_no_new` tells us no new point is inserted. BUT the counterexample `(s^[n](a), 0, bot, top, c5_forward)` at an appropriate `(p^[k](b))` ceiling should insert a point in the gap.

The key insight is that for any `s^[n](a)` and `p^[k](b)` with `s^[n](a) < p^[k](b)` and no orbit points between them, the counterexample `(s^[n](a), p^[k](b), ..., c4_forward)` or a density-creating counterexample gets processed. But since we're in the DISCRETE case (U(T,bot) everywhere), density counterexamples don't apply. The argument needs to show that the gap itself contradicts some property of the omega-chain.

**Alternative approach from the existing proof structure**: The three helpers already cover `pred(c).val < L` and `pred(c).val = L`. For the gap case, one needs to show there EXISTS a domain point `c` above the orbit with `pred(c).val ≤ L`. The pred-chain `p^[k](b)` is strictly decreasing and bounded below by `L`. In R, this sequence converges. If it converges to some `M > L`, there is a "double gap" which the omega-chain construction must fill via C5/C4 counterexample processing. The surjectivity of `counterexample_enum` guarantees every potential counterexample is processed, and `exists_containing_adjacent` guarantees adjacent pairs that span the gap eventually get split.
