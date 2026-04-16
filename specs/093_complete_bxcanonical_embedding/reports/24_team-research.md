# Research Report: Task #93 — Team Research Round 24

**Task**: 93 - Complete BXCanonical embedding
**Date**: 2026-04-16
**Mode**: Team Research (4 teammates)
**Session**: sess_1776367216_766def

## Summary

Round 24 synthesizes findings from 4 teammates after 23 prior rounds of research/implementation on the forward_F problem. The team produces the deepest analysis yet, with a key tension between Teammate A (20-25% confidence, "no known approach works") and Teammate C (70% confidence, "iterated demand resolution with defect-set recomputation"). Analysis of this tension reveals that Teammate C's proposed construction has a real gap (previously-resolved formulas can re-enter the defect set), but the underlying insight — that the F-obligation set is monotonically non-increasing — may still lead to a viable well-founded measure. Teammate B confirms published proofs handle forward_F semantically, not syntactically, and identifies the quasimodel infrastructure as the right tool for a restructured approach. Teammate D provides comprehensive ROAD_MAP staleness analysis and strategic recommendations.

## Key Findings

### Primary Approach (from Teammate A)

**Finding 1 — Round-robin and demand-driven chains are equivalent**: The existing `rr_fwd_chain` with `enriched_fwd_step` already folds ALL F-defects at every step. Replacing it with a "demand-driven" construction changes nothing about the mathematical obstacle. The enriched step gives disjunctive control (χ ∈ M' OR F(χ) ∈ M') regardless of how the chain is organized.

**Finding 2 — The enriched chain CREATES the forward_F problem**: By preserving F-obligations through all steps (via `phi_in_mcs_imp_F_phi`), the enriched chain ensures F(ψ) is perpetually present. But the disjunctive resolution means ψ itself may never appear. The non-enriched chain (`fwd_succ`) guarantees ψ ∈ M' at resolving steps, but loses other F-obligations. Neither works alone.

**Finding 3 — `extended_defect_seed_consistent` is already proved**: `target_resolving_fwd_exists_strong` (line 1143, sorry-free) is functionally equivalent. It gives: when target is bx11_earlier than all others, ∃ M' with target ∈ M' and F(χ) ∈ M' for all others. This is no longer a remaining obstacle.

**Finding 4 — Standard published technique (Goldblatt 1992)**: Processes demands sequentially with `{ψ_j} ∪ g_content(M_{j-1})` seed. F-obligations may or may not persist between steps. If F(ψ) is lost before its resolving step, no obligation exists. If it survives, `fwd_succ_resolves` gives definite resolution. The key insight: the non-enriched step's F-loss is a FEATURE, not a bug.

**Finding 5 — No currently identified approach fully works**: After exhaustive analysis of enriched, non-enriched, hybrid, demand-driven, extended seeds, and semantic arguments. Confidence: 20-25%.

### Alternative Approaches (from Teammate B)

**Finding 6 — Published proofs use fundamentally different model constructions**: Burgess 1984, Goldblatt 1992, GHR 1994 all handle F-eventuality SEMANTICALLY via the full canonical model or quasimodel/mosaic methods. None build a single Int-chain with syntactic eventuality resolution. The current `rr_fwd_chain` approach is non-standard and unvalidated by any published proof.

**Finding 7 — The quasimodel infrastructure is the right tool**: The sorry-free Quasimodel/ subsystem (2,289 lines) already handles eventuality via defect-discharge at the BXPoint level with well-founded recursion on `defect_count`. It solves the "does F(ψ) eventually resolve?" question — just at abstract BXPoints, not at Int chain indices.

**Finding 8 — Sorry 5 (backward Until coherence) may be independently provable**: `dd_bfmcs_restricted_buc` asks a BACKWARD direction question (from semantic witness to membership), answerable from BX axioms (BX8 `ψ → φUψ` for base case, BX9/BX10 for step). This could reduce the sorry count independently of forward_F.

**Finding 9 — Semantic coherence via truth lemma restructuring**: Instead of proving chain-level F-resolution, restructure the restricted parametric truth lemma to use abstract BXPoint witnesses from the sorry-free `bx_until_eventuality_resolution`. This bypasses the Int-chain resolution problem entirely. Confidence: 40%.

### Gaps and Shortcomings (from Critic)

**Finding 10 — Naive demand-driven chain with identity tail FAILS**: Concrete counterexample: 3 formulas where ψ₁ resolved at step 1 is lost at step 2. F(ψ₁) persists to step 1 by F-obligation constancy. Forward_F at n=1 requires s > 1 with ψ₁ ∈ chain(s). But ψ₁ ∉ chain(k) for any k > 1. Fatal for any single-pass demand-driven construction.

