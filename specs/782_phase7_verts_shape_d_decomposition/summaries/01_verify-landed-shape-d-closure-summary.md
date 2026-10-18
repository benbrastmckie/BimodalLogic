# Implementation Summary: Task #782

- **Task**: 782 - Phase7 verts shape d decomposition
- **Status**: [COMPLETED]
- **Started**: 2026-10-18T05:55:58Z
- **Completed**: 2026-10-18T06:09:13Z
- **Effort**: ~35 minutes (one implement dispatch; no-op rebuilds)
- **Dependencies**: None (parent task 716 is `[COMPLETED]` and archived)
- **Artifacts**: plans/01_verify-landed-shape-d-closure.md, probes/01_shapeD_landed_transfer.lean, probes/02_old_vs_landed_measure.lean, progress-file.md, summaries/01_verify-landed-shape-d-closure-summary.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

This task's three deliverables — the `Finset.biUnion`-shaped `PlusSlicedCertificate.verts`,
the `succT`/`predT` three-binding `let`-hoists, and the raised decomposition change dropping
`posTable`/`posAtC`/`posAtC_eq` from the Goals — were all landed and recorded by the parent task
716's revised plan `specs/archive/716_sliced_certificate_liveat_nontermination/plans/02_shape-d-verts-biunion.md`
(Phase 7; § "Decomposition Change (raised, not substituted)" at line 88; D8 at line 223) in
commit fcd3ffcb0 (2026-10-13), before this task's plan ran. **This task modified no
`FormalSystem/**` file.** It was a verification-and-closure round (plan D1, confirmed by the
user's recorded decision): every claim in the task description was re-derived on the current tree
(HEAD b5547cef9) with its command and output recorded in `progress-file.md`, the isolated `verts`
factor was measured afresh, the full guarded build and the project gate set were run, and this
summary is the durable record of where the scope was discharged.

## What Changed

No Lean source changed. Files created, all under this task's own directory:

- `specs/782_phase7_verts_shape_d_decomposition/probes/01_shapeD_landed_transfer.lean` — the
  parent's probe 25 re-pointed at this task: three `withBx` `rfl` transfers (`verts`, `succT`,
  `predT`) plus a `mem_verts` statement control and three `#print axioms`, under
  `maxHeartbeats 200000`.
- `specs/782_phase7_verts_shape_d_decomposition/probes/02_old_vs_landed_measure.lean` — the
  pre-Shape-D filter body re-declared verbatim (from 960e39ede) as `vertsOld` and timed beside the
  landed `verts` at `TotalEdge.certA` (plan D4).
- `specs/782_phase7_verts_shape_d_decomposition/progress-file.md` — every check's command and
  recorded output, both phases.
- Plan phase markers and checklist ticks/annotations only in
  `plans/01_verify-landed-shape-d-closure.md`.

### Phase 1 acceptance checks (all passed first time; commands and outputs in `progress-file.md`)

| Check | Result |
|-------|--------|
| HEAD / latest commit on `Timed.lean` / `git status --porcelain FormalSystem/` | b5547cef9 / fcd3ffcb0 (as expected) / empty |
| Body shapes (`grep -n -A6 '^def verts\|^def succT\|^def predT'`) | `verts` = `G.winTimes.biUnion (fun t => (G.posAt t).image (fun p => (p, t)))` (line 164-165); `succT`/`predT` open with `let V := G.verts`, bind `u` to `G.nextTime v.2`/`G.prevTime v.2` and `S`/`P` to `G.succP v.2 v.1`/`G.predP v.2 v.1`, filter `V` on `w.2 = u ∧ w.1 ∈ S` (resp. `∈ P`) (lines 424-435) |
| `grep -n 'posTable\|posAtC\|find?' Timed.lean` | no output (grep exit 1) |
| Statement fidelity vs `git show 960e39ede:…/Timed.lean` | `mem_verts`, `mem_succT`, `mem_predT` statement lines byte-identical; only `mem_verts`'s first proof line differs (`rw [verts, Finset.mem_biUnion]` vs `simp [verts, Finset.mem_product]`), the expected consequence of the body change |
| `lake env lean probes/01_shapeD_landed_transfer.lean` | exit 0, wall 1.846 s; all three `#print axioms` lines: `[propext, Classical.choice, Quot.sound]`, no `sorryAx` |
| `grep -c 'withBx_' Complete.lean` / `grep -n 'List.find?' Complete.lean` | 27 (matches CARRIED 27) / line 198 (stuck-matcher prose instance present) |
| Decomposition-change record in the parent's archived plan | `### Decomposition Change (raised, not substituted)` at line 88; `- **D8**` at line 223 |

