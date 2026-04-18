# Implementation Plan: Quasimodel BFMCS (Path B) with Round-Robin Cleanup

- **Task**: 93 - Complete BXCanonical embedding
- **Status**: [NOT STARTED]
- **Effort**: 12 hours
- **Dependencies**: Task 92 (truth lemma sorry-free)
- **Research Inputs**: reports/40_team-research.md, reports/39_team-research.md
- **Artifacts**: plans/40_bxcanonical-embedding.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

This plan implements Path B from the round-40 research: build a new `qm_bfmcs` construction that bypasses `dd_fmcs` entirely, making restricted_tc hold BY CONSTRUCTION via the quasimodel oracle step. The existing round-robin `rr_fwd_chain` / `dd_chain` architecture is confirmed dead by all four research teammates -- the perpetual deferral obstruction is an artifact of the wrong proof strategy, not a fundamental limitation. Before any implementation, Phase 1 archives all dead round-robin code to `Boneyard/` and Phase 2 validates derived rules by semantic counter-model, following the process-improvement recommendation. Definition of done: `lake build` succeeds and `#print axioms bx_completeness` lists only `propext`, `Classical.choice`, `Quot.sound`.

### Research Integration

- **Report 40** (team, 4 teammates): Confirmed v39 obstacle is semantically invalid. Round-robin architecture is fundamentally wrong. Path B (quasimodel BFMCS, ~800 LOC, 55% confidence) is the literature-aligned correct approach. Vacuous interval guard for integers simplifies restricted_fuc. Critical precondition: `until_defects_seed_consistent`.
- **Report 39** (team, 4 teammates): Corrected seed consistency argument -- Until defects bypass G-lifting via subset-of-MCS argument. Oracle approach was abandoned on false blocker.

### Prior Plan Reference

**Plan v39** (Quasimodel Oracle with Corrected Seed Consistency): Estimated 10 hours, structured around 5 sequential waves. Phase 1 (restricted_buc via Until introduction derived rule) was BLOCKED because `phi /\ F(phi U psi) -> phi U psi` is semantically invalid. Phase 2 onward never executed. Key lessons: (1) validate derived rules by counter-model BEFORE implementation; (2) direct coherence on dd_bfmcs is blocked by the round-robin alignment problem; (3) the quasimodel infrastructure (`hintikka_chain_exists`, `defect_count`, `SubformulaClosure_untl_closed`) is sorry-free and correct. Effort calibration: prior plans estimated 6-10 hours and blocked in Phase 1 -- this plan front-loads validation and cleanup to avoid that pattern.

### Roadmap Alignment

No ROADMAP.md found.

## Goals & Non-Goals

**Goals**:
- Archive all dead round-robin code (`rr_fwd_chain`, `enriched_fwd_step`, `discharge_fwd_chain`, `defect_fwd_chain`, `defect_bwd_chain`) to `Boneyard/`
- Validate key derived rules by semantic counter-model before implementation
- Build `qm_oracle_step` producing a successor MCS with all Until defects propagated or resolved
- Build `qm_fmcs` as an Int-indexed FMCS from oracle step iteration
- Build `qm_bfmcs` as a BFMCS from box-equivalent `qm_fmcs` families
- Close `dd_bfmcs_restricted_tc`, `dd_bfmcs_restricted_buc`, `dd_bfmcs_restricted_fuc` (or their renamed `qm_bfmcs` equivalents)
- Achieve sorry-free `bx_completeness`

**Non-Goals**:
- Preserving backward compatibility with the dd_chain/rr_fwd_chain architecture (it is dead)
- Path A (defect_fwd_chain induction) -- superseded by Path B
- Dense completeness (separate task 68)
- Closing dead-code sorry sites unreachable from `bx_completeness`

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `until_defects_seed_consistent` has subtle gap | H | M (25%) | Validate informally with pencil-and-paper proof in Phase 2. The subset-of-MCS argument is straightforward but needs formal verification. |
| `hintikka_step` H-backward clause unsatisfied by `bx_le` | H | M (30%) | Phase 2 validates whether `bx_le w v` gives `h_content(v) <= w`. If not, use forward-only hintikka_step variant. |
| Vacuous interval guard argument fails for restricted_fuc | M | L (15%) | The argument is mathematically clean: no integers strictly between t and t+1. Formal proof is straightforward omega. |
| `qm_fmcs` box content diverges from root MCS | H | L (10%) | All families constructed via `bx_le` from same root, so box content propagates via `g_content`. Verify in Phase 4. |
| Boneyard archival breaks imports | M | M (30%) | Phase 1 includes a `lake build` verification. Keep Boneyard files importable but not imported by main modules. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2 | -- |
| 2 | 3 | 2 |
| 3 | 4 | 3 |
| 4 | 5 | 4 |
| 5 | 6 | 5 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Archive Dead Round-Robin Code to Boneyard [COMPLETED]

