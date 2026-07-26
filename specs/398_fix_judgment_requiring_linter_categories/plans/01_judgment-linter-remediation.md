# Implementation Plan: Judgment-Requiring Linter Category Remediation

- **Task**: 398 - fix_judgment_requiring_linter_categories
- **Status**: [IMPLEMENTING]
- **Effort**: 10 hours
- **Dependencies**: None
- **Research Inputs**: `specs/398_fix_judgment_requiring_linter_categories/reports/01_judgment-linter-categories-inventory.md`
- **Artifacts**: plans/01_judgment-linter-remediation.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Remediate the judgment-requiring linter categories across the 67 in-scope T1+T2 Lean files:
`linter.flexible` (41 known distinct sites, a lower bound), `linter.style.show` (10),
`linter.style.nativeDecide` (4), `linter.unusedTactic` (2), `linter.style.multiGoal` (2),
`linter.style.openClassical` (1), and the single genuine `simpNF` finding. Work is organized
**by file**, not by category, because the `linter.flexible` inventory is dynamic: fixing a site
unmasks downstream ones, so a file is only done when it re-lints to a fixpoint. Two categories —
all 10 `unusedArguments` and 41 of the 42 `simpNF` findings — are settled as **accepted
residuals** with recorded root causes and are explicitly not edited.

Definition of done: every in-scope file reaches a `linter.flexible`/`style.show`/`nativeDecide`/
`unusedTactic`/`multiGoal`/`openClassical` fixpoint of zero, `lake build` reports 0 errors and
exactly 1 live sorry at `Theories/Bimodal/Metalogic/WeakCanonical/Transfer.lean:1227`, no new
`linter.style.longLine` warnings anywhere, and the 51 accepted residuals are documented with
their root causes.

### Research Integration

The report drives this plan directly:

- **Corrected baseline** (report §0): `lake build` green at 1875 jobs, 0 errors, **exactly 1**
  live sorry at `Transfer.lean:1227`. The task description's "12 sorry warnings" invariant is
  stale and is not used anywhere in this plan.
- **Corrected site counts** (report §2.1): the stale figures counted raw warning emissions.
  `linter.flexible` is **41 distinct source sites, not 78** — `ProofSystem/Axioms.lean:392:40`
  alone emits 9 warnings from one `simp [LE.le]` inside a `cases a <;> cases b` chain. Total
  in-scope work: 70 distinct sites across 16 files, ~29 real edits.
- **Verbatim replacement strings** (report §3.4) for 21 validated sites — all 9 T1 flexible
  sites, all 8 `Saturation.lean` suggestions, and all 10 `Core/DeductionTheorem.lean` sites —
  are transcribed into the phases below. Methodology success rate: **21/21**.
- **Unmasking hazard** (report §3.2) and **longLine regression hazard** (report §3.3) are both
  budgeted for explicitly (see Risks, and the per-phase fixpoint loop).
- **Root causes** for both residual categories (report §4.2, §5.3) are recorded verbatim in
  Phase 9.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No ROADMAP.md consulted for this task.

## Goals & Non-Goals

**Goals**:
- Drive `linter.flexible` to a per-file fixpoint of zero across all 67 in-scope T1+T2 files.
- Eliminate all `linter.style.show` (10), `linter.style.nativeDecide` (4),
  `linter.unusedTactic` (2), `linter.style.multiGoal` (2), and `linter.style.openClassical` (1)
  findings in scope.
- Fix the one genuine `simpNF` finding (`Derivable.ax`) under a full-build gate.
- Preserve the build invariant after **every file**: 0 errors, exactly 1 live sorry at
  `Transfer.lean:1227`.
- Introduce **zero** new `linter.style.longLine` warnings.
- Document 51 accepted residuals (41 `simpNF LINTER FAILED` + 10 `unusedArguments`) with root
  causes.

**Non-Goals**:
- **Do not touch the 10 `unusedArguments`.** Every one is an unused *typeclass instance*
  (`[LinearTemporalFrame D]` on `soundness_linear`, `[DenseTemporalFrame D]` on
  `soundness_dense`, `[DiscreteTemporalFrame D]` on `soundness_discrete`, and
  `[IsPredArchimedean D]`/`[IsSuccArchimedean D]`/`[Nontrivial D]` on the `FrameClassVariants`
  Prior-UZ/SZ lemmas). Those instances **are** the frame-class index; removing them collapses
  three distinct declarations into a single `Metalogic.soundness` and destroys the stratified
  API. Record as accepted residuals. Do not add `@[nolint unusedArguments]` either — that is a
  separate user-visible API decision.
