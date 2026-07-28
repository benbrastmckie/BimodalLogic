/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.Tableau
import FormalSystem.ProofSystem.Axioms

/-!
# RuleSpec — tying the tableau rule lattice to the axiom lattice

The tableau engine maintains its frame-class-specific rule lists (`denseRules`,
`discreteRules`, `dedekindRules`, and the two rules scheduled outside those lists) **by hand**,
and nothing in the engine connects them to `Axiom.minFrameClass`. That disconnect is the single
largest maintainability hazard in the decidability stack: a rule can be gated at a frame class
that cannot derive the axiom justifying it, and nothing notices. Adding an axiom does not prompt
a rule; mis-gating a rule is silent.

This module closes that gap. It declares, for every `TableauRule` constructor, the frame class
the rule needs (`ruleFrameClass`) and the axioms whose content it internalizes (`ruleAxioms`),
then proves three GATE theorems `by decide` over the finite product of 36 rules x 4 frame
classes. The gates are cheap to prove and — the point of the exercise — cheap to *keep* true:
mis-gating a rule, or adding a frame-class-specific rule with no correspondingly-gated axiom,
breaks the build immediately rather than drifting.

## Main definitions

- `ruleFrameClass : TableauRule → FrameClass` — the minimum frame class at which a rule is sound.
- `ruleAxioms : TableauRule → List AxiomInstance` — the axioms grounding the rule.
- `allTableauRules : List TableauRule` — the full constructor enumeration (36 entries).

## Main theorems (the gates)

- `ruleAxioms_minFrameClass_le` (GATE 1): a rule is never available at a frame class that cannot
  admit its own justifying axioms.
- `mem_allRulesForFC_iff` (GATE 2): the engine's hand-maintained `allRulesForFC` agrees with
  `ruleFrameClass`, modulo the two deliberately-excluded scheduled rules.
- `ruleAxioms_covers_ruleFrameClass` (GATE 3): the converse direction — a rule gated *above*
  `.Base` must name at least one axiom at exactly its own frame class, so a frame-class-specific
  rule cannot be introduced without an accompanying frame-class-specific axiom.

## What `ruleAxioms` does and does not claim

`ruleAxioms r` is the *grounding set* for `r`: the axioms whose content the rule internalizes,
and from which the eventual per-rule admissibility lemma will be built. It is a declaration
checked here for frame-class consistency. It is **not** itself a proof that `r` is admissible,
and it is not claimed to be a minimal or unique such set.

Two consequences of that reading are deliberate:

* The eight `G`/`H`/`F`/`P` quantifier-decomposition rules carry the empty list. Their soundness
  is the semantic truth condition for the temporal quantifier, which is a *rule* of the system
  rather than an axiom of it; there is no axiom whose image they are. The empty list records
  "no frame-class-sensitive justification", which is exactly right at `.Base` and, by GATE 3,
  can never be right anywhere else.
* `untlNeg` / `snceNeg` likewise carry the empty list: the Reynolds co-decomposition they
  perform is not the image of any single BX axiom.

## The two rules scheduled outside `allRulesForFC`

`serialityRule` and `timeLinearity` are both `.Base` rules in the soundness sense — `serial_future`
/ `serial_past` and `temp_linearity` are base axioms — but both are deliberately **absent** from
`allRulesForFC`, because each is keyed on something other than a formula's shape (`serialityRule`
on the label, `timeLinearity` on the branch's time structure), so no position in a per-formula
priority list is correct for them. They are scheduled instead as the second and third stages of
`expandOnce` (see `serialityRules` / `linearityRules` in `Tableau.lean`).

GATE 2 therefore needs an explicit exclusion clause for both. Without it the `by decide` gate
fails, and it fails confusingly: the two rules are `.Base`-gated and so satisfy
`ruleFrameClass r ≤ fc` for every `fc`, while never appearing in the list.

## References

* Report 02 §8.1-8.3 (the gate proposal, and the diagnosis it responds to).
* Report 04 §Q2.4 and report 05 (the constructor count and the two scheduled rules).
-/

namespace FormalSystem.Metalogic.Decidability.Verified

open FormalSystem.Syntax
open FormalSystem.ProofSystem

/-!
## Axiom instances

`Axiom` is indexed by the formula it proves, so a heterogeneous list of axioms is a list of
dependent pairs. `Axiom.minFrameClass` never inspects the index, so the placeholder atoms below
are immaterial to every gate proved in this file; they exist only so that the entries are closed
terms.
-/

/-!
## Decidable membership in the engine's rule lists

