# Implementation Plan: Reynolds Hybrid Path -- sorry-free completeness_discrete (v10)

- **Task**: 202 - Reynolds k-equivalence bypass for sorry-free completeness_discrete
- **Status**: [IN PROGRESS]
- **Effort**: 20 hours
- **Dependencies**: None
- **Research Inputs**: specs/202_reynolds_k_equivalence_bypass/reports/05_reynolds-theorem-14-research.md, specs/202_reynolds_k_equivalence_bypass/reports/07_bfmcs-bypass-research.md, specs/202_reynolds_k_equivalence_bypass/reports/08_succ-cofinal-dependency-trace.md, specs/202_reynolds_k_equivalence_bypass/reports/10_succ-cofinal-elimination-analysis.md, specs/202_reynolds_k_equivalence_bypass/reports/12_deviation-analysis.md, specs/202_reynolds_k_equivalence_bypass/handoffs/phase-4-5-handoff-20260529b.md
- **Artifacts**: plans/09_reynolds-hybrid-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

---

> **IMPLEMENTATION CONSTRAINT -- READ BEFORE ANY WORK**:
>
> There are TWO parallel pipelines in this codebase. Only ONE is viable.
>
> - **Path A (ACTIVE, correct)**: `completeness_discrete` -> `countermodel_discrete_enriched` -> `dd_countermodel_chronicle_discrete`. This is the parametric canonical model. Its sole sorry is `succ_cofinal`. This plan closes that sorry via `prior_implies_succ_archimedean` (which derives IsSuccArchimedean directly from Prior-UZ/SZ + no_gaps_prior).
> - **Path C (DEAD, do NOT touch)**: `countermodel_discrete_reynolds` at Transfer.lean:1004. This has an UNSOLVABLE sorry at Transfer.lean:1081 (Z-interval to TaskFrame packaging). Do NOT attempt to fix it. Do NOT activate it.
>
> **Pipeline structure** (v10, restructured):
> ```
> no_gaps_prior (sorry -- Phase 2 closes this)
>   + gap_of_not_succ_archimedean (sorry-free)
>   = prior_implies_succ_archimedean (sorry-free modulo no_gaps_prior)
>     -> IsSuccArchimedean on LimitDomSubtype (Phase 3 threads this)
>       -> succ_cofinal (Phase 3 closes this sorry)
>         -> completeness_discrete sorry-free
> ```
>
> This plan does NOT go through `no_gaps_discrete` / `one_class` / `one_class_implies_succ_archimedean`. Those remain in GoodStructures.lean but are OFF the critical path. The restructured pipeline has fewer links and a single sorry concentration point (`no_gaps_prior`).
>
> Phases MUST be executed in strict sequential order. No phase may be skipped.

---

## Overview

