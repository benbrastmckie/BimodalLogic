# Implementation Plan: Task #305 -- Witness-Count Restructure (v19, Path C)

- **Task**: 305 - Rabinovich EA-formula implementation
- **Status**: [NOT STARTED]
- **Effort**: 10 hours
- **Dependencies**: None (all VecEA infrastructure sorry-free; ExistPart(0-1), CharPart(0-2) sorry-free)
- **Research Inputs**: reports/15_k0-base-case-design.md, reports/16_witness-count-restructure.md, reports/17_faithful-bridge-design.md
- **Artifacts**: plans/19_witness-count-restructure-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Replace the NF-depth strong induction in `prior_nonconstenv_2var_agree_until/since` with a witness-count induction matching Rabinovich's Lemma 5.3. After 17 research rounds and 5 blocked implementation attempts on plan v18 (NF-to-VecEA depth-1 bridge), the between-zone transfer problem is confirmed irreducible within the NF-depth induction framework. The resolution is architectural: change the induction variable from NF depth K to witness count n, matching the paper. The paper's induction never encounters the K=0 base case because at witness count n=0 the formula is vacuously V-EA with no transfer needed.

This plan pursues **Path C** (full witness-count restructure, confidence 80%, from the orchestrator handoff) rather than the failed Path B (NF-to-VecEA bridge, demoted to 35%) or speculative Path F (depth-1 squeeze, 55%). The key insight: the VecEA infrastructure already implements witness-count induction sorry-free (EANegationClosure.lean), so the gap is specifically a bridge from the NF composition layer in PriorComposition.lean to the VecEA witness-count layer.

### Research Integration

**Reports integrated in this revision:**

- **Report 15 (k0-base-case-design)**: Confirmed the K=0 problem is an artifact of NF-depth strong induction. Identified the irreducible between-zone predicate transfer at depth 0 with the Z counterexample. Established that Rabinovich's witness-count induction avoids this entirely.

- **Report 16 (witness-count-restructure)**: Analyzed the disconnect between NF-depth (vertical) and witness-count (horizontal) induction. Mapped BracketFormula n to NF quantifier conditions. Estimated Path C at 900-1400 lines across 4-6 files. Confirmed all sorry-free infrastructure would be preserved.

- **Report 17 (faithful-bridge-design)**: Exhaustive adversarial analysis of all 7 sorry sites. Confirmed only lines 869/964 are on the critical path (others are dead-code or downstream). Documented that the VecEA framework (VecEAFormula, VecEAClosure, EANegationClosure, VecEATranslation, NfToVecEA) is entirely sorry-free.

### Prior Plan Reference

