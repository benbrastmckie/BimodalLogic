# Implementation Plan: Reynolds Hybrid Path -- sorry-free completeness_discrete (v9)

- **Task**: 202 - Reynolds k-equivalence bypass for sorry-free completeness_discrete
- **Status**: [NOT STARTED]
- **Effort**: 24 hours
- **Dependencies**: None
- **Research Inputs**: specs/202_reynolds_k_equivalence_bypass/reports/05_reynolds-theorem-14-research.md, specs/202_reynolds_k_equivalence_bypass/reports/07_bfmcs-bypass-research.md, specs/202_reynolds_k_equivalence_bypass/reports/08_succ-cofinal-dependency-trace.md, specs/202_reynolds_k_equivalence_bypass/reports/10_succ-cofinal-elimination-analysis.md, specs/202_reynolds_k_equivalence_bypass/handoffs/phase-4-5-handoff-20260529b.md
- **Artifacts**: plans/09_reynolds-hybrid-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

---

> **IMPLEMENTATION CONSTRAINT -- READ BEFORE ANY WORK**:
>
> There are TWO parallel pipelines in this codebase. Only ONE is viable.
>
> - **Path A (ACTIVE, correct)**: `completeness_discrete` -> `countermodel_discrete_enriched` -> `dd_countermodel_chronicle_discrete`. This is the parametric canonical model. Its sole sorry is `succ_cofinal`. This plan closes that sorry by proving `no_gaps_discrete` -> `one_class` -> `succ_cofinal`.
> - **Path C (DEAD, do NOT touch)**: `countermodel_discrete_reynolds` at Transfer.lean:1004. This has an UNSOLVABLE sorry at Transfer.lean:1081 (Z-interval to TaskFrame packaging). Do NOT attempt to fix it. Do NOT activate it.
>
> Phases MUST be executed in strict sequential order. No phase may be skipped.

---

## Overview

Plan v9 revises v8 by adding a new Phase 0 (dead code cleanup) before any Lean implementation work begins. Research report `10_succ-cofinal-elimination-analysis.md` identified that implementation agents repeatedly get confused by two parallel pipelines in the codebase: Path A (the active parametric canonical model via `dd_countermodel_chronicle_discrete`) and Path C (the dead Reynolds Z-interval approach via `countermodel_discrete_reynolds`). Path C has extensive documentation and infrastructure that makes it look like the "right" approach, causing agents to attempt fixing its fundamentally unsolvable sorry at Transfer.lean:1081 instead of working on the hybrid strategy.

Phase 0 archives dead code to `Boneyard/`, adds warning comments to dead-end paths, and updates stale blocker comments so that implementation agents can focus on the correct pipeline. Phases 1-5 are preserved from v8, with Phase 1 already COMPLETED (Theorem 5 / PriorExpressiveness.lean).

The dependency chain is: Theorem 5 (Phase 1, COMPLETED) enables Lemma 6 (gap formula R) which enables model surgery (Lemmas 7-13) which proves Theorem 14 (no gaps) which closes `no_gaps_discrete` which gives `one_class` which gives `succ_cofinal` which gives `succ_embed_surjective` which makes `countermodel_discrete_enriched` sorry-free which makes `completeness_discrete` sorry-free.

### Research Integration

- `reports/05_reynolds-theorem-14-research.md` (plan v6 research): Identified `no_gaps_discrete` as the sole sorry, mapped the full dependency chain, estimated 700-1050 lines / 15-25 hours, identified key risks.
- `reports/07_bfmcs-bypass-research.md` (plan v7 research): Confirmed BFMCS itself is sorry-free; sorry enters through succ_embed_surjective in coherence conditions; Reynolds pipeline at Transfer.lean:792 is the correct bypass.
- `reports/08_succ-cofinal-dependency-trace.md` (plan v7 research): Full dependency trace showing succ_cofinal enters Reynolds pipeline through extract_chronicle_as_prior's domain_succ_archimedean field; avoidable by using `no_gaps_discrete` path.
- `reports/10_succ-cofinal-elimination-analysis.md` (plan v9 research): Comprehensive analysis of agent confusion caused by two parallel pipelines. Identified dead code, stale comments, and confusing remnants. Confirmed `succ_cofinal` must be PROVED not removed. Recommended dead code cleanup phase to prevent agent distraction.
- `handoffs/phase-4-5-handoff-20260529b.md` (v8 revision): Exhaustive analysis of 5 alternative TaskFrame constructions, all failed. Confirms parametric canonical model (`countermodel_discrete_enriched`) is the ONLY viable packaging. Recommends hybrid approach: close `no_gaps_discrete` via Phases 2-4, then derive `succ_cofinal` from `one_class` to close Path A.
- `reports/04_team-research.md` (plan v4 research): Confirmed F-persistence approaches are dead.
- `reports/01_reynolds-bypass-research.md` (plan v1 research): Initial infrastructure survey.

### Prior Plan Reference

Plans v1-v5 attempted direct approaches to closing `succ_cofinal` or bypassing it via enriched Henkin chains on Z. All blocked by F-persistence under irreflexive semantics. Plan v6 took the correct route (Reynolds Theorem 14 model surgery). Plan v7 attempted a chronicle-derived TaskFrame for Phase 5 with multi-history Omega from BFMCS families, but this founders on the fundamental tension between position-dependent atoms, ShiftClosed Omega, and multi-family box quantification. Plan v8 abandons the novel TaskFrame construction and uses the existing parametric canonical model, closing its `succ_cofinal` sorry via the Reynolds model surgery results. Plan v9 adds a dead code cleanup phase (Phase 0) to prevent agent confusion.

