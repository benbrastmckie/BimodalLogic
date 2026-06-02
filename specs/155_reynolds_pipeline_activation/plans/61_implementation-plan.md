# Implementation Plan: Task #155 (v62)

- **Task**: 155 - Eliminate all sorries from completeness_discrete by fixing 3 root sorries in StaviCompleteness.lean (4-variable EF-game existential transfer, GHR93 Proposition 7) and rewiring limitDomSubtype_isSuccArchimedean
- **Status**: [NOT STARTED]
- **Effort**: 10-16 hours
- **Dependencies**: None (task 199 dependency resolved; Phase 1 complete)
- **Research Inputs**: specs/155_reynolds_pipeline_activation/reports/58_proper-fix-research.md, specs/155_reynolds_pipeline_activation/reports/59_lit-ghr93-gaps.md, specs/155_reynolds_pipeline_activation/reports/59_lit-ghr94-ch9.md, specs/155_reynolds_pipeline_activation/reports/59_lit-reynolds94.md, specs/155_reynolds_pipeline_activation/reports/59_lit-burgess-venema.md, specs/155_reynolds_pipeline_activation/reports/60_blocker-resolution.md, specs/155_reynolds_pipeline_activation/reports/61_depth-mismatch-literature.md
- **Artifacts**: plans/61_implementation-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

This is plan v62, revised from v61 to incorporate the definitive literature analysis (report 61_depth-mismatch-literature.md). Plan v61's Phase 2 was marked [BLOCKED] because the Bridge A approach (`nf_char_eq_implies_rank_type_eq`) was framed as a direct mapping from depth-k NF to rank_type at depth k. The literature research reveals this was a misframing: the problem is NOT a depth mismatch per se, but a **structural limitation** of the direct NF induction approach (sub-interval types are not derivable from enclosing interval data). GHR93 resolves this through EF game composition (Proposition 7, p.114), where Duplicator's strategy preserves sub-interval data via decomposition formula matching (Lemma 11, p.113).

The revised plan corrects the depth relationship (depth-k NF agreement implies rank_type agreement at depth floor(k/2), not depth k), makes `interval_nf_types` non-private to enable the bridge, and restructures Phase 2 around the correct game bridge approach grounded in specific GHR93 page/theorem references.

**Key correction from literature (report 61)**: The bridge uses `char_k` from the **induction hypothesis** (depth k, already complete by IH within `nf_characterizable_by_stavi`), not from the theorem being proved (depth k+1). So there is no circularity. Specifically: at induction step k+1, char_k (depth k) is already complete. Depth-k NF agreement gives rank_type agreement at depth floor(k/2) via char_{floor(k/2)}. The game at rank floor(k/2) yields depth-k 2-var NF agreement.

Definition of done: `#print axioms completeness_discrete` shows no `sorryAx`, `lake build` passes, no `axiom` declarations outside the proof system or frame constraints.

### Research Integration

- **Report 58** (proper fix research): Diagnosed model surgery limitation for IsSuccArchimedean. Still relevant for Phase 5 context.
- **Report 59 lit-ghr93-gaps**: GHR93 Proposition 7 game composition argument.
- **Report 59 lit-ghr94-ch9**: GHR94 Chapter 9 monadic NFs framework. Informs depth parameter handling.
- **Report 59 lit-reynolds94**: Reynolds 1994 Theorem 14 model surgery. Relevant to Phase 5 rewiring.
- **Report 59 lit-burgess-venema**: Historical context for Until/Since axiomatization.
- **Report 60** (blocker resolution): Diagnosed the interval-splitting problem, recommended EF Game Bridge approach.
- **Report 61** (depth mismatch literature): **Definitive analysis**. Confirmed NOT a depth mismatch but a structural limitation. Established correct depth relationship (k NF -> rank floor(k/2)). Confirmed IH-based char_k usage breaks apparent circularity. Provided GHR93 page-level references for each bridge step.

### Literature Sources

Each phase is grounded in specific literature from the `literature/` directory:

| Phase | Primary Literature | Specific Result |
|-------|-------------------|-----------------|
| Phase 2 | `Gabbay_Hodkinson_Reynolds_1993_Temporal_expressive_completeness_gaps.md` | Report 61: private defs need exposure |
| Phase 3A | `Gabbay_Hodkinson_Reynolds_1994_Temporal_Logic_Foundations_Vol1_ch9.md` | Ch. 9 NF/rank-type correspondence |
| Phase 3A | Report 61, Section "Depth/Rank relationship" | depth-k NF -> rank_type at floor(k/2) via char_k from IH |
| Phase 3B | `Gabbay_Hodkinson_Reynolds_1993_Temporal_expressive_completeness_gaps.md` p.108 | Definition 8.8.1: interval type characterization |
| Phase 3C | `Gabbay_Hodkinson_Reynolds_1993_Temporal_expressive_completeness_gaps.md` p.113 | Lemma 11: decomposition formula <-> game winning |
| Phase 3C | `Gabbay_Hodkinson_Reynolds_1993_Temporal_expressive_completeness_gaps.md` p.114 | Proposition 7: strategy composition |
| Phase 3C | `Libkin_2004_Elements_Finite_Model_Theory_ch3_ch7.md` | Lemma 3.7: Composition Lemma for Linear Orders |
| Phase 3D | `Gabbay_Hodkinson_Reynolds_1993_Temporal_expressive_completeness_gaps.md` p.115 | Corollary 5: game agreement -> formula agreement |
| Phase 5 | `Reynolds_1994_Axiomatising_U_and_S_over_integer_time.md` | Theorem 14: model surgery, no gaps at equivalence class boundaries |

Any step that cannot be justified by the above literature must be flagged as needing literature review before implementation.

### Prior Plan Reference

