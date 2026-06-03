# Implementation Plan: Task #155 (v63 -- Blocker-Corrected)

- **Task**: 155 - Eliminate all sorries from completeness_discrete by proving `nf_2var_existential_transfer` (Chain 1 root) and directly proving `IsSuccArchimedean` (Chain 2 bypass)
- **Status**: [NOT STARTED]
- **Effort**: 8-14 hours
- **Dependencies**: None (Phase 1 and Phase 2 from plan v62 are completed)
- **Research Inputs**: specs/155_reynolds_pipeline_activation/reports/61_blocker-escalation-research.md, specs/155_reynolds_pipeline_activation/reports/61_depth-mismatch-literature.md, specs/155_reynolds_pipeline_activation/reports/60_blocker-resolution.md, specs/155_reynolds_pipeline_activation/reports/58_proper-fix-research.md
- **Artifacts**: plans/62_revised-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-formats.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

This is plan v63, revised from v62 to incorporate the blocker escalation research (report 61_blocker-escalation-research.md). Plan v62 was blocked at Phase 3 due to two issues: (1) the EF Game Bridge approach required 300-500 lines of bridge code connecting NF types on M.carrier to rank_types on ExtendedCarrier, and (2) a diagnosed "formula construction bug" in `nf_exist_sf_guarded_backward` (line 2787). The escalation research reveals that issue (2) is a **misdiagnosis** -- the backward direction is not structurally unprovable; its sorry simply awaits `nf_2var_from_interval_data`, which itself awaits `nf_2var_existential_transfer`. This means there is only ONE root sorry in Chain 1, not two independent issues.

**Key correction from escalation research**: The `nf_exist_sf_guarded` formula does NOT need to encode quantifier structure because `nf_2var_from_interval_data` handles quantifier matching independently. Once `nf_2var_existential_transfer` is proved, the sorry at line 2787 resolves automatically through the dependency chain.

**Strategy pivot**: Instead of the EF Game Bridge approach (plan v62 Phase 3), this plan attacks the root sorry `nf_2var_existential_transfer` directly. The escalation research confirms that all zone-matching and atom-agreement infrastructure exists; the missing piece is the inductive quantifier transfer for 3-point configurations at depth j'+1. This is GHR93 Proposition 7's core inductive step, estimated at 200-400 lines of proof code.

For Chain 2 (IsSuccArchimedean, 6 sorries in `chronicle_gap_contradiction`), this plan adopts Strategy B: prove `limitDomSubtype_isSuccArchimedean` directly from the omega-chain construction, bypassing `chronicle_gap_contradiction` and `succ_cofinal` entirely. This avoids the hard constant-MCS case.

Definition of done: `#print axioms completeness_discrete` shows no `sorryAx`, `lake build` passes, no `axiom` declarations outside the proof system or frame constraints.

### Research Integration

- **Report 61 (blocker escalation)**: **Primary input for this revision.** Corrected the misdiagnosis of the formula construction bug. Identified `nf_2var_existential_transfer` as the single root cause of Chain 1 (3 sorries). Recommended attack order: Strategy C (direct proof of `nf_2var_existential_transfer`) then Strategy B (direct `IsSuccArchimedean`).
- **Report 61 (depth mismatch literature)**: Confirmed depth-k NF -> rank_type relationship. Still relevant as fallback context if the direct approach fails and the EF Game Bridge is needed.
- **Report 60 (blocker resolution)**: Diagnosed the interval-splitting problem. Confirmed game infrastructure is sorry-free.
- **Report 58 (proper fix research)**: Model surgery limitation for IsSuccArchimedean. Relevant to understanding why Strategy B (bypass) is preferred over Strategy A (fix chronicle_gap_contradiction directly).

### Literature Sources

| Phase | Primary Literature | Specific Result |
|-------|-------------------|-----------------|
| Phase 3 | `literature/Gabbay_Hodkinson_Reynolds_1993_Temporal_expressive_completeness_gaps.md` p.114 | Proposition 7: EF game composition, inductive strategy for existential transfer |
| Phase 3 | `literature/Gabbay_Hodkinson_Reynolds_1994_Temporal_Logic_Foundations_Vol1_ch9.md` | Ch. 9: monadic NF framework, depth-j quantifier transfer |
| Phase 4 | `literature/Burgess_1982_Axioms_for_tense_logic_Since_and_Until.md` | Chronicle construction and omega-chain properties |
| Phase 4 | `literature/Reynolds_1994_Axiomatising_U_and_S_over_integer_time.md` | Theorem 14: limit domain structure |

