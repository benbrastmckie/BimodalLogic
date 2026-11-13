/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.RaySummary.CounterQuotient
import FormalSystem.Metalogic.Decidability.RaySummary.LadderChain

/-!
# The definitional layer of the ladder's realization statement

This module lands the objects the ladder realization statements quantify over: `typeOfCl`, the
projection out of `Certificate.lean`'s closure component `ClType`; `certChain`, the bi-infinite
certificate chain over the product carrier `Q × ClType φ × CK Tc Tn P B`; `LadderCons`, the
consistency bundle on a candidate set; and `Real`, the actually realizable subset of that
carrier, with the certificate conditions of `Real` that need no relation between its members.

The three hard obligations — soundness, the agreement of class-equivalent cells, and the lift in
pumping form — are each stated and proved elsewhere, and nothing below consumes any of them. In
particular no theorem here consumes `cellAt_const_of_kappa_eq` or the schema
`CellLEZeroConstOfKappaEq`, which are the input of the conditions this module does NOT carry.

## What `Real` carries here, and what it does not

Landed: `Real` itself, `realItem` and `mem_real_realItem` (every point of every admissible ladder
history projects into `Real`), `mem_clType_iff_truth` (the bridge from membership in a member's
closure type to truth at the witnessing point), `real_certLocK` (condition (1)),
`real_certBoxK` (condition (6)), and the three RELATIONAL conditions `real_certBiInfK`,
`real_certFwdK` and `real_certBwdK` (conditions (2), (3) and (4)). Five of `Real`'s six conditions
are therefore landed.

