/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.WitnessFamily.Agreement
import FormalSystem.Metalogic.Decidability.WitnessFamily.Sharing.Histories
import FormalSystem.Metalogic.Decidability.WitnessFamily.Sharing.Fulfil

/-!
# Agreement for the Branching Device: Labels Are Truth Along Every Thread

The branching twin of `WitnessFamily/Agreement.lean`'s **T1**. A state-sharing family satisfying
(C0) `AtomCoherent`, (C1') `LocalCoherentShare`, (C2') `ThreadFulfilling` and (C3) `BoxFaithful`
has truth in the model it presents agreeing with label membership — at every thread, every time
offset and every formula of the target closure.

## No `ShiftSet`, and therefore no `forward_repr`

The deterministic development states its induction at `ShiftSet.ShiftTruth` and then composes
with `ShiftSet.forward_repr` to reach `TruthAt`. That route is closed here by construction: a
branching task relation is not a shift action, `Sharing/Frame.lean` builds a `FrameOver intOrder`
directly, and there is no shift-set layer to pass through. The induction below is therefore
stated at `TruthAt` from the start, and the role `forward_repr` plays on the deterministic side
— turning the auxiliary truth predicate into the consumer's one — is played here by nothing at
all, because there is no auxiliary predicate.

What *does* survive from that design is the reason the deterministic induction is generalised
over its carrier point: `box` quantifies over all world histories, so the induction has to be
stated at a quantified history or the `box` case has no induction hypothesis to apply. Here the
histories are parametrised by a thread and a time offset (`SharingWitnessFamily.hist`), and the
induction is generalised over both.

## The `box` case, and why (C3) is reused verbatim

`WitnessFamily.BoxFaithful` reads `bx χ = true ↔ ∀ i t, χ ∈ W.L i t`. Its right-hand side
quantifies over the **label pool** — every position of every lasso — and mentions no history, no
orbit and no task relation. A recombined history visits the positions `(θ.idx t, t)`, each of
which is one of those same positions, so recombination adds no label for `□` to range over.

The two halves of the case are exactly where `total_eq_thread` and `thread_is_history` are
consumed, one each:

* **`←`** (labels to truth) needs *every* world history to be a thread's trace, so that the
  induction hypothesis applies to an arbitrary `σ`. That is `total_eq_thread`, composed with
  `WorldHistory.ext_state` to turn the pointwise state agreement into an equality of histories.
* **`→`** (truth to labels) needs *every* position to carry a history through it, so that a
  universally quantified truth can be read at an arbitrary `(j, v)`. That is the constant thread
  at `j` from the offset `v - t`, which is `Thread.const` plus `hist`.

Neither half survives the deterministic argument's shape: `ShiftSet.total_eq_orbit` is false for
a branching frame, and it is `total_eq_thread` that replaces it.

## The valuation is a `Quotient.lift`, and that is what (C0) is for

The deterministic device's `atom` case is `Iff.rfl`: its carrier is `Fin |lassos| × ℤ` and the
valuation reads the label at that very pair. Here the carrier is a quotient by `share`, so the
valuation reads a *class*, and the lift needs the labels of any two shared indices to agree on
atoms. That is (C0), and it is the sole reason the branching device needs a condition the
deterministic one could do without. `SharingWitnessFamily.model` therefore takes an
`AtomCoherent` proof as an argument — the model is not defined without it.

Nothing else about the labels has to agree across a shared state. Two lassos may carry different
`untl` labels at a shared position and the certificate is still sound; that is the branching.

## What this frame delivers for the stability modal, and what it does not

(C5) `StabFaithful` and the `⊡` case of the truth lemma are **not** in scope here, and their
absence is not an oversight: `WitnessFamily` is indexed by `FormalSystem.Syntax.Context`, whose
formulas are `FormalSystem.Syntax.Formula` — six constructors, `atom`, `bot`, `imp`, `box`,
`untl`, `snce`, and no `⊡`. The stability modal is `FormalSystem.PlusLanguage.PlusFormula.stab`,
a constructor of a separate inductive, so there is no `⊡φ` to write at this datatype and the
induction below is complete as stated.

