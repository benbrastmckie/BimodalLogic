# Implementation Plan: Prove IsSuccArchimedean for LimitDomSubtype

- **Task**: 123 - fix_c5_witness_bot_and_prove_icc_finite
- **Status**: [NOT STARTED]
- **Effort**: 4-6 hours
- **Dependencies**: None (all prerequisite infrastructure exists sorry-free)
- **Research Inputs**:
  - specs/123_fix_c5_witness_bot_and_prove_icc_finite/reports/04_team-research.md
- **Artifacts**: plans/04_issucc-archimedean.md (this file)
- **Standards**:
  - .claude/context/formats/plan-format.md
  - .claude/rules/artifact-formats.md
  - .claude/rules/state-management.md
  - .claude/rules/lean4.md
- **Type**: lean4
- **Lean Intent**: true

### Research Integration

**Round 4** (`04_team-research.md`, 4 teammates): Unanimously confirmed that `IsSuccArchimedean` is provable via monotone convergence + predecessor contradiction. Key findings:
- The author's "Icc infinite" comment (lines 1085-1087) is WRONG for the discrete case
- Pure order theory cannot prove `IsSuccArchimedean` -- real analysis (monotone convergence) is required
- All Mathlib pipeline imports except two are already present; only `Mathlib.Topology.Instances.Real.Lemmas` and `Mathlib.Data.Rat.Cast.Order` need adding
- 6 of 7 typeclass prerequisites exist; only `IsSuccArchimedean` is missing
- Bridge code from `IsSuccArchimedean` to `succ_embed_surjective` is ~30 lines

### Prior Plan Reference

Prior plan v3 (`01_fix-c5-bot-witness.md`) had 5 phases:
- **Phase 1** [COMPLETED]: Collapse equivalence and quotient map
- **Phase 2** [COMPLETED]: FMCS on Z via direct embedding
- **Phase 3** [COMPLETED]: Succ-based embedding and discrete BFMCS infrastructure
- **Phase 4** [BLOCKED]: Single-orbit surjectivity proof (stage induction failed)
- **Phase 5** [COMPLETED]: Case split refinement and final wiring

**Lesson learned**: Stage induction fails because `Classical.choose` picks from the FULL `limit_dom` (future stages included), making `succ_embed(J+1)` opaque to stage-level reasoning. The new approach bypasses stage induction entirely by proving `IsSuccArchimedean` as a typeclass, which gives `succ_embed_surjective` via the Mathlib pipeline.

### Roadmap Alignment

This plan advances:
- "Discrete completeness: 1 sorry remains (task 122)" -- closing `succ_embed_surjective` makes the discrete countermodel sorry-free
- "Full `bx_completeness`: Blocked by 1 sorry in discrete case" -- unblocking the discrete case moves toward sorry-free `bx_completeness`

## Overview

This plan replaces the failed Phase 4 from the prior plan (v3) with a new approach: prove `IsSuccArchimedean` for `LimitDomSubtype` using real analysis (monotone convergence + predecessor contradiction), then bridge to `succ_embed_surjective` via Mathlib's `exists_succ_iterate_of_le`. The proof strategy is: given `a <= b`, assume no iterate of succ reaches `b`; then the pred-chain `pred^[k](b)` is strictly decreasing and bounded below, converging in R to a limit `L` that violates the immediate predecessor property. This closes the two sorry sites at lines 2053 and 2056 of `ChronicleToCountermodel.lean`.

**Definition of done**: `succ_embed_surjective` is sorry-free. `dd_countermodel_chronicle_discrete` is sorry-free. The only remaining sorry in the chronicle files is `dd_countermodel_chronicle_mixed_sorry`.

## Goals & Non-Goals

**Goals:**
- Add two new imports (`Mathlib.Topology.Instances.Real.Lemmas`, `Mathlib.Data.Rat.Cast.Order`)
- Prove `order_succ_eq_limitDomSubtype_succ`: that `Order.succ` equals `limitDomSubtype_succ` under `NoMaxOrder`
- Prove `limitDomSubtype_isSuccArchimedean`: the core convergence + predecessor contradiction
- Rewrite `succ_embed_surjective` to use `IsSuccArchimedean` instead of stage induction
- Close the two sorry sites at lines 2053 and 2056
- Make `dd_countermodel_chronicle_discrete` sorry-free

