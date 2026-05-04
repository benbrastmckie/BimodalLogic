# Revised Implementation Plan: Task #107 — Burgess-Faithful Chronicle Construction

- **Task**: 107 - Chain design diagnostics for representation theorem
- **Status**: [IN PROGRESS]
- **Previous Plan**: v54 (see `plans/54_implementation-plan.md` for context)
- **Revision Trigger**: Four-agent research team analysis of Burgess 1982 text vs. current codebase
- **Research Reports**:
  - `reports/burgess-24-26-analysis.md` — Lemma 2.4, 2.6 mapping
  - `reports/burgess-27-analysis.md` — Lemma 2.7 BX7 chain mapping
  - `reports/burgess-29-210-analysis.md` — C4/C5 elimination mapping
  - `reports/burgess-211-limit-analysis.md` — Limit construction & Claim 2.11 mapping
- **Plan Version**: 55 (supersedes v54)
- **Type**: lean4
- **Lean Intent**: true

---

## Executive Summary

Research confirms our codebase **faithfully follows Burgess 1982's proof architecture** with documented adaptations for open-guard strict semantics. However, four structural deviations from Burgess must be resolved:

1. **g-values are never constructed in elimination steps** — Burgess sets g-values explicitly; our code preserves g unchanged
2. **C5 output misused** — `η ∈ B` (interval), not `η ∈ C` (endpoint)
3. **c2' not threaded through finite omega-chain** — removed in prior phase, now must be restored
4. **C5Counterexample checks wrong condition** — workaround for missing g-values

**Key insight**: We do NOT need to rewrite C4/C5 elimination with Burgess's induction. Our flat direct-construction approach is mathematically equivalent. The fix is: **construct g-values correctly in each elimination branch, thread c2', use η ∈ g(x,y)**.

