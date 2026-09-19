# Research Report: Task #629

- **Task**: 629 - Reconcile task set with publication refactor programme
- **Started**: 2026-09-19T08:06:00Z
- **Completed**: 2026-09-19T09:10:00Z
- **Effort**: ~1 hour
- **Dependencies**: None (grounded in task 627's completed research)
- **Sources/Inputs**: `docs/development/PUBLICATION_REFACTOR.md`, `docs/architecture/ADR-010-*.md`,
  `docs/architecture/ADR-011-*.md`, `scripts/measure-refactor-partitions.py` (re-run live), task
  627's report/plan/summary, `specs/state.json` (50 active tasks, full descriptions read for
  every task named in the dispatch), `specs/reviews/review-2026-09-17.md` (README staleness list)
- **Artifacts**: this report
- **Standards**: report-format.md, subagent-return.md

## Executive Summary

- Every measurement in `PUBLICATION_REFACTOR.md` and ADR-011 was regenerated live against the
  current tree (commit-independent re-run of `scripts/measure-refactor-partitions.py all` and
  `--check`) and **matches the document exactly**: 141/104,087 Expressiveness files/lines, 38/
  28,472 residual, 0 leaking edges, 16 upward-into-Automation lines (11 attribute-only), 15 C6
  manifest entries, 9 loose test-root files (8 `*Probe.lean` + `TableauConformance.lean`). No
  number in this report is copied from the document; all are re-derived.
