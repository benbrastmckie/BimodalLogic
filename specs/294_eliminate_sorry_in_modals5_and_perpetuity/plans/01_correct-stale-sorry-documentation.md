# Implementation Plan: Task #294

- **Task**: 294 - Correct stale sorry/incompleteness documentation in ModalS5.lean and Perpetuity/Principles.lean
- **Status**: [IMPLEMENTING]
- **Effort**: 1 hour
- **Dependencies**: 291 (satisfied)
- **Research Inputs**: specs/294_eliminate_sorry_in_modals5_and_perpetuity/reports/01_sorry-elimination-modals5-perpetuity.md
- **Artifacts**: plans/01_correct-stale-sorry-documentation.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

This task was re-scoped after research disproved its original premise. Both target files, and
their entire 17-module transitive `Bimodal.*` import closure, are already fully sorry-free —
verified three independent ways (a `#print axioms` audit over all 31 declarations showing no
`sorryAx`; a comment-stripped source scan of the closure; and a clean
`lake build Bimodal.Theorems.ModalS5 Bimodal.Theorems.Perpetuity.Principles` emitting no
`declaration uses 'sorry'` warnings). All four grep hits for "sorry" in the two files are comment
prose. **There is no proof work in this task.** The residual work is purely documentation: two
stale comments assert incompleteness that no longer exists, and the roll-up status block in
`Theories/Bimodal/Theorems.lean` contradicts both the audit and its own sibling files.
Definition of done: every remaining "sorry"/"pending"/"partial" claim in the touched files is
factually true, and `lake build` stays clean.

### Research Integration

The plan is built directly on the research report's section "Actual Remaining Work / A. Stale
documentation claiming sorries and incompleteness". Its item B (`unusedSimpArgs` linter warnings)
is deliberately **excluded** — see Non-Goals. The report's own recommendation was a single
documentation phase; this plan splits it in two only to separate in-scope files from the declared
scope extension, so the extension can be reviewed or dropped independently.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

`specs/ROADMAP.md` exists but was not supplied as planning input and tracks a different area of
the formalization (the Kamp/`completeness_discrete` sorry endgame in
`WeakCanonical/`/`BXCanonical/`). It contains no items covering `Theorems/ModalS5.lean`,
`Theorems/Perpetuity/`, or `Theorems.lean` status documentation, so this task advances no roadmap
item. No ROADMAP.md edits are in scope.

## Goals & Non-Goals

