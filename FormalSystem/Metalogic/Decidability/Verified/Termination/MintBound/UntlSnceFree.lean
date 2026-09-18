/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.Verified.Termination.MintBound.SigmaFixed

/-! # D3. The residual, discharged at a **nonempty** universe: the `untl`/`snce`-free fragment

**What this section delivers.** `MintPaysForTime fc U Tmax` — the predicate this file started from,
not a repair of it — proved outright, at every frame class and every `Tmax`, for every universe
whose formulas carry no `untl` and no `snce` node. Section D2 left the predicate discharged only at
`U = ∅` (`mintPaysForTime_empty`); this section moves the boundary off the empty universe and onto a
syntactic condition that a genuinely nonempty stock satisfies — in particular the whole **modal
fragment**: atoms, `⊥`, `→`, `□`, and everything built from them, which is `S5` over a single
moment sitting inside the bimodal language.

**Why the two blockers section D2 records do not bite here.** They are both blockers on a *time
mint*, and in this fragment no time is ever minted at all:

* *The engine-level assembly.* D2's residual blocker needs the picked rule's identity threaded to
  the successor so a **per-rule payment** (disjunct 2 or 3) can be cashed there. Here no payment is
  ever needed: the argument runs entirely in disjunct 1, and disjunct 1 is uniform in the rule. All
  the pick has to supply is the *negative* fact `ruleMintsFreshTime r = false`, which
  `pick_stage_source_noMint` reads straight off `isApplicable` without destructuring a single rule
  arm.
* *The density coordinate.* `densityRule` is the rule register entries 17 and 20 name as reachable
  by no disjunct for any `σ` whatsoever. It is nonetheless harmless here, and for a reason that is
  worth stating because it is not the frame-class gate: `isApplicable .densityRule sf fc` requires
  `sf.formula` to match `.allFuture _`, and `Formula.allFuture φ` is
  `((⊥ → ⊥) untl (φ → ⊥)) → ⊥` — an `untl` node. So the shape gate rejects it before the
  `Dense ≤ fc` gate is ever consulted, and the discharge below carries **no frame-class
  restriction**. That is strictly better than the "every frame class except `.Dense`/`.RTime`"
  outcome D2's blocker anticipated.

**The shape of the argument, in one line.** Every one of the nine members of `freshTimeRules` is
gated by `isApplicable` on a formula shape that contains an `untl` or an `snce` node
(`allFutureNeg`, `allPastNeg`, `densityRule` through the `allFuture`/`allPast` abbreviations;
`someFuturePos`, `somePastPos`, `untlPos`, `sncePos`, `untlNeg`, `snceNeg` through their `as…?`
views). The engine's other two stages run exactly one rule each — `serialityRule` and
`timeLinearity` — and neither is in the census. So on an `untl`/`snce`-free branch the picked rule
never mints, `applyRule_emitted_time_mem` applies at every emission, and the successor's known
times are a subset of the predecessor's. Both of disjunct 1's conjuncts follow: the cardinality
directly, and the rank because `splitOrderedRank` is monotone in `knownTimes` and antitone in the
constraint list, which `expandOnceUnblocked_ord_mono` only ever extends.

**What this is not.** It is not a discharge at a universe containing a temporal operator, and it
cannot be turned into one: `mintPaysForTime_untlNeg_false` refutes the predicate at a universe whose
formulas are `untl`-headed, so the syntactic condition below is not removable. The two named next
steps of register entry 20 stand unchanged for the temporal fragment. -/

namespace FormalSystem.Metalogic.Decidability

open FormalSystem.Syntax

/-- **The syntactic condition**: no `untl` and no `snce` node anywhere in the formula.

Stated on the raw constructors rather than on the `as…?` views, so it is manifestly closed under
subformulas and manifestly satisfied by the modal fragment. It is *sufficient* rather than
necessary — `asUntil?` also rejects `untl ⊤ φ`, and `isApplicable` rejects some shapes this
predicate admits — and sufficiency is all the discharge needs. -/
def untlSnceFree : Formula → Bool
  | .atom _ => true
  | .bot => true
  | .imp a b => untlSnceFree a && untlSnceFree b
  | .box a => untlSnceFree a
  | .untl _ _ => false
  | .snce _ _ => false

/-- The modal fragment is `untl`/`snce`-free: `□` preserves the condition. -/
theorem untlSnceFree_box {φ : Formula} (h : untlSnceFree φ = true) :
    untlSnceFree φ.box = true := by simpa [untlSnceFree] using h

/-- …and so does `→`, hence `¬`, `∧`, `∨` and `◇` as well, all of which are `imp`/`box` composites
in this language. -/
theorem untlSnceFree_imp {φ ψ : Formula} (hφ : untlSnceFree φ = true)
    (hψ : untlSnceFree ψ = true) : untlSnceFree (φ.imp ψ) = true := by
  simp [untlSnceFree, hφ, hψ]

/-! ### The six shape views, all `none` on an `untl`/`snce`-free formula

One per `as…?` view `isApplicable` consults for a time-minting rule. Each is a two-line `cases`;
they are listed separately rather than bundled because `isApplicable`'s arms consult them
individually and the sweep below feeds them in by name. -/

theorem asUntil_eq_none_of_untlSnceFree {φ : Formula} (h : untlSnceFree φ = true) :
    asUntil? φ = none := by
  cases φ <;> simp_all [untlSnceFree, asUntil?]

