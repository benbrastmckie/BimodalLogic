/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.Verified.Termination.MintBound.MintPotential

/-! # C7. The measure, and the figure it earns

The concrete measure the abstract induction is instantiated at, its three residuals, and the
**divergence in the fuel figure** the instantiation forced.

## The measure, and why each of its three components is there

    Ψ(σ, b, ord) = 2·(Tmax² + 1)·mintPotential + extensionAllowance + splitOrderedRank

* `splitOrderedRank` is the ordered dimension, landed and unmodified. It strictly drops at **all
  three** arms of an ordered split (`expandOnceUnblocked_splitOrdered_rank_lt`), which is the only
  thing that moves at arms 1 and 2 — there the branch is literally unchanged.
* `extensionAllowance` is the branch dimension, and it is **not** `|U| − |b|`. That plain form is
  what the recorded obstruction refutes: `Branch.identifyTime` shrinks the branch and hands
  universe budget *back*, so `|U| − |b|` rises at arm 3. The allowance carries the shrinkage the
  run may still be owed — `|U| + (|knownTimes| + mintPotential)·|U| − |b|` — which is exactly the
  counting chain's links 2 and 3 turned into a per-state quantity: at most one identification per
  unit of `|knownTimes| + mintPotential`, and at most `|U|` of shrinkage each. Every arm-3 step
  spends one unit of that allowance to buy back at most `|U|`, so the allowance never rises.
* `mintPotential` is the fourth component, weighted by `2·(Tmax² + 1)`, and it is what breaks the
  circularity. A mint raises `|knownTimes|` and therefore raises the rank; nothing in the branch
  dimension can pay for that without re-opening the recorded circularity, and the mint potential
  can, because it is bounded by `8·|U|` outright and strictly drops at every mint. The weight is
  exactly twice the rank's per-time step, which is what makes one mint's drop dominate one mint's
  rank rise with a unit to spare.

## DIVERGENCE, recorded: `splitAwareFuel` is short, and by how much

Phase-level check `path_le_splitPathBound` compares the assembled counting figure against
`splitPathBound` and it fits — but what it bounds is `#extensions + #identifications`, **not the
total number of engine steps**. Fuel is spent by every step, including the ordered split's arms 1
and 2, which change neither the branch nor its known times and are therefore counted by neither
summand. `splitPathBound Ucard Tmax = (Ucard + 1)·(orderedRunBound Tmax + 1)` budgets one full
ordered run per branch-growing step and allows `Ucard + 1` of those; the measure above admits up
to `Ucard + Tmax·Ucard` branch-growing steps (shrinkage refunds) and up to `8·Ucard` rank resets
(mints), and neither is inside that figure.

The derived figure `mintPathBound` is therefore `splitPathBound` **plus** the three ceilings the
measure actually needs, and `splitPathBound_le_mintPathBound` /
`splitAwareFuel_le_mintAwareFuel` record that this is an *enlargement*: nothing that held at the
landed figure is withdrawn, and the landed figure is not redefined. This follows plan 02's own
instruction for `orderedRunBound` — derive the value, use the derived one, record the divergence —
rather than quietly restating the target at a figure that was not checked.

## Three residuals, named and not absorbed

`UniverseClosed`, `DifficultyBounded` and `MintPaysForTime` below are hypotheses of the theorem,
never of `mintPotential` or of the engine. Each carries its own docstring saying what would
discharge it and what stands in the way. -/

namespace FormalSystem.Metalogic.Decidability

open FormalSystem.Syntax

/-- **The ordered split's rank drop, at engine level.** `splitOrderedRank_lt_of_timeLinearity` is
stated at `applyRule .timeLinearity`; this is the same content read off
`expandOnceUnblocked_splitOrdered_shape`, so the induction never has to reach past the engine step
into the pick stages. All three arms drop: arms 1-2 by `incompPairs_lt_addFuture`, arm 3 because a
retired time is worth more than the whole incomparable-pair range. -/
theorem expandOnceUnblocked_splitOrdered_rank_lt {b : Branch} {bs : List (Branch × TimeOrdering)}
    {ord : TimeOrdering} {fc : FormalSystem.ProofSystem.FrameClass} {tr : EventualityTracker}
    {Tmax : Nat} (hT : b.knownTimes.toFinset.card ≤ Tmax)
    (h : (expandOnceUnblocked b ord fc tr).1 = ExpansionResult.splitOrdered bs) :
    ∀ p ∈ bs, splitOrderedRank Tmax p.1 p.2 < splitOrderedRank Tmax b ord := by
  obtain ⟨t₁, t₂, htrig, rfl⟩ := expandOnceUnblocked_splitOrdered_shape h
  obtain ⟨hlt1, hlt2⟩ := incompPairs_lt_addFuture htrig
  intro p hp
  simp only [List.mem_cons, List.not_mem_nil, or_false] at hp
  rcases hp with rfl | rfl | rfl
  · simp only [splitOrderedRank]; omega
  · simp only [splitOrderedRank]; omega
  · obtain ⟨hmu, hms, hsu⟩ := firstIncomparablePair_spec_oriented htrig
    exact splitOrderedRank_lt_identifyTime Tmax ord hT hmu hms hsu

/-- **The identification allowance.** Known times plus remaining mints: an upper bound on how many
identifications the run can still perform, because each identification retires a known time and
only a mint can create one. This is the counting chain's link 1 as a per-state quantity. -/
def mintTimeBudget (U : Finset SignedFormula) (σ : SignedFormula → SignedFormula)
    (b : Branch) (ord : TimeOrdering) : Nat :=
  b.knownTimes.toFinset.card + mintPotential U σ b ord

/-- **The branch-growing allowance**, carrying the shrinkage the run may still be owed.

`|U| − |b|` alone is refuted as a measure by the identification arm; this is that quantity plus
`|U|` for each identification still available, which is links 2 and 3 of the counting chain read
per-state. It never rises: an identification spends one unit of `mintTimeBudget` (worth `|U|`) to
buy back at most `|U|` of branch. -/
def extensionAllowance (U : Finset SignedFormula) (σ : SignedFormula → SignedFormula)
    (b : Branch) (ord : TimeOrdering) : Nat :=
  U.card + mintTimeBudget U σ b ord * U.card - b.toFinset.card

/-- **The measure.** See the section preamble for why each of the three components is present and
why no two of them suffice. -/
def budgetPotential (U : Finset SignedFormula) (Tmax : Nat)
    (σ : SignedFormula → SignedFormula) (b : Branch) (ord : TimeOrdering) : Nat :=
  (2 * (Tmax * Tmax + 1)) * mintPotential U σ b ord
  + extensionAllowance U σ b ord
  + splitOrderedRank Tmax b ord

/-- **The carried state**: the run invariant, confinement to the universe, and the derived time
bound. The third clause is what `derivedTmax_spec` satisfies at the engine's seed, so it is a
consequence of the mint budget rather than an assumption about `Tmax`. -/
def BudgetState (U : Finset SignedFormula) (Tmax : Nat)
    (σ : SignedFormula → SignedFormula) (b : Branch) (ord : TimeOrdering) : Prop :=
  RunInvariant b ord ∧ (∀ x ∈ b, x ∈ U) ∧ mintTimeBudget U σ b ord ≤ Tmax

/-- **The forward direction of `mem_signedUniverse`.**

`mem_signedUniverse` is the `mpr` direction only: it builds membership from a formula fact and a
label fact. Every closure argument about `signedUniverse C L` needs the converse — given a member,
recover its two coordinates — because closure conditions are stated on `C` and `L`, not on the
image.

It lives here rather than beside `mem_signedUniverse` because `Fuel.lean` is frozen: its md5 is
pinned by the plan that landed the totality terminus, so no new declaration may be added to it. -/
theorem formula_label_of_mem_signedUniverse {C : Finset Formula} {L : Finset Label}
    {x : SignedFormula} (h : x ∈ signedUniverse C L) : x.formula ∈ C ∧ x.label ∈ L := by
  simp only [signedUniverse, Finset.mem_image, Finset.mem_product, Finset.mem_insert,
    Finset.mem_singleton] at h
  obtain ⟨p, ⟨-, hf, hl⟩, rfl⟩ := h
  exact ⟨hf, hl⟩

/-- **Residual 1: the universe is closed under the engine's steps.**

The unsplit totality theorem carries the same obligation, as the conjunction of its `P` and its
`hU`; here it is separated out and named because the second clause is genuinely new. An ordered
split's identification arm **relabels** the branch, so confinement is preserved only if `U` is
closed under merging one time into another.

**Clause 2 as written is false at every nonempty `U`.** `universeClosed_identify_retime_false` is
the refuting witness and `universeClosed_nonempty_false` the residual-level corollary; the cause in
one line is that the merge *target* `t₁` is universally quantified with nothing tying it to `b`, so
a `Finset` universe would have to contain a distinct retiming of one of its own members at every one
of infinitely many times. It is not a statement about `L` that a caller could discharge: no `C`, no
`L` and no frame class enters the refutation. `universeClosed_identify_empty` shows the clause does
hold at `U = ∅`, so its satisfiability set is exactly `{∅}` — satisfiable only where the terminus is
vacuous.

It is retained **verbatim, unweakened**, because the landed terminus is stated against it and
nothing in this file is withdrawn. The satisfiable replacement is `UniverseClosedAt`, which
restricts `t₁` — and only `t₁` — to `b.knownTimes`;
`universeClosedAt_of_universeClosed` records that the replacement is *weaker*, hence that every
theorem restated against it is a strengthening. The restriction leaks no new hypothesis into the
terminus, because every consumer of clause 2 reaches `t₁` through
`expandOnceUnblocked_splitOrdered_shape`, whose trigger spec `firstIncomparablePair_spec` already
returns `t₁ ∈ b.knownTimes`. Register entries 10 and 12 record the refutation and the
tempting-but-wrong repair.

**Clause 1 is a different matter, and its label dimension is *not* a caller's obligation about `L`
either** — see `universeClosed_fresh_world_escapes` and the discussion on
`unorderedSuccessor_confined_signedUniverse_of_headroom`. An earlier version of this docstring said
that for `U = signedUniverse C L` the whole definition "is a statement about `L`". That is right for
clause 2's repaired form (`timeMergeClosed_identifyTime_signedUniverse` supplies the condition) and
**wrong** for clause 1's label dimension, which no closure condition on a fixed finite `L` can
supply. -/
def UniverseClosed (fc : FormalSystem.ProofSystem.FrameClass) (U : Finset SignedFormula) : Prop :=
  (∀ (b : Branch) (ord : TimeOrdering) (tr : EventualityTracker), (∀ x ∈ b, x ∈ U) →
      ∀ nb ∈ unorderedSuccessorBranches (expandOnceUnblocked b ord fc tr).1, ∀ x ∈ nb, x ∈ U) ∧
  (∀ (b : Branch) (t₁ t₂ : TimeIndex), (∀ x ∈ b, x ∈ U) →
      ∀ x ∈ b.identifyTime t₂ t₁, x ∈ U)

