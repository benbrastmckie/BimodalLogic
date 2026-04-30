# Wave 1 Partial Handoff — Phases 8a+8b

**Task**: 107 — Burgess chronicle construction
**Session**: sess_1777507213_35f648
**Date**: 2026-04-30
**Plan**: v34 (plans/48_implementation-plan.md)

## Status

Wave 1 (Phases 8a + 8b) is PARTIAL. Key wins achieved, two issues remain.

## Phase 8a: DCS Maximality Revert — PARTIAL

### Completed
- [x] BurgessR3Maximal definition changed from ClosedUnderDerivation to SetDeductivelyClosed (ChronicleTypes.lean:320)
- [x] Zorn sorry (RRelation.lean:772) ELIMINATED — the inconsistent D case never arises with DCS maximality
- [x] `burgessR3Maximal_extension_exists` compiles sorry-free
- [x] `BurgessR3Maximal_extension_fails` updated to use DCS

### Blocked: g_content_sub_B (2 sorries) — ROOT CAUSE IDENTIFIED

The sorries in `g_content_sub_B_of_BurgessR3Maximal` and `h_content_sub_B_of_BurgessR3Maximal` (PointInsertion.lean) exist because our Lemma 2.6 seed construction deviates from Burgess's.

**Burgess's seed (Lemma 2.6, p. 371)**:
```
D₀ = {S(α, β) : α ∈ A, β ∈ B} ∪ B ∪ {¬δ} ∪ {U(γ, β) : γ ∈ C, β ∈ B}
```
This seed includes ALL of B, plus Since/Until formulas. Consistency is proved directly using A4a, A5a, A7a, A3a (pp. 370–371). Burgess does NOT need `g_content(A) ⊆ B` as a lemma — the property never arises because B is already in the seed.

**Our seed (`splitting_seed_consistent`)**:
```
{β.neg} ∪ g_content(A) ∪ h_content(C)
```
This is a different (weaker) seed that requires `g_content_sub_B` to show `seed ⊆ {β.neg} ∪ B`. This is our architectural deviation from Burgess.

**Fix**: Rewrite `lemma_2_6_splitting` and `splitting_seed_consistent` to use Burgess's actual seed D₀. This eliminates the need for `g_content_sub_B_of_BurgessR3Maximal` entirely. The consistency proof follows Burgess's argument:
1. Reduce to showing each ζ = S(α,β) ∧ β ∧ ¬δ ∧ U(γ,β) is consistent (for α∈A, β∈B, γ∈C)
2. From R(A,B,C) with δ∉B: obtain β₀∈B, γ₀∈C with ¬U(γ₀, β₀∧δ) ∈ A (by maximality)
3. WLOG β₀=β, γ₀=γ (by replacing with β∧β₀, γ∧γ₀)
4. From U(γ,β) ∈ A and ¬U(γ, β∧δ) ∈ A: by A5a get U(γ, β∧U(γ,β)) ∈ A, then A4a gives U(β∧U(γ,β)∧¬δ, β) ∈ A
5. By A3a: U(β∧U(γ,β)∧¬δ∧S(α,β), β) ∈ A
6. By Lemma 2.2 (consistency criterion): ζ is consistent

