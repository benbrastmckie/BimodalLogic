# Implementation Plan: Local Hintikka-Set Quasimodel for Until/Since Truth Lemma (v2)

- **Task**: 98 - research_filtration_quasimodel_pivot
- **Status**: [NOT STARTED]
- **Effort**: 20-35 hours
- **Dependencies**: None (independent of tasks 96, 97; parallel research track)
- **Research Inputs**:
  - specs/098_research_filtration_quasimodel_pivot/reports/01_filtration-quasimodel-pivot.md
  - specs/098_research_filtration_quasimodel_pivot/reports/02_team-research.md
- **Artifacts**: plans/02_quasimodel-pivot-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4

## Overview

This revised plan restructures phases 4-5 of the quasimodel implementation to address the bx_le guard-lifting obstruction confirmed by round 2 team research. The original approach attempted to prove Until/Since guards at the BXPoint level using bx_le propagation, which is structurally impossible because bx_le (defined as g_content subset) only propagates G-formulas, not arbitrary formulas. The revised approach proves guards at the Hintikka level (trivial from `hintikka_step` definition), realizes the chain to BXPoints via enriched Lindenbaum seeds, and transfers guard membership via `sigma_signature_mem`. Phases 1-3 and 6 are preserved as-is. Definition of done: `lake build` succeeds with the four Until/Since sorries in Frame.lean replaced by proofs, and no new sorries introduced.

### Research Integration

Reports integrated into this plan revision:

- **01_filtration-quasimodel-pivot.md** (round 1): Established local quasimodel approach, zero cascade cost, identified realization lifting and locus-control as load-bearing lemmas. Integrated in plan v1.
- **02_team-research.md** (round 2, 4 teammates): Confirmed bx_le non-totality is wrong diagnosis; real issue is arbitrary formula propagation. Showed `hintikka_step` has Until persistence built in (guard trivial at Hintikka level). Identified combined seed consistency as sole remaining hard sub-problem. All 5 alternative approaches fail. Motivates full restructure of phases 4-5.

## Goals & Non-Goals

**Goals**:
- Restructure Realization.lean to prove guards at the Hintikka level, not the BXPoint level
- Build defect-discharge chain using `hintikka_step` from Construction.lean (guard trivial from third clause)
- Realize Hintikka chain to BXPoints via enriched Lindenbaum seeds (combined seed consistency)
- Transfer guard from Hintikka points to BXPoints via `sigma_signature_mem`
- Close the four sorry targets in Frame.lean: `bx_until_eventuality_resolution`, `bx_until_backward`, `bx_since_eventuality_resolution`, `bx_since_backward`
- Maintain `lake build` clean with zero new sorries

**Non-Goals**:
- Modifying phases 1-3 (SubformulaClosure, HintikkaPoint, Construction -- all sorry-free)
- Modifying any existing sorry-free theorem in Frame.lean (lines 140-583)
- Modifying TruthLemma.lean G/H/Box cases
- Changing the `bx_le` definition (cascade cost too high, per round 2 research)
- Adding new BX axioms (all candidates unsound over general linear orders)
- Building the TaskModel embedding (task 93)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Combined seed consistency fails: `h_i.formulas union g_content(v_{i-1}.formulas)` is inconsistent | H | Low (15%) | The enriched_seed_consistent lemmas are already sorry-free. The chain construction reuses the same seed pattern. Gate check at end of Phase 4. |
| Sigma-closure too small for sigma_signature round-trip | M | Low (10%) | SubformulaClosure already includes G/H enrichment and negation pairing. Verify round-trip property early in Phase 4. |
| Since standalone construction harder than mirror | M | Medium (25%) | Budget dedicated sub-phase for Since. H-propagation and backward ordering differ structurally from Until. |
| Hintikka chain construction needs explicit well-founded recursion | M | Low (15%) | Use Fintype.card bound on HintikkaPoint Sigma as termination measure. Defect_count decreases at each step. |
| LocusControl.lean needs sigma_signature equality, not just membership | M | Low (10%) | Use locally_maximal property of HintikkaPoint to get full equality from subset. |

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

Phases within the same wave can execute in parallel.

---

### Phase 1: Sigma-Closure Infrastructure [COMPLETED]

