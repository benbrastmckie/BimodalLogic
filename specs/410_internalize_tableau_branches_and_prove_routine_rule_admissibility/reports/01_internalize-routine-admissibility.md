# Research Report: Branch Internalization and Routine Rule Admissibility

- **Task**: 410 — Track B part 1 of the TM tableau decidability program
- **Type**: lean4 (hard mode: H2 anti-analysis, H3 reference grounding, H4 adversarial verification)
- **Date**: 2026-07-29
- **Reference grounding tier**: **Tier 3 (implementation-backed)** with a Tier 1 overlay. The
  primary source is this repository's own `FormalSystem/` tree (extend/port); the Burgess/Reynolds
  literature enters only through the axiom set, which is already transcribed into
  `ProofSystem/Axioms.lean`. No paper is being newly transcribed by this task, so the 5-column
  mapping table in §7 maps *rules → axioms/derived theorems in source*, not rules → paper
  propositions.
- **Verification substrate**: every declaration cited below was located in source by name and line;
  the five most load-bearing signatures were additionally confirmed through `lean_hover_info`
  (marked **[hover]** in §7/§10).

---

## Executive Summary

1. **The rule inventory is 34, not 30.** `allRulesForFC` contains 26 base + 2 dense + 3 discrete +
   3 dedekind = **34 distinct rules** across the four frame classes; `TableauRule` has **36**
   constructors, the extra two being `serialityRule`/`timeLinearity`, which are deliberately
   outside `allRulesForFC`. Report 02 §1.2's inventory (25 base, 30 total) predates
   `orderTrichotomy` and the three Dedekind rules. §1 gives the source-verified enumeration.

2. **410's territory is exactly 21 lemmas**, matching the plan's division table
   (`plans/01_tableau-decidability-two-track.md:3914`): 8 propositional + 4 S5 modal + 1
   `boxTemporal` + 8 temporal universal/existential. The other 13 are 411's. §2 draws the boundary
   rule-by-rule so nothing is double-claimed or dropped.

3. **The single most important source fact for the statement shape**: `expandOnce` **never removes
   the source formula**. `.linear`, `.branching` and `.persistent` all extend by `formulas ++ b`
   (`Tableau.lean:2189-2197`). "Consumable" is implemented by the `isExpanded`/`AppliedSet`
   guard, not by branch subtraction. So **every child branch in 410's scope is a superset of its
   parent**, and `rule_admissible` reduces to a *positive-position strengthening* obligation:
   `⊢ b.internalize → conjOf(emitted contents at their labels)`. This is materially simpler than
   report 02 §3.1's shape suggests, and §4 states the corrected shape (five corrections).

4. **`Branch.internalize` must be time-major, with a flat `◇` per (world, time) cell, and the
   `U`/`S` guard slot present from day one.** §3 gives the concrete definition. Time-major is
   *forced*: world-major makes `boxPos` unprovable, because extracting `□ψ` from under an `F` needs
   `F(□ψ) → □ψ`, which is false. Writing the tree edges as `untl _ ⊤` / `snce _ ⊤` (which is
   *definitionally* `someFuture`/`somePast`, `Formula.lean:131,141`) means the guard slot exists
   syntactically for 411/430 to strengthen without retyping the definition or reproving 410's 21
   lemmas.

5. **The one genuinely hard step inside 410's 21** is the cross-world `gProps`/`fNegProps`
   propagation in the four fresh-time existential rules: it needs a Barcan-type commutation
   `◇(Gχ) → G(◇χ)`. This is **not** among TM's axioms — but it is derivable from *already-proven*
   declarations: `perpetuity6 : ⊢ ▽(□φ) → □(△φ)` (`Perpetuity/MonotonicityDuality.lean:560`,
   **[hover]**-confirmed) with `persistence : ⊢ ◇φ → △(◇φ)` (`Perpetuity/Principles.lean:698`),
   `alwaysToFuture` (:235 of MonotonicityDuality), `boxMono`/`diamondMono`, and `serial_future`.
   §5.4 gives the chain. Without this the four existential rules would have to be promoted to 411;
   with it they stay, as their own phase.

6. **410 must build a positive-context monotonicity engine before any of the 21 lemmas.** Every
   emitted formula sits under `∧`/`◇`/`untl(·,⊤)`/`snce(·,⊤)` nesting — all monotone positions —
   and no rule's obligation should re-derive that descent. Report 02's asset list omits this
   entirely. §5.1 specifies it; it is the highest-leverage item in the task.

7. **One promotion out of 410, and it is not a rule.** `internalize`'s handling of *non-tree*
   `TimeOrdering` graphs should be an explicit hypothesis, not a lossy approximation and not a
   `sorry`. Within 410's 21 rules the ordering stays a forest rooted at time 0 (each
   ordering-mutating rule adds exactly one edge to a *fresh* time), so 410 can prove and discharge
   the invariant itself. Only `densityRule` (411) and `timeLinearity` (430) break it. §3.5, §8.

---

## 1. The Current, Verified Rule Inventory

### 1.1 Enumeration from source

`TableauRule` is declared at `FormalSystem/Metalogic/Decidability/Tableau.lean:73-192`, 36
constructors, pinned by `allTableauRules_length : allTableauRules.length = 36`
(`Verified/RuleSpec.lean:282`).

The engine's frame-class rule lists:

| List | Source | Members | Count |
|---|---|---|---|
| `allRules` | `Tableau.lean:1569-1588` | `negPos negNeg impNeg andPos orNeg boxPos boxNeg diamondPos diamondNeg boxTemporal allFuturePos allFutureNeg allPastPos allPastNeg someFuturePos someFutureNeg somePastPos somePastNeg untlPos untlNeg sncePos snceNeg impPos andNeg orPos orderTrichotomy` | 26 |
| `denseRules` | `Tableau.lean:1593-1596` | `denseIndicatorClosure densityRule` | 2 |
| `discreteRules` | `Tableau.lean:1601-1604` | `priorUZ priorSZ z1Rule` | 3 |
| `dedekindRules` | `Tableau.lean:1615-1617` | `priorUGap priorSGap sepRule` | 3 |
| **union** | `allRulesForFC`, `Tableau.lean:1624-1636` | — | **34** |
| outside | `serialityRules` :1664, `linearityRules` :1736 | `serialityRule timeLinearity` | 2 |

`allRulesForFC fc = dedekind ++ base ++ dense ++ discrete` — note the Dedekind rules are
*prepended*, for the scheduling reason given at `Tableau.lean:1629-1635`. Per-class lengths are
pinned by `example`s at `RuleSpec.lean:362-365`:

| Frame class | Composition | Length |
|---|---|---|
| `Base` | base | 26 |
| `Dense` | base + dense | 28 |
| `Discrete` | base + discrete (`Dense ≰ Discrete`) | 29 |
| `Dedekind` | dedekind + base + dense (`Discrete ≰ Dedekind`) | 31 |

The two exclusions are theorems, not conventions: `serialityRule_not_mem_allRulesForFC`
(`RuleSpec.lean:337`) and `timeLinearity_not_mem_allRulesForFC` (:342), both corollaries of GATE 2
`mem_allRulesForFC_iff` (:310).

### 1.2 Routine (410) vs hard (411) vs out-of-scope, all 36

| # | Rule | `ruleFrameClass` | Owner | Result form | Rationale |
|---|---|---|---|---|---|
| 1 | `andPos` | Base | **410** | `.linear` | same cell, truth-functional |
| 2 | `andNeg` | Base | **410** | `.branching` | same cell, truth-functional |
| 3 | `orPos` | Base | **410** | `.branching` | same cell |
| 4 | `orNeg` | Base | **410** | `.linear` | same cell |
| 5 | `impPos` | Base | **410** | `.branching` | same cell |
| 6 | `impNeg` | Base | **410** | `.linear` | same cell |
| 7 | `negPos` | Base | **410** | `.linear` | same cell |
| 8 | `negNeg` | Base | **410** | `.linear` | same cell |
| 9 | `boxPos` | Base | **410** | `.persistent` | cross-world, **fixed time** → single time node |
| 10 | `boxNeg` | Base | **410** | `.linear` | fresh world; all emissions at their source's own time |
| 11 | `diamondPos` | Base | **410** | `.linear` | dual of `boxNeg` |
| 12 | `diamondNeg` | Base | **410** | `.persistent` | dual of `boxPos` |
| 13 | `boxTemporal` | Base | **410** | `.persistent` | same cell; `boxToFuture`/`boxToPast` one-liners |
| 14 | `allFuturePos` | Base | **410** | `.persistent` | same world, along transitive `futureOf` chain |
| 15 | `allFutureNeg` | Base | **410** | `.linear` | fresh time + cross-world props (§5.4) |
| 16 | `allPastPos` | Base | **410** | `.persistent` | past mirror of 14 |
| 17 | `allPastNeg` | Base | **410** | `.linear` | past mirror of 15 |
| 18 | `someFuturePos` | Base | **410** | `.linear` | fresh time + cross-world props (§5.4) |
| 19 | `someFutureNeg` | Base | **410** | `.persistent` | same world, transitive `futureOf` |
| 20 | `somePastPos` | Base | **410** | `.linear` | past mirror of 18 |
| 21 | `somePastNeg` | Base | **410** | `.persistent` | past mirror of 19 |
| 22 | `untlPos` | Base | 411 | `.branching` | `self_accum_until`; report 02 §3.3 |
| 23 | `untlNeg` | Base | 411 | `.branching` (ACTIVE arm only) | see §1.4 |
| 24 | `sncePos` | Base | 411 | `.branching` | past mirror of 22 |
| 25 | `snceNeg` | Base | 411 | `.branching` (ACTIVE arm only) | see §1.4 |
| 26 | `orderTrichotomy` | Base | 411 | `.branching` (`Tableau.lean:1326`) | 3-way `temp_linearity` split |
| 27 | `denseIndicatorClosure` | Dense | 411 | `.linear []` | `dense_indicator` |
| 28 | `densityRule` | Dense | 411 | `.linear` | **breaks the tree invariant** (§3.5) |
| 29 | `priorUZ` | Discrete | 411 | `.persistent` | *rated routine by report 02*; see §2.2 |
| 30 | `priorSZ` | Discrete | 411 | `.persistent` | idem |
| 31 | `z1Rule` | Discrete | 411 | `.persistent` | two-premise, same label (§3.6) |
| 32 | `priorUGap` | Dedekind | 411 | `.persistent` | `prior_U_gap` |
| 33 | `priorSGap` | Dedekind | 411 | `.persistent` | `prior_S_gap` |
| 34 | `sepRule` | Dedekind | 411 | `.persistent` | `sep` |
| 35 | `serialityRule` | Base | **430** | `.persistent` | outside `allRulesForFC` (`RuleSpec.lean:337`) |
| 36 | `timeLinearity` | Base | **430** | `.branchingOrdered` | outside `allRulesForFC` (:342) |