- **Do not chase the 41 `simpNF LINTER FAILED` findings.** Root cause is a single looping
  `@[simp]` lemma, `neg_unfold` at `Theories/Bimodal/Automation/Normalization.lean:69`, whose
  RHS (`φ.imp bot`) is definitionally its own LHS pattern (`Formula.neg`,
  `Theories/Bimodal/Syntax/Formula.lean:121`). `lake exe runLinter Bimodal` imports the whole
  library, so this poisons simp for every `Formula`-valued LHS. `Automation/` is out of scope.
- All naming work, including `defsWithUnderscore` (189 T1 + 50 T2) and the 3 `linter.defProp`
  def-to-theorem conversions.
- Tier-3 `Metalogic/` bulk compliance.
- The 32 `push_neg` deprecation warnings in T2 (owned by the deprecation task).
- `Boneyard/` (unbuilt, inert) and `Automation/`.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| **Unmasking**: the linter reports only the FIRST flexible tactic in a dependent chain, so fixing inventoried sites reveals new ones. Measured: fixing `DeductionTheorem.lean`'s 9 sites created a new warning at `152:6`. **41 is a lower bound.** | H | Certain | Per-file iteration to a fixpoint is mandatory. A phase is NOT done when the listed sites are fixed — only when the file re-lints with zero `linter.flexible`. Budget +10-15% sites per file. Cap at 5 iterations; if not converging, record a residual and stop. |
| **longLine regression**: transcribing `simp?` suggestions verbatim reintroduced 5 `linter.style.longLine` warnings into a file a predecessor had taken to zero. | M | Certain | Line wrapping is part of each edit, never a cleanup pass. After transcribing, immediately check the line is ≤ 100 chars at its indentation; if not, break the lemma list at a comma with the continuation indented +2. `fix_long_lines.py` is not reliable here — verify per file. |
| A linter suggestion breaks a proof. | M | L (0/21 observed) | Restore the original tactic verbatim, record an accepted residual with the reason. **Never force a fix.** |
| Changing proof shape breaks a downstream file that imports the edited one. | H | L | `lake build` after **every file**, not just at phase end. Invariant: 0 errors, exactly 1 live sorry at `Transfer.lean:1227`. |
| `Derivable.ax` simpNF edit invalidates a library-wide rebuild (~1875 jobs) and was never empirically verified. | H | L | Serialize Phase 8 alone. Full `lake build` gate. Revert and record as residual on any breakage. |
| A "file must be silent" verification gate fails spuriously on the 32 out-of-scope `push_neg` deprecations in T2. | M | Certain if mis-specified | The gate is **"no NEW warnings and zero in-scope categories"**, NOT "file is silent". Enforced mechanically by the category-count diff established in Phase 1. |
| Parallel `lake build` invocations contend on the lake lockfile. | L | M | Phases 2-7 are territory-disjoint but must serialize their `lake build` steps; default to sequential execution unless separate git worktrees are used. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 3, 4, 5, 6, 7 | 1 |
| 3 | 8 | 2, 3, 4, 5, 6, 7 |
| 4 | 9 | 8 |

Phases within the same wave can execute in parallel. Wave 2 phases own disjoint file sets
(territory is assigned by file, not by category), but their `lake build` verification steps must
be serialized because `lake` takes a repo-wide lock. Default to sequential execution of wave 2.

---

### Reference: shared procedure used by every editing phase

Build targets are `Bimodal.*`, **not** `Theories.Bimodal.*` (`srcDir := "Theories"`,
`roots := #[`Bimodal]`).

**Working linter invocations**:
```bash
lake exe runLinter Bimodal                                    # declaration linters
lake env lean -Dlinter.mathlibStandardSet=true <file.lean>     # style/syntax linters
# set_option linter.all true                                   # core Lean set (in-file)
```

**Per-file loop** (report §3.1, validated end to end):

1. Replace each flagged `simp…` with `simp?…` (regex: first `\bsimp\b` on the line — this
   handles `simp`, `simp at h`, `simp [X] at h`, `simp at h ⊢` uniformly).
2. `lake env lean <file>` → collect the `Try this: simp only [...]` suggestions. Suggestions are
   emitted **in source order**, one per flagged position; a position re-elaborated N times (the
   `<;> cases` case) emits N *identical* suggestions.
3. Transcribe each suggestion back, preserving whatever followed the tactic on the line
   (`; exact hnd`, etc.). Transcribe **verbatim** — including bare `simp only at h` forms with an
   empty lemma list. Do not "improve" them into `simp only []` and do not delete them; they
   perform beta/eta/structural reduction and are what `simp?` actually suggests.
4. **Wrap any resulting line over 100 characters as part of this edit** — break the lemma list at
   a comma, continuation indented +2.
5. `lake env lean -Dlinter.mathlibStandardSet=true <file>` → must show 0 errors and 0
   `linter.flexible`.
6. **Repeat from step 1 until fixpoint.** New sites appearing is expected, not an error.
7. `lake build` → 0 errors, exactly 1 live sorry at `Transfer.lean:1227`.

**Per-file verification gate** (the *differential* gate — this is the correct criterion):

```bash
# after editing <file>:
lake env lean -Dlinter.mathlibStandardSet=true <file> 2>&1 \
  | grep -oE 'linter\.[a-zA-Z.]+' | sort | uniq -c > /tmp/task398/after/<key>.txt
