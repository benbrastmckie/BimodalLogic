/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.BaseLanguage.Axioms
import FormalSystem.BaseLanguage.Translation
import FormalSystem.Theorems.Combinators
import FormalSystem.Theorems.Propositional.Core
import FormalSystem.Theorems.TemporalDerived
import FormalSystem.Theorems.DedekindDerived
import FormalSystem.Theorems.DiscreteUnfolding
import FormalSystem.Theorems.GeneralizedNecessitation
import FormalSystem.Metalogic.Core.DeductionTheorem

/-!
# The axiom-discharge table: a BL⁺ derivation of `tr` of every BL axiom

`dischargeAxiom` is the lookup table that makes the `axiom` case of
`FormalSystem.Metalogic.Conservativity.translate` a one-line match. For each constructor of
`BaseLanguage.Axiom` it produces a `FormalSystem.ProofSystem` derivation of that axiom's
translation, at the frame class the BL-side side condition already supplies.

## Which rows are exact and which need the `F`/`P` bridge

Seven rows are *exact*: `tr` of the BL axiom is syntactically the BL⁺ asset, and the discharge
is a single `DerivationTree.axiom` or a single named theorem.

| Row | BL⁺ asset | Exact? |
|---|---|---|
| CPL (4) | `Axiom.prop_k`, `prop_s`, `ex_falso`, `peirce` | yes |
| MK | `Axiom.modal_k_dist` | yes |
| MT | `Axiom.modal_t` | yes |
| M5 | `Axiom.modal_5_collapse` | yes |
| MF | `Axiom.modal_future` | yes |
| TK | `Theorems.TemporalDerived.gDistribution` | yes |
| T4 | `Theorems.TemporalDerived.gTransitivity` | yes |
| DN | `Axiom.density` | yes |
| TB | `Axiom.serial_future` + MP | **no** — `F`-bridge |
| TA | `Axiom.connect_future` | **no** — `P`-bridge under `G` |
| TL | `Axiom.temp_linearity` | **no** — `F`-bridge *and* a disjunct reshuffle |
| DF | `Theorems.DiscreteUnfolding.dfSchema` | **no** — `F`-bridge on both sides |
| CO | `Theorems.DedekindDerived.co_derived` | **no** — `F`-bridge under `△` |

The research report predicted "exact syntactic match" for TA and TB. That is **refuted**, and
structurally so rather than by accident: BL's `F`/`P` are *derived* (`Fφ = ¬G¬φ`), so `tr (Fφ)`
is `¬G¬(tr φ)`, whereas `Formula.someFuture` is a top-level `untl` — and by
`BaseLanguage.tr_ne_untl` nothing in the range of `tr` is a top-level `untl`. No choice of
BL-side abbreviation could have closed that gap. See `BaseLanguage/Translation.lean`'s
`tr_someFuture_ne`.

What *does* close it is the derivable equivalence `¬G¬ψ ↔ Fψ` (`notGNot_imp_F` / `F_imp_notGNot`
and their past duals), plus enough monotone congruence to apply it under `∧`, `→`, `G`, `H`, `F`
and `△`. That machinery is the first section below; every non-exact row is then three or four
lines.

## Frame-class side conditions

Each extension row consumes the BL-side `h_fc` directly rather than re-deriving it: for `df` it
is exactly `Discrete ≤ fc`, which is what `DerivationTree.lift` wants for `dfSchema`; for `dn`
it is `Dense ≤ fc`, which is what `Axiom.density`'s own side condition wants; for `co` it is
`Dedekind ≤ fc`, which is `co_derived`'s hypothesis. Base rows use `FrameClass.base_le fc`.

## Module Invariant

Nothing here imports `FormalSystem.Semantics`. The `Theorems.*` and `Metalogic.Core.*` modules
pulled in above are Semantics-free transitively, so the invariant of
`FormalSystem/BaseLanguage.lean` survives this file's larger import list.
-/

namespace FormalSystem.BaseLanguage

open FormalSystem.Syntax
open FormalSystem.ProofSystem
open FormalSystem.Metalogic.Core
open FormalSystem.Theorems.Combinators
open FormalSystem.Theorems.Propositional
open FormalSystem.Theorems.TemporalDerived

