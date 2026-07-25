# Implementation Plan: Mechanical Mathlib Linter Compliance (Tier 1 + Tier 2)

- **Task**: 293 - audit_and_fix_mathlib_linter_compliance
- **Status**: [IMPLEMENTING]
- **Effort**: 15 hours
- **Dependencies**: None (task 292 depends on this; task 394 inherits all naming work)
- **Research Inputs**: `specs/293_audit_and_fix_mathlib_linter_compliance/reports/01_mathlib-linter-compliance-baseline.md`
- **Artifacts**: plans/01_mechanical-linter-compliance.md (this file)
- **Standards**: plan-format.md; status-markers.md; artifact-management.md; tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Bring the 67 sorry-free modules scheduled for cslib porting (Tier 1 = 34 files under `Syntax/`,
`Semantics/`, `ProofSystem/`, `Theorems/`, `FrameConditions/`; Tier 2 = 33 named `Metalogic/`
files) into conformance with Mathlib's **mechanical** style and hygiene linters. Scope is
restricted to categories where the correct fix is determined by the diagnostic itself and carries
no semantic risk: line length, unused simp arguments, unused variables, missing/malformed
docstrings, and blank lines inside tactic blocks. All naming work and all judgment-bearing
categories are out of scope. Definition of done: the in-scope diagnostic count for the 67 files
drops from **1,022 to 0**, `lake build` stays at 0 errors, and the 12 known sorries elsewhere in
the tree are unchanged.

### Research Integration

The research report's three-tier scope recommendation is adopted verbatim (T1+T2 = 67 files, all
sorry-free; T3 = 166 `Metalogic/` files deferred). Its working-invocation findings are adopted:
per-file style linting via `lake env lean -Dlinter.mathlibStandardSet=true <file>`, declaration
linting via `lake exe runLinter Bimodal`. Its `fix_long_lines.py` / `fix_unused_simp_args.py`
tooling assessment and its `fix_unused.py`-is-stale warning are adopted.

Every count in this plan was **re-measured during planning** against the actual T1 and T2 file
sets, not copied from the report. Where the two differ, this plan's numbers govern:

| Item | Report | Re-measured | Note |
|---|---|---|---|
| `emptyLine` T1 | 489 in 10 files | **489 in 11 files** | Report's per-file table omits `Semantics/Truth.lean` (5) |
| `longLine` T1 | 89 in 16 files | **89 in 22 files** | Count agrees; file spread is wider |
| `unusedSimpArgs` in `Theorems/` | 9 | **9** | Confirms the report; the "~21" figure circulating in dispatch intel is stale |
| `docBlame` T1+T2 | 8 | **8** | Exact sites re-enumerated from `runLinter` |
| `longLine` T2 | 168 (implied) | **168 in 22 files** | — |
| `maxHeartbeats` T2 | not reported | **8 in 2 files** | New finding; comment-only fix |

Three factual corrections to the report, established by the orchestrator and binding here:

1. `set_option linter.all true` **does exist and works** on v4.33.0-rc1 (verified against a
   control: a bogus option name errors with "Unknown option"; `linter.all` compiles and emits
   real diagnostics). The report's dead-end claim is wrong. It is a usable third mechanism for
   core-Lean linters. This plan does not depend on it, but no phase should repeat the claim.
2. Whether `#check_lint` exists is **unproven** — the failing test only showed that
   `Mathlib.Tactic.Lint`'s olean is not built. It does not matter: `lake exe runLinter Bimodal`
   is confirmed working and is the declaration-linter driver used here.
3. The toolchain is **v4.33.0-rc1** (`lean-toolchain`). The top-level `CLAUDE.md` says
   v4.27.0-rc1 and is stale. Do not edit `CLAUDE.md` — out of scope.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No `specs/ROADMAP.md` consulted for this dispatch (no `roadmap_path` supplied).

## Goals & Non-Goals

**Goals**:
- Eliminate all 508 `linter.style.emptyLine` diagnostics in T1+T2 (489 T1 + 19 T2). Full
  conformance, accepting the proof-readability regression — this is a settled user decision, not
  an open question.
- Eliminate all 257 `linter.style.longLine` diagnostics in T1+T2 (89 T1 + 168 T2).
- Eliminate all 223 `linter.unusedSimpArgs` diagnostics in T1+T2 (9 T1 + 214 T2).
- Eliminate all 14 `linter.unusedVariables` diagnostics in T1+T2, plus the one linter-invisible
  dead binding named below.
- Add the 8 missing docstrings (`docBlame`) and fix the 3 malformed ones
  (`linter.style.docString`).
- Correct stale docstring *content* that contradicts the proof it documents, starting from the
  confirmed `Theorems/ModalS5.lean` case.
- Fix the 1 `linter.style.whitespace` and add the 8 `linter.style.maxHeartbeats` explanatory
  comments (mechanical adjacents; see Assumption below).
- Keep `lake build` at 0 errors throughout, with no change to the 12 known sorries (all in T3).

**Non-Goals** (each is out of scope by an explicit decision, not an oversight):
- **All naming work** → task 394. This includes the 239 in-scope `defsWithUnderscore` findings
  (902 project-wide), every declaration rename, **and the 39 `linter.defProp` def→theorem
  conversions** (3 of which are in T1). The research report recommended the `defProp` subset for
  this task; that recommendation is superseded. If a phase finds itself renaming a declaration or
  changing a `def` to a `theorem`, it has exceeded scope and must stop.
- `linter.flexible` (78: 24 T1 + 54 T2) — each site needs `simp?` run, its suggestion
  transcribed, and the proof re-verified. Judgment work that can break proofs.
- `linter.style.show` (10), `linter.style.nativeDecide` (4), `linter.style.multiGoal` (2),
  `linter.style.openClassical` (1), `linter.unusedTactic` — each changes proof shape or proof
  architecture.