### Isolated `verts` factor — this round's figure beside the CARRIED pairs

| Source | Shape D (landed) | Filter shape (old) | Card | Factor |
|--------|------------------|--------------------|------|--------|
| **This round** (`probes/02_old_vs_landed_measure.lean`, `certA`) | **16 ms** | **1105 ms** | 16 / 16, equality `true` | **~69x** |
| CARRIED — task description / parent probe 24 | 15 ms | 1093 ms | 16 | ~73x |
| CARRIED — `Timed.lean` `verts` docstring | 21 ms | 1358 ms | 16 | ~65x |

Consistent with the carried figures; recorded, not acted on (plan Non-Goals).

### Challenge snapshot (plan D3)

`lean-challenge-snapshot.sh` has nothing to snapshot for this task: the plan's `**Goals**:` names
no identifier and `## Lean Challenge Statements` declares none, because the task adds no Lean
declaration. Its "no identifiers found … nothing to snapshot" verdict (exit 71) is the correct
verdict here, not a defect; statement fidelity for the three pre-existing `mem_*` lemmas was
checked by the byte comparison above instead.

## Decisions

- **Verify-and-close rather than abandon** (plan D1; user decision recorded in `.decisions.json`,
  cycle 1): run the verification round and leave a durable record in this task's own directory.
- **Acceptance bar = the parent's Phase 7 verification list, re-run** (plan D2) — no new bar.
- **Measure against a re-declared old shape** (plan D4): `vertsOld` from 960e39ede, since `verts`
  is now Shape D.
