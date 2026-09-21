/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Semantics.ConvexTruth
import Mathlib.Algebra.Order.Group.Int
import Mathlib.Data.Int.SuccPred

/-!
# Separations - C1, C3 and C4 Are Three Different Logics

The convex-index consequence relations of `Semantics/ConvexTruth.lean` are separated from the
library's own relation, and from each other, on the permissive integer-time frame.

- **C1 versus C3.** `F⊤` — the semantic content of TM's seriality axiom — is C1-valid
  (`valid_C1_someFuture_top`) and C3-invalid (`refute_C3_someFuture_top`), refuted at the right
  endpoint of a bounded index, where no later time lies in the index's domain. Its past dual
  `P⊤` fails at the left endpoint (`refute_C3_somePast_top`). The refuting index is an interval
  history, so the refutation lands for C4 as well (`refute_C4_someFuture_top`).
- **C3 versus C4.** `validC3_imp_validC4` is a strict containment. The formula `lastPoint`,
  `F⊤ → F G⊥`, says that a last point exists whenever a later point does. It is C4-valid on
  every frame (`validC4_lastPoint`): a closed bounded interval has a right endpoint in its own
  domain. It is not C3-valid (`refute_C3_lastPoint`): a total history is convex, and over the
  integers it has no last point.

Every refutation here is an instance of one phenomenon: the refuted formula asserts that some
time *exists* in the temporal order, and a bounded domain is exactly what falsifies an existence
assertion.

## Fixtures

The integer-time frame `NF` is `FrameOver.natFrame` at `D = ℤ`. It is a local reducible
abbreviation: the `PlusLanguage` namespace declares a frame of the same name, and a
base-language module does not import that language to reuse it. The three indices are `bdd`
(the one-point domain `[0, 0]`), `bdd01` (the two-point domain `[0, 1]`, with an
immediate-successor pair and two endpoints) and `totalNF` (a total history). Each carries its
membership, interval and convexity lemmas; `bdd01` and its lemmas are consumed by the
refutations in `AxiomSurvival.lean`.

## Main Results

- `valid_C1_someFuture_top`, `refute_C3_someFuture_top`, `refute_C3_somePast_top`,
  `refute_C4_someFuture_top`
- `validC4_lastPoint`, `refute_C3_lastPoint`

## References

* `FormalSystem/Semantics/ConvexTruth.lean` — `TruthAtConvex`, `ValidC3`, `ValidC4`
* `FormalSystem/Semantics/Validity.lean` — `TaskFrame.ValidOn` (C1 on a frame)

## Tags

convex-history · consequence-relation · separation · seriality
-/

namespace FormalSystem.Metalogic.ConvexConsequence

open FormalSystem.Syntax FormalSystem.Semantics

/-! ## Fixtures -/

/-- The permissive task frame over integer time: every nonzero duration relates every pair of
states. A local abbreviation for `FrameOver.natFrame` at `D = ℤ`. -/
abbrev NF : TaskFrame := FrameOver.natFrame (D := ℤ)

/-- The bounded index with the one-point domain `[0, 0]` over `NF`, constantly in state `0`. -/
def bdd : PartialHistory NF where
  domain := fun t => 0 ≤ t ∧ t ≤ 0
  nonempty_domain := ⟨0, le_refl 0, le_refl 0⟩
  states := fun _ _ => (0 : Nat)
  respects_task := fun _ _ _ _ => (FrameOver.natFrame_rel_iff _ _ _).mpr (Or.inr rfl)

/-- `0` is in the domain of `bdd`. -/
theorem bdd_zero_mem : bdd.domain 0 := ⟨le_refl 0, le_refl 0⟩

/-- `bdd` is an interval history: its domain is `[0, 0]`. -/
theorem bdd_isInterval : IsInterval bdd := ⟨0, 0, fun _ => Iff.rfl⟩

/-- `bdd` is convex, being an interval history. -/
theorem bdd_isConvex : bdd.IsConvex := bdd_isInterval.isConvex

/-- The bounded index with the two-point domain `[0, 1]` over `NF`, constantly in state `0`.
Over `ℤ` this domain has an immediate-successor pair and two endpoints, which is exactly what
TM's discreteness axioms talk about. -/
def bdd01 : PartialHistory NF where
  domain := fun t => 0 ≤ t ∧ t ≤ 1
  nonempty_domain := ⟨0, by decide, by decide⟩
  states := fun _ _ => (0 : Nat)
  respects_task := fun _ _ _ _ => (FrameOver.natFrame_rel_iff _ _ _).mpr (Or.inr rfl)

/-- `0` is in the domain of `bdd01`. -/
theorem bdd01_zero_mem : bdd01.domain 0 := ⟨by decide, by decide⟩

/-- `1` is in the domain of `bdd01`. -/
theorem bdd01_one_mem : bdd01.domain 1 := ⟨by decide, by decide⟩

/-- `bdd01` is an interval history: its domain is `[0, 1]`. -/
theorem bdd01_isInterval : IsInterval bdd01 := ⟨0, 1, fun _ => Iff.rfl⟩