- `simpNF` (42; 17 of T1's 18 are `LINTER FAILED`, i.e. the linter itself errored) and
  `unusedArguments` (11; each is a signature change with its own blast radius).
- **Copyright headers** → task 292, which runs after this task. Do not touch them. Context worth
  passing on: `linter.style.header` reports zero hits here because Mathlib's `isInLibraryRoot`
  looks for `./Bimodal.lean` while `srcDir := "Theories"` puts the root at
  `Theories/Bimodal.lean`, so the header linter silently no-ops in this repo.
- The 554 deprecation warnings (506 `push_neg` → `push Not`). These are v4.31→v4.33 upgrade
  residue, all outside T1+T2 (zero in scope).
- **T3 `Metalogic/`** (166 files, 6,136 diagnostics, all 12 sorries) — not sorry-free, outside
  the task's own predicate.
- `Theories/Bimodal/Boneyard/` (153 files) — unbuilt and inert; 0 oleans, nothing imports it.
- `Theories/Bimodal/Automation/` — outside the porting scope; also, `AxiomNames.lean` and
  `LemmaDB.lean` cannot even accept `-Dlinter.mathlibStandardSet=true` (they do not transitively
  import Mathlib).

**Stated assumption**: the user's scope decision enumerated five categories (line length, unused
simp args, unused variables, missing docstrings, blank lines). This plan additionally includes
`linter.style.docString` (3), `linter.style.whitespace` (1), and `linter.style.maxHeartbeats` (8)
— 12 sites total, all comment- or whitespace-only, all fully determined by the diagnostic, none
touching proof terms. They are folded into the docstring and line-length phases. If the intent
was the literal five, drop Phase 8's malformed-docstring sub-task, Phase 4's whitespace
sub-task, and Phase 6's maxHeartbeats sub-task; nothing else changes.

## Verified In-Scope Inventory

Measured during planning: T1 = the 34 files under `Theories/Bimodal/{Syntax,Semantics,ProofSystem,Theorems,FrameConditions}/`;
T2 = `Metalogic/{Soundness,Completeness,Decidability,Metalogic}.lean` + `Metalogic/{Core,SoundnessLemmas,Decidability}/**` + `Metalogic/WeakCanonical/Separation/*.lean` (33 files).

| Category | T1 | T2 | Total | Files | Phase |
|---|---|---|---|---|---|
| `linter.style.emptyLine` | 489 | 19 | **508** | 15 | 10, 11, 12 |
| `linter.style.longLine` | 89 | 168 | **257** | 44 | 4, 5, 6 |
| `linter.unusedSimpArgs` | 9 | 214 | **223** | 10 | 2, 3 |
| `linter.unusedVariables` | 4 | 10 | **14** | 6 | 7 |
| `docBlame` (missing docstring) | 2 | 6 | **8** | 5 | 8 |
| `linter.style.docString` (malformed) | 3 | 0 | **3** | 2 | 8 |
| `linter.style.maxHeartbeats` | 0 | 8 | **8** | 2 | 6 |
| `linter.style.whitespace` | 1 | 0 | **1** | 1 | 4 |
| **Total mechanical** | **597** | **425** | **1,022** | | |

Plus two linter-invisible items found by hand: the dead `have bc` binding and the stale
`classical_merge` docstring (both named in their phases).

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Line numbers shift under an earlier phase, so a later phase edits the wrong line | H | **H** | Every phase MUST re-derive its own diagnostic positions immediately before editing (command given per phase). Never reuse Phase 1's baseline positions for editing. |
| `fix_long_lines.py` breaks inside a string literal or comment | M | M | Measured hit rate is 7/11 = 64%; it only cuts at commas. Review the diff for every file it touches; hand-fix any line it mangles or leaves >100 chars. Iterate until the linter is clean. |
| `fix_unused_simp_args.py` rewrites out-of-scope T3 files | M | H | The script consumes a build log. **Filter the log to in-scope paths before piping.** A raw `lake build 2>&1 \| fix_unused_simp_args.py` would touch all 525 project-wide sites. |
| Removing a "unused" simp argument breaks the proof (the linter can be wrong when `simp only` ordering matters) | M | L | `lake build` gate after each file, not just each phase. Restore the argument and add a comment if removal breaks the proof; record it as a residual. |
| 489 blank-line deletions produce an unreviewable diff | M | H (certain) | Confined to 3 dedicated phases (10, 11, 12), one commit each, grouped so the whole readability change can be reverted as a unit without unpicking other work. |
| Blank-line deletion inside a tactic block changes parsing | H | L | Mechanically the linter only flags blank lines that carry no syntactic meaning, but the edit touches proof bodies. Gate with `lake build Bimodal.<Module>` **after each file**, per the user's instruction. |
| `fix_unused.py` silently no-ops (its regex expects "unused variable \`x\`"; v4.33 emits "Variable name \`x\` is not explicitly referenced") | L | H (confirmed stale) | Do not use it. Phase 7 fixes all 14 sites by hand. |
| Touching `ProofSystem/Axioms.lean` or `Syntax/Formula.lean` triggers a near-full rebuild | L | H | Use scoped `lake build Bimodal.<Module>` for per-file gates; reserve full `lake build` for phase-end. |
| Scope creep into naming | M | M | Phases 2-13 each carry an explicit "do not rename, do not convert def→theorem" constraint. |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5 | 4 |
| 6 | 6 | 5 |
| 7 | 7 | 6 |
| 8 | 8 | 7 |
| 9 | 9 | 8 |
| 10 | 10 | 9 |
| 11 | 11 | 10 |
| 12 | 12 | 11 |
| 13 | 13 | 12 |

Phases within the same wave can execute in parallel. **This plan is deliberately fully
sequential** — one phase per wave — for three concrete reasons, not for want of analysis:

1. **File territory overlaps heavily across categories.** `Metalogic/Soundness.lean` carries
   simpArgs, longLine, and emptyLine work; `Perpetuity/Principles.lean` carries simpArgs,
   longLine, emptyLine, and the dead-binding fix; `Decidability/Saturation.lean` carries
   longLine, unusedVariables, and maxHeartbeats. Category-parallel dispatch would put two agents
   in the same file.