Plan v18 (NF-to-VecEA bridge) attempted to build a depth-1 NF-to-VecEA bridge to handle the K=0 case. Phase 1 was BLOCKED after 5 implementation failures because the VecEA temporal formula transfers give witnesses relative to the wrong endpoint (some x-type point z1, not x' specifically). The zone-3 between-endpoint transfer is provably irreducible within the NF-composition framework. This plan abandons the bridge approach and instead restructures the induction variable.

### H3 Reference Mapping Table

| Rabinovich 2014 | Section | Lean Construct (existing) | Lean Construct (planned) | Status |
|-----------------|---------|--------------------------|-------------------------|--------|
| Prop 4.2: neg closure | Section 4 | `EANegationClosure.neg_2var_vec_ea` | -- | sorry-free |
| Lemma 5.1: bracket neg | Section 5 | `EANegationClosure.neg_interval_formula` | -- | sorry-free |
| Lemma 5.3: witness placement (n induction) | Section 5 | `EANegationClosure.neg_bounded_exists` | -- | sorry-free |
| Corollary 5.4: bracket-to-exists reduction | Section 5 | `EANegationClosure.neg_bounded_exists` | -- | sorry-free |
| Prop 3.5: V-EA to TL | Section 3 | `VecEATranslation.vecEA2_translateLeft/Right` | -- | sorry-free |
| Depth-0 NF-to-VecEA2 | (bridge) | `NfToVecEA.nf_depth0_existential_decomp` | -- | sorry-free |
| **Witness-count measure for NF** | Section 5 | -- | `WitnessCount.nf_witness_measure` | **Phase 1** |
| **NF existential to BracketFormula** | Section 5 | -- | `NfToVecEA1.nf_exist_to_bracket` | **Phase 2** |
| **Bracket transfer on Prior structures** | Lemma 5.1 | -- | `NfToVecEA1.bracket_prior_transfer` | **Phase 3** |
| **prior_nonconstenv K=0 via witness-count** | -- | sorry at lines 869, 964 | `PriorComposition.prior_nonconstenv_2var_agree_until/since` K=0 case | **Phase 4** |
| **Integration: completeness_discrete** | -- | sorry chain via KampBypass | Propagation verification | **Phase 5** |

### Roadmap Alignment

ROADMAP.md identifies the critical path: Task 303/305 (k>0 depth induction via Rabinovich Section 5 Lemma 5.1) -> sorry-free `completeness_discrete`. This plan directly resolves the SOLE remaining blocker: the K=0 sorry chain through `existPart_succ_n1_bypass` k>0 -> `prior_2var_transfer_until/since` -> `prior_nonconstenv_2var_agree_until/since` K=0 -> sorry.

## Goals & Non-Goals

**Goals**:
- Define a witness-count measure that maps NF quantifier conditions to a natural number compatible with BracketFormula indexing
- Build NF-to-BracketFormula conversion for depth-(K+1) existentials on 2-var environments
- Prove bracket-level cross-structure transfer on Prior structures using the sorry-free EANegationClosure infrastructure (witness-count induction, HasAttainedINF)
- Eliminate the K=0 sorry at PriorComposition.lean lines 869 and 964
- Verify sorry elimination propagates through KampBypass -> KampMutualInduction -> KampPrior -> `completeness_discrete`
- All work is additive (new files + minimal edits to PriorComposition.lean sorry sites)

**Non-Goals**:
- Fixing the dead-code sorrys in `nf_eval_from_lower_agree` (lines 507, 555) or `zone_compatible_witness` (lines 642, 647, 658) -- these are not on the critical path and become dead code once the K=0 sorry is resolved
- Restructuring the K>=1 recursive case in PriorComposition.lean (it works correctly via recursive call)
- Modifying any existing sorry-free infrastructure (VecEAFormula, VecEAClosure, EANegationClosure, NfToVecEA, etc.)
- Generalizing beyond what is needed for the K=0 case

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Witness-count measure for NF quantifier conditions is harder to define than expected (NF packages ALL quantifier types, not just satisfied ones) | H | M | Use the NF characteristic to extract the satisfied set. At depth 0, the 3-var NF's quantifier part is empty (purely atomic), so the "witnesses" are just the satisfied existential conditions. The measure is the count of satisfied quantifier-condition NFs in the outer layer. |
| NF-to-BracketFormula conversion loses information at depth > 0 (BracketFormula uses TemporalPred for point types, but NF quantifier conditions are richer) | H | M | At the K=0 case, the relevant existentials are depth-0 3-var, which are purely atomic. The BracketFormula point types ARE TemporalPred (predicate patterns), which exactly capture depth-0 atoms. For the general case, use char_fn to convert NF types to temporal formulas, then use the VecEA translation machinery. |
| Bracket-level cross-structure transfer requires new proof infrastructure beyond what EANegationClosure provides | M | M | EANegationClosure proves bracket negation (model-dependent), not cross-structure transfer. The transfer proof uses the VecEA-to-TL translation (sorry-free) combined with temporal truth transfer via char_correct. This is the same pattern used by existPart_succ_n1_bypass_k0 at k=0, which is sorry-free. |
| The rewiring of PriorComposition.lean K=0 is more complex than expected due to type mismatches between NF and BracketFormula frameworks | M | L | The integration point is narrow: replace a single `sorry` with a call to the new witness-count transfer theorem. The theorem statement is a biconditional on depth-0 3-var existentials, which matches the goal exactly. |
| Lean performance issues with new VecEA term manipulations | M | L | Follow NfToVecEA.lean patterns: use `set` bindings, helper lemmas, avoid deep unfolding. Split into multiple files if any exceeds 500 lines. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5 | 4 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Witness-Count Measure and NF Quantifier Decomposition [IN PROGRESS]

**Goal**: Define the witness-count measure that maps a depth-(K+1) 2-var NF existential condition (on a specific structure and environment) to a natural number n, and prove that this n bounds the number of distinct existential witnesses between two endpoints. This is the bridge between the NF framework's vertical quantifier depth and Rabinovich's horizontal witness count.

**Context**: At K=0, `prior_nonconstenv_2var_agree_until` needs depth-1 2-var agreement at [x,t]/[x',t']. The quantifier part of depth-1 2-var is: for each depth-0 3-var NF chi, `(exists w, nf_eval M 0 3 [w,x,t] chi) <-> (exists w', nf_eval N 0 3 [w',x',t'] chi)`. At depth 0, `nf_eval` is purely atomic (predicates + order), so each satisfied chi corresponds to a point w with specific predicates and specific zone (order relative to x and t). The witness count is the number of DISTINCT predicate types that appear as existential witnesses in the between-zone (zone 3: t < w < x).

The key insight from Rabinovich: the between-zone witnesses form a BracketFormula where each point type is a TemporalPred (the predicate pattern of the witness). The BracketFormula's n parameter IS the witness count.

**Tasks**:
- [ ] Create `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/WitnessCount.lean` with imports of NfToVecEA, EANegationClosure, VecEAFormula
- [ ] Define `zone3_witness_types`: given a depth-0 3-var NF characteristic and a structure M with environment [x,t] (t < x), extract the list of distinct TemporalPred types that appear as witnesses in zone 3 (points w with t < w < x). This is a Finset of TemporalPreds corresponding to satisfied depth-0 3-var NFs with zone-3 order atoms.
- [ ] Define `zone3_witness_count`: the cardinality of `zone3_witness_types`. This is the n for the BracketFormula encoding.
- [ ] Prove `zone3_witness_bound`: the number of distinct predicate types in zone 3 is bounded by `Fintype.card (TemporalPred sig)` (finite because sig has finitely many predicates). This ensures the measure is well-founded.
- [ ] Prove `zone3_types_transfer_equiv`: two structures M, N with matching depth-0 predicate types at x/x', t/t' (from h_x, h_t at depth >= 1) have the same set of satisfiable zone-3 NFs. That is, the set of depth-0 3-var NFs with zone-3 order atoms that are satisfiable on M at [w,x,t] for some w equals the set satisfiable on N at [w',x',t'] for some w'. Proof: the satisfiability of a depth-0 3-var NF with zone-3 atoms depends only on predicate availability in the interval, which is determined by the depth-1 quantifier conditions at x and t separately (for the endpoint-adjacent zones) plus the between-zone condition (which is the very thing we are proving). THIS IS DEFERRED TO PHASE 3 -- this phase focuses on the measure definition and basic properties only.
- [ ] Prove `zone3_bracket_encoding`: the zone-3 existential (exists w with t < w < x and specific predicates and depth-0 quantifier conditions relative to [x,t]) is equivalent to a BracketFormula holds statement. Specifically, for each satisfied zone-3 witness type, construct the corresponding BracketFormula entry.

**Timing**: 2 hours

**Depends on**: none

**Files to create/modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/WitnessCount.lean` (NEW, ~200-300 lines) -- witness-count measure definitions and basic properties

**Verification**:
- `lake build Bimodal.Metalogic.WeakCanonical.Kamp.WitnessCount` succeeds
- `grep -n sorry WitnessCount.lean` returns no proof sorry lines

---

### Phase 2: NF Existential to BracketFormula Conversion (Depth-0 3-var) [NOT STARTED]

**Goal**: Convert depth-0 3-var existentials (zone 3 only) into BracketFormula holds statements, and prove the conversion is correct. This extends the existing depth-0 2-var NF-to-VecEA2 conversion in NfToVecEA.lean to handle the 3-variable case needed for the K=0 quantifier conditions.

**Context**: At K=0, the quantifier condition for each depth-0 3-var NF chi with zone-3 order atoms is:
```
(exists w, t < w < x /\ nf_eval M 0 3 [w,x,t] chi) <->
BracketFormula.holds M atomMap t x bf_chi
```
where `bf_chi` is a BracketFormula with n=1 (one interior witness), pointTypes(0) = nfPred(chi's w-predicates), and segmentTypes = top (no segment constraints at depth 0).

The zone-3 case with MULTIPLE witness types (more than one distinct predicate pattern between t and x) is handled by disjunction: the full zone-3 existential is a disjunction over all satisfiable zone-3 NFs, each contributing one witness to a larger BracketFormula. But for the cross-structure transfer, we handle each NF type individually (the biconditional distributes over the finite disjunction), so each individual zone-3 NF maps to a BracketFormula with n=1.

**Tasks**:
- [ ] Create `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfToVecEA1.lean` with imports of NfToVecEA, WitnessCount, EANegationClosure, PriorINF
- [ ] Define `zone3_bracket`: given a depth-0 3-var NF chi with zone-3 order atoms, construct a `BracketFormula 1` capturing the existential `exists w, t < w < x /\ nf_eval M 0 3 [w,x,t] chi`. The BracketFormula has: pointTypes(0) = nfPred(nf_3var_w_proj chi) (the predicate type of the witness), segmentTypes = TemporalPred.top for all segments (no segment constraints at depth 0).
- [ ] Prove `zone3_bracket_correct_fwd`: if `exists w, t < w < x /\ nf_eval M 0 3 [w,x,t] chi`, then `zone3_bracket chi).holds M atomMap t x`. Proof: extract the witness w, show it satisfies the BracketFormula's point type via nfPred_correct, and the segment constraints are trivially top.
- [ ] Prove `zone3_bracket_correct_bwd`: if `(zone3_bracket chi).holds M atomMap t x`, then `exists w, t < w < x /\ nf_eval M 0 3 [w,x,t] chi`. Proof: extract the witness from the BracketFormula, reconstruct the depth-0 3-var NF evaluation from the TemporalPred + order structure. Use `reconstruct_nf_depth0`-style argument from NfToVecEA.lean.
- [ ] Combine into `zone3_bracket_iff`: the full biconditional.
- [ ] Define `zone3_temporal`: translate `zone3_bracket chi` into a temporal formula via `bracketBuildRight`/`bracketBuildLeft` (from NfToVecEA.lean and VecEATranslation.lean). The resulting temporal formula has quantifier depth <= 2.
- [ ] Prove `zone3_temporal_correct`: the temporal formula from `zone3_temporal` correctly captures the zone-3 existential on any structure. Compose `zone3_bracket_iff` with the bracket-to-temporal translation correctness theorems.

**Timing**: 2 hours

**Depends on**: 1

**Files to create/modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfToVecEA1.lean` (NEW, ~250-350 lines) -- zone-3 NF-to-BracketFormula conversion and temporal formula construction

**Verification**:
- `lake build Bimodal.Metalogic.WeakCanonical.Kamp.NfToVecEA1` succeeds
- `grep -n sorry NfToVecEA1.lean` returns no proof sorry lines
- Key theorems: `zone3_bracket_iff`, `zone3_temporal_correct` compile sorry-free

---

### Phase 3: Cross-Structure Bracket Transfer on Prior Structures [NOT STARTED]

**Goal**: Prove that zone-3 existentials transfer between Prior structures when the endpoints have matching depth-2 1-var NFs. This is the mathematical core of the restructure -- it replaces the irreducible between-zone problem with a temporal formula transfer argument.

**Context**: The key theorem:
```
Given:
  M, N: Prior structures (with HasAttainedINF via semantic_prior_UZ/SZ)
  x, t in M with t < x; x', t' in N with t' < x'
  h_x: depth-2 1-var agreement at x/x'
  h_t: depth-2 1-var agreement at t/t'
  char_fn, char_correct: characteristic formulas at depth <= 1
  chi: depth-0 3-var NF with zone-3 order atoms

Prove:
  (exists w, t < w < x /\ nf_eval M 0 3 [w,x,t] chi) <->
  (exists w', t' < w' < x' /\ nf_eval N 0 3 [w',x',t'] chi)
```

**Why this works (matching Rabinovich Lemma 5.3)**: From Phase 2, the zone-3 existential is equivalent to a temporal formula A (via zone3_temporal). The temporal formula A has quantifier depth <= 2. By char_correct at depth <= 1, temporal truth at t is determined by the depth-2 1-var NF at t. Since h_t gives depth-2 1-var agreement at t/t':
- `temporal_truth M atomMap t A <-> temporal_truth N atomMap t' A`

Composing:
- `(exists w in M) <-> temporal_truth M t A` (by zone3_temporal_correct on M)
- `temporal_truth M t A <-> temporal_truth N t' A` (by h_t at depth 2 + char_correct)
- `temporal_truth N t' A <-> (exists w' in N)` (by zone3_temporal_correct on N)

This sidesteps the between-zone problem entirely because we transfer at the TEMPORAL FORMULA level, not the NF level. The temporal formula A encodes the zone-3 existential as a single Until/Since formula at t, and t's depth-2 NF determines all temporal formulas of quantifier depth <= 2.

**CRITICAL SUBTLETY**: The temporal formula A from zone3_temporal is evaluated at t (for the Until direction) or x (for the Since direction). The transfer uses h_t (or h_x) at depth 2. The temporal formula involves bracket formulas with temporal predicates, and its quantifier depth is <= 2 because:
- BracketFormula with n=1 witness generates: F(P_w /\ ...) or S(P_w /\ ...) -- depth 1
- Combined with endpoint predicates: nfPred(x) adds depth 0
- Total: <= depth 2, within the range of char_correct at d <= 1 (which gives temporal depth K+1 = 1 when K=0... wait, we need to be careful here)

**REVISED ANALYSIS**: char_correct provides `temporal_truth M t (char_fn d nf_1) <-> nf_eval_nf M d 1 (fun _ => t) nf_1` for d <= K+1 = 1 (when K=0). But the temporal formula A from the bracket translation may have temporal quantifier depth > 1. Specifically, `bracketBuildRight` for a BracketFormula with n=1 generates `F(P_w /\ Q_seg)` which has temporal depth 1. Combined with the endpoint predicate, the full formula is `nfPred(t-type) /\ F(P_w)` -- still depth 1. So the temporal formula has quantifier depth <= 1, and char_correct at d <= 1 is SUFFICIENT.

Actually, the transfer is more subtle. We need `temporal_truth M atomMap t A <-> temporal_truth N atomMap t' A` for a SPECIFIC temporal formula A, not a generic "all temporal formulas of depth <= k agree." The correct mechanism is: h_t at depth 2 says `nf_eval_nf M 2 1 (fun _ => t) nf <-> nf_eval_nf N 2 1 (fun _ => t') nf` for all nf. The depth-2 1-var NF at t encodes, via its quantifier conditions, which depth-1 2-var existentials hold around t. In particular, the specific temporal formula `F(P_w /\ top)` (= "exists point above t with P_w predicates") is captured by a depth-1 1-var quantifier condition of t's NF. The key lemma: `temporal_truth M atomMap t (Formula.untl phi psi) <-> temporal_truth N atomMap t' (Formula.untl phi psi)` when h_t provides sufficient depth agreement and phi, psi have quantifier depth <= 1.

The ACTUAL mechanism available in the codebase: `char_correct` provides the NF-to-temporal bridge. Combined with h_t at depth 2, for any temporal formula of quantifier depth <= 1, truth at t transfers to t'. The zone-3 temporal formula has quantifier depth 1 (one level of Until/Since). So the transfer holds.

**Tasks**:
- [ ] In `NfToVecEA1.lean`, prove `zone3_temporal_depth_bound`: the temporal formula from `zone3_temporal chi` has temporal quantifier depth <= 1.
- [ ] Prove `temporal_transfer_depth1`: given depth-2 1-var agreement at t/t' and char_correct at d <= 1, for any temporal formula A with quantifier depth <= 1, `temporal_truth M atomMap t A <-> temporal_truth N atomMap t' A`. Proof: by induction on A's structure, using char_correct at depth 0 and 1 for the base cases (atom literals) and the quantifier conditions (Until/Since) via h_t's depth-1 quantifier conditions.

   **Note**: This may already be partially available via existing machinery. Check if `nf_eval_nf M 2 1 (fun _ => t) (nf_characteristic ...)` combined with `char_fn` provides this. If not, a direct structural induction on the temporal formula suffices. The formula A is built from `bracketBuildRight`/`bracketBuildLeft` which produce formulas from `Formula.untl`/`Formula.snce` + `Formula.and` + temporal predicates. Each temporal predicate has depth 0. Each Until/Since adds depth 1.

   **Alternative (simpler) approach**: Instead of proving generic temporal transfer, use the specific structure of A. From `zone3_bracket_iff`, the zone-3 existential = BracketFormula.holds. From `bracketBuildRight_correct`, BracketFormula.holds = temporal_truth at t. The temporal formula is `F(P_w)` where P_w is a conjunction of atom literals. Transfer `F(P_w)` at t: h_t at depth 2 gives depth-1 2-var existential transfer around t. The existential "exists y > t with P_w(y)" is a depth-1 2-var condition (the NF at [y,t] with y > t and P_w(y)). This transfers via h_t. Similarly, S(P_w) at x transfers via h_x.

- [ ] Prove `zone3_exist_transfer`: the main cross-structure transfer theorem. Given h_x at depth 2, h_t at depth 2, matching orders, and Prior-UZ/SZ:
  ```
  (exists w, t < w < x /\ nf_eval M 0 3 [w,x,t] chi) <->
  (exists w', t' < w' < x' /\ nf_eval N 0 3 [w',x',t'] chi)
  ```
  Proof composition:
  1. `(exists w in M) <-> zone3_bracket.holds M t x` (by zone3_bracket_iff)
  2. `zone3_bracket.holds M t x <-> temporal_truth M t A` (by bracketBuild correctness)
  3. `temporal_truth M t A <-> temporal_truth N t' A` (by temporal_transfer using h_t at depth 2)
  4. `temporal_truth N t' A <-> zone3_bracket.holds N t' x'` (by bracketBuild correctness on N, CONDITIONAL on matching endpoint types)
  5. `zone3_bracket.holds N t' x' <-> (exists w' in N)` (by zone3_bracket_iff on N)

  **SUBTLETY AT STEP 4**: The bracketBuild correctness on N requires knowing that x' satisfies the endpoint predicate (nfPred at x'). This follows from h_x at depth 2 which transfers x's predicate type to x'. Similarly for t's predicates.

  **SUBTLETY AT STEP 3**: The temporal formula A encodes "F(P_w /\ top)" which transfers via h_t's depth-1 quantifier conditions. But A is evaluated at t (the lower endpoint for Until). The transfer of "F(P_w)" from t to t' is: h_t at depth 2 implies depth-1 temporal truth agreement at t/t'. Since F(P_w) has temporal depth 1, it transfers.

  However, F(P_w) alone says "exists point > t with P_w" -- not "exists point between t and x with P_w." The bracket formula encodes the INTERVAL constraint. The correct decomposition: `zone3_bracket.holds M t x` = `exists w, t < w < x /\ P_w(w) /\ [segment constraints]`. Via bracketBuildRight, this becomes a temporal formula involving `F(P_w /\ S(endRight_pred))` or similar nested structure. The nesting is still depth <= 2 (F followed by S is depth 2).

  **REVISED STEP 3**: Need char_correct at d <= 1 to give temporal truth transfer at depth <= 2. With K=0, char_correct is available at d <= 1 (K+1 = 1). The temporal formula has depth <= 2 (F + S nesting). Transfer via h_t at depth 2: the depth-2 1-var NF at t determines all temporal truth up to depth 2 (by the fundamental CharPart theorem). So the transfer holds.

  **WAIT -- depth issue**: char_correct at d <= K+1 = 1 gives formulas characterizing depth-0 and depth-1 1-var NFs. But temporal depth 2 formulas involve two levels of quantification. The depth-2 1-var NF at t determines which depth-1 1-var NFs exist nearby (its quantifier conditions), which in turn determines which depth-0 NFs exist near those points (depth-1's quantifier conditions). This gives temporal depth 2 truth.

  **RESOLUTION**: The correct argument uses `nf_eval_nf M 2 1 (fun _ => t) nf_t <-> nf_eval_nf N 2 1 (fun _ => t') nf_t'` (from h_t) with nf_t = nf_t' (same NF). Combined with the CharPart(2) correctness: depth-2 1-var NF agreement implies temporal truth agreement for all TL(U,S) formulas up to temporal quantifier depth 2. This is NOT directly available as a single theorem in the codebase, but it follows from the CharPart correctness chain. The plan should include this as a proof step.

  **SIMPLIFICATION**: For the K=0 case specifically, the BracketFormula has n=1 (one witness). The temporal formula is `F(P_w /\ top)` = `F(P_w)` (depth 1). This IS within char_correct at d <= 1. Transfer of `F(P_w)` between t and t': from h_t at depth 2, the depth-1 2-var existential around t transfers. "exists y > t with P_w(y)" IS a depth-1 2-var condition (it asks for a specific depth-0 2-var NF at [y,t] with y > t and P_w(y) and possibly t's predicates). The transfer gives "exists y' > t' with P_w(y')". But we need y' < x' too.

  **THE BRACKET FORMULA APPROACH**: The BracketFormula encodes the INTERVAL constraint. `BracketFormula.holds M atomMap t x` requires witnesses BETWEEN t and x. The bracketBuild translation generates a formula that, evaluated at t, implies the existence of a point between t and some x-type point. On M, this x-type point is x itself. On N, the transferred formula gives existence of a point between t' and some x'-type point. The x'-type point may not be x'. BUT: we can add an endpoint constraint. The full transfer uses BOTH h_t and h_x.

  **ACTUAL APPROACH (follows Rabinovich)**: The zone-3 existential "exists w between t and x with P_w" is captured by the VecEA2 formula with endpointLeft = nfPred(t-type), endpointRight = nfPred(x-type), and bracket with 1 witness of type P_w. The VecEA2.holdsLeft at t says: "nfPred(t-type) holds at t AND exists z1 > t with nfPred(x-type) at z1 AND P_w between t and z1." On M, z1 = x works. On N, the temporal formula at t transfers via h_t at depth 2. The transferred formula gives z1' > t' with x-type predicates and P_w between t' and z1'. If z1' = x': done. If z1' is not x': z1' has x's predicates. We need the P_w point between t' and z1'. The P_w point y' is between t' and z1', so y' > t'. If z1' <= x': then y' < z1' <= x', so y' is between t' and x'. Done. If z1' > x': y' could be between t' and z1' but above x'. NOT done.

  **RESOLUTION VIA MINIMALITY**: On Prior structures with HasAttainedINF, use first-occurrence localization. The VecEA2 translation via bracketBuildRight produces a formula using HasAttainedINF.first_occ. The temporal formula at t encodes "exists FIRST x-type point above t, and P_w between t and that first x-type point." Call this first point r0. On M: r0 <= x (since x is an x-type point above t, the first one is <= x). So the P_w witness is between t and r0 <= x, hence between t and x. On N: h_t at depth 2 transfers the temporal formula. The transferred first x-type point r0' is the first x-type point above t' in N. We need r0' <= x'. Since h_x at depth 2 gives x' has x-type predicates AND h_t gives "first x-type above t' is r0'", is r0' <= x'? Yes: x' is an x-type point above t' (since t' < x' and x' has x's predicates). So the FIRST x-type point above t' is r0' <= x'. The P_w witness in the bracket is between t' and r0' <= x', hence between t' and x'.

  **THIS IS THE KEY INSIGHT THAT MAKES PATH C WORK.** The combination of:
  1. HasAttainedINF (first-occurrence minimality)
  2. The VecEA2 encoding with BOTH endpoint types
  3. h_t and h_x providing matching NF types at BOTH endpoints
  guarantees the transferred witness lands in the correct interval.