What the branching frame nonetheless delivers is the thing a stability clause was wanted for.
`FormalSystem.PlusLanguage.states_eq_of_deterministic` shows that on a **deterministic** frame
any two histories through a common state agree at every time, and
`FormalSystem.PlusLanguage.stab_iff_of_deterministic` turns that into the collapse `⊡φ ↔ φ` at
every point. The deterministic witness device presents a frame whose task relation *is*
functional, so both apply to it and `⊡` is the identity there — the device is blind to the
stability modal **by construction**, not merely incomplete for it, and cannot be repaired by
adding a truth clause. `SharingWitnessFamily.frame`'s task relation is not functional (a state
shared by two lassos has one successor per lasso through it), so neither lemma applies and the
collapse does not hold.

The condition itself is future work on an L⁺-indexed certificate: `LabelledLasso`, `closureOf`,
`WitnessFamily`, its conditions and this theorem would all have to be re-indexed over
`PlusFormula`, which also re-opens the model checker's JSON export contract.

## Main Definitions

- `SharingWitnessFamily.model` — the branching `TaskModel`, valuation lifted to the quotient
- `SharingWitnessFamily.Certifies` — the branching certificate bundle

## Main Results

- `SharingWitnessFamily.untl_mem_along_thread` / `snce_mem_along_thread` — the two inner
  inductions, run along a thread rather than along a lasso
- `SharingWitnessFamily.truth_iff_mem` — **T1** for the branching device
- `SharingWitnessFamily.Certifies` — the five conditions, bundled at a target time
- `SharingWitnessFamily.decidableCertifies` — the bundle decides
- `SharingWitnessFamily.not_consequence_ztime` / `joint_countermodel` — **T1'**
- `SharingWitnessFamily.refutes_of_certifies` — the second producer for `WitnessFamily.Refutes`
-/

namespace FormalSystem.Metalogic.Decidability

open FormalSystem.Syntax FormalSystem.Semantics FormalSystem.ProofSystem

namespace SharingWitnessFamily

variable {Γ Del : Context}

/-!
## The presented model

The frame is `Sharing/Frame.lean`'s; only the valuation is new, and it is a `Quotient.lift`.
-/

/--
**The branching model presented by a state-sharing family.**

The valuation reads the atom part of the labels through the quotient, which is well defined
exactly by (C0) `AtomCoherent`. The hypothesis is an explicit argument rather than a structure
field because every other condition is a hypothesis too, and bundling one of the five into the
datatype would make the datatype's `Decidable`-checked conditions four rather than five.
-/
def model (S : SharingWitnessFamily Γ Del) (hat : S.AtomCoherent) :
    TaskModel S.frame.toTaskFrame where
  valuation := fun C a =>
    Quotient.liftOn C (fun q => Formula.atom a ∈ S.L q.1 q.2)
      (by
        rintro ⟨i, u⟩ ⟨j, v⟩ ⟨ht, hs⟩
        have ht' : u = v := ht
        subst ht'
        exact propext (hat u i j hs a))

/-- The valuation at a class is label membership at any of its representatives. -/
@[simp]
theorem valuation_cls (S : SharingWitnessFamily Γ Del) (hat : S.AtomCoherent)
    (i : Fin S.lassos.length) (u : ℤ) (a : Atom) :
    (S.model hat).valuation (S.cls i u) a ↔ Formula.atom a ∈ S.L i u := Iff.rfl

/-!
## The two inner inductions, along a thread

