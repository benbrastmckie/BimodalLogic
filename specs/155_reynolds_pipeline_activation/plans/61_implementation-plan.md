# Implementation Plan: Task #155

- **Task**: 155 - Eliminate all sorries from completeness_discrete by fixing root sorries in two chains
- **Status**: [NOT STARTED]
- **Effort**: 14-22 hours
- **Dependencies**: None (Phases 1 and 2 from prior plan v64 are completed)
- **Research Inputs**: specs/155_reynolds_pipeline_activation/reports/61_team-research.md
- **Artifacts**: plans/61_implementation-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-formats.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

This plan eliminates all `sorryAx` from `completeness_discrete` by fixing root sorries in two independent chains. Chain 1 blocks through the Stavi expressive completeness pipeline (`nf_2var_existential_transfer` in StaviCompleteness.lean, 3 sorry sites at lines 2347, 2429, 2787) which flows to `completeness_discrete` via PriorExpressiveness -> GoodStructuresModelSurgery -> NoGapsDiscreteProof -> ShiftAndGlue -> ChronicleToCountermodel. Chain 2 blocks through the IsSuccArchimedean pipeline (`chronicle_gap_contradiction` sorry at line 472 -> `succ_cofinal` -> `limitDomSubtype_isSuccArchimedean` -> `succ_embed_surjective` -> `cantor_bfmcs_discrete_restricted_tc/fuc`). The prior plan v64's direct proof approach for Chain 1 is confirmed BLOCKED after 5 failed sessions. This plan uses the EF Game Bridge approach for Chain 1 and restructures the coherence conditions via the Reynolds k-equivalence pipeline for Chain 2.

### Research Integration

- **Team research (61_team-research.md)**: Confirmed Chain 1 EF Game Bridge approach (~300-430 lines). Identified critical type mismatch in Chain 2: `good` provides EF-game strategies, not concrete integer witnesses. Teammate D's claim that Chain 1 may not block `completeness_discrete` is REFUTED by import tracing (PriorExpressiveness.lean line 2 imports StaviCompleteness, and GoodStructuresModelSurgery uses `US_expressively_complete_over_prior` at 15+ call sites).
- **GoodStructuresModelSurgery.lean is sorry-free**: Verified by code analysis. `gap_prior_UZ_contradiction` is fully proved (~850 lines), `gap_prior_SZ_contradiction` delegates to it.

### Prior Plan Reference

Plan v64 attempted direct proof of `nf_2var_existential_transfer` (Phase 3, now BLOCKED after 5 failed sessions). The interval splitting problem is genuine: zone matching cannot provide multi-variable simultaneous orderings for the depth j'+1 inductive step. Plan v64 Phase 4 (restructure coherence via k-equivalence) remains the right approach for Chain 2, but the type mismatch between abstract k-equivalence and concrete coherence conditions requires careful design.

### Roadmap Alignment

- Closing both sorry chains achieves sorry-free `completeness_discrete`
- ROADMAP critical path: Task 155 -> Task 202 (Reynolds k-equivalence bypass) -> sorry-free `completeness_discrete`
- ROADMAP WARNING respected: this plan does NOT propose proving `IsSuccArchimedean` directly

## Goals & Non-Goals

**Goals**:
- Prove `nf_2var_existential_transfer` via EF Game Bridge, eliminating Chain 1 root sorries (lines 2347, 2429 in StaviCompleteness.lean)
- Cascade Chain 1 fix to make `nf_2var_from_interval_data`, `nf_exist_sf_guarded_backward` (line 2787), `stavi_expressive_completeness`, and `US_expressively_complete_over_prior` sorry-free
- Restructure `countermodel_discrete_reynolds` to bypass `succ_embed_surjective` entirely using the Reynolds `one_class -> good -> k_equiv` pipeline (Chain 2)
- `#print axioms completeness_discrete` shows no `sorryAx`
- `lake build` passes
- No new `sorry` or `axiom` declarations outside the proof system or frame constraints

