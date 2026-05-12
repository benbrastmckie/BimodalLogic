# Implementation Plan: Stage Induction with Bot-Guard Adjacency

- **Task**: 123 - fix_c5_witness_bot_and_prove_icc_finite
- **Status**: [NOT STARTED]
- **Effort**: 3-5 hours
- **Dependencies**: None (all prerequisite infrastructure exists sorry-free)
- **Research Inputs**:
  - specs/123_fix_c5_witness_bot_and_prove_icc_finite/reports/10_guard-api-map.md
  - specs/123_fix_c5_witness_bot_and_prove_icc_finite/reports/10_orbit-convexity-patterns.md
  - specs/123_fix_c5_witness_bot_and_prove_icc_finite/reports/10_boundary-cases.md
  - specs/123_fix_c5_witness_bot_and_prove_icc_finite/reports/11_z1-axiom-check.md
  - specs/123_fix_c5_witness_bot_and_prove_icc_finite/reports/12_prior-uz-gap-closure.md
  - specs/123_fix_c5_witness_bot_and_prove_icc_finite/reports/09_step6-validation.md
  - specs/123_fix_c5_witness_bot_and_prove_icc_finite/reports/08_c5-midpoint-analysis.md
  - specs/123_fix_c5_witness_bot_and_prove_icc_finite/reports/07_verbrugge-deep-study.md
  - specs/123_fix_c5_witness_bot_and_prove_icc_finite/reports/07_doets-reynolds-deep-study.md
  - specs/123_fix_c5_witness_bot_and_prove_icc_finite/reports/07_codebase-fit-analysis.md
  - specs/123_fix_c5_witness_bot_and_prove_icc_finite/reports/07_mathematical-comparison.md
  - specs/123_fix_c5_witness_bot_and_prove_icc_finite/reports/04_team-research.md through 06_team-research.md
- **Artifacts**: plans/10_bot-guard-adjacency.md (this file)
- **Standards**:
  - .claude/context/formats/plan-format.md
  - .claude/rules/artifact-formats.md
  - .claude/rules/state-management.md
  - .claude/rules/lean4.md
- **Type**: lean4
- **Lean Intent**: true

### Research Integration

**Reports integrated in this plan version:**
- `10_guard-api-map.md` (newly integrated in v10)
- `10_orbit-convexity-patterns.md` (newly integrated in v10)
- `10_boundary-cases.md` (newly integrated in v10)
- `11_z1-axiom-check.md` (newly integrated in v10)
- `12_prior-uz-gap-closure.md` (newly integrated in v10)
- All reports from v4-v9 preserved

### Key Findings from Rounds 10-12

1. **Bot-guard adjacency forcing**: For adjacent dom(N) points x < y where C5-bot at x was processed at stage M with M+1 <= N, the witness z enters dom(N). `adj_g_mem_limit_f` + `bot_not_in_mcs` prevents ALL limit_dom points between x and z. Since z in dom(N) with x < z and adjacency, z = y. Therefore succ(x_sub) = y_sub.

2. **Stage induction on N**: Prove by Nat.rec on N. At stage N+1, at most one new point enters. The new point is bracketed by dom(N) points in the common case (split insertions). IH + `succ_orbit_convex` factor through the new point.

3. **Boundary cases (beyond-max, below-min) require care**: When a new point enters beyond max(dom(N)), `succ(max_sub)` is not guaranteed to equal the new point unless the specific counterexample was C5-bot at max. The implementation agent should try the stage induction first and fall back to the gap-closure approach if boundary cases prove intractable.

4. **Prior-UZ cannot close the gap directly** (report 12): No universal distinguishing formula exists for constant-model MCSs. The construction-specific approach is required.

5. **`succ_orbit_convex` is circularity-free** (report 10): Safe to use in the IsSuccArchimedean proof.

### Why Plan v10 Supersedes Plan v9

Plan v9 correctly identified the stage induction but organized Phase 2 around the "choose N" approach (circularity confirmed by reports 10/12) and left Phase 2 as [BLOCKED]. Plan v10 restructures Phase 2 as a direct Nat.rec induction with explicit case analysis and honest assessment of the boundary-case difficulty.

### Prior Plan Reference

