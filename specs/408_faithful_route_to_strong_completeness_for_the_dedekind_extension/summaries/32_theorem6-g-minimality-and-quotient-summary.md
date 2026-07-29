# Phase 29 (sub-phases 29.2-29.4): Reynolds' `G`, `M/∼`, and Reynolds' `I`

**Dispatch target**: Phase 29 only — *Doets' Theorem, Reynolds §8 Theorem 6*, previously
`[PARTIAL]` with a tracked strategic sorry carrying two named sub-gaps.

**Outcome**: both remaining sub-gaps discharged, sorry-free and axiom-clean. The phase heading
stays `[PARTIAL]`: its Done-when is *"`doets_theorem_dense` and the chronicle instantiation are
sorry-free and axiom-clean"*, and neither holds — the residual `sorry` survives on the assembly.
Progress is real but it is not phase closure and is not presented as such.

## What was landed

All in `FormalSystem/Metalogic/WeakCanonical/RealModel/DoetsTheorem.lean`, the phase's owned file.
No new module was created (the plan's `Owns` list names this file alone) and no §6 file was
touched.

### Layer 5 — Reynolds' `G` and its minimization (sub-gap 2)

Printed p.187: *"Choose `a < b` from `M` such that `a ≁ b` and `G = {γᵢ | … ∃ ∼-class E strictly
between a and b such that M | E ⊨ γᵢ}` has minimal size."*

| Declaration | Source sentence |
|---|---|
| `ClassStrictlyBetween` | *"`∼`-class `E` strictly between `a` and `b`"*, named by a representative |
| `contempClassStructure` | `M | E`, via `restrictSet` (`Shuffle.lean:409`) |
| `gammaBetween` | Reynolds' `G` at a pair |
| `mem_gammaBetween`, `gammaBetween_subset` | monotonicity in the interval |
| `exists_minimal_gammaBetween` | *"The following choice makes sense."* |
| `gammaBetween_eq_of_minimal` | *"by minimality of `G`"* |
| `gammaBetween_dense_of_minimal` | *"all the `γᵢ`'s in `G` are satisfied densely in `I`"* |

**Rendering decision, recorded in the file**: `G` is a `Finset (NormalForm sig k 0)` rather than a
set of sentences. `gammaSentences` is literally `(goodNFs sig k).toList.map nfToSentence`, so the
two presentations carry the same data; the normal-form level is where `Finset.card` is available
without needing `nfToSentence` to be injective, and injectivity is not part of what the argument
uses. The only property of the size measure consumed is monotonicity under inclusion.

### Layers 6-7 — `M/∼` as a linear order, and Reynolds' `I` (sub-gap 3)

Printed p.187: *"Since we have density of `M/∼`, the classes in `I` … have order type `ℚ`."*

| Declaration | Content |
|---|---|
| `IsConvexEquiv` | clauses (i)+(ii) at **one** structure, so the quotient depends on one proof term |
| `isConvexEquiv_of_contempEquivDenseCD` | bridge from `IsContempEquivDenseCD` |
| `ContempLtPt`, `IsConvexEquiv.ltPt_congr` | well-definedness: two distinct classes are *totally* separated, not merely separated at the chosen representatives. **The one essential use of convexity.** |
| `setoid`, `ClassQuot`, `cls`, `classLt` | `M/∼` |
| `classLt_irrefl` / `_trans` / `_trichotomous`, `instLinearOrderClassQuot` | the order, via `linearOrderOfSTO` |
| `classStrictlyBetween_of_between`, `ClassStrictlyBetweenQ`, `ClassBetween` | Reynolds' `I` as an ordered type |
| `nonempty_classBetween`, `denselyOrdered_classBetween`, `noMinOrder_classBetween`, `noMaxOrder_classBetween` | the four Cantor hypotheses, all from `QuotientDenselyOrdered` |
| `nonempty_orderIso_rat_classBetween` | *"order type `ℚ`"*, by `Order.iso_of_countable_dense` |
| `quotientDenselyOrdered_epsDense` | *"By lemma 13 and D1 … thus we have density of `M/∼`"* |
| `isConvexEquiv_epsDense`, `nonempty_orderIso_rat_classBetween_epsDense` | the order-type-`ℚ` result at Reynolds' own `∼_M`, no abstract hypothesis left |

**Why a quotient type is built here when §6/§7 deliberately avoid one** (recorded in the module):
`Singletons.lean`'s convention — *"stated directly in terms of `∼` itself, with no quotient type
constructed"* — is right for `QuotientDenselyOrdered` and `HasDenseSingletons`, each a pointwise
property. *"Order type `ℚ`"* is not of that kind: it asserts an order isomorphism, so a type must
carry the order. `Order.iso_of_countable_dense` cannot be applied to a pointwise predicate.
Nothing above this layer needs the quotient, which is why it lives in `DoetsTheorem.lean` and not
in `Singletons.lean`; the two §6/§7 predicates are used **unchanged** as hypotheses.

D1 is not used inside Layer 6 and clause (iii) is not used at all — D1's role is Layer 7's, in
establishing `QuotientDenselyOrdered` through Lemma 13.

### One naming correction

`IsContempEquivDenseCD.atStructure`, landed under that name mid-dispatch, was renamed to
`isConvexEquiv_of_contempEquivDenseCD`: `IsContempEquivDenseCD` is declared in the
`DenseModelSurgery` namespace, so a declaration of the dotted name inside
`FormalSystem.Metalogic.WeakCanonical` sits in a different namespace and can never be reached by
dot notation. The reason is recorded on the declaration.

## Verification

| Gate | Result |
|---|---|
| Scoped build | Green. `RealModel.DoetsTheorem` + `DenseModelSurgery.ChronicleInstance`, 2234 jobs, 0 errors. `ChronicleInstance` is the canary that the additive changes did not disturb §6. |
| Full `lake build` | Green, 1983 jobs. As recorded by the Phase 28 reachability finding, the default target does **not** reach `RealModel/**`, so the scoped build is the load-bearing channel. Stated here rather than reported as coverage it does not have. |
| Territory sorry census | Two, unchanged in count: `Transfer.lean:1242` (pre-existing, unrelated) and `DoetsTheorem.lean:1000` (the tracked strategic sorry, moved from 458 by the added layers). **No new sorry.** |
| `#print axioms` | Every one of the 19 new load-bearing declarations reports exactly `[propext, Classical.choice, Quot.sound]`. No `sorryAx` in any of them. |
| Vacuous definitions | 0 in this task's territory. One repo-wide hit, `Examples/TemporalStructures.lean:279`, is pre-existing and out of territory. |
| New axioms | 0. |
| Frozen files | Untouched — the only Lean file modified this dispatch is `DoetsTheorem.lean`. |

## What remains, and it is now one item rather than three

The residual `sorry` at `DoetsTheorem.lean:1000` is the **assembly**, printed p.187 line 141
through p.188. Its docstring now says so precisely:

1. **The shuffle map.** Transport `Σ_{E∈I} M|E` to `Σ_{q∈ℚ} σ(q)` along the landed `I ≃o ℚ`.
   Transport layer (`kEquiv_orderedSum_blocks`, `Shuffle.lean:424`) and density input
   (`gammaBetween_dense_of_minimal`) are both landed; what must be written is the choice of `σ`
   and the discharge of `IsShuffleMap`.
2. **The `ℝ`-extension and the flow.** `doets_lemma_1_5` plus Phase 28's `≅o ℝ` characterization
   — application of landed, sorry-free assets, not new mathematics.
3. **The three-summand decomposition** `M|(c,d) = M|(c,c'] + M|⋃I + M|[d',d)`, then
   `M|(c,d) ≡ₖ X + 𝓡 + Y` via `doets_lemma_1_4`. `c'` and `d'` exist by Lemma 13, but the
   decomposition itself has no counterpart in the tree. **This is the one genuinely missing
   ingredient.**

## Deviations

- **PHASE NOT CLOSED.** Done-when is `doets_theorem_dense` sorry-free plus the chronicle
  instantiation; neither holds. Heading stays `[PARTIAL]`.
- **Anti-vacuity checkbox still not met**, and unchanged in its gating: it needs D1/D2
  *discharged* at the chronicle structure, which needs §6 to run on the countable-dense bundle —
  the obstruction measured at `surgeredStructure` in sub-phase 29.1 and recorded in the D1/D2
  section header. Nothing in this dispatch bears on it. `exists_realFlow_shuffleReal_point`
  remains the weaker honest substitute and is still not claimed to discharge the checkbox.
- **No rollback, no revert, no reset.** Every edit was additive to one file; four commits, each at
  a green build.