**Non-Goals**:
- Proving `IsSuccArchimedean` for `LimitDomSubtype` (ROADMAP WARNING: not how Reynolds does it)
- Fixing `chronicle_gap_contradiction` or `succ_cofinal` (dead BX pipeline code)
- Fixing the general `completeness` theorem (uses Base frame class, separate task 129)
- Fixing CaseAnalysis.lean sorries (not on critical path per team research)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| EF Game Bridge requires more than 500 lines due to NF-to-rank_type translation complexity | M | M | Core game infrastructure (Composition.lean, Decomposition.lean) is sorry-free. The bridge is a type-level translation, not new mathematics. Literature reference: GHR93 Proposition 7. |
| k-equivalence from `good` is only monadic k-equivalence, insufficient for coherence conditions | H | M | Reynolds Theorem 18 (Section 9, p.132): choose k > quantifier_depth(table(phi)). Coherence conditions (F/P-resolution, U/S-guard) involve formulas in `subformulaClosure(phi)` with bounded quantifier depth. The k-equivalence preserves truth of these formulas. |
| Restructuring `countermodel_discrete_reynolds` to bypass `succ_embed_surjective` may require large refactor | H | L | The `good` structure directly provides a Z-interval structure. `chronicle_is_good_direct` (ShiftAndGlue.lean:950) is sorry-free. The FMCS on Z can be constructed by transferring MCS data through the k-equivalence witness. |
| Circularity: NF bridge depends on game infrastructure which may transitively depend on NF | H | L | Verified: `nf_profile_determines_rank_type` does NOT depend on `nf_2var_from_interval_data`. `ghr93_strategy_compose` is sorry-free in Composition.lean. No circularity. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 3 | 1 |
| 3 | 4 | 2, 3 |
| 4 | 5 | 4 |

Phases within the same wave can execute in parallel.

### Phase 1: Verify critical path and confirm sorry sources [NOT STARTED]

**Goal**: Run `#print axioms completeness_discrete` and trace the exact sorry chains to confirm which sorry sites block the main theorem. Verify that `GoodStructuresModelSurgery.lean` is indeed sorry-free. This verification must happen before investing 300+ lines in either chain.

**Tasks**:
- [ ] Run `lean_verify completeness_discrete` (fully qualified) to check for `sorryAx`
- [ ] Run `lean_verify countermodel_discrete_reynolds` to check sorry chain
- [ ] Run `lean_verify US_expressively_complete_over_prior` to confirm Chain 1 is on the critical path
- [ ] Run `lean_verify no_gaps_discrete_model_surgery` to confirm model surgery is sorry-free
- [ ] Run `lean_verify chronicle_is_good_direct` to confirm it is sorry-free
- [ ] Run `lean_verify succ_embed_surjective` to confirm Chain 2 sorry source
- [ ] Document which sorry chains actually block `completeness_discrete` and update plan if any assumptions are wrong

**Timing**: 1 hour

**Depends on**: none

**Files to modify**:
- None (verification only)

**Verification**:
- Complete picture of which sorries block `completeness_discrete`
- Plan assumptions confirmed or corrected

---

### Phase 2: Build EF Game Bridge for Chain 1 [NOT STARTED]

**Goal**: Prove `nf_2var_existential_transfer` by building a bridge between NF hypotheses and the sorry-free EF game composition infrastructure. This eliminates the root sorry of Chain 1 (3 sorry sites in StaviCompleteness.lean).

**CRITICAL INSTRUCTIONS**:
- Do NOT attempt the direct proof approach (Phase 3 of plan v64, confirmed BLOCKED after 5 sessions)
- Build the bridge in NFGameBridge.lean (or extend StaviCompleteness.lean)
- The bridge has two directions:
  - Bridge A: NF hypotheses -> `decomposition_agreement` (game language)
  - Bridge B: `ghr93_duplicator_wins` -> NF agreement
- Use the sorry-free `ghr93_strategy_compose` from Composition.lean
- Literature: GHR93 Proposition 7 (pp.113-115)