diff /tmp/task398/baseline/<key>.txt /tmp/task398/after/<key>.txt
```

Pass conditions:
- Every targeted in-scope category (`linter.flexible`, `linter.style.show`,
  `linter.style.nativeDecide`, `linter.unusedTactic`, `linter.style.multiGoal`,
  `linter.style.openClassical`) is **absent** from the "after" counts.
- **No** category count increased relative to baseline. In particular
  `linter.style.longLine` must not increase.
- Deprecation-warning count did not increase (the 32 out-of-scope `push_neg` deprecations in T2
  will still be present — that is expected and is not a failure).

**If a suggestion breaks a proof**: restore the original tactic verbatim, note the site and the
failure reason for the Phase 9 residual ledger, and move on. Never force a fix.

**Commit granularity**: one commit per file that reaches green, message
`task 398 phase {P}.{O}: {file basename} linter fixpoint`.

---

### Phase 1: Baseline capture and differential-gate harness [COMPLETED]

- **Goal:** Establish the reproducible pre-state that every later phase diffs against, and
  confirm the corrected build invariant.
- **Tasks:**
  - [x] Run `lake build`; confirm 0 errors (expect ~1875 jobs).
  - [x] Run the sorry census and confirm **exactly one** live sorry:
        `grep -rnE '^\s*sorry\s*$|:= *sorry|by sorry' --include=*.lean Theories/ Tests/ | grep -v Boneyard`
        → must yield only `Theories/Bimodal/Metalogic/WeakCanonical/Transfer.lean:1227`.
  - [x] Build the in-scope file list (67 files) into `/tmp/task398/scope.txt`:
        ```bash
        mkdir -p /tmp/task398/baseline /tmp/task398/after
        find Theories/Bimodal/{Syntax,Semantics,ProofSystem,Theorems,FrameConditions} -name '*.lean' \
          | grep -v Boneyard > /tmp/task398/scope.txt
        find Theories/Bimodal/Metalogic/{Core,SoundnessLemmas,Decidability,WeakCanonical/Separation} \
          -name '*.lean' | grep -v Boneyard >> /tmp/task398/scope.txt
        printf '%s\n' Theories/Bimodal/Metalogic/{Soundness,Completeness,Decidability,Metalogic}.lean \
          >> /tmp/task398/scope.txt
        wc -l /tmp/task398/scope.txt   # expect 67
        ```
  - [x] Capture per-file baseline linter category counts (line-number-independent, so it stays
        valid after edits shift lines):
        ```bash
        while read -r f; do
          key=$(echo "$f" | tr / _)
          lake env lean -Dlinter.mathlibStandardSet=true "$f" 2>&1 \
            | grep -oE 'linter\.[a-zA-Z.]+' | sort | uniq -c > "/tmp/task398/baseline/$key.txt"
        done < /tmp/task398/scope.txt
        ```
  - [x] Also capture baseline deprecation counts per file (`grep -c 'deprecated'`) into the same
        baseline directory with a `.deprecated` suffix.
  - [x] Run `lake exe runLinter Bimodal > /tmp/task398/baseline/runLinter.txt` and confirm the
        declaration-linter pre-state: 10 `unusedArguments`, 42 `simpNF` (41 `LINTER FAILED`, 1
        genuine at `Derivable.ax`).
  - [x] Sanity-check the aggregate: 41 distinct `linter.flexible` sites, 10 `style.show`, 4
        `nativeDecide`, 2 `unusedTactic`, 2 `multiGoal`, 1 `openClassical`.
- **Timing:** 0.5 hours
- **Depends on:** none
- **Files to modify:** none (read-only; writes only to `/tmp/task398/`)
- **Verification:**
  - `/tmp/task398/scope.txt` has 67 lines.
  - `/tmp/task398/baseline/` has 67 category-count files.
  - Build invariant confirmed: 0 errors, exactly 1 sorry at `Transfer.lean:1227`.

---

### Phase 2: T1 sweep — `style.show` + all 9 T1 `linter.flexible` sites [COMPLETED]

- **Goal:** Take the eight T1 files carrying flexible/show findings to a fixpoint. Every
  replacement string here is **verified verbatim** (report §3.4) — this phase is transcription,
  not discovery.
- **Tasks:**
  - [x] `Theories/Bimodal/Syntax/Atom.lean:92` — `show T` → `change T` (validated: 0 errors, 0
        residual `style.show`).
  - [x] `Theories/Bimodal/ProofSystem/Axioms.lean:392:40` — `simp [LE.le]` →
        `simp only [LE.le]`. **Note**: this single site is the source of 9 raw warnings via the
        surrounding `cases a <;> cases b` chain. One edit clears all 9.
  - [x] `Theories/Bimodal/Semantics/TaskFrame.lean:265:25` — `simp at hnd` →
        `simp only [ne_eq, neg_eq_zero] at hnd`
  - [x] `Theories/Bimodal/Semantics/WorldHistory.lean:419:4` — `simp at this` →
        `simp only [neg_neg] at this`
  - [x] `Theories/Bimodal/Theorems/GeneralizedNecessitation.lean:80:22` — `simp` →
        `simp only [List.mem_cons]`
  - [x] `Theories/Bimodal/Theorems/Perpetuity/Principles.lean:639:4` — `simp at hx ⊢` →
        `simp only [List.mem_cons, List.not_mem_nil, or_false] at hx ⊢`
  - [x] `Theories/Bimodal/Theorems/Propositional/Connectives.lean:253:19` and `:273:19` — `simp` →
        `simp only [List.mem_cons, List.not_mem_nil, or_false]` (both sites, same replacement)
  - [x] `Theories/Bimodal/Theorems/Propositional/Reasoning.lean:166:54` and `:169:54` — `simp` →
        `simp only [List.mem_cons]` (both sites)
  - [x] Run the fixpoint loop on each file (unmasking is possible even here).
  - [x] Wrap any line pushed over 100 chars.
  - [x] `lake build` after each file.
- **Timing:** 1.5 hours
- **Depends on:** 1
- **Files to modify:**
  - `Theories/Bimodal/Syntax/Atom.lean` — `show` → `change`
  - `Theories/Bimodal/ProofSystem/Axioms.lean` — 1 flexible site
  - `Theories/Bimodal/Semantics/TaskFrame.lean` — 1 flexible site
  - `Theories/Bimodal/Semantics/WorldHistory.lean` — 1 flexible site
  - `Theories/Bimodal/Theorems/GeneralizedNecessitation.lean` — 1 flexible site
  - `Theories/Bimodal/Theorems/Perpetuity/Principles.lean` — 1 flexible site
  - `Theories/Bimodal/Theorems/Propositional/Connectives.lean` — 2 flexible sites
  - `Theories/Bimodal/Theorems/Propositional/Reasoning.lean` — 2 flexible sites
- **Verification:**
  - Differential gate passes on all 8 files.
  - `lake build`: 0 errors, exactly 1 sorry at `Transfer.lean:1227`.

---

### Phase 3: `Metalogic/Core/DeductionTheorem.lean` — all four categories to fixpoint [IN PROGRESS]

- **Goal:** Take the single file carrying four distinct categories fully clean. Validated end to
  end in research: reached 0 warnings, 0 errors in two iterations.
- **Tasks:**
  - [ ] Delete `open Classical` at line 53. The following line
        `attribute [local instance] Classical.propDecidable` is what actually does the work.
        (Clears `linter.style.openClassical`.)
  - [ ] Delete the `simp_wf` line at `:287` and at `:420` — both inside `decreasing_by` blocks
        followed by focused `·` bullets. **Two line deletions clear four findings**: the 2
        `linter.unusedTactic` and 2 `linter.style.multiGoal` reports are the same two no-ops seen
        from different angles.
  - [ ] Apply the 10 verified flexible replacements. Let `BIG` denote
        `simp only [ne_eq, decide_not, List.mem_filter, Bool.not_eq_eq_eq_not, Bool.not_true, decide_eq_false_iff_not]`:
        - `:115` → `BIG at hx`
        - `:118` → `simp only [List.mem_cons] at this`
        - `:136` → `simp only [List.mem_cons] at h`
        - `:143` → `BIG at h_in`
        - `:149` → `simp only [List.mem_cons]`
        - `:152` → `BIG` — **this site does not exist in the baseline scan.** It is unmasked by
          fixing the sites above. Expect it; do not treat it as an error.
        - `:238` → `BIG`
        - `:261` → `BIG at hx ⊢`
        - `:268` → `BIG`
        - `:402` → `simp only [List.mem_cons] at this`
  - [ ] **Wrap every `BIG` occurrence.** Verbatim it is 114 chars at the `:115` indentation.
        Applying all nine unwrapped introduced **five** new `linter.style.longLine` warnings in
        research. Break the lemma list across two lines, continuation indented +2.
  - [ ] Re-run the fixpoint loop until zero `linter.flexible` (expect exactly 2 iterations).
  - [ ] `lake build`.
- **Timing:** 1 hour
- **Depends on:** 1
- **Files to modify:**
  - `Theories/Bimodal/Metalogic/Core/DeductionTheorem.lean` — 10 flexible edits (9 inventoried +
    1 unmasked), 2 `simp_wf` deletions, 1 `open Classical` deletion, line wrapping
- **Verification:**
  - Differential gate: zero `linter.flexible`, `unusedTactic`, `multiGoal`, `openClassical`; no
    increase in `linter.style.longLine`.
  - `lake build`: 0 errors, exactly 1 sorry at `Transfer.lean:1227`.

---

### Phase 4: `Metalogic/Decidability/` mechanical + `Saturation.lean` flexible [NOT STARTED]

- **Goal:** Clear the validated-mechanical Decidability findings and apply the 8 pre-obtained
  `Saturation.lean` suggestions.
- **Tasks:**
  - [ ] `Metalogic/Decidability/SignedFormula.lean` `:132 :138 :139 :144` — `native_decide` →
        `decide` (all 4; validated 0 errors, 0 residual). All four decide propositions over
        `Sign`, a 2-constructor inductive, so `decide` is trivially sufficient. This also removes
        the Lean *compiler* from the trust base of `LawfulBEq Sign` / `ReflBEq Sign` — a
        correctness improvement, not only a style one.
  - [ ] `Metalogic/Decidability/Propositional/Decidable.lean` — 1 `show T` → `change T`.
  - [ ] `Metalogic/Decidability/Propositional/PropForm.lean` — 1 `show T` → `change T`.
  - [ ] `Metalogic/Decidability/Saturation.lean` — apply the 8 obtained suggestions (report §3.4;
        obtained but **not yet applied or verified** — run the full loop):
        - `:1021` → `simp only [SignedFormula.neg, List.mem_cons, List.not_mem_nil, or_false] at h_mem`
        - `:1110` → `simp only at h_result`
        - `:1121` → `simp only [Option.some.injEq, Sum.inr.injEq] at h_result`
        - `:1124` → `simp only at h_result`
        - `:1203` → `simp only [hfc] at h`
        - `:1213` → `simp only [hexp, Option.some.injEq, Sum.inr.injEq, Prod.mk.injEq] at h`
        - `:1215` → `simp only [hexp] at h`
        - `:1219` → `simp only [hexp] at h`
        Transcribe the two bare `simp only at h_result` forms verbatim — the empty lemma list is
        intentional.
  - [ ] Fixpoint loop on `Saturation.lean`; wrap long lines.
  - [ ] `lake build` after each file.
- **Timing:** 1.5 hours
- **Depends on:** 1
- **Files to modify:**
  - `Theories/Bimodal/Metalogic/Decidability/SignedFormula.lean` — 4 `native_decide` → `decide`
  - `Theories/Bimodal/Metalogic/Decidability/Propositional/Decidable.lean` — 1 `show` → `change`
  - `Theories/Bimodal/Metalogic/Decidability/Propositional/PropForm.lean` — 1 `show` → `change`
  - `Theories/Bimodal/Metalogic/Decidability/Saturation.lean` — 8 flexible sites + unmasked
- **Verification:**
  - Differential gate passes on all 4 files.
  - `lake build`: 0 errors, exactly 1 sorry at `Transfer.lean:1227`.

---

### Phase 5: `Metalogic/Decidability/` remaining flexible — CountermodelExtraction + Filtration [NOT STARTED]

- **Goal:** Clear the 8 flexible sites in the two Decidability files with no pre-obtained
  suggestions. This phase runs the discovery loop from scratch.
- **Tasks:**
  - [ ] `Metalogic/Decidability/CountermodelExtraction.lean` — run the §3.1 loop over 4 sites:
        `:373:4` (`simp [hb] at hOpen`), `:448:2` (`simp [Bool.not_eq_true] at h`), `:931:4`
        (`simp [extractSemanticCountermodel] at hw'`), `:989:16`
        (`simp [extractSemanticCountermodel]`).
  - [ ] `Metalogic/Decidability/FMP/Filtration.lean` — run the loop over 4 sites: `:205:6`
        (`simp at h`), `:214:6`, `:228:8` (`simp at h1`), `:231:6` (`simp [hy0] at h_uv`).
  - [ ] Iterate each file to fixpoint; wrap long lines as part of each edit.
  - [ ] Note: `CountermodelExtraction.lean` carries 3 out-of-scope `push_neg` deprecations. They
        will still appear in the lint output. That is expected — the gate is differential.
  - [ ] `lake build` after each file.
