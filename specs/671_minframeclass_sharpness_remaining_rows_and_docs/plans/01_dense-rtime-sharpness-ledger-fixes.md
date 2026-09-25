# Implementation Plan: Task #671

- **Task**: 671 - Prove the MINIMALITY half of `Axiom.minFrameClass` for the four remaining
  non-Base rows (`density`, `dense_indicator`, `prior_U_gap`, `sep`) and correct the two
  pre-existing documentation defects in the files that work already edits
- **Status**: [IMPLEMENTING]
- **Effort**: 7.25 hours
- **Dependencies**: None open. The `.ZTime` full-characterization work (task 672) has **landed** —
  `FormalSystem/Metalogic/Independence/ZTimeSharpness.lean` is present at 423 lines and carries
  `eq_base_of_lt_ztime`, the four `not_validIn_dense_*` / `not_validIn_rtime_*` corollaries, and
  the two `validIn_iff_ztime` biconditionals. The class-membership discharge machinery this task
  reuses (`Sat .Dense` as an anonymous instance pair, `Sat .ZTime` via
  `TaskFrame.isZTime_of_instances`) is therefore already in the tree and must not be rebuilt.
- **Research Inputs**:
  `specs/671_minframeclass_sharpness_remaining_rows_and_docs/reports/01_dense-rtime-sharpness-ledger-fixes.md`
- **Artifacts**: plans/01_dense-rtime-sharpness-ledger-fixes.md (this file),
  summaries/01_dense-rtime-sharpness-ledger-fixes-summary.md
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

One new module, `FormalSystem/Metalogic/Independence/DenseRTimeSharpness.lean`, closes three of
the four remaining `Axiom.minFrameClass` rows — `density` and `dense_indicator` (tagged `.Dense`)
and `prior_U_gap` (tagged `.RTime`) — by proving non-validity at every class strictly below each
tag, and ships a proved obstruction for the fourth (`sep`) rather than leaving it silent. The two
`.Dense` rows come out stronger than minimality at no extra cost: a four-way `cases fc` closes
`ValidIn fc φ ↔ FrameClass.Dense ≤ fc`. The same pass then corrects the two documentation defects
in the files this work already edits, in the dispatch's load-bearing order — proof work first,
ledger reconciliation last, so the result counts settle once. Definition of done: every new
declaration sorry-free and axiom-declaration-free with measured axiom set exactly
`[propext, Classical.choice, Quot.sound]`, both ledgers agreeing, no superseded `FrameClass`
spelling surviving under `FormalSystem/`, `bash scripts/check-module-invariants.sh` green across
every check group, and `bash scripts/readme-lint.sh` PASS — reached inside a single full-tree
rebuild.

### Research Integration

The research report elaborated the entire candidate module with `lake env lean` against the
current built tree: **zero errors, zero warnings, zero `sorry`**, with the three headline results
measuring `[propext, Classical.choice, Quot.sound]`. Its Appendix A and Appendix B carry verbatim
proof terms; this plan directs the implementer to **transcribe** them, not re-derive them. Six
report findings materially change the dispatch's own instructions and are carried into the phases
below.

- **The dispatch's `density` route does not compose, and a cheaper one was verified.**
  `validOn_dn_iff_denselyOrdered`'s left side quantifies `∀ F ∀ φ`, whereas `ValidIn .Base ψ`
  fixes one `ψ`. A nine-line direct refutation on `translationFrame` — reusing exactly the
  `ZTimeSharpness.lean` kit — is shorter than adapting it. The `dense_indicator` route *is* the
  one-step `iff` the dispatch names, because `validOn_neg_nextTop_iff` is stated per-frame.
