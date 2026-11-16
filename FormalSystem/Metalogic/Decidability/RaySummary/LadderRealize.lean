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

-- The module's recorded length ceiling: the offset-invariance section takes the file past the
-- default limit.
set_option linter.style.longFile 2300

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

/-! ## Route (P-2): the certificate-side bridge, and what `certStabK` of `Real` actually asks for

**THE DESIGN GATE'S RECORD.** This section is the whole of the bounded design round route (P-2)
is entered through, and its deliverable is a VERDICT backed by compiled objects rather than a
transport, a certificate condition or an agreement. Nothing above this section is re-opened,
weakened or re-proved by it, and no second measurement round is bought by it.

**THE VERDICT: OUTCOME (iii) — THE OBLIGATION IS NAMED AND THE TRANSPORT IS OPEN.** The two legs
landed as compiled objects, and the third possible outcome — a refutation at the
register-displaced instances, which would close route (P-2) — was NOT reached: no object below
refutes anything, and none is claimed to.

### LEG A, the obligation, named — and the two directions are NOT symmetric

`certStabK`'s clause at a member `x` is an IFF
(`ψ ∈ x.2.1.val ↔ ∀ y ∈ R, y.1 = x.1 → y.2.2 = x.2.2 → argOf ψ ∈ y.2.1.val`), and the finding of
this leg is that only ONE of its two directions needs anything transported at all.

* **`⟸` (the right-hand side forces the letter) needs NO transfer whatever, and is landed
  UNCONDITIONALLY**: `real_certStabK_mpr`. Its pair set is the fibre of `Real` over the member's
  OWN `(q, κ)` read at the member's OWN ladder state: every history through `σ.state z` projects
  by `mem_real_realItem` into `Real` at the same object component and the same class, so the
  right-hand side already says the `⊡` argument lies in every type of that one cell, which is
  `stab_mem_tpOf_iff_cell`'s left-hand side. **It ranges over NO register-displaced pair**: the
  counter pair `(c, n)` it quantifies at is literally the member's own, so the direction is
  discharged by `Real`'s definition and by nothing else. This is what the four path-level rounds
  never measured, and it halves the obligation.
* **`⟹` (the letter forces the right-hand side) is the direction that carries the transfer**:
  `real_certStabK_mp_of_cell_stab_transfer`. Its pair set is every pair of admissible ladder
  states `(q, c, n)` and `(q, c', n')` at the SAME object component whose counter classes agree
  under `kappa Tc Tn P B`, and the obligation it consumes is the CELL-SIDE transfer written out
  in its own hypothesis binder: if the `⊡` argument lies in every type of the cell at `(q, c, n)`,
  it lies in every type of the cell at `(q, c', n')`.

`real_certStabK_of_cell_stab_transfer` is the two directions joined: `certStabK` of `Real` from
that one cell-side hypothesis, with no parameter condition and no relation on position pairs
anywhere in it.

### LEG A, the scope reading: the obligation's pair set DOES contain register-displaced collisions

Stated loudly, because the opposite finding would have been the prize of this round. The domain
of the `⟹` direction's hypothesis contains pairs with the same object component, the same
countdown `c`, the same admissibility witness and `n ≠ n'`: `kappa_eq_register_displaced`
exhibits the class equality at `n' = n + (P + 1)` whenever `Tn ≤ n` and `c + B ≤ n`, and
`register_displaced_collision_in_domain` exhibits the two DISTINCT admissible ladder states that
carry it. So the certificate side does ask for what the path-level rounds were trying to deliver,
and it asks for it at a FIXED countdown, where the displacement is in the register coordinate
alone.

### LEG B, the transport, decided: OPEN

`ClassRepTransport` states the class-representative transport at the shape the obligation needs —
at the HISTORY level, not as a correspondence between positions: every closure type realized at
`(q, c', n')` is realized at `(q, c, n)` whenever the two counter pairs share a `kappa` class. It
is a HYPOTHESIS this section decides, never a premise it carries, and its own body is the goal
state the verdict records: from a history whose state at `z'` is `(t', ⟨(q, c', n'), _⟩)`,
produce one whose state at `z` is `(t, ⟨(q, c, n), _⟩)` realizing the same closure type.

`cell_stab_transfer_of_classRepTransport` compiles the implication from it to LEG A's obligation,
and `real_certStabK_of_classRepTransport` is the bridge end to end. **The transport itself is
neither proved nor refuted here, and the coordinate that refuses it is named**: the REGISTER. At
the register-displaced instances above the countdown is held fixed while `n` moves by `P + 1`,
and the one landed tool that produces `kappa`-collisions — `kappa_eq_of_shift`, the COMMON
downward shift of both counters by a multiple of `P + 1`, with `clipIdx_sub_sub` its gap half —
provably does not reach them: `register_displaced_ne_common_shift`. The gap between the
obligation's domain and the landed collision tool is therefore a compiled object rather than an
assessment.

### What this measurement does NOT say

It is not a transport and proves none, since LEG B landed none. It asserts no cell equality and
no agreement of class-equivalent cells. It claims neither the admissibility of `Real` under the
parameter conditions, nor any inclusion between `Real` and `Dmax` in either direction — those are
other phases' and are untouched here. It defines no relation on position pairs and carries no
register conjunct on one, the clipped gap included. It does not re-open, weaken or supersede any
landed measurement of the register discriminator or of the pending-state readings; every one of
those declarations is byte-identical to its landed form. And it revives no path-level route.

### The path-level closure, recorded in its honest form

Four register readings were MEASURED — the clipped reading, the Drift-distance reading, dropping
the register conjunct, and the gap reading — and each failed one of the two sides a position-pair
relation has to pass: delivery by the iterated splice at the window's interior, and consumption
by the `⊡` bit. The path level was closed on exactly that evidence, by the recorded ruling. That
is the whole of the claim: nothing here asserts a general impossibility at that level, and the
completeness of the gap reading is not settled by it.
-/

section CertificateBridge

variable {Q : Type} [Finite Q] [Nonempty Q] {step : Q → Q → Bool} {pend : Q → Bool}

