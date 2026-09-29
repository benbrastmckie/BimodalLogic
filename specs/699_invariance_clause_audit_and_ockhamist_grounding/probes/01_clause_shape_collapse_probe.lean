import FormalSystem.Metalogic.Decidability.PlusWitnessFamily.Incompleteness
import FormalSystem.Metalogic.Decidability.PlusWitnessFamily.Decide

/-!
# Audit probe: the clause-shape collapse, abstracted and re-instantiated

`snce_share_congr` (`PlusWitnessFamily/Incompleteness.lean`) is two lines from two readings of one
(C1') conjunct. This probe isolates what those two lines actually use — reflexivity of the
quantified relation and nothing else — as `clause_shape_collapse`, then re-instantiates it at every
(C1') conjunct of the audited shape, on both the landed substrate and the substrate as it would
read after the recommended `trans` redesign.

Nothing here is proposed for landing in the library; it exists so each audit verdict is checkable
rather than asserted.
-/

namespace FormalSystem.Metalogic.Decidability

open FormalSystem.Syntax FormalSystem.PlusLanguage
open FormalSystem.PlusLanguage.PlusFormula

/-! ## The abstract lemma

Read a biconditional clause once at an arbitrary related index and once at that index against
itself. The right-hand sides are then the *same* proposition, so the two left-hand sides are
equivalent. Reflexivity is the only property of `R` used; `Ψ` is arbitrary.
-/

/-- **Clause-shape collapse.** A biconditional universally quantified over a reflexive relation,
whose left side does not mention the quantified variable, is an invariance axiom for that left
side across the relation. -/
theorem clause_shape_collapse {ι : Type*} {R : ι → ι → Prop} (hrefl : ∀ i, R i i)
    {P Ψ : ι → Prop} (hclause : ∀ i j, R i j → (P i ↔ Ψ j)) :
    ∀ i j, R i j → (P i ↔ P j) :=
  fun i j hij => (hclause i j hij).trans (hclause j j (hrefl j)).symm

/-- **What survives when reflexivity is dropped.** Without `hrefl` the clause still identifies any
two sources sharing one witness. This residual is semantically forced — two positions with the
same successor set must agree, since the label at a position is the truth set of the histories
through it — so it is the invariance a repaired clause is *allowed* to entail, and reflexivity is
exactly what turns it into the collapse above (take `i' := j`). -/
theorem clause_shape_common_witness {ι : Type*} {R : ι → ι → Prop} {P Ψ : ι → Prop}
    (hclause : ∀ i j, R i j → (P i ↔ Ψ j)) :
    ∀ i i' j, R i j → R i' j → (P i ↔ P i') :=
  fun i i' j hij hi'j => (hclause i j hij).trans (hclause i' j hi'j).symm

namespace PlusSharingWitnessFamily

variable {Γ Del : PlusContext}

/-! ## The landed substrate: both temporal conjuncts of (C1') collapse -/

/-- The landed `snce_share_congr`, re-derived through the abstract lemma: the two-line proof in
`Incompleteness.lean` is exactly `clause_shape_collapse` at `R := S.share t`. -/
theorem snce_share_congr' (S : PlusSharingWitnessFamily Γ Del)
    (hloc : S.PlusLocalCoherentShare) (t : ℤ) (g e : PlusFormula)
    (hc : PlusFormula.snce g e ∈ plusClosureOf (Γ ++ Del)) :
    ∀ i j, S.share t i j →
      (PlusFormula.snce g e ∈ S.L i t ↔ PlusFormula.snce g e ∈ S.L j t) :=
  clause_shape_collapse (S.share_refl t)
    (fun i k hik => (hloc i t).2.2.2.2 k hik g e hc)

/-- **New: the `untl` conjunct collapses in the same place, not only one step shifted.**

The exact mirror of `snce_share_congr`: the `untl` label at time `t` is constant across the
*arrival* class at `t + 1`. Task 696's `untl_shift_share_congr` is a different consequence of the
same conjunct (congruence of the one-step unfolding across the class at `t`, read at `t - 1`); this
one is the label congruence itself, and is not recorded anywhere in the tree. -/
theorem untl_share_succ_congr (S : PlusSharingWitnessFamily Γ Del)
    (hloc : S.PlusLocalCoherentShare) (t : ℤ) (g e : PlusFormula)
    (hc : PlusFormula.untl g e ∈ plusClosureOf (Γ ++ Del)) :
    ∀ i j, S.share (t + 1) i j →
      (PlusFormula.untl g e ∈ S.L i t ↔ PlusFormula.untl g e ∈ S.L j t) :=
  clause_shape_collapse (S.share_refl (t + 1))
    (fun i j hij => (hloc i t).2.2.2.1 j hij g e hc)

/-! ## The `Formula`-side mirror

`SharingWitnessFamily.LocalCoherentShare` has the same two conjuncts at `Formula`, so it has the
same two collapses. Neither is recorded in the tree.
-/

end PlusSharingWitnessFamily

namespace SharingWitnessFamily

variable {Γ Del : Context}

/-- `Formula`-side mirror of `snce_share_congr`. -/
theorem snce_share_congr_formula (S : SharingWitnessFamily Γ Del)
    (hloc : S.LocalCoherentShare) (t : ℤ) (g e : Formula)
    (hc : Formula.snce g e ∈ closureOf (Γ ++ Del)) :
    ∀ i j, S.share t i j → (Formula.snce g e ∈ S.L i t ↔ Formula.snce g e ∈ S.L j t) :=
  clause_shape_collapse (S.share_refl t)
    (fun i k hik => (hloc i t).2.2.2.2 k hik g e hc)

/-- `Formula`-side mirror of `untl_share_succ_congr`. -/
theorem untl_share_succ_congr_formula (S : SharingWitnessFamily Γ Del)
    (hloc : S.LocalCoherentShare) (t : ℤ) (g e : Formula)
    (hc : Formula.untl g e ∈ closureOf (Γ ++ Del)) :
    ∀ i j, S.share (t + 1) i j → (Formula.untl g e ∈ S.L i t ↔ Formula.untl g e ∈ S.L j t) :=
  clause_shape_collapse (S.share_refl (t + 1))
    (fun i j hij => (hloc i t).2.2.2.1 j hij g e hc)

end SharingWitnessFamily

/-! ## The decision-procedure mirrors

`plusShareClauseAt` / `shareClauseAt` re-state the same two conjuncts at explicit data, with the
guard `rp i = rp j` / `rt i = rt k` in place of `S.share`. Those guards are reflexive by `rfl`, so
the same lemma applies and the decision procedure inherits the collapse — as it must, being
equivalent to (C1').
-/

/-- The data-level `snce` collapse: `plusShareClauseAt`'s `snce` arm forces the label row `Lt` to
be constant on the fibres of `rt`. -/
theorem PlusSharingWitnessFamily.plusShareClauseAt_snce_collapse {n : ℕ} (bx : PlusFormula → Bool)
    (rt rp : Fin n → Fin n) (Lm Lt Lp : Fin n → Finset PlusFormula) (g e : PlusFormula)
    (h : ∀ i : Fin n, PlusSharingWitnessFamily.plusShareClauseAt bx rt rp Lm Lt Lp i (PlusFormula.snce g e)) :
    ∀ i j : Fin n, rt i = rt j →
      (PlusFormula.snce g e ∈ Lt i ↔ PlusFormula.snce g e ∈ Lt j) :=
  clause_shape_collapse (R := fun i j => rt i = rt j) (fun _ => rfl) (fun i k hik => h i k hik)

/-- The data-level `untl` collapse, on the fibres of `rp`. -/
theorem PlusSharingWitnessFamily.plusShareClauseAt_untl_collapse {n : ℕ} (bx : PlusFormula → Bool)
    (rt rp : Fin n → Fin n) (Lm Lt Lp : Fin n → Finset PlusFormula) (g e : PlusFormula)
    (h : ∀ i : Fin n, PlusSharingWitnessFamily.plusShareClauseAt bx rt rp Lm Lt Lp i (PlusFormula.untl g e)) :
    ∀ i j : Fin n, rp i = rp j →
      (PlusFormula.untl g e ∈ Lt i ↔ PlusFormula.untl g e ∈ Lt j) :=
  clause_shape_collapse (R := fun i j => rp i = rp j) (fun _ => rfl) (fun i j hij => h i j hij)

/-! ## The redesigned substrate still collapses, now across `trans`

Task 696's recommendation re-quantifies (C1')'s two temporal conjuncts over a fourth periodic
datum `trans`, pruned by arrival renaming. `trans` must be reflexive — `trans_refl` is a declared
field of the proposed skeleton, and it has to be, since `Thread.const` (every position lies on a
thread) depends on it. Reflexivity is the only hypothesis `clause_shape_collapse` needs, so the
collapse survives the redesign verbatim, relocated from `share`-classes to `trans`.

`trans` is an external parameter here, exactly as in task 696's probe 03, so these are theorems
about the redesigned conditions without the redesign being built.
-/

namespace PlusSharingWitnessFamily

variable {Γ Del : PlusContext}

/-- (C1')'s `untl` conjunct as it would read after the redesign. -/
def TUntlClause (S : PlusSharingWitnessFamily Γ Del)
    (trans : ℤ → Fin S.lassos.length → Fin S.lassos.length → Prop) : Prop :=
  ∀ (i : Fin S.lassos.length) (t : ℤ) (j : Fin S.lassos.length), trans t i j →
    ∀ g e : PlusFormula, PlusFormula.untl g e ∈ plusClosureOf (Γ ++ Del) →
      (PlusFormula.untl g e ∈ S.L i t ↔
        (e ∈ S.L j (t + 1) ∨ (g ∈ S.L j (t + 1) ∧ PlusFormula.untl g e ∈ S.L j (t + 1))))

/-- (C1')'s `snce` conjunct as it would read after the redesign: quantified over the *predecessor*
argument of `trans (t - 1)`. -/
def TSnceClause (S : PlusSharingWitnessFamily Γ Del)
    (trans : ℤ → Fin S.lassos.length → Fin S.lassos.length → Prop) : Prop :=
  ∀ (i : Fin S.lassos.length) (t : ℤ) (k : Fin S.lassos.length), trans (t - 1) k i →
    ∀ g e : PlusFormula, PlusFormula.snce g e ∈ plusClosureOf (Γ ++ Del) →
      (PlusFormula.snce g e ∈ S.L i t ↔
        (e ∈ S.L k (t - 1) ∨ (g ∈ S.L k (t - 1) ∧ PlusFormula.snce g e ∈ S.L k (t - 1))))

/--
**The redesigned `untl` conjunct is still an invariance axiom**, now across `trans t`: two indices
that may succeed one another out of time `t` agree on every `untl` label of the closure *at time
`t`*. Nothing relates them at `t` semantically — arrival pruning relates them at `t + 1` — so this
is a residual latent collapse, not an intended invariance.

Vacuous exactly when `trans t` is the diagonal, which is why both of task 696's gate families
(`trans = eq`) pass without exhibiting it.
-/
theorem tUntl_trans_congr (S : PlusSharingWitnessFamily Γ Del)
    {trans : ℤ → Fin S.lassos.length → Fin S.lassos.length → Prop}
    (hrefl : ∀ u i, trans u i i) (h : S.TUntlClause trans) (t : ℤ) (g e : PlusFormula)
    (hc : PlusFormula.untl g e ∈ plusClosureOf (Γ ++ Del)) :
    ∀ i j, trans t i j →
      (PlusFormula.untl g e ∈ S.L i t ↔ PlusFormula.untl g e ∈ S.L j t) :=
  clause_shape_collapse (hrefl t) (fun i j hij => h i t j hij g e hc)

/-- The same residual at the redesigned `untl` conjunct, with no reflexivity hypothesis: two
indices with a common `trans t`-successor agree on `untl` labels at `t`. Dropping `trans_refl`
from the proposed skeleton leaves exactly this, and nothing stronger. -/
theorem tUntl_common_succ_congr (S : PlusSharingWitnessFamily Γ Del)
    {trans : ℤ → Fin S.lassos.length → Fin S.lassos.length → Prop}
    (h : S.TUntlClause trans) (t : ℤ) (g e : PlusFormula)
    (hc : PlusFormula.untl g e ∈ plusClosureOf (Γ ++ Del)) :
    ∀ i i' j, trans t i j → trans t i' j →
      (PlusFormula.untl g e ∈ S.L i t ↔ PlusFormula.untl g e ∈ S.L i' t) :=
  clause_shape_common_witness (fun i j hij => h i t j hij g e hc)

/-- **The redesigned `snce` conjunct is still an invariance axiom**, across `trans (t - 1)` read
backwards: a predecessor and its successor agree on every `snce` label of the closure at time `t`.
Again vacuous only when `trans` is the diagonal. -/
theorem tSnce_trans_congr (S : PlusSharingWitnessFamily Γ Del)
    {trans : ℤ → Fin S.lassos.length → Fin S.lassos.length → Prop}
    (hrefl : ∀ u i, trans u i i) (h : S.TSnceClause trans) (t : ℤ) (g e : PlusFormula)
    (hc : PlusFormula.snce g e ∈ plusClosureOf (Γ ++ Del)) :
    ∀ i k, trans (t - 1) k i →
      (PlusFormula.snce g e ∈ S.L i t ↔ PlusFormula.snce g e ∈ S.L k t) :=
  clause_shape_collapse (R := fun i k => trans (t - 1) k i) (fun i => hrefl (t - 1) i)
    (fun i k hki => h i t k hki g e hc)

end PlusSharingWitnessFamily

/-! ## Axiom audit -/

#print axioms PlusSharingWitnessFamily.snce_share_congr'
#print axioms PlusSharingWitnessFamily.untl_share_succ_congr
#print axioms SharingWitnessFamily.snce_share_congr_formula
#print axioms SharingWitnessFamily.untl_share_succ_congr_formula
#print axioms PlusSharingWitnessFamily.plusShareClauseAt_snce_collapse
#print axioms PlusSharingWitnessFamily.plusShareClauseAt_untl_collapse
#print axioms PlusSharingWitnessFamily.tUntl_trans_congr
#print axioms PlusSharingWitnessFamily.tSnce_trans_congr
#print axioms PlusSharingWitnessFamily.tUntl_common_succ_congr
#print axioms clause_shape_common_witness

end FormalSystem.Metalogic.Decidability
