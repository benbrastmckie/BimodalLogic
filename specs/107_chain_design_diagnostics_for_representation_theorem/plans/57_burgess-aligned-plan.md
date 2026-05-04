# Implementation Plan: Task #107 — Burgess-Aligned Chronicle Construction

- **Task**: 107 - chain_design_diagnostics_for_representation_theorem
- **Status**: [NOT STARTED]
- **Effort**: 37-50 hours
- **Dependencies**: N/A (self-contained within Chronicle/; Lemma 2.4 seed already sorry-free, omega_chain Phase 6 already complete)
- **Research Inputs**:
  - `reports/53_implementation-analysis.md` — full sorry inventory (12 sorries), BX axiom mapping, dependency graph, argument convention warning
  - `reports/54_burgess-semantic-alignment.md` — open-guard semantics confirmed, Path A recommended, Xu-style seed mathematically insufficient
  - `literature/Burgess_1982_Axioms_for_tense_logic_Since_and_Until.md` — primary mathematical reference, Sections 2.4–2.11
- **Artifacts**: plans/57_burgess-aligned-plan.md (this file)
- **Standards**: plan-format.md; status-markers.md; artifact-management.md; tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Restructures task 107 to follow Burgess 1982's chronicle construction **lemma-by-lemma**, co-constructing endpoint MCS and interval DCS together at each elimination step. The root cause across all 12 current sorries is the same: elimination functions produce endpoint MCSs but discard the interval DCSs (g-values). After this plan, every new adjacent pair created during C4/C5/C4'/C5'/density elimination will have populated g-values satisfying `BurgessR3Maximal`, and the limit C5a/C5b properties will be provable using C3 and the Cantor transfer.

### Research Integration

Report 54: Burgess uses **open-guard** semantics (identical to ours). A3a (BX13) and A4a (BX14) are valid and present with sorry-free soundness. **Path A (full Burgess D₀ chain) is the only mathematically correct option** — the Xu-style simplified seed cannot establish `burgessR3(D, B, C)` needed by Zorn's lemma.

Report 53 provides the complete sorry inventory, the dependency graph, and the argument convention warning (our `untl(guard, event)` swaps vs Burgess `U(event, guard)`).

## Goals & Non-Goals

**Goals**:
- Co-construct endpoint MCS and interval DCS at every elimination step (Burgess §2.9, §2.10).
- Close all 12 current sorries (2 in PointInsertion.lean, 8 in CounterexampleElimination.lean, 2 in ChronicleToCountermodel.lean).
- Prove `limit_satisfies_c5_full` and `limit_satisfies_c5'_full` (guard at intermediate domain points).
- Close FUC/FSC and complete the fully sorry-free countermodel.

**Non-Goals**:
- Rewrite the elimination algorithm with Burgess's induction-on-intermediate-points structure (flat approach is equivalent).
- Introduce new axioms or change semantics.
- Modify limit_dom, limit_f, limit_g, limit_c3 (all already sorry-free).

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Lemma 2.7 (BX7 three-way) combinatorially blocked | Delays Phase 3 by 3-5h | Medium | Use `lce_imp`/`rce_imp` for propositional simplifications; `untl_left_mono_deriv`/`untl_right_mono_deriv` already available |
| `guard_in_r_maximal` lemma unprovable (Phase 8) | Blocks limit C5a | Low | The limit_g is defined as formulas true at ALL intermediates; `limit_satisfies_c5_full` is provable directly from limit_g definition + `limit_satisfies_c5_weak` |
| g-value construction breaks all call sites | Build churn | High | Commit after each elimination function change; fix call sites incrementally |
| C4 hard cases remain blocked | Delays Phase 7 | Low | `BurgessR3Maximal_extension_fails` for γ ∉ g(w,w_next) bridges back to original counterexample |

## Phase Dependency Graph

