# Implementation Plan: Task #107 -- Close FUC/FSC via Guard-in-B (Burgess 2.4 Enrichment)

- **Task**: 107 - chain_design_diagnostics_for_representation_theorem
- **Status**: [IMPLEMENTING]
- **Effort**: 10 hours
- **Dependencies**: None (all prerequisite infrastructure exists)
- **Research Inputs**: reports/63_team-research.md
- **Artifacts**: plans/63_implementation-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Close the 2 remaining sorry sites in the entire Chronicle construction -- Forward Until Coherence (ChronicleToCountermodel.lean:634) and Forward Since Coherence (ChronicleToCountermodel.lean:638). The root cause is that `lemma_2_4` (PointInsertion.lean:158) does not produce `guard ∈ B` in its output, which Burgess Lemma 2.4 explicitly guarantees. The fix enriches `lemma_2_4`'s seed to include Since-obligations for the guard, enabling `burgessR3Maximal_with_guard` (RRelation.lean:1593, sorry-free) to produce B with guard membership. The guard is then propagated through the omega chain via Lemma 2.5 absorption (sorry-free at RRelation.lean:591) and the `limit_g` definition to close the sorry sites. All required mathematical infrastructure exists in the codebase; no novel mathematics is needed. Definition of done: `#print axioms bx_completeness` shows no `sorryAx`; `lake build` succeeds; `grep -rn "sorry" Chronicle/` returns only comments and documentation strings.

### Research Integration

**Report 63 (team-research.md)**: Four-teammate analysis confirming root cause (unanimous) and 6-phase strategy. Key findings: (1) `burgessR3Maximal_with_guard` exists and is sorry-free. (2) `burgessRSince_implies_burgessR` exists at RRelation.lean:1322. (3) `burgessR3_absorption` (Lemma 2.5) exists at RRelation.lean:591. (4) `limit_g` is defined from `limit_f` via the C3 identity (ChronicleConstruction.lean:845-849), so guard membership at the limit reduces to guard membership at all finite-stage intermediate points. (5) CounterexampleElimination.lean is already sorry-free (0 sorry sites), contrary to the ROADMAP's stale count.

### Prior Plan Reference

Plan v62 had 6 phases (25-41h). Phases 1-3 completed: NoUnivBurgessR3 eliminated, sorry #1/#3 closed, `lemma_2_7_seed_consistent` closed. Phase 4 (c2' co-construction) appears complete since CounterexampleElimination.lean has 0 sorry sites. Phases 5-6 never started. The v62 plan's Phase 6 assumed C3 at the limit suffices for FUC/FSC, but the actual dependency requires guard-in-B propagation through the omega chain -- this is the focus of the current plan.

### Roadmap Alignment

- Task 107 is the primary completeness path (Chronicle construction)
- Advances: "2 sorry sites remain across 1 file" toward 0
- Closes the completeness theorem for TM bimodal logic (representation theorem goal)

## Goals & Non-Goals

**Goals**:
- Enrich `lemma_2_4` to produce `guard ∈ B` in its existential output
- Prove `omega_chain_guard_in_g`: at the finite stage where a C5 witness y is created, the guard ξ belongs to g(x,y)
- Prove `limit_satisfies_c5_strong`: the strengthened C5 with guard at intermediate points
- Close FUC sorry (ChronicleToCountermodel.lean:634) via `limit_satisfies_c5_strong` + Cantor isomorphism
- Close FSC sorry (ChronicleToCountermodel.lean:638) via mirror
- Deliver fully sorry-free `bx_completeness` with no `sorryAx` dependency

