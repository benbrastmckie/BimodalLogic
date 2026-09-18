/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.Verified.Termination.MintBound.ClosureResidual
import FormalSystem.Metalogic.Decidability.Verified.Termination.MintBound.TimeCensus

/-! # C11. Clause 1's label dimension, discharged from branch-side headroom

**What this section spends.** Section C10 left clause 1's label dimension as the named residual
`UnorderedSuccessorLabelClosed`, and its obligation map recorded one coordinate as available and one
as absent: the world coordinate had `applyRule_emitted_world_dichotomy`, and the time coordinate had
no statement at all bounding the times a rule emits at. Section D1 has since landed exactly that
statement — `applyRule_emitted_time_dichotomy`, together with the engine-level
`unorderedSuccessor_time_dichotomy`. This section spends it, and the accounting is now complete in
both coordinates.

**What completing the accounting does and does not buy.** It buys the *reduction*: the label
dimension of every unordered successor follows from a branch-side headroom condition, as a theorem
(`unorderedSuccessor_label_mem_of_headroom`), with nothing left unaccounted. It does **not** buy the
residual's discharge, and no lemma could have: clause 1 is *refuted* at a fixed finite
`signedUniverse C L` (`universeClosed_fresh_world_escapes`), and no condition on `L` repairs it
(`freshWorldHeadroom_not_universal`). So the residual survives — but it survives for a proved reason
rather than for a missing lemma, and that is the difference this section makes. The honest bracket
is stated as `freshLabelHeadroom_not_universal`.

**The rectangle, and why the world condition alone was never enough.** A label is a *pair*. The two
dichotomies are per-coordinate: a successor's worlds lie in `b.worldFinset ∪ {b.nextWorld}` and its
times lie in `b.knownTimes ∪ {b.nextTime}`, but nothing correlates the two, so four quadrants have
to be covered rather than two. `FreshWorldHeadroom` covers one of them. Confinement of `b` covers
*not even one*: `∀ x ∈ b, x.label ∈ L` says the pairs `b` actually carries are in `L`, which does
not put `⟨w, t⟩` in `L` for a `w` and a `t` that `b` carries on different formulas.
`FreshLabelHeadroom` is the rectangle the two dichotomies actually license, and
`freshWorldHeadroom_of_freshLabelHeadroom` records that it is the strictly stronger of the two. This
is the same rectangle shape `timeMergeClosed_iff_product` found on the clause-2 side, arrived at
from the opposite direction. -/

namespace FormalSystem.Metalogic.Decidability

open FormalSystem.Syntax

/-- **The world dichotomy at engine level.** Every world an unordered successor mentions is a world
`b` mentioned, or `b.nextWorld`. One step adds at most the one fresh world, and never more.

The exact counterpart of `unorderedSuccessor_time_dichotomy`, assembled the same way and through the
same invariant-agnostic machinery — `pick_branches_eq`, `pick_stage_source`, `resultBranch_sub` — so
the three-stage pick is not destructured a second time. It carries **no** auxiliary hypothesis where
its time twin carries `OrdTimesKnown b ord`: `applyRule_emitted_world_dichotomy` needs nothing,
since no rule propagates a world through the `TimeOrdering` the way four of them propagate times
through `futureOf` / `pastOf`. See `applyRule_emitted_time_mem_ordTimesKnown_needed` for why the
asymmetry is real rather than an artifact of the proof. -/
private theorem pickBranches_world_dichotomy {b : Branch} {ord : TimeOrdering}
    {p : Option (TableauRule × RuleResult × TimeOrdering)}
    (hp : ∀ r res o, p = some (r, res, o) → ∃ sf, sf ∈ b ∧ applyRule r sf b ord = (res, o)) :
    ∀ nb ∈ pickBranches b p, ∀ w ∈ nb.worldFinset, w ∈ b.worldFinset ∨ w = b.nextWorld := by
  rcases p with _ | ⟨r, res, o⟩
  · simp [pickBranches]
  · obtain ⟨sf, hsf, hA⟩ := hp r res o rfl
    intro nb hnb w hwm
    obtain ⟨-, hsub⟩ := resultBranch_sub (b := b) (nb := nb) (res := res) hnb
    obtain ⟨x, hx, rfl⟩ := exists_mem_of_mem_worldFinset hwm
    rcases hsub x hx with hxe | hxb
    · refine applyRule_emitted_world_dichotomy (rule := r) (sf := sf) (ord := ord) hsf x ?_
      rw [hA]
      exact hxe
    · exact Or.inl (Branch.mem_worldFinset hxb)