The three relational conditions were owed to whichever round landed a theorem deriving an `RK`
edge from an actual `Count`/`Drift` step, and that is `CounterQuotient.lean`'s
`rk_of_count_drift`, stated over the WIDENED `repsCnt` (range `Tc + Tn + 3*P + 2*B + 5` in both
factors — the narrower `Tc + Tn + P + B + 2` is refuted, see that module's own docstring). All
three go through it, and through the three facts the history layer already supplies:
`exists_ladderWalk_of_history` (every history of `ladderFrameAdm` is an offset ladder path, so
its consecutive states carry an actual `Count`/`Drift` step), `cohIdle_of_realized`
(`LadderChain.lean`, the relation's object/closure half), and `untl_mem_tpOf_iff` /
`snce_mem_tpOf_iff` (`LadderAgree.lean`, the temporal content of the two discharge conditions).
The discharge path a member of `Real` owes is a contiguous stretch of its OWN witnessing history,
so the `DischPathK` witness is `realItem` read along the integers, not a path assembled inside a
candidate set.

NOT landed here: condition (5), `certStabK` of `Real`, which is the ONE condition that consumes
the agreement of class-equivalent cells. `certStabK` reads the `⊡` letter's bit off the fibre of
the candidate set over `(q, κ)`, and `stab_mem_tpOf_iff_cell` (`LadderAgree.lean`) makes that bit
a datum of the CELL at the member's own world state, so the condition asks exactly for the
agreement and for nothing weaker (`stab_bit_agree_of_certStabK` below is the statement of that
collapse). It is not claimed here, and neither is `real_certAdmK_of_paramsOk` or
`real_subset_dmax`: all three wait on the agreement.

**THE MAXIMUM-CERTIFIED-SET FINDING UNDER THE WIDENED `RK`: the sufficiency half has MOVED.**
Re-read, not inherited, because the widening is not semantically free. `Dmax` is literally the
union of `certAdmK`-certified sets and `dmax_maximal` says every certified set lies inside it;
widening `repsCnt` enlarges `RK`, hence `relK`, hence WEAKENS `certBiInfK`, `certFwdK` and
`certBwdK` — each an existential over `relK`-related members — so strictly MORE sets are
certified and `Dmax` can only grow. `Real` meanwhile is UNCHANGED: its definition above names no
relation, no `RK` and no `repsCnt` at all, only realizability by an admissible ladder history. So
the inclusion `Dmax ⊆ Real` is strictly harder to prove after the widening than before.

What the presentation-decision record
(`reports/01_ladder-cell-presentation-decision.md` under
`specs/archive/819_ladder_cell_presentation_design_decision/`, Finding 3) actually records is
narrower than "every certified `R` lies inside `Real`": it is
"every certified `R` **with `Real ⊆ R`** satisfies `R ⊆ Real`", with the `stab` case closed by
induction on formula complexity, the `⟹` direction using `Real ⊆ R` and the `⟸` direction using
the induction hypothesis **on a chain through each `R`-fibre member**. That last step is the
obligation the widening moves: a chain is admitted by `certLocK` together with `relK`, and
`relK`'s counter conjunct is exactly what grew, so the lift the step consumes — the counter-lift
lemma's completeness half — now has a WEAKER hypothesis and is a STRICTLY STRONGER statement.

The two conditions that are not preserved by enlarging the candidate set do NOT bound that
growth, and the conjunct is nameable: `certStabK`'s right-hand side is
`∀ y ∈ R, y.1 = x.1 → y.2.2 = x.2.2 → argOf ψ ∈ y.2.1.val`, whose quantifier domain is `R`
ITSELF, and `certBoxK`'s is `∀ y ∈ R, argOf ψ ∈ y.2.1.val`. Neither mentions `cellAt`, `tpOf`,
`Rlad` or any history — `CounterQuotient.lean`'s own "No ladder consequence" bullet records that
nothing in that module relates `certAdmK` or `Dmax` to the model — so neither can force `R`'s
fibre at a `(q, κ)` into `Real`'s fibre there. They constrain which TYPES a candidate may carry
at a given `(q, κ)`; they never constrain which class pairs are related, which is where the
widening acts.

**Consequence for the fibre equation, recorded and not acted on here**: the inclusion
`Dmax ⊆ Real` is an inherited contingency of whichever round proves it, not a corollary of the
widening, and `ladderRealized`'s own right-hand side is a statement about the GROWN `Dmax`. No
declaration of this module claims `certAdmK` of `Dmax`, or `certStabK` or `certBoxK` of a union
of certified sets, and none is added to reach the opposite verdict. `repsCnt`, `Real` and `Dmax`
are unmodified by this re-read.

**Why the three relational conditions needed `rk_of_count_drift` and nothing less.** `relK`'s
counter conjunct is `RK Tc Tn P B (pend x.1) (pend y.1) x.2.2 y.2.2`, and `RK` is the image of
`Count`/`Drift` taken over the BOUNDED representative set `repsCnt Tc Tn P B`. Deriving such an
edge is not a reduction coordinate by coordinate: `kappa`'s gap coordinate `clipIdx B c n`
couples the two counters, so reducing each counter independently within its own threshold and
residue can move the gap (at `c = 100`, `n = 101`, `B = 3`, `Tc = Tn = 1`, `P = 0` the
independent reduction sends a gap of `1` to a gap of `0`). A COMMON downward shift by a multiple
of `P + 1` does preserve all five coordinates — that is `kappa_eq_of_shift`
(`LadderAgree.lean`) read downward, `clipIdx_sub_sub` the gap half of it — but it is limited by
whichever counter reaches its own threshold first, so the construction needs the saturated-gap
regime as a second case. `repsCnt`'s own bound answers the sizing question that case raises, and
the answer is compiled rather than open: the narrower `Tc + Tn + P + B + 2` does NOT suffice —
three `decide`-checked witnesses refute it at the frozen bound in the wired probe
`specs/evidence/seam-gluing-ray-product/ladder-reps-bound-refutation.lean` — and `repsCnt` is
stated at the widened `Tc + Tn + 3*P + 2*B + 5`, which `rk_of_count_drift`'s construction
discharges. Nothing in this module assumes either figure; both are read from
`CounterQuotient.lean`.

## The ladder's structural liveness, and the shape the backward half is retained in

`Realize.lean`'s `Cons` carries two liveness fields. Their fate here is NOT symmetric, and the
asymmetry is a compiled fact and not a convention.

* The FORWARD field (`ulive`) is REPLACED. Its work is done by the `Count`-driven decrease of the
  current deadline `c` while the object is pending: by `RunLayer.lean`'s `Count`, a pending-to-
  pending step forces `c' + 1 = c`, so `c` strictly decreases along any pending stretch and no
  forward obligation can be deferred forever. Nothing has to be hypothesized for this; it is a
  consequence of the relation `RladAdm` already carries.
* The BACKWARD field (`slive`) is RETAINED, in the shape `certBwdK` — Phase 9's landed
  `DischPathK` taken along the reversed `relK` over the product carrier, with the letters read as
  formula membership in the `ClType` component. It is retained because the ladder's structural
  liveness is FORWARD-ONLY: the thirteenth wired probe
  `specs/evidence/seam-gluing-ray-product/ladder-liveness-forward-only.lean` exhibits an
  admissible ladder path that is pending at every past time with its countdown growing without
  bound into the past (`gPast_isPath`, `gPast_pending_past`, `gPast_count`), so the `Count`
  argument that discharges the forward direction has no backward mirror and the past-directed
  obligations must be carried by a discharge condition of their own. This is a statement about
  the landed form of the ladder's liveness and about nothing else: no claim is made here that one
  device discriminates between any two classes of structures.

`Realize.lean`'s `SLive` is NOT retained and cannot be: it, and with it `UCoh`, `ULive`, `SCoh`,
`deferGraph`, `bwdDeferGraph`, `Disch`, `DischBwd`, `persist` and `snce_iff_of_SCoh_SLive`, are
indexed by `(clSig φ).preds` letters over a labelling `Q → (clSig φ).preds → Bool`, whereas
`LadderCons` below carries `lab : Q → Atom → Bool` and keeps the closure component in `ClType φ`,
so none of those terms elaborates at this carrier. No new translation layer is authored to bridge
the two, because `DischPathK`, `certFwdK` and `certBwdK` already are that layer, at the carrier
the ladder's statements are pinned at.

## The one cascade interface the counter lift will read, and what it carries

The admissibility half of the counter lift (`ladderLift`, not landed here) reads ONE name from
`LadderAgree.lean` at the comparison position: `exists_ladderPath_at_region_of_self_loop`, the
regime-joined existential delivering some ladder path that carries the original's object state at
the comparison position with the countdown raised by exactly the cycle length. Two things about
that interface are settled, and are stated here so a consumer does not have to rediscover them.

* **It is unconditional in the REGIME sense and conditional on the self-loop**, in that wording.
  The name takes no pending-past and no idle-past hypothesis — it `by_cases`es the dichotomy
  internally — and it does take
  `hself : ∀ p ≤ a, pend (objAt g p) = false → step (objAt g p) (objAt g p) = true`, the
  path-local self-loop at the path's own idle positions at or below `a`
  (`LadderAgree.lean`, the join's own docstring). That premise is INDEPENDENT of the others, not
  merely undischarged: the wired probe
  `specs/evidence/seam-gluing-ray-product/ladder-self-loop-derivability-decision.lean` compiles
  `hself_not_derivable` — refuted with `Fintype Q` ASSUMED — together with
  `hself_satisfiable_at_an_instance`. So whatever consumes this interface is conditional on
  `hself` as well, and is to say so rather than describe the interface as unconditional.
* **The name itself carries that, so every use site sees it.** `exists_ladderPath_at_region` and
  `exists_ladderPath_at_region_of_idle_past` are UNCLAIMED names, left free for whatever
  eventually discharges `hself`; the two landed declarations carry the `_of_self_loop` suffix.
  The pending-forever half `exists_ladderPath_at_region_of_pend_past` reads no `hself` and keeps
  its own name. The `spliceObj`-shaped conclusion is REFUTED in the idle-past regime rather than
  merely absent, which is why `exists_spliced_ladderPath_of_idle_past` is unclaimed too.

No declaration of this module consumes any of those names, and none of them is cited here as a
proof term.

## What this module does NOT hold

* **No soundness field on `LadderCons`.** A clause asserting that the projections of ladder
  histories lie in the candidate set would make the second conjunct of the realization-side run
  theorem near-vacuous under a filed name. That conjunct is discharged instead from the soundness
  obligation plus `LadderCons`'s own maximality clause, with no field added.
* **No model-side notion appears in any of the three definitions.** None of them mentions a
  history, a closure type read off a model, the ladder model, or a cell: they are conditions on a
  chain and on a set, and the composition with the model layer is the content of the obligations
  that consume them.
* **No stratification by `⊡`-nesting depth.** `certChain` carries no depth parameter. The
  stratified alternative was the route not taken by the recorded presentation decision, and a
  depth-indexed `certChain` would change the pinned signature of the lift that consumes it.
* **No decision procedure, no bound, no index.** Nothing here decides anything, every quantity
  named is a count, and no tuple is stated as an index of a ladder cell at any parameters.
-/

open FormalSystem.Syntax FormalSystem.PlusLanguage FormalSystem.Semantics
open FormalSystem.Metalogic.Decidability

namespace FormalSystem.Metalogic.Decidability.RaySummary

/-! ## The closure component's projection

`ClType φ` is landed in `Certificate.lean` as `{T : Finset PlusFormula // T ∈
(plusSubformulaClosure φ).powerset}`; only its projection was missing. -/

/-- **The closure component's projection**: the `Finset` of closure formulas a `ClType` carries.
`ClType` is landed (`Certificate.lean`); this is its first projection under a name the
realization statements can quantify over. -/
def typeOfCl {φ : PlusFormula} (T : ClType φ) : Finset PlusFormula := T.val

/-! ## The bi-infinite certificate chain

The chain condition over the product carrier `Q × ClType φ × CK Tc Tn P B`: the landed relation
`relK` between consecutive positions, local coherence at every position through the landed
`certLocK`, and the two temporal obligations read as formula membership in the `ClType`
component.

The last two conjuncts are the chain-level counterpart of `DischPathK`, the landed guarded
discharge path that `certFwdK` and `certBwdK` quantify at a SET: on a chain the discharging path
is a contiguous stretch of the chain itself, so the obligation is stated at the chain's own
positions and the existential ranges over times rather than over paths inside a candidate set.
The first conjunct is implied by the second — `cohIdle` constrains `locCoh` at both of its
endpoints — and is kept explicit so that the condition is named by the landed predicate rather
than left to be read out of the relation. -/

/-- **THE BI-INFINITE CERTIFICATE CHAIN.** `ξ` is locally coherent at every position
(`certLocK`), steps by `relK` at every position, and fulfils every forward `untl` obligation at
some later position and every backward `snce` obligation at some earlier position, with the guard
holding throughout the intervening stretch. No depth or stratification parameter: the chain
condition is unstratified. -/
def certChain {Q : Type} (step : Q → Q → Bool) (pend : Q → Bool) (lab : Q → Atom → Bool)
    (φ : PlusFormula) (Tc Tn P B : ℕ)
    (ξ : ℤ → Q × ClType φ × CK Tc Tn P B) : Prop :=
  certLocK lab φ Tc Tn P B (Set.range ξ) ∧
    (∀ t : ℤ, relK step pend lab φ Tc Tn P B (ξ t) (ξ (t + 1))) ∧
    (∀ (t : ℤ) (g e : PlusFormula), PlusFormula.untl g e ∈ (ξ t).2.1.val →
      ∃ s : ℤ, t < s ∧ e ∈ (ξ s).2.1.val ∧ ∀ r : ℤ, t < r → r < s → g ∈ (ξ r).2.1.val) ∧
    (∀ (t : ℤ) (g e : PlusFormula), PlusFormula.snce g e ∈ (ξ t).2.1.val →
      ∃ s : ℤ, s < t ∧ e ∈ (ξ s).2.1.val ∧ ∀ r : ℤ, s < r → r < t → g ∈ (ξ r).2.1.val)

/-! ## The consistency bundle

`LadderCons` is the certificate conditions on a candidate set together with the maximality
clause. The acceptance criterion is part of it and is never dropped: `certAdmK`'s own `certBoxK`
pins the `□` letter as ONE GLOBAL BIT and its `certStabK` pins the `⊡` letter per `(q, κ)`, which
is the granularity the anchor layer's fixpoint equations force. -/

/-- **THE CONSISTENCY BUNDLE.** `R` is `certAdmK`-certified — the six conditions, the two
acceptance conditions `certStabK` (per `(q, κ)`) and `certBoxK` (one global bit) included — and
`R` contains the maximum certified subset `Dmax`. Together with `dmax_maximal` the two clauses
pin `R` to `Dmax` exactly; both are stated, because the maximality clause is what the
realization-side run theorem discharges its membership conjunct from, and the certification
clause is what its chain conjunct reads. No liveness field of `Realize.lean`'s `Cons` survives as
such: the forward one is replaced by the `Count`-driven decrease and the backward one is
`certAdmK`'s own `certBwdK`. -/
def LadderCons {Q : Type} (step : Q → Q → Bool) (pend : Q → Bool) (lab : Q → Atom → Bool)
    (φ : PlusFormula) (Tc Tn P B : ℕ)
    (R : Set (Q × ClType φ × CK Tc Tn P B)) : Prop :=
  certAdmK step pend lab φ Tc Tn P B R ∧ Dmax step pend lab φ Tc Tn P B ⊆ R


/-! ## The `⊡` bits of a certified set across a `(q, κ)`-class

The first theorem of this module, and the one that says why the acceptance clause is the hard
one: a `certStabK`-certified set assigns the SAME `⊡` bit to any two of its members sharing an
object state and a counter class, because `certStabK` reads that bit off the fibre of the set
over `(q, κ)` and the fibre is the same for both. Read together with `certBiInfK` — which forbids
confining a certified set to one state's cell — and with `stab_mem_tpOf_iff_cell`
(`LadderAgree.lean`), which makes the `⊡` bit of a realized type a datum of the CELL at the
member's own world state, this is why discharging condition (5) of a realizable set asks for the
agreement of class-equivalent cells and for nothing weaker. It is a statement about certified
sets, which is why it lives on the certificate side and not in `LadderAgree.lean`. -/

section Stab

/-- **Any `certStabK`-certified set collapses the `⊡` bits across a `(q, κ)`-class.** -/
theorem stab_bit_agree_of_certStabK {Q : Type} (φ : PlusFormula) (Tc Tn P B : ℕ)
    (R : Set (Q × ClType φ × CK Tc Tn P B))
    (hR : certStabK φ Tc Tn P B R)
    (x y : Q × ClType φ × CK Tc Tn P B) (hx : x ∈ R) (hy : y ∈ R)
    (hq : y.1 = x.1) (hk : y.2.2 = x.2.2)
    (ψ : PlusFormula) (hψ : ψ ∈ plusSubformulaClosure φ) (hs : isStab ψ = true) :
    (ψ ∈ x.2.1.val ↔ ψ ∈ y.2.1.val) := by
  have hX := hR x hx ψ hψ hs
  have hY := hR y hy ψ hψ hs
  rw [hX, hY]
  constructor
  · intro h z hz hz1 hz2
    exact h z hz (by rw [hz1, hq]) (by rw [hz2, hk])
  · intro h z hz hz1 hz2
    exact h z hz (by rw [hz1, ← hq]) (by rw [hz2, ← hk])

end Stab

/-! ## `Real`, the actually realizable subset

`Real` is the set-valued per-state datum of presentation (a), read at the carrier the certificate
conditions are pinned at: the triples `(q, T, κ)` for which SOME admissible ladder history
realizes `T` at a world state whose ladder component is `⟨(q, c, n), h⟩` with
`kappa Tc Tn P B (c, n) = κ`. `Real` is NOT an index — `Dmax` is the object the fibre equation
factors through, and no tuple is stated here as an index of a ladder cell at any parameters.

The `ℤ` component of the world state is existentially quantified rather than pinned to the time
of evaluation. That is the faithful reading of "some history and some `z` realize `T` at a state
`⟨(q, c, n), h⟩`": the state the datum is about is the LADDER state, and the time coordinate is
invisible to `cellAt` (`cellAt_eq_cellAt`). Quantifying it is also what makes `Real` closed under
the model's own re-anchoring, which `certBoxK` below needs in its right-to-left direction. -/

section Realizable

variable {Q : Type} [Finite Q] [Nonempty Q] {step : Q → Q → Bool} {pend : Q → Bool}

/-- **The item a point of a ladder history realizes**: its object state, its realized closure
type as a `ClType` (a subset of the closure by `tpOf_subset`), and the class of its counter pair.
Classical through `tpOf`, hence noncomputable. -/
noncomputable def realItem (step : Q → Q → Bool) (pend : Q → Bool)
    (lab : Q → Atom → Bool) (φ : PlusFormula) (Tc Tn P B : ℕ)
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (σ : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame) (z : ℤ) :
    Q × ClType φ × CK Tc Tn P B :=
  ((σ.state z).2.1.1,
    ⟨tpOf (ladderModel step pend fwd bwd lab) φ σ z,
      Finset.mem_powerset.mpr (tpOf_subset (ladderModel step pend fwd bwd lab) φ σ z)⟩,
    kappa Tc Tn P B ((σ.state z).2.1.2.1, (σ.state z).2.1.2.2))

/-- **THE ACTUALLY REALIZABLE SUBSET.** The triples some admissible ladder history realizes. This
is the candidate the presentation decision's Finding 3 names, and the one the agreement makes
reachable; the three candidates a named condition already refutes are not reinstated here under
any shape. -/
def Real (step : Q → Q → Bool) (pend : Q → Bool) (lab : Q → Atom → Bool)
    (φ : PlusFormula) (Tc Tn P B : ℕ)
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x) :
    Set (Q × ClType φ × CK Tc Tn P B) :=
  {x | ∃ (c n : ℕ) (h : c ∈ Adm pend x.1) (t z : ℤ)
         (σ : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame),
         σ.state z = ((t, ⟨(x.1, c, n), h⟩) : (ladderFrameAdm step pend fwd bwd).WorldState) ∧
         kappa Tc Tn P B (c, n) = x.2.2 ∧
         tpOf (ladderModel step pend fwd bwd lab) φ σ z = x.2.1.val}

/-- Membership in `Real`, unfolded. -/
theorem mem_real_iff (lab : Q → Atom → Bool) (φ : PlusFormula) (Tc Tn P B : ℕ)
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (x : Q × ClType φ × CK Tc Tn P B) :
    x ∈ Real step pend lab φ Tc Tn P B fwd bwd ↔
      ∃ (c n : ℕ) (h : c ∈ Adm pend x.1) (t z : ℤ)
        (σ : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame),
        σ.state z = ((t, ⟨(x.1, c, n), h⟩) : (ladderFrameAdm step pend fwd bwd).WorldState) ∧
        kappa Tc Tn P B (c, n) = x.2.2 ∧
        tpOf (ladderModel step pend fwd bwd lab) φ σ z = x.2.1.val :=
  Iff.rfl

/-- **Every point of every admissible ladder history realizes a member of `Real`.** `Real` is
non-vacuous exactly when the frame has a history at all, and this is also the closure property
`certBoxK`'s right-to-left direction reads: the `□` letter's bit is the fibre over EVERYTHING,
and everything is reached because every point projects in. -/
theorem mem_real_realItem (lab : Q → Atom → Bool) (φ : PlusFormula) (Tc Tn P B : ℕ)
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (σ : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame) (z : ℤ) :
    realItem step pend lab φ Tc Tn P B fwd bwd σ z
      ∈ Real step pend lab φ Tc Tn P B fwd bwd := by
  refine ⟨(σ.state z).2.1.2.1, (σ.state z).2.1.2.2, (σ.state z).2.2, (σ.state z).1, z, σ,
    ?_, rfl, rfl⟩
  show σ.state z = ((σ.state z).1, _)
  apply Prod.ext rfl
  apply Subtype.ext
  rfl

/-- **A member of `Real` carries its witness's truth values at every closure formula.** The
bridge every condition of `Real` is proved across: the closure type a member carries IS the
realized type, so a letter's membership in it is truth at the witnessing point. -/
theorem mem_clType_iff_truth (lab : Q → Atom → Bool) (φ : PlusFormula) (Tc Tn P B : ℕ)
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    {x : Q × ClType φ × CK Tc Tn P B}
    {σ : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame} {z : ℤ}
    (hT : tpOf (ladderModel step pend fwd bwd lab) φ σ z = x.2.1.val)
    (χ : PlusFormula) (hχ : χ ∈ plusSubformulaClosure φ) :
    (χ ∈ x.2.1.val ↔ PlusTruthAt (ladderModel step pend fwd bwd lab) σ z χ) := by
  rw [← hT, mem_tpOf_iff]
  exact and_iff_right hχ

/-- **CONDITION (1) OF `Real`**: local coherence at every member. The three constrained arms of
`locPred` are the three truth-functional clauses of `PlusTruthAt` — the atomic bit is the ladder
model's valuation, which reads the object component and nothing else, `⊥` is never true, and the
implication arm is truth-functional. The four modal and temporal arms of `locPred` are
unconstrained and need nothing. No relation and no parameter condition enters. -/
theorem real_certLocK (lab : Q → Atom → Bool) (φ : PlusFormula) (Tc Tn P B : ℕ)
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x) :
    certLocK lab φ Tc Tn P B (Real step pend lab φ Tc Tn P B fwd bwd) := by
  rintro x ⟨c, n, h, t, z, σ, hst, -, hT⟩
  rw [locCoh, decide_eq_true_eq]
  intro ψ hψ
  have hiff := mem_clType_iff_truth lab φ Tc Tn P B fwd bwd hT
  cases ψ with
  | atom a =>
    have hq : (σ.state z).2.1.1 = x.1 := by rw [hst]
    have hv : PlusTruthAt (ladderModel step pend fwd bwd lab) σ z (PlusFormula.atom a)
        ↔ lab x.1 a = true := by
      rw [PlusTruth.atom_iff]
      change lab (σ.state z).2.1.1 a = true ↔ lab x.1 a = true
      rw [hq]
    have hb := (hiff (PlusFormula.atom a) hψ).trans hv
    simp only [locPred, beq_iff_eq]
    rcases Bool.eq_false_or_eq_true (lab x.1 a) with hl | hl
    · simp [hl, hb.mpr hl]
    · have hno : PlusFormula.atom a ∉ x.2.1.val := by
        intro hc
        exact Bool.false_ne_true (hl.symm.trans (hb.mp hc))
      simp [hl, hno]
  | bot =>
    have hb := hiff PlusFormula.bot hψ
    simp only [locPred, decide_eq_true_eq]
    intro hc
    exact PlusTruth.bot_false (ladderModel step pend fwd bwd lab) σ z (hb.mp hc)
  | imp α β =>
    have ha := hiff α (plusClosure_imp_left φ α β hψ)
    have hbb := hiff β (plusClosure_imp_right φ α β hψ)
    have hi := (hiff (PlusFormula.imp α β) hψ).trans
      (PlusTruth.imp_iff (ladderModel step pend fwd bwd lab) σ z α β)
    simp only [locPred, beq_iff_eq]
    by_cases hA : α ∈ x.2.1.val
    · by_cases hBt : β ∈ x.2.1.val
      · have hin : PlusFormula.imp α β ∈ x.2.1.val := hi.mpr (fun _ => hbb.mp hBt)
        simp [hA, hBt, hin]
      · have hno : PlusFormula.imp α β ∉ x.2.1.val := by
          intro hc
          exact hBt (hbb.mpr (hi.mp hc (ha.mp hA)))
        simp [hA, hBt, hno]
    · have hin : PlusFormula.imp α β ∈ x.2.1.val := by
        refine hi.mpr (fun hc => ?_)
        exact absurd (ha.mpr hc) hA
      simp [hA, hin]
  | box _ => rfl
  | untl _ _ => rfl
  | snce _ _ => rfl
  | stab _ => rfl

/-- **CONDITION (6) OF `Real`**: the `□` letter's bit is ONE GLOBAL BIT. This is the condition
the candidate "all of `Q × ClType φ × CK`" fails, and it is reachable for `Real` exactly because
`box_mem_tpOf_iff`'s right-hand side quantifies over EVERY history and EVERY time — so the bit is
already the fibre of the whole model, and `mem_real_realItem` says every point of the model is a
member. No relation, no parameter condition, and no union argument enters: nothing here claims
`certBoxK` of a union of certified sets. -/
theorem real_certBoxK (lab : Q → Atom → Bool) (φ : PlusFormula) (Tc Tn P B : ℕ)
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x) :
    certBoxK φ Tc Tn P B (Real step pend lab φ Tc Tn P B fwd bwd) := by
  rintro x ⟨c, n, h, t, z, σ, hst, -, hT⟩ ψ hψ hs
  obtain ⟨χ, rfl⟩ : ∃ χ, ψ = PlusFormula.box χ := by
    cases ψ <;> first | exact ⟨_, rfl⟩ | simp [isBox] at hs
  have hbox := box_mem_tpOf_iff (ladderModel step pend fwd bwd lab) φ σ z hψ
  change PlusFormula.box χ ∈ x.2.1.val ↔ _
  rw [← hT, hbox]
  constructor
  · intro hall y hy
    obtain ⟨c', n', h', t', z', σ', -, -, hT'⟩ := hy
    show argOf (PlusFormula.box χ) ∈ y.2.1.val
    simpa only [argOf] using hT' ▸ hall σ' z'
  · intro hall σ' z'
    have hmem := mem_real_realItem lab φ Tc Tn P B fwd bwd σ' z'
    simpa only [argOf, realItem] using hall _ hmem

