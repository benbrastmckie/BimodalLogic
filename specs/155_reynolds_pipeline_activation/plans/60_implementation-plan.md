# Implementation Plan: Task #155 (v61)

- **Task**: 155 - Eliminate all sorries from completeness_discrete by fixing 3 root sorries in StaviCompleteness.lean (4-variable EF-game existential transfer, GHR93 Proposition 7) and rewiring limitDomSubtype_isSuccArchimedean to use the now-sorry-free Reynolds model surgery pipeline
- **Status**: [NOT STARTED]
- **Effort**: 12-18 hours
- **Dependencies**: None (task 199 dependency resolved; Phase 1 complete)
- **Research Inputs**: specs/155_reynolds_pipeline_activation/reports/58_proper-fix-research.md, specs/155_reynolds_pipeline_activation/reports/59_lit-ghr93-gaps.md, specs/155_reynolds_pipeline_activation/reports/59_lit-ghr94-ch9.md, specs/155_reynolds_pipeline_activation/reports/59_lit-reynolds94.md, specs/155_reynolds_pipeline_activation/reports/59_lit-burgess-venema.md, specs/155_reynolds_pipeline_activation/reports/60_blocker-resolution.md
- **Artifacts**: plans/60_implementation-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

This is plan v61, revised from v60 to address the Phase 2 blocker. The direct NF induction approach in v60's Phase 2 is mathematically impossible: `nf_2var_existential_transfer` cannot be proved by induction on depth because each inductive step increases variable count while decreasing depth, and zone matching does not preserve sub-interval type structure. Five sessions confirmed this failure mode.

The revised approach replaces v60's Phase 2 with the EF Game Bridge (Approach A from the blocker research report `60_blocker-resolution.md`). Instead of proving the 4-var existential transfer directly, we build bridge lemmas in NFGameBridge.lean connecting NF hypotheses on M.carrier to the existing sorry-free game composition infrastructure (Composition.lean, Decomposition.lean) on ExtendedCarrier. The game's compositional structure naturally handles sub-interval splitting via Duplicator strategies, which is precisely what the direct NF approach cannot do.

**Literature grounding**: This approach directly formalizes the proof strategy from GHR93 (Gabbay, Hodkinson, Reynolds 1993) Section 8, specifically:
- **GHR93 Proposition 7** (literature file lines 1293-1340): The game composition argument that shows Duplicator winning strategies compose across interval splits. This is what Composition.lean formalizes.
- **GHR93 Lemma 11 / Definition 8.8** (lines 1193-1242): Decomposition formulas characterize game positions. This is what Decomposition.lean formalizes.
- **GHR93 Corollary 5** (lines 1341-1347): Game agreement implies formula agreement, which bridges back to NF agreement.
- **Libkin 2004 Lemma 3.7** (Composition Lemma for Linear Orders): The general composition principle for EF games on linear orders that underpins the interval-splitting strategy.
- **GHR94 Chapter 9**: Monadic normal forms and their connection to EF games. Informs the depth parameter handling in Bridge A.

The revised Phase 2 has four sub-phases: (2A) NF-to-rank-type bridge, (2B) interval-type bridge, (2C) full Bridge A (NF hypotheses to Duplicator wins), and (2D) Bridge B + refactoring nf_2var_from_interval_data. Phases 3-6 remain structurally the same as v60 with minor adjustments to account for the bridge refactoring.

Definition of done: `#print axioms completeness_discrete` shows no `sorryAx`, `lake build` passes, no `axiom` declarations outside the proof system or frame constraints.

### Research Integration

- **Report 58** (proper fix research): Diagnosed model surgery limitation for IsSuccArchimedean. Superseded for Phase 2, still relevant for Phase 4 context.
- **Report 59 lit-ghr93-gaps**: GHR93 Proposition 7 game composition argument. The EF Game Bridge approach directly implements this.
- **Report 59 lit-ghr94-ch9**: GHR94 Chapter 9 monadic normal forms framework. Informs Bridge A depth parameter handling.
- **Report 59 lit-reynolds94**: Reynolds 1994 Theorem 14 model surgery. Relevant to Phase 4 rewiring.
- **Report 59 lit-burgess-venema**: Historical context for Until/Since axiomatization.
- **Report 60** (blocker resolution): Diagnosed the interval-splitting problem, recommended Approach A (EF Game Bridge), provided concrete implementation spec with function signatures and line estimates. This plan implements Approach A.

### Literature Sources

Each phase is grounded in specific literature from the `literature/` directory:

| Phase | Primary Literature | Specific Result |
|-------|-------------------|-----------------|
| Phase 2A | `Gabbay_Hodkinson_Reynolds_1994_Temporal_Logic_Foundations_Vol1_ch9.md` | NF/rank-type correspondence (Ch. 9 monadic NFs) |
| Phase 2A | `Doets_1989_Monadic_Pi11_Theories.md` | Doets Lemma 1.1 (NF profile characterization) |
| Phase 2B | `Gabbay_Hodkinson_Reynolds_1993_Temporal_expressive_completeness_gaps.md` | Definition 8.8.1 (interval type characterization) |
| Phase 2C | `Gabbay_Hodkinson_Reynolds_1993_Temporal_expressive_completeness_gaps.md` | Proposition 7 (game composition), Lemma 11 (decomposition equiv) |
| Phase 2C | `Libkin_2004_Elements_Finite_Model_Theory_ch3_ch7.md` | Lemma 3.7 (Composition Lemma for Linear Orders) |
| Phase 2C | `Thomas_1997_EF_Games_Composition_Monadic.md` | General composition method framework |
| Phase 2D | `Gabbay_Hodkinson_Reynolds_1993_Temporal_expressive_completeness_gaps.md` | Corollary 5 (game agreement implies formula agreement) |
| Phase 4 | `Reynolds_1994_Axiomatising_U_and_S_over_integer_time.md` | Theorem 14 (model surgery, no gaps at equivalence class boundaries) |
| Phase 4 | `Burgess_1982_Axioms_for_tense_logic_Since_and_Until.md` | Chronicle/canonical model construction |

Any step that cannot be justified by the above literature must be flagged as needing literature review before implementation.

### Prior Plan Reference

Plan v60 correctly identified the 3 root sorries in StaviCompleteness.lean and the cascade through model surgery. However, v60's Phase 2 attempted direct NF induction on `nf_2var_existential_transfer`, which is blocked by the interval-splitting problem. Plan v61 replaces Phase 2 with the EF Game Bridge approach while preserving all other phases.

### Roadmap Alignment

- Closing the sorry chain achieves sorry-free `completeness_discrete`
- Eliminates all axiom declarations outside the proof system
- Advances the critical path: Task 155 -> sorry-free `completeness_discrete`

## Goals & Non-Goals

**Goals**:
- Build EF Game Bridge in NFGameBridge.lean connecting NF world to game world
- Use bridge to close 3 sorries in StaviCompleteness.lean (the TRUE root cause)
- Rewire `limitDomSubtype_isSuccArchimedean` to use model surgery
- `#print axioms completeness_discrete` shows no `sorryAx`
- `lake build` passes
- No `axiom` declarations outside the proof system or frame constraints

**Non-Goals**:
- Proving `nf_2var_existential_transfer` by direct NF induction (proven impossible)
- Proving `chronicle_gap_contradiction` (dead BX pipeline code)
- Finite interval argument for IsSuccArchimedean (superseded by model surgery rewiring)
- Modifying GoodStructures.lean or NoGapsDiscreteProof.lean (Phase 1 work preserved)
- Resolving `prior_implies_succ_archimedean` in ReynoldsNoGaps.lean (deprecated)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Depth parameter mismatch (k vs 2k) in Bridge A is harder than estimated | H | M | The connection goes through `nf_profile_determines_rank_type` + `doets_lemma_1_1` + `stavi_table_mu_correct`. If direct bridging is too complex, build an intermediate lemma showing depth-k NF on M implies depth-k formula agreement on ExtendedCarrier (avoiding the 2k expansion). |
| `nf_profile_determines_rank_type` requires assumptions not available | M | M | Check its exact signature with `lean_hover_info` before starting. If it requires `extendedStructureWithMu` context, may need to construct the mu-extension explicitly. Fallback: use `stavi_temporal_truth_mu` directly instead of going through rank_type. |
| Bridge B (Duplicator wins to NF agreement) requires extracting NF from formula agreement | M | L | The winning condition gives `formula_agreement` at all depths <= r. Combined with `char_k_correct` this gives pointwise NF agreement. For 2-var NFs, need the game's environment transfer (already in Decomposition.lean's `ghr93_game_iff_decomposition`). |
| Rewiring limitDomSubtype_isSuccArchimedean requires Prior-UZ/SZ infrastructure not yet built | M | L | Phase 4 audits existing infrastructure first. If the bridge from LimitDomSubtype to OrderedMonadicStructure is missing, it may require 100-200 additional lines. |
| Full `lake build` regression from NFGameBridge.lean changes | L | L | Build after each sub-phase. NFGameBridge.lean is a leaf file with minimal downstream dependents. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 2 |
| 5 | 5 | 3, 4 |
| 6 | 6 | 5 |

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

### Phase 2: Build EF Game Bridge and close StaviCompleteness sorries [BLOCKED]

**Goal**: Build bridge lemmas in NFGameBridge.lean connecting NF hypotheses (depth-k 1-var NFs, interval_nf_types on M.carrier) to the existing sorry-free EF game infrastructure (rank_type, decomposition_agreement, ghr93_duplicator_wins on ExtendedCarrier). Then use the bridge to refactor `nf_2var_from_interval_data` in StaviCompleteness.lean, eliminating its dependency on `nf_2var_existential_transfer` and thereby closing all 3 sorries (lines 2347, 2429, 2787).

