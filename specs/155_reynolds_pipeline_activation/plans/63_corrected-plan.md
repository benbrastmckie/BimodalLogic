# Implementation Plan: Task #155 (v64 -- Literature-Faithful Correction)

- **Task**: 155 - Eliminate all sorries from completeness_discrete by proving `nf_2var_existential_transfer` (Chain 1 root) and restructuring Chain 2 to use the Reynolds one_class/good/k_equiv path instead of succ_embed_surjective
- **Status**: [NOT STARTED]
- **Effort**: 10-18 hours
- **Dependencies**: None (Phases 1 and 2 from plan v62 are completed)
- **Research Inputs**: specs/155_reynolds_pipeline_activation/reports/61_blocker-escalation-research.md, specs/155_reynolds_pipeline_activation/reports/61_depth-mismatch-literature.md, specs/155_reynolds_pipeline_activation/reports/60_blocker-resolution.md, specs/155_reynolds_pipeline_activation/reports/58_proper-fix-research.md
- **Artifacts**: plans/63_corrected-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-formats.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

This is plan v64, correcting a fundamental error in plan v63's Chain 2 approach. Plan v63 proposed proving `limitDomSubtype_isSuccArchimedean` directly from the omega-chain construction. A literature review confirms this approach does not follow Reynolds 1994: the paper never proves `IsSuccArchimedean` for the limit domain. Instead, Reynolds uses the `one_class -> very_good -> good -> k_equiv to integer structure` path (Theorem 15, Lemma 16).

**Critical correction**: The codebase already has `one_class` proved sorry-free in `NoGapsDiscreteProof.lean` (lines 88-112). The pipeline `one_class -> one_class_implies_very_good -> very_good_implies_good` is fully sorry-free in `ShiftAndGlue.lean` and produces a `good` structure (k-equivalent to a Z-interval). The real problem is that the coherence conditions (`cantor_bfmcs_discrete_restricted_tc` and `cantor_bfmcs_discrete_restricted_fuc`) use `succ_embed_surjective`, which requires `IsSuccArchimedean`. The literature-faithful fix is to restructure these coherence condition proofs to use the already-proved `good` structure instead.

**Strategy**: For Chain 2, we replace the `succ_embed_surjective`-based coherence proofs with ones that work through the Reynolds pipeline:
1. Apply `chronicle_is_good_direct` (ShiftAndGlue.lean:950, sorry-free) to the limit domain
2. This gives `good sig k M` -- a Z-interval structure Z and a k-equivalence M ~k Z
3. Prove the coherence conditions by transferring F/P-resolution and U/S-resolution through the k-equivalence, which acts as a monadic isomorphism at depth k

Chain 1 approach (prove `nf_2var_existential_transfer` directly) is unchanged from plan v63.

Definition of done: `#print axioms completeness_discrete` shows no `sorryAx`, `lake build` passes, no `axiom` declarations outside the proof system or frame constraints.

### Research Integration

- **Report 61 (blocker escalation)**: Primary input for Chain 1 correction. Identified `nf_2var_existential_transfer` as the single root sorry of Chain 1.
- **Report 61 (depth mismatch literature)**: Confirmed depth-k NF -> rank_type relationship.
- **Report 60 (blocker resolution)**: Diagnosed the interval-splitting problem. Confirmed game infrastructure is sorry-free.
- **Report 58 (proper fix research)**: Model surgery limitation for IsSuccArchimedean.
- **Literature correction (plan v64 motivation)**: Reynolds 1994 Sections 8-9, Theorem 15, Lemma 16 confirm the one_class/good/k_equiv path. GHR93 provides the EF game composition for Chain 1.

### Literature Sources

| Phase | Primary Literature | Specific Result |
|-------|-------------------|-----------------|
| Phase 3 | `literature/Gabbay_Hodkinson_Reynolds_1993_Temporal_expressive_completeness_gaps.md` pp.113-115 | Proposition 7: EF game composition, inductive strategy for existential transfer |
| Phase 3 | `literature/Gabbay_Hodkinson_Reynolds_1994_Temporal_Logic_Foundations_Vol1_ch9.md` | Ch. 9: monadic NF framework, depth-j quantifier transfer |
| Phase 4 | `literature/Reynolds_1994_Axiomatising_U_and_S_over_integer_time.md` Sections 8-9 | Theorem 15: `one_class` -> `very_good` -> `good` -> k-equiv to Z. Lemma 16: very good + countable implies good (lexicographic sum). |

