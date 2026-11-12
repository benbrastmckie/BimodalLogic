# Implementation Plan: Task #714

- **Task**: 714 - Evaluate full labels in the sliced certificate
- **Status**: [COMPLETED]
- **Effort**: 4.25 hours
- **Dependencies**: None
- **Research Inputs**: specs/714_evaluate_full_labels_in_sliced_certificate/reports/01_full-labels-sliced-certificate.md
- **Artifacts**: plans/01_full-labels-sliced-certificate.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

The research round answered the task's four questions and **refuted option 3**: decidability
survives full labels, but full labels collapse the comparison class of `PlusTruthAt`'s `stab`
clause to a singleton, kill both landed `⊡`-carrying witnesses outright (empty `posAtFull`), and
still admit a non-live position at `Fixture.cert`. There is therefore no refactor of the
certificate class to perform. What remains is to make the refutation durable and the one positive
by-product permanent: land the probe's three embedded-route equalities as library regression
theorems, promote the probe itself out of the task directory into the tracked evidence
collection and wire it into the probe gate, and record at `Position.lean`'s header what the
`posAt` over-approximation *buys*. Done when the three equalities are library declarations, the
probe is a WIRED evidence probe that `check-evidence-probes.sh` compiles, `Position.lean`'s
header states the `⊡`-comparison-class argument, and the repository's full gate set is green.

### Research Integration

Every finding this plan acts on is already measured at `decide` level in
`probes/FullLabels.lean` (zero sorries, axioms `[propext, Classical.choice, Quot.sound]`):

- **F1/D1** — decidability survives full labels; the deferral note's stated reason was a rework
  cost, not a decidability loss. No code change follows; this is recorded, not implemented.
- **F2/D2** — the binding obstruction is `⊡`: label multiplicity over one state at one time is
  the `stab` clause's comparison class. This is the content of R2, implemented as Phase 3.
- **F3** — both `⊡`-carrying witnesses have an EMPTY full-label position space; the slab is a
  state description, not a type. Kept as probe Part A (Phase 2).
- **F4/D3** — `posAtFull t = liveAt t` at every window time at all three embedded certificates.
  This is R3, implemented as Phase 1.
- **F5/D5** — full labels do not make junk positions impossible, and the `⊇` superset failure
  survives independently. Kept as probe Part E (Phase 2).
- **F6/D4** — no weaker label refinement exists; "refine `posAt`" and "keep the filter" are the
  same computation at two places. Recorded, not implemented.
- **R1/D6** — the landed option-1 two-filter design stands. Nothing in `Stable.lean` changes.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No `roadmap_path` was provided in this dispatch's delegation context; no roadmap phases are
included.

## Goals & Non-Goals

**Goals**:

- `posAtFull`, `botSnce_posAtFull_eq_liveAt`, `botUntl_posAtFull_eq_liveAt` and
  `liveFamily_posAtFull_eq_liveAt` -- the full-label position space and the three embedded-route
  equalities, landed in `EmbedComplete.lean` as a permanent regression triple.
- Promote `probes/FullLabels.lean` into `specs/evidence/` and wire it into
  `scripts/check-evidence-probes.sh`, so the option-3 refutation survives task archival.
- Record at `Position.lean`'s header what the `posAt` over-approximation buys: the `⊡`
  comparison class.
- Leave the landed two-filter design (`TailStable`, `TailStableMirror`, `fwdLiveAt`,
  `bwdLiveAt`) byte-for-byte unchanged.

**Non-Goals**:

- Implementing option 3 in any form. It is refuted; `AgreesOnState`, `posAt` and `Certifies`
  keep their current definitions.
- Opening the option-4 shape (full labels plus an explicit state-sharing relation, with a
  quotient frame carrier). Research R4 prices this as a parallel subtree with its own soundness,
  completeness and limit development; it should only be opened against a stated benefit the
  two-filter design does not already give.
