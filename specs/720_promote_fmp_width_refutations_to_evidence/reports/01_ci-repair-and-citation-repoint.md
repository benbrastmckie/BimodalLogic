# Research Report: Task #720

**Task**: 720 - Promote FMP width refutations to evidence (re-scoped: CI repair of the untracked `WIRED_REPO` entries + citation re-point to the landed `Limits/` theorems)
**Started**: 2026-10-10T07:34:19Z
**Completed**: 2026-10-10T07:41:23Z
**Effort**: ~0.5 h research; implementation estimated at 1.5-2 h (three small edits, one source-store edit, two gate runs)
**Dependencies**: 706, 710 (both archived as `completed` in `specs/archive/state.json`; their library landings are in the tree)
**Sources/Inputs**: - Codebase (`scripts/check-evidence-probes.sh`, `.github/workflows/ci.yml`, `FormalSystem/Metalogic/Decidability/FMP/README.md`, `PlusSlicedCertificate/Limits/*`, `.gitignore`, `specs/ROADMAP.md`, `specs/archive/state.json`), git history (`git log --name-status`, `git ls-files`, `git archive HEAD`), GitHub Actions logs (`gh run view 37368592660 --log`, `gh run view 37218607420 --log`), lean-lsp `lean_local_search` (index `unavailable`: positive hits only, used for name confirmation), guarded `lake env lean` compiles of both archived probes, source store at `/home/benjamin/.config/nvim/agent-system/extensions/core/`
**Artifacts**: - specs/720_promote_fmp_width_refutations_to_evidence/reports/01_ci-repair-and-citation-repoint.md
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **The CI red is confirmed from the logs, not inferred.** Run 37368592660 (head `1d06de5a5`, 2026-10-05) prints `FAIL (missing: specs/archive/706_.../NoFiniteCarrierModel.lean)`, `FAIL (missing: specs/archive/710_.../NoFiniteWidthModel.lean)`, `FAIL  2 of 16 wired probe(s) failed`; the earlier run 37218607420 (head `4695a6402`, 2026-10-04, the commit right after the archive) shows the same two failures at the pre-`e8cfcd868` live-task paths (`2 of 15`). The gate has been red on every push since the archive commit `70321e938` (2026-10-04T09:40-07:00).
- **Root cause verified mechanically.** `git archive HEAD | tar -t` contains neither probe; `git ls-files --error-unmatch` fails on both; `git check-ignore --no-index` matches both via `.gitignore:94` (`specs/archive/`). Both files are present on disk here (archived-but-ignored), which is exactly why the gate is green locally and red in CI. `check_probe` tests `[ ! -f "$file" ]` only (`scripts/check-evidence-probes.sh:717-720`); no `ls-files`/`check-ignore` call exists in the script.
- **The library fully subsumes both probes.** Every declaration in `NoFiniteCarrierModel.lean` (349 lines) and `NoFiniteWidthModel.lean` (1180 lines) has a counterpart in `Limits/FiniteCarrier.lean` / `Limits/NoFiniteWidth.lean` (name-by-name check; one rename: probe `S_hist_unique` is library `shift_hist_unique`, `FiniteCarrier.lean:382`). Both modules are imported by `PlusSlicedCertificate.lean:32-33`, so they are inside the `lake build` graph. Both archived probes still compile cleanly at HEAD (guard exit 0, 9 s and 10 s), so either resolution of Deliverable B is mechanically open.
- **Recommended resolution of the two entries: DELETE (option a).** The landed theorems are guarded by `lake build` on every commit, which is strictly stronger than this gate; nothing in either probe survives unlanded; provenance is durably anchored by commits `1b7b8431f` and `b1180dbf8`. Moving the files to `specs/evidence/` (option b) is viable but adds ~20 s of redundant CI work per push and preserves a duplicate that can only drift. Force-tracking under `specs/archive/` (option c) is rejected: it re-creates the fragility the script's own header names.
- **Citation names, corrected.** The dispatch places all five landed names in namespace `...PlusSlicedCertificate.NoFiniteWidth`; that is true only for the width family. The carrier family lives in `FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.FiniteCarrier` (`FiniteCarrier.lean:114-123`). `lean_local_search` confirms both fully-qualified names.
- **Two citation sites the dispatch did not name**: `Limits/README.md:92-97` (elided probe paths plus "The probe is retained as the provenance record and is not superseded" -- false once the entries are deleted) and `scripts/decidability-inventory-baseline.txt:81-82` (`repopath:` records at the OLD live-task paths; a recorded snapshot by its own header, not to be edited). Proposed `file_scope` addition: `Limits/README.md` only.
- **Fixing 720 does not alone turn CI green.** At `1d06de5a5` four check steps failed; at HEAD `check-module-invariants.sh --no-build` passes locally (C9 and INV cleared since), but `check-metalogic-cycles.sh` (unlayered `PlusLanguage.PlusRayFibre`) and `typst-sync-check.sh` still exit 1 locally. Both are outside this task's scope and are named so the implementer does not chase them.

