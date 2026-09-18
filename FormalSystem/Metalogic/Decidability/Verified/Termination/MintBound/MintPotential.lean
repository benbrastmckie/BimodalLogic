/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.Verified.Termination.MintBound.OrderingTimes

/-! # C1. The world dimension, and a time bound that does not go through the mint chain

Two independent obligations meet here.

**The time bound must not be circular.** `|U| = |signedUniverse C L|` with `L = worlds × times`,
while times grow by minting — so a time bound derived *from* the mint count would make the whole
chain circular. `timeFinset_card_le_of_mem_stock` below is the non-circular route, and it is
non-circular for a reason that can be read off its hypotheses rather than argued: branch-confined-
to-stock, linearity-saturated, eventuality-fulfilled, blocking-silent. **Not one of the four
mentions a world, a mint, or `|U|`.** Its conclusion `2 ^ (2 * |C|)` is a function of the stock
alone.

**The world dimension.** `worldFinset_card_le` turns the fresh-world discipline `WorldWitness`
into `|worlds| ≤ |S| + 2·|C|·|times|`, and `Branch.card_labelFinset_le` multiplies the two
dimensions into the label bound that `expandBranchWithFuel_isSome_at_worldFuel'` takes as `hL`.
`labelFinset_card_le_of_worldWitness` assembles exactly that, and `seedWorlds_card` pins `s = 1`
at the engine's own seed.

**What is discharged here and what is not, stated plainly.** `WorldWitness` is discharged **at the
seed branch** (`worldWitness_seedBranch`), which is what fixes `s = 1`. It is **not** discharged as
a run-level invariant: `chain_le_worldFuel'` wants `WorldWitness C S (run n)` at step `n`, and
establishing that is an induction over `applyRule`'s 36 constructors whose content is the
injectivity clause — a second world minted for the same sign/formula/time would have found the
first one's witness and been suppressed, which is `witnessPresent`'s world-indifference. That
induction is not attempted here. The residual is therefore exactly one named hypothesis,
`WorldWitness C (seedBranch φ).worldFinset b`, and every result below carries it visibly in its
statement rather than absorbing it. -/

namespace FormalSystem.Metalogic.Decidability

open FormalSystem.Syntax

/-- **The engine's seed branch.** Both `buildTableauAt` and `buildTableau` open with the single
signed formula `¬φ` at `Label.initial` and hand it to `expandBranchWithFuel` together with
`TimeOrdering.empty`. Named here so the seed-side facts cite one shape instead of repeating it. -/
def seedBranch (φ : Formula) : Branch := [SignedFormula.neg φ Label.initial]

/-- **The seed mentions exactly one world**, world `0` — which is what makes `s = 1` the right
instantiation of the world bound's seed parameter, rather than a figure chosen for convenience. -/
theorem seedWorlds_card (φ : Formula) : (seedBranch φ).worldFinset.card = 1 := rfl

/-- **`WorldWitness` at the seed.** Discharged, not assumed: at `S := (seedBranch φ).worldFinset`
every world of the branch lies in `S`, so both clauses of the discipline are satisfied by absence
of a non-seed world.

This is `worldWitness_self` at the seed, and — unlike the degenerate reading its docstring warns
about — it is *not* empty here, because `seedWorlds_card` computes `|S| = 1`. The world bound's
first summand is therefore a constant, which is the whole point of scoping to the seed. -/
theorem worldWitness_seedBranch (C : Finset Formula) (φ : Formula) :
    WorldWitness C (seedBranch φ).worldFinset (seedBranch φ) :=
  worldWitness_self C (seedBranch φ)

/-- **T2, in the form this chain consumes, and demonstrably not circular.**

`timeFinset_card_le_of_not_blocked` wants `TimeChain b ord`; `timeChain_of_linearity_saturated`
supplies it from the linearity stage's own silence, since `timeLinearity` is self-suppressing and
fires exactly while an incomparable pair remains. Composing the two leaves four hypotheses, and the
reason the mint bound may rest on this is that **none of them mentions a world, a mint, or the
signed universe**: the bound `2 ^ (2 * |C|)` is a function of the stock alone. -/
theorem timeFinset_card_le_of_mem_stock {C : Finset Formula} {b : Branch} {ord : TimeOrdering}
    {tracker : EventualityTracker}
    (hb : ∀ x ∈ b, x.formula ∈ C)
    (hlin : firstIncomparablePair b ord = none)
    (hev : ∀ t₁ ∈ b.knownTimes, ∀ t₂ ∈ b.knownTimes,
      allEventualitiesFulfilledOrDuplicated tracker t₁ t₂ = true)
    (hnb : findBlockedTime b ord tracker = none) :
    b.timeFinset.card ≤ 2 ^ (2 * C.card) :=
  timeFinset_card_le_of_not_blocked hb (timeChain_of_linearity_saturated hlin) hev hnb

/-- **The label bound, in the exact shape `expandBranchWithFuel_isSome_at_worldFuel'` takes as
`hL`.** The two dimensions multiply: `worldFinset_card_le` bounds the world component by
`|S| + 2·|C|·|times|`, the time component is bounded by `htime`, and `Branch.card_labelFinset_le`
injects labels into their two components. -/
theorem labelFinset_card_le_of_worldWitness {C : Finset Formula} {S : Finset WorldIndex}
    {b : Branch} {s : Nat}
    (hww : WorldWitness C S b) (hs : S.card ≤ s)
    (htime : b.timeFinset.card ≤ 2 ^ (2 * C.card)) :
    b.labelFinset.card ≤ (s + 2 * C.card * 2 ^ (2 * C.card)) * 2 ^ (2 * C.card) := by
  refine le_trans (Branch.card_labelFinset_le b) ?_
  have hw : b.worldFinset.card ≤ s + 2 * C.card * 2 ^ (2 * C.card) :=
    le_trans (worldFinset_card_le hww)
      (Nat.add_le_add hs (Nat.mul_le_mul_left _ htime))
  exact Nat.mul_le_mul hw htime

/-- **The label bound at `s = 1`**, the figure the engine's own seed supplies.

The one input not discharged in this module is `hww` — the fresh-world discipline **at the run's
branch `b`**, not at the seed. It is carried explicitly rather than absorbed, so that a consumer
can see precisely what remains: `worldWitness_seedBranch` gives the `n = 0` case, and the step case
is the 36-constructor induction described in the section preamble. -/
theorem labelFinset_card_le_at_seed_worlds {C : Finset Formula} {φ : Formula} {b : Branch}
    (hww : WorldWitness C (seedBranch φ).worldFinset b)
    (htime : b.timeFinset.card ≤ 2 ^ (2 * C.card)) :
    b.labelFinset.card ≤ (1 + 2 * C.card * 2 ^ (2 * C.card)) * 2 ^ (2 * C.card) :=
  labelFinset_card_le_of_worldWitness hww (le_of_eq (seedWorlds_card φ)) htime

/-! ## C2. The fresh-world discipline is preserved by a rule application

`WorldWitness` as `Fuel.lean` states it is **not inductive**: its witness function `wit` is
constrained only by `(wit w).formula ∈ C` and `(wit w).label.time ∈ b.timeFinset`, and is not
required to lie on the branch or to sit at the world it witnesses. The preservation argument needs
both: at a fresh-world mint, the new world's witness is distinct from every existing one *because*
an existing witness **on the branch** carrying the same sign, formula and time would have made
`witnessPresent` true and suppressed the mint. With `wit w` free-floating there is nothing to feed
the guard.

The repair is the same shape as this file's `OrdTimesKnown` repair: `WorldWitnessKnown` below
carries `wit w ∈ b ∧ (wit w).label.world = w` alongside the existing clauses,
`worldWitness_of_known` derives the weak form from it (the strengthening witness, mirroring
`ordTimesLeMaxTime_of_ordTimesKnown`), and the induction runs on the strong form. `Fuel.lean` is
not edited.

The world dimension is much narrower than the times dimension: of `TableauRule`'s 36
constructors exactly **two** — `boxNeg` and `diamondPos` — mint a world, and both do it by
emitting at `Branch.nextWorld`. `applyRule_emitted_world_mem` discharges the other 34 in one
split; the two minting rules are then handled by name, with the guard supplying the injectivity
clause. -/

/-- Identification relabels times only, so it never introduces a world. -/
theorem mem_identifyTime_world {b : Branch} {src tgt : TimeIndex} {g : SignedFormula}
    (h : g ∈ b.identifyTime src tgt) : g.label.world ∈ b.worldFinset := by
  simp only [Branch.identifyTime, List.mem_eraseDups, List.mem_map] at h
  obtain ⟨x, hx, rfl⟩ := h
  by_cases hc : x.label.time = src <;> simp only [hc, if_true, if_false, beq_iff_eq] <;>
    exact Branch.mem_worldFinset hx

/-- World-level analogue of `mem_filterMap_sub`: a propagation block that reads formulas off the
branch through a `List.filter` selector and relabels them emits nothing at a new world. The
hypothesis `hF` is discharged per block by opening the block's own `match`/`if`. -/
theorem mem_filterMap_world {b : Branch} {P : SignedFormula → Bool}
    {F : SignedFormula → Option SignedFormula} {g : SignedFormula}
    (hF : ∀ x y, F x = some y → y.label.world = x.label.world)
    (h : g ∈ (b.filter P).filterMap F) : g.label.world ∈ b.worldFinset := by
  obtain ⟨x, hx, hxg⟩ := List.mem_filterMap.mp h
  rw [hF x g hxg]
  exact Branch.mem_worldFinset (List.mem_of_mem_filter hx)

/-- The same shape with a constant target world, for the two rules that emit at `nextWorld`. -/
theorem mem_filterMap_const_world {l : List SignedFormula}
    {F : SignedFormula → Option SignedFormula} {w : WorldIndex} {g : SignedFormula}
    (hF : ∀ x y, F x = some y → y.label.world = w) (h : g ∈ l.filterMap F) :
    g.label.world = w := by
  obtain ⟨x, hx, hxg⟩ := List.mem_filterMap.mp h
  exact hF x g hxg

set_option maxHeartbeats 4000000 in
-- `repeat' split` case-splits every arm of the 36-constructor `applyRule` match; elaborating
-- all of them is past the default heartbeat budget.
/-- **Only `boxNeg` and `diamondPos` leave the branch's worlds.** Every other rule emits at a
world the branch already mentions: the propositional and temporal rules at the trigger's own
world, the persistent-universal rules at a `knownWorlds` entry, the fresh-*time* rules at the
trigger's world (their `boxDiamondPersistence` block included, by
`mem_boxDiamondPersistence_label`), and `timeLinearity`'s identification arm by
`mem_identifyTime_world`.

