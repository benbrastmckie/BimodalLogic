# Implementation Plan: Task #155 (v56)

- **Task**: 155 - Fix no_gaps_discrete import cycle for sorry-free discrete completeness
- **Status**: [NOT STARTED]
- **Effort**: 6-10 hours
- **Dependencies**: None
- **Research Inputs**: specs/155_reynolds_pipeline_activation/reports/55_team-research.md
- **Artifacts**: plans/55_implementation-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Close the sorry at `no_gaps_discrete` (GoodStructures.lean:855) by resolving the import cycle that prevents delegation to the sorry-free `no_gaps_discrete_model_surgery` (GoodStructuresModelSurgery.lean:2133), then rewire `completeness_discrete` to use the WeakCanonical cascade path (one_class -> very_good -> good -> Z-iso -> IsSuccArchimedean) instead of the dead `succ_cofinal` path. Definition of done: `#print axioms completeness_discrete` shows no `sorryAx`, `lake build` passes.

### Research Integration

Team research round 8 (4 teammates, all high confidence) identified the fundamental insight: the entire model surgery proof in GoodStructuresModelSurgery.lean is **already sorry-free** (zero sorry statements). The only sorry blocking discrete completeness is the import-cycle-induced sorry at GoodStructures.lean:855. Furthermore, ShiftAndGlue.lean already demonstrates the working pattern: `chronicle_is_good_direct` (line 950) bypasses the import cycle by inlining the `one_class` proof using `no_gaps_discrete_model_surgery` directly. The cascade `no_gaps_discrete -> one_class -> very_good -> good -> Z-iso -> IsSuccArchimedean` flows through existing sorry-free infrastructure.

Key verified facts:
- `GoodStructuresModelSurgery.lean`: 0 sorry statements (full model surgery complete)
- `ShiftAndGlue.lean`: 0 sorry statements (cascade wired and working)
- `GoodStructures.lean`: 1 sorry at line 855 (import cycle prevents delegation)
- `ChronicleToCountermodel.lean`: 6 sorry statements (all in dead BX pipeline, not used by `completeness_discrete`)
- `countermodel_discrete_reynolds` (Transfer.lean:1203): internally sorry-free but depends on `cantor_bfmcs_discrete_restricted_tc/fuc` which use `succ_embed_surjective` which has sorry via `succ_cofinal`

### Prior Plan Reference

Plan v55 attempted a "frozen guard" approach to prove `chronicle_gap_contradiction` directly. This was the 56th attempt at the same family of approaches (v50-v55). Research round 8 established that (a) the literature never proves the chronicle is Z-isomorphic, (b) all 55 prior plans attack the wrong target, and (c) the model surgery is already complete in GoodStructuresModelSurgery.lean. The v56 plan follows the research recommendation: resolve the import cycle and rewire the cascade.

**Effort calibration from prior plans**: Plans v50-v55 estimated 20-40 hours for deep proof construction. The v56 plan is fundamentally different -- it is an architectural refactoring task (move definitions, resolve imports, rewire callers) rather than a mathematical proof construction. The sorry-free proofs already exist.

### Roadmap Alignment

- Closing `no_gaps_discrete` and rewiring `completeness_discrete` achieves the primary goal: sorry-free discrete completeness
- Advances the critical path: Task 155 -> sorry-free `completeness_discrete`
- Makes task 202 (Reynolds k-equivalence bypass) unnecessary for discrete completeness

## Goals & Non-Goals

**Goals**:
- Close the sorry at `no_gaps_discrete` (GoodStructures.lean:855) by resolving the import cycle
- Rewire `completeness_discrete` to avoid the dead `succ_cofinal` path
- `#print axioms completeness_discrete` shows no `sorryAx`
- `lake build` passes

**Non-Goals**:
- Proving `succ_cofinal` or `chronicle_gap_contradiction` (dead BX pipeline, no longer needed)
- Writing new mathematical proofs (the sorry-free proofs already exist)
- Modifying the parametric canonical model or truth lemma
- Resolving the 6 sorry statements in ChronicleToCountermodel.lean (dead code)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Import cycle harder to resolve than expected | M | L | ShiftAndGlue.lean already demonstrates the solution pattern (inline one_class proof using no_gaps_discrete_model_surgery directly). Worst case: extract `no_gaps_discrete` into a new file that imports GoodStructuresModelSurgery. |
| Type mismatch between `no_gaps_discrete` and `no_gaps_discrete_model_surgery` | M | L | Verified: types are definitionally equal (`semantic_prior_UZ` is an abbrev that unfolds to the same inline type). |
| Cascade path has hidden sorry dependency | H | L | Verified: ShiftAndGlue.lean and GoodStructuresModelSurgery.lean have zero sorry statements. The cascade is fully sorry-free. |
| `completeness_discrete` rewiring introduces new sorry | H | M | The rewiring follows the existing `chronicle_is_good_direct` pattern. Verify with `#print axioms` at each step. |
| `countermodel_discrete_reynolds` needs `succ_embed_surjective` which needs `IsSuccArchimedean` via `succ_cofinal` | H | M | The cascade gives `IsSuccArchimedean` via a different path (one_class -> very_good -> good -> Z-iso). Need to wire this into `limitDomSubtype_isSuccArchimedean` or bypass `succ_embed_surjective` entirely by rewiring `countermodel_discrete_reynolds` to use the WeakCanonical cascade path directly. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |

Phases within the same wave can execute in parallel.

### Phase 1: Resolve import cycle and close no_gaps_discrete [NOT STARTED]

**Goal**: Close the sorry at GoodStructures.lean:855 by making `no_gaps_discrete` delegate to `no_gaps_discrete_model_surgery`.

**Tasks**:
- [ ] Analyze the import cycle: GoodStructuresModelSurgery.lean imports GoodStructures.lean, so GoodStructures.lean cannot import GoodStructuresModelSurgery.lean
- [ ] Strategy A (preferred): Extract `no_gaps_discrete` from GoodStructures.lean into a new file (e.g., `NoGapsDiscrete.lean`) that imports both GoodStructures.lean and GoodStructuresModelSurgery.lean. The new file contains the real theorem that delegates to `no_gaps_discrete_model_surgery`. Replace the sorry in GoodStructures.lean with `sorry` behind a clear docstring noting the real proof is in the new file, OR remove `no_gaps_discrete` from GoodStructures.lean entirely and have callers import the new file.
- [ ] Strategy B (alternative): Replace the sorry at GoodStructures.lean:855 by inlining the proof from `no_gaps_discrete_model_surgery`, exactly as ShiftAndGlue.lean:960-967 does for `chronicle_is_good_direct`. Since the types match definitionally, the proof body can be copied.
- [ ] Strategy C (if A/B fail): Move `no_gaps_discrete` and `one_class` out of GoodStructures.lean into a downstream file that already imports GoodStructuresModelSurgery.lean (e.g., ShiftAndGlue.lean or a new file). Update all callers.
- [ ] Verify `no_gaps_discrete` (or its replacement) compiles without sorry
- [ ] Verify `one_class` still compiles (it calls `no_gaps_discrete`)
- [ ] `lake build` passes after the change

**Timing**: 2 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/GoodStructures.lean` - close sorry at :855 or remove `no_gaps_discrete`
- Possibly new file `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/NoGapsDiscrete.lean` (Strategy A)
- `lakefile.lean` or `Theories/Bimodal.lean` - register new file if created

**Verification**:
- `#print axioms` on `no_gaps_discrete` (or replacement) shows no `sorryAx`
- `#print axioms one_class` shows no `sorryAx`
- `lake build` passes

---

### Phase 2: Wire cascade to provide IsSuccArchimedean on LimitDomSubtype [NOT STARTED]

**Goal**: Provide `IsSuccArchimedean` on `LimitDomSubtype` via the cascade path (one_class -> very_good -> good -> Z-iso -> IsSuccArchimedean), replacing the dead `succ_cofinal` path.

**Tasks**:
- [ ] Trace the cascade: `chronicle_is_good_direct` (ShiftAndGlue.lean:950) proves the chronicle monadic structure is `good`. The `good` property means there exists a Z-interval structure with a k-equivalence. This gives `IsSuccArchimedean` on a Z-interval, which can be transferred to `LimitDomSubtype` via the k-equivalence or the order isomorphism.
- [ ] Determine the wiring approach: Either (a) replace `limitDomSubtype_isSuccArchimedean` with a proof that goes through the cascade, or (b) bypass `succ_embed_surjective` entirely by constructing a new version of `countermodel_discrete_reynolds` that uses `chronicle_is_good_direct` to get the countermodel directly.
- [ ] Approach (a): Prove `limitDomSubtype_isSuccArchimedean` from `chronicle_is_good_direct`. The cascade gives `good sig k M_struct`, meaning M_struct is k-equivalent to a Z-interval. A Z-interval is `IsSuccArchimedean`. If the chronicle has the same "succ-reachability" as the Z-interval (via the k-equivalence preserving the successor structure), then `LimitDomSubtype` is `IsSuccArchimedean`.
- [ ] Approach (b): If the transfer of `IsSuccArchimedean` is not directly possible (k-equivalence preserves FO theory, not the successor function), rewire `countermodel_discrete_reynolds` to use `chronicle_is_good_direct` + the Z-interval model directly. The Z-interval model IS on Z, so no `succ_embed_surjective` needed -- the domain is already Z.
- [ ] Implement the chosen approach
- [ ] Verify `succ_embed_surjective` compiles without sorry (if approach a) OR verify the new countermodel construction compiles without sorry (if approach b)

