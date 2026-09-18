# Research Report: Task #588

**Task**: 588 - Triage the zero-occurrence declarations C17 reports
**Started**: 2026-09-17T00:13:46Z
**Completed**: 2026-09-17T00:52:00Z
**Effort**: ~40 minutes (mechanical census + cluster inspection)
**Dependencies**: 585 (warning burn-down, already landed — see census delta below), 591 (Automation renames)
**Sources/Inputs**:
- `scripts/check-module-invariants.sh` lines 2493-2600 (the C17 implementation)
- `bash scripts/check-module-invariants.sh --no-build` (live C17 output)
- `specs/588_triage_zero_occurrence_declarations/reports/01_dead-declaration-triage.md` (pre-research sweep evidence)
- `specs/reviews/review-2026-09-16.md`, Finding L1
- `lakefile.toml` (library/executable roots), `FormalSystem/Automation/NormalizationAttr.lean`,
  `FormalSystem/Automation/Normalization.lean`, `FormalSystem/Boneyard/RetiredTactics/Normalization.lean`,
  `Tests/BimodalTest/Automation/NormalizationTest.lean`
**Artifacts**:
- `specs/588_triage_zero_occurrence_declarations/reports/02_c17-zero-occurrence-triage.md` (this report)
- `specs/588_triage_zero_occurrence_declarations/tools/c17_triage.py` (stratifier; reproduces C17 exactly)
- `specs/588_triage_zero_occurrence_declarations/tools/c17_census.tsv` (1,020 rows, one per flagged declaration, tiered)
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **The census is now 1,020, not 1,029** (10,850 real declarations scanned). The stratifier in
  `tools/c17_triage.py` reproduces C17's count exactly, so every number below is measured, not estimated.
- **The known false-positive classes explain only 21% of the census.** Filtering parse artifacts,
  `instance`, `@[simp]`, the custom simp sets, and references from files C17 does not scan removes
  228 of 1,020. **792 declarations survive every mechanism known to defeat a textual scan** — and
  704 of those are plain, unattributed `theorem`s, for which Lean offers no indirect reachability
  path at all. The dispatch's expectation that mechanical filtering "may cut the list substantially"
  does not hold; the bulk of C17's census is real.
- **A safety finding the task description does not anticipate: 7 flagged declarations are pinned by
  name inside `scripts/check-module-invariants.sh` itself** (the C2/C14 `#print axioms` baselines),
  and 5 more are cited in `typst/chapters/*.typ`. C17's occurrence corpus covers `.lean` and `.md`
  but not `.typ` or `.sh`, so deleting on the raw list would break the very invariants the task's
  verification clause requires to stay unmoved.
- **The disputed `release_unfold` reading resolves against the review, and the Boneyard hypothesis
  is false.** `Boneyard/RetiredTactics/Normalization.lean` contains **zero** references to any of
  the 12 flagged `*_fold`/`*_unfold` names. The `formula_unfold`/`formula_fold` families have 31
  members; C17 flags 12 and spares 19 purely because the other 19 have `#check @...` rows in
  `Tests/BimodalTest/Automation/NormalizationTest.lean`. The split tracks test bookkeeping, not usage.
- **An independent, stronger deadness signal exists and is not measured anywhere: 10 live
  `FormalSystem/` modules (~91 declarations) are not import-reachable from any `lakefile.toml` lib or
  exe root.** Only 10 of C17's rows fall inside them, because their declarations reference each other.
- **Do not tighten C17's occurrence corpus.** Counting only comment-stripped Lean code (dropping
  markdown and docstrings) takes the census from 1,009 to 1,827: 818 declarations are currently
  kept alive by prose mentions alone.

## Context & Scope

C17 is a reporting-only, explicitly approximate census in `scripts/check-module-invariants.sh`. For
each declaration in non-Boneyard `FormalSystem/**/*.lean` it tokenises the base identifier (last
dot-segment) and counts occurrences across `FormalSystem/` + `Tests/` `.lean` files plus every
repo `.md` file, excluding `.git/.lake/specs/Boneyard/build/__pycache__`. A declaration whose base
identifier appears on no other line anywhere is reported.