**Goal**: Define the finite subformula closure type and prove its closure operations.

**Tasks**:
- [x] Create `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/SubformulaClosure.lean`
- [x] Define `SubformulaClosure` with subformula extraction, G/H enrichment, negation pairing
- [x] Prove membership lemmas: `target_mem`, `neg_of_base_mem`, `subformula_mem`, `g_enrichment_mem`, `h_enrichment_mem`
- [x] Prove `neg_pairing`: negation closure property for Hintikka maximality
- [x] Verify `lake build` succeeds

**Timing**: 3-5 hours
**Depends on**: none
**Completed**: 2026-04-10

---

### Phase 2: HintikkaPoint Definition and Properties [COMPLETED]

**Goal**: Define Hintikka points over a Sigma-closure with local consistency, maximality, and the sigma_signature projection from BXPoints.

**Tasks**:
- [x] Create `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/HintikkaPoint.lean`
- [x] Define `HintikkaPoint` structure with `formulas`, `subset_sigma`, `locally_consistent`, `bot_free`, `locally_maximal`
- [x] Prove `DecidableEq` for HintikkaPoint
- [x] Define `sigma_signature` and `sigma_signature_formulas`
- [x] Prove `sigma_signature_mem`: `f in sigma_signature w Sigma h_neg <-> f in Sigma and f in w.formulas`
- [x] Prove `sigma_signature_consistent`, `sigma_signature_bot_free`, `sigma_signature_maximal`
- [x] Verify `lake build` succeeds

**Timing**: 4-6 hours
**Depends on**: 1
**Completed**: 2026-04-10

---

### Phase 3: Quasimodel Construction with Defect-Discharge [COMPLETED]

**Goal**: Define the `hintikka_step` relation and MCS-level lemmas for BX axioms (BX4, BX5, BX8, BX9, BX10 and their Since duals).

**Tasks**:
- [x] Create `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/Construction.lean`
- [x] Define `hintikka_step` with G-propagation, H-backward, and Until defect propagation
- [x] Define `UntilDefect`, `SinceDefect`, `defect_count`
- [x] Prove MCS-level lemmas: `until_elim_mcs`, `self_accum_mcs`, `until_F_mcs`, `connect_future_mcs`, `refl_intro_until_mcs`
- [x] Prove Since duals: `since_elim_mcs`, `self_accum_since_mcs`, `since_P_mcs`, `connect_past_mcs`, `refl_intro_since_mcs`
- [x] Verify `lake build` succeeds

**Timing**: 6-10 hours
**Depends on**: 2
**Completed**: 2026-04-10

---

### Phase 4: Hintikka-Level Chain and Realization Lifting [NOT STARTED]

**Goal**: Restructure Realization.lean to prove Until/Since guards at the Hintikka level (trivial from `hintikka_step` definition), construct the defect-discharge chain explicitly, and realize it to BXPoints. This replaces the previous approach that attempted guard proofs at the BXPoint level via bx_le.

**Tasks**:

*Sub-phase 4a: Hintikka-level defect-discharge chain*
- [ ] Define `hintikka_chain` type: a `List (HintikkaPoint Sigma)` with `hintikka_step` between consecutive elements
- [ ] Prove `hintikka_chain_guard`: for all intermediate points h_i (i < k), if `(phi U psi) in h_0.formulas` and `psi not_in h_0.formulas`, then `phi in h_i.formulas` -- follows directly from `hintikka_step`'s third clause by induction on chain length
- [ ] Prove `hintikka_chain_witness`: `psi in h_k.formulas` at the endpoint
- [ ] Prove `hintikka_chain_exists`: given `UntilDefect h0 phi psi`, construct the chain using well-founded recursion on `defect_count` (bounded by `Fintype.card (HintikkaPoint Sigma)`)

*Sub-phase 4b: Chain realization via enriched Lindenbaum seeds*
- [ ] Define `realize_chain_step`: given BXPoint `v_i` realizing `h_i` and `hintikka_step h_i h_{i+1}`, construct BXPoint `v_{i+1}` realizing `h_{i+1}` with `bx_le v_i v_{i+1}`
  - The enriched seed is `h_{i+1}.formulas union g_content(v_i.formulas)`
  - Consistency proof reuses the pattern from `enriched_seed_consistent_until` (already sorry-free)
  - Key: `hintikka_step` guarantees `G(chi) in h_i -> chi in h_{i+1}`, which aligns with `g_content(v_i) subset v_{i+1}`
