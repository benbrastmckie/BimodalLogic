/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.AuxiliaryAtoms
import FormalSystem.Metalogic.Conservativity.Plus.PlusSoundness
import FormalSystem.PlusLanguage.PlusReversal

/-!
# The extended L⁺ proof system, its ZTime soundness, and the completeness targets

`ExtDerivation fc Ax R φ` is a `Prop`-valued theoremhood closure: the least predicate on `L⁺`
formulas containing every `PlusDerivable fc [] φ` theorem and every member of the axiom set `Ax`,
closed under modus ponens, necessitation, temporal necessitation and time reflection, and closed
in addition under whichever of the three *naming* rules the flag record `R` switches on — the
clock rule of `Metalogic/NamingRules.lean` and the forward and mirror Auxiliary-Atoms rules of
`Metalogic/AuxiliaryAtoms.lean`, each carrying its own freshness side conditions.

Two axiom sets are singled out: `IsLCAxiom`, the limit-closure schema `lcN` of
`PlusLanguage/PlusLCSchema.lean` at every positive arity together with its `reflectTime` mirror,
and `IsLCUAxiom`, the until-form schema `lcU` together with its mirror. Both are `.ZTime`-valid,
so the parametric soundness theorem discharges concretely at either of them.

## The rule-set flags and the `fc` parameter

`ExtDerivation` is parametric in a `FrameClass` because its base and its clock rule genuinely
are: `tm` quotes `PlusDerivable fc []`, whose soundness arm `plus_soundness_validIn` holds at
every class, and `clock_irr_sound` is likewise class-generic. The two Auxiliary-Atoms rules are
**not**: `aa_sound_ztime` and `aa_reflectTime_sound_ztime` are proved at `FrameClass.ZTime` only,
by a cone construction over `intOrder`. So `ExtDerivation fc Ax R` with `R.aaFwd` or `R.aaBwd`
switched on at some `fc` other than `.ZTime` is a syntactically well-formed closure for which no
soundness claim is made here. The hazard is stated rather than hidden: `ext_sound_ztime` fixes
`fc := .ZTime` and admits all three rules, while `ext_sound_validIn` is the class-generic arm and
pays for its generality by requiring `R.aaFwd = false` and `R.aaBwd = false`.

## Nothing in the proof system is modified

`ProofSystem/`'s `PlusDerivationTree` and `PlusAxiom`, and `PlusLanguage/`'s `PlusFormula`, are
untouched by this module: `ExtDerivation` sits strictly on top of `PlusDerivable fc []` as a new
`inductive` in this namespace, adds no axiom constructor to `PlusAxiom`, and adds no connective to
`PlusFormula`.

## Main Definitions

- `RuleSet`, `RuleSet.none`, `RuleSet.all` — the three naming-rule flags, all off, and all on
- `IsLCAxiom`, `IsLCUAxiom` — the two axiom-set predicates, each closed under `reflectTime`

## Main Results

- `ExtDerivation` — the extended theoremhood closure, with its ten constructors
- `isLCAxiom_plusValidZTime`, `isLCUAxiom_plusValidZTime` — each axiom set is `.ZTime`-valid
- `ext_sound_ztime` — **the headline**: `ExtDerivation .ZTime Ax R φ` implies `PlusValidZTime φ`
  whenever `Ax` is `.ZTime`-valid, for *every* rule set
- `ext_sound_validIn` — the class-generic arm, for a rule set with both Auxiliary-Atoms rules off
- `ext_sound_lc_ztime`, `ext_sound_lcU_ztime` — the soundness half of the three targets below,
  outright
- `ExtComplete` — completeness of an extension at `.ZTime`, as a predicate on `(Ax, R)`
- `LCComplete`, `LCRulesComplete`, `LCURulesComplete` — the three completeness targets, **stated
  and deliberately unproved**

## Not formalized

No completeness claim is made or implied anywhere in this module. `LCComplete`,
`LCRulesComplete` and `LCURulesComplete` are `Prop`-valued `def`s with no proof term and no
`sorry`: each names an open target, and none is asserted to hold. Nor is any decidability or
axiomatizability claim made. What *is* proved is soundness, in the two arms above.

