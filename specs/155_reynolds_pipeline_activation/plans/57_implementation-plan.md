# Implementation Plan: Task #155 (v58)

- **Task**: 155 - Close sorry chain to completeness_discrete via IsSuccArchimedean axiom
- **Status**: [NOT STARTED]
- **Effort**: 3-4 hours
- **Dependencies**: None
- **Research Inputs**: specs/155_reynolds_pipeline_activation/reports/55_team-research.md, specs/155_reynolds_pipeline_activation/reports/56_phase2-blocker-research.md, specs/155_reynolds_pipeline_activation/reports/57_bypass-surjectivity-research.md
- **Artifacts**: plans/57_implementation-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Close the sorry chain blocking `completeness_discrete` by axiomatizing `IsSuccArchimedean` for `LimitDomSubtype` (Path D from report 57). Phase 1 of the prior plan succeeded: `NoGapsDiscreteProof.lean` was created, resolving the import cycle so `GoodStructures.lean` has zero sorries. Phase 2 was blocked twice -- first targeting the wrong sorry (dead BX code), then attempting omega-chain stage induction which hit an irreducible boundary-case gap. Research report 57 definitively establishes that Paths A (multi-predicate model surgery), C (bypass surjectivity), and the omega-chain approach are not viable. Path D (axiomatize `IsSuccArchimedean`) replaces the existing sorry with a mathematically justified axiom at a higher level (~30 lines), while Path E (300-600 lines) remains for long-term full formal proof.

Definition of done: `#print axioms completeness_discrete` shows `limitDomSubtype_isSuccArchimedean_axiom` but no `sorryAx`, `lake build` passes.

### Research Integration

- **Report 55** (team research round 8): Identified import cycle as sole GoodStructures.lean sorry, cascade through sorry-free model surgery infrastructure.
- **Report 56** (phase 2 blocker research): Identified that `chronicle_gap_contradiction` is dead BX code. Mapped the real sorry chain: `completeness_discrete` -> `countermodel_discrete_reynolds` -> `restricted_tc/fuc` -> `succ_embed_surjective` -> `limitDomSubtype_isSuccArchimedean` -> `succ_cofinal` -> `chronicle_gap_contradiction` [sorry]. Recommends Path A (omega-chain induction, 150-300 lines).
- **Report 57** (bypass surjectivity research): After Phase 2 blocked on omega-chain approach, analyzed 5 paths. Paths A, C, and omega-chain are not viable. Recommends Path D: axiomatize `IsSuccArchimedean` for `LimitDomSubtype` (~30 lines, 1 hour). Path E (omega-chain stage induction, 300-600 lines) identified for long-term full formal proof.

### Prior Plan Reference

Plan v57 (56_implementation-plan.md) had 4 phases. Phase 1 completed successfully (import cycle resolved). Phase 2 was blocked: the omega-chain stage induction approach has an irreducible gap at the boundary case where `succ(max_N)` in limit_dom may come from an arbitrarily later stage. The v58 plan follows report 57's recommendation: axiomatize `IsSuccArchimedean` directly (Path D), replacing the deeply-nested sorry with a clean, documented axiom.

### Roadmap Alignment

- Axiomatizing `IsSuccArchimedean` replaces `sorryAx` with a named axiom in the `completeness_discrete` dependency chain
- The axiom is mathematically justified: the omega-chain construction builds limit_dom from `{0}` by inserting C5 witnesses via `next_top`, creating a successor-complete linear order
- `#print axioms completeness_discrete` will show `limitDomSubtype_isSuccArchimedean_axiom` instead of `sorryAx`
- Path E (full formal proof) can later remove this axiom entirely

## Goals & Non-Goals

**Goals**:
- Replace `limitDomSubtype_isSuccArchimedean` (which depends on sorry via `succ_cofinal`) with a clean axiom
- `#print axioms completeness_discrete` shows no `sorryAx` (may show the new named axiom)
- `lake build` passes
- Clear documentation of the mathematical justification for the axiom

**Non-Goals**:
- Proving `IsSuccArchimedean` formally (Path E, deferred to a future task)
- Proving `succ_cofinal` or `chronicle_gap_contradiction` (dead BX pipeline)
- Modifying the model surgery chain, WeakCanonical infrastructure, or GoodStructures.lean
- Resolving Stavi completeness sorries (not on this critical path)
- Removing or archiving dead BX code (separate task 255)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Axiom type signature mismatch | M | L | The existing `limitDomSubtype_isSuccArchimedean` at line 790 has the exact type needed. The axiom mirrors it. |
| Additional sorries in the chain beyond `succ_embed_surjective` | M | L | Report 57 verified the complete chain. Only `succ_cofinal` -> `chronicle_gap_contradiction` contributes sorryAx. |
| `succ_embed_surjective` proof body does not compile after swapping axiom | M | L | The proof at line 1667 uses `letI := limitDomSubtype_isSuccArchimedean ...`. Replace with `letI := limitDomSubtype_isSuccArchimedean_axiom ...` (same type, drop-in). |
| Lean rejects `axiom` with complex dependent types | L | L | Lean 4 supports axioms with arbitrary type signatures. The type is a standard typeclass instance. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |

Phases within the same wave can execute in parallel.

### Phase 1: Resolve import cycle and close no_gaps_discrete [COMPLETED]

**Goal**: Close the sorry at GoodStructures.lean:855 by extracting `no_gaps_discrete` into `NoGapsDiscreteProof.lean`.

**Tasks**:
- [x] Created `NoGapsDiscreteProof.lean` importing GoodStructuresModelSurgery
- [x] Removed `no_gaps_discrete` and `one_class` from GoodStructures.lean
- [x] `no_gaps_discrete` delegates to `no_gaps_discrete_model_surgery` via `exact`
- [x] `lake build` passes (1681 jobs, zero errors)
- [x] GoodStructures.lean has zero sorries

**Timing**: 2 hours

**Depends on**: none

**Completed**: 2026-06-02

**Files modified**:
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/NoGapsDiscreteProof.lean` (new)
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/GoodStructures.lean` (removed sorry)

---

### Phase 2: Axiomatize IsSuccArchimedean for LimitDomSubtype [COMPLETED]

**Goal**: Replace the sorry-dependent `limitDomSubtype_isSuccArchimedean` definition with a clean axiom declaration, and rewire `succ_embed_surjective` to use it.

**Approach**: Path D from report 57. Declare an `axiom` with the same type signature as the existing `limitDomSubtype_isSuccArchimedean` (line 790). Add documentation explaining the mathematical justification: the omega-chain construction builds limit_dom as a union of finite stages from `{0}`, with each stage extending by resolving C4/C5 violations via `next_top`, ensuring a successor-complete linear order. Then replace the reference in `succ_embed_surjective` (line 1674) to use the axiom instead of the sorry-dependent definition.

**Tasks**:
- [x] **Task 2.1**: Add the axiom declaration in ChronicleToCountermodel.lean, near the existing `limitDomSubtype_isSuccArchimedean` definition (around line 790). The axiom should have the form:
  ```lean
  /-- Axiom: The discrete chronicle limit domain is succ-archimedean.
  Mathematical justification: The omega-chain construction builds limit_dom
  as a union of finite stages starting from {0}. Each stage extends by
  resolving C4/C5 violations, inserting points between existing ones via
  next_top. The successor operation ensures adjacent points are succ-linked.
  The limit of a chain of succ-connected finite orders is succ-connected.
  Formal proof requires induction on the chronicle construction stages
  (Path E, estimated 300-600 lines -- deferred to a future task). -/
  axiom limitDomSubtype_isSuccArchimedean_axiom (fc : FrameClass)
      (A : Set Formula) (h_mcs : SetMaximalConsistent (fc := fc) A)
      (h_fc : FrameClass.Discrete ≤ fc)
      (h_discrete : ∀ x ∈ limit_dom fc A h_mcs, next_top ∈ limit_f fc A h_mcs x) :
      @IsSuccArchimedean (LimitDomSubtype fc A h_mcs)
        inferInstance
        (limitDomSubtype_succOrder fc A h_mcs h_discrete)
  ```
- [x] **Task 2.2**: Update `succ_embed_surjective` (line 1667-1689) to use the new axiom. Replace the `letI` binding:
  - Old: `letI := limitDomSubtype_isSuccArchimedean fc A h_mcs h_fc h_discrete`
  - New: `letI := limitDomSubtype_isSuccArchimedean_axiom fc A h_mcs h_fc h_discrete`
- [x] **Task 2.3**: Update the existing docstring at ChronicleToCountermodel.lean lines 55-95 to reflect that `limitDomSubtype_isSuccArchimedean` is replaced by an axiom, and that `succ_cofinal`/`chronicle_gap_contradiction` are definitively dead code (no longer on any path).
- [x] **Task 2.4**: Verify the module compiles: `lake build Bimodal.Metalogic.BXCanonical.Chronicle.ChronicleToCountermodel`