theorem asSince_eq_none_of_untlSnceFree {φ : Formula} (h : untlSnceFree φ = true) :
    asSince? φ = none := by
  cases φ <;> simp_all [untlSnceFree, asSince?]

theorem asSomeFuture_eq_none_of_untlSnceFree {φ : Formula} (h : untlSnceFree φ = true) :
    asSomeFuture? φ = none := by
  cases φ <;> simp_all [untlSnceFree, asSomeFuture?]

theorem asSomePast_eq_none_of_untlSnceFree {φ : Formula} (h : untlSnceFree φ = true) :
    asSomePast? φ = none := by
  cases φ <;> simp_all [untlSnceFree, asSomePast?]

/-- The `allFuture` view needs one extra split: `Formula.allFuture φ` is an `imp` whose *antecedent*
is the `untl` node, so the condition has to be pushed through the implication before the
contradiction is visible. -/
theorem asAllFuture_eq_none_of_untlSnceFree {φ : Formula} (h : untlSnceFree φ = true) :
    asAllFuture? φ = none := by
  cases φ with
  | imp a b => cases a <;> simp_all [untlSnceFree, asAllFuture?]
  | _ => simp_all [untlSnceFree, asAllFuture?]

/-- The past mirror. -/
theorem asAllPast_eq_none_of_untlSnceFree {φ : Formula} (h : untlSnceFree φ = true) :
    asAllPast? φ = none := by
  cases φ with
  | imp a b => cases a <;> simp_all [untlSnceFree, asAllPast?]
  | _ => simp_all [untlSnceFree, asAllPast?]

/-- **No time-minting rule is applicable to an `untl`/`snce`-free formula**, at any frame class.

The nine-arm sweep over `freshTimeRules`, run against `isApplicable`'s own match. Note what does
*not* appear in the proof: no frame class is inspected. `densityRule`'s arm is
`| .densityRule, .pos, .allFuture _ => decide (FrameClass.Dense ≤ fc)`, and the shape half of that
arm already fails, so the `decide` is never reached. This is why the discharge below is universal in
`fc` where register entry 20 expected a density-free restriction. -/
theorem isApplicable_eq_false_of_untlSnceFree {r : TableauRule} {sf : SignedFormula}
    {fc : FormalSystem.ProofSystem.FrameClass}
    (hmint : ruleMintsFreshTime r = true) (hfree : untlSnceFree sf.formula = true) :
    isApplicable r sf fc = false := by
  have h1 := asUntil_eq_none_of_untlSnceFree hfree
  have h2 := asSince_eq_none_of_untlSnceFree hfree
  have h3 := asSomeFuture_eq_none_of_untlSnceFree hfree
  have h4 := asSomePast_eq_none_of_untlSnceFree hfree
  have h5 := asAllFuture_eq_none_of_untlSnceFree hfree
  have h6 := asAllPast_eq_none_of_untlSnceFree hfree
  obtain ⟨sign, φ, l⟩ := sf
  simp only at h1 h2 h3 h4 h5 h6 hfree
  cases r <;> try exact Bool.noConfusion hmint
  all_goals (
    cases sign <;>
    (cases φ with
     | imp a b =>
        cases a <;>
          simp_all [isApplicable, asAllFuture?, asAllPast?, asUntil?, asSince?,
            asSomeFuture?, asSomePast?, untlSnceFree]
     | _ =>
        simp_all [isApplicable, asAllFuture?, asAllPast?, asUntil?, asSince?,
          asSomeFuture?, asSomePast?, untlSnceFree]))

/-- **The first stage reports only applicable rules.** The `isApplicable` companion of
`findApplicableRule_applyRule_pair`, read off the same `findSome?` structure: every arm of the
`if isApplicable rule sf fc then … else none` body that can return `some` sits under the `then`. -/
theorem findApplicableRule_isApplicable {sf : SignedFormula} {b : Branch} {ord : TimeOrdering}
    {fc : FormalSystem.ProofSystem.FrameClass}
    {r : TableauRule} {res : RuleResult} {o : TimeOrdering}
    (h : findApplicableRule sf b ord fc = some (r, res, o)) :
    isApplicable r sf fc = true := by
  unfold findApplicableRule at h
  obtain ⟨rule, -, hr⟩ := List.exists_of_findSome?_eq_some h
  repeat' split at hr
  all_goals simp_all

/-- **The first stage cannot pick a minting rule on an `untl`/`snce`-free trigger.** -/
theorem findApplicableRule_not_mintsFreshTime {sf : SignedFormula} {b : Branch}
    {ord : TimeOrdering} {fc : FormalSystem.ProofSystem.FrameClass}
    {r : TableauRule} {res : RuleResult} {o : TimeOrdering}
    (hfree : untlSnceFree sf.formula = true)
    (h : findApplicableRule sf b ord fc = some (r, res, o)) :
    ruleMintsFreshTime r = false := by
  rcases hm : ruleMintsFreshTime r with _ | _
  · rfl
  · exact absurd (findApplicableRule_isApplicable h)
      (by simp [isApplicable_eq_false_of_untlSnceFree hm hfree])