- [ ] Prove helper: `first_occ_within_interval`: on Prior structures, if nfPred(x-type) holds at x' and t' < x', then the first nfPred(x-type) point above t' is <= x'. Uses HasAttainedINF.first_occ_tp.
- [ ] Assemble the full transfer proof as described above.

**Timing**: 2.5 hours

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfToVecEA1.lean` -- add cross-structure transfer theorems (~200-350 lines)

**Verification**:
- `lake build Bimodal.Metalogic.WeakCanonical.Kamp.NfToVecEA1` succeeds
- `grep -n sorry NfToVecEA1.lean` returns no proof sorry lines
- Key theorem: `zone3_exist_transfer` compiles sorry-free

---

### Phase 4: Replace K=0 Sorry Sites in PriorComposition.lean [NOT STARTED]

**Goal**: Wire the zone-3 cross-structure transfer from Phase 3 into PriorComposition.lean to eliminate the K=0 sorry at lines 869 and 964.

**Context**: The sorry sites occur in the `| 0 =>` branch of `match K with` inside `prior_nonconstenv_2var_agree_until` (line 866-869) and `_since` (line 963-964). The goal at K=0 is:
```
forall nf : NormalForm sig 1 2,
    nf_eval_nf M 1 2 (Fin.cons x (fun _ => t)) nf <->
    nf_eval_nf N 1 2 (Fin.cons x' (fun _ => t')) nf