**410's count: 21.** Sum check: 21 + 13 + 2 = 36. ✓

### 1.3 Deltas against report 02's inventory

Report 02 was written before the Phase 2 rule-set changes. Concretely:

| Report 02 claim (§1.2, §3.2) | Current source | Verdict |
|---|---|---|
| `allRules` = **25** rules at `Tableau.lean:1029-1044` | **26** at `Tableau.lean:1569-1588` | stale count and stale anchor; `orderTrichotomy` added |
| Base 25 / Dense 27 / Discrete 28 / Dedekind 27 | 26 / 28 / 29 / **31** | stale; `dedekindRules` now exists and is in the `Dedekind` arm |
| "30 admissibility lemmas" (§3.1) | **34** | stale |
| "Dedekind (missing) | R6 rules" (§3.2 last row) | `priorUGap priorSGap sepRule` **exist** (`Tableau.lean:1615`) | resolved since |
| `serialityRule`, `timeLinearity` | exist, constructors 35–36 | **omitted entirely** by report 02 |
| `untlNeg` at `Tableau.lean:765-914`, strategy = `absorb_until` + `left_mono_until_G` for the "Reynolds co-decomposition" | arm is now `Tableau.lean:1013-1137`; the **PASSIVE arm is deleted** | anchor stale; §3.3's strategy targets a deleted arm |
| `generalizedTemporalK`/`generalizedPastK` at `:183,223` in `TemporalDerived.lean` context | `GeneralizedNecessitation.lean:183,223` | **file misattributed**; lines correct |
| `FrameClass.base_le` at `Axioms.lean:530` | `Axioms.lean:568` | line drift |
| `prior_U_gap` :377, `prior_S_gap` :387, `sep` :398 | :399, :409, :420 | line drift |
| `boxConjIff` :465, `s5DiamondBox` :717, `impTrans` :99, `pairing` :555, `notNotIntro` :589, `temporalFutureDerived` :653, `gDistribution` :260, `hDistribution` :268, `gTransitivity` :275, `hTransitivity` :283, `fNegG` :504, `pNegH` :514, `generalizedModalK` :148, `deductionTheorem` :325, `until_F` :226, `self_accum_until` :174, `absorb_until` :186, `left_mono_until_G` :123, `right_mono_until` :134, `enrichment_until` :156, `F_until_equiv` :255, `temp_linearity` :238, `linear_until` :196, `linear_since` :205, `z1` :332, `prior_UZ` :315, `prior_SZ` :320, `density` :343, `dense_indicator` :354, `modal_future` :268 | all confirmed at exactly these lines | **accurate** |

**No rule that report 02 lists has ceased to exist.** Everything in its inventory is still a
constructor; the changes are additions plus the two arm retirements in §1.4.

### 1.4 The retired PASSIVE arms — what survives, verified in source

`untlNeg` (`Tableau.lean:1013-1137`). The passive co-decomposition at *existing* future times is
gone (:1017-1062 is the tombstone comment). The surviving **ACTIVE** arm fires only under

```
if futureTimes.isEmpty && timeOrd.timeCount > 0 && timeOrd.timeCount < 4 then     -- :1063
```

and returns (`:1131-1133`)

```lean
let branch1 := [SignedFormula.neg event freshLabel, sf] ++ autoProp
let branch2 := [SignedFormula.neg guard freshLabel, sf] ++ autoProp
(.branching [branch1, branch2], newOrd)
```

with `autoProp = gProps ++ fNegProps ++ modalProps` (:1106) and `newOrd = timeOrd.addFuture l.time
freshTime` (:1071). Every other configuration returns `.notApplicable` (:1136). There is **no**
self-propagated `F(U(event,guard))@freshLabel` in branch 2 (:1109-1130) and **no** `untlNegProps`
copy block (:1092-1103). `snceNeg` (`Tableau.lean:1144-1211`) is the exact past mirror: guard at
:1163, `.branching` at :1207, `newOrd = timeOrd.addPast l.time freshTime` at :1170.

Confirmed absent from the tree: `sat_untl_neg` and `sat_snce_neg` (`grep` over `--include=*.lean`
returns nothing). Any 411 admissibility lemma for these two rules must target the ACTIVE arm above
and *only* it — and, because both arms live in one `applyRule` match, the `.notApplicable` case
discharges vacuously.

---

## 2. The 410 / 411 / 430 / 412 Boundary

### 2.1 Territory, by file

The authoritative split is the plan's division table
(`plans/01_tableau-decidability-two-track.md:3914-3916`):

| Owner | Files | Content |
|---|---|---|
| **410 (this task)** | `Verified/Internalize.lean`; `Verified/Refutation/Rules/{Propositional,Modal,Temporal}.lean` | `Branch.internalize` + the 21 routine lemmas + the shared infrastructure of §5 |
| 411 | `Verified/Refutation/Rules/{UntilSince,Trichotomy,Discrete,Dense,Dedekind}.lean` | rules 22–34 (13 lemmas) |
| 430 | (engine-side) | `serialityRule`, `timeLinearity` — rules 35–36 |
| 412 | `Verified/Refutation/Core.lean`, `Verified/Provable.lean` | `allClosed_derivable`, `Decidable (Derivable fc [] φ)` |

**410's routine lemmas do not cover `serialityRule` or `timeLinearity`.** Both are deliberately
outside `allRulesForFC` (`RuleSpec.lean:337,342`); they run as stages 2 and 3 of `expandOnce`
(`Tableau.lean:2176-2183`), and `timeLinearity` is the only rule returning
`.branchingOrdered` — a *replacement*-branch constructor whose identification arm removes a time
from `Branch.knownTimes` (`Tableau.lean:210-223`), which no formula-delta can express. 410 states
the admissibility theorem over `.linear`/`.branching`/`.persistent`/`.notApplicable` only, and
leaves `.branchingOrdered` to 430.

### 2.2 One boundary conflict, resolved

Report 02 §3.2 rates `priorUZ`/`priorSZ` **"Routine (direct axiom images)"**, but the plan's
division table assigns `Rules/Discrete.lean` to 411. These disagree.

**Resolution: 411 owns them.** Reasons, in order of weight: (a) file ownership is the H7 territory
contract, and 410's declared file set is exactly `{Propositional,Modal,Temporal}.lean`; (b) both
counts that were independently stated for 410 — the task brief's "8 + 4 + 1 + 8" and report 09's
"~21 routine lemmas" (`reports/09_...md:218`) — come to 21 without them; (c) they are `.Discrete`
rules, so their lemmas carry `ruleFrameClass r ≤ fc` in a form 410 never otherwise exercises (410's
21 are all `.Base`, so `h_fc` is discharged by `FrameClass.base_le`, `Axioms.lean:568`).

They *are* easy — `prior_UZ : F φ → U(φ, ¬φ)` (`Axioms.lean:315`) is a literal transcription of the
rule — so 411 should be told they are its cheapest two, not that they are hard.

### 2.3 Refuted scope explicitly avoided

Nothing in this report is scoped against `buildTableau_isSome`. That theorem is false —
`buildTableau` returns `none` above `maxBranches := 50000` at any fuel — and task 428 owns the
budget-parameterised replacement. 410's deliverables are `Branch.internalize` plus 21 `Prop`-valued
implications between `Derivable` statements; none of them mentions `buildTableau`, fuel, or
termination.

---

## 3. `Branch.internalize`: the Design

### 3.1 What the object language gives us

