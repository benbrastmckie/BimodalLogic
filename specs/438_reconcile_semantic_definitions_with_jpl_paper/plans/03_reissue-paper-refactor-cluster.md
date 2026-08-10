# Implementation Plan: Task #438 (Part B — Cluster Re-Issue), Revision 2

- **Task**: 438 - reconcile_semantic_definitions_with_jpl_paper
- **Status**: [IMPLEMENTING]
- **Effort**: 6 hours
- **Dependencies**: None (Part A research — rounds 1 and 2 — is complete and is the input to this plan)
- **Research Inputs**:
  - specs/438_reconcile_semantic_definitions_with_jpl_paper/reports/01_team-research.md
  - specs/438_reconcile_semantic_definitions_with_jpl_paper/reports/02_logical-consequence-discrepancy-audit.md
- **Artifacts**: plans/03_reissue-paper-refactor-cluster.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Part A (research rounds 1 and 2) already delivers the reconciliation table, target Lean
signatures, coupling analysis, per-task staleness verdicts, and the dependency-cycle resolution.
This plan executes **Part B only — deliverables 6 through 10**: rewrite the six paper-refactor
cluster task descriptions (414, 415, 417, 419, 420, 427) in `specs/state.json` to state the
current four-axiom `def:frame` (biconditional Compositionality, Seriality, Limit, Spherical) and
totality-based logical consequence over `H_F`; rename the three misnamed tasks (subject to a
rename-cost grep preflight that has NOT yet been run); set statuses per the reports' verdicts;
insert SUPERSEDED banners on stale report files; drop the `420 -> 415` cycle edge; and regenerate
`specs/TODO.md`. All work is confined to `specs/**` — this is state.json surgery, file moves, and
banner insertion: mechanical but high-blast-radius, so the rename grep runs before any rename is
committed to, and `state.json` is treated as the single machine source of truth (edit state.json,
then regenerate TODO.md via `generate-todo.sh`; never hand-edit TODO.md).

Definition of done: every one of the six descriptions states the current definitions with
`\label`-based paper anchors, an explicit survives/superseded breakdown, and preserved still-valid
content; the dependency graph is verifiably acyclic; TODO.md is regenerated; the superseded-
vocabulary grep across all six rewritten descriptions has every remaining hit justified.

### Research Integration

Two reports are integrated. **Report 02 is the authoritative content source wherever it
supersedes report 01; report 01 remains the authoritative content source for everything report 02
did not touch.** This precedence rule is not implicit — it is stated here, restated in Phase 3 and
Phase 4's task text, and is the single most important instruction in this revision.

**Report 01 (`reports/01_team-research.md`) — still authoritative for**:
- **Deliverable 4**'s per-task Survives / Refuted / "re-issued description must say" content for
  all six tasks — this remains the *skeleton* content spec for Phases 3-4, overlaid (not replaced)
  by report 02's §4 corrections below.
- **Deliverable 5**'s corrected edge set (drop `415` from `420.dependencies` only) and its
  four-point post-edit verification checklist — Phase 6, unchanged.
- **Gap 4** (rename-cost grep preflight not yet run) — Phase 1, unchanged.
- **Gap 6 / Recommendation 5** (SUPERSEDED-banner requirement) — Phase 5, unchanged.
- **Recommendation 10** (final superseded-vocabulary grep) — Phase 7, with an extended term list.
- **Conflict 3** (satisfiability has no paper anchor; Lean's satisfiability family inherits the
  totality fix as a design decision) — explicitly re-affirmed by report 02's Decisions section.
- **Conflict 6** (420 stays `blocked`; landed phases 1-5 must not be presented as undone).
- The Group C dead/live/portable bucketing (88/16/8), the staging plan for 415, the
  `bundleFlowFrame` strategy, the "Limit automatic over Z" claim, the 419 converse-direction
  done-and-sorry-free finding, and the recurrence-prevention Option A+C proposal — none of which
  report 02 touched except to strengthen.

