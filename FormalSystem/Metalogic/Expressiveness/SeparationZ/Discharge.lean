/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Expressiveness.SeparationZ.Packaging
import FormalSystem.Metalogic.Expressiveness.OpenFutureElimination

/-!
# The discharge of `SeparationOver TaskFrame.IsZTime`

`OpenFutureElimination.lean` states Gabbay's Separation Theorem over the integer flow as the
explicit hypothesis `SeparationOver TaskFrame.IsZTime` and proves the open-future eliminations
conditionally on it. This module discharges that hypothesis from the `SeparationZ/` development:
`separationOver_ztime : SeparationOver TaskFrame.IsZTime`, with the separated form computed by
the plain `def` `sepZ`.

## The route

`sepZ φ` is the composite of the four landed pieces: leaf-abstract `φ` to a `USForm` against its
own leaf table (`abstr`, `LeafAbstraction.lean`); separate by Theorem 10.2.9 (`sep`,
`JunctionDepth.lean`); package the separated form into (past, future) clause pairs (`package`,
`Packaging.lean`); and resubstitute each component (`toPlus (leafVal φ)`). The two conclusions
`SeparationOver` asks for are then:

- `sepZ_sepClauses`: every clause is a (past-determined, future-determined) pair. The past
  components are `untl`-free and the future components `snce`-free at the `USForm` level
  (`isSOnly_fst_of_mem_package`, `isUOnly_snd_of_mem_package`), purity transfers across the seam
  (`isPurePast_toPlus`, `isPureFuture_toPlus`, with the leaf table pure on both sides), and purity
  gives determinacy frame-independently (`pastDet_of_isPurePast`, `futDet_of_isPureFuture`). The
  regularity and ℤ-time hypotheses are consumed only to match `SeparationOver`'s shape.
- `plusTruthAt_sepZ_iff`: the equivalence, on every regular ℤ-time frame. It is proved over the
  single carrier `ℤ` — the roundtrip `toPlus_abstr`, the truth transfer `usTruth_toPlus_iff`,
  Theorem 10.2.9's `usTruth_sep_iff`, the packaging lemma `usTruth_sepFormUS_package`, and
  `toPlus_sepFormUS` carrying `sepFormUS` to `sepForm` — and then lifted to every regular ℤ-time
  task frame by the carrier bridge `pointwise_ztime_of_pointwise_int`.

`separationOver_ztime` is the pairing, with the `∃ L` before `∀ F` binder order `SeparationOver`
fixes: one separated form serves every frame in the class, which is what the syntactic route
delivers. `sepZ` is a plain `def` with no `noncomputable` keyword.

## What this does and does not change

Nothing in `OpenFutureElimination.lean` is touched: `tr` keeps its name, its `noncomputable`
keyword and its explicit `hsep` argument, and every conditional result there keeps its
hypothesis. This module supplies that hypothesis at `TaskFrame.IsZTime`, so each of those results
may now be instantiated at `separationOver_ztime`; the `TaskFrame.IsRTime` instance (GHR
Theorem 10.3.20) remains open.

## Main Definitions

- `sepZ`: the computable separated conjunctive normal form of an L⁺ formula over ℤ-time

## Main Results

- `sepZ_sepClauses`, `plusTruthAt_sepZ_iff`: the two conclusions of `SeparationOver` at `sepZ`
- `separationOver_ztime`: Gabbay's Separation Theorem over the integer flow, as the discharge of
  `SeparationOver TaskFrame.IsZTime`

## References

* [D. M. Gabbay, I. Hodkinson and M. Reynolds, *Temporal Logic: Mathematical Foundations and
  Computational Aspects*][gabbay1994], vol. 1, Theorem 10.2.9
-/

namespace FormalSystem.Metalogic.Expressiveness

open FormalSystem.Syntax
open FormalSystem.Semantics
open FormalSystem.PlusLanguage
open FormalSystem.OpenLanguage
open SeparationZ

/-- Resubstitution carries `sepFormUS` to `sepForm`, clause by clause: `top`, `and` and `or` have
the same right-hand sides on both syntaxes, so each step is definitional. -/
theorem SeparationZ.toPlus_sepFormUS (g : ℕ → PlusFormula) :
    ∀ L : List (USForm × USForm),
      toPlus g (sepFormUS L) = sepForm (L.map fun c => (toPlus g c.1, toPlus g c.2))
  | [] => rfl
  | c :: L =>
      congrArg (PlusFormula.and (PlusFormula.or (toPlus g c.1) (toPlus g c.2)))
        (toPlus_sepFormUS g L)

