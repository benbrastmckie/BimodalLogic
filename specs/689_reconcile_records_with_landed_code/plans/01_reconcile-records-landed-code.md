# Implementation Plan: Task #689

- **Task**: 689 - Reconcile records with landed code
- **Status**: [IMPLEMENTING]
- **Effort**: 4.25 hours
- **Dependencies**: None (all four source tasks are complete and committed)
- **Research Inputs**: `specs/689_reconcile_records_with_landed_code/reports/01_reconcile-records-landed-code.md`
- **Artifacts**: plans/01_reconcile-records-landed-code.md (this file)
- **Standards**:
  - `.claude/context/formats/plan-format.md`
  - `.claude/context/standards/status-markers.md`
  - `.claude/rules/artifact-formats.md`
  - `.claude/rules/no-task-references-in-deliverables.md`
  - `.claude/rules/plan-compliance.md` (Statement Fidelity)
  - `.claude/rules/state-management.md`
- **Type**: lean4
- **Lean Intent**: false

## Overview

Four durable records disagree with the landed tree, each discovered by an implementation that
found its own plan or a sibling's report wrong. No code defect is involved and no theorem
statement or proof changes: every edit lands in a docstring, a markdown file, one other task's
plan file, or a generated manifest. The four records are independent of one another, so the
four authoring phases are a single parallel wave, followed by one regeneration phase for the
machine-owned records the Lean edits invalidate and one full-gate phase. Done means: each of the
four records says what the code says, the no-consolidation decision is stated in both
independence modules, and every mechanical gate in the repository is green.

### Research Integration

The research report confirmed all four records verbatim against the landed tree and narrowed
each gap:

- **Record 1** — the three false pinned statements are real; the landed forms are
  `unescapeBody (escapeBody s ++ ['"'])`, and `parseCJson_printCJson` /
  `parseCJson_fuel_sufficient` each with an added `(hrest : NoDigitHead rest)`. A *fourth*
  divergence (`parseDigits_printDigits`'s `¬ c.isDigit` versus `¬ (c.isDigit = true)`) exists but
  is **not** a correction — the recorded plan's own third note pre-authorised that spelling, and
  the amendment must not present it as one.
- **Record 2** — the *new* module (`FormalSystem/SourceLanguage/Sentence.lean`) already states the
  non-injectivity exhaustively and needs no edit; so does `BimodalTools/README.md`. The gap is
  entirely on the *precedent*, `FormalSystem/MinusLanguage/Translation.lean`, which says
  injectivity is "cheap" without saying why, and so reads as a general property of a translation
  module.
- **Record 3** — the duplication is recorded honestly in four places; what is missing is the
  *decision* and the reciprocal pointer. `ConstraintWitnesses.lean` contains zero occurrences of
  `FrameConstraintIndependence`. Both consolidation directions were checked and both rejected
  (see Goals/Non-Goals and Phase 3).
- **Record 4** — `Tests/fixtures/README.md` already states most of the convention; the rejected
  alternative is recorded only in a task summary, and no directory tree a plan author consults
  mentions `Tests/fixtures/` at all — which is the mechanism by which the misplacement happened.

**One correction to the research report, established while planning this file.** The report
records the `FormalSystem/Semantics/StateTopology/README.md` line-count row as "Not gated by
`readme-lint.sh`". That is true of `readme-lint.sh` but the row is nevertheless **enforced**: it
sits inside a `<!-- BEGIN GENERATED: inventory dir=... -->` block, and
`scripts/check-module-invariants.sh`'s `INV` check fails on any stale generated block
(`FAIL INV %d file(s) carry a stale generated inventory block`). Three such blocks are affected by
this task's Lean edits — `FormalSystem/Semantics/StateTopology/README.md:15`,
`FormalSystem/MinusLanguage/README.md:24`, and the root `README.md:19`
(`dir=FormalSystem rows=totals`). Regeneration via
`bash scripts/check-module-invariants.sh --emit-inventory` is therefore a **mandatory gate**
alongside C35, not the optional courtesy the report's Risks section framed it as. Phase 5 owns
both.

### Prior Plan Reference

No prior plan. This is round 1.

### Roadmap Alignment

No `roadmap_path` was provided in the delegation context, so no roadmap consultation was
performed.

## Goals & Non-Goals

**Goals**:

- Amend the pinned Challenge block in
  `specs/678_canonical_wire_parser_round_trip/plans/01_canonical-wire-parser-round-trip.md` to the
  three statements actually proved, **non-destructively** — each original preserved verbatim
  beside its corrected form and its counterexample.
- Correct the injectivity precedent's framing in `FormalSystem/MinusLanguage/Translation.lean` so
  that the property is attributed to the translation's primitive-to-primitive shape rather than
  read as a general feature of a translation module.
- Record, in both `FormalSystem/Semantics/FrameConstraintIndependence.lean` and
  `FormalSystem/Semantics/StateTopology/ConstraintWitnesses.lean`, the **decision** not to
  consolidate the two independence matrices, with its reason and both rejected directions; and
  give the older module the reciprocal pointer it currently lacks.
- Record the shared-fixture convention, including the rejected `.gitignore`-hole alternative,
  where a plan author will actually read it: `Tests/fixtures/README.md`, `Tests/README.md`, and
  `docs/development/MODULE_ORGANIZATION.md` §1.
- Leave every mechanical gate green, including the two that this task's edits actively
  invalidate: C35 (`scripts/lean-citation-manifest.json`) and `INV` (the generated inventory
  blocks).

**Non-Goals**:

- **No theorem statement or proof changes.** Every landed statement named in this plan was read
  from the tree as already proved and sorry-free. Nothing under `BimodalTools/CanonicalWire/` is
  edited at all.
- **No consolidation of the two independence matrices.** This is the substantive decision the task
  asks for and it is settled here, not deferred: Direction A (moving the four new rows into
  `ConstraintWitnesses.lean`) is *blocked* — it loses reachability from
  `FormalSystem/Semantics.lean`, whose standing prohibition on `Mathlib.Topology.*` is the whole
  reason the new module exists. Direction B (moving the topology-free `voidFrame`/`bumpFrame`
  block out) is *feasible but disproportionate* — it would migrate eight `docs/theorem-index.md`
  rows (six `pinned:C14`), a `docs/reference/state-topology-appendix-support.md` citation, and
  four `scripts/module-invariants-allowlist.txt` entries, and would falsify the older module's own
  matrix-completeness claim. A relocation of that size is a restructuring task, not a record
  reconciliation.
- **No edit to `FormalSystem/SourceLanguage/Sentence.lean` or `BimodalTools/README.md`**, both of
  which are in the task's declared `file_scope` and both of which already say the right thing.
  They are verified and left alone (Phase 2).
- **No new mechanical gate for Record 4.** A check that "no plan places a shared artifact under a
  gitignored path" would have to read plans, outside every existing invariant's scope; C13 and C32
  already fail a *link* to a gitignored target, which catches the downstream symptom.
- **No renumbering of the amended Challenge block.** It stays nine theorems.
- **No `parseDigits_printDigits` edit.** Its `¬ c.isDigit` spelling was pre-authorised.
- **No line numbers in any durable record written by this task.** Quote rule text and cite by
  declaration or section name, per the repository's standing anti-line-number convention.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| C35 fails silently until run: header lines added to `FrameConstraintIndependence.lean` shift `constraints_pairwise_independent`'s recorded span (seed line 86 of `scripts/lean-citation-seeds.txt`) | H | H (certain, if Phase 3 lands) | Phase 5 regenerates with `python3 scripts/export-lean-citations.py` and confirms with `--check`. It is an explicit phase, not a final sweep. |
| `INV` fails: three generated inventory blocks go stale on the Lean line-count change | H | H (certain) | Phase 5 runs `bash scripts/check-module-invariants.sh --emit-inventory`, then `--emit-inventory --check`. See the correction note under Research Integration. |
| `ConstraintWitnesses.lean` `longFile` headroom: 1,727 lines against a recorded `set_option linter.style.longFile 1800` baseline — 73 lines | M | M | Keep the reciprocal pointer to one short paragraph. Phase 3's `local` tier builds that single module, which surfaces a breach immediately. If the ceiling is genuinely reached, raise the recorded baseline deliberately with a reason comment — never trim prose to fit. |
| Amendment read as license to edit recorded statements | M | M | The amendment subsection states in one sentence that it exists *because* the recorded statement was false, that the originals are preserved verbatim above it, and that the route was a reviewed follow-up rather than an in-flight edit. `plan-compliance.md` forbids *quiet* editing; this is the non-quiet route. |
| Task-number leakage into deliverables | M | M | Phases 2, 3 and 4 write to `.lean` and non-`specs/` `.md` files, where `.claude/rules/no-task-references-in-deliverables.md` applies. Cite durable anchors (`FormalSystem/SourceLanguage/Sentence.lean`'s `tr_not_injective`, `docs/reference/transcription-audit-surface.md`), never "task N". Phase 1's target is under `specs/**` and is exempt. |
| Long `lake build`: Lean hashes whole files, so a docstring-only edit to the upstream `MinusLanguage/Translation.lean` invalidates downstream `.olean`s | M | H | Never a plain foreground `lake build`. Use the detached, guarded invocation (`.claude/context/project/lean4/operations/long-builds.md`) with a bounded waiter per `context/patterns/bounded-build-waiter.md`. |
| Stale comment line number in `scripts/module-invariants-allowlist.txt` (`...ConstraintWitnesses.lean:1453`) drifts by exactly the number of header lines Phase 3 adds | L | H | Drop the `:1453` rather than re-pinning it, consistent with the repository's anti-line-number convention. Ungated, but a wrong record is the exact defect class this task exists to fix. |
| Concurrent siblings on a shared working tree (682, 686, 688 dispatch this same cycle) | M | M | Re-read each file immediately before editing. Stage only this task's own hunks with an explicit multi-file `git add --` list, never a directory or glob pathspec. Never run `git-snapshot.sh` in its reverting default mode. Treat a build failure outside this task's file set as possibly a sibling's in-flight edit — check `git log` before concluding it is a regression, and STOP and report a foreign commit or modification rather than dismissing it. 688's declared scope (`scripts/check-module-invariants.sh`, `scripts/nolints-style.txt`) overlaps nothing this task edits — this task only *runs* the former. |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2, 3, 4 | -- |
| 2 | 5 | 2, 3 |
| 3 | 6 | 1, 2, 3, 4, 5 |

Phases within the same wave can execute in parallel. The four Wave 1 phases touch entirely
disjoint file sets (one plan file; one `MinusLanguage` module; two `Semantics` modules plus one
`docs/reference` page plus one `scripts/` allowlist comment; three test/doc markdown files), so
parallel execution carries no write conflict between them.

---

### Phase 1: Amend the pinned Challenge block, non-destructively [NOT STARTED]

**Goal**: The canonical wire codec's recorded Challenge block states the three theorems that were
actually proved, and records beside each why the form originally recorded was false.

**Tasks**:
- [ ] Re-read `specs/678_canonical_wire_parser_round_trip/plans/01_canonical-wire-parser-round-trip.md` immediately before editing (sibling-concurrency discipline).
- [ ] In the `## Lean Challenge Statements` fenced block, replace the three false signatures with the landed forms, verified against the tree:
  - `unescape_escape` — conclusion becomes `unescapeBody (escapeBody s ++ ['"']) = .ok (s, [])` (landed at `BimodalTools/CanonicalWire/RoundTrip.lean`).
  - `parseCJson_printCJson` — binder list gains `(hrest : NoDigitHead rest)`, placed after `(hok : Canonical j)` and before `(f : Nat)`, matching the landed order.
  - `parseCJson_fuel_sufficient` — binder list gains `(hrest : NoDigitHead rest)` after `(hok : Canonical j)` (landed at `BimodalTools/CanonicalWire/Fuel.lean`).
- [ ] Leave `parseDigits_printDigits` untouched, and leave the other five statements untouched. The block stays nine theorems; do not renumber.
- [ ] Confirm no new `import` line is needed: `BimodalTools.CanonicalWire.Cert` already imports `BimodalTools.CanonicalWire.Fuel`, so `NoDigitHead` and `parseCJson_fuel_sufficient` are both in scope through the block's existing import list.
- [ ] Immediately below the fenced block (and below, or merged into, its "Three notes on this block" prose), add an `### Amendment` subsection containing, for each of the three: the original recorded statement quoted **verbatim**, the counterexample that refutes it, and the landed module.
  - `unescape_escape`: `unescapeBody` consumes the closing quote — it reads a string literal's body up to and including the delimiter — so without `++ ['"']` the reader runs off the end and reports an unterminated literal. The delimiter is part of the printed form (`printCJson (.str s)` emits it), so naming it weakens nothing.
  - `parseCJson_printCJson` and `parseCJson_fuel_sufficient`: `NoDigitHead rest` is `∀ c ∈ rest.head?, ¬ (c.isDigit = true)`. Without it, `printCJson (.int 1) ++ ['2']` is the byte string `12`, which any correct parser reads as twelve, so the conclusion `= .ok (.int 1, ['2'])` is false. The hypothesis is used at exactly one place, the integer leaf; every structural use discharges it for free via `noDigitHead_cons` at `,`, `]` or `}`, or via `noDigitHead_nil` at end of input.
- [ ] Add one sentence to the `### Amendment` subsection stating that it exists because the recorded statements were false, that the originals are preserved above, and that this was a reviewed follow-up rather than an in-flight edit — so the amendment is not read as license to edit recorded statements to match implementations.
- [ ] Add one sentence noting explicitly that `parseDigits_printDigits`'s `¬ c.isDigit` versus the landed `¬ (c.isDigit = true)` is **not** one of the corrections: the two are the same proposition modulo the `Bool`/`Prop` coercion, and the block's own third note already granted the implementer that degree of freedom.
- [ ] Cross-reference the summary that already records this (`specs/678_canonical_wire_parser_round_trip/summaries/01_canonical-wire-parser-round-trip-summary.md`, "Plan Deviations" and "Follow-ups").

**Timing**: 0.75 hours

**Depends on**: none

**Verification Tier**: prose

**Scope Hypothesis**: exactly three of the nine pinned statements are corrected, and exactly one
file is touched. Confirm at implementation time by diffing the amended block against the landed
signatures in `BimodalTools/CanonicalWire/RoundTrip.lean` and `BimodalTools/CanonicalWire/Fuel.lean`
— every one of the nine must either match its landed counterpart or be one of the five whose
recorded form was already correct, with `parseDigits_printDigits` the single documented
coercion-spelling exception. A fourth needed correction, or a fifth, falsifies the hypothesis and
must be reported rather than silently folded in.

**Files to modify**:
- `specs/678_canonical_wire_parser_round_trip/plans/01_canonical-wire-parser-round-trip.md` — three signatures in the `## Lean Challenge Statements` block, plus a new `### Amendment` subsection below it.

**Verification**:
- Each of the three amended signatures is byte-comparable to its landed counterpart modulo the plan block's `:= sorry` body and its line wrapping.
- Each of the three originals appears verbatim somewhere in the `### Amendment` subsection.
- The block still declares exactly nine theorems, and `parseDigits_printDigits` is unchanged.
- No new import line was added.
- Task-number references are permitted here (`specs/**` is exempt).

---

### Phase 2: Correct the injectivity precedent's framing [NOT STARTED]

**Goal**: `FormalSystem/MinusLanguage/Translation.lean` says *why* `tr` is injective, and says
that the reason does not transfer to an elimination — so the next reader does not ask for a false
`tr_injective` a third time.

**Tasks**:
- [ ] Re-read `FormalSystem/MinusLanguage/Translation.lean` immediately before editing.
- [ ] Extend the `## Main Results` bullet ``- `tr_injective` : `tr` is injective`` to name the reason: `tr` is primitive-to-primitive and same-name (each L⁻ primitive goes to the L operator of the same name; the one substitution is `allPast`/`allFuture` onto L's derived forms), which is what makes injectivity available.
- [ ] Extend the `/-! ### Injectivity -/` section comment with a paragraph stating that the property is a consequence of that shape and **does not generalise** to a translation that sends a defined operator onto the abbreviation it stands for. Name the worked case: `FormalSystem/SourceLanguage/Sentence.lean`'s `tr_not_injective`, where the source-language elimination collapses seventeen operators onto six and the collisions (`cond` with `vee ∘ neg`, `top` with `neg bot`, `dia` with `neg (box (neg ·))`, and both existential tenses) hold by *reflexivity* after unfolding — not by a subtle counterexample.
- [ ] Keep the existing "cheap, and it certifies that the L⁻-side and L-side statements of a theorem determine one another" claim; it is true here. The edit adds the missing *why*, it does not retract the claim.
- [ ] Use backticked repository-relative paths (``` `FormalSystem/SourceLanguage/Sentence.lean` ```), the style this file already uses — relative markdown links in Lean comments are C32-checked and this style is out of that check's scope entirely.
- [ ] Do **not** write a task number anywhere in this file (`.claude/rules/no-task-references-in-deliverables.md`).
- [ ] Verify and leave alone: confirm `FormalSystem/SourceLanguage/Sentence.lean`'s header section "`tr` is lossy, and that is the point" already names all four collisions and the forward-only conformance consequence, and that `BimodalTools/README.md`'s "The channel is one-directional" paragraph already says the same. Make no edit to either. Record the verification in the phase's commit message body.
- [ ] Confirm `FormalSystem/MinusLanguage/README.md` still has no `injectiv` occurrence and needs none — the correction belongs in the module docstring, not that README.

**Timing**: 0.5 hours

**Depends on**: none

**Verification Tier**: local

**Files to modify**:
- `FormalSystem/MinusLanguage/Translation.lean` — the `## Main Results` bullet and the `### Injectivity` section comment. Docstrings only.

**Verification**:
- `lake build FormalSystem.MinusLanguage.Translation` succeeds (a Lean module docstring is parsed, so a malformed one breaks the build — this is why the tier is `local` and not `prose`).
- `git diff` on the file shows every changed hunk inside a `/-!` or `/--` comment region; no declaration, binder or proof term is touched.
- `grep -n 'task [0-9]' FormalSystem/MinusLanguage/Translation.lean` returns nothing.
- `FormalSystem/SourceLanguage/Sentence.lean` and `BimodalTools/README.md` are unmodified (`git status --short` shows neither).

---

### Phase 3: Record the no-consolidation decision in both independence modules [NOT STARTED]

**Goal**: A reader arriving at *either* independence module learns that there are two, that the
duplication is deliberate, why it is kept, and what each module uniquely contributes.

**Tasks**:
- [ ] Re-read both Lean modules immediately before editing.
- [ ] In `FormalSystem/Semantics/FrameConstraintIndependence.lean`, convert the closing paragraph of the "This is not the tree's first independence matrix" section from an honest *observation* ("That is a real duplication and is recorded as such in `docs/reference/transcription-audit-surface.md` rather than glossed over here") into a stated **decision**:
  - The duplication is kept. The reason is reachability from the `FormalSystem/Semantics.lean` aggregator at no import weight.
  - Direction A — moving these four rows into `ConstraintWitnesses.lean` — is blocked: that module imports `FormalSystem.Semantics.StateTopology`, and the aggregator's standing prohibition on `Mathlib.Topology.*` is precisely why the aggregate statement cannot live there.
  - Direction B — moving the topology-free `voidFrame`/`bumpFrame` block out to here — is feasible but rejected: it would migrate eight `docs/theorem-index.md` rows (six `pinned:C14`), a `docs/reference/state-topology-appendix-support.md` citation, and four `scripts/module-invariants-allowlist.txt` namespace entries, and would falsify the older module's own matrix-completeness claim. That is a restructuring, not a record reconciliation.
- [ ] In `FormalSystem/Semantics/StateTopology/ConstraintWitnesses.lean`, add a **short** reciprocal paragraph to the "**With these two, the independence matrix for `def:frame` is complete.**" section stating:
  - The tree's citable *aggregate* statement is `FormalSystem.Semantics.FrameConstraintIndependence.constraints_pairwise_independent`, which this module does not carry.
  - `voidRel` here and `emptyRel` there are the same relation (`fun _ _ _ => False`) at different duration types.
  - That module additionally carries the tree's only *Limit* refutation over **discrete** time (`totalRel_not_limit`) — the four-state funnel's `funnel_not_limit` carries a `[DenselyOrdered ↑D]` binder and so does not apply over `ℤ`.
  - The two modules are deliberately **not** merged, with the one-line reason and a pointer to the other module's header for the full decision.
- [ ] Keep this paragraph short: the module is at 1,727 lines against a `set_option linter.style.longFile 1800` baseline, 73 lines of headroom.
- [ ] In `docs/reference/transcription-audit-surface.md`, amend the closing sentence of the "Three of its four rows were already established, at other witnesses" section — currently "That is recorded here rather than glossed over, because a reader who took the new module for the tree's first independence record would be misled about both the module and the earlier work" — to add that the **decision not to consolidate** is recorded in both module headers.
- [ ] In `scripts/module-invariants-allowlist.txt`, drop the `:1453` from the comment
      `# \`def FiberSaturation\` in namespace ... -- StateTopology/ConstraintWitnesses.lean:1453`,
      leaving the filename. It is a `#` comment and ungated, but this phase shifts it and
      re-pinning a line number reproduces the defect class this task exists to close.
- [ ] Use backticked repository-relative paths throughout (C32 out-of-scope style). No task numbers in any of these four files.

**Timing**: 1 hour

**Depends on**: none

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: exactly four files are touched by this phase — two `.lean`, one
`docs/reference` page, one `scripts/` allowlist comment — and the `ConstraintWitnesses.lean`
addition fits inside the 73 lines of `longFile` headroom. Confirm at implementation time with
`git status --short` (exactly those four paths, plus nothing) and `wc -l
FormalSystem/Semantics/StateTopology/ConstraintWitnesses.lean` (must stay under 1,800; if it does
not, raise the recorded baseline deliberately with a reason comment rather than trimming prose,
and report the raise).

**Files to modify**:
- `FormalSystem/Semantics/FrameConstraintIndependence.lean` — the duplication paragraph becomes a stated decision. Docstring only.
- `FormalSystem/Semantics/StateTopology/ConstraintWitnesses.lean` — reciprocal pointer paragraph in the matrix-completeness section. Docstring only.
- `docs/reference/transcription-audit-surface.md` — one sentence, keeping the three records in agreement.
- `scripts/module-invariants-allowlist.txt` — drop `:1453` from one `#` comment.

**Verification**:
- `lake build FormalSystem.Semantics.FrameConstraintIndependence` and `lake build FormalSystem.Semantics.StateTopology.ConstraintWitnesses` both succeed, the second confirming the `longFile` baseline is not breached.
- `grep -c FrameConstraintIndependence FormalSystem/Semantics/StateTopology/ConstraintWitnesses.lean` is now non-zero (it was zero).
- `git diff` on both `.lean` files shows every hunk inside a `/-!` comment region.
- `grep -n 'task [0-9]' ` over all four files returns nothing.
- **Phase 5 is now mandatory**: this phase shifts `constraints_pairwise_independent`'s recorded span (C35) and the `StateTopology` README's generated line count (`INV`). Do not close the task without it.

---

### Phase 4: Record the shared-fixture convention where a plan author reads it [COMPLETED]

**Goal**: The convention that a cross-repository shared artifact lives under `Tests/fixtures/` and
never under the gitignored `data/` is stated, with its rejected alternative, in the places a plan
author actually consults when deciding where a data file goes.

**Tasks**:
- [x] Re-read each target file immediately before editing.
- [x] In `Tests/fixtures/README.md`, extend the paragraph that already contrasts this directory with `data/` to record the **rejected alternative**: punching a hole in the shared `.gitignore` rule was considered and rejected, because the ignore rule is shared configuration, an exemption would be invisible at the point a later file is added under `data/`, and a tracked path beside the reader costs nothing.
- [x] Quote the `.gitignore` **rule text** (`data/*.jsonl` and `/data`) and never its line numbers — the repository's standing anti-line-number convention, and the same defect class this whole task is about.
- [x] In `Tests/README.md`'s `## Structure` table, add a `fixtures/` row (committed data files a test reads with `include_str`, or that a consumer outside this repository compares against) **and** a `BimodalToolsTest/` row — the latter exists on disk and is missing from the table too.
- [x] In `docs/development/MODULE_ORGANIZATION.md` §1's directory tree, add `Tests/fixtures/` under the `Tests/` node and a `data/` node at the repository root, each with a one-line gloss making the distinction explicit: `Tests/fixtures/` is committed and shareable; `data/` is gitignored in its entirety and cannot hold a shared artifact.
- [x] Bump the `*Last verified:*` line in `Tests/fixtures/README.md` to the implementation date. *(deviation: altered — the line already read `2026-09-27`, the implementation date, so no bump was needed)*
- [x] No task numbers in any of these three files.

**Timing**: 0.5 hours

**Depends on**: none

**Verification Tier**: prose

**Scope Hypothesis**: exactly three files are touched and no `.lean` file is, so this phase alone
triggers neither C35 nor `INV`. Confirm with `git status --short` after the edits — exactly
`Tests/fixtures/README.md`, `Tests/README.md`, `docs/development/MODULE_ORGANIZATION.md`. Also
confirm the `Tests/README.md` Structure table is exhaustive against `ls -d Tests/*/` at
implementation time; if a third missing directory turns up, the two-row hypothesis is falsified
and the extra row should be added and reported.

**Files to modify**:
- `Tests/fixtures/README.md` — the rejected alternative, plus the `Last verified` bump.
- `Tests/README.md` — `fixtures/` and `BimodalToolsTest/` rows in the Structure table.
- `docs/development/MODULE_ORGANIZATION.md` — `Tests/fixtures/` and `data/` in §1's tree.

**Verification**:
- `bash scripts/readme-lint.sh` passes for the touched doc roots (Check 1 and Check 3 are gated; 2 and 4 are reported only).
- No `.gitignore` line number appears in any of the three files.
- `grep -n 'task [0-9]' ` over all three returns nothing.
- `git diff` confirms only prose/table rows changed.

---

### Phase 5: Regenerate the machine-owned records [NOT STARTED]

**Goal**: The two generated records that Phases 2 and 3 invalidate — the Lean citation manifest
(C35) and the generated README inventory blocks (`INV`) — are regenerated and verified in the same
change that invalidated them.

**Tasks**:
- [ ] Confirm Phases 2 and 3 are committed before starting (this phase regenerates *from* their content).
- [ ] Run `python3 scripts/export-lean-citations.py` to rewrite `scripts/lean-citation-manifest.json`, then `python3 scripts/export-lean-citations.py --check` to confirm it is current. `FormalSystem.Semantics.FrameConstraintIndependence.constraints_pairwise_independent` is seed line 86 of `scripts/lean-citation-seeds.txt`; every header line Phase 3 added above it shifted the recorded span.
- [ ] Run `bash scripts/check-module-invariants.sh --emit-inventory` to rewrite the generated inventory blocks, then `bash scripts/check-module-invariants.sh --emit-inventory --check` to confirm none would change a byte.
- [ ] Inspect the resulting diff and confirm the changed rows are the expected ones and only those: `FormalSystem/Semantics/StateTopology/README.md` (the `ConstraintWitnesses.lean` line count, currently `1,727`), `FormalSystem/MinusLanguage/README.md` (the `Translation.lean` row, currently 266 lines), and the root `README.md`'s `dir=FormalSystem rows=totals` block.
- [ ] Bump the `*Last verified:*` line on any README whose inventory row this phase changed.
- [ ] Stage the regenerated files with an explicit multi-file `git add --` list, never a directory or glob pathspec.

**Timing**: 0.5 hours

**Depends on**: 2, 3

**Verification Tier**: local

**Scope Hypothesis**: exactly three generated inventory blocks go stale —
`FormalSystem/Semantics/StateTopology/README.md`, `FormalSystem/MinusLanguage/README.md`, and the
root `README.md` — and exactly one manifest entry shifts. Confirm at implementation time by
running `--emit-inventory` and reading `git status --short`: a fourth changed markdown file means
the hypothesis was wrong and the extra block must be explained before committing (most likely
candidate: another block whose `dir=` covers a file a sibling task edited concurrently — in which
case STOP and report rather than absorbing a sibling's hunk into this task's commit).

**Files to modify**:
- `scripts/lean-citation-manifest.json` — generated; C35.
- `FormalSystem/Semantics/StateTopology/README.md` — generated inventory block.
- `FormalSystem/MinusLanguage/README.md` — generated inventory block.
- `README.md` — generated `rows=totals` inventory block.

**Verification**:
- `python3 scripts/export-lean-citations.py --check` exits clean.
- `bash scripts/check-module-invariants.sh --emit-inventory --check` exits clean.
- The diff contains no hand-authored hunk — every change is generator output plus `Last verified` bumps.

---

### Phase 6: Full gate run and task close-out [NOT STARTED]

**Goal**: Every mechanical gate in the repository is green over the full change set, with the
build run detached and bounded.

**Tasks**:
- [ ] Run the full build detached and guarded — `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build` via `Bash(run_in_background: true)`, never a plain foreground `lake build`. Lean hashes whole files, so the `MinusLanguage/Translation.lean` docstring edit invalidates every downstream `.olean`; this is a long build.
- [ ] Wait on it with a bounded waiter per `context/patterns/bounded-build-waiter.md`: a hard timeout, writer liveness via `kill -0` on the captured PID, never `ps | grep` or `pgrep -f`, one waiter per log.
- [ ] Run `bash scripts/check-module-invariants.sh` (full default run: C13, C15, C20, C27, C31, C32, C35 and `INV`).
- [ ] Run `bash scripts/readme-lint.sh` over `FormalSystem` and the other doc roots touched.
- [ ] Re-run `python3 scripts/export-lean-citations.py --check`.
- [ ] Repo-wide task-reference lint over the non-`specs/` deliverables this task touched (`bash .claude/scripts/check-task-references.sh`, or the equivalent grep) — confirm zero new occurrences.
- [ ] Confirm the final diff touches no theorem statement and no proof term: `git diff` over the two `.lean` files in Phase 3 and the one in Phase 2 shows comment-region hunks only.
- [ ] If a gate fails in a file outside this task's own set, check `git log` and `git status` before concluding it is a regression — a sibling task dispatched this same cycle may have an in-flight edit. STOP and report a foreign commit or modification rather than fixing or dismissing it.
- [ ] Write the execution summary to `specs/689_reconcile_records_with_landed_code/summaries/01_reconcile-records-landed-code-summary.md`.

**Timing**: 1 hour (build-dominated; mostly waiting)

**Depends on**: 1, 2, 3, 4, 5

**Verification Tier**: full

**Files to modify**:
- `specs/689_reconcile_records_with_landed_code/summaries/01_reconcile-records-landed-code-summary.md` — new.

**Verification**:
- `lake build` exits clean with no `sorry`, no new warning, and no `longFile` breach.
- `bash scripts/check-module-invariants.sh` reports PASS for every check, `INV` included.
- `bash scripts/readme-lint.sh` passes on every touched doc root.
- `python3 scripts/export-lean-citations.py --check` exits clean.
- Zero task-number occurrences outside `specs/**` in the change set.

---

## Lean Challenge Statements

This plan is `task_type: lean4` and therefore carries this section, but it is **empty by design**
and contains no ```` ```lean ```` fenced block. The task states no new theorem, proves nothing,
and names no identifier under `- **Goals**:` — every theorem it mentions was already proved and
committed, and is read from the tree rather than re-pinned here. Assembling a Challenge module
from this plan would produce an empty module, and `lean-challenge-snapshot.sh` is correctly not
wired against it (the identifier set declared here is empty, which equals the empty identifier set
named under Goals, so the cross-validation the format requires holds trivially).

The nine statements this task *discusses* are the pinned block of
`specs/678_canonical_wire_parser_round_trip/plans/01_canonical-wire-parser-round-trip.md`, which
Phase 1 amends in place. They are that plan's contract, not this one's, and must not be copied
here — a second copy would be a fifth record to keep in agreement with the tree, which is the
exact failure mode this task exists to repair.

## Testing & Validation

- [ ] `lake build` clean, run detached and bounded (Phase 6).
- [ ] `bash scripts/check-module-invariants.sh` PASS on every check, `INV` included (Phase 6).
- [ ] `python3 scripts/export-lean-citations.py --check` clean (Phases 5 and 6).
- [ ] `bash scripts/check-module-invariants.sh --emit-inventory --check` clean (Phase 5).
- [ ] `bash scripts/readme-lint.sh` clean on every touched doc root (Phases 4 and 6).
- [ ] `lake build` of each individually edited Lean module succeeds before its phase closes (Phases 2 and 3).
- [ ] `ConstraintWitnesses.lean` stays under its recorded `set_option linter.style.longFile 1800` baseline, or the baseline is raised deliberately with a reason comment (Phase 3).
- [ ] Zero task-number occurrences outside `specs/**` across the whole change set (Phase 6).
- [ ] Every `.lean` hunk in the final diff lies inside a comment region — no statement, binder or proof term changed (Phase 6).
- [ ] Each of the three originally-recorded false statements appears verbatim in the amended plan's `### Amendment` subsection (Phase 1).

## Artifacts & Outputs

| Path | Record | Nature |
|------|--------|--------|
| `specs/678_canonical_wire_parser_round_trip/plans/01_canonical-wire-parser-round-trip.md` | 1 | amended pinned block + new `### Amendment` subsection |
| `FormalSystem/MinusLanguage/Translation.lean` | 2 | docstring |
| `FormalSystem/Semantics/FrameConstraintIndependence.lean` | 3 | docstring (decision) |
| `FormalSystem/Semantics/StateTopology/ConstraintWitnesses.lean` | 3 | docstring (reciprocal pointer) |
| `docs/reference/transcription-audit-surface.md` | 3 | one sentence |
| `scripts/module-invariants-allowlist.txt` | 3 | `#` comment, line number dropped |
| `Tests/fixtures/README.md` | 4 | rejected alternative + `Last verified` |
| `Tests/README.md` | 4 | two Structure-table rows |
| `docs/development/MODULE_ORGANIZATION.md` | 4 | two directory-tree nodes |
| `scripts/lean-citation-manifest.json` | gate | generated (C35) |
| `FormalSystem/Semantics/StateTopology/README.md` | gate | generated inventory block |
| `FormalSystem/MinusLanguage/README.md` | gate | generated inventory block |
| `README.md` | gate | generated inventory block |
| `specs/689_reconcile_records_with_landed_code/summaries/01_reconcile-records-landed-code-summary.md` | — | new execution summary |

**Explicitly not modified**, though both are in the task's declared `file_scope`:
`FormalSystem/SourceLanguage/Sentence.lean` and `BimodalTools/README.md` — verified in Phase 2 as
already correct. `FormalSystem/Semantics/StateTopology/README.md`'s *prose* and the root
`README.md`'s prose are likewise untouched; only their generated blocks change.

## Rollback/Contingency

Every phase is independently revertible and every edit is documentary, so rollback is per-file
rather than whole-tree:

- **A single phase's edits**: revert that phase's commit with `git revert <sha>`. Because the four
  Wave 1 phases touch disjoint files, reverting one leaves the other three intact and consistent.
- **Phase 5's regenerated artifacts**: never hand-revert these. Revert the Lean edit that caused
  the shift, then re-run `python3 scripts/export-lean-citations.py` and
  `bash scripts/check-module-invariants.sh --emit-inventory` to regenerate from the reverted
  content, and confirm with both `--check` forms.
- **A `longFile` breach in `ConstraintWitnesses.lean` that cannot be absorbed**: shorten the
  reciprocal paragraph to a two-sentence pointer at the other module's header, which is the
  minimum that discharges Record 3's reciprocal half. Raising the recorded baseline is the
  alternative and must carry a reason comment; trimming unrelated prose to fit is not.
- **Uncommitted work that must be discarded**: this is the one genuine rollback scenario, and it
  needs a snapshot first — see `context/contracts/recovery.md`'s rollback rung for the exact
  `git-snapshot.sh` invocation shape, including its out-of-scope override flag for the deliberate
  whole-tree case. Do **not** emit a bare default-mode `git-snapshot.sh` as a routine
  start-of-phase precaution; a defensive checkpoint before risky work uses `--no-revert`, which is
  durable without reverting the working tree.
- **Contingency if Phase 1's Scope Hypothesis is falsified** (a fourth genuinely false statement
  turns up in the pinned block): stop, report the additional statement and its counterexample, and
  extend the `### Amendment` subsection rather than silently widening the phase — the scope of the
  correction is itself part of the record this task is repairing.