```
This decomposes into atoms (already proved as `h_atom`) + quantifier conditions:
```
forall chi : NormalForm sig 0 3,
  (exists w, nf_eval M 0 3 (Fin.cons w (Fin.cons x (fun _ => t))) chi) <->
  (exists w', nf_eval N 0 3 (Fin.cons w' (Fin.cons x' (fun _ => t'))) chi)
```

Each quantifier condition chi decomposes by zone (order atoms of w relative to x, t):
- Zone 1 (w < t): transfers via h_t's depth-1 quantifier conditions (sorry-free, existing)
- Zone 2 (w = t): transfers trivially (sorry-free, existing)
- Zone 3 (t < w < x): transfers via Phase 3's `zone3_exist_transfer` (NEW)
- Zone 4 (w = x): transfers trivially (sorry-free, existing)
- Zone 5 (x < w): transfers via h_x's depth-1 quantifier conditions (sorry-free, existing)

**Tasks**:
- [ ] Add `import Bimodal.Metalogic.WeakCanonical.Kamp.NfToVecEA1` to PriorComposition.lean
- [ ] At the K=0 sorry site (line 869, Until), replace `sorry` with a proof that:
  1. Uses `nf_eval_nf_agreement_iff_atom_quant` (or equivalent) to decompose the depth-1 2-var NF agreement into atoms + quantifier conditions
  2. Proves atom agreement via existing `h_atom`
  3. Proves each quantifier condition by case-splitting on the zone of chi (the depth-0 3-var NF's order atoms for variable 0 relative to variables 1 and 2)
  4. For zone 3: applies `zone3_exist_transfer` from NfToVecEA1.lean with M, N, x, t, x', t', h_x, h_t, h_UZ_M, h_SZ_M, h_UZ_N, h_SZ_N, char_fn, char_correct, chi
  5. For zones 1, 2, 4, 5: uses `exist_transfer_from_full_agree` applied to the single-endpoint 1-var agreement (from h_x or h_t weakened to the appropriate depth)
  6. Assembles the full depth-1 2-var agreement using `nf_characteristic_satisfies` + `nf_agreement_from_shared_nf` (same pattern as the K>=1 branch)
- [ ] Mirror the above at the K=0 sorry site (line 964, Since)
- [ ] Verify PriorComposition.lean compiles: `lake build Bimodal.Metalogic.WeakCanonical.Kamp.PriorComposition`
- [ ] Verify K=0 sorry sites are eliminated: `grep -n 'sorry' PriorComposition.lean` should show only the dead-code sorrys at lines 507, 555, 642, 647, 658

**Timing**: 1.5 hours

**Depends on**: 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/PriorComposition.lean` -- add import, replace 2 sorry sites (~60-120 lines of new proof code)

