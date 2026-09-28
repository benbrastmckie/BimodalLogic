# Research Report: Task #689

**Task**: 689 - Reconcile records with landed code
**Started**: 2026-09-27T00:00:00Z
**Completed**: 2026-09-27T00:00:00Z
**Effort**: Medium — four independent documentation reconciliations, no proof work
**Dependencies**: None (all four source tasks are complete and committed)
**Sources/Inputs**:
- Codebase (`FormalSystem/`, `BimodalTools/`, `Tests/`, `docs/`, `scripts/`, `.gitignore`)
- Task records for the 677-681 batch: plans, summaries, handoffs under `specs/678_*`, `specs/679_*`, `specs/681_*`
- `.claude/rules/plan-compliance.md` (Statement Fidelity), verified byte-identical to the lean extension source store
- `.claude/context/project/lean4/operations/long-builds.md`, verified byte-identical to the source store
- `docs/development/MODULE_INVARIANTS.md` (C13, C20, C27, C32, C35), `scripts/readme-lint.sh`
**Artifacts**: - `specs/689_reconcile_records_with_landed_code/reports/01_reconcile-records-landed-code.md`
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **All four records were confirmed against the landed tree.** Every claim in the task description
  checks out verbatim: the three false pinned statements, the false injectivity request, the
  character-identical `voidRel`/`emptyRel` pair, and the gitignored fixture path. Nothing in the
  description needed correcting, and no code defect was found. This is a pure documentation task.
- **Three of the four records are *partly* already written down; the gap in each case is narrower
  than the description implies, and naming the exact gap is the main research finding.** The
  parser statements are recorded in the 678 summary but not in the plan's pinned block; the
  injectivity fact is recorded exhaustively on the *new* module but nowhere on the *precedent*;
  the matrix duplication is recorded honestly in four places but the *decision* is recorded
  nowhere, and the older module carries no pointer back; the fixture convention is recorded in
  `Tests/fixtures/README.md` but the rejected alternative is not, and neither directory tree a
  plan author would consult mentions `Tests/fixtures/` at all.
- **Recommended decision on the independence matrix: do not consolidate.** Consolidation is
  blocked in one direction by the `FormalSystem/Semantics.lean` aggregator's standing prohibition
  on topology imports, and is disproportionately expensive in the other (it would move four
  C14-pinned `docs/theorem-index.md` rows and a `docs/reference/state-topology-appendix-support.md`
  row). The duplication is a deliberate, bounded cost; the task is to say so as a decision, in both
  module headers.
- **One enforced gate will fail unless the plan schedules it: C35.**
  `FormalSystem.Semantics.FrameConstraintIndependence.constraints_pairwise_independent` is on
  `scripts/lean-citation-seeds.txt`, and any header line added above it shifts its recorded span in
  `scripts/lean-citation-manifest.json`. `python3 scripts/export-lean-citations.py` must be re-run
  in the same change.
- **Statement-fidelity tension on record 1 is real and has a clean resolution.**
  `plan-compliance.md` forbids *quietly* editing a recorded Challenge to match what was
  implemented. The correction here must therefore be an amendment that preserves each original
  statement verbatim beside its corrected form and its counterexample — not an in-place
  substitution that erases the original.

## Context & Scope

Four durable records left in a misleading state by the 677-681 implementation batch. Each was
discovered by an implementation finding its own plan, or a sibling's report, wrong. The task is to
make the records say what the code says. Scope is documentation, docstrings, one plan file, and one
generated manifest; no theorem statement or proof changes.

`file_scope` as declared on the task names five files:

```
FormalSystem/Semantics/FrameConstraintIndependence.lean
FormalSystem/Semantics/StateTopology/ConstraintWitnesses.lean
FormalSystem/MinusLanguage/Translation.lean
FormalSystem/SourceLanguage/Sentence.lean
BimodalTools/README.md
```

`file_scope` is descriptive, not filesystem-validated (`.claude/rules/state-management.md`). Research
found that two of these five need no edit and several files outside the list do — see "Decisions"
below for the corrected target set.

