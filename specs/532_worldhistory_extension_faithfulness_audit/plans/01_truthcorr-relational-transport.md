# Implementation Plan: Task #532

- **Task**: 532 - Audit and resolve the partial-vs-total WorldHistory faithfulness gap
- **Status**: [IMPLEMENTING]
- **Effort**: 7 hours
- **Dependencies**: None
- **Research Inputs**: specs/532_worldhistory_extension_faithfulness_audit/reports/01_worldhistory-extension-faithfulness-audit.md; verified experiment specs/532_worldhistory_extension_faithfulness_audit/reports/TruthCorr-experiment.lean.txt
- **Artifacts**: plans/01_truthcorr-relational-transport.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

The research settled the decision: neither widen `TruthIso` to a `WorldHistory`-level `Equiv`
(HEq trap) nor keep the two duplicated hand-written inductions. Instead land the paper's own
proof shape as a **relational** transport `TruthCorr` (a `Prop`-valued correspondence on
arbitrary histories + atomic agreement on related pairs + totality-existence in both directions,
mirroring `def:time-shift-histories`, `app:auto_existence`, and the `□` case of
`lem:history-time-shift-preservation`), run the six-case induction once in
`truthAt_of_truthCorr`, and derive `TimeShift.timeShift_preserves_truth`,
`IntTransfer.truthAt_map`, and `truthAt_of_truthIso` from it with their statements
byte-for-byte unchanged. The verified experiment is the starting point; this plan integrates it
into the live `FormalSystem/Semantics/` modules with the hand-written inductions deleted and
every docstring rewired. Alongside, the plan clears the hygiene defects the audit found:
re-pinning `specs/paper-definitions-of-record.md` (the lint fails today on 10 anchors), replacing
raw-line-number paper citations with `\label` citations, and correcting the convex docstring's
"exactly" overclaim.

Baseline measured at planning time: `lake build` green (2520 jobs, zero `sorry`);
`scripts/check-module-invariants.sh` ALL CHECKS PASSED (C15: 47 anchor citations resolve);
`scripts/check-paper-definitions.sh` FAILS with exactly the 10 drifted anchors the report lists.

### Research Integration

Taken directly from the report (§3 decision, §4 machine-checked transport, §5 divergence table,
§6 recommendations):

- **Decision (c)** is fixed; this plan does not re-derive it. `TruthCorr` fields are `dur`
  (order-iso), `Rel`, `atom`, `total_fwd`, `total_bwd` exactly as in the experiment.
- Three verified instances port verbatim: `TruthIso.toCorr`, `shiftCorr` (with `ShiftRel`,
  `shiftRel_timeShift`, `shiftRel_timeShift_neg`), `alignedCorr` (`Rel := Aligned e`).
- Two recorded tactic traps must be honoured: `shiftCorr.dur` must be `OrderIso.addRight Δ` (a
  hand-built `{ toEquiv := Equiv.addRight Δ, … }` leaves an unreduced `let` blocking `rw` on
  `states`); `shiftRel_timeShift_neg` closes the state equation with
  `WorldHistory.states_eq_of_time_eq … (add_neg_cancel_right z Δ).symm`, no `HEq`. And in
  `timeShift_preserves_truth`'s derivation, `change … at h; rw [add_sub_cancel] at h` succeeds
  where `simpa` fails to normalise `(OrderIso.addRight Δ) x`.
- **Do not narrow `timeShift_preserves_truth` to `H_F`** (report rec. 5; the prior plan's
  prohibition stands). Optionally add the `H_F`-specialised corollary as the documented
  `lem:history-time-shift-preservation` counterpart.
- Hygiene items #26-#29 are in scope. Items #9/#30 (`lem:fibers` RETIRED anchor), #11
  (`hF_nonempty` explicit `w`), and #14 (`FrameOver.nullity_identity` documented redundancy) are
  recorded as no-action (rec. 8).
- Axiom expectation: `truthAt_of_truthCorr` uses only `propext`/`Quot.sound`; `alignedCorr`
  brings in `Classical.choice` via Mathlib's `≃+o` API (already the axiom profile of
  `IntTransfer`'s consumers).

### Prior Plan Reference

No prior plan for this task. The blocked-phase record in
`specs/523_frame_kit_helpers_transport_standard_frames/plans/01_frame-kit-helpers-transport.md`
(Phase 10, Phase 12) is the triggering context: it calibrates the derivation effort (each
instance is 10-30 lines once the generic lemma exists) and fixes the prohibition on weakening
`timeShift_preserves_truth`'s statement. Its `induction φ` ledger (summary file) counts five
truth-transport inductions today: `truthAt_of_truthIso`, `truthAt_of_truthAntiIso`,
`timeShift_preserves_truth`, `truthAt_map`, `truthAt_add_hist_period`.

### Roadmap Alignment

