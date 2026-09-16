/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.Verified.Termination.MintBound.SigmaFixed

/-! # C12. The post-blocking settlement residual: refuted, and repaired

`PostBlockingSettles fc` (section C8) is the last settlement residual on the terminus, and its own
docstring names an open question: whether the gap between what `saturateBlocked` stops at and what
`findUnexpandedUnblockedWith` tests "can be closed by fuel alone". This section decides that
question — the answer is **no** — and lands the repair.

The two tests disagree, and the disagreement has nothing to do with fuel:

* `saturateBlocked` stops at `expandOnceNoFresh`'s `.saturated` verdict (`Saturation.lean`, the
  `(.saturated, _)` arm), and `expandOnceNoFresh` **skips** any candidate whose applicable rule
  mints a fresh label or lengthens the ordering constraints — its `pick` returns `none` for such a
  candidate and the search continues past it.
* `findUnexpandedUnblockedWith` tests `!isExpanded sf b ord fc`, i.e.
  `findApplicableRule sf b ord fc ≠ none`, with **no** reference to label-minting at all.

So a formula sitting at an unblocked time whose only applicable rule mints a fresh label is
invisible to the first test and visible to the second, at **every** fuel figure. That is the
refutation, and it is what the two theorems below decide.
-/

namespace FormalSystem.Metalogic.Decidability

open FormalSystem.Syntax

section PostBlockingSettlesRefutation

/-- **`saturateBlocked` at `fuel = 0` returns its input unchanged**, at every branch, ordering and
frame class. This is the `| 0 => some (.inr (b, timeOrd))` arm of `Saturation.lean`'s definition,
recorded here as a named fact because both refutations below run through it. -/
theorem saturateBlocked_fuel_zero (b : Branch) (ord : TimeOrdering)
    (fc : FormalSystem.ProofSystem.FrameClass) :
    saturateBlocked b 0 ord fc = some (.inr (b, ord)) := by
  rw [saturateBlocked]

/-- **The `fuel = 0` half of the witness**: nothing is blocked at the empty ordering, the branch's
one formula has `.impNeg` applicable, so the blocking-aware finder reports it. -/
theorem findUnexpandedUnblockedWith_multBranch_one
    (fc : FormalSystem.ProofSystem.FrameClass) :
    findUnexpandedUnblockedWith (multBranch 1) TimeOrdering.empty fc
        (blockedTimes (multBranch 1) TimeOrdering.empty fc (armTracker (multBranch 1)))
      = some multWitness := by
  have hrule := findApplicableRule_multWitness (multBranch 1) (pos_not_mem_multBranch 1) fc
  rw [blockedTimes_empty]
  have hb : multBranch 1 = multWitness :: ([] : Branch) := by
    simp [multBranch, List.replicate]
  simp only [findUnexpandedUnblockedWith, isExpanded]
  rw [hb, List.find?_cons]
  simp only [← hb, hrule, Option.isNone_some, List.contains_nil, Bool.not_false, Bool.and_true]

/-- **Gate 1: `PostBlockingSettles fc` is refuted at the `fuel = 0` arm**, at every frame class.

Not merely unproved: false. `saturateBlocked` at `fuel = 0` hands its input straight back
(`saturateBlocked_fuel_zero`), so the predicate's hypothesis is satisfied at **every** branch
whatsoever, and the predicate as literally stated therefore asserts that every branch is
blocking-aware saturated. The one-formula branch `[F(p → q)@⟨0,0⟩]` — the landed `multBranch 1`,
reused rather than rebuilt — is not: `.impNeg` applies to its only formula
(`findApplicableRule_multWitness`), nothing is blocked at the empty ordering
(`blockedTimes_empty`), so the finder reports that formula.

**What this does not show.** It is a statement about the `fuel = 0` arm alone, and it settles
nothing about larger fuel: a reader could reasonably suspect the predicate is one `fuel > 0` side
condition away from being true. `postBlockingSettles_fuel_gap_false` is the theorem that closes that
suspicion, and it is the substantive one. -/
theorem postBlockingSettles_fuel_zero_false (fc : FormalSystem.ProofSystem.FrameClass) :
    ¬ PostBlockingSettles fc := by
  intro h
  have hfind := h (multBranch 1) TimeOrdering.empty 0 (multBranch 1) TimeOrdering.empty
    (saturateBlocked_fuel_zero _ _ _)
  rw [findUnexpandedUnblockedWith_multBranch_one fc] at hfind
  exact absurd hfind (by simp)


/-- **The fuel-universal step.** If the branch is not closed and `expandOnceNoFresh` reports
`.saturated` on it, then `saturateBlocked` hands the branch straight back at **every** fuel figure.