/-- **The world dichotomy, at the shape clause 1 quantifies at.** Every world an unordered successor
mentions is one `b` mentioned or `b.nextWorld`.

This is the world-coordinate half of the label accounting, at engine level. Its time twin is
`unorderedSuccessor_time_dichotomy`; together they are what
`unorderedSuccessor_label_mem_of_headroom` consumes. -/
theorem unorderedSuccessor_world_dichotomy {b : Branch} {ord : TimeOrdering}
    {fc : FormalSystem.ProofSystem.FrameClass} {tr : EventualityTracker} :
    ∀ nb ∈ unorderedSuccessorBranches (expandOnceUnblocked b ord fc tr).1,
      ∀ w ∈ nb.worldFinset, w ∈ b.worldFinset ∨ w = b.nextWorld := by
  have keyB : unorderedSuccessorBranches (expandOnceUnblocked b ord fc tr).1
      = pickBranches b
          (match findUnexpandedUnblockedWith b ord fc (blockedTimes b ord fc tr) with
           | some sf => findApplicableRule sf b ord fc
           | none =>
             match b.find? (fun sf => !(blockedTimes b ord fc tr).contains sf.label.time
                 && (findApplicableSerialRule sf b ord).isSome) with
             | some sf => findApplicableSerialRule sf b ord
             | none =>
               match b.find? (fun sf => !(blockedTimes b ord fc tr).contains sf.label.time
                   && (findApplicableLinearityRule sf b ord).isSome) with
               | some sf => findApplicableLinearityRule sf b ord
               | none => none) := pick_branches_eq
  rw [keyB]
  exact pickBranches_world_dichotomy (pick_stage_source b ord fc tr)

/-- **The branch-side headroom condition the label dimension actually needs**: the rectangle spanned
by the branch's worlds-plus-one against its times-plus-one lies in `L`.

Stated in exactly the shape the two dichotomies deliver — a disjunction per coordinate — so that no
step of `unorderedSuccessor_label_mem_of_headroom` has to reconcile a `Finset` form with a `List`
form. Four quadrants, not two, because the dichotomies are per-coordinate and nothing correlates
them; and the quadrant `⟨w, t⟩` with `w` and `t` both already on `b` is **not** free, because
confinement of `b` constrains the pairs `b` carries and not their cross product.

`FreshWorldHeadroom` is the third quadrant alone (`freshWorldHeadroom_of_freshLabelHeadroom`). Like
it, this is a condition on the **branch**: `freshLabelHeadroom_not_universal` proves it cannot be
moved into `L`. -/
def FreshLabelHeadroom (L : Finset Label) (b : Branch) : Prop :=
  ∀ w, (w ∈ b.worldFinset ∨ w = b.nextWorld) →
    ∀ t, (t ∈ b.knownTimes ∨ t = b.nextTime) → (⟨w, t⟩ : Label) ∈ L

/-- The rectangle condition is the strictly stronger of the two headroom conditions: it is
`FreshWorldHeadroom` plus the three quadrants that one omits. -/
theorem freshWorldHeadroom_of_freshLabelHeadroom {L : Finset Label} {b : Branch}
    (h : FreshLabelHeadroom L b) : FreshWorldHeadroom L b :=
  fun t ht => h b.nextWorld (Or.inr rfl) t (Or.inl ht)

/-- **Clause 1's label dimension, discharged.** Every formula on every unordered successor of an
`L`-confined branch with headroom sits at a label of `L`.

This is the statement the Phase 7 blocker named, and it is now a theorem rather than a hypothesis.
Both coordinates are accounted for and neither is assumed: `unorderedSuccessor_world_dichotomy` for
the world, `unorderedSuccessor_time_dichotomy` for the time, `FreshLabelHeadroom` for the four
quadrants they leave. Nothing else is used — in particular, confinement of `b` is **not** among the
hypotheses, because the headroom rectangle already subsumes what confinement would have supplied.

