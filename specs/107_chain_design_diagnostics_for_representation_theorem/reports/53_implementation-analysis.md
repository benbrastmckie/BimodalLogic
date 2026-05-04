# Implementation Analysis: Task #107 Plan v56

- **Task**: 107 - chain_design_diagnostics_for_representation_theorem
- **Date**: 2026-05-04
- **Purpose**: Pre-implementation analysis of all sorry sites, plan accuracy assessment, and identified blockers
- **Audience**: Implementation subagents, orchestrator, user

---

## Current Sorry Inventory (12 total)

| # | File | Line | Phase | Description |
|---|------|------|-------|-------------|
| 1 | PointInsertion.lean | 1872 | 1 | `h_ev_b : event → b` in inconsistent case |
| 2 | PointInsertion.lean | 1873 | 1 | `h_ev_untl : event → untl(b, γ_hat)` in inconsistent case |
| 3 | PointInsertion.lean | 2414 | 2 | `lemma_2_7_seed_consistent` (entire body) |
| 4 | CounterexampleElimination.lean | 756 | 4 | c2' from C5 forward elimination |
| 5 | CounterexampleElimination.lean | 794 | 4 | c2' from C5' backward elimination |
| 6 | CounterexampleElimination.lean | 834 | 4 | c2' from C4 forward elimination |
| 7 | CounterexampleElimination.lean | 872 | 4 | c2' from C4' backward elimination |
| 8 | CounterexampleElimination.lean | 918 | 4 | c2' for density insertion |
| 9 | CounterexampleElimination.lean | 412 | 5 | C4 hard case (γ ∈ f(x) ∧ γ ∈ f(y)) |
| 10 | CounterexampleElimination.lean | 510 | 5 | C4' hard case (mirror) |
| 11 | ChronicleToCountermodel.lean | 615 | 8 | FUC (forward until coherence) |
| 12 | ChronicleToCountermodel.lean | 619 | 8 | FSC (forward since coherence) |

Phase 6 is already complete (0 sorries in ChronicleConstruction.lean).

---

## Phase 1: CRITICAL PLAN ERROR

### The Problem

The plan says Phase 1 Tasks 1.1 and 1.2 are "Easy (~15 min)" using `guard_destruct`. **This is wrong.**

The sorry sites are in `burgess_D0_finite_subset_consistent_incons` (line 1811), which handles the case where `{β} ∪ B` is inconsistent (so `β.neg ∈ B`). The proof constructs an event via `iterated_enrichment`:

```lean
let evt := iterated_enrichment h_mcs_A q a_list ha_list γ_hat h_bx5
let event := evt.event'
```

The `EnrichedEvent` structure (line 1208) provides:
- `event' → γ_hat` (h_impl) — event implies the BASE EVENT, not the guard
- `untl(q, event') ∈ A` (h_untl) — guard q holds throughout interval
- `event' → snce(q, α)` for each α (h_snce)

**We do NOT have `event → q`** and there is no `guard_destruct` function in the codebase.

### Root Cause Analysis

Compare with the consistent case (`burgess_zeta_consistent`, line 1251):

| Step | Consistent Case | Inconsistent Case |
|------|----------------|-------------------|
| 1 | BX5: `untl(q, γ_hat) ∈ A` | Same ✓ |
| 2 | BX14: `untl(q, q ∧ (b∧β).neg) ∈ A` | **MISSING** — BX14 not applied |
| 3 | Enrich from `q ∧ (b∧β).neg` | Enrich from `γ_hat` |
| 4 | `event → q ∧ (b∧β).neg → q → b` ✓ | `event → γ_hat` — no path to b |

BX14 (A4a) is the ONLY axiom that transfers the guard into the event:
- `untl(q, γ_hat) ∧ ¬untl(b∧β, γ_hat) → untl(q, q ∧ (b∧β).neg)`

The consistent case obtains `¬untl(b∧β, γ_hat) ∈ A` via `BurgessR3Maximal_extension_fails`, which requires `SetConsistent({β} ∪ B)`. The inconsistent case lacks this because `{β} ∪ B` is inconsistent.

### Why Extension Fails Can't Be Used

`BurgessR3Maximal_extension_fails` (line 566) requires:
```lean
(h_cons : SetConsistent ({delta} ∪ B))
```

In the inconsistent case, `{β} ∪ B` is inconsistent → function cannot be called.

Our `SetDeductivelyClosed` includes `SetConsistent` (line 82), so DC({β}∪B) = Set.univ is NOT a DCS. The maximality clause of BurgessR3Maximal only covers DCS extensions, so it says nothing about inconsistent extensions.

