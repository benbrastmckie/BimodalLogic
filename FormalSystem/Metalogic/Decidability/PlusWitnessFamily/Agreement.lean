/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.PlusWitnessFamily.Fulfil
import FormalSystem.PlusLanguage.PlusTruth

/-!
# Agreement at L⁺: Labels Are Truth Along Every Thread, Including `⊡`

The L⁺ twin of `WitnessFamily/Sharing/Agreement.lean`'s **T1**. An L⁺ state-sharing family
satisfying (C0) `PlusAtomCoherent`, (C1') `PlusLocalCoherentShare`, (C2') `PlusThreadFulfilling`,
(C3) `PlusBoxFaithful` and **(C5) `StabFaithful`** has truth in the model it presents agreeing
with label membership — at every thread, every time offset and every L⁺ formula of the target
closure.

## The seventh case is the whole point

`Syntax.Formula` has six constructors and the `Formula`-side induction is complete without a
stability clause. `PlusFormula` has seven, and the seventh is `stab`. Its case is what turns
(C5) from a signature into a **pinned obligation**: the theorem below does not elaborate without
`hstab`, and that is recorded here as the positive evidence that the condition is load-bearing.

## The `stab` case is the `box` case with `share`-gating

`PlusTruthAt`'s `box` clause quantifies over *every* world history; its `stab` clause quantifies
over every world history **whose state at `t` agrees with the present one**. On this frame the
states are the `share`-classes, so that side condition is exactly `share`, and the two halves of
the case consume exactly the two facts the `box` case consumes, each narrowed by one equation:

* **`→`** (truth to labels) reads the universally quantified truth at the constant thread
  through each `j` with `share u i j`; `cls_eq` is what discharges the state agreement that the
  `box` case did not have to discharge at all.
* **`←`** (labels to truth) takes an arbitrary `σ` with matching state, turns it into a thread's
  trace by `total_eq_thread`, and then turns the *state* match into a `share` by
  `share_of_cls_eq` — the exact converse of the step the forward direction takes.

Neither half is available on a deterministic frame, and not because the proof would be harder
there: `PlusLanguage/PlusDeterminism.lean`'s `stab_iff_of_deterministic` collapses `⊡φ` to `φ`
outright, so (C5) degenerates to a tautology and carries no information. The branching task
relation is what gives the condition content.

## Nothing here re-derives the frame

The frame, its four constraints, the threads, the histories and `total_eq_thread` are all
inherited from `SharingSkeleton` through `PlusSharingWitnessFamily`'s own projections. Only the
valuation is new, and it is a `Quotient.lift` whose well-definedness is exactly (C0) — which is
why `model` takes a `PlusAtomCoherent` proof as an argument rather than reading one off a field.

## Main Definitions

- `PlusSharingWitnessFamily.model` — the branching L⁺ `TaskModel`, valuation lifted to the
  quotient
- `PlusSharingWitnessFamily.PlusCertifies` — the **six** L⁺ certificate conditions, (C5) included
- `PlusWitnessFamily.PlusRefutes` — the L⁺ refutation interface, declared beside the
  deterministic one rather than replacing it

## Main Results

- `PlusSharingWitnessFamily.valuation_cls` — the valuation at a class
- `PlusSharingWitnessFamily.plusUntl_mem_along_thread` / `plusSnce_mem_along_thread` — the two
  inner inductions, run along a thread rather than along a lasso
- `PlusSharingWitnessFamily.plusTruth_iff_mem` — **T1** at L⁺, all seven cases
- `PlusSharingWitnessFamily.decidablePlusCertifies` — the six-condition bundle decides
- `PlusSharingWitnessFamily.plusJoint_countermodel` — **T1'** at L⁺
- `PlusSharingWitnessFamily.plusRefutes_of_certifies` — the producer for `PlusRefutes`
-/

namespace FormalSystem.Metalogic.Decidability

open FormalSystem.Syntax FormalSystem.Semantics FormalSystem.ProofSystem
open FormalSystem.PlusLanguage

namespace PlusSharingWitnessFamily

variable {Γ Del : PlusContext}

/-!
## The presented model