**Goals**:
- Correct the stale incompleteness claim at `Theories/Bimodal/Theorems/ModalS5.lean:481-486`
  (section header "Biconditional Theorems (Infrastructure Pending)" + "Marked as sorry pending
  Phase 3.") — the biconditionals below it are proven.
- Correct the stale incompleteness claim at
  `Theories/Bimodal/Theorems/Perpetuity/Principles.lean:98-104` ("requires propositional
  reasoning patterns that are complex to encode" / "left as sorry for the MVP") — `contraposition`
  is fully derived.
- Verify (do not edit) the two already-accurate status lines at `Principles.lean:686`
  ("FULLY DERIVED (zero sorry)") and `:889` ("FULLY PROVEN (zero sorry)").
- Audit the roll-up status block in `Theories/Bimodal/Theorems.lean` (lines 31, 39, 40, plus the
  adjacent line 32 — see Phase 2) and correct each line that is stale, verifying staleness before
  editing.
- Keep `lake build` clean and leave every touched comment factually accurate.

**Non-Goals**:
- Any proof, tactic, or definition change. No `.lean` code outside comments/docstrings is touched.
- Fixing the `linter.unusedSimpArgs` warnings anywhere — including the 5 in `Principles.lean`
  (lines 400, 667, 744, 810, 846) that the research report flagged. These are owned by the
  separate Mathlib-linter-compliance task, whose `file_scope` covers
  `Theories/Bimodal/Theorems/`. Touching them here would create a concurrent-edit conflict.
- Any edit to `Theories/Bimodal/Theorems/Perpetuity/Bridge.lean` (linter-task territory; its
  P5/P6 status text is already correct).
- Auditing status documentation elsewhere in the repo (`Theorems/Perpetuity/README.md`,
  `docs/`, `typst/`, `latex/`) even where it repeats the same staleness. Out of scope; note
  findings in the summary rather than acting on them.
- Correcting the `CLAUDE.md` Lean/Mathlib version mismatch the report noted incidentally.

## Scope Extension (explicit)

`Theories/Bimodal/Theorems.lean` is **outside** the task's declared `file_scope`
(`Theorems/ModalS5.lean`, `Theorems/Perpetuity/Principles.lean`). It is included deliberately and
with justification: lines 31/39/40 are the roll-up status lines that most directly contradict the
axiom audit, and `Bridge.lean:980-981` already states P5/P6 are fully proven — so `Theorems.lean`
is out of sync with both the code and its own siblings. Correcting the leaf docstrings while
leaving the aggregate index asserting "1 technical sorry" would leave the repo self-contradictory.
The extension is confined to the `## Status` block of that one file (lines 24-40); nothing else in
`Theorems.lean` is touched, and no other out-of-scope file is added.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Implementer treats task as proof work and churns on already-correct proofs | H | M | Phase 1 opens with a build+grep confirmation of zero sorries; plan states no tactic edits are permitted; any proof-body edit is a plan violation |
| Replacement text introduces a new inaccurate claim (over-correcting) | M | M | Each correction must be justified against a named declaration in the file; Phase 2 requires per-line verification before editing |
| Edit collides with the concurrent linter-compliance task in `Theorems/` | M | L | Comment-only edits at non-overlapping line ranges; explicit prohibition on touching `simp only` lists and `Bridge.lean` |
| `Theorems.lean:32` (ModalS4 "NOT STARTED (0/4)") turns out to be partly true | L | M | Phase 2 requires verifying ModalS4 declarations build and audit clean before rewriting that line; leave it unchanged and report if verification is inconclusive |
| Docstring edits trigger a large dependent rebuild that surfaces unrelated pre-existing warnings | L | M | Pre-existing `unusedSimpArgs` warnings are expected and must be left alone; only new errors/warnings count as regressions |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |

Phases within the same wave can execute in parallel. Phase 2 touches a disjoint file from
Phase 1, but is sequenced after it so the single full-project build gate at the end of Phase 2
covers both phases' edits.

### Phase 1: Correct stale claims in the two in-scope files [COMPLETED]

**Goal**: The two stale comments in `ModalS5.lean` and `Principles.lean` describe reality; the two
already-accurate status lines are confirmed unchanged.

**Tasks**:
- [x] Re-confirm the premise before editing: run
      `lake build Bimodal.Theorems.ModalS5 Bimodal.Theorems.Perpetuity.Principles` and confirm no
      `declaration uses 'sorry'` warning appears. Record the result. *(completed — build
      succeeded, 696 jobs, 0 `declaration uses 'sorry'` warnings, 21 pre-existing
      `unusedSimpArgs` warnings)*
- [x] Record the baseline grep: `grep -n sorry` on both files returns exactly 4 hits
      (`ModalS5.lean:485`, `Principles.lean:103`, `:686`, `:889`). *(completed — exactly those 4
      hits confirmed, all comment prose)*
- [x] Rewrite the `ModalS5.lean:481-486` doc block: retitle the section (drop "(Infrastructure
      Pending)") and replace "Marked as sorry pending Phase 3." with a factual statement. The
      biconditionals in that section — `box_conj_iff` (:502), `diamond_disj_iff` (:609),
      `s5_diamond_box` (:793), `s5_diamond_box_to_truth` (:853) — are all proven, and the
      deduction-theorem infrastructure the old text called "needed" is in place. Do not change
      `def iff` or any proof body. *(completed — all four declarations confirmed present at the
      cited lines and axiom-audited clean: `box_conj_iff`/`diamond_disj_iff` →
      `[propext, Classical.choice, Quot.sound]`, `s5_diamond_box`/`s5_diamond_box_to_truth` →
      `[propext]`. Replacement text names the actual infrastructure used, verified by grep of the
      section: `box_iff_intro`, `box_mono`, `imp_trans`, `pairing`, `box_conj_intro` — no
      deduction-theorem call appears)*
- [x] Rewrite the `Principles.lean:98-104` doc block for `contraposition`: drop the "complex to
      encode" / "left as sorry for the MVP" / "semantic justification remains sound" framing.
      `contraposition` (:109) is fully derived and audits to `[propext]` only. Keep the numbered
      proof-strategy steps (lines 91-96) and the **Usage** line (:106-107) — both are accurate.
      *(deviation: altered — did all of the above (audit confirmed `[propext]` only; steps and
      **Usage** line kept verbatim), and additionally corrected one further inaccurate line in
      the same doc block: `:89` claimed "Derived using double negation elimination (DNE) axiom",
      but the proof body uses only `Axiom.prop_k` (×2) and `Axiom.prop_s` (×2) with no DNE
      reference anywhere in lines 109-220. Corrected to name `prop_k`/`prop_s`. Additive
      accuracy fix inside the block already being rewritten, in service of the phase goal; no
      planned step was skipped or substituted)*
- [x] Check the proof-body comments immediately below (`Principles.lean:111-117`) for coherence
      with the corrected docstring. Only adjust wording that still asserts the proof is
      unfinished (e.g. "The full proof requires:" framing); do not rewrite accurate proof
      commentary and do not touch any tactic. *(completed — retitled "The full proof requires:"
      → "Proof outline:" and corrected step 3, which credited the `bc`/B-combinator route; the
      derivation actually builds the commuted form from `prop_s`/`prop_k` via `imp_trans`
      (:179-180). No tactic touched)*
- [x] Verify `Principles.lean:686` and `:889` and leave them **unchanged** — both already state
      zero-sorry status correctly. Record that they were checked and required no edit.
      *(completed — both read and confirmed accurate; left byte-identical. Now at `:688` and
      `:891` due to the +2 net line shift from the docstring edit above)*
- [x] Re-run `lake build Bimodal.Theorems.ModalS5 Bimodal.Theorems.Perpetuity.Principles` and
      confirm still clean (pre-existing `unusedSimpArgs` warnings excepted). *(completed — build
      succeeded, 696 jobs, 0 sorry warnings; warning set identical to baseline apart from the 5
      `Principles.lean` `unusedSimpArgs` warnings shifting +2 lines (400/667/744/810/846 →
      402/669/746/812/848), matching the net docstring delta exactly. No new warnings)*

**Timing**: 0.5 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Theorems/ModalS5.lean` — comment/docstring only, at lines 481-486 (plus
  optional wording touch-ups strictly inside that doc block)
- `Theories/Bimodal/Theorems/Perpetuity/Principles.lean` — comment/docstring only, at lines
  98-104 and, if needed for coherence, the proof-body comments at 111-117

**Verification**:
- `grep -n sorry` across both files returns exactly 2 hits, both the accurate status lines
  (`Principles.lean` "FULLY DERIVED (zero sorry)" and "FULLY PROVEN (zero sorry)"); zero hits in
  `ModalS5.lean`.
- `grep -n -i "pending\|MVP"` in the edited regions returns nothing stale.
- Scoped build clean; no new errors or warnings versus the Phase 1 baseline.
- No diff hunk touches a tactic, term, or declaration signature — confirm with
  `git diff -- Theories/Bimodal/Theorems/ModalS5.lean Theories/Bimodal/Theorems/Perpetuity/Principles.lean`.

---

### Phase 2: Audit and correct the Theorems.lean roll-up status block [COMPLETED]

**Goal**: The `## Status` block in `Theories/Bimodal/Theorems.lean` (lines 24-40) matches the axiom
audit and its sibling files.

**Tasks**:
- [x] Verify each candidate line against the code before editing it — audit, then edit; never edit
      on the strength of this plan's text alone: *(completed — all four lines verified stale by
      `lean_verify` axiom audits plus scoped builds; no line edited on the plan's word alone.
      Recorded results under each bullet below)*
      - **Line 31** "Modal S5 Phase 2: PARTIAL (4/6 proven, biconditionals pending)" — expected
        stale. `ModalS5.lean` contains 12 declarations, all auditing clean, biconditionals
        included.
        **VERIFIED STALE.** 12 declarations confirmed present; 11 are derivations (type contains
        `⊢`) and 1 is the `iff` connective definition (`: Formula`) — so neither "4" nor "6"
        matched anything in the file. All four biconditionals audit clean:
        `box_conj_iff`/`diamond_disj_iff` → `[propext, Classical.choice, Quot.sound]`,
        `s5_diamond_box`/`s5_diamond_box_to_truth` → `[propext]`. Scoped build emits no
        `declaration uses 'sorry'`. No `^axiom ` declaration in the file.
        **Corrected to**: "Modal S5 Phase 2: COMPLETE (11 derivations + `iff` connective, zero
        sorry)".
      - **Line 39** "P5: `◇▽φ → △◇φ` - THEOREM (using modal_5, 1 technical sorry)" — expected
        stale. `perpetuity_5` audits clean; `Principles.lean:889` already says FULLY PROVEN.
        **VERIFIED STALE.** `perpetuity_5` (`Principles.lean:904`) audits to
        `[propext, Classical.choice, Quot.sound]` — no `sorryAx`, so the "1 technical sorry" claim
        is false. `Bridge.lean:980` independently states "P5: ✓ FULLY PROVEN (zero sorry, via P4 +
        persistence)". **Corrected to**: "P5: `◇▽φ → △◇φ` - PROVEN (zero sorry)".
      - **Line 40** "P6: `▽□φ → □△φ` - AXIOMATIZED (semantic justification)" — expected stale.
        `perpetuity_6` (`Bridge.lean:894`) audits to
        `[propext, Classical.choice, Quot.sound]` — derived, not axiomatized; `Bridge.lean:980-981`
        already says fully proven.
        **VERIFIED STALE.** Audit reproduced exactly: `perpetuity_6` (`Bridge.lean:894`) →
        `[propext, Classical.choice, Quot.sound]`. It is a `def ... := by` with a real derivation,
        not an `axiom`. `Bridge.lean:981` states "P6: ✓ FULLY PROVEN (zero sorry, via P5(¬φ) +
        bridge lemmas + double_contrapose)". **Corrected to**: "P6: `▽□φ → □△φ` - PROVEN (zero
        sorry)". Note: only `Theorems.lean` was edited — `Bridge.lean` itself was not touched
        (linter-task territory).
      - **Line 32** "Modal S4 Phase 4: NOT STARTED (0/4 theorems)" — **discovered during planning,
        beyond the three lines named in the task description.** `ModalS4.lean` in fact contains 4
        declarations (`s4_diamond_box_conj`, `s4_box_diamond_box`, `s4_diamond_box_diamond`,
        `s5_diamond_conj_diamond`). Verify they build and audit clean (`lake build
        Bimodal.Theorems.ModalS4` plus `#print axioms` on each) and correct the line if so. If
        verification is inconclusive, leave the line unchanged and say so in the summary — do not
        guess.
        **VERIFIED STALE — verification was conclusive, so the line was corrected.** All 4
        declarations confirmed present at `ModalS4.lean:64, 156, 179, 310`.
        `lake build Bimodal.Theorems.ModalS4` succeeded (697 jobs) with no
        `declaration uses 'sorry'`. Axiom audits: `s4_diamond_box_conj` →
        `[propext, Classical.choice, Quot.sound]`, `s4_box_diamond_box` → `[propext]`,
        `s4_diamond_box_diamond` → `[propext]`, `s5_diamond_conj_diamond` →
        `[propext, Classical.choice, Quot.sound]`. None contains `sorryAx`; no `^axiom `
        declaration in the file. **Corrected to**: "Modal S4 Phase 4: COMPLETE (4/4 theorems,
        zero sorry)".
