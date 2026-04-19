# Implementation Plan: DD-BFMCS Scheduling Chain Coherence (Revised)

- **Task**: 93 - Complete BXCanonical embedding
- **Status**: [PARTIAL]
- **Effort**: 10 hours
- **Dependencies**: Task 92 (truth lemma sorry-free) -- satisfied
- **Research Inputs**: reports/41_team-research.md, reports/42_team-research.md
- **Artifacts**: plans/42_bxcanonical-embedding.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

This plan targets the three live sorry sites on the `dd_bfmcs` scheduling chain path: `dd_bfmcs_restricted_tc` (line 953), `dd_bfmcs_restricted_buc` (line 958), and `dd_bfmcs_restricted_fuc` (line 963). Phase 1 archives the unfinished oracle replacement code (qm_bfmcs construction) while preserving reusable oracle infrastructure (`qm_oracle_step`, `qm_oracle_step_bwd`, `hintikka_step_for_sigma_sig`). Phases 2-3 close restricted_tc and restricted_buc in parallel. Phase 4 closes restricted_fuc (depends on Phase 2). Phase 5 integrates and verifies sorry-free completeness. Definition of done: `lake build` succeeds and `#print axioms bx_completeness` lists only `propext`, `Classical.choice`, `Quot.sound`.

### Research Integration

- **Report 41** (team, 4 teammates): Confirmed `qm_bfmcs_restricted_*` and oracle chain machinery are not on the active proof path. Identified F-persistence in the scheduling chain via `defect_fwd_step_choice_spec` for closing `dd_bfmcs_restricted_tc`. Proposed enriched backward oracle seed for backward Until coherence. Confirmed `phi /\ F(phi U psi) -> phi U psi` is semantically invalid (all 4 teammates). Recommended 3-phase hybrid approach.

- **Report 42** (team, 4 teammates): Refined archival framing -- oracle infrastructure is "unfinished replacement abandoned at backward coherence obstruction," not "dead code." Confirmed F-persistence for ALL defects (very high confidence). Identified that enriched backward seed must target `bwd_pred` / `bwd_chain_of_sigma` (the actual dd_bfmcs backward construction), not `qm_oracle_seed_bwd`. Specified Reynolds induction approach for restricted_tc with concrete code references. Preserved `qm_oracle_step`, `qm_oracle_step_bwd`, `hintikka_step_for_sigma_sig` as reusable infrastructure.

### Prior Plan Reference

**Plan v41** (5 phases, 10 hours): Not started. Key lessons from v41 creation: (1) Phase 3 (restricted_buc) described the enriched backward seed approach targeting `qm_oracle_seed_bwd`, but the actual dd_bfmcs backward chain uses `bwd_pred` -> `bwd_chain_of_sigma`, which seeds with `h_content(M) union p_carry(M)` (non-resolving case) or `past_temporal_witness_seed(M, target)` = `{target} union h_content(M)` (resolving case). The enriched seed must be applied HERE, not to the oracle chain. (2) Phase 1 used "dead code" framing which mischaracterizes the oracle construction.

**Plan v40** (6 phases, 12 hours): Phases 1-4 partial. Built oracle chain infrastructure (qm_fmcs, qm_bfmcs) but hit backward coherence obstruction. Confirmed dd_countermodel still uses dd_bfmcs.

### Roadmap Alignment

- **Task 93** (ROAD_MAP.md): Close RootScopedChain.lean sorries (6 listed, 3 live + 3 dead on qm path)
- **Task 95**: `#print axioms` audit (depends on task 93)
- ROAD_MAP.md sorry inventory needs updating: line numbers are stale, and the 6-sorry count should be revised to 3 live + 9 dead (qm path)

## Goals & Non-Goals

**Goals**:
- Archive unfinished oracle replacement code (qm_fwd_chain, qm_bwd_chain, qm_chain, qm_fmcs, qm_bfmcs, qm_bfmcs_restricted_*) to Boneyard/ with accurate archival label
- Preserve reusable oracle infrastructure: `qm_oracle_step`, `qm_oracle_step_bwd`, `hintikka_step_for_sigma_sig` in OracleStep.lean (untouched)
- Update ROAD_MAP.md to reflect current sorry state (3 live sorries, not 6)
- Close `dd_bfmcs_restricted_tc` using Reynolds induction on defects.length with F-persistence from `defect_fwd_step_choice_spec`
- Close `dd_bfmcs_restricted_buc` using enriched backward seed applied to `bwd_pred` / `bwd_chain_of_sigma`
- Close `dd_bfmcs_restricted_fuc` using restricted_tc + BX9 guard argument
- Achieve sorry-free `bx_completeness`