`TableauRule` derives `DecidableEq` and `BEq` independently, and the core `Decidable (a ∈ l)`
instance for lists goes through `LawfulBEq`, which the derivation does not supply. Every gate
below is a membership check, so without this the gates are not decidable and none of them can be
discharged `by decide`.

The instance is a lawfulness fact about a derived `BEq`, so it is `Prop`-valued and cannot change
what the engine computes. It belongs next to the `deriving` clause in `Tableau.lean`; it lives
here because Phase 3 does not own the engine files.
-/

instance : LawfulBEq TableauRule where
  eq_of_beq {a b} h := by cases a <;> cases b <;> first | rfl | exact Bool.noConfusion h
  rfl {a} := by cases a <;> rfl

/-- A frame-class-tagged axiom instance: an axiom together with the formula it proves. -/
abbrev AxiomInstance := (φ : Formula) × Axiom φ

/-- Placeholder atom `p` for axiom instances. Immaterial: `Axiom.minFrameClass` is
index-independent. -/
private def pA : Formula := .atom (Atom.mkBase "p")

/-- Placeholder atom `q`. -/
private def qA : Formula := .atom (Atom.mkBase "q")

/-- Placeholder atom `r`. -/
private def rA : Formula := .atom (Atom.mkBase "r")

/-- The classical propositional base, grounding the eight truth-functional decomposition rules. -/
private def propositionalBase : List AxiomInstance :=
  [⟨_, .prop_k pA qA rA⟩, ⟨_, .prop_s pA qA⟩, ⟨_, .ex_falso pA⟩, ⟨_, .peirce pA qA⟩]

/-- The S5 modal layer, grounding the four `□`/`◇` rules. The universal propagation those rules
perform across all known worlds is exactly the content of reflexivity, transitivity, symmetry
and the S5 collapse together with `K`. -/
private def s5Base : List AxiomInstance :=
  [⟨_, .modal_t pA⟩, ⟨_, .modal_4 pA⟩, ⟨_, .modal_b pA⟩, ⟨_, .modal_5_collapse pA⟩,
   ⟨_, .modal_k_dist pA qA⟩]

/-!
## The rule specification

Both functions below are written as **exhaustive** matches with no wildcard arm. This is
deliberate and is half of the self-enforcement: a new `TableauRule` constructor fails to compile
until someone declares its frame class and its grounding axioms. (The other half is the gates.)
-/

/--
The minimum frame class at which a tableau rule is sound — the rule-side mirror of
`Axiom.minFrameClass`.

Both `serialityRule` and `timeLinearity` are `.Base`: they are scheduled outside `allRulesForFC`
for reasons of *applicability keying*, not of soundness, and their axioms (`serial_future` /
`serial_past`, `temp_linearity`) are base axioms.
-/
def ruleFrameClass : TableauRule → FrameClass
  -- Propositional decomposition (8)
  | .andPos => .Base
  | .andNeg => .Base
  | .orPos => .Base
  | .orNeg => .Base
  | .impPos => .Base
  | .impNeg => .Base
  | .negPos => .Base
  | .negNeg => .Base
  -- S5 modal (4)
  | .boxPos => .Base
  | .boxNeg => .Base
  | .diamondPos => .Base
  | .diamondNeg => .Base
  -- Modal-temporal interaction (1)
  | .boxTemporal => .Base
  -- Temporal quantifier decomposition (8)
  | .allFuturePos => .Base
  | .allFutureNeg => .Base
  | .allPastPos => .Base
  | .allPastNeg => .Base
  | .someFuturePos => .Base
  | .someFutureNeg => .Base
  | .somePastPos => .Base
  | .somePastNeg => .Base
  -- Until / Since (4)
  | .untlPos => .Base
  | .untlNeg => .Base
  | .sncePos => .Base
  | .snceNeg => .Base
  -- Order trichotomy (1) — BX11 is a base axiom
  | .orderTrichotomy => .Base
  -- Dense (2)
  | .denseIndicatorClosure => .Dense
  | .densityRule => .Dense
  -- Discrete (3)
  | .priorUZ => .Discrete
  | .priorSZ => .Discrete
  | .z1Rule => .Discrete
  -- Dedekind (3)
  | .priorUGap => .Dedekind
  | .priorSGap => .Dedekind
  | .sepRule => .Dedekind
  -- Scheduled outside `allRulesForFC` (2) — base rules nonetheless
  | .serialityRule => .Base
  | .timeLinearity => .Base

