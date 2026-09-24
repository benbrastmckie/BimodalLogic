# Implementation Plan: Hypothesis-honesty gate for `IsRegular` over-binding

- **Task**: 663 - Add a repo-wide hypothesis-honesty gate so no constraint-independence claim
  silently carries the bundling `IsRegular` class
- **Status**: [IMPLEMENTING]
- **Effort**: 11 hours
- **Dependencies**: Task "settle S1 vs directedness and restore Saturation" (landed; its Phase 3
  established the explicit-hypothesis-plus-corollary pattern this plan generalizes)
- **Research Inputs**:
  `specs/663_hypothesis_honesty_lint_isregular_overbinding/reports/01_hypothesis-honesty-lint-isregular.md`
- **Reports Integrated**: `reports/01_hypothesis-honesty-lint-isregular.md`
- **Artifacts**: plans/01_hypothesis-honesty-lint-isregular.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

A `[F.IsRegular]` instance binder silently supplies all four frame constraints (*Compositionality*,
*Seriality*, *Limit*, *Saturation*). Where a declaration's statement, name or docstring asserts
that a result holds *without* one of them, the binder makes the claim vacuous and the vacuity is
invisible at every call site. This plan does three things and nothing else: it restates the eight
declarations that make such a claim at the hypotheses their proofs actually consume (keeping each
original as a one-line corollary with an unchanged signature, so no call site moves); it
introduces a `Constraints consumed:` docstring line as the repository's marker for consumption
enumeration and documents it alongside the three normal forms already in
`docs/development/REFERENCE_NORMAL_FORM.md`; and it lands invariant **C34** in
`scripts/check-module-invariants.sh` — a build-free, textual check that gates the marked sites and
prints a per-run census, so the classification is re-runnable rather than a one-time human read.

Done means: `lake build` green, sorry-free, warning-free; C34 passing enforced; every one of the
eight fix sites restated and marked; every genuinely *Saturation*-consuming site marked rather than
changed; the convention documented in `REFERENCE_NORMAL_FORM.md` and the gate row present in
`MODULE_INVARIANTS.md`; and the Lean diff confined to
`FormalSystem/Semantics/Extension/` plus the gate and docs files.

### Research Integration

The report converts the task's premise from "225 over-bound sites need auditing" into a measured,
bounded work list. Five findings shape this plan's structure:

- **The independence-claiming residue is eight declarations, not hundreds.** Of the binder-carrying
  declarations, only a small minority mention *Saturation* at all, and only eight make an
  independence claim while carrying the class: seven in
  `FormalSystem/Semantics/Extension/Constraint.lean` and one in
  `FormalSystem/Semantics/Extension/Admissible.lean`. The flagship is `PartialHistory.constraint`,
  whose docstring says in bold that *Saturation* is **not** consumed over an `[F.IsRegular]`
  binder. This is what bounds the Lean work to two files.
- **The marker must be a consumption enumeration, not an independence assertion.** A
  `Constraints consumed: ...` line over the closed vocabulary
  `{Compositionality, Seriality, Limit, Saturation}` subsumes the independence claim (an unlisted
  constraint is claimed unconsumed) and, unlike a bare "independent of X" marker, also fits the
  sites that legitimately *do* consume *Saturation* — so the audit record covers them instead of
  ignoring them. It also sidesteps a real name collision: `FormalSystem/Metalogic/Independence/`
  means *logical* independence of proof-system axioms, an unrelated notion.
- **Consumption and elimination are different relations and the tree already uses both words
  precisely.** `isTotal_of_isMax`'s docstring saying "this is not a second *Saturation* elimination
  site" is not an independence claim. The marker enumerates **consumption** — what the elaborated
  proof term reaches — which is what `constraint`'s corrected docstring already does.
- **Prose pattern-matching can be the gate's trigger, never its verdict.** A hand-tuned
  independence regex over the binder-carrying declarations returns a handful of hits, most of them
  false positives, and misses the flagship. Widened to "docstring mentions *Saturation*" it catches
  the real defects inside a small superset. That ratio is fine for forcing a marker and useless for
  rendering a judgment — hence C34's split into a gated structural half (C34a) and a gated
  trigger half (C34b) that only ever demands a marker line.
- **The fix pattern is verified by elaboration, not assumed.** A scratch file restating
  `nonempty_fib_of_serial` at `(hser, hlim)` and `nonempty_seg_of_interpolates` at `(hcomp, hlim)`,
  with a one-line corollary at the original signature, elaborated with zero errors under
  `lake env lean`. `TaskFrame.forward_of_comp`, `TaskFrame.interpolates_of_comp`,
  `FrameOver.reflection_of_limit` and `TaskFrame.nullity_of_serial_limit` are the four projections
  that carry the whole set. No phase needs a `sorry`, a new axiom, or a deferral.

### Prior Plan Reference

No prior plan for this task. The prerequisite task's plan and summary were read as pattern
evidence, not as a template: its Phase 3 produced the three matched
`_of_compositional`/corollary pairs in `Constraint.lean` that this plan generalizes, and its
recorded effort for a comparable restatement-plus-corollary batch informs the 1.5h-per-Lean-phase
estimates here.

### Roadmap Alignment

`specs/ROADMAP.md` was not supplied in this dispatch's context and no roadmap phases are included.

## Goals & Non-Goals

**Goals**:

- **Make every constraint-independence claim in the tree honest at the level of its binder.** The
  eight declarations that assert independence from a constraint while carrying `[F.IsRegular]` are
  restated at the hypotheses their proofs actually consume, so the claim is machine-checked rather
  than asserted in prose over a binder that contradicts it.