- The `⊇` superset repair (absorbing `Fixture.cert`'s pre-period into `mid`). Research R5 leaves
  it where it is; no label refinement reaches it.
- Creating `context/project/lean4/domain/position-overapproximation.md`. That file's edit target
  resolves through `.claude-extensions.json` to the `lean` extension's `source_dir`
  (`~/.config/nvim/agent-system/extensions/lean`), which does not exist on this repository's
  filesystem. Per `.claude/rules/source-store-deploy-boundary.md`'s Task Siting subsection, a
  task whose edit target is a source-store path must be created in the repository that holds
  that `source_dir`; it cannot be done from here. The durable in-repo home for the same content
  is `Position.lean`'s header (Phase 3).
- Promoting `posAtFull` into `Position.lean`. Research R3 is explicit: state it locally in
  `EmbedComplete.lean` so no consumer of `posAt` is touched.

## Lean Challenge Statements

The four identifiers named under **Goals** above, with their exact intended signatures. The
namespace shown is the siting Phase 1 specifies (`WitnessFamily.FullLabelRegression`, opened
after `end BotTargets` and inside the file's own `namespace WitnessFamily`); the implementer
confirms name resolution at that site and adjusts qualification only, never the statements.

```lean
import FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.EmbedComplete

namespace FormalSystem.Metalogic.Decidability.WitnessFamily.FullLabelRegression

open FormalSystem.PlusLanguage
open FormalSystem.Metalogic.Decidability.PlusSlicedCertificate

/-- The position space under FULL labels: option 3's `posAt`, stated locally so that no
consumer of the landed `posAt` is touched. -/
def posAtFull {Γ Del : PlusContext} (G : PlusSlicedCertificate Γ Del) (t : ℤ) :
    Finset G.Pos :=
  sorry

/-- At the `⊥ S ⊥` certificate that forced the backward filter, the full-label position space
is exactly the computed live set at every window time. -/
theorem botSnce_posAtFull_eq_liveAt :
    ∀ t ∈ (BotTargets.botSnceFamily.sliced 0).winTimes,
      posAtFull (BotTargets.botSnceFamily.sliced 0) t
        = (BotTargets.botSnceFamily.sliced 0).liveAt t :=
  sorry

/-- The same at the `⊥ U ⊥` certificate that forced the forward filter. -/
theorem botUntl_posAtFull_eq_liveAt :
    ∀ t ∈ (BotTargets.botUntlFamily.sliced 0).winTimes,
      posAtFull (BotTargets.botUntlFamily.sliced 0) t
        = (BotTargets.botUntlFamily.sliced 0).liveAt t :=
  sorry

/-- And at the embedded live-eventuality certificate, whose raw demand also fails today. -/
theorem liveFamily_posAtFull_eq_liveAt :
    ∀ t ∈ (Embedded.liveFamily.sliced (-1)).winTimes,
      posAtFull (Embedded.liveFamily.sliced (-1)) t
        = (Embedded.liveFamily.sliced (-1)).liveAt t :=
  sorry

end FormalSystem.Metalogic.Decidability.WitnessFamily.FullLabelRegression
```

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| The three `decide`s measurably raise `EmbedComplete.lean`'s build cost | M | M | Each carries the probe's own explicit finite `maxHeartbeats 2000000` / `maxRecDepth 4000000` envelope (research R4 risk R4), so a cost regression fails the build rather than slowing it silently. These are the cheapest fixpoints in the subtree (`posAt` cardinality 2 over four or six window times). |
| The pre-commit hook refuses Phase 1's and Phase 3's commits on `typst/generated/status.typ` drift | H | H if unscheduled | Both phases schedule `scripts/typst-sync-check.sh --fix` as explicit in-phase work and carry `typst/generated/status.typ` in their own file scope. The hook is BLOCKING, not auto-regenerating, and fires on any staged `.lean` path. |
| `--emit-inventory` rewrites inventory blocks in READMEs owned by concurrent sibling tasks | M | M | Siblings 817 and 818 hold `file_scope` on several `FormalSystem/Metalogic/**/README.md` files this task does not claim. Stage only this task's own files with an explicit `git add -- <file> <file>` list, never a directory or glob, and read `git status --short` before every commit. If `--emit-inventory` dirties a sibling-owned README, leave it unstaged and report it. |
| `EmbedComplete.lean` crosses the `longFile` acceptance window | L | L | The file is 1548 lines with `set_option linter.style.longFile 1700`. At any length below 1700 the linter's `candidate` is 1700 or 1800, and 1700 is accepted in both windows. Phase 1 adds roughly 60 lines; its Scope Hypothesis names the check. |
| C27 rejects a `#eval` or `#print axioms` line carried over from the probe into `FormalSystem/` | M | M | C27 gates every live `#check`/`#eval`/`#print`/`#reduce` under `FormalSystem/` against `scripts/debug-artifact-allowlist.txt`. Phase 1 promotes the three theorems and the local `def` ONLY -- no `#eval`, no `#print axioms`. Those lines stay in the evidence probe, which is outside C27's scope. |
| The promoted probe rots against a later API change | L | M | That is exactly what wiring it into `check-evidence-probes.sh` prevents: the gate compiles it on every CI run under the no-weakening repair rule. |
| A concurrent sibling's `lake` build collides with this task's build or with the probe gate's `.lake` read | M | M | Route every build through `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- ...`; `check-evidence-probes.sh` takes the same `.lake/build-guard.lock` exclusively. Treat an unexplained failure in a file outside this task's `file_scope` as possibly a sibling's in-flight edit, per the dispatch's concurrency note. |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |

Phases within the same wave can execute in parallel. This plan's chain is linear: Phase 2 moves
the file whose Parts C/D Phase 1 promotes, and Phase 3's prose cites the path Phase 2 creates.

---

### Phase 1: Land the embedded-route regression triple in `EmbedComplete.lean` [COMPLETED]

**Goal**: The three embedded-route equalities become library declarations, pinning the
checkable form of "the embedding produces no junk positions" independently of option 3.

**Tasks**:

- [x] Re-read `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/EmbedComplete.lean`
      immediately before editing (concurrent siblings are live on this tree).
- [x] Open a new `namespace FullLabelRegression` directly after `end BotTargets`, inside the
      file's own `namespace WitnessFamily`, preceded by a `/-! ### ... -/` section header stating
      what the triple pins and that it is a fact about the EMBEDDING, not about full labels:
      full-label agreement alone does not imply it (`Fixture.cert` is the counterexample, kept in
      the evidence probe).
- [x] Add `def posAtFull` with the signature fixed in `## Lean Challenge Statements`, bodied as
      `Finset.univ.filter (fun p => LabCoherent Γ Del p.2.1 ∧ p.2.1 = G.slab t p.1)` -- the
      probe's definition verbatim, mirroring `Position.lean`'s `posAt` clause-for-clause. Give it
      a docstring (C19 docstring-coverage floor).
- [x] Add the three theorems with the statements fixed in `## Lean Challenge Statements`, each
      proved `by decide` under its own `set_option maxRecDepth 4000000 in` /
      `set_option maxHeartbeats 2000000 in` declaration-scoped prefix (C30 forbids an unscoped or
      infinite heartbeat budget; the `in` form and a finite literal are both required). Carry each
      theorem's docstring across from the probe. *(deviation: altered — each `set_option
      maxHeartbeats` prefix also needed an adjacent `--` justification comment, in
      `Examples.lean`'s existing house style, to silence `linter.style.maxHeartbeats`, which the
      plan did not anticipate.)*
- [x] Confirm the added block contains NO `#eval`, `#print axioms`, `#check` or `#reduce` line
      (C27 gates these under `FormalSystem/` against `scripts/debug-artifact-allowlist.txt`).
- [x] Confirm no added prose carries a `file.lean:NNN` citation (C20) and no added comment carries
      a relative markdown link that does not resolve from this file (C32).
- [x] Regenerate the commit-blocking count surface: `bash scripts/typst-sync-check.sh --fix`.
- [x] Regenerate the inventory blocks:
      `bash scripts/check-module-invariants.sh --emit-inventory`.
- [x] Stage with an explicit file list and commit.

**Timing**: 1.5 hours

**Depends on**: none

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: the added block is roughly 60 lines, keeping `EmbedComplete.lean` below
1700 lines so its `set_option linter.style.longFile 1700` stays inside the linter's acceptance
window (`candidate = max(1500, (lines / 100) * 100 + 200)`, accepted at `{candidate - 100,
candidate}`). Confirm with `wc -l` after the edit; if the file reaches 1700 lines or more, bump
the baseline to that length's own `candidate` in this same phase rather than deferring it.

**Tier Justification**: `suite_selection_select` returns `__FULL_SWEEP__` for every path in this
phase (measured, no shell suite maps to any of them), and the covering check for a single-module
Lean addition with no externally visible signature change is
`bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.EmbedComplete`
together with the two generated-surface checks named below.

**Files to modify**:

- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/EmbedComplete.lean` - add the
  `FullLabelRegression` namespace: `posAtFull` plus the three equalities.
- `typst/generated/status.typ` - regenerated `formalsystem-line-count` (commit-blocking; the
  pre-commit hook refuses this phase's own commit on drift).
- `README.md` - regenerated `inventory dir=FormalSystem rows=totals` block.
- `FormalSystem/Metalogic/README.md` - regenerated `rows=subdirs cols=files-lines` block, whose
  `Decidability/` row carries a line count.

**Verification**:

- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.EmbedComplete`
  exits 0 (prefer the foreground `timeout 600 <guard call>` form with the Bash tool `timeout`
  parameter raised to 600000; otherwise detach as a shell-level background job and block on it
  with the bounded single-call idiom).
- `bash scripts/typst-sync-check.sh --counts-only` exits 0.
- `bash scripts/check-module-invariants.sh --emit-inventory --check` exits 0.
- `grep -nE '^#(eval|check|print|reduce)' ` over the file reports no occurrence inside the added
  block.
- `wc -l` on `EmbedComplete.lean` confirms the Scope Hypothesis above.

---

### Phase 2: Promote the probe into `specs/evidence/` and wire it into the probe gate [COMPLETED]

**Goal**: The option-3 refutation becomes a tracked, task-independent, gate-compiled evidence
probe instead of a file that leaves version control the moment this task is archived.

**Why this phase exists** (not in the research report's recommendation list, added at planning
time): `scripts/check-evidence-probes.sh`'s own header states the doctrine. A probe records a
design obstruction and outlives the task that produced it; it must live under `specs/evidence/`
and be WIRED **before** that task is archived, because `/todo` moves task directories to
`specs/archive/`, which `.gitignore` excludes -- every file under the moved directory leaves
version control in that one commit while staying on disk for whoever already had it. The header
records this happening once already, unannounced.

**Tasks**:

- [x] `git mv specs/714_evaluate_full_labels_in_sliced_certificate/probes/FullLabels.lean specs/evidence/stability-modal-substrate/full-labels-collapse-stab.lean`
      (the `stability-modal-substrate/` collection is the thematically correct home -- it already
      holds `closure-field-is-necessary`).
- [x] Add the four-line Apache-2.0 copyright header the collection's existing probe carries.
- [x] Rewrite the module docstring to the evidence-probe shape: the decision this probe holds in
      place (option 3 is refuted; the landed two-filter design stands), and the argument.
- [x] Keep Part A (`certA_target_not_full`, `certB_target_not_full`,
      `certA_slab_not_labCoherent`, `certA_posAtFull_empty`, `certB_posAtFull_empty`), Part B
      (`certA_live_multiplicity`, `certB_live_multiplicity`) and Part E (the `⊇` measurements)
      verbatim -- these are the refutation and have no library home.
- [x] Replace Parts C and D's three theorems with a one-paragraph pointer to the library
      declarations Phase 1 landed, naming them. Precedent for this exact move is the
      `lcu-lcn-separation/lcu-lcn-separating-model` entry, whose note records that declarations
      it once proved locally are now library declarations and that the probe keeps only its
      witness and headline. Keep Parts C/D `#eval` readouts only where they measure something the
      library theorems do not state.
- [x] Add the probe's documentation row to the `probe | the decision it holds in place` table
      immediately above the `WIRED=(` array in `scripts/check-evidence-probes.sh`, following the
      column widths the existing rows use.
- [x] Add `"stability-modal-substrate/full-labels-collapse-stab"` to the `WIRED=(` array (entries
      are `<dir>/<basename>` with no `.lean` suffix; `check_probe` resolves them against
      `specs/evidence/`). Do NOT use `WIRED_REPO` -- that form is for a probe that cannot yet be
      moved into the collection, and this one can.
- [x] Append a one-line pointer under the research report's `### Probe` appendix heading giving
      the probe's new path, so the record does not name a path that no longer exists.
- [x] Stage with an explicit file list and commit.

**Timing**: 1 hour

**Depends on**: 1

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: exactly one probe file moves and exactly one `WIRED` entry plus one table
row is added; no other `WIRED`/`WIRED_REPO`/`DEFERRED` entry changes. Confirm with
`git diff --stat` and by diffing the `WIRED=(` array against its pre-phase content.

**Tier Justification**: `suite_selection_select` returns `__FULL_SWEEP__` for every path in this
phase (measured), and the covering check is the probe gate itself --
`bash scripts/check-evidence-probes.sh`, which compile-checks the moved file under `lake env lean`
and asserts it is tracked by git.

**Files to modify**:

- `specs/evidence/stability-modal-substrate/full-labels-collapse-stab.lean` - new, the promoted
  probe (Parts A, B, E plus a pointer paragraph for the promoted C/D).
- `specs/714_evaluate_full_labels_in_sliced_certificate/probes/FullLabels.lean` - removed by the
  `git mv`.
- `scripts/check-evidence-probes.sh` - one documentation-table row and one `WIRED` entry.
- `specs/714_evaluate_full_labels_in_sliced_certificate/reports/01_full-labels-sliced-certificate.md`
  - one-line new-path pointer under `### Probe`.

**Verification**:

- `bash scripts/check-evidence-probes.sh` prints `PASS` on the line labelled
  `stability-modal-substrate/full-labels-collapse-stab`, and the run's failure count is a
  recorded PASS for this phase under the baseline-delta rule: enumerate any pre-existing failure
  and confirm it names no file this task touched.
- `git ls-files --error-unmatch specs/evidence/stability-modal-substrate/full-labels-collapse-stab.lean`
  exits 0 (presence alone is not the guard's bar -- tracking is).
- `bash scripts/typst-sync-check.sh --counts-only` exits 0 (the pre-commit hook fires on any
  staged `.lean` path, including one under `specs/`; the counts themselves range over
  `FormalSystem/`, `Tests/` and `BimodalTools/` only, so no regeneration is expected here -- a
  drift finding means Phase 1's regeneration did not land and must be investigated, not
  re-applied blindly).
- `git status --short` shows no staged file outside the list above.

---

### Phase 3: Record the refutation at `Position.lean`'s header [COMPLETED]

**Goal**: `Position.lean`'s header states, as a positive claim, what the `posAt`
over-approximation buys -- closing the option-3 line the way the prior round's R2 closed option 2.

**Tasks**:

- [x] Re-read `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Position.lean`
      immediately before editing.
- [x] Add one paragraph to the module docstring, directly after the existing
      `## `posAt` over-approximates, and what that costs the tail-stability demands` section,
      under its own heading (the existing section states the COST; this one states the BENEFIT):
      - the multiplicity of labels over one state at one time is the comparison class of
        `PlusTruthAt`'s `stab` clause -- `⊡` quantifies over the histories sharing the present
        world state, and the frame the certificate presents has carrier `ℤ × Fin G.n`, so that
        class is the labels of the live positions over `w` at `t`, which is exactly what
        `StabFaithful` reads;
      - so collapsing `posAt` to one label per state would restrict the class to models in which
        `⊡φ ↔ φ`, which is the deterministic collapse named by
        `FormalSystem.PlusLanguage.stab_iff_of_deterministic`;
      - the measured witness: at both landed `⊡`-carrying non-vacuity witnesses (`TotalEdge.certA`
        at target `Pp → ⊡Pp`, `TotalEdge.certB`) two distinct live labels sit over one slice state
        at one time, and under full labels both have an EMPTY position space -- the slab is a
        state description, not a type;
      - and the limit of the positive result: `posAtFull = liveAt` holds at every window time at
        the three embedded certificates (Phase 1's triple, named), but fails at `Fixture.cert`, so
        it is a property of the embedding and not of the label refinement -- full labels do not
        make junk positions impossible, and the `⊇` superset failure survives them.
- [x] Cite the evidence probe by its Phase 2 path as backticked plain text, never as a
      `[...](...)` markdown link: C32 requires every relative markdown link inside a live `.lean`
      comment to resolve relative to the citing file, and this one would not.
- [x] Confirm the paragraph carries no `file.lean:NNN` citation (C20 gates any that lands outside
      the declaration it names) and no task-number reference (C9 gates these under
      `FormalSystem/`).
- [x] Regenerate `bash scripts/typst-sync-check.sh --fix` and
      `bash scripts/check-module-invariants.sh --emit-inventory`.
- [x] Stage with an explicit file list and commit.

**Timing**: 0.75 hours

**Depends on**: 2

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: the edit is confined to `Position.lean`'s module docstring -- no
declaration, signature or proof in that file changes. Confirm with
`git diff -- FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Position.lean`, checking
every changed hunk lies between the `/-!` and the `-/` of the module docstring.

**Tier Justification**: a Lean module docstring is elaborated and moves the file's line count, so
the `prose` tier does not cover it; `suite_selection_select` returns `__FULL_SWEEP__` for every
path in this phase (measured), and the covering check is
`bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.Position`
together with the two generated-surface checks below.

**Files to modify**:

- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Position.lean` - one new module-
  docstring section recording what the over-approximation buys.
- `typst/generated/status.typ` - regenerated `formalsystem-line-count` (commit-blocking).
- `README.md` - regenerated totals block.
- `FormalSystem/Metalogic/README.md` - regenerated subdirs block.

**Verification**:

- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.Position`
  exits 0.
- `bash scripts/typst-sync-check.sh --counts-only` exits 0.
- `bash scripts/check-module-invariants.sh --emit-inventory --check` exits 0.
- `grep -n 'stab_iff_of_deterministic' Position.lean` finds the citation, and
  `grep -rn 'theorem stab_iff_of_deterministic' FormalSystem/PlusLanguage/PlusDeterminism.lean`
  confirms the cited declaration exists at the name written.

---

### Phase 4: Full-gate verification [COMPLETED]

**Goal**: The whole repository is green with all three changes in place.

**Tasks**:

- [x] Run the full guarded build, detached as a shell-level background job and blocked on with
      the bounded single-call idiom (`context/patterns/bounded-build-waiter.md`): a hard timeout,
      writer liveness via `kill -0` on the captured PID, one waiter per log.
- [x] Run the repository's complete gate set, in the order CI runs it (see below), capturing each
      exit code.
- [x] For any red gate, enumerate its findings and separate those naming a file this task touched
      from the tree's standing baseline. Only the former is this task's to fix.
- [x] Record the measured build-time delta for `EmbedComplete.lean` against the risk table's
      build-cost entry.

**Timing**: 1 hour

**Depends on**: 3

**Verification Tier**: full

**Files to modify**: none (verification only).

**Verification** -- the complete gate set for this repository, which is the CI job's own step
list in `.github/workflows/ci.yml` (`verify-deploy.sh` is NOT part of it and is not applicable:
this task touches no `.claude/**` path and no source-store path):

- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build` exits 0 (full project).
- `bash scripts/check-evidence-probes.sh` -- the new probe PASSes; any other failure is
  enumerated as pre-existing.
- `bash scripts/check-module-invariants.sh --no-build` exits 0.
- `bash scripts/check-copyright-headers.sh --strict --exclude '*/Boneyard/*' FormalSystem` exits 0.
- `bash scripts/readme-lint.sh` exits 0.
- `bash scripts/check-metalogic-cycles.sh` exits 0 (no new upward import is introduced, so
  Assertion B's frozen allowlist needs no extension -- confirm rather than assume).
- `bash scripts/typst-sync-check.sh` exits 0 (the full invocation, not `--counts-only`).
- `bash scripts/check-paper-definitions.sh` exits 0.
- `lake exe mk_all --lib FormalSystem --check` exits 0 (no file is added or removed under
  `FormalSystem/`, so C33 should be unaffected -- confirm).
- `lake exe lint-style` exits 0. Under `--wfail` a lint WARNING is a CI FAILURE, so a warning in
  any touched file is a red gate, not a note.

Each repo-wide gate is judged as a baseline delta, not an absolute zero: a gate whose only
failures are pre-existing and outside this task's file scope is a recorded PASS for this phase,
with the pre-existing findings enumerated and the evidence that each touched file passes
individually.

**Measured result (dispatch 14).** This dispatch carried a Batch Gate Deferral directive. Neither
narrowing invocation it names can express this phase's criteria -- `.claude/scripts/tests/run-all.sh`
covers the agent system's own shell suites and this task touches no `.claude/**` path, and
`verify-deploy.sh` the plan already rules inapplicable for the same reason -- so the UNMAPPABLE
CRITERION clause applies and each named check was run directly instead. The complete set still runs
once for the whole batch at the end of the invocation.

| Gate | Exit | Verdict |
|------|------|---------|
| `lake build` (full, guarded) | 0 | PASS -- 2975 jobs, zero `error:` lines, `.olean` newer than source for both touched modules |
| `check-evidence-probes.sh` | 1 | PASS (baseline delta) -- the new probe reports PASS; the one failure is `specs/918_ladder_cell_index_positive_factorization/evidence/lowering-anchor-deficit.lean`, archived into the gitignored `specs/archive/` by commit `cf3e481fb` |
| `check-module-invariants.sh --no-build` | 0 | PASS |
| `check-copyright-headers.sh --strict` | 0 | PASS |
| `readme-lint.sh` | 0 | PASS |
| `check-metalogic-cycles.sh` | 0 | PASS -- no new upward import, Assertion B's allowlist needs no extension (confirmed, not assumed) |
| `typst-sync-check.sh` (full) | 0 | PASS |
| `check-paper-definitions.sh` | 1 | PASS (baseline delta) -- 9 definitions drifted against the out-of-repo LaTeX source; names no file this task touched |
| `lake exe mk_all --lib FormalSystem --check` | 0 | PASS -- "No update necessary" (confirmed, not assumed) |
| `lake exe lint-style` | 1 | PASS (baseline delta) -- 4 space-before-semicolon errors, all in `FormalSystem/Metalogic/Expressiveness/SeparationZ/NormalForm.lean`, whose last change precedes this task's first commit; zero findings name either touched file |

**Build-cost delta.** `EmbedComplete.lean` builds in 5.9s without the `FullLabelRegression` block
and 7.0s with it: +1.1s, roughly 19%, measured by a temporary removal and restore with a
byte-for-byte restore check. The risk table's build-cost entry is discharged -- these are the
cheapest fixpoints in the subtree, as it predicted.

**Zero-debt census.** `sorry_count: 0` over all resolved source roots. No `axiom` line added (the
tree's standing count of 14 is unchanged). The one vacuous-pattern grep hit,
`FormalSystem/Examples/TemporalStructures.lean`'s `int_domain_universal`, predates this task and is
a genuine proof rather than a placeholder.

## Testing & Validation

- [x] The three new theorems carry no `sorry`: `lean_verify` (or `#print axioms` run ad hoc
      outside the library) reports `[propext, Classical.choice, Quot.sound]` for each.
- [x] `Stable.lean`, `Check.lean`, `Position.lean`'s `posAt`/`AgreesOnState` definitions and
      `Fixture.lean` are unchanged apart from Phase 3's docstring addition:
      `git diff --stat` over the task's commits names no other declaration.
- [x] `scripts/check-evidence-probes.sh` lists the new probe and compiles it.
- [x] `git status --short` is clean of unstaged generated-surface drift at the end of each phase.
- [x] No commit stages a file in a concurrent sibling task's declared `file_scope`.

## Artifacts & Outputs

- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/EmbedComplete.lean` -- the
  `FullLabelRegression` block (`posAtFull` plus three equalities).
- `specs/evidence/stability-modal-substrate/full-labels-collapse-stab.lean` -- the promoted,
  tracked, WIRED evidence probe.
- `scripts/check-evidence-probes.sh` -- one new documentation row and one new `WIRED` entry.
- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Position.lean` -- the new
  module-docstring section.
- `typst/generated/status.typ`, `README.md`, `FormalSystem/Metalogic/README.md` -- regenerated
  coupled surfaces.
- `specs/714_evaluate_full_labels_in_sliced_certificate/summaries/01_full-labels-sliced-certificate-summary.md`
  -- written at implementation completion.

## Rollback/Contingency

Each phase commits independently, so the ordinary rollback is `git revert` of that phase's
commit -- no working-tree-destroying operation, and nothing to snapshot.

If a phase must be abandoned mid-edit with uncommitted work present, take a durable checkpoint
first with `bash .claude/scripts/git-snapshot.sh 714 --no-revert` (the non-reverting form; the
default reverting form belongs only to a genuine rollback scenario, per
`context/contracts/recovery.md`'s rollback rung, and must never be emitted as a routine
checkpoint on this shared tree while sibling tasks are live).

Per-phase contingency:

- **Phase 1** -- if a `decide` does not close inside the probe's envelope at the library site
  (an import-closure difference changing reducibility), do NOT weaken a statement to make it
  close. Mark the phase `[BLOCKED]` and report, per `.claude/rules/plan-compliance.md`: these
  signatures are the contract fixed in `## Lean Challenge Statements`.
- **Phase 2** -- if the moved probe fails to compile at its new path, the diagnosis is the
  three-class triage in `check-evidence-probes.sh`'s header (rot / untracked / environment); a
  missing-object-file error is an environment failure and means re-running after any concurrent
  build finishes, never repairing the probe.
- **Phase 3** -- the edit is docstring-only and revertable with no downstream consequence beyond
  re-running the two regeneration commands.