### Prior Plan Reference

Plan v63 Phase 4 ("Prove IsSuccArchimedean directly from omega-chain") is WRONG and is replaced by Phase 4 of this plan ("Restructure coherence conditions via k-equivalence"). The literature never proves `IsSuccArchimedean` for the limit domain. Instead, Reynolds constructs an integer model via the `good` property and lexicographic sums.

### Roadmap Alignment

- Closing both sorry chains achieves sorry-free `completeness_discrete`
- Eliminates all axiom declarations outside the proof system
- Advances critical path: Task 155 -> sorry-free `completeness_discrete`

## Goals & Non-Goals

**Goals**:
- Prove `nf_2var_existential_transfer` by induction on depth j, completing the 3-point configuration quantifier transfer (Chain 1 root)
- Restructure `cantor_bfmcs_discrete_restricted_tc` and `cantor_bfmcs_discrete_restricted_fuc` to avoid `succ_embed_surjective` entirely, using the Reynolds `one_class -> good -> k_equiv` pipeline instead
- Restructure `countermodel_discrete_reynolds` to construct its FMCS on Z via the `good` structure's Z-interval isomorphism rather than via `succ_embed`
- Verify that fixing Chain 1 cascades to make `stavi_expressive_completeness` and the model surgery pipeline sorry-free
- `#print axioms completeness_discrete` shows no `sorryAx`
- `lake build` passes
- No `axiom` declarations outside the proof system or frame constraints

**Non-Goals**:
- Proving `IsSuccArchimedean` for `LimitDomSubtype` (this is unnecessary per the literature)
- Building the EF Game Bridge in NFGameBridge.lean (deferred; not needed if direct proof works)
- Proving `chronicle_gap_contradiction` or `succ_cofinal` (dead BX pipeline code)
- Fixing the general `completeness` theorem (uses Base frame class, separate task 129)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Direct proof of `nf_2var_existential_transfer` requires more than 400 lines due to 3-point sub-interval matching | M | M | All zone-matching infrastructure exists (zone_match_witness, atom agreement). The inductive step follows GHR93 Proposition 7 (pp.113-115). If blocked, fall back to EF Game Bridge approach from plan v62 Phase 3. |
| The k-equivalence from `good` is only a monadic k-equivalence, not a full isomorphism -- coherence conditions might need more than k-equivalence | H | M | The coherence conditions (F/P-resolution, U/S-guard) are about formulas in `subformulaClosure(phi)`, which have bounded quantifier depth. Reynolds Theorem 15 gives k-equivalence for any k; we choose k > quantifier depth of phi's table. See Reynolds 1994, Section 9 (Theorem 18). |
| Restructuring `countermodel_discrete_reynolds` to use `good`-based FMCS may require significant refactoring of the parametric canonical model | H | M | The `good` property directly provides a Z-interval structure. The existing `chronicle_is_good_direct` (ShiftAndGlue.lean:950) is sorry-free and already computes `good`. The FMCS on Z can be defined via the k-equivalence: `mcs(n) = limit_f(iso.symm(n))` where `iso` is the Z-interval isomorphism. |
| The k-equivalence preserves monadic sentences of depth <= k, but coherence conditions involve properties at specific points, not sentences | H | L | F(phi) in mcs(t) is a property of the limit domain's F-resolution (sorry-free). The Z-integer model inherits this via the k-equivalence because F(phi) is a formula of bounded rank. See the proof strategy in Phase 4. |

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

### Phase 3: Prove nf_2var_existential_transfer [BLOCKED]

**Goal**: Complete the proof of `nf_2var_existential_transfer` (StaviCompleteness.lean, lines 2214-2429) by providing the inductive quantifier transfer for 3-point configurations at depth j'+1. This eliminates the root sorry of Chain 1 (Stavi expressive completeness).

