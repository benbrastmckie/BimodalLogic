# Implementation Plan: Discharge CompactBase/CompactDense and Collect Strong Completeness

- **Task**: 493 - Discharge compactbase compactdense and strong completeness
- **Status**: [IMPLEMENTING]
- **Effort**: 7 hours
- **Dependencies**: Task 490, Task 492 (both complete). Task 509 is sequenced BEHIND this task.
- **Research Inputs**: specs/493_discharge_compactbase_compactdense_and_strong_completeness/reports/01_compactness-and-strong-completeness.md
- **Artifacts**: plans/01_compactness-strong-completeness.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

The mathematical content of this task is already machine-verified. A probe compiled with
`lake env lean` (exit 0) established that `modelExistenceBase`, `modelExistenceDense`,
`compactBase`, `compactDense`, `strongCompletenessBase` and `strongCompletenessDense` all prove
from the built library with axiom profile `[propext, Classical.choice, Quot.sound]` and no
`sorryAx`. This is therefore not a proof-search task: it is (a) landing the verified proofs into
a new module, (b) a substantial prose-correction sweep across ~35 sites that currently assert
these are open obligations, and (c) gate wiring so the axiom audit becomes standing rather than
one-off.

The single largest risk is a **missed** prose site, not a failed proof. The plan therefore ends
with a re-grep sweep whose output is captured as acceptance evidence.

### Research Integration

Findings carried directly into this plan:

- **Placement**: one new `FormalSystem/Metalogic/Compactness.lean` importing
  `FormalSystem.Metalogic.StrongCompleteness`, `FormalSystem.Semantics.Ultraproduct.Los`, and
  `FormalSystem.Semantics.Ultraproduct.IndexFilter`. `Los` does NOT transitively reach
  `IndexFilter`, so both ultraproduct imports are required. No import cycle: every import in the
  `Ultraproduct` chain was read and nothing under `FormalSystem/Metalogic/` is reachable from it.
- **Proof text**: the report's appendix probe is verbatim-compilable. Phase 1 transcribes it,
  adding only a copyright header, module docstring, and `#print axioms` lines.
- **Elaboration details that are load-bearing**: `Ultraproduct.mk` must be namespace-qualified
  (bare `mk` is ambiguous under the open namespaces); the `(⟨τ i, hτ i⟩ : (F i).HF)` ascription
  must be kept; the Dense branch needs `haveI : ∀ i, DenselyOrdered ((F i).Duration : Type) := hd`
  plus `inferInstance` in the `refine`.
- **Line-number drift**: the task description's `:305`/`:331` are stale. Verified live:
  `strongCompletenessBase_of_compact` is at `StrongCompleteness.lean:312`,
  `strongCompletenessDense_of_compact` at `:338`, `compactBase_of_modelExistence` at `:376`,
  `compactDense_of_modelExistenceDense` at `:422`, `completeness_base` at `:677`,
  `completeness_dense` at `:783`. Re-verify at implementation time rather than trusting any
  written number, including these.
- **Gate wiring**: C2/C3/C14(i) unaffected. `scripts/module-invariants-manifest.txt` must NOT
  gain an entry (that file lists modules *unreachable* from the aggregator). C14(ii) should gain
  `strongCompletenessBase` and `strongCompletenessDense`.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

`specs/ROADMAP.md` Phase 1 ("Weak and Strong Completeness") records Leg B — genuine
`Set Formula` strong completeness for Base/Dense only — as gated on the (now completed) task 424
shift-set representation theorem, with the ultraproduct work itself "not yet scoped as tasks".
This task closes Leg B's remaining obligation. Lines 93-98 of ROADMAP.md also carry the
Discrete/Dedekind status language that Phase 2's taxonomy collapse must stay consistent with;
ROADMAP.md itself is read-only for this plan and is not edited by any phase.

## Goals & Non-Goals