- [ ] Prove `realize_chain_step_sigma`: the realized BXPoint has `sigma_signature` equal to `h_{i+1}`
  - Forward: `f in h_{i+1}.formulas and f in Sigma -> f in v_{i+1}.formulas` (from seed inclusion)
  - Backward: `f in Sigma and f in v_{i+1}.formulas -> f in h_{i+1}.formulas` (from local maximality + consistency)
- [ ] Prove `realize_chain_step_bx_le`: `bx_le v_i v_{i+1}` follows from `g_content(v_i) subset v_{i+1}.formulas`
- [ ] Lift entire chain: `realize_full_chain` producing `v_0, ..., v_k` with `bx_le v_i v_{i+1}` for all i

*Sub-phase 4c: Guard transfer from Hintikka to BXPoint*
- [ ] Prove `guard_transfer`: for each intermediate BXPoint v_i, `phi in h_i.formulas` implies `phi in v_i.formulas` via `sigma_signature_mem` (since phi is in Sigma by subformula closure)
- [ ] Prove `witness_transfer`: `psi in h_k.formulas` implies `psi in v_k.formulas` by the same mechanism
- [ ] **GATE CHECK**: If realize_chain_step's consistency proof or sigma_signature round-trip fails, HALT and report

**Timing**: 8-12 hours

**Depends on**: 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/Realization.lean` -- complete rewrite of sorry-bearing functions; preserve enriched_seed_consistent_until/since and helper lemmas (F_of_mem, P_of_mem, F_from_above)

**Verification**:
- `lake build` succeeds
- No sorries in Realization.lean
- Gate check passed: realize_chain_step and sigma_signature round-trip proved

---

### Phase 5: Until/Since Sorry Closure and Frame.lean Integration [NOT STARTED]

**Goal**: Assemble the full proofs for the four sorry targets using the Hintikka chain + realization + guard transfer infrastructure from Phase 4, then wire them into Frame.lean.

**Tasks**:

*Sub-phase 5a: Until forward (Frame.lean:653)*
- [ ] Prove `until_eventuality_resolution` using the new architecture:
  1. Build `SubformulaClosure (Formula.untl phi psi)` as Sigma
  2. Extract `h0 = sigma_signature w Sigma` (a HintikkaPoint with `UntilDefect h0 phi psi`)
  3. Apply `hintikka_chain_exists` to get Hintikka chain `h0, ..., hk`
  4. Realize starting from `w` as `v0 = w`: apply `realize_full_chain` to get `v0, ..., vk`
  5. Guard: `phi in v_i.formulas` for i < k via `guard_transfer`
  6. Witness: `psi in v_k.formulas` via `witness_transfer`
  7. Locus-control for arbitrary strict-interval points u: use sigma_signature projection of u into the Hintikka chain to transfer the guard

*Sub-phase 5b: Until backward (Frame.lean:675)*
- [ ] Prove `until_backward` using contradiction + enriched seed:
  1. Assume `neg(phi U psi) in w`
  2. Build u via enriched Lindenbaum seed (enriched_seed_consistent_until, already sorry-free)
  3. Obtain `bx_le w u` and `bx_le u v` and `neg(phi U psi) in u`
  4. Show `psi in u` from `bx_le u v` and `psi in v` (via F_from_above + refl_intro_until_mcs)
  5. Contradiction: `phi U psi in u` (from refl_intro_until_mcs on psi) vs `neg(phi U psi) in u`

*Sub-phase 5c: Since forward (Frame.lean:690)*
- [ ] Prove `since_eventuality_resolution` as standalone (not dual of Until):
  - Mirror architecture using `h_content`, `bx_backward_witness`, H-propagation
  - Build Since-specific Sigma-closure, Since defect-discharge chain
  - Realize using enriched seed `h_{i-1}.formulas union h_content(v_i.formulas)`
  - Transfer guard via `sigma_signature_mem`

*Sub-phase 5d: Since backward (Frame.lean:704)*
- [ ] Prove `since_backward` standalone using enriched_seed_consistent_since

*Sub-phase 5e: Wire into Frame.lean*
- [ ] Update LocusControl.lean to call the new sorry-free functions
- [ ] Replace 4 sorries in Frame.lean with calls to LocusControl.lean exports
- [ ] Verify `lake build` succeeds with zero new sorries

**Timing**: 6-12 hours

**Depends on**: 4

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/Realization.lean` -- sorry-free proofs
- `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/LocusControl.lean` -- updated wrappers
- `Theories/Bimodal/Metalogic/BXCanonical/Frame.lean` -- replace 4 sorries with proof terms