`OrdTimesKnown b ord` is inherited from the time dichotomy and is not new currency:
`ordTimesKnown_empty` supplies it at a run's seed and `expandOnceUnblocked_ordTimesKnown` propagates
it across every step, so nothing reaches the terminus that was not already there. -/
theorem unorderedSuccessor_label_mem_of_headroom {L : Finset Label} {b : Branch}
    {ord : TimeOrdering} {fc : FormalSystem.ProofSystem.FrameClass} {tr : EventualityTracker}
    (haux : OrdTimesKnown b ord) (hh : FreshLabelHeadroom L b) :
    ∀ nb ∈ unorderedSuccessorBranches (expandOnceUnblocked b ord fc tr).1,
      ∀ x ∈ nb, x.label ∈ L := by
  intro nb hnb x hx
  exact hh x.label.world
    (unorderedSuccessor_world_dichotomy nb hnb x.label.world (Branch.mem_worldFinset hx))
    x.label.time
    (unorderedSuccessor_time_dichotomy haux nb hnb x.label.time (mem_knownTimes_of_mem hx))

/-- **Clause 1 at `signedUniverse C L`, both dimensions, with no residual left standing.**

The composite the Phase 7 blocker was blocking. `TableauClosed C` and `TrichStock C` discharge the
formula coordinate via `unorderedSuccessor_formula_mem`; `FreshLabelHeadroom L b` discharges the
label coordinate via `unorderedSuccessor_label_mem_of_headroom`. Contrast
`unorderedSuccessor_confined_signedUniverse_of_headroom`, which is the same statement carrying
`UnorderedSuccessorLabelClosed fc L` as an unanalyzed hypothesis: that one is retained verbatim and
is what the landed terminus chain consumes; this one is the analysis of it.

The two are not interchangeable, and the difference is exactly the quantifier. This form is
**per-branch**: the headroom is a hypothesis about the `b` in front of it. The residual form
quantifies over every `L`-confined branch at once, and in that position the headroom is *refutable*
(`freshLabelHeadroom_not_universal`). So this theorem does not discharge the residual — see the
section note. -/
theorem unorderedSuccessor_confined_signedUniverse_of_freshLabelHeadroom {C : Finset Formula}
    {L : Finset Label} {fc : FormalSystem.ProofSystem.FrameClass}
    (hC : TableauClosed C) (hT : TrichStock C) :
    ∀ (b : Branch) (ord : TimeOrdering) (tr : EventualityTracker),
      OrdTimesKnown b ord → FreshLabelHeadroom L b →
      (∀ x ∈ b, x ∈ signedUniverse C L) →
      ∀ nb ∈ unorderedSuccessorBranches (expandOnceUnblocked b ord fc tr).1, ∀ x ∈ nb,
        x ∈ signedUniverse C L := by
  intro b ord tr haux hh hb nb hnb x hx
  have hbf : ∀ y ∈ b, y.formula ∈ C :=
    fun y hy => (formula_label_of_mem_signedUniverse (hb y hy)).1
  exact mem_signedUniverse
    (unorderedSuccessor_formula_mem hC hT hbf nb hnb x hx)
    (unorderedSuccessor_label_mem_of_headroom haux hh nb hnb x hx)

/-- **The residual, restated with the ordering hypothesis the time coordinate needs.**

`UnorderedSuccessorLabelClosed` quantifies over an arbitrary `TimeOrdering` with nothing tying it to
the branch, which is one hypothesis short of what `unorderedSuccessor_time_dichotomy` asks. This is
the same predicate with `OrdTimesKnown b ord` added, and it is therefore the *weaker* of the two —
`unorderedSuccessorLabelClosedOrd_of_unorderedSuccessorLabelClosed` records the implication. The
original is retained verbatim and is what the landed chain consumes; this one exists so that the
reduction below can be stated at all.

The added hypothesis is not a new cost at any consuming site:
`applyRule_emitted_time_mem_ordTimesKnown_needed` shows it is not removable, `ordTimesKnown_empty`
supplies it at a seed, and `expandOnceUnblocked_ordTimesKnown` propagates it. -/
def UnorderedSuccessorLabelClosedOrd (fc : FormalSystem.ProofSystem.FrameClass)
    (L : Finset Label) : Prop :=
  ∀ (b : Branch) (ord : TimeOrdering) (tr : EventualityTracker), OrdTimesKnown b ord →
    (∀ x ∈ b, x.label ∈ L) →
    ∀ nb ∈ unorderedSuccessorBranches (expandOnceUnblocked b ord fc tr).1, ∀ x ∈ nb, x.label ∈ L

