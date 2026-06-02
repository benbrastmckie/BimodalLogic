# Research Report: Task #155

**Task**: reynolds_pipeline_activation — Eliminate all sorries from completeness_discrete
**Date**: 2026-06-02T19:35:00Z
**Mode**: Team Research (4 teammates)
**Focus**: Deep-dive into GHR93 Proposition 7 game composition bridge construction against literature/

## Summary

All 3 sorry sites (StaviCompleteness.lean lines 2347, 2429, 2787) reduce to a single root blocker: `nf_2var_existential_transfer` requires sub-interval type preservation that zone matching alone cannot provide. GHR93 Proposition 7 resolves this by having Duplicator use the **full interval strategy** (not just zone matching) to find a witness satisfying ALL decomposition formulas simultaneously. Two viable implementation paths emerged: (1) a strengthened induction carrying all-pairs interval data as invariant (~200-400 lines, inside StaviCompleteness.lean), or (2) the full EF game bridge through ExtendedCarrier (~400-600 lines, requiring NFGameBridge.lean). The critic identified that plan v62's Sub-phase 3B targets the wrong interface (decomposition_agreement lacks interval_types). A second sorry chain in model surgery (GoodStructuresModelSurgery.lean) was discovered that is not in the task description.

## Key Findings

### Primary Approach — GHR93 Proposition 7 Proof Extraction (Teammate A)

**The exact GHR93 argument** (pp.114-115):
1. Induction on n rounds of the game
2. Spoiler picks α in interval (x_i, x_{i+1}) in M
3. Duplicator collects ALL decomposition formulas (Definition 8.8) witnessing how α splits the interval
4. Duplicator uses her **full-interval strategy** G_{f(n+1);r} to find e in N satisfying ALL those decomposition formulas simultaneously
5. By Lemma 11 (p.113), this yields winning strategies for BOTH sub-interval games
6. By Theorem 6 (backward game), backward strategies follow
7. Apply induction hypothesis

**Critical insight**: The witness e is determined by the FULL interval strategy, not zone matching. Zone matching only ensures 1-var NF agreement; the full strategy ensures all sub-interval decomposition data is preserved.

**Recommended implementation**: Strengthened induction on j (inner depth) maintaining "all-pairs interval agreement" as invariant:
```
nf_kvar_existential_transfer (k j n)
  -- n-point config with matching depth-k NFs, orderings, AND all-pairs interval data
  → ∀ chi, (∃u, nf_eval j (n+1) (u::env)) ↔ (∃u', nf_eval j (n+1) (u'::env'))
```

**GHR93 page references**: Proposition 7 (p.114), Lemma 11 (p.113), Corollary 5 (p.115), Definition 8.8 (p.108)

### Alternative Approaches (Teammate B)

- **Reynolds 1994**: Proves weak completeness via gap elimination (Theorem 14) and k-equivalence transfer (Theorem 15), but operates at the model level, NOT at the 2-variable NF transfer level. No shortcut available.
- **GHR94 Chapter 9**: Provides theoretical framework (Separation = Expressive Completeness) but not the combinatorial machinery. The game composition is in GHR93 only.
- **Hodkinson-Reynolds 2006**: Handbook chapter markdown contains only ToC + Introduction; substantive content (pp.658-712) not available.
- **Conclusion**: No alternative to the game composition approach exists in the literature. All roads lead to GHR93 Proposition 7.

### Gaps and Assumptions Challenged (Teammate C — Critic)

**Confirmed correct**:
- The sub-interval splitting problem is real, not a misunderstanding
- The signature bridge (sig → muSig) is NOT a fundamental blocker — machinery exists (`liftSigFormula_eval`, `stavi_truth_mu_at_point`, `nf_profile`)

**Critical gaps identified**:
1. **Sub-phase 3B targets wrong interface**: `decomposition_agreement` (Decomposition.lean:62-101) does NOT contain `interval_types`. It has a point-challenge condition requiring `ghr93_winning_condition`. The plan's proposed lemma `interval_nf_types_eq_implies_interval_types_eq` does not connect to decomposition_agreement's actual interface.
2. **Sorry 3 (line 2787) will NOT auto-resolve**: The comment "When the bridge is proved, this proof completes" is aspirational. A real proof (~50-150 lines) must extract the witness from the temporal formula, determine its 1-var NF via `char_k_correct`, and apply `nf_2var_from_interval_data`.
3. **NFGameBridge.lean has 174 lines but no real bridge content** — only trivial corollaries.