- The A/B ordering wrinkle is resolved by **declaring no dependency edge between A and B**: ADR-010
  itself states the Boneyard move "does not depend on" the frozen LaTeX citations Phase 1 retires,
  and Phase 1's other actions (personal-path removal, `docs/research`/`docs/training` relocation,
  one-off script deletion) touch no file under `FormalSystem/Boneyard/`. The document's `0 -> 1 ->
  2` chain is a narrative default, not a verified content dependency; A and B are independent
  follow-ups and either may land first.
- Of the 15 named collisions, verification found: 4 need a genuine new dependency edge (E on 626;
  C/D/E/F chain on A per programme order; 178 on F; 177 on F+G), 3 are resolvable by scope
  transfer/merge (610 into B; the 5 XLanguage READMEs from 614 into E's own commit; 177 kept
  separate from G, not merged, because its residual scope is materially different), 2 are **not
  real collisions** once checked against current file content (257/.gitattributes is already
  empty and 257's remaining work never touches it again; 625/H needs no edge because 625 is active
  now and H is programme-terminal), and the rest (the decidability chain vs D; 125/497-502/534/559
  path citations vs A/F) are confirmed non-colliding by direct file/description inspection.
- No proposed action targets a task carrying existing research or plan artifacts with an
  abandon/merge disposition (verified per-task artifact-directory presence below), so no
  `AskUserQuestion`-style confirmation gate is triggered by this report's recommendations. The one
  decision that does require the user's judgment — the `specs/` disposition at the publication
  gate — is recorded as a non-blocking `user_decision` with a stated default (keep tracked during
  the programme, untrack at the gate), consistent with task 627's own recommendation.
- Deliverable: a full specification for 9 new follow-up tasks (A-I, to be numbered 630-638 given
  `next_project_number: 630`), and a reconciliation table for every task named in the dispatch,
  ready for the `/plan 629` phase to turn into concrete task-creation and task-revision steps.

## Context & Scope

Task 629 is task-management work only: no file under `FormalSystem/`, `Tests/`, `docs/` or
`scripts/` was modified to produce this report. The programme document, both ADRs and the
measurement script are read-only inputs. This report proposes decisions; it does not execute
task creation, task revision, merges or abandonment — those are plan/implement-phase actions
against `specs/state.json`, guarded by the standard state-management tooling.

## Findings

### Re-derived measurements (live, this dispatch)

| Measurement | Document value | Re-derived value (this dispatch) | Match |
|---|---|---|---|
| Expressiveness set | 141 files, 104,087 lines, 0 leaking edges | 141 / 104,087 / 0 | yes |
| Residual `WeakCanonical` | 38 files, 28,472 lines | 38 / 28,472 | yes |
| `BXCanonical`-free by closure | 150 of 179 | 150 of 179 | yes |
| Upward edges into `Automation` | 16 (11 attribute-only) | 16 (11 attribute-only) | yes |
| Total upward import lines | 71 | 71 | yes |
| `Theorems` importing `Metalogic` | 4 files | 4 files | yes |
| `Metalogic` importing `Theorems` | 29 files, 47 lines | 29 files, 47 lines | yes |
| Automation: library-needed / user-facing / tooling | 9 (3,419 ln) / 4 (1,238 ln) / 25 (14,747 ln) | same | yes |
| Namespace audit (equal/ancestor/unrelated/none) | 279/187/24/43 | 279/187/24/43 | yes |
| C6 manifest entries | 15 | 15 (non-comment lines in `scripts/module-invariants-manifest.txt`) | yes |
| Loose `Tests/BimodalTest/` root files | 12 (8 Probe + TableauConformance + 3 Trace*) | 8 `*Probe.lean` + `TableauConformance.lean` (=9, Phase 5's set) + 3 `Trace*.lean` (=12 total, Phase 3's set) | yes |
| `--check` gate | exit 0 | exit 0 (`PASS`) | yes |
| Second Phase-9 split file | named only as "the split-point file" | `FormalSystem/Metalogic/WeakCanonical/Expressiveness/SplitPoint.lean`, 4,906 lines (identified by `wc -l` over `FormalSystem/**/*.lean`, second largest live file after the Boneyard-excluded ones) | resolved |

No discrepancy was found against the document; the "Discrepancies against the source analysis"
paragraph in Section 6 of the document is inherited from task 627's own resolution and still
holds.

### The A/B ordering wrinkle — resolved: no edge

Section 8 states `0 -> 1 -> 2`, and Section 9 bundles Phases 0+2 into task A while Phase 1 becomes
task B, so a literal reading would require B to land between A's two halves — impossible for a
single follow-up task. Two ways to resolve this were named in the dispatch; the evidence supports
the second:

- ADR-010 itself, in the "one rationale bullet cites a frozen artefact" paragraph, states: *"The
  frozen LaTeX file's two citations of the archive are historical text; the programme's
  deliverable-hygiene phase retires the frozen edition from the tracked tree, and **this record
  does not depend on it**."* That is the only place the document connects Phase 1's content to
  Phase 2's, and it is an explicit disclaimer of dependency, not an assertion of one.
- Checked directly: Phase 1's other actions (untrack `CLAUDE.md`/`.claude-extensions.json`/
  `.syncprotect`/`.gitattributes`; remove personal paths from `docs/`/`typst/`; delete the four
  one-off scripts; move `CONTRIBUTING.md`; relocate `docs/research/`, `docs/training/`; retire
  `latex/`; rewrite Logos/ProofChecker naming) touch no path under `FormalSystem/Boneyard/` or its
  538 archived imports, and Phase 2's move (the archive, its citers, B0/C11, the two new
  invariants) touches no path Phase 1 changes, with the one exception (the frozen LaTeX file)
  ADR-010 already disclaims.

**Decision**: A and B are independent follow-up tasks with **no dependency edge between them**;
either may be dispatched first. This is recorded on both tasks' descriptions (see the A and B
specifications below) rather than silently assumed, so a future reader does not re-derive the
question. C and D (Phase 3, Phase 4) keep their programme-order dependency on A only — they
consume the move tool A creates and validates in production — not on B, since neither phase
touches anything B's hygiene changes.

### A-I task specification (ready for `/plan 629`)

`next_project_number` is 630, so A-I are expected to land as tasks 630-638 in dependency order,
but the plan phase should not hardcode this — it should re-read `next_project_number` at
creation time. Dependencies below use letters pending real task numbers.

| Letter | Title (slug) | Task type | Dependencies | Notes |
|---|---|---|---|---|
| A | move_tool_and_boneyard_relocation | lean4 | none | Phases 0+2, accepts ADR-010 |
| B | deliverable_hygiene_excluding_specs | general | none | Phase 1; independent of A (see above) |
| C | bimodaltools_split | lean4 | A | Phase 3; sequence after 298/296/282 land (see below) |
| D | upward_edges_by_relocation | lean4 | A | Phase 4 |
| E | language_extension_directories_and_probe_tests | lean4 | C, D, 626 (see below) | Phase 5 |
| F | expressiveness_extraction | lean4 | E | Phase 6, accepts ADR-011 |
| G | docstring_and_citation_normalisation | lean4 | F | Phase 7 |
| H | ci_parity_root_collapse_publication_gate | lean4 | G | Phase 8 + publication gate |
| I | post_publication_size_splits_and_module_system | lean4 | H | Phase 9, optional |

Each description below is the Section 9 paste-ready text, unmodified in substance, with the
file_scope this report derived and any collision-driven addenda appended as a clearly marked
final paragraph (never renumbering or rewording the acceptance criteria the document already
fixed).

#### A — Move tool and archive relocation (Phases 0 + 2, ADR-010)

- **file_scope**: `scripts/move-modules.py` (new), `FormalSystem/Boneyard/` -> `Boneyard/`
  (`git mv`, 169 files), `Boneyard/README.md`, `scripts/check-module-invariants.sh` (B0/C11 scan
  roots, two new invariants), `scripts/boneyard-import-waivers.txt`,
  `docs/architecture/ADR-010-Boneyard-At-Repository-Root.md`,
  `docs/architecture/ADR-009-Boneyard-Retention.md` (status pointer only), plus every citer of
  `FormalSystem.Boneyard.*` the move tool rewrites (48 live docstrings, 43 markdown files, ~12
  scripts, 5 typst files, per ADR-010's own count).
- **Dependencies**: none.
- **Addendum**: no dependency on B (see A/B resolution above). Downstream, both C and D depend on
  this task, not on B.

#### B — Deliverable hygiene (Phase 1, excluding `specs/`)

- **file_scope**: `CLAUDE.md`, `.claude-extensions.json`, `.syncprotect`, `.gitattributes`,
  `.gitignore`, `CONTRIBUTING.md` (move to root), `docs/research/`, `docs/training/`, `latex/`
  (retire), `README.md`, `CITATION.cff`, `docs/` and `typst/` (personal-path removal),
  `scripts/README.md` (new), `scripts/migrate_schema_v2.py`, `scripts/swap_untl_snce.py`,
  `scripts/standardize_metadata.py`, `scripts/add-copyright-headers.sh` (delete).
- **Dependencies**: none.
- **Addendum**: no dependency on A. Merge task 610 into this task's scope (see reconciliation
  table). Sequence this task before task 604 (see reconciliation table) so 604's script inventory
  does not include the two scripts this task deletes.

#### C — `BimodalTools` split (Phase 3)

- **file_scope**: `lakefile.toml`, `FormalSystem/Automation/` (25 tooling modules per
  `automation-partition`), `BimodalTools/` (new lib), `Tests/BimodalTest/Automation/` (the 9
  tooling-importing test files), `Tests/BimodalToolsTest/` (new), `FormalSystem/Examples/
  BimodalProofs.lean`, `scripts/` (CI exe-root step, `typst-module-map.sh`, automation-module-map
  generator).
- **Dependencies**: A.
- **Addendum**: sequence after tasks 298, 296 and 282 (all `[partial]`, all editing
  `FormalSystem/Automation/` right now) rather than blocking them — see reconciliation table.

#### D — Upward edges by relocation (Phase 4)

- **file_scope**: `FormalSystem/Init.lean`, `FormalSystem/Tactic/Attr.lean` (new, merges
  `Automation/{TruthNormAttr,NormalizationAttr,LemmaDB}.lean`),
  `FormalSystem/Automation/Tactics/PropDecide.lean` -> `Metalogic/Decidability/Propositional/
  Tactic.lean`, `FormalSystem/Metalogic/Core/DeductionTheorem.lean` -> `Theorems/
  DeductionTheorem.lean`, `FormalSystem/Metalogic/Decidability/FMP/Periodicity.lean` ->
  `Semantics/Periodicity.lean`, `ORGANISATION.md`, `scripts/check-metalogic-cycles.sh`.
- **Dependencies**: A.
- **Addendum**: verified no file overlap with the decidability chain (410-412, 428-430, 464,
  465, 481, 482) — see reconciliation table.

#### E — Language-extension directories and probe tests (Phase 5)

- **file_scope**: `Syntax/{Plus,Minus,Star}Language/`, `Semantics/{Plus,Minus,Star}Language/` ->
  `{Plus,Minus,Star}Language/` (library root), `Metalogic/Conservativity/
  MinusLanguageSoundness.lean` -> `MinusLanguage/Soundness.lean`, the three foreign-namespace
  Chronicle files (`Metalogic/BXCanonical/Chronicle/ChronicleRealExtension.lean`, `Metalogic/
  WeakCanonical/DenseModelSurgery/ChronicleInstance.lean`, `Metalogic/WeakCanonical/RealModel/
  ChronicleRealFlow.lean`), `Tests/BimodalTest/{8 *Probe.lean files, TableauConformance.lean}` ->
  `Tests/BimodalTest/Metalogic/Decidability/`.
- **Dependencies**: C, D, **626**.
- **Addendum (collision resolution)**:
  - Task 626 edits `Syntax/PlusLanguage/Axioms.lean` and `Semantics/PlusLanguage/PlusTruth.lean`
    (both moved by this task) to replace manuscript line-number citations with label citations.
    626 must land first so its docstring fix travels with the file under the move tool rather than
    racing it; this task now depends on 626.
  - Task 429's `file_scope` includes `Tests/BimodalTest/TemporalWitnessProbe.lean`, one of the 8
    files this task relocates. 429 is deep, open-mathematics work gated behind task 428 with no
    fixed timeline (task 481/482 in the same chain are explicitly flagged multi-month); making
    this task wait on 429 would stall the whole publication programme behind unrelated open
    mathematics. Resolution: **no dependency edge in either direction**. At execution time, check
    whether 429 has landed; if not, move the file as scoped (429's own file_scope note, added
    below, tells it to look for the file at its new path). If 429 is actively in flight
    (uncommitted work) when this task is dispatched, exclude `TemporalWitnessProbe.lean` from this
    pass and relocate it in a small follow-up once 429 lands.
  - Task 614 lists 47 stale README date stamps; 5 of them
    (`Syntax/PlusLanguage/README.md`, `Syntax/MinusLanguage/README.md`,
    `Syntax/StarLanguage/README.md`, `Semantics/PlusLanguage/README.md`,
    `Semantics/MinusLanguage/README.md`) sit inside directories this task merges away. Recommend
    this task refresh the date stamp of the *merged* README as part of its own commit (since it
    already rewrites these directories), and 614's scope narrows to the other 42 files with a new
    dependency on this task (see 614's entry in the reconciliation table).

#### F — Expressiveness extraction (Phase 6, ADR-011)

- **file_scope**: `Metalogic/WeakCanonical/{Kamp,EFGames,Expressiveness,Separation,NormalForm,
  MonadicFO,StaviConnectives,PriorDefs,PriorDefsDense,PriorExpressiveness,
  PriorExpressivenessDense,Table,EFGameTactics}` -> `Metalogic/Expressiveness/**` (141 files),
  `typst/generated/*`, `docs/theorem-index.md`, `FormalSystem/MainResults.lean`, the C2/C14 axiom
  baseline files under `scripts/`, `docs/architecture/ADR-011-*.md`,
  `docs/architecture/ADR-006-*.md` (status pointer).
- **Dependencies**: E.
- **Addendum**: task 412 cites `Metalogic/WeakCanonical/GroupModel/CountermodelBase.lean` — this
  path is confirmed to stay in the **residual** 38-file set (it is not in the Expressiveness
  subtree list above), so no citation drift results from this task; record that fact in this
  task's own docstring/PR notes so a reader of 412 does not have to re-derive it.

#### G — Docstring and citation normalisation (Phase 7)

- **file_scope**: `FormalSystem/**/*.lean` (every `## References` section, repo-wide),
  `references.bib` (new, root), `typst/bibliography.bib` (merge into root, then remove), `typst/`
  (bibliography pointer), `FormalSystem/Examples/`, `FormalSystem/Semantics/{TaskFrame,Truth}.lean`,
  `Tests/`.
