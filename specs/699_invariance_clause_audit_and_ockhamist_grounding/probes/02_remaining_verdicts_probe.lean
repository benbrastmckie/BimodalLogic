import FormalSystem.Metalogic.Decidability.PlusWitnessFamily.Incompleteness
import FormalSystem.Metalogic.Decidability.PlusWitnessFamily.Decide
import FormalSystem.Metalogic.Decidability.WitnessFamily.Sharing.Decide

/-!
# Audit probe 2: the two verdicts probe 01 left asserted

Probe 01 (`01_clause_shape_collapse_probe.lean`) machine-checks nine of Part A's table cells.
Two remain asserted rather than probed:

- **Row 6** (`shareClauseAt`'s `snce`/`untl` arms, `Sharing/Decide.lean` 420-429): the table's
  Derivation cell reads "same two derivations at `Formula`; not separately probed". This file
  supplies the `Formula`-side mirror of probe 01's `plusShareClauseAt_snce_collapse` /
  `plusShareClauseAt_untl_collapse`.
- **Row 12** (`PlusBoxFaithful`'s globality, `PlusWitnessFamily/Predicates.lean` 195-197): A3
  writes the (C3) composition out in prose only. This file writes it as a theorem.

This probe is standalone: it does **not** import probe 01 (not in the build graph) and
re-declares `clause_shape_collapse` locally, exactly as probe 01 states it in its own three
lines. Nothing here is proposed for landing in the library.
-/

namespace FormalSystem.Metalogic.Decidability

open FormalSystem.Syntax FormalSystem.PlusLanguage
open FormalSystem.PlusLanguage.PlusFormula

/-- **Clause-shape collapse**, re-declared standalone (see probe 01 for the full account). A
biconditional universally quantified over a reflexive relation, whose left side does not mention
the quantified variable, is an invariance axiom for that left side across the relation. -/
theorem clause_shape_collapse {ι : Type*} {R : ι → ι → Prop} (hrefl : ∀ i, R i i)
    {P Ψ : ι → Prop} (hclause : ∀ i j, R i j → (P i ↔ Ψ j)) :
    ∀ i j, R i j → (P i ↔ P j) :=
  fun i j hij => (hclause i j hij).trans (hclause j j (hrefl j)).symm

/-! ## Row 6 — `shareClauseAt`'s two arms, at the decision procedure's `Formula`-side data

The exact mirror of probe 01's `PlusSharingWitnessFamily.plusShareClauseAt_snce_collapse` /
`..._untl_collapse`, at `SharingWitnessFamily.shareClauseAt` (`Sharing/Decide.lean` 420-429)
instead of `PlusSharingWitnessFamily.plusShareClauseAt`. The guards `rt i = rt k` / `rp i = rp j`
are reflexive by `rfl`, so the same instantiation applies verbatim.
-/

/-- The data-level `snce` collapse at `Formula`: `shareClauseAt`'s `snce` arm forces the label
row `Lm` to be constant on the fibres of `rt`. -/
theorem SharingWitnessFamily.shareClauseAt_snce_collapse {n : ℕ} (bx : Formula → Bool)
    (rt rp : Fin n → Fin n) (Lm Lt Lp : Fin n → Finset Formula) (g e : Formula)
    (h : ∀ i : Fin n, SharingWitnessFamily.shareClauseAt bx rt rp Lm Lt Lp i (Formula.snce g e)) :
    ∀ i k : Fin n, rt i = rt k →
      (Formula.snce g e ∈ Lt i ↔ Formula.snce g e ∈ Lt k) :=
  clause_shape_collapse (R := fun i k => rt i = rt k) (fun _ => rfl) (fun i k hik => h i k hik)

/-- The data-level `untl` collapse at `Formula`, on the fibres of `rp`. -/
theorem SharingWitnessFamily.shareClauseAt_untl_collapse {n : ℕ} (bx : Formula → Bool)
    (rt rp : Fin n → Fin n) (Lm Lt Lp : Fin n → Finset Formula) (g e : Formula)
    (h : ∀ i : Fin n, SharingWitnessFamily.shareClauseAt bx rt rp Lm Lt Lp i (Formula.untl g e)) :
    ∀ i j : Fin n, rp i = rp j →
      (Formula.untl g e ∈ Lt i ↔ Formula.untl g e ∈ Lt j) :=
  clause_shape_collapse (R := fun i j => rp i = rp j) (fun _ => rfl) (fun i j hij => h i j hij)

/-! ## Row 12 — `PlusBoxFaithful`'s globality, written out

(C1')'s box conjunct (`PlusLocalCoherentShare`, `PlusWitnessFamily/Predicates.lean` 89-90) gives
`box χ ∈ S.L i t ↔ S.bx χ = true` at *every* `(i, t)`, so the right side already does not depend
on the position. Composing with `PlusBoxFaithful` (`Predicates.lean` 195-197) additionally
identifies that constant with global membership of the bare `χ`, giving the full three-way
chain A3 states in prose:

  `box χ ∈ L i t  ↔  bx χ = true  ↔  ∀ j v, χ ∈ L j v`

from which the row-12 globality congruence `box χ ∈ L i t ↔ box χ ∈ L j v` follows immediately by
transitivity through either middle term.
-/

variable {Γ Del : PlusContext}

/-- The full (C1')/(C3) composition, exactly as A3 states it. -/
theorem PlusSharingWitnessFamily.plusBox_globality (S : PlusSharingWitnessFamily Γ Del)
    (hloc : S.PlusLocalCoherentShare) (hbox : S.toPlusWitnessFamily.PlusBoxFaithful)
    (χ : PlusFormula) (hc : PlusFormula.box χ ∈ plusClosureOf (Γ ++ Del))
    (i : Fin S.lassos.length) (t : ℤ) :
    PlusFormula.box χ ∈ S.L i t ↔ ∀ (j : Fin S.lassos.length) (v : ℤ), χ ∈ S.L j v :=
  ((hloc i t).2.2.1 χ hc).trans (hbox χ hc)

/-- **Row 12's derivation, named for the report.** A boxed formula in the target closure is
labelled at every position or at none, across indices *and* times. -/
theorem PlusSharingWitnessFamily.plusBox_share_congr (S : PlusSharingWitnessFamily Γ Del)
    (hloc : S.PlusLocalCoherentShare) (hbox : S.toPlusWitnessFamily.PlusBoxFaithful)
    (χ : PlusFormula) (hc : PlusFormula.box χ ∈ plusClosureOf (Γ ++ Del)) :
    ∀ (i : Fin S.lassos.length) (t : ℤ) (j : Fin S.lassos.length) (v : ℤ),
      PlusFormula.box χ ∈ S.L i t ↔ PlusFormula.box χ ∈ S.L j v := by
  intro i t j v
  rw [PlusSharingWitnessFamily.plusBox_globality S hloc hbox χ hc i t,
      PlusSharingWitnessFamily.plusBox_globality S hloc hbox χ hc j v]

/-! ## Axiom audit -/

#print axioms SharingWitnessFamily.shareClauseAt_snce_collapse
#print axioms SharingWitnessFamily.shareClauseAt_untl_collapse
#print axioms PlusSharingWitnessFamily.plusBox_globality
#print axioms PlusSharingWitnessFamily.plusBox_share_congr

end FormalSystem.Metalogic.Decidability
