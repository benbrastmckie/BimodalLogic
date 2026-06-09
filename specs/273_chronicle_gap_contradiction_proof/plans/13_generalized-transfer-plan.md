# Implementation Plan: Generalized Existential Transfer via 2-var Interval Types (v13)

- **Task**: 273 - Eliminate sorryAx from `completeness_discrete` via generalized NF transfer
- **Status**: [NOT STARTED]
- **Effort**: 8-12 hours
- **Dependencies**: None
- **Research Inputs**:
  - specs/273_chronicle_gap_contradiction_proof/reports/07_sorry-chain-verification.md
  - specs/273_chronicle_gap_contradiction_proof/reports/08_game-pipeline-research.md
  - specs/273_chronicle_gap_contradiction_proof/plans/11_discrete-backward-plan.md (BLOCKED -- IsSuccArchimedean circularity)
  - specs/273_chronicle_gap_contradiction_proof/plans/12_generalized-transfer-plan.md (BLOCKED -- interval splitting)
  - specs/273_chronicle_gap_contradiction_proof/handoffs/phase-1-handoff-20260609.md (blocker analysis)
  - literature/Gabbay_Hodkinson_Reynolds_1993_Temporal_expressive_completeness_gaps.md (Section 8, Proposition 7, Lemma 11)
  - literature/Gabbay_Hodkinson_Reynolds_1994_Temporal_Logic_Foundations_Vol1_ch12.md (Proposition 12.8.18, Lemma 12.8.14)
- **Artifacts**: plans/13_generalized-transfer-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Plan v12 is BLOCKED at Phase 1 because zone matching with 1-var interval types
(`interval_nf_types`) is insufficient. When extending a matched configuration by
adding zone-matched points, orderings between independently zone-matched points
in the same interval zone are not determined by 1-var types alone. This is the
"interval splitting" problem.

This plan (v13) resolves the blocker by switching from 1-var to 2-var interval
types, following the approach used in GHR93 Proposition 7 / GHR94 Proposition
12.8.18. The key insight from the literature is that decomposition formula
matching (Lemma 12.8.14 / Lemma 11) automatically provides sub-interval game
strategies. In NF terms, the 2-var NF of (u, endpoint) encodes both the 1-var
type of u AND its quantifier-level relationship to the endpoint, which is
exactly the decomposition formula content. The 2-var interval type matching
therefore provides the sub-interval data needed for the inductive step.

### What Failed in v12 Phase 1

Plan v12 defined `matching_data` using `interval_nf_types` (1-var) and relied
on `zone_match_witness` which produces u' with matching 1-var NF and orderings
relative to the original reference pair (x, t). The blocker occurs at Task 1.3
(`zone_match_extends_matching_data`): when adding a zone-matched point w/w' to
an n-point configuration, the sub-interval types for the new sub-intervals
(env(i), w) / (env'(i), w') cannot be derived from the containing interval's
1-var types. Four approaches were tried and all failed -- see the Phase 1
handoff for details.

### How the Literature Solves This (GHR93 Proposition 7)

GHR93 Proposition 7 / GHR94 Proposition 12.8.18 proceeds by induction on game
rounds (n in their notation, j in ours). When Spoiler places a new point `a` in
interval `(x_i, x_{i+1})`, Duplicator:

1. Lists all decomposition formulas (Def 12.8.13/8.8) satisfied by `(x_i, a)`
   and `(a, x_{i+1})`. A decomposition formula for interval `(x_i, a)` specifies
   the types of finitely many interior points and constraints on all points
   between consecutive ones. This is precisely the 2-var NF content.
2. Uses the interval game strategy for `G_{f(n+1),r}(M, x_i x_{i+1}; N, y_i y_{i+1})`
   to find the matching point `e`.
3. By Lemma 12.8.14 (decomposition formula = game equivalence), the response `e`
   automatically satisfies the SAME decomposition formulas. This gives sub-interval
   game strategies for `(x_i, a)/(y_i, e)` and `(a, x_{i+1})/(e, y_{i+1})`.
4. The induction hypothesis then extends from the original m-tuple to the
   (m+1)-tuple `(x bar, a)` / `(y bar, e)`.

