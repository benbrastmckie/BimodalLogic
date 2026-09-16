/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Conservativity.SpWitness
import FormalSystem.Metalogic.Conservativity.Z1Countermodel
import FormalSystem.Metalogic.Algebraic.FlowFrame

/-!
# Neither closed row's obstruction transfers to the dense classes

Both frame classes over which the forward direction of `L⁻ ⊂ L` is **refuted** are refuted by a
*dichotomy witness*: a base-language schema that is valid over the class because the class splits
into two H/G-distinguishable halves, while no single TM⁻-derivation covers both halves at once.

| Row | Witness | Why it separates |
|---|---|---|
| `.Base` | `Sp φ ψ := □(DF φ) ∨ □(DN ψ)` (`Conservativity/SpWitness.lean`) | every frame's single `Duration` is either dense or has a least positive element (`duration_dense_or_least_pos`), so one disjunct always holds — but which one is not decided uniformly |
| `.ZTime` | `Z1 φ := G(Gφ → φ) → (F(Gφ) → Gφ)` (`Conservativity/Backward.lean`) | valid over ℤ-time proper, refuted over the non-Archimedean discrete carrier `ℚ ×ₗ ℤ` (`Conservativity/Z1Countermodel.lean`) |

This module machine-checks that **neither witness survives the move to `FrameClass.Dense`**, for
two different and independent reasons:

* `Sp` becomes a **theorem** of the dense system. Its right disjunct's inner formula *is* the
  density axiom `Axiom.dn`, so `⊢⁻[.Dense] □(DN ψ)` by necessitation, and `Sp` follows by
  `Axiom.prop_s` and modus ponens. A schema derivable in the system cannot witness the system's
  incompleteness. Since `Dense ≤ RTime`, the same derivation runs at `.RTime`
  (`spDerivableRTime`), so this half covers both open rows at once.
* `Z1` stops being **valid**. It is refuted here on the flow frame over ℚ, at the same valuation
  `p := {x | 1 ≤ x}` that makes `Gp ↔ p` pointwise on any dense unbounded chain. So it is not
  `MinusValidDense`, and a formula that is not valid over the class cannot witness a validity the
  system fails to derive.

## What this is evidence for, and what it is not

Positively: the structural reason the two closed rows closed was that `FrameClass.Base` and
`FrameClass.ZTime` each split into two H/G-definable subclasses (dense-versus-discrete durations
in the first case, Archimedean-versus-not in the second). `FrameClass.Dense` does not split that
way, and this module is the machine-checked form of that observation — the two known separating
schemata are provably unavailable.

Negatively: **this is not a completeness proof and does not approach one.** Ruling out the two
witnesses that happen to be in the tree says nothing about the existence of some third witness.
No theorem here concludes in `TMMinusComplete _` or `Forward _`, and the standing prohibition in
`Metalogic/Conservativity.lean` — never state a completeness or forward-conservativity theorem
and discharge it with `sorry` — applies to this module in full. The current status of all four
rows, with the residual content of the dense route and the named obstruction at the Dedekind
row, is recorded in `Conservativity/TMCompletenessReduction.lean`'s module docstring.

## The ℚ countermodel

`Conservativity/Z1Countermodel.lean`'s existing model lives at `ℚ ×ₗ ℤ`, which is **not** densely
ordered — the lexicographic second coordinate is discrete — so it cannot be reused here even
though the `Z1` refutation reads almost identically. The model below is a fresh one at
`TemporalOrder.of ℚ`, sharing only the generic `multiFamTaskFrameGen`/`multiFamHistoryGen`
scaffolding of `Metalogic/Algebraic/FlowFrame.lean`. The `FrameClass.Sat .Dense` side condition
is discharged by instance resolution straight through the reducible chain
`Sat .Dense ⇝ TaskFrame.IsDense ⇝ DenselyOrdered ℚ`.

Density is used exactly once, in `q_gp_iff_p`: to see that `Gp` fails at a point `t < 1` one needs
*some* `s` with `t < s < 1`, and `exists_between` supplies it. On `ℚ ×ₗ ℤ` the corresponding step
used the discrete successor instead, which is the precise sense in which the two countermodels
are not variants of one another.

## Main Results

- `spDerivableDense`, `spDerivableRTime` — the `.Base` witness is a theorem of both open
  systems, hence separates neither
