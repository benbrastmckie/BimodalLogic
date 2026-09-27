/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.WitnessFamily.Predicates
import FormalSystem.Metalogic.Decidability.WitnessFamily.Std

/-!
# Agreement: Labels Are Truth in the Presented Model

**T1**, the theorem that makes a witness family a certificate: if a family satisfies local
coherence, fulfilment and box faithfulness, then truth in the model it presents agrees with label
membership, at every position and every formula of the target closure.

## Why the induction is stated at `ShiftTruth`, generalised over the carrier point

`ShiftSet.ShiftTruth`'s `box` clause quantifies over the whole carrier, so an induction stated at
a fixed lasso would have no induction hypothesis to apply in that case. Generalising over
`(w : W.std.Carrier)` makes the `box` case three lines: `sh_surj` turns "true at every shifted
point" into "true at every point", and `BoxFaithful` turns that into the box guess. The form the
consumer wants — `TruthAt` at the history of `(i, 0)` — is then the instance at that point,
composed with `ShiftSet.forward_repr`.

Composing with `Iff.trans` rather than rewriting by `forward_repr` is deliberate: the motive does
not match syntactically, because `std` is not reducible and the carrier ascription does not
unfold.

## The two inner inductions

`untl_mem_of_witness` and `snce_mem_of_witness` are inductions on the ℤ-distance between the
position and its witness, converting a semantic eventuality witness into label membership by
repeated application of the one-step unfolding clause. They are the label-level counterparts of
`BiLasso/Unfold.lean`'s `truth_untl_succ` / `truth_snce_pred`, and the same pair appears in
`BiLasso/TruthLemma.lean`'s `truth_along_annot` — the single-lasso, oracle-relative version of
this theorem.

## `@LT.lt ℤ _` re-ascription

`omega` cannot see through `↑intOrder`, even though it is `ℤ` by `rfl`. Every temporal
inequality that reaches `omega` is therefore re-ascribed at `ℤ` first. The idiom is the one
`BiLasso/TruthLemma.lean` and `BiLasso/Unfold.lean` already use.

## Main Results

- `WitnessFamily.shiftTruth_iff_mem` — **T1**, in shift-set form
- `WitnessFamily.truth_iff_mem` — **T1**, in `TruthAt` form
- `WitnessFamily.not_consequence_ztime` / `not_consequence_base` — **T1'**
- `WitnessFamily.joint_countermodel` — **T1'**, the joint form a model checker reports
- `WitnessFamily.Refutes` — the joint existence statement, named once
- `WitnessFamily.refutes_of_certifies` — the composition an accepting checker branch applies

## Why `Refutes` is named, and what the checker does with it

`joint_countermodel`'s conclusion is an eight-fold existential. A certificate checker whose
accepting branch is to *inhabit* that statement rather than report a verdict about it needs the
statement as a single name it can write in a return type, and needs it with explicit `Γ Del`
binders, because it applies it at a decoded certificate's own premise and conclusion lists rather
than at section variables. `Refutes` is that name; it restates `joint_countermodel`'s conclusion
verbatim and adds nothing.

`refutes_of_certifies` is the composition the executable applies: it takes the bundled
four-condition hypothesis `Certifies` — the thing a `Decidable` instance can discharge — to a
term of `Refutes`. It is `joint_countermodel` with the four hypotheses projected out of the
bundle, and `joint_countermodel`'s own statement is untouched by its arrival.
-/

namespace FormalSystem.Metalogic.Decidability

open FormalSystem.Syntax FormalSystem.Semantics FormalSystem.ProofSystem

namespace WitnessFamily

variable {Γ Del : Context}

