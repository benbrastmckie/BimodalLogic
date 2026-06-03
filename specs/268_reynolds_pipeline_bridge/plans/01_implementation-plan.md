# Implementation Plan: Reynolds Pipeline Bridge

- **Task**: 268 - Reynolds pipeline bridge: archive divergent BX code and wire Theorem 14/15 to close IsSuccArchimedean
- **Status**: [NOT STARTED]
- **Effort**: 8 hours
- **Dependencies**: None
- **Research Inputs**: specs/268_reynolds_pipeline_bridge/reports/01_bridge-research.md
- **Artifacts**: plans/01_implementation-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Archive dead BX pipeline code to the Boneyard directory, then fix the sorry in `chronicle_gap_contradiction` (ChronicleToCountermodel.lean:486) by building a singleton monadic structure on `LimitDomSubtype` and applying the sorry-free `gap_contradicts_prior` from `GoodStructuresModelSurgery.lean`. Once `chronicle_gap_contradiction` is proved, the downstream sorry chain (`succ_cofinal` -> `limitDomSubtype_isSuccArchimedean` -> `succ_embed_surjective`) should close automatically, making `completeness_discrete` sorry-free.

### Research Integration

Key findings from research report `01_bridge-research.md`:

1. **Boneyard targets**: `ReynoldsModelSurgery.lean` (407 lines, entirely dead, no imports), dead private functions in `ChronicleToCountermodel.lean` (lines 55-806: `succ_reaches_dom_N`, partially `chronicle_gap_contradiction`, `succ_cofinal`, `limitDomSubtype_isSuccArchimedean`), and deprecated `countermodel_discrete` in `Transfer.lean` (line 1281).
2. **Bridge mechanism**: Replace sorry at `ChronicleToCountermodel.lean:486` using `gap_contradicts_prior` from `GoodStructuresModelSurgery.lean`. No new files needed. Import already exists.
3. **The commented-out proof** (lines 488-762) is nearly complete. The bug is k=0 where k>=1 is needed for `contemp_equiv` to distinguish different MCS values.
4. **h_surj**: Trivially satisfied for singleton signature (`preds := Unit`).
5. **Key risk**: The constant-MCS case where `limit_f(a.val) = limit_f(b.val)`. May need a chronicle-specific argument showing omega-chain stages produce non-constant MCS on bounded orbits.
6. **Type signatures**: `gap_contradicts_prior` requires `MonadicSignature`, `OrderedMonadicStructure`, `SuccOrder`, `PredOrder`, `NoMaxOrder`, `NoMinOrder`, `atomMap`, `h_surj`, `semantic_prior_UZ`, `semantic_prior_SZ`, plus `h_succ_closed` and `h_bounded`.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

This task advances the completeness milestone: eliminating the last sorry on the discrete completeness critical path. Task 155 depends on task 268 completing this bridge work.

## Goals & Non-Goals

**Goals**:
- Archive all dead BX pipeline code to `Theories/Bimodal/Boneyard/`
- Replace the sorry in `chronicle_gap_contradiction` with a proof using Reynolds model surgery tools
- Close the downstream sorry chain through `succ_embed_surjective`
- Achieve sorry-free `completeness_discrete` (or identify and document any remaining blocker)

**Non-Goals**:
- Rewriting the Chronicle module architecture (task 176 scope)
- Eliminating non-critical-path sorries
- Proving EF game theorems in StaviCompleteness (separate sorry chain, not on discrete critical path via this route)
- Archiving BXCanonical subtree (task 176 scope)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Constant-MCS case intractable: `limit_f(a.val) = limit_f(b.val)` for all pairs in bounded orbit | H | M | Use chronicle-specific argument that omega-chain stages produce non-constant MCS. Fallback: leave this case as a targeted sorry with a clear explanation and reduced scope. |
| `semantic_prior_UZ/SZ` proof harder than expected on `LimitDomSubtype` | M | L | The commented-out code (lines 488-762) already shows the full proof structure. Follow it, fixing the k=0 bug to k>=1. |
| Downstream sorry chain does not close after `chronicle_gap_contradiction` | H | L | Verify each step: `succ_cofinal` depends only on `chronicle_gap_contradiction`; `limitDomSubtype_isSuccArchimedean` depends only on `succ_cofinal`. If blocked, investigate intermediate dependencies. |
| Boneyard archive breaks imports | L | L | `ReynoldsModelSurgery.lean` has no downstream imports (verified in research). Run `lake build` after each archive step. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |

Phases within the same wave can execute in parallel (all sequential here due to dependencies).

---

### Phase 1: Archive Dead BX Pipeline Code [NOT STARTED]

**Goal**: Move dead BX pipeline code to `Theories/Bimodal/Boneyard/` to reduce confusion and sorry noise.

**Tasks**:
- [ ] Create `Theories/Bimodal/Boneyard/BXPipelineDeadCode/` directory
- [ ] Move `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/ReynoldsModelSurgery.lean` to `Theories/Bimodal/Boneyard/BXPipelineDeadCode/ReynoldsModelSurgery.lean`
- [ ] Remove `ReynoldsModelSurgery` from `lakefile.lean` if it is listed as a module root or target
- [ ] In `ChronicleToCountermodel.lean`: identify and comment-mark the dead private functions (`succ_reaches_dom_N` lines 55-470) with `-- ARCHIVED: BX pipeline dead code, see task 268` (do NOT move these yet since they are private and interleaved with active code; moving requires restructuring)
- [ ] In `Transfer.lean`: comment-mark or extract `countermodel_discrete` (lines 1281-1296) as deprecated BX dead code with header annotation
- [ ] Run `lake build` to verify no breakage

**Timing**: 1 hour

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/ReynoldsModelSurgery.lean` -- move to Boneyard
- `Theories/Bimodal/Boneyard/BXPipelineDeadCode/ReynoldsModelSurgery.lean` -- new location
- `lakefile.lean` -- remove ReynoldsModelSurgery if listed
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` -- annotate dead functions
- `Theories/Bimodal/Metalogic/WeakCanonical/Transfer.lean` -- annotate deprecated function

**Verification**:
- `lake build` passes with zero errors
- `grep -r "ReynoldsModelSurgery" Theories/` returns only the Boneyard path
- Dead code sections in `ChronicleToCountermodel.lean` and `Transfer.lean` are clearly marked

---

### Phase 2: Fix chronicle_gap_contradiction [NOT STARTED]

**Goal**: Replace the sorry at `ChronicleToCountermodel.lean:486` with a proof using `gap_contradicts_prior` from `GoodStructuresModelSurgery.lean`.

**Tasks**:
- [ ] Uncomment the proof body at lines 488-762 of `ChronicleToCountermodel.lean`
- [ ] Fix the k=0 bug: change the singleton monadic structure to use k>=1 (use k=1 with a signature that has one predicate tracking a distinguishing formula)
- [ ] Build the `OrderedMonadicStructure` on `LimitDomSubtype` with singleton signature (`preds := Unit`)
- [ ] Prove `h_surj` trivially: `intro (); exact ⟨⟨0⟩, rfl⟩`
- [ ] Prove `semantic_prior_UZ` using `limit_satisfies_c5_strong` and `limit_satisfies_c4` combined with the Prior-UZ axiom in MCS
- [ ] Prove `semantic_prior_SZ` symmetrically using the same approach
- [ ] Handle the different-MCS case: pick a distinguishing formula psi, show a and b are NOT `contemp_equiv` at k=1, apply `gap_contradicts_prior` to derive False
- [ ] Handle the constant-MCS case: prove that if `limit_f` is constant on a bounded orbit, the orbit must cover all of `LimitDomSubtype` (contradicting boundedness), OR use a chronicle-specific argument that omega-chain construction guarantees non-constant MCS values on any bounded segment
- [ ] If the constant-MCS case proves intractable after reasonable effort (>2 hours), leave a targeted sorry with clear documentation of what remains
- [ ] Run `lake build` to verify the file compiles

**Timing**: 4 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` -- replace sorry at line 486 with proof

**Verification**:
- `chronicle_gap_contradiction` compiles without sorry (or with a single well-documented sorry for the constant-MCS case only)
- `lake build` passes on the modified file
- `#check @chronicle_gap_contradiction` shows the expected type

