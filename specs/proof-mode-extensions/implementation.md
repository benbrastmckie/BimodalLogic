# Implementation record

User goal: implement P0–P5 end to end, with Codex and Claude Opus 5.5 reviewing and grading,
split across three implementation branches. The [plan](plan.md) fixes the full scope.

The [source inventory](source-inventory.md) records closed versus contextual sources,
scope conversions, frame restrictions and layer placement.

## Branches

| Branch | Milestones | Status |
| --- | --- | --- |
| `feat/proof-mode-rewriting` | P0 prototypes, P1 native congruence, P2 rewriting/simplification | Complete; reviewed and checked |
| `feat/proof-mode-temporal` | P3 temporal rules, reflection, progress and persistent scope capture | Complete; reviewed and checked |
| `feat/proof-mode-semantics` | P4 clauses/soundness, P5 transport, semantic rewriting and progress | Complete; reviewed and checked |

Each branch must include executable examples, applicable repository gates, an independent
Codex review, an Opus review and grades under the design rubric. A reported grade does not
override a defect. Required findings must be fixed before that branch is considered complete.

## Completion ledger

- [x] P0: closed transfer inventory; four polarity combinations; arbitrary Plus substitution;
  Base conditional Next; Base Since fold; pointed soundness prototype.
- [x] P1: language-parametric signed path kernel; primitive/derived views; native TM/Plus
  adapters; exact/closed/finite scope discharge; checked declaration names and rule validation.
- [x] P2: goal/fact/equality rewrites, explicit paths/ambiguity; stable Γ; evidence exposure;
  bounded deterministic `lsimp only`; actual decrease; frame skipping; atomic failure/rollback;
  diagnostics and opaque provider reuse.
- [x] P3: strict U/S fold/cases/introduction; exact duals/inclusive translation; Base/ZTime gates;
  contextual reflection; generic rule application; consequence/case progress; `keeping` capture;
  documented Plus derived-view choice and compatibility.
- [x] P4: generic individual-clause helpers, covering-time Next/Previous; pointed semantic
  logical/modal/temporal tactics; explicit soundness with abstract Γ; strict indices and scopes;
  semantic mixed-path rewrite prototype and frontend.
- [x] P5: typed fact/goal transport and existing correspondence routes; persistence across
  repeated advances; well-founded rank progress with occurrence premises; semantic witnesses,
  native/semantic opaque-provider composition examples and refusal cases.
- [x] Integration: compact mechanism suite, source/axiom audit, README/import/inventory/count
  updates, required checks, two independent reviews per branch and final requirement audit.

## Validation policy

Build changed modules and their compact integration examples as needed. Reuse the pinned Lean
and Mathlib RAM cache. Run broader checks at branch boundaries, then the final integration
build/count generation once when source work is stable. Record failures and substantive fixes;
do not rerun unchanged passing checks without a reason.

## Evidence so far

- Opus implemented `Congruence.lean`; its targeted build and disposable signed/Plus/conditional
  Next probes passed. Codex reviewed the construction and wired it into the common frontend.
- Native rewriting, schema registration and bounded simplification compile. The shared
  extension suite covers scoped facts/goals, negative positions, mixed Plus scopes, scope
  refusal/exposure, formula equality, concrete frame gates, strict decrease and rollback.
- The original proof-mode acceptance module still compiles after replacing dynamic primitive
  name assembly with checked source declarations.
- The abstract-context pointed soundness prototype compiles in the shared extension module.
- P3 pure rules and frontend are integrated: Base Since fold, integer-time unfold, contextual
  reflection, progress consequence/cases, exact dual/inclusive views and persistent capture.
  Its [two reviews and closeout](implementation-reviews/branch2-closeout.md) record the lapply
  inference regression, fixes and passing source/build/linter/book checks.
- Generated module-root and README inventories have been refreshed. Final counts, repository
  gates and branch-1 review closeout are recorded in the
  [branch closeout](implementation-reviews/branch1-closeout.md). The full P0–P5 audit remains
  complete; branch-2 and branch-3 closeouts record the final implementation and checks.

- Branch 3 adds the indexed semantic backend, clause/cover witnesses, dual views, bounded
  rewriting/simplification, typed transports and occurrence-based rank progress. Both reviews
  are closed; the final library/test, linter, full invariant, README, book and axiom checks pass.

The [completion audit](completion-audit.md) maps P0–P5 to the actual modules and boundaries.

Last updated: 2026-11-19.
