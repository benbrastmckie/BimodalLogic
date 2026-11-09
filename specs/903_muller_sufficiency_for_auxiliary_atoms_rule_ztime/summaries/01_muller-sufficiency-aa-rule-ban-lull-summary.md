# Implementation Summary: Task #903

- **Task**: 903 - Settle whether a deterministic Muller automaton suffices for the Auxiliary-Atoms rule and the ban/lull mechanism at ZTime, or whether Rabin or parity is genuinely needed
- **Status**: [COMPLETED]
- **Started**: 2026-11-09T06:40:00Z
- **Completed**: 2026-11-09T07:40:00Z
- **Effort**: ~2.25 hours
- **Dependencies**: None
- **Artifacts**: plans/01_muller-sufficiency-aa-rule-ban-lull.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

This task settled, on paper, whether a deterministic Muller automaton suffices for the two
consumers the architecture names: the Auxiliary-Atoms (AA) rule and the ban/lull mechanism at
ZTime. The research dispatch delivered the answer as a split; this implementation dispatch is a
pure record-amendment pass landing that split in the three records that currently assert the
question is open, discharging a second obstruction as a free saving, and writing this close-out.
No Lean source, no build file, and no dependency declaration was touched by any phase.

**The verdict in three sentences.** A deterministic Muller automaton **suffices for the
Auxiliary-Atoms rule**, which carries no acceptance condition and demands only determinism
(`p : Atom → ℕ → Atom` being a function is the whole requirement). It **does not suffice for the
ban/lull mechanism**, whose banned list is indexed by the automaton's accepting pairs
(Reynolds 2001 §12, `bl : T → (C × {1,…,K})*`). So (O1) is preserved with its ground sharpened,
and `Muller.toRabin_exists` (fork `DA/Conversions.lean:112`, `proof_wanted`) is the single
highest-value gap in either CSLib tree.

**Why the naive repair is unsound, not merely incomplete.** Take `Q = {a,b}`, `𝓕 = {{a,b}}` (the
DMA for "both `a` and `b` recur"). Pair-enumeration of this Muller family yields
`χ₁' = GF a ∨ GF b`, which is **valid** over any finite state space, so `¬Eχ₁'` is unsatisfiable
and `φ⁺' = θ_A ∧ φ ∧ ¬Eχ₁'` is inconsistent — while `φ⁺` is consistent, because the DMA's
complement is nonempty (any word with `infOcc = {a}`). That is strictly stronger than the
incompleteness `DA/Conversions.lean`'s own docstring already records. The same example shows no
Rabin condition over `{a,b}` has accepted-`infOcc`-family `{{a,b}}`, so the LAR state-space
blowup is unavoidable in general, not an artifact of a bad pair choice.

**The one genuine saving.** (O2) — the indexed conjunctive product with a nameable initial
state, costed in report 902 at 100-150 lines of new Rabin closure code — is discharged for free
by `Muller.exists_iSup` (fork `DA/MullerClosure.lean:125`, proved, sorry-free) under a named
composition order: union on the **Muller** side first, determinize **once** afterwards. This
depends on two carried facts, named together rather than re-derived: `PT(w₀)` is finite (report
879 §2.4), and the union-first ordering is legitimate because complementing the union of the
component violation languages is the same requirement as universal non-acceptance in every
component (report 902 Finding 2). The automaton-side gap therefore drops from two items to one.

**What is explicitly untouched.** (O3) (the determinized automaton arrives as an existential over
`Type`, not nameable syntax) and (O4) (nothing in CSLib touches the rest of the 21-row ingredient
table) stand exactly as before. The GO for T3 as a paper programme is unaffected — it never
depended on the automaton being formalizable. Nothing in this task is a completeness claim.

**The forensic note worth carrying forward.** Reynolds' Theorem 2 cites McNaughton (whose
theorem lands in Muller) and Safra (for a Rabin conclusion), so the Muller→Rabin step is silently
absorbed into that theorem — exactly the step CSLib defers, and exactly the step this task shows
is load-bearing rather than cosmetic.

## What Changed

