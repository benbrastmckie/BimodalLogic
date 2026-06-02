# Implementation Plan: Task #155 (v60)

- **Task**: 155 - Eliminate all sorries from completeness_discrete by fixing 3 root sorries in StaviCompleteness.lean (4-variable EF-game existential transfer, GHR93 Proposition 7) and rewiring limitDomSubtype_isSuccArchimedean to use the now-sorry-free Reynolds model surgery pipeline
- **Status**: [NOT STARTED]
- **Effort**: 10-16 hours
- **Dependencies**: None (task 199 dependency resolved; Phase 1 complete)
- **Research Inputs**: specs/155_reynolds_pipeline_activation/reports/58_proper-fix-research.md, specs/155_reynolds_pipeline_activation/reports/59_lit-ghr93-gaps.md, specs/155_reynolds_pipeline_activation/reports/59_lit-ghr94-ch9.md, specs/155_reynolds_pipeline_activation/reports/59_lit-reynolds94.md, specs/155_reynolds_pipeline_activation/reports/59_lit-burgess-venema.md
- **Artifacts**: plans/59_implementation-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

A complete code audit has identified the TRUE root cause of all sorries blocking `completeness_discrete`. The previous plan (v59) targeted `limitDomSubtype_isSuccArchimedean` directly via a finite interval argument in ChronicleToCountermodel.lean. The code audit reveals a fundamentally different picture: there are TWO parallel sorry paths to `completeness_discrete`, and BOTH are blocked by the SAME 3 root sorries in `StaviCompleteness.lean` (lines 2347, 2429, 2787). These are the forward and backward directions of the 4-variable existential transfer in `nf_2var_existential_transfer`, plus a downstream backward direction in `nf_exist_sf_guarded_backward`.

Fixing Sorries 1-2 makes the bridge lemma `nf_2var_from_interval_data` sorry-free, which automatically fixes Sorry 3. This cascades through `stavi_expressive_completeness` -> `US_expressively_complete_over_prior` -> `gap_prior_UZ_contradiction` -> `reynolds_model_surgery_core` -> `no_gaps_discrete_model_surgery` -> `no_gaps_discrete`, making the entire Path 2 (model surgery) sorry-free. Then `limitDomSubtype_isSuccArchimedean` (Path 1) is rewired to use model surgery instead of the dead `chronicle_gap_contradiction` code.

Definition of done: `#print axioms completeness_discrete` shows no `sorryAx`, `lake build` passes, no `axiom` declarations outside the proof system or frame constraints.

### Research Integration

- **Report 58** (proper fix research): Diagnosed that model surgery cannot prove IsSuccArchimedean directly (second-order). Recommends finite interval argument. This plan SUPERSEDES that recommendation: the code audit shows the finite interval approach targeted the wrong sorry chain. The true root cause is in StaviCompleteness.lean, not ChronicleToCountermodel.lean.
- **Report 59 lit-ghr93-gaps**: GHR93 is about expressive completeness of temporal connectives over linear orders with gaps. Section 8 proves Theorem 3 (Stavi completeness) via EF games. The 4-variable existential transfer at lines 2347/2429 is precisely GHR93 Proposition 7's game composition argument.
- **Report 59 lit-ghr94-ch9**: GHR94 Chapter 9 provides the formal framework for monadic normal forms and their connection to EF games.
- **Report 59 lit-reynolds94**: Reynolds 1994 Theorem 14 proves equivalence classes don't end at gaps in Prior structures via model surgery. This chain goes through `US_expressively_complete_over_prior` which depends on `stavi_expressive_completeness`.
- **Report 59 lit-burgess-venema**: Historical context for Until/Since axiomatization.

### Prior Plan Reference

Plans v56-v59 targeted different sorry chains (import cycle, omega-chain induction, axiom stopgap, finite interval). Plan v59 correctly identified `limitDomSubtype_isSuccArchimedean` as the blocking definition but proposed a direct proof rather than recognizing that the entire model surgery pipeline was blocked upstream by the StaviCompleteness sorries. This v60 plan addresses the TRUE root cause.

### Roadmap Alignment

- Closing the sorry chain achieves sorry-free `completeness_discrete`
- Eliminates all axiom declarations outside the proof system
- Advances the critical path: Task 155 -> sorry-free `completeness_discrete`

