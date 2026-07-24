# Implementation Summary: Sweep Stale Task-Number Pointers from Lean Sources

- **Task**: 380 - sweep_stale_task_number_pointers_from_lean_sources
- **Status**: [COMPLETED]
- **Started**: 2026-07-24
- **Completed**: 2026-07-24
- **Effort**: 8 phases, ~12 h
- **Dependencies**: Tasks 387, 388 (both landed; baseline measured post-excision at `c12eab1d6`)
- **Artifacts**:
  - plans/01_pointer-sweep-plan.md
  - reports/01_pointer-sweep-inventory.md
  - scripts/rewrite_task_refs.py, scripts/protected-decls.txt
  - worklists/baseline.md, worklists/counts.md, worklists/phase2-autodrop.diff,
    worklists/handedit-phase{3..7}.md
  - handoffs/phase-{2..7}-handoff-*.md
- **Standards**: artifact-formats.md, summary-format.md, no-task-references-in-deliverables.md,
  plan-format-enforcement.md, git-workflow.md

## Overview

All 1,549 ephemeral task-number reference lines across 192 `Theories/**/*.lean` files were swept,
replacing provenance-bearing pointers with durable anchors (declaration names, `file:line`
citations, section headings, PDF page references) per
`.claude/rules/no-task-references-in-deliverables.md`. **1,535 of 1,549 lines (99.1%) were
cleared. The 14 that remain are immovable under a binding constraint, not misses** — every one
shares a line with the token `sorry`, and the never-touch-sorry-lines rule is what makes the
906/820/26 sorry census a valid invariant. The sweep changed no declaration, proof, tactic, or
term: comment-stripped normalized code is byte-identical to the pre-sweep tree for 428 of 430
files, the other two carrying only six explicitly user-authorized string-literal payloads.

## Recount Trail (measured, not recorded)

Every figure below was re-measured in Phase 8 directly at each phase commit
(`git grep -hE '\b[Tt]asks?[ #-]?[0-9]{1,4}\b' <rev> -- 'Theories/**/*.lean' | wc -l`) rather than
copied from the per-phase notes:

| Point | Commit | Lines | Files | Δ |
|---|---|---|---|---|
| Pre-sweep baseline | `c12eab1d6` | **1,549** | 192 | — |
| After phase 1 (tooling only) | `853b6d0dd` | 1,549 | 192 | 0 (by design) |
| After phase 2 (scripted auto-drop) | `dcc1926e1` | 959 | 143 | −590 |
| After phase 3 (SharedWitness) | `ba95c0709` | 797 | 142 | −162 |
| After phase 4 (NfMultiAnchorBridge large files) | `cb8bf8099` | 626 | 140 | −171 |
| After phase 5 (bridge remainder + KampPrior) | `9ae8fd345` | 408 | 116 | −218 |
| After phase 6 (Metalogic remainder) | `7c6c2d148` | 273 | 73 | −135 |
| After phase 7.1 (non-Metalogic live files) | `07835bd60` | 184 | 49 | −89 |
| After phase 7 (Boneyard de-numbering) | `460f88a18` | 16 | 10 | −168 |
| **After phase 8 (final)** | this commit | **14** | **9** | −2 |

**Correction to a figure in circulation**: the dispatch brief for this phase cited "1,362
original". No artifact in this task contains that number and it is not reproducible. The verified
baseline is **1,549 lines / 192 files**, reproduced independently at `c12eab1d6` and at the
phase-1 commit `853b6d0dd`, and matching research report §1 exactly.

Companion patterns on the final tree:

| Pattern | Matches | Note |
|---|---|---|
| `\b[Tt]asks?[ #-]?[0-9]{1,4}\b` (the sweep pattern) | **14** | all 14 are sorry-lines |
| same, case-insensitive | **14** | equal only after the Phase-8 fix below |
| `\b[Tt]asks?[[:space:]]+[0-9]+(-[0-9]+)?\b` (current hook regex) | 13 | misses the hyphenated `task-355` at `InteriorGateGeneralK.lean:1044` |
| `\btasks?([[:space:]]+\|-)[0-9]+(-[0-9]+)?\b` -i (recommended hook regex) | **14** | hyphen-aware; matches exactly the 14 sorry-lines |
| `specs/[0-9]{3}_[A-Za-z0-9_]+` (script's strict path pattern) | **0** | cleared |
| `specs/[0-9]{3}_` (loose path pattern) | **2** | the deferred `MergedBracketQuarantine` pair below |

### The sweep pattern was case-sensitive, and hid a real reference for seven phases

`SWEEP_RE = \b[Tt]asks?[ #-]?[0-9]{1,4}\b` matches `Task`/`task`/`Tasks`/`tasks` but **not
all-caps `TASK`**. Every phase-1-7 worklist, `--count` run, and recount gate inherited that blind
spot. Phase 8 re-ran the pattern case-insensitively and found exactly one line that had been
invisible throughout:

```
SharedWitness.lean:11516: -- TASK 344 dispatch 11 (R2): RIGHT pin-anchored fragment gate producer + fold.
```

A `--` banner comment, no `sorry`, in Phase-3 territory — so it was cleaned under the plan's
straggler provision (→ `-- R2: RIGHT pin-anchored fragment gate producer + fold.`, keeping the
file-local route designator per the established convention and dropping both the task number and
the ephemeral dispatch number). Verified exhaustive afterwards: `\bTASKS?\b` with no digit
requirement now returns only two `WHOLE-TASK NO-GO` hits in `MergedBracketQuarantine.lean`, which
are ordinary English rather than references. Two lessons carry forward: **a case-sensitive gate
reporting "0" is not a proof of absence**, and — see the hook section — the general-purpose
advisory hook's regex (`grep -qiE`) *would* have caught this line, making it stricter than this
task's bespoke tooling on precisely the axis that mattered.

## Final Gate Evidence

Measured on the final tree, each gate with its actual number:

| Gate | Baseline | Final | Verdict |
|---|---|---|---|
| `lake build` | EXIT 0, 1789 jobs | **EXIT 0, 1789 jobs, 0 errors** | pass |
| Warning lines (whole-tree log replay) | see correction below | 1,024 (1,012 non-sorry + 12 `uses 'sorry'`) | all pre-existing |
| Sorry census, raw | 906 | **906** | exact |
| Sorry census, non-comment-line | 820 | **820** | exact |
| `sorryAx` occurrences | 26 | **26** | exact |
| `^axiom ` count | 2 | **2** | exact |
| Vacuous-definition count | 1 | **1** | exact (pre-existing) |
| Declaration lines | 7,316 | **7,316** | identical |
| `.lean` file count | 430 | **430** | identical (0 added, 0 deleted) |
| Changed-line `sorry` grep (whole task range) | 0 | **0** | no sorry-line touched |
| `--check-diff --base c12eab1d6` | 0 failures on clean tree | **196 files, 2 failures** | expected — see "authorized exceptions" |
| Comment-stripped code identity (430 files) | — | **428 identical, 2 differ** | the 2 are the authorized literals |
| Sweep recount | 1,549 | **14** | floor reached |

### Three reconciliations that are shifts or expected outcomes, not regressions

1. **`worklists/baseline.md`'s "exactly ONE pre-existing warning" was wrong and has been corrected
   in place.** It was measured on a cached build where only `DatasetGenerator` had been
   invalidated, so only that module's log was emitted. A build that replays every module's cached
   log emits **1,024 warning lines tree-wide — 1,012 non-sorry across 81 files**, all pre-existing.
   The invariant that actually holds, and that Phases 2-8 verified, replaces it: every hunk is
   provably comment-span-only, and warnings are emitted by elaborating declarations, so **if no
   declaration changed, no warning can have been introduced** — regardless of the total count. A
   future reader must not inherit the "one warning" baseline.
2. **`DatasetGenerator.lean`'s warning shifted `:2174` → `:2173`.** Message and column (`:6:`) are
   byte-identical and it is still the only warning in that file. One pure-pointer References
   bullet was deleted at `:80`. A line shift is unavoidable for any authorized comment deletion —
   this is a shift, not a regression; the warning was neither fixed nor worsened.
3. **`--check-diff` legitimately reports 2 failures**, and they are exactly the two files carrying
   user-authorized string-literal edits. The checker asserts comment-span-only hunks; string
   literals are not comments, so they must fail it. **The checker was not weakened, edited, or
   path-excluded to make the number look clean.**

### Build-graph coverage: a gate limitation found and closed in Phase 8

`lake build` builds only `@[default_target] lean_lib Bimodal`, whose import closure from
`Theories/Bimodal.lean` is **262 of the tree's 430 modules**. Of the 196 files this sweep changed,
the build gate elaborates **124**; **12** are reachable only from `lean_exe` roots and **60** are
Boneyard modules in no lake target at all. A `lake build` EXIT 0 was therefore never — in any
phase of this task — evidence about those 72 files. Phase 8 closed the gap rather than leaving the
claim overstated:

- **The 12 live exe-only modules were elaborated directly** via `lake env lean <file>`:
  `AxiomNames`, `BenchmarkAnchors`, `BenchmarkOracle`, `DatasetExport`, `DatasetValidator`,
  `EnumBenchmark`, `FormulaMutator`, `ProofStepExport`, `TableauBridge`,
  `TableauProofStepPipeline`, `TraceExporter` (all `Automation/`), and
  `Metalogic/Decidability/TraceExport`. Result: **12/12 rc=0, 0 errors**, 1 warning total
  (`DatasetExport.lean:1220`, a pre-existing `String.trimLeft` deprecation in unchanged code).
  Note `lake build enum_benchmark` is *not* a usable gate — it native-compiles the entire import
  closure including Mathlib.
- **The 60 uncompiled Boneyard modules rest on the code-identity proof**, which is
  lake-independent and detects delimiter damage: deleting a `-/` would extend a comment span over
  real code and drop those lines from the normalized form; deleting a `/-` would add prose lines
  to it. Neither occurred in any file.

## What Changed

- **Phase 1** — span-aware `rewrite_task_refs.py` (Lean comment-span parser with nesting, hard
  comment-span assertion, never-touch-sorry-lines guard, protected-decl-span skip by NAME;
  modes `--dry-run/--apply/--worklist/--count/--check-diff`), `protected-decls.txt`, categorized
  worklists, and calibration: auto-drop = 597 matches / 130 files (a safe superset of the
  research report's 469 estimate). Zero `Theories/` modifications.
- **Phase 2** — scripted category-(a) auto-drop of pure parenthetical pointers across 130 files
  including Boneyard; recount decrease exactly equal to the calibrated 590.
- **Phase 3** — `SharedWitness.lean`: 162 entries; section headers rewritten to content-based
  names; "Task N Phase M (deliberate)" notes converted to "Deliberate: …" citing decl names.
- **Phase 4** — the five largest `NfMultiAnchorBridge` files (`Base`, `InteriorGateGeneralK`,
  `SubBracket2V`, `EndIntervalConsumerK`, `OuterGate`): 173 entries; stale line ranges dropped
  with the pointers.
- **Phase 5** — bridge remainder + aggregator + `KampPrior.lean`: 222 entries across 29 files.
  The protected span `nf_nvar_exist_all_depths` (resolved BY NAME to KampPrior 350..535) had zero
  changed lines.
- **Phase 6** — rest of `Metalogic/` (WeakCanonical misc, `Decidability/`, `BXCanonical/`): 144
  entries across 48 files.
- **Phase 7** — `Automation/`, `Syntax/`, `Theorems/`, `ProofSystem/` (266 entries across 68
  files) plus 175 Boneyard lines across 43 files. `Formula.lean`'s three colliding
  `### Complexity verification` headings became distinct content-based names by inspecting what
  each `#eval` block actually verifies; `FormulaEnumerator.lean`'s headings became API-named.
- **Phase 8** — final verification (including two gate limitations found and closed: the
  case-sensitive sweep pattern and the build-graph coverage gap), the two authorized
  `EnumBenchmark` literals, two plan-sanctioned comment stragglers (`SharedWitness.lean:9-10` and
  `:11516`), the `baseline.md` correction, and this summary.

Durable-anchor vocabulary is tabulated per phase in the plan's task annotations and in the
phase-4 through phase-7 handoffs; representative substitutions: `task 129 (Henkin model) or
Reynolds pipeline (tasks 154-155)` → "the Henkin-model route or the Reynolds pipeline";
`task-363` → "the depth-graded (fiber-consistency) guard"; `task 351` → `nfEval_le2_reduction` /
"Rabinovich Lemma 3.2(2)"; `Task 116` → the verified decl names `temp_k_dist_derived` /
`temp_4_derived`; `**Archived**: 2026-05-29 (task 202, Phase 0)` → `**Archived**: 2026-05-29`.

## Immovable Residual: the 14 Sorry-Line Sites

**A repo-wide recount of 0 is not achievable, and that is the correct outcome.** The floor is
structural: the binding postmortem rule forbids modifying any line containing the token `sorry`,
*even when the match is comment prose*, because that guard is precisely what makes the raw
906/820 census a valid invariant. Editing one of these lines to drive a count down would trade a
real correctness gate for a cosmetic one. Phase 1 predicted a floor of 14; all 14 are now
identified and enumerated. Verified: all 14 contain lowercase `sorry`.

| # | Site | Why immovable |
|---|---|---|
| 1 | `Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/Base.lean:971` | "…that strategic **sorry** is DISCHARGED…" — sorry-line |
| 2 | `…/NfMultiAnchorBridge/Base.lean:1054` | "…**sorry**-free leaf…" in a docstring — sorry-line |
| 3 | `…/NfMultiAnchorBridge/Base.lean:1077` | "…DISCHARGES and CORRECTS the Phase-6 §4.3 strategic **sorry**…" — sorry-line |
| 4 | `…/NfMultiAnchorBridge/Base.lean:1175` | "…**sorry**-free leaf…" — sorry-line |
| 5 | `…/NfMultiAnchorBridge/Base.lean:1761` | "…**sorry**-free leaf…" — sorry-line |
| 6 | `…/NfMultiAnchorBridge/InteriorGateGeneralK.lean:1044` | "No `**sorry**`/`admit`…" — sorry-line |
| 7 | `…/NfMultiAnchorBridge/SubBracket2V.lean:2104` | "…independently-driven, **sorry**-free directions…" — sorry-line |
| 8 | `…/NfMultiAnchorBridge/CarrierK1V.lean:79` | "…**sorry**-free leaf…" — sorry-line |
| 9 | `Metalogic/WeakCanonical/Transfer.lean:1179` | "…is now **sorry**-free…" — sorry-line |
| 10 | `Metalogic/WeakCanonical/Transfer.lean:1274` | "-- Replaced with direct **sorry**…" — sorry-line |
| 11 | `…/Kamp/Boneyard/NfMultiAnchorBridgeRetired/EndIntervalSkeleton.lean:102` | "…v6; **sorry**-free…" — sorry-line |
| 12 | `…/Kamp/Boneyard/NfMultiAnchorBridgeRetired/Lemma32Reduction.lean:15` | "…two green, **sorry**-free refutations…" — sorry-line |
| 13 | `Boneyard/DeadConvergenceProof/succ_cofinal_convergence.lean:371` | "…which bypasses this **sorry**." — sorry-line |
| 14 | `Theorems/TemporalDerived.lean:81` | `- Task 173: Archive of 27 **sorry**-tainted definitions` — sorry-line |

**On #14 specifically**: it is a References bullet whose three sibling task-number bullets *were*
deleted as pure pointers beneath the durable `- Burgess 1982/84` citation. Being a sorry-line, it
survives as a visibly stranded task-number bullet directly under that citation. That asymmetry is
the honest forced outcome of the guard, not an oversight — it should not be "tidied" without a
supervised decision to touch a sorry-line.

A guard subtlety worth carrying forward: the guard matches the **lowercase substring `sorry`**.
Capitalised `SORRY`, `Sorry-free`, and the plural `sorries` (s-o-r-r-i-**e**-s) do not trip it, so
several such prose lines were legitimately edited in Phases 6-7 with the census staying exact.

## Also Permanently Deferred: `MergedBracketQuarantine.lean:712/:713`

`Boneyard/MergedBracketQuarantine/MergedBracketQuarantine.lean:712` and `:713` are the two halves
of a single two-item citation pair inside one sentence, and **`:713` is a sorry-line** ("No sorry
on any live path"). Cleaning `:712` alone would leave a half-de-pathed pair reading
"(the spawn analysis; literature-alignment audit `specs/320_.../…md`)". Both are therefore left
**byte-identical**. This is a hard constraint, not a judgment call: the never-touch-sorry-lines
rule admits no exception, and mangling half a citation to satisfy a looser secondary pattern would
be strictly worse than leaving the pair intact. These two lines are the entire remaining
population of the loose `specs/[0-9]{3}_` pattern; the script's strict path pattern is at 0.

## Authorized Non-Comment Exceptions: 6 String Literals in 2 Files

The task is comment/docstring-only by constraint. Six matches sat inside **runtime output string
literals**, which the comment-span assertion correctly refused to auto-edit. Phase 6 escalated
them rather than silently skipping; the user authorized a narrow exception with an explicit
policy — *"Use durable anchors if appropriate, else remove entirely. Each should be reworked
individually as appropriate."* Each site was judged on its own merits, not find-replaced:

| Site | Treatment | Rationale |
|---|---|---|
| `Decidability/Saturation.lean:855` | removed entirely | the adjacent comment block (`:846-849`) already carries the full explanation, so an anchor would only duplicate it |
| `Decidability/Saturation.lean:856` | removed entirely | same fold as `:855` |
| `Decidability/Saturation.lean:865` | durable in-file anchor | MT4's adjacent comment points nowhere, so "see the blocking-termination status section" earns its place → this file's own `### Blocking termination: known issues and status` |
| `Decidability/Saturation.lean:866` | durable in-file anchor | same fold as `:865` |
| `Automation/EnumBenchmark.lean:175` | removed entirely (`, task 204` dropped) | the durable payload is the measured fractions and the random-vs-exhaustive contrast, which is self-describing; an attribution adds nothing to a benchmark note |
| `Automation/EnumBenchmark.lean:200` | removed entirely (parenthetical dropped whole) | a title banner/section divider; any anchor here would be noise |

Blast radius: `#eval`/CLI diagnostic banners with no programmatic consumer (no test asserts on the
text). Verified after editing: `#eval` logic, match arms, and surrounding code are byte-stable
(comment-stripped code line counts unchanged, 169→169 and 838→838); `Saturation.lean` remains
sorry-free; `EnumBenchmark.lean` elaborates with 0 errors and 0 warnings. These are reported here
as authorized exceptions precisely so they do **not** silently become a permanent exemption.

## Decisions

- **Category-(d) `VERIFY` policy**: rather than "correcting" a stale status pointer into a new
  claim that would rot again, `VERIFY` entries were re-anchored to durable *descriptors* unless
  the claim could be verified live at edit time. Two claims were verified and therefore
  *strengthened* to declaration names (`ProofSystem/Axioms.lean:38`/`:74` →
  `temp_k_dist_derived`, `temp_4_derived`).
- **Two pointers were not merely stale but FALSE**, and were corrected to verified truth:
  (i) `Saturation.lean:960` claimed "proofs are deferred" on a file that is entirely sorry-free
  and whose "theorem stubs" are proved outright (`subformula_property:996`,
  `blocking_sound:1212`); (ii) `Frame.lean:657` cited `Filtration/SigmaOrdering.lean`, a file that
  does not exist — it had been retired to `Boneyard/FiltrationOrdering/SigmaOrdering.lean`.
- **Heading disambiguation over deletion** (Settled decision 6): where a task number was the only
  disambiguator between sibling headings, rewrites produced distinct content-based headings. Phase
  7 caught a Phase-2 auto-drop that had collapsed three `Formula.lean` headings into exact
  duplicates and fixed all three; a tree-wide duplicate-heading check against `7c6c2d148`
  confirmed no duplicates were introduced anywhere.
- **Boneyard descriptor substitution**: where `task-NNN` was the SOLE disambiguator between
  sibling archived artifacts, a bare drop would have destroyed information, so the file's own
  durable descriptor was substituted. This is descriptor substitution, not the prose curation the
  Boneyard stance forbids — no archival narrative, date, or verdict was rewritten.
- **Pure-pointer References bullets were deleted** when sitting beneath a durable sibling citation
  (GHR93 / Burgess / Goldblatt / Doets / Reynolds / Rabinovich) with no other substance (~14
  sites); bullets that carried real content were restated inline instead. One entire References
  section was deleted (`FormulaEnumerator.lean`) because every bullet was such a pointer and the
  content was already stated in "## Design Decisions".
- **Isolated non-matching ephemera were left in place by decision, not oversight** — they match
  neither the sweep pattern nor `specs/[0-9]{3}_`: `specs/098/reports/…` bullets
  (`BigConj.lean:24`, `Boneyard/BXCanonicalQuasimodel/EnrichedClosure.lean:32`), `specs/305 report
  40` (`CarrierK1V.lean:34`), bare route numbers in Boneyard prose ("the 358 countermodel slice",
  "pre-363 revision", "358-dischargeability"), and elided paths lacking a trailing word character.
  A future reader should know this class was considered.

## Hook Escalation: Recommendation Only (Settled decision 4)

The task description raised escalating `.claude/hooks/validate-no-task-references.sh` from
advisory to blocking as **CONSIDER — raised, not decided**. **The hook's severity was not changed
by this task**, and this section is a recommendation for a follow-up meta task. Rationale for not
implementing it here: it is `.claude/` infrastructure requiring a new `PreToolUse` registration in
`settings.json` (meta territory, not lean4), and landing a blocking hook mid-history would
complicate rollback of this sweep.

### Recommendation: escalate, but only with a sorry-line exemption and path scoping

**A naive escalation would be permanently broken.** The current hook is `PostToolUse` and scans
the written content with `\b[Tt]asks?[[:space:]]+[0-9]+(-[0-9]+)?\b` (case-insensitively),
exempting `specs/**`. On the final tree that regex matches **13 lines**, and the recommended
hyphen-aware regex matches **14 — every one of them an immovable sorry-line** in 9 `Theories/`
files. Any Write/Edit touching those files would trip a blocking hook forever, because the *only*
way to satisfy it is to violate the never-touch-sorry-lines rule. **This is not a hypothetical
false-positive estimate: it is a measured 100% false-positive rate on the residual set.**
Escalation therefore **requires** one of the two carve-outs below, and the choice should be
explicit rather than discovered in production:

1. **Sorry-line exemption (recommended)**: when the matching line also contains `sorry`, do not
   deny. This is exactly the guard the sweep script already implements, it is self-maintaining as
   sorries are discharged, and it keeps the deny surface at 0 lines on the current tree.
2. **Path allowlist**: exempt the 9 files, or exempt `Boneyard`/`Retired` paths plus the specific
   live files. Discouraged — it is a static list that rots as files move, which is the exact
   failure mode this task exists to fix.

Concrete proposal for the follow-up task:

- **New `PreToolUse` registration on Write/Edit** — the existing hook is `PostToolUse` and
  structurally *cannot* prevent a write, so escalation is a new registration, not a severity flag
  flipped on the current script. Keep the existing `PostToolUse` advisory in place for all other
  paths.
- **Scope the deny to `Theories/**/*.lean`.** This sweep proves that scope is now clean apart from
  the 14 exempted sorry-lines. Do not scope it repo-wide: ~45 `.claude/` files legitimately
  discuss task numbers (agent/skill documentation about the task system itself), and — a data
  point this task surfaced — **`lakefile.lean` carries ~12 task-number references in `lean_exe`
  doc comments** and is outside this sweep's scope. A repo-wide blocking hook would fire on the
  build file on day one.
- **Pattern**: `\btasks?([[:space:]]+|-)[0-9]+(-[0-9]+)?\b`, **case-insensitive**. Two corrections
  to the current pattern, both empirically motivated by this sweep:
  - *Hyphen-aware.* The current pattern misses the hyphenated adjectival forms (`task-363`,
    `task-355`) that this sweep found in quantity — including one of the 14 residuals. Written as
    an alternation of "whitespace or hyphen" rather than a character class, to avoid widening to
    `task -320`.
  - *Case-insensitivity is load-bearing, not cosmetic.* The `-i` flag is what would have caught
    `TASK 344`, the one reference this task's own case-sensitive tooling missed across seven
    phases. Keep it.
  - *Keep the digit requirement.* Dropping it to match a bare `\btasks?\b` would false-positive on
    ordinary English: `MergedBracketQuarantine.lean` contains two `WHOLE-TASK NO-GO` verdicts that
    are not references at all.
- **False-positive risk in `Theories/`, excluding the sorry-line residuals: zero, measured.** The
  semantics vocabulary of this project (task frames, task-frame semantics — the "T" in TM) never
  carries a trailing numeral, so the domain term cannot collide with a digit-requiring pattern.
  After the exemption, the recommended pattern's deny surface on the current tree is **0 lines**.

### Supporting evidence that a *blocking* gate is worth its cost

The failure mode is not cosmetic staleness — the sweep found in-code pointers that were actively
misleading, the class of defect that caused this task's ROOT CAUSE (three rounds of wasted work):

- **Phase 6 found two pointers that were not merely stale but FALSE**: a "proofs are deferred"
  note on a file that is entirely sorry-free with the theorems in question proved outright, and a
  citation to `Filtration/SigmaOrdering.lean`, a path that does not exist because the file was
  retired to `Boneyard/`. A reader trusting either would have drawn a wrong conclusion about
  project state.
- **Phase 7 found that a Phase-2 automated drop had collapsed three `Formula.lean` headings into
  exact duplicates** — i.e. the task numbers were load-bearing as disambiguators, and removing
  them mechanically destroyed navigability. A blocking gate must therefore be paired with the
  Settled-decision-6 discipline (disambiguate by content, never leave duplicates); a hook that
  only denies text will push authors toward exactly this failure unless the rule file states the
  positive obligation. **Recommend the follow-up task also add a duplicate-heading check** to the
  advisory hook, since that is the specific damage a de-numbering reflex causes.
- **The advisory hook's regex was stricter than this task's purpose-built tooling.** The sweep
  script's pattern is case-sensitive and therefore never saw `TASK 344` at
  `SharedWitness.lean:11516`; the hook greps `-i` and would have flagged it on the write that
  introduced it. A one-off sweep inherits whatever blind spot its author's regex has; a standing
  gate is the thing that catches the next variant. This is the single most direct piece of evidence
  in favour of escalation.
- Even the sweep's *own* residual is instructive: the stranded `Task 173` bullet at
  `TemporalDerived.lean:81` sits under a durable Burgess citation whose three siblings were
  removed. A blocking hook without the sorry-line exemption would make that line unfixable *and*
  unignorable.

## Impacts

- `Theories/**/*.lean` is now free of task-number pointers apart from 14 constraint-locked
  sorry-lines; provenance that mattered survives as declaration names, `file:line` citations,
  section headings, and PDF page references.
- No semantic impact: 7,316 declarations unchanged, census 906/820/26 exact, 2 axioms, build
  EXIT 0. Comment-stripped code is byte-identical for 428/430 files; the 2 exceptions are 6
  authorized diagnostic-string payloads.
- Reusable tooling is archived under `specs/380_.../scripts/`: the span-aware rewriter with its
  `--check-diff` comment-span assertion is directly reusable for future de-pathing sweeps, and its
  parser is what made the lake-independent code-identity proof possible for the 60 Boneyard
  modules no lake target compiles.
- `worklists/baseline.md` no longer propagates a false warning baseline.

## Follow-ups

1. **Meta task — hook escalation** (recommendation above is written to be one-shot): new
   `PreToolUse` deny scoped to `Theories/**/*.lean`, hyphen-aware pattern, **mandatory sorry-line
   exemption**, existing `PostToolUse` advisory retained elsewhere. Include the duplicate-heading
   check.
2. **Supervised decision, optional**: whether to permit a narrowly-scoped exception to the
   never-touch-sorry-lines rule for *prose-only* `sorry` mentions. That single decision would
   unlock all 14 residual lines plus the `MergedBracketQuarantine` pair. It must be made
   deliberately, with the census invariant re-established on a different basis first — not folded
   into an editing phase.
3. **Out of scope here, worth a separate pass**: `lakefile.lean`'s ~12 task-number references in
   `lean_exe` doc comments, and the `.claude/`-adjacent files where task numbers are legitimate
   but occasionally stale.
4. **Note for whoever next edits the exe-only or Boneyard modules**: `lake build` does not
   elaborate them. Use `lake env lean <file>` for the 12 exe-only modules; the 60 Boneyard modules
   are in no lake target at all.
5. **Method note for any future de-referencing sweep**: run the gate pattern **case-insensitively**
   and **hyphen-aware**, and cross-check with a second, independently-written pattern before
   declaring a count. This sweep's case-sensitive gate reported clean on a file that still carried
   a reference, and its space-only variant missed the hyphenated forms; the two blind spots were
   only caught by differencing the pattern variants against each other in Phase 8.

## Plan Deviations

- **Phase 8 edited two files under `Theories/`** (5 lines total), where the plan anticipated "no
  `Theories/` edits expected". All three sites fall under the plan's own sanctioned straggler
  micro-repeat provision: the 2 user-authorized `EnumBenchmark.lean` string literals;
  `SharedWitness.lean:9-10` (a comment-only loose-`specs/`-path straggler in Phase-3 territory,
  cleaned per Phase 3's durable-anchor style — the plan/report paths were replaced with the
  design-route descriptors they named); and `SharedWitness.lean:11516` (the all-caps `TASK 344`
  banner exposed by the case-insensitive rescan). `SharedWitness.lean`'s line count is unchanged
  (12,800 → 12,800), so not even its 109 pre-existing warning line numbers moved.
- **`git-snapshot.sh` was not run before Phase 8's first write** (continuing the Phase-5/6/7
  pattern). The pre-edit state was recoverable throughout from the clean `460f88a18` tree, the
  edits total 5 lines, and every gate passed on the first attempt, so no rollback was needed.
  Additional reason specific to this phase: the helper's stash reverts the working tree, which
  would have discarded the in-flight plan-status edit.
- **A full from-scratch `lake build` was not performed.** The build that ran replays every module's
  cached log (1,024 warning lines across the tree), so the warning inventory is genuinely
  tree-wide rather than restricted to invalidated modules; combined with the code-identity proof,
  a from-scratch rebuild would add no information about this sweep.
- **`lake build enum_benchmark` was started and abandoned** in favour of `lake env lean` after it
  began native-compiling the entire import closure (clang on `Formula.c` after 11 minutes).
  Elaboration, not native codegen, is the relevant gate for a comment/string edit.
- **The dispatch brief's "1,362 original" figure was not used**; the measured baseline of 1,549 is
  reported instead, with the discrepancy documented above.
- All plan Phase-8 checklist items were completed as written; no item was skipped or deferred.

## References

- `specs/380_sweep_stale_task_number_pointers_from_lean_sources/plans/01_pointer-sweep-plan.md`
- `specs/380_sweep_stale_task_number_pointers_from_lean_sources/reports/01_pointer-sweep-inventory.md`
- `specs/380_sweep_stale_task_number_pointers_from_lean_sources/worklists/baseline.md` (corrected)
- `specs/380_sweep_stale_task_number_pointers_from_lean_sources/worklists/counts.md`
- `specs/380_sweep_stale_task_number_pointers_from_lean_sources/scripts/rewrite_task_refs.py`
- `specs/380_sweep_stale_task_number_pointers_from_lean_sources/handoffs/phase-7-handoff-20260724.md`
- `.claude/rules/no-task-references-in-deliverables.md`
- `.claude/hooks/validate-no-task-references.sh` (unchanged by this task)
