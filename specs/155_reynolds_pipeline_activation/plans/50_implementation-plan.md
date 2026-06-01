# Implementation Plan: Task #155 (Re-scoped)

- **Task**: 155 - Close no_gaps_discrete import cycle and rewire completeness_discrete
- **Status**: [NOT STARTED]
- **Effort**: 6 hours
- **Dependencies**: Task 199 (grid_order_tactic, PARTIAL -- non-blocking for this re-scoped work)
- **Research Inputs**: specs/155_reynolds_pipeline_activation/reports/50_import-cycle-research.md
- **Artifacts**: plans/50_implementation-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Rewrite `chronicle_gap_contradiction` in ChronicleToCountermodel.lean to use the sorry-free `no_gaps_discrete_model_surgery` from GoodStructuresModelSurgery.lean, replacing the broken `prior_model_is_succ_archimedean` call path that flows through the provably-false `no_gaps_faithful`. This makes `succ_cofinal`, `limitDomSubtype_isSuccArchimedean`, and ultimately `completeness_discrete` sorry-free through the existing BX pipeline without changing `completeness_discrete` code.

### Research Integration

Key findings from report 50 (import-cycle-research.md):
- `no_gaps_discrete_model_surgery` (GoodStructuresModelSurgery.lean:2133) is confirmed zero-sorry in its entire 2167-line file.
- Adding `import GoodStructuresModelSurgery` to ChronicleToCountermodel.lean creates NO circular dependency (verified: none of GoodStructuresModelSurgery's transitive imports include BXCanonical).
- The Prior-UZ/SZ types use `abbrev` definitions that expand identically -- direct delegation is possible without conversion.
- The `chronicle_semantic_prior_UZ/SZ` proofs in Transfer.lean (lines 1082-1161) demonstrate the pattern for translating MCS-level Prior-UZ/SZ to `semantic_prior_UZ/SZ` for an `OrderedMonadicStructure`.
- Strategy A (fix chronicle_gap_contradiction) makes completeness_discrete sorry-free WITHOUT any changes to completeness_discrete code. Strategy B (bridge file for no_gaps_discrete) is optional cleanup.

### Prior Plan Reference

Task 155 has had 44 prior plan versions (v35-v44) targeting the Reynolds pipeline through the full GHR93 EF game approach. Task 256 re-scoped the task to bypass that approach entirely, focusing instead on Strategy A from the research. Those prior plans targeted fundamentally different work and do not apply to this re-scoped plan.

### Roadmap Alignment

No ROADMAP.md found.

## Goals & Non-Goals

**Goals**:
- Rewrite `chronicle_gap_contradiction` to use `no_gaps_discrete_model_surgery` (sorry-free)
- Make `succ_cofinal` and `completeness_discrete` sorry-free via the existing BX pipeline
- Pass `lake build` with zero errors

**Non-Goals**:
- Closing the `no_gaps_discrete` sorry in GoodStructures.lean (Strategy B, secondary cleanup -- separate task)
- Modifying `completeness_discrete` code (it becomes sorry-free automatically when `chronicle_gap_contradiction` is fixed)
- Fixing the WeakCanonical path via `countermodel_discrete_reynolds` (permanently blocked)
- Archiving dead code (task 255)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Constructing `OrderedMonadicStructure` on `LimitDomSubtype` from raw chronicle data may require significant adapter code | M | M | Follow `chronicleAsMonadicStructure` pattern from NEquivalence.lean:1158; carrier = LimitDomSubtype, interp via limit_f membership |
| Proving `semantic_prior_UZ/SZ` for the raw LimitDomSubtype structure may require substantial effort | H | M | Follow `chronicle_semantic_prior_UZ/SZ` pattern from Transfer.lean:1082-1161; same proof structure applies since limit_f satisfies C4/C5 and Prior-UZ/SZ MCS membership |
| `no_gaps_discrete_model_surgery` requires `SuccOrder`/`PredOrder` instances on the carrier, which exist for LimitDomSubtype only when `h_discrete` is in scope | L | L | `limitDomSubtype_succOrder` and `limitDomSubtype_predOrder` are already defined and used by the current `chronicle_gap_contradiction` |
| Import addition may cause slow compilation or unexpected diamond issues | L | L | GoodStructuresModelSurgery has focused imports (PriorExpressiveness, GoodStructures, ReynoldsNoGaps, EFGames, NEquivalence) -- all lightweight |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |

Phases within the same wave can execute in parallel.

### Phase 1: Add Import and Construct OrderedMonadicStructure Adapter [NOT STARTED]

**Goal**: Add the GoodStructuresModelSurgery import to ChronicleToCountermodel.lean and rewrite `chronicle_gap_contradiction` to construct an `OrderedMonadicStructure` on `LimitDomSubtype`, prove `semantic_prior_UZ/SZ`, apply `no_gaps_discrete_model_surgery`, and derive `IsSuccArchimedean` contradiction.

**Tasks**:
- [ ] Add `import Bimodal.Metalogic.WeakCanonical.IntegerModel.GoodStructuresModelSurgery` to ChronicleToCountermodel.lean
- [ ] Verify the import compiles without cycle errors (`lake build Bimodal.Metalogic.BXCanonical.Chronicle.ChronicleToCountermodel`)
- [ ] Define a local `OrderedMonadicStructure` on `LimitDomSubtype` within `chronicle_gap_contradiction`, following the `chronicleAsMonadicStructure` pattern: carrier = LimitDomSubtype, interp via `limit_f` membership, carrier_order from the existing LimitDomSubtype LinearOrder
- [ ] Construct `mkSigFrom`/`mkAtomMapFwd`/`mkAtomMap` using an appropriate formula (likely a formula containing all atoms relevant to the chronicle)
- [ ] Prove `semantic_prior_UZ` for the constructed structure, following the `chronicle_semantic_prior_UZ` pattern from Transfer.lean:1082-1135. Key steps: convert temporal_truth to MCS membership, establish F(eff_psi) via C5/C4, apply MCS-level Prior-UZ, convert back
- [ ] Prove `semantic_prior_SZ` symmetrically, following Transfer.lean:1141-1161
- [ ] Apply `no_gaps_discrete_model_surgery` with the constructed structure to get one_class: for all a b, `contemp_equiv sig k M_struct a b`
- [ ] From one_class, derive `IsSuccArchimedean` for LimitDomSubtype (same technique as `chronicle_is_good_direct` lines 961-967 + succ iteration argument)
- [ ] Derive contradiction from `h_orbit_bounded` (all succ^n(a) < b) vs IsSuccArchimedean (some succ^n(a) = b)

**Timing**: 4 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` -- add import, rewrite `chronicle_gap_contradiction` (lines 1538-1588)

**Verification**:
- `lake build Bimodal.Metalogic.BXCanonical.Chronicle.ChronicleToCountermodel` passes
- `chronicle_gap_contradiction` has no sorry
- `succ_cofinal` (line 1599) has no sorry (it delegates to `chronicle_gap_contradiction`)

---

### Phase 2: Verify completeness_discrete is Sorry-Free [NOT STARTED]

**Goal**: Confirm the sorry-free status propagates through the full dependency chain from `chronicle_gap_contradiction` to `completeness_discrete`.

**Tasks**:
- [ ] Run `lake build Bimodal.Metalogic.BXCanonical.Completeness` to verify it compiles
- [ ] Add a temporary `#print axioms completeness_discrete` check in Completeness.lean and verify no `sorryAx` appears
- [ ] Trace the dependency chain to confirm no sorry remains: `chronicle_gap_contradiction` -> `succ_cofinal` -> `limitDomSubtype_isSuccArchimedean` -> `succ_embed_surjective` -> `cantor_bfmcs_discrete_restricted_tc/fuc` -> `countermodel_discrete_enriched` -> `completeness_discrete`
- [ ] Remove the temporary `#print axioms` line after verification

**Timing**: 30 minutes

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` -- temporary `#print axioms` (added then removed)

**Verification**:
- `#print axioms completeness_discrete` shows no `sorryAx`
- `lake build Bimodal.Metalogic.BXCanonical.Completeness` passes

---

### Phase 3: Full Build and Documentation Updates [NOT STARTED]

**Goal**: Run full `lake build`, update stale comments in source files, and update docstrings to reflect the new proof path.

**Tasks**:
- [ ] Run full `lake build` and verify zero errors
- [ ] Update the docstring on `chronicle_gap_contradiction` (line 1527-1537) to describe the new proof path via `no_gaps_discrete_model_surgery` instead of `prior_model_is_succ_archimedean`
- [ ] Update the docstring on `succ_cofinal` (line 1591-1598) to remove the sorry reference
- [ ] Update the docstring on `limitDomSubtype_isSuccArchimedean` (line 1607-1612) to remove the sorry reference and task 129 mention
- [ ] Add a note in `ReynoldsModelSurgery.lean` near `prior_model_is_succ_archimedean` (line 343) marking it as dead code bypassed by the `no_gaps_discrete_model_surgery` path
- [ ] Update the sorry-chain comment in `Completeness.lean` (lines ~295-308) to reflect the new sorry-free status of the discrete case

**Timing**: 1.5 hours

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` -- update docstrings
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/ReynoldsModelSurgery.lean` -- add dead-code note
- `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` -- update sorry-status comments

**Verification**:
- `lake build` passes (no functional changes in this phase, only comments)
- All modified docstrings accurately reflect the current proof state

## Testing & Validation

- [ ] `lake build Bimodal.Metalogic.BXCanonical.Chronicle.ChronicleToCountermodel` passes after Phase 1
- [ ] `#print axioms completeness_discrete` shows no `sorryAx` after Phase 2
- [ ] Full `lake build` passes with zero errors after Phase 3
- [ ] `chronicle_gap_contradiction` contains no `sorry` keyword
- [ ] `succ_cofinal` contains no `sorry` keyword
- [ ] `completeness_discrete` contains no `sorry` keyword (and no transitive sorry)

## Artifacts & Outputs

- plans/50_implementation-plan.md (this file)
- summaries/50_execution-summary.md (to be created at implementation completion)

## Rollback/Contingency

If the `semantic_prior_UZ/SZ` construction on LimitDomSubtype proves intractable in Phase 1:
1. Revert `chronicle_gap_contradiction` to its current state (PriorModelData approach with sorry)
2. Consider the alternative fallback from the research report: factor common proof structure into a shared helper that both `chronicle_gap_contradiction` and `chronicle_is_good_direct` can use, wrapping `LimitDomSubtype` into a `ChronicleAsPriorModel`-like structure minus the `IsSuccArchimedean` requirement
3. If that also fails, create a bridge theorem in ShiftAndGlue.lean (which already imports GoodStructuresModelSurgery) that wraps `no_gaps_discrete_model_surgery` for consumption by ChronicleToCountermodel.lean