**Goal**: Remove all dead round-robin chain infrastructure from the active codebase to eliminate future distraction. Move to `Boneyard/` directory for historical reference.

**Tasks**:
- [ ] Create `Theories/Bimodal/Metalogic/BXCanonical/Boneyard/` directory
- [ ] Identify all round-robin-specific definitions and theorems in `RootScopedChain.lean`: `rrSchedule`, `rr_fwd_seed`, `rr_fwd_chain`, `rr_fwd_chain_*` theorems, `enriched_fwd_step`, `enriched_fwd_step_*` theorems, `discharge_fwd_chain`, `discharge_fwd_chain_*` theorems, `defect_fwd_chain`, `defect_fwd_chain_*` theorems, `defect_bwd_chain`, `defect_bwd_chain_*` theorems, `f_nesting_depth`, `activeDefects`, `dd_fmcs_forward_F`, `dd_fmcs_backward_P`, `rr_fwd_chain_forward_F*`
- [ ] Extract dead code into `Boneyard/RoundRobinChain.lean` (preserving original structure for reference)
- [ ] Update `RootScopedChain.lean` to remove dead code, keeping only: `dd_chain` definition (needed until replaced), `dd_fmcs`, `dd_bfmcs`, the three sorry theorems, `dd_countermodel`, and the Lindenbaum infrastructure
- [ ] Add header comment to `Boneyard/RoundRobinChain.lean` documenting why this code is archived (round 40 research confirmation)
- [ ] Verify `lake build` succeeds after archival
- [ ] Update any comments in active files that reference round-robin approaches

**Timing**: 1.5 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` -- remove dead code
- `Theories/Bimodal/Metalogic/BXCanonical/Boneyard/RoundRobinChain.lean` -- new file, archived code

**Verification**:
- `lake build` succeeds
- `RootScopedChain.lean` has no references to `rr_fwd_chain`, `enriched_fwd_step`, etc.
- All sorry sites at lines 1517, 1522, 1527 remain in place (they are the live targets)

---

### Phase 2: Validate Derived Rules and Key Lemmas [COMPLETED]

**Goal**: Before any implementation, validate the mathematical preconditions by semantic counter-model analysis and pencil-and-paper proof. This addresses the systematic process failure identified in round 40 research.

**Tasks**:
- [x] **Validate `bx_le` gives h_content backward**: PASS. `g_content_subset_implies_h_content_reverse` (WitnessSeed.lean:511) proves bx_le w v implies h_content(v) ⊆ w. Full hintikka_step (G-forward + H-backward) is valid.
- [x] **Validate Until introduction rule is NOT needed**: PASS. qm_bfmcs uses BX8+BX7+oracle guard, NOT the invalid `phi /\ F(phi U psi) -> phi U psi` rule.
- [x] **Pencil-proof `until_defects_seed_consistent`**: PASS. Oracle seed ⊆ M.formulas by: g_content ⊆ M by BX1 reflexivity; Until-defects ⊆ M by definition. MCS consistency discharges any subset inconsistency.
- [x] **Validate vacuous interval guard**: PASS. `omega` proves: `(t ≤ r ∧ r < t + 1 → r = t)` and `(t < r ∧ r < t + 1 → False)` for integers. Single-step guard reduces to phi ∈ mcs(t) only.
- [x] **Validate `SubformulaClosure_untl_closed`**: PASS. `SubformulaClosure_untl_closed` (Realization.lean:586) is sorry-free and proves both φ ∈ Sigma and ψ ∈ Sigma from `φ U ψ ∈ Sigma`.
- [x] **Design decision**: DECIDED. Modify `dd_bfmcs` in place; reuse `dd_countermodel` wiring. Do not create separate `qm_bfmcs` type.

**Timing**: 1.5 hours

**Depends on**: none

**Files to modify**:
- No files modified (validation phase, comments and design decisions documented in-line)
- `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/Realization.lean` -- possibly inspect existing proofs

**Verification**:
- Each validation item has a clear PASS/FAIL with documented evidence
- Design decision for qm_bfmcs integration strategy is recorded
- Any FAIL items have documented alternatives

---

### Phase 3: Build `qm_oracle_step` and Prove Seed Consistency [PARTIAL]

**Goal**: Implement the oracle step that, given an MCS M with Until defects, produces a successor MCS M' where all Until defects are either propagated or resolved. Prove the seed consistency lemma.

**Tasks**:
- [ ] **Define `qm_oracle_seed`**: Given MCS M and sigma_list, the seed is `g_content(M) U {f | f U g in M, g not in M, f U g in sigma_list}`. This includes all g_content (forward propagation) plus all active Until defects (defect propagation).
- [ ] **Prove `qm_oracle_seed_subset_mcs`**: Show the seed is a subset of M.formulas. g_content(M) subset M by BX1 reflexivity (G(phi) -> phi). Until defects: if `f U g in M` and `g not in M`, then by BX9 (Until elimination), `f in M`. So the Until-defect guard `f` is already in M. The Until formula `f U g` itself is in M. Both are subsets of M.formulas.
- [ ] **Prove `qm_oracle_seed_consistent`**: From `qm_oracle_seed_subset_mcs`, any finite subset of the seed is a subset of M.formulas, so consistency follows from MCS consistency. This is a one-line proof via `chain_step_seed_consistent` pattern.
- [ ] **Define `qm_oracle_step`**: Apply Lindenbaum extension to `qm_oracle_seed` to get a new MCS. The extension is guaranteed to exist by seed consistency.
- [ ] **Prove `qm_oracle_step_g_content`**: Show `g_content(M) <= qm_oracle_step(M)`. This follows from the seed containing g_content and Lindenbaum extension preserving the seed.
- [ ] **Prove `qm_oracle_step_defect_propagation`**: Show that for each Until defect `f U g` in M (with `g not in M`), either `g in qm_oracle_step(M)` or `f U g in qm_oracle_step(M)`. The seed includes `f U g` (the Until formula itself for non-resolved defects) and `f` (the guard). By Lindenbaum, these are in M'. If `g in M'`, resolved. If `g not in M'`, then `f U g in M'` (from seed), so propagated.
- [ ] **Discharge `HintikkaStepOracle`**: Using `qm_oracle_step`, construct the `WitnessedHintikka` and prove `hintikka_step`. The G-propagation clause follows from `qm_oracle_step_g_content`. The Until-propagation clause follows from `qm_oracle_step_defect_propagation`. The H-backward clause needs the Phase 2 validation result -- if `bx_le` does not give h_content backward, use a forward-only variant or add h_content to the seed.

