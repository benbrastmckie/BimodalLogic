/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.Verified.Termination.MintBound.Measure

/-! # D2. `MintPaysForTime`: the verdict

**Verdict: refutable as literally stated.** `mintPaysForTime_untlNeg_false` is the witness, and it
is universally quantified in the frame class and in `Tmax`. This is the third residual on this
terminus to come out refutable rather than merely unproved, after `DifficultyBounded`
(`difficultyBounded_multiplicity_false`) and `UniverseClosed`
(`universeClosed_identify_retime_false`).

**The cause, in one line.** `untlNeg` is in `freshTimeRules` and **not** in `freshLabelRules`
(`freshTimeRules_incomparable_freshLabelRules`), so a step that fires it mints a time while moving
no pair of `mintPotential`'s index set `freshLabelRules ×ˢ U`. Disjunct 1's first conjunct then
fails because a known time was added, and disjunct 2's second conjunct fails because the potential
is unchanged — `mintTimeBudget = knownTimes.card + mintPotential` even *rises*, so disjunct 2's
first conjunct fails too. All three failures are decided at the concrete configuration below.

**Re-indexing the potential on `freshTimeRules` does not repair it**, and that is worth stating
before anyone tries. `mintPotential` filters on `witnessPresent r (σ sf) b ord = false`, and
`witnessPresent`'s match has exactly eight arms — one per `freshLabelRules` member — with
everything else falling to the catch-all `false`. `witnessPresent_eq_false_of_not_freshLabel`
decides that. So widening the index set to `freshTimeRules` adds `densityRule`, `untlNeg` and
`snceNeg` columns that are *permanently* false at every state, contributing a constant to the count
and never decreasing. The wider potential is the narrower one plus `3 * |U|`, and it moves exactly
when the narrower one does. The rule coordinate is not where the repair lives.

**Where the repair does live**, and what Phase 7 builds: disjunct 1's first conjunct is the wrong
inequality. `applyRule_emitted_time_dichotomy` says an unordered successor's times are the branch's
plus at most `Branch.nextTime` — one new time per step, never more. The satisfiable statement is
therefore `nb.knownTimes.card ≤ b.knownTimes.card + 1`, which is a *theorem*
(`knownTimes_card_le_succ_of_unorderedSuccessor`) rather than a hypothesis, leaving the ordering
rank as disjunct 1's only real content.

**The satisfiability boundary.** `mintPaysForTime_empty` holds at `U = ∅`: confinement forces
`b = []`, on which the engine reports `.saturated` and there are no unordered successors at all.
As with `UniverseClosed`, the predicate is satisfiable exactly where the terminus it guards is
vacuous — `signedUniverse C L` is empty only when `C` or `L` is.

`MintPaysForTime` itself is retained **verbatim**. Nothing in this file is withdrawn. -/

namespace FormalSystem.Metalogic.Decidability

open FormalSystem.Syntax

/-- **`witnessPresent` is identically `false` outside `freshLabelRules`.** Its match has eight
arms, one per witness-guarded rule, and every other `(rule, sign, formula)` triple reaches the
catch-all.

This is the fact that rules out repairing `MintPaysForTime` by widening `mintPotential`'s index
set from `freshLabelRules` to `freshTimeRules`: the three added columns — `densityRule`, `untlNeg`,
`snceNeg` — would be false at every state of every run, so they contribute `3 * |U|` to the count
and never move. See the register entry. -/
theorem witnessPresent_eq_false_of_not_freshLabel {r : TableauRule}
    (h : ruleMintsFreshLabel r = false) (sf : SignedFormula) (b : Branch) (ord : TimeOrdering) :
    witnessPresent r sf b ord = false := by
  cases sf with
  | mk sign formula label =>
    cases r <;> first
      | exact Bool.noConfusion h
      | (cases sign <;> simp only [witnessPresent])

/-! ### The refuting configuration

`untlNeg`'s ACTIVE arm fires when `timeOrd.futureOf l.time` is empty while `timeOrd.timeCount` is
in `(0, 4)`. The configuration below meets that with the least machinery possible: the trigger
`F(U(e,g))` sits at time `0`, and the ordering's single constraint `1 < 2` involves neither `0` nor
anything reachable from it. Two atoms at times `1` and `2` carry those times on the branch, which
is what `OrdTimesKnown` needs; atoms fire no rule, so nothing pre-empts the trigger.

`untlNeg` is a `carrierBase` rule, so this configuration is available at **every** frame class —
the witness quantifies over `fc` and the four cases are decided separately. It also quantifies over
`Tmax`: disjunct 1 fails at its *first* conjunct, which does not mention `Tmax` at all. -/

/-- The base atom `e` of the time-reuse witness's trigger `F(U(g, e))`. -/
def mwE : Formula := .atom (Atom.mkBase "e")
/-- The base atom `g` of the time-reuse witness's trigger `F(U(g, e))`. -/
def mwG : Formula := .atom (Atom.mkBase "g")
/-- The base atom `p` the time-reuse witness branch carries at time `1`. -/
def mwP : Formula := .atom (Atom.mkBase "p")
/-- The base atom `q` the time-reuse witness branch carries at time `2`. -/
def mwQ : Formula := .atom (Atom.mkBase "q")

/-- The trigger: `F(U(e,g))` at the initial label. -/
def mintWitnessTrigger : SignedFormula := SignedFormula.neg (Formula.untl mwG mwE) ⟨0, 0⟩

/-- The witness branch. The two atoms exist to carry times `1` and `2`, which the ordering's one
constraint mentions and `OrdTimesKnown` therefore requires. -/
def mintWitnessBranch : Branch :=
  [mintWitnessTrigger, SignedFormula.pos mwP ⟨0, 1⟩, SignedFormula.pos mwQ ⟨0, 2⟩]

/-- The witness ordering: `1 < 2`, leaving `futureOf 0` empty with `timeCount = 2`. Exactly the
ACTIVE arm's trigger condition. -/
def mintWitnessOrd : TimeOrdering := { constraints := [(1, 2)] }

/-- The witness universe: the branch itself, so confinement is immediate. -/
def mintWitnessUniverse : Finset SignedFormula :=
  {mintWitnessTrigger, SignedFormula.pos mwP ⟨0, 1⟩, SignedFormula.pos mwQ ⟨0, 2⟩}