**Tasks**:
- [ ] **Task 2.1**: Study the interface of the EF game infrastructure. Read Composition.lean (`ghr93_strategy_compose`), Decomposition.lean, and the rank_type/ExtendedCarrier definitions. Understand what `decomposition_agreement` requires as input and what `ghr93_duplicator_wins` produces as output.
- [ ] **Task 2.2**: Implement Bridge A -- `nf_char_eq_implies_rank_type_eq`: depth-k NF equality implies rank_type equality. Uses the sorry-free `nf_profile_determines_rank_type` from CharacteristicFormula.lean.
- [ ] **Task 2.3**: Implement Bridge A continued -- `interval_nf_types_implies_interval_types`: translate interval NF type sets to game interval types, and `nf_hypotheses_imply_duplicator_wins`: bridge NF hypotheses to duplicator winning strategies.
- [ ] **Task 2.4**: Implement Bridge B -- `duplicator_wins_implies_nf_agreement`: translate game-winning duplicator strategy back to 2-variable NF equality.
- [ ] **Task 2.5**: Wire the bridge into `nf_2var_existential_transfer`. Replace the two sorries (lines 2347, 2429) with calls through Bridge A -> `ghr93_strategy_compose` -> Bridge B.
- [ ] **Task 2.6**: Verify Chain 1 cascade:
  - `lean_verify nf_2var_existential_transfer` shows no `sorryAx`
  - `lean_verify nf_2var_from_interval_data` shows no `sorryAx`
  - `lean_verify nf_exist_sf_guarded_backward` shows no `sorryAx` (the sorry at line 2787 should cascade-resolve)
  - `lean_verify stavi_expressive_completeness` shows no `sorryAx`
  - `lean_verify US_expressively_complete_over_prior` shows no `sorryAx`
  - `lake build Bimodal.Metalogic.WeakCanonical.EFGames.StaviCompleteness` passes

**Timing**: 6-10 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/NFGameBridge.lean` (new or extended, ~300-430 lines of bridge code)
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/StaviCompleteness.lean` (wire bridge into sorry sites at lines 2347, 2429)

**Verification**:
- `lean_verify nf_2var_existential_transfer` shows no `sorryAx`
- `lean_verify US_expressively_complete_over_prior` shows no `sorryAx`
- `lake build Bimodal.Metalogic.WeakCanonical.EFGames.StaviCompleteness` passes

---

### Phase 3: Restructure countermodel_discrete_reynolds to bypass succ_embed_surjective [NOT STARTED]

**Goal**: Replace the `succ_embed_surjective`-based coherence condition proofs with proofs that work through the already sorry-free Reynolds pipeline (`one_class -> good -> k_equiv to Z`). This eliminates the Chain 2 sorry dependency on `IsSuccArchimedean`.

**CRITICAL INSTRUCTIONS**:
- Do NOT attempt to prove `IsSuccArchimedean` for `LimitDomSubtype` (ROADMAP WARNING)
- Do NOT fix `chronicle_gap_contradiction` or `succ_cofinal` (dead BX pipeline code)
- The sorry-free pipeline:
  1. `one_class` (NoGapsDiscreteProof.lean:88, sorry-free)
  2. `one_class_implies_very_good` (ShiftAndGlue.lean:919, sorry-free)
  3. `very_good_implies_good` (ShiftAndGlue.lean:831, sorry-free)
  4. `chronicle_is_good_direct` (ShiftAndGlue.lean:950, sorry-free)
- The `good` result produces: `exists (Z : ZIntervalStructure sig), k_equiv sig k M Z.toOrdered`
- **Key type mismatch**: The current coherence conditions (`cantor_bfmcs_discrete_restricted_tc/fuc`) require concrete integer witnesses via `succ_embed_surjective`. The `good` structure provides k-equivalence (game strategies), not concrete integers.
- **Solution approach**: Restructure `countermodel_discrete_reynolds` to build the FMCS on the Z-interval structure from `good` rather than on the chronicle's limit domain. The Z-interval IS an integer structure, so the BFMCS can be constructed directly on Z without needing `succ_embed_surjective`.