**Verification**:
- `lake build` succeeds
- `grep -rn "sorry" Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/` returns zero matches
- Frame.lean sorries at lines 653, 675, 690, 704 replaced
- `#check @bx_until_eventuality_resolution` and `#check @bx_since_eventuality_resolution` succeed

---

### Phase 6: Integration, Build Verification, and Regression [COMPLETED]

**Goal**: Wire the Quasimodel module into the BXCanonical import hierarchy, verify no regressions, and confirm sorry count reduction.

**Tasks**:
- [x] Verify `Theories/Bimodal/Metalogic/BXCanonical/BXCanonical.lean` imports Quasimodel submodules
- [x] Run `lake clean && lake build` for full clean build
- [x] Verify Frame.lean lines 140-583 (Box/G/H layer) unchanged via `git diff`
- [x] Verify TruthLemma.lean unchanged via `git diff`
- [x] Verify active-path sorry count reduced from 6 to 2
- [x] Confirm no regressions in sorry-free theorems

**Timing**: 2-4 hours
**Depends on**: 4, 5
**Completed**: 2026-04-10

## Testing & Validation

- [ ] `lake build` succeeds after each phase
- [ ] `lake clean && lake build` succeeds after Phase 5
- [ ] `grep -rn "sorry" Theories/Bimodal/Metalogic/BXCanonical/` shows exactly 2 sorries (bx_modal_witness, bx_completeness)
- [ ] Frame.lean lines 140-583 unchanged (verified by git diff)
- [ ] TruthLemma.lean unchanged (verified by git diff)
- [ ] `#check @bx_until_eventuality_resolution` type-checks without sorry
- [ ] `#check @bx_since_eventuality_resolution` type-checks without sorry
- [ ] `#check @bx_until_backward` type-checks without sorry
- [ ] `#check @bx_since_backward` type-checks without sorry
- [ ] Phase 4 gate check passed (chain realization and sigma_signature round-trip proved)

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/SubformulaClosure.lean` -- Phase 1 (unchanged)
- `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/HintikkaPoint.lean` -- Phase 2 (unchanged)
- `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/Construction.lean` -- Phase 3 (unchanged)
- `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/Realization.lean` -- Phase 4 (restructured)
- `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/LocusControl.lean` -- Phase 5 (updated)
- `Theories/Bimodal/Metalogic/BXCanonical/Frame.lean` -- Phase 5 (4 sorries replaced)
- `specs/098_research_filtration_quasimodel_pivot/plans/02_quasimodel-pivot-plan.md` -- this plan
- `specs/098_research_filtration_quasimodel_pivot/summaries/02_quasimodel-pivot-summary.md` -- post-implementation

## Rollback/Contingency

- **Phase 4 gate failure (chain realization)**: If combined seed consistency at the chain level fails or sigma_signature round-trip cannot be proved, HALT and report. The enriched_seed_consistent lemmas are sorry-free, so the gap would be specifically in lifting from single-step to chain-level realization. Escalate to global quasimodel fallback (40-60h) or investigate whether Sigma-closure needs additional formulas.
- **Since standalone failure (Phase 5c)**: If Since requires infrastructure not parallel to Until (e.g., different seed structure for H-propagation), halt Since half and escalate. Until can land independently, closing 2 of 4 sorries.
- **Build regression**: If any existing sorry-free proof breaks, immediately `git checkout` the affected file. The quasimodel module is downstream of Frame.lean; regressions would indicate import or instance issues.
- **Full rollback**: `git revert` the implementation commits. Quasimodel/ directory is self-contained.