/-- The first arm of the split: `F(e)` at the freshly minted time `3`, the re-included trigger, and
the original branch. -/
def mintWitnessSucc : Branch :=
  [SignedFormula.neg mwE ⟨0, 3⟩, mintWitnessTrigger, mintWitnessTrigger,
   SignedFormula.pos mwP ⟨0, 1⟩, SignedFormula.pos mwQ ⟨0, 2⟩]

/-- The witness state satisfies the run invariant, so the refutation is not reached by feeding
`MintPaysForTime` a state the run cannot occupy. -/
theorem mintWitness_runInvariant : RunInvariant mintWitnessBranch mintWitnessOrd := by
  constructor
  · unfold IrreflOrd mintWitnessOrd; decide
  · unfold OrdTimesKnown; decide

/-- …and it is confined to the witness universe. -/
theorem mintWitness_confined : ∀ x ∈ mintWitnessBranch, x ∈ mintWitnessUniverse := by decide

/-- **`MintPaysForTime` is false, at every frame class and every `Tmax`.**

At the configuration above the engine fires `untlNeg`'s ACTIVE arm and reports a two-arm `.split`.
On the first arm: `knownTimes` goes from `{0,1,2}` to `{0,1,2,3}`, so disjunct 1's first conjunct
`4 ≤ 3` is false; `mintPotential` is `24` before and `24` after, so disjunct 2's second conjunct
`24 < 24` is false. Both disjuncts fail and the four frame classes are decided separately.

The step is a genuine mint — it issues `Branch.nextTime` — but it is invisible to `mintPotential`
because `untlNeg` is not in `freshLabelRules`, and `witnessPresent_eq_false_of_not_freshLabel`
records that no re-indexing recovers it. -/
theorem mintPaysForTime_untlNeg_false (fc : FormalSystem.ProofSystem.FrameClass) (Tmax : Nat) :
    ¬ MintPaysForTime fc mintWitnessUniverse Tmax := by
  intro h
  have key := h id mintWitnessBranch mintWitnessOrd EventualityTracker.empty
    mintWitness_runInvariant mintWitness_confined
  cases fc <;>
    [ (rcases key mintWitnessSucc (by decide) with ⟨h1, -⟩ | ⟨-, h3⟩);
      (rcases key mintWitnessSucc (by decide) with ⟨h1, -⟩ | ⟨-, h3⟩);
      (rcases key mintWitnessSucc (by decide) with ⟨h1, -⟩ | ⟨-, h3⟩);
      (rcases key mintWitnessSucc (by decide) with ⟨h1, -⟩ | ⟨-, h3⟩)] <;>
    first
      | exact absurd h1 (by decide)
      | exact absurd h3 (by decide)

/-- **The satisfiability boundary: `U = ∅`.** Confinement forces the branch empty, the engine has
nothing to pick in any of its three stages and reports `.saturated`, and `unorderedSuccessorBranches`
of a `.saturated` result is `[]`. So the whole statement is vacuous there.

The same shape as `universeClosed_identify_empty`: the residual is satisfiable exactly where the
terminus it guards has nothing to say, since `signedUniverse C L` is empty only when `C` or `L` is. -/
theorem mintPaysForTime_empty (fc : FormalSystem.ProofSystem.FrameClass) (Tmax : Nat) :
    MintPaysForTime fc ∅ Tmax := by
  intro _ b ord tr _ hconf nb hnb
  have hb : b = [] := List.eq_nil_iff_forall_not_mem.mpr fun x hx => by simpa using hconf x hx
  subst hb
  simp [expandOnceUnblocked, findUnexpandedUnblockedWith, unorderedSuccessorBranches] at hnb

/-! ### The repair, attempted and BLOCKED

The repair this section was to land is **not available**, and this subsection records why with
machine-checked evidence rather than leaving the attempt undocumented. Nothing vacuous is
substituted for it.

*The rule-coordinate repair is out.* Widening `mintPotential`'s index set from `freshLabelRules` to
`freshTimeRules` adds three columns that `witnessPresent_eq_false_of_not_freshLabel` proves are
`false` at every state of every run. The wider potential is the narrower one plus `3 · |U|` and
moves exactly when it does.

*The disjunct-1 repair is out too, and this is the one that had to be tested.* The obvious
remaining narrowing is to drop disjunct 1's first conjunct — `nb.knownTimes.card ≤ b.knownTimes.card`
is exactly what a minting step falsifies, and `knownTimes_card_le_succ_of_unorderedSuccessor` shows
the true bound is one larger — leaving the ordering-rank conjunct as disjunct 1's whole content.
That does not work: `splitOrderedRank Tmax b ord` is
`b.knownTimes.card * (Tmax² + 1) + (incompPairs b ord).card`, the second summand is bounded by
`Tmax²` (`incompPairs_card_le` plus the carried time bound), and the base `Tmax² + 1` is *one more*
than that bound by construction. So one extra known time raises the rank by at least `1` no matter
what the incomparable-pair count does — `splitOrderedRank_lt_of_knownTimes_lt`. The rank conjunct
therefore fails at **every** time-minting step, not just at the refuting one, and
`mintPaysForTime_rank_repair_false` decides the weakened predicate false at the same configuration
that refuted the original.

*What is actually missing.* A fourth measure component that pays for the three self-guarded minting
rules. Each has its own termination argument, and none of them is `mintPotential`:

* `untlNeg` / `snceNeg` fire only when `ord.futureOf l.time` (resp. `pastOf`) is empty **and**
  `ord.timeCount < 4`, and their own `newOrd` makes that first test fail at the next call — the
  `ruleSelfGuarded` mechanism. The natural potential, "branch times with empty forward reach", does
  **not** decrease: the arm removes the trigger's empty future and mints a fresh time whose future
  is empty, for a net change of zero.
* `densityRule` splits each maximal unfilled gap at most once, an argument about the *gap set*,
  which mentions neither `knownTimes` nor `incompPairs` nor any `witnessPresent` count.

Composing those into one measure that also survives the identification arm is open. The
identification arm is the specific obstruction: `ord.timeCount` is the quantity `untlNeg`'s cap is
stated against, and `TimeOrdering.identifyTime` can lower it — the same `maxTime`-lowering
mechanism the time-reuse verdict above turns on.

