# Phase 29 (cycle 2): the Theorem 6 assembly

- **Task**: 408 — faithful route to strong completeness for `FrameClass.Dedekind`
- **Phase**: 29, *Doets' Theorem — Reynolds §8 Theorem 6*
- **Plan**: `plans/10_strong-completeness-dedekind-v10.md`
- **Outcome**: partial (skeleton). Heading stays `[PARTIAL]` — the phase's done-when is
  *"`doets_theorem_dense` and the chronicle instantiation are sorry-free and axiom-clean"*, and
  neither holds.

## What landed

Three green commits, all on one Lean file
(`FormalSystem/Metalogic/WeakCanonical/RealModel/DoetsTheorem.lean`).

| Commit | Layer | Content |
|---|---|---|
| `0553eea3b` | 8 | `goodDense_openSub_of_mid` — Reynolds' `M|(c,d) ≡ₖ X + 𝓡 + Y` |
| `6f4e467c1` | 9 | `goodDense_openSub_of_mid_le`, `exists_right_endpoint_class`, `exists_left_endpoint_class`, `endpoint_lt_endpoint` |
| `325525a9f` | 10 | `mem_openSub_endpoints_iff`, `classStrictlyBetween_epsDense_iff`, and the assembled `reynolds_theorem6_contradiction` |

`reynolds_theorem6_contradiction` is now Reynolds' printed argument end to end, with **no `sorry`
in its own body**: the minimal choice (Layer 5), very-goodness of `M|(a,b)` read as `SimDense` and
so contradicting `a ≁ b` outright, `veryGoodDense_openSubinterval_iff` reducing to goodness of each
`M|(c,d)`, the `c ∼ d` branch by Lemma 11, and the `c ≁ d` branch through Layers 8-10.

## The prior cycle's sizing was wrong, in the useful direction

The previous handoff named the three-summand decomposition
`M|(c,d) = M|(c,c'] + M|⋃I + M|[d',d)` as *"the one genuinely missing ingredient in the tree"*.
It is not: it is **two nested applications of assets already landed** — `kEquiv_openSub_split`
(`EpsilonDense.lean:858`) followed by `goodDense_binSum_pointSum` (`EpsilonDense.lean:832`), which
is the same `R₁ + R₂ + R₃` step §8 already used to prove transitivity of `∼`. It cost roughly 40
lines. `goodDense_openSub_of_mid_le` additionally discharges all four combinations of `c' = c` and
`d' = d`; those are not corner cases, because D2 supplies a *dense* set of singleton classes.

The real gap sits one step earlier, in the shuffle: **the choice of `N_γ`**.

## The residual, and why it is where it is

`goodDense_unionClasses` (`DoetsTheorem.lean:1318`) carries the single tracked strategic sorry, with
`hmin`, `D1`, `D2` and `hI : ⋃I = (c',d')` all in scope. Two sub-items, order forced:

1. **`N_γ`.** `goodDense_shuffle` asks for six properties of the family (`hne`, `hdense`, `hsum`,
   `hbot`, `hone`, `hsep`). These are printed p.188's *"because the `γᵢ`'s say so the summands
   themselves are closed intervals of the reals"*. Getting them needs the **two-sided closed** case
   of a normalization the tree has only end-point-free (`exists_ioo_witness`) and one-sided
   (`icoBlock` / `kEquiv_pointSum_icoBlock`). Concrete route: `M|E` is good, countable, densely
   ordered, and by Lemma 13 has an attained least and greatest point; transport *has-a-min*,
   *has-a-max* and `DenselyOrdered` across `≡ₖ` at `k ≥ 2` (pattern: `noMaxOrder_of_kEquiv`), and
   then the witness's `carrierSet`, being `OrdConnected` with an attained min and max, **is**
   `Set.Icc x y` — Dedekind complete, least element, dense, separable. The set identity is free; the
   three transfer lemmas are the work.
2. **`σ`.** Forced to `colour ∘ e.symm` for the landed `e : I ≃o ℚ`; then `hmatch` of
   `kEquiv_blocks_shuffle` holds by construction and `IsShuffleMap S σ` is
   `gammaBetween_dense_of_minimal` transported along `e`. Bookkeeping — but it cannot be written
   until (1) fixes `ι` and `N`.

## Verification

| Check | Result |
|---|---|
| Scoped build (`RealModel.DoetsTheorem` + `DenseModelSurgery.ChronicleInstance`) | green, 2234 jobs, 0 errors |
| Full `lake build` | green, 1983 jobs (default target does not reach `RealModel/**`; scoped build is load-bearing) |
| Non-Boneyard sorries | 2 — `Transfer.lean:1242` (pre-existing, unrelated) and `DoetsTheorem.lean:1318` (tracked). **No new sorry.** |
| `#print axioms`, seven new declarations | `[propext, Classical.choice, Quot.sound]` each |
| `#print axioms reynolds_theorem6_contradiction` / `doets_theorem_dense` | still include `sorryAx`, via the residual — reported, not hidden |
| Vacuous definitions in territory | 0 (one repo-wide hit, `Examples/TemporalStructures.lean:279`, pre-existing and out of territory) |
| New axioms | 0 |
| Territory | one Lean file modified; no §6 file, no `Decidability/`, no `Automation/` |

## Deviations

- **Phase not closed.** Done-when unmet on both counts. `[PARTIAL]` retained.
- **Anti-vacuity checkbox unchanged and still not met.** Nothing in this dispatch bears on it; its
  gating is unchanged from sub-phase 29.1 (D1/D2 must be *discharged* at the chronicle structure,
  which needs §6 to run on the countable-dense bundle, measured to fail at `surgeredStructure`).
- **The residual moved out of `reynolds_theorem6_contradiction` into a new named lemma.** This makes
  the theorem literally sorry-free in its body while still transitively depending on a sorry. Called
  out explicitly in the theorem's own docstring and in the plan record so it cannot be misread as
  closure.
