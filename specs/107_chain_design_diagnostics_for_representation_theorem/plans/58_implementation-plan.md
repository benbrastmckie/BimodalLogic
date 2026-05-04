# Implementation Plan: Task #107 — Chronicle Construction for BX Completeness

- **Task**: 107 - chain_design_diagnostics_for_representation_theorem
- **Status**: [NOT STARTED]
- **Effort**: 25-35 hours
- **Dependencies**: N/A (self-contained within Chronicle/; omega_chain Phase 6 already complete, Lemma 2.4 and Lemma 2.6 splitting already sorry-free)
- **Research Inputs**:
  - `reports/55_burgess-construction-step-by-step.md` — Complete step-by-step Burgess 1982 analysis (Sections 2.1-2.11), 12 sorries inventoried, dependency chain mapped, proof chains decomposed into atomic steps
  - `reports/54_burgess-semantic-alignment.md` — Open-guard semantics confirmed, Path A (full Burgess D0 chain) recommended
  - `literature/Burgess_1982_Axioms_for_tense_logic_Since_and_Until.md` — Primary mathematical reference, Sections 2.4-2.11
- **Artifacts**: plans/58_implementation-plan.md (this file)
- **Standards**: plan-format.md; status-markers.md; artifact-management.md; tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Close all 12 remaining sorries across PointInsertion.lean (3), CounterexampleElimination.lean (7), and ChronicleToCountermodel.lean (2) by implementing Burgess 1982's chronicle construction faithfully, lemma-by-lemma. The root issue across all sorries is the same: elimination functions produce endpoint MCSs but discard interval DCSs (g-values). After this plan, every new adjacent pair created during C4/C5/C4'/C5'/density elimination will have populated g-values satisfying `BurgessR3Maximal`, and the limit C5a/C5b properties with full guard propagation will be provable using C3 and the Cantor transfer. The final countermodel `dd_countermodel_chronicle` will be fully sorry-free.

### Research Integration

Report 55 provides an exhaustive, faithful walkthrough of every step in Burgess 1982's completeness proof, Sections 2.1-2.11, decomposed into numbered atomic steps that directly map to what must be implemented. Key findings:

- **Lemma 2.7 proof chain**: BX5 (self-accumulation) -> BX7 (three-way disjunction) -> BX14 (separation) -> BX13 (enrichment) -> BX10 (consistency). D1 and D2 disjuncts are eliminated via left-mono + right-mono to derive U(gamma, beta^eta) which contradicts ~U(gamma, beta^eta) in A. D3 survives because left-mono reduces event to beta not gamma, avoiding the contradiction.
- **C4 hard cases**: Solved via `BurgessR3Maximal_extension_fails` bridging from c2' (BurgessR3Maximal at adjacent pairs).
- **Limit C5 full**: Uses `limit_g` defined as formulas true at all intermediate points, combined with C3 three-way property.

Report 54 confirms: Burgess uses open-guard semantics (identical to ours). A3a (BX13) and A4a (BX14) are valid and present with sorry-free soundness. Path A (full Burgess D0 chain) is the only mathematically correct option.

## Goals & Non-Goals

**Goals**:
- Close all 12 sorries: 3 in PointInsertion.lean, 7 in CounterexampleElimination.lean, 2 in ChronicleToCountermodel.lean
- Co-construct endpoint MCS and interval DCS at every elimination step (Burgess Sections 2.9, 2.10)
- Prove `limit_satisfies_c5_full` and `limit_satisfies_c5'_full` (guard at intermediate domain points)
- Close FUC/FSC and deliver fully sorry-free `dd_countermodel_chronicle`