**Timing**: 3-4 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` - rewire `limitDomSubtype_isSuccArchimedean` or bypass it
- `Theories/Bimodal/Metalogic/WeakCanonical/Transfer.lean` - possibly rewire `countermodel_discrete_reynolds` to use WeakCanonical path
- Possibly `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/ShiftAndGlue.lean` - extend `chronicle_is_good_direct` if needed

**Verification**:
- `#print axioms succ_embed_surjective` shows no `sorryAx` (approach a), OR
- `#print axioms countermodel_discrete_reynolds` shows no `sorryAx` (approach b)
- `lake build` passes

---

### Phase 3: Verify completeness_discrete is sorry-free [NOT STARTED]

**Goal**: Confirm the full chain from `completeness_discrete` down to the sorry-free model surgery is complete.

**Tasks**:
- [ ] `#print axioms completeness_discrete` shows no `sorryAx`
- [ ] `#print axioms countermodel_discrete_reynolds` shows no `sorryAx`
- [ ] `#print axioms cantor_bfmcs_discrete_restricted_tc` shows no `sorryAx`
- [ ] `#print axioms cantor_bfmcs_discrete_restricted_fuc` shows no `sorryAx`
- [ ] `lake build` passes with zero errors
- [ ] Run `grep -rn "^\s*sorry" Theories/` and verify no new sorry statements were introduced
- [ ] If any sorry remains in the chain, trace and fix it

**Timing**: 1 hour

**Depends on**: 2

**Files to modify**:
- None (verification only), unless sorry traces are found

**Verification**:
- `#print axioms completeness_discrete` -- NO `sorryAx`
- `lake build` -- zero errors
- No new sorry statements

---

### Phase 4: Documentation cleanup and summary [NOT STARTED]

**Goal**: Update docstrings and comments that reference the old sorry chain, write execution summary.

**Tasks**:
- [ ] Update docstrings in GoodStructures.lean (lines 810-855) to note sorry is resolved
- [ ] Update docstrings in ChronicleToCountermodel.lean (lines 57-91) to note the dead code status of `succ_cofinal` etc., and that `completeness_discrete` no longer depends on them
- [ ] Update the audit section in Completeness.lean (lines 378-415) to reflect sorry-free status
- [ ] Update ROADMAP.md critical path section to reflect completion
- [ ] Update plan file phase markers to [COMPLETED]
- [ ] Write execution summary at `specs/155_reynolds_pipeline_activation/summaries/55_execution-summary.md`

**Timing**: 1 hour

**Depends on**: 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/GoodStructures.lean` - update docstrings
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` - update docstrings
- `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` - update audit comments
- `specs/ROADMAP.md` - update critical path and current state

**Verification**:
- `lake build` still passes
- All docstrings accurately reflect the current sorry status

## Testing & Validation

- [ ] `#print axioms no_gaps_discrete` (or replacement) shows no `sorryAx`
- [ ] `#print axioms one_class` shows no `sorryAx`
- [ ] `#print axioms countermodel_discrete_reynolds` shows no `sorryAx`
- [ ] `#print axioms completeness_discrete` shows no `sorryAx`
- [ ] `lake build` passes with zero errors
- [ ] No new sorry statements introduced anywhere (`grep -rn "^\s*sorry" Theories/`)
- [ ] Dead code in ChronicleToCountermodel.lean (`succ_cofinal`, `chronicle_gap_contradiction`) not accidentally activated

## Artifacts & Outputs

- `specs/155_reynolds_pipeline_activation/plans/55_implementation-plan.md` (this file, v56)
- Modified `GoodStructures.lean` (closed sorry at :855)
- Possibly new `NoGapsDiscrete.lean` (if Strategy A chosen in Phase 1)
- Modified `ChronicleToCountermodel.lean` or `Transfer.lean` (rewired cascade)
- Execution summary at `specs/155_reynolds_pipeline_activation/summaries/55_execution-summary.md`

## Rollback/Contingency

If the import cycle resolution creates problems:
1. `git checkout -- Theories/` to revert all changes
2. Strategy B (inline proof) is the safest fallback since it requires no file reorganization
3. If the cascade wiring (Phase 2) proves harder than expected, the existing `chronicle_is_good_direct` in ShiftAndGlue.lean is a working template that demonstrates the pattern at the chronicle level

If `IsSuccArchimedean` transfer (Phase 2) hits a wall:
1. The k-equivalence may not directly transfer successor structure. In that case, approach (b) -- bypassing `succ_embed_surjective` entirely by using the Z-interval model from the cascade -- is more robust since the Z-interval is inherently on Z.
2. The existing `countermodel_discrete_reynolds` already constructs the BFMCS on Z. The question is whether it can be fed from `chronicle_is_good_direct` instead of from `succ_embed_surjective`.
3. Worst case: `succ_embed_surjective` might need an entirely new proof of `limitDomSubtype_isSuccArchimedean` that uses the cascade. This would add ~4 hours but is straightforward given that the cascade already proves goodness.
