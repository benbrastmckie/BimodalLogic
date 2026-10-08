# Implementation Plan: Task #735

- **Task**: 735 - Assemble the decidable stab check on the ray-product presentation: Decidable (PlusValidZTime phi)
- **Status**: [NOT STARTED]
- **Effort**: 6 hours
- **Dependencies**: 711, 737, 742 (all complete)
- **Research Inputs**: specs/735_decidable_stab_check_ray_product_assembly/reports/01_decidable-stab-check-assembly.md
- **Artifacts**: plans/01_decidable-stab-check-assembly.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

This plan executes the acceptance criterion's **second branch**: a recorded, cited verdict that
the ray-product presentation cannot deliver `Decidable (PlusValidZTime φ)`, with the obstruction
carried as a wired, machine-checked probe rather than prose. The obstruction is already compiled
(`Probe735.not_presented`, 0 sorries, axioms `[propext, Classical.choice, Quot.sound]`, and
independently recompiled by the orchestrator): on fixture model A at the seam `(t, a)` with
`φ := Fp`, `Presented` fails for **every** finite `Q`, `lab`, `step`, by pumping a repeated run
state against `LocalRun.untl`. So `Presented` is a soundness device only, never a completeness
carrier, and no enumeration of `Presented`-presentations can decide `PlusValidZTime φ` whether or
not the B2b successor is ever built.

Beside the verdict the plan lands the one positive in-frame result the research compiled:
under `Presented`, `⊡φ` at the seam is the run-level condition that every anchored run carries
`clPhi φ` at its `now` state (`plusStab_iff_forall_run_of_presented`), and that condition is
decided by state liveness in the `now`-free step graphs (`stabCheckSig`,
`stabCheck_iff_of_presented`, `decidableStab_of_presented`). Every such statement is stated
**under `Presented`** and its docstring, index row and README entry say plainly that `Presented`
is unsatisfiable on model A, so the result is vacuous for such models and is a conditional bridge,
not a per-seam decision procedure for any model in the tree.

`Decidable (PlusValidZTime φ)` is **not stated in this task in any form** -- unconditional,
conditional, or as a hypothesis bundle (research Finding 4 names the forbidden shape). Definition
of done: the probe is wired and green; the four new declarations are sorry-free, pinned, and
indexed as Conditional; the verdict names (C), (S), (W) in the RaySummary README and the ROADMAP's
critical path is corrected; the full gate set is green.

### Research Integration

From `reports/01_decidable-stab-check-assembly.md`:
- Finding 2 (the obstruction, compiled) is Phase 1 verbatim: `probes/presented-not-complete.lean`
  (246 lines measured) moves into the evidence collection and the `WIRED` array.
- Finding 1 (run-level `⊡` check, compiled, 34 lines) is Phase 2's first lemma; its liveness
  reduction (`OnRun q ↔ lab q now ∧ live Gfwd q ∧ live Gbwd q`, gluing template
  `exists_run_of_live` in `HitOf.lean`) is Phase 2's only non-trivial proof and the plan's main
  risk item (research marked it Medium: statement shape verified, proof not run).
- Finding 3 (the verdict: (C) Hit-level completeness with a computable bound, (S) Hit-level
  soundness = the unfiled B2b record restated, (W) a closure-wide quasimodel) is Phase 4's
  README/ROADMAP content.
- Finding 4 (the forbidden conditional shape) is a hard constraint on every phase: no theorem
  mentions `PlusValidZTime`.
- Finding 5 costs are carried as Scope Hypotheses per phase.
- Decisions D-1..D-4 adopted. The report's optional `HitPresented` phase (250-400 lines, MEDIUM,
  satisfiability OPEN) is NOT planned -- see Non-Goals.
- Recommendation 4's `file_scope` list is the union of this plan's `Files to modify` fields, which
  `plan-file-scope-harvest.sh` harvests at plan postflight.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

`specs/ROADMAP.md` was consulted read-only. This plan advances the Phase 1-2 Decidability front's
"Assemble the decidable stab check on the ray-product presentation" item (the 735 bullet) to its
verdict outcome, and corrects the critical-path statement "742 → successor (B2b) → 735" (lines 28,
100, 195 and the B2b/735 bullets at 142-159), which the research shows is wrong for this task's
deliverable: B2b is (S) only, (C) and (W) are new unfiled requirements, and 735's verdict does not
depend on B2b. No task dependencies are changed and no new tasks are filed by this plan -- both
are reserved for the user.

## Goals & Non-Goals

**Goals**:
- `Probe735.not_presented` wired as `specs/evidence/seam-gluing-ray-product/presented-not-complete.lean`
  in `scripts/check-evidence-probes.sh`, with its "decision it holds in place" row.
- `plusStab_iff_forall_run_of_presented` (Trace.lean), `onRun_iff_live`, `stabCheckSig`,
  `stabCheckSig_iff`, `stabCheck_iff_of_presented`, `decidableStab_of_presented` (new
  `RaySummary/StabCheck.lean`), zero sorries, every statement under `[F.IsRegular]` and
  `Presented`, none mentioning `PlusValidZTime`.
- Axiom pins in `KTypeSummaryAxiomTest.lean`, C14 pins in `check-module-invariants.sh`,
  `#guard` computability witnesses in `KTypeFinEvalTest.lean`, Conditional rows in
  `docs/theorem-index.md`.