Scope of this research: characterise the 1,020, quantify the attribute/simp-set blind spot that
the absorbed dead-declaration-triage task required as an early step, resolve the `release_unfold`
dispute, and specify a durable extension to C17's counting rule. Deletion is explicitly out of
scope for the research phase; this report delivers the classification the plan phase executes from.

Lean MCP tooling (`lean-lsp`) failed to connect this session (`CONNECT_TIMEOUT` after 30s), so no
`lean_goal` / `lean_hover_info` / Mathlib search calls were made. None were needed: every question
here is a reachability question answerable from the source tree and the build configuration, and
the one external check that mattered — that the stratifier agrees with the harness — was made by
running the harness itself.

## Findings

### F1. Census stratification (measured)

`python3 specs/588_triage_zero_occurrence_declarations/tools/c17_triage.py --summary`:

| Tier | Count | Mechanism that defeats the textual scan |
|------|------:|------------------------------------------|
| T0 parse artifact | 11 | C17's decl regex matched a line **inside a comment** |
| T1 `instance` | 48 | reached by typeclass resolution, never by name |
| T2 `@[simp]` | 145 | reached through the default simp set |
| T3 custom simp set | 12 | `@[formula_fold]` / `@[formula_unfold]` |
| T4 corpus-external | 12 | referenced from `typst/**/*.typ` (5) or `scripts/*.sh` (7) |
| **SURVIVOR** | **792** | **none known** |

Survivor composition: 704 `theorem`, 81 `def`, 6 `structure`, 1 `abbrev`. Sub-signals within the
survivors: 47 are referenced only from `FormalSystem/Boneyard/` (comment-stripped, so real code
references); 6 sit in import-orphan modules (F5).

### F2. T0 is small in the census but large in the denominator

The C17 decl regex matches `raw.strip()` with no comment awareness, so a docstring continuation
line such as `lemma premises. -/` parses as a `lemma` named `premises.`, whose base (last
dot-segment) is the empty string — which never occurs anywhere, so it is always "dead". Eight of
the 11 T0 rows have an empty base for exactly this reason (`premises.`, `field.` ×2, `alone.`,
`order.`, `cache.`, `supplies.`).

The census effect is only 11 rows, but the **denominator** effect is 196: C17 reports 11,046
declarations scanned where only 10,850 are real. C19 and C23 share this regex and inherit the same
phantom declarations.

### F3. T4 — the load-bearing false positives (highest risk in the whole census)

C17's occurrence corpus is `.lean` + `.md`. It does not scan `.typ` or `.sh`. Twelve flagged
declarations are referenced from files outside that corpus:

| Declaration | Declared at | Referenced from |
|---|---|---|
| `soundness_setConsequence` | `FormalSystem/Metalogic/StrongCompleteness.lean:319` | `scripts/check-module-invariants.sh:1579` (C14 baseline) |
| `setConsequence_iff_not_satisfiable` | `FormalSystem/Metalogic/SetConsequence.lean:349` | `scripts/check-module-invariants.sh:1622` |
| `satisfiableSet_iff_finitelySatisfiable` | `FormalSystem/Metalogic/SetConsequence.lean:335` | `scripts/check-module-invariants.sh:1623` |
| `modelExistence_iff_finitelySatisfiable` | `FormalSystem/Metalogic/SetConsequence.lean:325` | `scripts/check-module-invariants.sh:1436, 1624` |
| `tmFrag_complete_dense` / `_ztime` / `_rtime` | `FormalSystem/Metalogic/Conservativity/Fragment.lean:121, 126, 131` | `scripts/check-module-invariants.sh:1649-1651` |
| `getProof` | `FormalSystem/Metalogic/Decidability/DecisionProcedure.lean:138` | `typst/chapters/p2-decidability-practice.typ:84` |
| `int_nullity_example`, `generic_nullity_example`, `int_compositionality_example`, `generic_compositionality` | `FormalSystem/Examples/TemporalStructures.lean:440, 446, 453, 468` | `typst/chapters/p4-dual-verification.typ:71` |

The seven `check-module-invariants.sh` names appear in the C2/C14 `#print axioms` heredocs.
Deleting any of them makes the axiom-baseline checks fail to elaborate — the exact regression the
task's verification clause forbids. This class is invisible on the raw C17 output.