/-- The ordering-hypothesis form is implied by the original, as adding a hypothesis always does. -/
theorem unorderedSuccessorLabelClosedOrd_of_unorderedSuccessorLabelClosed
    {fc : FormalSystem.ProofSystem.FrameClass} {L : Finset Label}
    (h : UnorderedSuccessorLabelClosed fc L) : UnorderedSuccessorLabelClosedOrd fc L :=
  fun b ord tr _ hbl => h b ord tr hbl

/-- **The reduction, complete.** The residual follows from branch-side headroom on every
`L`-confined branch. No coordinate is left unaccounted, and no hypothesis, placeholder or unfinished
step stands the two.

This is what section D1's arrival makes provable. Read together with
`freshLabelHeadroom_not_universal` it is also the *end* of the line: the antecedent is refutable at
every nonempty `L`, so the reduction is complete without being a discharge. -/
theorem unorderedSuccessorLabelClosedOrd_of_headroom
    {fc : FormalSystem.ProofSystem.FrameClass} {L : Finset Label}
    (h : ∀ b : Branch, (∀ x ∈ b, x.label ∈ L) → FreshLabelHeadroom L b) :
    UnorderedSuccessorLabelClosedOrd fc L :=
  fun b _ _ haux hbl => unorderedSuccessor_label_mem_of_headroom haux (h b hbl)

/-- **The rectangle cannot be moved into `L` either**, at every nonempty finite `L`.

Immediate from `freshWorldHeadroom_not_universal` through
`freshWorldHeadroom_of_freshLabelHeadroom`: the rectangle is the stronger condition, so refuting the
weaker one refutes it too. Stated separately because it is the load-bearing half of this section's
verdict — `unorderedSuccessorLabelClosedOrd_of_headroom` reduces the residual to exactly this
antecedent, and this says the antecedent is unavailable wherever the terminus is not vacuous.

So `UnorderedSuccessorLabelClosed` remains a residual, and now for a *proved* reason rather than for
a missing lemma. Register entry 11 records the finding; entry 21 records this refinement of it. -/
theorem freshLabelHeadroom_not_universal (L : Finset Label) (hne : L.Nonempty) :
    ¬ (∀ b : Branch, (∀ x ∈ b, x.label ∈ L) → FreshLabelHeadroom L b) :=
  fun h => freshWorldHeadroom_not_universal L hne
    fun b hb => freshWorldHeadroom_of_freshLabelHeadroom (h b hb)

/-- **The weakened residual is still refutable**, so the reduction above is not a reduction to
something already true.

The same witness `unorderedSuccessorLabelClosed_not_universal` uses, with the added ordering
hypothesis supplied by `ordTimesKnown_empty` — the witness runs at `TimeOrdering.empty`, so nothing
had to be rebuilt. Adding `OrdTimesKnown` to the residual therefore does not weaken it into
vacuity. -/
theorem unorderedSuccessorLabelClosedOrd_not_universal
    (fc : FormalSystem.ProofSystem.FrameClass) :
    ¬ UnorderedSuccessorLabelClosedOrd fc freshWorldLabels := by
  intro h
  have hstep := expandOnceUnblocked_freshWorldBranch fc EventualityTracker.empty
  have hmem : (freshWorldEmitted ++ freshWorldBranch)
      ∈ unorderedSuccessorBranches
        (expandOnceUnblocked freshWorldBranch TimeOrdering.empty fc
          EventualityTracker.empty).1 := by
    rw [hstep]; simp [unorderedSuccessorBranches]
  have hbl : ∀ y ∈ freshWorldBranch, y.label ∈ freshWorldLabels := by
    intro y hy
    simp only [freshWorldBranch, List.mem_cons, List.not_mem_nil, or_false] at hy
    subst hy
    simp [freshWorldLabels, freshWorldWitness, SignedFormula.neg]
  have hbad := h freshWorldBranch TimeOrdering.empty EventualityTracker.empty
    (ordTimesKnown_empty freshWorldBranch) hbl _ hmem
    (SignedFormula.neg fwp ⟨1, 0⟩) (by simp [freshWorldEmitted])
  simp [freshWorldLabels, SignedFormula.neg, Label.initial] at hbad

