# Research Report: Task #593

**Task**: 593 - Revise task organization codebase cleanup
**Started**: 2026-09-16T15:25:24Z
**Completed**: 2026-09-16T15:45:00Z
**Effort**: Implementation ~1-2 hours (state.json/TODO.md edits only: re-topic 15 tasks, abandon 1, rescope 6, rewire dependencies, create 4 new tasks)
**Dependencies**: None
**Sources/Inputs**: - Codebase (FormalSystem/, Tests/, scripts/, docs/, typst/, lakefile.lean, .github/workflows/), specs/state.json, specs/TODO.md, specs/archive/state.json, specs/reviews/review-2026-09-15.md, specs/reviews/review-2026-09-16.md, /home/benjamin/Projects/cslib (CONTRIBUTING.md, ORGANISATION.md, lakefile.toml, docs/lint-suppression-policy.md, .github/workflows/, scripts/pre-pr-check.sh); lean-lsp search tools not needed (no Mathlib lookup in scope)
**Artifacts**: - specs/593_revise_task_organization_codebase_cleanup/reports/01_cleanup-topic-reorganization.md
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- Of the 57 other active tasks, **16 are codebase-improvement work that writes no new
  mathematics** (conventions, cruft removal, comments/docs, refactors, gates). They are currently
  scattered across **ten** topics (`code-quality`, `repo-hygiene`, `documentation`,
  `infrastructure`, `automation`, `metalogic`, `decidability`, `paper-refactor`,
  `reference-book`, `publication-quality`). Recommendation: gather them under ONE topic,
  `codebase-cleanup`, with an explicit dependency DAG (below).
- **One duplicate**: 542 (`dead_declaration_triage_c17_findings`) and 588
  (`triage_zero_occurrence_declarations`) are the same job at two measurements (989 vs 1,029).
  Abandon 542, folding its attribute-reachability step into 588. The two descriptions also
  **contradict each other** on the leading example (`release_unfold`): verified here, it is
  `@[formula_unfold]`-registered and the simp set's only consumers are `Normalization.lean`'s
  own `#check`/`example` block plus `Tests/BimodalTest/Automation/NormalizationTest.lean` -- so
  588 must resolve it, not assume either reading.
- **One structural bottleneck to remove**: 583 (wire checks into CI) waits on four repair tasks
  (581, 582, 586, 590) and transitively on 591. Two of its scripts are green today (verified:
  `readme-lint.sh` exit 0; `check-copyright-headers.sh --strict --exclude '*/Boneyard/*'
  FormalSystem` exit 0) and the invariant harness is green per the sweep. Rescope 583 to wire
  the green checks now; each repair task wires its own script as its final phase. This locks
  each fix in the moment it lands instead of after the slowest one.
