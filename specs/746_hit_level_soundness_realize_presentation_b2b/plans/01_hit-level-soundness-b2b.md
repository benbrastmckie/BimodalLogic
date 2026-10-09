# Implementation Plan: Task #746

- **Task**: 746 - Requirement (S) of the ray-product verdict: Hit-level soundness — realize a presentation by a constructed regular ℤ-model (B2b)
- **Status**: [IMPLEMENTING]
- **Effort**: 14 hours (8 phases; lean4 `--hard`, one agent run per phase)
- **Dependencies**: None. (C) (task 745) is independent and is NOT a dependency; (W) depends on this and on (C). 740 (complete) discharged the `[Finite sig.preds]` prerequisite.
- **Research Inputs**: specs/746_hit_level_soundness_realize_presentation_b2b/reports/01_hit-level-soundness-b2b.md
- **Artifacts**: plans/01_hit-level-soundness-b2b.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md, reference-grounding.md (lean4 override, Tier 1), anti-analysis.md (lean4 override), wrap-up.md, plan-compliance.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

`hit_eq_hitOf_of_presented` (landed, `RaySummary/Trace.lean`) says a seam's `HitCl` IS the
computable `hitOf` — under the explicit realization hypothesis `Presented`, which is discharged
for no non-trivial model in the tree. This plan discharges it for a model CONSTRUCTED from the
presentation, which is requirement (S) of task 735's ray-product verdict and HWZ 2000 Theorem 14
in the (⇐) direction for the box-dot fibre. The route: define a decidable consistency bundle
`Cons` on a finite labelled presentation whose untl/snce clauses are the unfolded truth clause
plus the negation of exactly the object `Probe735.pump_isRun` manufactures; build `modelOf P` as
`FrameOver.ofSlicedStep` on the presentation's own finite `Q` (carrier `ℤ × Q`, infinite,
regularity free); prove `Presented (modelOf P) τ t φ lab step` through the landed uniqueness lemma
`eq_clTrace_of_localRun_anchored` in both directions; and read off the Hit-level equality as its
one-line corollary. Scope is `box`/`stab`-free `φ`, which is the (S)/(W) line the verdict already
drew.

The carried 300-500 line regular-frame constructor prerequisite is NOT a phase here. The research
dispatch established, with a compiled zero-sorry probe, that it is a completeness burden and not a
soundness one: in (S) the presentation is given and liveness sits in the `Cons` hypothesis, where
the dispatch itself put it, so `ofSlicedStep` on `W := Q` suffices unchanged. Its hard part is
preserved as wired evidence (Phase 1) rather than discarded, together with two refutations found
while testing it.

Definition of done: Phases 1-8 compile sorry-free on the standard axiom profile
`[propext, Classical.choice, Quot.sound]` with every headline pinned in
`Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean`; the `Cons` non-vacuity `#guard`s pass;
the new evidence probe is green under `scripts/check-evidence-probes.sh`; the theorem index, the
`RaySummary/` README and the ROADMAP say exactly what landed and what did not. `Decidable
(PlusValidZTime φ)` is NEVER stated in any form — the honest headline is: a finite presentation
satisfying `Cons` is realized by a constructed regular ℤ-model at one seam, so the four
**Conditional** rows of `docs/theorem-index.md` (194-200 band) have a non-vacuous instance;
lifting one seam to validity is (W).

### Research Integration

