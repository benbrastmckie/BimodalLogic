# Implementation Summary: Task #677

- **Task**: 677 - Proof-Producing check_certificate
- **Status**: [COMPLETED]
- **Started**: 2026-09-27T18:16:53Z
- **Completed**: 2026-09-27T20:35:00Z
- **Effort**: ~2.3 hours
- **Dependencies**: None
- **Artifacts**: plans/01_proof-producing-check-certificate.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

`lake exe check_certificate`'s accepting branch is now the composition of the four decided
certificate conditions with `WitnessFamily.joint_countermodel`, rather than a status line printed
beside it. The library gained the bundled condition `Certifies`, its `Decidable` instance, the
named joint statement `Refutes`, and the implication `refutes_of_certifies`; the executable's
library half gained a dependent verdict type whose accepting constructor *carries* a
`WitnessFamily.Refutes …`, so that branch cannot be written without one. The output line carries
the distinction additively as `"acceptance":"entailment"`, and the four in-repo sites that said
acceptance "is not a kernel-checked proof" now state the correct, bounded guarantee instead.

## What Changed

- `FormalSystem/Metalogic/Decidability/WitnessFamily/Predicates.lean` — added
  `WitnessFamily.Certifies W t`, the four conditions bundled at a target time in the order the
  four instances are evaluated in.
- `FormalSystem/Metalogic/Decidability/WitnessFamily/Decide.lean` — added
  `WitnessFamily.decidableCertifies`, composing the four landed instances through
  `instDecidableAnd`.
- `FormalSystem/Metalogic/Decidability/WitnessFamily/Agreement.lean` — added
  `WitnessFamily.Refutes Γ Δ` (`joint_countermodel`'s conclusion, named once, with explicit
  binders) and `WitnessFamily.refutes_of_certifies` (term-mode, from `joint_countermodel`), plus
  module-header prose. `joint_countermodel`'s own statement is untouched, and `Examples.lean`'s two
  call sites compile unchanged.
- `BimodalTools/CertificateImport.lean` — added `Acceptance`, `CheckOutcome raw` (accepting
  constructor carries `entails : WitnessFamily.Refutes …`, derives nothing), `checkCertified`
  (nested `dite` on the four conditions, same order and short-circuit as before), and
  `CheckOutcome.erase`; redefined `checkRaw := (checkCertified raw).erase`; widened
  `CheckResult.countermodel` with an `Acceptance` field and `CheckResult.toJson`'s accepting case
  with the `"acceptance"` key; added `refutes_of_countermodel`; corrected the module-header
  trust-model section and the `checkRaw` doc comment.
- `BimodalTools/CheckCertificateMain.lean` — corrected the "The trust model" section. It
  pattern-matches no `CheckResult` constructor, so no code change was needed there.
- `Tests/BimodalToolsTest/CertificateImportTest.lean` — the two `CheckResult.countermodel 0` rows
  became `CheckResult.countermodel 0 .entailment`; added a row pinning the exact accepting JSON
  line (via `posAcceptedLine`, split across two literals for the 100-column limit).
- `BimodalTools/README.md` — extended the certificate protocol's output section with the
  `acceptance` key, its two values, and the absent-field-means-`"decided"` rule; rewrote "What
  acceptance means"; recorded the jointly-gated payoff note.
- `FormalSystem/Metalogic/Decidability/WitnessFamily/README.md`,
  `FormalSystem/Metalogic/Decidability/README.md` — inventory rows naming the new declarations.
- `FormalSystem/Metalogic/README.md`, `Tests/BimodalToolsTest/README.md` — generated inventory
  blocks regenerated for the changed line counts.

### Theorems and definitions landed

| Declaration | Home | Axioms |
|---|---|---|
| `WitnessFamily.Certifies` | `Predicates.lean` | — (definition) |
| `WitnessFamily.decidableCertifies` | `Decide.lean` | `[propext, Classical.choice, Quot.sound]` |
| `WitnessFamily.Refutes` | `Agreement.lean` | — (definition) |
| `WitnessFamily.refutes_of_certifies` | `Agreement.lean` | `[propext, Classical.choice, Quot.sound]` |
| `BimodalTools.CertificateImport.refutes_of_countermodel` | `CertificateImport.lean` | `[propext, Classical.choice, Quot.sound]` |
| `BimodalTools.CertificateImport.checkCertified` | `CertificateImport.lean` | `[propext, Classical.choice, Quot.sound]` |
| `BimodalTools.CertificateImport.CheckOutcome.erase` | `CertificateImport.lean` | `[propext]` |
| `BimodalTools.CertificateImport.checkRaw` | `CertificateImport.lean` | `[propext, Classical.choice, Quot.sound]` |

No `sorryAx`, no `Lean.ofReduceBool`, no `native_decide`, no new `axiom` declaration.

## Decisions