**Finding 11 — "Perpetual deferral → G(¬ψ)" is DEFINITIVELY circular**: The restricted truth lemma requires `restricted_temporally_coherent root` as a hypothesis, which IS forward_F restricted to deferralClosure(root). Cannot use it to prove forward_F.

**Finding 12 — Iterated demand resolution with defect recomputation (Proposed)**: At each step, recompute D(n) = {χ ∈ sigma_list | F(χ) ∈ chain(n) ∧ χ ∉ chain(n)}, pick a target, use `target_resolving_fwd_exists_strong`. Claim: D(n+1) ⊆ D(n) \ {target}, strictly decreasing, terminates in ≤ |sigma_list| steps. After termination, no F-obligations remain, identity tail is safe. **Confidence: 70%.** However, see synthesis for gap analysis.

**Finding 13 — Code comment "defect count is NOT a valid well-founded measure" (line 1298) may be wrong**: With the correct construction, defect count COULD be well-founded — the key is ensuring no new defects enter. `no_new_f_defects` prevents new F-obligations; the question is whether previously-resolved formulas can become defects again.

### Strategic Horizons (from Horizons)

**Finding 14 — ROAD_MAP.md is significantly stale in 5 areas**: Wrong sorry line numbers (shifted ~46 lines), wrong module counts (3,473 → 5,669 lines, 13 → 16 files), internally contradictory sorry inventory (says both "1 sorry" and "6 sorries"), missing 3 files from import graph (39% of BXCanonical), stale task cross-references (103, 94 listed as not started but completed).

**Finding 15 — 5 new dead ends for ROAD_MAP**: (22) Extended defect seed inconsistency, (23) Defect-count non-monotonicity, (24) BX11 ordering convergence failure, (25) Perpetual-deferral semantic circularity, (26) Quasimodel BXPoint-to-integer bridge gap.

**Finding 16 — Project health**: 5,669 lines in BXCanonical, ~99.9% sorry-free. NOT permanently blocked but forward_F is disproportionately difficult. Publishable partial result exists regardless of outcome.

**Finding 17 — Strategic recommendation**: Continue BXCanonical (do not abandon), invest in pen-and-paper proof before more Lean implementation, consider publishing partial result if blocked.

## Synthesis

### Conflicts Resolved

1. **Teammate A ("no approach works," 20-25%) vs Teammate C ("iterated demand resolution works," 70%)**

   This is the critical tension. Teammate C's proposed construction is:
   - Define D(n) = {χ ∈ sigma_list | F(χ) ∈ chain(n) ∧ χ ∉ chain(n)}
   - At each step, pick target from D(n), use target_resolving_fwd_exists_strong
   - Claim: D(n+1) ⊆ D(n) \ {target}

   **Gap identified**: Previously-resolved formulas can RE-ENTER the defect set. If χ was resolved at step k (χ ∈ chain(k)), χ might be lost at step n+1 (χ ∉ chain(n+1)) while F(χ) ∈ chain(n+1) persists (by F-obligation constancy or phi_in_mcs_imp_F_phi). This means D(n+1) could contain elements NOT in D(n).

   **However**, the F-obligation set FO(n) = {χ | F(χ) ∈ chain(n)} is monotonically non-increasing (by no_new_f_defects: F(χ) ∈ chain(n+1) implies F(χ) ∈ chain(n)). This gives |FO(n)| ≤ |FO(0)| ≤ |sigma_list|. The defect set D(n) ⊆ FO(n), but D can fluctuate within FO.

   **Resolution**: The claim D(n+1) ⊆ D(n) \ {target} is **NOT proven correct** due to the re-entry problem. Teammate C's confidence (70%) is too high for the stated argument. But the underlying observation — that FO is non-increasing and each step resolves at least one formula — may still lead to a viable measure. The correct argument would need to show that the number of "ever-resolved" formulas monotonically increases, eventually covering all of FO. **Revised confidence: 40-50%**, pending pen-and-paper analysis.

2. **Teammate A proposes non-enriched chain; Teammate B proposes quasimodel restructuring**

   These are complementary, not conflicting. Teammate A's analysis shows both enriched and non-enriched chains fail independently. Teammate B suggests the problem is architectural — trying to do syntactic eventuality resolution in a chain is the wrong approach entirely. The quasimodel already solves eventuality at the BXPoint level; the question is whether the BFMCS can be restructured to use quasimodel witnesses directly. **This architectural question has not been deeply explored.**

3. **All 4 teammates agree**: semantic hybrid is circular, extended_defect_seed_consistent is already proved, ROAD_MAP is stale, project should not be abandoned.

### Gaps Identified

1. **The defect re-entry gap in Teammate C's proposal**: Does using target_resolving_fwd_exists_strong at each step prevent previously-resolved formulas from becoming defects again? If the seed for step n+1 is {target} ∪ {F(χ) | other defects} ∪ g_content(chain(n)), previously-resolved formulas are NOT in the seed and may be lost. This is the same problem as the identity tail failure but happening during the active phase.

