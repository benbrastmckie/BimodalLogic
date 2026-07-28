# Phase 2 Summary: Calculus Completion (R7, R2, R6, R5)

- **Task**: 165 - establish_semantic_finite_model_property
- **Plan**: plans/01_tableau-decidability-two-track.md
- **Phase**: 2 — status `[PARTIAL]` (2.1, 2.2, 2.3 complete; 2.4 blocked)
- **Verification**: `lake build` green, `lake build BimodalTest` green, zero new sorries,
  zero new axioms, zero vacuous definitions.

## What landed

### 2.1 R7 — verdict split (complete)

`DecisionResult.timeout` split into `.fuelExhausted` (tableau fuel ran out; validity
undetermined) and `.extractionFailed` (every branch closed, so the formula *is* valid, but no
proof term was reconstructed). `isUndecided` holds of the former only — that is the honest-
reporting property the single constructor made unstatable.

`decide_result_exclusive` reproved as four-way exclusivity, plus two new theorems
(`not_undecided_of_extractionFailed`, `isKnownValid_of_extractionFailed`). The
`CancellableExpansion` `IO` mirror and six `Automation/` consumers were updated;
`decideAutoAdaptive` now tags the two cases `adaptive_timeout` vs `adaptive_extraction_failed`
so the dataset pipeline keeps the distinction without changing its label vocabulary.

### 2.2 R2 — `orderTrichotomy` (complete)

New base rule branching syntactically on the three `temp_linearity` (BX11) disjuncts, as
settled by the plan.

**Recorded deviation from the phase text.** The phase specified a trigger on two positive
eventualities `T(F φ)`, `T(F ψ)` at one label. That trigger is unreachable: on
`F φ ∧ F ψ → …` the branch reaches `T(F φ)` while `T(F ψ)` is still inside an undecomposed
conjunction, and `someFuturePos` — consumable — destroys `T(F φ)` before the pair ever
coexists. The rule instead triggers on the **witness**: a positive formula at a time with an
incomparable sibling time under a common predecessor, same world. Branches are unchanged.

Termination needed three guards, each with a measured trace behind it (all documented
in-code): the conclusion still present; the two witness sets now ordered; and
first-witnesses-only. With only the first, the rule fires once per newly created time forever
(counterexample B `STALLED` at fuel 20000).

Counterexample B flips OPEN → CLOSED. It needs fuel ≈ 10000 because `expandBranchWithFuel`
divides fuel proportionally across a split; `Row` therefore gained a per-row `fuel` override
rather than moving the corpus-wide bound, which was tried and made the corpus take minutes.

### 2.3 R6 — `dedekindRules` (complete)

`priorUGap`, `priorSGap`, `sepRule` — tableau counterparts of `Axiom.prior_U_gap`,
`Axiom.prior_S_gap`, `Axiom.sep`, and the only consumers of `Formula.kPlus`/`kMinus`.

Two design points, recorded in-code: each rule triggers on its axiom's **antecedent
conjunction** (a conjunct trigger loses the same race 2.2 hit), and the Dedekind arm is
**prepended** to `allRulesForFC` rather than appended — appended, the consumable Until/Since
rules destroy the antecedent first and the rules are dead code. `Discrete ≰ Dedekind` is
preserved: the arm is base + dense + dedekind.

All three Dedekind rows flip STALLED → CLOSED.

### 2.4 R5 — certificate strengthening (BLOCKED)

See the `**BLOCKER**` block under Phase 2 in the plan and `.orchestrator-handoff.json`. In
short: certifying `findUnexpanded … = none` is unavailable (the applied set is the only thing
preventing an unbounded persistent/consumable cycle), and the applied-set route needs a proved
redundancy lemma whose obvious statement is false.

Landed instead, green and non-vacuous: a "Certificate Strength (R5)" section in
`Saturation.lean` recording the choice and the measured D4 orphan table; executable
`appliedEntryRedundant` / `AppliedRedundant` predicates; and two pinned probes in the corpus.

## Conformance corpus

Exactly four rows moved, across all four class tables:

| Row | Before | After |
|---|---|---|
| `B lin-perm` (all four classes) | OPEN | CLOSED |
| `R1 prior-U-gap` (Dedekind) | STALLED | CLOSED |
| `R2 prior-S-gap` (Dedekind) | STALLED | CLOSED |
| `R3 sep` (Dedekind) | STALLED | CLOSED |

No other verdict changed — in particular every control row and every `[DEFECT]` row held.

New pinned probes:

```
◇p        : fullySaturated=false applied=3 orphans=3 appliedRedundant=true
G p → p   : fullySaturated=true  applied=0 orphans=0 appliedRedundant=true
```

## Carried forward

1. **Phase 5.1's premise is at risk.** The plan says "trichotomy now guarantees totality" of a
   saturated branch's time order. R2 does not deliver that: `applyRule` returns a *single*
   `TimeOrdering` for all branches of a split, so a branching rule structurally cannot attach a
   different ordering per branch. The trichotomy emits disjuncts (creating fresh witness times)
   rather than ordering the two existing incomparable times.
2. **The seriality defect remains unowned** (unchanged from Phase 1): all five seriality/dual
   rows and `F q → F^k ⊤` for `k ≥ 2` still answer OPEN. Phase 2's scope does not touch it.
3. **`orderTrichotomy` is analytic** and may be refutation-incomplete — the plan's Risk 1.
4. **`TableauRule` now has 34 constructors**, which is the count Phase 3's `RuleSpec` gate
   must cover.