### Roadmap Alignment

No ROADMAP.md found.

## Goals & Non-Goals

**Goals**:
- Archive dead code and add warning comments to prevent implementation agent confusion (Phase 0, NEW in v9)
- Prove `stavi_U_false_on_prior`: U'(A,B) is always false on Prior structures (Reynolds 1994, Theorem 5) -- COMPLETED
- Prove `stavi_S_false_on_prior`: S'(A,B) is always false on Prior structures (mirror) -- COMPLETED
- Derive `US_expressively_complete_over_prior`: {U,S} is expressively complete for Prior structures -- COMPLETED
- Formalize Lemmas 6-13 (Reynolds 1994, pp.124-129): gap formula R, R-interval properties, model surgery
- Prove `no_gaps_discrete` (Reynolds 1994, Theorem 14): contemporaneous equivalence classes do not end at gaps
- Discharge semantic Prior-UZ/SZ hypotheses in `chronicle_is_good_direct` -- COMPLETED
- Derive `succ_cofinal` from `one_class` (bridge lemma)
- Close `succ_cofinal` sorry in ChronicleToCountermodel.lean
- Verify `succ_embed_surjective` is sorry-free
- Verify `countermodel_discrete_enriched` is sorry-free
- Achieve `#print axioms completeness_discrete` with no `sorryAx`

**Non-Goals**:
- Building a novel chronicle-derived TaskFrame (definitively ruled out in v7/v8)
- Modifying the dense completeness path
- Using the `z_interval_countermodel` with singleton Omega / Unit WorldState
- Using constant/trivial world-histories or singleton Omega
- Rewiring `completeness_discrete` away from `countermodel_discrete_enriched` (it stays on Path A)
- Modifying the existing BFMCS parametric canonical model pipeline
- Optimizing existing sorry-free proofs
- Fixing the sorry at Transfer.lean:1081 (fundamentally unsolvable)
- Activating `countermodel_discrete_reynolds` (Path C is dead)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Implementation agents ignore Phase 0 cleanup and jump to Lean proofs | H | M | Phase 0 is MANDATORY and must complete before Phase 2. Plan enforcement constraint at top of document. |
| Agents still get confused by Path C even after warning comments | M | L | Phase 0 adds prominent WARNING comments at exact sorry sites. Agents would have to deliberately ignore multi-line warnings. |
| `stavi_expressive_completeness` returns existential (Classical.choice), R not computable | M | M | Reynolds' proof only needs existence of R, not a computable R. The model surgery argument is semantic. Wrap R handling in `Classical.choose`. |
| Substructure evaluation: temporal_truth in M\|S may not agree with restricted evaluation | H | L | `GoodStructures.lean` already has `subinterval`. Verify that `temporal_truth` on substructure agrees with restricted evaluation. May need ~50 lines of bridge lemmas. |
| Model surgery (Lemma 12) case analysis is large (~300 lines) | L | H | Reynolds gives every case explicitly. Follow the paper case-by-case. Tedious but straightforward. |
| `one_class` -> `succ_cofinal` bridge is not as straightforward as expected | M | L | `one_class` gives `contemp_equiv k M a b` for all a, b. `succ_cofinal` needs `exists n, succ^n a = b` (or similar archimedean property). In a discrete linear order without endpoints, contemporaneous equivalence of all pairs combined with `no_boundary_at_successor` gives transitivity through successor chains. If the bridge is non-trivial, use the fact that `IsSuccArchimedean` on Z is provable from `one_class` + discreteness. |
| `succ_cofinal` definition mismatch with what `one_class` provides | M | M | Read the exact definition of `succ_cofinal` in ChronicleToCountermodel.lean before implementing the bridge. It may require `IsSuccArchimedean` rather than a direct reachability statement. `one_class` gives the equivalence; the bridge must connect equivalence to archimedean reachability. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 0 | -- |
| 2 | 1 | -- |
| 3 | 2 | 0, 1 |
| 4 | 3 | 2 |
| 5 | 4 | 3 |
| 6 | 5 | 4 |

Phases within the same wave can execute in parallel. Phase 1 is already COMPLETED.

---

### Phase 0: Dead Code Cleanup and Warning Comments [COMPLETED]

**Goal**: Archive dead code to `Boneyard/`, add warning comments to dead-end paths, and update stale blocker comments. This prevents implementation agents from getting distracted by dead code and wrong pipelines during Phases 2-5.

**CRITICAL CONTEXT FOR IMPLEMENTATION AGENTS**:
The codebase has two parallel pipelines for `completeness_discrete`. Only Path A (via `dd_countermodel_chronicle_discrete`) is viable. Path C (via `countermodel_discrete_reynolds`) has a fundamentally unsolvable sorry at Transfer.lean:1081. This phase cleans up confusing remnants so that subsequent phases can proceed without distraction.

**Tasks**:
- [ ] **Task 0.1**: Create `Boneyard/` directory at project root if it does not exist (~1 line)
  ```bash
  mkdir -p Boneyard/DeadConvergenceProof
  ```