| Fact | Anchor | Consequence for the design |
|---|---|---|
| `Formula` has 6 constructors: `atom bot imp box untl snce` | `Syntax/Formula.lean:76-91` | `G H F P ∧ ∨ ¬ ◇ ⊤` are all `def`s, so internalize can freely use them |
| `someFuture φ = untl φ top`; `somePast φ = snce φ top` | `Formula.lean:131,141` | writing tree edges as `untl _ ⊤` **is** writing `F`, definitionally — the guard slot is free |
| `allFuture φ = (someFuture φ.neg).neg`; `allPast` dual | `Formula.lean:151,161` | `G`/`H` are negative-position; expect DNE bookkeeping (§5.5) |
| `top = bot.imp bot`, `and`, `or`, `diamond` derived | `Formula.lean:118,433,438,443` | `⊤`-terminated right-nested conjunctions are cheap to manipulate with `pairing`/`combineImpConj` |
| `box φ` is `∀ σ ∈ Omega, TruthAt … σ t φ` — **same time `t`**, no accessibility relation | `Semantics/Truth.lean` (`TruthAt`, `Formula.box` clause) | worlds are a *flat* set at each instant; one `◇` layer suffices, no `◇`-nesting |
| `untl φ ψ` is `∃ s > t, φ@s ∧ ∀ r ∈ (t,s), ψ@r` — strict witness, **open** guard | same | the guard constrains the *open* interval; that is what makes `enrichment_until` (`Axioms.lean:156`) the mechanism for reaching *back* to the current instant |
| `Label = { world : WorldIndex, time : TimeIndex }`, both `Nat`; `Branch = List SignedFormula` | `SignedFormula.lean:59, 240, 49, 52` | the internalization is a function of a finite label set |
| `TimeOrdering = { constraints : List (TimeIndex × TimeIndex) }`, strict `<` pairs, **no equality** | `SignedFormula.lean:671-674` | the ordering is a DAG; equality is expressed only by `identifyTime` (:705), i.e. by substitution |

### 3.2 The definition

```lean
namespace FormalSystem.Metalogic.Decidability.Verified
open FormalSystem.Syntax

/-- The object-language content of a signed formula: `T(φ) ↦ φ`, `F(φ) ↦ ¬φ`. -/
def SignedFormula.content (sf : SignedFormula) : Formula :=
  match sf.sign with
  | .pos => sf.formula
  | .neg => sf.formula.neg

/-- Right-nested, `⊤`-terminated conjunction. -/
def conjOf : List Formula → Formula
  | []      => Formula.top
  | φ :: fs => φ.and (conjOf fs)

/-- Everything the branch asserts at *exactly* the label `(w, t)`. -/
def Branch.cell (b : Branch) (w : WorldIndex) (t : TimeIndex) : Formula :=
  conjOf ((b.filter fun sf => sf.label == ⟨w, t⟩).map SignedFormula.content)

/-- One time slice: the root world's cell, plus one `◇` per non-root known world. -/
def Branch.slice (b : Branch) (t : TimeIndex) : Formula :=
  (b.cell 0 t).and
    (conjOf ((b.knownWorlds.filter (· != 0)).map fun w => (b.cell w t).diamond))

/-- The time skeleton. One `untl (·) guard` per unvisited direct successor, one
`snce (·) guard` per unvisited direct predecessor. `visited` makes the walk a tree
unfolding; `fuel` bounds it. -/
def Branch.timeTree (b : Branch) (ord : TimeOrdering) (guard : Formula)
    (visited : List TimeIndex) (t : TimeIndex) : Nat → Formula
  | 0 => b.slice t
  | fuel + 1 =>
    let v := t :: visited
    let futs  := (ord.directFutureOf t).filter fun t' => !v.contains t'
    let pasts := (ord.directPastOf  t).filter fun t' => !v.contains t'
    (b.slice t).and
      ((conjOf (futs.map  fun t' => Formula.untl (b.timeTree ord guard v t' fuel) guard)).and
       (conjOf (pasts.map fun t' => Formula.snce (b.timeTree ord guard v t' fuel) guard)))

/-- The internalization. Guard instantiated at `⊤`, so every edge is literally `F`/`P`
(`Formula.lean:131,141`) while the guard slot stays available to 411/430. -/
def Branch.internalize (b : Branch) (ord : TimeOrdering) : Formula :=
  b.timeTree ord Formula.top [] 0 (b.knownTimes.length + ord.timeCount + 1)
```

Existing declarations this builds on, all verified present: `Branch.knownWorlds`
(`SignedFormula.lean:306`), `Branch.knownTimes` (:349), `TimeOrdering.directFutureOf` (:718),
`directPastOf` (:724), `TimeOrdering.timeCount` (:788), `Formula.and` (`Formula.lean:433`),
`Formula.diamond` (:443), `Formula.neg` (:121), `Formula.top` (:118).

### 3.3 How world labels are realized — flat `◇`, not nesting

Report 02 §3.1 says "world labels via the S5 modality (`□`/`◇` nesting)". **Nesting is
unnecessary.** `TruthAt … (Formula.box φ)` quantifies over `σ ∈ Omega` with no accessibility
relation and at the *same* time index, so the worlds known at an instant form a flat set; `◇◇A` and
`◇A` are equivalent (the `modal_4`/`modal_t` duals). A single `◇` per non-root world at each time
node is therefore exactly as strong as any nesting, and it is what `Branch.slice` emits.

Two consequences worth being explicit about:

- **World identity across times is deliberately not preserved.** `slice t` and `slice t'` each emit
  their own `◇(cell w ·)`, and `◇A ∧ ◇B` does not say one history satisfies both. So
  `internalize` is *weaker* than the branch. That direction is safe: `rule_admissible` needs
  `⊢ b.internalize → child.internalize`, and a weaker consequent is easier, not harder. It also
  leaves the root anchor (§3.7) untouched. This is a real simplification over a
  history-identity-preserving encoding, and it is the reason `boxNeg`/`diamondPos` — which mint a
  world whose content lands at *several* times (`Tableau.lean:685-697, 712-724`, keyed on
  `bsf.label.time`, not `l.time`) — stay routine.
- **World 0 is privileged as the actual history.** The tableau starts at `⟨0,0⟩`, so the root
  world's cell is asserted flatly rather than under `◇`. Without that, `internalize` of the initial
  branch would be `◇(¬φ)` rather than `¬φ` and the anchor of §3.7 would fail.

### 3.4 How time labels realize the `TimeOrdering` — and why time-major is forced

`timeTree` walks the ordering *graph* away from time 0 along both `directFutureOf` and
`directPastOf`, emitting one `untl`/`snce` layer per edge. Transitive consequences (`futureOf` is
the transitive closure, `SignedFormula.lean:776`) are realized as *chains* of nested `F`, which is
correct: `F(A ∧ F B)` is exactly `t < t₁ < t₂`. Incomparable siblings become independent conjuncts
`F(A) ∧ F(B)`, which correctly declines to order them — and is precisely why `orderTrichotomy` and
`timeLinearity` exist as rules rather than as internalization artefacts.

**Why times outermost and worlds inside, rather than the reverse.** The alternative — one `◇` per
world containing that world's whole time tree — is fatal to `boxPos`. `boxPos`
(`Tableau.lean:671-677`) takes `T(□ψ)@(w,t)` and emits `T(ψ)@(w',t)` for every known `w'`. Under
world-major, `□ψ` would sit under `F`/`P` nesting *inside* `◇_w`, and using it would require
`F(□ψ) → □ψ`, which is **false**: `F□ψ` at `t` places the universal claim at a later instant, not
at `t`. Under time-major, source and target are both inside `slice t` — the same time node — and
the obligation is purely S5-local (§5.3). The mirror-image cost is that cross-world *temporal*
propagation now needs a Barcan step; that cost is payable (§5.4), the `boxPos` cost is not.

**Where the `U`/`S` guard becomes load-bearing.** With `guard := ⊤` the tree is pure `F`/`P`
nesting, which faithfully realizes a *forest*. The guard slot earns its keep the moment the
ordering is not a forest, because a node with two incomparable predecessors cannot be realized by
independent `F`-witnesses (they need not coincide). The mechanism for rejoining is
`enrichment_until` (`Axioms.lean:156`):

```
p ∧ U(ψ, φ)  →  U(ψ ∧ S(p, φ), φ)
```

Because the `Until` guard interval `(t,s)` and the `Since` guard interval at the witness `s` are
*the same open interval*, this records "what held at the current instant" *inside* the future
witness as `S(p, φ)` — a back-edge realized through a guard. Together with
`left_mono_until_G` (`Axioms.lean:123`) and `right_mono_until` (:134) for strengthening guard and
event from branch-wide `G`-facts, this is the machinery a non-forest realization needs. **410 does
not need it** (§3.5), and should not build it; 410 needs only to leave the slot open, which the
`guard` parameter does.

### 3.5 The tree invariant, and the one promotion out of 410

Every ordering-mutating rule in 410's 21 calls `timeOrd.addFuture l.time freshTime` or
`addPast l.time freshTime` with `freshTime = branch.nextTime`
(`Tableau.lean:761-763, 801-803, 834-836, 878-880`). `addFuture`/`addPast` prepend exactly one
constraint (`SignedFormula.lean:685,689`), and `nextTime` (:380) is strictly above every time on the
branch, so the new node has exactly one incident edge. **Therefore each of 410's 21 rules preserves
"the constraint graph is a forest rooted at 0", and `TimeOrdering.empty` starts as one.**

The two rules that break it are outside 410:

- `densityRule` (411) inserts an intermediate node between `t` and an existing `t' ∈ futureOf t`,
  producing `t < t'' < t'` alongside the pre-existing `t < t'` — a diamond.
- `timeLinearity` (430) `identifyTime`s two nodes (`SignedFormula.lean:705`), so the surviving node
  inherits both predecessors' edges.