In NF terms: the decomposition formula for `(x_i, a)` IS the 2-var NF of
`(a, x_i)` at the appropriate depth. Matching decomposition formulas =
matching `interval_2var_nf_types`. The sub-interval game strategy = existential
transfer at lower depth for the sub-interval.

### This Plan's Approach

**Approach A (Strengthen hypotheses)**: Rewrite `nf_2var_existential_transfer`
to use `interval_2var_nf_types` instead of `interval_nf_types`. The 2-var
interval type of point u relative to endpoint b encodes:
- u's 1-var type (extractable from the 2-var NF)
- u's quantifier-level relationship to b (the sub-interval game strategy)

When zone-matching finds u' with the same 2-var NF relative to b', the
sub-interval data is automatically available. No separate
`zone_match_extends_matching_data` lemma is needed -- the 2-var NF agreement
at (u, b) / (u', b') directly gives the existential transfer for the sub-interval
via the quant component of the 2-var NF.

The caller chain must be verified: `nf_2var_from_interval_data` passes interval
hypotheses to `nf_2var_existential_transfer`, and its callers
(`nf_exist_sf_guarded_backward` at line 2805) must be able to supply
`interval_2var_nf_types` data. Since the backward direction extracts interval
data from temporal formulas via `char_k_correct`, and `char_k_correct`
characterizes 1-var NFs, the 2-var interval types need to be derived. This
derivation is the content of Phase 1.

### Research Integration

Reports integrated:
- `07_sorry-chain-verification.md`: Confirmed single sorry chain, root at
  `nf_exist_sf_guarded_backward` (StaviCompleteness.lean:2805)
- `08_game-pipeline-research.md`: Verified game pipeline components sorry-free
  for discrete case; identified arity escalation as core obstacle
- Plan v11 blocker analysis: Confirmed IsSuccArchimedean circularity is fatal
- Plan v12 Phase 1 handoff: Confirmed 1-var interval types insufficient;
  identified `interval_2var_nf_types` (line 1847) as the resolution
- Blocker research: Identified concrete resolution path using 2-var interval types

## Goals & Non-Goals

**Goals**:
- Prove `nf_2var_existential_transfer` (StaviCompleteness.lean:2353, 2435)
- Make `stavi_expressive_completeness` sorry-free
- Make `US_expressively_complete_over_prior` sorry-free
- Achieve sorry-free `completeness_discrete` end-to-end
- Work for ALL linear orders (no IsSuccArchimedean requirement)
- Follow GHR93 Proposition 7 proof structure faithfully

**Non-Goals**:
- Filling dead-code sorry sites in DiscreteStaviCompleteness.lean
- Implementing the full EF game framework separately (decomposition formulas
  are encoded as 2-var NFs, not as a separate game layer)
- Proving Cases III/IV of general Theorem 6 (CaseAnalysis.lean)
- Modifying the Reynolds model surgery pipeline
- Generalizing to arbitrary arity n (the sorry only requires arity 2, which
  recurses to arity 3 then bottoms out; we work at fixed arities)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `interval_2var_nf_types` matching cannot be derived from the caller's available data | H | M | Phase 1 investigates this derivability first. If `nf_exist_sf_guarded_backward` cannot supply 2-var interval data, fall back to Approach B (new theorem + corollary). The caller extracts interval info from temporal formulas -- the question is whether the guarded formula encodes enough structure. |
