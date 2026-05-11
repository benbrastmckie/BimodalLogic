# Implementation Plan: Fix C5 Witness Placement for ξ=⊥ and Prove Icc_finite

- **Task**: 123 - fix_c5_witness_bot_and_prove_icc_finite
- **Status**: [NOT STARTED]
- **Effort**: 15-20 hours
- **Dependencies**: None (all prerequisite infrastructure exists)
- **Research Inputs**:
  - specs/123_fix_c5_witness_bot_and_prove_icc_finite/reports/01_blocker-analysis.md
  - specs/123_fix_c5_witness_bot_and_prove_icc_finite/reports/01_teammate-a-findings.md
  - specs/123_fix_c5_witness_bot_and_prove_icc_finite/reports/01_team-research-reynolds.md
- **Artifacts**: plans/01_fix-c5-bot-witness.md (this file)
- **Standards**:
  - .claude/rules/artifact-formats.md
  - .claude/rules/state-management.md
  - .claude/rules/lean4.md
- **Type**: lean4

## Overview

The current C5 counterexample elimination for `U(η, ⊥)` inserts a midpoint at every step because: (1) condition (i) always fails (requires `⊥ ∧ U(η,⊥) ∈ f(x')`, impossible since ⊥ is never in MCS), and (2) the "already resolved" check requires `⊥ ∈ g(a,b)`, which fails when g-values are consistent. This creates infinite chains of midpoints in bounded intervals, making `limitDomSubtype_Icc_finite` false.

The fix weakens `EliminationResult.c5_forward_witness` to add a disjunction for the vacuous-guard case (ξ=⊥, witness is dom-successor with no intervening points). The elimination function skips midpoint insertion for ξ=⊥, returning the chronicle unchanged with the dom-successor as witness. The limit-level C5 proof handles the new disjunct via contradiction (⊥ is never in any MCS). With infinite midpoint chains eliminated, `limitDomSubtype_Icc_finite` becomes provable via omega-chain stabilization.

### Research Integration

- `01_blocker-analysis.md`: Root cause — infinite midpoint accumulation from ξ=⊥ C5 walks
- `01_teammate-a-findings.md`: Option A (weaken spec) recommended, detailed code-location analysis
- `01_team-research-reynolds.md`: Confirmed direct proof is correct path (15-20h vs 60-120h for Reynolds)

## Goals & Non-Goals

**Goals:**
- Prevent infinite midpoint insertion when ξ=⊥ in C5 counterexample elimination
- Weaken `EliminationResult.c5_forward_witness` to allow vacuous guard satisfaction
- Propagate the weakened witness through `omega_chain_c5_witness` and `limit_satisfies_c5_strong`
- Prove `limitDomSubtype_Icc_finite` (ChronicleToCountermodel.lean:1064)
- Mirror the fix for the backward (Since) direction (c5_backward_witness)

**Non-Goals:**
- Changing the dense case (already sorry-free via Cantor isomorphism)
- Refactoring the C5 walk for non-⊥ cases (those work correctly)
- Proving `dd_countermodel_chronicle_nondense_sorry` (line 836, separate task 122)

## Risks & Mitigations

- **Risk: The new disjunct breaks downstream consumers.** Mitigation: `omega_chain_c5_witness` and `limit_satisfies_c5_strong` are the only consumers; both are in ChronicleConstruction.lean and can be updated in the same phase.

- **Risk: Proving `η ∈ f(successor)` from `U(η,⊥) ∈ f(x)` and BurgessR3Maximal.** Mitigation: The vacuous-guard disjunct avoids needing this — it only requires y to be dom-successor with no intervening points. The η ∈ f(y) is obtained from the existing base case (lemma_2_4_with_guard) when x = max(dom), or from BurgessR3Maximal accessibility via a new helper lemma `untl_bot_event_in_r3m`.

- **Risk: Interval stabilization proof is complex.** Mitigation: Break into sub-lemmas (permanent closure, bounded stabilization, finite intersection). Each is independently testable. Fallback: use convergence-in-ℝ argument instead.

- **Risk: Since mirror requires symmetric changes.** Mitigation: Structurally identical; changes are mechanical once forward direction is correct.

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

### Phase 1: Weaken EliminationResult Witness Spec [NOT STARTED]

