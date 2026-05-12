# Teammate A Findings: Sorry State Examination

Task: 123 | Date: 2026-05-11

## 1. Sorry Location

**File**: `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean`
**Line**: 1211, column 5
**Definition**: `limitDomSubtype_isSuccArchimedean`
**Kind**: `noncomputable def` (returns an `IsSuccArchimedean` instance)

## 2. Exact Goal State (from lean_goal)

```
A : Set Formula
h_mcs : SetMaximalConsistent A
h_discrete : ∀ x ∈ limit_dom A h_mcs, next_top ∈ limit_f A h_mcs x
a b : LimitDomSubtype A h_mcs
hab : a ≤ b
h_not_cofinal : ∀ (n : ℕ), (limitDomSubtype_succ A h_mcs h_discrete)^[n] a < b
⊢ False
```

**Interpretation**: Given two elements `a ≤ b` in the limit domain subtype, if EVERY iterate of succ applied to `a` is strictly less than `b`, derive a contradiction. This is the heart of the `IsSuccArchimedean` property: finitely many succ steps from `a` must reach `b`.

## 3. Surrounding Code Structure

### Definition being proved (lines 1190-1211)

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
    suffices ∃ n, b ≤ (limitDomSubtype_succ A h_mcs h_discrete)^[n] a by
      obtain ⟨n, hn⟩ := this
      exact (succ_orbit_convex A h_mcs h_discrete a b n hab hn).imp fun k ⟨_, hk⟩ => hk
    by_contra h_not_cofinal
    push_neg at h_not_cofinal
    sorry
