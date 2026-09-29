# Research Report: Task #698

**Task**: 698 - file_scope_declaration_hygiene
**Started**: 2026-09-28
**Completed**: 2026-09-28
**Effort**: research only (no state.json writes performed by this dispatch)
**Dependencies**: None
**Sources/Inputs**: `specs/state.json`, `.claude/scripts/validate-state.sh`,
`.claude/scripts/lib/file-scope-overlap.sh`, `BimodalTools/*.lean`, `Tests/BimodalToolsTest/*`,
`scripts/run_dataset_generation.sh`, `scripts/check-module-invariants.sh`,
`/home/benjamin/.config/nvim/agent-system/extensions/core/scripts/orchestrate-cycle-postflight.sh`
(read-only; different repository, per `.claude/rules/source-store-deploy-boundary.md`)
**Artifacts**: - this report
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- All four Check-8 coarse findings and the one Check-9 duplicate finding have concrete,
  evidence-grounded resolutions; none requires guessing.
- Three of the four coarse findings (project 282, 296, 298's `BimodalTools/` declaration) are
  genuinely stale — code inspection shows each task's real touch surface is one or two specific
  files, not the whole tree — and should be narrowed.
- The fourth (project 177's `FormalSystem/Metalogic/Decidability/` declaration) is a legitimate
  whole-directory claim by the task's own description (an open-ended post-chain documentation
  audit), but its dependency list is missing one of the eight tasks it currently overlaps
  (project 696) — that gap, not the directory-wide declaration itself, is the actual defect.
- The project 178 duplicate (`FormalSystem/Examples/` listed twice) is Check-9 Class A
  (exact-duplicate) and is confirmed, by reading `validate-state.sh`'s `--fix` block directly,
  to be exactly what `--fix` repairs — no hand edit needed.
- `scripts/check-module-invariants.sh` is already correctly declared by the two tasks
  (695, 696) whose descriptions demonstrate they edit its `AXIOM_BASELINE` heredoc; no other
  non-terminal task's description provides comparable evidence of an *edit* (as opposed to a
  non-regression check against it), so no further additions are recommended without more
  evidence.
- The most consequential residue: project 412 (a headline tableau-decidability result, likely to
  need a new `AXIOM_BASELINE` row and a new `docs/theorem-index.md` row on landing) has **no
  file_scope at all**. A missing/null file_scope is invisible to the overlap predicate — worse
  than a coarse directory, which is at least visible as a WARN.
- The systemic enforcement half (postflight comparing reported `modified_files` against declared
  `file_scope`) already exists as **detection-only** code in the other repository
  (`orchestrate-cycle-postflight.sh` lines 1053–1069, WORK (h)) — it computes the exact excursion
  already but only logs it to stderr with no gate effect. This is out of scope here per
  `.claude/rules/source-store-deploy-boundary.md` and is recorded as a named follow-on.

## Context & Scope