/-! ### The refutation generalizes: **every** nonempty `L`, not merely one witness

`unorderedSuccessorLabelClosed_not_universal` and `unorderedSuccessorLabelClosedOrd_not_universal`
refute the residual at one particular label set, `freshWorldLabels = {⟨0,0⟩}`. That is enough to
show it is not a theorem, but it leaves open the reading — which the earlier phrasing of register
entry 11 invited — that the residual might hold at *other* label sets, so that a consuming site
could be repaired by choosing `L` more carefully.

It cannot. The generalization is mechanical, and for a structural reason: the engine's shape gates
match a signed formula's **sign and formula constructor**, never its label. So `F(□p)` fires
`.boxNeg` at every label, not only at `Label.initial`, and what the rule emits always sits at the
branch's `Branch.nextWorld`, which at a one-formula branch labelled `l` is `l.world + 1` — this is
what `arAt_bn` below records, by `rfl`, with `l` a free variable. Running the witness at a label of
**maximal world** in `L` therefore puts the emission outside `L`'s world projection by maximality,
at every nonempty finite `L` and every frame class.

The other end is immediate: at `L = ∅` the confinement hypothesis `∀ x ∈ b, x.label ∈ L` forces
`b = []`, the pick finds nothing, and the conclusion holds vacuously. So the residual's
satisfiability set is **exactly `{∅}`** — and `∅` is precisely the case in which every theorem
carrying it as a hypothesis has an empty universe and says nothing.

The family below is stated **beside** the `freshWorld*` family, not in place of it: the
single-witness form is what the file's earlier sections cite, and it is not withdrawn. -/

section FreshWorldRefutationAtEveryLabel

/-- `F(□p)` at an arbitrary label — the label-generalized form of `freshWorldWitness`, which is
this at `Label.initial`. -/
def freshWorldWitnessAt (l : Label) : SignedFormula := SignedFormula.neg (Formula.box fwp) l

/-- The witness branch at `l`. One formula, so its only world is `l.world` and its next world is
`l.world + 1`. -/
def freshWorldBranchAt (l : Label) : Branch := [freshWorldWitnessAt l]

/-- What `boxNeg` emits at the witness: `F(p)` at world `l.world + 1`, the fresh world, with the
time coordinate carried across unchanged. -/
def freshWorldEmittedAt (l : Label) : List SignedFormula :=
  [SignedFormula.neg fwp ⟨l.world + 1, l.time⟩]

private theorem iaAt_ug (fc : FormalSystem.ProofSystem.FrameClass) (l : Label) :
    isApplicable .priorUGap (freshWorldWitnessAt l) fc = false := rfl
private theorem iaAt_sg (fc : FormalSystem.ProofSystem.FrameClass) (l : Label) :
    isApplicable .priorSGap (freshWorldWitnessAt l) fc = false := rfl
private theorem iaAt_sep (fc : FormalSystem.ProofSystem.FrameClass) (l : Label) :
    isApplicable .sepRule (freshWorldWitnessAt l) fc = false := rfl
private theorem iaAt_np (fc : FormalSystem.ProofSystem.FrameClass) (l : Label) :
    isApplicable .negPos (freshWorldWitnessAt l) fc = false := rfl
private theorem iaAt_nn (fc : FormalSystem.ProofSystem.FrameClass) (l : Label) :
    isApplicable .negNeg (freshWorldWitnessAt l) fc = false := rfl
private theorem iaAt_in (fc : FormalSystem.ProofSystem.FrameClass) (l : Label) :
    isApplicable .impNeg (freshWorldWitnessAt l) fc = false := rfl
private theorem iaAt_ap (fc : FormalSystem.ProofSystem.FrameClass) (l : Label) :
    isApplicable .andPos (freshWorldWitnessAt l) fc = false := rfl
private theorem iaAt_on (fc : FormalSystem.ProofSystem.FrameClass) (l : Label) :
    isApplicable .orNeg (freshWorldWitnessAt l) fc = false := rfl
private theorem iaAt_bp (fc : FormalSystem.ProofSystem.FrameClass) (l : Label) :
    isApplicable .boxPos (freshWorldWitnessAt l) fc = false := rfl
private theorem iaAt_bn (fc : FormalSystem.ProofSystem.FrameClass) (l : Label) :
    isApplicable .boxNeg (freshWorldWitnessAt l) fc = true := rfl