**CRITICAL INSTRUCTIONS FOR IMPLEMENTING AGENT**:
- The two sorries are at lines 2347 (forward direction) and 2429 (backward direction).
- The proof structure is already in place: zone matching finds u' with matching 1-var NF and correct orderings. What remains is showing depth-j 3-var NF agreement at (u,x,t)/(u',x',t').
- For j=0: the depth-0 3-var NF is just atoms (predicates + orderings). Zone matching gives correct orderings, and 1-var NF agreement gives predicates. This case should already work from the existing code.
- For j>=1: the inductive hypothesis gives the transfer at depth j-1. The quantifier transfer at depth j requires sub-interval matching for the 3-point configuration. This is GHR93 Proposition 7's inductive step.
- Read `literature/Gabbay_Hodkinson_Reynolds_1993_Temporal_expressive_completeness_gaps.md` pages 113-115 (Lemma 11, Proposition 7, Corollary 5) for the exact argument structure. Key: the Duplicator's strategy in the EF game corresponds to choosing w' that maintains the invariant. The depth decrease from j'+1 to j' matches the game round consumption.
- Read `literature/Gabbay_Hodkinson_Reynolds_1994_Temporal_Logic_Foundations_Vol1_ch9.md` for the NF/depth correspondence.
- Do NOT attempt to build the EF Game Bridge (plan v62 approach). Work directly within StaviCompleteness.lean.
- Do NOT use `sorry` or `axiom` as fallbacks. If blocked, report what was tried and what goal state was reached.

**Tasks**:

- [x] **Task 3.1**: Read and understand the existing proof structure at lines 2214-2430. Identify exactly what the goal state is at each sorry (lines 2347 and 2429). Use `lean_goal` to inspect the proof state at both sorry sites. *(deviation: altered -- analyzed via code reading without lean_goal MCP tool)*

