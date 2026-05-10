# Research Report: IsSuccArchimedean for Discrete Completeness (Team Round 2)

- **Task**: 118 - Prove IsSuccArchimedean for discrete completeness branch
- **Status**: Research complete
- **Type**: lean4
- **Mode**: Team Research (4 teammates)
- **Date**: 2026-05-09
- **Session**: sess_1778370740_24df9f
- **Artifacts**: reports/02_team-research.md (this file)
- **Prior Research**: reports/01_issucc-archimedean-research.md (round 1)

## Executive Summary

Four parallel research agents investigated the IsSuccArchimedean sorry from complementary angles. The synthesis identifies **two viable proof strategies** and definitively closes six bypass alternatives. The NO-GO conclusion from task 117 Phase 6 is **partially overturned**: the "L ∈ limit_dom" case of the dual-chain argument gives a genuine contradiction (new finding), but the "L ∉ limit_dom" case remains the core obstacle requiring omega chain structural analysis.

**Key convergent finding**: All four teammates independently concluded that bypassing IsSuccArchimedean (removing AddCommGroup, dual completeness theorems, LocallyFiniteOrder, quotient constructions) is infeasible. The sorry must be proved directly.

**Two viable strategies identified**:

1. **Birth-monotonicity** (Teammates A, B, D converge): Show `birth(succ_limitdom(z)) > birth(z)` for `z` between consecutive dom_N elements, using `witness_not_old` from `C5ForwardWalkResult`. WF measure: `birth(q) - birth(current)`. Requires proving the C5 witness for `U(⊤, ⊥)` is exactly `succ_limitdom(z)`.

2. **Dual-chain contradiction** (Teammate C, new): Use both `succ^n(p)` ascending and `pred^m(q)` descending chains. When the ascending limit L ∈ limit_dom, `pred(L)` gives an immediate contradiction. When L ∉ limit_dom, the two chains converge from opposite sides and must eventually meet — but proving this requires omega chain structure.

## Synthesis of Findings

### Confirmed Dead Ends (All 4 Teammates Agree)

| Alternative | Verdict | Key Evidence |
|-------------|---------|--------------|
| IsPredArchimedean equivalence | DEAD END | Equivalent to IsSuccArchimedean (Mathlib `isSuccArchimedean_iff_isPredArchimedean`). Same WF obstacle. |
| Remove AddCommGroup from `valid` | DEAD END | Required by soundness of 6+ axioms (MF, TF, discrete_symm/propagate). Would break 30 files. |
| LocallyFiniteOrder pathway | DEAD END | Circular: constructing `LocallyFiniteOrder` requires finite intervals = IsSuccArchimedean. |
| Quotient by succ-orbits | DEAD END | "Exactly one orbit" IS IsSuccArchimedean. |
| OrderEmbedding into ℤ | DEAD END | Until/Since coherence fails across orbit boundaries. |
| Dual completeness theorems | DEAD END | Uniformity axioms not sound on arbitrary linear orders. |

### Conflict Resolution

**Conflict: Is the NO-GO conclusion correct?**
- Teammate A: Confirms guard-sealing alone is insufficient for finiteness. Real analysis has a gap. (Supports NO-GO for simple approaches.)
- Teammate C: The NO-GO is premature — the pred(q) dual-chain argument is genuinely new and was not tried. The "L ∈ S" case gives a real contradiction.
- Teammate D: All 6 WF measures fail. Birth-monotonicity is the most promising remaining approach.

**Resolution**: The NO-GO stands for the specific approaches tried (6 WF measures, formula counting). It does NOT cover the dual-chain argument (new) or birth-monotonicity (newly refined). The problem is still open for these approaches.

**Conflict: Birth-monotonicity — is `birth(succ(z)) > birth(z)` actually true?**
- Teammates B, D assert it follows from `witness_not_old`.
- Teammate A notes birth-stage non-monotonicity for `pred`: `birth(pred(x)) > birth(x)` IS possible.

**Resolution**: The claim is about `succ`, not `pred`. For `succ`, the argument is: when the C5 counterexample for `U(⊤, ⊥)` at `z` is processed at stage `s ≥ birth(z)`, the witness is NEW (`witness_not_old`), so `birth(witness) > birth(z)`. The key question is whether this witness IS `succ_limitdom(z)` or could be farther away. If the witness is beyond `succ_limitdom(z)`, then birth-monotonicity of `succ` still holds (since `succ_limitdom(z)` is below the witness and must have been born at some stage between `birth(z)` and `birth(witness)`). **This needs formalization verification but is mathematically plausible.**

### New Insights Not in Prior Research

1. **Condition (i) for U(⊤, ⊥) is NEVER satisfied** (Teammate C): The C5 walk condition (i) requires `⊥ ∈ g(pt, x')`, which is impossible since g-values are deductively closed sets (consistent). So the walk ALWAYS takes the split case, inserting the midpoint `(x + x')/2`. This gives `succ_limitdom(z)` a specific geometric structure.

2. **The "L ∈ limit_dom" case has a clean proof** (Teammate C): If the ascending succ-chain `succ^n(p)` converges to L ∈ limit_dom, then `pred(L)` exists with `(pred(L), L) ∩ limit_dom = ∅`. But for large n, `succ^n(p) > pred(L)`, giving `succ^n(p) ∈ (pred(L), L) ∩ limit_dom` — contradiction. This is pure order theory, ~30 lines of Lean.