**Non-Goals**:
- Rewrite the elimination algorithm with Burgess's induction-on-intermediate-points structure (flat approach is equivalent)
- Introduce new axioms or change semantics
- Modify limit_dom, limit_f, limit_g, limit_c3 (all already sorry-free)
- Add Lemma 2.8 as a separate theorem (absorbed into Lemma 2.7 via strengthened gamma parameter)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Lemma 2.7 BX7 three-way combinatorially blocked | Delays Phase 3 by 3-5h | Medium | Use `lce_imp`/`rce_imp` for propositional simplifications; `untl_left_mono_deriv`/`untl_right_mono_deriv` already available |
| `finite_stage_guard_in_g` lemma unprovable (Phase 7) | Blocks limit C5a | Low | The limit_g is defined as formulas true at ALL intermediates; `limit_satisfies_c5_full` is provable directly from limit_g definition + `limit_satisfies_c5_weak` |
| g-value construction breaks all call sites | Build churn | High | Commit after each elimination function change; fix call sites incrementally |
| C4 hard cases remain blocked | Delays Phase 6 | Low | `BurgessR3Maximal_extension_fails` for gamma not in g(w,w_next) bridges back to original counterexample |
| Lemma 2.6 inconsistent case sub-case B contradiction | Delays Phase 2 by 1-2h | Low | Sub-case B already proven impossible via `F(bottom) in A` contradiction in plan 57 analysis; implement directly |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 3 | 1 |
| 3 | 4 | 2, 3 |
| 4 | 5 | 4 |
| 5 | 6 | 5 |
| 6 | 7 | 5 |
| 7 | 8 | 7 |

Phases within the same wave can execute in parallel. Phases 2 and 3 are independent of each other (both only need Phase 1). Phases 4-8 are sequential on the critical path.

Critical path: Phase 3 -> Phase 4 -> Phase 5 -> Phase 7 -> Phase 8 (20-27h).

---

### Phase 1: Foundation Audit and Interface Verification [NOT STARTED]

- **Goal**: Verify that all existing infrastructure is correct and interfaces expose needed components before beginning implementation. Audit lemma outputs, BX axiom wrappers, and argument conventions.

- **Tasks**:
  - [ ] **Task 1.1**: Audit `lemma_2_4` (PointInsertion.lean:153) — verify the interval DCS B is returned and accessible in the output type. If return type buries B, restructure to expose it.
  - [ ] **Task 1.2**: Audit `lemma_2_6_splitting` (PointInsertion.lean:2328) — verify B', D, B'' all accessible with `BurgessR3Maximal` proofs. Confirm callers can extract each.
  - [ ] **Task 1.3**: Verify BX axiom MCS-level wrappers exist: BX5 (`self_accum_until_mcs`), BX7 (`linear_until_mcs`), BX10 (`until_implies_F_mcs`), BX13 (enrichment), BX14 (separation), left/right monotonicity (`untl_left_mono_deriv`, `untl_right_mono_deriv`).
  - [ ] **Task 1.4**: Verify `iterated_enrichment` works for both Lemma 2.6 (packing snce-formulas via guard q) and Lemma 2.7 (packing snce-formulas with `beta∧eta` guards).
  - [ ] **Task 1.5**: Add argument-order convention comments at top of PointInsertion.lean, CounterexampleElimination.lean, ChronicleConstruction.lean documenting that `untl(guard, event)` in our code = `U(event, guard)` in Burgess.

- **Timing**: 2 hours
- **Depends on**: none

- **Verification**: `lake build` passes. Audit results documented inline or in task notes.

---

### Phase 2: Lemma 2.6 — Inconsistent Case [NOT STARTED]

- **Goal**: Close the 2 sorries `h_ev_b` and `h_ev_untl` at PointInsertion.lean lines 1872-1873 in `burgess_D0_finite_subset_consistent_incons`. These require proving that the enriched event formula implies the guard `b` and the accumulated Until `untl(b, gamma_hat)`.

- **Paper reference**: Burgess Section 2.6, p.370-371 (D0 seed consistency, inconsistent sub-case)

- **Context**: When `{beta}∪B` is inconsistent, `beta.neg ∈ B`. The D0 seed simplifies. The enrichment `iterated_enrichment` gives `event -> gamma_hat` (the base event), but not `event -> b` or `event -> untl(b, gamma_hat)`. These come from BX14 separation applied to `~untl(b∧beta, gamma_hat) ∈ A`.