2. **Every edit position is line-number-sensitive.** Two concurrent phases editing one file
   invalidate each other's positions mid-run, which is exactly the failure this plan's per-phase
   re-derivation requirement exists to prevent.
3. **The verification gate cannot be parallelized.** `lake build` writes to a single shared
   `.lake/build` directory; concurrent invocations contend rather than overlap, so parallel
   phases would serialize at the gate anyway.

---

### Phase 1: Baseline capture and tooling verification [COMPLETED]

- **Goal:** Produce durable, in-repo baseline logs that every later phase measures its delta
  against, and confirm the two Mathlib fix scripts behave as documented on this repo.
- **Tasks:**
  - [x] Write the in-scope file lists to the task directory so no later phase has to re-derive
        them:
        ```bash
        cd /home/benjamin/Projects/BimodalLogic
        D=specs/293_audit_and_fix_mathlib_linter_compliance/baseline
        mkdir -p "$D"
        find Theories/Bimodal/Syntax Theories/Bimodal/Semantics Theories/Bimodal/ProofSystem \
             Theories/Bimodal/Theorems Theories/Bimodal/FrameConditions -name '*.lean' \
          | sort > "$D/t1.txt"    # expect 34 lines
        { echo Theories/Bimodal/Metalogic/Completeness.lean
          echo Theories/Bimodal/Metalogic/Decidability.lean
          echo Theories/Bimodal/Metalogic/Metalogic.lean
          echo Theories/Bimodal/Metalogic/Soundness.lean
          find Theories/Bimodal/Metalogic/Core Theories/Bimodal/Metalogic/SoundnessLemmas \
               Theories/Bimodal/Metalogic/Decidability -name '*.lean'
          find Theories/Bimodal/Metalogic/WeakCanonical/Separation -maxdepth 1 -name '*.lean'
        } | sort > "$D/t2.txt"    # expect 33 lines
        cat "$D/t1.txt" "$D/t2.txt" > "$D/scope.txt"   # expect 67 lines
        ```
  - [x] Capture the style baseline over all 67 files and confirm the totals in the Verified
        In-Scope Inventory table above reproduce:
        ```bash
        cat "$D/scope.txt" | xargs -P 8 -I{} sh -c \
          'lake env lean -Dlinter.mathlibStandardSet=true "{}" 2>&1 | sed "s|^|{}::|"' \
          > "$D/style-before.log" 2>&1
        grep -o 'linter\.[A-Za-z.]*' "$D/style-before.log" | sort | uniq -c | sort -rn
        ```
        Expect (allowing ±1 from log-wrapping artifacts): emptyLine 508, longLine 257,
        unusedSimpArgs 223, flexible 78, unusedVariables 14, show 10, maxHeartbeats 8,
        nativeDecide 4, docString 3, defProp 3, multiGoal 2, unusedTactic 2, whitespace 1,
        openClassical 1.
  - [x] Capture the declaration baseline: `lake exe runLinter Bimodal > "$D/runlinter-before.log" 2>&1`
        (exits 1 by design when findings exist; that is not a failure). Confirm the header reads
        `Found 1328 errors in 6520 declarations`.
  - [x] Capture the build baseline: `lake build > "$D/build-before.log" 2>&1`. Confirm 0 errors,
        `grep -c "warning:"` ≈ 1657, and `grep -c "declaration uses"` = 12 (the 12 known T3
        sorries — this is the regression guard used by every later phase).
  - [x] Verify `fix_long_lines.py` on one throwaway target and **revert the edit**:
        `python3 .lake/packages/mathlib/scripts/fix_long_lines.py Theories/Bimodal/Syntax/Formula.lean:<line>`
        then `git diff` to confirm it cut at a comma and re-indented by +2, then `git checkout --
        Theories/Bimodal/Syntax/Formula.lean`. (The working tree is clean at this point, so this
        discard is permitted; if it is not clean, snapshot first per
        `.claude/rules/git-workflow.md`.)
  - [x] Verify `fix_unused_simp_args.py`'s log format assumption holds:
        `grep -cE "^warning: [^:]+\.lean:[0-9]+:[0-9]+: This simp argument is unused:\s*$" "$D/build-before.log"`
        must return 525. Do not run the script yet.
  - [x] Confirm `fix_unused.py` is stale and record it: its regex expects ``unused variable `x` ``
        but `build-before.log` contains "Variable name \`x\` is not explicitly referenced". **Do
        not use it in Phase 7.**
- **Timing:** 0.5 hours
- **Depends on:** none
- **Files to modify:**
  - `specs/293_audit_and_fix_mathlib_linter_compliance/baseline/*` — new baseline logs and file
    lists (no source file is modified in this phase)
- **Verification:**
  - `wc -l $D/scope.txt` = 67
  - The style totals reproduce the inventory table
  - `lake build` exits 0; exactly 12 `declaration uses` lines
  - `git status --short` shows only the new `baseline/` files

---

### Phase 2: unusedSimpArgs — T1 and the T2 long tail [NOT STARTED]

- **Goal:** Remove 32 unused simp arguments across 8 files, leaving the two high-volume T2 files
  for Phase 3.