**Goal:** Change `c5_forward_witness` and `c5_backward_witness` in `EliminationResult` to add a disjunct for vacuous guard satisfaction (ξ=⊥).

**Tasks:**
- [ ] In `CounterexampleElimination.lean`, modify the `c5_forward_witness` field (line 571-576). Add a disjunction: the existing guard condition OR "y is the immediate dom-successor of x with no intervening points" (`∀ w ∈ val.dom, pc.x < w → w < y → False`).
- [ ] Mirror the same change for `c5_backward_witness` (line 577-582).
- [ ] Update ALL existing proof terms that fill `c5_forward_witness` to use `Or.inl` wrapping. Locations: lines ~1914-1951 (n=0 case), ~2030-2033 (condition i case), ~2233-2272 (split case), ~2339-2343 (not-actual case).
- [ ] Update ALL existing proof terms for `c5_backward_witness` similarly.
- [ ] Verify `lake build CounterexampleElimination` compiles.

**Timing:** 3-4 hours

**Depends on:** none

### Phase 2: Add ξ=⊥ Short-Circuit in eliminate_potential_counterexample [NOT STARTED]

**Goal:** When ξ=⊥ and kind=c5_forward (or c5_backward), return the chronicle unchanged with the dom-successor (or dom-predecessor) as the witness, using the `Or.inr` vacuous-guard disjunct.

**Tasks:**
- [ ] In `eliminate_potential_counterexample` (line 1820), inside the `.c5_forward` match arm, add `by_cases h_bot : pc.ξ = Formula.bot` BEFORE the existing `by_cases h_actual` (line 1825).
- [ ] When `h_bot` holds and x ∈ dom and U(η,⊥) ∈ f(x): find dom-successor x' (using existing Finset.filter + min' pattern from line 1980-1995). If x = max(dom): use existing base case (lemma_2_4_with_guard — one insertion, no recursion, no infinite chain). If x ≠ max(dom): return identity EliminationResult (`val := χ`) with x' as witness and `Or.inr` proof that no dom points exist between x and x' (from adjacency).
- [ ] Prove helper lemma `untl_bot_event_in_r3m`: Given `BurgessR3Maximal A B C`, `SetMaximalConsistent A`, `U(η, ⊥) ∈ A`, conclude `η ∈ C`. Place in CounterexampleElimination.lean or RRelation.lean.
- [ ] Mirror for `.c5_backward` case.
- [ ] Verify `lake build CounterexampleElimination` compiles.

**Timing:** 4-5 hours

**Depends on:** 1

### Phase 3: Update omega_chain_c5_witness and limit_satisfies_c5_strong [NOT STARTED]

**Goal:** Propagate the weakened c5_forward_witness through ChronicleConstruction.lean to the limit-level C5 proof.

**Tasks:**
- [ ] Update `omega_chain_c5_witness` (line 391-425) return type to include the disjunction from Phase 1. Propagate via `hn_eq` rewriting.
- [ ] Update `omega_chain_c5'_witness` (line 430-463) similarly for Since.
- [ ] Update `limit_satisfies_c5_strong` (line 1440-1481). After obtaining the disjunction, case split:
  - **Left case**: existing proof unchanged.
  - **Right case (vacuous)**: The right disjunct says no dom_{n+1} points between x and y. Need to show `∀ w ∈ limit_dom, x < w → w < y → ⊥ ∈ limit_f(w)`. Since ξ=⊥ in this case, and the vacuous disjunct guarantees no points were between x and y at stage n+1, prove that no FUTURE stage adds points between x and y either (permanent closure). For any such w, derive ⊥ ∈ limit_f(w) using `adj_g_mem_limit_f` (existing lemma), which gives `⊥ ∈ limit_f(w)` from `⊥ ∈ g_{n+1}(x,y)`. But we need `⊥ ∈ g_{n+1}(x,y)` — this requires that the g-value at (x,y) at stage n+1 contains ⊥. Check whether this is the case: at stage n+1, x and y are adjacent in dom_{n+1} (from the vacuous disjunct). The g-value g_{n+1}(x,y) is the original chronicle g-value since no insertion happened. If the original g(x,y) doesn't contain ⊥, we need a different argument. Alternative: since no points exist between x and y in ANY stage (by the permanent-closure property from the ξ=⊥ fix), the guard is vacuously satisfied at the limit level.