- **Change no call site.** Each original declaration survives with its statement, implicit-argument
  order and name unchanged, demoted to a one-line corollary at `F.comp` / `F.serial` / `F.limit`.
  The diff must touch no file outside `FormalSystem/Semantics/Extension/` plus the gate and docs
  files.
- **Give the repository a marker convention for constraint consumption** — a `Constraints
  consumed:` docstring line over a closed vocabulary — documented as a fourth normal form in
  `docs/development/REFERENCE_NORMAL_FORM.md` alongside the bibliographic, paper-anchor and
  module-cross-reference forms it joins.
- **Mark, rather than change, the sites that genuinely consume *Saturation*.** `step`,
  `isTotal_of_isMax`, `extension`, `isRestriction_of_isRegular`, `completion_of_isRegular` and
  `static_of_countable` are correct as they stand; marking them is what makes the audit record
  cover the whole population instead of only its defects.
- **Land a mechanical, build-free gate (C34) beside the existing repo lints**, with a gated
  structural assertion, a gated trigger assertion that stops a new unmarked claim slipping past an
  opt-in marker, an ungated per-run census that is the re-runnable classification record, and an
  anti-silence guard that treats a zero-marker or empty-walk result as a broken matcher rather than
  a clean tree.
- **Keep the classification at the site, not in a central manifest.** C29's recorded rationale — a
  reason in a central file goes stale silently when the code it covers moves, whereas a reason at
  the site moves with it — is the direct precedent, and a manifest of every binder row is exactly
  the artifact nothing would keep current.
- **Keep the tree green, sorry-free and warning-free at every phase boundary**, with the full gate
  set passing at task close.
- Declarations pinned by `## Lean Challenge Statements`:
  `PartialHistory.fib_zero_subset_of_compositional_limit`,
  `PartialHistory.fib_zero_subset_mem_of_compositional_limit`,
  `PartialHistory.nonempty_fib_of_serial_limit`,
  `PartialHistory.nonempty_seg_of_compositional_limit`,
  `PartialHistory.nonempty_of_mem_Constraints_of_compositional_serial_limit`,
  `PartialHistory.exists_mem_subset_inter_of_compositional_limit`,
  `PartialHistory.constraint_of_compositional_serial_limit`,
  `PartialHistory.admissible_of_serial_limit`.

**Non-Goals**:

- **Changing `IsRegular`'s fields.** Out of scope by the task description; the class keeps `comp`,
  `serial`, `limit`, `saturation` exactly as they are.
- **Blanket unbundling.** For ordinary soundness, validity and transfer theorems `[F.IsRegular]` is
  the correct ambient hypothesis. Stripping it would be churn with no gain, and the report measured
  the legitimately-ambient population as the overwhelming majority. The defect is the conjunction
  of an independence claim with the bundling class, never the class alone.
- **A second bundling class.** `IsRegular` is the only class of this kind in the tree today; C34's
  implementation is table-driven over `(class, field-vocabulary)` pairs so a second one costs a
  table row, but no second row is added here.
- **A Lean attribute (`@[hypothesis_honest]`) instead of a docstring line.** An attribute would need
  registering in `FormalSystem/Tactic/Attr.lean` and an environment-reading executable to query,
  putting the gate in CI's not-in-CI bucket alongside C2/C6/C24. Build-free is decisive: CI runs the
  harness `--no-build`.
- **Retrofitting markers onto declarations that make no claim.** Only the fix set and the genuine
  *Saturation* consumers are marked in this task; a `Constraints consumed:` line on an ordinary
  ambient theorem is permitted by the convention but not required by it, and none is added here.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| The report's own counts (occurrences, files, line numbers) drift before implementation, exactly as the task description's 225/43 baseline did | M | H | Phase 1 RE-MEASURES and records the census in the gate itself rather than in prose; no phase quotes a figure from the report or this plan as a fixed acceptance value. Already observed once during planning: the occurrence count moved between the report and this plan |
| Over-correction into a blanket unbundling | H | M | The fix set is pinned at eight declarations in two files. Phases 3-5 fail if the Lean diff reaches a third file under `FormalSystem/Semantics/`; verified by `git diff --stat` at each phase boundary |
| A restatement changes an implicit-argument order and silently moves call sites | H | L | Corollary-with-unchanged-signature rule: each original keeps its exact binder list and implicit-argument order, its body becoming a one-line application. Verified by `lake build` exit 0 with zero new warnings plus a diff confined to the two Extension files |
| C34b false positives on legitimately ambient binders whose docstrings mention *Saturation* in passing | M | M | Land C34b with `ENFORCE_C34=0`, read the printed list, then flip to enforced — the soft-then-enforced ladder C24 and C9D already use. A false positive costs one marker line, never a redesign, because the heuristic only forces marking and never renders a verdict |
| Marker drift: a docstring edit moves the `Constraints consumed:` line away from its declaration | M | L | The gate reads the span through `scripts/lib/lean_citations.py::decl_spans`, the same machinery whose drift detection was built after 327 citations were found mis-anchored; it walks back past `@[...]` attribute lines into the `/--` block |
| The gate's own explanatory prose self-fails C34a (a docstring saying "never the `IsRegular` instance" on a *Saturation*-free declaration) | M | M | C34a scans the declaration's text from its KEYWORD LINE to the end of its span with comments masked, so docstring prose is excluded by construction; scanning to end-of-span rather than to `:=` also catches an in-proof `haveI : F.IsRegular` |
| The bracketed-binder regex catches declarations that *conclude* `IsRegular` rather than assume it | M | M | The report measured a large population of `IsRegular`-concluding instances and constructions. C34's matcher is bracketed-binder-only and its fixture self-test includes a concluding declaration as a must-not-match case |
| A zero-marker or empty-walk result reads as a clean tree | H | L | Anti-silence guard exiting 2, not suppressed by `ENFORCE_C34=0`, matching C29/C30/C31 |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2 | -- |
| 2 | 3, 5 | 2 |
| 3 | 4 | 3 |
| 4 | 6 | 1, 3, 4, 5 |
| 5 | 7 | 6 |