/-! ## The relational conditions of `Real`

Conditions (2), (3) and (4) — the three that quantify `relK` between two members. Their one
shared missing link was a theorem deriving an `RK` edge from an actual `Count`/`Drift` step, and
that is `CounterQuotient.lean`'s `rk_of_count_drift` over the widened `repsCnt`. The other half
of `relK`, the `cohIdle` edge on the object and closure components, is `LadderChain.lean`'s
`cohIdle_of_realized`, and the bridge between them is `exists_ladderWalk_of_history`: a history
of `ladderFrameAdm` has no freedom beyond its offset, so its consecutive states carry an actual
ladder step and its realized types are `cohIdle`-linked.

No proof below consumes `cellAt_const_of_kappa_eq`, the schema `CellLEZeroConstOfKappaEq`, or any
union argument, and none claims `certStabK` of `Real`, `certAdmK` of `Dmax`, or any inclusion
between `Real` and `Dmax`. -/

/-- **A history of `ladderFrameAdm` is an offset ladder path.** `ofSlicedStepFinBranch_mem_HF_iff`
read at the admissible ladder relation: the time component is forced to be `t + k` for an offset
`k` the history fixes once, and the state component is a ladder path. This is what turns a
condition on a history into the actual `Count`/`Drift` step between two of its states, and it is
the only place in this module where the frame's construction is unfolded. -/
theorem exists_ladderWalk_of_history
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (σ : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame) :
    ∃ (k : ℤ) (g : ℤ → LadderState Q pend), IsLadderPath step pend g ∧
      ∀ t : ℤ, σ.state t = (t + k, g t) := by
  obtain ⟨k, g, hpath, hf⟩ :=
    (ofSlicedStepFinBranch_mem_HF_iff (RladAdm step pend) (RladAdm_fwd step pend)
      (RladAdm_bwd step pend) fwd bwd σ.path).mp ⟨σ, rfl⟩
  exact ⟨k, g, fun u => hpath u, fun t => congrFun hf t⟩