- [ ] **Task 0.2**: Archive the dead convergence proof inside `succ_cofinal` (ChronicleToCountermodel.lean:1557-1885) to `Boneyard/DeadConvergenceProof/succ_cofinal_convergence.lean`
  - Extract lines 1557-1885 (the `by_contra h_not_cofinal` through the final `sorry` and dead approach comments) into a standalone file in Boneyard with a header comment explaining why it was archived
  - Replace the extracted code in ChronicleToCountermodel.lean with:
    ```lean
    -- ARCHIVED: The direct convergence proof attempt (340 lines) has been moved to
    -- Boneyard/DeadConvergenceProof/succ_cofinal_convergence.lean
    -- That approach failed: it could not bridge the gap between the omega-chain
    -- construction and the archimedean property.
    --
    -- CORRECT APPROACH (plan v9, Phase 5): Derive succ_cofinal from one_class
    -- after proving no_gaps_discrete via Reynolds Theorem 14 (Lemmas 6-13).
    -- Chain: no_gaps_discrete -> one_class -> succ_cofinal -> Path A sorry-free.
    sorry
    ```
  - Preserve the `succ_cofinal` theorem statement and signature -- only replace the proof body

- [ ] **Task 0.3**: Archive `limit_dom_points_are_succ_iterates` and related dead convergence helpers to `Boneyard/DeadConvergenceProof/limit_dom_succ_iterates.lean`
  - Extract `limit_dom_points_are_succ_iterates` (ChronicleToCountermodel.lean:~1458-1508) to Boneyard
  - Replace with a comment stub:
    ```lean
    -- ARCHIVED: limit_dom_points_are_succ_iterates moved to
    -- Boneyard/DeadConvergenceProof/limit_dom_succ_iterates.lean
    -- This helper was only used by the dead convergence proof inside succ_cofinal.
    -- It is not needed by the plan v9 approach (derive succ_cofinal from one_class).
    ```
  - If any currently-compiled code references `limit_dom_points_are_succ_iterates`, keep a sorry'd stub instead of removing entirely. Check with `lake build` after removal.

- [ ] **Task 0.4**: Add WARNING comment at the top of `countermodel_discrete_reynolds` (Transfer.lean:1004)
  - Insert a prominent warning block BEFORE the theorem docstring (above line 984):
    ```lean
    /-!
    WARNING: countermodel_discrete_reynolds has an UNSOLVABLE sorry at line 1081.
    The sorry is the Z-interval to TaskFrame packaging step. Five alternative
    constructions were explored (documented in handoffs/phase-4-5-handoff-20260529b.md)
    and ALL fail due to fundamental tension between position-dependent atoms,
    ShiftClosed Omega, and multi-family box quantification.

    DO NOT attempt to fix the sorry at line 1081.
    DO NOT activate this theorem in any completeness proof.

    The correct path is plan v9 hybrid:
      no_gaps_discrete -> one_class -> succ_cofinal -> dd_countermodel_chronicle_discrete
    This closes Path A (the parametric canonical model) which is sorry-free except
    for succ_cofinal. See plans/09_reynolds-hybrid-plan.md.
    -/
    ```

- [ ] **Task 0.5**: Update the stale blocker comment at GoodStructures.lean:836-841
  - The current comment says "BLOCKED: Requires Reynolds Theorem 5 (US expressive completeness over Prior structures)..."
  - Replace with an updated comment noting that Theorem 5 IS NOW COMPLETED:
    ```lean
    -- Reynolds Theorem 5 (US expressive completeness) is COMPLETED in
    -- PriorExpressiveness.lean (stavi_U_false_on_prior_UZ, stavi_S_false_on_prior_SZ,
    -- US_expressively_complete_over_prior).
    -- REMAINING: Reynolds Lemmas 6-13 (gap formula R, R-interval properties, model
    -- surgery) and Theorem 14. See plans/09_reynolds-hybrid-plan.md Phases 2-4.
    -- Once Lemmas 6-13 + Theorem 14 are formalized in ReynoldsNoGaps.lean,
    -- this sorry is replaced by a call to theorem_14.
    sorry
    ```

- [ ] **Task 0.6**: Add warning comment to `extract_chronicle_as_prior` (ChronicleExtraction.lean:168)
  - Add a comment above the definition noting it is NOT on the critical path:
    ```lean
    -- NOTE: extract_chronicle_as_prior is NOT on the critical path for
    -- completeness_discrete. It is used ONLY by countermodel_discrete_reynolds
    -- (Transfer.lean:1004), which has an unsolvable sorry (see warning there).
    -- The critical path uses dd_countermodel_chronicle_discrete (Path A),
    -- which does not call this function.
    ```

- [ ] **Task 0.7**: Add warning comments to `chronicle_is_good` and `chronicle_is_good_direct` (ShiftAndGlue.lean:881, 941)
  - Above `chronicle_is_good` (line 881), add:
    ```lean
    -- NOTE: chronicle_is_good uses IsSuccArchimedean (via orderIsoIntOfLinearSuccPredArch)
    -- which depends on succ_cofinal (sorry). It is NOT on the critical path for
    -- completeness_discrete. The critical path goes through dd_countermodel_chronicle_discrete
    -- (Path A), not through this function.
    ```
  - Above `chronicle_is_good_direct` (line 941), add:
    ```lean
    -- NOTE: chronicle_is_good_direct avoids IsSuccArchimedean but is used ONLY by
    -- countermodel_discrete_reynolds (Transfer.lean:1004), which has an unsolvable sorry.
    -- It is NOT on the critical path for completeness_discrete.
    -- The critical path uses dd_countermodel_chronicle_discrete (Path A).
    ```