Phases within the same wave can execute in parallel. Wave 2's two phases are territory-disjoint:
Phase 3 owns `FormalSystem/Semantics/Extension/Constraint.lean`, Phase 5 owns
`FormalSystem/Semantics/Extension/Admissible.lean` plus the four marker-only files.

---

### Phase 1: Re-measure the population and land the C34 census reporter [COMPLETED]

**Goal**: Replace every inherited count with a freshly measured one, and make the measurement
re-runnable by landing it as the ungated census half of C34 rather than as prose in an artifact.

**Tasks**:
- [x] Re-measure the binder population from the current tree: total bracketed `IsRegular`
      occurrences and the file count, via
      `grep -rnE '\[[^]]*IsRegular[^]]*\]' --include=*.lean FormalSystem/ Tests/`. Record what the
      tree says today; do NOT reconcile against the report's or this plan's figures.
      *(measured: 259 occurrences across 47 files; led by `Semantics/TaskFrame.lean` 47,
      `Frames/TranslationProduct.lean` 24, `Semantics/IntTransfer.lean` 14,
      `Extension/Constraint.lean` 14, `Semantics/Validity.lean` 11, `PlusLanguage/PlusPasting.lean` 11.
      C34's declaration-level census reads 212 binder-carrying declarations in 46 files — the raw
      grep counts `variable`-block binders and multiple binders per declaration too.)*
- [x] Re-locate `class IsRegular` and confirm its four fields are still `comp`, `serial`, `limit`,
      `saturation`. If a field has changed, STOP and report — the marker vocabulary is derived from
      this list. *(confirmed: `FormalSystem/Semantics/TaskFrame.lean:1170`, all four fields
      unchanged; the line has drifted from the description's 1044.)*
- [x] Re-confirm the eight fix sites exist at the names pinned in `## Lean Challenge Statements`
      below (`fib_zero_subset`, `fib_zero_subset_of_mem_Constraints`, `nonempty_fib_of_serial`,
      `nonempty_seg_of_interpolates`, `nonempty_of_mem_Constraints`, `exists_mem_subset_inter`,
      `constraint` in `Constraint.lean`; `admissible` in `Admissible.lean`) and still carry
      `[F.IsRegular]`. Record any that have moved or already been fixed.
      *(all eight confirmed present and still binder-carrying: `Constraint.lean` 250, 301, 332,
      350, 365, 409, 528; `Admissible.lean` 301. None already fixed; fix set neither grew nor
      shrank.)*
- [x] Confirm the highest allocated invariant number in `scripts/check-module-invariants.sh` is
      still C33, so C34 is the correct next allocation. If a higher one exists, take the next free
      number and use it consistently everywhere below.
- [x] Add the C34 block to `scripts/check-module-invariants.sh`, CENSUS PORTION ONLY: a table-driven
      `(class, field-vocabulary)` header (one row: `IsRegular` ->
      `{Compositionality, Seriality, Limit, Saturation}`), the walk via
      `scripts/lib/live_walk.py::live_files`, declaration spans via
      `scripts/lib/lean_citations.py::decl_spans`, and comment masking via
      `scripts/lib/lean_debug_artifacts.py::mask` / `comments_only`.
- [x] Print the census at every run, never gated: total bracketed-binder sites; sites carrying a
      `Constraints consumed:` marker; marked-and-*Saturation*-free sites; unmarked binder sites.
- [x] Add the anti-silence guard (exit 2, NOT suppressed by `ENFORCE_C34=0`): an empty walk, or zero
      declaration spans recovered, is a broken matcher and fails loudly. Zero markers is expected at
      this phase and must NOT trip the guard yet — guard on walk and span recovery only.
      *(deviation: altered — a third condition was added, zero bracketed binder sites recovered.
      It is the same broken-matcher signal as the two the plan names and is disjoint from the
      zero-marker case the plan carves out; all three exit-2 paths were exercised.)*
- [x] Add a fixture self-test alongside the existing per-check self-tests, with at minimum: a
      bracketed-binder declaration (must match), a declaration whose CONCLUSION mentions `IsRegular`
      (must not match), and a `variable` block binder (must not be counted as a declaration site).
      *(nine fixtures landed, covering all three required cases plus a docstring-quoted binder, an
      in-proof `haveI` mention, `None`, a malformed vocabulary token, and an `@[simp]`-attributed
      declaration whose doc block must stay attached.)*
- [x] Run `bash scripts/check-module-invariants.sh` and confirm C34 reports without failing and
      without perturbing any existing check's status. *(`--no-build` pass: ALL CHECKS PASSED,
      exit 0, zero FAIL lines; C34 prints its census as an ungated `INFO`.)*

**Timing**: 2 hours

**Depends on**: none

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: This phase asserts that the fix set is exactly the eight named declarations
and that C34 is the next free invariant number. Confirm both at implementation time by the
re-measurement tasks above; if the fix set has shrunk (a site already corrected) record the
exclusion, and if it has GROWN, report the additional sites rather than silently widening the
Lean phases.