**Non-Goals**:
- Restructure the omega chain or limit construction beyond Burgess alignment
- Generalize beyond D=Rat

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Enriched seed for `lemma_2_4` may be inconsistent | Blocks Phase 1 | Low | Research confirmed the pattern mirrors `lemma_2_7_seed_consistent` (already closed). The additional `snce(guard, α)` terms use the same BX13+BX5 chain. |
| `omega_chain_guard_in_g` requires tracking guard through EliminationResult c2' | Blocks Phase 3 | Medium | The finite-stage c2' (already proved) gives BurgessR3Maximal on adjacent pairs. Guard membership in B follows from the enriched `lemma_2_4` output. The key question is whether this propagates through non-adjacent pairs via `lemma_2_6_splitting`. |
| Cantor isomorphism transfer for guard at intermediate points may require new infrastructure | Blocks Phase 5 | Low | The existing `cantor_bfmcs_restricted_tc` (lines 456-501) shows the transfer pattern. The guard condition maps through the same isomorphism. |
| `limit_g` definition is a universal quantifier over limit_dom, requiring guard at ALL intermediate points | Blocks Phase 4 | Medium | By construction, any w inserted between x and y at stage m has f_m(w) ⊇ g_m(x,y) (from c2'/C3 at finite stages). Guard ∈ g_n(x,y) from Phase 2, and g_n(x,y) ⊆ g_m(x,y) by Lemma 2.5 absorption. The chain: guard ∈ g_n(x,y) ⊆ g_m(x,y) ⊆ f_m(w) ⊆ limit_f(w). |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5 | 4 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Enrich lemma_2_4 to Produce Guard in B [COMPLETED]

**Goal**: Modify `lemma_2_4` (PointInsertion.lean:158) so its existential output includes `γ ∈ B` (the guard belongs to the interval set B), matching Burgess Lemma 2.4's guarantee.

**Paper reference**: Burgess 1982, Section 2.4 (p.371). Under our convention mapping: our `γ` (1st arg of `untl`) = Burgess's `β` (guard). Burgess explicitly states "there exist B, C such that β ∈ B."

**Strategy**:

The current `lemma_2_4` constructs C via Lindenbaum extension of `{β} ∪ g_content(A)`, then obtains B via `burgessR3Maximal_from_g_content_sub`. The seed does not include Since-obligations for the guard γ, so B does not necessarily contain γ.

To get `γ ∈ B`, enrich the C seed to include `{snce(γ, α) : α ∈ A}`. This gives `burgessRSince(C, γ, A)` (Since direction). Combined with `burgessR(A, γ, C)` (derived from the enriched seed's Until formulas via Lemma 2.3), we can apply `burgessR3Maximal_with_guard` (RRelation.lean:1593) to obtain B with `γ ∈ B`.

**Implementation note**: Created `lemma_2_4_with_guard` as a SEPARATE function (PointInsertion.lean:4832-4973) rather than modifying `lemma_2_4` directly, to avoid touching 3 callers that don't need guard. Phase 2 C5 callers use the new function.

**Tasks**:
- [x] **Task 1.1**: Created `until_witness_enriched_seed_consistent` — proves consistency of the enriched seed `{β} ∪ g_content(A) ∪ {snce(γ, α) : α ∈ A}`. Uses BX13 enrichment + BX10 + BX3' right-monotonicity + derivation_from_implied.
- [x] **Task 1.2**: Created `lemma_2_4_with_guard` — strengthened version of `lemma_2_4` that returns `γ ∈ B` (guard in interval DCS). Uses enriched seed → burgessRSince(C, γ, A) → burgessR(A, γ, C) → burgessR3Maximal_with_guard.
- [x] **Task 1.3**: `lake build` passes. No new sorries. 2 existing sorry sites remain at ChronicleToCountermodel.lean:634,638.

**Completed**: 2026-05-06

**Timing**: 3-4 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean` -- enrich seed, prove consistency, modify lemma_2_4, update return type
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean` -- update destructuring at callers of lemma_2_4

**Verification**:
- `lemma_2_4` returns `γ ∈ B` in its existential
- All callers updated and compile
- `lake build` passes
- No new sorry sites introduced

---

### Phase 2: Thread Guard Through EliminationResult and Omega Chain [COMPLETED]

**Goal**: Propagate the `γ ∈ B` information from `lemma_2_4` through the C5 elimination path so that the guard is in g(x,y) at the elimination stage. Fix `lemma_2_7` to produce `B ⊆ B'` (matching Burgess 2.7). Align the forward/backward walk condition with Burgess 2.10's full condition (i) to ensure guard ∈ g at every walk step.

**Paper reference**: Burgess 2.7 (p.372): B' seeded from B gives B ⊆ B'. Burgess 2.10 (p.374): condition (i) requires BOTH `η ∧ U(ξ,η) ∈ f(x')` AND `η ∈ g(x,x')`. Our code was missing the second part, causing the forward walk to advance past points where guard ∉ g.

**Tasks**:
- [x] **Task 2.A (Blocker fix)**: Fixed `lemma_2_7` — changed B' seed from DC({xi}) to B, giving `B ⊆ B'` instead of `xi ∈ B'`. Deleted ~120 lines of degenerate case code. (PointInsertion.lean:3616)
- [x] **Task 2.B**: Enriched `lemma_2_7_since` — added `B ⊆ B'` to output type. (PointInsertion.lean:4364)
- [x] **Task 2.C**: Updated 4 call sites in CounterexampleElimination.lean for new `lemma_2_7_since` 8-tuple output.
- [x] **Task 2.D**: Added `omega_chain_g_eq_elim`, `omega_chain_g_agrees`, `omega_chain_g_agrees_le` to ChronicleConstruction.lean — g-value tracking infrastructure.
- [x] **Task 2.E**: `lake build` passes after Tasks 2.A-D. 2 sorry sites remain at CTC:634,638.
- [x] **Task 2.F (Burgess alignment)**: Aligned forward walk condition (i) with Burgess 2.10. Changed `h_cond_i` from `conj ∈ f(x')` to `conj ∈ f(x') ∧ guard ∈ g(x, x')` (CounterexampleElimination.lean:796). Updated 1 usage site in the negated branch where `h_cond_i` was used to derive `conj ∉ f(x')`. This ensures the walk only advances when guard ∈ g, so C3 propagation works at the limit.
- [x] **Task 2.G (Since mirror)**: Applied same condition (i) fix to backward walk: `h_cond_i_back` now checks `conj_since ∈ f(x'') ∧ guard ∈ g(x'', pc.x)` (CounterexampleElimination.lean:1464). Updated 1 usage site.
- [x] **Task 2.H**: `lake build` passes after Tasks 2.F-G. 2 sorry sites remain at CTC:634,638.

**Completed**: 2026-05-06

**Timing**: 3 hours

**Depends on**: 1

**Files modified**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean` -- lemma_2_7 fix, lemma_2_7_since enrichment
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean` -- call site updates, Burgess 2.10 condition (i) alignment (forward + backward)
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleConstruction.lean` -- omega_chain_g_agrees infrastructure

**Verification**:
- Guard membership propagates correctly through the walk via Burgess 2.10 condition (i)
- All splitting lemmas produce B ⊆ B' (seed from B via Zorn)
- All splitting lemmas produce B ⊆ D (seed includes B)
- `lake build` passes
- No new sorry sites

---

### Phase 3: Prove Guard Propagation to Limit (omega_chain_guard_stable) [IN PROGRESS]

**Goal**: Prove that if `ξ ∈ g_n(x,y)` at the stage where y was created, then for any w inserted between x and y at a later stage m, `ξ ∈ f_m(w)`. This is the key step connecting finite-stage guard membership to the limit_g universal quantifier.

**Paper reference**: Burgess 2.5 (absorption, p.370) and 2.10 (p.374). With Burgess's full condition (i) aligned in Phase 2, the guard propagates via two mechanisms:
1. **Walk region** (x to u_max): At each walk step, guard ∈ g(w, w') by condition (i). When a new point is inserted between walk-adjacent w and w', the seed B = g(w, w') contains guard, so guard ∈ D = f(new_point) (from B ⊆ D). And guard ∈ g(w, z) = B' (from B ⊆ B').
2. **Splitting region** (u_max to y): guard ∈ g(u_max, y) from lemma_2_4/2_7 enrichment (Phase 1). Propagation through the splitting tree by B ⊆ B' and B ⊆ D at each level.

**Strategy**:

By induction on the splitting tree within the omega chain:
1. Base: At stage n+1 (when y was created), guard ∈ g(a, b) for all adjacent pairs (a, b) between x and y, where:
   - For walk pairs: guard ∈ g(a, b) from Burgess condition (i) second part
   - For the splitting pair (u_max, y): guard ∈ g(u_max, y) from lemma_2_4 enrichment
2. Step: When (a, b) is split by inserting z: g(a, z) = B' with B ⊆ B', f(z) = D with B ⊆ D, g(z, b) = B'' with B ⊆ B''. So guard ∈ B ⊆ D = f(z), and guard ∈ B' = g(a, z), guard ∈ B'' = g(z, b).
3. Lift to limit: `limit_g(x,y) = {φ | ∀ w ∈ limit_dom, x < w < y → φ ∈ limit_f(w)}`. For any w, w ∈ dom(m) for some m, and guard ∈ f_m(w) by the induction above. Since f_m(w) = limit_f(w), guard ∈ limit_f(w).

Key tools: `omega_chain_g_agrees_le` (proved in Phase 2), `omega_chain_f_agrees_le`, `burgessR3_absorption` (RRelation.lean:591).

**Tasks**:
- [x] **Task 3.1**: `omega_chain_g_agrees_le` proved in Phase 2 (Task 2.D). For x, y ∈ dom(n) and m ≥ n, `g_m(x,y) = g_n(x,y)`.
- [ ] **Task 3.2**: Prove `omega_chain_guard_at_intermediate`: if ξ ∈ g_{n+1}(x,y) and (x,y) adjacent at stage n+1, and w ∈ dom(m) with x < w < y and m ≥ n+1, then ξ ∈ f_m(w). Proof by induction on m - (n+1), using g_agrees (g-values preserved for old pairs) and B ⊆ D (from seed of all splitting lemmas).
- [ ] **Task 3.3**: Prove `omega_chain_guard_in_limit_g`: if ξ ∈ g_{n+1}(x,y) at stage n+1, then ξ ∈ limit_g(x,y). Uses Task 3.2 + limit_f_eq.
- [ ] **Task 3.4**: Run `lake build` and verify.

**Timing**: 2 hours

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleConstruction.lean` -- add omega_chain_guard_at_intermediate, omega_chain_guard_in_limit_g

**Verification**:
- Guard propagation lemma proved
- `ξ ∈ limit_g(x,y)` derivable from finite-stage guard membership
- `lake build` passes

---

### Phase 4: Prove limit_satisfies_c5_strong [PARTIAL]

**Goal**: Prove the strengthened C5 at the limit: `untl(ξ,η) ∈ limit_f(x) → ∃ y > x, η ∈ limit_f(y) ∧ ξ ∈ limit_g(x,y)`. This is the full Burgess C5 with the guard condition.

**Paper reference**: Burgess 2.11 (truth lemma, p.375). The Until case: if `U(γ,β) ∈ f(x)`, then by C5a there exists y > x with `β ∈ f(y)` and `γ ∈ g(x,y)`. By C3, `γ ∈ f(z)` for all z between x and y.

**Strategy**:

Combine `limit_satisfies_c5_weak` (already proved, ChronicleConstruction.lean:590) with Phase 3's guard propagation:
1. `limit_satisfies_c5_weak` gives: ∃ y > x, η ∈ limit_f(y).
2. Phase 3 gives: ξ ∈ limit_g(x,y) (guard at all intermediate points).
3. The combined statement is `limit_satisfies_c5_strong`.

Mirror: `limit_satisfies_c5'_strong` for Since.

**Tasks**:
- [ ] **Task 4.1**: State and prove `limit_satisfies_c5_strong`:
  ```
  untl ξ η ∈ limit_f(x) →
  ∃ y ∈ limit_dom, x < y ∧ η ∈ limit_f(y) ∧ ξ ∈ limit_g(x,y)
  ```
  Proof: (1) Apply `limit_satisfies_c5_weak` for the witness y. (2) Apply Phase 3's guard propagation for `ξ ∈ limit_g(x,y)`.
- [ ] **Task 4.2**: State and prove `limit_satisfies_c5'_strong` (Since mirror).
- [ ] **Task 4.3**: Run `lake build` and verify.

**Timing**: 1-2 hours

**Depends on**: 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleConstruction.lean` -- add limit_satisfies_c5_strong, limit_satisfies_c5'_strong

**Verification**:
- Both strong C5/C5' lemmas proved
- `lake build` passes

---

### Phase 5: Close FUC/FSC Sorries and Final Validation [PARTIAL]

**Goal**: Close the 2 remaining sorry sites at ChronicleToCountermodel.lean:634 (FUC) and :638 (FSC), then verify the entire completeness theorem is sorry-free.

**Paper reference**: Burgess 2.11 (truth lemma, p.375). Transfer from the chronicle limit to the Cantor-indexed countermodel.

**Strategy**:

The sorry sites are in `cantor_bfmcs_restricted_fuc` (ChronicleToCountermodel.lean:622). The proof must show:
- FUC: `untl(φ,ψ) ∈ mcs(t) → ∃ s > t, ψ ∈ mcs(s) ∧ ∀ r, t < r → r < s → φ ∈ mcs(r)`
- FSC: `snce(φ,ψ) ∈ mcs(t) → ∃ s < t, ψ ∈ mcs(s) ∧ ∀ r, s < r → r < t → φ ∈ mcs(r)`

The `mcs` function maps through the Cantor isomorphism to `limit_f`. Apply `limit_satisfies_c5_strong` from Phase 4, then transfer through the Cantor isomorphism (same pattern as existing sorry-free `cantor_bfmcs_restricted_tc` at lines 456-501).

The guard condition `∀ r, t < r → r < s → φ ∈ mcs(r)` transfers from `φ ∈ limit_g(x,y)` via the Cantor isomorphism's order-preservation and the `limit_c3_interval_subset_point` lemma.

**Tasks**:
- [ ] **Task 5.1**: Close FUC sorry (ChronicleToCountermodel.lean:634). Apply `limit_satisfies_c5_strong`, transfer through Cantor isomorphism.
- [ ] **Task 5.2**: Close FSC sorry (ChronicleToCountermodel.lean:638). Mirror of Task 5.1 using `limit_satisfies_c5'_strong`.
- [ ] **Task 5.3**: Final audit: run `#print axioms bx_completeness` and verify no `sorryAx`.
- [ ] **Task 5.4**: Run `grep -rn "sorry" Theories/Bimodal/Metalogic/BXCanonical/Chronicle/` -- verify only comment/documentation occurrences.
- [ ] **Task 5.5**: Run `grep -n "sorry" Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` -- verify only comment occurrences.
- [ ] **Task 5.6**: Full `lake build` clean from scratch.

**Timing**: 2 hours

**Depends on**: 4

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` lines 634, 638 -- close FUC/FSC sorries

**Verification**:
- Sorries at lines 634 and 638 both closed
- ChronicleToCountermodel.lean sorry count: 0 (actual sorry statements)
- `bx_completeness` has no `sorryAx` in its axioms
- `grep -rn "sorry" Chronicle/` returns only comment/documentation occurrences
- Full `lake build` passes cleanly
- Total sorry count across Chronicle: 0 on critical path

---

## Testing & Validation

- [ ] `lake build` succeeds at every phase boundary (Phases 1-5)
- [ ] `#print axioms bx_completeness` -- no `sorryAx` after Phase 5
- [ ] `grep -rn "sorry" Theories/Bimodal/Metalogic/BXCanonical/Chronicle/` -- only comment/doc occurrences
- [ ] `grep -n "sorry" Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` -- only comment occurrences
- [ ] Convention alignment maintained: `untl(guard, event)` = Burgess `U(event, guard)` throughout
- [ ] No density or discreteness axioms added
- [ ] `irr_until` axiom NOT used anywhere
- [ ] All new lemmas follow Burgess 1982 exactly -- no novel mathematical approaches

## Artifacts & Outputs

- `specs/107_chain_design_diagnostics_for_representation_theorem/plans/63_implementation-plan.md` (this file)
- `specs/107_chain_design_diagnostics_for_representation_theorem/summaries/63_execution-summary.md` (after Phase 5)
- Modified source files:
  - `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean` (Phase 1: enriched seed, modified lemma_2_4)
  - `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean` (Phase 1-2: caller updates, possibly guard field)
  - `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleConstruction.lean` (Phases 2-4: guard propagation, limit_satisfies_c5_strong)
  - `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` (Phase 5: close FUC/FSC)

## Rollback/Contingency

- **Phase 1 (enriched seed)**: COMPLETED. No rollback needed.

- **Phase 2 (Burgess alignment)**: COMPLETED. The Burgess 2.10 condition (i) fix (guard ∈ g check) resolves the forward walk region gap. No EliminationResult modification was needed — the fix was a 2-line condition change.

- **Phase 3 (guard propagation)**: The main risk is formalizing the induction on the splitting tree within the omega chain. If direct induction on `m - (n+1)` is difficult due to the noncomputable omega chain, an alternative is to prove a standalone lemma about `eliminate_potential_counterexample` preserving guard membership in g-values of old pairs.

- **Phase 4 (limit_satisfies_c5_strong)**: Assembly of prior phases. The witness y from `limit_satisfies_c5_weak` must be the SAME y for which guard propagation was established (both derive from the same C5 elimination step at the same omega chain stage).

- **Phase 5 (FUC/FSC)**: The Cantor isomorphism transfer follows the pattern of `cantor_bfmcs_restricted_tc` (lines 456-501). The guard condition `∀ r, t < r → r < s → φ ∈ mcs(r)` is equivalent to `φ ∈ limit_g(x, y)` because `cantor_iso` is an order isomorphism and `limit_g` is defined universally.

- **General**: Commit after each phase boundary. Phases 1-2 already committed.