**Tasks**:
- [ ] **Task 3.1**: Analyze `countermodel_discrete_reynolds` (Transfer.lean:1203-1247). Understand the exact interface it provides to `completeness_discrete` and what `cantor_bfmcs_discrete` constructs (BFMCS bundle + restricted coherence conditions).
- [ ] **Task 3.2**: Analyze `chronicle_is_good_direct` (ShiftAndGlue.lean:950-971). Understand the concrete output: `good sig k (chronicleAsMonadicStructure M sig atomMap)` which unfolds to `exists Z, k_equiv sig k M Z.toOrdered`. Determine if `Z.toOrdered` provides SuccOrder/PredOrder/IsSuccArchimedean instances.
- [ ] **Task 3.3**: Design the restructured countermodel. Key insight from Reynolds Theorem 18: choose k = 1 + quantifier_depth(table(phi)). The Z-interval structure from `good` satisfies the same monadic sentences of depth <= k. Build the FMCS on Z by defining MCS(n) = the MCS determined by the k-equivalence at point n.
- [ ] **Task 3.4**: Implement the restructured `countermodel_discrete_reynolds`:
  1. Build the chronicle `ChronicleAsPriorModel` from the discrete MCS (existing code)
  2. Apply `chronicle_is_good_direct` to get `good sig k M_struct` (sorry-free)
  3. Extract the Z-interval structure Z and k-equivalence
  4. Build BFMCS bundle on Z using the Z-interval structure
  5. Prove restricted coherence conditions directly on Z (the Z-interval IS Z, so integer witnesses are trivially available)
- [ ] **Task 3.5**: Verify Chain 2 fix:
  - `lean_verify countermodel_discrete_reynolds` shows no `sorryAx`
  - `lake build Bimodal.Metalogic.WeakCanonical.Transfer` passes

**Timing**: 6-10 hours

**Depends on**: 1 (independent of Phase 2; can run in parallel)

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Transfer.lean` (restructure `countermodel_discrete_reynolds`)
- Possibly new `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/GoodCountermodel.lean` (helper lemmas for good-based BFMCS construction)
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` (mark `succ_embed_surjective`-based path as dead code)

**Key existing sorry-free infrastructure**:
- `chronicle_is_good_direct` (ShiftAndGlue.lean:950) -- gives `good sig k M`
- `one_class` (NoGapsDiscreteProof.lean:88) -- all points contemporaneously equivalent
- `limit_F_resolution`, `limit_P_resolution` (ChronicleToCountermodelBasic.lean) -- F/P witnesses
- `limit_satisfies_c5_strong`, `limit_satisfies_c5'_strong` (ChronicleToCountermodelBasic.lean) -- U/S witnesses
- `gap_prior_UZ_contradiction` (GoodStructuresModelSurgery.lean) -- sorry-free model surgery

**Verification**:
- `lean_verify countermodel_discrete_reynolds` shows no `sorryAx`
- `lake build Bimodal.Metalogic.WeakCanonical.Transfer` passes

---

### Phase 4: Full sorry cascade verification [NOT STARTED]

**Goal**: Verify that both Chain 1 and Chain 2 fixes cascade through to make `completeness_discrete` entirely sorry-free.

**Tasks**:
- [ ] **Task 4.1**: Verify Chain 1 cascade:
  - `lean_verify nf_2var_existential_transfer` -- no `sorryAx`
  - `lean_verify nf_2var_from_interval_data` -- no `sorryAx`
  - `lean_verify nf_exist_sf_guarded_backward` -- no `sorryAx`
  - `lean_verify stavi_expressive_completeness` -- no `sorryAx`
  - `lean_verify US_expressively_complete_over_prior` -- no `sorryAx`
- [ ] **Task 4.2**: Verify model surgery pipeline is sorry-free:
  - `lean_verify gap_prior_UZ_contradiction` -- no `sorryAx`
  - `lean_verify reynolds_model_surgery_core` -- no `sorryAx`
  - `lean_verify no_gaps_discrete_model_surgery` -- no `sorryAx`
  - `lean_verify no_gaps_discrete` -- no `sorryAx`
- [ ] **Task 4.3**: Verify Chain 2 cascade:
  - `lean_verify countermodel_discrete_reynolds` -- no `sorryAx`
- [ ] **Task 4.4**: Final completeness verification:
  - `lean_verify completeness_discrete` -- no `sorryAx`
  - `lake build` passes with zero errors (full project)
  - `grep -rn "^\s*sorry" Theories/` -- verify no new sorry statements introduced by this task
  - `grep -rn "^axiom " Theories/` -- verify no axiom declarations outside proof system/frame constraints
- [ ] **Task 4.5**: If any verification fails, identify the remaining sorry source and document what additional work is needed.

**Timing**: 1-2 hours

**Depends on**: 2, 3

**Files to modify**:
- None expected (verification only), unless sorry traces are found