**Goals**:
- `StrongCompletenessBase` and `StrongCompletenessDense` inhabited unconditionally, sorry-free,
  with a recorded `#print axioms` profile of `[propext, Classical.choice, Quot.sound]`.
- `CompactBase`, `CompactDense`, `ModelExistenceBase`, `ModelExistenceDense` likewise.
- `lake build` green; `check-module-invariants.sh` green.
- Every in-tree claim that these six are open obligations corrected, with the three-way status
  taxonomy (Discrete refuted / Base+Dense open / Dedekind unavailable) collapsed consistently to
  two-way (Discrete refuted / Base+Dense **proved** / Dedekind unavailable).
- The author-memo items D1 and D2 retired by dated retirement notes, with
  `specs/paper-definitions-of-record.md:110` carrying the live truth.
- The axiom audit made standing via C14's `C14_BASELINE`.

**Non-Goals**:
- **Do NOT remove the `engine` parameters** from `strongCompletenessBase_of_compact` or
  `strongCompletenessDense_of_compact`. "Discharge the engine hypotheses" means *supply
  arguments at the call site*, not delete parameters. Task 509 collapses both reductions into a
  `FrameClass`-indexed family and needs those parameters as its work surface. This is a hard
  constraint, not a preference.
- Do NOT restructure or renumber `StrongCompleteness.lean` beyond prose edits — task 509 will
  restate that 924-line module wholesale.
- Do NOT retro-edit dated snapshots: `specs/reviews/review-2026-08-25.md`,
  `review-2026-08-25-programme-status.md`, `review-2026-08-31-metalogic-systematicity.md`, or
  any `specs/492_*/reports/` and `plans/` artifact.
- Do NOT rewrite the archived author memo's body as though the defect never existed; append
  dated retirement notes only.
- Do NOT add a `module-invariants-manifest.txt` entry for the new module.
- No Dedekind work. `FrameClass.Dedekind` remains unavailable on its primary source's own terms.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| A now-false prose claim survives the sweep | M | M | Phase 5 re-greps the six declaration names plus the phrase set (`open obligation`, `neither proved nor refuted`, `remaining obligation`, `undischarged`, `**open**`) across the whole tree minus the out-of-scope snapshot list, and captures the output as evidence |
| Proof fails to compile in final location | H | Very low | Transcribed verbatim from a probe that compiled against the built library; only a header and docstring differ. If it fails, diff against the report appendix before editing tactics |
| C14 baseline edit breaks the gate | M | M | `C14_BASELINE` is compared by exact string equality against `#print axioms` output. The `C14BASE` heredoc and the `C14LEAN` heredoc must be edited together and in the SAME order; append the two new lines after the two existing ones in both |
| Three-way taxonomy left half-updated | M | M | Phase 2 updates every mirror in one phase (`Metalogic.lean:106`, `StrongCompleteness.lean:84`) rather than splitting them across phases |
| Chronicle-obstruction argument deleted as "stale" | M | M | `StrongCompleteness.lean:294`-`:308` is still CORRECT. Phase 2 REFRAMES it from "why this is open" to "why the ultraproduct route is what it is". Explicit phase task |
| Deleting `engine` parameters destroys task 509's surface | H | Low | Called out as a Non-Goal and repeated in Phase 1's task list; Phase 5 greps that both reduction signatures still carry their parameters |
| Task 509 file conflict on StrongCompleteness.lean | M | Low | 509 declares a serialization edge on 493; this task lands first by design |
| Stale line-number citations copied forward | L | H | `architecture.md:824`-`827` and `API_REFERENCE.md:704`-`707` already cite `SetConsequence.lean:211/219/256/263` where the live values are `:209/:217/:255/:262`. Phase 3 re-derives rather than copies |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 3, 4 | 1 |
| 3 | 5 | 2, 3, 4 |

Phases within the same wave can execute in parallel. Phases 2, 3 and 4 touch disjoint file sets
(Lean modules / markdown docs / paper-side artifacts respectively) and carry territory contracts
stated in each phase.

