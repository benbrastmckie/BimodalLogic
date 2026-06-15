# Research Report: Task #273 — Encoding Fix for Between-Zone Witnesses

**Task**: chronicle_gap_contradiction_proof
**Date**: 2026-06-15
**Mode**: Team Research (4 teammates)
**Focus**: Resolve the x-sharing question for nested Until encoding; study prior art for correct proof strategy

## Summary

The team unanimously converges on **BracketFormula k > 0** (where k = number of positive between_tx SSNs) as the correct fix. The nested Until approach (Approach A from the handoff) is definitively ruled out — independent per-SSN Until chains each quantify their own endpoint, breaking the x-sharing that VecEA2.holdsLeft provides. The critical insight is that BracketFormula k and nested Until are the SAME construction at the infrastructure level: `VecEA2.translateLeft` calls `bracketBuildRight` which converts BracketFormula k into nested Until formulas automatically.

The backward direction sorting problem (ordering arbitrary witnesses into strictly increasing sequence) is feasible via Mathlib's `Tuple.sort` + `Monotone.strictMono_of_injective`, and the `nf_y_proj` injectivity gap is closeable with a ~15-30 line lemma.

## Key Findings

### 1. x IS Shared by VecEA2.holdsLeft — But Only Within the VecEA2 Framework (Teammate A)

`VecEA2.holdsLeft` (VecEATranslation.lean:250-256) uses a **single existential `z1`**. All conditions in `endpointRight` must hold at this same `z1`. Within a single disjunct of `enriched_bypass_until` (fixed `nf_x`), x is semantically shared across all positive between_tx SSNs by the VecEA2 framework, not by any property of the temporal formula.

**The x-sharing question is resolved**: x sharing is guaranteed by the VecEA2 structure. The problem was never x-sharing — it was that the Since-at-endpoint encoding loses the lower bound `t < y`.

### 2. Nested Until (Approach A) Definitively Ruled Out (Teammates A, B, C)

Three independent lines of reasoning eliminate Approach A:

- **Teammate A**: Independent per-SSN nested Until chains each quantify their own innermost endpoint `x'_i`. A conjunction of chains gives `x'_1, x'_2, ...` with no guarantee they equal each other or the outer x from VecEA2.holdsLeft.
- **Teammate B**: `endpointLeft` is evaluated at t BEFORE the existential witness `z1` (= x) is chosen. Any formula in endpointLeft cannot reference x. So bounded Untils in endpointLeft cannot enforce `y < x`.
- **Teammate C**: The nested Until introduces a FRESH existential `x'` that is NOT guaranteed to equal the outer `x`. Additionally, replacing VecEA2 with direct formula construction breaks `VecEA2.translateLeft_correct` (~300 lines of proven infrastructure would need rewriting).

### 3. BracketFormula k > 0 IS the Correct Fix (All Teammates)

The bracket is the ONLY structure with access to both endpoints t and x. `IntervalPattern.holds` (ExistsForallNF.lean:106-132) requires:
- k strictly ordered witnesses in (t, x) — providing both bounds
- Point type conditions at each witness — encoding char_y for each SSN
- Segment guard between consecutive witnesses — the existing seg_guard

**Critical realization (Teammate B)**: BracketFormula k and nested Until are the SAME thing. `VecEA2.translateLeft` calls `bracketBuildRight` which converts BracketFormula k into:
```
seg_guard Until (char_y₁ AND seg_guard Until (char_y₂ AND ... Until (char_1(nf_x))))
```
So the Rabinovich 2014 construction (Prop 3.5) is already implemented by the existing VecEA2 translation machinery.

### 4. Sorting Lemma Is Feasible (Teammate B)

Mathlib provides the required tools:
- `Tuple.sort` (Mathlib.Data.Fin.Tuple.Sort): gives permutation `σ` such that `f ∘ σ` is monotone
- `Monotone.strictMono_of_injective` (Mathlib.Order.Monotone.Defs): injective + monotone = strictly monotone
- `Finset.orderEmbOfFin` (Mathlib.Data.Finset.Sort): direct strictly monotone enumeration of a finset

At depth 0, witnesses for distinct SSNs are necessarily distinct (different predicate patterns at the witness point), so injectivity holds.

### 5. nf_y_proj Injectivity IS Closeable (Teammate C)

Within a single `enriched_vecEA2_until` call (fixed `nf_x`):
- `ssn_xt_compatible` fixes x-atoms (matching `nf_x_1var`) and t-atoms (matching `parent_atoms`)
- The `between_tx` zone fixes ordering bits
- Only y-atom bits vary between distinct SSNs

Therefore `nf_y_proj` is injective on `pos_between` within a fixed disjunct. This requires a ~15-30 line lemma proving that two SSNs differing only in y-atoms produce different `nf_y_proj` values.

### 6. Since Direction Is NOT a Simple Mirror (Teammate C)

The Since case (L512-594) uses `formula_disjList` directly with `Formula.snce pt_x guard` — there is NO bracket/VecEA2 machinery. The fix approach will differ structurally from the Until case:
- Until fix: change BracketFormula 0 to BracketFormula k within VecEA2
- Since fix: either introduce VecEA2/bracket into the Since path, or construct a bounded temporal encoding directly