**Non-Goals**:
- Closing sorry sites in `qm_bfmcs_restricted_*` (being archived)
- Closing OracleStep.lean sorry sites for general `HintikkaStepOracle` (oracle approach abandoned)
- Dense completeness (task 68)
- Deleting OracleStep.lean or its reusable building blocks (`qm_oracle_step`, `qm_oracle_step_bwd`, `hintikka_step_for_sigma_sig`)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `fwd_succ` does not preserve F-obligations for non-scheduled defects | H | M (30%) | `fwd_succ` uses seed `{target} union g_content(M)` (resolving case) or `g_content(M) union f_carry(M)` (non-resolving case). `f_carry` carries all `F(chi)` formulas from M. So F-obligations are preserved in the non-resolving case. For the resolving case, `g_content(M)` carries `G(F(chi))` only if `F(chi)` is a G-theorem. Alternative: use `defect_fwd_step_choice_spec` which explicitly preserves all F(chi) for defects. |
| Enriched backward seed for `bwd_pred` breaks existing h_content proofs | M | L (15%) | The enrichment adds Until-formulas to the backward seed. Since Until-formulas are already in M (subset property), seed consistency is trivial. Create `bwd_pred_enriched` as a separate function if modifying `bwd_pred` risks breakage. |
| Guard argument for restricted_fuc requires Until-persistence across scheduling steps | H | M (25%) | The scheduling chain's `fwd_succ` carries `f_carry(M)` which includes `F(chi)` but NOT `phi U psi` directly. Until-persistence needs enrichment of the forward seed or a separate argument via `defect_fwd_step_choice_spec` + BX axioms. |
| Boneyard archival breaks imports or removes needed definitions | M | L (10%) | Archive only qm_fwd_chain through qm_bfmcs_restricted_fuc (lines 1484-end). Keep `defect_fwd_step_choice*` (lines 1460-1482). Keep OracleStep.lean entirely. Verify with `lake build`. |
| restricted_buc backward step transfer still invalid for scheduling chain | H | M (20%) | Report 42 clarifies: `bwd_pred` uses `past_temporal_witness_seed(M, target) = {target} union h_content(M)` (resolving) or `h_content(M) union p_carry(M)` (non-resolving). Neither carries Until-formulas. The enrichment adds `{phi U psi | phi U psi in M, phi U psi in Sigma}` to the backward seed. This makes backward Until step transfer hold BY CONSTRUCTION since `phi U psi` is in the seed and survives Lindenbaum extension. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 3 | 1 |
| 3 | 4 | 2 |
| 4 | 5 | 3, 4 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Archive Unfinished Oracle Replacement and Update ROAD_MAP.md [COMPLETED]

**Goal**: Archive the qm_bfmcs construction from RootScopedChain.lean with the accurate label "unfinished oracle replacement, abandoned at backward coherence obstruction." Preserve reusable oracle infrastructure in OracleStep.lean.

**Tasks**:
- [ ] Archive dead code in RootScopedChain.lean: everything from line 1484 (`/-! ## Oracle-Based FMCS Construction (Phase 4)`) through end of `qm_bfmcs_restricted_fuc`. This includes:
  - `qm_fwd_chain`, `qm_bwd_chain`, `qm_chain` (oracle chain definitions)
  - `qm_fmcs`, `qm_bfmcs` (oracle FMCS/BFMCS)
  - `qm_fwd_chain_mcs`, `qm_bwd_chain_mcs`, `qm_chain_mcs` (MCS properties)
  - `qm_fwd_chain_g_content`, `qm_bwd_chain_h_content` (content propagation)
  - `qm_fwd_chain_until_persists`, `qm_bwd_chain_since_persists` (eventuality propagation)
  - `qm_bfmcs_restricted_tc`, `qm_bfmcs_restricted_buc`, `qm_bfmcs_restricted_fuc` (coherence sorries)
  - `F_phi_gives_top_until_defect` if present