**Files to modify**:
- `scripts/check-module-invariants.sh` - add the C34 header comment row, the `ENFORCE_C34` flag
  default, the table-driven class/vocabulary table, the census block and its fixture self-test

**Verification**:
- `bash scripts/check-module-invariants.sh` exits with its pre-phase status (C34 adds no failure)
- The C34 census lines appear in the output with non-zero totals
- The fixture self-test passes, including the must-not-match cases
- Deliberately emptying the walk reproduces the exit-2 anti-silence path

---

### Phase 2: Document the `Constraints consumed:` normal form [COMPLETED]

**Goal**: Fix the marker convention in the one place the repository already documents docstring
normal forms, so Phases 3-5 write markers to a written spec rather than to a plan.

**Tasks**:
- [x] Read `docs/development/REFERENCE_NORMAL_FORM.md` and the three normal forms it already
      defines (bibliographic, paper anchor, module cross-reference), noting how each records its
      gating invariant.
- [x] Add a fourth normal form: **constraint-consumption line**. Specify the literal line shape
      (`Constraints consumed: Seriality, Limit`), that it lives in the declaration's own `/--`
      block, the closed case-sensitive comma-separated vocabulary
      `{Compositionality, Seriality, Limit, Saturation}`, and `None` for a constraint-free result.
- [x] State the semantics explicitly: **the listed constraints are the whole of what the elaborated
      proof term reaches, and every unlisted constraint is thereby CLAIMED unconsumed.** This is
      what makes the line a checkable claim rather than a comment.
- [x] Record the consumption-vs-elimination distinction as part of the convention: *elimination* is
      spending a constraint on a conclusion that does not mention it; *consumption* is the
      elaborated proof term reaching the field at all. The marker enumerates consumption. Cite
      `isTotal_of_isMax`'s "not a second *Saturation* elimination site" as the worked example of a
      docstring that reads like an independence claim and is not one.
- [x] Record why the marker is positive (a consumption enumeration) rather than a bare independence
      assertion: it covers the honest *Saturation*-consuming sites too, and it avoids colliding with
      `FormalSystem/Metalogic/Independence/`, which means logical independence of proof-system
      axioms and is unrelated.
- [x] Note that enforcement is C34 in `scripts/check-module-invariants.sh`, matching how the other
      three forms name their gates.

**Timing**: 1.5 hours

**Depends on**: none

**Verification Tier**: prose