| `zone_match_witness_2var` (finding u' with matching 2-var NF relative to endpoint) is harder than 1-var zone matching | M | L | The existing `zone_match_witness` already handles 5-zone case analysis. The 2-var version uses the same zone analysis but matches against `interval_2var_nf_types` instead of `interval_nf_types`. The zone structure is identical; only the matching criterion is richer. |
| Sub-interval extraction from 2-var NF quant component requires non-trivial NF structural lemma | M | M | The quant component of nf_characteristic at depth k+1 directly encodes existential transfer at depth k. This is the definition of NormalForm.2 (the quant field). A lemma `interval_2var_nf_types_sub_interval` extracts this. Literature antecedent: GHR93 Lemma 11 direction (1) => (2). |
| Lean type-checking performance with 2-var NFs and Finset operations | L | M | Keep definitions noncomputable. Avoid unfolding Finset.filter in proofs -- work with membership lemmas instead. |
| Induction structure (on j or k) needs careful setup for termination checking | M | L | Follow GHR93: induction on n (game rounds = depth j in our terms). Each step decreases j by 1, arity increases but is unbounded. Use Nat.strongRecOn on j. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |

Phases within the same wave can execute in parallel.

---

### Phase 1: 2-var Zone Matching and Interval Type Infrastructure [BLOCKED]

**Goal**: Build the infrastructure for zone matching with 2-var interval types.
Define `zone_match_witness_2var` that finds u' with matching 2-var NF relative
to the interval endpoint, and prove the key structural lemma that 2-var NF
agreement provides sub-interval existential transfer.

**Literature basis**: GHR93 Proposition 7 step (1)-(3), Lemma 11. The
decomposition formula matching in Lemma 11/12.8.14 is equivalent to 2-var NF
matching. The sub-interval game strategy extraction is Lemma 11 direction
(1) => (2).

**Tasks**:
- [ ] **Task 1.1**: Define `interval_2var_nf_types_eq` predicate -- a convenience
  wrapper asserting that two intervals have the same 2-var NF type sets:
  `interval_2var_nf_types M k lo hi = interval_2var_nf_types M' k lo' hi'`.
  Also prove that `interval_2var_nf_types` matching implies `interval_nf_types`
  matching (the 1-var NF is extractable from the 2-var NF via projection).
  This is the "stronger implies weaker" direction.
  - **File**: `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/StaviCompleteness.lean`
  - **Location**: Near the existing `interval_2var_nf_types` definition (line 1847)
  - **Estimated size**: 30-50 lines
  - **Literature ref**: GHR93 Def 8.8 (X_t and X_{(t,u)} define decomposition content)

- [ ] **Task 1.2**: Prove `zone_match_witness_2var` -- given a point `u` in
  interval `(lo, hi)` of M, and `interval_2var_nf_types` agreement between
  `(lo, hi)` and `(lo', hi')`, find `u'` in `(lo', hi')` with:
  (a) `nf_characteristic M k 2 (Fin.cons u (fun _ => hi)) = nf_characteristic M' k 2 (Fin.cons u' (fun _ => hi'))` (2-var NF match relative to upper endpoint)
  (b) `lo < u iff lo' < u'` and `u < hi iff u' < hi'` (orderings preserved)
  - **Approach**: Filter `interval_2var_nf_types M' k lo' hi'` for the 2-var NF
    of u relative to hi. The 2-var NF type set equality guarantees existence.
    Extract the witness from the Finset membership proof.
  - **File**: `StaviCompleteness.lean` (near existing `zone_match_witness`)
  - **Estimated size**: 60-100 lines
  - **Literature ref**: GHR93 Prop 7 -- Duplicator applies interval strategy to find e

- [ ] **Task 1.3**: Prove `nf_2var_sub_interval_transfer` -- the key structural
  lemma. Given 2-var NF equality at `(u, hi)/(u', hi')` at depth k, extract
  existential transfer at depth j < k for extensions of `(u, hi)/(u', hi')`.
  Specifically:
  `nf_characteristic M k 2 (u, hi) = nf_characteristic M' k 2 (u', hi')` implies
  for all j < k, for all chi : NormalForm sig j 3,
  `(exists w, nf_eval_nf M j 3 (w::u::hi) chi) iff (exists w', nf_eval_nf M' j 3 (w'::u'::hi') chi)`.
  - **Approach**: The 2-var NF at depth k+1 has a quant component that encodes
    exactly this existential transfer at depth k. At depth k, the quant
    component gives transfer at depth k-1. By the NF structure
    (`nf_characteristic_satisfies`), the quant field stores whether each
    depth-j (n+1)-var NF is realizable. The 2-var NF equality at depth k
    gives transfer at depth j for all j < k.
  - **File**: `StaviCompleteness.lean`
  - **Estimated size**: 40-80 lines
  - **Literature ref**: GHR93 Lemma 11 (decomposition formula => game strategy)

- [ ] **Task 1.4**: Prove `nf_2var_sub_interval_types` -- given 2-var NF
  equality at `(u, hi)/(u', hi')` at depth k, the sub-interval 2-var types
  between u and hi agree:
  `interval_2var_nf_types M k' u hi = interval_2var_nf_types M' k' u' hi'`
  for appropriate k' (derived from the 2-var NF agreement).
  This connects the zone matching witness (Task 1.2) to the sub-interval
  structure needed for the inductive step.
  - **Approach**: The 2-var NF at (u, hi) encodes which 2-var NFs are realized
    in the interval (u, hi). By equality, the same set is realized in (u', hi').
    This is a direct consequence of the quant component structure.
  - **File**: `StaviCompleteness.lean`
  - **Estimated size**: 40-80 lines
  - **Literature ref**: GHR93 Prop 7 step (3) -- sub-interval decomposition
    formula matching follows from the response point's decomposition match

**BLOCKER** (Phase 1):
- **What failed**: The plan v13 approach of replacing `interval_nf_types` with `interval_2var_nf_types` in the hypotheses is necessary but insufficient. The core sorry at lines 2353/2435 requires 4-var existential transfer at depth j' for the 3-point config (u,x,t)/(u',x',t'). This requires proving matching at HIGHER arities (4, 5, ..., up to 3+j'), because each quantifier level adds one more variable.
- **What was tried**: Extensive analysis of approaches:
  1. **Strengthening hypotheses only** (plan v13 as written): Changing `interval_nf_types` to `interval_2var_nf_types` gives zone matching with 2-var NF agreement, but the quant component of the 3-var NF at (u,x,t) requires 4-var transfer, which requires zone matching at the 3-point config and then 5-var transfer, etc.
  2. **Induction on j (depth) at fixed arity**: The IH gives 3-var transfer at depth < j, but the quant step needs 4-var transfer, which the 3-var IH doesn't provide.
  3. **Deriving sub-interval data from 2-var NFs**: The 2-var NF of (u,x) at depth k gives 3-var transfer at depth k-1 for extensions of (u,x), but NOT 4-var transfer for (u,x,t). And sub-interval interval_nf_types at depth k can't be derived from the 2-var NF at depth k (only at depth k-1).
  4. **Composing pairwise 3-var transfers**: The three pairwise 3-var transfers (for (u,x), (x,t), (u,t)) don't compose to give 4-var transfer for (u,x,t), because the 4-var NF encodes entangled quantifier data.
  5. **Arity-parametric induction** (correct approach per GHR93): Induction on j universally over n (arity), with matching data at depth k that decreases by 1 at each step. Zone matching in the (n+1)-config requires sub-interval data, which comes from the 2-var NF of (w, endpoint) via depth decrease.
- **Why it's stuck**: The arity-parametric approach is correct in principle (it's what GHR93 Proposition 7 does), but formalization in Lean requires:
  (a) A theorem parametric in both depth j AND arity n, with matching data at depth K ≥ j.
  (b) Zone matching that produces sub-interval data for the extended config. This requires deriving `interval_nf_types` at depth K-1 from the 2-var NF at depth K.
  (c) The derivation of sub-interval types at depth K-1 needs a projection lemma: from the 3-var NF of (v, a, b) at depth K-1, extract the 1-var NF of v at depth K-1. This projection is NOT straightforward because 3-var and 1-var NFs encode different quantifier data.
  The actual implementation requires ~300-500 lines of infrastructure for the arity-parametric zone matching and the matching data propagation through the induction.