## Context & Scope

The dispatch file (`.dispatch/1.md`) carries three deliverables: **A** -- add a tracked-ness check to `check_probe` plus a header paragraph and a one-sentence note beside the `mv` in the source store's `context/patterns/task-abandon-mode.md`; **B** -- resolve the two un-tracked `WIRED_REPO` entries (force-track, convert to `WIRED` under `specs/evidence/`, or delete); **Deliverable 1** -- re-point `FMP/README.md`'s "The finite-carrier route is refuted, not merely open" subsection from `Probe706.`/`Probe710.` names to the landed library names and delete the "compiled outside the build graph" parenthetical. The third `WIRED_REPO` entry (`specs/archive/476_.../fmp-hypothesis-is-false.lean`) and `.claude/context/project/logic/domain/ztime-no-finite-carrier-fmp.md` are out of scope by the dispatch's own statement and were not examined beyond confirming the 476 file IS tracked (so Deliverable A's new check passes on it).

Declared `file_scope` (from `specs/state.json`): `.github/workflows/ci.yml`, `FormalSystem/Metalogic/Decidability/FMP/README.md`, `scripts/check-evidence-probes.sh`, `specs/evidence/seam-gluing-ray-product/`.

This is a lean4-typed task whose content is script, workflow and README editing; no new Lean proof is required under the recommended path. The Tactic Discovery Survey Protocol therefore was not invoked.

## Findings

### Codebase Patterns

**F1. The gate's missing-file branch, and nothing else, is what CI hits.**
`scripts/check-evidence-probes.sh:714-731` (`check_probe`): `[ ! -f "$file" ]` -> `FAIL (missing: ...)`; otherwise `lake env lean "$file"`. `grep -n 'ls-files\|check-ignore'` over the script returns only prose (no executable call). `ci.yml:22-23` is a plain `actions/checkout@v5`; `ci.yml:119-125` runs the script with `continue-on-error: true`; `ci.yml:352-356` (the `Report results` step) counts the failed outcome and `exit 1`s. Confirmed in the run log: the `Report results` step is the only step with `conclusion: failure` in run 37368592660, and its report lines are `FAIL check-evidence-probes.sh (outcome: failure)` alongside three others (see F8).

**F2. Tracking state of the three `WIRED_REPO` targets (measured this session).**

| Entry (as written in the array, `:694-696`) | On disk here | `git ls-files` | In `git archive HEAD` | `check-ignore --no-index` |
|---|---|---|---|---|
| `specs/archive/476_.../evidence/fmp-hypothesis-is-false.lean` | yes | tracked | yes | n/a (tracked) |
| `specs/archive/706_.../probes/NoFiniteCarrierModel.lean` | yes | **untracked** | **no** | ignored via `.gitignore:94` |
| `specs/archive/710_.../probes/NoFiniteWidthModel.lean` | yes | **untracked** | **no** | ignored via `.gitignore:94` |

All 25 `WIRED` entries resolve to tracked files (loop over the array, zero `UNTRACKED` lines). `git ls-files specs/archive/` lists exactly five force-tracked paths: the 476 probe, 476's `.orchestrator-handoff.json`, `.return-meta.json`, `reports/01_box-faithful-literature-gate.md`, and `specs/archive/state.json`.