noncomputable section

/-! ## Monotone congruence

Small closures of the existing distribution/monotonicity lemmas into *rule* form — from
`⊢ A → B` conclude `⊢ □A → □B`, `⊢ GA → GB`, and so on. Nothing here is a new derivation: each
is a `temporal_necessitation`/`pastNecessitation` followed by the matching distribution axiom
from `Theorems/TemporalDerived.lean`. -/

/-- From `⊢ A → B` conclude `⊢ GA → GB`. -/
private def gRule {fc : FrameClass} {A B : Formula} (h : ⊢[fc] A.imp B) :
    ⊢[fc] A.allFuture.imp B.allFuture :=
  mp (DerivationTree.temporal_necessitation _ h) (gDistribution A B)

/-- From `⊢ A → B` conclude `⊢ HA → HB`. -/
private def hRule {fc : FrameClass} {A B : Formula} (h : ⊢[fc] A.imp B) :
    ⊢[fc] A.allPast.imp B.allPast :=
  mp (FormalSystem.Theorems.pastNecessitation _ h) (hDistribution A B)

/-- From `⊢ A → B` conclude `⊢ FA → FB`. -/
private def fRule {fc : FrameClass} {A B : Formula} (h : ⊢[fc] A.imp B) :
    ⊢[fc] A.someFuture.imp B.someFuture :=
  mp (DerivationTree.temporal_necessitation _ h) (fMono A B)

/-- From `⊢ A → B` conclude `⊢ PA → PB`. -/
private def pRule {fc : FrameClass} {A B : Formula} (h : ⊢[fc] A.imp B) :
    ⊢[fc] A.somePast.imp B.somePast :=
  mp (FormalSystem.Theorems.pastNecessitation _ h) (pMono A B)

/-- Conjunction is monotone in both arguments. -/
private def andMono {fc : FrameClass} {A A' B B' : Formula}
    (hA : ⊢[fc] A.imp A') (hB : ⊢[fc] B.imp B') : ⊢[fc] (A.and B).imp (A'.and B') := by
  refine deductionTheorem [] (A.and B) (A'.and B') ?_
  have h := DerivationTree.assumption (fc := fc) [A.and B] (A.and B) (by simp)
  exact andIntro (ctxMp (wk _ _ hA) (andFst h)) (ctxMp (wk _ _ hB) (andSnd h))