- [ ] Archive to `Boneyard/OracleCoherence.lean` with header comment:
  ```
  /-! # Oracle-Based FMCS Coherence (Archived)

  Unfinished oracle replacement for dd_bfmcs, abandoned at backward coherence
  obstruction. The backward step transfer `phi /\ F(phi U psi) -> phi U psi` is
  semantically invalid, blocking qm_bfmcs_restricted_buc.

  Built as Plan v40 Phases 3-4 deliverable (2026-04-18). The oracle chain
  infrastructure in OracleStep.lean (qm_oracle_step, qm_oracle_step_bwd,
  hintikka_step_for_sigma_sig) is preserved as reusable infrastructure.
  -/
  ```
- [ ] DO NOT modify OracleStep.lean -- `qm_oracle_step`, `qm_oracle_step_bwd`, and `hintikka_step_for_sigma_sig` remain as reusable infrastructure
- [ ] Keep `defect_fwd_step_choice` and `defect_fwd_step_choice_spec` (lines 1460-1482) -- these are on the live path for restricted_tc
- [ ] Keep all helper lemmas before line 1484 (P_and_self_P, defect_step_from_earliest, etc.)
- [ ] Update ROAD_MAP.md:
  - Change sorry count from 6 to 3 (dd_bfmcs_restricted_tc/buc/fuc)
  - Update line numbers to current values (953, 958, 963)
  - Remove stale references to round-robin era sorries
  - Add note: "Oracle replacement approach (qm_bfmcs) archived -- hit backward coherence obstruction"
  - Update "Current Strategy" section to reflect scheduling chain approach with Reynolds induction + enriched backward seed
- [ ] Verify `lake build` succeeds after archival

**Timing**: 1.5 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` -- remove qm_* construction (lines 1484-end)
- `Theories/Bimodal/Metalogic/BXCanonical/Boneyard/OracleCoherence.lean` -- new file, archived oracle construction
- `specs/ROAD_MAP.md` -- update sorry inventory, strategy description, line numbers

**Verification**:
- `lake build` succeeds
- `grep -c 'sorry' RootScopedChain.lean` shows exactly 3 (lines 953, 958, 963)
- ROAD_MAP.md sorry table lists exactly 3 active-path sorries
- OracleStep.lean is untouched
- No definition referenced by `dd_countermodel` was removed

---

### Phase 2: Close dd_bfmcs_restricted_tc (Reynolds Induction on Defects) [PARTIAL]

**Goal**: Prove that F-eventualities are eventually resolved in the scheduling chain using Reynolds' induction on `defects.length`.

**Strategy**: The key infrastructure is already in place:
- `defect_fwd_step_choice_spec` (lines 1472-1481) provides F-persistence: `forall chi in defects, F(chi) in M'`. This means ALL F-obligations from the defects list persist through each step.
- `defect_fwd_step_choice_spec` also provides resolution: `exists w in defects, w in M'` -- the earliest defect enters M'.
- `defect_fwd_step_choice_singleton` (if it exists as a proved base case) handles the singleton defect list.

**Tasks**:
- [ ] Verify `fwd_succ` F-preservation. Read `fwd_succ` definition at CanonicalModel.lean:66-72:
  - Resolving case (`F(target) in M`): seed = `{target} union g_content(M)` via `forward_temporal_witness_seed`. This resolves `target` but does NOT explicitly carry other F-obligations.
  - Non-resolving case: seed = `g_content(M) union f_carry(M)` via `enriched_seed_consistent`. `f_carry(M) = {phi in M | exists chi, phi = F(chi)}` -- this DOES carry all F-obligations.
  - Conclusion: In the resolving case, other F-obligations may be lost. This is the gap.
- [ ] Determine whether `fwd_chain_of_sigma` needs rewiring to use `defect_fwd_step_choice` instead of `fwd_succ`, or whether the proof can work with `fwd_succ` by showing F-obligations persist through g_content.
  - Key question: if `F(chi) in M` and `G(F(chi)) in M` (which would give `F(chi) in g_content(M)`), then F-persistence through g_content holds. But `G(F(chi))` is not guaranteed in general.
  - Alternative: F(chi) in M implies, by BX4 (G(F(chi)) if F(chi) is a theorem pattern), that... no, BX4 is `G(phi) -> phi`, not the converse.
  - The Reynolds approach avoids this by using `defect_fwd_step_choice` directly, not `fwd_succ`.