- **Tasks:**
  - [ ] Re-derive current positions (do not reuse Phase 1's log for editing):
        `lake build 2>&1 | grep -A2 "This simp argument is unused" > /tmp/simp-now.log`
  - [ ] Fix T1 (9 sites, 3 files). All 9 were verified during planning; 8 are the single lemma
        `Formula.swap_temporal_all_past` and 1 is `Formula.swap_temporal`:
    - [ ] `Theories/Bimodal/Theorems/Perpetuity/Bridge.lean` — 3 sites (baseline lines 191, 604, 706)
    - [ ] `Theories/Bimodal/Theorems/Perpetuity/Principles.lean` — 5 sites (baseline lines 402, 669, 746, 812, 848)
    - [ ] `Theories/Bimodal/Theorems/GeneralizedNecessitation.lean` — 1 site (baseline line 96)
  - [ ] Fix the T2 long tail (23 sites, 5 files):
    - [ ] `Metalogic/SoundnessLemmas/FrameClassVariants.lean` — 8
    - [ ] `Metalogic/Core/DeductionTheorem.lean` — 6
    - [ ] `Metalogic/Decidability/CountermodelExtraction.lean` — 5
    - [ ] `Metalogic/Decidability/Propositional/Decidable.lean` — 3
    - [ ] `Metalogic/Decidability/FMP/Filtration.lean` — 1
  - [ ] Either hand-edit each `simp only [...]` list, or drive `fix_unused_simp_args.py` from a
        log **filtered to these 8 paths only**. A raw pipe would also rewrite Phase 3's files and
        all 302 out-of-scope T3 sites.
  - [ ] `lake build Bimodal.<Module>` after each file; full `lake build` at phase end.
  - [ ] Do not rename anything. Do not convert any `def` to a `theorem`.
- **Timing:** 0.75 hours
- **Depends on:** 1
- **Files to modify:** the 8 files listed above — each has one or more `simp only [...]` argument
  lists shortened
- **Verification:**
  - `lake env lean -Dlinter.mathlibStandardSet=true <file>` reports 0 `unusedSimpArgs` for each
    of the 8 files
  - `lake build` at 0 errors; still exactly 12 `declaration uses`
  - Project-wide `unusedSimpArgs` count drops from 525 to 493

---

### Phase 3: unusedSimpArgs — Soundness.lean and DenseValidity.lean [NOT STARTED]

- **Goal:** Remove the 190 remaining in-scope unused simp arguments, concentrated in two files.
- **Tasks:**
  - [ ] Re-derive positions from a fresh `lake build 2>&1`.
  - [ ] `Metalogic/Soundness.lean` — 161 sites
  - [ ] `Metalogic/SoundnessLemmas/DenseValidity.lean` — 29 sites
  - [ ] Drive `fix_unused_simp_args.py` from a log filtered to exactly these two paths, then
        review the diff: confirm only simp-argument lists changed and no proof term was touched.
  - [ ] `lake build Bimodal.Metalogic.SoundnessLemmas.DenseValidity` then
        `lake build Bimodal.Metalogic.Soundness`, then full `lake build`.
  - [ ] If removing an argument breaks a proof, restore it, add a short comment explaining why
        the linter is wrong at that site, and record it in the phase notes as a residual rather
        than forcing the fix.
  - [ ] Do not rename anything. Do not convert any `def` to a `theorem`.
- **Timing:** 1 hour
- **Depends on:** 2
- **Files to modify:**
  - `Theories/Bimodal/Metalogic/Soundness.lean` — 161 simp-argument removals
  - `Theories/Bimodal/Metalogic/SoundnessLemmas/DenseValidity.lean` — 29 simp-argument removals
- **Verification:**
  - Both files report 0 `unusedSimpArgs` under `-Dlinter.mathlibStandardSet=true`
  - In-scope `unusedSimpArgs` total is 0 (project-wide drops from 493 to 302, all T3)
  - `lake build` at 0 errors; still exactly 12 `declaration uses`

---

### Phase 4: longLine — Tier 1, plus the one whitespace fix [NOT STARTED]

- **Goal:** Bring all 89 over-length T1 lines under 100 characters and fix the single
  `linter.style.whitespace` site.
- **Tasks:**
  - [ ] Re-derive positions: sweep the 34 T1 files with `-Dlinter.mathlibStandardSet=true` and
        extract `longLine` locations. Phases 2-3 shifted nothing in most of these files, but
        `Bridge.lean` and `Principles.lean` were edited — re-derive, do not assume.
  - [ ] Run `fix_long_lines.py <path>:<line> ...` over the collected positions. It processes in
        reverse line order so offsets stay valid within a file. Expect ~64% resolved
        automatically.
  - [ ] Hand-fix the residue — lines with no comma before column 100 need a different break
        (rewrap a comment, split a `have`, introduce a local binding). Iterate: re-run the linter
        and re-run the script until each file is clean.
  - [ ] Review every diff hunk for a break inserted inside a string literal — the script will do
        this happily and it is the one way this phase can change behavior.
  - [ ] Expected distribution (baseline, 22 files): `Theorems/Combinators.lean` 18,
        `Theorems/ContextualProofs.lean` 11, `Syntax/SubformulaClosure/TemporalFormulas.lean` 11,
        `Syntax/Formula.lean` 7, `Theorems/Perpetuity/Bridge.lean` 6,
        `Theorems/Perpetuity/Principles.lean` 4, `Theorems/Propositional/Reasoning.lean` 3,
        `Theorems/Propositional/Core.lean` 3, `Theorems/Perpetuity/Helpers.lean` 3,
        `Semantics/Validity.lean` 3, `Semantics/TaskFrame.lean` 3,
        `Theorems/TemporalDerived.lean` 2, `Theorems/ModalS5.lean` 2, `Theorems/ModalS4.lean` 2,
        `Syntax/SubformulaClosure/NestingDepth.lean` 2, `Semantics/WorldHistory.lean` 2,
        `FrameConditions/Compatibility.lean` 2, and 1 each in
        `Syntax/SubformulaClosure/Closure.lean`, `Semantics/TaskModel.lean`,
        `ProofSystem/Derivation.lean`, `ProofSystem/Derivable.lean`,
        `FrameConditions/FrameClass.lean`.
  - [ ] Fix `linter.style.whitespace` at `Theories/Bimodal/Semantics/TaskFrame.lean:284:94`
        ("remove line break in the source").
  - [ ] `lake build Bimodal.<Module>` after each file; full `lake build` at phase end.
  - [ ] Do not rename anything. Do not convert any `def` to a `theorem`.
- **Timing:** 1.5 hours
- **Depends on:** 3
- **Files to modify:** the 22 T1 files above — long lines broken; plus
  `Semantics/TaskFrame.lean` line-break removal
- **Verification:**
  - Every T1 file reports 0 `longLine` and 0 `whitespace` under `-Dlinter.mathlibStandardSet=true`
  - `lake build` at 0 errors; still exactly 12 `declaration uses`
  - No new diagnostic category appears in the T1 sweep (a bad break can introduce `multiGoal` or
    parse changes)

---

### Phase 5: longLine — Tier 2 heavy files [NOT STARTED]

- **Goal:** Fix the 126 over-length lines concentrated in the six worst T2 files.
- **Tasks:**
  - [ ] Re-derive positions for these six files. Phases 2-3 edited four of them, so baseline line
        numbers are stale by construction.
  - [ ] `Metalogic/Soundness.lean` — 40
  - [ ] `Metalogic/Decidability/Saturation.lean` — 22
  - [ ] `Metalogic/Decidability/CountermodelExtraction.lean` — 20
  - [ ] `Metalogic/SoundnessLemmas/DenseValidity.lean` — 19
  - [ ] `Metalogic/Decidability/Tableau.lean` — 13
  - [ ] `Metalogic/SoundnessLemmas/FrameClassVariants.lean` — 12
  - [ ] Same method as Phase 4: `fix_long_lines.py` then hand-fix the residue, iterating until
        clean. Review each hunk for string-literal breakage.
  - [ ] `lake build Bimodal.<Module>` after each file; full `lake build` at phase end.
  - [ ] Do not rename anything. Do not convert any `def` to a `theorem`.
- **Timing:** 1.5 hours
- **Depends on:** 4
- **Files to modify:** the 6 T2 files above — long lines broken
- **Verification:**
  - Each of the 6 files reports 0 `longLine`
  - `lake build` at 0 errors; still exactly 12 `declaration uses`

---

### Phase 6: longLine — Tier 2 tail, plus maxHeartbeats comments [NOT STARTED]

- **Goal:** Fix the remaining 42 over-length T2 lines and add the 8 required `maxHeartbeats`
  explanatory comments.
- **Tasks:**
  - [ ] Re-derive `longLine` positions across all 33 T2 files; the residue should be exactly the
        16 files not covered by Phase 5. Baseline counts: `Metalogic/Completeness.lean` 8,
        `Decidability/ProofExtraction.lean` 5, `Core/MCSProperties.lean` 4,
        `Metalogic/Metalogic.lean` 3, `Decidability/FMP/FMP.lean` 3,
        `Decidability/CancellableExpansion.lean` 3, `Core/RestrictedMCS/Basic.lean` 3,
        `Core/MaximalConsistent.lean` 3, `WeakCanonical/Separation/Defs.lean` 2,
        `Decidability/SignedFormula.lean` 2, and 1 each in `SoundnessLemmas/Core.lean`,
        `Decidability/Propositional/PropForm.lean`, `Decidability/Propositional/Kalmar.lean`,
        `Decidability/FMP/TruthPreservation.lean`, `Decidability/Closure.lean`. Trust the
        re-derived list over these numbers if they disagree.
  - [ ] Fix each with `fix_long_lines.py` plus hand-fixed residue.
  - [ ] Add a `maxHeartbeats` justification comment at each of the 8 sites. The linter asks only
        for "a comment explaining the need for modifying the maxHeartbeat limit" immediately
        before the `set_option`; write a real one-line reason (e.g. what makes the proof
        expensive), not filler. Baseline sites:
    - [ ] `Metalogic/Decidability/CountermodelExtraction.lean` lines 498, 552, 588, 621, 679, 733, 795
    - [ ] `Metalogic/Decidability/Saturation.lean` line 1150
  - [ ] `lake build Bimodal.<Module>` after each file; full `lake build` at phase end.
  - [ ] Do not rename anything. Do not convert any `def` to a `theorem`.
- **Timing:** 1 hour
- **Depends on:** 5
- **Files to modify:** the 16 T2 tail files (long lines broken) plus
  `Decidability/CountermodelExtraction.lean` and `Decidability/Saturation.lean` (comments added)
- **Verification:**
  - Full T1+T2 sweep reports 0 `longLine` (down from 257) and 0 `maxHeartbeats` (down from 8)
  - `lake build` at 0 errors; still exactly 12 `declaration uses`

---

### Phase 7: unusedVariables, plus the dead `have bc` binding [NOT STARTED]

- **Goal:** Resolve all 14 `linter.unusedVariables` diagnostics and remove one linter-invisible
  dead binding.
- **Tasks:**
  - [ ] **Do not use `.lake/packages/mathlib/scripts/fix_unused.py`** — confirmed stale in Phase
        1 (its regex expects ``unused variable `x` ``; v4.33 emits "Variable name \`x\` is not
        explicitly referenced"). Fix all 14 by hand.
  - [ ] For each site, choose deliberately between the three remedies the diagnostic offers:
        remove the binding (if truly unused), rename to `_` (if used implicitly by position), or
        prefix with `_` (to keep the documentary name). Prefer `_`-prefixing in pattern matches
        where the name documents the case.
  - [ ] T1 (4 sites): `Theories/Bimodal/Syntax/Formula.lean` lines 186:45, 188:45, 206:39,
        213:39 — all the binding `ψ2`.
  - [ ] T2 (10 sites):
    - [ ] `Metalogic/Decidability/Saturation.lean` — 330:23, 350:19, 406:16
    - [ ] `Metalogic/Decidability/FMP/Filtration.lean` — 297:9, 297:11
    - [ ] `Metalogic/Decidability/FMP/TruthPreservation.lean` — 75:9, 75:11
    - [ ] `Metalogic/Decidability/FMP/FiniteModel.lean` — 85:11 (reported twice)
    - [ ] `Metalogic/Decidability/FMP/FMP.lean` — 174:7
  - [ ] Remove the dead binding in `Theories/Bimodal/Theorems/Perpetuity/Principles.lean`: `have
        bc : ⊢ (B.imp Formula.bot).imp ((A.imp B).imp (A.imp Formula.bot)) := b_combinator` at
        baseline lines 124-125, inside `def contraposition` (baseline line 110). Verified during
        planning: after line 125, `bc` appears only in comments (lines 129, 130, 133, 136-138,
        140-142, 147, 158) — never in code. The proof actually goes through `s_inst` and `s_b`
        (baseline lines 170, 175). Delete the `have` **and** the superseded commentary that
        narrates it, keeping the comments that describe the `s_inst`/`s_b` route that is actually
        taken. No linter reports this; it is a hand-found item.
  - [ ] `lake build Bimodal.<Module>` after each file; full `lake build` at phase end.
  - [ ] Do not rename any *declaration* — renaming a local binding to `_` is in scope; renaming a
        `def`/`theorem` is not.
- **Timing:** 1 hour
- **Depends on:** 6
- **Files to modify:** `Syntax/Formula.lean`, `Metalogic/Decidability/Saturation.lean`,
  `Metalogic/Decidability/FMP/{Filtration,TruthPreservation,FiniteModel,FMP}.lean`,
  `Theorems/Perpetuity/Principles.lean`
- **Verification:**
  - Full T1+T2 sweep reports 0 `unusedVariables` (down from 14)
  - `grep -n '\bbc\b' Theories/Bimodal/Theorems/Perpetuity/Principles.lean` returns nothing
  - `lake build` at 0 errors; still exactly 12 `declaration uses`

---

### Phase 8: Missing and malformed docstrings [NOT STARTED]

- **Goal:** Add the 8 missing docstrings and fix the 3 malformed ones.
- **Tasks:**
  - [ ] Re-derive from `lake exe runLinter Bimodal` (for `docBlame`) and the style sweep (for
        `linter.style.docString`). Note `docBlameThm` is `@[env_linter disabled]` and Mathlib does
        not enable it, so *theorem* docstrings are not audited — only definitions.
  - [ ] Add missing docstrings (`docBlame`, 8 sites, baseline positions). Each must describe what
        the definition means in the bimodal-logic setting, not restate its type:
    - [ ] `Syntax/SubformulaClosure/TemporalFormulas.lean:262` — `Bimodal.Syntax.deferralClosure`
    - [ ] `Theorems/Propositional/Core.lean:61` — `Bimodal.Theorems.Propositional.efq_axiom`
    - [ ] `Metalogic/Decidability/FMP/FMP.lean:158` — `BundledFilteredFrame.phi`
    - [ ] `Metalogic/Decidability/FMP/FMP.lean:159` — `BundledFilteredFrame.frame`
    - [ ] `Metalogic/Decidability/Tableau.lean:326` — `Bimodal.Metalogic.Decidability.applyRule`
    - [ ] `Metalogic/WeakCanonical/Separation/Defs.lean:35` — `IntStructure.val`
    - [ ] `Metalogic/WeakCanonical/Separation/Defs.lean:324` — `junction_depth_U`
    - [ ] `Metalogic/WeakCanonical/Separation/Defs.lean:332` — `junction_depth_S`
  - [ ] Fix malformed docstrings (`linter.style.docString`: "doc-strings should start with a
        single space or newline"), 3 sites:
    - [ ] `Semantics/TaskFrame.lean:271`
    - [ ] `Semantics/TaskFrame.lean:293`
    - [ ] `Semantics/TaskModel.lean:86`
  - [ ] Do not rename `junction_depth_U`/`junction_depth_S`/`efq_axiom` or any other underscored
        declaration, even though `defsWithUnderscore` also flags them. Naming is task 394.
  - [ ] `lake build Bimodal.<Module>` after each file; full `lake build` at phase end.
- **Timing:** 1 hour
- **Depends on:** 7
- **Files to modify:** `Syntax/SubformulaClosure/TemporalFormulas.lean`,
  `Theorems/Propositional/Core.lean`, `Metalogic/Decidability/FMP/FMP.lean`,
  `Metalogic/Decidability/Tableau.lean`, `Metalogic/WeakCanonical/Separation/Defs.lean`,
  `Semantics/TaskFrame.lean`, `Semantics/TaskModel.lean`
- **Verification:**
  - `lake exe runLinter Bimodal` reports 0 `docBlame` findings within the 67 in-scope files (down
    from 8; project-wide drops from 99 to 91, the rest in T3 and `Automation/`)
  - Full T1+T2 sweep reports 0 `linter.style.docString` (down from 3)
  - `lake build` at 0 errors; still exactly 12 `declaration uses`

---

### Phase 9: Stale docstring content audit [NOT STARTED]

- **Goal:** Find and correct docstrings whose *content* contradicts the proof they document. No
  linter catches this, so the phase is bounded by a claim-pattern search rather than by a
  diagnostic list.
- **Tasks:**
  - [ ] Fix the confirmed case first. `Theories/Bimodal/Theorems/ModalS5.lean` lines 49-63
        document `classical_merge` as blocked: line 54 reads "**Status**: Complex deduction
        theorem dependency. Marked as infrastructure gap", lines 56-59 list three unimplemented
        routes, and lines 61-62 give a "**Workaround**" paragraph. But `classical_merge` at line
        64 is fully proven by `exact Propositional.classical_merge P Q`. Replace the false status
        and workaround text with an accurate description; keep the statement and the case-analysis
        explanation (lines 50-52), which are correct.
  - [ ] Search the 67 in-scope files for the same failure mode — docstrings and doc-comments
        making status, blocker, or incompleteness claims:
        ```bash
        grep -rn -iE '\*\*Status\*\*|infrastructure gap|Workaround|not (yet )?(proven|derived|implemented)|blocked|TODO|FIXME|axiomatiz|assumed without proof|cannot be derived' \
          $(cat specs/293_audit_and_fix_mathlib_linter_compliance/baseline/scope.txt)
        ```
  - [ ] For each hit, read the claim against the declaration it documents and classify: (a) claim
        is false because the proof now exists → rewrite the docstring; (b) claim is true → leave
        it, and record it in the phase notes as a genuine known gap; (c) claim is about an
        out-of-scope file or a T3 sorry → leave it.
  - [ ] Correct only category (a). This phase changes comments only — no proof term, no
        signature, no name.
  - [ ] Record every (b) finding in the phase notes; these are real documentation of real gaps and
        must not be silently deleted to make the audit look clean.
  - [ ] Full `lake build` at phase end (comment-only edits, but the gate is cheap insurance).
- **Timing:** 1.5 hours
- **Depends on:** 8
- **Files to modify:** `Theorems/ModalS5.lean` (confirmed) plus whichever in-scope files the
  claim-pattern search implicates — comment text only
- **Verification:**
  - `Theorems/ModalS5.lean` no longer claims `classical_merge` is an infrastructure gap
  - Every claim-pattern hit in the 67 files is classified (a)/(b)/(c) in the phase notes
  - `git diff` for this phase touches only comments and docstrings — zero changes inside proof
    terms or declaration signatures
  - `lake build` at 0 errors; still exactly 12 `declaration uses`

---

### Phase 10: emptyLine deletion — group A (heaviest T1 files) [NOT STARTED]

- **Goal:** Delete the 215 `linter.style.emptyLine` blank lines in the three heaviest T1 files.
  Per the settled user decision, full conformance is required and the proof-readability
  regression is accepted.
- **Tasks:**
  - [ ] Re-derive positions per file immediately before editing — Phases 4, 8, and 9 touched some
        of these files:
        ```bash
        lake env lean -Dlinter.mathlibStandardSet=true <file> 2>&1 | grep -B20 emptyLine
        ```
  - [ ] `Theorems/ModalS5.lean` — 87 deletions
  - [ ] `Theorems/Propositional/Core.lean` — 75 deletions
  - [ ] `Theorems/Propositional/Connectives.lean` — 53 deletions
  - [ ] These are visual separators between `have` steps inside tactic blocks (many of which
        already carry their own `--` comment, which stays). Delete the blank line; keep the
        comment.
  - [ ] **`lake build Bimodal.<Module>` after each file**, not just at phase end — the user
        instruction is explicit about this, because the edit touches proof bodies.
  - [ ] Full `lake build` at phase end. Commit this phase as a single commit so it can be reverted
        wholesale.
- **Timing:** 1.5 hours
- **Depends on:** 9
- **Files to modify:** `Theorems/ModalS5.lean`, `Theorems/Propositional/Core.lean`,
  `Theorems/Propositional/Connectives.lean` — blank lines removed inside tactic blocks
- **Verification:**
  - Each of the 3 files reports 0 `emptyLine`
  - `lake build` at 0 errors; still exactly 12 `declaration uses`
  - The diff contains only line deletions (no line content changed)

---

### Phase 11: emptyLine deletion — group B (remaining heavy T1 files) [NOT STARTED]

- **Goal:** Delete the 207 blank lines in the next four T1 files.
- **Tasks:**
  - [ ] Re-derive positions per file before editing.
  - [ ] `Theorems/Perpetuity/Bridge.lean` — 57 deletions
  - [ ] `ProofSystem/Axioms.lean` — 52 deletions
  - [ ] `Theorems/ModalS4.lean` — 50 deletions
  - [ ] `Theorems/Combinators.lean` — 48 deletions
  - [ ] `ProofSystem/Axioms.lean` sits low in the import graph — expect its scoped build to
        cascade. Use `lake build Bimodal.ProofSystem.Axioms` for the per-file gate and accept the
        longer wall time.
  - [ ] `lake build Bimodal.<Module>` after each file. Full `lake build` at phase end. Single
        commit.
- **Timing:** 1.5 hours
- **Depends on:** 10
- **Files to modify:** `Theorems/Perpetuity/Bridge.lean`, `ProofSystem/Axioms.lean`,
  `Theorems/ModalS4.lean`, `Theorems/Combinators.lean` — blank lines removed
- **Verification:**
  - Each of the 4 files reports 0 `emptyLine`
  - `lake build` at 0 errors; still exactly 12 `declaration uses`
  - The diff contains only line deletions

---

### Phase 12: emptyLine deletion — group C (T1 remainder and all of T2) [NOT STARTED]

- **Goal:** Delete the last 86 blank lines, closing out the category at 0 across all 67 files.
- **Tasks:**
  - [ ] Re-derive positions per file before editing.
  - [ ] T1 remainder (67 deletions, 4 files):
    - [ ] `Theorems/Perpetuity/Principles.lean` — 41
    - [ ] `Theorems/Propositional/Reasoning.lean` — 15
    - [ ] `ProofSystem/Derivation.lean` — 6
    - [ ] `Semantics/Truth.lean` — 5
  - [ ] T2 (19 deletions, 4 files) — same settled full-conformance decision, extended to Tier 2
        for category consistency:
    - [ ] `Metalogic/Core/DeductionTheorem.lean` — 8
    - [ ] `Metalogic/SoundnessLemmas/Core.lean` — 5
    - [ ] `Metalogic/Decidability/ProofExtraction.lean` — 4
    - [ ] `Metalogic/Soundness.lean` — 2
  - [ ] Note: `Semantics/Truth.lean` (5) is absent from the research report's per-file table; it
        was found during planning. Its 5 deletions are what make the T1 total 489 rather than 484.
  - [ ] `lake build Bimodal.<Module>` after each file. Full `lake build` at phase end. Single
        commit.
- **Timing:** 1.25 hours
- **Depends on:** 11
- **Files to modify:** the 8 files listed above — blank lines removed
- **Verification:**
  - Full T1+T2 sweep reports 0 `emptyLine` (down from 508)
  - `lake build` at 0 errors; still exactly 12 `declaration uses`
  - The diff contains only line deletions

---

### Phase 13: Final verification and residual inventory [NOT STARTED]

- **Goal:** Prove the in-scope diagnostic count reached 0, prove nothing regressed, and hand a
  clean, honest residual inventory to tasks 292 and 394.
- **Tasks:**
  - [ ] Re-run the full style sweep over all 67 files into
        `specs/293_audit_and_fix_mathlib_linter_compliance/baseline/style-after.log` and diff the
        per-linter totals against `style-before.log`.
  - [ ] Confirm each in-scope category is 0: `emptyLine`, `longLine`, `unusedSimpArgs`,
        `unusedVariables`, `docString`, `whitespace`, `maxHeartbeats`.
  - [ ] Confirm the deliberately out-of-scope categories are **unchanged**, not accidentally
        modified: `flexible` 78, `show` 10, `nativeDecide` 4, `defProp` 3, `multiGoal` 2,
        `unusedTactic` 2, `openClassical` 1. A drop here means a phase exceeded scope.
  - [ ] Re-run `lake exe runLinter Bimodal` into `runlinter-after.log`. Confirm `docBlame` in
        scope is 0 and that `defsWithUnderscore` in scope is **still 239** (189 T1 + 50 T2) — any
        change means a rename leaked in from task 394's territory.
  - [ ] Re-run `lake build > build-after.log 2>&1`. Confirm 0 errors and exactly 12 `declaration
        uses` lines at the same 12 T3 locations as `build-before.log`
        (`Metalogic/Bundle/SuccRelation.lean` ×7, `Metalogic/Bundle/SuccExistence.lean` ×3,
        `Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` ×1,
        `Metalogic/WeakCanonical/Transfer.lean` ×1).
  - [ ] Confirm the 554 deprecation warnings are unchanged (they were all outside scope; a change
        means something drifted).
  - [ ] Write the residual inventory into the implementation summary: the exact out-of-scope
        counts remaining in the 67 files, so task 394 (naming) and any follow-up
        (`flexible`/`simpNF`/`unusedArguments`) start from measured numbers rather than
        re-deriving them.
  - [ ] Note for task 292: `linter.style.header` reports 0 hits in this repo because
        `isInLibraryRoot` looks for `./Bimodal.lean` while `srcDir := "Theories"` places it at
        `Theories/Bimodal.lean`. The header linter will not verify 292's work until that
        mismatch is addressed.
- **Timing:** 1 hour
- **Depends on:** 12
- **Files to modify:**
  - `specs/293_audit_and_fix_mathlib_linter_compliance/baseline/{style,runlinter,build}-after.log`
  - `specs/293_audit_and_fix_mathlib_linter_compliance/summaries/01_mechanical-linter-compliance-summary.md`
- **Verification:**
  - In-scope diagnostics: 1,022 → 0
  - Out-of-scope diagnostics: unchanged, itemized
  - `lake build`: 0 errors, 12 sorries, same locations
  - `defsWithUnderscore` in scope: still 239

## Testing & Validation

- [ ] `lake build` exits 0 at the end of every phase
- [ ] Sorry count stays at exactly 12, at the same 4 files / 12 lines, throughout
- [ ] Per touched file: `lake env lean -Dlinter.mathlibStandardSet=true <file>` reports 0 for the
      category that phase owned
- [ ] `lake exe runLinter Bimodal` shows `docBlame` in scope at 0 and `defsWithUnderscore` in
      scope still at 239
- [ ] Out-of-scope linter counts (`flexible` 78, `show` 10, `nativeDecide` 4, `defProp` 3,
      `multiGoal` 2, `unusedTactic` 2, `openClassical` 1) are identical before and after
- [ ] The 554 deprecation warnings are identical before and after
- [ ] No file under `Theories/Bimodal/Boneyard/`, `Theories/Bimodal/Automation/`, or T3
      `Metalogic/` appears in any phase's diff
- [ ] No copyright header is added or modified (task 292's territory)
- [ ] `git diff --stat` for Phases 10-12 shows deletions only

## Artifacts & Outputs

- `specs/293_audit_and_fix_mathlib_linter_compliance/plans/01_mechanical-linter-compliance.md` (this file)
- `specs/293_audit_and_fix_mathlib_linter_compliance/baseline/{t1,t2,scope}.txt` — in-scope file lists
- `specs/293_audit_and_fix_mathlib_linter_compliance/baseline/style-{before,after}.log`
- `specs/293_audit_and_fix_mathlib_linter_compliance/baseline/runlinter-{before,after}.log`
- `specs/293_audit_and_fix_mathlib_linter_compliance/baseline/build-{before,after}.log`
- `specs/293_audit_and_fix_mathlib_linter_compliance/summaries/01_mechanical-linter-compliance-summary.md`
- Modified: ~55 of the 67 in-scope `.lean` files (12 in-scope files have no in-scope diagnostics)

## Rollback/Contingency

- **Per phase**: each phase is one commit (Phases 10-12 strictly so). `git revert <sha>` undoes a
  phase without disturbing its predecessors.
- **The blank-line decision specifically**: Phases 10, 11, and 12 form one logical group. If the
  readability regression proves unacceptable in review, revert those three commits as a unit —
  they are sequenced last precisely so that no later work sits on top of them, and they contain
  only line deletions.
- **A broken proof mid-phase**: fix forward per `.claude/rules/error-handling.md`. For a simp
  argument the linter wrongly called unused, restore it with an explanatory comment and record it
  as a residual — do not force the fix and do not discard uncommitted work to reach a green
  build.
- **A phase step that cannot be executed as written**: per `.claude/rules/plan-compliance.md`
  (which governs `**/*.lean`), mark the phase `[BLOCKED]`, state what was tried and the goal state
  reached, and escalate. Do not substitute a different approach or silently annotate past it.
- **Full abandonment**: every change in this plan is comment, whitespace, or simp-argument level.
  Reverting all phase commits restores the tree exactly; `baseline/*.log` documents the starting
  state for a fresh attempt.