After the seed is proved consistent, extend to MCS D, then get R(A,B',D) and R(D,B'',C) by maximality with B⊆B' and B⊆B''. Lemma 2.5 gives B = B'∩D∩B''.

**Similarly for Lemma 2.7** (p. 371): the seed D₀ has the same structure but includes η∧U(ξ,η) terms. The A7a axiom is used here (the whole point of Phase 8b). Our Lemma 2.7 (`lemma_2_7`) should also be restructured to match Burgess's seed.

## Phase 8b: A7a Axiom — PARTIAL

### Design Change from Plan
The plan called for REPLACING BX7 with A7a. This caused 32+ cascading failures in SoundnessLemmas.lean. Instead, A7a was added as a SEPARATE axiom alongside BX7.

### Completed
- [x] `Axiom.linear_until_a7a` / `Axiom.linear_since_a7a` added (Axioms.lean)
- [x] Substitution cases added (Substitution.lean)
- [x] Soundness proofs verified (Soundness.lean) — `linear_until_a7a_valid`, `linear_since_a7a_valid`
- [x] All Soundness.lean match arms added (6 sites)
- [x] `axiom_swap_valid` function 1 in SoundnessLemmas.lean — A7a cases ADDED

### Remaining: SoundnessLemmas.lean (6 missing match arms)
Functions 2–4 need `linear_until_a7a` and `linear_since_a7a` cases:
- `axiom_locally_valid` (~line 1396): MISSING
- `axiom_swap_valid_general` (~line 1887): MISSING
- `axiom_locally_valid_general` (~line 2199): MISSING

**Template**: Copy the A7a cases from `axiom_swap_valid` (function 1, ~line 766). For direct-validity functions (2, 4), use direct proof style without `.swap_temporal`. For swap functions (3), use swap style with `.swap_temporal`.

**Key insight**: After `simp only [Formula.and, Formula.or, Formula.neg, truth_at]`, A7a proof terms are nearly identical to BX7. Only the D3 case needs guard order swapped: `(h_guard₂ r ...) (h_guard₁ r ...)` instead of `(h_guard₁ r ...) (h_guard₂ r ...)`.

## Build Status

**Build FAILS** on:
- `SoundnessLemmas.lean`: 6 missing match arms
- `PointInsertion.lean`: 2 sorry sites (g_content_sub_B — to be eliminated by seed refactoring)

Soundness.lean, Axioms.lean, Substitution.lean, RRelation.lean, ChronicleTypes.lean all compile clean.

## Current Sorry Count

| File | Sorries | Notes |
|------|---------|-------|
| PointInsertion.lean | 3 | 2 g/h_content_sub_B (eliminate via seed refactoring), 1 lemma_2_7 |
| CounterexampleElimination.lean | 2 | C4/C4' (Phase 9) |
| ChronicleToCountermodel.lean | 2 | FUC/FSC (Phase 10) |
| **Total** | **7** | Down from ~13 before this session |

## Resume Instructions

### Step 1: Fix SoundnessLemmas.lean (mechanical)
Add 6 missing match arms. Find `-- NOTE: until_elim / since_elim match arms removed` after `linear_since` cases in functions 2–4. Insert A7a cases before each NOTE line.

### Step 2: Restructure Lemma 2.6 seed (architectural)
Rewrite `splitting_seed_consistent` and `lemma_2_6_splitting` to use Burgess's actual D₀ seed:
```
D₀ = {S(α, β) : α ∈ A, β ∈ B} ∪ B ∪ {¬δ} ∪ {U(γ, β) : γ ∈ C, β ∈ B}
```
This eliminates `g_content_sub_B_of_BurgessR3Maximal` and `h_content_sub_B_of_BurgessR3Maximal` entirely (they become dead code that can be deleted).

### Step 3: Restructure Lemma 2.7 seed
Similarly align `lemma_2_7` with Burgess's D₀ for Lemma 2.7 (p. 371). This is where A7a (`Axiom.linear_until_a7a`) gets used.

### Step 4: Proceed to Wave 2
Phase 6 (Lemma 2.7 with A7a) and Phase 9 (C4 via lemma_2_6).

## Key Reference: Burgess 1982 Proof Structure

| Paper | Codebase | Notes |
|-------|----------|-------|
| r(A, β, C) | `burgessR A β C` | ∀γ∈C, U(γ,β)∈A |
| r(A, B, C) | `burgessR3 A B C` | B is DCS, r for all β∈B |
| R(A, B, C) | `BurgessR3Maximal A B C` | B maximal DCS with r(A,B,C) |
| Lemma 2.2 | (consistency criterion) | U(γ,δ)∈A → γ consistent |
| Lemma 2.3 | `burgessR_iff_burgessRSince` | r(A,β,C) ⟺ ∀α∈A, S(α,β)∈C |
| Lemma 2.4 | `burgessR3Maximal_exists_from_seed` | U(γ,β)∈A → ∃B,C with R(A,B,C) |
| Lemma 2.5 | (not formalized yet) | R(A,B,C) ∧ r(A,B',D) ∧ r(D,B'',C) ∧ B⊆B'∩D∩B'' → B=B'∩D∩B'' |
| Lemma 2.6 | `lemma_2_6_splitting` | R(A,B,C) ∧ δ∉B → splitting with ¬δ∈D |
| Lemma 2.7 | `lemma_2_7` (sorry) | R(A,B,C) ∧ U(ξ,η)∈A ∧ η∉B → splitting with η∈B', ξ∈D |
| C0–C5 | Chronicle structure | C3 = g(x,z) = g(x,y) ∩ f(y) ∩ g(y,z) |

## Key Decisions

1. **A7a is additive, not replacing BX7**: Both axioms coexist. A7a for Lemma 2.7. BX7 for guard conjunction. Both sound.

2. **g_content_sub_B is NOT needed**: Burgess never uses it. Our architecture deviated by using a non-Burgess seed. The fix is seed realignment, not density axioms.

3. **Plan v34 needs revision**: Phase 8b's "replace BX7" → "add A7a alongside BX7". Lemma 2.6/2.7 phases need seed restructuring prerequisite.