**Timing**: 3 hours

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/OracleStep.lean` -- new file, oracle step construction
- `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/Realization.lean` -- HintikkaStepOracle discharge

**Verification**:
- `qm_oracle_seed_consistent` compiles without sorry
- `HintikkaStepOracle` for `SubformulaClosure(root)` compiles without sorry
- `hintikka_chain_exists` can be instantiated with the discharged oracle
- `lake build` succeeds

---

### Phase 4: Build `qm_fmcs` and `qm_bfmcs` [NOT STARTED]

**Goal**: Construct an Int-indexed FMCS from oracle step iteration and wrap it in a BFMCS. restricted_tc holds BY CONSTRUCTION because the oracle resolves F-obligations directly.

**Tasks**:
- [ ] **Define `qm_fmcs`**: An FMCS indexed by Int.
  - `mcs(0) = M0` (starting MCS)
  - `mcs(n+1) = qm_oracle_step(mcs(n))` for n >= 0
  - `mcs(-n-1) = qm_oracle_step_bwd(mcs(-n))` for the backward direction (symmetric construction using `bx_since_eventuality_resolution`)
  - Prove `qm_fmcs` satisfies FMCS axioms: `g_content(mcs(t)) <= mcs(t+1)` (from oracle_step_g_content) and each `mcs(t)` is MCS.
- [ ] **Define `qm_oracle_step_bwd`**: Backward analog of `qm_oracle_step` using `h_content` and Since defects. The seed is `h_content(M) U {Since-defects of M}`.
- [ ] **Prove `qm_fmcs_h_content`**: Show `h_content(mcs(t+1)) <= mcs(t)`. This requires the backward direction. Two approaches: (a) if `bx_le` gives h_content backward, this follows from oracle construction; (b) if not, add h_content to the oracle seed or use the backward oracle step at even positions.
- [ ] **Define `qm_bfmcs`**: BFMCS where `families = { qm_fmcs N sigma_list | N box-equivalent to M0 }`. Box-equivalence means `forall psi, Box(psi) in M0 <-> Box(psi) in N`.
- [ ] **Prove `qm_bfmcs` satisfies BFMCS axioms**: Box saturation (inherited from `dd_bfmcs` pattern), Diamond witnessing.
- [ ] **Prove `qm_bfmcs_restricted_tc`**: Given `F(psi) in fam.mcs(t)`, by `bx_until_eventuality_resolution` get BXPoint v with `psi in v.formulas`. The oracle step at time t uses `qm_oracle_step` which includes the F-defect in its seed. By Lindenbaum, psi appears at `mcs(t+1)` or propagates. By `hintikka_chain_exists` (from Phase 3), a finite chain resolves psi. The integer index gives the witness `s > t` with `psi in mcs(s)`.
- [ ] **Prove vacuous interval guard for restricted_fuc**: For `phi U psi in fam.mcs(t)`, by BX10 get `F(psi) in fam.mcs(t)`. By restricted_tc, get `s > t` with `psi in mcs(s)`. Set `s = t + k` for some positive k. The guard `forall r, t <= r -> r < t + 1 -> phi in mcs(r)` is vacuously true when k=1 (no integers between t and t+1). For k > 1, the guard at each step follows from the Hintikka chain guard property (`hintikka_chain_guard_step`).

**Timing**: 3 hours

**Depends on**: 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/OracleStep.lean` -- backward oracle step
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` -- replace `dd_bfmcs` with `qm_bfmcs`, prove restricted_tc

**Verification**:
- `qm_fmcs` compiles as valid FMCS
- `qm_bfmcs` compiles as valid BFMCS
- `qm_bfmcs_restricted_tc` compiles without sorry
- `lake build` succeeds

---

### Phase 5: Close restricted_buc and restricted_fuc [NOT STARTED]

**Goal**: Close the remaining two sorry sites using the qm_bfmcs construction.

**Tasks**:
- [ ] **Prove restricted_buc (backward Until coherence)**: Given witness `s >= t` with `psi in fam.mcs(s)` and guard `phi in fam.mcs(r)` for all `r in [t, s)`, show `phi U psi in fam.mcs(t)`. Induction on `s - t`:
  - Base case (s = t): `psi in mcs(t)`, so `phi U psi in mcs(t)` by BX8 (`refl_intro_until_mcs`).
  - Step case (s = t + k + 1): By IH, `phi U psi in mcs(t+1)`. Need `phi U psi in mcs(t)` from `phi in mcs(t)` and `phi U psi in mcs(t+1)`. Use backward F-propagation: `phi U psi in mcs(t+1)` implies `H(F(phi U psi)) in mcs(t+1)` by BX4. By h_content propagation, `F(phi U psi) in mcs(t)`. Now apply BX5 self-accumulation + BX6 absorption to derive `phi U psi in mcs(t)` from `phi in mcs(t)` and `F(phi U psi) in mcs(t)`.
- [ ] **Validate the BX5+BX6 derivation**: The key derived rule is: `phi in M, F(phi U psi) in M -> phi U psi in M`. Derivation: (1) BX12 gives `F(phi U psi) -> top U (phi U psi)`; (2) BX5 self-accumulation on `top U (phi U psi)` gives `(top /\ (top U (phi U psi))) U (phi U psi)`; (3) simplify guard; (4) BX6 absorption collapses nested Until. This needs careful verification -- attempt with `lean_multi_attempt` before committing.
- [ ] **If BX5+BX6 derivation fails**: Alternative approach using the qm_bfmcs chain structure directly. At each chain step, the oracle propagates Until defects. If `phi U psi in mcs(t+1)` and `phi in mcs(t)`, the h_content backward propagation gives `P(phi U psi) in mcs(t)`. Combine with `phi in mcs(t)` using BX temporal properties.
- [ ] **Prove restricted_buc for Since (symmetric)**: Mirror the Until proof using Since axioms.
- [ ] **Prove restricted_fuc (forward Until coherence)**: Given `phi U psi in fam.mcs(t)`:
  1. By BX10, `F(psi) in fam.mcs(t)`. By restricted_tc, get `s > t` with `psi in mcs(s)`.
  2. Guard: for all `r in [t, s)`, `phi in mcs(r)`. This follows from `hintikka_chain_guard_step`: at each intermediate point where `phi U psi` is present and `psi` is absent, `phi` is present. The oracle step propagates `phi U psi` at each step until `psi` appears.
  3. Wire through the integer-indexed FMCS.
- [ ] **Prove restricted_fuc for Since (symmetric)**
- [ ] **Close sorry at line 1517 (restricted_tc)** -- already done in Phase 4
- [ ] **Close sorry at line 1522 (restricted_buc)**
- [ ] **Close sorry at line 1527 (restricted_fuc)**

**Timing**: 2 hours

**Depends on**: 4

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` -- restricted_buc, restricted_fuc proofs