**Result**: landed as `## 3. The constraint-consumption line` in
`docs/development/REFERENCE_NORMAL_FORM.md`, with sections 3-5 renumbered to 4-6 (no anchor link
into this document exists anywhere in the tree, so the renumber breaks nothing). *(deviation:
altered — the form is a sibling top-level section rather than a fourth `### ` subsection of
`## 2. The three forms`. Those three are `## References` citation forms; filing a per-declaration
docstring claim among them would tell a reader to write it in a References block. Section 2's
worked example and the document's opening both cross-link to it instead.)* Verified:
`--no-build` harness green, C12 and C13 pass, no Lean file touched.

**Files to modify**:
- `docs/development/REFERENCE_NORMAL_FORM.md` - add the fourth normal form section

**Verification**:
- The new section defines line shape, vocabulary, semantics, the elimination distinction, and the
  gate, in the same shape as the three existing forms
- `bash scripts/check-module-invariants.sh` still passes C12/C13 (every source path and relative
  markdown link in `docs/` resolves)
- No Lean file is touched by this phase

---

### Phase 3: Restate the four base declarations in `Constraint.lean` [NOT STARTED]

**Goal**: Give the four foundational independence-claiming declarations explicit-hypothesis twins,
each with its original kept as a one-line corollary at an unchanged signature.

**Tasks**:
- [ ] Read the three matched pairs the prerequisite task already landed in `Constraint.lean`
      (`fib_subset_fib_of_compositional` / `fib_subset_fib_of_le_of_le`, and the two others) and
      follow their exact shape: explicit-hypothesis statement first, docstring naming what it
      consumes and why the split exists, corollary immediately below.
- [ ] `fib_zero_subset_of_compositional_limit` at `(hcomp, hlim)`, proved by the two already-honest
      monotonicity lemmas `fib_subset_fib_of_compositional` and `fib_subset_fib_of_compositional'`;
      demote `fib_zero_subset` to `fib_zero_subset_of_compositional_limit F.comp F.limit`.
- [ ] `fib_zero_subset_mem_of_compositional_limit` at `(hcomp, hlim)`, proved by the above plus
      `seg_eq_inter_fib`; demote `fib_zero_subset_of_mem_Constraints` to the one-line corollary.
- [ ] `nonempty_fib_of_serial_limit` at `(hser, hlim)`, replacing `F.serial` with `hser` and the
      `F.reflection` step with `F.toFibre.reflection_of_limit hlim`; demote `nonempty_fib_of_serial`
      to `nonempty_fib_of_serial_limit F.serial F.limit`. (Name follows
      `TaskFrame.nullity_of_serial_limit`'s established shape.)
- [ ] `nonempty_seg_of_compositional_limit` at `(hcomp, hlim)`, replacing `F.interpolates` with
      `TaskFrame.interpolates_of_comp hcomp` and `F.reflection` with
      `F.toFibre.reflection_of_limit hlim`; demote `nonempty_seg_of_interpolates` to the corollary.
      Its name and docstring keep the interpolation-half wording, which is accurate.
- [ ] Give each of the four new declarations a `Constraints consumed:` line per Phase 2's
      convention, and each of the four corollaries its own line (the corollary consumes the same
      constraints through `F.comp`/`F.serial`/`F.limit`).
- [ ] Normalize the two pre-existing ad-hoc "**Axioms consumed…**" docstring lines in this file
      into the convention's shape, keeping their prose content.
- [ ] Confirm every corollary's binder list, implicit-argument order and name are byte-identical to
      the pre-phase version; only the body changes.

**Timing**: 1.5 hours

**Depends on**: 2

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: This phase asserts it touches exactly one file and exactly four
declaration pairs. Confirm with `git diff --stat` showing `Constraint.lean` alone, and
`git diff` showing no change to any corollary's signature line.

**Files to modify**:
- `FormalSystem/Semantics/Extension/Constraint.lean` - four explicit-hypothesis restatements, four
  demoted corollaries, marker lines, two ad-hoc lines normalized

**Verification**:
- `lake build FormalSystem.Semantics.Extension.Constraint` exits 0 with no new warning
- `git diff --stat` names `Constraint.lean` and nothing else
- `git diff` shows no change to any of the four corollaries' signature lines
- No `sorry` and no new axiom introduced

---

### Phase 4: Restate the three downstream declarations in `Constraint.lean` [NOT STARTED]

**Goal**: Carry the pattern through to the three compositions that sit on top of Phase 3's
results, including the flagship `constraint`.

**Tasks**:
- [ ] `nonempty_of_mem_Constraints_of_compositional_serial_limit` at `(hcomp, hser, hlim)`, its two
      branches now discharged by Phase 3's `nonempty_seg_of_compositional_limit` and
      `nonempty_fib_of_serial_limit`; demote `nonempty_of_mem_Constraints` to the one-line
      corollary at `F.comp F.serial F.limit`.
- [ ] `exists_mem_subset_inter_of_compositional_limit` at `(hcomp, hlim)`, its four-way case
      analysis routed through `seg_subset_seg_of_compositional` and the two
      `fib_subset_fib_of_compositional` lemmas instead of their binder-carrying corollaries; demote
      `exists_mem_subset_inter` to the corollary.
- [ ] `constraint_of_compositional_serial_limit` at `(hcomp, hser, hlim)`, assembled from
      `nonempty_Constraints` (already binder-free),
      `exists_mem_subset_inter_of_compositional_limit` and
      `nonempty_of_mem_Constraints_of_compositional_serial_limit`; demote `constraint` to the
      one-line corollary at `F.comp F.serial F.limit`.
- [ ] Rewrite `constraint`'s docstring so the bold "*Saturation* is **not** consumed" claim now sits
      over a statement that proves it, and carry its already-accurate consumption list
      (`C→`, `C←`, `S`, `L` — and not `Sat`) into a `Constraints consumed: Compositionality,
      Seriality, Limit` line.
- [ ] Give each new declaration and each demoted corollary its `Constraints consumed:` line.
- [ ] Re-confirm no corollary signature moved.

**Timing**: 1.5 hours

**Depends on**: 3

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: This phase asserts three declaration pairs in one file. Confirm with
`git diff --stat` and a signature-line diff as in Phase 3.

**Files to modify**:
- `FormalSystem/Semantics/Extension/Constraint.lean` - three explicit-hypothesis restatements, three
  demoted corollaries, `constraint`'s docstring corrected, marker lines

**Verification**:
- `lake build FormalSystem.Semantics.Extension.Constraint` exits 0 with no new warning
- `git diff --stat` names `Constraint.lean` and nothing else
- `constraint`'s signature line is unchanged and its docstring's independence claim is now backed by
  `constraint_of_compositional_serial_limit`
- No `sorry` and no new axiom introduced

---

### Phase 5: Restate `admissible` and mark the genuine *Saturation* consumers [NOT STARTED]

**Goal**: Close the one fix site outside `Constraint.lean`, and mark — never change — the six
declarations that genuinely consume *Saturation*, so the audit record covers the whole population.

**Tasks**:
- [ ] `admissible_of_serial_limit` at `(hser, hlim)` in
      `FormalSystem/Semantics/Extension/Admissible.lean`: `fibers` is already binder-free, so the
      only frame-field reaches are `TaskFrame.nullity_of_serial_limit hser hlim` for the `z`-twice
      case and `F.toFibre.reflection_of_limit hlim` for the reflection step. Demote `admissible` to
      the one-line corollary at `F.serial F.limit` with its signature unchanged, and give its
      docstring's "*Saturation* is not consumed" sentence a `Constraints consumed: Seriality, Limit`
      line.
- [ ] Add a `Constraints consumed:` line naming *Saturation* to each of the six declarations that
      genuinely consume it, changing nothing else about them:
      `Extension/Step.lean` `step` (the sole elimination site, reading `F.saturation` directly),
      `Extension/Extension.lean` `isTotal_of_isMax`, `extension` and `isRestriction_of_isRegular`,
      `Extension/Completion.lean` `completion_of_isRegular`, and
      `Correspondence/RigidityReal.lean` `static_of_countable`.
- [ ] On `isTotal_of_isMax` specifically, keep the existing "not a second *Saturation* elimination
      site" sentence intact and let the marker line carry the consumption fact beside it — this is
      the worked example of consumption-vs-elimination that Phase 2 documents, and it must survive
      as such.
- [ ] Re-derive each of the six consumption lists from the declaration rather than copying this
      plan's assertion that all six consume *Saturation*; if one turns out not to, mark it
      accordingly and record the discrepancy.

**Timing**: 1.5 hours

**Depends on**: 2

**Verification Tier**: interface

**Commit Mode**: per-substep

**Scope Hypothesis**: This phase asserts one restatement plus six marker-only edits across five
files, four of which receive comment-only changes. Confirm with `git diff --stat`: only
`Admissible.lean` may show a non-comment change, and the four marker-only files must show
comment-region hunks alone.

**Files to modify**:
- `FormalSystem/Semantics/Extension/Admissible.lean` - `admissible_of_serial_limit` plus the demoted
  corollary and marker lines
- `FormalSystem/Semantics/Extension/Step.lean` - marker line on `step`
- `FormalSystem/Semantics/Extension/Extension.lean` - marker lines on `isTotal_of_isMax`,
  `extension`, `isRestriction_of_isRegular`
- `FormalSystem/Semantics/Extension/Completion.lean` - marker line on `completion_of_isRegular`
- `FormalSystem/Semantics/Correspondence/RigidityReal.lean` - marker line on `static_of_countable`

**Verification**:
- `lake build` exits 0 with no new warning (interface tier: `Admissible.lean` plus its direct
  dependents, which the marker-only files are among)
- `admissible`'s signature line is unchanged
- The four marker-only files' diffs lie entirely inside `/--` blocks
- No `sorry` and no new axiom introduced

---

### Phase 6: Gate C34 — structural assertion, trigger assertion, soft-then-enforced [NOT STARTED]

**Goal**: Turn Phase 1's census into an enforced invariant, in the soft-then-enforced order that
lets the trigger half's false positives be read before they can block.

**Tasks**:
- [ ] **C34a (structural, gated)**: for every declaration carrying a `Constraints consumed:` line
      whose list OMITS *Saturation*, assert that the declaration's text from its KEYWORD LINE to the
      end of its span, comment-masked, contains no `IsRegular`. Masking excludes the docstring, so
      explanatory prose such as "never the `IsRegular` instance" is not a self-failure; scanning to
      end-of-span rather than to `:=` also catches an in-proof `haveI : F.IsRegular`.
- [ ] **C34b (trigger, gated)**: for every declaration carrying an `IsRegular` **binder**
      (bracketed match only, so `IsRegular`-concluding declarations are out of scope) whose
      docstring trips the independence-prose heuristic — mentions *Saturation* inside a negation or
      a consumption enumeration — and carries NO `Constraints consumed:` line, fail with the remedy
      "add a `Constraints consumed:` line". This is the half that stops a new unmarked claim
      slipping past an opt-in marker; it forces marking and never renders a verdict on honesty.
- [ ] Extend the anti-silence guard: now that markers exist in the tree, zero markers found anywhere
      joins the empty-walk condition as an exit-2 broken-matcher signal, not suppressed by
      `ENFORCE_C34=0`.
- [ ] Extend the fixture self-test to cover both assertions, including a marked-and-binder-carrying
      must-fail case for C34a and an unmarked-tripping-docstring must-fail case for C34b.
- [ ] Land with `ENFORCE_C34=0` first. Run the harness, READ the full C34b hit list, and classify
      each hit: a genuine unmarked claim gets a marker line; a passing mention gets a marker line
      too (the marker is always the remedy, never a heuristic exemption).
- [ ] Add whatever marker lines the C34b list demands, then flip the default to `ENFORCE_C34=1` and
      re-run until both assertions pass.
- [ ] Re-run the census and record the final classification counts from the tree.

**Timing**: 2 hours

**Depends on**: 1, 3, 4, 5

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: This phase asserts that the C34b hit list is small enough to resolve with
marker lines alone. Confirm by reading the soft-run list before flipping the flag; if it names
declarations whose correct remedy is a restatement rather than a marker, STOP and report rather
than expanding the Lean surface, since Phases 3-5 pinned the fix set deliberately.

**Files to modify**:
- `scripts/check-module-invariants.sh` - C34a, C34b, extended anti-silence guard and fixture
  self-test, `ENFORCE_C34` default flipped to 1
- `FormalSystem/Semantics/**/*.lean` - only marker lines demanded by the C34b soft run, comment-only

**Verification**:
- `ENFORCE_C34=0 bash scripts/check-module-invariants.sh` prints the full hit list without failing
- `bash scripts/check-module-invariants.sh` passes C34 with the flag defaulted to 1
- The fixture self-test's must-fail cases fail and its must-pass cases pass
- The zero-marker and empty-walk paths both exit 2 even with `ENFORCE_C34=0`
- `lake build` exits 0 with no new warning

---

### Phase 7: Document the invariant and close on the full gate set [NOT STARTED]

**Goal**: Record C34 where every other invariant is recorded, and close the task on a green full
gate set.

**Tasks**:
- [ ] Add the C34 row to `docs/development/MODULE_INVARIANTS.md`'s table in the established
      "what it checks / why it exists" shape, covering both assertions, the census, the anti-silence
      guard and the `ENFORCE_C34` flag.
- [ ] State the rationale that belongs in the record: why an at-site marker rather than a central
      per-binder manifest (C29's recorded evidence about central reason files going stale), and why
      a docstring line rather than a Lean attribute (build-free, so the check runs under the
      harness's `--no-build` CI invocation instead of joining the recorded not-in-CI gaps).
- [ ] Confirm the C34 entry in `scripts/check-module-invariants.sh`'s own header comment list is
      present and matches the documented row.
- [ ] Cross-link `REFERENCE_NORMAL_FORM.md`'s fourth normal form and the `MODULE_INVARIANTS.md` row
      to each other, as the three existing forms and their gates are cross-linked.
- [ ] Run the full gate set: `lake build`, `bash scripts/check-module-invariants.sh`, and every
      other lint the repository runs at task close. All green, sorry-free, warning-free.
- [ ] Re-run the binder census one final time and report the measured numbers as the task's outcome
      figures — measured at close, not quoted from this plan or the research report.
- [ ] Confirm the whole task's Lean diff is confined to `FormalSystem/Semantics/Extension/` plus
      `Correspondence/RigidityReal.lean`'s marker line, with the non-Lean diff confined to
      `scripts/check-module-invariants.sh` and the two `docs/development/` files.
- [ ] Write the execution summary to
      `specs/663_hypothesis_honesty_lint_isregular_overbinding/summaries/01_hypothesis-honesty-lint-isregular-summary.md`.

**Timing**: 1.5 hours

**Depends on**: 6

**Verification Tier**: full

**Commit Mode**: per-substep

**Scope Hypothesis**: This phase asserts the final diff is confined to the file set named above.
Confirm with `git diff --stat` against the task's base commit; a file outside that set is a
scope breach to report, not to absorb.

**Files to modify**:
- `docs/development/MODULE_INVARIANTS.md` - C34 row
- `docs/development/REFERENCE_NORMAL_FORM.md` - cross-link to the invariant row
- `scripts/check-module-invariants.sh` - header comment row if not already present
- `specs/663_hypothesis_honesty_lint_isregular_overbinding/summaries/01_hypothesis-honesty-lint-isregular-summary.md` - new

**Verification**:
- `lake build` exits 0, sorry-free, warning-free
- `bash scripts/check-module-invariants.sh` exits 0 with C34 enforced
- `git diff --stat` against the task base names only the file set above
- The census prints non-zero marked and marked-and-*Saturation*-free counts

---

## Lean Challenge Statements

The eight explicit-hypothesis restatements this plan commits to. Each original declaration survives
unchanged as a one-line corollary and is therefore NOT pinned here — only the new statements are.
Bodies are `sorry` by the format's rule; the real proofs are strict generalizations of the existing
green proofs with a projection substituted for each frame-field access.

```lean
import FormalSystem.Semantics.FrameAxioms
import Mathlib.Tactic.Abel

namespace FormalSystem.Semantics

namespace PartialHistory

open TaskFrame

variable {F : TaskFrame}

/-- `fib_zero_subset` at the hypotheses its proof consumes.
Constraints consumed: Compositionality, Limit -/
theorem fib_zero_subset_of_compositional_limit
    (hcomp : TaskFrame.Compositional F.TaskRel) (hlim : TaskFrame.Limit F.TaskRel)
    {τ : PartialHistory F} {z t : F.Duration} (hz : τ.domain z) (ht : τ.domain t) :
    Fib F.TaskRel (τ.states z hz) (z - z) ⊆ Fib F.TaskRel (τ.states t ht) (z - t) := sorry

/-- `fib_zero_subset_of_mem_Constraints` at the hypotheses its proof consumes.
Constraints consumed: Compositionality, Limit -/
theorem fib_zero_subset_mem_of_compositional_limit
    (hcomp : TaskFrame.Compositional F.TaskRel) (hlim : TaskFrame.Limit F.TaskRel)
    {τ : PartialHistory F} {z : F.Duration} (hz : τ.domain z)
    {c : Set F.WorldState} (hc : c ∈ Constraints τ z) :
    Fib F.TaskRel (τ.states z hz) (z - z) ⊆ c := sorry

/-- `nonempty_fib_of_serial` at the hypotheses its proof consumes. *Limit* enters only through
the reflection law at duration zero, which is genuinely reachable at `t = z`.
Constraints consumed: Seriality, Limit -/
theorem nonempty_fib_of_serial_limit
    (hser : TaskFrame.Serial F.TaskRel) (hlim : TaskFrame.Limit F.TaskRel)
    {τ : PartialHistory F} {z t : F.Duration} (ht : τ.domain t) :
    (Fib F.TaskRel (τ.states t ht) (z - t)).Nonempty := sorry

/-- `nonempty_seg_of_interpolates` at the hypotheses its proof consumes: the interpolation half
of *Compositionality*, reached through `TaskFrame.interpolates_of_comp`, plus the reflection law.
Constraints consumed: Compositionality, Limit -/
theorem nonempty_seg_of_compositional_limit
    (hcomp : TaskFrame.Compositional F.TaskRel) (hlim : TaskFrame.Limit F.TaskRel)
    {τ : PartialHistory F} {z t s : F.Duration} (ht : τ.domain t) (hs : τ.domain s)
    (htz : t < z) (hzs : z < s) :
    (Seg F.TaskRel (τ.states t ht) (τ.states s hs) (z - t) (s - z)).Nonempty := sorry

/-- `nonempty_of_mem_Constraints` at the hypotheses its proof consumes.
Constraints consumed: Compositionality, Seriality, Limit -/
theorem nonempty_of_mem_Constraints_of_compositional_serial_limit
    (hcomp : TaskFrame.Compositional F.TaskRel) (hser : TaskFrame.Serial F.TaskRel)
    (hlim : TaskFrame.Limit F.TaskRel)
    {τ : PartialHistory F} {z : F.Duration} {c : Set F.WorldState}
    (hc : c ∈ Constraints τ z) : c.Nonempty := sorry

/-- `exists_mem_subset_inter` at the hypotheses its proof consumes.
Constraints consumed: Compositionality, Limit -/
theorem exists_mem_subset_inter_of_compositional_limit
    (hcomp : TaskFrame.Compositional F.TaskRel) (hlim : TaskFrame.Limit F.TaskRel)
    {τ : PartialHistory F} {z : F.Duration} {c₁ c₂ : Set F.WorldState}
    (hc₁ : c₁ ∈ Constraints τ z) (hc₂ : c₂ ∈ Constraints τ z) :
    ∃ c ∈ Constraints τ z, c ⊆ c₁ ∩ c₂ := sorry

/-- `lem:constraint` at the hypotheses its proof consumes. This is the statement that makes the
docstring's bold "*Saturation* is **not** consumed" a machine-checked claim rather than prose
over a binder that supplies it anyway.
Constraints consumed: Compositionality, Seriality, Limit -/
theorem constraint_of_compositional_serial_limit
    (hcomp : TaskFrame.Compositional F.TaskRel) (hser : TaskFrame.Serial F.TaskRel)
    (hlim : TaskFrame.Limit F.TaskRel) (τ : PartialHistory F) (z : F.Duration) :
    DirectedFamily (Constraints τ z) ∧ ∀ c ∈ Constraints τ z, c.Nonempty := sorry

/-- `lem:admissible` at the hypotheses its proof consumes: *Seriality* and *Limit* through
`TaskFrame.nullity_of_serial_limit` and the reflection law. `fibers` is already binder-free.
Constraints consumed: Seriality, Limit -/
theorem admissible_of_serial_limit
    (hser : TaskFrame.Serial F.TaskRel) (hlim : TaskFrame.Limit F.TaskRel)
    (τ : PartialHistory F) {z : F.Duration} (hz : ¬ τ.domain z) (u : F.WorldState) :
    AdjoinRespects τ z u ↔ ∀ c ∈ Constraints τ z, u ∈ c := sorry

end PartialHistory

end FormalSystem.Semantics
```

## Testing & Validation

- [ ] `lake build` exits 0, with zero `sorry`, zero new axiom, and zero new warning, at every phase
      boundary from Phase 3 onward
- [ ] `bash scripts/check-module-invariants.sh` exits 0 with C34 enforced, and every pre-existing
      invariant (B0-B3, C1-C33) retains its pre-task status
- [ ] C34's fixture self-test passes, with each must-not-match case (an `IsRegular`-CONCLUDING
      declaration, a `variable` block binder) and each must-fail case (marked-and-binder-carrying for
      C34a, unmarked-tripping-docstring for C34b) behaving as specified
- [ ] The anti-silence guard exits 2 on an empty walk and on a zero-marker result, and is not
      suppressed by `ENFORCE_C34=0`
- [ ] Every one of the eight original declarations keeps a byte-identical signature line; verified by
      `git diff` on the two Extension files
- [ ] `git diff --stat` against the task base names only: `FormalSystem/Semantics/Extension/*.lean`
      (five files), `FormalSystem/Semantics/Correspondence/RigidityReal.lean`,
      `scripts/check-module-invariants.sh`, `docs/development/MODULE_INVARIANTS.md`,
      `docs/development/REFERENCE_NORMAL_FORM.md`, and this task's `specs/` artifacts
- [ ] The final census is re-measured from the tree at close and reported as such — no figure from
      this plan or the research report is carried forward as an acceptance value

## Artifacts & Outputs

- `FormalSystem/Semantics/Extension/Constraint.lean` - seven explicit-hypothesis restatements, seven
  demoted corollaries, marker lines, two ad-hoc consumption lines normalized
- `FormalSystem/Semantics/Extension/Admissible.lean` - `admissible_of_serial_limit` plus the demoted
  `admissible` corollary and marker lines
- `FormalSystem/Semantics/Extension/{Step,Extension,Completion}.lean`,
  `FormalSystem/Semantics/Correspondence/RigidityReal.lean` - marker lines only, on the six genuine
  *Saturation* consumers
- `scripts/check-module-invariants.sh` - invariant C34: census (ungated), C34a and C34b (gated),
  anti-silence guard, fixture self-test, `ENFORCE_C34` flag, table-driven class/vocabulary table
- `docs/development/REFERENCE_NORMAL_FORM.md` - the constraint-consumption normal form
- `docs/development/MODULE_INVARIANTS.md` - the C34 row
- `specs/663_hypothesis_honesty_lint_isregular_overbinding/summaries/01_hypothesis-honesty-lint-isregular-summary.md`

## Rollback/Contingency

Each phase commits per green sub-step, so the unit of rollback is a commit, not a working tree.

- **A single phase goes wrong**: `git revert` that phase's commits. Phases 3-5 are independent of
  one another at the corollary boundary (every call site sees an unchanged signature), so reverting
  one leaves the others green.
- **C34 proves unworkable as specified**: Phase 6's gated assertions can be reverted while Phase 1's
  census is kept. The census alone satisfies the task's re-runnable-classification requirement; the
  gate is the stronger half and is separable by construction, which is why the two were split across
  phases.
- **C34b's hit list turns out large**: leave `ENFORCE_C34=0` and land the check reporting-only, the
  soft-then-enforced posture C24 and C9D already occupy, then report the residual as follow-up work
  rather than widening this task's Lean surface.
- **A rollback of uncommitted work becomes necessary**: take a snapshot first per
  `context/contracts/recovery.md`'s rollback rung, using the invocation shape recorded there
  (including its out-of-scope override flag for a deliberate whole-tree revert). A bare defensive
  checkpoint before risky work uses `git-snapshot.sh {N} --no-revert` instead, which is durable
  without touching the working tree.
