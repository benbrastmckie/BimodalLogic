# Research Report: Task #107 — Burgess Inconsistent Case Analysis

**Task**: 107 - chain_design_diagnostics_for_representation_theorem
**Date**: 2026-05-05
**Mode**: Team Research (4 teammates)
**Session**: sess_1777987733_074c81

## Summary

Unanimous finding: the inconsistent-case split is a **formalization artifact** caused by `SetDeductivelyClosed` requiring consistency (diverging from Burgess 1982 who defines DCS as only deductively closed). Burgess never encounters this case because his R-maximality quantifies over ALL DCSs including inconsistent ones (Set.univ). The `irr_until` axiom `G(φ.neg) → (untl(φ,ψ)).neg` is **unsound for discrete orders** and must NOT be added. The recommended path is to proceed with Phases 3-7 (independent) while resolving Phase 2 via structural alignment with Burgess.

## Key Findings

### 1. Burgess Never Case-Splits on Consistency (Unanimous)

Burgess Section 1.3: "A is *deductively closed* if it contains all its consequences." No consistency requirement. His R-maximality (Section 2.3) says: "whenever R(A,B,C) holds and δ∉B... else consider B' = consequences of B∪{δ}." When {δ}∪B is inconsistent, consequences = Set.univ which IS a DCS in his framework. The maximality witness exists unconditionally.

### 2. irr_until Axiom is Unsound for Discrete Orders (Unanimous)

Under open-guard semantics: `untl(φ,ψ)` at t on discrete orders requires only ψ at t+1 (empty intermediate interval makes guard vacuous). So `G(φ.neg)` at t does NOT prevent `untl(φ,ψ)` when the open interval (t,t+1) is empty. The axiom restricts to dense orders only — unacceptable for general completeness.

### 3. The Circular Problem (from Teammate C)

- `ClosedUnderDerivation` maximality → witness exists always → but Zorn proof breaks (can't prove maximality over inconsistent sets from Zorn over consistent ones)
- `SetDeductivelyClosed` maximality → Zorn proof works → but witness only in consistent case → pos sub-case stuck

### 4. Teammate A's Key Claim (Requires Verification)

Teammate A argues: when β₀∧δ → ⊥, the formula `U(γ₀, β₀∧δ)` in Burgess puts β₀∧δ in the EVENT (endpoint) position, making it unsatisfiable (no point satisfies ⊥). If correct, `~U(γ₀, β₀∧δ)` is a thesis derivable via BX10 contrapositive + right-mono, giving the witness trivially.

**Convention issue**: This depends on whether Burgess's second argument of U is the event (endpoint) or guard (intermediate). The project convention `untl(guard, event) = U(event, guard)` implies argument positions are swapped. If β₀∧δ maps to our code's first arg (guard), it's satisfiable on discrete orders. If it maps to our second arg (event), it's unsatisfiable. This needs verification against the actual Lean proof state.

**Verification path**: Check whether `(untl (β₀ ∧ δ) γ₀).neg` can be derived as a theorem in the BX system using BX10 + BX3. If BX3 acts on the second arg (our "event") and β₀∧δ is in that position, the derivation works.

### 5. Strategic Recommendation (from Teammate D)

- Skip ahead to Phases 3-7 (close 9 more sorries, independent of Phase 2)
- Avoid irr_until axiom (breaks discrete compatibility)
- Structural fix (redefining DCS) is highest-value but complex
- Sorry count can go from 11 → 2 without resolving Phase 2

## Synthesis

### Conflicts Resolved

| Conflict | Resolution |
|----------|-----------|
| irr_until axiom viability | All agree: unsound for discrete, don't use |
| Whether to skip ahead | Unanimous: Phases 3-7 are independent, proceed |
| Teammate A's event-position claim | UNRESOLVED: needs Lean verification |

### Gaps Identified

1. **Convention verification**: The exact position of β₀∧δ in the code's untl encoding needs checking against lean_goal at the sorry site
2. **Direct seed consistency**: Teammate B's suggestion that the inconsistent case seed consistency can be proved WITHOUT the neg-until witness (using burgessR3 membership directly) has not been verified in Lean
3. **Zorn-maximality-implies-MCS**: If burgessR3(A, Set.univ, C) → every consistent DCS satisfies r → Zorn-maximal B is MCS → the inconsistent-case split may be eliminable by proving B is always MCS

### Recommendations

**Immediate** (high confidence):
1. Proceed with Phases 3-7 via `/implement 107` (skipping Phase 2)
2. This reduces sorry count from 11 → 2

**For Phase 2 resolution** (needs verification):
1. Check Teammate A's claim: verify in Lean whether `(untl (β₀∧δ) γ₀).neg` or `(untl γ₀ (β₀∧δ)).neg` can be derived as a theorem
2. If yes: the pos sub-case contradicts the MCS property of A (A can't contain both untl and its negation)
3. If no: restructure to prove seed consistency directly from burgessR3 membership (Teammate B's approach)

## Teammate Contributions

| Teammate | Angle | Status | Confidence |
|----------|-------|--------|------------|
| A | Burgess paper analysis | completed | medium (convention claim needs verification) |
| B | Alternative approaches | completed | high |
| C | Critic | completed | high |
| D | Strategic horizons | completed | high |
