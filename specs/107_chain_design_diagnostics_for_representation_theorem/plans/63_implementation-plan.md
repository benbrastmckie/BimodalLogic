# Implementation Plan: Task #107 -- Close FUC/FSC via Guard-in-B (Burgess 2.4 Enrichment)

- **Task**: 107 - chain_design_diagnostics_for_representation_theorem
- **Status**: [NOT STARTED]
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
- Modify CounterexampleElimination.lean (already sorry-free)
- Restructure the omega chain or limit construction
- Prove `omega_chain_g_stable` as a standalone lemma (the `limit_g` definition bypasses this)
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

### Phase 1: Enrich lemma_2_4 to Produce Guard in B [NOT STARTED]

**Goal**: Modify `lemma_2_4` (PointInsertion.lean:158) so its existential output includes `γ ∈ B` (the guard belongs to the interval set B), matching Burgess Lemma 2.4's guarantee.

**Paper reference**: Burgess 1982, Section 2.4 (p.371). Under our convention mapping: our `γ` (1st arg of `untl`) = Burgess's `β` (guard). Burgess explicitly states "there exist B, C such that β ∈ B."

**Strategy**:

The current `lemma_2_4` constructs C via Lindenbaum extension of `{β} ∪ g_content(A)`, then obtains B via `burgessR3Maximal_from_g_content_sub`. The seed does not include Since-obligations for the guard γ, so B does not necessarily contain γ.