- **Scope gaps found** that no task owns: (a) retired-tactic prose (`tm_auto` etc.) persists far
  beyond 586's typst chapter -- in `FormalSystem/Automation/README.md` (:61, :114),
  `Automation/ProofSearch/README.md:19`, `typst/chapters/p4-dual-verification.typ:36`, and nine
  `docs/` files; (b) 404 `#check`/`#eval`/`#print` lines across 29 live library files plus 389
  top-level `example`s outside `Examples/` (cslib's pre-PR check treats `#check`/`#eval` in the
  library as debug artifacts); (c) the untasked 2026-09-15 review finding M1 (`Semantics/`'s 15
  flat `Minus*`/`Plus*`/`Star*` files) and the `ForMathlib/README.md` half of M2; (d) three Lean
  docstrings citing non-existent or gitignored `specs/` paths, and 43 citations of durable records
  (`specs/paper-definitions-of-record.md`, `specs/decisions/*`) that live in the task-management
  tree; (e) no Mathlib style linter set (cslib enables `weak.linter.mathlibStandardSet`; here 692
  lines exceed 100 chars in 154 files and 37 files exceed Mathlib's 1,500-line `longFile` limit).
- Recommended: create **4 new tasks** (N1-N4 below; N5 is optional, its state edits can be applied directly), widen 586 and 590, rescope 583, move 569
  (semantic retarget refactor) and 540 (docstring coverage) into the topic, and add ordering
  edges so that every line-number- or path-sensitive task (588, 540, 589) runs after every
  rename/move/reflow task.
- Tasks that stay OUT of the topic: all proof/research programmes (decidability, algebraic
  representation, categorical structure, TM* completeness, frame extensions), dataset pipeline
  tasks, 504 (literature acquisition), 177/178 (gated on open proofs), 592 (agent-system, not
  this codebase).

## Context & Scope

The user asked whether tasks 581-592 (created from the 2026-09-16 sweep) and the rest of the
active backlog can be better organized, combined, replaced, removed, or supplemented, with
priority on non-proof codebase improvement gathered under one topic with clear dependencies;
and suggested cslib as a quality reference. This report inventories all 60 active tasks,
verifies key claims against the tree, compares engineering conventions with cslib, and proposes
the concrete revision set for the implementation phase to apply to `specs/state.json` and
`specs/TODO.md`. No Lean or task file was modified during research.

Constraints honored: topic labels and dependencies are `state.json` fields; task numbers are
never cited in deliverables (only in `specs/`).

## Findings

### Codebase Patterns

**Measured state of the tree (2026-09-16):**

| Metric | Value | Source |
|---|---|---|
| Live Lean files / lines (Boneyard excluded) | 520 / 295,187 | `find FormalSystem -name '*.lean'` |
| Boneyard files / lines | 168 / 91,618 (inside `FormalSystem/Boneyard/`) | same |
| Files > 1,500 lines (Mathlib `longFile` default) | 37; largest `EFGames/GapDetection.lean` 5,090 | `wc -l` |
| Lines > 100 chars (Mathlib `longLine`) | 692 in 154 files | `awk length>100` |
| File-scoped `set_option linter.* false` | 4 (3 in `Semantics/Ultraproduct/`, 1 test) | grep |
| `set_option maxHeartbeats` unscoped / `in`-scoped | 7 / 48 | grep |
| `#check`/`#eval`/`#print` lines in live library | 404 in 29 files (DatasetGenerator 116, Saturation 59, MainResults 54 intentional, Normalization 42, Syntax/Formula 20) | grep |
| Top-level `example` outside `Examples/` | 389 | grep |
| Directories without README (non-Boneyard) | 1: `FormalSystem/ForMathlib` | find |
| `specs/` paths cited from live Lean | 46 (25 paper-definitions-of-record, 18 decisions/, 3 broken) | grep |
| Check-script status (run here) | readme-lint 0, copyright strict 0, metalogic-cycles 1, typst-sync-check 1 | executed |

Broken `specs/` citations in live Lean (verified; targets absent or gitignored):
- `FormalSystem/Syntax/BigConj.lean:30` -> `specs/098/...` (no such dir)
- `FormalSystem/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/CarrierK1V.lean:42` -> `specs/305 report 40`
- `FormalSystem/Syntax/MinusLanguage/Axioms.lean:76` -> `specs/archive/514_.../01_...md` (`specs/archive/` is gitignored, .gitignore:80)

Retired-tactic drift outside 586's scope (verified by grep; `Automation.lean`,
`Tactics/README.md`, `docs/reference/tactic-reference.md` mention them correctly as removed):
`FormalSystem/Automation/README.md:61,114`, `FormalSystem/Automation/ProofSearch/README.md:19`,
`typst/chapters/p4-dual-verification.typ:36`, `docs/user-guide/{tutorial,examples,
tactic-development,troubleshooting}.md`, `docs/project-info/{tactic-registry,FEATURE_REGISTRY,
test-coverage}.md`, `docs/development/METAPROGRAMMING_GUIDE.md`, `docs/reference/API_REFERENCE.md`.

Other doc cruft candidates for 590's widened audit: four `docs/research/leansearch-*.md` files
(~1,450 lines, last touched 2026-07-26, about the LeanSearch API rather than this logic);
`docs/project-info/{implementation-status,performance-targets,test-coverage}.md`; naming
inconsistency across surfaces -- Lake `package Logos`, library `FormalSystem`, test library
`BimodalTest`, repository `BimodalLogic`, root `CLAUDE.md` title "ProofChecker".

**Task-graph hygiene (all active tasks):** 36 dependency numbers point at completed, archived
tasks (e.g. 177 lists 20 deps, of which only 428/429/430 are live). Two `blocked` statuses look
stale: 481 is blocked on 434 and 483, both completed; 428 is blocked on 432/433/434 (completed)
and 465 (live). 481 also cites `MintBound.lean:6199`, but `MintBound` has since been split into
a `MintBound/` directory (the predicate now appears in `MintBound/SigmaFixed.lean`). These are
outside the cleanup topic but belong in this revision pass.