**Verification**:
- `dd_bfmcs_restricted_buc` (or renamed `qm_bfmcs_restricted_buc`) compiles without sorry
- `dd_bfmcs_restricted_fuc` (or renamed `qm_bfmcs_restricted_fuc`) compiles without sorry
- `dd_countermodel` compiles without sorry
- `lake build` succeeds

---

### Phase 6: Integration, Verification, and Cleanup [NOT STARTED]

**Goal**: Verify `bx_completeness` is sorry-free. Final cleanup and documentation.

**Tasks**:
- [ ] Verify `bx_completeness` compiles without sorry
- [ ] Run `#print axioms bx_completeness` and confirm only `propext`, `Classical.choice`, `Quot.sound`
- [ ] Annotate Boneyard files with cross-references to the new qm_bfmcs approach
- [ ] Add docstrings to new theorems explaining the mathematical argument
- [ ] Run full `lake build`
- [ ] Grep for remaining sorry in BXCanonical files; verify none reachable from `bx_completeness`
- [ ] Update any dead-code sorry annotations (lines 1413, 1457, 1464, 2196, 2289 are now in Boneyard)

**Timing**: 1 hour

**Depends on**: 5

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` -- docstrings
- `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/OracleStep.lean` -- docstrings
- `Theories/Bimodal/Metalogic/BXCanonical/Boneyard/RoundRobinChain.lean` -- cross-references

**Verification**:
- `lake build` succeeds
- `#print axioms bx_completeness` shows only `propext`, `Classical.choice`, `Quot.sound`
- No reachable sorry from `bx_completeness`

