/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.Verified.Termination.MintBound.Invariants

/-! # A6. `OrdTimesLeMaxTime` at the branching shapes

This is the mirrored half of R1. A `.branching` step hands the *same* new ordering to every arm,
so an arm whose formula list omitted the fresh witness would hold an ordering edge to a time
absent from its own branch, and that arm's `nextTime` could then collide with the minted time.

The reading of the four branching mint sites is that this does not happen: `untlPos`, `sncePos`,
and the ACTIVE arms of `untlNeg` and `snceNeg` all build **both** arms at `freshLabel`, so each
arm's head already sits at the fresh time and dominates it. That reading is what the proof below
discharges — the `rfl` supplied for `hg` in each mint case is exactly the claim "this arm's head
sits at `b.nextTime`". -/

namespace FormalSystem.Metalogic.Decidability

open FormalSystem.Syntax

/-- The successor branches of a **branching** rule result. The `Option` analogue for the
non-branching shapes is `nonBranchingResultBranch`; the same goal-side phrasing applies, and for
the same reason. -/
def branchingResultBranches (b : Branch) : RuleResult → List Branch
  | .branching bss => bss.map (fun fs => fs ++ b)
  | _ => []

set_option maxHeartbeats 4000000 in
-- `repeat' split` case-splits every arm of the 36-constructor `applyRule` match; elaborating
-- all of them is past the default heartbeat budget.
/-- **`applyRule` preserves `OrdTimesLeMaxTime` at the `.branching` result shape**, for every arm.

The `.branchingOrdered` shape is deliberately not covered here: its per-arm orderings live in the
*result* rather than the second component, so it is handled at engine level where the arm list is
visible. -/
theorem applyRule_ordTimes_branching {rule : TableauRule} {sf : SignedFormula}
    {b : Branch} {ord : TimeOrdering}
    (hsf : sf ∈ b) (haux : OrdTimesLeMaxTime b ord) :
    ∀ nb ∈ branchingResultBranches b (applyRule rule sf b ord).1,
      OrdTimesLeMaxTime nb (applyRule rule sf b ord).2 := by
  have ht : sf.label.time ≤ b.maxTime := le_maxTime hsf
  cases sf with
  | mk sign formula label =>
    cases rule <;>
      (cases sign <;> simp only [applyRule] <;> (repeat' split) <;>
        first
          | contradiction
          | (intro nb hnb
             -- At a non-branching result `branchingResultBranches` is `[]`, so this `simp only`
             -- turns `hnb` into `False` and closes the goal outright; `all_goals` is what lets
             -- the branching alternatives below run only where a goal survives.
             simp only [branchingResultBranches, List.mem_map, List.not_mem_nil] at hnb
             all_goals first
               | (obtain ⟨fs, hfs, rfl⟩ := hnb
                  simp only [List.mem_cons, List.not_mem_nil, or_false] at hfs
                  rcases hfs with rfl | rfl <;>
                    first
                      | exact ordTimes_addFuture_cons haux ht rfl
                      | exact ordTimes_addPast_cons haux ht rfl)
               | (obtain ⟨fs, -, rfl⟩ := hnb
                  exact ordTimes_mono haux (maxTime_le_append _ _))))

/-- The successor branches of a step at the two shapes that carry the step's **own** ordering:
`.extended` reports one, `.split` reports its arms, and every arm of a split shares the single
ordering in the step's second component. `.splitOrdered` is excluded by construction — it carries
per-arm orderings inside the result, and `expandOnceUnblocked_splitOrdered_shape` is the lemma
that exposes them. -/
def unorderedSuccessorBranches : ExpansionResult → List Branch
  | .extended nb => [nb]
  | .split bs => bs
  | _ => []

/-- The branches a pick hands on, assembled from the two per-shape selectors. -/
def pickBranches (b : Branch) :
    Option (TableauRule × RuleResult × TimeOrdering) → List Branch
  | none => []
  | some (_, res, _) => (nonBranchingResultBranch b res).toList ++ branchingResultBranches b res

/-- The branch half of `pick_ord_eq`: uniformly across all five `RuleResult` shapes, the
result-tail's successor branches are `pickBranches`. -/
theorem pick_branches_eq {b : Branch} {ord : TimeOrdering}
    {pick : Option (TableauRule × RuleResult × TimeOrdering)} :
    unorderedSuccessorBranches
      (match pick with
        | none => (ExpansionResult.saturated, ord)
        | some (_, result, newOrd) =>
          match result with
          | .linear fs => (ExpansionResult.extended (fs ++ b), newOrd)
          | .branching bss => (ExpansionResult.split (bss.map fun fs => fs ++ b), newOrd)
          | .branchingOrdered bs' => (ExpansionResult.splitOrdered bs', newOrd)
          | .persistent fs => (ExpansionResult.extended (fs ++ b), newOrd)
          | .notApplicable => (ExpansionResult.saturated, newOrd)).1
      = pickBranches b pick := by
  rcases pick with _ | ⟨r, res, o⟩
  · rfl
  · cases res <;> rfl

/-- **The three-stage pick reports `applyRule`'s own pair for some formula on the branch.**

Packaging the three stages here, with the pick equation in a *hypothesis*, is what keeps the
engine-level proofs free of the nested-`match` reduction problem: `rw … at h` on an equation
hypothesis is the pattern `expandOnceUnblocked_extended_mem` already uses, whereas case-splitting
the same `match` in the goal leaves outer `match none with …` layers that block unification at the
application site. No `none` case is needed — the statement quantifies over a `some`. -/
theorem pick_stage_source (b : Branch) (ord : TimeOrdering)
    (fc : FormalSystem.ProofSystem.FrameClass) (tr : EventualityTracker) :
    ∀ r res o,
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
           | none => none) = some (r, res, o) →
      ∃ sf, sf ∈ b ∧ applyRule r sf b ord = (res, o) := by
  intro r res o h
  rcases hpick : findUnexpandedUnblockedWith b ord fc (blockedTimes b ord fc tr) with _ | sf
  · rw [hpick] at h
    rcases hser : b.find? (fun sf => !(blockedTimes b ord fc tr).contains sf.label.time
                             && (findApplicableSerialRule sf b ord).isSome) with _ | sf2
    · rw [hser] at h
      rcases hlin : b.find? (fun sf => !(blockedTimes b ord fc tr).contains sf.label.time
                               && (findApplicableLinearityRule sf b ord).isSome) with _ | sf3
      · rw [hlin] at h
        simp only at h
        exact absurd h (by simp)
      · rw [hlin] at h
        simp only at h
        exact ⟨sf3, List.mem_of_find?_eq_some hlin,
          findApplicableLinearityRule_applyRule_pair h⟩
    · rw [hser] at h
      simp only at h
      exact ⟨sf2, List.mem_of_find?_eq_some hser, findApplicableSerialRule_applyRule_pair h⟩
  · rw [hpick] at h
    simp only at h
    have hmem : sf ∈ b := by
      unfold findUnexpandedUnblockedWith at hpick
      exact List.mem_of_find?_eq_some hpick
    exact ⟨sf, hmem, findApplicableRule_applyRule_pair h⟩