```
Phase 1 (Foundation Audit, 2h)
  ├──► Phase 2 (Lemma 2.6 Inconsistent, 4-6h) ── independent
  └──► Phase 3 (Lemma 2.7, 6-9h) ─────────────── independent
                                                         │
Phase 4 (C4 co-construction, 5-7h) ◄────────────────────┘ (depends on 2, 3)
Phase 5 (C5 co-construction, 4-5h) ◄────────────────────┘ (depends on 2, 3)
     │                                                             
Phase 6 (c2' Maintenance, 5-7h) ◄── (depends on 4, 5)
     │
Phase 7 (C4 Hard Cases, 3-5h) ◄── (depends on 6)
     │
Phase 8 (Limit C5a/C5b Full, 6-9h) ◄── (depends on 6)
     │
Phase 9 (FUC/FSC, 3-5h) ◄─────── (depends on 8)
     │
Phase 10 (Final Audit, 2-3h) ◄── (depends on 9)
```

**Critical path**: Phase 3 → Phase 4 → Phase 6 → Phase 8 → Phase 9 (27-37h)

Phases 4 and 5 are parallel; Phase 2 is parallel to Phase 3.

---

## Phase 1: Foundation Audit and Interface Verification

**Paper reference**: Burgess §2.1–2.5 (overall definitions)  
**Status**: [COMPLETED]  
**Effort**: 2 hours