- **Timing:** 1.5 hours
- **Depends on:** 1
- **Files to modify:**
  - `Theories/Bimodal/Metalogic/Decidability/CountermodelExtraction.lean` — 4 flexible sites
  - `Theories/Bimodal/Metalogic/Decidability/FMP/Filtration.lean` — 4 flexible sites
- **Verification:**
  - Differential gate passes on both files; deprecation counts unchanged.
  - `lake build`: 0 errors, exactly 1 sorry at `Transfer.lean:1227`.

---

### Phase 6: `Metalogic/Core/` remaining flexible — MaximalConsistent + RestrictedMCS [NOT STARTED]

- **Goal:** Clear the 3 remaining Core flexible sites.
- **Tasks:**
  - [ ] `Metalogic/Core/MaximalConsistent.lean:512:4` — `simp [Set.mem_insert_iff] at h_L_sub`;
        run the loop.
  - [ ] `Metalogic/Core/RestrictedMCS/Basic.lean:175:6` — `simp [Set.mem_insert_iff] at h_L_sub`.
  - [ ] `Metalogic/Core/RestrictedMCS/Basic.lean:220:6` —
        `simp [Set.mem_insert_iff] at h_L'_sub`.
  - [ ] Iterate to fixpoint; wrap long lines.
  - [ ] Note: `RestrictedMCS/Basic.lean` carries 4 and `MaximalConsistent.lean` 2 out-of-scope
        `push_neg` deprecations; leave them.
  - [ ] `lake build` after each file.
