# Research Report: Task #273

- **Task**: chronicle_gap_contradiction_proof
- **Date**: 2026-06-14
- **Mode**: Team Research (4 teammates)
- **Session**: sess_1781436428_97e03a

## Summary

- **Root cause confirmed**: `ssn_xt_compatible` (KampBypass.lean:78-91) passes unrealizable 3-variable order assignments (3 defective cases in the Until direction, 4 in Since, 6 in the equality direction). Teammate A exhaustively enumerated all 64 boolean assignments; Teammate C corroborated that this does not refute the zone-aware approach but instead identifies a filter gap.
- **Depth-0 case is mathematically sound and closable**: All three analysis teammates (A, B, C) converge that the 8 sorry sites in `existPart_succ_n1_bypass_k0` are zone-specific proof obligations without fundamental mathematical obstacles. Estimated effort: 1,000 lines of mechanical case analysis.
- **Depth k >= 1 reintroduces the Feferman-Vaught composition problem**: Teammates B and C independently confirm that the non-interval zone backward direction at depth k >= 1 requires the composition lemma, which is false in general (NfComposition.lean counterexample) and not yet proved for Prior structures. Critic confidence: 95%.
- **Strategic decision required**: Teammate D identifies a concrete fallback (named axiom `kamp_expressive_completeness`) that is mathematically honest, publishable, and unblocks 4 downstream tasks. The question of whether to pursue 2-3 more dispatches or convert to the named axiom is the key decision point.
- **The `ssn_order_consistent` filter** (Teammate A's proposal) is the correct immediate code fix for the unsound filter and should be merged regardless of which depth-k strategy is chosen.

## Key Findings

### 1. `ssn_xt_compatible` admits unrealizable SSN values (Teammate A, HIGH confidence)

The filter at KampBypass.lean:78-91 checks predicate compatibility and x-t order compatibility but does NOT check transitivity or equality consistency for all three variables (y, x, t). This allows SSN values that encode impossible linear orders to pass and contribute incorrect conjuncts to the enriched formula.

**Defect inventory**:
- Until direction (t < x): 3 of 16 combinations per zone are unrealizable
- Since direction (x < t): 4 defective SSN values emit formulas
- Equality direction (x = t): 6 defective SSN values emit formulas

**Fix**: Add `ssn_order_consistent ssn` check to `ssn_xt_compatible`. The proposed definition covers all 3 pairwise antisymmetry checks, 6 transitivity implications, and 3 equality consistency conditions. This is a single call site modification that protects all 13 call sites uniformly.

**Key correctness property**: `ssn_zone_until` correctly classifies all 5 realizable Until orderings. The defect is entirely in the upstream filter, not in zone classification.

### 2. VecEADecomp is sorry-free and provides complete zone coverage (Teammate B, VERY HIGH confidence)

VecEADecomp.lean (898 lines, 0 sorries) already has complete sorry-free zone theorems for ALL 3-variable orderings:

| Zone | Theorem |
|------|---------|
| y < t < x | `nf_3var_zone_ytx_correct` |
| t < y < x | `nf_3var_bracket_tyx_correct` |
| t < x < y | `nf_3var_zone_txy_correct` |
| x < y < t | `nf_3var_bracket_xyt_correct` |
| x < t < y | `nf_3var_zone_xty_correct` |
| y < x < t | `nf_3var_zone_yxt_correct` |
| y = t | `nf_3var_eq_yt` |
| y = x | `nf_3var_eq_yx` |
| inconsistent | `nf_3var_order_contradiction` |

Each zone theorem produces a `VecEA2` with correct orientation, translatable via the sorry-free `VecEA2.translateLeft` / `VecEA2.translateRight` infrastructure. The depth-0 sorry sites in KampBypass.lean are wiring sorries connecting this existing infrastructure to `nf_eval_nf`.

### 3. The 8 depth-0 sorry sites are wiring, not mathematics (Teammates B and C, convergent)

All 8 depth-0 sorry sites in KampBypass.lean follow the same pattern: the mathematical content exists in VecEADecomp zone theorems; the sorry gap is the bridge between `VecEA2.holdsLeft` and `nf_eval_nf`. Teammate B's estimates:

| Sorry site | Location | Estimated lines |
|------------|----------|----------------|
| `existPart_succ_n1_bypass_k0_eq` | L690 | ~100 |
| Equality inner sorry | L752 | included above |
| `zone_3var_exist_iff_1var` | L842 | ~200 |
| `backward_holdsLeft_of_nf_eval` endLeft | L923 | ~100 |
| endRight (eq_x, above_x) | L935 | ~80 |
| bracket (between_tx) | L939 | ~60 |
| `forward_nf_eval_of_holdsLeft` | L997 | ~150 |
| `existPart_succ_n1_bypass_k0_since` | L1109 | ~300 |

Total depth-0 wave: approximately 1,000 lines of zone-by-zone case analysis.

### 4. The NfComposition counterexample does NOT refute the zone-aware approach (Teammate C, HIGH confidence)

The counterexample at NfComposition.lean:18-37 refutes `generalized_composition` (same 1-var NFs + same order => same n-var NF), but the zone-aware enriched formula encodes interval zone content explicitly via Since/Until witnesses. The formula correctly distinguishes (0,2) from (0,1) in Z because `Since(char_y, top)` at x=2 fires for a witness between 0 and 2, while no such integer exists between 0 and 1.

### 5. Depth k >= 1 faces the Feferman-Vaught composition problem (Teammates B and C, VERY HIGH confidence)

At depth k >= 1, non-interval zones (y > x when t < x, y < t when t < x) require recovering the full 3-var NF from y's 1-var NF + x's 1-var NF + orders. This is the composition property, which is false in general and has not been proved for Prior structures in Lean. The enriched formula approach does not bypass this -- it relocates the sorry from `nf_exist_formula_nested_backward` to `existPart_succ_n1_bypass` at line 1197.

Teammate B's arity-climbing induction proposal (P_n(k) with depth decreasing, arity increasing) was assessed by Teammate C at 15% confidence of success: the backward direction of P_n(k+1) at any n still requires the composition argument at arity n+1.

### 6. Strategic fallback: named axiom (Teammate D, HIGH confidence)

The named axiom approach:
```lean
axiom kamp_expressive_completeness : ∀ (sig : MonadicSignature) (k : Nat) (n : Nat) ...
```
is mathematically honest and publishable. It changes `sorryAx` to a named, documented assumption in `#print axioms completeness_discrete`. The mathematical content (Kamp's theorem) has been known since 1968 with multiple independent proofs. The sorry-free infrastructure (EF games, model surgery, Reynolds pipeline, 174,465 total lines) already constitutes a significant formalization contribution regardless.

Downstream unblocking from closing or axiomatic-wrapping task 273:
- Task 155 (eliminate sorries from completeness_discrete)
- Task 299 (refactor DiscreteGameTransfer.lean)
- Task 95 (verification pass -- transitive)
- Task 254 (documentation update -- transitive)

## Synthesis

### Conflicts Resolved

**Conflict 1**: Teammate A recommends fixing `ssn_xt_compatible` as the primary action; Teammate B recommends pursuing depth-0 wiring sorries as the primary action.

**Resolution**: These are sequential, not competing. The `ssn_order_consistent` fix is a prerequisite for the depth-0 wiring proofs -- unrealizable SSN values reaching zone lemmas would cause proof obligations to fail or require separate contradiction branches. Apply the filter fix first (small, localized), then proceed to wiring proofs. Both teammates converge on the same goal; they differ only in sequence emphasis.

**Conflict 2**: Teammate B (Option A: Wave 1 + Wave 2) projects a viable path to close k >= 1 via arity-climbing induction. Teammate C rates this at 15% confidence.

**Resolution**: Teammate C's adversarial analysis is more rigorous here. The backward direction of P_n(k+1) requires showing that the formula's truth implies existence of a witness with the full (n+1)-var NF -- exactly the composition property. Teammate B acknowledges this in Finding 5 ("requires the IH at depth k for 3-var existentials") but underweights the difficulty. Teammate C's 15% confidence is well-grounded. The arity-climbing approach should not be counted on; it is a speculative Wave 2, not a reliable path.

**Conflict 3**: Teammate D recommends a dispatch budget (2-3 more dispatches) then convert to named axiom. Teammate C recommends closing depth-1 first, then investigating composition for k >= 2.

**Resolution**: These are compatible if reframed: Teammate D's "2-3 dispatches" maps exactly onto Teammate C's "close depth-1 case." If those dispatches succeed, depth-1 is closed and the named axiom covers only k >= 2 (or is not needed). If they fail, the named axiom covers everything. The two recommendations are sequential phases of the same strategy.

### Gaps Identified

**Gap 1: No assessment of `ssn_zone_until` correctness on the equality cases (x=t)**. Teammate A's analysis focuses on the Until and Since directions in detail, but the equality direction defect enumeration (6 cases) does not include an assessment of how `existPart_succ_n1_bypass_k0_eq` (L690) handles or should handle these cases post-filter. The equality direction sorry is the first in the chain; understanding its interaction with the filter fix matters.

**Gap 2: No estimate of the `zone_3var_exist_iff_1var` proof structure**. This is identified as the largest single sorry (~200 lines), but no teammate provided a detailed proof sketch. Given that `ssn_zone_until` must case-split across all 5 realizable zones (after the filter fix), the proof requires connecting `ssn_zone_until`'s output to the corresponding VecEADecomp theorem. A phase-1 implementation run should target this sorry first to validate the approach before committing to the full 1,000-line estimate.

**Gap 3: Composition on Prior structures remains completely open**. No teammate provided new evidence bearing on whether the Feferman-Vaught composition theorem can be proved for Prior linear orders in Lean. Teammate C acknowledges this requires following Rabinovich Section 5 more faithfully, but this path has not been attempted in any of the 40+ dispatches. If the named axiom fallback is rejected, this would require a dedicated research phase on Rabinovich's composition argument.

### Recommendations

**Recommendation 1 (Immediate): Apply the `ssn_order_consistent` filter fix.**

Add the proposed `ssn_order_consistent` definition to KampBypass.lean and add `&& ssn_order_consistent ssn` to `ssn_xt_compatible`. This eliminates the unsoundness defect regardless of which depth-k strategy is chosen. Also add the `ssn_order_consistent_correct` theorem (if `ssn_order_consistent ssn = false` then the SSN is unrealizable on any strict linear order). This is a self-contained improvement with no risk of breaking existing proofs, since all existing SSN values arising from model evaluation are already realizable.

**Recommendation 2 (Phase A): Close the depth-0 wiring sorries in KampBypass.lean.**

Target the 8 sorry sites in order:
1. `zone_3var_exist_iff_1var` (L842) -- largest single sorry, validates approach
2. `backward_holdsLeft_of_nf_eval` bracket (L939) -- smallest, structurally clean
3. `backward_holdsLeft_of_nf_eval` endLeft (L923) and endRight (L935)
4. `forward_nf_eval_of_holdsLeft` (L997)
5. `existPart_succ_n1_bypass_k0_eq` (L690, L752)
6. `existPart_succ_n1_bypass_k0_since` (L1109) -- largest, mirror of Until

Confidence that this succeeds: 80% (Teammate C). Estimated effort: 2-3 focused dispatches.

**Recommendation 3 (Decision point after Phase A): Set a deadline on k >= 1.**

If Phase A closes the depth-0 case, immediately make the strategic choice:
- **Option A (pursue composition)**: Dedicate 2-3 dispatches to following Rabinovich Section 5's composition argument for Prior structures. If no convergence, convert to named axiom.
- **Option B (immediate axiom)**: Wrap `kamp_expressive_completeness` as a named axiom now. Mark task 273 [PARTIAL] with a clear documentation block. Proceed to tasks 155, 299, 95, 254.

The Critic's evidence strongly favors Option B: 40+ dispatches, 29 plan versions, and a mathematically confirmed blocker (Feferman-Vaught composition for Prior structures) that no dispatch has touched. Option A is not foreclosed, but it should be time-boxed.

**Recommendation 4 (Long-term): Scope the Kamp composition argument as a standalone task.**

If task 273 converts to named axiom, create a new task scoped specifically to Rabinovich Section 5's composition argument. This separates the well-defined mathematical problem from the large implementation machinery. A human mathematician should review whether Rabinovich's Section 5 proof is directly formalizable or requires a fundamentally different representation (e.g., EF-game based composition as in Doets 1989).

## Teammate Contributions

| Teammate | Angle | Status | Confidence |
|----------|-------|--------|------------|
| A | Primary: ssn_xt_compatible filter design and defect enumeration | completed | high (95%) |
| B | Alternatives: VecEADecomp wiring path and arity-climbing induction | completed | medium-high (depth-0), low (k+1) |
| C | Critic: soundness analysis, depth boundary, adversarial self-verification | completed | very high for depth-0; 5% for k+1 bypass |
| D | Horizons: strategic impact, axiom fallback, downstream task analysis | completed | high (90%) |

## References

- `KampBypass.lean` -- primary implementation file, 13 `ssn_xt_compatible` call sites, 10 active sorries
- `VecEADecomp.lean` -- 898 lines, 0 sorries, complete zone theorem coverage
- `NfComposition.lean:18-37` -- counterexample refuting `generalized_composition`
- `NegationClosure.lean:1716` -- `nf_exist_formula_nested_backward` (parallel blocker path)
- `NfCharFormula.lean:541` -- `nf_characterizable_temporal_prior` succ k sorry (critical path)
- `ChronicleToCountermodel.lean:537` -- `chronicle_gap_contradiction` sorry (critical path)
- Rabinovich 2014 (Section 5) -- composition argument for Prior structures (not yet formalized)
- GHR94 Chapter 10 -- Q-lemma technique for mixed past/future elimination
- Plan v29 -- most recent implementation plan (VecEA Path B with arity-climbing induction)