---

### Phase 1: Land the six theorems in FormalSystem/Metalogic/Compactness.lean [COMPLETED]

**Goal**: The six verified theorems exist in the tree, reachable from the aggregator, with
`lake build` green and their axiom profiles captured.

**Tasks**:
- [ ] Read `specs/493_.../reports/01_compactness-and-strong-completeness.md` Appendix in full
      before writing any Lean.
- [ ] Create `FormalSystem/Metalogic/Compactness.lean` with the standard copyright header (match
      the header in `FormalSystem/Metalogic/SetConsequence.lean`), the three imports
      (`FormalSystem.Metalogic.StrongCompleteness`,
      `FormalSystem.Semantics.Ultraproduct.Los`,
      `FormalSystem.Semantics.Ultraproduct.IndexFilter`), the `open` lines from the probe, and a
      module docstring.
- [ ] Transcribe the six theorems verbatim from the report appendix: `modelExistenceBase`,
      `modelExistenceDense`, `compactBase`, `compactDense`, `strongCompletenessBase`,
      `strongCompletenessDense`.
- [ ] Confirm the three load-bearing elaboration details survive transcription: qualified
      `Ultraproduct.mk`; the `(⟨τ i, hτ i⟩ : (F i).HF)` ascription; the Dense `haveI` +
      `inferInstance`.
- [ ] Verify (do not assume) that `completeness_base` and `completeness_dense` are in scope from
      the `StrongCompleteness` import and resolve without a namespace reach; if not, fall back to
      the `BXCanonical.completeness` / `BXCanonical.completeness_dense` names, which have the same
      types.
- [ ] Confirm `strongCompletenessBase_of_compact` and `strongCompletenessDense_of_compact` are
      called WITH their `engine` argument and that their declarations in
      `StrongCompleteness.lean` are left untouched (parameters intact).
- [ ] Add `#print axioms` lines for all six theorems at the end of the module, matching the style
      of the existing block at the end of `StrongCompleteness.lean`.
- [ ] Write the module docstring with NO task-number citations (rule C9 / `.claude/rules/
      no-task-references-in-deliverables.md`) — cite declaration names and file paths instead.
- [ ] Add `import FormalSystem.Metalogic.Compactness` to `FormalSystem/Metalogic.lean` in the
      re-export block (alongside `DiscreteNonCompactness`, currently line 10).
- [ ] Run `lake build`; capture the literal `#print axioms` output for all six.
- [ ] Confirm `scripts/module-invariants-manifest.txt` was NOT modified.

**Timing**: 1.5 hours

**Depends on**: none

**Verification Tier**: full

**Scope Hypothesis**: This phase asserts exactly **six** new theorems in exactly **one** new file
plus a one-line import in `FormalSystem/Metalogic.lean`. Confirm at implementation time by
`grep -c '^theorem' FormalSystem/Metalogic/Compactness.lean` (expect 6) and
`git status --short` showing exactly two changed paths.

**Files to modify**:
- `FormalSystem/Metalogic/Compactness.lean` - NEW; six theorems, header, module docstring,
  `#print axioms` block
- `FormalSystem/Metalogic.lean` - one added import line in the re-export block

**Verification**:
- `lake build` exits 0
- `#print axioms` reports `[propext, Classical.choice, Quot.sound]` for all six and `sorryAx`
  appears in none
- `grep -n 'engine' FormalSystem/Metalogic/StrongCompleteness.lean` still shows the two
  reductions' parameters
- `bash scripts/check-module-invariants.sh` C6/C8 pass without a manifest entry

---

### Phase 2: Correct the in-tree Lean docstrings [COMPLETED]

**Goal**: No Lean docstring in `FormalSystem/` asserts these six are open, and the status
taxonomy reads consistently two-way across every mirror.