- **Timing:** 0.75 hours
- **Depends on:** 1
- **Files to modify:**
  - `Theories/Bimodal/Metalogic/Core/MaximalConsistent.lean` — 1 flexible site
  - `Theories/Bimodal/Metalogic/Core/RestrictedMCS/Basic.lean` — 2 flexible sites
- **Verification:**
  - Differential gate passes on both files; deprecation counts unchanged.
  - `lake build`: 0 errors, exactly 1 sorry at `Transfer.lean:1227`.

---

### Phase 7: `Metalogic/SoundnessLemmas/FrameClassVariants.lean` — `show` + flexible [NOT STARTED]

- **Goal:** Take the densest single file (7 `style.show` + 4 `linter.flexible`) to a fixpoint,
  while leaving its 4 `unusedArguments` untouched.
- **Tasks:**
  - [ ] Convert the 7 `show T` → `change T` at `:802 :839 :864 :891 :914 :917 :920` (validated in
        research: 0 errors, 0 residual `style.show`). The Mathlib linter
        (`Mathlib/Tactic/Linter/Style.lean:635-657`) fires exactly when `show` changed the goal
        type, and its own message names `change` as the intended replacement.
  - [ ] Run the §3.1 loop over the 4 flexible sites at `:722:4 :741:6 :762:4 :780:6` (all bare
        `simp` on the goal).
  - [ ] Iterate to fixpoint; wrap long lines.
  - [ ] **Do NOT touch** the 4 `unusedArguments` at `:711 :752 :791 :853`
        (`[IsPredArchimedean D]` / `[IsSuccArchimedean D]` / `[Nontrivial D]`). They document the
        discrete-order setting of Prior-UZ/SZ and are accepted residuals.
  - [ ] Note: 2 out-of-scope `push_neg` deprecations remain in this file.
  - [ ] `lake build`.