**BLOCKER** (Phase 2):
- **What failed**: The Bridge A approach (Task 2A.3: `nf_char_eq_implies_rank_type_eq`) cannot be proved as specified because of a depth mismatch: depth-k NFs on M capture FO depth <= k, but rank_type requires StaviFormula agreement at depth <= k, which has FO depth up to 2k (proved by `stavi_fo_depth_le_twice_depth`).
- **What was tried**: (1) Direct NF-to-rank_type bridge via nf_profile (fails cross-structure: gap structures are independent). (2) Bridge via char_k_correct (only gives agreement on char_k-characterizable formulas, not ALL StaviFormulas). (3) Doets lemma on M (captures depth-k FO, not depth-2k). (4) General n-var NF induction (requires sub-interval data that zone matching cannot provide). (5) Simplified game on M.carrier without gaps (would need parallel infrastructure from scratch).
- **Why it's stuck**: The depth doubling from StaviFormula depth to FO depth (stavi_depth k -> stavi_fo_depth <= 2k) means depth-k NF agreement on M is insufficient to determine rank_type at depth k. The bridge requires either (a) a depth bound on char_k formulas, (b) running the game at rank 2k, or (c) a custom NF-game that avoids StaviFormulas entirely.
- **What is needed**: Either (1) prove `stavi_depth (char_k nf_k) <= 2k` by tracking depth bounds through `nf_characterizable_by_stavi`, then run game at rank 2k; or (2) build a custom NF-game on M.carrier with composition, ~200-300 lines; or (3) revise plan to use a fundamentally different approach. See handoff at `specs/155_reynolds_pipeline_activation/handoffs/phase-2-depth-mismatch-handoff-20260602.md`.
- **Prohibited workarounds**: Do NOT use `sorry`, `def X := True`, or any vacuous placeholder

**CRITICAL INSTRUCTIONS FOR IMPLEMENTING AGENT**:
- This phase implements the EF Game Bridge (Approach A from report 60_blocker-resolution.md).
- Do NOT attempt direct NF induction on `nf_2var_existential_transfer`. This is proven impossible (5 sessions confirmed the interval-splitting problem).
- Follow the bridge construction order: rank_type bridge first, then interval_types bridge, then compose into full Bridge A, then Bridge B, then refactor.
- Defer to the blocker research report for function signatures and the literature files for mathematical content.
- Do NOT use `sorry` or `axiom` as fallbacks. If blocked, report what was tried.
- Read existing infrastructure in NFGameBridge.lean, Composition.lean, Decomposition.lean, and CharacteristicFormula.lean CAREFULLY before writing new code.

**Mathematical Background**:

The interval-splitting problem: when `zone_match_witness` places u' in (x',t') with the same 1-var NF as u, the sub-interval types of (x',u') and (u',t') are NOT determined by the interval types of (x',t'). The game argument solves this because Composition.lean's `ghr93_strategy_compose` splits intervals while maintaining the game invariant via Duplicator strategies at each sub-interval. The bridge connects the NF world to the game world so that the sorry-free game machinery handles the sub-interval splitting.