/-- **The label-independence of the emission, stated as a `rfl` fact with `l` free.** This is the
one line that carries the whole generalization: the rule's output is computed from the branch's
`Branch.nextWorld`, and at a one-formula branch that is `l.world + 1` for whatever `l` is. -/
private theorem arAt_bn (l : Label) :
    applyRule .boxNeg (freshWorldWitnessAt l) (freshWorldBranchAt l) TimeOrdering.empty
      = (RuleResult.linear (freshWorldEmittedAt l), TimeOrdering.empty) := rfl
private theorem wpAt_bn (l : Label) :
    witnessPresent .boxNeg (freshWorldWitnessAt l) (freshWorldBranchAt l) TimeOrdering.empty
      = false := rfl
private theorem twAt_bn (l : Label) :
    trivialEventWitnessed .boxNeg (freshWorldWitnessAt l) (freshWorldBranchAt l) TimeOrdering.empty
      = false := rfl

-- `rm_bn` (`ruleMintsFreshLabel .boxNeg = true`) is reused rather than restated: it mentions no
-- witness and no label, so the label-generalized family needs no variant of it.
attribute [local simp] iaAt_ug iaAt_sg iaAt_sep iaAt_np iaAt_nn iaAt_in iaAt_ap iaAt_on iaAt_bp
  iaAt_bn arAt_bn rm_bn wpAt_bn twAt_bn

/-- **`.boxNeg` is the rule the engine picks at the witness, at every frame class and every label.**
Exactly `findApplicableRule_freshWorldWitness`'s argument with `l` free: the nine rules ahead of
`.boxNeg` are inapplicable to a `.neg`-signed box regardless of where it sits, and the Dense and
Discrete blocks are *appended* after the base rules by `allRulesForFC`, so neither can pre-empt it.
-/
theorem findApplicableRule_freshWorldWitnessAt
    (fc : FormalSystem.ProofSystem.FrameClass) (l : Label) :
    findApplicableRule (freshWorldWitnessAt l) (freshWorldBranchAt l) TimeOrdering.empty fc
      = some (TableauRule.boxNeg, RuleResult.linear (freshWorldEmittedAt l),
          TimeOrdering.empty) := by
  simp only [findApplicableRule, allRulesForFC, allRules, rTimeRules]
  by_cases hd : FormalSystem.ProofSystem.FrameClass.RTime ≤ fc
  · simp [hd, List.findSome?]
  · simp [hd, List.findSome?]

/-- **The step fires at the witness, at every frame class, tracker and label.** Blocking is empty
(`blockedTimes_empty`), the pick short-circuits on the single formula, and the result carries a
formula at world `l.world + 1`. -/
theorem expandOnceUnblocked_freshWorldBranchAt
    (fc : FormalSystem.ProofSystem.FrameClass) (tr : EventualityTracker) (l : Label) :
    (expandOnceUnblocked (freshWorldBranchAt l) TimeOrdering.empty fc tr).1
      = ExpansionResult.extended (freshWorldEmittedAt l ++ freshWorldBranchAt l) := by
  have hrule := findApplicableRule_freshWorldWitnessAt fc l
  simp only [freshWorldBranchAt] at hrule
  rw [expandOnceUnblocked]
  simp only [blockedTimes_empty, findUnexpandedUnblockedWith, isExpanded, freshWorldBranchAt,
    List.find?_cons, List.contains_nil, Bool.not_false, Bool.and_true, hrule,
    Option.isNone_some]

/-- **The `Ord` form of the residual is false at every nonempty finite `L`, at every frame class.**

Run the witness at a label `l₀ ∈ L` whose world is maximal in `L.image (·.world)`. The step fires
(`expandOnceUnblocked_freshWorldBranchAt`), the extended branch is an unordered successor, and the
emitted formula sits at world `l₀.world + 1`. If the residual held, that label would be in `L`, so
`l₀.world + 1 ≤ max' (L.image (·.world)) = l₀.world` — impossible.