### External Resources

cslib (`/home/benjamin/Projects/cslib`) engineering conventions, compared:

| cslib practice | BimodalLogic state | Disposition |
|---|---|---|
| `lakefile.toml`; `docgen-action` works in `docs.yml` | `lakefile.lean`; `docs.yml.disabled` because docgen-action needs toml | 578 already owns it; cslib is direct precedent for the migration route |
| `weak.linter.mathlibStandardSet = true` in `[leanOptions]` | only `autoImplicit false`, `pp.unicode.fun` | NEW N4 |
| CI builds with `--wfail --iofail` | 316 warnings, no gate | 585 (gate phase should evaluate `--wfail` on cslib precedent vs. count baseline) |
| Blanket-suppression ratchet (`check-lint-suppressions.sh`, only `... false in` allowed) | 4 blanket suppressions, no ratchet | fold into N4 (tiny: fix 4, add ratchet) |
| `lake exe mk_all --check`, `checkInitImports` | C8 aggregator check, C24 `checkInitImports` | already equivalent |
| `lake shake` import minimization (locally ratcheted) | none | out of scope (requires Lean module system; note only) |
| `lint-style-action` text linters | none | fold into N4 |
| Debug-artifact check (`#check`/`#eval`/`dbg_trace` in library) in `pre-pr-check.sh` | 404 such lines in library | NEW N1 |
| Boneyard at repository root, excluded by import reachability | `FormalSystem/Boneyard/`, excluded by name in every walker (source of 589's 11 unresolvable archive citations) | not proposed as a task (ADR-005/009 settled placement; revisit only if 589's convention decision favors it) |
| `ORGANISATION.md`, `NOTATION.md`, per-directory READMEs | all present except `ForMathlib/README.md` | NEW N3 |

cslib is weaker in one respect this tree should not copy: its CI tolerates a red build by design
(bare sorries). BimodalLogic's gated invariants (C1-C26, zero live sorry, axiom pinning) exceed
cslib's; the gap is purely that the checks are not in CI and that compiler/style warnings are
ungated.

### Recommendations

#### 1. One topic: `codebase-cleanup`

Members (15 existing after merging 542, plus 4 new). Topic changes for existing members:

| Task | Current topic | Action |
|---|---|---|
| 578 fix_api_documentation_ci_integration | documentation | re-topic; add package-name decision (`Logos` vs `FormalSystem`/`BimodalLogic`) to its toml migration |
| 581 repair_bilasso_evidence_probes | decidability | re-topic; add final phase "wire `check-evidence-probes.sh` into CI" |
| 582 break_or_rebaseline_metalogic_cycle | metalogic | re-topic; add final phase "wire `check-metalogic-cycles.sh` into CI" |
| 583 wire_check_scripts_into_ci | repo-hygiene | re-topic; RESCOPE (see 3) |
| 584 reconcile_lean_tree_with_paper_vocabulary | paper-refactor | re-topic; absorb `MinusLanguage/Axioms.lean:76` open naming-audit note; final phase wires `check-paper-definitions.sh` (skip-neutral when paper absent) |
| 585 burn_down_compiler_warnings_and_add_gate | code-quality | re-topic |
| 586 rewrite_typst_proof_automation_chapter | reference-book | re-topic; WIDEN to all non-`docs/` retired-tactic prose (Automation READMEs, `p4-dual-verification.typ`); final phase wires `typst-sync-check.sh` |
| 587 repair_or_retire_broken_benchmark_modules | code-quality | re-topic |
| 588 triage_zero_occurrence_declarations | code-quality | re-topic; absorb 542 |
| 589 disambiguate_basename_citations | code-quality | re-topic; absorb the 3 broken `specs/` citations |
| 590 retire_stale_development_documentation | documentation | re-topic; WIDEN to a `docs/` staleness audit (retired-tactic docs, leansearch research docs, project-info status docs, CLAUDE.md title) |
| 591 consolidate_automation_export_names | automation | re-topic |
| 540 docstring_coverage_class_instance_lemma | documentation | re-topic; add deps (see DAG) |
| 569 retarget_semantics_to_possible_world_index | paper-refactor | re-topic (refactor, ~600 touch points, no new theorems) -- see Decisions |
| 506 fix_typst_display_defects_via_playwright_visual_loop | publication-quality | re-topic (layout-only); add dep on 586 |
| 542 dead_declaration_triage_c17_findings | infrastructure | ABANDON, merged into 588 |