The full 34 × 2 split, stated against `RuleResult.emitted` so that one statement covers all five
result shapes at once. -/
theorem applyRule_emitted_world_mem {rule : TableauRule} {sf : SignedFormula}
    {b : Branch} {ord : TimeOrdering}
    (hsf : sf ∈ b) (h1 : rule ≠ .boxNeg) (h2 : rule ≠ .diamondPos) :
    ∀ g ∈ (applyRule rule sf b ord).1.emitted, g.label.world ∈ b.worldFinset := by
  have hw : sf.label.world ∈ b.worldFinset := Branch.mem_worldFinset hsf
  cases sf with
  | mk sign formula label =>
    cases rule <;> first
      | exact absurd rfl h1
      | exact absurd rfl h2
      | (cases sign <;> simp only [applyRule] <;> (repeat' split) <;>
          (try contradiction) <;>
          intro g hg <;>
          repeat' first
            | exact hw
            | exact Branch.mem_worldFinset hg
            | exact mem_identifyTime_world hg
            | (rw [(mem_boxDiamondPersistence_label hg).1]; exact hw)
            | (obtain ⟨x, hx, rfl⟩ := mem_filterMap_guarded hg
               first
                 | exact hw
                 | exact List.mem_toFinset.mpr hx)
            | (refine mem_filterMap_world ?_ hg
               clear hg
               intro x y hy
               repeat' first
                 | split at hy
                 | simp only [Option.some.injEq] at hy
               all_goals first
                 | (subst hy; rfl)
                 | (simp only [reduceCtorEq] at hy))
            | (simp only [RuleResult.emitted, 
                 Branch.allFuturePosFormulas, Branch.allPastPosFormulas,
                 Branch.someFutureNegFormulas, Branch.somePastNegFormulas,
                 
                 List.map_cons, List.map_nil, List.flatten_cons, List.flatten_nil,
                 List.append_nil, List.mem_cons, List.mem_append, List.not_mem_nil,
                 or_false, List.mem_filter] at hg)
            | (subst hg; exact hw)
            | (rcases hg with hg | hg))

set_option maxHeartbeats 1000000 in
-- `repeat' split` case-splits every arm of the 36-constructor `applyRule` match; elaborating
-- all of them is past the default heartbeat budget.
/-- `boxNeg` emits **only** at `Branch.nextWorld`: the witness and both auto-propagation blocks
carry the fresh world. -/
theorem applyRule_boxNeg_emitted_world {sf : SignedFormula} {b : Branch} {ord : TimeOrdering} :
    ∀ g ∈ (applyRule .boxNeg sf b ord).1.emitted, g.label.world = b.nextWorld := by
  cases sf with
  | mk sign formula label =>
    cases sign <;> simp only [applyRule] <;> (repeat' split) <;> (try contradiction) <;>
      intro g hg <;>
      repeat' first
        | rfl
        | (refine mem_filterMap_const_world ?_ hg
           clear hg
           intro x y hy
           repeat' first
             | split at hy
             | simp only [Option.some.injEq] at hy
           all_goals first
             | (subst hy; rfl)
             | (simp only [reduceCtorEq] at hy))
        | (simp only [RuleResult.emitted, Branch.boxPosFormulas, Branch.diamondNegFormulas,
             List.mem_cons, List.mem_append, List.not_mem_nil] at hg)
        | (subst hg; rfl)
        | (rcases hg with hg | hg)

set_option maxHeartbeats 1000000 in
-- `repeat' split` case-splits every arm of the 36-constructor `applyRule` match; elaborating
-- all of them is past the default heartbeat budget.
/-- The `diamondPos` mirror of `applyRule_boxNeg_emitted_world`. -/
theorem applyRule_diamondPos_emitted_world {sf : SignedFormula} {b : Branch} {ord : TimeOrdering} :
    ∀ g ∈ (applyRule .diamondPos sf b ord).1.emitted, g.label.world = b.nextWorld := by
  cases sf with
  | mk sign formula label =>
    cases sign <;> simp only [applyRule] <;> (repeat' split) <;>
      intro g hg <;>
      repeat' first
        | rfl
        | (refine mem_filterMap_const_world ?_ hg
           clear hg
           intro x y hy
           repeat' first
             | split at hy
             | simp only [Option.some.injEq] at hy
           all_goals first
             | (subst hy; rfl)
             | (simp only [reduceCtorEq] at hy))
        | (simp only [RuleResult.emitted, Branch.boxPosFormulas, Branch.diamondNegFormulas,
             List.mem_cons, List.mem_append, List.not_mem_nil] at hg)
        | (subst hg; rfl)
        | (rcases hg with hg | hg)

set_option maxHeartbeats 1000000 in
-- `repeat' split` case-splits every arm of the 36-constructor `applyRule` match; elaborating
-- all of them is past the default heartbeat budget.
/-- If `boxNeg` emitted anything at all, the trigger had the shape the rule is keyed on. This is
what turns "a new world appeared" into a statement about the *rule's own* witness. -/
theorem applyRule_boxNeg_shape {sf : SignedFormula} {b : Branch} {ord : TimeOrdering}
    {g : SignedFormula} (hg : g ∈ (applyRule .boxNeg sf b ord).1.emitted) :
    ∃ ψ, sf.formula = Formula.box ψ ∧ sf.sign = Sign.neg := by
  cases sf with
  | mk sign formula label =>
    cases sign <;> simp only [applyRule] at hg <;> (repeat' split at hg) <;>
      first
        | contradiction
        | exact ⟨_, rfl, rfl⟩

set_option maxHeartbeats 1000000 in
-- `repeat' split` case-splits every arm of the 36-constructor `applyRule` match; elaborating
-- all of them is past the default heartbeat budget.
/-- The `diamondPos` mirror of `applyRule_boxNeg_shape`. -/
theorem applyRule_diamondPos_shape {sf : SignedFormula} {b : Branch} {ord : TimeOrdering}
    {g : SignedFormula} (hg : g ∈ (applyRule .diamondPos sf b ord).1.emitted) :
    ∃ ψ, asDiamond? sf.formula = some ψ ∧ sf.sign = Sign.pos := by
  cases sf with
  | mk sign formula label =>
    cases sign <;> simp only [applyRule] at hg <;> (repeat' split at hg) <;>
      first
        | contradiction
        | exact ⟨_, by assumption, rfl⟩

/-- At its own trigger shape, `boxNeg` returns a `.linear` result — so its successor is the single
branch `fs ++ b`, and everything it emitted is on that branch. -/
theorem applyRule_boxNeg_eq {sf : SignedFormula} {ψ : Formula} {b : Branch} {ord : TimeOrdering}
    (hf : sf.formula = Formula.box ψ) (hs : sf.sign = Sign.neg) :
    ∃ fs, (applyRule .boxNeg sf b ord).1 = RuleResult.linear fs := by
  cases sf with
  | mk sign formula label =>
    simp only at hf hs
    subst hf; subst hs
    exact ⟨_, rfl⟩

/-- The `diamondPos` mirror of `applyRule_boxNeg_eq`. -/
theorem applyRule_diamondPos_eq {sf : SignedFormula} {ψ : Formula} {b : Branch}
    {ord : TimeOrdering} (hf : asDiamond? sf.formula = some ψ) (hs : sf.sign = Sign.pos) :
    ∃ fs, (applyRule .diamondPos sf b ord).1 = RuleResult.linear fs := by
  cases sf with
  | mk sign formula label =>
    simp only at hf hs
    subst hs
    rw [asDiamond?_eq_iff] at hf
    subst hf
    exact ⟨_, rfl⟩

/-- Independently of the trigger's shape, `boxNeg` returns either nothing or a `.linear` result —
never `.persistent` and never a split. Consumed where a rule's result shape has to be excluded
without first knowing that the rule fired. -/
theorem applyRule_boxNeg_result (sf : SignedFormula) (b : Branch) (ord : TimeOrdering) :
    (applyRule .boxNeg sf b ord).1 = RuleResult.notApplicable ∨
      ∃ fs, (applyRule .boxNeg sf b ord).1 = RuleResult.linear fs := by
  cases sf with
  | mk sign formula label =>
    cases sign <;> simp only [applyRule] <;> (repeat' split) <;>
      first
        | contradiction
        | exact Or.inl rfl
        | exact Or.inl trivial
        | exact Or.inr ⟨_, rfl⟩

/-- The `diamondPos` mirror of `applyRule_boxNeg_result`. -/
theorem applyRule_diamondPos_result (sf : SignedFormula) (b : Branch) (ord : TimeOrdering) :
    (applyRule .diamondPos sf b ord).1 = RuleResult.notApplicable ∨
      ∃ fs, (applyRule .diamondPos sf b ord).1 = RuleResult.linear fs := by
  cases sf with
  | mk sign formula label =>
    cases sign <;> simp only [applyRule] <;> (repeat' split) <;>
      first
        | contradiction
        | exact Or.inl rfl
        | exact Or.inl trivial
        | exact Or.inr ⟨_, rfl⟩

/-- The `witness` of the rule's own conclusion is the head of what `boxNeg` emits. -/
theorem applyRule_boxNeg_witness {sf : SignedFormula} {ψ : Formula} {b : Branch}
    {ord : TimeOrdering} (hf : sf.formula = Formula.box ψ) (hs : sf.sign = Sign.neg) :
    SignedFormula.neg ψ { world := b.nextWorld, time := sf.label.time }
      ∈ (applyRule .boxNeg sf b ord).1.emitted := by
  cases sf with
  | mk sign formula label =>
    simp only at hf hs
    subst hf; subst hs
    simp only [applyRule, RuleResult.emitted]
    exact List.mem_cons_self

/-- The `diamondPos` mirror of `applyRule_boxNeg_witness`. -/
theorem applyRule_diamondPos_witness {sf : SignedFormula} {ψ : Formula} {b : Branch}
    {ord : TimeOrdering} (hf : asDiamond? sf.formula = some ψ) (hs : sf.sign = Sign.pos) :
    SignedFormula.pos ψ { world := b.nextWorld, time := sf.label.time }
      ∈ (applyRule .diamondPos sf b ord).1.emitted := by
  cases sf with
  | mk sign formula label =>
    simp only at hf hs
    subst hs
    rw [asDiamond?_eq_iff] at hf
    subst hf
    simp only [applyRule, RuleResult.emitted]
    exact List.mem_cons_self

/-! ### The strengthened discipline -/

/-- **The fresh-world discipline, strengthened so that it is inductive.**

`WorldWitness` (`Fuel.lean`) says only that each non-seed world's witness has a stock formula and
a branch time. This adds the two clauses the preservation argument needs and the weak form omits:
the witness lies **on the branch**, and it sits at the world it witnesses. Both are what let the
`witnessPresent` guard be applied at a mint — the guard scans the branch for a formula at a known
world, so a witness that is neither on the branch nor at its own world cannot be fed to it.

`worldWitness_of_known` recovers the weak form, so every landed `WorldWitness` consumer keeps
working. This is a strengthening, not a weakening. -/
def WorldWitnessKnown (C : Finset Formula) (S : Finset WorldIndex) (b : Branch) : Prop :=
  ∃ wit : WorldIndex → SignedFormula,
    (∀ w ∈ b.worldFinset, w ∉ S →
      wit w ∈ b ∧ (wit w).label.world = w ∧ (wit w).formula ∈ C) ∧
    (∀ w₁ ∈ b.worldFinset, w₁ ∉ S → ∀ w₂ ∈ b.worldFinset, w₂ ∉ S →
      witnessSig (wit w₁) = witnessSig (wit w₂) → w₁ = w₂)

/-- **The strengthening witness.** The strong discipline implies the weak one, with the same
witness function: the time clause the weak form asks for follows from branch membership. This is
what makes `WorldWitnessKnown` a strengthening of `WorldWitness` rather than a different
condition, and it is what `worldFinset_card_le` is reached through. -/
theorem worldWitness_of_known {C : Finset Formula} {S : Finset WorldIndex} {b : Branch}
    (h : WorldWitnessKnown C S b) : WorldWitness C S b := by
  obtain ⟨wit, hwit, hinj⟩ := h
  refine ⟨wit, ?_, hinj⟩
  intro w hw hs
  obtain ⟨hmem, -, hC⟩ := hwit w hw hs
  exact ⟨hC, Branch.mem_timeFinset hmem⟩

/-- A world the branch mentions is mentioned by one of its formulas. -/
theorem exists_mem_of_mem_worldFinset {b : Branch} {w : WorldIndex} (h : w ∈ b.worldFinset) :
    ∃ x ∈ b, x.label.world = w := by
  simp only [Branch.worldFinset, List.mem_toFinset, Branch.knownWorlds, List.mem_eraseDups,
    List.mem_map] at h
  obtain ⟨x, hx, hxw⟩ := h
  exact ⟨x, hx, hxw⟩

/-- `Branch.nextWorld` is fresh, as a `worldFinset` statement. -/
theorem nextWorld_not_mem_worldFinset (b : Branch) : b.nextWorld ∉ b.worldFinset := by
  intro h
  obtain ⟨x, hx, hxw⟩ := exists_mem_of_mem_worldFinset h
  exact not_mem_of_world_nextWorld hxw hx

/-- The converse of `mem_of_branch_contains`. -/
theorem contains_of_mem {b : Branch} {x : SignedFormula} (h : x ∈ b) : b.contains x = true := by
  simp only [Branch.contains, List.any_eq_true]
  exact ⟨x, h, beq_self_eq_true x⟩

/-- A branch formula's world is a known world, in list form. -/
theorem mem_knownWorlds_of_mem {b : Branch} {x : SignedFormula} (h : x ∈ b) :
    x.label.world ∈ b.knownWorlds :=
  List.mem_eraseDups.mpr (List.mem_map_of_mem h)

/-- **A step that introduces no world keeps the discipline**, with the same witness function.
This is the case of 34 of the 36 rules. -/
theorem worldWitnessKnown_of_no_new_world {C : Finset Formula} {S : Finset WorldIndex}
    {b nb : Branch} (hww : WorldWitnessKnown C S b) (hsub : ∀ x ∈ b, x ∈ nb)
    (hworlds : ∀ x ∈ nb, x.label.world ∈ b.worldFinset) : WorldWitnessKnown C S nb := by
  obtain ⟨wit, hwit, hinj⟩ := hww
  have key : ∀ w ∈ nb.worldFinset, w ∈ b.worldFinset := by
    intro w hw
    obtain ⟨x, hx, rfl⟩ := exists_mem_of_mem_worldFinset hw
    exact hworlds x hx
  refine ⟨wit, ?_, ?_⟩
  · intro w hw hs
    obtain ⟨hm, hl, hc⟩ := hwit w (key w hw) hs
    exact ⟨hsub _ hm, hl, hc⟩
  · intro w₁ h1 hs1 w₂ h2 hs2 heq
    exact hinj w₁ (key w₁ h1) hs1 w₂ (key w₂ h2) hs2 heq

/-- **A step that mints exactly one world keeps the discipline**, provided the minted world's own
witness carries a signature no branch formula carries.

That last hypothesis is the whole content of the invariant, and it is exactly what the engine's
`witnessPresent` guard supplies at a fresh-world rule: had any branch formula carried the same
sign, formula and time, the guard would have reported a witness and the rule would not have
fired. The new witness function is the old one updated at the minted world. -/
theorem worldWitnessKnown_mint {C : Finset Formula} {S : Finset WorldIndex}
    {b nb : Branch} {w₀ : WorldIndex} {x₀ : SignedFormula}
    (hww : WorldWitnessKnown C S b) (hsub : ∀ x ∈ b, x ∈ nb)
    (hworlds : ∀ x ∈ nb, x.label.world ∈ b.worldFinset ∨ x.label.world = w₀)
    (hfresh : w₀ ∉ b.worldFinset)
    (hx₀ : x₀ ∈ nb) (hx₀w : x₀.label.world = w₀) (hx₀C : x₀.formula ∈ C)
    (hsig : ∀ y ∈ b, witnessSig y ≠ witnessSig x₀) : WorldWitnessKnown C S nb := by
  classical
  obtain ⟨wit, hwit, hinj⟩ := hww
  refine ⟨Function.update wit w₀ x₀, ?_, ?_⟩
  · intro w hw hs
    by_cases hw0 : w = w₀
    · subst hw0
      simpa [Function.update_self] using ⟨hx₀, hx₀w, hx₀C⟩
    · obtain ⟨x, hx, rfl⟩ := exists_mem_of_mem_worldFinset hw
      have hb : x.label.world ∈ b.worldFinset := (hworlds x hx).resolve_right hw0
      obtain ⟨hm, hl, hc⟩ := hwit _ hb hs
      simpa [Function.update_of_ne hw0] using ⟨hsub _ hm, hl, hc⟩
  · intro w₁ h1 hs1 w₂ h2 hs2 heq
    have hb : ∀ w ∈ nb.worldFinset, w ≠ w₀ → w ∈ b.worldFinset := by
      intro w hw hne
      obtain ⟨x, hx, rfl⟩ := exists_mem_of_mem_worldFinset hw
      exact (hworlds x hx).resolve_right hne
    by_cases e1 : w₁ = w₀ <;> by_cases e2 : w₂ = w₀
    · rw [e1, e2]
    · exfalso
      subst e1
      rw [Function.update_self, Function.update_of_ne e2] at heq
      exact hsig _ (hwit _ (hb _ h2 e2) hs2).1 heq.symm
    · exfalso
      subst e2
      rw [Function.update_self, Function.update_of_ne e1] at heq
      exact hsig _ (hwit _ (hb _ h1 e1) hs1).1 heq
    · rw [Function.update_of_ne e1, Function.update_of_ne e2] at heq
      exact hinj _ (hb _ h1 e1) hs1 _ (hb _ h2 e2) hs2 heq

/-! ### The guard, read as a statement about witness signatures -/

/-- **`boxNeg`'s guard, in signature form.** `witnessPresent .boxNeg` scans `knownWorlds` for the
rule's conclusion at the trigger's own time; the scan is world-indifferent, so its failure says
precisely that no branch formula shares the minted witness's signature. -/
theorem boxNeg_guard_sig {sf : SignedFormula} {ψ : Formula} {b : Branch} {ord : TimeOrdering}
    (hf : sf.formula = Formula.box ψ) (hs : sf.sign = Sign.neg)
    (hguard : witnessPresent .boxNeg sf b ord = false) :
    ∀ y ∈ b, witnessSig y
      ≠ witnessSig (SignedFormula.neg ψ { world := b.nextWorld, time := sf.label.time }) := by
  cases sf with
  | mk sign formula label =>
    simp only at hf hs
    subst hf; subst hs
    simp only [witnessPresent] at hguard
    intro y hy heq
    have h1 : y.sign = Sign.neg := congrArg SignedFormula.sign heq
    have h2 : y.formula = ψ := congrArg SignedFormula.formula heq
    have h3 : y.label.time = label.time := congrArg (fun z => z.label.time) heq
    have hy' : y = SignedFormula.neg ψ { world := y.label.world, time := label.time } := by
      obtain ⟨ys, yf, yl⟩ := y
      obtain ⟨yw, yt⟩ := yl
      simp_all [SignedFormula.neg]
    have hcontains : b.contains
        (SignedFormula.neg ψ { world := y.label.world, time := label.time }) = true := by
      rw [← hy']; exact contains_of_mem hy
    have hany : (b.knownWorlds.any fun w =>
        b.contains (SignedFormula.neg ψ { world := w, time := label.time })) = true :=
      List.any_eq_true.mpr ⟨y.label.world, mem_knownWorlds_of_mem hy, hcontains⟩
    rw [hany] at hguard
    exact Bool.noConfusion hguard

/-- The `diamondPos` mirror of `boxNeg_guard_sig`. -/
theorem diamondPos_guard_sig {sf : SignedFormula} {ψ : Formula} {b : Branch} {ord : TimeOrdering}
    (hf : asDiamond? sf.formula = some ψ) (hs : sf.sign = Sign.pos)
    (hguard : witnessPresent .diamondPos sf b ord = false) :
    ∀ y ∈ b, witnessSig y
      ≠ witnessSig (SignedFormula.pos ψ { world := b.nextWorld, time := sf.label.time }) := by
  cases sf with
  | mk sign formula label =>
    simp only at hf hs
    subst hs
    simp only [witnessPresent, hf] at hguard
    intro y hy heq
    have h1 : y.sign = Sign.pos := congrArg SignedFormula.sign heq
    have h2 : y.formula = ψ := congrArg SignedFormula.formula heq
    have h3 : y.label.time = label.time := congrArg (fun z => z.label.time) heq
    have hy' : y = SignedFormula.pos ψ { world := y.label.world, time := label.time } := by
      obtain ⟨ys, yf, yl⟩ := y
      obtain ⟨yw, yt⟩ := yl
      simp_all [SignedFormula.pos]
    have hcontains : b.contains
        (SignedFormula.pos ψ { world := y.label.world, time := label.time }) = true := by
      rw [← hy']; exact contains_of_mem hy
    have hany : (b.knownWorlds.any fun w =>
        b.contains (SignedFormula.pos ψ { world := w, time := label.time })) = true :=
      List.any_eq_true.mpr ⟨y.label.world, mem_knownWorlds_of_mem hy, hcontains⟩
    rw [hany] at hguard
    exact Bool.noConfusion hguard

/-- Every successor branch a rule result reports extends the branch, and everything on it is
either emitted by the rule or was already there. Stated once for the two per-shape selectors
`nonBranchingResultBranch` and `branchingResultBranches` that `pickBranches` is assembled from. -/
theorem resultBranch_sub {b nb : Branch} {res : RuleResult}
    (h : nb ∈ (nonBranchingResultBranch b res).toList ++ branchingResultBranches b res) :
    (∀ x ∈ b, x ∈ nb) ∧ (∀ x ∈ nb, x ∈ res.emitted ∨ x ∈ b) := by
  cases res with
  | linear fs =>
    simp only [nonBranchingResultBranch, branchingResultBranches, Option.toList, 
      List.mem_cons, List.not_mem_nil, or_false, List.append_nil] at h
    subst h
    exact ⟨fun x hx => List.mem_append_right _ hx,
      fun x hx => (List.mem_append.mp hx).imp id id⟩
  | persistent fs =>
    simp only [nonBranchingResultBranch, branchingResultBranches, Option.toList, 
      List.mem_cons, List.not_mem_nil, or_false, List.append_nil] at h
    subst h
    exact ⟨fun x hx => List.mem_append_right _ hx,
      fun x hx => (List.mem_append.mp hx).imp id id⟩
  | branching bss =>
    simp only [nonBranchingResultBranch, branchingResultBranches, Option.toList, List.nil_append,
      List.mem_map] at h
    obtain ⟨fs, hfs, rfl⟩ := h
    exact ⟨fun x hx => List.mem_append_right _ hx,
      fun x hx => (List.mem_append.mp hx).imp
        (fun hh => List.mem_flatten.mpr ⟨fs, hfs, hh⟩) id⟩
  | branchingOrdered bs =>
    simp only [nonBranchingResultBranch, branchingResultBranches, Option.toList, List.nil_append,
      List.not_mem_nil] at h
  | notApplicable =>
    simp only [nonBranchingResultBranch, branchingResultBranches, Option.toList, List.nil_append,
      List.not_mem_nil] at h

set_option maxHeartbeats 1000000 in
-- The proof reduces `applyRule` at the rule under analysis, stepping past the earlier arms of its
-- 36-constructor match; that `whnf` work is past the default heartbeat budget.
/-- **One rule application preserves the strengthened fresh-world discipline**, at every successor
branch the result reports.

Three cases, and only the first two have any content. For 34 of the 36 rules
`applyRule_emitted_world_mem` says no world is introduced, so the witness function carries over
untouched. For `boxNeg` and `diamondPos` either no world was introduced — same argument — or
`Branch.nextWorld` appears, in which case the trigger had the rule's own shape
(`applyRule_boxNeg_shape`), the result is `.linear` (`applyRule_boxNeg_eq`), the rule's own
witness is on the successor (`applyRule_boxNeg_witness`), its formula is in the stock by
subformula closure, and its signature is unmatched on the branch by the guard
(`boxNeg_guard_sig`).

`hguard` is demanded only at the two minting rules, which is the only place it is available:
`findApplicableRule` tests `witnessPresent` exactly at the eight `ruleMintsFreshLabel` rules. -/
theorem applyRule_worldWitnessKnown {C : Finset Formula} {S : Finset WorldIndex}
    {rule : TableauRule} {sf : SignedFormula} {b : Branch} {ord : TimeOrdering}
    (hC : TableauClosed C) (hstock : ∀ x ∈ b, x.formula ∈ C) (hsf : sf ∈ b)
    (hguard : rule = .boxNeg ∨ rule = .diamondPos → witnessPresent rule sf b ord = false)
    (hww : WorldWitnessKnown C S b) :
    ∀ nb ∈ (nonBranchingResultBranch b (applyRule rule sf b ord).1).toList
             ++ branchingResultBranches b (applyRule rule sf b ord).1,
      WorldWitnessKnown C S nb := by
  intro nb hnb
  obtain ⟨hsub, hmem⟩ := resultBranch_sub hnb
  by_cases hbn : rule = .boxNeg
  · subst hbn
    by_cases hnew : b.nextWorld ∈ nb.worldFinset
    · obtain ⟨x, hx, hxw⟩ := exists_mem_of_mem_worldFinset hnew
      have hxe : x ∈ (applyRule .boxNeg sf b ord).1.emitted := by
        rcases hmem x hx with h | h
        · exact h
        · exact absurd (hxw ▸ Branch.mem_worldFinset h) (nextWorld_not_mem_worldFinset b)
      obtain ⟨ψ, hf, hs⟩ := applyRule_boxNeg_shape hxe
      obtain ⟨fs, hres⟩ := applyRule_boxNeg_eq (b := b) (ord := ord) hf hs
      have hnbeq : nb = fs ++ b := by
        rw [hres] at hnb
        simpa [nonBranchingResultBranch, branchingResultBranches] using hnb
      have hWfs : SignedFormula.neg ψ { world := b.nextWorld, time := sf.label.time } ∈ fs := by
        have hW := applyRule_boxNeg_witness (b := b) (ord := ord) hf hs
        rwa [hres, RuleResult.emitted_linear] at hW
      refine worldWitnessKnown_mint hww hsub ?_ (nextWorld_not_mem_worldFinset b)
        (hnbeq ▸ List.mem_append_left _ hWfs) rfl
        (hC.box_inner (hf ▸ hstock sf hsf)) (boxNeg_guard_sig hf hs (hguard (Or.inl rfl)))
      intro y hy
      rcases hmem y hy with h | h
      · exact Or.inr (applyRule_boxNeg_emitted_world y h)
      · exact Or.inl (Branch.mem_worldFinset h)
    · refine worldWitnessKnown_of_no_new_world hww hsub ?_
      intro y hy
      rcases hmem y hy with h | h
      · exact absurd (applyRule_boxNeg_emitted_world y h ▸ Branch.mem_worldFinset hy) hnew
      · exact Branch.mem_worldFinset h
  · by_cases hdp : rule = .diamondPos
    · subst hdp
      by_cases hnew : b.nextWorld ∈ nb.worldFinset
      · obtain ⟨x, hx, hxw⟩ := exists_mem_of_mem_worldFinset hnew
        have hxe : x ∈ (applyRule .diamondPos sf b ord).1.emitted := by
          rcases hmem x hx with h | h
          · exact h
          · exact absurd (hxw ▸ Branch.mem_worldFinset h) (nextWorld_not_mem_worldFinset b)
        obtain ⟨ψ, hf, hs⟩ := applyRule_diamondPos_shape hxe
        obtain ⟨fs, hres⟩ := applyRule_diamondPos_eq (b := b) (ord := ord) hf hs
        have hnbeq : nb = fs ++ b := by
          rw [hres] at hnb
          simpa [nonBranchingResultBranch, branchingResultBranches] using hnb
        have hWfs : SignedFormula.pos ψ { world := b.nextWorld, time := sf.label.time } ∈ fs := by
          have hW := applyRule_diamondPos_witness (b := b) (ord := ord) hf hs
          rwa [hres, RuleResult.emitted_linear] at hW
        refine worldWitnessKnown_mint hww hsub ?_ (nextWorld_not_mem_worldFinset b)
          (hnbeq ▸ List.mem_append_left _ hWfs) rfl
          (hC.diamond_inner (asDiamond?_eq_iff.mp hf ▸ hstock sf hsf))
          (diamondPos_guard_sig hf hs (hguard (Or.inr rfl)))
        intro y hy
        rcases hmem y hy with h | h
        · exact Or.inr (applyRule_diamondPos_emitted_world y h)
        · exact Or.inl (Branch.mem_worldFinset h)
      · refine worldWitnessKnown_of_no_new_world hww hsub ?_
        intro y hy
        rcases hmem y hy with h | h
        · exact absurd (applyRule_diamondPos_emitted_world y h ▸ Branch.mem_worldFinset hy) hnew
        · exact Branch.mem_worldFinset h
    · refine worldWitnessKnown_of_no_new_world hww hsub ?_
      intro y hy
      rcases hmem y hy with h | h
      · exact applyRule_emitted_world_mem hsf hbn hdp y h
      · exact Branch.mem_worldFinset h


/-! ### The guard, extracted from the pick

`witnessPresent` is tested by `findApplicableRule` **only** at the eight `ruleMintsFreshLabel`
rules, and only in its `.linear` and `.branching` arms. Both world-minting rules live there —
`applyRule_boxNeg_result` and `applyRule_diamondPos_result` rule out the two unguarded arms — so
the guard is recoverable exactly where the fresh-world discipline needs it. The seriality and
linearity stages need no guard at all: they run one rule each, and neither is world-minting. -/

set_option maxHeartbeats 1000000 in
-- `repeat' split` case-splits every arm of the 36-constructor `applyRule` match; elaborating
-- all of them is past the default heartbeat budget.
/-- **The ordinary-rule pick carries its own guard, at the two world-minting rules.** -/
theorem findApplicableRule_guard_mint {sf : SignedFormula} {b : Branch} {ord : TimeOrdering}
    {fc : FormalSystem.ProofSystem.FrameClass}
    {r : TableauRule} {res : RuleResult} {o : TimeOrdering}
    (h : findApplicableRule sf b ord fc = some (r, res, o))
    (hm : r = .boxNeg ∨ r = .diamondPos) :
    witnessPresent r sf b ord = false := by
  unfold findApplicableRule at h
  obtain ⟨rule, -, hr⟩ := List.exists_of_findSome?_eq_some h
  rcases hm with rfl | rfl <;>
    (repeat' split at hr) <;>
    simp_all [ruleMintsFreshLabel]
  all_goals first
    | (rcases applyRule_boxNeg_result sf b ord with h' | ⟨fs', h'⟩ <;> simp_all)
    | (rcases applyRule_diamondPos_result sf b ord with h' | ⟨fs', h'⟩ <;> simp_all)

/-- The seriality stage runs exactly one rule. -/
theorem findApplicableSerialRule_rule {sf : SignedFormula} {b : Branch} {ord : TimeOrdering}
    {r : TableauRule} {res : RuleResult} {o : TimeOrdering}
    (h : findApplicableSerialRule sf b ord = some (r, res, o)) :
    r = TableauRule.serialityRule := by
  unfold findApplicableSerialRule serialityRules at h
  simp only [List.findSome?_cons, List.findSome?_nil] at h
  rcases hA : applyRule TableauRule.serialityRule sf b ord with ⟨res', o'⟩
  rw [hA] at h
  simp only at h
  cases res' <;> simp_all

/-- The linearity stage runs exactly one rule. -/
theorem findApplicableLinearityRule_rule {sf : SignedFormula} {b : Branch} {ord : TimeOrdering}
    {r : TableauRule} {res : RuleResult} {o : TimeOrdering}
    (h : findApplicableLinearityRule sf b ord = some (r, res, o)) :
    r = TableauRule.timeLinearity := by
  unfold findApplicableLinearityRule linearityRules at h
  simp only [List.findSome?_cons, List.findSome?_nil] at h
  rcases hA : applyRule TableauRule.timeLinearity sf b ord with ⟨res', o'⟩
  rw [hA] at h
  simp only at h
  cases res' <;> simp_all

/-- **`pick_stage_source` with the fresh-world guard attached.** The three stages differ only in
how the guard arrives: stage one has it from `findApplicableRule_guard_mint`, stages two and
three by the rule they run not being a world-minting rule at all. -/
private theorem pick_stage_source_guarded (b : Branch) (ord : TimeOrdering)
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
        (r = .boxNeg ∨ r = .diamondPos → witnessPresent r sf b ord = false) := by
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
        intro hm
        have hr := findApplicableLinearityRule_rule h
        rcases hm with rfl | rfl <;> exact absurd hr (by simp)
    · rw [hser] at h
      simp only at h
      refine ⟨sf2, List.mem_of_find?_eq_some hser,
        findApplicableSerialRule_applyRule_pair h, ?_⟩
      intro hm
      have hr := findApplicableSerialRule_rule h
      rcases hm with rfl | rfl <;> exact absurd hr (by simp)
  · rw [hpick] at h
    simp only at h
    have hmem : sf ∈ b := by
      unfold findUnexpandedUnblockedWith at hpick
      exact List.mem_of_find?_eq_some hpick
    exact ⟨sf, hmem, findApplicableRule_applyRule_pair h,
      fun hm => findApplicableRule_guard_mint h hm⟩

/-- One pick stage preserves the strengthened fresh-world discipline at every successor branch it
reports. The join of the `applyRule`-level lemma with the guarded source. -/
private theorem pickBranches_worldWitnessKnown {C : Finset Formula} {S : Finset WorldIndex}
    {b : Branch} {ord : TimeOrdering} {p : Option (TableauRule × RuleResult × TimeOrdering)}
    (hC : TableauClosed C) (hstock : ∀ x ∈ b, x.formula ∈ C)
    (hww : WorldWitnessKnown C S b)
    (hp : ∀ r res o, p = some (r, res, o) → ∃ sf, sf ∈ b ∧ applyRule r sf b ord = (res, o) ∧
      (r = .boxNeg ∨ r = .diamondPos → witnessPresent r sf b ord = false)) :
    ∀ nb ∈ pickBranches b p, WorldWitnessKnown C S nb := by
  rcases p with _ | ⟨r, res, o⟩
  · simp [pickBranches]
  · obtain ⟨sf, hsf, hA, hg⟩ := hp r res o rfl
    have h1 := applyRule_worldWitnessKnown (rule := r) (sf := sf) (b := b) (ord := ord)
      hC hstock hsf hg hww
    rw [hA] at h1
    intro nb hnb
    simp only [pickBranches] at hnb
    exact h1 nb hnb

/-- **Engine-level preservation of the strengthened fresh-world discipline**, at `.extended` and
at every arm of a `.split`.

`.saturated` contributes no successor. `.splitOrdered` is **deliberately not covered**, and the
reason is a real limitation rather than an omission — see the note below. It is also not needed:
`ExtendStep`, which is what every run this feeds is built from, is `.extended`-only. -/
theorem expandOnceUnblocked_worldWitnessKnown {C : Finset Formula} {S : Finset WorldIndex}
    {b : Branch} {ord : TimeOrdering}
    {fc : FormalSystem.ProofSystem.FrameClass} {tr : EventualityTracker}
    (hC : TableauClosed C) (hstock : ∀ x ∈ b, x.formula ∈ C)
    (hww : WorldWitnessKnown C S b) :
    ∀ nb ∈ unorderedSuccessorBranches (expandOnceUnblocked b ord fc tr).1,
      WorldWitnessKnown C S nb := by
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
  exact pickBranches_worldWitnessKnown hC hstock hww (pick_stage_source_guarded b ord fc tr)

/-! ### Why the ordered split is excluded, stated rather than glossed

The identification arm relabels every branch formula by `rho`, and `rho` **merges** two times.
Two non-seed worlds whose witnesses differ only in carrying the merged pair of times have
*distinct* signatures before the arm and the *same* signature after it, so the injectivity clause
of `WorldWitnessKnown` is not transported along `rhoSF`. That is a genuine failure of the
invariant at arm 3, of exactly the kind `ordTimes_identifyTime_arm3_false` records for the
ordering-times invariant — not a gap in this proof.

It costs nothing here. `ExtendStep` (`Fuel.lean`) is defined as
`(expandOnceUnblocked b ord fc tr).1 = .extended nb`, so every run that `chain_le_worlds_bounded`
and `chain_le_worldFuel'` quantify over is `.extended`-only: no split of either kind occurs along
it, and `expandOnceUnblocked_worldWitnessKnown` covers every step such a run can take. A consumer
that needs the discipline **across** an ordered split would need a repair of the same shape as
`OrdTimesKnown`, and does not have one. -/

/-- **The strengthened discipline at the engine's seed.** Every world of the seed lies in `S`, so
both clauses hold by absence of a non-seed world — the same reason `worldWitness_seedBranch`
holds, and not by any weakening. -/
theorem worldWitnessKnown_seedBranch (C : Finset Formula) (φ : Formula) :
    WorldWitnessKnown C (seedBranch φ).worldFinset (seedBranch φ) := by
  refine ⟨fun _ => ⟨Sign.pos, .bot, { world := 0, time := 0 }⟩, ?_, ?_⟩
  · intro w hw hns; exact absurd hw hns
  · intro w₁ hw₁ hns₁ _ _ _ _; exact absurd hw₁ hns₁

/-- **The run-level discharge — `WorldWitnessKnown` is an invariant of an `ExtendStep` chain.**

Base case: the hypothesis at step 0. Step case: `expandOnceUnblocked_worldWitnessKnown`, with the
stock hypothesis supplied at each intermediate branch by `branchStock_chain` (T1). This is the
induction the world bound needed and did not have. -/
theorem worldWitnessKnown_chain {C : Finset Formula} {S : Finset WorldIndex}
    (hC : TableauClosed C) (hT : TrichStock C) (run : Nat → Branch) (n : Nat)
    (h0 : BranchStock C (run 0))
    (hstep : ∀ i < n, ExtendStep (run i) (run (i + 1)))
    (hww : WorldWitnessKnown C S (run 0)) : WorldWitnessKnown C S (run n) := by
  induction n with
  | zero => exact hww
  | succ n ih =>
      have hstep' : ∀ i < n, ExtendStep (run i) (run (i + 1)) := fun i hi => hstep i (by omega)
      have hprev := ih hstep'
      have hstock := (branchStock_chain hC hT run n h0 hstep').mem
      obtain ⟨ord, fc, tr, hs⟩ := hstep n (by omega)
      refine expandOnceUnblocked_worldWitnessKnown (ord := ord) (fc := fc) (tr := tr)
        hC hstock hprev (run (n + 1)) ?_
      rw [hs]
      simp [unorderedSuccessorBranches]

/-- **The weak form at every step of a seed run — the residual `chain_le_worldFuel'` names is
gone.** `WorldWitness C S (run n)` is now a theorem about runs out of the engine's own seed
rather than a hypothesis a caller must supply. -/
theorem worldWitness_chain_of_seed {C : Finset Formula} {φ : Formula}
    (hC : TableauClosed C) (hT : TrichStock C) (run : Nat → Branch) (n : Nat)
    (h0 : BranchStock C (run 0)) (hseed : run 0 = seedBranch φ)
    (hstep : ∀ i < n, ExtendStep (run i) (run (i + 1))) :
    WorldWitness C (seedBranch φ).worldFinset (run n) :=
  worldWitness_of_known
    (worldWitnessKnown_chain hC hT run n h0 hstep (hseed ▸ worldWitnessKnown_seedBranch C φ))

/-- **The label bound along a seed run, with no `WorldWitness` hypothesis left.**

This is `labelFinset_card_le_at_seed_worlds` with its one carried input discharged: the fresh-world
discipline is supplied by `worldWitness_chain_of_seed` rather than assumed, and `s = 1` by
`seedWorlds_card`. -/
theorem labelFinset_card_le_of_seed_run {C : Finset Formula} {φ : Formula}
    (hC : TableauClosed C) (hT : TrichStock C) (run : Nat → Branch) (n : Nat)
    (h0 : BranchStock C (run 0)) (hseed : run 0 = seedBranch φ)
    (hstep : ∀ i < n, ExtendStep (run i) (run (i + 1)))
    (htime : (run n).timeFinset.card ≤ 2 ^ (2 * C.card)) :
    (run n).labelFinset.card ≤ (1 + 2 * C.card * 2 ^ (2 * C.card)) * 2 ^ (2 * C.card) :=
  labelFinset_card_le_at_seed_worlds (worldWitness_chain_of_seed hC hT run n h0 hseed hstep) htime

/-- **T3's step bound for a seed run, with the fresh-world discipline discharged.**

`chain_le_worldFuel'` carries `hww : WorldWitness C S (run n)` as an undischarged invariant. Out
of the engine's own seed it is no longer undischarged: `worldWitness_chain_of_seed` proves it, and
`seedWorlds_card` fixes `S.card = 1`, so the figure is `worldFuel' φ 1`. -/
theorem chain_le_worldFuel'_of_seed {C : Finset Formula} {φ : Formula}
    {ord : TimeOrdering} {tracker : EventualityTracker}
    (hC : TableauClosed C) (hT : TrichStock C)
    (run : Nat → Branch) (n : Nat)
    (h0 : BranchStock C (run 0)) (hseed : run 0 = seedBranch φ)
    (hstep : ∀ i < n, ExtendStep (run i) (run (i + 1)))
    (hlin : firstIncomparablePair (run n) ord = none)
    (hev : ∀ t₁ ∈ (run n).knownTimes, ∀ t₂ ∈ (run n).knownTimes,
      allEventualitiesFulfilledOrDuplicated tracker t₁ t₂ = true)
    (hnb : findBlockedTime (run n) ord tracker = none)
    (hφ : C.card = (FormalSystem.Syntax.subformulaClosure φ).card) :
    n ≤ worldFuel' φ 1 := by
  have h := chain_le_worldFuel' (S := (seedBranch φ).worldFinset) (ord := ord) (tracker := tracker)
    hC hT run n h0 hstep hlin hev hnb
    (worldWitness_chain_of_seed hC hT run n h0 hseed hstep) hφ
  rwa [seedWorlds_card] at h

/-! ## C3. The mint potential

The count of `(rule, signed formula)` pairs still eligible to mint. Witness preservation makes it
non-increasing along a run, and a mint makes it strictly decrease, which is what turns "each pair
mints at most once" into a *per-state* quantity a fuel induction can carry.

### The carried renaming is not decoration — read this before simplifying it away

The obvious measure filters `freshLabelRules ×ˢ U` by `witnessPresent r sf b ord = false` at the
current state. **That measure is not available at the ordered split's identification arm**, and the
reason is the same non-injectivity that `ordTimes_identifyTime_arm3_false` exhibits for the
ordering-times invariant. `rhoSF t₂ t₁` merges `t₂` into `t₁`, so it is not injective on `U`, and a
counting argument at arm 3 would need an injection from the after-false set into the before-false
set. The map that suggests itself is not one: after the arm the branch carries **nothing** at `t₂`,
so every pair whose formula sits at `t₂` reports no witness at the successor, while a pair at `t₂`
whose witness also sat at `t₂` reported one before — a local *increase*, with no partner to absorb
it. Whether the simultaneous decreases at `t₁` dominate is not decided here in either direction.

`mintPotential` therefore carries the accumulated renaming `σ` as an explicit parameter and
filters on `witnessPresent r (σ sf) b ord = false`. The index set `freshLabelRules ×ˢ U` is then
**fixed for the whole run**, so successive potentials are cardinalities of subsets of one finset
and compare directly, and each of the two step shapes is a pointwise *subset* fact needing no
injection:

* an ordinary step keeps `σ` and grows branch and ordering — `mintPotential_le_of_grow`, from the
  two `witnessPresent` monotonicity lemmas;
* arm 3 post-composes `rhoSF t₂ t₁` onto `σ` — `mintPotential_identifyTime`, from
  `arm3_preserves_witness` read contrapositively.

Post-composition is what makes the measure compose along a run carrying **any number** of
identifications, rather than only the first one: `σ` is a parameter of the measure, not a fixed
choice inside it. `mints_le_eight_mul` is that composition, in the form the counting consumes.
Instantiating `σ := id` recovers the intrinsic measure at any prefix of the run before the first
ordered split, so nothing is lost relative to the simpler shape where the simpler shape works.

### The residual, named rather than absorbed

`mintPotential_lt_of_mint` — the strict decrease — asks that the minting pair be **`σ`-hit**: the
formula the rule fires on must be `σ sf` for some `sf ∈ U`. `σ`'s image omits exactly the times
earlier identifications merged away, so the obligation is precisely that a minting formula does
not sit at a merged-away time. That is a question about **time reuse**, not about the measure:
`Branch.nextTime` is `Branch.maxTime + 1` and `Branch.identifyTime` can *lower* `Branch.maxTime`
(the configuration `ordTimes_identifyTime_arm3_false` decides drops it from `5` to `0`), so a
fresh time can in principle re-issue a value an earlier identification removed. The equivalent
"live times" reformulation of the potential — filter additionally on the formula's time being a
fixed point of `σ` — carries the identical obligation, which is what shows it is intrinsic to the
situation rather than an artifact of this measure's shape. Discharging it is the first obligation
of the once-only bound, and it is stated in `mintPotential_lt_of_mint`'s hypotheses rather than
assumed anywhere.

### Why the three-component impossibility does not apply

The measured obstruction recorded against the split-aware fuel figure rules out the *linear
three-component family* `Ψ = A · (|U| − |b|) + B · |knownTimes| + C · |incompPairs|`: no choice of
the three coefficients decreases on every arm, because the identification arm moves the second and
third components in opposite directions from the first. `mintPotential` is a **fourth component
outside that family** — it mentions neither `b.toFinset.card`, nor `Branch.knownTimes`, nor the
incomparable-pair count, and it is not a linear combination of them. It is a count over a fixed
index set of *witness tests*, and it is bounded by `8 * U.card` outright. The impossibility is
therefore not evidence against this measure; it is evidence against the family this measure is
not in.

### The time bound is not circular

`|U| = |signedUniverse C L|` grows with the times, and the times grow by minting, so a `Tmax`
derived from the mint count would make the chain circular. It is not derived that way:
`timeFinset_card_le_of_mem_stock` above bounds `Branch.timeFinset.card` by `2 ^ (2 * |C|)` from
branch-confined-to-stock, linearity-saturated, eventuality-fulfilled and blocking-silent. **Not
one of those four hypotheses mentions a world, a mint, or `|U|`.** The mint chain may rest on it. -/

/-- **The eight rules that mint a fresh label**, as a `Finset`, so the potential's index set is a
product. The list is exactly `ruleMintsFreshLabel`'s `true` arms — `mem_freshLabelRules` proves the
agreement rather than asserting it, so the two can never drift apart silently. -/
def freshLabelRules : Finset TableauRule :=
  {TableauRule.boxNeg, TableauRule.diamondPos, TableauRule.allFutureNeg, TableauRule.allPastNeg,
   TableauRule.someFuturePos, TableauRule.somePastPos, TableauRule.untlPos, TableauRule.sncePos}

/-- There are exactly eight, decided rather than counted by hand. -/
theorem freshLabelRules_card : freshLabelRules.card = 8 := by decide

/-- The `Finset` and the `Bool` predicate agree, over all thirty-six constructors. -/
theorem mem_freshLabelRules {r : TableauRule} :
    r ∈ freshLabelRules ↔ ruleMintsFreshLabel r = true := by
  cases r <;> simp [freshLabelRules, ruleMintsFreshLabel]

/-- **The mint potential**: the number of `(rule, formula)` pairs drawn from the fixed index set
`freshLabelRules ×ˢ U` that report **no** witness at the current state, with the formula carried
through the accumulated renaming `σ`.

`σ` is the composition of the `rhoSF`s of the ordered splits taken so far; it is `id` before the
first one. Carrying it keeps the index set fixed across the whole run — see the section note above
for why the `σ`-free form is not available at the identification arm. -/
def mintPotential (U : Finset SignedFormula) (σ : SignedFormula → SignedFormula)
    (b : Branch) (ord : TimeOrdering) : Nat :=
  ((freshLabelRules ×ˢ U).filter (fun p => witnessPresent p.1 (σ p.2) b ord = false)).card

/-- **`mintPotential ≤ 8 · |U|`**, immediately, for every state and every renaming: the filter
cannot exceed its index set, and the index set is a product with an eight-element left factor. This
is the ceiling the once-only bound reads off. -/
theorem mintPotential_le_eight_mul (U : Finset SignedFormula)
    (σ : SignedFormula → SignedFormula) (b : Branch) (ord : TimeOrdering) :
    mintPotential U σ b ord ≤ 8 * U.card := by
  refine le_trans (Finset.card_filter_le _ _) ?_
  rw [Finset.card_product, freshLabelRules_card]

/-- **An ordinary step does not increase the potential.** The branch grows and the ordering grows,
so `witnessPresent` can only turn on; contrapositively the after-false set is a *subset* of the
before-false set inside the same index set, and no injection is needed. Covers `.extended`,
`.split`, and the ordered split's first two arms, all of which keep `σ`. -/
theorem mintPotential_le_of_grow {U : Finset SignedFormula} {σ : SignedFormula → SignedFormula}
    {b b' : Branch} {ord ord' : TimeOrdering}
    (hb : ∀ x ∈ b, x ∈ b') (hord : ∀ q ∈ ord.constraints, q ∈ ord'.constraints) :
    mintPotential U σ b' ord' ≤ mintPotential U σ b ord := by
  refine Finset.card_le_card ?_
  intro p hp
  simp only [Finset.mem_filter] at hp ⊢
  refine ⟨hp.1, ?_⟩
  rcases hw : witnessPresent p.1 (σ p.2) b ord with _ | _
  · rfl
  · rw [witnessPresent_branch_mono hb (witnessPresent_ord_mono hord hw)] at hp
    exact absurd hp.2 (by simp)

/-- **The identification arm does not increase the potential either** — the central obligation of
this block, and the one the plain measure cannot meet.

The successor is measured at `rhoSF t₂ t₁ ∘ σ` rather than at `σ`, which is exactly the renaming
the arm performs, and the proof is again a pointwise subset fact: the contrapositive of
`arm3_preserves_witness`. No injection from the after-false set into the before-false set is
required, and none is available — `rhoSF t₂ t₁` is not injective on `U`.

Because the renaming is *post-composed* onto the parameter, this lemma applies unchanged at a
second, third, or `n`-th identification along the same run. -/
theorem mintPotential_identifyTime {U : Finset SignedFormula} {σ : SignedFormula → SignedFormula}
    {b : Branch} {ord : TimeOrdering} {t₁ t₂ : TimeIndex}
    (htrig : firstIncomparablePair b ord = some (t₁, t₂)) (hirr : IrreflOrd ord) :
    mintPotential U (fun x => rhoSF t₂ t₁ (σ x)) (b.identifyTime t₂ t₁) (ord.identifyTime t₂ t₁)
      ≤ mintPotential U σ b ord := by
  refine Finset.card_le_card ?_
  intro p hp
  simp only [Finset.mem_filter] at hp ⊢
  refine ⟨hp.1, ?_⟩
  rcases hw : witnessPresent p.1 (σ p.2) b ord with _ | _
  · rfl
  · rw [arm3_preserves_witness htrig hirr p.1 (σ p.2) hw] at hp
    exact absurd hp.2 (by simp)

/-- **The identification arm does not increase the potential, at the engine's own orientation.**
`mintPotential_identifyTime` read at `(min t₁ t₂, max t₁ t₂)`, which is the merge arm 3 actually
performs. Same proof, one lemma deeper: the contrapositive of `arm3_preserves_witness_oriented`. -/
theorem mintPotential_identifyTime_oriented {U : Finset SignedFormula}
    {σ : SignedFormula → SignedFormula} {b : Branch} {ord : TimeOrdering} {t₁ t₂ : TimeIndex}
    (htrig : firstIncomparablePair b ord = some (t₁, t₂)) (hirr : IrreflOrd ord) :
    mintPotential U (fun x => rhoSF (min t₁ t₂) (max t₁ t₂) (σ x))
        (b.identifyTime (min t₁ t₂) (max t₁ t₂)) (ord.identifyTime (min t₁ t₂) (max t₁ t₂))
      ≤ mintPotential U σ b ord := by
  refine Finset.card_le_card ?_
  intro p hp
  simp only [Finset.mem_filter] at hp ⊢
  refine ⟨hp.1, ?_⟩
  rcases hw : witnessPresent p.1 (σ p.2) b ord with _ | _
  · rfl
  · rw [arm3_preserves_witness_oriented htrig hirr p.1 (σ p.2) hw] at hp
    exact absurd hp.2 (by simp)

/-- **A mint strictly decreases the potential.**

The minting pair is in the before-false set (that is the guard `findApplicableRule` tests) and out
of the after-false set (the rule's own output is the witness), and the after-false set is contained
in the before-false set by the same argument as `mintPotential_le_of_grow`. A strict subset of a
finset has strictly smaller cardinality.

**The `σ`-hit hypotheses are the residual, and they are visible here rather than absorbed.** The
pair must be drawn from the index set — `hr`, `hsf` — and the formula the rule fires on must be
`σ sf`, not merely some branch formula. See the section note on time reuse for what discharging
that costs. -/
theorem mintPotential_lt_of_mint {U : Finset SignedFormula} {σ : SignedFormula → SignedFormula}
    {b b' : Branch} {ord ord' : TimeOrdering} {r : TableauRule} {sf : SignedFormula}
    (hb : ∀ x ∈ b, x ∈ b') (hord : ∀ q ∈ ord.constraints, q ∈ ord'.constraints)
    (hr : r ∈ freshLabelRules) (hsf : sf ∈ U)
    (hbefore : witnessPresent r (σ sf) b ord = false)
    (hafter : witnessPresent r (σ sf) b' ord' = true) :
    mintPotential U σ b' ord' < mintPotential U σ b ord := by
  refine Finset.card_lt_card ?_
  refine (Finset.ssubset_iff_of_subset ?_).mpr ⟨(r, sf), ?_, ?_⟩
  · intro p hp
    simp only [Finset.mem_filter] at hp ⊢
    refine ⟨hp.1, ?_⟩
    rcases hw : witnessPresent p.1 (σ p.2) b ord with _ | _
    · rfl
    · rw [witnessPresent_branch_mono hb (witnessPresent_ord_mono hord hw)] at hp
      exact absurd hp.2 (by simp)
  · simp only [Finset.mem_filter, Finset.mem_product]
    exact ⟨⟨hr, hsf⟩, hbefore⟩
  · simp only [Finset.mem_filter, hafter]
    simp

/-- **Engine level, unordered successors.** `.extended` and every arm of a `.split` grow both
components of the state, so `mintPotential_le_of_grow` applies with the renaming unchanged.
`.saturated` and `.splitOrdered` contribute no unordered successor. -/
theorem mintPotential_expandOnceUnblocked {U : Finset SignedFormula}
    {σ : SignedFormula → SignedFormula} {b : Branch} {ord : TimeOrdering}
    {fc : FormalSystem.ProofSystem.FrameClass} {tr : EventualityTracker} :
    ∀ nb ∈ unorderedSuccessorBranches (expandOnceUnblocked b ord fc tr).1,
      mintPotential U σ nb (expandOnceUnblocked b ord fc tr).2 ≤ mintPotential U σ b ord := by
  intro nb hnb
  exact mintPotential_le_of_grow (expandOnceUnblocked_branch_mono nb hnb)
    expandOnceUnblocked_ord_mono

/-- **Engine level, the ordered split's three arms.** Each arm reports which renaming the run
carries onward: arms 1 and 2 keep `σ` (the branch is literally unchanged and the ordering gains one
edge), arm 3 post-composes `rhoSF t₂ t₁`. The disjunction is the honest shape — the induction
chooses per arm, and both choices are supplied with the same bound. -/
theorem mintPotential_expandOnceUnblocked_splitOrdered {U : Finset SignedFormula}
    {σ : SignedFormula → SignedFormula} {b : Branch} {ord : TimeOrdering}
    {fc : FormalSystem.ProofSystem.FrameClass} {tr : EventualityTracker}
    {bs : List (Branch × TimeOrdering)} {t₁ t₂ : TimeIndex}
    (hinv : RunInvariant b ord)
    (hbs : (expandOnceUnblocked b ord fc tr).1 = ExpansionResult.splitOrdered bs)
    (htrig : firstIncomparablePair b ord = some (t₁, t₂)) :
    ∀ p ∈ bs, ∃ σ' : SignedFormula → SignedFormula,
      (σ' = σ ∨ σ' = fun x => rhoSF (min t₁ t₂) (max t₁ t₂) (σ x)) ∧
        mintPotential U σ' p.1 p.2 ≤ mintPotential U σ b ord := by
  obtain ⟨u₁, u₂, htrig', rfl⟩ := expandOnceUnblocked_splitOrdered_shape hbs
  rw [htrig] at htrig'
  obtain ⟨rfl, rfl⟩ : t₁ = u₁ ∧ t₂ = u₂ := by simpa using htrig'
  intro p hp
  simp only [List.mem_cons, List.not_mem_nil, or_false] at hp
  rcases hp with rfl | rfl | rfl
  · exact ⟨σ, Or.inl rfl,
      mintPotential_le_of_grow (fun _ hx => hx) (addFuture_constraints_mono ord t₁ t₂)⟩
  · exact ⟨σ, Or.inl rfl,
      mintPotential_le_of_grow (fun _ hx => hx) (addFuture_constraints_mono ord t₂ t₁)⟩
  · exact ⟨_, Or.inr rfl, mintPotential_identifyTime_oriented htrig hinv.irreflOrd⟩

/-- **The mint budget's arithmetic, non-minting step.** The invariant is "mints used plus potential
remaining does not exceed the budget"; a step that does not mint leaves the first summand alone and
does not raise the second. The mirror of `extendBudget_preserved` for the mint dimension. -/
theorem mintBudget_preserved {used budget p p' : Nat}
    (hbud : used + p ≤ budget) (hle : p' ≤ p) : used + p' ≤ budget := by omega

/-- **The mint budget's arithmetic, minting step.** A mint spends one unit of budget and buys a
strict decrease in the potential, so the sum is again preserved. This is the mint dimension's
analogue of `splitBudget_preserved`, and it is where "each pair mints at most once" is cashed. -/
theorem mintBudget_preserved_mint {used budget p p' : Nat}
    (hbud : used + p ≤ budget) (hlt : p' < p) : (used + 1) + p' ≤ budget := by omega

/-- **`#mints ≤ 8 · |U|` along any run** — the composition, stated over an arbitrary sequence of
states, renamings and mint counts.

This is the piece the carried renaming buys. The hypothesis is exactly the two step shapes above
combined with the budget arithmetic: at every step, `mints + mintPotential` does not increase, with
the step free to choose the successor renaming (`σ (i+1)` is unconstrained here, and the two
engine-level lemmas supply the two admissible choices). Because the index set is fixed, the
potentials at different steps are comparable **without** any injection between them, and the run
may carry arbitrarily many identifications.

The conclusion mentions neither the branch, nor branch growth, nor the number of ordered splits. -/
theorem mints_le_eight_mul {U : Finset SignedFormula}
    (σ : Nat → SignedFormula → SignedFormula) (br : Nat → Branch) (og : Nat → TimeOrdering)
    (mints : Nat → Nat) (n : Nat) (h0 : mints 0 = 0)
    (hstep : ∀ i < n, mints (i + 1) + mintPotential U (σ (i + 1)) (br (i + 1)) (og (i + 1))
      ≤ mints i + mintPotential U (σ i) (br i) (og i)) :
    mints n ≤ 8 * U.card := by
  have key : ∀ m ≤ n, mints m + mintPotential U (σ m) (br m) (og m)
      ≤ mints 0 + mintPotential U (σ 0) (br 0) (og 0) := by
    intro m
    induction m with
    | zero => intro _; exact Nat.le_refl _
    | succ k ih =>
      intro hk
      exact le_trans (hstep k (Nat.lt_of_lt_of_le (Nat.lt_succ_self k) hk))
        (ih (Nat.le_of_succ_le hk))
  have h := key n (Nat.le_refl n)
  rw [h0] at h
  have hb : mintPotential U (σ 0) (br 0) (og 0) ≤ 8 * U.card :=
    mintPotential_le_eight_mul _ _ _ _
  omega

/-- **The budget-carrying restatement, as a fixed target.**

This is the statement the induction over fuel has to close, named here so the counting block has
something fixed to aim at and so the shape cannot drift while it is being built. **Nothing here
asserts it**: it is a `Prop`-valued definition, and it is discharged where the induction is closed,
not before.

Read against `expandBranchWithFuel_isSome_of_noSplit`, four things changed and each is deliberate:

* **The unbranching-run restriction is gone**, name and all — the predicate
  `expandBranchWithFuel_isSome_of_noSplit` carries does not appear here under any spelling.
  No hypothesis restricts which `ExpansionResult` shapes the run may take,
  which is the whole point; a theorem that only applied to unbranching runs would have removed the
  restriction in name only.
* **The mint budget is an explicit parameter**, `mintBudget`, constrained only by
  `8 * U.card ≤ mintBudget` — the ceiling `mintPotential_le_eight_mul` supplies outright. It is a
  parameter this development discharges, never a caller obligation.
* **The time bound is derived from it**, `b.knownTimes.toFinset.card + mintBudget ≤ Tmax`, rather
  than assumed: each identification drops the known-time count and each mint raises it by one, so
  the initial count plus the mint budget bounds it for the whole run.
* **`RunInvariant` is the carried side condition**, on the *initial* state only. It is
  re-established at every successor by `expandOnceUnblocked_runInvariant`, and at the engine's own
  seed it is discharged outright by `runInvariant_initial`.

The fuel figure is the landed `splitAwareFuel`, unmodified, and the branch budget is the
`β`-linear one that `splitBudget_preserved` preserves. -/
def BudgetedTotality (fc : FormalSystem.ProofSystem.FrameClass) (U : Finset SignedFormula)
    (mintBudget Tmax D β : Nat) : Prop :=
  ∀ (b : Branch) (ord : TimeOrdering) (tr : EventualityTracker) (applied : AppliedSet)
    (maxBranches branchesUsed : Nat),
    (∀ x ∈ b, x ∈ U) →
    RunInvariant b ord →
    8 * U.card ≤ mintBudget →
    b.knownTimes.toFinset.card + mintBudget ≤ Tmax →
    branchesUsed + β * splitAwareFuel U.card Tmax D β ≤ maxBranches →
    (expandBranchWithFuel b (splitAwareFuel U.card Tmax D β) ord fc tr applied
      maxBranches branchesUsed).isSome = true

/-! ## C4. The once-only bound — the guard before a mint, the witness after one

The mint potential decreases at a mint for two reasons that have to be read off the source rather
than assumed, and they are proved here in that order.

**Before.** `findApplicableRule` gates every `ruleMintsFreshLabel` rule on `witnessPresent`, in
both arms that can carry one, and **instead of** the output-presence test rather than in addition
to it. This reading was checked against the source before anything was built on it: the `.linear`
arm tests `witnessPresent` under `if ruleMintsFreshLabel rule`, with the `fs.all branch.contains`
test in the *else* branch; the `.branching` arm does the same behind the `ruleSelfGuarded` test,
and `not_selfGuarded_of_fresh` proves no fresh-label rule is self-guarded, so the guard is always
reached. The `.persistent` and `.branchingOrdered` arms carry no guard, which costs nothing here
because the two lemmas below take the result shape as a hypothesis and are only ever applied at
the two shapes that do.

An `&&`-composition of the two tests would have broken the once-only argument, because a pair
could then be re-selected after its witness existed. It is not one.

**After.** All eight constructors return a syntactic cons whose head is the witness at the fresh
label, and the rule's own ordering edge puts that label in reach: `addFuture l.time freshTime`
for the future-directed rules, `addPast` for the past-directed ones, and the two world-minting
rules need no edge at all because `witnessPresent` scans `Branch.knownWorlds`. So immediately
after a mint, the pair reports a witness — which is what makes the decrease strict rather than
merely non-increasing. -/

/-- No fresh-label rule is self-guarded, so the `.branching` arm's `ruleSelfGuarded` test never
diverts a mint away from its guard. Decided over all thirty-six constructors. -/
theorem not_selfGuarded_of_fresh {r : TableauRule} (h : ruleMintsFreshLabel r = true) :
    ruleSelfGuarded r = false := by
  cases r <;> simp_all [ruleMintsFreshLabel, ruleSelfGuarded]

/-- **The guard, at a `.linear` mint.** Generalises `findApplicableRule_guard_mint` from the two
world-minting rules to all eight fresh-label rules, by taking the result shape as a hypothesis
instead of excluding the unguarded shapes rule by rule. -/
theorem findApplicableRule_guard_linear {sf : SignedFormula} {b : Branch} {ord : TimeOrdering}
    {fc : FormalSystem.ProofSystem.FrameClass} {r : TableauRule} {fs : List SignedFormula}
    {o : TimeOrdering}
    (h : findApplicableRule sf b ord fc = some (r, RuleResult.linear fs, o))
    (hfresh : ruleMintsFreshLabel r = true) :
    witnessPresent r sf b ord = false := by
  unfold findApplicableRule at h
  obtain ⟨rule, -, hr⟩ := List.exists_of_findSome?_eq_some h
  (repeat' split at hr) <;> simp_all

/-- **The guard, at a `.branching` mint.** The `.linear` twin, through the `ruleSelfGuarded` test
that the `.branching` arm checks first. -/
theorem findApplicableRule_guard_branching {sf : SignedFormula} {b : Branch} {ord : TimeOrdering}
    {fc : FormalSystem.ProofSystem.FrameClass} {r : TableauRule}
    {bss : List (List SignedFormula)} {o : TimeOrdering}
    (h : findApplicableRule sf b ord fc = some (r, RuleResult.branching bss, o))
    (hfresh : ruleMintsFreshLabel r = true) :
    witnessPresent r sf b ord = false := by
  unfold findApplicableRule at h
  obtain ⟨rule, -, hr⟩ := List.exists_of_findSome?_eq_some h
  (repeat' split at hr) <;> simp_all [not_selfGuarded_of_fresh]

set_option maxHeartbeats 4000000 in
-- `repeat' split` case-splits every arm of the 36-constructor `applyRule` match; elaborating
-- all of them is past the default heartbeat budget.
/-- **After a fresh-label rule fires, its own pair reports a witness** — non-branching shapes.

The rule's emitted list is headed by the witness at the fresh label, and the second component
carries the edge that puts the fresh label in `witnessPresent`'s search: `futureOf` for the
future-directed rules, `pastOf` for the past-directed ones, `Branch.knownWorlds` for the two
world-minting rules, which need no edge. Proved by the same goal-side skeleton as
`applyRule_ordTimesKnown_nonbranching`, at the module's standing heartbeat figure — not above it. -/
theorem applyRule_fresh_witness_nonbranching {rule : TableauRule} {sf : SignedFormula}
    {b : Branch} {ord : TimeOrdering} (hfresh : ruleMintsFreshLabel rule = true) :
    ∀ nb ∈ nonBranchingResultBranch b (applyRule rule sf b ord).1,
      witnessPresent rule sf nb (applyRule rule sf b ord).2 = true := by
  cases sf with
  | mk sign formula label =>
    cases rule <;> simp only [ruleMintsFreshLabel] at hfresh <;>
      (cases sign <;> simp only [applyRule] <;> (repeat' split) <;>
        first
          | contradiction
          | (intro nb hnb
             simp only [nonBranchingResultBranch, Option.mem_def, Option.some.injEq] at hnb
             first
               | (subst hnb
                  simp_all only [witnessPresent, TimeOrdering.addFuture, TimeOrdering.addPast,
                    List.cons_append, List.any_eq_true]
                  first
                    | exact ⟨_, mem_knownWorlds_of_mem List.mem_cons_self,
                        contains_of_mem List.mem_cons_self⟩
                    | exact ⟨_, mem_futureOf_of_mem_constraints _ _ _ List.mem_cons_self,
                        contains_of_mem List.mem_cons_self⟩
                    | exact ⟨_, mem_pastOf_of_mem_constraints _ _ _ List.mem_cons_self,
                        contains_of_mem List.mem_cons_self⟩)
               | exact absurd hnb (by simp)))

set_option maxHeartbeats 4000000 in
-- `repeat' split` case-splits every arm of the 36-constructor `applyRule` match; elaborating
-- all of them is past the default heartbeat budget.
/-- **After a fresh-label rule fires, its own pair reports a witness** — `.branching` shape, both
arms.

`untlPos` and `sncePos` are the only fresh-label rules that branch, and `witnessPresent`'s clause
for each is a disjunction matching the two arms exactly: arm 1 carries the event witness at the
fresh label, arm 2 carries the guard together with the Until/Since itself. Neither arm is the
weaker one — both are proved. -/
theorem applyRule_fresh_witness_branching {rule : TableauRule} {sf : SignedFormula}
    {b : Branch} {ord : TimeOrdering} (hfresh : ruleMintsFreshLabel rule = true) :
    ∀ nb ∈ branchingResultBranches b (applyRule rule sf b ord).1,
      witnessPresent rule sf nb (applyRule rule sf b ord).2 = true := by
  cases sf with
  | mk sign formula label =>
    cases rule <;> simp only [ruleMintsFreshLabel] at hfresh <;>
      (cases sign <;> simp only [applyRule] <;> (repeat' split) <;>
        first
          | contradiction
          | (intro nb hnb
             simp only [branchingResultBranches, List.mem_map, List.mem_cons, List.not_mem_nil,
               or_false] at hnb
             all_goals
               (obtain ⟨fs, hfs, rfl⟩ := hnb
                rcases hfs with rfl | rfl <;>
                  (simp_all only [witnessPresent, TimeOrdering.addFuture, TimeOrdering.addPast,
                     List.cons_append, List.any_eq_true, Bool.or_eq_true, Bool.and_eq_true]
                   all_goals first
                     | exact ⟨_, mem_futureOf_of_mem_constraints _ _ _ List.mem_cons_self,
                         Or.inl (contains_of_mem List.mem_cons_self)⟩
                     | exact ⟨_, mem_futureOf_of_mem_constraints _ _ _ List.mem_cons_self,
                         Or.inr ⟨contains_of_mem List.mem_cons_self,
                           contains_of_mem (List.mem_cons_of_mem _ List.mem_cons_self)⟩⟩
                     | exact ⟨_, mem_pastOf_of_mem_constraints _ _ _ List.mem_cons_self,
                         Or.inl (contains_of_mem List.mem_cons_self)⟩
                     | exact ⟨_, mem_pastOf_of_mem_constraints _ _ _ List.mem_cons_self,
                         Or.inr ⟨contains_of_mem List.mem_cons_self,
                           contains_of_mem (List.mem_cons_of_mem _ List.mem_cons_self)⟩⟩))))

/-! ### The two halves meet: a mint is a strict decrease

The guard puts the minting pair *in* the before-false set and the witness puts it *out* of the
after-false set, and the successor is a superset in both components, so the after-false set is a
strict subset of the before-false set. That is `mintPotential_lt_of_mint`, with its hypotheses now
supplied from the pick rather than assumed.

The two lemmas below are stated at the **pick**, not at the engine step, because that is where
both halves are available at once — `findApplicableRule_applyRule_pair` ties the pick's reported
result to `applyRule`'s, which is what lets the guard and the witness talk about the same rule
application. The engine's fuel induction consumes them through the pick-stage bridges.

With them, the once-only bound is complete: `mints_le_eight_mul` above turns "every step preserves
`mints + mintPotential`, and a mint pays one unit for a strict decrease" into
`#mints ≤ 8 · |U|` along a run of any length, carrying any number of ordered splits. The
conclusion mentions no branch and no branch growth, which is the property route (b) exists to
supply. -/

/-- **A `.linear` mint strictly decreases the potential.** -/
theorem mintPotential_lt_of_pick_linear {U : Finset SignedFormula}
    {σ : SignedFormula → SignedFormula} {b : Branch} {ord : TimeOrdering}
    {fc : FormalSystem.ProofSystem.FrameClass} {r : TableauRule} {sf₀ sf : SignedFormula}
    {fs : List SignedFormula} {o : TimeOrdering}
    (hpick : findApplicableRule sf₀ b ord fc = some (r, RuleResult.linear fs, o))
    (hfresh : ruleMintsFreshLabel r = true) (hsfU : sf ∈ U) (hσ : σ sf = sf₀) :
    mintPotential U σ (fs ++ b) o < mintPotential U σ b ord := by
  have hpair : applyRule r sf₀ b ord = (RuleResult.linear fs, o) :=
    findApplicableRule_applyRule_pair hpick
  have hbefore : witnessPresent r (σ sf) b ord = false := by
    rw [hσ]; exact findApplicableRule_guard_linear hpick hfresh
  have hafter : witnessPresent r (σ sf) (fs ++ b) o = true := by
    rw [hσ]
    have := applyRule_fresh_witness_nonbranching (rule := r) (sf := sf₀) (b := b) (ord := ord)
      hfresh (fs ++ b) (by rw [hpair]; simp [nonBranchingResultBranch])
    rwa [hpair] at this
  have hord : ∀ q ∈ ord.constraints, q ∈ o.constraints := by
    have := applyRule_ord_mono r sf₀ b ord
    rwa [hpair] at this
  exact mintPotential_lt_of_mint (fun _ hx => List.mem_append_right fs hx) hord
    (mem_freshLabelRules.mpr hfresh) hsfU hbefore hafter

/-- **A `.branching` mint strictly decreases the potential, on every arm.** Both arms of
`untlPos` / `sncePos` carry the witness, so neither arm is the one that escapes the bound. -/
theorem mintPotential_lt_of_pick_branching {U : Finset SignedFormula}
    {σ : SignedFormula → SignedFormula} {b : Branch} {ord : TimeOrdering}
    {fc : FormalSystem.ProofSystem.FrameClass} {r : TableauRule} {sf₀ sf : SignedFormula}
    {bss : List (List SignedFormula)} {o : TimeOrdering}
    (hpick : findApplicableRule sf₀ b ord fc = some (r, RuleResult.branching bss, o))
    (hfresh : ruleMintsFreshLabel r = true) (hsfU : sf ∈ U) (hσ : σ sf = sf₀) :
    ∀ arm ∈ bss, mintPotential U σ (arm ++ b) o < mintPotential U σ b ord := by
  have hpair : applyRule r sf₀ b ord = (RuleResult.branching bss, o) :=
    findApplicableRule_applyRule_pair hpick
  have hbefore : witnessPresent r (σ sf) b ord = false := by
    rw [hσ]; exact findApplicableRule_guard_branching hpick hfresh
  have hord : ∀ q ∈ ord.constraints, q ∈ o.constraints := by
    have := applyRule_ord_mono r sf₀ b ord
    rwa [hpair] at this
  intro arm harm
  have hafter : witnessPresent r (σ sf) (arm ++ b) o = true := by
    rw [hσ]
    have := applyRule_fresh_witness_branching (rule := r) (sf := sf₀) (b := b) (ord := ord)
      hfresh (arm ++ b) (by rw [hpair]; exact List.mem_map_of_mem harm)
    rwa [hpair] at this
  exact mintPotential_lt_of_mint (fun _ hx => List.mem_append_right arm hx) hord
    (mem_freshLabelRules.mpr hfresh) hsfU hbefore hafter

/-! ## C5. The counting chain — identifications, shrinkage, extensions

Three inequalities, each **absolute**: none of them refers to how long the run is, and each is a
fold of one per-step fact over the run. `fold_le_of_step` is that fold, stated once and
instantiated three times — the additive form `f (i+1) + g i ≤ f i + g (i+1)` says "`f - g` does
not increase" without ever writing a `Nat` subtraction, which is what keeps `omega` in play at
every link.

**Link 1 — `#identifications ≤ |knownTimes|₀ + #mints`.** Each identification drops the known-time
count by at least one (`knownTimes_card_lt_at_arm3`, from the landed
`knownTimes_card_lt_identifyTime` with the trigger supplying its three hypotheses); each mint
raises it by at most one; every other step leaves it alone. The three per-step arithmetic facts
are `identStep_le`, `mintStep_le`, `plainStep_le`.

**The payoff is that the time bound is derived rather than assumed, and this is what makes the
mint budget a discharged parameter instead of a residual.** Composing link 1 with
`mints_le_eight_mul` bounds the known-time count along the whole run by
`|knownTimes|₀ + 8 * |U|`, which is `derivedTmax`. `BudgetedTotality`'s time hypothesis is
satisfied at that value by `derivedTmax_spec`, definitionally — nothing is assumed about `Tmax`
anywhere in this development.

**Link 2 — `total shrinkage ≤ #identifications · |U|`.** A single identification's `eraseDups`
merge cannot remove more than the branch had, and the branch is confined to `U`, so
`shrinkage_le_card` bounds one identification's loss by `|U|` outright.

**This is an UPPER bound on the loss, and it must not be confused with the refuted lower bound.**
Route (a) sought a *lower* bound on `(b.identifyTime t₂ t₁).toFinset.card` in terms of
`b.toFinset.card`, and that is dead by definition: `Branch.identifyTime` is
`(b.map relabel).eraseDups` and the merge is bounded only by `|U|` in the direction taken here.
Bounding the loss from above is available; bounding the survivors from below is not. A reader
meeting `shrinkage_le_card` and thinking it revives route (a) has the direction backwards.

**Link 3 — `#extensions ≤ |U| + total shrinkage`.** The branch-as-a-set grows by at least one per
extending step (`expandOnceUnblocked_card_lt`, and `expandOnceUnblocked_split_card_lt` for the
split arms) and can never exceed `|U|`; shrinkage is the only way that budget comes back.

**Assembly.** `path_le_of_links` combines the three, and `path_le_splitPathBound` checks the
result against the figure that already exists rather than introducing a new one: the assembled
bound `|U| + Tmax·|U| + Tmax` is below `splitPathBound |U| Tmax`, because `orderedRunBound` is
above `Tmax` (`orderedRunBound_ge`) and `splitPathBound` multiplies by `|U| + 1`. So Phase 13's
induction consumes `splitAwareFuel` unchanged, and **no divergence from the landed figure had to
be recorded**. -/

/-- **The fold every link of the chain uses.** If `f` gains no more than `g` does at each step,
then it has gained no more than `g` has over the whole run. Written additively so that no `Nat`
subtraction ever appears. -/
theorem fold_le_of_step (f g : Nat → Nat) (n : Nat)
    (hstep : ∀ i < n, f (i + 1) + g i ≤ f i + g (i + 1)) :
    f n + g 0 ≤ f 0 + g n := by
  induction n with
  | zero => exact Nat.le_refl _
  | succ k ih =>
    have hk := hstep k (Nat.lt_succ_self k)
    have hih := ih (fun i hi => hstep i (Nat.lt_succ_of_lt hi))
    omega

/-- An identification spends one unit of the identification counter and buys a strict drop in the
known-time count. -/
theorem identStep_le {ident kt mints ident' kt' : Nat}
    (hi : ident' = ident + 1) (hk : kt' < kt) :
    (ident' + kt') + mints ≤ (ident + kt) + mints := by omega

/-- A mint adds at most one known time and spends one unit of the mint counter. -/
theorem mintStep_le {ident kt mints kt' : Nat} (hk : kt' ≤ kt + 1) :
    (ident + kt') + mints ≤ (ident + kt) + (mints + 1) := by omega

/-- Every other step leaves the known-time count where it was, or lower. -/
theorem plainStep_le {ident kt mints kt' : Nat} (hk : kt' ≤ kt) :
    (ident + kt') + mints ≤ (ident + kt) + mints := by omega

/-- **An identification drops the known-time count**, with the trigger supplying the three
hypotheses `knownTimes_card_lt_identifyTime` asks for: both times are known and they are
distinct. -/
theorem knownTimes_card_lt_at_arm3 {b : Branch} {ord : TimeOrdering} {t₁ t₂ : TimeIndex}
    (htrig : firstIncomparablePair b ord = some (t₁, t₂)) :
    ((b.identifyTime t₂ t₁).knownTimes).toFinset.card < (b.knownTimes).toFinset.card := by
  obtain ⟨h1, h2, hne, -, -⟩ := firstIncomparablePair_spec htrig
  exact knownTimes_card_lt_identifyTime h1 h2 hne

/-- **The same drop at the engine's own orientation.** Arm 3 retires `min t₁ t₂`, and the trigger
supplies membership of both times and their distinctness in either orientation
(`firstIncomparablePair_spec_oriented`) — which is why the reorientation costs the termination
measure's first component nothing. -/
theorem knownTimes_card_lt_at_arm3_oriented {b : Branch} {ord : TimeOrdering} {t₁ t₂ : TimeIndex}
    (htrig : firstIncomparablePair b ord = some (t₁, t₂)) :
    ((b.identifyTime (min t₁ t₂) (max t₁ t₂)).knownTimes).toFinset.card
      < (b.knownTimes).toFinset.card := by
  obtain ⟨hmu, hms, hsu⟩ := firstIncomparablePair_spec_oriented htrig
  exact knownTimes_card_lt_identifyTime hmu hms hsu

/-- **Link 1**: `#identifications ≤ |knownTimes|₀ + #mints`. -/
theorem idents_le_knownTimes_add_mints (kt ident mints : Nat → Nat) (n : Nat)
    (h0 : ident 0 = 0) (hm0 : mints 0 = 0)
    (hstep : ∀ i < n, (ident (i + 1) + kt (i + 1)) + mints i
      ≤ (ident i + kt i) + mints (i + 1)) :
    ident n ≤ kt 0 + mints n := by
  have h := fold_le_of_step (fun i => ident i + kt i) mints n hstep
  omega

/-- **The derived time bound.** The initial known-time count plus the mint budget — *derived* from
link 1 and `mints_le_eight_mul`, never assumed. -/
def derivedTmax (kt0 Ucard : Nat) : Nat := kt0 + 8 * Ucard

/-- `BudgetedTotality`'s time hypothesis is satisfied at `derivedTmax`, definitionally. This is
what makes the mint budget a discharged parameter rather than a caller obligation. -/
theorem derivedTmax_spec (b : Branch) (U : Finset SignedFormula) :
    b.knownTimes.toFinset.card + 8 * U.card
      ≤ derivedTmax (b.knownTimes.toFinset.card) U.card := Nat.le_refl _

/-- **One identification's shrinkage is bounded by `|U|`** — an upper bound on the *loss*, which is
available; not a lower bound on the survivors, which is refuted. -/
theorem shrinkage_le_card {U : Finset SignedFormula} {b : Branch}
    (hU : ∀ x ∈ b, x ∈ U) (t₁ t₂ : TimeIndex) :
    b.toFinset.card - (b.identifyTime t₂ t₁).toFinset.card ≤ U.card :=
  Nat.le_trans (Nat.sub_le _ _) (card_le_of_subset_universe hU)

/-- **Link 2**: `total shrinkage ≤ #identifications · |U|`. -/
theorem shrinkage_total_le (shrink ident : Nat → Nat) (Ucard n : Nat)
    (h0 : shrink 0 = 0) (hi0 : ident 0 = 0)
    (hstep : ∀ i < n, shrink (i + 1) + ident i * Ucard
      ≤ shrink i + ident (i + 1) * Ucard) :
    shrink n ≤ ident n * Ucard := by
  have h := fold_le_of_step shrink (fun i => ident i * Ucard) n hstep
  simp only [hi0, h0, Nat.zero_mul] at h
  omega

/-- **Link 3**: `#extensions ≤ |U| + total shrinkage`. -/
theorem extensions_le (ext card shrink : Nat → Nat) (Ucard n : Nat)
    (h0 : ext 0 = 0) (hs0 : shrink 0 = 0) (hU : card n ≤ Ucard)
    (hstep : ∀ i < n, ext (i + 1) + (card i + shrink i)
      ≤ ext i + (card (i + 1) + shrink (i + 1))) :
    ext n ≤ Ucard + shrink n := by
  have h := fold_le_of_step ext (fun i => card i + shrink i) n hstep
  simp only [h0, hs0] at h
  omega

/-- **The three links assembled** into a bound on the path length, at the derived time bound. -/
theorem path_le_of_links (ext ident : Nat → Nat) (Ucard Tmax0 mintBudget shrinkN n : Nat)
    (hext : ext n ≤ Ucard + shrinkN)
    (hshrink : shrinkN ≤ ident n * Ucard)
    (hident : ident n ≤ Tmax0 + mintBudget) :
    ext n + ident n ≤ Ucard + (Tmax0 + mintBudget) * Ucard + (Tmax0 + mintBudget) := by
  have h1 : ident n * Ucard ≤ (Tmax0 + mintBudget) * Ucard := Nat.mul_le_mul_right _ hident
  omega

/-- `orderedRunBound` is above its argument, which is all the assembly needs of it. -/
theorem orderedRunBound_ge (Tmax : Nat) : Tmax ≤ orderedRunBound Tmax := by
  have h : Tmax * 1 ≤ Tmax * (Tmax * Tmax + 1) := Nat.mul_le_mul (Nat.le_refl _) (by omega)
  simp only [orderedRunBound]
  omega

/-- **The assembled figure fits inside the landed `splitPathBound`**, so the fuel induction
consumes `splitAwareFuel` unchanged and no new figure is introduced. -/
theorem path_le_splitPathBound (Ucard Tmax ext ident : Nat)
    (h : ext + ident ≤ Ucard + Tmax * Ucard + Tmax) :
    ext + ident ≤ splitPathBound Ucard Tmax := by
  have hO := orderedRunBound_ge Tmax
  have hmul : Ucard * Tmax ≤ Ucard * orderedRunBound Tmax :=
    Nat.mul_le_mul (Nat.le_refl _) hO
  have hexp : (Ucard + 1) * (orderedRunBound Tmax + 1)
      = Ucard * orderedRunBound Tmax + Ucard + orderedRunBound Tmax + 1 := by ring
  rw [Nat.mul_comm Tmax Ucard] at h
  simp only [splitPathBound, hexp]
  omega

/-! ## C6. The fuel induction, over an abstract measure

The induction that closes the branching case, stated once and over an **abstract** carried state,
measure and invariant. Separating it from any particular measure is what makes it checkable: the
statement below mentions no branch cardinality, no known-time count, no mint potential and no
ordering rank, and its proof therefore cannot smuggle in a fact about any of them. All four
`ExpansionResult` shapes are discharged here — `.saturated` by the engine's own return, `.extended`
by the inductive hypothesis at one less unit of fuel, and both split shapes through the landed
folds — so the only thing a concrete measure has to supply is the per-step obligation bundle
`StepDecreases`.

**Why the carried state is a parameter rather than a fixed measure.** The mint potential carries
the accumulated renaming `σ`, and `σ` changes at the ordered split's identification arm. A measure
of the shape `Ψ : Branch → TimeOrdering → Nat` therefore cannot express it. `StepDecreases` lets
each successor *choose* its own carried state (`∃ a'`), which is exactly the disjunction
`mintPotential_expandOnceUnblocked_splitOrdered` reports.

**The two residuals this section names rather than absorbs.**

* `ArmSettlement` — `resolveOpenArm` reports `none` on an arm that is neither closed nor
  blocking-aware saturated after the post-blocking pass. `Fuel.lean` records this outcome as
  **reachable**, not dead, and carries it as the per-arm hypothesis `hres` of both fold lemmas;
  nothing here discharges it, so it appears as a hypothesis under a name. It is stated exactly in
  the form the folds consume, quantified only over arms an engine run actually produces, so it is
  not the (false) blanket claim that `resolveOpenArm` never reports `none` — at `fuel = 0` and an
  unsaturated arm it plainly does.
* the difficulty and arity coefficients `D` and `β` — carried as `StepDecreases` clauses rather
  than computed, which is the interface `Fuel.lean`'s `splitAwareFuel` already documents. The
  reason `D` is carried is **not** the `private` marker on `temporalCount`/`modalCount`:
  `estimateBranchDifficulty_length_le` and `estimateBranchDifficulty_le_of_subperm` below both
  bound it from inside this file, because `private` blocks name resolution and not unfolding. The
  real obstruction is recorded on `DifficultyBounded` and refuted by
  `difficultyBounded_multiplicity_false`; the repaired, satisfiable shape is `StepLengthBounded`. -/

/-- **The fuel a run of at most `N` engine steps needs**, at split arity `β` and per-arm difficulty
`D`.

`N` units would suffice if fuel were not divided at a split; `allocateFuelProportionally` hands an
arm only a proportional share, and `allocateFuelProportionally_ge` says an arm is guaranteed `m`
units only when `D * β * m ≤ fuel + 1`, so each split costs a factor of `D * β + 1`. Over a path of
`N` steps that is `(D * β + 1) ^ N`.

This is the landed `splitAwareFuel` with its path length made a parameter:
`fuelFigure D β (splitPathBound Ucard Tmax)` is `splitAwareFuel Ucard Tmax D β` **definitionally**
(`fuelFigure_splitAwareFuel`, by `rfl`). Nothing about the figure changes; only the path bound it
is evaluated at becomes visible. -/
def fuelFigure (D β N : Nat) : Nat := N * (D * β + 1) ^ N

/-- The landed figure is this one at the landed path bound, on the nose. -/
theorem fuelFigure_splitAwareFuel (Ucard Tmax D β : Nat) :
    fuelFigure D β (splitPathBound Ucard Tmax) = splitAwareFuel Ucard Tmax D β := rfl

/-- The decay factor is at least one, at every exponent. -/
theorem one_le_pow_succ (K N : Nat) : 1 ≤ (K + 1) ^ N := Nat.one_le_pow _ _ (Nat.succ_pos _)

/-- A nonzero path bound needs at least one unit of fuel — which is what lets the induction
destructure `fuel` and reach the engine's `fuel + 1` arm. -/
theorem fuelFigure_pos {D β N : Nat} (hN : 1 ≤ N) : 1 ≤ fuelFigure D β N := by
  simp only [fuelFigure]
  exact Nat.one_le_iff_ne_zero.mpr (by
    have := one_le_pow_succ (D * β) N
    exact Nat.mul_ne_zero (by omega) (by omega))

/-- **One step's worth of slack.** The figure at `N + 1` covers the figure at `N` plus the one unit
the step itself consumes. This is what re-establishes both the fuel hypothesis and the `β`-linear
branch-budget hypothesis at every successor. -/
theorem fuelFigure_succ (D β N : Nat) : fuelFigure D β N + 1 ≤ fuelFigure D β (N + 1) := by
  simp only [fuelFigure]
  have hp : 1 ≤ (D * β + 1) ^ N := one_le_pow_succ _ _
  have h1 : (N + 1) * (D * β + 1) ^ (N + 1)
      = (N + 1) * ((D * β + 1) ^ N * (D * β + 1)) := by rw [Nat.pow_succ]
  have h2 : (N + 1) * (D * β + 1) ^ N ≤ (N + 1) * ((D * β + 1) ^ N * (D * β + 1)) :=
    Nat.mul_le_mul_left _ (Nat.le_mul_of_pos_right _ (by omega))
  have h3 : (N + 1) * (D * β + 1) ^ N = N * (D * β + 1) ^ N + (D * β + 1) ^ N := by ring
  omega

/-- **The allocation condition, discharged from the figure.** `allocateFuelProportionally_ge` asks
for `T * m ≤ fuel + 1` with `T` the arms' total difficulty; `totalDifficulty_le` bounds `T` by
`D * β`, and this is the resulting arithmetic. It is the whole reason the figure carries a power
rather than a product. -/
theorem fuelFigure_alloc (D β N : Nat) :
    D * β * fuelFigure D β N ≤ fuelFigure D β (N + 1) := by
  simp only [fuelFigure]
  have h1 : D * β * (N * (D * β + 1) ^ N) = N * (D * β + 1) ^ N * (D * β) := by ring
  have h2 : (N + 1) * (D * β + 1) ^ (N + 1)
      = (N + 1) * (D * β + 1) ^ N * (D * β + 1) := by rw [Nat.pow_succ]; ring
  have h3 : N * (D * β + 1) ^ N * (D * β) ≤ (N + 1) * (D * β + 1) ^ N * (D * β + 1) :=
    Nat.mul_le_mul (Nat.mul_le_mul_right _ (by omega)) (by omega)
  omega

/-- The figure is monotone in the path bound, so a later, larger path bound never invalidates an
earlier, smaller one. -/
theorem fuelFigure_mono {D β N N' : Nat} (h : N ≤ N') :
    fuelFigure D β N ≤ fuelFigure D β N' :=
  Nat.mul_le_mul h (Nat.pow_le_pow_right (by omega) h)

/-- **The per-step obligation bundle.**

Everything a concrete measure has to supply, and nothing else. Each successor may choose its own
carried state `a'` — which is what lets the mint potential's renaming change at the ordered split's
identification arm — and every clause is stated at the engine step rather than at `applyRule`, so
no pick-stage reasoning leaks into the induction.

The `β` clauses bound the split arity and the `D` clauses bound a single arm's
`estimateBranchDifficulty`; both are the coefficients `splitAwareFuel` already carries. -/
def StepDecreases {α : Type} (fc : FormalSystem.ProofSystem.FrameClass)
    (P : α → Branch → TimeOrdering → Prop) (Ψ : α → Branch → TimeOrdering → Nat)
    (D β : Nat) : Prop :=
  ∀ (a : α) (b : Branch) (ord : TimeOrdering) (tr : EventualityTracker), P a b ord →
    (∀ nb, (expandOnceUnblocked b ord fc tr).1 = ExpansionResult.extended nb →
        ∃ a' : α, P a' nb (expandOnceUnblocked b ord fc tr).2 ∧
          Ψ a' nb (expandOnceUnblocked b ord fc tr).2 < Ψ a b ord) ∧
    (∀ bs, (expandOnceUnblocked b ord fc tr).1 = ExpansionResult.split bs →
        bs.length ≤ β ∧ (∀ nb ∈ bs, estimateBranchDifficulty nb ≤ D) ∧
        ∀ nb ∈ bs, ∃ a' : α, P a' nb (expandOnceUnblocked b ord fc tr).2 ∧
          Ψ a' nb (expandOnceUnblocked b ord fc tr).2 < Ψ a b ord) ∧
    (∀ bs, (expandOnceUnblocked b ord fc tr).1 = ExpansionResult.splitOrdered bs →
        bs.length ≤ β ∧ (∀ p ∈ bs, estimateBranchDifficulty p.1 ≤ D) ∧
        ∀ p ∈ bs, ∃ a' : α, P a' p.1 p.2 ∧ Ψ a' p.1 p.2 < Ψ a b ord)

/-- **The arm-settlement residual, named rather than absorbed.**

Both split folds short-circuit on `resolveOpenArm` reporting `none`, and `Fuel.lean` records that
outcome as **reachable**: by `resolveOpenArm_eq_none_imp` the surviving route is its final "still
not saturated" arm, where the post-blocking pass returned an open branch that `findClosure` does
not close and that the arm's own recomputed tracker does not certify as blocking-aware saturated.
That is the configuration the refuted unconditional totality statement died on, so it is a live
outcome, not a dead one.

**The quantification is the honest one.** A blanket "`resolveOpenArm` never reports `none`" is
plainly false — at `fuel = 0` and an unsaturated arm it reports `none` — so this predicate is
restricted to arms an engine run actually hands the fold: `ob` is a branch some
`expandBranchWithFuel` call returned open, and `parentFuel` is the enclosing call's own fuel, which
dominates the arm's. Whether *that* is true is exactly the open question `Fuel.lean` records;
nothing in this file decides it in either direction, and it is a hypothesis everywhere it appears.

The gap it isolates is a disagreement between two eventuality trackers: the engine reports
`.saturated` against the tracker it has threaded through the run, while `resolveOpenArm` re-derives
one from the arm's own formulas (`armTracker`). The recomputed tracker is the *stricter* of the
two, so the engine's verdict does not transfer, and closing the gap means comparing the two blocked
sets — not adding fuel. -/
def ArmSettlement (fc : FormalSystem.ProofSystem.FrameClass) : Prop :=
  ∀ (b ob : Branch) (armFuel parentFuel : Nat) (ord oOrd : TimeOrdering)
    (tr : EventualityTracker) (ap oAp : AppliedSet) (mb bu : Nat),
    armFuel ≤ parentFuel →
    expandBranchWithFuel b armFuel ord fc tr ap mb bu = some (.inr (ob, oOrd, oAp)) →
    (resolveOpenArm ob oOrd oAp parentFuel fc).isSome = true

/--
**The fuel induction, free of the unbranching restriction, over an abstract measure.**

Read against the landed `expandBranchWithFuel_isSome_of_noSplit`, exactly one thing is removed and
nothing is added in its place: the unbranching-run restriction is gone, name and all, and both
split shapes are discharged here rather than excluded. `.split` goes through
`expand_split_fold_isSome` with `allocateFuelProportionally_ge` and `totalDifficulty_le` supplying
the arm's fuel and `splitBudget_preserved` the arm's budget; `.splitOrdered` goes through
`expand_splitOrdered_fold_isSome` in the same shape, with each arm expanded under **its own**
ordering.

The measure is abstract, so this theorem asserts nothing about the engine's termination behaviour
by itself: it converts a per-step decrease into totality at the figure that decrease earns. The
mathematical content of the branching case lives in `StepDecreases`, and is supplied for the mint
potential further down.

`β ≥ 1` is not decoration. The engine's very first line returns `none` when
`branchesUsed ≥ maxBranches`, so a budget hypothesis has to be strict somewhere; `β * fuelFigure`
with `β ≥ 1` and a positive path bound is what makes it strict. `BudgetedTotality`'s
`β`-linear hypothesis is **not** strict at `β = 0`, which is why the naked statement is refutable
there (`budgetedTotality_beta_zero_false`).
-/
theorem expandBranchWithFuel_isSome_of_measure {α : Type}
    {fc : FormalSystem.ProofSystem.FrameClass} {P : α → Branch → TimeOrdering → Prop}
    {Ψ : α → Branch → TimeOrdering → Nat} {D β : Nat}
    (hβ : 1 ≤ β) (hstep : StepDecreases fc P Ψ D β) (harm : ArmSettlement fc) :
    ∀ (N : Nat) (a : α) (fuel : Nat) (b : Branch) (ord : TimeOrdering) (tr : EventualityTracker)
      (applied : AppliedSet) (maxBranches branchesUsed : Nat),
      P a b ord → Ψ a b ord < N → fuelFigure D β N ≤ fuel →
      branchesUsed + β * fuelFigure D β N ≤ maxBranches →
      (expandBranchWithFuel b fuel ord fc tr applied maxBranches branchesUsed).isSome = true := by
  intro N
  induction N with
  | zero => intro _ _ _ _ _ _ _ _ _ hlt; exact absurd hlt (by omega)
  | succ M ih =>
    intro a fuel b ord tr applied mb bu hP hlt hfuel hbud
    have hFpos : 1 ≤ fuelFigure D β (M + 1) := fuelFigure_pos (by omega)
    have hsucc := fuelFigure_succ D β M
    have hβF : 1 ≤ β * fuelFigure D β (M + 1) :=
      Nat.one_le_iff_ne_zero.mpr (Nat.mul_ne_zero (by omega) (by omega))
    rcases fuel with _ | f
    · omega
    have hfM : fuelFigure D β M ≤ f := by omega
    have hbudM : ∀ k, k ≤ β → bu + k + β * fuelFigure D β M ≤ mb := by
      intro k hk
      have : β * (fuelFigure D β M + 1) ≤ β * fuelFigure D β (M + 1) :=
        Nat.mul_le_mul_left _ (by omega)
      have h2 : β * (fuelFigure D β M + 1) = β * fuelFigure D β M + β := by ring
      omega
    rw [expandBranchWithFuel, if_neg (by omega : ¬ bu ≥ mb)]
    rcases hcl : findClosure b fc with _ | reason
    case some => simp
    case none =>
      simp only [expandOnceUnblockedWithApplied]
      obtain ⟨hext, hsp, hsso⟩ :=
        hstep a b ord (fulfillEventualities b (registerEventualities b tr)) hP
      rcases hres : (expandOnceUnblocked b ord fc
          (fulfillEventualities b (registerEventualities b tr))).1 with _ | nb | bs | bs
      · simp
      · obtain ⟨a', hP', hΨ'⟩ := hext nb hres
        simpa using ih a' f nb _ _ applied mb (bu + 1) hP' (by omega) hfM
          (by have := hbudM 1 hβ; omega)
      · obtain ⟨harity, hdiff, harms⟩ := hsp bs hres
        have hT : ((bs.map estimateBranchDifficulty).foldl (· + ·) 0) * fuelFigure D β M
            ≤ f + 1 := by
          have h1 := totalDifficulty_le bs D hdiff
          have h2 : D * bs.length ≤ D * β := Nat.mul_le_mul_left _ harity
          have h3 : ((bs.map estimateBranchDifficulty).foldl (· + ·) 0) * fuelFigure D β M
              ≤ (D * β) * fuelFigure D β M := Nat.mul_le_mul_right _ (by omega)
          have h4 := fuelFigure_alloc D β M
          omega
        refine expand_split_fold_isSome f _ fc _ _ mb _ _ ?_ ?_ _ (by simp)
        · intro pair hp
          obtain ⟨hb, hal⟩ := List.of_mem_zip hp
          obtain ⟨a', hP', hΨ'⟩ := harms pair.1 hb
          refine ih a' (min pair.2 f) pair.1 _ _ _ mb _ hP' (by omega) ?_ ?_
          · exact Nat.le_min.mpr
              ⟨allocateFuelProportionally_ge f bs _ _ hfM hT hal, hfM⟩
          · exact hbudM bs.length harity
        · intro pair hp ob oOrd oAp hexp
          exact harm _ _ _ _ _ _ _ _ _ _ _ (Nat.min_le_right _ _) hexp
      · obtain ⟨harity, hdiff, harms⟩ := hsso bs hres
        have hdiff' : ∀ nb ∈ bs.map Prod.fst, estimateBranchDifficulty nb ≤ D := by
          intro nb hnb
          obtain ⟨p, hp, rfl⟩ := List.mem_map.mp hnb
          exact hdiff p hp
        have hT : (((bs.map Prod.fst).map estimateBranchDifficulty).foldl (· + ·) 0)
            * fuelFigure D β M ≤ f + 1 := by
          have h1 := totalDifficulty_le (bs.map Prod.fst) D hdiff'
          have hlen : (bs.map Prod.fst).length = bs.length := by simp
          have h2 : D * (bs.map Prod.fst).length ≤ D * β := by
            rw [hlen]; exact Nat.mul_le_mul_left _ harity
          have h3 : (((bs.map Prod.fst).map estimateBranchDifficulty).foldl (· + ·) 0)
              * fuelFigure D β M ≤ (D * β) * fuelFigure D β M :=
            Nat.mul_le_mul_right _ (by omega)
          have h4 := fuelFigure_alloc D β M
          omega
        refine expand_splitOrdered_fold_isSome f fc _ _ mb _ _ ?_ ?_ _ (by simp)
        · intro pair hp
          obtain ⟨hb, hal⟩ := List.of_mem_zip hp
          obtain ⟨a', hP', hΨ'⟩ := harms pair.1 hb
          refine ih a' (min pair.2 f) pair.1.1 pair.1.2 _ _ mb _ hP' (by omega) ?_ ?_
          · exact Nat.le_min.mpr
              ⟨allocateFuelProportionally_ge f (bs.map Prod.fst) _ _ hfM hT hal, hfM⟩
          · exact hbudM bs.length harity
        · intro pair hp ob oOrd oAp hexp
          exact harm _ _ _ _ _ _ _ _ _ _ _ (Nat.min_le_right _ _) hexp

end FormalSystem.Metalogic.Decidability