Plan v10 revises v9 by correcting phase status annotations (Phases 2-4 were incorrectly marked [COMPLETED] despite `no_gaps_prior` remaining sorry'd) and merging old Phases 2-4 into a single Phase 2 targeting `no_gaps_prior`. The implementation agent's restructuring during Phase 2 execution was mathematically sound: `gap_of_not_succ_archimedean` (sorry-free), `no_gaps_prior` (sorry'd, encapsulating Reynolds Lemmas 6-13 + Theorem 14), `prior_implies_succ_archimedean` (sorry-free modulo `no_gaps_prior`), and the `h_surj` fix to `one_class_implies_succ_archimedean` (correcting a genuine mathematical error). All scaffolding is kept. The sole remaining work is: (1) close the sorry in `no_gaps_prior` by implementing the Reynolds model surgery argument, and (2) thread `prior_implies_succ_archimedean` through the chronicle construction to close `succ_cofinal`.

### Research Integration

- `reports/01_reynolds-bypass-research.md` (plan v1): Initial infrastructure survey.
- `reports/02_option-c-pivot-research.md` (plan v2): Option C pivot research.
- `handoffs/phase-1-handoff-20260529.md` (plan v3): Phase 1 handoff.
- `reports/04_team-research.md` (plan v4): Confirmed F-persistence approaches are dead.
- `reports/05_reynolds-theorem-14-research.md` (plan v6): Identified `no_gaps_discrete` as the sole sorry, mapped the full dependency chain, estimated 700-1050 lines / 15-25 hours, identified key risks.
- `reports/07_bfmcs-bypass-research.md` (plan v8): Confirmed BFMCS itself is sorry-free; sorry enters through succ_embed_surjective in coherence conditions; Reynolds pipeline at Transfer.lean:792 is the correct bypass.
- `reports/08_succ-cofinal-dependency-trace.md` (plan v8): Full dependency trace showing succ_cofinal enters Reynolds pipeline through extract_chronicle_as_prior's domain_succ_archimedean field; avoidable by using `no_gaps_discrete` path.
- `handoffs/phase-4-5-handoff-20260529b.md` (plan v8): Exhaustive analysis of 5 alternative TaskFrame constructions, all failed. Confirms parametric canonical model (`countermodel_discrete_enriched`) is the ONLY viable packaging.
- `reports/10_succ-cofinal-elimination-analysis.md` (plan v9): Comprehensive analysis of agent confusion caused by two parallel pipelines. Identified dead code, stale comments, and confusing remnants. Confirmed `succ_cofinal` must be PROVED not removed. Recommended dead code cleanup phase.
- `reports/12_deviation-analysis.md` (plan v10): Deviation analysis of Phase 2 restructuring. Confirmed `gap_of_not_succ_archimedean` is sound, `h_surj` fix is mathematically necessary, `no_gaps_prior` has correct type, restructured pipeline connects to `succ_cofinal`. Phases 2-4 should be [PARTIAL]/[NOT STARTED], not [COMPLETED].

### Prior Plan Reference

Plans v1-v5 attempted direct approaches to closing `succ_cofinal` or bypassing it via enriched Henkin chains on Z. All blocked by F-persistence under irreflexive semantics. Plan v6 took the correct route (Reynolds Theorem 14 model surgery). Plan v7 attempted a chronicle-derived TaskFrame for Phase 5 with multi-history Omega from BFMCS families, but this founders on the fundamental tension between position-dependent atoms, ShiftClosed Omega, and multi-family box quantification. Plan v8 abandons the novel TaskFrame construction and uses the existing parametric canonical model, closing its `succ_cofinal` sorry via the Reynolds model surgery results. Plan v9 adds a dead code cleanup phase (Phase 0) to prevent agent confusion. Plan v10 corrects phase annotations, merges old Phases 2-4 into a single Phase 2 (no_gaps_prior), and renumbers old Phase 5 to Phase 3 with the restructured pipeline.

### Roadmap Alignment

No ROADMAP.md found.

## Goals & Non-Goals

**Goals**:
- Archive dead code and add warning comments to prevent implementation agent confusion (Phase 0, COMPLETED)
- Prove `stavi_U_false_on_prior`: U'(A,B) is always false on Prior structures (Reynolds 1994, Theorem 5) -- COMPLETED
- Prove `stavi_S_false_on_prior`: S'(A,B) is always false on Prior structures (mirror) -- COMPLETED
- Derive `US_expressively_complete_over_prior`: {U,S} is expressively complete for Prior structures -- COMPLETED
- Close the sorry in `no_gaps_prior` (ReynoldsNoGaps.lean:292) by implementing Reynolds Lemmas 6-13 and deriving that Prior structures have no Dedekind gaps
- Derive `succ_cofinal` from `prior_implies_succ_archimedean` by threading IsSuccArchimedean through the chronicle construction to LimitDomSubtype
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
- Reverting the `gap_of_not_succ_archimedean` / `prior_implies_succ_archimedean` scaffolding (architecturally superior to the original decomposition)
- Closing `no_gaps_discrete` in GoodStructures.lean (off the critical path; can be derived from `no_gaps_prior` later if needed)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `stavi_expressive_completeness` returns existential (Classical.choice), R not computable | M | M | Reynolds' proof only needs existence of R, not a computable R. The model surgery argument is semantic. Wrap R handling in `Classical.choose`. |
| Substructure evaluation: temporal_truth in M\|S may not agree with restricted evaluation | H | L | `GoodStructures.lean` already has `subinterval`. Verify that `temporal_truth` on substructure agrees with restricted evaluation. May need ~50 lines of bridge lemmas. |
| Model surgery (Lemma 12) case analysis is large (~300 lines) | L | H | Reynolds gives every case explicitly. Follow the paper case-by-case. Tedious but straightforward. |
| Threading h_surj through chronicle construction proves complex | M | M | The `mkSigFrom`/`mkAtomMap` construction in Transfer.lean already builds sig and atomMap; h_surj should follow from the construction. |
| `succ_cofinal` definition uses `limitDomSubtype_succ` rather than `Order.succ` | M | L | ChronicleToCountermodel.lean:987-991 proves `Order.succ = limitDomSubtype_succ` definitionally. The `IsSuccArchimedean` instance transfers directly via this equality. |
| Two sorry sites (`no_gaps_prior` and `no_gaps_discrete`) confuse future agents | M | M | `no_gaps_discrete` is OFF the critical path. Add comment noting it can be derived from `no_gaps_prior` later. The plan constraint block above makes the pipeline clear. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 0 | -- |
| 2 | 1 | -- |
| 3 | 2 | 0, 1 |
| 4 | 3 | 2 |

Phases within the same wave can execute in parallel. Phases 0 and 1 are COMPLETED.

---

### Phase 0: Dead Code Cleanup and Warning Comments [COMPLETED]

**Goal**: Archive dead code to `Boneyard/`, add warning comments to dead-end paths, and update stale blocker comments. This prevents implementation agents from getting distracted by dead code and wrong pipelines during Phases 2-3.

**Completed Implementation**: Dead convergence proof archived to `Boneyard/DeadConvergenceProof/succ_cofinal_convergence.lean`. Warning comments added to `countermodel_discrete_reynolds` (Transfer.lean), `extract_chronicle_as_prior` (ChronicleExtraction.lean), `chronicle_is_good` and `chronicle_is_good_direct` (ShiftAndGlue.lean). Stale blocker comment at `no_gaps_discrete` (GoodStructures.lean) updated. `limit_dom_points_are_succ_iterates` archived.

**Timing**: 2 hours (completed)

**Depends on**: none

**Files modified/created**:
- `Boneyard/DeadConvergenceProof/succ_cofinal_convergence.lean` (NEW)
- `Boneyard/DeadConvergenceProof/limit_dom_succ_iterates.lean` (NEW)
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` (MODIFIED)
- `Theories/Bimodal/Metalogic/WeakCanonical/Transfer.lean` (MODIFIED)
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/GoodStructures.lean` (MODIFIED)
- `Theories/Bimodal/Metalogic/WeakCanonical/ChronicleExtraction.lean` (MODIFIED)
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/ShiftAndGlue.lean` (MODIFIED)

**Completed**: 2026-05-29

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

### Phase 2: Reynolds Lemmas 6-13 + Theorem 14 -- Close `no_gaps_prior` [BLOCKED]

**Goal**: Implement the Reynolds model surgery argument (Lemmas 6-13) and close the sorry in `no_gaps_prior` (ReynoldsNoGaps.lean:292), proving that Prior structures have no Dedekind gaps (`IsEmpty (Gap M.carrier)`).

**BLOCKER** (Phase 2):
- **What failed**: The theorem `no_gaps_prior` as currently stated is mathematically incorrect. It claims that any `OrderedMonadicStructure` satisfying Prior-UZ, Prior-SZ, h_surj (atomMap surjective), and discreteness has no Dedekind gaps. A concrete counterexample disproves this: take carrier = Z+Z (two disjoint copies of integers, first copy below second), with constant predicates (M.interp p x = True for all p, x). This structure satisfies all hypotheses (Prior-UZ/SZ are trivially satisfied since all temporal formulas evaluate to constants, and the "first occurrence" is always succ(t)), yet it has a gap between the two copies.
- **What was tried**: (1) Attempted to prove via the abstract Reynolds Lemmas 6-13 model surgery argument as specified in the plan. Analysis revealed the statement is false before implementation began. (2) Analyzed the constant-predicate counterexample in detail, confirming all hypotheses are satisfied. (3) Considered adding a "faithfulness" hypothesis (temporal_truth = MCS membership) to fix the statement, but this would require restructuring the pipeline. (4) Analyzed direct proof approaches for `succ_cofinal` at the omega-chain level; the existing `succ_reaches_dom_N` has two sorry'd boundary cases (lines 1285 and 1441 of ChronicleToCountermodel.lean) where succ(max_N_sub) or pred(min_N_sub) may enter the domain at an arbitrarily later stage, defeating the stage-induction argument.
- **Why it's stuck**: The core issue is that `no_gaps_prior` lacks a hypothesis connecting temporal_truth to the structure's predicate interpretation. In the chronicle construction, this connection exists (via `chronicle_temporal_truth_effective`), but the abstract theorem doesn't require it. The constant-predicate Z+Z structure satisfies all stated hypotheses but has a gap. The Reynolds model surgery argument from the paper DOES work, but only for "faithful" structures where temporal truth determines predicate truth — a condition not captured in the current formalization.
- **What is needed**: One of three approaches: (A) Add a faithfulness hypothesis to `no_gaps_prior` (e.g., `∀ t φ, temporal_truth M atomMap t φ ↔ M.interp (atomMap φ) t`) and prove the corrected theorem, then verify the chronicle satisfies the new hypothesis. (B) Bypass `no_gaps_prior` entirely and prove `succ_cofinal` directly at the `ChronicleAsPriorModel` level using chronicle-specific properties (Prior-UZ in MCS form + C4/C5 coherence). (C) Fix the boundary cases in `succ_reaches_dom_N` by using a different induction principle (e.g., well-founded induction on the pair (stage, position) rather than stage alone).
- **Prohibited workarounds**: Do NOT use `sorry`, `def X := True`, or any vacuous placeholder

**CRITICAL GUIDANCE FOR IMPLEMENTATION AGENTS**: This phase works ONLY with `ReynoldsNoGaps.lean` and possibly `MonadicFO.lean`. Do NOT touch `Transfer.lean`, `ChronicleToCountermodel.lean`, or `countermodel_discrete_reynolds`. The target is the sorry at `no_gaps_prior` (ReynoldsNoGaps.lean:292). The conclusion type is `IsEmpty (Gap M.carrier)` -- prove that no Dedekind gaps exist.

**Current state (keep all scaffolding)**:
- `gap_of_not_succ_archimedean` (lines 158-234, sorry-free) -- If NOT IsSuccArchimedean, Gap exists. Independently valuable. Do not modify.
- `no_gaps_prior` (lines 277-292, sorry'd) -- THIS IS THE TARGET. Close this sorry.
- `prior_implies_succ_archimedean` (lines 304-316, sorry-free modulo no_gaps_prior) -- Composes `no_gaps_prior` with `gap_of_not_succ_archimedean`. Do not modify.
- `one_class_implies_succ_archimedean` (lines 326-334, sorry-free modulo no_gaps_prior) -- Revised with `h_surj` hypothesis (genuine mathematical correction). Do not modify.

**Literature**: Reynolds 1994, Section 7, pp.124-129, Lemmas 6-13 and Theorem 14.

**Proof Strategy**: The proof of `no_gaps_prior` goes by contradiction. Suppose `gamma : Gap M.carrier` exists. Then:
1. (Lemma 6) By `US_expressively_complete_over_prior` (Phase 1, requires `h_surj`), construct temporal formula R equivalent to rho(x) = "x's ~M-class ends at gamma on the right." Similarly L for the left side.
2. (Lemmas 7-8) R-intervals are open with excluded endpoints. No first/last ~M-class in any maximal R-interval.
3. (Lemma 9) ~M-classes within R-intervals are elementarily equivalent as substructures.
4. (Lemma 10) Bad points (where R or L holds) only occur in non-singleton bad intervals.
5. (Lemma 11) Formulas true at the start of a class in a bad interval hold throughout.
6. (Lemma 12, KEY) Model surgery: replace a bad interval Q_o by one ~M-class I; temporal truth is preserved in Q_minus U I U Q_plus (induction on formula, 13 cases for U(A,B)).
7. (Lemma 13) The surgery model N is a Prior structure where R holds in I, but I's class in N cannot end at a gap (bounded by the excluded endpoint). Contradiction with R holding.
8. Conclude `IsEmpty (Gap M.carrier)`.

**Tasks**:
- [ ] **Task 2.1**: Define `rho_formula` -- FO formula rho(x) = "x's ~M-class ends in a gap on the right" (~40 lines)
- [ ] **Task 2.2**: Define `gap_formula_R` and `gap_formula_L` -- temporal equivalents of rho and its mirror via `US_expressively_complete_over_prior` (~30 lines)
- [ ] **Task 2.3**: Prove `gap_formula_R_correct` -- R holds exactly where rho holds (~60 lines)
- [ ] **Task 2.4**: Prove `R_intervals_open` (Lemma 7) -- maximal R-intervals are open with excluded endpoints (~100 lines)
- [ ] **Task 2.5**: Prove `R_no_first_last_class` (Lemma 8) -- no first or last ~M-class in any maximal R-interval (~60 lines)
- [ ] **Task 2.6**: Prove `substructure_temporal_truth` -- temporal truth in M|S agrees with restricted evaluation (~80 lines)
- [ ] **Task 2.7**: Prove `R_classes_elem_equiv` (Lemma 9) -- ~M-classes in R-intervals are elementarily equivalent (~120 lines)
- [ ] **Task 2.8**: Define `bad_point` and `bad_interval` (~30 lines)
- [ ] **Task 2.9**: Prove `bad_points_in_intervals` (Lemma 10) -- bad points only in non-singleton intervals, R and L hold throughout, excluded endpoints (~80 lines)
- [ ] **Task 2.10**: Prove `bad_interval_propagation` (Lemma 11) -- formula true at start of class holds throughout bad interval (~60 lines)
- [ ] **Task 2.11**: Define `surgery_model` -- substructure Q_minus U I U Q_plus (~50 lines)
- [ ] **Task 2.12**: Prove `surgery_preserves_truth` (Lemma 12) -- temporal truth preserved in surgery model (~200 lines)
- [ ] **Task 2.13**: Prove `no_bad_points` (Lemma 13) -- bad points cannot exist in any Prior structure (~80 lines)
- [ ] **Task 2.14**: Close the sorry in `no_gaps_prior` using `no_bad_points` -- if Gap exists, bad points exist (via gap formula R), but no_bad_points says they cannot (~30 lines)

**Timing**: 12 hours

**Depends on**: 0, 1

**Files to modify/create**:
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/ReynoldsNoGaps.lean` (EXTEND, ~950 lines added) -- Lemmas 6-13, Theorem 14 proof body
- `Theories/Bimodal/Metalogic/WeakCanonical/MonadicFO.lean` (MODIFY, ~80 lines) -- `substructure_temporal_truth` (or place in ReynoldsNoGaps if MonadicFO modification is too invasive)

**Verification**:
- `#print axioms no_gaps_prior` shows no `sorryAx`
- `#print axioms prior_implies_succ_archimedean` shows no `sorryAx`
- `lake build Bimodal.Metalogic.WeakCanonical.IntegerModel.ReynoldsNoGaps` succeeds
- No new sorry sites in ReynoldsNoGaps.lean

---

### Phase 3: Bridge `prior_implies_succ_archimedean` to `succ_cofinal` and Close Path A [NOT STARTED]

**Goal**: Thread `prior_implies_succ_archimedean` (now sorry-free after Phase 2) through the chronicle construction to derive `IsSuccArchimedean` on `LimitDomSubtype`, close the `succ_cofinal` sorry in ChronicleToCountermodel.lean, and verify `completeness_discrete` is sorry-free.

**CRITICAL GUIDANCE FOR IMPLEMENTATION AGENTS**: This phase modifies `ChronicleToCountermodel.lean` to close the `succ_cofinal` sorry. The restructured pipeline is:
1. `no_gaps_prior` (Phase 2 closed this sorry) proves `IsEmpty (Gap M.carrier)` for Prior structures
2. `prior_implies_succ_archimedean` (already sorry-free modulo no_gaps_prior) derives `IsSuccArchimedean` from Prior-UZ/SZ
3. Thread: instantiate `prior_implies_succ_archimedean` on `chronicleAsMonadicStructure` whose carrier IS `LimitDomSubtype`
4. The `IsSuccArchimedean` instance on `LimitDomSubtype` gives `succ_cofinal` directly

Do NOT go through `one_class` / `no_gaps_discrete` / `one_class_implies_succ_archimedean`. Those are off the critical path. Do NOT touch `countermodel_discrete_reynolds` or `Transfer.lean:1081`.

**Literature**: Reynolds 1994, consequence of Theorem 14. The mathematical argument: `prior_implies_succ_archimedean` gives `IsSuccArchimedean` on any discrete Prior structure. The chronicle's monadic structure (`chronicleAsMonadicStructure` in NEquivalence.lean) on `LimitDomSubtype` IS a Prior structure. Therefore `LimitDomSubtype` is `IsSuccArchimedean`. In a discrete linear order, `IsSuccArchimedean` means for any a < b, there exist finitely many successor steps from a to b. This gives `succ_cofinal` (which needs `exists n, b <= succ^[n] a`).

**Tasks**:
- [ ] **Task 3.1**: Provide `h_surj` for the chronicle's monadic structure (~40-60 lines)
  The `mkSigFrom` / `mkAtomMap` construction in Transfer.lean (lines 1033-1047) builds `sig` and `atomMap_rev`. For `h_surj`, we need: for every predicate `p` in `sig.preds`, there exists an `Atom` whose image under the forward map equals `p`. Since `atomMap_fwd` maps formula `f` to its subtype in `sig.preds`, and `sig.preds = {Formula.bot} U phi.predFormulas`, surjectivity follows from the construction. This needs careful Lean proof but is feasible.

- [ ] **Task 3.2**: Instantiate `prior_implies_succ_archimedean` on the chronicle (~30-50 lines)
  ```lean
  -- Need: prior_implies_succ_archimedean sig k hk
  --   (chronicleAsMonadicStructure ...) atomMap h_surj h_prior_UZ h_prior_SZ
  -- Result: IsSuccArchimedean LimitDomSubtype
  ```
  Thread the `sig`, `k`, `hk`, `atomMap`, `h_surj`, `h_prior_UZ`, `h_prior_SZ` parameters through the chronicle construction. The `h_prior_UZ`/`h_prior_SZ` for the chronicle were already discharged in `chronicle_is_good_direct` (ShiftAndGlue.lean, completed in plan v8 via `chronicle_semantic_prior_UZ`/`chronicle_semantic_prior_SZ` in Transfer.lean).

- [ ] **Task 3.3**: Close the `succ_cofinal` sorry using the IsSuccArchimedean instance (~30-50 lines)
  `succ_cofinal` (ChronicleToCountermodel.lean:1497-1510) needs `exists n, b <= (limitDomSubtype_succ ...)^[n] a` for `a < b`. The `IsSuccArchimedean` instance from Task 3.2 gives `exists n, Order.succ^[n] a = b`. By the definitional equality `Order.succ = limitDomSubtype_succ` (ChronicleToCountermodel.lean:987-991), this directly yields `limitDomSubtype_succ^[n] a = b`, hence `b <= limitDomSubtype_succ^[n] a`.

- [ ] **Task 3.4**: Verify `succ_embed_surjective` is now sorry-free (~5 lines)
  `#print axioms succ_embed_surjective` -- should show no `sorryAx`

- [ ] **Task 3.5**: Verify `countermodel_discrete_enriched` is now sorry-free (~5 lines)
  `#print axioms countermodel_discrete_enriched` -- should show no `sorryAx`

- [ ] **Task 3.6**: Full build verification (~10 lines)
  - `lake build` -- full project, zero errors
  - `#print axioms completeness_discrete` -- no `sorryAx`
  - `grep -r "sorry" Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/ReynoldsNoGaps.lean` -- no sorry
  - `grep -r "sorry" Theories/Bimodal/Metalogic/WeakCanonical/PriorExpressiveness.lean` -- no sorry
  - Existing dense completeness path unaffected (`#print axioms completeness_dense` unchanged)

**Timing**: 3 hours

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` -- close `succ_cofinal` sorry
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/ReynoldsNoGaps.lean` (or new file) -- bridge infrastructure if needed
- `Theories/Bimodal/Metalogic/WeakCanonical/Transfer.lean` -- h_surj proof for mkAtomMap (if needed)

**Verification**:
- `#print axioms succ_cofinal` or equivalent shows no `sorryAx`
- `#print axioms succ_embed_surjective` shows no `sorryAx`
- `#print axioms countermodel_discrete_enriched` shows no `sorryAx`
- `#print axioms completeness_discrete` shows no `sorryAx`
- `lake build` passes with zero errors
- No new sorry sites in any modified files

## Testing & Validation

- [x] Phase 0: `lake build` passes after cleanup, `#print axioms completeness_discrete` unchanged
- [x] `#print axioms stavi_U_false_on_prior_UZ` shows no `sorryAx` (Phase 1, completed)
- [x] `#print axioms US_expressively_complete_over_prior` shows no `sorryAx` (Phase 1, completed)
- [ ] `#print axioms no_gaps_prior` shows no `sorryAx` (Phase 2)
- [ ] `#print axioms prior_implies_succ_archimedean` shows no `sorryAx` (Phase 2, automatic once no_gaps_prior closed)
- [ ] `#print axioms succ_cofinal` or equivalent shows no `sorryAx` (Phase 3)
- [ ] `#print axioms succ_embed_surjective` shows no `sorryAx` (Phase 3)
- [ ] `#print axioms countermodel_discrete_enriched` shows no `sorryAx` (Phase 3)
- [ ] `#print axioms completeness_discrete` shows no `sorryAx` (Phase 3)
- [ ] `lake build` passes with zero errors (Phase 3)
- [ ] No new sorry sites introduced (grep across all modified/created files)
- [ ] Existing dense completeness path unaffected (`#print axioms completeness_dense` unchanged)

## Artifacts & Outputs

- `specs/202_reynolds_k_equivalence_bypass/plans/09_reynolds-hybrid-plan.md` (this plan)
- `Boneyard/DeadConvergenceProof/succ_cofinal_convergence.lean` (EXISTING, Phase 0) -- archived dead proof
- `Boneyard/DeadConvergenceProof/limit_dom_succ_iterates.lean` (EXISTING, Phase 0) -- archived dead helper
- `Theories/Bimodal/Metalogic/WeakCanonical/PriorExpressiveness.lean` (EXISTING, 395 lines) -- Theorem 5 (Phase 1, completed)
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/ReynoldsNoGaps.lean` (EXTEND) -- Lemmas 6-13, close no_gaps_prior sorry (Phase 2), bridge infrastructure (Phase 3)
- `Theories/Bimodal/Metalogic/WeakCanonical/MonadicFO.lean` (MODIFY) -- `substructure_temporal_truth` (~80 lines, Phase 2)
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` (MODIFY) -- close `succ_cofinal` sorry (Phase 3)

## Rollback/Contingency

Phase 0 and Phase 1 are completed and will not be rolled back. Phase 2 work goes into `ReynoldsNoGaps.lean` (extending existing file) and possibly `MonadicFO.lean`. Reverting Phase 2 restores the `sorry` in `no_gaps_prior`. Phase 3 modifies `ChronicleToCountermodel.lean` to close `succ_cofinal`; reverting restores the `sorry`.

**Phase 2 contingencies**:
1. **If model surgery (Lemma 12) case analysis exceeds 300 lines**: Break the 13 cases for U(A,B) into individual lemmas. Use existing `subinterval` infrastructure from GoodStructures.lean.
2. **If `substructure_temporal_truth` is hard to prove in full generality**: Prove only the cases needed by Lemma 12 (convex subsets of discrete linear orders). The full general version can follow later.
3. **If the gap formula R construction is difficult due to Classical.choice**: The gap formula R only needs to EXIST (not be computable). Use `Classical.choose` freely. The model surgery argument is semantic.

**Phase 3 contingencies**:
1. **If threading h_surj through the chronicle construction is harder than expected**: The `mkSigFrom`/`mkAtomMap` construction in Transfer.lean already builds sig and atomMap. The h_surj proof should follow from the construction's surjectivity properties. If not, add a helper lemma in Transfer.lean.
2. **If `prior_implies_succ_archimedean` does not directly give the right `IsSuccArchimedean` instance for `LimitDomSubtype`**: The chronicle's domain IS `LimitDomSubtype`. The `chronicleAsMonadicStructure`'s carrier is `LimitDomSubtype`. So `prior_implies_succ_archimedean` applied to this structure gives `IsSuccArchimedean LimitDomSubtype` directly. If type-level coercions cause issues, add explicit casts.
3. **If `succ_cofinal` requires a different form than `IsSuccArchimedean`**: `succ_cofinal` needs `exists n, b <= succ^[n] a` for `a < b`. `IsSuccArchimedean` gives `exists n, succ^[n] a = b` for `a <= b`. The two are directly related: equality implies `<=`, and for `a < b` we get the required witness.