**Purpose**: Verify that all existing infrastructure is correct before implementing. `lemma_2_4` (endpoint MCS + interval DCS) and `lemma_2_6_splitting` (B', D, B'') are already sorry-free. Audit each lemma's output interface to ensure callers can access all needed components.

**Tasks**:
- [x] **Task 1.1**: Audit `lemma_2_4` — verify that the interval DCS `B` is returned and accessible. If return type buries `B` inside `exists_rat_gt_finset`'s output, restructure to expose it.
- [x] **Task 1.2**: Audit `lemma_2_6_splitting` — verify `B', D, B''` all accessible with `BurgessR3Maximal` proofs. Confirm callers can extract each.
- [x] **Task 1.3**: Verify BX axiom MCS-level wrappers exist: BX5 (`self_accum_until_mcs`), BX7 (`linear_until_mcs`), BX10 (`until_implies_F_mcs`), BX13 (enrichment), BX14 (separation), left/right monotonicity.
- [x] **Task 1.4**: Verify `iterated_enrichment` works for both Lemma 2.6 (packing snce-formulas via guard `q`) and Lemma 2.7 (packing snce-formulas with `β∧η` guards).
- [x] **Task 1.5**: Add argument-order convention comments at top of PointInsertion.lean, CounterexampleElimination.lean, ChronicleConstruction.lean.

**Verification**: `lake build` passes. Audit results written to `reports/57_foundation-audit.md`.

---

## Phase 2: Lemma 2.6 — Inconsistent Case (PointInsertion lines 1872-1873)

**Paper reference**: Burgess §2.6, p.370–371 (D₀ seed consistency, inconsistent sub-case)  
**Status**: [IN PROGRESS]  
**Effort**: 4–6 hours  
**Depends on**: Phase 1

**Purpose**: Close the 2 sorries `h_ev_b` and `h_ev_untl` in `burgess_D0_finite_subset_consistent_incons`. These require proving that the enriched event formula implies the guard `b` and the accumulated Until `untl(b, γ̂)`.

**Context**: When `{β}∪B` is inconsistent, `β.neg ∈ B`. The D₀ seed simplifies. The enrichment `iterated_enrichment` gives `event → γ̂` (the base event), but not `event → b` or `event → untl(b, γ̂)`. These come from BX14 separation applied to `¬untl(b∧β, γ̂) ∈ A`.

**Proof approach** (from Report 53): **MCS case split** on membership of `untl(b∧β, γ̂)` in `A`:

**Sub-case A** (`¬untl(b∧β, γ̂) ∈ A`): Apply BX14 directly, then reuse `burgess_zeta_consistent` (line 1251) which internally chains BX5 → BX14 → BX13 → BX10 to produce all five needed components.

**Sub-case B** (`untl(b∧β, γ̂) ∈ A`): Since `b → β.neg` (β.neg ∈ B ⊆ b_list), we have `⊢ (b∧β) → ⊥`. Left_mono gives `untl(⊥, γ̂) ∈ A`. By BX10, `F(⊥) ∈ A`. But `G(⊤) ∈ A` by theorem_in_mcs. Since `F(⊥) = ¬G(⊤)`, this contradicts MCS consistency. So Sub-case B is impossible.

**Tasks**:
- [ ] **Task 2.1**: Implement MCS case split and Sub-case A (negation available). Replace `h_ev_b` and `h_ev_untl` sorry sites with output from `burgess_zeta_consistent`. (2h)
- [ ] **Task 2.2**: Prove Sub-case B impossible via `F(⊥) ∈ A` contradiction. (1-2h)
- [ ] **Task 2.3**: Integrate both cases, remove sorries, verify full function compiles. (1h)

**Verification**: `PointInsertion.lean` sorry count: 3 → 1. `lake build` passes for PointInsertion.lean.

---

## Phase 3: Lemma 2.7 — Point Insertion for C5 Nested Case (PointInsertion line 2414)

**Paper reference**: Burgess §2.7, p.372 (Until-formula splitting with BX7 three-way disjunction)  
**Status**: [NOT STARTED]  
**Effort**: 6–9 hours  
**Depends on**: Phase 1. Independent of Phase 2.

**Purpose**: Implement the complete body of `lemma_2_7_seed_consistent`. This is the hardest single theorem — it proves consistency of the Lemma 2.7 D₀ seed:
```
lemma_2_7_seed = B ∪ {xi} ∪ {untl(β,γ): β∈B, γ∈C}
                 ∪ {snce(β,α): β∈B, α∈A}
                 ∪ {snce(β∧η,α): β∈B, α∈A}
```

The proof chains BX5 → BX7 → BX13 → BX14 → BX10 exactly as Burgess does.

**Proof chain** (10 steps, matching TODO comment at lines 2393-2403):
1. **Witness**: From `η ∉ B` + maximality, extract `β₀ ∈ B, γ₀ ∈ C` with `¬untl(β₀∧η, γ₀) ∈ A`.
2. **BX5 on `untl(β₀, γ₀)`**: Get `untl(β₀∧untl(β₀,γ₀), γ₀) ∈ A`.
3. **BX5 on `untl(xi, η)`**: Get `untl(xi∧untl(xi,η), η) ∈ A`.
4. **BX7 three-way** on these two → D₁ ∨ D₂ ∨ D₃.
5. **Eliminate D₁**: Event contains `η∧γ₀`, left_mono → `untl(β₀∧η, γ₀) ∈ A`, contradicts step 1.
6. **Eliminate D₂**: Event contains `η`, similar contradiction via left_mono.
7. **D₃ survives**: `untl(φ₁∧φ₂, (xi∧untl(xi,η))∧γ₀) ∈ A` where `φ₁=xi∧untl(xi,η)`, `φ₂=β₀∧untl(β₀,γ₀)`.
8. **BX14 separation**: With `¬untl(β₀∧η, γ₀)`, insert guard into event.
9. **BX13 enrichment**: Pack `snce`-formulas for α∈A and β∧η cases into event.
10. **BX10**: `F(event) ∈ A` → event consistent → D₀ seed consistent.

**Tasks**:
- [ ] **Task 3.1**: Implement `lemma_2_7_neg_untl_exists` — extract β₀, γ₀ witness using `BurgessR3Maximal_extension_fails` + `dc_delta_B_controlled`. (1.5h)
- [ ] **Task 3.2**: BX5 self-accumulation on both Until formulas. (0.5h)
- [ ] **Task 3.3**: BX7 three-way disjunction application — verify `linear_until_mcs` wrapper. (1h)
- [ ] **Task 3.4**: Eliminate D₁ — left_mono on event `η∧γ₀` to contradict witness. (1.5h)
- [ ] **Task 3.5**: Eliminate D₂ — mirror of D₁ elimination. (1.5h)
- [ ] **Task 3.6**: BX14 separation on surviving D₃ — propositional simplification: guard `φ₁∧φ₂` contains `β₀` and `xi`. (2h)
- [ ] **Task 3.7**: BX13 enrichment + BX10 consistency — pack snce-formulas, extract F(event). (2h)
- [ ] **Task 3.8**: Assemble and close `lemma_2_7_seed_consistent`. (1h)

**Verification**: `PointInsertion.lean` sorry count: 1 → 0. `lemma_2_7` (line 2416, main theorem) still compiles. `lake build` passes.

---

## Phase 4: Lemma 2.9 — C4 Elimination with Co-Constructed g-Values

**Paper reference**: Burgess §2.9, p.373 (C4 counterexample elimination — base and inductive cases)  
**Status**: [NOT STARTED]  
**Effort**: 5–7 hours  
**Depends on**: Phase 2 (valid `lemma_2_6_splitting`) + Phase 3 (valid Lemma 2.7 for nested case)

**Purpose**: Rewrite `eliminate_C4_counterexample` (line ~329) and `eliminate_C4'_counterexample` (line ~426) to populate g-values at new adjacent pairs using `lemma_2_6_splitting`. Currently both functions return `χ.g` unchanged.

**What changes**: When inserting midpoint z between x and y, `lemma_2_6_splitting` produces `(B', D, B'')`. The chronicle must be extended with:
- `f'(z) = D` (already done)
- `g'(x, z) = B'`
- `g'(z, y) = B''`  
- For old non-adjacent pairs now involving z, use C3 intersection formula.
- Return type changes: `(∀ a b, χ'.g a b = χ.g a b)` is no longer true globally.

**Base case (n=0)**: x and y are adjacent. `lemma_2_6_splitting` applies directly with `A=f(x)`, `B=g(x,y)`, `C=f(y)`.

**Inductive case**: The existing code already locates the rightmost w with `¬U(γ,δ) ∈ f(w)` and its successor w_next. Lemma 2.6 applies to this adjacent pair, then C3 determines other g-values involving z.

**Tasks**:
- [ ] **Task 4.1**: Restructure `eliminate_C4_counterexample` — call `lemma_2_6_splitting` to get B', D, B''. Set `g'(x,z)=B'`, `g'(z,y)=B''`. For the easy cases (¬γ ∈ f(x) or ¬γ ∈ f(y)), use trivial g-values that satisfy BurgessR3Maximal. (2.5h)
- [ ] **Task 4.2**: Restructure `eliminate_C4'_counterexample` — mirror for Since. (2h)
- [ ] **Task 4.3**: Verify C1 (all new g-values are DCS) — `lemma_2_6_splitting` output B', B'' come from `BurgessR3Maximal`, which guarantees DCS. C3-derived intersections are DCS via `dcs_inter_mcs_inter_dcs`. (0.5h)
- [ ] **Task 4.4**: Update return type and call sites — change `g_agrees` from global to old-domain-only, or add `g_replaced` field documenting which g-values changed. Fix all call sites in `eliminate_potential_counterexample` and `omega_chain`. (1h)

**Verification**: New adjacent pairs have non-empty g-values. `lake build` succeeds after each atomic change. C4 branches compile.

---

## Phase 5: Lemma 2.10 — C5 Elimination with Co-Constructed g-Values

**Paper reference**: Burgess §2.10, p.374 (C5 counterexample elimination)  
**Status**: [NOT STARTED]  
**Effort**: 4–5 hours  
**Depends on**: Phase 2 (Lemma 2.6) + Phase 3 (Lemma 2.7)

**Purpose**: Rewrite `eliminate_C5_counterexample` (line ~167) and `eliminate_C5'_counterexample` (line ~211) to populate g-values using Lemma 2.4's interval DCS output. Currently `lemma_2_4` returns both B and C, but only C is used.

**What changes**: `lemma_2_4` produces `(B, C)` where `BurgessR3Maximal(f(x), B, C)`. Set `g'(x, y) = B` for the new adjacent pair.

**Base case (n=0)**: No domain points after x. y is placed beyond all domain points. B from `lemma_2_4` becomes `g'(x, y)`.

**Inductive case**: This is handled at the omega-chain level — each step adds y beyond all current points, so the base case suffices. The nested case (intermediate points after x) would use Lemma 2.7, but it's not needed here since y goes beyond everything.

**Tasks**:
- [ ] **Task 5.1**: Rewrite `eliminate_C5_counterexample` — extract B from `lemma_2_4`. Set `g'(x, y) = B`. (2h)
- [ ] **Task 5.2**: Rewrite `eliminate_C5'_counterexample` — mirror for Since. (1.5h)
- [ ] **Task 5.3**: Update return type — change g_agrees property. Fix call sites. (1h)

**Verification**: New adjacent pair (x, y) has `g'(x, y) = B` where B is non-empty DCS with `BurgessR3Maximal`. `lake build` passes. C5 branches compile.

---

## Phase 6: c2' Maintenance — BurgessR3Maximal at All Adjacent Pairs

**Paper reference**: Burgess §2.5 (C2' condition — BurgessR3Maximal at adjacent pairs)  
**Status**: [NOT STARTED]  
**Effort**: 5–7 hours  
**Depends on**: Phases 4 and 5 (g-values now populated)

**Purpose**: Fill the 5 `c2'` sorries (lines 756, 794, 834, 872, 918) in `EliminationResult` within `eliminate_potential_counterexample`. The no-elimination branches are already done (Task 4.1 from plan v56).

**Proof strategy per branch**: For each elimination branch, prove `BurgessR3Maximal` at every adjacent pair in the new chronicle:
- **Old adjacent pairs** (both endpoints in original domain): Inherit from `h_c2'` of input chronicle via g-agreement property.
- **New adjacent pairs**: Derive from the elimination lemma that created them.

| Branch | New adjacent pairs | Proof source |
|--------|-------------------|--------------|
| C5 forward (756) | (x, y) | `lemma_2_4` output `BurgessR3Maximal(f(x), B, C)` — now `BurgessR3Maximal(f(x), g'(x,y), f'(y))` |
| C5' backward (794) | (y, x) | Mirror |
| C4 forward (834) | (x, z) and (z, y) | `lemma_2_6_splitting` output `BurgessR3Maximal(f(x), B', D)` and `BurgessR3Maximal(D, B'', f(y))` |
| C4' backward (872) | (y, z) and (z, x) | Mirror |
| Density (918) | (x, z) and (z, y) | `burgessR3Maximal_from_g_content_sub` or direct construction from copied endpoint |

**Tasks**:
- [ ] **Task 6.1**: C5 forward c2' (line 756) — from Phase 5 output. (1h)
- [ ] **Task 6.2**: C5' backward c2' (line 794) — mirror. (0.5h)
- [ ] **Task 6.3**: C4 forward c2' (line 834) — from Phase 4 output, handle old and new pairs. (2.5h)
- [ ] **Task 6.4**: C4' backward c2' (line 872) — mirror. (1.5h)
- [ ] **Task 6.5**: Density c2' (line 918) — the new point copies f(x); prove maximality for both new adjacent pairs. (1.5h)

**Verification**: All 5 c2' sorries closed. `CounterexampleElimination.lean` sorry count: 9 → 4. `omega_chain` still compiles (`omega_chain_c2'` already depends on `EliminationResult.c2'`). `lake build` passes.

---

## Phase 7: C4 Hard Cases — BurgessR3 Bridging (CounterexampleElimination lines 412, 510)

**Paper reference**: Burgess §2.9 (C4 hard case — γ ∈ f(w) ∧ γ ∈ f(w_next))  
**Status**: [NOT STARTED]  
**Effort**: 3–5 hours  
**Depends on**: Phase 6 (c2' available at all adjacent pairs)

**Purpose**: Close the 2 hard-case sorries in the C4/C4' elimination functions. These handle the sub-case where γ ∈ f(w) AND γ ∈ f(w_next), so neither endpoint can directly serve as the witness.

**Mathematical context**: The existing code extracts the rightmost w with `¬U(γ,δ) ∈ f(w)` and its successor w_next. These are adjacent. From c2' (Phase 6): `BurgessR3Maximal(f(w), g(w,w_next), f(w_next))`. Since the Until is a counterexample, γ ∉ g(w,w_next). Apply `BurgessR3Maximal_extension_fails` with extension candidate γ: this produces a witness formula φ ∈ DC({γ}) and some γ' ∈ f(w_next) with `¬U(φ, γ') ∈ f(w)`. Bridge back to the original counterexample via monotonicity.

**Tasks**:
- [ ] **Task 7.1**: Close C4 hard case (line 412) — apply `BurgessR3Maximal_extension_fails` at (f(w), g(w,w_next)) with extension candidate γ. Extract witness, derive γ.neg-containing MCS D for the new midpoint z. (2.5h)
- [ ] **Task 7.2**: Close C4' hard case (line 510) — mirror for Since. (2h)

**Verification**: `CounterexampleElimination.lean` sorry count: 4 → 2. Both C4/C4' elimination functions fully sorry-free. `lake build` passes.

---

## Phase 8: Limit C5a/C5b — Full Guard Propagation (ChronicleConstruction)

**Paper reference**: Burgess Claim 2.11, p.375 (truth lemma — forward Until/Since coherence at limit)  
**Status**: [NOT STARTED]  
**Effort**: 6–9 hours  
**Depends on**: Phase 6 (c2' threaded through omega_chain — already done)

**Purpose**: Prove `limit_satisfies_c5_full` and `limit_satisfies_c5'_full`. The "weak" versions already exist (endpoint witnesses only: `limit_satisfies_c5_weak`, `limit_satisfies_c5'_weak`). The full versions must additionally prove that the guard formula holds at all intermediate domain points.

**Key insight**: The limit interval function `limit_g` is already defined as:
```
limit_g A h_mcs x z := { φ | ∀ y ∈ limit_dom, x < y → y < z → φ ∈ limit_f y }
```

This definition directly encodes the property that guard formulas propagate to all intermediate points. So the proof of `limit_satisfies_c5_full` reduces to:
1. Given `U(ξ,η) ∈ limit_f x`, obtain witness y from `limit_satisfies_c5_weak` (η ∈ limit_f y).
2. For any intermediate z (x < z < y), we need `ξ ∈ limit_f z`. By C3 at the limit, `limit_g(x,y) ⊆ limit_f z`. So we need `ξ ∈ limit_g(x,y)`.
3. Prove that `ξ ∈ limit_g(x,y)`. Since limit_g is defined as formulas true at all intermediates, this is equivalent to: `∀w ∈ limit_dom, x < w < y → ξ ∈ limit_f w`. This is what we're trying to prove! So this is circular.

**Correct approach**: Instead, prove that `ξ ∈ limit_f z` for each z by tracing back to the finite stage where z was inserted. At each elimination step, the g-values are populated with `BurgessR3Maximal` (Phase 6). The key lemma:

**`guard_persists_at_limit`**: If `U(ξ,η) ∈ limit_f x` and y is the witness (from `limit_satisfies_c5_weak`), then for any z inserted at finite stage n with x < z < y:
- At the finite stage n+1 (right after z's insertion), the g-value for the subinterval containing z includes ξ.
- This follows from c2' at finite stage n (the elimination function maintains it), combined with the fact that ξ is part of the Until formula's accumulated guard.
- Then C3 at the limit lifts this to `ξ ∈ limit_f z`.

**Alternative direct approach** (recommended): Since `limit_g` is defined as formulas at ALL intermediate points, we can avoid tracing back. Instead, prove by contradiction: if some intermediate z has `¬ξ ∈ limit_f z`, then `ξ.neg ∈ limit_f z` (MCS). By the definition of `limit_g`, `ξ ∉ limit_g(x,y)`. This means the Until witness's g-value doesn't contain ξ. But from the finite-stage elimination that created y (via Lemma 2.4), `g'(x,y)` was set to B with `BurgessR3Maximal(f(x), B, C)`. If `ξ ∈ f(x)` (from `U(ξ,η) ∈ f(x)`, the guard ξ may not be in f(x) — actually, under open guard semantics, the guard is NOT at f(x). It's only on the open interval (x,y)).

Wait. Under open-guard semantics: `U(ξ,η) ∈ f(x)` means ∃ y > x: `η ∈ f(y)` ∧ `∀z(x < z < y): ξ ∈ f(z)`. The guard ξ is on the OPEN interval, NOT at x. So the truth lemma says the guard ξ should be at EVERY intermediate f(z). This is exactly what `limit_g` captures: `ξ ∈ limit_g(x,y)` iff ξ is true at all intermediate points.

So the proof strategy is:
1. From `U(ξ,η) ∈ limit_f x`, obtain witness y from `limit_satisfies_c5_weak`.
2. Show that `ξ ∈ limit_g(x,y)`. Since limit_g is defined by C3 at the dense limit, and the finite-stage c2' provides `BurgessR3Maximal` at all subintervals, each subinterval's g-value contains ξ. Then by the definition of limit_g as "all intermediates", we get `ξ ∈ limit_g(x,y)`.
3. The key sub-lemma: **`finite_stage_guard_in_g`**: At any finite stage n where the witness y has been added, for any adjacent pair (a,b) between x and y, `ξ ∈ g_n(a,b)`. This is proven by induction on the construction.

I think the simplest path: Since the limit domain is the union of finite domains, and C3 ensures g(x,y) ⊆ f(z) for all intermediate z, we can prove `ξ ∈ limit_f z` by using C3 and the fact that at the finite stage where z was inserted, the g-values for the adjacent pair covering z contained ξ. This avoids the circularity.

**Tasks**:
- [ ] **Task 8.1**: Lemma `finite_stage_guard_in_g` — at any finite stage n after witness y insertion, prove that for any adjacent pair (a,b) with x ≤ a < b ≤ y in the finite domain, `ξ ∈ g_n(a,b)`. Use induction on n and the c2' invariant. (3h, Hard)
- [ ] **Task 8.2**: Lift to `ξ ∈ limit_g(x,y)` — use Task 8.1 + C3 limit decomposition. (1.5h, Medium)
- [ ] **Task 8.3**: Assemble `limit_satisfies_c5_full` — combine Tasks 8.1-8.2 with `limit_satisfies_c5_weak` and `limit_c3_interval_subset_point`. (2h, Medium)
- [ ] **Task 8.4**: Mirror `limit_satisfies_c5'_full` for Since. (1.5h, Medium)

**Verification**: Both `limit_satisfies_c5_full` and `limit_satisfies_c5'_full` compile sorry-free. `ChronicleConstruction.lean` sorry count remains 0. `lake build` passes.

---

## Phase 9: FUC/FSC — ChronicleToCountermodel lines 615, 619

**Paper reference**: Burgess Claim 2.11, p.375 (truth lemma → countermodel coherence)  
**Status**: [NOT STARTED]  
**Effort**: 3–5 hours  
**Depends on**: Phase 8 (`limit_satisfies_c5_full`)

**Purpose**: Close the 2 sorries (FUC at line 615, FSC at line 619) in `cantor_bfmcs_restricted_fuc` within `ChronicleToCountermodel.lean`. These are the forward Until/Since coherence proofs for the Cantor-based countermodel.

**Context**: The countermodel uses `cantor_bfmcs` (Cantor-isomorphic FMCS/BFMCS families from the limit chronicle). The coherence proofs need to show:
- **FUC (forward until coherence)**: If `U(φ,ψ) ∈ mcs(t)`, then ∃s > t with `ψ ∈ mcs(s)` and ∀r(t < r < s): `φ ∈ mcs(r)`.
- **FSC (forward since coherence)**: Mirror for Since.

The transfer from the limit chronicle to the Cantor-based FMCS family relies on the Cantor isomorphism between limit_dom and ℚ. The formulas are preserved across the isomorphism (already proven in `cantor_bfmcs`). So FUC follows from `limit_satisfies_c5_full` + the Cantor transfer.

**Proof structure**: Use `limit_satisfies_c5_full` at the preimage points under the Cantor isomorphism. The Cantor isomorphism preserves the ordering and formula memberships.

**Tasks**:
- [ ] **Task 9.1**: Close FUC (line 615) — unpack the hfam hypothesis to get the Cantor preimages, apply `limit_satisfies_c5_full`, transfer back through isomorphism. (2h)
- [ ] **Task 9.2**: Close FSC (line 619) — mirror. (1.5h)

**Verification**: `ChronicleToCountermodel.lean` sorry count: 2 → 0. `cantor_bfmcs_restricted_fuc` fully proven. `lake build` passes.

---

## Phase 10: Final Audit and Integration

**Paper reference**: Full completeness theorem (Burgess §1.5, §2.11)  
**Status**: [NOT STARTED]  
**Effort**: 2–3 hours  
**Depends on**: Phase 9

**Purpose**: Verify the entire Chronicle/ directory is sorry-free and the countermodel construction delivers the representation theorem.

**Tasks**:
- [ ] **Task 10.1**: Run `#print axioms dd_countermodel_chronicle` — verify no `sorryAx`.
- [ ] **Task 10.2**: Run `grep -rn "sorry" Theories/Bimodal/Metalogic/BXCanonical/Chronicle/` — verify only comments remain.
- [ ] **Task 10.3**: Full `lake build` clean.
- [ ] **Task 10.4**: Generate summary artifact: `summaries/57_implementation-summary.md`.

**Verification**: 
- Chronicle/ sorry count: 0.
- `dd_countermodel_chronicle` has no `sorryAx` in its axioms.
- Full `lake build` clean.

---

## Testing & Validation

- [ ] `lake build` succeeds at every phase boundary.
- [ ] `#print axioms dd_countermodel_chronicle` no `sorryAx` after Phase 10.
- [ ] `grep -rn "sorry" Theories/Bimodal/Metalogic/BXCanonical/Chronicle/` only comment occurrences.
- [ ] All elimination functions' `g`-field non-empty for new adjacent pairs.
- [ ] `omega_chain` type-checks with c2' invariant (already done).

## Artifacts & Outputs

- `plans/57_burgess-aligned-plan.md` (this file)
- `reports/57_foundation-audit.md` (Phase 1)
- `summaries/57_implementation-summary.md` (Phase 10)
- Modified source files:
  - `PointInsertion.lean` (Phases 2, 3)
  - `CounterexampleElimination.lean` (Phases 4, 5, 6, 7)
  - `ChronicleConstruction.lean` (Phase 8)
  - `ChronicleToCountermodel.lean` (Phase 9)

## Rollback/Contingency

- **If `finite_stage_guard_in_g` unprovable (Phase 8)**: Fall back to a weaker C5 property that only asserts endpoint witnesses; mark the guard propagation as a known limitation, defer to a subsequent task.
- **If g-value construction too invasive (Phases 4-5)**: Start with C4 forward only (critical path), use trivial g-values for other directions, expand later.
- **Build instability**: Commit after each elimination function modification. Fix call sites incrementally.

## Reference: Axiom-to-Burgess Mapping

| Burgess Axiom | Our Code | Used In | Soundness |
|---|---|---|---|
| A1a (left mono) | BX2 | Lemma 2.7 disjunct elimination | ✓ |
| A2a (right mono) | BX3 | Lemma 2.7 disjunct elimination | ✓ |
| A3a (enrichment) | BX13 | Lemma 2.6, 2.7 seed | ✓ |
| A4a (separation) | BX14 | Lemma 2.6, 2.7 | ✓ |
| A5a (self-accum) | BX5 | Lemma 2.7 three-way | ✓ |
| A6a (converse) | BX16 | Lemma 2.6 | ✓ |
| A7a (three-way) | BX7 | Lemma 2.7 | ✓ |
| — | BX10 | Lemma 2.6, 2.7 consistency | ✓ |

## Implementation Agent Notes

1. **Follow Burgess exactly for proof structure**, translating our BX axiom replacements (BX2/BX3/BX5/BX7/BX10/BX13/BX14) for open-guard strict semantics.
2. **Argument order convention**: `untl(guard, event)` in our code = `U(event, guard)` in Burgess.
3. **Co-construct g-values** at each elimination — this is the architecture fix that cascades through all phases.
4. **Commit after each phase**, verify `lake build`, update phase status.
5. **Critical path**: Phase 3 (Lemma 2.7) → Phase 4 (C4 co-construction) → Phase 6 (c2') → Phase 8 (limit C5a full) → Phase 9 (FUC/FSC).
