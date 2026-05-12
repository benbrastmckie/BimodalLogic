# Boundary Cases in the Omega-Chain Construction

**Task**: 123 - fix_c5_witness_bot_and_prove_icc_finite
**Purpose**: Provide the implementation agent with exact code references for boundary case handling in the C5 forward/backward walk, singleton chronicle, and the plan v9 induction.

---

## 1. C5 Forward Walk: The "Beyond Max" Case

**File**: `CounterexampleElimination.lean`
**Function**: `c5_forward_walk` (line 668)

The walk is structured as follows at each step from `start`:

1. Compute `max_old = dom.max' h_dom_ne` (line 679)
2. Branch on `h_eq_max : pt = max_old` (line 683)

### Base Case (pt = max(dom)) — Lines 684-822

When `pt` is the maximum element of `dom`, the construction places the witness **beyond all current domain points**.

```
have h_fresh := exists_rat_gt_finset chi.dom    -- line 685
let y := h_fresh.choose                          -- line 686
```

`exists_rat_gt_finset` (lines 76-88) produces `y = dom.max' + 1` (or 0 for empty domain), satisfying:
- `forall s in dom, s < y` (line 687)
- `y not in dom` (line 688)

The witness is placed at this fresh `y`, with:
- `f'(y) = C` where C is an MCS from `lemma_2_4_with_guard` containing `eta` (line 694)
- `g'(max_old, y) = B` where B is a `BurgessR3Maximal(f(pt), B, C)` set containing `xi` (line 696)
- `g'(a, b) = chi.g(a, b)` for all other pairs (lines 698-700)

**Key property**: the `domain_guard` field (line 817-821) is trivially satisfied because pt = max(dom) means NO domain point w satisfies `pt < w`, so the guard interval `(pt, y)` contains no old domain points:

```lean
intro w hw hsw _
exact absurd (h_max_le w hw) (not_le.mpr (h_eq_max ▸ hsw))
```

**Key property**: the `witness_guard` field (lines 764-790) shows `xi in g'(a, b)` for all adjacent pairs `(a, b)` with `pt <= a` and `b <= y`. The only such pair is `(max_old, y)`, and `xi in B = g'(max_old, y)`.

### Recursive Case (pt < max_old) — Lines 823 onward

When `pt` is NOT the maximum, the walk finds `x'` = immediate successor of `pt` in dom (line 828), then case-splits:

- **Condition (i)** (line 858): `and(xi, untl(eta, xi)) in f(x')` AND `xi in g(pt, x')` => recurse from `x'`
- **Not condition (i)** (line 966): split at `(pt, x')` using lemma 2.7/2.8/2.6, placing witness at midpoint `z = (pt + x') / 2` (line 1058)

In the split case, the witness is the midpoint `z = (pt + x') / 2`, which is between `pt` and `x'` (NOT beyond max). The `domain_guard` (lines 1193-1198) is vacuous because `(pt, x')` are adjacent — no old domain points exist between them.

---

## 2. C5 Backward Walk: The "Below Min" Case

**File**: `CounterexampleElimination.lean`
**Function**: `c5_backward_walk` (line 1252)

Mirrors the forward walk exactly. At each step from `start`:

1. Compute `min_old = dom.min' h_dom_ne`
2. Branch on `h_eq_min : pt = min_old`

### Base Case (pt = min(dom))

Uses `exists_rat_lt_finset` (lines 94-106) to produce `y = dom.min' - 1` satisfying:
- `forall s in dom, y < s`
- `y not in dom`

The witness is placed below all current domain points. The construction mirrors the forward case: `f'(y) = C` from `lemma_2_4_since_with_guard`, `g'(y, min_old) = B` for the interval set.

### Recursive Case (pt > min_old)

Finds `x''` = immediate predecessor of `pt` in dom, then condition (i) check and splitting at `(x'', pt)`.

---

## 3. dom(0) and the Singleton Chronicle

**File**: `ChronicleConstruction.lean`
**Definition**: `singleton_chronicle` (line 64)

```lean
noncomputable def singleton_chronicle (A : Set Formula) : Chronicle :=
  { f := fun _ => A
    g := fun _ _ => emptyset
    dom := {(0 : Rat)} }
```

### Verified: dom(0) = {0}

- `singleton_dom` (line 83): `(singleton_chronicle A).dom = {(0 : Rat)}` is `rfl`
- `singleton_f_zero` (line 89): `(singleton_chronicle A).f 0 = A` is `rfl`

### omega_chain at step 0

The omega chain at step 0 is explicitly the singleton chronicle:

```lean
noncomputable def omega_chain (A : Set Formula) (h_mcs : SetMaximalConsistent A) :
    (n : Nat) -> { chi : Chronicle // chi.c0 /\ chi.c2' }
  | 0 => ⟨singleton_chronicle A, ⟨singleton_c0 h_mcs, singleton_c2' h_mcs⟩⟩
```
(line 253-255)

