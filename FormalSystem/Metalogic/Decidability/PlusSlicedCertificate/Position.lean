/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.Frame
import FormalSystem.Metalogic.Decidability.PlusWitnessFamily.Compression.Types

/-!
# The Position Space over a Slice, and the One-Step Position Graph

A **position** is a slice state paired with a label set drawn from the target closure. The position
space over one slice is finite, and the one-step relations `succP` / `predP` between consecutive
slices are `Finset`-valued and decidable. This is the carrier the liveness fixpoints run on.

## The cardinality bound is a bound on the POSITION SPACE, not on `n`

`card_Pos` reads `Fintype.card G.Pos = G.n * 2 ^ |plusClosureOf (Γ ++ Del)|`. That is a count of
label-state pairs at a *given* slice width, not a bound on the slice width itself. The plan's
"Bounds: none, deliberately" forbids claiming a bound on `n`, `|back|`, `|mid|` or `|fwd|`; this is
none of those, and nothing here bounds any of them.

## What is local and what is not

`LabCoherent` is the part of coherence internal to **one** label: `⊥` is absent and the
implication clause holds. `StepClause` is the part relating **two consecutive** labels: the `untl`
clause read forwards out of the earlier label and the `snce` clause read backwards out of the
later one. The remaining coherence clauses — the `□`-clause against the box guess and the
fulfilment clauses — are not one-step conditions at all: the first is global and the second is what
liveness computes.

`AgreesOnState` pins the **state formulas** of a label — atoms, `□`-formulas, `⊡`-formulas — to the
slice labelling `G.slab t w`. Those are exactly the formulas whose truth at a carrier element is a
function of the carrier element, so pinning them is what makes a position a position rather than an
arbitrary pair.

## `succP` is NOT total on the position space, and that is correct

The plan's Phase 15 task list asks for `succP` and `predP` to be proved **non-empty on the position
space**, "from `G.BiSerial` and the type-completion argument". That claim is **false as stated**,
and this module does not prove it. The reason is structural rather than technical:

Take a closure containing `untl g e` with `e` and `g` both atoms, a certificate whose slice
labelling carries no atom at all, and the label `X = {untl g e}`. `X` is `LabCoherent` (no `⊥`, and
no implication in the closure to constrain) and it `AgreesOnState` with the empty atom set. But any
successor label `Y` at the next slice must also carry no atom, so `e ∉ Y` and `g ∉ Y`, and the
`untl` clause then demands `untl g e ∉ X` — a contradiction. So `G.succP t (w, X)` is empty.

Positions with no successor are not a defect: they are exactly what the **greatest** fixpoint
`fwdLive` is there to discard. What the liveness computation actually needs is that the fixpoints
are non-empty *when the certificate admits a genuine labelled path*, and that is
`mem_succP_of_path` below — proved, and the engine of the soundness direction. Recorded as a
deviation at the plan's Phase 15 heading, loudly, rather than absorbed: the obligation is replaced,
not dropped.

## `posAt` over-approximates, and what that costs the tail-stability demands

`posAt` admits every `LabCoherent`, state-agreeing label, including labels carrying an eventuality
obligation that **nothing** on the relevant side can discharge. The paragraph above records that in
the `untl` direction, where it leaves `succP` empty; `snceClauseAt` constrains the *later* label
from the earlier one, so the same thing happens mirror-wise in the `snce` direction, leaving
`predP` empty instead. Those positions are legitimate members of `posAt`, not artifacts.

**The consequence, and the `⊆`/`⊇` dichotomy it forces.** The one-step transfers `Stable.stepFwd`
and `Stable.stepBack` are reachability relations — `stepBack` is a `succP`-preimage — so a
dead-in-one-direction position reachable from a live one lands in that direction's iterate. A raw
demand `Φ X = X` then fails in the `⊆` direction: the iterate is **too big**. That failure is
repairable by intersecting with the computed one-directional live set, which is what
`Stable.fwdLiveAt` and `Stable.bwdLiveAt` are and why each conjunct of `Stable.TailStable` carries
one.

