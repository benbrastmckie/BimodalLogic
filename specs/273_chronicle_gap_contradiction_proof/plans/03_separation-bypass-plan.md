# Implementation Plan: Separation-Based Bypass for US Expressive Completeness (v3)

- **Task**: 273 - Bypass GHR93 bridge lemma sorry via GHR94 integer-time separation
- **Status**: [NOT STARTED]
- **Effort**: 6 hours
- **Dependencies**: None (separation theorem and SemanticBridge are fully proved)
- **Research Inputs**: specs/273_chronicle_gap_contradiction_proof/reports/03_team-research.md, specs/273_chronicle_gap_contradiction_proof/reports/03_teammate-a-findings.md, specs/273_chronicle_gap_contradiction_proof/reports/03_teammate-b-findings.md
- **Artifacts**: plans/03_separation-bypass-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

This plan (v3) replaces the blocked Kamp translation approach (v2 Phases 2-6) with a direct semantic transfer strategy (Approach S from team research). The key discovery from team research: `separation_implies_expressiveness` in `ExpressiveCompleteness/Theorem.lean` already implements the full GHR94 Ch 9.3.1 quantifier elimination, producing a temporal formula A correct for all Z-carrier `IntStructureFromSig` structures, sorry-free. The only missing piece is a `prior_transfer` theorem lifting Z-structure correctness to arbitrary `OrderedMonadicStructure` satisfying Prior-UZ/SZ.

Phase 1 (SemanticBridge infrastructure) was completed in v2. This plan adds: Phase 0 (axiom audit), Phase 2 (Prior transfer lemma), Phase 3 (rewire PriorExpressiveness.lean), and Phase 4 (full build verification). The Chain B sorry (`chronicle_gap_contradiction`) is addressed via Lean's proof-term-based `#print axioms` semantics -- imports alone do not leak `sorryAx`.

### Research Integration

Integrated reports:
- `03_team-research.md` (PRIMARY): Identified Approach S as the cheapest path (~200-350 lines). Flagged the Prior-to-Z transfer as the critical gap. Confirmed two sorry chains (Stavi + Chronicle) reaching `completeness_discrete`.
- `03_teammate-a-findings.md`: Confirmed `separation_implies_expressiveness` is sorry-free and implements full GHR94 Ch 9.3.1. Identified the `atomMap` direction mismatch (`sig.preds -> Atom` vs `Formula -> sig.preds`) as a bridging detail.
- `03_teammate-b-findings.md`: Raised the valid concern that Prior structures are not necessarily Z-isomorphic. However, `US_expressively_complete_over_prior` consumers (`gap_prior_UZ_contradiction` in `GoodStructuresModelSurgery.lean`) use it on `limitdom_monadic_structure` which is a countable discrete linear order. The transfer can exploit the `Countable` + discrete structure.

Key findings incorporated:
1. `separation_implies_expressiveness` (GHR94 Theorem 9.3.1) is sorry-free in `ExpressiveCompleteness/Theorem.lean`.
2. `SemanticBridge.lean` provides `int_truth_eq_temporal_truth_Z` and `int_equiv_implies_temporal_equiv_with_iso` (both sorry-free).
3. The formula A produced by `expressiveness_inner` is box-free (separation never introduces box).
4. `US_expressively_complete_over_prior` is consumed ~7 times in `GoodStructuresModelSurgery.lean`; the replacement must preserve the exact type signature.
5. The actual sorry chain in `completeness_discrete` is: `countermodel_discrete_reynolds_v2` -> `limitdom_is_good` -> `no_gaps_discrete_model_surgery` -> `gap_prior_UZ_contradiction` -> `US_expressively_complete_over_prior` -> `stavi_expressive_completeness` -> sorry.

### Prior Plan Reference

Prior plan v2 (this file, overwritten) had 6 phases. Phase 1 (SemanticBridge) was completed. Phases 2-3 (Kamp translation) were blocked: the Kamp translation requires interval splitting for 4-variable existential transfer, which reduces to the same sorry being bypassed. v3 abandons the Kamp route entirely and uses the already-proved separation theorem.