---

## Testing & Validation

- [ ] `lake build` succeeds after each phase
- [ ] `lean_verify` on `qm_oracle_seed_consistent` after Phase 3 -- no sorry dependency
- [ ] `lean_verify` on `HintikkaStepOracle` instantiation after Phase 3 -- no sorry dependency
- [ ] `lean_verify` on `qm_fmcs` after Phase 4 -- no sorry dependency
- [ ] `lean_verify` on `qm_bfmcs_restricted_tc` after Phase 4 -- no sorry dependency
- [ ] `lean_verify` on `qm_bfmcs_restricted_buc` after Phase 5 -- no sorry dependency
- [ ] `lean_verify` on `qm_bfmcs_restricted_fuc` after Phase 5 -- no sorry dependency
- [ ] `lean_verify` on `dd_countermodel` after Phase 5 -- no sorry dependency
- [ ] `lean_verify` on `bx_completeness` after Phase 6 -- only `propext`, `Classical.choice`, `Quot.sound`

## Artifacts & Outputs

- `specs/093_complete_bxcanonical_embedding/plans/40_bxcanonical-embedding.md` -- this plan
- `Theories/Bimodal/Metalogic/BXCanonical/Boneyard/RoundRobinChain.lean` -- archived dead code (Phase 1)
- `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/OracleStep.lean` -- oracle step construction (Phase 3)
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` -- cleaned up, sorry-free coherence proofs (Phases 4-5)
- `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/Realization.lean` -- HintikkaStepOracle discharge (Phase 3)

## Rollback/Contingency

1. **Phase 1 safe**: Boneyard archival is pure code movement. Rollback: move code back from Boneyard.

2. **Phase 2 validation fails**: If `bx_le` does not give h_content backward, modify `hintikka_step` to use forward-only G-propagation (drop H-backward clause). The `hintikka_chain_exists` theorem still works because the chain termination depends only on defect_count, not H-backward.

3. **Phase 3 seed consistency fails**: If the subset-of-MCS argument has a gap (e.g., Until defects require formulas not in M), fall back to the extended seed with `{psi_target} U g_content(M)` only (no Until defects). This reduces to `forward_temporal_witness_seed_consistent` which is already proved.

4. **Phase 5 BX5+BX6 derivation fails for restricted_buc**: Build restricted_buc via the quasimodel chain directly. The chain's constructive property (`hintikka_chain_guard_step` + witness at endpoint) gives the Until coherence condition directly, without needing a BX-level derived rule.

5. **Complete failure**: `git checkout -- Theories/Bimodal/Metalogic/BXCanonical/` restores current state. The Boneyard archival (Phase 1) can be preserved independently since it improves code organization regardless.
