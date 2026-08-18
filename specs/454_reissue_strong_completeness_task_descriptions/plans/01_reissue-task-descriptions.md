# Implementation Plan: Task #454

- **Task**: 454 - reissue_strong_completeness_task_descriptions
- **Status**: [IMPLEMENTING]
- **Effort**: 6.5 hours
- **Dependencies**: 452
- **Research Inputs**: specs/454_reissue_strong_completeness_task_descriptions/reports/01_strong-completeness-reissue-research.md
- **Artifacts**: plans/01_reissue-task-descriptions.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

Re-issue the `state.json` descriptions of the six strong-completeness tasks (169, 362, 421, 422,
423, 424) so that every citation resolves against the live tree, task 424's Representation Theorem
is restated against total-history semantics, and 424's "gate" prose agrees with the declared
dependency graph. This is a description-only change: no Lean is written, no sorry is closed, no
task status moves, and no task's substance is re-scoped except 424's — whose re-scope is stated
explicitly with its rationale. Every `specs/state.json` write goes through
`.claude/scripts/state-write.sh`; `TODO.md` is regenerated once at the end, never hand-edited.
Done when all six descriptions carry symbol-primary anchors that resolve, 424 carries the
re-scoped theorem plus precise gate language, `362.dependencies` includes `424`, and all six
statuses are still `not_started`.

### Research Integration

The research report (`reports/01_strong-completeness-reissue-research.md`) settles all three
deliverables and this plan executes its recommendations rather than re-deriving them:

- **(a)** All nine cited drifts verified exactly correct against the live tree. Two more were found
  in task 422's own text (`cantor_bfmcs_dense_restricted_buc` cited `:680`, actual `:675`; `_fuc`
  cited `:755`, actual `:750` — the same -5 drift). Task 421's `CompletenessDedekind.lean:61-100`
  CarrierProbe anchor is confirmed still accurate and must NOT be "fixed."
- **(b)** Verdict delivered: the shift-set Representation Theorem **survives and simplifies** under
  total-history semantics. It loses the `Omega` parameter and the `ShiftClosed` hypothesis on both
  directions; `ShiftClosed` and the `Omega`-taking form of `time_shift_preserves_truth` are gone
  from `Truth.lean` entirely. It does **not** need its own research cycle. The report's
  "Recommended Text" section supplies drop-in replacement prose; Phase 7 applies it after
  re-verifying it against the live tree.
- **(c)** `state.json` already wires `454` as a dependency of 421/423/424 (an earlier partial
  dispatch), transitively blocking 422/169/362 — that half is done and consistent, and Phase 8
  only re-confirms it. What remains open is the forward direction: nothing depends on 424. The
  recommendation is to add `424` to **362's** dependencies only — **not** 423's, whose own
  description is explicit that it is vocabulary-only, proves no compactness result, and is
  self-contained — and to reword 424's "gate for the entire ultraproduct branch" language to name
  precisely what it gates.
- The description's "41 declared dependency edges" figure is stale (live: 44 unique / 102 raw).
  The re-issued text must not repeat "41" verbatim.

Two findings this plan adds on top of the report, both discovered while sizing the phases:

- The "nine anchors" table **undercounts** the drifted-citation surface. `Transfer.lean:1242` (the
  sorry) is cited in task **421**'s text ("do not touch the sorry at `:1242`") and in task
  **422**'s acceptance clause ("does NOT close the `Transfer.lean:1242` sorry"), not only in 169's.
  Task **362** carries roughly eighteen further line citations that the original table never
  examined; spot-checking already found drift among them (`completeness_dense` cited `:255`, actual
  `:250`; `completeness_discrete` cited `:296`, actual `:291`; `SemanticConsequence` cited
  `Validity.lean:103`, actual `:125`; its notation cited `:114`, actual `:135`; the `Type`-not-
  `Type*` note cited `:77`, actual `:92`).