**Verification**:
- `lake build Bimodal.Metalogic.WeakCanonical.Kamp.PriorComposition` succeeds
- `grep -n 'sorry' PriorComposition.lean` returns only lines 507, 555, 642, 647, 658 (dead-code sorrys)
- `lean_verify` on `prior_nonconstenv_2var_agree_until` and `_since` confirms no sorryAx

---

### Phase 5: Integration Verification (KampBypass to completeness_discrete) [NOT STARTED]

**Goal**: Verify that eliminating the K=0 sorry in PriorComposition.lean propagates through the entire call chain to `completeness_discrete`, making the full Kamp theorem pipeline sorry-free.

**Context**: The sorry chain is:
```
completeness_discrete
  -> countermodel_discrete_reynolds_v2
    -> limitdom_is_good
      -> no_gaps_discrete_model_surgery
        -> US_expressively_complete_over_prior
          -> kamp_prior_expressive_completeness
            -> existPart_succ_n1_bypass (k>0)
              -> prior_2var_transfer_until/since (K=k-1)
                -> prior_nonconstenv_2var_agree_until/since (K=k-1)
```
With K=0 eliminated, the recursion works: k=1 calls K=0 (now sorry-free), k=2 calls K=1 (uses K=0 recursively), etc. All k>0 cases resolve.