**Report 02 (`reports/02_logical-consequence-discrepancy-audit.md`) — overrides report 01 for**:
- **Findings §1(b)** — ten itemized supersessions of report 01's quotes and anchors.
- **Findings §1(c)** — two corrections to earlier errors plus one caveat (see "Two corrected
  earlier errors" below).
- **Findings §2** — the updated target Lean signatures, superseding report 01's Deliverable 2.
- **Findings §3** — the re-verified frame-axiom coupling under the new proof architecture
  (`lem:constraint` -> `lem:step` -> Zorn).
- **Findings §4** — the SEVEN itemized content-source corrections, reproduced concretely in this
  plan's Phase 3/Phase 4 task text so an implementer can act on them without re-deriving them.

**Report 02's plan-validity verdict on plan 01: PARTIALLY VALID.** Its explicit finding is that
plan 01's "phase structure, renames, status decisions, dependency-edge fix, and banner scheme all
stand" and that only Phases 3-4's *content source* required revision. This revision therefore adds
and removes no phase, and changes no status, rename, or edge decision.

### The seven content-source corrections (report 02, Findings §4)

Reproduced here verbatim in substance so Phases 3-4 are self-sufficient. Each is tagged **C1**-**C7**
and referenced by tag from the phase task lists.

| Tag | Correction | Applies to |
|-----|------------|------------|
| **C1** | **Anchor set.** Add `def:temporal-order`, `def:task-relation`, `def:directed` to the anchor inventory. Replace EVERY `lem:segments` reference with `lem:constraint` + `lem:step` — `lem:segments` no longer exists in the paper. Note that `thm:extension` is now stated for *partial histories* and proved via Zorn + Step Lemma. Purge all parenthetical line locators inherited from report 01: `:2412`, `:2570`, `:926`, `:912-913`, `:949-960` are all stale at the current snapshot. | all six |
| **C2** | **Notation.** Segments are written `[w, v]_x^y` — the `\Seg` macro is DELETED from the paper preamble, so `Seg(w, v; a, b)` must not appear as current notation. Spell the defining equation out once per description: `[w, v]_x^y := Fib(w, x) ∩ Fib(v, -y)` for `x, y >= 0`, with `Fib(w, x) := {u ∈ W : w =>_x u}` and cone `(w)_x := ⋃_{|y| < x} Fib(w, y)` for `x > 0`. Spherical ranges over directed families of nonempty **fibers and segments** as two separate classes; the fibers-count-among-segments device is RETIRED. Directedness is its own definition (`def:directed`): a nonempty family `S` is directed iff for any `S₁, S₂ ∈ S` there is `S ∈ S` with `S ⊆ S₁ ∩ S₂`. | 414, 415, 420, 427 |
| **C3** | **Vocabulary.** "partial history" replaces "task-constrained function" THROUGHOUT — the latter vocabulary is retired everywhere in the paper (`thm:extension`, `thm:occurrence`, and the `app:gluing` footnote are all recast). A *partial history* is a function `τ : X -> W` on a **nonempty** `X ⊆ D` with `τ(x) =>_{y-x} τ(y)` for all `x, y ∈ X` — **no convexity**. A *world history* is a partial history whose domain is convex. *Total* (equivalently: a *possible world*) means `X = D`. The layering is partial ⊃ world ⊃ total. The Lean `WorldHistory` nonemptiness gap (report 02 item c1) joins 414/420's scope. | 414, 415, 420, 427 |
| **C4** | **419's quoted non-example.** Quote the CURRENT footnote text (report 02 §1(b) row b7), not report 01's version, and do NOT cite `:926`. Current text: "Convexity alone does not guarantee extendability: taking $D = \mathbb{Q}$ and $W = \set{q \in \mathbb{Q} : q > 0}$ with $r \Rightarrow_x r'$ *iff* $\vert{r' - r} \leq x$ yields a structure satisfying every axiom but *Spherical*, in which the partial history $\tau(t) = 1 - t$ defined for $0 < t < 1$ admits no value $u$ at the time $1$, since $\vert{u - (1 - s)} \leq 1 - s$ for every $s < 1$ forces $u \leq 0$, and so $\tau$ restricts no total world history. *Spherical* is exactly what excludes this structure." It is a footnote to the world-history sentence in the `sec:Construction` body and carries NO label of its own; `def:world-history` is the durable formal anchor. | 419 |
| **C5** | **417's research lead — strengthened.** Add `lem:step`'s closing remark: "Where the family has a $\subseteq$-least member--- as when nearest assignments flank $z$--- that member already contains a candidate and *Spherical* is not needed." Over a discrete order like `D = ℤ`, any nonempty bounded set of integers has a max/min, so the *step extension* is **Spherical-free over ℤ**. State explicitly that this does NOT discharge the Spherical *axiom*: the axiom must still be proved for the frame instance. The finite-`W` pigeonhole lead for Spherical stands separately, as a lead to verify, not assume. | 417 |
| **C6** | **Cross-task acceptance criterion — re-pointed.** The shared 414/420 criterion changes from "Spherical's Lean statement must be literally the hypothesis `thm:extension`'s proof consumes" to "...the hypothesis **`lem:step`'s** proof consumes". Under the new proof architecture `lem:step` is the sole site where Spherical is applied; `thm:extension` consumes only Zorn + `lem:step`. Spherical must not be an inert field. | 414, 420 |
| **C7** | **Recurrence instruction — snapshot-pinned.** The paper-git-log-first instruction must ALSO record report 02's pinned snapshot as the "since" baseline: paper repo HEAD `98b52b41` ("task 66: complete implementation", 2026-08-10 14:57 -0700) **plus uncommitted working-tree edits**, file md5 `aa0488c1fe6134e59256803ae891a5f2`, 3975 lines, read 2026-08-10T15:31 -0700. Warn that the file changes **intra-day** (it changed under the research agent mid-dispatch: 3968 -> 3975 lines, `def:frame` moved :2420 -> :2427, and two new labeled definitions appeared between two greps minutes apart), so a fourth drift wave before the cluster re-runs is likely. | 414, 415, 417, 419 (the four re-run research dispatches) |

### Two corrected earlier errors (report 02, Findings §1(c)) — must land in the rewrites

1. **Lean `WorldHistory` lacks the paper's nonempty-domain requirement.** Report 01's row 10
   scored the base definition a **match**; it is a match on four of five conjuncts. `WorldHistory`
   has `domain : D -> Prop` with no nonemptiness field, so the empty history is a legal Lean
   `WorldHistory` but is not a world history in the paper. Impact is nil for the consequence chain
   (total histories have domain `D`, nonempty since `D` is nontrivial) but real for
   `thm:extension` fidelity, whose hypothesis is a *nonempty* partial history. 414 and 420 must
   carry this gap explicitly rather than inheriting report 01's "match" verdict.
2. **`valid`/`SemanticConsequence` already carry `[Nontrivial D]`** (`Validity.lean:80` and
   `:104`). Report 01's Deliverable 2 presents `[Nontrivial D]` as new at every level. The genuine
   binder gap is only at the `TaskFrame` **structure** level (no `[Nontrivial D]` binder, no
   `Nonempty WorldState` field). The consequence-level delta is precisely: (i) drop
   `Omega`/`ShiftClosed`/`τ ∈ Omega`, (ii) add the totality constraint on `τ`. 414's rewrite must
   state the smaller delta, not the overstated one.

Also carried (report 02 item c3, a caveat rather than an error): Lean's `Formula` takes
**Until/Since** (`untl`/`snce`) as primitive with G/H/F/P derived, mirroring the paper's extended
`def:BLplus-semantics`, while `def:BL-semantics` has primitive Past/Future only. The totality
refactor must rewrite the `untl`/`snce` clauses' binders too.

### Pinned-snapshot citation discipline (applies to every phase that quotes the paper)

Carried forward from report 02's "Paper Snapshot" section and Recommendation 2, and binding on
Phases 3, 4, and 7:

- Cite by `\label` **only**. A bare `possible_worlds.tex:NNNN` is never a citation; at most it is
  a parenthetical locator written beside a label, and even then it is snapshot-scoped.
- Every quoted definition must carry (a) its `\label` name and (b) the quoted TEXT verbatim, so a
  renamed or moved label remains detectable by text search.
- Every rewritten description that instructs a downstream research dispatch must record the pinned
  snapshot triple — **SHA `98b52b41` + md5 `aa0488c1fe6134e59256803ae891a5f2` + 2026-08-10** — as
  its verification baseline, per **C7**.
- The label inventory itself is volatile: `def:temporal-order`, `def:task-relation`, and
  `def:directed` appeared mid-session during research round 2. A phase that quotes the label
  inventory re-checks it at execution time rather than trusting this plan's copy.
- Reproducing the ASCII bracket form `[w, v]_x^y` with its defining equation spelled out (per
  **C2**) is the mitigation for the notation's plain-text ambiguity in task descriptions.

### Prior Plan Reference

Plan v01 is `plans/01_reissue-paper-refactor-cluster.md`. It stays on disk as history and is NOT
deleted or overwritten. This is plan v02 (artifact 03). Report 02's verdict on v01 — PARTIALLY
VALID, "not executable as-is solely on account of the Phases 3-4 content source" — is the reason
this revision exists. Everything v01 got right is carried forward verbatim in substance:
the 7-phase structure, the rename-cost preflight, the three rename targets, the status-reset
rules including 420's special handling, the SUPERSEDED banner mechanism, the single-edge
dependency fix with its four-point acyclicity verification, and the final vocabulary-grep gate.

### Roadmap Alignment

`specs/ROADMAP.md`'s "Paper Alignment Programme" section governs this cluster, but the research
establishes that section is itself stale (three-axiom frame, maximal-history validity). This plan
does NOT edit ROADMAP.md (out of Part B scope); the staleness is recorded under Recommended
Follow-Ups below so it is not lost.

## Goals & Non-Goals

**Goals**:
- Rewrite the `description` field of all six cluster tasks so each states the CURRENT
  definitions (four-axiom `def:frame`; totality-based consequence over `H_F`; partial-history
  vocabulary; `lem:constraint`/`lem:step` proof architecture) as settled inputs, with
  `\label`-based paper anchors (never bare line numbers), an explicit survives/superseded
  breakdown, and all still-valid content preserved (scope boundaries, non-goals, binding notation
  decisions such as the superscript-inverse converse convention). Descriptions ARE the specs —
  do not shorten to tidy.
- Apply the seven content-source corrections **C1**-**C7** and the two corrected earlier errors,
  sourcing from report 02 wherever it supersedes report 01 and from report 01 everywhere else.
- Rename 414, 415, and 420 per the reports' proposals — IF the Phase 1 grep preflight shows a
  manageable reference surface; otherwise record the rename decision and its measured cost in the
  task descriptions instead of doing a partial rename.
- Set statuses: 414, 415, 417 -> `not_started` (target predicate changed; research must re-run);
  419, 427 stay `not_started`; 420 stays `blocked` with a revised `blockers` field (phases 1-5
  are landed, green, and committed and must not be presented as undone).
- Insert a one-line SUPERSEDED banner at the top of each superseded report file. Never delete or
  overwrite any existing report file.
- Apply the corrected dependency edges (drop `415` from `420.dependencies`; nothing else) and
  verify acyclicity via `.claude/scripts/generate-task-order.sh --print`.
- Regenerate `specs/TODO.md` via `.claude/scripts/generate-todo.sh` and commit state.json +
  TODO.md together.

**Non-Goals** (hard boundaries, restated from the task description and unchanged from plan v01):
- Do NOT add, remove, or alter any field of `TaskFrame`. Do NOT touch `TruthAt`, `valid`,
  `SemanticConsequence`, or any Omega binder. Do NOT edit any file under `FormalSystem/`.
- Do NOT edit `latex/` or `typst/` content.
- Do NOT edit anything under `/home/benjamin/Philosophy/Papers/` — the paper is read-only input.
- Do NOT perform any of the six cluster tasks' underlying Lean/LaTeX/typst work.
- Do NOT re-run Part A or re-derive anything from the paper — reports 01 and 02 are the settled
  inputs, with 02 winning conflicts.
- Do NOT edit `specs/ROADMAP.md` and do NOT rewrite task 424 — see Recommended Follow-Ups.
- Do NOT delete, truncate, or content-modify `plans/01_reissue-paper-refactor-cluster.md`,
  `reports/01_team-research.md`, or `reports/02_logical-consequence-discrepancy-audit.md`.
- Part B changes task SPECIFICATIONS in `specs/`, nothing else.

### Recommended Follow-Ups (out of scope — record, do not execute)

These items are real, surfaced by the research, and outside deliverables 6-10. They belong in
task 438's completion summary as named follow-ups; expanding this plan to cover them is the
user's call, not the plan's:

1. **Task 424** (`strong_completeness` topic, not_started, gates the entire ultraproduct branch)
   hard-codes the current Omega-parameterized `TruthAt`/box clause through its governing design
   doc under `specs/archive/361_*/design/02_compactness-route.md` and breaks silently once 414
   lands. Outside `topic == "paper-refactor"`, so outside Part B's rewrite scope. (Related open
   item: tasks 421-423 and 425 are UNCHECKED, not cleared — their design docs were never opened.)
2. **`specs/ROADMAP.md`'s "Paper Alignment Programme" section** is itself stale (three-axiom
   frame, maximal-history validity) and deliverable 6 does not touch it.