- Verification criterion 5 of the task description ("Every file:line or symbol reference in **all
  six** re-issued descriptions resolves in the live tree") is therefore materially broader than
  deliverable (a)'s nine-row table. Phase 1 exists to close that gap before any description is
  rewritten.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No `roadmap_path` supplied in the delegation context; no ROADMAP.md consulted.

## Goals & Non-Goals

**Goals**:
- Re-anchor every drifted citation across all six descriptions by fully-qualified symbol name as
  the primary reference, with line numbers demoted to explicitly non-load-bearing hints.
- Produce a verified citation ledger covering **every** file:line/symbol reference in all six
  descriptions, not only the eleven already known to have drifted.
- Re-issue task 424 with the re-scoped, `Omega`-free Representation Theorem, with `ShiftClosed`
  recorded as retired (not renamed), and with its "gate" language narrowed to what it concretely
  gates.
- Add `424` to task 362's `dependencies`, with prose in both 362 and 424 recording that the edge is
  about leg B specifically.
- Leave all six tasks at `not_started` with their substance (except 424's) unchanged.

**Non-Goals**:
- Proving anything, closing any sorry, or writing any Lean.
- Starting, planning, or dispatching 169, 362, 421, 422, 423, or 424.
- Re-scoping 169, 362, 421, 422, or 423 beyond re-anchoring.
- Adding a `424` dependency edge to 423.
- Creating tasks S2-S5 (the ultraproduct branch), which 424's own text keeps unauthorized.
- Hand-editing `specs/TODO.md`.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Re-issued text reintroduces load-bearing line numbers that drift again on the next unrelated edit | M | M | Symbol-primary convention is mandatory in every phase; any retained line number is written as a parenthetical hint with explicit "re-verify before use" wording |
| A `state-write.sh` jq filter mangles a long multi-line description (backticks, unicode, `->`, `$`) through shell quoting | H | M | Never inline description text in the filter. Stage each new description in a scratch file and bind it with `--arg desc "$(cat FILE)"`; verify byte-for-byte with a post-write `jq -r ... \| diff - FILE` |
| A phase silently changes a task's `status`, `dependencies`, or other fields alongside the description | H | L | Phase 8 diffs a pre-flight snapshot of all six task records against the post-flight state; only 362's `dependencies` and the six `description` fields may differ |
| Phase 1's sweep finds a cited symbol that is *deleted*, not merely drifted, forcing a re-scope beyond mandate | M | L | Record it in the ledger as an ESCALATION row, do not silently rewrite the surrounding scope; report it in the summary and leave the affected clause flagged rather than invented |
| Adding `424 -> 362` makes orchestration treat all of 362 (legs A/C/D, which do not need 424) as blocked on a high-effort gate | M | M | Edge is added with explicit "leg B only" prose in 362's description text; the edge itself cannot express partiality, so the prose carries it |
| Parallel wave-2 phases race on `specs/state.json` | M | L | `state-write.sh` is the single mutex-guarded writer and is fail-closed; additionally, no wave-2 phase passes `--regen-todo` (TODO regeneration is last-writer-wins and is deferred to Phase 8) |
| Re-issued 424 text drifts from the live tree between research (2026-08-18) and implementation | M | L | Phase 7 re-verifies every symbol in the Recommended Text against the live tree before applying it, and treats the report text as a draft to confirm, not a fact to paste |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 3, 4, 5, 6, 7 | 1 |
| 3 | 8 | 2, 3, 4, 5, 6, 7 |

Phases within the same wave can execute in parallel. Each wave-2 phase owns exactly one
`project_number` record in `specs/state.json` and touches no other — that is the territory
contract for parallel execution.

---

### Phase 1: Build the verified citation ledger [COMPLETED]

**Goal**: Enumerate every file:line and symbol citation appearing in all six descriptions, verify
each against the live tree, and record the verified symbol-primary replacement for each. This is
the single source of truth every later phase copies from, so no later phase re-derives a line
number.

**Tasks**:
- [x] Snapshot the six task records for later diffing:
      `jq '[.active_projects[] | select(.project_number | IN(169,362,421,422,423,424))]' specs/state.json > specs/454_reissue_strong_completeness_task_descriptions/.pre-reissue-snapshot.json`
- [x] Dump each description to a scratch file: for `N` in 169 362 421 422 423 424,
      `jq -r --argjson n $N '.active_projects[]|select(.project_number==$n)|.description' specs/state.json > SCRATCH/$N-desc.orig.txt`
- [x] Extract every citation from each dump (`grep -nE '\.(lean|tex)[:0-9-]*|:[0-9]{2,}'`) and
      enumerate them into a table with columns: task, cited file, cited line(s), symbol, verified
      actual location, status (`ACCURATE` / `DRIFTED` / `DELETED` / `NO-LINE`).
- [x] Verify each row against the live tree by symbol, using `grep -n` on the declaration keyword
      (`^theorem`, `^def`, `^lemma`, `^section`) rather than trusting the cited line. Confirm the
      eleven already-known rows and resolve every row the research did not examine.
- [x] Confirm the CarrierProbe anchor in 421 (`CompletenessDedekind.lean`, `section CarrierProbe`,
      actual `:69-105`) is marked `ACCURATE — DO NOT CHANGE THE CLAIM`, with the re-anchor being a
      switch to symbol-primary form only.
- [x] For every `DRIFTED` or `ACCURATE` row, write the exact replacement citation string in
      symbol-primary form, e.g.
      `` `box_dense_gives_density` (`FormalSystem/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodelBasic.lean`; currently near :430, hint only — re-verify by symbol before use) ``
- [x] For any `DELETED` row, add an ESCALATION note (what was cited, what is gone, which clause
      depends on it) instead of inventing a replacement.
- [x] Write the ledger to
      `specs/454_reissue_strong_completeness_task_descriptions/reports/02_citation-ledger.md`.

**Timing**: 1.0 hour

**Depends on**: none

**Verification Tier**: prose

**Scope Hypothesis**: The research names 11 drifted anchors (9 from the original table plus 422's
`_buc`/`_fuc`). This plan hypothesizes the true drifted count is materially higher — at least 5
more in 362 (`completeness_dense`, `completeness_discrete`, `SemanticConsequence` and its notation,
the `Type`-not-`Type*` note) plus the two extra `Transfer.lean:1242` occurrences in 421 and 422 —
and that the total citation surface across the six descriptions is roughly 45 references. Confirm
by completing the enumeration above and reporting the actual counts (total citations, ACCURATE,
DRIFTED, DELETED) in the ledger; do not carry these numbers forward as facts.

**Files to modify**:
- `specs/454_reissue_strong_completeness_task_descriptions/reports/02_citation-ledger.md` - new;
  the verified ledger
- `specs/454_reissue_strong_completeness_task_descriptions/.pre-reissue-snapshot.json` - new;
  pre-flight snapshot of the six task records for the Phase 8 diff

**Verification**:
- Ledger has one row per citation extracted by the grep sweep; no extracted citation is unrowed.
- Every non-`NO-LINE` row's "verified actual location" was produced by a symbol grep, with the
  command recorded in the ledger appendix.
- The eleven rows already verified by the research match the research's values; any mismatch is
  called out explicitly (the tree may have moved since 2026-08-18).

---

### Phase 2: Re-issue task 423 [NOT STARTED]

**Goal**: Re-anchor 423's `Validity.lean` citations by symbol. 423's substance (vocabulary-only,
self-contained, proves no compactness result) is unchanged, and 423 does **not** gain a `424`
dependency.

**Tasks**:
- [ ] Copy `SCRATCH/423-desc.orig.txt` to `SCRATCH/423-desc.new.txt` and edit only the citation
      strings, using the Phase 1 ledger rows for 423.
- [ ] Rewrite the acceptance clause "each `SetSemanticConsequence*` binder list is byte-comparable
      to its `Validity.lean` source (`valid :79`, `ValidDense :169`, `ValidDiscrete :187`,
      `ValidDedekindDense :276`)" so the four sources are named by symbol, with line numbers either
      dropped or demoted to hints. The byte-comparability criterion itself stays.
- [ ] Re-anchor the `Validity.lean:77` reference (the "uses `Type` not `Type*`, deliberate" note) to
      its verified location by symbol/quoted-note, per the ledger.
- [ ] Apply with:
      `.claude/scripts/state-write.sh '(.active_projects[] | select(.project_number == 423) | .description) = $desc' --session-id sess_1787033965_d6c07f_454 --arg desc "$(cat SCRATCH/423-desc.new.txt)"`
      (no `--regen-todo`).
- [ ] Confirm round-trip:
      `jq -r '.active_projects[]|select(.project_number==423)|.description' specs/state.json | diff - SCRATCH/423-desc.new.txt`

**Timing**: 0.5 hours

**Depends on**: 1

**Verification Tier**: local

**Scope Hypothesis**: 423's description is expected to carry 5 citations (4 `Validity.lean`
definitions plus the `Type`/`Type*` note), all in a single acceptance sentence. Confirm against the
Phase 1 ledger's 423 rows before editing; if the ledger shows more, handle all of them in this
phase.

**Files to modify**:
- `specs/state.json` - `active_projects[project_number==423].description` only

**Verification**:
- `jq empty specs/state.json` passes.
- Round-trip diff is empty.
- `jq -r '.active_projects[]|select(.project_number==423)|"\(.status) \(.dependencies)"'` is
  unchanged from the Phase 1 snapshot (`not_started`, `[361,454]`).
- No bare `Validity.lean:` line reference remains as a primary anchor.

---

### Phase 3: Re-issue task 421 [NOT STARTED]

**Goal**: Re-anchor 421's `Transfer.lean` citations (including the two `:1239-1241` occurrences and
the `:1242` sorry reference), switch the CarrierProbe anchor to symbol-primary form without
changing its claim, and re-verify the Mathlib citation.