- **The correct claim is level 2, and the prose says so.** What landed is a *build-time*
  kernel-checked implication whose per-certificate hypothesis is supplied by compiled `Decidable`
  instances. It is not per-certificate kernel checking, and every corrected disclaimer site names
  the residual trust base (Lean's compiler plus this module's decoding) rather than deleting the
  caveat. This adopts the research report's correction of the task description's opening framing.
- **`Acceptance.toJson` renders the carried value** rather than hard-coding `"entailment"`. The
  accepting path always carries `.entailment`, so the specified line is produced byte for byte;
  hard-coding would have left the enum's second value unrenderable.
- **The behaviour-preservation guard is the pre-existing test corpus**, not a new temporary
  `#guard`. `Tests/BimodalToolsTest/CertificateImportTest.lean` already pins the exact
  `CheckResult` value for the accepting fixture, for every rejection fixture with its localization
  tuple, for the error rows and for the wire round-trips — strictly stronger than a
  `checkRaw' = checkRaw` equality against a second copy of the same code.
- **Whole-repo generated inventory blocks were left to their owners.** `README.md` and
  `FormalSystem/README.md` carry repo-wide totals that were already modified in the working tree by
  concurrent sibling dispatches; regenerating and staging them would have swept sibling-derived
  numbers into this task's commits. Only the three generated blocks whose delta is attributable to
  this task were staged.

## Plan Deviations

- **Phase 2** altered: the research probe's five separate `split`s became one `split at h` on the
  `mkFamily` match plus `split_ifs at h with h1 h2 h3 h4` on the `if` chain, with the
  `simp only [Bool.not_eq_true', decide_eq_false_iff_not, not_not]` premise content discharged by
  `simpa` inside each `of_decide_eq_true`. Same tactic family, same premises, fewer lines; the
  statement is unchanged.
- **Phase 4** altered: `CheckResult.toJson`'s accepting case renders the constructor's carried
  `Acceptance` through a new `Acceptance.toJson` instead of hard-coding the string. Output is
  byte-identical to the specified line.