**Recommendation (this is the promotion the brief asks for, and it is not a rule):** state
`rule_admissible` with an explicit forest hypothesis on `ord`, and have 410 prove the invariant
lemma `applyRule_preserves_forest` for its own 21 and hand the obligation to 411/430 by name. This
is a declared boundary with an owner, not a `sorry` and not a lossy approximation. A vacuous
`def IsForest := True` or an unhypothesised definition that silently mis-realizes diamonds would
both be worse than the hypothesis.

### 3.6 `z1Rule`'s same-label constraint — respected by construction

`Axiom.z1` (`Axioms.lean:332`) is

```
G(Gφ → φ)  →  (F(Gφ) → Gφ)
```

and `z1Rule` (`Tableau.lean:1408-1413`) fires on `T(G(Gφ → φ))` with `T(F(Gφ))` at the **same
label**, emitting `T(Gφ)` there. Under §3.2 both premises are members of the *same*
`Branch.cell w t` list, hence conjuncts of the *same* `conjOf`, hence available together with no
temporal or modal step between them. The admissibility obligation is then a single-cell
propositional step plus one `Axiom.z1` instance at `.Discrete`:

```
⊢[fc]  conjOf(… G(Gφ→φ) … F(Gφ) … )  →  conjOf( Gφ :: … )      given  .Discrete ≤ fc
```

Keying `cell` on the *full* `Label` (world **and** time) is what guarantees this; a design that
grouped by time alone, or that placed the two premises at different nodes, would break it. The
constraint is a property of `Branch.cell`, and it holds for every rule that fires on a pair of
same-label formulas — which is also `priorUGap`/`priorSGap`/`sepRule`, all of which trigger on the
axiom's *antecedent conjunction* at one label (`Tableau.lean:387-396`).

### 3.7 The root anchor (pins the definition; 412 consumes it)

For the initial branch `b₀ = [SignedFormula.neg φ ⟨0,0⟩]` and `ord₀ = TimeOrdering.empty`:
`knownWorlds b₀ = [0]`, `knownTimes b₀ = [0]`, and both `directFutureOf 0` and `directPastOf 0` are
`[]`. So

```
b₀.internalize ord₀  =  ((φ.neg.and ⊤).and ⊤).and (⊤.and ⊤)
```

which is propositionally equivalent to `φ.neg`. 410 should ship

```lean
theorem internalize_initial (φ : Formula) {fc : FrameClass} :
    Derivable fc [] ([SignedFormula.neg φ ⟨0,0⟩].internalize TimeOrdering.empty).neg →
    Derivable fc [] φ
```

as part of `Internalize.lean`, because it is the lemma that *pins the definition* — without it, a
later edit to `slice`/`conjOf` could silently break 412's base case. It is cheap: `⊤`-conjunct
elimination from `Combinators.lean` plus double-negation elimination.

---

## 4. The `rule_admissible` Statement Shape — Corrected

Report 02 §3.1 proposes:

```lean
theorem rule_admissible (r : TableauRule) (sf : SignedFormula) (b : Branch) (ord : TimeOrdering)
    (h_fc : ruleFrameClass r ≤ fc) :
    ∀ children ∈ applyRule r sf b ord,
      Derivable fc [] (child.internalize).neg → Derivable fc [] (b.internalize).neg
```

Five corrections, each grounded in source:

1. **`applyRule` returns a pair.** `applyRule : TableauRule → SignedFormula → Branch →
   TimeOrdering → RuleResult × TimeOrdering` (`Tableau.lean:630-631`). The second component is the
   *new* ordering, and the fresh-time rules change it. The child must be internalized against
   `ord'`, not `ord`. Report 02's shape drops it and would state a false theorem for rules 15, 17,
   18, 20.

2. **`RuleResult` has five constructors, not one.** `.linear`, `.branching`, `.branchingOrdered`,
   `.persistent`, `.notApplicable` (`Tableau.lean:205-230`). `∀ children ∈ …` does not typecheck
   against it. The statement must case-split. `.branchingOrdered` is 430-only and should be an
   explicit hypothesis or a separate theorem.

3. **The payloads are *deltas*, not branches — except for `.branchingOrdered`.** From `expandOnce`
   (`Tableau.lean:2189-2197`):

   ```lean
   | .linear formulas       => (.extended (formulas ++ b), newOrd)
   | .branching branches    => (.split (branches.map fun new => new ++ b), newOrd)
   | .branchingOrdered brs  => (.splitOrdered brs, newOrd)          -- replacements
   | .persistent formulas   => (.extended (formulas ++ b), newOrd)
   ```

4. **The source formula is never removed.** This is the most consequential correction. Nothing in
   `expandOnce` subtracts `sf`; `.linear` and `.persistent` are *literally the same* branch
   operation, and the difference between "consumable" and "persistent" lives entirely in the
   `isExpanded`/`AppliedSet` guard (`Tableau.lean:1949, 2846`). Consequently **every child in 410's
   scope is `delta ++ b`**, and since `cell`/`slice`/`timeTree` are conjunctive and `b`'s conjuncts
   survive verbatim, the obligation collapses to: *each emitted formula's content is derivable, at
   its own label position, from the parent's internalization.* That is a positive-position
   strengthening, and it is why §5.1's monotonicity engine is the whole game.

5. **`h_fc` is discharged trivially for all 21.** Every rule in 410's scope has
   `ruleFrameClass r = .Base` (`RuleSpec.lean:151-175`), so `h_fc` is `FrameClass.base_le fc`
   (`Axioms.lean:568`) and every Base-only reused theorem lifts through
   `DerivationTree.lift (h_le := FrameClass.base_le fc)` (`Derivation.lean:190`, **[hover]**) or
   `Derivable.lift` (`Derivable.lean:110`, **[hover]**). Keep `h_fc` in the statement anyway — 411
   needs it and 412's induction over `allRulesForFC` supplies it via GATE 2
   (`mem_allRulesForFC_iff`, `RuleSpec.lean:310`).

**Recommended shape:**

```lean
/-- Per-rule admissibility: refutability of every child yields refutability of the parent. -/
theorem rule_admissible {fc : FrameClass} (r : TableauRule) (sf : SignedFormula)
    (b : Branch) (ord : TimeOrdering)
    (h_fc : ruleFrameClass r ≤ fc)
    (h_forest : ord.IsForestAt 0) :                       -- §3.5; 410 proves preservation
    match (applyRule r sf b ord) with
    | (.linear fs, ord')     => Derivable fc [] ((fs ++ b).internalize ord').neg →
                                Derivable fc [] (b.internalize ord).neg
    | (.persistent fs, ord') => Derivable fc [] ((fs ++ b).internalize ord').neg →
                                Derivable fc [] (b.internalize ord).neg
    | (.branching brs, ord') => (∀ nf ∈ brs, Derivable fc [] ((nf ++ b).internalize ord').neg) →
                                Derivable fc [] (b.internalize ord).neg
    | (.branchingOrdered _, _) => True                    -- 430's territory
    | (.notApplicable, _)      => True
```

In practice each of the 21 is stated as its own theorem with `r` fixed, so the `match` collapses to
the one arm the rule can produce, and the file splits cleanly along §2.1's lines. The *contrapositive
working form* every proof actually establishes is

```lean
⊢[fc]  b.internalize ord  →  (delta ++ b).internalize ord'
```

with the `Derivable`-of-negation statement obtained once, generically, by contraposition
(`Perpetuity/Principles.lean:116` `contraposition`, or `MonotonicityDuality.lean:480`
`doubleContrapose`).

---

## 5. Infrastructure 410 Must Build First

Report 02's asset list is a list of *object-language theorems*. It omits the four pieces of
*plumbing* without which every one of the 21 lemmas re-derives the same descent. These should be a
dedicated first phase of `Internalize.lean`, before any rule lemma.

### 5.1 Positive-context monotonicity (highest leverage)

Every label position in `internalize` occurs under `∧`, `◇`, `untl(·, ⊤)`, `snce(·, ⊤)` — all
monotone. So:

> **`internalize_mono`**: if `⊢[fc] X → Y` then `⊢[fc] C[X] → C[Y]` for every context `C` built
> from those four formers.

Assembled entirely from verified declarations:

| Former | Monotonicity route | Anchor |
|---|---|---|
| `∧` | `combineImpConj` / `combineImpConj3`, `pairing`, `impTrans` | `Combinators.lean:603, 622, 555, 99` |
| `◇` | `diamondMono` (or `kDistDiamond` + `necessitation`) | `Perpetuity/MonotonicityDuality.lean:150`; `ModalS5.lean:280` |
| `untl (·) ⊤` = `F` | `fMono`, or `right_mono_until` + `temporal_necessitation` | `TemporalDerived.lean:407`; `Axioms.lean:134` |
| `snce (·) ⊤` = `P` | `pMono`, or `right_mono_since` + `pastNecessitation` | `TemporalDerived.lean:417`; `Axioms.lean:138`; `GeneralizedNecessitation.lean:95` |
| `G`, `H` (if ever needed positively) | `futureMono`, `pastMono` | `MonotonicityDuality.lean:160, 170` |

Implement it as recursion over `timeTree`'s own structure (a `slice`-at-node replacement lemma plus
a tree-lifting lemma), not as a general `Formula` context type — the latter is a much larger
project and 410 does not need it.