**F3. History of the two files.** `git log --all --name-status` on the four candidate paths: `1b7b8431f` (task 706 research) adds `NoFiniteCarrierModel.lean`; `b1180dbf8` (task 710 research) adds `NoFiniteWidthModel.lean`; `70321e938` ("todo: archive 12 completed tasks", 2026-10-04) deletes both from the index (349 and 1180 lines); no commit ever adds an `specs/archive/...` path for either. `e8cfcd868` (2026-10-05, task 732 phase 3) edits only `scripts/check-evidence-probes.sh` (+23/-2), re-pointing the two entries to the ignored archive paths -- so the fix-up itself never touched the index.

**F4. The recurrence mechanism, located in the source store.** `.claude-extensions.json` -> `extensions.core.source_dir` = `/home/benjamin/.config/nvim/agent-system/extensions/core` (a git repo rooted at `/home/benjamin/.config/nvim`, clean apart from unrelated edits). The `mv` into `specs/archive/` appears at `context/patterns/task-abandon-mode.md:63` and `:65` (deployed copy identical on lines 50-70) and, for `/todo`, at `skills/skill-todo/SKILL.md:546` (`mv "$source_dir" "$target_dir"`, step 4c). The dispatch mandates the one-sentence note only beside the `task-abandon-mode.md` `mv`; the `skill-todo` site is named here because it is the one that actually fired (`70321e938`) -- the planner may choose to add the same sentence there.

**F5. The landed library theorems (verified by `grep -n` and `lean_local_search`).**

| Probe name (archived) | Library name | File:line |
|---|---|---|
| `Probe706.no_finite_carrier_sat` | `FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.FiniteCarrier.no_finite_carrier_sat` | `Limits/FiniteCarrier.lean:248` |
| `Probe706.not_finite_carrier_fmp` | `...PlusSlicedCertificate.FiniteCarrier.not_finite_carrier_fmp` | `Limits/FiniteCarrier.lean:349` |
| `Probe706.θ_eq_ofFormula` | `...FiniteCarrier.θ_eq_ofFormula` | `Limits/FiniteCarrier.lean:157` |
| `Probe706.no_ofStep_sat` | `...FiniteCarrier.no_ofStep_sat` | `Limits/FiniteCarrier.lean:323` |
| `Probe706.no_finite_carrier_sat'` / `not_finite_carrier_fmp_fragment` | `...FiniteCarrier.no_finite_carrier_sat'` / `not_finite_carrier_fmp_fragment` | `Limits/FiniteCarrier.lean:447` / `:533` |
| `Probe706.S_hist_unique` | `...FiniteCarrier.shift_hist_unique` (renamed) | `Limits/FiniteCarrier.lean:382` |
| `Probe710.not_plusValidZTime_neg_Φ` | `...PlusSlicedCertificate.NoFiniteWidth.not_plusValidZTime_neg_Φ` | `Limits/NoFiniteWidth.lean:588` |
| `Probe710.no_finite_width_sat` | `...NoFiniteWidth.no_finite_width_sat` | `Limits/NoFiniteWidth.lean:1200` |
| `Probe710.not_certifies` / `not_sliced_complete` / `not_finite_width_fmp` | `...NoFiniteWidth.not_certifies` / `not_sliced_complete` / `not_finite_width_fmp` | `Limits/NoFiniteWidth.lean:1229` / `:1257` / `:1280` |

Namespaces: `FiniteCarrier.lean:114/118/123` opens `FormalSystem.Metalogic.Decidability` > `PlusSlicedCertificate` > `FiniteCarrier`; `NoFiniteWidth.lean:95/99/103` opens the same two then `NoFiniteWidth`. **The dispatch's "in namespace `...NoFiniteWidth`" applies to the width family only.** Both modules are imported at `PlusSlicedCertificate.lean:32-33` and are therefore built by `lake build`; `check-module-invariants.sh --no-build` C3 reports a zero structural-sorry inventory across `FormalSystem/` at HEAD (run this session, exit 0).

**F6. Nothing in either probe survives unlanded.** Name-by-name comparison of every `theorem`/`def` in the two probe files against the two library modules finds exactly one non-identical name (`S_hist_unique` -> `shift_hist_unique`); the `#print axioms` records, `by decide` fixture (`θ_eq_ofFormula`) and the `Node` step-graph fixture all have library twins. The library's own `Limits/README.md:85-86` module table itemises the transcription and `:92-97` states the arguments are unchanged. There is therefore no "scaffolding lemma or `by decide` fixture that 710/706 chose not to carry" to justify option (b) on content grounds.