`specs/ROADMAP.md` loaded. This task advances the **Paper Alignment Programme** section ("Cite
the paper by `\label` and quote verbatim — never by bare line number"): Phases 4 and 5 bring the
record file and the Lean docstrings back into that discipline. It also touches Phase 7
(Repository Hygiene) in spirit. No roadmap checkbox names this task; no `roadmap_flag` was
passed, so no ROADMAP phases are added. Observation only (out of scope, not modified here): the
Paper Alignment paragraph in ROADMAP still names the fourth axiom *Spherical*; the live paper
and the tree say *Saturation*.

## Goals & Non-Goals

**Goals**:
- Land `TruthCorr` + `truthAt_of_truthCorr` in `FormalSystem/Semantics/Truth.lean` as the single
  generic truth-transport induction, docstringed against the paper's relational proof shape.
- Derive `TimeShift.timeShift_preserves_truth`, `IntTransfer.truthAt_map`, and
  `Truth.truthAt_of_truthIso` from it, **statements and names unchanged**, and delete the three
  hand-written inductions they replace.
- Reduce the truth-transport `induction φ` count in `Semantics/` + `Independence/` from five to
  three (generic `TruthCorr`, generic `TruthAntiIso` twin, and the per-history
  `truthAt_add_hist_period` exception).
- Re-pin `specs/paper-definitions-of-record.md` so `scripts/check-paper-definitions.sh` exits 0.
- Replace every raw-line-number paper citation in `Truth.lean` and `WorldHistory.lean` with a
  `\label` citation; correct the convex docstring overclaim; update the stale `def:world-history`
  verbatim quotes to the live wording.
- Every Lean phase ends at a green `lake build` with no new `sorry`.

**Non-Goals**:
- Narrowing `timeShift_preserves_truth` (or any consumer-facing statement) to total histories.
- Any `WorldHistory F ≃ WorldHistory F'` or any `HEq`.
- Relationalising `TruthAntiIso` (a `TruthCorr` twin with an order anti-isomorphism). It keeps
  its own generic induction; a follow-up may unify it later.
- Changing `FrameOver.nullity_identity`, `converse`, `hF_nonempty`'s signature, or the
  `lem:fibers` RETIRED-anchor citations (all already recorded as deliberate).
- Editing the paper, `ROADMAP.md`, or `FwdRecPeriodicity.truthAt_add_hist_period`'s statement.
- Pinning `app:auto_existence` or `lem:history-time-shift-preservation` in the record manifest
  (they stay `LIVE-UNPINNED`; the new docstrings cite them by name only, never quoting text).

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `TruthCorr` must precede the `TimeShift` namespace in `Truth.lean` (currently `TruthIso` sits after it at ~l.1035) so Phase 2 can consume it | M | H | Phase 1 inserts the new section between `end Truth` (~l.548) and `/-! ## Time-Shift Preservation` (~l.550); it depends only on the `truth_norm` lemmas defined above that point |
| Experiment tactics drift when pasted into a different namespace/variable context (`variable {F : TaskFrame}` is in scope in `Truth.lean`) | M | M | Port verbatim first, compile, then adapt binders; the two recorded traps are listed in each Lean phase |
| Deleting the 230-line induction changes elaboration of the ten consumer sites | H | L | Statement, name, and namespace unchanged; consumers are enumerated and the phase's gate is a full `lake build` |
| `alignedCorr` introduces `Classical.choice` where `truthAt_map` had none | L | M | Record `#print axioms` before and after; `validDiscrete_iff_validInt` already lives in the choice-using profile, and the repository's accepted axiom set is exactly `propext`/`Classical.choice`/`Quot.sound` |
| Record re-pin: the paper is dirty against its git HEAD (`M JPL/possible_worlds.tex`) | L | H | Apply the record's documented dirty-pin caveat; pin the file checksum (authoritative) and note HEAD as "file dirty against it" |
| Docstring edits are load-bearing (`/-- -/` doc comments are parsed; a stray `-/` breaks the build) | M | L | Phase 5 still runs `lake build` even though its tier is `prose` |
| New anchor citations break C15 | M | L | Only cite anchors already in the manifest or the KNOWN-ANCHORS block; run `check-module-invariants.sh` in every phase that adds a citation |
| Implementer writes "task 523"/"task 532" into a Lean docstring | M | M | `.claude/rules/no-task-references-in-deliverables.md`: cite the report/plan by filename inside `specs/` only; Lean docstrings cite declarations and `\label`s |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 4 | -- |
| 2 | 2, 3 | 1 |
| 3 | 5 | 2, 3, 4 |
| 4 | 6 | 5 |

Phases within the same wave can execute in parallel. Phases 1 and 4 touch disjoint files
(`Truth.lean` vs `specs/paper-definitions-of-record.md`); Phases 2 and 3 touch disjoint files
(`Truth.lean` vs `IntTransfer.lean`). Phase 5 is serialised after 2 and 3 because it edits
`Truth.lean` and `WorldHistory.lean` docstrings and must see the final code.

### Phase 1: Land `TruthCorr` and derive `truthAt_of_truthIso` from it [COMPLETED]

**Goal**: The relational generic transport exists in `Truth.lean`, is placed where the
`TimeShift` section can consume it, and `TruthIso` becomes a derived special case with
`truthAt_of_truthIso`'s statement unchanged and its own induction deleted.

**Tasks**:
- [x] In `FormalSystem/Semantics/Truth.lean`, insert a new section
      `/-! ## Truth correspondences — the generic relational transport -/` **between**
      `end Truth` (the end of the `truth_norm` block, ~l.548) and
      `/-! ## Time-Shift Preservation` (~l.550). Port from the experiment file:
      `structure TruthCorr` (fields `dur`, `Rel`, `atom`, `total_fwd`, `total_bwd`) and
      `Truth.truthAt_of_truthCorr` (the ~45-line six-case induction, written against
      `imp_iff`/`box_iff`/`untl_iff`/`snce_iff`).
- [x] Docstring `TruthCorr` field-by-field against the paper, citing by `\label` **name only**
      (no verbatim quotes of unpinned anchors): `Rel` = the relation of
      `def:time-shift-histories` read on arbitrary histories; `total_fwd`/`total_bwd` =
      `app:auto_existence` in the two directions the `□` case of
      `lem:history-time-shift-preservation` uses; `atom` = that lemma's base case (absorbing the
      domain transport, since `TruthAt`'s atom clause carries the domain conjunct). Say explicitly
      why a relation and not an `Equiv`: the paper's proof uses existence in both directions and
      never injectivity or round-trip cancellation, and an `Equiv` on `WorldHistory` would hit the
      dependent-`states` `HEq` trap `IntTransfer.lean` documents.
- [x] Docstring `truthAt_of_truthCorr` as the one generic induction; note it is the
      `truthAt_of_truthIso` body with `I.hist.surjective` replaced by `I.total_bwd`/`I.total_fwd`.
- [x] In the existing `## Truth isomorphisms — the generic transport` section (~l.1001): add
      `def TruthIso.toCorr` (port verbatim: `Rel := fun σ σ' => ∃ hσ hσ', I.hist ⟨σ,hσ⟩ = ⟨σ',hσ'⟩`)
      and **replace the body** of `Truth.truthAt_of_truthIso` with the one-line
      `truthAt_of_truthCorr (TruthIso.toCorr I) φ τ.val (I.hist τ).val ⟨τ.property, (I.hist τ).property, rfl⟩ t`.
      The theorem's statement must remain byte-identical.
- [x] Rewrite that section's prose docstring: `TruthIso` is now the total-only, bijective special
      case of `TruthCorr`; keep the "why `atom` is quantified over all histories" paragraph (it is
      still true and `FwdRecPeriodicity` cites it); retire the "Why `hist` is an honest
      equivalence and not a map" framing in favour of "the paper needs existence both ways;
      `TruthCorr` asks for exactly that, and an `Equiv` supplies it".
- [x] Leave `TruthAntiIso` and `truthAt_of_truthAntiIso` untouched. *(deviation: altered — code untouched; one docstring sentence in `truthAt_of_truthAntiIso` now names `truthAt_of_truthCorr` as its twin, since the `truthAt_of_truthIso` induction it referred to no longer exists)*
- [x] `lake build`; confirm `LoopingDuration.lean` (consumer of `truthAt_of_truthIso`) still
      compiles unchanged; run `lean_verify` / `#print axioms` on `Truth.truthAt_of_truthCorr`
      (expected `propext`, `Quot.sound`) and `Truth.truthAt_of_truthIso` (unchanged set).

**Phase record**: `induction φ` code sites before = {`timeShift_preserves_truth`, `truthAt_atomFree_history_indep`, `truthAt_of_truthIso`, `truthAt_of_truthAntiIso`}; after = {`truthAt_of_truthCorr`, `timeShift_preserves_truth`, `truthAt_atomFree_history_indep`, `truthAt_of_truthAntiIso`} (four each, one-for-one). Axioms: `truthAt_of_truthCorr`, `truthAt_of_truthIso`, `TruthIso.toCorr` all `[propext, Quot.sound]`. Full `lake build` 2520 jobs exit 0; `check-module-invariants.sh` ALL CHECKS PASSED (C15: 48 anchors). `truthAt_of_truthIso` header byte-identical to HEAD.

**Timing**: 1.5 hours

**Depends on**: none

**Verification Tier**: full

**Scope Hypothesis**: The new section is ~90 lines (structure + docstrings + induction) and the
`TruthIso` section shrinks by ~45 lines (the deleted induction) net of ~20 added
(`toCorr`). Confirm by `git diff --stat` after the build; confirm the `truthAt_of_truthIso`
statement is byte-identical by diffing the declaration header against `git show HEAD`.

**Files to modify**:
- `FormalSystem/Semantics/Truth.lean` - new `TruthCorr` section before `TimeShift`; `TruthIso.toCorr`; `truthAt_of_truthIso` re-proved; section docstrings rewritten

**Verification**:
- `lake build` exits 0; `grep -rn sorry FormalSystem/Semantics/Truth.lean` unchanged (zero)
- `grep -n "induction φ" FormalSystem/Semantics/Truth.lean` shows exactly four hits before and after, with the named set changed one-for-one: before = {`timeShift_preserves_truth`, `truthAt_atomFree_history_indep`, `truthAt_of_truthIso`, `truthAt_of_truthAntiIso`}; after = {`timeShift_preserves_truth`, `truthAt_atomFree_history_indep`, `truthAt_of_truthCorr`, `truthAt_of_truthAntiIso`}. Record the measured before/after sets in the phase record
- `bash scripts/check-module-invariants.sh` still passes (new `\label` citations resolve)
- No new task-number strings in `FormalSystem/**`

---

### Phase 2: Derive `timeShift_preserves_truth` from `shiftCorr`; delete the 230-line induction [NOT STARTED]

**Goal**: `TimeShift.timeShift_preserves_truth` keeps its exact statement (arbitrary `σ`) and
name but is a ~12-line consequence of `truthAt_of_truthCorr` at the `shiftCorr` instance; the
hand-written six-case induction is gone.

**Tasks**:
- [ ] In `FormalSystem/Semantics/Truth.lean`, inside `namespace TimeShift` (before
      `timeShift_preserves_truth`), port from the experiment: `ShiftRel Δ ρ ρ'`
      (pointwise domain/state agreement at `z` vs `z + Δ`), `shiftRel_timeShift`,
      `shiftRel_timeShift_neg`, and `def shiftCorr (M) (Δ) : TruthCorr M M` with
      `dur := OrderIso.addRight Δ` (**not** a hand-built `OrderIso`; recorded trap),
      `Rel := ShiftRel Δ`, `total_fwd` via `ρ.timeShift (-Δ)` and
      `WorldHistory.isTotal_timeShift`, `total_bwd` via `ρ'.timeShift Δ`.
- [ ] Docstring `ShiftRel` as `def:time-shift-histories`'s `τ ≈ σ` read on arbitrary histories,
      and `shiftCorr.total_fwd`/`total_bwd` as `app:auto_existence` ("total since 𝔇 is a group",
      i.e. `isTotal_timeShift`). Cite by name only.
- [ ] Replace the body of `timeShift_preserves_truth` with the experiment's derivation
      (`have h := truthAt_of_truthCorr (shiftCorr M (y - x)) φ (σ.timeShift (y - x)) σ
      (shiftRel_timeShift _ σ) x`, then `change … at h; rw [add_sub_cancel] at h; exact h`).
      Statement, name, namespace, and argument order unchanged.
- [ ] Rewrite `timeShift_preserves_truth`'s docstring and the `## Time-Shift Preservation`
      section docstring: drop the six-bullet proof sketch of the deleted induction; state that
      the theorem is Lean-stronger than `lem:history-time-shift-preservation` (the paper states it
      for `τ, σ ∈ H_F`; the general form is free because `ShiftRel` is pointwise) and that every
      live consumer passes a total history; keep the "no shift-closure hypothesis" paragraph.
      Remove the stale "With the new semantics ... these proofs become simpler" note.
- [ ] Add the paper-faithful corollary
      `theorem timeShift_preserves_truth_total (M) (σ : WorldHistory F) (hσ : σ.IsTotal) (x y) (φ) : …`
      (or the `F.HF` form — implementer's choice) as a one-liner from the general theorem, with
      a docstring naming it as the `lem:history-time-shift-preservation` counterpart. Do **not**
      make any consumer use it; this is documentation alignment only.
- [ ] `lake build`; run `#print axioms` on `TimeShift.timeShift_preserves_truth` (expected
      `propext`, `Quot.sound` — unchanged from before).

**Timing**: 1.5 hours

**Depends on**: 1

**Verification Tier**: full

**Scope Hypothesis**: The theorem body shrinks from ~230 lines (l.598-827 today) to ~12, plus
~40 lines of `ShiftRel`/`shiftCorr`. The ten consumer sites enumerated in the report
(`Soundness.lean:307`, `FrameClassVariants.lean:116`, `RegionFrame.lean:435,476`,
`Decidable.lean:689,701,1557`, `BoxOracle.lean:249`, `ShiftSet.lean:370`, `Truth.lean` `box_const`
region) need no edits. Confirm by `grep -rn "timeShift_preserves_truth" FormalSystem --include=*.lean`
before and after: the set of call sites is identical and the build is green.

**Files to modify**:
- `FormalSystem/Semantics/Truth.lean` - `ShiftRel`, `shiftCorr`, derivation; delete the hand-written induction; docstrings; `timeShift_preserves_truth_total`

**Verification**:
- `lake build` exits 0, no new `sorry`
- `grep -c "induction φ" FormalSystem/Semantics/Truth.lean` drops by exactly one relative to Phase 1's post-state
- Statement of `timeShift_preserves_truth` byte-identical to `git show HEAD:FormalSystem/Semantics/Truth.lean` (diff the declaration header)
- `bash scripts/check-module-invariants.sh` passes

---

### Phase 3: Derive `IntTransfer.truthAt_map` from `alignedCorr`; delete its induction [NOT STARTED]

**Goal**: `truthAt_map` keeps its exact statement (arbitrary aligned pair) and is a one-line
consequence of `truthAt_of_truthCorr` at the `alignedCorr` instance; `Aligned` is documented as
a `TruthCorr.Rel` verbatim.

**Tasks**:
- [ ] In `FormalSystem/Semantics/IntTransfer.lean`, immediately before `truthAt_map`, port
      `def alignedCorr (e : ↑D ≃+o ↑E) (M) : TruthCorr M (TaskModel.map M e)` with
      `dur := e.toOrderIso`, `Rel := Aligned e`, `atom` = the existing `truthAt_map` `atom` case
      verbatim (`ha.dom`, `ha.st`, `σ.states_eq_of_time_eq (e.symm (e t)) t`),
      `total_fwd` via `WorldHistory.map`/`isTotal_map`/`aligned_map`, `total_bwd` via
      `WorldHistory.comap`/`aligned_comap` with the bare-term totality proof
      `fun s => hσ' (e s)` (recorded trap: `simpa` does not close it).
- [ ] Replace the body of `truthAt_map` with
      `fun σ σ' ha t => truthAt_of_truthCorr (alignedCorr e M) φ σ σ' ha t`. Statement unchanged.
- [ ] Update `truthAt_map`'s docstring (drop the induction narrative; keep the recorded
      `simpa` trap, now living in `alignedCorr.total_bwd`), and the module docstring's
      "Design decision: `Aligned`, not `Equiv`" and "Main results" bullets: `Aligned` is the
      `Rel` field of a `TruthCorr`, which is why no `Equiv` was ever needed; the prohibition
      "Do not replace `Aligned` with an `Equiv`" stays.
- [ ] `lake build`; `#print axioms IntTransfer.truthAt_map` before (from `git stash` or the
      HEAD build) and after; record both in the phase record. `Classical.choice` appearing via
      `≃+o` is expected and acceptable; `sorryAx` is not.

**Timing**: 1 hour

**Depends on**: 1

**Verification Tier**: full

**Scope Hypothesis**: `truthAt_map` shrinks from ~72 lines (l.292-364) to ~5 plus ~25 lines of
`alignedCorr`; `IntTransfer.lean` then contains zero `induction φ`. Confirm with
`grep -c "induction φ" FormalSystem/Semantics/IntTransfer.lean` = 0 and
`validDiscrete_iff_validInt` compiling unchanged.

**Files to modify**:
- `FormalSystem/Semantics/IntTransfer.lean` - `alignedCorr`; `truthAt_map` re-proved; docstrings

**Verification**:
- `lake build` exits 0, no new `sorry`
- `grep -c "induction φ" FormalSystem/Semantics/IntTransfer.lean` = 0
- Statement of `truthAt_map` byte-identical to HEAD
- `bash scripts/check-module-invariants.sh` passes

---

### Phase 4: Re-pin `specs/paper-definitions-of-record.md` against the live paper [COMPLETED]

**Goal**: `scripts/check-paper-definitions.sh` exits 0 (quiet case (a)) with all 10 drifted
anchors re-quoted and re-hashed, the drift classified, and the sentinels re-pinned per the
record's own convention.

**Tasks**:
- [x] Run `bash scripts/check-paper-definitions.sh` and capture the OLD/NEW blocks for all 10
      anchors: `def:task-relation`, `def:directed`, `def:frame`, `def:frame#Compositionality`,
      `def:frame#Seriality`, `def:frame#Limit`, `def:world-history`, `thm:extension`,
      `def:BLplus-defined`, `def:time-shift-histories`.
- [x] For each, run `check-paper-definitions.sh --resolve "ANCHOR|KIND|ENCLOSING|LOCATOR"`
      (`env|-|-` for the eight environments; `item|def:frame|Compositionality` etc. for the
      three items) and replace the entry's fenced `latex` block and its `sha256:` line with the
      resolved text and hash. Update the manifest rows in the `MANIFEST:BEGIN/END` block to the
      new hashes.
- [x] Add a dated narrative section `### Drift correction (2026-09-02): ten-anchor re-pin`
      directly under the existing "Rename absorption (2026-09-02)" section, following the shape
      of the 2026-08-17 and 2026-08-25 entries: list the 10 anchors; classify each as
      substantive or cosmetic (at minimum: `def:time-shift-histories` dropped the explicit
      translation function in favour of `τ(z) = σ(z + y − x)` — substantive;
      `def:world-history`'s last sentence now reads "The set of all possible worlds over 𝔉 is
      denoted `H_F`" — terminological, equivalent by the definition's own "equivalently";
      `def:frame` text says *Saturation* — the rename already absorbed at the key level;
      `def:BLplus-defined` and the three `def:frame#*` items are `\bf` → `\it` emphasis —
      cosmetic; `thm:extension` footnote wording — check and state). Record that the
      repository's Lean statements are unaffected (every change is equivalent), per the audit.
- [x] Update the two navigation headings that the prior pass flagged for a deliberate decision:
      `def:directed — directed family (used by Spherical)` → `(used by Saturation)`, and
      `def:time-shift-histories — …, translation form` → `…, pointwise form`. These are the
      record's own navigation, not quoted paper text, so updating them does not falsify the
      record; say so in the narrative.
- [x] Re-pin the sentinels, because a drift correction is being absorbed (the dirty-pin
      convention): update the `<!-- PINNED_COMMIT -->`, `<!-- FILE_CHECKSUM -->`,
      `<!-- LINE_COUNT -->` comments and add a provenance-table row with the paper repo's
      `git HEAD` (noting the file is dirty against it), the file sha256, line count, and UTC
      time. Measured at planning time: HEAD `14f1bee5…`, sha256 `7303bc9e…`, 4867 lines —
      re-measure at implementation time; do not copy these.
- [x] Do **not** edit the paper. Do not rewrite historical prose in earlier sections.
- [x] Run `bash scripts/check-paper-definitions.sh` → exit 0, and
      `bash scripts/check-module-invariants.sh` → C15 still PASS.

**Phase record**: measured 10 drifted / 0 unresolvable before; quiet case-(a) pass after (`check-paper-definitions.sh` exit 0). Paper repo HEAD had moved since planning (`fa0dbf7c…`, not `14f1bee5…`) but the file sha256 `7303bc9e…`/4867 lines matched; pinned the measured values. Also re-keyed the `def:frame` sub-anchor table's stale `#Spherical` row to `#Saturation` (recorded in the narrative). `check-module-invariants.sh` C15 PASS (48 anchors).

**Timing**: 1.5 hours

**Depends on**: none

**Verification Tier**: local

**Scope Hypothesis**: Exactly 10 anchors drift and 0 are unresolvable (measured at planning
time). Confirm with the script's summary line before editing; if the paper has moved again and
the count differs, absorb the actual set and record the delta in the narrative.

**Files to modify**:
- `specs/paper-definitions-of-record.md` - 10 entries re-quoted/re-hashed; manifest rows; narrative section; two headings; sentinels

**Verification**:
- `bash scripts/check-paper-definitions.sh; echo $?` prints 0 with the quiet pass
- `bash scripts/check-module-invariants.sh` reports C15 PASS
- `git diff` shows no change outside `specs/paper-definitions-of-record.md`

---

### Phase 5: Lean docstring hygiene — citations by `\label`, convex wording, `H_F` quotes [NOT STARTED]

**Goal**: No raw paper line numbers remain in `Truth.lean` or `WorldHistory.lean`; the convex
docstring says "equivalent to" rather than "exactly"; every verbatim `def:world-history` quote in
the tree matches the re-pinned record; `FwdRecPeriodicity`'s "not an instance" note names
`TruthCorr`.

**Tasks**:
- [ ] `FormalSystem/Semantics/Truth.lean` module docstring: replace "def:BL-semantics, lines
      1857-1872" (two occurrences, ~l.28 and ~l.141), "line 892" (~l.35 and ~l.51), "lines
      899-919" (~l.42), and "JPL Paper lines 892-919" (~l.142) with citations by `\label`
      (`def:BL-semantics`, `app:TaskSemantics`) and no line numbers. While there, correct the
      atom bullet against the record's `def:BL-semantics` entry: the paper's atom clause is
      `τ(x) ∈ |p|` at a possible world `τ ∈ H_F` with **no** domain conjunct; the domain
      conjunct is this tree's Decision A encoding (`specs/decisions/total-history-validity-decisions.md`)
      forced by evaluating on arbitrary `WorldHistory`s. Do not fabricate a paper claim about
      "atoms outside the domain"; state it as the Lean-side generalisation the audit records.
- [ ] `FormalSystem/Semantics/WorldHistory.lean` `timeShift` docstring (~l.280): replace
      "app:auto_existence (line ~2330) defines time-shift automorphisms" with a by-label
      citation: `def:time-shift-histories` defines the relation, `app:auto_existence` asserts
      existence of the shifted possible world; note the Lean definition is on arbitrary histories
      (Lean-stronger, harmless; `isTotal_timeShift` is the paper's "total since 𝔇 is a group").
- [ ] `WorldHistory.lean` module docstring (~l.66) "Convexity is now formally enforced (matching
      paper definition exactly)" → state the paper's strict `x < y < z` formulation and Lean's
      `x ≤ y ≤ z` are equivalent (endpoints are already in `X`), not identical. Check the
      `convex` field docstring (~l.108) — it quotes the paper verbatim and is fine; add one
      sentence noting the `≤` reading is equivalent if absent.
- [ ] Update the stale verbatim quote "The set of all total world histories over $\F$ is denoted
      $H_{\F}$" to the live wording from the re-pinned record ("The set of all possible worlds
      over $\F$ is denoted $H_{\F}$") at: `WorldHistory.lean` ~l.339 and ~l.391,
      `PartialHistory.lean` ~l.38, `Metalogic/Algebraic/FlowFrame.lean` ~l.51. Keep the
      surrounding Lean prose ("`H_F` — the set of all total world histories over a frame,
      bundled as a type") since that is the tree's own description, not a quote.
- [ ] `FormalSystem/Semantics/Correspondence/FwdRecPeriodicity.lean` (~l.377-390): update the
      "not a `Semantics.TruthIso` instance" paragraph to say it is not a `TruthCorr` instance
      either, for the same reason (`TruthCorr.atom` is quantified over every related pair
      because the `□` case applies the IH at a pair the caller did not choose; `hper` is about
      one history).
- [ ] Grep-sweep: `grep -rn "line ~\|lines [0-9]\+-[0-9]\+\|line [0-9]\{3,4\}" FormalSystem/Semantics/Truth.lean FormalSystem/Semantics/WorldHistory.lean`
      returns zero hits; `grep -rn "total world histories over \$" FormalSystem --include=*.lean`
      returns zero hits.
- [ ] `lake build` (doc comments are parsed) and `bash scripts/check-module-invariants.sh`.

**Timing**: 1 hour

**Depends on**: 2, 3, 4

**Verification Tier**: prose

**Scope Hypothesis**: Six raw-line-number sites in `Truth.lean`, one in `WorldHistory.lean`,
one "exactly" overclaim, four stale `H_F` quotes, one `FwdRecPeriodicity` paragraph — measured
by grep at planning time. Re-run the greps in the phase before editing; the counts are the
hypothesis, the grep output is the fact.

**Files to modify**:
- `FormalSystem/Semantics/Truth.lean` - module docstring citations and atom-clause wording
- `FormalSystem/Semantics/WorldHistory.lean` - `timeShift` docstring; convex wording; `H_F` quotes
- `FormalSystem/Semantics/PartialHistory.lean` - `H_F` quote
- `FormalSystem/Metalogic/Algebraic/FlowFrame.lean` - `H_F` quote
- `FormalSystem/Semantics/Correspondence/FwdRecPeriodicity.lean` - "not an instance" paragraph

**Verification**:
- Diff read-through: every changed hunk lies inside a `/-! -/` or `/-- -/` comment
- `lake build` exits 0 (unchanged job count aside from the touched modules)
- `bash scripts/check-module-invariants.sh` passes (C15)
- Both grep sweeps above return zero hits

---

### Phase 6: Closure — full gate set, `induction φ` ledger, cross-record updates [NOT STARTED]

**Goal**: The whole task is verified against the complete gate set, the transport-induction
ledger is measured and recorded, and the paused prior plan's blocker record points at the
resolution.

**Tasks**:
- [ ] Run the full gate set from a clean state: `lake build` (exit 0, zero `sorry` in
      `FormalSystem/`), `bash scripts/check-module-invariants.sh` (ALL CHECKS PASSED),
      `bash scripts/check-paper-definitions.sh` (exit 0), `bash scripts/readme-lint.sh` if
      `FormalSystem/Semantics/README.md` was touched.
- [ ] Measure the ledger: `grep -rn "induction φ" FormalSystem/Semantics FormalSystem/Metalogic/Independence`
      and classify every hit. Expected truth-transport inductions: `Truth.truthAt_of_truthCorr`,
      `Truth.truthAt_of_truthAntiIso`, `FwdRecPeriodicity.truthAt_add_hist_period` (three).
      Expected non-transport inductions (unchanged): `Truth.truthAt_atomFree_history_indep`,
      `ShiftSet.forward_repr`, `ShiftSet.reverse_repr`. Record the measured table in the
      implementation summary.
- [ ] `lean_verify` (or `#print axioms`) on `Truth.truthAt_of_truthCorr`,
      `TimeShift.timeShift_preserves_truth`, `truthAt_map`, `Truth.truthAt_of_truthIso`: no
      `sorryAx`; axiom sets ⊆ {`propext`, `Classical.choice`, `Quot.sound`}. Record them.
- [ ] `FormalSystem/Semantics/README.md`: extend the `Truth.lean` row to mention the relational
      truth transport (`TruthCorr` / `truthAt_of_truthCorr`) if the README's row convention
      admits it; otherwise leave it and say so.
- [ ] Append a short resolution note to
      `specs/523_frame_kit_helpers_transport_standard_frames/plans/01_frame-kit-helpers-transport.md`
      under the Phase 10 blocker record and the Phase 12 exclusion row (specs-only; task
      references are permitted there): the quantifier mismatch is resolved by the relational
      `TruthCorr` in this task's plan; both derivations landed with statements unchanged; the
      acceptance criterion now reads "at most three truth-transport `induction φ` in
      `Semantics/` + `Independence/`" (two generic + the per-history exception). Do not change
      the phase status markers of that plan.
- [ ] Confirm no file outside `specs/**` contains "task 523" or "task 532":
      `grep -rn "task 5[23][23]" FormalSystem docs scripts --include=* 2>/dev/null` (or run
      `scripts/check-task-references.sh` if present in this checkout).
- [ ] Commit per the git-workflow convention.

**Timing**: 0.5 hours

**Depends on**: 5

**Verification Tier**: full

**Files to modify**:
- `FormalSystem/Semantics/README.md` - `Truth.lean` row (conditional)
- `specs/523_frame_kit_helpers_transport_standard_frames/plans/01_frame-kit-helpers-transport.md` - resolution note (specs-only)

**Verification**:
- All four gate commands exit 0
- Ledger table recorded with exactly three truth-transport inductions
- Axiom report recorded, no `sorryAx`

## Testing & Validation

- [ ] `lake build` green at the end of every Lean phase (1, 2, 3, 5, 6); zero new `sorry`
- [ ] `TimeShift.timeShift_preserves_truth`, `IntTransfer.truthAt_map`, `Truth.truthAt_of_truthIso`:
      declaration headers byte-identical to `git show HEAD`
- [ ] All consumer sites of the three theorems compile with no edits (enumerated in Phase 2's
      scope hypothesis; `LoopingDuration.lean`; `validDiscrete_iff_validInt`)
- [ ] `grep -c "induction φ" FormalSystem/Semantics/IntTransfer.lean` = 0;
      `FormalSystem/Semantics/Truth.lean` contains exactly three (`truthAt_of_truthCorr`,
      `truthAt_of_truthAntiIso`, `truthAt_atomFree_history_indep`)
- [ ] `bash scripts/check-paper-definitions.sh` exits 0
- [ ] `bash scripts/check-module-invariants.sh` ALL CHECKS PASSED (C15 included)
- [ ] No `HEq`, no `WorldHistory ≃`, no `sorry`, no new axiom anywhere in the diff
- [ ] No raw paper line numbers in `Truth.lean`/`WorldHistory.lean`; no "total world histories
      over $\F$" verbatim quote remains in `FormalSystem/**`
- [ ] No task-number references in files outside `specs/**`

## Artifacts & Outputs

- `FormalSystem/Semantics/Truth.lean`: `TruthCorr`, `truthAt_of_truthCorr`, `TruthIso.toCorr`,
  `TimeShift.ShiftRel`/`shiftCorr`, `timeShift_preserves_truth_total`; two hand-written
  inductions deleted (~275 lines net removed)
- `FormalSystem/Semantics/IntTransfer.lean`: `alignedCorr`; `truthAt_map` induction deleted
- `specs/paper-definitions-of-record.md`: 10 anchors re-pinned, drift narrative, sentinels
- Docstring hygiene across `Truth.lean`, `WorldHistory.lean`, `PartialHistory.lean`,
  `FlowFrame.lean`, `FwdRecPeriodicity.lean`
- Implementation summary at `specs/532_worldhistory_extension_faithfulness_audit/summaries/01_truthcorr-relational-transport-summary.md`
  with the measured `induction φ` ledger and axiom report

## Rollback/Contingency

Every phase commits at a green build, so rollback is `git revert` of the phase commit(s). Phases
2 and 3 each replace a proof body without touching a statement, so if a derivation fails to
elaborate the fallback is to keep the hand-written induction for that one theorem, leave
`TruthCorr` landed (Phase 1 stands on its own), and record the exact failing goal in the phase's
blocker record — never a `sorry`, never a statement weakening. Phase 4 is a single markdown
file; if the paper moves mid-phase, re-run the script and absorb the new set rather than pinning
a stale checksum. Phase 5 is prose-only and independently revertible.