**Tasks**:
- [ ] Re-anchor deliverable (a)'s `Transfer.lean:1239-1241` (refuted route-(i) guidance; actual
      `:1081-1083`) by quoting the comment's opening text as the anchor — "the `(i) a Base-MCS ...
      (ii) a Henkin-style ...` comment block in `FormalSystem/Metalogic/WeakCanonical/Transfer.lean`"
      — with the line range as a hint only.
- [ ] Re-anchor the same range where it recurs in the Acceptance clause ("the refuted-route comment
      no longer appears at `Transfer.lean:1239-1241`") to the same symbol-primary form.
- [ ] Re-anchor "do not touch the sorry at `:1242`" to `` the `sorry` inside
      `WeakCanonical.countermodel_discrete` `` (declaration start currently `:1068`, sorry token
      currently `:1084` — hints only). Note this occurrence is **not** in the original nine-row
      table.
- [ ] Convert the CarrierProbe reference to `` the `section CarrierProbe` block in
      `FormalSystem/Metalogic/BXCanonical/CompletenessDedekind.lean` `` (currently `:69-105`, hint
      only). Do not restate `:61-100` as if load-bearing and do not change what the clause claims —
      it was verified still accurate.
- [ ] Re-verify the `Mathlib/Algebra/Order/Monoid/Prod.lean:52-59` citation per the ledger and
      re-anchor by declaration name (`Lex.isOrderedMonoid`).
- [ ] Leave the sorry-count acceptance clause ("live non-Boneyard sorry count is unchanged at 2")
      intact — it is a scope claim, not an anchor, and re-scoping 421 is a non-goal. If the ledger
      shows the count is now different, flag it in the summary rather than editing the claim.
- [ ] Apply via `state-write.sh` with `--arg desc "$(cat SCRATCH/421-desc.new.txt)"` (no
      `--regen-todo`), then round-trip diff.

**Timing**: 0.5 hours

**Depends on**: 1

**Verification Tier**: local

**Scope Hypothesis**: 421's description is expected to carry 5 distinct citations
(`Transfer.lean:1239-1241` twice, `Transfer.lean:1242`, `CompletenessDedekind.lean:61-100`, Mathlib
`Prod.lean:52-59`). Confirm against the ledger's 421 rows before editing.

**Files to modify**:
- `specs/state.json` - `active_projects[project_number==421].description` only

**Verification**:
- `jq empty specs/state.json` passes; round-trip diff empty.
- `status` still `not_started`, `dependencies` still `[361,448,454]`.
- The CarrierProbe clause's claim is textually unchanged apart from the anchor form.

---

### Phase 4: Re-issue task 422 [NOT STARTED]

**Goal**: Re-anchor 422's six citations, including the two `_buc`/`_fuc` anchors the original
nine-row table missed, and the `Transfer.lean:1242` occurrence in its acceptance clause.

**Tasks**:
- [ ] Re-anchor `box_dense_gives_density` (cited `ChronicleToCountermodelBasic.lean:435`, actual
      `:430`) by symbol.
- [ ] Re-anchor `cantor_bfmcs_dense_restricted_tc` (cited `:629`, actual `:624`) by symbol.
- [ ] Re-anchor `cantor_bfmcs_dense_restricted_buc` (cited `:680`, actual `:675`) and `_fuc` (cited
      `:755`, actual `:750`) by symbol — these two are the research's "beyond the nine" finding.
- [ ] Re-anchor the `valid` / `Validity.lean:79` reference in the "why this carrier and not Z"
      paragraph by symbol (actual `:94`); the "no `IsSuccArchimedean` binder" observation is
      re-verified by the ledger, not re-derived here.
- [ ] Re-anchor the acceptance clause's `Transfer.lean:1242` to
      `` `WeakCanonical.countermodel_discrete`'s sorry `` (hints only).
- [ ] Update the "FOUR-AXIOM / TOTALITY EXPOSURE NOTE (added 2026-08-10)" only to the extent that it
      states a now-settled fact: tasks 414/420 have landed and are archived, so the note's
      instruction to "re-verify against the refactored signatures" has been discharged for the
      `Validity.lean` citation by this re-issue. Record that discharge in one sentence. Do **not**
      re-scope the note's four-axiom obligations — 422's substance is out of scope.
- [ ] Apply via `state-write.sh` (no `--regen-todo`), then round-trip diff.

**Timing**: 0.5 hours

**Depends on**: 1

**Verification Tier**: local

**Scope Hypothesis**: 422's description is expected to carry ~7 citations
(`ChronicleToCountermodelBasic.lean` x4, `cantorIsoDense` with no line, `Validity.lean:79`,
`Transfer.lean:1242`). Confirm against the ledger's 422 rows before editing.

**Files to modify**:
- `specs/state.json` - `active_projects[project_number==422].description` only

**Verification**:
- `jq empty specs/state.json` passes; round-trip diff empty.
- `status` still `not_started`, `dependencies` still `[414,420,421,439,448]`.
- All four `ChronicleToCountermodelBasic` lemma references are symbol-primary.

---

### Phase 5: Re-issue task 169 [NOT STARTED]

**Goal**: Re-anchor 169's `Transfer.lean`, `Completeness.lean`, `Validity.lean`, and
`ChronicleToCountermodelBasic.lean` citations, keeping the CORRECTED SCOPE narrative and the
route (i)/(ii)/(iii) verdicts textually intact.

**Tasks**:
- [ ] Re-anchor `theorem completeness` (cited `Completeness.lean:196`, actual `:191`) by symbol,
      noting explicitly that the file has **two** declarations named `completeness` (a second at
      `:26`), so the symbol anchor must say which — the one at the file's Base-class terminus,
      `valid φ → Derivable FrameClass.Base [] φ`.
- [ ] Re-anchor both occurrences of `Transfer.lean:1242` to
      `` `WeakCanonical.countermodel_discrete` `` (declaration currently `:1068`, sorry token
      currently `:1084` — hints only). Preserve the machine-verified claim ("`#print axioms
      completeness` = [propext, sorryAx, Classical.choice, Quot.sound], sole `sorryAx` source")
      unchanged in substance; only its anchor moves.
- [ ] Re-anchor `countermodel_dense_enriched` (`Completeness.lean:133`, called at `:221`) and
      `Chronicle.mcs_mixed_case_absurd` (`MCSMixedCase.lean`, called from `Completeness.lean:231`)
      per the ledger.
- [ ] Re-anchor `box_dense_gives_density` (`ChronicleToCountermodelBasic.lean:435`) and `valid`
      (`Validity.lean:79`) by symbol.
- [ ] Leave the route (i)/(ii)/(iii) verdicts, the `ℤ ×ₗ ℤ` witness, and the DEPENDENCIES paragraph
      untouched in substance.
- [ ] Apply via `state-write.sh` (no `--regen-todo`), then round-trip diff.

**Timing**: 0.75 hours

**Depends on**: 1

**Verification Tier**: local

**Scope Hypothesis**: 169's description is expected to carry ~8 citations. Confirm against the
ledger's 169 rows before editing; the duplicate-`completeness`-declaration hazard above must be
confirmed by grep before the disambiguating wording is written.

**Files to modify**:
- `specs/state.json` - `active_projects[project_number==169].description` only

**Verification**:
- `jq empty specs/state.json` passes; round-trip diff empty.
- `status` still `not_started`, `dependencies` still `[361,422,448]`.
- No line number in the re-issued text is presented as a primary anchor.

---

### Phase 6: Re-issue task 362 and wire the 424 dependency edge [NOT STARTED]

**Goal**: Re-anchor 362's large citation block (the widest surface of the six) and add `424` to its
`dependencies`, with prose recording that the edge exists for leg B specifically.

**Tasks**:
- [ ] Re-anchor the "REFERENCE MAP" bullets by symbol: `completeness` / `completeness_dense`
      (cited `:255`, actual `:250`) / `completeness_discrete` (cited `:296`, actual `:291`) in
      `BXCanonical/Completeness.lean`; `valid` / `ValidDense` / `ValidDiscrete` in `Validity.lean`;
      `Derivable` (`ProofSystem/Derivable.lean:69`); `Derivable.deduction`, `deductionTheorem`,
      `deductionConverse` in `Metalogic/Core/DeductionTheorem.lean`; `SetConsistent` /
      `SetMaximalConsistent` / `set_lindenbaum` in `Metalogic/Core/MaximalConsistent.lean`;
      `SemanticConsequence` (cited `Validity.lean:103`, actual `:125`) and its `Γ ⊨ φ` notation
      (cited `:114`, actual `:135`).
- [ ] Re-anchor the leg (D) LaTeX citations (`latex/subfiles/04-Metalogic.tex`,
      `main_strong_completeness` at `:266`, identifier also at `:211`, `:490`) by identifier per the
      ledger.
- [ ] Add one sentence to leg (B) recording the new dependency and its narrow scope: leg B — and
      only leg B — is gated on task 424's shift-set Representation Theorem; legs A, C, and D do not
      depend on it, and the declared edge cannot express that partiality, which is why it is stated
      here in prose. Do not otherwise re-scope any leg.
- [ ] Apply the description with `state-write.sh` (no `--regen-todo`), then round-trip diff.
- [ ] Apply the dependency edge as a **separate** `state-write.sh` call:
      `.claude/scripts/state-write.sh '(.active_projects[] | select(.project_number == 362) | .dependencies) = $deps' --session-id sess_1787033965_d6c07f_454 --argjson deps '[361,375,169,170,424]'`
- [ ] Confirm `423`'s dependencies were **not** touched (they must remain `[361,454]`) — the
      research is explicit that 423 is self-contained and must not gain a `424` edge.

**Timing**: 1.0 hour

**Depends on**: 1

**Verification Tier**: interface

**Scope Hypothesis**: 362's description is expected to carry ~18 citations across the REFERENCE MAP
and leg (D) — by far the largest surface of the six, and one the original nine-row table never
examined. Confirm the actual count against the ledger's 362 rows before editing, and treat any row
the ledger marks `DELETED` as an escalation rather than a rewrite.

**Files to modify**:
- `specs/state.json` - `active_projects[project_number==362].description` and `.dependencies`

**Verification**:
- `jq empty specs/state.json` passes; round-trip diff empty.
- `jq -r '.active_projects[]|select(.project_number==362)|.dependencies'` is `[361,375,169,170,424]`.
- `jq -r '.active_projects[]|select(.project_number==423)|.dependencies'` is still `[361,454]`.
- `status` still `not_started`.
- Every `.lean` and `.tex` reference in the new text is symbol-primary.

---

### Phase 7: Re-issue task 424 (re-scope against total-history semantics) [NOT STARTED]

**Goal**: Replace 424's forward-looking `Omega`-exposure audit with the settled post-refactor
verdict, state the re-scoped Representation Theorem, retire `ShiftClosed` explicitly, and narrow
the "gate" language to what 424 concretely gates. This is the only phase that changes a task's
scope, and it does so explicitly with its rationale, as the task description requires.

**Tasks**:
- [ ] **Re-verify before applying**: confirm against the live tree that `TruthAt` still takes no
      `Omega` parameter and that its box clause quantifies over `σ.IsTotal`; that `ShiftClosed` has
      zero occurrences in `FormalSystem/Semantics/Truth.lean`; that
      `time_shift_preserves_truth` has signature `(M) (σ) (x y : D) (φ)` with no `h_sc`; and that
      `WorldHistory.isTotal_timeShift` exists with no side condition. Treat the report's
      Recommended Text as a draft to confirm, not a fact to paste.
- [ ] Rewrite sections 1-3 (the 2026-08-10 exposure audit): the predicted refactor **has landed and
      is archived**, so the forward-looking risk language becomes a settled statement of what
      changed. Keep the audit's own conclusion that the model-theoretic argument survives.
- [ ] Replace the section 6 Representation Theorem statement with the re-scoped, `Omega`-free
      version (the report's "Recommended Text" for 424, verified against the live tree in the first
      step): forward direction builds `WorldState := Ω`, `TaskRel w d u := (u = sh w d)`,
      `states σ t := sh σ t`, `domain := Set.univ`, and now carries one small new obligation —
      proving the constructed frame's total-history set equals the shift-orbit range, a consequence
      of `TaskRel`'s functionality; reverse direction takes `Ω := {τ : WorldHistory F // τ.IsTotal}`
      from `(F, M)` alone, `sh σ Δ := σ.val.timeShift Δ` landing in `Ω` unconditionally via
      `WorldHistory.isTotal_timeShift`, and `A p σ := TruthAt M σ.val 0 (atom p)`.
- [ ] Record the verdict explicitly: the theorem **survives and simplifies** — it loses the `Omega`
      parameter and the `ShiftClosed` hypothesis on both directions, gains no new hypothesis, and
      does **not** require its own research cycle. State that this is the totality-fixed special
      case the 2026-08-10 audit already predicted.
- [ ] State that `ShiftClosed` is **retired, not renamed** — the definition no longer exists and no
      future implementer should go looking for it. Delete the `Truth.lean:333` `ShiftClosed`
      citation outright.
- [ ] Re-anchor the surviving Lean citations by symbol: `TruthAt` (cited `Truth.lean:128-137`,
      currently `:159-167`) and `time_shift_preserves_truth` (cited `Truth.lean:446`, currently
      `:457`). Re-anchor or drop the `Validity.lean:77-139` citation per the ledger.
- [ ] Replace "THIS TASK IS THE GATE FOR THE ENTIRE ULTRAPRODUCT BRANCH" with precise language: it
      gates (i) authorization to create tasks S2-S5, which deliberately do not exist yet and so
      cannot carry a declared edge, and (ii) leg B of task 362 specifically — which is
      edge-representable and is wired in Phase 6. It does **not** gate 423, which is self-contained
      and proves no compactness result. Keep the "NOT AUTHORIZED / do not spawn S2-S5" instruction.
- [ ] Confirm the untouched remainder still holds: Q1's structural evidence, Route B's S1-S4 plan,
      risks R1-R3, the GATING RULE, the gate-passed evidence standard, the cancel condition, and the
      corrected `specs/archive/361_.../design/02_compactness-route.md` path. R4's shift-closure
      concern is recorded as having no remaining attachment point.
- [ ] Do not repeat the stale "41 declared dependency edges" figure anywhere; if an edge count is
      wanted at all, either omit it or state the freshly measured value with its measurement date.
- [ ] Apply via `state-write.sh` (no `--regen-todo`), then round-trip diff.

**Timing**: 1.5 hours

**Depends on**: 1

**Verification Tier**: local

**Scope Hypothesis**: 424's description is expected to carry 4 Lean citations (`Truth.lean:128`,
`Truth.lean:128-137`, `Truth.lean:446`, `Validity.lean:77-139`) plus the `ShiftClosed`
`Truth.lean:333` citation slated for deletion, and to be the longest of the six (~9,000 characters).
Confirm against the ledger's 424 rows before editing.