## Goals & Non-Goals

**Goals**:
- Fix 3 sorries in StaviCompleteness.lean (the TRUE root cause)
- Rewire `limitDomSubtype_isSuccArchimedean` to use model surgery
- `#print axioms completeness_discrete` shows no `sorryAx`
- `lake build` passes
- No `axiom` declarations outside the proof system or frame constraints

**Non-Goals**:
- Proving `chronicle_gap_contradiction` (dead BX pipeline code)
- Finite interval argument for IsSuccArchimedean (superseded by model surgery rewiring)
- Modifying GoodStructures.lean or NoGapsDiscreteProof.lean (Phase 1 work preserved)
- Resolving `prior_implies_succ_archimedean` in ReynoldsNoGaps.lean (deprecated, mathematically false for Z+Z)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| 4-variable existential transfer proof harder than estimated | H | M | The proof structure is clear from the existing code: zone_match_witness already finds u', atom agreement at 3 vars is fully proved (lines 2257-2317). Only the quantifier transfer at depth j' for 4-var extensions remains. This is a recursive application of the same bridge lemma at lower depth. |
| Recursive structure creates termination issues in Lean | M | M | The recursion is on j (depth), decreasing at each step. Use well-founded recursion on j or match on j values. The base case (j=0) is already handled in the code. |
| Rewiring limitDomSubtype_isSuccArchimedean requires new infrastructure | M | L | The model surgery pipeline is already sorry-free (GoodStructuresModelSurgery.lean has zero inline sorries). The rewiring needs to construct an OrderedMonadicStructure on LimitDomSubtype and show it satisfies Prior-UZ/SZ. |
| The 4-var transfer at depth j' needs sub-interval matching for the 3-point configuration (u,x,t) | M | M | This is the standard Fraisse game composition: the interval between any two of the 3 points in M is zone-matched to the corresponding interval in M'. The hypotheses h_interval_above, h_interval_below, h_above_max, h_below_min propagate to sub-intervals. |

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

### Phase 2: Fix Sorries 1 and 2 in nf_2var_existential_transfer [BLOCKED]

**Goal**: Close the two sorry sites at StaviCompleteness.lean lines 2347 and 2429. These are the forward and backward directions of the 4-variable existential transfer at depth j' for the 3-point configuration (u,x,t)/(u',x',t').

**CRITICAL INSTRUCTIONS FOR IMPLEMENTING AGENT**:
- Follow this plan step-by-step. Do NOT take shortcuts.
- Defer to the literature files for proof techniques, especially `literature/Gabbay_Hodkinson_Reynolds_1993_Temporal_expressive_completeness_gaps.md` (Section 8, Proposition 7) and `literature/Libkin_2004_Elements_Finite_Model_Theory_ch3_ch7.md`.
- Do NOT use `sorry` or `axiom` as fallbacks. If blocked, report what was tried.
- Read the existing code around the sorry sites CAREFULLY before modifying.

**Mathematical Background**:

The theorem `nf_2var_existential_transfer` (line 2214) proves: given bridge lemma hypotheses (1-var NF agreement at depth k, ordering, interval type agreement), for every j < k and every NormalForm chi of depth j with 3 variables, the existential transfer holds:
```
(exists u, nf_eval M j 3 (u::x::t) chi) <-> (exists u', nf_eval M' j 3 (u'::x'::t') chi)
```

The proof structure (already in the code):
1. Forward direction (lines 2236-2347): Given u in M, use `zone_match_witness` to find u' in M'. This succeeds (lines 2239-2241). Then prove 3-var atom agreement (lines 2257-2317, FULLY PROVED). Then split on j:
   - j=0: depth-0 NF is just atoms. Transfer is direct (lines 2323-2327, DONE).
   - j=j'+1: atoms transfer (lines 2335-2338, DONE). Quantifier part needs 4-var existential transfer at depth j' (line 2347, SORRY).

2. Backward direction (lines 2348-2429): Symmetric to forward. Same structure, same sorry at line 2429.