Plan v9 had Phase 1 [COMPLETED], Phase 2 [BLOCKED], Phase 3 [NOT STARTED].

## Overview

Replace the convergence proof body of `limitDomSubtype_isSuccArchimedean` (lines 1196-1402 in `ChronicleToCountermodel.lean`) with a stage induction proof. The existing proof uses by_contra + real-analysis convergence and stalls at the "gap-at-L" case (sorry at line 1402). The replacement proof inductively shows that for all a, b in dom(N) with a <= b, succ^[k](a) = b for some k.

**Core strategy**: Prove `succ_reaches_dom_N` by Nat.rec on N.
- **Base (N=0)**: dom(0) = {0}, a = b = 0, k = 0.
- **Step (N -> N+1)**: Case split on dom(N) membership. Common case: new point between dom(N) points, handled by IH + orbit convexity. Boundary cases: new point beyond max or below min, handled by guard structure or impossibility argument.

**Definition of done**: `limitDomSubtype_isSuccArchimedean` sorry-free. `dd_countermodel_chronicle_discrete` sorry-free.

## Goals & Non-Goals

**Goals:**
- Close the sorry at line 1402 by replacing lines 1196-1402 with stage induction
- Prove `succ_reaches_dom_N` by Nat.rec on N
- Make `dd_countermodel_chronicle_discrete` sorry-free

**Non-Goals:**
- Preserving the convergence framework (replaced entirely)
- Defining `first_stage` as a standalone function
- Proving LocallyFiniteOrder (unless needed as fallback)
- Using Prior-UZ directly
- Modifying Phase 1 (already [COMPLETED])
- Solving the mixed or nondense cases

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Boundary case (3b): new point beyond max(dom(N)) | H | M | For C5-bot at max: guard gives succ(max_sub) = new_point directly. For other counterexamples: need to show succ orbit from max reaches new_point. If intractable, fall back to gap-closure approach. |
| Boundary case (2c): new point below min(dom(N)) | H | M | Mirror of (3b). succ from new_point to min may require multiple steps. If intractable, fall back. |
| Bracketing: finding w, w_next in dom(N) for new point | M | L | Use Finset.max/min of filtered subsets or `exists_containing_adjacent` (line 1389). |
| Proof exceeds 200 lines | M | M | Factor case analysis helpers into separate lemmas. Aim for 150-200 lines replacing 200 lines. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |

Phases within the same wave can execute in parallel.

### Phase 1: Add Imports and Prove Order.succ Equality [COMPLETED]

**Goal**: Add Mathlib imports and prove `Order.succ` equals `limitDomSubtype_succ`.

**Tasks**:
- [x] Add Mathlib imports (lines 11-12)
- [x] Prove `order_succ_eq` (line 1006, `rfl`)
- [x] Prove `order_pred_eq` (line 1017, `rfl`)

**Timing**: Completed
**Depends on**: none
**Completed**: 2026-05-11

---

### Phase 2: Stage Induction Proof [PARTIAL]

**Goal**: Prove `succ_reaches_dom_N` and rewire `limitDomSubtype_isSuccArchimedean`.

#### Step 2a: Prove `succ_reaches_dom_N` (~120-180 lines)

**Location**: Insert before `limitDomSubtype_isSuccArchimedean` (before line 1190).

**Signature**:
```lean
private theorem succ_reaches_dom_N (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (h_discrete : ∀ x ∈ limit_dom A h_mcs, next_top ∈ limit_f A h_mcs x)
    (N : Nat) (a b : LimitDomSubtype A h_mcs)
    (ha : a.val ∈ (omega_chain_val A h_mcs N).dom)
    (hb : b.val ∈ (omega_chain_val A h_mcs N).dom)
    (hab : a ≤ b) :
    ∃ k, (limitDomSubtype_succ A h_mcs h_discrete)^[k] a = b
```

**Proof by Nat.rec on N, 4 cases at the inductive step:**

**Case 1 (both in dom(N))**: Apply IH directly.