### 5.2 `F`/`G` and `P`/`H` distribution: `fConjG` / `pConjH`

The four temporal *universal* rules (14, 16, 19, 21) propagate along the transitive closure
`futureOf`/`pastOf`, i.e. down a chain of `F` layers. The needed principle is

```
⊢ G ψ  →  (F A  →  F (A ∧ ψ))
```

**Not present in the tree** (checked). Assembled from verified pieces:

1. `⊢ ψ → (A → (A ∧ ψ))` — `pairing` (`Combinators.lean:555`) + `theoremFlip` (:169).
2. `⊢ G(ψ → (A → A ∧ ψ))` — `DerivationTree.temporal_necessitation` (`Derivation.lean:196`).
3. `⊢ Gψ → G(A → A ∧ ψ)` — `gDistribution` (`TemporalDerived.lean:260`).
4. `⊢ G(A → A∧ψ) → (U(A,⊤) → U(A∧ψ,⊤))` — `right_mono_until` (`Axioms.lean:134`); and
   `U(A,⊤) = F A` definitionally (`Formula.lean:131`).

Past mirror: `hDistribution` (:268) + `right_mono_since` (`Axioms.lean:138`), giving `pConjH`.
To reach a node `k` edges away, iterate with `gTransitivity : ⊢ Gφ → G(Gφ)`
(`TemporalDerived.lean:275`) / `hTransitivity` (:283) — that is exactly why `futureOf` is the
transitive closure and not the direct-edge filter (`SignedFormula.lean:764-771`).

### 5.3 Pulling `□` out of `◇`, and pushing content into every `◇`

The four S5 rules (9–12) all move content across worlds at a fixed time, so their whole obligation
is local to one `slice`:

- **Extract**: `s5DiamondBoxToTruth : ⊢ (◇□A) → A` (`ModalS5.lean:766`) and
  `s5DiamondBox : ⊢ (◇□A) ↔ □A` (:717) recover the universal claim from inside a `◇` conjunct.
  Combined with `diamondMono` to strip the rest of the cell.
- **Distribute**: `□ψ ∧ ◇A → ◇(A ∧ ψ)` from `modal_k_dist` (`Axioms.lean:106`) and `kDistDiamond`
  (`ModalS5.lean:280`); `boxConjIff` (:465) for the conjunction bookkeeping.
- **`◇⊤`** (needed when `boxNeg`/`diamondPos` mint a world with no content at some time node):
  `mbDiamond : ⊢ φ → ◇□φ` (`Perpetuity/Principles.lean:567`) with `boxToPresent` (`Helpers.lean:93`),
  or `tBoxToDiamond` (`ModalS5.lean:108`).
- **`¬◇`/`□¬` bookkeeping**: `modalDualityNeg` / `modalDualityNegRev`
  (`MonotonicityDuality.lean:78, 108`), `boxDne` (`Principles.lean:474`).

### 5.4 The Barcan step — the one genuinely hard item inside 410

**The problem.** In the four fresh-time existential rules, `gProps` and `fNegProps` are drawn from
`branch.allFuturePosFormulas` / `someFutureNegFormulas` filtered by `gsf.label.time == l.time`
**only** — the *world* is unconstrained, and the emitted formula lands at
`{ world := gsf.label.world, time := freshTime }` (`Tableau.lean:767-785, 807-825, 840-856,
884-900`). So a `T(Gχ)@(w₂, t)` with `w₂ ≠ l.world` contributes `T(χ)@(w₂, freshTime)`. Under
time-major internalization the source sits inside `◇` at node `t` and the target inside `◇` at node
`freshTime`, so the obligation contains

```
◇(G χ)  →  G(◇ χ)
```

a Barcan-type modal–temporal commutation. It is **not** an axiom of TM: the only modal–temporal
axiom is `modal_future : □φ → □(Gφ)` (`Axioms.lean:268`). And the configuration is **reachable**,
not vacuous: `boxNeg`/`diamondPos`'s `boxProps` emit `T(□ψ)` at a fresh world when the source is
`T(□□ψ)`, after which `boxTemporal` produces `T(Gψ)` there. Reachability is not load-bearing
either way: §4 states admissibility over `applyRule` directly rather than over the guarded engine
path, so the cross-world case is an obligation whether or not the engine ever schedules it.

**The resolution — a verified route exists.** Its contrapositive is `F(□θ) → □(F θ)`, and:

| Step | Statement | Anchor | Verified |
|---|---|---|---|
| 1 | `⊢ F θ → ▽ θ` (`F` is one disjunct of `sometimes`) | `sometimes φ = φ.neg.always.neg`, `Formula.lean:594`; `always φ = Hφ ∧ (φ ∧ Gφ)`, :460 | def-level |
| 2 | `⊢ ▽(□φ) → □(△φ)` | `Perpetuity/MonotonicityDuality.lean:560` `perpetuity6` | **[hover]**: `⊢ (▽φ.box).imp (△φ).box` |
| 3 | `⊢ △θ → G θ` | `MonotonicityDuality.lean:235` `alwaysToFuture` | grep-verified |
| 4 | `⊢ □(△θ) → □(Gθ)` | `MonotonicityDuality.lean:139` `boxMono` | grep-verified |
| 5 | `⊢ Gθ → Fθ` (needs a future point) | `Axiom.serial_future` `Axioms.lean:113` + `fConjG` (§5.2) | grep-verified |

so `F(□θ) → ▽(□θ) → □(△θ) → □(Gθ) → □(Fθ)`. Dualizing to `◇(Gχ) → G(◇χ)` costs the
`allFuture φ = (someFuture φ.neg).neg` double negations, for which
`doubleContrapose` (`MonotonicityDuality.lean:480`), `alwaysDne`/`alwaysDni` (:365, :267) and
`boxDne` (`Principles.lean:474`) are available.

An equivalent second route, worth trying first because it is shorter:
`persistence : ⊢ ◇φ → △(◇φ)` (`Principles.lean:698`) instantiated at `φ := Gχ` gives
`◇Gχ → G(◇Gχ)`; then inside the `G`, `◇Gχ → ◇Fχ` (seriality + `diamondMono`) and
`◇Fχ → ◇χ` (the contraposition of `modal_future`), closing via `futureMono`.

**Also available and probably worth extracting**: `⊢ ◇φ → G(◇φ)` is *already proved* inline as
`future_comp` inside `persistence` (`Principles.lean:771-787`) but is not a top-level declaration.
410 should extract it as a named lemma — it is free.

**Contingency, stated now rather than discovered later**: if the dualization proves worse than
budgeted, the four existential rules (15, 17, 18, 20) — and *only* their cross-world
`gProps`/`fNegProps` sub-case — are the item to promote to 411, since 411 already owns the
`Until`/`Since` block where these same commutations recur. They should **not** be `sorry`ed and the
cross-world case should **not** be silently dropped from the emitted set.

### 5.5 `boxDiamondPersistence` is `private` — use its three public lemmas