/-- **A member of `Real` IS the item its own witness realizes.** The three conjuncts of
membership pin all three components of `realItem` at the witnessing point, so the member and the
item are the same triple. This is what lets every condition below be proved about `realItem`
read along the integers and then transported to the member. -/
theorem realItem_eq_of_witness (lab : Q → Atom → Bool) (φ : PlusFormula) (Tc Tn P B : ℕ)
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    {x : Q × ClType φ × CK Tc Tn P B} {c n : ℕ} {h : c ∈ Adm pend x.1} {t z : ℤ}
    {σ : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame}
    (hst : σ.state z = ((t, ⟨(x.1, c, n), h⟩) : (ladderFrameAdm step pend fwd bwd).WorldState))
    (hk : kappa Tc Tn P B (c, n) = x.2.2)
    (hT : tpOf (ladderModel step pend fwd bwd lab) φ σ z = x.2.1.val) :
    realItem step pend lab φ Tc Tn P B fwd bwd σ z = x := by
  have h1 : (σ.state z).2.1.1 = x.1 := by rw [hst]
  have h2 : (σ.state z).2.1.2.1 = c := by rw [hst]
  have h3 : (σ.state z).2.1.2.2 = n := by rw [hst]
  refine Prod.ext h1 (Prod.ext (Subtype.ext hT) ?_)
  change kappa Tc Tn P B ((σ.state z).2.1.2.1, (σ.state z).2.1.2.2) = x.2.2
  rw [h2, h3]; exact hk