**Territory**: `FormalSystem/Metalogic/SetConsequence.lean`,
`FormalSystem/Metalogic/StrongCompleteness.lean`, `FormalSystem/Metalogic.lean` — and no other
files. Phase 1's `Compactness.lean` is complete and must not be re-edited here.

**Tasks**:
- [ ] `SetConsequence.lean`: correct the sites at approximately `:191`, `:200`, `:215`, `:237`,
      `:246`, `:281`, `:290`, and the section-header block at `:180`-`:205`. Re-derive every line
      number live — do not trust these.
- [ ] `StrongCompleteness.lean`: correct the sites at approximately `:84`, `:135`, `:335`,
      `:370`, `:418`, `:645`, `:689`, `:691`, `:746`-`:747`, `:805`, `:904`, `:909`.
- [ ] `StrongCompleteness.lean:294`-`:308`: **REFRAME, DO NOT DELETE.** The
      `deferralClosure`/`subformulaClosure` `Finset` obstruction argument explaining why the
      `BXCanonical` chronicle machinery structurally cannot reach `CompactBase` is still correct.
      Rewrite its framing from "why this is still open" to "why the ultraproduct route is what it
      is", and point forward to `FormalSystem/Metalogic/Compactness.lean`.
- [ ] `Metalogic.lean:106` (the three-status bullet list), `:156`, `:159`, `:164`-`:165`: collapse
      to the two-way taxonomy — Discrete **refuted**, Base and Dense **proved**, Dedekind
      **unavailable on its primary source's own terms**.
- [ ] `StrongCompleteness.lean:84`: same taxonomy, updated in lockstep with `Metalogic.lean:106`
      so the two mirrors never disagree.
- [ ] Where a docstring previously named an open obligation, name the discharging declaration in
      `FormalSystem.Metalogic.Compactness` instead.
- [ ] Write NO task numbers into any `FormalSystem/` file (rule C9).

**Timing**: 2 hours

**Depends on**: 1

**Verification Tier**: local

**Scope Hypothesis**: This phase asserts ~23 docstring sites across three files. A live count of
the phrase set (`open obligation|neither proved nor refuted|remaining obligation|undischarged|
still open`) currently returns 9 / 11 / 3 matching lines in `SetConsequence.lean` /
`StrongCompleteness.lean` / `Metalogic.lean`. Confirm at implementation time by re-running that
grep before and after; the after-count for these three files must be 0 except for lines that
correctly describe Dedekind or Discrete.

**Files to modify**:
- `FormalSystem/Metalogic/SetConsequence.lean` - docstring status corrections
- `FormalSystem/Metalogic/StrongCompleteness.lean` - docstring status corrections plus the
  `:294`-`:308` reframe
- `FormalSystem/Metalogic.lean` - module docstring taxonomy collapse

**Verification**:
- `lake build` exits 0 (docstring edits in Lean can break elaboration; this is why the tier is
  `local`, not `prose`)
- Re-grep of the phrase set over the three files returns only Dedekind/Discrete-scoped hits
- `:294`-`:308` argument is present and reframed, not removed

---

### Phase 3: Correct the documentation [COMPLETED]

**Goal**: README and `docs/` no longer describe Base/Dense compactness or strong completeness as
open, and the new module is documented.

**Territory**: `README.md`, `docs/**`, `FormalSystem/Metalogic/README.md` — and no other files.
No `.lean` file is edited in this phase.

**Tasks**:
- [ ] `README.md:165`: replace "**Base** and **Dense** — **open**. Neither proved nor refuted".
- [ ] `docs/project-info/known-limitations.md:37`, `:78`: table row and prose naming
      `CompactBase`/`CompactDense` as remaining work.
- [ ] `docs/project-info/implementation-status.md:68`: "`CompactBase`/`CompactDense` named as open
      obligations".
- [ ] `docs/user-guide/architecture.md:824`-`:827`, `:1090`: declaration table entries marking
      both as "an **open obligation**", and the module-tree comment; add
      `Metalogic/Compactness.lean` to the module tree.