**Status: this phase is BLOCKED, and so is the concrete-instantiation discharge that depends on
it.** What is delivered instead is the accounting the residual was blocked on
(`applyRule_emitted_time_mem`, `applyRule_emitted_time_dichotomy`,
`unorderedSuccessor_time_dichotomy`, `knownTimes_card_le_succ_of_unorderedSuccessor`), the
satisfiability verdict on the residual as stated, the time-reuse verdict, and the two refutations
below that close off the repair routes a reader would try first. `MintPaysForTime` remains a named,
open hypothesis, retained verbatim; nothing in this file assumes it.

**Since this note was written, the fourth component has been attempted and decided.** The subsection
"The fourth measure component: the self-guard discharge potential" below builds the natural
candidate — a second defect ledger over `selfGuardRules ×ˢ U`, measured against each rule's own
discharge rather than against `ord.timeCount`, and therefore immune to the two routes the register
already refutes — and `mintPaysForTimeAt_reuse_false` decides it **false**, at every frame class and
every `Tmax`. So the paragraph above is now sharper than "open": the identification arm is not only
the obstruction to composing a measure in general, it defeats this composition specifically, through
the σ-hit route of the time-reuse verdict in a weakened *time-hit* form that escapes nothing.
Register entry 17 is the standing record, and the subsection "The density residual" below records
the one coordinate the verdict leaves untouched. `MintPaysForTime` is still a named, open
hypothesis, and is still assumed by nothing.

**And since *that* note was written, the verdict has been scoped and then overturned.** The
reorientation of the ordered split's identification arm (register entry 18) removed the σ-hit
configuration from the engine path, and the subsection "The self-guard component re-gated at the
oriented arm" below re-runs the gate at the renaming the oriented arm actually produces: the
component's potential falls where it previously did not, and the repaired predicate
`MintPaysForTimeStable` — the self-guard disjunct paired with a combined-budget conjunct, under a
σ-time-stability hypothesis the engine discharges — carries the four-component measure
`budgetPotentialAt` through both step lemmas and up to the two seed-level termini. So the paragraph
above is now sharper again, in the other direction: the identification arm is no longer the
obstruction, the σ-hit obligation is discharged rather than carried, and what remains open is the
**density** coordinate alone. `mintPaysForTimeAt_reuse_false` is untouched and stays true; it is a
statement about `MintPaysForTimeAt`, whose σ is tied to nothing. Register entry 19 is the standing
record, and `MintPaysForTime` — as literally stated — is still refuted, still named, and still
assumed by nothing. -/

/-- **One extra known time strictly raises the ordered rank**, whenever the smaller time count is
within the carried bound.