**Verification**:
- `#print axioms completeness_discrete` -- NO `sorryAx`
- `lake build` -- zero errors
- No new sorry statements
- No extraneous axiom declarations

---

### Phase 5: Documentation cleanup and dead code annotation [NOT STARTED]

**Goal**: Update docstrings referencing the old sorry chain, mark dead BX pipeline code, and update the audit section.

**Tasks**:
- [ ] Update ChronicleToCountermodel.lean file-level docstring (lines 55-91) to note that the `succ_embed_surjective` path is dead code and coherence conditions are restructured via `good`-based approach
- [ ] Update docstring above `limitDomSubtype_isSuccArchimedean` (line 782-787) to note it is dead code -- the Reynolds pipeline does not require `IsSuccArchimedean`
- [ ] Update docstring above `succ_embed_surjective` (line 811-817) to note it is no longer used by `completeness_discrete`
- [ ] Update StaviCompleteness.lean docstrings near the fixed sorry sites to note the EF Game Bridge resolution
- [ ] Mark dead BX pipeline code (`chronicle_gap_contradiction`, `succ_cofinal`, old `limitDomSubtype_isSuccArchimedean`) with "DEAD CODE -- bypassed by Reynolds good-structure path" annotations
- [ ] Update the audit section in Completeness.lean (lines 376-388) to reflect sorry-free status for `completeness_discrete`

**Timing**: 1 hour

**Depends on**: 4

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` -- update docstrings
- `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` -- update audit comments
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/StaviCompleteness.lean` -- update docstrings
- `Theories/Bimodal/Metalogic/WeakCanonical/Transfer.lean` -- update docstrings

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
- [ ] `lean_verify countermodel_discrete_reynolds` shows no `sorryAx`
- [ ] `lean_verify completeness_discrete` shows no `sorryAx`
- [ ] `lake build` passes with zero errors
- [ ] No new sorry statements introduced (`grep -rn "^\s*sorry" Theories/`)
- [ ] No `axiom` declarations outside proof system (`grep -rn "^axiom " Theories/`)

## Artifacts & Outputs

- `specs/155_reynolds_pipeline_activation/plans/61_implementation-plan.md` (this file)
- Modified/new `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/NFGameBridge.lean` (~300-430 lines of EF bridge code)
- Modified `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/StaviCompleteness.lean` (wire bridge into sorry sites)
- Modified `Theories/Bimodal/Metalogic/WeakCanonical/Transfer.lean` (restructured `countermodel_discrete_reynolds`)
- Possibly new `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/GoodCountermodel.lean`
- Modified `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` (docstrings)
- Modified `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` (audit update)

## Rollback/Contingency

**Chain 1 (EF Game Bridge) fallback**:

1. **Fallback A -- Generalize game infrastructure**: If the NF-to-rank_type bridge is too complex, extend the game infrastructure in Composition.lean to accept NF-level inputs directly, adding a thin adapter layer rather than full type translation.

2. **Fallback B -- Prove `nf_2var_from_interval_data` by alternative method**: Bypass `nf_2var_existential_transfer` entirely. If there exists a way to prove `nf_2var_from_interval_data` that does not go through the existential transfer (e.g., by using game-theoretic arguments at a higher level), pursue that.

3. **Safe revert**: `git checkout -- Theories/Bimodal/Metalogic/WeakCanonical/EFGames/` to restore files. Phases 1-2 from prior plan are preserved.

**Chain 2 (k-equivalence bypass) fallback**:

1. **Fallback A -- Prove IsSuccArchimedean via Path E**: Despite the ROADMAP warning, if the k-equivalence transfer proves technically difficult in Lean, a direct 300-600 line proof that the omega-chain construction produces an IsSuccArchimedean structure may be viable. The ROADMAP warning is about the mathematical approach; the direct proof may still be technically possible even if it does not follow Reynolds.

2. **Fallback B -- Alternative FMCS construction on Z**: Instead of restructuring existing coherence conditions, construct a completely new FMCS on Z from scratch using the `good` structure's Z-interval isomorphism. Prove coherence conditions for this new FMCS independently.

3. **Safe revert**: `git checkout -- Theories/Bimodal/Metalogic/WeakCanonical/Transfer.lean` to restore. Prior work preserved.