- **Dependencies**: F.
- **Addendum**: tasks 563-567 and 616-618 (the categorical-front new-file tasks) are unrelated
  mathematics with no dependency on the publication programme's schedule; recommend a citation-
  convention note only (adopt the `* [Author, *Title*][key]` form against the root
  `references.bib` if drafted after this task lands; migrate if drafted before) rather than a
  blocking dependency.

#### H — CI parity, root collapse and publication gate (Phase 8)

- **file_scope**: `FormalSystem/FormalSystem.lean` (mk_all-generated), `scripts/module-invariants-
  manifest.txt` (drain to empty), CI workflow files (new `mk_all --check` step, `lint-style-
  action`, tag-triggered release workflow), `ORGANISATION.md` (module-size policy text),
  `scripts/check-copyright-headers.sh` (retire if redundant); **at the gate**, in one commit:
  `specs/`, `CLAUDE.md`, `.claude-extensions.json`, `.syncprotect`, `.gitattributes` (untrack).
- **Dependencies**: G.
- **Addendum**: task 625 (`[researched]`) edits `FormalSystem/FormalSystem.lean` directly to
  register its new `OpenLanguage` modules. No dependency edge is added in either direction: 625 is
  active research work now, while this task is programme-terminal (phase 8 of 9) and will very
  likely be dispatched long after 625 lands regardless. If 625 has *not* landed by the time this
  task executes, `mk_all`'s generation is automatic over whatever `.lean` files then exist under
  `FormalSystem/`, so no special handling is required either way.