### F4. `FormalSystem/Examples/` is a sixth false-positive class

25 census rows (21 survivors + 4 T4) are in `FormalSystem/Examples/`. Inspection of
`TemporalStructures.lean` confirms these are pedagogical demonstrations — `intTimeFrame_serial`,
`int_compositionality_example`, `genericNatFrame_saturation`, and siblings — declared so a reader
can see a frame instantiation satisfy each constraint. They are documented as such in the module
header ("This module provides examples demonstrating the use of different temporal types"), the
module is imported by `FormalSystem/Examples.lean` and by `Tests/BimodalTest/Semantics/TaskFrameTest.lean`,
and four of them are cited in the Typst manual. "Nothing calls it" is the intended state.

### F5. Import-orphan modules — a stronger signal C17 barely sees

Walking `import` edges from every `lakefile.toml` root (`FormalSystem`, `BimodalTest`, and the 12
`lean_exe` roots), 10 of 527 live modules are unreachable:

| Module | Lines | Declarations |
|---|---:|---:|
| `FormalSystem/Metalogic/Decidability/BiLasso/Orbit.lean` | 916 | 52 |
| `FormalSystem/Metalogic/Decidability/BiLasso/Successor.lean` | 137 | 12 |
| `FormalSystem/Metalogic/Decidability/BiLasso/Extend.lean` | 120 | 10 |
| `FormalSystem/Automation/ProofFirstBenchmark.lean` | 189 | 9 |
| `FormalSystem/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/OuterGateFaithful.lean` | 250 | 4 |
| `FormalSystem/Metalogic/Decidability/BiLasso/Agreement.lean` | 175 | 3 |
| `FormalSystem/Metalogic/SoundnessLemmas/CoValidity.lean` | 112 | 1 |
| `FormalSystem/Metalogic/Bundle.lean`, `Metalogic/Core.lean`, `Metalogic/SoundnessLemmas.lean` | 119 | 0 (aggregators) |

Roughly 91 declarations, none of which are compiled by `lake build` or reachable by any consumer.
C17 surfaces only 10 of them, because declarations inside an orphan module reference each other and
so never reach zero occurrences. This is a cheaper, categorical signal than C17's textual
approximation, and it is currently measured by nothing. (`lake exe checkInitImports` checks a
different property — whether modules import `FormalSystem.Init` — not root reachability.)

### F6. The `release_unfold` dispute, resolved

`FormalSystem/Automation/NormalizationAttr.lean` registers four simp sets via `register_simp_attr`:
`formula_unfold`, `formula_fold` (plus `truth_norm`, `swap_norm` in `TruthNormAttr.lean`).

- `truth_norm` is genuinely live: ~30 `simp only [truth_norm]` call sites in
  `FormalSystem/Metalogic/Soundness.lean`. No member is flagged.
- **`formula_unfold` (21 members) and `formula_fold` (10 members) have zero `simp only [...]` call
  sites anywhere in `FormalSystem/`.** The only invocations in the repository are seven lines in
  `Tests/BimodalTest/Automation/NormalizationTest.lean` and eight retired tactic macros in
  `FormalSystem/Boneyard/RetiredTactics/Normalization.lean` (`modalNorm`, `propNorm`, `modalOpNorm`,
  `temporalNorm`, `modalNormAt`, `modalNormAll`, `modalFold`), archived 2026-09-07.
- **The dispatch's Boneyard hypothesis is false.** Those retired macros reference `formula_unfold`
  as a *set* and 16 individual `*_unfold` lemmas by name — `neg_unfold`, `top_unfold`, `and_unfold`,
  `diamond_unfold`, and so on. **None of the 12 flagged names appears in the Boneyard at all**
  (verified per-name; all zero). They were never the retired macros' named consumers.
- **The 12/19 split is test bookkeeping, not usage.** The 19 spared members are spared because
  `NormalizationTest.lean` carries `#check @FormalSystem.Automation.Normalization.<name>` rows (and
  some fully-qualified `simp only [...]` / `rw [← ...]` lines) for them. `top_unfold`'s *only*
  non-declaring occurrence in the entire repository is one `#check` row. The 12 flagged members are
  the ones nobody wrote a `#check` for. Semantically all 31 have identical status: reachable only
  through a simp set whose sole live consumer is one test file.