- [x] Apply corrections only to the lines verified stale. Leave lines 27, 28, 35-38 unchanged —
      they already read COMPLETE/PROVEN (zero sorry) and are accurate. *(completed — exactly 4
      lines changed (31, 32, 39, 40); lines 27, 28, 35-38 left byte-identical)*
- [x] Keep the edit inside the `## Status` block. Do not touch the import list, `## Submodules`,
      `## Usage`, or `## References` sections. *(completed — `git diff` shows a single hunk
      spanning lines 28-40, entirely inside the `## Status` block)*
- [x] Run `lake build` (full project) as the closing gate for both phases. *(completed — 1877
      jobs, build completed successfully, 0 errors, 0 `declaration uses 'sorry'` warnings. The
      only warnings in the three touched files are the 5 pre-existing `unusedSimpArgs` warnings
      in `Principles.lean`, shifted +2 lines; `ModalS5.lean` and `Theorems.lean` emit none)*

**Timing**: 0.5 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Theorems.lean` — `## Status` block only (lines 24-40). Declared scope
  extension; see "Scope Extension (explicit)" above.

**Verification**:
- `grep -n -i "sorry\|PARTIAL\|pending\|AXIOMATIZED\|NOT STARTED" Theories/Bimodal/Theorems.lean`
  returns only claims that are true of the current code.