- **Addendum (specs/ disposition)**: this task's gate commit executes whichever specs/ disposition
  the user confirms (see "specs/ disposition" below); the default, absent a contrary instruction,
  is untrack at the gate as scoped above.

#### I — Post-publication (Phase 9, optional)

- **file_scope**: `FormalSystem/Metalogic/Expressiveness/EFGames/GapDetection.lean` (post-F path;
  5,092 lines today), `FormalSystem/Metalogic/Expressiveness/GameTransfer/SplitPoint.lean`
  (post-F path for today's `Metalogic/WeakCanonical/Expressiveness/SplitPoint.lean`, 4,906 lines
  — identified by direct line count as "the split-point file" Section 7 names but does not spell
  out).
- **Dependencies**: H.

### Reconciliation of every named open task

Artifact-directory presence was checked directly (`find specs/{N}_*/ -mindepth 2 -maxdepth 2`)
for every task below; "artifacts: none" means the task has no `specs/{N}_*/` directory at all
(created via `/task` but never dispatched), so no abandon/merge confirmation gate applies to any
recommendation made for it below.

| Task | Status / artifacts | Collision | Verified finding | Recommended disposition |
|---|---|---|---|---|
| 626 | not_started / none | vs E | Confirmed: edits `Syntax/PlusLanguage/Axioms.lean`, `Semantics/PlusLanguage/PlusTruth.lean`, both moved by E | Keep; add **E depends on 626** |
| 429 | not_started / none | vs E | Confirmed: `file_scope` includes `Tests/BimodalTest/TemporalWitnessProbe.lean`, one of E's 8 moved probe files | Keep, no new edge; revise `file_scope` note to also accept the post-E path `Tests/BimodalTest/Metalogic/Decidability/TemporalWitnessProbe.lean` |
| 614 | not_started / none | vs E | Confirmed: 5 of the 47 stale-README files sit in directories E merges (`Syntax/{Plus,Minus,Star}Language/README.md`, `Semantics/{Plus,Minus}Language/README.md`) | Narrow scope to the other 42 files; add **614 depends on E**; let E refresh the 5 merged READMEs' dates in its own commit |
| 298 | partial / 14 artifacts | vs C | Confirmed: `file_scope` includes `FormalSystem/Automation/`, in-flight bug fix | Keep as-is (no edge to C needed on 298's side); **C depends on A** and is sequenced by the planner to dispatch after 298 lands |
| 296 | partial / 3 artifacts | vs C | Confirmed: `file_scope` includes `FormalSystem/Automation/`; already `deps: [298]` | Keep as-is; same sequencing note as 298 |
| 282 | partial / 4 artifacts | vs C | Confirmed: `file_scope` includes `FormalSystem/Automation/`; already `deps: [298]` | Keep as-is; same sequencing note as 298 |
| 604 | not_started / none | vs C, vs B | Confirmed: inventories `FormalSystem/Automation/*Main.lean` exes (C re-roots these) and `scripts/migrate_schema_v2.py`, `scripts/standardize_metadata.py` (B deletes these) | Revise: add **604 depends on B** (drop the two deleted scripts from its own inventory step) and **604 depends on C** (write its Lean-executable inventory against `BimodalTools.*` paths directly, avoiding a second rewrite) |
| 231 | not_started / none | vs C (transitively via 298) | Confirmed: already `deps: [298]`; touches `lake exe dataset_generator`/`proof_extractor`/`benchmark_oracle` by name only (exe names are unchanged by C per the lakefile target shape) | Keep as-is; no new edge needed — exe names survive C unchanged |
| 257 | blocked / 3 artifacts | vs B | **Not a real collision**: `.gitattributes` is confirmed empty (`ls -la` shows 0 bytes) and 257's own plan/summary confirm Phase 3 (LFS-tracking removal from `.gitattributes`) is already `[COMPLETED]`; 257's only remaining work is the HF Hub upload (blocked on credentials), which never touches `.gitattributes` again | No action; B may untrack the file independently of 257's completion |
| 610 | not_started / none | vs B | Confirmed: pure grep-and-fix of stale `lakefile.lean` mentions in `docs/`, same doc-cleanup class as B, no artifacts to preserve | **Merge into B**'s scope (no confirmation gate: 610 has no artifacts) |
| 625 | researched / 3 artifacts | vs H | Confirmed: `file_scope` includes `FormalSystem/FormalSystem.lean`, which H replaces with a generated aggregator | No dependency edge (625 is active now; H is programme-terminal); see H's addendum above |
| 177 | not_started / none | vs G | Confirmed: 177's *residual* scope (post-472/473, per its own realignment notes) is re-auditing drift the decidability chain introduces plus the Axiom Reference update — materially different from G's citation-form/bibliography normalization, so **not merged** | Keep separate; add **177 depends on F, G** (in addition to its existing `deps: [428, 429, 430]`) so its final pass runs after both the Expressiveness rename and the citation-form normalization land |
| 178 | not_started / none | vs F (and C, transitively) | Confirmed: cites Kamp-named results (`F` renames them) and edits `Examples/BimodalProofs.lean` (C also edits it for the aggregator-import change) | Add **178 depends on F** (F already transitively requires C via E via {C,D}, so no separate C edge is needed) |
| 563, 564, 565, 566, 567, 616, 617, 618 | not_started (564, 567 have 1 report each; others none) | vs G | Confirmed: none of these tasks currently cite `## References`-style docstring content in a form G would rewrite; they are new-file categorical-front tasks | No dependency edge; add a citation-convention note (adopt G's form once landed, migrate if drafted first) |
| 410, 411, 412, 428, 430, 464, 465, 481, 482 (decidability chain) | mixed (428: 44 artifacts; 464: 2; 481: 9; others 0) | vs D | Confirmed by direct file-path comparison: this chain lives entirely under `Metalogic/Decidability/Verified/` (plus `Decidability/Saturation.lean`, `Decidability/Correctness.lean`, `Decidability/ProofExtraction.lean`); D touches `Metalogic/Core/DeductionTheorem.lean` and `Metalogic/Decidability/FMP/Periodicity.lean` only — no overlap | No action; confirmed independent |
| 412 | not_started / none | vs F | Confirmed: cites `Metalogic/WeakCanonical/GroupModel/CountermodelBase.lean`, which the F specification (Section 4/6) places in the **residual** set, not the moved Expressiveness set | No action; note recorded on F above so the fact does not need re-deriving |
| 534, 559 | researched (534: 2 artifacts; 559: 11 artifacts) | vs F | Checked: neither task's live description contains a slash-path citation into the Expressiveness-moved subtree; both mention "Kamp" only as a concept name (Kamp's theorem / Kamp-Burgess territory), and 559's engine references (`Metalogic/Independence/CoarsenedModels.lean`, `Semantics/Extension/Extension.lean`, Doets/RealModel) are all in the **residual** set F does not move | No action; not a real collision |
| 125, 497, 498, 499, 500, 501, 502 | not_started (125 has notable history but 0 artifact-dir files) | vs A | Confirmed: 497 and 499 already cite the archive using the post-move shorthand `Boneyard/UltrafilterFrame/...Lean` (no `FormalSystem/` prefix) even though the current on-disk path is `FormalSystem/Boneyard/UltrafilterFrame/...lean`; A's move makes this existing informal citation exactly correct rather than staling it | No action; A's move improves these citations' accuracy, does not break them |
| 604 vs 257 | — | dispatch also asks to "reconcile with the HF Hub storage migration (task 257)" | This is 604's own internal note, not a new collision from the programme; unaffected by A-I | No action beyond the B/C edges above |

## Decisions

1. **A and B are independent** (no dependency edge); resolves the A/B ordering wrinkle via
   ADR-010's own no-dependency disclaimer plus a direct check that Phase 1's actions touch no
   Boneyard path.
2. **C and D both depend on A only**, preserving the programme's `2 -> {3,4}` order without
   requiring B.
3. **E depends on C, D and 626** (new edge to 626, justified by direct file overlap); **no edge
   to 429** (open-ended math work must not gate a mechanical hygiene phase — 429's own
   `file_scope` note is revised instead to tolerate either path).
4. **F depends on E**; **G depends on F**; **H depends on G**; **I depends on H** — the programme's
   stated `5 -> 6 -> 7 -> 8 -> 9` chain, unchanged.
5. **610 is merged into B's scope** (no artifacts, same doc-cleanup class).
6. **604 gains dependencies on B and C** (drops the two scripts B deletes from its inventory;
   targets `BimodalTools.*` paths directly rather than being rewritten twice).
7. **614 narrows to 42 files and depends on E** (the other 5 are absorbed into E's own commit).
8. **177 stays separate from G** but gains dependencies on F and G (its residual scope — drift
   re-audit plus Axiom Reference — is not the same work as G's citation-form normalisation).
9. **178 depends on F** (sufficient; F transitively requires C).
10. No dependency edges are added for: 257/B (not a real collision — verified moot), 625/H (625
    precedes H by natural task priority, no edge needed), the decidability chain/D (file-disjoint,
    verified), 412/F (residual-set membership confirmed), 534, 559/F (no path citations found),
    125/497-502/A (citations already match the post-move form), 231/C (exe names unchanged by C),
    298/296/282/C (their in-flight status is a scheduling fact for the planner, not a task-graph
    edge — C already depends on A and the planner sequences C's dispatch after these three land).
11. **specs/ disposition**: recorded as a non-blocking `user_decision` (see below) rather than
    decided unilaterally, per the dispatch's explicit "confirm with the user" instruction and the
    user-decision contract's guidance that a genuine external-preference question belongs there.
    The default carried forward from task 627 is: keep `specs/` tracked while the programme runs,
    untrack the whole non-deliverable set (`specs/`, `CLAUDE.md`, `.claude-extensions.json`,
    `.syncprotect`, `.gitattributes`) in one commit at the publication gate (task H). Alternatives
    named in the document: keep `specs/` published permanently, or move it to a separate
    unpublished branch before the gate.

## specs/ disposition (flagged for user confirmation)

Per `PUBLICATION_REFACTOR.md` Section 8: `specs/` stays tracked *while the programme runs*
because the task workflow that executes the phases commits its own provenance there, and
untracking it mid-programme would break that workflow. At the publication gate (task H), three
options exist:

1. **Untrack at the gate** (document's default, non-blocking recommendation, carried forward from
   task 627): one commit, immediately before the `v1.0.0` tag, untracks `specs/` alongside the
   other non-deliverable paths and adds them to `.gitignore`. Provenance survives in git history
   but not in the published tree.
2. **Keep published permanently**: `specs/` remains part of the tracked deliverable indefinitely.
   Diverges from the cslib/Mathlib "clean upstream surface" convention (Section 3, row `g`).
3. **Move to an unpublished branch**: `specs/` is relocated to a branch that is never merged to the
   publication branch, preserving full provenance outside the published history while keeping the
   main branch clean from the start of the programme rather than only at the gate.

This report does not decide among the three; it is recorded as a `user_decision` in
`.return-meta.json` (non-blocking — the default is safe to proceed with in the interim, since the
gate action itself is task H, the last task in the whole programme, and nothing before it depends
on which option is chosen).

## Risks & Mitigations

- **Risk**: sequencing C after 298/296/282 (a scheduling note, not a task-graph edge) could be
  lost if the planner does not carry this report's prose forward. **Mitigation**: this report
  states the sequencing explicitly in both C's addendum and the reconciliation table; the `/plan
  629` phase should encode it as an explicit planner note even though it is not a `dependencies`
  array entry (a hard dependency would incorrectly block C on 298/296/282's *eventual* completion
  rather than merely recommending an order).
- **Risk**: E's non-edge to 429 could result in a genuine file conflict if 429 is dispatched
  concurrently with E's execution. **Mitigation**: addendum on E instructs a live check
  (`git status`/task status) immediately before the move, with an explicit small-follow-up
  fallback if 429 is mid-flight.
- **Risk**: the specs/ disposition default (untrack at the gate) is far downstream (task H, last
  in the chain); if the user's actual preference differs, no work is wasted either way since
  nothing before H acts on it.

## Context Extension Recommendations

None — this is a meta task; the reconciliation belongs entirely in `specs/` artifacts and
`state.json`, not in `.claude/context/`.

## Appendix

### Search/verification commands used

```
python3 scripts/measure-refactor-partitions.py all
python3 scripts/measure-refactor-partitions.py all --json
python3 scripts/measure-refactor-partitions.py --check
grep -vc '^#\|^$' scripts/module-invariants-manifest.txt
find FormalSystem -name '*.lean' | xargs wc -l | sort -rn | head -5
ls -la .gitattributes
jq -r '.active_projects[] | ...' specs/state.json   # full task inventory + per-task descriptions
grep -n "README" specs/reviews/review-2026-09-17.md | grep -iE "plusLanguage|minusLanguage|starLanguage|conservativity"
```

### Task numbering note

`next_project_number` in `specs/state.json` is 630 at the time of this report. If other tasks are
created between this research round and the `/plan 629` or `/orchestrate 629 --plan` dispatch that
creates A-I, the plan phase must re-read `next_project_number` rather than assuming 630-638.