- [ ] `docs/reference/API_REFERENCE.md:704`-`:707`: same table, "(**open**)"; add rows for the six
      new theorems.
- [ ] `docs/development/MODULE_ORGANIZATION.md:297`: "name the two open obligations".
- [ ] `FormalSystem/Metalogic/README.md:142`-`:144`: add a `Compactness.lean` row to the module
      table and correct the `StrongCompleteness.lean` line count (live value: 924).
- [ ] **Re-derive, do not copy, every `SetConsequence.lean` line-number citation.**
      `architecture.md` and `API_REFERENCE.md` currently cite `:211/:219/:256/:263`; the live
      values are `:209/:217/:255/:262`. Verify each against the file rather than transcribing
      either number.
- [ ] `FormalSystem/Semantics/README.md` needs no change (the `Ultraproduct/` row already exists);
      confirm rather than assume.
- [ ] Write no task numbers into any file under `docs/`, `README.md`, or
      `FormalSystem/*/README.md`.

**Timing**: 1.5 hours

**Depends on**: 1

**Verification Tier**: prose

**Scope Hypothesis**: This phase asserts **7** documentation files. Confirm at implementation time
with `grep -rln 'CompactBase\|CompactDense\|StrongCompletenessBase\|StrongCompletenessDense\|
ModelExistenceBase\|ModelExistenceDense' README.md docs/ FormalSystem/*/README.md`, which
currently returns six paths under `README.md`/`docs/` plus `FormalSystem/Metalogic/README.md`
(which needs the new row for a different reason — it does not currently name the declarations).
If the live list differs from the enumeration above, the enumeration is wrong, not the grep.

**Files to modify**:
- `README.md`
- `docs/project-info/known-limitations.md`
- `docs/project-info/implementation-status.md`
- `docs/user-guide/architecture.md`
- `docs/reference/API_REFERENCE.md`
- `docs/development/MODULE_ORGANIZATION.md`
- `FormalSystem/Metalogic/README.md`

**Verification**:
- Diff read-through confirming every changed hunk is prose/table text
- `bash scripts/readme-lint.sh` check 2 reports the `Compactness.lean` row present
- Every re-derived line-number citation matches the live file

---

### Phase 4: Paper-side record and author-memo retirement [COMPLETED]

**Goal**: The live paper record reflects that only mismatch item (i) remains, and the archived
author memo carries dated retirement notes rather than a rewritten history.

**Territory**: `specs/paper-definitions-of-record.md`,
`specs/archive/488_align_lean_code_and_docs_with_possible_worlds_paper/reports/02_author-memo.md`,
`typst/FormalFoundations.typ` — and no other files.

**Tasks**:
- [ ] `specs/paper-definitions-of-record.md:110` (`cor:tm-completeness` row): the mismatch is
      recorded as "Yes, twice". Item (ii) — the paper attributing TM⁺/TM⁺_d strong completeness to
      this repository "where both are **conditional** on the unproved `CompactBase`/
      `CompactDense`" — is now resolved. **Edit the row to show only item (i)** (the TM⁺_c /
      `FrameClass.Dedekind` mismatch) as live; do not delete the row.
- [ ] Author memo item **D1** (approximately `:29`): add a dated retirement note at the top of the
      item naming `FormalSystem.Metalogic.strongCompletenessBase` and
      `FormalSystem.Metalogic.compactBase` as the discharging declarations. Do not rewrite D1's
      body.
- [ ] Author memo item **D2** (approximately `:75`): same, naming
      `strongCompletenessDense` / `compactDense`.
- [ ] Author memo verification rows at approximately `:434`-`:435` (recording
      `Metalogic.CompactBase` / `Metalogic.CompactDense` as "`Prop` def, undischarged") and `:450`
      ("**Confirmed absent**: any declaration inhabiting `CompactBase` or `CompactDense`"): add a
      one-line dated correction under each. Both statements are now false; the corrections say so
      without editing the original rows.