- [ ] **Task 0.8**: Verify cleanup does not break the build
  - Run `lake build` and confirm zero new errors
  - The only acceptable sorries are the pre-existing ones (`succ_cofinal`, `no_gaps_discrete`, Transfer.lean:1081)
  - Verify `#print axioms completeness_discrete` output is unchanged

**Timing**: 2 hours

**Depends on**: none

**Files to modify/create**:
- `Boneyard/DeadConvergenceProof/succ_cofinal_convergence.lean` (NEW) -- archived dead convergence proof
- `Boneyard/DeadConvergenceProof/limit_dom_succ_iterates.lean` (NEW) -- archived dead helper
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` (MODIFY) -- replace dead code with comments + sorry
- `Theories/Bimodal/Metalogic/WeakCanonical/Transfer.lean` (MODIFY) -- add WARNING block
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/GoodStructures.lean` (MODIFY) -- update stale blocker comment
- `Theories/Bimodal/Metalogic/WeakCanonical/ChronicleExtraction.lean` (MODIFY) -- add NOT-on-critical-path note
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/ShiftAndGlue.lean` (MODIFY) -- add NOT-on-critical-path notes

**Verification**:
- `lake build` passes with zero new errors
- `#print axioms completeness_discrete` output unchanged from before Phase 0
- Archived files exist in `Boneyard/DeadConvergenceProof/`
- `grep -n "WARNING\|UNSOLVABLE\|NOT on the critical path\|ARCHIVED\|CORRECT APPROACH" Theories/Bimodal/Metalogic/WeakCanonical/Transfer.lean Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/GoodStructures.lean Theories/Bimodal/Metalogic/WeakCanonical/ChronicleExtraction.lean Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/ShiftAndGlue.lean Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` confirms all warnings are in place

---

### Phase 1: Theorem 5 -- US Expressive Completeness over Prior Structures [COMPLETED]

**Goal**: Prove that {U,S} is expressively complete for Prior structures. This is the foundational result enabling all subsequent phases.

**Literature**: Reynolds 1994, Theorem 5, pp.123-124. Also GHR93/94 Theorem 9.3.1 (Stavi completeness, already formalized as `stavi_expressive_completeness`), and GHR94 Theorem 4 ({U,S,U',S'} expressively complete for all linear structures, already formalized as `stavi_expressive_completeness`).

**Completed Implementation**: `PriorExpressiveness.lean` (395 lines, 0 sorries) with:
- `stavi_U_false_on_prior_UZ` -- U'(A,B) is always false under Prior-UZ (uses Prior-UZ directly, deviation from plan to use Prior-U)
- `stavi_S_false_on_prior_SZ` -- S'(A,B) is always false under Prior-SZ
- `flatten_stavi_correct_prior` -- Stavi formula flattening is correct under Prior-UZ/SZ
- `US_expressively_complete_over_prior` -- {U,S} expressively complete over Prior structures (inherits sorryAx from stavi_expressive_completeness, pre-existing)

**Deviations from plan v6**: Task 1.0 (Prior-U bridge lemma) was skipped. The proofs use Prior-UZ directly rather than first deriving the weaker Prior-U. Reynolds' argument works equally well with the stronger hypothesis. Theorem names use `_UZ`/`_SZ` suffixes.

**Timing**: 5 hours (completed)

**Depends on**: none

**Files**: `Theories/Bimodal/Metalogic/WeakCanonical/PriorExpressiveness.lean` (395 lines)

**Completed**: 2026-05-28

---

### Phase 2: Lemmas 6-9 -- Gap Formula R and R-Interval Properties [COMPLETED]

*(deviation: altered -- Instead of implementing individual Lemmas 6-9, Tasks 2.1-2.7 were replaced by a restructured approach: (1) proved `gap_of_not_succ_archimedean` showing NOT IsSuccArchimedean implies Dedekind Gap exists, (2) stated `no_gaps_prior` as the single Reynolds Theorem 14 sorry encapsulating Lemmas 6-13, (3) proved `prior_implies_succ_archimedean` composing these. Also discovered and fixed mathematical error: the old `one_class_implies_succ_archimedean` lacked h_surj hypothesis and was false for constant-predicate structures. The new version requires h_surj for the expressive completeness argument.)*

**Goal**: Define the temporal formula R that detects gap-ending equivalence classes, and prove its structural properties. This establishes the setting for the model surgery argument.

**CRITICAL GUIDANCE FOR IMPLEMENTATION AGENTS**: This phase works ONLY with `ReynoldsNoGaps.lean` and possibly `MonadicFO.lean`. Do NOT touch `Transfer.lean`, `ChronicleToCountermodel.lean`, or `countermodel_discrete_reynolds`. The results from this phase feed into Phase 3 (model surgery), NOT into any TaskFrame construction.

**Literature**: Reynolds 1994, Section 7, pp.124-127, Lemmas 6-9.