- `q_atom_iff`, `q_gp_iff_p` — the ℚ model's valuation lemma and the pointwise `Gp ↔ p` collapse
- `q_G_Gp_imp_p`, `q_F_Gp`, `q_not_Gp`, `q_not_true_at_zero` — the three `Z1` parts and their
  combination at the base point `0`
- `not_minusValidDense_z1` — the `.ZTime` witness is not dense-valid, hence separates nothing here

## References

* `FormalSystem/Metalogic/Conservativity/SpWitness.lean` — `Sp`, `minusValid_sp`
* `FormalSystem/Metalogic/Conservativity/Z1Countermodel.lean` — `Z1`'s discrete countermodel, the
  structural template for the ℚ model below
* `FormalSystem/Metalogic/Algebraic/FlowFrame.lean` — `multiFamTaskFrameGen`,
  `multiFamHistoryGen`, `multiFamHistoryGen_total`
* `FormalSystem/Metalogic/Conservativity/TMCompletenessReduction.lean` — the four-row status table
  this module's results are cited from

## Tags

conservativity · dense · obstruction · countermodel · base-language
-/

namespace FormalSystem.Metalogic

open FormalSystem.Syntax
open FormalSystem.ProofSystem
open FormalSystem.MinusLanguage
open FormalSystem.Semantics
open FormalSystem.Metalogic.Algebraic

/-! ## The `.Base` witness is a theorem of both open systems -/

/--
**`Sp` is a `TM⁻_d` theorem.**

`Sp φ ψ` is `□(DF φ) ∨ □(DN ψ)`, and `.or` unfolds to `(·).neg.imp (·)`, so it suffices to derive
the *right* disjunct outright and weaken. The right disjunct's inner formula
`GGψ → Gψ` is literally `Axiom.dn ψ`, whose `minFrameClass` is `.Dense`; `necessitation` boxes it
and `Axiom.prop_s` supplies `χ → (θ → χ)` at `χ := □(DN ψ)`, `θ := ¬□(DF φ)`.

The tactic `by decide` does **not** discharge the `minFrameClass ≤ .Dense` side condition — the
expected type carries free variables — so the two side conditions are given as `le_refl` and
`FrameClass.base_le` terms.

Consequence: `Sp` cannot be the `.Dense` row's separating witness, because it is not a
`.Dense`-underivable validity. It is a `.Dense` *theorem*. (Contrast `Conservativity/
SpCountermodel.lean`'s `not_derivable_sp`, which is the `.Base` row, where `Axiom.dn` is not
available and the derivation below does not exist.)

Stated at the bare `DerivationTree` (`⊢⁻[fc] φ`) rather than at `MinusLanguage.Derivable`, so the
derivation term itself is available to any consumer; see the naming-exemption note below on what
that costs.
-/
noncomputable def spDerivableDense (φ ψ : MinusFormula) :
    ⊢⁻[FrameClass.Dense] Sp φ ψ :=
  let dn : ⊢⁻[FrameClass.Dense] (ψ.allFuture.allFuture.imp ψ.allFuture) :=
    .axiom [] _ (Axiom.dn ψ) (le_refl FrameClass.Dense)
  let boxdn := DerivationTree.necessitation _ dn
  let s : ⊢⁻[FrameClass.Dense]
      ((ψ.allFuture.allFuture.imp ψ.allFuture).box.imp
        ((((φ.allPast.and φ).and MinusFormula.top.someFuture).imp
          φ.allPast.someFuture).box.neg.imp
          (ψ.allFuture.allFuture.imp ψ.allFuture).box)) :=
    .axiom [] _ (Axiom.prop_s _ _) (FrameClass.base_le _)
  DerivationTree.modus_ponens [] _ _ s boxdn

/--
**`Sp` is a `TM⁻_dc` theorem**, by the same derivation at `.RTime`.

`Axiom.dn`'s `minFrameClass` is `.Dense` and `Dense ≤ RTime` holds definitionally, so the only
change from `spDerivableDense` is the side-condition term. There is no frame-class weakening
lemma for `DerivationTree` in this tree, so the derivation is restated rather than transported;
the two proofs are deliberately kept literally parallel so that a future weakening lemma can
replace both at once.

