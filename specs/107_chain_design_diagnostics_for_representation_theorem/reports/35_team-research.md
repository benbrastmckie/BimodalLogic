# Research Report: Task #107

**Task**: 107 - Burgess chronicle construction for BX representation theorem
**Date**: 2026-04-27
**Mode**: Team Research (1 of 4 teammates completed; 3 rate-limited)
**Session**: sess_1777333301_7ec1e7

## Summary

The "guard/event convention mismatch" identified in the Phase 1 D₀ consistency handoff is a **FALSE ALARM**. The previous implementation agent confused argument ORDER with semantic ROLE. In all three conventions (Burgess 1982, Xu 1988, and our code), B-elements serve as the GUARD in the Until formula. The only difference is whether event or guard comes first in the argument list — a purely notational distinction that does not affect the proof structure.

**No convention swap is needed.** The D₀ consistency proof should proceed using BX5+BX7 to derive the A4a-equivalent formula, exactly as the plan specifies.

## Key Findings

### 1. The Convention Mismatch Is a False Alarm (HIGH CONFIDENCE)

The handoff claimed: "Burgess: B provides EVENTS, C provides GUARDS" vs "Our code: B provides GUARDS, C provides EVENTS."

**This is wrong.** Verified line-by-line:

| Convention | Until notation | First arg | Second arg | B-element role |
|-----------|---------------|-----------|------------|----------------|
| Burgess 1982 | U(α,β) | EVENT (α at endpoint) | GUARD (β at intermediate) | **GUARD** |
| Xu 1988 | U(β,γ) | EVENT (β at endpoint) | GUARD (γ at intermediate) | **GUARD** |
| Our code | untl(φ,ψ) | GUARD (φ at intermediate) | EVENT (ψ at endpoint) | **GUARD** |

Burgess's `r(A, β, C) = ∀γ∈C, U(γ, β) ∈ A`: β (from B) is in the SECOND arg = GUARD position.
Our `burgessR(A, β, C) = ∀γ∈C, untl(β, γ) ∈ A`: β (from B) is in the FIRST arg = GUARD position.

**B is the guard in all conventions.** The argument positions are swapped (Burgess: event-first; ours: guard-first, following Kamp), but the semantic role is identical.

### 2. A4a Translates Correctly to Our Convention (HIGH CONFIDENCE)

Burgess A4a: `U(p,q) ∧ ¬U(p,r) → U(q∧¬r, q)` where p=event, q=guard, r=guard.

Translated to our convention (swap arg positions): `untl(q,p) ∧ ¬untl(r,p) → untl(q, q∧¬r)`.

Applied to the maximality witness: we have `untl(β₀, γ₀) ∈ A` and `¬untl(β₀∧δ, γ₀) ∈ A`. Setting q=β₀, p=γ₀, r=β₀∧δ: the output is `untl(β₀, β₀∧¬(β₀∧δ)) ∈ A`, which simplifies to `untl(β₀, β₀∧¬δ) ∈ A` (since β₀∧¬(β₀∧δ) = β₀∧(¬β₀∨¬δ), and in an MCS where β₀∈A, ¬β₀∉A, so the disjunction collapses to ¬δ).

After event weakening via BX3: `untl(β₀, ¬δ) ∈ A`, i.e., the guard β₀ holds until ¬δ is witnessed. This gives F(¬δ) via BX10.

### 3. BX5+BX7 Subsume A4a Under Strict Semantics (MEDIUM-HIGH CONFIDENCE)

A4a itself is not sound under strict semantics (documented in `TemporalDerived.lean:528-538`). But `PointInsertion.lean:21-22` documents: "BX5 + BX6 (absorb_until) + BX7 (linear_until) subsume A4a's role."