- `specs/902_reassess_lplus_ztime_nogo_cslib_omega_automata/reports/01_cslib-omega-automata-nogo-reassessment.md`
  — (O1)'s parenthetical replaced by the settled split and narrowed to Rabin alone (on
  `Parity.toRabin_language_eq` being proved); the (O2) bullet replaced by its discharge, naming
  the union-first composition order and `Muller.exists_iSup`; both "settle (O1) first"
  recommendations (Finding 4b recommendation 1, Recommendations item 1) replaced by a record that
  the settlement has happened; recommendation 6 (the 100-150-line Rabin closure item) withdrawn
  rather than re-filed; the matching Risks bullet discharged negatively in place; one new dated
  `**Amended by**` note under `## Executive Summary`. The `(O1)/(O3)/(O4)` obstruction frame and
  the "do not `require` anything now" conclusion are preserved byte-identical throughout.
- `specs/902_reassess_lplus_ztime_nogo_cslib_omega_automata/summaries/01_cslib-omega-automata-nogo-reassessment-summary.md`
  — one new dated `**Amended by**` note under `## Overview` (this file has no `## Executive
  Summary` heading — see Plan Deviations), pointing at this task's report; its "Not filed, by
  decision" row for the (O2) lemma is now described as a withdrawal rather than a deferral; body
  otherwise untouched.
- `specs/879_lplus_ztime_completeness_tm_plus_lc_programme/reports/01_lplus-ztime-completeness-programme.md`
  — ingredient row 16's fourth cell (`Evidence / proposal`) now states that the AA rule needs
  only determinism while the ban/lull mechanism needs the pair shape, narrowing "Rabin or parity"
  to Rabin alone and dropping the now-discharged "(≈100-150 lines to add)" clause; the NO-GO
  verdict paragraph's (O1)/(O2) clauses amended the same way, with (O3)/(O4) and the paragraph's
  opening and closing sentences byte-identical; the executive-summary deliverable-4 bullet
  narrowed and discharged the same way, with its GO/NO-GO verdict string and "T1 is neither
  reached nor refuted" sentence byte-identical; one new dated `**Amended by**` note added below
  the existing one. Ingredient row 8 (the full-product lemma, this repository's own
  TaskFrame-semantics obligation) is deliberately byte-identical.