- [ ] Implement Reynolds induction proof for forward direction:
  1. Given `F(phi) in mcs(t)` where `mcs` is `dd_chain M0 h0 sigma_list`.
  2. The forward chain uses `fwd_chain_of_sigma` which iterates `fwd_succ`.
  3. Since `phi in deferralClosure root` and `h_sub` ensures `phi in sigma_list`, `phi` is scheduled at position `i` in sigma_list.
  4. At each step where `target = phi` (i.e., step n where `n % sigma_list.length = i`), `fwd_succ` uses the resolving case if `F(phi) in mcs(n)`, placing `phi in mcs(n+1)`.
  5. The gap: showing `F(phi)` persists from step `t` to the next scheduled step for `phi`.
  6. In the non-resolving case of `fwd_succ`, `f_carry(M)` carries `F(phi)` forward. So F(phi) persists through every non-resolving step.
  7. In a resolving step for some OTHER target `psi != phi`: the seed is `{psi} union g_content(M)`. F(phi) is NOT in this seed unless `G(F(phi)) in M`. This is the gap.
  8. **Resolution**: Either (a) show `G(F(phi)) in M` for any `F(phi) in M` with `phi in sigma_list` (requires an axiom like `F(phi) -> G(F(phi))` which is NOT valid), OR (b) build a separate chain using `defect_fwd_step_choice` that handles all defects simultaneously.
- [ ] If approach (b): build `defect_fwd_chain` that, at each step, uses `defect_fwd_step_choice` with the current defects list, then show this chain has the same MCS sequence as `fwd_chain_of_sigma` for the relevant formulas, or directly prove restricted_tc using this chain.
  - Alternative: prove restricted_tc without modifying the chain, by working with the chain's actual properties and showing F-persistence through the combination of `g_content` propagation and `f_carry`.
  - Note: `fwd_succ_g_content` gives `g_content(M) subset fwd_succ(M, target)`. And `fwd_succ_f_carry` (if it exists) gives `f_carry(M) subset fwd_succ(M, target)` in the non-resolving case. Check if `f_carry` preservation also holds in the resolving case.
- [ ] Check whether `forward_temporal_witness_seed_consistent` can be strengthened to include `f_carry` in the resolving seed: `{target} union g_content(M) union f_carry(M)`. If the strengthened seed is consistent (it is a subset of M by the same argument), then `fwd_succ` preserves F-obligations in ALL cases.
- [ ] If the strengthened seed approach works: modify `fwd_succ` or create `fwd_succ_enriched` to use `{target} union g_content(M) union f_carry(M)` as seed in the resolving case. Then F-persistence is automatic.
- [ ] After F-persistence is established: prove `dd_bfmcs_restricted_tc` forward direction by:
  - `F(phi) in mcs(t)`, F-persistence gives `F(phi) in mcs(t+1), mcs(t+2), ...`
  - By schedule surjectivity: `phi` is scheduled at some step `s > t` (exists `s` with `sigma_list[s % len] = phi`)
  - At step `s`: `fwd_succ` resolves `phi` because `F(phi) in mcs(s)`, giving `phi in mcs(s+1)`
- [ ] Backward direction: symmetric argument using `bwd_pred`, `h_content`, `p_carry`, and Past/Since.
- [ ] Write the formal Lean proof for `dd_bfmcs_restricted_tc`.

