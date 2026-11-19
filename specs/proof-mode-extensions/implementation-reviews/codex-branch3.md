# Codex review: integrated pointed semantics

Written before reading Opus's independent branch-3 review. Scope is P4/P5, stacked on
`1f545ea`; this is source review, with validation tracked separately.

| Criterion | Score / 10 |
| --- | ---: |
| Correctness/source grounding (30%) | 9.0 |
| Compositionality (25%) | 9.0 |
| Reuse (20%) | 8.7 |
| Predictable bounded automation (15%) | 8.2 |
| Clarity/validation economy (10%) | 8.0 |

Weighted grade: **87.2/100**. Provisional GO after integration checks and independent findings
are resolved. A grade does not excuse a defect or establish that a check ran.

## Required integration fixes applied

- Metadata around truth goals is stripped before head recognition. Native and semantic handlers
  dispatch by the typed head; semantic handlers use `no_fallback` and restore state on failure.
- Nominal point comparison is shared in `SemanticMeta`, independent of rewriting. The frontend
  validates language/dictionary/frame/model/history/time/environment before formula reduction.
  Exact local side-premise matching preserves indices beneath quantifiers and logical binders.
  The shared equality planner accepts this resolver explicitly, so semantic equality premises
  use the same indexed discipline as logical rewrites.
- Pure explicit-index temporal wrappers moved out of the frontend into a clause-only layer-1
  module. The soundness seam remains in Metalogic; lower kernels cannot reach native derivations.
- Generic semantic application captures only new holes, leaves data inferable and schedules it
  after premises. Rule routes attach to the actual integrated branch-2 syntax, including keeping.
- Semantic rewriting replays the same positions through a separate Prop-valued kernel. It checks
  live proof holes and discards only its own unused term-elaboration jobs when exposing a demand.
  Typed Point parameters match the demanded point by their evaluation projections, not a search
  through local data. Missing point evidence cannot be repaired by introducing a leaf implication.

## Source audit

`Step.comp` combines polarity with xor, nests demands outermost first and lifts the inner
transfer through the outer demand. Its four sign cases are actual Lean proofs. Frontend fact
and goal roles use different reconstruction directions; equivalence projection/reversal is
pointwise beneath the entire quantified family. Current-point equivalence is never promoted.
Until/Since transfers use the conservative G/H range, not endpoint guards.

Next/Previous is strict Until/Since with bottom guard. Its covering-time theorem and cover
uniqueness eliminate only an existing cover; no successor or ZTime certificate is fabricated.
Inclusive U/S interval theorems preserve present-time guards separately from strict intervals.
The generic rank rule retains occurrence, invariant, well-foundedness and an inclusive endpoint;
its strict version additionally excludes the goal now.

FactTransport, GoalTransport and IffTransport retain both languages, frames, models and points.
Existing correspondence/shift/reversal/locality/history-morphism theorems supply factories with
their real hypotheses. Forward preservation is not inverted. Reflection changes the model and
history to their converses and time to its negative; a same-model reading requires a certificate.

Soundness consumes actual native data, `fc.Sat F` and truth of every member of abstract Γ at
the selected point. The canonical dictionary restriction is explicit. There is no semantic-to-native
route and no completeness-based extraction. Opaque provider proofs are consumed through types.

## Deliberate limits and remaining checks

Native U/S fold/introduction/unfold is P3. Semantic U/S uses direct witnesses/cases and supplied
proved rules; generic semantic durations get no automatic discrete unfolding or induction.
Arithmetic stays ordinary Lean. Counterfactuals, metric syntax and Veil remain outside scope.
The simplifier uses explicit rules, fixed orientation, concrete decrease and finite budgets;
no change fails and exhaustion rolls back. It does not search for component contracts.

The shared suite adds mechanism examples rather than a language/operator cross-product. Required
remaining evidence: actual generic-Point replay, final library/original+extension builds with
`--wfail`, linter, layer/import/README/inventory gates, book synchronization, representative axiom
checks, independent Opus review and a requirement-by-requirement final audit.