So `omega_chain_val A h_mcs 0 = singleton_chronicle A`, and `(omega_chain_val A h_mcs 0).dom = {0}`.

### All conditions vacuously true

`singleton_invariant` (line 96-111) proves `ChronicleInvariant (singleton_chronicle A)` with all conditions (C1, C2', C3) vacuously true since `{0}` has no pairs `x < y`.

- C1: `x, y in {0}, x < y` => `0 < 0`, contradiction via `lt_irrefl` (line 101-102)
- C2': Adjacent pairs require two distinct points, impossible in `{0}` (line 103-107)
- C3: Triples `x < y < z` impossible in `{0}` (line 108-111)
- C4: Pairs `x < y` impossible (line 139-145)
- C4': Pairs `y < x` impossible (line 150-155)

---

## 4. NoMaxOrder and NoMinOrder for LimitDomSubtype

**File**: `ChronicleToCountermodel.lean`

### NoMaxOrder — Lines 130-136

```lean
instance limitDomSubtype_noMaxOrder (A : Set Formula) (h_mcs : SetMaximalConsistent A) :
    NoMaxOrder (LimitDomSubtype A h_mcs) where
  exists_gt := by
    intro ⟨a, ha⟩
    obtain ⟨y, hy, hay⟩ := limit_dom_no_max A h_mcs a ha
    exact ⟨⟨y, hy⟩, hay⟩
```

This uses `limit_dom_no_max` (lines 96-106), which works by:

1. Every point `x` in limit_dom maps to an MCS (by `limit_c0`)
2. The seriality axiom `serial_future` gives `F(top) in limit_f(x)`
3. `limit_F_resolution` produces `y > x` in limit_dom

The chain: `top in MCS => serial_future => F(top) in MCS => BX12 => U(top, top) in MCS => limit_satisfies_c5_weak => witness y in limit_dom`

### NoMinOrder — Lines 141-147

Mirror using `limit_dom_no_min` (lines 115-125), which uses `serial_past` and `limit_P_resolution`.

### Key: These do NOT use density

Both NoMaxOrder and NoMinOrder are unconditional — they do not require the `h_discrete` hypothesis or any density condition. They follow purely from seriality axioms and the limit C5 satisfaction.

---

## 5. Plan v9 Induction: Base Case (N = 0)

**Statement** (from plan v9, lines 600-602):

> Base N = 0: dom(0) = {0}. So a.val = b.val = 0. a = b. k = 0.

This is correct. The proof should be:

```lean
-- Base case: dom(0) = {0}, so a.val = 0 and b.val = 0
-- Hence a = b (as Subtype elements with same val), and k = 0
simp [omega_chain_val, omega_chain, singleton_chronicle, Finset.mem_singleton] at ha hb
-- ha : a.val = 0, hb : b.val = 0
subst ha; subst hb
exact ⟨0, by simp⟩  -- or use Subtype.ext + rfl
```

**Verification**: `omega_chain_val A h_mcs 0 = singleton_chronicle A`, so `(omega_chain_val A h_mcs 0).dom = {(0 : Rat)}`. If `a.val in {0}` then `a.val = 0`, and similarly for `b.val`. Since `a` and `b` are subtypes of `{q : Rat // q in limit_dom}` with `a.val = b.val = 0`, they are equal by `Subtype.ext`.

---

## 6. Plan v9 Inductive Step: Boundary Handling

### The New Point at Stage N+1

At stage `N+1`, at most ONE new point enters the domain (from `omega_chain_dom_new_unique`, line 1196 of `ChronicleConstruction.lean`). This new point was produced by `eliminate_potential_counterexample`.

### How new points are placed — all cases

**Case A: C5 forward, base case (beyond max)**

- New point `y > max(dom(N))`
- The counterexample point `pt = max(dom(N))`
- `y = exists_rat_gt_finset.choose` (typically `max + 1`)
- Bot-guard: no limit_dom between `pt` and `y`
- `succ(pt) = y` in limit_dom

**Plan v9 handling**: If `a` is this new point (`a.val = y > max(dom(N))`), then `a.val > all dom(N) points`. Since `b.val` must be in `dom(N+1)`, either:
- `b.val in dom(N)`: then `b.val <= max(dom(N)) < a.val`, contradicting `a <= b`
- `b.val = a.val` (unique new point): `a = b`, `k = 0`

So `a` beyond max with `a <= b` forces `a = b`. This case is trivial.

**Case B: C5 forward, split case (midpoint)**

- New point `z = (pt + ceiling) / 2` where `pt` and `ceiling` are adjacent in dom(N)
- Bot-guard: no limit_dom between `pt` and `z`
- `succ(pt) = z` in limit_dom
- `z < ceiling`, both `pt` and `ceiling` are in dom(N)

**Plan v9 handling**: If `a` is this new point, then `a` is between two dom(N) points `pt` and `ceiling`. By IH applied to `(pt, ceiling)` (both in dom(N)), `succ^[m](pt) = ceiling`. By `succ_orbit_convex` with `pt <= a <= ceiling`, `succ^[j](pt) = a` for some `j`. Then `succ^[m-j](a) = ceiling`. If `b` is in dom(N), extend by IH from `ceiling`. If `b = a`, `k = 0`.

**Case C: C5 backward, base case (below min)**

- New point `y < min(dom(N))`
- `succ(y) = pt` where `pt` is the counterexample point (with no limit_dom between `y` and `pt`)

**Plan v9 handling**: If `a` is this new point, then `a < all dom(N) points`. `succ(a) = pt` where `pt in dom(N)`. If `b in dom(N)`, IH gives `succ^[m](pt) = b`, so `succ^[m+1](a) = b`. If `b = a`, `k = 0`.

If `b` is this new point with `a in dom(N)`: impossible since `b < min(dom(N)) <= a.val`, contradicting `a <= b`.

**Case D: C5 backward, split case (midpoint)**

- New point `z = (floor + pt) / 2` between `floor` and `pt` in dom(N)
- Same handling as Case B via orbit convexity

**Case E: C4 forward/backward (density counterexample)**

- New point `z = (w + w_next) / 2` between two adjacent dom(N) points
- NO bot-guard (guard formula is not bot)
- Same handling as Case B via orbit convexity — the new point is between two dom(N) points

### The Critical Adjacency Argument (from plan v9, lines 337-346)

For adjacent dom(N) points `a_val < b_val` where the C5-bot counterexample at `a_val` was processed at stage M <= N-1:

1. The C5-bot witness `y` enters at stage `M+1 <= N`, so `y in dom(N)`.
2. Bot-guard: no limit_dom between `a_val` and `y`, so `succ(a_val) = y`.
3. `succ_le_iff`: `succ(a_val) <= b_val` (since `a_val < b_val`), so `y <= b_val`.
4. `y in dom(N)` with `a_val < y <= b_val`.
5. Since `a_val` and `b_val` are adjacent in dom(N), no dom(N) point strictly between them. But `y in dom(N)` with `a_val < y`. If `y < b_val`, then `y` is a dom(N) point strictly between `a_val` and `b_val` — contradicting adjacency.
6. Therefore `y = b_val`, i.e., `succ(a_val) = b_val`.

**This is the key structural fact** that makes the stage-walk work: for adjacent dom(N) points where C5-bot is resolved, `succ` maps the lower to the upper directly.

### Existence of the "good" N (plan v9, lines 450-453)

The plan identifies a potential circularity: choosing N large enough that ALL dom(N) points in [a, b] have their C5-bot resolved. The resolution is the **induction on N** approach (plan v9, lines 596-698), which avoids needing a fixed-point N entirely:

- Base: N = 0, dom(0) = {0}, a = b.
- Step: N -> N+1. Case split on whether a, b are old (in dom(N)) or new (the unique point at stage N+1). For old points, apply IH. For new points, identify the bracketing dom(N) points and use IH + orbit convexity.

This approach **never needs to find a "good N"** — it works by induction on the chain stage itself.

---

## 7. Key Code References Summary

| Concept | File | Line(s) | Key function/theorem |
|---------|------|---------|---------------------|
| Singleton chronicle | ChronicleConstruction.lean | 64 | `singleton_chronicle` |
| dom(0) = {0} | ChronicleConstruction.lean | 83 | `singleton_dom` |
| C5 forward walk | CounterexampleElimination.lean | 668 | `c5_forward_walk` |
| Base case (beyond max) | CounterexampleElimination.lean | 684-822 | inside `c5_forward_walk` |
| Split case (midpoint) | CounterexampleElimination.lean | 966-1199 | inside `c5_forward_walk` |
| exists_rat_gt_finset | CounterexampleElimination.lean | 76-88 | `exists_rat_gt_finset` |
| exists_rat_lt_finset | CounterexampleElimination.lean | 94-106 | `exists_rat_lt_finset` |
| EliminationResult | CounterexampleElimination.lean | 561 | `EliminationResult` |
| dom_new_unique | CounterexampleElimination.lean | 601 | field of `EliminationResult` |
| NoMaxOrder proof | ChronicleToCountermodel.lean | 130-136 | `limitDomSubtype_noMaxOrder` |
| NoMinOrder proof | ChronicleToCountermodel.lean | 141-147 | `limitDomSubtype_noMinOrder` |
| succ_orbit_convex | ChronicleToCountermodel.lean | 1112 | `succ_orbit_convex` |
| Sorry site | ChronicleToCountermodel.lean | 1402 | inside `limitDomSubtype_isSuccArchimedean` |
| omega_chain definition | ChronicleConstruction.lean | 253 | `omega_chain` |
| omega_chain_dom_new_unique | ChronicleConstruction.lean | 1196 | `omega_chain_dom_new_unique` |
| limit_dom_has_succ | ChronicleToCountermodel.lean | 858 | `limit_dom_has_succ` |
| limitDomSubtype_succ | ChronicleToCountermodel.lean | 901 | `limitDomSubtype_succ` |