The current line numbers are 146/150/154/158 and 523-557, not the 146-776 range in the task
description; `all_future_fold` and `all_past_fold` have joined the flagged set (12, not 10) since
the review was written.

### F7. Do not tighten the occurrence corpus

Re-running the census with a comment-stripped, code-only corpus (Lean code only, no markdown, no
docstrings) yields **1,827 dead** against 1,009 — 818 declarations are held alive solely by prose.
The `Boneyard/RetiredTactics/README.md` retirement criterion ("real invocations, not docstring
mentions") is the stricter rule, and it is the right rule for a *hand* retirement decision, but
applying it to the automated census would make the number less actionable, not more.

## Decisions

- **D1 — `formula_unfold` / `formula_fold` count as live.** Decided here rather than deferred: the
  codebase answers it. `NormalizationAttr.lean` exists as a separate module for the sole purpose of
  registering these two attributes, carries a docstring explaining the fold/unfold round-trip
  design, and a dedicated test file exercises both directions. That is a deliberately maintained
  public API surface, not residue. The 12 flagged members are kept. The correct unit of any future
  retirement decision is the whole 31-member family plus both `register_simp_attr` declarations —
  never the 12.
- **D2 — C17 stays reporting-only.** Non-goal per the task and per the harness's own comment; a
  textual approximation with a 21% known-false-positive rate must not gate a build.
- **D3 — C17's occurrence corpus is not narrowed** (F7), but it **is widened** to `.typ` and
  `scripts/*.sh` (F3).
- **D4 — T4 rows are excluded from every deletion batch, unconditionally**, and the C17 filter
  extension must make them stop being reported at all, so no future reader re-discovers them the
  hard way.
- **D5 — `FormalSystem/Examples/**` is excluded from C17's declaration scope** (F4), on the same
  footing as `#guard`/`example` smoke tests: the directory's contract is to be read.

## Recommendations

Prioritised; R1 is the durable deliverable the task description flags as most valuable.

1. **Extend C17's counting rule permanently** (edit `scripts/check-module-invariants.sh`, ~line
   2493, and document the new rule in its header and in `docs/development/MODULE_INVARIANTS.md`):
   - comment-strip each line before matching the decl regex, and skip lines inside `/- -/` blocks
     (fixes T0, and removes 196 phantom declarations from the scanned-count denominator that C19
     and C23 also inherit);
   - add `typst/**/*.typ` and `scripts/*.sh` to the occurrence corpus (fixes T4 — the C2/C14
     baseline anchors and the manual citations);
   - exclude `instance` declarations (T1);
   - exclude declarations carrying `simp` or any attribute registered via `register_simp_attr`,
     **discovered by scanning for `register_simp_attr` rather than hardcoding the four names**, so a
     future simp set is covered automatically (T2 + T3);
   - exclude `FormalSystem/Examples/**` from the declaration scope (F4);
   - report "flagged in live code but referenced from `Boneyard/`" as a separate sub-count rather
     than folding it into the headline.

   Expected reported count: **1,020 → 771**, with a **47** Boneyard-only sub-count alongside it.
   `tools/c17_triage.py` implements all six filters already and can be lifted more or less directly.

2. **Add a new import-reachability check** for orphan modules (F5). 10 modules, ~91 declarations,
   categorical rather than approximate, and cheap — an import-graph walk from the `lakefile.toml`
   roots. This is the highest-confidence dead code in the repository and nothing currently reports
   it. It can gate, unlike C17, once the existing 10 are dispositioned.

3. **Triage the 792 survivors by cluster, in this order** (each is a self-contained plan phase
   sized to one agent run):
   - the 6 orphan-module survivors, as part of R2's disposition of all 10 modules;
   - the 47 Boneyard-only-referenced survivors — "the only consumer is archived" is a retire-to-
     Boneyard decision, not a delete decision, and the 10 in
     `FormalSystem/Syntax/SubformulaClosure/TemporalFormulas.lean` are one cluster, not ten;
   - the **81 `def` survivors** — the highest-confidence deletions in the census. Inspection shows
     dead API surface with no indirect-reachability story at all: `DecideCache.hitRate`,
     `ProofExtractionStats`, `TableauStats`, `countPotentialContradictions`, `countNegatedAxioms`,
     `patternStats`, `branchUnexpandedComplexity`, and 13 more in
     `Metalogic/Decidability/SignedFormula.lean` alone;
   - the 704 `theorem` survivors, by file cluster, largest first
     (`Syntax/SubformulaClosure/TemporalFormulas.lean` 18, then the three
     `BXCanonical/Chronicle/*` files at 16 each, `Decidability/SignedFormula.lean` 13).