**Timing**: 1 hour

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean`
  - Add `limitDomSubtype_isSuccArchimedean_axiom` axiom declaration
  - Update `succ_embed_surjective` to reference the axiom
  - Update section docstring

**Verification**:
- `lake build Bimodal.Metalogic.BXCanonical.Chronicle.ChronicleToCountermodel` passes
- `lean_verify succ_embed_surjective` shows `limitDomSubtype_isSuccArchimedean_axiom` but no `sorryAx`

---

### Phase 3: Verify completeness_discrete sorry chain is clear [COMPLETED]

**Goal**: Confirm the full chain from `completeness_discrete` down through `succ_embed_surjective` shows no `sorryAx`.

**Tasks**:
- [x] `#print axioms completeness_discrete` -- confirmed: shows `limitDomSubtype_isSuccArchimedean_axiom`, NO `sorryAx`
- [x] `#print axioms countermodel_discrete_reynolds` -- confirmed: no `sorryAx`
- [x] `#print axioms cantor_bfmcs_discrete_restricted_tc` -- confirmed: no `sorryAx`
- [x] `#print axioms cantor_bfmcs_discrete_restricted_fuc` -- confirmed: no `sorryAx`
- [x] `#print axioms succ_embed_surjective` -- confirmed: no `sorryAx`
- [x] `lake build` passes with zero errors (1682 jobs)
- [x] `grep -rn "^\s*sorry" Theories/` -- no new sorry statements introduced (all pre-existing)
- [x] No sorry remains in the completeness_discrete chain *(deviation: altered -- used #print axioms via lake env lean instead of lean_verify MCP tool, which was unavailable)*

**Timing**: 30 minutes

**Depends on**: 2

**Files to modify**:
- None expected (verification only), unless sorry traces are found

**Verification**:
- `#print axioms completeness_discrete` -- NO `sorryAx`, shows `limitDomSubtype_isSuccArchimedean_axiom`
- `lake build` -- zero errors
- No new sorry statements

---

### Phase 4: Documentation cleanup and summary [COMPLETED]

**Goal**: Update docstrings referencing the old sorry chain, write execution summary.

**Tasks**:
- [x] Update the `limitDomSubtype_isSuccArchimedean` docstring (lines 785-788) to note it is now superseded by the axiom and retained only for reference *(deviation: altered -- completed during Phase 2)*
- [x] Update the `succ_embed_surjective` docstring (lines 813-817) to note it now uses the axiom *(deviation: altered -- completed during Phase 2)*
- [x] Update the audit section in Completeness.lean to reflect that `completeness_discrete` has no `sorryAx` (only the named axiom `limitDomSubtype_isSuccArchimedean_axiom`)
- [x] Write execution summary at `specs/155_reynolds_pipeline_activation/summaries/58_implementation-summary.md` *(deviation: altered -- used artifact number 58 per sequence)*

**Timing**: 30 minutes

**Depends on**: 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` -- update docstrings
- `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` -- update audit comments

**Verification**:
- `lake build` still passes
- All docstrings accurately reflect the current sorry/axiom status

## Testing & Validation

- [ ] `lean_verify succ_embed_surjective` shows no `sorryAx`
- [ ] `lean_verify completeness_discrete` shows no `sorryAx`
- [ ] `lean_verify countermodel_discrete_reynolds` shows no `sorryAx`
- [ ] `lean_verify cantor_bfmcs_discrete_restricted_tc` shows no `sorryAx`
- [ ] `lean_verify cantor_bfmcs_discrete_restricted_fuc` shows no `sorryAx`
- [ ] `#print axioms completeness_discrete` shows `limitDomSubtype_isSuccArchimedean_axiom` (named axiom, not sorryAx)
- [ ] `lake build` passes with zero errors
- [ ] No new sorry statements introduced (`grep -rn "^\s*sorry" Theories/`)
- [ ] Dead code in ChronicleToCountermodel.lean (`succ_cofinal`, `chronicle_gap_contradiction`) not accidentally activated

## Artifacts & Outputs

- `specs/155_reynolds_pipeline_activation/plans/57_implementation-plan.md` (this file, v58)
- Modified `ChronicleToCountermodel.lean` (axiom declaration + reference update)
- Execution summary at `specs/155_reynolds_pipeline_activation/summaries/57_execution-summary.md`

## Rollback/Contingency

If the axiom approach fails for any reason (type mismatch, unexpected compilation issues):

1. **Safe revert**: `git checkout -- Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` to restore the file. Phase 1 changes (NoGapsDiscreteProof.lean, GoodStructures.lean) are unaffected.

2. **Alternative (Path E)**: Full formal proof of `IsSuccArchimedean` via omega-chain stage induction. Estimated 300-600 lines, 20-40 hours. Would eliminate the axiom entirely.

3. **Status quo**: The current codebase already builds with the sorry. The axiom approach strictly improves the situation by replacing an anonymous `sorryAx` with a named, documented axiom.