The frame is the skeleton's; only the valuation is new, and it is a `Quotient.lift`.
-/

/--
**The branching L⁺ model presented by a state-sharing family.**

The valuation reads the atom part of the labels through the quotient, which is well defined
exactly by (C0) `PlusAtomCoherent`. The hypothesis is an explicit argument rather than a
structure field because every other condition is a hypothesis too, and bundling one of the six
into the datatype would make the datatype's `Decidable`-checked conditions five rather than six.
-/
def model (S : PlusSharingWitnessFamily Γ Del) (hat : S.PlusAtomCoherent) :
    TaskModel S.frame.toTaskFrame where
  valuation := fun C a =>
    Quotient.liftOn C (fun q => PlusFormula.atom a ∈ S.L q.1 q.2)
      (by
        rintro ⟨i, u⟩ ⟨j, v⟩ ⟨ht, hs⟩
        have ht' : u = v := ht
        subst ht'
        exact propext (hat u i j hs a))

/-- The valuation at a class is label membership at any of its representatives. -/
@[simp]
theorem valuation_cls (S : PlusSharingWitnessFamily Γ Del) (hat : S.PlusAtomCoherent)
    (i : Fin S.lassos.length) (u : ℤ) (a : Atom) :
    (S.model hat).valuation (S.cls i u) a ↔ PlusFormula.atom a ∈ S.L i u := Iff.rfl

/-!
## The two inner inductions, along a thread