Plan v61 correctly identified the 3 root sorries and the EF Game Bridge approach. However, v61 framed Bridge A as mapping depth-k NF directly to rank_type at depth k, which requires StaviFormula agreement at FO depth 2k -- beyond what depth-k NFs capture. Plan v62 corrects this by using the depth relationship from report 61: depth-k NF -> char_k (from IH) -> rank_type at floor(k/2). The game at rank floor(k/2) suffices because it yields depth-k FO agreement (via Proposition 5/Corollary 5, GHR93 p.115), which gives depth-k 2-var NF agreement.

### Roadmap Alignment

- Closing the sorry chain achieves sorry-free `completeness_discrete`
- Eliminates all axiom declarations outside the proof system
- Advances the critical path: Task 155 -> sorry-free `completeness_discrete`

## Goals & Non-Goals

**Goals**:
- Make `interval_nf_types` and required supporting definitions non-private in StaviCompleteness.lean
- Build EF Game Bridge in NFGameBridge.lean connecting NF world to game world with correct depth floor(k/2) relationship
- Use bridge to close 3 sorries in StaviCompleteness.lean (lines 2347, 2429, 2787)
- Rewire `limitDomSubtype_isSuccArchimedean` to use model surgery
- `#print axioms completeness_discrete` shows no `sorryAx`
- `lake build` passes
- No `axiom` declarations outside the proof system or frame constraints

**Non-Goals**:
- Proving `nf_2var_existential_transfer` by direct NF induction (proven impossible -- 5 sessions confirmed interval-splitting problem)
- Proving `chronicle_gap_contradiction` (dead BX pipeline code)
- Finite interval argument for IsSuccArchimedean (superseded by model surgery rewiring)
- Modifying GoodStructures.lean or NoGapsDiscreteProof.lean (Phase 1 work preserved)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Depth floor(k/2) relationship is not tight enough for the bridge | H | L | Report 61 confirms: depth-k NF -> FO depth k -> rank_type at floor(k/2) because StaviFormula depth r has FO depth <= 2r. The game at rank floor(k/2) gives depth-k FO agreement. If floor(k/2) is off-by-one, try ceiling(k/2). |
| char_k from IH requires specific context not available at bridge call site | M | M | Audit `nf_characterizable_by_stavi` induction structure. The bridge is called INSIDE the induction step at depth k+1, so char_k (depth k) is available from IH. If the Lean encoding makes IH inaccessible, restructure the bridge to accept char_k as a parameter. |
| Making `interval_nf_types` non-private breaks existing StaviCompleteness.lean proofs | L | L | The definition is only used within StaviCompleteness.lean itself. Making it non-private adds visibility but changes no semantics. Build immediately after to catch any issues. |
| `decomposition_agreement` on ExtendedCarrier requires gap structure data that M.carrier lacks | M | M | The bridge constructs ExtendedCarrier data from M.carrier data via `extendPoint`. Gap points in ExtendedCarrier are NOT in M.carrier -- they arise from the extension. The bridge only needs to show rank_type and interval_types at `extendPoint` images, not at gap points. |
| Rewiring limitDomSubtype_isSuccArchimedean requires Prior-UZ/SZ infrastructure not yet built | M | L | Phase 5 audits existing infrastructure first. If missing, construct OrderedMonadicStructure on LimitDomSubtype (~100-200 lines). |
| Full `lake build` regression from NFGameBridge.lean changes | L | L | Build after each sub-phase. NFGameBridge.lean is a leaf file. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5 | 3 |
| 6 | 6 | 4, 5 |
| 7 | 7 | 6 |

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

### Phase 2: Make private definitions accessible for bridge [COMPLETED]

**Goal**: Make `interval_nf_types` and other definitions needed by the NF-to-game bridge non-private in StaviCompleteness.lean, so NFGameBridge.lean can reference them.

**Literature basis**: Report 61, Section "The Private Definition Constraint" (p.85-87): "All key definitions are `private` to StaviCompleteness.lean... Any bridge code must work WITHIN StaviCompleteness.lean, or these must be made non-private. Recommendation: Make `interval_nf_types` and supporting types non-private."

**Tasks**:
- [x] **Task 2.1**: Identify all private definitions needed by the bridge. Read NFGameBridge.lean imports and StaviCompleteness.lean private definitions. The minimum set is:
  - `interval_nf_types` (line 1835) -- needed for bridge hypotheses
  - `zone_match_witness` (line 2044) -- may be needed if bridge reuses zone matching
  - `nf_fraisse_compression` (line 2006) -- used by `nf_2var_from_interval_data`
  - `nf_2var_from_interval_data` (line 2442) -- the theorem to be refactored
  - `nf_2var_existential_transfer` (line 2214) -- to be bypassed but may need visibility for dead-code marking
  - Additional: `interval_2var_nf_types`, `nf_char_depth_decrease`, `interval_nf_types_depth_decrease`, `above_max_depth_decrease`, `below_min_depth_decrease`
- [x] **Task 2.2**: Remove the `private` keyword from each identified definition. Use `Edit` tool to change `private noncomputable def` to `noncomputable def` and `private theorem` to `theorem` for each.
- [x] **Task 2.3**: Build to verify no regressions: `lake build Bimodal.Metalogic.WeakCanonical.EFGames.StaviCompleteness`
- [x] **Task 2.4**: Verify NFGameBridge.lean can now see the definitions: add a test import reference and build `lake build Bimodal.Metalogic.WeakCanonical.EFGames.NFGameBridge`

