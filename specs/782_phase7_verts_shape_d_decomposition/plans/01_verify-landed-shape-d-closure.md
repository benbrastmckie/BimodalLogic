# Implementation Plan: Task #782

- **Task**: 782 - Phase7 verts shape d decomposition
- **Status**: [IMPLEMENTING]
- **Effort**: 1.5 hours
- **Dependencies**: None. Parent task 716 is `[COMPLETED]` and archived; this plan reads its
  records, it does not wait on them.
- **Research Inputs**: None (no report this round; `--fast`/forced-plan entry, Stage 1.5 assessment
  found the description plus the codebase sufficient). Durable records consulted at plan time:
  - specs/archive/716_sliced_certificate_liveat_nontermination/plans/02_shape-d-verts-biunion.md
    (Phase 7, the `### Decomposition Change (raised, not substituted)` subsection, and D7/D8)
  - specs/archive/716_sliced_certificate_liveat_nontermination/probes/21_shapeD_transfer.lean
    through 25_shapeD_landed_transfer.lean
  - specs/archive/716_sliced_certificate_liveat_nontermination/issues.jsonl entries
    iss_1791930247123_2yrlt6, iss_1791930803755_uNnWEO (the blocker) and
    iss_1791938399591_KHUXUs, iss_1791938700842_immZpN, iss_1791939778304_A8DJ5A (the landing)
  - commit fcd3ffcb0 (`task 716 phase 7: Shape D -- the posAt-hoisted verts and the succT/predT
    let-hoists`, 2026-10-13) and its parent on `Timed.lean`, 960e39ede
- **Artifacts**: plans/01_verify-landed-shape-d-closure.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

**Every deliverable in this task's description is already landed and recorded.** The task was
spawned as the blocker follow-up for the parent's Phase 7 (issue iss_1791930803755_uNnWEO, "needs
a planning decision, recorded via /revise"). The parent then took exactly that route: its revised
plan `02_shape-d-verts-biunion.md` records the Shape D decision (D7), raises the decomposition
change that drops `posTable`/`posAtC`/`posAtC_eq` (D8 and the `### Decomposition Change (raised,
not substituted)` subsection — the record `.claude/rules/plan-compliance.md` requires), and its
Phase 7 landed the `biUnion`-shaped `verts` together with the `succT`/`predT` `let`-hoists in
commit fcd3ffcb0. Its Phase 9 ran the full gate set green, and the parent is `[COMPLETED]` and
archived. Nothing on `Timed.lean` has changed since (`git log -- …/Timed.lean` shows fcd3ffcb0 as
the latest commit).

