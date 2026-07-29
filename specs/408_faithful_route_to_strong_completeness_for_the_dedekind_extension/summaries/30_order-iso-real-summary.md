# Phase 28 — `orderIsoRealOfDedekindDenseSeparable`: the order characterization of `ℝ`

- **Task**: 408, faithful route to strong completeness for the Dedekind extension
- **Plan**: `plans/10_strong-completeness-dedekind-v10.md`, Phase 28
- **Status**: `[COMPLETED]`
- **Session**: `sess_1785337808_19a89c_408`
- **Commits**: `ce349825f` (phase 28.1), `ef43679a8` (phase 28.2)

## What was landed

### `FormalSystem/Metalogic/WeakCanonical/RealModel/OrderIsoReal.lean` (new, 335 lines)

Imports **only Mathlib**. The module is the free-floating unit the wave map describes, and stays
that way.

| Declaration | Role |
|---|---|
| `IsRealLike` | The six-clause hypothesis bundle (`nonempty'`, `dense`, `noMax`, `noMin`, `lub`, `sep`) with the Rule 6 "what this excludes" paragraph |
| `nonempty_orderIso_rat_of_countableDense` | Step 1 — `↥D ≃o ℚ`, the one step delegated to Mathlib (`Order.iso_of_countable_dense`) |
| `cutSet`, `cutMap` | Step 2 — `cutMap e x = sSup {(e d : ℝ) ∣ d ∈ D, d < x}` |
| `cutSet_nonempty`, `cutSet_bddAbove_of`, `cutSet_bddAbove` | Well-definedness of the supremum |
| `cutMap_le_of`, `le_cutMap_of` | The two one-sided bounds every later step uses |
| `strictMono_cutMap` | Step 3a — strict monotonicity, from two applications of density of `D` |
| `preCut`, `preCut_nonempty`, `preCut_bddAbove` | The `R`-side cut determined by a real |
| `cutMap_surjective` | Step 3b — Dedekind completeness of `R` against `exists_rat_btwn` in `ℝ` |
| **`orderIsoRealOfDedekindDenseSeparable`** | **The deliverable**: `IsRealLike R → Nonempty (R ≃o ℝ)` |
| `nonempty_orderIso_real_of_facts` | Unbundled convenience form |
| `countableDense_rat_real`, `isRealLike_real`, `nonempty_orderIso_real_real` | Anti-vacuity, base case |

### `FormalSystem/Metalogic/WeakCanonical/RealModel/ShuffleReal.lean` (append-only, +83 lines)

| Declaration | Role |
|---|---|
| `isRealLike_shuffleReal` | Feeds the five Phase 27 order facts into the bundle |
| **`nonempty_orderIso_real_shuffleReal`** | The last sentence of Reynolds' printed p.188 paragraph: the flow of `Σ_{r∈ℝ} σ*(r)` is `≃o ℝ` |
| `pointStructure_subsingleton`, `nonempty_orderIso_real_shuffleReal_point` | Anti-vacuity for that theorem, at the constant one-point palette |

## Proof shape

1. `D ⊆ R` countable and order-dense makes `↥D` countable, densely ordered, endpointless and
   non-empty; Cantor's isomorphism theorem (Mathlib) gives `e : ↥D ≃o ℚ`.
2. `cutMap e x := sSup ((e ·) '' {d : ↥D ∣ (d : R) < x})`. Non-empty because `R` has no least
   element and `D` is dense; bounded above because `R` has no greatest element and `D` is dense.
3. Strict monotonicity: for `x < y` pick `d₁ < d₂` in `D` strictly between; then
   `cutMap x ≤ e d₁ < e d₂ ≤ cutMap y`.