**Concurrency**: three sibling tasks dispatch this same cycle. 688 declares
`scripts/check-module-invariants.sh` and `scripts/nolints-style.txt`; this task only *runs* the
former and never edits it, so there is no collision. 682 and 686 declare no scope. The working tree
was clean of foreign modifications at research time (`git status --short` showed only `specs/`
churn and the two untracked new task directories).

## Findings

### Record 1 — The three false pinned statements

**Location of the record**: `specs/678_canonical_wire_parser_round_trip/plans/01_canonical-wire-parser-round-trip.md`,
the fenced `## Lean Challenge Statements` block (lines 596-655), specifically lines 606-608,
615-619 and 621-623.

**Confirmed, all three.** The landed forms differ from the pinned forms exactly as described.

| Pinned (false as written) | Landed | Where |
|---|---|---|
| `unescapeBody (escapeBody s) = .ok (s, [])` | `unescapeBody (escapeBody s ++ ['"']) = .ok (s, [])` | `BimodalTools/CanonicalWire/RoundTrip.lean`, `unescape_escape` |
| `parseCJson_printCJson` with `(hok) (f) (hf)` only | same, plus `(hrest : NoDigitHead rest)` | `BimodalTools/CanonicalWire/RoundTrip.lean` |
| `parseCJson_fuel_sufficient` with `(hok)` only | same, plus `(hrest : NoDigitHead rest)` | `BimodalTools/CanonicalWire/Fuel.lean` |

The counterexamples are already proved out in the landed docstrings:

- `unescapeBody` *consumes* the closing quote (it reads a string literal's body up to and including
  the delimiter), so without `++ ['"']` the reader runs off the end and reports an unterminated
  literal. The delimiter is part of the printed form — `printCJson (.str s)` emits it — so naming
  it weakens nothing.
- `NoDigitHead rest` is defined at `RoundTrip.lean` as
  `∀ c ∈ rest.head?, ¬ (c.isDigit = true)`. Without it, `printCJson (.int 1) ++ ['2']` is the byte
  string `12`, which any correct parser reads as twelve — so the conclusion
  `= .ok (.int 1, ['2'])` is false. The landed docstring on `parseCJson_printCJson` states that the
  hypothesis is used at exactly one place, the integer leaf; every structural use discharges it for
  free through `noDigitHead_cons` at `,`, `]` or `}`, or through `noDigitHead_nil` at end of input.