**F7. Both archived probes compile at HEAD.** Guarded `lake env lean` (via `lake-build-guard.sh build -- env lean FILE`): exit 0 for both, printing the expected `#print axioms` lines (`[propext, Classical.choice, Quot.sound]` for all 7 + 5 headline theorems); elapsed 9 s and 10 s on this machine. So option (b) would need no repair, only the header-path fix (`NoFiniteCarrierModel.lean:24`, `NoFiniteWidthModel.lean:37`) -- but see Recommendations for why it is still not preferred.

**F8. What else is red in CI, so the implementer does not over-read a non-green result.** Run 37368592660's report step: FAIL `check-evidence-probes.sh`, `check-metalogic-cycles.sh`, `check-module-invariants.sh --no-build`, `typst-sync-check.sh`; PASS the other five. Re-run locally at HEAD (`5f5b4360e`): `check-module-invariants.sh --no-build` exit 0 (so the C9/INV failures were fixed by later commits); `check-metalogic-cycles.sh` exit 1 (`unlayered module FormalSystem.PlusLanguage.PlusRayFibre: the per-file table LANGUAGE_FILE_LAYERS["PlusLanguage"] has no row PlusRayFibre`); `typst-sync-check.sh` exit 1. No push has happened since 2026-10-05, so no CI run reflects HEAD. **720's acceptance criterion should be the evidence-probes step and `lake build`, not the whole job.**

