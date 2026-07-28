# Phase 3 — RuleSpec Gate: Self-Enforcing Frame-Class Composition

- **Task**: 165 — establish_semantic_finite_model_property
- **Phase**: 3 of 8 (wave 3; Phases 4 and 5 are its parallel siblings)
- **Plan**: `plans/01_tableau-decidability-two-track.md`
- **Commit**: `6ee047de4`
- **Status**: `[COMPLETED]`
- **Started**: TBD
- **Completed**: TBD
- **Artifacts**: TBD
- **Standards**: TBD

## What the phase was for

The engine's frame-class rule lists (`denseRules`, `discreteRules`, `dedekindRules`, and the two
rules scheduled outside them) were hand-maintained and disconnected from `Axiom.minFrameClass`.
Nothing enforced that a `.Discrete`-gated rule is justified by a `.Discrete`-gated axiom. Adding
an axiom did not prompt a rule; mis-gating a rule was silent. This phase makes that
correspondence a machine-checked fact, so the failure mode becomes a build break rather than
drift.

## What landed

`FormalSystem/Metalogic/Decidability/Verified/RuleSpec.lean` (~350 lines) plus
`Verified/README.md`. One line was added to `Decidability.lean` — the aggregator import, without
which the module is never elaborated and the gates never checked.

`ruleFrameClass` and `ruleAxioms` are **exhaustive** 36-case matches with no wildcard arm. That
is half the self-enforcement: a 37th `TableauRule` constructor does not compile until someone
declares its frame class and its grounding axioms. The other half is three gates, each `by
decide` over the finite product of 36 rules and 4 frame classes, all elaborating in 2.0 s total:

| Gate | Statement | Catches |
|------|-----------|---------|
| GATE 1 `ruleAxioms_minFrameClass_le` | every axiom grounding `r` has `minFrameClass ≤ ruleFrameClass r` | a rule available below the class its axioms need |
| GATE 2 `mem_allRulesForFC_iff` | `r ∈ allRulesForFC fc ↔ r ≠ .serialityRule ∧ r ≠ .timeLinearity ∧ ruleFrameClass r ≤ fc` | the engine's lists drifting from the spec |
| GATE 3 `ruleAxioms_covers_ruleFrameClass` | a rule above `.Base` names an axiom at exactly its class | the rule lattice outgrowing the axiom lattice |

Plus corollaries the later phases will consume: `mem_allRulesForFC_mono` (the monotonicity that
lets one induction over `allRulesForFC fc` specialise to all four classes),
`serialityRule_not_mem_allRulesForFC` and `timeLinearity_not_mem_allRulesForFC`, and regression
pins on the constructor count (36) and the four rule-list lengths (26 / 28 / 29 / 31).

## Three things worth carrying forward

**The exclusion clause is wider than the plan text.** The revision named `serialityRule` because
it was written before 2.7 landed `timeLinearity`. Both are `.Base` rules deliberately outside
`allRulesForFC` for the same reason — each is keyed on something other than a formula's shape, so
no position in a per-formula priority list is correct — and both therefore satisfy the plain
equivalence's right-hand side at every frame class while satisfying its left at none. Excluding
only the first leaves the gate false on four rule/class pairs.

**A third gate was needed.** Both planned gates run axiom-class → rule-class, and neither catches
a rule gated high with nothing behind it — which is the exact failure report 02 §8.3 cites as the
motivation ("adding a Dedekind rule without an accompanying Dedekind axiom breaks the build
immediately"). GATE 3 is what makes that sentence true. It is also what makes the empty
`ruleAxioms` entries safe rather than a loophole: the eight `G`/`H`/`F`/`P` decomposition rules
implement a semantic truth condition rather than any axiom's image, and an empty list is licit at
`.Base` and, by GATE 3, can never be right anywhere else.

**`LawfulBEq TableauRule` was a prerequisite, not a nicety.** `TableauRule` derives `DecidableEq`
and `BEq` independently, and the core `Decidable (a ∈ l)` instance routes through `LawfulBEq`,
which no deriving handler supplies. Since every gate is a membership check, without the instance
*none* of them is decidable — and the synthesis error names `Decidable`, not `LawfulBEq`, which
is a misleading place to start looking. The instance is `Prop`-valued and cannot change what the
engine computes; it belongs beside the `deriving` clause in `Tableau.lean` and should move there
when a later phase owns that file.

## Done-criterion evidence

The phase's stated done-criterion was that deliberately mis-gating a rule is *confirmed* to fail
the build. Five mis-gatings were applied, built, and reverted from a byte-identical backup. Each
gate turned out to catch something the others do not:

| Control | Gates broken |
|---------|--------------|
| `densityRule` `.Dense` → `.Base` | 1, 2 |
| `priorUGap` `.Dedekind` → `.Discrete` | 1, 2, 3 |
| `.Base` rule `untlNeg` grounded in `Axiom.prior_U_gap` | 1 |
| `ruleAxioms .sepRule` emptied | 3 |
| `serialityRule` exclusion clause deleted | 2 |

The last row is the one the plan revision predicted, and it confirms the clause is load-bearing
rather than cosmetic.

## Verification

`lake build` and `lake build BimodalTest` both green. The conformance corpus was re-executed
under a *forced* rebuild rather than replayed from cache (59.2 s, matching the 2.7 baseline) with
zero `#guard_msgs` movement — verdict-neutral, as it must be: `TableauConformance.lean` imports
`Saturation` and `Tableau` directly, neither of which this phase touched. Zero new sorries, zero
new axioms, zero new vacuous definitions; the single live-tree sorry remains the pre-existing
`WeakCanonical/Transfer.lean:1242`.

## Deviations

None. Both planned gates landed as specified, at the corrected constructor count of 36 and with
the exclusion clause the revision required. The three items above are additions and a widened
clause, not skipped or substituted steps; all are recorded in the plan's Phase 3 completion note
and in `.orchestrator-handoff.json`.
