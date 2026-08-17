# Implementation Plan: Guard-First Migration of `snce`/`untl`

- **Task**: 448 - Migrate the Lean tree's `snce`/`untl` constructors from EVENT-FIRST (Burgess) to GUARD-FIRST (paper) argument order
- **Status**: [IMPLEMENTING]
- **Effort**: 19 hours
- **Dependencies**: None
- **Research Inputs**: `specs/448_migrate_snce_untl_to_guard_first_order/reports/01_guard-first-migration-strategy.md`
- **Artifacts**: plans/01_guard-first-migration.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Swap the argument order of `Formula.untl` and `Formula.snce` from event-first to guard-first so
the Lean tree agrees with `def:BLplus-semantics` and with the already-guard-first Typst manual.
The spine is the research report's **rename-forced migration**: rename the constructors at the
same moment as the swap so every unmigrated reference becomes a hard compiler error, mechanically
rewrite the tree, repair module-by-module in topological order, audit the definitional sites
against a role-keyed JSON oracle, then lexically rename back. The migration is meaning-preserving
by construction — no phase may introduce a `sorry`.

The dominant cost is build time: `Formula.lean` is the DAG root, so every touch invalidates the
whole tree (~379 oleans, 60-90 min per full cycle). Phases are sized so that full-build cycles
are spent exactly three times (Phase 8 green build, Phase 10 rename-back build, Phase 10 final
verification build) rather than once per repair round; intermediate repair phases build to
scoped module targets only.

### Research Integration

Adopted from the research report: the rename-forced strategy (§5.2), the rejection of the
smart-constructor alternative (§5.1, blocked because `@[match_pattern]` cannot serve as an
`induction … with | untl …` case label and 540 sites are exactly that), the four confirmed
defects in `scripts/swap_untl_snce.py` (§5.3), the derived-operator swap table (§4), the
swap-invariant function list (§4.1), the `DataExport.toJson` role-keyed oracle (§6), and the
third stale artifact at `specs/paper-definitions-of-record.md:573-600` (§2.3).

**Three measured corrections to the research report**, each resolved in the Decisions section
below and each changing the plan's shape:

1. **Boneyard is NOT compiled.** The report's Open Question 3 asserts `FormalSystem/Boneyard/` is
   "inside the default build target and therefore must migrate". Measured: 0 of 379 built oleans
   lie under any `Boneyard` path; no non-Boneyard module imports any Boneyard module;
   `lean_lib FormalSystem` roots only `FormalSystem`. Boneyard is excluded (Decision D3).
2. **There are two Boneyard trees, not one.** `FormalSystem/Boneyard/` and
   `FormalSystem/Metalogic/WeakCanonical/Kamp/Boneyard/`, together 1,934 occurrences across 51
   files — four times the report's 476/31 figure, which counted only the first tree. Excluding
   both drops the live migration scope to **3,711 occurrences across 152 files** (not 5,790/207).
3. **`untlG`/`snceG` are unsafe as the temporary name.** The report checked for the exact tokens
   and found none, but `untlGuard`, `untlGuards`, `snceGuard`, `snceGuards` all exist in
   `Metalogic/Decidability/Verified/Bridge/`. A substring-based rename-back of `untlG`→`untl`
   corrupts them to `untluard`/`untluards`. Resolved to `untlQ`/`snceQ` (Decision D5).

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No `roadmap_path` provided; ROADMAP.md not consulted.

## Decisions

The research report's §9 names five open questions the planner must resolve. Each is resolved
here, with the resolution binding on all phases below.

### D1. `toJson` key order — KEEP `"event"` first for the duration of this task

`DataExport.toJson` emits role-keyed JSON (`{"tag":"untl","event":…,"guard":…}`). The report
recommends flipping the key order to guard-first positional and building a temporary
`toJsonLegacy` printer to preserve the oracle.

**Resolved: do neither.** Keep the emitted key order as `"event"` then `"guard"`, and change only
*which constructor argument feeds each key* — post-migration, `| .untl g e => … "event": e …
"guard": g`. Because the JSON is keyed by **role** and the migration preserves roles exactly, the
regenerated `typst/generated/machine-appendix.jsonl` becomes **byte-identical to the
pre-migration baseline by construction**, with no temporary printer, no extra Lean code to write
and delete, and no extra build cycle. The oracle keeps its full discriminating power: a
half-swapped, un-swapped, or double-swapped axiom schema changes the *role content*, so the diff
is non-empty and names the exact axiom.

