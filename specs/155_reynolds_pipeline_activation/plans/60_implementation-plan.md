# Implementation Plan: Task #155 (v63)

- **Task**: 155 - Eliminate all sorries from completeness_discrete by fixing 3 root sorries in StaviCompleteness.lean (4-variable EF-game existential transfer, GHR93 Proposition 7) and rewiring limitDomSubtype_isSuccArchimedean
- **Status**: [NOT STARTED]
- **Effort**: 10-14 hours
- **Dependencies**: None (task 199 dependency is stale per research; Phase 1+2 already completed)
- **Research Inputs**: specs/155_reynolds_pipeline_activation/reports/60_team-research.md
- **Artifacts**: plans/60_implementation-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Plan v63 replaces the failed EF Game Bridge approach (plan v62 Phase 3) with the **strengthened induction** approach recommended by team research (report 60). The root blocker is `nf_2var_existential_transfer` (sorry at StaviCompleteness.lean lines 2347, 2429), which requires proving that a zone-matched witness u' in M' satisfies depth-(j'+1) 3-var NFs when given depth-k 1-var NF agreement and interval type agreement. The current proof handles depth-0 (atoms only) but gets stuck at the quantifier transfer step for depth j'+1 because 4-variable sub-interval matching requires the SAME interval data that the outer theorem provides -- a self-similar structure that demands induction on j, not case analysis.

GHR93 Proposition 7 (p.114) resolves this via induction on game rounds: Duplicator uses the **full interval strategy** (not just zone matching) to find a witness satisfying ALL decomposition formulas simultaneously. The strengthened induction carries all-pairs interval data as invariant, mirroring GHR93's proof structure directly within StaviCompleteness.lean. This avoids the 400-600 line NFGameBridge.lean detour that plan v62 attempted.

Definition of done: `#print axioms completeness_discrete` shows no `sorryAx`, `lake build` passes, no `axiom` declarations outside the proof system or frame constraints.

### Research Integration

- **Report 60** (team research, 4 teammates): Definitive analysis establishing that all 3 sorries reduce to ONE root blocker (`nf_2var_existential_transfer`). Recommends strengthened induction on j carrying all-pairs interval data. Identified that plan v62's Sub-phase 3B targets the wrong interface (`decomposition_agreement` lacks `interval_types`). Discovered second sorry chain in GoodStructuresModelSurgery.lean (out of scope).

### Prior Plan Reference

Plan v62 (61_implementation-plan.md) correctly identified the 3 root sorries and completed Phases 1-2. Phase 3 was marked [BLOCKED] because it proposed an EF Game Bridge through NFGameBridge.lean targeting `decomposition_agreement` and `rank_type` -- an interface that does not expose interval_types (confirmed by research critic). The depth floor(k/2) relationship added complexity without clear payoff. Plan v63 replaces Phase 3 entirely with the strengthened induction approach, which works INSIDE StaviCompleteness.lean and avoids the rank_type/game bridge layer altogether. Effort calibration from v62: Phases 1-2 each took approximately the estimated time. The v62 Phase 3 estimate of 5-8 hours was reasonable but applied to the wrong approach.

### Roadmap Alignment

- Closing the Stavi sorry chain achieves sorry-free `stavi_expressive_completeness`
- Rewiring `limitDomSubtype_isSuccArchimedean` removes the last axiom-based bypass
- Together: sorry-free `completeness_discrete` on the critical path

## Goals & Non-Goals

**Goals**:
- Prove `nf_2var_existential_transfer` by strengthened induction on j carrying all-pairs interval agreement as invariant (GHR93 Proposition 7)
- Close the 3 sorry sites at StaviCompleteness.lean lines 2347, 2429, 2787
- Rewire `limitDomSubtype_isSuccArchimedean` to use the now-sorry-free Reynolds model surgery pipeline
- `#print axioms completeness_discrete` shows no `sorryAx`
- `lake build` passes
- No `axiom` declarations outside the proof system or frame constraints

**Non-Goals**:
- Building EF Game Bridge in NFGameBridge.lean (plan v62 approach, abandoned)
- Proving `chronicle_gap_contradiction` (dead BX pipeline code)
- Closing the second sorry chain in GoodStructuresModelSurgery.lean (separate task)
- Modifying GoodStructures.lean or NoGapsDiscreteProof.lean (Phase 1 work preserved)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Strengthened induction hypothesis too complex to express in Lean 4 | H | M | Start with the precise statement from GHR93 Prop 7. If `all_pairs_interval_agreement` is unwieldy, package it as a structure/record with named fields. Prototype the statement with `lean_multi_attempt` before committing. |
| Sub-interval data at recursive call does not follow from outer invariant | H | L | GHR93 Lemma 11 (p.113) establishes exactly this: Duplicator's response preserves decomposition formula agreement for BOTH sub-intervals. The strengthened invariant is designed to carry this data. If extraction is difficult, introduce an intermediate lemma `sub_interval_data_from_invariant`. |
| Sorry 3 (line 2787, `nf_exist_sf_guarded_backward`) does not resolve automatically | M | M | Research report notes this needs 50-150 lines of explicit proof: extract witness from temporal formula, determine 1-var NF via `char_k_correct`, apply `nf_2var_from_interval_data`. Phase 4 budgets time for this. |
| Rewiring `limitDomSubtype_isSuccArchimedean` requires missing Prior-UZ/SZ infrastructure | M | M | Phase 5 audits existing infrastructure first. The model surgery pipeline (`no_gaps_discrete_model_surgery`) is already sorry-free from Phase 1. The gap is constructing an OrderedMonadicStructure on LimitDomSubtype, which requires ~100-200 lines. |
| Full `lake build` regression from StaviCompleteness.lean changes | L | L | Build after each sub-phase. All changes are internal to proof bodies (no signature changes). |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2 | -- |
| 2 | 3 | 1, 2 |
| 3 | 4 | 3 |
| 4 | 5 | 3 |
| 5 | 6 | 4, 5 |

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

**Files modified**:
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/NoGapsDiscreteProof.lean` (new)
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/GoodStructures.lean` (removed sorry)

---

### Phase 2: Make private definitions accessible [COMPLETED]

**Goal**: Remove `private` from 11 definitions in StaviCompleteness.lean needed for the strengthened induction approach.

**Tasks**:
- [x] Identified and removed `private` from `interval_nf_types`, `zone_match_witness`, `nf_fraisse_compression`, `nf_2var_from_interval_data`, `nf_2var_existential_transfer`, `interval_2var_nf_types`, `nf_char_depth_decrease`, `interval_nf_types_depth_decrease`, `above_max_depth_decrease`, `below_min_depth_decrease`, `nf_exist_sf_guarded_backward`
- [x] Build passes

**Timing**: 0.5 hours

**Depends on**: none

**Completed**: 2026-06-02

---

### Phase 3: Strengthened induction for nf_2var_existential_transfer [NOT STARTED]

**Goal**: Replace the sorry'd proof body of `nf_2var_existential_transfer` (lines 2347, 2429) with a strengthened induction on j that carries all-pairs interval agreement as invariant, directly mirroring GHR93 Proposition 7.

**CRITICAL INSTRUCTIONS FOR IMPLEMENTING AGENT**:
- Work INSIDE StaviCompleteness.lean. Do NOT modify NFGameBridge.lean.
- The proof currently gets stuck at the quantifier transfer for depth j'+1 (4-var existential transfer). The fix is to strengthen the induction hypothesis to carry interval data for ALL pairs of points in the configuration, not just the outer pair (x,t).
- Follow GHR93 Proposition 7 (p.114) step-by-step. Read the literature file `literature/Gabbay_Hodkinson_Reynolds_1993_Temporal_expressive_completeness_gaps.md` BEFORE writing code.
- Do NOT attempt to bypass the induction via the EF Game Bridge (plan v62 approach, definitively abandoned).
- Do NOT use `sorry` or `axiom` as fallbacks. If blocked, report what was tried.

**Literature basis**: GHR93 Proposition 7 (p.114): Duplicator responds to Spoiler's placement of alpha in (x_i, x_{i+1}) by collecting ALL decomposition formulas witnessing how alpha splits the interval, then using the full interval strategy to find e in N satisfying ALL decomposition formulas simultaneously. By Lemma 11 (p.113), this yields winning strategies for BOTH sub-interval games. Apply induction hypothesis.

**Sub-phase 3A: Design the strengthened induction statement (~50-80 lines)**

- [ ] **Task 3A.1**: Read the current proof structure of `nf_2var_existential_transfer` at lines 2214-2429 carefully. Understand the exact goal state at the sorry sites (lines 2347, 2429). Use `lean_goal` at the sorry positions to get the precise Lean 4 goal.

- [ ] **Task 3A.2**: Read GHR93 Proposition 7 (p.114) and Lemma 11 (p.113) in `literature/Gabbay_Hodkinson_Reynolds_1993_Temporal_expressive_completeness_gaps.md`. Extract the exact invariant that Duplicator maintains.

- [ ] **Task 3A.3**: Design the strengthened theorem statement. The key change: instead of proving the transfer for a fixed 2-point configuration (x,t) directly, prove it for an arbitrary n-point configuration where the induction hypothesis carries interval agreement data for ALL pairs of adjacent points. The skeleton:
  ```
  -- Strengthened transfer: given n points with matching depth-k 1-var NFs,
  -- matching orderings, and matching interval type sets for ALL adjacent pairs,
  -- the existential transfer holds at depth j for (n+1)-var extensions.
  theorem nf_existential_transfer_strong
      (k j n : Nat) (hj : j < k)
      (env : Fin n -> M.carrier) (env' : Fin n -> M'.carrier)
      (h_nf : forall i, nf_characteristic M k 1 (fun _ => env i) =
                         nf_characteristic M' k 1 (fun _ => env' i))
      (h_order : forall i j, env i < env j <-> env' i < env' j)
      (h_interval : forall i j, env i < env j ->
          interval_nf_types M k (env i) (env j) =
          interval_nf_types M' k (env' i) (env' j))
      (h_above : ...) (h_below : ...) :
      forall chi : NormalForm sig j (n + 1),
        (exists u, nf_eval_nf M j (n+1) (Fin.cons u env) chi) <->
        (exists u', nf_eval_nf M' j (n+1) (Fin.cons u' env') chi)
  ```

- [ ] **Task 3A.4**: Verify the statement type-checks using `lean_multi_attempt` on a skeleton with `sorry` body. Iterate on the signature until Lean accepts it.

**Sub-phase 3B: Prove the strengthened induction (~150-250 lines)**

- [ ] **Task 3B.1**: Prove the base case j = 0. At depth 0, NFs are just atom predicates and orderings. Zone matching provides correct orderings, and 1-var NF agreement provides predicates. This should be straightforward using the existing atom transfer infrastructure already in the proof (lines 2259-2327).

- [ ] **Task 3B.2**: Prove the inductive step j' + 1. This is the core of GHR93 Proposition 7:
  1. Given a witness u in M with `nf_eval_nf M j' (n+2) (Fin.cons w (Fin.cons u env)) sub_nf`, use zone_match_witness to find u' in M' matching u's depth-k 1-var NF and zone position.
  2. The atom part of the (n+1)-var NF transfers using h_nf for each point.
  3. For the quantifier part at depth j': need (n+2)-var existential transfer at depth j'. Apply the INDUCTION HYPOTHESIS (at depth j') with the (n+1)-point configuration (u, env) / (u', env').
  4. The induction hypothesis requires interval data for ALL pairs in (u, env). This is the key: u's zone position relative to each env_i gives interval_nf_types agreement via:
     - If u is between env_i and env_{i+1}: sub-interval of the (env_i, env_{i+1}) interval, inheriting types from h_interval
     - If u is above/below all env points: from h_above/h_below
  5. Prove that zone_match_witness combined with the outer interval data provides all-pairs interval data for the extended configuration.

  **GHR93 reference**: This step corresponds to Proposition 7's "Duplicator collects ALL decomposition formulas witnessing how alpha splits the interval" + Lemma 11's "decomposition formula agreement implies winning strategies for BOTH sub-interval games."

- [ ] **Task 3B.3**: Prove the sub-interval inheritance lemma: if `interval_nf_types M k a c = interval_nf_types M' k a' c'` and b is in (a,c) with b' matching b's depth-k 1-var NF and zone, then `interval_nf_types M k a b = interval_nf_types M' k a' b'` AND `interval_nf_types M k b c = interval_nf_types M' k b' c'`. This may require ~30-60 lines. It is the formal content of Lemma 11 in the NF world.

- [ ] **Task 3B.4**: Build check: `lake build Bimodal.Metalogic.WeakCanonical.EFGames.StaviCompleteness`

**Sub-phase 3C: Wire nf_2var_existential_transfer to use the strengthened theorem (~30-50 lines)**

- [ ] **Task 3C.1**: Replace the sorry'd proof body of `nf_2var_existential_transfer` with a call to `nf_existential_transfer_strong` specialized to n=2. The outer hypotheses (h_nf_x, h_nf_t, h_order_xt, h_interval_above, h_interval_below, h_above_max, h_below_min) match the strengthened theorem's hypotheses for the 2-point case.

- [ ] **Task 3C.2**: Verify both sorries (lines 2347, 2429) are eliminated:
  - `lean_verify nf_2var_existential_transfer` -- no `sorryAx`
  - `lake build Bimodal.Metalogic.WeakCanonical.EFGames.StaviCompleteness` passes

**Timing**: 4-6 hours

**Depends on**: 1, 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/StaviCompleteness.lean`
  - Add `nf_existential_transfer_strong` theorem (~200-350 lines)
  - Add `sub_interval_types_from_zone_match` helper lemma (~30-60 lines)
  - Replace sorry'd proof body of `nf_2var_existential_transfer` (~30-50 lines)

**Verification**:
- `lean_verify nf_2var_existential_transfer` shows no `sorryAx`
- `lean_verify nf_2var_from_interval_data` shows no `sorryAx`
- `lake build Bimodal.Metalogic.WeakCanonical.EFGames.StaviCompleteness` passes

---

### Phase 4: Close Sorry 3 and verify cascade [NOT STARTED]

**Goal**: Fix `nf_exist_sf_guarded_backward` (line 2787) and verify the full cascade through `stavi_expressive_completeness` and the model surgery pipeline.

**CRITICAL INSTRUCTIONS FOR IMPLEMENTING AGENT**:
- Sorry 3 (line 2787) may NOT resolve automatically from Phase 3. The research report explicitly warns this needs 50-150 lines of proof work.
- The proof must: (1) extract witness x from the temporal formula (Until/Since guard), (2) determine x's 1-var NF via `char_k_correct`, (3) extract interval types from the interval guard, (4) apply the now-sorry-free `nf_2var_from_interval_data` to conclude the 2-var NF equals `sub_nf`.
- Read lines 2760-2787 and the `nf_exist_sf_guarded` forward direction carefully for the proof pattern.

**Tasks**:
- [ ] **Task 4.1**: Check if Sorry 3 resolves automatically after Phase 3:
  - `lean_verify nf_exist_sf_guarded_backward` -- check for `sorryAx`
  - If sorry-free, skip to Task 4.3.

- [ ] **Task 4.2**: If Sorry 3 persists, implement the proof (~50-150 lines):
  - Read the forward direction `nf_exist_sf_guarded` for the proof pattern (lines above 2760)
  - Extract the temporal formula witness and determine its 1-var depth-k NF
  - Extract interval guard data for the interval between the witness and t
  - Apply `nf_2var_from_interval_data` (now sorry-free) with appropriate hypotheses
  - Build to verify: `lake build Bimodal.Metalogic.WeakCanonical.EFGames.StaviCompleteness`

- [ ] **Task 4.3**: Verify the full Stavi cascade:
  - `lean_verify stavi_expressive_completeness` -- no `sorryAx`
  - `lean_verify US_expressively_complete_over_prior` -- no `sorryAx`

- [ ] **Task 4.4**: Verify the model surgery cascade (these should already be sorry-free from Phase 1):
  - `lean_verify no_gaps_discrete_model_surgery` -- no `sorryAx`
  - `lean_verify no_gaps_discrete` -- no `sorryAx`

**Timing**: 1-2 hours

**Depends on**: 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/StaviCompleteness.lean` (only if Sorry 3 needs manual fix at lines 2760-2787)

**Verification**:
- `lean_verify nf_exist_sf_guarded_backward` shows no `sorryAx`
- `lean_verify stavi_expressive_completeness` shows no `sorryAx`
- `lean_verify US_expressively_complete_over_prior` shows no `sorryAx`
- `lake build Bimodal.Metalogic.WeakCanonical.EFGames.StaviCompleteness` passes

---

### Phase 5: Rewire limitDomSubtype_isSuccArchimedean to use model surgery [NOT STARTED]

**Goal**: Replace the sorry-bearing `limitDomSubtype_isSuccArchimedean` (ChronicleToCountermodel.lean line 789) with a proof using the now-sorry-free Reynolds model surgery pipeline, eliminating the last sorryAx in the `completeness_discrete` chain.

**CRITICAL INSTRUCTIONS FOR IMPLEMENTING AGENT**:
- `succ_embed_surjective` (line 1673) currently calls the sorry'd `limitDomSubtype_isSuccArchimedean`. The fix is to make `limitDomSubtype_isSuccArchimedean` sorry-free, NOT to bypass it.
- The model surgery pipeline (`no_gaps_discrete_model_surgery`) proves that a Prior structure has no gaps. The key challenge is constructing an `OrderedMonadicStructure` on the chronicle's LimitDomSubtype and showing it satisfies Prior-UZ/SZ.
- Follow Reynolds 1994 Theorem 14 step-by-step. Read `literature/Reynolds_1994_Axiomatising_U_and_S_over_integer_time.md`.
- Do NOT revert to the finite interval approach from earlier plans.

**Literature basis**: Reynolds 1994, Theorem 14: equivalence classes don't end at gaps in Prior structures via model surgery. Burgess 1982: chronicle construction and connection to Prior structures.

**Tasks**:
- [ ] **Task 5.1**: Audit existing infrastructure for the Prior-UZ/SZ bridge:
  - Search ChronicleToCountermodel.lean and GoodStructuresModelSurgery.lean for:
    - `OrderedMonadicStructure` instances on LimitDomSubtype or similar types
    - `semantic_prior_UZ`, `semantic_prior_SZ` proofs for chronicle structures
    - `contemp_equiv` or k-type equivalence on limit domain points
  - Document what exists and what gaps remain.

- [ ] **Task 5.2**: Construct the bridge from LimitDomSubtype to the model surgery pipeline:
  - Option A (preferred): If an OrderedMonadicStructure on LimitDomSubtype exists or can be constructed easily, use it and apply `no_gaps_discrete`.
  - Option B: Prove IsSuccArchimedean directly from Prior-UZ + single equivalence class + no gaps, bypassing the model surgery abstraction.
  - Estimated: 100-200 lines.

- [ ] **Task 5.3**: Replace the sorry-bearing proof body of `limitDomSubtype_isSuccArchimedean` (lines 789-806). The new proof should derive IsSuccArchimedean from: single equivalence class (from `one_class`) + no gaps (from `no_gaps_discrete`) + discrete order.

- [ ] **Task 5.4**: Verify:
  - `lean_verify limitDomSubtype_isSuccArchimedean` -- no `sorryAx`
  - `lean_verify succ_embed_surjective` -- no `sorryAx`
  - `lake build Bimodal.Metalogic.BXCanonical.Chronicle.ChronicleToCountermodel` passes

**Timing**: 2-4 hours

**Depends on**: 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean`
  - Replace proof body of `limitDomSubtype_isSuccArchimedean` (lines 789-806)
  - May add helper lemmas for the Prior-UZ/SZ bridge (~100-200 lines)
  - Update docstrings at lines 782-787

**Verification**:
- `lean_verify limitDomSubtype_isSuccArchimedean` shows no `sorryAx`
- `lean_verify succ_embed_surjective` shows no `sorryAx`
- `lake build Bimodal.Metalogic.BXCanonical.Chronicle.ChronicleToCountermodel` passes

---

### Phase 6: Full sorry chain verification and documentation cleanup [NOT STARTED]

**Goal**: Verify `completeness_discrete` is entirely sorry-free, clean up docstrings, and write execution summary.

**Tasks**:
- [ ] **Task 6.1**: Full verification:
  - `lean_verify completeness_discrete` -- confirm no `sorryAx`
  - `lean_verify countermodel_discrete_reynolds` -- confirm no `sorryAx`
  - `lean_verify cantor_bfmcs_discrete_restricted_tc` -- confirm no `sorryAx`
  - `lean_verify cantor_bfmcs_discrete_restricted_fuc` -- confirm no `sorryAx`
  - `lean_verify succ_embed_surjective` -- confirm no `sorryAx`
  - `lake build` passes with zero errors (full project)

- [ ] **Task 6.2**: Verify no new sorry or axiom:
  - `grep -rn "^\s*sorry" Theories/` -- verify no new sorry statements
  - `grep -rn "^axiom " Theories/` -- verify no axiom declarations outside proof system

- [ ] **Task 6.3**: Documentation cleanup:
  - Update docstring at ChronicleToCountermodel.lean lines 55-92 (BX pipeline section) to reflect sorry-free status
  - Update docstring at lines 782-787 (above `limitDomSubtype_isSuccArchimedean`) to note it is now sorry-free via model surgery
  - Update StaviCompleteness.lean docstrings near the fixed sorry sites to remove references to bridge lemma being sorry'd
  - Mark dead BX pipeline code (lines 472-780: `chronicle_gap_contradiction`, old `succ_cofinal`) with "DEAD CODE" annotations

- [ ] **Task 6.4**: If any verification fails, identify and fix the remaining sorry source.

**Timing**: 1-2 hours

**Depends on**: 4, 5

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` (docstrings)
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/StaviCompleteness.lean` (docstrings)

**Verification**:
- `#print axioms completeness_discrete` -- NO `sorryAx`
- `lake build` -- zero errors
- No new sorry statements
- No extraneous axiom declarations

## Testing & Validation

- [ ] `lean_verify nf_existential_transfer_strong` shows no `sorryAx`
- [ ] `lean_verify nf_2var_existential_transfer` shows no `sorryAx`
- [ ] `lean_verify nf_2var_from_interval_data` shows no `sorryAx`
- [ ] `lean_verify nf_exist_sf_guarded_backward` shows no `sorryAx`
- [ ] `lean_verify stavi_expressive_completeness` shows no `sorryAx`
- [ ] `lean_verify US_expressively_complete_over_prior` shows no `sorryAx`
- [ ] `lean_verify no_gaps_discrete_model_surgery` shows no `sorryAx`
- [ ] `lean_verify no_gaps_discrete` shows no `sorryAx`
- [ ] `lean_verify limitDomSubtype_isSuccArchimedean` shows no `sorryAx`
- [ ] `lean_verify succ_embed_surjective` shows no `sorryAx`
- [ ] `lean_verify completeness_discrete` shows no `sorryAx`
- [ ] `lean_verify countermodel_discrete_reynolds` shows no `sorryAx`
- [ ] `lake build` passes with zero errors
- [ ] No new sorry statements introduced (`grep -rn "^\s*sorry" Theories/`)
- [ ] No `axiom` declarations outside proof system (`grep -rn "^axiom " Theories/`)

## Artifacts & Outputs

- `specs/155_reynolds_pipeline_activation/plans/60_implementation-plan.md` (this file, v63)
- Modified `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/StaviCompleteness.lean` (strengthened induction, sorry elimination)
- Modified `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` (rewired IsSuccArchimedean)

## Rollback/Contingency

If the strengthened induction approach (Phase 3) hits a wall:

1. **Fallback A -- Reduced strengthening**: Instead of carrying interval data for ALL pairs, carry it only for ADJACENT pairs in a specific ordering. This simplifies the invariant but may require proving that zone_match_witness preserves adjacency structure.

2. **Fallback B -- Double induction on (k, n)**: The critic (teammate C in report 60) identified an unexplored alternative: double induction where the hypothesis carries depth-k interval types for ALL sub-intervals. This was never attempted and might avoid the complexity of the full game-theoretic argument.

3. **Fallback C -- EF Game Bridge (plan v62 revised)**: Return to the NFGameBridge approach but target `ghr93_winning_condition` instead of `decomposition_agreement`/`interval_types`, fixing the interface mismatch identified by the critic. This is a last resort as it requires ~400-600 lines of new bridge code.

4. **Safe revert**: `git checkout -- Theories/Bimodal/Metalogic/WeakCanonical/EFGames/StaviCompleteness.lean` and `git checkout -- Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean`. Phases 1-2 changes are preserved (committed separately).