**Tasks**:
- [ ] Run `lake build Bimodal.Metalogic.WeakCanonical.Kamp.KampBypass` -- verify compiles
- [ ] Run `lake build Bimodal.Metalogic.WeakCanonical.Kamp.KampMutualInduction` -- verify compiles
- [ ] Run `lake build Bimodal.Metalogic.WeakCanonical.Kamp.KampPrior` -- verify compiles
- [ ] Run `lean_verify` on `completeness_discrete` to confirm no sorryAx
- [ ] Run full `lake build` to verify clean project build with zero errors
- [ ] Final sorry audit: `grep -rn sorry Theories/Bimodal/Metalogic/WeakCanonical/Kamp/` to catalog remaining sorrys
- [ ] Document which remaining sorrys are dead-code vs. live. Expected: only dead-code sorrys at PriorComposition.lean lines 507, 555, 642, 647, 658 (nf_eval_from_lower_agree d=0, n=0 and zone_compatible_witness d=0, d=1, r=0) and any NfCharFormula.lean dead-code sorrys.

**Timing**: 2 hours

**Depends on**: 4

**Files to verify** (no modifications expected):
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampBypass.lean`
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampMutualInduction.lean`
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampPrior.lean`
- Full project via `lake build`

**Verification**:
- `lake build` succeeds with no errors
- `lean_verify` on `completeness_discrete` reports no sorryAx
- `grep -rn sorry Theories/Bimodal/Metalogic/WeakCanonical/Kamp/` shows only dead-code sorrys in PriorComposition.lean (lines 507, 555, 642, 647, 658) and NfCharFormula.lean dead-code sorrys (if any)

## Testing & Validation

- [ ] Phase 1: `lake build Bimodal.Metalogic.WeakCanonical.Kamp.WitnessCount` succeeds sorry-free
- [ ] Phase 2: `zone3_bracket_iff` and `zone3_temporal_correct` compile sorry-free
- [ ] Phase 2: `lean_verify` on key theorems confirms no sorryAx
- [ ] Phase 3: `zone3_exist_transfer` compiles sorry-free
- [ ] Phase 3: `first_occ_within_interval` verified using HasAttainedINF.first_occ_tp
- [ ] Phase 4: Both K=0 sorry sites eliminated
- [ ] Phase 4: `prior_nonconstenv_2var_agree_until` and `_since` compile sorry-free for all K
- [ ] Phase 4: `lean_verify` on both theorems confirms no sorryAx
- [ ] Phase 5: `completeness_discrete` compiles sorry-free (no sorryAx)
- [ ] Phase 5: Full `lake build` succeeds
- [ ] Phase 5: Final sorry audit confirms only dead-code sorrys remain in Kamp directory

## Artifacts & Outputs

- `specs/305_rabinovich_ea_formula_implementation/plans/19_witness-count-restructure-plan.md` -- this plan
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/WitnessCount.lean` (NEW) -- witness-count measure (~200-300 lines)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfToVecEA1.lean` (NEW) -- zone-3 NF-to-BracketFormula conversion + cross-structure transfer (~450-700 lines)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/PriorComposition.lean` -- K=0 sorry eliminated (Phase 4)