#### 2. New tasks

- **N1 relocate_in_library_smoke_tests** (lean4). Classify the 404 `#check`/`#eval`/`#print`
  lines and 389 non-`Examples/` `example`s; move test-shaped ones to `Tests/BimodalTest/` as
  `#guard`/`example`, keep documentation-shaped ones and `MainResults.lean` (intentional axiom
  audit page), and add a debug-artifact check to the invariant harness with a recorded allowlist.
  Must precede 588 because C17 counts `#check @foo` as an occurrence (e.g. Normalization's
  `#check @neg_unfold` block), so removal changes C17's census.
- **N2 establish_durable_records_home** (meta/markdown, small). Decide whether durable records
  (`specs/paper-definitions-of-record.md`, `specs/decisions/*.md`, cited 43 times from Lean and
  read by `check-paper-definitions.sh`) belong under `docs/` rather than the task-management
  tree; move and repoint if so. Precedes 584 (which re-pins the record) and 590.
- **N3 nest_semantics_language_family_files** (lean4). The untasked 2026-09-15 review M1: move
  `Semantics/{Minus,Plus,Star}*.lean` (4+6+5 files) into `Semantics/Minus/`, `Plus/`, `Star/`,
  mirroring the now-landed `Syntax/{Minus,Plus,Star}Language/` nesting; update C8 parent tuple;
  write `ForMathlib/README.md` (the remaining half of review M2). Module-path-only change.