**Files to modify**:
- `specs/state.json` - `active_projects[project_number==424].description` only

**Verification**:
- `jq empty specs/state.json` passes; round-trip diff empty.
- `status` still `not_started`, `dependencies` still `[361,414,439,454]`.
- The string `ShiftClosed` appears only in the "retired, not renamed" sentence — never as a
  hypothesis of the stated theorem or as a citation.
- No `Omega` Lean *parameter* is asserted to exist; the paper-facing shift-set carrier `Ω` remains,
  with the naming coincidence disentangled as the 2026-08-10 audit did.
- The phrase "GATE FOR THE ENTIRE ULTRAPRODUCT BRANCH" no longer appears.

---

### Phase 8: Verify, regenerate, and record [NOT STARTED]

**Goal**: Prove the whole re-issue satisfies the task's five verification criteria, regenerate the
derived views once, and write the summary.

**Tasks**:
- [ ] `jq empty specs/state.json` and a full re-read of all six descriptions.
- [ ] Diff the post-flight six task records against `.pre-reissue-snapshot.json`. Assert that the
      only differing fields are the six `description` strings and `362.dependencies`. Any other
      differing field is a defect to fix before proceeding.
- [ ] Assert all six statuses are `not_started`.
- [ ] Re-run the citation sweep over the **re-issued** descriptions and confirm every remaining
      file:line/symbol reference resolves in the live tree (task verification criterion 5). Record
      the pass in the summary.