/--
**The computable separated conjunctive normal form over ℤ-time.** Leaf-abstract, separate by
Theorem 10.2.9, package into (past, future) clause pairs, resubstitute. A plain `def`, deliberately
not `noncomputable`: this is what makes the ZTime translation executable.

Paper: — (a result of GHR vol. 1, Theorem 10.2.9 (the separated form it asserts to exist, computed);
the manuscript states no separation theorem)
-/
def sepZ (φ : PlusFormula) : List (PlusFormula × PlusFormula) :=
  (package (sep (abstr φ))).map fun c => (toPlus (leafVal φ) c.1, toPlus (leafVal φ) c.2)

-- `hreg` and `hz` are unused by design: the contract signature carries them so that this result
-- slots into `SeparationOver`'s shape, while purity-derived determinacy is frame-independent and
-- needs neither. `linter.unusedVariables` (core) is scoped off for this one declaration, and the
-- Mathlib `unusedArguments` environment linter is answered by the `nolint` attribute below.
set_option linter.unusedVariables false in
/--
**Every clause of `sepZ φ` is a (past-determined, future-determined) pair**, on every frame. Purity
is frame-independent, so `hreg` and `hz` are consumed only to match `SeparationOver`'s shape.

Paper: — (a result of GHR vol. 1, Theorem 10.2.9 (the separatedness of the form); the manuscript
states no separation theorem)
-/
@[nolint unusedArguments]
theorem sepZ_sepClauses (φ : PlusFormula) (F : TaskFrame) (hreg : F.IsRegular)
    (hz : F.IsZTime) : SepClauses F (sepZ φ) := by
  intro c hc
  obtain ⟨d, hd, rfl⟩ := List.mem_map.mp hc
  exact ⟨pastDet_of_isPurePast
      (isPurePast_toPlus (leafVal_isPurePast φ) (isSOnly_fst_of_mem_package d hd)),
    futDet_of_isPureFuture
      (isPureFuture_toPlus (leafVal_isPureFuture φ)
        (isUOnly_snd_of_mem_package (isSeparated_sep _) d hd))⟩

/--
**`sepZ φ` is equivalent to `φ` on every regular ℤ-time frame.** Proved over the carrier `ℤ` and
lifted by the carrier bridge.

Paper: — (a result of GHR vol. 1, Theorem 10.2.9 (the equivalence); the manuscript states no
separation theorem)
-/
theorem plusTruthAt_sepZ_iff (φ : PlusFormula) {F : TaskFrame} (hreg : F.IsRegular)
    (hz : F.IsZTime) (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration) :
    PlusTruthAt M τ t φ ↔ PlusTruthAt M τ t (sepForm (sepZ φ)) := by
  refine pointwise_ztime_of_pointwise_int (fun G _ M' τ' t' => ?_) F hreg hz M τ t
  calc PlusTruthAt M' τ' t' φ
      ↔ PlusTruthAt M' τ' t' (toPlus (leafVal φ) (abstr φ)) := by rw [toPlus_abstr]
    _ ↔ usTruth (fun i s => PlusTruthAt M' τ' s (leafVal φ i)) t' (abstr φ) :=
        (usTruth_toPlus_iff M' τ' (leafVal φ) (abstr φ) t').symm
    _ ↔ usTruth (fun i s => PlusTruthAt M' τ' s (leafVal φ i)) t' (sep (abstr φ)) :=
        (usTruth_sep_iff (abstr φ) _ t').symm
    _ ↔ usTruth (fun i s => PlusTruthAt M' τ' s (leafVal φ i)) t'
          (sepFormUS (package (sep (abstr φ)))) :=
        (usTruth_sepFormUS_package _ t' _).symm
    _ ↔ PlusTruthAt M' τ' t' (toPlus (leafVal φ) (sepFormUS (package (sep (abstr φ))))) :=
        usTruth_toPlus_iff M' τ' (leafVal φ) _ t'
    _ ↔ PlusTruthAt M' τ' t' (sepForm (sepZ φ)) := by rw [toPlus_sepFormUS, sepZ]

/--
**Gabbay's Separation Theorem over the integer flow**, as the discharge of the hypothesis
`OpenFutureElimination.lean` states: every L⁺ formula has a separated conjunctive normal form
equivalent to it on every regular ℤ-time task frame, and `sepZ` computes it.

Paper: — (a result of GHR vol. 1, Theorem 10.2.9; the manuscript states no separation theorem)
-/
theorem separationOver_ztime : SeparationOver TaskFrame.IsZTime :=
  fun φ => ⟨sepZ φ, fun F hreg hz =>
    ⟨sepZ_sepClauses φ F hreg hz, fun M τ t => plusTruthAt_sepZ_iff φ hreg hz M τ t⟩⟩

end FormalSystem.Metalogic.Expressiveness