## References

* [M. Reynolds, *An Axiomatization of Full Computation Tree Logic*][reynolds2001] — §7, the
  naming rules this closure admits. The L⁺ transposition, the flag record, and the particular
  axiom sets named here are not Reynolds'.
* `FormalSystem/Metalogic/NamingRules.lean` — `Fresh`, `clockAnte`, `clock_irr_sound`
* `FormalSystem/Metalogic/AuxiliaryAtoms.lean` — `aaAnte`, `aa_sound_ztime`,
  `aa_reflectTime_sound_ztime`
* `FormalSystem/Metalogic/Conservativity/Plus/PlusSoundness.lean` — `plus_soundness_ztime`,
  `plus_soundness_validIn`
* `FormalSystem/PlusLanguage/PlusLCSchema.lean` — `lcN`, `lcU`, `bigAnd` and their validity
* `FormalSystem/PlusLanguage/PlusReversal.lean` — `PlusFormula.reflectTime`,
  `PlusFormula.reflect_time_involution`, `plusValidIn_reflectTime`

## Tags

proof system, soundness, naming rules, limit closure, completeness target
-/

namespace FormalSystem.Metalogic.LCExtension

open FormalSystem.Syntax FormalSystem.ProofSystem FormalSystem.PlusLanguage
open FormalSystem.Metalogic.NamingRules FormalSystem.Metalogic.AuxiliaryAtoms
open FormalSystem.Metalogic.Conservativity

/-! ## The rule-set flags -/

/-- Which of the three naming rules an extension admits: the clock rule of
`Metalogic/NamingRules.lean`, and the forward and mirror Auxiliary-Atoms rules of
`Metalogic/AuxiliaryAtoms.lean`.

A flag record rather than three separate inductives, so that one `ExtDerivation` serves every
combination and `ExtComplete` can be stated uniformly as a predicate on `(Ax, R)`. -/
structure RuleSet where
  /-- Admit the clock rule. -/
  clock : Bool
  /-- Admit the forward Auxiliary-Atoms rule. `.ZTime`-only; see the module docstring. -/
  aaFwd : Bool
  /-- Admit the mirror Auxiliary-Atoms rule. `.ZTime`-only; see the module docstring. -/
  aaBwd : Bool

/-- Every naming rule off: the extension is the base system plus the axiom set alone. -/
def RuleSet.none : RuleSet := ⟨false, false, false⟩

/-- All three naming rules on. -/
def RuleSet.all : RuleSet := ⟨true, true, true⟩

/-! ## The two axiom sets -/

/-- The `LC_n` axiom set: every instance of the limit-closure schema `lcN` at positive arity,
together with its `reflectTime` mirror.

The mirror is a separate disjunct rather than derived, because `reflectTime` is not a syntactic
substitution and `lcN n α` is not stable under it; `lcN_reflectTime_plusValidZTime` is the
separate validity fact that pays for the disjunct.

Paper: — (formalization-native; the manuscript states no limit-closure schema) -/
def IsLCAxiom (ψ : PlusFormula) : Prop :=
  ∃ (n : ℕ) (α : ℕ → PlusFormula), 0 < n ∧ (ψ = lcN n α ∨ ψ = (lcN n α).reflectTime)

/-- The `LCU` axiom set: every instance of the until-form limit-closure schema `lcU`, together
with its `reflectTime` mirror.

`lcU` is **not** an instance of `lcN` and `lcN 1` is not `lcU`; see
`PlusLanguage/PlusLCSchema.lean`'s module docstring for the two side by side. The two axiom sets
are therefore genuinely different, which is why `LCRulesComplete` and `LCURulesComplete` are
distinct targets.

Paper: — (formalization-native; the manuscript states no until-form limit-closure schema) -/
def IsLCUAxiom (ψ : PlusFormula) : Prop :=
  ∃ α β : PlusFormula, ψ = lcU α β ∨ ψ = (lcU α β).reflectTime