`boxDiamondPersistence` is `private def` at `Tableau.lean:434` and appears in the output of the four
fresh-time existential rules (and of `untlNeg`/`snceNeg`'s ACTIVE arms). It cannot be unfolded from
`Verified/Refutation/Rules/Temporal.lean`. Its intended public API is already in place, and the
docstrings say so explicitly (`Tableau.lean:480-485` names exactly "`allFutureNeg`, `allPastNeg`,
`someFuturePos`, `somePastPos`"):

| Lemma | Statement | Anchor |
|---|---|---|
| `mem_boxDiamondPersistence` | `g ∈ … → ∃ s ∈ branch, g.formula = s.formula` | `Tableau.lean:454` |
| `mem_boxDiamondPersistence_label` | `g.label = ⟨w, ft⟩ ∧ ∃ s ∈ branch, s.label = ⟨w, t⟩ ∧ s.sign = g.sign ∧ s.formula = g.formula` | `Tableau.lean:491` |
| `mem_boxDiamondPersistence_shape` | `(g.sign = .pos ∧ ∃ χ, g.formula = .box χ) ∨ (g.sign = .neg ∧ ∃ χ, g.formula = .imp (.box (.imp χ .bot)) .bot)` | `Tableau.lean:551` |

Together these say: every contributed formula is a `□`-positive or `◇`-negative relabelling of a
branch member from `(w,t)` to `(w,ft)`. The corresponding object-language obligation is
`□χ → G(□χ)` and `□χ → H(□χ)`, i.e. `temporalFutureDerived` (`Combinators.lean:653`) and
`boxToPast` (`Perpetuity/Helpers.lean:81`) composed with `modal_4` (`Axioms.lean:100`) — the exact
composition already performed at
`BXCanonical/Chronicle/ChronicleToCountermodelBasic.lean:385-390`.

One caveat: these three lemmas are *necessary* conditions on membership. For the `.linear` payload
`witness :: gProps ++ fNegProps ++ modalProps`, admissibility needs a statement about **every**
member, which is exactly what `∀ g ∈ …` over these three gives. No *sufficiency* (surjectivity)
lemma is required, because the obligation is universally quantified over what was emitted.

---

## 6. Phase Decomposition Recommendation

The 21 stratify cleanly by *how far the emitted content travels*, which is the natural phase
boundary:

| Tier | Rules | Travel | Depends on |
|---|---|---|---|
| 0 | — | — | §5.1 monotonicity engine, `conjOf`/`cell`/`slice`/`timeTree`, `internalize_initial` (§3.7), `applyRule_preserves_forest` (§3.5) |
| 1 | 8 propositional (1–8) | within one `cell` | Tier 0 + `Combinators.lean`, `deductionTheorem` |
| 2 | `boxTemporal` (13) | within one `cell` | Tier 0 + `boxToFuture`/`boxToPast` — the cheapest three lines in the task |
| 3 | 4 S5 modal (9–12) | across worlds, **one time node** | Tier 0 + §5.3 |
| 4 | 4 temporal universals (14, 16, 19, 21) | node → node, **one world** | Tier 0 + §5.2 |
| 5 | 4 temporal existentials (15, 17, 18, 20) | node → fresh node, **across worlds** | Tiers 0, 3, 4 + §5.4 + §5.5 |

Tier 5 is the risk. Tiers 1–4 are 17 of the 21 and have no unresolved step.

---

## 7. H3 Reference Grounding — Rule → Target → Reduces-To Mapping

Every row's "reduces to" declaration was located in source by name and line. `⊢[fc]` is
`DerivationTree fc Γ φ`; `⊢` is the `fc = .Base` instance, lifted by
`DerivationTree.lift (FrameClass.base_le fc)`. Target statements are written in the working
contrapositive form of §4 (`⊢[fc] b.internalize ord → child.internalize ord'`); the `Derivable`-of-
negation form follows by one generic contraposition step.

| Rule | Source statement (engine behaviour, anchored) | Target Lean statement | Reduces to (file:line) | Verified? |
|---|---|---|---|---|
| `andPos` | `T(¬(A→¬B))@l → T(A)@l, T(B)@l`; `.linear`, `Tableau.lean:635-638` via `asAnd?` :249 | `⊢[fc] cell l ∋ (A∧B) → cell l ∋ A, B` lifted by §5.1 | `Combinators.lean:99` `impTrans`, `:555` `pairing`, `:603` `combineImpConj`; `DeductionTheorem.lean:325` `deductionTheorem` | ✅ grep + **[hover]** on `deductionTheorem` |
| `andNeg` | `F(A∧B)@l → F(A)@l | F(B)@l`; `.branching`, :640-643 | two-arm: `⊢[fc] par → arm₁ ∨ arm₂` then case | `Combinators.lean:589` `notNotIntro`, `:292` `theoremApp1`, `:318` `theoremApp2`; `Axioms.lean:95` `peirce` | ✅ grep |
| `orPos` | `T(¬A→B)@l → T(A)@l | T(B)@l`; `.branching`, :645-648 via `asOr?` :258 | as above | `Axioms.lean:95` `peirce`, `:88` `prop_k`; `Combinators.lean:148` `bCombinator` | ✅ grep |
| `orNeg` | `F(A∨B)@l → F(A)@l, F(B)@l`; `.linear`, :650-653 | `⊢[fc] cell ∋ ¬(A∨B) → cell ∋ ¬A, ¬B` | `Combinators.lean:99, 555, 589` | ✅ grep |
| `impPos` | `T(A→B)@l → F(A)@l | T(B)@l`; `.branching`, :655-656 (matches `.imp` directly) | two-arm | `Axioms.lean:95` `peirce`; `Combinators.lean:112` `mp` | ✅ grep |
| `impNeg` | `F(A→B)@l → T(A)@l, F(B)@l`; `.linear`, :658-659 | `⊢[fc] cell ∋ ¬(A→B) → cell ∋ A, ¬B` | `Combinators.lean:292` `theoremApp1`, `:589` `notNotIntro`; `Axioms.lean:93` `ex_falso` | ✅ grep |
| `negPos` | `T(A→⊥)@l → F(A)@l`; `.linear`, :661-664 via `asNeg?` :240 | identity modulo `neg` unfolding (`Formula.lean:121`) | `Combinators.lean:126` `identity` | ✅ grep |
| `negNeg` | `F(A→⊥)@l → T(A)@l`; `.linear`, :666-669 | DNE step | `Combinators.lean:589` `notNotIntro`; `MonotonicityDuality.lean:480` `doubleContrapose` | ✅ grep |
| `boxPos` | `T(□ψ)@(w,t) → T(ψ)@(w',t)` ∀ `w' ∈ knownWorlds`; `.persistent`, :671-677 | `⊢[fc] slice t (b) → slice t (child)` | `ModalS5.lean:766` `s5DiamondBoxToTruth`, `:717` `s5DiamondBox`, `:280` `kDistDiamond`, `:465` `boxConjIff`; `Axioms.lean:98` `modal_t`, `:106` `modal_k_dist` | ✅ grep |
| `boxNeg` | `F(□ψ)@(w,t) → F(ψ)@(wF,t)` + `boxProps` + `diaProps`, all at their *sources'* times; `.linear`, :679-702 | slice-wise, one new `◇` conjunct per affected node | `MonotonicityDuality.lean:78, 108` `modalDualityNeg(Rev)`; `Principles.lean:474` `boxDne`, `:567` `mbDiamond`; `Axioms.lean:98, 102` `modal_t`, `modal_b` | ✅ grep |
| `diamondPos` | `T(◇ψ)@(w,t) → T(ψ)@(wF,t)` + same props; `.linear`, :704-729 via `asDiamond?` :267 | as `boxNeg` | same as `boxNeg`; `ModalS5.lean:108` `tBoxToDiamond` | ✅ grep |
| `diamondNeg` | `F(◇ψ)@(w,t) → F(ψ)@(w',t)` ∀ `w'`; `.persistent`, :731-740 | as `boxPos`, via `¬◇ = □¬` | `MonotonicityDuality.lean:78, 108`; `ModalS5.lean:766, 280` | ✅ grep |
| `boxTemporal` | `T(□ψ)@l → T(Gψ)@l, T(Hψ)@l`; `.persistent`, :743-748 | `⊢[fc] cell ∋ □ψ → cell ∋ Gψ, Hψ` | `Perpetuity/Helpers.lean:62` `boxToFuture` (`⊢ □φ → Gφ`), `:81` `boxToPast` (`⊢ □φ → Hφ`) | ✅ grep — both exact |
| `allFuturePos` | `T(Gψ)@(w,t) → T(ψ)@(w,t')` ∀ `t' ∈ futureOf t`; `.persistent`, :751-757 | node-to-node within one world's `F`-chain | `TemporalDerived.lean:275` `gTransitivity`, `:260` `gDistribution`; `Axioms.lean:134` `right_mono_until`; §5.2 `fConjG` (**new**) | ✅ grep (assets); ❗ `fConjG` **to be built** |
| `allFutureNeg` | `F(Gψ)@(w,t) → F(ψ)@(w,tF)` + `gProps` + `fNegProps` + `boxDiamondPersistence`; `.linear`, `newOrd = addFuture`, :760-788 | grows one `F`-child of node `t` | `TemporalDerived.lean:504` `fNegG` (`¬Gψ → F¬ψ`); `Tableau.lean:491, 551` `mem_boxDiamondPersistence_{label,shape}`; `Combinators.lean:653` `temporalFutureDerived`; §5.2, §5.4 | ✅ grep (assets); ❗ §5.4 chain **to be built** |
| `allPastPos` | `T(Hψ)@(w,t) → T(ψ)@(w,t')` ∀ `t' ∈ pastOf t`; `.persistent`, :791-797 | past mirror of `allFuturePos` | `TemporalDerived.lean:283` `hTransitivity`, `:268` `hDistribution`; `Axioms.lean:138` `right_mono_since`; §5.2 `pConjH` (**new**) | ✅ grep (assets); ❗ `pConjH` **to be built** |
| `allPastNeg` | `F(Hψ)@(w,t) → F(ψ)@(w,tF)` + `hProps` + `pNegProps` + persistence; `.linear`, `newOrd = addPast`, :800-828 | past mirror of `allFutureNeg` | `TemporalDerived.lean:514` `pNegH`; `Perpetuity/Helpers.lean:81` `boxToPast`; `Tableau.lean:491, 551`; §5.2, §5.4 | ✅ grep (assets); ❗ §5.4 |
| `someFuturePos` | `T(Fψ)@(w,t) → T(ψ)@(w,tF)` + same props; `.linear`, :831-860 via `asSomeFuture?` :285 | grows one `F`-child | `Axioms.lean:255` `F_until_equiv` (`Fφ → U(φ,⊤)` — here definitional, `Formula.lean:131`); `TemporalDerived.lean:407` `fMono`; `Tableau.lean:491, 551`; §5.2, §5.4 | ✅ grep (assets); ❗ §5.4 |
| `someFutureNeg` | `F(Fψ)@(w,t) → F(ψ)@(w,t')` ∀ `t' ∈ futureOf t`; `.persistent`, :863-872 | as `allFuturePos`, modulo `¬F` vs `G` DNE | `TemporalDerived.lean:260, 275`; `Combinators.lean:589` `notNotIntro`; §5.2 | ✅ grep (assets) |
| `somePastPos` | `T(Pψ)@(w,t) → T(ψ)@(w,tF)` + props; `.linear`, :875-903 via `asSomePast?` :276 | past mirror | `Axioms.lean:260` `P_since_equiv`; `TemporalDerived.lean:417` `pMono`; `Tableau.lean:491, 551`; §5.2, §5.4 | ✅ grep (assets); ❗ §5.4 |
| `somePastNeg` | `F(Pψ)@(w,t) → F(ψ)@(w,t')` ∀ `t' ∈ pastOf t`; `.persistent`, :907-916 | past mirror of `someFutureNeg` | `TemporalDerived.lean:268, 283`; `Combinators.lean:589`; §5.2 | ✅ grep (assets) |

Shared infrastructure rows (used by all 21):

| Item | Target | Reduces to (file:line) | Verified? |
|---|---|---|---|
| Frame-class lifting | Base theorem → `⊢[fc]` | `Derivation.lean:190` `DerivationTree.lift`; `Derivable.lean:110` `Derivable.lift`; `Axioms.lean:568` `FrameClass.base_le` | ✅ **[hover]** on both `lift`s |
| Context discharge | `A :: Γ ⊢[fc] B` → `Γ ⊢[fc] A → B` | `DeductionTheorem.lean:325` `deductionTheorem` | ✅ **[hover]** |
| `□`/`G`/`H` over contexts | `Γ ⊢ φ → □Γ ⊢ □φ` etc. | `GeneralizedNecessitation.lean:148` `generalizedModalK`, `:183` `generalizedTemporalK`, `:223` `generalizedPastK`, `:95` `pastNecessitation`, `:114` `pastKDist` | ✅ grep, all four at report 02's line numbers (file corrected, §1.3) |
| K-distribution | `G(A→B) → (GA → GB)` | `Principles.lean:617` `futureKDist`, `:664` `pastKDist` (note: a second `pastKDist` at `GeneralizedNecessitation.lean:114` is the `{fc}`-generic one — prefer that) | ✅ grep |
| Barcan chain | `◇Gχ → G◇χ` | `MonotonicityDuality.lean:560` `perpetuity6`, `:235` `alwaysToFuture`, `:139` `boxMono`, `:150` `diamondMono`, `:480` `doubleContrapose`; `Principles.lean:698` `persistence`, `:811` `perpetuity5`, `:512` `perpetuity4`; `Axioms.lean:113` `serial_future`, `:268` `modal_future` | ✅ **[hover]** on `perpetuity6`; grep on the rest |
| `◇φ → G◇φ` | extract as named lemma | currently only an inline `have future_comp` at `Principles.lean:771-787` | ⚠️ **exists as a proof step, NOT as a declaration** — must be extracted |

**Two rules named by report 02 §3.2's asset column that 410 will *not* use**, recorded so 411 does
not assume 410 consumed them: `self_accum_until` (`Axioms.lean:174`), `absorb_until` (:186),
`left_mono_until_G` (:123), `enrichment_until` (:156), `linear_until` (:196), `linear_since` (:205),
`temp_linearity` (:238), `z1` (:332), `prior_UZ` (:315), `prior_SZ` (:320), `density` (:343),
`dense_indicator` (:354), `prior_U_gap` (:399), `prior_S_gap` (:409), `sep` (:420) — all verified
present, all 411's. `enrichment_until` is the exception 410 *touches* only in the sense that §3.4
reserves the guard slot for it; 410 writes no proof using it.

---

## 8. Risks

| # | Risk | Likelihood | Mitigation |
|---|---|---|---|
| R1 | The Barcan dualization (§5.4) costs more than one phase | Medium | Route B (`persistence` + `modal_future` contraposed) tried first; if both fail, promote rules 15/17/18/20 to 411 — do **not** `sorry`, do **not** drop the cross-world sub-case |
| R2 | `internalize`'s `guard` parameter turns out to need to be per-edge rather than global | Medium-low | `guard : TimeIndex → TimeIndex → Formula` instead of `Formula` costs nothing now and is unpleasant to retrofit; recommend the function form if 411's needs are at all unclear |
| R3 | 411 instantiates `guard` at a non-`⊤` value and 410's 21 lemmas do not transfer | Medium | Tiers 1–3 (13 of 21) never touch a tree edge, so they are guard-agnostic outright. State Tiers 4–5 generically in `guard` where the proof permits; otherwise this is 411's cost, and it should be told so |
| R4 | The forest hypothesis (§3.5) propagates into 412's `allClosed_derivable` as an unproved side condition | Medium | 410 supplies `applyRule_preserves_forest` for its 21; the residual obligation is exactly `densityRule` (411) and `timeLinearity` (430), named in this report so neither task can lose it |
| R5 | `private boxDiamondPersistence` needs a *fourth* public lemma 410 cannot add (it does not own `Tableau.lean`) | Low | The three existing lemmas are universally quantified over membership, which is the direction admissibility needs (§5.5). If a fourth is needed, it is a one-line `Prop`-valued additive lemma and should be raised as a blocker, not worked around |
| R6 | `impPos`/`impNeg` match `.imp` directly and therefore overlap `negPos`/`negNeg`/`andPos` on the *same* formula | None (not a risk) | Recorded to pre-empt confusion: each admissibility lemma is stated per rule and is independently true; overlap only affects engine priority (`Tableau.lean:1569-1588`), not admissibility |

---

## 9. Adversarial Self-Verification

### Claim Verification Table

| Claim | Source / Counterexample | Verification method | Confidence |
|---|---|---|---|
| `allRulesForFC` contains 34 distinct rules across the 4 classes | `Tableau.lean:1569-1636`; 26+2+3+3; cross-checked against `RuleSpec.lean:362-365` (26/28/29/31) and `allTableauRules_length = 36` (:282) with 2 excluded (:337, :342) | source read of both files, two independent pinned counts | **High** |
| 410's territory is exactly 21 lemmas | Plan division table `plans/01_...md:3914` (`{Propositional,Modal,Temporal}.lean`); report 09 `:218` ("~21 routine lemmas"); brief's 8+4+1+8; my enumeration §1.2 sums to 21 and 21+13+2 = 36 | three independent sources agree; arithmetic closed | **High** |
| `expandOnce` never removes the source formula | `Tableau.lean:2189-2197`: `.linear`/`.persistent` both `formulas ++ b`, `.branching` `branches.map (· ++ b)` | direct source read of the only branch-construction site | **High** |
| "consumable" is enforced by `isExpanded`/`AppliedSet`, not subtraction | `Tableau.lean:1949` `isExpanded`, `:2846` `isExpandedWithApplied`, `:1559` `AppliedSet` | declaration list + the absence of any subtraction in `expandOnce` | Medium-high — I did not read `findApplicableRule`'s body in full, so I assert *no subtraction in `expandOnce`* (verified) and infer the guard mechanism from names and the `AppliedSet` type (inferred) |
| The passive arms of `untlNeg`/`snceNeg` are retired; only the ACTIVE arms survive | `Tableau.lean:1017-1062` (tombstone), guard at `:1063`, `.branching` at `:1133`; mirror at `:1148-1162, 1163, 1207` | source read of both arms | **High** |
| `sat_untl_neg` / `sat_snce_neg` are deleted | `grep -rn "sat_untl_neg\|sat_snce_neg" --include=*.lean` → no output | negative grep over the whole tree | **High** |
| `serialityRule`/`timeLinearity` are outside `allRulesForFC` and are not 410's | `RuleSpec.lean:337, 342` (theorems, `by decide`); scheduled at `Tableau.lean:2176-2183` | source read; these are proved facts, not conventions | **High** |
| `deductionTheorem` has signature `{fc} (Γ) (A B) (h : A :: Γ ⊢[fc] B) : Γ ⊢[fc] A.imp B` | `DeductionTheorem.lean:325` | **`lean_hover_info`-confirmed type signature** | **High** |
| `DerivationTree.lift {fc₁ fc₂} (h_le : fc₁ ≤ fc₂) {Γ φ} : DerivationTree fc₁ Γ φ → DerivationTree fc₂ Γ φ` | `Derivation.lean:190` | **`lean_hover_info`-confirmed type signature** | **High** |
| `Derivable.lift {fc₁ fc₂} (h_le) {G p} (h : G ⊢![fc₁] p) : G ⊢![fc₂] p` | `Derivable.lean:110` | **`lean_hover_info`-confirmed type signature** | **High** |
| `perpetuity6 : ⊢ (▽φ.box).imp (△φ).box` | `MonotonicityDuality.lean:560` | **`lean_hover_info`-confirmed type signature** | **High** |
| `persistence : ⊢ φ.diamond.imp φ.diamond.always` exists at `Principles.lean:698` | grep `def persistence` | grep only (not hover) — signature read from the source line, which states it verbatim | Medium-high |
| `boxToFuture : ⊢ φ.box.imp φ.allFuture`, `boxToPast : ⊢ φ.box.imp φ.allPast` | `Perpetuity/Helpers.lean:62, 81` | grep with full signature line captured | **High** |
| `◇φ → G(◇φ)` exists only as an inline `have`, not as a declaration | `Principles.lean:771` is inside `persistence`'s `by` block (:698); no `^def` matched the name | grep of `^def`/`^noncomputable def` in the file plus reading :765-790 | Medium-high |
| `◇(Gχ) → G(◇χ)` is **not** a TM axiom | `Axioms.lean` Layer 4 has exactly one modal–temporal axiom, `modal_future` (:268), and the file comment at :265 says "Modal-Temporal Interaction (1)" | source read of the axiom list around :262-270 | Medium-high — I read the Layer 4 header and its single constructor; I did not exhaustively re-read all 45 constructors for a differently-named equivalent |
| The Barcan configuration must be handled (a `T(Gχ)` at a world other than the rule's source world) | Two independent grounds. (a) **Unconditional**: `gProps`/`fNegProps` filter on `gsf.label.time == l.time` **only** and emit at `gsf.label.world` (`Tableau.lean:767-785`), so `applyRule` produces the cross-world case for *any* branch containing such a formula — and §4 states `rule_admissible` over `applyRule` directly, so reachability is irrelevant to the obligation. (b) **Reachability, for information**: `boxNeg`'s `boxProps` (`Tableau.lean:685-690`, `| .box inner => SignedFormula.pos inner {world := freshWorld, time := bsf.label.time}`) turns `T(□□ψ)` into `T(□ψ)` at the fresh world; `boxTemporal` (`:743-748`, matching `.pos, .box ψ` at any label) then yields `T(Gψ)` there | (a) source read of the emitting arm's filter — decisive on its own; (b) two-step trace with both call sites read | **High** for (a); Medium-high for (b) — (b) is a source-level trace, not a measured `#eval` firing, but nothing in this report depends on it |
| World-major internalization breaks `boxPos` because `F(□ψ) → □ψ` is false | Semantics: `TruthAt … (box φ)` quantifies at the *same* `t` (`Truth.lean`, `Formula.box` clause), so `F□ψ` at `t` says nothing about `t` | semantic counterexample from the truth definition; no formal Lean refutation attempted | Medium-high |
| Each of 410's 21 rules preserves the forest shape of `ord` | `addFuture`/`addPast` prepend one pair (`SignedFormula.lean:685, 689`); `nextTime` (:380) exceeds every branch time; call sites `Tableau.lean:763, 803, 836, 880` | source read of all four call sites and both mutators | Medium-high — asserted as the *statement to be proved* by `applyRule_preserves_forest`, not as an already-proved fact |
| `densityRule` and `timeLinearity` break it | `identifyTime` (`SignedFormula.lean:705`) rewrites constraints, so a merged node inherits both predecessor sets; `densityRule` (`Tableau.lean:1338+`) inserts between `t` and an existing `t' ∈ futureOf t` | source read of `identifyTime`; `densityRule`'s body read only at its head comment (:1336-1341) | Medium — the `densityRule` claim rests on its docstring (`Tableau.lean:137-140`) plus the head of its arm, not on a full read of the arm body |
| `priorUZ`/`priorSZ` belong to 411 despite report 02 rating them routine | Plan `:3914` gives 410 only `{Propositional,Modal,Temporal}.lean`; `:3915` gives 411 `Rules/Discrete.lean`; both independent 410 counts equal 21 without them | cross-check of plan file against two count sources | **High** |
| Report 02's line-number claims for `Combinators`/`ModalS5`/`TemporalDerived`/`GeneralizedNecessitation`/`DeductionTheorem` and for `Axioms.lean`'s Base/Dense/Discrete rows are accurate; its Dedekind rows and `base_le` have drifted | per-name grep with line output, §1.3 table | grep on 30 names | **High** |
| No `internalize` or `rule_admissible` declaration exists yet | `grep -rn "internalize\|Internalize"` returns only docstring prose in `WeakCanonical/Kamp/*` and `RuleSpec.lean`; `grep "rule_admissible\|ruleAdmissible"` returns nothing | two negative greps over the tree | **High** |

### Contradiction Log

**C1 — `priorUZ`/`priorSZ`: report 02 says routine (→ implies 410-shaped work), plan says
`Rules/Discrete.lean` (→ 411).** Precedence: the plan is the later artifact and is the H7 territory
contract; report 02's difficulty rating is an *estimate*, the plan's file assignment is an
*allocation*. Resolved in favour of the plan (§2.2). Both readings are recorded so 411 knows these
are its two cheapest lemmas rather than assuming they were done.

**C2 — report 02 §3.1's `rule_admissible` shape vs. `applyRule`'s actual type.** Report 02 writes
`∀ children ∈ applyRule r sf b ord`, which does not typecheck: `applyRule` returns
`RuleResult × TimeOrdering` (`Tableau.lean:630`) and `RuleResult` has five constructors (:205-230).
Precedence: source over report. Resolved in §4 with five named corrections. This is a *statement-
shape* correction, not a change of approach — the internalization design report 02 settles is
untouched.

**C3 — report 02 §3.2 attributes `generalizedTemporalK`/`generalizedPastK` to
`TemporalDerived.lean:183,223`.** They are at `GeneralizedNecessitation.lean:183,223`. Precedence:
grep over report. The line numbers are right, so this reads as a file-context slip in the table's
bare-`:` convention, not a wrong claim about existence.

**UNRESOLVED CONTRADICTION: none.** Every disagreement found had a decidable precedence.

### Claims explicitly NOT verified

- The exact `by`-block feasibility of any proof sketched in §5. Every *ingredient* is verified to
  exist with the stated type; no composition was executed in Lean. §5.2's `fConjG`, §5.4's Barcan
  chain, and §5.1's monotonicity engine are **designs, not proofs**.
- `densityRule`'s and `sepRule`'s arm bodies (read only at their heads and docstrings).
- `findApplicableRule`'s body (`Tableau.lean:1899`), `witnessPresent` (:1838), `ruleSelfGuarded`
  (:1817) — inspected by signature only. This does not affect §4, which states admissibility over
  `applyRule` directly (strictly stronger than over the guarded engine path).
- Whether some *differently named* declaration in the tree already proves `◇Gχ → G◇χ`. I searched
  by shape (`diamond.*allFuture`, `allFuture.*diamond`, `someFuture.*box`, `box.*someFuture`) over
  `Theorems/` and `ProofSystem/` and found only the inline `future_comp`. A `lean_loogle` type-
  pattern search was not run.
- No `lake build` was run; this dispatch wrote no Lean.

### Recommendations modified after verification

1. **Dropped**: "state `internalize` with a general `Formula` context type for monotonicity." Scoped
   down to recursion over `timeTree`'s own structure (§5.1) after seeing how few formers occur.
2. **Reversed**: an initial world-major design (worlds outermost) was abandoned once
   `TruthAt`'s `box` clause showed `F(□ψ) → □ψ` is invalid, which kills `boxPos` (§3.4).
3. **Upgraded from "blocker" to "hard but routed"**: the Barcan step. It was written up as a
   genuine obstruction until `perpetuity6` and `persistence` were found; both are proven, and
   `perpetuity6`'s signature is hover-confirmed (§5.4).
4. **Added**: §3.5's forest hypothesis and `applyRule_preserves_forest`. Not in report 02, and it
   is the item that would otherwise have become a silent unsoundness in `internalize` or a `sorry`
   in 411/430.
5. **Added**: §5.5. `boxDiamondPersistence` being `private` was not anticipated; the three
   `mem_*` lemmas turn it from a blocker into a solved problem.

---

## 10. Anchors

Declarations verified by `lean_hover_info` (exact signatures in §7): `deductionTheorem`
(`FormalSystem/Metalogic/Core/DeductionTheorem.lean:325`), `DerivationTree.lift`
(`FormalSystem/ProofSystem/Derivation.lean:190`), `Derivable.lift`
(`FormalSystem/ProofSystem/Derivable.lean:110`), `perpetuity6`
(`FormalSystem/Theorems/Perpetuity/MonotonicityDuality.lean:560`).

Primary source files read: `FormalSystem/Metalogic/Decidability/Tableau.lean` (rule inductive,
`applyRule`, rule lists, `expandOnce`, `boxDiamondPersistence` + its three lemmas),
`FormalSystem/Metalogic/Decidability/Verified/RuleSpec.lean` (whole file),
`FormalSystem/Metalogic/Decidability/SignedFormula.lean` (`Label`, `Branch` API, `TimeOrdering`),
`FormalSystem/ProofSystem/Axioms.lean` (Layers 3–8, `FrameClass`, `base_le`),
`FormalSystem/Syntax/Formula.lean` (constructors and derived operators),
`FormalSystem/Semantics/Truth.lean` (`TruthAt`), `FormalSystem/Theorems/{Combinators,ModalS5,
TemporalDerived,GeneralizedNecessitation}.lean`, `FormalSystem/Theorems/Perpetuity/{Helpers,
MonotonicityDuality,Principles}.lean`.

Prior artifacts: `specs/165_establish_semantic_finite_model_property/reports/02_tableau-decidability-hard-research.md`
§§1.2-1.3, 3.1-3.4; `.../reports/09_phase7-deadlock-blocker-research.md` §3;
`.../plans/01_tableau-decidability-two-track.md` :17, :243-245, :270-275, :3914-3916.

Literature: the `<literature-briefing>` (33 documents, `sparse=false`) was consulted. The
Burgess 1982 "Axioms for Tense Logic I: Since and Until"
(`~/Projects/Literature/sources/burgess_1982_i`) and Reynolds 1992 entries are the sources behind
`Axioms.lean`'s BX layer, but **no chunk was needed for this dispatch**: the axioms are already
transcribed into source with per-constructor docstrings naming their Burgess/Xu numbering
(e.g. `enrichment_until` = "Burgess A3a, Xu axiom (3)", `Axioms.lean:149`), and 410's work is
against those transcriptions rather than against the papers. Several 1993/1994 Gabbay-Hodkinson-
Reynolds entries in the briefing carry `[UNVERIFIED - provenance_fidelity: unverified_summary]`
banners; none is cited here. 411 is the task for which a Reynolds 1992/2003 acquisition pass
matters (report 02 §10).
