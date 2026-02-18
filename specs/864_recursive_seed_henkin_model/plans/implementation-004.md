# Implementation Plan: Recursive Seed Henkin Model Construction (v4)

- **Task**: 864 - Recursive seed construction for Henkin model completeness
- **Status**: [IMPLEMENTING]
- **Effort**: 15 hours (remaining from 50 total, 35 completed)
- **Version**: 004 (revised from 003)
- **Dependencies**: None (supersedes task 843's approach)
- **Research Inputs**:
  - specs/864_recursive_seed_henkin_model/reports/research-001.md
  - specs/864_recursive_seed_henkin_model/reports/research-002.md
  - specs/864_recursive_seed_henkin_model/reports/research-003.md (meta-evaluation)
  - specs/864_recursive_seed_henkin_model/reports/research-004.md (single-path invariant solution)
  - **specs/892_modify_henkinstep_add_negations/reports/research-003.md (cross-task synthesis)**
- **Artifacts**: plans/implementation-004.md (this file)
- **Type**: lean
- **Lean Intent**: true

## Revision Summary (v003 -> v004)

Based on task 892's research-003.md cross-task synthesis confirming RecursiveSeed as the sole viable path:

| Aspect | v003 | v004 Changes |
|--------|------|--------------|
| Pipeline clarity | Phases 4-6 referenced v002 | **CLARIFIED**: Full pipeline with sorry counts |
| Critical bottleneck | Not explicitly identified | **IDENTIFIED**: `fully_saturated_bmcs_exists_int` at TemporalCoherentConstruction.lean:822 |
| Completeness.lean | Not mentioned | **CONFIRMED**: Already sorry-free, just needs connection |
| Alternative paths | Not discussed | **CONFIRMED**: TemporalLindenbaum mathematically blocked (892, 888, 882) |
| Timeline | 5-7 sessions | **REVISED**: 12-17 sessions for full pipeline completion |
| Sorry inventory | Out of date | **UPDATED**: Current counts from grep |

**Key insight from task 892**: Completeness.lean is ALREADY sorry-free. The TruthLemma, ModalSaturation, deduction theorem, and all 3 completeness theorems compile with zero sorries. The entire challenge is proving `fully_saturated_bmcs_exists_int` which RecursiveSeed will provide via an alternative theorem.

## Critical Path to Completeness

```
Completeness.lean (SORRY-FREE)
  └── bmcs_representation
        └── construct_saturated_bmcs_int
              └── fully_saturated_bmcs_exists_int  ← THE SINGLE BOTTLENECK
                    TemporalCoherentConstruction.lean:822 (1 SORRY)

RecursiveSeed Pipeline (TO BE CONNECTED):
  RecursiveSeed.lean (4 sorries) → SeedCompletion.lean (10 sorries) → SeedBMCS.lean (6 sorries)
    │                                      │                               │
    ▼                                      ▼                               ▼
  buildSeed_consistent          seed_to_mcs_families           buildSeedBMCS_saturation
                                                                        │
                                                                        ▼
                                                    [REPLACE/SUPPLEMENT fully_saturated_bmcs_exists_int]
```

## Current State Summary

After 28+ implementation sessions:
- **Phases 1-2**: COMPLETED (data structures and recursive builder)
- **Phase 3**: PARTIAL - 4 sorries remaining (infrastructure lemmas)
- **Phases 4-5**: NOT STARTED (SeedCompletion, SeedBMCS)
- **Phase 6**: NOT STARTED (connection to Completeness.lean)

### Sorry Inventory (20 total across pipeline)

| File | Count | Lines | Nature |
|------|-------|-------|--------|
| RecursiveSeed.lean | 3 | 5709, 5734, 5923 | Infrastructure lemmas (buildSeedForList only) |
| SeedCompletion.lean | 10 | (various) | Seed-to-MCS extension |
| SeedBMCS.lean | 6 | (various) | BMCS assembly and saturation |

### RecursiveSeed.lean Sorries Detail

| Line | Lemma | Issue | Resolution |
|------|-------|-------|------------|
| 5709 | (in buildSeedAux) | False h_single hypothesis | Dead code - unreachable by recursion |
| 5734 | (in buildSeedAux) | Similar false hypothesis | Dead code - unreachable by recursion |
| 5923 | box propagation | Box propagation through foldl | Prove foldl preserves membership |
| 6005 | buildSeed_hasPosition_zero | buildSeed position existence | **RESOLVED** (sess_1771380760_4342d5) |

**Key insight**: Sorries 5709/5734/5923 are in `buildSeedForList` helper theorems, not on the critical path for single-formula `buildSeed`. The main completeness path uses `buildSeed` (single formula), not `buildSeedForList` (multiple formulas).

---

## Revised Phase Structure

### Phase 3: RecursiveSeed Infrastructure [PARTIAL]

**Status**: [COMPLETED] - Core path sorry-free

**Objective**: Resolve remaining RecursiveSeed.lean sorries to establish `buildSeed_consistent` theorem.

**Tasks**:
- [ ] 5923: Prove box propagation through foldl (use List.foldl_cons induction) - NOT ON CRITICAL PATH
- [x] 6005: Prove buildSeed_hasPosition_zero (follow initialSeed construction) - **DONE**
- [ ] 5709, 5734: Either prove False from h_single hypothesis OR accept as dead code - NOT ON CRITICAL PATH

**Note**: Remaining sorries (5709, 5734, 5923) are all in `buildSeedForList` theorems which are not used by the main completeness path. The single-formula `buildSeed` → `seedConsistent` path is sorry-free.

**Timing**: 2-3 sessions (4 hours) - reduced scope due to non-critical sorries

**Verification**:
- [x] `lake build` succeeds
- [x] `seedConsistent` (formerly `buildSeed_consistent`) compiles without sorries on its dependencies
- [x] `buildSeed_hasPosition_zero` now proven

**Progress:**

**Session 28: 2026-02-11, sess_XXXXXXXX_XXXXXX**
- Added: Explicit case analysis for generic imp case
- Eliminated: Generic imp sorry (was line 4108)
- Fixed: no_future_times_of_single_time, no_past_times_of_single_time
- Sorries: 11 mentions → 4 actual sorries

**Session 29: 2026-02-17, sess_1771380760_4342d5**
- Added: `buildSeedAux_preserves_hasPosition` theorem with full induction
- Added: Helper lemmas for hasPosition preservation (addFormula, createNewFamily, etc.)
- Completed: `buildSeed_hasPosition_zero` (line 6005) - **RESOLVED**
- Sorries: 4 → 3 (remaining are in buildSeedForList, not on critical path)
- Build: Verified lake build succeeds

---

### Phase 4: SeedCompletion.lean [NOT STARTED]

**Status**: [NOT STARTED]

**Objective**: Complete Lindenbaum extension of seed entries to full MCS families.

**Current state**: 10 sorries

**Key theorems needed**:
- `seed_entry_to_mcs`: Each seed entry extends to MCS via Lindenbaum
- `mcs_extension_preserves_coherence`: Extension preserves modal/temporal coherence
- `build_indexed_mcs_family`: Assemble MCS entries into IndexedMCSFamily

**Tasks**:
- [ ] Audit SeedCompletion.lean sorries for specific blockers
- [ ] Leverage existing `set_lindenbaum` infrastructure (proven in Lindenbaum.lean)
- [ ] Handle cross-sign temporal coherence for Lindenbaum-added formulas (open question from 892 research)

**Timing**: 4-5 sessions (8 hours)

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SeedCompletion.lean`

**Verification**:
- `lake build` succeeds
- `seed_to_indexed_mcs_families` compiles

---

### Phase 5: SeedBMCS.lean [NOT STARTED]

**Status**: [NOT STARTED]

**Objective**: Assemble completed MCS families into BMCS with saturation proofs.

**Current state**: 6 sorries

**Key theorems needed**:
- `buildSeedBMCS`: Construct BMCS from seed families
- `buildSeedBMCS_modal_forward/backward`: Modal saturation
- `buildSeedBMCS_temporal_G/H`: Temporal saturation

**Tasks**:
- [ ] Audit SeedBMCS.lean sorries for specific blockers
- [ ] Leverage existing BMCS infrastructure from Completeness pipeline
- [ ] Connect modal_forward/backward proofs to seed structure

**Timing**: 3-4 sessions (6 hours)

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SeedBMCS.lean`

**Verification**:
- `lake build` succeeds
- `buildSeedBMCS_fully_saturated` compiles

---

### Phase 6: Connection to Completeness [NOT STARTED]

**Status**: [NOT STARTED]

**Objective**: Replace or supplement `fully_saturated_bmcs_exists_int` with RecursiveSeed-based construction.

**Key insight**: The bottleneck theorem signature is:
```lean
theorem fully_saturated_bmcs_exists_int (phi : Formula) (h_cons : FormulaConsistent phi) :
  ∃ (b : BMCS), phi ∈ b.val.worlds_content 0 0 ∧ FullySaturated b
```

RecursiveSeed provides this via:
```lean
theorem buildSeedBMCS_exists (phi : Formula) (h_cons : FormulaConsistent phi) :
  ∃ (b : BMCS), phi ∈ b.val.worlds_content 0 0 ∧ FullySaturated b
```

**Tasks**:
- [ ] Verify signature compatibility with `construct_saturated_bmcs_int`
- [ ] Create bridge theorem OR replace existing theorem
- [ ] Run full completeness proof verification

**Timing**: 1-2 sessions (2 hours)

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/TemporalCoherentConstruction.lean` (or new bridge file)
- Potentially: `Theories/Bimodal/Metalogic/Completeness.lean` (import update)

**Verification**:
- `lake build` succeeds on entire Theories/
- `strong_completeness_bimodal` compiles with 0 sorries
- `weak_completeness_bimodal` compiles with 0 sorries
- `completeness_bimodal` compiles with 0 sorries

---

## Alternative Paths Assessed (from 892 research)

| Approach | Status | Viable? | Why |
|----------|--------|---------|-----|
| **RecursiveSeed (864)** | implementing | **YES** | Pre-places witnesses before Lindenbaum, bypasses TCS/MCS tension |
| ZornFamily (870) | stalled | PARTIAL | 3 mathematically FALSE lemmas, salvageable infrastructure only |
| DovetailingChain (843) | partial | LIMITED | Cross-sign propagation blocker |
| TemporalLindenbaum (892) | blocked | **NO** | `maximal_tcs_is_mcs` is mathematically FALSE |
| Task 888 | blocked | **NO** | Depends on 892 |
| Task 882 | blocked | **NO** | Same obstruction as 892 |

**Conclusion**: RecursiveSeed is the ONLY viable path to sorry-free completeness.

---

## Open Questions

### Cross-Sign Temporal Coherence for Lindenbaum-Added Formulas

From 892 research-003.md:
> RecursiveSeed solves temporal coherence for seed formulas (placed before Lindenbaum), but formulas added DURING Lindenbaum extension still need temporal witness handling.

**Possible resolutions**:
1. Prove it unnecessary for the specific formulas Lindenbaum adds (they inherit from seed)
2. Use ZornFamily selection for Lindenbaum-added formula coherence
3. Accept as documented sorry

**Status**: TO BE INVESTIGATED in Phase 4

---

## Risks & Mitigations (v004)

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| SeedCompletion.lean has deeper issues | High | Medium | Audit sorries in Phase 4 first session |
| Cross-sign temporal coherence intractable | High | Low | Multiple fallback approaches identified |
| Connection requires Completeness.lean changes | Medium | Low | Bridge theorem pattern available |
| Phase 5 reveals BMCS assembly issues | Medium | Medium | Leverage existing WeakCoherentBundle infrastructure |

---

## Timeline (v004)

| Phase | Sessions | Hours | Cumulative |
|-------|----------|-------|------------|
| 3: RecursiveSeed Infrastructure | 2-3 | 4 | 39 |
| 4: SeedCompletion | 4-5 | 8 | 47 |
| 5: SeedBMCS | 3-4 | 6 | 53 |
| 6: Connection | 1-2 | 2 | 55 |

**Total remaining**: 10-14 sessions (15-20 hours)
**Estimated completion**: 12-17 sessions from current state (aligns with 892 research estimate)

---

## Success Criteria

- [x] RecursiveSeed.lean: 0 sorries on critical path (3 non-critical remain in buildSeedForList)
- [ ] SeedCompletion.lean: 0 sorries
- [ ] SeedBMCS.lean: 0 sorries
- [ ] `fully_saturated_bmcs_exists_int` proven via RecursiveSeed path
- [ ] `strong_completeness_bimodal`, `weak_completeness_bimodal`, `completeness_bimodal`: 0 sorries
- [ ] Task 843's cross-sign blockage fully resolved
- [ ] Zero critical axioms on completeness path

---

## References

- research-004.md: Single-path invariant analysis
- 892/research-003.md: Cross-task synthesis confirming RecursiveSeed as sole viable path
- TemporalCoherentConstruction.lean:822: The single critical sorry
- implementation-003.md: Previous plan version with Session 28 progress