Together with `spDerivableDense` this closes the `Sp` half for **both** open rows.
-/
noncomputable def spDerivableRTime (φ ψ : MinusFormula) :
    ⊢⁻[FrameClass.RTime] Sp φ ψ :=
  let dn : ⊢⁻[FrameClass.RTime] (ψ.allFuture.allFuture.imp ψ.allFuture) :=
    .axiom [] _ (Axiom.dn ψ) (show FrameClass.Dense ≤ FrameClass.RTime from trivial)
  let boxdn := DerivationTree.necessitation _ dn
  let s : ⊢⁻[FrameClass.RTime]
      ((ψ.allFuture.allFuture.imp ψ.allFuture).box.imp
        ((((φ.allPast.and φ).and MinusFormula.top.someFuture).imp
          φ.allPast.someFuture).box.neg.imp
          (ψ.allFuture.allFuture.imp ψ.allFuture).box)) :=
    .axiom [] _ (Axiom.prop_s _ _) (FrameClass.base_le _)
  DerivationTree.modus_ponens [] _ _ s boxdn

/-! ### Why these two are `def`s, and why they are not restated

`spDerivableDense` and `spDerivableRTime` are `DerivationTree`-valued, hence `def`s rather than
`theorem`s. They now carry lowerCamelCase names, which is what the rule table in
`docs/development/NAMING_CONVENTION_DEVIATION.md` requires of anything a declaration *produces*
as data — `DerivationTree`-valued results included — so no linter exemption is needed and none is
given.

They read as derivability facts rather than as constructions, and every neighbouring result in
this namespace that says something about what TM⁻ does or does not derive is snake_case —
`z1_translate`, `not_derivable_sp`, `not_minus_derivable_z1`, `minusValid_sp`. Those are snake_case
because they are `Prop`-valued proofs; these two say the same kind of thing but are `def`s only
because `⊢⁻[fc] φ` is `DerivationTree` rather than `Nonempty ∘ DerivationTree`. That is a fact
about the notation, not about what the declarations assert, and the naming rule keys on the
former.

The `Nonempty`-wrapped restatement at `MinusLanguage.Derivable` is deliberately **not** provided:
it would be a second name for the same fact under a strictly weaker statement, and a plain
`⟨spDerivableDense φ ψ⟩` at any use site is shorter than the wrapper would be. That prohibition is
still in force — the rename resolved the naming question without touching either signature. -/

/-! ## The ℚ model refuting the `.ZTime` witness -/

/-- The countermodel's temporal order: ℚ. Densely ordered, unbounded in both directions, and an
ordered abelian group, so it satisfies every `TemporalOrder` field and the `.Dense` tag. -/
noncomputable abbrev qD : TemporalOrder := TemporalOrder.of ℚ

/-- The countermodel's frame: the deterministic flow frame at `qD` with a single (`Unit`) family.
All four frame axioms are discharged generically by `multiFamTaskFrameGen`. -/
noncomputable abbrev qF : TaskFrame := multiFamTaskFrameGen qD Unit

/-- The countermodel's valuation: `p` holds at `w` iff `w`'s ℚ-coordinate is `≥ 1`. The same
half-line valuation as `Z1Countermodel.lean`'s, read off the single ℚ coordinate rather than off
the ℚ-component of a lexicographic pair. -/
noncomputable def qTM : TaskModel qF where
  valuation := fun w _ => 1 ≤ w.2

/-- The countermodel's history: the flow line through family `()` starting at `0`. -/
noncomputable abbrev qτ : PartialHistory qF := multiFamHistoryGen () (0 : (qD : Type))

/-- `qτ` is total, definitionally (`multiFamHistoryGen` carries `domain := fun _ => True`). -/
theorem qτ_total : qτ.IsTotal := multiFamHistoryGen_total (D := qD) () 0

/-- **The valuation lemma.** `p` holds at time `t` along `qτ` iff `1 ≤ t`. The domain conjunct of
`MinusTruthAt`'s atom clause is `trivial` here, since `qτ` is total. -/
theorem q_atom_iff (p : Atom) (t : (qD : Type)) :
    MinusTruthAt qTM qτ t (MinusFormula.atom p) ↔ (1 : ℚ) ≤ t := by
  constructor
  · rintro ⟨_, h⟩
    simpa [qTM, multiFamHistoryGen] using h
  · intro h
    refine ⟨trivial, ?_⟩
    simpa [qTM, multiFamHistoryGen] using h

