# Implementation Plan: Quasimodel Pivot via EnrichedClosure (v4)

- **Task**: 98 - research_filtration_quasimodel_pivot
- **Status**: [NOT STARTED]
- **Effort**: 70-135 hours (point estimate: 95h)
- **Dependencies**: Task 99 (COMPLETED) provides the BXPoint-backed
  `HintikkaStepOracle` and `chain_step_seed_consistent` that Phase 4
  consumes. Parallel-safe with tasks 93 and 94.
- **Research Inputs**:
  - specs/098_research_filtration_quasimodel_pivot/reports/01_filtration-quasimodel-pivot.md
  - specs/098_research_filtration_quasimodel_pivot/reports/02_team-research.md
  - specs/098_research_filtration_quasimodel_pivot/reports/03_team-research.md
  - specs/098_research_filtration_quasimodel_pivot/reports/03_teammate-a-findings.md
  - specs/098_research_filtration_quasimodel_pivot/reports/03_teammate-c-findings.md
  - specs/098_research_filtration_quasimodel_pivot/reports/03_teammate-d-findings.md
  - specs/098_research_filtration_quasimodel_pivot/reports/08_team-research.md
  - specs/098_research_filtration_quasimodel_pivot/reports/08_teammate-c-findings.md (round 4 critic; primary v4 driver)
  - specs/099_bxpoint_backed_hintikka_oracle/summaries/01_bxpoint-backed-oracle-summary.md (task 99 payload)
- **Artifacts**: plans/04_quasimodel-pivot-plan.md (this file)
- **Standards**:
  - .claude/rules/artifact-formats.md
  - .claude/rules/state-management.md
  - .claude/context/formats/plan-format.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Plan v3 was halted at Phase 4 because the `chain_step_seed_consistent`
obligation could not be discharged against the bare `HintikkaPoint`
abstraction, and because the round 4 critic (08_teammate-c-findings.md)
identified three independent latent blockers in Phases 5 and 6 plus a
zero-debt violation in the Phase 6 axiom fallback. Task 99 has now
landed a BXPoint-backed `HintikkaStepOracle`, a `WitnessedHintikka`
structure that carries an MCS witness through the chain, a
`ChainWitnessed` predicate, and a fully-proved `chain_step_seed_consistent`
theorem (`specs/099_.../summaries/01_bxpoint-backed-oracle-summary.md`).
Plan v4 rewrites Phase 3/4 around the post-task-99 API (the Hintikka
chain is realized-as-it-is-built, carrying an MCS witness in lockstep),
rewrites Phase 5 to state and discharge the stricter enriched-seed
obligation identified as C.4, rewrites Phase 6 as a zero-debt
spanning-chain construction with an explicit descope branch if the
spanning proof exceeds 20h, deletes the prior axiom fallback entirely,
and rebudgets Phases 4-8 to the realistic 70-135h range from C.7.
Phases 1 and 2 remain unchanged from v3 (already COMPLETED in tree).
Definition of done: `lake build` succeeds with zero new sorries, zero
new axioms, and the ten targeted sorries (4 in Frame.lean + 6 in
Realization.lean) replaced by proofs; OR task 98 is explicitly marked
`[PARTIAL]` with Phase 6 descoped to a successor task and the remaining
non-Phase-6 sorries closed.

### Research Integration

- **01_filtration-quasimodel-pivot.md** — established local quasimodel
  approach.
- **02_team-research.md**, **03_team-research.md** — EnrichedClosure
  design, defect-count termination.
- **03_teammate-a-findings.md** — `bigconj`/`neg_bigconj` construction
  and the reduction that Phase 4 implements.
- **03_teammate-c-findings.md** — prior locus-control critique carried
  forward.
- **03_teammate-d-findings.md** — defect-count strict-decrease.
- **08_team-research.md**, **08_teammate-c-findings.md** (primary v4
  driver) — identification of C.4 (Phase 5 stricter seed obligation),
  C.5 (Phase 6 axiom fallback violates zero-debt), C.7 (Phases 4-8
  effort optimism by 30-50%), and C.6 (fuse Phase 3 and 5 around an
  MCS-backing witness).
- **099/summaries/01_bxpoint-backed-oracle-summary.md** — concrete
  post-task-99 API that Phase 4 consumes: `WitnessedHintikka`,
  `ChainWitnessed`, `HintikkaStepOracle` new shape, and the landed
  `chain_step_seed_consistent` theorem.