`WitnessFamily/Agreement.lean`'s `untl_mem_of_witness` and `snce_mem_of_witness` walk the
one-step unfolding clause along a *lasso*. The branching clauses of (C1') are quantified over
shared successors and predecessors, so the same two inductions walk along a **thread**, with
`Thread.step` and `thread_trans_pred` supplying the succession side condition at each step.
-/

/--
**Forward inner induction, along a thread.** A semantic `untl` witness at ℤ-distance `d` down a
thread yields label membership at the thread's own index, by `d` applications of the branching
one-step unfolding clause.
-/
theorem untl_mem_along_thread (S : SharingWitnessFamily Γ Del)
    (hloc : S.LocalCoherentShare) {g e : Formula}
    (hge : Formula.untl g e ∈ closureOf (Γ ++ Del)) (θ : S.Thread) :
    ∀ (d : ℕ) (t s : ℤ), s - t = (d : ℤ) → t < s →
      e ∈ S.L (θ.idx s) s → (∀ r : ℤ, t < r → r < s → g ∈ S.L (θ.idx r) r) →
      Formula.untl g e ∈ S.L (θ.idx t) t := by
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
**Backward inner induction, along a thread** — the leftward mirror of `untl_mem_along_thread`.
-/
theorem snce_mem_along_thread (S : SharingWitnessFamily Γ Del)
    (hloc : S.LocalCoherentShare) {g e : Formula}
    (hge : Formula.snce g e ∈ closureOf (Γ ++ Del)) (θ : S.Thread) :
    ∀ (d : ℕ) (t s : ℤ), t - s = (d : ℤ) → s < t →
      e ∈ S.L (θ.idx s) s → (∀ r : ℤ, s < r → r < t → g ∈ S.L (θ.idx r) r) →
      Formula.snce g e ∈ S.L (θ.idx t) t := by
  intro d
  induction d with
  | zero => intro t s hd hst _ _; omega
  | succ n ih =>
    intro t s hd hst hse hguard
    have hclause :=
      (hloc (θ.idx t) t).2.2.2.2 (θ.idx (t - 1)) (thread_trans_pred θ t) g e hge
    rcases eq_or_lt_of_le (show s ≤ t - 1 by omega) with heq | hlt
    · subst heq
      exact hclause.mpr (Or.inl hse)
    · exact hclause.mpr (Or.inr ⟨hguard (t - 1) hlt (by omega),
        ih (t - 1) s (by omega) hlt hse (fun r hr1 hr2 => hguard r hr1 (by omega))⟩)

/-!
## The residual agreement the two clauses still force

Neither clause is a one-position condition, so each still forces *some* agreement between
distinct indices. Recording exactly how much, as named lemmas, is what keeps the redesign
honest: it is easy to re-derive the repaired defect by accident, and a statement is the only
form of that check which cannot drift.

**What is forced.** Fix a position `(i, t)`. Every index the position succeeds *to* agrees on
the `untl` unfolding, and every index it is succeeded *from* agrees on the `snce` unfolding.

**Why that is semantically forced rather than a relapse.** A position in a task frame is a
*history type*, not a world state: `untl g e` at `(i, t)` is `A[g U e]` there, so if two
successors disagreed on the unfolding, the position would have to be true and false at once.
The agreement below is that reading, transcribed.

**Why it is not the repaired defect.** `snce_share_congr` forced agreement between any two
indices merely *naming the same world state at `t`* — no succession required — which collapsed
the branching outright: two threads passing through one state could not carry different pasts.
`snce_pred_congr` requires a *common successor*, a strictly finer condition, and two indices
sharing a state at `t` need not have one. That gap is exactly the room the certificates of
`PlusWitnessFamily/Examples.lean` are built in.
-/

/--
**Residual `untl` agreement across successors.** Two indices the same position succeeds to agree
on the `untl` unfolding. See this section's header for why this is semantically forced.
-/
theorem untl_succ_congr {S : SharingWitnessFamily Γ Del} (h : S.LocalCoherentShare)
    {i j j' : Fin S.lassos.length} {t : ℤ} (hj : S.trans t i j) (hj' : S.trans t i j')
    {g e : Formula} (hc : Formula.untl g e ∈ closureOf (Γ ++ Del)) :
    (e ∈ S.L j (t + 1) ∨ (g ∈ S.L j (t + 1) ∧ Formula.untl g e ∈ S.L j (t + 1))) ↔
      (e ∈ S.L j' (t + 1) ∨ (g ∈ S.L j' (t + 1) ∧ Formula.untl g e ∈ S.L j' (t + 1))) :=
  ((h i t).2.2.2.1 j hj g e hc).symm.trans ((h i t).2.2.2.1 j' hj' g e hc)

/--
**Residual `snce` agreement across predecessors.** Two indices the same position is succeeded
from agree on the `snce` unfolding. The predecessor mirror of `untl_succ_congr`, and the
statement that replaces the retired `snce_share_congr`: the hypothesis is a *common successor*,
not a shared state.
-/
theorem snce_pred_congr {S : SharingWitnessFamily Γ Del} (h : S.LocalCoherentShare)
    {i k k' : Fin S.lassos.length} {t : ℤ} (hk : S.trans (t - 1) k i)
    (hk' : S.trans (t - 1) k' i)
    {g e : Formula} (hc : Formula.snce g e ∈ closureOf (Γ ++ Del)) :
    (e ∈ S.L k (t - 1) ∨ (g ∈ S.L k (t - 1) ∧ Formula.snce g e ∈ S.L k (t - 1))) ↔
      (e ∈ S.L k' (t - 1) ∨ (g ∈ S.L k' (t - 1) ∧ Formula.snce g e ∈ S.L k' (t - 1))) :=
  ((h i t).2.2.2.2 k hk g e hc).symm.trans ((h i t).2.2.2.2 k' hk' g e hc)

/-!
## T1 for the branching device
-/

/--
**T1 for the branching device.**

Truth in the presented model agrees with label membership, along every thread, at every time
offset and every formula of the target closure. The `box` case is grounded in `total_eq_thread`
— every world history is a thread's trace — where the deterministic proof appeals to
`ShiftSet.total_eq_orbit`, which is false here.
-/
theorem truth_iff_mem (S : SharingWitnessFamily Γ Del)
    (hat : S.AtomCoherent) (hloc : S.LocalCoherentShare) (hful : S.ThreadFulfilling)
    (hbox : S.toWitnessFamily.BoxFaithful) :
    ∀ ψ : Formula, ψ ∈ closureOf (Γ ++ Del) →
      ∀ (θ : S.Thread) (s t : ℤ),
        TruthAt (S.model hat) (S.hist θ s) t ψ ↔ ψ ∈ S.L (θ.idx (s + t)) (s + t) := by
  intro ψ
  induction ψ with
  | atom a => intro _ θ s t; exact Iff.rfl
  | bot =>
    intro _ θ s t
    exact ⟨fun h => absurd h (by exact id), fun h => absurd h (hloc (θ.idx (s + t)) (s + t)).1⟩
  | imp a b iha ihb =>
    intro hmem θ s t
    have ha := iha (closureOf_imp_left hmem) θ s t
    have hb := ihb (closureOf_imp_right hmem) θ s t
    rw [show TruthAt (S.model hat) (S.hist θ s) t (Formula.imp a b)
        = (TruthAt (S.model hat) (S.hist θ s) t a →
            TruthAt (S.model hat) (S.hist θ s) t b) from rfl,
      (hloc (θ.idx (s + t)) (s + t)).2.1 a b hmem]
    exact ⟨fun h hl => hb.mp (h (ha.mpr hl)), fun h hs => hb.mpr (h (ha.mp hs))⟩
  | box χ ih =>
    intro hmem θ s t
    rw [(hloc (θ.idx (s + t)) (s + t)).2.2.1 χ hmem, hbox χ hmem]
    constructor
    · intro h j v
      have hc := (ih (closureOf_box hmem) (Thread.const S j) (v - t) t).mp
        (h (S.hist (Thread.const S j) (v - t)))
      rw [Thread.const_idx, show v - t + t = v from by omega] at hc
      exact hc
    · intro h σ
      obtain ⟨θ', s', hσ⟩ := S.total_eq_thread σ
      have heq : σ = S.hist θ' s' := WorldHistory.ext_state (fun r => by rw [hσ r]; rfl)
      rw [heq]
      exact (ih (closureOf_box hmem) θ' s' t).mpr (h _ _)
  | untl g e ihg ihe =>
    intro hmem θ s t
    have hgc : g ∈ closureOf (Γ ++ Del) := closureOf_untl_right hmem
    have hec : e ∈ closureOf (Γ ++ Del) := closureOf_untl_left hmem
    constructor
    · rintro ⟨s₀, hts, hse, hguard⟩
      have hts' : @LT.lt ℤ _ t s₀ := hts
      replace hguard : ∀ r : ℤ, @LT.lt ℤ _ t r → @LT.lt ℤ _ r s₀ →
          TruthAt (S.model hat) (S.hist θ s) r g := hguard
      refine untl_mem_along_thread S hloc hmem θ (s₀ - t).toNat (s + t) (s + s₀)
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
    have hgc : g ∈ closureOf (Γ ++ Del) := closureOf_snce_right hmem
    have hec : e ∈ closureOf (Γ ++ Del) := closureOf_snce_left hmem
    constructor
    · rintro ⟨s₀, hst, hse, hguard⟩
      have hst' : @LT.lt ℤ _ s₀ t := hst
      replace hguard : ∀ r : ℤ, @LT.lt ℤ _ s₀ r → @LT.lt ℤ _ r t →
          TruthAt (S.model hat) (S.hist θ s) r g := hguard
      refine snce_mem_along_thread S hloc hmem θ (t - s₀).toNat (s + t) (s + s₀)
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

/-!
## The bundle, its decision procedure, and the `Refutes` producer

`WitnessFamily.Refutes` existentially quantifies the frame, the model, the history and the time.
That is what lets the two devices coexist as **two producers for one interface**: the
deterministic `WitnessFamily.refutes_of_certifies` lands in it with `W.std.frame`, and
`SharingWitnessFamily.refutes_of_certifies` lands in the same `Refutes Γ Del` with
`S.frame.toTaskFrame`. Neither producer's statement mentions the other's frame, so adding this
one does not touch `WitnessFamily/Agreement.lean`, and a consumer written against `Refutes`
accepts certificates of either shape with no change.

### Five components, in the checker's evaluation order

`Certifies` bundles exactly five conditions — (C0) `AtomCoherent`, (C1') `LocalCoherentShare`,
(C2') `ThreadFulfilling`, (C3) `BoxFaithful` (reused verbatim) and (C4) `Target` (reused
verbatim). A sixth, `StabFaithful`, was planned and is out of scope; see this module's header
and `Sharing/Predicates.lean` for why it is not stateable at a `Formula`-indexed certificate.

The (C1')/(C2') pair is **nested as a single conjunct** rather than left flat, because
`Sharing/Fulfil.lean` exports no standalone `Decidable (ThreadFulfilling S)`: the window
reduction for (C2') is relative to (C1'), so the two decide jointly through
`decidableCoherentShareAndFulfilling`. `decidableCertifies` is therefore assembled from four
instances, not five, and the nesting is what makes that assembly a bare `inferInstanceAs`
rather than a `decidable_of_iff` through a reassociation. Nothing is lost: the bundle carries
(C1') either way.
-/

/--
**The five certificate conditions, bundled at a target time.**

The projection order is the order a checker evaluates them in — cheapest and most local first —
so `instDecidableAnd`'s left-to-right short-circuit agrees with the order in which a rejection
is localized. It is a cost property of the bundle, not a mathematical one.
-/
def Certifies (S : SharingWitnessFamily Γ Del) (t : ℤ) : Prop :=
  S.AtomCoherent ∧ (S.LocalCoherentShare ∧ S.ThreadFulfilling) ∧
    S.toWitnessFamily.BoxFaithful ∧ S.toWitnessFamily.Target t

/--
**The bundle decides**, from four component instances: (C0), the joint (C1')∧(C2'), (C3) and
(C4). See the section header for why the middle two are joint rather than separate.
-/
instance decidableCertifies (S : SharingWitnessFamily Γ Del) (t : ℤ) :
    Decidable (S.Certifies t) :=
  inferInstanceAs (Decidable (S.AtomCoherent ∧ (S.LocalCoherentShare ∧ S.ThreadFulfilling) ∧
    S.toWitnessFamily.BoxFaithful ∧ S.toWitnessFamily.Target t))

/--
**T1 read on the main lasso**, which is where `Target` reads the consequence.

The constant thread at `mainIdx` from offset `0`; `Thread.const` makes it a thread and
`total_eq_thread` is not needed in this direction.
-/
theorem truth_main_iff_mem (S : SharingWitnessFamily Γ Del)
    (hat : S.AtomCoherent) (hloc : S.LocalCoherentShare) (hful : S.ThreadFulfilling)
    (hbox : S.toWitnessFamily.BoxFaithful) (t : ℤ) (ψ : Formula)
    (hψ : ψ ∈ closureOf (Γ ++ Del)) :
    TruthAt (S.model hat) (S.hist (Thread.const S S.mainIdx) 0) t ψ ↔
      ψ ∈ S.toWitnessFamily.main t := by
  have h := truth_iff_mem S hat hloc hful hbox ψ hψ (Thread.const S S.mainIdx) 0 t
  rw [Thread.const_idx, show (0 : ℤ) + t = t from by omega] at h
  exact h

/--
**T1'** — a state-sharing family with a target refutes ℤ-time consequence.
-/
theorem not_consequence_ztime (S : SharingWitnessFamily Γ Del) {t : ℤ}
    (hat : S.AtomCoherent) (hloc : S.LocalCoherentShare) (hful : S.ThreadFulfilling)
    (hbox : S.toWitnessFamily.BoxFaithful) (htgt : S.toWitnessFamily.Target t)
    {σ : Formula} (hσ : σ ∈ Del) :
    ¬ SemanticConsequenceIn FrameClass.ZTime Γ σ := by
  intro hcons
  have hpre : ∀ ψ ∈ Γ, TruthAt (S.model hat) (S.hist (Thread.const S S.mainIdx) 0) t ψ := by
    intro ψ hψ
    exact (truth_main_iff_mem S hat hloc hful hbox t ψ
      (WitnessFamily.premise_mem_closure hψ)).mpr (htgt.1 ψ hψ)
  have htruth := hcons S.frame.toTaskFrame S.frame_sat_ztime (S.model hat) _ t hpre
  exact htgt.2 σ hσ ((truth_main_iff_mem S hat hloc hful hbox t σ
    (WitnessFamily.conclusion_mem_closure hσ)).mp htruth)

/--
**T1', the joint form** a model checker reports, for the branching device: an explicit ℤ-time
frame, model, history and time at which every premise is true and every conclusion false.

The frame is `S.frame.toTaskFrame`, not a shift set; the history is the main lasso's constant
thread from offset `0`.
-/
theorem joint_countermodel (S : SharingWitnessFamily Γ Del) {t : ℤ}
    (hat : S.AtomCoherent) (hloc : S.LocalCoherentShare) (hful : S.ThreadFulfilling)
    (hbox : S.toWitnessFamily.BoxFaithful) (htgt : S.toWitnessFamily.Target t) :
    ∃ (F : TaskFrame) (_ : FrameClass.ZTime.Sat F) (M : TaskModel F)
      (τ : WorldHistory F) (u : F.Duration),
      (∀ γ ∈ Γ, TruthAt M τ u γ) ∧ (∀ σ ∈ Del, ¬ TruthAt M τ u σ) :=
  ⟨S.frame.toTaskFrame, S.frame_sat_ztime, S.model hat,
    S.hist (Thread.const S S.mainIdx) 0, t,
    fun γ hγ => (truth_main_iff_mem S hat hloc hful hbox t γ
      (WitnessFamily.premise_mem_closure hγ)).mpr (htgt.1 γ hγ),
    fun σ hσ h => htgt.2 σ hσ ((truth_main_iff_mem S hat hloc hful hbox t σ
      (WitnessFamily.conclusion_mem_closure hσ)).mp h)⟩

/--
**The second producer for the unchanged `Refutes` interface.**

`joint_countermodel` with `Certifies`' five projections in place of its five hypotheses, landing
in exactly `WitnessFamily.Refutes Γ Del` — the same statement `WitnessFamily.refutes_of_certifies`
lands in, which is untouched by this arrival.
-/
theorem refutes_of_certifies (S : SharingWitnessFamily Γ Del) {t : ℤ}
    (h : S.Certifies t) : WitnessFamily.Refutes Γ Del :=
  joint_countermodel S h.1 h.2.1.1 h.2.1.2 h.2.2.1 h.2.2.2

/-- The bundle's instance, confirmed by synthesis rather than asserted. -/
example (S : SharingWitnessFamily Γ Del) (t : ℤ) : Decidable (S.Certifies t) := inferInstance

end SharingWitnessFamily

end FormalSystem.Metalogic.Decidability