**The Key Insight**: At depth j'+1, the quantifier part requires showing:
```
(exists w, nf_eval M j' 4 (w::u::x::t) sub_nf) <-> (exists w', nf_eval M' j' 4 (w'::u'::x'::t') sub_nf)
```
This is a 4-variable existential transfer at depth j' for the 3-point configuration (u,x,t)/(u',x',t'). The zone_match_witness can again find w' from w using (u,x,t) as the reference frame. But we need bridge lemma hypotheses for the (u,x,t) configuration -- specifically, 1-var NF agreement at all 3 points and interval type agreement for all 3 pairs.

We ALREADY HAVE:
- 1-var NF agreement for u/u' (from zone_match_witness, line 2240: `h_nf_u`)
- 1-var NF agreement for x/x' (hypothesis `h_nf_x`)
- 1-var NF agreement for t/t' (hypothesis `h_nf_t`)
- Ordering agreement for all 6 pairs (from zone_match_witness: h_ux, h_xu, h_ut, h_tu, plus h_order_xt)

What we NEED but don't have directly: interval type agreement for the 3 pairs (u,x), (u,t), (x,t) at depth k. However:
- (x,t) interval types: we have h_interval_above, h_interval_below from the outer hypotheses
- (u,x) and (u,t) interval types: these follow from the zone_match_witness position of u'. Since u is in one of the zones (below x, between x and t, above t), and u' is in the corresponding zone with matching interval type data, the sub-interval types propagate.

**Approach**: Restructure `nf_2var_existential_transfer` to use induction on j (the depth parameter), making the recursive structure explicit. The code already matches on j in the proof body (line 2322: `match j`). Convert this to a proper induction.

**Tasks**:
**BLOCKER** (Phase 2):
- **What failed**: The sorry at StaviCompleteness.lean line 2347 (and symmetrically 2429) requires proving a 4-variable existential transfer at depth j' for the 3-point configuration (u,x,t)/(u',x',t'). After zone_match_witness finds u' with matching depth-k 1-var NF and orderings relative to x',t', the proof needs to show that for any w with a given depth-j' 4-var NF relative to (u,x,t), there exists w' in M' with the same depth-j' 4-var NF relative to (u',x',t').
- **What was tried**:
  1. Direct induction on j (depth of transfer): fails because the inductive step at depth j'+1 needs 5-var transfer at depth j', which needs 6-var transfer at depth j'-1, etc. Each level increases variables while decreasing depth, and at each level zone matching within a shared interval does NOT preserve relative ordering between independently matched points.
  2. Applying nf_2var_existential_transfer recursively for different 2-point frames (u,x), (u,t), (x,t): fails because each gives 3-var transfer for a different pair, but the 4-var NF encodes JOINT information about all variables simultaneously.
  3. Using nf_agreement_monotone + pointwise 1-var NF agreement: fails because n-variable NF agreement requires interval type data, not just pointwise data.
  4. Deriving sub-interval types from endpoint NFs: fails because depth-k 1-var NFs of u and x encode existential information about neighborhoods (above/below) but NOT about specific sub-intervals (x,u).
  5. Using nf_fraisse_compression at lower depth: circular because it needs the transfer that we are trying to prove.
  6. Merging nf_2var_from_interval_data and nf_2var_existential_transfer into a mutual induction on k: fails for the same reason - the inductive step still needs the 4-var transfer.
- **Why it's stuck**: The core mathematical issue is the "interval-splitting problem" (documented in NFGameBridge.lean lines 30-38). When zone_match_witness places u' in the interval (x',t') with the same 1-var NF as u, the sub-interval types of (x,u)/(x',u') and (u,t)/(u',t') are NOT determined by the interval types of (x,t)/(x',t'). A type realized in (x,t) might appear only in (x,u) in M but only in (u',t') in M'. This means zone matching does not preserve the interval-splitting structure needed for recursive transfer.
- **What is needed**: One of:
  (A) Implement the full EF game bridge (NF hypotheses -> decomposition_agreement -> ghr93_duplicator_wins -> game composition -> NF agreement). The game composition (Composition.lean, already sorry-free) handles interval splitting via the Duplicator strategy. Estimated ~300-500 lines for the bridge lemmas.
  (B) Prove an "interval-splitting zone match" lemma: given interval type agreement for (a,b)/(a',b') and a point w in (a,b), find w' in (a',b') with matching NF AND sub-interval type preservation. This requires a separate inductive argument. Estimated ~200-300 lines.
  (C) Restructure the proof to use a DIFFERENT characterization of 2-var NFs that avoids the existential transfer entirely (e.g., via temporal formula decomposition).
