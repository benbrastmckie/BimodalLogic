# Implementation Plan: Task #155 (v55)

- **Task**: 155 - Fix no_gaps_discrete import cycle for sorry-free discrete completeness
- **Status**: [NOT STARTED]
- **Effort**: 20-40 hours
- **Dependencies**: None
- **Research Inputs**: specs/155_reynolds_pipeline_activation/reports/50_import-cycle-research.md, handoffs from plans v50-v54
- **Artifacts**: plans/55_implementation-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Prove `chronicle_gap_contradiction` (ChronicleToCountermodel.lean:489) via a chronicle-specific "frozen guard" argument, making the entire chain through `completeness_discrete` sorry-free.

All previous plans (v50-v54) failed because they tried abstract approaches:
- v50-51: Abstract model surgery (one_class ≠ IsSuccArchimedean, Z+Z counterexample)
- v52: Reynolds k-equiv transfer (parametric model still carries sorry)
- v53: Existing Henkin chain (F-formulas lost, F→GF not a theorem)
- v54: Modified Henkin seed (G(¬F(phi)) ∧ F(phi) coexist, seed inconsistent)

The v55 approach works at the **construction level**: when the chronicle processes `U(⊤, ⊥)` (next_top) at a domain point, `⊥` enters the guard interval, preventing any future domain points from being inserted between consecutive points. This "freezes" the successor relation and enables a well-founded induction proving `succ_cofinal`.

### Research Integration

The frozen guard insight comes from the v54 implementation agent's analysis of the chronicle construction. Key infrastructure:
- `adj_g_mem_limit_f` (ChronicleConstruction.lean:1357): guard formulas transfer to limit_f for any point in the interval
- `limit_dom_has_succ` (ChronicleToCountermodelBasic.lean): every limit_dom point has a successor
- C5 elimination for `U(⊤, ⊥)` places `⊥` in guard between source and witness
- `succ_embed_no_gap` (ChronicleToCountermodel.lean): no domain points between consecutive embedded points (sorry-free)

### Prior Plan Reference

Replaces plans v50-v54. The `succ_reaches_dom_N` partial proof (lines 101-401) has two boundary sorries at lines 239 and 395 that this plan addresses.

### Roadmap Alignment

Closing `chronicle_gap_contradiction` unlocks the full sorry chain: `succ_cofinal` → `limitDomSubtype_isSuccArchimedean` → `succ_embed_surjective` → `restricted_tc/fuc` → `completeness_discrete` sorry-free.

## Goals & Non-Goals

**Goals**:
- Prove `chronicle_gap_contradiction` (ChronicleToCountermodel.lean:489)
- Make `#print axioms completeness_discrete` show no sorryAx
- `lake build` passes

**Non-Goals**:
- Modifying the parametric canonical model or truth lemma
- Proving IsSuccArchimedean abstractly (we prove it for the specific construction)
- Changing the pipeline architecture (the existing succ_embed → surjective → restricted_tc/fuc chain is correct once succ_cofinal is proved)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Frozen guard doesn't actually prevent all insertions | H | M | Verify C5 elimination places ⊥ in guard for ALL points, not just some |
| C4 elimination can insert points in frozen regions | H | L | C4 inserts between existing adjacent pairs; if guard has ⊥, the pair is not a valid C4 target |
| Boundary sorries in succ_reaches_dom_N are fundamentally hard | M | M | Frozen guard may provide the missing ingredient; if not, try direct induction on construction stages |
| Well-founded measure for induction is complex | M | M | Use (stage where b appears, Finset.card of dom(N) points between a and b) |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |

### Phase 1: Frozen guard lemma [NOT STARTED]

**Goal**: Prove that in the discrete case, when `U(⊤, ⊥)` is processed at a point, `⊥` enters the guard and prevents future domain insertions in that interval.

**Tasks**:
- [ ] Prove `next_top_guard_has_bot`: when C5 elimination processes `U(⊤, ⊥)` at point `a` creating witness `a'`, `Formula.bot ∈ g(a, a')` at the stage of creation
- [ ] Prove `frozen_guard_no_insertion`: for any adjacent pair `(a, b)` at stage N where `Formula.bot ∈ g_N(a, b)`, no point `w` with `a < w < b` can enter `limit_dom`. Uses `adj_g_mem_limit_f` + the fact that no MCS contains `⊥`
- [ ] Prove `discrete_succ_frozen`: in the discrete chronicle, for every point `x ∈ limit_dom`, there exists a stage N and adjacent pair `(x, x')` in dom(N) such that `Formula.bot ∈ g_N(x, x')`, meaning `x' = succ(x)` and the gap is permanently frozen