- Every edited line is backed by a recorded verification (build result or `#print axioms` output)
  captured during this phase.
- `lake build` completes with no errors and no new warnings relative to the pre-task baseline
  (the pre-existing `unusedSimpArgs` warnings in `DeductionTheorem.lean`, `Principles.lean`,
  `Formula.lean`, `Bridge.lean`, and `GeneralizedNecessitation.lean` remain and are expected).
- `git diff --stat` shows exactly three files changed and no `.lean` code (non-comment) lines
  modified.

## Testing & Validation

- [x] `lake build Bimodal.Theorems.ModalS5 Bimodal.Theorems.Perpetuity.Principles` clean.
      *(696 jobs, success, 0 sorry warnings)*
- [x] `lake build` (full project) clean; warning set unchanged from baseline. *(1877 jobs,
      success, 0 errors, 0 sorry warnings. Touched files emit only the 5 pre-existing
      `unusedSimpArgs` warnings in `Principles.lean`, shifted +2 lines; `ModalS5.lean` and
      `Theorems.lean` emit none)*
- [x] `grep -rn sorry` over the three touched files yields only factually true prose. *(2 hits in
      `Principles.lean` (:688, :891) — the pre-existing accurate "zero sorry" status lines; 0 in
      `ModalS5.lean`; 10 in `Theorems.lean`, all "zero sorry" claims verified true)*