- **Prohibited workarounds**: Do NOT use `sorry`, `def X := True`, or any vacuous placeholder.

- [x] **Task 2.1**: Read and understand the existing proof around lines 2214-2430 thoroughly. *(completed — full analysis documented in blocker above)* Read `zone_match_witness` (find its definition in the same file) to understand what hypotheses it provides. Read `nf_fraisse_compression` to understand what it requires.
  - File: `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/StaviCompleteness.lean`
  - Read the GHR93 literature: `literature/Gabbay_Hodkinson_Reynolds_1993_Temporal_expressive_completeness_gaps.md`, Section 8
  - Document the exact hypotheses available at the sorry site and what is needed.

- [ ] **Task 2.2**: Prove a helper lemma for sub-interval type propagation from zone_match_witness. *(deviation: blocked — requires interval-splitting zone match, see blocker above)* When u is in the interval (x,t) and u' is the zone-matched point in M', the interval types of (x,u)/(x',u') and (u,t)/(u',t') are determined by the interval types of (x,t)/(x',t'). Specifically:
  - If x < u < t, then interval_nf_types M k x u is a subset of interval_nf_types M k x t (types in (x,u) are a subset of types in (x,t)), and similarly for (u,t).
  - The key property: zone_match_witness places u' so that the PARTITION of interval types at (x,t) into those in (x,u) and (u,t) is preserved.
  - This may require strengthening zone_match_witness or proving it as a consequence of the existing zone_match_witness output.
  - Estimated: 50-100 lines.