/-- **`pick_stage_source` with the no-mint fact attached**, the exact counterpart of
`pick_stage_source_guarded` in the time coordinate. The three stages differ only in how the fact
arrives: stage one has it from `findApplicableRule_not_mintsFreshTime`, stages two and three from
running exactly one rule each, neither of which is in the census
(`findApplicableSerialRule_rule`, `findApplicableLinearityRule_rule`). -/
private theorem pick_stage_source_noMint (b : Branch) (ord : TimeOrdering)
    (fc : FormalSystem.ProofSystem.FrameClass) (tr : EventualityTracker)
    (hfree : ∀ x ∈ b, untlSnceFree x.formula = true) :
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
      ∃ sf, sf ∈ b ∧ applyRule r sf b ord = (res, o) ∧ ruleMintsFreshTime r = false := by
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
        refine ⟨sf3, List.mem_of_find?_eq_some hlin,
          findApplicableLinearityRule_applyRule_pair h, ?_⟩
        rw [findApplicableLinearityRule_rule h]
        rfl
    · rw [hser] at h
      simp only at h
      refine ⟨sf2, List.mem_of_find?_eq_some hser,
        findApplicableSerialRule_applyRule_pair h, ?_⟩
      rw [findApplicableSerialRule_rule h]
      rfl
  · rw [hpick] at h
    simp only at h
    have hmem : sf ∈ b := by
      unfold findUnexpandedUnblockedWith at hpick
      exact List.mem_of_find?_eq_some hpick
    exact ⟨sf, hmem, findApplicableRule_applyRule_pair h,
      findApplicableRule_not_mintsFreshTime (hfree sf hmem) h⟩

/-! ### The time sweep with `OrdTimesKnown` traded for branch-level freeness

`applyRule_emitted_time_mem` (section D1) carries `OrdTimesKnown b ord`, and
`applyRule_emitted_time_mem_ordTimesKnown_needed` decides that the *unconditional* statement is
false. Neither fact settles what happens on this section's fragment, and the difference matters
downstream: `UniverseClosedAt`'s clause 1 hands over `∀ x ∈ b, x ∈ signedUniverse C L`, from which
branch-level `untlSnceFree` follows in one line, but it hands over nothing at all about the
ordering. A statement whose only currency is branch-level freeness therefore reaches sites the
`OrdTimesKnown` form cannot.

`haux` is consumed at exactly three closer families in the D1 sweep —
`mem_filterMap_futureOf_time haux`, `mem_filterMap_pastOf_time haux`, and (through
`applyRule_orderTrichotomy_emitted_time`) `mem_knownTimes_of_mem_pastOf haux` — spread across
exactly five rule arms. All five are shape-gated, and the five lemmas below say so one arm at a
time. Four are gated by the *trigger*: `.allFuturePos` and `.allPastPos` match the raw
`Formula.allFuture` / `Formula.allPast` shape, whose head is an `untl` / `snce` node, and
`.someFutureNeg` / `.somePastNeg` consult `asSomeFuture?` / `asSomePast?`, which the view lemmas
above already return `none` for. The fifth is gated by the *branch*: `.orderTrichotomy`'s `fires`
guard demands `branch.contains (SignedFormula.neg d l0)` for one of three `Formula.someFuture`-headed
disjuncts, and an `untl`/`snce`-free branch carries no `untl`-headed formula at all. That asymmetry
is why the restricted sweep takes a branch-level hypothesis rather than a trigger-level one.

Each exclusion concludes `emitted = []` rather than the weaker "every emission is at a known time":
on this fragment the four propagation arms and the trichotomy arm do not merely emit safely, they
do not fire. -/

/-- `.allFuturePos` does not fire on an `untl`/`snce`-free trigger. Its arm matches the raw shape
`Formula.allFuture ψ = ((⊥ → ⊥) untl (ψ → ⊥)) → ⊥`, so the condition has to be pushed through the
implication before the `untl` node is visible — the same extra split
`asAllFuture_eq_none_of_untlSnceFree` needs, and for the same reason. Routing through that view
lemma is not available here: `applyRule`'s arm is a constructor pattern, not a view. -/
theorem applyRule_allFuturePos_emitted_nil_of_untlSnceFree
    {sf : SignedFormula} {b : Branch} {ord : TimeOrdering}
    (hfree : untlSnceFree sf.formula = true) :
    (applyRule .allFuturePos sf b ord).1.emitted = [] := by
  obtain ⟨sign, φ, l⟩ := sf
  simp only at hfree
  cases sign
  case pos =>
    cases φ with
    | imp a c => cases a <;> simp_all [applyRule, untlSnceFree, RuleResult.emitted]
    | _ => simp [applyRule, RuleResult.emitted]
  case neg => simp [applyRule, RuleResult.emitted]

/-- The past mirror, through `Formula.allPast` and `snce`. -/
theorem applyRule_allPastPos_emitted_nil_of_untlSnceFree
    {sf : SignedFormula} {b : Branch} {ord : TimeOrdering}
    (hfree : untlSnceFree sf.formula = true) :
    (applyRule .allPastPos sf b ord).1.emitted = [] := by
  obtain ⟨sign, φ, l⟩ := sf
  simp only at hfree
  cases sign
  case pos =>
    cases φ with
    | imp a c => cases a <;> simp_all [applyRule, untlSnceFree, RuleResult.emitted]
    | _ => simp [applyRule, RuleResult.emitted]
  case neg => simp [applyRule, RuleResult.emitted]