/--
**Forward inner induction.** A semantic `untl` witness at ℤ-distance `d` yields label membership,
by `d` applications of the one-step unfolding clause.
-/
theorem untl_mem_of_witness (W : WitnessFamily Γ Del) (hloc : W.LocalCoherentLab)
    {g e : Formula} (hge : Formula.untl g e ∈ closureOf (Γ ++ Del))
    (i : Fin W.lassos.length) :
    ∀ (d : ℕ) (t s : ℤ), s - t = (d : ℤ) → t < s →
      e ∈ W.L i s → (∀ r : ℤ, t < r → r < s → g ∈ W.L i r) →
      Formula.untl g e ∈ W.L i t := by
  intro d
  induction d with
  | zero => intro t s hd hts _ _; omega
  | succ n ih =>
    intro t s hd hts hse hguard
    have hclause := (hloc i t).2.2.2.1 g e hge
    rcases eq_or_lt_of_le (show t + 1 ≤ s by omega) with heq | hlt
    · exact hclause.mpr (Or.inl (heq ▸ hse))
    · exact hclause.mpr (Or.inr ⟨hguard (t + 1) (by omega) hlt,
        ih (t + 1) s (by omega) hlt hse (fun r hr1 hr2 => hguard r (by omega) hr2)⟩)

/--
**Backward inner induction** — the leftward mirror of `untl_mem_of_witness`.
-/
theorem snce_mem_of_witness (W : WitnessFamily Γ Del) (hloc : W.LocalCoherentLab)
    {g e : Formula} (hge : Formula.snce g e ∈ closureOf (Γ ++ Del))
    (i : Fin W.lassos.length) :
    ∀ (d : ℕ) (t s : ℤ), t - s = (d : ℤ) → s < t →
      e ∈ W.L i s → (∀ r : ℤ, s < r → r < t → g ∈ W.L i r) →
      Formula.snce g e ∈ W.L i t := by
  intro d
  induction d with
  | zero => intro t s hd hst _ _; omega
  | succ n ih =>
    intro t s hd hst hse hguard
    have hclause := (hloc i t).2.2.2.2 g e hge
    rcases eq_or_lt_of_le (show s ≤ t - 1 by omega) with heq | hlt
    · exact hclause.mpr (Or.inl (heq ▸ hse))
    · exact hclause.mpr (Or.inr ⟨hguard (t - 1) hlt (by omega),
        ih (t - 1) s (by omega) hlt hse (fun r hr1 hr2 => hguard r hr1 (by omega))⟩)

/--
**T1, in shift-set form.**