**Case 2 (a new, b old)**: a.val in dom(N+1)\dom(N). Subcases:
- a between dom(N) points w, w_next: IH gives succ^[m](w_sub) = w_next_sub. Orbit convexity factors through a: succ^[j](w_sub) = a. Then succ^[m-j](a) = w_next_sub. IH gives succ^[m'](w_next_sub) = b. Chain: succ^[m-j+m'](a) = b.
- a beyond max(dom(N)): b in dom(N) implies b.val <= max(dom(N)) < a.val, contradicting a <= b. Impossible.
- a below min(dom(N)): Use `limit_dom_has_succ` at a. succ(a) > a. Need succ^[k](a) reaches some dom(N) point, then IH continues. The guard from the C5 construction ensures succ(a) is adjacent to some dom(N) point via the bot-guard. If the counterexample at step N was C5-backward at min placing a below min, the backward guard (with bot for U(T,bot)) ensures no limit_dom between a and the counterexample point pt (in dom(N)), giving succ(a) = pt_sub. IH continues from pt.

**Case 3 (a old, b new)**: b.val in dom(N+1)\dom(N). Subcases:
- b between dom(N) points w, w_next: IH gives succ^[m](a) = w_next_sub (a in dom(N), w_next in dom(N)). Since a <= b < w_next, orbit convexity gives succ^[j](a) = b for some j <= m.
- b beyond max(dom(N)): IH gives succ^[m](a) = max_sub. Need succ(max_sub) to reach b. If the specific elimination at step N placed b via C5-forward-bot at max, the bot-guard ensures succ(max_sub) = b. For other counterexample types, use limit_dom_has_succ properties. If succ(max_sub) = b: chain gives succ^[m+1](a) = b. If succ(max_sub) < b: need additional succ steps; apply orbit convexity if succ^[m+j](a) eventually passes b.
- b below min(dom(N)): b < min(dom(N)) <= a.val, contradicting a <= b. Impossible.

**Case 4 (both new)**: omega_chain_dom_new_unique gives a.val = b.val, hence a = b, k = 0.

**Key API used**:
- `omega_chain_dom_new_unique` (ChronicleConstruction.lean:1196)
- `omega_chain_dom_mono_le` (ChronicleConstruction.lean:334)
- `succ_orbit_convex` (ChronicleToCountermodel.lean:1112)
- `limit_dom_has_succ` (ChronicleToCountermodel.lean:858)
- `adj_g_mem_limit_f` (ChronicleConstruction.lean:1367)
- `bot_not_in_mcs` (TruthLemma.lean:63)
- `singleton_dom` / `singleton_chronicle` (ChronicleConstruction.lean:83/64)

**Implementation guidance for the agent**:

The common cases (1, 2-between, 3-between, 4) are clean and should be implemented first. Cases 2-beyond and 3-beyond are trivially impossible (contradiction with a <= b). Cases 2-below and 3-above-max are the hard boundary cases. For these:

- **Case 2-below-min**: The new point a was placed below min(dom(N)). To show succ(a) = min_sub: use the fact that h_discrete gives U(T,bot) at a, so `limit_dom_has_succ` gives some y > a with no limit_dom between a and y. min(dom(N)) is in limit_dom with min > a. So y <= min. If y < min, y is a limit_dom point between a and min that is NOT in dom(N). The key question is whether y is in dom(N+1) or a later stage. If the elimination at step N placed a via C5-backward at min with bot guard: no limit_dom between a and min, so succ(a) = min_sub. If the guard is not bot (non-C5-bot counterexample): succ(a) might not equal min_sub. In this case, try proving that the guard IS bot by analyzing the elimination at step N, or use an alternative argument.

- **Case 3-above-max**: The new point b was placed beyond max(dom(N)). Same analysis as 2-below-min, mirrored. If the elimination at step N was C5-forward-bot at max: succ(max_sub) = b (bot-guard ensures no limit_dom between). Otherwise: need alternative argument.

**If boundary cases prove intractable**: The agent should write a handoff explaining the difficulty and recommend the fallback: close the gap-at-L sorry at line 1402 in the existing convergence proof instead of replacing the entire proof body. The gap-at-L closure would use counterexample processing to show a Dedekind cut in limit_dom is impossible.