3. **Recurrence prevention — now escalated.** Report 02 records a THIRD drift wave, landing
   mid-dispatch. The recommendation (report 01 Option A+C) is a generated
   `specs/paper-definitions-of-record.md` plus a `check-paper-definitions.sh` lint anchored to a
   paper commit SHA recorded in state.json — a follow-up `meta` task. Report 02 calls this "the
   highest-leverage `meta` follow-up in the cluster's orbit". Without it this cluster goes stale a
   fourth time.
4. **Frame-relative validity gap** (report 02 Recommendation 5): `def:frame-validity`'s
   `⊨_F` has no Lean counterpart, and it is the natural home for the `app:nonempty` never-vacuous
   theorem. This is folded into 414's rewrite as an explicit OPTIONAL deliverable (Phase 3), not
   left as an out-of-scope note.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| **Phases 3-4 compose from report 01's Deliverable 4 verbatim, writing a FOURTH stale generation into the specs** (report 02's own named top risk) | H | M | The **C1**-**C7** table above is reproduced in-plan and referenced by tag from every Phase 3/4 checklist item, so the implementer never needs to re-derive it; Phase 7's grep list is extended with "task-constrained", "lem:segments", "Seg(" and the old Spherical phrasing |
| Partial rename leaves dangling artifact paths (state.json `artifacts[].path` pointing at a moved directory) | H | M | Phase 1 grep preflight runs BEFORE any rename; Phase 2 is a pre-declared atomic batch per rename (state.json name + `git mv` + path updates land as one commit); fallback is record-decision-instead-of-rename |
| state.json corrupted by a bad edit (malformed JSON breaks every downstream script) | H | L | Every state.json edit goes through `jq`/scripted rewrite into a temp file, validated with `jq empty` before moving into place; TODO.md regenerated only after validation; per-phase commits give clean rollback points |
| A rewritten description silently retains a superseded axiom statement or superseded machinery | M | M | Phase 7's extended grep (nine terms, see Phase 7) across all six descriptions, with every remaining hit justified in the summary |
| 420 presented as undone (status reset destroying the record of landed phases 1-5) | H | L | 420's status is never changed from `blocked`; its rewritten description and `blockers` field inventory landed-vs-stale explicitly (report 01 Conflict 6, two teammates converged independently; re-affirmed by report 02 §4) |
| **The paper changes again before Part B lands or the cluster re-runs** (observed cadence: intra-day) | M | H | Snapshot pinning per **C7** in every re-run task's description; paper-git-log-first instruction as the literal FIRST step of each re-run research dispatch; recurrence-prevention meta task named in the completion summary |
| **A mid-session label (`def:temporal-order`/`def:task-relation`/`def:directed`) is reverted or renamed by the paper's author, dangling the anchors** | M | M | Descriptions quote definition TEXT verbatim alongside each label, so a renamed label is detectable by text search; Phase 3/4 re-check the label inventory against the paper at execution time (read-only) before writing anchors |
| Concurrent task activity mutates state.json between phases | M | L | Phase 1 re-verifies cluster membership/statuses/edges against live state.json; each phase re-reads state.json before editing rather than trusting an earlier phase's snapshot |
| Descriptions drift from the reports' content spec (paraphrase error re-introducing a stale claim) | M | M | Phases 3-4 compose each description from Deliverable 4's text **overlaid with C1-C7**, with BOTH reports open, then re-read each description end to end (deliverable 8's own requirement) |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3, 5 | 2 |
| 4 | 4 | 3 |
| 5 | 6 | 4 |
| 6 | 7 | 5, 6 |

Phases within the same wave can execute in parallel. (Phases 3 and 4 both edit `state.json` and
are deliberately serialized; Phase 5 touches only report files and may run parallel to Phase 3.)

### Phase 1: Preflight — cluster re-verification and rename-cost grep [COMPLETED]

**Goal**: Re-verify the cluster's live state and measure the rename reference surface BEFORE any
mutation, producing the rename-vs-record decision input. Read-only; no file is modified.

**Tasks**:
- [x] Re-query `specs/state.json` for `topic == "paper-refactor"`: confirm the cluster is still
  exactly {414, 415, 417, 419, 420, 427} with statuses/dependencies as both reports record
  (420 blocked deps [415,438]; 419 not_started [438]; 414 researched [420,438]; 415 researched
  [414,420,438]; 417 researched [414,420,438]; 427 not_started [414,415,417,419,420,438]). Report
  02 re-verified this inventory live on 2026-08-10 and found it unchanged, including the cycle.
  Any divergence: stop and reconcile against the live state before proceeding.
- [x] Run the rename-cost grep preflight the research flags as NOT yet run (report 01 Gap 4; not
  contradicted by report 02): for each old slug —
  `414_refactor_semantics_to_maximal_history_validity`,
  `415_completeness_over_maximal_history_semantics`,
  `420_align_task_frame_with_positive_cone_limit_nullity` — run
  `grep -rl '<slug>' specs/ --include='*.md'` AND `grep -c '<slug>' specs/state.json`, and also
  check `.return-meta.json` / `.orchestrator-handoff.json` files under each task directory.
  Record per-slug file lists and hit counts.
- [x] Enumerate, via `jq`, every `artifacts[].path` in state.json (any task) that points into
  `specs/414_*/`, `specs/415_*/`, or `specs/420_*/` — these must all be updated if the rename
  proceeds (the research expects 420 to have the widest surface: plan, report, summary,
  `.return-meta.json`, `.orchestrator-handoff.json`).
- [x] Decide rename-vs-record per task and write the decision (with measured counts) into the
  phase notes for Phase 2. Decision rule: rename when every hit is inside `specs/**` and
  enumerable in the Phase 2 batch; record-instead-of-rename when hits extend beyond what one
  atomic batch can consistently update (per the task's own instruction to record the decision
  and cost rather than leave dangling paths).
- [x] Capture the BEFORE state of the dependency graph: run
  `bash .claude/scripts/generate-task-order.sh --print` and save the output showing 415 in wave 1
  with `Blocked by: --` (the cycle symptom) for before/after comparison in Phase 6.
- [x] **Snapshot re-check (read-only, added in v02)**: record the paper's current HEAD SHA and the
  file's current md5 for `/home/benjamin/Philosophy/Papers/PossibleWorlds/JPL/possible_worlds.tex`,
  and compare against report 02's pinned snapshot (HEAD `98b52b41`, md5
  `aa0488c1fe6134e59256803ae891a5f2`, 3975 lines). ALSO re-grep the label inventory for
  `def:temporal-order`, `def:task-relation`, `def:directed`, `lem:constraint`, `lem:step`, and
  confirm `lem:segments` is absent. If the paper has drifted again, do NOT re-derive definitions
  (that is Part A work and out of scope) — record the drift in the phase notes, keep composing
  from report 02, and add the observed drift to the completion summary as evidence for the
  recurrence-prevention follow-up. Reading the paper is permitted; writing to it is not.

**Timing**: 0.5 hours

**Depends on**: none

**Verification Tier**: prose

**Scope Hypothesis**: The reports assert exactly six cluster tasks, exactly three rename
candidates (414, 415, 420), and an UNMEASURED grep surface for the three old slugs. Confirm the
six-task set and three-candidate list by the live `jq` re-query, and treat the grep hit counts as
the measurement this phase exists to produce — no count from either report or from the task
description may be assumed. The paper snapshot triple is likewise a hypothesis: report 02 pinned
it on 2026-08-10 against a working tree with uncommitted edits, so a mismatch is expected rather
than exceptional and is recorded, not treated as a blocker.

**Files to modify**: none (read-only phase; findings recorded in the Phase 2 execution notes)

**Verification**:
- Cluster re-query output matches the reports' inventory (or divergence is documented).
- All three greps executed with per-file hit lists recorded; rename-vs-record decision stated
  per task with its measured cost.
- Baseline `generate-task-order.sh --print` output saved.
- Paper snapshot SHA/md5 recorded and compared against report 02's pin; label-inventory re-grep
  results recorded.

#### Phase 1 Execution Notes (recorded 2026-08-10)

**Cluster re-query (live `jq`, `topic == "paper-refactor"`)** — matches both reports exactly, no
divergence:

```
420 align_task_frame_with_positive_cone_limit_nullity  blocked      deps=[415,438]
419 machine_check_co_reynolds_independence             not_started  deps=[438]
414 refactor_semantics_to_maximal_history_validity     researched   deps=[420,438]
415 completeness_over_maximal_history_semantics        researched   deps=[414,420,438]
417 semantic_fmp_finite_worldstate_over_z              researched   deps=[414,420,438]
427 sync_typst_book_with_refactored_paper              not_started  deps=[414,415,417,419,420,438]
438 reconcile_semantic_definitions_with_jpl_paper      implementing deps=[]
```