Lessons from prior plan:
- SemanticBridge was correctly scoped and completed on schedule (~2 hours)
- The Kamp translation approach was fundamentally blocked by the same EF game composition issue
- Infrastructure from the blocked phases (`KampTranslation.lean` helpers) may be reusable but is not needed for Approach S

### Roadmap Alignment

ROADMAP.md item: "Reynolds k-equivalence bypass (task 202) is the critical path" -- this task advances the same goal by eliminating the `stavi_expressive_completeness` sorry from the `US_expressively_complete_over_prior` -> `gap_prior_UZ_contradiction` -> `no_gaps_discrete_model_surgery` chain.

## Goals & Non-Goals

**Goals**:
- Prove `US_expressively_complete_over_prior` without importing `StaviCompleteness.lean`, using the sorry-free `separation_implies_expressiveness` + a semantic transfer lemma
- Eliminate `sorryAx` from `completeness_discrete` through the Stavi chain (Chain A)
- Preserve the exact type signature of `US_expressively_complete_over_prior` so downstream consumers (`GoodStructuresModelSurgery.lean`) compile unchanged

**Non-Goals**:
- Fixing the sorry in `chronicle_gap_contradiction` (Chain B) -- this is a separate sorry in `ChronicleToCountermodel.lean` that does not affect `completeness_discrete` per `#print axioms` semantics (imports do not leak `sorryAx` into proof terms that do not reference them)
- Fixing the 3 sorry sites in `StaviCompleteness.lean` (lines 2353, 2435, 2805) -- those are bypassed, not fixed
- Proving `completeness_dense` sorry-free (separate concern, uses Chronicle pipeline)
- Modifying `GoodStructuresModelSurgery.lean` or any downstream consumers

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Prior structures may not be Z-isomorphic, preventing direct use of `int_equiv_implies_temporal_equiv_with_iso` | H | M | Two fallback approaches: (1) prove that the transfer works at the `int_truth`/`temporal_truth` level without requiring Z-isomorphism by building an `IntStructureFromSig` from any `OrderedMonadicStructure`, or (2) prove that all consumers actually use `US_expressively_complete_over_prior` on Z-isomorphic structures (limitdom is countable discrete). |
| `atomMap` direction mismatch: `separation_implies_expressiveness` uses `sig.preds -> Atom` while `US_expressively_complete_over_prior` uses `Formula -> sig.preds` | M | H | The `h_surj` hypothesis in `US_expressively_complete_over_prior` provides `forall p, exists a, atomMap (.atom a) = p`, enabling construction of the reverse map. Build a `sig.preds -> Atom` from `atomMap : Formula -> sig.preds` via `h_surj` + Classical.choice. |
| `separation_implies_expressiveness` produces existentially quantified A and atomMap, not a definitional construction | M | M | Use `US_expressively_complete_over_Z` which existentially provides A and atomMap, then apply the transfer lemma. The existential form is sufficient since `US_expressively_complete_over_prior` also returns a Subtype. |
| Chain B (`chronicle_gap_contradiction`) actually leaks `sorryAx` into `completeness_discrete` via proof-term references | H | L | Phase 0 axiom audit will confirm. If it leaks, Phase 3 can add import guards or move `mcs_mixed_case_absurd` to a separate module. |
| Total effort exceeds estimate due to unforeseen type-level obstacles in the transfer | M | M | Phase 1 (completed) and Phase 0 (cheap verification) reduce uncertainty. If Phase 2 hits a wall, fall back to Approach D-discrete (discrete-only bridge lemma, ~200-400 additional lines). |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 0 | -- |
| 2 | 2 | 0 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |

Phases within the same wave can execute in parallel.

---

### Phase 0: Axiom Audit and Sorry State Verification [COMPLETED]

**Goal**: Run `#print axioms completeness_discrete` and related checks to establish the ground truth about which sorry chains are live. This is a prerequisite identified by the research team (Finding 3: "No live #print axioms has been run").