- **N4 adopt_mathlib_standard_linter_set** (lean4). Following cslib: enable
  `weak.linter.mathlibStandardSet` (with cslib's documented opt-outs where they do not apply),
  measure the new warning surface (`longLine` 692, `longFile` 37, header), fix or baseline it
  under 585's gate, convert the 4 blanket linter suppressions and 7 unscoped `maxHeartbeats` to
  `in`-scoped form, and add a blanket-suppression ratchet. `longFile` is baselined, not fixed by
  splitting, unless a split is independently justified.
- **N5 revise_stale_task_graph_metadata** (meta, small). Outside the topic but part of this
  revision: prune completed-task numbers from dependency lists (177's 20 -> 428/429/430, etc.),
  re-examine `blocked` on 481 (both blockers completed) and 428 (only 465 live), and refresh
  481's stale `MintBound.lean:6199` pointer. Alternatively the implementer of this task may apply
  these edits directly (they are state edits, not code) -- preferred, so N5 need not exist.

#### 3. Rescope 583

New scope: wire the checks that are green today -- `check-module-invariants.sh` (full, or
`--no-build` after the lean-action build), `check-copyright-headers.sh --strict --exclude
'*/Boneyard/*' FormalSystem`, `readme-lint.sh` -- and write down the per-script wiring pattern
(step naming, skip-neutral convention for external inputs, runtime budget). Remove its
dependencies on 581/582/586/590. Each of those tasks adds its own script as its last phase;
590 flips `ENFORCE_C9_DOCS=1`. 585's gate then extends 583's workflow rather than competing with
it.

#### 4. Dependency DAG for `codebase-cleanup`

Principle: decisions and structural moves/renames first; burn-downs next; line- and
occurrence-sensitive work last.

| Wave | Task | Direct dependencies (new or kept) | Rationale |
|---|---|---|---|
| 1 | 583 (rescoped) | -- | lock in green gates now |
| 1 | 582 cycle | -- | decision task |
| 1 | 591 automation names | -- | rename |
| 1 | N3 Semantics nesting | -- | module moves |
| 1 | N2 records home | -- | decision; moves paths other tasks cite |
| 1 | 581 evidence probes | -- | API-drift repair |
| 1 | 587 broken benchmarks | -- | repair-or-retire |
| 1 | 578 docs CI / lakefile.toml | -- | independent |
| 1 | N1 in-library tests | -- | relocations |
| 2 | 584 paper vocabulary | 582, 591, N3, N2 | large renames after moves settle |
| 2 | 586 typst + prose (widened) | 591 | kept |
| 2 | 590 docs audit (widened) | N2 | docs home decided first; 590 no longer blocks 583 |
| 3 | 569 semantics retarget | 584 | naming decisions (e.g. `FrameOver.converse`) precede the 600-site sweep |
| 3 | 585 warnings + gate | 583, 584 | kept |
| 3 | 506 typst layout | 586 | re-screenshot after chapter rewrite |
| 4 | N4 Mathlib linter set | 585 | new warnings land under the gate |
| 4 | 588 C17 triage (+542) | 585, 591, N1, 569 | occurrence census after moves/renames/test relocation |
| 5 | 540 docstring coverage | 588, N4 | don't document declarations about to be deleted |
| 6 | 589 basename citations | 588, 540, N4, 584, 591, N3 | terminal: every earlier task shifts cited lines |

No cycles (checked by hand: every edge points to a strictly earlier wave).

## Decisions

- Topic name `codebase-cleanup` (new) rather than reusing `code-quality`/`repo-hygiene`: both
  existing labels are narrower than the user's stated scope and each already covers only a
  fragment; a fresh label avoids implying the old grouping was right.
- 542 abandoned in favor of 588 (newer measurement, concrete cluster lead, explicit no-gating
  constraint); 542's step (1) attribute/simp-set reachability quantification is carried over.
- 177 and 178 stay out: both are gated on open decidability proofs, and 178 writes new example
  proofs. 177's dependency list should still be pruned.
- 563 and 568 stay out: although much content already exists in probes, they add new library
  API to their research programmes.
- 592 stays in `agent-system`: it concerns the deployed agent tree, not this Lean codebase.
- 569 is moved in (non-blocking user decision recorded): it is a refactor that removes 12
  bridges and ~150-250 net lines with no new theorems, matching "doesn't involve writing new
  proofs"; but it is the largest item and gates 588/540/589.
- Boneyard relocation to repository root (cslib layout) is NOT proposed as a task; ADR-005/ADR-009
  settled placement, and the only concrete cost found (C20 archive citations) is already inside
  589's convention decision.
- Tactic survey not performed: no proof goal is in scope.

## Risks & Mitigations

- **Long serial chain** (589 is wave 6). Mitigation: waves 1-2 are wide and parallelizable;
  only the line-sensitive tail is serial, and it is serial by necessity.
- **569 size could stall the tail.** Mitigation: if the user declines folding 569 in, drop the
  569 edge from 588 and keep 569 in `paper-refactor`, ordered after 584.
- **Widening 586/590 inflates them.** Mitigation: both widenings are grep-bounded lists given
  above; if the planner finds a phase exceeds one agent run, split rather than truncate.
- **Rescoped 583 wires the full harness into CI, raising wall-clock.** The sweep measured the
  structural pass at ~20 s; full-build C-checks reuse the lean-action cache. Record the delta as
  583 already requires.
- **N4 may surface hundreds of style warnings.** Mitigation: baseline under 585's gate first,
  burn down opportunistically; never bulk-suppress.
- **Moving durable records (N2) breaks `check-paper-definitions.sh` and 43 Lean citations.**
  Mitigation: N2 is decision-first and precedes both consumers (584, 589); C13/C15 catch missed
  referrers.

## Tactic Survey Results

- Not applicable (no tactic survey performed; this is a task-organization task with no proof goals)

## Context Extension Recommendations

- **Topic**: Task topic taxonomy
- **Gap**: `active_topics` has 26 free-form labels with overlapping scope (`code-quality`,
  `repo-hygiene`, `infrastructure`, `documentation`) and no guidance on when to create vs. reuse one.
- **Recommendation**: add a short topic-assignment note to the repo's project-overview context
  after this reorganization lands.

## Appendix

Commands used (all read-only):
- `jq` over `specs/state.json` and `specs/archive/state.json` (descriptions, topics, dependency
  liveness)
- `grep -rn` for retired-tactic names, `specs/` citations, `#check|#eval|#print`, linter and
  heartbeat options, `formula_unfold` consumers
- `find ... | xargs wc -l`, `awk 'length($0)>100'` for file and line-length metrics
- `bash scripts/readme-lint.sh`, `bash scripts/check-copyright-headers.sh --strict --exclude
  '*/Boneyard/*' FormalSystem`, `bash scripts/check-metalogic-cycles.sh`,
  `bash scripts/typst-sync-check.sh` (exit codes only)
- cslib: `CONTRIBUTING.md`, `ORGANISATION.md`, `lakefile.toml`,
  `docs/lint-suppression-policy.md`, `.github/workflows/{lean_action_ci,lint-hygiene,docs}.yml`,
  `scripts/pre-pr-check.sh`, `Cslib/Init.lean`