The branching clauses of (C1') are quantified over shared successors and predecessors, so the
two one-step-unfolding inductions walk along a **thread**, with `Thread.step` and
`plusThread_trans_pred` supplying the succession side condition at each step.
-/

/--
**Forward inner induction, along a thread.** A semantic `untl` witness at ℤ-distance `d` down a
thread yields label membership at the thread's own index, by `d` applications of the branching
one-step unfolding clause.
-/
theorem plusUntl_mem_along_thread (S : PlusSharingWitnessFamily Γ Del)
    (hloc : S.PlusLocalCoherentShare) {g e : PlusFormula}
    (hge : PlusFormula.untl g e ∈ plusClosureOf (Γ ++ Del)) (θ : S.Thread) :
    ∀ (d : ℕ) (t s : ℤ), s - t = (d : ℤ) → t < s →
      e ∈ S.L (θ.idx s) s → (∀ r : ℤ, t < r → r < s → g ∈ S.L (θ.idx r) r) →
      PlusFormula.untl g e ∈ S.L (θ.idx t) t := by
  intro d
  induction d with
  | zero => intro t s hd hts _ _; omega
  | succ n ih =>
    intro t s hd hts hse hguard
    have hclause := (hloc (θ.idx t) t).2.2.2.1 (θ.idx (t + 1)) (Thread.step θ t) g e hge
    rcases eq_or_lt_of_le (show t + 1 ≤ s by omega) with heq | hlt
    · subst heq
      exact hclause.mpr (Or.inl hse)
    · exact hclause.mpr (Or.inr ⟨hguard (t + 1) (by omega) hlt,
        ih (t + 1) s (by omega) hlt hse (fun r hr1 hr2 => hguard r (by omega) hr2)⟩)

/--
**Backward inner induction, along a thread** — the leftward mirror of
`plusUntl_mem_along_thread`.
-/
theorem plusSnce_mem_along_thread (S : PlusSharingWitnessFamily Γ Del)
    (hloc : S.PlusLocalCoherentShare) {g e : PlusFormula}
    (hge : PlusFormula.snce g e ∈ plusClosureOf (Γ ++ Del)) (θ : S.Thread) :
    ∀ (d : ℕ) (t s : ℤ), t - s = (d : ℤ) → s < t →
      e ∈ S.L (θ.idx s) s → (∀ r : ℤ, s < r → r < t → g ∈ S.L (θ.idx r) r) →
      PlusFormula.snce g e ∈ S.L (θ.idx t) t := by
  intro d
  induction d with
  | zero => intro t s hd hst _ _; omega
  | succ n ih =>
    intro t s hd hst hse hguard
    have hclause :=
      (hloc (θ.idx t) t).2.2.2.2 (θ.idx (t - 1)) (plusThread_trans_pred θ t) g e hge
    rcases eq_or_lt_of_le (show s ≤ t - 1 by omega) with heq | hlt
    · subst heq
      exact hclause.mpr (Or.inl hse)
    · exact hclause.mpr (Or.inr ⟨hguard (t - 1) hlt (by omega),
        ih (t - 1) s (by omega) hlt hse (fun r hr1 hr2 => hguard r hr1 (by omega))⟩)

/-!
## T1 at L⁺, all seven cases
-/

/--
**T1 for the L⁺ branching device.**

Truth in the presented model agrees with label membership, along every thread, at every time
offset and every L⁺ formula of the target closure.

The `box` case is grounded in `total_eq_thread` — every world history is a thread's trace. The
`stab` case is grounded in the same fact narrowed by `share_of_cls_eq`, plus (C5) `hstab`.
**Delete `hstab` and the `stab` case does not elaborate**: the label-side statement
`stab φ ∈ S.L i u` has, without it, no connection whatsoever to the labels at the other indices
of the class, which is exactly what the semantic clause quantifies over.

Paper: — (the certificate layer is the formalization's own; the paper states no
agreement theorem for it)
-/
theorem plusTruth_iff_mem (S : PlusSharingWitnessFamily Γ Del)
    (hat : S.PlusAtomCoherent) (hloc : S.PlusLocalCoherentShare)
    (hful : S.PlusThreadFulfilling) (hbox : S.toPlusWitnessFamily.PlusBoxFaithful)
    (hstab : S.StabFaithful) :
    ∀ ψ : PlusFormula, ψ ∈ plusClosureOf (Γ ++ Del) →
      ∀ (θ : S.Thread) (s t : ℤ),
        PlusTruthAt (S.model hat) (S.hist θ s) t ψ ↔ ψ ∈ S.L (θ.idx (s + t)) (s + t) := by
  intro ψ
  induction ψ with
  | atom a => intro _ θ s t; exact Iff.rfl
  | bot =>
    intro _ θ s t
    exact ⟨fun h => absurd h (by exact id), fun h => absurd h (hloc (θ.idx (s + t)) (s + t)).1⟩
  | imp a b iha ihb =>
    intro hmem θ s t
    have ha := iha (plusClosureOf_imp_left hmem) θ s t
    have hb := ihb (plusClosureOf_imp_right hmem) θ s t
    rw [show PlusTruthAt (S.model hat) (S.hist θ s) t (PlusFormula.imp a b)
        = (PlusTruthAt (S.model hat) (S.hist θ s) t a →
            PlusTruthAt (S.model hat) (S.hist θ s) t b) from rfl,
      (hloc (θ.idx (s + t)) (s + t)).2.1 a b hmem]
    exact ⟨fun h hl => hb.mp (h (ha.mpr hl)), fun h hs => hb.mpr (h (ha.mp hs))⟩
  | box χ ih =>
    intro hmem θ s t
    rw [(hloc (θ.idx (s + t)) (s + t)).2.2.1 χ hmem, hbox χ hmem]
    constructor
    · intro h j v
      have hc := (ih (plusClosureOf_box hmem) (Thread.const S j) (v - t) t).mp
        (h (S.hist (Thread.const S j) (v - t)))
      rw [SharingSkeleton.Thread.const_idx, show v - t + t = v from by omega] at hc
      exact hc
    · intro h σ
      obtain ⟨θ', s', hσ⟩ := S.total_eq_thread σ
      have heq : σ = S.hist θ' s' := WorldHistory.ext_state (fun r => by rw [hσ r]; rfl)
      rw [heq]
      exact (ih (plusClosureOf_box hmem) θ' s' t).mpr (h _ _)
  | untl g e ihg ihe =>
    intro hmem θ s t
    have hgc : g ∈ plusClosureOf (Γ ++ Del) := plusClosureOf_untl_right hmem
    have hec : e ∈ plusClosureOf (Γ ++ Del) := plusClosureOf_untl_left hmem
    constructor
    · rintro ⟨s₀, hts, hse, hguard⟩
      have hts' : @LT.lt ℤ _ t s₀ := hts
      replace hguard : ∀ r : ℤ, @LT.lt ℤ _ t r → @LT.lt ℤ _ r s₀ →
          PlusTruthAt (S.model hat) (S.hist θ s) r g := hguard
      refine plusUntl_mem_along_thread S hloc hmem θ (s₀ - t).toNat (s + t) (s + s₀)
        (by omega) (by omega) ((ihe hec θ s s₀).mp hse) ?_
      intro r hr1 hr2
      have hr := (ihg hgc θ s (r - s)).mp (hguard (r - s) (by omega) (by omega))
      rw [show s + (r - s) = r from by omega] at hr
      exact hr
    · intro hlab
      obtain ⟨s₀, hs0, hes, hgs⟩ := hful.1 (θ.idx (s + t)) (s + t) g e hlab θ rfl
      refine ⟨s₀ - s, show @LT.lt ℤ _ t (s₀ - s) by omega, ?_, ?_⟩
      · exact (ihe hec θ s (s₀ - s)).mpr
          (by rw [show s + (s₀ - s) = s₀ from by omega]; exact hes)
      · intro r hr1 hr2
        have hr1' : @LT.lt ℤ _ t r := hr1
        have hr2' : @LT.lt ℤ _ r (s₀ - s) := hr2
        exact (ihg hgc θ s r).mpr (hgs (s + r) (by omega) (by omega))
  | snce g e ihg ihe =>
    intro hmem θ s t
    have hgc : g ∈ plusClosureOf (Γ ++ Del) := plusClosureOf_snce_right hmem
    have hec : e ∈ plusClosureOf (Γ ++ Del) := plusClosureOf_snce_left hmem
    constructor
    · rintro ⟨s₀, hst, hse, hguard⟩
      have hst' : @LT.lt ℤ _ s₀ t := hst
      replace hguard : ∀ r : ℤ, @LT.lt ℤ _ s₀ r → @LT.lt ℤ _ r t →
          PlusTruthAt (S.model hat) (S.hist θ s) r g := hguard
      refine plusSnce_mem_along_thread S hloc hmem θ (t - s₀).toNat (s + t) (s + s₀)
        (by omega) (by omega) ((ihe hec θ s s₀).mp hse) ?_
      intro r hr1 hr2
      have hr := (ihg hgc θ s (r - s)).mp (hguard (r - s) (by omega) (by omega))
      rw [show s + (r - s) = r from by omega] at hr
      exact hr
    · intro hlab
      obtain ⟨s₀, hs0, hes, hgs⟩ := hful.2 (θ.idx (s + t)) (s + t) g e hlab θ rfl
      refine ⟨s₀ - s, show @LT.lt ℤ _ (s₀ - s) t by omega, ?_, ?_⟩
      · exact (ihe hec θ s (s₀ - s)).mpr
          (by rw [show s + (s₀ - s) = s₀ from by omega]; exact hes)
      · intro r hr1 hr2
        have hr1' : @LT.lt ℤ _ (s₀ - s) r := hr1
        have hr2' : @LT.lt ℤ _ r t := hr2
        exact (ihg hgc θ s r).mpr (hgs (s + r) (by omega) (by omega))
  | stab φ ih =>
    intro hmem θ s t
    rw [hstab (θ.idx (s + t)) (s + t) φ hmem]
    constructor
    · intro h j hsh
      have hst : (S.hist θ s).state t = (S.hist (Thread.const S j) s).state t := by
        change S.cls (θ.idx (s + t)) (s + t) = S.cls ((Thread.const S j).idx (s + t)) (s + t)
        rw [SharingSkeleton.Thread.const_idx]
        exact cls_eq rfl hsh
      have hc := (ih (plusClosureOf_stab hmem) (Thread.const S j) s t).mp
        (h (S.hist (Thread.const S j) s) hst)
      rwa [SharingSkeleton.Thread.const_idx] at hc
    · intro h σ hst
      obtain ⟨θ', s', hσ⟩ := S.total_eq_thread σ
      have heq : σ = S.hist θ' s' := WorldHistory.ext_state (fun r => by rw [hσ r]; rfl)
      subst heq
      have hst' : S.cls (θ.idx (s + t)) (s + t) = S.cls (θ'.idx (s' + t)) (s' + t) := hst
      obtain ⟨hteq, hsh⟩ := share_of_cls_eq hst'
      have hmem2 := h (θ'.idx (s' + t)) hsh
      rw [hteq] at hmem2
      exact (ih (plusClosureOf_stab hmem) θ' s' t).mpr hmem2