**Non-Goals:**
- Modifying the omega-chain construction (`ChronicleConstruction.lean`)
- Modifying BUC (already sorry-free)
- Solving the mixed case (`dd_countermodel_chronicle_mixed_sorry`)
- Proving `LocallyFiniteOrder` (stronger than needed; `IsSuccArchimedean` suffices)
- Modifying phases 1, 2, 3, or 5 (all completed)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Real analysis imports increase build time | L | M | Only 2 new imports; Mathlib already imported heavily |
| Convergence argument hard to formalize in Lean | M | M | Teammate A designed detailed pseudo-Lean proof; Mathlib has `tendsto_of_monotone` and `Real.isCauSeq` |
| `Order.succ` vs `limitDomSubtype_succ` mismatch | M | L | Teammate D verified definitional unfolding works; `SuccOrder.ofSuccLeIff` construction guarantees equality |
| Bridge code from `IsSuccArchimedean` to `succ_embed_surjective` fails | H | L | Teammate D mapped the exact pipeline: `exists_succ_iterate_of_le` + case split on `root <= w` vs `w < root` |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |

Phases within the same wave can execute in parallel.

### Phase 1: Add Imports and Prove Order.succ Equality [NOT STARTED]

**Goal**: Add the two missing Mathlib imports and prove that `Order.succ` equals `limitDomSubtype_succ` when the `SuccOrder` instance is registered via `letI`.

**Tasks**:
- [ ] Add `import Mathlib.Topology.Instances.Real.Lemmas` after line 9
- [ ] Add `import Mathlib.Data.Rat.Cast.Order` after line 9
- [ ] Run `lake build` to verify imports compile (this may be slow due to new transitive dependencies)
- [ ] Prove `order_succ_eq_limitDomSubtype_succ`: under `letI := limitDomSubtype_succOrder A h_mcs h_discrete`, show `Order.succ x = limitDomSubtype_succ A h_mcs h_discrete x` for all `x : LimitDomSubtype A h_mcs`
  - Proof sketch: `Order.succ` for `SuccOrder.ofSuccLeIff f h` is `f` by definition; unfold and apply `rfl` or `simp [Order.succ, SuccOrder.ofSuccLeIff]`
  - Place this lemma after `limitDomSubtype_predOrder` (around line 997), inside a section that opens with `letI := limitDomSubtype_succOrder` and `letI := limitDomSubtype_predOrder`
- [ ] Similarly prove `order_pred_eq_limitDomSubtype_pred` if needed