/-- **CONSECUTIVE POINTS OF A LADDER HISTORY ARE `relK`-LINKED.** The edge every relational
condition of `Real` is built from: the `cohIdle` half by `cohIdle_of_realized`, the `RK` half by
`rk_of_count_drift` applied to the actual `Count`/`Drift` step `exists_ladderWalk_of_history`
exposes. No parameter condition and no agreement enters. -/
theorem relK_realItem_succ (lab : Q → Atom → Bool) (φ : PlusFormula) (Tc Tn P B : ℕ)
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (σ : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame) (z : ℤ) :
    relK step pend lab φ Tc Tn P B
      (realItem step pend lab φ Tc Tn P B fwd bwd σ z)
      (realItem step pend lab φ Tc Tn P B fwd bwd σ (z + 1)) := by
  obtain ⟨k, g, hg, hτ⟩ := exists_ladderWalk_of_history fwd bwd σ
  have e1 : (realItem step pend lab φ Tc Tn P B fwd bwd σ z).1 = objAt g z := by
    change (σ.state z).2.1.1 = (g z).1.1
    rw [hτ z]
  have e2 : (realItem step pend lab φ Tc Tn P B fwd bwd σ (z + 1)).1 = objAt g (z + 1) := by
    change (σ.state (z + 1)).2.1.1 = (g (z + 1)).1.1
    rw [hτ (z + 1)]
  have f1 : (realItem step pend lab φ Tc Tn P B fwd bwd σ z).2.2
      = kappa Tc Tn P B (cntAt g z, nxtAt g z) := by
    change kappa Tc Tn P B ((σ.state z).2.1.2.1, (σ.state z).2.1.2.2) = _
    rw [hτ z]; rfl
  have f2 : (realItem step pend lab φ Tc Tn P B fwd bwd σ (z + 1)).2.2
      = kappa Tc Tn P B (cntAt g (z + 1), nxtAt g (z + 1)) := by
    change kappa Tc Tn P B ((σ.state (z + 1)).2.1.2.1, (σ.state (z + 1)).2.1.2.2) = _
    rw [hτ (z + 1)]; rfl
  obtain ⟨-, -, hdrift, hcount⟩ := hg z
  refine ⟨?_, ?_⟩
  · simp only [e1, e2]
    exact cohIdle_of_realized fwd bwd lab φ hg σ hτ z
  · rw [e1, e2, f1, f2]
    exact rk_of_count_drift Tc Tn P B (pend (objAt g z)) (pend (objAt g (z + 1)))
      (cntAt g z) (nxtAt g z) (cntAt g (z + 1)) (nxtAt g (z + 1)) hcount hdrift

