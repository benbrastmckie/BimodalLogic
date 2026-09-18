/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.Verified.Termination.MintBound.UntlSnceFree

/-! # D5. The engine-level assembly: `MintPaysForTimeFixed` off `.Dense`, at any universe

**What this section delivers.** `MintPaysForTimeFixed fc U Tmax` — the repaired mint residual the
terminus chain is stated against — proved outright at an **arbitrary** universe, for every frame
class `fc` satisfying `¬ (FrameClass.Dense ≤ fc)`. No syntactic condition on the formulas, no
emptiness, no hypothesis added to the predicate, no figure changed, and no engine definition
touched. At the concrete universe the seed-level termini consume it reads
`mintPaysForTimeFixed_signedUniverse_of_not_dense`, which holds for **every** stock `C` — `untl`
and `snce` nodes included.

**The frame restriction is one condition, and it is written in the statement.** `¬ (FrameClass.Dense
≤ fc)` excludes `.Dense` and `.RTime` together, because `Dense ≤ Dedekind` holds in the
`FrameClass` order, and it admits exactly `.Base` and `.ZTime`. It is not hidden behind a
definition, a `variable`, or a typeclass: a reader of `mintPaysForTimeFixed_of_not_dense` alone sees
it. What it buys is the exclusion of `densityRule` — the one rule that mints a fresh time while
sitting outside both `freshLabelRules` and `selfGuardRules`, and therefore outside every disjunct —
via `findApplicableRule_ne_densityRule`. It does not close the density coordinate: `gapPotential` is
still implemented nowhere and assumed by nothing, and register entry 20's item (b) stands exactly as
written.

**What was missing, and what supplies it.** The per-rule payments all existed already. What did not
exist was the picked rule's *identity* at the successor: `pick_stage_source` hands on `applyRule`'s
pair and discards stage one's `findApplicableRule` equation, and the equation is precisely what the
witness-guarded payments need — `findApplicableRule_guard_linear` and its `.branching` twin read
`witnessPresent … = false` off `findApplicableRule`'s own `if`, which `applyRule` does not carry.
`pick_stage_source_rule` is that threading, in the only shape all three stages support: stage one
reports its equation, stages two and three report that their rule (`serialityRule`, `timeLinearity`)
is outside `freshTimeRules`. With it, `pickBranches_mintPays` splits the picked rule into the four
buckets a `decide`-proved census fixes — no fresh time (disjunct 1), witness-guarded mint (disjunct
2), self-guarded mint (disjunct 3), `densityRule` (excluded) — and every bucket closes from a landed
lemma with both budget conjuncts exact.

**What this retires, and what it generalizes.** Register entry 20's item (a), the engine-level
assembly, is the last non-density obstruction to the mint predicate itself, and it is retired here;
entry 20's paragraph is amended in place to say so. `mintPaysForTimeFixed_signedUniverse_of_not_dense`
generalizes section D3's `mintPaysForTimeFixed_signedUniverse_untlSnceFree` off its syntactic
fragment onto arbitrary `C` — the case entry 20 itself calls the hard one, and the case
`mintPaysForTime_untlNeg_false` refutes the *unrepaired* predicate at. Neither D3's discharge nor
`mintPaysForTimeFixed_signedUniverse_empty` is deleted or altered; both are superseded in prose
only, and D3's remains the statement to reach for at `.Dense` and `.RTime`, where this section is
silent. The discharge here is satisfiable rather than vacuous: `signedUniverse_nonempty` makes the
universe nonempty as soon as `C` and `L` are, and the hypothesis discharged is a *theorem* there.

**And now the part that must not be omitted: this makes NO terminus in this file non-vacuous.**
Landing it unlocks nothing downstream, and saying otherwise would reproduce exactly the failure mode
register entry 21 documents for
`buildTableauAt_isSome_at_seed_lengthBudget_signedUniverse_untlSnceFree`. Both halves of that, named:

* *The nine `hlab` carriers stay vacuous.* Nine statements in this file carry
  `hlab : UnorderedSuccessorLabelClosed fc L` as a live hypothesis, and every one of them is a true
  conditional with a false antecedent at every nonempty `L`, because
  `unorderedSuccessorLabelClosed_nonempty_false` pins that predicate's satisfiability set at exactly
  `{∅}`. Removing `hmint` from such a statement changes nothing about its reach — and this section
  removes `hmint` from none of them in any case, because it restates no terminus at all.
* *The `hlab`-free `hmint`-carrying termini stay conditioned elsewhere.* Each of them still requires
  `UniverseClosedAt fc U`, plus `DifficultyBounded` or `StepLengthBounded`, plus `PostBlockingSettles`
  or `PostBlockingSettlesRun`. Three of those are refuted outright — `DifficultyBounded` by register
  entry 9, clause 1 of `UniverseClosed`/`UniverseClosedAt` at a fixed finite `signedUniverse C L` by
  entry 11, and `PostBlockingSettles` by entry 22. A discharged mint residual does not touch any of
  them.

So the honest reading of this section is: one named residual of the four is now a theorem at a
nonempty universe off `.Dense`, and the count of *satisfiable* residual conditions blocking any
terminus is unchanged. No artifact should read `mintPaysForTimeFixed_of_not_dense` as de-vacuifying
anything. -/

namespace FormalSystem.Metalogic.Decidability