**Critical path (unchanged)**: Phase 2 → Phase 3 → Phase 4 (g-construction + c2') → Phase 5a → Phase 5b.

**Estimated remaining effort**: 28-38 hours (down from 37-50 in v54 because research clarified exact proof steps).

---

## Synthesis of Research Findings

### What Matches Burgess Exactly

| Component | Status | Notes |
|---|---|---|
| Lemma 2.4 (C5 base / Until witness) | ✅ Complete | Role-reversed event/guard; documented; sorry-free |
| Lemma 2.6 (C4 base / Splitting) | ⚠️ Partial | 2 sorries in inconsistent case; otherwise matches |
| Lemma 2.7 seed construction | ✅ Complete | 5 components match Burgess exactly |
| Limit domain as union | ✅ Complete | `limit_dom`, `limit_f` are unions |
| C3 at limit | ✅ Complete | `limit_c3` proved sorry-free |
| BX axiom substitutions | ✅ Complete | BX5/BX13/BX14 for A3a/A4a/A5a (documented) |

### Four Critical Deviations (All Fixable Without Rewriting)

| # | Deviation | Severity | Fix |
|---|---|---|---|
| 1 | g-values never constructed in eliminations | CRITICAL | Assign g at new adjacent pairs using Lemma 2.4/2.6/2.7 output |
| 2 | C5 output: `η ∈ C` (endpoint) vs `η ∈ B` (interval) | CRITICAL | Extract interval B from `lemma_2_4`; assign `g(x,y) = B` |
| 3 | c2' removed from finite omega-chain | HIGH | Thread `c2'` through `omega_chain` return type |
| 4 | `C5Counterexample` checks `η ∈ f(y)` + intermediate f | MEDIUM | Keep for backward compat; add proper `C5a` at limit via g |

**Important**: Research team confirms our flat direct-construction approach for C4/C5 is mathematically equivalent to Burgess's induction. The induction is just a proof technique; our case-analysis achieves the same. **We should NOT rewrite with induction** — we should make our approach work by adding g-construction.

### Root Cause Summary

The single root cause of 22/29 sorries is: **g-values are not populated during finite-stage elimination, so c2' cannot hold, so the limit cannot prove C5a with guard in g**.

Fixing g-population fixes: C5/C5' c2' (4 sorries), C4/C4' c2' (4 sorries), density c2' (2 sorries), C11/C12 hard cases (2 sorries), omega_chain c2' (Phase 4e), limit_satisfies_c5_full (Phase 5a), FUC/FSC (Phase 5b).

---

## Implementation Phases

---

### Phase 2: Close D0 Seed Inconsistent Case Sorries [PARTIAL]

**Goal**: Close 2 remaining sorries (1872, 1873) in PointInsertion.lean.

**Tasks**:
- [ ] **Task 2.2**: Close `h_ev_b` (line ~1872)
  - Event guard is `q = b ∧ untl(b, γ_hat)`. Need `event → b`.
  - Proof: `guard_destruct` on `event → q` to get `event → b` and `event → untl(b, γ_hat)`.
  - Difficulty: Easy (~15 min)

- [ ] **Task 2.3**: Close `h_ev_untl` (line ~1873)
  - Same guard `q`. Need `event → untl(b, γ_hat)`.
  - Proof: `guard_destruct` on `event → q`, second conjunct.
  - Difficulty: Easy (~15 min)

- [ ] **Verify**: `lemma_2_6_splitting` compiles sorry-free; `lake build` succeeds.

**Timing**: 1 hour

**Depends on**: None.

---

### Phase 3: Implement Lemma 2.7 with BX7 Chain [NOT STARTED]

**Goal**: Close `lemma_2_7_seed_consistent` (line 2414).

**Findings from research**: Our seed (line 2386) and axioms (BX5, BX7, BX13, BX14) correctly adapt Burgess's proof for open-guard semantics. The 10-step proof structure is fully prescribed by the TODO comment (lines 2393-2403).

**Tasks**:
- [ ] **Task 3.1**: Implement `lemma_2_7_neg_untl_exists` (extract witness)
  - Use `BurgessR3Maximal_extension_fails` + `dc_delta_B_controlled` (line ~540)
  - Difficulty: Medium (~2h)

- [ ] **Task 3.2**: Verify `linear_until_mcs` (already exists, trivial wrapper)
  - Apply `theorem_in_mcs` + `conj_mcs` for BX7 at MCS level
  - Difficulty: Easy (~15 min)

- [ ] **Task 3.3**: Implement `lemma_2_7_disjunct_elim_D1`
  - D1 contains `γ_hat ∧ eta` in event. By right mono and witness, contradicts `¬untl(β₀∧eta, γ₀)`.
  - Key: `gamma₀` is in the C-event list, so `γ_hat → gamma₀` via conjunction elimination.
  - Difficulty: Medium (~2h)

- [ ] **Task 3.4**: Implement `lemma_2_7_disjunct_elim_D2`
  - Mirror of D1 but with `xi` instead of `eta` in the event position.
  - Uses the same witness + monotonicity argument.
  - Difficulty: Medium (~2h)

- [ ] **Task 3.5**: Orchestrate `lemma_2_7_seed_consistent`
  - Follow the TODO comment's 10-step structure.
  - Steps: (1) witness, (2) BX5 on `untl(b,γ_hat)`, (3) BX5 on `untl(xi,eta)`, (4) BX7, (5-6) eliminate D1/D2, (7) surviving D3, (8) BX14 separation, (9) BX13 enrichment + BX10, (10) seed consistency.
  - Difficulty: Hard (~4-6h)

**Timing**: 8-10 hours

**Depends on**: None (independent of Phase 2).

**Verification**:
- `lemma_2_7_seed_consistent` compiles sorry-free.
- `lemma_2_7` theorem (lines 2416-2551) is already sorry-free once seed is proved.
- `lake build` succeeds.

---

### Phase 4a: Refactor Eliminations to Construct g-Values [NOT STARTED]

**Goal**: Make elimination functions actually construct g-values for new adjacent pairs, per Burgess.

**CRITICAL CHANGE from v54**: This is not just about adding `c2'` field sorries — it requires **changing how eliminations return g-assignments**.

**Research finding**: Burgess sets g at new adjacent pairs using:
- C5 base: `g(x,y) = B` from `lemma_2_4` output
- C4 base: `g(x,z) = B'`, `g(z,y) = B''` from `lemma_2_6_splitting`
- C5 inductive: `g(x,z) = B'`, `g(z,x') = B''` from `lemma_2_7`

**Current code's EliminationResult type** (line ~693) already carries a `val : Chronicle` with `c2'` field. The Chronicle type contains both `f` (point function) and `g` (pair function). So modifying `f` and `g` in the result is already structurally supported.

**Tasks**:
- [ ] **Task 4a.1**: Modify `eliminate_C5_counterexample` to:
  - Extract interval `B` (not just endpoint `C`) from `lemma_2_4`.
  - Construct `g'` where `g'(x,y) = B` for the NEW adjacent pair.
  - For OLD pairs, preserve `χ.g` via `h_c2'`.
  - Difficulty: Medium (~2h)

- [ ] **Task 4a.2**: Modify `eliminate_C5'_counterexample` similarly (mirror for Since).
  - Use the symmetric mirror of `lemma_2_4` for Since direction.
  - Difficulty: Medium (~1.5h)

- [ ] **Task 4a.3**: Modify `eliminate_C4_counterexample` to:
  - When inserting midpoint z, construct g' where:
    - `g'(x,z) = B'` from `lemma_2_6_splitting`
    - `g'(z,y) = B''` from `lemma_2_6_splitting`
    - For OLD non-adjacent pair (x,y), update via C3: `g'(x,y) = g'(x,z) ∩ f(z) ∩ g'(z,y)`.
    - For other pairs involving z, determine by C3.
  - Difficulty: Hard (~3-4h)

- [ ] **Task 4a.4**: Modify `eliminate_C4'_counterexample` similarly (mirror).
  - Difficulty: Hard (~2-3h)

- [ ] **Task 4a.5**: For density insertion:
  - Use `burgessR3Maximal_from_g_content_sub` to construct g-values for new adjacent pairs.
  - Difficulty: Medium (~1-2h)

- [ ] **Task 4a.6**: Ensure `EliminationResult.val.g` at old adjacent pairs respects C3.
  - When a new point splits an old adjacent pair (x,y) into (x,z) and (z,y), the old adjacency is broken, so g(x,y) is now non-adjacent and determined by C3.
  - Difficulty: Medium (~1h)

**Timing**: 10-14 hours

**Depends on**: Phase 3 (Lemma 2.7) for C5 inductive case g-construction.

**Verification**:
- Each elimination produces a chronicle with populated g-values.
- `c2'` can be proved for new adjacent pairs (because g-values come from BurgessR3Maximal outputs).
- `lake build` succeeds.

---

### Phase 4b: Prove c2' for All Elimination Branches [NOT STARTED]

**Goal**: Close all 10 c2' sorries (4 trivial + 6 non-trivial).

**Research finding**: With g-values properly constructed in Phase 4a, c2' proofs become straightforward:
- **No-elimination cases** (4 trivial): `c2' := h_c2'` (old pairs unchanged).
- **C5 forward/backward** (2 sorries): New adjacent pair gets g from `lemma_2_4` output, which is already BurgessR3Maximal by construction. Prove `c2'` by forwarding `lemma_2_4`'s postcondition.
- **C4 forward/backward** (2 sorries): New adjacent pairs get g from `lemma_2_6_splitting` output B' and B''. Prove `c2'` by forwarding the splitting theorem's BurgessR3Maximal outputs.
- **Density** (2 sorries): New adjacent pairs get g from `burgessR3Maximal_from_g_content_sub`. Prove `c2'` from its output.

**Tasks**:
- [ ] **Task 4b.1**: C5 forward no-elimination c2' (trivial) — `by exact h_c2'`
- [ ] **Task 4b.2**: C5 backward no-elimination c2' (trivial) — `by exact h_c2'`
- [ ] **Task 4b.3**: C4 forward no-elimination c2' (trivial) — `by exact h_c2'`
- [ ] **Task 4b.4**: C4 backward no-elimination c2' (trivial) — `by exact h_c2'`
- [ ] **Task 4b.5**: C5 forward elimination c2' — forward `lemma_2_4` output
- [ ] **Task 4b.6**: C5 backward elimination c2' — mirror
- [ ] **Task 4b.7**: C4 forward elimination c2' — forward `lemma_2_6_splitting` B' and B''
- [ ] **Task 4b.8**: C4 backward elimination c2' — mirror
- [ ] **Task 4b.9**: Density forward c2' — from `burgessR3Maximal_from_g_content_sub`
- [ ] **Task 4b.10**: Density backward c2' — mirror

**Timing**: 4-6 hours

**Depends on**: Phase 4a (g-values actually populated).

**Verification**:
- All 10 c2' sorries closed.
- `lake build` succeeds.

---

### C4 Hard Cases (C11/C12) [NOT STARTED]

**Goal**: Close 2 hard-case sorries (lines 412, 510).

**Research finding**: These arise in our `w_max` strategy (which is not in Burgess). However, with g-values populated in Phase 4a:
- `burgessR3_gamma_not_in_B` becomes applicable (g is no longer empty).
- `lemma_2_6_splitting` with `β = γ` becomes usable.

**Tasks**:
- [ ] **Task C11**: Close C4 hard case.
  - γ ∈ f(w) and γ ∈ f(w_next), `¬untl(γ,δ) ∈ f(w)`.
  - Use γ ∉ g(w, w_next) (from c2' + counterexample logic).
  - Apply `lemma_2_6_splitting` with β = γ.
  - Difficulty: Hard (~3h)

- [ ] **Task C12**: Close C4' hard case (mirror).
  - Difficulty: Hard (~2h)

**Timing**: 5 hours

**Depends on**: Phase 4a (g-values populated, c2' established).

---

### Phase 4e: Thread c2' Through omega_chain [NOT STARTED]

**Goal**: Change `omega_chain` return type to carry c2' invariant.

**Research finding**: Burgess threads C2' implicitly through finite stages. Our code must make it explicit.

**Tasks**:
- [ ] **Task 4e.1**: Change `omega_chain` return type:
  ```lean
  (n : Nat) → { χ : Chronicle // χ.c0 ∧ χ.c2' }
  ```
- [ ] **Task 4e.2**: Base case (n=0): singleton chronicle satisfies c2' vacuously (no adjacent pairs).
- [ ] **Task 4e.3**: Step case: extract `c2'` from `EliminationResult` (now populated in Phase 4a).
- [ ] **Task 4e.4**: Fix `omega_chain_elim_result` call site to include c2'.
- [ ] **Task 4e.5**: Fix `omega_chain` call sites in `ChronicleConstruction.lean` (lines 259, 281).

**Timing**: 2-3 hours

**Depends on**: Phase 4a-4b (all eliminations provide c2').

**Verification**:
- `omega_chain_c2'` accessor compiles.
- `lake build` succeeds.

---

### Phase 5a: Prove limit_satisfies_c5_full [NOT STARTED]

**Goal**: Prove the full C5a property at the limit, following Burgess Claim 2.11.

**Research finding**: With g-values populated at finite stages and c2' threaded:

Burgess's proof path:
1. U(ξ,η) ∈ limit_f(x) at some finite stage.
2. C5 elimination at a later stage creates witness y with ξ ∈ f(y) and η ∈ g(x,y).
3. By c2' maximality, g(x,y) persists (if pair stays adjacent) or propagates (if split, via C3).
4. At limit: ξ ∈ limit_g(x,y).
5. By C3: ξ ∈ limit_f(z) for all intermediate z.

Our adapted proof path (same structure, different limit_g definition):
1. Same as above.
2. Key lemma needed: `guard_in_r_maximal` — if BurgessR3Maximal and U(ξ,η), then ξ is in the g-value.
  - **Research gap identified**: This lemma may need to be proved or may follow from existing properties.
3. ξ ∈ limit_g(x,y) by construction (limit_g is intersection of intermediate f-values).
4. By `limit_c3_interval_subset_point` (already sorry-free): ξ ∈ limit_f(z) for all intermediate z.

**Tasks**:
- [ ] **Task 5a.1**: Prove or identify `guard_in_r_maximal` lemma.
  - If U(ξ,η) ∈ f(x) and BurgessR3Maximal(f(x), g(x,y), f(y)), does ξ ∈ g(x,y)?
  - This is a research question. If false, prove a variant sufficient for C5.
  - Difficulty: Hard (research-dependent, 2-6h)

- [ ] **Task 5a.2**: Prove `limit_satisfies_c5_full`.
  - Use `omega_chain_c2'` + `guard_in_r_maximal` + `limit_c3_interval_subset_point`.
  - Difficulty: Hard (~4h, contingent on 5a.1)

- [ ] **Task 5a.3**: Mirror for Since: `limit_satisfies_c5'_full`.
  - Difficulty: Medium (~2h)

**Timing**: 8-12 hours

**Depends on**: Phase 4e (c2' available at all stages).

**Verification**:
- `limit_satisfies_c5_full` compiles sorry-free.
- `lake build` succeeds.

---

### Phase 5b: Close FUC/FSC Sorries [NOT STARTED]

**Goal**: Close 2 sorries in ChronicleToCountermodel.lean.

**Research finding**: Straightforward once `limit_satisfies_c5_full` is available. The proof template in v54 plan (lines 449-463) is correct.

**Tasks**:
- [ ] **Task 5b.1**: Close FUC (line 615) using `limit_satisfies_c5_full` + Cantor transfer.
- [ ] **Task 5b.2**: Close FSC (line 619) mirror.

**Timing**: 2-3 hours

**Depends on**: Phase 5a.

**Verification**:
- ChronicleToCountermodel.lean sorry count: 0.
- `lake build` succeeds.

---

### Phase 5c: Final Audit and Verification [NOT STARTED]

Same as v54 plan Phase 5c.

- `#print axioms dd_countermodel_chronicle` shows no `sorryAx`
- `grep -rn "sorry" Theories/Bimodal/Metalogic/BXCanonical/Chronicle/` returns only comments
- Full `lake build` clean
- Create summary artifact: `specs/107/.../summaries/55_implementation-summary.md`

**Timing**: 1-2 hours.

---

## Phased Dependency Graph

```
Phase 2: Close D0 inconsistent case (2 sorries) ───────────────────────────┐
   │                                                                      │
   │ (independent)                                                        │
   │                                                                      │
Phase 3: Implement Lemma 2.7 (1 sorry) ──────────────────────────────────┤
   │                                                                      │
   ▼                                                                      │
Phase 4a: Construct g-values in eliminations (structural change)         │
   │                                                                      │
   ▼                                                                      │
Phase 4b: Prove c2' (10 sorries)                                        │
   │                                                                      │
   ▼                                                                      │
C11/C12: Close hard cases (2 sorries)                                   │
   │                                                                      │
   ▼                                                                      │
Phase 4e: Thread c2' through omega_chain                                 │
   │                                                                      │
   ▼                                                                      │
Phase 5a: Prove limit_satisfies_c5_full                                  │
   │                                                                      │
   ▼                                                                      │
Phase 5b: Close FUC/FSC (2 sorries) ─────────────────────────────────────┘
   │
   ▼
Phase 5c: Final audit
```

---

## Rollback/Contingency

- **guard_in_r_maximal lemma not provable (Phase 5a.1)**: Research team identified this as a gap. If the lemma is false, the approach must change to prove intermediate guard propagation directly (bypass g-values at the limit), or prove a weaker variant. Contingency: document the gap and mark task as partial.
- **g-value construction too invasive (Phase 4a)**: If modifying all elimination functions is prohibitive, start with C5 forward only (the critical path for Until formulas), and use trivial g-values (e.g., empty or g_content propagation only) for other directions.
- **Build instability during Phase 4a**: Phase 4a changes function signatures. Commit after each elimination function modification, and fix call sites incrementally.

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

---

## Agent Instruction Notes

**To lean-implementation-agent**:

1. **Follow the plan exactly** — do not invent novel approaches. All research has been done; deviations from Burgess are documented and either accepted or flagged for fixing.

2. **Phase 4a is about CONSTRUCTING g-values**, not just filling sorries. Each elimination must modify the Chronicle's g-function at new adjacent pairs.

3. **Use existing infrastructure**: `iterated_enrichment`, `burgess_zeta_consistent`, `burgess_D0_finite_subset_consistent`, `list_conj` compression, `burgessR3Maximal_from_g_content_sub`.

4. **Burgess 1982 text is the authority** for proof structure, but our BX axiom replacements (for open-guard) are the correct axioms to use.

5. **Do NOT introduce new axioms or axiomatic shortcuts**.

6. **At each phase boundary**: verify with `lake build`, check sorry counts, update phase status in this plan file.

---

**Plan revised**: 2026-05-04
**Based on**: Research reports burgess-24-26, burgess-27, burgess-29-210, burgess-211
**Previous plan**: v54 (superseded)
**Estimated Total Effort**: 28-38 hours (down from 37-50)
**Critical Path**: Phase 3 (8-10h) → Phase 4a (10-14h) → Phase 4b (4-6h) → Phase 4e (2-3h) → Phase 5a (8-12h) → Phase 5b (2-3h)