**Literature justification**: The composition method for EF games on linear orders (Libkin 2004, Section 3.2, Proof #2 of Theorem 3.6) shows that when a point z splits an interval [a,b], the game type of ([a,b],z) is determined by the game types of [a,z] and [z,b]. This is the exact principle that handles sub-interval splitting -- each sub-interval is treated independently via its own game strategy, and the strategies compose. GHR93 Proposition 7 (pp. 113-114) applies this principle to temporal structures with decomposition formulas (Definition 8.8), showing that Duplicator strategies compose across arbitrary m-tuples of points. Thomas 1997 provides the general framework connecting the composition method to monadic theories of ordinal words.

**Sub-phase 2A: NF-to-rank-type bridge (~100-150 lines)**

Prove that depth-k 1-var NF agreement on M.carrier implies rank_type agreement on ExtendedCarrier.

**Literature basis**: GHR93 Definition 8.8.1 defines X_t as the conjunction of all temporal formulas of rank < r true at t. This is the temporal-logic analog of `rank_type`. The bridge from NF to rank_type formalizes the correspondence between the NF characterization (GHR94 Ch. 9) and the temporal characterization (GHR93 Def. 8.8.1). See also Doets 1987/1989 for the monadic Pi-1-1 theory connection.

- [ ] **Task 2A.1**: Audit the relationship between `nf_characteristic M k 1` and `rank_type` by reading:
  - `CharacteristicFormula.lean`: find `nf_profile_determines_rank_type` (line ~250), `nf_profile_determines_stavi_truth`, `doets_lemma_1_1`
  - `TypeFormulas.lean`: find `stavi_temporal_truth_mu` (line ~304), `rank_type` definition
  - `StaviCompleteness.lean`: find `stavi_table_mu_correct` and `char_k_correct`
  - Document exact signatures and what hypotheses they require.

- [ ] **Task 2A.2**: Determine the depth parameter relationship. The NF world uses depth k on M.carrier. The game world uses rank r on ExtendedCarrier where `stavi_temporal_truth_mu` at depth r corresponds to quantifier depth 2r on the mu-extended structure. Determine whether `r = k` or `r = k/2` or some other relationship is needed for the bridge.

- [ ] **Task 2A.3**: Prove `nf_char_eq_implies_rank_type_eq`:
  ```lean
  theorem nf_char_eq_implies_rank_type_eq {sig : MonadicSignature}
      {M M' : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
      {k : Nat} {x : M.carrier} {x' : M'.carrier}
      (h_nf : nf_characteristic M k 1 (fun _ => x) =
              nf_characteristic M' k 1 (fun _ => x')) :
      rank_type M atomMap k (extendPoint x) =
      rank_type M' atomMap k (extendPoint x')
  ```
  The proof path: `nf_characteristic` agreement -> `nf_eval_nf` agreement for all depth-k NFs -> `stavi_temporal_truth` agreement (via `char_k_correct` or `nf_char_eq_implies_stavi_char_agree` already in NFGameBridge.lean) -> `rank_type` agreement (via `nf_profile_determines_rank_type` or directly from the StaviFormula agreement).

- [ ] **Task 2A.4**: **Verify against literature**: Confirm that the proved `nf_char_eq_implies_rank_type_eq` correctly captures the correspondence between GHR94 Ch. 9 NF types and GHR93 Def. 8.8.1 temporal rank types. The depth parameter relationship (k vs r) should match the paper's usage.

- [ ] **Task 2A.5**: Verify sub-phase compiles: `lake build Bimodal.Metalogic.WeakCanonical.EFGames.NFGameBridge`

**Sub-phase 2B: Interval-type bridge (~50-80 lines)**

Prove that `interval_nf_types` agreement on M.carrier implies `interval_types` agreement on ExtendedCarrier.

**Literature basis**: GHR93 Definition 8.8.1 defines X_{(t,u)} as the disjunction of X_v for all non-gap points v in (t,u). This is the temporal-logic analog of `interval_types`. The bridge formalizes: `interval_nf_types` (which NF types are realized in an interval) determines `interval_types` (which rank types are realized), because each NF type maps to a unique rank type via Bridge A.

- [ ] **Task 2B.1**: Read the definitions of `interval_nf_types` (StaviCompleteness.lean) and `interval_types` (Decomposition.lean or TypeFormulas.lean). Document how they relate:
  - `interval_nf_types M k x t` = set of depth-k 1-var NFs realized in the open interval (x,t)
  - `interval_types M atomMap r a b` = set of rank_types realized in the open interval (a,b) on ExtendedCarrier
  - The bridge: each NF type in interval_nf_types maps to a rank_type via the Bridge A helper. If the NF type sets agree, the rank_type sets agree.

- [ ] **Task 2B.2**: Prove `interval_nf_types_eq_implies_interval_types_eq`:
  ```lean
  theorem interval_nf_types_eq_implies_interval_types_eq {sig : MonadicSignature}
      {M M' : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
      {k : Nat} {x t : M.carrier} {x' t' : M'.carrier}
      (h_int : interval_nf_types M k x t = interval_nf_types M' k x' t') :
      interval_types M atomMap k (extendPoint x) (extendPoint t) =
      interval_types M' atomMap k (extendPoint x') (extendPoint t')
  ```
  The proof: show that `y` in `(x,t)` with `nf_characteristic M k 1 (fun _ => y) = nf_k` maps to `extendPoint y` in `(extendPoint x, extendPoint t)` with `rank_type = nf_char_eq_implies_rank_type_eq(nf_k)`. Since interval_nf_types encodes which NF types are realized, and interval_types encodes which rank_types are realized, the set equality transfers.

- [ ] **Task 2B.3**: Also prove the analogous lemmas for `above_max_type` and `below_min_type` if these are needed by `decomposition_agreement`. Read `decomposition_agreement` in Decomposition.lean to determine exactly what hypotheses it requires.

- [ ] **Task 2B.4**: **Verify against literature**: Confirm that the interval_types bridge matches GHR93 Definition 8.8.1's X_{(t,u)} construction. The set of realized types in an interval should correspond to the decomposition formula's interval predicates (GHR93 Def. 8.8.2b).

- [ ] **Task 2B.5**: Verify sub-phase compiles: `lake build Bimodal.Metalogic.WeakCanonical.EFGames.NFGameBridge`

**Sub-phase 2C: Full Bridge A -- NF hypotheses to Duplicator wins (~80-120 lines)**

Compose the rank_type and interval_type bridges into a proof that NF hypotheses imply `ghr93_duplicator_wins`.

**Literature basis**: GHR93 Lemma 11 (lines 1222-1242) establishes the equivalence between Duplicator winning and decomposition formula agreement. GHR93 Proposition 7 (lines 1293-1340) shows that decomposition agreement at the right parameters gives Duplicator a winning strategy for the full game. The bridge composes: NF hypotheses -> decomposition_agreement (via 2A+2B) -> ghr93_duplicator_wins (via Lemma 11 / ghr93_game_iff_decomposition already in Decomposition.lean).

- [ ] **Task 2C.1**: Read `ghr93_duplicator_wins` definition and `ghr93_game_iff_decomposition` in Decomposition.lean. Understand what `decomposition_agreement` requires: rank_type agreement at endpoints, interval_types agreement, above_max_type agreement, below_min_type agreement. **Verify against literature**: confirm this matches GHR93 Lemma 11's decomposition formula structure.

- [ ] **Task 2C.2**: Prove `nf_hypotheses_imply_decomposition_agreement`:
  ```lean
  theorem nf_hypotheses_imply_decomposition_agreement {sig : MonadicSignature}
      {M M' : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
      {k : Nat} {x t : M.carrier} {x' t' : M'.carrier}
      (h_nf_x : nf_characteristic M k 1 (fun _ => x) =
                nf_characteristic M' k 1 (fun _ => x'))
      (h_nf_t : nf_characteristic M k 1 (fun _ => t) =
                nf_characteristic M' k 1 (fun _ => t'))
      (h_order_xt : x < t ↔ x' < t')
      (h_interval : interval_nf_types M k x t = interval_nf_types M' k x' t')
      (h_above : above_max_nf_types M k t = above_max_nf_types M' k t')
      (h_below : below_min_nf_types M k x = below_min_nf_types M' k x') :
      decomposition_agreement M M' atomMap k
        (extendPoint x) (extendPoint t) (extendPoint x') (extendPoint t')
  ```
  Uses `nf_char_eq_implies_rank_type_eq` (2A) and `interval_nf_types_eq_implies_interval_types_eq` (2B).

- [ ] **Task 2C.3**: Compose with `ghr93_game_iff_decomposition` to get `ghr93_duplicator_wins`:
  ```lean
  theorem nf_hypotheses_imply_duplicator_wins {sig : MonadicSignature}
      {M M' : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
      {k n : Nat} {x t : M.carrier} {x' t' : M'.carrier}
      (h_nf_x : ...) (h_nf_t : ...) (h_order : ...) 
      (h_interval : ...) (h_above : ...) (h_below : ...) :
      ghr93_duplicator_wins M M' atomMap n k
        (extendPoint x) (extendPoint t) (extendPoint x') (extendPoint t')
  ```

- [ ] **Task 2C.4**: **Verify against literature**: The composed bridge should match GHR93 Proposition 7's hypothesis structure: given NF agreement at endpoints and interval-type agreement at all adjacent pairs, the Duplicator wins the full game. Check that parameter functions f(n), g(n) from GHR93 Definition 8.9 are correctly handled in the Lean formalization.

- [ ] **Task 2C.5**: Verify sub-phase compiles: `lake build Bimodal.Metalogic.WeakCanonical.EFGames.NFGameBridge`

**Sub-phase 2D: Bridge B + refactor nf_2var_from_interval_data (~100-150 lines)**

Prove that Duplicator winning implies NF agreement, then refactor `nf_2var_from_interval_data` to use the bridge instead of `nf_fraisse_compression` + `nf_2var_existential_transfer`.

**Literature basis**: GHR93 Corollary 5 (lines 1341-1347) establishes that game agreement implies formula agreement, which in turn gives NF agreement. This is the "Bridge B" direction. The refactoring replaces the failed direct NF induction path with the game-theoretic path that GHR93 uses.

- [ ] **Task 2D.1**: Prove `duplicator_wins_implies_nf_agreement`:
  ```lean
  theorem duplicator_wins_implies_nf_agreement {sig : MonadicSignature}
      {M M' : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
      {k : Nat} {x t : M.carrier} {x' t' : M'.carrier}
      (hwin : ghr93_duplicator_wins M M' atomMap 2 k
        (extendPoint x) (extendPoint t) (extendPoint x') (extendPoint t')) :
      nf_characteristic M k 2 (Fin.cons x (fun _ => t)) =
      nf_characteristic M' k 2 (Fin.cons x' (fun _ => t'))
  ```
  The proof: Duplicator winning at rank k with 2 pebbles gives `formula_agreement` at depth k. This means for every StaviFormula A of depth <= k, `stavi_temporal_truth_mu M atomMap k (extendPoint x) A <-> stavi_temporal_truth_mu M' atomMap k (extendPoint x') A` (and similarly for t/t'). Via `char_k_correct`, this gives `nf_eval_nf` agreement at all depth-k NFs. Via `nf_eval_unique`, this gives `nf_characteristic` equality.

  NOTE: The `n = 2` case means the game is played with 2 pebble pairs (for the 2-var NF). The game's formula_agreement gives StaviFormula agreement, which gives temporal formula agreement, which via char_k gives NF agreement. The conversion from 2-pebble game agreement to 2-var NF agreement is the key step.

- [ ] **Task 2D.2**: Prove the combined bridge theorem `nf_2var_from_bridge`:
  ```lean
  theorem nf_2var_from_bridge {sig : MonadicSignature}
      {M M' : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
      {k : Nat} {x t : M.carrier} {x' t' : M'.carrier}
      (h_nf_x : nf_characteristic M k 1 (fun _ => x) =
                nf_characteristic M' k 1 (fun _ => x'))
      (h_nf_t : nf_characteristic M k 1 (fun _ => t) =
                nf_characteristic M' k 1 (fun _ => t'))
      (h_order_xt : x < t ↔ x' < t')
      (h_interval : interval_nf_types M k x t = interval_nf_types M' k x' t')
      (h_above : above_max_nf_types M k t = above_max_nf_types M' k t')
      (h_below : below_min_nf_types M k x = below_min_nf_types M' k x') :
      nf_characteristic M k 2 (Fin.cons x (fun _ => t)) =
      nf_characteristic M' k 2 (Fin.cons x' (fun _ => t'))
  ```
  Composition: `nf_hypotheses_imply_duplicator_wins` (2C) -> `duplicator_wins_implies_nf_agreement` (2D.1).

- [ ] **Task 2D.3**: Refactor `nf_2var_from_interval_data` in StaviCompleteness.lean. Replace its current proof body (which calls `nf_fraisse_compression` requiring the sorry-bearing `nf_2var_existential_transfer`) with a direct application of `nf_2var_from_bridge`. This eliminates the dependency on `nf_2var_existential_transfer` entirely.
  - File: `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/StaviCompleteness.lean`
  - Read `nf_2var_from_interval_data` (find its definition, likely around line 2500+)
  - Verify its signature matches the hypotheses of `nf_2var_from_bridge`
  - Replace proof body with: `exact nf_2var_from_bridge h_nf_x h_nf_t h_order h_interval h_above h_below`
  - If signatures don't exactly match, add adapter lemmas.
  - Estimated: 20-50 lines for the refactoring and adapters.

- [ ] **Task 2D.4**: Verify the refactoring eliminates the sorry chain:
  - `lean_verify nf_2var_from_interval_data` -- no `sorryAx`
  - `lean_verify nf_2var_existential_transfer` -- this theorem may still have sorries, but it is no longer in the dependency chain of `nf_2var_from_interval_data`. Confirm it is unused.
  - If `nf_2var_existential_transfer` is used elsewhere, determine if those uses also need refactoring or if they are dead code.
  - `lake build Bimodal.Metalogic.WeakCanonical.EFGames.StaviCompleteness` passes

- [ ] **Task 2D.5**: Full sub-phase verification:
  - `lake build Bimodal.Metalogic.WeakCanonical.EFGames.NFGameBridge` passes
  - `lake build Bimodal.Metalogic.WeakCanonical.EFGames.StaviCompleteness` passes
  - No new sorry or axiom introduced

**Timing**: 6-10 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/NFGameBridge.lean` (extend with bridge lemmas: ~300-460 lines added)
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/StaviCompleteness.lean` (refactor `nf_2var_from_interval_data` proof body)

**Verification**:
- `lean_verify nf_2var_from_interval_data` shows no `sorryAx`
- `lean_verify nf_char_eq_implies_rank_type_eq` shows no `sorryAx`
- `lean_verify nf_hypotheses_imply_duplicator_wins` shows no `sorryAx`
- `lean_verify duplicator_wins_implies_nf_agreement` shows no `sorryAx`
- `lake build Bimodal.Metalogic.WeakCanonical.EFGames.NFGameBridge` passes
- `lake build Bimodal.Metalogic.WeakCanonical.EFGames.StaviCompleteness` passes

---

### Phase 3: Verify sorry cascade resolution [NOT STARTED]

**Goal**: Confirm that fixing `nf_2var_from_interval_data` (via the bridge refactoring) makes `nf_exist_sf_guarded_backward` (line 2787) sorry-free, and verify the full cascade through `stavi_expressive_completeness` -> `US_expressively_complete_over_prior` -> model surgery pipeline.

**CRITICAL INSTRUCTIONS FOR IMPLEMENTING AGENT**:
- This phase is primarily verification. If Sorry 3 does NOT resolve automatically, investigate why and fix it.
- The bridge refactoring in Phase 2 bypasses `nf_2var_existential_transfer` entirely. The sorry at line 2787 in `nf_exist_sf_guarded_backward` depends on `nf_2var_from_interval_data`, which is now sorry-free. Therefore Sorry 3 should resolve automatically.

**Tasks**:
- [ ] **Task 3.1**: Verify `nf_exist_sf_guarded_backward` is sorry-free:
  - `lean_verify nf_exist_sf_guarded_backward` -- confirm no `sorryAx`
  - If still sorry: read lines 2760-2787 and determine what additional work is needed. The sorry at line 2787 should now resolve because its dependency `nf_2var_from_interval_data` is sorry-free via the bridge.

- [ ] **Task 3.2**: If Sorry 3 did NOT resolve automatically, fix it:
  - The proof structure at line 2787 needs to extract witness x from the temporal formula, determine its 1-var NF via char_k_correct, extract interval types from the interval guard, and apply `nf_2var_from_interval_data` to conclude the 2-var NF equals sub_nf.
  - This is a DOWNSTREAM fix, not a separate mathematical argument.
  - Estimated: 50-150 lines if needed.

- [ ] **Task 3.3**: Verify the full Stavi cascade:
  - `lean_verify stavi_expressive_completeness` -- no `sorryAx`
  - `lean_verify US_expressively_complete_over_prior` -- no `sorryAx` (PriorExpressiveness.lean:371)
  - These should be sorry-free as consequences.

- [ ] **Task 3.4**: Verify the model surgery cascade:
  - `lean_verify gap_prior_UZ_contradiction` -- no `sorryAx` (GoodStructuresModelSurgery.lean:1169)
  - `lean_verify reynolds_model_surgery_core` -- no `sorryAx` (GoodStructuresModelSurgery.lean:2058)
  - `lean_verify no_gaps_discrete_model_surgery` -- no `sorryAx` (GoodStructuresModelSurgery.lean:2133)
  - `lean_verify no_gaps_discrete` -- no `sorryAx` (NoGapsDiscreteProof.lean)

**Timing**: 1-2 hours

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/StaviCompleteness.lean` (only if Sorry 3 needs manual fix at lines 2760-2787)

**Verification**:
- All `lean_verify` checks above pass with no `sorryAx`
- `lake build Bimodal.Metalogic.WeakCanonical.EFGames.StaviCompleteness` passes

---

### Phase 4: Rewire limitDomSubtype_isSuccArchimedean to use model surgery [NOT STARTED]

**Goal**: Replace the sorry-bearing definition of `limitDomSubtype_isSuccArchimedean` (ChronicleToCountermodel.lean:789) to use the now-sorry-free Reynolds model surgery pipeline instead of the dead `succ_cofinal` -> `chronicle_gap_contradiction` path.

**CRITICAL INSTRUCTIONS FOR IMPLEMENTING AGENT**:
- Follow this plan step-by-step. Do NOT revert to the finite interval approach from plan v59.
- The model surgery pipeline is now sorry-free (verified in Phase 3).
- The key challenge is constructing an OrderedMonadicStructure on the chronicle's LimitDomSubtype and showing it satisfies Prior-UZ/SZ, so that `no_gaps_discrete` applies.
- Read ChronicleToCountermodel.lean carefully around lines 789-830 to understand the existing def structure.
- Check what infrastructure already exists for the Prior-UZ/SZ bridge in ChronicleToCountermodel.lean or Transfer.lean.

**Literature basis**: Reynolds 1994 (`literature/Reynolds_1994_Axiomatising_U_and_S_over_integer_time.md`) Theorem 14 proves that equivalence classes don't end at gaps in Prior structures via model surgery. The `no_gaps_discrete` theorem formalizes this for discrete structures. The chronicle construction and its connection to Prior structures is from the BX canonical model theory (Burgess 1982, `literature/Burgess_1982_Axioms_for_tense_logic_Since_and_Until.md`).

**Mathematical Approach**:

The goal is to show IsSuccArchimedean for LimitDomSubtype. The model surgery pipeline gives us `no_gaps_discrete`: in a discrete Prior structure, there are no gaps between contemporaneous equivalence classes. For the chronicle limit domain:

1. LimitDomSubtype is a discrete linear order with a successor function.
2. Define a k-type equivalence relation on LimitDomSubtype: two points a, b are equivalent if they satisfy the same temporal formulas up to depth k (for some fixed k related to the MCS).
3. By `no_gaps_discrete` (now sorry-free), this equivalence has no gaps between classes.
4. The chronicle construction ensures there is only ONE equivalence class (all points in the limit domain arise from extending the same MCS A).
5. One class + no gaps = the entire domain is one class = IsSuccArchimedean.

Alternatively (simpler): if `no_gaps_discrete` + `one_class` from NoGapsDiscreteProof.lean are already proved sorry-free, and they establish that the Prior structure has one equivalence class, then IsSuccArchimedean follows because every pair of points is in the same class, and within a single class in a discrete order, succ-iteration covers everything.

**Tasks**:
- [ ] **Task 4.1**: Audit the existing infrastructure for the Prior-UZ/SZ bridge:
  - Search ChronicleToCountermodel.lean, Transfer.lean, and GoodStructuresModelSurgery.lean for:
    - `OrderedMonadicStructure` instances on LimitDomSubtype or similar types
    - `semantic_prior_UZ`, `semantic_prior_SZ` proofs for chronicle-related structures
    - `contemp_equiv` or k-type equivalence on limit domain points
  - Document what exists and what gaps remain.

- [ ] **Task 4.2**: Construct the bridge from LimitDomSubtype to the model surgery pipeline:
  - Option A (preferred): If there is already an OrderedMonadicStructure on LimitDomSubtype or a closely related type, use it directly and apply `no_gaps_discrete`.
  - Option B: If not, construct one. LimitDomSubtype has a linear order (inherited from Q). The monadic predicates come from the MCS labeling: `limit_f` assigns each point an MCS which determines predicate truth. The temporal truth evaluation follows from the semantics of the chronicle.
  - Show the constructed structure satisfies Prior-UZ and Prior-SZ (these express that certain axiom instances hold in the structure).
  - Estimated: 100-200 lines.

- [ ] **Task 4.3**: Prove IsSuccArchimedean using the model surgery result:
  - From `no_gaps_discrete` and `one_class`: the limit domain has one equivalence class and no gaps between classes.
  - One class means: for any a, b in LimitDomSubtype, they are contemporaneously equivalent.
  - No gaps: there is no point between two equivalent points that is NOT equivalent to them.
  - In a discrete order, one class + no gaps implies every pair is connected by finite succ-iteration: given a < b, the succ chain from a either reaches b (done) or gets stuck at some point c < b where succ(c) > b, which contradicts one class + no gaps.
  - Replace the body of `limitDomSubtype_isSuccArchimedean` (lines 789-806) with this proof.
  - Estimated: 50-150 lines.

- [ ] **Task 4.4**: **Verify against literature**: Confirm that the rewiring correctly implements the Reynolds 1994 Theorem 14 argument: (1) the chronicle limit domain forms a valid Prior structure, (2) `no_gaps_discrete` applies to show no gaps between equivalence classes, (3) one class + no gaps implies succ-Archimedean. Cross-reference with `literature/Reynolds_1994_Axiomatising_U_and_S_over_integer_time.md`.

- [ ] **Task 4.5**: Verify the rewired definition compiles:
  - `lean_verify limitDomSubtype_isSuccArchimedean` -- no `sorryAx`
  - `lean_verify succ_embed_surjective` -- no `sorryAx` (uses the rewired def at line 1673)
  - `lake build Bimodal.Metalogic.BXCanonical.Chronicle.ChronicleToCountermodel` passes

**Timing**: 2-4 hours

**Depends on**: 2 (Phase 3 verifies the pipeline is sorry-free, but Phase 4 can start once Phase 2 is done)

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

### Phase 5: Full sorry chain verification [NOT STARTED]

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
- [ ] If any verification fails: identify the remaining sorry source and fix it. Common issues:
  - A theorem in the chain was not fully updated
  - A transitive dependency still carries sorryAx
  - An `axiom` declaration was not removed

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

**Goal**: Update docstrings referencing the old sorry chain, the deleted axiom, and the previous plan approaches.

**Tasks**:
- [ ] Update the file-level docstring at ChronicleToCountermodel.lean lines 57-91 to reflect that `limitDomSubtype_isSuccArchimedean` is now proved via model surgery (no axiom, no sorry)
- [ ] Update the docstring at lines 782-787 (above `limitDomSubtype_isSuccArchimedean`) to note it is now sorry-free via the model surgery pipeline
- [ ] Update the docstring at lines 808-817 (Collapse-Based Discrete Pipeline section) to note the axiom has been replaced by a genuine proof
- [ ] Update the `succ_embed_surjective` docstring (lines 1656-1664) to note the full chain is sorry-free
- [ ] Update the audit section in Completeness.lean to reflect sorry-free status for `completeness_discrete`
- [ ] Mark dead BX pipeline code (lines 472-780: `chronicle_gap_contradiction`, `succ_cofinal` old version) with clear "DEAD CODE" annotations for future archival by task 255
- [ ] Update StaviCompleteness.lean docstrings near the fixed sorry sites to remove references to the bridge lemma being sorry'd
- [ ] Update NFGameBridge.lean module docstring to reflect that the bridge is now complete (not partial)
- [ ] Write execution summary at `specs/155_reynolds_pipeline_activation/summaries/60_execution-summary.md`

**Timing**: 1 hour

**Depends on**: 5

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` -- update docstrings
- `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` -- update audit comments
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/StaviCompleteness.lean` -- update docstrings near fixed sites
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

- `specs/155_reynolds_pipeline_activation/plans/60_implementation-plan.md` (this file, v61)
- Modified `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/NFGameBridge.lean` (bridge lemmas: ~300-460 lines added)
- Modified `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/StaviCompleteness.lean` (refactored nf_2var_from_interval_data)
- Modified `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` (rewired IsSuccArchimedean)
- Execution summary at `specs/155_reynolds_pipeline_activation/summaries/60_execution-summary.md`

## Rollback/Contingency

If the EF Game Bridge approach (Phase 2) hits a wall:

1. **Fallback A -- Bypass rank_type, use StaviFormula directly**: If the depth parameter mismatch (k vs 2k) in Bridge A proves unmanageable, bypass `rank_type` entirely. Instead, prove directly that NF hypotheses imply `stavi_temporal_truth` agreement at all depths <= k, and use that to construct `decomposition_agreement` without going through `nf_profile_determines_rank_type`. This avoids the mu-extension depth doubling.

2. **Fallback B -- Direct formula agreement**: If connecting to the full game infrastructure is too complex, prove a weaker bridge: NF hypotheses imply `formula_agreement` at depth k for 2-variable environments. This may require reproving parts of the composition argument specialized to the NF context, but avoids the full ExtendedCarrier machinery.

3. **Fallback C -- Double induction (k,n)**: If the game bridge is blocked entirely, attempt Approach D from the blocker research (direct double induction on depth k and variable count n). While harder than the game bridge, it avoids the ExtendedCarrier machinery entirely. Risk: still requires solving the interval-splitting problem, but at the cost of a more complex induction.

4. **Safe revert**: `git checkout -- Theories/Bimodal/Metalogic/WeakCanonical/EFGames/NFGameBridge.lean` and `git checkout -- Theories/Bimodal/Metalogic/WeakCanonical/EFGames/StaviCompleteness.lean` and `git checkout -- Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` to restore files. Phase 1 changes (NoGapsDiscreteProof.lean, GoodStructures.lean) are unaffected.