/--
The axioms grounding each tableau rule. See the module docstring for the precise reading of this
function, and in particular for why several base rules carry the empty list.
-/
def ruleAxioms : TableauRule → List AxiomInstance
  -- Propositional decomposition (8): truth-functional, grounded in the classical base.
  | .andPos => propositionalBase
  | .andNeg => propositionalBase
  | .orPos => propositionalBase
  | .orNeg => propositionalBase
  | .impPos => propositionalBase
  | .impNeg => propositionalBase
  | .negPos => propositionalBase
  | .negNeg => propositionalBase
  -- S5 modal (4): universal propagation / fresh witness worlds.
  | .boxPos => s5Base
  | .boxNeg => s5Base
  | .diamondPos => s5Base
  | .diamondNeg => s5Base
  -- Modal-temporal interaction (1): `T(□A) → T(GA), T(HA)`, i.e. MF plus reflexivity.
  | .boxTemporal => [⟨_, .modal_future pA⟩, ⟨_, .modal_t pA⟩]
  -- Temporal quantifier decomposition (8): semantic truth conditions, no axiom image.
  | .allFuturePos => []
  | .allFutureNeg => []
  | .allPastPos => []
  | .allPastNeg => []
  | .someFuturePos => []
  | .someFutureNeg => []
  | .somePastPos => []
  | .somePastNeg => []
  -- Until / Since (4). The positive rules branch into an event witness (BX10/BX10') and a
  -- guard-and-continue arm that re-emits the eventuality (BX5/BX5', self-accumulation).
  -- The negative rules perform a Reynolds co-decomposition that is no single axiom's image.
  | .untlPos => [⟨_, .until_F pA qA⟩, ⟨_, .self_accum_until pA qA⟩]
  | .untlNeg => []
  | .sncePos => [⟨_, .since_P pA qA⟩, ⟨_, .self_accum_since pA qA⟩]
  | .snceNeg => []
  -- Order trichotomy (1): the three branches ARE the three `temp_linearity` disjuncts. That
  -- identity is settled design, and it is what makes the eventual admissibility lemma a
  -- one-liner.
  | .orderTrichotomy => [⟨_, .temp_linearity pA qA⟩]
  -- Dense (2)
  | .denseIndicatorClosure => [⟨_, .dense_indicator⟩]
  | .densityRule => [⟨_, .density pA⟩]
  -- Discrete (3)
  | .priorUZ => [⟨_, .prior_UZ pA⟩]
  | .priorSZ => [⟨_, .prior_SZ pA⟩]
  | .z1Rule => [⟨_, .z1 pA⟩]
  -- Dedekind (3). NOT `prior_UZ`/`prior_SZ`: those are the integer well-ordering axioms at
  -- `.Discrete`, and the similarity of the names is a known trap.
  | .priorUGap => [⟨_, .prior_U_gap pA⟩]
  | .priorSGap => [⟨_, .prior_S_gap pA⟩]
  | .sepRule => [⟨_, .sep pA⟩]
  -- Scheduled outside `allRulesForFC` (2)
  | .serialityRule => [⟨_, .serial_future⟩, ⟨_, .serial_past⟩]
  | .timeLinearity => [⟨_, .temp_linearity pA qA⟩]

/-!
## The constructor enumeration

`TableauRule` has no `Fintype` instance in the engine, and Phase 3 does not own the engine files,
so the enumeration is given here and pinned to the constructor set by `mem_allTableauRules`.
Adding a constructor breaks that lemma, which is the intended alarm.
-/

/-- Every `TableauRule` constructor, in declaration order. -/
def allTableauRules : List TableauRule :=
  [.andPos, .andNeg, .orPos, .orNeg, .impPos, .impNeg, .negPos, .negNeg,
   .boxPos, .boxNeg, .diamondPos, .diamondNeg, .boxTemporal,
   .allFuturePos, .allFutureNeg, .allPastPos, .allPastNeg,
   .someFuturePos, .someFutureNeg, .somePastPos, .somePastNeg,
   .untlPos, .untlNeg, .sncePos, .snceNeg,
   .orderTrichotomy,
   .denseIndicatorClosure, .densityRule,
   .priorUZ, .priorSZ, .z1Rule,
   .priorUGap, .priorSGap, .sepRule,
   .serialityRule, .timeLinearity]

/-- `allTableauRules` really is exhaustive. Breaks the moment a constructor is added. -/
theorem mem_allTableauRules (r : TableauRule) : r ∈ allTableauRules := by
  cases r <;> decide

/-- The constructor count, pinned. 36 = 26 base (25 shape-keyed plus `orderTrichotomy`)
+ 2 dense + 3 discrete + 3 dedekind + 2 scheduled-outside. -/
theorem allTableauRules_length : allTableauRules.length = 36 := by decide

/-!
## The gates

All three are closed finite checks. `cases` reduces the statement to one closed proposition per
constructor (per constructor pair, for GATE 2) and `decide` evaluates it.
-/

/--
**GATE 1.** A rule is never available at a frame class that cannot admit the axioms justifying
it: every axiom grounding `r` has `minFrameClass ≤ ruleFrameClass r`.

Read contrapositively, this is the check that matters: grounding a rule in a `.Dedekind` axiom
while gating the rule at `.Base` is a build failure.
-/
theorem ruleAxioms_minFrameClass_le (r : TableauRule) :
    ∀ a ∈ ruleAxioms r, a.2.minFrameClass ≤ ruleFrameClass r := by
  cases r <;> decide

/--
**GATE 2.** The engine's hand-maintained `allRulesForFC` agrees with `ruleFrameClass`.

The two conjuncts on the left of the frame-class comparison are the **exclusion clause** for the
rules that are scheduled rather than prioritised. Both are `.Base` rules, so both satisfy
`ruleFrameClass r ≤ fc` at every `fc`; without naming them the equivalence is simply false, and
its `by decide` failure gives no hint as to why. See the module docstring.
-/
theorem mem_allRulesForFC_iff (r : TableauRule) (fc : FrameClass) :
    r ∈ allRulesForFC fc ↔
      r ≠ .serialityRule ∧ r ≠ .timeLinearity ∧ ruleFrameClass r ≤ fc := by
  cases r <;> cases fc <;> decide

/--
**GATE 3.** The converse of GATE 1, and the direction that stops the rule lattice from growing
past the axiom lattice: a rule gated above `.Base` must name at least one axiom at exactly its
own frame class.

This is what makes an empty `ruleAxioms` entry safe. An empty list is a licit statement of "no
frame-class-sensitive justification" at `.Base`, and by this gate it can never be anything else:
moving such a rule to `.Dense`, `.Discrete` or `.Dedekind` without supplying a correspondingly
gated axiom breaks the build.
-/
theorem ruleAxioms_covers_ruleFrameClass (r : TableauRule) :
    ruleFrameClass r = .Base ∨
      ∃ a ∈ ruleAxioms r, a.2.minFrameClass = ruleFrameClass r := by
  cases r <;> decide

/-!
## Corollaries of the gates
-/

/-- `serialityRule` is outside `allRulesForFC` at every frame class. Corollary of GATE 2, but
stated separately because it is the fact downstream saturation code depends on: `findUnexpanded`
scans `allRulesForFC`, so a branch can be "saturated" while still owed `T(F ⊤)` / `T(P ⊤)`. -/
theorem serialityRule_not_mem_allRulesForFC (fc : FrameClass) :
    TableauRule.serialityRule ∉ allRulesForFC fc := by
  cases fc <;> decide

/-- `timeLinearity` is outside `allRulesForFC` at every frame class. -/
theorem timeLinearity_not_mem_allRulesForFC (fc : FrameClass) :
    TableauRule.timeLinearity ∉ allRulesForFC fc := by
  cases fc <;> decide

/-- A rule available at some frame class is available at every larger one. The monotonicity that
lets a single frame-class-generic induction over `allRulesForFC fc` specialise to all four
classes without re-proof. -/
theorem mem_allRulesForFC_mono {r : TableauRule} {fc fc' : FrameClass}
    (hle : fc ≤ fc') (hmem : r ∈ allRulesForFC fc) : r ∈ allRulesForFC fc' := by
  rw [mem_allRulesForFC_iff] at hmem ⊢
  exact ⟨hmem.1, hmem.2.1, le_trans hmem.2.2 hle⟩

/-!
## Shape regression checks

These pin the sizes of the four rule lists. They are not used downstream; they exist so that a
future edit to `allRules`, `denseRules`, `discreteRules` or `dedekindRules` that changes what the
engine actually runs cannot pass unnoticed just because the gates above happen to survive it.
-/

example : (allRulesForFC .Base).length = 26 := by decide
example : (allRulesForFC .Dense).length = 28 := by decide
example : (allRulesForFC .Discrete).length = 29 := by decide
example : (allRulesForFC .Dedekind).length = 31 := by decide

/-- `Discrete` and `Dedekind` are incomparable, so the Dedekind arm never picks up the Discrete
rules and vice versa. Pinned here because it is the fact that makes the gating correct rather
than a defect (report 02, contradiction C3). -/
example : TableauRule.priorUZ ∉ allRulesForFC .Dedekind := by decide

example : TableauRule.priorUGap ∉ allRulesForFC .Discrete := by decide

end FormalSystem.Metalogic.Decidability.Verified