3. **Two-orbit counterexample is misleading** (Teammate C): The abstract counterexample from report 01 is consistent with C0-C5 as conditions but CANNOT arise from the omega chain construction (which starts from singleton `dom_0 = {0}`). The construction's connectivity prevents disconnected orbits.

4. **AddCommGroup is structurally necessary** (Teammates B, D independently confirm): Not just an implementation choice — the BX axiom system's uniformity axioms require group structure for soundness. Burgess's paper uses a different axiom system (without uniformity axioms).

### Gaps Identified

1. **Birth-monotonicity formalization**: Whether `witness_not_old` + the specific C5 walk for `U(⊤, ⊥)` formally implies `birth(succ_limitdom(z)) > birth(z)` has not been verified in Lean. The mathematical argument is plausible but the Lean infrastructure (extracting birth stages from the omega chain, relating C5 walk witnesses to limit-domain successors) may require 50-100 lines of lemmas.

2. **The "L ∉ limit_dom" case**: All four teammates acknowledge this as the genuine hard case. The most promising approaches:
   - Birth-monotonicity gives a WF measure that avoids this case entirely (by induction on `birth(q) - birth(current)` in the gap)
   - The dual-chain argument needs omega chain structure to close this case
   - The "sealed interval compactness" argument (total length of sealed intervals = q - p) could work but needs careful formalization

3. **Connection between C5 walk witness and `succ_limitdom`**: The C5 walk produces a witness `y > z`. This witness becomes `succ_limitdom(z)` only if no OTHER insertion between `z` and `y` occurs at a later stage. Proving this requires showing that once the interval `(z, y)` is sealed by `⊥ ∈ g(z, y)`, no future insertion can place a point there — which IS the guard-sealing property, already proven for the limit domain.

## Recommended Strategy

### Primary: Birth-Monotonicity Induction

**Why**: Avoids real analysis, avoids the "L ∉ limit_dom" gap, provides a concrete WF measure, and uses construction-specific properties.

**Proof sketch**:

```
Given a ≤ b in LimitDomSubtype, show ∃ n, succ^[n] a = b.
1. Get stages: a.val ∈ dom_{na}, b.val ∈ dom_{nb}, set N = max na nb
2. Induction on |dom_N ∩ (a.val, b.val]| (number of dom_N points in the interval)
3. Base case: |dom_N ∩ (a.val, b.val]| = 0 implies a = b (since b.val ∈ dom_N)
4. Step: pred(b) exists, a ≤ pred(b), succ(pred(b)) = b
   - If pred(b).val ∈ dom_N: |dom_N ∩ (a.val, pred(b).val]| < |dom_N ∩ (a.val, b.val]| ✓
   - If pred(b).val ∉ dom_N: NEED ALTERNATIVE DESCENT
5. For the pred(b) ∉ dom_N case, use "gap lemma":
   Find the consecutive dom_N elements p, q containing pred(b) (i.e., p < pred(b) < q ≤ b)
   In this gap, prove succ^[k](p) = q by birth-monotonicity:
   - Each succ step in (p, q) increases birth stage (witness_not_old)
   - WF measure: birth(q) - birth(current) is a Nat that decreases
   Once succ^[k](p) = q, combine with the outer induction
```

**Estimated effort**: 150-250 lines of Lean. Phase 1 (dom_N induction framework) ~50 lines. Phase 2 (birth-monotonicity lemma) ~80 lines. Phase 3 (gap lemma + combination) ~70 lines.

### Fallback: Dual-Chain + Real Analysis

If birth-monotonicity cannot be formalized (e.g., the connection between C5 walk witness and `succ_limitdom` is too complex):

1. Prove the "L ∈ limit_dom" case (~30 lines, pure order theory)
2. For "L ∉ limit_dom", use the dual-chain convergence to derive a contradiction from the omega chain's surjectivity-above property (~100+ lines)

### Research Questions for Planning Phase

Before proceeding to implementation:

1. **Verify birth-monotonicity in Lean**: Use `lean_goal` and `lean_hover_info` to check whether `C5ForwardWalkResult.witness_not_old` gives the right form for concluding `birth(succ_limitdom(z)) > birth(z)`.

2. **Check the gap between C5 walk witness and limit-domain successor**: The C5 walk at stage `s` produces a witness in `dom_{s+1}`. This witness might not be `succ_limitdom(z)` — it could be farther. Need to verify that the guard-sealing property ensures the C5 witness IS the immediate successor in the limit.

3. **Assess whether birth stages are extractable**: The `LimitDomSubtype` membership proof `⟨n, hn⟩` gives a stage where the point appears, but `birth(x)` is the MINIMUM such stage. Lean would need `Nat.find` to extract the minimum. Check if this is practical.

## Teammate Contributions

| Teammate | Angle | Status | Confidence | Key Contribution |
|----------|-------|--------|------------|------------------|
| A | Guard-sealing formalization | completed | Low-Medium | Confirmed guard-sealing insufficient alone; identified real-analysis gap |
| B | Alternative bypass paths | completed | High | Definitively closed all 6 bypass alternatives |
| C | Critic / blind spots | completed | High | New dual-chain argument; pred(q) reduction; "L ∈ S" case proof |
| D | Strategic / mathematical | completed | High | Confirmed AddCommGroup necessary; birth-monotonicity convergence |

## Next Steps

- `/plan 118` to create implementation plan based on birth-monotonicity strategy
- Focus planning on: (1) birth stage extraction infrastructure, (2) C5 walk witness = succ_limitdom lemma, (3) gap lemma via birth induction, (4) integration with dom_N outer induction