/--
**`Gp ↔ p`, pointwise** — the collapse that makes `Z1` fail.

`←` is monotonicity of the half-line: if `1 ≤ t` and `t < s` then `1 ≤ s`. `→` is where
**density** enters, and is the step that has no analogue in `Z1Countermodel.lean`: if `t < 1`,
`exists_between` produces `s` with `t < s < 1`, and `p` fails at `s`, so `Gp` fails at `t`. On the
discrete carrier `ℚ ×ₗ ℤ` the corresponding witness was the lexicographic successor
`(t.1, t.2 + 1)` instead, which is why the two models are not variants of one another.
-/
theorem q_gp_iff_p (p : Atom) (t : (qD : Type)) :
    MinusTruthAt qTM qτ t (MinusFormula.atom p).allFuture ↔ MinusTruthAt qTM qτ t (MinusFormula.atom p) := by
  rw [MinusTruth.future_iff, q_atom_iff]
  constructor
  · intro h
    by_contra hc
    push_neg at hc
    obtain ⟨s, hts, hs1⟩ := exists_between (show (t : ℚ) < 1 from hc)
    have h2 := h s hts
    rw [q_atom_iff] at h2
    exact absurd h2 (not_le.mpr hs1)
  · intro h s hs
    rw [q_atom_iff]
    exact h.trans hs.le

/-- `Z1`'s antecedent `G(Gp → p)` is true at `0`: immediate from `q_gp_iff_p` at each future
point. -/
theorem q_G_Gp_imp_p (p : Atom) :
    MinusTruthAt qTM qτ (0 : (qD : Type))
      ((MinusFormula.atom p).allFuture.imp (MinusFormula.atom p)).allFuture := by
  rw [MinusTruth.future_iff]
  intro s _
  rw [MinusTruth.imp_iff]
  exact (q_gp_iff_p p s).mp

/-- `F(Gp)` is true at `0`, witnessed by `1`: `Gp` holds at `1` because `p` does. -/
theorem q_F_Gp (p : Atom) :
    MinusTruthAt qTM qτ (0 : (qD : Type)) (MinusFormula.atom p).allFuture.someFuture := by
  rw [MinusTruth.someFuture_iff]
  refine ⟨(1 : ℚ), by norm_num, ?_⟩
  rw [(q_gp_iff_p p _), q_atom_iff]

/-- `Gp` is false at `0`: by `q_gp_iff_p` it is equivalent to `p` at `0`, and `¬ (1 ≤ 0)`. -/
theorem q_not_Gp (p : Atom) :
    ¬ MinusTruthAt qTM qτ (0 : (qD : Type)) (MinusFormula.atom p).allFuture := by
  rw [(q_gp_iff_p p _), q_atom_iff]
  norm_num

/-- **`Z1 p` is false at `0` in the ℚ model.** The antecedent `G(Gp → p)` holds while the
consequent `F(Gp) → Gp` fails, since `F(Gp)` holds and `Gp` does not. -/
theorem q_not_true_at_zero (p : Atom) :
    ¬ MinusTruthAt qTM qτ (0 : (qD : Type)) (Conservativity.Z1 (MinusFormula.atom p)) := by
  intro h
  unfold Conservativity.Z1 at h
  rw [MinusTruth.imp_iff] at h
  have h_cons := h (q_G_Gp_imp_p p)
  rw [MinusTruth.imp_iff] at h_cons
  exact q_not_Gp p (h_cons (q_F_Gp p))

/--
**The `.ZTime` witness is not dense-valid.**

`MinusValidDense` is `MinusValidIn .Dense`, so one `.Dense`-satisfying frame carrying a refutation
suffices; `MinusValidIn.apply_total` supplies the elimination and the `FrameClass.Sat .Dense qF` side
condition is `inferInstance` through the reducible chain to `DenselyOrdered ℚ`.

With `spDerivableDense`, this is the machine-checked half of the record that the `.Dense` row
has no known separating witness: one of the two candidates is a theorem of the system, the other
is not a validity of the class.
-/
theorem not_minusValidDense_z1 (p : Atom) :
    ¬ MinusValidDense (Conservativity.Z1 (MinusFormula.atom p)) := fun h =>
  q_not_true_at_zero p (MinusValidIn.apply_total h qF inferInstance qTM qτ qτ_total 0)

end FormalSystem.Metalogic