- **Phase 4**, `CheckCertificateMain.lean`: re-read as the plan required and found to contain no
  `CheckResult` or `countermodel` occurrence, so no code change was needed (its prose is Phase 5's).
- Both `Refutes` and `refutes_of_countermodel` match their `## Lean Challenge Statements`
  signatures, with the one widening the plan itself anticipated: `refutes_of_countermodel` gained
  an `{a : Acceptance}` binder in Phase 4 when `CheckResult.countermodel` gained its second field.

## Verification

- **Build**: Success. Full `lake build` green — guard exit 0, `Build completed successfully (2741
  jobs)`, zero `error:` across captured stdout and stderr, and `.olean`-newer-than-source confirmed
  for all six touched modules (`CheckCertificateMain` needed its own scoped build, since the
  executable root is not in the default target; it is green).
- `lake build BimodalTools --wfail` and `lake build BimodalToolsTest.CertificateImportTest
  --wfail`: green.
- **Sorry count**: 0 (`lean-sorry-census.sh` over all eight resolved source roots).
- **Vacuous count**: 1 repo-wide, pre-existing and not this task's —
  `FormalSystem/Examples/TemporalStructures.lean:495`'s `int_domain_universal … := trivial`, where
  the goal really is trivially true by the definition of `intTimeHistory.domain`. Zero introduced
  by this task.
- **Axiom count**: unchanged (15 `axiom` declarations repo-wide; none added by this task's five
  commits — verified per commit).
- **Tests**: `BimodalToolsTest.CertificateImportTest` built green with `--wfail`, every pre-existing
  `#guard` row passing unchanged plus the new pinned-JSON row.
- **End-to-end**, the real binary against wire input:
  - accepting fixture: `{"status":"countermodel","time":0,"acceptance":"entailment"}`
  - rejecting fixture: `{"status":"rejected","failed":[{"condition":"fulfilling","lasso":0,"position":-2,…}]}`
    — the same localization tuple as before the restructure
  - malformed input: `{"status":"error","message":"expected '\"' got 'n' at pos 2"}` — byte-identical
- `lake exe mk_all --lib FormalSystem --check`: green ("No update necessary").
- `bash scripts/check-copyright-headers.sh --strict FormalSystem BimodalTools`: green.
- `bash scripts/readme-lint.sh FormalSystem BimodalTools`: PASS.
- `bash scripts/check-metalogic-cycles.sh`: green. `bash scripts/check-evidence-probes.sh`: green.
- `bash scripts/check-module-invariants.sh --no-build`: C20 and C20_DECL green (no citation drift
  from the added lines). Two check groups red for reasons outside this task — see below.
- **Files verified**: Yes.

### Gates red for reasons outside this task

These were verified not to be caused by this task's changes, and are recorded rather than
"fixed", since fixing them would mean editing files this task has no business editing.

| Gate | Finding | Why it is not this task's |
|---|---|---|
| `lake exe lint-style` | 9 trailing-whitespace errors in `FormalSystem/Semantics/Extension/Completion.lean`, `…/Extension.lean` and `FormalSystem/Semantics/StateTopology/ConstraintWitnesses.lean` | All three are unmodified HEAD content (`git status` clean for them); the last was last touched by an earlier task's commit |
| `check-module-invariants.sh` C28 | `BimodalTools/TranslateSentenceMain.lean` `linter.style.longLine` above the warning budget | A concurrent sibling dispatch's file, not in this task's scope |
| `check-module-invariants.sh` INV | `README.md` and `FormalSystem/README.md` generated blocks stale | Repo-wide totals under concurrent modification by sibling dispatches; deliberately not staged here (see Decisions) |
| `scripts/typst-sync-check.sh` | 6 count violations, e.g. `formalsystem-file-count: committed=537 live=575`, `formalsystem-line-count: committed=285608 live=303984` | Long-accumulated drift of ~38 files and ~18,000 lines; this task adds ~200 lines and edits no Typst source (an explicit plan Non-Goal) |
| `scripts/check-paper-definitions.sh` | 1 recorded definition drifted (`def:id`, a LaTeX paper definition) | No `.tex`, `.typ` or paper source was touched by this task |

## Impacts

- `WitnessFamily.Refutes` and `WitnessFamily.refutes_of_certifies` are now available to any module
  that wants the joint countermodel statement as a single named type — the shape a proof-carrying
  verdict needs. `joint_countermodel`'s signature is unchanged, so nothing downstream had to move.
- `CheckResult.countermodel` gained a second field. Every in-repo match site was the two `#guard`
  rows already noted; the change is source-breaking for any out-of-repo Lean consumer that matched
  the constructor, but the *wire* format is additive only.
- The certificate wire's **input** schema is untouched. The output gains one key on `countermodel`
  only; `rejected` and `error` lines are byte-identical.

## Follow-ups

### Consuming-repository hand-off (read-only findings; nothing in `~/Projects/ModelChecker` was edited)

1. Add `"acceptance": "decided"` to the countermodel verdicts produced by
   `tests/unit/_certificate_model.py` and by the `recheck` path. Emitting `"decided"` is correct
   for a re-checker that decides the four conditions without constructing anything.
2. In `tests/integration/test_certificate_lean_agreement.py`, keep the existing status comparison
   and add an assertion that Lean reports `acceptance == "entailment"` where Python reports
   `"decided"` — the asymmetry is the point, not a disagreement.
3. Update `A2_GAP.md` section 9 ("The honesty point") and section 10 route (f): the accepting
   branch now constructs the entailment, so the "not a kernel-checked proof for that particular
   certificate" sentence needs the level-2 replacement, not deletion.
4. Update `TRUST_PIPELINE.md`'s two "What remains" rows to record the half that has landed.
5. A consumer **must** read an absent `acceptance` field as `"decided"`. That rule is written into
   `BimodalTools/README.md`'s protocol section so the two repositories can land in either order.

### Follow-up task to file (scope recorded, deliberately not created here)

**Per-certificate kernel checking by generated-file re-elaboration.** This is what would make an
`Acceptance` value of `kernel` real. It is gated on a feasibility measurement first: kernel `whnf`
cost on a real fixture, since the four conditions' decision procedures are bounded window scans
whose kernel-reduction cost has never been measured. `native_decide` is explicitly *not* the route
— it moves the compiler into the trust base via `Lean.ofReduceBool`, a trust regression.

**The downstream payoff is jointly gated.** The consuming repository's pure-Python re-checker
becoming a fast pre-filter rather than part of the trust base needs both this change *and* a
Lean-side parse echo compared against the bytes actually sent, so that the decoding step named in
the residual trust base is pinned rather than trusted. That echo work is separate and has not
landed.

### Context-extension recommendations (for a later `/learn` or `/meta` pass)

1. **`context/project/lean4/patterns/proof-carrying-verdicts.md`** — the pattern of indexing a
   result type by its input and carrying the witness in the accepting constructor, versus stating a
   separate soundness theorem about an erased Boolean verdict. Should record why the `dite` form
   keeps the hypotheses in scope where an `if ! decide …` chain does not, and the level 1/2/3 trust
   framing. The distinction has now recurred three times in this codebase
   (`DecisionResult`/`sound_of_isValid`, and now `CheckOutcome`/`refutes_of_countermodel`) and was
   re-derived from scratch each time.
2. **The `decide` / `by decide` / `native_decide` / re-elaboration trust ladder** — extend
   `context/project/lean4/tools/comparator-guide.md`, or add a sibling file, with the four rungs and
   the explicit note that `native_decide` is a trust regression rather than a strengthening. This
   task turned entirely on that ladder and the guide covers only the Comparator's own trust model.

## References

- `specs/677_proof_producing_check_certificate/plans/01_proof-producing-check-certificate.md`
- `specs/677_proof_producing_check_certificate/reports/01_proof-producing-check-certificate.md`
- `specs/677_proof_producing_check_certificate/handoffs/` — per-phase handoffs
- `BimodalTools/README.md` — the certificate re-verification protocol, including the new key