### Prior Plan Reference

Plan v3 Phases 1 and 2 are complete in tree (EnrichedClosure,
`bigconj`/`neg_bigconj`, HintikkaPoint/Construction migrated). Phase 3
was marked complete in v3 but produced a chain type that did **not**
carry an MCS witness; task 99 has superseded that shape. Phase 4 in v3
was marked PARTIAL; the task-99 work retires the technical blocker.
Phases 5, 6, 7, 8 in v3 are preserved as scope but rewritten here to
address C.4, C.5, C.6, C.7. No phases from v3 are copied verbatim except
the COMPLETED Phases 1 and 2, which are restated for traceability only.

### Roadmap Alignment

Task 98 advances the BX canonical-model completeness milestone by
unblocking the Until/Since Truth Lemma and the four Frame.lean
Until/Since sorries. It remains parallelizable with tasks 93 and 94.

## Goals & Non-Goals

**Goals**:

- Consume the task-99 `WitnessedHintikka` / `ChainWitnessed` /
  `HintikkaStepOracle` API to retire Phase 4's chain-step obligation
  without modifying the task-99 deliverables.
- Thread `ChainWitnessed` through `realize_chain_step` so the stricter
  enriched seed `h_{i+1} ∪ g_content(v_i) ∪ {¬f | f ∈ Sigma \ h_{i+1}}`
  is proved consistent at MCS level, not at Hintikka level (C.4).
- Replace Phase 6's locus-control exhaustiveness with either (a) a
  zero-debt spanning-chain construction or (b) an explicit descope to a
  follow-on task; remove the v3 axiom fallback entirely (C.5).
- Rebudget Phases 4-8 to 70-135h range (C.7).
- Port the BXPoint-backed witness pattern to the Since dual
  (`HintikkaStepOracleSince`), which task 99 explicitly deferred.
- Close all 10 targeted sorries (4 Frame.lean + 6 Realization.lean) OR
  document a clean descope boundary.
- Preserve `lake build` cleanliness and zero-debt compliance throughout.

**Non-Goals**:

- Modifying task 99's `WitnessedHintikka` / `HintikkaStepOracle` /
  `chain_step_seed_consistent` declarations (reference-only; the design
  is stable and any change would re-open that task's scope).
- Redefining `bx_le`.
- Adding new BX axioms or **any** new axioms including
  `locus_control_exhaustive` (zero-debt policy, C.5).
- Building the TaskModel embedding (task 93).
- Touching Frame.lean lines 140-583 beyond the four targeted sorries.
- Any changes to TruthLemma.lean G/H/Box cases.
- Archiving legacy sorries (task 94).

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Phase 5 stricter-seed consistency (C.4) fails even with `ChainWitnessed` | H | M (30%) | The stricter seed adds `{¬f | f ∈ Sigma \ h_{i+1}}`; the witness `w_{i+1}` produced by `bx_forward_witness` already decides every `f ∈ Sigma` via `locally_maximal`, so each `¬f` we need is either in `w_{i+1}.formulas` (consistent with the MCS) or `f ∈ w_{i+1}.formulas` but `f ∉ h_{i+1}.formulas` (contradicting the sigma_signature equality we are proving). Phase 5 structures the proof explicitly around this dichotomy. If it fails, Gate B halts and re-scopes. |
| Phase 6 spanning-chain construction exceeds 30h budget | H | M (40%) | v4 drops the axiom fallback; the fallback is now **explicit descope**: split locus-control exhaustiveness + `until_backward`/`since_backward` into a new task 101, mark task 98 `[PARTIAL]` with the remaining 8 sorries closed. No axioms. |
| Since-dual divergence pushes Phase 8 over estimate | M | M (35%) | Budget dedicated Since sub-phase (Phase 4b) that ports the witness pattern to `HintikkaStepOracleSince`; mirror Phase 5's C.4 treatment for `h_content`. |
| `.toList` ordering hazards in `bigconj L_h.toList` threading (C critic Q4) | M | M (40%) | Thread a single `.toList` call throughout each proof; add helper `bigconj_toList_stable` if needed; budget 2-4h debugging buffer inside Phase 4. |
| Downstream callers (Realization.lean) break when consuming the new `HintikkaStepOracle` signature | M | L (20%) | Task 99 summary confirms `HintikkaStepOracle` has **no callers outside Construction.lean** today; Phase 4 is the first caller. Verify with grep before starting. |
| `chain_step_seed_consistent` as landed requires an `S : Set Formula` argument shape incompatible with Phase 5's seed | M | L (15%) | Task 99 signature takes `S ⊆ h.formulas` and returns `SetConsistent S`; Phase 5's seed extends beyond `h.formulas`, so a lifted variant is needed. Phase 4a defines `chain_step_seed_consistent_enriched` as a **new theorem in task 98's own files**, consuming the task-99 primitive as an ingredient but not modifying it. |
| Cascading type-signature changes across 4+ files | M | M (25%) | Phase 4a does a contained `HintikkaStepOracle`-consumer audit; Realization.lean updates are isolated to the `realize_chain_step` proof site. |
| Total effort exceeds 135h | M | M (30%) | Gate B and Gate C trigger an explicit split: Phase 6 becomes task 101, task 98 ships the 8 non-Phase-6 sorries closed, no axioms. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2 | -- |
| 2 | 3 | 1, 2 |
| 3 | 4a | 3 |
| 4 | 4b | 4a |
| 5 | 5 | 4a, 4b |
| 6 | 6 | 5 |
| 7 | 7 | 5, 6 |
| 8 | 8 | 7 |

Phases within the same wave can execute in parallel. Phases 1 and 2 are
restated only for continuity; both are `[COMPLETED]` in tree and require
no work.

**Checkpoint gates**:

- **Gate A** (end of Phase 3): BXPoint-backed chain from task 99
  integrated into task 98's Construction.lean call sites; `lake build`
  clean. If failed, halt and escalate — task 99 assumptions were wrong.
- **Gate B** (end of Phase 5): Stricter enriched-seed consistency (C.4)
  proved for both Until and Since; `realize_full_chain` compiles with
  axiom audit clean. If failed, halt and re-scope Phase 5 via a new
  research round; do **not** introduce axioms.
- **Gate C** (start of Phase 6): decision point between (a) full
  spanning-chain proof (budget 20-40h) and (b) explicit descope of
  locus-control exhaustiveness into task 101. No third option.

---

### Phase 1: Bigconj and EnrichedClosure Definition [COMPLETED]

**Goal**: Define `bigconj`, `neg_bigconj`, and the Fisher-Ladner
`EnrichedClosure` plus closure/negation-pairing lemmas.

**Tasks**: (completed in v3; restated for continuity)

- [x] `Theories/Bimodal/Syntax/BigConj.lean` with `bigconj`,
  `neg_bigconj`, and derivation-tree helpers.
- [x] `EnrichedClosure.lean` with `enrichedClosure`,
  `enriched_target_mem`, `enriched_subformula_mem`,
  `enriched_g_neg_bigconj_mem`, `enriched_h_neg_bigconj_mem`,
  `enriched_neg_pairing`, `enriched_finite`.

**Timing**: 0h (already in tree)

**Depends on**: none

**Verification**: already satisfied.

---

### Phase 2: Migrate HintikkaPoint / Construction to EnrichedClosure [COMPLETED]

**Goal**: Route `HintikkaPoint`, `Construction`, `Realization`, and
`LocusControl` through `enrichedClosure` as the Sigma of record.

**Tasks**: (completed in v3; restated for continuity)

- [x] `HintikkaPoint Sigma` quantification updated.
- [x] `sigma_signature_mem`, `locally_maximal` re-verified under
  `EnrichedClosure`.

**Timing**: 0h (already in tree)

**Depends on**: 1

**Verification**: already satisfied.

---

### Phase 3: Integrate the BXPoint-backed HintikkaStepOracle (task 99 payload) [COMPLETED]

**Goal**: Adopt task 99's `WitnessedHintikka` / `ChainWitnessed` /
`HintikkaStepOracle` / `hintikka_chain_exists` / `chain_step_seed_consistent`
as the chain-construction API for Phase 4 and beyond. The chain is
realized-as-it-is-built (C.6): every point carries its MCS witness.

**Tasks**:

- [ ] Read `Construction.lean` in tree to confirm the task-99 declarations
  are present and match the signatures in
  `specs/099_.../summaries/01_bxpoint-backed-oracle-summary.md`.
- [ ] Audit every caller of `HintikkaStepOracle` and
  `hintikka_chain_exists` with `grep -rn` across `Theories/`; confirm
  (per the task-99 summary) there are no callers outside
  `Construction.lean`. If any have appeared, update them to pass the
  `w0 : BXPoint` seed and `h0_sub` proof.
- [ ] Define a thin adapter `quasimodel_chain_exists` that wraps
  `hintikka_chain_exists` to produce the
  `QuasimodelChain` / `HintikkaRawChain`-compatible shape expected by
  Phase 5, including the `ChainWitnessed` witness as a separate
  returned component.
- [ ] For the starting point, identify and document the `BXPoint`
  witness source (the canonical MCS at `v_0` from Frame.lean's context)
  that Phase 5 will feed in as `w0`.
- [ ] Run `lake build`; `lean_verify hintikka_chain_exists` to confirm
  `[propext, Classical.choice, Quot.sound]` axiom set.
- [ ] **GATE A**: If any of the above fails, halt and file a
  back-channel to task 99.

**Timing**: 4-8 hours

**Depends on**: 1, 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/Construction.lean`
  (adapter only, no modification of task-99 declarations)

**Verification**:
- [ ] `lake build` clean.
- [ ] Zero new sorries.
- [ ] `lean_verify` on `hintikka_chain_exists` and
  `chain_step_seed_consistent` returns the task-99 axiom set.
- [ ] Gate A passed: adapter compiles, chain construction is callable
  from `Realization.lean` with the new signature.

---

### Phase 4a: Consume chain_step_seed_consistent for Until realization [NOT STARTED]

**Goal**: In `Realization.lean`, replace the failed v3 Phase 4b
derivation with a direct consumption of the task-99-landed
`chain_step_seed_consistent` theorem plus a task-98-local lifting
lemma `chain_step_seed_consistent_enriched` that extends the seed with
`g_content(v_i.formulas)`.

**Tasks**:

- [ ] State `chain_step_seed_consistent_enriched : ChainWitnessed c →
  ∀ h ∈ c.points, SetConsistent (h.formulas ∪ g_content v_i.formulas)`.
- [ ] Structure the proof as Teammate A §3.3 prescribed, but use
  `chain_step_seed_consistent` (task 99) for the `S ⊆ h.formulas` half
  and use `g_content_closed_derivation` + the bigconj machinery for the
  cross-seed half. The `ChainWitnessed` MCS witness `w` discharges the
  derivation-level consistency through `w.is_mcs.1`.
- [ ] Thread a **single** `.toList` call on the failing finite subset to
  avoid the C-critic Q4 `Finset.toList` ordering hazard.
- [ ] Add supporting lemmas: `bigconj_mem_hintikka_via_witness`,
  `neg_bigconj_mem_next_hintikka`.
- [ ] `lean_verify` on `chain_step_seed_consistent_enriched` to confirm
  the axiom set.

**Timing**: 10-18 hours

**Depends on**: 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/Realization.lean`
  (new theorem + helpers; no signature churn for existing lemmas)

**Verification**:
- [ ] `chain_step_seed_consistent_enriched` compiles.
- [ ] Zero new sorries, zero new axioms.
- [ ] `lake build` clean.
- [ ] Axiom audit matches task 99 baseline.

---

### Phase 4b: Since dual — witness-backed HintikkaStepOracleSince [NOT STARTED]

**Goal**: Port task 99's BXPoint-backed witness pattern to the Since
dual (`HintikkaStepOracleSince`, which task 99 explicitly left as a
TODO), and prove the Since analogue of
`chain_step_seed_consistent_enriched`.

**Tasks**:

- [ ] Strengthen `HintikkaStepOracleSince` to return a
  `WitnessedHintikka` using the existing `WitnessedHintikka` structure
  (no new type).
- [ ] Strengthen `hintikka_chain_exists_since` to take a backing
  witness `w0 : BXPoint` and return a `ChainWitnessed` predicate on the
  Since chain.
- [ ] Prove `chain_step_seed_consistent_since` mirroring the task 99
  one-line proof.
- [ ] Prove `chain_step_seed_consistent_enriched_since` mirroring
  Phase 4a, substituting `h_content` for `g_content` and
  `Formula.all_past` for `Formula.all_future`.
- [ ] Remove the TODO comment task 99 left next to
  `HintikkaStepOracleSince` in `Construction.lean`.

**Timing**: 8-14 hours

**Depends on**: 4a

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/Construction.lean`
  (Since oracle + chain existence)
- `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/Realization.lean`
  (Since enriched-seed lemma)

**Verification**:
- [ ] `lake build` clean.
- [ ] Zero new sorries, zero new axioms.
- [ ] `lean_verify` on the Since analogues matches the Until axiom set.

---

### Phase 5: Realize Full Chain with stricter seed (C.4) [NOT STARTED]

**Goal**: Turn the witnessed Hintikka chain into a BXPoint chain via
`realize_chain_step`, discharging the **stricter** enriched seed
`h_{i+1}.formulas ∪ g_content(v_i.formulas) ∪ {¬f | f ∈ Sigma \ h_{i+1}.formulas}`
identified by C.4. This is the C.4 resolution and is the central
technical phase of v4.

**Tasks**:

- [ ] State the stricter seed explicitly as
  `realize_seed_strict i := h_{i+1}.formulas ∪ g_content(v_i.formulas) ∪
  {¬f | f ∈ Sigma ∧ f ∉ h_{i+1}.formulas}`.
- [ ] Prove `realize_seed_strict_consistent`: the seed is derivation-consistent.
  Proof strategy (C.4 resolution):
  - Decompose into three chunks.
  - `h_{i+1}.formulas ∪ g_content(v_i.formulas)` is consistent by
    Phase 4a (`chain_step_seed_consistent_enriched`).
  - For the `{¬f | f ∈ Sigma \ h_{i+1}.formulas}` chunk, use the
    `ChainWitnessed` witness `w_{i+1}` for `h_{i+1}`. By
    `locally_maximal` under EnrichedClosure, every `f ∈ Sigma` is
    decided in the MCS `w_{i+1}`. If `f ∉ h_{i+1}.formulas` then
    because `h_{i+1} = sigma_signature w_{i+1} Sigma` (the task-99
    subset property plus locally_maximal on `w_{i+1}`), we have
    `¬f ∈ w_{i+1}.formulas`. So the chunk is a subset of
    `w_{i+1}.formulas`.
  - The union of three consistency witnesses into a single MCS
    (`w_{i+1}`) is consistent by `w_{i+1}.is_mcs.1`.
- [ ] Prove `realize_chain_step`: given a `ChainWitnessed` chain and
  `v_i` with `sigma_signature v_i Sigma = h_i`, extend to `v_{i+1}` via
  Lindenbaum on `realize_seed_strict i`, preserving `bx_le v_i v_{i+1}`
  and `sigma_signature v_{i+1} Sigma = h_{i+1}`.
- [ ] Prove `realize_full_chain` by induction on the `QuasimodelChain`.
- [ ] Prove `guard_transfer` and `witness_transfer`.
- [ ] Mirror Since: `realize_seed_strict_since`,
  `realize_seed_strict_since_consistent`, `realize_chain_step_since`,
  `realize_full_chain_since`.
- [ ] **GATE B**: if any step fails, halt. Do **not** introduce axioms;
  escalate to a new research round.

**Timing**: 18-30 hours

**Depends on**: 4a, 4b

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/Realization.lean`

**Verification**:
- [ ] `realize_full_chain` compiles; axiom audit clean.
- [ ] `guard_transfer` and `witness_transfer` sorry-free.
- [ ] Gate B passed.

---

### Phase 6: Locus-Control Exhaustiveness — zero-debt or descope (C.5) [NOT STARTED]

**Goal**: Either prove `locus_control_exhaustive` via a zero-debt
spanning-chain construction, or explicitly descope the lemma into a
new task 101 and mark task 98 `[PARTIAL]` after Phase 7/8 close the
8 non-dependent sorries. **The v3 axiom fallback is removed** — there
is no axiom path in v4 (C.5 zero-debt enforcement).

**Gate C (at start of Phase 6)**: choose path:
- **Path A — Prove**: attempt the spanning-chain construction
  (described below). Budget 20-40h. If budget exhausted and the proof
  is not in reach, halt and switch to Path B.
- **Path B — Descope**: skip Phase 6 entirely; proceed to Phase 7/8
  against the subset of the 10 sorries that do not need locus-control
  exhaustiveness (sorries R1, R2, R4, R5, F1, F3 — 6 of 10); file a
  new task 101 for locus-control plus R3, R6, F2, F4 (the remaining 4
  sorries); mark task 98 `[PARTIAL]`.

**Path A tasks** (if chosen):

- [ ] Rewrite Phase 3's `hintikka_chain_exists` output as a **spanning
  structure** (not a path) that visits every `HintikkaPoint` reachable
  from `h_0` in at most `k` `hintikka_step`s. Concretely: replace the
  `HintikkaRawChain` with a `HintikkaSpanningTree` and adapt the
  well-founded recursion on `defect_count` to enumerate all
  step-successors at each layer, not just one per target-defect.
- [ ] Prove `hintikka_reachable_in_tree`: every reachable point
  appears in the spanning tree.
- [ ] State and prove `locus_control_exhaustive`: for every `u` with
  `bx_le v_0 u ∧ bx_le u v_k`, `sigma_signature u Sigma` appears in the
  spanning tree, and therefore equals some `h_i` whose realized
  `v_i` satisfies the transfer lemmas.
- [ ] Update `LocusControl.lean` to expose `locus_control_exhaustive`.
- [ ] Axiom audit must show only the standard Lean/Mathlib axiom set.

**Path B tasks** (if chosen):

- [ ] Draft `specs/101_locus_control_exhaustiveness/` task description
  and minimal research summary pointing at Phase 6 Path A as the
  approach of record.
- [ ] Update task 98 TODO.md and state.json entries to `[PARTIAL]`
  with explicit sorries listed (R3, R6, F2, F4).
- [ ] Document in the task 98 summary which sorries are closed vs
  deferred and why.

**Timing**: Path A: 20-40h. Path B: 2-4h setup + dependent phase
cascade costs.

**Depends on**: 5

**Files to modify** (Path A):
- `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/Construction.lean`
  (spanning tree)
- `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/LocusControl.lean`

**Files to modify** (Path B):
- `specs/TODO.md`, `specs/state.json`
- `specs/101_locus_control_exhaustiveness/` (new task directory)

**Verification**:
- Path A: `locus_control_exhaustive` compiles; `lean_verify` shows
  only standard axioms; `lake build` clean.
- Path B: task 101 created; task 98 correctly marked `[PARTIAL]` with
  sorries listed; no new axioms introduced anywhere.

---

### Phase 7: Close Realization.lean Sorries (Until and Since) [NOT STARTED]

**Goal**: Replace the six sorries in `Realization.lean` using the
infrastructure from Phases 3-6. If Phase 6 took Path B, only R1, R2,
R4, R5 are closed here and R3, R6 are deferred to task 101.

**Tasks**:

- [ ] **R1 (Realization.lean:282)** — Until realization consistency.
  Close via `realize_seed_strict_consistent` (Phase 5).
- [ ] **R2 (Realization.lean:286)** — Until realization sigma-signature
  round-trip. Close via `sigma_signature_mem` under EnrichedClosure.
- [ ] **R3 (Realization.lean:346)** — `until_backward`. Close via
  `realize_full_chain` (Phase 5) + `locus_control_exhaustive` (Phase 6
  Path A). **If Path B**: defer to task 101.
- [ ] **R4 (Realization.lean:372)** — Since realization consistency.
  Close via `realize_seed_strict_since_consistent` (Phase 5).
- [ ] **R5 (Realization.lean:374)** — Since realization sigma-signature
  round-trip. Close via EnrichedClosure Since dual.
- [ ] **R6 (Realization.lean:404)** — `since_backward`. Close via Since
  dual of R3. **If Path B**: defer to task 101.
- [ ] Add explicit `bx_le v u` case analysis where the C-critic noted
  it was missing (Q-section §4.3) so the guard transfer is
  non-vacuously handled.

**Timing**: 10-18 hours

**Depends on**: 5, 6

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/Realization.lean`

**Verification**:
- [ ] Path A: zero sorries remaining in `Realization.lean`.
- [ ] Path B: four sorries remaining (R1, R2, R4, R5 closed; R3, R6
  deferred with explicit comment pointing at task 101).
- [ ] `lean_verify` on every closed theorem shows only standard
  Lean/Mathlib axioms.
- [ ] `lake build` clean.

---

### Phase 8: Close Frame.lean Sorries [NOT STARTED]

**Goal**: Replace the four Until/Since sorries in `Frame.lean` using
the now-proved Realization.lean lemmas. If Phase 6 took Path B, only
F1 and F3 are closed here and F2, F4 are deferred to task 101.

**Tasks**:

- [ ] **F1 (Frame.lean:653)** — `bx_until_eventuality_resolution`.
  Invoke `realize_full_chain` (Phase 5).
- [ ] **F2 (Frame.lean:675)** — `bx_until_backward`. Invoke
  `until_backward` (R3). **If Path B**: defer to task 101.
- [ ] **F3 (Frame.lean:690)** — `bx_since_eventuality_resolution`.
  Since dual of F1.
- [ ] **F4 (Frame.lean:704)** — `bx_since_backward`. Since dual of F2.
  **If Path B**: defer to task 101.
- [ ] Confirm Frame.lean lines 140-583 are untouched.
- [ ] Confirm TruthLemma.lean G/H/Box cases still compile unchanged.
- [ ] Final full-project `lake build`.

**Timing**: 6-12 hours

**Depends on**: 7

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Frame.lean` (only lines
  628-707, the four sorry theorems)

**Verification**:
- [ ] Path A: zero sorries in Frame.lean for the four targeted
  theorems; task 98 mark `[COMPLETED]`.
- [ ] Path B: two sorries remain (F2, F4); task 98 mark `[PARTIAL]`
  with explicit pointer to task 101.
- [ ] `lake build` clean at project root.
- [ ] `lean_verify` on closed theorems shows only standard axioms. No
  axioms introduced anywhere.

---

## Testing & Validation

- [ ] `lake build` clean at project root at the end of each phase.
- [ ] Sorry counts monotonically decrease across Phases 7-8.
- [ ] `lean_verify` on every theorem closed in Phases 3-8 shows only
  standard Lean/Mathlib axioms. **No new axioms are acceptable.** Any
  attempt to introduce an axiom triggers Gate B or Gate C failure.
- [ ] `lean_profile_proof` on `chain_step_seed_consistent_enriched`
  and `realize_seed_strict_consistent` shows elaboration < 10s each.
- [ ] Frame.lean lines 140-583 unchanged (verify with `git diff
  --stat`).
- [ ] TruthLemma.lean unchanged.
- [ ] Task 99 declarations (`WitnessedHintikka`, `ChainWitnessed`,
  `HintikkaStepOracle`, `hintikka_chain_exists`,
  `chain_step_seed_consistent`) unchanged (reference-only).

## Artifacts & Outputs

- `specs/098_research_filtration_quasimodel_pivot/plans/04_quasimodel-pivot-plan.md` (this file)
- Updates to `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/Construction.lean`
  (Phase 3 adapter, Phase 4b Since oracle, Phase 6 Path A optional
  spanning tree)
- Updates to `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/Realization.lean`
  (Phases 4a, 4b, 5, 7)
- Updates to `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/LocusControl.lean`
  (Phase 6 Path A only)
- Updates to `Theories/Bimodal/Metalogic/BXCanonical/Frame.lean`
  (Phase 8, 4 theorems only, lines 628-707)
- Final implementation summary at
  `specs/098_research_filtration_quasimodel_pivot/summaries/04_implementation-summary.md`
- (Path B only) `specs/101_locus_control_exhaustiveness/` task
  directory with description and minimal research pointer.

## Rollback/Contingency

- **Per-phase rollback**: each phase is scoped to a single logical
  commit; reverting returns the codebase to the prior phase.
- **Gate A failure (end of Phase 3)**: task 99's deliverables do not
  match their summary; file a defect report and escalate. Do not
  proceed.
- **Gate B failure (end of Phase 5)**: halt, keep Phases 3/4 committed,
  and open a new research round targeting the stricter-seed
  obligation. **Do not introduce an axiom to close the gap.**
- **Gate C — Path B chosen**: follow Phase 6 Path B tasks; task 98
  closes as `[PARTIAL]` with 6 of 10 sorries retired and 4 deferred to
  task 101. This is a zero-debt-compliant resolution (no axioms).
- **Total-effort overrun (>135h)**: force Gate C Path B regardless of
  proof progress.
- **Baseline recovery**: if all else fails, `git reset` to the
  task-99-complete commit and mark task 98 `[BLOCKED]` pending a
  fresh research round.