- **Proof approach** (from Report 55): **MCS case split** on membership of `untl(b∧beta, gamma_hat)` in `A`:

  **Sub-case A** (`~untl(b∧beta, gamma_hat) ∈ A`): Apply BX14 directly, then reuse `burgess_zeta_consistent` (line 1251) which internally chains BX5 -> BX14 -> BX13 -> BX10 to produce all five needed components, including the `event -> b` and `event -> untl(b, gamma_hat)` derivations.

  **Sub-case B** (`untl(b∧beta, gamma_hat) ∈ A`): Since `b -> beta.neg` (beta.neg ∈ B ⊆ b_list), we have `|- (b∧beta) -> bottom`. Left_mono gives `untl(bottom, gamma_hat) ∈ A`. By BX10, `F(bottom) ∈ A`. But `G(top) ∈ A` by `theorem_in_mcs`. Since `F(bottom) = ~G(top)`, this contradicts MCS consistency. So Sub-case B is impossible.

- **Tasks**:
  - [ ] **Task 2.1**: Implement MCS case split. Prove Sub-case A by reusing `burgess_zeta_consistent` output to fill `h_ev_b` and `h_ev_untl`. (1.5h)
  - [ ] **Task 2.2**: Prove Sub-case B impossible via `F(bottom) ∈ A` contradiction using the chain: `untl(b∧beta, gamma_hat) ∈ A` -> left_mono with `b -> beta.neg` -> `untl(bottom, gamma_hat) ∈ A` -> BX10 -> `F(bottom) ∈ A` -> contradiction with `G(top) ∈ A` via `theorem_G_top`. (1h)
  - [ ] **Task 2.3**: Integrate both sub-cases, remove sorries, verify full function compiles. (0.5h)

- **Timing**: 3-4 hours
- **Depends on**: 1

- **Verification**: `PointInsertion.lean` sorry count: 3 -> 1. `lake build` passes.

---

### Phase 3: Lemma 2.7 — Seed Consistency (C5 Nested Case) [NOT STARTED]

- **Goal**: Implement the complete body of `lemma_2_7_seed_consistent` (PointInsertion.lean line 2405, currently fully sorry). This is the hardest single theorem in the chronicle construction.

- **Paper reference**: Burgess Section 2.7, p.372 (Until-formula splitting with BX7 three-way disjunction)

- **Purpose**: Prove consistency of the Lemma 2.7 D0 seed:
  ```
  lemma_2_7_seed = B ∪ {xi} ∪ {untl(beta,gamma): beta∈B, gamma∈C}
                   ∪ {snce(beta,alpha): beta∈B, alpha∈A}
                   ∪ {snce(beta∧eta,alpha): beta∈B, alpha∈A}
  ```

- **Proof chain** (10 steps, matching the TODO comment at lines 2393-2403):
  1. **Witness extraction**: From `eta ∉ B` + maximality, extract beta0 ∈ B, gamma0 ∈ C with `~untl(beta0∧eta, gamma0) ∈ A` using `BurgessR3Maximal_extension_fails` + `dc_delta_B_controlled`.
  2. **BX5 on `untl(beta0, gamma0)`**: Get `untl(beta0∧untl(beta0,gamma0), gamma0) ∈ A`.
  3. **BX5 on `untl(xi, eta)`**: Get `untl(xi∧untl(xi,eta), eta) ∈ A`.
  4. **BX7 three-way disjunction** on these two -> D1 ∨ D2 ∨ D3, all in A by MCS disjunction property.
  5. **Eliminate D1**: Event contains `eta∧gamma0`; left_mono reduces event to gamma0, right_mono on guard containing `beta0∧eta` -> `untl(gamma0, beta0∧eta) ∈ A`, contradicting step 1.
  6. **Eliminate D2**: Event contains `eta`. Similar left_mono + right_mono to derive contradiction with step 1.
  7. **D3 survives**: `untl(phi1∧phi2, (xi∧untl(xi,eta))∧gamma0) ∈ A` where `phi1=xi∧untl(xi,eta)`, `phi2=beta0∧untl(beta0,gamma0)`. Event is `beta0∧untl(beta0,gamma0)∧xi`, guard contains eta.
  8. **BX14 separation**: Apply A4a with `p=gamma0`, `q=beta0∧untl(beta0,gamma0)∧xi` and `r=beta0∧eta`, using `~untl(gamma0, beta0∧eta) ∈ A` from step 1.
  9. **BX13 iterated enrichment**: Pack `snce(alpha, beta∧eta)` formulas for alpha∈A into event via enrichment_from_until.
  10. **BX10 consistency**: `F(event) ∈ A` -> event consistent -> D0 seed consistent.