- `specs/ROADMAP.md` — the "MSO/Rabin route reaches ZTime only" ruling's open-question sentence
  (naming this task as the question's owner) replaced by the settled split verdict, citing this
  task's report. The ruling's surrounding text — that the route stays a paper result and does not
  close `Decidable (PlusValidZTime φ)` constructively — and the separate "MSO decidability
  formalization is refused outright" bullet are both untouched.
- `specs/903_muller_sufficiency_for_auxiliary_atoms_rule_ztime/plans/01_muller-sufficiency-aa-rule-ban-lull.md`
  — per-phase task check-offs, Phase 1-3 notes recording anchor measurements and the two
  deviations, and the four phase-heading markers.
- `specs/903_muller_sufficiency_for_auxiliary_atoms_rule_ztime/summaries/01_muller-sufficiency-aa-rule-ban-lull-summary.md`
  — new; this close-out record.

## Decisions

- **Amend records, do not re-derive the finding.** Every amendment cites the research report
  (`specs/903_.../reports/01_muller-sufficiency-aa-rule-ban-lull.md`) as the source of the split
  verdict and the (O2) discharge, rather than restating the argument in each record.
- **Preserve outcomes, change grounds.** Each of the three amended records keeps its own
  outcome sentence byte-identical (902's "do not `require` anything now"; 879's NO-GO and T3 GO;
  ROADMAP's "does not close `Decidable (PlusValidZTime φ)` constructively"), and only the
  obstruction's *ground* is replaced.
- **Withdraw rather than re-cost or re-file** report 902's recommendation 6 (the 100-150-line
  Rabin closure item): under the union-first ordering it is not needed at all, not merely cheaper.
- **Close Phase 3 `[COMPLETED WITH EXCLUSIONS]`**, not `[COMPLETED]`, because
  `test-roadmap-generation.sh` could not run in this environment (see Plan Deviations and the
  plan's Phase 3 `#### Reasoned Exclusions` row) even though its substitute evidence is fully
  green. The plan's own Risks table pre-authorized exactly this substitution.
- **No `user_decision` is raised.** The research report's own Decisions item 7 already
  determined that nothing here is a preference-shaped question; this implementation dispatch
  adds no new one.

## Plan Deviations

- **Phase 1 task** (dated note location in the 902 summary): altered. The plan directed the note
  to land under `## Executive Summary` in
  `specs/902_.../summaries/01_cslib-omega-automata-nogo-reassessment-summary.md`, but that file
  carries no such heading — it is summary-format, whose top section is `## Overview`; the plan's
  cited "line 47" was a prose mention of report 879's own heading, not a heading in this file.
  The note was placed under this file's own `## Overview` heading instead.
- **Phase 1 Scope Hypothesis**: `git diff -U0` on report 902 showed 7 hunks, not the anticipated
  8, because the (O1) parenthetical replacement and the Rabin-narrowing note were authored as one
  contiguous paragraph edit (no unchanged line separates them) and so collapsed into one diff
  hunk. All seven anchor-table dispositions were nonetheless satisfied exactly; this is a diff-
  mechanics artifact, not a missed edit.
- **Phase 3 verification**: `bash .claude/scripts/tests/run-all.sh --only
  test-engine-written-state-paths-lib.sh,test-roadmap-generation.sh` exited non-zero on
  `test-roadmap-generation.sh` for the environment reason the plan's Risks table named in advance
  (the suite resolves its subject in `source-store` mode; this tree has no `agent-system/` tree
  and `.claude-extensions.json` carries no `source_dir` key, so the suite never reaches
  `specs/ROADMAP.md` here). Substituted `bash .claude/scripts/roadmap-integration.sh --regenerate
  --dry-run` and `bash .claude/scripts/roadmap-integration.sh --print`, both exit 0 against the
  amended file; recorded as a `#### Reasoned Exclusions` row in the plan under Phase 3.

## Impacts

- The CSLib dependency question stays exactly where report 902 left it: do not `require` either
  CSLib tree now, reinforced on a second, independent (mathematical, not merely trust-surface)
  ground — the fork does not today contain the determinization the architecture consumes.
- `Muller.toRabin_exists` is now recorded, in three places other tasks read (902, 879, ROADMAP),
  as the single highest-value `proof_wanted` in either CSLib tree, with its value established
  rather than conjectural.
- The automaton-side obstruction count for the completeness programme drops from four named
  components to three, a genuine simplification with no Lean work and no dependency change.
- Task 901 (the two-sided Reynolds engine paper proof), which already depends on this task, will
  read this report by construction; its task description is deliberately left unamended (out of
  this plan's scope, per precedent).

## Deliberately Not Done, and Why

- **No `require` on either CSLib tree** (report 902 recommendation 5, strengthened): the fork
  does not contain the determinization the architecture consumes, so a dependency today would
  shorten nothing on the automaton-side path.
- **No upstream PR and no CSLib-side lemma written.** Recommendation 4's named
  `Muller.toRabinLAR : Muller State Symbol → Rabin (LAR State) Symbol` with a `language_eq`
  belongs in `~/Projects/cslib`; `rules/pr-prohibition.md` bars an agent from it unconditionally,
  and it is recorded with its narrowing — *named*, not the existential `Muller.toRabin_exists` as
  currently stated, because (O3) is alive precisely because an `∃ (State : Type)` cannot be
  written into `θ_f`.
- **No `Muller.compl`, `Muller.inter`, `Rabin.union`, `Rabin.exists_iSup`, or
  `Rabin.toParity_exists` filed anywhere.** The report's §3 puts the first four off the critical
  path under the union-first ordering, and `Parity.toRabin_language_eq` being proved puts the
  fifth there too.
- **No task filed in this tree** (recommendation 7): nothing may rest on Muller sufficiency for
  the ban mechanism, and task 901 already depends on this task so it will read this report by
  construction.
- **No amendment to any task description** in `specs/state.json`, including task 901's, which
  still carries the overturned "absent from Mathlib" ground — out of this plan's scope, as the
  precedent task (902) recorded for the same reason.
- **No Lean source, no `lakefile.toml`/`lake-manifest.json` edit, no Lean process started** by any
  phase. Confirmed: `git status --short -- FormalSystem/ Tests/ lakefile.toml lake-manifest.json`
  is empty, and `git diff --stat` over this task's own commits for the same paths is empty.
- **No `.claude/` redeploy.** The dispatch's deploy-freshness warning (six extensions stale) is
  unactionable here: no `agent-system/` tree exists in this repository and
  `.claude-extensions.json` carries no `source_dir` key — the same condition the precedent task
  measured. `deploy-headless.sh` is its own task, not this one's.
- **No file under `.claude/**`**, and no file in `~/Projects/cslib` or `~/Projects/cslib-pr648`,
  written by any phase.

## Verification

- `bash .claude/scripts/validate-artifact.sh` exits 0 on all four amended/new artifacts: both
  amended reports (902, 879) and the amended summary (902) as `report`/`summary`, this task's new
  summary as `summary`, and this task's plan as `plan` (every phase heading a valid closed-enum
  marker).
- `bash .claude/scripts/validate-state.sh` exits 0 (PASSED WITH WARNINGS; all warnings pre-exist
  this task and concern unrelated projects' `file_scope` coarseness, not this task).
- `git status --short -- FormalSystem/ Tests/ lakefile.toml lake-manifest.json` is empty, and the
  union of `git show --name-only` over this task's own commits touches no path outside
  `specs/**`.
- `git status --short -- .claude/` is empty.
- **Full gate set (`verify-deploy.sh`) deferred per this dispatch's `## Batch Gate Deferral`
  directive**, not independently run in this dispatch. This task's own touched paths
  (`specs/903_.../summaries/*`, `specs/903_.../plans/*`) resolve to `__FULL_SWEEP__` under
  `suite_selection_select` — the same no-narrower-suite outcome Phases 1 and 2 already measured
  for their own `specs/**` targets — so there is no `--only SUITE` narrowing available for this
  phase specifically; the deferral directive's alternative narrowing form
  (`verify-deploy.sh --only-gate N`) is likewise not invoked, and the complete gate set is left to
  run exactly once at the end of this `/orchestrate` batch invocation, attributed back to this
  task via its `modified_files`. `validate-artifact.sh` and `validate-state.sh` above are the
  scoped checks that do apply and both exit 0.

## Follow-ups

- Whenever task 901 is next touched, its description's "absent from Mathlib" ground (already
  overturned by report 902, now further sharpened by this task) is worth a one-line fix — not
  done here, out of scope per precedent.
- The CSLib-side `Muller.toRabinLAR` construction (report 902 recommendation 4, narrowed by this
  task's report §4 Recommendation 4 to a *named* construction, not an existential) remains
  unfiled, by decision, pending an upstream contribution outside this agent's authority.
- Report 879's P9 continues to own the progress-measure alternative that would avoid
  determinization entirely; this task's §4 last paragraph records the direct-DRA shortcut as a
  closed sub-question (the colour-word labelling does not resolve the automaton's guess).

## References

- `specs/903_muller_sufficiency_for_auxiliary_atoms_rule_ztime/reports/01_muller-sufficiency-aa-rule-ban-lull.md` (this task's research report, the sole substantive input)
- `specs/903_muller_sufficiency_for_auxiliary_atoms_rule_ztime/plans/01_muller-sufficiency-aa-rule-ban-lull.md` (this task's implementation plan, carrying the Phase 1-3 notes)
- `specs/902_reassess_lplus_ztime_nogo_cslib_omega_automata/reports/01_cslib-omega-automata-nogo-reassessment.md` (amended)
- `specs/902_reassess_lplus_ztime_nogo_cslib_omega_automata/summaries/01_cslib-omega-automata-nogo-reassessment-summary.md` (amended)
- `specs/879_lplus_ztime_completeness_tm_plus_lc_programme/reports/01_lplus-ztime-completeness-programme.md` (amended)
- `specs/ROADMAP.md` (amended)