- The recorded verdict (RaySummary README "The verdict" section; Decidability README cell;
  aggregator header) naming (C), (S), (W) with their statement shapes and why `Presented` cannot
  carry (C); ROADMAP critical path corrected.

**Non-Goals**:
- Stating `Decidable (PlusValidZTime φ)` in any form (HARD CONSTRAINT; research Finding 4).
- The `HitPresented` generalization and the per-triple representative check via `PathEntry.rep`
  (research Finding 1, optional): 250-400 lines MEDIUM against a hypothesis whose satisfiability
  the research leaves OPEN; excluded as scope widening beyond the acceptance text. Recorded as a
  follow-up candidate in Decisions.
- (C), (S), (W) themselves: successor requirements, named, never attempted.
- Building B2b or adding it to this task's dependencies (research D-4); filing new tasks; editing
  `active_projects[].dependencies` -- all reserved for the user.
- Rewriting task 742's own deliverable text (docstrings, index row, README sentences, the 742
  ROADMAP bullet) -- see Risk R5 and the Decisions section; this plan adds adjacent text only.
- Any complexity statement, any finite-fibre assumption, anything about `⊡(Pp)` (forward-only
  fixtures throughout; no backward Bool-fixture bridge exists).

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| R1: the `OnRun ↔ liveness` gluing (Phase 2) does not go through as sketched -- ℤ-indexed run from two ℕ-chains, `IsRun`'s `now`-exactly-at-`t` clause | M | L-M | Template is `pump_isRun` in the wired probe (same case split on `z ≤ i`) and `exists_run_of_live` (`HitOf.lean`); define `ρ z := if t ≤ z then f (z - t).toNat else g (t - z).toNat` with `f 0 = g 0 = q`; `omega` on `Int.toNat`; if blocked, mark Phase 2 `[BLOCKED]` per `plan-compliance.md` rather than weakening the statement |
| R2: a new library module reads as a decision procedure (the "true-looking name" defect) | H | L | Names carry `_of_presented`; `StabCheck.lean`'s header and each docstring state that `Presented` is refuted on model A by `presented-not-complete.lean`, so the result is vacuous there; index rows begin "**Conditional**"; no declaration mentions `PlusValidZTime` (grep gate in Phase 3) |
| R3: `scripts/check-evidence-probes.sh` and the evidence collection are shared with 733, 734, 739 (all `not_started`, no live writer at plan time) | M | L | Phase 1 is the only phase touching the script; it appends one `WIRED` entry and one comment block; if the batch admission gate reports a collision, dispatch Phase 1 singly |
| R4: `#guard` witnesses are hypotheses: the chosen two-state presentations may not discriminate as sketched | L | M | Phase 3 runs `#eval` first, then pins the observed value; the discriminator must show one `true` and one `false` `stabCheckSig` or the witness is replaced, never the statement |
| R5: task 742's completed deliverables (`hit_eq_hitOf_of_presented`, `plusStab_iff_forall_hitOf_of_presented`, their docstrings, index row, README/ROADMAP/aggregator sentences, the pin-test prose block) are stated under `Presented` and are therefore VACUOUS on non-trivial models; their text says only "discharged for no non-trivial model", the weaker reading | M | certain | This plan does NOT rewrite them silently: every phase adds adjacent, cross-referencing text and leaves 742's sentences verbatim. The correction is scoped and costed in Decisions and raised as a non-blocking `user_decision` on `.return-meta.json` for the user's ruling |
| R6: `FormalSystem.lean` is generated (`lake exe mk_all`; C33 refuses a hand-edited root) | L | M | Phase 2 adds the module to the aggregator by hand and runs `lake exe mk_all` for the root, never edits `FormalSystem.lean` directly |
| R7: C16/C26/C29 env-linter findings on a new module (742 Phase 10 hit seven) | L | M | Phase 2 runs `bash scripts/check-module-invariants.sh --no-build` before closing; fix forward with strict generalizations, no in-source suppressions |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2 | -- |
| 2 | 3 | 2 |
| 3 | 4 | 1, 2, 3 |

Phases within the same wave can execute in parallel. Phases 1 and 2 touch disjoint files
(evidence collection + gate script vs. library + tests root).

### Phase 1: Wire the obstruction -- `Presented` is not a completeness carrier [NOT STARTED]

**Goal**: The verdict's machine-checked carrier lives in the evidence collection and is compiled
by the gate script on every run: `¬ Presented MA stayA t Fp lab step` for every finite `Q`,
`lab`, `step`.

**Tasks**:
- [ ] Copy `specs/735_decidable_stab_check_ray_product_assembly/probes/presented-not-complete.lean`
      to `specs/evidence/seam-gluing-ray-product/presented-not-complete.lean` **verbatim in every
      declaration** (namespace `Probe735`, the fixture re-declared, `loopIdx`/`pump`/`pump_isRun`/
      `pump_exists`, `not_presented`, the `#print axioms` foot). Extend only the header docstring to
      the collection's house style: what is established / what is NOT established (nothing about
      `⊡(Pp)`; nothing about `HitPresented := HitCl = ↑hitOf`, left OPEN; no complexity statement;
      nothing about infinite-slice models) / axiom record / compile line
      `lake env lean specs/evidence/seam-gluing-ray-product/presented-not-complete.lean` / the
      decision held in place: "`Presented` is a soundness device (B2b, `Presented (modelOf P)`),
      never a completeness one; no decision procedure for `PlusValidZTime φ` may proceed by
      'every refuting regular ℤ-model has a `Presented` presentation'; B2b's consistency conditions
      must exclude pumpable eventuality-deferring run sets (`presented_localRun`)". Cite the fixture
      source `quasistate-does-not-determine-hit.lean` (transcribed, never imported).