### Prior Plan Reference

Plan v62 identified the correct 3 root sorries and proposed the EF Game Bridge approach. Phase 1 (import cycle resolution) and Phase 2 (private defs made accessible) are completed and preserved. This plan v63 replaces Phases 3-7 from v62 with a simpler, more direct approach:

- **v62 Phase 3 (EF Game Bridge, 300-500 lines)** is replaced by **v63 Phase 3 (direct proof of nf_2var_existential_transfer, 200-400 lines)**. The direct approach avoids building bridge code between NF types and rank_types, instead completing the inductive proof that was already partially written.
- **v62 Phase 5 (model surgery rewiring)** is replaced by **v63 Phase 4 (direct IsSuccArchimedean)**. This bypasses `chronicle_gap_contradiction` entirely.

### Roadmap Alignment

- Closing both sorry chains achieves sorry-free `completeness_discrete`
- Eliminates all axiom declarations outside the proof system
- Advances critical path: Task 155 -> sorry-free `completeness_discrete`

## Goals & Non-Goals

**Goals**:
- Prove `nf_2var_existential_transfer` by induction on depth j, completing the 3-point configuration quantifier transfer (Chain 1 root)
- Prove `limitDomSubtype_isSuccArchimedean` directly from the omega-chain construction, bypassing `chronicle_gap_contradiction` (Chain 2 bypass)
- Verify that fixing Chain 1 cascades to make `nf_exist_sf_guarded_backward`, `stavi_expressive_completeness`, and the full model surgery pipeline sorry-free
- `#print axioms completeness_discrete` shows no `sorryAx`
- `lake build` passes
- No `axiom` declarations outside the proof system or frame constraints

**Non-Goals**:
- Building the EF Game Bridge in NFGameBridge.lean (deferred; not needed if direct proof works)
- Proving `chronicle_gap_contradiction` (dead BX pipeline code, bypassed by direct approach)
- Making additional definitions non-private beyond what Phase 2 already accomplished
- Modifying GoodStructures.lean or NoGapsDiscreteProof.lean (Phase 1 work preserved)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Direct proof of `nf_2var_existential_transfer` requires more than 400 lines due to 3-point sub-interval matching | M | M | All zone-matching infrastructure exists (zone_match_witness, atom agreement). The inductive step follows GHR93 Proposition 7. If blocked, fall back to EF Game Bridge approach from plan v62 Phase 3. |
| Depth j'+1 inductive step needs sub-interval data for the 3-point configuration (u,x,t) that is not available from the 2-point hypotheses | H | M | The escalation research confirms this is the same sub-interval problem at lower depth and higher variable count. The proof proceeds by induction on j: at j=0, atoms transfer from zone matching; at j+1, the inductive hypothesis gives the transfer at depth j. Read GHR93 p.114 carefully for the exact argument. |
| Direct IsSuccArchimedean proof requires omega_chain internals that are hard to work with | M | L | The omega_chain construction adds one point per stage. `limit_dom_no_max` and `limit_dom_no_min` show the domain is unbounded. The succ function (`limitDomSubtype_succ`) is strictly monotone (proved at line 854). The key insight from the escalation research: every point enters the domain at some finite stage, and succ iterates cover all later stages. |
| Model surgery pipeline does NOT become sorry-free after Chain 1 fix because of an independent sorry | M | L | The escalation research traced the full dependency: `no_gaps_discrete_model_surgery` -> `US_expressively_complete_over_prior` -> `stavi_expressive_completeness` -> `nf_2var_existential_transfer`. No independent sorries were found in this chain. Phase 5 verification will catch any unexpected sorries. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2 | -- |
| 2 | 3, 4 | 1, 2 (already completed) |
| 3 | 5 | 3, 4 |
| 4 | 6 | 5 |

Phases within the same wave can execute in parallel.

### Phase 1: Resolve import cycle and close no_gaps_discrete [COMPLETED]

**Goal**: Close the sorry at GoodStructures.lean:855 by extracting `no_gaps_discrete` into `NoGapsDiscreteProof.lean`.