**Recommendation**: Fix Until first to establish the correct pattern, then determine the Since approach. Report 35's phase ordering (Since first) is reversed.

### 7. Strategic: lean_verify Results May Be Stale (Teammate D)

`lean_verify` reports `kamp_prior_expressive_completeness` and `completeness_discrete` as sorry-free, which contradicts the known sorries in their constituent lemmas. This is likely due to cached build artifacts. A fresh `lake build` is needed to establish true axiom status.

Additional findings:
- Task "202" referenced in ROADMAP.md is actually **task 268** (status: [RESEARCHED])
- No alternative completeness path exists — WeakCanonical Chronicle is the only viable route
- NegationClosure.lean:1716 (`nf_exist_formula_nested_backward`) is an independent blocker not addressed by this task
- BXCanonical is dead code with ~17 provably false sorries

## Synthesis

### Conflicts Resolved

No genuine conflicts between teammates. All converge on BracketFormula k > 0 as the correct approach. Minor differences in framing:
- Teammate C emphasizes "disjunction PointTypes" (Report 35 terminology) while A and B say "BracketFormula k" — these are the same construction (BracketFormula k where each pointType is a single SSN characteristic, or equivalently a disjunction of characteristics as Report 35 proposes)
- Teammate D's verify discrepancy does not change the technical recommendation — the sorries need closing regardless of cached build state

### Gaps Identified

1. **Alpha assignment strategy**: When constructing BracketFormula k, need to decide how to assign point types (alpha) to bracket positions. Two sub-options:
   - (a) Each alpha_i = char_y(ssn_i) for a fixed enumeration of positive between_tx SSNs. Forward direction extracts one SSN per witness. Backward direction must sort witnesses to match the enumeration order. **Simpler but requires the nf_y_proj injectivity lemma.**
   - (b) Each alpha_i = disjunction of all char_y values (Report 35 "disjunction PointTypes"). Forward direction gets any char_y at each witness, then uses pigeonhole + mutual exclusivity to assign SSNs. Backward direction is simpler (any char_y satisfies the disjunction). **More robust but forward proof is more complex.**

2. **Segment type (beta) construction**: The seg_guard currently guards (t, x) universally. With k bracket witnesses, seg_guard needs to guard each segment (t, y₁), (y₁, y₂), ..., (yₖ, x). Since seg_guard is a universal property (no positive between_tx SSN satisfied), it holds on all subintervals of (t, x). This needs a small subinterval lemma.

3. **Since direction approach**: Not resolved by this research. Options: (a) introduce VecEA2 bracket into Since path, (b) construct direct nested Since formula, (c) use an existing Since-direction translation. Needs its own investigation after the Until fix is validated.

4. **Fresh lake build**: Needed to resolve the verify discrepancy and confirm KampBypass work is on the critical path.

### Recommendations

1. **Change `enriched_vecEA2_until` to return `VecEA2 k`** (not `VecEA2 0`) where k = `pos_between.length`
2. **Each bracket point type** = `char_y(ssn_i)` for the i-th positive between_tx SSN (option (a) above — simpler, injectivity is closeable)
3. **Each bracket segment type** = `seg_guard` (same as current)
4. **Remove** `Formula.snce char_y Formula.top` from endpointRight for positive between_tx SSNs
5. **Prove nf_y_proj injectivity** on pos_between within a fixed disjunct (~15-30 lines)
6. **Prove witness sorting** for backward direction using `Tuple.sort` + `Monotone.strictMono_of_injective` (~30-50 lines)
7. **Prove seg_guard subinterval** lemma (~10-15 lines)
8. **Forward direction** becomes straightforward: bracket witnesses are in (t, x) with correct point types by construction
9. **Fix Until first**, then determine Since approach
10. **Run fresh `lake build`** to confirm critical path status

## Teammate Contributions

| Teammate | Angle | Status | Confidence |
|----------|-------|--------|------------|
| A | Primary: nested Until design + x-sharing | completed | HIGH |
| B | Alternatives: BracketFormula k, hybrid, direct Formula | completed | HIGH |
| C | Critic: soundness, gaps, boundary cases | completed | HIGH |
| D | Horizons: sorry chain, strategic direction, scope | completed | HIGH |

## References

- Rabinovich 2014, Proposition 3.5 / Corollary 5.4: nested Until construction for between-zone witnesses
- GHR93/94: original Kamp proof structure
- Report 35 (specs/273_chronicle_gap_contradiction_proof/reports/35_team-research.md): disjunction PointTypes approach
- Report 36 (specs/273_chronicle_gap_contradiction_proof/reports/36_literature-bracket-proof.md): bounded Until approach (ruled out by this research)
- VecEATranslation.lean:250-256: VecEA2.holdsLeft definition (single existential z1)
- VecEATranslation.lean:246-247: VecEA2.translateLeft using bracketBuildRight
- ExistsForallNF.lean:106-132: IntervalPattern.holds (strict ordering requirement)
- Mathlib.Data.Fin.Tuple.Sort: Tuple.sort for witness ordering
- Mathlib.Order.Monotone.Defs: Monotone.strictMono_of_injective