Truth in the presented shift set agrees with label membership, at every carrier point, every time
and every formula of the target closure. Generalised over the carrier point because
`ShiftTruth`'s `box` clause quantifies over the whole carrier.
-/
theorem shiftTruth_iff_mem (W : WitnessFamily Γ Del)
    (hloc : W.LocalCoherentLab) (hful : W.FulfillingLab) (hbox : W.BoxFaithful) :
    ∀ ψ : Formula, ψ ∈ closureOf (Γ ++ Del) →
      ∀ (w : W.std.Carrier) (t : ℤ),
        ShiftSet.ShiftTruth W.std w t ψ ↔ ψ ∈ W.L w.1 (w.2 + t) := by
  intro ψ
  induction ψ with
  | atom p => intro _ w t; exact Iff.rfl
  | bot =>
    intro _ w t
    exact ⟨fun h => absurd h (by exact id), fun h => absurd h (hloc w.1 (w.2 + t)).1⟩
  | imp a b iha ihb =>
    intro hmem w t
    have ha := iha (closureOf_imp_left hmem) w t
    have hb := ihb (closureOf_imp_right hmem) w t
    rw [show ShiftSet.ShiftTruth W.std w t (Formula.imp a b)
        = (ShiftSet.ShiftTruth W.std w t a → ShiftSet.ShiftTruth W.std w t b) from rfl,
      (hloc w.1 (w.2 + t)).2.1 a b hmem]
    exact ⟨fun h hl => hb.mp (h (ha.mpr hl)), fun h hs => hb.mpr (h (ha.mp hs))⟩
  | box χ ih =>
    intro hmem w t
    rw [(hloc w.1 (w.2 + t)).2.2.1 χ hmem, hbox χ hmem]
    constructor
    · intro h i u
      obtain ⟨v, hv⟩ := W.sh_surj t (i, u)
      have hmem' := (ih (closureOf_box hmem) v t).mp (h v)
      have h1 : v.1 = i := congrArg Prod.fst hv
      have h2 : v.2 + t = u := congrArg Prod.snd hv
      rw [h1, h2] at hmem'
      exact hmem'
    · intro h v
      exact (ih (closureOf_box hmem) v t).mpr (h v.1 (v.2 + t))
  | untl g e ihg ihe =>
    intro hmem w t
    have hgc : g ∈ closureOf (Γ ++ Del) := closureOf_untl_right hmem
    have hec : e ∈ closureOf (Γ ++ Del) := closureOf_untl_left hmem
    constructor
    · rintro ⟨s, hts, hse, hguard⟩
      have hts' : @LT.lt ℤ _ t s := hts
      replace hguard : ∀ r : ℤ, @LT.lt ℤ _ t r → @LT.lt ℤ _ r s →
          ShiftSet.ShiftTruth W.std w r g := hguard
      refine W.untl_mem_of_witness hloc hmem w.1
        (s - t).toNat (w.2 + t) (w.2 + s) (by omega) (by omega)
        ((ihe hec w s).mp hse) ?_
      intro r hr1 hr2
      have hr := (ihg hgc w (r - w.2)).mp (hguard (r - w.2) (by omega) (by omega))
      simpa using hr
    · intro hlab
      obtain ⟨s, hts, hes, hgs⟩ := hful.1 w.1 (w.2 + t) g e hlab
      refine ⟨s - w.2, show @LT.lt ℤ _ t (s - w.2) by omega,
        (ihe hec w (s - w.2)).mpr (by simpa using hes), ?_⟩
      intro r hr1 hr2
      have hr1' : @LT.lt ℤ _ t r := hr1
      have hr2' : @LT.lt ℤ _ r (s - w.2) := hr2
      exact (ihg hgc w r).mpr (hgs (w.2 + r) (by omega) (by omega))
  | snce g e ihg ihe =>
    intro hmem w t
    have hgc : g ∈ closureOf (Γ ++ Del) := closureOf_snce_right hmem
    have hec : e ∈ closureOf (Γ ++ Del) := closureOf_snce_left hmem
    constructor
    · rintro ⟨s, hst, hse, hguard⟩
      have hst' : @LT.lt ℤ _ s t := hst
      replace hguard : ∀ r : ℤ, @LT.lt ℤ _ s r → @LT.lt ℤ _ r t →
          ShiftSet.ShiftTruth W.std w r g := hguard
      refine W.snce_mem_of_witness hloc hmem w.1
        (t - s).toNat (w.2 + t) (w.2 + s) (by omega) (by omega)
        ((ihe hec w s).mp hse) ?_
      intro r hr1 hr2
      have hr := (ihg hgc w (r - w.2)).mp (hguard (r - w.2) (by omega) (by omega))
      simpa using hr
    · intro hlab
      obtain ⟨s, hst, hes, hgs⟩ := hful.2 w.1 (w.2 + t) g e hlab
      refine ⟨s - w.2, show @LT.lt ℤ _ (s - w.2) t by omega,
        (ihe hec w (s - w.2)).mpr (by simpa using hes), ?_⟩
      intro r hr1 hr2
      have hr1' : @LT.lt ℤ _ (s - w.2) r := hr1
      have hr2' : @LT.lt ℤ _ r t := hr2
      exact (ihg hgc w r).mpr (hgs (w.2 + r) (by omega) (by omega))

/--
**T1, in `TruthAt` form**, via `ShiftSet.forward_repr`.

Composed with `Iff.trans` rather than rewritten by `forward_repr`; see this module's header.
-/
theorem truth_iff_mem (W : WitnessFamily Γ Del)
    (hloc : W.LocalCoherentLab) (hful : W.FulfillingLab) (hbox : W.BoxFaithful)
    (i : Fin W.lassos.length) (t : ℤ) (ψ : Formula) (hψ : ψ ∈ closureOf (Γ ++ Del)) :
    TruthAt W.std.model (W.std.hist ((i, 0) : W.std.Carrier)) t ψ ↔ ψ ∈ W.L i t :=
  (ShiftSet.forward_repr W.std ((i, 0) : W.std.Carrier) t ψ).trans
    (by simpa using shiftTruth_iff_mem W hloc hful hbox ψ hψ ((i, 0) : W.std.Carrier) t)