open FormalSystem.Syntax

/-- **The strengthened pick-stage bridge.** `pick_stage_source` with the picked rule's *identity*
threaded through, in the only form the three stages can all support: stage one hands on its own
`findApplicableRule` equation, and stages two and three report that their rule is outside the time
census.

This is the whole of what the engine-level assembly was missing. `pick_stage_source` discards the
stage-one equation and keeps only `applyRule`'s pair, which is enough for the disjunct-1 arguments
(`pickBranches_ordTimes`, `pickBranches_time_dichotomy`) and not enough for disjunct 2: the
witness-guard the per-rule payment lemmas consume — `findApplicableRule_guard_linear` and its
`.branching` twin — lives in `findApplicableRule`'s own `if`, not in `applyRule`, and there is no
route to it from `applyRule r sf b ord = (res, o)` alone.

Its two precedents are `pick_stage_source_guarded`, which attaches the blocking-side fact by the
same three-stage `rcases`, and `pick_stage_source_noMint`, whose proof skeleton this is verbatim:
the only difference is that the two later stages report `Or.inr` of the no-mint fact where that
lemma reports it bare, and the first stage reports `Or.inl` of its own equation where that lemma
computes the no-mint fact from a syntactic hypothesis it does not have here. The disjunction is the
honest shape — stages two and three run `serialityRule` and `timeLinearity`, neither of which is
in `freshTimeRules`, and neither of which has a `findApplicableRule` equation to give. -/
private theorem pick_stage_source_rule (b : Branch) (ord : TimeOrdering)
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
      ∃ sf, sf ∈ b ∧ applyRule r sf b ord = (res, o) ∧
        (findApplicableRule sf b ord fc = some (r, res, o)
          ∨ ruleMintsFreshTime r = false) := by
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
          findApplicableLinearityRule_applyRule_pair h, Or.inr ?_⟩
        rw [findApplicableLinearityRule_rule h]
        rfl
    · rw [hser] at h
      simp only at h
      refine ⟨sf2, List.mem_of_find?_eq_some hser,
        findApplicableSerialRule_applyRule_pair h, Or.inr ?_⟩
      rw [findApplicableSerialRule_rule h]
      rfl
  · rw [hpick] at h
    simp only at h
    have hmem : sf ∈ b := by
      unfold findUnexpandedUnblockedWith at hpick
      exact List.mem_of_find?_eq_some hpick
    exact ⟨sf, hmem, findApplicableRule_applyRule_pair h, Or.inl h⟩

/-- **The density exclusion, by frame class.** `densityRule`'s arm of `isApplicable` is
`| .densityRule, .pos, .allFuture _ => decide (FrameClass.Dense ≤ fc)`, so a first-stage pick of it
carries `Dense ≤ fc` as a decided fact; denying that fact excludes the rule outright. Reached
through `findApplicableRule_isApplicable`, which is what makes this ten lines rather than a walk
over `findApplicableRule`'s arm list.

**One hypothesis, not two.** `¬ (FrameClass.Dense ≤ fc)` excludes `.Dense` and `.RTime`
*together*: `Dense ≤ Dedekind` holds in the `FrameClass` order, so a `fc` above `.Dense` is
excluded whether it is `.Dense` itself or anything above it. What it admits is exactly `.Base` and
`.ZTime`. Stating it as a pair of disequalities would be both weaker in form and redundant, and
it is deliberately not hidden behind a definition: a reader of the discharge below sees the
restriction in the statement.

This is the whole of the density treatment in this section. `gapPotential` — register entry 19's
and entry 20's item (b) — is not introduced, not assumed, and not needed here; buying the
exclusion with a frame-class hypothesis is what makes that so. -/
theorem findApplicableRule_ne_densityRule {sf : SignedFormula} {b : Branch}
    {ord : TimeOrdering} {fc : FormalSystem.ProofSystem.FrameClass}
    {r : TableauRule} {res : RuleResult} {o : TimeOrdering}
    (hfc : ¬ (FormalSystem.ProofSystem.FrameClass.Dense ≤ fc))
    (h : findApplicableRule sf b ord fc = some (r, res, o)) :
    r ≠ TableauRule.densityRule := by
  intro hr
  subst hr
  have hA := findApplicableRule_isApplicable h
  simp only [isApplicable] at hA
  split at hA <;> simp_all


/-! ### The leaf inversions the census case split consumes

Four kinds of fact, all of them read straight off `isApplicable` and `applyRule`: the result shapes
the six witness-guarded minting rules can report, the trigger shape `untlNeg` / `snceNeg` fire on,
their ACTIVE guard, and the four-bucket partition of all thirty-six constructors. None of them is
new mathematics; each is an inversion of an engine definition that is already frozen. -/

set_option maxHeartbeats 4000000 in
-- `repeat' split` case-splits every arm of the 36-constructor `applyRule` match; elaborating
-- all of them is past the default heartbeat budget.
/-- **None of the six witness-guarded minting rules ever reports `.persistent`.**

The six are `freshLabelRules ∩ freshTimeRules` — `allFutureNeg`, `allPastNeg`, `someFuturePos`,
`somePastPos`, `untlPos`, `sncePos` — and the two payment lemmas that cover them,
`mintPotential_lt_of_pick_linear_sigmaFixed` and `..._branching_sigmaFixed`, between them cover
`.linear` and `.branching` only. `.branchingOrdered` and `.notApplicable` need no cover: neither
contributes a successor branch to `pickBranches`. `.persistent` would, and this lemma is what
closes it.