/-- **CONDITION (2) OF `Real`**: every member has a successor AND a predecessor inside `Real`.
Both fulfilment arms stay EXISTENTIAL, and both witnesses are the neighbouring points of the
member's own witnessing history — which is also why `Real` is never confined to one state's
cell. -/
theorem real_certBiInfK (lab : Q → Atom → Bool) (φ : PlusFormula) (Tc Tn P B : ℕ)
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x) :
    certBiInfK step pend lab φ Tc Tn P B (Real step pend lab φ Tc Tn P B fwd bwd) := by
  rintro x ⟨c, n, h, t, z, σ, hst, hk, hT⟩
  have hx : realItem step pend lab φ Tc Tn P B fwd bwd σ z = x :=
    realItem_eq_of_witness lab φ Tc Tn P B fwd bwd hst hk hT
  refine ⟨⟨realItem step pend lab φ Tc Tn P B fwd bwd σ (z + 1),
      mem_real_realItem lab φ Tc Tn P B fwd bwd σ (z + 1), ?_⟩,
    ⟨realItem step pend lab φ Tc Tn P B fwd bwd σ (z - 1),
      mem_real_realItem lab φ Tc Tn P B fwd bwd σ (z - 1), ?_⟩⟩
  · rw [← hx]; exact relK_realItem_succ lab φ Tc Tn P B fwd bwd σ z
  · have hrel := relK_realItem_succ lab φ Tc Tn P B fwd bwd σ (z - 1)
    rw [show z - 1 + 1 = z from by ring] at hrel
    rw [← hx]
    exact hrel