Directories exist for 414, 415, 417, 420 only; 419 and 427 have no task directory yet.

**Rename-cost grep (measured, per old slug)**

| Old slug | `*.md` hits | `state.json` hits | other files |
|---|---|---|---|
| `414_refactor_semantics_to_maximal_history_validity` | `specs/TODO.md`; 438 `plans/01`, `plans/03`; 438 `reports/01_teammate-b-findings.md`, `reports/01_team-research.md`; `specs/415_.../reports/01_completeness-maximal-history-rebase.md`; `specs/414_.../reports/02_group-c-reconciliation.md` (7) | 2 | `specs/414_.../.return-meta.json`, `specs/414_.../.return-meta-reconcile.json` |
| `415_completeness_over_maximal_history_semantics` | `specs/TODO.md`; 438 `plans/01`, `plans/03`; 438 `reports/01_teammate-b-findings.md`, `reports/01_team-research.md`; `specs/414_.../reports/02_group-c-reconciliation.md` (6) | 1 | `specs/415_.../.return-meta.json` |
| `420_align_task_frame_with_positive_cone_limit_nullity` | `specs/TODO.md`; 438 `plans/01`, `plans/03`; 438 `reports/01_teammate-b-findings.md`, `reports/01_team-research.md`; `specs/420_.../plans/01_taskframe-limit-nullity-alignment.md`; `specs/420_.../summaries/01_taskframe-limit-nullity-alignment-summary.md` (7) | 3 | `specs/420_.../.return-meta.json`, `specs/420_.../.orchestrator-handoff.json` |

**`artifacts[].path` entries pointing into the three directories** (enumerated via `jq`; all belong
to the owning task, no cross-task references):

- 420: `reports/01_taskframe-positive-cone-limit-nullity.md`, `plans/01_taskframe-limit-nullity-alignment.md`, `summaries/01_taskframe-limit-nullity-alignment-summary.md` (3)
- 414: `reports/01_maximal-history-validity-refactor.md`, `reports/02_group-c-reconciliation.md` (2)
- 415: `reports/01_completeness-maximal-history-rebase.md` (1)

**Rename-vs-record decision: RENAME all three.** Every measured hit is inside `specs/**` and is
enumerable in a single Phase 2 batch. The only `*.md` hits outside the moved directories are
(a) `specs/TODO.md`, which is regenerated from state.json and never hand-edited, and (b) task
438's own reports and plan v01, which are frozen historical artifacts (a non-goal forbids
content-modifying them) and whose old-slug mentions are historical prose by construction. Hits
*inside* the moved directories travel with the `git mv` and are likewise historical prose in
superseded reports. Live path references requiring update therefore reduce to exactly:
`project_name` (3) + `artifacts[].path` (6) in `specs/state.json`, plus the directory moves.

**Baseline `generate-task-order.sh --print` (BEFORE)** — cycle symptom confirmed present:

```
| 1 | 125,127,128,193,231,257,298,413,415,421,423,424,437,438 | -- | ...
| 2 | 178,219,282,296,419,420,422,425,436 | 193,231,298,415,421,423,437,438 | ...
| 3 | 169,414,434 | 420,422,436 | ...
| 4 | 362,417,432 | 169,414,434,438 | ...
| 5 | 427,433 | 417,419,432 | ...
```

415 appears in wave 1 with `Blocked by: --` despite declaring `dependencies = [414,420,438]` —
exactly the symptom report 01 Deliverable 5 predicted for the `420 <-> 415` cycle. Paper Refactor
group renders as `415 -> 420 -> 414 -> 417 -> 427`.

**Paper snapshot re-check — A FOURTH DRIFT WAVE HAS OCCURRED (recorded, not blocking).**

| | report 02's pin | observed 2026-08-10 (this dispatch) |
|---|---|---|
| repo | `/home/benjamin/Philosophy/Papers/PossibleWorlds` | same (note: the git root is `PossibleWorlds/`, not `Papers/`) |
| HEAD | `98b52b41` "task 66: complete implementation", 14:57 -0700 | **`c3da9852` "task 67: complete research", 16:05:57 -0700** |
| md5 of `JPL/possible_worlds.tex` | `aa0488c1fe6134e59256803ae891a5f2` | **`0225d65a3d995275c6565145c71dade0`** |
| line count | 3975 | **3943** |

Per the plan's contingency, no definitions were re-derived. Instead every quote this plan relies
on was re-read read-only and **all are confirmed verbatim at the new snapshot**:
`def:temporal-order` (:2409), `def:task-relation` (:2413, Fiber/Cone/Segment + converse
convention), `def:directed` (:2423), `def:frame` (:2427, four axioms, Spherical over "nonempty
fibers and segments"), `lem:nullity` (:2460), `def:world-history` (:2531, partial-history
primary, nonempty `X`, no convexity), `lem:constraint` (:2566), `lem:step` (:2584, including the
$\subseteq$-least-member closing remark), `thm:extension` (:2598, Zorn + Step Lemma),
`thm:occurrence` (:2630), `app:nonempty` (:2642), `def:BL-semantics` (:2658, box over $H_\F$, no
dom conjunct), `def:frame-validity` (:2832), `def:logical-consequence` (:3318). `lem:segments`
confirmed **absent**. `\Seg` survives only inside three `%% OLD:` comment lines — the macro is
retired from live text as report 02 records. The ℚ non-example footnote is at the world-history
sentence in the `sec:Construction` body and carries the full current text **including** the
closing sentence "*Spherical* is exactly what excludes this structure."

**Anchor correction for 419 discovered during the label re-grep**: neither `TMP-CO` nor `CO` is a
`\label{}`. They are `\aitem` axiom keys resolved by `\aref`: the base **TM** axiom is
`\aitem{CO}` inside `\label{sub:Extension}`, and the **TM$^+$** restatement is
`\aitem[CO]{TMP-CO}` inside `\label{def:TMplus-c}`. Report 01's "`\label{CO}` at :1217 /
`\label{TMP-CO}` at :3709" phrasing is therefore imprecise as well as line-stale; Phase 4 writes
the `\aitem`/enclosing-`\label` form instead.

This fourth wave is direct evidence for the recurrence-prevention follow-up and is carried into
the completion summary. Consequence for **C7**: the rewritten descriptions record BOTH baselines —
report 02's pin (`98b52b41` / `aa0488c1…`) as the generation the surviving research was audited
against, and this dispatch's re-verification snapshot (`c3da9852` / `0225d65a…`, 3943 lines) as
the most recent point at which every quoted definition was confirmed verbatim.

---

### Phase 2: Renames (or recorded rename decisions) [COMPLETED]

**Goal**: Execute the renames green-lit by Phase 1 — 414 -> `refactor_semantics_to_total_history_validity`,
415 -> `completeness_over_total_history_semantics`, 420 -> `align_task_frame_with_positive_cone_axioms`
(417, 419, 427 need no rename) — atomically per task, or record the decision-and-cost instead
where Phase 1 showed a wide surface. Renames run BEFORE the description rewrites so Phases 3-4
write descriptions against final paths. Report 02 explicitly re-confirms these three rename
targets: they name totality and the four-axiom frame, both of which the finalized paper confirms.