/--
**T1'** — a witness family with a target refutes ℤ-time consequence.
-/
theorem not_consequence_ztime (W : WitnessFamily Γ Del) {t : ℤ}
    (hloc : W.LocalCoherentLab) (hful : W.FulfillingLab) (hbox : W.BoxFaithful)
    (htgt : W.Target t) {σ : Formula} (hσ : σ ∈ Del) :
    ¬ SemanticConsequenceIn FrameClass.ZTime Γ σ := by
  intro hcons
  have hpre : ∀ ψ ∈ Γ, TruthAt W.std.model
      (W.std.hist ((W.mainIdx, 0) : W.std.Carrier)) t ψ := by
    intro ψ hψ
    exact (truth_iff_mem W hloc hful hbox _ t ψ (premise_mem_closure hψ)).mpr (htgt.1 ψ hψ)
  have htruth := hcons W.std.frame W.std_sat_ztime W.std.model _ t hpre
  exact htgt.2 σ hσ
    ((truth_iff_mem W hloc hful hbox _ t σ (conclusion_mem_closure hσ)).mp htruth)

/--
**T1'** at the unconstrained class, via `FrameClass.Sat.anti`.
-/
theorem not_consequence_base (W : WitnessFamily Γ Del) {t : ℤ}
    (hloc : W.LocalCoherentLab) (hful : W.FulfillingLab) (hbox : W.BoxFaithful)
    (htgt : W.Target t) {σ : Formula} (hσ : σ ∈ Del) :
    ¬ SemanticConsequenceIn FrameClass.Base Γ σ := by
  intro hcons
  refine not_consequence_ztime W hloc hful hbox htgt hσ ?_
  intro F hF M τ u hall
  exact hcons F (FrameClass.Sat.anti (by decide) hF) M τ u hall

/--
**T1', the joint form** a model checker reports: an explicit ℤ-time frame, model, history and
time at which every premise is true and every conclusion false.
-/
theorem joint_countermodel (W : WitnessFamily Γ Del) {t : ℤ}
    (hloc : W.LocalCoherentLab) (hful : W.FulfillingLab) (hbox : W.BoxFaithful)
    (htgt : W.Target t) :
    ∃ (F : TaskFrame) (_ : FrameClass.ZTime.Sat F) (M : TaskModel F)
      (τ : WorldHistory F) (u : F.Duration),
      (∀ γ ∈ Γ, TruthAt M τ u γ) ∧ (∀ σ ∈ Del, ¬ TruthAt M τ u σ) :=
  ⟨W.std.frame, W.std_sat_ztime, W.std.model,
    W.std.hist ((W.mainIdx, 0) : W.std.Carrier), t,
    fun γ hγ =>
      (truth_iff_mem W hloc hful hbox _ t γ (premise_mem_closure hγ)).mpr (htgt.1 γ hγ),
    fun σ hσ h =>
      htgt.2 σ hσ ((truth_iff_mem W hloc hful hbox _ t σ (conclusion_mem_closure hσ)).mp h)⟩

/--
**The joint existence statement a refuting certificate witnesses.**

`joint_countermodel`'s conclusion, named once so that a checker's accepting branch can carry it
as a return type. The binders `Γ` and `Del` are explicit rather than the section `variable`s
because the consumer applies this at a decoded certificate's own `target.premises` and
`target.conclusions`, which are not section variables there.
-/
def Refutes (Γ Del : Context) : Prop :=
  ∃ (F : TaskFrame) (_ : FrameClass.ZTime.Sat F) (M : TaskModel F)
    (τ : WorldHistory F) (u : F.Duration),
    (∀ γ ∈ Γ, TruthAt M τ u γ) ∧ (∀ σ ∈ Del, ¬ TruthAt M τ u σ)

/--
**The composition an accepting checker branch applies**: the bundled four conditions at a target
time yield the joint existence statement.

`joint_countermodel` with `Certifies`' four projections in place of its four hypotheses. This is
what makes acceptance a constructed term rather than a reported verdict: a branch that returns
this has a `Refutes Γ Del` in hand, and cannot be written without a `Certifies` to feed it.
-/
theorem refutes_of_certifies (W : WitnessFamily Γ Del) {t : ℤ}
    (h : W.Certifies t) : Refutes Γ Del :=
  joint_countermodel W h.1 h.2.1 h.2.2.1 h.2.2.2

end WitnessFamily

end FormalSystem.Metalogic.Decidability