Stated at the `Ord` form because that is the **weaker** predicate: `OrdTimesKnown` is supplied for
free at `TimeOrdering.empty` by `ordTimesKnown_empty`, so the added hypothesis costs the refutation
nothing, and refuting the weaker predicate refutes the stronger one too. -/
theorem unorderedSuccessorLabelClosedOrd_nonempty_false
    (fc : FormalSystem.ProofSystem.FrameClass) (L : Finset Label) (hne : L.Nonempty) :
    ¬ UnorderedSuccessorLabelClosedOrd fc L := by
  intro h
  have hine : (L.image (·.world)).Nonempty := hne.image _
  obtain ⟨l₀, hl₀, hl₀w⟩ := Finset.mem_image.mp ((L.image (·.world)).max'_mem hine)
  have hstep := expandOnceUnblocked_freshWorldBranchAt fc EventualityTracker.empty l₀
  have hmem : (freshWorldEmittedAt l₀ ++ freshWorldBranchAt l₀)
      ∈ unorderedSuccessorBranches
        (expandOnceUnblocked (freshWorldBranchAt l₀) TimeOrdering.empty fc
          EventualityTracker.empty).1 := by
    rw [hstep]; simp [unorderedSuccessorBranches]
  have hbl : ∀ y ∈ freshWorldBranchAt l₀, y.label ∈ L := by
    intro y hy
    simp only [freshWorldBranchAt, List.mem_cons, List.not_mem_nil, or_false] at hy
    subst hy
    simpa [freshWorldWitnessAt, SignedFormula.neg] using hl₀
  have hbad := h (freshWorldBranchAt l₀) TimeOrdering.empty EventualityTracker.empty
    (ordTimesKnown_empty (freshWorldBranchAt l₀)) hbl _ hmem
    (SignedFormula.neg fwp ⟨l₀.world + 1, l₀.time⟩) (by simp [freshWorldEmittedAt])
  simp only [SignedFormula.neg] at hbad
  have hle : l₀.world + 1 ≤ (L.image (·.world)).max' hine :=
    Finset.le_max' (L.image (·.world)) (l₀.world + 1)
      (Finset.mem_image.mpr ⟨⟨l₀.world + 1, l₀.time⟩, hbad, rfl⟩)
  rw [hl₀w] at hle
  exact absurd hle (Nat.not_succ_le_self _)

/-- **The residual itself is false at every nonempty finite `L`, at every frame class.**

One line from the `Ord` form through
`unorderedSuccessorLabelClosedOrd_of_unorderedSuccessorLabelClosed`, so the file carries a single
refutation argument rather than two copies of it.

This is the statement any downstream artifact should cite. It says that
`unorderedSuccessorLabelClosed_not_universal`'s single witness was not a peculiarity of
`freshWorldLabels`: there is no finite nonempty label set at which the residual can be assumed, and
so every theorem carrying it as a live hypothesis is a vacuously true conditional wherever its
universe is nonempty. -/
theorem unorderedSuccessorLabelClosed_nonempty_false
    (fc : FormalSystem.ProofSystem.FrameClass) (L : Finset Label) (hne : L.Nonempty) :
    ¬ UnorderedSuccessorLabelClosed fc L :=
  fun h => unorderedSuccessorLabelClosedOrd_nonempty_false fc L hne
    (unorderedSuccessorLabelClosedOrd_of_unorderedSuccessorLabelClosed h)

/-- **And it is true at `∅`** — which, with the refutation above, pins the residual's satisfiability
set to exactly `{∅}`.

Not a discharge in any useful sense: confinement to `∅` forces `b = []`, the pick finds no
unexpanded formula, and `unorderedSuccessorBranches` of a non-firing step is empty, so the
conclusion is quantified over nothing. It is recorded because "refuted at every nonempty `L`" and
"refuted outright" are different statements, and the register should assert the one that is true. -/
theorem unorderedSuccessorLabelClosed_empty
    (fc : FormalSystem.ProofSystem.FrameClass) :
    UnorderedSuccessorLabelClosed fc (∅ : Finset Label) := by
  intro b ord tr hbl nb hnb x hx
  have hb : b = [] := by
    rcases b with _ | ⟨y, ys⟩
    · rfl
    · exact absurd (hbl y (by simp)) (by simp)
  subst hb
  rw [expandOnceUnblocked] at hnb
  simp only [findUnexpandedUnblockedWith, List.find?_nil] at hnb
  simp [unorderedSuccessorBranches] at hnb

end FreshWorldRefutationAtEveryLabel

end FormalSystem.Metalogic.Decidability