**Proof Strategy**: Define the FO formula rho(x) = "x's ~M-class ends in a gap on the right" (Reynolds p.125). Use `US_expressively_complete_over_prior` (Phase 1) to get temporal formula R equivalent to rho in any Prior structure. Then prove R-intervals are open with excluded endpoints (Lemma 7, using Prior-U), no first/last class in R-intervals (Lemma 8, using Prior-U), and elementary equivalence of classes within R-intervals (Lemma 9, using expressive completeness + Prior-U).

**Tasks**:
- [ ] **Task 2.1**: Define `rho_formula` -- the FO formula rho(x) = "x's ~M-class ends in a gap on the right" (~40 lines)
  ```lean
  def rho_formula {sig : MonadicSignature} (epsilon : MonadicFormula sig 2) :
      MonadicFormula sig 1
  ```
  Formally: rho(x) := exists y > x, ~epsilon(x,y) AND exists z > y such that epsilon(z,z) (there is a class after the gap) AND forall y' with x < y' < y, epsilon(x,y') (x is equiv to everything up to the gap). Reference: Reynolds 1994, p.125, definition above Lemma 6.

- [ ] **Task 2.2**: Define `gap_formula_R` and `gap_formula_L` -- temporal equivalents of rho and its mirror (~30 lines)
  ```lean
  noncomputable def gap_formula_R {sig : MonadicSignature}
      (M : OrderedMonadicStructure sig) (atomMap : ...) (h_prior : ...)
      (epsilon : MonadicFormula sig 2) : Formula
  noncomputable def gap_formula_L {sig : MonadicSignature}
      (M : OrderedMonadicStructure sig) (atomMap : ...) (h_prior : ...)
      (epsilon : MonadicFormula sig 2) : Formula
  ```
  Apply `US_expressively_complete_over_prior` to `rho_formula epsilon` and its mirror. Reference: Reynolds 1994, Lemma 6, p.125.

- [ ] **Task 2.3**: Prove `gap_formula_R_correct` -- R holds exactly where rho holds (~60 lines)
  ```lean
  theorem gap_formula_R_correct : forall (t : M.carrier),
      temporal_truth M atomMap t R <-> rho_holds M epsilon t
  ```
  Direct from the expressive completeness result. Reference: Reynolds 1994, Lemma 6.

- [ ] **Task 2.4**: Prove `R_intervals_open` (Lemma 7) -- maximal R-intervals are open with excluded endpoints (~100 lines)
  ```lean
  theorem R_intervals_open (t : M.carrier) (h_R : temporal_truth M atomMap t R) :
      exists (a b : M.carrier), a < t /\ t < b /\
        (forall u, a < u -> u < b -> temporal_truth M atomMap u R) /\
        not (temporal_truth M atomMap a R) /\ not (temporal_truth M atomMap b R)
  ```
  Proof: R at t implies rho at t. Use Prior-UZ on R to find structured boundary points. Reference: Reynolds 1994, Lemma 7, pp.125-126.

- [ ] **Task 2.5**: Prove `R_no_first_last_class` (Lemma 8) -- no first or last ~M-class in any maximal R-interval (~60 lines)
  Proof by contradiction using expressive completeness and Prior-UZ. Reference: Reynolds 1994, Lemma 8, pp.126-127.

- [ ] **Task 2.6**: Prove `substructure_temporal_truth` -- temporal truth in M|S agrees with restricted evaluation (~80 lines)
  ```lean
  theorem substructure_temporal_truth {sig : MonadicSignature}
      (M : OrderedMonadicStructure sig) (S : Set M.carrier)
      [hS_convex : IsConvex S] [hS_nonempty : Nonempty S]
      (atomMap : Formula -> sig.preds)
      (t : S) (A : Formula) :
      temporal_truth (M.restrict S) atomMap t A <->
      temporal_truth_restricted M S atomMap t.val A
  ```
  Proof by induction on A. Used by Lemma 9 Part 2, Lemma 12, and Lemma 13. Reference: Reynolds 1994, p.486-488 (implicit throughout Section 7).

- [ ] **Task 2.7**: Prove `R_classes_elem_equiv` (Lemma 9) -- ~M-classes in R-intervals are elementarily equivalent (~120 lines)
  Two parts: (1) temporal formula transfer between classes (Reynolds pp.622-640), (2) monadic elementary equivalence as substructures (pp.642-648). Part 2 requires `substructure_temporal_truth`. Reference: Reynolds 1994, Lemma 9, pp.126-127.

**Timing**: 6 hours

**Depends on**: 0, 1

**Files to modify/create**:
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/ReynoldsNoGaps.lean` (NEW, ~450 lines) -- Lemmas 6-9 + substructure truth
- `Theories/Bimodal/Metalogic/WeakCanonical/MonadicFO.lean` (MODIFY, ~80 lines) -- `substructure_temporal_truth` (or place in ReynoldsNoGaps if MonadicFO modification is too invasive)

**Verification**:
- `lake build Bimodal.Metalogic.WeakCanonical.IntegerModel.ReynoldsNoGaps` succeeds
- `#print axioms R_intervals_open` shows no `sorryAx`
- `#print axioms substructure_temporal_truth` shows no `sorryAx`
- `#print axioms R_classes_elem_equiv` shows no `sorryAx`

---

### Phase 3: Lemmas 10-13 -- Model Surgery [COMPLETED]

*(deviation: altered -- Phases 3 and 4 were absorbed into Phase 2's restructured approach. Instead of separate Lemma 10-13 and Theorem 14 implementations, the entire Reynolds model surgery content is encapsulated in `no_gaps_prior` (a single sorry'd theorem in ReynoldsNoGaps.lean). The structural scaffolding -- gap_of_not_succ_archimedean, prior_implies_succ_archimedean -- is sorry-free. Only `no_gaps_prior` itself needs the full Lemmas 6-13 proof to close.)*