**Tasks**:
- [x] Created `NoGapsDiscreteProof.lean` importing GoodStructuresModelSurgery
- [x] Removed `no_gaps_discrete` and `one_class` from GoodStructures.lean
- [x] `no_gaps_discrete` delegates to `no_gaps_discrete_model_surgery` via `exact`
- [x] `lake build` passes (1681 jobs, zero errors)
- [x] GoodStructures.lean has zero sorries

**Timing**: 2 hours

**Depends on**: none

**Completed**: 2026-06-02

---

### Phase 2: Make private definitions accessible for bridge [COMPLETED]

**Goal**: Make `interval_nf_types` and other definitions needed by the bridge non-private in StaviCompleteness.lean.

**Tasks**:
- [x] Identified all private definitions needed
- [x] Removed `private` keyword from ~10 definitions
- [x] Build verification passed
- [x] NFGameBridge.lean can see the definitions

**Timing**: 0.5-1 hour

**Depends on**: 1

**Completed**: 2026-06-02

---

### Phase 3: Prove nf_2var_existential_transfer [NOT STARTED]

**Goal**: Complete the proof of `nf_2var_existential_transfer` (StaviCompleteness.lean, lines 2214-2429) by providing the inductive quantifier transfer for 3-point configurations at depth j'+1. This eliminates the root sorry of Chain 1 (Stavi expressive completeness).

**CRITICAL INSTRUCTIONS FOR IMPLEMENTING AGENT**:
- The two sorries are at lines 2347 (forward direction) and 2429 (backward direction).
- The proof structure is already in place: zone matching finds u' with matching 1-var NF and correct orderings. What remains is showing depth-j 3-var NF agreement at (u,x,t)/(u',x',t').
- For j=0: the depth-0 3-var NF is just atoms (predicates + orderings). Zone matching gives correct orderings, and 1-var NF agreement gives predicates. This case should already work from the existing code.
- For j>=1: the inductive hypothesis gives the transfer at depth j-1. The quantifier transfer at depth j requires sub-interval matching for the 3-point configuration. This is GHR93 Proposition 7's inductive step.
- Read `literature/Gabbay_Hodkinson_Reynolds_1993_Temporal_expressive_completeness_gaps.md` pages 113-115 (Lemma 11, Proposition 7, Corollary 5) for the exact argument structure.
- Read `literature/Gabbay_Hodkinson_Reynolds_1994_Temporal_Logic_Foundations_Vol1_ch9.md` for the NF/depth correspondence.
- Do NOT attempt to build the EF Game Bridge (plan v62 approach). Work directly within StaviCompleteness.lean.
- Do NOT use `sorry` or `axiom` as fallbacks. If blocked, report what was tried and what goal state was reached.

**Tasks**:

- [ ] **Task 3.1**: Read and understand the existing proof structure at lines 2214-2430. Identify exactly what the goal state is at each sorry (lines 2347 and 2429). Use `lean_goal` to inspect the proof state at both sorry sites.

- [ ] **Task 3.2**: Handle the j=0 base case. At depth 0, the 3-var NF is determined entirely by atoms (predicates at each variable + orderings between variables). Zone matching provides ordering agreement for all pairs (u,x), (u,t), (x,t) and their primed counterparts. 1-var NF agreement at depth k (which is >= j=0) gives predicate agreement. Prove `nf_eval_nf M 0 (2+1) ... chi` transfers from (u,x,t) to (u',x',t') using atom agreement.

- [ ] **Task 3.3**: Handle the j=j'+1 inductive step (forward direction, line 2347). The depth-(j'+1) 3-var NF chi decomposes into: (a) atoms at 3 variables, and (b) existential quantifiers over a 4th variable at depth j'. Part (a) is handled by zone matching + NF agreement. For part (b), given a 4th variable w in M witnessing the existential, find w' in M' such that the depth-j' 4-var NF at (w,u,x,t) equals that at (w',u',x',t'). This requires:
  - Zone matching w to w' using the 1-var NF data and interval types between all relevant pairs
  - Applying the inductive hypothesis at depth j' (one lower) to transfer the quantifier

  **Literature reference**: GHR93 Proposition 7 (p.114): the Duplicator's strategy in the game corresponds to choosing w' that maintains the invariant. The depth decrease from j'+1 to j' matches the game round consumption.

