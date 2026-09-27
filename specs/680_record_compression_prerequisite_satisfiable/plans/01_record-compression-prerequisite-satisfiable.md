# Implementation Plan: Task #680

- **Task**: 680 - Record compression prerequisite satisfiable
- **Status**: [NOT STARTED]
- **Effort**: 2.75 hours
- **Dependencies**: None (task 623 depends on this task; this task depends on nothing)
- **Research Inputs**: specs/680_record_compression_prerequisite_satisfiable/reports/01_compression-prerequisite-satisfiable.md
- **Artifacts**: plans/01_record-compression-prerequisite-satisfiable.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: markdown
- **Lean Intent**: false

## Overview

Documentation-only. Three distinct records must land on this side, each in the file whose reader
would otherwise be misled: (1) that the consuming repository's reduction condition (iii) is now
*satisfiable in principle* but *non-monotone in the `back`/`mid`/`fwd` bounds*, so the compression
task's planning neither re-derives the prerequisite as missing nor reads "satisfiable" as "nearly
done"; (2) that the `IntPresentation` small-model hypothesis `fmp` is **refuted**, not open, in
the two files that still call it open; (3) the durable scope sentence recording that the procedure
decides validity for the language *without* the stability modal, its witness models being
deterministic and the modal therefore trivial on them. No new mathematics, no semantics changes,
no changes in the consuming repository.

### Research Integration

The research report established, by reading the consuming repository directly, that no corrective
work is owed there and that this task's entire deliverable is local. It pinned the exact stale
text (`BiLasso/Assembly.lean:23`; `BiLasso/README.md:23-28`), the already-correct citation form to
mirror (`WitnessFamily/README.md:24-25`, citing `Probe476.fmp_false` by declaration name with a
parenthesised path and no line number), and the grounding chain for the scope sentence
(`ShiftSet.total_eq_orbit` -> `PlusDeterminism.stab_iff_of_deterministic`). It also surfaced a
separate, pre-existing `ValidDiscrete` -> `ValidZTime` rename drift in the exact `BiLasso/README.md`
paragraph being rewritten, and explicitly left the scoping decision to this plan.

**Decision on the rename drift: scoped IN, as its own phase and its own commit.** Rewriting a
paragraph while knowingly leaving wrong declaration names in it is not a defensible outcome, and
`ValidDiscrete` exists nowhere in live Lean source (verified: zero occurrences under
`FormalSystem/`, `Tests/`, `BimodalTools/`). Separating it into Phase 4 with its own commit
answers the research report's own risk (two defects blurred into one pass with no record of
which is which).

**Decision on `FormalSystem/Metalogic/SoundnessLemmas/README.md`: scoped OUT, flagged.** It also
names `ValidDiscrete` (line 16, "the four discrete Prior/z1 lemmas at `ValidDiscrete`"), but in a
different directory and a different context whose correct replacement name is not established by
this task's research. Recorded here so it is a deliberate exclusion, not an oversight.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