- **What is needed**: A plan v14 that implements the full arity-parametric induction following GHR93 Proposition 7 exactly. Specifically:
  1. Define a "matched configuration" predicate parametric in n (arity) and K (data depth).
  2. Prove zone matching preserves matching at arity n+1 and data depth K-1.
  3. Prove the existential transfer by Nat.strongRecOn on j, universally over n.
  4. Derive `nf_2var_existential_transfer` and `nf_2var_from_interval_data` as corollaries.
- **Prohibited workarounds**: Do NOT use `sorry`, `def X := True`, or any vacuous placeholder.

**Timing**: 3-4 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/StaviCompleteness.lean`

**Verification**:
- `lean_goal` confirms all new definitions are well-typed
- `lean_verify zone_match_witness_2var` -- no sorryAx
- `lean_verify nf_2var_sub_interval_transfer` -- no sorryAx
- `lean_verify nf_2var_sub_interval_types` -- no sorryAx

---

### Phase 2: Prove Existential Transfer with 2-var Interval Hypotheses [NOT STARTED]

**Goal**: Prove `nf_2var_existential_transfer` by rewriting it to use
`interval_2var_nf_types` hypotheses, following GHR93 Proposition 7's induction
on game rounds.

**Literature basis**: GHR93 Proposition 7, induction on n. At round n+1:
(1) Duplicator finds e matching a's decomposition formulas for both sub-intervals,
(2) by IH at round n, Duplicator wins the extended game. In NF terms: at depth
j+1, zone-match u to u' with 2-var NF agreement, extract sub-interval transfer
from the 2-var NF, apply IH at depth j.

**Decision: Approach A vs B**: This plan uses **Approach B** (new theorem +
corollary) to avoid changing the signature of `nf_2var_existential_transfer`
and risking breakage in the caller chain. We add a new theorem
`nf_2var_existential_transfer_strong` with 2-var interval hypotheses, prove it
by induction on j, then derive the original `nf_2var_existential_transfer` as
a corollary. The corollary derivation requires showing that 1-var interval type
agreement at depth k implies 2-var interval type agreement at depth k -- this
is NOT generally true, but `nf_2var_from_interval_data` provides additional
structure (the `nf_fraisse_compression` call) that bridges the gap. If this
corollary derivation is infeasible, fall back to Approach A (change the
signature and propagate).

**Revised decision**: On closer analysis, the corollary approach is problematic
because 1-var interval types do NOT determine 2-var interval types (that is
precisely the v12 blocker). Instead, use **Approach A directly**: replace
`interval_nf_types` with `interval_2var_nf_types` in `nf_2var_existential_transfer`
and `nf_2var_from_interval_data`. Propagate the change to callers in Phase 3.

**Tasks**:
- [ ] **Task 2.1**: Modify `nf_2var_existential_transfer` signature -- replace
  `h_interval_above` and `h_interval_below` hypotheses from `interval_nf_types`
  to `interval_2var_nf_types`:
  ```
  (h_interval_above : t < x →
    interval_2var_nf_types M k t x = interval_2var_nf_types M' k t' x')
  (h_interval_below : x < t →
    interval_2var_nf_types M k x t = interval_2var_nf_types M' k x' t')
  ```
  - **File**: `StaviCompleteness.lean` (modify at line ~2228)
  - **Estimated size**: 10 lines changed

- [ ] **Task 2.2**: Prove `nf_2var_existential_transfer` with the strengthened
  hypotheses. The proof follows GHR93 Proposition 7:
  - **Base case j = 0**: Zone-match u to u' using `zone_match_witness_2var`
    (from Phase 1). At depth 0, only atoms matter. Atom agreement follows from
    2-var NF agreement (which subsumes 1-var NF agreement). The iff holds.
  - **Inductive step j = j'+1**: Zone-match u to u' with 2-var NF agreement.
    Apply `nf_fraisse_compression` at arity 3. Need:
    - `h_atoms` at arity 3: from 2-var NF agreement (predicates) + ordering
      preservation (from zone matching). Same as v12's existing atom agreement code.
    - `h_transfer` at arity 4 for depth j' < j'+1: The 2-var NF agreement at
      (u, t)/(u', t') gives existential transfer at depth j' for extensions of
      this pair (by Task 1.3). For extensions of (u, x)/(u', x'), use the
      2-var NF agreement at (u, x) derived from sub-interval types (Task 1.4).
      Apply IH at depth j' with the sub-interval 2-var type data.
  - **File**: `StaviCompleteness.lean` (replace sorry at lines 2353, 2435)
  - **Estimated size**: 100-200 lines
  - **Literature ref**: GHR93 Prop 7 induction step

- [ ] **Task 2.3**: Modify `nf_2var_from_interval_data` signature to use
  `interval_2var_nf_types` and verify its proof still works. The proof body
  calls `nf_fraisse_compression` with `nf_2var_existential_transfer` -- since
  we changed the latter's signature, the hypotheses passed must be updated.
  - **File**: `StaviCompleteness.lean` (modify at line ~2462)
  - **Estimated size**: 20-40 lines changed

**Timing**: 3-4 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/StaviCompleteness.lean`

**Verification**:
- `lean_verify nf_2var_existential_transfer` -- no sorryAx
- `lean_verify nf_2var_from_interval_data` -- no sorryAx
- `lean_goal` at former sorry sites (lines 2353, 2435) shows no remaining goals

---

### Phase 3: Propagate 2-var Interval Types to Callers [NOT STARTED]

**Goal**: Update `nf_exist_sf_guarded_backward` and its callers to supply
`interval_2var_nf_types` data instead of `interval_nf_types` data. Verify the
full Stavi completeness chain is sorry-free.

**Literature basis**: GHR93 Section 8 -- the temporal formulas (U, S) encode
interval structure. The guarded formula construction (`nf_exist_sf_guarded`)
already encodes interval types via `interval_guard_sf`. The question is whether
the guard encodes enough to reconstruct 2-var interval types. If yes, the
backward direction proof goes through. If no, the guard construction itself
needs strengthening.

**Tasks**:
- [ ] **Task 3.1**: Analyze `nf_exist_sf_guarded` and `interval_guard_sf` to
  determine whether the guarded formula encodes 2-var interval types.
  - Read the guard construction and its forward/backward proofs
  - Determine if `char_k_correct` (which characterizes 1-var NFs) combined
    with the temporal formula structure provides 2-var interval type data
  - If the guard only encodes 1-var types: need to strengthen it to encode
    2-var types (add sub-interval existential transfer to the guard)
  - **File**: `StaviCompleteness.lean` (read lines ~2550-2800)
  - **Estimated size**: Analysis only, 0 lines if guard suffices

- [ ] **Task 3.2**: Prove `nf_exist_sf_guarded_backward` (line 2805) with
  2-var interval type data. The proof structure:
  1. Extract witness x from the temporal formula (Until/Since/equality)
  2. From `char_k_correct`, determine x's 1-var depth-k NF
  3. From the interval guard, extract 2-var interval types (this is the key
     step -- requires either the existing guard or a strengthened guard)
  4. Apply `nf_2var_from_interval_data` (now with 2-var interval hypotheses)
     to conclude 2-var NF equality
  - **File**: `StaviCompleteness.lean` (replace sorry at line 2805)
  - **Estimated size**: 100-200 lines
  - **Contingency**: If the existing guard cannot provide 2-var interval types,
    strengthen `interval_guard_sf` to include 2-var constraints. This adds
    ~100-150 lines to the guard construction and its forward proof.

- [ ] **Task 3.3**: Verify the Stavi completeness chain is sorry-free:
  - `lean_verify nf_exist_sf_guarded_backward` -- no sorryAx
  - `lean_verify nf_2var_exist_sf_classical` -- no sorryAx
  - `lean_verify nf_characterizable_by_stavi` -- no sorryAx
  - `lean_verify stavi_expressive_completeness` -- no sorryAx

**Timing**: 2-3 hours

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/StaviCompleteness.lean`

**Verification**:
- `lean_verify stavi_expressive_completeness` -- no sorryAx (primary success criterion)
- Zero sorry sites in `nf_exist_sf_guarded_backward`

---

### Phase 4: Full Chain Verification [NOT STARTED]

**Goal**: Verify the entire sorry chain from `completeness_discrete` is resolved.

**Tasks**:
- [ ] **Task 4.1**: Verify `US_expressively_complete_over_prior`:
  - `lean_verify US_expressively_complete_over_prior` -- no sorryAx

- [ ] **Task 4.2**: Verify model surgery chain:
  - `lean_verify gap_prior_UZ_contradiction` -- no sorryAx
  - `lean_verify no_gaps_discrete_model_surgery` -- no sorryAx

- [ ] **Task 4.3**: Verify `completeness_discrete`:
  - `lean_verify completeness_discrete` -- no sorryAx (or sorryAx only through
    non-273 chains like chronicle construction)

- [ ] **Task 4.4**: Full build verification:
  - `lake build` passes without errors
  - No new sorry introduced anywhere
  - No import cycles introduced

**Timing**: 1 hour

**Depends on**: 3

**Files to modify**: None (verification only)

**Verification**:
- `lean_verify completeness_discrete` -- no sorryAx from this chain
- `lake build` passes

---

## Testing & Validation

- [ ] `lean_verify zone_match_witness_2var` -- no sorryAx
- [ ] `lean_verify nf_2var_sub_interval_transfer` -- no sorryAx
- [ ] `lean_verify nf_2var_existential_transfer` -- no sorryAx
- [ ] `lean_verify nf_2var_from_interval_data` -- no sorryAx
- [ ] `lean_verify nf_exist_sf_guarded_backward` -- no sorryAx
- [ ] `lean_verify stavi_expressive_completeness` -- no sorryAx
- [ ] `lean_verify US_expressively_complete_over_prior` -- no sorryAx
- [ ] `lean_verify completeness_discrete` -- no sorryAx from this chain
- [ ] `lake build` passes without errors
- [ ] No new sorry introduced anywhere

## Artifacts & Outputs

- `specs/273_chronicle_gap_contradiction_proof/plans/13_generalized-transfer-plan.md` (this file)
- Modified: `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/StaviCompleteness.lean` (~400-700 new lines)
- `specs/273_chronicle_gap_contradiction_proof/summaries/08_generalized-transfer-summary.md`

## Rollback/Contingency

- **If 2-var interval types cannot be derived from the caller's data (Task 3.1
  finds the guard is insufficient)**: Strengthen `interval_guard_sf` to encode
  2-var interval constraints. The guard already encodes 1-var NF types for all
  interval points. Adding the 2-var constraint means encoding the relationship
  between each interval point and the interval endpoints. This changes
  `interval_guard_sf` and its forward proof but follows the same Until/Since
  formula structure. Estimated additional effort: 2-3 hours.

- **If Approach A (changing signatures) causes unexpected breakage downstream**:
  Fall back to adding a NEW theorem `nf_2var_from_interval_data_strong` with
  2-var interval hypotheses, prove it, and have the original
  `nf_2var_from_interval_data` call the strong version after deriving 2-var
  types from 1-var types + bridge structure. This isolates the change.

- **If zone_match_witness_2var is harder than expected**: The 2-var zone matching
  is a direct analogue of the 1-var version. The 5-zone case analysis is
  identical. The only difference is matching against `interval_2var_nf_types`
  instead of `interval_nf_types`. If the Finset membership extraction is
  problematic, work with Classical.choice on the existence statement instead.

- **If sub-interval transfer extraction (Task 1.3) is non-trivial**: The
  quant component of the 2-var NF at depth k directly encodes existential
  transfer at depth k-1. If extracting this requires unfolding NormalForm
  structure deeply, introduce a helper lemma `nf_quant_transfer` that connects
  the quant component to existential transfer abstractly.

- **Git revert** to current commit if any phase introduces regressions.

## Lessons Learned from v11 and v12

1. **IsSuccArchimedean circularity (v11)**: Cannot use discrete-only theorems to
   prove discreteness. The proof must work for all linear orders.

2. **1-var interval types insufficient (v12)**: Zone matching with 1-var NFs
   does not determine orderings between independently zone-matched points.
   The literature uses decomposition formula matching (= 2-var NF matching)
   to resolve this. `interval_2var_nf_types` is already defined in the codebase
   (line 1847) but was not used.

3. **Follow the literature**: GHR93/GHR94 already solved the interval splitting
   problem. The resolution is to use richer matching criteria (2-var NFs)
   that encode spatial arrangement within intervals. Novel approaches that
   diverge from the literature have failed twice.