- **Key technical note**: Under our convention (`untl(guard, event)` = Burgess `U(event, guard)`), the BX7 three-way produces three disjuncts with DIFFERENT events but the same guard theta = `beta0∧untl(beta0,gamma0)∧eta∧untl(xi,eta)`. D1 and D2 are eliminated because left_mono on their events (which contain eta/gamma0) reduces to an event that, combined with the guard containing beta0∧eta, produces `untl(gamma0, beta0∧eta)` contradicting the witness. D3 survives because its event contains `beta0` as the leftmost component, and left_mono on `beta0∧untl(beta0,gamma0)∧xi -> beta0` produces `untl(beta0, ...)` which does NOT directly contradict the `~untl(gamma0, beta0∧eta)` witness.

- **Tasks**:
  - [ ] **Task 3.1**: Implement `lemma_2_7_neg_untl_exists` — extract beta0, gamma0 witness using `BurgessR3Maximal_extension_fails` + `dc_delta_B_controlled`. (1-1.5h)
  - [ ] **Task 3.2**: Apply BX5 self-accumulation on both Until formulas (`untl(beta0,gamma0)` and `untl(xi,eta)`). Verify `self_accum_until_mcs` wrapper works for both. (0.5h)
  - [ ] **Task 3.3**: Apply BX7 three-way disjunction to produce D1 ∨ D2 ∨ D3. Verify the exact form of `linear_until_mcs` and confirm it produces the correct disjuncts under our argument convention. (1h)
  - [ ] **Task 3.4**: Eliminate D1 — left_mono on event `gamma0∧(xi∧untl(xi,eta)) -> gamma0`, right_mono on guard theta -> `beta0∧eta` to get `untl(gamma0, beta0∧eta) ∈ A`, contradicting step 1. (1h)
  - [ ] **Task 3.5**: Eliminate D2 — mirror of D1 with left_mono on `gamma0∧(eta∧untl(xi,eta)) -> gamma0`. (1h)
  - [ ] **Task 3.6**: Work with surviving D3. Simplify the guard from `theta` to `beta0∧eta` using right_mono (since `theta -> beta0∧eta`). This gives `untl(beta0∧untl(beta0,gamma0)∧xi, beta0∧eta) ∈ A`. (1h)
  - [ ] **Task 3.7**: Apply BX13 iterated enrichment + BX10 consistency to derive F(event) ∈ A, proving event consistency and thus D0 seed consistency. (1.5h)
  - [ ] **Task 3.8**: Assemble and close `lemma_2_7_seed_consistent`, then verify `lemma_2_7` (line 2416, currently depends on seed) still compiles. (1h)

- **Timing**: 6-8 hours
- **Depends on**: 1

- **Verification**: `PointInsertion.lean` sorry count: 1 -> 0. `lemma_2_7` compiles. `lake build` passes.

---

### Phase 4: C4/C5 Elimination — Co-Constructed g-Values [NOT STARTED]

- **Goal**: Rewrite C4, C4', C5, C5' elimination functions in CounterexampleElimination.lean to populate g-values at new adjacent pairs. Currently these functions return `chi.g` unchanged for g-values. After this phase, g-values at new adjacent pairs will satisfy `BurgessR3Maximal`.

- **Paper reference**: Burgess Sections 2.9 (p.373) and 2.10 (p.374)