- [ ] Use the current date on every retirement note; state the discharging module path
      (`FormalSystem/Metalogic/Compactness.lean`).
- [ ] `typst/FormalFoundations.typ:1454`: the Representation-theorem proof sketch calls the
      model-existence step "each instance of `StrongCompletenessBase`, `CompactBase`, and
      `ModelExistenceBase`". The `#leansrc` anchors at `:1484`-`:1486` pointing at
      `Metalogic.SetConsequence` remain valid (the declarations are still *defined* there), so
      leave them. Add a sentence recording that these are now theorems, not statements the proof
      would need.
- [ ] Confirm `specs/reviews/review-2026-08-25.md`,
      `review-2026-08-25-programme-status.md`, `review-2026-08-31-metalogic-systematicity.md`,
      and `specs/492_*/` were NOT touched.

**Timing**: 1 hour

**Depends on**: 1

**Verification Tier**: local

**Scope Hypothesis**: This phase asserts **3** files and **4** memo edit sites (D1, D2, the
`:434`-`:435` rows, the `:450` line). Confirm each site's live line number by grepping for its
quoted text rather than by line number; the memo is an archived file and its numbering has not
been verified against this plan's writing time.

**Files to modify**:
- `specs/paper-definitions-of-record.md` - `cor:tm-completeness` row, item (ii) resolved
- `specs/archive/488_align_lean_code_and_docs_with_possible_worlds_paper/reports/02_author-memo.md`
  - dated retirement notes on D1, D2, and the two verification rows
- `typst/FormalFoundations.typ` - one sentence at the Representation-theorem proof sketch

**Verification**:
- `typst compile typst/FormalFoundations.typ` succeeds (or the project's usual typst build
  invocation)
- `bash scripts/typst-sync-check.sh` and `bash scripts/typst-status-counts.sh` re-run clean
- `git status --short` shows exactly the three files above changed by this phase

---

### Phase 5: Gate wiring and acceptance [COMPLETED]

**Goal**: The axiom audit is a standing gate, every check is green, and the acceptance evidence is
captured literally.

**Tasks**:
- [ ] Add `strongCompletenessBase` and `strongCompletenessDense` to C14(ii) in
      `scripts/check-module-invariants.sh`. **Both heredocs must be edited together and in the
      same order**: append two `'FormalSystem.Metalogic.strongCompletenessBase' depends on axioms:
      [propext, Classical.choice, Quot.sound]`-shaped lines to the `C14BASE` heredoc, and the two
      matching `#print axioms FormalSystem.Metalogic.strongCompletenessBase` /
      `...strongCompletenessDense` lines to the `C14LEAN` heredoc, in the same relative order.
      `C14_OUT` is compared to `C14_BASELINE` by exact string equality, so order mismatch fails
      the gate.
- [ ] Run `bash scripts/check-module-invariants.sh` and confirm C14 passes with the enlarged
      baseline.
- [ ] Confirm C6 still passes and that `scripts/module-invariants-manifest.txt` remains
      unmodified.
- [ ] Run `lake build` from clean and capture the literal output.
- [ ] Capture literal `#print axioms` output for all six theorems as acceptance evidence.
- [ ] **Missed-site re-grep sweep**: grep the whole tree for the six declaration names and for
      `open obligation`, `neither proved nor refuted`, `remaining obligation`, `undischarged`,
      `**open**`, excluding `specs/reviews/`, `specs/492_*/`, `specs/493_*/reports/`, and
      `specs/archive/`. Every surviving hit must be either correct (Dedekind/Discrete-scoped) or
      fixed. Capture the sweep output.
- [ ] Grep that `strongCompletenessBase_of_compact` and `strongCompletenessDense_of_compact` still
      carry their `engine` parameters — task 509's work surface must be intact.
- [ ] Run `bash scripts/readme-lint.sh` and confirm no new findings.

**Timing**: 1 hour

**Depends on**: 2, 3, 4