4. **Execute only unambiguous clusters in this task; spawn follow-ups for the rest.** Re-run
   `tools/c17_triage.py` after each batch — line numbers in the census go stale on the first edit,
   and the accounting the task requires is per-line.

5. **Record the `@[simp]` overlap rather than silently absorbing it.** Excluding T2's 145 rows from
   C17 hides declarations that may be genuinely unused simp lemmas; that population belongs to the
   unused-simp burn-down work, not here. Note the handoff explicitly so the two efforts do not each
   assume the other covers it.

## Risks & Mitigations

- **Deleting a T4 row breaks C2/C14.** Seven names are pinned inside the invariant script itself.
  Mitigation: R1 removes them from the report; until then, the plan must diff any deletion batch
  against `grep -F -f <names> scripts/check-module-invariants.sh`.
- **C15 paper anchors are partly outside C17's corpus.** Anchors in `.md` are counted, but the Typst
  reference manual is not scanned at all. R1's `.typ` addition closes this; without it, a deletion
  batch can silently break a manual citation.
- **`instance` exclusion can hide a genuinely unused instance.** Accepted: for a never-gating census
  the safe direction of error is under-reporting, consistent with C17's existing same-base-name
  policy.
- **Census line numbers are volatile.** Every edit invalidates the TSV. Mitigation: the census is
  regenerable in seconds; treat `tools/c17_census.tsv` as a snapshot, never as an input to a second
  batch.
- **Zero-debt compliance.** Nothing in this plan introduces `sorry` or an axiom: every recommended
  change is a deletion, a script filter, or a new reporting check. If a survivor turns out to be
  load-bearing when removed, the correct response is to keep it and record why, not to stub it.

## Tactic Survey Results

- Not applicable (no tactic survey performed). This task contains no proof goals; it is a
  reachability census over the source tree and build graph.

## Context Extension Recommendations

- **Topic**: Indirect reachability mechanisms in Lean 4 that defeat textual dead-code scans.
- **Gap**: `.claude/context/project/lean4/` documents MCP tooling and hard-mode routing but has
  nothing on *why* a declaration can be live with zero textual references. This research
  re-derived the list from scratch (typeclass resolution, default and registered simp sets, aesop
  rule sets, `deriving` handlers, `attribute [...]` applied at a distance, `lean_exe` roots,
  pedagogical `Examples/` declarations, and non-Lean citation corpora such as Typst and shell
  invariant scripts).
- **Recommendation**: add `.claude/context/project/lean4/patterns/indirect-reachability.md`
  capturing that enumeration plus the finding that the exhaustive filter set still leaves ~78% of
  this repository's textual census standing — so the next reader starts from the measurement rather
  than from the assumption that filtering will do the work.

## Appendix

- Reproduce the census: `python3 specs/588_triage_zero_occurrence_declarations/tools/c17_triage.py --summary`
  (full TSV on stdout without `--summary`). Verified to match
  `bash scripts/check-module-invariants.sh --no-build | grep C17` exactly at 1,020.
- C17 implementation: `scripts/check-module-invariants.sh:2493-2600`.
- Simp-set registrations: `FormalSystem/Automation/NormalizationAttr.lean:36,44`;
  `FormalSystem/Automation/TruthNormAttr.lean:51,57`.
- Retired tactic macros that consumed `formula_unfold`:
  `FormalSystem/Boneyard/RetiredTactics/Normalization.lean:45-90`.
- C2/C14 axiom baseline heredocs: `scripts/check-module-invariants.sh:1425-1660`.
- Aesop rule attributes in live code (none flagged by C17):
  `FormalSystem/ProofSystem/Derivable.lean:121-173`.