## Postmortem Constraints (from v9-v18 and 17 research rounds)

Previous plans failed for specific reasons that this plan MUST avoid:

1. **Do NOT attempt zone-3 witness placement within the NF framework** -- 17 research rounds and 5 implementation failures confirm this is irreducible. Every NF-level approach (cross_extend, exist_transfer_from_full_agree, nvar_transfer_from_1var_agree, char_fn + Prior-UZ/SZ, depth-1 NF-to-VecEA bridge) fails at zone 3.
2. **Do NOT modify existing sorry-free infrastructure** -- the VecEA files, NfToVecEA.lean, KampBypass.lean, EANegationClosure.lean, etc. are all sorry-free and must remain untouched.
3. **Do NOT target the dead-code sorrys** (lines 507, 555, 642, 647, 658 in PriorComposition.lean) -- they are in `nf_eval_from_lower_agree` and `zone_compatible_witness`, which become dead code once the K=0 sorry is resolved.
4. **The VecEA2 temporal transfer ALONE does not solve the problem** -- the transferred formula gives a witness relative to SOME x-type point z1', not necessarily x'. The plan v18 Phase 1 blocking confirms this.
5. **Use HasAttainedINF FIRST-OCCURRENCE MINIMALITY** as the key mechanism -- the first x-type point above t' is guaranteed <= x' (since x' is itself an x-type point above t'). This is why Rabinovich's approach works and the naive temporal transfer doesn't.
6. **Work through the BracketFormula/VecEA2 encoding** -- do not try to prove the zone-3 transfer directly at the NF level. The temporal formula level is where the transfer works.
7. **Additive-only changes** -- create new files (WitnessCount.lean, NfToVecEA1.lean), replace exactly 2 sorry sites in PriorComposition.lean (lines 869, 964), add 1 import. No other modifications to existing files.