**This is a deviation from Burgess**: In the paper, "deductively closed" does NOT require consistency (Section 1.3). Our maximality is over consistent DCS only, losing coverage of the inconsistent extension case.

### Proposed Fix: Case Split on MCS Maximality

In the inconsistent case, `β.neg ∈ B` and `β ∉ B` (since B is a consistent DCS). We need `¬untl(b∧β, γ_hat) ∈ A` for BX14.

**Approach**: By MCS maximality of A:
- Either `¬untl(b∧β, γ_hat) ∈ A`: Apply BX14, proceed as in consistent case
- Or `untl(b∧β, γ_hat) ∈ A`: Since `⊢ (b∧β) → ⊥` (from `b → β.neg`), we get `untl(⊥, γ_hat) ∈ A` by left_mono. This case needs separate treatment.

For the second sub-case, one approach: use the fact that `untl(b∧β, γ_hat) ∈ A` combined with BX5 and a different BX14 application. Alternatively, show this case can't arise (which would require new axiom-level reasoning).

**Alternatively**: Eliminate the inconsistent case entirely by calling `burgess_zeta_consistent` (or its logic) for both cases. The preconditions can potentially be satisfied:
- `β ∉ B` ✓ (β.neg ∈ B, B consistent)
- `{β.neg} ∪ B = B` consistent ✓  
- `F(β.neg) ∈ A` — needs derivation (not directly available)
- `¬untl(b∧β, γ_hat) ∈ A` — needs the MCS case split above

### Estimated Difficulty

**NOT 30 minutes. Estimated 2-4 hours** (research + structural fix + verification).

---

## Phase 2: Lemma 2.7 Seed Consistency

### Structure

`lemma_2_7_seed_consistent` (line 2405) is a complete sorry — the entire body. The TODO comment (lines 2393-2403) outlines a 10-step proof following Burgess 1982 p.372.

### Key BX Axioms Needed

- **BX5** (self_accum_until): `untl(ξ, η) → untl(ξ ∧ untl(ξ,η), η)` — already used in codebase
- **BX7** (linear_until): `untl(φ,ψ) ∧ untl(χ,θ) → D1 ∨ D2 ∨ D3` — three-way disjunction
- **BX13** (enrichment_until): `p ∧ untl(r, q) → untl(r, q ∧ snce(r, p))` — packs Since into event
- **BX14** (separation_until): `untl(q, γ) ∧ ¬untl(b∧η, γ) → untl(q, q ∧ (b∧η).neg)` — guard into event
- **BX10** (until_F): `untl(guard, event) → F(event)` — consistency of event

### Existing Infrastructure

- `BurgessR3Maximal_extension_fails` (line 566): Extract ¬untl witnesses from maximality
- `dc_delta_B_controlled` (line 512): Analyze deductive closure membership
- `burgess_zeta_consistent` (line 1251): Template for BX5+BX14+BX13+BX10 chain
- `iterated_enrichment` (line 1218): Pack Since-formulas into enriched event
- `self_accum_until_mcs`, `separation_until_mcs`, `until_implies_F_mcs`: MCS-level axiom wrappers

### Proof Outline (Burgess 2.7)

Given: R(A, B, C), untl(ξ, η) ∈ A, η ∉ B.