- **Timing:** 1.25 hours
- **Depends on:** 1
- **Files to modify:**
  - `Theories/Bimodal/Metalogic/SoundnessLemmas/FrameClassVariants.lean` — 7 `show` → `change`,
    4 flexible sites
- **Verification:**
  - Differential gate: zero `linter.flexible` and `linter.style.show`; `unusedArguments` count
    unchanged (4); deprecation count unchanged (2).
  - `lake build`: 0 errors, exactly 1 sorry at `Transfer.lean:1227`.

---

### Phase 8: The one genuine `simpNF` — `Derivable.ax` [NOT STARTED]

- **Goal:** Remove a simp lemma that provably can never fire. **Serialized alone** — this file is
  imported library-wide and the edit forces a full ~1875-job rebuild.
- **Tasks:**
  - [ ] At `Theories/Bimodal/ProofSystem/Derivable.lean:117`, change the attribute list on
        `Derivable.ax` from `@[aesop safe apply, simp]` to `@[aesop safe apply]`.
        Rationale: `h : Axiom p` occurs only in `h_fc`'s type and never in the conclusion
        `Derivable fc G p`, so `simp` can never instantiate it — the lemma is dead weight in the
        simp set and per the linter "will never apply".
  - [ ] Run a **full** `lake build`. This is the mandatory gate.
  - [ ] Run `lake exe runLinter Bimodal` and confirm the genuine `simpNF` finding is gone and the
        `simpNF` total dropped from 42 to 41 (all remaining are `LINTER FAILED`).
  - [ ] **Contingency**: this edit was NOT empirically verified in research (the repo was
        deliberately not mutated). If the build breaks anywhere, revert the attribute change and
        record `Derivable.ax` as an accepted residual with the observed breakage, then proceed to
        Phase 9. Do not attempt to repair downstream proofs to accommodate it.
