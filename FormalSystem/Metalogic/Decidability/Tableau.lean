/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.SignedFormula

/-!
# Tableau Rules for TM Bimodal Logic

This module defines the tableau expansion rules for the TM bimodal logic
decision procedure. The rules systematically decompose signed formulas
until branches close (contradiction found) or saturate (countermodel exists).

## Main Definitions

- `TableauRule`: Enumeration of all tableau expansion rules
- `RuleResult`: Result of applying a rule (linear extension or branching)
- `applyRule`: Apply a tableau rule to a signed formula
- `expandBranch`: Single-step expansion of a branch

## Tableau Rules

### Propositional Rules
- `andPos`: T(A ∧ B) → T(A), T(B) (non-branching)
- `andNeg`: F(A ∧ B) → F(A) | F(B) (branching)
- `orPos`: T(A ∨ B) → T(A) | T(B) (branching)
- `orNeg`: F(A ∨ B) → F(A), F(B) (non-branching)
- `impPos`: T(A → B) → F(A) | T(B) (branching)
- `impNeg`: F(A → B) → T(A), F(B) (non-branching)
- `negPos`: T(¬A) → F(A) (non-branching)
- `negNeg`: F(¬A) → T(A) (non-branching)

### Modal S5 Rules
- `boxPos`: T(□A) → propagate T(A) to accessible states
- `boxNeg`: F(□A) → create state with F(A)

### Temporal Rules
- `allFuturePos`: T(GA) → propagate T(A) to future times
- `allFutureNeg`: F(GA) → create future time with F(A)
- `allPastPos`: T(HA) → propagate T(A) to past times
- `allPastNeg`: F(HA) → create past time with F(A)

## Implementation Notes

Since TM combines S5 modal logic with linear temporal logic, we use a
simplified tableau system that exploits the special properties of S5
(all worlds are mutually accessible, so we can use a single equivalence class).

## References

* Gore, R. (1999). Tableau Methods for Modal and Temporal Logics
* Wu, M. Verified Decision Procedures for Modal Logics
-/

namespace FormalSystem.Metalogic.Decidability

open FormalSystem.Syntax
open FormalSystem.ProofSystem

/-!
## Tableau Rule Type
-/

/--
Tableau expansion rules for TM bimodal logic.