**Timing**: 3 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` -- close sorry at line 953
- Possibly `Theories/Bimodal/Metalogic/BXCanonical/CanonicalModel.lean` -- if `fwd_succ` seed needs enrichment

**Verification**:
- `dd_bfmcs_restricted_tc` compiles without sorry
- `lake build` succeeds
- All existing sorry-free theorems remain sorry-free

---

### Phase 3: Close dd_bfmcs_restricted_buc (Enriched Backward Seed) [NOT STARTED]

**Goal**: Prove backward Until/Since coherence by enriching the backward chain's seed to carry Until-formulas, ensuring backward step transfer holds by construction.

**Strategy**: The backward chain `bwd_chain_of_sigma` (RootScopedChain.lean:474-482) uses `bwd_pred` (CanonicalModel.lean:145-151) at each step. `bwd_pred` constructs the predecessor MCS using:
- **Resolving case** (`P(target) in M`): seed = `past_temporal_witness_seed(M, target)` = `{target} union h_content(M)`
- **Non-resolving case**: seed = `h_content(M) union p_carry(M)`

Neither seed carries Until-formulas from the successor. The enrichment adds Until-formulas from the Sigma closure to the backward seed, making backward Until step transfer hold by construction.

**Detailed backward chain analysis** (from Report 42):
- `dd_bfmcs` at line 977 constructs `dd_chain M0 h0 sigma_list` which assembles `fwd_chain_of_sigma` (t >= 0) and `bwd_chain_of_sigma` (t < 0) into an Int-indexed chain.
- For `restricted_buc`, we need: given `phi U psi in Sigma`, if `psi in mcs(u)` and `phi in mcs(r)` for all `r in [t, u)`, then `phi U psi in mcs(t)`.
- The backward direction of the chain goes from `mcs(0)` backward: `bwd_chain_of_sigma(n+1)` is the predecessor of `bwd_chain_of_sigma(n)` (i.e., `mcs(-n-1)` is the predecessor of `mcs(-n)`).
- Actually for `restricted_buc`, the backward step transfer is needed in the FORWARD direction of the chain: given `phi U psi in mcs(r+1)`, show `phi U psi in mcs(r)` when `phi in mcs(r)`. This is about the relationship between successive MCSs in the forward chain.

**Tasks**:
- [ ] Clarify the exact statement of `restricted_backward_until_since_coherent`. Read the type signature at line 955-957.
- [ ] Determine whether `restricted_buc` is about backward Until coherence (witnessing Until formulas looking backward in time) or about the backward step in proving Until coherence forward.
- [ ] If `restricted_buc` means: "for `phi S psi` (Since), given witness in the past, show `phi S psi` at the current point" -- this is the symmetric backward version. The Since formula needs to propagate forward through successors, which is the dual of the Until problem.
- [ ] For the enriched backward seed approach:
  - Define `bwd_pred_enriched(M, h_mcs, target, Sigma)` that uses seed:
    - Resolving case: `{target} union h_content(M) union {phi U psi | phi U psi in M, phi U psi in Sigma} union {phi S psi | phi S psi in M, phi S psi in Sigma}`
    - Non-resolving case: `h_content(M) union p_carry(M) union {phi U psi | phi U psi in M, phi U psi in Sigma} union {phi S psi | phi S psi in M, phi S psi in Sigma}`
  - Consistency: the enriched seed is a subset of M (h_content subset M, p_carry subset M, and the Until/Since formulas are explicitly required to be in M). So consistency follows from MCS consistency.
- [ ] Alternative: modify `bwd_pred` directly to carry Until/Since formulas. This changes the backward chain globally but may break existing proofs of `bwd_pred_h_content`, `bwd_pred_resolves`, etc.
- [ ] **Preferred approach**: Create `bwd_pred_enriched` and `bwd_chain_of_sigma_enriched` as separate definitions. Build a parallel `dd_chain_enriched` and `dd_bfmcs_enriched` if needed. Or: prove restricted_buc by showing that the EXISTING chain already satisfies the property, using an indirect argument.
- [ ] **Indirect argument**: If `phi U psi in mcs(r+1)` and `phi in mcs(r)`, can we show `phi U psi in mcs(r)` using only MCS properties?
  - By BX9: `phi U psi <-> psi \/ (phi /\ X(phi U psi))` where X is "next" (not available in this logic).
  - In this logic, the relevant axiom is BX8: `psi -> phi U psi` (base case).
  - And: `phi U psi -> F(psi)` (BX10), `phi U psi -> phi \/ psi` (BX9).
  - The backward step transfer `phi /\ F(phi U psi) -> phi U psi` is SEMANTICALLY INVALID (confirmed by all 4 teammates in Reports 41-42).
  - So the indirect argument does NOT work. The enriched seed approach is necessary.
- [ ] Implement the enriched backward seed:
  1. Define the enriched backward seed as `h_content(M) union p_carry(M) union until_since_carry(M, Sigma)` where `until_since_carry(M, Sigma) = {phi in M | (exists a b, phi = a.until b /\ phi in Sigma) \/ (exists a b, phi = a.since b /\ phi in Sigma)}`
  2. Prove consistency: subset of M, hence consistent
  3. Define `bwd_pred_enriched` using this seed
  4. Define `bwd_chain_of_sigma_enriched` using `bwd_pred_enriched`
  5. Prove h_content propagation for the enriched chain
  6. Prove Until/Since carry: `phi U psi in mcs(n) -> phi U psi in mcs(n+1)` for the enriched backward chain
  7. Wire into `dd_bfmcs` by creating an enriched variant, or prove restricted_buc directly using the enriched chain properties
- [ ] Write the formal Lean proof for `dd_bfmcs_restricted_buc`.

**Timing**: 3 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/CanonicalModel.lean` -- add `bwd_pred_enriched` or modify `bwd_pred`
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` -- close sorry at line 958, add enriched backward chain if needed

**Verification**:
- `dd_bfmcs_restricted_buc` compiles without sorry
- `lake build` succeeds
- All existing sorry-free theorems remain sorry-free

---

### Phase 4: Close dd_bfmcs_restricted_fuc (Forward Until/Since Coherence) [NOT STARTED]

**Goal**: Prove forward Until/Since coherence: given `phi U psi in mcs(t)`, find witness `s >= t` with `psi in mcs(s)` and guard `phi in mcs(r)` for `r in [t, s)`.

**Strategy**: This depends on Phase 2 (restricted_tc provides witness existence) and uses BX9 for the guard argument. The forward Until coherence also needs Until-persistence: `phi U psi` must persist in the chain until `psi` appears.

**Tasks**:
- [ ] Forward Until coherence proof:
  1. By BX10: `phi U psi in mcs(t)` implies `F(psi) in mcs(t)`.
  2. By restricted_tc (Phase 2): exists `s > t` with `psi in mcs(s)`. Take the EARLIEST such `s`.
  3. Guard: for `r in [t, s)`, show `phi in mcs(r)`.
  4. Until persistence: need `phi U psi in mcs(r)` for `r in [t, s)` where `psi not in mcs(r)`.
     - If `fwd_succ` is enriched (from Phase 2 work) to carry `f_carry` in the resolving case, then `F(phi U psi)` may persist.
     - But we need `phi U psi` itself, not `F(phi U psi)`.
     - Alternative: enrich the forward seed to carry Until-formulas, symmetric to Phase 3's backward enrichment.
     - Or: use `defect_fwd_step_choice_spec` which preserves F-obligations for defects. If `phi U psi` is treated as a defect, its F-obligation `F(psi)` persists but `phi U psi` itself may not.
  5. **Until-persistence via forward seed enrichment**: Add `until_since_carry(M, Sigma)` to the forward seed (symmetric to Phase 3). Then `phi U psi in mcs(r) -> phi U psi in mcs(r+1)` when `phi U psi in Sigma`.
  6. With Until-persistence: at each `r in [t, s)`, `phi U psi in mcs(r)` and `psi not in mcs(r)` (by minimality of `s`). By BX9: `phi U psi -> phi \/ psi`. Since `psi not in mcs(r)`, `phi in mcs(r)`.
- [ ] If forward seed enrichment is needed: this parallels Phase 3 exactly. Define `fwd_succ_enriched` with seed `{target} union g_content(M) union f_carry(M) union until_since_carry(M, Sigma)`. Or enrich the existing `fwd_succ`.
- [ ] Alternative without enrichment: use `qm_fwd_chain_until_persists` (sorry-free) from the oracle chain if it can apply to the scheduling chain. But the oracle chain is being archived, so this theorem would need to be reproved for the scheduling chain.
- [ ] Forward Since: symmetric argument using `bwd_pred` and `P(psi)`.
- [ ] Write the formal Lean proof for `dd_bfmcs_restricted_fuc`.

**Timing**: 2 hours (leverages Phase 2 and Phase 3 infrastructure for seed enrichment)

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` -- close sorry at line 963
- Possibly `Theories/Bimodal/Metalogic/BXCanonical/CanonicalModel.lean` -- if `fwd_succ` needs enrichment