A `⊇` failure is a different thing and **no filter repairs it**: there the iterate is too *small*,
because a genuinely live position has no live predecessor one whole period back. Intersecting can
only shrink the left-hand side, so it cannot close a `⊇` gap.
`FixtureStable.ΦBack_L₀_inter_ne_cert` is exactly such a failure, at a named certificate, and it is
repaired only by re-presenting the frame — absorbing the pre-period into `mid`.

So `Stable.TailStable`, with both filters in place, is a **demand on a certificate and not a
theorem**: it is satisfiable, strictly weaker than the raw demand, and refuted at a certificate. It
is a field of `Certifies` for that reason. This is also what closes the question of strengthening
the compression theorem's output to avoid the obstruction: the undischargeable positions are
determined by `posAt` — by the closure and the slice labelling — and not by any witness family, so
no strengthening of a family-producing theorem can exclude them.

## Main definitions

- `PlusSlicedCertificate.Pos` — the position type, with `Fintype` and `DecidableEq`
- `PlusSlicedCertificate.card_Pos` — the position-space cardinality
- `PlusSlicedCertificate.LabCoherent` / `AgreesOnState` / `posAt` — the positions at one slice
- `PlusSlicedCertificate.StepClause` / `succP` / `predP` — the one-step position graph
- `PlusSlicedCertificate.mem_succP_of_path` — positions on a genuine labelled path do have
  successors; see this header's over-approximation note for what the positions *without* them cost
  the tail-stability demands

## Tags

plus-language · certificate · time-sliced · positions · decidable
-/

namespace FormalSystem.Metalogic.Decidability

open FormalSystem.PlusLanguage

namespace PlusSlicedCertificate

variable {Γ Del : PlusContext}

/-! ## The position type -/