- **Documentation defect 1 is misdiagnosed in the dispatch, and executing it as written would
  introduce an error.** `Axioms.lean:16-29` declares three renderings of `untl` and is explicit
  that they disagree on argument order: constructor and infix are guard-first, the prefix form
  `U(e, g)` is deliberately **event-first**, keyed to `Formula.prettyPrint`
  (`Automation/Normalization.lean:672` prints the constructor's *second* argument first). Under
  that declared convention `prior_UZ`'s prose `F(φ) → U(φ, ¬φ)` is **correct**, as is every
  prefix rendering on the four axioms this task touches. Rewriting them would desynchronise the
  docstrings from the printer. What *is* defective is three pieces of infix/English prose that
  reverse guard and event: `Axioms.lean:333`, `Axioms.lean:447`, and `ZTimeSharpness.lean:130-133`
  — the last being the source of the dispatch's own misreading.
- **Documentation defect 2 is bigger than a count mismatch.** The two ledgers enumerate
  *different* result sets (6 vs 9; union 10, not a choice between them);
  `Independence.lean`'s Contents list omits 6 of its 24 imported modules;
  `Independence/README.md:126-128` cites two **non-existent** identifiers; and two generated
  descriptions (`:105`, `:110`) are visibly truncated.
- **The superseded-name sweep is confined to markdown and is larger than the report measured.**
  Verified during planning: `grep` for `FrameClass.Dedekind` / `FrameClass.Discrete` and for bare
  `.Dedekind` / `.Discrete` tokens returns **zero** hits under `FormalSystem/**/*.lean` and hits
  in **eight** `README.md` files, not one. `Metalogic/README.md:115` additionally cites four
  dangling identifiers (`CompactDedekind`, `StrongCompletenessDedekind`, `SatisfiableDedekindSet`,
  `ModelExistenceDedekind` — none exist; the real names in `Metalogic/SetConsequence.lean` are
  `CompactRTime`, `StrongCompletenessRTime`, `SatisfiableRTimeSet`, `ModelExistenceRTime`). Since
  no `.lean` file is touched, the whole sweep is free of rebuild cost.
- **`--no-build` is the lever the dispatch does not mention.**
  `bash scripts/check-module-invariants.sh --no-build` runs the entire structural pass (C4-C34,
  C9D, B0-B3) without `lake build` and is currently green. Every documentation iteration can be
  gated for free, so the one budgeted full rebuild is spent once, at the end.
- **C20 is the sharpest unnamed risk.** 16 live `ProofSystem/Axioms.lean:NNN` citations exist
  across the tree, and `scripts/c20-declaration-baseline.txt` carries **no** `Axioms.lean` entry
  while stating it "only ever SHRINKS" — so a new violation cannot be quieted by adding a key.
  Growing `Axioms.lean` shifts all 16. The remedy already in the tree is
  `python3 scripts/reanchor-lean-citations.py --by-name --files FormalSystem/ProofSystem/Axioms.lean`.

### Prior Plan Reference

No prior plan exists for task 671. Two neighbouring plans were read as reference context, not as
templates:

- `specs/670_minframeclass_sharpness_prior_uz_z1/plans/01_ztime-sharpness-theorems.md` — supplies
  the calibration that `by decide` **fails** on `FrameClass` `<` (only `≤` carries a
  `DecidableRel` instance, `Axioms.lean:508-509`), so strict-order goals must route through
  `absurd h.le (by decide)`. Its Phases 5 and 6 closed as `[COMPLETED WITH EXCLUSIONS]`; the
  present task inherits nothing from them.
- `specs/672_ztime_full_characterization_and_axiom_pin/plans/01_ztime-characterization-axiom-pin.md`
  — supplies the effort calibration for a single-module-plus-ledger change (4.5 hours measured)
  and the gate-ordering lesson that `--emit-inventory` must run strictly after the last docstring
  edit. Its Phase 3 `atomic-batch` pin has no analogue here; nothing in this task is
  all-or-nothing across files.

### Roadmap Alignment

No `roadmap_path` was supplied in this dispatch and no roadmap phases were requested, so no
ROADMAP.md consultation or update is in scope.

## Goals & Non-Goals

**Goals**:

- `eq_base_of_lt_dense`
- `base_or_dense_of_lt_rtime`
- `not_validIn_base_density`
- `not_validIn_ztime_density`
- `density_minFrameClass_sharp`
- `density_validIn_iff`
- `not_validIn_base_dense_indicator`
- `not_validIn_ztime_dense_indicator`
- `dense_indicator_minFrameClass_sharp`
- `dense_indicator_validIn_iff`
- `not_validIn_base_prior_U_gap`
- `not_validIn_dense_prior_U_gap`
- `prior_U_gap_minFrameClass_sharp`
- `sep_validOn_of_isLeastPos`
- Correct the three infix/English prose items that reverse guard and event, leaving every prefix
  rendering untouched.
- Reconcile the two Independence ledgers to the ten-result union plus this task's new entry,
  renumbered identically, with the Contents list completed and the dangling identifiers repaired.
- Replace every superseded frame-class spelling under `FormalSystem/` with its current spelling.
- Update the minimal-frame-class docstring to cite the new sharpness results, record the Base row
  as vacuously sharp, and name the one row that remains open.

**Non-Goals**:

- Proving the `sep` row. Excluded up front with a proved obstruction shipped in its place; see
  Phase 2's Reasoned Exclusions record and the follow-up in Observations below.
- Re-proving or restating the `.ZTime` row. It is closed in both directions already; this task
  only corrects one prose note inside its module.
- The `.ZTime` full-characterization work and the MainResults axiom pinning. That is this task's
  **dependency**, already landed, not part of it.
- Any `.ZTime`-validity claim for `prior_U_gap`. It looks valid there, but that is a conjecture;
  claiming it would be an upgrade the evidence does not support. This row gets minimality only.
- Any schematic `∀ φ` non-validity statement. `Axiom.prior_UZ ⊥` has an unsatisfiable antecedent
  and *is* `.Base`-valid, so the schematic form can be outright false; every parametrised result
  is stated at `Formula.atom a`.
- Any claim about `ℚ` specifically. The `prior_U_gap` refutation runs over the clock frame, whose
  duration group is `ℚ`, but the statements claim `.Base` and `.Dense` only — holding the same
  line the `.ZTime` module deliberately holds.
- Renaming the live predicate `TaskFrame.IsDiscrete`. It is a correct, current name and is
  deliberately contrasted with the frame-class tag in `Semantics/Correspondence/README.md`.
- Reconciling the ledgers by deleting entries; anything under `docs/`, `typst/`, or the
  repository-root `README.md` beyond the inventory block the generator itself rewrites; and any
  change to the ModelChecker repository.
- Adding a key to `scripts/c20-declaration-baseline.txt`. That file only ever shrinks.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| The prose "corrections" reverse a *correct* prefix rendering, desynchronising docstrings from the printer | H | M | Phase 4 treats `Axioms.lean:16-29` and `Normalization.lean:672` as the authority; only the three enumerated infix/English items are in scope, and the shape pins in Phase 1 make any drift a compile error |
| C20 fails after `Axioms.lean` grows: 16 live citations shift against an empty baseline | H | M | Phase 7 runs `--no-build` first, then `reanchor-lean-citations.py --by-name --files FormalSystem/ProofSystem/Axioms.lean`, then re-reads the diff; no baseline key is ever added |
| INV fails because a docstring edit grew a file after `--emit-inventory` ran (exactly the `.ZTime` incident, 123 → 133 lines) | M | M | Inventory regeneration is the **last** content step, inside Phase 7, after Phases 4-6 have made their final prose edit; `--emit-inventory --check` is re-run to confirm |
| The new module's inventory row ships as `<!-- TODO: add description -->` | L | M | Phase 7 fills the description immediately after the first `--emit-inventory`, before the `--check` re-run |
| A second full rebuild is incurred, meaning the phase ordering went wrong | M | M | No `lake build` during authoring: `lake env lean` on the single file (Phase 1-2), one scoped Independence build (Phase 3), one full rebuild (Phase 7) |
| C33 fails because the library root was not regenerated for the new module | M | M | `lake exe mk_all --lib FormalSystem` is a Phase 1 task, before any gate run; `scripts/module-invariants-manifest.txt` stays empty by design |
| C17 flags a new theorem as dead | M | L | Every headline name is cited in the module docstring, the minimal-frame-class docstring and both ledger entries, with exactly matching spellings; auxiliary lemmas are named in the module's own docstring, which satisfies "outside the declaring line" |
| The superseded-name sweep over-reaches into legitimate mathematical prose ("Dedekind-complete", `DedekindNonCompactness.lean`, `DedekindDerived.lean`) | H | M | Phase 6 rewrites only frame-class *tag* spellings — `FrameClass.Dedekind`, `FrameClass.Discrete`, and bare `.Dedekind` / `.Discrete` in tag position — never the English adjective or a filename |
| The `.Dense` `validIn_iff` bonus is mistaken for required scope and blocks the row | M | L | Already elaborated in the report's Appendix A; if it ever resists, drop to the `*_minFrameClass_sharp` results alone, which are what the dispatch actually names |
| `sep` is attempted inside this task and overruns | H | M | Excluded up front in Phase 2 with `sep_validOn_of_isLeastPos` as the proved boundary and both candidate routes recorded; spawned as its own task |
| `by decide` attempted on `FrameClass` `<` | L | M | Every order fact routes through `absurd h.le (by decide)`; recorded in Phase 1's tasks |
| A frame-level statement is attempted where the `CoNotPriorU` model-fixed obstruction genuinely bites | M | L | The criterion is applied *before* writing: the obstruction bites only when a statement must simultaneously **validate** something on a valuation-rich flow; every statement here is a bare non-validity claim and validates nothing. Phase 1 requires this be written into the module docstring, not rediscovered |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4, 5 | 3 |
| 5 | 6 | 5 |
| 6 | 7 | 4, 6 |

Phases within the same wave can execute in parallel. Wave 4's two phases own disjoint file sets —
Phase 4 owns `FormalSystem/ProofSystem/Axioms.lean` and
`FormalSystem/Metalogic/Independence/ZTimeSharpness.lean`; Phase 5 owns
`FormalSystem/Metalogic/Independence.lean` and
`FormalSystem/Metalogic/Independence/README.md` — so they may be dispatched together under that
territory contract. Phase 6 follows Phase 5 because both touch
`FormalSystem/Metalogic/Independence/README.md`. Everything else is strictly sequential: the
dispatch's load-bearing ordering constraint is that ledger reconciliation happens **after** every
new entry exists, which Phases 1-2 supply.

### Phase 1: Author DenseRTimeSharpness.lean — the three closed rows [COMPLETED]

**Goal**: A new sorry-free module exists carrying the order facts, the generic refutation
machinery, the integer carrier, and the three closed rows; it elaborates clean under
`lake env lean` and every headline name measures `[propext, Classical.choice, Quot.sound]`.

**Tasks**:

- [x] Create `FormalSystem/Metalogic/Independence/DenseRTimeSharpness.lean` with exactly the four
      imports the report tested: `FormalSystem.Semantics.Correspondence.DurationFrames`,
      `FormalSystem.Semantics.Correspondence.Indicator`, `FormalSystem.Metalogic.Soundness`,
      `FormalSystem.Metalogic.Independence.CoNotPriorU`; the `open` line
      `open FormalSystem FormalSystem.Syntax FormalSystem.Semantics FormalSystem.ProofSystem`; and
      `namespace FormalSystem.Metalogic.Independence`.
- [x] Write the module docstring. It MUST state, in as many words: (a) that every result is a
      frame-level `¬ ValidOn` lifted to `¬ ValidIn`; (b) why the `CoNotPriorU` frame-versus-model
      obstruction does not apply — that obstruction bites only when a statement must
      *simultaneously validate* something on a valuation-rich flow, and a bare non-validity claim
      validates nothing, so a `¬ ValidOn` claim is weaker than, and follows from, the model-fixed
      refutation; (c) exactly which class each result establishes, with no upgrade — in
      particular that nothing is claimed about `ℚ` specifically and nothing about `.ZTime` for the
      `prior_U_gap` row; (d) the names of the auxiliary lemmas, so C17 sees them outside their
      declaring lines. Cite declaration names and file paths **without** `:NNN` (C20 tier 2 is
      enforced), following `ZTimeSharpness.lean`'s practice.
- [x] Add the three anonymous shape-pin `example`s from report Appendix A, for `Axiom.density`,
      `Axiom.dense_indicator` and `Axiom.prior_U_gap`, so formula-transcription fidelity is a
      compiler obligation rather than a reading. The entire result is vacuous if a transcribed
      formula drifts from its constructor's.
- [x] Add `eq_base_of_lt_dense` and `base_or_dense_of_lt_rtime`, both four-arm `cases fc` proofs
      in `eq_base_of_lt_ztime`'s idiom. Route every strict-order arm through
      `absurd h.le (by decide)` — `by decide` **fails** on `FrameClass` `<`; only `≤` has a
      `DecidableRel` instance.
- [x] Add the generic machinery: `not_denselyOrdered_of_isLeastPos`,
      `not_validOn_density_of_isLeastPos` (the nine-line direct `translationFrame` refutation with
      `A = {x | x ≠ p}`, fully generic in `D`, using `ne_of_gt` rather than `omega` — `omega` does
      not see through the `TemporalOrder.carrier` coercion), and
      `not_validOn_dense_indicator_of_isLeastPos` (two lines through
      `validOn_neg_nextTop_iff`, which applies because `Axiom.dense_indicator`'s formula is
      *definitionally* `(Formula.next Formula.top).neg`).
- [x] Add the integer carrier: `noncomputable abbrev denseSharpOrder := TemporalOrder.of ℤ`,
      `isLeast_one_denseSharpOrder`, `sat_base_denseSharpFrame` (`inferInstance`) and
      `sat_ztime_denseSharpFrame` (`⟨inferInstance, TaskFrame.isZTime_of_instances _⟩` — a bare
      `constructor`/`refine ⟨…⟩` fails, `IsZTime` is a nested four-component existential).
- [x] Add Row 1 (`density`): `not_validIn_base_density`, `not_validIn_ztime_density`,
      `density_minFrameClass_sharp`, `density_validIn_iff` and `not_derivable_base_density`,
      transcribed from Appendix A.
- [x] Add Row 2 (`dense_indicator`): `not_validIn_base_dense_indicator`,
      `not_validIn_ztime_dense_indicator`, `dense_indicator_minFrameClass_sharp`,
      `dense_indicator_validIn_iff` and `not_derivable_base_dense_indicator`.
- [x] Add Row 3 (`prior_U_gap`): `not_validOn_prior_U_gap_clock`, `not_validIn_base_prior_U_gap`,
      `not_validIn_dense_prior_U_gap`, `prior_U_gap_minFrameClass_sharp` and
      `not_derivable_dense_prior_U_gap`. The `.Dense` discharge is `⟨inferInstance, inferInstance⟩`
      over the clock frame; the same single refutation covers both classes strictly below
      `.RTime`.
- [x] Give every declaration a `/-- … -/` docstring (C16 `docBlame` and C19 both read them; the
      report's appendix deliberately elided them, so they are the implementer's to write).
- [x] Add `import FormalSystem.Metalogic.Independence.DenseRTimeSharpness` to
      `FormalSystem/Metalogic/Independence.lean` in its existing alphabetical import position.
      (The Contents-list bullet for it is Phase 5's work, not this phase's.)
- [x] Regenerate the library root: `lake exe mk_all --lib FormalSystem`. C33 compares it
      byte-for-byte and `scripts/module-invariants-manifest.txt` must stay empty.
- [x] Verify with `lake env lean FormalSystem/Metalogic/Independence/DenseRTimeSharpness.lean` —
      **not** `lake build`. This was sufficient for every result in the research report.
- [x] Confirm each headline name's axiom set with `lean_verify` or a scratch `#print axioms` run
      that is **not** left in the file — C27 fails on any new in-file directive outside
      `MainResults.lean`.

**Timing**: 1.5 hours

**Depends on**: none

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: one new `.lean` file plus a one-line import addition and a regenerated
`FormalSystem.lean`; roughly 23 new declarations in the new module, all transcribed from the
report's verified Appendix A with no new countermodel construction anywhere. Confirm at
implementation time by a clean `lake env lean` run on the single new file with zero errors and
zero warnings, and by the measured axiom set of every headline name being
`[propext, Classical.choice, Quot.sound]`. If any row needs machinery beyond the four imports
above, stop and reassess rather than widening the module.

**Files to modify**:

- `FormalSystem/Metalogic/Independence/DenseRTimeSharpness.lean` - new module (created).
- `FormalSystem/Metalogic/Independence.lean` - one added import line.
- `FormalSystem.lean` - regenerated by `mk_all`.

**Verification**:

- `lake env lean FormalSystem/Metalogic/Independence/DenseRTimeSharpness.lean` exits 0 with no
  `error:` and no `warning:` line.
- `grep -n 'sorry' FormalSystem/Metalogic/Independence/DenseRTimeSharpness.lean` finds nothing,
  and `grep -n '^axiom ' ` finds nothing.
- Each headline name reports `[propext, Classical.choice, Quot.sound]`.
- `git diff --stat FormalSystem.lean` shows exactly the one new import line.

---

### Phase 2: The sep row — ship the proved obstruction, exclude the proof [COMPLETED]

**Goal**: The `sep` row leaves this task with a *proved boundary* rather than silence: it is
established that no discrete witness can exist, and the two candidate dense routes are recorded
where the next reader will find them.

**Tasks**:

- [x] Add `not_kPlus_of_isLeastPos` and `sep_validOn_of_isLeastPos` to
      `DenseRTimeSharpness.lean`, transcribed from report Appendix B. These show `K⁺φ` is false
      everywhere on a frame with a least positive duration — the immediate successor `t + p`
      empties the interval `(t, t+p)` — so `sep`'s antecedent's first conjunct fails and `sep` is
      *vacuously* valid on every such frame.
- [x] Add a `/-! ## The sep row -/` section docstring recording the consequence:
      *(deviation: altered — the section heading reads `## Row 4: sep — the obstruction, not the
      refutation`, matching the module's existing `## Row N:` section naming; content as
      specified.)* combined with
      `Semantics.duration_dense_or_least_pos`, **no discrete witness for `sep` can exist**, so any
      `.Base` refutation must run over a densely ordered duration group — and since
      `Sat .Dense F → Sat .Base F`, one dense witness would close both classes at once, exactly
      the `prior_U_gap` pattern.
- [x] Record both candidate routes in that same section docstring, without attempting either:
      (a) the lexicographic configuration already written down in
      `SoundnessLemmas/Separability.lean` (`t = (0,1)` on the lex square with φ-region
      `{(a,0) : 0 < a < 1}`) does **not** transfer as-is, because a group has no fibre tops and
      the antecedent collapses the problem back to the separable one-level case — the *value*
      group must itself be densely ordered; (b) the witness that does work is
      `D = Lex (ℚ →₀ ℚ)` with φ-region `{toLex (single γ 1) : γ > 0}`, whose carrier instances
      were probed and work except for `IsOrderedAddMonoid`, a three-line instance off Mathlib's
      `Finsupp.Lex.addLeftMono` / `addRightMono`; and (c) an independent plain-`ℚ` route via a
      bespoke Cantor set exploiting completeness rather than separability.
- [x] Re-run `lake env lean` on the single file.
- [x] Do **not** attempt the `Lex (ℚ →₀ ℚ)` construction. It is estimated at 350-450 new lines
      with real risk in the least-support arithmetic; it is spawned as a separate task in
      Observations below.

**Timing**: 0.5 hours

**Depends on**: 1

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: exactly two new declarations plus one section docstring, in the file Phase 1
created — no second module, no new carrier, no new imports. Confirm by a clean `lake env lean`
run and by `git diff --stat` showing one file changed. If either lemma needs an import beyond
Phase 1's four, the obstruction is not the one the report proved and the phase should stop and
report rather than widen.

#### Reasoned Exclusions

This record is written at plan time, as a pre-emptive declaration alongside the Scope Hypothesis
above; implementation-time findings confirm or supersede it.

| Item | Reason | Evidence |
|------|--------|----------|
| A `.Base` refutation of `Axiom.sep` | No discrete witness can exist. `sep` is vacuously valid on every frame with a least positive duration, because its antecedent's first conjunct `K⁺φ` is false everywhere there; with `duration_dense_or_least_pos` (every duration group is densely ordered or has a least positive element), any `.Base` refutation must therefore run over a densely ordered group, which is the same problem as the `.Dense` case | `sep_validOn_of_isLeastPos` and `not_kPlus_of_isLeastPos`, shipped in `FormalSystem/Metalogic/Independence/DenseRTimeSharpness.lean` by this phase and elaborated in the research report's Appendix B |
| A `.Dense` refutation of `Axiom.sep` | No witness exists in the tree, and the only configuration the repository records (the lexicographic square in `SoundnessLemmas/Separability.lean`) does not transfer to a duration *group*: a group has no fibre tops, so the antecedent forces the φ-region into an infinitesimal fibre order-isomorphic to a rational interval and `sep` survives. The value group must itself be densely ordered, which needs a new carrier | Research report's "Row 4 — `sep`" section, with the `Lex (ℚ →₀ ℚ)` carrier probed working (except a three-line `IsOrderedAddMonoid` instance) and costed at 350-450 lines — one to two dedicated phases of new work, beyond this task's budget |
| `sep_minFrameClass_sharp` | Follows from the two refutations above; cannot be stated without them | Same as above; the row is named as the one open row in the minimal-frame-class docstring by Phase 4, so the gap is recorded in the code rather than left implicit |

---

### Phase 3: Scoped build over the Independence closure [COMPLETED]

**Goal**: The new module and its import are proved not to break anything downstream, before any
edit that would cost a full-tree rebuild.

**Tasks**:

- [x] Re-derive the reverse-dependency set rather than trusting a figure:
      `grep -rln '^import FormalSystem.Metalogic.Independence.DenseRTimeSharpness$' FormalSystem Tests`,
      then iterate the same grep up the aggregator chain
      (`…Independence` → `…Metalogic` → consumers).
- [x] Run one detached scoped build:
      `bash .claude/scripts/lake-build-guard.sh --timeout 1800 -- build FormalSystem.Metalogic.Independence`
      under `Bash(run_in_background: true)`.
- [x] Wait with the bounded-waiter idiom from `context/patterns/bounded-build-waiter.md`: a hard
      timeout, writer liveness via `kill -0` on the captured PID, never `pgrep -f` or
      `ps | grep`, one waiter per log.
- [x] Grep the build log for `error:`, for namespace/ambiguity complaints, and for any
      `declaration uses 'sorry'` warning. *(deviation: altered — the first scoped build surfaced a
      `linter.style.show` warning that `lake env lean` had not shown, because the linter set is a
      package-level `leanOptions` entry; `isLeast_one_denseSharpOrder` was restated in term mode
      and the scoped build re-run, now zero errors and zero warnings.)*

**Timing**: 0.75 hours, mostly build wall-time

**Depends on**: 2

**Verification Tier**: interface

**Commit Mode**: per-substep

**Scope Hypothesis**: the new module is a leaf under `Metalogic/Independence.lean` and nothing
imports it yet, so the reverse-dependency set is expected to be the aggregator chain alone.
Confirm by running the grep chain above at implementation time rather than assuming it; if any
module outside that chain turns up, add it to the scoped build target list before proceeding.

**Files to modify**: none (verification only).

**Verification**:

- The scoped build exits 0.
- The log carries no `error:` line and no `sorry` warning.

---

### Phase 4: Batched prose pass over Axioms.lean and ZTimeSharpness.lean [COMPLETED]

**Goal**: The three genuinely-defective infix/English prose items are corrected, every prefix
rendering is left alone, and the minimal-frame-class docstring tells the truth about what is now
proved.

**Tasks**:

- [x] Read `Axioms.lean:16-29` (the notation block) and `Automation/Normalization.lean:672`
      **first**, and confirm from them that the prefix form `U(e, g)` is event-first by design.
      This is the authority for everything below. Do **not** rewrite `U(φ, ¬φ)` to `U(¬φ, φ)`
      anywhere: the prose renderings of `prior_UZ`, `dense_indicator`, `density`, `prior_U_gap`
      and `sep` are all correct under that convention, and changing them would desynchronise the
      docstrings from the printer and from the machine appendix's `schema_string`.
- [x] Fix `Axioms.lean:333` (a `--` comment above `prior_UZ`): "then p holds until not-p" is
      backwards under the guard-first infix convention — the constructor is `untl φ.neg φ`, so it
      is `¬p` that holds until `p`. The parenthetical that follows it is already correct, and the
      `prior_UZ` docstring body immediately below is already correct, which is why this reads as a
      leftover.
- [x] Fix `Axioms.lean:447` (inside the `prior_U_gap` docstring): "reading forward,
      `¬φ ∨ K⁺(¬φ)` holds until φ" is exactly reversed — the constructor is
      `untl φ (φ.neg ∨ K⁺ φ.neg)`, guard `φ`, so it is `φ` that holds until `¬φ ∨ K⁺(¬φ)`. The
      prefix rendering on the docstring's first line (`:444`) is correct and must not be touched.
- [x] Rewrite `ZTimeSharpness.lean:130-133`'s shape-pin note, which currently frames the
      constructor/prose argument order as a *conflict*. It is the declared prefix convention: say
      that the prefix rendering is event-first by design, tracking `Formula.prettyPrint`, and that
      the pin confirms it. This note is the source of the dispatch's own misdiagnosis; leaving it
      leaves the trap armed.
- [x] Rewrite the `Axiom.minFrameClass` docstring's lower-bound paragraph
      (`Axioms.lean:610-620`): cite the new sharpness results for the three rows this task closes;
      upgrade the `.ZTime` sentence to name the stronger `prior_UZ_validIn_iff_ztime` and
      `z1_validIn_iff_ztime` alongside the two `*_minFrameClass_sharp` results; record that the
      `.Base` row is **vacuously sharp** (nothing is `< FrameClass.Base`); and replace the closing
      sentence — "The Base, Dense and RTime rows carry the upper bound **only** … the
      corresponding sharpness results do not exist yet", which becomes false the moment this task
      lands — with a statement naming `sep` as the single remaining open row. Cite declaration
      names and file paths **without** `:NNN` (C20 tier 2).
- [x] Change **no** proof, theorem statement or definition. If a prose correction appears to
      require changing a constructor or a statement, stop and report rather than editing the
      mathematics.
- [x] Read the full diff and confirm every changed hunk lies inside a comment or docstring region.
- [x] Run `bash scripts/check-module-invariants.sh --no-build` (free, no `lake build`) and iterate
      until green. *(deviation: altered — every check group is green EXCEPT `INV`, which reports
      four stale generated inventory blocks. That is the expected, plan-anticipated consequence of
      growing `Axioms.lean`, and regeneration is explicitly Phase 7's job, not this phase's;
      notably `C20` passes at both tiers with no re-anchoring needed. No fourth reversed prose
      reading was found: the `density`, `dense_indicator`, `prior_U_gap` and `sep` prefix
      renderings all check out against their constructors under the declared event-first
      convention.)*

**Timing**: 1 hour

**Depends on**: 3

**Verification Tier**: prose

**Commit Mode**: per-substep

**Scope Hypothesis**: exactly three prose corrections plus one docstring rewrite, across exactly
two files, with zero lines of Lean code changed. Confirm at implementation time with
`git diff -U0 FormalSystem/ProofSystem/Axioms.lean FormalSystem/Metalogic/Independence/ZTimeSharpness.lean`
and a hunk-by-hunk read establishing every changed line is inside `--` or `/-- … -/` or `/-! … -/`.
The dispatch asserts one prior_UZ defect; the report measured three items and re-scoped the
diagnosis — if a fourth reversed reading turns up in a neighbouring docstring, fix it here and
record it, rather than deferring.

**Files to modify**:

- `FormalSystem/ProofSystem/Axioms.lean` - comment at `:333`, docstring line at `:447`,
  minimal-frame-class docstring lower-bound paragraph.
- `FormalSystem/Metalogic/Independence/ZTimeSharpness.lean` - shape-pin section note at
  `:130-133`.

**Verification**:

- `git diff` on both files shows only comment/docstring hunks; `git diff --stat` shows no change
  to any declaration line.
- `bash scripts/check-module-invariants.sh --no-build` exits 0.
- No prefix `U(…, …)` rendering anywhere in the diff has had its argument order changed.

---

### Phase 5: Reconcile the two Independence ledgers [COMPLETED]

**Goal**: The module docstring and the directory README agree on one renumbered result list, the
Contents list is complete, and no dangling identifier survives in either ledger.

**Tasks**:

- [x] Establish the true result set **from the directory itself**, not from either ledger. The
      two lists enumerate different sets (6 in `Independence.lean:38`, 9 in
      `Independence/README.md:6`); their union is ten. Verify that union by reading the directory
      rather than adopting the report's figure.
- [x] Adopt the union and renumber **both** lists identically: the shared five (CO ⊬ Prior-U; the
      two `Sat ⊊ Mod` non-closure witnesses; TM⁺ incomplete at `.Base`; the `.ZTime`
      characterization), plus the one only `Independence.lean` carries (`Deterministic` is not
      L⁺-definable), plus the four only the README carries (`⊡` not L-definable; the two pasting
      schemata not derivable; store/recall discriminate; `sent:det` defines only forward
      determinism).
- [x] Add this task's new entry as the eleventh result, in both ledgers, naming the headline
      declarations from Phase 1 with exactly matching spellings — this is also what keeps C17
      from flagging them.
- [x] Complete `Independence.lean`'s `## Contents` list: it imports 24 modules but bullets only
      18. Add the six missing (`CoarsenedModels`, `PastingIndependence`, `StarDiscrimination`,
      `ForwardDeterministicFrame`, `StabUndefinable`, `NaiveSystem`) plus the new
      `DenseRTimeSharpness`.
- [x] Repair the two dangling identifiers at `Independence/README.md:126-128`:
      *(deviation: altered — a **third** dangling identifier was found by the same
      resolve-every-cited-name sweep: the Key Results entry cited `co_not_derives_prior_U`, which
      does not exist; the real declarations in `CoNotPriorU.lean` are `co_not_derives_prior_U_gap`
      and `co_not_derives_prior_U_gap_schema`. Fixed here rather than deferred, as the same defect
      class.)*
      `sat_dedekind_ssubset_mod_axiomSet` and `sat_discrete_ssubset_mod_axiomSet` do not exist;
      the real declarations are `sat_rtime_ssubset_mod_axiomSet` (`RationalWitness.lean`) and
      `sat_ztime_ssubset_mod_axiomSet` (`LexIntWitness.lean`). Confirm both by grep before
      writing.
- [x] Rewrite the two mangled generated descriptions in `Independence/README.md` — `:105`
      (`PastingIndependence.lean`, currently beginning with a stray backtick and a dash) and
      `:110` (`StarDiscrimination.lean`, currently beginning mid-expression). They are
      hand-maintained cells carried across verbatim by the generator, so they can simply be
      rewritten in place.
- [x] Do **not** reconcile by deleting entries, and do **not** touch the generated line-count
      columns by hand — those are Phase 7's `--emit-inventory` job.
- [x] Run `bash scripts/check-module-invariants.sh --no-build` and iterate until green.
      *(deviation: altered — green on every group except `INV`'s four stale inventory blocks,
      which are Phase 7's regeneration job by design.)*

**Timing**: 1.25 hours

**Depends on**: 3

**Verification Tier**: prose

**Commit Mode**: per-substep

**Scope Hypothesis**: ten pre-existing results reconcile to one union list, plus one new entry,
across exactly two files; six Contents bullets are missing and two identifiers are dangling. Every
one of those counts is a hypothesis from the research report — confirm each at implementation time
by counting the numbered entries in each ledger, by
`diff <(grep '^import' FormalSystem/Metalogic/Independence.lean | sed …) <(grep '^- ' …)` or an
equivalent comparison of imports against Contents bullets, and by grepping each cited identifier
for existence. Adjust the plan's numbers to what is measured; do not force the measurement to the
plan.

**Files to modify**:

- `FormalSystem/Metalogic/Independence.lean` - module docstring: result list renumbered to the
  union, new entry added, Contents list completed.
- `FormalSystem/Metalogic/Independence/README.md` - result list renumbered identically, new entry
  added, two dangling identifiers repaired, two mangled descriptions rewritten.

**Verification**:

- The two numbered lists have the same length and the same entries in the same order.
- Every identifier cited in either ledger resolves:
  `for n in <cited names>; do grep -rq "\b$n\b" FormalSystem --include=*.lean || echo "DANGLING: $n"; done`
  prints nothing.
- Every module imported by `Independence.lean` appears in its Contents list.
- `bash scripts/check-module-invariants.sh --no-build` exits 0.

---

### Phase 6: Sweep the superseded frame-class spellings [COMPLETED]

**Goal**: No superseded frame-class tag spelling survives under `FormalSystem/`, and the
dangling identifiers that share the same root cause are repaired with it.

**Tasks**:

- [x] Run the sweep grep and work from its output, not from this plan's file list:
      `grep -rnE 'FrameClass\.(Dedekind|Discrete)|(^|[^A-Za-z.])\.(Dedekind|Discrete)([^A-Za-z]|$)' FormalSystem/`.
      Planning measured **eight** `README.md` files
      (`Metalogic/Independence/README.md`, `Metalogic/README.md`,
      `Metalogic/Decidability/BiLasso/README.md`, `Metalogic/Decidability/Verified/README.md`,
      `Semantics/README.md`, `Semantics/Correspondence/README.md`, `Theorems/README.md`,
      `ProofSystem/README.md`) and **zero** `.lean` files — so the whole sweep is free of rebuild
      cost. Re-measure before editing.
- [x] Replace `.Dedekind` with `.RTime` and `.Discrete` with `.ZTime` **only in frame-class tag
      position**. Do not touch the English adjective "Dedekind-complete", the module names
      `DedekindNonCompactness.lean` / `DedekindDerived.lean` / `CompletenessDedekind.lean` /
      `DiscreteNonCompactness.lean` / `DiscreteUnfolding.lean`, or the declaration names that
      genuinely contain those words.
- [x] Do **not** rename `TaskFrame.IsDiscrete`. It is live and correct.
      `Semantics/Correspondence/README.md:20` deliberately contrasts it with the frame-class tag;
      that contrast must survive the rename, which changes only the tag half of the sentence.
- [x] Repair the four dangling identifiers at `Metalogic/README.md:115` —
      `CompactDedekind`, `StrongCompletenessDedekind`, `SatisfiableDedekindSet`,
      `ModelExistenceDedekind` do not exist; the real declarations in
      `Metalogic/SetConsequence.lean` are `CompactRTime`, `StrongCompletenessRTime`,
      `SatisfiableRTimeSet` and `ModelExistenceRTime`. Confirm each by grep before writing. This
      is the same defect class as Phase 5's, found by the same sweep, and belongs with it.
      *(deviation: altered — the same sweep surfaced three MORE dangling identifiers of the same
      class at `ProofSystem/README.md:55-60`: `soundness_dedekind`, `completeness_dedekind` and
      `ValidDedekind` do not exist; the real names are `soundness_rtime`
      (`Metalogic/Soundness.lean`), `completeness_rtime` (`Metalogic/StrongCompleteness.lean`) and
      `ValidRTime` (`Semantics/Validity.lean`). Repaired here, so seven identifiers were fixed in
      this phase rather than four. The eight-file / zero-`.lean` measurement itself was confirmed
      exactly as the plan predicted, so the Verification Tier stays `prose`.)*
- [x] Note that two of `Independence/README.md`'s occurrences (`:98`, `:107`) sit **inside** a
      generated inventory block. The generator carries existing descriptions across verbatim, so
      editing them in place is correct and they survive Phase 7's regeneration.
- [x] Re-run the sweep grep and confirm it returns only legitimate mathematical prose.
- [x] Run `bash scripts/check-module-invariants.sh --no-build` and iterate until green.
      *(deviation: altered — green on every group except `INV`'s four stale inventory blocks,
      which are Phase 7's regeneration job by design.)*

**Timing**: 1 hour

**Depends on**: 5

**Verification Tier**: prose

**Commit Mode**: per-substep

**Scope Hypothesis**: eight markdown files and zero Lean files carry a superseded tag spelling,
and `Metalogic/README.md:115` carries four dangling identifiers. Both figures were measured during
planning by the greps above and both must be re-measured at implementation time before editing —
the dispatch and the research report both assumed the sweep was confined to
`Independence/README.md`, which planning disproved, so the file list is the least trustworthy
number in this plan. If any `.lean` file turns up in the re-measurement, the phase's Verification
Tier rises from `prose` to at least `local` and the rebuild budget must be re-examined before
proceeding.

**Files to modify**:

- `FormalSystem/Metalogic/README.md`, `FormalSystem/Metalogic/Independence/README.md`,
  `FormalSystem/Metalogic/Decidability/BiLasso/README.md`,
  `FormalSystem/Metalogic/Decidability/Verified/README.md`, `FormalSystem/Semantics/README.md`,
  `FormalSystem/Semantics/Correspondence/README.md`, `FormalSystem/Theorems/README.md`,
  `FormalSystem/ProofSystem/README.md` - superseded tag spellings replaced; four dangling
  identifiers repaired in the first of these.

**Verification**:

- The sweep grep returns no frame-class-tag occurrence of `.Dedekind` or `.Discrete`.
- `grep -rn 'TaskFrame.IsDiscrete' FormalSystem/` is unchanged in count.
- Every identifier newly written resolves under `FormalSystem/**/*.lean`.
- `bash scripts/check-module-invariants.sh --no-build` exits 0.

---

### Phase 7: C20 re-anchor, inventory regeneration, one full rebuild, full gate set [NOT STARTED]

**Goal**: The single budgeted full rebuild is spent, every gate is green, and the measured axiom
set is unchanged.

**Tasks**:

- [ ] Confirm Phases 4, 5 and 6 have made their **last** content edit. Inventory regeneration
      after this point is what the `.ZTime` incident (an `Independence.lean` docstring edit
      growing the file from 123 to 133 lines *after* regeneration) teaches.
- [ ] Run `bash scripts/check-module-invariants.sh --no-build` one more time. It is free and
      catches everything structural before any build cost is paid.
- [ ] If C20 flags shifted citations, run
      `python3 scripts/reanchor-lean-citations.py --by-name --files FormalSystem/ProofSystem/Axioms.lean`
      and **read the resulting diff** before accepting it. Never add a key to
      `scripts/c20-declaration-baseline.txt` — that file only ever shrinks.
- [ ] Run `bash scripts/check-module-invariants.sh --emit-inventory`. This is the real command;
      `scripts/readme-inventory.sh` is only a pointer script. It propagates counts into four
      blocks: `Metalogic/Independence/README.md`'s per-file table (which gains a row for the new
      module), `Metalogic/README.md`'s aggregators table line for `Independence.lean`,
      `Metalogic/README.md`'s subdirs rollup for `Independence/`, and the repository-root
      `README.md` totals block (which moves for the `Axioms.lean` docstring edits alone).
- [ ] Fill in the new module's inventory description immediately — it lands as
      `<!-- TODO: add description -->` — then re-run
      `bash scripts/check-module-invariants.sh --emit-inventory --check` and confirm it exits 0.
- [ ] Spend the single full rebuild:
      `bash .claude/scripts/lake-build-guard.sh --timeout 1800 -- build` detached, waited on with
      the bounded-waiter idiom (hard timeout, `kill -0` on the captured PID, one waiter per log).
      A second full rebuild means the phase ordering went wrong.
- [ ] Run the full `bash scripts/check-module-invariants.sh` — every check group green, including
      the build-dependent C1/C2/C6/C16/C24/C25 that `--no-build` skips.
- [ ] Run `bash scripts/readme-lint.sh` and confirm PASS. Its `STALE DATE` findings are warnings
      only and do not affect the exit code.
- [ ] Confirm the axiom audit: `FormalSystem/MainResults.lean`'s build-time `#print axioms` pass
      still measures exactly `[propext, Classical.choice, Quot.sound]`.
- [ ] Confirm the tree still carries zero structural sorries and zero `axiom` declarations outside
      `Boneyard/`.

**Timing**: 1.25 hours, mostly build wall-time

**Depends on**: 4, 6

**Verification Tier**: full

**Commit Mode**: per-substep

**Scope Hypothesis**: exactly one full rebuild, and exactly four inventory blocks move. Both are
hypotheses: confirm the rebuild count by the absence of any earlier `lake build` in the task's
command history, and the block count by reading `git diff --stat` after `--emit-inventory` rather
than assuming. `FormalSystem/README.md`'s `rows=loose` block is expected **not** to move (it lists
only files directly under `FormalSystem/`) and `FormalSystem/ProofSystem/README.md` carries no
inventory block at all — if either changes, re-read the generator's scope before accepting.

**Files to modify**:

- `FormalSystem/Metalogic/Independence/README.md`, `FormalSystem/Metalogic/README.md`,
  `README.md` - generated inventory blocks, plus the new module's description.
- `FormalSystem/ProofSystem/Axioms.lean` and any citing module - only if the C20 re-anchoring
  script rewrites a `:NNN` citation.

**Verification**:

- `bash scripts/check-module-invariants.sh` exits 0 with every check group green.
- `bash scripts/check-module-invariants.sh --emit-inventory --check` exits 0.
- `bash scripts/readme-lint.sh` reports PASS.
- The full `lake build` exits 0 with no `error:` and no `declaration uses 'sorry'` warning.
- The measured axiom set is exactly `[propext, Classical.choice, Quot.sound]`.
- Exactly one full rebuild was run across the whole task.

## Lean Challenge Statements

```lean
import FormalSystem.Semantics.Correspondence.DurationFrames
import FormalSystem.Semantics.Correspondence.Indicator
import FormalSystem.Metalogic.Soundness
import FormalSystem.Metalogic.Independence.CoNotPriorU

open FormalSystem FormalSystem.Syntax FormalSystem.Semantics FormalSystem.ProofSystem

namespace FormalSystem.Metalogic.Independence

theorem eq_base_of_lt_dense {fc : FrameClass} (h : fc < FrameClass.Dense) :
    fc = FrameClass.Base := sorry

theorem base_or_dense_of_lt_rtime {fc : FrameClass} (h : fc < FrameClass.RTime) :
    fc = FrameClass.Base ∨ fc = FrameClass.Dense := sorry

theorem not_validIn_base_density (a : Atom) :
    ¬ ValidIn FrameClass.Base
      ((Formula.atom a).allFuture.allFuture.imp (Formula.atom a).allFuture) := sorry

theorem not_validIn_ztime_density (a : Atom) :
    ¬ ValidIn FrameClass.ZTime
      ((Formula.atom a).allFuture.allFuture.imp (Formula.atom a).allFuture) := sorry

theorem density_minFrameClass_sharp (a : Atom) {fc : FrameClass} (hfc : fc < FrameClass.Dense) :
    ¬ ValidIn fc ((Formula.atom a).allFuture.allFuture.imp (Formula.atom a).allFuture) := sorry

theorem density_validIn_iff (a : Atom) (fc : FrameClass) :
    ValidIn fc ((Formula.atom a).allFuture.allFuture.imp (Formula.atom a).allFuture)
      ↔ FrameClass.Dense ≤ fc := sorry

theorem not_validIn_base_dense_indicator :
    ¬ ValidIn FrameClass.Base
      (Formula.untl Formula.bot (Formula.bot.imp Formula.bot)).neg := sorry

theorem not_validIn_ztime_dense_indicator :
    ¬ ValidIn FrameClass.ZTime
      (Formula.untl Formula.bot (Formula.bot.imp Formula.bot)).neg := sorry

theorem dense_indicator_minFrameClass_sharp {fc : FrameClass} (hfc : fc < FrameClass.Dense) :
    ¬ ValidIn fc (Formula.untl Formula.bot (Formula.bot.imp Formula.bot)).neg := sorry

theorem dense_indicator_validIn_iff (fc : FrameClass) :
    ValidIn fc (Formula.untl Formula.bot (Formula.bot.imp Formula.bot)).neg
      ↔ FrameClass.Dense ≤ fc := sorry

theorem not_validIn_base_prior_U_gap (a : Atom) :
    ¬ ValidIn FrameClass.Base (priorUGapFormula (Formula.atom a)) := sorry

theorem not_validIn_dense_prior_U_gap (a : Atom) :
    ¬ ValidIn FrameClass.Dense (priorUGapFormula (Formula.atom a)) := sorry

theorem prior_U_gap_minFrameClass_sharp (a : Atom) {fc : FrameClass}
    (hfc : fc < FrameClass.RTime) : ¬ ValidIn fc (priorUGapFormula (Formula.atom a)) := sorry

theorem sep_validOn_of_isLeastPos {F : TaskFrame} {p : F.Duration}
    (hp : IsLeast {x : F.Duration | 0 < x} p) (φ : Formula) :
    F.ValidOn ((Formula.and (Formula.kPlus φ)
        (Formula.kPlus (Formula.and φ (Formula.untl φ.neg φ))).neg).imp
        (Formula.kPlus (Formula.and (Formula.kPlus φ) (Formula.kMinus φ)))) := sorry

end FormalSystem.Metalogic.Independence
```

These fourteen are the headline results the ledgers and the minimal-frame-class docstring cite.
The module also carries supporting declarations that are not pinned here — the generic lemmas
`not_denselyOrdered_of_isLeastPos`, `not_validOn_density_of_isLeastPos`,
`not_validOn_dense_indicator_of_isLeastPos`, `not_validOn_prior_U_gap_clock` and
`not_kPlus_of_isLeastPos`; the carrier `denseSharpOrder` with `isLeast_one_denseSharpOrder`,
`sat_base_denseSharpFrame` and `sat_ztime_denseSharpFrame`; and the three derivability corollaries
`not_derivable_base_density`, `not_derivable_base_dense_indicator` and
`not_derivable_dense_prior_U_gap`. Their statements are in the research report's Appendix A and B
and are the implementer's to transcribe.

## Testing & Validation

- [ ] `lake env lean FormalSystem/Metalogic/Independence/DenseRTimeSharpness.lean` — 0 errors,
      0 warnings (Phases 1 and 2).
- [ ] No `sorry`, no `sorryAx`, and no new `axiom` declaration anywhere in the diff.
- [ ] Every headline name measures `[propext, Classical.choice, Quot.sound]`.
- [ ] The three shape-pin `example`s elaborate, making formula transcription a compiler
      obligation.
- [ ] Scoped build over the Independence closure exits 0 (Phase 3).
- [ ] `bash scripts/check-module-invariants.sh --no-build` exits 0 after each of Phases 4, 5, 6.
- [ ] No prefix `U(…, …)` rendering had its argument order changed (Phase 4).
- [ ] The two Independence ledgers carry identical, identically numbered result lists (Phase 5).
- [ ] No frame-class-tag occurrence of `.Dedekind` or `.Discrete` survives under `FormalSystem/`,
      and `TaskFrame.IsDiscrete` is untouched (Phase 6).
- [ ] Every identifier cited in any edited ledger or README resolves under
      `FormalSystem/**/*.lean`.
- [ ] `bash scripts/check-module-invariants.sh --emit-inventory --check` exits 0, with the new
      module's description filled in (Phase 7).
- [ ] Full `lake build` exits 0 — run exactly once across the whole task (Phase 7).
- [ ] Full `bash scripts/check-module-invariants.sh` green across every check group (Phase 7).
- [ ] `bash scripts/readme-lint.sh` reports PASS (Phase 7).
- [ ] `FormalSystem/MainResults.lean`'s build-time audit still measures exactly
      `[propext, Classical.choice, Quot.sound]` (Phase 7).

## Artifacts & Outputs

- `FormalSystem/Metalogic/Independence/DenseRTimeSharpness.lean` — new module: three closed
  `minFrameClass` rows with two full characterizations, the `sep` obstruction, and a docstring
  recording the frame-versus-model criterion and the class each result establishes.
- `FormalSystem/Metalogic/Independence.lean` — one added import, reconciled result list, completed
  Contents list.
- `FormalSystem.lean` — regenerated by `lake exe mk_all --lib FormalSystem`.
- `FormalSystem/ProofSystem/Axioms.lean` — two prose corrections and a rewritten
  minimal-frame-class lower-bound paragraph.
- `FormalSystem/Metalogic/Independence/ZTimeSharpness.lean` — corrected shape-pin note.
- `FormalSystem/Metalogic/Independence/README.md` — reconciled result list, repaired identifiers,
  rewritten descriptions, regenerated inventory block.
- `FormalSystem/Metalogic/README.md`, `FormalSystem/Metalogic/Decidability/BiLasso/README.md`,
  `FormalSystem/Metalogic/Decidability/Verified/README.md`, `FormalSystem/Semantics/README.md`,
  `FormalSystem/Semantics/Correspondence/README.md`, `FormalSystem/Theorems/README.md`,
  `FormalSystem/ProofSystem/README.md` — superseded frame-class spellings replaced; four dangling
  identifiers repaired.
- `README.md` (repository root) — regenerated totals block.
- `specs/671_minframeclass_sharpness_remaining_rows_and_docs/plans/01_dense-rtime-sharpness-ledger-fixes.md`
  — this plan.
- `specs/671_minframeclass_sharpness_remaining_rows_and_docs/summaries/01_dense-rtime-sharpness-ledger-fixes-summary.md`
  — the execution summary.

## Observations Recorded for Follow-Up

Recorded, not executed by this task:

- **The `sep` row.** Spawn a dedicated task for the `Lex (ℚ →₀ ℚ)` witness (~350-450 lines:
  ~80 for carrier setup including the three-line `IsOrderedAddMonoid` instance off
  `Finsupp.Lex.addLeftMono` / `addRightMono`, ~120 for least-support comparison lemmas, ~150 for
  the three semantic facts and assembly), with the plain-`ℚ` Cantor-set route as the alternative.
  `sep_validOn_of_isLeastPos`, shipped here, is the proved boundary it starts from.
- **A `.ZTime` validity result for `prior_U_gap`**, which is the only route to a full
  `validIn_iff` for that row. Conjectured, unproved, not needed for minimality.
- **A context note on the three-rendering `untl` convention.** The rule — constructor and infix
  are guard-first, prefix `U(e, g)` is event-first because it tracks `Formula.prettyPrint` —
  lives only in `Axioms.lean`'s header, and two separate readers (this task's dispatch and
  `ZTimeSharpness.lean`'s shape-pin note) have already reconstructed it wrongly. It belongs in
  `.claude/context/project/lean4/` with the pointer that a shape-pin `example` is the only
  reliable arbiter.
- **A context note on the frame-versus-model refutation criterion.** Recorded in three module
  docstrings and now a fourth, but nowhere an agent reads before starting. One paragraph: frame-
  level refutation is obstructed only when a statement must *simultaneously validate* something on
  a valuation-rich flow; a bare non-validity claim is never obstructed.
- **A runbook for an `Axioms.lean`-touching change.** `--no-build`, the C20 re-anchoring script,
  the C33 `mk_all` requirement and the four inventory sites are each discoverable only by reading
  `check-module-invariants.sh`'s header. Phase 7's task list is that runbook and should be lifted
  into `.claude/context/project/lean4/operations/`.
- **`readme-lint.sh`'s five `STALE DATE` warnings**, including `FormalSystem/README.md`'s stamp.
  Warnings only; they do not affect the exit code and are out of scope here.

## Rollback/Contingency

No phase in this plan is all-or-nothing across files, so ordinary per-substep reverts suffice and
no atomic-batch unit is declared.

- **Phases 1-2 (the new module).** Delete
  `FormalSystem/Metalogic/Independence/DenseRTimeSharpness.lean`, revert the one import line in
  `FormalSystem/Metalogic/Independence.lean`, and re-run `lake exe mk_all --lib FormalSystem`. The
  tree returns to its pre-task state with no rebuild owed.
- **Phases 4-6 (prose).** Every edit is comment, docstring or markdown; a per-file
  `git revert` of the relevant commit restores the prior text. Because each of these phases gates
  on `--no-build` before committing, a failure is caught before it can reach the rebuild.
- **Phase 7 (gates).** If the full rebuild fails, the failure is in code landed by Phases 1-2,
  which are independently revertible as above; the prose phases cannot break a build. If
  `--emit-inventory` produces an inconsistent block, re-run it after confirming no content edit
  followed it, rather than hand-editing a generated count.
- **If a genuine whole-tree rollback becomes necessary** (uncommitted work must be discarded),
  take a snapshot first per `context/contracts/recovery.md`'s rollback rung — including its
  out-of-scope override flag for the deliberate whole-tree case — and only then run the
  destructive command. Do not emit a bare precautionary snapshot at the start of a phase; an
  ordinary defensive checkpoint before risky work uses the durable, non-reverting `--no-revert`
  form instead.