**Tasks**:
- [ ] Add temporary `#print axioms` checks to verify the current sorry state:
  - `#print axioms Bimodal.Metalogic.WeakCanonical.US_expressively_complete_over_prior` (expected: includes `sorryAx`)
  - `#print axioms Bimodal.Metalogic.WeakCanonical.gap_prior_UZ_contradiction` (expected: includes `sorryAx` via US_expressively_complete_over_prior)
  - `#print axioms Bimodal.Metalogic.BXCanonical.completeness_discrete` (expected: includes `sorryAx`)
  - `#print axioms Bimodal.Metalogic.BXCanonical.Chronicle.mcs_mixed_case_absurd` (expected: no `sorryAx`)
- [ ] Use `lean_verify` or `lean_goal` to check the axiom output for each of these declarations
- [ ] Document which sorry chains are confirmed live vs stale
- [ ] Confirm that Chain A (Stavi -> US_expressively_complete_over_prior -> gap_prior_UZ_contradiction -> no_gaps_discrete_model_surgery -> limitdom_is_good -> countermodel_discrete_reynolds_v2 -> completeness_discrete) is the primary sorry source
- [ ] Determine whether Chain B (`chronicle_gap_contradiction` via `ChronicleToCountermodel` import) actually affects `completeness_discrete` via `#print axioms`

**Timing**: 0.5 hours

**Depends on**: none

**Files to modify**:
- None (read-only verification using MCP tools)

**Verification**:
- Axiom audit results documented in plan annotations or handoff
- Clear identification of which sorry chains must be addressed by subsequent phases

---

### Phase 1: SemanticBridge Infrastructure [COMPLETED]

**Goal**: Build the connection between `IntStructure`/`int_truth` (separation framework) and `OrderedMonadicStructure`/`temporal_truth` (completeness framework).

**Tasks**:
- [x] Created `Theories/Bimodal/Metalogic/WeakCanonical/Separation/SemanticBridge.lean`
- [x] Proved `z_structure_to_int`: IntStructure from ZStructure + atomMap
- [x] Proved `int_truth_eq_temporal_truth_Z`: int_truth matches temporal_truth on Z-carrier (box-free)
- [x] Proved `int_equiv_implies_temporal_equiv_Z`: int_equiv -> temporal_truth equivalence on Z-structures
- [x] Proved `temporal_truth_order_iso`: temporal_truth transfers through order isomorphisms (box-free)
- [x] Proved `int_equiv_implies_temporal_equiv_with_iso`: full bridge for structures with `M.carrier ≃o Z`