Each rule specifies how to decompose a signed formula. Rules are either:
- **Linear** (non-branching): Add formulas to the current branch
- **Branching**: Split into multiple branches (any must close for tableau to close)
-/
inductive TableauRule : Type where
  /-- T(A ∧ B) → T(A), T(B) (A ∧ B = ¬(A → ¬B)) -/
  | andPos
  /-- F(A ∧ B) → F(A) | F(B) (branching) -/
  | andNeg
  /-- T(A ∨ B) → T(A) | T(B) (A ∨ B = ¬A → B, branching) -/
  | orPos
  /-- F(A ∨ B) → F(A), F(B) -/
  | orNeg
  /-- T(A → B) → F(A) | T(B) (branching) -/
  | impPos
  /-- F(A → B) → T(A), F(B) -/
  | impNeg
  /-- T(¬A) → F(A) (¬A = A → ⊥) -/
  | negPos
  /-- F(¬A) → T(A) -/
  | negNeg
  /-- T(□A) → propagate T(A) to all known worlds (S5 universal, persistent) -/
  | boxPos
  /-- F(□A) → introduce fresh witness world with F(A), auto-propagate universals -/
  | boxNeg
  /-- T(◇A) → introduce fresh witness world with T(A), auto-propagate universals -/
  | diamondPos
  /-- F(◇A) → propagate F(A) to all known worlds (S5 universal, persistent) -/
  | diamondNeg
  /-- T(□A) → derive T(GA) and T(HA) at the same label (modal-temporal interaction, persistent).
      Sound by boxToFuture (□φ → Gφ) and boxToPast (□φ → Hφ). -/
  | boxTemporal
  /-- T(GA) → propagate T(A) to all known future times (universal, persistent) -/
  | allFuturePos
  /-- F(GA) → F(A) at fresh future time (existential, consumable) -/
  | allFutureNeg
  /-- T(HA) → propagate T(A) to all known past times (universal, persistent) -/
  | allPastPos
  /-- F(HA) → F(A) at fresh past time (existential, consumable) -/
  | allPastNeg
  /-- T(FA) → T(A) at fresh future time (existential, consumable) -/
  | someFuturePos
  /-- F(FA) → propagate F(A) to all known future times (universal, persistent) -/
  | someFutureNeg
  /-- T(PA) → T(A) at fresh past time (existential, consumable) -/
  | somePastPos
  /-- F(PA) → propagate F(A) to all known past times (universal, persistent) -/
  | somePastNeg
  /-- T(U(event,guard)) → branch:
    event-witness at fresh future time OR guard+continue (consumable) -/
  | untlPos
  /-- F(U(event,guard)) → Reynolds co-decomposition at known future times (persistent) -/
  | untlNeg
  /-- T(S(event,guard)) → branch: event-witness at fresh past time OR guard+continue (consumable) -/
  | sncePos
  /-- F(S(event,guard)) → Reynolds co-decomposition at known past times (persistent) -/
  | snceNeg
  /-- Order trichotomy (R2, repairs D2). A positive witness `T(φ)` at a time `t1` and a
      positive `T(ψ)` at an incomparable sibling time `t2` (both after a common `t0`, same
      world) branch on the relative order of `t1` and `t2`, syntactically the three
      `temp_linearity` (BX11) disjuncts at `t0`:
      `T(F(φ ∧ ψ)) | T(F(φ ∧ F ψ)) | T(F(F φ ∧ ψ))`.
      Base rule: BX11 is a base axiom, so this is sound for every frame class. -/
  | orderTrichotomy
  /-- Dense: close branch when T(U(⊤,⊥)) appears (since ¬U(⊤,⊥) is a Dense axiom,
      asserting U(⊤,⊥) leads to contradiction on dense frames). Only applicable when fc >= .Dense.
      -/
  | denseIndicatorClosure
  /-- Dense: when T(G(φ)) at (w,t) and there exists a future time t' > t on the branch,
      introduce an intermediate time t'' with t < t'' < t' and add T(φ) at (w,t'').
      Captures density: between any two time points there is another. Only when fc >= .Dense. -/
  | densityRule
  /-- Discrete: when T(F(φ)) at (w,t), add T(U(φ, ¬φ)) at (w,t).
      Captures "nearest future φ-point reachable by Until". Only when fc >= .Discrete. -/
  | priorUZ
  /-- Discrete: when T(P(φ)) at (w,t), add T(S(φ, ¬φ)) at (w,t).
      Captures "nearest past φ-point reachable by Since". Only when fc >= .Discrete. -/
  | priorSZ
  /-- Discrete: when both T(G(G(φ) → φ)) and T(F(G(φ))) at same label,
      add T(G(φ)). Z1 backward induction axiom. Only when fc >= .Discrete. -/
  | z1Rule
  /-- Dedekind: Prior-U (gap form). When `T(U(⊤,φ) ∧ F(¬φ))` at `(w,t)`, add
      `T(U(¬φ ∨ K⁺(¬φ), φ))` at `(w,t)` — the φ-region has a definable right endpoint.
      Tableau counterpart of `Axiom.prior_U_gap`. Only when `fc >= .Dedekind`.
      NOT `priorUZ`, which is the integer well-ordering axiom at `.Discrete`. -/
  | priorUGap
  /-- Dedekind: Prior-S (gap form). Past dual of `priorUGap`: from
      `T(S(⊤,φ) ∧ P(¬φ))` add `T(S(¬φ ∨ K⁻(¬φ), φ))`.
      Tableau counterpart of `Axiom.prior_S_gap`. NOT `priorSZ`. -/
  | priorSGap
  /-- Dedekind: separation. From `T(K⁺φ ∧ ¬K⁺(φ ∧ U(φ,¬φ)))` add
      `T(K⁺(K⁺φ ∧ K⁻φ))`. Tableau counterpart of `Axiom.sep`. -/
  | sepRule
  /-- Seriality (BX1/BX1'). At any label, add `T(F ⊤)` and `T(P ⊤)` — the tableau images of
      `Axiom.serial_future` and `Axiom.serial_past` (`Axioms.lean:113, 117`). Persistent, and
      self-suppressing once both are on the branch at that label.

      Base rule in the soundness sense — both are base axioms, so it is sound for every frame
      class — but deliberately **absent from `allRulesForFC`**. It is keyed on the *label*, not
      on the formula's shape, so it applies to every signed formula on the branch, and any
      position in a per-formula priority list is the wrong one. See
      `serialityRules` / `expandOnce` for the globally-last scheduling it requires instead. -/
  | serialityRule
  /-- Time linearity (BX11, order level). Takes two times the branch knows but the ordering
      leaves incomparable and branches three ways on their relative position: `t₁ < t₂`,
      `t₂ < t₁`, or `t₁ = t₂`. Returns `.branchingOrdered`, because each arm needs a *different*
      `TimeOrdering` and the identification arm needs a different branch as well.

      **Arm 3 cannot be dropped.** `t₁ < t₂ ∨ t₁ = t₂ ∨ t₂ < t₁` is the trichotomy of a linear
      order; a two-arm version forces the two times to be distinct and loses exactly the models
      in which one instant witnesses both existentials.

      **Not a replacement for `orderTrichotomy`, and vice versa.** `orderTrichotomy` branches on
      `temp_linearity` *formulas*, which mint fresh witness times rather than ordering the two
      existing ones — which is why the W rows stayed incomparable while it was the only
      order-facing rule present. The two emit different things (formulas vs. ordering
      constraints) and coexist.

      Base rule in the soundness sense — `Axiom.temp_linearity` is a base axiom — but, like
      `serialityRule` and for the same reason, deliberately **absent from `allRulesForFC`**: it
      is keyed on the branch's time structure, not on any formula's shape. See
      `linearityRules` / `expandOnce` for the third-stage scheduling it requires. -/
  | timeLinearity
  deriving Repr, DecidableEq, BEq, Hashable

/-!
## Rule Result Type
-/

/--
Result of applying a tableau rule to a signed formula.

- `linear`: Add formulas to the current branch (non-branching)
- `branching`: Split into multiple branches (all must close for validity)
- `notApplicable`: Rule doesn't apply to this signed formula
-/
inductive RuleResult : Type where
  /-- Add these signed formulas to the current branch. -/
  | linear (formulas : List SignedFormula)
  /-- Split into multiple branches (each is a list of formulas to add). -/
  | branching (branches : List (List SignedFormula))
  /--
  Split into multiple branches that constrain the **time ordering differently per branch**.

  Additive: `.branching` above is untouched and keeps its meaning, so every existing rule and
  every existing consumer is unaffected. Only a rule that genuinely needs a different
  `TimeOrdering` on each branch — today only `timeLinearity` — returns this constructor.

  **The payload is a list of replacement branches, not of deltas.** This is the one place where
  it differs from `.branching`, and the difference is forced rather than stylistic: the
  identification arm of `timeLinearity` has to *remove* a time from `Branch.knownTimes`, which no
  list of formulas-to-add can do. Arms that add nothing to the branch simply pass the branch
  through unchanged. `Branch` is an `abbrev` for `List SignedFormula`, so this is the same type
  the design note names.
  -/
  | branchingOrdered (branches : List (Branch × TimeOrdering))
  /-- Universal modal rule: add formulas but do NOT remove the source formula.
      Used for T(□A) and F(◇A) which must persist for propagation to new worlds. -/
  | persistent (formulas : List SignedFormula)
  /-- Rule does not apply to this signed formula. -/
  | notApplicable
  deriving Repr

/-!
## Formula Decomposition Helpers
-/

/--
Try to decompose a formula as negation (A → ⊥).
Returns `some A` if the formula is `A.imp .bot`, otherwise `none`.
-/
def asNeg? : Formula → Option Formula
  | .imp φ .bot => some φ
  | _ => none

/--
Try to decompose a formula as conjunction (¬(A → ¬B)).
Note: A ∧ B = (A.imp B.neg).neg = (A.imp (B.imp .bot)).imp .bot
Returns `some (A, B)` if it matches the pattern, otherwise `none`.
-/
def asAnd? : Formula → Option (Formula × Formula)
  | .imp (.imp φ (.imp ψ .bot)) .bot => some (φ, ψ)
  | _ => none

/--
Try to decompose a formula as disjunction (¬A → B).
Note: A ∨ B = A.neg.imp B = (A.imp .bot).imp B
Returns `some (A, B)` if it matches the pattern, otherwise `none`.
-/
def asOr? : Formula → Option (Formula × Formula)
  | .imp (.imp φ .bot) ψ => some (φ, ψ)
  | _ => none

/--
Try to decompose a formula as diamond (¬□¬A).
Note: ◇A = A.neg.box.neg = ((A.imp .bot).box).imp .bot
Returns `some A` if it matches the pattern, otherwise `none`.
-/
def asDiamond? : Formula → Option Formula
  | .imp (.box (.imp φ .bot)) .bot => some φ
  | _ => none

/--
Try to decompose a formula as somePast (PA = S(A, ⊤)).
Note: somePast A = snce A top = snce A (imp bot bot)
Returns `some A` if it matches the pattern, otherwise `none`.
-/
def asSomePast? : Formula → Option Formula
  | .somePast φ => some φ
  | _ => none

/--
Try to decompose a formula as someFuture (FA = U(A, ⊤)).
Note: someFuture A = untl A top = untl A (imp bot bot)
Returns `some A` if it matches the pattern, otherwise `none`.
-/
def asSomeFuture? : Formula → Option Formula
  | .someFuture φ => some φ
  | _ => none

/--
Try to decompose a formula as allFuture (GA = ¬F¬A = ¬(U(¬A, ⊤))).
Note: allFuture A = (someFuture A.neg).neg
Returns `some A` if it matches the pattern, otherwise `none`.
-/
def asAllFuture? : Formula → Option Formula
  | .allFuture φ => some φ
  | _ => none

/--
Try to decompose a formula as allPast (HA = ¬P¬A = ¬(S(¬A, ⊤))).
Note: allPast A = (somePast A.neg).neg
Returns `some A` if it matches the pattern, otherwise `none`.
-/
def asAllPast? : Formula → Option Formula
  | .allPast φ => some φ
  | _ => none

/--
Try to decompose a formula as a genuine Until (not someFuture).
Returns `some (event, guard)` if the formula is `untl event guard` with `guard != top`.
This filters out `someFuture φ = untl φ top` which is handled by someFuturePos/someFutureNeg.
Burgess convention: first component = event, second = guard.
-/
def asUntil? : Formula → Option (Formula × Formula)
  | .untl event guard =>
    if guard == Formula.top then none
    else some (event, guard)
  | _ => none

/--
Try to decompose a formula as a genuine Since (not somePast).
Returns `some (event, guard)` if the formula is `snce event guard` with `guard != top`.
This filters out `somePast φ = snce φ top` which is handled by somePastPos/somePastNeg.
Burgess convention: first component = event, second = guard.
-/
def asSince? : Formula → Option (Formula × Formula)
  | .snce event guard =>
    if guard == Formula.top then none
    else some (event, guard)
  | _ => none

/-!
## Rule Application
-/

/--
Check if a specific rule is applicable to a signed formula.
-/
def isApplicable (rule : TableauRule) (sf : SignedFormula)
    (fc : FrameClass := .Base) : Bool :=
  match rule, sf.sign, sf.formula with
  -- Propositional rules
  | .andPos, .pos, φ => (asAnd? φ).isSome
  | .andNeg, .neg, φ => (asAnd? φ).isSome
  | .orPos, .pos, φ => (asOr? φ).isSome
  | .orNeg, .neg, φ => (asOr? φ).isSome
  | .impPos, .pos, .imp _ _ => true
  | .impNeg, .neg, .imp _ _ => true
  | .negPos, .pos, φ => (asNeg? φ).isSome
  | .negNeg, .neg, φ => (asNeg? φ).isSome
  -- Modal rules
  | .boxPos, .pos, .box _ => true
  | .boxNeg, .neg, .box _ => true
  | .diamondPos, .pos, φ => (asDiamond? φ).isSome
  | .diamondNeg, .neg, φ => (asDiamond? φ).isSome
  -- Modal-temporal interaction
  | .boxTemporal, .pos, .box _ => true
  -- Temporal rules (G/H universal)
  | .allFuturePos, .pos, .allFuture _ => true
  | .allFutureNeg, .neg, .allFuture _ => true
  | .allPastPos, .pos, .allPast _ => true
  | .allPastNeg, .neg, .allPast _ => true
  -- Temporal rules (F/P existential)
  | .someFuturePos, .pos, φ => (asSomeFuture? φ).isSome
  | .someFutureNeg, .neg, φ => (asSomeFuture? φ).isSome
  | .somePastPos, .pos, φ => (asSomePast? φ).isSome
  | .somePastNeg, .neg, φ => (asSomePast? φ).isSome
  -- Until/Since rules (genuine, not someFuture/somePast)
  | .untlPos, .pos, φ => (asUntil? φ).isSome
  | .untlNeg, .neg, φ => (asUntil? φ).isSome
  | .sncePos, .pos, φ => (asSince? φ).isSome
  | .snceNeg, .neg, φ => (asSince? φ).isSome
  -- Order trichotomy: shape gate only. The real restriction (an incomparable sibling
  -- time under a common predecessor, carrying a formula the branch already constrains) is
  -- in `applyRule`, which has the branch and the ordering; `isApplicable` sees only the
  -- signed formula. Same split of labour as `z1Rule`. Conjunctions are excluded here
  -- because they are exactly this rule's own output.
  | .orderTrichotomy, .pos, φ => (asAnd? φ).isNone
  -- Dense-specific rules (gated by fc >= .Dense)
  | .denseIndicatorClosure, .pos, .untl (.imp .bot .bot) .bot =>
      decide (FrameClass.Dense ≤ fc)
  | .densityRule, .pos, .allFuture _ =>
      decide (FrameClass.Dense ≤ fc)
  -- Discrete-specific rules (gated by fc >= .Discrete)
  | .priorUZ, .pos, φ => decide (FrameClass.Discrete ≤ fc) && (asSomeFuture? φ).isSome
  | .priorSZ, .pos, φ => decide (FrameClass.Discrete ≤ fc) && (asSomePast? φ).isSome
  | .z1Rule, .pos, .allFuture _ => decide (FrameClass.Discrete ≤ fc)
  -- Dedekind (R6). All three trigger on the axiom's *antecedent conjunction* rather than on
  -- one of its conjuncts. Triggering on a conjunct loses a race: the conjuncts of
  -- `U(⊤,φ) ∧ F(¬φ)` are produced one expansion step apart, and the base rule that owns the
  -- first one (`untlPos`, `someFuturePos`) is consumable, so it destroys the antecedent
  -- before the other conjunct exists. The conjunction itself is what the branch actually
  -- carries at a single moment, and matching it makes each rule a 1:1 transcription of its
  -- axiom.
  | .priorUGap, .pos, φ => decide (FrameClass.Dedekind ≤ fc) && (asAnd? φ).isSome
  | .priorSGap, .pos, φ => decide (FrameClass.Dedekind ≤ fc) && (asAnd? φ).isSome
  | .sepRule, .pos, φ => decide (FrameClass.Dedekind ≤ fc) && (asAnd? φ).isSome
  -- Seriality: keyed on the label, not on the formula. `T(F⊤)` and `T(P⊤)` are wanted at every
  -- label of every branch regardless of what formula carries that label, so there is no shape
  -- to gate on and no frame class to gate on either. The real suppression is in `applyRule`,
  -- which filters its two outputs against the branch and reports `.notApplicable` when both are
  -- already present. Scheduling — not applicability — is what keeps this rule in its place.
  | .serialityRule, _, _ => true
  -- Time linearity: keyed on the branch's time structure, not on the formula's shape, for the
  -- same reason as seriality. The real suppression is in `applyRule`, which reports
  -- `.notApplicable` as soon as no two known times are incomparable.
  | .timeLinearity, _, _ => true
  | _, _, _ => false

/--
The first pair of branch times the ordering leaves incomparable, scanned in `knownTimes` order.

`timeLinearity`'s trigger, factored out so the rule's arm reads as a two-case match and the
stage lemmas can `rcases` on this call rather than on an inlined `findSome?` term.

Incomparable means exactly what `Saturation.timeOrderTotal` means by it — neither time is in the
other's transitive future — and the quantification is over `Branch.knownTimes`, with no
common-predecessor or shared-world side condition. See the rule's arm in `applyRule` for why the
narrower trigger cannot meet the totality criterion.
-/
def firstIncomparablePair (b : Branch) (ord : TimeOrdering) : Option (TimeIndex × TimeIndex) :=
  let ts := b.knownTimes
  ts.findSome? fun t₁ =>
    let futs := ord.futureOf t₁
    let pasts := ord.pastOf t₁
    match ts.find? fun t₂ => t₂ != t₁ && !futs.contains t₂ && !pasts.contains t₂ with
    | some t₂ => some (t₁, t₂)
    | none => none

/--
Helper: collect T(□A) and F(◇A) formulas at a specific world and time,
re-labeled to a fresh time. Used by time-creation rules to propagate
box persistence (□φ → G(□φ)) and diamond-neg persistence.
-/
private def boxDiamondPersistence (branch : Branch) (w : WorldIndex) (t : TimeIndex)
    (freshTime : TimeIndex) : List SignedFormula :=
  let boxProps := (branch.boxPosAtWorldTime w t).filterMap fun bsf =>
    let prop := { bsf with label := { bsf.label with time := freshTime } }
    if branch.contains prop then none else some prop
  let diaProps := (branch.diamondNegAtWorldTime w t).filterMap fun dsf =>
    let prop := { dsf with label := { dsf.label with time := freshTime } }
    if branch.contains prop then none else some prop
  boxProps ++ diaProps

/--
`boxDiamondPersistence` only ever relabels: everything it emits carries the formula of some
signed formula already on the branch.

Stated here, rather than where it is used, because `boxDiamondPersistence` is `private` and so is
opaque outside this module — and it appears in the output of six rules, which makes it the one
piece of `applyRule` the subformula property (`Verified/Termination/SubformulaProperty.lean`)
cannot reach on its own. The lemma is `Prop`-valued and additive; it changes nothing the engine
computes.
-/
theorem mem_boxDiamondPersistence {branch : Branch} {w : WorldIndex} {t ft : TimeIndex}
    {g : SignedFormula} (h : g ∈ boxDiamondPersistence branch w t ft) :
    ∃ s ∈ branch, g.formula = s.formula := by
  unfold boxDiamondPersistence at h
  simp only [List.mem_append] at h
  rcases h with h | h
  · obtain ⟨s, hs, hsg⟩ := List.mem_filterMap.mp h
    unfold Branch.boxPosAtWorldTime at hs
    refine ⟨s, List.mem_of_mem_filter hs, ?_⟩
    by_cases hc : branch.contains { s with label := { s.label with time := ft } } = true <;>
      simp only [hc, if_true, if_false, reduceIte] at hsg
    · exact absurd hsg (by simp)
    · rw [← Option.some_inj.mp hsg]
  · obtain ⟨s, hs, hsg⟩ := List.mem_filterMap.mp h
    unfold Branch.diamondNegAtWorldTime at hs
    refine ⟨s, List.mem_of_mem_filter hs, ?_⟩
    by_cases hc : branch.contains { s with label := { s.label with time := ft } } = true <;>
      simp only [hc, if_true, if_false, reduceIte] at hsg
    · exact absurd hsg (by simp)
    · rw [← Option.some_inj.mp hsg]

/--
Label-level companion to `mem_boxDiamondPersistence`.

`mem_boxDiamondPersistence` recovers only the *formula*: it says the emitted signed formula
carries the formula of some branch member, and is deliberately silent about label and sign.
That is enough for the subformula property and not enough for anything else. The four
fresh-time existential rules (`allFutureNeg`, `allPastNeg`, `someFuturePos`, `somePastPos`)
need to know *where* the contributed formulas land and with *which* sign, because their
soundness argument has to relate the fresh time `ft` back to the triggering time `t` inside
the one world `w`. This lemma supplies exactly that: the output sits at `(w, ft)`, and its
source sits at `(w, t)` on the branch carrying the same sign and the same formula.

Stated here for the same reason as its companion: `boxDiamondPersistence` is `private` and so
is opaque outside this module. Like it, this lemma is `Prop`-valued and additive — it changes
nothing the engine computes.
-/
theorem mem_boxDiamondPersistence_label {branch : Branch} {w : WorldIndex} {t ft : TimeIndex}
    {g : SignedFormula} (h : g ∈ boxDiamondPersistence branch w t ft) :
    g.label = { world := w, time := ft } ∧
      ∃ s ∈ branch, s.label = { world := w, time := t } ∧
        s.sign = g.sign ∧ s.formula = g.formula := by
  have key : ∀ (l : List SignedFormula),
      (∀ s ∈ l, s.label.world = w ∧ s.label.time = t) →
      (∀ s ∈ l, s ∈ branch) →
      g ∈ l.filterMap (fun sf =>
        let prop := { sf with label := { sf.label with time := ft } }
        if branch.contains prop then none else some prop) →
      g.label = { world := w, time := ft } ∧
        ∃ s ∈ branch, s.label = { world := w, time := t } ∧
          s.sign = g.sign ∧ s.formula = g.formula := by
    intro l hloc hsub hmem
    obtain ⟨s, hs, hsg⟩ := List.mem_filterMap.mp hmem
    obtain ⟨hw, ht⟩ := hloc s hs
    by_cases hc : branch.contains { s with label := { s.label with time := ft } } = true <;>
      simp only [hc, if_true] at hsg
    · exact absurd hsg (by simp)
    · have hgs : ({ s with label := { s.label with time := ft } } : SignedFormula) = g :=
        Option.some_inj.mp hsg
      subst hgs
      exact ⟨by simp [hw], s, hsub s hs, by simp [← hw, ← ht], rfl, rfl⟩
  unfold boxDiamondPersistence at h
  simp only [List.mem_append] at h
  rcases h with h | h
  · refine key _ ?_ (fun s hs => List.mem_of_mem_filter hs) h
    intro s hs
    have hp := List.of_mem_filter hs
    split at hp
    · exact ⟨by simpa using ((Bool.and_eq_true _ _).mp hp).1,
        by simpa using ((Bool.and_eq_true _ _).mp hp).2⟩
    · exact absurd hp (by simp)
  · refine key _ ?_ (fun s hs => List.mem_of_mem_filter hs) h
    intro s hs
    have hp := List.of_mem_filter hs
    split at hp
    · exact ⟨by simpa using ((Bool.and_eq_true _ _).mp hp).1,
        by simpa using ((Bool.and_eq_true _ _).mp hp).2⟩
    · exact absurd hp (by simp)

/--
Apply a single tableau rule to a signed formula, in the context of the branch it
belongs to and the time ordering accumulated so far.

Returns the rule's outcome together with a possibly-extended time ordering:
`.linear fs` replaces the formula with `fs` on the same branch, `.branching bss`
splits the branch once per element of `bss`, `.persistent fs` adds `fs` while
keeping the formula, and `.notApplicable` means the rule does not match this
sign/connective pair. Rules that introduce a fresh time (the temporal and
diamond rules) are what extend the returned `TimeOrdering`.

The two world-minting rules (`.boxNeg`, `.diamondPos`) emit exactly
`witness :: boxProps ++ diaProps`: the existential witness, plus the modal
universals `T(□B)` and `F(◇B)` re-labelled into the fresh world. They emit
**no temporal formulas**. Copying `T(Gφ)`, `T(Hφ)`, `F(Fφ)`, `F(Pφ)`,
`F(U(φ,ψ))` or `F(S(φ,ψ))` from the triggering label's time into the fresh
world would assert of an alternative world what is only known of the history
being built — precisely the distinction `□`/`◇` quantify over — and six such
copy blocks per rule were removed for that reason. Do not reintroduce them, in
narrowed form or otherwise. Note the contrast with the *time*-minting rules
below, whose `boxDiamondPersistence` calls relabel `T(□A)`/`F(◇A)` across
times *within one world*; that is sound and is unaffected.
-/
def applyRule (rule : TableauRule) (sf : SignedFormula) (branch : Branch := [])
    (timeOrd : TimeOrdering := TimeOrdering.empty) : RuleResult × TimeOrdering :=
  let l := sf.label
  match rule, sf.sign, sf.formula with
  -- T(A ∧ B) → T(A), T(B)
  | .andPos, .pos, φ =>
      match asAnd? φ with
      | some (ψ, χ) => (.linear [SignedFormula.pos ψ l, SignedFormula.pos χ l], timeOrd)
      | none => (.notApplicable, timeOrd)
  -- F(A ∧ B) → F(A) | F(B)
  | .andNeg, .neg, φ =>
      match asAnd? φ with
      | some (ψ, χ) => (.branching [[SignedFormula.neg ψ l], [SignedFormula.neg χ l]], timeOrd)
      | none => (.notApplicable, timeOrd)
  -- T(A ∨ B) → T(A) | T(B)
  | .orPos, .pos, φ =>
      match asOr? φ with
      | some (ψ, χ) => (.branching [[SignedFormula.pos ψ l], [SignedFormula.pos χ l]], timeOrd)
      | none => (.notApplicable, timeOrd)
  -- F(A ∨ B) → F(A), F(B)
  | .orNeg, .neg, φ =>
      match asOr? φ with
      | some (ψ, χ) => (.linear [SignedFormula.neg ψ l, SignedFormula.neg χ l], timeOrd)
      | none => (.notApplicable, timeOrd)
  -- T(A → B) → F(A) | T(B)
  | .impPos, .pos, .imp ψ χ =>
      (.branching [[SignedFormula.neg ψ l], [SignedFormula.pos χ l]], timeOrd)
  -- F(A → B) → T(A), F(B)
  | .impNeg, .neg, .imp ψ χ =>
      (.linear [SignedFormula.pos ψ l, SignedFormula.neg χ l], timeOrd)
  -- T(¬A) → F(A)
  | .negPos, .pos, φ =>
      match asNeg? φ with
      | some ψ => (.linear [SignedFormula.neg ψ l], timeOrd)
      | none => (.notApplicable, timeOrd)
  -- F(¬A) → T(A)
  | .negNeg, .neg, φ =>
      match asNeg? φ with
      | some ψ => (.linear [SignedFormula.pos ψ l], timeOrd)
      | none => (.notApplicable, timeOrd)
  -- T(□A) → propagate T(A) to all known worlds (S5 universal, persistent)
  | .boxPos, .pos, .box ψ =>
      let worlds := branch.knownWorlds
      let newFormulas := worlds.filterMap fun w =>
        let newSf := SignedFormula.pos ψ { world := w, time := l.time }
        if branch.contains newSf then none else some newSf
      if newFormulas.isEmpty then (.notApplicable, timeOrd)
      else (.persistent newFormulas, timeOrd)
  -- F(□A) → F(A) at fresh witness world + auto-propagate universals (S5 existential)
  | .boxNeg, .neg, .box ψ =>
      let freshWorld := branch.nextWorld
      let freshLabel : Label := { world := freshWorld, time := l.time }
      -- The witness: F(A) at the fresh world
      let witness := SignedFormula.neg ψ freshLabel
      -- Auto-propagate all T(□B) formulas to the fresh world
      let boxProps := branch.boxPosFormulas.filterMap fun bsf =>
        match bsf.formula with
        | .box inner =>
          let prop := SignedFormula.pos inner { world := freshWorld, time := bsf.label.time }
          if branch.contains prop then none else some prop
        | _ => none
      -- Auto-propagate all F(◇B) formulas to the fresh world
      let diaProps := branch.diamondNegFormulas.filterMap fun dsf =>
        match dsf.formula with
        | .imp (.box (.imp inner .bot)) .bot =>
          let prop := SignedFormula.neg inner { world := freshWorld, time := dsf.label.time }
          if branch.contains prop then none else some prop
        | _ => none
      -- No cross-modal-temporal propagation. Temporal formulas at `l.time` are NOT copied
      -- into the fresh world: `T(Gφ)` says φ holds along *this* history's future, which is
      -- exactly what `□`/`◇` quantify over and therefore exactly what must not be assumed
      -- of a newly minted alternative world.
      (.linear (witness :: boxProps ++ diaProps), timeOrd)
  -- T(◇A) → T(A) at fresh witness world + auto-propagate universals (S5 existential)
  | .diamondPos, .pos, φ =>
      match asDiamond? φ with
      | some ψ =>
        let freshWorld := branch.nextWorld
        let freshLabel : Label := { world := freshWorld, time := l.time }
        -- The witness: T(A) at the fresh world
        let witness := SignedFormula.pos ψ freshLabel
        -- Auto-propagate all T(□B) formulas to the fresh world
        let boxProps := branch.boxPosFormulas.filterMap fun bsf =>
          match bsf.formula with
          | .box inner =>
            let prop := SignedFormula.pos inner { world := freshWorld, time := bsf.label.time }
            if branch.contains prop then none else some prop
          | _ => none
        -- Auto-propagate all F(◇B) formulas to the fresh world
        let diaProps := branch.diamondNegFormulas.filterMap fun dsf =>
          match dsf.formula with
          | .imp (.box (.imp inner .bot)) .bot =>
            let prop := SignedFormula.neg inner { world := freshWorld, time := dsf.label.time }
            if branch.contains prop then none else some prop
          | _ => none
        -- No cross-modal-temporal propagation. See the matching note in `.boxNeg` above:
        -- copying `T(Gφ)`/`T(Hφ)`/`F(Fφ)`/`F(Pφ)`/`F(U ..)`/`F(S ..)` from `l.time` into the
        -- fresh world would assume of an alternative world what is only known of this one.
        (.linear (witness :: boxProps ++ diaProps), timeOrd)
      | none => (.notApplicable, timeOrd)
  -- F(◇A) → propagate F(A) to all known worlds (S5 universal, persistent)
  | .diamondNeg, .neg, φ =>
      match asDiamond? φ with
      | some ψ =>
        let worlds := branch.knownWorlds
        let newFormulas := worlds.filterMap fun w =>
          let newSf := SignedFormula.neg ψ { world := w, time := l.time }
          if branch.contains newSf then none else some newSf
        if newFormulas.isEmpty then (.notApplicable, timeOrd)
        else (.persistent newFormulas, timeOrd)
      | none => (.notApplicable, timeOrd)
  -- T(□A) → derive T(GA) and T(HA) at the same label (modal-temporal interaction)
  -- Sound by boxToFuture (□φ → Gφ) and boxToPast (□φ → Hφ)
  | .boxTemporal, .pos, .box ψ =>
      let gFormula := SignedFormula.pos (Formula.allFuture ψ) l
      let hFormula := SignedFormula.pos (Formula.allPast ψ) l
      let newFormulas := [gFormula, hFormula].filter fun sf => !branch.contains sf
      if newFormulas.isEmpty then (.notApplicable, timeOrd)
      else (.persistent newFormulas, timeOrd)
  -- T(GA) @ (w,t) → propagate T(A) to all known future times (universal, persistent)
  -- Strict inequality: G(A) at t means A holds at all t' > t
  | .allFuturePos, .pos, .allFuture ψ =>
      let futureTimes := timeOrd.futureOf l.time
      let newFormulas := futureTimes.filterMap fun t' =>
        let newSf := SignedFormula.pos ψ { world := l.world, time := t' }
        if branch.contains newSf then none else some newSf
      if newFormulas.isEmpty then (.notApplicable, timeOrd)
      else (.persistent newFormulas, timeOrd)
  -- F(GA) @ (w,t) → F(A) at fresh future time (existential, consumable)
  -- ¬G(A) at t means there exists t' > t where ¬A
  | .allFutureNeg, .neg, .allFuture ψ =>
      let freshTime := branch.nextTime
      let freshLabel : Label := { world := l.world, time := freshTime }
      let newOrd := timeOrd.addFuture l.time freshTime
      -- The witness: F(A) at the fresh future time
      let witness := SignedFormula.neg ψ freshLabel
      -- Auto-propagate all T(GA) formulas from time t to freshTime
      let gProps := branch.allFuturePosFormulas.filterMap fun gsf =>
        match gsf.formula with
        | .allFuture inner =>
          -- Only propagate if freshTime is future of gsf's time
          -- Since we only added (l.time, freshTime), check gsf is at time l.time
          if gsf.label.time == l.time then
            let prop := SignedFormula.pos inner { world := gsf.label.world, time := freshTime }
            if branch.contains prop then none else some prop
          else none
        | _ => none
      -- Auto-propagate all F(FA) formulas from time t to freshTime
      let fNegProps := branch.someFutureNegFormulas.filterMap fun fsf =>
        match fsf.formula with
        | .someFuture inner =>
          if fsf.label.time == l.time then
            let prop := SignedFormula.neg inner { world := fsf.label.world, time := freshTime }
            if branch.contains prop then none else some prop
          else none
        | _ => none
      -- Cross-modal-temporal: propagate T(□A) and F(◇A) to fresh future time
      let modalProps := boxDiamondPersistence branch l.world l.time freshTime
      (.linear (witness :: gProps ++ fNegProps ++ modalProps), newOrd)
  -- T(HA) @ (w,t) → propagate T(A) to all known past times (universal, persistent)
  -- Strict inequality: H(A) at t means A holds at all t' < t
  | .allPastPos, .pos, .allPast ψ =>
      let pastTimes := timeOrd.pastOf l.time
      let newFormulas := pastTimes.filterMap fun t' =>
        let newSf := SignedFormula.pos ψ { world := l.world, time := t' }
        if branch.contains newSf then none else some newSf
      if newFormulas.isEmpty then (.notApplicable, timeOrd)
      else (.persistent newFormulas, timeOrd)
  -- F(HA) @ (w,t) → F(A) at fresh past time (existential, consumable)
  -- ¬H(A) at t means there exists t' < t where ¬A
  | .allPastNeg, .neg, .allPast ψ =>
      let freshTime := branch.nextTime
      let freshLabel : Label := { world := l.world, time := freshTime }
      let newOrd := timeOrd.addPast l.time freshTime
      -- The witness: F(A) at the fresh past time
      let witness := SignedFormula.neg ψ freshLabel
      -- Auto-propagate all T(HA) formulas from time t to freshTime
      let hProps := branch.allPastPosFormulas.filterMap fun hsf =>
        match hsf.formula with
        | .allPast inner =>
          -- Only propagate if freshTime is past of hsf's time
          -- Since we added (freshTime, l.time), check hsf is at time l.time
          if hsf.label.time == l.time then
            let prop := SignedFormula.pos inner { world := hsf.label.world, time := freshTime }
            if branch.contains prop then none else some prop
          else none
        | _ => none
      -- Auto-propagate all F(PA) formulas from time t to freshTime
      let pNegProps := branch.somePastNegFormulas.filterMap fun psf =>
        match psf.formula with
        | .somePast inner =>
          if psf.label.time == l.time then
            let prop := SignedFormula.neg inner { world := psf.label.world, time := freshTime }
            if branch.contains prop then none else some prop
          else none
        | _ => none
      -- Cross-modal-temporal: propagate T(□A) and F(◇A) to fresh past time
      let modalProps := boxDiamondPersistence branch l.world l.time freshTime
      (.linear (witness :: hProps ++ pNegProps ++ modalProps), newOrd)
  -- T(FA) @ (w,t) → T(A) at fresh future time (existential, consumable)
  -- F(A) at t means there exists t' > t where A holds
  | .someFuturePos, .pos, φ =>
      match asSomeFuture? φ with
      | some ψ =>
        let freshTime := branch.nextTime
        let freshLabel : Label := { world := l.world, time := freshTime }
        let newOrd := timeOrd.addFuture l.time freshTime
        -- The witness: T(A) at the fresh future time
        let witness := SignedFormula.pos ψ freshLabel
        -- Auto-propagate all T(GA) formulas from time t to freshTime
        let gProps := branch.allFuturePosFormulas.filterMap fun gsf =>
          match gsf.formula with
          | .allFuture inner =>
            if gsf.label.time == l.time then
              let prop := SignedFormula.pos inner { world := gsf.label.world, time := freshTime }
              if branch.contains prop then none else some prop
            else none
          | _ => none
        -- Auto-propagate all F(FA) formulas from time t to freshTime
        let fNegProps := branch.someFutureNegFormulas.filterMap fun fsf =>
          match fsf.formula with
          | .someFuture inner =>
            if fsf.label.time == l.time then
              let prop := SignedFormula.neg inner { world := fsf.label.world, time := freshTime }
              if branch.contains prop then none else some prop
            else none
          | _ => none
        -- Cross-modal-temporal: propagate T(□A) and F(◇A) to fresh future time
        let modalProps := boxDiamondPersistence branch l.world l.time freshTime
        (.linear (witness :: gProps ++ fNegProps ++ modalProps), newOrd)
      | none => (.notApplicable, timeOrd)
  -- F(FA) @ (w,t) → propagate F(A) to all known future times (universal, persistent)
  -- F(FA) = ¬(FA) means at all future times, A fails
  | .someFutureNeg, .neg, φ =>
      match asSomeFuture? φ with
      | some ψ =>
        let futureTimes := timeOrd.futureOf l.time
        let newFormulas := futureTimes.filterMap fun t' =>
          let newSf := SignedFormula.neg ψ { world := l.world, time := t' }
          if branch.contains newSf then none else some newSf
        if newFormulas.isEmpty then (.notApplicable, timeOrd)
        else (.persistent newFormulas, timeOrd)
      | none => (.notApplicable, timeOrd)
  -- T(PA) @ (w,t) → T(A) at fresh past time (existential, consumable)
  -- P(A) at t means there exists t' < t where A holds
  | .somePastPos, .pos, φ =>
      match asSomePast? φ with
      | some ψ =>
        let freshTime := branch.nextTime
        let freshLabel : Label := { world := l.world, time := freshTime }
        let newOrd := timeOrd.addPast l.time freshTime
        -- The witness: T(A) at the fresh past time
        let witness := SignedFormula.pos ψ freshLabel
        -- Auto-propagate all T(HA) formulas from time t to freshTime
        let hProps := branch.allPastPosFormulas.filterMap fun hsf =>
          match hsf.formula with
          | .allPast inner =>
            if hsf.label.time == l.time then
              let prop := SignedFormula.pos inner { world := hsf.label.world, time := freshTime }
              if branch.contains prop then none else some prop
            else none
          | _ => none
        -- Auto-propagate all F(PA) formulas from time t to freshTime
        let pNegProps := branch.somePastNegFormulas.filterMap fun psf =>
          match psf.formula with
          | .somePast inner =>
            if psf.label.time == l.time then
              let prop := SignedFormula.neg inner { world := psf.label.world, time := freshTime }
              if branch.contains prop then none else some prop
            else none
          | _ => none
        -- Cross-modal-temporal: propagate T(□A) and F(◇A) to fresh past time
        let modalProps := boxDiamondPersistence branch l.world l.time freshTime
        (.linear (witness :: hProps ++ pNegProps ++ modalProps), newOrd)
      | none => (.notApplicable, timeOrd)
  -- F(PA) @ (w,t) → propagate F(A) to all known past times (universal, persistent)
  -- F(PA) = ¬(PA) means at all past times, A fails
  | .somePastNeg, .neg, φ =>
      match asSomePast? φ with
      | some ψ =>
        let pastTimes := timeOrd.pastOf l.time
        let newFormulas := pastTimes.filterMap fun t' =>
          let newSf := SignedFormula.neg ψ { world := l.world, time := t' }
          if branch.contains newSf then none else some newSf
        if newFormulas.isEmpty then (.notApplicable, timeOrd)
        else (.persistent newFormulas, timeOrd)
      | none => (.notApplicable, timeOrd)
  -- T(U(event, guard)) @ (w,t) → branch: event-witness at fresh future time OR guard+continue
  -- Consumable: removed after application. Creates fresh time t' > t.
  -- Branch 1 (event witness): T(event) @ (w, t')
  -- Branch 2 (guard + continue): T(guard) @ (w, t'), T(U(event, guard)) @ (w, t')
  | .untlPos, .pos, φ =>
      match asUntil? φ with
      | some (event, guard) =>
        let freshTime := branch.nextTime
        let freshLabel : Label := { world := l.world, time := freshTime }
        let newOrd := timeOrd.addFuture l.time freshTime
        -- Branch 1: event witness at fresh future time
        let branch1 := [SignedFormula.pos event freshLabel]
        -- Branch 2: guard holds at fresh time + Until continues from fresh time
        let branch2 := [SignedFormula.pos guard freshLabel,
                         SignedFormula.pos (.untl event guard) freshLabel]
        -- Auto-propagate all T(GA) formulas to freshTime
        let gProps := branch.allFuturePosFormulas.filterMap fun gsf =>
          match gsf.formula with
          | .allFuture inner =>
            if gsf.label.time == l.time then
              let prop := SignedFormula.pos inner { world := gsf.label.world, time := freshTime }
              if branch.contains prop then none else some prop
            else none
          | _ => none
        -- Auto-propagate all F(FA) formulas to freshTime
        let fNegProps := branch.someFutureNegFormulas.filterMap fun fsf =>
          match fsf.formula with
          | .someFuture inner =>
            if fsf.label.time == l.time then
              let prop := SignedFormula.neg inner { world := fsf.label.world, time := freshTime }
              if branch.contains prop then none else some prop
            else none
          | _ => none
        -- Auto-propagate all F(U(event', guard')) formulas to freshTime
        let untlNegProps := branch.untlNegFormulas.filterMap fun usf =>
          if usf.label.time == l.time then
            let prop :=
              SignedFormula.neg usf.formula { world := usf.label.world, time := freshTime }
            if branch.contains prop then none else some prop
          else none
        -- Cross-modal-temporal: propagate T(□A) and F(◇A) to fresh future time
        let modalProps := boxDiamondPersistence branch l.world l.time freshTime
        let autoProp := gProps ++ fNegProps ++ untlNegProps ++ modalProps
        (.branching [branch1 ++ autoProp, branch2 ++ autoProp], newOrd)
      | none => (.notApplicable, timeOrd)
  -- T(S(event, guard)) @ (w,t) → branch: event-witness at fresh past time OR guard+continue
  -- Consumable: removed after application. Creates fresh time t' < t.
  -- Branch 1 (event witness): T(event) @ (w, t')
  -- Branch 2 (guard + continue): T(guard) @ (w, t'), T(S(event, guard)) @ (w, t')
  | .sncePos, .pos, φ =>
      match asSince? φ with
      | some (event, guard) =>
        let freshTime := branch.nextTime
        let freshLabel : Label := { world := l.world, time := freshTime }
        let newOrd := timeOrd.addPast l.time freshTime
        -- Branch 1: event witness at fresh past time
        let branch1 := [SignedFormula.pos event freshLabel]
        -- Branch 2: guard holds at fresh time + Since continues from fresh time
        let branch2 := [SignedFormula.pos guard freshLabel,
                         SignedFormula.pos (.snce event guard) freshLabel]
        -- Auto-propagate all T(HA) formulas to freshTime
        let hProps := branch.allPastPosFormulas.filterMap fun hsf =>
          match hsf.formula with
          | .allPast inner =>
            if hsf.label.time == l.time then
              let prop := SignedFormula.pos inner { world := hsf.label.world, time := freshTime }
              if branch.contains prop then none else some prop
            else none
          | _ => none
        -- Auto-propagate all F(PA) formulas to freshTime
        let pNegProps := branch.somePastNegFormulas.filterMap fun psf =>
          match psf.formula with
          | .somePast inner =>
            if psf.label.time == l.time then
              let prop := SignedFormula.neg inner { world := psf.label.world, time := freshTime }
              if branch.contains prop then none else some prop
            else none
          | _ => none
        -- Auto-propagate all F(S(event', guard')) formulas to freshTime
        let snceNegProps := branch.snceNegFormulas.filterMap fun ssf =>
          if ssf.label.time == l.time then
            let prop :=
              SignedFormula.neg ssf.formula { world := ssf.label.world, time := freshTime }
            if branch.contains prop then none else some prop
          else none
        -- Cross-modal-temporal: propagate T(□A) and F(◇A) to fresh past time
        let modalProps := boxDiamondPersistence branch l.world l.time freshTime
        let autoProp := hProps ++ pNegProps ++ snceNegProps ++ modalProps
        (.branching [branch1 ++ autoProp, branch2 ++ autoProp], newOrd)
      | none => (.notApplicable, timeOrd)
  -- F(U(event, guard)) @ (w,t) → Reynolds co-decomposition at future times
  -- Persistent: source formula re-included in both branches.
  -- PASSIVE mode: For each known future time t' > t, branch:
  --   Branch 1: F(event) @ (w, t'), source re-included
  --   Branch 2: F(guard) @ (w, t'), F(U(event, guard)) @ (w, t'), source re-included
  -- ACTIVE mode: When no future times exist, create a fresh future time and
  --   perform Reynolds co-decomposition there with full auto-propagation.
  | .untlNeg, .neg, φ =>
      match asUntil? φ with
      | some (event, guard) =>
        let futureTimes := timeOrd.futureOf l.time
        -- Find first unprocessed future time (where decomposition hasn't been done yet)
        let unprocessed := futureTimes.filter fun t' =>
          let negEvent := SignedFormula.neg event { world := l.world, time := t' }
          let negGuard := SignedFormula.neg guard { world := l.world, time := t' }
          !branch.contains negEvent && !branch.contains negGuard
        match unprocessed with
        | [] =>
          if futureTimes.isEmpty && timeOrd.timeCount > 0 && timeOrd.timeCount < 4 then
            -- ACTIVE: no future times exist at all — create fresh future time
            -- for Reynolds decomposition (Skolem witness for universal quantifier)
            -- Guard: limit fresh time point creation to prevent runaway chains
            --. Without this guard, standalone temporal formulas create
            -- exponential branching chains that exhaust fuel.
            let freshTime := branch.nextTime
            let freshLabel : Label := { world := l.world, time := freshTime }
            let newOrd := timeOrd.addFuture l.time freshTime
            -- Auto-propagate T(GA) formulas from time t to freshTime
            let gProps := branch.allFuturePosFormulas.filterMap fun gsf =>
              match gsf.formula with
              | .allFuture inner =>
                if gsf.label.time == l.time then
                  let prop :=
                    SignedFormula.pos inner { world := gsf.label.world, time := freshTime }
                  if branch.contains prop then none else some prop
                else none
              | _ => none
            -- Auto-propagate F(FA) formulas from time t to freshTime
            let fNegProps := branch.someFutureNegFormulas.filterMap fun fsf =>
              match fsf.formula with
              | .someFuture inner =>
                if fsf.label.time == l.time then
                  let prop :=
                    SignedFormula.neg inner { world := fsf.label.world, time := freshTime }
                  if branch.contains prop then none else some prop
                else none
              | _ => none
            -- Auto-propagate OTHER F(U(event', guard')) formulas to freshTime
            let untlNegProps := branch.untlNegFormulas.filterMap fun usf =>
              if usf.label.time == l.time && usf != sf then
                let prop :=
                  SignedFormula.neg usf.formula { world := usf.label.world, time := freshTime }
                if branch.contains prop then none else some prop
              else none
            -- Cross-modal-temporal: propagate T(□A) and F(◇A) to fresh future time
            let modalProps := boxDiamondPersistence branch l.world l.time freshTime
            let autoProp := gProps ++ fNegProps ++ untlNegProps ++ modalProps
            -- Reynolds co-decomposition at the fresh time
            let branch1 := [SignedFormula.neg event freshLabel, sf] ++ autoProp
            let branch2 := [SignedFormula.neg guard freshLabel,
                             SignedFormula.neg (.untl event guard) freshLabel, sf] ++ autoProp
            (.branching [branch1, branch2], newOrd)
          else
            -- All existing future times processed, or depth limit reached
            (.notApplicable, timeOrd)
        | t' :: _ =>
          let targetLabel : Label := { world := l.world, time := t' }
          -- Branch 1: event fails at t', source formula re-included for persistence
          let branch1 := [SignedFormula.neg event targetLabel, sf]
          -- Branch 2: guard fails at t' AND Until propagated to t', source re-included
          let branch2 := [SignedFormula.neg guard targetLabel,
                           SignedFormula.neg (.untl event guard) targetLabel, sf]
          (.branching [branch1, branch2], timeOrd)
      | none => (.notApplicable, timeOrd)
  -- F(S(event, guard)) @ (w,t) → Reynolds co-decomposition at past times
  -- Persistent: source formula re-included in both branches.
  -- PASSIVE mode: For each known past time t' < t, branch:
  --   Branch 1: F(event) @ (w, t'), source re-included
  --   Branch 2: F(guard) @ (w, t'), F(S(event, guard)) @ (w, t'), source re-included
  -- ACTIVE mode: When no past times exist, create a fresh past time and
  --   perform Reynolds co-decomposition there with full auto-propagation.
  | .snceNeg, .neg, φ =>
      match asSince? φ with
      | some (event, guard) =>
        let pastTimes := timeOrd.pastOf l.time
        -- Find first unprocessed past time
        let unprocessed := pastTimes.filter fun t' =>
          let negEvent := SignedFormula.neg event { world := l.world, time := t' }
          let negGuard := SignedFormula.neg guard { world := l.world, time := t' }
          !branch.contains negEvent && !branch.contains negGuard
        match unprocessed with
        | [] =>
          if pastTimes.isEmpty && timeOrd.timeCount > 0 && timeOrd.timeCount < 4 then
            -- ACTIVE: no past times exist at all — create fresh past time
            -- for Reynolds co-decomposition (Skolem witness for universal quantifier)
            -- Guard: limit fresh time point creation to prevent runaway chains
            --. Same guard as untlNeg active case above.
            let freshTime := branch.nextTime
            let freshLabel : Label := { world := l.world, time := freshTime }
            let newOrd := timeOrd.addPast l.time freshTime
            -- Auto-propagate T(HA) formulas from time t to freshTime
            let hProps := branch.allPastPosFormulas.filterMap fun hsf =>
              match hsf.formula with
              | .allPast inner =>
                if hsf.label.time == l.time then
                  let prop :=
                    SignedFormula.pos inner { world := hsf.label.world, time := freshTime }
                  if branch.contains prop then none else some prop
                else none
              | _ => none
            -- Auto-propagate F(PA) formulas from time t to freshTime
            let pNegProps := branch.somePastNegFormulas.filterMap fun psf =>
              match psf.formula with
              | .somePast inner =>
                if psf.label.time == l.time then
                  let prop :=
                    SignedFormula.neg inner { world := psf.label.world, time := freshTime }
                  if branch.contains prop then none else some prop
                else none
              | _ => none
            -- Auto-propagate OTHER F(S(event', guard')) formulas to freshTime
            let snceNegProps := branch.snceNegFormulas.filterMap fun ssf =>
              if ssf.label.time == l.time && ssf != sf then
                let prop :=
                  SignedFormula.neg ssf.formula { world := ssf.label.world, time := freshTime }
                if branch.contains prop then none else some prop
              else none
            -- Cross-modal-temporal: propagate T(□A) and F(◇A) to fresh past time
            let modalProps := boxDiamondPersistence branch l.world l.time freshTime
            let autoProp := hProps ++ pNegProps ++ snceNegProps ++ modalProps
            -- Reynolds co-decomposition at the fresh time
            let branch1 := [SignedFormula.neg event freshLabel, sf] ++ autoProp
            let branch2 := [SignedFormula.neg guard freshLabel,
                             SignedFormula.neg (.snce event guard) freshLabel, sf] ++ autoProp
            (.branching [branch1, branch2], newOrd)
          else
            -- All existing past times processed, or depth limit reached
            (.notApplicable, timeOrd)
        | t' :: _ =>
          let targetLabel : Label := { world := l.world, time := t' }
          -- Branch 1: event fails at t', source formula re-included for persistence
          let branch1 := [SignedFormula.neg event targetLabel, sf]
          -- Branch 2: guard fails at t' AND Since propagated to t', source re-included
          let branch2 := [SignedFormula.neg guard targetLabel,
                           SignedFormula.neg (.snce event guard) targetLabel, sf]
          (.branching [branch1, branch2], timeOrd)
      | none => (.notApplicable, timeOrd)
  -- Order trichotomy (R2, repairs D2): branch on the relative order of two incomparable
  -- times that share a common past.
  --
  -- **Why the branches are syntactically the BX11 disjuncts.** `temp_linearity`
  -- (`Axioms.lean:238`) is `F φ ∧ F ψ → F(φ ∧ ψ) ∨ F(φ ∧ F ψ) ∨ F(F φ ∧ ψ)`, and those three
  -- disjuncts *are* the trichotomy on two future witnesses: they coincide, the φ-witness
  -- comes first, or the ψ-witness comes first. Emitting them verbatim rather than as fresh
  -- ordering constraints keeps the rule's admissibility obligation a single appeal to BX11
  -- instead of a semantic argument about `TimeOrdering`, and it is the form the Phase 3
  -- `RuleSpec` gate maps to `Axiom.temp_linearity`.
  --
  -- **Why the trigger is a witness formula and not the eventuality.** The obvious trigger —
  -- `T(F φ)` with a partner `T(F ψ)` at the same label — never fires in practice, because
  -- `someFuturePos` is consumable: on `F φ ∧ F ψ → …` the branch reaches
  -- `T(F φ) @ t0` while `T(F ψ) @ t0` is still buried inside an undecomposed conjunction,
  -- `someFuturePos` consumes `T(F φ)` immediately, and the pair never coexists. The rule
  -- therefore triggers on the *witness*: a positive formula `T(φ) @ (w, t1)` looks back for
  -- a common predecessor `t0` and sideways for an incomparable sibling `t2` carrying
  -- `T(ψ)`, which is exactly the D2 configuration (two fresh times, both after `t0`, with
  -- no order between them).
  --
  -- **Branching restriction (the `3^k` containment).**
  --
  -- 1. *Incomparable time pairs.* `t1 ≠ t2`, neither is in the other's transitive future or
  --    past, and both lie in `futureOf t0`. The common predecessor is required because the
  --    BX11 instance being used is the one *at* `t0`: without it there is no point at which
  --    `F φ ∧ F ψ` holds and the split is not an axiom instance at all.
  -- 2. *Shared world.* `t1`, `t2` and `t0` are read at `l.world` throughout. Times are
  --    world-indexed here, so a pair drawn across two worlds is not a temporal-order
  --    question.
  -- 3. *Shared temporal formula (analytic restriction).* The split fires only when the
  --    branch already carries, at `(w, t0)`, the negation of at least one of the three
  --    disjuncts. This is what makes the rule analytic with respect to the branch: it never
  --    introduces a BX11 instance that no formula on the branch is about, so the branching
  --    is bounded by the negated eventualities present rather than by the square of the
  --    formulas at incomparable times. It is a genuine restriction, and it is the one the
  --    plan's Risk 1 flags for re-examination: if a conformance row that should CLOSE stays
  --    OPEN, this guard is the first suspect.
  -- 4. *No re-firing, in two halves.* A split must not repeat for a pair whose order the
  --    branch has already fixed, and the evidence for "already fixed" changes shape as the
  --    branch grows, so both halves are needed:
  --      (a) one of the three disjuncts is still present, positive, at some time of this
  --          world — the split fired and its conclusion has not yet been decomposed;
  --      (b) the conclusion *has* been decomposed: `someFuturePos` consumed the disjunct
  --          and left witnesses, so some φ-time and some ψ-time after `t0` are now equal
  --          or ordered. This is the half that makes the rule terminate. Guard (a) alone
  --          is not enough precisely because `someFuturePos` is consumable: the disjunct
  --          it removes was the only record that the pair had been split, so the trigger
  --          recurs at the freshly created time and the branch regresses without bound.
  --          Measured with only (a): counterexample B and the plain `F p ∧ F q` corpus
  --          rows STALLED at fuel 20000, the trace showing `orderTrichotomy` firing once
  --          per newly created time. Guard (b) is also the exact statement of what the
  --          rule is for — once the two witness sets are comparable, the trichotomy has
  --          been decided and there is nothing left to branch on.
  --    Guards (a) and (b) together still leave a window: the split's conclusion can be
  --    consumed by `someFuturePos` and its witness only *partly* decomposed, so that for a
  --    step or two neither (a) nor (b) holds and the pair re-fires at the newly created
  --    time. The third half closes it — *first witnesses only*: the pair fires only while
  --    each operand has at most one witness after `t0`. A second φ-witness can only exist
  --    because something already produced one, which is precisely the state the split was
  --    meant to reach. This is what makes the branch count finite: without it the trace
  --    shows `orderTrichotomy` firing at time 2, 3, 4, … forever, one new direct successor
  --    of `t0` per firing.
  --
  -- Neither operand may be a conjunction: every formula this rule produces has a
  -- conjunction under the `F`, so that restriction is exactly "the rule does not consume
  -- its own output".
  --
  -- The trigger formula is re-added to each branch (`.branching` deletes the expanded
  -- formula, and a witness atom must survive to close the branch against its negation).
  | .orderTrichotomy, .pos, φ =>
      if (asAnd? φ).isSome then (.notApplicable, timeOrd)
      else
        let disjuncts : Formula → Formula → List Formula := fun x y =>
          [ Formula.someFuture (Formula.and x y)
          , Formula.someFuture (Formula.and x (Formula.someFuture y))
          , Formula.someFuture (Formula.and (Formula.someFuture x) y) ]
        -- Positive, non-conjunctive formulas carried by a sibling time.
        let carriedAt : TimeIndex → List Formula := fun t =>
          branch.filterMap fun sf' =>
            match sf'.sign with
            | .pos =>
                if sf'.label.world == l.world && sf'.label.time == t
                    && (asAnd? sf'.formula).isNone then some sf'.formula else none
            | _ => none
        let futs := timeOrd.futureOf l.time
        let pasts := timeOrd.pastOf l.time
        -- Restriction 1+2: incomparable siblings under a common predecessor, same world.
        let candidates : List (TimeIndex × Formula) :=
          pasts.flatMap fun t0 =>
            let siblings := (timeOrd.futureOf t0).filter fun t2 =>
              t2 != l.time && !futs.contains t2 && !pasts.contains t2
            siblings.flatMap fun t2 => (carriedAt t2).map fun ψ => (t0, ψ)
        -- Restriction 4a: the split's own output is still on the branch, unconsumed.
        let firedAlready : Formula → Bool := fun d =>
          branch.any fun sf' =>
            sf'.sign == Sign.pos && sf'.label.world == l.world && sf'.formula == d
        -- Restriction 4b: the split's output has been consumed but its witnesses survive —
        -- some φ-time and ψ-time after `t0` are now ordered or identical.
        let witnessesOf : TimeIndex → Formula → List TimeIndex := fun t0 χ =>
          (timeOrd.futureOf t0).filter fun t =>
            branch.contains (SignedFormula.pos χ { world := l.world, time := t })
        let settled : TimeIndex → Formula → Bool := fun t0 ψ =>
          (witnessesOf t0 φ).any fun a => (witnessesOf t0 ψ).any fun b =>
            a == b || (timeOrd.futureOf a).contains b || (timeOrd.pastOf a).contains b
        let fires : TimeIndex × Formula → Bool := fun (t0, ψ) =>
          let l0 : Label := { world := l.world, time := t0 }
          let ds := disjuncts φ ψ
          !(ds.any firedAlready) && !settled t0 ψ
            && (witnessesOf t0 φ).length <= 1 && (witnessesOf t0 ψ).length <= 1
            && (ds.any fun d => branch.contains (SignedFormula.neg d l0))
        match candidates.find? fires with
        | none => (.notApplicable, timeOrd)
        | some (t0, ψ) =>
            let l0 : Label := { world := l.world, time := t0 }
            (.branching ((disjuncts φ ψ).map fun d => [SignedFormula.pos d l0, sf]), timeOrd)
  -- Dense: T(U(⊤,⊥)) closes the branch on dense frames
  -- U(⊤,⊥) asserts "⊥ holds until ⊤" which requires an immediate successor,
  -- but ¬U(⊤,⊥) is a Dense axiom (no immediate successors on dense frames).
  | .denseIndicatorClosure, .pos, .untl (.imp .bot .bot) .bot =>
      -- Close branch: T(U(top, bot)) contradicts density
      -- Return as linear with empty list -- the closure will be detected by checkAxiomNeg
      -- since F(¬U(top, bot)) is the dense_indicator axiom
      (.linear [], timeOrd)
  -- Dense: T(G(φ)) at (w,t) with known future time → introduce intermediate point
  -- On a dense frame, for any t' > t there exists t'' with t < t'' < t', so Gφ at t gives φ at t''.
  | .densityRule, .pos, .allFuture ψ =>
      -- **Gap selection: maximal targets only.** The candidate gaps are `(l.time, t')` for `t'`
      -- *maximal* in the source's future — no time lies after `t'` — and not already filled by
      -- an intermediate.
      --
      -- The second half of that is the original `existingIntermediates` guard, kept verbatim in
      -- meaning. The first half is new, and without it the rule diverges. The original picked
      -- `t'` as the *head* of `futureOf l.time` and gave up if that one gap was filled. But
      -- filling a gap adds a time, which changes the head, which exposes a fresh unfilled gap:
      -- interpolating `3` into `0 < 2` leaves `0 < 3` unfilled, interpolating `5` there leaves
      -- `0 < 5` unfilled, and so on without bound. The source of every one of those steps is the
      -- *root*, which carries the `T(G ψ)` and is never blocked, so time-blocking cannot stop the
      -- regress: blocking is a statement about expanding *from* a time, and this rule expands
      -- from time 0 no matter how many interpolants pile up below it.
      --
      -- Restricting to maximal `t'` makes the admissible-gap set shrink as gaps are filled: an
      -- interpolant is never maximal (it has the old target after it), so it cannot itself become
      -- a target, and each maximal future time is split at most once. New gaps appear only when
      -- some *other* rule mints a new witness time, and those rules carry their own guards.
      --
      -- **Measured.** Counterexample row B
      -- (`(F p ∧ F q) → (F(p ∧ F q) ∨ F(p ∧ q) ∨ F(q ∧ F p))`) read `CLOSED` at `.Base`/`.Discrete`
      -- and `STALLED` at `.Dense`/`.Dedekind`. Deleting `densityRule` from `denseRules` made all
      -- four read `CLOSED`, isolating this rule as the sole cause; the fix keeps the rule and
      -- bounds its gap selection.
      let futureTimes := timeOrd.futureOf l.time
      let gapTargets := futureTimes.filter fun t' =>
        (timeOrd.futureOf t').isEmpty
          && !(futureTimes.any fun t'' => (timeOrd.futureOf t'').contains t')
      match gapTargets with
      | [] => (.notApplicable, timeOrd)  -- No unfilled maximal gap to interpolate into
      | t' :: _ =>
          let freshTime := branch.nextTime
          let freshLabel : Label := { world := l.world, time := freshTime }
          -- Add t < freshTime < t' to the ordering
          let newOrd := (timeOrd.addFuture l.time freshTime).addFuture freshTime t'
          -- The intermediate point gets T(ψ) from G(ψ) at l.time
          let witness := SignedFormula.pos ψ freshLabel
          -- Also propagate all T(G(A)) from l.time to the intermediate
          let gProps := branch.allFuturePosFormulas.filterMap fun gsf =>
            match gsf.formula with
            | .allFuture inner =>
              if gsf.label.time == l.time && gsf.formula != .allFuture ψ then
                let prop := SignedFormula.pos inner { world := gsf.label.world, time := freshTime }
                if branch.contains prop then none else some prop
              else none
            | _ => none
          (.persistent (witness :: gProps), newOrd)
  -- Discrete: T(F(φ)) → T(U(φ, ¬φ))
  -- On discrete frames, F(φ) implies there is a nearest φ-point reachable by Until
  | .priorUZ, .pos, φ =>
      match asSomeFuture? φ with
      | some ψ =>
        let untilFormula := Formula.untl ψ ψ.neg
        let newSf := SignedFormula.pos untilFormula l
        if branch.contains newSf then (.notApplicable, timeOrd)
        else (.persistent [newSf], timeOrd)
      | none => (.notApplicable, timeOrd)
  -- Discrete: T(P(φ)) → T(S(φ, ¬φ))
  -- On discrete frames, P(φ) implies there is a nearest φ-point reachable by Since
  | .priorSZ, .pos, φ =>
      match asSomePast? φ with
      | some ψ =>
        let sinceFormula := Formula.snce ψ ψ.neg
        let newSf := SignedFormula.pos sinceFormula l
        if branch.contains newSf then (.notApplicable, timeOrd)
        else (.persistent [newSf], timeOrd)
      | none => (.notApplicable, timeOrd)
  -- Discrete: Z1 backward induction
  -- When T(G(G(φ) → φ)) and T(F(G(φ))) both at same label, add T(G(φ))
  | .z1Rule, .pos, .allFuture φ_inner =>
      -- Check if sf matches T(G(G(φ) → φ)) pattern
      match φ_inner with
      | .imp (.imp (.untl (.imp inner .bot) (.imp .bot .bot)) .bot) rhs =>
        -- This is G(G(inner) → rhs) -- verify rhs = inner
        if inner == rhs then
          -- Look for T(F(G(inner))) on the branch at the same label
          let gInner := Formula.allFuture inner
          let fgFormula := Formula.someFuture gInner
          let fgSf := SignedFormula.pos fgFormula l
          if branch.contains fgSf then
            let newSf := SignedFormula.pos gInner l
            if branch.contains newSf then (.notApplicable, timeOrd)
            else (.persistent [newSf], timeOrd)
          else (.notApplicable, timeOrd)
        else (.notApplicable, timeOrd)
      | _ => (.notApplicable, timeOrd)
  -- Dedekind: Prior-U (gap form), `Axiom.prior_U_gap`.
  -- `U(⊤,φ) ∧ F(¬φ) → U(¬φ ∨ K⁺(¬φ), φ)`: the φ-region ends, and its right endpoint is
  -- definable by `K⁺` ("¬φ holds arbitrarily soon after"). The rule adds the consequent and
  -- keeps its trigger, so the base rules still decompose the conjunction normally.
  | .priorUGap, .pos, χ =>
      match asAnd? χ with
      | some (a, b) =>
          match a with
          | .untl e g =>
              if e == Formula.top
                  && b == Formula.someFuture (Formula.neg g) then
                let concl :=
                  Formula.untl (Formula.or (Formula.neg g) (Formula.kPlus (Formula.neg g))) g
                let newSf := SignedFormula.pos concl l
                if branch.contains newSf then (.notApplicable, timeOrd)
                else (.persistent [newSf], timeOrd)
              else (.notApplicable, timeOrd)
          | _ => (.notApplicable, timeOrd)
      | none => (.notApplicable, timeOrd)
  -- Dedekind: Prior-S (gap form), `Axiom.prior_S_gap`. Past dual of `priorUGap`.
  | .priorSGap, .pos, χ =>
      match asAnd? χ with
      | some (a, b) =>
          match a with
          | .snce e g =>
              if e == Formula.top
                  && b == Formula.somePast (Formula.neg g) then
                let concl :=
                  Formula.snce (Formula.or (Formula.neg g) (Formula.kMinus (Formula.neg g))) g
                let newSf := SignedFormula.pos concl l
                if branch.contains newSf then (.notApplicable, timeOrd)
                else (.persistent [newSf], timeOrd)
              else (.notApplicable, timeOrd)
          | _ => (.notApplicable, timeOrd)
      | none => (.notApplicable, timeOrd)
  -- Dedekind: separation, `Axiom.sep`.
  -- `K⁺φ ∧ ¬K⁺(φ ∧ U(φ,¬φ)) → K⁺(K⁺φ ∧ K⁻φ)`. `K⁺ψ` unfolds to
  -- `(U(⊤, ¬ψ)) → ⊥`, which is the shape matched on `a` below; matching `Formula.top`
  -- as an equality rather than as a pattern keeps this independent of how `top` is defined.
  | .sepRule, .pos, χ =>
      match asAnd? χ with
      | some (a, b) =>
          match a with
          | .imp (.untl e (.imp ψ .bot)) .bot =>
              if e == Formula.top
                  && b == Formula.neg
                        (Formula.kPlus (Formula.and ψ (Formula.untl ψ (Formula.neg ψ)))) then
                let concl :=
                  Formula.kPlus (Formula.and (Formula.kPlus ψ) (Formula.kMinus ψ))
                let newSf := SignedFormula.pos concl l
                if branch.contains newSf then (.notApplicable, timeOrd)
                else (.persistent [newSf], timeOrd)
              else (.notApplicable, timeOrd)
          | _ => (.notApplicable, timeOrd)
      | none => (.notApplicable, timeOrd)
  -- Seriality: `T(F ⊤)` and `T(P ⊤)` at this label, filtered against the branch.
  -- Persistent and self-suppressing: once both are present the rule reports `.notApplicable`,
  -- so it cannot re-fire at a label it has already served. Soundness is immediate from
  -- `Axiom.serial_future` / `Axiom.serial_past`: both have antecedent `⊤`, so their consequents
  -- hold at every label of every model, and adding them preserves satisfiability in both
  -- directions.
  | .serialityRule, _, _ =>
      let outs := [SignedFormula.pos (Formula.someFuture Formula.top) l,
                   SignedFormula.pos (Formula.somePast Formula.top) l].filter
                    fun f => !branch.contains f
      if outs.isEmpty then (.notApplicable, timeOrd) else (.persistent outs, timeOrd)
  -- Time linearity: find the first pair of known times the ordering leaves incomparable and
  -- branch on their trichotomy.
  --
  -- **The trigger is "incomparable pair of `knownTimes`", full stop** — no common-predecessor
  -- and no shared-world restriction. Report 04 §Q2.4 describes the trigger as the one
  -- `orderTrichotomy` already computes (incomparable siblings under a common predecessor, same
  -- world), but that trigger cannot meet the done-criterion the same report sets, which is
  -- `timeOrderTotal` — and `timeOrderTotal` quantifies over *every* pair of `b.knownTimes`,
  -- with no predecessor or world condition. Measured on the corpus's own control row W6
  -- (`F p → F(F p)`): times `0` and `3` are incomparable and have no common predecessor at all
  -- (`pastOf 3 = []`), so a common-predecessor trigger leaves that pair unordered and the row
  -- reads `total=false` forever. The wider trigger is what the criterion forces.
  --
  -- Soundness is `Axiom.temp_linearity` read at the order level: on a linear order any two
  -- instants stand in exactly one of the three relations, so the three arms are jointly
  -- exhaustive and adding the disjunction preserves satisfiability. Arms 1 and 2 add one
  -- constraint and leave the branch alone; arm 3 identifies the two instants in both the branch
  -- and the ordering.
  --
  -- Self-suppressing: once every pair of known times is comparable there is no candidate and
  -- the rule reports `.notApplicable`, so it cannot re-fire on a pair it has already settled.
  -- That is also why `findApplicableRule` adds no guard for `.branchingOrdered`.
  | .timeLinearity, _, _ =>
      match firstIncomparablePair branch timeOrd with
      | none => (.notApplicable, timeOrd)
      | some (t₁, t₂) =>
          (.branchingOrdered
            [ (branch, timeOrd.addFuture t₁ t₂)
            , (branch, timeOrd.addFuture t₂ t₁)
            , (branch.identifyTime t₂ t₁, timeOrd.identifyTime t₂ t₁) ],
           timeOrd)
  | _, _, _ => (.notApplicable, timeOrd)

/--
`RuleResult.branching` is never equal to `RuleResult.notApplicable`.
-/
@[simp] theorem RuleResult.branching_ne_notApplicable (bs : List (List SignedFormula)) :
    RuleResult.branching bs ≠ RuleResult.notApplicable := by
  exact nofun

/--
`RuleResult.linear` is never equal to `RuleResult.notApplicable`.
-/
@[simp] theorem RuleResult.linear_ne_notApplicable (fs : List SignedFormula) :
    RuleResult.linear fs ≠ RuleResult.notApplicable := by
  exact nofun

/--
`RuleResult.persistent` is never equal to `RuleResult.notApplicable`.
-/
@[simp] theorem RuleResult.persistent_ne_notApplicable (fs : List SignedFormula) :
    RuleResult.persistent fs ≠ RuleResult.notApplicable := by
  exact nofun

/-!
## Applied-Set Tracking

Persistent rules (boxPos, diamondNeg, allFuturePos, allPastPos, boxTemporal,
someFutureNeg, somePastNeg, untlNeg, snceNeg) keep their source formula on the
branch and propagate consequences. If a consumable rule later removes a propagated
formula, the persistent rule sees it as "new" and re-adds it, creating an infinite
loop. The `AppliedSet` tracks signed formulas that have already been produced by
persistent rules. When a persistent rule's output formulas are ALL already in the
applied set, the rule is treated as not applicable.
-/

/-- Set of signed formulas already produced by persistent rule applications.
    Used to prevent infinite cycling between persistent and consumable rules. -/
abbrev AppliedSet := Std.HashSet SignedFormula

/-!
## Branch Expansion
-/

/--
All base tableau rules in priority order (frame-class independent).
Propositional rules are tried first, then modal, then temporal.
-/
def allRules : List TableauRule := [
  .negPos, .negNeg,      -- Negation (simplest)
  .impNeg,               -- F(A → B) non-branching
  .andPos, .orNeg,       -- Non-branching compound
  .boxPos, .boxNeg,      -- Modal
  .diamondPos, .diamondNeg,
  .boxTemporal,                    -- Modal-temporal interaction (before temporal rules)
  .allFuturePos, .allFutureNeg,  -- Temporal G/H
  .allPastPos, .allPastNeg,
  .someFuturePos, .someFutureNeg,  -- Temporal F/P
  .somePastPos, .somePastNeg,
  .untlPos, .untlNeg,             -- Until (genuine, not someFuture)
  .sncePos, .snceNeg,             -- Since (genuine, not somePast)
  .impPos,               -- Branching implication
  .andNeg, .orPos,       -- Branching compound
  -- Order trichotomy last: it triggers on witness formulas (typically atoms, which no
  -- other rule touches), so every cheaper decomposition is exhausted before a 3-way
  -- linearity split is considered.
  .orderTrichotomy
]

/--
Dense-specific rules, included only when fc >= .Dense.
-/
def denseRules : List TableauRule := [
  .denseIndicatorClosure,
  .densityRule
]

/--
Discrete-specific rules, included only when fc >= .Discrete.
-/
def discreteRules : List TableauRule := [
  .priorUZ, .priorSZ,
  .z1Rule
]

/--
Dedekind-specific rules (R6), included only when fc >= .Dedekind.

The tableau counterparts of `Axiom.prior_U_gap`, `Axiom.prior_S_gap` and `Axiom.sep`
(`Axioms.lean:377,387,398`) — the three axioms whose gap/separation content no other rule
touches, and the reason `Discrete ≰ Dedekind` is the correct gating rather than a defect:
the Dedekind terminus consumes `ValidDedekindDense`, so its arm is base + dense + dedekind
and never includes the Discrete rules.
-/
def dedekindRules : List TableauRule := [
  .priorUGap, .priorSGap, .sepRule
]

/--
All tableau rules for a given frame class, in priority order.
Base rules are always included; Dense/Discrete rules are appended
when the frame class supports them.
-/
def allRulesForFC (fc : FrameClass := .Base) : List TableauRule :=
  let base := allRules
  let dense := if decide (FrameClass.Dense ≤ fc) then denseRules else []
  let discrete := if decide (FrameClass.Discrete ≤ fc) then discreteRules else []
  let dedekind := if decide (FrameClass.Dedekind ≤ fc) then dedekindRules else []
  -- The Dedekind rules come FIRST, ahead of the base rules. They are persistent, they fire
  -- at most once per label (each checks `branch.contains` on its own conclusion), and they
  -- trigger on a conjunction that the consumable propositional rules destroy on their very
  -- next step. Appending them, as the Dense and Discrete arms are appended, would mean
  -- `negPos` decomposes `T(U(⊤,φ) ∧ F(¬φ))` before `priorUGap` is ever consulted and the
  -- rules would be dead code. Nothing else depends on their position: a persistent rule
  -- that adds one formula and then reports `notApplicable` cannot pre-empt any other rule.
  dedekind ++ base ++ dense ++ discrete

/-!
### Seriality is scheduled, not prioritised

`serialityRule` is **not** in `allRulesForFC` and must not be added to it. It is keyed on the
label rather than the formula, so it is applicable to *every* signed formula on the branch, and
`findUnexpanded` returns the first formula for which *any* rule applies. Putting seriality last
in the priority list therefore makes it last **per formula**, which is not what is wanted: if the
first formula on the branch happens to have no other applicable rule, seriality fires there while
real work is still pending further down, mints a time, and the resulting serial chain trips
blocking before the closure is found.

Measured on the corpus prototype at `.Base`: last-per-formula regresses `C5 K_G`, counterexample
`A` and `S4` to open at fuel 300 *and* at fuel 3000 (so not a fuel artefact), while last-globally
hits all 24 targets at fuel 3000 and at fuel 200.

"Last globally" means: fire seriality only when *no* formula on the branch has any ordinary rule
applicable. That is a property of the expansion step, not of a priority list, so it lives in
`expandOnce` as an explicit two-stage pick and cannot be broken by a future edit to the list.

**Contrast with the Dedekind arm above**, which is *prepended* for the opposite reason: those
rules trigger on a conjunction that the consumable propositional rules destroy on their next
step, so they must be consulted early or they are dead code. Both are scheduling lessons, in
opposite directions, and neither is expressible as "put it in the right place in one list".
-/

/-- The second-stage rule set: seriality alone. Deliberately disjoint from `allRulesForFC`. -/
def serialityRules : List TableauRule := [.serialityRule]

/-- `findApplicableRule` over the seriality stage. Seriality is persistent and self-guarded, so
this needs none of the `.linear`/`.branching` guard structure. -/
def findApplicableSerialRule (sf : SignedFormula) (branch : Branch := [])
    (timeOrd : TimeOrdering := TimeOrdering.empty) :
    Option (TableauRule × RuleResult × TimeOrdering) :=
  serialityRules.findSome? fun rule =>
    let (result, newOrd) := applyRule rule sf branch timeOrd
    match result with
    | .notApplicable => none
    | _ => some (rule, result, newOrd)

/-- The first formula seriality can serve: one whose label lacks `T(F ⊤)` or `T(P ⊤)`. -/
def findUnexpandedSerial (b : Branch) (timeOrd : TimeOrdering := TimeOrdering.empty) :
    Option SignedFormula :=
  b.find? fun sf => (findApplicableSerialRule sf b timeOrd).isSome

/-!
### Time linearity: the third stage, and the engine defect scheduling it exposed

`timeLinearity` is now wired into `expandOnce` / `expandOnceUnblocked` as the third stage, and
all seven `TimeOrderProbe` rows read `total=true incomparable=[]`. The history below is kept
because it identifies a live invariant of the engine that this rule was merely the first thing
to test.

Scheduling this stage against the *old* `expandBranchWithFuel` made the engine report
`F p → F(F p)` as CLOSED at `.Base` (conformance row C4, `target=OPEN`: there is no density
over an arbitrary linear order, and ℤ with `p` true only at `1` is a countermodel). That was a
real unsoundness, and it was **not** a defect in this rule:

- identification arm alone → OPEN, with a genuinely total order (`5 < 0 < 1 < 2 < 4`) that is a
  correct countermodel; arms 2+3 → OPEN likewise. Any variant containing arm 1 → CLOSED.
- Calling `expandBranchWithFuel` directly showed it returning `.inr openBranch` — an **open**
  branch — for which `findUnexpanded ≠ none`. The fuel loop was handing back a branch saturated
  only in the *unblocked* sense.
- Its split fold short-circuited on the first sub-branch that came back `.inr` and never
  explored the remaining arms. `buildTableau` then ran `saturateBlocked` on that branch, which
  closed it, and reported `.allClosed` — so the abandoned sibling arms were silently counted as
  closed.

The defect was in the open-branch contract between the split fold and the post-blocking pass,
not in the trichotomy: pre-existing, and merely *exposed* here, because it needs a rule whose
arms come back open-but-not-saturated and no corpus row produced one before. It is repaired in
`Saturation.resolveOpenArm`, which settles each arm while its siblings are still in scope. With
that in place C4 stays OPEN and the stage is sound to schedule.

**The invariant to preserve.** Any future rule whose arms can come back open-but-not-saturated
is subject to the same contract: an arm that cannot be settled must propagate as fuel
exhaustion, never as a closure. `resolveOpenArm` is where that is enforced.

### It goes third, after seriality

`timeLinearity` is not in `allRulesForFC` either, for the same reason as `serialityRule` — it is
keyed on the branch's time structure rather than on any formula's shape — but its stage belongs
*after* seriality's, not alongside it, and the order between the two is forced rather than
stylistic.

Seriality mints times. Time linearity orders the times that exist. Running linearity first would
order a time structure that seriality then extends, and every extension reintroduces
incomparabilities — the two stages would ping-pong, and each linearity firing is a **three-way
split**, so the ping-pong is paid for in branches rather than in steps. Running it strictly last
means the ordering work is done once, against a time structure nothing else is going to grow.

That is also why it is not merged into `serialityRules`: `findApplicableSerialRule` walks its
list per *formula*, so a two-element list would let linearity fire at the first formula seriality
happens to have nothing to do at, which is the same "last per formula, not last globally" defect
the section above measured for seriality itself.
-/

/-- The third-stage rule set: time linearity alone. Deliberately disjoint from both
`allRulesForFC` and `serialityRules`. -/
def linearityRules : List TableauRule := [.timeLinearity]

/-- `findApplicableRule` over the linearity stage. `timeLinearity` returns only
`.notApplicable` or `.branchingOrdered`, and it is self-suppressing (no candidate pair means
no result), so this needs none of the `.linear`/`.branching` guard structure. -/
def findApplicableLinearityRule (sf : SignedFormula) (branch : Branch := [])
    (timeOrd : TimeOrdering := TimeOrdering.empty) :
    Option (TableauRule × RuleResult × TimeOrdering) :=
  linearityRules.findSome? fun rule =>
    let (result, newOrd) := applyRule rule sf branch timeOrd
    match result with
    | .notApplicable => none
    | _ => some (rule, result, newOrd)

/-- The first formula the linearity stage can serve. Since `timeLinearity` is keyed on the
branch rather than on the formula, this is "the head of a non-empty branch that still has two
incomparable known times". -/
def findUnexpandedLinearity (b : Branch) (timeOrd : TimeOrdering := TimeOrdering.empty) :
    Option SignedFormula :=
  b.find? fun sf => (findApplicableLinearityRule sf b timeOrd).isSome

/-!
## Uniform Branch Guards

The persistent rules have always been self-guarded: each one filters its own output against
`branch.contains` and reports `.notApplicable` when nothing new remains. The `.linear` and
`.branching` rules were not, and did not need to be — they were *destructive*, deleting their
source from the branch, so they could not re-fire.

Destruction is what made the applied set necessary, and it made it necessary for a reason
that has nothing to do with the persistent rules themselves. `boxPos` produces `T(¬p)`;
`negPos` consumes `T(¬p)`; `boxPos`'s own guard now sees its output missing and re-emits it;
`negPos` consumes it again. The cycle is driven by the consumable rule deleting the persistent
rule's output, not by the persistent rule ignoring the branch.

So the fix is to stop deleting, and to give the consumable arms the guard the persistent arms
already have. `untlNeg` and `snceNeg` are the in-repo precedent: both re-include their source
formula in every arm and are guarded by their own `unprocessed` filter, and both have always
been non-destructive.

**The fresh-label complication.** Eight rules mint a fresh world or a fresh time, so their
outputs live at a label that by construction is not on the branch. `fs.all branch.contains`
can therefore never suppress them, and non-destructive application would mint labels forever.
For those eight, output-presence is replaced by *witness existence*: the rule is suppressed
when the branch already carries a witness of the right shape at some already-known world (for
the modal rules) or at some already-ordered time (for the temporal ones). This is the standard
"do not duplicate an existing witness" restriction and is satisfiability-preserving in both
directions, exactly as the output-presence guard is.

`densityRule` also mints a fresh time but is deliberately absent from the list below: it
carries its own equivalent guard (`existingIntermediates.isEmpty`), which is the same test
specialised to the intermediate it would create.

With both guards in place every expansion step strictly adds at least one formula the branch
did not have, so branch length is a strict progress measure and the applied set has no work
left to do.
-/

/--
Rules whose output lives at a freshly-minted world or time, and which therefore cannot be
suppressed by testing their output against the branch.

`densityRule` mints a fresh time too but is not listed: its `existingIntermediates` guard is
already the witness test specialised to its own witness shape.
-/
def ruleMintsFreshLabel : TableauRule → Bool
  | .boxNeg | .diamondPos | .allFutureNeg | .allPastNeg
  | .someFuturePos | .somePastPos | .untlPos | .sncePos => true
  | _ => false

/--
Rules that already suppress themselves, and so need no guard added in `findApplicableRule`.

`untlNeg` and `snceNeg` return `.branching`, but they filter the times they act on through
their own `unprocessed` test — a target time counts only when *neither* co-decomposition
output is on the branch yet — and they re-include the source formula in every arm. They are
therefore self-guarded and non-destructive already, by exactly the argument that makes the
`.persistent` arms self-guarded. Re-guarding them here would add nothing operationally (the
outer test can never fire where the inner filter has already passed) while putting an extra
`if` between the saturation lemmas and the filter structure they read.
-/
def ruleSelfGuarded : TableauRule → Bool
  | .untlNeg | .snceNeg => true
  | _ => false

/--
Does the branch already carry a witness for this fresh-label rule at this formula?

The witness test per rule, at label `(w, t)`:

- `boxNeg` / `diamondPos` — the modal accessibility relation is universal (S5), so any known
  world serves: some `w'` with `F(ψ) @ (w', t)` (resp. `T(ψ) @ (w', t)`) on the branch.
- `allFutureNeg` / `someFuturePos` — some `t'` strictly after `t` in the *transitive* ordering
  carrying `F(ψ)` (resp. `T(ψ)`) at `w`.
- `allPastNeg` / `somePastPos` — the past-directed mirrors.
- `untlPos` / `sncePos` — either arm counts, since the rule's conclusion is a disjunction: a
  future (resp. past) time carrying the event witness, or one carrying both the guard and the
  Until/Since itself.

Returns `false` for every other rule, so it is only ever consulted behind
`ruleMintsFreshLabel`.
-/
def witnessPresent (rule : TableauRule) (sf : SignedFormula) (branch : Branch)
    (timeOrd : TimeOrdering) : Bool :=
  let l := sf.label
  match rule, sf.sign, sf.formula with
  | .boxNeg, .neg, .box ψ =>
      branch.knownWorlds.any fun w =>
        branch.contains (SignedFormula.neg ψ { world := w, time := l.time })
  | .diamondPos, .pos, φ =>
      match asDiamond? φ with
      | some ψ =>
          branch.knownWorlds.any fun w =>
            branch.contains (SignedFormula.pos ψ { world := w, time := l.time })
      | none => false
  | .allFutureNeg, .neg, .allFuture ψ =>
      (timeOrd.futureOf l.time).any fun t =>
        branch.contains (SignedFormula.neg ψ { world := l.world, time := t })
  | .allPastNeg, .neg, .allPast ψ =>
      (timeOrd.pastOf l.time).any fun t =>
        branch.contains (SignedFormula.neg ψ { world := l.world, time := t })
  | .someFuturePos, .pos, φ =>
      match asSomeFuture? φ with
      | some ψ =>
          (timeOrd.futureOf l.time).any fun t =>
            branch.contains (SignedFormula.pos ψ { world := l.world, time := t })
      | none => false
  | .somePastPos, .pos, φ =>
      match asSomePast? φ with
      | some ψ =>
          (timeOrd.pastOf l.time).any fun t =>
            branch.contains (SignedFormula.pos ψ { world := l.world, time := t })
      | none => false
  | .untlPos, .pos, φ =>
      match asUntil? φ with
      | some (event, guard) =>
          (timeOrd.futureOf l.time).any fun t =>
            let lab : Label := { world := l.world, time := t }
            branch.contains (SignedFormula.pos event lab) ||
              (branch.contains (SignedFormula.pos guard lab) &&
               branch.contains (SignedFormula.pos (.untl event guard) lab))
      | none => false
  | .sncePos, .pos, φ =>
      match asSince? φ with
      | some (event, guard) =>
          (timeOrd.pastOf l.time).any fun t =>
            let lab : Label := { world := l.world, time := t }
            branch.contains (SignedFormula.pos event lab) ||
              (branch.contains (SignedFormula.pos guard lab) &&
               branch.contains (SignedFormula.pos (.snce event guard) lab))
      | none => false
  | _, _, _ => false

/--
Find a rule that applies to a signed formula.
Returns the first applicable rule, its result, and the updated TimeOrdering.

Every arm is branch-guarded: a rule whose conclusion the branch already carries is not
"applicable", so `findApplicableRule … = none` is a genuine downward-saturation statement
rather than a statement about what the engine happens to have tried. See the
"Uniform Branch Guards" section above for why the `.linear`/`.branching` guards must exist
and why the eight fresh-label rules use witness existence instead of output presence.
-/
def findApplicableRule (sf : SignedFormula) (branch : Branch := [])
    (timeOrd : TimeOrdering := TimeOrdering.empty)
    (fc : FrameClass := .Base) : Option (TableauRule × RuleResult × TimeOrdering) :=
  (allRulesForFC fc).findSome? fun rule =>
    if isApplicable rule sf fc then
      let (result, newOrd) := applyRule rule sf branch timeOrd
      match result with
      | .notApplicable => none
      | .linear fs =>
          if ruleMintsFreshLabel rule then
            if witnessPresent rule sf branch timeOrd then none
            else some (rule, result, newOrd)
          else if fs.all branch.contains then none
          else some (rule, result, newOrd)
      | .persistent _ =>
          -- No guard here, deliberately. Every `.persistent` arm of `applyRule` already
          -- filters its own output against `branch.contains` and returns `.notApplicable`
          -- when nothing new remains (the sole exception, `densityRule`, emits at a fresh
          -- time, so its output cannot be on the branch and it carries an equivalent
          -- `existingIntermediates` guard instead). A `fs.all branch.contains` test here
          -- would therefore always be false and never fire. Adding it anyway would be
          -- harmless operationally but would put an extra `if` between every saturation
          -- lemma and the rule's own filter structure, which is precisely what those
          -- lemmas read to extract their conclusion.
          some (rule, result, newOrd)
      | .branching bss =>
          -- Symmetric with the `.linear` arm: a fresh-label rule is tested for witness
          -- existence *instead of* output presence, never in addition to it. Its arms all
          -- live at a label the branch does not have, so the output-presence test could
          -- never fire there anyway; running both would only put a dead `if` between the
          -- saturation lemmas and the witness condition they need to read off.
          if ruleSelfGuarded rule then some (rule, result, newOrd)
          else if ruleMintsFreshLabel rule then
            (if witnessPresent rule sf branch timeOrd then none else some (rule, result, newOrd))
          else if bss.any (fun fs => fs.all branch.contains) then none
          else some (rule, result, newOrd)
      | .branchingOrdered _ =>
          -- No output-presence guard, and none is possible: the arms of an ordered split are
          -- replacement *branches*, so "the branch already contains this arm's output" is
          -- trivially true of every arm that adds no formula, which is every arm of the only
          -- rule that produces this constructor. What stops re-firing is the rule's own gate —
          -- it reports `.notApplicable` once no incomparable pair remains — exactly as the
          -- `.persistent` arm above relies on `applyRule`'s per-rule filters.
          some (rule, result, newOrd)
    else none

/--
Check if a signed formula is fully expanded (no rules apply).
Atoms, bot with appropriate signs, and already-reduced formulas are expanded.
-/
def isExpanded (sf : SignedFormula) (branch : Branch := [])
    (timeOrd : TimeOrdering := TimeOrdering.empty)
    (fc : FrameClass := .Base) : Bool :=
  (findApplicableRule sf branch timeOrd fc).isNone

/--
Find an unexpanded formula in a branch.
Returns the first formula that can still be expanded.
-/
def findUnexpanded (b : Branch) (timeOrd : TimeOrdering := TimeOrdering.empty)
    (fc : FrameClass := .Base) : Option SignedFormula :=
  b.find? (fun sf => ¬isExpanded sf b timeOrd fc)

/-!
## Blocking Against Saturated Ancestors Only

`findBlockedTime` (`SignedFormula.lean`) decides subset blocking from formula *content* alone:
time `t` is blocked by an ancestor `t_anc` when `type(t) ⊆ type(t_anc)` and every eventuality
pending at `t` is duplicated at `t_anc`. Its soundness story is "everything available at `t` is
already available at `t_anc`, so expanding `t` yields nothing new" — and that story is only true
of the *finished* type at `t_anc`. While `t_anc` still has an applicable rule, `type(t_anc)` is
a moving target: the containment being observed is an artifact of `t_anc` not having been
expanded yet, not evidence of a repetition.

Consuming that decision as "treat the whole branch as a saturated open branch"
(`Saturation.lean`) is where it does damage: the branch is handed back with propagation
outstanding, so a branch that would have closed instead reports open, or stalls.

**Measured instance.** Counterexample row B (`(F p ∧ F q) → (F(p ∧ F q) ∨ F(p ∧ q) ∨
F(q ∧ F p))`) at `.Dense`/`.Dedekind`: `densityRule` interpolates times 3 and 4 into `0 < 2`,
giving ordering `[(4,3),(0,4),(3,2),(0,3),(0,2),(0,1)]`. The interpolated times carry types that
are subsets of their ancestors' *because the ancestors have not finished expanding* —
`findUnexpanded` still points at `T(G ¬(p ∧ F q)) @ (0,0)`, i.e. at the root, which is an
ancestor of everything. Blocking fires against time 0 and the branch is abandoned. Under the
destructive engine the intermediate times carried fewer formulas and the subset test read
differently, which is why the defect only became visible with non-destructive expansion.

**The repair is a side condition, not a strengthening.** Note the direction carefully: this
predicate fires strictly *less* often than `findBlockedTime`, so it can only let expansion run
longer. It does not widen what counts as blocked, and it does not add a new halting reason.
The termination argument is unaffected — expansion remains fuel-bounded, and blocking was never
what bounded it.

**Why `t_anc` and not `t`.** The saturation demand is on the *ancestor*, the time whose type is
standing in for the blocked time's. Demanding it of `t` instead would be a different (and
wrong) predicate: `t`'s own unexpanded formulas are precisely what blocking is entitled to skip,
since the ancestor subsumes them.
-/

/--
Every formula on the branch at time `t` is fully expanded: no rule of `fc` applies to any of
them against the current branch.

This is `findUnexpanded` restricted to one time. It reads the same
`findApplicableRule`-is-`none` condition, so it inherits the uniform branch guards: a rule whose
conclusion the branch already carries does not count as applicable, and therefore does not keep
a time perpetually unsaturated.
-/
def timeSaturated (b : Branch) (t : TimeIndex)
    (timeOrd : TimeOrdering := TimeOrdering.empty)
    (fc : FrameClass := .Base) : Bool :=
  (b.formulasAtTime t).all fun sf => isExpanded sf b timeOrd fc

/--
The times `t` may be blocked *against*: order-related times that were created **earlier**.

`ancestorTimes` alone is `ord.pastOf t` (`SignedFormula.lean:782`), which is the right candidate
set only for chains that grow into the future. A time minted by `somePastPos` is placed strictly
before everything on the branch, so its `pastOf` is empty and it can never be blocked — and
`serialityRule` demands a predecessor at *every* label, so the past-directed chain
`T(P⊤)@t ⟶ t' ⟶ t'' ⟶ …` runs to fuel exhaustion. Measured before this repair: the bare atom `p`
at `.Base` consumed all 200 fuel, reaching 266 formulas over 68 times in 88 s; after it, 7 steps
in 1 ms.

The `t' < t` filter is what keeps the added arm well-founded: fresh times are minted at
`Branch.nextTime = maxTime + 1` (`SignedFormula.lean:363`), so numeric index order **is** creation
order, and a time can only be blocked by one created strictly before it. Without the filter a time
and its own future witness could block each other.

`ancestorTimes` is retained unfiltered, so this arm is purely additive: no candidate the previous
predicate considered is dropped. (Measured: with this change and seriality *off*, the entire
four-class corpus, `CertificateProbe` and `TimeOrderProbe` are unmoved.)
-/
def blockCandidates (ord : TimeOrdering) (t : TimeIndex) : List TimeIndex :=
  ancestorTimes ord t ++ (ord.futureOf t).filter (fun t' => t' < t)

/--
`isTemporallyBlocked` with the ancestor-saturation side condition: `t` is blocked by `t_anc`
only when `t_anc` itself has no applicable rule left.

See the section docstring above for why the side condition belongs here and why it cannot make
blocking fire more often. Candidates come from `blockCandidates`, not `ancestorTimes` — see that
definition for why blocking has to be bidirectional once `serialityRule` is scheduled.
-/
def isTemporallyBlockedSaturated (b : Branch) (t : TimeIndex) (ord : TimeOrdering)
    (fc : FrameClass := .Base)
    (tracker : EventualityTracker := EventualityTracker.empty) : Bool :=
  (blockCandidates ord t).any fun t_anc =>
    b.isSubsetBlocked t t_anc
      && allEventualitiesFulfilledOrDuplicated tracker t t_anc
      && timeSaturated b t_anc ord fc

/--
The first blocked time on the branch, blocking only against saturated ancestors.

This is the predicate the fuel loop consumes; `findBlockedTime` is retained in
`SignedFormula.lean` as the content-only core it is built from (and is still what the blocking
*lemmas* there are stated against, since those lemmas are about the subset condition itself).

The `&&` chain is short-circuiting, so the comparatively expensive `timeSaturated` call runs
only for ancestor pairs that already passed the cheap subset and eventuality tests.
-/
def findBlockedTimeSaturated (b : Branch) (ord : TimeOrdering)
    (fc : FrameClass := .Base)
    (tracker : EventualityTracker := EventualityTracker.empty) : Option TimeIndex :=
  b.knownTimes.find? fun t => isTemporallyBlockedSaturated b t ord fc tracker

/-!
## Blocking Blocks a Time, Not the Branch

The ancestor-saturation side condition above is necessary but not sufficient, and the measurement
says so. With it in place, row B at `.Dense` halts on a branch whose state is

```
len=35 times=[4,3,1,2,0] ord=[(4,3),(0,4),(3,2),(0,3),(0,2),(0,1)]
blockedSat=(some 3) unexpanded=(some @time 0)
```

Time 3 is genuinely blocked — by the interpolated time 4, which really is saturated, so the
side condition is satisfied and the block is legitimate *about time 3*. What is not legitimate
is the conclusion the fuel loop drew from it: it treated one blocked time as a verdict on the
whole branch and handed the branch back as "saturated open" with unexpanded work still sitting
at time 0, the root.

That is the eagerness. Blocking is a statement about a **time**: expanding *from* `t` cannot
produce anything the ancestor does not already offer. It says nothing about times that are not
blocked, and the root is never blocked (it has no ancestors). So a blocked time is skipped as an
expansion **source**, and the branch is saturated only when no *unblocked* formula has an
applicable rule.

Two consequences worth stating explicitly, because both are load-bearing elsewhere:

- **Termination is unchanged.** It was never blocking that bounded the loop — `expandBranchWithFuel`
  is fuel-bounded and `maxBranches`-bounded, and both bounds are untouched. Blocking's job is to
  let a branch *reach* a verdict sooner, and it still does that, one time at a time.
- **The open certificate's saturation field is now a disjunction.** An open branch satisfies
  `findUnexpandedUnblocked … = none`, which is `findUnexpanded … = none` only when nothing is
  blocked. Any consumer that wants literal full saturation must either check for it or accept the
  blocked disjunct and argue that the ancestor's type stands in for the blocked time's.
-/

/--
The times on the branch that are blocked by a saturated ancestor. Computed once per expansion
step and reused across the whole branch, rather than re-derived per formula.
-/
def blockedTimes (b : Branch) (ord : TimeOrdering) (fc : FrameClass := .Base)
    (tracker : EventualityTracker := EventualityTracker.empty) : List TimeIndex :=
  b.knownTimes.filter fun t => isTemporallyBlockedSaturated b t ord fc tracker

/--
`findUnexpanded` restricted to unblocked times: the first formula that has an applicable rule
and does not sit at a blocked time.

This is the engine's real saturation test. `findUnexpanded` remains the *literal* one and is
what the certificate probes and the truth-lemma statement read.
-/
def findUnexpandedUnblockedWith (b : Branch) (ord : TimeOrdering) (fc : FrameClass)
    (blocked : List TimeIndex) : Option SignedFormula :=
  b.find? fun sf => !blocked.contains sf.label.time && !isExpanded sf b ord fc

/--
`findUnexpandedUnblocked` computing its own blocked set.

Callers that also need the blocked set — the expansion step does, for its seriality stage — should
use `findUnexpandedUnblockedWith` and share one `blockedTimes` call. `blockedTimes` is the most
expensive thing in the inner loop (a saturation test per candidate ancestor pair), and computing
it twice per expansion step is the difference between a fast corpus run and a slow one.
-/
def findUnexpandedUnblocked (b : Branch) (ord : TimeOrdering) (fc : FrameClass := .Base)
    (tracker : EventualityTracker := EventualityTracker.empty) : Option SignedFormula :=
  findUnexpandedUnblockedWith b ord fc (blockedTimes b ord fc tracker)

/--
Result of a single expansion step on a branch.
-/
inductive ExpansionResult : Type where
  /-- Branch is fully saturated (no more expansions possible). -/
  | saturated
  /-- Single branch extension (non-branching rule applied). -/
  | extended (newBranch : Branch)
  /-- Branch splits into multiple branches (branching rule applied). -/
  | split (branches : List Branch)
  /--
  Branch splits into multiple branches, each carrying **its own** `TimeOrdering`.

  Additive counterpart of `.split`, which keeps its payload and its meaning verbatim. A consumer
  of `.split` passes the single post-step ordering to every sub-branch; a consumer of
  `.splitOrdered` passes each sub-branch the ordering paired with it. Produced only from
  `RuleResult.branchingOrdered`.
  -/
  | splitOrdered (branches : List (Branch × TimeOrdering))
  deriving Repr

/--
Perform a single expansion step on a branch.

Finds the first unexpanded formula and applies the appropriate rule.
Returns the result of the expansion together with the (possibly updated) TimeOrdering.

**Non-destructive.** No arm deletes the source formula. The `.linear` and `.branching` arms
used to (`remaining := b.filter (· != sf)`), which is what created the persistent/consumable
cycle the applied set was invented to suppress: a consumable rule would delete a formula a
persistent rule had produced, the persistent rule's `branch.contains` guard would then see
its own output missing, and the two would alternate forever. With the guards in
`findApplicableRule` covering all three arms, deletion is no longer needed to prevent
re-firing, and keeping the source buys two things: the branch is monotone, so its length is a
strict progress measure; and a time whose formulas were all consumed no longer disappears from
`Branch.knownTimes`, which is what made the ordering induced on the known times lossy.
-/
def expandOnce (b : Branch) (timeOrd : TimeOrdering := TimeOrdering.empty)
    (fc : FrameClass := .Base) : ExpansionResult × TimeOrdering :=
  -- Three-stage pick: ordinary rules over the whole branch first; only when *nothing* on the
  -- branch has an ordinary rule left does seriality get a turn; and only when seriality is also
  -- done does time linearity get one. See "Seriality is scheduled, not prioritised" and "When it
  -- is scheduled, it goes third, after seriality" — seriality mints times, linearity orders the
  -- times that exist, so linearity must run against a time structure nothing else will grow.
  match (match findUnexpanded b timeOrd fc with
         | some sf => findApplicableRule sf b timeOrd fc
         | none =>
             match findUnexpandedSerial b timeOrd with
             | some sf => findApplicableSerialRule sf b timeOrd
             | none =>
                 match findUnexpandedLinearity b timeOrd with
                 | some sf => findApplicableLinearityRule sf b timeOrd
                 | none => none) with
      | none => (.saturated, timeOrd)  -- Nothing applies in either stage
      | some (_, result, newOrd) =>
          match result with
          | .linear formulas =>
              (.extended (formulas ++ b), newOrd)
          | .branching branches =>
              (.split (branches.map fun newFormulas => newFormulas ++ b), newOrd)
          | .branchingOrdered branches =>
              -- Replacement branches: each arm already *is* the branch it describes.
              (.splitOrdered branches, newOrd)
          | .persistent formulas =>
              (.extended (formulas ++ b), newOrd)
          | .notApplicable => (.saturated, newOrd)  -- Shouldn't happen

/--
`expandOnce` with blocked times skipped as expansion sources.

This is the step the fuel loop takes. It differs from `expandOnce` only in which formula it
picks: `findUnexpandedUnblocked` rather than `findUnexpanded`. Reporting `.saturated` therefore
means "no unblocked work remains", which is the branch-level reading of blocking that the
per-time predicate actually supports — see "Blocking Blocks a Time, Not the Branch" above.

A formula produced *at* a blocked time (the `allFuturePos` family propagates into every future
time, blocked or not) is added to the branch as usual and then skipped as a source. It is not
discarded, because the countermodel read off the branch has to describe that time too.
-/
def expandOnceUnblocked (b : Branch) (timeOrd : TimeOrdering := TimeOrdering.empty)
    (fc : FrameClass := .Base)
    (tracker : EventualityTracker := EventualityTracker.empty)
    : ExpansionResult × TimeOrdering :=
  -- Same three-stage pick as `expandOnce`, with blocked times skipped in *every* stage. Skipping
  -- them in the seriality stage is what keeps the serial chain finite: seriality demands one more
  -- successor at every label, so without it the chain `T(F⊤)@t ⟶ t' ⟶ t'' ⟶ …` never stops.
  -- Each new time carries the same type, so blocking catches it within a step or two, and the
  -- rule then has no unblocked label left to serve.
  let blocked := blockedTimes b timeOrd fc tracker
  match (match findUnexpandedUnblockedWith b timeOrd fc blocked with
         | some sf => findApplicableRule sf b timeOrd fc
         | none =>
             match b.find? (fun (sf : SignedFormula) => !blocked.contains sf.label.time
                 && (findApplicableSerialRule sf b timeOrd).isSome) with
             | some sf => findApplicableSerialRule sf b timeOrd
             | none =>
                 match b.find? (fun (sf : SignedFormula) => !blocked.contains sf.label.time
                     && (findApplicableLinearityRule sf b timeOrd).isSome) with
                 | some sf => findApplicableLinearityRule sf b timeOrd
                 | none => none) with
      | none => (.saturated, timeOrd)
      | some (_, result, newOrd) =>
          match result with
          | .linear formulas => (.extended (formulas ++ b), newOrd)
          | .branching branches =>
              (.split (branches.map fun newFormulas => newFormulas ++ b), newOrd)
          | .branchingOrdered branches => (.splitOrdered branches, newOrd)
          | .persistent formulas => (.extended (formulas ++ b), newOrd)
          | .notApplicable => (.saturated, newOrd)

/--
A single expansion step restricted to rules that introduce **no new label** — neither a fresh
world nor a fresh time.

This is the step the post-blocking pass needs. That pass exists to finish the propositional
and propagation work still outstanding on a branch that time-blocking halted, without
extending the time structure the blocking decision was made against.

Its predecessor asked `expandOnce` for *the* next step and abandoned the whole branch when
that step happened to introduce a time. That is too brittle to survive non-destructive
expansion: the source formulas now stay on the branch, so the first formula `findUnexpanded`
lands on is frequently a temporal existential, and the pass would give up with ordinary
propositional work still pending. Here the label-introducing candidates are *skipped* and the
search continues, so the pass stops only when no label-free work remains at all.

The test is exact rather than a rule list: a candidate is rejected if it mints a fresh world
(`ruleMintsFreshLabel`) or if applying it would lengthen the ordering constraints. That covers
`densityRule` and the active-mode arms of `untlNeg`/`snceNeg`, which introduce times without
being witness-guarded, and it stays correct if a future rule does the same.
-/
def expandOnceNoFresh (b : Branch) (timeOrd : TimeOrdering := TimeOrdering.empty)
    (fc : FrameClass := .Base) : ExpansionResult × TimeOrdering :=
  let pick := b.findSome? fun sf =>
    match findApplicableRule sf b timeOrd fc with
    | some (rule, result, newOrd) =>
        if ruleMintsFreshLabel rule then none
        else if newOrd.constraints.length > timeOrd.constraints.length then none
        else some (result, newOrd)
    | none => none
  match pick with
  | none => (.saturated, timeOrd)
  | some (result, newOrd) =>
      match result with
      | .linear formulas => (.extended (formulas ++ b), newOrd)
      | .branching branches => (.split (branches.map fun fs => fs ++ b), newOrd)
      | .branchingOrdered branches => (.splitOrdered branches, newOrd)
      | .persistent formulas => (.extended (formulas ++ b), newOrd)
      | .notApplicable => (.saturated, newOrd)

/-!
## Expansion Makes Progress

The termination argument for `expandBranchWithFuel` needs to know that an `.extended` step is
not a no-op. Two facts are proved here, in increasing strength:

- `expandOnceUnblocked_length_lt` — `b.length < nb.length`. What the plan names, and a useful
  sanity check on the guards.
- `expandOnceUnblocked_adds_new` — `b ⊆ nb ∧ ∃ g ∈ nb, g ∉ b`. What the fuel bound can actually
  consume. Strict length increase does **not** bound the step count on its own: expansion is
  non-destructive, `nb = fs ++ b`, and `fs` may re-add formulas already present, so `List.length`
  has no upper bound. Set growth against the finite signed closure × label set does bound it.

Both reduce to the same question — can a rule that the guards let through return an empty
result? — and the answer is per-rule. The chain below settles it once, at the `applyRule` level,
and the two statements about `expandOnceUnblocked` then follow by destructuring its two-stage
pick.

**Tactic note, recorded because it cost four failed attempts.** `split at h` cannot see through
a `Prod.fst` projection, so the seven `if newFormulas.isEmpty then …` guards inside `applyRule`
survive `repeat' split at h` as unopened `(if c then … else …).1 = …` hypotheses, and the goal
that remains *looks* like a statement about `filterMap` because the guard that discharges it is
still sealed inside the `ite`. Interleaving `simp only [apply_ite Prod.fst] at h` opens all of
them and leaves `¬ l.isEmpty = true → l ≠ []`, which `simp` closes. No `filterMap` lemma is
needed. Relatedly, do not write the closer as `first | simp_all | <fallback>`: `simp_all` reports
success whenever it makes *any* progress, even leaving the goal open, so the fallback is
unreachable.
-/

section ProgressLemmas

-- The three `applyRule`-level sweeps each analyse 36 constructors; measured at roughly 80 s of
-- elaboration, which is above the default heartbeat budget but not the wall-clock budget.
set_option maxHeartbeats 2000000

/-- A `.persistent` result is never empty.

The 14 `.persistent` return sites of `applyRule` divide into three kinds, and each is
self-guarding: 7 sit behind `if newFormulas.isEmpty then .notApplicable else …`, 6 return a
literal singleton `[newSf]`, and 1 (`densityRule`) returns a syntactic cons `witness :: gProps`.
Post-seriality there is a 15th, of the first kind. -/
theorem applyRule_persistent_ne_nil
    {rule : TableauRule} {sf : SignedFormula} {b : Branch} {ord : TimeOrdering}
    {fs : List SignedFormula}
    (h : (applyRule rule sf b ord).1 = RuleResult.persistent fs) : fs ≠ [] := by
  unfold applyRule at h
  repeat' first
    | split at h
    | simp only [apply_ite Prod.fst] at h
  all_goals (try (injection h with h))
  all_goals first
    | (simp_all; done)
    | (subst h; simp_all)

/-- A `.linear` result of a fresh-label rule is never empty.

All eight `ruleMintsFreshLabel` constructors return a syntactic cons whose head is the witness
at the fresh label, so `List.cons_ne_nil` closes each. `cases rule` **before** unfolding is
load-bearing: it discharges the 28 non-fresh constructors from `hfresh : false = true` and keeps
`unfold applyRule` off them entirely. -/
theorem applyRule_fresh_linear_ne_nil
    {rule : TableauRule} {sf : SignedFormula} {b : Branch} {ord : TimeOrdering}
    {fs : List SignedFormula}
    (hfresh : ruleMintsFreshLabel rule = true)
    (h : (applyRule rule sf b ord).1 = RuleResult.linear fs) : fs ≠ [] := by
  cases rule <;> simp only [ruleMintsFreshLabel] at hfresh <;>
    (unfold applyRule at h
     repeat' first
       | split at h
       | simp only [apply_ite Prod.fst] at h)
  all_goals (try (injection h with h))
  all_goals first
    | (simp_all; done)
    | (subst h; simp_all)

/-- Every arm of a `.branching` result of a fresh-label rule is non-empty.

The two branching fresh-label rules return `.branching [branch1 ++ autoProp, branch2 ++ autoProp]`
with `branch1 = [SignedFormula.pos event freshLabel]`, so each arm is a cons. -/
theorem applyRule_fresh_branching_ne_nil
    {rule : TableauRule} {sf : SignedFormula} {b : Branch} {ord : TimeOrdering}
    {bss : List (List SignedFormula)}
    (hfresh : ruleMintsFreshLabel rule = true)
    (h : (applyRule rule sf b ord).1 = RuleResult.branching bss) :
    ∀ fs ∈ bss, fs ≠ [] := by
  cases rule <;> simp only [ruleMintsFreshLabel] at hfresh <;>
    (unfold applyRule at h
     repeat' first
       | split at h
       | simp only [apply_ite Prod.fst] at h)
  all_goals (try (injection h with h))
  all_goals first
    | (simp_all; done)
    | (subst h; simp_all)

/-- The ordinary-rule pick never returns an empty extension.

Three details are load-bearing and were each found by measurement:
`FrameClass` must be written `ProofSystem.FrameClass` here, or the binder resolves to the wrong
constant; `List.exists_of_findSome?_eq_some` is the right entry point (`List.findSome?_eq_some_iff`
also exists but yields a three-way list decomposition that is strictly more work); and
`rcases h` must come **before** unfolding, so `res` is already `.linear fs` / `.persistent fs`
when the splits run. `congrArg Prod.fst (by assumption)` is what converts the split's
`applyRule rule sf b ord = (res, ord')` into the `.1`-form the `applyRule` lemmas want — `simp_all`
cannot do it, because that equation is inaccessible-named. -/
theorem findApplicableRule_extending_ne_nil
    {sf : SignedFormula} {b : Branch} {ord : TimeOrdering} {fc : ProofSystem.FrameClass}
    {rule : TableauRule} {ord' : TimeOrdering} {fs : List SignedFormula}
    (h : findApplicableRule sf b ord fc = some (rule, RuleResult.linear fs, ord')
       ∨ findApplicableRule sf b ord fc = some (rule, RuleResult.persistent fs, ord')) :
    fs ≠ [] := by
  rcases h with h | h <;>
    (unfold findApplicableRule at h
     obtain ⟨r, _, hr⟩ := List.exists_of_findSome?_eq_some h
     repeat' split at hr)
  all_goals simp_all
  all_goals first
    | exact applyRule_fresh_linear_ne_nil (by assumption) (congrArg Prod.fst (by assumption))
    | exact applyRule_persistent_ne_nil (congrArg Prod.fst (by assumption))
    | (intro hnil; subst hnil; simp_all)

/-- The seriality pick never returns an empty extension.

`by_cases` rather than `split` here: the guard sits in a `match` *scrutinee*, which `split at h`
does not reach. -/
theorem findApplicableSerialRule_ne_nil
    {sf : SignedFormula} {b : Branch} {ord : TimeOrdering}
    {rule : TableauRule} {ord' : TimeOrdering} {fs : List SignedFormula}
    (h : findApplicableSerialRule sf b ord = some (rule, RuleResult.persistent fs, ord')) :
    fs ≠ [] := by
  unfold findApplicableSerialRule serialityRules at h
  simp only [List.findSome?_cons, List.findSome?_nil, applyRule] at h
  by_cases hE : ([SignedFormula.pos Syntax.Formula.top.someFuture sf.label,
                  SignedFormula.pos Syntax.Formula.top.somePast sf.label].filter
                    (fun f => !b.contains f)).isEmpty = true
  · simp only [hE, if_pos] at h; simp at h
  · simp only [hE, if_false, Bool.false_eq_true] at h
    simp at h
    obtain ⟨-, hres, -⟩ := h
    rw [← hres]
    simpa using hE

/-- The seriality pick never returns a `.linear` result.

`serialityRule`'s `applyRule` arm returns `.notApplicable` or `.persistent outs` and nothing
else, so the `.linear` arm of the pick is unreachable through it. Needed because
`expandOnceUnblocked`'s result tail treats `.linear` and `.persistent` alike, so both have to be
discharged when the seriality stage supplied the pick. -/
theorem findApplicableSerialRule_not_linear
    {sf : SignedFormula} {b : Branch} {ord : TimeOrdering}
    {rule : TableauRule} {ord' : TimeOrdering} {fs : List SignedFormula}
    (h : findApplicableSerialRule sf b ord = some (rule, RuleResult.linear fs, ord')) :
    False := by
  unfold findApplicableSerialRule serialityRules at h
  simp only [List.findSome?_cons, List.findSome?_nil, applyRule] at h
  by_cases hE : ([SignedFormula.pos Syntax.Formula.top.someFuture sf.label,
                  SignedFormula.pos Syntax.Formula.top.somePast sf.label].filter
                    (fun f => !b.contains f)).isEmpty = true
  · simp only [hE, if_pos] at h; simp at h
  · simp only [hE, if_false, Bool.false_eq_true] at h
    simp at h

/--
The linearity stage never reports `.linear`.

`timeLinearity`'s `applyRule` arm returns `.notApplicable` or `.branchingOrdered` and nothing
else, and `findApplicableLinearityRule` discards the former, so the stage's only possible result
is an ordered split. Stated as two lemmas (`_not_linear`, `_not_persistent`) rather than one
existential because that is the shape `expandOnceUnblocked_pick_ne_nil` consumes.
-/
theorem findApplicableLinearityRule_not_linear
    {sf : SignedFormula} {b : Branch} {ord : TimeOrdering}
    {rule : TableauRule} {ord' : TimeOrdering} {fs : List SignedFormula}
    (h : findApplicableLinearityRule sf b ord = some (rule, RuleResult.linear fs, ord')) :
    False := by
  unfold findApplicableLinearityRule linearityRules at h
  simp only [List.findSome?_cons, List.findSome?_nil, applyRule] at h
  -- `rcases` on the trigger rather than `split at h`: the result sits under a `Prod.fst`
  -- projection, which `split` cannot see through (the tactic note in the ProgressLemmas
  -- section records the same obstacle).
  rcases hc : firstIncomparablePair b ord with _ | pr <;> rw [hc] at h <;> simp at h

/-- The linearity stage never reports `.persistent`; see `findApplicableLinearityRule_not_linear`. -/
theorem findApplicableLinearityRule_not_persistent
    {sf : SignedFormula} {b : Branch} {ord : TimeOrdering}
    {rule : TableauRule} {ord' : TimeOrdering} {fs : List SignedFormula}
    (h : findApplicableLinearityRule sf b ord = some (rule, RuleResult.persistent fs, ord')) :
    False := by
  unfold findApplicableLinearityRule linearityRules at h
  simp only [List.findSome?_cons, List.findSome?_nil, applyRule] at h
  -- `rcases` on the trigger rather than `split at h`: the result sits under a `Prod.fst`
  -- projection, which `split` cannot see through (the tactic note in the ProgressLemmas
  -- section records the same obstacle).
  rcases hc : firstIncomparablePair b ord with _ | pr <;> rw [hc] at h <;> simp at h

/-- The result tail shared by `expandOnce`, `expandOnceUnblocked` and `expandOnceNoFresh`,
factored out over an abstract pick.

Reporting `.extended nb` means the pick supplied a `.linear` or `.persistent` result and `nb` is
that result appended to `b`. Stating it over an abstract `pick` is what lets the two-stage
seriality pick be destructured *afterwards*: a hypothesis about the two-stage `match` as a whole
is not something the `findApplicableRule`-level lemmas can consume. -/
theorem pick_extended
    {b nb : Branch} {ord : TimeOrdering}
    {pick : Option (TableauRule × RuleResult × TimeOrdering)}
    (h : (match pick with
          | none => (ExpansionResult.saturated, ord)
          | some (_, result, newOrd) =>
            match result with
            | .linear fs => (ExpansionResult.extended (fs ++ b), newOrd)
            | .branching bss => (ExpansionResult.split (bss.map fun fs => fs ++ b), newOrd)
            | .branchingOrdered bs => (ExpansionResult.splitOrdered bs, newOrd)
            | .persistent fs => (ExpansionResult.extended (fs ++ b), newOrd)
            | .notApplicable => (ExpansionResult.saturated, newOrd)).1
         = ExpansionResult.extended nb) :
    ∃ r fs o, (pick = some (r, RuleResult.linear fs, o)
                ∨ pick = some (r, RuleResult.persistent fs, o)) ∧ nb = fs ++ b := by
  rcases pick with _ | ⟨r, res, o⟩
  · simp at h
  · cases res with
    | notApplicable => simp at h
    | branching bss => simp at h
    | branchingOrdered bs => simp at h
    | linear fs => exact ⟨r, fs, o, Or.inl rfl, by simpa using h.symm⟩
    | persistent fs => exact ⟨r, fs, o, Or.inr rfl, by simpa using h.symm⟩

/-- An `.extended` step of `expandOnceUnblocked` appends a non-empty list to the branch.

The proof destructures the two-stage pick — ordinary rules first, seriality only when
`findUnexpandedUnblockedWith` returns `none` — and hands each stage to its own non-emptiness
lemma. `rw` rather than `simp` on the stage equations is deliberate: `simp` normalises
`List.contains` to `decide (· ∈ ·)`, after which the equation for the seriality stage's `find?`
no longer matches the form the `rcases` produced. -/
theorem expandOnceUnblocked_pick_ne_nil
    {b nb : Branch} {ord : TimeOrdering} {fc : ProofSystem.FrameClass}
    {tr : EventualityTracker}
    (h : (expandOnceUnblocked b ord fc tr).1 = ExpansionResult.extended nb) :
    ∃ fs, fs ≠ [] ∧ nb = fs ++ b := by
  unfold expandOnceUnblocked at h
  obtain ⟨r, fs, o, hp, rfl⟩ := pick_extended h
  refine ⟨fs, ?_, rfl⟩
  rcases hpick : findUnexpandedUnblockedWith b ord fc (blockedTimes b ord fc tr) with _ | sf
  · rw [hpick] at hp
    rcases hser : b.find? (fun sf => !(blockedTimes b ord fc tr).contains sf.label.time
                             && (findApplicableSerialRule sf b ord).isSome) with _ | sf2
    · rw [hser] at hp
      -- Third stage: time linearity. It can only report `.branchingOrdered`, so an `.extended`
      -- step cannot have come from here; the two stage lemmas discharge both `pick_extended`
      -- alternatives outright.
      rcases hlin : b.find? (fun sf => !(blockedTimes b ord fc tr).contains sf.label.time
                               && (findApplicableLinearityRule sf b ord).isSome) with _ | sf3
      · rw [hlin] at hp
        simp only at hp
        rcases hp with hp | hp <;> exact absurd hp (by simp)
      · rw [hlin] at hp
        simp only at hp
        rcases hp with hp | hp
        · exact absurd hp (fun hc => findApplicableLinearityRule_not_linear hc)
        · exact absurd hp (fun hc => findApplicableLinearityRule_not_persistent hc)
    · rw [hser] at hp
      simp only at hp
      rcases hp with hp | hp
      · exact absurd hp (fun hc => findApplicableSerialRule_not_linear hc)
      · exact findApplicableSerialRule_ne_nil hp
  · rw [hpick] at hp
    simp only at hp
    rcases hp with hp | hp
    · exact findApplicableRule_extending_ne_nil (Or.inl hp)
    · exact findApplicableRule_extending_ne_nil (Or.inr hp)

/-- An `.extended` step strictly lengthens the branch.

This is the lemma the plan names (as `expandOnce_length_lt`; `expandOnce` has no proof-path
caller, so it is stated here for the function `expandBranchWithFuel` actually calls). It is a
sanity check on the guards rather than the termination measure — see the section docstring for
why `List.length` cannot bound the step count on its own. -/
theorem expandOnceUnblocked_length_lt
    {b nb : Branch} {ord : TimeOrdering} {fc : ProofSystem.FrameClass}
    {tr : EventualityTracker}
    (h : (expandOnceUnblocked b ord fc tr).1 = ExpansionResult.extended nb) :
    b.length < nb.length := by
  obtain ⟨fs, hne, rfl⟩ := expandOnceUnblocked_pick_ne_nil h
  have : 0 < fs.length := List.length_pos_iff.mpr hne
  simp only [List.length_append]
  omega

/-! ### Freshness and the `contains`/`∈` bridge

`length_lt` needs only "the appended list is non-empty". `adds_new` needs "one of its elements is
off the branch", and two of the ways a rule can guarantee that are not `branch.contains` tests:
`densityRule`'s interpolant and every fresh-label rule's witness are off-branch *by freshness*,
because they live at `Branch.nextTime` / `Branch.nextWorld`. -/

private theorem le_foldl_max (f : SignedFormula → Nat) :
    ∀ (l : List SignedFormula) (a : Nat), a ≤ l.foldl (fun x s => max x (f s)) a := by
  intro l
  induction l with
  | nil => intro a; simp
  | cons x xs ih =>
      intro a
      simp only [List.foldl_cons]
      exact le_trans (le_max_left a (f x)) (ih _)

private theorem mem_le_foldl_max (f : SignedFormula → Nat) :
    ∀ (l : List SignedFormula) {sf : SignedFormula}, sf ∈ l →
      ∀ a : Nat, f sf ≤ l.foldl (fun x s => max x (f s)) a := by
  intro l
  induction l with
  | nil => intro sf h; cases h
  | cons x xs ih =>
      intro sf h a
      simp only [List.foldl_cons]
      rcases List.mem_cons.mp h with rfl | h
      · exact le_trans (le_max_right a (f sf)) (le_foldl_max f xs _)
      · exact ih h _

/-- Every formula on the branch sits at or below `Branch.maxTime`. -/
theorem le_maxTime {b : Branch} {sf : SignedFormula} (h : sf ∈ b) :
    sf.label.time ≤ b.maxTime :=
  mem_le_foldl_max (fun s => s.label.time) b h 0

/-- Every formula on the branch sits at or below `Branch.maxWorld`. -/
theorem le_maxWorld {b : Branch} {sf : SignedFormula} (h : sf ∈ b) :
    sf.label.world ≤ b.maxWorld :=
  mem_le_foldl_max (fun s => s.label.world) b h 0

/-- A formula at the branch's fresh time is not on the branch. This is what makes
`Branch.nextTime` a *fresh* time rather than merely a new numeral. -/
theorem not_mem_of_time_nextTime {b : Branch} {sf : SignedFormula}
    (h : sf.label.time = b.nextTime) : sf ∉ b := by
  intro hmem
  have := le_maxTime hmem
  rw [h] at this
  unfold Branch.nextTime at this
  exact Nat.not_succ_le_self _ this

/-- A formula at the branch's fresh world is not on the branch. -/
theorem not_mem_of_world_nextWorld {b : Branch} {sf : SignedFormula}
    (h : sf.label.world = b.nextWorld) : sf ∉ b := by
  intro hmem
  have := le_maxWorld hmem
  rw [h] at this
  unfold Branch.nextWorld at this
  exact Nat.not_succ_le_self _ this

/-- `Branch.contains` is `b.any (· == ·)`, not `List.contains`, so the standard membership
simp set does not bridge it. This is the bridge. -/
theorem not_mem_of_contains_false {b : Branch} {g : SignedFormula}
    (h : b.contains g = false) : g ∉ b := by
  unfold Branch.contains at h
  simp only [List.any_eq_false] at h
  intro hmem
  have := h g hmem
  simp at this

/-- The `Branch.contains`/`∈` bridge as an iff, for use in `simp` sets. -/
theorem contains_eq_false_iff {b : Branch} {g : SignedFormula} :
    b.contains g = false ↔ g ∉ b := by
  constructor
  · exact not_mem_of_contains_false
  · intro h
    by_contra hc
    simp only [Bool.not_eq_false] at hc
    unfold Branch.contains at hc
    simp only [List.any_eq_true] at hc
    obtain ⟨x, hx, hxe⟩ := hc
    exact h (by simpa [eq_of_beq hxe] using hx)

/-- The non-fresh `.linear`/`.branching` guard, read as a membership witness.

`fs.all branch.contains = false` is exactly "some element of `fs` is off the branch" — the guard
delivers the *specific* `g` that `adds_new` needs, not merely `fs ≠ []`. -/
theorem exists_not_mem_of_all_contains_false {b : Branch} {fs : List SignedFormula}
    (h : fs.all b.contains = false) : ∃ g ∈ fs, g ∉ b := by
  simp only [List.all_eq_false] at h
  obtain ⟨g, hg, hc⟩ := h
  exact ⟨g, hg, not_mem_of_contains_false (by simpa using hc)⟩

/-- Bundle non-emptiness with an all-elements-off-branch fact into the existential. -/
theorem exists_of_ne_nil_of_forall_not_mem {b : Branch} {fs : List SignedFormula}
    (hne : fs ≠ []) (hnm : ∀ g ∈ fs, g ∉ b) : ∃ g ∈ fs, g ∉ b := by
  cases fs with
  | nil => exact absurd rfl hne
  | cons x xs => exact ⟨x, List.mem_cons_self, hnm x List.mem_cons_self⟩

/-! ### Set growth -/

/-- **Every** formula a `.persistent` rule emits is off the branch.

Stronger than needed, and true for a reason worth recording: 14 of the 15 `.persistent` arms
build their output by filtering against `branch.contains`, so the property is immediate; the
15th (`densityRule`) emits its interpolant at `Branch.nextTime` and its propagated `T(G A)`
consequences at the same fresh time, so freshness covers it. -/
theorem applyRule_persistent_not_mem
    {rule : TableauRule} {sf : SignedFormula} {b : Branch} {ord : TimeOrdering}
    {fs : List SignedFormula}
    (h : (applyRule rule sf b ord).1 = RuleResult.persistent fs) : ∀ g ∈ fs, g ∉ b := by
  unfold applyRule at h
  repeat' first
    | split at h
    | simp only [apply_ite Prod.fst] at h
  all_goals (try (injection h with h))
  all_goals first
    | (simp_all [contains_eq_false_iff]; done)
    | (subst h; simp_all [contains_eq_false_iff])
  all_goals first
    | (rintro g x hx hnm rfl; exact hnm)
    | (refine ⟨not_mem_of_time_nextTime rfl, ?_⟩
       intro a x hx hm
       repeat' split at hm
       all_goals first
         | (injection hm with hm; subst hm; exact not_mem_of_time_nextTime rfl)
         | (simp at hm))

/-- A `.persistent` step contributes a formula the branch did not already carry. -/
theorem applyRule_persistent_adds_new
    {rule : TableauRule} {sf : SignedFormula} {b : Branch} {ord : TimeOrdering}
    {fs : List SignedFormula}
    (h : (applyRule rule sf b ord).1 = RuleResult.persistent fs) : ∃ g ∈ fs, g ∉ b :=
  exists_of_ne_nil_of_forall_not_mem (applyRule_persistent_ne_nil h)
    (applyRule_persistent_not_mem h)

/-- A fresh-label `.linear` step contributes its witness, which is off-branch by freshness.

All eight fresh-label constructors return `witness :: …` with the witness at
`Branch.nextWorld` (the modal rules) or `Branch.nextTime` (the temporal ones), so the head of the
list is the required element in every case. -/
theorem applyRule_fresh_linear_adds_new
    {rule : TableauRule} {sf : SignedFormula} {b : Branch} {ord : TimeOrdering}
    {fs : List SignedFormula}
    (hfresh : ruleMintsFreshLabel rule = true)
    (h : (applyRule rule sf b ord).1 = RuleResult.linear fs) : ∃ g ∈ fs, g ∉ b := by
  cases rule <;> simp only [ruleMintsFreshLabel] at hfresh <;>
    (unfold applyRule at h
     repeat' first
       | split at h
       | simp only [apply_ite Prod.fst] at h)
  all_goals (try (injection h with h))
  all_goals (try (simp_all; done))
  all_goals (try (subst h))
  all_goals first
    | (exact ⟨_, List.mem_cons_self, not_mem_of_world_nextWorld rfl⟩)
    | (exact ⟨_, List.mem_cons_self, not_mem_of_time_nextTime rfl⟩)

/-- The seriality pick contributes a formula the branch did not already carry. -/
theorem findApplicableSerialRule_adds_new
    {sf : SignedFormula} {b : Branch} {ord : TimeOrdering}
    {rule : TableauRule} {ord' : TimeOrdering} {fs : List SignedFormula}
    (h : findApplicableSerialRule sf b ord = some (rule, RuleResult.persistent fs, ord')) :
    ∃ g ∈ fs, g ∉ b := by
  unfold findApplicableSerialRule serialityRules at h
  simp only [List.findSome?_cons, List.findSome?_nil] at h
  rcases hA : applyRule TableauRule.serialityRule sf b ord with ⟨res, o⟩
  rw [hA] at h
  simp only at h
  cases res <;> simp at h
  obtain ⟨-, hres, -⟩ := h
  subst hres
  exact applyRule_persistent_adds_new (by rw [hA])

/-- The ordinary-rule pick contributes a formula the branch did not already carry.

Three sources, one per guard: the non-fresh `.linear` arm's `fs.all branch.contains = false`,
the fresh-label arm's witness, and the `.persistent` arms' own filters. -/
theorem findApplicableRule_extending_adds_new
    {sf : SignedFormula} {b : Branch} {ord : TimeOrdering} {fc : ProofSystem.FrameClass}
    {rule : TableauRule} {ord' : TimeOrdering} {fs : List SignedFormula}
    (h : findApplicableRule sf b ord fc = some (rule, RuleResult.linear fs, ord')
       ∨ findApplicableRule sf b ord fc = some (rule, RuleResult.persistent fs, ord')) :
    ∃ g ∈ fs, g ∉ b := by
  rcases h with h | h <;>
    (unfold findApplicableRule at h
     obtain ⟨r, _, hr⟩ := List.exists_of_findSome?_eq_some h
     repeat' split at hr)
  all_goals simp_all
  all_goals first
    | exact applyRule_fresh_linear_adds_new (by assumption) (congrArg Prod.fst (by assumption))
    | exact applyRule_persistent_adds_new (congrArg Prod.fst (by assumption))
    | (rename_i hguard
       obtain ⟨x, hx, hc⟩ := hguard
       exact ⟨x, hx, not_mem_of_contains_false hc⟩)

/-- An `.extended` step appends a list containing at least one formula the branch lacked. -/
theorem expandOnceUnblocked_pick_adds_new
    {b nb : Branch} {ord : TimeOrdering} {fc : ProofSystem.FrameClass}
    {tr : EventualityTracker}
    (h : (expandOnceUnblocked b ord fc tr).1 = ExpansionResult.extended nb) :
    ∃ fs, (∃ g ∈ fs, g ∉ b) ∧ nb = fs ++ b := by
  unfold expandOnceUnblocked at h
  obtain ⟨r, fs, o, hp, rfl⟩ := pick_extended h
  refine ⟨fs, ?_, rfl⟩
  rcases hpick : findUnexpandedUnblockedWith b ord fc (blockedTimes b ord fc tr) with _ | sf
  · rw [hpick] at hp
    rcases hser : b.find? (fun sf => !(blockedTimes b ord fc tr).contains sf.label.time
                             && (findApplicableSerialRule sf b ord).isSome) with _ | sf2
    · rw [hser] at hp
      -- Third stage: time linearity, which only ever reports `.branchingOrdered`.
      rcases hlin : b.find? (fun sf => !(blockedTimes b ord fc tr).contains sf.label.time
                               && (findApplicableLinearityRule sf b ord).isSome) with _ | sf3
      · rw [hlin] at hp
        simp only at hp
        rcases hp with hp | hp <;> exact absurd hp (by simp)
      · rw [hlin] at hp
        simp only at hp
        rcases hp with hp | hp
        · exact absurd hp (fun hc => findApplicableLinearityRule_not_linear hc)
        · exact absurd hp (fun hc => findApplicableLinearityRule_not_persistent hc)
    · rw [hser] at hp
      simp only at hp
      rcases hp with hp | hp
      · exact absurd hp (fun hc => findApplicableSerialRule_not_linear hc)
      · exact findApplicableSerialRule_adds_new hp
  · rw [hpick] at hp
    simp only at hp
    rcases hp with hp | hp
    · exact findApplicableRule_extending_adds_new (Or.inl hp)
    · exact findApplicableRule_extending_adds_new (Or.inr hp)

/-- **The progress measure the fuel bound can consume**: expansion is non-destructive and
strictly grows the branch *as a set*.

This, and not `expandOnceUnblocked_length_lt`, is what bounds the step count. `nb = fs ++ b` may
re-add formulas already present, so `List.length` has no upper bound and strict length increase
alone permits an unbounded run. Set growth against the finite signed closure × label set does
not. -/
theorem expandOnceUnblocked_adds_new
    {b nb : Branch} {ord : TimeOrdering} {fc : ProofSystem.FrameClass}
    {tr : EventualityTracker}
    (h : (expandOnceUnblocked b ord fc tr).1 = ExpansionResult.extended nb) :
    b ⊆ nb ∧ ∃ g ∈ nb, g ∉ b := by
  obtain ⟨fs, ⟨g, hg, hgb⟩, rfl⟩ := expandOnceUnblocked_pick_adds_new h
  exact ⟨List.subset_append_right _ _, g, List.mem_append_left _ hg, hgb⟩

end ProgressLemmas

/-!
## The Applied Set, Demoted

The applied set existed to break the persistent/consumable cycle described in the
"Uniform Branch Guards" section. The branch guards plus non-destructive expansion break that
cycle at its source, so the applied set has nothing left to suppress, and it must not be
allowed to suppress anything: a rule filtered out by the applied set rather than by the branch
is a rule whose conclusion may be *absent* from the branch, which is exactly the orphan
situation that stopped the open-branch certificate from meaning downward saturation.

The four functions below are therefore **inert wrappers**: they ignore the `applied` argument
entirely and delegate to the guarded, non-destructive versions, always reporting an empty
applied-set delta. The signatures are kept only so that the certificate and the fuel loop can
be moved off them in a separate step; nothing depends on the applied set's contents any more,
and an open certificate's applied set is now always empty.
-/

/--
Deprecated in substance: delegates to `findApplicableRule`, ignoring `applied`.
Always reports an empty applied-set delta.
-/
def findApplicableRuleWithApplied (sf : SignedFormula) (branch : Branch := [])
    (timeOrd : TimeOrdering := TimeOrdering.empty)
    (fc : FrameClass := .Base)
    (_applied : AppliedSet := {}) :
      Option (TableauRule × RuleResult × TimeOrdering × List SignedFormula) :=
  match findApplicableRule sf branch timeOrd fc with
  | none => none
  | some (rule, result, newOrd) => some (rule, result, newOrd, [])

/-- Deprecated in substance: agrees with `isExpanded`, ignoring `applied`. -/
def isExpandedWithApplied (sf : SignedFormula) (branch : Branch := [])
    (timeOrd : TimeOrdering := TimeOrdering.empty)
    (fc : FrameClass := .Base)
    (applied : AppliedSet := {}) : Bool :=
  (findApplicableRuleWithApplied sf branch timeOrd fc applied).isNone

/-- Deprecated in substance: agrees with `findUnexpanded`, ignoring `applied`. -/
def findUnexpandedWithApplied (b : Branch) (timeOrd : TimeOrdering := TimeOrdering.empty)
    (fc : FrameClass := .Base)
    (applied : AppliedSet := {}) : Option SignedFormula :=
  b.find? (fun sf => ¬isExpandedWithApplied sf b timeOrd fc applied)

/--
Deprecated in substance: delegates to `expandOnce`, ignoring `applied` and always reporting
an empty applied-set delta.
-/
def expandOnceWithApplied (b : Branch) (timeOrd : TimeOrdering := TimeOrdering.empty)
    (fc : FrameClass := .Base) (_applied : AppliedSet := {})
    : ExpansionResult × TimeOrdering × List SignedFormula :=
  let (result, newOrd) := expandOnce b timeOrd fc
  (result, newOrd, [])

/--
Deprecated in substance: delegates to `expandOnceUnblocked`, ignoring `applied` and always
reporting an empty applied-set delta. This is the shape the fuel loop calls; the triple is kept
only so the loop and its proofs can be moved off the applied set in a separate step.
-/
def expandOnceUnblockedWithApplied (b : Branch) (timeOrd : TimeOrdering := TimeOrdering.empty)
    (fc : FrameClass := .Base)
    (tracker : EventualityTracker := EventualityTracker.empty)
    (_applied : AppliedSet := {})
    : ExpansionResult × TimeOrdering × List SignedFormula :=
  let (result, newOrd) := expandOnceUnblocked b timeOrd fc tracker
  (result, newOrd, [])

/--
Count of unexpanded formulas in a branch (termination measure).
-/
def countUnexpanded (b : Branch) (timeOrd : TimeOrdering := TimeOrdering.empty)
    (fc : FrameClass := .Base) : Nat :=
  b.filter (fun sf => ¬isExpanded sf b timeOrd fc) |>.length

/--
Total unexpanded complexity (alternative termination measure).
-/
def totalUnexpandedComplexity (b : Branch) (timeOrd : TimeOrdering := TimeOrdering.empty)
    (fc : FrameClass := .Base) : Nat :=
  b.filter (fun sf => ¬isExpanded sf b timeOrd fc)
  |>.foldl (fun acc sf => acc + sf.complexity) 0

/-!
## What Saturation Says About Every Rule

`findUnexpanded b ord fc = none` is the engine's own certificate that a branch is finished. The
lemma below is what that certificate *means*, stated once for every rule rather than re-derived
per formula: for each rule applicable to each formula on the branch, the guard in
`findApplicableRule` that suppressed it must have held, and each guard is a statement about the
branch's contents.

This is deliberately a **mechanical unfolding lemma**, not an induction over
`expandBranchWithFuel`. That is the payoff of moving the suppression condition out of the applied
set and into `findApplicableRule`: the certificate can be read off `List.find?_eq_none` and
`List.findSome?_eq_none_iff` with no invariant to carry through the fuel loop.

The `sat_*` family in `CountermodelExtraction.lean` are its load-bearing instances; each of them
predates it and each now follows the same three steps this proof performs once.
-/

/-- `findUnexpanded … = none` says exactly that every formula on the branch is expanded. -/
theorem isExpanded_of_findUnexpanded_none {b : Branch} {ord : TimeOrdering} {fc : FrameClass}
    (h : findUnexpanded b ord fc = none) {sf : SignedFormula} (hsf : sf ∈ b) :
    findApplicableRule sf b ord fc = none := by
  have hfind := List.find?_eq_none.mp h sf hsf
  simp only [isExpanded, Option.isNone_iff_eq_none, Bool.not_eq_true, decide_eq_true_eq,
    Bool.not_eq_eq_eq_not, Bool.not_false, Bool.decide_eq_false, Bool.not_eq_false] at hfind
  simpa [isExpanded, Option.isNone_iff_eq_none] using hfind

/--
**Downward closure of saturation.** On a saturated branch, every rule applicable to every formula
present had its `findApplicableRule` guard hold, and this spells out what each guard gives:

* a `.linear` result is either wholly on the branch (ordinary rules) or its witness already exists
  (fresh-label rules);
* a `.persistent` result cannot occur at all — that arm of `findApplicableRule` carries no guard
  and returns `some` unconditionally, so a saturated branch simply has no applicable persistent
  rule (each such arm of `applyRule` filters its own output and reports `.notApplicable` instead);
* a `.branching` result has one arm wholly on the branch, or is a fresh-label rule whose witness
  already exists.
-/
theorem saturated_downward_closed
    {b : Branch} {ord : TimeOrdering} {fc : FrameClass}
    (h : findUnexpanded b ord fc = none)
    {sf : SignedFormula} (hsf : sf ∈ b)
    {rule : TableauRule} (happ : isApplicable rule sf fc = true)
    (hmem : rule ∈ allRulesForFC fc) :
    (∀ fs, (applyRule rule sf b ord).1 = .linear fs →
       (ruleMintsFreshLabel rule = false → ∀ g ∈ fs, b.contains g = true)
       ∧ (ruleMintsFreshLabel rule = true → witnessPresent rule sf b ord = true))
  ∧ (∀ fs, (applyRule rule sf b ord).1 = .persistent fs → ∀ g ∈ fs, b.contains g = true)
  ∧ (∀ bss, (applyRule rule sf b ord).1 = .branching bss →
       (∃ fs ∈ bss, ∀ g ∈ fs, b.contains g = true)
       ∨ (ruleMintsFreshLabel rule = true ∧ witnessPresent rule sf b ord = true)) := by
  have hExp := isExpanded_of_findUnexpanded_none h hsf
  unfold findApplicableRule at hExp
  rw [List.findSome?_eq_none_iff] at hExp
  have hr := hExp rule hmem
  rw [if_pos happ] at hr
  -- Destructure the rule application once, so the three clauses can rewrite the `match`.
  cases hres : applyRule rule sf b ord with
  | mk res o =>
  rw [hres] at hr
  dsimp only at hr
  refine ⟨?_, ?_, ?_⟩
  · intro fs hfs
    dsimp only at hfs
    subst hfs
    dsimp only at hr
    by_cases hfresh : ruleMintsFreshLabel rule
    · refine ⟨fun hc => absurd hc (by simp [hfresh]), fun _ => ?_⟩
      by_contra hw
      simp only [hfresh, if_true, Bool.not_eq_true] at hr
      rw [if_neg (by simpa using hw)] at hr
      exact absurd hr (by simp)
    · refine ⟨fun _ g hg => ?_, fun hc => absurd hc (by simp [hfresh])⟩
      simp only [hfresh, Bool.false_eq_true, if_false] at hr
      by_cases hall : fs.all b.contains
      · exact List.all_eq_true.mp hall g hg
      · rw [if_neg hall] at hr; exact absurd hr (by simp)
  · intro fs hfs
    -- The `.persistent` arm of `findApplicableRule` is unguarded, so this case is unreachable.
    dsimp only at hfs
    subst hfs
    exact absurd hr (by simp)
  · intro bss hbss
    dsimp only at hbss
    subst hbss
    dsimp only at hr
    by_cases hself : ruleSelfGuarded rule
    · simp only [hself, if_true] at hr; exact absurd hr (by simp)
    · simp only [hself, Bool.false_eq_true, if_false] at hr
      by_cases hfresh : ruleMintsFreshLabel rule
      · refine Or.inr ⟨hfresh, ?_⟩
        by_contra hw
        simp only [hfresh, if_true] at hr
        rw [if_neg (by simpa using hw)] at hr
        exact absurd hr (by simp)
      · refine Or.inl ?_
        simp only [hfresh, Bool.false_eq_true, if_false] at hr
        by_cases hany : bss.any (fun fs => fs.all b.contains)
        · obtain ⟨fs, hfs, hall⟩ := List.any_eq_true.mp hany
          exact ⟨fs, hfs, fun g hg => List.all_eq_true.mp hall g hg⟩
        · rw [if_neg hany] at hr; exact absurd hr (by simp)

end FormalSystem.Metalogic.Decidability