/-- Every `LC_n` axiom, mirror included, is valid at `FrameClass.ZTime`.

This is what discharges `ext_sound_ztime`'s `hAx` hypothesis concretely at `IsLCAxiom`, rather
than leaving the soundness arm parametric.

Paper: — (formalization-native; the manuscript states no limit-closure schema) -/
theorem isLCAxiom_plusValidZTime {ψ : PlusFormula} (h : IsLCAxiom ψ) : PlusValidZTime ψ := by
  obtain ⟨n, α, hn, h | h⟩ := h
  · exact h ▸ lcN_plusValidZTime n hn α
  · exact h ▸ lcN_reflectTime_plusValidZTime n hn α

/-- Every `LCU` axiom, mirror included, is valid at `FrameClass.ZTime`.

The `.Base` validity of `lcU` is open and unclaimed; only the `.ZTime` fact is used here.

Paper: — (formalization-native; the manuscript states no until-form limit-closure schema) -/
theorem isLCUAxiom_plusValidZTime {ψ : PlusFormula} (h : IsLCUAxiom ψ) : PlusValidZTime ψ := by
  obtain ⟨α, β, h | h⟩ := h
  · exact h ▸ lcU_plusValidZTime α β
  · exact h ▸ lcU_reflectTime_plusValidZTime α β

/-! ## The extended theoremhood closure -/

/-- `ExtDerivation fc Ax R φ` — theoremhood in the extension of the `L⁺` system at `fc`
by the axiom set `Ax` and the naming rules `R` switches on.

The ten constructors: `tm` quotes a `PlusDerivable fc []` theorem; `ax` quotes a member of `Ax`;
`mp`, `nec`, `tnec` and `refl` are modus ponens, necessitation, temporal necessitation and time
reflection; `clock` is the clock rule, gated by `R.clock` and carrying its freshness condition;
`aaFwd` and `aaBwd` are the forward and mirror Auxiliary-Atoms rules, gated by `R.aaFwd` and
`R.aaBwd` and carrying the landed `aaAnte qa m k a p b₀` encoding's full side-condition list.

The Auxiliary-Atoms rules' exhaustiveness and disjointness premises `hexh` and `hdisj` are
**recursive `ExtDerivation` premises, not semantic hypotheses**, so this closure carries no
validity hypothesis anywhere: the soundness induction's own inductive hypotheses supply exactly
the validity `aa_sound_ztime` wants. `aaBwd`'s conclusion is `φ.reflectTime`, matching
`aa_reflectTime_sound_ztime` exactly; the arbitrary-conclusion mirror form is derivable from it by
`PlusFormula.reflect_time_involution` alone, as the acceptance `example` below shows.