This plan therefore does **not** re-implement anything, and it edits **no `FormalSystem/**`
file**. It is a verification-and-closure round: re-derive on the current tree every claim the
description makes (the body shapes, the absence of any position cache, the byte-identical
characterization statements, the `rfl` transfer across `withBx`, the axiom profiles, and — as
this round's own measurement — the isolated `verts` factor), run the repository's full gate, and
write the summary that becomes this task's durable record of **where** its scope was discharged.
Definition of done: every acceptance check in Phase 1 passes on the current tree with its output
recorded, the Phase 2 gate set is green, and the summary states plainly that this task changed no
source file and why.

A non-blocking `user_decision` accompanies this plan: the user may prefer to abandon the task as
superseded rather than spend an implement round on verification. The plan proceeds on the
recommended option (verify and close) unless told otherwise — see Decisions, D1.

### Research Integration

No research report this round. The plan-time Stage 1.5 assessment read the parent's archived plan,
probes and issue log directly, and re-derived the one claim everything else rests on:
`probes/25_shapeD_landed_transfer.lean` (the three `withBx` `rfl` transfers against the **landed**
`verts`/`succT`/`predT`, with an explicit finite `maxHeartbeats 200000`) compiles standalone
against HEAD d034460fd via `lake env lean` in 1.9 s, exit 0, and its three `#print axioms` lines
report `[propext, Classical.choice, Quot.sound]` for `mem_verts`, `mem_succT`, `mem_predT` with no
`sorryAx`. The remaining figures in this plan (15 ms vs 1093 ms at `certA`, card 16; 27 `withBx_`
references in `Complete.lean`) are CARRIED and named as such where they appear; Phase 1 re-derives
them.

### Prior Plan Reference

No prior plan for this task. The parent's plan `02_shape-d-verts-biunion.md` is the reference for
what was landed and how it was verified: its Phase 7 verification list (probe 25 before the
aggregate build, byte-identical `mem_*` statements, `grep -n 'posTable\|posAtC\|find?'` empty,
`withBx_` count unchanged, axiom pins) is adopted here as this task's acceptance bar, because it
is the bar the description's three deliverables were written against. Its effort calibration
(Phase 7 at 2 h including the edit) bounds this verification-only round well under that.

### Roadmap Alignment

No ROADMAP.md found (no `roadmap_path` in the delegation context; `specs/ROADMAP.md` not consulted).

## Goals & Non-Goals

**Goals**:

Lean declarations added by this task: **none**. The task adds no identifier, re-proves nothing,
and changes no statement — the pinned identifier set under this heading is deliberately empty, and
the Lean Challenge Statements section below is empty to match.

- Re-derive, on the current tree, that the body of PlusSlicedCertificate.verts is the
  `Finset.biUnion` over G.winTimes of the image of G.posAt, that PlusSlicedCertificate.succT and
  PlusSlicedCertificate.predT carry the three-binding let-hoists, and that Timed.lean contains no
  position table, no posAtC, and no `List.find?` lookup inside any `Finset.filter` predicate.
- Re-derive that the statements of PlusSlicedCertificate.mem_verts,
  PlusSlicedCertificate.mem_succT and PlusSlicedCertificate.mem_predT are byte-identical to their
  pre-Shape-D form at commit 960e39ede, and that each depends only on propext, Classical.choice and
  Quot.sound.
- Re-derive that the landed definitions transfer across PlusSlicedCertificate.withBx by rfl under
  a finite explicit heartbeat cap, and that Complete.lean's withBx_* lemma surface and its recorded
  third instance of the stuck-matcher pattern are intact.
- Measure, as this round's own figure, the isolated verts factor of the landed shape against the
  pre-Shape-D filter shape at the width-2 total-edge witness certA, and record it beside the
  carried figures without re-litigating the route.
- Confirm the decomposition-change record exists where plan-compliance.md requires it to have been
  raised (the parent's archived plan), and cite it by heading from this task's summary rather than
  duplicating it.
- Run the repository's full gate set and write the summary recording that this task's scope was
  discharged by the parent's Phase 7 at commit fcd3ffcb0, with no source file modified here.

**Non-Goals**:

- **No edit to any `FormalSystem/**` file.** If a Phase 1 check fails, this task does not repair
  it: the failing phase is marked `[BLOCKED]` and raised (plan-compliance.md's
  escalate-rather-than-substitute rule) — a repair is a different task with its own plan.
- No re-derivation of the parent's diagnosis and no re-litigation of its Phase 6 gate or its D7
  route decision; a measured factor that differs from a carried one is recorded, not acted on.
- No position table, no `posAtC`, no `posAtC_eq`, and no propositional `withBx_*` transfer lemma
  in `Complete.lean` — the parent's Non-Goals stand, and this task does not reopen them.
- No `maxHeartbeats` bump anywhere, and no `maxHeartbeats 0` in any probe: every scratch file
  carries an explicit finite cap.
- No change to task 781's question (the Phase 5 inner-fixpoint hoist in `LiveFix.lean`); that
  task owns the stay-or-revert decision and this plan neither measures nor touches it.
- No duplication of the parent's decomposition-change record into this task's artifacts — it is
  cited by file and heading, not copied.
- No `sorry`, no new axiom, no `#eval` of anything but `Finset` cards and a `Bool` equality in the
  measurement probe.

## Decisions

- **D1 — Verify-and-close rather than abandon, raised as a non-blocking `user_decision`.** Two
  reasonable dispositions exist for a task whose scope the parent absorbed: close it through a
  verification round that leaves a durable record in its own directory, or abandon it as
  superseded. The artifacts cannot infer the user's preference. The plan recommends and proceeds on
  the first: the cost is one bounded implement round with no source edit, and the payoff is a
  record — in this task's own `summaries/` — that re-derives every carried claim on today's tree
  rather than trusting the parent's figures by reference. `blocking: false`, because proceeding on
  the recommendation costs nothing that abandonment would recover.
- **D2 — The acceptance bar is the parent's Phase 7 verification list, re-run, not a new one.**
  The description's three deliverables were written against that bar; inventing a different one
  here would make "landed" mean something the parent never claimed.
- **D3 — Empty Goals, and what that means for the Challenge snapshot.** This task adds no
  declaration, so `- **Goals**:` names no identifier and `## Lean Challenge Statements` declares
  none. `lean-challenge-snapshot.sh` will therefore report `no identifiers found under **Goals**:
  … nothing to snapshot` (exit 71). That is the correct verdict for this task, not a defect: the
  snapshot tool is opt-in (`--compare`) and advisory, and it exists for greenfield theorems — the
  three pre-existing `mem_*` lemmas cannot be re-declared in a Challenge module that imports the
  file already declaring them. Statement fidelity for those three is checked instead by Phase 1's
  byte-identical signature comparison against commit 960e39ede.
- **D4 — Measure the isolated factor against a re-declared old shape, not against the landed
  name.** The parent's probe 24 timed `vertsD` beside the then-landed filter-shaped `verts`; today
  `verts` *is* Shape D, so re-running probe 24 verbatim would time Shape D against itself. The
  measurement probe re-declares the pre-Shape-D body under a scratch name (`vertsOld`, taken
  verbatim from commit 960e39ede) and times both. The figures are evidence for the summary, not a
  gate: no phase outcome depends on the factor.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| A Phase 1 check fails because `Timed.lean` or `Complete.lean` drifted since fcd3ffcb0 | H | L | `git log -- …/Timed.lean` at plan time shows fcd3ffcb0 as the latest commit and probe 25 compiles against HEAD; if a check nevertheless fails, Phase 1 is marked `[BLOCKED]` and raised — this plan has no repair phase by design (Non-Goals, plan-compliance.md) |
| The deployed `.claude/` tree is stale for the `core` extension (flagged in this dispatch's context), so a gate script in Phase 2 misbehaves or `verify-deploy.sh` reports the staleness itself | M | M | Phase 2's first task checks freshness and redeploys with the bounded-wait idiom (`timeout 540 bash .claude/scripts/deploy-headless.sh`, Bash `timeout` raised to 600000) before any gate runs; no file under `.claude/**` is hand-patched |
| Concurrent sibling (task 618, research on `Semantics/Presheaf/Path.lean`) or a foreign build on the shared tree | M | L | File scopes are disjoint; the territory discipline applies anyway: re-read before every check, commit only this task's own files by explicit path, never `git-snapshot.sh` in reverting mode, and STOP on any foreign modification or running build after a `git log` check |
| Full build wall-clock on a loaded host exceeds the dispatch budget | M | M | Run the guarded build detached per `context/patterns/bounded-build-waiter.md` (hard timeout 1800 s, `kill -0` on the captured PID, one waiter per log); the build is a no-op rebuild if `.lake` is current, which plan time suggests (oleans for `Complete`/`Examples` present) |
| The measurement probe's old-shape `#eval` is slow (the carried figure is ~1.1-1.4 s at `certA`) or the factor differs from the carried 73x | L | M | Cap is explicit and finite (2000000, the parent's probe-24 cap); a different factor is recorded as this round's measurement with the carried one beside it, per Non-Goals |
| `lean-challenge-snapshot.sh` run under `--compare` exits 71 on the empty Goals | L | H | Expected and documented (D3); advisory-only, opt-in; the summary names it so a reader does not read it as a failure |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |

Phases within the same wave can execute in parallel.

### Phase 1: Re-derive the landed Shape D state against the acceptance bar [COMPLETED]

**Goal**: Every claim the task description makes about the landed `Timed.lean` is confirmed on the
current tree by a command whose output is recorded, and the isolated `verts` factor is measured
this round. No source file is edited.

**Tasks**:
- [x] Create `specs/782_phase7_verts_shape_d_decomposition/progress-file.md` and record HEAD
      (`git rev-parse HEAD`), the latest commit on `Timed.lean`
      (`git log -1 --format=%h -- FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Timed.lean`,
      expected fcd3ffcb0), and `git status --porcelain FormalSystem/` (expected empty) before any
      other check. A foreign uncommitted modification or a foreign build here is a STOP-and-report
      per the territory contract, not a check failure.
- [x] **Body shapes.** Re-read `Timed.lean` immediately beforehand, then confirm by
      `grep -n -A1 '^def verts\|^def succT\|^def predT' …/Timed.lean` that `verts`'s body is exactly
      `G.winTimes.biUnion (fun t => (G.posAt t).image (fun p => (p, t)))` and that `succT`/`predT`
      each open with `let V := G.verts`, bind `u` to `G.nextTime v.2` / `G.prevTime v.2` and `S`/`P`
      to `G.succP v.2 v.1` / `G.predP v.2 v.1`, and filter `V` on `w.2 = u ∧ w.1 ∈ S` (resp. `∈ P`).
      Confirm `grep -n 'posTable\|posAtC\|find?' …/Timed.lean` returns nothing. Record both outputs.
- [x] **Statement fidelity.** Confirm the three characterization statements are byte-identical to
      their pre-Shape-D form: for each of `mem_verts`, `mem_succT`, `mem_predT`, compare
      `grep -n -A2 '^theorem NAME ' …/Timed.lean` against the same grep over
      `git show 960e39ede:FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Timed.lean`;
      the signature lines must agree exactly. The pinned statements, for the record:

      ```lean
      theorem mem_verts (G : PlusSlicedCertificate Γ Del) (v : G.TPos) :
          v ∈ G.verts ↔ v.2 ∈ G.winTimes ∧ v.1 ∈ G.posAt v.2
      theorem mem_succT (G : PlusSlicedCertificate Γ Del) (v w : G.TPos) :
          w ∈ G.succT v ↔ w ∈ G.verts ∧ (w.2 = G.nextTime v.2 ∧ w.1 ∈ G.succP v.2 v.1)
      theorem mem_predT (G : PlusSlicedCertificate Γ Del) (v w : G.TPos) :
          w ∈ G.predT v ↔ w ∈ G.verts ∧ (w.2 = G.prevTime v.2 ∧ w.1 ∈ G.predP v.2 v.1)
      ```
- [x] **`withBx` transfer and axiom profiles.** Copy the parent's
      `probes/25_shapeD_landed_transfer.lean` to
      `specs/782_phase7_verts_shape_d_decomposition/probes/01_shapeD_landed_transfer.lean`
      (header comment updated to name this task's directory; cap stays `maxHeartbeats 200000`,
      deliberately not raised — the failure mode it guards is `isDefEq` returning false, which no
      cap bump reaches). Compile standalone: `lake env lean <probe>` exits 0 with the three `rfl`
      `example`s accepted, and the three `#print axioms` lines list only
      `[propext, Classical.choice, Quot.sound]` with no `sorryAx`. Record the exit code, the axiom
      lines and the wall clock. (Plan-time re-derivation against d034460fd: exit 0, 1.9 s.)
- [x] **`Complete.lean` surface.** Confirm `grep -c 'withBx_' …/Complete.lean` reports 27 (CARRIED
      from issue iss_1791938399591_KHUXUs; re-derived at plan time as 27) and that the
      `### What a changed box guess does and does not move` section still carries the recorded third
      instance of the stuck-matcher pattern (`grep -n 'List.find?' …/Complete.lean` is non-empty).
      Whether every `rfl`-proved `withBx_*` lemma there still elaborates is the full build's job in
      Phase 2, not a grep's.
- [x] **Isolated factor, measured this round (D4).** Write
      `specs/782_phase7_verts_shape_d_decomposition/probes/02_old_vs_landed_measure.lean`:
      `import FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.Examples`,
      `set_option maxHeartbeats 2000000`, then inside
      `namespace FormalSystem.Metalogic.Decidability.PlusSlicedCertificate` declare
      `def vertsOld (G : PlusSlicedCertificate Γ Del) : Finset G.TPos :=
      (Finset.univ ×ˢ G.winTimes).filter (fun v => v.1 ∈ G.posAt v.2)` (the body at 960e39ede,
      verbatim) and, with `open TotalEdge in`, the three lines `#time #eval (certA.verts).card`,
      `#time #eval (certA.vertsOld).card`, `#time #eval (certA.verts = certA.vertsOld)`. Compile with
      `lake env lean`; record the three figures beside the CARRIED pair **15 ms vs 1093 ms, card 16**
      (task description / parent probe 24) and the docstring's **21 ms vs 1358 ms**
      (`Timed.lean`, `verts` docstring). Both cards must read 16 and the equality must print `true`;
      the factor is recorded whatever it is.
- [x] **Decomposition-change record.** Confirm the raised record exists:
      `grep -n '^### Decomposition Change\|^- \*\*D8\*\*' specs/archive/716_sliced_certificate_liveat_nontermination/plans/02_shape-d-verts-biunion.md`
      returns both lines. Record the line numbers for the summary to cite by heading. Add nothing
      to the parent's archived plan.
- [x] Record via `issue-record.sh` (`--phase implement --dispatch-seq <this dispatch>`) anything
      that arises — a check that needed a second look, a figure that moved, a smooth run — or
      attest explicitly in `progress-file.md` that nothing did.

**Timing**: 45 minutes

**Depends on**: none

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: (1) **No `FormalSystem/**` file needs editing.** Confirmed when every check
above passes; refuted by any failing check, in which case this phase is marked `[BLOCKED]` and
raised rather than repaired here (Non-Goals). (2) **Carried figures**, each named with its source
and re-derived by the task that cites it: 27 `withBx_` references (iss_1791938399591_KHUXUs;
plan-time re-derivation 27); 15 ms vs 1093 ms at card 16 (task description, originally
parent probe 24) and 21 ms vs 1358 ms (`Timed.lean` docstring) for the isolated `verts` factor;
probe 25 exit 0 in 1.9 s (plan-time re-derivation against d034460fd).

**Tier Justification**: The only compile surface this phase creates is the two scratch probes
under `specs/782_phase7_verts_shape_d_decomposition/probes/`, each compiled standalone by
`lake env lean <probe>` under an explicit finite cap, and no `FormalSystem/**` file is touched —
so a single-module compile of each probe is the covering check, and the `progress-file.md` edits
under `specs/**` take the `prose` row's diff read-through (sub-case (a) of the `__FULL_SWEEP__`
rule; `--only-gate 3,4` does not apply under `specs/**`).

**Files to modify**:
- `specs/782_phase7_verts_shape_d_decomposition/probes/01_shapeD_landed_transfer.lean` - new; the
  parent's probe 25 with its header pointed at this task, the three `withBx` `rfl` transfers and
  the three `#print axioms`
- `specs/782_phase7_verts_shape_d_decomposition/probes/02_old_vs_landed_measure.lean` - new; the
  pre-Shape-D filter body under the scratch name `vertsOld` timed against the landed `verts` at
  `certA`
- `specs/782_phase7_verts_shape_d_decomposition/progress-file.md` - new; HEAD, every check's
  command and output, the measured figures beside their carried counterparts, and the
  issue-record attestation

**Verification**:
- `git status --porcelain FormalSystem/` is empty before and after this phase (nothing under
  `FormalSystem/**` was edited)
- `grep -n 'posTable\|posAtC\|find?' …/Timed.lean` returns nothing; the three body greps match
  the shapes named above
- The three `mem_*` signature lines agree exactly between the working tree and
  `git show 960e39ede:…/Timed.lean`
- `lake env lean probes/01_shapeD_landed_transfer.lean` exits 0; three `#print axioms` lines show
  only `[propext, Classical.choice, Quot.sound]`, no `sorryAx`
- `lake env lean probes/02_old_vs_landed_measure.lean` exits 0; both cards 16; equality `true`;
  three `#time` figures recorded in `progress-file.md` beside the carried pair
- `grep -c 'withBx_' …/Complete.lean` is 27; `grep -n 'List.find?' …/Complete.lean` is non-empty
- Both grep hits for the parent's decomposition-change record are present and their line numbers
  recorded
- `progress-file.md` carries an explicit issue-record attestation (entries recorded, or "nothing
  arose")

---

### Phase 2: Full gate, summary, and close [NOT STARTED]

**Goal**: The repository's complete gate set is green on the tree this task leaves behind, and the
task's summary records — in this task's own directory — that each of the description's three
deliverables was discharged by the parent's Phase 7 at commit fcd3ffcb0, with this round's
re-derived evidence and no source file modified here.

**Tasks**:
- [ ] **Deploy freshness first.** The dispatch context flags the deployed `.claude/` tree STALE for
      the `core` extension. Before any gate runs, redeploy with the bounded-wait idiom:
      `timeout 540 bash .claude/scripts/deploy-headless.sh` (Bash tool `timeout` 600000). Do not
      hand-patch any file under `.claude/**`. Record the outcome in `progress-file.md`.
- [ ] **Full guarded build**, detached per `context/patterns/bounded-build-waiter.md`:
      `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build`; green through the
      guard's own `result`, zero error lines. A break in a file outside this task's (empty) source
      scope is treated as a possible sibling in-flight edit — `git log` and `git status` first,
      then STOP and report rather than fix.
- [ ] **Gate set**: `bash scripts/check-module-invariants.sh` (ALL CHECKS PASSED);
      `bash scripts/typst-sync-check.sh` (all checks green); `bash .claude/scripts/verify-deploy.sh`
      (0 failures); `bash .claude/scripts/check-task-references.sh` (0 occurrences — this task
      touches no deliverable file, so this is a confirmation, not a repair surface);
      `lake exe lint-style` (no finding); sorry census
      `grep -rn 'sorry' FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/ | grep -v '^\s*--\|/-\|-/'`
      (empty). Each command's exit status is checked, not only its stdout.
- [ ] **Summary.** Write
      `specs/782_phase7_verts_shape_d_decomposition/summaries/01_verify-landed-shape-d-closure-summary.md`
      per `context/formats/summary-format.md`. It must state, in this order: (a) that the task's
      three deliverables — the `biUnion`-shaped `verts`, the `succT`/`predT` `let`-hoists, and the
      raised `posTable`/`posAtC`/`posAtC_eq` decomposition change — were landed and recorded by the
      parent's revised plan (`02_shape-d-verts-biunion.md`, Phase 7 and its
      `### Decomposition Change (raised, not substituted)` subsection and D8, cited by heading and
      the line numbers Phase 1 recorded) at commit fcd3ffcb0, and that this task **modified no
      `FormalSystem/**` file**; (b) every Phase 1 check with its command and recorded output;
      (c) the measured isolated factor beside both carried pairs, labelled as this round's figure
      versus CARRIED; (d) the D3 note that `lean-challenge-snapshot.sh` reports nothing to snapshot
      for this task and why that is the correct verdict; (e) the Phase 2 gate results.
- [ ] Record via `issue-record.sh` (`kind: win` or `issue`) how the gate round went, or attest
      explicitly that nothing arose. `kind: win` is the expected shape if the full set passes
      first time, as the parent's Phase 9 did.
- [ ] Commit this task's own files only, by explicit path, through
      `.claude/scripts/git-commit-scoped.sh` — the two probes, `progress-file.md`, the plan's
      marker updates and the summary. Never a directory or glob add (concurrent sibling on the
      tree).

**Timing**: 45 minutes (dominated by the build and gate wall clock)

**Depends on**: 1

**Verification Tier**: full

**Commit Mode**: per-substep

**Scope Hypothesis**: The gate set above is the one the parent's Phase 9 ran green
(iss_1791939778304_A8DJ5A: guarded build, `check-module-invariants.sh`, `typst-sync-check.sh`,
`verify-deploy.sh`, `check-task-references.sh`, `lake exe lint-style`, sorry census, axiom pins).
Confirm each script exists at the named path before running (`ls`) — all seven were present at
plan time — and if `verify-deploy.sh` aggregates one of the others, run it once, not twice.

**Files to modify**:
- `specs/782_phase7_verts_shape_d_decomposition/summaries/01_verify-landed-shape-d-closure-summary.md` -
  new; the closure record described above
- `specs/782_phase7_verts_shape_d_decomposition/progress-file.md` - the deploy-freshness outcome,
  each gate command with its exit status, and the issue-record attestation
- `specs/782_phase7_verts_shape_d_decomposition/plans/01_verify-landed-shape-d-closure.md` - phase
  heading markers and checklist ticks only

**Verification**:
- Deploy freshness re-checked after the redeploy; no file under `.claude/**` hand-edited
  (`git status --porcelain .claude/` unchanged by this task)
- `lake-build-guard.sh build` reports green with zero error lines
- `bash scripts/check-module-invariants.sh` exits 0, ALL CHECKS PASSED
- `bash scripts/typst-sync-check.sh` exits 0
- `bash .claude/scripts/verify-deploy.sh` exits 0, 0 failures — the complete gate set this
  repository aggregates, named here because this is the final phase
- `bash .claude/scripts/check-task-references.sh` exits 0, 0 occurrences
- `lake exe lint-style` exits 0 with no finding
- Sorry census over `PlusSlicedCertificate/` is empty
- `git status --porcelain FormalSystem/` is empty: this task modified no source file
- The summary exists, validates (`bash .claude/scripts/validate-artifact.sh <path> summary`), and
  contains items (a)-(e) above
- Every phase heading in this plan reads `[COMPLETED]` and `progress-file.md` carries both
  phases' issue-record attestations

## Lean Challenge Statements

This task adds no Lean declaration, so there is nothing to pin: the identifier set here is empty,
matching the empty identifier set under `- **Goals**:` above (D3). The fenced block is present so
the section is well-formed; `lean-challenge-snapshot.sh` will report that no identifiers were
found under the Goals heading and there is nothing to snapshot (exit 71), which is the correct
verdict for this task. The three
pre-existing characterization lemmas whose statements this task verifies are pinned in Phase 1's
statement-fidelity task and checked there by byte comparison against commit 960e39ede, not here —
they already exist in the module a Challenge file would have to import.

```lean
import FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.Timed

-- No declarations: this task pins no new theorem. See the plan's Goals and Decision D3.
```

## Testing & Validation

- [ ] `git status --porcelain FormalSystem/` empty at the start of Phase 1 and the end of Phase 2
- [ ] Body-shape greps on `Timed.lean` match Shape D and the `let`-hoists; `posTable|posAtC|find?`
      absent
- [ ] `mem_verts` / `mem_succT` / `mem_predT` signature lines byte-identical to 960e39ede
- [ ] `probes/01_shapeD_landed_transfer.lean` compiles standalone, exit 0, axioms within
      `[propext, Classical.choice, Quot.sound]`, no `sorryAx`
- [ ] `probes/02_old_vs_landed_measure.lean` compiles, both cards 16, equality `true`, figures
      recorded beside the carried pairs
- [ ] `Complete.lean`: 27 `withBx_` references; `List.find?` prose instance present
- [ ] Parent plan's `### Decomposition Change` subsection and D8 present and cited by line
- [ ] Full guarded build, `check-module-invariants.sh`, `typst-sync-check.sh`, `verify-deploy.sh`,
      `check-task-references.sh`, `lake exe lint-style`, sorry census — all green, exit statuses
      checked
- [ ] Summary written, validated, and states items (a)-(e)
- [ ] `issue-record.sh` attestation present for both phases

## Artifacts & Outputs

- `specs/782_phase7_verts_shape_d_decomposition/plans/01_verify-landed-shape-d-closure.md` (this
  plan)
- `specs/782_phase7_verts_shape_d_decomposition/probes/01_shapeD_landed_transfer.lean`
- `specs/782_phase7_verts_shape_d_decomposition/probes/02_old_vs_landed_measure.lean`
- `specs/782_phase7_verts_shape_d_decomposition/progress-file.md`
- `specs/782_phase7_verts_shape_d_decomposition/summaries/01_verify-landed-shape-d-closure-summary.md`
- `specs/782_phase7_verts_shape_d_decomposition/issues.jsonl` entries for both phases
- No file under `FormalSystem/**`, `Tests/**`, `docs/**` or `.claude/**` is created or modified

## Rollback/Contingency

Nothing in this plan edits a source file, so there is no working-tree state to revert and no
snapshot to take: `git-snapshot.sh` is not invoked in any mode. If the round must be unwound,
delete this task's own new files (`probes/01_*.lean`, `probes/02_*.lean`, `progress-file.md`,
`summaries/01_*.md`) by explicit path; they are untracked until Phase 2's scoped commit, and after
it the commit is reverted with `git revert <sha>` of that one commit, never a `reset`.

If a Phase 1 check fails — the tree has drifted from fcd3ffcb0 or a transfer no longer holds — the
contingency is **not** a repair here: mark Phase 1 `[BLOCKED]`, record the failing command and
output in `progress-file.md` and `issues.jsonl` (severity `blocking`), and raise it; the repair is
a separate task against `Timed.lean` with its own plan, per plan-compliance.md.

If the user chooses the abandonment option of the accompanying `user_decision`, the plan is simply
not executed: `/task --abandon 782` closes the task and the parent's archived record remains the
sole record of the Shape D landing.