**A fourth divergence exists and is NOT one of the three.** The plan's `parseDigits_printDigits`
writes `¬ c.isDigit` where the landed form writes `¬ (c.isDigit = true)`. These are the same
proposition modulo the `Bool`/`Prop` coercion, and the plan's third note already granted the
implementer that exact degree of freedom ("the exact spelling of this side condition is the one
degree of freedom the implementer may adjust"). It is not a correction and the amendment must not
present it as one.

**Where the fact is already recorded**: `specs/678_.../summaries/01_...-summary.md` records it
twice — under "Plan Deviations" and again under "Follow-ups" ("For review: three pinned Challenge
statements were corrected rather than proved as recorded"). The summary explicitly notes "Nothing
was quietly edited in the plan's `## Lean Challenge Statements` block." So the gap is precisely
that the plan's block still reads false, and a reader who opens the plan without the summary is
misled.

**The statement-fidelity constraint.** `.claude/rules/plan-compliance.md`'s Statement Fidelity
section says, of a drift finding that reflects a genuinely wrong recorded statement: "do not
quietly edit the recorded Challenge to match what was implemented — either move silently launders
the exact defect this section exists to catch." The operative word is *quietly*. This task is the
non-quiet route: a reviewed amendment. The safe shape preserves the original.

**No snapshot manifest exists for this task.** `find specs -name '*challenge*'` returns nothing, so
`lean-challenge-snapshot.sh --check` is not wired against the 678 plan and no manifest needs
regenerating. The amendment is purely documentary.

**Import-list note**: the block's imports already cover the amended statements.
`BimodalTools.CanonicalWire.Cert` imports `BimodalTools.CanonicalWire.Fuel` (`Cert.lean:7`), so
`parseCJson_fuel_sufficient` and `NoDigitHead` are both in scope without adding an import line.

### Record 2 — The false injectivity request

**Confirmed.** `FormalSystem/SourceLanguage/Sentence.lean` proves `tr_not_injective`; the plan
(`specs/679_.../plans/01_...md:155`, `:246-254`) and the report (`specs/679_.../reports/01_...md:131`)
both asked for `tr_injective`, citing `MinusLanguage/Translation.lean`'s `tr_injective` as
precedent.

**The new module's framing is already complete and needs no edit.** `Sentence.lean` carries a whole
header section, "`tr` is lossy, and that is the point", naming all four collisions
(`cond`/`vee ∘ neg`, `top`/`neg bot`, `dia`/`neg (box (neg ·))`, and both existential tenses), the
forward-only consequence for the conformance channel, and an explicit paragraph saying "This is why
the plan-level expectation of a `tr_injective` mirroring `FormalSystem/MinusLanguage/Translation.lean`
does not hold here." `FormalSystem/SourceLanguage/README.md:68` and `BimodalTools/README.md`'s
"The channel is one-directional" paragraph say the same.

**The precedent carries no such caveat.** `FormalSystem/MinusLanguage/Translation.lean` says only:

- line 30, Main Results: ``- `tr_injective` : `tr` is injective``
- lines 157-161, the `### Injectivity` section: "Not required by the backward direction — it would
  be needed only if faithfulness were stated as a biconditional — but cheap, and it certifies that
  the L⁻-side and L-side statements of a theorem determine one another."

Nothing there says *why* it is available, and the reason is exactly what does not generalise: this
translation is primitive-to-primitive and same-name (`tr` sends each L⁻ primitive to the L operator
of the same name; the one substitution is `allPast`/`allFuture` onto L's derived forms), whereas the
source-language elimination collapses seventeen operators onto six. A reader who takes "cheap and it
certifies determination" as a general property of a translation module asks for the false lemma
again — which is exactly what happened.

`FormalSystem/MinusLanguage/README.md` does not mention injectivity at all
(`grep -i injectiv` returns nothing), so the correction belongs in the module docstring rather
than in that README.

### Record 3 — The duplicated independence matrix

**Confirmed, and the duplication is exact where the description says it is.**

```
FormalSystem/Semantics/FrameConstraintIndependence.lean:123
  def emptyRel : Bool → ℤ → Bool → Prop := fun _ _ _ => False

FormalSystem/Semantics/StateTopology/ConstraintWitnesses.lean:1568
  def voidRel : Bool → ℤ → Bool → Prop := fun _ _ _ => False
```

Character-identical. The new module is 420 lines (four witness relations, sixteen theorems and
`constraints_pairwise_independent`); the older one is 1,727 lines and its header already asserts
"**With these two, the independence matrix for `def:frame` is complete.**"

**The duplication is already recorded honestly in four places**: the new module's own header (a
dedicated section, "This is not the tree's first independence matrix — read this before citing it
as one", with the older module's rows enumerated), `FormalSystem/Semantics.lean:99-110`,
`FormalSystem/Semantics/README.md:34`, and `docs/reference/transcription-audit-surface.md:162-181`.

**What is missing is the decision, and the reciprocal pointer.** `ConstraintWitnesses.lean` contains
zero occurrences of `FrameConstraintIndependence` (grep-confirmed), and neither does
`FormalSystem/Semantics/StateTopology/README.md`. A reader who arrives at the older module — the one
whose header claims a complete matrix — learns nothing about the newer one, which is the more likely
arrival order for anyone following the `def:frame` trail.

**Consolidation analysis — both directions were checked.**

*Direction A: move the four new rows into `ConstraintWitnesses.lean`.* Blocked.
`FormalSystem/Semantics.lean` imports `FrameConstraintIndependence` precisely so
`constraints_pairwise_independent` is reachable from the aggregator, and that aggregator carries a
standing prohibition on `Mathlib.Topology.*` reaching it.
`ConstraintWitnesses.lean` imports `FormalSystem.Semantics.StateTopology` and
`FormalSystem.Semantics.Extension.Completion` and is a deliberate leaf — nothing under
`FormalSystem/` imports it except the top-level `FormalSystem.lean:512`. Moving the aggregate there
loses aggregator reachability, which is the whole point of the new module.

*Direction B: move the topology-free `voidFrame`/`bumpFrame` block out of `ConstraintWitnesses.lean`
into `FrameConstraintIndependence.lean`.* Technically feasible — those declarations need only
`FrameOver`, `intOrder`, `TaskFrame.saturation_of_finite` and `abs`/`omega`-level arithmetic — but
expensive and destructive to two other records:

- `docs/theorem-index.md:249-256` carries eight rows naming `voidFrame_*` and `bumpFrame_*` with
  `FormalSystem/Semantics/StateTopology/ConstraintWitnesses.lean` as the file column, six of them
  marked `pinned:C14`.
- `docs/reference/state-topology-appendix-support.md:127` cites
  `FormalSystem.Semantics.StateTopology.bumpFrame_not_compositional` and `...voidFrame_not_serial`
  as the appendix's certification of matrix completeness.
- `scripts/module-invariants-allowlist.txt` carries four `FormalSystem.Semantics.StateTopology.*`
  namespace entries justified by "the frame lives in the single module
  `StateTopology/ConstraintWitnesses.lean`".
- The move would also break the older module's own header claim that the matrix is complete *there*.

A relocation of that size is a restructuring task, not a record reconciliation, and it would trade a
23-line documentary duplication for a multi-file citation migration.

**Recommended decision: keep both, do not consolidate.** The duplication is one `def` and three
theorem *rows* re-proved at a different witness, bought deliberately for aggregator reachability at
import-light weight. Record the decision, with its reason and the rejected alternatives, in both
module headers.

### Record 4 — The shared-fixture convention

**Confirmed.** `.gitignore` carries both `data/*.jsonl` (line 68, under "Large dataset files (hosted
on Hugging Face Hub)") and a blanket `/data` (line 107). `git ls-files data/` returns nothing: not
one file under `data/` is tracked, `data/README.md` included. The fixture now lives at
`Tests/fixtures/sentence-translation-fixtures.jsonl`, read by
`Tests/BimodalToolsTest/SentenceCodecTest.lean` and consumed cross-repository per
`BimodalTools/README.md`'s "The fixture file, and the hand-off" section.

**`Tests/fixtures/README.md` already states most of the convention** — "`data/` is gitignored in its
entirety ... so nothing in it can serve as a shared artifact. A conformance fixture has to be
obtainable from git by whoever is conforming to it, so it lives here." Two things are missing:

1. **The rejected alternative is not recorded there.** Only the 679 summary
   (`specs/679_.../summaries/01_...-summary.md:101`) mentions "rather than punching a hole in shared
   `.gitignore` config", and a task summary is not where a future plan author looks.
2. **No directory tree a plan author consults mentions `Tests/fixtures/` at all.**
   `docs/development/MODULE_ORGANIZATION.md` §1 lists `Tests/BimodalTest/` and its eight
   subdirectories, and no `fixtures/` and no `data/`. The root `README.md` tree lists
   `Tests/BimodalTest/` only. `Tests/README.md`'s Structure table lists a single row,
   `BimodalTest/` — it mentions neither `fixtures/` nor `BimodalToolsTest/`, both of which exist.
   This is the actual mechanism by which the 679 plan chose `data/`: the place a plan author reads
   to decide where a data file goes says nothing about where a *shared* data file goes.

**Line-number caution.** The 679 summary cites `.gitignore` line 107 and line 68. Those numbers are
correct today but will rot on the next `.gitignore` edit, and the repository has an explicit and
well-evidenced convention against trusting line numbers in durable records (C20 tier 2, C35, and
`docs/reference/paper-definitions-of-record.md`'s "resolved by `\label{}` name ... never by line
number"). The new convention record should quote the *rule text* (`/data`, `data/*.jsonl`) and not
the line numbers.

### Verification gates that apply to this task's edits

| Gate | Applies because | Invocation |
|---|---|---|
| **C35** (enforced) | `constraints_pairwise_independent` is seed line 86 of `scripts/lean-citation-seeds.txt`; any line added above it in `FrameConstraintIndependence.lean` shifts its recorded span | `python3 scripts/export-lean-citations.py` to regenerate, then `--check` to confirm |
| `lake build` | Lean hashes whole files, so a docstring-only edit invalidates every downstream `.olean` | `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build`, detached via `Bash(run_in_background: true)` |
| `scripts/check-module-invariants.sh` | C20 (declaration-span citations), C27 (debug-artifact line counts), C32 (relative markdown links in Lean comments), C15/C31 | run after the build |
| `scripts/readme-lint.sh` | any `README.md` edit; Check 3 (broken relative references) is gated, Checks 2 and 4 are reported only | `bash scripts/readme-lint.sh FormalSystem` plus the doc roots touched |

**`longFile` headroom.** `ConstraintWitnesses.lean` is 1,727 lines against its recorded
`set_option linter.style.longFile 1800` baseline (line 161) — 73 lines of headroom, ample for a
header paragraph but worth watching. `FrameConstraintIndependence.lean` (420),
`MinusLanguage/Translation.lean` (266) and `SourceLanguage/Sentence.lean` (321) carry no baseline and
sit far under the default.

**C32 note.** Relative markdown links in Lean comments must resolve from the citing file's own
directory; *backticked repository-relative paths are out of scope*, which is the style every file in
scope already uses (``` `FormalSystem/SourceLanguage/Sentence.lean` ```). Keeping that style avoids
the check entirely.

### Recommendations

**Record 1 — amend the 678 plan's pinned block, non-destructively.**
Rewrite the three statements in the fenced block to the landed forms, and immediately below the
block add an `### Amendment` subsection that, for each of the three, quotes the original recorded
statement verbatim, gives the counterexample, and names the landed module. Preserving the original
is what keeps this an amendment rather than the silent laundering `plan-compliance.md` prohibits.
Do not touch `parseDigits_printDigits` — its `¬ c.isDigit` spelling was pre-authorised by the
plan's own third note. Do not renumber: the block stays nine theorems.

**Record 2 — correct the precedent's framing in `FormalSystem/MinusLanguage/Translation.lean`.**
Two edits, both docstring: extend the `## Main Results` bullet at line 30 to say *why* `tr` is
injective (primitive-to-primitive, same-name), and extend the `### Injectivity` section comment
(lines 157-161) with a paragraph saying the property is a consequence of that shape and does not
transfer to an elimination that sends a defined operator onto the abbreviation it stands for,
pointing at `FormalSystem/SourceLanguage/Sentence.lean`'s `tr_not_injective` as the worked case.
`FormalSystem/SourceLanguage/Sentence.lean` needs no edit — verify and leave it.

**Record 3 — record the no-consolidation decision in both headers.**
In `FrameConstraintIndependence.lean`, convert the existing honest observation into a stated
decision: the duplication is kept, the reason is aggregator reachability, and both consolidation
directions were considered and rejected (naming the aggregator's topology prohibition for one and
the C14-pinned `theorem-index.md` rows for the other). In `ConstraintWitnesses.lean`, add the
reciprocal pointer to its matrix-completeness section — that the tree's citable *aggregate*
statement is `FrameConstraintIndependence.constraints_pairwise_independent`, that `voidRel` there is
called `emptyRel`, and that the two modules are deliberately not merged. Mirror one sentence into
`docs/reference/transcription-audit-surface.md:178-181`, turning "That is recorded here rather than
glossed over" into "…and the decision not to consolidate is recorded in both module headers."

**Record 4 — record the convention where a plan author will read it.**
Add the rejected alternative to `Tests/fixtures/README.md` (a hole in the shared `.gitignore` rule
was considered and rejected: the ignore rule is shared configuration, the exemption would be
invisible at the point a later file is added under `data/`, and a tracked path beside the reader
costs nothing). Add a `fixtures/` row to `Tests/README.md`'s Structure table — and a
`BimodalToolsTest/` row while there, since it is missing too. Add `Tests/fixtures/` and `data/` to
`docs/development/MODULE_ORGANIZATION.md` §1's tree with a one-line convention gloss. Quote the
`.gitignore` rule text, never its line numbers.

## Decisions

- **Do not consolidate the two independence matrices.** Rationale and rejected alternatives under
  Record 3. This is the substantive decision the task asks for; the rest is transcription.
- **Amend rather than substitute, on Record 1.** The original recorded statements stay visible in
  the plan file. Overwriting them would satisfy the letter of "make the record true" while
  destroying the reviewability `plan-compliance.md`'s Statement Fidelity section exists to protect.
- **Corrected target file set.** Of the five declared in `file_scope`, two need no edit
  (`FormalSystem/SourceLanguage/Sentence.lean` and `BimodalTools/README.md` already say the right
  thing about forward-only conformance — verify, do not touch). The files that do need edits:

  | File | Record | Why |
  |---|---|---|
  | `specs/678_canonical_wire_parser_round_trip/plans/01_canonical-wire-parser-round-trip.md` | 1 | the pinned block |
  | `FormalSystem/MinusLanguage/Translation.lean` | 2 | the precedent's framing |
  | `FormalSystem/Semantics/FrameConstraintIndependence.lean` | 3 | the decision |
  | `FormalSystem/Semantics/StateTopology/ConstraintWitnesses.lean` | 3 | the reciprocal pointer |
  | `docs/reference/transcription-audit-surface.md` | 3 | one sentence, keeps the three records in agreement |
  | `scripts/lean-citation-manifest.json` | 3 | generated; C35 |
  | `Tests/fixtures/README.md` | 4 | the rejected alternative |
  | `Tests/README.md` | 4 | `fixtures/` and `BimodalToolsTest/` rows |
  | `docs/development/MODULE_ORGANIZATION.md` | 4 | the directory tree |

- **`FormalSystem/Semantics/StateTopology/README.md` and the root `README.md` are optional.** Both
  are plausible homes for a pointer, neither is where the described reader arrives first. Leave them
  to the plan's judgement rather than mandating churn.
- **No new mechanical gate is proposed for Record 4.** A check that "no plan places a shared
  artifact under a gitignored path" would need to read plans, which is outside every existing
  invariant's scope; C13 and C32 already fail a *link* to a gitignored target, which catches the
  downstream symptom. Recording the convention is the proportionate remedy.

## Risks & Mitigations

- **C35 fails silently until run.** Adding header lines to `FrameConstraintIndependence.lean` shifts
  `constraints_pairwise_independent`. *Mitigation*: regenerate with
  `python3 scripts/export-lean-citations.py` in the same change and confirm with `--check`; the plan
  should make this an explicit checklist item on the phase that edits that file, not a final sweep.
- **Full `lake build` on a docstring-only change.** Lean hashes whole files, so editing
  `MinusLanguage/Translation.lean` (an upstream module) invalidates downstream `.olean`s and the
  build is long. *Mitigation*: the canonical detached, guarded invocation above; never a plain
  foreground `lake build`.
- **`ConstraintWitnesses.lean` `longFile` baseline.** 73 lines of headroom. *Mitigation*: keep the
  reciprocal pointer to a short paragraph; if the ceiling is approached, raise the recorded baseline
  deliberately rather than trimming prose to fit.
- **Stale comment line number.** `scripts/module-invariants-allowlist.txt:87` cites
  `StateTopology/ConstraintWitnesses.lean:1453` in a `#` comment. It is not gated, but it will drift
  by exactly the number of header lines added. *Mitigation*: drop the `:1453` (consistent with the
  repository's own anti-line-number convention) rather than re-pinning it.
- **README line counts drift.** `FormalSystem/Semantics/StateTopology/README.md:18` records
  `ConstraintWitnesses.lean | 1,727` and `FormalSystem/SourceLanguage/README.md:101` records
  `Sentence.lean | 321`. Not gated by `readme-lint.sh`, but a wrong number is a wrong record — the
  same defect class this whole task is about. *Mitigation*: update any count for a file this task
  lengthens, and bump that README's `Last verified` date.
- **Concurrent siblings on a shared tree.** Per the dispatch's territory block: re-read each file
  immediately before editing, stage only this task's own hunks with an explicit file list (never a
  directory or glob pathspec), and treat a build failure outside this task's file set as possibly a
  sibling's in-flight edit.
- **Reading the amendment as license.** An amended plan block could be read as "recorded statements
  may be edited to match implementations". *Mitigation*: the amendment subsection should say in one
  sentence that it exists because the recorded statement was false, that the originals are preserved
  above, and that the route was a reviewed follow-up rather than an in-flight edit.

## Tactic Survey Results

- Not applicable (no tactic survey performed). This task changes no theorem statement and no proof;
  every landed statement named here was read from the tree as already proved, sorry-free, with the
  678 and 679 summaries recording `#print axioms` at the standard three or fewer.

## Context Extension Recommendations

- **Topic**: Correcting a false recorded Challenge statement after implementation.
  **Gap**: `.claude/rules/plan-compliance.md`'s Statement Fidelity section tells an implementer what
  *not* to do (do not quietly edit the plan, do not quietly substitute) and names `[BLOCKED]` as the
  in-flight route, but says nothing about the after-the-fact route — which is what actually happened
  twice in the 677-681 batch and what this task executes.
  **Recommendation**: add a short "Correcting a false recorded statement, after the fact" subsection
  to that rule, specifying the amendment shape (originals preserved verbatim, counterexample given,
  landed form named, summary cross-referenced). This is a source-store edit under
  `/home/benjamin/.config/nvim/agent-system/extensions/lean/rules/plan-compliance.md`, never a
  hand-patch under `.claude/**`.

- **Topic**: Where a shared cross-repository artifact lives in this repository.
  **Gap**: covered by Record 4's deliverables inside the repository. No agent-system context file is
  needed; the convention is repository-specific.

## Appendix

### Searches and commands used

```
jq '.active_projects[] | select(.project_number==689)' specs/state.json
grep -rn "injectiv" specs/679_lean_sentence_formula_translation_truth/
grep -rn "tr_injective" --include=*.md --include=*.lean .        # outside specs/: 3 hits
grep -rn "FrameConstraintIndependence" FormalSystem/ docs/
grep -rn "voidFrame|bumpFrame|voidRel|bumpRel" --include=*.md --include=*.lean --include=*.txt .
git ls-files data/                                               # empty
grep -n "^data/\*\.jsonl$|^/data$" .gitignore                    # 68, 107
find specs -name "*challenge*"                                   # empty: no 678 snapshot manifest
grep -n "FrameConstraintIndependence" scripts/lean-citation-seeds.txt   # line 86
diff <source-store>/rules/plan-compliance.md .claude/rules/plan-compliance.md            # identical
diff <source-store>/context/.../long-builds.md .claude/context/.../long-builds.md        # identical
```

### Key references

- `.claude/rules/plan-compliance.md` — Statement Fidelity (lines 41-71)
- `.claude/context/project/lean4/operations/long-builds.md` — the canonical detached, guarded build
- `docs/development/MODULE_INVARIANTS.md` — C13, C14, C20, C27, C32, C35
- `scripts/export-lean-citations.py` — `--check` / `--stdout` / write modes
- `scripts/readme-lint.sh` — which checks are gated (1 and 3) and which are reported (2 and 4)
- `specs/678_canonical_wire_parser_round_trip/summaries/01_canonical-wire-parser-round-trip-summary.md`
  — "Plan Deviations" and "Follow-ups"
- `specs/679_lean_sentence_formula_translation_truth/summaries/01_sentence-formula-translation-truth-summary.md`
  — "Decisions" and "Plan Deviations"