**BLOCKER** (Phase 3):
- **What failed**: The existential transfer at depth j'+1 requires 4-variable existential transfer at depth j' for the 3-point configuration (u,x,t)/(u',x',t'). Zone matching provides u' with matching 1-var NF and orderings with x', t', but NOT the correct ordering with an inner variable w' relative to u'. This is the "interval splitting problem" documented in NFGameBridge.lean.
- **What was tried**: (1) Direct proof by matching on j -- fails because the IH is at 2+1=3 variables but the step needs 3+1=4 variables. (2) Generalization to n-variable bases -- fails because zone matching still needs interval types between all pairs, which are unavailable for pairs involving newly matched points. (3) Double induction on depth and variables -- terminates at depth 0 atom agreement but the multi-variable matching problem persists at every depth. (4) Using nf_agreement_monotone to step down from depth-k agreement -- circular, requires depth-k n-var agreement which is what we're trying to prove.
- **Why it's stuck**: The direct NF approach fundamentally cannot solve the multi-variable simultaneous matching problem. NFGameBridge.lean documents 5 failed sessions. The correct approach requires the EF game compositional infrastructure (Composition.lean, Decomposition.lean), which splits intervals while maintaining the game invariant. Building the NF-to-game bridge (Bridge A: NF hypotheses -> decomposition_agreement; Bridge B: ghr93_duplicator_wins -> NF agreement) requires ~300-500 lines connecting NormalForm/nf_eval_nf with rank_type/ExtendedCarrier.
- **What is needed**: Either (a) build the EF Game Bridge (plan v62 Phase 3, explicitly ruled out by this plan), or (b) prove nf_2var_from_interval_data by a different method that bypasses nf_2var_existential_transfer entirely.
- **Prohibited workarounds**: Do NOT use `sorry`, `def X := True`, or any vacuous placeholder.

- [ ] **Task 3.2**: Handle the j=0 base case. *(deviation: skipped -- Phase 3 blocked before implementation)* At depth 0, the 3-var NF is determined entirely by atoms (predicates at each variable + orderings between variables). Zone matching provides ordering agreement for all pairs (u,x), (u,t), (x,t) and their primed counterparts. 1-var NF agreement at depth k (which is >= j=0) gives predicate agreement. Prove `nf_eval_nf M 0 (2+1) ... chi` transfers from (u,x,t) to (u',x',t') using atom agreement.

- [ ] **Task 3.3**: Handle the j=j'+1 inductive step (forward direction, line 2347). *(deviation: skipped -- Phase 3 blocked)* The depth-(j'+1) 3-var NF chi decomposes into: (a) atoms at 3 variables, and (b) existential quantifiers over a 4th variable at depth j'. Part (a) is handled by zone matching + NF agreement. For part (b), given a 4th variable w in M witnessing the existential, find w' in M' such that the depth-j' 4-var NF at (w,u,x,t) equals that at (w',u',x',t'). This requires:
  - Zone matching w to w' using the 1-var NF data and interval types between all relevant pairs
  - Applying the inductive hypothesis at depth j' (one lower) to transfer the quantifier

  **Literature reference**: GHR93 Proposition 7 (p.114): the Duplicator's strategy in the game corresponds to choosing w' that maintains the invariant. The depth decrease from j'+1 to j' matches the game round consumption.

- [ ] **Task 3.4**: Handle the j=j'+1 inductive step (backward direction, line 2429). *(deviation: skipped -- Phase 3 blocked)*

- [ ] **Task 3.5**: Verify the proof compiles and eliminates the sorries: *(deviation: skipped -- Phase 3 blocked)*
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

### Phase 4: Restructure coherence conditions via Reynolds k-equivalence path [IN PROGRESS]

**Goal**: Replace the `succ_embed_surjective`-based coherence condition proofs in `ChronicleToCountermodel.lean` with proofs that work through the already sorry-free Reynolds pipeline (`one_class -> good -> k_equiv to Z`). This eliminates the entire Chain 2 sorry dependency.

**CRITICAL INSTRUCTIONS FOR IMPLEMENTING AGENT**:
- Do NOT attempt to prove `IsSuccArchimedean` for `LimitDomSubtype`. This is NOT how the literature handles the problem (Reynolds 1994, Sections 8-9).
- Do NOT fix `chronicle_gap_contradiction` or `succ_cofinal`. These are dead BX pipeline code.
- The already sorry-free pipeline is:
  1. `one_class` (NoGapsDiscreteProof.lean:88, sorry-free)
  2. `one_class_implies_very_good` (ShiftAndGlue.lean:919, sorry-free)
  3. `very_good_implies_good` (ShiftAndGlue.lean:831, sorry-free)
  4. `chronicle_is_good_direct` (ShiftAndGlue.lean:950, sorry-free -- packages steps 1-3 for ChronicleAsPriorModel)
- The `good` result produces: `exists (Z : ZIntervalStructure sig), k_equiv sig k M Z.toOrdered`
- The k-equivalence means: for all monadic sentences sigma of quantifier depth <= k, `M |= sigma iff Z.toOrdered |= sigma`
- **Key literature reference**: Reynolds 1994, Theorem 18 (Section 9, page 132): "Let k be one greater than the quantifier depth of the table alpha(t) of A_0. We have a temporal structure Z, with flow of time the integers, satisfying the same monadic sentences of quantifier depth at most k as M does."
- **How this replaces succ_embed_surjective**: The current coherence proofs work by (a) getting a witness y in the limit domain via `limit_F_resolution`, then (b) mapping y to an integer via `succ_embed_surjective`. The new approach: (a) the `good` structure gives a Z-interval structure Z that is k-equivalent to the limit domain, (b) construct the FMCS on Z directly by defining `mcs(n) = limit_f(iso_point(n))` where `iso_point` maps Z-interval elements to limit domain elements via the k-equivalence witness, (c) the coherence conditions follow from the F/P-resolution and U/S-resolution properties of the limit domain, transferred through the strict monotone embedding that the `good` structure provides.

**Alternative simpler approach**: Instead of restructuring the coherence conditions through k-equivalence, consider the following more direct route:
- The `countermodel_discrete_reynolds` theorem (Transfer.lean:1203) can be restructured to use `chronicle_is_good_direct` to get `good sig k M` for the chronicle's monadic structure
- The `good` result gives a `ZIntervalStructure` and a k-equivalence to Z
- Since Z is literally an integer interval, we can build the FMCS on Z by transferring the MCS data through the k-equivalence
- The coherence conditions are inherited because the k-equivalence preserves all sentences of depth <= k, and F(phi)/U(phi,psi) are formulas of bounded rank

**Tasks**:

- [ ] **Task 4.1**: Analyze the structure of `countermodel_discrete_reynolds` (Transfer.lean:1203-1247). It currently calls `cantor_bfmcs_discrete_restricted_tc` and `cantor_bfmcs_discrete_restricted_fuc`, both of which use `succ_embed_surjective`. Understand how the BFMCS + restricted coherence conditions feed into `fully_restricted_parametric_completeness_from_neg_membership`.

- [ ] **Task 4.2**: Analyze `chronicle_is_good_direct` (ShiftAndGlue.lean:950-971). It takes a `ChronicleAsPriorModel` and returns `good sig k (chronicleAsMonadicStructure M sig atomMap)`. The `good` result unfolds to: `exists (Z : ZIntervalStructure sig), k_equiv sig k M Z.toOrdered`. Understand what `k_equiv` provides concretely -- it is a pair of winning strategies for EF games of depth k between M and Z.toOrdered.

- [ ] **Task 4.3**: Design the restructured countermodel. The key insight from Reynolds (Theorem 18, p.132): choose k = 1 + quantifier_depth(table(phi)). Then the k-equivalence M ~k Z means Z satisfies the same monadic sentences of depth <= k as M. Since the truth of phi at any point is determined by a monadic formula of depth <= k, the Z structure is a valid countermodel. The new `countermodel_discrete_reynolds` should:
  1. Build the chronicle `ChronicleAsPriorModel` from the discrete MCS (existing code)
  2. Apply `chronicle_is_good_direct` to get `good sig k M_struct` (sorry-free)
  3. Extract the Z-interval structure and k-equivalence
  4. Build the FMCS on Z by transferring MCS data through the isomorphism
  5. Prove coherence conditions using the F/P-resolution and U/S-resolution of the limit domain, transferred through the embedding

- [ ] **Task 4.4**: Implement the restructured coherence proofs. Create new versions of:
  - `cantor_bfmcs_discrete_restricted_tc_good`: Uses the `good` structure's Z-interval embedding instead of `succ_embed_surjective`
  - `cantor_bfmcs_discrete_restricted_fuc_good`: Same approach for U/S-coherence
  Or restructure `countermodel_discrete_reynolds` to bypass these coherence conditions entirely by using the k-equivalence to transfer truth directly.

- [ ] **Task 4.5**: Rewire `countermodel_discrete_reynolds` to use the new approach. Update the proof body to call the `good`-based coherence conditions instead of the `succ_embed_surjective`-based ones.

- [ ] **Task 4.6**: Verify the proof compiles and the sorry chain is eliminated:
  - `lean_verify countermodel_discrete_reynolds` shows no `sorryAx`
  - `lake build Bimodal.Metalogic.WeakCanonical.Transfer` passes
  - `lake build Bimodal.Metalogic.BXCanonical.Completeness` passes

**Timing**: 4-8 hours

**Depends on**: 2 (independent of Phase 3; can run in parallel)

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Transfer.lean` (restructure `countermodel_discrete_reynolds`; possibly add new lemmas)
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` (optionally restructure coherence conditions, or mark the succ_embed-based versions as dead code)
- Possibly add a new file `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/GoodCountermodel.lean` if the restructuring is too large for inline changes

**Key existing sorry-free infrastructure**:
- `chronicle_is_good_direct` (ShiftAndGlue.lean:950) -- gives `good sig k M` without `IsSuccArchimedean`
- `one_class` (NoGapsDiscreteProof.lean:88) -- all points contemporaneously equivalent
- `one_class_implies_very_good` (ShiftAndGlue.lean:919) -- `one_class -> very_good`
- `very_good_implies_good` (ShiftAndGlue.lean:831) -- `very_good + countable -> good`
- `limit_F_resolution`, `limit_P_resolution` (ChronicleToCountermodelBasic.lean) -- F/P witnesses in limit domain
- `limit_satisfies_c5_strong`, `limit_satisfies_c5'_strong` (ChronicleToCountermodelBasic.lean) -- U/S witnesses in limit domain

**Verification**:
- `lean_verify countermodel_discrete_reynolds` shows no `sorryAx`
- `lake build Bimodal.Metalogic.WeakCanonical.Transfer` passes
- `lake build Bimodal.Metalogic.BXCanonical.Completeness` passes

---

### Phase 5: Full sorry cascade verification [NOT STARTED]

**Goal**: Verify that both Chain 1 and Chain 2 fixes cascade through to make `completeness_discrete` entirely sorry-free. Verify the model surgery pipeline is also sorry-free as a consequence of Chain 1.

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

- [ ] **Task 5.3**: Verify Chain 2 cascade:
  - `lean_verify countermodel_discrete_reynolds` -- no `sorryAx` (Phase 4 result)
  - `lean_verify completeness_discrete` -- no `sorryAx`

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
- [ ] Update ChronicleToCountermodel.lean file-level docstring (lines 57-91) to note that the `succ_embed_surjective` path is no longer on the critical path (coherence conditions restructured to use `good`-based approach)
- [ ] Update the docstring at lines 782-787 (above `limitDomSubtype_isSuccArchimedean`) to note it is dead code -- the Reynolds pipeline does not require `IsSuccArchimedean`
- [ ] Update the docstring at lines 808-817 (Collapse-Based Discrete Pipeline) to note that `succ_embed_surjective` is no longer used by `completeness_discrete`
- [ ] Update StaviCompleteness.lean docstrings near the fixed sorry sites (lines 2196-2213 and line 2785-2786) to remove references to sorry'd bridge lemma
- [ ] Mark dead BX pipeline code (lines 472-780: `chronicle_gap_contradiction`, `succ_cofinal` old version) with clear "DEAD CODE -- bypassed by Reynolds good-structure path" annotations for future archival
- [ ] Update the audit section in Completeness.lean (lines 376-388) to reflect sorry-free status for `completeness_discrete`
- [ ] Write execution summary at `specs/155_reynolds_pipeline_activation/summaries/63_execution-summary.md`

**Timing**: 1 hour

**Depends on**: 5

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

- `specs/155_reynolds_pipeline_activation/plans/63_corrected-plan.md` (this file, v64)
- Modified `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/StaviCompleteness.lean` (proof of `nf_2var_existential_transfer`: ~200-400 lines)
- Modified `Theories/Bimodal/Metalogic/WeakCanonical/Transfer.lean` (restructured `countermodel_discrete_reynolds` to use `good`-based coherence)
- Possibly new `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/GoodCountermodel.lean` (helper lemmas for good-based coherence)
- Modified `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` (docstring updates, dead code annotations)
- Modified `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` (docstring updates)
- Execution summary at `specs/155_reynolds_pipeline_activation/summaries/63_execution-summary.md`

## Rollback/Contingency

If the direct proof of `nf_2var_existential_transfer` (Phase 3) hits a wall:

1. **Fallback A -- EF Game Bridge (plan v62 Phase 3)**: Revert to building the full bridge between NF types and rank_types in NFGameBridge.lean. This is the plan v62 approach, estimated at 300-500 lines. It bypasses `nf_2var_existential_transfer` entirely by using the sorry-free game infrastructure (Composition.lean, Decomposition.lean).

2. **Fallback B -- Partial direct + bridge hybrid**: If the direct proof works for j=0 and j=1 but fails at j>=2, combine the direct proof for low depths with a bridge argument that handles the general case.

3. **Safe revert**: `git checkout -- Theories/Bimodal/Metalogic/WeakCanonical/EFGames/StaviCompleteness.lean` to restore files. Phase 1 and Phase 2 changes are preserved.

If the `good`-based coherence restructuring (Phase 4) hits a wall:

1. **Fallback A -- Direct IsSuccArchimedean** (plan v63 Phase 4): Despite the literature not using this approach, if the k-equivalence transfer turns out to be technically difficult in Lean, prove `IsSuccArchimedean` directly by showing the limit domain is a well-ordered discrete linear order (every element enters at a finite stage of the omega-chain). This is plan v63's approach, which may work even though it doesn't follow Reynolds.

2. **Fallback B -- Alternative FMCS construction**: Instead of restructuring coherence conditions, construct the FMCS on Z by defining a direct map from Z to MCS's using the `good` structure's Z-interval isomorphism. Prove the coherence conditions for this FMCS from scratch rather than adapting the existing proofs.

3. **Safe revert**: `git checkout -- Theories/Bimodal/Metalogic/WeakCanonical/Transfer.lean` and `git checkout -- Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` to restore files. Phase 1 and Phase 2 changes are preserved.