**Verification**:
- `dd_bfmcs_restricted_fuc` compiles without sorry
- `lake build` succeeds
- `dd_countermodel` compiles without sorry

---

### Phase 5: Integration, Verification, and Cleanup [NOT STARTED]

**Goal**: Verify sorry-free completeness and perform final cleanup.

**Tasks**:
- [ ] Verify `bx_completeness` compiles without sorry
- [ ] Run `#print axioms bx_completeness` and confirm only `propext`, `Classical.choice`, `Quot.sound`
- [ ] Run full `lake build`
- [ ] Grep for remaining sorry in BXCanonical files; verify none reachable from `bx_completeness`
- [ ] Add docstrings to new/modified theorems explaining the mathematical argument
- [ ] Final ROAD_MAP.md update: mark task 93 sorry sites as closed, update sorry count to 0

**Timing**: 0.5 hours

**Depends on**: 3, 4

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` -- docstrings
- `specs/ROAD_MAP.md` -- final sorry count update

**Verification**:
- `lake build` succeeds
- `#print axioms bx_completeness` shows only `propext`, `Classical.choice`, `Quot.sound`
- No reachable sorry from `bx_completeness`

---

## Testing & Validation

- [ ] `lake build` succeeds after each phase
- [ ] `lean_verify` on `dd_bfmcs_restricted_tc` after Phase 2 -- no sorry dependency
- [ ] `lean_verify` on `dd_bfmcs_restricted_buc` after Phase 3 -- no sorry dependency
- [ ] `lean_verify` on `dd_bfmcs_restricted_fuc` after Phase 4 -- no sorry dependency
- [ ] `lean_verify` on `dd_countermodel` after Phase 4 -- no sorry dependency
- [ ] `lean_verify` on `bx_completeness` after Phase 5 -- only `propext`, `Classical.choice`, `Quot.sound`