Paper: — (formalization-native; the manuscript states no extended proof system) -/
inductive ExtDerivation (fc : FrameClass) (Ax : PlusFormula → Prop) (R : RuleSet) :
    PlusFormula → Prop
  | tm {φ} (d : PlusDerivable fc [] φ) : ExtDerivation fc Ax R φ
  | ax {φ} (h : Ax φ) : ExtDerivation fc Ax R φ
  | mp {φ ψ} (d₁ : ExtDerivation fc Ax R (φ.imp ψ)) (d₂ : ExtDerivation fc Ax R φ) :
      ExtDerivation fc Ax R ψ
  | nec {φ} (d : ExtDerivation fc Ax R φ) : ExtDerivation fc Ax R (PlusFormula.box φ)
  | tnec {φ} (d : ExtDerivation fc Ax R φ) : ExtDerivation fc Ax R φ.allFuture
  | refl {φ} (d : ExtDerivation fc Ax R φ) : ExtDerivation fc Ax R φ.reflectTime
  | clock {q φ} (hR : R.clock = true) (hq : Fresh q φ)
      (d : ExtDerivation fc Ax R ((clockAnte q).imp φ)) : ExtDerivation fc Ax R φ
  | aaFwd {φ} (hR : R.aaFwd = true) (qa : ℕ → Atom) (m k : ℕ) (a : ℕ → PlusFormula)
      (p : ℕ → ℕ → ℕ) (b₀ : ℕ) (hb₀ : b₀ < m)
      (hinj : ∀ j, j < m → ∀ j', j' < m → qa j = qa j' → j = j')
      (hp : ∀ j, j < m → ∀ i, i < k → p j i < m)
      (ha : ∀ i, i < k → (a i).StateLocal)
      (hfresh : ∀ j, j < m → Fresh (qa j) φ)
      (hfreshA : ∀ j, j < m → ∀ i, i < k → Fresh (qa j) (a i))
      (hexh : ExtDerivation fc Ax R (bigAnd k fun i => (a i).neg).neg)
      (hdisj : ∀ i, i < k → ∀ i', i' < k → i ≠ i' →
        ExtDerivation fc Ax R (((a i).and (a i')).neg))
      (d : ExtDerivation fc Ax R ((aaAnte qa m k a p b₀).imp φ)) :
      ExtDerivation fc Ax R φ
  | aaBwd {φ} (hR : R.aaBwd = true) (qa : ℕ → Atom) (m k : ℕ) (a : ℕ → PlusFormula)
      (p : ℕ → ℕ → ℕ) (b₀ : ℕ) (hb₀ : b₀ < m)
      (hinj : ∀ j, j < m → ∀ j', j' < m → qa j = qa j' → j = j')
      (hp : ∀ j, j < m → ∀ i, i < k → p j i < m)
      (ha : ∀ i, i < k → (a i).StateLocal)
      (hfresh : ∀ j, j < m → Fresh (qa j) φ)
      (hfreshA : ∀ j, j < m → ∀ i, i < k → Fresh (qa j) (a i))
      (hexh : ExtDerivation fc Ax R (bigAnd k fun i => (a i).neg).neg)
      (hdisj : ∀ i, i < k → ∀ i', i' < k → i ≠ i' →
        ExtDerivation fc Ax R (((a i).and (a i')).neg))
      (d : ExtDerivation fc Ax R (((aaAnte qa m k a p b₀).imp φ).reflectTime)) :
      ExtDerivation fc Ax R φ.reflectTime

/-! ## Soundness -/

/-- **The headline**: the extension of `L⁺` at `FrameClass.ZTime` by any `.ZTime`-valid axiom set
and *any* rule set is sound.

All three naming rules are admitted, because `clock_irr_sound`, `aa_sound_ztime` and
`aa_reflectTime_sound_ztime` are all available at `.ZTime`. The `nec` and `tnec` cases are inline
two-line arguments rather than named lemmas (`PlusTruth.box_iff` is `Iff.rfl`); the two
Auxiliary-Atoms cases hand their recursive `hexh`/`hdisj` inductive hypotheses straight to the
rule's soundness theorem, which is what those premises were shaped for.

Paper: — (formalization-native; the manuscript states no extended proof system) -/
theorem ext_sound_ztime {Ax : PlusFormula → Prop} {R : RuleSet}
    (hAx : ∀ ψ, Ax ψ → PlusValidZTime ψ) {φ : PlusFormula}
    (d : ExtDerivation FrameClass.ZTime Ax R φ) : PlusValidZTime φ := by
  induction d with
  | tm h => exact plus_soundness_ztime h
  | ax h => exact hAx _ h
  | mp _ _ ih1 ih2 => exact fun F hF M τ x => ih1 F hF M τ x (ih2 F hF M τ x)
  | nec _ ih => exact fun F hF M τ x σ => ih F hF M σ x
  | tnec _ ih =>
    intro F hF M τ x
    rw [PlusTruth.allFuture_iff]
    intro s _
    exact ih F hF M τ s
  | refl _ ih => exact plusValidIn_reflectTime ih
  | clock hR hq _ ih => exact clock_irr_sound _ _ _ hq ih
  | aaFwd hR qa m k a p b₀ hb₀ hinj hp ha hfresh hfreshA _ _ _ ihexh ihdisj ihd =>
    exact aa_sound_ztime qa m k a p b₀ _ hb₀ hinj hp ha ihexh ihdisj hfresh hfreshA ihd
  | aaBwd hR qa m k a p b₀ hb₀ hinj hp ha hfresh hfreshA _ _ _ ihexh ihdisj ihd =>
    exact aa_reflectTime_sound_ztime qa m k a p b₀ _ hb₀ hinj hp ha ihexh ihdisj hfresh hfreshA
      ihd

/-- The class-generic soundness arm: at an arbitrary `FrameClass`, the extension by a valid axiom
set is sound provided both Auxiliary-Atoms rules are **off**.

This is what converts `ExtDerivation`'s `fc` parameter from a latent trap into a stated fact. The
`tm` base goes through `plus_soundness_validIn` and the `clock` case through the same
class-generic `clock_irr_sound` as above; the two `aa` cases are discharged by contradiction
against `hFwd`/`hBwd`, which is precisely where the restriction is paid for.

Paper: — (formalization-native; the manuscript states no extended proof system) -/
theorem ext_sound_validIn {fc : FrameClass} {Ax : PlusFormula → Prop} {R : RuleSet}
    (hFwd : R.aaFwd = false) (hBwd : R.aaBwd = false)
    (hAx : ∀ ψ, Ax ψ → PlusValidIn fc ψ) {φ : PlusFormula}
    (d : ExtDerivation fc Ax R φ) : PlusValidIn fc φ := by
  induction d with
  | tm h => exact plus_soundness_validIn h
  | ax h => exact hAx _ h
  | mp _ _ ih1 ih2 => exact fun F hFr M τ x => ih1 F hFr M τ x (ih2 F hFr M τ x)
  | nec _ ih => exact fun F hFr M τ x σ => ih F hFr M σ x
  | tnec _ ih =>
    intro F hFr M τ x
    rw [PlusTruth.allFuture_iff]
    intro s _
    exact ih F hFr M τ s
  | refl _ ih => exact plusValidIn_reflectTime ih
  | clock hR hq _ ih => exact clock_irr_sound _ _ _ hq ih
  | aaFwd hR => exact absurd hR (by rw [hFwd]; simp)
  | aaBwd hR => exact absurd hR (by rw [hBwd]; simp)

/-- Soundness of the extension by the `LC_n` axiom set at `.ZTime`, for every rule set.

Half of each of `LCComplete` and `LCRulesComplete` is therefore settled outright; what those two
targets add is the converse.

Paper: — (formalization-native; the manuscript states no extended proof system) -/
theorem ext_sound_lc_ztime {R : RuleSet} {φ : PlusFormula}
    (d : ExtDerivation FrameClass.ZTime IsLCAxiom R φ) : PlusValidZTime φ :=
  ext_sound_ztime (fun _ h => isLCAxiom_plusValidZTime h) d

/-- Soundness of the extension by the `LCU` axiom set at `.ZTime`, for every rule set.

Half of `LCURulesComplete` is therefore settled outright; what that target adds is the converse.

Paper: — (formalization-native; the manuscript states no extended proof system) -/
theorem ext_sound_lcU_ztime {R : RuleSet} {φ : PlusFormula}
    (d : ExtDerivation FrameClass.ZTime IsLCUAxiom R φ) : PlusValidZTime φ :=
  ext_sound_ztime (fun _ h => isLCUAxiom_plusValidZTime h) d

/-! ## The completeness targets

Each of the three `def`s below is a **statement**, with no proof term anywhere in this tree and
no `sorry`. None is asserted to hold.
-/

/-- Completeness of the extension by `Ax` and `R` at `FrameClass.ZTime`: every `.ZTime`-valid
`L⁺` formula is a theorem of the extension.

A predicate on `(Ax, R)` rather than three unrelated statements, so that the three targets below
differ only in their arguments and the soundness converse is visibly the same shape in each case.

Paper: — (formalization-native; the manuscript states no extended proof system) -/
def ExtComplete (Ax : PlusFormula → Prop) (R : RuleSet) : Prop :=
  ∀ φ : PlusFormula, PlusValidZTime φ → ExtDerivation FrameClass.ZTime Ax R φ

/-- **Target, stated and unproved**: `TM⁺` plus the `LC_n` axiom set, with no naming rule, is
complete for `.ZTime` validity.

This is the weakest of the three — no naming rule is available — and is correspondingly the
least likely to hold. Nothing in this tree proves it or any weakening of it.

Paper: — (formalization-native; the manuscript states no limit-closure schema) -/
def LCComplete : Prop := ExtComplete IsLCAxiom RuleSet.none

/-- **Target, stated and unproved**: `TM⁺` plus the `LC_n` axiom set plus all three naming rules
is complete for `.ZTime` validity.

Nothing in this tree proves it or any weakening of it.

Paper: — (formalization-native; the manuscript states no limit-closure schema) -/
def LCRulesComplete : Prop := ExtComplete IsLCAxiom RuleSet.all

/-- **Target, stated and unproved**: `TM⁺` plus the `LCU` axiom set plus all three naming rules
is complete for `.ZTime` validity.

The until-form variant of `LCRulesComplete`, distinct from it because `lcU` is not an instance of
`lcN`. Nothing in this tree proves it or any weakening of it.

Paper: — (formalization-native; the manuscript states no until-form limit-closure schema) -/
def LCURulesComplete : Prop := ExtComplete IsLCUAxiom RuleSet.all

/-! ## Acceptance

The `example`s below are acceptance checks, not library API: the mirror rule's arbitrary-conclusion
shape, and non-vacuity of each axiom predicate.
-/

/-- Acceptance: the arbitrary-conclusion mirror shape is derivable from `aaBwd`'s
`φ.reflectTime` form by `PlusFormula.reflect_time_involution` alone, so stating the constructor at
`φ.reflectTime` — which is what makes its soundness case glue-free — costs no generality. -/
example {Ax : PlusFormula → Prop} {R : RuleSet} {ψ : PlusFormula} (hR : R.aaBwd = true)
    (qa : ℕ → Atom) (m k : ℕ) (a : ℕ → PlusFormula) (p : ℕ → ℕ → ℕ) (b₀ : ℕ) (hb₀ : b₀ < m)
    (hinj : ∀ j, j < m → ∀ j', j' < m → qa j = qa j' → j = j')
    (hp : ∀ j, j < m → ∀ i, i < k → p j i < m)
    (ha : ∀ i, i < k → (a i).StateLocal)
    (hfresh : ∀ j, j < m → Fresh (qa j) ψ.reflectTime)
    (hfreshA : ∀ j, j < m → ∀ i, i < k → Fresh (qa j) (a i))
    (hexh : ExtDerivation FrameClass.ZTime Ax R (bigAnd k fun i => (a i).neg).neg)
    (hdisj : ∀ i, i < k → ∀ i', i' < k → i ≠ i' →
      ExtDerivation FrameClass.ZTime Ax R (((a i).and (a i')).neg))
    (d : ExtDerivation FrameClass.ZTime Ax R ((aaAnte qa m k a p b₀).reflectTime.imp ψ)) :
    ExtDerivation FrameClass.ZTime Ax R ψ := by
  have h := ExtDerivation.aaBwd (φ := ψ.reflectTime) hR qa m k a p b₀ hb₀ hinj hp ha hfresh
    hfreshA hexh hdisj (by
      change ExtDerivation FrameClass.ZTime Ax R
        ((aaAnte qa m k a p b₀).reflectTime.imp ψ.reflectTime.reflectTime)
      rwa [PlusFormula.reflect_time_involution])
  rwa [PlusFormula.reflect_time_involution] at h

/-- Non-vacuity: `IsLCAxiom` is inhabited. -/
example : ∃ ψ, IsLCAxiom ψ := ⟨lcN 1 (fun _ => PlusFormula.bot), 1, _, by omega, Or.inl rfl⟩

/-- Non-vacuity: `IsLCUAxiom` is inhabited. -/
example : ∃ ψ, IsLCUAxiom ψ :=
  ⟨lcU PlusFormula.bot PlusFormula.bot, PlusFormula.bot, PlusFormula.bot, Or.inl rfl⟩

end FormalSystem.Metalogic.LCExtension