2. **The quasimodel-to-chain bridge**: Teammate B's most promising direction (semantic coherence via truth lemma restructuring, Finding 9) requires understanding how the restricted parametric truth lemma invokes temporal coherence. Can the truth lemma be decomposed so that some cases are forward_F-free?

3. **The bx11_earlier precondition**: target_resolving_fwd_exists_strong requires target to be bx11_earlier than ALL other defects. With BX11 3-cycles among 3+ defects, there may be no such element. The 2-defect case works (bx11_earlier_total gives totality on pairs), but 3+ defects need the fold's behavior, not pairwise comparison.

4. **Backward chain (sorry 3) and t < 0 case (sorry 2)**: All analysis focuses on the forward chain. The backward direction (P-eventuality) needs symmetric treatment. h_content replaces g_content; P replaces F. The infrastructure may or may not be symmetric.

5. **Forward Until coherence guard condition (sorry 6)**: Even with forward_F, fuc requires φ at all intermediate points between t and s. This needs the BX5 self-accumulation axiom ((φUψ) → ((φ ∧ (φUψ))Uψ)) applied at the chain level.

### Recommendations

**The critical path** requires resolving the tension between Teammates A and C. Three distinct approaches remain viable:

1. **Iterated Demand Resolution (Teammate C, revised)** — 40-50% confidence
   - Fix the defect re-entry gap by finding a monotonic measure
   - Possible measure: track the set of "permanently resolved" formulas (χ where χ ∈ chain(k) for all k ≥ some k₀)
   - Key prerequisite: pen-and-paper proof that D(n) eventually empties
   - Estimated effort: 4-8 hours pen-and-paper, then 20-30 hours Lean if viable

2. **BFMCS Restructuring with Quasimodel Witnesses (Teammate B)** — 35-40% confidence
   - Restructure dd_bfmcs to use quasimodel eventuality witnesses (sorry-free) instead of chain-level resolution
   - This is the most architecturally sound approach but requires significant restructuring
   - Key prerequisite: analyze which truth lemma cases need chain-level coherence vs BXPoint-level coherence
   - Estimated effort: 4-8 hours analysis, then 30-40 hours Lean if viable

3. **Non-Enriched Chain with F-Loss Analysis (Teammate A Finding 13)** — 30-35% confidence
   - Use `fwd_succ` (non-enriched) at each step. F-obligations can be lost.
   - Forward_F argument: either F(ψ) survives to visit step (then fwd_succ_resolves gives witness), or F(ψ) is lost (vacuously satisfied)
   - The gap: F(ψ) being lost means G(¬ψ) entered. Can we show this leads to a contradiction or harmlessness?
   - Key: understand EXACTLY when F(ψ) can be lost in the non-enriched chain

**Pre-step (independent, highest priority)**: Pen-and-paper proof before any more Lean implementation. Investigate whether the defect re-entry problem in approach 1 can be solved, and whether the non-enriched chain's F-loss in approach 3 is actually harmless.

**Independent win**: Investigate whether sorry 5 (restricted_buc) can be proved independently of forward_F.

**ROAD_MAP update**: Apply Teammate D's comprehensive corrections (Finding 14-15). This is a separate documentation task.

## Teammate Contributions

| Teammate | Angle | Status | Confidence |
|----------|-------|--------|------------|
| A | Primary approach (deep analysis) | completed | low (20-25%) |
| B | Alternative approaches (literature + novel) | completed | medium (55%) |
| C | Critic (validation + counterexamples) | completed | medium-high (70%, revised to 40-50%) |
| D | Horizons (ROAD_MAP + strategy) | completed | high (90% factual, 50-60% forward_F) |

## References

- Burgess, J.P. (1982/1984). "Axioms for tense logic I: Since and Until" / "Basic tense logic"
- Goldblatt, R. (1992). "Logics of Time and Computation" — CSLI Lecture Notes
- Gabbay, D., Hodkinson, I., Reynolds, M. (1994). "Temporal Logic" — Oxford University Press
- Reynolds, M. (2003). Temporal logic completeness techniques
- Caleiro, C., Viganò, L., Volpe, M. (2012). "Mosaic Method for Many-Dimensional Modal Logics"
- Report 17: Round-robin chain history (19 failed approaches)
- Report 23: Team research synthesis (demand-driven consensus)
- Summary 23: Implementation attempt (Phase 1 complete, Phases 2-6 blocked)
- OrderedSeedConsistency.lean: enriched_resolving_seed_consistent, two_defect_consistent_seed
- RootScopedChain.lean: target_resolving_fwd_exists_strong, enriched_fwd_step_resolves_one