/-- **Residual 2: the per-arm difficulty coefficient.**

`D` is the interface `splitAwareFuel` already documents. An earlier version of this docstring
blamed the `private` markers on `temporalCount`/`modalCount` in `Saturation.lean` for the bound
being unstatable here. **That explanation is wrong**, and the correction matters because it points
a reader at the wrong file. `private` blocks *name resolution*, not *unfolding*:
`simp only [estimateBranchDifficulty]` reduces across the module boundary and leaves the two
counters as opaque non-negative terms, over which `omega` reasons freely
(`estimateBranchDifficulty_length_le`) and against which a lemma with universally quantified
counters unifies (`estimateBranchDifficulty_le_of_subperm`). Widening the two markers would
therefore change nothing, which is why `Saturation.lean` is deliberately left untouched.

**The real obstruction is list multiplicity.** `estimateBranchDifficulty` is
`1 + 3·tempCount + 2·modCount + len/4`, and both the counters and the `len/4` term are computed
over the branch **list** — `Branch` is `List SignedFormula` (`SignedFormula.lean:240`), not a
finite set. Every confinement fact in this development, `∀ x ∈ b, x ∈ U` included, is a statement
about `b.toFinset`, and **nothing in the repository asserts a branch is `Nodup`**: successors are
built as raw `formulas ++ b` with no `eraseDups` (`Tableau.lean:2233-2239`), and avoiding a `Nodup`
side condition was a deliberate design goal (`BranchOrder.lean:275-290`). A `U`-confined branch may
therefore be arbitrarily long, so no fixed `D` bounds `estimateBranchDifficulty` on it. The
statement below is consequently **false at every `D`** at any `U` the engine fires on —
`difficultyBounded_multiplicity_false` is the refuting witness, and register entry 9 records it.

It is retained verbatim, unweakened, because the landed terminus is stated against it and nothing
in this file is withdrawn. The satisfiable replacement is `StepLengthBounded`, which is provably
equivalent to it up to a factor of `4` (`difficultyBounded_of_stepLengthBounded` and
`stepLengthBounded_of_difficultyBounded`), and `buildTableauAt_isSome_of_lengthBudget` is the
sibling terminus stated at that shape. -/
def DifficultyBounded (fc : FormalSystem.ProofSystem.FrameClass) (U : Finset SignedFormula)
    (D : Nat) : Prop :=
  ∀ (b : Branch) (ord : TimeOrdering) (tr : EventualityTracker), (∀ x ∈ b, x ∈ U) →
    (∀ nb ∈ unorderedSuccessorBranches (expandOnceUnblocked b ord fc tr).1,
        estimateBranchDifficulty nb ≤ D) ∧
    (∀ bs, (expandOnceUnblocked b ord fc tr).1 = ExpansionResult.splitOrdered bs →
        ∀ p ∈ bs, estimateBranchDifficulty p.1 ≤ D)

/-- **Residual 3: a step that creates a time is a step that mints.**

The one genuinely open mathematical obligation of this development, and the two things standing in
its way are named here rather than glossed.

*The first disjunct* — a step that does not raise the known-time count does not raise the rank —
is refuted for at least three rules if read as "non-`ruleMintsFreshLabel` implies no new time":
`densityRule` interpolates a fresh time and is deliberately **absent** from `ruleMintsFreshLabel`
(it carries its own `existingIntermediates` guard instead), and the active-mode arms of
`untlNeg`/`snceNeg` introduce times without being witness-guarded. `expandOnceNoFresh` rejects
exactly those three by testing `newOrd.constraints.length` rather than the rule list, which is the
in-repo evidence that the rule-list reading is the wrong one. So the disjunct is about the
*ordering-length* test, not about `ruleMintsFreshLabel`, and establishing it means a time-dimension
analogue of `applyRule_emitted_world_mem`.

*The second disjunct* is where the once-only bound is cashed, and it carries the **σ-hit**
obligation `mintPotential_lt_of_pick_linear` / `_branching` state in their hypotheses: the formula
the rule fires on must be `σ sf` for some `sf ∈ U`. As the section note on time reuse records, that
is a question about whether the engine can re-issue a time an earlier identification retired —
`Branch.nextTime` is `maxTime + 1` and `Branch.identifyTime` can *lower* `maxTime` — and the
equivalent live-times reformulation carries the identical obligation, which is what shows it is
intrinsic to the situation rather than an artifact of this measure. It is **not** discharged here.
It is a hypothesis, it is named, and nothing in this file assumes it.

**Both of those have since been settled, and this predicate is retained verbatim anyway.** Section
D1 lands the time-dimension analogue the first disjunct asked for —
`applyRule_emitted_time_mem`, `applyRule_emitted_time_dichotomy`,
`unorderedSuccessor_time_dichotomy` and the quantitative
`knownTimes_card_le_succ_of_unorderedSuccessor` — and the rule census `freshTimeRules` that the
disjunct's rule-list reading got wrong. Section D2 settles the rest, negatively:

* the predicate **as stated is false**, at every frame class and every `Tmax`
  (`mintPaysForTime_untlNeg_false`), satisfiable only at `U = ∅` (`mintPaysForTime_empty`);
* the σ-hit obligation is **false**, not merely open: the engine really does re-issue a retired
  time on a run (`nextTime_reissues_retired_time`, `reuse_driven_through_engine`) and nothing minted
  there lies in the renaming's image (`mint_not_in_rhoSF_image`);
* neither of the two obvious repairs is available — re-indexing the potential on `freshTimeRules`
  (`witnessPresent_eq_false_of_not_freshLabel`) nor dropping disjunct 1's cardinality conjunct
  (`splitOrderedRank_lt_of_knownTimes_lt`, `mintPaysForTime_rank_repair_false`).

So this remains the development's one open mathematical obligation, but it is now open at a
*located* obstruction rather than an unexamined one: what is missing is a measure component paying
for the three self-guarded minting rules that also survives the identification arm. See section
D2's blocked-repair note for the full statement.

**And it is open only on the temporal fragment.** Section D3 proves this predicate — the one stated
here, at every `σ`, not a repair of it — for every universe whose formulas carry no `untl` and no
`snce` node (`mintPaysForTime_of_untlSnceFree`), at every frame class and every `Tmax`, and hence at
the concrete `signedUniverse C L` the seed-level termini consume. Every step there lands in the
first disjunct, so neither the σ-hit nor the self-guard measure is consulted, and `densityRule` is
excluded by its own shape gate rather than by a frame-class restriction. What is open is the
predicate at a universe containing a temporal operator, which `mintPaysForTime_untlNeg_false`
confirms is where the difficulty actually lives. -/
def MintPaysForTime (fc : FormalSystem.ProofSystem.FrameClass) (U : Finset SignedFormula)
    (Tmax : Nat) : Prop :=
  ∀ (σ : SignedFormula → SignedFormula) (b : Branch) (ord : TimeOrdering)
    (tr : EventualityTracker), RunInvariant b ord → (∀ x ∈ b, x ∈ U) →
    ∀ nb ∈ unorderedSuccessorBranches (expandOnceUnblocked b ord fc tr).1,
      (nb.knownTimes.toFinset.card ≤ b.knownTimes.toFinset.card ∧
        splitOrderedRank Tmax nb (expandOnceUnblocked b ord fc tr).2
          ≤ splitOrderedRank Tmax b ord)
      ∨ (mintTimeBudget U σ nb (expandOnceUnblocked b ord fc tr).2
            ≤ mintTimeBudget U σ b ord ∧
          mintPotential U σ nb (expandOnceUnblocked b ord fc tr).2
            < mintPotential U σ b ord)

/-! ### `UniverseClosed`'s identification clause is refutable, at every nonempty `U`

The same shape of defect that `difficultyBounded_multiplicity_false` records for `DifficultyBounded`,
in a different coordinate. There the quantifier that went unconstrained was the branch's *length*;
here it is the identification's **merge target**.

Clause 2 reads `∀ (b : Branch) (t₁ t₂ : TimeIndex), (∀ x ∈ b, x ∈ U) → ∀ x ∈ b.identifyTime t₂ t₁,
x ∈ U`, and `t₁` — the time everything is merged *into* — ranges over all of `TimeIndex` with
nothing tying it to `b`, to `U`, or to any ordering. Since `Branch.identifyTime b t₂ t₁` is
`(b.map fun sf => if sf.label.time == t₂ then {sf with label := {sf.label with time := t₁}} else
sf).eraseDups`, the singleton branch `[x]` at `t₂ = x.label.time` retimes `x` to `t₁` outright.
Clause 2 then demands the retiming of `x` at **every** `t : TimeIndex`, and `t ↦ ⟨x.sign, x.formula,
⟨x.label.world, t⟩⟩` is injective, so `U` would have to be infinite. It is a `Finset`.

So the clause is satisfiable only where the terminus is vacuous: `universeClosed_identify_empty`
records that it does hold at `U = ∅`, and `universeClosed_nonempty_false` records that this is the
only case. No frame class enters either statement.

The repaired form is `UniverseClosedAt` below, which constrains `t₁` — and only `t₁` — to
`b.knownTimes`. Register entries 10 and 12 record the refutation and the tempting-but-wrong repair.
-/

/-- **The refutation.** Clause 2 of `UniverseClosed`, stated as a standalone proposition so the
witness does not have to carry clause 1, is false at every nonempty `U` — with no frame-class
hypothesis, because none is needed.

The universe is a `Finset`; the clause forces it to contain a distinct retiming of one of its own
members at every one of infinitely many times. The pigeonhole is taken over
`Finset.range (U.card + 1)`, which is the smallest range that cannot inject. -/
theorem universeClosed_identify_retime_false {U : Finset SignedFormula} (hne : U.Nonempty)
    (h2 : ∀ (b : Branch) (t₁ t₂ : TimeIndex), (∀ x ∈ b, x ∈ U) →
      ∀ x ∈ b.identifyTime t₂ t₁, x ∈ U) : False := by
  obtain ⟨x, hx⟩ := hne
  -- Clause 2 at the singleton branch `[x]`, source `x.label.time`, target `t`.
  have key : ∀ t : TimeIndex,
      (⟨x.sign, x.formula, ⟨x.label.world, t⟩⟩ : SignedFormula) ∈ U := by
    intro t
    have hb : ∀ y ∈ ([x] : Branch), y ∈ U := by
      intro y hy
      simp only [List.mem_cons, List.not_mem_nil, or_false] at hy
      subst hy; exact hx
    refine h2 [x] t x.label.time hb _ ?_
    refine List.mem_eraseDups.mpr (List.mem_map.mpr ⟨x, by simp, ?_⟩)
    simp only [beq_self_eq_true, if_true]
  -- `U.card + 1` retimings cannot fit in `U`.
  obtain ⟨a, -, c, -, hac, heq⟩ :=
    Finset.exists_ne_map_eq_of_card_lt_of_maps_to
      (s := Finset.range (U.card + 1)) (t := U)
      (f := fun t => (⟨x.sign, x.formula, ⟨x.label.world, t⟩⟩ : SignedFormula))
      (by simp) (fun t _ => key t)
  exact hac (by simpa using heq)