- [x] `git diff` confirms comment/docstring-only changes — no tactic, term, signature, or
      `simp only` argument modified. *(verified across all three files)*
- [x] `Bridge.lean` and all `simp only` lists untouched (linter-task territory preserved).
      *(`git diff --stat` shows exactly 3 files under `Theories/`; `Bridge.lean` absent)*
- [x] Each corrected claim traceable to a named declaration or a recorded build/axiom-audit result.
      *(all 6 corrected claims backed by recorded `lean_verify` output and/or build results —
      see the Phase 1/2 annotations above)*

## Artifacts & Outputs

- `specs/294_eliminate_sorry_in_modals5_and_perpetuity/plans/01_correct-stale-sorry-documentation.md`
  (this file)
- `specs/294_eliminate_sorry_in_modals5_and_perpetuity/summaries/01_correct-stale-sorry-documentation-summary.md`
  — must record: the zero-sorry evidence re-confirmation, the exact before/after text of each
  corrected line, the lines verified as already accurate and left alone, and any status
  documentation found stale elsewhere in the repo but deliberately not touched.
- Modified: `Theories/Bimodal/Theorems/ModalS5.lean`,
  `Theories/Bimodal/Theorems/Perpetuity/Principles.lean`, `Theories/Bimodal/Theorems.lean`

## Rollback/Contingency

All changes are comment-only and confined to three files, so rollback is
`git checkout HEAD -- <file>` per file (safe only on an otherwise-clean tree; snapshot first per
`.claude/rules/git-workflow.md` if uncommitted work exists). Commit per phase so either phase can
be reverted independently. If Phase 2's verification of `Theorems.lean:32` (ModalS4) is
inconclusive, drop that single line from the phase and complete the rest — it is additive to the
task's stated scope, not load-bearing. If the full `lake build` in Phase 2 regresses, revert the
comment edits and report: a comment-only change cannot cause a genuine build failure, so a
regression indicates an unrelated or concurrent change and must be diagnosed, not worked around.