**Tasks**:
- [x] For each green-lit rename, as ONE batch per task: (a) update `project_name` in state.json;
  (b) `git mv specs/{NNN}_{old_slug} specs/{NNN}_{new_slug}`; (c) update every `artifacts[].path`
  entry in state.json referencing the old directory (in the task's own record and any other
  task's record found by Phase 1); (d) update every `specs/**/*.md` reference from Phase 1's hit
  list (superseded report files keep their historical prose — only live path references change;
  a report's own internal mention of the old name as history is acceptable per the rename-surface
  analysis).
- [x] For any task where Phase 1 decided record-instead-of-rename: leave `project_name` and the
  directory untouched, and add the decision + measured cost to the notes Phase 3/4 will fold
  into that task's rewritten description. *(deviation: not applicable — Phase 1 green-lit all three renames; no task took the record-instead-of-rename path)*
- [x] Validate state.json with `jq empty` after each batch; run
  `bash .claude/scripts/generate-todo.sh` and confirm it exits 0.
- [x] Confirm zero dangling paths: re-run the Phase 1 greps for each old slug; every remaining
  hit must be inside a superseded report file as historical prose, justified in the phase notes.

**Timing**: 1 hour

**Depends on**: 1

**Verification Tier**: local

**Commit Mode**: atomic-batch

**Scope Hypothesis**: Three renames expected (report 01 Recommendation 3, re-confirmed by report
02 §4), with 420 carrying the widest artifact surface (3+ `artifacts[].path` entries plus
`.return-meta.json` and `.orchestrator-handoff.json`) and 414/415 low surface (reports only, no
plan/summary). Confirm against Phase 1's measured hit lists before executing; the batch file set
for each rename is exactly Phase 1's enumeration for that slug, fixed before the batch starts.

**Files to modify**:
- `specs/state.json` — `project_name` and `artifacts[].path` entries for renamed tasks
- `specs/{414,415,420}_*/` — directory renames via `git mv`
- `specs/TODO.md` — regenerated (never hand-edited)
- Any `specs/**/*.md` live path references from Phase 1's hit list

**Verification**:
- `jq empty specs/state.json` passes; `generate-todo.sh` exits 0.
- Old-slug greps return only justified historical-prose hits; `ls specs/` shows the new
  directory names; every `artifacts[].path` in state.json resolves to an existing file.

#### Phase 2 Execution Notes

**All three renames executed** (Phase 1's decision rule was satisfied for each — every measured
hit was inside `specs/**` and enumerable in one batch):

| Task | Old directory | New directory |
|---|---|---|
| 414 | `specs/414_refactor_semantics_to_maximal_history_validity/` | `specs/414_refactor_semantics_to_total_history_validity/` |
| 415 | `specs/415_completeness_over_maximal_history_semantics/` | `specs/415_completeness_over_total_history_semantics/` |
| 420 | `specs/420_align_task_frame_with_positive_cone_limit_nullity/` | `specs/420_align_task_frame_with_positive_cone_axioms/` |

Batch contents: `git mv` of the three directories; `project_name` updated for 414/415/420;
6 `artifacts[].path` entries rewritten (420 x3, 414 x2, 415 x1) — all owned by the renaming task
itself, no cross-task artifact path pointed into a moved directory. `jq empty specs/state.json`
passes; the diff is 12 insertions / 12 deletions with no incidental reformatting.
`generate-todo.sh` exits 0.

Additionally, the five ephemeral dispatch-scratch files that travelled with the moved directories
had their embedded self-paths rewritten so no dangling path survives:
`414/.return-meta.json`, `414/.return-meta-reconcile.json`, `415/.return-meta.json`,
`420/.return-meta.json`, `420/.orchestrator-handoff.json` (all re-validated with `jq empty`).

**Residual old-slug hits — all justified as historical prose, none a live path reference**:

| File | Justification |
|---|---|
| `specs/414_.../reports/02_group-c-reconciliation.md` | superseded report; names the old slugs as the state of the world when written |
| `specs/415_.../reports/01_completeness-maximal-history-rebase.md` | same |
| `specs/420_.../plans/01_taskframe-limit-nullity-alignment.md`, `.../summaries/01_...-summary.md` | 420's own landed phase-1-5 artifacts, historically accurate |
| 438 `plans/01_reissue-paper-refactor-cluster.md`, `reports/01_teammate-b-findings.md`, `reports/01_team-research.md` | frozen Part A artifacts; a non-goal forbids content-modifying them |
| 438 `plans/03_reissue-paper-refactor-cluster.md` (this file) | names the old slugs as the rename *sources*, which is the point |

**Pre-existing unrelated defect observed** (recorded, not fixed — outside this task's scope): the
`artifacts[].path` resolution sweep flagged one missing file repo-wide,
`specs/418_fix_tableau_engine_crossworld_temporalcopy_unsoundness_in_boxnegdiamondpos/artifacts/after-verdicts.md`,
belonging to task 418. It is unrelated to this cluster and predates this dispatch. All six paths
touched by the renames resolve.

---

### Phase 3: Rewrite descriptions and reset status — tasks 414, 415, 417 [NOT STARTED]

**Goal**: Re-issue the three research-invalidated tasks: rewrite each `description` from report
01's Deliverable 4 "Re-issued description must say" content **overlaid with report 02's
corrections C1-C7 and its two corrected earlier errors**, and set each status to `not_started`
(their target predicate changed from `IsMax`-maximality to totality, so existing research was
conducted against the wrong target).

**CONTENT SOURCE RULE (binding on every checklist item below)**: open BOTH reports. Report 01
Deliverable 4 supplies the skeleton and everything report 02 did not touch. Report 02 supplies
Findings §1(b), §1(c), §2, §3, and §4 — and **wins every conflict**. Composing any sentence from
report 01 that C1-C7 corrects is the defect this revision exists to prevent.

**Tasks**:
- [ ] **414**: rewrite the description to state — target predicate for `TruthAt`'s box clause,
  `valid`, `SemanticConsequence`, `satisfiable`, and `H_F` is TOTALITY (`∀ t, τ.domain t`), not
  Mathlib `IsMax`; the `Preorder`/Zorn/`chainSup`/`isMax_timeShift` prototype survives as reusable
  engine material but is not the destination API; the Group C dead/live/portable bucketing
  (88/16/8) survives as verified-as-transcribed but NOT re-derived against the current tree —
  carry both halves, never present the counts as fresh; preserve all still-valid
  scope/non-goal/notation content including the superscript-inverse converse convention.
- [ ] **414 — apply C3**: state the paper's layering `partial ⊃ world ⊃ total` using
  **partial-history** vocabulary throughout ("task-constrained function" is retired). Fold in the
  `PartialHistory`/`WorldHistory` layering decision and the **corrected earlier error 1**: Lean
  `WorldHistory` has NO nonempty-domain field, so report 01's "match" verdict on the base
  definition is a match on four of five conjuncts, and a faithful `thm:extension` transcription
  needs the nonemptiness field or an explicit empty-case argument the paper does not make. Report
  02's Recommendation 4 places this decision in 414/420's scope, to be made ONCE before the
  consequence refactor, not after.
- [ ] **414 — apply C2**: use `[w, v]_x^y` bracket notation with `[w, v]_x^y := Fib(w, x) ∩
  Fib(v, -y)` spelled out; `Seg(...)` is not current notation (the macro is deleted). Spherical
  ranges over directed families of nonempty **fibers and segments** as separate classes, with
  directedness per `def:directed`.
- [ ] **414 — apply C1**: anchors are `\label{def:temporal-order}`, `\label{def:task-relation}`,
  `\label{def:directed}`, `\label{def:frame}`, `\label{def:world-history}`, `\label{lem:nullity}`,
  `\label{lem:constraint}`, `\label{lem:step}`, `\label{thm:extension}`, `\label{thm:occurrence}`,
  `\label{app:nonempty}`, `\label{def:BL-semantics}`, `\label{def:frame-validity}`,
  `\label{def:logical-consequence}`. No `lem:segments` (it no longer exists). No bare line
  locators — every `:2412`/`:2570`/`:1833`-style citation inherited from earlier generations is
  purged.
- [ ] **414 — apply C6**: the cross-task acceptance criterion shared with 420 reads "Spherical's
  Lean statement must be literally the hypothesis **`lem:step`'s** proof consumes, not an inert
  field" — re-pointed from `thm:extension`.
- [ ] **414 — corrected earlier error 2**: state that `valid` and `SemanticConsequence` ALREADY
  carry `[Nontrivial D]` (`Validity.lean:80`, `:104`), so the binder gap is only at the
  `TaskFrame` **structure** level (missing `[Nontrivial D]` binder and `Nonempty WorldState`
  field). The consequence-level delta is exactly: drop `Omega`/`ShiftClosed`/`τ ∈ Omega`, add the
  totality constraint on `τ`. Do NOT restate report 01 Deliverable 2's overstated binder delta.
  Also carry report 02 item c3: `untl`/`snce` are the Lean primitives and their binders must be
  rewritten by the totality refactor too.
- [ ] **414 — new coupling material from report 02 §3**: `thm:extension` is CHEAPER than report 01
  estimated because the paper now supplies the lemma decomposition (`lem:constraint` -> `lem:step`
  -> Zorn) report 01 said Lean would have to invent; the Lean development should mirror it
  lemma-for-lemma per the literature-fidelity policy; the Zorn engine from 414's prototype
  retargets to `PartialHistory` with the final "maximal ⇒ total" step going through `lem:step`.
- [ ] **414 — optional deliverable (report 02 Recommendation 5)**: name the frame-relative
  validity gap explicitly — `def:frame-validity`'s `⊨_F` has no Lean counterpart and is the
  natural home for `app:nonempty`'s never-vacuous theorem. Mark it OPTIONAL, not required scope.
- [ ] **415**: rewrite to state — countermodel family is the full TOTAL-history set `H_F`, not
  maximal; staging plan (Discrete -> Dense -> Base -> Dedekind) and deterministic lead-frame
  (`bundleFlowFrame`) strategy survive and are plausibly totality-favorable (report 01, untouched
  by report 02); every canonical/chronicle construction must discharge Seriality, Limit ("Limit
  Nullity" name retired), and Spherical, with Spherical flagged least routine; biconditional
  Compositionality (interpolation direction) is a new proof obligation for constructions that
  relied on the lax inclusion only. Apply **C1**, **C2**, **C3** to all definitional statements
  in the rewrite.
- [ ] **417**: rewrite to state — target totality per 414's corrected charter; the "Limit
  automatic over Z" claim survives verbatim under the renamed "Limit" axiom
  (`limit_nullity_of_succOrder`). Apply **C5** in place of report 01's weaker lead: over discrete
  `D = ℤ` the constraint family has a `⊆`-least member so the STEP EXTENSION is Spherical-free
  (quote `lem:step`'s closing remark), while the Spherical AXIOM must still be discharged for the
  frame instance; the finite-`W` pigeonhole lead stands separately as a lead to verify, not
  assume. Whether Seriality is also automatic over `ℤ` remains an open question for 417's next
  research pass. Apply **C1** and **C3** to definitional statements.
- [ ] In all three descriptions: carry `\label`-based paper anchors only, each accompanied by the
  quoted definition TEXT verbatim so a renamed label stays detectable by text search (pinned-
  snapshot discipline); name explicitly which prior research survives and which is superseded,
  distinguishing report 01-superseded-by-02 items from report 01 items that still stand, so the
  next agent does not silently re-consume a refuted finding; and apply **C7** — instruct the next
  research dispatch to check the paper's git log against the pinned baseline (HEAD `98b52b41`,
  md5 `aa0488c1fe6134e59256803ae891a5f2`, 2026-08-10) as its literal FIRST step before re-reading
  any definition, with the explicit warning that the file changes intra-day.
- [ ] Set `status` to `not_started` for 414, 415, 417 in state.json. Do not touch
  `next_artifact_number`; do not delete or modify any existing report file.
- [ ] Validate with `jq empty`; regenerate TODO.md via `generate-todo.sh`; re-read each of the
  three rewritten descriptions end to end against BOTH reports before committing.

**Timing**: 1.5 hours

**Depends on**: 2

**Verification Tier**: local

**Scope Hypothesis**: Exactly three descriptions rewritten and three statuses reset in this
phase, each applying its assigned subset of the seven corrections (414: C1,C2,C3,C6,C7 + both
corrected errors; 415: C1,C2,C3,C7; 417: C1,C3,C5,C7). Confirm at execution time that no
additional task has been added to the cluster since Phase 1's re-query (re-check
`topic == "paper-refactor"` before editing).

**Files to modify**:
- `specs/state.json` — `description` and `status` fields for 414, 415, 417
- `specs/TODO.md` — regenerated

**Verification**:
- `jq empty` passes; `generate-todo.sh` exits 0; TODO.md shows the three tasks as [NOT STARTED].
- Each description re-read end to end; contains its `\label` anchors with verbatim quoted text,
  survives/superseded breakdown, the C7 snapshot-pinned git-log-first instruction, and (414) the
  `lem:step`-pointed cross-task acceptance criterion plus both corrected earlier errors.
- Zero occurrences of `lem:segments`, `Seg(`, or "task-constrained function" presented as current
  in any of the three descriptions (checked here, re-checked globally in Phase 7).

---

### Phase 4: Rewrite descriptions — tasks 419, 420, 427 (statuses stand) [NOT STARTED]

**Goal**: Re-issue the three tasks whose status is unchanged: description rewrites per report 01
Deliverable 4 **overlaid with report 02's C1-C7**, plus 420's revised `blockers` field. No status
transitions in this phase.

**CONTENT SOURCE RULE**: identical to Phase 3 — both reports open, report 02 wins conflicts,
report 01 authoritative for everything report 02 did not touch.

**Tasks**:
- [ ] **419** (stays `not_started`): replace the stale `possible_worlds.tex:3250` CO citation
  with `\label{TMP-CO}` (the `def:TMplus-c` restatement that `Formula.co` actually mirrors) and
  `\label{CO}` for the base-TM form; state that the converse direction (`co_derived`/`co_valid`)
  is done, sorry-free, and must not be redone. Flag the Spherical risk as the PRIMARY open
  question for the next research pass: the Q-flow countermodel sketch may not be a legitimate
  `TaskFrame` under the four-axiom `def:frame` and may need a different carrier — not softened to
  a routine conformance check.
- [ ] **419 — apply C4**: quote the CURRENT ℚ non-example footnote verbatim (the partial-history
  wording WITH the new forcing computation "since $\vert{u - (1 - s)} \leq 1 - s$ for every
  $s < 1$ forces $u \leq 0$"), NOT report 01's version, and do NOT cite `:926`. Record that the
  footnote carries no label of its own and that `def:world-history` is the durable formal anchor;
  it sits as a footnote to the world-history sentence in the `sec:Construction` body.
- [ ] **419 — apply C1 and C7**: purge every bare line locator; carry the pinned-snapshot
  baseline and the paper-git-log-first instruction (419 is one of the four re-run research
  dispatches). Note that the stale `possible_worlds.tex:3250` locator ALSO persists in
  `FormalSystem/Theorems/DedekindDerived.lean:359` and `FormalSystem/Syntax/Formula.lean:467` —
  419-relevant but OUT of task 438's write scope, so it is recorded in 419's description as work
  for 419, never edited here.
- [ ] **420** (stays `blocked` — report 01 Conflict 6, both teammates converged, re-affirmed by
  report 02 §4; phases 1-5 are landed/green/committed and must NOT be presented as undone):
  rewrite the description to state the CURRENT four-axiom `def:frame` with `\label{def:frame}` as
  the formal anchor and the axiom text quoted verbatim; inventory landed-vs-stale explicitly
  (PRESERVED from phases 1-5: citations, docstrings, the three bare-relation helper theorems
  `limit_nullity_of_succOrder`/`limit_nullity_of_shift`/`exists_uniform_radius_of_finite` —
  re-confirmed surviving verbatim by report 02 item a12 — and the LaTeX restatement scaffolding;
  STALE: the phase-5 LaTeX definition text is stale a second time, and phase 6 must be re-scoped
  to add Seriality, Spherical, and the interpolation direction together, not `limit_nullity`
  alone); note `nullity_identity`-as-field-vs-derived-lemma is an open design question (the paper
  asserts reflexivity only via `lem:nullity`, while Lean's field is the strictly stronger iff
  form).
- [ ] **420 — apply C2, C3, C6**: bracket notation `[w, v]_x^y` with its defining equation,
  fibers-and-segments as separate classes, `def:directed` directedness (C2); partial-history
  vocabulary and the `PartialHistory`/`WorldHistory` layering plus the Lean nonemptiness gap
  shared with 414 (C3 + corrected earlier error 1); and the `lem:step`-pointed cross-task
  acceptance criterion (C6). Apply **C1**'s anchor set including `lem:constraint`/`lem:step` and
  the deletion of `lem:segments`.
- [ ] **420 `blockers` field**: revise to (a) preserve the 415-phase-6 explanation (phase 6's
  `bundleFlowFrame` discharge still phase-waits on 415 even though the task-level edge is being
  dropped in Phase 6 — the compensating record from report 01 Deliverable 5), and (b) add that
  the description/phase-6 scope was stale a second time and the next research pass must re-scope
  phase 6 against the four-axiom target and the `lem:constraint`/`lem:step` proof architecture
  before resuming implementation.
- [ ] **427** (stays `not_started`): rewrite to state — do NOT use
  `latex/subfiles/02-Semantics.tex` as the model (it was rewritten by 420 phase 5 against the
  now-superseded THREE-axiom frame; the prior instruction would write wrong definitions into the
  book); model the typst restatement directly on the paper's `\label{def:frame}` and
  `\label{def:world-history}`, treating the LaTeX subfile as a fellow downstream consumer possibly
  still mid-sync; note latex and typst are stale by DIFFERENT amounts and BOTH are now a further
  generation behind than report 01 recorded (report 02 item a15: no `latex/` or `typst/` commits
  since 2026-08-08, so both now also lag the partial-history restatement and the notation change);
  the stale-site enumeration must be re-audited against the current four-axiom paper, not trusted
  from the prior description; 427 remains LAST in the cluster; audit scope beyond
  `02-semantics.typ` survives.
- [ ] **427 — apply C1, C2, C3**: the definitions 427 must write into the book use bracket segment
  notation with the defining equation, fibers-and-segments Spherical with `def:directed`
  directedness, and partial-history vocabulary — writing `Seg(...)`, `lem:segments`, or
  "task-constrained function" into the typst book is precisely the failure mode 427 exists to
  prevent.
- [ ] All three: `\label` anchors only, each with verbatim quoted definition text (pinned-snapshot
  discipline); survives/superseded breakdown distinguishing report 01-superseded-by-02 from
  report 01 items still standing; preserve still-valid scope/non-goal/notation content.
- [ ] Validate with `jq empty`; regenerate TODO.md; re-read all three rewritten descriptions end
  to end against BOTH reports before committing.

**Timing**: 1.5 hours

**Depends on**: 3

**Verification Tier**: local

**Scope Hypothesis**: Exactly three descriptions rewritten, one `blockers` field revised, zero
status transitions, with correction subsets (419: C1,C4,C7; 420: C1,C2,C3,C6 + corrected error 1;
427: C1,C2,C3). Confirm 420's status is still `blocked` and 419/427 still `not_started` at edit
time.

**Files to modify**:
- `specs/state.json` — `description` fields for 419, 420, 427; `blockers` field for 420
- `specs/TODO.md` — regenerated

**Verification**:
- `jq empty` passes; `generate-todo.sh` exits 0; statuses for 419/420/427 unchanged in TODO.md.
- 419's description contains `TMP-CO`/`CO` label anchors and the CURRENT ℚ non-example quote
  including the forcing computation, with no `:926` citation.
- 420's blockers field carries both the phase-6/415 wait and the re-scope requirement; 420's
  description carries the `lem:step`-pointed acceptance criterion and the landed-vs-stale
  inventory.
- 427's description names `def:frame`/`def:world-history` as the model and explicitly forbids the
  LaTeX subfile as source.
- Zero occurrences of `lem:segments`, `Seg(`, or "task-constrained function" presented as current
  in any of the three descriptions.

---

### Phase 5: SUPERSEDED banners on stale report files [COMPLETED]

**Goal**: Insert a one-line `> **SUPERSEDED** ...` banner at the top of each report file whose
content predates the four-axiom/totality generation, so a future agent opening the file directly
sees the warning (report 01 Gap 6 / Recommendation 5; unaffected by report 02 per its §4). Banner
insertion only — never delete, truncate, or otherwise rewrite any report content.

**Tasks**:
- [x] Insert the banner at the top of: 414's `reports/01_maximal-history-validity-refactor.md`
  and `reports/02_group-c-reconciliation.md`; 415's
  `reports/01_completeness-maximal-history-rebase.md`; 417's
  `reports/01_semantic-fmp-finite-worldstate.md` (its research targets `IsMaximal`, the same
  refuted predicate); and 420's report and summary
  (`01_taskframe-limit-nullity-alignment-summary.md` and its report) whose sections describe the
  three-axiom frame.
- [x] Banner text names WHAT superseded the file and where the verdict lives, e.g.:
  `> **SUPERSEDED** (2026-08-10): written against the three-axiom frame / maximal-history
  (IsMax) target, superseded by the paper's four-axiom def:frame + totality-based H_F. See
  specs/438_reconcile_semantic_definitions_with_jpl_paper/reports/01_team-research.md
  (Deliverable 4) for what survives, and reports/02_logical-consequence-discrepancy-audit.md
  (Findings 1b/4) for what report 01 itself got superseded on.` Adjust the survives-pointer per
  file; use post-Phase-2 (renamed) paths.
- [x] **Do NOT banner** task 438's own `reports/01_team-research.md`. It is partially superseded
  by report 02, but it remains an authoritative content source for everything report 02 did not
  touch, and a blanket SUPERSEDED banner would misrepresent that. If a pointer is wanted, it is a
  "see also report 02, which overlays this one and wins conflicts" note — record the decision
  either way in the phase notes rather than silently doing neither.
- [x] Confirm by diff that each change is a pure top-of-file insertion (banner + one blank
  line); no other line of any report is touched.

**Timing**: 0.5 hours

**Depends on**: 2

**Verification Tier**: prose

**Scope Hypothesis**: Approximately six files bannered (414 x2, 415 x1, 417 x1, 420 x2). The
research's minimum list names 420's reports/summary plus 414's and 415's reports; 417's report is
included by the same refuted-target criterion. Confirm the actual file inventory by listing each
task's `reports/`/`summaries/` directories at execution time — banner every file that states the
superseded three-axiom frame or `IsMax` target, and record the final count and list.

**Files to modify**:
- `specs/{414,415,417,420}_*/reports/*.md` and `specs/420_*/summaries/*.md` — top-of-file banner
  insertion only

**Verification**:
- `git diff` shows only prepended banner lines per file; every bannered file's remaining content
  is byte-identical; final banner inventory recorded.
- Task 438's own `reports/01_team-research.md` and `reports/02_*.md` and
  `plans/01_reissue-paper-refactor-cluster.md` are untouched.

#### Phase 5 Execution Notes

**Final banner inventory: 7 files** (the Scope Hypothesis estimated ~6; the seventh was added by
applying the phase's own stated criterion — "banner every file that states the superseded
three-axiom frame or `IsMax` target" — rather than the estimate):

| # | File | Why superseded |
|---|---|---|
| 1 | `specs/414_.../reports/01_maximal-history-validity-refactor.md` | `IsMax` validity target |
| 2 | `specs/414_.../reports/02_group-c-reconciliation.md` | `IsMax`-flavored replacement lemmas; counts never re-derived |
| 3 | `specs/415_.../reports/01_completeness-maximal-history-rebase.md` | maximal-history countermodel family |
| 4 | `specs/417_.../reports/01_semantic-fmp-finite-worldstate.md` | inherits 414's refuted `IsMaximal` target |
| 5 | `specs/420_.../reports/01_taskframe-positive-cone-limit-nullity.md` | three-axiom frame |
| 6 | `specs/420_.../summaries/01_taskframe-limit-nullity-alignment-summary.md` | three-axiom frame; phase-5 LaTeX text stale a second time |
| 7 | `specs/420_.../plans/01_taskframe-limit-nullity-alignment.md` | **added beyond the estimate** — 9 hits for "Limit Nullity"/"NOT adopted"; its phase-6 scope must be re-scoped against the four-axiom frame |

Every banner names both what superseded the file and where the verdict lives, and each carries a
file-specific survives-clause (not a generic pointer). All banners use post-Phase-2 renamed paths.

`git diff --numstat` reports exactly `2 0` for all seven files: two inserted lines (banner +
blank), zero deletions. No report content was modified.

**Decision recorded on task 438's own `reports/01_team-research.md`: NOT bannered, and no
see-also note added either.** Report 01 is partially superseded by report 02, but it remains the
authoritative content source for everything report 02 did not touch, and a SUPERSEDED banner
would misrepresent that. A "see also report 02" note was considered and declined because the
precedence rule already lives in a more durable place — the plan's Research Integration section
and every rewritten description's own survives/superseded breakdown state it explicitly — and
editing a frozen Part A artifact to duplicate it would contradict the non-goal forbidding
content-modification of that file. This is an explicit decision, not an omission.

---

### Phase 6: Dependency edge correction and acyclicity verification [NOT STARTED]

**Goal**: Apply report 01 Deliverable 5's corrected edge set — remove exactly one edge (`415` from
`420.dependencies`, breaking both the 2-cycle `420 <-> 415` and the 3-cycle
`420 -> 415 -> 414 -> 420` simultaneously) — and verify the graph is acyclic with 427 last. Report
02 §4 lists this phase as valid as written; no change from plan v01.

**Tasks**:
- [ ] Edit state.json: `420.dependencies` becomes `[438]` (415 removed). ALL other cluster edges
  stay exactly as declared: 414 `[420,438]`, 415 `[414,420,438]`, 417 `[414,420,438]`,
  419 `[438]`, 427 `[414,415,417,419,420,438]`. (The compensating record for the dropped edge —
  420's phase-6-still-waits-on-415 text — already landed in Phase 4's blockers revision; confirm
  it is present.)
- [ ] Validate with `jq empty`; regenerate TODO.md via `generate-todo.sh`.
- [ ] Run `bash .claude/scripts/generate-task-order.sh --print` and verify all four Deliverable 5
  checks against the Phase 1 baseline: (a) 415 no longer appears in wave 1 with `Blocked by: --`;
  (b) 415's wave lists 414 and 420 among its blockers; (c) 420 lands in an earlier wave than
  414/415/417; (d) 427 is in the final wave of the Paper Refactor group.

**Timing**: 0.5 hours

**Depends on**: 4

**Verification Tier**: local

**Scope Hypothesis**: Exactly ONE edge removed; every other dependency array unchanged. Confirm
by diffing the six tasks' `dependencies` arrays before/after the edit — any second changed array
is an error.

**Files to modify**:
- `specs/state.json` — `420.dependencies` only
- `specs/TODO.md` — regenerated

**Verification**:
- `generate-task-order.sh --print` passes all four checks (a)-(d); output saved next to the
  Phase 1 baseline for the summary.

---

### Phase 7: Final verification, regeneration, and closing commit [NOT STARTED]

**Goal**: Run the task description's mandated end-to-end verification over the finished state
with the EXTENDED forbidden-token list, regenerate TODO.md a final time, and land the closing
commit of state.json + TODO.md together.

**Tasks**:
- [ ] Re-read all six rewritten descriptions end to end (extract each via `jq` and read in
  full), confirming: current four-axiom `def:frame` + totality-based consequence stated as
  settled inputs; partial-history vocabulary and bracket segment notation; `\label` anchors with
  verbatim quoted text; survives/superseded breakdown present; still-valid content preserved.
- [ ] **Bare-locator gate**: grep the six descriptions for `possible_worlds\.tex:[0-9]` — any hit
  must be a parenthetical locator written beside a `\label`, never a citation in itself. Also
  grep for the specific stale locators report 02 named: `:2412`, `:2570`, `:926`, `:912-913`,
  `:949-960`, `:1833`, `:3250`. The `:3250` case has a legitimate remaining home — 419's
  description recording the two `FormalSystem/` files that still carry it as 419's own future
  work — and that hit is justified, not removed.
- [ ] **Extended superseded-vocabulary grep** over the six descriptions. Plan v01's five terms,
  PLUS four added in this revision for the newly superseded machinery:
  1. `Limit Nullity` (v01)
  2. `lax` (v01)
  3. `maximal-history` (v01)
  4. `IsMaximal` (v01)
  5. `NOT adopted` (v01)
  6. `Seg(` — the retired `\Seg(w, v; a, b)` notation whose macro is deleted from the paper (NEW)
  7. `lem:segments` — the deleted lemma (NEW)
  8. `task-constrained` — the retired history vocabulary (NEW)
  9. `count among the segments` / `counting among the segments` — the retired old-Spherical
     fibers-as-degenerate-segments phrasing (NEW; also grep the bare phrase `nonempty segments`,
     which was the OLD Spherical statement's object and is now `nonempty fibers and segments`)

  Zero hits is NOT the target — hits inside explicit supersession framing (e.g. naming the refuted
  prior target, or a "superseded: X" line) are expected and correct. Every remaining hit must be
  individually justified in the implementation summary, and **any hit presenting superseded
  content as CURRENT is a defect to fix before closing**.
- [ ] **Positive-presence gate** (the complement of the forbidden-token grep — a description can
  avoid every forbidden term and still be silently missing the correction): confirm each of the
  six descriptions contains the current-generation tokens it should, per its C-assignment —
  `lem:constraint` and `lem:step` (414, 415, 420, 427), `partial history` (414, 415, 420, 427),
  `[w, v]_x^y` or its ASCII rendering (414, 415, 420, 427), `def:directed` (414, 420, 427),
  `def:temporal-order` and `def:task-relation` (414, 420), and the pinned snapshot SHA
  `98b52b41` (414, 415, 417, 419).
- [ ] Confirm statuses: 414/415/417 `not_started`; 419/427 `not_started`; 420 `blocked` with the
  revised blockers field. Confirm no report file was deleted or content-modified (banners are
  insertions only): `git diff --stat` across the task shows no deletions in any `reports/` or
  `summaries/` file, and `plans/01_reissue-paper-refactor-cluster.md` is unmodified.
- [ ] Final `bash .claude/scripts/generate-todo.sh`; confirm TODO.md renders the renamed slugs
  and updated statuses; `jq empty specs/state.json` passes.
- [ ] Closing commit including `specs/state.json` + `specs/TODO.md` together (per deliverable 10;
  both research reports are already committed with Part A), message per git-workflow conventions
  with the session ID.
- [ ] Write the implementation summary listing: renames executed vs. recorded, banner inventory,
  the justified extended-vocabulary hits, the positive-presence gate results, the before/after
  `generate-task-order.sh` outputs, any paper drift observed in Phase 1's snapshot re-check, and
  the four Recommended Follow-Ups (424, ROADMAP.md staleness, the escalated recurrence-prevention
  meta task, frame-relative validity) so they land in the completion summary.

**Timing**: 0.5 hours

**Depends on**: 5, 6

**Verification Tier**: local

**Scope Hypothesis**: Nine forbidden-token terms and roughly six positive-presence token classes
are asserted here. The term lists are hypotheses about what superseded vocabulary actually
survives in the rewritten text — run every grep and record actual hit counts rather than assuming
the list is exhaustive; if a rewritten description surfaces a superseded phrase not on either
list, add it to the summary's recorded term list rather than silently passing.

**Files to modify**:
- `specs/TODO.md` — final regeneration
- `specs/438_reconcile_semantic_definitions_with_jpl_paper/summaries/03_*.md` — implementation
  summary (created by the implement dispatch per its own conventions)

**Verification**:
- All checklist greps run with outputs captured; every superseded-vocabulary hit justified; every
  positive-presence token confirmed present in its assigned descriptions.
- Closing commit contains state.json + TODO.md together; working tree clean for `specs/`.

## Testing & Validation

- [ ] `jq empty specs/state.json` passes after every phase that edits it.
- [ ] `bash .claude/scripts/generate-todo.sh` exits 0 after every state.json edit; TODO.md is
  never hand-edited.
- [ ] `bash .claude/scripts/generate-task-order.sh --print` post-Phase-6 passes the four checks:
  415 out of wave 1, 415 blocked by 414+420, 420 before 414/415/417, 427 last.
- [ ] Rename integrity: old-slug greps return only justified historical-prose hits; every
  `artifacts[].path` in state.json resolves to an existing file.
- [ ] Extended superseded-vocabulary grep (nine terms: "Limit Nullity", "lax", "maximal-history",
  "IsMaximal", "NOT adopted", "Seg(", "lem:segments", "task-constrained", the old-Spherical
  phrasings) across all six rewritten descriptions, with every remaining hit justified.
- [ ] Positive-presence gate: `lem:constraint`/`lem:step`, "partial history", `[w, v]_x^y`,
  `def:directed`, `def:temporal-order`/`def:task-relation`, and the pinned SHA `98b52b41` present
  in their assigned descriptions.
- [ ] Bare-locator gate: no `possible_worlds.tex:NNNN` citation stands alone without a `\label`
  beside it; the named stale locators are absent except where justified.
- [ ] No file under `FormalSystem/`, `latex/`, `typst/`, or `/home/benjamin/Philosophy/Papers/`
  is touched: `git status` shows changes confined to `specs/**`.
- [ ] No report file deleted or content-rewritten; SUPERSEDED banners are pure top-of-file
  insertions; `plans/01_reissue-paper-refactor-cluster.md` unmodified.

## Artifacts & Outputs

- `specs/438_reconcile_semantic_definitions_with_jpl_paper/plans/03_reissue-paper-refactor-cluster.md`
  (this file; plan v02, superseding plan v01 which remains on disk as history)
- Rewritten `description` (and 420 `blockers`) fields for tasks 414, 415, 417, 419, 420, 427 in
  `specs/state.json`
- Renamed task directories (subject to Phase 1 decision):
  `specs/414_refactor_semantics_to_total_history_validity/`,
  `specs/415_completeness_over_total_history_semantics/`,
  `specs/420_align_task_frame_with_positive_cone_axioms/`
- SUPERSEDED banners on ~6 stale report/summary files
- Corrected dependency graph (`420.dependencies = [438]`) verified acyclic
- Regenerated `specs/TODO.md`
- `specs/438_reconcile_semantic_definitions_with_jpl_paper/summaries/03_*.md` implementation
  summary carrying the four named follow-ups (task 424 exposure, ROADMAP.md staleness, the
  escalated recurrence-prevention meta task, frame-relative validity gap)

## Rollback/Contingency

All changes are git-tracked and land as per-phase (Phase 2: per-rename atomic) commits, so
rollback is `git revert` of the offending commit(s) — state.json, TODO.md, directory renames
(`git mv` reverts cleanly), and banner insertions are all fully reversible. If a rename batch
fails midway, do not commit: restore with the snapshot discipline (`git-snapshot.sh 438` before
any intentional discard, per git-workflow rules), fall back to the record-decision-instead-of-
rename path for that task, and proceed — a recorded rename decision satisfies deliverable 7. If
`generate-todo.sh` or `generate-task-order.sh` fails after a state.json edit, the edit is
reverted (not hand-patched forward) and re-applied via a validated jq rewrite. If Phase 1's
snapshot re-check finds the paper has drifted a fourth time, the contingency is to RECORD the
drift and proceed from report 02 — re-deriving definitions from the paper is Part A work and
would exceed this plan's scope; the recurrence-prevention follow-up is the durable fix. No Lean,
LaTeX, typst, or paper file is ever touched, so no build-level rollback exists or is needed.