- **What changes across all four functions**:
  - Return type can no longer claim `(forall a b, chi'.g a b = chi.g a b)` globally.
  - New adjacent pairs must have populated g-values from the insertion lemma used.

  **C5 forward** (`eliminate_C5_counterexample`, line 167):
  - Base case (n=0): `lemma_2_4` returns `(B, C)` with `BurgessR3Maximal f(x) B C`. Set `g'(x, y) = B`.
  - Inductive case: Handled at omega-chain level; each step adds y beyond all current points.

  **C4 forward** (`eliminate_C4_counterexample`, line 304):
  - Base case (n=0): `lemma_2_6_splitting` returns `B', D, B''`. Set `g'(x,z) = B'`, `g'(z,y) = B''`.
  - Inductive case: Locates rightmost w with `~U(gamma,delta) ∈ f(w)` and successor w_next. Lemma 2.6 applies to the adjacent pair (w, w_next), then C3 determines other g-values involving z.
  - Easy cases (`~gamma ∈ f(x)` or `~gamma ∈ f(y)`): Use trivial g-values via `burgessR3Maximal_singleton`.

  **C5'/C4' backward**: Mirror images for Since direction.

- **Tasks**:
  - [ ] **Task 4.1**: Rewrite `eliminate_C5_counterexample` — extract B from `lemma_2_4`, set `g'(x, y) = B`. Update return type to allow g_changed for the new pair. (1.5h)
  - [ ] **Task 4.2**: Rewrite `eliminate_C5'_counterexample` — mirror for Since. (1h)
  - [ ] **Task 4.3**: Rewrite `eliminate_C4_counterexample` — call `lemma_2_6_splitting`, set `g'(x,z)=B'`, `g'(z,y)=B''`. Handle easy cases with `burgessR3Maximal_singleton`. Update return type. (2h)
  - [ ] **Task 4.4**: Rewrite `eliminate_C4'_counterexample` — mirror for Since. (1.5h)
  - [ ] **Task 4.5**: Fix call sites in `eliminate_potential_counterexample` and `omega_chain`. Verify `omega_chain` still compiles with changed return types. (1h)

- **Timing**: 5-7 hours
- **Depends on**: 2, 3

- **Verification**: `lake build` succeeds after each atomic change. All four elimination functions compile. New adjacent pairs have non-empty g-values satisfying `BurgessR3Maximal`.

---

### Phase 5: c2' Maintenance — BurgessR3Maximal at All Adjacent Pairs [NOT STARTED]

- **Goal**: Close all 5 `c2'` sorries (lines 756, 794, 834, 872, 918) in `EliminationResult` within `eliminate_potential_counterexample` in CounterexampleElimination.lean.