/-- **The residual as literally stated is unsatisfiable wherever it matters.** Projecting the second
conjunct and applying `universeClosed_identify_retime_false`.

This is the exact analogue of `difficultyBounded_multiplicity_false` for the other residual: the
hypothesis is not merely unproved, it is false, and it is false for a reason that no amount of work
on `C`, on `L`, or on the frame class can repair. -/
theorem universeClosed_nonempty_false {fc : FormalSystem.ProofSystem.FrameClass}
    {U : Finset SignedFormula} (hne : U.Nonempty) : ¬ UniverseClosed fc U :=
  fun h => universeClosed_identify_retime_false hne h.2

/-- **The complement that makes the refutation informative.** Clause 2 *does* hold at `U = ∅`,
vacuously: confinement to the empty universe forces `b = []`, and `[].identifyTime t₂ t₁ = []`.

Together with `universeClosed_nonempty_false` this pins the residual's satisfiability set exactly:
`{∅}`. A residual satisfiable only at the empty universe is satisfiable only where the terminus it
guards has nothing to say, since `signedUniverse C L` is empty only when `C` or `L` is. -/
theorem universeClosed_identify_empty :
    ∀ (b : Branch) (t₁ t₂ : TimeIndex), (∀ x ∈ b, x ∈ (∅ : Finset SignedFormula)) →
      ∀ x ∈ b.identifyTime t₂ t₁, x ∈ (∅ : Finset SignedFormula) := by
  intro b t₁ t₂ hb
  have hnil : b = [] := by
    cases b with
    | nil => rfl
    | cons y ys => exact absurd (hb y (by simp)) (by simp)
  subst hnil
  intro x hx
  simp only [Branch.identifyTime, List.map_nil, List.eraseDups_nil, List.not_mem_nil] at hx

/-! ### The difficulty toolkit, and the scope decision it settles

`DifficultyBounded` is the one residual whose docstring used to misdescribe its own obstruction,
and the toolkit here is what settles the question. Two routes were open:

* **(a)** widen `temporalCount`/`modalCount` in `Saturation.lean` so a formula-complexity bound
  becomes *nameable* here;
* **(b)** bound `estimateBranchDifficulty` using only what is already reachable from this file.

**(b) is taken, and (a) is neither necessary nor sufficient.** Not necessary, because
`estimateBranchDifficulty_length_le` below is a bound on `estimateBranchDifficulty` proved in this
file, right now, with the counters `private`: `simp only [estimateBranchDifficulty]` unfolds across
the module boundary and leaves the two counters as opaque `Nat`-valued terms that no source text
here can *name* but that `omega` handles like any other non-negative unknown. Upper bounds transfer
the same way, by unification against a lemma whose counters are universally quantified — that is
`estimateBranchDifficulty_le_of_subperm`. Not sufficient, because the obstruction is **list
multiplicity**, not visibility: see `DifficultyBounded`'s docstring and
`difficultyBounded_multiplicity_false`. Making the counters public would leave the residual exactly
as unprovable as it is. `Saturation.lean` is therefore not edited.

What the toolkit delivers instead is the honest maximum: a lower bound in the branch's **length**,
monotonicity of the difficulty under sub-permutation, and a concrete ceiling `difficultyCeiling U L`
that any `U`-confined branch of length at most `L` respects. Together with the equivalence in the
next block, these say that the coefficient `D` the fuel allocation consumes is, up to a factor of
`4`, a bound on branch length and nothing about formula complexity at all. -/

/-- **The difficulty is at least the branch's length, quartered.**

The lemma that retires the visibility framing of the `DifficultyBounded` residual. Its proof is
`simp only [estimateBranchDifficulty]; omega` — the unfolding crosses the `Saturation.lean`
boundary even though `temporalCount` and `modalCount` are `private` there, because `private`
governs which names this file may *write*, not which definitions the elaborator may *unfold*. What
`omega` sees after the `simp only` is `1 + 3 * ?t + 2 * ?m + b.length / 4` with the two counters
opaque non-negative terms, and dropping two non-negative summands is all the bound needs.

Read in the contrapositive this is the whole content of the multiplicity obstruction: a bound
`estimateBranchDifficulty b ≤ D` *forces* `b.length ≤ 4 * D`, so a residual asserting the former
for every `U`-confined `b` is asserting a bound on branch length in disguise. -/
theorem estimateBranchDifficulty_length_le (b : Branch) :
    1 + b.length / 4 ≤ estimateBranchDifficulty b := by
  simp only [estimateBranchDifficulty]
  omega

/-- The contrapositive reading, spelled out: a difficulty bound **is** a length bound. -/
theorem length_le_of_estimateBranchDifficulty_le {b : Branch} {D : Nat}
    (h : estimateBranchDifficulty b ≤ D) : b.length ≤ 4 * D := by
  have hl := estimateBranchDifficulty_length_le b
  omega

/-! #### The upper-bound machinery

Three plumbing lemmas about `Nat`-valued list sums under sub-permutation, then the two statements
this block exists for. Nothing here mentions the engine. -/

private theorem natSum_le_of_sublist {l₁ l₂ : List Nat} (h : l₁.Sublist l₂) :
    l₁.sum ≤ l₂.sum := by
  induction h with
  | slnil => simp
  | cons a h ih => simp only [List.sum_cons]; omega
  | cons_cons a h ih => simp only [List.sum_cons]; omega

private theorem natSum_le_of_subperm {l₁ l₂ : List Nat} (h : l₁.Subperm l₂) :
    l₁.sum ≤ l₂.sum := by
  obtain ⟨l, hl, hs⟩ := h
  rw [← hl.sum_eq]
  exact natSum_le_of_sublist hs

private theorem subperm_map_of_subperm {α β : Type} (g : α → β) {l₁ l₂ : List α}
    (h : l₁.Subperm l₂) : (l₁.map g).Subperm (l₂.map g) := by
  obtain ⟨l, hl, hs⟩ := h
  exact ⟨l.map g, hl.map g, hs.map g⟩

/-- **A branch-summed counter is monotone under sub-permutation**, for an arbitrary per-formula
weight `f`. This is the generic form of both of `estimateBranchDifficulty`'s counters; `f` is
universally quantified precisely so that the two `private` functions of `Saturation.lean` can be
supplied by unification rather than by name. -/
theorem branchCount_le_of_subperm (f : Formula → Nat) {b₁ b₂ : Branch} (h : b₁.Subperm b₂) :
    b₁.foldl (fun acc sf => acc + f sf.formula) 0
      ≤ b₂.foldl (fun acc sf => acc + f sf.formula) 0 := by
  have e : ∀ l : Branch, l.foldl (fun acc sf => acc + f sf.formula) 0
      = (l.map (fun sf => f sf.formula)).sum := by
    intro l; rw [List.sum_eq_foldl, List.foldl_map]
  rw [e, e]
  exact natSum_le_of_subperm (subperm_map_of_subperm _ h)

/-- **The unfolded shape of `estimateBranchDifficulty`, with both counters universally quantified.**

This is the lemma the visibility question turns on. Its statement mentions no `private` name, so it
can be written here; its two counter arguments are metavariables at the point of use, so
`exact difficultyShape_le_of_subperm _ _ h` against a goal already reduced by
`simp only [estimateBranchDifficulty]` unifies them with `temporalCount` and `modalCount` — terms
this file may not *type* but the elaborator may freely *assign*. -/
theorem difficultyShape_le_of_subperm (f g : Formula → Nat) {b₁ b₂ : Branch}
    (h : b₁.Subperm b₂) :
    1 + 3 * b₁.foldl (fun acc sf => acc + f sf.formula) 0
      + 2 * b₁.foldl (fun acc sf => acc + g sf.formula) 0 + b₁.length / 4
    ≤ 1 + 3 * b₂.foldl (fun acc sf => acc + f sf.formula) 0
      + 2 * b₂.foldl (fun acc sf => acc + g sf.formula) 0 + b₂.length / 4 := by
  have h1 := branchCount_le_of_subperm f h
  have h2 := branchCount_le_of_subperm g h
  have h4 : b₁.length / 4 ≤ b₂.length / 4 := Nat.div_le_div_right h.length_le
  omega

/-- **The difficulty is monotone under sub-permutation.** Every one of its four summands is: the two
counters by `branchCount_le_of_subperm`, the length term because `Subperm` bounds length, and the
constant trivially. Sub-permutation rather than `Sublist` is the right hypothesis because it is what
a *multiset* comparison gives, and multiplicity is exactly what is at issue. -/
theorem estimateBranchDifficulty_le_of_subperm {b₁ b₂ : Branch} (h : b₁.Subperm b₂) :
    estimateBranchDifficulty b₁ ≤ estimateBranchDifficulty b₂ := by
  simp only [estimateBranchDifficulty]
  exact difficultyShape_le_of_subperm _ _ h

/-- **The worst branch of length at most `L` drawn from `U`**: every element of `U` repeated `L`
times. Any `U`-confined branch of length at most `L` is a sub-permutation of it, because it can
contain at most `L` copies of any single element and this list contains exactly `L` of each. -/
noncomputable def canonicalBranch (U : Finset SignedFormula) (L : Nat) : Branch :=
  U.toList.flatMap (fun x => List.replicate L x)

/-- **The difficulty ceiling for `U`-confined branches of length at most `L`.**

Deliberately crude: it is `estimateBranchDifficulty` evaluated at the canonical worst branch, with
no attempt at tightness. Size is irrelevant to every use, because the figure only ever appears as
the `D` argument of `mintAwareFuel`, i.e. as a `Nat` fed to an already-astronomical fuel
expression. `noncomputable` because `Finset.toList` is; nothing downstream evaluates it. -/
noncomputable def difficultyCeiling (U : Finset SignedFormula) (L : Nat) : Nat :=
  estimateBranchDifficulty (canonicalBranch U L)

