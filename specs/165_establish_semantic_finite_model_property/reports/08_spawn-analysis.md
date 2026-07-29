# Blocker Analysis: Task #165

**Parent Task**: #165 - establish_semantic_finite_model_property (tableau decidability)
**Generated**: 2026-07-29
**Blocker**: The tableau engine (`applyRule` in `Tableau.lean`) is unsound: six group-3 blocks in
`boxNeg` and `diamondPos` copy temporal formulas verbatim across worlds, which is invalid for
`□`/`◇` (a world quantifier fixing time, not a history quantifier). This closes `(G p) → □(G p)`
— a measured-invalid formula — with verdict `.allClosed`, blocking Phase 7.2's `RuleSound`
assembly for `boxNeg`/`diamondPos` at 16 of 28 rules.

## Root Cause

**Category**: Missing prerequisite (an engine correctness fix that must land before the semantic
soundness proof can be stated truthfully) combined with a scope-boundary issue (the fix requires
editing a `.lean` engine file mid-plan, which `plan-compliance.md` requires be escalated rather
than silently substituted inside the existing implementation dispatch for task 165).

**Mechanism.** `TruthAt (□φ)` at time `t` quantifies over admissible histories `σ ∈ Ω` at the
*same* `t`; `TruthAt` of `G p` is evaluated along a *single* history's future. The six group-3
blocks — `tempGProps`, `tempHProps`, `tempFNegProps`, `tempPNegProps`, `tempUNegProps`,
`tempSNegProps` at `Tableau.lean:555-574` (`boxNeg`) and `:599-619` (`diamondPos`) — copy every
temporal-universal/existential signed formula holding at `l.time` on the current branch into the
freshly minted `□`/`◇`-witness world verbatim. This conflates "true along the history I am
building" with "true along every admissible history at this instant", which is exactly what
`□`/`◇` must NOT assume.

**Measured evidence** (pinned, not hypothesized):
- `buildTableau ((G p) → □(G p)) 1000 .Base = .allClosed`, one closed branch, closure reason
  `contradiction` at the minted world `(w1,t0)` where the `tempGProps` copy of `T(G p)` meets the
  witness `F(G p)`.
- `decide` on this formula returns `.extractionFailed`; `isInvalid = false`;
  `getCountermodel? = none`. `isValid` reports `false`, which reads as "closed, but no valid-proof
  term could be extracted" — NOT as "correctly recognized as invalid". The engine has no path
  that reports this formula as invalid.
- Required behavior: `.hasOpen`, hence `decide = .invalid` with an extracted countermodel.
- Pinned in `Tests/BimodalTest/BoxNegReachabilityProbe.lean` (twelve `#guard_msgs` rows) and
  `Tests/BimodalTest/BoxNegPreservationProbe.lean` (satisfiability-preservation refutation).
- Isolation: Groups 1 and 2 of both rules — the existential witness, and the sound
  `T(□B)`/`F(◇B)` propagation to the fresh world — are NOT implicated. Only the six group-3
  blocks are unsound.

**Why this could not be fixed in place inside the prior dispatch.** The task 165 plan is a
`.lean`-file plan under `plan-compliance.md`'s strict-sequence rule: a step that cannot be
executed as written (Phase 7.2's assembly target, `∀ r ∈ allRulesForFC fc, RuleSound _ r`, is
FALSE as written because the refuting branch is one the engine itself builds) must be escalated,
not silently substituted. Editing `applyRule` is also outside Phase 7.2's declared scope (a new
`Verified/Decidable.lean` soundness-proof file) and is risk-asymmetric: removing the six blocks
can only make branches *harder* to close (deleting formulas from a branch only shrinks its
contradiction surface), so the introduced failure mode is *under-closing* — silently missing
genuine closures — which only a full-corpus regression pass, not spot-checking the one refuting
formula, can detect.

**Concurrency hazard specific to this fix.** Three concurrent sessions (tasks 408, 414, 415)
share this git clone and have destroyed full-build attempts before by deleting `.olean` files out
from under an in-progress `lake build`. The acceptance gate for this fix is a FULL project rebuild
plus the full conformance corpus, which is exactly the kind of long-running build this hazard can
corrupt mid-run — so the spawned task must plan explicitly for build reliability (see task
description below), not merely assume a clean, exclusive build environment.

## Proposed New Tasks