/-- `.someFutureNeg` is view-gated: its arm is `| .someFutureNeg, .neg, φ => match asSomeFuture? φ`,
and `asSomeFuture_eq_none_of_untlSnceFree` sends the view to `none`, hence the arm to
`.notApplicable`. -/
theorem applyRule_someFutureNeg_emitted_nil_of_untlSnceFree
    {sf : SignedFormula} {b : Branch} {ord : TimeOrdering}
    (hfree : untlSnceFree sf.formula = true) :
    (applyRule .someFutureNeg sf b ord).1.emitted = [] := by
  obtain ⟨sign, φ, l⟩ := sf
  simp only at hfree
  have h := asSomeFuture_eq_none_of_untlSnceFree hfree
  cases sign <;> simp [applyRule, h, RuleResult.emitted]

/-- The past mirror, through `asSomePast?`. -/
theorem applyRule_somePastNeg_emitted_nil_of_untlSnceFree
    {sf : SignedFormula} {b : Branch} {ord : TimeOrdering}
    (hfree : untlSnceFree sf.formula = true) :
    (applyRule .somePastNeg sf b ord).1.emitted = [] := by
  obtain ⟨sign, φ, l⟩ := sf
  simp only at hfree
  have h := asSomePast_eq_none_of_untlSnceFree hfree
  cases sign <;> simp [applyRule, h, RuleResult.emitted]

/-- **The branch-level step**: an `untl`-headed formula is not carried by an `untl`/`snce`-free
branch, at any sign and any label. Named separately because it is the one step of the
`.orderTrichotomy` exclusion that is about the branch rather than about `applyRule`'s match, and it
should fail in isolation if it fails. -/
theorem untl_not_contains_of_untlSnceFree {b : Branch}
    (hbfree : ∀ x ∈ b, untlSnceFree x.formula = true)
    {s : Sign} {x y : Formula} {l : Label} :
    b.contains ⟨s, Formula.untl x y, l⟩ = false := by
  rcases hc : b.contains (⟨s, Formula.untl x y, l⟩ : SignedFormula) with _ | _
  · rfl
  · have hm : (⟨s, Formula.untl x y, l⟩ : SignedFormula) ∈ b := mem_of_branch_contains hc
    have := hbfree _ hm
    simp [untlSnceFree] at this

/-- `.orderTrichotomy` does not fire on an `untl`/`snce`-free **branch**. Its `fires` guard ends in
`ds.any fun d => branch.contains (SignedFormula.neg d l0)`, where every `d ∈ disjuncts φ ψ` is
`Formula.someFuture (…) = Formula.untl ⊤ (…)`. So no candidate fires, `candidates.find? fires` is
`none`, and the arm reports `.notApplicable`.

This is the arm the trigger-level hypothesis does not reach: nothing about `sf`'s own shape
constrains what the branch carries, which is why the restricted sweep below takes `hbfree`. -/
theorem applyRule_orderTrichotomy_emitted_nil_of_untlSnceFree
    {sf : SignedFormula} {b : Branch} {ord : TimeOrdering}
    (hbfree : ∀ x ∈ b, untlSnceFree x.formula = true) :
    (applyRule .orderTrichotomy sf b ord).1.emitted = [] := by
  obtain ⟨sign, φ, l⟩ := sf
  cases sign
  case neg => simp [applyRule, RuleResult.emitted]
  case pos =>
    simp only [applyRule]
    repeat' split
    all_goals (try simp only [RuleResult.emitted])
    rename_i heq
    have hfires := List.find?_some heq
    simp only [Formula.someFuture, SignedFormula.neg, List.any_cons, List.any_nil,
      Bool.and_eq_true, Bool.or_eq_true, untl_not_contains_of_untlSnceFree hbfree] at hfires
    simp at hfires

/-- An arm that emits nothing meets the sweep's conclusion vacuously. Stated separately so the five
exclusions can be fed into the sweep's `first` chain as one-line `exact`s. -/
theorem time_mem_of_emitted_nil {b : Branch} {r : RuleResult × TimeOrdering}
    (h : r.1.emitted = []) : ∀ g ∈ r.1.emitted, g.label.time ∈ b.knownTimes := by
  rw [h]; simp

-- `linter.unusedTactic` fires on the `assumption` at the end of the
-- `mem_identifyTime_time_at_trigger` alternative below and calls it dead. It is NOT dead: it is
-- the alternative's *failure* mechanism. The `refine mem_identifyTime_time_at_trigger (ord := ord)
-- ?_ hg` above it leaves a `?_` that only `assumption` can discharge; where nothing in context
-- closes it, the `assumption` fails, the whole alternative fails, and `first` falls through to the
-- `mem_identifyTime_time_at_trigger_oriented` twin that follows. Without it the alternative
-- succeeds vacuously and orphans the goal `refine` created.
-- Deleting it was tried: replacing that `assumption` with `skip` fails the build with `unsolved
-- goals` reported at `applyRule_emitted_time_mem_of_untlSnceFree` below, twice over -- the same
-- `case h_2.inr.inr`, once for `Sign.pos` and once for `Sign.neg`.
-- This is the `MintBound/Invariants.lean` pattern (a tactic kept for its failure), not the
-- `Termination/SubformulaProperty.lean` one (a `done` kept as a closer for a goal `refine` left
-- open).
set_option linter.unusedTactic false in
set_option maxHeartbeats 4000000 in
-- `repeat' split` case-splits every arm of the 36-constructor `applyRule` match; elaborating
-- all of them is past the default heartbeat budget.
/-- **The time sweep on the `untl`/`snce`-free fragment, without `OrdTimesKnown`.**

`applyRule_emitted_time_mem` with `haux : OrdTimesKnown b ord` replaced by
`hbfree : ∀ x ∈ b, untlSnceFree x.formula = true`. Three things about it, and no more:

* **It is incomparable to the original, not stronger.** It trades a semantic run invariant for a
  syntactic branch condition. Neither hypothesis implies the other: an ordering can be
  `OrdTimesKnown` over a branch carrying `untl` formulas, and an `untl`/`snce`-free branch can sit
  under an ordering reaching times it does not know. Both statements are needed, and both are kept.
* **It does not contradict `applyRule_emitted_time_mem_ordTimesKnown_needed`.** What that theorem
  refutes is the *unconditional* statement — no `OrdTimesKnown`, no syntactic condition, nothing.
  Its witness branch is `[T(G p)]`, and `Formula.allFuture p` is an `untl` node, so the witness
  fails `hbfree` outright. The refutation stands exactly as stated.
* **The five arms that consume `OrdTimesKnown` are precisely the five the syntactic hypothesis
  shape-gates**: `.allFuturePos` and `.allPastPos` (raw `allFuture` / `allPast` constructor
  patterns), `.someFutureNeg` and `.somePastNeg` (the `asSomeFuture?` / `asSomePast?` views), and
  `.orderTrichotomy` (the `fires` guard's branch lookup). The five exclusions above are inserted
  into the sweep's `first` chain *ahead of* the closers that would have needed `haux`, and the
  `mem_filterMap_futureOf_time` / `mem_filterMap_pastOf_time` alternatives are then simply absent:
  no arm reaches them. Every other arm is closed by the D1 sweep's own `haux`-free alternatives,
  copied verbatim so that the ordering property that script's docstring records — every closer a
  backtrackable `refine … ?_`, never a term-level `by` that could absorb a failing goal into
  `sorryAx` — is preserved.

`hmint : ruleMintsFreshTime rule = false` is retained. It is plausibly droppable on this fragment,
since an `untl`/`snce`-free trigger fails every minting rule's shape view
(`isApplicable_eq_false_of_untlSnceFree`), but `applyRule` is not gated by `isApplicable`, so
dropping it is a separate proof and not one this statement needs. -/
theorem applyRule_emitted_time_mem_of_untlSnceFree {rule : TableauRule} {sf : SignedFormula}
    {b : Branch} {ord : TimeOrdering}
    (hsf : sf ∈ b) (hbfree : ∀ x ∈ b, untlSnceFree x.formula = true)
    (hmint : ruleMintsFreshTime rule = false) :
    ∀ g ∈ (applyRule rule sf b ord).1.emitted, g.label.time ∈ b.knownTimes := by
  have ht : sf.label.time ∈ b.knownTimes := mem_knownTimes_of_mem hsf
  have hfree : untlSnceFree sf.formula = true := hbfree sf hsf
  cases sf with
  | mk sign formula label =>
    cases rule <;> first
      | exact Bool.noConfusion hmint
      | exact time_mem_of_emitted_nil (applyRule_allFuturePos_emitted_nil_of_untlSnceFree hfree)
      | exact time_mem_of_emitted_nil (applyRule_allPastPos_emitted_nil_of_untlSnceFree hfree)
      | exact time_mem_of_emitted_nil (applyRule_someFutureNeg_emitted_nil_of_untlSnceFree hfree)
      | exact time_mem_of_emitted_nil (applyRule_somePastNeg_emitted_nil_of_untlSnceFree hfree)
      | exact time_mem_of_emitted_nil (applyRule_orderTrichotomy_emitted_nil_of_untlSnceFree hbfree)
      | (cases sign <;> simp only [applyRule] <;> (repeat' split) <;>
          (try contradiction) <;>
          intro g hg <;>
          repeat' first
            | exact ht
            | exact mem_knownTimes_of_mem hg
            | (refine mem_identifyTime_time_at_trigger (ord := ord) ?_ hg
               assumption)
            | (refine mem_identifyTime_time_at_trigger_oriented (ord := ord) ?_ hg
               assumption)
            | (refine mem_filterMap_const_time_mem (t := label.time) ht ?_ hg
               clear hg
               intro x y hy
               repeat' first
                 | split at hy
                 | simp only [Option.some.injEq] at hy
               all_goals first
                 | (subst hy; rfl)
                 | (simp only [reduceCtorEq] at hy))
            | (refine mem_filterMap_time ?_ hg
               clear hg
               intro x y hy
               repeat' first
                 | split at hy
                 | simp only [Option.some.injEq] at hy
               all_goals first
                 | (subst hy; rfl)
                 | (simp only [reduceCtorEq] at hy))
            | (simp only [RuleResult.emitted, Branch.boxPosFormulas, Branch.diamondNegFormulas,
                 List.map_cons, List.map_nil, List.flatten_cons, List.flatten_nil,
                 List.append_nil, List.mem_cons, List.mem_append, List.not_mem_nil,
                 or_false, List.mem_filter] at hg)
            | (subst hg; exact ht)
            | (rcases hg with hg | hg))

/-- One pick stage adds no known time, given that its rule mints none. The join of
`applyRule_emitted_time_mem` with the no-mint source, in the shape `pickBranches_world_dichotomy`
uses for the world coordinate. -/
theorem pickBranches_knownTimes_subset {b : Branch} {ord : TimeOrdering}
    {p : Option (TableauRule × RuleResult × TimeOrdering)}
    (haux : OrdTimesKnown b ord)
    (hp : ∀ r res o, p = some (r, res, o) → ∃ sf, sf ∈ b ∧ applyRule r sf b ord = (res, o) ∧
      ruleMintsFreshTime r = false) :
    ∀ nb ∈ pickBranches b p, ∀ t ∈ nb.knownTimes, t ∈ b.knownTimes := by
  rcases p with _ | ⟨r, res, o⟩
  · simp [pickBranches]
  · obtain ⟨sf, hsf, hA, hnm⟩ := hp r res o rfl
    intro nb hnb t ht
    obtain ⟨-, hsub⟩ := resultBranch_sub (b := b) (nb := nb) (res := res) hnb
    obtain ⟨x, hx, rfl⟩ := exists_mem_of_mem_knownTimes ht
    rcases hsub x hx with hxe | hxb
    · refine applyRule_emitted_time_mem (rule := r) (sf := sf) (ord := ord) hsf haux hnm x ?_
      rw [hA]
      exact hxe
    · exact mem_knownTimes_of_mem hxb

/-- **No unordered successor of an `untl`/`snce`-free branch carries a new time.**

The engine-level statement, and the one the discharge consumes. Compare
`unorderedSuccessor_time_dichotomy`, which is unconditional and therefore has to admit
`t = b.nextTime` as a second case: here the second case is *closed*, at the cost of the syntactic
hypothesis. Routed through `pick_branches_eq` and `pick_stage_source_noMint`, so the three-stage
pick is not destructured a second time. -/
theorem unorderedSuccessor_knownTimes_subset {b : Branch} {ord : TimeOrdering}
    {fc : FormalSystem.ProofSystem.FrameClass} {tr : EventualityTracker}
    (haux : OrdTimesKnown b ord) (hfree : ∀ x ∈ b, untlSnceFree x.formula = true) :
    ∀ nb ∈ unorderedSuccessorBranches (expandOnceUnblocked b ord fc tr).1,
      ∀ t ∈ nb.knownTimes, t ∈ b.knownTimes := by
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
  exact pickBranches_knownTimes_subset haux (pick_stage_source_noMint b ord fc tr hfree)

/-- The `haux`-free twin of `pickBranches_knownTimes_subset`, routed through
`applyRule_emitted_time_mem_of_untlSnceFree` at the one site where the original calls
`applyRule_emitted_time_mem`. The source obligation `hp` is unchanged and already carries
`ruleMintsFreshTime r = false`, so the restricted sweep's `hmint` costs nothing here; the only new
currency is the branch-level syntactic condition, which `pick_stage_source_noMint`'s own caller
already has in hand. -/
private theorem pickBranches_knownTimes_subset_of_untlSnceFree {b : Branch} {ord : TimeOrdering}
    {p : Option (TableauRule × RuleResult × TimeOrdering)}
    (hbfree : ∀ x ∈ b, untlSnceFree x.formula = true)
    (hp : ∀ r res o, p = some (r, res, o) → ∃ sf, sf ∈ b ∧ applyRule r sf b ord = (res, o) ∧
      ruleMintsFreshTime r = false) :
    ∀ nb ∈ pickBranches b p, ∀ t ∈ nb.knownTimes, t ∈ b.knownTimes := by
  rcases p with _ | ⟨r, res, o⟩
  · simp [pickBranches]
  · obtain ⟨sf, hsf, hA, hnm⟩ := hp r res o rfl
    intro nb hnb t ht
    obtain ⟨-, hsub⟩ := resultBranch_sub (b := b) (nb := nb) (res := res) hnb
    obtain ⟨x, hx, rfl⟩ := exists_mem_of_mem_knownTimes ht
    rcases hsub x hx with hxe | hxb
    · refine applyRule_emitted_time_mem_of_untlSnceFree (rule := r) (sf := sf) (ord := ord)
        hsf hbfree hnm x ?_
      rw [hA]
      exact hxe
    · exact mem_knownTimes_of_mem hxb

/-- **The engine-level statement without the run invariant.** `unorderedSuccessor_knownTimes_subset`
with `OrdTimesKnown b ord` gone: its `hfree` was already exactly the hypothesis the restricted sweep
needs, so the `haux`-free form is strictly stronger at no new cost.

This is the declaration section D4's boundary block said would be needed and did not have. Its point
is not economy — the original's `haux` is available at every site that currently consumes it, via
`hri.ordTimesKnown` — but *reachability*: `UniverseClosedAt`'s clause 1 quantifies `ord` universally
and unconstrained, so it can never supply `OrdTimesKnown b ord`, while branch-level freeness follows
from clause 1's own `∀ x ∈ b, x ∈ signedUniverse C L` in one line.

The original is retained with its signature byte-identical and its proof untouched: it is cited by
name in this section's prose and in D4's boundary block, and `mintPaysForTime_of_untlSnceFree` and
its three descendants continue to consume it unchanged. -/
theorem unorderedSuccessor_knownTimes_subset_of_untlSnceFree {b : Branch} {ord : TimeOrdering}
    {fc : FormalSystem.ProofSystem.FrameClass} {tr : EventualityTracker}
    (hfree : ∀ x ∈ b, untlSnceFree x.formula = true) :
    ∀ nb ∈ unorderedSuccessorBranches (expandOnceUnblocked b ord fc tr).1,
      ∀ t ∈ nb.knownTimes, t ∈ b.knownTimes := by
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
  exact pickBranches_knownTimes_subset_of_untlSnceFree hfree
    (pick_stage_source_noMint b ord fc tr hfree)

/-- **The rank is monotone in the two things a step can move.** `splitOrderedRank` rises with
`knownTimes` and falls with the constraint list, so a successor that adds no time and loses no
constraint cannot raise it. This is disjunct 1's second conjunct in general form; the first
conjunct is `Finset.card_le_card` on the same subset. -/
theorem splitOrderedRank_le_of_knownTimes_subset {Tmax : Nat} {b nb : Branch}
    {ord ord' : TimeOrdering}
    (hsub : ∀ t ∈ nb.knownTimes, t ∈ b.knownTimes)
    (hmono : ∀ q ∈ ord.constraints, q ∈ ord'.constraints) :
    splitOrderedRank Tmax nb ord' ≤ splitOrderedRank Tmax b ord := by
  have h1 : nb.knownTimes.toFinset ⊆ b.knownTimes.toFinset := by
    intro t ht
    simp only [List.mem_toFinset] at ht ⊢
    exact hsub t ht
  have h2 : incompPairs nb ord' ⊆ incompPairs b ord := by
    intro p hp
    rw [mem_incompPairs] at hp ⊢
    exact ⟨hsub _ hp.1, hsub _ hp.2.1, incomparableB_mono hmono p hp.2.2⟩
  simp only [splitOrderedRank]
  exact Nat.add_le_add (Nat.mul_le_mul_right _ (Finset.card_le_card h1))
    (Finset.card_le_card h2)

/-- **The discharge.** `MintPaysForTime` — the predicate as this file first stated it, not a repair
of it — holds at every universe of `untl`/`snce`-free formulas, at every frame class, for every
`Tmax`, and for every renaming `σ`.

Every step lands in **disjunct 1**, and neither the σ-hit obligation nor the self-guard measure is
consulted: `σ` does not appear in the proof at all. That is what makes this a discharge rather than
another repair — the hypothesis list of the predicate is untouched, and the direction lemmas of
section D2 carry it to `MintPaysForTimeStable` and `MintPaysForTimeFixed` for free. -/
theorem mintPaysForTime_of_untlSnceFree {fc : FormalSystem.ProofSystem.FrameClass}
    {U : Finset SignedFormula} {Tmax : Nat}
    (hU : ∀ x ∈ U, untlSnceFree x.formula = true) :
    MintPaysForTime fc U Tmax := by
  intro _σ b ord tr hri hconf nb hnb
  have hfree : ∀ x ∈ b, untlSnceFree x.formula = true := fun x hx => hU x (hconf x hx)
  have hsub := unorderedSuccessor_knownTimes_subset (fc := fc) (tr := tr)
    hri.ordTimesKnown hfree nb hnb
  refine Or.inl ⟨Finset.card_le_card ?_, splitOrderedRank_le_of_knownTimes_subset hsub
    expandOnceUnblocked_ord_mono⟩
  intro t ht
  simp only [List.mem_toFinset] at ht ⊢
  exact hsub t ht

/-- …and at the repaired predicate the terminus chain is stated against, by the direction lemma. No
new hypothesis is introduced: `MintPaysForTimeFixed` is *weaker*. -/
theorem mintPaysForTimeFixed_of_untlSnceFree {fc : FormalSystem.ProofSystem.FrameClass}
    {U : Finset SignedFormula} {Tmax : Nat}
    (hU : ∀ x ∈ U, untlSnceFree x.formula = true) :
    MintPaysForTimeFixed fc U Tmax :=
  mintPaysForTimeFixed_of_mintPaysForTime (mintPaysForTime_of_untlSnceFree hU)

/-- A member of `signedUniverse C L` carries a formula from `C`. The projection the concrete
instantiation below needs; the converse `mem_signedUniverse` is in `Fuel.lean`. -/
theorem formula_mem_of_mem_signedUniverse {C : Finset Formula} {L : Finset Label}
    {x : SignedFormula} (h : x ∈ signedUniverse C L) : x.formula ∈ C := by
  simp only [signedUniverse, Finset.mem_image, Finset.mem_product] at h
  obtain ⟨p, ⟨-, hf, -⟩, rfl⟩ := h
  exact hf

/-- **The discharge at the concrete universe the seed-level termini consume**, for every stock of
`untl`/`snce`-free formulas and every label set. This is the statement
`mintPaysForTimeFixed_signedUniverse_empty` was the `L = ∅` shadow of: the universe here is
nonempty as soon as `C` and `L` are (`signedUniverse_nonempty`). -/
theorem mintPaysForTimeFixed_signedUniverse_untlSnceFree
    (fc : FormalSystem.ProofSystem.FrameClass) {C : Finset Formula} (L : Finset Label)
    (Tmax : Nat) (hC : ∀ φ ∈ C, untlSnceFree φ = true) :
    MintPaysForTimeFixed fc (signedUniverse C L) Tmax :=
  mintPaysForTimeFixed_of_untlSnceFree
    (fun _ hx => hC _ (formula_mem_of_mem_signedUniverse hx))

/-- …and at the original predicate too, since the discharge is at the original. -/
theorem mintPaysForTime_signedUniverse_untlSnceFree
    (fc : FormalSystem.ProofSystem.FrameClass) {C : Finset Formula} (L : Finset Label)
    (Tmax : Nat) (hC : ∀ φ ∈ C, untlSnceFree φ = true) :
    MintPaysForTime fc (signedUniverse C L) Tmax :=
  mintPaysForTime_of_untlSnceFree (fun _ hx => hC _ (formula_mem_of_mem_signedUniverse hx))

/-! ### Non-vacuity

The discharge is at a universe, not at the empty set, and this is where that is checked rather than
asserted. Two facts: the universe is nonempty whenever both its dimensions are, and a concrete
modal stock — an atom, its box, and the `T` axiom's instance over it — satisfies the syntactic
condition. -/

/-- `signedUniverse` is nonempty as soon as both its dimensions are. -/
theorem signedUniverse_nonempty {C : Finset Formula} {L : Finset Label}
    (hC : C.Nonempty) (hL : L.Nonempty) : (signedUniverse C L).Nonempty := by
  obtain ⟨φ, hφ⟩ := hC
  obtain ⟨l, hl⟩ := hL
  exact ⟨⟨Sign.pos, φ, l⟩, mem_signedUniverse hφ hl⟩

/-- A concrete `untl`/`snce`-free stock: `p`, `□p`, and `□p → p`. -/
def modalWitnessStock : Finset Formula :=
  {Formula.atomS "p", (Formula.atomS "p").box,
    ((Formula.atomS "p").box).imp (Formula.atomS "p")}

/-- It satisfies the syntactic condition… -/
theorem modalWitnessStock_untlSnceFree :
    ∀ φ ∈ modalWitnessStock, untlSnceFree φ = true := by
  intro φ hφ
  simp only [modalWitnessStock, Finset.mem_insert, Finset.mem_singleton] at hφ
  rcases hφ with rfl | rfl | rfl <;> rfl

/-- …and it is not empty. -/
theorem modalWitnessStock_nonempty : modalWitnessStock.Nonempty :=
  ⟨Formula.atomS "p", by simp [modalWitnessStock]⟩

/-- **The residual, discharged at a nonempty concrete universe.** Together with
`signedUniverse_nonempty` and `modalWitnessStock_nonempty` this is the residual discharged at a
universe that is not the empty one. -/
theorem mintPaysForTime_modalWitness (fc : FormalSystem.ProofSystem.FrameClass)
    (L : Finset Label) (Tmax : Nat) :
    MintPaysForTime fc (signedUniverse modalWitnessStock L) Tmax :=
  mintPaysForTime_signedUniverse_untlSnceFree fc L Tmax modalWitnessStock_untlSnceFree

/-- **Seed-level terminus 2, with the mint residual discharged rather than assumed.**

The exact statement of `buildTableauAt_isSome_at_seed_lengthBudget_signedUniverse_fixed` with its
`hmint` argument gone: on an `untl`/`snce`-free stock the hypothesis is a theorem, so the terminus
carries one named residual fewer. The other three (`UnorderedSuccessorLabelClosed`,
`StepLengthBounded`, `PostBlockingSettles`) are untouched — this section says nothing about them.

**But read the reach honestly: `hlab` makes this statement vacuous wherever the universe is not
empty.** The section heading promises a discharge "at a **nonempty** universe", and the `hmint`
half of that promise is kept. The `hlab` half is not, and cannot be:
`unorderedSuccessorLabelClosed_nonempty_false` refutes `hlab` at every nonempty finite `L`, so at
exactly the `L` this section is interested in, the theorem above is a true conditional with a false
antecedent. It is the failure mode `DifficultyBounded` fell into and that `timeMergeClosed_product`
was added to rule out — a residual nobody can satisfy makes its theorem a true conditional with no
reach. What removes `hlab` is not a better proof of this theorem but a **replacement** for the
predicate — a condition that is actually satisfiable at a nonempty `L`. No artifact should read this
theorem, or any of the eight siblings that carry `hlab`, as claiming a discharge at a nonempty
universe until `hlab` is absent from the signature. -/
theorem buildTableauAt_isSome_at_seed_lengthBudget_signedUniverse_untlSnceFree
    {fc : FormalSystem.ProofSystem.FrameClass}
    {C : Finset Formula} {L : Finset Label} {L' β : Nat} (phi : Formula) (hβ : 3 ≤ β)
    (hC : TableauClosed C) (hT : TrichStock C) (hL : TimeMergeClosed L)
    (hlab : UnorderedSuccessorLabelClosed fc L)
    (hSL : StepLengthBounded fc (signedUniverse C L) L')
    (hfree : ∀ φ ∈ C, untlSnceFree φ = true)
    (hpb : PostBlockingSettles fc)
    (hseed : ∀ x ∈ seedBranch phi, x ∈ signedUniverse C L) :
    (buildTableauAt phi
        (mintAwareFuelAt (signedUniverse C L).card
          (derivedTmaxAt ((seedBranch phi).knownTimes.toFinset.card)
            (signedUniverse C L).card)
          (10 * (signedUniverse C L).card)
          (difficultyCeiling (signedUniverse C L) L') β)
        fc
        (β * mintAwareFuelAt (signedUniverse C L).card
          (derivedTmaxAt ((seedBranch phi).knownTimes.toFinset.card)
            (signedUniverse C L).card)
          (10 * (signedUniverse C L).card)
          (difficultyCeiling (signedUniverse C L) L') β)
      ).isSome = true :=
  buildTableauAt_isSome_at_seed_lengthBudget_signedUniverse_fixed phi hβ hC hT hL hlab hSL
    (mintPaysForTimeFixed_signedUniverse_untlSnceFree fc L _ hfree) hpb hseed

end FormalSystem.Metalogic.Decidability