private theorem sublist_flatMap_of_mem {α β : Type} {a : α} {l : List α} {g : α → List β}
    (h : a ∈ l) : (g a).Sublist (l.flatMap g) := by
  induction l with
  | nil => simp at h
  | cons y ys ih =>
    rw [List.flatMap_cons]
    rcases List.mem_cons.mp h with rfl | h'
    · exact List.sublist_append_left _ _
    · exact (ih h').trans (List.sublist_append_right _ _)

private theorem sublist_flatMap_mono {α β : Type} {l : List α} {g₁ g₂ : α → List β}
    (h : ∀ a ∈ l, (g₁ a).Sublist (g₂ a)) : (l.flatMap g₁).Sublist (l.flatMap g₂) := by
  induction l with
  | nil => simp
  | cons y ys ih =>
    rw [List.flatMap_cons, List.flatMap_cons]
    exact (h y (by simp)).append (ih (fun a ha => h a (by simp [ha])))

/-- **Confinement plus a length bound is a sub-permutation of the canonical branch.** By the
multiset criterion `List.subperm_ext_iff`: an element occurs in `b` at most `b.length ≤ L` times,
and occurs in `canonicalBranch U L` exactly `L` times whenever it is in `U`. This is the one place
where the length hypothesis is genuinely needed — confinement alone gives nothing, which is the
whole content of the multiplicity obstruction. -/
theorem subperm_canonicalBranch {U : Finset SignedFormula} {L : Nat} {b : Branch}
    (hb : ∀ x ∈ b, x ∈ U) (hlen : b.length ≤ L) : b.Subperm (canonicalBranch U L) := by
  rw [List.subperm_ext_iff]
  intro x hx
  have h1 : b.count x ≤ L := le_trans List.count_le_length hlen
  have hxU : x ∈ U.toList := Finset.mem_toList.mpr (hb x hx)
  have h3 : (List.replicate L x).count x ≤ (canonicalBranch U L).count x :=
    List.Sublist.count_le x (sublist_flatMap_of_mem hxU)
  rw [List.count_replicate] at h3
  simp only [beq_self_eq_true, if_true] at h3
  omega

/-- **The ceiling does its job.** A `U`-confined branch of length at most `L` has difficulty at most
`difficultyCeiling U L`. Both hypotheses are load-bearing. -/
theorem estimateBranchDifficulty_le_ceiling {U : Finset SignedFormula} {L : Nat} {b : Branch}
    (hb : ∀ x ∈ b, x ∈ U) (hlen : b.length ≤ L) :
    estimateBranchDifficulty b ≤ difficultyCeiling U L :=
  estimateBranchDifficulty_le_of_subperm (subperm_canonicalBranch hb hlen)

/-- The ceiling is monotone in the length budget, so slack can always be absorbed upward. -/
theorem difficultyCeiling_mono {U : Finset SignedFormula} {L L' : Nat} (h : L ≤ L') :
    difficultyCeiling U L ≤ difficultyCeiling U L' :=
  estimateBranchDifficulty_le_of_subperm
    (List.Sublist.subperm (sublist_flatMap_mono
      (fun a _ => (List.replicate_sublist_replicate a).mpr h)))

/-! #### The equivalence: a difficulty bound *is* a length bound

The pair below is **the** answer to the `DifficultyBounded` residual, and it is worth stating what
it settles. `D` looks like a bound on formula complexity — `estimateBranchDifficulty` weights
`untl`/`snce` by `3` and `box` by `2`, so the name invites that reading. It is not. Up to a factor
of `4`, `DifficultyBounded fc U D` and `StepLengthBounded fc U L` are the same hypothesis:

* forwards, `stepLengthBounded_of_difficultyBounded` turns any `D` into the length budget `4 * D`;
* backwards, `difficultyBounded_of_stepLengthBounded` turns any length budget `L` into the
  difficulty coefficient `difficultyCeiling U L`.

So the residual carries **no** information about the shapes of the formulas on a branch beyond what
confinement to `U` already gives. Everything it asks for is a bound on how *long* a successor branch
can get, and that is a statement this file can make about the engine on its own — which is what
`StepLengthGrowth` below does. The visibility of `temporalCount`/`modalCount` never entered into it. -/

/-- **The residual's real content: successors of `U`-confined branches have bounded length.**

`DifficultyBounded`'s two conjuncts verbatim — same quantifier prefix, same confinement hypothesis,
same split between the unordered successors and the `.splitOrdered` arms — with
`estimateBranchDifficulty _ ≤ D` replaced by `_.length ≤ L`. -/
def StepLengthBounded (fc : FormalSystem.ProofSystem.FrameClass) (U : Finset SignedFormula)
    (L : Nat) : Prop :=
  ∀ (b : Branch) (ord : TimeOrdering) (tr : EventualityTracker), (∀ x ∈ b, x ∈ U) →
    (∀ nb ∈ unorderedSuccessorBranches (expandOnceUnblocked b ord fc tr).1, nb.length ≤ L) ∧
    (∀ bs, (expandOnceUnblocked b ord fc tr).1 = ExpansionResult.splitOrdered bs →
        ∀ p ∈ bs, p.1.length ≤ L)

/-- **A length budget buys the difficulty coefficient outright.**

`UniverseClosed` supplies confinement of every successor, `StepLengthBounded` supplies the length,
and `estimateBranchDifficulty_le_ceiling` converts the pair into `difficultyCeiling U L`.

**On the `.splitOrdered` arms.** `UniverseClosed`'s *second* conjunct is exactly what they need, and
no extra hypothesis is required: by `expandOnceUnblocked_splitOrdered_shape` the three arms are
`(b, _)`, `(b, _)` and `(b.identifyTime t₂ t₁, _)`, so arms 1-2 are confined by the incoming
hypothesis and arm 3 by the identification clause. That the identification clause was introduced for
this shape is why it is stated about `Branch.identifyTime` rather than about the engine step.

**Correction, recorded rather than glossed.** That second conjunct is **false at every nonempty `U`**
(`universeClosed_identify_retime_false`), so this theorem is a true conditional whose closure
antecedent no caller can supply. The cause is that the conjunct quantifies the merge *target* `t₁`
over all of `TimeIndex`, whereas this proof only ever needs it at the trigger's own `t₁` — which
`firstIncomparablePair_spec` puts in `b.knownTimes`. `difficultyBounded_of_stepLengthBounded_at` is
the same statement at the repaired `UniverseClosedAt`, and it is the usable one. This theorem's
statement and proof are unchanged; the sibling is additive. Register entry 10 records the refutation. -/
theorem difficultyBounded_of_stepLengthBounded {fc : FormalSystem.ProofSystem.FrameClass}
    {U : Finset SignedFormula} {L : Nat}
    (hL : StepLengthBounded fc U L) (hUcl : UniverseClosed fc U) :
    DifficultyBounded fc U (difficultyCeiling U L) := by
  intro b ord tr hbU
  refine ⟨?_, ?_⟩
  · intro nb hnb
    exact estimateBranchDifficulty_le_ceiling (hUcl.1 b ord tr hbU nb hnb)
      ((hL b ord tr hbU).1 nb hnb)
  · intro bs hbs p hp
    obtain ⟨t₁, t₂, -, rfl⟩ := expandOnceUnblocked_splitOrdered_shape hbs
    have hlen : p.1.length ≤ L := (hL b ord tr hbU).2 _ hbs p hp
    have hconf : ∀ x ∈ p.1, x ∈ U := by
      simp only [List.mem_cons, List.not_mem_nil, or_false] at hp
      rcases hp with rfl | rfl | rfl
      · exact hbU
      · exact hbU
      · exact hUcl.2 b (max t₁ t₂) (min t₁ t₂) hbU
    exact estimateBranchDifficulty_le_ceiling hconf hlen

/-- **The converse, with no side conditions at all.** A difficulty bound forces a length bound, by
`estimateBranchDifficulty_length_le` applied at each successor. Confinement is not needed in this
direction, which is the asymmetry that makes the difficulty residual the *stronger* of the two
hypotheses and hence the one that is refutable. -/
theorem stepLengthBounded_of_difficultyBounded {fc : FormalSystem.ProofSystem.FrameClass}
    {U : Finset SignedFormula} {D : Nat} (hD : DifficultyBounded fc U D) :
    StepLengthBounded fc U (4 * D) := by
  intro b ord tr hbU
  refine ⟨?_, ?_⟩
  · intro nb hnb
    exact length_le_of_estimateBranchDifficulty_le ((hD b ord tr hbU).1 nb hnb)
  · intro bs hbs p hp
    exact length_le_of_estimateBranchDifficulty_le ((hD b ord tr hbU).2 bs hbs p hp)

/-! #### The satisfiable form, and the rule-local obligation it isolates

The equivalence above says what the residual *is*; it does not make it true, and
`difficultyBounded_multiplicity_false` says it is not. What is true is the same statement with the
incoming branch's length bounded — `DifficultyBoundedAt` — and that form is reachable from a single
rule-local growth inequality, `StepLengthGrowth`. The reduction is
`difficultyBoundedAt_ceiling`, and the difference in character between the two obligations is the
point of this block:

* `DifficultyBounded` asks for a bound on `estimateBranchDifficulty` at *every* `U`-confined branch,
  which by `estimateBranchDifficulty_length_le` means a bound on the length of every `U`-confined
  branch. Confinement provides none, and no invariant supplies one. There is nothing to prove.
* `StepLengthGrowth fc c` asks, for each of `applyRule`'s arms separately, that the emitted list be
  linear in the incoming branch. That is a finite case analysis over a fixed function, with every
  arm's answer already visible in its source text. It is left unproved **by scope decision**, not by
  discovery of an obstruction, and the obligation map below is recorded so a follow-up needs no
  fresh reconnaissance. -/

/-- **The rule-local growth obligation: every successor is linear in the branch it came from.**

`c` is a parameter, so the constant may be widened freely without restating anything downstream.
`RunInvariant b ord` is present because four arms emit a list indexed by the *ordering* rather than
by the branch, and only `OrdTimesKnown` ties the two together.

### The obligation map

`applyRule` (`Tableau.lean:630`) has **36** arms. Every one is accounted for here; the largest
emitted list anywhere is `2 + 4 * b.length`, so a successor `formulas ++ b` has length at most
`2 + 5 * b.length` and `c = 5` suffices.

**Constant arms** — emitted length independent of the branch:
* `.andPos` 635, `.orNeg` 650, `.impNeg` 658: exactly `2`.
* `.andNeg` 640, `.orPos` 645, `.impPos` 655: `.branching`, each arm exactly `1`.
* `.negPos` 661, `.negNeg` 666: exactly `1`.
* `.boxTemporal` 743: a `filter` of a two-element list, so at most `2`.
* `.orderTrichotomy` 1282: `.branching` with three arms, each of length exactly `2`
  (`[pos d l0, sf]`).
* `.denseIndicatorClosure` 1331: `.linear []`, length `0`.
* `.priorUZ` 1388, `.priorSZ` 1398, `.z1Rule` 1408, `.priorUGap` 1429, `.priorSGap` 1445,
  `.sepRule` 1464: six arms, each `.persistent [newSf]`, length exactly `1`.
* `.serialityRule` 1486: a `filter` of a two-element list, so at most `2`.

**Branch-mapped arms** — emitted length `Θ(b.length)`, thirteen of them:
* `.boxPos` 671 and `.diamondNeg` 731: one `filterMap` over `branch.knownWorlds`, so at most
  `b.length`.
* `.boxNeg` 679 and `.diamondPos` 704: `witness :: boxProps ++ diaProps`, two `filterMap`s over
  branch selectors, so at most `1 + 2 * b.length`.
* `.densityRule` 1338: `witness :: gProps`, so at most `1 + b.length`.
* `.allFutureNeg` 760, `.allPastNeg` 800, `.someFuturePos` 831, `.somePastPos` 875:
  `witness :: gProps ++ fNegProps ++ modalProps`, where `modalProps` is
  `boxDiamondPersistence` (`Tableau.lean:434-442`) and is itself two branch `filterMap`s
  concatenated — four branch-length terms in all, so at most `1 + 4 * b.length`.
* the `.branching` arms of `.untlPos` 921, `.sncePos` 968, `.untlNeg` 1013, `.snceNeg` 1144:
  `[…] ++ autoProp` with `autoProp = gProps ++ fNegProps ++ modalProps`, so at most
  `2 + 4 * b.length`. **These are the widest arms in the function**, and they are what fixes
  `c = 5`.

**Ordering-driven arms** — four of them, and the reason `RunInvariant` appears in the hypothesis:
* `.allFuturePos` 751 and `.someFutureNeg` 863 `filterMap` over `timeOrd.futureOf l.time`;
  `.allPastPos` 791 and `.somePastNeg` 907 over `timeOrd.pastOf l.time`.
* `futureOf`/`pastOf` (`SignedFormula.lean:776`, `782`) are duplicate-free: `reachableForward` and
  `reachableBackward` (`SignedFormula.lean:741-758`) `eraseDups` each layer and filter it against
  the visited set. Every element is the target of an ordering constraint, so `OrdTimesKnown`
  puts it in `b.knownTimes`, whose length is at most `b.length` because
  `Branch.knownTimes` is a map-then-`eraseDups` of `b`. Hence at most `b.length` again — but only
  under the invariant, which is why the invariant is a hypothesis here and not in
  `StepLengthBounded`.

**The `.branchingOrdered` arm** — `.timeLinearity` 1513, the one already-benign family: its three
arms are `(b, _)`, `(b, _)` and `(b.identifyTime t₂ t₁, _)`, and `Branch.identifyTime` is
`(b.map relabel).eraseDups`, so all three have length at most `b.length` with no `c` needed. -/
def StepLengthGrowth (fc : FormalSystem.ProofSystem.FrameClass) (c : Nat) : Prop :=
  ∀ (b : Branch) (ord : TimeOrdering) (tr : EventualityTracker), RunInvariant b ord →
    (∀ nb ∈ unorderedSuccessorBranches (expandOnceUnblocked b ord fc tr).1,
        nb.length ≤ c * b.length + c) ∧
    (∀ bs, (expandOnceUnblocked b ord fc tr).1 = ExpansionResult.splitOrdered bs →
        ∀ p ∈ bs, p.1.length ≤ c * b.length + c)

/-- **The satisfiable form of the difficulty residual.**

`DifficultyBounded`'s two conjuncts with `RunInvariant b ord` and `b.length ≤ L` added as
hypotheses, in `MintPaysForTime`'s hypothesis order so the residual family reads uniformly. The
added length hypothesis is precisely what `difficultyBounded_multiplicity_false` shows cannot be
dispensed with: without it the statement is false at every `D`. -/
def DifficultyBoundedAt (fc : FormalSystem.ProofSystem.FrameClass) (U : Finset SignedFormula)
    (L D : Nat) : Prop :=
  ∀ (b : Branch) (ord : TimeOrdering) (tr : EventualityTracker), RunInvariant b ord →
    (∀ x ∈ b, x ∈ U) → b.length ≤ L →
    (∀ nb ∈ unorderedSuccessorBranches (expandOnceUnblocked b ord fc tr).1,
        estimateBranchDifficulty nb ≤ D) ∧
    (∀ bs, (expandOnceUnblocked b ord fc tr).1 = ExpansionResult.splitOrdered bs →
        ∀ p ∈ bs, estimateBranchDifficulty p.1 ≤ D)

/-- **The reduction.** A rule-local growth constant plus universe closure gives the satisfiable form
of the difficulty residual outright, with `D` read off as `difficultyCeiling U (c * L + c)`.

Proving `StepLengthGrowth fc c` for a concrete `c` — the map on `StepLengthGrowth` says `c = 5`
works — would therefore turn this into an **unconditional** discharge of the satisfiable form,
which is the furthest this residual can be taken. -/
theorem difficultyBoundedAt_ceiling {fc : FormalSystem.ProofSystem.FrameClass}
    {U : Finset SignedFormula} {c L : Nat}
    (hg : StepLengthGrowth fc c) (hUcl : UniverseClosed fc U) :
    DifficultyBoundedAt fc U L (difficultyCeiling U (c * L + c)) := by
  intro b ord tr hinv hbU hlen
  have habs : c * b.length + c ≤ c * L + c :=
    Nat.add_le_add_right (Nat.mul_le_mul_left c hlen) c
  refine ⟨?_, ?_⟩
  · intro nb hnb
    exact estimateBranchDifficulty_le_ceiling (hUcl.1 b ord tr hbU nb hnb)
      (le_trans ((hg b ord tr hinv).1 nb hnb) habs)
  · intro bs hbs p hp
    have hlen' : p.1.length ≤ c * L + c := le_trans ((hg b ord tr hinv).2 bs hbs p hp) habs
    obtain ⟨t₁, t₂, -, rfl⟩ := expandOnceUnblocked_splitOrdered_shape hbs
    have hconf : ∀ x ∈ p.1, x ∈ U := by
      simp only [List.mem_cons, List.not_mem_nil, or_false] at hp
      rcases hp with rfl | rfl | rfl
      · exact hbU
      · exact hbU
      · exact hUcl.2 b (max t₁ t₂) (min t₁ t₂) hbU
    exact estimateBranchDifficulty_le_ceiling hconf hlen'

/-! #### The residual as literally stated is refutable, at every `D`

The refutation, in one paragraph. Take `sf₀ := F(p → q)` at the initial label and
`U₀ := {sf₀, T p, F q}` — closed enough that `sf₀`'s one step stays inside it. Take
`b := List.replicate n sf₀`: a branch consisting of `n` copies of a single formula, which is
`U₀`-confined for every `n` because confinement is a statement about *membership*, not about
multiplicity. The engine's step at `b` is `.impNeg`, emitting `[T p, F q]`, so the successor has
length `n + 2`, and `estimateBranchDifficulty_length_le` puts its difficulty at least
`1 + (n + 2) / 4`. Instantiating at `n := 4·D + 4` makes that `D + 2`, which exceeds `D`. Hence no
`D` bounds the difficulty of the successors of `U₀`-confined branches, and
`DifficultyBounded fc U₀ D` is false — at **every** `D` and at **every** frame class.

**Why the reduction goes through generically in `n`.** Every engine function the step consults is
insensitive to the duplication:

* `blockedTimes b ord fc tr` is `b.knownTimes.filter (isTemporallyBlockedSaturated …)`, and at
  `ord = TimeOrdering.empty` the candidate list `blockCandidates` is empty at every time, so the
  filter's predicate is `false` everywhere. `blockedTimes_empty` records this for an **arbitrary**
  branch, frame class and tracker — it is not a fact about this witness at all.
* `findUnexpandedUnblockedWith` is a `List.find?`, so it short-circuits on the head, which is `sf₀`.
* `findApplicableRule` consults `allRulesForFC fc`, whose first three entries are the Dedekind rules
  and whose next two are `.negPos`/`.negNeg`; all five are inapplicable to a `.neg`-signed
  implication between atoms, so `.impNeg` — third in `allRules` — is the first rule to fire, at every
  frame class. Its `fs.all branch.contains` guard passes because `T p` is not among the copies of
  `sf₀`.

None of this is a `decide` on a fixed `n`: `findApplicableRule_multWitness` holds for any branch not
already carrying `T p`, and `expandOnceUnblocked_multBranch` for any `n ≥ 1`. -/

section MultiplicityRefutation

/-- The base atom `p` of the multiplicity refutation's witness `F(p → q)`. -/
def mfp : Formula := .atom (Atom.mkBase "p")
/-- The base atom `q` of the multiplicity refutation's witness `F(p → q)`. -/
def mfq : Formula := .atom (Atom.mkBase "q")

/-- `F(p → q)` at the initial label: the formula the refutation duplicates. `.impNeg` fires on it at
every frame class, and its two outputs are neither of them equal to it. -/
def multWitness : SignedFormula := SignedFormula.neg (Formula.imp mfp mfq) Label.initial

/-- What `.impNeg` emits at `multWitness`: `T p, F q`. -/
def multEmitted : List SignedFormula :=
  [SignedFormula.pos mfp Label.initial, SignedFormula.neg mfq Label.initial]

/-- The refuting universe: the witness together with the two formulas its one step produces, so the
universe is closed under that step and the refutation cannot be dismissed as an artefact of a
universe too small to be interesting. -/
def multUniverse : Finset SignedFormula :=
  {multWitness, SignedFormula.pos mfp Label.initial, SignedFormula.neg mfq Label.initial}

/-- **The padded branch**: `n` copies of one formula. `U`-confined at every `n`, because confinement
quantifies over membership. Its `toFinset` has one element and its `length` is `n` — which is the
entire gap `DifficultyBounded` falls into. -/
def multBranch (n : Nat) : Branch := List.replicate n multWitness

private theorem futureOf_empty (t : TimeIndex) :
    TimeOrdering.futureOf { constraints := [] } t = [] := rfl

private theorem pastOf_empty (t : TimeIndex) :
    TimeOrdering.pastOf { constraints := [] } t = [] := rfl

/-- **Nothing is blocked at the empty ordering**, at any branch, frame class or tracker. Blocking
needs an ancestor to block against, and `blockCandidates` reads its candidates off the ordering's
constraints. This is what makes the refutation's engine reduction independent of the branch's
content. -/
theorem blockedTimes_empty (b : Branch) (fc : FormalSystem.ProofSystem.FrameClass)
    (tr : EventualityTracker) : blockedTimes b TimeOrdering.empty fc tr = [] := by
  simp [blockedTimes, isTemporallyBlockedSaturated, blockCandidates, ancestorTimes,
    TimeOrdering.empty, futureOf_empty, pastOf_empty]

private theorem ia_priorUGap (fc : FormalSystem.ProofSystem.FrameClass) :
    isApplicable .priorUGap multWitness fc = false := rfl

private theorem ia_priorSGap (fc : FormalSystem.ProofSystem.FrameClass) :
    isApplicable .priorSGap multWitness fc = false := rfl

private theorem ia_sepRule (fc : FormalSystem.ProofSystem.FrameClass) :
    isApplicable .sepRule multWitness fc = false := rfl

private theorem ia_negPos (fc : FormalSystem.ProofSystem.FrameClass) :
    isApplicable .negPos multWitness fc = false := rfl

private theorem ia_negNeg (fc : FormalSystem.ProofSystem.FrameClass) :
    isApplicable .negNeg multWitness fc = false := by
  simp [isApplicable, multWitness, SignedFormula.neg, mfp, mfq, asNeg?]

private theorem ia_impNeg (fc : FormalSystem.ProofSystem.FrameClass) :
    isApplicable .impNeg multWitness fc = true := rfl

private theorem ar_impNeg (b : Branch) :
    applyRule .impNeg multWitness b TimeOrdering.empty
      = (RuleResult.linear multEmitted, TimeOrdering.empty) := rfl

private theorem rm_impNeg : ruleMintsFreshLabel .impNeg = false := rfl

attribute [local simp] ia_priorUGap ia_priorSGap ia_sepRule ia_negPos ia_negNeg ia_impNeg
  ar_impNeg rm_impNeg

theorem multWitness_mem_multUniverse : multWitness ∈ multUniverse := by simp [multUniverse]

private theorem pos_ne_multWitness : SignedFormula.pos mfp Label.initial ≠ multWitness := by decide

/-- **`.impNeg` is the rule the engine picks at `multWitness`, at every frame class and on any branch
not already carrying `T p`.** The five rules ahead of it in `allRulesForFC fc` — the three Dedekind
rules, then `.negPos` and `.negNeg` — are all inapplicable to a `.neg`-signed implication between
atoms, and the frame-class-dependent rules are all `.pos`-gated, which is why the two `Dedekind ≤ fc`
branches close by the same argument. -/
theorem findApplicableRule_multWitness (b : Branch)
    (hnot : SignedFormula.pos mfp Label.initial ∉ b)
    (fc : FormalSystem.ProofSystem.FrameClass) :
    findApplicableRule multWitness b TimeOrdering.empty fc
      = some (TableauRule.impNeg, RuleResult.linear multEmitted, TimeOrdering.empty) := by
  have hg : ¬ (∀ x ∈ multEmitted, b.contains x = true) := by
    intro h
    exact hnot (mem_of_branch_contains (h (SignedFormula.pos mfp Label.initial)
      (by simp [multEmitted])))
  simp only [findApplicableRule, allRulesForFC, allRules, rTimeRules]
  by_cases hd : FormalSystem.ProofSystem.FrameClass.RTime ≤ fc
  · simp [hd, hg, List.findSome?]
  · simp [hd, hg, List.findSome?]

/-- The padded branch carries only copies of the witness, so it never carries `T p`. -/
theorem pos_not_mem_multBranch (n : Nat) :
    SignedFormula.pos mfp Label.initial ∉ multBranch n := fun h =>
  pos_ne_multWitness (List.eq_of_mem_replicate h)

/-- **The step fires on the padded branch, generically in `n`.** Blocking is empty
(`blockedTimes_empty`), the `List.find?` short-circuits on the head, and the pick is `.impNeg`
(`findApplicableRule_multWitness`), so the step is `.extended (multEmitted ++ b)` — two formulas
longer than a branch that can be made arbitrarily long. -/
theorem expandOnceUnblocked_multBranch (n : Nat)
    (fc : FormalSystem.ProofSystem.FrameClass) (tr : EventualityTracker) :
    (expandOnceUnblocked (multBranch (n + 1)) TimeOrdering.empty fc tr).1
      = ExpansionResult.extended (multEmitted ++ multBranch (n + 1)) := by
  have hrule := findApplicableRule_multWitness (multBranch (n + 1))
    (pos_not_mem_multBranch (n + 1)) fc
  have hcons : multBranch (n + 1) = multWitness :: multBranch n := by
    simp [multBranch, List.replicate_succ]
  rw [expandOnceUnblocked]
  simp only [blockedTimes_empty, findUnexpandedUnblockedWith, isExpanded]
  rw [hcons, List.find?_cons]
  simp only [← hcons, hrule, Option.isNone_some, List.contains_nil, Bool.not_false,
    Bool.and_true]

theorem length_multBranch (n : Nat) : (multBranch n).length = n := by simp [multBranch]

/-- **`DifficultyBounded fc U D` is refuted, at every `D` and every frame class.**

Not merely unproved: false. The witness is `multUniverse` and the padded branch
`multBranch (4 * D + 4)`, which is `U`-confined because confinement is about membership, and whose
`.impNeg` successor has length `4 * D + 6` and hence difficulty at least `D + 2`.

This is why the landed terminus's `hD` hypothesis is unsatisfiable at any universe the engine fires
on, and hence why `buildTableauAt_isSome_of_lengthBudget` is a repair rather than a convenience: the
`DifficultyBounded`-shaped statements are true conditionals that no caller can discharge. The
repaired hypothesis is `StepLengthBounded`, and `stepLengthBounded_of_difficultyBounded` shows the
exchange loses nothing that was ever available.

Note where the refutation does **not** come from. It is not about formula complexity — the witness is
an implication between two atoms, with zero temporal and zero modal operators, so both of
`estimateBranchDifficulty`'s weighted counters are `0` on it. The entire refutation runs through the
`b.length / 4` term. Making `temporalCount` and `modalCount` public in `Saturation.lean` would leave
every step of this argument intact. -/
theorem difficultyBounded_multiplicity_false (fc : FormalSystem.ProofSystem.FrameClass)
    (D : Nat) : ¬ DifficultyBounded fc multUniverse D := by
  intro h
  have hconf : ∀ x ∈ multBranch (4 * D + 3 + 1), x ∈ multUniverse := by
    intro x hx
    rw [List.eq_of_mem_replicate hx]
    exact multWitness_mem_multUniverse
  have hstep := expandOnceUnblocked_multBranch (4 * D + 3) fc EventualityTracker.empty
  have hmem : (multEmitted ++ multBranch (4 * D + 3 + 1))
      ∈ unorderedSuccessorBranches
        (expandOnceUnblocked (multBranch (4 * D + 3 + 1)) TimeOrdering.empty fc
          EventualityTracker.empty).1 := by
    rw [hstep]; simp [unorderedSuccessorBranches]
  have hle := (h (multBranch (4 * D + 3 + 1)) TimeOrdering.empty EventualityTracker.empty
    hconf).1 _ hmem
  have hlow := estimateBranchDifficulty_length_le (multEmitted ++ multBranch (4 * D + 3 + 1))
  have hlen : (multEmitted ++ multBranch (4 * D + 3 + 1)).length = 4 * D + 6 := by
    simp [multEmitted, length_multBranch]
  rw [hlen] at hlow
  have harith : (4 * D + 6) / 4 = D + 1 := by omega
  rw [harith] at hlow
  omega

end MultiplicityRefutation

/-- **The measure drops at `.extended` and at every arm of a `.split`.**

Both residual disjuncts are discharged, and the second is the interesting one: a mint may raise the
known-time count by as much as it lowered the potential, so the rank may rise by that many units of
`Tmax² + 1` plus a full incomparable-pair range. The weight `2·(Tmax² + 1)` pays for both with a
unit left over, which is why the drop is by at least one however many times the step mints. -/
theorem budgetPotential_step_unordered {U : Finset SignedFormula} {Tmax : Nat}
    {σ : SignedFormula → SignedFormula} {b nb : Branch} {ord : TimeOrdering}
    {fc : FormalSystem.ProofSystem.FrameClass} {tr : EventualityTracker}
    (hUcl : UniverseClosed fc U) (hmint : MintPaysForTime fc U Tmax)
    (hst : BudgetState U Tmax σ b ord)
    (hmem : nb ∈ unorderedSuccessorBranches (expandOnceUnblocked b ord fc tr).1)
    (hgrow : b.toFinset.card < nb.toFinset.card) :
    BudgetState U Tmax σ nb (expandOnceUnblocked b ord fc tr).2 ∧
      budgetPotential U Tmax σ nb (expandOnceUnblocked b ord fc tr).2
        < budgetPotential U Tmax σ b ord := by
  obtain ⟨hinv, hbU, hbud⟩ := hst
  have hnbU : ∀ x ∈ nb, x ∈ U := hUcl.1 b ord tr hbU nb hmem
  have hinv' : RunInvariant nb (expandOnceUnblocked b ord fc tr).2 :=
    (expandOnceUnblocked_runInvariant hinv).1 nb hmem
  have hm' : mintPotential U σ nb (expandOnceUnblocked b ord fc tr).2
      ≤ mintPotential U σ b ord := mintPotential_expandOnceUnblocked nb hmem
  have hcU : b.toFinset.card ≤ U.card := card_le_of_subset_universe hbU
  have hc'U : nb.toFinset.card ≤ U.card := card_le_of_subset_universe hnbU
  have hS : 0 < Tmax * Tmax + 1 := by omega
  rcases hmint σ b ord tr hinv hbU nb hmem with ⟨hk, hR⟩ | ⟨hI, hmlt⟩
  · have hI : mintTimeBudget U σ nb (expandOnceUnblocked b ord fc tr).2
        ≤ mintTimeBudget U σ b ord := by
      simp only [mintTimeBudget]; omega
    have hEmul : mintTimeBudget U σ nb (expandOnceUnblocked b ord fc tr).2 * U.card
        ≤ mintTimeBudget U σ b ord * U.card := Nat.mul_le_mul_right _ hI
    have hAmul : 2 * (Tmax * Tmax + 1) * mintPotential U σ nb (expandOnceUnblocked b ord fc tr).2
        ≤ 2 * (Tmax * Tmax + 1) * mintPotential U σ b ord := Nat.mul_le_mul_left _ hm'
    refine ⟨⟨hinv', hnbU, by omega⟩, ?_⟩
    simp only [budgetPotential, extensionAllowance]
    omega
  · have hkT : nb.knownTimes.toFinset.card ≤ Tmax := by
      simp only [mintTimeBudget] at hI hbud; omega
    have hp' : (incompPairs nb (expandOnceUnblocked b ord fc tr).2).card ≤ Tmax * Tmax :=
      le_trans (incompPairs_card_le _ _) (Nat.mul_le_mul hkT hkT)
    have hEmul : mintTimeBudget U σ nb (expandOnceUnblocked b ord fc tr).2 * U.card
        ≤ mintTimeBudget U σ b ord * U.card := Nat.mul_le_mul_right _ hI
    have hg1 : (nb.knownTimes.toFinset.card + mintPotential U σ nb
          (expandOnceUnblocked b ord fc tr).2) * (Tmax * Tmax + 1)
        ≤ (b.knownTimes.toFinset.card + mintPotential U σ b ord) * (Tmax * Tmax + 1) := by
      refine Nat.mul_le_mul_right _ ?_
      simpa only [mintTimeBudget] using hI
    have hg3 : (mintPotential U σ nb (expandOnceUnblocked b ord fc tr).2 + 1)
          * (Tmax * Tmax + 1)
        ≤ mintPotential U σ b ord * (Tmax * Tmax + 1) := Nat.mul_le_mul_right _ hmlt
    have he1 : (nb.knownTimes.toFinset.card + mintPotential U σ nb
          (expandOnceUnblocked b ord fc tr).2) * (Tmax * Tmax + 1)
        = nb.knownTimes.toFinset.card * (Tmax * Tmax + 1)
          + mintPotential U σ nb (expandOnceUnblocked b ord fc tr).2 * (Tmax * Tmax + 1) := by
      ring
    have he2 : (b.knownTimes.toFinset.card + mintPotential U σ b ord) * (Tmax * Tmax + 1)
        = b.knownTimes.toFinset.card * (Tmax * Tmax + 1)
          + mintPotential U σ b ord * (Tmax * Tmax + 1) := by ring
    have he3 : (mintPotential U σ nb (expandOnceUnblocked b ord fc tr).2 + 1)
          * (Tmax * Tmax + 1)
        = mintPotential U σ nb (expandOnceUnblocked b ord fc tr).2 * (Tmax * Tmax + 1)
          + (Tmax * Tmax + 1) := by ring
    have he4 : 2 * (Tmax * Tmax + 1) * mintPotential U σ nb (expandOnceUnblocked b ord fc tr).2
        = mintPotential U σ nb (expandOnceUnblocked b ord fc tr).2 * (Tmax * Tmax + 1)
          + mintPotential U σ nb (expandOnceUnblocked b ord fc tr).2 * (Tmax * Tmax + 1) := by
      ring
    have he5 : 2 * (Tmax * Tmax + 1) * mintPotential U σ b ord
        = mintPotential U σ b ord * (Tmax * Tmax + 1)
          + mintPotential U σ b ord * (Tmax * Tmax + 1) := by ring
    refine ⟨⟨hinv', hnbU, by omega⟩, ?_⟩
    simp only [budgetPotential, extensionAllowance, splitOrderedRank]
    omega

/-- **The measure drops at every arm of an ordered split**, with each arm reporting the renaming it
carries onward.

No residual is consumed here: arms 1 and 2 keep the branch and add one edge, arm 3 is the landed
`mintPotential_identifyTime` with `rhoSF t₂ t₁` post-composed, and the rank drops at all three by
`expandOnceUnblocked_splitOrdered_rank_lt`. Arm 3 is the one that would have broken a plain
`|U| − |b|` measure, and what absorbs it is `extensionAllowance`: the arm spends one unit of
`mintTimeBudget`, which is worth a full `|U|` of branch, and the branch cannot shrink by more. -/
theorem budgetPotential_step_splitOrdered {U : Finset SignedFormula} {Tmax : Nat}
    {σ : SignedFormula → SignedFormula} {b : Branch} {ord : TimeOrdering}
    {bs : List (Branch × TimeOrdering)}
    {fc : FormalSystem.ProofSystem.FrameClass} {tr : EventualityTracker}
    (hUcl : UniverseClosed fc U) (hst : BudgetState U Tmax σ b ord)
    (hres : (expandOnceUnblocked b ord fc tr).1 = ExpansionResult.splitOrdered bs) :
    ∀ p ∈ bs, ∃ σ' : SignedFormula → SignedFormula, BudgetState U Tmax σ' p.1 p.2 ∧
      budgetPotential U Tmax σ' p.1 p.2 < budgetPotential U Tmax σ b ord := by
  obtain ⟨hinv, hbU, hbud⟩ := hst
  have hkT : b.knownTimes.toFinset.card ≤ Tmax := by
    simp only [mintTimeBudget] at hbud; omega
  have hcU : b.toFinset.card ≤ U.card := card_le_of_subset_universe hbU
  have hrank := expandOnceUnblocked_splitOrdered_rank_lt hkT hres
  have hinvs := (expandOnceUnblocked_runInvariant hinv).2 bs hres
  obtain ⟨t₁, t₂, htrig, rfl⟩ := expandOnceUnblocked_splitOrdered_shape hres
  intro p hp
  have hrk := hrank p hp
  have hinvp := hinvs p hp
  simp only [List.mem_cons, List.not_mem_nil, or_false] at hp
  rcases hp with rfl | rfl | rfl
  · dsimp only at hrk hinvp ⊢
    have hm' : mintPotential U σ b (ord.addFuture t₁ t₂) ≤ mintPotential U σ b ord :=
      mintPotential_le_of_grow (fun _ hx => hx) (addFuture_constraints_mono ord t₁ t₂)
    have hI : mintTimeBudget U σ b (ord.addFuture t₁ t₂) ≤ mintTimeBudget U σ b ord := by
      simp only [mintTimeBudget]; omega
    have hEmul : mintTimeBudget U σ b (ord.addFuture t₁ t₂) * U.card
        ≤ mintTimeBudget U σ b ord * U.card := Nat.mul_le_mul_right _ hI
    have hAmul : 2 * (Tmax * Tmax + 1) * mintPotential U σ b (ord.addFuture t₁ t₂)
        ≤ 2 * (Tmax * Tmax + 1) * mintPotential U σ b ord := Nat.mul_le_mul_left _ hm'
    refine ⟨σ, ⟨hinvp, hbU, by omega⟩, ?_⟩
    simp only [budgetPotential, extensionAllowance]
    omega
  · dsimp only at hrk hinvp ⊢
    have hm' : mintPotential U σ b (ord.addFuture t₂ t₁) ≤ mintPotential U σ b ord :=
      mintPotential_le_of_grow (fun _ hx => hx) (addFuture_constraints_mono ord t₂ t₁)
    have hI : mintTimeBudget U σ b (ord.addFuture t₂ t₁) ≤ mintTimeBudget U σ b ord := by
      simp only [mintTimeBudget]; omega
    have hEmul : mintTimeBudget U σ b (ord.addFuture t₂ t₁) * U.card
        ≤ mintTimeBudget U σ b ord * U.card := Nat.mul_le_mul_right _ hI
    have hAmul : 2 * (Tmax * Tmax + 1) * mintPotential U σ b (ord.addFuture t₂ t₁)
        ≤ 2 * (Tmax * Tmax + 1) * mintPotential U σ b ord := Nat.mul_le_mul_left _ hm'
    refine ⟨σ, ⟨hinvp, hbU, by omega⟩, ?_⟩
    simp only [budgetPotential, extensionAllowance]
    omega
  · dsimp only at hrk hinvp ⊢
    have hk := knownTimes_card_lt_at_arm3_oriented (b := b) (ord := ord) htrig
    set s := min t₁ t₂ with hsdef
    set u := max t₁ t₂ with hudef
    have hm' : mintPotential U (fun x => rhoSF s u (σ x)) (b.identifyTime s u)
        (ord.identifyTime s u) ≤ mintPotential U σ b ord :=
      mintPotential_identifyTime_oriented htrig hinv.irreflOrd
    have hIU : ∀ x ∈ b.identifyTime s u, x ∈ U := hUcl.2 b u s hbU
    have hc'U : (b.identifyTime s u).toFinset.card ≤ U.card :=
      card_le_of_subset_universe hIU
    have hIsucc : mintTimeBudget U (fun x => rhoSF s u (σ x)) (b.identifyTime s u)
        (ord.identifyTime s u) + 1 ≤ mintTimeBudget U σ b ord := by
      simp only [mintTimeBudget]; omega
    have hEmul : (mintTimeBudget U (fun x => rhoSF s u (σ x)) (b.identifyTime s u)
          (ord.identifyTime s u) + 1) * U.card
        ≤ mintTimeBudget U σ b ord * U.card := Nat.mul_le_mul_right _ hIsucc
    have hEexp : (mintTimeBudget U (fun x => rhoSF s u (σ x)) (b.identifyTime s u)
          (ord.identifyTime s u) + 1) * U.card
        = mintTimeBudget U (fun x => rhoSF s u (σ x)) (b.identifyTime s u)
          (ord.identifyTime s u) * U.card + U.card := by ring
    have hAmul : 2 * (Tmax * Tmax + 1) * mintPotential U (fun x => rhoSF s u (σ x))
          (b.identifyTime s u) (ord.identifyTime s u)
        ≤ 2 * (Tmax * Tmax + 1) * mintPotential U σ b ord := Nat.mul_le_mul_left _ hm'
    refine ⟨fun x => rhoSF s u (σ x), ⟨hinvp, hIU, by omega⟩, ?_⟩
    simp only [budgetPotential, extensionAllowance]
    omega

/-- **The per-step bundle, discharged at the concrete measure.** The arity coefficient is supplied
by the landed `expandOnceUnblocked_split_arity_le` for `.split` and by the ordered split's shape —
exactly three arms — for `.splitOrdered`, so `β ≥ 3` is all that is asked of it. -/
theorem stepDecreases_budgetPotential {fc : FormalSystem.ProofSystem.FrameClass}
    {U : Finset SignedFormula} {Tmax D β : Nat} (hβ : 3 ≤ β)
    (hUcl : UniverseClosed fc U) (hD : DifficultyBounded fc U D)
    (hmint : MintPaysForTime fc U Tmax) :
    StepDecreases fc (BudgetState U Tmax) (budgetPotential U Tmax) D β := by
  intro σ b ord tr hst
  refine ⟨?_, ?_, ?_⟩
  · intro nb hres
    have hmem : nb ∈ unorderedSuccessorBranches (expandOnceUnblocked b ord fc tr).1 := by
      rw [hres]; simp [unorderedSuccessorBranches]
    exact ⟨σ, budgetPotential_step_unordered hUcl hmint hst hmem
      (expandOnceUnblocked_card_lt hres)⟩
  · intro bs hres
    have hmem : ∀ nb ∈ bs,
        nb ∈ unorderedSuccessorBranches (expandOnceUnblocked b ord fc tr).1 := by
      intro nb hnb; rw [hres]; simpa [unorderedSuccessorBranches] using hnb
    refine ⟨le_trans (expandOnceUnblocked_split_arity_le hres) hβ, ?_, ?_⟩
    · intro nb hnb
      exact (hD b ord tr hst.2.1).1 nb (hmem nb hnb)
    · intro nb hnb
      exact ⟨σ, budgetPotential_step_unordered hUcl hmint hst (hmem nb hnb)
        (expandOnceUnblocked_split_card_lt hres hnb)⟩
  · intro bs hres
    have harity : bs.length ≤ β := by
      obtain ⟨t₁, t₂, -, rfl⟩ := expandOnceUnblocked_splitOrdered_shape hres
      simpa using hβ
    exact ⟨harity, (hD b ord tr hst.2.1).2 bs hres,
      budgetPotential_step_splitOrdered hUcl hst hres⟩

/-- **The derived path bound.** `splitPathBound` plus the three ceilings the measure needs and that
figure does not carry: the mint dimension's rank resets, the shrinkage-refunded extensions, and one
full ordered run. See the section preamble for the recorded divergence. -/
def mintPathBound (Ucard Tmax mintBudget : Nat) : Nat :=
  splitPathBound Ucard Tmax
  + 2 * (Tmax * Tmax + 1) * mintBudget
  + Ucard + Tmax * Ucard
  + orderedRunBound Tmax + 1

/-- **The derived fuel figure**, the landed one evaluated at the derived path bound. -/
def mintAwareFuel (Ucard Tmax mintBudget D β : Nat) : Nat :=
  fuelFigure D β (mintPathBound Ucard Tmax mintBudget)

/-- The derived path bound is an **enlargement** of the landed one, never a replacement. -/
theorem splitPathBound_le_mintPathBound (Ucard Tmax mintBudget : Nat) :
    splitPathBound Ucard Tmax ≤ mintPathBound Ucard Tmax mintBudget := by
  simp only [mintPathBound]; omega

/-- …and so is the fuel figure, so nothing stated at `splitAwareFuel` is withdrawn. -/
theorem splitAwareFuel_le_mintAwareFuel (Ucard Tmax mintBudget D β : Nat) :
    splitAwareFuel Ucard Tmax D β ≤ mintAwareFuel Ucard Tmax mintBudget D β := by
  rw [← fuelFigure_splitAwareFuel]
  exact fuelFigure_mono (splitPathBound_le_mintPathBound _ _ _)

/-- **The measure sits under the derived path bound**, which is the one arithmetic fact connecting
the induction to a concrete figure. Each of the three components is capped by a landed ceiling:
`mintPotential_le_eight_mul` for the mint dimension, the carried time bound for the extension
allowance, and `splitOrderedRank_le` for the ordered dimension. -/
theorem budgetPotential_lt_mintPathBound {U : Finset SignedFormula} {Tmax mintBudget : Nat}
    {σ : SignedFormula → SignedFormula} {b : Branch} {ord : TimeOrdering}
    (hst : BudgetState U Tmax σ b ord) (hmb : 8 * U.card ≤ mintBudget) :
    budgetPotential U Tmax σ b ord < mintPathBound U.card Tmax mintBudget := by
  obtain ⟨hinv, hbU, hbud⟩ := hst
  have hkT : b.knownTimes.toFinset.card ≤ Tmax := by
    simp only [mintTimeBudget] at hbud; omega
  have hm8 := mintPotential_le_eight_mul U σ b ord
  have hR := splitOrderedRank_le Tmax b ord hkT
  have hAmul : 2 * (Tmax * Tmax + 1) * mintPotential U σ b ord
      ≤ 2 * (Tmax * Tmax + 1) * mintBudget := Nat.mul_le_mul_left _ (by omega)
  have hEmul : mintTimeBudget U σ b ord * U.card ≤ Tmax * U.card :=
    Nat.mul_le_mul_right _ hbud
  simp only [budgetPotential, extensionAllowance, mintPathBound]
  omega

/-- **The target, at the derived figure.**

`BudgetedTotality` with `splitAwareFuel` replaced by `mintAwareFuel` and nothing else changed. Read
against `expandBranchWithFuel_isSome_of_noSplit`, the unbranching-run restriction is gone name and
all, the mint budget is a parameter this development discharges rather than a caller obligation,
the time bound is derived from it (`derivedTmax_spec`) rather than assumed, and `RunInvariant` is
carried on the initial state only. -/
def BudgetedTotalityAt (fc : FormalSystem.ProofSystem.FrameClass) (U : Finset SignedFormula)
    (mintBudget Tmax D β : Nat) : Prop :=
  ∀ (b : Branch) (ord : TimeOrdering) (tr : EventualityTracker) (applied : AppliedSet)
    (maxBranches branchesUsed : Nat),
    (∀ x ∈ b, x ∈ U) →
    RunInvariant b ord →
    8 * U.card ≤ mintBudget →
    b.knownTimes.toFinset.card + mintBudget ≤ Tmax →
    branchesUsed + β * mintAwareFuel U.card Tmax mintBudget D β ≤ maxBranches →
    (expandBranchWithFuel b (mintAwareFuel U.card Tmax mintBudget D β) ord fc tr applied
      maxBranches branchesUsed).isSome = true

/--
**`expandBranchWithFuel` does not exhaust, with the branching arms discharged rather than
excluded.**

The measure is instantiated at `σ = id`, which is the intrinsic mint potential: the renaming is
introduced by the run's own identification arms, not by the statement.

**The residual hypotheses, listed as the phase's scope hypothesis requires.** Four appear, and each
is named above with what would discharge it: `UniverseClosed` (closure of `U` under the engine's
steps *and* under an identification's relabelling), `DifficultyBounded` and `β ≥ 3` (the two
coefficients `splitAwareFuel` already carries as an interface), `MintPaysForTime` (the time
dimension — the one genuinely open mathematical obligation, carrying the σ-hit/time-reuse question,
and discharged outright on the `untl`/`snce`-free fragment by section D3)
and `ArmSettlement` (`resolveOpenArm`'s reachable `none`, which `Fuel.lean` carries in the same
form). None of them is the unbranching restriction under another name: each is a bound or a
closure condition, all
four `ExpansionResult` shapes remain admissible under every one of them, and
`branchingWitness_splits` exhibits a branch at which the engine genuinely splits.
-/
theorem expandBranchWithFuel_isSome_of_budget {fc : FormalSystem.ProofSystem.FrameClass}
    {U : Finset SignedFormula} {mintBudget Tmax D β : Nat}
    (hβ : 3 ≤ β) (hUcl : UniverseClosed fc U) (hD : DifficultyBounded fc U D)
    (hmint : MintPaysForTime fc U Tmax) (harm : ArmSettlement fc) :
    BudgetedTotalityAt fc U mintBudget Tmax D β := by
  intro b ord tr applied maxBranches branchesUsed hbU hinv hmb hT hbud
  have hst : BudgetState U Tmax id b ord := by
    refine ⟨hinv, hbU, ?_⟩
    have := mintPotential_le_eight_mul U id b ord
    simp only [mintTimeBudget]
    omega
  exact expandBranchWithFuel_isSome_of_measure (by omega)
    (stepDecreases_budgetPotential hβ hUcl hD hmint)
    harm (mintPathBound U.card Tmax mintBudget) id _ b ord tr applied maxBranches branchesUsed
    hst (budgetPotential_lt_mintPathBound hst hmb) (Nat.le_refl _) hbud

/-- **The naked statement is refuted at `β = 0`, not merely unproved.**

`BudgetedTotality`'s branch-budget hypothesis is `branchesUsed + β · fuel ≤ maxBranches`, which at
`β = 0` says only `branchesUsed ≤ maxBranches` — and the engine's very first line returns `none`
when `branchesUsed ≥ maxBranches`. Taking both to be zero satisfies every hypothesis and refutes
the conclusion, at every frame class, every difficulty coefficient and every branch.

This is why `BudgetedTotalityAt` above is stated with `β ≥ 3` on the theorem rather than with the
budget hypothesis left as it stands: `β ≥ 1` is what makes the budget hypothesis strict, and
`β ≥ 3` is what the measured split arity asks for. A reader who "simplifies" the coefficient away
is re-attempting a refuted statement. -/
theorem budgetedTotality_beta_zero_false (fc : FormalSystem.ProofSystem.FrameClass)
    (D : Nat) (sf : SignedFormula) :
    ¬ BudgetedTotality fc {sf} 8 ((Branch.knownTimes [sf]).toFinset.card + 8) D 0 := by
  intro h
  have hx := h [sf] TimeOrdering.empty EventualityTracker.empty {} 0 0
    (by simp) (runInvariant_initial _) (by simp) (Nat.le_refl _) (by simp)
  rw [expandBranchWithFuel.eq_def] at hx
  simp at hx

/-! ### Branching non-vacuity

`expandBranchWithFuel_isSome_of_budget` would be worth nothing if its hypotheses secretly excluded
the branching shapes — that is precisely what the unbranching restriction did, and removing the
name while keeping
the exclusion would be removing it in name only. The witness below is the mechanical check: at a
branch carrying `T(p → q)` the engine's step is a genuine `.split` with two arms, and the expansion
still terminates. The split is checked by `decide` below and termination by a probe in
`Tests/BimodalTest/Metalogic/Decidability/Verified/TerminationProbes.lean`, not by inspection. -/

section BranchingNonVacuity

private def nvp : Formula := .atom (Atom.mkBase "p")
private def nvq : Formula := .atom (Atom.mkBase "q")

/-- `T(p → q)` at the initial label: the smallest branch at which the engine genuinely splits. -/
def branchingWitness : Branch := [SignedFormula.pos (Formula.imp nvp nvq) Label.initial]

private def branchingWitnessArity : Nat :=
  match (expandOnceUnblocked branchingWitness TimeOrdering.empty .Base
      EventualityTracker.empty).1 with
  | .split bs => bs.length
  | _ => 0

/-- **The witness branches**, decided rather than asserted: the engine's step is `.split` with two
arms, so neither the `.split` clause of `StepDecreases` nor the `.split` arm of the induction is
vacuous. -/
theorem branchingWitness_splits : branchingWitnessArity = 2 := by decide

end BranchingNonVacuity

end FormalSystem.Metalogic.Decidability
