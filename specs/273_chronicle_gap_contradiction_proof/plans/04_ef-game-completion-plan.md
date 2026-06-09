# Implementation Plan: EF Game Composition for Stavi Expressive Completeness (v4)

- **Task**: 273 - Fill the EF game sorry in StaviCompleteness.lean to make {U,S,U',S'} expressively complete
- **Status**: [NOT STARTED]
- **Effort**: 8 hours
- **Dependencies**: None (Phases 0-1 from v3 are completed)
- **Research Inputs**: specs/273_chronicle_gap_contradiction_proof/reports/03_team-research.md, literature/Gabbay_Hodkinson_Reynolds_1993_Temporal_expressive_completeness_gaps.md (GHR93 Section 8), literature/Gabbay_Hodkinson_Reynolds_1994_Temporal_Logic_Foundations_Vol1_ch9.md (GHR94 Ch 9)
- **Artifacts**: plans/04_ef-game-completion-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

This plan (v4) replaces v3's separation-bypass approach (which was blocked: the Z separation theorem cannot transfer to arbitrary Prior structures). Instead, we follow the literature directly by filling the sorry sites at `StaviCompleteness.lean:2353,2435`, which are the 4-variable existential transfer steps in the GHR93 EF game composition argument.

**Why this approach**: The sorry is in `nf_2var_existential_transfer`, which proves that existential quantification over a 3rd variable transfers between structures M and M' given 2-point matching conditions. The sorry occurs at depth j+1, where the atom transfer is proved but the quantifier step (transferring ∃w at 4 variables and depth j) is missing. This is the inductive heart of Duplicator's strategy in the EF game (GHR93 Proposition 7 + Lemma 11).

**Mathematical significance**: Filling this sorry proves GHR93 Theorem 9.3.1 ({U,S,U',S'} is expressively complete over ALL linear structures) in Lean 4 — a fundamental result in temporal logic whose full proof has never been formally verified. This is the mathematically proper approach per the literature.

### Prior Plan Reference

v3 (separation bypass) attempted to replace `stavi_expressive_completeness` with a direct separation-based proof. This was blocked because:
- The separation result (GHR94 Ch 10.2) is proved for Z-carrier structures only
- `eval` quantifies over M.carrier, and arbitrary Prior carriers may differ from Z
- The atom elimination step is proved only for IntStructureFromSig

v4 follows the natural proof structure: fill the EF game sorry → stavi_expressive_completeness becomes sorry-free → US_expressively_complete_over_prior becomes sorry-free → completeness_discrete sorry chain (Chain A) is eliminated.

### Existing Infrastructure

The EF game infrastructure is substantial (~14,500 lines across 9 files):
- `Defs.lean`: EF game definitions, ExtendedCarrier, decomposition formulas
- `CustomGame.lean` (1703 lines): Custom GHR93 game with gap support
- `Composition.lean` (626 lines): `ghr93_strategy_compose` — GHR93 Proposition 7
- `NFGameBridge.lean` (1237 lines): Bridge between NF framework and game framework
- `CharacteristicFormula.lean` (666 lines): Characteristic formula construction
- `GapDetection.lean` (5057 lines): Gap detection and definable gap machinery
- `TypeFormulas.lean` (1068 lines): Type formula infrastructure
- `Decomposition.lean` (315 lines): Decomposition formula infrastructure
- `StaviCompleteness.lean` (3270 lines): Main theorem with sorry sites

Key existing lemmas:
- `zone_match_witness` (line 2044): Given 2-point matching, find a zone-matched partner for a 3rd point
- `nf_fraisse_compression` (used at line 2518): Atoms + existential transfer at each depth j < k → NF equality
- `nf_agreement_from_shared_nf`: Shared NF → atom-level agreement
- `ghr93_strategy_compose` (Composition.lean): Duplicator strategy composes from sub-interval strategies

### Literature Reference

The sorry corresponds to GHR93 Section 8, proof of Theorem 6 (the main game-theoretic step):
- (**)_n: For all r, if Duplicator wins G_{1+3n; r+4n}(M, xy; N, x'y'), then Duplicator wins G_{n;r}(N, x'y'; M, xy)
- The proof is by induction on n (game rounds), with Cases I-IV handling different configurations

In the NF formalization, this becomes: to prove existential transfer at n+1 variables and depth j+1, zone-match the new variable, establish atoms at n+1 variables, then use the induction hypothesis for the quantifier step at n+2 variables and depth j. The termination is guaranteed by decreasing depth.

## Goals & Non-Goals

**Goals**:
- Fill the sorry at `StaviCompleteness.lean:2353` (forward 4-var existential transfer)
- Fill the sorry at `StaviCompleteness.lean:2435` (backward 4-var existential transfer)
- Make `stavi_expressive_completeness` sorry-free
- Thereby make `US_expressively_complete_over_prior` sorry-free (Chain A eliminated)
- Verify via `#print axioms completeness_discrete` that sorryAx is removed from Chain A