**Verification Tier**: full

**Scope Hypothesis**: This phase asserts that C14 is the only gate needing a source edit
(C2/C3/C14(i)/C15 unaffected, C6 explicitly must NOT change). Confirm by running
`check-module-invariants.sh` before the C14 edit and observing that C14 is the only failure or
gap attributable to this task's new declarations.

**Files to modify**:
- `scripts/check-module-invariants.sh` - two lines in `C14BASE`, two in `C14LEAN`

**Verification**:
- `lake build` exits 0
- `bash scripts/check-module-invariants.sh` reports all gates pass, C14 included
- Re-grep sweep output contains no now-false status claim
- `#print axioms` for all six: `[propext, Classical.choice, Quot.sound]`, no `sorryAx`

---

## Testing & Validation

- [ ] `lake build` exits 0 with no new warnings
- [ ] `#print axioms` for `modelExistenceBase`, `modelExistenceDense`, `compactBase`,
      `compactDense`, `strongCompletenessBase`, `strongCompletenessDense` each report exactly
      `[propext, Classical.choice, Quot.sound]`; `sorryAx` absent from all six
- [ ] `bash scripts/check-module-invariants.sh` green, C14 passing against the enlarged baseline
- [ ] `bash scripts/readme-lint.sh` reports the `Compactness.lean` row present
- [ ] `bash scripts/typst-sync-check.sh` and `bash scripts/typst-status-counts.sh` clean
- [ ] `scripts/module-invariants-manifest.txt` unchanged
- [ ] Both `*_of_compact` reductions retain their `engine` parameters
- [ ] Tree-wide re-grep sweep shows no surviving "open obligation" claim about the six
      declarations
- [ ] No task-number citations introduced under `FormalSystem/`, `docs/`, `README.md`, or `typst/`

## Artifacts & Outputs

- `FormalSystem/Metalogic/Compactness.lean` (new, six theorems)
- `FormalSystem/Metalogic.lean` (one import)
- Prose corrections in `FormalSystem/Metalogic/SetConsequence.lean`,
  `FormalSystem/Metalogic/StrongCompleteness.lean`, `FormalSystem/Metalogic.lean`
- Prose corrections in `README.md`, `docs/project-info/known-limitations.md`,
  `docs/project-info/implementation-status.md`, `docs/user-guide/architecture.md`,
  `docs/reference/API_REFERENCE.md`, `docs/development/MODULE_ORGANIZATION.md`,
  `FormalSystem/Metalogic/README.md`
- `specs/paper-definitions-of-record.md` (item (ii) resolved)
- Author-memo dated retirement notes
- `typst/FormalFoundations.typ` (one sentence)
- `scripts/check-module-invariants.sh` (C14 baseline enlarged)
- `specs/493_discharge_compactbase_compactdense_and_strong_completeness/summaries/01_compactness-strong-completeness-summary.md`

## Rollback/Contingency

Each phase commits separately, so rollback is per-phase `git revert`.

- **Phase 1 fails to compile**: diff the transcription against the report appendix verbatim
  before touching any tactic — the appendix compiled against this exact library. The most likely
  transcription slips are an unqualified `mk`, a dropped `(⟨τ i, hτ i⟩ : (F i).HF)` ascription, or
  a missing `haveI`/`inferInstance` on the Dense branch.
- **Phase 1 blocked entirely**: the whole task blocks; phases 2-5 assert facts that are only true
  once Phase 1 lands. Do NOT land the prose corrections ahead of the proofs.
- **Phases 2-4 fail individually**: they are independent territories; revert only the failing one
  and proceed, marking that phase `[PARTIAL]`.
- **Phase 5 C14 edit fails the gate**: the failure output prints expected-vs-actual. Almost
  certainly a line-order mismatch between the two heredocs; reorder rather than re-baselining.
  Never "fix" C14 by replacing the baseline with observed output — the gate exists to catch
  exactly that.