## Artifacts & Outputs

- `specs/093_complete_bxcanonical_embedding/plans/42_bxcanonical-embedding.md` -- this plan (revised from v41)
- `Theories/Bimodal/Metalogic/BXCanonical/Boneyard/OracleCoherence.lean` -- archived oracle construction (Phase 1)
- `specs/ROAD_MAP.md` -- updated sorry inventory (Phases 1, 5)
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` -- sorry-free coherence proofs (Phases 2-4)
- `Theories/Bimodal/Metalogic/BXCanonical/CanonicalModel.lean` -- enriched seed variants (Phases 2-3, if needed)

## Rollback/Contingency

1. **Phase 1 safe**: Boneyard archival is pure code movement. Rollback: move code back.

2. **Phase 2 F-persistence fails for fwd_succ**: If enriching the resolving seed is not feasible, build a parallel `defect_fwd_chain` using `defect_fwd_step_choice` at each step (which has guaranteed F-persistence) and prove restricted_tc on that chain. Then show the actual dd_chain satisfies the same property by functional extensionality or a transfer argument.

3. **Phase 3 enriched backward seed breaks existing proofs**: Create `bwd_pred_enriched` and `bwd_chain_of_sigma_enriched` as entirely new definitions, coexisting with the originals. Build a separate enriched dd_bfmcs and prove restricted_buc on it. Then show the original dd_bfmcs also satisfies the property (if the enriched chain is a refinement).

4. **Phase 4 Until-persistence fails for forward chain**: If enriching the forward seed is too invasive, try: prove Until-persistence via a meta-argument. If `phi U psi in mcs(r)` and `psi not in mcs(r)`, by BX9 `phi in mcs(r)`, and by BX10 `F(psi) in mcs(r)`. By F-persistence (Phase 2), `F(psi) in mcs(r+1)`. Then if `phi U psi not in mcs(r+1)`, we have `neg(phi U psi) in mcs(r+1)` (MCS totality). Check if `F(psi) /\ neg(phi U psi)` leads to a contradiction using BX axioms.

5. **Complete failure**: `git checkout -- Theories/Bimodal/Metalogic/BXCanonical/` restores current state. The Boneyard archival (Phase 1) can be preserved independently.