**Timing**: 0.5-1 hour

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` -- add imports (lines 1-9), add equality lemma (after line 997)

**Verification**:
- `lake build ChronicleToCountermodel` compiles
- `lean_goal` at the `order_succ_eq` lemma shows no goals

---

### Phase 2: Prove IsSuccArchimedean for LimitDomSubtype [NOT STARTED]

**Goal**: Prove that `LimitDomSubtype` satisfies `IsSuccArchimedean` using the monotone convergence + predecessor contradiction argument. This is the mathematical core of the plan.

**Tasks**:
- [ ] Define the `IsSuccArchimedean` instance for `LimitDomSubtype`:
  ```
  instance limitDomSubtype_isSuccArchimedean (A : Set Formula) (h_mcs : SetMaximalConsistent A)
      (h_discrete : ∀ x ∈ limit_dom A h_mcs, next_top ∈ limit_f A h_mcs x) :
      @IsSuccArchimedean (LimitDomSubtype A h_mcs) _
        (limitDomSubtype_succOrder A h_mcs h_discrete) := by
  ```
  The instance requires proving: `∀ a b, a ≤ b → ∃ n, succ^[n](a) = b`
- [ ] Implement the proof by contradiction. Given `a <= b`, assume `succ^[n](a) /= b` for all `n`. The core argument:
  1. Show `succ^[n](a) < b` for all `n` (by induction: if `succ^[n](a) < b`, then `succ^[n](a) < b` implies `succ^[n+1](a) <= b`, and `succ^[n+1](a) /= b` gives strict inequality)
  2. Show `succ^[n](a) <= pred(b)` for all `n` (from `le_pred_iff`: `x <= pred(b) <-> x < b`)
  3. If any `succ^[n](a) = pred(b)`, then `succ^[n+1](a) = succ(pred(b)) = b` -- contradiction with the assumption
  4. So `succ^[n](a) < pred(b)` for all `n`. Repeat: `succ^[n](a) < pred^[k](b)` for all `n, k`
  5. The sequence `pred^[k](b)` is strictly decreasing (`pred^[k+1](b) < pred^[k](b)` since `pred(x) < x` always)
  6. The Q-values `(pred^[k](b)).val` are strictly decreasing and bounded below by `a.val`
  7. Cast to R: the sequence `((pred^[k](b)).val : R)` is monotone decreasing and bounded, hence converges to some limit `L` in R
  8. Derive contradiction: for large enough `k`, `pred^[k](b)` and `pred^[k+1](b)` are arbitrarily close in R, but they are consecutive in `LimitDomSubtype` (no domain points between them). The gap `pred^[k](b).val - pred^[k+1](b).val` tends to 0, but each gap is a rational interval containing no domain points. Meanwhile, `succ^[n](a)` for large `n` must enter one of these gaps (since the orbit values are increasing toward `L` from below), contradicting no domain points between consecutive elements
- [ ] Alternative contradiction argument (may be simpler in Lean):
  - The sequence `pred^[k](b).val` in Q is decreasing and bounded below by `a.val`
  - The sequence `succ^[n](a).val` in Q is increasing and bounded above by `pred^[k](b).val` for all `k`
  - Both sequences are bounded monotone sequences in Q (embedded in R)
  - Let `L_up = sup{succ^[n](a).val}` and `L_down = inf{pred^[k](b).val}` in R
  - `L_up <= L_down` since every orbit element is below every pred-chain element
  - If `L_up < L_down`: the interval `(L_up, L_down)` in R contains no domain points (since orbit elements are below `L_up` and pred-chain elements are above `L_down`). But `NoMaxOrder` applied to any orbit element gives a successor above it, still in the orbit, contradicting that the orbit is bounded above by `L_up`. (Actually the successor IS the next orbit element, so the orbit approaches `L_up` from below. The key is that for any `eps > 0`, eventually `succ^[n](a).val > L_up - eps`. Similarly `pred^[k](b).val < L_down + eps`. But between any two consecutive orbit elements, no domain points. So a pred-chain element cannot be between consecutive orbit elements. This forces `L_up = L_down`.)
  - If `L_up = L_down = L`: both sequences converge to `L`. For large `n` and `k`, `succ^[n](a).val` and `pred^[k](b).val` are within `eps` of `L`. But `succ^[n](a) < pred^[k](b)` always, and both are domain points, with `succ^[n+1](a)` the immediate successor of `succ^[n](a)` (no domain points between). For `n` large enough that `succ^[n](a).val > L - eps` and `k` large enough that `pred^[k](b).val < L + eps`, we get `pred^[k](b)` is a domain point between `succ^[n](a)` and `succ^[n+1](a)` (since `succ^[n](a) < pred^[k](b) < succ^[n+1](a)` for appropriate `n, k`). This contradicts `succ_embed_no_gap` (or the analogous no-gap property for the successor function).
- [ ] Key Mathlib lemmas to use:
  - `Rat.cast_le` / `Rat.cast_lt` for embedding Q into R
  - `MonotoneBoundedBelow.tendsto` or `tendsto_of_monotone` for convergence of bounded monotone sequences
  - `IsSuccArchimedean` definition: `∀ {a b}, a ≤ b → ∃ n, Order.succ^[n] a = b`
  - `limitDomSubtype_succ_le_iff` for `succ(x) <= y <-> x < y`
  - `limitDomSubtype_le_pred_iff` for `x <= pred(y) <-> x < y`
  - `limitDomSubtype_succ_pred` / `limitDomSubtype_pred_succ` for cancellation
  - `succ_embed_no_gap` for the final contradiction (adapted to the general successor, not just `succ_embed`)
- [ ] Place the proof after Phase 1's equality lemmas, before `succ_embed_surjective` (around line 1080-1095, in the section before the collapse infrastructure)

**Timing**: 2-4 hours (the core formalization effort)

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` -- add `IsSuccArchimedean` instance (~80-120 lines)

**Verification**:
- `lean_goal` at each step of the proof shows expected intermediate goals
- `lean_verify` on `limitDomSubtype_isSuccArchimedean` shows no sorry
- `lake build ChronicleToCountermodel` compiles

---

### Phase 3: Bridge to succ_embed_surjective and Close Sorry Sites [NOT STARTED]

**Goal**: Rewrite `succ_embed_surjective` to use `IsSuccArchimedean` instead of stage induction, closing the two sorry sites at lines 2053 and 2056. Verify the entire discrete pipeline is sorry-free.

**Tasks**:
- [ ] Replace the entire proof body of `succ_embed_surjective` (lines 2008-2088) with the bridge argument:
  ```lean
  theorem succ_embed_surjective (A : Set Formula) (h_mcs : SetMaximalConsistent A)
      (h_discrete : ∀ x ∈ limit_dom A h_mcs, next_top ∈ limit_f A h_mcs x)
      (w : LimitDomSubtype A h_mcs) :
      ∃ n : ℤ, succ_embed A h_mcs h_discrete n = w := by
    letI := limitDomSubtype_succOrder A h_mcs h_discrete
    letI := limitDomSubtype_predOrder A h_mcs h_discrete
    set root := (⟨0, zero_mem_limit_dom A h_mcs⟩ : LimitDomSubtype A h_mcs)
    by_cases h : root ≤ w
    · -- root ≤ w: use IsSuccArchimedean to get n with succ^[n](root) = w
      obtain ⟨n, hn⟩ := IsSuccArchimedean.exists_succ_iterate_of_le h
      -- succ^[n](root) = succ_embed(n) by definition
      exact ⟨n, ...⟩  -- bridge succ^[n] to succ_embed via order_succ_eq
    · -- w < root: use IsSuccArchimedean on the pred side
      push_neg at h
      -- pred^[n](root) = w for some n, i.e., succ_embed(-n) = w
      obtain ⟨n, hn⟩ := IsSuccArchimedean.exists_succ_iterate_of_le (le_of_lt h)
      -- succ^[n](w) = root, so w = pred^[n](root) = succ_embed(-n)
      exact ⟨-n, ...⟩  -- bridge pred^[n] to succ_embed via order_pred_eq
  ```