The base `Tmax * Tmax + 1` in `splitOrderedRank` is one more than `incompPairs`' range, and this is
that design fact used in the direction it was built for: a *rise* in the first component cannot be
absorbed by any fall in the second, exactly as a *fall* in the first cannot be absorbed by a rise.
`splitOrderedRank_le` is the range statement it rests on. -/
theorem splitOrderedRank_lt_of_knownTimes_lt {Tmax : Nat} {b nb : Branch}
    {ord ord' : TimeOrdering}
    (hT : b.knownTimes.toFinset.card ≤ Tmax)
    (hlt : b.knownTimes.toFinset.card < nb.knownTimes.toFinset.card) :
    splitOrderedRank Tmax b ord < splitOrderedRank Tmax nb ord' := by
  have hip : (incompPairs b ord).card ≤ Tmax * Tmax :=
    le_trans (incompPairs_card_le b ord) (Nat.mul_le_mul hT hT)
  simp only [splitOrderedRank]
  have h1 : b.knownTimes.toFinset.card + 1 ≤ nb.knownTimes.toFinset.card := hlt
  have h2 : (b.knownTimes.toFinset.card + 1) * (Tmax * Tmax + 1)
      ≤ nb.knownTimes.toFinset.card * (Tmax * Tmax + 1) := Nat.mul_le_mul_right _ h1
  rw [Nat.add_mul, one_mul] at h2
  omega

/-- **Dropping disjunct 1's cardinality conjunct does not repair `MintPaysForTime`.**

The weakened predicate is spelled out inline rather than given a name, because a repaired predicate
that is itself false must not be landed as a definition for a later reader to pick up. It is
`MintPaysForTime` with disjunct 1's first conjunct removed — the narrowing the satisfiability
verdict pointed at — and it is false at the *same* configuration, at every frame class, for every
`Tmax ≥ 3`.

The `3` is not arbitrary: it is the witness branch's time count, and the hypothesis is exactly what
`splitOrderedRank_lt_of_knownTimes_lt` needs. Any `Tmax` too small to bound the witness's own times
is one the terminus could not have been instantiated at. -/
theorem mintPaysForTime_rank_repair_false (fc : FormalSystem.ProofSystem.FrameClass)
    {Tmax : Nat} (hT : 3 ≤ Tmax) :
    ¬ (∀ (σ : SignedFormula → SignedFormula) (b : Branch) (ord : TimeOrdering)
         (tr : EventualityTracker), RunInvariant b ord →
         (∀ x ∈ b, x ∈ mintWitnessUniverse) →
         ∀ nb ∈ unorderedSuccessorBranches (expandOnceUnblocked b ord fc tr).1,
           splitOrderedRank Tmax nb (expandOnceUnblocked b ord fc tr).2
               ≤ splitOrderedRank Tmax b ord
           ∨ (mintTimeBudget mintWitnessUniverse σ nb (expandOnceUnblocked b ord fc tr).2
                 ≤ mintTimeBudget mintWitnessUniverse σ b ord ∧
              mintPotential mintWitnessUniverse σ nb (expandOnceUnblocked b ord fc tr).2
                 < mintPotential mintWitnessUniverse σ b ord)) := by
  intro h
  have hcard : mintWitnessBranch.knownTimes.toFinset.card ≤ Tmax := by
    have h3 : mintWitnessBranch.knownTimes.toFinset.card = 3 := by decide
    omega
  have hgrow : mintWitnessBranch.knownTimes.toFinset.card
      < mintWitnessSucc.knownTimes.toFinset.card := by decide
  have key := h id mintWitnessBranch mintWitnessOrd EventualityTracker.empty
    mintWitness_runInvariant mintWitness_confined
  cases fc <;>
    [ (rcases key mintWitnessSucc (by decide) with h1 | ⟨-, h3⟩);
      (rcases key mintWitnessSucc (by decide) with h1 | ⟨-, h3⟩);
      (rcases key mintWitnessSucc (by decide) with h1 | ⟨-, h3⟩);
      (rcases key mintWitnessSucc (by decide) with h1 | ⟨-, h3⟩)] <;>
    first
      | exact absurd h1 (Nat.not_le.mpr (splitOrderedRank_lt_of_knownTimes_lt hcard hgrow))
      | exact absurd h3 (by decide)

/-! ### Verdict on the time-reuse sub-question

**Verdict: reuse is possible.** Decided, at a configuration the engine itself drives.

*The obligation, restated precisely.* `mintPotential_lt_of_mint` asks that the minting pair be
**σ-hit**: the formula the rule fires on must be `σ sf` for some `sf ∈ U`, where `σ` is the
composition of the `rhoSF`s of the ordered splits taken so far. `rhoSF src tgt` never lands on
`src` (`rhoSF_time_ne_src`), so σ's image omits exactly the times earlier identifications merged
away. The obligation is therefore: *a minting formula does not sit at a merged-away time.*

*The affirmative direction fails.* The available facts about identification are
`src_not_mem_knownTimes_identifyTime` (the retired time leaves `knownTimes`) and
`knownTimes_card_lt_identifyTime` (the count strictly drops). Neither says anything about
`Branch.maxTime`, and `Branch.nextTime` is `maxTime + 1`. When the retired time is the branch's
largest, `maxTime` drops with it and the next fresh time lands *back on the retired value*.
`nextTime_reissues_retired_time` decides exactly that: `firstIncomparablePair` selects `(0, 2)` on
a three-time branch, `2` leaves `knownTimes`, and the post-identification `nextTime` is `2` again.

*And the engine drives it.* `reuse_driven_through_engine` decides that two `expandOnceUnblocked`
steps after the identification, the branch carries time `2` once more. So this is not a
configuration reachable only by hand-assembling a `Branch`; it is on a run.

*The consequence for the measure.* `mint_not_in_rhoSF_image` is the σ-hit failure stated directly:
a formula minted at `b.nextTime`, when that value is the retired `src`, is in the image of no
`rhoSF src tgt`. The hypothesis of `mintPotential_lt_of_mint` is therefore not discharged — it is
**false** at this step — and Phase 7's repair must carry it structurally rather than discharge it.

*The live-times reformulation carries the identical obligation, verified rather than asserted.*
That reformulation filters additionally on the formula's time being a fixed point of `σ`. But
`rho_src_ne_src` says `src` is not a fixed point of `rho src tgt`, and the re-issued time **is**
`src`. So the extra filter excludes the re-minted formula for precisely the reason the image
condition does, and defeating one defeats the other. The obstruction is intrinsic to
identification-plus-`maxTime`, not to this measure's shape. -/

/-- The renaming never fixes the time it retires. One line, and the whole σ-hit story rests on it. -/
theorem rho_src_ne_src {src tgt : TimeIndex} (h : tgt ≠ src) : rho src tgt src ≠ src := by
  simp [rho, h]

/-- **`rhoSF src tgt`'s image omits the time `src` entirely.** Everything at `src` is moved to
`tgt`, and everything else keeps a time that was not `src` to begin with. This is why σ's image
omits exactly the merged-away times. -/
theorem rhoSF_time_ne_src {src tgt : TimeIndex} (h : tgt ≠ src) (sf : SignedFormula) :
    (rhoSF src tgt sf).label.time ≠ src := by
  simp only [rhoSF, rho]
  by_cases hc : sf.label.time = src <;> simp [hc, h]

/-- **The σ-hit failure, stated directly.** If the branch's next fresh time *is* the time an
earlier identification retired, then nothing the rule mints there lies in the renaming's image —
so `mintPotential_lt_of_mint`'s hypothesis is false, not merely unproved, at that step. -/
theorem mint_not_in_rhoSF_image {src tgt : TimeIndex} (h : tgt ≠ src) {b : Branch}
    (hnext : b.nextTime = src) {g : SignedFormula} (hg : g.label.time = b.nextTime)
    (sf : SignedFormula) : rhoSF src tgt sf ≠ g := by
  intro heq
  exact rhoSF_time_ne_src h sf (by rw [heq, hg, hnext])

/-- **The retired time comes back.** `firstIncomparablePair` selects `(0, 2)` here, so the
identification arm merges the branch's *largest* time away; `Branch.maxTime` drops from `2` to `1`
and `Branch.nextTime` becomes `2` — the value just retired.

All six conjuncts are decided. The first three establish that this is a genuine ordered-split
trigger meeting both standing hypotheses, so the coincidence in the last three is attributable to
the arm rather than to a violated precondition — the same discipline
`ordTimes_identifyTime_arm3_false` uses. -/
theorem nextTime_reissues_retired_time :
    letI p : Formula := .atom ⟨"p", none⟩
    letI q : Formula := .atom ⟨"q", none⟩
    letI r : Formula := .atom ⟨"r", none⟩
    letI b : Branch := [⟨.pos, p, ⟨0, 0⟩⟩, ⟨.pos, q, ⟨0, 1⟩⟩, ⟨.pos, r, ⟨0, 2⟩⟩]
    letI ord : TimeOrdering := ⟨[(0, 1)]⟩
    IrreflOrd ord ∧ OrdTimesKnown b ord ∧
      firstIncomparablePair b ord = some (0, 2) ∧
      2 ∈ b.knownTimes ∧
      2 ∉ (b.identifyTime 2 0).knownTimes ∧
      (b.identifyTime 2 0).nextTime = 2 := by
  refine ⟨?_, ?_, by decide, by decide, by decide, by decide⟩
  · unfold IrreflOrd; decide
  · unfold OrdTimesKnown; decide

/-- One engine step along the first reported unordered successor. A witness helper, not part of
the development's interface — it exists so the continuation below is a closed term `decide` can
evaluate. -/
def reuseStep (s : Branch × TimeOrdering) : Option (Branch × TimeOrdering) :=
  let r := expandOnceUnblocked s.1 s.2 FormalSystem.ProofSystem.FrameClass.Base
    EventualityTracker.empty
  match unorderedSuccessorBranches r.1 with
  | [] => none
  | nb :: _ => some (nb, r.2)

/-- The branch of `nextTime_reissues_retired_time`. -/
def reuseWitnessBranch : Branch :=
  [⟨.pos, .atom ⟨"p", none⟩, ⟨0, 0⟩⟩, ⟨.pos, .atom ⟨"q", none⟩, ⟨0, 1⟩⟩,
   ⟨.pos, .atom ⟨"r", none⟩, ⟨0, 2⟩⟩]

/-- The ordering of `nextTime_reissues_retired_time`. -/
def reuseWitnessOrd : TimeOrdering := ⟨[(0, 1)]⟩

/-- The state of `nextTime_reissues_retired_time`, after the identification arm. -/
def reuseWitnessState : Branch × TimeOrdering :=
  (Branch.identifyTime reuseWitnessBranch 2 0, TimeOrdering.identifyTime reuseWitnessOrd 2 0)

/-- **The engine really does re-issue it.** Two `expandOnceUnblocked` steps after the
identification, time `2` is back on the branch. Decided.

This is what turns the coincidence above into a statement about *runs* rather than about
hand-assembled branches, and it is why the verdict is "reuse possible" rather than "open".

**This statement is UNCHANGED by the arm's reorientation, and that is not an oversight.** The plan
that reoriented arm 3 anticipated this `decide` flipping value and required an honest restatement
if it did. It did not flip, for a reason worth stating precisely rather than absorbing: `reuseStep`
is driven from `reuseWitnessState`, which is *hand-assembled* by a direct
`Branch.identifyTime reuseWitnessBranch 2 0` call and not by the engine's arm. What this theorem
decides is therefore conditional — *if* a run ever reaches a branch whose `maxTime` has fallen
below an index it once carried, the engine re-mints that index — and that conditional is as true
now as it was before. What the repair changes is whether the engine can *reach* such a branch:
`oriented_engine_does_not_produce_reuse` below decides that it no longer produces this one, and
`maxTime_monotone_along_run` proves it produces no other. Keeping this theorem at its original
value and adding the reachability statement beside it is the accurate record; re-tuning the witness
until the number moved would have destroyed exactly the conditional worth keeping. -/
theorem reuse_driven_through_engine :
    ((reuseStep reuseWitnessState).bind reuseStep).map
      (fun s => s.1.knownTimes.contains 2) = some true := by decide

/-- **…and the engine no longer produces the state it is conditional on.** The measurement
`reuse_driven_through_engine` cannot make, decided at the same witness.

`reuseWitnessState` is what arm 3 *used to* hand back here. Conjuncts 4 and 5 record that state's
numbers — `maxTime` fallen to `1`, `nextTime` back down to `2`, the retired index — and conjuncts 2
and 3 record what the arm now hands back instead: `maxTime` still `2`, `nextTime` `3`. Conjunct 1
pins the trigger, so the comparison is at the pair the engine itself selects rather than at a pair
chosen to make it come out right; the arm's `min 0 2` / `max 0 2` are written unevaluated for the
same reason, so the statement is read at the arm's own form. Conjunct 6 drives one further engine
step and finds `nextTime` still at `3`: nothing along the continuation recovers the retired value.

Together with `reuse_driven_through_engine` this is the whole of the repair at this witness: the
implication is untouched, and its antecedent is now unreachable. -/
theorem oriented_engine_does_not_produce_reuse :
    firstIncomparablePair reuseWitnessBranch reuseWitnessOrd = some (0, 2) ∧
      (Branch.identifyTime reuseWitnessBranch (min 0 2) (max 0 2)).maxTime = 2 ∧
      (Branch.identifyTime reuseWitnessBranch (min 0 2) (max 0 2)).nextTime = 3 ∧
      reuseWitnessState.1.maxTime = 1 ∧
      reuseWitnessState.1.nextTime = 2 ∧
      (reuseStep (Branch.identifyTime reuseWitnessBranch (min 0 2) (max 0 2),
          TimeOrdering.identifyTime reuseWitnessOrd (min 0 2) (max 0 2))).map
        (fun s => s.1.nextTime) = some 3 := by decide

/-! ### The fourth measure component: the self-guard discharge potential

The component the blocked-repair note above says is missing: a potential paying for the
**self-guarded** minting rules, measured against each rule's own discharge rather than against its
cap. `untlNeg` and `snceNeg` fire only when the trigger's forward (resp. backward) reach is empty,
and each arm's own `newOrd` makes that test fail at the next call. That is a defect ledger with its
own defect notion — deliberately *not* a widening of `mintPotential`'s, which is what closes it off
from the two routes the register already refutes. It is stated against `ord.futureOf` / `ord.pastOf`
emptiness and never against `ord.timeCount`, the quantity `TimeOrdering.identifyTime` lowers.

The subsection opens with a refute-first gate on the one exposure the design inherits and cannot
argue away in advance: the σ-hit obligation. -/

/-- **The two self-guarded time-minting rules**, as a `Finset`, so the potential's index set is a
product in the shape `mintPotential` already uses.

This is deliberately **not** `freshTimeRules` and **not** a widening of `freshLabelRules`. Widening
`mintPotential`'s index set to `freshTimeRules` is the route the do-not-re-attempt register closes
with `witnessPresent_eq_false_of_not_freshLabel`: the added columns are permanently `false`, so the
wider potential is the narrower one plus a constant. This index set carries a **different** cured/
uncured predicate (`selfGuardDischarged`, below), so it is a second ledger rather than a wider
first one.

`densityRule` is excluded on purpose. Its termination argument is about the *gap set*, is quadratic
in `|U|`, and is gated on `denseRules`; it is the right second component and is a named residual,
not a member of this list. -/
def selfGuardRules : Finset TableauRule :=
  {TableauRule.untlNeg, TableauRule.snceNeg}

/-- There are exactly two, decided rather than counted by hand. -/
theorem selfGuardRules_card : selfGuardRules.card = 2 := by decide

/-- **The self-guard's own discharge test**, transcribed from each rule's own firing guard in
inverted polarity.

`untlNeg`'s ACTIVE arm fires only when `timeOrd.futureOf l.time` is empty, and `snceNeg`'s only when
`timeOrd.pastOf l.time` is. So "the defect is already cured at this column" is exactly
*non*-emptiness of that reach — the rule cannot fire there again.

**The catch-all is `true`, the mirror image of `witnessPresent`'s polarity, and this is the design
decision that separates this component from the refuted re-indexing route.** A rule outside the
index set reports `true` here, so its column is permanently *cured* and contributes `0` to the
count; under `witnessPresent`'s polarity the out-of-range arms report `false` and contribute a
permanent positive constant, which is precisely why
`witnessPresent_eq_false_of_not_freshLabel` kills that route. The catch-all is unreachable from
`selfGuardPotential` anyway, since the index set's left factor is exactly the two named rules
(`mem_selfGuardRules`); the polarity choice is what makes any future widening harmless rather than
inert.

`ord.timeCount` is deliberately absent. It is the second conjunct of both arms' guards, and it is
the quantity `TimeOrdering.identifyTime` can lower; measuring the discharge rather than the cap is
what this component is for. -/
def selfGuardDischarged (r : TableauRule) (sf : SignedFormula) (ord : TimeOrdering) : Bool :=
  match r with
  | .untlNeg => !(ord.futureOf sf.label.time).isEmpty
  | .snceNeg => !(ord.pastOf sf.label.time).isEmpty
  | _ => true

/-- **The self-guard potential**: the number of `(rule, formula)` pairs drawn from the fixed index
set `selfGuardRules ×ˢ U` whose self-guard is **not** yet discharged, with the formula carried
through the accumulated renaming `σ`.

It deliberately does **not** take a `Branch`. The self-guard is a property of the ordering alone,
so the branch-growth half of `mintPotential`'s monotonicity has no analogue here and no branch-side
hypothesis is needed at any call site.

`σ` is the composition of the `rhoSF`s of the ordered splits taken so far, exactly as in
`mintPotential`; carrying it keeps the index set fixed across the whole run. -/
def selfGuardPotential (U : Finset SignedFormula) (σ : SignedFormula → SignedFormula)
    (ord : TimeOrdering) : Nat :=
  ((selfGuardRules ×ˢ U).filter (fun p => selfGuardDischarged p.1 (σ p.2) ord = false)).card

/-- **The repaired time-minting residual**: `MintPaysForTime`'s body verbatim, with a **third**
disjunct added and nothing removed.

Nothing is dropped, so the implication runs `MintPaysForTime → MintPaysForTimeAt` and never the
other way; the converse is refuted by `mintPaysForTime_untlNeg_false` at a `U` where the weaker
form was intended to hold. This is the `universeClosedAt_of_universeClosed` idiom.

The third disjunct is the self-guard coordinate: a self-guarded minting step is paid for by
discharging its own guard, which is invisible to both existing disjuncts — the mint raises
`knownTimes` (killing disjunct 1's first conjunct) and `untlNeg` / `snceNeg` are not in
`freshLabelRules` (so `mintPotential` does not move at all).

**Verdict on this predicate at the σ-hit hazard: see `mintPaysForTimeAt_reuse_false` below. It is
false there, for the same reason `MintPaysForTime`'s second disjunct is.** The definition is landed
anyway, and named, because the refutation has to be *stated about something*; it is not offered as
a working repair.

**Obligation map — the density coordinate is a second, independent gap.** Even setting the σ-hit
verdict aside, this predicate carrying only the `selfGuardPotential` disjunct is separately
refutable at `.Dense` / `.RTime` by a `densityRule` vehicle: `densityRule` returns `.persistent`
(`Tableau.lean:1387`), which `expandOnceUnblocked` maps to `.extended`, so
it is inside this predicate's scope, and it mints a fresh time while lying outside **both**
`freshLabelRules` and `selfGuardRules` — no disjunct moves at all. The intended component is
`gapPotential`, indexed by `U ×ˢ U` and gated on `denseRules`; it is a **named residual**,
implemented nowhere and assumed by nothing. See the subsection "The density residual" following
`mintPaysForTimeAt_reuse_false`, and register entry 17. -/
def MintPaysForTimeAt (fc : FormalSystem.ProofSystem.FrameClass) (U : Finset SignedFormula)
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
      ∨ selfGuardPotential U σ (expandOnceUnblocked b ord fc tr).2
          < selfGuardPotential U σ ord

/-! #### The gate: the σ-hit obligation, inherited in weakened form and still false

The time-reuse verdict decides that σ's image omits the times earlier identifications merged away,
and that the engine re-issues exactly those times. `mintPotential_lt_of_mint` needs the minting
formula to be **σ-hit** — literally `σ sf` for some `sf ∈ U` — and `mint_not_in_rhoSF_image`
refutes that at the re-issue configuration.

`selfGuardPotential` inherits the obligation in a *weaker* form. Its columns are indexed by the
σ-image's **time**, not by the σ-image formula, so it needs only a *time* hit: some `sf ∈ U` with
`(σ sf).label.time` equal to the trigger's time. The question this gate decides is whether that
weakening escapes the refutation.

**It does not, and the reason is one line.** `rhoSF_time_ne_src` is already a statement about
*times*: `(rhoSF src tgt sf).label.time ≠ src`, for every `sf` whatsoever. The formula-hit
refutation was derived from it (`mint_not_in_rhoSF_image` is three lines on top of it), so the
time-hit weakening cannot escape what the formula-hit failure was a corollary of. -/

/-- **No column of `selfGuardPotential`'s index set is indexed at a retired time.**

The general half of the gate, and the reason the concrete configuration below is not a lucky
choice. The ACTIVE arm of `untlNeg` cures its trigger's column by adding `(l.time, freshTime)` to
the ordering, so the only column that arm can flip is the one at `l.time`. When `l.time` is a time
an earlier identification retired — which the time-reuse verdict decides the engine re-issues —
`rhoSF_time_ne_src` says no column lives there at all. Nothing flips, so nothing drops.

This is `mint_not_in_rhoSF_image`'s obligation stated one level weaker and still unmet: weakening
a formula hit to a time hit gains nothing, because the refutation was a time-level fact to begin
with. -/
theorem selfGuard_no_column_at_retired_time {src tgt : TimeIndex} (h : tgt ≠ src)
    (U : Finset SignedFormula) :
    ∀ p ∈ selfGuardRules ×ˢ U, ((rhoSF src tgt) p.2).label.time ≠ src :=
  fun p _ => rhoSF_time_ne_src h p.2

/-- The gate's trigger: `F(U(e,g))` at the **re-issued** time `2`. Same formula shape as
`mintWitnessTrigger`; the label's time is what differs, and it is the whole point. -/
def gateTrigger : SignedFormula := SignedFormula.neg (Formula.untl mwG mwE) ⟨0, 2⟩

/-- The gate branch. The trigger sits at the re-issued time `2`; the two atoms carry times `0` and
`1`, which the ordering's one constraint mentions and `OrdTimesKnown` therefore requires. Atoms fire
no rule, so nothing pre-empts the trigger. -/
def gateBranch : Branch :=
  [gateTrigger, SignedFormula.pos mwP ⟨0, 0⟩, SignedFormula.pos mwQ ⟨0, 1⟩]

/-- The gate ordering. It is `TimeOrdering.identifyTime reuseWitnessOrd 2 0` on the nose — the
ordering the identification arm of `nextTime_reissues_retired_time` leaves behind (the retired time
`2` appears in no constraint, so the substitution is a no-op there). `futureOf 2` is empty and
`timeCount` is `2`, which is exactly `untlNeg`'s ACTIVE guard. -/
def gateOrd : TimeOrdering := ⟨[(0, 1)]⟩

/-- The gate universe: the branch itself, so confinement is immediate. -/
def gateUniverse : Finset SignedFormula :=
  {gateTrigger, SignedFormula.pos mwP ⟨0, 0⟩, SignedFormula.pos mwQ ⟨0, 1⟩}

/-- The first arm of the split the ACTIVE `untlNeg` reports: `F(e)` at the freshly minted time `3`,
the re-included trigger, and the original branch. -/
def gateSucc : Branch :=
  [SignedFormula.neg mwE ⟨0, 3⟩, gateTrigger, gateTrigger,
   SignedFormula.pos mwP ⟨0, 0⟩, SignedFormula.pos mwQ ⟨0, 1⟩]

/-- The ordering after the ACTIVE arm: `addFuture 2 3` prepended. This is the edge that is supposed
to cure the trigger's column. -/
def gateNewOrd : TimeOrdering := ⟨[(2, 3), (0, 1)]⟩

/-- **The run-realizable renaming.** `rhoSF 2 0` is the σ the identification `2 → 0` itself
produces, not a σ chosen to make the refutation work. Refuting a σ-mediated potential with a σ
unconstrained by the run is worthless — a hostile σ defeats every such potential and teaches
nothing — so the gate uses the *most favorable available* σ, the discipline
`mintPaysForTime_untlNeg_false` sets by using `id`. -/
def gateSigma : SignedFormula → SignedFormula := rhoSF 2 0

/-- The gate state satisfies the run invariant. -/
theorem gate_runInvariant : RunInvariant gateBranch gateOrd := by
  constructor
  · unfold IrreflOrd gateOrd; decide
  · unfold OrdTimesKnown; decide

/-- …and it is confined to the gate universe. -/
theorem gate_confined : ∀ x ∈ gateBranch, x ∈ gateUniverse := by decide

/-- **The gate configuration really is the re-issue hazard.** Seven conjuncts, all decided, in the
discipline `nextTime_reissues_retired_time` uses: without them a negative verdict below would be
attributable to a violated precondition rather than to the arm.

1-2. the standing hypotheses hold at the gate state;
3. `firstIncomparablePair` selects `(0, 2)` on the predecessor state, so the identification that
   produces `gateSigma = rhoSF 2 0` is the one the engine itself takes;
4. time `2` really is retired by it;
5. …and really is re-issued: the post-identification `nextTime` is `2` again;
6. the gate ordering is exactly what that identification leaves behind;
7. the trigger sits at the re-issued time and `untlNeg`'s ACTIVE guard is met there — empty forward
   reach, with `timeCount` inside the `(0, 4)` window. -/
theorem gate_is_reissue_hazard :
    IrreflOrd gateOrd ∧ OrdTimesKnown gateBranch gateOrd ∧
      firstIncomparablePair reuseWitnessBranch reuseWitnessOrd = some (0, 2) ∧
      2 ∉ (Branch.identifyTime reuseWitnessBranch 2 0).knownTimes ∧
      (Branch.identifyTime reuseWitnessBranch 2 0).nextTime = 2 ∧
      gateOrd.constraints = (TimeOrdering.identifyTime reuseWitnessOrd 2 0).constraints ∧
      (gateTrigger.label.time = 2 ∧ (gateOrd.futureOf 2).isEmpty = true ∧
        0 < gateOrd.timeCount ∧ gateOrd.timeCount < 4) := by
  refine ⟨?_, ?_, by decide, by decide, by decide, by decide, by decide, by decide, by decide,
    by decide⟩
  · unfold IrreflOrd gateOrd; decide
  · unfold OrdTimesKnown; decide

/-- **The engine fires the ACTIVE arm here**, at every frame class: the reported ordering is
`gateNewOrd` and `gateSucc` is one of the two unordered successors. `untlNeg` is a `carrierBase`
rule, so this is not a frame-class accident.

**Unchanged by the arm's reorientation**, for the reason `oriented_gate_invariants` conjunct 7
already decides: the gate's trigger is `some (2, 0)`, so `min 2 0 = 0` and `max 2 0 = 2`, and the
oriented arm and the unoriented one are *literally the same list* at this configuration. Nothing at
the gate is evidence for the mechanism, and nothing at the gate regresses under it — which is why
the reuse witness, where the two orientations genuinely differ, is the configuration that carries
the verdict. -/
theorem gate_step_fires (fc : FormalSystem.ProofSystem.FrameClass) :
    (expandOnceUnblocked gateBranch gateOrd fc EventualityTracker.empty).2.constraints
        = gateNewOrd.constraints ∧
      gateSucc ∈ unorderedSuccessorBranches
        (expandOnceUnblocked gateBranch gateOrd fc EventualityTracker.empty).1 := by
  cases fc <;> exact ⟨by decide, by decide⟩

/-- **The component is not inert: with `σ = id` the self-guard potential does drop**, `4` to `3`, at
exactly this step. The trigger's own column at time `2` flips uncured → cured, which is the whole
mechanism `selfGuardPotential` was designed around.

This is the discriminating measurement. It is what makes the refutation below a statement about the
**σ-hit obligation** rather than about the component failing to move at all — the distinction that
separates a located obstruction from an unexamined one. -/
theorem selfGuardPotential_lt_at_gate_with_id :
    selfGuardPotential gateUniverse id gateNewOrd
      < selfGuardPotential gateUniverse id gateOrd := by decide

/-- **…and with the run-realizable `σ` it does not.** `4 → 3` becomes `3 → 3`. The column that
flipped under `id` was the trigger's own, indexed at time `2`; under `gateSigma = rhoSF 2 0` no
column is indexed there at all (`selfGuard_no_column_at_retired_time`), so the curing edge
`(2, 3)` that the ACTIVE arm adds lands outside the index set. -/
theorem selfGuardPotential_eq_at_gate_with_sigma :
    selfGuardPotential gateUniverse gateSigma gateNewOrd
      = selfGuardPotential gateUniverse gateSigma gateOrd := by decide

/-- **VERDICT: `MintPaysForTimeAt` is FALSE.** At every frame class and every `Tmax`, at the
configuration the time-reuse verdict identifies as the σ-hit hazard, with the most favorable
run-realizable renaming.

*The verdict in words.* The self-guard discharge potential does **not** repair the time-minting
residual. The σ-hit obligation that the time-reuse verdict decides false for `mintPotential` is
inherited by `selfGuardPotential` in a weakened *time-hit* form, and **the weakening does not
escape it.** `mint_not_in_rhoSF_image` is a corollary of `rhoSF_time_ne_src`, which is already a
statement about times, so relaxing "the minting formula is `σ sf`" to "the minting formula's *time*
is `(σ sf)`'s time" relaxes nothing that the refutation depended on.

*How all three disjuncts fail here.* The step mints time `3`, so `knownTimes` goes from `3` to `4`
and disjunct 1's first conjunct `4 ≤ 3` is false. `mintTimeBudget` goes from `27` to `28` and
`mintPotential` is `24` both before and after — `untlNeg` is not in `freshLabelRules` — so both of
disjunct 2's conjuncts are false. And `selfGuardPotential` is `3` both before and after, so
disjunct 3's `3 < 3` is false.

*Why this is a real refutation and not a measurement artifact.* Three things are established
separately rather than assumed. `gate_is_reissue_hazard` decides all seven preconditions, so the
failure is attributable to the arm and not to a violated hypothesis.
`selfGuardPotential_lt_at_gate_with_id` decides that the component **does** drop at this very step
under `σ = id`, so the component is not inert and the failure is located precisely at σ.
And `selfGuard_no_column_at_retired_time` gives the general reason — no configuration escapes it,
because the obstruction is the renaming's image omitting the retired time, which holds for every
`U`, every trigger and every retired time.

*Consequence.* The self-guard coordinate is not the missing fourth measure component, and the
obstruction is not this component's shape: it is intrinsic to identification-plus-`maxTime`, the
same conclusion the live-times reformulation reaches. See register entry 17. -/
theorem mintPaysForTimeAt_reuse_false (fc : FormalSystem.ProofSystem.FrameClass) (Tmax : Nat) :
    ¬ MintPaysForTimeAt fc gateUniverse Tmax := by
  intro h
  have key := h gateSigma gateBranch gateOrd EventualityTracker.empty
    gate_runInvariant gate_confined
  cases fc <;>
    [ (rcases key gateSucc (by decide) with ⟨h1, -⟩ | ⟨h2, -⟩ | h3);
      (rcases key gateSucc (by decide) with ⟨h1, -⟩ | ⟨h2, -⟩ | h3);
      (rcases key gateSucc (by decide) with ⟨h1, -⟩ | ⟨h2, -⟩ | h3);
      (rcases key gateSucc (by decide) with ⟨h1, -⟩ | ⟨h2, -⟩ | h3)] <;>
    first
      | exact absurd h1 (by decide)
      | exact absurd h2 (by decide)
      | exact absurd h3 (by decide)

/-! #### The density residual: `gapPotential`, unattempted rather than refuted

Recorded immediately after the verdict because the verdict closes the **self-guard** coordinate and
would otherwise leave a reader believing the whole fourth-component question closed with it. It is
not. This subsection states precisely which coordinate remains, why it is a separate clause rather
than another disjunct fitted to the same ledger, and that nothing here is implemented or assumed.

*The exposure the verdict does not cover.* `MintPaysForTimeAt` carrying only the
`selfGuardPotential` disjunct is separately refutable at `.Dense` / `.RTime` by a `densityRule`
vehicle, on grounds that have nothing to do with the σ-hit hazard. `densityRule` is inside the
predicate's scope — it returns `.persistent` (`Tableau.lean:1387`), which `expandOnceUnblocked` maps
to `.extended` — and it mints a fresh time while sitting outside **both**
`freshLabelRules` and `selfGuardRules`. So a `densityRule` step moves no disjunct of the predicate
at all, at any `U`, independently of everything above. `freshTimeRules_incomparable_freshLabelRules`
is the census fact that puts it outside the first list; `selfGuardRules` excludes it by construction.

*The intended component, named so that its absence is legible.* `gapPotential`, indexed by `U ×ˢ U`
rather than by `selfGuardRules ×ˢ U`. The index shape is forced by the rule's own argument:
`densityRule` splits each *maximal unfilled gap* at most once, and a gap is a **pair**, so the
ledger transcribes the rule's own `gapTargets` filter (`Tableau.lean:1366-1366`) —
`(timeOrd.futureOf t').isEmpty`, together with `t'` lying below no other future time of the trigger
— rather than any per-rule discharge test. It is therefore quadratic in `|U|` where
`selfGuardPotential` is linear, and it is gated on `denseRules` (`Tableau.lean:1595`), so it
contributes nothing at `.Base` / `.ZTime`.

*That it has to be a separate clause is not this development's invention.* In the mosaic
decidability argument whose residual structure this file follows, density is `(SVDns)`, listed among
the *additional vertical saturation conditions* and kept apart from the eventuality conditions the
other clauses discharge (Caleiro–Viganò–Volpe 2013, §3.1). The separation is the source's. The
pair-indexing conclusion is independently forced by `densityRule`'s own docstring in any case, so
nothing here rests on the citation alone.

**Nothing of `gapPotential` is implemented in this file, and no theorem in this file assumes it.**
It is named so that a reader arriving at the verdict above can tell which coordinate is *refuted*
and which is merely *untried*; see register entry 17. Refuting the self-guard coordinate says
nothing about this one in either direction. -/

end FormalSystem.Metalogic.Decidability