No induction is needed and none is used: at `fuel = 0` the pass returns its input by definition, and
at `fuel + 1` it reaches the `(.saturated, _)` arm in one step, whose result is again the input. The
two `constraints.length` rejection guards and the three recursive arms are therefore not on this
branch's path at all, which is what makes the statement universal in `fuel` rather than a ladder of
checked figures. -/
theorem saturateBlocked_eq_self_of_noFresh_saturated
    {b : Branch} {ord ord' : TimeOrdering} {fc : FormalSystem.ProofSystem.FrameClass}
    (hcl : findClosure b fc = none)
    (hsat : expandOnceNoFresh b ord fc = (ExpansionResult.saturated, ord')) (fuel : Nat) :
    saturateBlocked b fuel ord fc = some (.inr (b, ord)) := by
  cases fuel with
  | zero => exact saturateBlocked_fuel_zero b ord fc
  | succ n => rw [saturateBlocked, hcl, hsat]

/-- The witness branch is open: one `.neg`-signed box between atoms closes nothing, at every frame
class. `checkBotPos` and `checkContradiction` do not read the frame class at all, and
`checkAxiomNeg`'s `matchAxiom` does not recognise `□p` as an axiom instance, so the
`witness.minFrameClass ≤ fc` test is never reached. -/
theorem findClosure_freshWorldBranch (fc : FormalSystem.ProofSystem.FrameClass) :
    findClosure freshWorldBranch fc = none := rfl

/-- **`expandOnceNoFresh` reports `.saturated` on the witness branch, at every frame class.**

Its `pick` runs `findApplicableRule` at the branch's one formula, gets `.boxNeg`
(`findApplicableRule_freshWorldWitness`), and `ruleMintsFreshLabel .boxNeg = true`, so the **first**
rejection test fires and `pick` returns `none` — the candidate is skipped rather than reported. The
branch has nothing else, so the search ends with no pick and the verdict is `.saturated`.

This is the exact disagreement the residual's docstring names, exhibited: there is outstanding work
on the branch, and this pass is by construction unable to see it. -/
theorem expandOnceNoFresh_freshWorldBranch (fc : FormalSystem.ProofSystem.FrameClass) :
    expandOnceNoFresh freshWorldBranch TimeOrdering.empty fc
      = (ExpansionResult.saturated, TimeOrdering.empty) := by
  have hrule := findApplicableRule_freshWorldWitness fc
  simp only [freshWorldBranch] at hrule
  have hmint : ruleMintsFreshLabel TableauRule.boxNeg = true := rfl
  simp only [expandOnceNoFresh, freshWorldBranch, List.findSome?_cons, List.findSome?_nil, hrule,
    hmint, if_true]

/-- **The blocking-aware finder does see it**, at every frame class: nothing is blocked at the empty
ordering, and `.boxNeg` applies, so `isExpanded` is `false` at the branch's one formula. -/
theorem findUnexpandedUnblockedWith_freshWorldBranch
    (fc : FormalSystem.ProofSystem.FrameClass) :
    findUnexpandedUnblockedWith freshWorldBranch TimeOrdering.empty fc
        (blockedTimes freshWorldBranch TimeOrdering.empty fc (armTracker freshWorldBranch))
      = some freshWorldWitness := by
  have hrule := findApplicableRule_freshWorldWitness fc
  simp only [freshWorldBranch] at hrule
  rw [blockedTimes_empty]
  simp only [findUnexpandedUnblockedWith, isExpanded, freshWorldBranch, List.find?_cons, hrule,
    Option.isNone_some, List.contains_nil, Bool.not_false, Bool.and_true]

/-- **The gap is exhibited at every fuel figure, simultaneously.**

Both halves at once, universally quantified in `fuel` and in the frame class: the post-blocking pass
returns the witness branch unchanged, and the saturation test it is measured against reports
outstanding work on that same branch. No fuel figure appears anywhere in either half, which is the
whole content of the verdict below. -/
theorem postBlockingSettles_gap_at_every_fuel
    (fc : FormalSystem.ProofSystem.FrameClass) (fuel : Nat) :
    saturateBlocked freshWorldBranch fuel TimeOrdering.empty fc
        = some (.inr (freshWorldBranch, TimeOrdering.empty)) ∧
      findUnexpandedUnblockedWith freshWorldBranch TimeOrdering.empty fc
          (blockedTimes freshWorldBranch TimeOrdering.empty fc (armTracker freshWorldBranch))
        = some freshWorldWitness :=
  ⟨saturateBlocked_eq_self_of_noFresh_saturated (findClosure_freshWorldBranch fc)
      (expandOnceNoFresh_freshWorldBranch fc) fuel,
    findUnexpandedUnblockedWith_freshWorldBranch fc⟩

/-- **Gate 2: fuel does not close the gap.** The verdict on the open question
`PostBlockingSettles`'s own docstring poses.

`PostBlockingSettles fc` is refuted at a **nonzero** fuel — so this is not a restatement of
`postBlockingSettles_fuel_zero_false` — and `postBlockingSettles_gap_at_every_fuel` records that the
same witness works at every fuel whatsoever, not at the figure chosen here.

**The verdict, in one line.** Fuel does not close it, because `expandOnceNoFresh` *skips*
label-minting candidates while `findUnexpandedUnblockedWith` counts them, and no fuel figure appears
anywhere in that disagreement.

**What the witness is.** The landed `freshWorldBranch = [F(□p)@⟨0,0⟩]`, reused rather than rebuilt.
Its only applicable rule is `.boxNeg`, which mints a fresh **world**, so it trips
`expandOnceNoFresh`'s *first* rejection test (`ruleMintsFreshLabel`). Register entry 13 records that
the label-minting and time-minting rule lists are incomparable and that this is exactly why
`expandOnceNoFresh` runs two rejection tests in sequence; a time-minting witness would trip the
second test and refute the predicate the same way. -/
theorem postBlockingSettles_fuel_gap_false (fc : FormalSystem.ProofSystem.FrameClass) :
    ¬ PostBlockingSettles fc := by
  intro h
  obtain ⟨hsb, hfind⟩ := postBlockingSettles_gap_at_every_fuel fc 1
  rw [h freshWorldBranch TimeOrdering.empty 1 freshWorldBranch TimeOrdering.empty hsb] at hfind
  exact absurd hfind (by simp)


/-! ### The repaired predicate

Phase 2's witness locates the missing content at the **branch**, not at the fuel, so the repair
relocates exactly two hypotheses and changes the conclusion not at all. Both are stated about the
pass's **output** branch, which is where the settlement test is run.
-/

/-- **The pass ran to label-free saturation** rather than being truncated by fuel.

Stated as `(expandOnceNoFresh b ord fc).1 = .saturated` rather than as the pair equation
`expandOnceNoFresh b ord fc = (.saturated, ord)` the plan pre-declared. The narrowing is forced by
the frozen definition and is a *weakening* of the hypothesis, hence a strengthening of every
statement that assumes it: `expandOnceNoFresh`'s `.notApplicable` arm returns `(.saturated, newOrd)`
with the **picked** ordering rather than the incoming one, so the pair equation is strictly stronger
than the fact the settlement argument consumes, and `saturateBlocked`'s own `(.saturated, _)` arm
discards the second component too. -/
def LabelFreeSaturatedExit (b : Branch) (ord : TimeOrdering)
    (fc : FormalSystem.ProofSystem.FrameClass) : Prop :=
  (expandOnceNoFresh b ord fc).1 = ExpansionResult.saturated

/-- **No label-minting work is left sitting at an unblocked time.**

This is the disagreement Phase 2 exhibits, stated as a condition on the branch: every formula at an
unblocked time whose rule the engine finds applicable is one `expandOnceNoFresh` would have been
willing to fire — it neither mints a fresh label nor lengthens the ordering constraints. The witness
`freshWorldBranch` fails it at its one formula, which is exactly why it refutes the residual. -/
def NoUnblockedFreshWork (b : Branch) (ord : TimeOrdering)
    (fc : FormalSystem.ProofSystem.FrameClass) : Prop :=
  ∀ sf ∈ b, ¬ (blockedTimes b ord fc (armTracker b)).contains sf.label.time →
    ∀ rule result newOrd, findApplicableRule sf b ord fc = some (rule, result, newOrd) →
      ruleMintsFreshLabel rule = false ∧
        newOrd.constraints.length ≤ ord.constraints.length

/-- **The repaired residual**: `PostBlockingSettles`'s statement with the two conditions above added
as antecedents on the **output** branch. The conclusion is carried over verbatim — no test is
weakened, no finder is replaced, and the frame class stays universally quantified. -/
def PostBlockingSettlesAt (fc : FormalSystem.ProofSystem.FrameClass) : Prop :=
  ∀ (ob : Branch) (oOrd : TimeOrdering) (fuel : Nat) (satBr : Branch) (satOrd : TimeOrdering),
    saturateBlocked ob fuel oOrd fc = some (.inr (satBr, satOrd)) →
    LabelFreeSaturatedExit satBr satOrd fc →
    NoUnblockedFreshWork satBr satOrd fc →
    findUnexpandedUnblockedWith satBr satOrd fc
      (blockedTimes satBr satOrd fc (armTracker satBr)) = none

/-- **The direction, fixed.** The hypothesis list is longer, so `PostBlockingSettlesAt` is the
**weaker** predicate, so every theorem restated against it is a **strengthening** — the same
direction `universeClosedAt_of_universeClosed` and `mintPaysForTimeFixed_of_mintPaysForTimeStable`
record for their own repairs, and the reason register entry 7 exists. -/
theorem postBlockingSettlesAt_of_postBlockingSettles
    {fc : FormalSystem.ProofSystem.FrameClass} (h : PostBlockingSettles fc) :
    PostBlockingSettlesAt fc :=
  fun ob oOrd fuel satBr satOrd hsb _ _ => h ob oOrd fuel satBr satOrd hsb

/-! ### The gate: can the consuming sites supply the two antecedents?

The repair is admissible only if `armSettlement_of_postBlockingSettles`'s and
`buildTableauAt_isSome_of_settles`'s proofs can supply the relocated hypotheses where they consume
the residual. Both sites reach the residual holding exactly one fact about the output pair — the
equation `saturateBlocked ob fuel oOrd fc = some (.inr (satBr, satOrd))` — so the question is
whether `LabelFreeSaturatedExit satBr satOrd fc` follows from that equation.

It does not, and the obstruction is decided rather than described.
-/

/-- **`.impNeg` fires on the one-formula branch under the label-free filter too.** Its rule mints no
label and adds no ordering constraint, so `expandOnceNoFresh`'s `pick` accepts it and the verdict is
`.extended`, not `.saturated`. -/
theorem expandOnceNoFresh_multBranch_one (fc : FormalSystem.ProofSystem.FrameClass) :
    expandOnceNoFresh (multBranch 1) TimeOrdering.empty fc
      = (ExpansionResult.extended (multEmitted ++ multBranch 1), TimeOrdering.empty) := by
  have hrule := findApplicableRule_multWitness (multBranch 1) (pos_not_mem_multBranch 1) fc
  have hb : multBranch 1 = multWitness :: ([] : Branch) := by
    simp [multBranch, List.replicate]
  have hmint : ruleMintsFreshLabel TableauRule.impNeg = false := rfl
  conv_lhs => rw [expandOnceNoFresh]
  rw [hb, List.findSome?_cons]
  rw [← hb, hrule]
  simp only [hmint, if_false, TimeOrdering.empty, gt_iff_lt, lt_self_iff_false, if_false, hb]
  simp

/-- **The obstruction, decided.** `saturateBlocked`'s `.inr` exit does **not** carry
`LabelFreeSaturatedExit` on its output: at `fuel = 0` the pass hands back its input untested, and
that input can have label-free work outstanding. So the relocated hypothesis is not derivable from
what either consuming site holds, and it is a genuine residual rather than a side condition a bridge
proof could discharge.

Stated at every frame class, on the landed `multBranch 1` vehicle. -/
theorem labelFreeSaturatedExit_not_of_saturateBlocked_inr
    (fc : FormalSystem.ProofSystem.FrameClass) :
    saturateBlocked (multBranch 1) 0 TimeOrdering.empty fc
        = some (.inr (multBranch 1, TimeOrdering.empty)) ∧
      ¬ LabelFreeSaturatedExit (multBranch 1) TimeOrdering.empty fc := by
  refine ⟨saturateBlocked_fuel_zero _ _ _, ?_⟩
  intro h
  rw [LabelFreeSaturatedExit, expandOnceNoFresh_multBranch_one fc] at h
  exact absurd h (by simp)


/-! ### The settlement lemma

The mathematical content of the repair: the two relocated antecedents really do force the
conclusion. Everything below is proved from the frozen files' **public** interface — `saturateBlocked`,
`expandOnceNoFresh`, `findApplicableRule`, `isExpanded`, `findUnexpandedUnblockedWith`,
`blockedTimes` and `ruleMintsFreshLabel` are all public `def`s, and `private` blocks name resolution
rather than unfolding (register entry 9's observation, used here in the direction where it helps).
-/

/-- **`findApplicableRule` never reports `.notApplicable`.** Its own body maps that constructor to
`none` before the `some` is built, so a reported triple always carries a result the engine can act
on. Needed because `expandOnceNoFresh` has a *second* route to `.saturated` — its `.notApplicable`
arm — and the inversion below has to rule that route out rather than assume it dead. -/
theorem findApplicableRule_result_ne_notApplicable
    {sf : SignedFormula} {b : Branch} {ord : TimeOrdering}
    {fc : FormalSystem.ProofSystem.FrameClass}
    {rule : TableauRule} {result : RuleResult} {newOrd : TimeOrdering}
    (h : findApplicableRule sf b ord fc = some (rule, result, newOrd)) :
    result ≠ RuleResult.notApplicable := by
  rw [findApplicableRule, List.findSome?_eq_some_iff] at h
  obtain ⟨_, r, _, _, hr, _⟩ := h
  intro hna
  subst hna
  repeat' split at hr
  all_goals simp_all

/-- **The `.saturated` verdict inverts to "the label-free filter rejected everything".**

`expandOnceNoFresh` reports `.saturated` in two ways: its `pick` found nothing, or the pick's result
was `.notApplicable`. The second is unreachable
(`findApplicableRule_result_ne_notApplicable`), so `.saturated` means exactly that every formula on
the branch was either not applicable at all, or applicable only through a rule the label-free filter
rejects. -/
theorem expandOnceNoFresh_saturated_imp
    {b : Branch} {ord : TimeOrdering} {fc : FormalSystem.ProofSystem.FrameClass}
    (hsat : (expandOnceNoFresh b ord fc).1 = ExpansionResult.saturated)
    {sf : SignedFormula} (hsf : sf ∈ b)
    {rule : TableauRule} {result : RuleResult} {newOrd : TimeOrdering}
    (hr : findApplicableRule sf b ord fc = some (rule, result, newOrd)) :
    ruleMintsFreshLabel rule = true ∨
      newOrd.constraints.length > ord.constraints.length := by
  by_contra hcon
  rw [not_or] at hcon
  obtain ⟨hmint', hlen'⟩ := hcon
  have hmint : ruleMintsFreshLabel rule = false := by simpa using hmint'
  have hlen : newOrd.constraints.length ≤ ord.constraints.length := Nat.not_lt.mp hlen'
  rw [expandOnceNoFresh] at hsat
  split at hsat
  · rename_i hp
    rw [List.findSome?_eq_none_iff] at hp
    have hx := hp sf hsf
    rw [hr] at hx
    simp only [hmint, Bool.false_eq_true, if_false, Nat.not_lt.mpr hlen, if_false] at hx
    exact absurd hx (by simp)
  · rename_i res nO hp
    have hne : res ≠ RuleResult.notApplicable := by
      rw [List.findSome?_eq_some_iff] at hp
      obtain ⟨_, x, _, _, hx, _⟩ := hp
      cases hfa : findApplicableRule x b ord fc with
      | none => rw [hfa] at hx; simp at hx
      | some tr =>
          obtain ⟨r', res', nO'⟩ := tr
          rw [hfa] at hx
          simp only at hx
          split at hx
          · simp at hx
          · split at hx
            · simp at hx
            · simp only [Option.some.injEq, Prod.mk.injEq] at hx
              obtain ⟨rfl, _⟩ := hx
              exact findApplicableRule_result_ne_notApplicable hfa
    cases res <;> simp_all

/-- **The finder closes when every unblocked formula is expanded.** Pure `List.find?` reasoning. -/
theorem findUnexpandedUnblockedWith_eq_none_of_isExpanded
    {b : Branch} {ord : TimeOrdering} {fc : FormalSystem.ProofSystem.FrameClass}
    {blocked : List TimeIndex}
    (h : ∀ sf ∈ b, ¬ blocked.contains sf.label.time → isExpanded sf b ord fc = true) :
    findUnexpandedUnblockedWith b ord fc blocked = none := by
  rw [findUnexpandedUnblockedWith, List.find?_eq_none]
  intro x hx hp
  simp only [Bool.and_eq_true, Bool.not_eq_true'] at hp
  exact absurd (h x hx (by simp only [hp.1, Bool.false_eq_true, not_false_eq_true]))
    (by simp [hp.2])

/-- **The core lemma.** `.saturated` plus no unblocked fresh work **is** settlement.

If `expandOnceNoFresh` reports `.saturated` then every formula on the branch is either not
applicable at all or applicable only through a label-minting or constraint-lengthening rule
(`expandOnceNoFresh_saturated_imp`). `NoUnblockedFreshWork` rules out the second and third
possibilities at every unblocked time. So every unblocked formula has `findApplicableRule = none`,
i.e. is `isExpanded`, and the blocking-aware finder closes.

Each hypothesis pays for exactly one of the two disagreements Phase 2 exhibits:
`LabelFreeSaturatedExit` pays for the fuel-truncation gap (`saturateBlocked` may hand a branch back
untested), and `NoUnblockedFreshWork` pays for the label-minting gap (`expandOnceNoFresh` skips what
`findUnexpandedUnblockedWith` counts). -/
theorem postBlockingSettlesAt_settlement
    {b : Branch} {ord : TimeOrdering} {fc : FormalSystem.ProofSystem.FrameClass}
    (hlf : LabelFreeSaturatedExit b ord fc) (hnf : NoUnblockedFreshWork b ord fc) :
    findUnexpandedUnblockedWith b ord fc (blockedTimes b ord fc (armTracker b)) = none := by
  refine findUnexpandedUnblockedWith_eq_none_of_isExpanded ?_
  intro sf hsf hub
  rw [isExpanded, Option.isNone_iff_eq_none]
  by_contra hne
  obtain ⟨tr, htr⟩ := Option.ne_none_iff_exists'.mp hne
  obtain ⟨rule, result, newOrd⟩ := tr
  obtain ⟨hm, hl⟩ := hnf sf hsf hub rule result newOrd htr
  rcases expandOnceNoFresh_saturated_imp hlf hsf htr with h | h
  · rw [hm] at h; exact absurd h (by simp)
  · exact absurd hl (Nat.not_le.mpr h)

/-- **The repaired residual is not a residual at all: it is a theorem.**

`PostBlockingSettlesAt fc` holds outright, for every frame class, with no hypothesis and no witness
class. This is the honest resolution of `PostBlockingSettles`'s open question: the settlement test is
decided by the **branch** — whether the label-free pass ran to completion on it, and whether any
label-minting work is left at an unblocked time — and not by the fuel. Neither fact follows from
`saturateBlocked`'s exit equation, which is why the literal predicate is false and why this one is
true. -/
theorem postBlockingSettlesAt_holds (fc : FormalSystem.ProofSystem.FrameClass) :
    PostBlockingSettlesAt fc :=
  fun _ _ _ _ _ _ hlf hnf => postBlockingSettlesAt_settlement hlf hnf


/-! ### The gate's verdict, decided

The two bridges are the anti-weakening gate: the repair is admissible only if
`armSettlement_of_postBlockingSettles` and `buildTableauAt_isSome_of_settles` can supply the
relocated hypotheses where they consume the residual. They cannot, and the failure is now decidable
rather than merely observed.

Both sites hold exactly one fact about the output pair — the exit equation — and
`labelFreeSaturatedExit_not_of_saturateBlocked_inr` shows that equation does not carry
`LabelFreeSaturatedExit`. The remaining question is whether a bridge could carry the two antecedents
as an *extra hypothesis* instead. It can, syntactically, and the hypothesis it would carry is
`PostBlockingExitSettled` below — which is **refuted**. So the only bridge shape that typechecks is a
weakening dressed as a repair, and the gate rejects it. That is the finding, stated as a theorem
rather than as a judgement call.
-/

/-- **The hypothesis a bridge at the repaired predicate would have to carry**: that
`saturateBlocked`'s open exit always lands on a branch satisfying both relocated antecedents. -/
def PostBlockingExitSettled (fc : FormalSystem.ProofSystem.FrameClass) : Prop :=
  ∀ (ob : Branch) (oOrd : TimeOrdering) (fuel : Nat) (satBr : Branch) (satOrd : TimeOrdering),
    saturateBlocked ob fuel oOrd fc = some (.inr (satBr, satOrd)) →
    LabelFreeSaturatedExit satBr satOrd fc ∧ NoUnblockedFreshWork satBr satOrd fc

/-- Supplying the antecedents at every exit recovers the literal residual, through the settlement
lemma. This is the implication that makes the refutation below possible. -/
theorem postBlockingSettles_of_postBlockingExitSettled
    {fc : FormalSystem.ProofSystem.FrameClass} (h : PostBlockingExitSettled fc) :
    PostBlockingSettles fc := fun ob oOrd fuel satBr satOrd hsb =>
  postBlockingSettlesAt_settlement (h ob oOrd fuel satBr satOrd hsb).1
    (h ob oOrd fuel satBr satOrd hsb).2

/-- **Gate verdict: FALSE, and provably so.** The bridge hypothesis is refuted at every frame class,
because it implies the literal residual that `postBlockingSettles_fuel_zero_false` refutes.

So the pre-declared repair is not admissible: relocating the two conditions to the output branch
leaves the terminus needing them at a site that cannot produce them, and the one way to hand them to
it carries an antecedent no caller can discharge — the `mintPaysForTime_empty` /
`universeClosed_identify_empty` failure mode in its sharpest form, caught before anything was
restated against it.

The repair is not thereby worthless: `postBlockingSettlesAt_holds` says the relocated statement is
**true outright**, which is what identifies where the real residual lives. It is not a settlement
question at all. It is the conjunction of a *fuel-adequacy* fact — that the pass ran to label-free
saturation rather than being truncated — and a *label-minting* fact about the branch the run reaches,
and neither is available from `saturateBlocked`'s exit equation because both are false at the
`fuel = 0` exit. Any admissible repair must therefore restrict the residual's quantification from
"every `(ob, oOrd, fuel)`" to the pair the terminus's own run produces; that is named here and
deliberately left unattempted. -/
theorem postBlockingExitSettled_false (fc : FormalSystem.ProofSystem.FrameClass) :
    ¬ PostBlockingExitSettled fc :=
  fun h => postBlockingSettles_fuel_zero_false fc
    (postBlockingSettles_of_postBlockingExitSettled h)


/-! ### How far the discharge goes

Two questions, kept apart because conflating them is how a weakening gets mistaken for a repair.
**Is the settlement lemma's antecedent pair dischargeable at a class the engine reaches?** Yes, and
the witness below is a branch the post-blocking pass itself produces. **Is that class larger than
the class where the conclusion already holds?** No — and that is the sharp statement of why
`PostBlockingSettlesAt` is a theorem rather than a repair.
-/

/-- **The converse, unconditional.** A branch on which the settlement test already closes satisfies
`NoUnblockedFreshWork` for free, because the antecedent of that condition is then unsatisfiable: no
unblocked formula has an applicable rule at all. No hypothesis about `expandOnceNoFresh` is used. -/
theorem noUnblockedFreshWork_of_settled
    {b : Branch} {ord : TimeOrdering} {fc : FormalSystem.ProofSystem.FrameClass}
    (h : findUnexpandedUnblockedWith b ord fc (blockedTimes b ord fc (armTracker b)) = none) :
    NoUnblockedFreshWork b ord fc := by
  intro sf hsf hub rule result newOrd hr
  exfalso
  rw [findUnexpandedUnblockedWith, List.find?_eq_none] at h
  refine h sf hsf ?_
  simp only [Bool.and_eq_true, Bool.not_eq_true', isExpanded, hr, Option.isNone_some]
  exact ⟨by simpa using hub, trivial⟩

/-- **The equivalence, and the verdict it carries.** Given that the pass ran to label-free
saturation, `NoUnblockedFreshWork` is not a weaker condition than the settlement test — it is that
test, restated. Forward is `postBlockingSettlesAt_settlement`; backward is the unconditional
converse above.

So `PostBlockingSettlesAt` is a theorem for a reason a reader should not mistake for progress: its
second antecedent already says what its conclusion says, once its first antecedent holds. What the
pair *does* buy is a **branch-independent** sufficient condition — `LabelFreeUniverseAt` below is
checkable from the universe alone, without looking at the branch — and that is the only useful
direction the equivalence leaves open. -/
theorem noUnblockedFreshWork_iff_of_labelFreeSaturatedExit
    {b : Branch} {ord : TimeOrdering} {fc : FormalSystem.ProofSystem.FrameClass}
    (hlf : LabelFreeSaturatedExit b ord fc) :
    NoUnblockedFreshWork b ord fc ↔
      findUnexpandedUnblockedWith b ord fc (blockedTimes b ord fc (armTracker b)) = none :=
  ⟨fun hnf => postBlockingSettlesAt_settlement hlf hnf, noUnblockedFreshWork_of_settled⟩

/-- **The label-minting-free fragment**, stated at a fixed ordering because the ordering is part of
what decides it: `orderTrichotomy` is applicable to *every* signed formula and is
constraint-lengthening exactly when the ordering has an incomparable pair, so no condition on the
formula stock alone can be sufficient. At `TimeOrdering.empty` it reports `.notApplicable`, which is
why the concrete witness below runs there. -/
def LabelFreeUniverseAt (fc : FormalSystem.ProofSystem.FrameClass)
    (U : Finset SignedFormula) (ord : TimeOrdering) : Prop :=
  ∀ sf ∈ U, ∀ (b : Branch) (rule : TableauRule) (result : RuleResult) (newOrd : TimeOrdering),
    findApplicableRule sf b ord fc = some (rule, result, newOrd) →
      ruleMintsFreshLabel rule = false ∧
        newOrd.constraints.length ≤ ord.constraints.length

/-- **Confinement to a label-free universe discharges the second antecedent**, for every branch and
every blocked set, without looking at the branch. This is the branch-independent direction the
equivalence above leaves open. -/
theorem noUnblockedFreshWork_of_labelFreeUniverseAt
    {fc : FormalSystem.ProofSystem.FrameClass} {U : Finset SignedFormula} {ord : TimeOrdering}
    (hU : LabelFreeUniverseAt fc U ord) {b : Branch} (hconf : ∀ x ∈ b, x ∈ U) :
    NoUnblockedFreshWork b ord fc :=
  fun sf hsf _ rule result newOrd hr => hU sf (hconf sf hsf) b rule result newOrd hr

/-! #### The concrete instantiation, and its non-vacuity

The witness is the landed `multBranch 1 = [F(p → q)@⟨0,0⟩]` and its one-step successor. It is
propositional, at `TimeOrdering.empty`, and the branch the discharge is stated at is one the
**post-blocking pass itself produces** — not a hand-assembled `Branch` and not the empty universe.
-/

/-- The pass's output at the witness: `T p, F q, F(p → q)`. -/
def multSettledBranch : Branch := multEmitted ++ multBranch 1

/-- One `.extended` step of the post-blocking pass, in closed form. -/
theorem saturateBlocked_step_extended {b nb : Branch} {ord : TimeOrdering}
    {fc : FormalSystem.ProofSystem.FrameClass} (fuel : Nat)
    (hcl : findClosure b fc = none)
    (hext : expandOnceNoFresh b ord fc = (ExpansionResult.extended nb, ord)) :
    saturateBlocked b (fuel + 1) ord fc = saturateBlocked nb fuel ord fc := by
  rw [saturateBlocked, hcl, hext]
  simp

theorem findClosure_multBranch_one (fc : FormalSystem.ProofSystem.FrameClass) :
    findClosure (multBranch 1) fc = none := by
  cases fc <;> rfl

theorem findClosure_multSettledBranch (fc : FormalSystem.ProofSystem.FrameClass) :
    findClosure multSettledBranch fc = none := by
  cases fc <;> rfl

/-- **The first antecedent, decided at every frame class**: the pass's output is label-free
saturated. Both atoms are expanded, and `F(p → q)`'s `.impNeg` is guarded off because the branch now
carries both of its conclusions. -/
theorem labelFreeSaturatedExit_multSettledBranch
    (fc : FormalSystem.ProofSystem.FrameClass) :
    LabelFreeSaturatedExit multSettledBranch TimeOrdering.empty fc := by
  show (expandOnceNoFresh multSettledBranch TimeOrdering.empty fc).1 = _
  cases fc <;> rfl

/-- **The second antecedent, at the same branch.** Discharged through the equivalence, from the
decided settlement test — which is exactly the caveat this section exists to state plainly. -/
theorem noUnblockedFreshWork_multSettledBranch
    (fc : FormalSystem.ProofSystem.FrameClass) :
    NoUnblockedFreshWork multSettledBranch TimeOrdering.empty fc :=
  noUnblockedFreshWork_of_settled (by cases fc <;> rfl)

/-- **The engine actually gets there**, at every frame class and every positive fuel figure: the
post-blocking pass started at `[F(p → q)@⟨0,0⟩]` fires `.impNeg` once and then reports the extended
branch as label-free saturated. So the class the discharge is stated at is inhabited by a branch the
pass produces, not by a hand-assembled one. -/
theorem saturateBlocked_multBranch_one_run
    (fc : FormalSystem.ProofSystem.FrameClass) (fuel : Nat) :
    saturateBlocked (multBranch 1) (fuel + 1) TimeOrdering.empty fc
      = some (.inr (multSettledBranch, TimeOrdering.empty)) := by
  rw [saturateBlocked_step_extended fuel (findClosure_multBranch_one fc)
    (expandOnceNoFresh_multBranch_one fc)]
  exact saturateBlocked_eq_self_of_noFresh_saturated (findClosure_multSettledBranch fc)
    (by
      have h := labelFreeSaturatedExit_multSettledBranch fc
      rw [LabelFreeSaturatedExit] at h
      exact Prod.ext h rfl) fuel

/-- **The concrete discharge.** At every frame class and every positive fuel, the post-blocking pass
run from `[F(p → q)@⟨0,0⟩]` returns a branch at which both antecedents hold and the blocking-aware
saturation test therefore closes. Nothing here is at a vacuous boundary: the branch is nonempty,
three formulas wide, and produced by the pass. -/
theorem postBlockingSettlesAt_labelFree
    (fc : FormalSystem.ProofSystem.FrameClass) (fuel : Nat) :
    ∃ satBr satOrd,
      saturateBlocked (multBranch 1) (fuel + 1) TimeOrdering.empty fc
          = some (.inr (satBr, satOrd)) ∧
        findUnexpandedUnblockedWith satBr satOrd fc
          (blockedTimes satBr satOrd fc (armTracker satBr)) = none :=
  ⟨multSettledBranch, TimeOrdering.empty, saturateBlocked_multBranch_one_run fc fuel,
    postBlockingSettlesAt_settlement (labelFreeSaturatedExit_multSettledBranch fc)
      (noUnblockedFreshWork_multSettledBranch fc)⟩


/-! ### The narrowed repair: the residual at what the terminus instantiates it at

The gate above rejects the *output-branch* repair. What is left is the over-quantification itself,
and that is repairable by the same move every sibling residual on this terminus was repaired by:
state the predicate at what the terminus actually instantiates it at, and fix the direction with a
lemma. `UniverseClosedAt` restricts clause 2's merge target to `b.knownTimes` (entry 10);
`MintPaysForTimeStable` and `MintPaysForTimeFixed` restrict σ (entries 19, 20); and — closest of
all — `ArmSettlement` is *already* stated this way, and says so on its own docstring: "a blanket
'`resolveOpenArm` never reports `none`' is plainly false — at `fuel = 0` and an unsaturated arm it
reports `none` — so this predicate is restricted to arms an engine run actually hands the fold."

`PostBlockingSettles` was never restricted that way, and that is the whole of its defect. It
quantifies over **every** `(ob, oOrd, fuel)`, including branches no run produces and the `fuel = 0`
arm at which its hypothesis is satisfied by every branch whatsoever. `buildTableauAt` reaches it at
exactly one kind of pair: a branch `expandBranchWithFuel` returned open, and the same fuel figure
that call was given.

`PostBlockingSettles` is retained verbatim and the landed termini are untouched. Nine restatements
once stood below, carrying `ArmSettlement` — which the landed chain already needed and already had
— together with the narrowed residual. They have been retired as vacuous, because the narrowed
residual is itself refuted at the figures they were stated at; the retirement record below carries
the disposition, and the live successor line is `PostBlockingSettlesSeedRun`.
-/

/-- **The post-blocking settlement residual, at what the terminus instantiates it at.**

`PostBlockingSettles`'s statement with the pass's input branch restricted to a branch some
`expandBranchWithFuel` call returned open, at the **same** fuel figure that call was given — which
is exactly how `buildTableauAt` reaches it (`Saturation.lean`'s `buildTableauAt`: one
`expandBranchWithFuel … fuel …` call, then `saturateBlocked openBr fuel ord fc`). The conclusion is
carried over verbatim: no test is weakened, no finder is replaced, and the frame class stays
universally quantified.

**Why the unrestricted form is not used.** It is refuted, at every frame class, and register entry
22 records why: `postBlockingSettles_fuel_zero_false` kills it at the `fuel = 0` arm, where
`saturateBlocked` hands its input back untested so the hypothesis is satisfied at *every* branch,
and `postBlockingSettles_fuel_gap_false` kills it at a nonzero one, on a branch
(`freshWorldBranch`) that no engine run hands to the pass. Entry 23 records why relocating
conditions onto the pass's **output** branch is not the repair either.

**The quantification is the honest one as far as it goes**, in the same sense and the same words as
`ArmSettlement`: `ob` is a branch some `expandBranchWithFuel` call returned open, and the fuel is
that call's own. What *is* decided in this narrowing's favour is that the `fuel = 0` degeneracy
which refutes the unrestricted form cannot reach it (`expandBranchWithFuel_eq_none_zero`), and that
its antecedent is genuinely satisfiable at figures the engine reaches — see the non-vacuity
subsection below.

**But the narrowing is incomplete, and the predicate is REFUTED at the terminus's own fuel figure.**
`postBlockingSettlesRun_terminusFuel_false` decides it in the negative at `.Base`, for every value of
every parameter, and `postBlockingSettlesRun_false_dense` / `postBlockingSettlesRun_false_rtime` do
the same at two further classes. The defect is a *second* over-quantification: this predicate
restricts `(ob, oOrd, fuel)` but leaves `expandBranchWithFuel`'s `EventualityTracker` argument
universally quantified, and that argument is the only input the engine's blocked-set computation and
the settlement test's recomputed `armTracker` do not share. Nothing is withdrawn on that account —
this definition is retained verbatim, as everything in this file is — but it is a **false**
hypothesis at those three classes. The nine termini that carried it were vacuous there for exactly
that reason and have been retired; see the retirement record below, the verdict subsection, and
register entries 24 and 25. The completion of the narrowing is
`PostBlockingSettlesSeedRun`, which is carried as a hypothesis and is **not** shown true. -/
def PostBlockingSettlesRun (fc : FormalSystem.ProofSystem.FrameClass) (fuel : Nat) : Prop :=
  ∀ (b ob : Branch) (ord oOrd : TimeOrdering) (tr : EventualityTracker) (ap oAp : AppliedSet)
    (mb bu : Nat) (satBr : Branch) (satOrd : TimeOrdering),
    expandBranchWithFuel b fuel ord fc tr ap mb bu = some (.inr (ob, oOrd, oAp)) →
    saturateBlocked ob fuel oOrd fc = some (.inr (satBr, satOrd)) →
    findUnexpandedUnblockedWith satBr satOrd fc
      (blockedTimes satBr satOrd fc (armTracker satBr)) = none

/-- **The direction, fixed and stated in words.** `PostBlockingSettlesRun fc fuel` is the **weaker**
predicate: its hypothesis list is longer by one antecedent, and the difference sits at the `(ob,
oOrd)` quantifier — the narrowed form speaks only about pairs an `expandBranchWithFuel` call at this
same fuel returned open, where the unrestricted form speaks about all of them. So the implication
runs `PostBlockingSettles fc → PostBlockingSettlesRun fc fuel`, at every `fuel`, and **every
theorem restated against the narrowed form is a strengthening of its landed original**, never a
weakening. This is the same direction `universeClosedAt_of_universeClosed` and
`mintPaysForTimeFixed_of_mintPaysForTimeStable` record for their own repairs, and register entry 7
is why it is stated rather than assumed.

Retained as the record of the direction; its one consumer was among the retired `_run` termini, so
it has none today. See the retirement record below. -/
theorem postBlockingSettlesRun_of_postBlockingSettles
    {fc : FormalSystem.ProofSystem.FrameClass} (h : PostBlockingSettles fc) (fuel : Nat) :
    PostBlockingSettlesRun fc fuel :=
  fun _ ob _ oOrd _ _ _ _ _ satBr satOrd _ hsb => h ob oOrd fuel satBr satOrd hsb

/-- `expandBranchWithFuel` is `none` at zero fuel, whether or not the budget guard fires first. -/
theorem expandBranchWithFuel_eq_none_zero (b : Branch) (ord : TimeOrdering)
    (fc : FormalSystem.ProofSystem.FrameClass) (tr : EventualityTracker) (ap : AppliedSet)
    (mb bu : Nat) : expandBranchWithFuel b 0 ord fc tr ap mb bu = none := by
  rw [expandBranchWithFuel]
  split <;> rfl

/-- **The degeneracy that refutes the unrestricted form cannot reach the narrowed one.** At
`fuel = 0` the narrowed predicate is vacuously true, because `expandBranchWithFuel` reports `none`
there and its antecedent is unsatisfiable — where the unrestricted predicate is *false* at that
same figure, since `saturateBlocked` hands its input back untested and the hypothesis is then
satisfied at every branch.

Stated so the fuel parameter is visibly load-bearing rather than decoration: at `fuel = 0` the
narrowed predicate says nothing at all, so a discharge has to be claimed at a figure where its
antecedent is satisfiable. The non-vacuity subsection below exhibits such figures. -/
theorem postBlockingSettlesRun_zero (fc : FormalSystem.ProofSystem.FrameClass) :
    PostBlockingSettlesRun fc 0 := by
  intro b _ ord _ tr ap _ mb bu _ _ hE _
  rw [expandBranchWithFuel_eq_none_zero b ord fc tr ap mb bu] at hE
  exact absurd hE (by simp)

/-- **Bridge, and the gate on the whole narrowing: the entry point's arms are discharged by the
narrowed residual.** The analogue of `buildTableauAt_isSome_of_settles`, with
`PostBlockingSettles fc` exchanged for `PostBlockingSettlesRun fc fuel`. The exchange is available
because `buildTableauAt` reaches the residual holding the very equation the narrowed form asks for:
its own `expandBranchWithFuel` call is in scope at the point the post-blocking arm is decided.

Retained as the record of the narrowing; its four consumers were the retired `_run` termini, so it
has none today. See the retirement record below. -/
theorem buildTableauAt_isSome_of_settlesRun {phi : Formula} {fuel : Nat}
    {fc : FormalSystem.ProofSystem.FrameClass} {maxBranches : Nat}
    (hpb : PostBlockingSettlesRun fc fuel)
    (hexp : (expandBranchWithFuel [SignedFormula.neg phi Label.initial] fuel TimeOrdering.empty fc
      (maxBranches := maxBranches)).isSome = true) :
    (buildTableauAt phi fuel fc maxBranches).isSome = true := by
  unfold buildTableauAt
  simp only
  match hE : expandBranchWithFuel [SignedFormula.neg phi Label.initial] fuel TimeOrdering.empty fc
      (maxBranches := maxBranches) with
  | none => rw [hE] at hexp; simp at hexp
  | some (.inl closedBr) => simp
  | some (.inr (ob, oOrd, oAp)) =>
      dsimp only
      split
      · simp
      · match hsb : saturateBlocked ob fuel oOrd fc with
        | none => exact absurd hsb (saturateBlocked_ne_none ob fuel oOrd fc)
        | some (.inl cb) => simp
        | some (.inr (satBr, satOrd)) =>
            dsimp only
            split
            · simp
            · rename_i sf2 hg2
              rw [hpb _ _ _ _ _ _ _ _ _ _ _ hE hsb] at hg2
              simp at hg2


/-! #### The termini restated at the narrowed residual — retired as vacuous

**What stood here.** Nine theorems restated the landed termini against the narrowed residual:

* `buildTableauAt_isSome_of_budget_run`
* `buildTableauAt_isSome_of_budget_of_run`
* `buildTableauAt_isSome_at_seed_run`
* `buildTableauAt_isSome_of_budget_at_run`
* `buildTableauAt_isSome_at_seed_at_run`
* `buildTableauAt_isSome_of_budget_selfGuarded_run`
* `buildTableauAt_isSome_at_seed_selfGuarded_run`
* `buildTableauAt_isSome_of_budget_fixed_run`
* `buildTableauAt_isSome_at_seed_fixed_run`

They are gone from the file. The names are recorded here so a reader arriving from `git log`, from
register entries 24 and 25, or from an external citation still finds them, in the idiom
`Correctness.lean` uses for its own retired pair: delete the theorem, keep the record.

**Why they were retired.** Each read as a headline result — the tableau construction succeeds —
while establishing nothing, because each carried a hypothesis this file itself refutes. That is
worse than the statements being absent: a reader meeting one at its declaration site got no local
signal, and the refutation sits thousands of lines away in the register. Removing them withdraws
no content, because none of them ever delivered any.

**The refutations, at the figures the nine were actually stated at.** Four of them
(`_of_budget_run`, `_at_seed_run`, `_of_budget_at_run`, `_at_seed_at_run`) carried
`PostBlockingSettlesRun fc` at the un-`At` figure `mintAwareFuel …`, refuted by
`postBlockingSettlesRun_mintAwareFuel_false`. Four (`_of_budget_selfGuarded_run`,
`_at_seed_selfGuarded_run`, `_of_budget_fixed_run`, `_at_seed_fixed_run`) carried it at
`mintAwareFuelAt …`, refuted by `postBlockingSettlesRun_terminusFuel_false`. Both figures are
positive at every parameter value (`one_le_mintAwareFuel`, `one_le_mintAwareFuelAt`), and
`postBlockingSettlesRun_false_succ` refutes the predicate at every positive figure. The ninth,
`buildTableauAt_isSome_of_budget_of_run`, carried the unrestricted `PostBlockingSettles`, refuted
by `postBlockingSettles_fuel_zero_false`.

**The frame-class split, which is not uniform and must not be flattened.** The eight carrying
`PostBlockingSettlesRun` are established vacuous at `.Base`, `.Dense` and `.RTime` — the last two
by `postBlockingSettlesRun_false_dense` and `postBlockingSettlesRun_false_rtime`. At `.ZTime`
their hypothesis is *undecided here*: the witness leaves `priorUZ` and `priorSZ` applicable, as
entry 25 records. Undecided is not delivered — at `.ZTime` they proved nothing either, and they
had zero dependents there as everywhere else. `buildTableauAt_isSome_of_budget_of_run` is the
exception in the other direction: carrying the unrestricted predicate, it is refuted by
`postBlockingSettles_fuel_zero_false` at **all four** frame classes, so entry 25's `.ZTime`
caveat does not reach it at all.

**What survives, and why.** Everything but the nine restatements. `PostBlockingSettlesRun` itself
is retained verbatim as the record of the narrowing, with
`postBlockingSettlesRun_of_postBlockingSettles` fixing its direction and
`buildTableauAt_isSome_of_settlesRun` as its bridge. The whole refutation apparatus stands —
`pbrWitnessBranch`, `pbrDoctoredTracker`, `postBlockingSettlesRun_false_succ` and the per-class
records — as does the non-vacuity subsection below. So does the live successor line:
`PostBlockingSettlesSeedRun`, its bridge `buildTableauAt_isSome_of_settlesSeedRun`, and
`buildTableauAt_isSome_of_budget_fixed_seedRun`, the terminus restated against a hypothesis this
file has **not** refuted. The landed termini stated against `PostBlockingSettles` are untouched.

**What the removal cost.** Nothing measurable. A whole-environment reverse-dependency scan found
zero dependents of the nine outside the nine themselves, and the decision procedure
`FormalSystem.Metalogic.Decidability.decide` reaches zero constants from this file at all.
-/


/-! #### Non-vacuity of the narrowed residual

The refutation of the unrestricted form turns on `fuel = 0` making its hypothesis hold at every
branch while carrying no information. A narrowed predicate that were true only because its
restricted antecedent is never satisfied would repeat that failure one level down, so the antecedent
is exhibited holding on runs the terminus actually produces.

Two things are shown, and they are shown by different means, which is stated rather than blurred.

**(a) The pass does real work, proved.** `saturateBlocked_multBranch_one_run` decides — at every
frame class and every positive fuel — that the post-blocking pass started at `[F(p → q)@⟨0,0⟩]`
returns a strictly longer branch, and `postBlockingSettlesAt_labelFree` is the settlement delivered
there. So the residual's conclusion is an obligation about a branch the pass built, never a no-op on
its input.

**(b) The full antecedent is satisfied by seed runs, measured.** The probe below runs the terminus's
own two calls in sequence — `expandBranchWithFuel` from the seed at a fuel figure, then
`saturateBlocked` on its open exit at that same figure — and reports three booleans: the run reached
an open exit, the pass strictly extended it, and the settlement test closed on the result. All three
are `true` at every frame class, on a propositional seed and a temporal one.

This half is a **checked measurement, not a kernel proof**, and the reason is worth stating so a
reader does not mistake one for the other: `expandBranchWithFuel` is compiled by well-founded
recursion and does not reduce definitionally, so a proof of the first equation would require
transcribing its eleven-formula open exit and unfolding the equation lemma once per engine step.
`#guard_msgs` makes the measurement a build-time obligation — the probe (`postBlockingRunProbe`, in
`Tests/BimodalTest/Metalogic/Decidability/Verified/TerminationProbes.lean`) is checked by
`lake build BimodalTest` — which is the same standing `branchingWitness`'s non-vacuity probe has,
and it is recorded with the same honesty about what it is.

**What the probe did not find.** Across fourteen formula shapes, four frame classes and three fuel
figures, no run made the settlement test fail — so no counterexample to the narrowed residual was
found, at any figure probed. That is evidence and not a proof, and the residual is carried as a
hypothesis accordingly. The same sweep also found `buildTableauAt`'s own guard never firing on those
shapes: the threaded tracker and the recomputed `armTracker` agreed everywhere, so the entry point
did not consult its post-blocking arm on any of them. The residual is therefore live but not yet
exercised by a probed formula, which is a fact about the probe's reach, not about the residual.

**And that warning was the right one: the residual is now refuted.** The subsection below decides
`PostBlockingSettlesRun` in the negative at `.Base`, `.Dense` and `.RTime`, at every positive fuel
figure and hence at the terminus's own. Nothing above is withdrawn — the measurements stand exactly
as recorded, and the pass really does do real work on the shapes probed — but no part of this
subsection should be read as evidence toward the residual's *truth*. The counterexample is reached
by doctoring an input the probes never varied, which is precisely what "a fact about the probe's
reach" left open. -/

/-- The witness pass extends its input strictly: one formula in, three out. The length fact behind
non-vacuity claim (a). -/
theorem multBranch_one_length_lt_multSettledBranch :
    (multBranch 1).length < multSettledBranch.length := by decide


/-! #### The verdict on the narrowed residual: **FALSE**, at the terminus's own fuel figure

`PostBlockingSettlesRun`'s narrowing restricted `(ob, oOrd, fuel)` to a pair some `expandBranchWithFuel` call at
this same fuel returned open. It did **not** restrict the run's other inputs, and one of them is not
inert: the `EventualityTracker` argument `tr`. The two blocked-set computations that the residual
needs to agree — `blockedTimes b ord fc tracker'` inside `expandOnceUnblocked`, where
`tracker' = fulfillEventualities b (registerEventualities b tr)`, and
`blockedTimes satBr satOrd fc (armTracker satBr)`, where `armTracker` re-seeds from
`EventualityTracker.empty` — share their branch, their ordering and their frame class, and differ in
**exactly** the tracker seed.

Blocking is *monotone in pending entries at the ancestor*: `isTemporallyBlockedSaturated` conjoins
`allEventualitiesFulfilledOrDuplicated`, which asks that every eventuality pending at `t` have some
pending entry with the same event formula and the same `isUntil` flag at the ancestor time. Adding a
pending entry at the ancestor therefore makes blocking fire *more* often, so a doctored `tr` yields a
**strictly larger** blocked set than the settlement test's recomputed `armTracker`: the engine skips
a time the settlement test still inspects. Two further facts make the exploit reachable —
`fulfillEventualities` discharges a pending entry only when its event formula occurs positively at
the entry's own **world** at some other time, so an entry parked at an otherwise-unused world is
never discharged; and `Branch.timeType`'s subset test ignores the world component, so the subset half
of blocking is satisfied across worlds while fulfillment, which is world-sensitive, is not.

**The predicate as written quantifies over `tr`, so the predicate as written is false.** This is
stated in the same voice as register entry 22's `fuel = 0` degeneracy, and it is not softened to a
caveat: the finding is that the narrowing was *incomplete*, and the completion is named below
(`PostBlockingSettlesSeedRun`) — carried as a hypothesis, never discharged.

**Why this refutation is a kernel proof where entry 24 records the positive direction as
prohibitive.** Entry 24 is right that `expandBranchWithFuel` is compiled by well-founded recursion
and does not reduce definitionally, so *proving* its half of the antecedent would mean transcribing
an engine exit and unfolding the equation lemma once per engine step. The witness below is returned
at the **first** step — the run reports `.saturated` immediately — so a single `rw` through the
equation lemma reaches the `.saturated` arm and the obligation closes. No engine step is
transcribed. That is the whole qualitative gain over a `#guard_msgs` measurement, and it is why the
verdict here is a theorem rather than an observation.
-/

/-- The witness branch: the verbatim open exit `expandBranchWithFuel` produces from
`seedBranch (p → q)` at `.Base` (its last eleven formulas, times chained `2 < 0 < 1 < 3`, engine
blocked set `[3, 2]`), augmented with world-1 machinery, the two `negPos` conclusions that exit left
outstanding at its blocked times, and the witness formula `T(p untl q)@⟨9,4⟩`.

Every part of the shape is load-bearing, and none of it is decoration:

* the tail is an **engine exit taken verbatim**, so the ancestor times are genuinely
  engine-saturated rather than hand-asserted — that is what makes `expandOnceNoFresh`'s `.saturated`
  verdict below honest instead of arranged;
* the world-1 block puts `T(p untl q)` into the ancestor's time type already expanded and fulfilled,
  which is what lets the duplication half of blocking be satisfied at time 4;
* `T(p untl q)@⟨9,4⟩` is the witness itself: `untlPos` mints a time, so `expandOnceNoFresh` skips it
  (`ruleMintsFreshTime`), and the post-blocking pass is by construction unable to remove it. -/
private def pbrWitnessBranch : Branch :=
  [ SignedFormula.neg .bot ⟨0, 2⟩
  , SignedFormula.neg .bot ⟨0, 3⟩
  , SignedFormula.pos (Formula.untl mfp mfq) ⟨1, 0⟩
  , SignedFormula.pos mfq ⟨1, 0⟩
  , SignedFormula.pos (Formula.untl (Formula.imp .bot .bot) (Formula.imp .bot .bot)) ⟨1, 0⟩
  , SignedFormula.pos (Formula.snce (Formula.imp .bot .bot) (Formula.imp .bot .bot)) ⟨1, 0⟩
  , SignedFormula.pos mfq ⟨1, 1⟩
  , SignedFormula.pos (Formula.imp .bot .bot) ⟨1, 1⟩
  , SignedFormula.pos (Formula.untl (Formula.imp .bot .bot) (Formula.imp .bot .bot)) ⟨1, 1⟩
  , SignedFormula.pos (Formula.snce (Formula.imp .bot .bot) (Formula.imp .bot .bot)) ⟨1, 1⟩
  , SignedFormula.pos (Formula.imp .bot .bot) ⟨1, 2⟩
  , SignedFormula.neg .bot ⟨1, 2⟩
  , SignedFormula.pos (Formula.imp .bot .bot) ⟨1, 3⟩
  , SignedFormula.neg .bot ⟨1, 3⟩
  , SignedFormula.pos (Formula.imp .bot .bot) ⟨1, 0⟩
  , SignedFormula.neg .bot ⟨1, 0⟩
  , SignedFormula.neg .bot ⟨1, 1⟩
  , SignedFormula.pos (Formula.untl mfp mfq) ⟨9, 4⟩
  -- the verbatim engine exit from `seedBranch (p → q)` begins here
  , SignedFormula.pos (Formula.imp .bot .bot) ⟨0, 3⟩
  , SignedFormula.pos (Formula.untl (Formula.imp .bot .bot) (Formula.imp .bot .bot)) ⟨0, 1⟩
  , SignedFormula.pos (Formula.snce (Formula.imp .bot .bot) (Formula.imp .bot .bot)) ⟨0, 1⟩
  , SignedFormula.pos (Formula.imp .bot .bot) ⟨0, 2⟩
  , SignedFormula.neg .bot ⟨0, 1⟩
  , SignedFormula.pos (Formula.imp .bot .bot) ⟨0, 1⟩
  , SignedFormula.pos (Formula.untl (Formula.imp .bot .bot) (Formula.imp .bot .bot)) ⟨0, 0⟩
  , SignedFormula.pos (Formula.snce (Formula.imp .bot .bot) (Formula.imp .bot .bot)) ⟨0, 0⟩
  , SignedFormula.pos mfp ⟨0, 0⟩
  , SignedFormula.neg mfq ⟨0, 0⟩
  , SignedFormula.neg (Formula.imp mfp mfq) ⟨0, 0⟩ ]

/-- The witness ordering: the engine exit's own chain `2 < 0 < 1 < 3`, extended by `3 < 4` so the
witness's time 4 is the chain's last element and time 1 is its ancestor. The extension is the
minimum needed to place time 4 in the ordering at all; nothing else about it is chosen. -/
private def pbrWitnessOrd : TimeOrdering := { constraints := [(3, 4), (1, 3), (2, 0), (0, 1)] }

/-- The doctored tracker: one pending `q`-eventuality parked at world 7, time 0 — a world the
witness branch never mentions.

Both halves of that placement are load-bearing. The *time* is 0, which is the ancestor time
`allEventualitiesFulfilledOrDuplicated` consults for the pending `q`-eventuality that
`registerEventualities` derives from `T(p untl q)@⟨9,4⟩`, so the duplication test is satisfied and
time 4 joins the blocked set. The *world* is unused, so `fulfillEventualities` — which discharges an
entry only on finding `T q` at that entry's own world at some other time — never removes it. This
tracker is not one any engine run threads, and that is not a defect in the refutation: the residual
quantifies over the tracker, so a tracker it admits is a counterexample to it. -/
private def pbrDoctoredTracker : EventualityTracker :=
  { pending := [{ formula := mfq, label := ⟨7, 0⟩, isUntil := true }] }

/-- The witness branch is open, at every frame class. -/
theorem pbrWitness_findClosure_none (fc : FormalSystem.ProofSystem.FrameClass) :
    findClosure pbrWitnessBranch fc = none := by cases fc <;> rfl

/-- **The label-free pass reports `.saturated` on the witness at `.Base`.** Every candidate it can
still see has been discharged by the augmentation; the one formula that is not discharged,
`T(p untl q)@⟨9,4⟩`, is invisible to this pass because `untlPos` mints a time. -/
theorem pbrWitness_expandOnceNoFresh_saturated :
    expandOnceNoFresh pbrWitnessBranch pbrWitnessOrd FormalSystem.ProofSystem.FrameClass.Base
      = (ExpansionResult.saturated, pbrWitnessOrd) := by rfl

/-- **The post-blocking pass hands the witness straight back, at every fuel figure.** This is the
existing fuel-universal step `saturateBlocked_eq_self_of_noFresh_saturated`, reused verbatim rather
than rebuilt: no induction on fuel, and no ladder of checked figures. -/
theorem pbrWitness_saturateBlocked_self (fuel : Nat) :
    saturateBlocked pbrWitnessBranch fuel pbrWitnessOrd
        FormalSystem.ProofSystem.FrameClass.Base
      = some (.inr (pbrWitnessBranch, pbrWitnessOrd)) :=
  saturateBlocked_eq_self_of_noFresh_saturated (pbrWitness_findClosure_none _)
    pbrWitness_expandOnceNoFresh_saturated fuel

/-- **The doctored run returns the witness open at its first step, at every positive fuel.**

This is the obligation register entry 24 records as prohibitive in the *positive* direction, and the
reason it is cheap here is worth stating rather than leaving to be rediscovered: the run reports
`.saturated` **immediately**, so `rw [expandBranchWithFuel]` unfolds the equation lemma exactly
**once** and the `.saturated` arm closes the goal. No engine step is transcribed and no equation
lemma is unfolded per step. That is what makes this a kernel proof where the corresponding positive
statement is a `#guard_msgs` measurement. -/
theorem pbrWitness_expandBranchWithFuel_eq (n : Nat) :
    expandBranchWithFuel pbrWitnessBranch (n + 1) pbrWitnessOrd
        FormalSystem.ProofSystem.FrameClass.Base pbrDoctoredTracker {} 100 0
      = some (.inr (pbrWitnessBranch, pbrWitnessOrd, {})) := by
  rw [expandBranchWithFuel]
  norm_num
  rfl

/-- **The settlement test does not close on the witness**, and it names the formula it is still
holding: `T(p untl q)@⟨9,4⟩`. The finder recomputes the blocked set with `armTracker`, which is
seeded from `EventualityTracker.empty` and so does not carry the doctored entry; time 4 is therefore
*not* blocked here, where the run's own computation blocked it. -/
theorem pbrWitness_settlement_fails :
    findUnexpandedUnblockedWith pbrWitnessBranch pbrWitnessOrd
        FormalSystem.ProofSystem.FrameClass.Base
        (blockedTimes pbrWitnessBranch pbrWitnessOrd FormalSystem.ProofSystem.FrameClass.Base
          (armTracker pbrWitnessBranch))
      = some (SignedFormula.pos (Formula.untl mfp mfq) ⟨9, 4⟩) := by rfl


/-- **The assembly, stated once and reused at every frame class the witness covers.** Given the
three class-specific `rfl` facts — the label-free pass is saturated on the witness, the doctored run
returns it open at `n + 1`, and the settlement test still reports the minting formula — the narrowed
residual is refuted at that class and that fuel. Nothing here is class-specific; only its three
hypotheses are. -/
private theorem postBlockingSettlesRun_false_succ_of
    {fc : FormalSystem.ProofSystem.FrameClass} (n : Nat)
    (hnf : expandOnceNoFresh pbrWitnessBranch pbrWitnessOrd fc
      = (ExpansionResult.saturated, pbrWitnessOrd))
    (hE : expandBranchWithFuel pbrWitnessBranch (n + 1) pbrWitnessOrd fc pbrDoctoredTracker {} 100 0
      = some (.inr (pbrWitnessBranch, pbrWitnessOrd, {})))
    (hs : findUnexpandedUnblockedWith pbrWitnessBranch pbrWitnessOrd fc
        (blockedTimes pbrWitnessBranch pbrWitnessOrd fc (armTracker pbrWitnessBranch))
      = some (SignedFormula.pos (Formula.untl mfp mfq) ⟨9, 4⟩)) :
    ¬ PostBlockingSettlesRun fc (n + 1) := by
  intro h
  have hsb : saturateBlocked pbrWitnessBranch (n + 1) pbrWitnessOrd fc
      = some (.inr (pbrWitnessBranch, pbrWitnessOrd)) :=
    saturateBlocked_eq_self_of_noFresh_saturated (pbrWitness_findClosure_none fc) hnf (n + 1)
  have hcon := h pbrWitnessBranch pbrWitnessBranch pbrWitnessOrd pbrWitnessOrd pbrDoctoredTracker
    {} {} 100 0 pbrWitnessBranch pbrWitnessOrd hE hsb
  rw [hs] at hcon
  exact absurd hcon (by simp)

/-- **Verdict: `PostBlockingSettlesRun` is FALSE at `.Base`, at every positive fuel figure.**

The five obligations above, assembled. Note what is *not* claimed: this is not a claim that
`buildTableauAt` ever threads `pbrDoctoredTracker`, and it does not have to be. The residual
quantifies over the tracker argument, so a tracker it admits refutes it — exactly as
`postBlockingSettles_fuel_zero_false` refutes the unrestricted form at an arm no caller reaches. -/
theorem postBlockingSettlesRun_false_succ (n : Nat) :
    ¬ PostBlockingSettlesRun FormalSystem.ProofSystem.FrameClass.Base (n + 1) :=
  postBlockingSettlesRun_false_succ_of n pbrWitness_expandOnceNoFresh_saturated
    (pbrWitness_expandBranchWithFuel_eq n) pbrWitness_settlement_fails

/-- **The terminus's own fuel figure is always positive.** `mintPathBound` ends in `+ 1`, so
`mintPathBoundAt` is at least one, and `fuelFigure_pos` lifts that to the figure itself with no
hypothesis on any parameter. This is what carries the `n + 1` refutation to the figure the termini
are stated at. -/
theorem one_le_mintAwareFuelAt (Ucard Tmax mintBudget D β : Nat) :
    1 ≤ mintAwareFuelAt Ucard Tmax mintBudget D β :=
  fuelFigure_pos (by simp only [mintPathBoundAt, mintPathBound]; omega)

/-- **The un-`At` figure is positive too, by the same route.** The un-`At` counterpart of
`one_le_mintAwareFuelAt`: `mintPathBound` ends in `+ 1`, so `fuelFigure_pos` lifts that to
`mintAwareFuel` itself, with no hypothesis on any parameter. -/
theorem one_le_mintAwareFuel (Ucard Tmax mintBudget D β : Nat) :
    1 ≤ mintAwareFuel Ucard Tmax mintBudget D β :=
  fuelFigure_pos (by simp only [mintPathBound]; omega)

/-- **The dispatch's literal question, answered: FALSE.**

`PostBlockingSettlesRun` does not hold at the terminus's own fuel figure, at `.Base`, for **any**
values of the parameters — the figure is always at least one, and the predicate is refuted at every
positive figure.

**The consequence, stated without hedging.** Eight `_run` termini carried `PostBlockingSettlesRun
fc` as a hypothesis: four at `mintAwareFuelAt …`, refuted here, and four at the un-`At` figure
`mintAwareFuel …`, refuted by `postBlockingSettlesRun_mintAwareFuel_false` immediately below. At
`.Base` (and, by `postBlockingSettlesRun_false_dense` / `postBlockingSettlesRun_false_rtime`, at
`.Dense` and `.RTime`) that hypothesis is **false**: those statements were vacuous there, not merely
unproved, and a reader could not read them as delivering `buildTableauAt … .isSome` at those
classes. They have since been retired for that reason, together with a ninth that carried the
unrestricted `PostBlockingSettles` and is refuted at all four classes — see the retirement record in
section C12. This is the analogue
of `postBlockingExitSettled_false`, and it sits beside it in spirit: a residual decided in the
negative, recorded as a theorem rather than left to be inferred.

The repair is named below (`PostBlockingSettlesSeedRun`) and is carried as a hypothesis, not
discharged. -/
theorem postBlockingSettlesRun_terminusFuel_false
    (U : Finset SignedFormula) (Tmax mintBudget D β : Nat) :
    ¬ PostBlockingSettlesRun FormalSystem.ProofSystem.FrameClass.Base
        (mintAwareFuelAt U.card Tmax mintBudget D β) := by
  obtain ⟨n, hn⟩ := Nat.exists_eq_succ_of_ne_zero
    (Nat.one_le_iff_ne_zero.mp (one_le_mintAwareFuelAt U.card Tmax mintBudget D β))
  rw [hn]
  exact postBlockingSettlesRun_false_succ n

/-- **The same verdict at the un-`At` figure.** The un-`At` counterpart of
`postBlockingSettlesRun_terminusFuel_false`, and the reason the vacuity claim covers **both** fuel
figures rather than only the `At` one: four of the nine retired `_run` termini were stated at
`mintAwareFuel …`, not at `mintAwareFuelAt …`. The frame class is written out in full because this
file opens only `FormalSystem.Syntax`. -/
theorem postBlockingSettlesRun_mintAwareFuel_false
    (U : Finset SignedFormula) (Tmax mintBudget D β : Nat) :
    ¬ PostBlockingSettlesRun FormalSystem.ProofSystem.FrameClass.Base
        (mintAwareFuel U.card Tmax mintBudget D β) := by
  obtain ⟨n, hn⟩ := Nat.exists_eq_succ_of_ne_zero
    (Nat.one_le_iff_ne_zero.mp (one_le_mintAwareFuel U.card Tmax mintBudget D β))
  rw [hn]
  exact postBlockingSettlesRun_false_succ n


/-! ##### The record at the other frame classes

Refuting at one frame class already refutes the predicate, so what follows completes the **record**,
not the verdict.

`.Dense` and `.RTime` are covered: the same three `rfl` obligations go through unchanged there,
because none of the rules those classes add is applicable to the witness. `.ZTime` is **not** covered
by this witness, and the reason is recorded here rather than left implicit: at that class `priorUZ`
and `priorSZ` remain applicable to `T(⊤ untl ⊤)` and `T(⊤ snce ⊤)` at `⟨0,0⟩`, `⟨0,1⟩`, `⟨1,0⟩` and
`⟨1,1⟩`, so `expandOnceNoFresh` reports `.extended` rather than `.saturated` and the first obligation
fails. Adding those rules' conclusions to the witness would close it; that is mechanical and is left
undone deliberately, because the predicate is already refuted and a fourth class buys nothing beyond
tidiness. A future reader who wants it can re-run the measurement from the two rule names and the
four labels named here without re-deriving anything. -/

/-- The label-free pass is saturated on the witness at `.Dense`. -/
theorem pbrWitness_expandOnceNoFresh_saturated_dense :
    expandOnceNoFresh pbrWitnessBranch pbrWitnessOrd FormalSystem.ProofSystem.FrameClass.Dense
      = (ExpansionResult.saturated, pbrWitnessOrd) := by rfl

/-- The doctored run returns the witness open at `.Dense`, at every positive fuel. -/
theorem pbrWitness_expandBranchWithFuel_eq_dense (n : Nat) :
    expandBranchWithFuel pbrWitnessBranch (n + 1) pbrWitnessOrd
        FormalSystem.ProofSystem.FrameClass.Dense pbrDoctoredTracker {} 100 0
      = some (.inr (pbrWitnessBranch, pbrWitnessOrd, {})) := by
  rw [expandBranchWithFuel]
  norm_num
  rfl

/-- The settlement test still reports the minting formula at `.Dense`. -/
theorem pbrWitness_settlement_fails_dense :
    findUnexpandedUnblockedWith pbrWitnessBranch pbrWitnessOrd
        FormalSystem.ProofSystem.FrameClass.Dense
        (blockedTimes pbrWitnessBranch pbrWitnessOrd FormalSystem.ProofSystem.FrameClass.Dense
          (armTracker pbrWitnessBranch))
      = some (SignedFormula.pos (Formula.untl mfp mfq) ⟨9, 4⟩) := by rfl

/-- The label-free pass is saturated on the witness at `.RTime`. -/
theorem pbrWitness_expandOnceNoFresh_saturated_rtime :
    expandOnceNoFresh pbrWitnessBranch pbrWitnessOrd FormalSystem.ProofSystem.FrameClass.RTime
      = (ExpansionResult.saturated, pbrWitnessOrd) := by rfl

/-- The doctored run returns the witness open at `.RTime`, at every positive fuel. -/
theorem pbrWitness_expandBranchWithFuel_eq_rtime (n : Nat) :
    expandBranchWithFuel pbrWitnessBranch (n + 1) pbrWitnessOrd
        FormalSystem.ProofSystem.FrameClass.RTime pbrDoctoredTracker {} 100 0
      = some (.inr (pbrWitnessBranch, pbrWitnessOrd, {})) := by
  rw [expandBranchWithFuel]
  norm_num
  rfl

/-- The settlement test still reports the minting formula at `.RTime`. -/
theorem pbrWitness_settlement_fails_rtime :
    findUnexpandedUnblockedWith pbrWitnessBranch pbrWitnessOrd
        FormalSystem.ProofSystem.FrameClass.RTime
        (blockedTimes pbrWitnessBranch pbrWitnessOrd FormalSystem.ProofSystem.FrameClass.RTime
          (armTracker pbrWitnessBranch))
      = some (SignedFormula.pos (Formula.untl mfp mfq) ⟨9, 4⟩) := by rfl

/-- **Verdict at `.Dense`: FALSE**, at every positive fuel figure. -/
theorem postBlockingSettlesRun_false_dense (n : Nat) :
    ¬ PostBlockingSettlesRun FormalSystem.ProofSystem.FrameClass.Dense (n + 1) :=
  postBlockingSettlesRun_false_succ_of n pbrWitness_expandOnceNoFresh_saturated_dense
    (pbrWitness_expandBranchWithFuel_eq_dense n) pbrWitness_settlement_fails_dense

/-- **Verdict at `.RTime`: FALSE**, at every positive fuel figure. -/
theorem postBlockingSettlesRun_false_rtime (n : Nat) :
    ¬ PostBlockingSettlesRun FormalSystem.ProofSystem.FrameClass.RTime (n + 1) :=
  postBlockingSettlesRun_false_succ_of n pbrWitness_expandOnceNoFresh_saturated_rtime
    (pbrWitness_expandBranchWithFuel_eq_rtime n) pbrWitness_settlement_fails_rtime


/-! ##### The minimal further narrowing, named and carried

What the refutation above kills is the residual's quantification over `expandBranchWithFuel`'s
*other* inputs. `buildTableauAt` does not quantify over them: at the one place it reaches the
residual it has just made the call

```
expandBranchWithFuel [F φ @ initial] fuel TimeOrdering.empty fc (maxBranches := maxBranches)
```

which supplies `ord`, `tracker`, `applied` and `branchesUsed` at `TimeOrdering.empty`,
`EventualityTracker.empty`, `{}` and `0`. Quantifying over those four was over-quantification, in the
same sense and for the same reason that quantifying over `(ob, oOrd, fuel)` was: generality the
consuming site never asked for, bought at the price of admitting inputs no run produces.

`PostBlockingSettlesSeedRun` fixes exactly those four and leaves everything else quantified. The
bridge survives verbatim, so the repaired chain is non-vacuous again.

**This is not a proof of the narrowing, and the distinction is the whole point of this subsection.**
-/

/-- **The residual with the four arguments `buildTableauAt` always supplies at their defaults
fixed.** `ord := TimeOrdering.empty`, `tr := EventualityTracker.empty`, `ap := {}` and `bu := 0`;
`b`, `ob`, `oOrd`, `oAp`, `mb`, `satBr` and `satOrd` stay quantified.

**(i) What it fixes, and why exactly those four.** They are precisely the arguments the consuming
site instantiates itself. `buildTableauAt` makes one `expandBranchWithFuel` call, from the seed
branch, at the empty ordering, the empty tracker, the empty applied set and zero branches used. A
predicate quantifying over them was not more general in any way a caller could use; it was admitting
inputs the entry point never produces, which is what
`postBlockingSettlesRun_terminusFuel_false` exploits.

**(ii) It kills that witness, and the reason is checked rather than hoped for.** At
`tr := EventualityTracker.empty` the witness branch's own `expandOnceUnblocked` reports `.extended`,
not `.saturated` — the doctored entry is exactly what made time 4 blocked, and with it gone the run
does not return the witness open at all. The measured genuine run from the witness at the empty
tracker reaches an exit whose settlement test **passes**.

**(iii) It is NOT shown true, and a second, structurally independent refutation route against it is
unprobed.** `saturateBlocked` may *extend* `ob`, and `expandOnceNoFresh` ignores blocking entirely —
so it can do label-free work at a *blocked* time, and the formulas it adds can break
`isSubsetBlocked` (or `timeSaturated` at the ancestor) and thereby **unblock** a time carrying
label-minting work that `expandOnceNoFresh` itself skips. The settlement test on `satBr` would then
report it, with no doctored tracker anywhere. That route needs no over-quantification at all and was
not probed. Any future claim that this predicate holds must gate on it first; the cheapest probe is a
sweep reporting, for engine exits `ob`, whether
`blockedTimes satBr satOrd fc (armTracker satBr)` ever loses a time that
`blockedTimes ob oOrd fc (armTracker ob)` held. -/
def PostBlockingSettlesSeedRun (fc : FormalSystem.ProofSystem.FrameClass) (fuel : Nat) : Prop :=
  ∀ (b ob : Branch) (oOrd : TimeOrdering) (oAp : AppliedSet) (mb : Nat)
    (satBr : Branch) (satOrd : TimeOrdering),
    expandBranchWithFuel b fuel TimeOrdering.empty fc EventualityTracker.empty {} mb 0
      = some (.inr (ob, oOrd, oAp)) →
    saturateBlocked ob fuel oOrd fc = some (.inr (satBr, satOrd)) →
    findUnexpandedUnblockedWith satBr satOrd fc
      (blockedTimes satBr satOrd fc (armTracker satBr)) = none

/-- **The direction, fixed and stated in words**, in the same idiom as
`postBlockingSettlesRun_of_postBlockingSettles`. `PostBlockingSettlesSeedRun fc fuel` is the
**weaker** predicate: it speaks only about runs started from the four defaults, where the run form
speaks about all of them. So the implication runs
`PostBlockingSettlesRun fc fuel → PostBlockingSettlesSeedRun fc fuel`, and **every theorem restated
against the seed form is a strengthening of its `_run` original**, never a weakening. Register entry
7 is why this is stated rather than assumed. -/
theorem postBlockingSettlesSeedRun_of_postBlockingSettlesRun
    {fc : FormalSystem.ProofSystem.FrameClass} {fuel : Nat}
    (h : PostBlockingSettlesRun fc fuel) : PostBlockingSettlesSeedRun fc fuel :=
  fun b ob oOrd oAp mb satBr satOrd hE hsb =>
    h b ob TimeOrdering.empty oOrd EventualityTracker.empty {} oAp mb 0 satBr satOrd hE hsb

/-- **Bridge, at the seed narrowing.** `buildTableauAt_isSome_of_settlesRun` with
`PostBlockingSettlesRun fc fuel` exchanged for `PostBlockingSettlesSeedRun fc fuel`. The exchange is
available for exactly the reason the narrowing is the right one: `buildTableauAt`'s own
`expandBranchWithFuel` call supplies the four fixed arguments at the very values the narrowing pins
them to, so the proof skeleton survives byte for byte. -/
theorem buildTableauAt_isSome_of_settlesSeedRun {phi : Formula} {fuel : Nat}
    {fc : FormalSystem.ProofSystem.FrameClass} {maxBranches : Nat}
    (hpb : PostBlockingSettlesSeedRun fc fuel)
    (hexp : (expandBranchWithFuel [SignedFormula.neg phi Label.initial] fuel TimeOrdering.empty fc
      (maxBranches := maxBranches)).isSome = true) :
    (buildTableauAt phi fuel fc maxBranches).isSome = true := by
  unfold buildTableauAt
  simp only
  match hE : expandBranchWithFuel [SignedFormula.neg phi Label.initial] fuel TimeOrdering.empty fc
      (maxBranches := maxBranches) with
  | none => rw [hE] at hexp; simp at hexp
  | some (.inl closedBr) => simp
  | some (.inr (ob, oOrd, oAp)) =>
      dsimp only
      split
      · simp
      · match hsb : saturateBlocked ob fuel oOrd fc with
        | none => exact absurd hsb (saturateBlocked_ne_none ob fuel oOrd fc)
        | some (.inl cb) => simp
        | some (.inr (satBr, satOrd)) =>
            dsimp only
            split
            · simp
            · rename_i sf2 hg2
              rw [hpb _ _ _ _ _ _ _ hE hsb] at hg2
              simp at hg2

/-- The `_of_budget_fixed` terminus at the seed narrowing — restated so it rests on a hypothesis
this file has **not** refuted. Exactly one entry of the hypothesis list differs from the retired
`buildTableauAt_isSome_of_budget_fixed_run`; the fuel expression is reused byte for byte.

This is the representative restatement, not the family. The nine `_run` termini it once stood beside
have been retired as vacuous (see the retirement record in section C12), so this is now the only
terminus in the file stated at a narrowed post-blocking residual. Widening the seed narrowing to the
rest of that family is deliberately deferred rather than forgotten — but note that widening it now
means restating landed termini, not repairing surviving ones. -/
theorem buildTableauAt_isSome_of_budget_fixed_seedRun
    {fc : FormalSystem.ProofSystem.FrameClass} {U : Finset SignedFormula}
    {mintBudget Tmax D β : Nat} (phi : Formula) (maxBranches : Nat)
    (hβ : 3 ≤ β) (hUcl : UniverseClosedAt fc U) (hD : DifficultyBounded fc U D)
    (hmint : MintPaysForTimeFixed fc U Tmax) (harm : ArmSettlement fc)
    (hpb : PostBlockingSettlesSeedRun fc (mintAwareFuelAt U.card Tmax mintBudget D β))
    (hseed : ∀ x ∈ seedBranch phi, x ∈ U)
    (hmb : 10 * U.card ≤ mintBudget)
    (hT : (seedBranch phi).knownTimes.toFinset.card + mintBudget ≤ Tmax)
    (hbud : β * mintAwareFuelAt U.card Tmax mintBudget D β ≤ maxBranches) :
    (buildTableauAt phi (mintAwareFuelAt U.card Tmax mintBudget D β) fc maxBranches).isSome
      = true := by
  refine buildTableauAt_isSome_of_settlesSeedRun hpb ?_
  exact expandBranchWithFuel_isSome_of_budget_fixed hβ hUcl hD hmint harm
    (seedBranch phi) TimeOrdering.empty EventualityTracker.empty {} maxBranches 0
    hseed (runInvariant_initial _) hmb hT (by omega)

end PostBlockingSettlesRefutation

end FormalSystem.Metalogic.Decidability