- **No redeploy from this dispatch**: `deploy-headless.sh`'s header and
  `context/patterns/regeneration-is-manual-only.md` sanction only the orchestrator's inter-cycle
  checkpoint (and `command-gate-out.sh`'s rc==6 branch) as automated callers; with sibling
  dispatches live on the shared tree, this agent left the flagged `core` staleness to that
  checkpoint.
- **Pre-existing gate findings outside scope are raised, not repaired** (plan Non-Goals,
  plan-compliance.md): see Follow-ups.

## Plan Deviations

- **Phase 2, "Deploy freshness first"** skipped: not run by this dispatch — the only sanctioned
  automated callers of `deploy-headless.sh` are the orchestrator's inter-cycle redeploy checkpoint
  and the single-task completion gate (`regeneration-is-manual-only.md` § Automated Exception);
  deferred to that checkpoint. Staleness re-confirmed by `check-deploy-freshness.sh` (WARN: core
  stale). Recorded as issue iss_1792303574127_9gVd6r.
- **Phase 2, "Gate set"** altered: per the dispatch's Batch Gate Deferral, `verify-deploy.sh` was
  not run independently here (deferred to the batch stage, where the complete gate set runs once
  and is attributed by `modified_files`; this task's are all under `specs/**`, which no
  `--only-gate`/`run-all.sh --only` suite covers). The project gates were run:
  `check-module-invariants.sh` ALL CHECKS PASSED (exit 0, 125 s); `typst-sync-check.sh` PASS (exit
  0); `check-task-references.sh` PASS, 0 occurrences (exit 0); sorry census 0; **`lake exe
  lint-style` exit 3 with 4 pre-existing findings in files this task does not touch** — raised, not
  repaired (Non-Goals forbid any `FormalSystem/**` edit). Recorded as a `costly` gate-collision
  issue; see Follow-ups.
- **Commit granularity** altered: a Phase 1 commit (c03844462) was made at Phase 1's end per the
  phase-granular commit mandate, rather than a single Phase 2 commit of everything.

## Verification

- Build: Success — `lake-build-guard.sh build --timeout 1800 -- build` exit 0, "Build completed
  successfully (2878 jobs)", zero `error:` lines, run at Phase 1 end (7.5 s, no-op rebuild) and
  again as the final build (2.3 s); `Timed`/`Complete`/`Examples` `.olean`s newer than source.
- Sorry count: 0 (`lean-sorry-census.sh` over the resolved roots; the plan's grep census over
  `PlusSlicedCertificate/` hits only prose: two README lines and a doc-comment line at
  `EmbedComplete.lean:924`)
- Vacuous count: 0 after manual review — the single-line regex hits one pre-existing theorem,
  `FormalSystem/Examples/TemporalStructures.lean:495` (`int_domain_universal (t : Int) :
  intTimeHistory.domain t := trivial`, unchanged since 2025-12-04), whose `domain` is
  `fun _ => True` so `trivial` is its honest proof; it is not a placeholder, and the file is
  outside this task's scope. Raw regex count: 1.
- Axiom count: 14 `^axiom` lines over the resolved roots at the working tree, HEAD b5547cef9 and
  fcd3ffcb0 alike — not increased. The three `mem_*` lemmas depend only on
  `[propext, Classical.choice, Quot.sound]`.
- Tests: N/A (no test file changed); project gates as listed under Plan Deviations
  (`lake exe lint-style` red on pre-existing lines, see Follow-ups).
- Files verified: Yes — `git status --porcelain FormalSystem/` empty before Phase 1 and after
  Phase 2.
- Full gate set: deferred to the batch stage per the dispatch's Batch Gate Deferral directive
  (the plan's `**Verification Tier**: full` field is unchanged).

## Impacts

- Closes the blocker follow-up spawned from the parent's Phase 7 without reopening any route
  decision: the Shape D `verts`, the `let`-hoisted `succT`/`predT`, and the five `rfl`-proved
  `withBx_*` transfer lemmas in `Complete.lean` are confirmed intact on today's tree.
- The parent's archived plan remains the sole record of the decomposition change; this summary
  cites it by heading and line rather than duplicating it.

## Follow-ups

- **`lake exe lint-style` is red at HEAD** on 4 pre-existing lines outside this task's scope:
  `FormalSystem/ProofSystem/Axioms.lean:300`, `FormalSystem/ProofSystem/DerivedAxioms.lean:51` and
  `:154`, `FormalSystem/Theorems/ConnectDerived.lean:28` ("This line contains a space before a
  semicolon" — doc-comment derivation chains written `NB ; MF ; MT`), introduced on 2026-10-14/15
  (commits de8a7e4722/cec66f898, 7ef396e45, 5a94c259d) after the parent's Phase 9 gate ran green.
  A follow-up task should apply `lake exe lint-style --fix` or rewrite the separators and re-run
  the gate.
- The deployed `.claude/` tree is stale for the `core` extension; the orchestrator's inter-cycle
  redeploy checkpoint is the sanctioned place to clear it.
- The user may still elect `/task --abandon 782` per the recorded decision's note; nothing here
  depends on that.

## References

- Plan: `specs/782_phase7_verts_shape_d_decomposition/plans/01_verify-landed-shape-d-closure.md`
- Progress record: `specs/782_phase7_verts_shape_d_decomposition/progress-file.md`
- Probes: `specs/782_phase7_verts_shape_d_decomposition/probes/01_shapeD_landed_transfer.lean`,
  `specs/782_phase7_verts_shape_d_decomposition/probes/02_old_vs_landed_measure.lean`
- Issue log: `specs/782_phase7_verts_shape_d_decomposition/issues.jsonl` (one `win`, two `issue`
  entries this dispatch)
- Parent record: `specs/archive/716_sliced_certificate_liveat_nontermination/plans/02_shape-d-verts-biunion.md`
  (Phase 7; line 88 § "Decomposition Change (raised, not substituted)"; line 223 D8); probes 21-25;
  commit fcd3ffcb0 and its parent on `Timed.lean`, 960e39ede
- Prior decision: `specs/782_phase7_verts_shape_d_decomposition/.decisions.json`
