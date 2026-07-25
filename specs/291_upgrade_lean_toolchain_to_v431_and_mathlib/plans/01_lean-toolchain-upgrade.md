# Implementation Plan: Lean Toolchain Upgrade and Mathlib Pin Sync

- **Task**: 291 - upgrade_lean_toolchain_to_v431_and_mathlib
- **Status**: [IMPLEMENTING]
- **Effort**: 16 hours (see "Effort estimate is provisional by design" below)
- **Dependencies**: None
- **Research Inputs**: specs/291_upgrade_lean_toolchain_to_v431_and_mathlib/reports/01_lean-toolchain-upgrade-431.md
- **Artifacts**: plans/01_lean-toolchain-upgrade.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

---

## Deviation from Task Description

**This plan targets Lean `v4.33.0-rc1`, not the `v4.31` named in the task title.**

The task description contains two clauses that no longer agree with each other:

> "Upgrade Lean toolchain from v4.27 to v4.31" **and** "update Mathlib to the same pin as cslib"

When the task was written (2026-06-08) those were the same thing. They are not any more.
Research verified against `raw.githubusercontent.com/leanprover/cslib/main/lean-toolchain` that
cslib `main` now pins `leanprover/lean4:v4.33.0-rc1` (bumped 2026-07-16, PR #723), having passed
through 4.31.0 and 4.32.0 in the interim.

The task's *stated purpose* is the tiebreaker: "This is a prerequisite for all porting tasks:
cslib uses Lean 4.31 and tasks 292-294 cannot proceed until BimodalLogic builds cleanly."
Landing on 4.31 would leave this repo two minor releases behind cslib and would **not** unblock
porting — it would satisfy the literal text while failing the goal.

| Target | Verdict |
|---|---|
| `v4.33.0-rc1` | **Chosen.** Byte-identical toolchain to cslib HEAD. Mathlib tag `v4.33.0-rc1` exists. |
| `v4.32.1` | Rejected. Latest stable, but still one minor behind cslib; residual skew for porting. |
| `v4.31.0` (literal task text) | Rejected. Three releases behind cslib; does not achieve the task's purpose. |

Concrete pin strings to write:

- `lean-toolchain` (entire file, no trailing newline, matching current style):
  `leanprover/lean4:v4.33.0-rc1`
- `lakefile.lean:8-9`: mathlib `@ "v4.33.0-rc1"`

Mathlib is pinned by **tag**, not by cslib's raw commit rev (`169c26b52a38…`). Tags have
`lake exe cache get` coverage; the rev is an arbitrary master commit that merely happens to sit on
the same toolchain. There is no compatibility reason to match it exactly.

**Reviewer action required if this is wrong.** If 4.31 was wanted for a reason not stated in the
task, stop at Phase 2 and re-plan — the pin edit is a single isolated commit precisely so this is
cheap to redirect.

---

## Overview

Move BimodalLogic from `leanprover/lean4:v4.27.0-rc1` + Mathlib `v4.27.0-rc1` to
`leanprover/lean4:v4.33.0-rc1` + Mathlib `v4.33.0-rc1`, repair the resulting breakage, and prove
the repo is functionally unchanged — including in the executables, where the most dangerous
change of this upgrade is **silent**. The work is structured as: capture a baseline, flip the pin
as one isolated commit, run one build to *measure* the damage without fixing anything, then run
sized repair phases against that measurement, then verify behavior rather than just compilation.

Definition of done: `lake build` green with zero new `sorry`, `lake test` passing, and all 12
`lean_exe` targets producing output that matches the pre-upgrade baseline.

### Effort estimate is provisional by design

The task description estimates "~50-200 lines of fixes". Research argues this is likely wrong
**in kind**, not merely in magnitude, and this plan is built around that argument:

- All 59 Mathlib modules this repo imports were verified to still exist at `v4.33.0-rc1`. **Zero
  import-path breakage.** There is no rename sweep to do.
- The actual failure mode is semantic — `isDefEq` transparency (Lean 4.29/4.31), elaboration cost
  against already-exhausted heartbeat budgets, and `simp` instance handling — which produces
  failures spread thinly across a 182k-line non-Boneyard proof corpus, each needing a judgement
  call rather than a mechanical substitution.

Accordingly, **Phase 3 produces only a categorized error inventory and fixes nothing.** Phases
4-7 are sized from that inventory at the time it exists. The 16-hour figure in the metadata block
is a placeholder for scheduling, not a commitment; the implementer updates it after Phase 3.
Committing to a fix count now would be inventing a number.

### Research Integration

Driven throughout by `reports/01_lean-toolchain-upgrade-431.md`. Findings carried directly into
phases: the verified target pin (§2), zero import breakage (§3), the twelve-row breakage taxonomy
(§5) which becomes the Phase 3 inventory schema, the `skill-lean-version` defect (§7), and the
single-jump-vs-staged trade-off (§7, resolved below).

One research correction, verified during planning: the report states **13** `lean_exe` targets;
`grep -c '^lean_exe' lakefile.lean` returns **12**. The correct list is `dataset_generator`,
`dataset_validator`, `proof_extractor`, `enum_benchmark`, `benchmark_anchors`,
`benchmark_oracle`, `contrastive_generator`, `tableau_bridge`, `tableau_proof_steps`,
`trace_exporter`, `proof_first_generator`, `machine_appendix`. This matters because Phase 1 and
Phase 8 iterate that list; use 12.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No `specs/ROADMAP.md` consulted for this task (no `roadmap_path` in delegation context).

---

## Decisions Made in This Plan

### D1. Single jump 4.27 -> 4.33, with staging held as an explicit fallback

Research deliberately left this open. **Decision: single jump.**

Rationale: staging through 4.29/4.31 means three Mathlib cache downloads and three full rebuilds
of a 278k-line corpus — many hours of pure compute and ~3x disk churn against 63 GB free — and its
only real benefit is *attributing* each error to the release that caused it. But §5 of the
research already provides that attribution as a lookup table: each breakage category is tagged
with its originating release and paired with the concrete repo sites it lands on. Paying three
rebuilds to re-derive information we already have on paper is a bad trade.

**Fallback trigger (must be evaluated at the end of Phase 3, and only there):** fall back to
staged `4.27 -> 4.29 -> 4.31 -> 4.33` if **either** condition holds:

1. More than 25% of Phase 3's error inventory lands in the `unattributable` category — i.e. the
   error cannot be mapped to any row of the §5 taxonomy. This is the real signal that the single
   jump has destroyed our ability to reason about causes.
2. The Phase 3 build fails so early that the inventory is not representative — e.g. a failure in
   a low-level module aborts the build before the bulk of `Theories/` is elaborated, so the error
   count is an artifact of build ordering rather than a measurement.

If triggered: `git checkout` back to the pre-upgrade pin, re-run Phase 2 targeting `v4.29.0`, and
repeat Phases 3-7 per stage. Do **not** trigger staging merely because the inventory is large — a
large but *attributable* inventory is exactly the case the single jump handles fine.

### D2. Un-quarantining the Plausible tests is split OUT of this task

The direct `require plausible from git … @ "main"` at `lakefile.lean:11-12` **is** removed here
(Phase 2). That is pin hygiene: Mathlib already requires plausible, and our floating `main`
override lets `lake update` pull a plausible HEAD newer than the one Mathlib was built against.
This repo has already been bitten by exactly that — `Tests/BimodalTest/Syntax/FormulaPropertyTest.lean`
carries 27 `NamedBinder`-related quarantine comments across ~18 commented-out test blocks.

**Re-enabling those blocks is NOT in scope for this task.** Reasons:

- It is proof-authoring work (adding `NamedBinder` decoration to ~18 property statements), not
  toolchain-pin work. Different skill, different failure modes.
- It would pollute the signal this task depends on. Phases 3-7 measure "what did the upgrade
  break" by watching the error count fall monotonically. Adding ~18 previously-absent test blocks
  injects new errors into that same count and makes the measurement meaningless.
- The quarantined blocks are comments. They compile trivially before and after, so they cannot
  block this upgrade.

**Action**: Phase 10 records a follow-up task recommendation ("re-enable quarantined Plausible
property tests under the inherited plausible pin"). Creating that task is a `/task` invocation for
the user or orchestrator, not something this plan performs.

### D3. `skill-lean-version` is not used

Research found the skill's documentation claims it backs up `lake-manifest.json` (SKILL.md:138)
while its actual backup step (SKILL.md:91-96) copies only `lean-toolchain` and `lakefile.lean`.
Trusting its rollback would silently lose the resolved dependency graph. It also requires
`AskUserQuestion`, which is unavailable under `orchestrator_mode: true`.

Edits are made directly with the Edit tool; rollback is git. All three files (`lean-toolchain`,
`lakefile.lean`, `lake-manifest.json`) are tracked, and the tree was clean at `e0158da5e`.

*(Out of scope but worth a separate meta task: the skill's backup/documentation mismatch is a real
defect in the agent system.)*

---

## Goals & Non-Goals

**Goals**:

- `lean-toolchain` at `leanprover/lean4:v4.33.0-rc1`, Mathlib pinned to tag `v4.33.0-rc1`,
  `lake-manifest.json` regenerated and committed.
- Redundant direct `require plausible` removed from `lakefile.lean`; plausible inherited from
  Mathlib.
- Unused `import Batteries.Tactic.OpenPrivate` removed from `InteriorGateGeneralK.lean:4`.
- `lake build` completes with zero errors and **zero net new `sorry`** relative to the Phase 1
  baseline.
- `lake test` passes.
- All 12 `lean_exe` targets produce output matching the Phase 1 baseline — the gate that catches
  the silent `do`-elaborator change.
- Any `backward.*` compatibility options introduced during repair are inventoried, and those no
  longer needed are removed before completion.

**Non-Goals**:

- Re-enabling the quarantined Plausible property tests (see D2 — follow-up task).
- Migrating this repo's own files to Lean's module system (`module` / `public import`). Research
  confirmed our files use none of it and that legacy-importing-module-Mathlib already works; this
  upgrade does not cross that boundary.
- Fixing `sorry`s that already exist at the Phase 1 baseline.
- Broader linter-compliance work, beyond the one unused import above.
- Establishing a recurring cslib pin-sync mechanism (cslib bumps ~monthly; worth its own task).
- Refactoring or deleting `Boneyard/` — 46 of its 89 files are in the build graph and must compile.

---

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| **Silent behavior change in executables** — Lean 4.32 #13912: `return e` inside `(← do …)` now early-returns from the *enclosing* `do` block. Fails no build. | H | M | Phase 1 captures per-executable output baselines; Phase 8 is a dedicated source audit + output diff across all 12 targets. `lake build` is explicitly **not** accepted as the gate for executables. |
| `lake exe cache get` fails -> Mathlib builds from source | H | L | Phase 2 gates on cache success. Failure is a **hard stop** reported to the user, not worked around. Source-building Mathlib would consume the entire task budget. |
| `isDefEq` transparency changes break defeq-dependent proofs | H | H | Phase 5 dedicated to this category. Known sites pre-identified: `Automation/Tactics/Helpers.lean:162,416,467`; `ChronicleToCountermodelBasic.lean:989,1000`. Escape hatches (`@[reducible]`, `backward.isDefEq.respectTransparency`, `simpa using!`) applied deliberately and tracked as debt in Phase 10. |
| Elaboration cost increase (20-50% per 4.31 notes) exhausts heartbeat budgets | H | H | Phase 6 dedicated. 88 existing `set_option maxHeartbeats` sites, up to 64x default. Prefer proof restructuring over unbounded budget escalation; record every bump. |
| Repair volume genuinely unknown until first build | M | H | Structural mitigation: Phase 3 measures before Phases 4-7 fix. Phases resized at that point. |
| Errors unattributable to any known cause -> single jump was wrong call | M | L | D1 fallback trigger, evaluated at end of Phase 3 with a concrete 25% threshold. |
| `v4.33.0-rc1` toolchain not installed locally; network required | M | L | elan fetches on first `lake` call. If offline, `v4.32.0` is the best already-installed fallback — but note it does not fully satisfy the cslib-match goal. |
| Axiom audit prose invalidated (4.29 changed `native_decide` axiom accounting) | M | M | Phase 9 re-verifies `#print axioms` assertions and the audit prose in `Metalogic/Metalogic.lean` and `BXCanonical/Completeness.lean`. |
| Repair introduces `sorry` to reach a green build | H | L | Explicitly forbidden. Every §5 category has a structural fix. If a proof genuinely cannot be repaired, mark the task `[BLOCKED]` for user review rather than deferring with `sorry`. |
| Disk exhaustion (5.7 GB `.lake` already; 63 GB free) | L | L | `lake clean` before the first new build rather than accumulating two full olean trees. |

---

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

Phases within the same wave can execute in parallel. **This plan is fully sequential and no
parallelism is available.** Every repair phase mutates shared `.lean` files and measures progress
by the same global `lake build` error count; running two repair phases concurrently would make
that count uninterpretable and risk edit conflicts in the same files. The one partial exception is
noted in Phase 8 (its source-audit half needs no green build), but its output-diff half does, so
it stays in sequence.

---

### Phase 1: Capture Pre-Upgrade Baselines [COMPLETED]

**Goal**: Produce the reference artifacts every later gate compares against. Nothing here modifies
the repo. This phase is what makes "no regressions" a checkable claim rather than an assertion.

**Tasks**:

- [x] Confirm working tree is clean and record HEAD: `git status --porcelain`, `git rev-parse HEAD`
      (expected `e0158da5e974e7526ea6e7c1db436618fa170e81`; if HEAD has moved, record the new SHA
      and use it for rollback). *(completed — HEAD confirmed at the expected SHA)*
- [x] Create `specs/291_upgrade_lean_toolchain_to_v431_and_mathlib/baseline/`.
- [x] Full build log: `lake build 2>&1 | tee baseline/build.log` *(completed — green, 1789 jobs,
      0 errors, 1024 warnings; stored gzipped as `build.log.gz`)*
- [x] Extract the **authoritative** `sorry` baseline from that log's warning output, not from grep.
      A naive grep returns ~764 hits because this repo discusses `sorry` heavily in docstrings.
      Write the count and the per-file list to `baseline/sorry-baseline.txt`. *(completed —
      **12** sorries across 4 files)*
- [x] Record the warning-count baseline to `baseline/warnings.txt`.
- [x] Test baseline: `lake test 2>&1 | tee baseline/test.log` *(completed — exits 0; note 12/42
      pre-existing failures inside one tactic sub-suite, recorded in `test-summary.txt` so they
      are not later mistaken for upgrade regressions; stored gzipped)*
- [x] **Added**: axiom baseline captured to `baseline/axioms.txt` (4 `#print axioms` assertions)
      — not a plan step, but Phase 9 re-verifies these and needs the before-state.
- [x] Executable output baselines for **all 12** targets, one file each under `baseline/exe/`.
      *(deviation: altered — captured via `lake env lean --run` (interpreter) rather than
      `lake exe`, and three invocations corrected. Full rationale and evidence in
      `baseline/exe/REPRODUCIBILITY.md`. Summary: `lake exe` needs a ~264 MB native link per
      target, requiring every module recompiled as `.c.o.export` at -O3; the 29 MB
      `Syntax/Formula.c` alone burned 30 min CPU / 3.9 GB RSS without finishing, and the set
      would have to be rebuilt post-flip. The 4.32 `do` hazard this gate targets is an
      **elaboration** change, which the interpreter exercises identically. Uncovered by the
      substitution: native codegen/linking — checked separately via `lake build` of the exe
      targets, not folded into this gate.)*
      Invocation corrections, all verified against source:
      `trace_exporter` takes **S-expressions**, not JSON (`TraceExporter.lean:222`) — the plan's
      JSON line produced only a parse-error baseline; `tableau_bridge` does take JSON but needed
      its own envelope, not the `trace_exporter` line; `tableau_proof_steps --max-complexity 3`
      never finishes, shrunk to complexity 2 with reduced seed/wrap counts.
      For targets needing input or flags, use a small fixed input committed under `baseline/exe/`
      inputs so the run is reproducible. Suggested minimal invocations:
      `dataset_validator` (no args); `enum_benchmark` (no args);
      `dataset_generator --max-complexity 3 --output baseline/exe/dataset.jsonl`;
      `proof_extractor --output baseline/exe/proof_steps.jsonl`;
      `benchmark_anchors --output baseline/exe/axiom-instances.jsonl`;
      `contrastive_generator --max-complexity 3 --output baseline/exe/contrastive.jsonl`;
      `tableau_proof_steps --max-complexity 3 --output baseline/exe/tableau_steps.jsonl`;
      `proof_first_generator --max-depth 2 --seed 1000 --output baseline/exe/proof_first.jsonl`;
      `machine_appendix --output baseline/exe/machine-appendix.jsonl` (omit git stamps so output
      is deterministic); `trace_exporter` and `tableau_bridge` are stdin REPLs — feed a fixed
      JSONL line, e.g.
      `echo '{"command":"trace_decide","formula":{"tag":"atom","name":"p"}}' | lake exe trace_exporter`;
      `benchmark_oracle` needs an input file — if no committed sample exists, record that it was
      skipped and why, so Phase 8 does not silently drop it.
- [x] For any target that cannot be run deterministically, write an explicit note in
      `baseline/exe/SKIPPED.md` naming the target and the reason. **A silently missing baseline is
      a hole in the Phase 8 gate** — record it rather than omitting it. *(deviation: altered —
      no target was skipped, so there is nothing for a `SKIPPED.md` to name. The equivalent
      disclosure, and more, is in `baseline/exe/REPRODUCIBILITY.md`, which states the gate
      strength per target rather than only naming omissions.)*
- [x] Note any executable whose output embeds a timestamp, RNG seed, or path so Phase 8 can
      normalize before diffing. *(completed, and taken further: each target was run **twice**
      pre-upgrade and self-diffed, because source reading shows what *could* vary while only a
      second run shows what *does*. Result: **7 targets are exactly reproducible; 5 are not**,
      because they call unseeded `IO.rand` (`FormulaEnumerator.lean:811+`) — two identical
      pre-upgrade `enum_benchmark` runs gave pool sizes 108 vs 98. Those 5 therefore **cannot**
      support a byte-exact diff regardless of the upgrade; they get a structural comparison that
      masks RNG-derived cardinalities and requires everything else to match. Encoded in
      `baseline/normalize.sh` + `baseline/compare-exes.sh`; the harness was validated by
      reporting 0/12 differences between two independent pre-upgrade captures.)*

**Timing**: ~1.5 hours (mostly wall-clock build/run time; light agent work)

**Depends on**: none

**Files to modify**:
- `specs/291_upgrade_lean_toolchain_to_v431_and_mathlib/baseline/**` — new baseline artifacts only.
- No source files touched.

**Verification**:
- [x] `baseline/build.log` exists and is non-empty; ends in a successful build. *(green, 0 errors)*
- [x] `baseline/sorry-baseline.txt` exists with a numeric count derived from build warnings. *(12)*
- [x] `ls baseline/exe/` shows an output artifact or a `SKIPPED.md` entry for each of the 12 targets.
      *(all 12 have `.out`/`.err`/`.exit`; none skipped; per-target gate strength stated in
      `REPRODUCIBILITY.md`)*
- [x] `git rev-parse HEAD` recorded in `baseline/HEAD.txt`. *(`e0158da5e974e7526ea6e7c1db436618fa170e81`)*

**Artifact size note**: `proof_steps.jsonl` (68 MB), `proof_first.jsonl` (28 MB) and
`dataset.jsonl` (1.1 MB) are not committed. Their sha256 + line counts are recorded in
`baseline/exe/data-products.tsv`, which preserves the gate — `proof_steps.jsonl` was verified
byte-identical across two runs, so its digest is an exact check. `build.log`/`test.log` are
committed gzipped.

**Commit**: `task 291 phase 1: capture pre-upgrade baselines`

---

### Phase 2: Flip the Pin and Resolve Dependencies [NOT STARTED]

**Goal**: Change the toolchain and Mathlib pin, remove the two lakefile/import redundancies, and
get a working dependency resolution with a prebuilt Mathlib cache. Committed as **one isolated
commit containing no repair work**, so the pin diff stays cleanly separable and cheaply revertible.

**Tasks**:

- [ ] Edit `lean-toolchain`: replace contents with `leanprover/lean4:v4.33.0-rc1`. Preserve the
      no-trailing-newline style of the current file.
- [ ] Edit `lakefile.lean:8-9`: mathlib rev `"v4.27.0-rc1"` -> `"v4.33.0-rc1"`.
- [ ] Edit `lakefile.lean:11-12`: delete the entire `require plausible from git … @ "main"` block
      (plausible is inherited from Mathlib — verified present in Mathlib's own `lake-manifest.json`
      at `v4.33.0-rc1`). Leave all `lean_lib` / `lean_exe` / `theoryLeanOptions` stanzas untouched.
- [ ] Edit `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/InteriorGateGeneralK.lean:4`:
      delete `import Batteries.Tactic.OpenPrivate`. Verified unused — no `open_private` or
      `export_private` anywhere in the repo, and this is the only `import Batteries` in the tree.
- [ ] `lake update` — regenerates `lake-manifest.json`; elan fetches the v4.33.0-rc1 toolchain
      (network required).
- [ ] `lake exe cache get` — **hard gate**, see below.
- [ ] `lake clean` — remove the stale v4.27 olean tree rather than accumulating two (5.7 GB
      already on disk, 63 GB free).
- [ ] Confirm `Tests/BimodalTest/Syntax/FormulaPropertyTest.lean:3` (`import Plausible`) still
      resolves under the inherited pin — inherited packages are importable, but verify rather than
      assume.

**Timing**: ~1 hour (dominated by toolchain + Mathlib cache download)

**Depends on**: 1

**Files to modify**:
- `lean-toolchain` — toolchain pin
- `lakefile.lean` — mathlib rev; delete plausible require block
- `lake-manifest.json` — regenerated by `lake update`
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/InteriorGateGeneralK.lean` — drop unused import

**Verification**:
- [ ] `cat lean-toolchain` -> `leanprover/lean4:v4.33.0-rc1`
- [ ] `lean --version` reports 4.33.0-rc1
- [ ] `jq -r '.packages[] | select(.name=="mathlib") | .rev, .inputRev' lake-manifest.json` shows
      the v4.33.0-rc1 tag
- [ ] `jq -r '.packages[] | select(.name=="plausible") | .inherited' lake-manifest.json` -> `true`
- [ ] `grep -c "require plausible" lakefile.lean` -> `0`
- [ ] `grep -c "import Batteries" -r Theories/ Tests/` -> `0`
- [ ] **`lake exe cache get` exited 0.** If it did not: **HARD STOP.** Do not proceed and do not
      let Mathlib build from source. Report the failure and mark the task `[BLOCKED]`.

**Commit**: `task 291 phase 2: pin toolchain v4.33.0-rc1 and mathlib v4.33.0-rc1`
(pin change only — no repair edits in this commit)

---

### Phase 3: First Full Build and Categorized Error Inventory [NOT STARTED]

**Goal**: Measure the damage. **Fix nothing.** This phase exists so that Phases 4-7 can be sized
from evidence instead of from a guess, and it is the single most important structural decision in
this plan.

**Tasks**:

- [ ] `lake build 2>&1 | tee /tmp/upgrade-build-01.log` (expect failures — that is the point)
- [ ] Copy the log to `specs/291_upgrade_lean_toolchain_to_v431_and_mathlib/inventory/build-01.log`
- [ ] Write `inventory/01_error-inventory.md` classifying **every** error against the research §5
      taxonomy. Required columns: file, line, error text (truncated), category, originating Lean
      release, proposed fix approach.
- [ ] Categories (from research §5) — use these exact labels:
      `defeq-transparency` (4.29/4.31) · `heartbeat-timeout` (4.31) · `do-elaborator` (4.32) ·
      `simp-instances` (4.29) · `native-decide-axioms` (4.29) · `subgoal-tags` (4.31) ·
      `noncomputable` (4.29) · `meta-api-renames` (4.30) · `range-syntax` (4.28) ·
      `dsimp-no-progress` (4.31 beta-reduction) · `unattributable`
- [ ] Produce a per-category count table and a per-file hot-spot table (which files carry the most
      errors) — Phases 4-7 are sequenced from these.
- [ ] Note whether the build aborted early (so the inventory may under-count downstream modules)
      and roughly how far through the module graph it reached.
- [ ] **Evaluate the D1 staged-fallback trigger.** Record the `unattributable` percentage and the
      early-abort assessment explicitly in the inventory, with a stated verdict:
      `PROCEED single-jump` or `FALL BACK to staged`.
- [ ] Update this plan's `- **Effort**:` field and the Phase 4-7 timings with estimates grounded in
      the inventory.

**Timing**: ~1.5 hours (long build; classification is the agent work)

**Depends on**: 2

**Files to modify**:
- `specs/291_upgrade_lean_toolchain_to_v431_and_mathlib/inventory/**` — new
- `specs/291_upgrade_lean_toolchain_to_v431_and_mathlib/plans/01_lean-toolchain-upgrade.md` — effort/timing update only
- **No `.lean` files. Zero source edits in this phase.**

**Verification**:
- [ ] `inventory/01_error-inventory.md` exists, non-empty, every error assigned a category.
- [ ] Per-category count table present and sums to the total error count.
- [ ] D1 fallback verdict recorded with the supporting `unattributable` percentage.
- [ ] `git diff --stat` shows **no** changes under `Theories/` or `Tests/`.

**Commit**: `task 291 phase 3: first build error inventory (no fixes)`

---

### Phase 4: Mechanical and Low-Risk Repairs [NOT STARTED]

**Goal**: Clear the cheap, unambiguous, loudly-failing categories first. This shrinks the inventory
and reduces noise before the judgement-heavy phases, and it delivers a fast, verifiable win.

**Tasks**:

- [ ] `range-syntax` (4.28, `Std.Range` -> `Std.Legacy.Range`; `[a:b]` -> `a...b`). Exactly 5 sites,
      all confirmed present:
      `Automation/Tactics/Deduction.lean:103` (`for _ in [0:count]`),
      `Automation/DatasetGenerator.lean:1722` and `:1740` (`for i in [:numChunks]`),
      `Tests/BimodalTest/Semantics/SemanticBenchmark.lean:105`,
      `Tests/BimodalTest/ProofSystem/DerivationBenchmark.lean:67`.
      Only fix these if Phase 3 shows them actually failing — the old syntax may still be
      deprecated-but-working.
- [ ] `noncomputable` (4.29 tightening): add annotations where newly required. Mechanical; the
      compiler names the declaration.
- [ ] `subgoal-tags` (4.31): repair `case h => …` names broken by tag renaming. 173 `case` and 240
      `funext` sites exist; only the overlap fails, and it fails loudly with "unknown tag".
- [ ] `meta-api-renames` (4.30): research found **zero** hits for the renamed APIs
      (`isStructureLike`, `compileDecl`, `addAndCompile`). Expect this category to be empty —
      if Phase 3 populated it, that is new information worth flagging.
- [ ] `dsimp-no-progress`: 4.31 beta-reduces arguments during substitution, making some previously
      necessary `dsimp only` steps useless. 33 candidate sites. Delete the now-redundant step
      rather than suppressing the error.
- [ ] Re-run `lake build`; record the new error count against the Phase 3 total.

**Timing**: ~2 hours

**Depends on**: 3

**Files to modify**: Determined by the Phase 3 inventory. Known candidates listed above.

**Verification**:
- [ ] `lake build` error count is **strictly lower** than Phase 3's.
- [ ] Every error in the four categories above is either resolved or explicitly re-classified in
      the inventory with a reason.
- [ ] `sorry` count unchanged from `baseline/sorry-baseline.txt`.
- [ ] `git diff` contains no `sorry` additions.

**Commit**: `task 291 phase 4: mechanical repairs (range syntax, noncomputable, subgoal tags)`

---

### Phase 5: Definitional-Equality and Transparency Repairs [NOT STARTED]

**Goal**: Repair the highest-risk category — Lean 4.29's "the `isDefEq` algorithm no longer bumps
transparency to `.default`" and 4.31's "definitional equality now strictly respects transparency
levels", both of which the Lean team labelled disruptive.

**Tasks**:

- [ ] Repair the three direct `isDefEq` call sites in `Automation/Tactics/Helpers.lean`:
      `:162` (`assumption_search`, iterating the local context),
      `:416` (`modal_4_tactic`), `:467` (`modal_b_tactic`). These now compare at the ambient
      transparency rather than silently at `.default`; decide per site whether to wrap in
      `withDefault` / `withReducible` explicitly rather than relying on the old implicit behavior.
- [ ] Repair the defeq-dependent proofs in
      `Metalogic/BXCanonical/Chronicle/ChronicleToCountermodelBasic.lean:989` and `:1000`
      (`@Order.succ`/`@Order.pred` under a `letI`-registered instance stated as *definitionally*
      equal to `limitDomSubtype_succ`/`_pred`; the docstring at `:983` justifies this via how
      `SuccOrder.ofSuccLeIff` unfolds). `SuccOrder.ofSuccLeIff` itself was verified unchanged in
      current Mathlib, so the break is in unfolding behavior, not the API.
- [ ] `simp-instances` (4.29, instance processing off by default): apply `simp +instances` at
      failing sites. Prefer the targeted per-call form over the global
      `set_option backward.dsimp.instances true`. Instance-dense sites to expect:
      `Metalogic/Soundness.lean:1341`,
      `Metalogic/SoundnessLemmas/FrameClassVariants.lean:700`,
      and the `letI` registrations at `ChronicleToCountermodelBasic.lean:923,976`.
- [ ] `simpa` failures (398 sites total; only a subset will fail): the documented migration is
      `simpa using` -> `simpa using!`.
- [ ] `inferInstanceAs` (18 sites): 4.30 requires an exact expected-type match and removed its use
      as an `inferInstance` synonym.
- [ ] Where a plain `def` must unfold inside `simp`/`dsimp`, prefer marking it `@[reducible]` over
      applying a `backward.*` option. The repo has 107 `abbrev` but only 1 `@[reducible]`, so this
      is a sparsely-used tool here — using it is fine and is the intended migration.
- [ ] **Track every `backward.*` option added** in `inventory/backward-options.md` (file, line,
      option, why). Phase 10 removes what it can. Consider Mathlib's `scripts/add_set_option.py`
      for bulk application and `#defeq_abuse` for diagnosis if the site count is large.
- [ ] Re-run `lake build`; record the new error count.

**Timing**: ~2 hours (resize from Phase 3 inventory; this category may need splitting into 5a/5b)

**Depends on**: 4

**Files to modify**:
- `Theories/Bimodal/Automation/Tactics/Helpers.lean` — three `isDefEq` sites
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodelBasic.lean` — defeq proofs
- Additional files per Phase 3 inventory (`defeq-transparency` and `simp-instances` rows)

**Verification**:
- [ ] `lake build` error count strictly lower than Phase 4's.
- [ ] `inventory/backward-options.md` lists every `backward.*` option added, with justification.
- [ ] `sorry` count unchanged from baseline.
- [ ] The three `Helpers.lean` tactics (`assumption_search`, `modal_4_tactic`, `modal_b_tactic`)
      still compile **and** their existing test coverage still passes — a tactic that compiles but
      no longer fires is a silent regression in the same family as the `do` issue.

**Commit**: `task 291 phase 5: defeq transparency and simp instance repairs`

---

### Phase 6: Heartbeat and Elaboration-Budget Repairs [NOT STARTED]

**Goal**: Resolve `(deterministic) timeout` failures caused by the 4.31 elaboration-cost increase
(upstream reports tests needing 20-50% `maxHeartbeats` increases) landing on a codebase already
running at up to 64x the default budget.

**Tasks**:

- [ ] For each timeout in the inventory, **first attempt a structural fix** — a more targeted
      `simp` set, an intermediate `have`, splitting a large proof — before raising the budget.
      This repo already has 88 `set_option maxHeartbeats` sites (29 at 8x, 21 at 16x, one at 64x);
      unbounded escalation makes the corpus progressively harder to build and defers the problem.
- [ ] Where a bump is genuinely the right call, raise by the smallest increment that succeeds and
      record the before/after value in `inventory/heartbeat-changes.md`.
- [ ] Expect the heaviest files to dominate:
      `Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/SharedWitness.lean` (12,800 lines),
      `Boneyard/StrictSemanticsLegacy/Bundle/SuccChainFMCS.lean` (6,147),
      `Metalogic/WeakCanonical/EFGames/GapDetection.lean` (5,056),
      `Metalogic/WeakCanonical/Expressiveness/SplitPoint.lean` (4,693).
- [ ] Remember `Boneyard/` cannot be skipped: 46 of its 89 files are reachable from the default
      target and must compile.
- [ ] Consider `lean_profile_proof` (lean-lsp MCP) on the worst offenders to locate the actual
      hotspot rather than guessing at the budget.
- [ ] Re-run `lake build`; record the new error count.

**Timing**: ~2 hours (resize from inventory; timeouts fail slowly, so wall-clock may exceed this)

**Depends on**: 5

**Files to modify**: Per Phase 3 inventory `heartbeat-timeout` rows; heavy files listed above.

**Verification**:
- [ ] `lake build` error count strictly lower than Phase 5's; zero `(deterministic) timeout` errors.
- [ ] `inventory/heartbeat-changes.md` records every budget change with before/after values.
- [ ] Total `set_option maxHeartbeats` site count reported (was 88) so budget creep is visible.
- [ ] `sorry` count unchanged from baseline.

**Commit**: `task 291 phase 6: heartbeat and elaboration budget repairs`

---

### Phase 7: Long-Tail Repairs to Green Build [NOT STARTED]

**Goal**: Clear whatever remains and reach a zero-error `lake build`. This phase absorbs the
inventory's residue — including anything that landed in `unattributable`.

**Tasks**:

- [ ] Work remaining inventory rows in descending per-file error count (hot spots first).
- [ ] For each `unattributable` error, determine the actual cause and **add a new row to the §5
      taxonomy** in the inventory. These are the genuinely new findings of this upgrade and are
      the most valuable thing to write down.
- [ ] If this phase's scope exceeds one agent run, split into 7a/7b/… by file group and commit each
      green sub-step separately — do not hold a large repair diff uncommitted.
- [ ] **Zero-debt rule**: do not introduce `sorry` to reach green. Every §5 category has a
      structural fix. If a specific proof genuinely cannot be repaired under the new elaborator,
      stop and mark the task `[BLOCKED]` for user review rather than deferring with `sorry`.
- [ ] Final `lake build` must be clean.

**Timing**: Sized at Phase 3 (placeholder: 3 hours). Split if it exceeds one agent run.

**Depends on**: 6

**Files to modify**: Per remaining Phase 3 inventory rows.

**Verification**:
- [ ] `lake build` exits 0 with **zero errors**.
- [ ] `sorry` count from build warnings equals `baseline/sorry-baseline.txt` exactly — zero net new.
- [ ] Every inventory row marked resolved, re-classified, or explicitly deferred with a reason.
- [ ] `git diff` against the Phase 2 commit contains no `sorry` additions.

**Commit**: `task 291 phase 7: long-tail repairs to green build`

---

### Phase 8: `do`-Elaborator Semantic Audit and Executable Output Diff [NOT STARTED]

**Goal**: Catch the one change in this upgrade that a green build cannot detect. **This phase is
the reason "`lake build` passes" is not the definition of done for this task.**

Lean 4.32 (#13912): `return e` inside `(← do …)` or `(← try … catch …)` now early-returns from the
**enclosing** `do` block rather than the nested one. No compile error. The repo's exposure is
concentrated exactly where it hurts: 12 `IO`-heavy `lean_exe` targets, 241 `let mut`, 15 `catch`,
10 `try`.

**Tasks**:

- [ ] **Source audit** (needs no build): grep for `return` appearing inside a nested action
      `(← do …)` or `(← try … catch …)` across `Theories/Bimodal/Automation/`. Prioritize the
      `do`-heaviest modules: `DatasetGenerator.lean`, `TableauProofStepPipeline.lean`,
      `FormulaEnumerator.lean`, `ForwardProofGenerator.lean`, `BenchmarkOracle.lean`,
      `TableauBridge.lean`. For each hit, determine whether the intent was to return from the
      nested block; if so, migrate to `pure e` or re-wrap as `(← (do …))`.
- [ ] Audit the other 4.32 `do` changes surfaced by the new default elaborator: `do` now requires a
      `Pure` instance (not just `Bind`); `do match` arms are non-dependent by default
      (`do match (dependent := true)` restores the old behavior); `try`/`catch` no longer accepts
      bodies whose result type matches only via coercion; `let pat := rhs | otherwise` now scopes
      over the following `doSeq`.
- [ ] **Output diff**: re-run all 12 executables with the **exact** invocations recorded in Phase 1
      and diff each against its baseline artifact.
- [ ] Normalize the fields Phase 1 flagged as nondeterministic (timestamps, seeds, absolute paths)
      before diffing — but normalize narrowly. Do not normalize away a field just because it
      differs; a changed value is precisely the signal this phase exists to detect.
- [ ] For every non-empty diff: determine root cause before accepting it. An "improvement" or
      "reordering" is not automatically benign.
- [ ] Record results per target in `inventory/exe-diff.md`, including any target skipped in
      Phase 1 and therefore **not** covered by this gate.

**Timing**: ~2 hours

**Depends on**: 7

**Files to modify**:
- `Theories/Bimodal/Automation/**` — nested-`return` and `do`-elaborator migrations
- `specs/291_upgrade_lean_toolchain_to_v431_and_mathlib/inventory/exe-diff.md` — new

**Verification**:
- [ ] All 12 targets run successfully (or are listed in `exe-diff.md` with the Phase 1 skip reason).
- [ ] Every diff is either empty or explained with an accepted root cause.
- [ ] Zero unexplained output differences.
- [ ] `lake build` still green after any `do` migrations.

**Commit**: `task 291 phase 8: do-elaborator audit and executable output verification`

---

### Phase 9: Test Suite and Axiom Audit Re-Verification [NOT STARTED]

**Goal**: Confirm the test suite passes and that this repo's deliberate axiom audit is still
accurate — 4.29 changed `native_decide`/`bv_decide` to emit one axiom per computation instead of
using `Lean.trustCompiler`, which changes `#print axioms` output.

**Tasks**:

- [ ] `lake test` (driver is `BimodalTest`); compare against `baseline/test.log`.
- [ ] Re-verify the remaining live `native_decide` sites:
      `Metalogic/Decidability/SignedFormula.lean:126,132,133,138` and
      `Boneyard/StrictSemanticsLegacy/Bundle/SuccChainFMCS.lean:410`.
- [ ] Re-verify the axiom-audit **prose**, which the 4.29 change may have invalidated:
      `Metalogic/Metalogic.lean:57` (describes swapping Syntax-layer `native_decide` to
      `rfl`/`decide`, referencing an "Axiom Audit") and
      `Metalogic/BXCanonical/Completeness.lean:386,390` (records 7 in-cone sites swapped, 4
      remaining). Update the prose if the counts or axiom names no longer match reality.
- [ ] Re-verify the `PropDecide.lean:21` and `:80` claims that the tactic "never emits
      `native_decide`" — check it, do not trust the comment.
- [ ] Update any `#print axioms`-based assertions whose expected output changed.
- [ ] Confirm `Tests/BimodalTest/Syntax/FormulaPropertyTest.lean` still compiles under the
      inherited plausible pin (its ~18 quarantined blocks remain commented out per D2).

**Timing**: ~1.5 hours

**Depends on**: 8

**Files to modify**:
- `Theories/Bimodal/Metalogic/Metalogic.lean` — audit prose, if invalidated
- `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` — audit prose, if invalidated
- `Theories/Bimodal/Automation/Tactics/PropDecide.lean` — claim re-verification
- Test files carrying `#print axioms` assertions

**Verification**:
- [ ] `lake test` passes; no test regressed relative to `baseline/test.log`.
- [ ] Every `#print axioms` assertion matches actual output.
- [ ] Axiom-audit prose re-verified and corrected where stale (state explicitly that it was
      checked, even when no change was needed).

**Commit**: `task 291 phase 9: test suite and axiom audit re-verification`

---

### Phase 10: Compatibility-Option Debt Sweep and Wrap-Up [NOT STARTED]

**Goal**: Leave the repo in a defensible end state rather than one propped up by backward-compat
escape hatches, and record the follow-up work this task deliberately did not do.

**Tasks**:

- [ ] For each entry in `inventory/backward-options.md`, remove the option and rebuild that file.
      Keep it only if removal actually re-breaks the proof. Mathlib's `scripts/rm_set_option.py`
      automates finding workarounds that are no longer needed.
- [ ] Same treatment for Phase 6 heartbeat bumps: retry the smaller value where a structural fix
      was later applied to the same file.
- [ ] Final full verification from a clean state: `lake clean && lake exe cache get && lake build`.
- [ ] Re-run `lake test` and a spot-check of the executable diffs from Phase 8.
- [ ] Write `summaries/01_lean-toolchain-upgrade-summary.md` covering: actual repair volume by
      category (the honest answer to the "~50-200 lines" question), any remaining `backward.*`
      options and why, new taxonomy rows discovered in Phase 7, and residual risk.
- [ ] Record follow-up task recommendations (do **not** create them here):
      (1) re-enable the ~18 quarantined Plausible property tests under the inherited pin (D2);
      (2) recurring cslib pin-sync check, since cslib bumps roughly monthly and this pin will drift;
      (3) meta task for the `skill-lean-version` backup/documentation defect (D3).
- [ ] Confirm the working tree contains no stray baseline/inventory artifacts that should not be
      committed, and that `lake-manifest.json` is committed.

**Timing**: ~1.5 hours

**Depends on**: 9

**Files to modify**:
- Files carrying `backward.*` options or heartbeat bumps that proved removable
- `specs/291_upgrade_lean_toolchain_to_v431_and_mathlib/summaries/01_lean-toolchain-upgrade-summary.md` — new

**Verification**:
- [ ] `lake clean && lake exe cache get && lake build` green from scratch.
- [ ] `lake test` passes.
- [ ] Remaining `backward.*` options enumerated in the summary, each with a justification.
- [ ] Summary written with actual repair volume by category.
- [ ] Follow-up recommendations recorded.

**Commit**: `task 291 phase 10: compatibility option sweep and wrap-up`

---

## Testing & Validation

- [ ] `lake build` exits 0 with zero errors from a clean `.lake/build`.
- [ ] `sorry` count (from build warnings, **not** grep) equals the Phase 1 baseline exactly.
- [ ] `lake test` passes with no regression against `baseline/test.log`.
- [ ] All 12 `lean_exe` targets produce output matching Phase 1 baselines, modulo documented
      normalization. Any target skipped at baseline is named explicitly as an uncovered gap.
- [ ] `lean --version` reports `4.33.0-rc1`; `lake-manifest.json` shows mathlib at the
      `v4.33.0-rc1` tag and plausible as `inherited: true`.
- [ ] No `require plausible` in `lakefile.lean`; no `import Batteries` anywhere in the tree.
- [ ] `#print axioms` assertions match actual output; axiom-audit prose re-verified.
- [ ] Every remaining `backward.*` compatibility option is justified in the summary.

---

## Artifacts & Outputs

- `specs/291_upgrade_lean_toolchain_to_v431_and_mathlib/plans/01_lean-toolchain-upgrade.md` (this file)
- `specs/291_upgrade_lean_toolchain_to_v431_and_mathlib/baseline/` — build log, sorry baseline,
  warning baseline, test log, `HEAD.txt`, per-executable output baselines, `exe/SKIPPED.md`
- `specs/291_upgrade_lean_toolchain_to_v431_and_mathlib/inventory/01_error-inventory.md` — the
  categorized Phase 3 measurement that sizes Phases 4-7
- `specs/291_upgrade_lean_toolchain_to_v431_and_mathlib/inventory/backward-options.md`
- `specs/291_upgrade_lean_toolchain_to_v431_and_mathlib/inventory/heartbeat-changes.md`
- `specs/291_upgrade_lean_toolchain_to_v431_and_mathlib/inventory/exe-diff.md`
- `specs/291_upgrade_lean_toolchain_to_v431_and_mathlib/summaries/01_lean-toolchain-upgrade-summary.md`
- Modified: `lean-toolchain`, `lakefile.lean`, `lake-manifest.json`, plus repair edits across
  `Theories/` and `Tests/`

---

## Rollback/Contingency

**Rollback is git.** `skill-lean-version` is deliberately not used (D3): its backup step does not
actually cover `lake-manifest.json` despite its documentation claiming otherwise, and it requires
`AskUserQuestion`, which is unavailable under `orchestrator_mode: true`.

Pre-upgrade HEAD: `e0158da5e974e7526ea6e7c1db436618fa170e81` (tree clean; `lean-toolchain`,
`lakefile.lean`, `lake-manifest.json` all tracked). Phase 1 re-confirms this and writes it to
`baseline/HEAD.txt` — use that recorded value if HEAD has since moved.

**Full revert to the pre-upgrade pin**:

```bash
git checkout <baseline-HEAD> -- lean-toolchain lakefile.lean lake-manifest.json
lake clean && lake exe cache get && lake build
```

**Partial rollback**: the Phase 2 pin commit contains no repair work, so repair phases can be
reverted individually (`git revert <phase-commit>`) while keeping the new pin — useful if one
repair phase turns out to be wrong but the upgrade itself is sound.

Before any destructive git operation on a dirty tree, run `bash .claude/scripts/git-snapshot.sh`
first (required by `.claude/rules/git-workflow.md`).

**Contingency triggers**:

| Trigger | Response |
|---|---|
| `lake exe cache get` fails (Phase 2) | **Hard stop.** Mark `[BLOCKED]`, report. Never let Mathlib build from source. |
| >25% `unattributable` errors, or unrepresentative early-abort build (Phase 3) | Roll back to the pre-upgrade pin and restart Phase 2 targeting `v4.29.0`; repeat Phases 3-7 per stage (D1). |
| No network for the v4.33.0-rc1 toolchain | Fall back to already-installed `v4.32.0` — but flag prominently that this does **not** fully satisfy the cslib-match goal and porting skew remains. |
| A proof genuinely cannot be repaired under the new elaborator | Mark task `[BLOCKED]` for user review. Do **not** `sorry` the goal. |
| Executable output diff cannot be explained (Phase 8) | Do not accept the diff. Treat as a hard blocker — this is exactly the silent regression the phase exists to catch. |