```

**Proof structure**: The proof has been reduced via `suffices` to showing the succ-orbit is cofinal (eventually reaches or exceeds `b`). By contradiction, `h_not_cofinal` says every iterate stays strictly below `b`.

### Type context

- `LimitDomSubtype A h_mcs` = `{q : Rat // q ∈ limit_dom A h_mcs}` (subtype of rationals)
- `limit_dom` = `{ x | ∃ n : Nat, x ∈ (omega_chain_val A h_mcs n).dom }` (countable union of finite sets)
- `limitDomSubtype_succ` = classical choose of immediate successor (no domain points between)

## 4. Available Helper Lemmas (in scope)

### Succ/Pred Infrastructure (lines 901-1106)

| Lemma | Type | Line |
|-------|------|------|
| `limitDomSubtype_succ` | `LimitDomSubtype → LimitDomSubtype` | 901 |
| `limitDomSubtype_succ_le_iff` | `succ(a) ≤ b ↔ a < b` | 912 |
| `limitDomSubtype_succOrder` | `SuccOrder LimitDomSubtype` | 941 |
| `limitDomSubtype_pred` | `LimitDomSubtype → LimitDomSubtype` | 952 |
| `limitDomSubtype_le_pred_iff` | `a ≤ pred(b) ↔ a < b` | 964 |
| `limitDomSubtype_predOrder` | `PredOrder LimitDomSubtype` | 994 |
| `order_succ_eq_limitDomSubtype_succ` | `Order.succ = limitDomSubtype_succ` (rfl) | 1006 |
| `order_pred_eq_limitDomSubtype_pred` | `Order.pred = limitDomSubtype_pred` (rfl) | 1017 |
| `limitDomSubtype_succ_pred` | `succ(pred(b)) = b` | 1029 |
| `limitDomSubtype_pred_succ` | `pred(succ(a)) = a` | 1063 |
| `limitDomSubtype_le_pred_of_lt` | `a < b → a ≤ pred(b)` | 1091 |
| `limitDomSubtype_pred_lt` | `pred(b) < b` | 1100 |

### Orbit Infrastructure (lines 1107-1161)

| Lemma | Type | Line |
|-------|------|------|
| `succ_orbit_convex` | `a ≤ b ≤ succ^[n](a) → ∃ k ≤ n, succ^[k](a) = b` | 1112 |
| `succ_iter_le_pred_of_lt_forall` | `(∀ n, succ^[n](a) < b) → succ^[n](a) ≤ pred(b)` | 1155 |
| `succ_iter_eq_gives_next` | `succ^[n₀](a) = c → succ^[n₀+1](a) = succ(c)` | 1167 |

### Monotonicity Infrastructure (lines 1259-1310)

| Lemma | Type | Line |
|-------|------|------|
| `limitDomSubtype_succ_lt` | `a < succ(a)` | 1259 |
| `limitDomSubtype_succ_iter_lt` | `succ^[n](a) < succ^[n+1](a)` | 1269 |
| `limitDomSubtype_succ_iter_mono` | `n ≤ m → succ^[n](a) ≤ succ^[m](a)` | 1280 |
| `limitDomSubtype_succ_iter_strictMono` | `n < m → succ^[n](a) < succ^[m](a)` | 1297 |

### Type-level Properties

| Instance | Line |
|----------|------|
| `Countable LimitDomSubtype` | 86 |
| `NoMaxOrder LimitDomSubtype` | 132 |
| `NoMinOrder LimitDomSubtype` | 143 |
| `Nonempty LimitDomSubtype` | 154 |

## 5. succ_embed_surjective Status

**Lines 2119-2187**: The proof is COMPLETE and sorry-free, conditional on `limitDomSubtype_isSuccArchimedean`. It uses:
1. `letI := limitDomSubtype_isSuccArchimedean A h_mcs h_discrete` (the sorry source)
2. `exists_succ_iterate_of_le` from Mathlib (requires `IsSuccArchimedean`)
3. Case split on `root ≤ w` vs `w < root`
4. `limitDomSubtype_pred_succ` for the negative case

## 6. All Sorry Sites in File

| Line | Definition | Dependency on sorry at 1211? |
|------|------------|------------------------------|
| 839 | `dd_countermodel_chronicle_nondense_sorry` | NO (independent) |
| 1211 | `limitDomSubtype_isSuccArchimedean` | THIS IS THE SORRY |
| 2638 | `dd_countermodel_chronicle_mixed_sorry` | NO (independent) |

Only `limitDomSubtype_isSuccArchimedean` (line 1211) is the blocking sorry for the discrete pipeline. Once this sorry is closed, `succ_embed_surjective` and the entire `dd_countermodel_chronicle_discrete` theorem become sorry-free.

## 7. Imports Already Present

```lean
import Mathlib.Algebra.Order.Ring.Rat
import Mathlib.Algebra.Order.Archimedean.Basic
import Mathlib.Order.CountableDenseLinearOrder
import Mathlib.Order.SuccPred.LinearLocallyFinite
import Mathlib.Topology.Instances.Real.Lemmas
import Mathlib.Topology.Instances.NNReal.Lemmas
import Mathlib.Data.Rat.Cast.Order
```

All imports needed for the monotone convergence approach are ALREADY present.

## 8. Proof Strategy Analysis

### What the proof needs

Given `h_not_cofinal : ∀ n, succ^[n](a) < b`, derive `False`.

### Key deductions from hypotheses

1. `succ^[n](a) ≤ pred(b)` for all `n` (by `succ_iter_le_pred_of_lt_forall`)
2. `succ^[n](a) ≠ pred(b)` for all `n` (otherwise `succ^[n+1](a) = succ(pred(b)) = b`, contradicting `h_not_cofinal`)
3. Therefore `succ^[n](a) < pred(b)` for all `n`
4. By induction on `k`: `succ^[n](a) < pred^[k](b)` for all `n, k`
5. `pred^[k](b)` is strictly decreasing: `pred^[k+1](b) < pred^[k](b)` (by `limitDomSubtype_pred_lt`)
6. `pred^[k](b) > a` for all `k` (since `a = succ^[0](a) < pred^[k](b)`)

### Why contradiction is non-trivial

The above gives two infinite sequences:
- Succ-orbit: `a < succ(a) < succ^2(a) < ...` (increasing, bounded above)
- Pred-orbit: `... < pred^2(b) < pred(b) < b` (decreasing, bounded below)

With every succ-element strictly below every pred-element. In the RATIONALS, this is consistent (think: 0, 1/2, 3/4, ... and ... 15/16, 31/32, 63/64, 1). There's no finite contradiction just from the ordering.

### The convergence argument (planned approach)

1. Cast `pred^[k](b).val` to R: get a monotone decreasing bounded-below sequence
2. By `tendsto_of_monotone` (Mathlib): converges to L = inf in R
3. Cast `succ^[n](a).val` to R: get a monotone increasing bounded-above sequence
4. Converges to M = sup in R, with M ≤ L
5. **Contradiction source**: For large k, `pred^[k](b)` and `pred^[k+1](b)` are consecutive domain points (no domain points between). Their R-distance goes to 0. Meanwhile, for large n, `succ^[n](a).val` is close to M ≤ L, so `succ^[n](a)` is between `pred^[k+1](b)` and `pred^[k](b)` for appropriate n, k. But no domain points should exist between consecutive pred-iterates. Contradiction.

### Alternative: simpler contradiction

Actually, a simpler contradiction exists: since `succ^[n](a) < pred^[k](b)` for all n, k, in particular `succ^[n](a) < pred^[k](b)` for all n, k. But also `pred^[k](b) > a` for all k. Now consider: `pred^[k](b)` is a domain point above all succ-orbit elements. So `pred^[k](b) ≥ succ(succ^[n](a))` for all n (since succ gives the LEAST domain point above, and pred^[k](b) is above succ^[n](a)). This just gives `pred^[k](b) ≥ succ^[n+1](a)`, which we already know.

The convergence argument is genuinely needed. No pure order-theoretic argument works because the "gap at L" configuration is order-theoretically consistent.

## 9. Confidence Assessment

| Aspect | Confidence |
|--------|------------|
| Sorry location and goal state | HIGH (verified via lean_goal) |
| Surrounding infrastructure completeness | HIGH (all helpers exist) |
| succ_embed_surjective conditionality | HIGH (verified — depends only on this sorry) |
| Convergence approach mathematical correctness | HIGH (well-established argument) |
| Convergence approach formalizability in Lean | MEDIUM (requires careful topology API usage) |
| Estimated LOC for proof | 80-120 lines |

## 10. Specific Formalization Concerns

1. **Casting Rat to R**: Need `Rat.cast_le`, `Rat.cast_lt`, `Rat.cast_strictMono` for embedding the ordered sequence into R
2. **Monotone convergence**: `tendsto_of_monotone` or `tendsto_atBot_ciInf` for the decreasing pred-chain
3. **Getting the contradiction**: Need to show that for large enough indices, a succ-orbit element falls in a "gap" of the pred-orbit. This requires:
   - The pred-chain gaps go to 0 in R
   - The succ-orbit approaches the infimum from below
   - Some element of the succ-orbit is between consecutive pred-elements
   - This contradicts the no-between property (immediate predecessor = no domain points between)
4. **No-between property**: We have `limitDomSubtype_succ_le_iff` and `limitDomSubtype_le_pred_iff` which encode the immediate successor/predecessor property. The "no domain points between consecutive elements" is encoded as: if `x < y` and `succ(x) ≤ y` (equivalent to `x < y`), with `succ(x) = y` being the "immediate" case. Between `pred^[k+1](b)` and `pred^[k](b)`, we need `succ(pred^[k+1](b)) = pred^[k](b)` (by `limitDomSubtype_succ_pred`), confirming no domain points between them.