**Timing**: 8 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean`

**Verification**:
- Each lemma compiles without sorry
- `frozen_guard_no_insertion` correctly uses `adj_g_mem_limit_f`

---

### Phase 2: Close succ_reaches_dom_N boundary sorries [NOT STARTED]

**Goal**: Close the two sorry sites at lines 239 and 395 using the frozen guard infrastructure.

**Tasks**:
- [ ] Close above-max boundary sorry (line 239): when `b` is above `max(dom(N))`, use the frozen guard to show `succ(max_N_sub)` must equal `b` (no points can exist between max_N and b because the guard is frozen)
- [ ] Close below-min boundary sorry (line 395): when `a` is below `min(dom(N))`, use the frozen guard symmetrically (pred direction)
- [ ] Verify `succ_reaches_dom_N` compiles without sorry

**Timing**: 6 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` (lines ~239, ~395)

**Verification**:
- `succ_reaches_dom_N` has no sorry
- `#print axioms succ_reaches_dom_N` shows no sorryAx

---

### Phase 3: Prove chronicle_gap_contradiction and succ_cofinal [NOT STARTED]

**Goal**: Use `succ_reaches_dom_N` to prove `succ_cofinal`, which proves `limitDomSubtype_isSuccArchimedean`, which unlocks the full chain to sorry-free `completeness_discrete`.

**Tasks**:
- [ ] Prove `succ_cofinal` from `succ_reaches_dom_N`: given any `a, b` in `LimitDomSubtype`, both appear at some finite stage N, and `succ_reaches_dom_N` gives succ-reachability
- [ ] Prove `chronicle_gap_contradiction` from `succ_cofinal`: if succ-iterates from `a` are all < `b`, then `succ_cofinal` gives a contradiction
- [ ] Verify `limitDomSubtype_isSuccArchimedean` compiles without sorry (it delegates to `succ_cofinal`)
- [ ] Verify `succ_embed_surjective` compiles without sorry
- [ ] Verify `cantor_bfmcs_discrete_restricted_tc` and `_fuc` compile without sorry

**Timing**: 4 hours

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean`

**Verification**:
- `#print axioms chronicle_gap_contradiction` shows no sorryAx
- `#print axioms succ_embed_surjective` shows no sorryAx
- `#print axioms cantor_bfmcs_discrete_restricted_tc` shows no sorryAx
- `#print axioms cantor_bfmcs_discrete_restricted_fuc` shows no sorryAx

---

### Phase 4: Full verification and cleanup [NOT STARTED]

**Goal**: Verify the entire chain is sorry-free and update documentation.

**Tasks**:
- [ ] `#print axioms completeness_discrete` shows no sorryAx
- [ ] `lake build` passes with zero errors
- [ ] Update docstrings in ChronicleToCountermodel.lean (remove "DEAD APPROACH" comments, update sorry status)
- [ ] Update plan file phase markers to [COMPLETED]
- [ ] Write execution summary

**Timing**: 2 hours

**Depends on**: 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean`
- `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` (update audit comments)

**Verification**:
- `#print axioms completeness_discrete` — NO sorryAx
- `lake build` — zero errors

## Testing & Validation

- [ ] `#print axioms chronicle_gap_contradiction` shows no sorryAx
- [ ] `#print axioms succ_cofinal` shows no sorryAx
- [ ] `#print axioms completeness_discrete` shows no sorryAx
- [ ] `lake build` passes
- [ ] No new sorry statements introduced anywhere

## Artifacts & Outputs

- `specs/155_reynolds_pipeline_activation/plans/55_implementation-plan.md` (this file)
- Modified `ChronicleToCountermodel.lean` (frozen guard lemmas, closed boundary sorries)
- Execution summary at `specs/155_reynolds_pipeline_activation/summaries/55_execution-summary.md`

## Rollback/Contingency

If the frozen guard argument has gaps:
1. Check if C4 elimination can bypass the frozen guard (it shouldn't — C4 inserts between adjacent pairs, and frozen guards prevent this)
2. If the guard is not always frozen for `U(⊤, ⊥)`, check whether `U(⊤, ⊥)` is always processed for each point (scheduling ensures this)
3. Fall back to direct construction-level induction if the guard approach fails
4. `git checkout -- Theories/` to revert all changes