- [ ] `scripts/check-evidence-probes.sh`: append `"seam-gluing-ray-product/presented-not-complete"`
      to the `WIRED` array after `quasistate-does-not-determine-hit`, and add its header-comment
      row in the probe table (`probe | the decision it holds in place`, wrapped at the existing
      column), labelled `OBSTRUCTION (verdict on the ray-product assembly)` and naming the three
      missing theorems (C), (S), (W) in one line each. Do not reorder or touch any other entry.
- [ ] `lake env lean specs/evidence/seam-gluing-ray-product/presented-not-complete.lean` exits 0;
      then `bash scripts/check-evidence-probes.sh` exits 0 with 19 wired probes listed (18 + this
      one; confirm the count from the script's own `PASS all N` line).
- [ ] Commit (`task 735 phase 1: ...`) staging exactly the two files.

**Timing**: 1 hour

**Depends on**: none

**Verification Tier**: local

**Scope Hypothesis**: 246 lines carried from the research report (measured there by `wc -l` on
the compiled probe) plus a ~15-line header extension and a ~40-line script comment block; confirm
by `wc -l` on both files and by the script's wired-probe count.

**Files to modify**:
- `specs/evidence/seam-gluing-ray-product/presented-not-complete.lean` - new wired probe (verbatim declarations from the research probe)
- `scripts/check-evidence-probes.sh` - one `WIRED` entry and its header-comment row

**Verification**:
- `bash scripts/check-evidence-probes.sh` exits 0 and lists `presented-not-complete` as PASS.
- `#print axioms Probe735.not_presented` = `[propext, Classical.choice, Quot.sound]`;
  `grep -c sorry` on the probe = 0.
- `git diff --stat` on the script shows additions only.

---

### Phase 2: The run-level `⊡` bridge and the liveness decider under `Presented` [NOT STARTED]

**Goal**: The positive in-frame result, sorry-free and honestly labelled: under `Presented`, `⊡φ`
at the seam is "every anchored run carries `clPhi φ` at its `now` state", and that is decided by
`now`-free liveness on the presentation -- a conditional bridge over a hypothesis the wired probe
refutes on model A.

**Tasks**:
- [ ] `FormalSystem/Metalogic/Decidability/RaySummary/Trace.lean`, inside `section Presented`
      directly after `plusStab_iff_forall_hitOf_of_presented`: add
      `plusStab_iff_forall_run_of_presented` **verbatim** from
      `probes/stab-run-check.lean` (statement and proof: `rw [plusStab_iff_omega]`, both directions
      through `hP _ |>.mp/.mpr` and `rw [← hc]` on the definitional `clTrace`/`runTrace`
      unfoldings). Docstring: the `⊡` bridge with the family machinery factored out; no `k`-type is
      evaluated; `Paper: —` (the formalization's own device); "under `Presented`, which
      `specs/evidence/seam-gluing-ray-product/presented-not-complete.lean` refutes on a three-state
      regular model for every finite presentation, so this is vacuous there". Leave the two
      existing 742 docstrings verbatim (Risk R5).
- [ ] Create `FormalSystem/Metalogic/Decidability/RaySummary/StabCheck.lean`
      (`import FormalSystem.Metalogic.Decidability.RaySummary.Trace`; copyright header as the
      siblings). Header docstring: what it decides (the run-level condition on a presentation, by
      liveness), what it does NOT (no decision procedure for any model in the tree -- `Presented`
      is refuted on model A; nothing about `PlusValidZTime`; no complexity bound; no finite-fibre
      assumption; forward-only fixtures), and the three missing theorems (C), (S), (W) by name with
      a pointer to the RaySummary README.
- [ ] In `namespace FormalSystem.Metalogic.WeakCanonical` (presentation-level, no model):
      `fwdNowFree lab step now : Q → Q → Bool := fun x y => step x y && !lab y now`,
      `bwdNowFree lab step now : Q → Q → Bool := fun x y => step y x && !lab y now`,
      `OnRun lab step now t q : Prop := ∃ ρ, IsRun lab step now t ρ ∧ ρ t = q`, and
      `onRun_iff_live` (the Challenge statement below). Proof: (⇒) `f n := ρ (t + n)` and
      `g n := ρ (t - n)` are `HasChain` witnesses (the `now` clause of `IsRun` gives
      `!lab (ρ z) now` for `z ≠ t`), then `live_iff`; (⇐) from `live_iff` obtain `f`, `g` with
      `f 0 = g 0 = q`, glue `ρ z := if t ≤ z then f (z - t).toNat else g (t - z).toNat`, prove
      `IsRun` by the `pump_isRun` case split (`z + 1 ≤ t` / `z + 1 = t` / `t ≤ z`, `omega` on
      `Int.toNat`), and `ρ t = q` by `rfl`-after-`simp`.
- [ ] `stabCheckSig lab step now phi : Bool := decide (∀ q, lab q now = true → live (fwdNowFree lab step now) q = true → live (bwdNowFree lab step now) q = true → lab q phi = true)`
      (`Fintype.decidableForallFintype`), and `stabCheckSig_iff` (Challenge statement below) from
      `onRun_iff_live`: `∀ ρ, IsRun … ρ → lab (ρ t) phi` ↔ `∀ q, OnRun … q → lab q phi`. Note
      `t` does not occur in `stabCheckSig`; the anchor is carried by `now`.
- [ ] In `namespace FormalSystem.Metalogic.Decidability.RaySummary` (closure instance):
      `stabCheck_iff_of_presented` = `stabCheckSig_iff` composed with
      `plusStab_iff_forall_run_of_presented`, and
      `decidableStab_of_presented … (hP : Presented M τ t φ lab step) : Decidable (PlusTruthAt M τ t (.stab φ)) := decidable_of_iff _ (stabCheck_iff_of_presented …)`.
      Docstrings on both: "**Conditional** on `Presented`, refuted on model A by
      `presented-not-complete.lean`; vacuous there; not a decision procedure for `PlusValidZTime`
      and nothing here mentions it." No `#print axioms` in library files (pins live in Phase 3).
- [ ] `FormalSystem/Metalogic/Decidability/RaySummary.lean`: add the import and a `## Modules`
      line for `RaySummary.StabCheck`; add ONE sentence to the header beside "no decision
      procedure is built, no decidability result is proved" reading "a conditional per-seam
      `⊡` decider exists under `Presented` (`StabCheck`), and `Presented` is refuted as a
      completeness carrier by the wired probe `presented-not-complete.lean`" -- leave the existing
      sentences verbatim. Run `lake exe mk_all` so `FormalSystem.lean` picks up the new module
      (never hand-edit the root; Risk R6).
- [ ] Scoped build, detached and guarded:
      `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Decidability.RaySummary`
      green; `grep -c sorry` over `StabCheck.lean` and the Trace.lean hunk = 0;
      `grep -n PlusValidZTime FormalSystem/Metalogic/Decidability/RaySummary/StabCheck.lean` returns
      only docstring lines that say it is NOT decided (or nothing).
- [ ] `bash scripts/check-module-invariants.sh --no-build` green on the linter checks (C16, C26,
      C29, C33, INV); fix forward in-phase (Risk R7).
- [ ] Commit per green sub-step (`task 735 phase 2.1: run bridge`, `2.2: liveness
      characterization`, `2.3: decider`), staging exactly the files named below.

**Timing**: 2 hours

**Depends on**: none

**Verification Tier**: local

**Scope Hypothesis**: 34 lines in Trace.lean (measured in the research report on the compiled
probe) + 150-250 lines in `StabCheck.lean` (research Finding 5, calibrated on
`exists_run_of_live`'s ~100 lines for a harder gluing). Confirm by `wc -l` at phase end; a figure
above 300 is a signal to re-read the gluing sketch, not to widen the phase.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/RaySummary/Trace.lean` - `plusStab_iff_forall_run_of_presented` after `plusStab_iff_forall_hitOf_of_presented`
- `FormalSystem/Metalogic/Decidability/RaySummary/StabCheck.lean` - new module: `fwdNowFree`, `bwdNowFree`, `OnRun`, `onRun_iff_live`, `stabCheckSig`, `stabCheckSig_iff`, `stabCheck_iff_of_presented`, `decidableStab_of_presented`
- `FormalSystem/Metalogic/Decidability/RaySummary.lean` - import, `## Modules` line, one header sentence
- `FormalSystem.lean` - regenerated by `lake exe mk_all` (never hand-edited)

**Verification**:
- Scoped guarded build of `FormalSystem.Metalogic.Decidability.RaySummary` green; zero sorries in
  the new module and the Trace.lean hunk.
- `lean_verify` (or one `lake env lean` pass with `#print axioms`) on the four headline names
  reports exactly `[propext, Classical.choice, Quot.sound]`.
- Every new docstring names `Presented` as its hypothesis and cites
  `presented-not-complete.lean`; no new declaration's statement mentions `PlusValidZTime`.

---

### Phase 3: Pins, computability witnesses, and Conditional index rows [NOT STARTED]

**Goal**: Every new headline is machine-pinned in both harnesses, `stabCheckSig` is witnessed to
evaluate (and to discriminate) on the existing two-state presentations, and the theorem index
carries the results as **Conditional** rows with the refutation cited in the row text.

**Tasks**:
- [ ] `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean`: after the existing four
      `Presented` pins, a new prose block ("The run-level bridge and the liveness decider under
      `Presented` -- conditional, and `Presented` is refuted as a completeness carrier by the wired
      probe `presented-not-complete.lean`; the existing four rows above are vacuous on that
      fixture for the same reason") and four `#guard_msgs`/`#print axioms` rows:
      `FormalSystem.Metalogic.Decidability.RaySummary.plusStab_iff_forall_run_of_presented`,
      `FormalSystem.Metalogic.WeakCanonical.onRun_iff_live`,
      `FormalSystem.Metalogic.Decidability.RaySummary.stabCheck_iff_of_presented`,
      `FormalSystem.Metalogic.Decidability.RaySummary.decidableStab_of_presented`. Leave the
      existing prose block verbatim (Risk R5).
- [ ] `Tests/BimodalTest/Metalogic/KTypeFinEvalTest.lean`: a `## stabCheckSig on finite labelled presentations`
      section. First `#eval`, then pin with `#guard` (Risk R4): (i)
      `stabCheckSig labW stepW true false = true` (the one `now` state reads `phi` too);
      (ii) a new `labX : Bool → twoLetter.preds → Bool := fun q p => q && p` (state `true` reads
      `now` only) with `!stabCheckSig labX stepW true false` (a live `now` state lacking `phi`);
      (iii) `stabCheckSig labX stepAlt true false = true` (no `now` state is live in both
      `now`-free graphs, so the check is vacuously true -- the liveness guard is load-bearing);
      (iv) `stabCheckSig labAlt stepAlt true false = true` (no `now` state at all). Each number is a
      witness of computability and nothing else; say so in the section docstring.
- [ ] `docs/theorem-index.md`, Decidability section, directly after the
      `hit_eq_hitOf_of_presented` row: three rows -- `plusStab_iff_forall_run_of_presented`,
      `stabCheck_iff_of_presented`, `decidableStab_of_presented` -- each Statement cell beginning
      "**Conditional**: under the realization hypothesis `Presented` …" and ending "`Presented` is
      refuted as a completeness carrier on a three-state regular ℤ-model for every finite
      presentation by the wired probe `specs/evidence/seam-gluing-ray-product/presented-not-complete.lean`,
      so this is vacuous there; nothing is stated about `PlusValidZTime`". Frame class `ZTime`,
      Axioms `pcq pinned:C14`. Leave the existing 742 row text verbatim (Risk R5).
- [ ] `scripts/check-module-invariants.sh`: C14 -- append three matched pairs (one
      `'…' depends on axioms: [propext, Classical.choice, Quot.sound]` line in the `C14BASE`
      heredoc and the corresponding `#print axioms …` line in the `C14LEAN` heredoc, same trailing
      position on both sides) for the three indexed names, and extend the C14 comment block's
      name list by one sentence ("… and the three `StabCheck` rows, conditional on `Presented`,
      which `presented-not-complete.lean` refutes as a completeness carrier").
- [ ] Full gate: `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build` (whole
      project, detached, bounded waiter), `bash scripts/check-module-invariants.sh` (C14 with the
      updated baseline; C9 no task numbers outside `specs/**`), `bash scripts/check-evidence-probes.sh`,
      `bash .claude/scripts/verify-deploy.sh` -- all green.
- [ ] Commit per green sub-step (`3.1: pins`, `3.2: witnesses`, `3.3: index rows + C14`).

**Timing**: 1.5 hours

**Depends on**: 2

**Verification Tier**: full

**Scope Hypothesis**: 4 pin rows, 4 `#guard`s (+1 new two-state labelling), 3 index rows, 3 C14
pairs. Confirm each count against the diff; the `#guard` values are confirmed by `#eval` before
pinning, never assumed from the sketch.

**Files to modify**:
- `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean` - four new pin rows and a prose block
- `Tests/BimodalTest/Metalogic/KTypeFinEvalTest.lean` - `stabCheckSig` witnesses, one new labelling `labX`
- `docs/theorem-index.md` - three Conditional rows in the Decidability section
- `scripts/check-module-invariants.sh` - three C14 matched pairs and the comment-block sentence

**Verification**:
- `bash .claude/scripts/verify-deploy.sh` green (the complete gate set -- the `full` tier's
  requirement), plus the whole-project guarded build, `check-module-invariants.sh` and
  `check-evidence-probes.sh` named above.
- `grep -n "PlusValidZTime" docs/theorem-index.md` shows the three new rows only in the phrase
  "nothing is stated about `PlusValidZTime`"; `grep -rn "task 735\|Task 735" FormalSystem docs Tests scripts` is empty.

---

### Phase 4: The recorded verdict and the ROADMAP correction [NOT STARTED]

**Goal**: The verdict is recorded where the programme reads it -- the RaySummary README, the
Decidability README, and the ROADMAP -- naming what the ray-product presentation cannot deliver,
why, and the three theorems the lift to validity still needs; the ROADMAP's wrong critical path is
corrected; no task dependency is changed and no task is filed.

**Tasks**:
- [ ] `FormalSystem/Metalogic/Decidability/RaySummary/README.md`: (a) module table row for
      `StabCheck.lean` (line count by `wc -l`, never carried); (b) a new section `## The verdict`
      placed after "What it does not do": the ray-product presentation as landed
      (`seamOmegaEquiv` + `hitOf` + `Presented`) delivers a decidable per-seam `⊡` check
      conditional on `Presented` and nothing further, because `Presented` is refuted as a
      completeness carrier by `presented-not-complete.lean` (statement verbatim, proof shape in two
      sentences: pumping-closed run-trace sets vs. the trace map's discontinuity in `untl` letters,
      so the seam's trace set is not closed while the path set is), and because (C) Hit-level
      completeness with a computable bound, (S) Hit-level soundness (the B2b record restated at
      `hitOf` level; its consistency conditions must exclude pumpable eventuality-deferring run
      sets by `presented_localRun`), and (W) a closure-wide quasimodel over all seams and times
      (`box` per time, `stab` per state, nested under `untl`/`snce`) exist neither in the tree nor
      as records -- each with its statement shape carrying `[F.IsRegular]`, L⁺, ZTime, in a
      three-row table; what the verdict does NOT establish (`⊡(Pp)`, `HitPresented` OPEN,
      infinite-slice models, any bound); literature position (HWZ 2000 Thm 14 ⇐ realizes by
      persistent runs, never exact trace equality; corpus entry is UNVERIFIED-summary provenance,
      cited as context only). (c) In "What it does not do", ADD one bullet "**It does not decide
      `PlusValidZTime φ`, and the presentation cannot**" pointing at the verdict; (d) add the
      probe to the "Evidence" section as the fifth wired probe; (e) add the four new names to the
      pinned-profile list in "The consumer relation". Every existing sentence stays verbatim
      (Risk R5); new text cites the probe by filename, never a task number.
- [ ] `FormalSystem/Metalogic/Decidability/README.md`: the `RaySummary/` cell -- append
      "`StabCheck.lean` (the run-level `⊡` bridge and a liveness decider, conditional on
      `Presented`); the wired probe `presented-not-complete.lean` refutes `Presented` as a
      completeness carrier, so no decision procedure for `PlusValidZTime` is reachable from this
      presentation (8 files)" -- adjust the file count, leave the rest verbatim.
- [ ] `specs/ROADMAP.md`: (a) lines 28-29 and 195-196 (the two `/orchestrate 735` comments):
      replace "file the B2b successor … and add it to 735's dependencies first" with "735's verdict
      does not depend on B2b (RaySummary README, 'The verdict')"; (b) line 100: replace
      "**Critical path: 742 → successor (B2b) → 735.**" with a paragraph: the critical path to
      `Decidable (PlusValidZTime φ)` is NOT through B2b; B2b is (S) only; (C) and (W) are
      unfiled requirements named in the RaySummary README; the ray-product presentation's
      deliverable on this front is the verdict plus the conditional per-seam check; (c) the B2b
      bullet (lines 142-153): APPEND "Consistency conditions must exclude pumpable
      eventuality-deferring run sets (`presented_localRun`); completeness is out of this record's
      reach (`presented-not-complete.lean`); 735 does not depend on it" -- no other change;
      (d) the 735 bullet (lines 154-159): rewrite to the outcome (verdict + conditional decider +
      wired probe, with the HARD CONSTRAINTS restated in one line) and mark `- [x]` with
      `*(Completed: Task 735, {DATE})*`. Do NOT add new `- [ ]` bullets for (C), (S), (W) and do
      NOT edit the 742 `[x]` bullet's text (Risk R5; filing is the user's call).
- [ ] `bash scripts/check-module-invariants.sh --no-build` green (C9: no task numbers under
      `FormalSystem/`, `docs/`, `Tests/`, `scripts/`); `bash .claude/scripts/check-task-references.sh`
      (if deployed) green; `bash scripts/check-evidence-probes.sh` green; the Phase 3 full gate is
      not invalidated (prose-only edits -- confirm by `git diff --stat` that no `.lean` file
      changed in this phase).
- [ ] Commit (`task 735 phase 4: verdict record and ROADMAP correction`), staging exactly the three
      files.

**Timing**: 1.5 hours

**Depends on**: 1, 2, 3

**Verification Tier**: prose

**Scope Hypothesis**: 1 README section (~40-60 lines) + 1 table row + 3 small additions, 1 README
cell, 4 ROADMAP hunks. Confirm against the diff; no `.lean` file is touched.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/RaySummary/README.md` - module row, `## The verdict`, one "does not do" bullet, Evidence and consumer-relation additions
- `FormalSystem/Metalogic/Decidability/README.md` - the `RaySummary/` cell
- `specs/ROADMAP.md` - critical-path correction, B2b bullet appendix, 735 bullet outcome, two command comments

**Verification**:
- Diff read-through: every changed hunk is prose; no `.lean` file in `git diff --stat`.
- `grep -n "742 → successor\|B2b → 735\|add it to 735" specs/ROADMAP.md` is empty.
- `grep -rn "task 735\|Task 735" FormalSystem docs` is empty; the verdict text names
  `presented-not-complete.lean`, (C), (S), (W), `[F.IsRegular]`, L⁺ and `PlusValidZTime` explicitly,
  and never writes "L⁺ is decidable" or any bound.

## Lean Challenge Statements

```lean
import FormalSystem

open FormalSystem.Syntax FormalSystem.Semantics FormalSystem.PlusLanguage
open FormalSystem.Metalogic.WeakCanonical FormalSystem.Metalogic.Expressiveness
open FormalSystem.Metalogic.Decidability.RaySummary

namespace FormalSystem.Metalogic.WeakCanonical

variable {sig : MonadicSignature} {Q : Type} [Fintype Q] [DecidableEq Q]
  (lab : Q → sig.preds → Bool) (step : Q → Q → Bool) (now : sig.preds)

/-- The forward `now`-free step graph: a step whose target does not read `now`. -/
def fwdNowFree : Q → Q → Bool := fun x y => step x y && !lab y now

/-- The backward `now`-free step graph: a step into `x` from a source not reading `now`. -/
def bwdNowFree : Q → Q → Bool := fun x y => step y x && !lab y now

/-- `q` is the `now` state of some run of the presentation anchored at `t`. -/
def OnRun (t : ℤ) (q : Q) : Prop := ∃ ρ : ℤ → Q, IsRun lab step now t ρ ∧ ρ t = q

/-- A state is on an anchored run iff it reads `now` and is live in both `now`-free graphs. -/
theorem onRun_iff_live (t : ℤ) (q : Q) :
    OnRun lab step now t q ↔
      lab q now = true ∧ live (fwdNowFree lab step now) q = true ∧
        live (bwdNowFree lab step now) q = true := sorry

/-- The decider: every live `now` state reads `phi`. `t` does not occur; the anchor is `now`. -/
def stabCheckSig (phi : sig.preds) : Bool :=
  decide (∀ q : Q, lab q now = true → live (fwdNowFree lab step now) q = true →
    live (bwdNowFree lab step now) q = true → lab q phi = true)

/-- `stabCheckSig` decides the run-level condition, at every anchor. -/
theorem stabCheckSig_iff (phi : sig.preds) (t : ℤ) :
    stabCheckSig lab step now phi = true ↔
      ∀ ρ : ℤ → Q, IsRun lab step now t ρ → lab (ρ t) phi = true := sorry

end FormalSystem.Metalogic.WeakCanonical

namespace FormalSystem.Metalogic.Decidability.RaySummary

variable {F : FrameOver intOrder} [F.IsRegular] {Q : Type}

/-- Under `Presented`, `⊡φ` at the seam is a run-level condition on the presentation: every
anchored run carries `φ`'s letter at its `now` state. No `k`-type is evaluated. Conditional on
`Presented`, refuted as a completeness carrier by `presented-not-complete.lean`. -/
theorem plusStab_iff_forall_run_of_presented (M : TaskModel F.toTaskFrame)
    (τ : WorldHistory F.toTaskFrame) (t : ℤ) (φ : PlusFormula)
    (lab : Q → (clSig φ).preds → Bool) (step : Q → Q → Bool)
    (hP : Presented M τ t φ lab step) :
    PlusTruthAt M τ t (.stab φ) ↔
      ∀ ρ : ℤ → Q, IsRun lab step (clNow φ) t ρ → lab (ρ t) (clPhi φ) = true := sorry

/-- **Conditional** on `Presented`: the liveness decider agrees with `⊡φ` at the seam. -/
theorem stabCheck_iff_of_presented [Fintype Q] [DecidableEq Q] (M : TaskModel F.toTaskFrame)
    (τ : WorldHistory F.toTaskFrame) (t : ℤ) (φ : PlusFormula)
    (lab : Q → (clSig φ).preds → Bool) (step : Q → Q → Bool)
    (hP : Presented M τ t φ lab step) :
    stabCheckSig lab step (clNow φ) (clPhi φ) = true ↔ PlusTruthAt M τ t (.stab φ) := sorry

/-- **Conditional** on `Presented`: `⊡φ` at the seam is decidable. Not a decision procedure for
any model in the tree (`Presented` is unsatisfiable on model A); nothing about `PlusValidZTime`. -/
def decidableStab_of_presented [Fintype Q] [DecidableEq Q] (M : TaskModel F.toTaskFrame)
    (τ : WorldHistory F.toTaskFrame) (t : ℤ) (φ : PlusFormula)
    (lab : Q → (clSig φ).preds → Bool) (step : Q → Q → Bool)
    (hP : Presented M τ t φ lab step) :
    Decidable (PlusTruthAt M τ t (.stab φ)) :=
  decidable_of_iff _ (stabCheck_iff_of_presented M τ t φ lab step hP)

end FormalSystem.Metalogic.Decidability.RaySummary
```

The signatures above are plan-time statements (`lean-challenge-snapshot.sh --check` is advisory).
An implementation-time mismatch (e.g. an instance argument `Fintype sig.preds` turning out to be
required by `live`'s section variables) is resolved by adding the instance, never by weakening a
statement; a genuinely wrong recorded statement is escalated per `plan-compliance.md`.

## Testing & Validation

- [ ] `bash scripts/check-evidence-probes.sh` exits 0 with `presented-not-complete` PASS (Phase 1).
- [ ] Scoped guarded build of `FormalSystem.Metalogic.Decidability.RaySummary` green; zero sorries
      in `StabCheck.lean` and the Trace.lean hunk; four headline axiom profiles =
      `[propext, Classical.choice, Quot.sound]` (Phase 2).
- [ ] Whole-project guarded build, `bash scripts/check-module-invariants.sh` (C14 baseline updated,
      C9 clean), `bash .claude/scripts/verify-deploy.sh` green; test modules
      `BimodalTest.Metalogic.KTypeSummaryAxiomTest` and `BimodalTest.Metalogic.KTypeFinEvalTest`
      build with the new pins and `#guard`s (Phase 3).
- [ ] No declaration statement anywhere in the diff mentions `PlusValidZTime`; no prose under
      `FormalSystem/`, `docs/`, `Tests/`, `scripts/` cites a task number; no prose anywhere writes
      "L⁺ is decidable" unqualified or claims a bound (Phases 3-4).
- [ ] `specs/ROADMAP.md` no longer states "742 → successor (B2b) → 735" or asks to add B2b to 735's
      dependencies; `active_projects[735].dependencies` in `specs/state.json` is unchanged by this
      task; no new task is filed (Phase 4).

## Artifacts & Outputs

- `specs/evidence/seam-gluing-ray-product/presented-not-complete.lean` (wired probe, `Probe735.not_presented`)
- `FormalSystem/Metalogic/Decidability/RaySummary/StabCheck.lean` (new module)
- `FormalSystem/Metalogic/Decidability/RaySummary/Trace.lean` (`plusStab_iff_forall_run_of_presented`)
- `FormalSystem/Metalogic/Decidability/RaySummary.lean`, `FormalSystem.lean` (aggregator import; root regenerated)
- `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean`, `Tests/BimodalTest/Metalogic/KTypeFinEvalTest.lean` (pins, witnesses)
- `docs/theorem-index.md` (three Conditional rows), `scripts/check-module-invariants.sh` (C14 pairs), `scripts/check-evidence-probes.sh` (WIRED entry)
- `FormalSystem/Metalogic/Decidability/RaySummary/README.md` (`## The verdict`), `FormalSystem/Metalogic/Decidability/README.md`, `specs/ROADMAP.md`
- `specs/735_decidable_stab_check_ray_product_assembly/summaries/01_decidable-stab-check-assembly-summary.md` (implementation summary, written by the implementer)

## Rollback/Contingency

Each phase commits per green sub-step, so a failed phase is reverted by dropping its own commits
only; no earlier phase is touched. If Phase 2's gluing lemma blocks (Risk R1), mark Phase 2
`[BLOCKED]` with the exact goal state and what was tried, leave `plusStab_iff_forall_run_of_presented`
(already compiled) committed, and let Phases 1, 3 (pins for the landed lemma only) and 4 (the
verdict, which does not depend on the decider) complete -- the acceptance criterion's second
branch is met by Phases 1 and 4 alone. A genuine rollback of uncommitted work follows
`context/contracts/recovery.md`'s rollback rung (snapshot via `git-snapshot.sh 735`, then the
destructive command); an ordinary defensive checkpoint before the gluing proof uses
`bash .claude/scripts/git-snapshot.sh 735 --no-revert`. Never delete or weaken the wired probe to
make a gate pass.

## Decisions

- **D-P1 (outcome)**: the acceptance criterion's second branch; `Decidable (PlusValidZTime φ)` is
  not stated in any form. Source: research Findings 2-4; orchestrator confirmation of the probe.
- **D-P2 (positive deliverable)**: the run-level route under `Presented` (research D-2), landed
  with explicit vacuity statements; the `HitPresented` route is excluded (Non-Goals) and recorded
  here as a follow-up candidate: "`HitPresented M τ t φ lab step k := HitCl M τ t φ k = ↑(hitOf lab step (clNow φ) k)`;
  `plusStab_iff_forall_hitOf_of_presented` holds verbatim under it; satisfiability on model A is
  OPEN (the pumped limit's forward type differs from every seam trace's type); the per-triple check
  through `PathEntry.rep` and `doets_lemma_1_1` costs 250-400 lines MEDIUM". Filing is the user's
  call.
- **D-P3 (generic decider)**: `stabCheckSig` is stated over an arbitrary `MonadicSignature` with
  distinguished `now`/`phi` letters (as `plusStab_iff_forall_hitSig` is), so the `#guard`
  witnesses run on the existing `twoLetter` presentations; the closure instance is the two
  `_of_presented` theorems.
- **D-P4 (no dependency or task changes)**: B2b is not added to this task's dependencies
  (research D-4); (C), (S), (W) are named as unfiled requirements in prose, not filed and not added
  as ROADMAP checkbox bullets. Reserved for the user.
- **D-P5 (the 742 finding, scoped and costed -- for the user's ruling)**: task 742's
  `hit_eq_hitOf_of_presented` and `plusStab_iff_forall_hitOf_of_presented` are stated under
  `Presented` and are therefore vacuous on model A (and on any regular ℤ-model whose seam has an
  unboundedly deferrable eventuality). 742 is `[COMPLETED]` with text written on the weaker reading
  ("discharged for no non-trivial model"). The correction set, if the user authorizes it:
  `Trace.lean` -- the `Presented`, `hit_eq_hitOf_of_presented` and
  `plusStab_iff_forall_hitOf_of_presented` docstrings (the last says the successor "assembles
  `Decidable (PlusValidZTime φ)`", now known false); `docs/theorem-index.md` -- the
  `hit_eq_hitOf_of_presented` row's statement text; `RaySummary/README.md` -- the Trace.lean table
  row, "What it does not do" bullets 1-2, "Two carried limits" item 2; `RaySummary.lean` header
  (two sentences); `KTypeSummary/README.md` (three sentences); `Decidability/README.md` (one
  cell); `KTypeSummaryAxiomTest.lean` (the prose block before the four `Presented` pins);
  `specs/ROADMAP.md` (the 742 `[x]` bullet's "discharged for **no** non-trivial model" clause).
  Cost: ~40-60 prose lines, zero Lean statement changes, zero axiom-profile changes, ~1 hour, LOW;
  verification: C9/task-reference lint and the C14 baseline unchanged. The 742 summary is archival
  and is never edited. This plan proceeds **additive-only** (Risk R5) unless the user rules
  otherwise; the question is raised as a non-blocking `user_decision` on `.return-meta.json`.