/-- One pick stage preserves `OrdTimesLeMaxTime` at every successor branch it reports. This is
where the non-branching and branching `applyRule` lemmas are joined. -/
private theorem pickBranches_ordTimes {b : Branch} {ord : TimeOrdering}
    {p : Option (TableauRule × RuleResult × TimeOrdering)}
    (haux : OrdTimesLeMaxTime b ord)
    (hp : ∀ r res o, p = some (r, res, o) → ∃ sf, sf ∈ b ∧ applyRule r sf b ord = (res, o)) :
    ∀ nb ∈ pickBranches b p, OrdTimesLeMaxTime nb (pickOrd ord p) := by
  rcases p with _ | ⟨r, res, o⟩
  · simp [pickBranches]
  · obtain ⟨sf, hsf, hA⟩ := hp r res o rfl
    have h1 := applyRule_ordTimes_nonbranching (rule := r) (sf := sf) (b := b) (ord := ord)
      hsf haux
    have h2 := applyRule_ordTimes_branching (rule := r) (sf := sf) (b := b) (ord := ord)
      hsf haux
    rw [hA] at h1 h2
    intro nb hnb
    simp only [pickBranches] at hnb
    rcases List.mem_append.mp hnb with h | h
    · exact h1 nb (by simpa using h)
    · exact h2 nb h

/-- **Engine-level `OrdTimesLeMaxTime`, at `.extended` and at every arm of a `.split`.**

This is the mirrored half of R1 discharged: a `.branching` step does hand the same new ordering
to every arm, and every arm nonetheless dominates the minted time, because all four branching
mint sites build both arms at `freshLabel`. `.saturated` and `.splitOrdered` contribute no
successor branch here by construction. -/
theorem expandOnceUnblocked_ordTimes {b : Branch} {ord : TimeOrdering}
    {fc : FormalSystem.ProofSystem.FrameClass} {tr : EventualityTracker}
    (haux : OrdTimesLeMaxTime b ord) :
    ∀ nb ∈ unorderedSuccessorBranches (expandOnceUnblocked b ord fc tr).1,
      OrdTimesLeMaxTime nb (expandOnceUnblocked b ord fc tr).2 := by
  have keyO : (expandOnceUnblocked b ord fc tr).2
      = pickOrd ord
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
               | none => none) := pick_ord_eq
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
  rw [keyO, keyB]
  exact pickBranches_ordTimes haux (pick_stage_source b ord fc tr)

/-! ### `OrdTimesLeMaxTime` is REFUTED at the ordered split's identification arm

The statement above stops at `.extended` and `.split` for a reason that is a **fact, not a gap**.
`Branch.identifyTime t₂ t₁` can *lower* `Branch.maxTime` — it does so exactly when `t₂` was the
branch's largest time and `t₁` is smaller — while `TimeOrdering.identifyTime` leaves any
constraint not mentioning `t₂` completely untouched. A constraint whose times sit strictly
between `t₁` and `t₂` therefore survives the arm while the bound it was measured against drops
below it.

The refuting configuration below is machine-checked, and it belongs on the do-not-re-attempt
register alongside `witnessPresent_identifyTime_unconditional_false`: a future reader who assumes
`OrdTimesLeMaxTime` is a run invariant across *every* engine step will be re-attempting a refuted
statement.

**What this does and does not say.** It says the invariant *as defined* is not preserved by the
identification arm. It does not say the configuration is reachable from `initialBranch` — the
constraint `(3, 4)` mentions two times no formula on the branch carries, and every ordering edge
the engine actually builds runs between a branch time and a freshly minted one. Closing that gap
needs a **strictly stronger** invariant ("every ordering time is a *known branch time*", not
merely "≤ `maxTime`"), which is preserved at the arm because `rho` maps known times to known
times. That strengthening is not made here: `OrdTimesLeMaxTime` is what the landed density and
non-branching results already consume, and changing it would reopen them. -/

/-- **Counterexample: the identification arm does not preserve `OrdTimesLeMaxTime`.**

All four conjuncts are decided. The first three establish that the configuration is a *genuine*
ordered-split trigger satisfying both standing hypotheses — the ordering is irreflexive, the
invariant holds before the step, and `firstIncomparablePair` really does select `(0, 5)` — so the
failure in the fourth conjunct is attributable to the arm itself rather than to a violated
precondition. The branch's largest time `5` is the one identified away, and the surviving
constraint `(3, 4)` then exceeds the collapsed `maxTime` of `0`. -/
theorem ordTimes_identifyTime_arm3_false :
    letI p : Formula := .atom ⟨"p", none⟩
    letI q : Formula := .atom ⟨"q", none⟩
    letI b : Branch := [⟨.pos, p, ⟨0, 0⟩⟩, ⟨.pos, q, ⟨0, 5⟩⟩]
    letI ord : TimeOrdering := ⟨[(3, 4)]⟩
    IrreflOrd ord ∧ OrdTimesLeMaxTime b ord ∧
      firstIncomparablePair b ord = some (0, 5) ∧
      ¬ OrdTimesLeMaxTime (b.identifyTime 5 0) (ord.identifyTime 5 0) := by
  refine ⟨?_, ?_, by decide, ?_⟩
  · unfold IrreflOrd; decide
  · unfold OrdTimesLeMaxTime; decide
  · unfold OrdTimesLeMaxTime; decide

/-! ## A7. `OrdTimesKnown` — the strengthened ordering-times invariant

### Do-not-re-attempt

The preservation of `OrdTimesLeMaxTime` across the ordered split's identification arm is
**REFUTED**, not merely unproved: `ordTimes_identifyTime_arm3_false` just above decides a
configuration in which both standing hypotheses hold, `firstIncomparablePair` really does fire,
and the invariant nonetheless fails after the arm. A reader who assumes `OrdTimesLeMaxTime` is a
run invariant across *every* engine step — or who later "simplifies" the run invariant back to the
`≤ maxTime` form — is re-attempting a refuted statement.

The settled repair is `OrdTimesKnown` below, with `ordTimesKnown_identifyTime` supplying the arm-3
preservation the weak form cannot have. `ordTimesLeMaxTime_of_ordTimesKnown` records that this is a
**strengthening** rather than a weakening: every landed `OrdTimesLeMaxTime` result stays true, stays
in source, and stays reachable.

Root cause of the refutation, restated so the repair is legible: `Branch.identifyTime` measures the
ordering against a bound (`Branch.maxTime`) that the arm is free to move *downward* underneath a
surviving constraint. Membership in `Branch.knownTimes` has no such defect, because the arm relabels
the branch and the ordering by the **same** function `rho`, so the two move together. -/

/-- **The strengthened ordering-times invariant**: every time mentioned by the ordering is a
*known branch time*, rather than merely `≤ b.maxTime`.

This strengthens `OrdTimesLeMaxTime`, and `ordTimesLeMaxTime_of_ordTimesKnown` is the witness —
the weak form is derivable from this one, so every landed `OrdTimesLeMaxTime` consumer keeps
working and none of its producers is disturbed. The strengthening is necessary rather than
cosmetic: the weak form is **refuted** at the ordered split's identification arm by
`ordTimes_identifyTime_arm3_false`, while this form survives it unconditionally
(`ordTimesKnown_identifyTime`). -/
def OrdTimesKnown (b : Branch) (ord : TimeOrdering) : Prop :=
  ∀ p ∈ ord.constraints, p.1 ∈ b.knownTimes ∧ p.2 ∈ b.knownTimes

/-! ### Basic `knownTimes` facts -/

/-- A branch formula's time is a known time. -/
theorem mem_knownTimes_of_mem {b : Branch} {sf : SignedFormula} (h : sf ∈ b) :
    sf.label.time ∈ b.knownTimes := by
  simp only [Branch.knownTimes, List.mem_eraseDups, List.mem_map]
  exact ⟨sf, h, rfl⟩

