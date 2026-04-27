# Phase 1.2 Handoff: D0 Seed Consistency (`burgess_D0_consistent`)

## Session
- Session ID: `sess_1777330399_eee36d`
- Date: 2026-04-27

## Summary

Extensive analysis of the `burgess_D0_consistent` proof at line 825 of PointInsertion.lean. The proof requires a non-trivial BX axiom chain to replace Burgess's A3a + A4a axioms, complicated by a guard/event convention mismatch between Burgess 1982 and our code.

## The Problem

`burgess_D0_consistent` must show: `SetConsistent (burgess_D0 A B C delta)` given `BurgessR3Maximal A B C`, `delta not in B`, and A, C are MCS.

D0 = {S(beta,alpha) : alpha in A, beta in B} union B union {neg(delta)} union {U(beta,gamma) : beta in B, gamma in C}

## Convention Mismatch (Key Finding)

**Burgess 1982**: `r(A, B, C)` means for all beta in B, gamma in C: `U(gamma, beta) in A`. Here gamma (from C) is the GUARD and beta (from B) is the EVENT.

**Our code**: `burgessR3 A B C` means for all beta in B, gamma in C: `U(beta, gamma) in A`. Here beta (from B) is the GUARD and gamma (from C) is the EVENT.

This means:
- Burgess: B provides EVENTS, C provides GUARDS
- Our code: B provides GUARDS, C provides EVENTS

The roles are swapped in the first and second argument of `Formula.untl`.

### Impact on Axiom Chain

Burgess uses:
1. **A5a** (event-side self-accumulation): `U(guard, event) -> U(guard, event AND U(guard, event))` -- enriches the EVENT (B-side)
2. **A4a**: `U(guard, event) AND not U(guard, event AND chi) -> U(event AND not chi, event)` -- enriches the new GUARD using event-side negation

Our BX system has:
1. **BX5** (guard-side self-accumulation): `U(guard, event) -> U(guard AND U(guard, event), event)` -- enriches the GUARD (B-side)
2. **No A4a equivalent** for GUARD-side negation

Both A5a and BX5 enrich the B-side, which is correct. But A4a's role is to bring `not chi` into the formula using the failure of the event-side extension. In Burgess: the maximality gives `not U(gamma, beta AND delta)` (event extension fails). A4a then uses this to enrich the GUARD.

In our code: the maximality gives `not U(beta AND delta, gamma)` (GUARD extension fails). There is NO corresponding axiom that uses guard extension failure to enrich the guard further.

Specifically:
- A4a: `U(p,q) AND not U(p, q AND r) -> U(q AND not r, q)` -- uses EVENT extension failure
- Needed: something from `U(p,q) AND not U(p AND r, q) -> ???` -- uses GUARD extension failure
- This is NOT valid under half-open guard semantics (counterexample: delta fails at base point t only)

## Partial Results Established

### Lemma: Guard Strengthening from G(delta)

If `delta in A` and `G(delta) in A` and `U(beta, gamma) in A`, then `U(beta AND delta, gamma) in A`.

Proof: Use BX2 with the implication `beta -> beta AND delta` (derivable since delta in A at base) and `G(beta -> beta AND delta)` (derivable from G(delta) via temporal K-distribution).

### Consequence: F(neg delta) in A in Case 2

From `U(beta, gamma) in A` and `not U(beta AND delta, gamma) in A`:
- If `delta in A` AND `G(delta) in A`: by guard strengthening, `U(beta AND delta, gamma) in A`. Contradiction.
- So if `delta in A`: `G(delta) not in A`, hence `neg G(delta) in A`, which is logically equivalent to `F(neg delta) in A` (after double-negation handling through MCS).

### Case Split

The proof splits into:
- **Case 1**: `delta not in A` (so `neg delta in A`): Every D0 element is in A union C.
- **Case 2**: `delta in A` but `G(delta) not in A` (so `F(neg delta) in A`).

### Case 1 Analysis

When neg delta in A: all B-elements and Until formulas are in A, all Since formulas are in C, and neg delta is in A. So D0 subset A union C.

**Blocker**: A union C being consistent is NOT guaranteed (different MCS can have contradictory elements). The consistency of D0 requires showing that the SPECIFIC elements from A (B elements + Until formulas + neg delta) are compatible with the SPECIFIC elements from C (Since formulas).

This requires the "each zeta = S(beta,alpha) AND beta AND neg delta AND U(beta,gamma) is consistent" argument, which needs the A3a/A4a chain.

### Case 2 Analysis  

When F(neg delta) in A: by BX12, `U(top, neg delta) in A`. Applying BX7 to `U(beta AND U(beta,gamma), gamma)` (from BX5) and `U(U(top, neg delta), neg delta)` (from BX5 on the F-derived Until):

Three disjuncts D1, D2, D3. D3 gives F(beta AND neg delta) in A (via BX10 + event weakening). D1 gives U(big_guard, gamma AND neg delta) in A. D2 gives no new info.

**Blocker**: Cannot FORCE D2 not in A (D2 weakens to U(beta, gamma) which IS in A). So from a single BX7 application, we can't guarantee F(beta AND neg delta).

A SECOND BX7 application using D1 as input might give F(beta AND neg delta) via D3', but again D2' (= U(beta AND U(beta,gamma), gamma)) is already in A and can't be eliminated.

## Proposed Resolution Approaches

### Approach A: Direct Maximality Contradiction (Most Promising)

Instead of following Burgess's single-formula consistency argument, prove D0 consistent by contradiction: if L subset D0, L derives bot, then use the derivation to construct a proper DCS extension of B satisfying burgessR3, contradicting maximality.

The key insight: from L derives bot with neg delta in L, by deduction theorem L' derives delta (where L' = L minus neg delta). Each element of L' is in A union C. If we can show that the derivation factors through B in a suitable way, we get delta in DC(B-related things), hence delta in some extension of B.

This would avoid the A4a issue entirely but requires careful handling of the cross-MCS derivation.

### Approach B: Swap Convention

Change `burgessR3` to put B on the event side (matching Burgess). This would make A4a applicable (or rather, its BX7-based substitute). However, this is a massive refactor touching all of RRelation.lean, PointInsertion.lean, and downstream files.

### Approach C: Prove A4a-Guard Variant from BX

Derive: `U(beta, gamma) AND not U(beta AND delta, gamma) -> something_useful`.

The semantic content under half-open guard: delta fails at some point in [t,s). If at the base point t: neg delta in A directly. If at a strict future point: F(beta AND neg delta) in A (since beta holds throughout [t,s) and neg delta at the failure point).

This DISJUNCTION (neg delta in A OR F(beta AND neg delta) in A) might be derivable from BX axioms. Need to check.

### Approach D: Use Half-Open Guard Strength

Under half-open guard, until_guard gives `beta in A` directly (stronger than Burgess). This might enable a simpler consistency argument not available in Burgess's reflexive setting.

## Recommendation

**Approach A** (direct maximality contradiction) seems most promising. It avoids the convention mismatch entirely and uses the maximality structure directly.

**If stuck on A**: consider **Approach C** (disjunction neg delta in A OR F(beta AND neg delta) in A) combined with the case-split analysis.

**Approach B** (convention swap) is a last resort due to refactor cost.

## File State
- `PointInsertion.lean`: 827 lines, 1 sorry (`burgess_D0_consistent` at line 825)
- All other theorems remain sorry-free
- `lake build` passes (with the sorry)