**Timing**: 2 hours (completed)

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/SemanticBridge.lean` -- completed

**Verification**:
- `lake build Bimodal.Metalogic.WeakCanonical.Separation.SemanticBridge` succeeds (confirmed)

---

### Phase 2: Prior Transfer Lemma [BLOCKED]

**Goal**: Prove that the formula A produced by `separation_implies_expressiveness` (correct for all Z-carrier `IntStructureFromSig` structures) is also correct for arbitrary `OrderedMonadicStructure sig` satisfying Prior-UZ/SZ. This is the core missing piece.

**BLOCKER** (Phase 2):
- **What failed**: The transfer from Z-structure correctness to arbitrary Prior structures is not achievable via the separation theorem alone. All three approaches (2a, 2b, 2c) were analyzed in depth and found to have the same fundamental gap.
- **What was tried**:
  1. **Approach 2a (direct IntStructureFromSig construction)**: Given M : OrderedMonadicStructure, construct M_Z : IntStructureFromSig matching M. FAILS because eval quantifies over M.carrier (arbitrary) vs Int (Z-carrier), and the quantifier domains differ when M is not Z-isomorphic.
  2. **Approach 2b (characteristic formula + reinterpretation)**: Show temporal_truth of A depends only on local data and order. PARTIALLY CORRECT: temporal_truth IS carrier-agnostic for box-free formulas, but eval quantifies over M.carrier. The atom elimination step (quantElimFormula) is proved only for IntStructureFromSig. Reproving for arbitrary carriers would duplicate ~1000 lines.
  3. **Approach 2c (fixed-t embedding via succ/pred)**: Embed Z-neighborhood of t into IntStructureFromSig using succ/pred chains. FAILS because if M is not IsSuccArchimedean, the chain does not cover M.carrier, and eval quantifiers see elements outside the chain.
  4. **IsSuccArchimedean derivation**: Attempted to show Prior-UZ + SuccOrder + NoMaxOrder + h_surj implies IsSuccArchimedean. INCONCLUSIVE: Prior-UZ prevents certain definable gaps but does not prevent non-archimedean gaps in general. The predicate signature is finite, so only finitely many "types" exist, but temporal formulas can still be consistent with non-archimedean carriers.
  5. **eval_order_iso approach**: Would work IF M.carrier ≃o Z, but this requires IsSuccArchimedean which cannot be derived from the hypotheses.
- **Why it's stuck**: Reynolds 1994 Theorem 5 (the mathematical result being formalized) explicitly uses GHR93 Theorem 9.3.1 ({U,S,U',S'} expressive completeness for ALL linear structures) as a prerequisite. The sorry in stavi_expressive_completeness IS the formalization of GHR93 9.3.1 for all structures. The separation theorem (GHR94 Ch 10.2, already formalized sorry-free) proves a DIFFERENT result: {U,S} completeness over Z only. These are mathematically distinct theorems. The gap between "completeness over Z" and "completeness over all Prior structures" is exactly what the GHR93 EF game proof provides, and there is no known shortcut that avoids it.
- **What is needed**: One of:
  (a) Fill the sorry sites at StaviCompleteness.lean:2353,2435 (4-variable existential transfer in EF games), which would make stavi_expressive_completeness sorry-free and resolve the entire chain.
  (b) Prove that the specific structures used by consumers of US_expressively_complete_over_prior are Z-isomorphic, and add iso : M.carrier ≃o Z to the type signature. This changes 7 call sites in GoodStructuresModelSurgery.lean.
  (c) Prove that Prior-UZ + SuccOrder + PredOrder + NoMaxOrder + NoMinOrder + h_surj implies IsSuccArchimedean, which would allow constructing the iso inside the proof.
- **Prohibited workarounds**: Do NOT use `sorry`, `def X := True`, or any vacuous placeholder.

**Tasks**:
- [x] Study the type signatures carefully: *(completed)* *(deviation: altered -- all three approaches analyzed, none viable)*
  - `separation_implies_expressiveness` returns: `exists A atomMap_fwd, forall (M : IntStructureFromSig sig) (t : Int), eval (int_to_ordered sig M) (fun _ => t) psi <-> Separation.int_truth (to_int_struct M atomMap_fwd) t A`
  - `US_expressively_complete_over_prior` needs: `{ A : Formula // forall (M : OrderedMonadicStructure sig) (h_UZ) (h_SZ) (t : M.carrier), eval M (fun _ => t) psi <-> temporal_truth M atomMap t A }`
  - Key difference: `atomMap_fwd : sig.preds -> Atom` (forward) vs `atomMap : Formula -> sig.preds` (backward)
- [ ] Build the atomMap bridge: given `atomMap : Formula -> sig.preds` with `h_surj : forall p, exists a, atomMap (.atom a) = p`, construct `atomMap_fwd : sig.preds -> Atom` via Classical.choice on `h_surj`. Prove round-trip properties. *(deviation: skipped -- blocked by core transfer theorem)*
- [ ] Prove the core transfer theorem. Two approaches to evaluate: *(deviation: blocked -- all approaches analyzed, none viable without EF games or Z-isomorphism)*
  - **Approach 2a (direct IntStructureFromSig construction)**: Given any `OrderedMonadicStructure sig M` and `atomMap`, construct an `IntStructureFromSig sig` called `M_Z` such that `eval (int_to_ordered sig M_Z) (fun _ => t) psi <-> eval M (fun _ => t) psi` for all `psi` and `t` (by making `M_Z.interp p t` depend on the actual `M` truth). Then the `separation_implies_expressiveness` result for `M_Z` gives `eval M (fun _ => t) psi <-> int_truth (to_int_struct M_Z atomMap_fwd) t A`, and `int_truth_eq_temporal_truth_Z` gives the temporal_truth form. The challenge is: `int_to_ordered sig M_Z` has carrier `Int` while `M` may not have carrier `Int`, so `eval` may differ structurally.
  - **Approach 2b (characteristic formula + reinterpretation)**: The formula A produced by `expressiveness_inner` only depends on `psi`'s structure and the separation theorem. Show that A is box-free and that `temporal_truth M atomMap t A` depends only on the local truth of atoms and the order structure of M. Since atoms are interpreted the same way (via atomMap) and the temporal operators (U, S) only depend on the order, A's truth is determined by the same data in M as in any Z-structure with matching predicates.
  - **Approach 2c (the eval transfer for fixed t)**: For a fixed point `t : M.carrier`, construct an `IntStructureFromSig` whose predicates at integer `n` match the predicates of the `n`-th successor/predecessor of `t` in `M` (using Prior-UZ/SZ to guarantee that each point has a unique successor/predecessor). This embeds a "Z-like neighborhood" of `t` into a Z-structure. This may require `SuccOrder`/`PredOrder` and `IsSuccArchimedean` instances which are guaranteed by Prior-UZ/SZ on discrete structures.
- [ ] Implement the chosen approach in `SemanticBridge.lean` (extend existing file) or a new file `Theories/Bimodal/Metalogic/WeakCanonical/Separation/PriorTransfer.lean` *(deviation: blocked -- no viable approach found)*
- [ ] Prove `US_expressively_complete_over_prior_via_separation`: the theorem with the SAME type signature as the current `US_expressively_complete_over_prior`, but using `separation_implies_expressiveness` instead of `stavi_expressive_completeness` *(deviation: blocked -- Prior transfer requires GHR93 EF game result which is the same sorry being bypassed)*

**Timing**: 2.5 hours

**Depends on**: 0 (to confirm sorry state and choose the right approach based on findings)

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/PriorTransfer.lean` (new file) or extend `SemanticBridge.lean`

**Verification**:
- New theorem compiles without sorry
- Type signature matches `US_expressively_complete_over_prior` exactly
- `lake build` for the new module succeeds
- No import cycles

---

### Phase 3: Rewire PriorExpressiveness.lean [NOT STARTED]

**Goal**: Replace the `StaviCompleteness` import in `PriorExpressiveness.lean` with the separation-based proof from Phase 2. Make `US_expressively_complete_over_prior` sorry-free.

**Tasks**:
- [ ] Modify `PriorExpressiveness.lean`:
  - Replace `import Bimodal.Metalogic.WeakCanonical.EFGames.StaviCompleteness` with the import for the new PriorTransfer module (or SemanticBridge extension)
  - Keep `import Bimodal.Metalogic.WeakCanonical.StaviConnectives` (needed for `flatten_stavi_correct_prior` infrastructure, which is sorry-free and independent of StaviCompleteness)
- [ ] Rewrite `US_expressively_complete_over_prior` to use the new separation-based proof:
  - Replace `obtain ⟨sf, h_sf⟩ := stavi_expressive_completeness sig atomMap h_surj psi` with the new transfer-based construction
  - Preserve the exact type signature
- [ ] Verify downstream consumers compile without changes:
  - `lake build Bimodal.Metalogic.WeakCanonical.IntegerModel.GoodStructuresModelSurgery`
  - Confirm `gap_prior_UZ_contradiction` still compiles
  - Confirm `no_gaps_discrete_model_surgery` still compiles
- [ ] Run `#print axioms US_expressively_complete_over_prior` to confirm no `sorryAx`
- [ ] Run `#print axioms gap_prior_UZ_contradiction` to confirm no `sorryAx`

**Timing**: 1.5 hours

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/PriorExpressiveness.lean` -- change imports and rewrite `US_expressively_complete_over_prior`

**Verification**:
- `lake build Bimodal.Metalogic.WeakCanonical.PriorExpressiveness` succeeds
- `lake build Bimodal.Metalogic.WeakCanonical.IntegerModel.GoodStructuresModelSurgery` succeeds
- `#print axioms US_expressively_complete_over_prior` shows no `sorryAx`
- `#print axioms gap_prior_UZ_contradiction` shows no `sorryAx`

---

### Phase 4: Full Build Verification and Axiom Audit [NOT STARTED]

**Goal**: Run full project build, verify `completeness_discrete` sorry state, and confirm the Stavi sorry chain is eliminated end-to-end.

**Tasks**:
- [ ] Run `lake build` for the full project (may encounter pre-existing heartbeat timeout in CanonicalTaskRelation.lean -- this is unrelated and non-blocking)
- [ ] Run `#print axioms completeness_discrete` and compare against Phase 0 baseline:
  - If `sorryAx` is gone: Chain A is fully eliminated, task is complete
  - If `sorryAx` remains: identify which chain (should be Chain B via `chronicle_gap_contradiction`). If Chain B, this is expected and documented as a separate concern
- [ ] Verify the full sorry chain is eliminated:
  - `US_expressively_complete_over_prior` -- sorry-free
  - `gap_prior_UZ_contradiction` -- sorry-free
  - `gap_prior_SZ_contradiction` -- sorry-free
  - `no_gaps_discrete_model_surgery` -- sorry-free
  - `limitdom_is_good` -- sorry-free
  - `countermodel_discrete_reynolds_v2` -- sorry-free (from Chain A perspective)
- [ ] Verify no new `sorry` was introduced: `grep -rn "sorry" Theories/Bimodal/Metalogic/WeakCanonical/Separation/ --include="*.lean"` shows no results (excluding comments)
- [ ] Verify no import cycles: `lake build` succeeds
- [ ] Run existing tests: `lake build BimodalTest`

**Timing**: 1 hour

**Depends on**: 3

**Files to modify**:
- None (verification only)

**Verification**:
- `lake build` succeeds for the full project
- `#print axioms completeness_discrete` result documented
- `grep` finds no unexpected sorry in modified/new files
- Existing tests pass

## Testing & Validation

- [ ] `lake build` completes without errors for the full project
- [ ] `#print axioms Bimodal.Metalogic.WeakCanonical.US_expressively_complete_over_prior` does not include `sorryAx`
- [ ] `#print axioms Bimodal.Metalogic.WeakCanonical.IntegerModel.gap_prior_UZ_contradiction` does not include `sorryAx`
- [ ] `#print axioms Bimodal.Metalogic.BXCanonical.completeness_discrete` -- either no `sorryAx` or only through Chain B (documented)
- [ ] `GoodStructuresModelSurgery.lean` compiles without changes (type signature preserved)
- [ ] No new `sorry` introduced in `Separation/` directory
- [ ] No import cycles (verified by successful `lake build`)
- [ ] Existing `Tests/BimodalTest/` tests pass

## Artifacts & Outputs

- `specs/273_chronicle_gap_contradiction_proof/plans/03_separation-bypass-plan.md` (this file, v3)
- Existing file (Phase 1 complete): `Theories/Bimodal/Metalogic/WeakCanonical/Separation/SemanticBridge.lean`
- New file (Phase 2): `Theories/Bimodal/Metalogic/WeakCanonical/Separation/PriorTransfer.lean`
- Modified (Phase 3): `Theories/Bimodal/Metalogic/WeakCanonical/PriorExpressiveness.lean`
- `specs/273_chronicle_gap_contradiction_proof/summaries/03_separation-bypass-summary.md`

## Rollback/Contingency

- If Approach 2a/2b/2c all fail for the Prior transfer (Phase 2): fall back to Approach D-discrete from the research report -- a discrete-only bridge lemma exploiting Cases I/II only, estimated ~200-400 additional lines. This fills the sorry directly in `StaviCompleteness.lean` but only for the discrete case needed by `completeness_discrete`.
- If the `atomMap` direction mismatch creates insurmountable type obstacles: consider modifying the type of `US_expressively_complete_over_prior` to take `atomMap_fwd : sig.preds -> Atom` directly, then adapt all 7 call sites in `GoodStructuresModelSurgery.lean`. This is higher effort but avoids the round-trip issue.
- If `#print axioms completeness_discrete` shows Chain B is also needed: move `mcs_mixed_case_absurd` to a separate module that does not import the sorry-carrying parts of `ChronicleToCountermodel.lean`, then update `Completeness.lean` to import the new module.
- Git revert to the commit before implementation if any phase introduces regressions.
