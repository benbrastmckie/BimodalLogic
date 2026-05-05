# Teammate D Findings: Strategic Horizons

## Key Findings

### 1. Axiom Economics: `G(φ.neg) → (untl(φ, ψ)).neg` is NOT Sound for All Linear Orders

This axiom says: "if φ is always false in the future, then U(φ, ψ) is false." Under **open-guard** semantics (`U(φ,ψ)` at t means ∃s>t: ψ@s ∧ ∀r(t<r<s → φ@r)), this axiom is:

- **Sound for DENSE strict linear orders**: In dense orders, between any two points there exists an intermediate. If φ is globally false, any witness s>t has an intermediate r with ¬φ@r, falsifying the guard.
- **Sound for ALL irreflexive strict linear orders**: Under open-guard semantics with strict `<`, even adjacent points satisfy the axiom because: if there exist NO intermediate points (adjacent), then the guard is vacuously true (∀r∈∅, φ@r). So U(φ,ψ) reduces to F(ψ). But G(φ.neg) means φ is false at ALL future points including s. Wait — G(φ.neg) says φ.neg at all strict future. But the guard is about intermediate points. If t and s are adjacent (no intermediates), the guard φ is vacuously satisfied. So `untl(φ, ψ)` is satisfiable even when G(φ.neg) holds: choose adjacent s with ψ@s, guard is vacuous. **UNSOUND for discrete orders with adjacent points.**
- **Sound for dense-only orders**: In dense orders, there's always an intermediate point where φ must hold, but G(φ.neg) ensures φ.neg at that point. Contradiction.

**Verdict**: This axiom restricts completeness to DENSE linear orders only. Adding it means the theorem becomes "completeness for dense strict linear orders" — NOT "all linear orders" as Burgess proves.

### 2. Skip-Ahead Strategy is STRONGLY Recommended

The dependency analysis shows:
- Phase 3 (Lemma 2.7) depends only on Phase 1 ✓ (completed)
- Phases 4-7 depend on Phase 3, NOT on Phase 2

This means Phases 3-7 can proceed independently of the Phase 2 blocker. Completing them would:
- Close 9 additional sorries (from 11 down to 2)
- Validate the entire downstream architecture
- Reduce the problem to a single localized 2-sorry blocker
- Provide confidence that the overall approach works

**Risk**: Phase 4 (c2' maintenance) may indirectly need the Phase 2 function if elimination call sites use `burgess_D0_finite_subset_consistent_incons`. But the plan states Phase 4 depends on Phases 2 AND 3, so this needs verification.

### 3. Publication Strategy Assessment

| Approach | Elegance | Generality | Risk | Publication Quality |
|----------|----------|-----------|------|-------------------|
| Add density axiom | Low | Restricts to dense orders | Low | Poor (excludes discrete/arbitrary) |
| Add irr_until axiom | Medium | Restricts to dense orders | Medium | Moderate (named axiom, clear semantics) |
| Delete inconsistent function (prove unreachable) | High | Full generality preserved | High | Excellent (if provable) |
| Redefine SetDeductivelyClosed (remove consistency) | High | Full generality preserved | Medium | Excellent (aligns with Burgess) |

The project README states completeness is for general linear orders. The Axioms.lean file explicitly notes: "All BX axioms are both dense and discrete compatible." Adding a density/irr_until axiom would **break this invariant** and narrow the result.

### 4. Risk Assessment: "Delete the Function" Approach

Probability the inconsistent case is unreachable: **Medium-High (60-75%)**

Reasoning:
- Burgess's proof (Section 2.6) never splits on consistency — he operates uniformly on DCSs
- The formalization's `SetDeductivelyClosed = SetConsistent ∧ ClosedUnderDerivation` is the root divergence
- If `BurgessR3Maximal_extension_fails` with `h_cons` is only called where `{δ}∪B` IS consistent (because the witness β comes from R-maximality over consistent DCSs, and the extension argument only produces consistent sets), the inconsistent branch is dead code
- The question reduces to: can `dc_delta_B_controlled` or its callers produce a β where `{β}∪B` is inconsistent?

## Recommended Approach

**Priority 1**: Immediately proceed with Phases 3-7 (close 9 sorries, validate architecture).

**Priority 2**: Investigate whether `SetDeductivelyClosed` can be redefined to NOT require consistency. This is the cleanest structural fix that:
- Aligns with Burgess's original framework
- Preserves full generality (all linear orders)
- Eliminates the inconsistent/consistent case split entirely
- Doesn't require new axioms

**Priority 3 (fallback)**: If redefining is too invasive, prove the inconsistent case is unreachable by tracing all call sites of the function and showing they always pass consistent extensions.

**Avoid**: Adding irr_until or density axioms. These narrow the completeness result and violate the project's stated invariant ("all BX axioms are both dense and discrete compatible").

## Evidence/Examples

- Axioms.lean:336: `/-- All BX axioms are dense-compatible (no discrete-only axioms in the base system). -/`
- Axioms.lean:340: `/-- All BX axioms are discrete-compatible (no density axiom in the base system). -/`
- BX8/BX9 were REMOVED because they were unsound under open guard — the project prioritizes semantic correctness over axiom count
- README claims "completeness" without qualification — not "completeness for dense orders"

## Confidence Level

**High** for the skip-ahead recommendation and axiom economics analysis.
**Medium** for the SetDeductivelyClosed redefinition approach (high reward but needs feasibility study of downstream impact on ~30k lines).