/-- **LEG A, THE DIRECTION THAT NEEDS NO TRANSFER.** The `⟸` half of `certStabK`'s clause at a
member of `Real`, landed UNCONDITIONALLY: if the `⊡` argument lies in the closure type of every
member of `Real` sharing the object component and the counter class, then the `⊡` letter itself
lies in the member's own type. Its pair set is the member's own cell and nothing else — every
history through the member's witnessing state projects into `Real` at the same `(q, κ)` by
`mem_real_realItem` — so no register-displaced pair is in its range and no cell transfer enters
its proof. -/
theorem real_certStabK_mpr (lab : Q → Atom → Bool) (φ : PlusFormula) (Tc Tn P B : ℕ)
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (x : Q × ClType φ × CK Tc Tn P B)
    (hx : x ∈ Real step pend lab φ Tc Tn P B fwd bwd)
    (ψ : PlusFormula) (hψ : ψ ∈ plusSubformulaClosure φ) (hs : isStab ψ = true)
    (H : ∀ y ∈ Real step pend lab φ Tc Tn P B fwd bwd, y.1 = x.1 → y.2.2 = x.2.2 →
      argOf ψ ∈ y.2.1.val) :
    ψ ∈ x.2.1.val := by
  obtain ⟨χ, rfl⟩ : ∃ χ, ψ = PlusFormula.stab χ := by
    cases ψ <;> first | exact ⟨_, rfl⟩ | simp [isStab] at hs
  obtain ⟨c, n, h, t, z, σ, hst, hk, hT⟩ := hx
  rw [← hT, stab_mem_tpOf_iff_cell (ladderModel step pend fwd bwd lab) φ σ z hψ]
  rintro T ⟨σ', hs', rfl⟩
  have hmem := mem_real_realItem lab φ Tc Tn P B fwd bwd σ' z
  have h1 : (realItem step pend lab φ Tc Tn P B fwd bwd σ' z).1 = x.1 := by
    change (σ'.state z).2.1.1 = x.1
    rw [hs', hst]
  have h2 : (realItem step pend lab φ Tc Tn P B fwd bwd σ' z).2.2 = x.2.2 := by
    change kappa Tc Tn P B ((σ'.state z).2.1.2.1, (σ'.state z).2.1.2.2) = x.2.2
    rw [hs', hst]; exact hk
  exact H _ hmem h1 h2

/-- **LEG A, THE DIRECTION THAT CARRIES THE TRANSFER.** The `⟹` half, from the CELL-SIDE
obligation written out in its own binder: for two admissible ladder states at the same object
component whose counter pairs share a `kappa` class, a formula lying in every closure type of the
cell at the first lies in every closure type of the cell at the second. Its pair set is exactly
that family of class-equal pairs, and it DOES contain register-displaced ones
(`register_displaced_collision_in_domain`). -/
theorem real_certStabK_mp_of_cell_stab_transfer (lab : Q → Atom → Bool) (φ : PlusFormula)
    (Tc Tn P B : ℕ)
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (hcell : ∀ (q : Q) (c n c' n' : ℕ) (hq : c ∈ Adm pend q) (hq' : c' ∈ Adm pend q)
      (t t' z z' : ℤ) (χ : PlusFormula),
      kappa Tc Tn P B (c, n) = kappa Tc Tn P B (c', n') →
      (∀ T ∈ cellAt (ladderModel step pend fwd bwd lab) φ
          ((t, ⟨(q, c, n), hq⟩) : (ladderFrameAdm step pend fwd bwd).WorldState) z, χ ∈ T) →
      (∀ T ∈ cellAt (ladderModel step pend fwd bwd lab) φ
          ((t', ⟨(q, c', n'), hq'⟩) : (ladderFrameAdm step pend fwd bwd).WorldState) z', χ ∈ T))
    (x : Q × ClType φ × CK Tc Tn P B)
    (hx : x ∈ Real step pend lab φ Tc Tn P B fwd bwd)
    (ψ : PlusFormula) (hψ : ψ ∈ plusSubformulaClosure φ) (hs : isStab ψ = true)
    (H : ψ ∈ x.2.1.val) :
    ∀ y ∈ Real step pend lab φ Tc Tn P B fwd bwd, y.1 = x.1 → y.2.2 = x.2.2 →
      argOf ψ ∈ y.2.1.val := by
  obtain ⟨χ, rfl⟩ : ∃ χ, ψ = PlusFormula.stab χ := by
    cases ψ <;> first | exact ⟨_, rfl⟩ | simp [isStab] at hs
  obtain ⟨c, n, h, t, z, σ, hst, hk, hT⟩ := hx
  have Hc : ∀ T ∈ cellAt (ladderModel step pend fwd bwd lab) φ
      ((t, ⟨(x.1, c, n), h⟩) : (ladderFrameAdm step pend fwd bwd).WorldState) z, χ ∈ T := by
    have hmem : PlusFormula.stab χ ∈ tpOf (ladderModel step pend fwd bwd lab) φ σ z := by
      rw [hT]; exact H
    have hcl := (stab_mem_tpOf_iff_cell (ladderModel step pend fwd bwd lab) φ σ z hψ).mp hmem
    rwa [hst] at hcl
  rintro ⟨q, Ty, ky⟩ ⟨c', n', h', t', z', σ', hst', hk', hT'⟩ hy1 hy2
  dsimp only at hy1 hy2 h' hst' hk' hT' ⊢
  subst hy1
  have hkeq : kappa Tc Tn P B (c, n) = kappa Tc Tn P B (c', n') := by
    rw [hk, ← hy2, ← hk']
  exact hcell x.1 c n c' n' h h' t t' z z' χ hkeq Hc Ty.val ⟨σ', hst', hT'⟩

/-- **LEG A'S PRODUCT: `certStabK` of `Real` FROM THE CELL-SIDE OBLIGATION.** The reduction the
certificate-side bridge is, with the obligation's quantifier domain written out in the hypothesis
binder rather than abbreviated: condition (5) of `Real` holds as soon as a formula lying in every
closure type of one cell lies in every closure type of every class-equal cell at the same object
component. No parameter condition enters, no relation on position pairs is defined, and neither
half of the bundle is weakened. -/
theorem real_certStabK_of_cell_stab_transfer (lab : Q → Atom → Bool) (φ : PlusFormula)
    (Tc Tn P B : ℕ)
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (hcell : ∀ (q : Q) (c n c' n' : ℕ) (hq : c ∈ Adm pend q) (hq' : c' ∈ Adm pend q)
      (t t' z z' : ℤ) (χ : PlusFormula),
      kappa Tc Tn P B (c, n) = kappa Tc Tn P B (c', n') →
      (∀ T ∈ cellAt (ladderModel step pend fwd bwd lab) φ
          ((t, ⟨(q, c, n), hq⟩) : (ladderFrameAdm step pend fwd bwd).WorldState) z, χ ∈ T) →
      (∀ T ∈ cellAt (ladderModel step pend fwd bwd lab) φ
          ((t', ⟨(q, c', n'), hq'⟩) : (ladderFrameAdm step pend fwd bwd).WorldState) z', χ ∈ T)) :
    certStabK φ Tc Tn P B (Real step pend lab φ Tc Tn P B fwd bwd) := by
  intro x hx ψ hψ hs
  exact ⟨fun H => real_certStabK_mp_of_cell_stab_transfer lab φ Tc Tn P B fwd bwd hcell x hx
      ψ hψ hs H,
    fun H => real_certStabK_mpr lab φ Tc Tn P B fwd bwd x hx ψ hψ hs H⟩

/-! ### The scope reading: register-displaced collisions are inside the obligation's domain -/

/-- **THE REGISTER-DISPLACED COLLISION, AT A FIXED COUNTDOWN.** Raising the register alone by the
modulus `P + 1` leaves all five `kappa` coordinates alone once the register is at or above its own
threshold and the gap is saturated: the two countdown coordinates are untouched because `c` does
not move, the register's clipped coordinate is pinned at `Tn`, its residue is unmoved by a
multiple of the modulus, and the gap is pinned at `B` because `c + B ≤ n`. So the obligation's
pair set contains pairs that differ in the REGISTER and in nothing else. -/
theorem kappa_eq_register_displaced (Tc Tn P B c n : ℕ) (hn : Tn ≤ n) (hB : c + B ≤ n) :
    kappa Tc Tn P B (c, n + (P + 1)) = kappa Tc Tn P B (c, n) := by
  have h1 : min (n + (P + 1)) Tn = min n Tn := by omega
  have h2 : (n + (P + 1)) % (P + 1) = n % (P + 1) := by
    simp [Nat.add_mod_right]
  have h3 : clipIdx B c (n + (P + 1)) = clipIdx B c n := by
    unfold clipIdx; split <;> split <;> omega
  simp only [kappa, h1, h2, h3]

omit [Finite Q] [Nonempty Q] in
/-- **THE SAME COLLISION, READ IN THE OBLIGATION'S OWN DOMAIN.** Two DISTINCT admissible ladder
states at the same object component, sharing one admissibility witness because the countdown does
not move, whose counter classes agree. This is the compiled object behind the scope reading: the
cell-side obligation `real_certStabK_of_cell_stab_transfer` consumes is asked at pairs of this
shape, so route (P-2) does not avoid the register-displaced instances. -/
theorem register_displaced_collision_in_domain (Tc Tn P B : ℕ) (q : Q) (c n : ℕ)
    (hq : c ∈ Adm pend q) (hn : Tn ≤ n) (hB : c + B ≤ n) :
    kappa Tc Tn P B (c, n + (P + 1)) = kappa Tc Tn P B (c, n) ∧
      (⟨(q, c, n + (P + 1)), hq⟩ : LadderState Q pend) ≠ ⟨(q, c, n), hq⟩ := by
  refine ⟨kappa_eq_register_displaced Tc Tn P B c n hn hB, ?_⟩
  intro hcon
  have h2 : n + (P + 1) = n :=
    congrArg (fun s : LadderState Q pend => s.1.2.2) hcon
  omega

/-- **THE LANDED COLLISION TOOL DOES NOT REACH THEM.** `kappa_eq_of_shift` produces its
collisions by shifting BOTH counters down by a common multiple of `P + 1`; the register-displaced
pair above holds the countdown fixed. So no instance of the common shift is that pair, and the
gap between the obligation's domain and the one landed tool for populating it is a compiled
object rather than an assessment. This names the coordinate that refuses the transport and
asserts nothing about whether the transport holds. -/
theorem register_displaced_ne_common_shift (P c n m : ℕ) (hm : 0 < m) :
    ((c, n + (P + 1)) : ℕ × ℕ) ≠ (c + m * (P + 1), n + m * (P + 1)) := by
  intro hcon
  have h1 : c = c + m * (P + 1) := congrArg Prod.fst hcon
  have hpos : 0 < m * (P + 1) := Nat.mul_pos hm (Nat.succ_pos P)
  omega

/-! ### LEG B: the class-representative transport, stated and left OPEN -/

/-- **THE CLASS-REPRESENTATIVE TRANSPORT.** The shape route (P-2)'s name points at, at the
HISTORY level: every closure type realized at an admissible ladder state is realized at every
class-equal ladder state with the same object component. Its body IS the goal state this round's
verdict records — from a history whose state at `z'` is `(t', ⟨(q, c', n'), _⟩)`, produce one
whose state at `z` is `(t, ⟨(q, c, n), _⟩)` carrying the same closure type — and it is a
HYPOTHESIS, never a premise carried by anything above. It is not a correspondence between
positions of two paths and defines no relation on position pairs. -/
def ClassRepTransport (step : Q → Q → Bool) (pend : Q → Bool) (lab : Q → Atom → Bool)
    (φ : PlusFormula) (Tc Tn P B : ℕ)
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x) : Prop :=
  ∀ (q : Q) (c n c' n' : ℕ) (hq : c ∈ Adm pend q) (hq' : c' ∈ Adm pend q) (t t' z z' : ℤ),
    kappa Tc Tn P B (c, n) = kappa Tc Tn P B (c', n') →
    cellAt (ladderModel step pend fwd bwd lab) φ
        ((t', ⟨(q, c', n'), hq'⟩) : (ladderFrameAdm step pend fwd bwd).WorldState) z' ⊆
      cellAt (ladderModel step pend fwd bwd lab) φ
        ((t, ⟨(q, c, n), hq⟩) : (ladderFrameAdm step pend fwd bwd).WorldState) z

/-- **THE TRANSPORT DELIVERS LEG A'S OBLIGATION.** One line, and that is the point: the
certificate side asks only that a formula true throughout one cell be true throughout every
class-equal cell, and a transport of realized types in the opposite direction gives exactly
that. -/
theorem cell_stab_transfer_of_classRepTransport (lab : Q → Atom → Bool) (φ : PlusFormula)
    (Tc Tn P B : ℕ)
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (htr : ClassRepTransport step pend lab φ Tc Tn P B fwd bwd) :
    ∀ (q : Q) (c n c' n' : ℕ) (hq : c ∈ Adm pend q) (hq' : c' ∈ Adm pend q)
      (t t' z z' : ℤ) (χ : PlusFormula),
      kappa Tc Tn P B (c, n) = kappa Tc Tn P B (c', n') →
      (∀ T ∈ cellAt (ladderModel step pend fwd bwd lab) φ
          ((t, ⟨(q, c, n), hq⟩) : (ladderFrameAdm step pend fwd bwd).WorldState) z, χ ∈ T) →
      (∀ T ∈ cellAt (ladderModel step pend fwd bwd lab) φ
          ((t', ⟨(q, c', n'), hq'⟩) : (ladderFrameAdm step pend fwd bwd).WorldState) z',
            χ ∈ T) := by
  intro q c n c' n' hq hq' t t' z z' χ hk Hc T hTmem
  exact Hc T (htr q c n c' n' hq hq' t t' z z' hk hTmem)

/-- **THE BRIDGE, END TO END.** Condition (5) of `Real` from the class-representative transport
alone. The transport is OPEN — this round neither proves nor refutes it — so this is a reduction
and not a discharge, and nothing downstream may read it as one. -/
theorem real_certStabK_of_classRepTransport (lab : Q → Atom → Bool) (φ : PlusFormula)
    (Tc Tn P B : ℕ)
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (htr : ClassRepTransport step pend lab φ Tc Tn P B fwd bwd) :
    certStabK φ Tc Tn P B (Real step pend lab φ Tc Tn P B fwd bwd) :=
  real_certStabK_of_cell_stab_transfer lab φ Tc Tn P B fwd bwd
    (cell_stab_transfer_of_classRepTransport lab φ Tc Tn P B fwd bwd htr)

/-! ### Phase 11.26, BRANCH OPEN: the transport on the register-RAISE regime, and the two
coordinates that refuse it outside that regime

**THE BRANCH IS READ OFF PHASE 11.25'S RECORDED OUTCOME, AND IT IS OPEN.** Phase 11.25 recorded
outcome (iii) — the obligation named, the transport neither proved nor refuted — so this section
is on branch OPEN: it attempts `ClassRepTransport` on its own ground and records, as compiled
objects, exactly how far the landed machinery reaches and which coordinate refuses the rest.

**WHAT THE LANDED MACHINERY DELIVERS.** The one tool that moves a register at a HELD countdown is
`exists_ladderPath_through_deleted_exact_raised_upfirst_of_pend_past` at `m = 0`: the exact-shift
deletion with nothing deleted, which re-lifts the ORIGINAL walk and countdown at a prescribed
anchor value. `exists_ladderPath_register_raised_at_held_countdown` is that instance, named, and
`cellAt_subset_of_register_raise` is the cell-level inclusion it yields — a transport in exactly
`ClassRepTransport`'s direction, with every room condition an explicit named binder.

**THE REGIME IT COVERS, AND THE REGIME IT DOES NOT.** It covers the DOWNWARD-saturated
register-displaced collisions: pairs `(c, n)`, `(c, n')` at a held countdown with
`Tn ≤ n' ≤ n`, `n ≡ n' [MOD P + 1]` and `n + B ≤ c`, which `kappa_eq_register_raise_down` shows
are `kappa`-collisions. It does NOT cover the UPWARD-saturated ones — the family Phase 11.25's
`register_displaced_collision_in_domain` exhibits inside the obligation's own domain, at
`c + B ≤ n` — and the exclusion is an inequality rather than an assessment:
`raise_room_excludes_upward_displacement` is the compiled contradiction between the raise tool's
room ceiling `n₀ + 2 ≤ cntAt g z` and that family's `c + B ≤ n₀`.

**THE SECOND, INDEPENDENT COORDINATE THAT REFUSES IT: the `⊡` letters themselves.** Both
register-moving deletions carry the stab-free premise
`hno : ∀ χ, PlusFormula.stab χ ∉ plusSubformulaClosure φ`, so the transport landed here is
available only at a stab-free closure — and `certStabK_of_stabFree` is the compiled object
showing that at exactly those `φ` the obligation the bridge consumes is VACUOUS. So the
inclusion below is a real transport over a real family of `kappa`-collisions, and it buys the
certificate side nothing: the regime it covers is the regime in which condition (5) asks nothing.

**WHAT THIS SECTION DOES NOT SAY.** It is not a cell AGREEMENT and asserts none — every statement
below is a one-directional inclusion under named room conditions, never an equality of cells. It
is not `certStabK` of `Real` and claims none: `certStabK_of_stabFree` is the vacuous case and
nothing else. It is not a position-pair correspondence and defines no relation on position pairs;
no register conjunct on such a pair appears, the clipped gap included. It does not discharge
`ClassRepTransport`, which remains OPEN exactly as Phase 11.25 left it, and it discharges neither
`real_certAdmK_of_paramsOk`, `real_subset_dmax` nor `Dmax ⊆ Real`. It re-opens, weakens and
supersedes no landed measurement of Phases 11.20 or 11.23.

**A THIRD GAP, RECORDED RATHER THAN CLOSED.** The inclusion is stated at the DIAGONAL world state
`(z, ⟨(q, c, n), h⟩)` evaluated at `z` — the shape `CellLEZeroConstOfKappaEq` and
`mem_cellAt_ladder_iff` use — while `real_certStabK_of_cell_stab_transfer`'s `hcell` binder is at
the general `(t, ⟨(q, c, n), h⟩)` evaluated at `z`. Bridging the two is an offset-invariance of
`tpOf` under the ladder model, which is an induction over the closure and is NOT landed here. -/

/-- **THE `kappa`-COLLISIONS THE REGISTER RAISE REACHES: downward-saturated, countdown held.**
Two registers above the register threshold, congruent modulo the period, both at or below the
countdown by at least the gap clip, give the same class: the countdown coordinates are untouched,
the clipped register coordinate is pinned at `Tn`, the residues agree by hypothesis, and the gap
coordinate is pinned at `0` because each register sits at least `B` below the countdown. This is
the family `cellAt_subset_of_register_raise` transports across, and it is DISJOINT from the
family `register_displaced_collision_in_domain` exhibits. -/
theorem kappa_eq_register_raise_down (Tc Tn P B c n n' : ℕ)
    (hTn : Tn ≤ n') (hle : n' ≤ n) (hres : n % (P + 1) = n' % (P + 1))
    (hgap : n + B ≤ c) :
    kappa Tc Tn P B (c, n) = kappa Tc Tn P B (c, n') := by
  have h1 : min n Tn = min n' Tn := by omega
  have h3 : clipIdx B c n = clipIdx B c n' := by
    unfold clipIdx; split <;> split <;> omega
  simp only [kappa, h1, h3, hres]

/-- **THE ROOM CEILING EXCLUDES THE UPWARD-SATURATED FAMILY, AS AN INEQUALITY.** The register
raise delivers its prescribed anchor only under `n₀ + 2 ≤ cntAt g z`; the collisions Phase 11.25
exhibited inside the obligation's domain carry `c + B ≤ n₀` at the same countdown `c`. The two
are contradictory, so the one landed tool that holds a countdown fixed cannot reach a single pair
of that family. This names the coordinate that refuses the transport — the REGISTER — and the
inequality that refuses it; it asserts nothing about whether the transport holds there. -/
theorem raise_room_excludes_upward_displacement (B c n₀ : ℕ) (hB : c + B ≤ n₀) :
    ¬ (n₀ + 2 ≤ c) := by omega

omit [Finite Q] [Nonempty Q] in
/-- **CONDITION (5) IS VACUOUS AT A STAB-FREE CLOSURE.** Every set whatever satisfies `certStabK`
when no `⊡` letter lies in the closure, because the clause's own quantifier is empty. Compiled
here because it is what fixes the standing of the transport below: the register-moving deletions
carry the stab-free premise, so the regime in which the transport is available is exactly the
regime in which the obligation it would discharge asks nothing. -/
theorem certStabK_of_stabFree (φ : PlusFormula) (Tc Tn P B : ℕ)
    (hno : ∀ χ : PlusFormula, PlusFormula.stab χ ∉ plusSubformulaClosure φ)
    (R : Set (Q × ClType φ × CK Tc Tn P B)) :
    certStabK φ Tc Tn P B R := by
  intro x _ ψ hψ hs
  obtain ⟨χ, rfl⟩ : ∃ χ, ψ = PlusFormula.stab χ := by
    cases ψ <;> first | exact ⟨_, rfl⟩ | simp [isStab] at hs
  exact absurd hψ (hno χ)

/-- **THE REGISTER RAISE AT A HELD COUNTDOWN.** The exact-shift raised deletion at `m = 0`:
nothing is deleted, so the countdown at `z` is held rather than lowered, the object state is
held, the realized stab-free type at `z` is held, and the register is delivered at the prescribed
value `n₀`. Its room conditions are the tool's own, with `m = 0` substituted: the raise
`nxtAt g z ≤ n₀`, the threshold `Tc ≤ cntAt g z`, the room `n₀ + 2 ≤ cntAt g z`, and the regime
`HasForwardSlack g z 0 (nxtAt g z)`. Nothing here is new machinery — the point of naming the
instance is that `m = 0` is the ONLY instance that holds a countdown fixed, and a held countdown
is what a register-displaced `kappa`-collision asks for. -/
theorem exists_ladderPath_register_raised_at_held_countdown [Fintype Q]
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (lab : Q → Atom → Bool) (φ : PlusFormula) (Tc Tn P B : ℕ)
    (hp : ParamsOk step pend lab φ Tc Tn P B)
    (hno : ∀ χ : PlusFormula, PlusFormula.stab χ ∉ plusSubformulaClosure φ)
    (g : ℤ → LadderState Q pend) (hg : IsLadderPath step pend g) (z : ℤ)
    (hpast : ∀ p : ℤ, p ≤ z → pend (objAt g p) = true)
    (n₀ : ℕ) (hraise : nxtAt g z ≤ n₀)
    (hTc : Tc ≤ cntAt g z) (hroom : n₀ + 2 ≤ cntAt g z)
    (hslack : HasForwardSlack g z 0 (nxtAt g z)) :
    ∃ g' : ℤ → LadderState Q pend, IsLadderPath step pend g' ∧
      objAt g' z = objAt g z ∧ cntAt g' z = cntAt g z ∧ nxtAt g' z = n₀ ∧
      ∀ (σ σ' : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame),
        (∀ t : ℤ, σ.state t = (t, g t)) →
        (∀ t : ℤ, σ'.state t = (t, g' t)) →
        tpOf (ladderModel step pend fwd bwd lab) φ σ' z
          = tpOf (ladderModel step pend fwd bwd lab) φ σ z := by
  have hz : (0 : ℕ) * (P + 1) = 0 := Nat.zero_mul _
  obtain ⟨g', hg', hobj, hcnt, hnxt, hty⟩ :=
    exists_ladderPath_through_deleted_exact_raised_upfirst_of_pend_past step pend fwd bwd lab φ
      Tc Tn P B hp hno g hg z hpast 0 n₀ hraise (by rw [hz]; omega) (by rw [hz]; omega)
      (by rw [hz]; exact hslack)
  exact ⟨g', hg', hobj, by rw [hz] at hcnt; omega, hnxt, hty⟩

/-- **THE TRANSPORT, OVER THE REGIME THE RAISE COVERS.** `ClassRepTransport`'s inclusion at the
diagonal world state, between two ladder states differing in the REGISTER alone, with the
`kappa`-collision carried as the FIRST conjunct of the conclusion rather than assumed — so the
statement is a transport between CLASS-EQUAL states and every one of its collision binders is
load-bearing. Note what the second conjunct's own proof shows: the inclusion follows from the
raise tool and the room conditions ALONE, and consumes neither `hTn` nor `hres`. The class
equality is therefore a certificate that the two states are the pair the certificate side asks
about, not an input to the surgery. Every room condition is an explicit named binder: the
downward-saturated collision conditions (`hTn`, `hle`, `hres`, `hgap`), the threshold `hTc`, and
the per-path regime `hreg` the raise tool asks of every path through the source state — a
pending past at `z` and forward slack at amount `0`. The narrowing is deliberate and is recorded
in the section docstring above: this is NOT `ClassRepTransport`, which quantifies over every
class-equal pair with no room condition and no regime hypothesis, and which remains OPEN. -/
theorem cellAt_subset_of_register_raise [Fintype Q]
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (lab : Q → Atom → Bool) (φ : PlusFormula) (Tc Tn P B : ℕ)
    (hp : ParamsOk step pend lab φ Tc Tn P B)
    (hno : ∀ χ : PlusFormula, PlusFormula.stab χ ∉ plusSubformulaClosure φ)
    (q : Q) (c n n' : ℕ) (hq : c ∈ Adm pend q) (z : ℤ)
    (hTn : Tn ≤ n') (hle : n' ≤ n) (hres : n % (P + 1) = n' % (P + 1))
    (hgap : n + B ≤ c) (hTc : Tc ≤ c) (hB : 2 ≤ B)
    (hreg : ∀ g : ℤ → LadderState Q pend, IsLadderPath step pend g →
      g z = (⟨(q, c, n'), hq⟩ : LadderState Q pend) →
      (∀ p : ℤ, p ≤ z → pend (objAt g p) = true) ∧ HasForwardSlack g z 0 n') :
    kappa Tc Tn P B (c, n) = kappa Tc Tn P B (c, n') ∧
      cellAt (ladderModel step pend fwd bwd lab) φ
          ((z, ⟨(q, c, n'), hq⟩) : (ladderFrameAdm step pend fwd bwd).WorldState) z ⊆
        cellAt (ladderModel step pend fwd bwd lab) φ
          ((z, ⟨(q, c, n), hq⟩) : (ladderFrameAdm step pend fwd bwd).WorldState) z := by
  refine ⟨kappa_eq_register_raise_down Tc Tn P B c n n' hTn hle hres hgap, ?_⟩
  intro T hT
  obtain ⟨g, τ, hg, hgz, hτ, hTy⟩ :=
    (mem_cellAt_ladder_iff fwd bwd lab φ (⟨(q, c, n'), hq⟩ : LadderState Q pend) z T).mp hT
  obtain ⟨hpast, hslack⟩ := hreg g hg hgz
  have hobjz : objAt g z = q := by rw [objAt, hgz]
  have hcntz : cntAt g z = c := by rw [cntAt, hgz]
  have hnxtz : nxtAt g z = n' := by rw [nxtAt, hgz]
  obtain ⟨g', hg', hobj, hcnt, hnxt, hty⟩ :=
    exists_ladderPath_register_raised_at_held_countdown fwd bwd lab φ Tc Tn P B hp hno g hg z
      hpast n (by omega) (by omega) (by omega) (by rw [hnxtz]; exact hslack)
  obtain ⟨τ', hτ'⟩ := exists_hist_of_isLadderPath fwd bwd g' hg'
  refine (mem_cellAt_ladder_iff fwd bwd lab φ (⟨(q, c, n), hq⟩ : LadderState Q pend) z T).mpr
    ⟨g', τ', hg', ?_, hτ', ?_⟩
  · apply Subtype.ext
    refine Prod.ext (show objAt g' z = q from hobj.trans hobjz) (Prod.ext ?_ ?_)
    · change cntAt g' z = c
      omega
    · change nxtAt g' z = n
      exact hnxt
  · rw [hty τ τ' hτ hτ', hTy]

/-! ### Phase 11.27: the composition over the COVERED collisions, and what it buys

**THE COVERED COLLISION SET, READ OFF PHASE 11.26'S RECORDED OUTCOME AND STATED BEFORE ANY PROOF
IS ATTEMPTED.** Phase 11.26 closed on branch OPEN with a transport over a NARROWED regime. The
collisions it covers are exactly these, and this section quantifies over no others:

* the DOWNWARD-saturated register-displaced pairs `(c, n)`, `(c, n')` at a HELD countdown, with
  `Tn ≤ n'`, `n' ≤ n`, `n ≡ n' [MOD P + 1]` and `n + B ≤ c` — the family
  `kappa_eq_register_raise_down` exhibits as `kappa`-collisions;
* at the DIAGONAL world state `(z, ⟨(q, c, n), hq⟩)` evaluated at `z`, never at a general time
  component — the third gap Phase 11.26 recorded rather than closed;
* at a STAB-FREE closure `φ`, because both register-moving deletions carry
  `hno : ∀ χ, PlusFormula.stab χ ∉ plusSubformulaClosure φ`;
* under the per-path regime each direction's tool asks of the paths through its own source state.

**Register-displaced collisions in the UPWARD-saturated family are NOT covered**, by
`raise_room_excludes_upward_displacement`, and `ClassRepTransport` itself remains OPEN.

**WHICH HYPOTHESIS OF THE REDUCTION THE TRANSPORT DISCHARGES, AND WHICH IT LEAVES STANDING — the
table Phase 11.7 inherits.** `real_certStabK_of_cell_stab_transfer` carries ONE hypothesis,
`hcell`, universally quantified over `q`, `c`, `n`, `c'`, `n'`, `t`, `t'`, `z`, `z'` with
`kappa Tc Tn P B (c, n) = kappa Tc Tn P B (c', n')`.

| Coordinate of `hcell`'s domain | Discharged by the transport? |
|---|---|
| the register, downward-saturated, countdown held | **YES**, both orientations (see below) |
| the register, upward-saturated (`c + B ≤ n`) | NO — `raise_room_excludes_upward_displacement` |
| the countdown (`c ≠ c'`) | NO — no tool here moves a countdown while holding a class |
| the time components (`t`, `t'`, `z`, `z'` general) | NO — the diagonal gap, not landed |
| closures carrying a `⊡` letter | NO — the stab-free premise of both deletions |
| paths through the source state outside the regime | NO — `hreg` is an explicit binder |

The YES row is `cell_stab_transfer_of_register_displacement`, in both orientations.

**WHAT THE COMPOSITION BUYS, STATED LOUDLY BECAUSE IT IS THE PHASE'S RESULT.** Over the covered
collisions the composition's `certStabK` conclusion DOES hold — and the transport is NOT
load-bearing in it. The covered regime's own defining premise, stab-freeness, already gives
`certStabK φ Tc Tn P B (Real …)` outright through `certStabK_of_stabFree`, with no transport, no
cell agreement and no parameter condition: `real_certStabK_of_stabFree` is that conclusion at
`Real`, and its proof consumes nothing from this section. So route (P-2)'s composition closes on
the covered set and closes VACUOUSLY there. This is recorded as the measurement it is; it is not
a discharge of condition (5) at any closure carrying a `⊡` letter, and nothing downstream may
read it as one.

**WHAT THIS SECTION DOES NOT SAY.** It does not land `cellAt_const_of_kappa_eq`, which is Phase
11.7's at its filed signature and is NOT landed here under any name. It is not the factorization
lemma. It claims `ClassRepTransport` neither proved nor refuted. It defines no relation on
position pairs and carries no register conjunct on one, the clipped gap included (Ruling 1). It
claims neither `real_certAdmK_of_paramsOk`, nor `real_subset_dmax`, nor `Dmax ⊆ Real`. It does not
derive anything from `ladderSound`, `ladderLift`, `ladderCons_localRun` or any (S)/(C') statement
— the circularity that would close a cycle through Phases 13, 15.1 and 11.7. It takes no new
parameter ruling: `Tc` is not raised, `Tc_d` is not re-based and `ParamsOk` is not strengthened. -/

/-- **THE REGISTER LOWER AT A HELD COUNTDOWN.** The exact-shift LOWERED deletion at `m = 0`, the
mirror of `exists_ladderPath_register_raised_at_held_countdown`: nothing is deleted, so the
countdown at `z` is held, the object state and the realized stab-free type at `z` are held, and
the register is delivered at the prescribed value `n₀ ≤ nxtAt g z`. Its room conditions are the
tool's own with `m = 0` substituted: the lowering budget `n₀ + k = nxtAt g z`, the threshold
`Tc ≤ cntAt g z`, the gap `nxtAt g z + k ≤ cntAt g z`, and the regime
`HasForwardSlack g z k (nxtAt g z)` — at amount `k`, the `k` of the lowering, and not at `0`:
lowering an anchor is paid for in the upper direction of the single anchor inequality where
raising it is free. -/
theorem exists_ladderPath_register_lowered_at_held_countdown [Fintype Q]
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (lab : Q → Atom → Bool) (φ : PlusFormula) (Tc Tn P B : ℕ)
    (hp : ParamsOk step pend lab φ Tc Tn P B)
    (hno : ∀ χ : PlusFormula, PlusFormula.stab χ ∉ plusSubformulaClosure φ)
    (g : ℤ → LadderState Q pend) (hg : IsLadderPath step pend g) (z : ℤ)
    (hpast : ∀ p : ℤ, p ≤ z → pend (objAt g p) = true)
    (n₀ k : ℕ) (hk : n₀ + k = nxtAt g z)
    (hTc : Tc ≤ cntAt g z) (hgap : nxtAt g z + k ≤ cntAt g z)
    (hslack : HasForwardSlack g z k (nxtAt g z)) :
    ∃ g' : ℤ → LadderState Q pend, IsLadderPath step pend g' ∧
      objAt g' z = objAt g z ∧ cntAt g' z = cntAt g z ∧ nxtAt g' z = n₀ ∧
      ∀ (σ σ' : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame),
        (∀ t : ℤ, σ.state t = (t, g t)) →
        (∀ t : ℤ, σ'.state t = (t, g' t)) →
        tpOf (ladderModel step pend fwd bwd lab) φ σ' z
          = tpOf (ladderModel step pend fwd bwd lab) φ σ z := by
  have hz : (0 : ℕ) * (P + 1) = 0 := Nat.zero_mul _
  obtain ⟨g', hg', hobj, hcnt, hnxt, hty⟩ :=
    exists_ladderPath_through_deleted_exact_lowered_upfirst_of_pend_past step pend fwd bwd lab φ
      Tc Tn P B hp hno g hg z hpast 0 n₀ k hk (by rw [hz]; omega) (by rw [hz]; omega)
      (by rw [hz, Nat.zero_add]; exact hslack)
  exact ⟨g', hg', hobj, by rw [hz] at hcnt; omega, hnxt, hty⟩

/-- **THE TRANSPORT'S REVERSE INCLUSION, OVER THE SAME COVERED REGIME.** The mirror of
`cellAt_subset_of_register_raise`, from the HIGHER register to the LOWER one, carried by the
lowered exact-shift deletion at `m = 0`. Its extra room over the raise's is exactly the lowering
budget: `hroom : n + (n - n') ≤ c`, carried as an explicit named binder rather than derived from
`hgap`, because `n - n' ≤ B` is not implied by anything in the covered family's definition. The
regime is at amount `n - n'` and is asked of the paths through the SOURCE state `(q, c, n)`,
which is the other state from the one the raise constrains. -/
theorem cellAt_subset_of_register_lower [Fintype Q]
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (lab : Q → Atom → Bool) (φ : PlusFormula) (Tc Tn P B : ℕ)
    (hp : ParamsOk step pend lab φ Tc Tn P B)
    (hno : ∀ χ : PlusFormula, PlusFormula.stab χ ∉ plusSubformulaClosure φ)
    (q : Q) (c n n' : ℕ) (hq : c ∈ Adm pend q) (z : ℤ)
    (hle : n' ≤ n) (hTc : Tc ≤ c) (hroom : n + (n - n') ≤ c)
    (hreg : ∀ g : ℤ → LadderState Q pend, IsLadderPath step pend g →
      g z = (⟨(q, c, n), hq⟩ : LadderState Q pend) →
      (∀ p : ℤ, p ≤ z → pend (objAt g p) = true) ∧ HasForwardSlack g z (n - n') n) :
    cellAt (ladderModel step pend fwd bwd lab) φ
        ((z, ⟨(q, c, n), hq⟩) : (ladderFrameAdm step pend fwd bwd).WorldState) z ⊆
      cellAt (ladderModel step pend fwd bwd lab) φ
        ((z, ⟨(q, c, n'), hq⟩) : (ladderFrameAdm step pend fwd bwd).WorldState) z := by
  intro T hT
  obtain ⟨g, τ, hg, hgz, hτ, hTy⟩ :=
    (mem_cellAt_ladder_iff fwd bwd lab φ (⟨(q, c, n), hq⟩ : LadderState Q pend) z T).mp hT
  obtain ⟨hpast, hslack⟩ := hreg g hg hgz
  have hobjz : objAt g z = q := by rw [objAt, hgz]
  have hcntz : cntAt g z = c := by rw [cntAt, hgz]
  have hnxtz : nxtAt g z = n := by rw [nxtAt, hgz]
  obtain ⟨g', hg', hobj, hcnt, hnxt, hty⟩ :=
    exists_ladderPath_register_lowered_at_held_countdown fwd bwd lab φ Tc Tn P B hp hno g hg z
      hpast n' (n - n') (by omega) (by omega) (by omega) (by rw [hnxtz]; exact hslack)
  obtain ⟨τ', hτ'⟩ := exists_hist_of_isLadderPath fwd bwd g' hg'
  refine (mem_cellAt_ladder_iff fwd bwd lab φ (⟨(q, c, n'), hq⟩ : LadderState Q pend) z T).mpr
    ⟨g', τ', hg', ?_, hτ', ?_⟩
  · apply Subtype.ext
    refine Prod.ext (show objAt g' z = q from hobj.trans hobjz) (Prod.ext ?_ ?_)
    · change cntAt g' z = c
      omega
    · change nxtAt g' z = n'
      exact hnxt
  · rw [hty τ τ' hτ hτ', hTy]

/-- **THE CELL-LEVEL AGREEMENT OVER THE COVERED COLLISIONS.** Both inclusions of the covered
regime together: the cells of two class-equal ladder states differing in the REGISTER alone, at
the diagonal world state, are EQUAL. This is an agreement over the COVERED set and is NOT the
filed statement `cellAt_const_of_kappa_eq`, which quantifies over every `kappa`-collision at every
time component and at every closure; it is landed here under its own name precisely so that the
difference is visible. Every restriction is an explicit named binder: the downward-saturated
collision conditions (`hTn`, `hle`, `hres`, `hgap`), the threshold `hTc` and the clip `hB`, the
lowering room `hroom`, the stab-free closure `hno`, and the two per-path regimes — one asked of
the paths through each of the two states, because the two directions are carried by different
tools through different source states. -/
theorem cellAt_eq_of_register_displacement [Fintype Q]
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (lab : Q → Atom → Bool) (φ : PlusFormula) (Tc Tn P B : ℕ)
    (hp : ParamsOk step pend lab φ Tc Tn P B)
    (hno : ∀ χ : PlusFormula, PlusFormula.stab χ ∉ plusSubformulaClosure φ)
    (q : Q) (c n n' : ℕ) (hq : c ∈ Adm pend q) (z : ℤ)
    (hTn : Tn ≤ n') (hle : n' ≤ n) (hres : n % (P + 1) = n' % (P + 1))
    (hgap : n + B ≤ c) (hTc : Tc ≤ c) (hB : 2 ≤ B) (hroom : n + (n - n') ≤ c)
    (hregLo : ∀ g : ℤ → LadderState Q pend, IsLadderPath step pend g →
      g z = (⟨(q, c, n'), hq⟩ : LadderState Q pend) →
      (∀ p : ℤ, p ≤ z → pend (objAt g p) = true) ∧ HasForwardSlack g z 0 n')
    (hregHi : ∀ g : ℤ → LadderState Q pend, IsLadderPath step pend g →
      g z = (⟨(q, c, n), hq⟩ : LadderState Q pend) →
      (∀ p : ℤ, p ≤ z → pend (objAt g p) = true) ∧ HasForwardSlack g z (n - n') n) :
    kappa Tc Tn P B (c, n) = kappa Tc Tn P B (c, n') ∧
      cellAt (ladderModel step pend fwd bwd lab) φ
          ((z, ⟨(q, c, n), hq⟩) : (ladderFrameAdm step pend fwd bwd).WorldState) z =
        cellAt (ladderModel step pend fwd bwd lab) φ
          ((z, ⟨(q, c, n'), hq⟩) : (ladderFrameAdm step pend fwd bwd).WorldState) z := by
  refine ⟨kappa_eq_register_raise_down Tc Tn P B c n n' hTn hle hres hgap, ?_⟩
  refine Set.Subset.antisymm
    (cellAt_subset_of_register_lower fwd bwd lab φ Tc Tn P B hp hno q c n n' hq z hle hTc hroom
      hregHi) ?_
  exact (cellAt_subset_of_register_raise fwd bwd lab φ Tc Tn P B hp hno q c n n' hq z hTn hle
    hres hgap hTc hB hregLo).2

/-- **THE REDUCTION'S HYPOTHESIS, DISCHARGED ON THE COVERED COLLISIONS AND IN BOTH ORIENTATIONS.**
`real_certStabK_of_cell_stab_transfer`'s `hcell` binder, instantiated at the covered family: a
formula lying in every closure type of one cell lies in every closure type of the other, at the
diagonal world state and in either orientation. It is the agreement above read in the shape the
certificate side consumes, and it is the compiled form of this section's table — the row that
says YES. Every other row of that table is a coordinate on which `hcell` is left STANDING, which
is why no `certStabK` conclusion is drawn from this declaration anywhere below. -/
theorem cell_stab_transfer_of_register_displacement [Fintype Q]
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (lab : Q → Atom → Bool) (φ : PlusFormula) (Tc Tn P B : ℕ)
    (hp : ParamsOk step pend lab φ Tc Tn P B)
    (hno : ∀ χ : PlusFormula, PlusFormula.stab χ ∉ plusSubformulaClosure φ)
    (q : Q) (c n n' : ℕ) (hq : c ∈ Adm pend q) (z : ℤ)
    (hTn : Tn ≤ n') (hle : n' ≤ n) (hres : n % (P + 1) = n' % (P + 1))
    (hgap : n + B ≤ c) (hTc : Tc ≤ c) (hB : 2 ≤ B) (hroom : n + (n - n') ≤ c)
    (hregLo : ∀ g : ℤ → LadderState Q pend, IsLadderPath step pend g →
      g z = (⟨(q, c, n'), hq⟩ : LadderState Q pend) →
      (∀ p : ℤ, p ≤ z → pend (objAt g p) = true) ∧ HasForwardSlack g z 0 n')
    (hregHi : ∀ g : ℤ → LadderState Q pend, IsLadderPath step pend g →
      g z = (⟨(q, c, n), hq⟩ : LadderState Q pend) →
      (∀ p : ℤ, p ≤ z → pend (objAt g p) = true) ∧ HasForwardSlack g z (n - n') n)
    (χ : PlusFormula) :
    ((∀ T ∈ cellAt (ladderModel step pend fwd bwd lab) φ
        ((z, ⟨(q, c, n), hq⟩) : (ladderFrameAdm step pend fwd bwd).WorldState) z, χ ∈ T) →
      (∀ T ∈ cellAt (ladderModel step pend fwd bwd lab) φ
        ((z, ⟨(q, c, n'), hq⟩) : (ladderFrameAdm step pend fwd bwd).WorldState) z, χ ∈ T)) ∧
    ((∀ T ∈ cellAt (ladderModel step pend fwd bwd lab) φ
        ((z, ⟨(q, c, n'), hq⟩) : (ladderFrameAdm step pend fwd bwd).WorldState) z, χ ∈ T) →
      (∀ T ∈ cellAt (ladderModel step pend fwd bwd lab) φ
        ((z, ⟨(q, c, n), hq⟩) : (ladderFrameAdm step pend fwd bwd).WorldState) z, χ ∈ T)) := by
  have hcell := (cellAt_eq_of_register_displacement fwd bwd lab φ Tc Tn P B hp hno q c n n' hq z
    hTn hle hres hgap hTc hB hroom hregLo hregHi).2
  exact ⟨fun H T hT => H T (hcell ▸ hT), fun H T hT => H T (hcell ▸ hT)⟩

/-- **THE COMPOSITION'S `certStabK` PRODUCT OVER THE COVERED REGIME — AND IT IS VACUOUS THERE.**
Condition (5) of `Real` at a stab-free closure. This IS what route (P-2)'s composition delivers on
the collisions Phase 11.26's transport covers, because the covered regime is confined to stab-free
closures by the register-moving deletions' own premise — and its proof consumes NOTHING from the
transport, the agreement above, or `real_certStabK_of_cell_stab_transfer`: `certStabK_of_stabFree`
alone gives it, for `Real` and for every other set. The restriction is the explicit named binder
`hno`, and it is recorded here rather than left implicit because it is the phase's finding: the
composition closes on the covered set and closes vacuously there. It is NOT a discharge of
condition (5) at any closure carrying a `⊡` letter. -/
theorem real_certStabK_of_stabFree (lab : Q → Atom → Bool) (φ : PlusFormula) (Tc Tn P B : ℕ)
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (hno : ∀ χ : PlusFormula, PlusFormula.stab χ ∉ plusSubformulaClosure φ) :
    certStabK φ Tc Tn P B (Real step pend lab φ Tc Tn P B fwd bwd) :=
  certStabK_of_stabFree φ Tc Tn P B hno _

/-! ### Phase 11.7: the filed agreement, ATTEMPTED FIRST and left OPEN, and the instantiation
over the covered collisions

**THE FILED STATEMENT WAS ATTEMPTED AT ITS RECORDED SIGNATURE, TOKEN-FOR-TOKEN, BEFORE ANYTHING
BELOW WAS WRITTEN, AND IT IS NOT LANDED.** The signature elaborates — it names no object that
does not exist — and the residual goal after the only reduction the landed machinery offers
(`kappa_eq_components`, the collision read coordinate by coordinate) is the statement's own
conclusion with the five coordinate equations in context and no tool applicable to it:

```
hp : ParamsOk step pend lab φ Tc Tn P B
h : c ∈ Adm pend q,  h' : c' ∈ Adm pend q
hk : kappa Tc Tn P B (c, n) = kappa Tc Tn P B (c', n')
h1 : min c Tc = min c' Tc        h2 : c % (P + 1) = c' % (P + 1)
h3 : min n Tn = min n' Tn        h4 : n % (P + 1) = n' % (P + 1)
h5 : clipIdx B c n = clipIdx B c' n'
⊢ cellAt (ladderModel step pend fwd bwd lab) φ (t, ⟨(q, c, n), h⟩) z
    = cellAt (ladderModel step pend fwd bwd lab) φ (t, ⟨(q, c', n'), h'⟩) z
```

Five coordinates of its domain are OUTSIDE the covered set, each for a reason that is a landed
object and not an assessment: the filed signature carries no stab-free premise, and both
register-moving deletions carry one; it carries no `c = c'`, and `h1`/`h2` give only
`min c Tc = min c' Tc` and a common residue, while no landed tool moves a countdown while
holding a class; its first world-state component `t` is general, while the inclusions below are
stated at the DIAGONAL (`t = z`) — the one coordinate the offset-invariance section at the end of
this module closes, by `cellAt_ladder_eq_of_worldTime`; it carries no per-path regime; and it
carries none of the room, threshold or clip conditions the deletions ask for. **So the covered
family stops short of the filed `cellAt_const_of_kappa_eq` on those collisions SPECIFICALLY** — the
upward-saturated register family, moved countdowns, closures carrying a `⊡` letter, and paths
outside the regime. **The filed statement itself is REFUTED**, on a `⊡`-carrying closure at the
gap coordinate and at (K4)'s own clip, by `exists_kappa_collision_cellAt_ne_at_K4_clip` at the end
of this module; the wired probe
`specs/evidence/seam-gluing-ray-product/ladder-cell-agreement-refutation.lean` compiles the same
object independently (`cellAt_const_of_kappa_eq_schema_refuted`; `LadderCell.lean`, section "The
refutation of the agreement over counter classes"). It is landed here under no name, and adding a
hypothesis to a recorded statement is not an implementer's move.

**WHICH CONDITION OF THE COVERED FAMILY EACH `kappa` COORDINATE SUPPLIES, so the gap is visible
in the record rather than inferred.**

| Condition of the covered family | Supplied by | Binder? |
|---|---|---|
| `n % (P + 1) = n' % (P + 1)` | `kappa`'s FOURTH coordinate, via `kappa_eq_components` | NO |
| `n = n' ∨ n + B ≤ c ∨ c + B ≤ n'` | `kappa`'s FIFTH coordinate at a held countdown | NO |
| `c' = c`, the held countdown | nothing: `h1`, `h2` give only a `min` and a residue | `hcnt` |
| `Tn ≤ n'`, the register threshold | nothing; `h3` then gives `Tn ≤ n` too | `hTn` |
| `n' ≤ n`, the orientation | nothing — the dichotomy's branch is a choice | `hle` |
| `n + B ≤ c`, downward saturation | the dichotomy's SECOND branch, a disjunct | `hgap` |
| `Tc ≤ c`, `2 ≤ B`, the lowering room | nothing | `hTc`, `hB`, `hroom` |
| stab-freeness, the per-path regimes | nothing | `hno`, `hregLo`, `hregHi` |

The two `NO` rows are derived inside the proofs below; the second is
`register_dichotomy_of_kappa_eq_held_countdown`.

**THE ROUTE TAKEN IS THE CELL-LEVEL ONE, AND THE PATH-LEVEL INVARIANCE IT REPLACES IS REFUTED,
NOT MERELY ABSENT.** The agreement below equates CELLS — the set of closure types realized at a
ladder state over all admissible histories through it — and never puts two positions of two paths
into correspondence. The path-level statement it replaces, that a splice preserves the realized
stab-free type at a distance from its splice point, is a compiled REFUTATION:
`splice_type_invariance_refuted` in
`specs/evidence/seam-gluing-ray-product/ladder-splice-type-refutation.lean`, cited by path as
evidence and not as a proof term.

**WHAT THE AGREEMENT DOES NOT SAY.** It equates cells at `kappa`-colliding states inside the
covered family, and asserts no tuple index of a ladder cell at any parameters, no bound of any
kind, and no device discrimination. The ladder's structural liveness stays FORWARD-ONLY and is
untouched by it (`gPast_isPath`,
`specs/evidence/seam-gluing-ray-product/ladder-liveness-forward-only.lean`). It is not the
factorization lemma, it is not `cellAt_const_of_kappa_eq` and nothing below consumes
`ladderSound`, `ladderLift`, `ladderCons_localRun` or any (S)/(C') statement. It takes no new
parameter ruling: `Tc` is not raised and `ParamsOk` is not strengthened. -/

/-- **A REGISTER-DISPLACED COLLISION AT A HELD COUNTDOWN IS TRIVIAL, DOWNWARD-SATURATED, OR
UPWARD-SATURATED — there is no fourth case.** The gap coordinate's own content at `c' = c`: two
registers with `n' ≤ n` colliding under `kappa` are either equal, or sit at least `B` below the
countdown (the family `cellAt_eq_of_register_displacement` covers), or the lower of them sits at
least `B` above it (the family `raise_room_excludes_upward_displacement` puts outside every
landed tool's reach). This is the compiled form of the covered/uncovered split on the register
coordinate: the covered set is the second branch, and the third is named rather than assumed
away. -/
theorem register_dichotomy_of_kappa_eq_held_countdown (Tc Tn P B c n n' : ℕ)
    (hB : 1 ≤ B) (hle : n' ≤ n)
    (hk : kappa Tc Tn P B (c, n) = kappa Tc Tn P B (c, n')) :
    n = n' ∨ n + B ≤ c ∨ c + B ≤ n' := by
  have h5 : clipIdx B c n = clipIdx B c n' := (kappa_eq_components Tc Tn P B c n c n' hk).2.2.2.2
  unfold clipIdx at h5
  split at h5 <;> split at h5 <;> omega

/-- **THE AGREEMENT AT THE FILED STATEMENT'S OWN SHAPE, RESTRICTED TO THE COVERED COLLISIONS.**
The filed `cellAt_const_of_kappa_eq` takes the `kappa`-collision as a HYPOTHESIS and concludes the
two cells equal; this is that statement with every coordinate outside Phase 11.26's covered
family carried as an explicit named binder — the held countdown `hcnt`, the orientation `hle`,
the register threshold `hTn`, the downward saturation `hgap`, the countdown threshold `hTc`, the
clip `hB`, the lowering room `hroom`, the stab-free closure `hno`, the diagonal world state, and
the two per-path regimes, one through each state because the two inclusions are carried by
different tools through different source states. **It is NOT the filed statement**, which
quantifies over every `kappa`-collision at every time component and at every closure, lies
outside this theorem on exactly the coordinates listed above, and is REFUTED on a `⊡`-carrying
closure (`exists_kappa_collision_cellAt_ne_at_K4_clip`); this theorem is landed under its own name
precisely so that the difference is visible. `hk` is load-bearing: it supplies the residue
conjunct through `kappa_eq_components`, and nothing below re-assumes it.

Paper: — (the counter quotient, the ladder carrier and the cell of a ladder state are the
formalization's own objects; the paper states no agreement of class-equivalent cells and no
counter quotient to state one over) -/
theorem cellAt_const_of_kappa_eq_of_covered [Fintype Q]
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (lab : Q → Atom → Bool) (φ : PlusFormula) (Tc Tn P B : ℕ)
    (hp : ParamsOk step pend lab φ Tc Tn P B)
    (hno : ∀ χ : PlusFormula, PlusFormula.stab χ ∉ plusSubformulaClosure φ)
    (q : Q) (c n c' n' : ℕ) (h : c ∈ Adm pend q) (h' : c' ∈ Adm pend q)
    (hk : kappa Tc Tn P B (c, n) = kappa Tc Tn P B (c', n'))
    (hcnt : c' = c) (hTn : Tn ≤ n') (hle : n' ≤ n)
    (hgap : n + B ≤ c) (hTc : Tc ≤ c) (hB : 2 ≤ B) (hroom : n + (n - n') ≤ c)
    (z : ℤ)
    (hregLo : ∀ g : ℤ → LadderState Q pend, IsLadderPath step pend g →
      g z = (⟨(q, c', n'), h'⟩ : LadderState Q pend) →
      (∀ p : ℤ, p ≤ z → pend (objAt g p) = true) ∧ HasForwardSlack g z 0 n')
    (hregHi : ∀ g : ℤ → LadderState Q pend, IsLadderPath step pend g →
      g z = (⟨(q, c, n), h⟩ : LadderState Q pend) →
      (∀ p : ℤ, p ≤ z → pend (objAt g p) = true) ∧ HasForwardSlack g z (n - n') n) :
    cellAt (ladderModel step pend fwd bwd lab) φ
        ((z, ⟨(q, c, n), h⟩) : (ladderFrameAdm step pend fwd bwd).WorldState) z
      = cellAt (ladderModel step pend fwd bwd lab) φ
        ((z, ⟨(q, c', n'), h'⟩) : (ladderFrameAdm step pend fwd bwd).WorldState) z := by
  subst hcnt
  have hres : n % (P + 1) = n' % (P + 1) :=
    (kappa_eq_components Tc Tn P B c' n c' n' hk).2.2.2.1
  exact (cellAt_eq_of_register_displacement fwd bwd lab φ Tc Tn P B hp hno q c' n n' h z
    hTn hle hres hgap hTc hB hroom hregLo hregHi).2


/-! ### Route (E-2): the DIAGONAL gap — offset-invariance of `tpOf` under `ladderModel`, and the
covered agreement at a general time component

One of the five coordinates on which the filed `cellAt_const_of_kappa_eq` is open above is the
world state's own TIME component: every landed inclusion is DIAGONAL (`t = z`), while the filed
statement quantifies over a general `t`. That coordinate is closed here, and it is closed
INDEPENDENTLY of the register question and of the stab-free premise: no declaration in this
section carries `hno`, none mentions `kappa`'s register coordinate, none raises `Tc` and none
strengthens `ParamsOk`.

**WHY IT CLOSES AT ALL, when `cellAt_eq_cellAt` does not already give it.** `cellAt_eq_cellAt`
says a cell does not depend on the time at which a state is VISITED — the `z` argument. It says
nothing about the `ℤ` component of the world STATE, which on this carrier is a coordinate of the
state itself: `cellAt … (t, x) z` and `cellAt … (t', x) z` are cells of two DIFFERENT world
states, and no history through one is a history through the other. What makes them equal is that
`Rlad` ignores its time argument (`isSlicedStepPath_iff_isLadderPath`), so one ladder walk is a
history at EVERY offset (`exists_hist_of_isLadderPath_at_offset`), and the model's valuation reads
the object component alone — the offset is invisible to every clause of `PlusTruthAt`.

**WHERE THE `⊡` CLAUSE GOES, since it is the clause that reads the world state.** It is the only
clause that is not structural here, and it closes by the same shift: a history through
`(z + k', g z)` is an offset step path at some offset, hence the SAME walk re-offset to `k`, and
the induction hypothesis at that walk transports its truth. This is why no stab-free premise is
needed — the obligation route (E-2) names, and the reason this coordinate is tractable while the
register coordinate is not.

**WHAT THIS SECTION DOES NOT SAY.** It does not close the filed `cellAt_const_of_kappa_eq`: four
of the five uncovered coordinates (the upward-saturated register family, moved countdowns,
closures carrying a `⊡` letter, and paths outside the regime) are untouched, and the agreement
below is still restricted to Phase 11.26's covered family by the same named binders. It asserts no
tuple index of a ladder cell, no bound of any kind, no device discrimination, and it consumes
neither `ladderSound`, `ladderLift`, `ladderCons_localRun` nor any (S)/(C') statement. -/

/-- **Every ladder path is a world history of the ladder frame at EVERY offset.**
`exists_hist_of_isLadderPath` is the instance `k = 0`. The offset is invisible to the step
condition (`isSlicedStepPath_iff_isLadderPath`, because `Rlad` ignores its time argument), so one
walk is an offset step path at every `k`, and the history it yields occupies world time `t + k`
while the walk is at `t`.

Paper: — (the frame-scheme constructor's history space is the formalization's own object) -/
theorem exists_hist_of_isLadderPath_at_offset
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (k : ℤ) (g : ℤ → LadderState Q pend) (hg : IsLadderPath step pend g) :
    ∃ τ : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame,
      ∀ t : ℤ, τ.state t = (t + k, g t) := by
  obtain ⟨τ, hτ⟩ :=
    (ofSlicedStepFinBranch_mem_HF_iff (RladAdm step pend) (RladAdm_fwd step pend)
        (RladAdm_bwd step pend) fwd bwd (fun t => (t + k, g t))).mpr
      ⟨k, g, (isSlicedStepPath_iff_isLadderPath k g).mpr hg, rfl⟩
  refine ⟨τ, fun t => ?_⟩
  have h : τ.path t = (t + k, g t) := by rw [hτ]
  exact h

/-- **OFFSET-INVARIANCE OF TRUTH UNDER `ladderModel`.** Two world histories carrying the SAME
ladder walk at two different offsets satisfy the same formulas at every position. No premise on
the formula: the `⊡` letters are included, so there is no stab-free hypothesis and no pinned-letter
parameter, and no finiteness of the fibre or of the width enters anywhere.

One case per clause of `PlusTruthAt`, as half (i) is
(`truthAt_iff_of_objAt_eq_of_stabPinned`), with the `⊡` clause PROVED rather than carried: the
atomic letters read the object component of the walk and the offset is invisible to the
valuation; `⊥` and `→` are structural; `□` names no history at all; `U` and `S` quantify over the
time axis of the same history and are the induction hypothesis at the other positions; and `⊡`
quantifies over the histories through the world state at that position, where a history through
the offset-`k'` state is the same walk at offset `k'` and re-offsetting it to `k`
(`exists_hist_of_isLadderPath_at_offset`) lands inside the other side's quantifier, with the
induction hypothesis at THAT walk transporting the truth back.

Paper: — (a statement about the frame-scheme constructor's offset, which has no counterpart in
HWZ 2000, where histories are the runs of a freely chosen run set) -/
theorem truthAt_iff_of_worldTime_offset
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (lab : Q → Atom → Bool) :
    ∀ (ψ : PlusFormula) (k k' : ℤ) (g : ℤ → LadderState Q pend), IsLadderPath step pend g →
      ∀ σ σ' : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame,
        (∀ t : ℤ, σ.state t = (t + k, g t)) → (∀ t : ℤ, σ'.state t = (t + k', g t)) →
        ∀ z : ℤ,
          (PlusTruthAt (ladderModel step pend fwd bwd lab) σ z ψ ↔
            PlusTruthAt (ladderModel step pend fwd bwd lab) σ' z ψ) := by
  intro ψ
  induction ψ with
  | atom p =>
      intro k k' g _ σ σ' hσ hσ' z
      rw [PlusTruth.atom_iff, PlusTruth.atom_iff, hσ z, hσ' z]
      exact Iff.rfl
  | bot => intro _ _ _ _ _ _ _ _ _; exact Iff.rfl
  | imp a b iha ihb =>
      intro k k' g hg σ σ' hσ hσ' z
      exact imp_congr (iha k k' g hg σ σ' hσ hσ' z) (ihb k k' g hg σ σ' hσ hσ' z)
  | box a _ => intro _ _ _ _ _ _ _ _ _; exact Iff.rfl
  | untl a b iha ihb =>
      intro k k' g hg σ σ' hσ hσ' z
      rw [PlusTruth.untl_iff, PlusTruth.untl_iff]
      constructor
      · rintro ⟨s, hs, he, hgd⟩
        exact ⟨s, hs, (ihb k k' g hg σ σ' hσ hσ' s).mp he,
          fun r h1 h2 => (iha k k' g hg σ σ' hσ hσ' r).mp (hgd r h1 h2)⟩
      · rintro ⟨s, hs, he, hgd⟩
        exact ⟨s, hs, (ihb k k' g hg σ σ' hσ hσ' s).mpr he,
          fun r h1 h2 => (iha k k' g hg σ σ' hσ hσ' r).mpr (hgd r h1 h2)⟩
  | snce a b iha ihb =>
      intro k k' g hg σ σ' hσ hσ' z
      rw [PlusTruth.snce_iff, PlusTruth.snce_iff]
      constructor
      · rintro ⟨s, hs, he, hgd⟩
        exact ⟨s, hs, (ihb k k' g hg σ σ' hσ hσ' s).mp he,
          fun r h1 h2 => (iha k k' g hg σ σ' hσ hσ' r).mp (hgd r h1 h2)⟩
      · rintro ⟨s, hs, he, hgd⟩
        exact ⟨s, hs, (ihb k k' g hg σ σ' hσ hσ' s).mpr he,
          fun r h1 h2 => (iha k k' g hg σ σ' hσ hσ' r).mpr (hgd r h1 h2)⟩
  | stab a iha =>
      have key : ∀ (k k' : ℤ) (g : ℤ → LadderState Q pend), IsLadderPath step pend g →
          ∀ σ σ' : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame,
            (∀ t : ℤ, σ.state t = (t + k, g t)) → (∀ t : ℤ, σ'.state t = (t + k', g t)) →
            ∀ z : ℤ,
              PlusTruthAt (ladderModel step pend fwd bwd lab) σ z (PlusFormula.stab a) →
                PlusTruthAt (ladderModel step pend fwd bwd lab) σ' z (PlusFormula.stab a) := by
        intro k k' g hg σ σ' hσ hσ' z H τ hτeq
        obtain ⟨m, h, hh, hp⟩ := exists_isLadderPath_of_hist fwd bwd τ
        have hstate : ((z + k', g z) : (ladderFrameAdm step pend fwd bwd).WorldState)
            = (z + m, h z) := (hσ' z).symm.trans (hτeq.trans (hp z))
        have hm : m = k' := by
          have := congrArg Prod.fst hstate
          simp only at this
          omega
        have hgz : h z = g z := by
          have := congrArg Prod.snd hstate
          simpa using this.symm
        obtain ⟨ρ, hρ⟩ := exists_hist_of_isLadderPath_at_offset fwd bwd k h hh
        have hρz : σ.state z = ρ.state z := by
          rw [hσ z, hρ z, hgz]
        exact (iha k m h hh ρ τ hρ hp z).mp (H ρ hρz)
      intro k k' g hg σ σ' hσ hσ' z
      exact ⟨key k k' g hg σ σ' hσ hσ' z, key k' k g hg σ' σ hσ' hσ z⟩

/-- **OFFSET-INVARIANCE OF THE REALIZED CLOSURE TYPE.** `truthAt_iff_of_worldTime_offset` on
types: the type realized by a ladder walk at a position does not depend on the offset its history
carries. Box and `⊡` letters included; no stab-free premise. -/
theorem tpOf_eq_of_worldTime_offset
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (lab : Q → Atom → Bool) (φ : PlusFormula) {k k' : ℤ} {g : ℤ → LadderState Q pend}
    (hg : IsLadderPath step pend g)
    (σ σ' : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame)
    (hσ : ∀ t : ℤ, σ.state t = (t + k, g t)) (hσ' : ∀ t : ℤ, σ'.state t = (t + k', g t))
    (z : ℤ) :
    tpOf (ladderModel step pend fwd bwd lab) φ σ z
      = tpOf (ladderModel step pend fwd bwd lab) φ σ' z := by
  ext ψ
  rw [mem_tpOf_iff, mem_tpOf_iff]
  exact and_congr_right fun _ =>
    truthAt_iff_of_worldTime_offset fwd bwd lab ψ k k' g hg σ σ' hσ hσ' z

/-- **THE CELL OF A LADDER STATE DOES NOT DEPEND ON THE WORLD STATE'S TIME COMPONENT.** The
coordinate `cellAt_eq_cellAt` does NOT give: that one is the time at which the state is VISITED
(`z`), this one the `ℤ` COMPONENT OF THE STATE, whose two values name two different world states
with disjoint history sets. They carry the same cell because one ladder walk is a history at
every offset and the offset is invisible to truth (`tpOf_eq_of_worldTime_offset`).

This is the diagonal gap of route (E-2), landed: it lifts any inclusion or equality stated at the
diagonal world state `(z, x)` to the general `(t, x)` the filed statements quantify over.

Paper: — (as `exists_hist_of_isLadderPath_at_offset`: the constructor's offset has no literature
counterpart) -/
theorem cellAt_ladder_eq_of_worldTime
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (lab : Q → Atom → Bool) (φ : PlusFormula) (x : LadderState Q pend) (t t' z : ℤ) :
    cellAt (ladderModel step pend fwd bwd lab) φ
        ((t, x) : (ladderFrameAdm step pend fwd bwd).WorldState) z
      = cellAt (ladderModel step pend fwd bwd lab) φ
        ((t', x) : (ladderFrameAdm step pend fwd bwd).WorldState) z := by
  have key : ∀ u u' : ℤ,
      cellAt (ladderModel step pend fwd bwd lab) φ
          ((u, x) : (ladderFrameAdm step pend fwd bwd).WorldState) z
        ⊆ cellAt (ladderModel step pend fwd bwd lab) φ
          ((u', x) : (ladderFrameAdm step pend fwd bwd).WorldState) z := by
    intro u u' T hT
    obtain ⟨σ, hs, hT⟩ := hT
    obtain ⟨k, g, hg, hp⟩ := exists_isLadderPath_of_hist fwd bwd σ
    have hstate : ((u, x) : (ladderFrameAdm step pend fwd bwd).WorldState) = (z + k, g z) :=
      hs.symm.trans (hp z)
    have hk : z + k = u := by
      have := congrArg Prod.fst hstate
      simp only at this
      omega
    have hgz : g z = x := by
      have := congrArg Prod.snd hstate
      simpa using this.symm
    obtain ⟨σ', hσ'⟩ := exists_hist_of_isLadderPath_at_offset fwd bwd (u' - z) g hg
    refine ⟨σ', ?_, ?_⟩
    · rw [hσ' z, hgz]
      have : z + (u' - z) = u' := by omega
      rw [this]
    · rw [← hT]
      exact (tpOf_eq_of_worldTime_offset fwd bwd lab φ hg σ σ' hp hσ' z).symm
  exact Set.Subset.antisymm (key t t') (key t' t)

/-- **THE COVERED AGREEMENT AT A GENERAL TIME COMPONENT.** `cellAt_const_of_kappa_eq_of_covered`
with its DIAGONAL world state replaced by the filed statement's general `t`, which is what route
(E-2) owes: every other binder is unchanged, token for token, and the two per-path regimes stay at
`z` because they are conditions on the walk and not on the world state's time component.

**What is still open after it**: four of the five coordinates listed above — the upward-saturated
register family, moved countdowns, closures carrying a `⊡` letter, and paths outside the regime.
This widens the covered family by one coordinate and closes nothing else; the filed
`cellAt_const_of_kappa_eq` is landed under no name and is REFUTED on a `⊡`-carrying closure
(`exists_kappa_collision_cellAt_ne_at_K4_clip`).

Paper: — (as `cellAt_const_of_kappa_eq_of_covered`) -/
theorem cellAt_const_of_kappa_eq_of_covered_at_time [Fintype Q]
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (lab : Q → Atom → Bool) (φ : PlusFormula) (Tc Tn P B : ℕ)
    (hp : ParamsOk step pend lab φ Tc Tn P B)
    (hno : ∀ χ : PlusFormula, PlusFormula.stab χ ∉ plusSubformulaClosure φ)
    (q : Q) (c n c' n' : ℕ) (h : c ∈ Adm pend q) (h' : c' ∈ Adm pend q)
    (hk : kappa Tc Tn P B (c, n) = kappa Tc Tn P B (c', n'))
    (hcnt : c' = c) (hTn : Tn ≤ n') (hle : n' ≤ n)
    (hgap : n + B ≤ c) (hTc : Tc ≤ c) (hB : 2 ≤ B) (hroom : n + (n - n') ≤ c)
    (t z : ℤ)
    (hregLo : ∀ g : ℤ → LadderState Q pend, IsLadderPath step pend g →
      g z = (⟨(q, c', n'), h'⟩ : LadderState Q pend) →
      (∀ p : ℤ, p ≤ z → pend (objAt g p) = true) ∧ HasForwardSlack g z 0 n')
    (hregHi : ∀ g : ℤ → LadderState Q pend, IsLadderPath step pend g →
      g z = (⟨(q, c, n), h⟩ : LadderState Q pend) →
      (∀ p : ℤ, p ≤ z → pend (objAt g p) = true) ∧ HasForwardSlack g z (n - n') n) :
    cellAt (ladderModel step pend fwd bwd lab) φ
        ((t, ⟨(q, c, n), h⟩) : (ladderFrameAdm step pend fwd bwd).WorldState) z
      = cellAt (ladderModel step pend fwd bwd lab) φ
        ((t, ⟨(q, c', n'), h'⟩) : (ladderFrameAdm step pend fwd bwd).WorldState) z := by
  rw [cellAt_ladder_eq_of_worldTime fwd bwd lab φ ⟨(q, c, n), h⟩ t z z,
    cellAt_ladder_eq_of_worldTime fwd bwd lab φ ⟨(q, c', n'), h'⟩ t z z]
  exact cellAt_const_of_kappa_eq_of_covered fwd bwd lab φ Tc Tn P B hp hno q c n c' n' h h' hk
    hcnt hTn hle hgap hTc hB hroom z hregLo hregHi


end CertificateBridge

/-! ## The agreement on `kappa`-classes is refuted at (K4)'s clip

One declaration, `exists_kappa_collision_cellAt_ne_at_K4_clip`, and the two-state object that
witnesses it. Everything in the namespace `K4ClipWitness` is `private`: the object, its ladder
paths, the separating formula and its two membership lemmas are the witness's construction and are
not part of this module's interface. The wired probe
`specs/evidence/seam-gluing-ray-product/ladder-cell-agreement-refutation.lean` compiles the same
object independently (`cellAt_const_of_kappa_eq_schema_refuted`, `no_fibre_equation_over_kappa`)
and stays the independently-gated duplicate; nothing here imports it. -/

namespace K4ClipWitness

private abbrev Qc : Type := Fin 2

private def pendC : Qc → Bool := fun q => decide (q = 0)

private def stepC : Qc → Qc → Bool := fun _ _ => true

private def pC : Atom := ⟨"p", none⟩

private def labC : Qc → Atom → Bool := fun q at_ => decide (at_ = pC ∧ q = 0)

private theorem pendC_zero : pendC 0 = true := by decide

private theorem pendC_one : pendC 1 = false := by decide

private theorem not_pendC_zero_false : ¬ ((true : Bool) = false) := by simp

/-- Admissibility of EVERY countdown at the pending state: the clause's hypothesis is false
there. -/
private theorem admZeroC (d n : ℕ) : ((0 : Qc), d, n).2.1 ∈ Adm pendC ((0 : Qc), d, n).1 :=
  fun h => absurd (pendC_zero.symm.trans h) not_pendC_zero_false

private theorem labC_pC (q : Qc) : labC q pC = pendC q := by
  simp [labC, pendC]

/-! #### Seriality -/

private theorem fwdC : ∀ (t : ℤ) (x : LadderState Qc pendC), ∃ y, RladAdm stepC pendC t x y := by
  intro _ x
  obtain ⟨⟨q, c, n⟩, hx⟩ := x
  by_cases hq : pendC q = true
  · cases c with
    | zero =>
        refine ⟨⟨(1, 0, n), fun _ => rfl⟩, rfl, hx, Or.inl rfl, ?_⟩
        simp [Count, hq, pendC_one]
    | succ d =>
        refine ⟨⟨(0, d, n), admZeroC d n⟩, rfl, hx, Or.inl rfl, ?_⟩
        simp [Count, hq, pendC_zero]
  · rw [Bool.not_eq_true] at hq
    refine ⟨⟨(1, 0, n), fun _ => rfl⟩, rfl, hx, Or.inl rfl, ?_⟩
    simp [Count, hq, pendC_one]

private theorem bwdC :
    ∀ (t : ℤ) (x : LadderState Qc pendC), ∃ y, RladAdm stepC pendC (t - 1) y x := by
  intro _ x
  obtain ⟨⟨q, c, n⟩, hx⟩ := x
  by_cases hq : pendC q = true
  · refine ⟨⟨(0, c + 1, n), admZeroC (c + 1) n⟩, rfl, admZeroC (c + 1) n,
      Or.inl rfl, ?_⟩
    simp [Count, hq, pendC_zero]
  · rw [Bool.not_eq_true] at hq
    have hc : c = 0 := hx hq
    refine ⟨⟨(0, 0, n), admZeroC 0 n⟩, rfl, admZeroC 0 n, Or.inl rfl, ?_⟩
    simp [Count, hq, pendC_zero, hc]

/-! #### The walk, pending at every past position, and its forced countdown -/

private def wC (c₀ : ℕ) : ℤ → Qc := fun v => if v ≤ (c₀ : ℤ) then 0 else 1

private def cC (c₀ : ℕ) : ℤ → ℕ := fun v => ((c₀ : ℤ) - v).toNat

private theorem pendC_wC_of_le (c₀ : ℕ) (v : ℤ) (h : v ≤ (c₀ : ℤ)) : pendC (wC c₀ v) = true := by
  simp [wC, pendC, h]

private theorem pendC_wC_of_gt (c₀ : ℕ) (v : ℤ) (h : ¬ (v ≤ (c₀ : ℤ))) :
    pendC (wC c₀ v) = false := by
  simp [wC, pendC, h]

private theorem admC (c₀ : ℕ) (v : ℤ) : pendC (wC c₀ v) = false → cC c₀ v = 0 := by
  intro h
  by_cases hv : v ≤ (c₀ : ℤ)
  · exact absurd ((pendC_wC_of_le c₀ v hv).symm.trans h) not_pendC_zero_false
  · simp only [cC]; omega

/-- **The ladder path through `⟨(0, c₀, n₀), _⟩`**: pending at every position at or below `c₀`,
idle after, with the next-deadline register CONSTANT at `n₀`.  The walk has no region start, so
the register is free of every pin and the constant is admissible. -/
private def gC (c₀ n₀ : ℕ) : ℤ → LadderState Qc pendC :=
  fun v => ⟨(wC c₀ v, cC c₀ v, n₀), admC c₀ v⟩

private theorem gC_objAt (c₀ n₀ : ℕ) (v : ℤ) : objAt (gC c₀ n₀) v = wC c₀ v := rfl

private theorem gC_cntAt (c₀ n₀ : ℕ) (v : ℤ) : cntAt (gC c₀ n₀) v = cC c₀ v := rfl

private theorem gC_nxtAt (c₀ n₀ : ℕ) (v : ℤ) : nxtAt (gC c₀ n₀) v = n₀ := rfl

private theorem gC_isPath (c₀ n₀ : ℕ) : IsLadderPath stepC pendC (gC c₀ n₀) := by
  intro u
  refine ⟨rfl, admC c₀ u, Or.inl rfl, ?_⟩
  by_cases h1 : u + 1 ≤ (c₀ : ℤ)
  · have h0 : u ≤ (c₀ : ℤ) := by omega
    rw [show (gC c₀ n₀ u).1.1 = wC c₀ u from rfl,
      show (gC c₀ n₀ (u + 1)).1.1 = wC c₀ (u + 1) from rfl]
    simp only [Count, pendC_wC_of_le c₀ u h0, pendC_wC_of_le c₀ (u + 1) h1, if_true]
    change cC c₀ (u + 1) + 1 = cC c₀ u
    simp only [cC]; omega
  · by_cases h0 : u ≤ (c₀ : ℤ)
    · rw [show (gC c₀ n₀ u).1.1 = wC c₀ u from rfl,
        show (gC c₀ n₀ (u + 1)).1.1 = wC c₀ (u + 1) from rfl]
      simp only [Count, pendC_wC_of_le c₀ u h0, pendC_wC_of_gt c₀ (u + 1) h1]
      refine ⟨?_, ?_⟩
      · change cC c₀ (u + 1) = 0
        simp only [cC]; omega
      · intro _
        change cC c₀ u = 0
        simp only [cC]; omega
    · rw [show (gC c₀ n₀ u).1.1 = wC c₀ u from rfl,
        show (gC c₀ n₀ (u + 1)).1.1 = wC c₀ (u + 1) from rfl]
      simp only [Count, pendC_wC_of_gt c₀ u h0, pendC_wC_of_gt c₀ (u + 1) h1]
      refine ⟨?_, ?_⟩
      · change cC c₀ (u + 1) = 0
        simp only [cC]; omega
      · intro h
        exact absurd h (by simp)

private theorem gC_zero (c₀ n₀ : ℕ) : (gC c₀ n₀ 0).1 = ((0 : Qc), c₀, n₀) := by
  simp only [gC, wC, cC]
  norm_num

/-- The model of this object. -/
private noncomputable abbrev MC :
    TaskModel (ladderFrameAdm stepC pendC fwdC bwdC).toTaskFrame :=
  ladderModel stepC pendC fwdC bwdC labC

/-- `X ψ`, written with the strict `untl` at the guard `⊥`. -/
private def nxtF (ψ : PlusFormula) : PlusFormula := .untl .bot ψ

private theorem int_succ_lt_of_ne (t s : ℤ) (h : t < s) (hne : s ≠ t + 1) : t + 1 < s := by omega

private theorem int_not_between (t r : ℤ) (h1 : t < r) (h2 : r < t + 1) : False := by omega

private theorem truth_nxtF (τ : WorldHistory (ladderFrameAdm stepC pendC fwdC bwdC).toTaskFrame)
    (t : ℤ) (ψ : PlusFormula) :
    PlusTruthAt MC τ t (nxtF ψ) ↔ PlusTruthAt MC τ (t + 1) ψ := by
  constructor
  · rintro ⟨s, hts, hs, hr⟩
    by_cases he : s = t + 1
    · rw [he] at hs
      exact hs
    · exact (hr (t + 1) (Int.lt_succ_self t) (int_succ_lt_of_ne t s hts he)).elim
  · intro h
    exact ⟨t + 1, Int.lt_succ_self t, h, fun r h1 h2 => (int_not_between t r h1 h2).elim⟩

/-- The ladder state `⟨(0, c, n), _⟩`. -/
private def stC (c n : ℕ) : LadderState Qc pendC := ⟨((0 : Qc), c, n), admZeroC c n⟩

private theorem gC_zero_eq (c n : ℕ) : gC c n 0 = stC c n := Subtype.ext (gC_zero c n)

private theorem cellC_nonempty (φ : PlusFormula) (c n : ℕ) :
    ∃ T, T ∈ cellAt MC φ
      ((0, stC c n) : (ladderFrameAdm stepC pendC fwdC bwdC).WorldState) 0 := by
  obtain ⟨τ, hτ⟩ := exists_hist_of_isLadderPath fwdC bwdC (gC c n) (gC_isPath c n)
  exact ⟨_, (mem_cellAt_ladder_iff fwdC bwdC labC φ (stC c n) 0 _).mpr
    ⟨gC c n, τ, gC_isPath c n, gC_zero_eq c n, hτ, rfl⟩⟩


section Glue

variable {Q : Type} {step : Q → Q → Bool} {pend : Q → Bool}

/-- Follow `g₁` up to and including `z`, and `g₂` from `z + 1` on. -/
private def gluePath (g₁ g₂ : ℤ → LadderState Q pend) (z : ℤ) : ℤ → LadderState Q pend :=
  fun v => if v ≤ z then g₁ v else g₂ v

private theorem gluePath_isPath (g₁ g₂ : ℤ → LadderState Q pend)
    (h₁ : IsLadderPath step pend g₁) (h₂ : IsLadderPath step pend g₂) (z : ℤ)
    (hz : RladAdm step pend z (g₁ z) (g₂ (z + 1))) :
    IsLadderPath step pend (gluePath g₁ g₂ z) := by
  intro u
  unfold gluePath
  by_cases h : u + 1 ≤ z
  · rw [if_pos (by omega), if_pos h]
    exact h₁ u
  · by_cases h' : u ≤ z
    · have hu : u = z := by omega
      subst hu
      rw [if_pos le_rfl, if_neg h]
      exact hz
    · rw [if_neg h', if_neg h]
      exact h₂ u

private theorem gluePath_of_le (g₁ g₂ : ℤ → LadderState Q pend) (z v : ℤ) (h : v ≤ z) :
    gluePath g₁ g₂ z v = g₁ v := by
  unfold gluePath; rw [if_pos h]

private theorem gluePath_of_gt (g₁ g₂ : ℤ → LadderState Q pend) (z v : ℤ) (h : z < v) :
    gluePath g₁ g₂ z v = g₂ v := by
  unfold gluePath; rw [if_neg (by omega)]

/-- A ladder path read at a shifted clock is a ladder path: the relation ignores its time. -/
private theorem shiftPath_isPath (g : ℤ → LadderState Q pend) (hg : IsLadderPath step pend g)
    (k : ℤ) :
    IsLadderPath step pend (fun v => g (v - k)) := by
  intro u
  have h := hg (u - k)
  rw [show u - k + 1 = u + 1 - k by ring] at h
  exact h

/-- **A FINITE PAST FORCES THE GAP.** On a ladder path, a pending position with an idle position
somewhere before it carries a countdown at most one above its register: the region it sits in was
entered with the countdown set to the register, and since then the countdown fell by one per step
while the register fell by at most one per step. -/
private theorem cnt_le_nxt_succ_of_past_idle (g : ℤ → LadderState Q pend)
    (hg : IsLadderPath step pend g)
    (z s : ℤ) (hs : s < z) (hidle : pend (objAt g s) = false) (hz : pend (objAt g z) = true) :
    cntAt g z ≤ nxtAt g z + 1 := by
  have hex : ∃ k : ℕ, pend (objAt g (z - (k : ℤ) - 1)) = false :=
    ⟨(z - s - 1).toNat, by
      rw [show z - (((z - s - 1).toNat : ℕ) : ℤ) - 1 = s by omega]; exact hidle⟩
  have hk := Nat.find_spec hex
  have hmin : ∀ i : ℕ, i < Nat.find hex → pend (objAt g (z - (i : ℤ) - 1)) = true := by
    intro i hi
    have := Nat.find_min hex hi
    simpa using this
  set k := Nat.find hex with hkdef
  have hall : ∀ i : ℕ, i ≤ k → pend (objAt g (z - (i : ℤ))) = true := by
    intro i hi
    cases i with
    | zero => simpa using hz
    | succ j =>
      have := hmin j (by omega)
      rwa [show z - ((j + 1 : ℕ) : ℤ) = z - (j : ℤ) - 1 by push_cast; ring]
  have hpin := cntAt_eq_nxtAt_of_idle_pend g hg (z - (k : ℤ) - 1) hk
    (by rw [show z - (k : ℤ) - 1 + 1 = z - (k : ℤ) by ring]; exact hall k le_rfl)
  rw [show z - (k : ℤ) - 1 + 1 = z - (k : ℤ) by ring] at hpin
  have hback := cntAt_add_of_pend_back g hg z k hall
  have hlip := nxtAt_lipschitz g hg (z - (k : ℤ) - 1) (k + 1)
  rw [show z - (k : ℤ) - 1 + ((k + 1 : ℕ) : ℤ) = z by push_cast; ring] at hlip
  omega

end Glue

/-! #### The separating formula -/

/-- The constant idle path with register `r`. -/
private def gI (r : ℕ) : ℤ → LadderState Qc pendC := fun _ => ⟨((1 : Qc), 0, r), fun _ => rfl⟩

private theorem gI_isPath (r : ℕ) : IsLadderPath stepC pendC (gI r) := by
  intro u
  refine ⟨rfl, fun _ => rfl, Or.inl rfl, ?_⟩
  change Count (pendC 1) (pendC 1) 0 r 0
  simp [Count, pendC_one]

/-- `P ¬p`: the pending bit was released at some earlier time. -/
private def pastIdleC : PlusFormula := .snce (.imp .bot .bot) (PlusFormula.neg (.atom pC))

/-- **THE SEPARATING FORMULA.** `⊡ X ⊡ ¬ P ¬p`: on every history through this state, one step
on, every history through the state reached there has been pending at every earlier time. -/
private def thetaC : PlusFormula := .stab (nxtF (.stab (PlusFormula.neg pastIdleC)))

private theorem truth_neg_pC_off
    (τ : WorldHistory (ladderFrameAdm stepC pendC fwdC bwdC).toTaskFrame)
    (g : ℤ → LadderState Qc pendC) (k : ℤ) (hτ : ∀ t : ℤ, τ.state t = (t + k, g t)) (s : ℤ) :
    PlusTruthAt MC τ s (PlusFormula.neg (.atom pC)) ↔ pendC (objAt g s) = false := by
  change (labC (τ.state s).2.1.1 pC = true → False) ↔ _
  rw [hτ s]
  change (labC (objAt g s) pC = true → False) ↔ _
  rw [labC_pC]
  cases pendC (objAt g s) <;> simp

private theorem truth_pastIdleC
    (τ : WorldHistory (ladderFrameAdm stepC pendC fwdC bwdC).toTaskFrame)
    (g : ℤ → LadderState Qc pendC) (k : ℤ) (hτ : ∀ t : ℤ, τ.state t = (t + k, g t)) (t : ℤ) :
    PlusTruthAt MC τ t pastIdleC ↔ ∃ s : ℤ, s < t ∧ pendC (objAt g s) = false := by
  constructor
  · rintro ⟨s, hs, h, -⟩
    exact ⟨s, hs, (truth_neg_pC_off τ g k hτ s).mp h⟩
  · rintro ⟨s, hs, h⟩
    exact ⟨s, hs, (truth_neg_pC_off τ g k hτ s).mpr h, fun _ _ _ hf => hf⟩


/-- **NEGATIVE MEMBERSHIP: gap `n - c = -3`.** At the pending state with countdown `n + 3` and
register `n`, no realized type contains the separating formula: one step on the register can have
risen to `n + 1` against a countdown `n + 2`, and that state is also reached one step after an
idle state with register `n + 2`. -/
private theorem thetaC_not_mem (n : ℕ) (T : Finset PlusFormula)
    (hT : T ∈ cellAt MC thetaC
      ((0, stC (n + 3) n) : (ladderFrameAdm stepC pendC fwdC bwdC).WorldState) 0) :
    thetaC ∉ T := by
  obtain ⟨τ, hs, rfl⟩ := hT
  rw [mem_tpOf_iff]
  rintro ⟨-, h⟩
  -- the common future: the path through `(n + 2, n + 1)` at time `1`
  have hfut := shiftPath_isPath (gC (n + 2) (n + 1)) (gC_isPath (n + 2) (n + 1)) 1
  have hfut1 : gC (n + 2) (n + 1) (0 + 1 - 1) = stC (n + 2) (n + 1) := by
    rw [show (0 : ℤ) + 1 - 1 = 0 by norm_num, gC_zero_eq]
  -- `σ`: through `(n + 3, n)` at `0`, register rising
  have hσp : IsLadderPath stepC pendC
      (gluePath (gC (n + 3) n) (fun v : ℤ => gC (n + 2) (n + 1) (v - 1)) 0) := by
    refine gluePath_isPath _ _ (gC_isPath _ _) hfut 0 ?_
    rw [hfut1, gC_zero_eq]
    refine ⟨rfl, admZeroC _ _, Or.inr (Or.inl rfl), ?_⟩
    change Count (pendC 0) (pendC 0) (n + 3) n (n + 2)
    simp [Count, pendC_zero]
  -- `ρ`: idle at `0` with register `n + 2`, the same state at `1`
  have hρp : IsLadderPath stepC pendC
      (gluePath (gI (n + 2)) (fun v : ℤ => gC (n + 2) (n + 1) (v - 1)) 0) := by
    refine gluePath_isPath _ _ (gI_isPath _) hfut 0 ?_
    rw [hfut1]
    refine ⟨rfl, fun _ => rfl, Or.inr (Or.inr rfl), ?_⟩
    change Count (pendC 1) (pendC 0) 0 (n + 2) (n + 2)
    simp [Count, pendC_zero, pendC_one]
  obtain ⟨σ, hσ⟩ := exists_hist_of_isLadderPath fwdC bwdC _ hσp
  obtain ⟨ρ, hρ⟩ := exists_hist_of_isLadderPath fwdC bwdC _ hρp
  have h1 : PlusTruthAt MC σ 0 (nxtF (.stab (PlusFormula.neg pastIdleC))) := by
    refine h σ ?_
    rw [hs, hσ 0, gluePath_of_le _ _ 0 0 le_rfl, gC_zero_eq]
  rw [truth_nxtF] at h1
  have h2 : PlusTruthAt MC ρ (0 + 1) pastIdleC → False := by
    refine h1 ρ ?_
    rw [hσ (0 + 1), hρ (0 + 1), gluePath_of_gt _ _ 0 (0 + 1) (by norm_num),
      gluePath_of_gt _ _ 0 (0 + 1) (by norm_num)]
  refine h2 ((truth_pastIdleC ρ _ 0 (fun t => by rw [hρ t, add_zero]) (0 + 1)).mpr
    ⟨0, by norm_num, ?_⟩)
  change pendC (gluePath (gI (n + 2)) (fun v : ℤ => gC (n + 2) (n + 1) (v - 1)) 0 0).1.1 = false
  rw [gluePath_of_le _ _ 0 0 le_rfl]
  exact pendC_one

/-- **POSITIVE MEMBERSHIP: gap `n - c ≤ -4`.** At a pending state whose countdown exceeds its
register by at least four, every realized type contains the separating formula: one step on the
countdown still exceeds the register by at least two, and `cnt_le_nxt_succ_of_past_idle` leaves
such a state no history with an idle past. -/
private theorem thetaC_mem (c n : ℕ) (hgap : n + 4 ≤ c) (T : Finset PlusFormula)
    (hT : T ∈ cellAt MC thetaC
      ((0, stC c n) : (ladderFrameAdm stepC pendC fwdC bwdC).WorldState) 0) :
    thetaC ∈ T := by
  obtain ⟨τ, hs, rfl⟩ := hT
  rw [mem_tpOf_iff]
  refine ⟨self_mem_plusSubformulaClosure _, fun σ hσ => ?_⟩
  change PlusTruthAt MC σ 0 (nxtF (.stab (PlusFormula.neg pastIdleC)))
  rw [truth_nxtF]
  intro ρ hρ hpast
  obtain ⟨k, g, hg, hp⟩ := exists_isLadderPath_of_hist fwdC bwdC σ
  obtain ⟨k', g', hg', hp'⟩ := exists_isLadderPath_of_hist fwdC bwdC ρ
  have h0 : ((0, stC c n) : (ladderFrameAdm stepC pendC fwdC bwdC).WorldState) = (0 + k, g 0) :=
    hs.symm.trans (hσ.trans (hp 0))
  have hg0 : g 0 = stC c n := (congrArg Prod.snd h0).symm
  have h1 : ((0 + 1 + k, g (0 + 1)) : (ladderFrameAdm stepC pendC fwdC bwdC).WorldState)
      = (0 + 1 + k', g' (0 + 1)) := (hp (0 + 1)).symm.trans (hρ.trans (hp' (0 + 1)))
  have hg1 : g (0 + 1) = g' (0 + 1) := congrArg Prod.snd h1
  have hobj : objAt g 0 = 0 := by rw [objAt, hg0]; rfl
  have hcnt : cntAt g 0 = c := by rw [cntAt, hg0]; rfl
  have hnxt : nxtAt g 0 = n := by rw [nxtAt, hg0]; rfl
  have e1 : (0 : ℤ) + ((1 : ℕ) : ℤ) = 0 + 1 := by norm_num
  have hstep := cntAt_sub_of_pend g hg 0 (by rw [hobj]; exact pendC_zero) 1 (by omega)
  have hlip := nxtAt_lipschitz g hg 0 1
  rw [e1] at hstep hlip
  obtain ⟨s, hs1, hidle⟩ := (truth_pastIdleC ρ g' k' hp' (0 + 1)).mp hpast
  have hcap := cnt_le_nxt_succ_of_past_idle g' hg' (0 + 1) s hs1 hidle
    (by rw [show objAt g' (0 + 1) = objAt g (0 + 1) by rw [objAt, objAt, hg1]]; exact hstep.1)
  rw [show cntAt g' (0 + 1) = cntAt g (0 + 1) by rw [cntAt, cntAt, hg1],
    show nxtAt g' (0 + 1) = nxtAt g (0 + 1) by rw [nxtAt, nxtAt, hg1]] at hcap
  have hs2 := hstep.2
  omega

/-- **THE COLLISION.** At every threshold pair, every modulus and the gap clip `3`, the counter
pairs `(Tc + 3, Tc)` and `(Tc + 3 + (P + 1), Tc)` have the same class: both countdowns are at or
above `Tc`, they differ by the modulus, the register is shared, and both gaps are at or below
`-3`, where the clip stops reading. -/
private theorem kappa_collision_theta (Tc Tn P : ℕ) :
    kappa Tc Tn P 3 (Tc + 3, Tc) = kappa Tc Tn P 3 (Tc + 3 + (P + 1), Tc) := by
  unfold kappa
  refine Prod.ext (Fin.ext ?_) (Prod.ext (Fin.ext ?_) (Prod.ext rfl (Prod.ext rfl (Fin.ext ?_))))
  · change min (Tc + 3) Tc = min (Tc + 3 + (P + 1)) Tc
    omega
  · change (Tc + 3) % (P + 1) = (Tc + 3 + (P + 1)) % (P + 1)
    rw [Nat.add_mod_right]
  · change clipIdx 3 (Tc + 3) Tc = clipIdx 3 (Tc + 3 + (P + 1)) Tc
    unfold clipIdx
    split_ifs <;> omega

/-- **THE CELLS DIFFER.** -/
private theorem thetaC_cell_ne (n c' : ℕ) (hgap : n + 4 ≤ c') :
    cellAt MC thetaC ((0, stC (n + 3) n) : (ladderFrameAdm stepC pendC fwdC bwdC).WorldState) 0
      ≠ cellAt MC thetaC
          ((0, stC c' n) : (ladderFrameAdm stepC pendC fwdC bwdC).WorldState) 0 := by
  intro heq
  obtain ⟨T, hT⟩ := cellC_nonempty thetaC (n + 3) n
  exact thetaC_not_mem n T hT (thetaC_mem c' n hgap T (heq ▸ hT))

/-- (K4)'s least admissible gap clip at the separating formula is `3`. -/
private theorem clip_thetaC :
    max (2 * dBack thetaC + 1) (max (2 * dFwd thetaC + 1) 2) = 3 := rfl

end K4ClipWitness

open K4ClipWitness in
/-- **THE CELL AGREEMENT ON `kappa`-CLASSES FAILS AT (K4)'S CLIP.** There are a finite object, a
labelling, a formula `phi`, thresholds and a modulus satisfying `ParamsOk` at the gap clip
`B = max (2 * dBack phi + 1) (max (2 * dFwd phi + 1) 2)` — the least clip `paramsOkK4` admits, and
the value `Bof` outputs — together with a `kappa`-collision at those parameters whose two cells
DIFFER, at world time `0` and evaluation time `0`.

**Which quantifier fails.** The schema "for every finite object, labelling, formula and parameter
tuple satisfying `ParamsOk`, the cells of a `kappa`-collision are equal at every world time and
evaluation time" is false, and the binder it fails at is the one over the counter pairs of a
collision whose gaps `n - c` both lie below the clip. `kappa`'s gap coordinate is `clipIdx B`, which
stops reading at `-B`; (K4) asks only `B ≥ max (2 * dBack phi + 1) (2 * dFwd phi + 1) 2`; and a
formula carrying a `⊡` letter reads the gap further than that.

**The witness.** The object has two states, one pending and one idle, every transition allowed,
and the pending bit carried as the atom `p`. The formula is `⊡ X ⊡ ¬ P ¬p`, with
`dBack = dFwd = 1`, so the clip is `3`. The thresholds and modulus are the periodicity fixpoint's
own outputs `Tcof`, `Tnof`, `Pof`, discharged by `paramsOk_params`. The collision is the pair of
counter pairs `(Tc + 3, Tc)` and `(Tc + 3 + (P + 1), Tc)` at the pending state: both countdowns are
at or above `Tc`, they differ by the modulus, the register is shared, and the gaps are `-3` and
`-(P + 4)`, which the clip `3` identifies. The formula separates them: at gap `-3` no realized type
contains it, at every gap at or below `-4` every realized type does.

**What a larger clip does not repair.** The wired probe named in this section's header compiles a
second family (`dblC`, with `repaired_clip_refuted` and `gap_clip_below_exponential_refuted`) that
separates two gaps with equal `kappa`-images at EVERY clip `B < 2 ^ (dBack phi + 1)`, at every
threshold pair and modulus, so no clip polynomial in the two exactness depths makes the agreement
true. That strengthening is compiled in the probe only; this module carries no declaration of it,
and whether a clip exponential in `dBack` suffices is not known.

**Statement fidelity.** This is a statement about `ParamsOk` as `paramsOkK4` defines it in
`CounterQuotient.lean`. It proves no agreement and no fibre equation: the names
`cellAt_const_of_kappa_eq` and `ladderRealized` are carried by no declaration, and this theorem is
the negation of the first one's schema and of any fibre equation reading the cell off
`(q, kappa (c, n))` alone. It is not a device-discrimination claim, and every quantity named is a
count.

Paper: — (a refutation of this library's own counter quotient at its own gap clip; `kappa` and
(K4) have no literature counterpart) -/
theorem exists_kappa_collision_cellAt_ne_at_K4_clip :
    ∃ (Q : Type) (_ : Fintype Q) (_ : Nonempty Q)
      (step : Q → Q → Bool) (pend : Q → Bool) (lab : Q → Atom → Bool)
      (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
      (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
      (phi : PlusFormula) (Tc Tn P : ℕ) (q : Q) (c n c' n' : ℕ)
      (h : c ∈ Adm pend q) (h' : c' ∈ Adm pend q),
      ParamsOk step pend lab phi Tc Tn P (max (2 * dBack phi + 1) (max (2 * dFwd phi + 1) 2)) ∧
      kappa Tc Tn P (max (2 * dBack phi + 1) (max (2 * dFwd phi + 1) 2)) (c, n)
        = kappa Tc Tn P (max (2 * dBack phi + 1) (max (2 * dFwd phi + 1) 2)) (c', n') ∧
      cellAt (ladderModel step pend fwd bwd lab) phi
          ((0, ⟨(q, c, n), h⟩) : (ladderFrameAdm step pend fwd bwd).WorldState) 0
        ≠ cellAt (ladderModel step pend fwd bwd lab) phi
          ((0, ⟨(q, c', n'), h'⟩) : (ladderFrameAdm step pend fwd bwd).WorldState) 0 := by
  refine ⟨Qc, inferInstance, inferInstance, stepC, pendC, labC, fwdC, bwdC, thetaC,
    Tcof stepC pendC labC thetaC, Tnof stepC pendC labC thetaC, Pof stepC pendC labC thetaC,
    0, Tcof stepC pendC labC thetaC + 3, Tcof stepC pendC labC thetaC,
    Tcof stepC pendC labC thetaC + 3 + (Pof stepC pendC labC thetaC + 1),
    Tcof stepC pendC labC thetaC, admZeroC _ (Tcof stepC pendC labC thetaC),
    admZeroC _ (Tcof stepC pendC labC thetaC),
    paramsOk_params stepC pendC labC thetaC, ?_, ?_⟩
  · rw [clip_thetaC]
    exact kappa_collision_theta _ _ _
  · exact thetaC_cell_ne _ _ (by omega)

end FormalSystem.Metalogic.Decidability.RaySummary