4. Surjectivity: for `r : ℝ`, let `u` be the `R`-lub (Dedekind completeness) of
   `{d ∈ D ∣ e d < r}`. `cutMap u ≤ r` because any `d < u` fails to bound that set, so lies below
   a member of it. `r ≤ cutMap u` because every rational `q < r` has `e.symm q < u` strictly —
   equality is refuted by a rational strictly between `q` and `r` — hence `q ≤ cutMap u`.
5. `StrictMono.orderIsoOfSurjective` closes it.

## Mathlib negative result (recorded so it is not repeated)

At Lean `v4.33.0-rc1` / Mathlib tag `v4.33.0-rc1`:

- `loogle "Nonempty (?a ≃o ℝ)"` — **zero results**.
- `loogle "?a ≃o ℝ"` — only `Real.tanOrderIso`, `Real.sinhOrderIso`,
  `CircleDeg1Lift.toOrderIso`: specific isomorphisms, never a characterization.
- `Mathlib.Order.CountableDenseLinearOrder` stops at `Order.iso_of_countable_dense` (countable
  orders only) and `Order.embedding_from_countable_to_dense`.
- Uniqueness of `ℝ` in Mathlib is **field**-theoretic
  (`Mathlib.Algebra.Order.CompleteField`, `ConditionallyCompleteLinearOrderedField`), a hypothesis
  unavailable here: the flows this development characterizes carry no arithmetic.
- `leansearch` returned HTTP 502 and was not retried; the two `loogle` queries are decisive alone.

So only step 1 is delegated. Steps 2-3 are original work for this development, as the docstring
states — Reynolds asserts the characterization in one sentence and gives no proof.

## Verification

| Check | Result |
|---|---|
| `lake build FormalSystem.Metalogic.WeakCanonical.RealModel.OrderIsoReal` | green, **zero warnings** |
| `lake build FormalSystem.Metalogic.WeakCanonical.RealModel.ShuffleReal` | green (2207 jobs); only pre-existing warnings |
| Full `lake build` | green (1983 jobs) — see the reachability finding below |
| Sorry census outside `Boneyard/` | **1** (`Transfer.lean:1242`, pre-existing) — unchanged |
| Vacuous definitions | 1, pre-existing and unrelated (`Examples/TemporalStructures.lean:279`) |
| `axiom` declarations | 2, unchanged from baseline |
| `#print axioms` on all 8 new theorems | exactly `[propext, Classical.choice, Quot.sound]`; no `sorryAx` |
| Regression canaries | `BXCanonical.completeness_dense`, `BXCanonical.completeness_discrete`, `WeakCanonical.countermodel_discrete_reynolds_v2` — all three `[propext, Classical.choice, Quot.sound]` |

## Deviation from the `Owns` line

The phase owns `RealModel/OrderIsoReal.lean` only. The **non-trivial** anti-vacuity instantiation
was landed append-only in `RealModel/ShuffleReal.lean` (Phase 27's file, `[COMPLETED]`, no live
conflict) plus one added `import`. Importing `ShuffleReal` into `OrderIsoReal` instead would have
inverted the layering and made the characterization depend on the whole Doets chain.

## Finding for Phases 29-30 — `RealModel/**` is unreachable from the default build target

Verified, not assumed. `lakefile.lean` sets `roots := #[FormalSystem]`, and nothing in the
`FormalSystem.lean → FormalSystem/FormalSystem.lean → Metalogic.lean →
Metalogic/WeakCanonical.lean` chain imports any `RealModel/*` module: `grep -rn '^import.*RealModel'`
matches only inside `RealModel/` itself. Measured consequence: full `lake build` runs **1983 jobs**
while the scoped `ShuffleReal` build runs **2207**.

So "full `lake build` green" does **not** cover Blocks G-H. The scoped builds are the real
verification and both are green. This is pre-existing from Phases 24-27 and was **not** repaired
here: `Metalogic/WeakCanonical.lean` is in no phase's `Owns` list and `FormalSystem/Metalogic.lean`
belongs to Phase 30, which should add the reachability edge when it updates the tracking table.