- [ ] Confirm the string `41 declared dependency edges` (and a bare "41" used as an edge count) does
      not appear in any re-issued description.
- [ ] Re-confirm the already-wired half of deliverable (c): `454` is still in the dependencies of
      421, 423, and 424.
- [ ] Regenerate `TODO.md` once: `.claude/scripts/generate-todo.sh` (or a final `state-write.sh`
      no-op-style call with `--regen-todo`). Do not hand-edit `TODO.md`.
- [ ] Run `.claude/scripts/generate-task-order.sh` and confirm 424 now orders in a strictly earlier
      wave than 362, and that no dependency reference dangles.
- [ ] Write `specs/454_reissue_strong_completeness_task_descriptions/summaries/01_reissue-task-descriptions-summary.md`
      recording: per-task anchor changes applied, the 424 verdict, the edge added, the actual
      citation counts measured in Phase 1 (confirming or correcting each phase's Scope Hypothesis),
      and any ESCALATION rows left unresolved.

**Timing**: 0.75 hours

**Depends on**: 2, 3, 4, 5, 6, 7

**Verification Tier**: full

**Files to modify**:
- `specs/TODO.md` - regenerated
- `specs/454_reissue_strong_completeness_task_descriptions/summaries/01_reissue-task-descriptions-summary.md` - new

**Verification**:
- Snapshot diff shows exactly the seven intended field changes and nothing else.
- `generate-task-order.sh` places 424 before 362 and reports zero dangling references.
- Every citation in every re-issued description resolves.

---

## Testing & Validation

- [ ] `jq empty specs/state.json` passes after every write.
- [ ] Round-trip diff (`jq -r ... | diff - SCRATCH/N-desc.new.txt`) is empty for each of the six
      tasks — proving no shell-quoting corruption of backticks, unicode, or `$`.
- [ ] All six tasks remain `status: not_started`.
- [ ] Only `362.dependencies` changed among all dependency arrays; 423's is untouched.
- [ ] Every file:line/symbol reference in all six re-issued descriptions resolves in the live tree.
- [ ] `generate-task-order.sh` orders 424 strictly before 362, with zero dangling references.
- [ ] `TODO.md` is regenerated by script, and `git diff --stat specs/TODO.md` shows only
      regeneration-consistent changes.
- [ ] No Lean file is modified: `git status --porcelain FormalSystem/ Tests/` is empty.

## Artifacts & Outputs

- `specs/454_reissue_strong_completeness_task_descriptions/plans/01_reissue-task-descriptions.md` (this file)
- `specs/454_reissue_strong_completeness_task_descriptions/reports/02_citation-ledger.md`
- `specs/454_reissue_strong_completeness_task_descriptions/.pre-reissue-snapshot.json`
- `specs/454_reissue_strong_completeness_task_descriptions/summaries/01_reissue-task-descriptions-summary.md`
- `specs/state.json` — six `description` fields plus `362.dependencies`
- `specs/TODO.md` — regenerated

## Rollback/Contingency

- `.pre-reissue-snapshot.json` (written in Phase 1) holds the exact pre-change records for all six
  tasks. To revert any single task, re-apply its snapshot description via `state-write.sh` with
  `--arg desc "$(jq -r '.[]|select(.project_number==N)|.description' .pre-reissue-snapshot.json)"`;
  to revert the edge, set `362.dependencies` back to `[361,375,169,170]`.
- All changes are confined to `specs/state.json` and generated/`specs/`-local artifacts, so
  `git checkout -- specs/state.json specs/TODO.md` is a complete whole-task rollback provided no
  unrelated `state.json` write has interleaved. Prefer the per-task snapshot restore when other
  sessions are active.
- If Phase 1 surfaces a `DELETED` citation whose surrounding clause cannot be re-anchored without
  re-scoping a task other than 424, leave that clause unedited, mark the phase
  `[COMPLETED WITH EXCLUSIONS]` with a `#### Reasoned Exclusions` record, and report the escalation
  — do not invent a replacement and do not re-scope out of mandate.