1. Extract witnesses β₀ ∈ B, γ₀ ∈ C with ¬untl(β₀∧η, γ₀) ∈ A (from maximality via extension_fails; note {η}∪B IS consistent here since η ∉ B but {η}∪B consistency comes from `lemma_2_7`'s context)
2. BX5 on untl(ξ, η): untl(ξ ∧ untl(ξ,η), η) ∈ A
3. BX5 on untl(β₀, γ₀) (from r(A,B,C)): untl(β₀ ∧ untl(β₀,γ₀), γ₀) ∈ A
4. BX7 on these two: three-way disjunction D1 ∨ D2 ∨ D3
5. Eliminate D1: contains η∧γ₀ endpoint. Left mono → untl(β₀∧η, γ₀) ∈ A, contradicting step 1.
6. Eliminate D2: contains η∧(β₀∧untl(β₀,γ₀)) endpoint. Needs argument that this implies untl(β₀∧η, γ₀) via left_mono.
7. D3 survives: untl((ξ∧untl(ξ,η))∧(β₀∧untl(β₀,γ₀)), (ξ∧untl(ξ,η))∧γ₀) ∈ A
8. BX14 with ¬untl(β₀∧η, γ₀): put guard into event
9. BX13 enrichment: pack snce-formulas
10. BX10: F(event) ∈ A → event consistent → D₀ consistent

**The seed** (line 2386) includes an extra component vs Lemma 2.6:
```
{snce(β ∧ η, α) : β ∈ B, α ∈ A}
```
This requires the enrichment to also pack `snce(β∧η, α)` into the event, which needs the guard to contain `β∧η`. This is achievable because D3's guard includes `ξ∧untl(ξ,η)`, and from untl(ξ,η) we can extract η-related formulas.

### Estimated Difficulty

**Hard. 4-6 hours** (5 sub-tasks, each Medium to Hard).

---

## Phase 3: Populate g-Values (6-8 hours)

The core structural fix: make each elimination function construct g-values for new adjacent pairs. Currently all 5 elimination branches return `χ.g` unchanged.

**Key insight**: When inserting a new point z between x and y, new adjacent pairs (x,z) and (z,y) are created. The g-values for these pairs must be populated using `lemma_2_4` output (for C5) or `lemma_2_6_splitting` output (for C4).

This phase creates the data that Phases 4 and 5 consume.

---

## Phase 4: c2' Proofs (2 hours, depends on Phase 3)

Five sorry sites at CounterexampleElimination.lean lines 756/794/834/872/918. Each proves that the new chronicle after elimination satisfies c2' (BurgessR3Maximal at all adjacent pairs). Task 4.1 (trivial no-elimination branches) already completed.

---

## Phase 5: C4 Hard Cases (3-4 hours, depends on Phase 3)

Two sorry sites at lines 412/510. The hard case where γ ∈ f(x) AND γ ∈ f(y). Requires BurgessR3 bridging using populated g-values + c2'.

---

## Phase 7: Limit C5a/C5b (6-8 hours, depends on Phase 6 ✓)

Prove `limit_satisfies_c5_full` and mirror. Uses `omega_chain_c2'` (Phase 6, done) + g-value persistence at the limit + C3 interval containment.

**Key unknown**: `guard_in_r_maximal` — whether untl(ξ,η) ∈ f(x) and BurgessR3Maximal(f(x), g(x,y), f(y)) implies ξ ∈ g(x,y). This needs verification.

---

## Phase 8: FUC/FSC (3-4 hours, depends on Phase 7)

Two sorry sites at ChronicleToCountermodel.lean lines 615/619. Uses `limit_satisfies_c5_full` + Cantor isomorphism transfer. Should be relatively straightforward once Phase 7 is done.

---

## Argument Convention Warning

Our code swaps argument order vs Burgess:

| | First Arg | Second Arg |
|--|-----------|------------|
| **Burgess U(α, β)** | event (endpoint) | guard (interval) |
| **Our untl(guard, event)** | guard (interval) | event (endpoint) |

Correspondences:
- Burgess A1a (left_mono on event) = our `right_mono_until_mcs` (changes second arg)
- Burgess A2a (right_mono on guard) = our `left_mono_until_mcs`/`untl_left_mono_thm` (changes first arg)
- Our `lce_imp`/`rce_imp` = left/right conjunction elimination derivations

---

## Dependency Graph

```
Phase 1 ─────────────────────────────────────────┐
                                                   ├─ (independent)
Phase 2 ─────────────────────────────────────────┤
                                                   │
Phase 3 (depends on Phase 2) ────────────────────┤
                                                   │
Phase 4 (depends on Phase 3) ─┬──────────────────┤
Phase 5 (depends on Phase 3) ─┘                   │
                                                   │
Phase 6 [COMPLETED] ─────────────────────────────┤
                                                   │
Phase 7 (depends on Phase 6) ────────────────────┤
                                                   │
Phase 8 (depends on Phase 7) ────────────────────┘
```

**Critical path**: Phase 2 → Phase 3 → Phase 4 → Phase 7 → Phase 8

Phase 1 is independent but blocks nothing else. It should be resolved but is not on the critical path.

---

## Recommendations

1. **Phase 1**: Restructure `burgess_D0_finite_subset_consistent_incons` to use the BX14 approach. Apply MCS case split on `untl(b∧β, γ_hat)`. If `¬untl(b∧β, γ_hat) ∈ A`, proceed as in consistent case. Alternatively, call `burgess_zeta_consistent` directly if F(β.neg) can be derived.

2. **Phase 2**: Follow the 10-step outline in the TODO comment, using `burgess_zeta_consistent` as a template. The BX7 three-way disjunction + elimination is the core.

3. **Phases 3-5**: These are structurally dependent on Phases 1-2 being correct. The g-population work in Phase 3 is the largest single phase.

4. **Burgess reference**: Subagents should read `/home/benjamin/Projects/ProofChecker/literature/Burgess_1982_Axioms_for_tense_logic_Since_and_Until.md` — especially Lemmas 2.6 (Phase 1 fix template) and 2.7 (Phase 2 proof).