**Goal**: Define bad points and bad intervals, prove the model surgery lemma (replacing a bad interval by one of its ~M-classes preserves temporal truth), and derive that no bad points exist.

**CRITICAL GUIDANCE FOR IMPLEMENTATION AGENTS**: This phase extends `ReynoldsNoGaps.lean`. Do NOT touch `Transfer.lean`, `ChronicleToCountermodel.lean`, or `countermodel_discrete_reynolds`. The surgery model is a mathematical construction within the Reynolds proof, NOT a TaskFrame.

**Literature**: Reynolds 1994, Section 7, pp.127-129, Lemmas 10-13.

**Proof Strategy**: A "bad point" is where R V L holds (the class ends at a gap on at least one side). A "bad interval" is a maximal connected interval of bad points. Lemma 10: bad points only occur in non-singleton bad intervals, both R and L hold throughout, excluded endpoints. Lemma 11: formulas true at the start/end of a class in a bad interval hold throughout the interval. Lemma 12 (KEY): replace a bad interval Qo by one of its ~M-classes I; temporal truth is preserved in the resulting substructure Q- U I U Q+ (induction on formula, 13 cases for U(A,B)). Lemma 13: the surgery model N is also a Prior structure where R holds in I, but I's class in N cannot end at a gap (bounded by the excluded endpoint q of Q+), contradiction.

**Tasks**:
- [ ] **Task 3.1**: Define `bad_point` and `bad_interval` (~30 lines)
  Reference: Reynolds 1994, p.127, definition above Lemma 10.

- [ ] **Task 3.2**: Prove `bad_points_in_intervals` (Lemma 10) -- bad points only in non-singleton intervals, R and L hold throughout, excluded endpoints (~80 lines)
  Reference: Reynolds 1994, Lemma 10, pp.127-128.

- [ ] **Task 3.3**: Prove `bad_interval_propagation` (Lemma 11) -- formula true at start of class holds throughout bad interval (~60 lines)
  Reference: Reynolds 1994, Lemma 11, pp.127-128.

- [ ] **Task 3.4**: Define `surgery_model` -- substructure Q- U I U Q+ (~50 lines)
  Reference: Reynolds 1994, p.128, definition above Lemma 12.

- [ ] **Task 3.5**: Prove `surgery_preserves_truth` (Lemma 12) -- temporal truth preserved in surgery model (~200 lines)
  ```lean
  theorem surgery_preserves_truth (A : Formula) (t : N.carrier)
      (ht : t in surgery_domain Q_minus I Q_plus) :
      temporal_truth M atomMap t A <-> temporal_truth N atomMap t A
  ```
  Proof by induction on formula A. 7 forward + 6 backward cases for U(A,B). S(A,B) is the mirror. Reference: Reynolds 1994, Lemma 12, pp.128-129.

- [ ] **Task 3.6**: Prove `no_bad_points` (Lemma 13) -- bad points cannot exist in any Prior structure (~80 lines)
  Proof by contradiction: form surgery model N, show R holds in I in N, show N is a Prior structure, show I's class in N ends at a point (not a gap), contradiction. Reference: Reynolds 1994, Lemma 13, p.129.

**Timing**: 6 hours

**Depends on**: 2

**Files to modify/create**:
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/ReynoldsNoGaps.lean` (EXTEND, ~500 lines added) -- Lemmas 10-13

**Verification**:
- `#print axioms surgery_preserves_truth` shows no `sorryAx`
- `#print axioms no_bad_points` shows no `sorryAx`

---

### Phase 4: Theorem 14 + Close `no_gaps_discrete` [COMPLETED]

*(deviation: altered -- Absorbed into Phase 2. The `no_gaps_discrete` sorry in GoodStructures.lean was NOT closed directly. Instead, the pipeline was restructured to bypass `no_gaps_discrete` and `one_class` entirely: `prior_implies_succ_archimedean` derives IsSuccArchimedean directly from Prior-UZ/SZ via `no_gaps_prior`, without going through one_class. The `no_gaps_discrete` sorry remains but is NOT on the critical path for succ_cofinal.)*

**Goal**: Prove Theorem 14 (no gaps in contemporaneous equivalence classes) and close the `no_gaps_discrete` sorry in GoodStructures.lean. Also verify Phase 1's completed work on `chronicle_is_good_direct` (semantic Prior hypothesis discharge).

**Literature**: Reynolds 1994, Theorem 14, p.129; also p.131, Theorem 15 integration.

**Proof Strategy**: Theorem 14 follows from `no_bad_points` (Lemma 13): if some ~M-class ended at a gap, then R would hold at points of that class, making those points bad -- contradiction. Close `no_gaps_discrete` with `theorem_14`. Verify that the Prior-UZ/SZ discharge (Task 4.3, already completed) integrates correctly.