---

### Phase 3: Wire the Sorry Chain [NOT STARTED]

**Goal**: With `chronicle_gap_contradiction` proved (or partially proved), verify that downstream definitions close: `succ_cofinal`, `limitDomSubtype_isSuccArchimedean`, `succ_embed_surjective`.

**Tasks**:
- [ ] Verify `succ_cofinal` (line 773) now compiles without sorry -- it depends directly on `chronicle_gap_contradiction`
- [ ] Verify `limitDomSubtype_isSuccArchimedean` (line 789) compiles without sorry -- it depends on `succ_cofinal`
- [ ] Verify `succ_embed_surjective` (line 1666) compiles without sorry -- it depends on `limitDomSubtype_isSuccArchimedean`
- [ ] Trace the path from `succ_embed_surjective` through `cantor_bfmcs_discrete_restricted_tc/fuc` to `dd_countermodel_chronicle_discrete` to confirm no other sorry blockers exist
- [ ] If any step does not automatically close, investigate and fix the intermediate dependency
- [ ] Run `lake build` on the full project

**Timing**: 1.5 hours

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` -- verify/fix downstream definitions if needed

**Verification**:
- `#print axioms succ_embed_surjective` shows no `sorryAx`
- `#print axioms dd_countermodel_chronicle_discrete` shows no `sorryAx` (or shows only sorries from other unrelated paths)
- `lake build` passes

---

### Phase 4: Full Build Verification and Sorry Audit [NOT STARTED]

**Goal**: Run `lake build` on the entire project and verify `completeness_discrete` is sorry-free.

**Tasks**:
- [ ] Run `lake build` and verify zero errors
- [ ] Run `#print axioms completeness_discrete` and check for `sorryAx`
- [ ] If `sorryAx` is present, trace which sorry it comes from using `#print axioms` on intermediate definitions along the critical path
- [ ] Run `grep -rn "sorry" Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` to count remaining sorries
- [ ] Run `grep -rn "sorry" Theories/Bimodal/Metalogic/WeakCanonical/Transfer.lean` to verify no new sorries
- [ ] Compare total sorry count before and after changes
- [ ] Clean up any deprecated comments or stale docstrings in modified files
- [ ] Document the final state: which sorries were eliminated, which remain (if any), and what the remaining path to sorry-free `completeness_discrete` is

**Timing**: 1.5 hours

**Depends on**: 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` -- cleanup
- `Theories/Bimodal/Metalogic/WeakCanonical/Transfer.lean` -- cleanup

**Verification**:
- `lake build` passes with zero errors
- `#print axioms completeness_discrete` shows no `sorryAx` (success) or shows exactly which sorries remain (partial success)
- `grep -r "sorry" Theories/` shows reduced sorry count versus baseline
- Documentation of final state is clear and accurate

## Testing & Validation

- [ ] `lake build` passes at each phase boundary (phases 1, 2, 3, 4)
- [ ] `#print axioms completeness_discrete` checked at phase 4
- [ ] `#print axioms succ_embed_surjective` checked at phase 3
- [ ] No new sorries introduced: `grep -r "sorry" Theories/` count does not increase
- [ ] `ReynoldsModelSurgery.lean` is no longer importable from active code paths
- [ ] All Boneyard moves are clean (no dangling references)

## Artifacts & Outputs

- `specs/268_reynolds_pipeline_bridge/plans/01_implementation-plan.md` (this file)
- `specs/268_reynolds_pipeline_bridge/summaries/01_implementation-summary.md` (upon completion)
- Modified files in `Theories/Bimodal/` (Boneyard archive + bridge proof)

## Rollback/Contingency

If the bridge proof proves intractable (constant-MCS case cannot be resolved):
1. Revert `ChronicleToCountermodel.lean` to its pre-modification state using `git checkout`
2. Keep the Boneyard archive (Phase 1) as it is independently valuable housekeeping
3. Document the blocker in the task summary for future research
4. Consider the alternative path: axiomatize `IsSuccArchimedean` for `LimitDomSubtype` as a temporary sorry-reduction measure (~30 lines, per research report Path D)