Flipping the emitted key order to guard-first positional is a dataset-format version bump with
downstream consumers (`DatasetExport.lean`'s S-expression parser, the training-data pipeline,
`typst/chapters/ax-machine-appendix.typ`'s shape table). It is orthogonal to argument order and
would destroy the byte-identity gate that makes this task auditable. **Deferred to a follow-on
task.**

`prettyPrint` is positional (`U(φ, ψ)` prefix), so it *cannot* be role-stable. Its output changes
predictably: every `U(a,b)` becomes `U(b,a)` and every `S(a,b)` becomes `S(b,a)`. This is handled
as a second, separately-transformed gate (Phase 9, Gate B) rather than by contorting the printer.
Switching `prettyPrint` to infix `(φ U ψ)` to match the manual is an explicit **Non-Goal**.

### D2. Role-encoding lemma names — DEFER to a follow-on task

Measured: **219 distinct identifiers** in live scope contain an `untl_`/`snce_` segment
(`untl_left_mono_thm`, `snce_event_congr`, `replace_untl_with_top`, `replace_untl_args`,
`closure_untl_left`, …) — substantially more than the report's ~60 estimate. After the swap,
`*_left` names the guard and `*_event_congr` names position 2.

**Resolved: defer.** Renaming identifiers in the same pass would (a) defeat the zero-residue grep
gate, which relies on `untl`/`snce` tokens being *absent* between Phases 4 and 10, (b) make the
diff unreviewable, and (c) risk colliding with the temporary-name substitution. This task's diff
stays a pure argument reorder that the Phase 9 oracle can verify end-to-end. The drift is
recorded explicitly in the closed decision record (Phase 13) with the measured 219 figure, so the
follow-on task has a starting inventory.

### D3. Boneyard scope — EXCLUDE both trees

**Resolved: exclude `FormalSystem/Boneyard/` and
`FormalSystem/Metalogic/WeakCanonical/Kamp/Boneyard/` from the migration entirely.**

Evidence (measured, not inferred): `find .lake/build -name '*.olean' -path '*Boneyard*'` returns
0 against 379 total built oleans; no module outside a Boneyard tree carries an
`import …Boneyard…` line; `lakefile.lean`'s `lean_lib FormalSystem` declares `roots :=
#[`FormalSystem]`, so only modules transitively imported from `FormalSystem.lean` are built. Both
trees are already documented as excluded from the repo's naming conventions
(`FormalSystem/FormalSystem.lean:35-39`).

Rewriting 1,934 occurrences that no compiler will ever check is pure added risk with no
verification available. Instead, Phase 13 adds a convention banner to each tree's `README.md`
recording that its contents predate this migration and read event-first, so a future
resurrection does not silently import the old convention.

**Consequence binding on every phase**: the zero-residue grep, the rewriter's file walk, the
per-file `sorry` ledger, and all reference counts are scoped to live (compiled) code only —
`FormalSystem/` and `Tests/` minus any path containing a `Boneyard` segment.

### D4. Comment/docstring migration scope — two tiers, mandatory tier only

The rewriter deliberately skips comments (report defect 4). That stays: comment correction is a
review operation, not a regex operation, because the prose needing repair is of the form
"Burgess: untl(event=φ, guard=ψ)" (`SoundnessLemmas/Core.lean:91`) and "In Xu's notation
U(event, guard), so Xu's 'U(γ, β)' = our untl(β, γ)" (`Chronicle/RRelation.lean:1527`) — whose
correction is a rewrite, not a swap.

**Resolved: migrate the mandatory tier in this task, defer the incidental tier.**

- **Mandatory** (Phase 11): comment/docstring lines that mention `untl`/`snce` *and* carry a
  role or convention word (`event`, `guard`, `Burgess`, `Pnueli`, `Xu`, `argument order`,
  `guard-first`, `event-first`, or a `U(`/`S(` prefix rendering). These state or depend on the
  convention and become false after the swap. Measured: **115 lines across 22 files**.
- **Deferred**: incidental mentions where the constructor appears only as a formula token
  (`untl φ ψ ∈ m q`). These are order-neutral and remain true. Measured: 391 lines.

### D5. Temporary name — `untlQ` / `snceQ`, with word-boundary-anchored rename-back

**Resolved: `untlQ` / `snceQ`. Do NOT use `untlG`/`snceG`.**

Measured prefix-extension scan over live scope:

| Candidate | Existing identifiers extending it |
|---|---|
| `untlG` | `untlGuard`, `untlGuards` |
| `snceG` | `snceGuard`, `snceGuards` |
| `untlQ` | none |
| `snceQ` | none |

A substring-based Phase 10 rename-back of `untlG`→`untl` would rewrite `untlGuards` to
`untluards`, breaking `Metalogic/Decidability/Verified/Bridge/RegionLabel.lean` and
`DenseTruth.lean`. `untlQ`/`snceQ` have zero prefix extensions and are therefore safe under both
word-boundary and naive substring replacement.

**Additionally mandated regardless of name choice**: the Phase 10 rename-back MUST use
identifier-boundary-anchored matching (`(?<![A-Za-z0-9_.])untlQ(?![A-Za-z0-9_])`), never bare
substring replacement. Belt and braces — the name choice removes the hazard, the anchoring
removes the class of hazard.

## Goals & Non-Goals

**Goals**:
- `Formula.untl`/`Formula.snce` take guard first, event second, with docstrings that name the
  roles and cite `def:BLplus-semantics` (acceptance 1).
- `Truth.lean`'s clauses and docstring match, with the stale footnote quotation replaced by text
  derived from the tracked anchor's current, footnote-free body (acceptance 2).
- `lake build` green with **zero** new `sorry`, verified by per-file delta (acceptance 3).
- `somePast`, `someFuture`, `next`, `prev` verified character-for-character against
  `def:BLplus-defined`'s `⊤ S φ`, `⊤ U φ`, `⊥ U φ`, `⊥ S φ` — verified against the paper, never
  against pre-migration Lean (acceptance 4).
- `specs/decisions/untl-snce-argument-order.md` closed as DECIDED, with the erroneous
  "four load-bearing dependents make this a semantic rewrite" argument explicitly retracted
  (acceptance 5).
- `scripts/typst-sync-check.sh` PASS and machine-appendix artifacts regenerated (acceptance 6).
- `specs/paper-definitions-of-record.md:573-600` prose caveat repaired (third stale artifact,
  not in the task description).

**Non-Goals**:
- Renaming the 219 role-encoding identifiers (D2, follow-on task).
- Flipping `toJson`'s emitted key order to guard-first positional (D1, follow-on task).
- Switching `prettyPrint` from prefix `U(φ,ψ)` to infix (D1).
- Migrating either Boneyard tree (D3).
- Migrating the 391 incidental comment mentions (D4).
- Re-pinning any paper anchor — no anchor hash moves in this task.
- Any prose change to the Typst manual body: it is already guard-first and already correct.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Rewriter half-applies (renames without swapping) — invisible to the compiler | H | M | Phase 9 role-keyed JSON oracle; the rewriter's per-site log makes every rewrite reviewable as a table |
| A build error during repair gets triaged as "hard proof" and answered with a `sorry` | H | M | Zero-Debt contract stated in every repair phase: the migration is meaning-preserving by construction, so an unexplainable error is a rewriter bug, not a proof obligation. Escalate to [BLOCKED] naming the module, never `sorry` |
| Swap-invariant functions (`swapTemporal`, `complexity`, `subformulas`, …) produce neither error nor wrong behaviour, inflating the residue chase | M | H | Enumerated up front in the Phase 1 ledger from report §4.1 so the audit does not chase them |
| Rename-back corrupts `untlGuards`/`snceGuards` | H | L | D5: `untlQ`/`snceQ` have zero prefix extensions, plus mandated identifier-boundary anchoring |
| A repair phase overruns its agent run mid-tree, leaving the build red | M | M | Repair phases build to scoped module targets, commit per green module, and record the topological frontier so the next run resumes there |
| Full-build cycle cost (60-90 min) consumed repeatedly by trial-and-error | M | M | Phases 3-7 build scoped targets only; exactly three full cycles are budgeted (Phases 8, 10) |
| `DatasetExport.lean`'s S-expression parser desyncs from the printer | M | M | Existing round-trip test is in the build; called out explicitly in Phase 5 |
| Baseline artifacts not captured before the root edit, destroying the oracle | H | L | Phase 1 is a hard prerequisite of Phase 3 and commits its snapshot |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2 | -- |
| 2 | 3 | 1, 2 |
| 3 | 4 | 3 |
| 4 | 5 | 4 |
| 5 | 6 | 5 |
| 6 | 7 | 6 |
| 7 | 8 | 7 |
| 8 | 9 | 8 |
| 9 | 10 | 9 |
| 10 | 11, 12 | 10 |
| 11 | 13 | 12 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Baseline Snapshot and Migration Ledger [COMPLETED]

**Goal**: Capture every pre-migration measurement the later gates diff against, and freeze the
scope boundary. Nothing downstream is auditable without this.

**Tasks**:
- [x] Confirm `lake build` green and record the job count. *(green, 2457 jobs, 425 oleans)*
- [x] Confirm `scripts/typst-sync-check.sh` PASS and record all three check results. *(PASS 3/3)*
- [x] Copy `typst/generated/machine-appendix.jsonl` and `machine-appendix.typ` to
      `specs/448_migrate_snce_untl_to_guard_first_order/baseline/`.
- [x] Write a **per-file** `sorry` count table for live scope to
      `baseline/sorry-baseline.txt` (per-file, never a total — the total double-counts).
- [x] Write a **per-file** `untl`/`snce` occurrence table for live scope to
      `baseline/reference-ledger.txt` using the identifier-boundary pattern
      `(?<![A-Za-z0-9_.])(?:Formula\.|\.)?(untl|snce)(?![A-Za-z0-9_])`.
- [x] Record the excluded-path predicate (any path containing a `Boneyard` segment) at the top of
      the ledger, and re-confirm D3's evidence: 0 Boneyard oleans, 0 non-Boneyard importers.
      *(both re-confirmed: 0 of 425 oleans under Boneyard; 0 non-Boneyard importers)*
- [x] Enumerate the swap-invariant sites from report §4.1 (`Formula.swapTemporal`, `complexity`,
      `modalDepth`, `temporalDepth`, `countImplications`, `atoms`, `predFormulas`, `subformulas`)
      into `baseline/swap-invariant-sites.txt` so the audit does not chase them.
- [x] Commit the baseline directory.

**Phase 1 result**: Scope hypothesis confirmed **exactly** — live scope 3,711 occurrences across
152 files; excluded Boneyard scope 1,934 across 51 files. Divergence 0.0%, well inside the 2%
tolerance, so the exclusion predicate and identifier pattern are both correct as specified.

**Timing**: 45 minutes

**Depends on**: none

**Verification Tier**: local

**Scope Hypothesis**: live scope is 3,711 constructor references across 152 files, and excluded
Boneyard scope is 1,934 across 51 files. Confirm by regenerating both counts with the ledger
script and comparing against these figures; a material divergence (>2%) means the exclusion
predicate or the identifier pattern is wrong and must be reconciled before Phase 3.

**Files to modify**:
- `specs/448_migrate_snce_untl_to_guard_first_order/baseline/` - new, four snapshot files

**Verification**:
- All four baseline files exist and are non-empty.
- `lake build` green; `typst-sync-check.sh` PASS.
- Ledger per-file counts sum to the confirmed live-scope figure.

---

### Phase 2: Harden the Rewriter [COMPLETED]

**Goal**: Turn `scripts/swap_untl_snce.py` into a tool that can be trusted over 152 files, with a
reviewable per-site audit log.

**Tasks**:
- [x] Fix defect 1 — **bare tokens not matched**. `| untl φ ψ ih_φ ih_ψ =>` must be recognised;
      these are `induction`/`cases` binder lists and an unswapped binder silently rebinds `φ`
      from event to guard. *(implemented as the `arm-2`/`arm-4` forms; the 4-binder arm swaps the
      induction hypotheses in step with the arguments)*
- [x] Fix defect 2 — **receiver dot-notation**. In `γ.untl β` the receiver `γ` is argument 1 and
      sits to the *left*; the scanner currently only looks right, finds one argument, and bails.
- [x] Fix defect 3 — **underscore-suffixed identifiers corrupted**. `Formula.untl_inj h` currently
      becomes `Formula.untlh _inj`. Refuse to fire on any `untl`/`snce` token followed by `_`,
      `.`, or an alphanumeric. *(`.`-followed names are now a distinct `lemma-ref` form: renamed,
      never swapped, because `Formula.untl.injEq` is generated from the constructor)*
- [x] Keep defect 4 as **designed behaviour**: comments and docstrings stay untouched (D4).
      Made explicit in the script docstring under "Deliberately NOT touched".
- [x] Add a `--rename-to untlQ,snceQ` mode performing rename-and-swap in one pass (D5).
- [x] Add an inverse `--rename-back` mode using identifier-boundary anchoring, no argument
      movement (D5). *(deviation: altered — see the anchoring note below)*
- [x] Add `--exclude-glob '*Boneyard*'`, applied by default (D3).
- [x] Add `--dry-run` and a **per-site log** (`file:line`, syntactic form, before, after) so the
      migration is reviewable as a table.
- [x] Extend the `--test` suite with in-tree regression cases for all four defects, drawn from
      real lines. *(66 cases: swap, rename-to, rename-back, and a swap-twice-is-identity
      round-trip over every swap case)*
- [x] Run `--dry-run` over live scope and confirm the log's site count reconciles against the
      Phase 1 ledger.
- [x] *(added)* Add a `--residue-scan` mode. The zero-residue gate is a statement about **code**;
      comments deliberately keep the old token until Phase 11, so a raw-text grep can never reach
      zero. `--residue-scan` greps code regions only and separates migratable hits from the two
      allowed foreign-namespace references.

**Four further defects found during implementation**, each fixed and regression-tested:

5. **Character literals desynchronised the comment/string mask.** A bare `'"'` in a parser
   (`TableauBridge`, `BenchmarkOracle`, `DatasetExport`, `Normalization`) opened a phantom string
   literal, inverting the code/non-code classification for the remainder of the file. Symptom: the
   string `| "untl" =>` was treated as code while the adjacent real `Formula.untl event guard`
   was treated as a string.
6. **Line-bounded argument scan.** Lean applications wrap; a two-argument application split over
   two lines was reported as partially applied. Fixed with an indentation-guarded continuation
   rule (a following line counts only when indented strictly deeper). 48 sites recovered.
7. **`·` section placeholders and `?hole` arguments were not argument atoms.**
   `(Formula.untl · q)` abbreviates `fun x => Formula.untl x q`, so `·` occupies argument
   position 1 and must move with it (`Tests/BimodalTest/Property/Generators.lean:118-123`).
8. **A sibling type shares the anonymous-dot syntax.** `Automation/Normalization.lean` declares
   `EnrichedFormula` with its own `untl`/`snce` constructors, referenced exclusively as `.untl`
   / bare case labels — indistinguishable from `Formula`'s. Handled by adding a `ctor-decl` form
   so the declaration is renamed (never swapped, its signature being symmetric); `EnrichedFormula`
   therefore migrates to guard-first in lockstep, which is coherent because every one of its
   construction and pattern sites is swapped uniformly. Conversely `TemporalPred.untl`
   (`Kamp/EANegationFix/BoundedFix.lean:44,49`) is a genuinely different function and is skipped
   as `foreign`, together with the two unqualified `simp only [untl]` references to it.

**Timing**: 1.5 hours

**Depends on**: none

**Verification Tier**: local

**Scope Hypothesis**: the four defects cover ~652 sites (540 bare-token across 63 files, 100
receiver-dot across 13 files, 12 underscore-suffix). Confirm at implementation time from the
`--dry-run` per-site log's form breakdown; if the bare-token or receiver-dot class comes back
materially smaller than these figures, the new matcher is under-firing and must be re-examined
before Phase 4 runs for real.

**Scope Hypothesis outcome** — measured, with the two divergences chased to ground:

| Class | Report estimate | Measured | Verdict |
|---|---|---|---|
| Underscore-suffix (defect 3) | 12 | **12** across 1 file | exact |
| Occurrences on `\|`-prefixed lines | 540 / 63 files | **580** | report slightly *under*-counted |
| — of which case-label heads | — | 384 (`arm-2` 275, `arm-4` 109) | the rest are nested patterns inside a label, handled by the ordinary 2-argument swap |
| — of which written bare | — | 162 (`arm-2` 53, `arm-4` 109) | |
| Receiver-dot (defect 2) | 100 / 13 files | **57** across 6 files | report over-estimated |

The receiver-dot divergence is *not* the matcher under-firing. An independent Unicode-aware
regex sweep over code regions for `‹receiver›.untl` shapes (excluding `Formula.` and foreign
namespaces) returns exactly 57 across exactly 6 files, agreeing with the classifier site for
site. The plan's re-examination trigger was therefore honoured and discharged by measurement.

**Full reconciliation against the Phase 1 ledger** (all figures over live scope, 424 files):

```
2,973  substring occurrences of untl/snce in code regions (every classified site)
 -400  embedded   — segments of longer identifiers (untl_left_mono_thm, untlGuards, …)
  -32  foreign    — TemporalPred.untl / .snce, a different function in a different namespace
=2,541  constructor references, the true migration surface
```

Cross-checks:
- 2,541 = qualified 1,627 + anon-dot 432 + arm-2 275 + arm-4 109 + receiver-dot 57 + bare-app 26
  + lemma-ref 7 + ctor-decl 4 + no-arg 2 + bare-ref 2.
- The Phase 1 ledger's 3,711 = 2,533 code-region + 1,178 comment/string occurrences. The
  2,533 differs from 2,541 by exactly **8**, all `receiver-dot` sites whose receiver ends in an
  ASCII alphanumeric (`bot.untl φ`, `f.snce g`, `φ.neg.untl ψ.neg`, `φ.swapTemporal.untl …`):
  the ledger pattern's `(?<![A-Za-z0-9_.])` lookbehind rejects those, while accepting the
  Greek-receiver cases. Enumerated individually in the phase notes; no other divergence exists.

**Rename-back anchoring** *(deviation: altered)*: D5 specifies
`(?<![A-Za-z0-9_.])untlQ(?![A-Za-z0-9_])`. Taken literally that lookbehind's `.` refuses to match
`Formula.untlQ`, which is 1,627 of the 2,541 sites — the rename-back would silently do almost
nothing. The implemented anchor is `(?<![A-Za-z0-9_])untlQ(?![A-Za-z0-9_])`: identifier-boundary
on both sides, `.` correctly treated as a boundary rather than as an identifier character. D5's
actual intent — never match a *suffix* of a longer name — is preserved, and is regression-tested
against `untlGuards`, `snceGuards`, `untlGuard` and `snceQGuard`.

**Files to modify**:
- `scripts/swap_untl_snce.py` - hardened matcher, rename modes, exclusion, per-site log, tests

**Verification**:
- [x] `python3 scripts/swap_untl_snce.py --test` passes: 66 cases across swap, rename-to,
  rename-back and swap-twice-is-identity round-trip.
- [x] `--dry-run` over live scope produces a per-site log whose total reconciles with the Phase 1
  ledger (reconciliation above), with **zero** sites classified `UNRECOGNISED`.
- [x] No file is modified by the dry run (`git status --short FormalSystem Tests` clean).

---

### Phase 3: Root Migration — Formula.lean, Syntax, Truth.lean [COMPLETED]

**Goal**: Perform the rename-and-swap by hand at the definitional root, where correctness is
established by reading the paper rather than by the compiler.

**Tasks**:
- [x] In `FormalSystem/Syntax/Formula.lean`: rename `untl`→`untlQ`, `snce`→`snceQ`; reorder both
      constructor signatures to guard-first; replace both docstrings with text naming the roles
      (arg 1 = guard, universally quantified over the open interval; arg 2 = event, witnessed at
      the existential time) and citing `def:BLplus-semantics`.
      *(deviation: altered — "reorder both constructor signatures" is vacuous here. Both
      signatures are `Formula → Formula → Formula`: the type is symmetric, so there is no
      textual reordering to perform and no way for the signature to record the convention. The
      entire semantic content of argument order lives in `Truth.lean`'s two clauses plus every
      call site; the constructor declarations carry it only in their docstrings, which is what
      was rewritten.)*
- [x] Swap all twelve derived-operator definitions per report §4: `someFuture`, `somePast`,
      `next`, `prev`, `kPlus`, `kMinus`, `release`, `weakUntil`, `trigger`, `weakSince`,
      `strongRelease`, `strongTrigger`. *(all twelve swapped; verified in the diff)*
- [x] **Verify the four paper-anchored operators against `def:BLplus-defined` directly**, not
      against the pre-migration Lean.
- [x] Leave `swapTemporal` and the symmetric recursors alone (report §4.1) — deliberate, not a
      miss. *(`complexity`, `modalDepth`, `temporalDepth`, `countImplications` have their case
      labels alpha-renamed by the rewriter so binder names keep their roles; their bodies are
      symmetric and unchanged. `complexity`'s shape-matching arms for the derived operators are
      NOT symmetric and were correctly swapped.)*
- [x] Migrate the remainder of `FormalSystem/Syntax/` with the hardened rewriter.
- [x] In `FormalSystem/Semantics/Truth.lean`: swap the two binding clauses so argument 1 is the
      universally-quantified guard and argument 2 the existentially-witnessed event.
- [x] Replace the stale `Truth.lean` docstring block, quoting the clause bodies rather than a
      footnote, corroborating with `def:BLplus-defined`, and retiring the earlier revisions'
      footnote quotation.
- [x] Build the scoped target `FormalSystem.Semantics.Truth` only. *(green, 784 jobs, first try)*

**The four shape assertions** (acceptance 4), each verified against `def:BLplus-defined` as
quoted in `specs/paper-definitions-of-record.md`, never against pre-migration Lean:

| Paper (`def:BLplus-defined`) | Lean, post-migration | Site |
|---|---|---|
| `Past: past φ ≔ ⊤ since φ` | `somePast φ = Formula.snceQ Formula.top φ` | `Formula.lean:157` |
| `Future: future φ ≔ ⊤ until φ` | `someFuture φ = Formula.untlQ Formula.top φ` | `Formula.lean:147` |
| `Next: Next φ ≔ ⊥ until φ` | `next φ = Formula.untlQ Formula.bot φ` | `Formula.lean:510` |
| `Previous: Previous φ ≔ ⊥ since φ` | `prev φ = Formula.snceQ Formula.bot φ` | `Formula.lean:514` |

In every row the paper's operand is the event and stands second; the constant (`⊤`/`⊥`) is the
guard and stands first. All four hold.

**One rewriter mis-fire found and repaired by hand.** `exact congrArg₂ untl (iha h.1) (ihb h.2)`
(`Formula.lean:354,361`) passes the constructor as a **value** to a higher-order combinator; the
two terms that follow are `congrArg₂`'s arguments, not the constructor's, so swapping them is
wrong. A Unicode-aware sweep of the pre-migration tree for the general shape (`untl`/`snce`
preceded by a non-keyword identifier) returns **exactly these two sites tree-wide**, so the class
is closed, not merely sampled. Repaired together with the four adjacent `BEq` bookkeeping
lemmas (`beq_untl_eq`, `beq_snce_eq`, `beq_refl`, `eq_of_beq`), whose constructor arguments carry
no roles: those were restored to canonical positional naming (`a b c d` in position order), a
pure alpha-rename that puts `rfl` back in front of an uncommuted conjunction.

**Timing**: 1.5 hours

**Depends on**: 1, 2

**Verification Tier**: interface

**Scope Hypothesis**: `Formula.lean` holds ~100 references and twelve derived-operator
definitions; `Truth.lean` holds 16. Confirm against the Phase 1 per-file ledger rows for these
files before editing, and confirm zero residual `untl`/`snce` tokens in `Syntax/` and
`Semantics/` after.

**Scope Hypothesis outcome**: 132 sites across 6 changed files of the 22 scanned — `qualified` 28,
`arm-2` 48, `arm-4` 14, `bare-app` 26, `anon-dot` 8, `ctor-decl` 2, plus 6 `embedded` skips. All
twelve derived operators present and swapped. Confirmed.

**Files to modify**:
- `FormalSystem/Syntax/Formula.lean` - constructors renamed/documented, 12 derived ops swapped
- `FormalSystem/Syntax/Subformulas.lean`, `SubformulaClosure/{Closure,NestingDepth,TemporalFormulas}.lean` - mechanical
- `FormalSystem/Semantics/Truth.lean` - clauses swapped, docstring replaced

**Verification**:
- [x] `lake build FormalSystem.Semantics.Truth` green (784 jobs).
- [x] Code-region residue scan over `FormalSystem/Syntax/` and `FormalSystem/Semantics/` returns
  `RESIDUE_MIGRATABLE=0  RESIDUE_ALLOWED=0`.
- [x] The four shape assertions against `def:BLplus-defined` recorded above and holding.
- [x] Per-file `sorry` delta zero for all six changed files (0 before, 0 after).

---

### Phase 4: Mechanical Rewrite of the Live Tree [COMPLETED]

**Goal**: Apply the hardened rewriter to everything downstream of `Semantics/`, and prove by grep
that no unmigrated reference survives. The build is expected red throughout — that is the point of
the rename.

**Tasks**:
- [x] Run `scripts/swap_untl_snce.py --rename-to untlQ,snceQ --exclude-glob '*Boneyard*'` over
      `FormalSystem/` and `Tests/`. *(deviation: altered — run over the whole tree rather than
      "excluding the already-migrated `Syntax/` and `Semantics/`". Those directories carry zero
      `untl`/`snce` tokens after Phase 3, so the rewriter is a provable no-op there; re-scanning
      them costs nothing and closes the possibility of a Phase 3 straggler surviving unseen.)*
- [x] Save the per-site log to `specs/448_migrate_snce_untl_to_guard_first_order/rewrite-log.txt`.
- [x] Review the per-site log as a table: form breakdown plausible, no site skipped or
      unrecognised.
- [x] **Zero-residue gate**: `RESIDUE_MIGRATABLE=0`.
- [x] Do NOT attempt any build repair in this phase.

**Form breakdown, and its exact reconciliation against Phase 2** (Phase 3 + Phase 4 together):

| form | Phase 3 | Phase 4 | sum | Phase 2 measurement |
|---|---|---|---|---|
| qualified | 28 | 1,599 | 1,627 | 1,627 |
| anon-dot | 8 | 424 | 432 | 432 |
| arm-2 | 48 | 227 | 275 | 275 |
| arm-4 | 14 | 95 | 109 | 109 |
| receiver-dot | 0 | 57 | 57 | 57 |
| bare-app | 26 | 0 | 26 | 26 |
| lemma-ref | 0 | 7 | 7 | 7 |
| ctor-decl | 2 | 2 | 4 | 4 |
| no-arg | 0 | 2 | 2 | 2 |
| bare-ref | 0 | 2 | 2 | 2 |
| **constructor references** | **126** | **2,415** | **2,541** | **2,541** |

Every one of the 2,541 constructor references established in Phase 2 is accounted for, form for
form, with no residual and no surplus. `embedded` (406, of which 6 are counted in both logs) and
`foreign` (32) are non-constructor skips and are excluded from the total by construction.

**Zero-residue gate**: `RESIDUE_MIGRATABLE=0  RESIDUE_ALLOWED=2  over 424 files`. The two allowed
hits are `simp only [untl, ...]` / `simp only [snce, ...]` at
`Metalogic/WeakCanonical/Kamp/EANegationFix/BoundedFix.lean:59,68`, unqualified references to
`TemporalPred.untl`/`TemporalPred.snce` -- a different function in a different namespace, correctly
untouched.

**Timing**: 1.5 hours

**Depends on**: 3

**Verification Tier**: full

**Commit Mode**: atomic-batch

**Scope Hypothesis**: this phase rewrites approximately 3,711 minus the Phase 3 Syntax/Semantics
subtotal (~197) = ~3,514 sites across ~146 files.

**Scope Hypothesis outcome**: 2,415 constructor references across 134 files. The hypothesis was
stated in *ledger occurrences* (which count comment and string mentions) rather than *constructor
references*; the two differ by the 1,178 comment/string occurrences the rewriter deliberately
leaves alone (D4). Against the like-for-like Phase 2 figure the count is exact. File count 134 vs
~146 estimated: 152 ledger files minus the 6 migrated in Phase 3 minus 12 whose only occurrences
are in comments or are `embedded`/`foreign` skips.

**Files to modify**:
- 134 files under `FormalSystem/` and `Tests/BimodalTest/` - mechanical rename-and-swap

**Verification**:
- [x] Code-region residue scan returns `RESIDUE_MIGRATABLE=0`.
- [x] The per-site log exists and reconciles against Phase 2 exactly (table above).
- [x] Every Boneyard file untouched (`git diff --name-only` shows no Boneyard path).

---

### Phase 5: Repair — ProofSystem, Theorems, Automation, FrameConditions [COMPLETED]

**Goal**: Bring the first downstream tier to a green scoped build. This tier contains the largest
unprotected definitional surface (`Axioms.lean`'s 45 schemata, the serialisers).

**Tasks**:
- [x] Build `FormalSystem.ProofSystem` and repair to green. *(green with no repair needed)*
      `dense_indicator` (`Axioms.lean:354-355`) now reads
      `(Formula.untlQ Formula.bot (Formula.bot.imp Formula.bot)).neg`, i.e. `¬(⊥ U ⊤)`,
      corroborated by `typst/chapters/p2-frame-classes.typ:134`'s `not (bot #untl top)`.
- [x] Build `FormalSystem.Theorems` and repair to green. *(green, no repair needed)*
- [x] Build `FormalSystem.FrameConditions` and repair to green. *(green, no repair needed)*
- [x] Build `FormalSystem.Automation` and repair to green. Confirm the `DatasetExport.lean`
      S-expression **parser** stays in sync with the printer, and that the round-trip test passes.
- [x] In `DataExport.lean`, apply D1. *(no manual edit needed — see below)*
- [x] Re-word the `dense_indicator` soundness prose at `Semantics/Validity.lean:262-264,301,307`
      from `U(⊤,⊥)` to `⊥ U ⊤`.
- [x] Commit per green module.

**The only repair this tier needed** was four `injection` component selections in
`Syntax/SubformulaClosure/TemporalFormulas.lean` (lines 843, 941, 990, 1029) — a textbook swap
artifact, and exactly the kind the Zero-Debt contract says to fix rather than `sorry` past.
`allFuture psi` unfolds to `imp (untlQ (imp bot bot) (imp psi bot)) bot`, so the constant guard
`⊤` now occupies injection component 1 and the operand moved to component 2; `injection h3` became
`injection h4`, and `injection h1 with h2 _` became `injection h1 with _ h2`. No other module in
the tier required any edit.

**D1 is satisfied with no manual edit, and Gate B's transform turns out to be the identity.**
The plan assumed the printers are positional by *argument slot*. They are not: every printer arm
binds by role, so the rewriter's role-preserving arm swap already produced exactly what D1 asks
for. `DataExport.lean:118-121` now reads `| .untlQ ψ φ => "{\"tag\": \"untl\", \"event\": "
++ φ.toJson ++ ", \"guard\": " ++ ψ.toJson ++ "}"` — key order unchanged, `φ` still the event,
now in argument position 2. Consequently:

- `toJson` output is byte-stable (Gate A as planned).
- `prettyPrint` (`U(" ++ φ.prettyPrint ++ ", " ++ ψ.prettyPrint`) is **also** byte-stable: it
  prints `U(event, guard)` before and after. **Gate B's `U(a,b) → U(b,a)` transform is therefore
  the identity**, and Phase 9 must diff `schema_string` fields *raw*. Applying the planned
  transform would manufacture a failure. This is a correction to D1, recorded here and applied in
  Phase 9.
- `toSExpr` and `tokenize` are byte-stable for the same reason, so `DatasetExport.lean`'s
  `matchStr "untl "` parser needs no format change; its construction site was swapped to
  `Formula.untlQ rhs lhs` (`DatasetExport.lean:804`), and `BenchmarkOracle.lean:227` likewise to
  `Formula.untlQ guard event`. Printer and parser stay mutually inverse.

**Timing**: 2 hours

**Depends on**: 4

**Verification Tier**: full

**Scope Hypothesis**: this tier holds roughly 82 (`ProofSystem`) + 73 (`Theorems`) + 657
(`Automation`) references. Confirm against the Phase 1 ledger rows; the count is a hypothesis, and
what actually matters is that each scoped build reaches green.

**Scope Hypothesis outcome**: all four scoped builds reach green, which is the operative
criterion. Three of the four needed no edit at all.

**Files to modify**:
- `FormalSystem/Syntax/SubformulaClosure/TemporalFormulas.lean` (injection components),
  `FormalSystem/Semantics/Validity.lean` (prose only)

**Verification**:
- [x] `lake build FormalSystem.ProofSystem FormalSystem.Theorems FormalSystem.FrameConditions
  FormalSystem.Automation` green (1,414 jobs).
- [x] Zero `sorry` delta versus the Phase 1 per-file baseline across `ProofSystem`, `Theorems`,
  `FrameConditions`, `Automation`, `Semantics` and `Syntax` — 0 files with a nonzero delta.
- [x] `dense_indicator` reads `¬(⊥ U ⊤)`.

---

### Phase 6: Repair — Metalogic, Soundness and BXCanonical/Chronicle [NOT STARTED]

**Goal**: Repair the first half of the bulk. Metalogic is 71% of the migration.

**Tasks**:
- [ ] Build and repair `FormalSystem.Metalogic.Soundness` and its `SoundnessLemmas/` tree.
- [ ] Build and repair `FormalSystem.Metalogic.BXCanonical` and its `Chronicle/` tree.
- [ ] Commit per green module.
- [ ] Record the topological frontier reached in the phase notes so a resumed run knows where to
      pick up.

**Timing**: 2 hours

**Depends on**: 5

**Verification Tier**: full

**Scope Hypothesis**: `Metalogic` totals ~4,127 references across 133 files pre-exclusion; the
live, Boneyard-excluded portion is smaller and split across Phases 6-7. Confirm the actual live
per-file rows from the Phase 1 ledger at the start of the phase, and split the Phase 6/7 boundary
by whatever the ledger shows rather than by the report's directory estimate.

**Zero-Debt contract**: this migration is meaning-preserving by construction — every proof valid
before remains valid after once its statement and body are swapped consistently. A build error
that is not explicable as a swap artifact is a **rewriter bug at that site**, not a proof
obligation. Fix the rewrite. Never insert a `sorry`. If a module's errors resist explanation,
escalate to `[BLOCKED]` naming the module.

**Files to modify**:
- `FormalSystem/Metalogic/Soundness*`, `FormalSystem/Metalogic/SoundnessLemmas/*`,
  `FormalSystem/Metalogic/BXCanonical/*`

**Verification**:
- Scoped builds for both subtrees green.
- Zero new `sorry` versus baseline for every file touched.

---

### Phase 7: Repair — Metalogic WeakCanonical/Kamp, Decidability/Verified, Examples [NOT STARTED]

**Goal**: Repair the remaining bulk.

**Tasks**:
- [ ] Build and repair `FormalSystem.Metalogic.WeakCanonical` and its `Kamp/` tree (excluding its
      local `Boneyard/`).
- [ ] Build and repair `FormalSystem.Metalogic.Decidability` and its `Verified/` tree. Confirm
      `Bridge/RegionLabel.lean` and `Bridge/DenseTruth.lean` — which contain the
      `untlGuards`/`snceGuards` identifiers behind D5 — are correct and untouched by the rename.
- [ ] Build and repair `FormalSystem.Examples`.
- [ ] Commit per green module.

**Timing**: 2 hours

**Depends on**: 6

**Verification Tier**: full

**Scope Hypothesis**: the residual live Metalogic rows from the Phase 1 ledger not covered by
Phase 6, plus `Examples`. Confirm by re-running the ledger scoped to these subtrees and checking
that Phases 6 and 7 together account for every live Metalogic file.

**Zero-Debt contract**: as Phase 6. No `sorry` under any circumstance.

**Files to modify**:
- `FormalSystem/Metalogic/WeakCanonical/*` (minus `Kamp/Boneyard/`),
  `FormalSystem/Metalogic/Decidability/*`, `FormalSystem/Examples/*`

**Verification**:
- Scoped builds green for all three subtrees.
- `untlGuards`/`snceGuards` identifiers intact and unrenamed.
- Zero new `sorry` versus baseline.

---

### Phase 8: Repair Tests and First Full Green Build [NOT STARTED]

**Goal**: Close the repair loop and spend the first budgeted full build cycle.

**Tasks**:
- [ ] Build and repair `Tests/BimodalTest/`, including `UntlSnceCopyProbe.lean` and
      `TemporalWitnessProbe.lean` (which pin the tableau-rule semantics of the constructors) and
      the conformance corpora expected-value tables.
- [ ] Run a **full `lake build`** and drive it to green.
- [ ] Regenerate the per-file `sorry` count table and diff against `baseline/sorry-baseline.txt`.
      The delta must be zero for every file (acceptance 3).
- [ ] Confirm `next_unfold` / `prev_unfold` still close by `rfl` and now read `bot.untlQ φ` /
      `bot.snceQ φ` — the `⊥ U φ` / `⊥ S φ` paper forms.
- [ ] Commit.

**Timing**: 1.5 hours plus a 60-90 minute build cycle

**Depends on**: 7

**Verification Tier**: full

**Scope Hypothesis**: `Tests/BimodalTest` holds ~178 references across 13 files. Confirm against
the Phase 1 ledger.

**Zero-Debt contract**: as Phase 6.

**Files to modify**:
- `Tests/BimodalTest/*`

**Verification**:
- Full `lake build` green.
- Per-file `sorry` delta is zero across the whole live tree.
- `next_unfold`/`prev_unfold` close by `rfl`.

---

### Phase 9: Definitional Audit — Two-Gate Oracle [NOT STARTED]

**Goal**: Audit exactly the sites no proof pins — the 45 axiom schemata and the derived
operators — where a half-applied swap is well-typed and silent.

**Tasks**:
- [ ] Regenerate `typst/generated/machine-appendix.jsonl` via
      `scripts/typst-machine-appendix.sh`.
- [ ] **Gate A (structural, byte-exact)**: extract the role-keyed `toJson` structural fields from
      the regenerated JSONL and from `baseline/machine-appendix.jsonl`, and diff. Under D1 these
      must be **byte-identical**. A non-empty diff names the exact axiom or operator that was
      half-swapped, un-swapped, or double-swapped.
- [ ] **Gate B (positional, transform-then-diff)**: `prettyPrint`'s `schema_string` fields are
      positional and are expected to change predictably — every `U(a,b)` becomes `U(b,a)` and
      every `S(a,b)` becomes `S(b,a)`. Apply that transformation to the baseline's
      `schema_string` fields and diff against the regenerated ones. Must be byte-identical after
      the transform. Any residue is a real defect.
- [ ] Re-verify the four `def:BLplus-defined` shape assertions from Phase 3 against the
      regenerated appendix output (`⊤ S φ`, `⊤ U φ`, `⊥ U φ`, `⊥ S φ`).
- [ ] Record both gate results in the phase notes.

**Timing**: 1 hour

**Depends on**: 8

**Verification Tier**: full

**Scope Hypothesis**: the appendix covers 45 axioms, 7 inference rules, and 21 derived operators
across 74 JSONL lines. Confirm the regenerated line count matches the baseline's 74 before
running either gate — a line-count change means something other than argument order moved.

**Files to modify**:
- `typst/generated/machine-appendix.jsonl`, `typst/generated/machine-appendix.typ` (regenerated)

**Verification**:
- Gate A diff empty.
- Gate B diff empty after the documented `U(a,b)→U(b,a)` / `S(a,b)→S(b,a)` transform.
- Four shape assertions hold against the regenerated output.

---

### Phase 10: Rename Back and Final Verification Build [NOT STARTED]

**Goal**: Restore the constructor names. This step is provably meaning-preserving — a lexical
rename with no possible collision, since zero `untl`/`snce` tokens exist at this point.

**Tasks**:
- [ ] Run `scripts/swap_untl_snce.py --rename-back` over live scope: `untlQ`→`untl`,
      `snceQ`→`snce`, **identifier-boundary anchored**, with no argument movement (D5).
- [ ] Confirm `grep -c 'untlQ\|snceQ'` over live scope returns 0.
- [ ] Confirm `untlGuards`, `snceGuards`, `untlGuard`, `snceGuard` are present and unmodified in
      `Metalogic/Decidability/Verified/Bridge/` — the D5 corruption check.
- [ ] Run the **final full `lake build`** to green.
- [ ] Regenerate the per-file `sorry` table and re-confirm a zero delta against baseline.
- [ ] Re-run the Phase 9 Gate A byte-diff after the rename-back (the JSON is role-keyed, so
      renaming the constructor changes the `"tag"` value back to `"untl"`/`"snce"` — the diff must
      be empty against the original baseline, not against the Phase 9 output).
- [ ] Commit.

**Timing**: 1.5 hours plus a 60-90 minute build cycle

**Depends on**: 9

**Verification Tier**: full

**Scope Hypothesis**: the rename-back touches exactly the same file set as Phases 3-8 combined
(~152 live files). Confirm by diffing the rename-back log's file list against the Phase 4
rewrite log plus the Phase 3 file list; a file appearing in one and not the other is a defect.

**Files to modify**:
- All ~152 live files carrying constructor references

**Verification**:
- Zero `untlQ`/`snceQ` tokens in live scope.
- `untlGuards`/`snceGuards` intact.
- Full `lake build` green; per-file `sorry` delta zero.
- Gate A byte-diff against the original baseline empty.

---

### Phase 11: Role-Naming Comment and Docstring Migration [NOT STARTED]

**Goal**: Correct the comments that state or depend on the argument-order convention. These are
now false and cannot be fixed by a swap — several describe *other authors'* conventions relative
to ours and need rewriting.

**Tasks**:
- [ ] Enumerate the mandatory tier (D4): comment/docstring lines mentioning `untl`/`snce` that
      also carry a role or convention word.
- [ ] Rewrite each by review, not by regex. Known hard cases: `SoundnessLemmas/Core.lean:91`
      ("Burgess: untl(event=φ, guard=ψ)") and `Chronicle/RRelation.lean:1527` ("In Xu's notation
      U(event, guard), so Xu's 'U(γ, β)' = our untl(β, γ)") — the correction of the latter is a
      re-derivation of the cross-notation mapping, not a swap.
- [ ] Leave the incidental tier untouched (D4) — those mentions are order-neutral and remain true.
- [ ] Read the diff through to confirm every changed hunk lies inside a comment or docstring
      region and does not cross into code.
- [ ] Commit.

**Timing**: 1.5 hours

**Depends on**: 10

**Verification Tier**: prose

**Scope Hypothesis**: 115 mandatory-tier lines across 22 files; 391 incidental lines deliberately
untouched. Confirm both counts by re-running the classifier at implementation time; a materially
larger mandatory set means the role-word predicate needs widening before the pass begins.

**Files to modify**:
- ~22 files under `FormalSystem/` - comments and docstrings only

**Verification**:
- Every changed hunk lies inside a comment/docstring region (diff read-through).
- No mandatory-tier line still asserts event-first.
- `lake build` still green (a docstring edit should not affect it, but confirm — Lean docstrings
  are elaborated).

---

### Phase 12: Typst Regeneration and Sync [NOT STARTED]

**Goal**: Make the manual's four `CONFIRM(lean)` assertions true, and refresh the generated
artifacts (acceptance 6).

**Tasks**:
- [ ] Re-run `scripts/typst-machine-appendix.sh` to regenerate both
      `typst/generated/machine-appendix.jsonl` and `machine-appendix.typ` at the current commit.
- [ ] Run `scripts/typst-sync-check.sh` and confirm all three checks PASS
      (`TOTAL_VIOLATIONS=0`, `MISMATCH_COUNT=0`, `MA_COUNT_MISMATCHES=0`).
- [ ] Re-verify the four `// CONFIRM(lean):` markers now hold, one by one, against live Lean
      source: `01-syntax.typ:25`, `01-syntax.typ:112`, `p2-frame-classes.typ:171`,
      `ax-machine-appendix.typ:24`.
- [ ] Leave `ax-machine-appendix.typ`'s JSON-shape table as `{"tag":"untl","event":…,"guard":…}` —
      under D1 the emitted key order is unchanged, so the table stays correct. Add a one-line note
      that the keys are role-keyed and therefore order-stable across the argument-order change.
- [ ] Refresh the stale line-number reference at `typst/SYNC-MAP.md:232` ("added from
      Truth.lean:125-130") to the current `Truth.lean` clause lines.
- [ ] Make no prose change to the manual body — it is already guard-first and already correct.
- [ ] Commit.

**Timing**: 1 hour

**Depends on**: 10

**Verification Tier**: local

**Scope Hypothesis**: exactly four `// CONFIRM(lean):` markers assert guard-first order, at
`01-syntax.typ:25`, `01-syntax.typ:112`, `p2-frame-classes.typ:171`, and
`ax-machine-appendix.typ:24`. Confirm at implementation time by grepping `typst/` for
`CONFIRM(lean)` and checking that every hit touching argument order is in that list — a fifth
marker means the manual asserts something this plan has not accounted for.

**Files to modify**:
- `typst/generated/machine-appendix.jsonl`, `typst/generated/machine-appendix.typ` (regenerated)
- `typst/chapters/ax-machine-appendix.typ` - one clarifying note
- `typst/SYNC-MAP.md` - refreshed line references

**Verification**:
- `scripts/typst-sync-check.sh` PASS on all three checks.
- Each of the four `CONFIRM(lean)` markers verified by hand against live Lean source.

---

### Phase 13: Record Closure and Prose Repairs [NOT STARTED]

**Goal**: Close the decision record and repair the two other stale prose artifacts, including the
third one the task description did not flag.

**Tasks**:
- [ ] Close `specs/decisions/untl-snce-argument-order.md`: OPEN -> DECIDED, recording that the
      Lean tree was aligned to the paper (guard-first) rather than the reverse (acceptance 5).
- [ ] **Explicitly retract**, in that record, the "Why the event-first reading is load-bearing"
      argument. It is wrong: it evaluates each of the four dependents' *current text* under a
      *guard-first reading* without swapping the dependent's arguments. A uniform swap of the
      definition and every call site is meaning-preserving by construction, so the four
      dependents were never obstacles — they were four more sites. Retract it rather than
      silently dropping it, so a future reader does not rediscover it as live reasoning.
- [ ] Record in that record: the superseded footnote quotation is retired (the live anchor
      `edde7517…` is footnote-free as of the 2026-08-17 re-pin); the D2 identifier-name drift with
      the measured figure of 219 distinct `untl_`/`snce_` identifiers; the D1 deferred `toJson`
      key-order flip; and the D3 Boneyard exclusion.
- [ ] Repair the prose caveat at `specs/paper-definitions-of-record.md:573-600` — the **third**
      stale artifact. It describes a footnote that no longer exists, asserts the Lean tree is
      event-first "and did not need to be changed", and cites `Formula.lean:85-90` /
      `Truth.lean:134-135` by stale line numbers. Rewrite it to describe the current, footnote-free
      anchor and the completed alignment. This is a prose repair, **not** a re-pin — no anchor
      hash moves.
- [ ] Add a convention banner to `FormalSystem/Boneyard/README.md` and
      `FormalSystem/Metalogic/WeakCanonical/Kamp/Boneyard/README.md` (D3): their contents predate
      this migration, are not compiled, and read `untl`/`snce` **event-first**; resurrecting any
      file requires swapping its constructor arguments first.
- [ ] Run `scripts/check-paper-definitions.sh` to confirm no anchor drift was introduced.
- [ ] Commit.

**Timing**: 1.5 hours

**Depends on**: 12

**Verification Tier**: prose

**Scope Hypothesis**: exactly three stale prose artifacts need repair — the decision record, the
`paper-definitions-of-record.md:573-600` caveat, and (as new banners) the two Boneyard READMEs.
Line 573-600 is a plan-time reference and will have drifted; locate the caveat by its content
("did not need to be changed", the footnote description) rather than by line number, and confirm
no fourth artifact quotes the retired footnote by grepping `specs/` for the superseded footnote
text before closing the phase.

**Files to modify**:
- `specs/decisions/untl-snce-argument-order.md` - closed as DECIDED, argument retracted
- `specs/paper-definitions-of-record.md` - prose caveat at 573-600 repaired
- `FormalSystem/Boneyard/README.md`, `FormalSystem/Metalogic/WeakCanonical/Kamp/Boneyard/README.md` - convention banners

**Verification**:
- Decision record status is DECIDED and the retraction is explicit.
- No occurrence of the removed footnote's text survives in any of the three artifacts.
- `scripts/check-paper-definitions.sh` reports no anchor drift.

---

## Testing & Validation

- [ ] `lake build` green with zero errors (Phases 8 and 10).
- [ ] Per-file `sorry` count delta is zero against `baseline/sorry-baseline.txt` — no new `sorry`
      anywhere (acceptance 3).
- [ ] Identifier-boundary grep for `untl`/`snce` returns 0 over live scope between Phases 4 and 10
      (zero-residue gate).
- [ ] `grep -c 'untlQ\|snceQ'` returns 0 after Phase 10.
- [ ] `untlGuards`/`snceGuards`/`untlGuard`/`snceGuard` intact after Phase 10.
- [ ] Gate A: role-keyed `toJson` fields byte-identical to baseline.
- [ ] Gate B: `schema_string` fields byte-identical after the documented `U(a,b)→U(b,a)` /
      `S(a,b)→S(b,a)` transform.
- [ ] `somePast` = `⊤ S φ`, `someFuture` = `⊤ U φ`, `next` = `⊥ U φ`, `prev` = `⊥ S φ`, verified
      against `def:BLplus-defined` (acceptance 4).
- [ ] `dense_indicator` reads `¬(⊥ U ⊤)`.
- [ ] `next_unfold` / `prev_unfold` still close by `rfl`.
- [ ] `Tests/BimodalTest/UntlSnceCopyProbe.lean` and `TemporalWitnessProbe.lean` pass.
- [ ] `DatasetExport.lean` S-expression printer/parser round-trip test passes.
- [ ] `scripts/typst-sync-check.sh` PASS on all three checks (acceptance 6).
- [ ] `scripts/check-paper-definitions.sh` reports no anchor drift.
- [ ] `python3 scripts/swap_untl_snce.py --test` passes.

## Artifacts & Outputs

- `specs/448_migrate_snce_untl_to_guard_first_order/plans/01_guard-first-migration.md` (this file)
- `specs/448_migrate_snce_untl_to_guard_first_order/baseline/` — machine-appendix snapshot,
  per-file `sorry` baseline, per-file reference ledger, swap-invariant site list
- `specs/448_migrate_snce_untl_to_guard_first_order/rewrite-log.txt` — per-site migration audit log
- `specs/448_migrate_snce_untl_to_guard_first_order/summaries/01_guard-first-migration-summary.md`
- Hardened `scripts/swap_untl_snce.py`
- Migrated `FormalSystem/` and `Tests/` live tree (~152 files)
- Regenerated `typst/generated/machine-appendix.{jsonl,typ}`
- Closed `specs/decisions/untl-snce-argument-order.md`
- Repaired `specs/paper-definitions-of-record.md` prose caveat
- Convention banners in both `Boneyard/README.md` files

## Follow-On Work (out of scope, recorded for task creation)

1. **Identifier-name hygiene** (D2): rename the 219 role-encoding identifiers so `*_left`,
   `*_event_congr`, `untl_args`, `replace_untl_with_top`/`_with_bot` reflect the new positions.
2. **`toJson` key-order flip** (D1): change the emitted key order to guard-first positional and
   version the dataset format, updating `DatasetExport.lean`'s parser and
   `ax-machine-appendix.typ`'s shape table.
3. **Incidental comment migration** (D4): the 391 order-neutral prose mentions.
4. **Optional `prettyPrint` infix rendering** (D1) to match the manual's `(φ U ψ)` form.

## Rollback/Contingency

Every phase commits independently, so rollback is `git revert` of the phase range. The two
structurally significant rollback points are:

- **Before Phase 3**: the tree is untouched apart from the baseline directory and the hardened
  script. Reverting Phases 1-2 is free and loses nothing of value.
- **Between Phases 4 and 10**: the tree carries `untlQ`/`snceQ` and does not build. This is a
  deliberate red window. Rollback here means reverting the whole Phase 3-N range in one revert —
  do not attempt a partial revert, which would leave a mixed-convention tree that the compiler
  cannot distinguish from a correct one.

If Phase 6 or 7 stalls on a module whose errors are not explicable as swap artifacts, mark the
task `[BLOCKED]` naming the module. **Do not insert a `sorry` to reach a green build**, and do not
discard uncommitted changes to reach one.
