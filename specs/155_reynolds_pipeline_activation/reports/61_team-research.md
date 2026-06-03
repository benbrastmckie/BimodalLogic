# Research Report: Task #155

**Task**: reynolds_pipeline_activation — Eliminate all sorries from completeness_discrete
**Date**: 2026-06-02
**Mode**: Team Research (4 teammates)
**Session**: sess_1780460054_7b1e12

## Summary

Four research teammates investigated the two blocker chains preventing sorry-free `completeness_discrete`, consulting the `literature/` directory throughout. The team achieved strong consensus on Chain 1 (EF Game Bridge) and identified a critical type mismatch in Chain 2 that invalidates the current plan's approach.

## Key Findings

### Chain 1: nf_2var_existential_transfer (Stavi/EF Game Chain)

**Consensus (A, C agree; D questions criticality)**: The interval splitting problem is a genuine mathematical gap — zone matching cannot provide multi-variable simultaneous orderings for the depth j'+1 inductive step. The correct approach is the **EF Game Bridge**, which translates NF hypotheses into game language, applies the sorry-free `ghr93_strategy_compose` (Composition.lean), and converts back.

**Implementation path** (from Teammate A, ~300-430 lines):
1. `nf_char_eq_implies_rank_type_eq` — depth-k NF equality → rank_type equality (uses sorry-free `nf_profile_determines_rank_type` from CharacteristicFormula.lean)
2. `interval_nf_types_implies_interval_types` — interval type set translation
3. `nf_hypotheses_imply_duplicator_wins` — bridge hypotheses → game wins
4. `duplicator_wins_implies_nf_agreement` — game win → 2-var NF equality

**No circularity**: `nf_profile_determines_rank_type` does NOT depend on `nf_2var_from_interval_data`.

**Literature basis**: GHR93 Proposition 7 (pp.113-115) — induction on game rounds, pivot point c splits interval, duplicator maintains strategies for sub-intervals independently.

### Chain 2: chronicle_gap_contradiction / IsSuccArchimedean

**Critical discovery (Teammate C)**: The current plan's Phase 4 (replace `succ_embed_surjective` with `chronicle_is_good_direct`) has a **type mismatch**. The restricted coherence conditions (`cantor_bfmcs_discrete_restricted_tc/fuc`) require concrete integer witnesses via `succ_embed_surjective`. Abstract k-equivalence from `chronicle_is_good_direct` provides EF-game winning strategies, NOT concrete integers. This gap is non-trivial to bridge.

**Teammate B finding**: `chronicle_is_good_direct` (ShiftAndGlue.lean:950) is sorry-free and implements the full Reynolds pipeline, but is not connected to the BFMCS coherence conditions.

**Three approaches for Chain 2** (ranked by feasibility):

1. **Restructure BFMCS to use limit-domain indices** (Teammate C recommendation): Instead of mapping to Z via succ_embed, keep the limit-domain as the index set. Redefine `restricted_tc`/`restricted_fuc` to work directly on limit-domain elements. Avoids the concrete-integer problem entirely. Estimated ~200-400 lines.

2. **Prove `succ_reaches_dom_N` Case 3b** (Teammate B recommendation): Show the omega-chain construction never produces a below-min boundary via stage properties. Would make `chronicle_gap_contradiction` provable, removing the sorry chain. Estimated ~150-300 lines but the constant-MCS case remains genuinely hard.

3. **Rewire completeness_discrete to use Path B** (Teammate D recommendation): Claims `GoodStructuresModelSurgery.lean` has zero sorries and the Reynolds pipeline may already be complete. **NEEDS VERIFICATION** — Teammate C's type mismatch concern applies here too.

### Critical Path Verification Needed

**Teammate D claims** Chain 1 may not block `completeness_discrete` (possibly only blocks standalone expressive completeness). **Teammate C disagrees** — the sorry chain traces through. This MUST be verified with `#print axioms completeness_discrete` before investing 300+ lines in Chain 1.

### Non-Critical Path Clarification

**Teammate C confirmed**: CaseAnalysis.lean sorries (5 sorries in `ghr93_cases_III_IV`) are NOT on the critical path. `ghr93_forward_to_backward_discrete` uses `ghr93_inductive_step_discrete` which avoids Cases III/IV entirely because discrete structures have no gaps.

## Synthesis

### Conflicts Resolved

| Conflict | Resolution |
|----------|------------|
| D claims Chain 2 "already complete" vs B/C identify real blockers | **B/C prevail**: `sorryAx` still flows through `chronicle_gap_contradiction`. D's grep may have missed `sorry` in dependencies. The sorry chain through `succ_cofinal` is real. |
| D questions Chain 1 criticality vs A/C confirm it | **Unresolved**: Need `#print axioms` verification. If D is right, Chain 1 work can be deferred. |
| B suggests fixing chronicle_gap_contradiction vs C warns of type mismatch | **Both partially right**: Case A fix is viable but insufficient alone. Restructuring BFMCS (C's approach) is more robust. |

### Gaps Identified

1. **No teammate verified `#print axioms completeness_discrete`** — essential to confirm which sorry chains actually block the main theorem
2. **Type mismatch between abstract k-equivalence and concrete coherence conditions** — no teammate provided a complete solution
3. **Constant-MCS case** (Case B of chronicle_gap_contradiction) — all teammates agree this is genuinely hard with no current solution path

### Recommendations

**Immediate action** (before any implementation):
1. Run `#print axioms completeness_discrete` to definitively trace which sorries are on the critical path
2. Run `#print axioms countermodel_discrete_reynolds` to check if the Reynolds pipeline is truly sorry-free

**Chain 1** (if confirmed on critical path):
- Implement the EF Game Bridge (~300-430 lines, high confidence)
- Literature reference: GHR93 Proposition 7, `literature/Gabbay_Hodkinson_Reynolds_1993_Temporal_expressive_completeness_gaps.md`

**Chain 2** (recommended approach):
- Restructure BFMCS coherence conditions to use limit-domain indices directly, bypassing the Z-indexing that creates the IsSuccArchimedean dependency
- Literature reference: Reynolds 1994 Sections 8-9, `literature/Reynolds_1994_Axiomatising_U_and_S_over_integer_time.md`

## Teammate Contributions

| Teammate | Angle | Status | Confidence |
|----------|-------|--------|------------|
| A | GHR93 Prop 7 / EF Game Bridge | completed | high |
| B | Chronicle gap / Reynolds bypass | completed | medium |
| C | Critic / sorry audit | completed | high |
| D | Strategic horizons | completed | medium |

## References

- `literature/Gabbay_Hodkinson_Reynolds_1993_Temporal_expressive_completeness_gaps.md` — Proposition 7 (Chain 1)
- `literature/Reynolds_1994_Axiomatising_U_and_S_over_integer_time.md` — Sections 8-9, Theorem 15, Lemma 16 (Chain 2)
- `literature/Gabbay_Hodkinson_Reynolds_1994_Temporal_Logic_Foundations_Vol1_ch12.md` — Chronicle construction
- `literature/Burgess_1982_Axioms_for_tense_logic_Since_and_Until.md` — Original axiomatization
