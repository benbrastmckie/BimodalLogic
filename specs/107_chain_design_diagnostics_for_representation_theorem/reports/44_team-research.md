# Research Report: Task #107 -- A4a Axiom Derivability and Alternatives

**Task**: 107 - Burgess chronicle construction for BX representation theorem
**Date**: 2026-04-28
**Mode**: Team Research (4 teammates)
**Session**: sess_1777439842_f085ea

## Summary

A4a (`U(p,q) AND NOT U(p,r) -> U(q AND NOT r, q)` in Burgess convention U(event, guard)) is **semantically valid under open-guard semantics** (Teammate A's proof is correct) but **NOT derivable from existing BX axioms** (5 strategies attempted, all fail). The formula can be added as a new sound axiom, OR avoided entirely via Xu's 1988 alternative construction (Teammate B's finding). Xu's Lemma 2.4 provides the full splitting without A4a, using only BX1/BX2 + BX13 — infrastructure already available in the codebase.

**Critical conflict resolved**: Teammate C's countermodel was based on an incorrect convention (treating Burgess U(α,β) as U(guard, event) when Burgess actually uses U(event, guard) per the paper's definition at line 39: `V(U(α,β)) = {x : ∃y(x<y ∧ y∈V(α) ∧ ∀z(x<z<y ⊃ z∈V(β)))}`). Under the correct convention, C's countermodel does not satisfy the antecedent.

## Key Findings

### 1. A4a Convention and Validity (Conflict Resolved)

**Burgess convention** (from Section 1.2 of the paper): `U(α,β)` means α at the witness (EVENT), β throughout the interval (GUARD). Equivalently: `V(U(α,β)) = {x : ∃y(x<y ∧ y∈V(α) ∧ ∀z(x<z<y ⊃ z∈V(β)))}`. Confirmed by `F(α) = U(α,⊤)` — α is the event.

**BX convention**: `untl(guard, event)` — arguments SWAPPED from Burgess. So Burgess `U(p,q)` = BX `untl(q,p)`.

**A4a in BX convention**: `untl(q,p) AND NOT untl(r,p) -> untl(q, q AND NOT r)`

**Teammate A's semantic proof** (verified correct):
1. From `untl(q,p)` at t: witness s0 > t with p(s0), guard q on (t,s0)
2. From `NOT untl(r,p)` at t applied to s0: since p(s0), ∃u0 ∈ (t,s0) with NOT r(u0)
3. u0 ∈ (t,s0) ⟹ q(u0) from step 1's guard
4. (q AND NOT r)(u0) holds
5. For v ∈ (t,u0): v ∈ (t,s0) ⟹ q(v) from step 1's guard
6. u0 witnesses `untl(q, q AND NOT r)` at t ∎

**Teammate C's error**: Evaluated `U(p,q)` with p=top as "top on the interval, q at the witness" — i.e., treated U(guard, event). Under Burgess's actual convention U(event, guard), their model has `U(top, {2})` requiring guard={2} on the interval, which fails at point 1. The antecedent is not satisfied.

**Verdict**: A4a IS semantically valid under open-guard semantics on all strict linear orders. It can be soundly added to the BX axiom system.

### 2. A4a Is NOT Derivable from Existing BX Axioms (Teammate A, unanimous)

Five derivation strategies attempted, all fail:
- **BX13 (enrichment)**: Adds Since content to the event, doesn't modify the guard
- **BX7 (linearity)**: Requires two positive Until formulas; NOT U(p,r) is negative
- **BX5+BX6 chain**: Fixpoint property, never changes guard position
- **Contrapositive**: Equally hard — requires going from guard q to guard r
- **Combined**: No BX axiom can substitute event formulas into the guard position

The fundamental obstacle: BX axioms operate on positive Until formulas; A4a's derivation requires extracting information from a negated Until (`NOT untl(r,p)`), which no BX axiom can destructure.

### 3. Two Viable Paths Forward (Teammates A, B)

**Path 1: Add A4a as a new axiom** (Teammate A)
- Add `separation_until` constructor to Axioms.lean
- ~30-line soundness proof using the semantic argument above
- Enables direct use of Burgess's Lemma 2.6 proof

**Path 2: Use Xu's Lemma 2.4 alternative** (Teammate B)
- Xu 1988 proves the same splitting result WITHOUT A4a
- Uses only axioms (1)-(4), corresponding to BX1/BX2 + BX13
- Construction: given R(A,B,C) with β not in B, extend B∪{¬β} to MCS D, then use Xu's Lemma 2.3 + Zorn for B' and B''
- Existing infrastructure `burgessR3Maximal_exists_from_seed` handles the Zorn step

### 4. All 9 Sorry Sites Are Interdependent (Teammate D)

No partial wins are available. The 7 CE c2' sorries feed transitively into the 2 FUC/FSC sorries. The g_content bridge approach is a dead end (loses Since direction). FUC/FSC cannot be closed independently.

## Synthesis

### Conflict Resolution

**Teammate A vs Teammate C**: Resolved in A's favor. The convention error is definitive — Burgess 1982 Section 1.2 explicitly defines `V(U(α,β))` with α at the witness (event) and β throughout (guard). Teammate C's countermodel uses the reversed convention and is therefore invalid.

### Recommended Path: Add A4a as New Axiom (Simpler) OR Xu Alternative (No New Axiom)

**Option 1 (Recommended for simplicity)**: Add A4a as `separation_until` axiom to BX system.
- Pros: Enables direct Burgess proof, minimal code changes, well-understood soundness
- Cons: Expands axiom system (but A4a is a natural temporal property)
- Effort: ~2 hours (axiom + soundness proof)

**Option 2 (Recommended for purity)**: Use Xu's Lemma 2.4 approach.
- Pros: No new axioms, uses only existing infrastructure
- Cons: More complex proof structure, less directly mapped to Burgess
- Effort: ~6-8 hours (new splitting lemma + proof)

Both paths are mathematically sound. Option 1 is faster and more directly corresponds to Burgess.

### Gap: Lemma 2.7 Does NOT Depend on A4a (Confirmed)

Lemma 2.7 uses only BX5 + BX7 + BX13 (no A4a). Phase 5a GATE verdict remains valid. C5 elimination via Lemma 2.7 is unblocked regardless of A4a decision.

## Teammate Contributions

| Teammate | Angle | Status | Confidence | Key Contribution |
|----------|-------|--------|------------|------------------|
| A | A4a derivability | completed | high | Proved A4a semantically valid; 5 derivation attempts all fail; convention mapping |
| B | Xu alternative | completed | high | Xu Lemma 2.4 avoids A4a entirely using BX1/BX2+BX13 |
| C | Critic | completed | medium* | Countermodel INVALID (wrong convention), but correctly identified Xu as alternative |
| D | Strategic assessment | completed | high | All 9 sites interdependent; g_content bridge dead end |

*Teammate C's countermodel analysis has a convention error, but their assessment of alternatives (Xu recommended) is correct.

## References

- Burgess 1982 Section 1.2: `V(U(α,β)) = {x : ∃y(x<y ∧ y∈V(α) ∧ ∀z(x<z<y ⊃ z∈V(β)))}` — α=event, β=guard
- Burgess 1982 Lemma 2.6: A4a used at exactly one point (step 5 of consistency proof)
- Xu 1988 Lemma 2.4: Full splitting without A4a, using axioms (1)-(4) only
- Reynolds 1992: "we are rid of the extra one" (confirming A4a removal)
- Handoff: `specs/107_.../handoffs/01_phase5-gate-complete.md`