/-- **CONDITION (3) OF `Real`**: EXISTENTIAL forward discharge inside `Real`. The discharge path
is the contiguous stretch `z, z + 1, …, z + m` of the member's OWN witnessing history, with
`untl_mem_tpOf_iff` (`LadderAgree.lean`) supplying the fulfilling position `s = z + m` and the
guard along the intervening stretch, every position of the stretch lying in `Real` by
`mem_real_realItem` and the consecutive-position relation by `relK_realItem_succ`. -/
theorem real_certFwdK (lab : Q → Atom → Bool) (φ : PlusFormula) (Tc Tn P B : ℕ)
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x) :
    certFwdK step pend lab φ Tc Tn P B (Real step pend lab φ Tc Tn P B fwd bwd) := by
  rintro x ⟨c, n, h, t, z, σ, hst, hk, hT⟩ ψ hψx hu
  obtain ⟨γ, ε, rfl⟩ : ∃ γ ε, ψ = PlusFormula.untl γ ε := by
    cases ψ <;> first | exact ⟨_, _, rfl⟩ | simp [isUntl] at hu
  have hcl : PlusFormula.untl γ ε ∈ plusSubformulaClosure φ :=
    Finset.mem_powerset.mp x.2.1.property hψx
  have hx : realItem step pend lab φ Tc Tn P B fwd bwd σ z = x :=
    realItem_eq_of_witness lab φ Tc Tn P B fwd bwd hst hk hT
  have hmem : PlusFormula.untl γ ε ∈ tpOf (ladderModel step pend fwd bwd lab) φ σ z := by
    rw [hT]; exact hψx
  obtain ⟨s, hzs, hε, hγ⟩ :=
    (untl_mem_tpOf_iff (ladderModel step pend fwd bwd lab) φ σ z hcl).mp hmem
  refine ⟨(s - z).toNat,
    fun i => realItem step pend lab φ Tc Tn P B fwd bwd σ (z + (i : ℤ)), by omega, ?_,
    fun i _ => mem_real_realItem lab φ Tc Tn P B fwd bwd σ _, fun i _ => ⟨?_, ?_⟩, ?_, ?_⟩
  · simpa using hx
  · have hrel := relK_realItem_succ lab φ Tc Tn P B fwd bwd σ (z + (i : ℤ))
    change relK step pend lab φ Tc Tn P B
      (realItem step pend lab φ Tc Tn P B fwd bwd σ (z + (i : ℤ)))
      (realItem step pend lab φ Tc Tn P B fwd bwd σ (z + ((i + 1 : ℕ) : ℤ)))
    rw [show z + ((i + 1 : ℕ) : ℤ) = (z + (i : ℤ)) + 1 from by push_cast; ring]
    exact hrel
  · exact mem_real_realItem lab φ Tc Tn P B fwd bwd σ _
  · change ε ∈ tpOf (ladderModel step pend fwd bwd lab) φ σ (z + (((s - z).toNat : ℕ) : ℤ))
    rw [show z + (((s - z).toNat : ℕ) : ℤ) = s from by omega]
    exact hε
  · intro i hi0 him
    change γ ∈ tpOf (ladderModel step pend fwd bwd lab) φ σ (z + (i : ℤ))
    exact hγ (z + (i : ℤ)) (by omega) (by omega)