- [ ] **Task 2.3**: Restructure the forward direction proof. *(deviation: blocked — depends on Task 2.2)* Replace the `match j` block (lines 2322-2347) with an approach that handles the j'+1 case using the recursive transfer. The key proof obligation at line 2347 is:
  ```
  (exists w, nf_eval M j' 4 (w::u::x::t) sub_nf) <->
  (exists w', nf_eval M' j' 4 (w'::u'::x'::t') sub_nf)
  ```
  This can be proved by:
  - Showing that the 3-point config (u,x,t)/(u',x',t') satisfies bridge lemma hypotheses at depth k (1-var NFs agree, orderings agree, interval types agree -- using Task 2.2)
  - Applying `nf_2var_existential_transfer` recursively at depth j' < k with the 3-point config embedded into a 2-point frame (this requires reindexing variables)
  
  ALTERNATIVE (simpler): The 4-variable transfer at depth j' can be proved by applying zone_match_witness AGAIN at the (u,x,t) level to find w' from w. This gives a 4-point configuration with atom agreement at all 4 points. For j' = 0, atom agreement suffices. For j' > 0, the recursion continues but at lower depth. Since j' < j < k, this terminates.
  
  The simplest approach: prove `nf_2var_existential_transfer` by induction on j (not k), with the base case j=0 already handled. For the inductive step j'+1, the 4-var transfer at depth j' follows from the IH applied to the 3-point configuration (u,x,t)/(u',x',t'). This requires showing that the IH hypotheses (bridge lemma hypotheses at depth k for this configuration) are satisfied.
  - Estimated: 100-200 lines.

- [ ] **Task 2.4**: Implement the backward direction (line 2429). *(deviation: blocked — symmetric to Task 2.3)* This is symmetric to the forward direction. The exact same argument works with M and M' swapped. The code already sets up the symmetric hypotheses (lines 2348-2366).
  - Estimated: 50-100 lines (mostly mirroring the forward direction, possibly extract a shared helper).

- [ ] **Task 2.5**: Verify the fixes compile: *(deviation: blocked — depends on Tasks 2.3-2.4)*
  - `lake build Bimodal.Metalogic.WeakCanonical.EFGames.StaviCompleteness` passes
  - `lean_verify nf_2var_existential_transfer` shows no `sorryAx`
  - `lean_verify nf_2var_from_interval_data` shows no `sorryAx` (depends on the fixed theorem)

**Timing**: 5-8 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/StaviCompleteness.lean`
  - Lines 2322-2347: replace match/sorry with inductive proof (forward direction)
  - Lines 2413-2429: replace match/sorry with inductive proof (backward direction)
  - May need to add helper lemmas before `nf_2var_existential_transfer`

**Verification**:
- `lean_verify nf_2var_existential_transfer` shows no `sorryAx`
- `lean_verify nf_2var_from_interval_data` shows no `sorryAx`
- `lake build Bimodal.Metalogic.WeakCanonical.EFGames.StaviCompleteness` passes

---

### Phase 3: Verify Sorry 3 resolves automatically [NOT STARTED]

**Goal**: Confirm that `nf_exist_sf_guarded_backward` (line 2787) is now sorry-free as a consequence of fixing Sorries 1-2, and verify the full cascade through `stavi_expressive_completeness` -> `US_expressively_complete_over_prior`.

**CRITICAL INSTRUCTIONS FOR IMPLEMENTING AGENT**:
- This phase is primarily verification. If Sorry 3 does NOT resolve automatically, investigate why and fix it.
- The expected cascade: `nf_2var_existential_transfer` (sorry-free) -> `nf_2var_from_interval_data` (sorry-free, calls the fixed theorem at line 2507) -> `nf_exist_sf_guarded_backward` (should be sorry-free, as its only sorry at line 2787 is because "the bridge lemma is sorry'd").

**Tasks**:
- [ ] **Task 3.1**: Verify `nf_exist_sf_guarded_backward` is sorry-free:
  - `lean_verify nf_exist_sf_guarded_backward` -- confirm no `sorryAx`
  - If still sorry: read lines 2760-2787 and determine what additional work is needed. The docstring says "When the bridge is proved, this proof completes." So the sorry should simply be replaceable with the bridge lemma application.

- [ ] **Task 3.2**: If Sorry 3 did NOT resolve automatically, fix it:
  - The proof structure at line 2787 needs to extract witness x from the temporal formula, determine its 1-var NF via char_k_correct, extract interval types from the interval guard, and apply `nf_2var_from_interval_data` to conclude the 2-var NF equals sub_nf.
  - This is a DOWNSTREAM fix, not a separate mathematical argument. It should be straightforward given the bridge lemma.
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

- [ ] **Task 4.4**: Verify the rewired definition compiles:
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
- [ ] Write execution summary at `specs/155_reynolds_pipeline_activation/summaries/59_execution-summary.md`

**Timing**: 1 hour

**Depends on**: 5

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` -- update docstrings
- `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` -- update audit comments
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/StaviCompleteness.lean` -- update docstrings near fixed sites

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

- `specs/155_reynolds_pipeline_activation/plans/59_implementation-plan.md` (this file, v60)
- Modified `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/StaviCompleteness.lean` (fixed 3 sorries)
- Modified `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` (rewired IsSuccArchimedean)
- Execution summary at `specs/155_reynolds_pipeline_activation/summaries/59_execution-summary.md`

## Rollback/Contingency

If the 4-variable existential transfer proof (Phase 2) hits a wall:

1. **Fallback A**: Instead of proving the full recursive transfer, prove `nf_2var_from_interval_data` directly using a different technique. The bridge lemma's conclusion (depth-k 2-var NF equality) can potentially be proved by induction on k directly, folding the zone_match_witness argument into the inductive step. This avoids the 4-variable extension entirely. Higher effort (~300 lines) but avoids the recursive variable-count increase.

2. **Fallback B**: Prove `nf_exist_sf_guarded_backward` (Sorry 3) directly without going through the bridge lemma. If the formula construction in `nf_exist_sf_guarded` is rich enough, the backward direction might be provable by formula decomposition alone, bypassing the need for the 2-var NF equality.

3. **Fallback C**: If the model surgery rewiring (Phase 4) is too difficult, return to the finite interval approach from plan v59 (Phase 2 of that plan). This is a standalone proof of IsSuccArchimedean via successor stability, independent of the StaviCompleteness fixes. However, this would leave the StaviCompleteness sorries open, meaning Path 2 remains sorry'd.

4. **Safe revert**: `git checkout -- Theories/Bimodal/Metalogic/WeakCanonical/EFGames/StaviCompleteness.lean` and `git checkout -- Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` to restore files. Phase 1 changes (NoGapsDiscreteProof.lean, GoodStructures.lean) are unaffected.