- [ ] Update `limit_satisfies_c5'_strong` (line 1483-1518) with Since mirror.
- [ ] Verify `lake build ChronicleConstruction` compiles.

**Timing:** 4-5 hours

**Depends on:** 2

### Phase 4: Prove limitDomSubtype_Icc_finite [NOT STARTED]

**Goal:** Remove the sorry at ChronicleToCountermodel.lean:1064.

**Tasks:**
- [ ] Prove **permanent-closure lemma**: For x ∈ limit_dom with next_top ∈ limit_f(x), let y = succ(x) from `limit_dom_has_succ`. Then `∀ w ∈ limit_dom, x < w → w < y → False`. Proof: from `limit_satisfies_c5_strong` with ξ=⊥, η=⊤, the guard `⊥ ∈ limit_g(x,y)` means `∀ w ∈ limit_dom, x < w → w < y → ⊥ ∈ limit_f(w)`. Since ⊥ ∉ limit_f(w) (MCS), no such w exists.
- [ ] Prove **interval stabilization**: For a, b ∈ LimitDomSubtype with a ≤ b, ∃ N such that limit_dom ∩ [a.val, b.val] ⊆ ↑(dom(N) ∩ [a.val, b.val]). Strategy: each point in limit_dom enters at some finite stage. Each adjacent pair in the limit is permanently closed. The finite set dom(N₀) ∩ [a.val, b.val] (where N₀ is the max entry stage of a and b) eventually receives all C5 witnesses for its points, after which no new points enter [a.val, b.val].
- [ ] Prove `limitDomSubtype_Icc_finite`: since limit_dom ∩ [a.val, b.val] ⊆ dom(N) and dom(N) is Finset, use `Set.Finite.subset`.
- [ ] Verify `lake build ChronicleToCountermodel` with no sorry at line 1064.

**Timing:** 3-4 hours

**Depends on:** 3

### Phase 5: Verify and Clean Up [NOT STARTED]

**Goal:** Full build verification and cleanup.

**Tasks:**
- [ ] Run full `lake build` and verify no new errors.
- [ ] Verify `limitDomSubtype_isSuccArchimedean` (line 1074) compiles without sorry.
- [ ] Verify `discrete_iso`, `discrete_fmcs`, and downstream definitions compile.
- [ ] Confirm `dd_countermodel_chronicle_nondense_sorry` (line 836) retains its single sorry (unaffected).
- [ ] Review modified code for unnecessary `noncomputable` or complex proof terms; simplify.
- [ ] Add brief docstrings to new lemmas.

**Timing:** 1-2 hours

**Depends on:** 4

## Testing & Validation

- [ ] `lake build CounterexampleElimination` passes after Phases 1-2
- [ ] `lake build ChronicleConstruction` passes after Phase 3
- [ ] `lake build ChronicleToCountermodel` passes after Phase 4 with no sorry at line 1064
- [ ] Full `lake build` passes after Phase 5
- [ ] `lean_verify` on `limitDomSubtype_Icc_finite`, `limitDomSubtype_isSuccArchimedean`, `discrete_iso` confirms no sorry dependencies
- [ ] Grep for sorry in the 4 key files: only `dd_countermodel_chronicle_nondense_sorry` remains

## Artifacts & Outputs

- **Plan**: specs/123_fix_c5_witness_bot_and_prove_icc_finite/plans/01_fix-c5-bot-witness.md (this file)
- **Modified files**:
  - `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean` (Phases 1-2)
  - `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleConstruction.lean` (Phase 3)
  - `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` (Phase 4)
  - Possibly `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/RRelation.lean` (Phase 2 helper)
- **Summary**: specs/123_fix_c5_witness_bot_and_prove_icc_finite/summaries/01_fix-c5-bot-summary.md

## Rollback/Contingency

All changes are additive (new disjuncts, new branches, new lemmas). Reverting to current state: remove added disjuncts and restore original `c5_forward_witness` type.

If `untl_bot_event_in_r3m` proves too difficult: in the ξ=⊥ n≥1 case, still use `lemma_2_4_with_guard` to insert ONE point beyond max(dom) (the n=0 approach). This inserts one point per counterexample but does NOT create infinite chains.

If interval stabilization is too complex: use convergence-in-ℝ argument (embed in ℝ, show accumulation point, derive contradiction from discreteness). ~50 lines of Mathlib real analysis.