- [ ] The bridge requires connecting:
  - `Order.succ^[n] root = w` (from `IsSuccArchimedean`) with
  - `succ_embed n = w` (the theorem's conclusion)
  - This connection uses `order_succ_eq_limitDomSubtype_succ` from Phase 1:
    `Order.succ^[n] root = (limitDomSubtype_succ)^[n] root = succ_embed n`
  - For the negative case: `Order.succ^[n] w = root` implies `w = pred^[n] root = succ_embed (-n)`
    Using `limitDomSubtype_pred_succ` cancellation iteratively
- [ ] Update the docstring of `succ_embed_surjective` to remove the sorry documentation (lines 1983-2003)
- [ ] Update the comment block at lines 1082-1097 to remove the "fails" language about `IsSuccArchimedean`
- [ ] Verify `lake build ChronicleToCountermodel` compiles sorry-free (except `dd_countermodel_chronicle_mixed_sorry`)
- [ ] Verify `lake build Completeness` compiles
- [ ] Run `lean_verify` on:
  - `succ_embed_surjective`
  - `cantor_bfmcs_discrete_restricted_tc`
  - `cantor_bfmcs_discrete_restricted_fuc`
  - `dd_countermodel_chronicle_discrete`
- [ ] Grep for `sorry` in `ChronicleToCountermodel.lean` -- should show only `dd_countermodel_chronicle_mixed_sorry` and `dd_countermodel_chronicle_nondense_sorry`

**Timing**: 1-2 hours

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` -- rewrite `succ_embed_surjective` proof body (~30 lines replacing ~80 lines), update comments

**Verification**:
- `lean_verify succ_embed_surjective` -- no sorry
- `lean_verify dd_countermodel_chronicle_discrete` -- no sorry
- `grep sorry ChronicleToCountermodel.lean` -- only mixed-case and nondense stubs
- Full `lake build` passes

## Testing & Validation

- [ ] `lake build ChronicleToCountermodel` passes after Phase 1 (imports + equality lemma)
- [ ] `lake build ChronicleToCountermodel` passes after Phase 2 (IsSuccArchimedean)
- [ ] `lake build ChronicleToCountermodel` passes after Phase 3 (bridge)
- [ ] `lean_verify` on `succ_embed_surjective` confirms no sorry
- [ ] `lean_verify` on `dd_countermodel_chronicle_discrete` confirms no sorry
- [ ] `lean_verify` on `cantor_bfmcs_discrete_restricted_tc` confirms no sorry
- [ ] `lean_verify` on `cantor_bfmcs_discrete_restricted_fuc` confirms no sorry
- [ ] Grep for sorry in `ChronicleToCountermodel.lean` shows only the mixed-case and nondense stubs
- [ ] Full `lake build` passes

## Artifacts & Outputs

- **Plan**: `specs/123_fix_c5_witness_bot_and_prove_icc_finite/plans/04_issucc-archimedean.md` (this file)
- **Modified files**:
  - `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` (imports, IsSuccArchimedean instance, succ_embed_surjective rewrite)
- **Summary**: `specs/123_fix_c5_witness_bot_and_prove_icc_finite/summaries/04_issucc-archimedean-summary.md` (after implementation)

## Rollback/Contingency

All changes are in a single file (`ChronicleToCountermodel.lean`). The theorem statement of `succ_embed_surjective` is unchanged -- only the proof body is replaced. Reverting: restore the sorry at lines 2053 and 2056 and remove the new imports and lemmas.

If the monotone convergence approach proves too hard to formalize:
1. **Fallback A (Nat.find on stages)**: Use `Nat.find` to find the first omega-chain stage K where a domain point >= w appears. Analyze the structure at that stage to show the new point must be an orbit element.
2. **Fallback B (direct Finset argument)**: Prove `Set.Finite {x : LimitDomSubtype | a <= x /\ x <= b}` using the omega-chain stage structure (each stage adds finitely many points, and between consecutive orbit elements nothing else exists).
3. **Fallback C (leave sorry documented)**: Keep the sorry with detailed documentation that the mathematical proof is confirmed correct by 4 independent analyses. The discrete case would be "sorry-free modulo succ_embed_surjective."