`specs/ROADMAP.md` was not supplied in this dispatch's delegation context and so was not loaded as
roadmap context; it was consulted only to confirm relevance. Its Phase 2 ("Decidability and the
Tableau Engine") is the front this task stands in front of: this task is the sole remaining
blocker on the quasimodel/ShiftSet decidability task, which is the long pole of the adequacy
chain. No roadmap phases are added (no `roadmap_flag` in this dispatch).

## Goals & Non-Goals

**Goals**:
- Record durably, on this side, that the consuming repository's reduction condition (iii) is
  satisfiable in principle (both former prerequisites landed there: a certificate export on the
  documented wire contract, and an independent pure-Python re-checker cross-checked against
  `check_certificate`).
- Record durably the correction that travels with it: the searched witness-family space is **not
  monotone** in `back`/`mid`/`fwd` (exact-modulus folding means a search at bound `n` represents
  exactly the periods dividing `n`), so the condition as originally worded is falsified; the sole
  blocking sub-condition is fixing the length space; and a bound of the shape "segment lengths at
  least `f` of the closure size" is insufficient on its own because representability is a
  divisibility question, not a magnitude question.
- Correct the `fmp`-is-open claim to `fmp`-is-refuted in `BiLasso/Assembly.lean` and
  `BiLasso/README.md`, citing `Probe476.fmp_false` in the form the sibling README already uses.
- State the without-stability-modal scope durably in both files, worded so it cannot be read as
  inviting a truth-clause patch.
- Fix the `ValidDiscrete` -> `ValidZTime` rename drift in `BiLasso/README.md` (separate commit).

**Non-Goals**:
- Any change in the consuming repository (`~/Projects/ModelChecker`). Its adequacy document
  already states condition (iii) correctly.
- Any change to `specs/TODO.md`'s task 623 entry: research confirmed it already carries the
  struck item and the non-monotonicity correction in its own words.
- Any new mathematics, any change under `FormalSystem/Semantics/`, any proof edits.
- Fixing the `ValidDiscrete` occurrence in `FormalSystem/Metalogic/SoundnessLemmas/README.md`.
- Building or designing the bounded grid sweep that the blocking sub-condition needs. This plan
  records that it is unbuilt; it does not build it.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Under-correction: "open" replaced by "satisfiable"/"in progress" rather than "refuted", re-introducing the exact defect | H | M | Phases 2 and 3 quote the required wording obligations explicitly: the word is *refuted*, for **every** candidate list, with the witness formula and the `Probe476.fmp_false` citation |
| Scope sentence read as inviting a `⊡` truth clause | M | M | Phases 2 and 3 require the phrase "by construction" and an explicit statement that the device cannot be extended by adding a truth clause |
| New `file.lean:NNN` citations break C20 (out of range / wrong declaration) | M | M | Cite by declaration name with a parenthesised path and **no line number**, mirroring `WitnessFamily/README.md:24-25`. Phase 5 runs the C20 tier to confirm |
| Task-number citations leak into `FormalSystem/**` text, breaking C9 and `.claude/rules/no-task-references-in-deliverables.md` | H | M | The scope sentence must cite durable anchors (`stab_iff_of_deterministic`, `total_eq_orbit`, the branching-witness-structure line) and never a task number. Phase 5 runs the C9 tier |
| Sibling task 681 edits `FormalSystem/Semantics/ShiftSet.lean` this same cycle, shifting the lines the scope sentence would cite | M | H | Cite `total_eq_orbit` by name, never by line number. `ShiftSet.lean` is read-only for this task and is in task 681's declared `file_scope` — do not edit it |
| Sibling tasks touch `scripts/check-module-invariants.sh` / `scripts/lib/lean_citations.py` (task 681's declared scope) while Phase 5 runs them | M | M | Phase 5 *invokes* these scripts read-only and never edits them; an unexpected failure inside them is to be reported as a possible sibling in-flight edit, not silently "fixed" |
| Over-staging across sibling work on this shared tree | H | M | Explicit per-file `git add -- <paths>` only, one commit per phase, `git status --short` reviewed first; no directory or glob pathspec, no `git add -A`, no `git-snapshot.sh` in its reverting default mode |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2, 3 | -- |
| 2 | 4 | 3 |
| 3 | 5 | 1, 2, 3, 4 |

Phases within the same wave can execute in parallel. Phases 1, 2 and 3 touch disjoint files.
Phase 4 touches the same file as Phase 3 and is therefore sequenced after it.

### Phase 1: Record the cross-repository reduction-condition status [NOT STARTED]

**Goal**: The satisfiable-in-principle news and the non-monotonicity correction are durably
recorded on this side, in the section whose reader would otherwise re-derive the prerequisite as
missing.

**Tasks**:
- [ ] Re-read `FormalSystem/Metalogic/Decidability/WitnessFamily/README.md` immediately before
      editing (sibling tasks share this tree).
- [ ] Extend its `## This is the soundness half only` section (which already names "the
      compression work" as the owner of the completeness direction) with a short subsection
      recording, in durable terms and without any task number:
      - the consuming side's reduction condition is now satisfiable **in principle**: both of its
        former prerequisites are landed there — a certificate export on the wire contract this
        tree documents (`BimodalTools/README.md`, "Certificate re-verification protocol"), and an
        independent pure-Python re-checker that decides the four conditions over the proved
        windows on every reported countermodel, cross-checked against `lake exe check_certificate`
        where present;
      - "satisfiable" is **not** "nearly done": the searched witness-family space is **not
        monotone** in the `back`/`mid`/`fwd` bounds, because the consuming registry folds those
        bounds by exact modulus — a search at bound `n` represents exactly the periods dividing
        `n`. The measured instance: one formula is SAT at `(3, 1, 3)` and `(6, 1, 6)` and
        genuinely UNSAT (not a timeout) at `(4, 1, 4)` and `(5, 1, 5)`, exactly as `6 ∤ 4` and
        `6 ∤ 5` predict;
      - consequently the condition **as originally worded is false**, which is why it was
        rewritten into ordered sub-conditions rather than simply marked satisfiable; the sole
        blocking one is fixing the length space — either sweeping the bounds over the grid up to
        the compression bound, or restricting the claim to bounds the folding actually covers —
        and without it the condition is **unprovable, not merely unproved**;
      - the corollary for the compression bound's *shape*: a bound of the form "segment lengths at
        least `f` of the closure size" is insufficient on its own, because representability is a
        divisibility (period) question, not a magnitude question — a family whose period does not
        divide the configured length is unrepresentable however large that length is.
- [ ] Add one sentence to `BimodalTools/README.md`'s `## Certificate re-verification protocol`,
      inside or immediately after its **What acceptance means** paragraph, recording that the
      producing side now also re-decides each reported countermodel independently in Python and
      cross-checks against this executable where present — so acceptance is dual-decided per run
      rather than single-sided. Keep it to one sentence; this file's honesty note about
      `countermodel` not being a kernel-checked proof must stand unchanged.
- [ ] Verify no task number appears in either added passage.
- [ ] `git status --short`; `git add -- FormalSystem/Metalogic/Decidability/WitnessFamily/README.md
      BimodalTools/README.md`; commit.

**Timing**: 0.5 hours

**Depends on**: none

**Verification Tier**: prose

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/WitnessFamily/README.md` - new subsection under
  `## This is the soundness half only` carrying the satisfiable-in-principle record, the
  non-monotonicity correction, and the magnitude-insufficiency corollary.
- `BimodalTools/README.md` - one sentence in `## Certificate re-verification protocol` recording
  the independent Python re-check and the cross-check against `check_certificate`.

**Verification**:
- Diff read-through confirms every changed hunk is prose in a markdown file.
- `grep -nE '\btasks? [0-9]+' ` over both changed files returns nothing.
- Both added passages state all four facts above; in particular the words "not monotone",
  "unprovable rather than merely unproved", and the divisibility-not-magnitude point are all
  present in some form.
- No relative link or `FormalSystem.*` module path was added that does not resolve (checked again
  mechanically in Phase 5 via C5/C13/C32).

---

### Phase 2: Correct `fmp`'s status and state the scope in `Assembly.lean` [NOT STARTED]

**Goal**: `Assembly.lean`'s module docstring no longer calls `fmp` open, and carries the durable
without-stability-modal scope sentence.

**Tasks**:
- [ ] Re-read `FormalSystem/Metalogic/Decidability/BiLasso/Assembly.lean` immediately before
      editing.
- [ ] Replace the sentence "`fmp` is the one open theorem between this layer and decidability of
      `ValidZTime`." (currently at line 23, inside the `/-! ... -/` module comment) with a
      statement that `fmp` in this literal candidate-list-of-finite-presentations form is
      **refuted — closed negatively, not open** — for *every* candidate list, by
      `Probe476.fmp_false`
      (`specs/archive/476_box_faithful_small_model_theorem/evidence/fmp-hypothesis-is-false.lean`),
      with the witness `□(p ∨ Fp ∨ Pp) ∧ □(p → ¬Pp)`: satisfiable over the ℤ-carrier `ShiftSet`,
      satisfiable at no state of any finite presentation. Cite by declaration name and
      parenthesised path, with **no** line number.
- [ ] Keep the surrounding accurate material (the box-faithfulness crux, the
      `exists_annot_of_truth`-compresses-within-a-presentation point) intact; adjust only the
      sentences that assert openness or that read as "one theorem still needed".
- [ ] Add the durable scope sentence to the same module comment: this module decides `ValidZTime`
      for `FormalSystem.Syntax.Formula`, the base language **without** the stability modal `⊡`
      (which lives only in `FormalSystem.PlusLanguage.Formula`'s `PlusFormula`, so `ValidZTime`
      cannot even state a claim about it); the certified witness models are `ShiftSet`-built and
      therefore deterministic (`ShiftSet.total_eq_orbit`), and on a deterministic frame `⊡`
      collapses to the identity (`PlusDeterminism.stab_iff_of_deterministic`). State explicitly
      that the device is therefore silent on `⊡` **by construction** rather than merely incomplete
      for it, and that it cannot be extended to cover `⊡` by adding a truth clause — a genuinely
      different, branching witness structure is required.
- [ ] Verify no task number appears in the added text.
- [ ] `lake build FormalSystem.Metalogic.Decidability.BiLasso.Assembly`.
- [ ] `git status --short`; `git add -- FormalSystem/Metalogic/Decidability/BiLasso/Assembly.lean`;
      commit.

**Timing**: 0.5 hours

**Depends on**: none

**Verification Tier**: local

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/BiLasso/Assembly.lean` - module `/-! -/` comment only:
  `fmp`-status correction plus the scope sentence. No declaration, signature, or proof changes.

**Verification**:
- `lake build FormalSystem.Metalogic.Decidability.BiLasso.Assembly` exits 0.
- Diff touches only lines inside the module `/-! ... -/` comment; `git diff` shows no change to
  any `theorem`/`def`/`instance` line.
- `grep -n 'open theorem' FormalSystem/Metalogic/Decidability/BiLasso/Assembly.lean` returns
  nothing.
- The words "refuted" and "by construction" both appear; `Probe476.fmp_false`,
  `total_eq_orbit` and `stab_iff_of_deterministic` are all cited by name.
- `grep -nE '\btasks? [0-9]+' ` over the file returns nothing.

---

### Phase 3: Correct `fmp`'s status and state the scope in `BiLasso/README.md` [NOT STARTED]

**Goal**: `BiLasso/README.md`'s "what decidability still needs" section no longer frames `fmp` as
the one open theorem, and carries the same durable scope sentence.

**Tasks**:
- [ ] Re-read `FormalSystem/Metalogic/Decidability/BiLasso/README.md` immediately before editing.
- [ ] Rewrite the framing of the section currently headed `## What decidability of `ValidDiscrete`
      still needs` (lines 23-28 and the "Given `fmp`, the rest assembles" paragraph that follows)
      so that it states the refutation rather than an open theorem: `fmp` in the literal
      candidate-list form is closed negatively by `Probe476.fmp_false` for every candidate list,
      same citation form as Phase 2 (declaration name plus parenthesised path, no line number).
      What the section should now say is what the layer *does* buy given a finite-model step, and
      that the step in this form is refuted — so the remaining route is the presentation-free
      witness family, not a finite presentation.
- [ ] Leave the box-faithfulness discussion, the three measured consequences, the
      `cands`-cannot-be-a-finite-list point, and the "do not promise a choice-free result"
      paragraph substantively intact — the research found them accurate.
- [ ] Add the durable scope sentence (same content as Phase 2, worded for a README reader): the
      procedure decides `ValidZTime` for the base language without `⊡`; witness models are
      deterministic; `⊡` is trivial there; silent **by construction**; not extensible by a truth
      clause.
- [ ] Verify no task number appears in the added text.
- [ ] `git status --short`; `git add -- FormalSystem/Metalogic/Decidability/BiLasso/README.md`;
      commit (message scoped to the `fmp`-status correction only — the rename drift is Phase 4).

**Timing**: 0.75 hours

**Depends on**: none

**Verification Tier**: prose

**Scope Hypothesis**: the stale framing is expected to occupy the section heading plus the
"Exactly one theorem" block (lines 23-28) and the "Given `fmp`, the rest assembles" paragraph that
follows it. Confirm at implementation time by re-reading the section rather than trusting these
line numbers, and report a divergence instead of editing by line offset.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/BiLasso/README.md` - the "what decidability still needs"
  section's framing, plus the added scope sentence.

**Verification**:
- Diff read-through confirms markdown prose only.
- `grep -n 'Exactly one theorem' FormalSystem/Metalogic/Decidability/BiLasso/README.md` returns
  nothing.
- The words "refuted" and "by construction" both appear; `Probe476.fmp_false` is cited.
- `grep -nE '\btasks? [0-9]+' ` over the file returns nothing.
- No line-numbered `*.lean:NNN` citation was added (checked mechanically in Phase 5 via C20).

---

### Phase 4: Fix the `ValidDiscrete` -> `ValidZTime` rename drift in `BiLasso/README.md` [NOT STARTED]

**Goal**: `BiLasso/README.md` names the declarations `Assembly.lean` actually defines, recorded as
its own change so it is not conflated with the `fmp`-status correction.

**Tasks**:
- [ ] Re-read `FormalSystem/Metalogic/Decidability/BiLasso/README.md` (Phase 3 has just changed
      it).
- [ ] Confirm the live names against `Assembly.lean` itself rather than against this plan:
      `ValidZTime`, `validZTime_iff_check`, `validZTime_iff_checkFamily`, `decidableValidZTime`,
      `decidableValidZTimeFamily`, `not_validZTime_of_satAtState`.
- [ ] Replace every stale occurrence in this file, including the section heading and the
      `Assembly.lean` row of the `## Modules` table.
- [ ] Confirm `ValidDiscrete`/`validDiscrete` has zero remaining occurrences in this file.
- [ ] Do **not** touch `FormalSystem/Metalogic/SoundnessLemmas/README.md` (explicitly out of
      scope, see Overview); record in the summary that it still carries one occurrence, in a
      different context, for a separate task.
- [ ] `git status --short`; `git add -- FormalSystem/Metalogic/Decidability/BiLasso/README.md`;
      commit with a message naming the rename drift specifically.

**Timing**: 0.5 hours

**Depends on**: 3

**Verification Tier**: prose

**Scope Hypothesis**: this file is expected to carry ~16 `ValidDiscrete`/`validDiscrete` tokens
across ~9 lines (23, 28, 31, 32, 34, 35, 36, 42, 81), and `ValidDiscrete` is expected to appear in
exactly one other markdown file (`FormalSystem/Metalogic/SoundnessLemmas/README.md`, out of scope)
and in zero live `.lean` files. Confirm at implementation time with
`grep -on 'ValidDiscrete\|validDiscrete' FormalSystem/Metalogic/Decidability/BiLasso/README.md`
and a repo-wide `grep -rn 'ValidDiscrete' --include='*.lean' --include='*.md'`; if the counts or
the file set differ, report the difference rather than silently widening this phase's scope.
Phase 3's own edits may have changed these counts — re-measure, do not assume.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/BiLasso/README.md` - stale declaration names only.

**Verification**:
- `grep -c 'ValidDiscrete\|validDiscrete' FormalSystem/Metalogic/Decidability/BiLasso/README.md`
  returns 0.
- Every replacement name is one that appears in `Assembly.lean` (spot-check each against
  `grep -n` in that file).
- Diff read-through confirms markdown prose only; no other content changed in this commit.

---

### Phase 5: Refresh verification dates and run the gate set [NOT STARTED]

**Goal**: The three changed READMEs carry current "Last verified" dates and the repository's
documentation invariants pass on the changed files.

**Tasks**:
- [ ] Update the `*Last verified: YYYY-MM-DD*` trailer to today's date in each README changed by
      Phases 1, 3 and 4: `FormalSystem/Metalogic/Decidability/WitnessFamily/README.md`,
      `FormalSystem/Metalogic/Decidability/BiLasso/README.md`, `BimodalTools/README.md` (all three
      currently read 2026-09-24).
- [ ] Run `bash scripts/readme-lint.sh FormalSystem` and confirm no gated failure attributable to
      these changes.
- [ ] Run `bash scripts/check-module-invariants.sh` (or its `--no-build` mode plus a targeted
      `lake build` if a full build is impractical on this shared tree) and confirm the
      documentation-facing invariants are clean for the changed files: C5 (`FormalSystem.*` module
      paths resolve), C9/C9D (zero task-number citations), C13 (relative markdown links), C20
      (`file.lean:NNN` citations), C32 (relative links inside `.lean` comments). These scripts are
      **invoked read-only**; they are in a sibling task's declared file scope and must not be
      edited here.
- [ ] If a gate fails inside a file outside this task's own changed set, check `git log` and report
      it as a possible sibling in-flight edit rather than treating it as this task's regression.
- [ ] `git status --short`; `git add -- ` the three README paths explicitly; commit.

**Timing**: 0.5 hours

**Depends on**: 1, 2, 3, 4

**Verification Tier**: full

**Scope Hypothesis**: exactly three files are expected to need a `Last verified` refresh, all
three currently reading `2026-09-24`. Confirm with
`grep -n 'Last verified' FormalSystem/Metalogic/Decidability/WitnessFamily/README.md
FormalSystem/Metalogic/Decidability/BiLasso/README.md BimodalTools/README.md` before editing; if a
fourth file was touched by an earlier phase, refresh its trailer too and say so in the summary.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/WitnessFamily/README.md` - `Last verified` date.
- `FormalSystem/Metalogic/Decidability/BiLasso/README.md` - `Last verified` date.
- `BimodalTools/README.md` - `Last verified` date.

**Verification**:
- `scripts/readme-lint.sh FormalSystem` reports no gated failure on the changed files.
- `scripts/check-module-invariants.sh` reports PASS for C5, C9, C9D, C13, C20 and C32; any
  pre-existing failure unrelated to these changes is named in the summary rather than silently
  absorbed.
- `lake build` (or the targeted module build from Phase 2, if a full build is impractical here)
  exits 0.
- All three `Last verified` trailers show today's date.

## Testing & Validation

- [ ] `lake build FormalSystem.Metalogic.Decidability.BiLasso.Assembly` exits 0 (Phase 2).
- [ ] `scripts/readme-lint.sh FormalSystem` shows no gated failure on the changed files.
- [ ] `scripts/check-module-invariants.sh` clean for C5, C9, C9D, C13, C20, C32.
- [ ] Zero occurrences of "open theorem" / "Exactly one theorem" framing for `fmp` in
      `Assembly.lean` and `BiLasso/README.md`.
- [ ] Zero occurrences of `ValidDiscrete` in `BiLasso/README.md`.
- [ ] Zero task-number citations in any file changed under `FormalSystem/**` or `BimodalTools/**`.
- [ ] The satisfiable-in-principle record, the non-monotonicity correction, and the
      divisibility-not-magnitude corollary are all three present in
      `WitnessFamily/README.md`.
- [ ] The scope sentence appears in both `Assembly.lean` and `BiLasso/README.md`, in each case
      stating "by construction" and ruling out a truth-clause extension.

## Artifacts & Outputs

- `FormalSystem/Metalogic/Decidability/WitnessFamily/README.md` (cross-repository condition record)
- `FormalSystem/Metalogic/Decidability/BiLasso/Assembly.lean` (module docstring)
- `FormalSystem/Metalogic/Decidability/BiLasso/README.md` (`fmp` status, scope sentence, rename)
- `BimodalTools/README.md` (one-sentence dual-verification note, `Last verified`)
- `specs/680_record_compression_prerequisite_satisfiable/summaries/01_*-summary.md`
- Five scoped commits, one per phase.

## Rollback/Contingency

Every change is documentation text in four files, each committed separately, with no semantics or
proof content touched. Reverting any phase is `git revert <sha>` of that phase's commit; the
phases are independent except for 3 -> 4 (same file), which revert cleanly in reverse order.
Because sibling tasks are dispatched onto this same working tree in this cycle, do **not** use
`git-snapshot.sh` in its reverting default mode and do **not** use `git reset --hard`; a targeted
`git revert` of this task's own commits is the only sanctioned rollback here. If a gate in Phase 5
fails for a reason outside these four files, stop and report rather than widening scope to fix it.
