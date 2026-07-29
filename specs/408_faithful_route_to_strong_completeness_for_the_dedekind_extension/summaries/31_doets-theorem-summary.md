# Phase 29 — Doets' Theorem (Reynolds §8 Theorem 6): implementation summary

**Status**: `[PARTIAL]`. One tracked strategic sorry.
**Module**: `FormalSystem/Metalogic/WeakCanonical/RealModel/DoetsTheorem.lean` (new, 443 lines).
**Plan**: `plans/10_strong-completeness-dedekind-v10.md`, Phase 29.

## What landed

`DoetsTheorem.lean` is the Block H assembly point. Four layers, bottom-up.

### Layer 1 — `ℝ`-flow normalization (sorry-free)

`goodDense` hands back *some* interval of `ℝ`; Reynolds' conclusion asks for *the* real line.

- `RIntervalStructure.IsRealFlow R := R.carrierSet = Set.univ`
- `exists_realFlow_witness` — good + nonempty + no end points ⇒ an `ℝ`-flowed `k`-equivalent.
  Modelled on the landed `exists_ioo_witness` (`GoodDense.lean:713`), substituting
  `univIsoReal.symm ∘ realIsoIoo01.symm` for `iooIsoIoo`.

### Layer 2 — a flow `≅o ℝ` is good (sorry-free)

- `goodDense_of_orderIso_real`, `exists_realFlow_of_orderIso_real`.

This is what makes Phase 28's `orderIsoRealOfDedekindDenseSeparable` usable as an *input* to
goodness rather than only as an output — the direction printed p.188 actually uses.

### Layer 3 — the `ℝ`-model transfer (sorry-free) — **the phase's real deliverable**

Printed p.188, composed:

- `goodDense_shuffleReal` / `exists_realFlow_shuffleReal` — `Σ_{r∈ℝ} σ*(r)` is good, with flow
  the real line. Via `nonempty_orderIso_real_shuffleReal` (Phase 27's five order facts fed to
  Phase 28's characterization) then Layer 2.
- `goodDense_shuffle` — the `ℚ`-shuffle is good, transported back along
  `kEquiv_shuffle_shuffleReal` (Phase 27 + `doets_lemma_1_5`).
- `exists_realFlow_of_kEquiv_shuffle` — the consumption shape for printed p.187's
  `M | (⋃ I) ≡ₖ Σ_{q∈ℚ} σ(q)`: `kEquiv_blocks_shuffle` supplies the left-hand `≡ₖ` and this
  converts it into an `ℝ`-flowed witness in one step.
- `exists_realFlow_shuffleReal_point` — anti-vacuity at the constant one-point palette.

The six hypotheses are `isRealLike_shuffleReal`'s, in the same spelling — no adapter needed.

### Layer 4 — the theorem (one tracked sorry)

- `DoetsD1` / `DoetsD2` — D1 and D2 quantified over *"any contemporaneous equivalence relation
  `∼` on `M`"*, in the spelling Phase 30's suppliers already produce (`IsContempEquivDense ε`,
  `EndsInGapOnRight`/`EndsInGapOnLeft`, `QuotientDenselyOrdered → HasDenseSingletons`).
- `exists_not_simDense_of_not_goodDense` — **proved**. Printed p.187's *"`M` is not very good and
  so there are `a < b` with `a ≁ b`"*. Both implications are Lemma 11 in contrapositive form:
  applied at `M` itself, and at `M | (t,u)` for the `SimDense` middle clause.
- `reynolds_theorem6_contradiction` — **the one sorry** (`DoetsTheorem.lean:415`).
- `doets_goodDense`, `doets_theorem_dense` — pure compositions of the above.

`doets_theorem_dense` is landed **with its final signature** (`DoetsD1`/`DoetsD2` only, no extra
hypothesis), so Phase 30 consumes it exactly as chartered.

## The single strategic sorry, and why it is a division boundary

`reynolds_theorem6_contradiction` is printed pp.187-188's `G`-minimality contradiction. Three
named sub-gaps, all recorded in its docstring:

1. **The `ε`-adapter.** The argument runs at `ε := epsDense sig k`, but `epsDense_isContempEquiv`
   (`EpsilonDense.lean:1033`) supplies the three clauses only **at a fixed `Countable`,
   `DenselyOrdered` `M`** — not the `∀ M`-quantified `IsContempEquivDense` that `DoetsD1` and
   `DoetsD2` take. This is verbatim *"the one adapter Phase 29 must supply"* that Phase 25's own
   deviation record flagged, and it is not supplied. Closing it means either weakening
   `IsContempEquivDense` to an at-`M` bundle throughout `DenseModelSurgery/`, or proving the
   `∀ M` form — which the Phase 25 module header records as **false** without density.
2. **The `G`-minimality argument.** Minimization over the finite `γ`-palette (`gammaSentences`,
   `EpsilonDense.lean:239`). No counterpart in the tree.
3. **The order-type-`ℚ` step.** Cantor at the `∼`-quotient. `Order.iso_of_countable_dense`
   supplies the isomorphism once the quotient is built; the quotient is not built.

It is a genuine division boundary rather than avoidance: everything the residual routes
*through* — `kEquiv_blocks_shuffle`, `kEquiv_shuffle_shuffleReal`,
`nonempty_orderIso_real_shuffleReal`, `goodDense_shuffle`, `doets_lemma_1_4` — is landed and
sorry-free, and the residual is a single named lemma with a stable signature, not a scattering.

## Anti-vacuity: not met, and not faked

The plan's anti-vacuity checkbox asks for the chronicle instantiation. It is **not** landed. It
is gated on sub-gap (1) above, and closing it at `epsTop` would be vacuous by the plan's own
v10 caveat. `exists_realFlow_shuffleReal_point` is landed instead as an honest but *weaker*
witness — it shows the `ℝ`-flow conclusion shape is inhabited at a non-degenerate carrier (a
lexicographic `Sigma` over `ℝ`, not `ℝ` in disguise). It does not discharge the checkbox and is
not presented as doing so.

## Verification

| Check | Result |
|---|---|
| Scoped build `…RealModel.DoetsTheorem` | green, 2215 jobs, no warnings from this module beyond the `sorry` notice |
| Full `lake build` | green, 1983 jobs — **does not reach `RealModel/**`** (Phase 28 reachability finding, unchanged; Phase 30 owns the repair) |
| Sorry census outside `Boneyard/` | 2: `Transfer.lean:1242` (pre-existing) + `DoetsTheorem.lean:415` (this dispatch, tracked strategic) |
| Vacuous definitions | 1, pre-existing and unrelated (`Examples/TemporalStructures.lean:279`) |
| `axiom` declarations | 2, unchanged from baseline |
| `#print axioms` | `exists_realFlow_witness`, `exists_not_simDense_of_not_goodDense`, `goodDense_shuffle`, `exists_realFlow_of_kEquiv_shuffle`, `exists_realFlow_shuffleReal_point` — all exactly `[propext, Classical.choice, Quot.sound]`. `doets_theorem_dense` additionally reports `sorryAx`, as expected. |

## Formalization notes

- `rw [ψ.symm_apply_apply]` fails where the goal carries a `Subtype.val` coercion through an
  anonymous-constructor membership proof: the pattern `ψ.symm (ψ ?x)` is not found even though
  the term is definitionally present. The fix that works is the shape `exists_ioo_witness`
  already uses — `(iff_of_eq (congrArg (R₀.interp p) (congrArg Subtype.val
  (ψ.symm_apply_apply x)))).symm`. Worth reaching for first in this file's idiom.
- `exists_not_simDense_of_not_goodDense` is much shorter proved by `by_contra` + `push Not` than
  by unfolding `¬ veryGoodDense`: the contrapositive form hands back
  `∀ a b, a < b → SimDense …` directly, and `veryGoodDense`'s non-emptiness clause then falls out
  of `exists_between`.
- `Countable (M.openSubinterval sig t u).carrier` does not fire from `inferInstance` at the
  `openSubinterval` spelling; it needs the explicit
  `(inferInstance : Countable {x : M.carrier // t < x ∧ x < u})` ascription.