**Unexplored alternative**: Double induction on (k, n) where the hypothesis carries depth-k interval types for ALL sub-intervals. This was never attempted and might avoid 400+ lines of game bridge code.

### Strategic Horizons (Teammate D)

- **Second sorry chain discovered**: GoodStructuresModelSurgery.lean has 2 conditional sorries (`gap_prior_UZ_contradiction`, `gap_prior_SZ_contradiction`) required for Phase 4 of plan v61 but NOT in task description. Total scope: ~1100-1260 new lines across both chains.
- **Task 199 not actually blocking 155**: Task 199 creates a tactic for `ghr93_case_II` in CaseAnalysis.lean, which is NOT on the critical path. The state.json dependency should be removed.
- **60+ revisions represent convergence**: Each revision correctly discovered previously-hidden sorry sites. The trajectory is narrowing, not diverging.
- **Axiomatizing is counterproductive**: Mathematics is provable (published results), project claims sorry-free proofs, and axioms would cascade into downstream tasks (95, 254).
- **Recommendation**: Proceed with plan, but consider splitting task after Chain 1 closes.

## Synthesis

### Conflicts Resolved

| Conflict | Teammates | Resolution |
|----------|-----------|------------|
| Game bridge vs. strengthened induction | A+C vs B | **Strengthened induction preferred** — both A and C independently converged on carrying all-pairs interval data as invariant, matching GHR93's actual proof structure. This avoids 400+ lines of ExtendedCarrier bridge code. Try this first (~200-400 lines inside StaviCompleteness.lean). |
| Sub-phase 3B interface target | C vs plan v62 | **Critic is correct** — plan v62's Sub-phase 3B targets the wrong interface. `decomposition_agreement` lacks `interval_types`. Must either (a) work within the NF world directly (strengthened induction) or (b) restructure the bridge to target `ghr93_winning_condition` instead. |
| Scope: 3 sorries vs 5+ | D vs task description | **Task scope needs updating** — the model surgery chain (2 additional sorries) is required for `completeness_discrete` but not in the description. Recommend splitting: close Chain 1 (Stavi) first, then create a new task for Chain 2 (model surgery). |

### Gaps Identified

1. **No implementation has tried the strengthened induction approach** — carrying all-pairs interval data as invariant. This matches GHR93 most directly and avoids the ExtendedCarrier/signature bridge entirely.
2. **Sorry 3 needs explicit proof work** (~50-150 lines), not just "bridge closes it."
3. **Model surgery sorry chain** needs its own task or Phase 5 revision.
4. **Task 199 dependency is stale** — should be removed from state.json.

### Recommendations

1. **Primary path**: Implement strengthened induction on j inside StaviCompleteness.lean (~200-400 lines). Modify `nf_2var_existential_transfer` to carry all-pairs interval agreement as invariant, matching GHR93 Proposition 7's proof where Duplicator uses the full interval strategy. This avoids the entire ExtendedCarrier bridge.

2. **Fallback**: If strengthened induction hits unforeseen barriers, fall back to the full game bridge but target `ghr93_winning_condition` (not `decomposition_agreement`/`interval_types`), fixing the Sub-phase 3B interface mismatch.

3. **Task scope**: Split task 155 after closing Chain 1 (Stavi sorries). Create a separate task for Chain 2 (model surgery in GoodStructuresModelSurgery.lean).

4. **Cleanup**: Remove stale task 199 dependency from state.json.

## Teammate Contributions

| Teammate | Angle | Status | Confidence |
|----------|-------|--------|------------|
| A | GHR93 Prop 7 extraction | completed | high |
| B | Alternative approaches | completed | high |
| C | Critic (gaps/assumptions) | completed | high |
| D | Strategic horizons | completed | medium |

## References

- GHR93: Gabbay, Hodkinson, Reynolds (1993) "Temporal expressive completeness in the presence of gaps" — Proposition 7 (p.114), Lemma 11 (p.113), Corollary 5 (p.115), Definition 8.8 (p.108)
- GHR94: Gabbay, Hodkinson, Reynolds (1994) "Temporal Logic: Mathematical Foundations" Vol.1 Ch.9
- Reynolds 1994: "Axiomatising U and S over integer time" — Theorems 14-15
- Hodkinson & Reynolds 2006: "Temporal Logic" Handbook Ch.11