- **Paper reference**: Burgess Section 2.5 (C2' condition — BurgessR3Maximal at adjacent pairs)

- **Proof strategy per branch**: For each elimination branch, prove `BurgessR3Maximal` at every adjacent pair in the new chronicle:
  - **Old adjacent pairs** (both endpoints in original domain): Inherit from `h_c2'` of input chronicle via g-agreement property.
  - **New adjacent pairs**: Derive from the elimination lemma that created them (Phase 4 output).

| Branch | Line | New adjacent pairs | Proof source |
|--------|------|-------------------|--------------|
| C5 forward | 756 | (x, y) | `lemma_2_4` output `BurgessR3Maximal(f(x), g'(x,y), f'(y))` |
| C5' backward | 794 | (y, x) | Mirror of C5 forward |
| C4 forward | 834 | (x, z) and (z, y) | `lemma_2_6_splitting` output `BurgessR3Maximal(f(x), B', D)` and `BurgessR3Maximal(D, B'', f(y))` |
| C4' backward | 872 | (y, z) and (z, x) | Mirror of C4 forward |
| Density | 918 | (x, z) and (z, y) | `burgessR3Maximal_from_g_content_sub` or direct construction from copied endpoint |

- **Tasks**:
  - [ ] **Task 5.1**: Close C5 forward c2' (line 756) — use Phase 4 output. (0.5h)
  - [ ] **Task 5.2**: Close C5' backward c2' (line 794) — mirror. (0.5h)
  - [ ] **Task 5.3**: Close C4 forward c2' (line 834) — from Phase 4 output, handle both old pairs (inherit) and new pairs (lemma_2_6_splitting). (2h)
  - [ ] **Task 5.4**: Close C4' backward c2' (line 872) — mirror. (1h)
  - [ ] **Task 5.5**: Close density c2' (line 918) — the new point copies f(x); prove maximality for both new adjacent pairs via `burgessR3Maximal_from_f`. (1h)

- **Timing**: 4-5 hours
- **Depends on**: 4

- **Verification**: All 5 c2' sorries closed. `CounterexampleElimination.lean` sorry count: 7 -> 2. `omega_chain` still compiles (`omega_chain_c2'` already depends on `EliminationResult.c2'`). `lake build` passes.

---

### Phase 6: C4 Hard Cases — BurgessR3 Bridging [NOT STARTED]

- **Goal**: Close the 2 hard-case sorries at CounterexampleElimination.lean lines 412 (C4 forward) and 510 (C4' backward). These handle the sub-case where gamma is in BOTH f(w) and f(w_next), so neither endpoint can directly serve as the witness.

- **Paper reference**: Burgess Section 2.9 (C4 hard case — gamma in f(w) and gamma in f(w_next))

- **Mathematical context**: The existing code (already implemented) extracts the rightmost w with `~U(gamma,delta) ∈ f(w)` and its successor w_next. These are adjacent. From c2' (Phase 5): `BurgessR3Maximal(f(w), g(w,w_next), f(w_next))`. Since the Until is a counterexample, `gamma ∉ g(w,w_next)`.

  Apply `BurgessR3Maximal_extension_fails` with extension candidate `gamma`: this produces a witness formula `phi ∈ DC({gamma})` and some `gamma' ∈ f(w_next)` with `~U(phi, gamma') ∈ f(w)`. The midpoint MCS D is then constructed from this witness, producing `gamma.neg ∈ D`, resolving the counterexample. Bridge back to the original counterexample via monotonicity.

- **Tasks**:
  - [ ] **Task 6.1**: Close C4 forward hard case (line 412) — apply `BurgessR3Maximal_extension_fails` at `(f(w), g(w,w_next))` with extension candidate `gamma`. Extract witness phi such that `gamma.neg ∈ DC({phi})`, derive MCS D for the new midpoint z with `gamma.neg ∈ D`. Assemble the full output. (1.5h)
  - [ ] **Task 6.2**: Close C4' backward hard case (line 510) — mirror for Since using `BurgessR3MaximalSince_extension_fails`. (1.5h)

- **Timing**: 2-3 hours
- **Depends on**: 5

- **Verification**: `CounterexampleElimination.lean` sorry count: 2 -> 0. Both C4/C4' elimination functions fully sorry-free. `lake build` passes.

---

### Phase 7: Limit C5a/C5b Full + FUC/FSC [NOT STARTED]

- **Goal**: Prove `limit_satisfies_c5_full` and `limit_satisfies_c5'_full` in ChronicleConstruction.lean, then close the 2 FUC/FSC sorries in ChronicleToCountermodel.lean (lines 615, 619).

- **Paper reference**: Burgess Claim 2.11, p.375 (truth lemma — forward Until/Since coherence at limit)

- **Part A — Limit C5 full**:

  The "weak" versions already exist (`limit_satisfies_c5_weak`, `limit_satisfies_c5'_weak`) giving endpoint witnesses only. The full versions must additionally prove the guard formula holds at ALL intermediate domain points.

  The limit interval function `limit_g` is defined as:
  ```
  limit_g A h_mcs x z := { phi | forall y in limit_dom, x < y < z -> phi in limit_f y }
  ```
  This definition directly encodes guard propagation to all intermediate points. The proof strategy:
  1. Given `untl(xi,eta) ∈ limit_f x`, obtain witness y from `limit_satisfies_c5_weak` (eta ∈ limit_f y).
  2. At the finite stage n where y was added (via Lemma 2.4), `BurgessR3Maximal` was established at each adjacent pair between x and y by c2' (Phase 5). This means the guard `xi` is in the g-value of each subinterval.
  3. Using C3 at the limit: `limit_g(x,y) ⊆ limit_f z` for any intermediate z. From the finite-stage c2' + C3 lifting, `xi ∈ limit_g(x,y)`. Hence `xi ∈ limit_f z` for every intermediate z.
  4. **Key lemma**: `finite_stage_guard_in_g` — at the finite stage n when witness y is added, for every adjacent pair (a,b) with x ≤ a < b ≤ y, the guard `xi` is in `g_n(a,b)`. Proved by induction on n using the c2' invariant and the fact that the elimination function (Lemma 2.4) produces guard-inclusive g-values.

  **Alternative direct approach** (if `finite_stage_guard_in_g` proves difficult): Since `limit_g` is defined as formulas true at ALL intermediate points, we can prove `limit_satisfies_c5_full` directly from the definition of `limit_g` + `limit_satisfies_c5_weak` by showing that for any intermediate z, `xi` must be in `limit_g(x,y)`, which by definition means `xi ∈ limit_f z`. This requires proving that `xi` is universally present across the interval — which is exactly what c2' establishes at every finite stage.

- **Part B — FUC/FSC**:

  The countermodel uses `cantor_bfmcs` (Cantor-isomorphic FMCS/BFMCS families from the limit chronicle). FUC says: if `U(phi,psi) ∈ mcs(t)`, then exists s > t with `psi ∈ mcs(s)` and forall r (t < r < s): `phi ∈ mcs(r)`. This follows from `limit_satisfies_c5_full` applied at the preimage points under the Cantor isomorphism, which preserves ordering and formula membership (already proven in `cantor_bfmcs`).

- **Tasks**:
  - [ ] **Task 7.1**: Prove lemma `finite_stage_guard_in_g` — by induction on finite stage n, show that when witness y is added, guard xi is in every g-value for adjacent pairs between x and y. This uses c2' invariant (Phase 5) and the fact that Lemma 2.4's `BurgessR3Maximal` includes the guard. (2-3h)
  - [ ] **Task 7.2**: Lift `finite_stage_guard_in_g` to `xi ∈ limit_g(x,y)` using C3 at the limit (`limit_c3_interval_subset_point`). (1h)
  - [ ] **Task 7.3**: Assemble `limit_satisfies_c5_full` — combine Tasks 7.1-7.2 with `limit_satisfies_c5_weak`. (1h)
  - [ ] **Task 7.4**: Mirror `limit_satisfies_c5'_full` for Since. (1h)
  - [ ] **Task 7.5**: Close FUC (ChronicleToCountermodel.lean:615) — unpack hfam hypothesis to get Cantor preimages, apply `limit_satisfies_c5_full`, transfer back through isomorphism using `cantor_bfmcs` ordering/coherence properties. (1h)
  - [ ] **Task 7.6**: Close FSC (ChronicleToCountermodel.lean:619) — mirror. (0.5h)

- **Timing**: 5-7 hours
- **Depends on**: 5

- **Verification**: `ChronicleConstruction.lean` sorry count remains 0 (new theorems added). `ChronicleToCountermodel.lean` sorry count: 2 -> 0. `dd_countermodel_chronicle` fully sorry-free. `lake build` passes.

---

### Phase 8: Final Audit and Integration [NOT STARTED]

- **Goal**: Verify the entire Chronicle/ directory is sorry-free and the countermodel construction delivers the representation theorem.

- **Tasks**:
  - [ ] **Task 8.1**: Run `#print axioms dd_countermodel_chronicle` — verify no `sorryAx` appears in the axioms list.
  - [ ] **Task 8.2**: Run `grep -rn "sorry" Theories/Bimodal/Metalogic/BXCanonical/Chronicle/` — verify only comment occurrences remain (no active sorries).
  - [ ] **Task 8.3**: Full `lake build` clean from scratch.
  - [ ] **Task 8.4**: Generate summary artifact: `summaries/58_implementation-summary.md` with verification results, axiom audit, and metrics (sorry count 12 -> 0, lines added, phases completed).

- **Timing**: 1-2 hours
- **Depends on**: 7

- **Verification**:
  - Chronicle/ sorry count: 0.
  - `dd_countermodel_chronicle` has no `sorryAx` in its axioms.
  - Full `lake build` clean.

---

## Testing & Validation

- [ ] `lake build` succeeds at every phase boundary
- [ ] `#print axioms dd_countermodel_chronicle` — no `sorryAx` after Phase 8
- [ ] `grep -rn "sorry" Theories/Bimodal/Metalogic/BXCanonical/Chronicle/` — only comment occurrences
- [ ] All elimination functions' g-field non-empty for new adjacent pairs
- [ ] `omega_chain` type-checks with c2' invariant (already done, must continue to work)
- [ ] `limit_satisfies_c5_full` provable without circularity
- [ ] FUC/FSC compile using `limit_satisfies_c5_full`

## Artifacts & Outputs

- `plans/58_implementation-plan.md` (this file)
- `summaries/58_implementation-summary.md` (Phase 8)
- Modified source files:
  - `PointInsertion.lean` (Phases 2, 3)
  - `CounterexampleElimination.lean` (Phases 4, 5, 6)
  - `ChronicleConstruction.lean` (Phase 7)
  - `ChronicleToCountermodel.lean` (Phase 7)

## Rollback/Contingency

- **If `finite_stage_guard_in_g` proves unprovable (Phase 7)**: Fall back to a weaker C5 property that only asserts endpoint witnesses; mark guard propagation as a known limitation defer to a subsequent task. The FUC/FSC would then require an alternative approach using the Cantor isomorphism's density property.
- **If g-value construction too invasive (Phase 4)**: Start with C5 forward only (critical path). Use trivial g-values for other directions, expand later.
- **If Lemma 2.7 blocked beyond Phase 3 timing**: The D3 elimination uses standard propositional derivations (`lce_imp`/`rce_imp`) — if a specific BX7 form mismatch occurs, adapt by restating BX7 to match the codebase's convention.
- **Build instability**: Commit after each elimination function modification. Fix call sites and verify `lake build` incrementally.

## Reference: Axiom-to-Burgess Mapping

| Burgess Axiom | Our Code | Used In | Soundness |
|---|---|---|---|
| A1a (left mono) | BX2 / `untl_left_mono_deriv` | Lemmas 2.6, 2.7 disjunct elimination | ✓ |
| A2a (right mono) | BX3 / `untl_right_mono_deriv` | Lemmas 2.6, 2.7 disjunct elimination | ✓ |
| A3a (enrichment) | BX13 / `enrichment_from_until` | Lemmas 2.4, 2.6, 2.7 seed | ✓ |
| A4a (separation) | BX14 | Lemmas 2.6, 2.7 | ✓ |
| A5a (self-accum) | BX5 / `self_accum_until_mcs` | Lemma 2.7 three-way | ✓ |
| A6a (converse) | BX6 | Lemma 2.6 (via converse reduction) | ✓ |
| A7a (three-way) | BX7 / `linear_until_mcs` | Lemma 2.7 | ✓ |
| -- | BX10 / `until_implies_F_mcs` | Lemmas 2.6, 2.7 consistency | ✓ |

## Implementation Agent Notes

1. **Follow Burgess exactly for proof structure** — translate our BX axiom replacements for open-guard strict semantics. No novel approaches.
2. **Argument order convention**: `untl(guard, event)` in our code = `U(event, guard)` in Burgess. Arguments are SWAPPED. Always verify which position the guard occupies when applying BX axioms.
3. **Co-construct g-values** at each elimination — this is the architecture fix that cascades through all phases. Every new adjacent pair must have a populated g-value satisfying `BurgessR3Maximal`.
4. **Commit after each phase**, verify `lake build`, update phase status in this plan.
5. **Critical path**: Phase 3 (Lemma 2.7, 6-8h) -> Phase 4 (C4/C5 co-construction, 5-7h) -> Phase 5 (c2', 4-5h) -> Phase 7 (limit C5 full + FUC/FSC, 5-7h) -> Phase 8 (final audit, 1-2h) = 20-27h.
6. **Parallel opportunity**: Phases 2 (Lemma 2.6 inconsistent case) and 3 (Lemma 2.7) are independent and can be implemented by separate subagents in parallel after Phase 1.
7. **Key proof infrastructure** to verify exists before starting:
   - `BurgessR3Maximal_extension_fails` (used in Phase 3 step 1, Phase 6)
   - `dc_delta_B_controlled` (used in Phase 3 step 1)
   - `iterated_enrichment` with event' and h_impl/h_snce fields (used in Phases 2, 3)
   - `burgessR3Maximal_singleton` or equivalent (used in Phase 4 easy cases)
   - `limit_c3_interval_subset_point` (used in Phase 7)