To get `γ ∈ B`, enrich the C seed to include `{snce(γ, α) : α ∈ A}`. This gives `burgessRSince(C, γ, A)` (Since direction). Combined with `burgessR(A, γ, C)` (derived from the enriched seed's Until formulas via Lemma 2.3), we can apply `burgessR3Maximal_with_guard` (RRelation.lean:1593) to obtain B with `γ ∈ B`.

**Tasks**:
- [ ] **Task 1.1**: Create `until_witness_enriched_seed` -- the enriched seed `{β} ∪ g_content(A) ∪ {snce(γ, α) : α ∈ A}` or equivalent. The Since-obligation terms ensure the Lindenbaum extension D has `burgessRSince(D, γ, A)`.
- [ ] **Task 1.2**: Prove `until_witness_enriched_seed_consistent` -- consistency of the enriched seed. Use iterated BX13 enrichment (existing `iterated_enrichment` infrastructure at PointInsertion.lean:~1388) and the pattern from `lemma_2_7_seed_consistent` (PointInsertion.lean:3204, sorry-free). The key step: from `untl(γ, β) ∈ A`, apply BX13 enrichment to get `untl(γ, β ∧ S(γ, α)) ∈ A` for each `α ∈ A`, then BX10 to extract `F(β ∧ S(γ, α))` into the forward temporal witness seed.
- [ ] **Task 1.3**: Modify `lemma_2_4` to use the enriched seed. After Lindenbaum extension to MCS C: extract `snce(γ, α) ∈ C` for all `α ∈ A` from the seed. Derive `burgessRSince(C, γ, A)` from these Since memberships. Derive `burgessR(A, γ, C)` via `burgessRSince_implies_burgessR` (RRelation.lean:1322). Apply `burgessR3Maximal_with_guard` (RRelation.lean:1593) to get B with `γ ∈ B`.
- [ ] **Task 1.4**: Update `lemma_2_4`'s return type to include `γ ∈ B`: change from `∃ B C, ... ∧ BurgessR3Maximal A B C` to `∃ B C, ... ∧ γ ∈ B ∧ BurgessR3Maximal A B C`.
- [ ] **Task 1.5**: Update all callers of `lemma_2_4` to destructure the new `γ ∈ B` field. The primary caller is `eliminate_C5_counterexample` (CounterexampleElimination.lean:340). Currently discards B with `_B` at line 356. Capture it and thread through.
- [ ] **Task 1.6**: Run `lake build` and verify no regressions. The caller updates should be mechanical (adding `_` for the new field where not needed, or capturing it where needed).

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

### Phase 2: Thread Guard Through EliminationResult and Omega Chain [NOT STARTED]

**Goal**: Propagate the `γ ∈ B` information from `lemma_2_4` through the C5 elimination path so that `omega_chain_c5_witness` (ChronicleConstruction.lean:363) includes guard membership in the g-value at the elimination stage.

**Paper reference**: Burgess 2.10 (p.374). When a C5 counterexample ⟨x, ξ, η⟩ (meaning `untl(ξ,η) ∈ f(x)`) is eliminated by adding point y, the new g(x,y) = B from `lemma_2_4`, and `ξ ∈ B` by Phase 1.

**Strategy**:

Currently `eliminate_C5_counterexample` (CE:340) discards B from `lemma_2_4`. After Phase 1, B contains `ξ` (the guard). We need to:
1. Capture B in `eliminate_C5_counterexample` and assign it as g(x,y) in the new chronicle.
2. Add a `c5_forward_guard` field to `EliminationResult` (or strengthen `c5_forward_witness`).
3. Thread this through `omega_chain_elim_result` and `omega_chain_c5_witness`.

However, a simpler approach may work: since `limit_g(x,y)` is defined as `{φ | ∀ w ∈ limit_dom, x < w → w < y → φ ∈ limit_f(w)}`, we do NOT need to track guard through finite-stage g. Instead, we need to prove that ξ ∈ limit_f(w) for all intermediate w. This may follow from c2' at the finite stage + Lemma 2.5 absorption, without modifying EliminationResult at all.

Determine the approach at implementation time: either (A) thread guard through EliminationResult, or (B) prove guard propagation directly from c2' + absorption at the limit level.

**Tasks**:
- [ ] **Task 2.1**: Determine whether approach (A) or (B) is needed by inspecting the proof obligations in Phase 4. If `limit_g` can be shown to contain the guard purely from the c2' structure and Lemma 2.5, approach (B) avoids EliminationResult changes.
- [ ] **Task 2.2**: If approach (A): Add `c5_forward_guard` field to `EliminationResult` stating `pc.kind = .c5_forward → ... → pc.ξ ∈ val.g pc.x y` for the new witness y. Populate from Phase 1's enriched `lemma_2_4`.
- [ ] **Task 2.3**: If approach (A): Update `omega_chain_c5_witness` to include the guard statement: when `untl(ξ,η) ∈ f_n(x)` and the C5 witness y is added at step n+1, `ξ ∈ g_{n+1}(x,y)`.
- [ ] **Task 2.4**: If approach (B): Prove that c2' at finite stages gives BurgessR3Maximal(f(x), g(x,y), f(y)) for the (x,y) pair created at C5 elimination. The g(x,y) is the B from `lemma_2_4`, and `ξ ∈ B` from Phase 1.
- [ ] **Task 2.5**: Mirror all changes for the Since direction (C5' counterexample).
- [ ] **Task 2.6**: Run `lake build` and verify.

**Timing**: 2-3 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean` -- possibly add guard field to EliminationResult
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleConstruction.lean` -- add omega_chain_c5_guard_witness or equivalent

**Verification**:
- Guard membership is available at the omega chain level
- `lake build` passes
- No new sorry sites

---

### Phase 3: Prove Guard Propagation to Limit (omega_chain_guard_stable) [NOT STARTED]

**Goal**: Prove that if `ξ ∈ g_n(x,y)` at the stage where y was created, then for any w inserted between x and y at a later stage m, `ξ ∈ f_m(w)`. This is the key step connecting finite-stage guard membership to the limit_g universal quantifier.

**Paper reference**: Burgess 2.5 (absorption, p.370). When point z is inserted between x and y via Lemma 2.6 splitting, the new g-values satisfy B = B' ∩ D ∩ B'' where B = g(x,y), D = f(z). By Lemma 2.5, this is an equality (absorption), so g(x,y) ⊆ f(z).

**Strategy**:

The argument proceeds by induction on the omega chain stages:
1. At stage n+1 (when y was created): `ξ ∈ g_{n+1}(x,y)` from Phase 2.
2. At stage m > n+1: if z is inserted between x and y, by c2' invariant `BurgessR3Maximal(f_m(x), g_m(x,y), f_m(y))` holds. Point insertion via `lemma_2_6_splitting` gives `g_m(x,z) = B'`, `f_m(z) = D`, `g_m(z,y) = B''` with `B = B' ∩ D ∩ B''`. By Lemma 2.5 absorption, `g_m(x,y) = g_{n+1}(x,y)` (g-values are preserved). Hence `ξ ∈ g_m(x,y) ⊆ f_m(z)`.
3. Key tools: `burgessR3_absorption` (RRelation.lean:591), `omega_chain_f_agrees_le` (f-values don't change at existing points), `g_agrees` field of `EliminationResult`.

Note: we may need `omega_chain_g_agrees_le` (g-values for old pairs are preserved). Check if `g_agrees` from `EliminationResult` lifts to this.

**Tasks**:
- [ ] **Task 3.1**: Verify `omega_chain_g_agrees_le`: for x, y ∈ dom(n) and m ≥ n, `g_m(x,y) = g_n(x,y)`. This should follow from the `g_agrees` field of each EliminationResult step.
- [ ] **Task 3.2**: Prove `omega_chain_guard_stable`: if `ξ ∈ g_{n+1}(x,y)` and w ∈ dom(m) with x < w < y and m ≥ n+1, then `ξ ∈ f_m(w)`. Uses Task 3.1 + c2'/C3 at finite stages.
- [ ] **Task 3.3**: Alternative approach: since `limit_g(x,y) = {φ | ∀ w ∈ limit_dom, x < w < y → φ ∈ limit_f(w)}`, prove `ξ ∈ limit_g(x,y)` directly by showing the universal property. For any w in limit_dom between x and y, w ∈ dom(m) for some m. Then `ξ ∈ g_m(x,y) ⊆ f_m(w)` by Task 3.2, and `f_m(w) = limit_f(w)` by `limit_f_eq`.
- [ ] **Task 3.4**: Run `lake build` and verify.

**Timing**: 2 hours

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleConstruction.lean` -- add omega_chain_g_agrees_le, omega_chain_guard_stable or equivalent

**Verification**:
- Guard propagation lemma proved
- `ξ ∈ limit_g(x,y)` derivable from finite-stage guard membership
- `lake build` passes

---

### Phase 4: Prove limit_satisfies_c5_strong [NOT STARTED]

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

### Phase 5: Close FUC/FSC Sorries and Final Validation [NOT STARTED]

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

- **Phase 1 (enriched seed)**: If the enriched seed is inconsistent (unlikely given the `lemma_2_7_seed_consistent` precedent), fall back to a weaker enrichment using only `{snce(γ, α) : α ∈ g_content(A)}` instead of all `α ∈ A`. Git commit before Phase 2 enables clean rollback.

- **Phase 2 (threading guard)**: If modifying EliminationResult is too invasive, approach (B) avoids it entirely by proving guard propagation at the limit level directly from c2' + absorption.

- **Phase 3 (guard propagation)**: If `omega_chain_g_agrees_le` is blocked, prove it via a direct induction on the elimination step count using the `g_agrees` field. If Lemma 2.5 absorption does not directly give g-stability, use the explicit `lemma_2_6_splitting` output structure.

- **Phase 4 (limit_satisfies_c5_strong)**: Assembly of prior phases. If the combination is blocked, check that the witness y from `limit_satisfies_c5_weak` is the SAME y for which guard propagation was established (it must be, since both derive from the same C5 elimination step).

- **Phase 5 (FUC/FSC)**: If the Cantor isomorphism transfer is blocked, check that the Cantor map preserves the interval structure (order-preserving + surjective on limit_dom). The existing sorry-free `cantor_bfmcs_restricted_tc` demonstrates this pattern.

- **General**: Commit after each phase boundary. Any phase can be reverted by checking out the prior commit.