From `reports/01_hit-level-soundness-b2b.md`. Every substrate declaration below was re-resolved
BY NAME during this planning pass (22 of them; the dispatch's anchor warning), with zero drift
found; no line number from the report or the dispatch is carried into this plan.

- **The frame-constructor prerequisite is off the critical path** (research Decision 2). Probe
  `01_fib-finite-generalization.lean` (compiled, zero sorries) confirms the dispatch's structural
  reading — `ofSlicedStep_fib_finite`'s `[Finite W]` is replaceable by two-sided finite branching
  (`fib_finite_of_finBranch`, `saturation_of_finBranch`), `TaskFrame.saturation_of_fib_finite`
  carries no carrier hypothesis, and the four other `ofReflectiveRegular` field discharges
  (`ofSlicedStepRel_reflect`, `ofSlicedStep_compositional`, `ofSlicedStep_serial`,
  `ofSlicedStep_limit`) carry no `[Finite W]`. It ALSO refutes the dispatch's guess at the repair
  shape: the named reset hazard is real (`Rbad_fib_infinite`) and moving the reset does not fix it
  (`Rok_fwd_infinite`) — an unbounded nondeterministic deadline is infinite-branching wherever it
  fires. Phase 1 wires that probe; no phase builds the constructor.
- **`Cons`'s untl half is already machine-checked.** Probe `02_cons-untl-core.lean` compiles
  `untl_iff_of_UCoh_ULive` generically over `sig` and `Q`, with no model and no `[Finite W]`:
  `UCoh` is `PlusTruthAt`'s `untl` clause unfolded across one step, `ULive` is the negation (via
  `Present.lean`'s existing `live`/`live_iff`) of a `step`-cycle every state of which claims the
  eventuality and lacks the event — exactly what `Probe735.pump_isRun` builds. Phase 2 is a
  transcription; Phase 3's `snce` mirror is OWED work and no symmetry claim transfers to it
  (forward-only).
- **Non-vacuity is machine-checked**: probe `03_cons-non-vacuity.lean`'s three-state presentation
  satisfies `UCoh`, `ULive`, two-sided bi-seriality and the once-only `now` condition, with a
  negative control (one label changed makes `live deferBad 0 = true`, the `Probe735` shape).
  Phase 5 lifts both.
- **No new formula induction is needed.** `eq_clTrace_of_localRun_anchored` is landed and serves
  BOTH directions of `Presented`; the splice plumbing is copyable from `Probe735.not_presented`'s
  `hsp` block (`seamOmegaEquiv` + `Equiv.symm_apply_apply`, with `spliced` the `SeamMulti.lean`
  abbrev). Research rates this Medium confidence — argued from signatures, not compiled — so
  Phase 7 is where it is paid for and is the plan's single largest risk.
- **`box`/`stab`-freeness is the scope line, and it needs a new predicate.** `Anchored`'s `box`
  and `stab` fields quantify over `h : .box ψ ∈ plusSubformulaClosure φ`; for `box`/`stab`-free
  `φ` that hypothesis is uninhabited, so `Anchored` reduces to `now` + `atom`. `PlusFormula`
  has no `BoxStabFree` predicate (`isBoxFree` in `Separation/SemanticBridge.lean` is for
  `Formula` and cannot be reused), so Phase 4 writes it beside `plusSubformulaClosure`.
- **Cost revised to 600-900 lines, MEDIUM** (research Decision 6) against the carried 1,200-2,000
  HIGH plus 300-500 prerequisite. This plan's phase budgets sum to 740-1,050 library lines plus
  documentation, and the largest single phase is bounded at 180-260.
- **Pin-drift costs to avoid** (research Tactic Survey, at Mathlib `v4.33.0-rc1` / `79d0395a`):
  `le_or_lt` is not an identifier (use `le_or_gt`); `Set.finite_insert` is an `Iff`, not a
  function (use `Set.Finite.insert`); a `/-- … -/` doc comment immediately before `#guard` is a
  parse error (use `/-! … -/`); a `HasChain` witness given as a lambda needs an explicit `show`
  to beta-reduce before `rw`.

### Prior Plan Reference

No prior plan for this task. Calibration is borrowed from the immediate predecessor
`specs/742_compute_hit_realizability_device/plans/01_compute-hit-realizability-device.md` (10
phases, 19 hours, all `[COMPLETED]`): phases of ~150-260 lines at 2 hours each held; README line
anchors drifted mid-batch, which is why every anchor here is a declaration name; and 742's Phase 8
is the precedent for a wired evidence probe as a first-class phase deliverable.

### Roadmap Alignment

`roadmap_path` was not supplied in this dispatch, so `specs/ROADMAP.md` was consulted read-only
for alignment and is not otherwise treated as an input. Phase 1 of the roadmap carries the bullet
`/orchestrate 745,746 --hard --lit` and, under it, the **(S)** paragraph beginning "the other half
of that line — ungated". This plan advances that paragraph in full and contradicts one sentence of
it on machine-checked grounds (the 300-500 line prerequisite is descoped, and "test backward
finite branching cheapest" was done and returned a refutation of the repair shape). Phase 8
rewrites that paragraph to say so and names the frame-constructor successor beside it. The
adjacent `/orchestrate 747` bullet is the consumer; nothing here attempts it.

## Goals & Non-Goals

- **Goals**: `untl_iff_of_UCoh_ULive`, `snce_iff_of_SCoh_SLive`,
  `not_box_mem_plusSubformulaClosure`, `not_stab_mem_plusSubformulaClosure`, `cons_localRun`,
  `anchored_runTrace_of_boxStabFree`, `presented_modelOf`, `hitCl_modelOf_eq_hitOf`
- Goals, stated in prose (not Challenge-pinned): the module `RaySummary/Realize.lean` with its
  header stating what is and is not realized; the decidable predicates `UCoh`, `deferGraph`,
  `ULive`, `SCoh`, `bwdDeferGraph`, `SLive` and the bundle `Cons`; `PlusFormula.BoxStabFree` with
  its subformula-inheritance lemma; `frameOf` / `modelOf` with the regularity instance and the
  valuation/step rewrite lemmas; the `Cons` non-vacuity `#guard` inhabitant and its negative
  control; a wired evidence probe holding the frame-constructor branching verdict; axiom pins for
  every Goal; theorem-index rows; `RaySummary/` README and `RaySummary.lean` aggregator updates;
  the ROADMAP (S) paragraph rewrite and the frame-constructor successor-record description.
- **Non-Goals**:
  - **Requirement (C)** (task 745, Hit-level completeness and its computable bound) and
    **requirement (W)** (task 747, the closure-wide quasimodel). Independent records; (C) is not
    a dependency of this one in either direction.
  - **`Decidable (PlusValidZTime φ)` in any form**, any quantification over models, any search
    over presentations, any per-seam `Bool` verdict beyond the landed `stabCheckSig`. (S) alone
    does not deliver validity: the verdict records that (C) and (S) together still speak of ONE
    SEAM.
  - **Any complexity bound**, upper or lower.
  - **The regular-frame constructor for "finitely many fibre shapes per time"** —
    `ofSlicedStepBranch` and the 7-8 companion restatements of `SlicedFrame.lean`'s
    `[Finite W]`-carrying declarations. Descoped on the research finding that (S) does not need
    it; `[Finite W]` occurs 11 times across 9 declarations in that module and `ofSlicedStep` is
    referenced in 17 files including two probes this task may not retire, so an in-place
    generalization is prohibited and a parallel constructor belongs to its own record. Phase 1
    wires the probe; Phase 8 writes the successor description.
  - **`box`/`stab`-bearing `φ`.** The landing statement is restricted to `BoxStabFree φ`. The
    general variant (clauses pinning `lab q (box ψ)` and `lab q (stab ψ)`) is described in
    Phase 8's README text and not built; the stab-collapse mechanism
    (`plusStateLocal_stab_iff`'s semantic half) is stated there in prose, and its ~5-line
    semantic-hypothesis variant of that lemma is NOT written.
  - **Retiring or re-proving anything landed**: `Presented`, `presented_localRun`,
    `hit_eq_hitOf_of_presented`, `hitOf`, `mem_hitOf_iff`, `IsRun`, `runTrace`, `pathTypes`,
    `live`, `live_iff`, `eq_clTrace_of_localRun_anchored`, `ofSlicedStep` and its companions,
    `seamOmegaEquiv`, `SeqPair` — all cited by name, none re-proved. Task 735's verdict stands;
    both wired probes (`presented-not-complete`, `quasistate-does-not-determine-hit`) stay.
  - **A backward Bool-fixture bridge.** None exists; the `snce` mirror of Phase 3 is proved
    outright and is never obtained as a symmetry of the `untl` half, and every module header says
    the fixtures are forward-only.
  - **Any cslib `require` edge or copied declaration.** `~/Projects/cslib/` is read-only and may
    be consulted for strategy only; a `require` would drag this tree 76 Mathlib commits forward.
  - **Any reintroduction of a finite-fibre or finite-width assumption** on the constructed model.
    `[Finite Q]` is finiteness of the PRESENTATION's state set, not of the model's world states
    (`ofSlicedStep_not_finite_worldState` is cited in Phase 6's verification for exactly this
    reason) and not of any fibre.
  - The three research Context Extension Recommendations (the Mathlib pin-drift table, the
    `#guard` doc-comment note, the carried-prerequisite pattern note) — they belong to the
    agent-system source store, not this repository, and are recorded in the summary as
    recommendations only.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Phase 7's reduction of `Presented` to `eq_clTrace_of_localRun_anchored` is argued from signatures, never compiled (research marks it Medium confidence) — a hidden obligation in either direction would land in the plan's largest phase | H | M | Phase 7 is ordered last among the proof phases and both its directions are written out task-by-task below, each naming the landed lemma it routes through. The (⇐) half's splice plumbing is copied verbatim from `Probe735.not_presented`'s `hsp` block, which compiles today. If a direction resists, land the (⇐) half green and commit it before attempting (⇒) — the sub-step commit mandate makes that cheap — and if the (⇒) half is genuinely obstructed, Phase 7 closes `[BLOCKED]` with the goal state, and Phase 8 degrades to the per-sub-obstruction machine-checked verdict the acceptance criterion admits as a COMPLETE result |
| The `snce` mirror (Phase 3) is owed work with no symmetry available; the backward deferral graph and backward walk may need a different induction than `persist` | H | M | Probe 02's forward proof is the template for the shape but not for the content: Phase 3 states `SCoh`/`SLive` first and proves `persist`'s mirror by the SAME induction on the gap `(z - r).toNat` before touching `snce_iff_of_SCoh_SLive`. The research's own tactic survey already records the `ℤ`/`ℕ` cast route (`push_cast; omega`). If the backward walk resists, land `SCoh`'s direction that mirrors `u_of_disch` first (it needs no liveness) and commit |
| `Cons` as a bundle over every `untl`/`snce` pair in `plusSubformulaClosure φ` needs the membership projections at each instance; a `structure` whose fields quantify over closure-membership proofs is awkward to inhabit, which is what makes the Phase 5 `#guard` inhabitant load-bearing | M | M | `Cons`'s fields mirror `LocalRun`'s shape exactly (quantify over `ψ χ` and `h : .untl ψ χ ∈ plusSubformulaClosure φ`, project with `plusClosure_untl_left`/`_right`), so `cons_localRun` is field-by-field with no re-derivation. Phase 5's `#guard` block is dispatched in the same phase as `cons_localRun` precisely so an un-inhabitable bundle is caught immediately rather than at Phase 7 |
| `modelOf`'s `box` anchor is time-invariant and its `stab` letters collapse, so a `box`/`stab`-bearing `φ` would be realized only degenerately; research flags the resolving check (every world state of `ofSlicedStep` lies on a history) as Low confidence with no such lemma in the tree | M | H | Already mitigated by scope: `BoxStabFree φ` makes both `Anchored` fields vacuous, and Phase 4 proves that vacuity (`not_box_mem_plusSubformulaClosure`) rather than assuming it. No phase relies on the Low-confidence claim. Phase 8's README text states the limitation and assigns it to (W) |
| Shared-file contention with task 745 on `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean` (the known reason the two are batched) and with task 733 on `scripts/check-evidence-probes.sh` | M | M | `file_scope` is declared by this plan (see Artifacts & Outputs), closing the admission blindness the record was filed with. The two contended files are touched in exactly two phases: the gate script in Phase 1 only, the axiom test in Phase 8 only, both append-only. Per the dispatch's territory note, re-read each immediately before editing and stage only this task's own hunks — never a directory or glob `git add` |
| A same-named weaker statement lands under a true-looking name (the defect class task 737 was filed to find) | H | L | `## Lean Challenge Statements` pins every Goal's signature before implementation; `plan-compliance.md`'s Statement Fidelity section governs. `presented_modelOf` carries `Cons` and `BoxStabFree` as explicit named hypotheses in its statement, and `hitCl_modelOf_eq_hitOf` carries `1 ≤ k` |
| `#guard`/`decide` on `live` and on the `Cons` conditions is exponential in the alphabet; a witness over a full closure signature may not finish | M | M | The witness runs at the probe-03 size only: three states, a two-letter-plus-marker closure, depth 1. Research confirmed `live` over `Fin 3` evaluates. No complexity claim is made anywhere, and the `#guard`s are witnesses rather than a benchmark |
| The new module's import of `SlicedFrame.lean` pulls `Semantics` into `Decidability`, risking an import cycle | L | L | `RaySummary/Trace.lean` already imports the `PlusLanguage`/`Semantics` layer transitively (it mentions `FrameOver intOrder`, `SeqPair`, `spliced`); Phase 2 checks the scoped build of `Realize.lean` before any later phase depends on it, so a cycle surfaces in the cheapest phase |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2, 4 | -- |
| 2 | 3 | 2 |
| 3 | 5 | 3 |
| 4 | 6 | 5 |
| 5 | 7 | 4, 6 |
| 6 | 8 | 1, 7 |

Phases within the same wave can execute in parallel, and Wave 1's territory is disjoint by
construction: Phase 1 owns the new evidence probe plus `scripts/check-evidence-probes.sh`,
Phase 2 owns `RaySummary/Realize.lean`, Phase 4 owns `PlusLanguage/Subformulas.lean`. Phases
2-3 and 5-7 all write `Realize.lean` and are strictly serialized by the wave table for that
reason.

Every build is the guarded, detached form
`bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build <Module>` (never a bare
`lake`, never foreground). Every phase ends with its scoped build green, `#print axioms` on each
new theorem showing exactly `[propext, Classical.choice, Quot.sound]`, and `grep -c sorry` = 0 on
every touched module.

---

### Phase 1: Wire the frame-constructor branching verdict as permanent evidence [COMPLETED]

**Goal**: Preserve the research dispatch's machine-checked frame-constructor findings as a wired
probe under `specs/evidence/seam-gluing-ray-product/`, so the descoping of the carried
prerequisite rests on a green, rotting-protected artifact rather than on a report paragraph.

**Tasks**:
- [x] Copy `specs/746_hit_level_soundness_realize_presentation_b2b/evidence/01_fib-finite-generalization.lean`
      to `specs/evidence/seam-gluing-ray-product/b2b-frame-constructor-branching.lean`, keeping
      every declaration (`FwdFinBranch`, `BwdFinBranch`, `iterS_fwd_finite`, `iterS_bwd_finite`,
      `fib_finite_of_finBranch`, `saturation_of_finBranch`, `Rbad_fwd`, `Rbad_bwd_infinite`,
      `Rbad_fib_infinite`, `Rok_bwd`, `Rok_fwd_infinite`, `shift_saturation`,
      `shift_slice_infinite`) and the `#print axioms` lines.
- [x] Rewrite the file header to the house probe form, stating: what is established POSITIVELY
      (`ofSlicedStep_fib_finite`'s `[Finite W]` is replaceable by two-sided finite branching, and
      `Fib` at negative durations is the preimage so both senses are needed); what is REFUTED
      (the reset-to-`0`-from-any-level hazard is real, AND moving the reset to fire only from
      level `0` merely swaps the failing side, so no reset placement rescues a nondeterministic
      deadline); that the generalization is non-vacuous on a genuinely infinite slice
      (`shift_saturation`); and — explicitly — that NONE of this is a dependency of requirement
      (S), which is why the constructor itself is a successor record and not built here.
- [x] Register `"seam-gluing-ray-product/b2b-frame-constructor-branching"` in
      `scripts/check-evidence-probes.sh`'s probe list, append-only at the end of the array, and
      add the matching header-comment block in that script's catalogue in the same house format
      as the `presented-not-complete` entry (verdict label, what it shows, what it does not).
- [x] Run `bash scripts/check-evidence-probes.sh` and confirm the new probe is green along with
      every pre-existing one *(deviation: altered — the registered-probe count was 24 before and
      25 after, not the plan's 14/15; the plan's figure was stale against the actual arrays of 21
      `WIRED` plus 3 `WIRED_REPO` entries. Append-only editing was confirmed from the diff
      instead: 57 insertions, 0 deletions)*.

**Timing**: 1 hour

**Depends on**: none

**Verification Tier**: local

**Tier Justification**: The edit touches one new probe file plus an append-only registry entry,
and `scripts/check-evidence-probes.sh` compiles every registered probe and exits non-zero on any
failure — that one command is the complete covering check for this phase's blast radius; nothing
under `FormalSystem/` is touched, so no library build can regress.

**Scope Hypothesis**: ~175-200 lines in the new probe (the source is 173 lines; the header
rewrite adds 10-25) and ~12-18 lines of registry plus catalogue in the gate script, with 14
pre-existing registered probes becoming 15. Confirm by `wc -l` on the new probe and by the gate
script's own count line at phase end; a registered-probe count other than 15 means the array was
edited non-append-only.

**Scope Hypothesis outcome (measured)**: NOT confirmed, on both counts, in the direction of more
lines rather than fewer. The new probe is **283 lines** (173 carried verbatim, a 91-line house
header, a 27-line `#print axioms` foot covering all 18 declarations — the source carried no axiom
foot to keep, contrary to the task text above), against the predicted 175-200. The gate-script
edit is **57 lines** (56-line catalogue block plus the one `WIRED` entry) against the predicted
12-18: the catalogue's comment column is 38 characters wide, so an entry stating verdict label,
what it shows and what it does not necessarily runs long — the two neighbouring entries
(`presented-not-complete`, `hit-presented-model-a`) are ~55 and ~60 lines, so 57 is in-house-norm
and the estimate, not the edit, was wrong. Append-only was verified structurally (57 insertions,
0 deletions) rather than by the predicted count, which was itself stale.

**Files to modify**:
- `specs/evidence/seam-gluing-ray-product/b2b-frame-constructor-branching.lean` - new probe
- `scripts/check-evidence-probes.sh` - append the registry entry and the catalogue comment block

**Verification**:
- `bash scripts/check-evidence-probes.sh` exits 0 and reports the new probe green.
- `#print axioms fib_finite_of_finBranch` and `#print axioms saturation_of_finBranch` show
  exactly `[propext, Classical.choice, Quot.sound]`.
- `grep -c sorry` = 0 in the new probe.
- The probe header contains the words "not a dependency of requirement (S)" (or equivalent
  explicit statement) — the descoping claim must be legible inside the artifact itself.

---

### Phase 2: `Realize.lean` and the `untl` half of the consistency conditions [COMPLETED]

**Goal**: Create the new module and land, as a transcription of the compiled research probe, the
decidable forward conditions `UCoh`/`deferGraph`/`ULive` and the theorem that they force
`LocalRun`'s `untl` clause on every run of a finite presentation — generically over `sig` and
`Q`, with no model and no `[Finite W]`.

**Tasks**:
- [x] Create `FormalSystem/Metalogic/Decidability/RaySummary/Realize.lean` (namespace
      `FormalSystem.Metalogic.Decidability.RaySummary`, importing
      `FormalSystem.Metalogic.Decidability.RaySummary.Trace`,
      `FormalSystem.Metalogic.Decidability.RaySummary.HitOf` and
      `FormalSystem.Semantics.SlicedFrame`). Header states: this is HWZ 2000 Theorem 14 in the
      (⇐) direction for the box-dot fibre, requirement (S) of the README's verdict; what is
      realized (one seam, `box`/`stab`-free `φ`, under `[F.IsRegular]` over the ℤ time axis);
      what is NOT (no validity statement in any form, no complexity bound, no `box`/`stab`
      realization beyond the degenerate one, no finite-fibre or finite-width assumption — the
      only finiteness is `[Fintype Q]` on the PRESENTATION); that `Cons` is derived from
      `Probe735.not_presented`'s pumping proof and not from HWZ Def 10's bare type set, which
      `quasistate_does_not_determine_hit` refutes for this semantics; and that the fixtures are
      forward-only.
- [x] Transcribe from `evidence/02_cons-untl-core.lean`: `UCoh lab step u g e : Prop` (the
      per-edge unfolded `untl` clause), `deferGraph lab step u e : Q → Q → Bool`,
      `ULive lab step u e : Prop` (`∀ q, live (deferGraph lab step u e) q = false`), and the
      decidability instances for `UCoh` and `ULive` over `[Fintype Q] [DecidableEq Q]`.
- [x] Transcribe the three supporting lemmas with their probe proofs: `persist` (under `UCoh`, an
      undischarged claim at `z` forces `u`, `g` and `¬e` at every `z+1+m` for `m ≤ n`),
      `disch_of_UCoh_ULive` (the hard (⇒) direction, routed through `live_iff`'s `HasChain`
      characterization), and `u_of_disch` (the (⇐) direction, walking coherence back from the
      witness). Where the probe supplies a `HasChain` witness as a lambda, keep the explicit
      `show` that beta-reduces before `rw` (research tactic survey).
- [x] State and prove `untl_iff_of_UCoh_ULive` as the combination, with the signature pinned in
      `## Lean Challenge Statements` below. Docstring cites `Probe735.pump_isRun` by name as the
      object `ULive` forbids.
- [x] Scoped build of `FormalSystem.Metalogic.Decidability.RaySummary.Realize`; `#print axioms
      untl_iff_of_UCoh_ULive`; `grep -c sorry` = 0. Do NOT add the aggregator import yet — that
      is Phase 8, so a mid-plan full build never pulls an incomplete module.

**Timing**: 2 hours

**Depends on**: none

**Verification Tier**: local

**Tier Justification**: This phase creates one new module that nothing imports yet (the
aggregator edge is deliberately deferred to Phase 8), so the scoped build of
`RaySummary.Realize` is the complete covering check — no existing module's build can change.

**Scope Hypothesis**: ~170-210 lines (the probe is 150 lines; the module header and the
decidability instances add 20-60). Confirm by `wc -l` at phase end; past 300 lines means the
probe is being re-proved rather than transcribed, which `plan-compliance.md` forbids.
*(outcome: 249 lines — above the 170-210 estimate, under the 300 red line. Every proof body is
the probe's verbatim; the excess is the module header the phase's own first task specifies (~60
lines of scope and negative-claim prose) plus two commented, declaration/section-scoped linter
suppressions following `Compose.lean`'s precedent. No proof was re-derived.)*

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/RaySummary/Realize.lean` - new module (the `untl` half)

**Verification**:
- `lake-build-guard.sh build … -- build FormalSystem.Metalogic.Decidability.RaySummary.Realize`
  green.
- `#print axioms untl_iff_of_UCoh_ULive` = exactly `[propext, Classical.choice, Quot.sound]`.
- `grep -c sorry FormalSystem/Metalogic/Decidability/RaySummary/Realize.lean` = 0.
- `UCoh` and `ULive` are `Prop`-valued with `Decidable` instances derivable — confirm by a scratch
  `#eval decide (ULive …)` on the probe-03 fixture in `lean_run_code`, not a permanent witness
  (that is Phase 5).
- No `[Finite W]`, no `FrameOver`, no `TaskModel` appears in any of this phase's declarations:
  `grep -n 'Finite W\|FrameOver\|TaskModel'` over the phase's own additions returns nothing.

---

### Phase 3: The `snce` mirror — owed work, proved outright [NOT STARTED]

**Goal**: Land the backward conditions `SCoh`/`bwdDeferGraph`/`SLive` and
`snce_iff_of_SCoh_SLive`, forcing `LocalRun`'s `snce` clause on every run. This is proved from
scratch: no symmetry with Phase 2 is available or claimed, because no backward Bool-fixture bridge
exists in this tree.

**Tasks**:
- [ ] Define `SCoh lab step u g e : Prop` — the per-edge unfolded `snce` clause, oriented
      backward: `∀ q q', step q q' = true → (lab q' u = true ↔ (lab q e = true ∨ (lab q g = true
      ∧ lab q u = true)))`. Docstring states explicitly that this is NOT `UCoh` with the
      arguments swapped and that the orientation was derived from `LocalRun.snce`'s own clause
      (`∃ s, s < z ∧ … ∧ ∀ r, s < r → r < z → …`), not from the forward case.
- [ ] Define `bwdDeferGraph lab step u e (x y : Q) : Bool := lab y u && !(lab y e) && step x y`
      (the deferral edge read backward) and `SLive lab step u e : Prop` as
      `∀ q, live (bwdDeferGraph lab step u e) q = false`, with its decidability instance. Record
      in the docstring which argument order of `live` is being used and why.
- [ ] Prove the backward persistence lemma `persistBwd` by induction on the gap, mirroring
      `persist`'s SHAPE but with its own content: under `SCoh`, an undischarged claim at `z`
      forces `u`, `g` and `¬e` at every `z-1-m` for `m ≤ n`. Research's cast route applies
      (`push_cast; omega`, and `omega` directly for `(z - r - 1).toNat` bounds).
- [ ] Prove `disch_of_SCoh_SLive` (the hard direction, via `live_iff` on `bwdDeferGraph`) and
      `u_of_dischBwd` (the easy direction, needs no liveness), then combine into
      `snce_iff_of_SCoh_SLive` with the signature pinned below.
- [ ] Scoped build; `#print axioms snce_iff_of_SCoh_SLive`; `grep -c sorry` = 0.

**Timing**: 2 hours

**Depends on**: 2

**Verification Tier**: local

**Tier Justification**: The phase appends to the single module `RaySummary.Realize`, which no
other module imports until Phase 8, so the scoped build of that one module plus the axiom pin
covers the whole edit.

**Scope Hypothesis**: ~140-180 lines, roughly Phase 2's length since the proof is independent
rather than derived. Confirm by `wc -l` delta at phase end; markedly SHORTER than Phase 2 is a
signal that a symmetry shortcut was taken, which the forward-only constraint forbids — in that
case stop and re-check the proof actually discharges `LocalRun.snce`'s own clause.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/RaySummary/Realize.lean` - append the backward half

**Verification**:
- Scoped build of `FormalSystem.Metalogic.Decidability.RaySummary.Realize` green.
- `#print axioms snce_iff_of_SCoh_SLive` = exactly `[propext, Classical.choice, Quot.sound]`.
- `grep -c sorry` = 0 on the module.
- `snce_iff_of_SCoh_SLive`'s statement mentions `s < z` ordering, matching `LocalRun.snce` — read
  the two side by side and confirm the interval is the open `(s, z)`, not `[s, z)`.
- No declaration in this phase is defined as an application of a Phase 2 declaration: `grep -n
  'UCoh\|deferGraph\|ULive'` inside the Phase 3 block returns only docstring mentions.

---

### Phase 4: `PlusFormula.BoxStabFree` and the `Anchored` vacuity it buys [NOT STARTED]

**Goal**: Land the syntactic predicate that fixes this task's scope, its subformula-closure
inheritance, and the two lemmas saying a `box`/`stab`-free `φ` has no `box` or `stab` letter in
its closure — which is what collapses `Anchored` to `now` + `atom` in Phase 7.

**Tasks**:
- [ ] In `FormalSystem/PlusLanguage/Subformulas.lean`, beside `plusSubformulaClosure` and its
      `plusClosure_*` projections, define `PlusFormula.BoxStabFree : PlusFormula → Prop` (or
      `Bool` with a `decide` bridge, matching the surrounding file's style) by recursion over the
      seven arms of `PlusFormula`, `False` on `.box` and `.stab`. Docstring notes that
      `isBoxFree` in `Metalogic/Expressiveness/Separation/SemanticBridge.lean` is the `Formula`
      analogue and is NOT reusable here (different type), so this is a parallel definition rather
      than a generalization.
- [ ] Prove `boxStabFree_of_mem_subformulas : ψ ∈ PlusFormula.subformulas φ → φ.BoxStabFree →
      ψ.BoxStabFree` by induction on `φ`, routed through the existing `subformulas_trans` /
      per-arm membership lemmas rather than re-deriving them.
- [ ] Prove the two vacuity lemmas, both pinned below:
      `not_box_mem_plusSubformulaClosure : φ.BoxStabFree → ∀ ψ, PlusFormula.box ψ ∉
      plusSubformulaClosure φ` and `not_stab_mem_plusSubformulaClosure` likewise for `.stab`.
      Both unfold `plusSubformulaClosure` to `List.mem_toFinset` and apply the inheritance lemma.
- [ ] Scoped build of `FormalSystem.PlusLanguage.Subformulas`; axiom pins on both vacuity
      lemmas; `grep -c sorry` = 0.

**Timing**: 1 hour

**Depends on**: none

**Verification Tier**: interface

**Tier Justification**: `Subformulas.lean` is a core `PlusLanguage` module with many downstream
consumers, so a scoped build of it alone would not show whether a new definition in its namespace
shadows or clashes with anything downstream; the covering check is a build of the modules that
import it, which `interface` is exactly the tier for.

**Scope Hypothesis**: ~60-95 lines added to one existing module (research estimated ~35 for the
predicate plus inheritance; the two vacuity lemmas add 25-60), and ZERO existing declarations in
that file modified. Confirm by `git diff --stat` on the file at phase end showing insertions only;
any deletion means an existing declaration was touched, which is out of scope.

**Files to modify**:
- `FormalSystem/PlusLanguage/Subformulas.lean` - append `BoxStabFree`, its inheritance lemma, and
  the two closure-vacuity lemmas

**Verification**:
- `lake-build-guard.sh build … -- build FormalSystem.PlusLanguage.Subformulas` green, then the
  same guarded form for `FormalSystem.PlusLanguage` and
  `FormalSystem.Metalogic.Decidability.RaySummary` (the nearest importing aggregators) to confirm
  no downstream breakage from the new namespace entries.
- `#print axioms not_box_mem_plusSubformulaClosure` and
  `#print axioms not_stab_mem_plusSubformulaClosure` = exactly
  `[propext, Classical.choice, Quot.sound]`.
- `grep -c sorry FormalSystem/PlusLanguage/Subformulas.lean` = 0.
- `BoxStabFree` is not a vacuous definition: `#eval decide ((PlusFormula.box (.atom 0)).BoxStabFree)`
  is `false` and `#eval decide ((PlusFormula.untl (.atom 0) (.atom 1)).BoxStabFree)` is `true` in
  a scratch `lean_run_code` (the `lean4.md` prohibition on `def X := True` is checked here, not
  assumed).

---

### Phase 5: `Cons`, `cons_localRun`, and the machine-checked inhabitant [NOT STARTED]

**Goal**: Assemble the six-clause consistency bundle on a finite labelled presentation, prove it
forces every `LocalRun` field on every `step`-path, and land the non-vacuity witness with its
negative control — so the bundle is a real constraint that is satisfied, not an empty one.

**Tasks**:
- [ ] In `Realize.lean`, define `structure Cons (φ : PlusFormula) (lab : Q → (clSig φ).preds →
      Bool) (step : Q → Q → Bool) : Prop` with the six clauses the research assembled, each field
      shaped to mirror `LocalRun`'s corresponding field so `cons_localRun` is field-by-field:
      (1) `nonempty`/bi-seriality — `∀ q, ∃ q', step q q' = true` and `∀ q, ∃ q', step q' q =
      true`; (2) propositional coherence per state — `lab q (clLetter φ h_bot) = false` and
      `lab q (imp ψ χ) = (!lab q ψ || lab q χ)` quantified over the closure-membership proofs via
      `plusClosure_imp_left`/`_right`; (3) `UCoh` + `ULive` at every `.untl ψ χ ∈
      plusSubformulaClosure φ`; (4) `SCoh` + `SLive` at every `.snce ψ χ`; (5) once-only `now` —
      no `step`-path of positive length from a `clNow`-labelled state returns to one;
      (6) `BoxStabFree φ`.
- [ ] Prove `cons_localRun (hC : Cons φ lab step) (ρ : ℤ → Q) (hstep : ∀ z, step (ρ z) (ρ (z+1))
      = true) : LocalRun φ (runTrace lab ρ)`, signature pinned below: `bot` and `imp` from clause
      2 directly, `untl` from `untl_iff_of_UCoh_ULive` at clause 3, `snce` from
      `snce_iff_of_SCoh_SLive` at clause 4. No new induction.
- [ ] Lift `evidence/03_cons-non-vacuity.lean` into
      `Tests/BimodalTest/Metalogic/KTypeFinEvalTest.lean`, append-only: the three-state
      presentation (`0→0`, `0→1`, `1→2`, `2→2`; event at `0` and `2`, absent at the `now`-state
      `1`), the `#guard`s for `UCoh`, `ULive`, both bi-serialities and the once-only `now`
      condition checked to the carrier's full depth, and the negative control (one label changed
      makes `live deferBad 0 = true`, the `Probe735` shape). Use `/-! … -/` for every comment
      immediately preceding a `#guard` — a `/-- … -/` there is a parse error.
- [ ] Scoped builds of `RaySummary.Realize` and of the test module; axiom pin on
      `cons_localRun`; `grep -c sorry` = 0 on both.

**Timing**: 2 hours

**Depends on**: 3

**Verification Tier**: local

**Tier Justification**: The edit is confined to `Realize.lean` (which nothing imports until
Phase 8) and an append-only block in one test module, and the test module's own build evaluates
every `#guard` — those two scoped builds together are the complete covering check.

**Scope Hypothesis**: ~130-180 lines in `Realize.lean` for `Cons` plus `cons_localRun`, and
~70-100 lines appended to the test module (the source probe is 68 lines). Confirm by `wc -l`
delta on each at phase end. If `cons_localRun` alone exceeds ~80 lines, a field is being
re-derived instead of cited from Phase 2/3 — stop and route it through the pinned theorem.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/RaySummary/Realize.lean` - `Cons` and `cons_localRun`
- `Tests/BimodalTest/Metalogic/KTypeFinEvalTest.lean` - the `Cons` inhabitant and its negative
  control, append-only

**Verification**:
- Scoped builds of `FormalSystem.Metalogic.Decidability.RaySummary.Realize` and
  `BimodalTest.Metalogic.KTypeFinEvalTest` both green, every `#guard` passing.
- `#print axioms cons_localRun` = exactly `[propext, Classical.choice, Quot.sound]`.
- `grep -c sorry` = 0 on both files.
- The negative control is present and genuinely negative: the test module contains a `#guard`
  asserting `live deferBad 0 = true` (i.e. `ULive` FAILS on the altered fixture), so the
  conditions are shown to exclude something.
- `Cons` is not vacuous: `git diff` shows no `:= True`, `:= Unit`, or `:= trivial` body anywhere
  (the `lean4.md` prohibition).

---

### Phase 6: `frameOf`, `modelOf`, and the constructed model's rewrite lemmas [NOT STARTED]

**Goal**: Build the regular ℤ-model from the presentation — `ofSlicedStep` on `W := Q` with the
time-constant step relation — and land the rewrite lemmas Phase 7 consumes, with the carrier's
infiniteness cited rather than asserted.

**Tasks**:
- [ ] Define `frameOf (step) (hC : Cons φ lab step) : FrameOver intOrder :=
      FrameOver.ofSlicedStep (fun _ q q' => step q q' = true) fwd bwd`, taking `[Fintype Q]`
      (hence `[Finite Q]`) and `[Nonempty Q]` from the presentation and `fwd`/`bwd` from `Cons`
      clause 1 (the relation is time-constant, so the `t - 1` index in `ofSlicedStep`'s `bwd`
      argument is immaterial — state that in the docstring, since it is the one place the
      constructor's signature could mislead).
- [ ] Register the regularity instance by citing `ofSlicedStep_isRegular` (no new proof), and
      state `frameOf_not_finite_worldState` by citing `ofSlicedStep_not_finite_worldState` — the
      explicit record that no finite-width or finite-fibre assumption has been reintroduced.
- [ ] Define `modelOf (φ) (lab) (step) (hC) : TaskModel (frameOf step hC).toTaskFrame` with
      valuation `fun w p => lab w.2 (clLetter φ h) = true` at closure atoms (and whatever the
      `TaskModel` structure requires off the closure), and prove the two rewrite lemmas:
      `modelOf_valuation` (the valuation at `(z, q)` reads `lab q`) and `frameOf_step` (a
      restatement of `ofSlicedStep_step` at this frame: `(frameOf …).step p q ↔ q.1 = p.1 + 1 ∧
      step p.2 q.2 = true`).
- [ ] State `frameOf_mem_HF_iff` as the specialization of `ofSlicedStep_mem_HF_iff` at this
      relation — the history-space characterization Phase 7's (⇒) direction reads `ρ` off, and
      whose `←` direction builds the history for (⇐).
- [ ] Scoped build; axiom pins on the rewrite lemmas; `grep -c sorry` = 0.

**Timing**: 1.5 hours

**Depends on**: 5

**Verification Tier**: local

**Tier Justification**: Everything lands in `Realize.lean`, which still has no importer, and the
phase adds no declaration to any shared namespace; the scoped build of that module plus the axiom
pins covers the edit, and the five `ofReflectiveRegular` field discharges are cited from
`SlicedFrame.lean` rather than re-proved, so no other module's build can change.

**Scope Hypothesis**: ~90-130 lines, most of it citation of `ofSlicedStep`'s landed companions
rather than new proof. Confirm by `wc -l` delta at phase end. A figure past 200 lines means a
field discharge is being re-proved instead of cited — `ofSlicedStep` and its five discharges are
usable as-is for `W := Q` and must not be rebuilt.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/RaySummary/Realize.lean` - the frame, the model, and the
  rewrite lemmas

**Verification**:
- Scoped build of `FormalSystem.Metalogic.Decidability.RaySummary.Realize` green.
- `#print axioms modelOf_valuation`, `#print axioms frameOf_step` = exactly
  `[propext, Classical.choice, Quot.sound]`.
- `grep -c sorry` = 0.
- The regularity instance resolves: a scratch `example : (frameOf step hC).IsRegular :=
  inferInstance` type-checks.
- `frameOf_not_finite_worldState` is present and cites
  `ofSlicedStep_not_finite_worldState` — the constructed model's world-state type is NOT finite,
  and that is stated in the module rather than left to the reader.
- `grep -n 'Finite.*WorldState\|FiniteWidth'` over the phase's additions finds only the negative
  statement, never a hypothesis.

---

### Phase 7: `presented_modelOf` — the realization theorem [NOT STARTED]

**Goal**: Discharge `Presented (modelOf …) τ t φ lab step` for the constructed model at a seam.
Both directions route through the landed uniqueness lemma `eq_clTrace_of_localRun_anchored`; this
is the plan's largest phase and its one genuinely unproved reduction.

**Tasks**:
- [ ] State `anchored_runTrace_of_boxStabFree` (pinned below): for `BoxStabFree φ`, a history `σ`
      of `frameOf` whose path is `fun z => (z, ρ z)`, and a run `ρ` with `IsRun lab step (clNow
      φ) t ρ`, the colouring `runTrace lab ρ` is `Anchored (modelOf …) φ t · σ`. Prove it by
      four fields: `now` from `IsRun`'s second conjunct; `atom` from `modelOf_valuation`; `box`
      and `stab` VACUOUSLY, by `not_box_mem_plusSubformulaClosure` /
      `not_stab_mem_plusSubformulaClosure` on the field's own membership hypothesis.
- [ ] Prove the (⇐) direction of `Presented`: given `ρ` with `IsRun`, build the history `σ` from
      the step path `z ↦ (z, ρ z)` via `frameOf_mem_HF_iff`'s `←` direction at offset `0` (or
      `FrameOver.worldHistoryOfStepPath` with `IsStepPath` from `frameOf_step`); get `LocalRun φ
      (runTrace lab ρ)` from `cons_localRun` and `Anchored` from the previous task; conclude
      `runTrace lab ρ = clTrace (modelOf …) φ t σ` by `eq_clTrace_of_localRun_anchored`; then
      exhibit `σ` as a splice by copying `Probe735.not_presented`'s `hsp` block verbatim — a
      `Presheaf.StabFibre` element `⟨σ, hσt⟩`, `seamOmegaEquiv t (τ.state t)` applied to it, and
      `Equiv.symm_apply_apply` under an explicit `show` (`spliced` is the `SeamMulti.lean`
      abbrev).
- [ ] Prove the (⇒) direction: given a splice `σ = spliced τ t bf`, set `ρ z := (σ.path z).2`;
      derive `IsRun lab step (clNow φ) t ρ` — the step conjunct from `frameOf_mem_HF_iff`'s `→`
      direction (which pins the time component to `z + k`, hence `k = 0` at the seam) plus
      `frameOf_step`, and the `now` conjunct from `Cons` clause 5 together with the seam anchor
      `hτ : τ.state t = (t, q₀)`, `hq₀ : lab q₀ (clNow φ) = true`; then apply the SAME two
      obligations (`cons_localRun`, `anchored_runTrace_of_boxStabFree`) and the SAME uniqueness
      lemma to get `clTrace (modelOf …) φ t σ = runTrace lab ρ`.
- [ ] Assemble `presented_modelOf` with the signature pinned below, and commit the two directions
      separately as they go green (the sub-step commit mandate; a green (⇐) half must not wait on
      (⇒)).
- [ ] Scoped build; `#print axioms` on both new theorems; `grep -c sorry` = 0.

**Timing**: 2.5 hours

**Depends on**: 4, 6

**Verification Tier**: local

**Tier Justification**: The phase appends two theorems to `Realize.lean`, still importerless, and
cites `eq_clTrace_of_localRun_anchored`, `seamOmegaEquiv` and `frameOf_mem_HF_iff` without
restating them; the scoped build of that module is the complete covering check for the edit, and
the plan's cross-cutting sweep is Phase 8's job.

**Scope Hypothesis**: ~180-260 lines (research's own estimate for this target), the largest phase
in the plan. Confirm by `wc -l` delta at phase end. If it exceeds ~320 lines, a hidden obligation
in the reduction has materialized — record it in the issue log as a `scope` issue and consider
closing the phase on the green direction with the other `[BLOCKED]`, rather than growing the
phase past one agent run.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/RaySummary/Realize.lean` - the anchoring lemma and
  `presented_modelOf`

**Verification**:
- Scoped build of `FormalSystem.Metalogic.Decidability.RaySummary.Realize` green.
- `#print axioms presented_modelOf` and `#print axioms anchored_runTrace_of_boxStabFree` = exactly
  `[propext, Classical.choice, Quot.sound]`.
- `grep -c sorry` = 0.
- `presented_modelOf`'s statement carries `Cons φ lab step` and `φ.BoxStabFree` as explicit named
  hypotheses, and its conclusion is literally `Presented (modelOf …) τ t φ lab step` with
  `Presented` the landed `Trace.lean` definition — read the two signatures side by side and
  confirm no hypothesis was added to and no quantifier specialized in `Presented` itself
  (`plan-compliance.md` Statement Fidelity).
- The uniqueness lemma is cited, not re-proved: `grep -c eq_clTrace_of_localRun_anchored` ≥ 2 in
  the phase's additions, and no new induction on `PlusFormula` appears.

---

### Phase 8: The acceptance statement, pins, index, READMEs, and the ROADMAP [NOT STARTED]

**Goal**: Read off the Hit-level equality as the one-line corollary, wire the module into the
aggregator, and make every record say exactly what landed and what did not — including the
`box`/`stab` limitation, the descoped frame-constructor successor, and the standing silence on
validity.

**Tasks**:
- [ ] Prove `hitCl_modelOf_eq_hitOf` (pinned below): `(hk : 1 ≤ k) → HitCl (modelOf …) τ t φ k =
      ↑(hitOf lab (fun q q' => step q q' = true) (clNow φ) k)`, as
      `hit_eq_hitOf_of_presented … (presented_modelOf …)`. One line of proof; the work was
      Phase 7's.
- [ ] Add `import FormalSystem.Metalogic.Decidability.RaySummary.Realize` to
      `FormalSystem/Metalogic/Decidability/RaySummary.lean` and a `* RaySummary.Realize — …`
      bullet to its `## Modules` list. Update that aggregator's header paragraph, which currently
      says `Presented` "is discharged for no non-trivial model here: constructing a regular model
      from a presentation is a successor record" — it now has a non-vacuous instance for
      `box`/`stab`-free `φ` at one seam, and the sentence must be rewritten to say precisely
      that, without overclaiming.
- [ ] Update `FormalSystem/Metalogic/Decidability/RaySummary/README.md`'s verdict section:
      requirement (S) is discharged for `box`/`stab`-free `φ` at one seam; (C) and (W) are
      untouched; the `box`-global / `stab`-collapse limitation is stated with its mechanism
      (`plusStateLocal_stab_iff`'s semantic half) and assigned to (W); the descoped
      frame-constructor successor is described with its measured content (probe 01's
      `fib_finite_of_finBranch` plus the two refutations) and its ~120-160 line cost as a
      PARALLEL constructor beside `ofSlicedStep`, never an in-place generalization (11
      `[Finite W]` occurrences across 9 declarations, 17 referencing files, two of them probes
      that may not be retired). State explicitly that nothing here says `Decidable
      (PlusValidZTime φ)` and that no complexity bound is claimed.
- [ ] Add theorem-index rows to `docs/theorem-index.md` beside the existing 194-200 band: one for
      `presented_modelOf` and one for `hitCl_modelOf_eq_hitOf`, each stating the frame class
      (regular ℤ-frame), the language fragment (`box`/`stab`-free L⁺), the premise set (`Cons`),
      and the one-seam limit. Update the four **Conditional** rows' wording in that band to note
      that the hypothesis now has a constructed non-vacuous instance, without altering their own
      statements.
- [ ] Append axiom pins for all eight Goals to
      `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean`, append-only, in the file's
      existing `#guard_msgs in #print axioms` form, with a comment block stating what the new pins
      do and do not certify. Re-read the file immediately before editing (task 745 also appends
      here).
- [ ] Rewrite `specs/ROADMAP.md`'s **(S)** paragraph under the `/orchestrate 745,746` bullet: the
      construction landed for `box`/`stab`-free `φ`; the 1,200-2,000 + 300-500 carried estimate
      was pessimistic and the measured figure replaces it; the frame-constructor prerequisite was
      descoped with a machine-checked reason and is now a named successor; the "test backward
      finite branching cheapest" instruction was followed and returned a refutation of the repair
      shape, which the wired probe holds.
- [ ] Full-project guarded build, then `bash scripts/check-evidence-probes.sh`, then
      `bash .claude/scripts/lean-sorry-census.sh` (or the repository's current census entry
      point), and confirm each exits 0.

**Timing**: 2 hours

**Depends on**: 1, 7

**Verification Tier**: full

**Scope Hypothesis**: eight axiom pins (one per Goal), two new theorem-index rows beside the
existing 194-200 band, 15 registered evidence probes green after Phase 1's addition, and six
files touched as enumerated below — all four counts are hypotheses, not facts. Confirm at phase
end by counting `#print axioms` additions in the diff of the axiom-pin test, counting the new
rows in `docs/theorem-index.md`, reading `check-evidence-probes.sh`'s own count line, and
`git diff --stat`. A pin count other than eight means a Goal was silently dropped or added
relative to `## Lean Challenge Statements`.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/RaySummary/Realize.lean` - `hitCl_modelOf_eq_hitOf`
- `FormalSystem/Metalogic/Decidability/RaySummary.lean` - the import, the module bullet, and the
  header-paragraph rewrite
- `FormalSystem/Metalogic/Decidability/RaySummary/README.md` - the verdict update and the
  successor-record description
- `docs/theorem-index.md` - two new rows plus the Conditional-row wording update
- `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean` - axiom pins, append-only
- `specs/ROADMAP.md` - the (S) paragraph rewrite

**Verification**:
- The complete gate set runs and is green: the full-project guarded build
  `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build` exits 0; the test
  library builds with every `#guard_msgs` and `#guard` passing;
  `bash scripts/check-evidence-probes.sh` exits 0 with 15 probes green;
  `bash .claude/scripts/lean-sorry-census.sh` reports zero sorries across the modules this plan
  touched; `bash .claude/scripts/validate-artifact.sh specs/746_hit_level_soundness_realize_presentation_b2b/plans/01_hit-level-soundness-b2b.md plan` exits 0.
- `#print axioms hitCl_modelOf_eq_hitOf` = exactly `[propext, Classical.choice, Quot.sound]`, and
  all eight Goals are pinned in `KTypeSummaryAxiomTest.lean`.
- `grep -rn 'PlusValidZTime' ` over every file this plan touched returns only negative statements
  ("nothing here states…"), never a `Decidable` claim — checked by reading each hit.
- `grep -rni 'EXPSPACE\|PSPACE\|exponential time\|complexity bound'` over the touched files
  returns nothing asserting a bound.
- The README and the aggregator header both state the `box`/`stab` limitation and the one-seam
  limit; neither says `Hit` is computed for a model outright.
- `git diff --stat` shows no modification to `presented-not-complete.lean`,
  `quasistate-does-not-determine-hit.lean`, `SlicedFrame.lean`, or `TaskFrame.lean`.

---

## Literature Proof Structure

**Source**: HWZ 2000, *Decidable fragments of first-order temporal logics*, Theorem 14 (⇐
direction) and Definitions 10-12, as attributed in `RaySummary/README.md`. **Provenance:
UNVERIFIED summary** in this repository's literature sub-index. Treated as orientation only: no
step below is cited as authority for a Lean claim, and the formalization's own declarations are
the ground truth throughout. Tier 1 reference grounding applies (the task names the theorem).

| Source step | Translation in this plan | Phase |
|---|---|---|
| Def 10-11, state candidates and run conditions | `lab` + the landed `LocalRun`. The verbatim Def 10 bare type set is REFUTED for this semantics by `quasistate_does_not_determine_hit` and is NOT transcribed: the alphabet is `clSig φ` and types are derived by the trace map, which `Anchored` implements | — (landed) |
| Def 11, persistent runs | the decidable pair `UCoh` + `ULive` (and the backward `SCoh` + `SLive`), built on `Present.lean`'s `live`/`live_iff`. The repair relative to the paper: persistence becomes a condition on the GRAPH, which is decidable, and which `Probe735.pump_isRun` shows is necessary | 2, 3 |
| Def 12, the quasimodel as a structure | `Cons`, the hypothesis bundle. The clause the paper does not have is clause 5 (once-only `now`), needed because `IsRun` anchors the marker at one time | 5 |
| Thm 14 (⇐), build a model from the quasimodel | `modelOf := ofSlicedStep` on `W := Q`. Regularity is free; the formalization's frame constraints (`Compositional`, `Serial`, `Limit`, `Saturation`) have no paper counterpart and are discharged by the existing constructor | 6 |
| Thm 14 (⇐), the truth lemma | `eq_clTrace_of_localRun_anchored`, already in the tree. The formalization is SHORTER than the paper here, because the induction is landed | 7 |
| Lemma 17, splice / created-type hazard | ABSORBED by the product alphabet (`seamOmegaEquiv : StabFibre F t s ≃ SeqPair F s` makes the fibre a product, so a mixed type `past(t₁).future(t₂)` is automatically realized and a sound presentation simply lists it). `Cons` carries NO created-type clause. The PUMPING half of the same lemma is exactly what clauses 3-4 exclude | 5 (as a non-obligation) |

**Divergence from the source, flagged**: `Presented` is trace-set EQUALITY, this formalization's
own strengthening of HWZ (the README records it, and `Probe735.not_presented` shows the
strengthening is exactly what fails as a completeness carrier). This plan discharges the
strengthened form, which is legitimate because it is strictly stronger than Theorem 14 (⇐)'s
claim; the Hit-level statement the acceptance criterion names is its weaker consequence, obtained
by `hit_eq_hitOf_of_presented`.

**Expected formalization difficulty**, in order: Phase 7's splice plumbing and `IsRun`
bookkeeping; Phase 3's `snce` mirror (no symmetry available); Phase 5's `Cons` inhabitation;
Phase 4's closure-vacuity induction.

## Lean Challenge Statements

```lean
import FormalSystem.Metalogic.Decidability.RaySummary.Trace
import FormalSystem.Metalogic.Decidability.RaySummary.HitOf
import FormalSystem.Semantics.SlicedFrame
import FormalSystem.PlusLanguage.Subformulas

open FormalSystem.PlusLanguage FormalSystem.Metalogic.WeakCanonical
open FormalSystem.Semantics

namespace FormalSystem.PlusLanguage

/-- The `box`/`stab`-free fragment of L⁺ — this task's scope line, and the (S)/(W) boundary the
verdict already drew. -/
def PlusFormula.BoxStabFree : PlusFormula → Prop := sorry

/-- A `box`/`stab`-free formula has no `box` letter in its subformula closure, which is what makes
`Anchored.box` vacuous. -/
theorem not_box_mem_plusSubformulaClosure {φ : PlusFormula} (hφ : φ.BoxStabFree) (ψ : PlusFormula) :
    PlusFormula.box ψ ∉ plusSubformulaClosure φ := sorry

/-- The `stab` mirror: no `stab` letter in the closure, making `Anchored.stab` vacuous. -/
theorem not_stab_mem_plusSubformulaClosure {φ : PlusFormula} (hφ : φ.BoxStabFree)
    (ψ : PlusFormula) : PlusFormula.stab ψ ∉ plusSubformulaClosure φ := sorry

end FormalSystem.PlusLanguage

namespace FormalSystem.Metalogic.Decidability.RaySummary

variable {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
variable {Q : Type} [Fintype Q] [DecidableEq Q]

/-- Per-edge unfolding coherence for an `untl` letter `u` with guard `g` and event `e`:
`PlusTruthAt`'s `untl` clause unfolded across one `step`. -/
def UCoh (lab : Q → sig.preds → Bool) (step : Q → Q → Bool) (u g e : sig.preds) : Prop := sorry

/-- The deferral graph of an `untl` letter: the edges out of states claiming the eventuality and
lacking the event — the object `Probe735.pump_isRun` manufactures. -/
def deferGraph (lab : Q → sig.preds → Bool) (step : Q → Q → Bool) (u e : sig.preds) :
    Q → Q → Bool := sorry

/-- Acyclicity of the deferral graph, decided by `Present.lean`'s `live`. -/
def ULive (lab : Q → sig.preds → Bool) (step : Q → Q → Bool) (u e : sig.preds) : Prop := sorry

/-- The discharge predicate: the event at some later point with the guard on the open interval. -/
def Disch (lab : Q → sig.preds → Bool) (g e : sig.preds) (ρ : ℤ → Q) (z : ℤ) : Prop := sorry

/-- **`LocalRun`'s `untl` field, discharged from decidable per-edge data**: per-edge unfolding
coherence plus acyclicity of the deferral graph force the `untl` clause on every `step`-path.
No model, no frame, no `[Finite W]`. -/
theorem untl_iff_of_UCoh_ULive (lab : Q → sig.preds → Bool) (step : Q → Q → Bool)
    (u g e : sig.preds) (hC : UCoh lab step u g e) (hL : ULive lab step u e)
    (ρ : ℤ → Q) (hstep : ∀ z, step (ρ z) (ρ (z + 1)) = true) (z : ℤ) :
    lab (ρ z) u = true ↔ Disch lab g e ρ z := sorry

/-- The backward mirror of `UCoh`, read off `LocalRun.snce`'s own clause rather than obtained by
symmetry (no backward Bool-fixture bridge exists in this tree). -/
def SCoh (lab : Q → sig.preds → Bool) (step : Q → Q → Bool) (u g e : sig.preds) : Prop := sorry

/-- The backward deferral graph. -/
def bwdDeferGraph (lab : Q → sig.preds → Bool) (step : Q → Q → Bool) (u e : sig.preds) :
    Q → Q → Bool := sorry

/-- Acyclicity of the backward deferral graph. -/
def SLive (lab : Q → sig.preds → Bool) (step : Q → Q → Bool) (u e : sig.preds) : Prop := sorry

/-- The backward discharge predicate: the event at some earlier point with the guard on the open
interval. -/
def DischBwd (lab : Q → sig.preds → Bool) (g e : sig.preds) (ρ : ℤ → Q) (z : ℤ) : Prop := sorry

/-- **`LocalRun`'s `snce` field, discharged** — owed work proved outright, not a symmetry of
`untl_iff_of_UCoh_ULive`. -/
theorem snce_iff_of_SCoh_SLive (lab : Q → sig.preds → Bool) (step : Q → Q → Bool)
    (u g e : sig.preds) (hC : SCoh lab step u g e) (hL : SLive lab step u e)
    (ρ : ℤ → Q) (hstep : ∀ z, step (ρ z) (ρ (z + 1)) = true) (z : ℤ) :
    lab (ρ z) u = true ↔ DischBwd lab g e ρ z := sorry

/-- **The consistency conditions on a finite labelled presentation** (HWZ 2000 Def 12's
counterpart): bi-seriality, propositional coherence, `UCoh`+`ULive` per `untl` letter,
`SCoh`+`SLive` per `snce` letter, the once-only `now` condition, and `box`/`stab`-freeness of
`φ`. Derived from `Probe735.not_presented`'s pumping proof, not from HWZ Def 10's bare type set,
which `quasistate_does_not_determine_hit` refutes for this semantics. -/
structure Cons (φ : PlusFormula) (lab : Q → (clSig φ).preds → Bool) (step : Q → Q → Bool) :
    Prop where

/-- **Every `step`-path of a consistent presentation satisfies the run conditions**: field by
field, with `untl` and `snce` cited from the two theorems above and no new induction. -/
theorem cons_localRun {φ : PlusFormula} {lab : Q → (clSig φ).preds → Bool} {step : Q → Q → Bool}
    (hC : Cons φ lab step) (ρ : ℤ → Q) (hstep : ∀ z, step (ρ z) (ρ (z + 1)) = true) :
    LocalRun φ (runTrace lab ρ) := sorry

/-- **The frame of a presentation**: `ofSlicedStep` on the presentation's own finite `Q` with the
time-constant step relation. Carrier `ℤ × Q` is infinite; no finite-fibre or finite-width
assumption is introduced. -/
def frameOf {φ : PlusFormula} {lab : Q → (clSig φ).preds → Bool} {step : Q → Q → Bool}
    (hC : Cons φ lab step) : FrameOver intOrder := sorry

/-- **The model of a presentation**: the valuation reads the state component's label. -/
def modelOf (φ : PlusFormula) (lab : Q → (clSig φ).preds → Bool) (step : Q → Q → Bool)
    (hC : Cons φ lab step) : TaskModel (frameOf hC).toTaskFrame := sorry

/-- For `box`/`stab`-free `φ`, a run's trace is anchored to the corresponding history of the
constructed model: `now` from `IsRun`, `atom` from the valuation, `box` and `stab` vacuously. -/
theorem anchored_runTrace_of_boxStabFree {φ : PlusFormula} (hφ : φ.BoxStabFree)
    {lab : Q → (clSig φ).preds → Bool} {step : Q → Q → Bool} (hC : Cons φ lab step) (t : ℤ)
    (ρ : ℤ → Q) (hρ : IsRun lab step (clNow φ) t ρ)
    (σ : WorldHistory (frameOf hC).toTaskFrame) (hσ : σ.path = fun z => (z, ρ z)) :
    Anchored (modelOf φ lab step hC) φ t (runTrace lab ρ) σ := sorry

/-- **Requirement (S), HWZ 2000 Theorem 14 (⇐) for the box-dot fibre**: a finite presentation
satisfying `Cons` is realized by the constructed regular ℤ-model at a seam anchored at a
`now`-labelled state — the realization hypothesis `Presented`, discharged for a constructed
model. Scope: `box`/`stab`-free `φ`, one seam. Nothing is stated about validity. -/
theorem presented_modelOf {φ : PlusFormula} (hφ : φ.BoxStabFree)
    {lab : Q → (clSig φ).preds → Bool} {step : Q → Q → Bool} (hC : Cons φ lab step)
    (t : ℤ) (q₀ : Q) (hq₀ : lab q₀ (clNow φ) = true)
    (τ : WorldHistory (frameOf hC).toTaskFrame) (hτ : τ.state t = (t, q₀)) :
    Presented (modelOf φ lab step hC) τ t φ lab (fun q q' => step q q' = true) := sorry

/-- **The Hit-level acceptance statement**: the realized set of the constructed model's seam IS
the computable `hitOf` of the presentation, at every depth `k ≥ 1`. One line from
`hit_eq_hitOf_of_presented` and `presented_modelOf`. This decides nothing: `Decidable
(PlusValidZTime φ)` does not follow, and no complexity bound is claimed. -/
theorem hitCl_modelOf_eq_hitOf {φ : PlusFormula} (hφ : φ.BoxStabFree)
    {lab : Q → (clSig φ).preds → Bool} {step : Q → Q → Bool} (hC : Cons φ lab step)
    (t : ℤ) (q₀ : Q) (hq₀ : lab q₀ (clNow φ) = true)
    (τ : WorldHistory (frameOf hC).toTaskFrame) (hτ : τ.state t = (t, q₀))
    (k : ℕ) (hk : 1 ≤ k) :
    HitCl (modelOf φ lab step hC) τ t φ k =
      ↑(hitOf lab (fun q q' => step q q' = true) (clNow φ) k) := sorry

end FormalSystem.Metalogic.Decidability.RaySummary
```

## Testing & Validation

- [ ] Full-project guarded build green: `bash .claude/scripts/lake-build-guard.sh build --timeout
      1800 -- build` exits 0 (detached, never foreground, never bare `lake`).
- [ ] Zero sorries across every module this plan touches, confirmed by
      `bash .claude/scripts/lean-sorry-census.sh`.
- [ ] All eight Goals pinned in `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean` with
      axiom profile exactly `[propext, Classical.choice, Quot.sound]`; the test library builds
      with every `#guard_msgs` passing.
- [ ] The `Cons` non-vacuity `#guard`s in `Tests/BimodalTest/Metalogic/KTypeFinEvalTest.lean`
      pass, INCLUDING the negative control (`live deferBad 0 = true`, the `Probe735` shape) —
      the conditions must be shown to exclude something.
- [ ] `bash scripts/check-evidence-probes.sh` exits 0 with 15 probes green, the two pre-existing
      verdict probes among them unmodified.
- [ ] `bash .claude/scripts/validate-artifact.sh specs/746_hit_level_soundness_realize_presentation_b2b/plans/01_hit-level-soundness-b2b.md plan` exits 0.
- [ ] No file touched by this plan states `Decidable (PlusValidZTime φ)` in any form, asserts any
      complexity bound, introduces a `[Finite W]`-style finite-fibre or finite-width assumption on
      the constructed model, adds a cslib `require` edge or copies a cslib declaration, or implies
      a backward Bool-fixture bridge exists. Each checked by reading the hits of a targeted grep,
      not by assuming.
- [ ] No vacuous definition anywhere (`:= True`, `:= Unit`, `:= trivial` bodies), per
      `lean4.md`'s prohibition.

## Artifacts & Outputs

**file_scope** (set at plan time, as the dispatch required — the record was filed without one,
which made it invisible to the batch-admission overlap gate):

- `FormalSystem/Metalogic/Decidability/RaySummary/Realize.lean` (new; Phases 2, 3, 5, 6, 7, 8)
- `FormalSystem/Metalogic/Decidability/RaySummary.lean` (Phase 8)
- `FormalSystem/Metalogic/Decidability/RaySummary/README.md` (Phase 8)
- `FormalSystem/PlusLanguage/Subformulas.lean` (Phase 4)
- `Tests/BimodalTest/Metalogic/KTypeFinEvalTest.lean` (Phase 5)
- `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean` (Phase 8; shared with task 745 —
  append-only, re-read immediately before editing)
- `docs/theorem-index.md` (Phase 8)
- `specs/evidence/seam-gluing-ray-product/b2b-frame-constructor-branching.lean` (new; Phase 1)
- `scripts/check-evidence-probes.sh` (Phase 1; shared with task 733 — append-only)
- `specs/ROADMAP.md` (Phase 8)

Expected outputs: the new `Realize.lean` module (~600-900 lines across Phases 2-8); the new wired
evidence probe (~175-200 lines); ~60-95 lines appended to `Subformulas.lean`; ~70-100 lines of
`#guard` witnesses and ~40-60 lines of axiom pins in the two test modules; two theorem-index rows
plus a wording update to the 194-200 Conditional band; the README verdict update carrying the
`box`/`stab` limitation and the frame-constructor successor-record description; the ROADMAP (S)
paragraph rewrite; and an execution summary at
`specs/746_hit_level_soundness_realize_presentation_b2b/summaries/01_hit-level-soundness-b2b-summary.md`.

## Rollback/Contingency

- **Per-phase**: every phase commits only when its own verification is green, one commit per green
  sub-step (`git-workflow.md`'s commit-per-green-substep mandate), with targeted file-list staging
  only — never `git add -A`, never a directory or glob pathspec, never `git commit -am`. A sibling
  task (745) is live on this same working tree this cycle, so re-read each file immediately before
  editing and stage only this task's own hunks. Reverting a phase is `git revert` of its commits;
  no phase depends on uncommitted state from another.
- **Never run `git-snapshot.sh` in its reverting default form** during this plan — the territory
  note forbids it under concurrency. An ordinary defensive checkpoint before a risky edit uses
  `bash .claude/scripts/git-snapshot.sh 746 --no-revert`.
- **If Phase 7's (⇒) direction is genuinely obstructed**: close Phase 7 `[BLOCKED]` with the goal
  state recorded, keep the green (⇐) half committed, and degrade Phase 8 to the acceptance
  criterion's second branch — a per-sub-obstruction MACHINE-CHECKED verdict naming precisely what
  cannot be built and what it would cost, as a theorem or a wired probe rather than argued in
  prose. That is a COMPLETE result, and it is how tasks 737, 742 and 735 each closed. Do NOT
  substitute a weaker same-named statement for `presented_modelOf` (`plan-compliance.md`
  Statement Fidelity) and do NOT write a strategic sorry or a vacuous definition.
- **If Phase 3's `snce` mirror resists**: land the direction that needs no liveness
  (`u_of_dischBwd`) green and commit it, then close the phase `[PARTIAL]` with the remaining goal
  state. Phase 5's `Cons` can still be stated with the `snce` clauses present and
  `cons_localRun`'s `snce` field is then the single blocked obligation — a much smaller
  obstruction to report than a blocked Phase 7.
- **If the `Cons` bundle proves un-inhabitable** at Phase 5 (the `#guard` witness fails rather
  than the proof): the bundle is over-strong. Repair it within the phase by weakening the
  offending clause to what the probe-03 fixture actually satisfies, record the change in the
  module docstring and the issue log, and re-run the negative control to confirm the weakened
  bundle still excludes the `Probe735` shape. A bundle that no longer excludes it is not a
  repair.
- **Nothing landed is removed under any contingency**: `Presented`, `hit_eq_hitOf_of_presented`,
  `ofSlicedStep` and its companions, task 735's verdict, and both wired probes
  (`presented-not-complete`, `quasistate-does-not-determine-hit`) stay exactly as they are.