/-- **CONDITION (4) OF `Real`**: the past-directed mirror, along the reversed `relK`. The
discharge path is the stretch `z, z - 1, …, z - m` of the same history, with
`snce_mem_tpOf_iff` (`LadderAgree.lean`) supplying the temporal content and
`relK_realItem_succ` the same relation link read backwards. The mirror is available here although
the ladder's STRUCTURAL liveness is forward-only: what is mirrored is the realized type's own
`since` equation along a history, not the `Count`-driven decrease. -/
theorem real_certBwdK (lab : Q → Atom → Bool) (φ : PlusFormula) (Tc Tn P B : ℕ)
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x) :
    certBwdK step pend lab φ Tc Tn P B (Real step pend lab φ Tc Tn P B fwd bwd) := by
  rintro x ⟨c, n, h, t, z, σ, hst, hk, hT⟩ ψ hψx hs
  obtain ⟨γ, ε, rfl⟩ : ∃ γ ε, ψ = PlusFormula.snce γ ε := by
    cases ψ <;> first | exact ⟨_, _, rfl⟩ | simp [isSnce] at hs
  have hcl : PlusFormula.snce γ ε ∈ plusSubformulaClosure φ :=
    Finset.mem_powerset.mp x.2.1.property hψx
  have hx : realItem step pend lab φ Tc Tn P B fwd bwd σ z = x :=
    realItem_eq_of_witness lab φ Tc Tn P B fwd bwd hst hk hT
  have hmem : PlusFormula.snce γ ε ∈ tpOf (ladderModel step pend fwd bwd lab) φ σ z := by
    rw [hT]; exact hψx
  obtain ⟨s, hsz, hε, hγ⟩ :=
    (snce_mem_tpOf_iff (ladderModel step pend fwd bwd lab) φ σ z hcl).mp hmem
  refine ⟨(z - s).toNat,
    fun i => realItem step pend lab φ Tc Tn P B fwd bwd σ (z - (i : ℤ)), by omega, ?_,
    fun i _ => mem_real_realItem lab φ Tc Tn P B fwd bwd σ _, fun i _ => ⟨?_, ?_⟩, ?_, ?_⟩
  · simpa using hx
  · have hrel := relK_realItem_succ lab φ Tc Tn P B fwd bwd σ (z - ((i : ℤ) + 1))
    change relK step pend lab φ Tc Tn P B
      (realItem step pend lab φ Tc Tn P B fwd bwd σ (z - ((i + 1 : ℕ) : ℤ)))
      (realItem step pend lab φ Tc Tn P B fwd bwd σ (z - (i : ℤ)))
    rw [show z - ((i + 1 : ℕ) : ℤ) = z - ((i : ℤ) + 1) from by push_cast; ring,
      show z - (i : ℤ) = (z - ((i : ℤ) + 1)) + 1 from by ring]
    exact hrel
  · exact mem_real_realItem lab φ Tc Tn P B fwd bwd σ _
  · change ε ∈ tpOf (ladderModel step pend fwd bwd lab) φ σ (z - (((z - s).toNat : ℕ) : ℤ))
    rw [show z - (((z - s).toNat : ℕ) : ℤ) = s from by omega]
    exact hε
  · intro i hi0 him
    change γ ∈ tpOf (ladderModel step pend fwd bwd lab) φ σ (z - (i : ℤ))
    exact hγ (z - (i : ℤ)) (by omega) (by omega)

end Realizable

end FormalSystem.Metalogic.Decidability.RaySummary