**Non-Goals**:
- Fixing `chronicle_gap_contradiction` (Chain B, separate concern)
- Modifying `PriorExpressiveness.lean` or downstream consumers
- Refactoring the existing EF game infrastructure
- Proving completeness_dense sorry-free

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| The general n-variable existential transfer requires more infrastructure than expected | H | M | Start with the minimal approach: prove the 4-var case directly using zone_match for 3-point configurations, rather than a fully general n-variable theorem. The depth induction terminates at j=0 regardless. |
| Zone matching for 3-point configurations needs sub-interval type data that isn't available from 2-point matching alone | H | L | Zone matching only needs 1-var NF types, orderings, and interval types. For the 3-point case, the sub-intervals of (u,x,t) are determined by the zone of u relative to (x,t). The existing zone_match_witness already provides the correct zone data. |
| The induction structure doesn't terminate because variable count grows at each step | L | L | Variable count grows but depth strictly decreases. At depth 0, only atoms matter and no quantifier transfer is needed. The well-founded induction on depth guarantees termination. |
| `nf_fraisse_compression` at higher variable counts requires additional infrastructure | M | M | Check if `nf_fraisse_compression` is parametric in variable count. If not, generalize it. |
| Build time exceeds heartbeat timeout for the large StaviCompleteness.lean file | M | H | Keep the general lemma in a separate file (e.g., GeneralExistentialTransfer.lean) and import it. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 2 | -- |
| 2 | 3 | 2 |
| 3 | 4 | 3 |

Phase 0 (axiom audit) and Phase 1 (SemanticBridge) from v3 are already [COMPLETED].

---

### Phase 0: Axiom Audit and Sorry State Verification [COMPLETED]

(From v3 plan — already completed.)

---

### Phase 1: SemanticBridge Infrastructure [COMPLETED]

(From v3 plan — already completed.)

---

### Phase 2: General Existential Transfer Theorem [BLOCKED]

**Goal**: Prove a general existential transfer theorem that handles the inductive step of the EF game composition. This is the core mathematical contribution: when two n-point configurations match (same 1-var NFs, orderings, interval types), existential quantification over an (n+1)-th variable transfers at any depth j < k.