**F9. Other citation sites (repo-wide grep for `Probe706|Probe710|NoFiniteCarrierModel|NoFiniteWidthModel`, excluding `.lake`, `.git`, `specs/archive`).**
- `FormalSystem/Metalogic/Decidability/FMP/README.md:84,87,96,98` -- the four in-scope name citations; `:84-85` the parenthetical to delete; `:94-100` the two-limits paragraph to keep ("both probes rely on" -> "both proofs rely on"; "Neither probe says" -> "Neither theorem says" are the only wording changes needed).
- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Limits/README.md:92-97` -- Provenance paragraph: elided paths `specs/.../probes/NoFiniteWidthModel.lean` and `.../NoFiniteCarrierModel.lean`, plus "The probe is retained as the provenance record and is not superseded." Outside declared `file_scope`; proposed addition (one-paragraph edit, see Recommendations).
- `scripts/decidability-inventory-baseline.txt:81-82` -- `REFUTED repopath:specs/706_.../NoFiniteCarrierModel.lean` and `repopath:specs/710_...` at the OLD live-task paths. The file's header says it is "a historical snapshot to diff against, never a live statement"; `generate-decidability-inventory.sh --diff` already reports these two as `- REFUTED` since `e8cfcd868` changed the paths, and that script is not wired into `ci.yml` (grep: no match). Leave it; after deletion the diff will continue to show two removed `repopath:` records, which is the correct historical reading.
- `scripts/check-evidence-probes.sh:685-696` -- the `WIRED_REPO` comment block and the two array entries (in scope).
- `specs/evidence/seam-gluing-ray-product/backward-dual-{asymmetric,mirror}-fixture.lean` -- prose mentions of "Probe710's step graph" and `Probe710.not_finite_width_fmp` inside docstrings; no path citation, no import. Harmless; optionally untouched.
- `specs/734_*` artifacts and `specs/TODO.md`/`state.json` task descriptions -- `specs/**`, exempt.
- `.claude/context/project/logic/domain/ztime-no-finite-carrier-fmp.md` -- out of scope per dispatch (deploy artifact).

**F10. Two dispatch claims corrected on re-verification.** (i) "`ci.yml:239-240` carries the force-tracked-archive-file list": lines 239-240 are a comment inside the `lint-style` step giving a COUNT ("5 deliberately force-tracked files under specs/archive/"), not a list; force-tracking two more files would make that count stale but edits no list. (ii) The dispatch's `lake env lean` header-line numbers (`:24`, `:37`) and the `check_probe` lines (`:717-720`), `.gitignore:94`, `ci.yml:119-125`/`:352-356`, and `Limits` line numbers were all re-opened and hold.

### External Resources

- No Mathlib search was needed: the deliverables are shell, YAML and Markdown edits against already-landed library theorems. `lean_local_search` ran with `index: unavailable`; it returned positive hits for both target names (both the library and the archived `Probe*` declarations), which is sufficient for name confirmation (an empty result would not have been proof of absence).
- `git ls-files --error-unmatch` is the standard, pure-git tracked-ness predicate; it exits non-zero for an untracked or ignored path and needs no network. It is safe in `actions/checkout@v5` (full git repo present). It is also correct here when run locally against an ignored-but-present file, which is precisely the false-green case.

### Recommendations

**R1 (Deliverable A, mandatory): tracked-ness check in `check_probe`.** Insert after the `-f` test at `scripts/check-evidence-probes.sh:717-721` so the "missing" message is preserved for absent files and a distinct message covers present-but-untracked ones:

```bash
  if ! git ls-files --error-unmatch -- "$file" >/dev/null 2>&1; then
    echo "FAIL (untracked: $file -- present on disk but not in version control; a fresh clone has no such file)"
    failures=$((failures + 1))
    return
  fi
```

Add one header paragraph (near "TWO ENTRY FORMS", `:28-33`): a wired probe must be TRACKED, NOT MERELY PRESENT -- `[ -f ]` is satisfied by an ignored file under `specs/archive/`, which is exactly what an archival `mv` produces, so the gate stayed green for everyone with the file on disk and red in CI. Extend the footer text (`:760-762`) with one clause for the untracked case. Verify by a negative test: temporarily point an entry at an ignored path (e.g. one of the archived probes) and confirm the gate prints `FAIL (untracked: ...)`; then restore.

**R2 (Deliverable A, source store): one sentence beside the `mv`** at `/home/benjamin/.config/nvim/agent-system/extensions/core/context/patterns/task-abandon-mode.md:63-65`, stating that the move un-tracks everything under the directory because `specs/archive/` is gitignored, so any guard that cites a file by its task-directory path (the evidence-probe gate's `WIRED_REPO` form) must be re-pointed or the file promoted to `specs/evidence/` before archiving. Same sentence optionally at `skills/skill-todo/SKILL.md:546`. This edit is outside this repository and outside `file_scope` by design (`.claude/rules/source-store-deploy-boundary.md`); do NOT hand-edit `.claude/context/patterns/task-abandon-mode.md`. The deploy-freshness notice says `core` is already stale; whether to run `bash .claude/scripts/deploy-headless.sh` afterwards is the operator's call and is not required for 720's verification.

**R3 (Deliverable B): DELETE the two `WIRED_REPO` entries and their comment block (option a).** Rationale: (i) F6 -- every declaration is in the library, so the probes guard nothing the build does not; (ii) `lake build` checks the library theorems on every commit, strictly stronger than `lake env lean` in a `continue-on-error` step; (iii) the probe files are not in version control at all today, so deleting the entries removes a citation to nothing, not a record; (iv) the durable provenance anchors are commits `1b7b8431f` and `b1180dbf8`, which `Limits/README.md` can cite directly. Concretely: remove `:685-692` (the 706/710 paragraph of the comment block) and `:695-696` (the two array lines), leaving the 476 entry and its paragraphs (`:657-684`, `:694`) untouched. After the edit the gate prints `PASS  all 26 wired probe(s) compile` (25 `WIRED` + 1 `WIRED_REPO`, counted mechanically this session); the pre-edit total is 28, which passes locally only because both ignored files are present on this machine and fails in CI (the 2026-10-05 run saw 16 because twelve `WIRED` entries were added since).

Why not (b): both probes compile, so a `mv` + `git add` + `WIRED` conversion is mechanically open (note `git mv` fails on an untracked source -- `fatal: not under version control`; it would be plain `mv` then `git add`), but it adds ~20 s of redundant CI per push (F7) and a second copy of 1,529 lines that can only drift from the library; the 718 Phase 1 precedent promoted a probe that had NO library counterpart, which is the case this collection exists for. Why not (c): `git add -f` under the ignored `specs/archive/` recreates the fragility the script header already calls out at `:677-681` ("a *new* file at that path would not be [tracked]") and contradicts "Do not move a probe back under a task directory" (`:24`). `ci.yml` then needs **no edit** under R3; the `.github/workflows/ci.yml` `file_scope` entry becomes unused (harmless).

**R4 (Deliverable 1): re-point `FMP/README.md:79-100`.** Replace `Probe706.no_finite_carrier_sat` with `FiniteCarrier.no_finite_carrier_sat` and `Probe710.not_finite_width_fmp` with `NoFiniteWidth.not_finite_width_fmp`, giving the full `FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.` prefix once on first mention and linking the modules by relative path (`../PlusSlicedCertificate/Limits/FiniteCarrier.lean`, `.../NoFiniteWidth.lean`; C13 checks relative links resolve, both exist). Delete the parenthetical at `:84-85`. Keep `:94-100` with the two wording changes in F9. Consider adding `not_finite_carrier_fmp` / `not_sliced_complete` as the corollary names in the same sentence, matching `docs/theorem-index.md:182-193` rows. Add `[Limits README](../PlusSlicedCertificate/Limits/README.md)` under Related Documentation and bump `*Last verified*` (`readme-lint.sh` requires the line to exist, `:283`).

**R5 (proposed `file_scope` addition): `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Limits/README.md`.** Under R3 its Provenance paragraph (`:92-97`) becomes false ("retained ... not superseded"). Re-word to: transcribed from the research probes recorded at commits `1b7b8431f` (`NoFiniteCarrierModel.lean`) and `b1180dbf8` (`NoFiniteWidthModel.lean`); the library modules are now the record and the sole guarded copy. Two sentences; no table change.

**R6 (verification set for the plan).** `bash scripts/check-evidence-probes.sh` exit 0 with `PASS  all 26 wired probe(s) compile`; the negative test from R1; `git ls-files --error-unmatch` on every remaining `WIRED`/`WIRED_REPO` target (loop in Appendix); `bash scripts/check-module-invariants.sh --no-build` still exit 0 (C5/C12/C13 cover the README path edits); `bash scripts/readme-lint.sh`; and a guarded, detached `lake build` (`lake-build-guard.sh build -- build`, per `context/project/lean4/operations/long-builds.md`) -- although no `.lean` file changes under R3, the dispatch names `lake build` green as the finish line.

## Decisions

- D1: Recommend option (a) delete for both `WIRED_REPO` entries; rationale in R3. This is a recommendation; the planner may choose (b) if the user values a standalone probe copy -- F7 shows it is mechanically open.
- D2: Treat `scripts/decidability-inventory-baseline.txt` as read-only (its header forbids live edits); report the resulting `--diff` lines as expected history, not drift to fix.
- D3: Do not touch the 476 entry, `ztime-no-finite-carrier-fmp.md`, the seam-gluing fixture docstrings, or `.claude/**` -- all out of scope per dispatch or deploy-boundary rule.
- D4: No `user_decision` raised: the choice between (a) and (b) is an engineering judgement the artifacts can settle (F6/F7), not a preference only the user can supply.

## Risks & Mitigations

- **R-1: the new check fails in some non-git context.** `check-evidence-probes.sh` already `cd`s to the repo root and is only ever run inside a checkout (local or `actions/checkout`). Mitigation: guard with `git rev-parse --is-inside-work-tree` once at top and skip the tracked-ness test with a loud `WARN` if absent -- optional hardening.
- **R-2: a `WIRED` target under `specs/evidence/` that is tracked but has uncommitted local edits** passes `ls-files` while CI compiles the committed version. Out of scope; same exposure exists for every gated script.
- **R-3: the FMP README re-point silently weakens the two scope-limit paragraphs.** Mitigation: diff-review that `:94-100` changes only "probe(s)" -> "proof(s)/theorem(s)" and nothing else.
- **R-4: CI still red after 720 lands** because of `check-metalogic-cycles.sh` and `typst-sync-check.sh` (F8). Mitigation: state the acceptance criterion as the evidence-probes step + `lake build`, and file the other two separately if not already tracked.
- **R-5: source-store edit lands in a different git repository** (`/home/benjamin/.config/nvim`). Mitigation: commit it there under the same session id; note in the summary that the deployed `.claude/` copy updates only on redeploy.

## Tactic Survey Results

- Not applicable (no tactic survey performed): the recommended path adds no Lean code; both archived probes and both library modules already compile with the standard axiom set.

## Context Extension Recommendations

- **Topic**: Evidence-gate tracked-ness rule.
- **Gap**: `context/project/lean4/` documents compile guards for out-of-graph files but nowhere states that a guard's `[ -f ]` test is satisfied by an ignored file, nor that `specs/archive/` is gitignored and therefore an archival `mv` un-tracks a probe.
- **Recommendation**: after R2 lands in the source store, add a short "Probes and archival" note to `context/project/lean4/operations/` (or the evidence-probe section of `docs/development/CI_CD_PROCESS.md:219`) pointing at `check-evidence-probes.sh`'s header paragraph, so the rule is discoverable from the Lean side as well as the task-management side.

## Appendix

**Commands run this session (all from the repository root).**
- `awk '/^WIRED_REPO=\(/,/^\)/' scripts/check-evidence-probes.sh` -- three entries.
- `for f in <3 WIRED_REPO paths>; do [ -f "$f" ]; git ls-files --error-unmatch "$f"; git check-ignore -q --no-index "$f"; done` -- table F2.
- `awk '/^WIRED=\(/,/^\)/' ... | while read p; do git ls-files --error-unmatch "specs/evidence/$p.lean"; done` -- zero untracked.
- `git archive HEAD | tar -t | grep -E 'NoFiniteCarrierModel|NoFiniteWidthModel|fmp-hypothesis-is-false'` -- only the 476 file.
- `git log --all --oneline --name-status -- <4 paths>` -- F3.
- `git show --stat 1b7b8431f b1180dbf8 70321e938 e8cfcd868`; `git log --date=iso-strict -1 <sha>`.
- `gh run list --limit 8`; `gh run view 37368592660 --log | grep -E 'FAIL \(missing|wired probe'`; same for 37218607420; `gh run view 37368592660 --json jobs`.
- `grep -rnE 'Probe706|Probe710|NoFiniteCarrierModel|NoFiniteWidthModel' --exclude-dir=.lake --exclude-dir=.git --exclude-dir=archive .` -- F9.
- `grep -nE '^(theorem|lemma|def|...)' Limits/FiniteCarrier.lean Limits/NoFiniteWidth.lean` and the archived probes; name-by-name loop -- F5/F6.
- `lean_local_search("no_finite_carrier_sat")`, `lean_local_search("not_finite_width_fmp")` -- index `unavailable`, positive hits for library and `Probe*` names.
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- env lean <probe>` (detached, both files) -- exit 0, 9 s / 10 s.
- `timeout 400 bash scripts/check-module-invariants.sh --no-build` -- exit 0 (C3, C5, C9, C12, C13, INV all PASS).
- `bash scripts/check-metalogic-cycles.sh` -- exit 1; `bash scripts/typst-sync-check.sh` -- exit 1 (F8).
- `git mv -n <archived probe> specs/evidence/...` -- `fatal: not under version control` (R3 note).
- `jq '.extensions.core.source_dir' .claude-extensions.json`; `grep -n 'mv ' <source-store>/context/patterns/task-abandon-mode.md`; `diff` of deployed vs source lines 50-70 (identical).

**Verification loop for the plan (tracked-ness of every wired target):**
```bash
{ awk '/^WIRED=\(/,/^\)/' scripts/check-evidence-probes.sh | grep -o '"[^"]*"' | tr -d '"' | sed 's|^|specs/evidence/|; s|$|.lean|';
  awk '/^WIRED_REPO=\(/,/^\)/' scripts/check-evidence-probes.sh | grep -o '"[^"]*"' | tr -d '"'; } |
while read -r f; do git ls-files --error-unmatch -- "$f" >/dev/null 2>&1 || echo "UNTRACKED: $f"; done
```

**References.** `scripts/check-evidence-probes.sh` header (`:1-37`, `:657-692`); `.github/workflows/ci.yml:112-126, 230-241, 337, 352-356`; `.gitignore:94`; `FormalSystem/Metalogic/Decidability/FMP/README.md:79-100`; `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Limits/README.md:83-97`; `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate.lean:32-33, 253-295`; `docs/theorem-index.md:182-193`; `specs/archive/718_omega_sequence_decidability_full_lplus/plans/02_route-probes-and-handoff.md` Phase 1 (`:179-234`); `specs/ROADMAP.md:99-103`; `.claude/context/project/lean4/operations/long-builds.md`; `.claude/rules/source-store-deploy-boundary.md`.