Task 698 asks this research pass to make `specs/state.json`'s `file_scope` declarations
accurately describe what non-terminal tasks actually touch, using `scripts/validate-state.sh`'s
Check 8 (coarse whole-directory declarations, WARN when a directory-ending entry overlaps ≥3
other non-terminal tasks) and Check 9 (duplicate entries within one task's own array) as the
mechanical signal. Four coarse findings and one duplicate finding are in scope by name; the
systemic postflight-enforcement half is explicitly out of scope (different repository). This
dispatch is the **research** phase only — it establishes and grounds the concrete recommendations
below; no `specs/state.json` edits were made here.

Baseline `validate-state.sh` output (unmodified tree), Check 8/9/11 lines only:

```
[WARN] Coarse file_scope declaration: project_number 177, entry 'FormalSystem/Metalogic/Decidability/' overlaps 8 distinct non-terminal task(s): 428,429,430,464,465,481,482,696
[WARN] Coarse file_scope declaration: project_number 282, entry 'BimodalTools/' overlaps 3 distinct non-terminal task(s): 177,296,298
[WARN] Coarse file_scope declaration: project_number 296, entry 'BimodalTools/' overlaps 3 distinct non-terminal task(s): 177,282,298
[WARN] Coarse file_scope declaration: project_number 298, entry 'BimodalTools/' overlaps 3 distinct non-terminal task(s): 177,282,296
[WARN] Duplicate file_scope entry (Class A, exact -- repairable by --fix): project_number 178, entry 'FormalSystem/Examples/' appears 2 times
[PASS] No glob-shaped file_scope entries found
```

(The base run also reports 10 FAIL-level schema findings — unknown top-level/entry fields — and
17 total WARNINGs including 23 missing-key / 5 null-value file_scope visibility findings. These
are pre-existing, separately-tracked classes of finding, not named in this task's scope, and are
not addressed here except where one instance — project 412 — bears directly on this task's
`scripts/check-module-invariants.sh` question; see Risks & Mitigations and Context Extension
Recommendations.)

## Findings

### Item 1 — the four coarse declarations

#### (a) Project 177, `FormalSystem/Metalogic/Decidability/` — JUSTIFY, plus close one dependency gap

Project 177 (`update_readme_and_module_docstrings`) is a documentation re-audit that the task's
own description says must run *after* the decidability chain lands, and whose target file set
inside `Decidability/` is explicitly deferred: "The re-audit is open-ended by design: re-derive
and widen file_scope at research time." Narrowing it now, before that chain lands, would be
exactly the guessing the dispatch prohibits. The whole-directory claim is genuinely correct at
this stage.

However, of the 8 non-terminal tasks Check 8 reports as overlapping (428, 429, 430, 464, 465,
481, 482, 696), project 177's own `dependencies` array already lists 7 of them
(428, 429, 430, 464, 465, 481, 482) — meaning the orchestrator's dependency gate
(`orchestrate-cycle-plan.sh`) already prevents 177 from being dispatched while any of those 7 is
non-terminal, so the declared overlap against them is a structural non-issue, already closed by
the existing dependency mechanism 177 uses elsewhere in its own description ("FURTHER EDGES...
because each shares a named path with this task").

**Project 696 is missing from that list.** 696 (`stability_modal_substrate_design`, status
`researched`) declares
`FormalSystem/Metalogic/Decidability/PlusWitnessFamily/*` and
`FormalSystem/Metalogic/Decidability/WitnessFamily/Sharing/*` — both inside the directory 177
claims — and nothing in 177's dependency list gates against it. This is the one real residual
exposure: if 177's other 7 dependencies complete while 696 is still non-terminal, 177 could be
dispatched concurrently with 696 with a genuine (if narrow) file-level collision risk inside
`Decidability/`.

**Recommendation**: keep `FormalSystem/Metalogic/Decidability/` as declared (record the
justification above inline in 177's description, following the same dated-note convention already
used throughout that description), and add `696` to project 177's `dependencies` array — the same
repair pattern 177 already applies to 178/282/296/298/464/465/481/482.

#### (b), (c), (d) Projects 282, 296, 298 — `BimodalTools/` — NARROW

All three inherited an identical `BimodalTools/`, `FormalSystem/Automation/`,
`Tests/BimodalToolsTest/` triad from task 632's relocation note ("file_scope widened to include
BimodalTools/ and Tests/BimodalToolsTest/"), applied as a blanket defensive widening across all
three sibling tasks rather than derived from what each actually touches. Code inspection shows
each task's real surface is narrow:

- **Project 296** (`re_add_the_6_derived_binary_temporal_operators...`, status `partial`,
  depends on 298): the enumerator's operator generation, `passesFilter`, and `canonicalDedup`
  logic (which calls `AtomCanonicalization.canonicalize`) all live in
  `BimodalTools/FormulaEnumerator.lean` (confirmed at lines 308–332, 767–986, 1751–1858); the
  task's own description names two of its four candidate approaches as canonicalization changes,
  which would land in `BimodalTools/AtomCanonicalization.lean`. The dedicated test is
  `Tests/BimodalToolsTest/EnumeratorCountsTest.lean`.
  **Recommended file_scope**: `BimodalTools/FormulaEnumerator.lean`,
  `BimodalTools/AtomCanonicalization.lean`, `Tests/BimodalToolsTest/EnumeratorCountsTest.lean`
  (replacing the three directory-wide entries; other declared entries — `data/bmlogic-c4.json` —
  unchanged).

- **Project 298** (`fix_c7_labeling_bug...`, status `partial`, no dependencies): the "decision
  procedure's timeout handling" the description names is `BimodalTools/DatasetGenerator.lean`'s
  wall-clock timeout machinery (`labelWallclockTimeoutMs`, `labelFormulaImpl`, lines ~1080–1335,
  including the `.timeout` / `wallclock_timeout` labeling path the bug report describes). The
  dedicated test is `Tests/BimodalToolsTest/DatasetGeneratorTest.lean`.
  **Recommended file_scope**: `BimodalTools/DatasetGenerator.lean`,
  `Tests/BimodalToolsTest/DatasetGeneratorTest.lean` (replacing the three directory-wide entries;
  `data/bmlogic-c7.jsonl` unchanged — note the on-disk file is actually
  `data/bmlogic-c7.jsonl.zst`, a pre-existing staleness in the declared name, not part of this
  task's four named findings, flagged only as a minor aside for the implement phase to correct
  opportunistically).

- **Project 282** (`flip_complexity_9_dataset_generation...`, status `partial`, depends on 298):
  the description's "next action" (c9 feasibility probe, then exhaustive regeneration) is a
  script-level mode flip: `scripts/run_dataset_generation.sh` invokes the c9 pipeline with an
  explicit `--mode stratified` override (line 496) against a CLI whose own default is already
  `exhaustive` (`DatasetGeneratorMain.lean` `--mode` flag, default `exhaustive`). No Lean-tooling
  code change is indicated by the description; "corrected... scripts/run_dataset_generation.sh"
  is recorded as already-done prior work, and the remaining work is running the probe,
  editing that one script's mode argument, and regenerating/republishing data. There is no
  evidence this task touches `BimodalTools/`, `FormalSystem/Automation/`, or
  `Tests/BimodalToolsTest/` at all.
  **Recommended file_scope**: drop `BimodalTools/`, `FormalSystem/Automation/`,
  `Tests/BimodalToolsTest/` entirely; add `scripts/run_dataset_generation.sh` explicitly (already
  implicitly touched per the description, just never declared). Other declared entries
  (`data/README.md`, `data/bmlogic-c8.json`, `data/bmlogic-c9.json`, `data/hf-dataset/README.md`)
  unchanged (their on-disk suffixes are also somewhat stale — actual files are e.g.
  `data/bmlogic-c8-stratified_metadata.json` — again a pre-existing staleness outside this task's
  four named findings).

Narrowing all three removes every trailing-`/` entry from their arrays, which also eliminates
their spurious overlap against project 177's single-file
`BimodalTools/TraceExporterMain.lean` entry (177 already depends on all three of 282/296/298
directly, so that overlap was already dependency-gated, but removing it is a clean side effect of
the narrowing rather than something requiring separate action).

After narrowing (b)–(d) and recording justification for (a), Check 8 should report **zero**
coarse findings above threshold, with the one surviving `FormalSystem/Metalogic/Decidability/`
entry (project 177) justified per the deliverable's "or every surviving finding carries a
recorded justification" clause.

### Item 2 — Check 9 duplicate on project 178

Project 178 (`publication_examples_and_demo`) declares
`["FormalSystem/Examples/", "FormalSystem/Examples/"]` — Class A exact duplicate. Reading
`validate-state.sh` lines 255–330 directly: `--fix` computes exactly this case (order-preserving
in-array dedup, `select(($fs|length) != ($dedup|length))`), applies it through the deployed
`state-write.sh` (refusing loudly if no deployed copy is found), and then falls through to
re-validate rather than exiting early. This is precisely the repair task 178 needs.
**Recommendation**: run `bash .claude/scripts/validate-state.sh --fix` at implementation time
rather than hand-editing `specs/state.json`; confirm the deploy is fresh first
(`bash .claude/scripts/deploy-headless.sh` if `--fix` refuses). No other change to 178's
file_scope is indicated by Check 8/9 (its single remaining `FormalSystem/Examples/` entry only
overlaps one other non-terminal task — project 177's single file inside that directory — which is
below the ≥3 coarse threshold and already dependency-gated).

### Item 3 — shared gate/tooling scripts, in particular `scripts/check-module-invariants.sh`

The script's `AXIOM_BASELINE` heredoc (lines 1012–1027, the C2 check) hardcodes fourteen
theorem-name → expected-axiom-set rows. Ten of those fourteen rows are exactly the
`PlusSharingWitnessFamily` declarations project 696's description names verbatim
(`stabFaithful_share_congr`, `plusTruth_iff_mem`, `plusRefutes_of_certifies`,
`stabFamily_separates`, `stabFaithful_diagonal`, `snce_share_congr`,
`not_plusCertifies_stabSnce`, `not_plusCertifies_stabSnce_premise`,
`not_plusValidZTime_stabSnce`) — confirming 696 is the task that "pins" these baseline rows, and
its file_scope already correctly declares `scripts/check-module-invariants.sh` (and
`docs/theorem-index.md`). Project 695 similarly already declares both files (per the territory
block in this dispatch), consistent with C15's theorem-index-row requirement.

I checked every other non-terminal task whose description mentions
`check-module-invariants.sh`/`axiom baseline`/`theorem-index`/`C25`/`axiom-reference`
(700, 412, 481, 482, 563, plus the already-covered 282/296/298/696/695):

- **700, 481, 482, 563** reference the script only as a *non-regression gate*
  ("no regression to any currently-passing check-module-invariants.sh check") or, for 700, as
  narrative about what a *future* task would need to do. None describes editing the script's
  `AXIOM_BASELINE`/theorem-index content itself. Per the same "do not narrow/widen by guessing"
  principle, I am **not** recommending these four be given `scripts/check-module-invariants.sh`
  in file_scope — the evidence supports only a read/gate relationship, not a write one. 481 in
  particular has its own unrelated "C9 register" (an in-file residual catalog inside
  `ClosureResidual.lean`, currently 24 entries) that is a same-name coincidence with the script's
  own Check 9 (task-number-citation check) and should not be confused with it.
- **412** is the strongest latent candidate — Track B of the tableau-decidability programme,
  whose acceptance criterion is "update typst/latex decidability chapters to record headline
  result 2," the same shape of flagship landing that triggered 695/696's C2/C15 entries — but 412
  currently has **no file_scope at all** (`null`), so it cannot be narrowed or extended by this
  item; see Item 4 below.

**Recommendation**: no file_scope changes needed for item 3 beyond what 695/696 already declare;
do not add `scripts/check-module-invariants.sh` to 700/481/482/563 without stronger evidence of
an actual edit.

### Item 4 — residue: undeclared shared write targets

1. **177 ↔ 696 dependency gap** (already covered under Item 1(a)): a real, currently-open
   exposure inside `Decidability/`, closed by adding `696` to 177's `dependencies`.

2. **Project 412's missing file_scope is a structurally worse gap than any coarse directory.**
   Check 8 can only warn about a declaration that *exists* and ends in `/`; an absent or `null`
   file_scope is invisible to `scopes_overlap_first` (an empty array trivially overlaps nothing),
   so it produces **no signal at all**, not even a WARN. 412 is `not_started`, has `null`
   file_scope, and its acceptance criteria (a headline `Decidable (Derivable fc [] phi)` result,
   typst/latex chapter updates) make it a plausible future editor of the same
   `scripts/check-module-invariants.sh` / `docs/theorem-index.md` pair that 695 and 696 already
   correctly declare — exactly the shape of collision this task exists to prevent, sitting one
   step further back (declaration entirely absent rather than merely coarse). This is one
   concrete instance of the pre-existing, separately-tracked "file_scope visibility" class (23
   missing-key + 5 null-value findings across 49 non-terminal tasks) that the dispatch places out
   of this task's four named items; I am not attempting a full sweep of all 28 here, but flag 412
   specifically because it bears directly on the shared-script question this task does ask about.
   Recommend a follow-up (in-repo, in scope for a future `/task`) to give 412 (and 563, the other
   description-matched but null-scope task, which is unrelated presheaf-library work with no
   evident check-module-invariants.sh edit) real file_scope declarations once their plans exist.

3. **No other cross-task file-level overlap was found** among the non-terminal population beyond
   what Check 8/9 already surface and what dependency edges already gate. Tasks that legitimately
   declare the *same specific file* (695 and 696 both declaring
   `scripts/check-module-invariants.sh`; both declaring `docs/theorem-index.md`) are not a defect
   — the territory contract (`context/contracts/territory.md`) and this dispatch's own
   concurrency-note staging discipline (stage and commit only one's own hunks, never a directory
   add) are the designed mechanism for two tasks correctly sharing a declared file, and 695/696
   are listed as concurrent siblings in this very dispatch's Territory block.

4. **Applying recommendations 1–3 does not introduce any new Check 8/9/11 finding**: the
   narrowing in Item 1(b)-(d) only replaces directory-ending entries with file-ending ones (never
   adds a new directory entry), and the 178 `--fix` only removes an exact duplicate (never adds
   one), so no new coarse, duplicate, or glob-shaped finding is created by acting on this report.

### Out-of-scope follow-on (recorded per dispatch instruction, not attempted here)

The systemic enforcement half — postflight comparing a dispatch's reported `modified_files`
against the task's declared `file_scope` and surfacing an overstep — **already exists**, but as
detection-only code, in the source-store repository
(`/home/benjamin/.config/nvim/agent-system`, its own git repo with its own `specs/` tree, per
`.claude/rules/source-store-deploy-boundary.md`):

- File: `extensions/core/scripts/orchestrate-cycle-postflight.sh`
- Block: "WORK (h): modified_files vs file_scope excursion advisory (detection only)", lines
  1053–1069 (comment at line 50 cross-references it: "modified_files vs file_scope excursion
  advisory — detection only, never a gate.")
- Current behavior: computes `excursions_json` (the set of reported `modified_files` not covered
  by the task's declared `file_scope`, when `file_scope` is non-empty) and, if non-empty, writes
  `ADVISORY: task ${task_number} reported modified_files outside its declared file_scope: ...
  (detection only — no gate, no exit-code, no verdict effect).` to stderr only.
- This is exactly why the incident this task's description opens with was not caught: the
  comparison the incident needed already runs, every cycle, but its output has no gating effect
  and is easy to miss in stderr.

**Recommended follow-on task** (to be filed in the agent-system repository, not here): turn WORK
(h)'s existing excursion computation into an actual gate — at minimum, surface it somewhere a
human/agent cannot miss (e.g. into `.return-meta.json`'s `errors[]` or a dedicated
`state.json`/TODO.md flag) and, for a hard overstep (a file entirely outside file_scope, as
opposed to a merely-coarse-but-covering declaration), fail the postflight verdict rather than
logging an advisory. The detection logic itself (lines 1055–1069) does not need to be rewritten —
only its consequence does.

## Decisions

- Recommend justification (not narrowing) for project 177's `Decidability/` entry, paired with a
  dependency-list fix (add 696) — narrowing now would require guessing a target-file set the
  task's own description says cannot yet be known.
- Recommend narrowing 282/296/298's `BimodalTools/`/`FormalSystem/Automation/`/
  `Tests/BimodalToolsTest/` triad to the specific files each task's description and the
  corresponding Lean source demonstrably implicate.
- Recommend `validate-state.sh --fix` (not a hand edit) for project 178's duplicate.
- Recommend no file_scope change for 700/481/482/563 regarding
  `scripts/check-module-invariants.sh` — evidence supports only a read/non-regression
  relationship, not an edit.
- Recommend flagging (not fixing here) project 412's missing file_scope as the concrete, most
  relevant instance of the separately-tracked file_scope-visibility gap.
- Recommend filing the postflight-gating follow-on in the agent-system source-store repository,
  citing the exact existing detection-only block rather than re-describing the problem from
  scratch.

## Risks & Mitigations

- **Risk**: narrowing 296/298's file_scope to a single implementation file each could be too
  tight if their eventual plan also needs a shared helper module (e.g. if approach (1) or (3) from
  296's own candidate list — filter/gate changes rather than canonicalization — turns out to need
  a change to a shared pretty-printer or CLI-argument module not enumerated above).
  **Mitigation**: the plan phase should re-derive/confirm the exact file list against the chosen
  approach before finalizing file_scope, per this task's own "do not narrow by guessing" standard;
  this report's recommendations are the evidence-grounded starting point, not a substitute for
  that re-derivation.
- **Risk**: adding 696 to 177's dependencies could, in principle, delay 177 further if 696 stalls.
  **Mitigation**: 177's own description already carries the precedent for this exact trade-off
  ("if one stalls indefinitely, drop its edge rather than hold this task"), applied to 481/282/
  296/298; the same clause should be understood to extend to the new 696 edge.
- **Risk**: this report's file-name observations (e.g. `data/bmlogic-c7.jsonl.zst` vs. declared
  `data/bmlogic-c7.jsonl`) are real but out of this task's four named items; acting on them here
  would silently widen scope.
  **Mitigation**: recorded as minor asides only, left for opportunistic correction, not bundled
  into this task's deliverable.

## Context Extension Recommendations

- **Topic**: file_scope visibility (missing-key / null-value) as a distinct, larger hygiene class
  from coarse/duplicate declarations.
  **Gap**: no existing context file documents that a missing/null file_scope is *strictly worse*
  for collision detection than a coarse directory declaration (invisible vs. merely permissive),
  even though `validate-state.sh`'s own Check 8/9/(visibility) header comments imply this
  distinction.
  **Recommendation**: a short addendum to
  `context/reference/state-management-schema.md`'s file_scope section (or a new pattern file)
  making this asymmetry explicit, so future hygiene passes prioritize visibility gaps over
  coarseness gaps when both are present.

## Appendix

### Search queries / commands used

- `bash .claude/scripts/validate-state.sh` (baseline Check 1–11 run)
- `sed -n` ranges over `.claude/scripts/validate-state.sh` (Check 8/9/--fix logic) and
  `.claude/scripts/lib/file-scope-overlap.sh` (`scopes_overlap_first` definition)
- `jq` queries against `specs/state.json` for project_number 177, 178, 282, 296, 298, 412, 428,
  429, 430, 464, 465, 481, 482, 563, 695, 696, 700 (`.description`, `.file_scope`,
  `.dependencies`, `.status`)
- `grep`/`find` over `BimodalTools/*.lean`, `Tests/BimodalToolsTest/`,
  `scripts/run_dataset_generation.sh` for `timeout`, `stratified`/`exhaustive`, `passesFilter`,
  `canonical`, `release`/`weakUntil`/`trigger`/`strongRelease`
- `grep -n "AXIOM_BASELINE\|Check 8\|Check 9\|--fix"` and surrounding context in
  `scripts/check-module-invariants.sh` and `validate-state.sh`
- Read-only inspection of
  `/home/benjamin/.config/nvim/agent-system/extensions/core/scripts/orchestrate-cycle-postflight.sh`
  (grep for `modified_files`/`file_scope`) to ground the out-of-scope follow-on precisely, per
  `.claude/rules/source-store-deploy-boundary.md` (read-only; no edits made there)

### References

- `.claude/scripts/validate-state.sh` (Check 8: lines 507–546; Check 9: lines 548–586; `--fix`:
  lines 255–330)
- `.claude/scripts/lib/file-scope-overlap.sh` (`scopes_overlap_first`, `norm`, `is_glob_entry`)
- `scripts/check-module-invariants.sh` (`AXIOM_BASELINE` heredoc, lines 1012–1027; C2 check,
  lines 994–1071)
- `specs/state.json` project entries 177, 178, 282, 296, 298, 412, 428, 429, 430, 464, 465, 481,
  482, 563, 695, 696, 700
- `/home/benjamin/.config/nvim/agent-system/extensions/core/scripts/orchestrate-cycle-postflight.sh`
  lines 50, 1053–1069 (read-only reference; different repository)