## Rollback/Contingency

- **Phase 1** creates a new file. Rollback = delete `WitnessCount.lean`.
- **Phase 2** creates a new file. Rollback = delete `NfToVecEA1.lean`.
- **Phase 3** extends NfToVecEA1.lean. Rollback = revert to Phase 2 version.
- **Phase 4** modifies PriorComposition.lean (2 sorry sites + 1 import). Rollback = `git checkout -- PriorComposition.lean`.
- **Phase 5** is verification only -- no rollback needed.
- Git per-phase commits enable rollback to any intermediate state.
- **If the BracketFormula encoding at depth 0 is more complex than expected**: The depth-0 3-var NF is purely atomic, so BracketFormula with TemporalPred point types should capture it exactly. If not, the issue would be in the bracket-to-temporal translation (bracketBuildRight/Left), which is already sorry-free and tested.
- **If the first-occurrence argument (first_occ_within_interval) fails**: This would mean HasAttainedINF.first_occ_tp does not provide the guarantee that the first x-type point above t' is <= x'. But by definition of "first occurrence," if x' is an x-type point above t', the first one is <= x'. This argument is mathematically airtight.
- **If the temporal transfer at depth 2 exceeds char_correct's depth bound**: Fall back to a direct proof of temporal truth agreement for the specific zone-3 temporal formula, using the NF agreement hypotheses directly rather than through char_correct.