/-- Conversely, a known time is carried by some branch formula. -/
theorem exists_mem_of_mem_knownTimes {b : Branch} {t : TimeIndex} (h : t ∈ b.knownTimes) :
    ∃ sf ∈ b, sf.label.time = t := by
  simp only [Branch.knownTimes, List.mem_eraseDups, List.mem_map] at h
  obtain ⟨sf, hsf, hEq⟩ := h
  exact ⟨sf, hsf, hEq⟩

/-- A known time is at or below `maxTime`. -/
theorem le_maxTime_of_mem_knownTimes {b : Branch} {t : TimeIndex} (h : t ∈ b.knownTimes) :
    t ≤ b.maxTime := by
  obtain ⟨sf, hsf, rfl⟩ := exists_mem_of_mem_knownTimes h
  exact le_maxTime hsf

/-- **The strengthening witness.** The strong invariant implies the weak one.

This is what makes the move to `OrdTimesKnown` a *strengthening* rather than the forbidden
weakening: every landed `OrdTimesLeMaxTime` consumer — `applyRule_irreflOrd` above chief among
them — keeps working unchanged, reached from the strong form through this one lemma. None of the
weak form's four producer lemmas is deleted, renamed, or restated; they remain true and simply go
unused by the strong chain. -/
theorem ordTimesLeMaxTime_of_ordTimesKnown {b : Branch} {ord : TimeOrdering}
    (h : OrdTimesKnown b ord) : OrdTimesLeMaxTime b ord := fun p hp =>
  ⟨le_maxTime_of_mem_knownTimes (h p hp).1, le_maxTime_of_mem_knownTimes (h p hp).2⟩

/-- **The refuting configuration dies under the strengthened invariant.**

The exact branch and ordering that refute `OrdTimesLeMaxTime` preservation at the identification
arm (`ordTimes_identifyTime_arm3_false` above) fail `OrdTimesKnown` at their *input*: the
constraint `(3, 4)` mentions two times no formula on the branch carries. So the counterexample
does not transfer, and the strengthening is not merely a different statement but a live repair. -/
theorem counterexample_dies :
    letI p : Formula := .atom ⟨"p", none⟩
    letI q : Formula := .atom ⟨"q", none⟩
    letI b : Branch := [⟨.pos, p, ⟨0, 0⟩⟩, ⟨.pos, q, ⟨0, 5⟩⟩]
    letI ord : TimeOrdering := ⟨[(3, 4)]⟩
    ¬ OrdTimesKnown b ord := by
  unfold OrdTimesKnown; decide

/-! ### Arm-3 preservation — the crux

`Branch.identifyTime` relabels by `rho src tgt`; `TimeOrdering.identifyTime` relabels its
constraint components by the same function. So the two move together, and membership survives. -/

/-- The branch half of the renaming acts on known times exactly as `rho` does. -/
theorem mem_knownTimes_identifyTime {b : Branch} {src tgt t : TimeIndex}
    (h : t ∈ b.knownTimes) : rho src tgt t ∈ (b.identifyTime src tgt).knownTimes := by
  obtain ⟨sf, hsf, rfl⟩ := exists_mem_of_mem_knownTimes h
  refine mem_knownTimes_of_mem (sf := rhoSF src tgt sf) ?_
  simp only [Branch.identifyTime, List.mem_eraseDups, List.mem_map]
  refine ⟨sf, hsf, ?_⟩
  by_cases hc : sf.label.time = src
  · simp [rhoSF, rho, hc]
  · simp [rhoSF, rho, hc]

/-- **Arm-3 preservation.** `OrdTimesKnown` IS preserved by the ordered split's identification arm.

Note it needs **no trigger hypotheses at all** — not `firstIncomparablePair`, not `IrreflOrd`. It
is a pure structural fact about branch and ordering being relabelled by the same `rho`, which is
strictly better than the weak form: `ordTimes_identifyTime_arm3_false` shows the weak form fails
here even *with* both hypotheses in hand. -/
theorem ordTimesKnown_identifyTime {b : Branch} {ord : TimeOrdering} {t₁ t₂ : TimeIndex}
    (h : OrdTimesKnown b ord) :
    OrdTimesKnown (b.identifyTime t₂ t₁) (ord.identifyTime t₂ t₁) := by
  rintro ⟨a, c⟩ hp
  simp only [TimeOrdering.identifyTime, List.mem_eraseDups, List.mem_filterMap] at hp
  obtain ⟨⟨x, y⟩, hxy, hres⟩ := hp
  by_cases hAB : (if x == t₂ then t₁ else x) = (if y == t₂ then t₁ else y)
  · rw [if_pos (by simpa using hAB)] at hres
    exact absurd hres (by simp)
  · rw [if_neg (by simpa using hAB)] at hres
    simp only [Option.some.injEq, Prod.mk.injEq] at hres
    obtain ⟨rfl, rfl⟩ := hres
    obtain ⟨hx, hy⟩ := h (x, y) hxy
    constructor
    · have := mem_knownTimes_identifyTime (src := t₂) (tgt := t₁) hx
      simpa only [rho, beq_iff_eq] using this
    · have := mem_knownTimes_identifyTime (src := t₂) (tgt := t₁) hy
      simpa only [rho, beq_iff_eq] using this

/-! ### Preservation at the mint sites

It is no use fixing arm 3 if the stronger invariant breaks at a mint site where the weaker one
held. The mint sites state their invariant against the POST-step branch `g :: rest ++ b`, where
`g` is the witness sitting at `b.nextTime`. -/

/-- Known times survive branch growth. -/
theorem knownTimes_mono {b nb : Branch} {t : TimeIndex} (hsub : ∀ x ∈ b, x ∈ nb)
    (h : t ∈ b.knownTimes) : t ∈ nb.knownTimes := by
  obtain ⟨sf, hsf, rfl⟩ := exists_mem_of_mem_knownTimes h
  exact mem_knownTimes_of_mem (hsub sf hsf)

/-- The strong invariant survives branch growth on its own, when the ordering does not change.
The `OrdTimesKnown` analogue of `ordTimes_mono`. -/
theorem ordTimesKnown_mono {b nb : Branch} {ord : TimeOrdering}
    (haux : OrdTimesKnown b ord) (hsub : ∀ x ∈ b, x ∈ nb) : OrdTimesKnown nb ord :=
  fun p hp => ⟨knownTimes_mono hsub (haux p hp).1, knownTimes_mono hsub (haux p hp).2⟩

/-- A mint step's new branch KNOWS the fresh time, because the witness sits there.
The `OrdTimesKnown` analogue of `nextTime_le_maxTime_cons`. -/
theorem nextTime_mem_knownTimes_cons {b : Branch} {g : SignedFormula}
    {rest : List SignedFormula} (hg : g.label.time = b.nextTime) :
    b.nextTime ∈ Branch.knownTimes (g :: rest ++ b) :=
  hg ▸ mem_knownTimes_of_mem (List.mem_append_left b List.mem_cons_self)

/-- Branch growth by prepending any list. Stated for a general `fs` rather than the `g :: rest`
shape, so it also covers the `.linear []` / `.persistent []` arms where the branch is unchanged. -/
private theorem sub_append {b : Branch} {fs : List SignedFormula} :
    ∀ x ∈ b, x ∈ (fs ++ b) := fun _ hx => List.mem_append_right _ hx

