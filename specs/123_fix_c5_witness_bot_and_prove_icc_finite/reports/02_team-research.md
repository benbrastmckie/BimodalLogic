# Team Research Report: Task #123 — succ_embed_surjective Analysis

**Task**: 123 — fix_c5_witness_bot_and_prove_icc_finite
**Date**: 2026-05-11
**Mode**: Team Research (4 teammates)
**Session**: sess_1778538040_e03b63

## Summary

All 4 teammates independently confirmed: `succ_embed_surjective` is **mathematically TRUE** and provable. The prior claim that it was "unprovable due to Classical.choose allowing orbit convergence to an irrational limit" was **incorrect** — it confused the failure of a specific proof strategy (stage induction) with mathematical falsity.

The recommended proof path is the **single-orbit argument** using existing collapse infrastructure (~80-150 lines).

## Key Findings

### Teammate A — Primary Analysis (HIGH confidence)
- Verdict: TRUE. The accumulation scenario cannot occur.
- Between any x and succ(x) in limit_dom, NO domain points exist (universal no-gap from U(T,bot))
- An infinite bounded subset of limit_dom would require accumulation, but accumulation at any point (rational or not) forces domain points between consecutive orbit members, contradicting no-gap
- Recommended: prove Icc finiteness → cofinality → surjectivity via squeeze

### Teammate B — Alternative Approaches (HIGH confidence)
- No viable bypass exists — TC/FUC coherence REQUIRES integer witnesses from succ_embed
- BUC is sorry-free because its C4 witnesses are bounded between known embedded points; TC/FUC witnesses can be above all embedded points (the cofinal problem)
- collapse_map/collapse_iso do NOT exist in the codebase (report 07 was mistaken)
- Ranked the single-orbit argument as best approach; existing infrastructure (collapse_equiv, collapse_class_sep, collapse_orbit_bounded) is ready

### Teammate C — Critic (HIGH confidence)
- The "irrational limit" counterargument is WRONG: if orbit converges to L and domain point w > L exists, the pred-chain from w produces elements between consecutive orbit members, contradicting no-gap
- Report 06's proof sketch was CIRCULAR (assumed Icc finiteness to prove it), but the CONCLUSION was correct
- The difficulty is purely proof-engineering: stage induction fails because succ_embed(j+1) in the full limit_dom is determined by future stages, not stage K+1

### Teammate D — Strategic Horizons (MEDIUM confidence)
- Task 122 should be consolidated into 123 (123 has absorbed the BFMCS work)
- Don't modify the construction — surjectivity is true as-is
- The mixed case sorry is architectural (needs task 117's natural X ⊂ Q inclusion), not a fundamental open problem
- Dense + discrete completeness is a substantial publication result even without the mixed case

## Synthesis

### Conflicts Resolved
- **Conflict**: Prior agents produced contradictory findings (TRUE vs UNPROVABLE). **Resolution**: All 4 teammates independently confirmed TRUE. The "unprovable" claim was incorrect — it confused stage-induction failure with mathematical impossibility. The irrational-limit scenario is self-defeating because the pred-chain from any point above the limit would violate no-gap.

### Proof Strategy Consensus

The **single-orbit argument** using existing collapse infrastructure:

1. Take any w ∈ LimitDomSubtype. Assume w is NOT in root's orbit (¬collapse_equiv root w).
2. By `collapse_class_sep` (already proved, sorry-free): w's orbit is totally separated from root's orbit.
3. WLOG w > all root orbit members (the below case is symmetric via pred).
4. Root's orbit is ascending: succ_embed(0) < succ_embed(1) < ... all < w.
5. The pred-chain from w: w > pred(w) > pred²(w) > ... all > every orbit member.
6. These two sequences (orbit ascending, pred-chain descending) interleave near their common limit.
7. For large n and k, succ_embed(n) and pred^k(w) are arbitrarily close in Q.
8. At some point, pred^k(w) falls between succ_embed(n) and succ_embed(n+1), contradicting no-gap.

Step 8 is the key. It uses: orbit values are rationals increasing toward a limit, pred-chain values are rationals decreasing toward the same limit. Between consecutive orbit members, no domain points (no-gap). But pred^k(w) IS a domain point. So pred^k(w) cannot be between consecutive orbit members. But it must be (since the sequences converge to the same limit from opposite sides). Contradiction.

**Formalizing step 8**: Need to show that for sufficiently large n, k: succ_embed(n) < pred^k(w) < succ_embed(n+1). This uses the Archimedean property of Q: the gap between succ_embed(n) and succ_embed(n+1) approaches 0 (since the orbit converges), while pred^k(w) approaches the same limit from above. Eventually the pred-chain value enters the gap.

**Concern (from Critic)**: The "gap approaches 0" claim needs careful formalization. In Q, we need: for any ε > 0, eventually |succ_embed(n+1).val - succ_embed(n).val| < ε. This follows if the orbit converges (bounded monotone sequence in R has a limit, consecutive differences → 0). And pred^k(w).val → L from above while succ_embed(n).val → L from below. So for large enough n, k: succ_embed(n).val < pred^k(w).val < succ_embed(n+1).val.

### Gaps Identified
1. The exact Lean formalization of "consecutive orbit gaps shrink to 0" may require real analysis lemmas from Mathlib (monotone convergence, Cauchy sequences in Q/R)
2. Whether `LimitDomSubtype` values are accessible as rationals for the convergence argument needs verification
3. The pred-chain may not literally converge — need to check that pred^k(w) is bounded below

### Recommendations

1. **Prove `succ_embed_surjective`** via the single-orbit argument (80-150 lines)
2. **Consolidate task 122** into task 123 (123 has absorbed the BFMCS work)
3. **Accept the mixed-case sorry** as out-of-scope for now (needs architectural changes from task 117)
4. **Do NOT modify the omega-chain construction** — surjectivity holds as-is

## Teammate Contributions

| Teammate | Angle | Status | Confidence |
|----------|-------|--------|------------|
| A | Primary surjectivity analysis | completed | HIGH |
| B | Alternative approaches | completed | HIGH |
| C | Critic — challenge findings | completed | HIGH |
| D | Strategic horizons | completed | MEDIUM |

## References

- ChronicleToCountermodel.lean lines 2060, 2063 (sorry sites)
- `succ_embed_no_gap` (existing, sorry-free)
- `collapse_class_sep` (existing, sorry-free)
- `collapse_orbit_bounded`, `collapse_orbit_convex` (existing, sorry-free)
- reports/06_surjectivity-false-verification.md (prior research, correct conclusion but circular proof)
- handoffs/03_succ-surjective-analysis.md (stage-induction failure analysis)
