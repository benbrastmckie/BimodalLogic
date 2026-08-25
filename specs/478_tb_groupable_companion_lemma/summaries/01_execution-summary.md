# Execution Summary: T-B — The Groupable Companion Lemma

- **Task**: 478 - T-B: The Groupable Companion Lemma
- **Status**: COMPLETED (all 4 phases; no [PARTIAL] split needed; escape hatch NOT taken)
- **Session**: sess_1787636012_6457eb
- **Plan**: plans/01_groupable-companion-lemma.md
- **Research Input**: reports/01_groupable-companion-feasibility.md

## Result

The general groupable companion lemma is **proved, sorry-free, with clean axioms**:

- `companionGeneral` (`GroupModel/GroupableCompanion.lean`): every countable discrete
  (Succ/Pred) unbounded-both-ways `OrderedMonadicStructure sig M` satisfies
  `goodGroupable sig k M` for every depth `k` — there is a structure on the **full carrier**
  `ℚ ×ₗ ℤ` that is `≡ₖ` to `M`. No counterexample emerged; the sufficient lemma holds in
  full generality (arbitrary countable index order `I`, carried verbatim by ℚ-condensation).
- `companionChronicle`: the instantiation at `limitdomMonadicStructure A h_mcs φ` for a Base
  MCS `A` with `□(nextTop) ∈ A` — the Base analogue of `limitdom_is_good`, and the
  deliverable the successor task (the `countermodel_discrete` replacement) consumes. No
  `Discrete ≤ fc` hypothesis; discreteness comes from `□(nextTop)` alone.

`#print axioms` on both (checked from a scratch file outside `FormalSystem/`):
exactly `[propext, Classical.choice, Quot.sound]`. The escape hatch (chronicle-specific
weakening) was **not** needed: `companionGeneral` is the unweakened general statement.

## Artifacts (2,685 new lines across 4 modules)

| Module | Lines | Content |
|---|---|---|
| `GroupModel/BlockDecomposition.lean` | 444 | Discrete-order succ/pred-iterate toolkit; `SuccReach` block equivalence (convex classes); `BlockQuot` linear quotient; `zPoint` ℤ-action; `zFiber`; **`blockDecomposition`**: `M ≃o Σ_{i∈I} (ℤ, cᵢ)` |
| `GroupModel/MonoDiscrete.lean` | 892 | `MonoInv` threshold invariant (pair-list form, pinned anchors); the Duplicator answering step `monoInv_step` (5-way case tree, exact/threshold placement); master `backForth_of_monoInv`; **`kEquiv_monoDiscrete_noEnds` / `_minNoMax` / `_maxNoMin`** (the last via `dualStructure` + mirror-atom `BackForth` transfer); constant-colouring corollaries at `colourSig` |
| `GroupModel/RamseyFactorization.lean` | 923 | **`infinite_ramsey_pairs`** (transcribed from the compiled probe; absent from Mathlib at this pin); `SuccOrder`/`PredOrder` instances on `ℚ ×ₗ ℤ` and on lex sums; predicate-generalized master `backForth_of_monoInv_pred`; **`kEquiv_colourStructure_anchored`** (3-region anchored coloured-order completeness); `segZ`/`qzFiber`; bi-infinite Ramsey factorization `exists_zFactorization`; **`inflate_right` / `inflate_left`** (tail absorption above/below, same depth `k`) |
| `GroupModel/GroupableCompanion.lean` | 426 | `pairSum`; **`inflate_both`**; `CondFiber := ℚ ⊕ₗ (Unit ⊕ₗ ℚ)` with density/unboundedness instances; **`condensationOfQ`**: `I ×ₗ CondFiber ≃o ℚ` (Cantor, `Order.iso_of_countable_dense`); `goodGroupable_of_carrier_iso` (predicate transport); the glue `glueMap` (strictMono + surjective onto `ℚ ×ₗ ℤ`); **`companionGeneral`**, **`companionChronicle`** |

Plus: one CI-edge import per module in `WeakCanonical.lean`, and the stale
`doets_lemma_1_5` "strategic sorry" header note in `OrderedSum.lean` corrected (it is proved
via `kEquiv_orderedSum_of_kEquiv_colour`; no sorry involved).

## Verification (final gate)

- `lake build`: green, 2,492 jobs, zero warnings in the new modules.
- Sorry census: sole non-Boneyard `sorry` remains `countermodel_discrete`
  (`Transfer.lean:1102`); count unchanged.
- No new axioms; no vacuous definitions (grep clean).
- `scripts/check-module-invariants.sh`: **ALL CHECKS PASSED** (C1-C11, incl. C2 flagship
  axiom baselines, C3 sole-sorry pin, C9 no task-number citations).
- T-A rulings honoured: full carrier only (no interval type), no `veryGoodGroupable`.

## Plan Deviations

All deviations are annotated inline on the plan checklist items; summary:

- **Phase 3 (altered)**: the plan's split-at-0 + separate ω/ω* tail absorptions were
  replaced by ONE bi-infinite Ramsey factorization of the whole block (ω*-many τ⁻-segments,
  pinned middle segment, ω-many τ⁺-segments), reduced by the mixing lemma to the coloured
  index orders `ζ` vs `ζ ⊕ₗ (ℚ ×ₗ ζ)` (and mirror), closed by the new 3-region
  `kEquiv_colourStructure_anchored` over the predicate-generalized master. Reason: the
  plan's "both monochromatic" index orders are only monochromatic after peeling the prefix,
  which costs nested-sum re-association isos; pinned anchors absorb the prefix and the seam
  at zero cost, eliminating the split, the re-associations, and the dual-transfer.
  Deliverables landed as `inflate_right`/`inflate_left` (in place of a single `Inflate`).
- **Phase 4 (altered)**: condensation uses the uniform fiber `ℚ+1+ℚ` for **every** index
  (`CondFiber`), not `1+ℚ` with a ℚ prepended only into a minimum fiber — density and
  unboundedness then hold regardless of whether `I` has a minimum, removing any case split;
  every block gets both-sided inflation (`inflate_both`). The glue needs **no** interp
  condition: the target `QZStructure` is defined by transporting predicates along the glue
  iso (`goodGroupable_of_carrier_iso`), so the glue is pure order theory.
- **Statement names**: `companionGeneral`/`companionChronicle` (lowerCamel per repo
  convention) prove exactly the probe's `CompanionGeneral`/`CompanionChronicle` statement
  shapes; the probe's abstract-`B` `TailAbsorption` shape was narrowed to the coloured-ℤ
  block shape actually consumed (the abstract non-Archimedean form is not needed and its
  finite-word tiling argument requires the Archimedean block shape).
- Minor: `Nat.Subtype.ofNat`/`Set.finite_le_nat`/`Set.finite_iUnion` probe guidance followed
  verbatim in the Ramsey transcription; the `Prod.Lex.right _ (by simp)` unboundedness
  tactic was not needed (T-A's `NoMaxOrder`/`NoMinOrder` instances were reused directly).

## What Worked / Notes for Successors

- The pair-list (`List (M.carrier × N.carrier)`) formulation of the EF threshold invariant
  let endpoint anchors ride outside the `BackForth` environments; the predicate-generalized
  master (`backForth_of_monoInv_pred`) then closes ANY colouring constant on anchor-defined
  regions — reusable for further coloured-order obligations.
- `dualStructure` transfer is pure `exact`-level defeq (`OrderDual` is a definitional
  synonym); order atoms transfer by playing `.order j i h.symm`. No environment rewriting.
- The successor task consumes `companionChronicle` plus the landed `truth_transfer`
  machinery to replace the `countermodel_discrete` sorry.