- [ ] **Task 3.4**: Handle the j=j'+1 inductive step (backward direction, line 2429). This is symmetric to the forward direction: given w' in M' witnessing the existential in chi, find w in M. Apply zone matching in the reverse direction and use the inductive hypothesis.

- [ ] **Task 3.5**: Verify the proof compiles and eliminates the sorries:
  - `lake build Bimodal.Metalogic.WeakCanonical.EFGames.StaviCompleteness` passes
  - `lean_verify nf_2var_existential_transfer` shows no `sorryAx`
  - Confirm `nf_2var_from_interval_data` is now sorry-free (it calls `nf_2var_existential_transfer`)

**Timing**: 4-8 hours

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/StaviCompleteness.lean` (prove the two sorries at lines 2347, 2429; estimated 200-400 lines of new proof code)

**Verification**:
- `lean_verify nf_2var_existential_transfer` shows no `sorryAx`
- `lean_verify nf_2var_from_interval_data` shows no `sorryAx`
- `lake build Bimodal.Metalogic.WeakCanonical.EFGames.StaviCompleteness` passes
- No new sorry or axiom introduced

---

### Phase 4: Prove IsSuccArchimedean directly from omega-chain [NOT STARTED]

**Goal**: Replace the sorry-bearing `limitDomSubtype_isSuccArchimedean` (ChronicleToCountermodel.lean:789) with a direct proof that bypasses `chronicle_gap_contradiction` and `succ_cofinal` entirely. The key insight: every point in `limit_dom` enters at some finite stage of the omega-chain construction, and the succ function covers all points reachable from a given starting point.

**CRITICAL INSTRUCTIONS FOR IMPLEMENTING AGENT**:
- Do NOT attempt to fix `chronicle_gap_contradiction` (dead BX pipeline code). Instead, prove `limitDomSubtype_isSuccArchimedean` directly.
- The current definition at line 789 uses `succ_cofinal` which depends on `chronicle_gap_contradiction`. Replace the proof body entirely.
- `succ_embed_surjective` (line 1666) references `limitDomSubtype_isSuccArchimedean` at line 1673. When this definition is proved, `succ_embed_surjective` becomes sorry-free automatically.
- Read `literature/Burgess_1982_Axioms_for_tense_logic_Since_and_Until.md` for the chronicle/omega-chain construction details.
- The omega-chain construction (in ChronicleToCountermodelBasic.lean) adds points via `omega_chain_val`. Key properties: `omega_chain_dom_mono` (domain grows monotonically), `omega_chain_dom_new_unique` (each stage adds at most one new point).
- Existing infrastructure: `limitDomSubtype_succ_lt` (line 854: succ is strictly monotone), `limitDomSubtype_succ_iter_mono` (line 875: iterates are monotone), `succ_orbit_convex` (referenced at line 805).

**Tasks**:

- [ ] **Task 4.1**: Understand the omega-chain internals. Read `ChronicleToCountermodelBasic.lean` for `omega_chain_val`, `limit_dom`, `limit_dom_no_max`, `limit_dom_no_min`. Identify what properties are available about the relationship between omega-chain stages and `limitDomSubtype_succ`.

- [ ] **Task 4.2**: Design the direct proof strategy. The goal is: for any a, b in `LimitDomSubtype` with a <= b, show there exists n such that `succ^[n](a) = b`. Key argument sketch:
  - Both a and b are rationals in `limit_dom`, so they appear in `omega_chain_val(N).dom` for some finite N.
  - The succ function on `LimitDomSubtype` is the order-successor in the limit domain (a discrete linear order by the h_discrete hypothesis).
  - In a discrete linear order without endpoints, any two elements with a <= b are connected by finitely many succ steps IF the order is well-founded in both directions restricted to any finite interval.
  - The limit domain is countable (proved at line 83 of ChronicleToCountermodelBasic.lean). The set {c : a <= c <= b} is finite in a discrete order (each step increments by at least the minimum gap between rationals in a finite stage).

- [ ] **Task 4.3**: Implement the proof. Replace the body of `limitDomSubtype_isSuccArchimedean` (lines 789-806). The new proof should NOT reference `succ_cofinal` or `chronicle_gap_contradiction`. Estimated: 100-250 lines.

- [ ] **Task 4.4**: Verify the proof compiles and eliminates the sorry chain:
  - `lean_verify limitDomSubtype_isSuccArchimedean` shows no `sorryAx`
  - `lean_verify succ_embed_surjective` shows no `sorryAx`
  - `lake build Bimodal.Metalogic.BXCanonical.Chronicle.ChronicleToCountermodel` passes

**Timing**: 2-4 hours

**Depends on**: 2 (independent of Phase 3; can run in parallel)

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` (replace proof body of `limitDomSubtype_isSuccArchimedean` at lines 789-806; add helper lemmas)