- **Timing:** 0.75 hours
- **Depends on:** 2, 3, 4, 5, 6, 7
- **Files to modify:**
  - `Theories/Bimodal/ProofSystem/Derivable.lean` — drop `simp` from the `Derivable.ax` attribute
    list
- **Verification:**
  - `lake build`: 0 errors, exactly 1 sorry at `Transfer.lean:1227`.
  - `lake exe runLinter Bimodal`: `simpNF` count 42 → 41; `unusedArguments` still 10.

---

### Phase 9: Final full verification and accepted-residuals ledger [NOT STARTED]

- **Goal:** Prove the end state globally and record the 51 accepted residuals with their root
  causes so no successor re-derives them.
- **Tasks:**
  - [ ] Re-run the full Mechanism-A sweep over all 67 in-scope files and diff every file against
        its Phase-1 baseline:
        ```bash
        while read -r f; do
          key=$(echo "$f" | tr / _)
          lake env lean -Dlinter.mathlibStandardSet=true "$f" 2>&1 \
            | grep -oE 'linter\.[a-zA-Z.]+' | sort | uniq -c > "/tmp/task398/after/$key.txt"
          diff -u "/tmp/task398/baseline/$key.txt" "/tmp/task398/after/$key.txt"
        done < /tmp/task398/scope.txt
        ```
        Assert: zero `linter.flexible`, `linter.style.show`, `linter.style.nativeDecide`,
        `linter.unusedTactic`, `linter.style.multiGoal`, `linter.style.openClassical` across all
        67 files; **no** category count increased anywhere (`linter.style.longLine` in
        particular).
  - [ ] Final `lake build`: 0 errors, exactly 1 live sorry at `Transfer.lean:1227`.
  - [ ] Final `lake exe runLinter Bimodal`.
  - [ ] Write the **Accepted Residuals** section into
        `specs/398_fix_judgment_requiring_linter_categories/summaries/01_judgment-linter-remediation-summary.md`,
        containing:
        - **41 `simpNF LINTER FAILED`** — every one has the same body ("Tactic `simp` failed with
          a nested error: maximum recursion depth has been reached"). Root cause: `neg_unfold` at
          `Theories/Bimodal/Automation/Normalization.lean:69`
          (`@[simp] theorem neg_unfold (φ : Formula) : φ.neg = φ.imp bot := rfl`) whose RHS is
          definitionally its own LHS pattern (`Formula.neg`, `Theories/Bimodal/Syntax/Formula.lean:121`),
          so simp loops. This is **not** a `maxRecDepth` setting problem: in isolation these
          declarations are simp-normal at the default depth, and raising the depth to 20000 does
          not help. `lake exe runLinter Bimodal` imports the whole library, so the lemma poisons
          simp for every `Formula`-valued LHS. `Automation/` is out of scope for this task —
          recommend a follow-up Automation-scoped task; do not open it here. Note also that
          removing `@[simp]` from `neg_unfold` would convert these into *real* `simpNF` reports
          that are still artifacts of the same simp set, so the fix is not a simple attribute
          removal.
        - **10 `unusedArguments`** — 6 in `Theories/Bimodal/FrameConditions/Soundness.lean`
          (`:69 :84 :100 :119 :130 :142`) and 4 in
          `Theories/Bimodal/Metalogic/SoundnessLemmas/FrameClassVariants.lean`
          (`:711 :752 :791 :853`). Every one is an unused *typeclass instance* argument that is
          semantically load-bearing as API documentation: the instances **are** the frame-class
          index and are the entire reason `soundness_linear`, `soundness_dense`, and
          `soundness_discrete` are three separate declarations rather than one. Removing them
          collapses all three into `Metalogic.soundness` and destroys the frame-class-stratified
          API. Accepted as residuals by explicit decision; not a linter chore.
        - Any per-site residuals accumulated during Phases 2-8 (a suggestion that broke a proof,
          or a Phase 8 revert), each with its reason.
  - [ ] Record the outcome table: in-scope findings reduced from 70 distinct sites to the
        residual count (expected 51 if no per-site residuals accrued).
  - [ ] Note in the summary that `Theories/Bimodal/FrameConditions/Soundness.lean` is also touched
        by the out-of-scope naming task (`linter.defProp`), so territory between the two tasks is
        assigned by category, not by file.
- **Timing:** 0.75 hours
- **Depends on:** 8
- **Files to modify:**
  - `specs/398_fix_judgment_requiring_linter_categories/summaries/01_judgment-linter-remediation-summary.md`
- **Verification:**
  - Global differential sweep shows zero in-scope categories and no regressions.
  - `lake build`: 0 errors, exactly 1 sorry at `Transfer.lean:1227`.
  - Residuals ledger written with both root causes.

---

## Testing & Validation

- [ ] `lake build` succeeds with 0 errors after **every file edit**, not merely at phase end.
- [ ] Live sorry census yields exactly one result, `Transfer.lean:1227`, at every checkpoint.
- [ ] Across all 67 in-scope files, `lake env lean -Dlinter.mathlibStandardSet=true` reports zero
      `linter.flexible`, `linter.style.show`, `linter.style.nativeDecide`, `linter.unusedTactic`,
      `linter.style.multiGoal`, and `linter.style.openClassical`.
- [ ] No linter category count increased relative to the Phase-1 baseline anywhere — in
      particular `linter.style.longLine`.
- [ ] The 32 out-of-scope `push_neg` deprecations in T2 are still present and unchanged in count
      (their disappearance would indicate out-of-scope edits).
- [ ] `lake exe runLinter Bimodal`: `unusedArguments` still 10 (untouched by design); `simpNF`
      41 (was 42) if Phase 8 landed, or 42 if Phase 8 was reverted.
- [ ] No file under `Automation/` or `Boneyard/` was modified.

## Artifacts & Outputs

- `specs/398_fix_judgment_requiring_linter_categories/plans/01_judgment-linter-remediation.md`
  (this file)
- `specs/398_fix_judgment_requiring_linter_categories/summaries/01_judgment-linter-remediation-summary.md`
  (Phase 9, including the Accepted Residuals ledger)
- Modified Lean sources (19 files):
  `Syntax/Atom.lean`, `ProofSystem/Axioms.lean`, `ProofSystem/Derivable.lean`,
  `Semantics/TaskFrame.lean`, `Semantics/WorldHistory.lean`,
  `Theorems/GeneralizedNecessitation.lean`, `Theorems/Perpetuity/Principles.lean`,
  `Theorems/Propositional/Connectives.lean`, `Theorems/Propositional/Reasoning.lean`,
  `Metalogic/Core/DeductionTheorem.lean`, `Metalogic/Core/MaximalConsistent.lean`,
  `Metalogic/Core/RestrictedMCS/Basic.lean`,
  `Metalogic/Decidability/CountermodelExtraction.lean`,
  `Metalogic/Decidability/FMP/Filtration.lean`, `Metalogic/Decidability/Saturation.lean`,
  `Metalogic/Decidability/SignedFormula.lean`,
  `Metalogic/Decidability/Propositional/Decidable.lean`,
  `Metalogic/Decidability/Propositional/PropForm.lean`,
  `Metalogic/SoundnessLemmas/FrameClassVariants.lean`
  (all under `Theories/Bimodal/`)
- Transient: `/tmp/task398/` baseline and after category-count files (not committed)

## Rollback/Contingency

- Every change is a localized tactic or attribute edit with no semantic content, so rollback is
  per-file: `git checkout HEAD -- <file>` restores it. Commit one file per green milestone so the
  blast radius of any revert is a single file.
- **Per-site contingency**: if a `simp?` suggestion breaks a proof, restore the original tactic
  verbatim and record an accepted residual with the reason. Never force a fix, never restructure
  a proof to accommodate a linter.
- **Non-convergence contingency**: if a file's fixpoint loop has not converged after 5
  iterations, stop, restore that file to its last green state, and record the remaining sites as
  residuals with the iteration trace.
- **Phase 8 contingency**: if dropping `simp` from `Derivable.ax` breaks the library build,
  revert that single-line attribute change and record it as a residual. This is expected to be
  the highest-blast-radius edit in the task and is deliberately isolated in its own phase for
  exactly this reason.
- The working tree must be clean of unrelated changes before starting; do not run destructive git
  operations on a dirty tree (see `.claude/rules/git-workflow.md`).
