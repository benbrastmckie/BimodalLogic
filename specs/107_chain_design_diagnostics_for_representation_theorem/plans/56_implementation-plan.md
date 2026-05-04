# Implementation Plan: Task #107 — Burgess-Faithful Chronicle Construction (Revised)

- **Task**: 107 - chain_design_diagnostics_for_representation_theorem
- **Status**: [NOT STARTED]
- **Effort**: 28-38 hours
- **Dependencies**: Plans 01-55 (iterative refinement); research reports
- **Research Inputs**:
  - `reports/burgess-24-26-analysis.md` — Lemma 2.4/2.6 exact mapping
  - `reports/burgess-27-analysis.md` — Lemma 2.7 BX7 chain exact mapping
  - `reports/burgess-29-210-analysis.md` — C4/C5 elimination exact mapping
  - `reports/burgess-211-limit-analysis.md` — Limit construction & Claim 2.11 mapping
- **Artifacts**: plans/56_implementation-plan.md (this file)
- **Standards**: plan-format.md; status-markers.md; artifact-management.md; tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

This revised plan addresses the single root cause identified by four-agent parallel research: **g-values are never populated during finite-stage elimination steps**. While our codebase's flat direct-construction approach for C4/C5 elimination is mathematically equivalent to Burgess's induction, the failure to assign `g` at new adjacent pairs breaks the C2' invariant, prevents C5a from being proved at the limit, and blocks FUC/FSC. The fix is strictly local: construct `g` at each elimination branch, thread C2', and prove limit properties following Burgess 1982 Sections 2.9-2.11. No elimination algorithm is rewritten.

### Research Integration

Four parallel research agents mapped every Burgess lemma to our Lean codebase. The synthesis confirms:
- **What matches**: Lemma 2.4, 2.7 seed, limit domain/f, C3 at limit, BX axiom substitutions.
- **Critical deviations (fixable)**: (1) g-values never constructed in eliminations, (2) C5 output misused (`η ∈ C` vs `η ∈ B`), (3) c2' removed from finite omega-chain, (4) `C5Counterexample` checks wrong condition.
- **Root cause**: g-population is the structural fix that unblocks 22/29 sorries.

## Goals & Non-Goals

**Goals**:
- Populate g-values for all new adjacent pairs created during C4/C5/C4'/C5'/density elimination (Burgess 2.9, 2.10).
- Thread the C2' invariant through the finite omega-chain (Burgess 2.10).
- Prove `limit_satisfies_c5_full` and `limit_satisfies_c5'_full` using g-value persistence and C3 (Burgess 2.11).
- Close all remaining 29 sorries in `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/`.

**Non-Goals**:
- Rewrite C4/C5 elimination with Burgess's induction structure (flat approach is equivalent and preserved).
- Introduce new axioms or novel proof approaches.
- Modify limit domain/f construction or the existing sorry-free C3 proof.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `guard_in_r_maximal` lemma is unprovable | Blocks Phase 7 | Medium | Prove a weaker variant sufficient for C5a; document gap if necessary |
| g-value construction breaks function signatures | High build churn | High | Commit after each elimination function modification; fix call sites incrementally |
| C4 Hard cases remain blocked even with g-populated | Delays Phase 4 | Low | Use `burgessR3_gamma_not_in_B` + `lemma_2_6_splitting` with β = γ |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 3, 6 | -- |
| 2 | 1 | 6 |
| 3 | 2, 4 | 1 |
| 4 | 5 | 2 |
| 5 | 7 | 5 |
| 6 | 8 | 7 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Populate g-Values in Elimination Functions [NOT STARTED]

**Goal**: Make each elimination function construct g-values for new adjacent pairs, per Burgess Sections 2.9 (C4) and 2.10 (C5).

**Tasks**:
- [ ] **Task 1.1**: Modify `eliminate_C5_counterexample` (Burgess 2.10, C5a base case)
  - Extract interval `B` (not endpoint `C`) from `lemma_2_4` output.
  - Construct `g'` where `g'(x,y) = B` for the NEW adjacent pair.
  - For OLD adjacent pairs, preserve `χ.g` via `h_c2'`.
  - Difficulty: Medium (~1.5h)

- [ ] **Task 1.2**: Modify `eliminate_C5'_counterexample` (mirror for Since)
  - Symmetric mirror of Task 1.1.
  - Burgess 2.10, C5b.
  - Difficulty: Medium (~1h)