**Verification**:
- `lean_verify limitDomSubtype_isSuccArchimedean` shows no `sorryAx`
- `lean_verify succ_embed_surjective` shows no `sorryAx`
- `lake build Bimodal.Metalogic.BXCanonical.Chronicle.ChronicleToCountermodel` passes

---

### Phase 5: Full sorry cascade verification [NOT STARTED]

**Goal**: Verify that both Chain 1 and Chain 2 fixes cascade through to make `completeness_discrete` entirely sorry-free. Verify the model surgery pipeline is also sorry-free as a consequence.

**Tasks**:

- [ ] **Task 5.1**: Verify Chain 1 cascade (Stavi -> expressive completeness -> model surgery):
  - `lean_verify nf_exist_sf_guarded_backward` -- should now be sorry-free since it depends on `nf_2var_from_interval_data` which depends on `nf_2var_existential_transfer` (Phase 3)
  - `lean_verify stavi_expressive_completeness` -- no `sorryAx`
  - `lean_verify US_expressively_complete_over_prior` -- no `sorryAx`

- [ ] **Task 5.2**: Verify model surgery pipeline (now should be sorry-free):
  - `lean_verify gap_prior_UZ_contradiction` -- no `sorryAx`
  - `lean_verify reynolds_model_surgery_core` -- no `sorryAx`
  - `lean_verify no_gaps_discrete_model_surgery` -- no `sorryAx`
  - `lean_verify no_gaps_discrete` -- no `sorryAx`

- [ ] **Task 5.3**: Verify Chain 2 cascade (IsSuccArchimedean -> countermodel -> completeness):
  - `lean_verify countermodel_discrete_reynolds` -- no `sorryAx`
  - `lean_verify cantor_bfmcs_discrete_restricted_tc` -- no `sorryAx`
  - `lean_verify cantor_bfmcs_discrete_restricted_fuc` -- no `sorryAx`

- [ ] **Task 5.4**: Final completeness verification:
  - `lean_verify completeness_discrete` -- no `sorryAx`
  - `lake build` passes with zero errors (full project)
  - `grep -rn "^\s*sorry" Theories/` -- verify no new sorry statements introduced
  - `grep -rn "^axiom " Theories/` -- verify no axiom declarations outside proof system/frame constraints

- [ ] **Task 5.5**: If any verification fails, identify the remaining sorry source and fix it. Document what was found and what additional work is needed.

**Timing**: 1-2 hours

**Depends on**: 3, 4

**Files to modify**:
- None expected (verification only), unless sorry traces are found

**Verification**:
- `#print axioms completeness_discrete` -- NO `sorryAx`
- `lake build` -- zero errors
- No new sorry statements
- No extraneous axiom declarations

---

### Phase 6: Documentation cleanup [NOT STARTED]

**Goal**: Update docstrings referencing the old sorry chain, the dead BX pipeline code, and the previous plan approaches.

**Tasks**:
- [ ] Update ChronicleToCountermodel.lean file-level docstring (lines 57-91) to reflect that `limitDomSubtype_isSuccArchimedean` is now proved directly (not via axiom or model surgery)
- [ ] Update the docstring at lines 782-787 (above `limitDomSubtype_isSuccArchimedean`) to note it is sorry-free via direct proof
- [ ] Update the docstring at lines 808-817 (Collapse-Based Discrete Pipeline) to note that `succ_embed_surjective` uses the genuine proof
- [ ] Update StaviCompleteness.lean docstrings near the fixed sorry sites (lines 2196-2213 and line 2785-2786) to remove references to sorry'd bridge lemma
- [ ] Mark dead BX pipeline code (lines 472-780: `chronicle_gap_contradiction`, `succ_cofinal` old version) with clear "DEAD CODE -- bypassed by direct IsSuccArchimedean proof" annotations for future archival by task 255
- [ ] Update the audit section in Completeness.lean to reflect sorry-free status for `completeness_discrete`
- [ ] Write execution summary at `specs/155_reynolds_pipeline_activation/summaries/62_execution-summary.md`