**Timing**: 0.5-1 hour

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/StaviCompleteness.lean` (remove `private` from ~10 definitions)

**Verification**:
- `lake build Bimodal.Metalogic.WeakCanonical.EFGames.StaviCompleteness` passes
- `lake build Bimodal.Metalogic.WeakCanonical.EFGames.NFGameBridge` passes
- No new sorry or axiom introduced

---

### Phase 3: Build EF Game Bridge with correct depth relationship [BLOCKED]

**BLOCKER** (Phase 3):
- **What failed**: The plan's approach to fixing the 3 root sorries in StaviCompleteness.lean faces TWO distinct issues:
  1. **Sorries 1&2 (lines 2347, 2429)**: The `nf_2var_existential_transfer` sorries require 4-var existential transfer at depth j' for 3-point configurations, which is the sub-interval splitting problem confirmed impossible by 5 sessions. The EF game bridge approach (via rank_type, decomposition_agreement, ghr93_duplicator_wins) is the correct theoretical path but requires 300-500 lines of bridge code connecting NF types on M.carrier to rank_types on ExtendedCarrier.
  2. **Sorry 3 (line 2787)**: `nf_exist_sf_guarded_backward` has a SEPARATE structural issue. The formula `nf_exist_sf_guarded` is too weak for the backward direction: it only checks atom-compatibility (predicates at variable 0 + ordering) but does NOT encode the quantifier part of sub_nf. Two different sub_nfs with the same atom assignment produce the SAME formula, making the backward direction unprovable. This is a formula construction bug, not just a missing proof.
- **What was tried**: Extensive analysis of the code structure, dependency tracing, and verification of axiom dependencies. Confirmed that the game infrastructure (Decomposition.lean, Composition.lean) is sorry-free and correctly implements GHR93 Lemma 11 and Proposition 7.
- **Why it's stuck**: Two independent issues require resolution:
  (a) Building the NF-to-game bridge (300-500 lines) to bypass `nf_2var_existential_transfer`
  (b) Restructuring the formula construction in `nf_exist_sf_guarded` to encode quantifier information, or using a completely different proof structure for `nf_2var_existence_characterizable`
- **What is needed**: Either (i) build the EF game bridge AND fix the formula, or (ii) restructure the proof of `nf_characterizable_by_stavi` to avoid the problematic formula construction entirely (e.g., using a non-constructive pigeonhole argument that avoids explicit formula construction for the backward direction)
- **Additional finding**: The model surgery pipeline (no_gaps_discrete_model_surgery) depends on `US_expressively_complete_over_prior` which depends on `stavi_expressive_completeness` which carries these sorries. So the pipeline is NOT sorry-free despite Phase 1 resolving the import cycle. This invalidates the Phase 5 approach of using model surgery to prove IsSuccArchimedean.
- **Prohibited workarounds**: Do NOT use `sorry`, `def X := True`, or any vacuous placeholder

**Goal**: Build bridge lemmas in NFGameBridge.lean connecting NF hypotheses (depth-k 1-var NFs, interval_nf_types on M.carrier) to the existing sorry-free EF game infrastructure (rank_type, decomposition_agreement, ghr93_duplicator_wins on ExtendedCarrier), using the correct depth relationship: depth-k NF -> rank_type at depth floor(k/2), game at rank floor(k/2), then game result -> depth-k NF agreement. Then refactor `nf_2var_from_interval_data` to use the bridge.

**CRITICAL INSTRUCTIONS FOR IMPLEMENTING AGENT**:
- The bridge uses char_k from the INDUCTION HYPOTHESIS (depth k). The bridge theorems must either (a) accept char_k as a parameter, or (b) be invoked inside the induction body of `nf_characterizable_by_stavi` where char_k is in scope. Option (a) is preferred for modularity.
- Do NOT attempt direct NF induction on `nf_2var_existential_transfer`. This is proven impossible.
- The CORRECT depth relationship (from report 61): depth-k NF captures FO depth k. StaviFormula of depth r has FO depth <= 2r. Therefore depth-k NF agreement -> rank_type agreement at depth floor(k/2). The game at rank floor(k/2) gives depth-k FO agreement via Corollary 5 (GHR93, p.115).
- Read existing infrastructure in NFGameBridge.lean (173 lines), Composition.lean, Decomposition.lean, and CharacteristicFormula.lean CAREFULLY before writing new code.
- Do NOT use `sorry` or `axiom` as fallbacks. If blocked, report what was tried.

**Sub-phase 3A: NF-to-rank-type bridge with correct depth (~100-150 lines)**

Prove that depth-k 1-var NF agreement on M.carrier implies rank_type agreement at depth floor(k/2) on ExtendedCarrier.

**Literature basis**: GHR93 Definition 8.2 (p.108): rank = temporal nesting depth. GHR94 Ch. 9: NF/rank-type correspondence via monadic NFs. Report 61, Section "Depth/Rank relationship": "depth-k NF agreement -> rank_type agreement at depth floor(k/2)" because StaviFormula of depth r has FO depth <= 2r, so depth-k NFs determine all StaviFormulas of depth <= floor(k/2).

- [ ] **Task 3A.1**: Audit the relationship between `nf_characteristic M k 1` and `rank_type` by reading:
  - `CharacteristicFormula.lean`: find `nf_profile_determines_rank_type`, `nf_profile_determines_stavi_truth`, `doets_lemma_1_1`
  - `TypeFormulas.lean`: find `stavi_temporal_truth_mu` (line ~304), `rank_type` definition (line ~381)
  - `StaviCompleteness.lean`: find `stavi_table_mu_correct` and `char_k_correct`
  - Document exact signatures and what hypotheses they require, especially regarding depth parameters.

- [ ] **Task 3A.2**: Determine the precise depth parameter mapping. Verify:
  - depth-k NF agreement -> agreement on all NormalForm sig k 1 values
  - each NormalForm sig k 1 corresponds to FO formulas of depth <= k
  - char_k (from IH at depth k) maps NF to StaviFormula of depth <= k (with FO depth <= 2k? or <= k?)
  - rank_type at depth r captures StaviFormulas of depth <= r
  - Therefore: if char_k produces StaviFormulas of stavi_depth <= k, then depth-k NF agreement gives rank_type at depth k (not floor(k/2))
  - BUT if char_k produces StaviFormulas of stavi_depth that could be up to 2k, then we need floor(k/2)
  - **Resolution**: Check `stavi_fo_depth_le_twice_depth` in StaviCompleteness.lean (line ~464) and `char_k_correct` to determine the actual depth of char_k output.

- [ ] **Task 3A.3**: Prove the NF-to-rank-type bridge theorem. The precise statement depends on Task 3A.2, but the skeleton is:
  ```lean
  theorem nf_char_eq_implies_rank_type_eq {sig : MonadicSignature}
      {M M' : OrderedMonadicStructure sig} {atomMap : Formula -> sig.preds}
      {k : Nat} {x : M.carrier} {x' : M'.carrier}
      -- char_k from induction hypothesis (parameterized)
      (char_k : NormalForm sig k 1 -> StaviFormula)
      (char_k_correct : forall (nf_k : NormalForm sig k 1)
          (N : OrderedMonadicStructure sig) (t : N.carrier),
          stavi_temporal_truth N atomMap t (char_k nf_k) <->
          nf_eval_nf N k 1 (fun _ => t) nf_k)
      (h_nf : nf_characteristic M k 1 (fun _ => x) =
              nf_characteristic M' k 1 (fun _ => x')) :
      rank_type M atomMap (k / 2) (extendPoint x) =
      rank_type M' atomMap (k / 2) (extendPoint x')
  ```
  Proof path: NF agreement -> nf_eval_nf agreement for all depth-k NFs -> via char_k_correct, stavi_temporal_truth agreement for all char_k images -> these are StaviFormulas of depth <= r (where r = k/2 or k depending on 3A.2) -> rank_type agreement at that depth.

  **GHR93 reference**: This formalizes the correspondence between GHR94 Ch. 9 NF types and GHR93 Def. 8.8.1 temporal rank types (X_t as conjunction of temporal formulas of rank < r true at t).

- [ ] **Task 3A.4**: Verify sub-phase compiles: `lake build Bimodal.Metalogic.WeakCanonical.EFGames.NFGameBridge`

**Sub-phase 3B: Interval-type bridge (~50-80 lines)**

Prove that `interval_nf_types` agreement on M.carrier implies `interval_types` agreement on ExtendedCarrier at the corresponding depth.

**Literature basis**: GHR93 Definition 8.8.1 (p.108): X_{(t,u)} = disjunction of X_v for all non-gap points v in (t,u). This is the temporal-logic analog of `interval_types`. Report 61: "The bridge formalizes: interval_nf_types determines interval_types, because each NF type maps to a unique rank type via Bridge A."

- [ ] **Task 3B.1**: Read definitions of `interval_nf_types` (now non-private in StaviCompleteness.lean, line 1835) and `interval_types` (TypeFormulas.lean, line 391). Document how they relate:
  - `interval_nf_types M k x t` = set of depth-k 1-var NFs realized in open interval (x,t) on M.carrier
  - `interval_types M atomMap r a b` = set of rank_types realized in open interval (a,b) on ExtendedCarrier
  - Bridge: each NF type in interval_nf_types maps to a rank_type via nf_char_eq_implies_rank_type_eq (3A). If NF type sets agree, rank_type sets agree.

- [ ] **Task 3B.2**: Prove `interval_nf_types_eq_implies_interval_types_eq`:
  ```lean
  theorem interval_nf_types_eq_implies_interval_types_eq {sig : MonadicSignature}
      {M M' : OrderedMonadicStructure sig} {atomMap : Formula -> sig.preds}
      {k : Nat} {x t : M.carrier} {x' t' : M'.carrier}
      (char_k : NormalForm sig k 1 -> StaviFormula)
      (char_k_correct : ...)
      (h_int : interval_nf_types M k x t = interval_nf_types M' k x' t') :
      interval_types M atomMap (k / 2) (extendPoint x) (extendPoint t) =
      interval_types M' atomMap (k / 2) (extendPoint x') (extendPoint t')
  ```
  Proof: A rank_type tau is in interval_types M iff there exists y in (x,t) with rank_type y = tau. By the 3A bridge, this y's NF maps to tau. Since interval_nf_types agree, M' has y' with the same NF, hence the same rank_type.

- [ ] **Task 3B.3**: Prove analogous lemmas for `above_max_type` and `below_min_type` if required by `decomposition_agreement`. Read `decomposition_agreement` definition in Decomposition.lean (line 62) to determine exact hypotheses.

  **GHR93 reference**: Corresponds to GHR93 Def. 8.8.2b: interval predicates in the decomposition formula encoding which types are realized between adjacent elements.

- [ ] **Task 3B.4**: Verify sub-phase compiles: `lake build Bimodal.Metalogic.WeakCanonical.EFGames.NFGameBridge`

**Sub-phase 3C: Full Bridge A -- NF hypotheses to Duplicator wins (~80-120 lines)**

Compose the rank_type and interval_type bridges into a proof that NF hypotheses imply `ghr93_duplicator_wins`.

**Literature basis**: GHR93 Lemma 11 (p.113): equivalence between Duplicator winning and decomposition formula agreement. GHR93 Proposition 7 (p.114): decomposition agreement at right parameters -> Duplicator winning strategy for full game. The bridge composes: NF hypotheses -> decomposition_agreement (via 3A+3B) -> ghr93_duplicator_wins (via `ghr93_decomposition_implies_game` already in Decomposition.lean, line 272).

- [ ] **Task 3C.1**: Read `ghr93_duplicator_wins` definition (CustomGame.lean, line 285) and `ghr93_decomposition_implies_game` (Decomposition.lean, line 272). Understand what `decomposition_agreement` requires:
  - rank_type agreement at endpoints
  - interval_types agreement for intervals between endpoints
  - Point-challenge conditions (for arbitrary points added between endpoints)
  - **GHR93 reference**: Confirm this matches Lemma 11's decomposition formula structure (Definition 8.8, p.108).

- [ ] **Task 3C.2**: Prove `nf_hypotheses_imply_decomposition_agreement`:
  ```lean
  theorem nf_hypotheses_imply_decomposition_agreement {sig : MonadicSignature}
      {M M' : OrderedMonadicStructure sig} {atomMap : Formula -> sig.preds}
      {k n : Nat} {x t : M.carrier} {x' t' : M'.carrier}
      (char_k : NormalForm sig k 1 -> StaviFormula)
      (char_k_correct : ...)
      (h_nf_x : nf_characteristic M k 1 (fun _ => x) =
                nf_characteristic M' k 1 (fun _ => x'))
      (h_nf_t : nf_characteristic M k 1 (fun _ => t) =
                nf_characteristic M' k 1 (fun _ => t'))
      (h_order_xt : x < t <-> x' < t')
      (h_interval : interval_nf_types M k x t = interval_nf_types M' k x' t')
      (h_above : ...) (h_below : ...) :
      decomposition_agreement M M' atomMap n (k / 2)
        (extendPoint x) (extendPoint t) (extendPoint x') (extendPoint t')
  ```
  Uses `nf_char_eq_implies_rank_type_eq` (3A) and `interval_nf_types_eq_implies_interval_types_eq` (3B).

- [ ] **Task 3C.3**: Compose with `ghr93_decomposition_implies_game` to get `ghr93_duplicator_wins`:
  ```lean
  theorem nf_hypotheses_imply_duplicator_wins {sig : MonadicSignature}
      {M M' : OrderedMonadicStructure sig} {atomMap : Formula -> sig.preds}
      {k n : Nat} {x t : M.carrier} {x' t' : M'.carrier}
      (char_k : ...) (char_k_correct : ...)
      (h_nf_x : ...) (h_nf_t : ...) (h_order : ...)
      (h_interval : ...) (h_above : ...) (h_below : ...) :
      ghr93_duplicator_wins M M' atomMap n (k / 2)
        (extendPoint x) (extendPoint t) (extendPoint x') (extendPoint t')
  ```

  **GHR93 reference**: Proposition 7 (p.114) -- given NF/decomposition agreement, Duplicator has a winning strategy. The parameter functions f(n), g(n) from Definition 8.9 should be checked against the Lean formalization.

- [ ] **Task 3C.4**: Verify sub-phase compiles: `lake build Bimodal.Metalogic.WeakCanonical.EFGames.NFGameBridge`

**Sub-phase 3D: Bridge B + refactor nf_2var_from_interval_data (~100-150 lines)**

Prove that Duplicator winning implies NF agreement (Bridge B), then refactor `nf_2var_from_interval_data` to use the bridge instead of `nf_fraisse_compression` + `nf_2var_existential_transfer`.

**Literature basis**: GHR93 Corollary 5 (p.115): game agreement implies formula agreement at all depths. Report 61, Section "Circularity Problem": "game winning at rank r = floor(k/2) gives depth-k FO agreement (since rank r captures FO depth 2r >= k), which gives depth-k 2-var NF agreement."

- [ ] **Task 3D.1**: Prove `duplicator_wins_implies_nf_agreement`:
  ```lean
  theorem duplicator_wins_implies_nf_agreement {sig : MonadicSignature}
      {M M' : OrderedMonadicStructure sig} {atomMap : Formula -> sig.preds}
      {k : Nat} {x t : M.carrier} {x' t' : M'.carrier}
      (hwin : ghr93_duplicator_wins M M' atomMap 2 (k / 2)
        (extendPoint x) (extendPoint t) (extendPoint x') (extendPoint t'))
      (hwin_bwd : ghr93_duplicator_wins M' M atomMap 2 (k / 2)
        (extendPoint x') (extendPoint t') (extendPoint x) (extendPoint t)) :
      nf_characteristic M k 2 (Fin.cons x (fun _ => t)) =
      nf_characteristic M' k 2 (Fin.cons x' (fun _ => t'))
  ```
  Proof path: Duplicator winning at rank r = k/2 with 2 pebbles gives `formula_agreement` for all StaviFormulas of depth <= r (via `ghr93_game_implies_decomposition`, Decomposition.lean line 117). StaviFormula agreement at depth r captures FO depth 2r >= k. This gives depth-k FO agreement, hence `nf_eval_nf` agreement at all depth-k NFs. Via `nf_eval_unique`, this gives `nf_characteristic` equality.

  NOTE: We need the BACKWARD direction too (hwin_bwd) because `ghr93_game_implies_decomposition` requires both forward and backward winning. The NF hypotheses are symmetric, so this is obtainable.

  **GHR93 reference**: Corollary 5 (p.115) and Theorem 6 (p.113, forward-backward transfer).

- [ ] **Task 3D.2**: Prove the combined bridge `nf_2var_from_bridge`:
  ```lean
  theorem nf_2var_from_bridge {sig : MonadicSignature}
      {M M' : OrderedMonadicStructure sig} {atomMap : Formula -> sig.preds}
      {k : Nat} {x t : M.carrier} {x' t' : M'.carrier}
      (char_k : NormalForm sig k 1 -> StaviFormula)
      (char_k_correct : ...)
      (h_nf_x : ...) (h_nf_t : ...)
      (h_order_xt : (x < t <-> x' < t') /\ (t < x <-> t' < x'))
      (h_interval_above : t < x -> interval_nf_types M k t x = interval_nf_types M' k t' x')
      (h_interval_below : x < t -> interval_nf_types M k x t = interval_nf_types M' k x' t')
      (h_above_max : ...) (h_below_min : ...) :
      nf_characteristic M k 2 (Fin.cons x (fun _ => t)) =
      nf_characteristic M' k 2 (Fin.cons x' (fun _ => t'))
  ```
  Composition: nf_hypotheses_imply_duplicator_wins (3C, both directions) -> duplicator_wins_implies_nf_agreement (3D.1).

- [ ] **Task 3D.3**: Refactor `nf_2var_from_interval_data` in StaviCompleteness.lean. Replace its current proof body (which calls `nf_fraisse_compression` requiring the sorry-bearing `nf_2var_existential_transfer`) with a call to `nf_2var_from_bridge`.
  - File: `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/StaviCompleteness.lean`
  - Read `nf_2var_from_interval_data` at line 2442 (already read -- signature known)
  - The signature of `nf_2var_from_interval_data` must match `nf_2var_from_bridge` hypotheses. Key differences:
    - `nf_2var_from_bridge` takes `char_k` and `char_k_correct` as parameters
    - `nf_2var_from_bridge` takes `atomMap` as parameter
    - `nf_2var_from_interval_data` takes h_above_max and h_below_min in a different format
  - Either add adapter lemmas or restructure `nf_2var_from_interval_data` to pass char_k from the enclosing induction context.
  - **CRITICAL**: `nf_2var_from_interval_data` is called from within `nf_characterizable_by_stavi` (the induction), so char_k IS available at the call site. The refactoring adds char_k as a parameter to `nf_2var_from_interval_data` or inlines the bridge call at the use site (line ~2534).
  - Estimated: 30-80 lines for the refactoring and adapters.

- [ ] **Task 3D.4**: Verify the refactoring eliminates the sorry chain:
  - `lean_verify nf_2var_from_interval_data` -- no `sorryAx`
  - Confirm `nf_2var_existential_transfer` is no longer in the dependency chain of `nf_2var_from_interval_data`
  - `lake build Bimodal.Metalogic.WeakCanonical.EFGames.StaviCompleteness` passes

- [ ] **Task 3D.5**: Full sub-phase verification:
  - `lake build Bimodal.Metalogic.WeakCanonical.EFGames.NFGameBridge` passes
  - `lake build Bimodal.Metalogic.WeakCanonical.EFGames.StaviCompleteness` passes
  - No new sorry or axiom introduced

**Timing**: 5-8 hours

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/NFGameBridge.lean` (extend with bridge lemmas: ~300-500 lines added)
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/StaviCompleteness.lean` (refactor `nf_2var_from_interval_data` proof body, add char_k parameter or inline bridge)

**Verification**:
- `lean_verify nf_2var_from_interval_data` shows no `sorryAx`
- `lean_verify nf_char_eq_implies_rank_type_eq` shows no `sorryAx`
- `lean_verify nf_hypotheses_imply_duplicator_wins` shows no `sorryAx`
- `lean_verify duplicator_wins_implies_nf_agreement` shows no `sorryAx`
- `lake build Bimodal.Metalogic.WeakCanonical.EFGames.NFGameBridge` passes
- `lake build Bimodal.Metalogic.WeakCanonical.EFGames.StaviCompleteness` passes

---

### Phase 4: Verify sorry cascade resolution [NOT STARTED]

**Goal**: Confirm that fixing `nf_2var_from_interval_data` (via the bridge refactoring) makes `nf_exist_sf_guarded_backward` (line 2787) sorry-free, and verify the full cascade through `stavi_expressive_completeness` -> `US_expressively_complete_over_prior` -> model surgery pipeline.

**CRITICAL INSTRUCTIONS FOR IMPLEMENTING AGENT**:
- This phase is primarily verification. If Sorry 3 (line 2787) does NOT resolve automatically, investigate why and fix it.
- The bridge refactoring in Phase 3 bypasses `nf_2var_existential_transfer` entirely. The sorry at line 2787 in `nf_exist_sf_guarded_backward` depends on `nf_2var_from_interval_data`, which is now sorry-free. Therefore Sorry 3 should resolve automatically.

**Tasks**:
- [ ] **Task 4.1**: Verify `nf_exist_sf_guarded_backward` is sorry-free:
  - `lean_verify nf_exist_sf_guarded_backward` -- confirm no `sorryAx`
  - If still sorry: read lines 2760-2787 and determine what additional work is needed.

- [ ] **Task 4.2**: If Sorry 3 did NOT resolve automatically, fix it:
  - The proof at line 2787 needs to extract witness x from the temporal formula, determine its 1-var NF via char_k_correct, extract interval types from the interval guard, and apply `nf_2var_from_interval_data` (now sorry-free) to conclude the 2-var NF equals sub_nf.
  - Estimated: 50-150 lines if needed.

- [ ] **Task 4.3**: Verify the full Stavi cascade:
  - `lean_verify stavi_expressive_completeness` -- no `sorryAx`
  - `lean_verify US_expressively_complete_over_prior` -- no `sorryAx` (PriorExpressiveness.lean:371)

- [ ] **Task 4.4**: Verify the model surgery cascade:
  - `lean_verify gap_prior_UZ_contradiction` -- no `sorryAx` (GoodStructuresModelSurgery.lean:1169)
  - `lean_verify reynolds_model_surgery_core` -- no `sorryAx` (GoodStructuresModelSurgery.lean:2058)
  - `lean_verify no_gaps_discrete_model_surgery` -- no `sorryAx` (GoodStructuresModelSurgery.lean:2133)
  - `lean_verify no_gaps_discrete` -- no `sorryAx` (NoGapsDiscreteProof.lean)

**Timing**: 1-2 hours

**Depends on**: 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/StaviCompleteness.lean` (only if Sorry 3 needs manual fix at lines 2760-2787)

**Verification**:
- All `lean_verify` checks above pass with no `sorryAx`
- `lake build Bimodal.Metalogic.WeakCanonical.EFGames.StaviCompleteness` passes

---

### Phase 5: Rewire limitDomSubtype_isSuccArchimedean to use model surgery [BLOCKED]

**BLOCKER** (Phase 5):
- **What failed**: The model surgery pipeline (`no_gaps_discrete_model_surgery`) depends on `US_expressively_complete_over_prior` which depends on `stavi_expressive_completeness` which carries `sorryAx`. Verified via `#print axioms`: `no_gaps_discrete_model_surgery` depends on `sorryAx`. Therefore, using model surgery to prove IsSuccArchimedean would not eliminate `sorryAx` from `completeness_discrete`.
- **What was tried**: `#print axioms` verification of `reynolds_model_surgery_core`, `no_gaps_discrete_model_surgery`, `US_expressively_complete_over_prior`, and `stavi_expressive_completeness` — all depend on `sorryAx`.
- **Why it's stuck**: Phase 3 (Stavi chain) must be resolved first to make the model surgery pipeline sorry-free. Only then can Phase 5 use model surgery to prove IsSuccArchimedean.
- **What is needed**: Complete Phase 3 first, making `stavi_expressive_completeness` sorry-free, which will cascade to make `US_expressively_complete_over_prior` and `no_gaps_discrete_model_surgery` sorry-free.
- **Alternative**: Find a proof of IsSuccArchimedean that does NOT go through model surgery (e.g., direct argument about the omega-chain structure of the limit domain). This would decouple Phases 3 and 5.
- **Prohibited workarounds**: Do NOT use `sorry`, `def X := True`, or any vacuous placeholder

**Goal**: Replace the sorry-bearing definition of `limitDomSubtype_isSuccArchimedean` (ChronicleToCountermodel.lean:789) to use the now-sorry-free Reynolds model surgery pipeline instead of the dead `succ_cofinal` -> `chronicle_gap_contradiction` path.

**CRITICAL INSTRUCTIONS FOR IMPLEMENTING AGENT**:
- Follow this plan step-by-step. Do NOT revert to the finite interval approach from plan v59.
- The model surgery pipeline is now sorry-free (verified in Phase 4).
- The key challenge is constructing an OrderedMonadicStructure on the chronicle's LimitDomSubtype and showing it satisfies Prior-UZ/SZ, so that `no_gaps_discrete` applies.
- Read ChronicleToCountermodel.lean carefully around lines 789-830 to understand the existing def structure.

**Literature basis**: Reynolds 1994 (`literature/Reynolds_1994_Axiomatising_U_and_S_over_integer_time.md`) Theorem 14: equivalence classes don't end at gaps in Prior structures via model surgery. Burgess 1982 (`literature/Burgess_1982_Axioms_for_tense_logic_Since_and_Until.md`): chronicle construction and connection to Prior structures.

**Tasks**:
- [ ] **Task 5.1**: Audit existing infrastructure for the Prior-UZ/SZ bridge:
  - Search ChronicleToCountermodel.lean, Transfer.lean, and GoodStructuresModelSurgery.lean for:
    - `OrderedMonadicStructure` instances on LimitDomSubtype or similar types
    - `semantic_prior_UZ`, `semantic_prior_SZ` proofs for chronicle-related structures
    - `contemp_equiv` or k-type equivalence on limit domain points
  - Document what exists and what gaps remain.

- [ ] **Task 5.2**: Construct the bridge from LimitDomSubtype to the model surgery pipeline:
  - Option A (preferred): If there is already an OrderedMonadicStructure on LimitDomSubtype, use it and apply `no_gaps_discrete`.
  - Option B: If not, construct one. LimitDomSubtype has a linear order (inherited from Q). The monadic predicates come from the MCS labeling. Show the constructed structure satisfies Prior-UZ and Prior-SZ.
  - Estimated: 100-200 lines.

- [ ] **Task 5.3**: Prove IsSuccArchimedean using the model surgery result:
  - From `no_gaps_discrete` + `one_class`: the limit domain has one equivalence class and no gaps.
  - One class + no gaps in a discrete order implies every pair is connected by finite succ-iteration.
  - Replace body of `limitDomSubtype_isSuccArchimedean` (lines 789-806).
  - Estimated: 50-150 lines.

- [ ] **Task 5.4**: **Verify against literature**: Confirm the rewiring correctly implements Reynolds 1994 Theorem 14: (1) chronicle limit domain forms a valid Prior structure, (2) `no_gaps_discrete` applies, (3) one class + no gaps implies succ-Archimedean. Cross-reference `literature/Reynolds_1994_Axiomatising_U_and_S_over_integer_time.md`.

- [ ] **Task 5.5**: Verify:
  - `lean_verify limitDomSubtype_isSuccArchimedean` -- no `sorryAx`
  - `lean_verify succ_embed_surjective` -- no `sorryAx` (uses the rewired def at line 1673)
  - `lake build Bimodal.Metalogic.BXCanonical.Chronicle.ChronicleToCountermodel` passes

**Timing**: 2-4 hours

**Depends on**: 3 (Phase 4 verifies the pipeline is sorry-free, but Phase 5 can start once Phase 3 is done since the pipeline was already known to be sorry-free from Phase 1)

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean`
  - Replace body of `limitDomSubtype_isSuccArchimedean` (lines 789-806)
  - May add helper lemmas for the Prior-UZ/SZ bridge
  - Update docstrings at lines 782-787 and 808-817

**Verification**:
- `lean_verify limitDomSubtype_isSuccArchimedean` shows no `sorryAx`
- `lean_verify succ_embed_surjective` shows no `sorryAx`
- `lake build Bimodal.Metalogic.BXCanonical.Chronicle.ChronicleToCountermodel` passes

---

### Phase 6: Full sorry chain verification [NOT STARTED]

**Goal**: Verify `completeness_discrete` is entirely sorry-free and no regressions exist.

**Tasks**:
- [ ] `lean_verify completeness_discrete` -- confirm no `sorryAx`
- [ ] `lean_verify countermodel_discrete_reynolds` -- confirm no `sorryAx`
- [ ] `lean_verify cantor_bfmcs_discrete_restricted_tc` -- confirm no `sorryAx`
- [ ] `lean_verify cantor_bfmcs_discrete_restricted_fuc` -- confirm no `sorryAx`
- [ ] `lean_verify succ_embed_surjective` -- confirm no `sorryAx`
- [ ] `lake build` passes with zero errors (full project)
- [ ] Run `grep -rn "^\s*sorry" Theories/` and verify no new sorry statements introduced
- [ ] Verify no `axiom` declarations outside proof system/frame constraints: `grep -rn "^axiom " Theories/` should show only proof-system axioms
- [ ] If any verification fails: identify the remaining sorry source and fix it

**Timing**: 1-2 hours

**Depends on**: 4, 5

**Files to modify**:
- None expected (verification only), unless sorry traces are found

**Verification**:
- `#print axioms completeness_discrete` -- NO `sorryAx`
- `lake build` -- zero errors
- No new sorry statements
- No extraneous axiom declarations

---

### Phase 7: Documentation cleanup [NOT STARTED]

**Goal**: Update docstrings referencing the old sorry chain, the deleted axiom, and the previous plan approaches.

**Tasks**:
- [ ] Update the file-level docstring at ChronicleToCountermodel.lean lines 57-91 to reflect that `limitDomSubtype_isSuccArchimedean` is now proved via model surgery
- [ ] Update the docstring at lines 782-787 (above `limitDomSubtype_isSuccArchimedean`) to note it is now sorry-free via the model surgery pipeline
- [ ] Update the docstring at lines 808-817 (Collapse-Based Discrete Pipeline section) to note the axiom has been replaced by a genuine proof
- [ ] Update the `succ_embed_surjective` docstring (lines 1656-1664) to note the full chain is sorry-free
- [ ] Update the audit section in Completeness.lean to reflect sorry-free status for `completeness_discrete`
- [ ] Mark dead BX pipeline code (lines 472-780: `chronicle_gap_contradiction`, `succ_cofinal` old version) with clear "DEAD CODE" annotations for future archival by task 255
- [ ] Update StaviCompleteness.lean docstrings near the fixed sorry sites to remove references to the bridge lemma being sorry'd
- [ ] Update NFGameBridge.lean module docstring to reflect that the bridge is now complete
- [ ] Write execution summary at `specs/155_reynolds_pipeline_activation/summaries/61_execution-summary.md`

**Timing**: 1 hour

**Depends on**: 6

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` -- update docstrings
- `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` -- update audit comments
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/StaviCompleteness.lean` -- update docstrings
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/NFGameBridge.lean` -- update module docstring

**Verification**:
- `lake build` still passes
- All docstrings accurately reflect the current sorry status

## Testing & Validation

- [ ] `lean_verify nf_char_eq_implies_rank_type_eq` shows no `sorryAx`
- [ ] `lean_verify interval_nf_types_eq_implies_interval_types_eq` shows no `sorryAx`
- [ ] `lean_verify nf_hypotheses_imply_duplicator_wins` shows no `sorryAx`
- [ ] `lean_verify duplicator_wins_implies_nf_agreement` shows no `sorryAx`
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

- `specs/155_reynolds_pipeline_activation/plans/61_implementation-plan.md` (this file, v62)
- Modified `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/StaviCompleteness.lean` (private defs made non-private, refactored nf_2var_from_interval_data)
- Modified `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/NFGameBridge.lean` (bridge lemmas: ~300-500 lines added)
- Modified `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` (rewired IsSuccArchimedean)
- Execution summary at `specs/155_reynolds_pipeline_activation/summaries/61_execution-summary.md`

## Rollback/Contingency

If the EF Game Bridge approach (Phase 3) hits a wall:

1. **Fallback A -- Bypass rank_type, use StaviFormula directly**: If the depth parameter relationship (k vs k/2) proves unmanageable with `rank_type`, bypass `rank_type` entirely. Prove directly that NF hypotheses imply `stavi_temporal_truth` agreement at all depths <= k/2, and use that to construct `decomposition_agreement` without going through `nf_profile_determines_rank_type`. This avoids the rank_type layer.

2. **Fallback B -- Direct formula agreement**: If connecting to the full game infrastructure is too complex, prove a weaker bridge: NF hypotheses imply `formula_agreement` (CustomGame.lean, line 239) at depth k/2 for 2-variable environments. This may require reproving parts of the composition argument specialized to the NF context, but avoids the full game machinery.

3. **Fallback C -- Direct Game Embedding (Option B from report 61)**: Keep everything inside StaviCompleteness.lean. Define a local game using NF types instead of StaviFormulas. Prove composition for this NF-game (~200-400 lines). Advantage: no private def changes needed. Disadvantage: duplicates game composition logic.

4. **Safe revert**: `git checkout -- Theories/Bimodal/Metalogic/WeakCanonical/EFGames/NFGameBridge.lean` and `git checkout -- Theories/Bimodal/Metalogic/WeakCanonical/EFGames/StaviCompleteness.lean` and `git checkout -- Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` to restore files. Phase 1 changes (NoGapsDiscreteProof.lean, GoodStructures.lean) are unaffected.