The derivation sketch:
1. `untl(β₀, γ₀) ∈ A` (from burgessR3)
2. BX5: `untl(β₀ ∧ untl(β₀,γ₀), γ₀) ∈ A` (guard enriched)
3. `¬untl(β₀∧δ, γ₀) ∈ A` (maximality witness)
4. BX7 (linearity) on steps 2 and 3: three disjuncts
5. Two disjuncts imply `untl(β₀∧δ, γ₀)`, contradicting step 3 — eliminated
6. Surviving disjunct contains ¬δ in event position
7. BX10 extracts F(β₀ ∧ ¬δ) ∈ A

This gives the consistency of ¬δ with the other D₀ formulas.

### 4. The D₀ Definition in Our Code Matches Burgess (HIGH CONFIDENCE)

Our `burgess_D0 A B C delta` (PointInsertion.lean ~line 755):
```
{S(β,α) : α∈A, β∈B} ∪ B ∪ {¬δ} ∪ {U(β,γ) : β∈B, γ∈C}
```

Translating Burgess's D₀ (Lemma 2.6) to our convention:
- `{S(α,β) : α∈A, β∈B}` → `{snce(β,α) : β∈B, α∈A}` (Since with B in guard position)

Wait — Burgess writes `S(α,β)` where (by his convention for S, which mirrors U) first=event, second=guard. Our `snce(φ,ψ)` has first=guard, second=event. So Burgess's `S(α,β)` with α=event, β=guard maps to our `snce(β,α)`.

Our code has `{S(β,α) : α∈A, β∈B}` = `{snce(β,α) : ...}` with β in guard position. This IS correct — matches Burgess.

Similarly `{U(γ,β) : γ∈C, β∈B}` in Burgess maps to `{untl(β,γ) : β∈B, γ∈C}` in our convention. Our code has `{U(β,γ) : β∈B, γ∈C}` which should be `{untl(β,γ) : ...}` — **correct**.

### 5. No Convention Swap Recommended (HIGH CONFIDENCE)

Our code follows the Kamp/standard convention (guard-first, event-second), which is used by most modern logic textbooks and the Lean formalization community. Burgess and Xu use a non-standard event-first convention. Swapping to match Burgess would:
- Diverge from the CS/PL standard
- Require touching ~1300 lines across 6+ files
- Not gain any mathematical advantage (the proof structure is identical)

## Recommendations

### 1. Correct the Handoff Analysis

The handoff's claim of a "fundamental guard/event convention mismatch" is wrong. The blocker is NOT a convention issue — it's that the BX5+BX7 derivation chain (replacing A4a) has not been implemented yet. This is the original plan task 1.2 and is straightforward now that the false alarm is resolved.

### 2. Continue D₀ Consistency Proof Following the Plan

The proof path:
1. Use `BurgessR3Maximal_maximality_combined` to get witness β₀∈B, γ₀∈C with `¬untl(β₀∧δ, γ₀) ∈ A`
2. From burgessR3: `untl(β₀, γ₀) ∈ A`
3. BX5: `untl(β₀ ∧ untl(β₀,γ₀), γ₀) ∈ A`
4. BX7 on steps 3 and the negation from step 1
5. Eliminate 2 of 3 disjuncts (they contradict step 1)
6. Surviving disjunct + BX10 → F(β₀ ∧ ¬δ) ∈ A
7. Build seed with β₀, ¬δ, Since/Until formulas → consistent by the 2.2 criterion

### 3. Do NOT Swap Conventions

No mathematical or practical benefit. Keep the Kamp standard.

## Teammate Contributions

| Teammate | Angle | Status | Key Finding |
|----------|-------|--------|-------------|
| A | Convention analysis | completed | Mismatch is false alarm; B=GUARD in all conventions |
| B | Alternatives | rate-limited | (not completed) |
| C | Critic | rate-limited | (not completed) |
| D | Horizons | rate-limited | (not completed) |

## References

- Burgess 1982: Section 1.2 (semantics), Section 2.3 (r-relation), Lemma 2.6 (D₀)
- Xu 1988: Section 1 item (iv) (semantics), Section 2 (r-relation)
- TemporalDerived.lean:528-538 (A4a invalidity + BX substitution documentation)
- PointInsertion.lean:19-22 (BX axiom substitution documentation)