/-!
## The bundle, its decision procedure, and the L⁺ refutation interface

### Six components, and why the count is the point

`PlusCertifies` bundles exactly **six** conditions — (C0) `PlusAtomCoherent`, (C1')
`PlusLocalCoherentShare`, (C2') `PlusThreadFulfilling`, (C3) `PlusBoxFaithful`, (C4)
`PlusTarget` and (C5) `StabFaithful`. A five-component bundle would mean (C5) had been dropped
from the *checked* conditions while remaining in the theorem's hypotheses, which is precisely
the regression this whole development exists to prevent: a condition that is stated but never
checked certifies nothing.

The (C1')/(C2') pair is **nested as a single conjunct** rather than left flat, because
`PlusWitnessFamily/Fulfil.lean` exports no standalone `Decidable (PlusThreadFulfilling S)`: the
window reduction for (C2') is relative to (C1'), so the two decide jointly through
`decidablePlusCoherentShareAndFulfilling`. `decidablePlusCertifies` is therefore assembled from
five instances, not six, and the nesting is what makes that assembly a bare `inferInstanceAs`
rather than a `decidable_of_iff` through a reassociation. Nothing is lost: the bundle carries
(C1') either way.

### A parallel interface, not a widened one

`PlusRefutes` is a **new** existential over `PlusTruthAt`, declared beside
`WitnessFamily.Refutes` rather than in place of it. The deterministic device's `Refutes`, its
producers and the JSON export contract the model checker ships against are untouched by
everything in this file — nothing here edits them, and nothing here is imported by them.
-/

/--
**The six certificate conditions, bundled at a target time.**

The projection order is the order a checker evaluates them in, and (C5) sits last for a reason
that is about *localization*, not cost: it is the only condition whose failure implicates the
representative structure rather than a single lasso's labels, so a rejection that reaches it has
already excluded every cheaper explanation.
-/
def PlusCertifies (S : PlusSharingWitnessFamily Γ Del) (t : ℤ) : Prop :=
  S.PlusAtomCoherent ∧ (S.PlusLocalCoherentShare ∧ S.PlusThreadFulfilling) ∧
    S.toPlusWitnessFamily.PlusBoxFaithful ∧ S.toPlusWitnessFamily.PlusTarget t ∧ S.StabFaithful

/--
**The bundle decides**, from five component instances: (C0), the joint (C1')∧(C2'), (C3), (C4)
and (C5). See the section header for why the middle two are joint rather than separate.
-/
instance decidablePlusCertifies (S : PlusSharingWitnessFamily Γ Del) (t : ℤ) :
    Decidable (S.PlusCertifies t) :=
  inferInstanceAs (Decidable (S.PlusAtomCoherent ∧
    (S.PlusLocalCoherentShare ∧ S.PlusThreadFulfilling) ∧
    S.toPlusWitnessFamily.PlusBoxFaithful ∧ S.toPlusWitnessFamily.PlusTarget t ∧
    S.StabFaithful))

/--
**T1 read on the main lasso**, which is where `PlusTarget` reads the consequence.

The constant thread at `mainIdx` from offset `0`; `Thread.const` makes it a thread and
`total_eq_thread` is not needed in this direction.
-/
theorem plusTruth_main_iff_mem (S : PlusSharingWitnessFamily Γ Del)
    (hat : S.PlusAtomCoherent) (hloc : S.PlusLocalCoherentShare)
    (hful : S.PlusThreadFulfilling) (hbox : S.toPlusWitnessFamily.PlusBoxFaithful)
    (hstab : S.StabFaithful) (t : ℤ) (ψ : PlusFormula)
    (hψ : ψ ∈ plusClosureOf (Γ ++ Del)) :
    PlusTruthAt (S.model hat) (S.hist (Thread.const S S.mainIdx) 0) t ψ ↔
      ψ ∈ S.toPlusWitnessFamily.main t := by
  have h := plusTruth_iff_mem S hat hloc hful hbox hstab ψ hψ (Thread.const S S.mainIdx) 0 t
  rw [SharingSkeleton.Thread.const_idx, show (0 : ℤ) + t = t from by omega] at h
  exact h

end PlusSharingWitnessFamily

namespace PlusWitnessFamily

variable {Γ Del : PlusContext}

/--
**The L⁺ refutation interface.**

An explicit ℤ-time frame, model, history and time at which every premise is L⁺-true and every
conclusion L⁺-false. Declared beside `WitnessFamily.Refutes` rather than replacing it: the two
quantify over different truth predicates (`PlusTruthAt` against `TruthAt`) because they are
about different languages, and the deterministic device's interface is untouched.
-/
def PlusRefutes (Γ Del : PlusContext) : Prop :=
  ∃ (F : TaskFrame) (_ : FrameClass.ZTime.Sat F) (M : TaskModel F)
    (τ : WorldHistory F) (u : F.Duration),
    (∀ γ ∈ Γ, PlusTruthAt M τ u γ) ∧ (∀ σ ∈ Del, ¬ PlusTruthAt M τ u σ)

end PlusWitnessFamily

namespace PlusSharingWitnessFamily

variable {Γ Del : PlusContext}

/--
**T1', the joint form** a model checker reports, for the L⁺ branching device: an explicit ℤ-time
frame, model, history and time at which every premise is true and every conclusion false.

The frame is `S.frame.toTaskFrame`, not a shift set; the history is the main lasso's constant
thread from offset `0`.
-/
theorem plusJoint_countermodel (S : PlusSharingWitnessFamily Γ Del) {t : ℤ}
    (hat : S.PlusAtomCoherent) (hloc : S.PlusLocalCoherentShare)
    (hful : S.PlusThreadFulfilling) (hbox : S.toPlusWitnessFamily.PlusBoxFaithful)
    (htgt : S.toPlusWitnessFamily.PlusTarget t) (hstab : S.StabFaithful) :
    PlusWitnessFamily.PlusRefutes Γ Del :=
  ⟨S.frame.toTaskFrame, S.skeleton.frame_sat_ztime, S.model hat,
    S.hist (Thread.const S S.mainIdx) 0, t,
    fun γ hγ => (plusTruth_main_iff_mem S hat hloc hful hbox hstab t γ
      (plusPremise_mem_closure hγ)).mpr (htgt.1 γ hγ),
    fun σ hσ h => htgt.2 σ hσ ((plusTruth_main_iff_mem S hat hloc hful hbox hstab t σ
      (plusConclusion_mem_closure hσ)).mp h)⟩

/--
**The producer for the L⁺ refutation interface.**

`plusJoint_countermodel` with `PlusCertifies`' six projections in place of its six hypotheses.
This is what makes acceptance a constructed term rather than a reported verdict: a branch that
returns this has a `PlusRefutes Γ Del` in hand, and cannot be written without a `PlusCertifies`
to feed it — (C5) included, which is the sense in which the condition is checked rather than
merely stated.

Paper: — (the certificate layer is the formalization's own; the paper states no
refutation interface)
-/
theorem plusRefutes_of_certifies (S : PlusSharingWitnessFamily Γ Del) {t : ℤ}
    (h : S.PlusCertifies t) : PlusWitnessFamily.PlusRefutes Γ Del :=
  plusJoint_countermodel S h.1 h.2.1.1 h.2.1.2 h.2.2.1 h.2.2.2.1 h.2.2.2.2

/-- The bundle's instance, confirmed by synthesis rather than asserted. -/
example (S : PlusSharingWitnessFamily Γ Del) (t : ℤ) : Decidable (S.PlusCertifies t) :=
  inferInstance

end PlusSharingWitnessFamily

end FormalSystem.Metalogic.Decidability