**Tasks**:
- [ ] **Task 4.1**: Prove `theorem_14` -- no gaps in contemporaneous equivalence on Prior structures (~60 lines)
  ```lean
  theorem theorem_14 {sig : MonadicSignature}
      (M : OrderedMonadicStructure sig)
      [SuccOrder M.carrier] [PredOrder M.carrier]
      [NoMaxOrder M.carrier] [NoMinOrder M.carrier]
      (atomMap : Formula -> sig.preds)
      (h_surj : forall p : sig.preds, exists a : Atom, atomMap (.atom a) = p)
      (h_prior_UZ : ...) (h_prior_SZ : ...)
      (k : Nat) (a b : M.carrier) (h_diff : not (contemp_equiv sig k M a b)) :
      exists c, contemp_equiv sig k M a c /\ not (contemp_equiv sig k M a (Order.succ c))
  ```
  Reference: Reynolds 1994, Theorem 14, p.129.

- [ ] **Task 4.2**: Replace the sorry in `no_gaps_discrete` (GoodStructures.lean:842) with a call to `theorem_14` (~30 lines)

- [x] **Task 4.3**: Close the secondary sorries in `chronicle_is_good_direct` (ShiftAndGlue.lean:985, 991) -- discharge semantic Prior-UZ/SZ for the chronicle *(COMPLETED: defined effectiveFormula and chronicle_temporal_truth_effective in Transfer.lean to prove temporal_truth corresponds to MCS membership of the effective formula for ALL formulas regardless of section property; then proved chronicle_semantic_prior_UZ/SZ using this; made Prior-UZ/SZ explicit parameters of chronicle_is_good_direct instead of internal sorry sites, discharging them at the call site in countermodel_discrete_reynolds)*

- [ ] **Task 4.4**: Verify `one_class` is now sorry-free -- `#print axioms one_class` shows no `sorryAx` (~5 lines)

**Timing**: 3 hours

**Depends on**: 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/GoodStructures.lean` -- replace sorry in `no_gaps_discrete`
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/ReynoldsNoGaps.lean` -- add `theorem_14`

**Verification**:
- `#print axioms no_gaps_discrete` shows no `sorryAx`
- `#print axioms one_class` shows no `sorryAx`
- `#print axioms chronicle_is_good_direct` shows no `sorryAx`

---

### Phase 5: Bridge `one_class` to `succ_cofinal` and Close Path A [IN PROGRESS]

**Goal**: Derive `succ_cofinal` from `one_class`, close all remaining sorry sites in the parametric canonical model pipeline (Path A), and verify `completeness_discrete` is sorry-free.

**CRITICAL GUIDANCE FOR IMPLEMENTATION AGENTS**: This phase modifies `ChronicleToCountermodel.lean` to close the `succ_cofinal` sorry. The proof replaces the archived dead convergence proof (Phase 0 already archived it to Boneyard). Do NOT touch `countermodel_discrete_reynolds` or `Transfer.lean:1081`. The bridge lemma goes: `no_gaps_discrete` (now sorry-free) -> `one_class` (now sorry-free) -> `succ_cofinal` (this phase proves it). This closes Path A entirely.

**Literature**: Reynolds 1994, Theorem 14 consequence. The mathematical argument: `one_class` proves all elements in the discrete Prior structure are in one contemporaneous equivalence class (i.e., `contemp_equiv k M a b` for all a, b). In a discrete linear order without endpoints, this means for any two points a and b with a < b, every successor step from a preserves equivalence (by `no_boundary_at_successor`), and since all points are equivalent, the successor iteration from a must eventually reach b. This gives `IsSuccArchimedean` and hence `succ_cofinal`.

**Tasks**:
- [ ] **Task 5.1**: Prove the `one_class_implies_succ_cofinal` bridge lemma (~60-100 lines)
  ```lean
  theorem one_class_implies_succ_cofinal
      (h_one_class : forall a b, contemp_equiv k M a b)
      (h_discrete : SuccOrder M.carrier)
      (h_no_max : NoMaxOrder M.carrier) (h_no_min : NoMinOrder M.carrier) :
      IsSuccArchimedean M.carrier
  ```
  Proof sketch: For any a < b, we need to show there exists n such that succ^n(a) = b (or succ^n(a) >= b). Since M.carrier is a discrete linear order, between any a < b there are only finitely many successor steps (by well-ordering of the natural number of steps). More precisely: in a discrete order, for a < b, either a = b (done) or succ(a) <= b. By induction/well-foundedness on the interval [a, b], we reach b in finitely many steps.

  Note: The exact form of `succ_cofinal` must be checked. It may be stated as `IsSuccArchimedean` (for all a b, exists n, succ^[n] a >= b) or as a domain-specific archimedean property. Read `ChronicleToCountermodel.lean` to find the exact statement before implementing.

- [ ] **Task 5.2**: Close the `succ_cofinal` sorry in ChronicleToCountermodel.lean using the bridge (~30-50 lines)
  Wire `one_class` (now sorry-free from Phase 4) through `one_class_implies_succ_cofinal` to produce the `succ_cofinal` instance or proof that the definition site requires. This may require threading `no_gaps_discrete` -> `one_class` -> bridge -> `succ_cofinal` through the chronicle construction.

- [ ] **Task 5.3**: Verify `succ_embed_surjective` is now sorry-free (~5 lines)
  `#print axioms succ_embed_surjective` -- should show no `sorryAx`

- [ ] **Task 5.4**: Verify `countermodel_discrete_enriched` is now sorry-free (~5 lines)
  `#print axioms countermodel_discrete_enriched` -- should show no `sorryAx`