**Timing**: 1 hour

**Depends on**: 5

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` -- update docstrings
- `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` -- update audit comments
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/StaviCompleteness.lean` -- update docstrings

**Verification**:
- `lake build` still passes
- All docstrings accurately reflect the current sorry status

## Testing & Validation

- [ ] `lean_verify nf_2var_existential_transfer` shows no `sorryAx`
- [ ] `lean_verify nf_2var_from_interval_data` shows no `sorryAx`
- [ ] `lean_verify nf_exist_sf_guarded_backward` shows no `sorryAx`
- [ ] `lean_verify stavi_expressive_completeness` shows no `sorryAx`
- [ ] `lean_verify US_expressively_complete_over_prior` shows no `sorryAx`
- [ ] `lean_verify gap_prior_UZ_contradiction` shows no `sorryAx`
- [ ] `lean_verify reynolds_model_surgery_core` shows no `sorryAx`
- [ ] `lean_verify no_gaps_discrete_model_surgery` shows no `sorryAx`
- [ ] `lean_verify no_gaps_discrete` shows no `sorryAx`
- [ ] `lean_verify limitDomSubtype_isSuccArchimedean` shows no `sorryAx`
- [ ] `lean_verify succ_embed_surjective` shows no `sorryAx`
- [ ] `lean_verify completeness_discrete` shows no `sorryAx`
- [ ] `lean_verify countermodel_discrete_reynolds` shows no `sorryAx`
- [ ] `lean_verify cantor_bfmcs_discrete_restricted_tc` shows no `sorryAx`
- [ ] `lean_verify cantor_bfmcs_discrete_restricted_fuc` shows no `sorryAx`
- [ ] `lake build` passes with zero errors
- [ ] No new sorry statements introduced (`grep -rn "^\s*sorry" Theories/`)
- [ ] No `axiom` declarations outside proof system (`grep -rn "^axiom " Theories/`)

## Artifacts & Outputs

- `specs/155_reynolds_pipeline_activation/plans/62_revised-plan.md` (this file, v63)
- Modified `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/StaviCompleteness.lean` (proof of `nf_2var_existential_transfer`: ~200-400 lines)
- Modified `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` (direct proof of `limitDomSubtype_isSuccArchimedean`: ~100-250 lines, docstring updates)
- Modified `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` (docstring updates)
- Execution summary at `specs/155_reynolds_pipeline_activation/summaries/62_execution-summary.md`

## Rollback/Contingency

If the direct proof of `nf_2var_existential_transfer` (Phase 3) hits a wall:

1. **Fallback A -- EF Game Bridge (plan v62 Phase 3)**: Revert to building the full bridge between NF types and rank_types in NFGameBridge.lean. This is the plan v62 approach, estimated at 300-500 lines. It bypasses `nf_2var_existential_transfer` entirely by using the sorry-free game infrastructure (Composition.lean, Decomposition.lean). See plan v62 Phase 3 sub-phases 3A-3D for the detailed approach.

2. **Fallback B -- Partial direct + bridge hybrid**: If the direct proof works for j=0 and j=1 but fails at j>=2, combine the direct proof for low depths with a bridge argument that handles the general case.

3. **Safe revert**: `git checkout -- Theories/Bimodal/Metalogic/WeakCanonical/EFGames/StaviCompleteness.lean` and `git checkout -- Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` to restore files. Phase 1 and Phase 2 changes are preserved.

If the direct IsSuccArchimedean proof (Phase 4) fails:

1. **Fallback A -- Model surgery rewiring**: If Phase 3 succeeds (making the Stavi pipeline sorry-free), use plan v62 Phase 5 to rewire `limitDomSubtype_isSuccArchimedean` through the now-sorry-free model surgery pipeline (`no_gaps_discrete`).

2. **Fallback B -- Fix chronicle_gap_contradiction**: Strategy A from the escalation research. Fix Case A (line 741: use k=1 instead of k=0; line 761: symmetric case). Case B (constant MCS) is the hard part, estimated at 300-600 lines.