### New Task 1: Fix tableau engine cross-world temporal-copy unsoundness in boxNeg/diamondPos
- **Effort**: 4-8 hours
- **Task Type**: lean4
- **Topic**: completeness (inherited)
- **Rationale**: This is the sole defect blocking Phase 7.2 of task 165. It is scoped as its own
  task rather than folded into task 165 because it requires editing the tableau engine file
  itself (`Tableau.lean`), a deviation from task 165's Phase 7.2 plan scope
  (`Verified/Decidable.lean`, a soundness-*proof* file, not the engine) that `plan-compliance.md`
  requires be escalated out rather than silently substituted in-place.
- **Description**: Remove the six unsound group-3 blocks — `tempGProps`, `tempHProps`,
  `tempFNegProps`, `tempPNegProps`, `tempUNegProps`, `tempSNegProps` — from both `boxNeg`
  (`FormalSystem/Metalogic/Decidability/Tableau.lean:555-574`) and `diamondPos` (same file,
  `:599-619`). Groups 1 (existential witness) and 2 (`T(□B)`/`F(◇B)` propagation) in both rules
  are sound and MUST NOT be touched. After the edit, `temporalProps` in each rule reduces to the
  empty concatenation (or is deleted along with its assembly line), and each rule's `.linear`
  list becomes `witness :: boxProps ++ diaProps`.

  Rebuild `Tableau.lean` and the full project (`lake build`), then run the FULL conformance
  corpus (`Tests/BimodalTest/TableauConformance.lean`, plus the two probes that pinned this
  defect, `BoxNegReachabilityProbe.lean` and `BoxNegPreservationProbe.lean`) as the acceptance
  gate. This is not a spot-check: because the removal is risk-asymmetric (branches can only get
  harder to close, never easier — i.e. the fix cannot introduce a new false-invalid verdict, only
  reveal previously-hidden false-valid ones or newly-uncloseable branches), the ONLY way to bound
  the fix's blast radius is to run the entire corpus before and after and record every verdict
  that changes, not just confirm `(G p) → □(G p)` now reads `.hasOpen`/`.invalid`. Produce a
  before/after table (formula, old verdict, new verdict) for every row whose verdict differs, as
  part of the task's summary artifact.

  Because three concurrent sessions (tasks 408, 414, 415) share this clone and have previously
  destroyed full-build attempts by deleting `.olean` files mid-build, this task's plan must
  include an explicit build-reliability strategy before attempting the full-project rebuild and
  corpus run that form its acceptance gate — e.g. checking for and honoring any existing
  build-coordination/lock convention in the repo, avoiding `lake clean` while a concurrent
  session may be mid-build, and treating a corpus run whose build step failed or was interrupted
  as inconclusive (retry) rather than as a passing gate. Do not silently treat an
  oleans-were-deleted failure as if the corpus had validated the fix.

  Do NOT touch `FormalSystem/Metalogic/Decidability/Verified/Decidable.lean` or attempt Phase
  7.2's `RuleSound` proof — that remains task 165's responsibility once this fix lands. This task
  ends at "engine sound, full corpus green (or every regression explicitly recorded and
  triaged), full build green."
- **Depends on**: None
- **file_scope**:
  - `FormalSystem/Metalogic/Decidability/Tableau.lean`
  - `Tests/BimodalTest/TableauConformance.lean`
  - `Tests/BimodalTest/BoxNegReachabilityProbe.lean`
  - `Tests/BimodalTest/BoxNegPreservationProbe.lean`

## Dependency Reasoning

Only one task is proposed. Task minimization applies directly: the blocker is a single, tightly
localized engine defect (six copy-paste blocks in two rules) with a single acceptance criterion
(full corpus green, every verdict delta recorded), and the build-reliability concern is an
operational precondition of that same task's own gate — not a separable deliverable with any
other consumer — so it is folded into this task's planning obligation rather than spawned as its
own task. There is no second task whose implementation choices depend on a decision made inside
this one; splitting further would not reduce coupling, only add hand-off overhead for a
single-session engine edit.

## After Completion

Once the spawned task is complete, resume the parent task #165 with `/implement 165`.

The blocker will be resolved because: with the six unsound group-3 blocks removed, `applyRule`
no longer asserts that a temporal-universal true along one history is true at the same instant
along every admissible history. `(G p) → □(G p)` will read `.hasOpen`/`.invalid` with an
extracted countermodel, the `RuleSound` obligation for `boxNeg`/`diamondPos` becomes provable
against the corrected `applyRule` definition (rather than false as currently written), and Phase
7.2's single induction over `allRulesForFC fc` can proceed past its current 16-of-28 stall to the
two remaining group-3-affected rules plus the rest of the family.