/-- Implication is antitone in its antecedent and monotone in its consequent. -/
private def impMono {fc : FrameClass} {A A' B B' : Formula}
    (hA : ⊢[fc] A'.imp A) (hB : ⊢[fc] B.imp B') : ⊢[fc] (A.imp B).imp (A'.imp B') := by
  refine deductionTheorem [] (A.imp B) (A'.imp B') ?_
  refine deductionTheorem [A.imp B] A' B' ?_
  have h1 : [A', A.imp B] ⊢[fc] A.imp B := DerivationTree.assumption _ _ (by simp)
  have h2 : [A', A.imp B] ⊢[fc] A' := DerivationTree.assumption _ _ (by simp)
  exact ctxMp (wk _ _ hB) (ctxMp h1 (ctxMp (wk _ _ hA) h2))

/-- `△` is monotone. `Formula.always X = HX ∧ (X ∧ GX)`, so this is `hRule`, `id` and `gRule`
combined through `andMono`. Needed by the CO row. -/
private def alwaysMono {fc : FrameClass} {A B : Formula} (h : ⊢[fc] A.imp B) :
    ⊢[fc] (Formula.always A).imp (Formula.always B) :=
  andMono (hRule h) (andMono h (gRule h))

/-! ## The `F`/`P` bridge

`tr` sends BL's `Fψ = ¬G¬ψ` to `¬G¬(tr ψ)`, which unfolds on the BL⁺ side to `¬¬F(¬¬·)` and is
therefore *not* `Formula.someFuture`. The four lemmas below are the derivable equivalence that
repairs this, once, for every row that needs it. -/

/-- `⊢ ¬G¬ψ → Fψ`. Unfolding `Formula.allFuture`, the antecedent is `¬¬F(¬¬ψ)`; strip the outer
double negation classically, then push `¬¬ψ → ψ` under `F` by `fRule`. -/
def notGNot_imp_F {fc : FrameClass} (ψ : Formula) :
    ⊢[fc] ((Formula.allFuture ψ.neg).neg).imp ψ.someFuture :=
  impTrans (doubleNegation (Formula.someFuture ψ.neg.neg)) (fRule (doubleNegation ψ))

/-- `⊢ Fψ → ¬G¬ψ`, the converse of `notGNot_imp_F`. -/
def F_imp_notGNot {fc : FrameClass} (ψ : Formula) :
    ⊢[fc] ψ.someFuture.imp ((Formula.allFuture ψ.neg).neg) :=
  impTrans (fRule (notNotIntro ψ)) (notNotIntro (Formula.someFuture ψ.neg.neg))

/-- `⊢ ¬H¬ψ → Pψ`, the past dual of `notGNot_imp_F`. -/
def notHNot_imp_P {fc : FrameClass} (ψ : Formula) :
    ⊢[fc] ((Formula.allPast ψ.neg).neg).imp ψ.somePast :=
  impTrans (doubleNegation (Formula.somePast ψ.neg.neg)) (pRule (doubleNegation ψ))

/-- `⊢ Pψ → ¬H¬ψ`, the converse of `notHNot_imp_P`. -/
def P_imp_notHNot {fc : FrameClass} (ψ : Formula) :
    ⊢[fc] ψ.somePast.imp ((Formula.allPast ψ.neg).neg) :=
  impTrans (pRule (notNotIntro ψ)) (notNotIntro (Formula.somePast ψ.neg.neg))

/-! ## Base row

One lemma per Base-class BL axiom, each of shape `⊢[fc] tr (<the BL axiom formula>)`. Seven are
a single application; TB, TA and TL carry the bridge. -/

/-- **CPL/K**. Exact. -/
def discharge_prop_k {fc : FrameClass} (a b c : BLFormula) :
    ⊢[fc] tr ((a.imp (b.imp c)).imp ((a.imp b).imp (a.imp c))) :=
  DerivationTree.axiom [] _ (ProofSystem.Axiom.prop_k (tr a) (tr b) (tr c))
    (FrameClass.base_le fc)

/-- **CPL/S**. Exact. -/
def discharge_prop_s {fc : FrameClass} (a b : BLFormula) :
    ⊢[fc] tr (a.imp (b.imp a)) :=
  DerivationTree.axiom [] _ (ProofSystem.Axiom.prop_s (tr a) (tr b)) (FrameClass.base_le fc)

/-- **CPL/EFQ**. Exact. -/
def discharge_ex_falso {fc : FrameClass} (a : BLFormula) :
    ⊢[fc] tr (BLFormula.bot.imp a) :=
  DerivationTree.axiom [] _ (ProofSystem.Axiom.ex_falso (tr a)) (FrameClass.base_le fc)

/-- **CPL/Peirce**. Exact. -/
def discharge_peirce {fc : FrameClass} (a b : BLFormula) :
    ⊢[fc] tr (((a.imp b).imp a).imp a) :=
  DerivationTree.axiom [] _ (ProofSystem.Axiom.peirce (tr a) (tr b)) (FrameClass.base_le fc)

/-- **MK**. Exact: `Axiom.modal_k_dist`. -/
def discharge_modal_k {fc : FrameClass} (a b : BLFormula) :
    ⊢[fc] tr ((a.imp b).box.imp (a.box.imp b.box)) :=
  DerivationTree.axiom [] _ (ProofSystem.Axiom.modal_k_dist (tr a) (tr b))
    (FrameClass.base_le fc)

/-- **MT**. Exact: `Axiom.modal_t`. -/
def discharge_modal_t {fc : FrameClass} (a : BLFormula) :
    ⊢[fc] tr (a.box.imp a) :=
  DerivationTree.axiom [] _ (ProofSystem.Axiom.modal_t (tr a)) (FrameClass.base_le fc)

/-- **M5**. Exact: `Axiom.modal_5_collapse`. `tr` commutes with `◇` because BL's `◇` and BL⁺'s
are the same abbreviation `¬□¬`. -/
def discharge_modal_5 {fc : FrameClass} (a : BLFormula) :
    ⊢[fc] tr (a.box.diamond.imp a.box) :=
  DerivationTree.axiom [] _ (ProofSystem.Axiom.modal_5_collapse (tr a)) (FrameClass.base_le fc)

/-- **MF**. Exact: `Axiom.modal_future`, the one genuine "exact syntactic match" the research
report predicted that survives contact with the translation. -/
def discharge_modal_future {fc : FrameClass} (a : BLFormula) :
    ⊢[fc] tr (a.box.imp a.allFuture.box) :=
  DerivationTree.axiom [] _ (ProofSystem.Axiom.modal_future (tr a)) (FrameClass.base_le fc)

/-- **TK**. Exact: `gDistribution`, a sorry-free derived theorem. -/
def discharge_temp_k {fc : FrameClass} (a b : BLFormula) :
    ⊢[fc] tr ((a.imp b).allFuture.imp (a.allFuture.imp b.allFuture)) :=
  gDistribution (tr a) (tr b)

/-- **T4**. Exact: `gTransitivity`, a sorry-free derived theorem. -/
def discharge_temp_4 {fc : FrameClass} (a : BLFormula) :
    ⊢[fc] tr (a.allFuture.imp a.allFuture.allFuture) :=
  gTransitivity (tr a)

/-- **TB** (`F⊤`). `Axiom.serial_future` gives `⊤ → F⊤`; modus ponens on `⊤` gives `F⊤`; the
`F`-bridge converts that to the `¬G¬⊤` shape `tr` produces. -/
def discharge_temp_serial {fc : FrameClass} :
    ⊢[fc] tr BLFormula.top.someFuture :=
  let serial : ⊢[fc] Formula.top.someFuture :=
    mp topThm
      (DerivationTree.axiom [] _ ProofSystem.Axiom.serial_future (FrameClass.base_le fc))
  mp serial (F_imp_notGNot Formula.top)

/-- **TA** (`φ → G P φ`). `Axiom.connect_future` gives `A → G(P A)`; the `P`-bridge, pushed
under `G` by `gRule`, converts `P A` to the `¬H¬A` shape `tr` produces. -/
def discharge_temp_connect {fc : FrameClass} (a : BLFormula) :
    ⊢[fc] tr (a.imp a.somePast.allFuture) :=
  impTrans
    (DerivationTree.axiom [] _ (ProofSystem.Axiom.connect_future (tr a)) (FrameClass.base_le fc))
    (gRule (P_imp_notHNot (tr a)))

/--
**TL**, the one Base row with real friction.

The paper's disjunct order is `F(Fφ ∧ ψ) ∨ F(φ ∧ ψ) ∨ F(φ ∧ Fψ)`; this repository's
`Axiom.temp_linearity` gives `F(φ ∧ ψ) ∨ (F(φ ∧ Fψ) ∨ F(Fφ ∧ ψ))` — the same three disjuncts,
differently ordered and associated. On top of that every `F` has to cross the bridge.

Route: bridge the antecedent down to `Fφ ∧ Fψ`, apply the axiom, then `orElim` the three
disjuncts and re-introduce each into its paper position, bridging (and, in two cases, pushing
the bridge under `F` with `fRule`) on the way.
-/
def discharge_temp_linearity {fc : FrameClass} (a b : BLFormula) :
    ⊢[fc] tr ((a.someFuture.and b.someFuture).imp
      (((a.someFuture.and b).someFuture).or
        (((a.and b).someFuture).or ((a.and b.someFuture).someFuture)))) := by
  set A := tr a with hA
  set B := tr b with hB
  -- `nf X` is the shape `tr` gives BL's `F X`.
  set nfA := (Formula.allFuture A.neg).neg with hnfA
  set nfB := (Formula.allFuture B.neg).neg with hnfB
  set T1 := (Formula.allFuture (Formula.and nfA B).neg).neg with hT1
  set T2 := (Formula.allFuture (Formula.and A B).neg).neg with hT2
  set T3 := (Formula.allFuture (Formula.and A nfB).neg).neg with hT3
  set C := T1.or (T2.or T3) with hC
  set ant := nfA.and nfB with hant
  set Γ : Syntax.Context := [ant] with hΓ
  refine deductionTheorem [] ant C ?_
  have h0 : Γ ⊢[fc] ant := DerivationTree.assumption _ _ (by simp [hΓ])
  have hFA : Γ ⊢[fc] A.someFuture := ctxMp (wk _ _ (notGNot_imp_F A)) (andFst h0)
  have hFB : Γ ⊢[fc] B.someFuture := ctxMp (wk _ _ (notGNot_imp_F B)) (andSnd h0)
  have hLin : Γ ⊢[fc]
      ((Formula.and A B).someFuture).or
        (((Formula.and A B.someFuture).someFuture).or
          ((Formula.and A.someFuture B).someFuture)) :=
    ctxMp (DerivationTree.axiom _ _ (ProofSystem.Axiom.temp_linearity A B)
      (FrameClass.base_le fc)) (andIntro hFA hFB)
  refine orElim Γ ((Formula.and A B).someFuture)
    (((Formula.and A B.someFuture).someFuture).or ((Formula.and A.someFuture B).someFuture))
    C hLin ?_ ?_
  · -- `F(A ∧ B)` is the paper's *middle* disjunct.
    refine deductionTheorem Γ ((Formula.and A B).someFuture) C ?_
    have a1 : ((Formula.and A B).someFuture :: Γ) ⊢[fc] T2 :=
      ctxMp (wk _ _ (F_imp_notGNot (Formula.and A B)))
        (DerivationTree.assumption _ _ (by simp))
    exact orIntroR _ T1 (T2.or T3) (orIntroL _ T2 T3 a1)
  · refine deductionTheorem Γ
      (((Formula.and A B.someFuture).someFuture).or ((Formula.and A.someFuture B).someFuture))
      C ?_
    refine orElim _ ((Formula.and A B.someFuture).someFuture)
      ((Formula.and A.someFuture B).someFuture) C
      (DerivationTree.assumption _ _ (by simp)) ?_ ?_
    · -- `F(A ∧ F B)` is the paper's *last* disjunct, after bridging the inner `F B`.
      refine deductionTheorem _ ((Formula.and A B.someFuture).someFuture) C ?_
      have a1 := DerivationTree.assumption (fc := fc)
        ((Formula.and A B.someFuture).someFuture ::
          (((Formula.and A B.someFuture).someFuture).or
            ((Formula.and A.someFuture B).someFuture)) :: Γ)
        ((Formula.and A B.someFuture).someFuture) (by simp)
      have a2 := ctxMp
        (wk _ _ (fRule (andMono (identity A) (F_imp_notGNot B)))) a1
      have a3 := ctxMp (wk _ _ (F_imp_notGNot (Formula.and A nfB))) a2
      exact orIntroR _ T1 (T2.or T3) (orIntroR _ T2 T3 a3)
    · -- `F(F A ∧ B)` is the paper's *first* disjunct, after bridging the inner `F A`.
      refine deductionTheorem _ ((Formula.and A.someFuture B).someFuture) C ?_
      have a1 := DerivationTree.assumption (fc := fc)
        ((Formula.and A.someFuture B).someFuture ::
          (((Formula.and A B.someFuture).someFuture).or
            ((Formula.and A.someFuture B).someFuture)) :: Γ)
        ((Formula.and A.someFuture B).someFuture) (by simp)
      have a2 := ctxMp
        (wk _ _ (fRule (andMono (F_imp_notGNot A) (identity B)))) a1
      have a3 := ctxMp (wk _ _ (F_imp_notGNot (Formula.and nfA B))) a2
      exact orIntroL _ T1 (T2.or T3) a3

/-! ## Extension rows

DN, CO and DF, each at its own frame class, each consuming the BL-side `h_fc` unchanged. -/

/-- **DN** at `Dense`. Exact: `Axiom.density` is literally the same formula, and the BL-side
side condition `Dense ≤ fc` is exactly the one `Axiom.density` needs. -/
def discharge_dn {fc : FrameClass} (h_fc : FrameClass.Dense ≤ fc) (a : BLFormula) :
    ⊢[fc] tr (a.allFuture.allFuture.imp a.allFuture) :=
  DerivationTree.axiom [] _ (ProofSystem.Axiom.density (tr a)) h_fc

/-- **CO** at `Dedekind`. `Theorems.DedekindDerived.co_derived` proves `Formula.co A`; `tr` of
BL's CO differs from it only in the inner `F(HA)`, which the bridge repairs — pushed under `→`
by `impMono` and then under `△` by `alwaysMono`.

Because this repository's `Dedekind` admits the dense axioms, the row lands at the paper's
**TM_dc**, not TM_c; see `Metalogic/Conservativity.lean`'s `cec_backward`. -/
def discharge_co {fc : FrameClass} (h_fc : FrameClass.Dedekind ≤ fc) (a : BLFormula) :
    ⊢[fc] tr ((a.allPast.imp a.allPast.someFuture).always.imp (a.allPast.imp a.allFuture)) :=
  impTrans
    (alwaysMono (impMono (identity (tr a).allPast) (notGNot_imp_F (tr a).allPast)))
    (FormalSystem.Theorems.DedekindDerived.co_derived h_fc (tr a))

/-- **DF** at `Discrete`. `Theorems.DiscreteUnfolding.dfSchema` is the Route-A syntactic
derivation; it is stated at `FrameClass.Discrete` and lifted here by the BL-side side condition.
Both the antecedent's `F⊤` and the consequent's `F(Hφ)` cross the bridge. -/
def discharge_df {fc : FrameClass} (h_fc : FrameClass.Discrete ≤ fc) (a : BLFormula) :
    ⊢[fc] tr (((a.allPast.and a).and BLFormula.top.someFuture).imp a.allPast.someFuture) :=
  let core : ⊢[fc]
      (((tr a).allPast.and (tr a)).and Formula.top.someFuture).imp
        ((tr a).allPast.someFuture) :=
    DerivationTree.lift h_fc (FormalSystem.Theorems.DiscreteUnfolding.dfSchema (tr a))
  impTrans
    (impTrans
      (andMono (identity ((tr a).allPast.and (tr a))) (notGNot_imp_F Formula.top))
      core)
    (F_imp_notGNot (tr a).allPast)

/-! ## The table -/

/--
For every BL axiom instance, a BL⁺ derivation of its translation at the same frame class.

This is the whole content of the `axiom` case of
`FormalSystem.Metalogic.Conservativity.translate`. The side condition `h_fc` is threaded
through unchanged: on the three extension rows it is already exactly the hypothesis the BL⁺
asset requires, and on the Base rows it is discarded in favour of `FrameClass.base_le`.
-/
def dischargeAxiom {fc : FrameClass} {φ : BLFormula} (h : Axiom φ)
    (h_fc : h.minFrameClass ≤ fc) : ⊢[fc] tr φ := by
  cases h with
  | prop_k a b c => exact discharge_prop_k a b c
  | prop_s a b => exact discharge_prop_s a b
  | ex_falso a => exact discharge_ex_falso a
  | peirce a b => exact discharge_peirce a b
  | modal_k a b => exact discharge_modal_k a b
  | modal_t a => exact discharge_modal_t a
  | modal_5 a => exact discharge_modal_5 a
  | modal_future a => exact discharge_modal_future a
  | temp_k a b => exact discharge_temp_k a b
  | temp_4 a => exact discharge_temp_4 a
  | temp_serial => exact discharge_temp_serial
  | temp_connect a => exact discharge_temp_connect a
  | temp_linearity a b => exact discharge_temp_linearity a b
  | df a => exact discharge_df h_fc a
  | dn a => exact discharge_dn h_fc a
  | co a => exact discharge_co h_fc a

end -- noncomputable section

end FormalSystem.BaseLanguage