/-- Single-edge `addFuture` mint step preserves the strong invariant. -/
theorem ordTimesKnown_addFuture_cons {b : Branch} {ord : TimeOrdering} {t : TimeIndex}
    {g : SignedFormula} {rest : List SignedFormula}
    (haux : OrdTimesKnown b ord) (ht : t ∈ b.knownTimes)
    (hg : g.label.time = b.nextTime) :
    OrdTimesKnown (g :: rest ++ b) (ord.addFuture t b.nextTime) := by
  intro p hp
  simp only [TimeOrdering.addFuture, List.mem_cons] at hp
  rcases hp with rfl | hp
  · exact ⟨knownTimes_mono sub_append ht, nextTime_mem_knownTimes_cons hg⟩
  · exact ordTimesKnown_mono haux sub_append p hp

/-- Single-edge `addPast` mint step preserves the strong invariant. -/
theorem ordTimesKnown_addPast_cons {b : Branch} {ord : TimeOrdering} {t : TimeIndex}
    {g : SignedFormula} {rest : List SignedFormula}
    (haux : OrdTimesKnown b ord) (ht : t ∈ b.knownTimes)
    (hg : g.label.time = b.nextTime) :
    OrdTimesKnown (g :: rest ++ b) (ord.addPast t b.nextTime) := by
  intro p hp
  simp only [TimeOrdering.addPast, List.mem_cons] at hp
  rcases hp with rfl | hp
  · exact ⟨nextTime_mem_knownTimes_cons hg, knownTimes_mono sub_append ht⟩
  · exact ordTimesKnown_mono haux sub_append p hp