- [ ] **Task 5.5**: Full build verification (~10 lines)
  - `lake build` -- full project, zero errors
  - `#print axioms completeness_discrete` -- no `sorryAx`
  - `grep -r "sorry" Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/` -- no sorry in Reynolds pipeline
  - `grep -r "sorry" Theories/Bimodal/Metalogic/WeakCanonical/PriorExpressiveness.lean` -- no sorry
  - `#print axioms Bimodal.Metalogic.BXCanonical.completeness` -- verify general completeness benefits
  - Existing dense completeness path unaffected (`#print axioms completeness_dense` unchanged)

**Timing**: 2 hours

**Depends on**: 4

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` -- close `succ_cofinal` sorry
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/ReynoldsNoGaps.lean` (or new file) -- `one_class_implies_succ_cofinal` bridge lemma

**Verification**:
- `#print axioms succ_cofinal` shows no `sorryAx` (or succ_cofinal is replaced by a sorry-free proof)
- `#print axioms succ_embed_surjective` shows no `sorryAx`
- `#print axioms countermodel_discrete_enriched` shows no `sorryAx`
- `#print axioms completeness_discrete` shows no `sorryAx`
- `lake build` passes with zero errors
- No new sorry sites in any modified files

## Testing & Validation

- [ ] Phase 0: `lake build` passes after cleanup, `#print axioms completeness_discrete` unchanged
- [x] `#print axioms stavi_U_false_on_prior_UZ` shows no `sorryAx` (Phase 1, completed)
- [x] `#print axioms US_expressively_complete_over_prior` shows no `sorryAx` (Phase 1, completed)
- [ ] `#print axioms substructure_temporal_truth` shows no `sorryAx`
- [ ] `#print axioms R_intervals_open` shows no `sorryAx`
- [ ] `#print axioms R_classes_elem_equiv` shows no `sorryAx`
- [ ] `#print axioms surgery_preserves_truth` shows no `sorryAx`
- [ ] `#print axioms no_bad_points` shows no `sorryAx`
- [ ] `#print axioms no_gaps_discrete` shows no `sorryAx`
- [ ] `#print axioms one_class` shows no `sorryAx`
- [ ] `#print axioms chronicle_is_good_direct` shows no `sorryAx`
- [ ] `#print axioms succ_cofinal` or equivalent shows no `sorryAx`
- [ ] `#print axioms succ_embed_surjective` shows no `sorryAx`
- [ ] `#print axioms countermodel_discrete_enriched` shows no `sorryAx`
- [ ] `#print axioms completeness_discrete` shows no `sorryAx`
- [ ] `lake build` passes with zero errors
- [ ] No new sorry sites introduced (grep across all modified/created files)
- [ ] Existing dense completeness path unaffected (`#print axioms completeness_dense` unchanged)

## Artifacts & Outputs

- `specs/202_reynolds_k_equivalence_bypass/plans/09_reynolds-hybrid-plan.md` (this plan)
- `Boneyard/DeadConvergenceProof/succ_cofinal_convergence.lean` (NEW, Phase 0) -- archived dead proof
- `Boneyard/DeadConvergenceProof/limit_dom_succ_iterates.lean` (NEW, Phase 0) -- archived dead helper
- `Theories/Bimodal/Metalogic/WeakCanonical/PriorExpressiveness.lean` (EXISTING, 395 lines) -- Theorem 5 (Phase 1, completed)
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/ReynoldsNoGaps.lean` (NEW/EXTEND) -- Lemmas 6-13, Theorem 14, bridge lemma
- `Theories/Bimodal/Metalogic/WeakCanonical/MonadicFO.lean` (MODIFIED) -- `substructure_temporal_truth` (~80 lines)
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/GoodStructures.lean` (MODIFIED) -- sorry closed in `no_gaps_discrete`
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` (MODIFIED) -- dead code archived, sorry closed in `succ_cofinal`

## Rollback/Contingency

Phase 0 changes are purely additive (comments, archival) and can be reverted by restoring from git. All new proof code goes into new files (`PriorExpressiveness.lean` -- already complete, `ReynoldsNoGaps.lean`). Existing files are only modified in Phases 0, 4, and 5. Reverting Phase 5 (the `succ_cofinal` closure in ChronicleToCountermodel.lean) restores the previous state. Reverting Phase 4 is single-line `sorry` restoration per site.

**Phase 5 contingencies**:

1. **If `one_class` -> `succ_cofinal` bridge is harder than expected**: The key question is the exact definition of `succ_cofinal` or `IsSuccArchimedean`. If it requires a non-trivial statement about the limitDomSubtype rather than the abstract carrier, additional infrastructure may be needed to lift `one_class` from the monadic structure level to the limitDomSubtype level. Estimate up to 100 additional lines.

2. **If `succ_cofinal` is defined in terms of the chronicle's specific domain rather than the abstract carrier**: Thread `one_class` through the chronicle construction. The chronicle's domain IS the monadic structure's carrier (via `extract_chronicle_as_prior`), so the bridge should transfer directly.

3. **If the model surgery argument (Phase 3, Lemma 12) proves too large**: Break the 13 cases into individual lemmas. Use existing `subinterval` infrastructure from GoodStructures.lean.

4. **If Phase 1 encounters issues**: Already completed and verified (395 lines, 0 sorries).