/--
The labels a position may carry: subsets of the target closure, as a subtype of the closure's
powerset so that the type is a `Fintype` with no further argument.
-/
abbrev Lab (Γ Del : PlusContext) : Type :=
  {X : Finset PlusFormula // X ∈ (plusClosureOf (Γ ++ Del)).powerset}

/-- **A position over a slice**: a slice state and a label. -/
abbrev Pos (G : PlusSlicedCertificate Γ Del) : Type := Fin G.n × Lab Γ Del

/-- A position's label is a closure subset. -/
theorem pos_lab_sub (G : PlusSlicedCertificate Γ Del) (p : G.Pos) :
    p.2.1 ⊆ plusClosureOf (Γ ++ Del) :=
  Finset.mem_powerset.mp p.2.2

/--
**The size of the position space over one slice.**

A count of label-state pairs, *not* a bound on the slice width: `G.n` appears as a factor, not as a
quantity bounded. See this module's header.
-/
theorem card_Pos (G : PlusSlicedCertificate Γ Del) :
    Fintype.card G.Pos = G.n * 2 ^ (plusClosureOf (Γ ++ Del)).card := by
  simp [Fintype.card_prod, Fintype.card_coe, Finset.card_powerset]

/-! ## Which labels belong at a slice -/

/--
**The state shapes.** The closure members whose truth at a carrier element `(t, w)` is a function of
the carrier element alone: atoms (by the valuation), `□`-formulas (by `plusBox_const`) and
`⊡`-formulas (by `stab_congr_state`).
-/
def IsStateShape : PlusFormula → Bool
  | .atom _ => true
  | .box _ => true
  | .stab _ => true
  | _ => false

/-- A label **agrees on the state formulas** with the slice labelling at `(t, w)`. -/
def AgreesOnState (G : PlusSlicedCertificate Γ Del) (t : ℤ) (w : Fin G.n)
    (X : Finset PlusFormula) : Prop :=
  ∀ ψ ∈ plusClosureOf (Γ ++ Del), IsStateShape ψ = true → (ψ ∈ X ↔ ψ ∈ G.slab t w)

instance decidableAgreesOnState (G : PlusSlicedCertificate Γ Del) (t : ℤ) (w : Fin G.n)
    (X : Finset PlusFormula) : Decidable (G.AgreesOnState t w X) := by
  unfold AgreesOnState; infer_instance

/--
The implication clause at one formula, `Bool`-valued so that the whole of `LabCoherent` is decided
by a bounded quantifier over the closure. At a non-implication it is vacuously `true`.
-/
def impClauseAt (X : Finset PlusFormula) : PlusFormula → Bool
  | .imp a b => decide (PlusFormula.imp a b ∈ X ↔ (a ∈ X → b ∈ X))
  | _ => true

/--
**Coherence internal to one label**: `⊥` is absent, and the implication clause holds at every
implication in the closure.

The temporal clauses are deliberately absent — they relate two labels and live on `StepClause` —
and so are the `□`-clause (global) and the fulfilment clauses (what liveness computes).
-/
def LabCoherent (Γ Del : PlusContext) (X : Finset PlusFormula) : Prop :=
  PlusFormula.bot ∉ X ∧ ∀ ψ ∈ plusClosureOf (Γ ++ Del), impClauseAt X ψ = true

instance decidableLabCoherent (Γ Del : PlusContext) (X : Finset PlusFormula) :
    Decidable (LabCoherent Γ Del X) := by
  unfold LabCoherent; infer_instance

/-- **The position space at slice `t`**: the internally coherent labels that agree with the slice
labelling on the state formulas, paired with a slice state. -/
def posAt (G : PlusSlicedCertificate Γ Del) (t : ℤ) : Finset G.Pos :=
  Finset.univ.filter (fun p => LabCoherent Γ Del p.2.1 ∧ G.AgreesOnState t p.1 p.2.1)

theorem mem_posAt (G : PlusSlicedCertificate Γ Del) (t : ℤ) (p : G.Pos) :
    p ∈ G.posAt t ↔ LabCoherent Γ Del p.2.1 ∧ G.AgreesOnState t p.1 p.2.1 := by
  simp [posAt]

/-! ## The one-step position graph -/

/-- The `untl` clause read **forwards** out of the earlier label. -/
def untlClauseAt (X Y : Finset PlusFormula) : PlusFormula → Bool
  | .untl g e =>
      decide (PlusFormula.untl g e ∈ X ↔ (e ∈ Y ∨ (g ∈ Y ∧ PlusFormula.untl g e ∈ Y)))
  | _ => true

/-- The `snce` clause read **backwards** out of the later label. -/
def snceClauseAt (X Y : Finset PlusFormula) : PlusFormula → Bool
  | .snce g e =>
      decide (PlusFormula.snce g e ∈ Y ↔ (e ∈ X ∨ (g ∈ X ∧ PlusFormula.snce g e ∈ X)))
  | _ => true

/--
**The (C1') one-step clauses** linking a label `X` at slice `t` to a label `Y` at slice `t + 1`.

Both clauses are conditions on the *pair*: the `untl` clause constrains `X` given `Y`, and the
`snce` clause constrains `Y` given `X`. Neither is a condition on either label alone, which is why
they are here rather than in `LabCoherent`.
-/
def StepClause (Γ Del : PlusContext) (X Y : Finset PlusFormula) : Prop :=
  (∀ ψ ∈ plusClosureOf (Γ ++ Del), untlClauseAt X Y ψ = true) ∧
    (∀ ψ ∈ plusClosureOf (Γ ++ Del), snceClauseAt X Y ψ = true)

instance decidableStepClause (Γ Del : PlusContext) (X Y : Finset PlusFormula) :
    Decidable (StepClause Γ Del X Y) := by
  unfold StepClause; infer_instance

/-- **The one-step successors** of a position at slice `t`: positions at slice `t + 1` reached by a
`G.edge` on the state component and satisfying the one-step clauses on the label component. -/
def succP (G : PlusSlicedCertificate Γ Del) (t : ℤ) (p : G.Pos) : Finset G.Pos :=
  (G.posAt (t + 1)).filter (fun q => G.edge t p.1 q.1 = true ∧ StepClause Γ Del p.2.1 q.2.1)

/-- **The one-step predecessors** of a position at slice `t`: positions at slice `t - 1`. -/
def predP (G : PlusSlicedCertificate Γ Del) (t : ℤ) (q : G.Pos) : Finset G.Pos :=
  (G.posAt (t - 1)).filter
    (fun p => G.edge (t - 1) p.1 q.1 = true ∧ StepClause Γ Del p.2.1 q.2.1)

theorem mem_succP (G : PlusSlicedCertificate Γ Del) (t : ℤ) (p q : G.Pos) :
    q ∈ G.succP t p ↔
      q ∈ G.posAt (t + 1) ∧ G.edge t p.1 q.1 = true ∧ StepClause Γ Del p.2.1 q.2.1 := by
  simp [succP]

theorem mem_predP (G : PlusSlicedCertificate Γ Del) (t : ℤ) (p q : G.Pos) :
    p ∈ G.predP t q ↔
      p ∈ G.posAt (t - 1) ∧ G.edge (t - 1) p.1 q.1 = true ∧ StepClause Γ Del p.2.1 q.2.1 := by
  simp [predP]

/--
**`succP` and `predP` are adjoint**, on positions already known to lie at their own slices. This is
what lets the backward fixpoint be the forward one on the reversed slice graph rather than a second
independent development.
-/
theorem mem_succP_iff_mem_predP (G : PlusSlicedCertificate Γ Del) (t : ℤ) (p q : G.Pos)
    (hp : p ∈ G.posAt t) (hq : q ∈ G.posAt (t + 1)) :
    q ∈ G.succP t p ↔ p ∈ G.predP (t + 1) q := by
  rw [mem_succP, mem_predP, show t + 1 - 1 = t from by omega]
  exact ⟨fun h => ⟨hp, h.2⟩, fun h => ⟨hq, h.2⟩⟩

/-! ## Positions on a genuine labelled path

The replacement for the plan's (false) `succP`-totality obligation. See this module's header for why
totality fails and why its failure is the point.
-/

/-- The position a labelled path occupies at time `t`. -/
def posOf (G : PlusSlicedCertificate Γ Del) (lab : ℤ → Finset PlusFormula)
    (hsub : ∀ s : ℤ, lab s ⊆ plusClosureOf (Γ ++ Del)) (st : ℤ → Fin G.n) (t : ℤ) : G.Pos :=
  (st t, ⟨lab t, Finset.mem_powerset.mpr (hsub t)⟩)

@[simp]
theorem posOf_fst (G : PlusSlicedCertificate Γ Del) (lab : ℤ → Finset PlusFormula)
    (hsub : ∀ s : ℤ, lab s ⊆ plusClosureOf (Γ ++ Del)) (st : ℤ → Fin G.n) (t : ℤ) :
    (G.posOf lab hsub st t).1 = st t := rfl

@[simp]
theorem posOf_snd (G : PlusSlicedCertificate Γ Del) (lab : ℤ → Finset PlusFormula)
    (hsub : ∀ s : ℤ, lab s ⊆ plusClosureOf (Γ ++ Del)) (st : ℤ → Fin G.n) (t : ℤ) :
    (G.posOf lab hsub st t).2.1 = lab t := rfl

/-- **A labelled path occupies a position at every time.** -/
theorem mem_posAt_of_path (G : PlusSlicedCertificate Γ Del) (lab : ℤ → Finset PlusFormula)
    (hsub : ∀ s : ℤ, lab s ⊆ plusClosureOf (Γ ++ Del)) (st : ℤ → Fin G.n)
    (hcoh : PlusLocalCoherentSeqLab Γ Del G.bx lab)
    (hstate : ∀ s : ℤ, G.AgreesOnState s (st s) (lab s)) (t : ℤ) :
    G.posOf lab hsub st t ∈ G.posAt t := by
  rw [mem_posAt]
  refine ⟨⟨?_, ?_⟩, hstate t⟩
  · simpa using (hcoh t).1
  · intro ψ hψ
    match ψ with
    | .atom _ => rfl
    | .bot => rfl
    | .imp a b =>
        have h := (hcoh t).2.1 a b hψ
        simp only [impClauseAt]
        exact decide_eq_true h
    | .box _ => rfl
    | .untl _ _ => rfl
    | .snce _ _ => rfl
    | .stab _ => rfl

/--
**Positions on a genuine labelled path have successors**, and the successor is the position the path
itself occupies one slice later.

This is what the liveness fixpoints need, and all they need: `succP`-totality on the whole position
space is false (module header), but every position a real path visits has the real path's own next
position as a witness.
-/
theorem mem_succP_of_path (G : PlusSlicedCertificate Γ Del) (lab : ℤ → Finset PlusFormula)
    (hsub : ∀ s : ℤ, lab s ⊆ plusClosureOf (Γ ++ Del)) (st : ℤ → Fin G.n)
    (hcoh : PlusLocalCoherentSeqLab Γ Del G.bx lab)
    (hstate : ∀ s : ℤ, G.AgreesOnState s (st s) (lab s))
    (hedge : ∀ s : ℤ, G.edge s (st s) (st (s + 1)) = true) (t : ℤ) :
    G.posOf lab hsub st (t + 1) ∈ G.succP t (G.posOf lab hsub st t) := by
  rw [mem_succP]
  refine ⟨mem_posAt_of_path G lab hsub st hcoh hstate (t + 1), hedge t, ?_, ?_⟩
  · intro ψ hψ
    match ψ with
    | .atom _ => rfl
    | .bot => rfl
    | .imp _ _ => rfl
    | .box _ => rfl
    | .untl g e =>
        have h := (hcoh t).2.2.2.1 g e hψ
        simp only [untlClauseAt]
        exact decide_eq_true h
    | .snce _ _ => rfl
    | .stab _ => rfl
  · intro ψ hψ
    match ψ with
    | .atom _ => rfl
    | .bot => rfl
    | .imp _ _ => rfl
    | .box _ => rfl
    | .untl _ _ => rfl
    | .snce g e =>
        have h := (hcoh (t + 1)).2.2.2.2 g e hψ
        rw [show t + 1 - 1 = t from by omega] at h
        simp only [snceClauseAt]
        exact decide_eq_true h
    | .stab _ => rfl

/--
**Positions on a genuine labelled path have predecessors**, by the same argument mirrored through
the adjointness.
-/
theorem mem_predP_of_path (G : PlusSlicedCertificate Γ Del) (lab : ℤ → Finset PlusFormula)
    (hsub : ∀ s : ℤ, lab s ⊆ plusClosureOf (Γ ++ Del)) (st : ℤ → Fin G.n)
    (hcoh : PlusLocalCoherentSeqLab Γ Del G.bx lab)
    (hstate : ∀ s : ℤ, G.AgreesOnState s (st s) (lab s))
    (hedge : ∀ s : ℤ, G.edge s (st s) (st (s + 1)) = true) (t : ℤ) :
    G.posOf lab hsub st t ∈ G.predP (t + 1) (G.posOf lab hsub st (t + 1)) :=
  (mem_succP_iff_mem_predP G t _ _
    (mem_posAt_of_path G lab hsub st hcoh hstate t)
    (mem_posAt_of_path G lab hsub st hcoh hstate (t + 1))).mp
    (mem_succP_of_path G lab hsub st hcoh hstate hedge t)

end PlusSlicedCertificate

end FormalSystem.Metalogic.Decidability