**Mathematical approach (following GHR93 Proposition 7)**:
The proof is by strong induction on depth j:
- **Base case (j = 0)**: At depth 0, nf_eval is determined by atoms alone. Zone-match the new variable u to u', verify atom agreement at n+1 variables, done.
- **Inductive case (j = j' + 1)**: At depth j'+1, nf_eval consists of atoms + existential quantifier at depth j'. Atoms transfer by zone matching + NF agreement (same as depth 0). For the quantifier: need to show ∃w at depth j' and n+2 variables transfers. Zone-match w to w', establishing (n+1)-point matching for the extended configuration. Apply the induction hypothesis at depth j' (which is < j'+1).

The key insight: each inductive step increases variable count by 1 but decreases depth by 1. Since depth starts at j < k and decreases, the recursion terminates at depth 0 after at most j steps, using at most n+j variables.

**Tasks**:
- [x] Study `nf_fraisse_compression` to confirm it's parametric in variable count n, or generalize it *(completed: nf_fraisse_compression IS parametric in n and k, confirmed at line 2006)*
- [x] Study `zone_match_witness` to understand what matching conditions it provides and whether the output is sufficient for constructing matching conditions for the extended (n+1)-point configuration *(deviation: altered — analysis showed zone_match_witness is INSUFFICIENT: it provides orderings relative to the outermost pair only, not relative to inner matched points; sub-interval type splitting is not guaranteed)*
- [ ] Prove helper: given n-point matching conditions + zone-matched u/u', derive the (n+1)-point matching conditions (sub-interval types for the extended configuration) *(deviation: blocked — requires interval-splitting zone match which is not always possible for arbitrary linear orders; see BLOCKER)*
- [ ] Prove `nf_general_existential_transfer`: the general existential transfer theorem by induction on depth j, parameterized by variable count n. This is the formal version of GHR93's game invariant maintenance *(deviation: blocked — depends on interval-splitting helper)*
- [ ] Verify the theorem compiles and has the right type to plug into the sorry sites *(deviation: blocked — depends on general transfer theorem)*

**BLOCKER** (Phase 2):
- **What failed**: The sorry at `StaviCompleteness.lean:2353,2435` asks for 4-variable existential transfer at depth `j'` given 3-point matching for `(u,x,t)/(u',x',t')`. The existing `zone_match_witness` (line 2044) finds `u'` with the same depth-k 1-var NF and correct orderings relative to `x'` and `t'`, but does NOT guarantee: (a) correct orderings relative to ALL inner points when zone-matching subsequent variables, or (b) consistent interval-type splitting for sub-intervals `(x,u)/(x',u')` and `(u,t)/(u',t')`.
- **What was tried**:
  1. **Direct zone matching + strong induction on j**: Zone-match the new 4th variable `w` to `w'` relative to `(x,t)/(x',t')`. This gives `w'` in the correct broad zone (below-min, above-max, or in-interval relative to `(x',t')`), but when `w` and `u` are BOTH in the interval `(x,t)`, the ordering of `w'` relative to `u'` is NOT guaranteed by zone matching relative to `(x,t)`. Specifically: if `x < w < u < t` in M, zone matching gives `w'` in `(x', t')` but `w'` could be in `(u', t')` instead of `(x', u')`.
  2. **Using the outer theorem's IH at lower depth**: Strong induction on `j` gives existential transfer at depths `< j` for 3-var extensions. The IH at depth `j'` gives `u''` with the same depth-`j'` 3-var NF as `(u,x,t)`. But this `u''` might differ from the zone-matched `u'`, and the depth-`j'` 3-var NF does not encode depth-`j'` quantifier data (only depth-`(j'-1)` quantifier data). So the 4-var transfer at depth `j'` does not follow from 3-var NF matching at depth `j'`.
  3. **Using `nf_fraisse_compression` for the 3-point config**: Applying `nf_fraisse_compression` at depth `j'+1` for 3 vars needs existential transfer at ALL depths `< j'+1` for 4-var extensions — which is exactly the sorry goal. Circular.
  4. **Deriving sub-interval types from endpoint NFs**: The depth-k 1-var NF of `u` encodes which depth-(k-1) 2-var NFs `(v,u)` are realized, but this includes ALL `v < u` (not just those in `(x,u)`). The NF of `x` similarly includes ALL `v > x`. The intersection cannot cleanly determine `interval_nf_types M (k-1) x u`.
  5. **Counterexample analysis**: Constructed a concrete counterexample showing interval-splitting is NOT always possible: M with `x < a(A) < u(B) < c(C) < t` and M' with `x' < b'(B) < c'(C) < a'(A) < t'`. Both have `interval_nf_types = {A,B,C}`, but no choice of `u'(B)` in `(x', t')` gives `interval_nf_types(x', u') = {A}`.
- **Why it's stuck**: The mathematical gap is between "same interval type SET" and "same interval type ARRANGEMENT". The GHR93 game argument (Proposition 7) handles this through a multi-round game strategy with decomposition formulas, where Duplicator places MULTIPLE points to preserve sub-interval structure. The current NF framework's single-step zone matching cannot achieve this. The counterexample confirms the gap is genuine for arbitrary linear orders at depth k.
- **What is needed**: One of the following approaches (ordered by estimated feasibility):
  1. **(Preferred) Game-based interval splitting**: Prove that when the outer game has enough rounds (depth k), the Duplicator CAN choose `u'` to split interval types correctly by using the 2-var depth-k NF equality implicitly. This corresponds to GHR93 Proposition 7's strategy where witnesses for ALL decomposition formulas are placed simultaneously. Estimated ~300-500 lines of new infrastructure defining game positions, strategies, and invariant maintenance.
  2. **Direct induction on (k - j) with decreasing interval data**: Use the fact that at each recursive step, the depth decreases by 1, and derive sub-interval types at depth `k-1` from the matched points' depth-k data. The key lemma: the depth-k 2-var NF of `(x, t)` (once proved equal) implies enough about depth-(k-1) sub-interval structure. But this creates a circular dependency (the 2-var NF equality depends on the sorry).
  3. **Bypass the bridge lemma entirely**: Find an alternative proof of `stavi_expressive_completeness` that does not go through `nf_2var_from_interval_data`. This would require a fundamentally different proof architecture.
- **Prohibited workarounds**: Do NOT use `sorry`, `def X := True`, or any vacuous placeholder.

**Timing**: 4 hours (original), blocked after ~3 hours of analysis

**Depends on**: Phases 0, 1 (completed)

**Files to modify**:
- New file: `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/GeneralExistentialTransfer.lean`

**Verification**:
- New file compiles with `lake build Bimodal.Metalogic.WeakCanonical.EFGames.GeneralExistentialTransfer`
- No sorry in the new file
- The theorem type signature matches what the sorry sites need

---

### Phase 3: Fill Sorry Sites in StaviCompleteness.lean [NOT STARTED]

**Goal**: Replace the sorry at lines 2353 and 2435 with calls to the general existential transfer theorem from Phase 2. Then verify the full sorry chain is eliminated.

**Tasks**:
- [ ] Import GeneralExistentialTransfer.lean in StaviCompleteness.lean
- [ ] At line 2353 (forward direction, depth j'+1): construct the 3-point matching conditions for (u,x,t)/(u',x',t') from the existing zone_match output and apply `nf_general_existential_transfer`
- [ ] At line 2435 (backward direction, depth j'+1): symmetric case, construct matching conditions for (u',x',t')/(u,x,t) and apply the transfer theorem
- [ ] Verify `lake build Bimodal.Metalogic.WeakCanonical.EFGames.StaviCompleteness` succeeds with no sorry
- [ ] Run `lean_verify` on `stavi_expressive_completeness` to confirm no sorryAx
- [ ] Run `lean_verify` on `US_expressively_complete_over_prior` to confirm no sorryAx

**Timing**: 2 hours

**Depends on**: Phase 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/StaviCompleteness.lean` — replace sorry at lines 2353, 2435

**Verification**:
- `lake build Bimodal.Metalogic.WeakCanonical.EFGames.StaviCompleteness` succeeds
- `#print axioms stavi_expressive_completeness` shows no sorryAx
- `#print axioms US_expressively_complete_over_prior` shows no sorryAx
- `#print axioms gap_prior_UZ_contradiction` shows no sorryAx

---

### Phase 4: Full Build Verification and Axiom Audit [NOT STARTED]

**Goal**: Run full project build, verify `completeness_discrete` sorry state, and confirm Chain A is eliminated end-to-end.

**Tasks**:
- [ ] Run `lake build` for the full project
- [ ] Run `#print axioms completeness_discrete` and compare against Phase 0 baseline:
  - If `sorryAx` is gone: Chain A is fully eliminated, task is complete
  - If `sorryAx` remains: identify which chain (should be Chain B via `chronicle_gap_contradiction`)
- [ ] Verify the full Chain A sorry chain is eliminated:
  - `stavi_expressive_completeness` — sorry-free
  - `US_expressively_complete_over_prior` — sorry-free
  - `gap_prior_UZ_contradiction` — sorry-free
  - `gap_prior_SZ_contradiction` — sorry-free
  - `no_gaps_discrete_model_surgery` — sorry-free
  - `limitdom_is_good` — sorry-free
  - `countermodel_discrete_reynolds_v2` — sorry-free (from Chain A perspective)
- [ ] Verify no new `sorry` introduced: `grep -rn "sorry" Theories/Bimodal/Metalogic/WeakCanonical/EFGames/ --include="*.lean"` shows no results (excluding comments)
- [ ] Run existing tests: `lake build BimodalTest`

**Timing**: 1 hour

**Depends on**: Phase 3

**Files to modify**:
- None (verification only)

**Verification**:
- `lake build` succeeds for the full project
- `#print axioms completeness_discrete` result documented
- `grep` finds no unexpected sorry in EFGames/ directory
- Existing tests pass

## Testing & Validation

- [ ] `lake build` completes without errors for the full project
- [ ] `#print axioms Bimodal.Metalogic.WeakCanonical.stavi_expressive_completeness` does not include `sorryAx`
- [ ] `#print axioms Bimodal.Metalogic.WeakCanonical.US_expressively_complete_over_prior` does not include `sorryAx`
- [ ] `#print axioms Bimodal.Metalogic.WeakCanonical.IntegerModel.gap_prior_UZ_contradiction` does not include `sorryAx`
- [ ] `#print axioms Bimodal.Metalogic.BXCanonical.completeness_discrete` — either no `sorryAx` or only through Chain B (documented)
- [ ] `GoodStructuresModelSurgery.lean` compiles without changes
- [ ] No new `sorry` introduced in `EFGames/` directory
- [ ] No import cycles (verified by successful `lake build`)
- [ ] Existing `Tests/BimodalTest/` tests pass

## Artifacts & Outputs

- `specs/273_chronicle_gap_contradiction_proof/plans/04_ef-game-completion-plan.md` (this file, v4)
- Existing (Phase 0 complete): Axiom audit results
- Existing (Phase 1 complete): `Theories/Bimodal/Metalogic/WeakCanonical/Separation/SemanticBridge.lean`
- New (Phase 2): `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/GeneralExistentialTransfer.lean`
- Modified (Phase 3): `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/StaviCompleteness.lean`
- `specs/273_chronicle_gap_contradiction_proof/summaries/04_ef-game-completion-summary.md`

## Rollback/Contingency

- If the general n-variable transfer proves too complex: implement a FIXED 4-variable transfer (hardcoded for n=3) and a separate 5-variable transfer (hardcoded for n=4), etc. up to the required depth. This is less elegant but avoids the parametric generalization. Since k is finite for any given formula, this terminates.
- If the depth induction doesn't work cleanly in Lean's termination checker: use `Nat.strongRecOn` or `WellFoundedRelation` explicitly.
- If build time exceeds heartbeat: split GeneralExistentialTransfer.lean into sub-modules.
- Git revert to the commit before implementation if any phase introduces regressions.