- [ ] **Task 1.3**: Modify `eliminate_C4_counterexample` (Burgess 2.9, C4a base case)
  - When inserting midpoint `z`, construct `g'` where:
    - `g'(x,z) = B'` from `lemma_2_6_splitting`
    - `g'(z,y) = B''` from `lemma_2_6_splitting`
    - For OLD non-adjacent pair `(x,y)` now split, update via C3: `g'(x,y) = g'(x,z) ∩ f(z) ∩ g'(z,y)`.
    - For other pairs involving `z`, determine by C3.
  - Difficulty: Hard (~2.5h)

- [ ] **Task 1.4**: Modify `eliminate_C4'_counterexample` (mirror)
  - Symmetric mirror of Task 1.3.
  - Difficulty: Hard (~1.5h)

- [ ] **Task 1.5**: Handle density insertion g-population
  - Use `burgessR3Maximal_from_g_content_sub` to construct g-values for new adjacent pairs.
  - Burgess 2.9/2.10, density case (n = m + 1).
  - Difficulty: Medium (~1h)

- [ ] **Task 1.6**: Verify old adjacent pair C3 consistency after splitting
  - When a new point splits an old adjacent pair `(x,y)`, adjacency is broken; `g(x,y)` should now be determined by C3 intersection.
  - Difficulty: Medium (~1h)

**Timing**: 6-8 hours

**Depends on**: Phase 6 (Lemma 2.7 seed provides C5 inductive case g-construction lemmas).

**Verification**:
- Each elimination produces a `Chronicle` with populated g-values.
- `lake build` succeeds after each modification (commit incrementally).

---

### Phase 2: Prove c2' for All Elimination Branches [NOT STARTED]

**Goal**: Close all 10 c2' sorries once g-values are properly populated.