**Tasks:**
- [ ] Implement base case (N = 0)
- [ ] Implement Case 1 (both in dom(N)) -- IH
- [ ] Implement Case 2-between (a new, between dom(N) points) -- IH + orbit convexity
- [ ] Implement Case 3-between (b new, between dom(N) points) -- IH + orbit convexity
- [ ] Implement Case 4 (both new) -- uniqueness
- [ ] Implement Case 2-beyond-max (impossible) -- contradiction
- [ ] Implement Case 3-below-min (impossible) -- contradiction
- [ ] Implement Case 2-below-min -- guard argument or fallback
- [ ] Implement Case 3-above-max -- guard argument or fallback

**Timing**: 2-3 hours
**Depends on**: Phase 1

#### Step 2b: Wire up `limitDomSubtype_isSuccArchimedean` (~20-30 lines)

**Location**: Replace lines 1196-1402.

```lean
@IsSuccArchimedean.mk _ _ (limitDomSubtype_succOrder A h_mcs h_discrete) <| by
  intro a b hab
  change ∃ n, (limitDomSubtype_succ A h_mcs h_discrete)^[n] a = b
  obtain ⟨M_a, hM_a⟩ := a.property
  obtain ⟨M_b, hM_b⟩ := b.property
  have ha_N := omega_chain_dom_mono_le A h_mcs (le_max_left M_a M_b) hM_a
  have hb_N := omega_chain_dom_mono_le A h_mcs (le_max_right M_a M_b) hM_b
  exact succ_reaches_dom_N A h_mcs h_discrete (max M_a M_b) a b ha_N hb_N hab
```

**Tasks:**
- [ ] Delete lines 1196-1402
- [ ] Insert new proof body
- [ ] Verify with `lean_goal` and `lean_verify`

**Timing**: 0.5 hour
**Depends on**: Step 2a

---

### Phase 3: Verification and Cleanup [NOT STARTED]

**Goal**: Verify compilation and sorry elimination downstream.

**Tasks**:
- [ ] `lake build ChronicleToCountermodel` passes
- [ ] `lean_verify` on `limitDomSubtype_isSuccArchimedean` -- no sorry
- [ ] `lean_verify` on `succ_embed_surjective` -- no sorry
- [ ] `lean_verify` on `dd_countermodel_chronicle_discrete` -- no sorry
- [ ] Grep for sorry confirms only nondense/mixed stubs remain
- [ ] Full `lake build` passes
- [ ] Remove temporary scaffolding

**Timing**: 0.5-1 hour
**Depends on**: 2

## Testing & Validation

- [ ] `lake build ChronicleToCountermodel` passes
- [ ] `lean_verify` on `limitDomSubtype_isSuccArchimedean` -- no sorry
- [ ] `lean_verify` on `succ_embed_surjective` -- no sorry
- [ ] `lean_verify` on `dd_countermodel_chronicle_discrete` -- no sorry
- [ ] Grep for sorry shows only nondense and mixed stubs
- [ ] Full `lake build` passes

## Artifacts & Outputs

- **Plan**: `specs/123_fix_c5_witness_bot_and_prove_icc_finite/plans/10_bot-guard-adjacency.md` (this file)
- **Modified files**:
  - `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` -- add `succ_reaches_dom_N` lemma and replace proof body of `limitDomSubtype_isSuccArchimedean`
- **Summary**: `specs/123_fix_c5_witness_bot_and_prove_icc_finite/summaries/10_bot-guard-adjacency-summary.md` (after implementation)

## Rollback/Contingency

Theorem statement unchanged. Rollback: `git checkout` the modified file.

If the stage induction fails at boundary cases:

1. **Primary fallback: Close gap-at-L sorry directly** (60% confidence, 100-200 lines): Keep the existing convergence proof. Close the sorry at line 1402 by showing a Dedekind cut in limit_dom is impossible using counterexample processing: for orbit element w and above-orbit element c, some C4/C5 counterexample between them eventually inserts a point in the gap with pred <= L, triggering the existing h_pred_below_L_contradiction helper.

2. **Secondary fallback: LocallyFiniteOrder** (85% confidence, 400-600 lines): Prove `Set.Finite (Set.Icc a b)` for all a, b : LimitDomSubtype. Mathlib provides LocallyFiniteOrder -> IsSuccArchimedean.

3. **Last resort**: Leave sorry with documentation.