/-- `densityRule`'s two-edge mint step preserves the strong invariant.
The extra obligation is `t' ∈ b.knownTimes`, supplied by the invariant applied to the constraint
that put `t'` in the reach. -/
theorem ordTimesKnown_density_cons {b : Branch} {ord : TimeOrdering} {t t' : TimeIndex}
    {P : TimeIndex → Bool} {tail : List TimeIndex}
    {g : SignedFormula} {rest : List SignedFormula}
    (haux : OrdTimesKnown b ord) (ht : t ∈ b.knownTimes)
    (hg : g.label.time = b.nextTime)
    (heq : (ord.futureOf t).filter P = t' :: tail) :
    OrdTimesKnown (g :: rest ++ b) ((ord.addFuture t b.nextTime).addFuture b.nextTime t') := by
  have hmem : t' ∈ ord.futureOf t :=
    List.mem_of_mem_filter (by rw [heq]; exact List.mem_cons_self)
  obtain ⟨x, hx⟩ := exists_constraint_to_of_mem_futureOf ord t t' hmem
  have ht' : t' ∈ b.knownTimes := (haux (x, t') hx).2
  intro p hp
  simp only [TimeOrdering.addFuture, List.mem_cons] at hp
  rcases hp with rfl | rfl | hp
  · exact ⟨nextTime_mem_knownTimes_cons hg, knownTimes_mono sub_append ht'⟩
  · exact ⟨knownTimes_mono sub_append ht, nextTime_mem_knownTimes_cons hg⟩
  · exact ordTimesKnown_mono haux sub_append p hp

set_option maxHeartbeats 4000000 in
-- `repeat' split` case-splits every arm of the 36-constructor `applyRule` match; elaborating
-- all of them is past the default heartbeat budget.
/-- **`applyRule` preserves `OrdTimesKnown` at the non-branching result shapes** — the strong
analogue of `applyRule_ordTimes_nonbranching`, proved by the same tactic skeleton with the three
`_cons` lemmas swapped for their strong forms.

This is the load-bearing check: the strong invariant survives every one of the nine mint sites, so
nothing that held under the weak form is lost by strengthening. -/
theorem applyRule_ordTimesKnown_nonbranching {rule : TableauRule} {sf : SignedFormula}
    {b : Branch} {ord : TimeOrdering}
    (hsf : sf ∈ b) (haux : OrdTimesKnown b ord) :
    ∀ nb ∈ nonBranchingResultBranch b (applyRule rule sf b ord).1,
      OrdTimesKnown nb (applyRule rule sf b ord).2 := by
  have ht : sf.label.time ∈ b.knownTimes := mem_knownTimes_of_mem hsf
  cases sf with
  | mk sign formula label =>
    cases rule <;>
      (cases sign <;> simp only [applyRule] <;> (repeat' split) <;>
        first
          | contradiction
          | (intro nb hnb
             simp only [nonBranchingResultBranch, Option.mem_def, Option.some.injEq] at hnb
             first
               | (subst hnb
                  first
                    | exact ordTimesKnown_mono haux sub_append
                    | exact ordTimesKnown_addFuture_cons haux ht rfl
                    | exact ordTimesKnown_addPast_cons haux ht rfl
                    | exact ordTimesKnown_density_cons haux ht rfl (by assumption))
               | exact absurd hnb (by simp)))

/-- **Both non-identification arms of the ordered split preserve the strong invariant.**

Arms 1 and 2 keep the branch literally and add one ordering edge between the incomparable pair.
The strong invariant needs `t₁, t₂ ∈ b.knownTimes`, and the trigger supplies exactly that —
`firstIncomparablePair` scans `b.knownTimes`, so `firstIncomparablePair_spec` hands the two
membership facts over directly. This engine-level site is therefore free. -/
theorem ordTimesKnown_splitOrdered_arms12 {b : Branch} {ord : TimeOrdering} {t₁ t₂ : TimeIndex}
    (htrig : firstIncomparablePair b ord = some (t₁, t₂)) (haux : OrdTimesKnown b ord) :
    OrdTimesKnown b (ord.addFuture t₁ t₂) ∧ OrdTimesKnown b (ord.addFuture t₂ t₁) := by
  obtain ⟨h1, h2, -, -, -⟩ := firstIncomparablePair_spec htrig
  constructor <;> (intro p hp
                   simp only [TimeOrdering.addFuture, List.mem_cons] at hp
                   rcases hp with rfl | hp)
  · exact ⟨h1, h2⟩
  · exact haux p hp
  · exact ⟨h2, h1⟩
  · exact haux p hp

/-! ### The strong form re-derives the weak form's consumers unchanged -/

/-- `applyRule_irreflOrd` — the headline irreflexivity result above — is reachable from the strong
invariant with **no change to its proof**, by composing with `ordTimesLeMaxTime_of_ordTimesKnown`.
This is the concrete evidence that adding `OrdTimesKnown` alongside `OrdTimesLeMaxTime` touches no
already-proved result. -/
theorem applyRule_irreflOrd_from_known {rule : TableauRule} {sf : SignedFormula} {b : Branch}
    {ord : TimeOrdering} (hsf : sf ∈ b) (hord : IrreflOrd ord)
    (haux : OrdTimesKnown b ord) : IrreflOrd (applyRule rule sf b ord).2 :=
  applyRule_irreflOrd hsf hord (ordTimesLeMaxTime_of_ordTimesKnown haux)

/-- Likewise the density second-edge fact. -/
theorem ne_nextTime_from_known {b : Branch} {ord : TimeOrdering} {s t : TimeIndex}
    (haux : OrdTimesKnown b ord) (h : t ∈ ord.futureOf s) : b.nextTime ≠ t :=
  ne_nextTime_of_mem_futureOf (ordTimesLeMaxTime_of_ordTimesKnown haux) h

/-- **The initial condition.** The strong invariant holds at the engine's seed ordering.

This is **vacuously true, and the vacuity is a property of the seed rather than of a narrowed
statement**: `TimeOrdering.empty` is defined with `constraints := []`, and every engine run starts
there — both `buildTableauAt` and `buildTableau` call `expandBranchWithFuel` with
`TimeOrdering.empty` as the initial ordering. So there is no constraint to check, for any branch
whatsoever.

The distinction matters enough to state. A later reader meeting a base case that discharges by
`simp` must be able to tell, without re-deriving anything, that nothing was weakened to make it
close. The base case is vacuous; the inductive step — `applyRule_ordTimesKnown_nonbranching`,
`ordTimesKnown_splitOrdered_arms12`, and `ordTimesKnown_identifyTime` — carries all the content,
and none of those three is vacuous. -/
theorem ordTimesKnown_empty (b : Branch) : OrdTimesKnown b TimeOrdering.empty := by
  intro p hp
  simp [TimeOrdering.empty] at hp

/-! ### `OrdTimesKnown` at the branching shapes and at engine level

The weak engine-level twins just above — `applyRule_ordTimes_branching`, `pickBranches_ordTimes`,
`expandOnceUnblocked_ordTimes`, `expandOnceUnblocked_irreflOrd` — are **retained and still true**.
They are not superseded in the sense of being wrong; they are what the strong forms compose
through, and `expandOnceUnblocked_irreflOrd_of_known` below is literally one line of composition
over `expandOnceUnblocked_irreflOrd`.

The strong forms exist for one reason only: the weak invariant is **not carryable across the
ordered split's identification arm**, by `ordTimes_identifyTime_arm3_false`. An engine-level
statement threaded through `OrdTimesLeMaxTime` therefore cannot become a run invariant, however
many result shapes it covers. -/

set_option maxHeartbeats 4000000 in
-- `repeat' split` case-splits every arm of the 36-constructor `applyRule` match; elaborating
-- all of them is past the default heartbeat budget.
/-- **`applyRule` preserves `OrdTimesKnown` at the `.branching` result shape**, for every arm —
the strong analogue of `applyRule_ordTimes_branching`.

Proved by that theorem's own tactic skeleton, with `le_maxTime hsf` replaced by
`mem_knownTimes_of_mem hsf`, the two `_cons` lemmas replaced by their `ordTimesKnown_*` twins, and
the ordering-unchanged case discharged by `ordTimesKnown_mono … sub_append` where the weak form
used `ordTimes_mono … (maxTime_le_append _ _)`. Branch growth is identical: every arm is `fs ++ b`.

As with the weak twin, the `.branchingOrdered` shape is deliberately not covered here — its
per-arm orderings live in the *result* rather than the second component, so it is handled at
engine level where the arm list is visible. -/
theorem applyRule_ordTimesKnown_branching {rule : TableauRule} {sf : SignedFormula}
    {b : Branch} {ord : TimeOrdering}
    (hsf : sf ∈ b) (haux : OrdTimesKnown b ord) :
    ∀ nb ∈ branchingResultBranches b (applyRule rule sf b ord).1,
      OrdTimesKnown nb (applyRule rule sf b ord).2 := by
  have ht : sf.label.time ∈ b.knownTimes := mem_knownTimes_of_mem hsf
  cases sf with
  | mk sign formula label =>
    cases rule <;>
      (cases sign <;> simp only [applyRule] <;> (repeat' split) <;>
        first
          | contradiction
          | (intro nb hnb
             -- At a non-branching result `branchingResultBranches` is `[]`, so this `simp only`
             -- turns `hnb` into `False` and closes the goal outright; `all_goals` is what lets
             -- the branching alternatives below run only where a goal survives.
             simp only [branchingResultBranches, List.mem_map, List.not_mem_nil] at hnb
             all_goals first
               | (obtain ⟨fs, hfs, rfl⟩ := hnb
                  simp only [List.mem_cons, List.not_mem_nil, or_false] at hfs
                  rcases hfs with rfl | rfl <;>
                    first
                      | exact ordTimesKnown_addFuture_cons haux ht rfl
                      | exact ordTimesKnown_addPast_cons haux ht rfl)
               | (obtain ⟨fs, -, rfl⟩ := hnb
                  exact ordTimesKnown_mono haux sub_append)))

/-- One pick stage preserves `OrdTimesKnown` at every successor branch it reports. This is where
the non-branching and branching `applyRule` lemmas are joined, exactly as `pickBranches_ordTimes`
joins their weak twins. `pick_stage_source` is reused unchanged — it is invariant-agnostic. -/
private theorem pickBranches_ordTimesKnown {b : Branch} {ord : TimeOrdering}
    {p : Option (TableauRule × RuleResult × TimeOrdering)}
    (haux : OrdTimesKnown b ord)
    (hp : ∀ r res o, p = some (r, res, o) → ∃ sf, sf ∈ b ∧ applyRule r sf b ord = (res, o)) :
    ∀ nb ∈ pickBranches b p, OrdTimesKnown nb (pickOrd ord p) := by
  rcases p with _ | ⟨r, res, o⟩
  · simp [pickBranches]
  · obtain ⟨sf, hsf, hA⟩ := hp r res o rfl
    have h1 := applyRule_ordTimesKnown_nonbranching (rule := r) (sf := sf) (b := b) (ord := ord)
      hsf haux
    have h2 := applyRule_ordTimesKnown_branching (rule := r) (sf := sf) (b := b) (ord := ord)
      hsf haux
    rw [hA] at h1 h2
    intro nb hnb
    simp only [pickBranches] at hnb
    rcases List.mem_append.mp hnb with h | h
    · exact h1 nb (by simpa using h)
    · exact h2 nb h

/-- **Engine-level `OrdTimesKnown`, at `.extended` and at every arm of a `.split`.**

The strong analogue of `expandOnceUnblocked_ordTimes`, reusing the invariant-agnostic `pick_ord_eq`
and `pick_branches_eq` unchanged. `.saturated` contributes no successor branch; `.splitOrdered`
carries per-arm orderings inside the result and is handled by
`expandOnceUnblocked_splitOrdered_ordTimesKnown`. -/
theorem expandOnceUnblocked_ordTimesKnown {b : Branch} {ord : TimeOrdering}
    {fc : FormalSystem.ProofSystem.FrameClass} {tr : EventualityTracker}
    (haux : OrdTimesKnown b ord) :
    ∀ nb ∈ unorderedSuccessorBranches (expandOnceUnblocked b ord fc tr).1,
      OrdTimesKnown nb (expandOnceUnblocked b ord fc tr).2 := by
  have keyO : (expandOnceUnblocked b ord fc tr).2
      = pickOrd ord
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
               | none => none) := pick_ord_eq
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
  rw [keyO, keyB]
  exact pickBranches_ordTimesKnown haux (pick_stage_source b ord fc tr)

/-- **Engine-level irreflexivity from the strong invariant.**

No case analysis is re-done here: this composes the landed `expandOnceUnblocked_irreflOrd` with
`ordTimesLeMaxTime_of_ordTimesKnown`. It exists so that a run carrying `OrdTimesKnown` can feed
irreflexivity without also carrying the weak invariant separately. -/
theorem expandOnceUnblocked_irreflOrd_of_known {b : Branch} {ord : TimeOrdering}
    {fc : FormalSystem.ProofSystem.FrameClass} {tr : EventualityTracker}
    (hord : IrreflOrd ord) (haux : OrdTimesKnown b ord) :
    IrreflOrd (expandOnceUnblocked b ord fc tr).2 :=
  expandOnceUnblocked_irreflOrd hord (ordTimesLeMaxTime_of_ordTimesKnown haux)

/-! ## A8. The run invariant

This section closes the obligation the weak invariant could not meet.

`OrdTimesLeMaxTime` is **refuted** at the ordered split's identification arm
(`ordTimes_identifyTime_arm3_false`), so no amount of engine-level plumbing could have made the
pair `(IrreflOrd, OrdTimesLeMaxTime)` into a run invariant: a single ordered split destroys the
second component, and `IrreflOrd`'s own preservation at `applyRule` consumes it. The repair is
`ordTimesKnown_identifyTime`, which survives that same arm **unconditionally** — with neither the
`firstIncomparablePair` trigger nor `IrreflOrd` in hand — because branch and ordering are relabelled
by the same `rho`.

With arm 3 supplied, all three ordered-split arms close (`ordTimesKnown_splitOrdered_arms12` for
arms 1-2), and `RunInvariant` below is carryable across **every** expansion step. -/

/-- **The ordered split preserves `OrdTimesKnown` at all three arms** — the deliverable the
strengthening exists for.

`expandOnceUnblocked_splitOrdered_shape` supplies the exact three-arm list together with the
trigger. Arms 1-2 keep the branch literally and add one edge between the incomparable pair, closed
by `ordTimesKnown_splitOrdered_arms12` from the trigger alone; arm 3 is
`ordTimesKnown_identifyTime`, which needs neither the trigger nor `IrreflOrd`. -/
theorem expandOnceUnblocked_splitOrdered_ordTimesKnown
    {b : Branch} {bs : List (Branch × TimeOrdering)} {ord : TimeOrdering}
    {fc : FormalSystem.ProofSystem.FrameClass} {tr : EventualityTracker}
    (haux : OrdTimesKnown b ord)
    (h : (expandOnceUnblocked b ord fc tr).1 = ExpansionResult.splitOrdered bs) :
    ∀ p ∈ bs, OrdTimesKnown p.1 p.2 := by
  obtain ⟨t₁, t₂, htrig, rfl⟩ := expandOnceUnblocked_splitOrdered_shape h
  obtain ⟨harm1, harm2⟩ := ordTimesKnown_splitOrdered_arms12 htrig haux
  intro p hp
  simp only [List.mem_cons, List.not_mem_nil, or_false] at hp
  rcases hp with rfl | rfl | rfl
  · exact harm1
  · exact harm2
  · exact ordTimesKnown_identifyTime haux

/-- **The run invariant.** Irreflexivity of the ordering, plus every ordering time being a known
branch time.

Bundled under one name so the fuel induction and its consumers carry a single hypothesis rather
than spelling out a two-element bundle at every call site. The weak form `OrdTimesLeMaxTime` is
available from it by projection (`RunInvariant.ordTimesLeMaxTime`) wherever a landed consumer wants
it, so bundling loses nothing. -/
def RunInvariant (b : Branch) (ord : TimeOrdering) : Prop :=
  IrreflOrd ord ∧ OrdTimesKnown b ord

/-- The irreflexivity component. -/
theorem RunInvariant.irreflOrd {b : Branch} {ord : TimeOrdering} (h : RunInvariant b ord) :
    IrreflOrd ord := h.1

/-- The ordering-times component, in its strong form. -/
theorem RunInvariant.ordTimesKnown {b : Branch} {ord : TimeOrdering} (h : RunInvariant b ord) :
    OrdTimesKnown b ord := h.2

/-- The ordering-times component in the **weak** form the landed `OrdTimesLeMaxTime` consumers
take. This is the projection that keeps every already-proved result reachable. -/
theorem RunInvariant.ordTimesLeMaxTime {b : Branch} {ord : TimeOrdering} (h : RunInvariant b ord) :
    OrdTimesLeMaxTime b ord := ordTimesLeMaxTime_of_ordTimesKnown h.2

/-- **The run invariant holds at every successor of an unblocked expansion step**, across all four
`ExpansionResult` shapes.

The first conjunct covers `.extended` (one successor) and `.split` (its arms), which share the
step's own second-component ordering. The second conjunct covers `.splitOrdered`, whose per-arm
orderings live inside the result. `.saturated` produces no successor branch and satisfies both
conjuncts vacuously — by absence of successors, not by any weakening of the statement. -/
theorem expandOnceUnblocked_runInvariant {b : Branch} {ord : TimeOrdering}
    {fc : FormalSystem.ProofSystem.FrameClass} {tr : EventualityTracker}
    (hinv : RunInvariant b ord) :
    (∀ nb ∈ unorderedSuccessorBranches (expandOnceUnblocked b ord fc tr).1,
        RunInvariant nb (expandOnceUnblocked b ord fc tr).2) ∧
    (∀ bs, (expandOnceUnblocked b ord fc tr).1 = ExpansionResult.splitOrdered bs →
        ∀ p ∈ bs, RunInvariant p.1 p.2) := by
  obtain ⟨hord, haux⟩ := hinv
  constructor
  · intro nb hnb
    exact ⟨expandOnceUnblocked_irreflOrd_of_known hord haux,
      expandOnceUnblocked_ordTimesKnown haux nb hnb⟩
  · intro bs h p hp
    exact ⟨expandOnceUnblocked_splitOrdered_irreflOrd hord h p hp,
      expandOnceUnblocked_splitOrdered_ordTimesKnown haux h p hp⟩

/-- **The initial condition.** The run invariant holds at the engine's seed ordering, for every
branch.

Both components are **vacuously true, and the vacuity is a property of the seed rather than of a
narrowed statement**: `TimeOrdering.empty` has `constraints := []`, so there is no constraint to be
irreflexive about and none whose times need to be known. Every engine run starts there — both
`buildTableauAt` and `buildTableau` seed `expandBranchWithFuel` with `TimeOrdering.empty`.

Stated with the same care as `ordTimesKnown_empty`: a base case discharged by `simp` here is not
evidence that anything was weakened to make it close. The content lives in
`expandOnceUnblocked_runInvariant`, whose three ordered-split arms and nine mint sites are each
discharged by a non-vacuous lemma. -/
theorem runInvariant_initial (b : Branch) : RunInvariant b TimeOrdering.empty := by
  refine ⟨?_, ordTimesKnown_empty b⟩
  intro t ht
  simp [TimeOrdering.empty] at ht

/-! ## B4. `witnessPresent` monotonicity

Every clause of `witnessPresent` is a **positive** combination of `Branch.contains` tests and
`knownWorlds` / `futureOf` / `pastOf` membership tests, joined only by `any`, `||` and `&&`. There
is no negation anywhere in its body, so it is monotone in the branch and monotone in the ordering
separately. That is what makes "a witness, once present, stays present" available to the counting
argument, and it is read off the definition rather than assumed. -/

/-- `Branch.contains` is monotone in the branch. -/
theorem contains_mono {b nb : Branch} {sf : SignedFormula} (hsub : ∀ x ∈ b, x ∈ nb)
    (h : b.contains sf = true) : nb.contains sf = true := by
  simp only [Branch.contains, List.any_eq_true] at h ⊢
  obtain ⟨x, hx, hxe⟩ := h
  exact ⟨x, hsub x hx, hxe⟩

/-- Known worlds survive branch growth. The `knownWorlds` mirror of `knownTimes_mono`. -/
theorem knownWorlds_mono {b nb : Branch} {w : WorldIndex} (hsub : ∀ x ∈ b, x ∈ nb)
    (h : w ∈ b.knownWorlds) : w ∈ nb.knownWorlds := by
  simp only [Branch.knownWorlds, List.mem_eraseDups, List.mem_map] at h ⊢
  obtain ⟨sf, hsf, rfl⟩ := h
  exact ⟨sf, hsub sf hsf, rfl⟩

/-- **`witnessPresent` is monotone in the branch.** A witness found on a branch is still found on
any larger branch: each of the eight real arms is a `knownWorlds`/`futureOf`/`pastOf` search whose
body is a positive combination of `Branch.contains` tests, and only the `contains` tests and the
`knownWorlds` search depend on the branch. -/
theorem witnessPresent_branch_mono {rule : TableauRule} {sf : SignedFormula}
    {b nb : Branch} {ord : TimeOrdering} (hsub : ∀ x ∈ b, x ∈ nb) :
    witnessPresent rule sf b ord = true → witnessPresent rule sf nb ord = true := by
  cases sf with
  | mk sign formula label =>
    cases rule <;> cases sign <;> simp only [witnessPresent] <;> (repeat' split) <;>
      (try simp only [List.any_eq_true, Bool.or_eq_true, Bool.and_eq_true]) <;>
      first
        | exact fun h => Bool.noConfusion h
        | (rintro ⟨x, hx, hc⟩
           refine ⟨x, ?_, ?_⟩
           · first
               | exact hx
               | exact knownWorlds_mono hsub hx
           · first
               | exact contains_mono hsub hc
               | (rcases hc with hc | ⟨h1, h2⟩
                  · exact Or.inl (contains_mono hsub hc)
                  · exact Or.inr ⟨contains_mono hsub h1, contains_mono hsub h2⟩))

set_option maxHeartbeats 4000000 in
-- `first` tries the reachability-monotonicity lemmas on every arm of the 36-constructor x
-- 2-sign `witnessPresent` split; that is past the default heartbeat budget.
/-- **`witnessPresent` is monotone in the ordering.** Only the `futureOf` / `pastOf` searches
depend on the ordering, and both are monotone in the constraint list by the landed `futureOf_mono`
and `pastOf_mono`. The `knownWorlds` arms do not mention the ordering at all.

Carries the module's standing `maxHeartbeats 4000000`: the reachability-monotonicity lemmas are
tried by `first` across every arm of the 36-constructor × 2-sign split, and `futureOf_mono`'s
unification is not cheap. The figure is the one already established elsewhere in this module; it is
not raised. -/
theorem witnessPresent_ord_mono {rule : TableauRule} {sf : SignedFormula}
    {b : Branch} {ord ord' : TimeOrdering}
    (hsub : ∀ p ∈ ord.constraints, p ∈ ord'.constraints) :
    witnessPresent rule sf b ord = true → witnessPresent rule sf b ord' = true := by
  cases sf with
  | mk sign formula label =>
    cases rule <;> cases sign <;> simp only [witnessPresent] <;> (repeat' split) <;>
      (try simp only [List.any_eq_true, Bool.or_eq_true, Bool.and_eq_true]) <;>
      first
        | exact fun h => Bool.noConfusion h
        | (rintro ⟨x, hx, hc⟩
           refine ⟨x, ?_, hc⟩
           first
             | exact hx
             | exact TimeOrdering.futureOf_mono hsub _ _ hx
             | exact TimeOrdering.pastOf_mono hsub _ _ hx)

/-! ## B5. Engine-level growth, and one-step witness preservation

The two monotonicity lemmas above are stated against **abstract** growth hypotheses. Applying them
at an expansion step needs both growth facts supplied at engine level, and only one of the two was
available:

* **Branch growth** — `expandOnceUnblocked_split_subset` covers `.split`, and the `.extended`
  shape is `fs ++ b`; `expandOnceUnblocked_extended_shape` below records that shape and
  `expandOnceUnblocked_branch_mono` joins the two.
* **Ordering growth** — nothing like it was landed. `applyRule_ord_mono` proves it at rule level
  by the same case analysis the invariant lemmas use, and `expandOnceUnblocked_ord_mono` lifts it
  through the three pick stages.

Arm 3 of the ordered split is the one place where **neither** growth fact holds: the ordering is
*relabelled* there rather than extended, and the branch is `Branch.identifyTime`, which is not a
superset of the branch it came from. That arm is supplied instead by `arm3_preserves_witness`, and
it is why the `.splitOrdered` half of the statement below carries a disjunction over the
renaming. -/

/-- **`applyRule` never deletes an ordering constraint.**

Every rule either hands `ord` straight back, or prepends one edge (`addFuture` at the five forward
mint sites, `addPast` at the four backward ones), or prepends two (`densityRule`). `timeLinearity`
returns `ord` itself in this component — its per-arm orderings live inside the result, and their
growth is read off `expandOnceUnblocked_splitOrdered_shape` instead.

This is the ordering half of the growth `witnessPresent_ord_mono` consumes, and it did not exist
before: the landed `addFuture_constraints_mono` is a fact about one `TimeOrdering` operation, not
about `applyRule`'s ordering component. -/
theorem applyRule_ord_mono (rule : TableauRule) (sf : SignedFormula)
    (b : Branch) (ord : TimeOrdering) :
    ∀ q ∈ ord.constraints, q ∈ (applyRule rule sf b ord).2.constraints := by
  cases sf with
  | mk sign formula label =>
    cases rule <;>
      (cases sign <;> simp only [applyRule] <;> (repeat' split) <;>
        first
          | contradiction
          | (intro q hq
             first
               | exact hq
               | (simp only [TimeOrdering.addFuture, TimeOrdering.addPast, List.mem_cons]
                  tauto)))

/-- One pick stage never deletes an ordering constraint. The `none` stage threads `ord` through
unchanged; a `some` stage hands on `applyRule`'s own ordering, and `pick_stage_source` supplies the
formula it was called with. -/
theorem pickOrd_mono {b : Branch} {ord : TimeOrdering}
    {p : Option (TableauRule × RuleResult × TimeOrdering)}
    (hp : ∀ r res o, p = some (r, res, o) → ∃ sf, sf ∈ b ∧ applyRule r sf b ord = (res, o)) :
    ∀ q ∈ ord.constraints, q ∈ (pickOrd ord p).constraints := by
  rcases p with _ | ⟨r, res, o⟩
  · exact fun _ hq => hq
  · obtain ⟨sf, -, hA⟩ := hp r res o rfl
    have h1 := applyRule_ord_mono r sf b ord
    rw [hA] at h1
    exact h1

/-- **Engine-level ordering growth.** An unblocked expansion step never deletes an ordering
constraint from the step's own second component.

The `.splitOrdered` per-arm orderings are *not* covered by this — arm 3 relabels rather than
extends — and they are handled directly from `expandOnceUnblocked_splitOrdered_shape` in
`expandOnceUnblocked_preserves_witness`. -/
theorem expandOnceUnblocked_ord_mono {b : Branch} {ord : TimeOrdering}
    {fc : FormalSystem.ProofSystem.FrameClass} {tr : EventualityTracker} :
    ∀ q ∈ ord.constraints, q ∈ (expandOnceUnblocked b ord fc tr).2.constraints := by
  have keyO : (expandOnceUnblocked b ord fc tr).2
      = pickOrd ord
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
               | none => none) := pick_ord_eq
  rw [keyO]
  exact pickOrd_mono (pick_stage_source b ord fc tr)

/-- **Engine-level shape of an `.extended` step**: the reported branch is the picked rule's formula
list appended to the branch. The `.extended` mirror of `expandOnceUnblocked_split_shape`, which
`Fuel.lean` supplies for `.split` but not for `.extended`. -/
theorem expandOnceUnblocked_extended_shape {b nb : Branch} {ord : TimeOrdering}
    {fc : FormalSystem.ProofSystem.FrameClass} {tr : EventualityTracker}
    (h : (expandOnceUnblocked b ord fc tr).1 = ExpansionResult.extended nb) :
    ∃ fs : List SignedFormula, nb = fs ++ b := by
  unfold expandOnceUnblocked at h
  obtain ⟨_, fs, _, -, hnb⟩ := pick_extended h
  exact ⟨fs, hnb⟩

/-- **Engine-level branch growth**, at `.extended` and at every arm of a `.split`. Both shapes
append to the branch rather than replacing it: `.extended` by the shape lemma just above, `.split`
by the landed `expandOnceUnblocked_split_subset`. `.saturated` and `.splitOrdered` contribute no
unordered successor, so they hold by absence. -/
theorem expandOnceUnblocked_branch_mono {b : Branch} {ord : TimeOrdering}
    {fc : FormalSystem.ProofSystem.FrameClass} {tr : EventualityTracker} :
    ∀ nb ∈ unorderedSuccessorBranches (expandOnceUnblocked b ord fc tr).1, ∀ x ∈ b, x ∈ nb := by
  rcases hres : (expandOnceUnblocked b ord fc tr).1 with _ | nb' | bs | bs
  · simp [unorderedSuccessorBranches]
  · obtain ⟨fs, rfl⟩ := expandOnceUnblocked_extended_shape hres
    intro nb hnb x hx
    simp only [unorderedSuccessorBranches, List.mem_cons, List.not_mem_nil, or_false] at hnb
    subst hnb
    exact List.mem_append_right fs hx
  · intro nb hnb x hx
    simp only [unorderedSuccessorBranches] at hnb
    exact expandOnceUnblocked_split_subset hres hnb x hx
  · simp [unorderedSuccessorBranches]

/-- **One expansion step preserves a present witness**, across all four `ExpansionResult` shapes.

The first conjunct covers `.extended` (one successor) and `.split` (its arms), which share the
step's own ordering: the branch only grows (`expandOnceUnblocked_branch_mono`) and the ordering only
grows (`expandOnceUnblocked_ord_mono`), so the two monotonicity lemmas compose.

The second conjunct covers `.splitOrdered`, whose per-arm orderings live inside the result. Arms 1
and 2 keep the branch literally and add one edge between the incomparable pair, so ordering
monotonicity alone suffices; **arm 3** relabels both branch and ordering, and is
`arm3_preserves_witness` — which is why the arm-3 disjunct is about `rhoSF t₂ t₁ sf` rather than
`sf`. That renaming is not a weakening: it is the same formula carried along the identification the
arm performs, and it is the same form in which
`expandOnceUnblocked_splitOrdered_no_deletion` states non-deletion.

`.saturated` produces no successor branch and satisfies both conjuncts by absence of successors,
not by any weakening of the statement.

`RunInvariant` enters for one reason only: arm 3's `IrreflOrd` side condition. Both monotonicity
lemmas are invariant-free. -/
theorem expandOnceUnblocked_preserves_witness {b : Branch} {ord : TimeOrdering}
    {fc : FormalSystem.ProofSystem.FrameClass} {tr : EventualityTracker}
    {rule : TableauRule} {sf : SignedFormula}
    (hinv : RunInvariant b ord) (h : witnessPresent rule sf b ord = true) :
    (∀ nb ∈ unorderedSuccessorBranches (expandOnceUnblocked b ord fc tr).1,
        witnessPresent rule sf nb (expandOnceUnblocked b ord fc tr).2 = true) ∧
    (∀ bs t₁ t₂, (expandOnceUnblocked b ord fc tr).1 = ExpansionResult.splitOrdered bs →
        firstIncomparablePair b ord = some (t₁, t₂) →
        ∀ p ∈ bs, witnessPresent rule sf p.1 p.2 = true ∨
          witnessPresent rule (rhoSF (min t₁ t₂) (max t₁ t₂) sf) p.1 p.2 = true) := by
  constructor
  · intro nb hnb
    exact witnessPresent_branch_mono (expandOnceUnblocked_branch_mono nb hnb)
      (witnessPresent_ord_mono expandOnceUnblocked_ord_mono h)
  · intro bs t₁ t₂ hbs htrig
    obtain ⟨u₁, u₂, htrig', rfl⟩ := expandOnceUnblocked_splitOrdered_shape hbs
    rw [htrig] at htrig'
    obtain ⟨rfl, rfl⟩ : t₁ = u₁ ∧ t₂ = u₂ := by simpa using htrig'
    intro p hp
    simp only [List.mem_cons, List.not_mem_nil, or_false] at hp
    rcases hp with rfl | rfl | rfl
    · exact Or.inl (witnessPresent_ord_mono (addFuture_constraints_mono ord t₁ t₂) h)
    · exact Or.inl (witnessPresent_ord_mono (addFuture_constraints_mono ord t₂ t₁) h)
    · exact Or.inr (arm3_preserves_witness_oriented htrig hinv.irreflOrd rule sf h)

/-- **`witnessPresent` never flips `true → false` along a run**, up to the arm-3 renaming — the
corollary in the form the mint counting consumes.

Contrapositive of `expandOnceUnblocked_preserves_witness`. Read forwards: if a successor reports no
witness then the step it came from reported none either. At an ordered split, "the successor
reports no witness" has to mean *both* the formula and its arm-3 rename report none — that is what
makes the statement true at arm 3 rather than merely unrefuted there.

Stated against `RunInvariant` rather than a standalone `IrreflOrd` hypothesis, so a fuel induction
carrying the single bundled invariant can consume it directly. -/
theorem witnessPresent_no_flip {b : Branch} {ord : TimeOrdering}
    {fc : FormalSystem.ProofSystem.FrameClass} {tr : EventualityTracker}
    {rule : TableauRule} {sf : SignedFormula} (hinv : RunInvariant b ord) :
    (∀ nb ∈ unorderedSuccessorBranches (expandOnceUnblocked b ord fc tr).1,
        witnessPresent rule sf nb (expandOnceUnblocked b ord fc tr).2 = false →
          witnessPresent rule sf b ord = false) ∧
    (∀ bs t₁ t₂, (expandOnceUnblocked b ord fc tr).1 = ExpansionResult.splitOrdered bs →
        firstIncomparablePair b ord = some (t₁, t₂) →
        ∀ p ∈ bs, witnessPresent rule sf p.1 p.2 = false →
          witnessPresent rule (rhoSF (min t₁ t₂) (max t₁ t₂) sf) p.1 p.2 = false →
            witnessPresent rule sf b ord = false) := by
  constructor
  · intro nb hnb hfalse
    rcases hw : witnessPresent rule sf b ord with _ | _
    · rfl
    · rw [(expandOnceUnblocked_preserves_witness hinv hw).1 nb hnb] at hfalse
      exact Bool.noConfusion hfalse
  · intro bs t₁ t₂ hbs htrig p hp h1 h2
    rcases hw : witnessPresent rule sf b ord with _ | _
    · rfl
    · rcases (expandOnceUnblocked_preserves_witness hinv hw).2 bs t₁ t₂ hbs htrig p hp with ht | ht
      · rw [ht] at h1; exact Bool.noConfusion h1
      · rw [ht] at h2; exact Bool.noConfusion h2

end FormalSystem.Metalogic.Decidability