**Why the cheaper route is not available, recorded so it is not re-costed.** The obvious saving is
a `.persistent` variant of `mintPotential_lt_of_pick_linear_sigmaFixed`, since
`nonBranchingResultBranch` treats `.linear` and `.persistent` alike and
`applyRule_fresh_witness_nonbranching` is shape-agnostic. It does not exist, and cannot: the
missing input is `witnessPresent r sf b ord = false`, which the `.linear` and `.branching` arms of
`findApplicableRule` supply from their own `if` and the `.persistent` arm **deliberately does not**
— that arm carries no guard at all, by a design decision `findApplicableRule`'s own comment
records. So there is no `findApplicableRule_guard_persistent` to be had, and the exclusion has to
come from the rule side. It does, decidably, and that is this lemma.

`applyRule` has `.persistent` arms in plenty — `boxPos`, `diamondNeg`, `boxTemporal`,
`allFuturePos`, `allPastPos`, `someFutureNeg`, `somePastNeg`, `densityRule`, `priorUZ`, `priorSZ`,
`z1Rule`, `priorUGap`, `priorSGap`, `sepRule` and `serialityRule` all have one — and not one of them
is among the six. -/
private theorem applyRule_ne_persistent_of_fresh {r : TableauRule} {sf : SignedFormula}
    {b : Branch} {ord : TimeOrdering} {fs : List SignedFormula} {o : TimeOrdering}
    (hlab : ruleMintsFreshLabel r = true) (htime : ruleMintsFreshTime r = true)
    (hA : applyRule r sf b ord = (RuleResult.persistent fs, o)) : False := by
  cases r <;>
    first
      | exact Bool.noConfusion hlab
      | exact Bool.noConfusion htime
      | (simp only [applyRule] at hA
         (repeat' split at hA)
         all_goals simp_all)

/-- **`untlNeg`'s trigger shape, recovered from `isApplicable`.** The rule's arm is
`| .untlNeg, .neg, φ => (asUntil? φ).isSome`, so applicability fixes the sign and hands back the
`asUntil?` view's two components. Destructuring `sf` in the conclusion rather than asserting
`sf.sign = .neg` is what lets the consumer feed `selfGuardPotential_lt_of_untlNeg`, whose trigger
argument is a literal `⟨Sign.neg, φ, l⟩`, without a further rewrite. -/
theorem isApplicable_untlNeg_trigger {sf : SignedFormula}
    {fc : FormalSystem.ProofSystem.FrameClass}
    (hA : isApplicable TableauRule.untlNeg sf fc = true) :
    ∃ e g l, sf = ⟨Sign.neg, sf.formula, l⟩ ∧ asUntil? sf.formula = some (e, g) := by
  rcases sf with ⟨sign, φ, l⟩
  cases sign
  · simp only [isApplicable] at hA; simp at hA
  · rcases h : asUntil? φ with _ | ⟨e, g⟩
    · simp only [isApplicable, h] at hA; simp at hA
    · exact ⟨e, g, l, rfl, rfl⟩

/-- **The `snceNeg` mirror**, through `asSince?`. -/
theorem isApplicable_snceNeg_trigger {sf : SignedFormula}
    {fc : FormalSystem.ProofSystem.FrameClass}
    (hA : isApplicable TableauRule.snceNeg sf fc = true) :
    ∃ e g l, sf = ⟨Sign.neg, sf.formula, l⟩ ∧ asSince? sf.formula = some (e, g) := by
  rcases sf with ⟨sign, φ, l⟩
  cases sign
  · simp only [isApplicable] at hA; simp at hA
  · rcases h : asSince? φ with _ | ⟨e, g⟩
    · simp only [isApplicable, h] at hA; simp at hA
    · exact ⟨e, g, l, rfl, rfl⟩

/-- **`untlNeg`'s ACTIVE guard, inverted from a non-`notApplicable` result.**

One `by_contra` and no arm analysis, and the absence of the arm analysis is the point: the rule's
PASSIVE arm was retired from `applyRule`, so on a trigger the `asUntil?` view accepts there are
exactly two outcomes — the ACTIVE arm under its own `if`, or `.notApplicable`. A reported result
that is not `.notApplicable` therefore *forces* the guard, and the guard is transcribed here
character for character as the arm's `if` writes it, which is also character for character what
`selfGuardPotential_lt_of_untlNeg` asks for. -/
theorem applyRule_untlNeg_active_guard {φ : Formula} {l : Label} {b : Branch} {ord : TimeOrdering}
    {e g : Formula} {res : RuleResult} {o : TimeOrdering}
    (hform : asUntil? φ = some (e, g))
    (hA : applyRule TableauRule.untlNeg ⟨Sign.neg, φ, l⟩ b ord = (res, o))
    (hne : res ≠ RuleResult.notApplicable) :
    ((ord.futureOf l.time).isEmpty && decide (0 < ord.timeCount)
      && decide (ord.timeCount < 4)) = true := by
  by_contra hg
  simp only [Bool.not_eq_true] at hg
  rw [show applyRule TableauRule.untlNeg ⟨Sign.neg, φ, l⟩ b ord
      = (RuleResult.notApplicable, ord) by
    simp only [applyRule, hform]
    simp_all] at hA
  exact hne (by simp_all)

/-- **The `snceNeg` mirror**: `pastOf` in place of `futureOf`, same one-`by_contra` inversion, same
absent PASSIVE arm. -/
theorem applyRule_snceNeg_active_guard {φ : Formula} {l : Label} {b : Branch} {ord : TimeOrdering}
    {e g : Formula} {res : RuleResult} {o : TimeOrdering}
    (hform : asSince? φ = some (e, g))
    (hA : applyRule TableauRule.snceNeg ⟨Sign.neg, φ, l⟩ b ord = (res, o))
    (hne : res ≠ RuleResult.notApplicable) :
    ((ord.pastOf l.time).isEmpty && decide (0 < ord.timeCount)
      && decide (ord.timeCount < 4)) = true := by
  by_contra hg
  simp only [Bool.not_eq_true] at hg
  rw [show applyRule TableauRule.snceNeg ⟨Sign.neg, φ, l⟩ b ord
      = (RuleResult.notApplicable, ord) by
    simp only [applyRule, hform]
    simp_all] at hA
  exact hne (by simp_all)

/-- **The four-bucket census, decided over all thirty-six constructors.**

Every rule either mints no fresh time, or mints one *and* is witness-guarded (the six of
`freshLabelRules ∩ freshTimeRules`), or is one of the two self-guarded minters, or is
`densityRule`. There is no fifth bucket and no residue, and `decide` rather than a hand-written
case list is what guarantees it: a constructor added to `TableauRule` without a home here would
break this proof rather than fall silently into a catch-all. The split is `cases r <;> decide`
rather than `revert r; decide` because `TableauRule` carries no `Fintype` instance, so the
quantified form has no `Decidable` instance to run; `cases` is exhaustive by construction, so the
anti-drift guarantee is the same.

The census is stated over `TableauRule` as a whole rather than over the rules the engine's three
stages can pick, so it covers `serialityRule` and `timeLinearity` too — both in the first bucket,
neither in `freshTimeRules`. -/
private theorem rule_census (r : TableauRule) :
    ruleMintsFreshTime r = false
    ∨ (r ∈ freshLabelRules ∧ ruleMintsFreshTime r = true)
    ∨ r = TableauRule.untlNeg ∨ r = TableauRule.snceNeg
    ∨ r = TableauRule.densityRule := by
  cases r <;> decide


/-! ### The four-bucket case split at the `pickBranches` level

The bulk of the section. `MintPaysForTimeFixed`'s three-way disjunct is proved for every successor
branch a pick reports, by splitting the picked rule into the census's four buckets and closing each
from a payment lemma that is already landed. Every bucket's arithmetic is **exact** — the two
budget conjuncts close by `omega` from inequalities with no slack in them — and no bucket adds a
hypothesis to the predicate.

The buckets are stated separately, each with the pick already destructured, so that each is a
standalone obligation with a readable statement rather than a branch of a long tactic block. -/

/-- The pick-source hypothesis `pick_stage_source`'s consumers take, specialised to a pick that has
already been destructured. Saves repeating the `Option`/`Prod` injectivity dance in every bucket. -/
private theorem pick_singleton_source {b : Branch} {ord : TimeOrdering} {r : TableauRule}
    {sf : SignedFormula} {res : RuleResult} {o : TimeOrdering}
    (hsf : sf ∈ b) (hA : applyRule r sf b ord = (res, o)) :
    ∀ r' res' o', (some (r, res, o) : Option (TableauRule × RuleResult × TimeOrdering))
      = some (r', res', o') → ∃ x, x ∈ b ∧ applyRule r' x b ord = (res', o') := by
  rintro r' res' o' h
  simp only [Option.some.injEq, Prod.mk.injEq] at h
  obtain ⟨rfl, rfl, rfl⟩ := h
  exact ⟨sf, hsf, hA⟩

/-- The same, carrying the no-mint fact `pickBranches_knownTimes_subset` additionally wants. -/
private theorem pick_singleton_source_noMint {b : Branch} {ord : TimeOrdering} {r : TableauRule}
    {sf : SignedFormula} {res : RuleResult} {o : TimeOrdering}
    (hsf : sf ∈ b) (hA : applyRule r sf b ord = (res, o))
    (hnm : ruleMintsFreshTime r = false) :
    ∀ r' res' o', (some (r, res, o) : Option (TableauRule × RuleResult × TimeOrdering))
      = some (r', res', o') → ∃ x, x ∈ b ∧ applyRule r' x b ord = (res', o')
        ∧ ruleMintsFreshTime r' = false := by
  rintro r' res' o' h
  simp only [Option.some.injEq, Prod.mk.injEq] at h
  obtain ⟨rfl, rfl, rfl⟩ := h
  exact ⟨sf, hsf, hA, hnm⟩

/-- **One step adds at most one known time, at the pick level.** The `pickBranches` counterpart of
`knownTimes_card_le_succ_of_unorderedSuccessor`, whose proof this is verbatim with
`pickBranches_time_dichotomy` in place of its engine-level lift. Buckets B and C both need the
inequality *before* the engine lift, because that is where the payment lemmas live. -/
private theorem pickBranches_knownTimes_card_le_succ {b : Branch} {ord : TimeOrdering}
    {p : Option (TableauRule × RuleResult × TimeOrdering)}
    (haux : OrdTimesKnown b ord)
    (hp : ∀ r res o, p = some (r, res, o) → ∃ sf, sf ∈ b ∧ applyRule r sf b ord = (res, o)) :
    ∀ nb ∈ pickBranches b p, nb.knownTimes.toFinset.card ≤ b.knownTimes.toFinset.card + 1 := by
  intro nb hnb
  have hsub : nb.knownTimes.toFinset ⊆ insert b.nextTime b.knownTimes.toFinset := by
    intro t ht
    rcases pickBranches_time_dichotomy haux hp nb hnb t (List.mem_toFinset.mp ht) with h | h
    · exact Finset.mem_insert_of_mem (List.mem_toFinset.mpr h)
    · exact h ▸ Finset.mem_insert_self _ _
  exact le_trans (Finset.card_le_card hsub) (Finset.card_insert_le _ _)

/-- **Bucket A — the rule mints no fresh time: disjunct 1.**

Twenty-seven of the thirty-six constructors, plus `serialityRule` and `timeLinearity`, which is
what the engine's second and third stages run. Nothing about the rule's identity is used beyond the
negative fact: `applyRule_emitted_time_mem` turns it into a `knownTimes` subset, and both of
disjunct 1's conjuncts are read off that subset — the cardinality by `Finset.card_le_card`, the
rank by `splitOrderedRank_le_of_knownTimes_subset` against the ordering growth `pickOrd_mono`
supplies. `σ` does not appear.

This is also the bucket the strengthened bridge's *right* disjunct lands in: stages two and three
report no `findApplicableRule` equation, and they do not need one. -/
private theorem mintPays_bucketA {b : Branch} {ord : TimeOrdering} {Tmax : Nat}
    {r : TableauRule} {sf : SignedFormula} {res : RuleResult} {o : TimeOrdering} {nb : Branch}
    (haux : OrdTimesKnown b ord) (hsf : sf ∈ b)
    (hA : applyRule r sf b ord = (res, o)) (hnm : ruleMintsFreshTime r = false)
    (hnb : nb ∈ pickBranches b (some (r, res, o))) :
    nb.knownTimes.toFinset.card ≤ b.knownTimes.toFinset.card ∧
      splitOrderedRank Tmax nb o ≤ splitOrderedRank Tmax b ord := by
  have hsub := pickBranches_knownTimes_subset haux
    (pick_singleton_source_noMint hsf hA hnm) nb hnb
  refine ⟨Finset.card_le_card ?_, ?_⟩
  · intro t ht
    simp only [List.mem_toFinset] at ht ⊢
    exact hsub t ht
  · exact splitOrderedRank_le_of_knownTimes_subset hsub
      (pickOrd_mono (p := some (r, res, o)) (pick_singleton_source hsf hA))

/-- **Bucket B — the rule is witness-guarded and mints a time: disjunct 2.**

The six of `freshLabelRules ∩ freshTimeRules`. This is the bucket the strengthened bridge exists
for: the payment lemmas consume `findApplicableRule_guard_linear` / `_branching`, whose
`witnessPresent … = false` guard lives inside `findApplicableRule`'s own `if` and **not** inside
`applyRule`, so `pick_stage_source`'s `applyRule` pair is not enough and the stage-one equation is.

Three of the five result shapes are reachable and only two of them carry a successor branch:
`.branchingOrdered` and `.notApplicable` contribute nothing to `pickBranches`, and `.persistent` is
excluded by `applyRule_ne_persistent_of_fresh`. The remaining two are exactly the two the payment
lemmas cover.

Conjunct 1 is the sum, and it is exact: `|kt nb| ≤ |kt b| + 1` from the pick-level dichotomy, and
`mintPotential nb o + 1 ≤ mintPotential b ord` from the payment, add to
`mintTimeBudget nb o ≤ mintTimeBudget b ord` with nothing left over. -/
private theorem mintPays_bucketB {U : Finset SignedFormula} {σ : SignedFormula → SignedFormula}
    {b : Branch} {ord : TimeOrdering} {fc : FormalSystem.ProofSystem.FrameClass}
    {r : TableauRule} {sf : SignedFormula} {res : RuleResult} {o : TimeOrdering} {nb : Branch}
    (haux : OrdTimesKnown b ord) (hconf : ∀ x ∈ b, x ∈ U) (hfix : SigmaFixed σ b) (hsf : sf ∈ b)
    (hpick : findApplicableRule sf b ord fc = some (r, res, o))
    (hlab : ruleMintsFreshLabel r = true) (htime : ruleMintsFreshTime r = true)
    (hnb : nb ∈ pickBranches b (some (r, res, o))) :
    mintTimeBudget U σ nb o ≤ mintTimeBudget U σ b ord ∧
      mintPotential U σ nb o < mintPotential U σ b ord := by
  have hA : applyRule r sf b ord = (res, o) := findApplicableRule_applyRule_pair hpick
  have hlt : mintPotential U σ nb o < mintPotential U σ b ord := by
    cases res with
    | notApplicable =>
        simp [pickBranches, nonBranchingResultBranch, branchingResultBranches] at hnb
    | branchingOrdered bs =>
        simp [pickBranches, nonBranchingResultBranch, branchingResultBranches] at hnb
    | persistent fs => exact (applyRule_ne_persistent_of_fresh hlab htime hA).elim
    | linear fs =>
        simp only [pickBranches, nonBranchingResultBranch, branchingResultBranches,
          Option.toList, List.append_nil, List.mem_cons, List.not_mem_nil, or_false] at hnb
        subst hnb
        exact mintPotential_lt_of_pick_linear_sigmaFixed hconf hfix hsf hpick hlab
    | branching bss =>
        simp only [pickBranches, nonBranchingResultBranch, branchingResultBranches,
          Option.toList, List.nil_append, List.mem_map] at hnb
        obtain ⟨arm, harm, rfl⟩ := hnb
        exact mintPotential_lt_of_pick_branching_sigmaFixed hconf hfix hsf hpick hlab arm harm
  refine ⟨?_, hlt⟩
  have hcard := pickBranches_knownTimes_card_le_succ haux
    (pick_singleton_source hsf hA) nb hnb
  simp only [mintTimeBudget]
  omega

/-- **Bucket C, the `untlNeg` half — the rule is self-guarded: disjunct 3.**

`untlNeg` mints a fresh time and is not in `freshLabelRules`, so disjunct 1 fails (a known time was
added) and disjunct 2 cannot move (`mintPotential`'s index set does not mention the rule). What
pays is the rule's own guard: the ACTIVE arm fires only into an empty future and leaves an edge
behind, so `selfGuardPotential` strictly drops. That is register entry 19's route 2 working exactly
as designed — the drop is *paired* with the combined-budget conjunct rather than offered bare,
because a bare drop is refuted there.

The combined conjunct is again exact: `|kt nb| ≤ |kt b| + 1`, `mintPotential nb o ≤ mintPotential b
ord` (branch and ordering both only grow), and `selfGuardPotential o + 1 ≤ selfGuardPotential ord`
sum to the required inequality with nothing to spare.

`sigmaTimeStable_of_sigmaFixed` is what lets `selfGuardPotential_lt_of_untlNeg` — stated at the
time-level hypothesis — be fed from the predicate's formula-level one. -/
private theorem mintPays_bucketC_untlNeg {U : Finset SignedFormula}
    {σ : SignedFormula → SignedFormula} {b : Branch} {ord : TimeOrdering}
    {fc : FormalSystem.ProofSystem.FrameClass} {sf : SignedFormula} {res : RuleResult}
    {o : TimeOrdering} {nb : Branch}
    (haux : OrdTimesKnown b ord) (hconf : ∀ x ∈ b, x ∈ U) (hfix : SigmaFixed σ b) (hsf : sf ∈ b)
    (hAp : isApplicable TableauRule.untlNeg sf fc = true)
    (hA : applyRule TableauRule.untlNeg sf b ord = (res, o))
    (hnb : nb ∈ pickBranches b (some (TableauRule.untlNeg, res, o))) :
    mintTimeBudget U σ nb o + selfGuardPotential U σ o
        ≤ mintTimeBudget U σ b ord + selfGuardPotential U σ ord ∧
      selfGuardPotential U σ o < selfGuardPotential U σ ord := by
  obtain ⟨e, g, l, hsfeq, hform⟩ := isApplicable_untlNeg_trigger hAp
  have hne : res ≠ RuleResult.notApplicable := by
    rintro rfl
    simp [pickBranches, nonBranchingResultBranch, branchingResultBranches] at hnb
  have hsfb : (⟨Sign.neg, sf.formula, l⟩ : SignedFormula) ∈ b := by
    rw [← hsfeq]; exact hsf
  have hA' : applyRule TableauRule.untlNeg ⟨Sign.neg, sf.formula, l⟩ b ord = (res, o) := by
    rw [← hsfeq]; exact hA
  have hguard := applyRule_untlNeg_active_guard hform hA' hne
  have hdrop : selfGuardPotential U σ o < selfGuardPotential U σ ord := by
    have h := selfGuardPotential_lt_of_untlNeg (U := U) (σ := σ) hconf
      (sigmaTimeStable_of_sigmaFixed hfix) hsfb hform hguard
    rwa [hA'] at h
  refine ⟨?_, hdrop⟩
  have hcard := pickBranches_knownTimes_card_le_succ haux
    (pick_singleton_source hsf hA) nb hnb
  have hgrow : mintPotential U σ nb o ≤ mintPotential U σ b ord := by
    refine mintPotential_le_of_grow (resultBranch_sub (b := b) (nb := nb) (res := res) hnb).1 ?_
    have hm := applyRule_ord_mono TableauRule.untlNeg sf b ord
    rwa [hA] at hm
  simp only [mintTimeBudget]
  omega

/-- **Bucket C, the `snceNeg` half.** The exact past mirror, `pastOf` for `futureOf` throughout. -/
private theorem mintPays_bucketC_snceNeg {U : Finset SignedFormula}
    {σ : SignedFormula → SignedFormula} {b : Branch} {ord : TimeOrdering}
    {fc : FormalSystem.ProofSystem.FrameClass} {sf : SignedFormula} {res : RuleResult}
    {o : TimeOrdering} {nb : Branch}
    (haux : OrdTimesKnown b ord) (hconf : ∀ x ∈ b, x ∈ U) (hfix : SigmaFixed σ b) (hsf : sf ∈ b)
    (hAp : isApplicable TableauRule.snceNeg sf fc = true)
    (hA : applyRule TableauRule.snceNeg sf b ord = (res, o))
    (hnb : nb ∈ pickBranches b (some (TableauRule.snceNeg, res, o))) :
    mintTimeBudget U σ nb o + selfGuardPotential U σ o
        ≤ mintTimeBudget U σ b ord + selfGuardPotential U σ ord ∧
      selfGuardPotential U σ o < selfGuardPotential U σ ord := by
  obtain ⟨e, g, l, hsfeq, hform⟩ := isApplicable_snceNeg_trigger hAp
  have hne : res ≠ RuleResult.notApplicable := by
    rintro rfl
    simp [pickBranches, nonBranchingResultBranch, branchingResultBranches] at hnb
  have hsfb : (⟨Sign.neg, sf.formula, l⟩ : SignedFormula) ∈ b := by
    rw [← hsfeq]; exact hsf
  have hA' : applyRule TableauRule.snceNeg ⟨Sign.neg, sf.formula, l⟩ b ord = (res, o) := by
    rw [← hsfeq]; exact hA
  have hguard := applyRule_snceNeg_active_guard hform hA' hne
  have hdrop : selfGuardPotential U σ o < selfGuardPotential U σ ord := by
    have h := selfGuardPotential_lt_of_snceNeg (U := U) (σ := σ) hconf
      (sigmaTimeStable_of_sigmaFixed hfix) hsfb hform hguard
    rwa [hA'] at h
  refine ⟨?_, hdrop⟩
  have hcard := pickBranches_knownTimes_card_le_succ haux
    (pick_singleton_source hsf hA) nb hnb
  have hgrow : mintPotential U σ nb o ≤ mintPotential U σ b ord := by
    refine mintPotential_le_of_grow (resultBranch_sub (b := b) (nb := nb) (res := res) hnb).1 ?_
    have hm := applyRule_ord_mono TableauRule.snceNeg sf b ord
    rwa [hA] at hm
  simp only [mintTimeBudget]
  omega

/-- **The census case split, assembled: `MintPaysForTimeFixed`'s disjunct at the pick level.**

The four buckets joined by `rule_census`, with `densityRule` — bucket D — discharged rather than
proved: `findApplicableRule_ne_densityRule` excludes it outright under the frame-class hypothesis,
and it is the only place that hypothesis is used in the whole section. When the bridge reports its
*right* disjunct instead, the rule is outside `freshTimeRules` and lands in bucket A, so no density
case arises on that side either.

Because the split is driven by a `decide`-proved census rather than by a hand-written constructor
list, no rule is handled by an unexamined catch-all: a rule with no bucket would break `rule_census`
rather than pass through here silently. -/
private theorem pickBranches_mintPays {U : Finset SignedFormula}
    {σ : SignedFormula → SignedFormula} {b : Branch} {ord : TimeOrdering}
    {fc : FormalSystem.ProofSystem.FrameClass} {Tmax : Nat}
    {p : Option (TableauRule × RuleResult × TimeOrdering)}
    (hfc : ¬ (FormalSystem.ProofSystem.FrameClass.Dense ≤ fc))
    (haux : OrdTimesKnown b ord) (hconf : ∀ x ∈ b, x ∈ U) (hfix : SigmaFixed σ b)
    (hp : ∀ r res o, p = some (r, res, o) → ∃ sf, sf ∈ b ∧ applyRule r sf b ord = (res, o) ∧
      (findApplicableRule sf b ord fc = some (r, res, o) ∨ ruleMintsFreshTime r = false)) :
    ∀ nb ∈ pickBranches b p,
      (nb.knownTimes.toFinset.card ≤ b.knownTimes.toFinset.card ∧
        splitOrderedRank Tmax nb (pickOrd ord p) ≤ splitOrderedRank Tmax b ord)
      ∨ (mintTimeBudget U σ nb (pickOrd ord p) ≤ mintTimeBudget U σ b ord ∧
          mintPotential U σ nb (pickOrd ord p) < mintPotential U σ b ord)
      ∨ (mintTimeBudget U σ nb (pickOrd ord p) + selfGuardPotential U σ (pickOrd ord p)
            ≤ mintTimeBudget U σ b ord + selfGuardPotential U σ ord ∧
          selfGuardPotential U σ (pickOrd ord p) < selfGuardPotential U σ ord) := by
  rcases p with _ | ⟨r, res, o⟩
  · simp [pickBranches]
  · obtain ⟨sf, hsf, hA, hsrc⟩ := hp r res o rfl
    intro nb hnb
    rcases hsrc with hpick | hnm
    · rcases rule_census r with hnm | ⟨hlabmem, htime⟩ | hun | hsn | hden
      · exact Or.inl (mintPays_bucketA (Tmax := Tmax) haux hsf hA hnm hnb)
      · exact Or.inr (Or.inl (mintPays_bucketB haux hconf hfix hsf hpick
          (mem_freshLabelRules.mp hlabmem) htime hnb))
      · subst hun
        exact Or.inr (Or.inr (mintPays_bucketC_untlNeg haux hconf hfix hsf
          (findApplicableRule_isApplicable hpick) hA hnb))
      · subst hsn
        exact Or.inr (Or.inr (mintPays_bucketC_snceNeg haux hconf hfix hsf
          (findApplicableRule_isApplicable hpick) hA hnb))
      · exact absurd hden (findApplicableRule_ne_densityRule hfc hpick)
    · exact Or.inl (mintPays_bucketA (Tmax := Tmax) haux hsf hA hnm hnb)


/-! ### The engine lift and the discharge -/

/-- **The engine-level lift.** The `keyO`/`keyB` pattern of `expandOnceUnblocked_ordTimes`, run
once more: `pick_ord_eq` and `pick_branches_eq` restate the step's two components as `pickOrd` and
`pickBranches` over the three-stage `match`, and the pick-level result is applied to it with
`pick_stage_source_rule` as the source. The three-stage pick is not destructured a second time. -/
theorem expandOnceUnblocked_mintPays {U : Finset SignedFormula}
    {σ : SignedFormula → SignedFormula} {b : Branch} {ord : TimeOrdering}
    {fc : FormalSystem.ProofSystem.FrameClass} {tr : EventualityTracker} {Tmax : Nat}
    (hfc : ¬ (FormalSystem.ProofSystem.FrameClass.Dense ≤ fc))
    (haux : OrdTimesKnown b ord) (hconf : ∀ x ∈ b, x ∈ U) (hfix : SigmaFixed σ b) :
    ∀ nb ∈ unorderedSuccessorBranches (expandOnceUnblocked b ord fc tr).1,
      (nb.knownTimes.toFinset.card ≤ b.knownTimes.toFinset.card ∧
        splitOrderedRank Tmax nb (expandOnceUnblocked b ord fc tr).2
          ≤ splitOrderedRank Tmax b ord)
      ∨ (mintTimeBudget U σ nb (expandOnceUnblocked b ord fc tr).2
            ≤ mintTimeBudget U σ b ord ∧
          mintPotential U σ nb (expandOnceUnblocked b ord fc tr).2
            < mintPotential U σ b ord)
      ∨ (mintTimeBudget U σ nb (expandOnceUnblocked b ord fc tr).2
            + selfGuardPotential U σ (expandOnceUnblocked b ord fc tr).2
            ≤ mintTimeBudget U σ b ord + selfGuardPotential U σ ord ∧
          selfGuardPotential U σ (expandOnceUnblocked b ord fc tr).2
            < selfGuardPotential U σ ord) := by
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
  exact pickBranches_mintPays hfc haux hconf hfix (pick_stage_source_rule b ord fc tr)

/-- **The discharge.** `MintPaysForTimeFixed fc U Tmax` at an **arbitrary** universe — no syntactic
condition on the formulas, no emptiness, no added hypothesis on the predicate — for every frame
class the density rule cannot fire at.

**The one restriction, in the statement.** `¬ (FrameClass.Dense ≤ fc)` is a single hypothesis and
it is written here rather than hidden behind a definition, a `variable`, or a typeclass. It covers
`.Dense` and `.RTime` together and admits exactly `.Base` and `.ZTime`, and it is what buys
the exclusion of the density coordinate — register entry 20's item (b) — rather than closing it.
`gapPotential` is still implemented nowhere and assumed by nothing.

**What this retires.** Entry 20's item (a): the engine-level assembly. The per-rule payments all
existed; what was missing was the pick's rule identity at the successor, which
`pick_stage_source_rule` now threads. The predicate's hypothesis list is untouched.

**What this does not do.** It makes no terminus in this file non-vacuous. See the section prose. -/
theorem mintPaysForTimeFixed_of_not_dense {fc : FormalSystem.ProofSystem.FrameClass}
    {U : Finset SignedFormula} {Tmax : Nat}
    (hfc : ¬ (FormalSystem.ProofSystem.FrameClass.Dense ≤ fc)) :
    MintPaysForTimeFixed fc U Tmax := by
  intro σ b ord tr hri hconf hfix nb hnb
  exact expandOnceUnblocked_mintPays hfc hri.ordTimesKnown hconf hfix nb hnb

/-- **The discharge at the concrete universe the seed-level termini consume**, for **every** stock
`C` and every label set `L`.

This supersedes `mintPaysForTimeFixed_signedUniverse_empty`, whose universe is the `L = ∅` shadow,
and generalizes `mintPaysForTimeFixed_signedUniverse_untlSnceFree` off its syntactic fragment: `C`
here may carry `untl` and `snce` nodes freely, which is the case register entry 20 itself calls the
hard one. Neither of those two is deleted or altered; they are superseded in prose only, and
`mintPaysForTimeFixed_signedUniverse_untlSnceFree` remains the statement to reach for at `.Dense`
and `.RTime`, where this one is silent.

**Satisfiable rather than vacuous.** `signedUniverse_nonempty` makes the universe nonempty as soon
as `C` and `L` are, and the discharged hypothesis is a *theorem* there rather than a condition
nobody meets — which is exactly what separates this from the `hlab` residual. -/
theorem mintPaysForTimeFixed_signedUniverse_of_not_dense
    {fc : FormalSystem.ProofSystem.FrameClass} (C : Finset Formula) (L : Finset Label)
    (Tmax : Nat) (hfc : ¬ (FormalSystem.ProofSystem.FrameClass.Dense ≤ fc)) :
    MintPaysForTimeFixed fc (signedUniverse C L) Tmax :=
  mintPaysForTimeFixed_of_not_dense hfc

end FormalSystem.Metalogic.Decidability