/-- `bdd01` is convex, being an interval history. -/
theorem bdd01_isConvex : bdd01.IsConvex := bdd01_isInterval.isConvex

/-- A total history of `NF`, constantly in state `0`. -/
def totalNF : PartialHistory NF :=
  PartialHistory.ofTotal NF (fun _ => (0 : Nat))
    (fun _ _ => (FrameOver.natFrame_rel_iff _ _ _).mpr (Or.inr rfl))

/-- `totalNF` is total. -/
theorem totalNF_isTotal : totalNF.IsTotal := PartialHistory.ofTotal_isTotal _ _ _

/-- Every time is in the domain of `totalNF`, by totality. -/
theorem totalNF_mem (t : ℤ) : totalNF.domain t := totalNF_isTotal t

/-- `totalNF` is convex, being total. -/
theorem totalNF_isConvex : totalNF.IsConvex := totalNF_isTotal.isConvex

/-! ## `F⊤` separates C1 from C3 and from C4 -/

/--
**`F⊤` is C1-valid at `NF`.** The library's `untl` clause quantifies over all of `D = ℤ`, which
has no maximum, so the witness `t + 1` is always available. C1's tense clauses never consult the
index's domain, so this is a fact about `D`, not about the index.
-/
theorem valid_C1_someFuture_top : NF.ValidOn (Formula.someFuture Formula.top) :=
  fun _M _τ t => ⟨t + 1, lt_add_one t, fun h => h, fun _ _ _ h => h⟩

/--
**`F⊤` is not C3-valid at `NF`.** Refuted at `(bdd, 0)`, the right endpoint of the closed
bounded interval `[0, 0]`. C3's `untl` clause requires its witness to lie in the index's
domain, and `dom bdd = {0}` contains no time strictly after `0`.
-/
theorem refute_C3_someFuture_top : ¬ ValidC3 NF (Formula.someFuture Formula.top) := by
  intro h
  obtain ⟨s, ⟨-, hs0⟩, h0s, -, -⟩ := h TaskModel.allTrue bdd bdd_isConvex 0 bdd_zero_mem
  exact absurd (lt_of_lt_of_le h0s hs0) (lt_irrefl 0)

/-- Dually, **`P⊤` is not C3-valid at `NF`**: it fails at the left endpoint of the same
interval. -/
theorem refute_C3_somePast_top : ¬ ValidC3 NF (Formula.somePast Formula.top) := by
  intro h
  obtain ⟨s, ⟨hs0, -⟩, hs, -, -⟩ := h TaskModel.allTrue bdd bdd_isConvex 0 bdd_zero_mem
  exact absurd (lt_of_le_of_lt hs0 hs) (lt_irrefl 0)

/-- **`F⊤` is not C4-valid at `NF`** either, since `bdd` is an interval index. -/
theorem refute_C4_someFuture_top : ¬ ValidC4 NF (Formula.someFuture Formula.top) := by
  intro h
  obtain ⟨s, ⟨-, hs0⟩, h0s, -, -⟩ := h TaskModel.allTrue bdd bdd_isInterval 0 bdd_zero_mem
  exact absurd (lt_of_lt_of_le h0s hs0) (lt_irrefl 0)

/-! ## `lastPoint` separates C3 from C4 -/

/-- `F⊤ → F G⊥`: a last point exists whenever a later point does. -/
def lastPoint : Formula :=
  (Formula.someFuture Formula.top).imp (Formula.someFuture (Formula.allFuture Formula.bot))

/--
**`lastPoint` is C4-valid on every frame.** An interval index `[a, b]` has its right endpoint
`b` in its own domain; if any later domain time exists then `b` is later too, and `G⊥` holds
at `b` because no domain time follows it.
-/
theorem validC4_lastPoint {F : TaskFrame} : ValidC4 F lastPoint := by
  rintro M τ ⟨a, b, hab⟩ x hx ⟨s, hs, hxs, -, -⟩
  have hsb := ((hab s).mp hs).2
  have hb : τ.domain b :=
    (hab b).mpr ⟨le_trans ((hab x).mp hx).1 (le_trans hxs.le hsb), le_refl b⟩
  refine ⟨b, hb, lt_of_lt_of_le hxs hsb, ?_, fun _ _ _ _ h => h⟩
  rintro ⟨u, hu, hbu, -, -⟩
  exact absurd ((hab u).mp hu).2 (not_le_of_gt hbu)

/--
**`lastPoint` is not C3-valid at `NF`**, so the containment `validC3_imp_validC4` is strict.
Refuted at the total index `totalNF`: `F⊤` holds at `0`, and no integer is a last point.
-/
theorem refute_C3_lastPoint : ¬ ValidC3 NF lastPoint := by
  intro h
  obtain ⟨s, -, -, hG, -⟩ := h TaskModel.allTrue totalNF totalNF_isConvex 0 (totalNF_mem 0)
    ⟨1, totalNF_mem 1, by decide, fun h => h, fun _ _ _ _ h => h⟩
  exact hG ⟨s + 1, totalNF_mem (s + 1), lt_add_one s, fun h => h, fun _ _ _ _ h => h⟩

end FormalSystem.Metalogic.ConvexConsequence