**Tasks**:
- [ ] **Task 2.1**: Trivial no-elimination c2' (4 sorries) — `by exact h_c2'`
- [ ] **Task 2.2**: C5 forward elimination c2' — forward `lemma_2_4` output (BurgessR3Maximal)
- [ ] **Task 2.3**: C5 backward elimination c2' — mirror
- [ ] **Task 2.4**: C4 forward elimination c2' — forward `lemma_2_6_splitting` B' and B''
- [ ] **Task 2.5**: C4 backward elimination c2' — mirror
- [ ] **Task 2.6**: Density forward c2' — from `burgessR3Maximal_from_g_content_sub`
- [ ] **Task 2.7**: Density backward c2' — mirror

**Timing**: 3-4 hours

**Depends on**: Phase 1 (g-values actually present in eliminations).

**Verification**:
- All 10 c2' sorries in `CounterexampleElimination.lean` closed.
- `lake build` succeeds.

---

### Phase 3: Close PointInsertion.lean Remaining Sorries [NOT STARTED]

**Goal**: Close the 2 remaining sorries (lines ~1872, ~1873) in `lemma_2_6_splitting`.

**Tasks**:
- [ ] **Task 3.1**: Close `h_ev_b` (line ~1872)
  - Event guard is `q = b ∧ untl(b, γ_hat)`. Need `event → b`.
  - Proof: `guard_destruct` on `event → q` to get `event → b` and `event → untl(b, γ_hat)`.
  - Difficulty: Easy (~15 min)

- [ ] **Task 3.2**: Close `h_ev_untl` (line ~1873)
  - Same guard `q`. Need `event → untl(b, γ_hat)`.
  - Proof: `guard_destruct` on `event → q`, second conjunct.
  - Difficulty: Easy (~15 min)

**Timing**: 1 hour

**Depends on**: None (independent).

**Verification**:
- `lemma_2_6_splitting` compiles sorry-free.
- `lake build` succeeds.

---

### Phase 4: Close C4/C4' Hard Cases (C11/C12) [NOT STARTED]

**Goal**: Close 2 hard-case sorries (lines 412, 510) in `CounterexampleElimination.lean`.

**Tasks**:
- [ ] **Task 4.1**: Close C4 hard case (C11)
  - γ ∈ f(w) and γ ∈ f(w_next), `¬untl(γ,δ) ∈ f(w)`.
  - Use γ ∉ g(w, w_next) (now available from c2' + counterexample logic with populated g).
  - Apply `lemma_2_6_splitting` with β = γ.
  - Difficulty: Hard (~2h)

- [ ] **Task 4.2**: Close C4' hard case (C12) (mirror)
  - Difficulty: Hard (~2h)

**Timing**: 3-4 hours

**Depends on**: Phase 1 (g-values populated, c2' established for old adjacent pairs).

**Verification**:
- Hard-case sorries closed.
- `lake build` succeeds.

---

### Phase 5: Thread c2' Through omega_chain [NOT STARTED]

**Goal**: Change `omega_chain` return type to carry the C2' invariant through all finite stages, as Burgess threads it implicitly.

**Tasks**:
- [ ] **Task 5.1**: Change `omega_chain` return type:
  ```lean
  (n : Nat) → { χ : Chronicle // χ.c0 ∧ χ.c2' }
  ```
- [ ] **Task 5.2**: Base case (n=0): singleton chronicle satisfies c2' vacuously (no adjacent pairs).
- [ ] **Task 5.3**: Step case: extract `c2'` from `EliminationResult` (populated in Phase 1).
- [ ] **Task 5.4**: Fix `omega_chain_elim_result` call site to include c2'.
- [ ] **Task 5.5**: Fix `omega_chain` call sites in `ChronicleConstruction.lean` (lines 259, 281) to thread c2'.

**Timing**: 2-3 hours

**Depends on**: Phase 2 (all eliminations provide c2').

**Verification**:
- `omega_chain_c2'` accessor compiles.
- `lake build` succeeds.

---

### Phase 6: Implement Lemma 2.7 Seed Consistency [NOT STARTED]

**Goal**: Close `lemma_2_7_seed_consistent` (line 2414) using the BX7 chain mapped exactly by research.

**Tasks**:
- [ ] **Task 6.1**: Implement `lemma_2_7_neg_untl_exists` (extract witness)
  - Use `BurgessR3Maximal_extension_fails` + `dc_delta_B_controlled`.
  - Burgess 2.7, witness extraction.
  - Difficulty: Medium (~1.5h)

- [ ] **Task 6.2**: Verify `linear_until_mcs` wrapper (trivial)
  - Apply `theorem_in_mcs` + `conj_mcs` for BX7 at MCS level.
  - Difficulty: Easy (~15 min)

- [ ] **Task 6.3**: Implement `lemma_2_7_disjunct_elim_D1`
  - D1 contains `γ_hat ∧ eta` in event. By right mono and witness, contradicts `¬untl(β₀∧eta, γ₀)`.
  - Key: `gamma₀` is in the C-event list, so `γ_hat → gamma₀` via conjunction elimination.
  - Burgess 2.7, A7a/BX7 disjunct elimination.
  - Difficulty: Medium (~1.5h)

- [ ] **Task 6.4**: Implement `lemma_2_7_disjunct_elim_D2` (mirror with `xi`)
  - Uses same witness + monotonicity argument.
  - Difficulty: Medium (~1.5h)

- [ ] **Task 6.5**: Orchestrate `lemma_2_7_seed_consistent`
  - Follow the TODO comment's 10-step structure (lines 2393-2403).
  - Steps: (1) witness, (2) BX5 on `untl(b,γ_hat)`, (3) BX5 on `untl(xi,eta)`, (4) BX7, (5-6) eliminate D1/D2, (7) surviving D3, (8) BX14 separation, (9) BX13 enrichment + BX10, (10) seed consistency.
  - Difficulty: Hard (~2-3h)

**Timing**: 4-5 hours

**Depends on**: None (independent, but needed for Phase 1 C5 inductive case).

**Verification**:
- `lemma_2_7_seed_consistent` compiles sorry-free.
- `lake build` succeeds.

---

### Phase 7: Prove limit_satisfies_c5_full and limit_satisfies_c5'_full [NOT STARTED]

**Goal**: Prove the full C5a/C5b properties at the limit, following Burgess Claim 2.11.

**Tasks**:
- [ ] **Task 7.1**: Prove or identify `guard_in_r_maximal` lemma
  - If `U(ξ,η) ∈ f(x)` and `BurgessR3Maximal(f(x), g(x,y), f(y))`, does `ξ ∈ g(x,y)`?
  - If unprovable, find weaker variant sufficient for C5a.
  - Burgess 2.11, key step for limit property.
  - Difficulty: Hard (research-dependent, 2-4h)

- [ ] **Task 7.2**: Prove `limit_satisfies_c5_full`
  - Use `omega_chain_c2'` + `guard_in_r_maximal` + `limit_c3_interval_subset_point`.
  - Burgess 2.11, Claim (+) for Until.
  - Difficulty: Hard (~3-4h, contingent on 7.1)

- [ ] **Task 7.3**: Mirror for Since: `limit_satisfies_c5'_full`
  - Difficulty: Medium (~1-2h)

**Timing**: 6-8 hours

**Depends on**: Phase 5 (c2' available at all finite stages via omega_chain).

**Verification**:
- `limit_satisfies_c5_full` and `limit_satisfies_c5'_full` compile sorry-free.
- `lake build` succeeds.

---

### Phase 8: Close FUC/FSC and Final Audit [NOT STARTED]

**Goal**: Close remaining `ChronicleToCountermodel.lean` sorries and verify a fully sorry-free build.

**Tasks**:
- [ ] **Task 8.1**: Close FUC (line 615) using `limit_satisfies_c5_full` + Cantor transfer.
- [ ] **Task 8.2**: Close FSC (line 619) mirror using `limit_satisfies_c5'_full`.
- [ ] **Task 8.3**: Final audit: `#print axioms dd_countermodel_chronicle` shows no `sorryAx`.
- [ ] **Task 8.4**: Verify `grep -rn "sorry" Theories/Bimodal/Metalogic/BXCanonical/Chronicle/` returns only comments.
- [ ] **Task 8.5**: Full `lake build` clean.
- [ ] **Task 8.6**: Create summary artifact: `specs/107_chain_design_diagnostics_for_representation_theorem/summaries/56_implementation-summary.md`.

**Timing**: 3-4 hours

**Depends on**: Phase 7.

**Verification**:
- Chronicle/ directory sorry count: 0.
- Full `lake build` clean.

---

## Testing & Validation

- [ ] `lake build` succeeds at the boundary of every phase.
- [ ] `#print axioms dd_countermodel_chronicle` shows no `sorryAx` after Phase 8.
- [ ] `grep -rn "sorry" Theories/Bimodal/Metalogic/BXCanonical/Chronicle/` returns only comment occurrences.
- [ ] Each elimination function's `g`-field is non-empty for newly created adjacent pairs.
- [ ] `omega_chain` type-checks with the `c2'` invariant.

## Artifacts & Outputs

- `plans/56_implementation-plan.md` (this file)
- `summaries/56_implementation-summary.md` (produced in Phase 8)
- Modified Lean source files in `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/`:
  - `PointInsertion.lean`
  - `CounterexampleElimination.lean`
  - `ChronicleConstruction.lean`
  - `ChronicleToCountermodel.lean`

## Rollback/Contingency

- **If `guard_in_r_maximal` is unprovable (Phase 7.1)**: Document the gap and mark the task partial. Fallback: prove intermediate guard propagation directly for limit C5a, bypassing g-values at the limit.
- **If g-value construction becomes too invasive (Phase 1)**: Start with C5 forward only (critical path for Until formulas), use trivial g-values for other directions, and expand later.
- **Build instability during Phase 1**: Commit after each elimination function modification. Fix call sites incrementally rather than in a single large batch.

---

## Reference: Axiom-to-Burgess Mapping

| Burgess Axiom | Our Axiom | Used In | Soundness Proved |
|---|---|---|---|
| A1a (left mono) | BX2 (`left_mono_until`) | Lemma 2.7 disjunct elimination | SoundnessLemmas |
| A2a (right mono) | BX3 (`right_mono_until`) | Lemma 2.7 disjunct elimination | SoundnessLemmas |
| A3a (enrichment) | BX13 (`enrichment_until`) | Lemma 2.6, 2.7 seed | SoundnessLemmas |
| A4a (separation) | BX14 (`separation_until`) | Lemma 2.6, 2.7 | SoundnessLemmas |
| A5a (self-accum) | BX5 (`self_accum_until`) | Lemma 2.7 three-way | SoundnessLemmas |
| A6a (converse) | BX16 | Lemma 2.6 | SoundnessLemmas |
| A7a (three-way) | BX7 (`linear_until`) | Lemma 2.7 | SoundnessLemmas |
| — | BX10 (`until_F`) | Lemma 2.6, 2.7 consistency | SoundnessLemmas |

## Agent Instruction Notes

**To lean-implementation-agent**:

1. **Follow Burgess exactly for proof structure**, but use our BX axiom replacements (BX2/BX3/BX5/BX7/BX10/BX13/BX14) for open-guard strict semantics.
2. **Phase 1 is about CONSTRUCTING g-values**, not rewriting eliminations. Each branch must assign `g` at new adjacent pairs using lemma outputs.
3. **Do NOT introduce new axioms or novel approaches.** Implement Burgess's method as mapped by research.
4. **At each phase boundary**: verify with `lake build`, check sorry counts, update phase status in this plan file.
5. **Critical path**: Phase 6 (Lemma 2.7) -> Phase 1 (g-population) -> Phase 2 (c2') -> Phase 5 (omega_chain) -> Phase 7 (limit C5a) -> Phase 8 (FUC/FSC).

**Plan revised**: 2026-05-03
**Based on**: Research reports burgess-24-26, burgess-27, burgess-29-210, burgess-211
**Previous plan**: v55 (superseded)
**Estimated Total Effort**: 28-38 hours (aligned with research estimate)
**Critical Path**: Phase 6 (4-5h) -> Phase 1 (6-8h) -> Phase 2 (3-4h) -> Phase 5 (2-3h) -> Phase 7 (6-8h) -> Phase 8 (3-4h)
