# Implementation Plan: Chronicle-Level Proof of succ_cofinal (v11)

- **Task**: 202 - Reynolds k-equivalence bypass for sorry-free completeness_discrete
- **Status**: [NOT STARTED]
- **Effort**: 12 hours
- **Dependencies**: None
- **Research Inputs**: specs/202_reynolds_k_equivalence_bypass/reports/05_reynolds-theorem-14-research.md, specs/202_reynolds_k_equivalence_bypass/reports/07_bfmcs-bypass-research.md, specs/202_reynolds_k_equivalence_bypass/reports/08_succ-cofinal-dependency-trace.md, specs/202_reynolds_k_equivalence_bypass/reports/12_deviation-analysis.md, specs/202_reynolds_k_equivalence_bypass/handoffs/phase-2-blocked-20260529.md
- **Artifacts**: plans/10_chronicle-level-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

---

> **IMPLEMENTATION CONSTRAINT -- READ BEFORE ANY WORK**:
>
> Plan v11 abandons `no_gaps_prior` (mathematically false as stated) and proves
> `succ_cofinal` directly at the `ChronicleAsPriorModel` level using Path B.
>
> **Pipeline structure** (v11, chronicle-level):
> ```
> gap_of_not_succ_archimedean (sorry-free)
>   + US_expressively_complete_over_prior (sorry-free, Phase 1 COMPLETED)
>   + chronicle_temporal_truth_effective (sorry-free)
>   + chronicle MCS-level Prior-UZ/SZ (sorry-free)
>   = chronicle_no_gaps (Phase 2 -- NEW)
>     -> succ_cofinal closed (Phase 3)
>       -> completeness_discrete sorry-free
> ```
>
> This plan does NOT go through `no_gaps_prior` (ReynoldsNoGaps.lean:292).
> That theorem is mathematically false without a faithfulness hypothesis
> (constant-predicate Z+Z counterexample -- see blocker handoff).
>
> Phases MUST be executed in strict sequential order. No phase may be skipped.

---

## Overview

Plan v11 replaces the blocked Phase 2 from plan v10. The blocker: `no_gaps_prior` (ReynoldsNoGaps.lean:277-292) is mathematically incorrect as stated -- a Z+Z structure with constant predicates satisfies all hypotheses but has a Dedekind gap. The missing hypothesis is "faithfulness" -- a connection between temporal_truth and predicate interpretation that holds in the chronicle setting but not in the abstract theorem.

Path B proves `succ_cofinal` directly at the `ChronicleAsPriorModel` level, bypassing the abstract `no_gaps_prior` entirely. This works because the chronicle construction IS the faithful setting where Reynolds' argument applies:

1. `ChronicleAsPriorModel` (ChronicleExtraction.lean:85) provides a discrete domain with MCS assignment
2. `chronicle_temporal_truth_effective` (Transfer.lean:806) provides faithfulness: temporal_truth corresponds to MCS membership of the effective formula
3. `chronicle_semantic_prior_UZ/SZ` (Transfer.lean:887/947) give semantic Prior-UZ/SZ
4. `US_expressively_complete_over_prior` (PriorExpressiveness.lean, Phase 1 COMPLETED) gives gap-detecting formulas

With these, the Reynolds gap-elimination argument goes through at the chronicle level without needing the abstract `no_gaps_prior`.

### Research Integration

- `reports/01_reynolds-bypass-research.md` (plan v1): Initial infrastructure survey.
- `reports/05_reynolds-theorem-14-research.md` (plan v6): Mapped the full dependency chain.
- `reports/07_bfmcs-bypass-research.md` (plan v8): Confirmed BFMCS sorry-free; Reynolds pipeline correct.
- `reports/08_succ-cofinal-dependency-trace.md` (plan v8): Full dependency trace.
- `reports/12_deviation-analysis.md` (plan v10): Phase 2 restructuring assessment.
- `handoffs/phase-2-blocked-20260529.md` (plan v11): Blocker analysis showing `no_gaps_prior` is false as stated, three alternative paths, user chose Path B.

### Prior Plan Reference

Plans v1-v5 attempted direct approaches, all blocked by F-persistence. Plan v6 took the Reynolds Theorem 14 route. Plans v7-v8 refined the pipeline. Plan v9 added dead code cleanup. Plan v10 corrected phase annotations, merged old Phases 2-4 into a single Phase 2 targeting `no_gaps_prior`. Plan v10 Phase 2 blocked: `no_gaps_prior` is mathematically false as stated. Plan v11 bypasses `no_gaps_prior` and proves `succ_cofinal` at the chronicle level using the faithfulness bridge (`chronicle_temporal_truth_effective`).

## Goals & Non-Goals

**Goals**:
- Deprecate `no_gaps_prior` with a comment explaining the counterexample and why it is false as stated
- Prove `chronicle_no_gaps`: the chronicle's `ChronicleAsPriorModel` domain has no Dedekind gaps, using the faithfulness bridge and Reynolds' model surgery argument adapted to the concrete MCS setting
- Close the `succ_cofinal` sorry in ChronicleToCountermodel.lean:1510
- Verify `completeness_discrete` has no `sorryAx`

**Non-Goals**:
- Fixing `no_gaps_prior` by adding a faithfulness hypothesis (possible but unnecessary -- Path B is more direct)
- Closing `no_gaps_discrete` in GoodStructures.lean (off the critical path)
- Modifying the dense completeness path
- Touching `countermodel_discrete_reynolds` (Path C is dead)
- Building a novel TaskFrame (definitively ruled out)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Model surgery at chronicle level requires reproving Lemmas 6-13 in the MCS setting (~600 lines) | H | M | The MCS setting SIMPLIFIES the argument: faithfulness is built in, so the gap formula R is directly expressible as MCS membership. Many intermediate lemmas collapse. |
| `chronicle_temporal_truth_effective` returns `effectiveFormula`, not the original formula | M | L | The `effectiveFormula` substitution is transparent for the gap argument. R-formula properties depend on temporal_truth behavior, which `chronicle_temporal_truth_effective` characterizes exactly. |
| `US_expressively_complete_over_prior` uses `Classical.choose` for the gap formula R | L | H | Only existence of R is needed, not computability. `Classical.choose` is fine for the semantic argument. |
| Threading the new `chronicle_no_gaps` through to `succ_cofinal` requires refactoring `extract_chronicle_as_prior` | M | L | The simpler approach: prove `succ_cofinal` directly inside ChronicleToCountermodel.lean using the new theorem, without changing the `ChronicleAsPriorModel` structure. |
| MCS-level argument for gap formula R correctness is harder than expected | M | M | Fallback: use Path A from blocker handoff (add faithfulness to `no_gaps_prior`, verify chronicle satisfies it). This is 600-1000 lines but well-understood. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Deprecate no_gaps_prior and Prepare Infrastructure [COMPLETED]

**Goal**: Mark `no_gaps_prior` as deprecated (not on critical path) with a clear comment explaining the counterexample. Prove a corrected version `no_gaps_prior_faithful` that adds the faithfulness hypothesis, which will serve as the lemma instantiated on the chronicle.

**Tasks**:
- [x] **Task 1.1**: Add deprecation comment to `no_gaps_prior` (ReynoldsNoGaps.lean:277-292)
  - Add a docstring block above the sorry explaining: (a) the theorem is mathematically false as stated, (b) the Z+Z constant-predicate counterexample, (c) it is OFF the critical path, (d) `chronicle_no_gaps` in the new file handles the chronicle case directly
  - Do NOT delete `no_gaps_prior` -- leave the sorry in place with the warning
  - Do NOT modify `prior_implies_succ_archimedean` or `one_class_implies_succ_archimedean` (they remain sound if `no_gaps_prior` is ever corrected)
  - File: `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/ReynoldsNoGaps.lean`, lines 260-292
  - ~15 lines of comments

- [x] **Task 1.2**: Create new file `ChronicleNoGaps.lean` with module structure *(deviation: altered -- file created in WeakCanonical with local copy of gap_of_not_succ_archimedean to avoid import cycle; also added PriorExpressiveness import to ChronicleToCountermodel.lean and centralized sorry in chronicle_gap_contradiction)*
  - File: `Theories/Bimodal/Metalogic/WeakCanonical/ChronicleNoGaps.lean` (NEW)
  - Import: `Bimodal.Metalogic.WeakCanonical.Transfer` (for `chronicle_temporal_truth_effective`, `chronicle_semantic_prior_UZ/SZ`, `chronicleAsMonadicStructure`, `effectiveFormula`, `mkSigFrom`, `mkAtomMap`)
  - Import: `Bimodal.Metalogic.WeakCanonical.PriorExpressiveness` (for `US_expressively_complete_over_prior`)
  - Import: `Bimodal.Metalogic.WeakCanonical.IntegerModel.ReynoldsNoGaps` (for `gap_of_not_succ_archimedean`, `Gap`)
  - Module docstring explaining the chronicle-level no-gaps proof
  - ~30 lines of setup

- [ ] **Task 1.3**: Define the gap-detecting formula R at the chronicle level *(deviation: deferred to Phase 2 -- gap formula construction is part of the core model-theoretic argument)*
  - Using `US_expressively_complete_over_prior` on the `chronicleAsMonadicStructure`, obtain a temporal formula R equivalent to the monadic FO formula rho(x) = "x's equivalence class ends at the gap on the right"
  - Since `chronicle_temporal_truth_effective` gives `temporal_truth M_struct atomMap_fwd t psi <-> effectiveFormula atomMap_rev atomMap_fwd psi in M.fmcs t`, the gap formula R can be characterized by MCS membership
  - The key point: in the chronicle, temporal_truth CORRESPONDS to MCS membership (faithfulness), so R holding at a point means a specific effective formula is in that point's MCS
  - File: `ChronicleNoGaps.lean`
  - ~60 lines

**Timing**: 2 hours

**Depends on**: none

**Files to modify/create**:
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/ReynoldsNoGaps.lean` (MODIFY -- add deprecation comments only)
- `Theories/Bimodal/Metalogic/WeakCanonical/ChronicleNoGaps.lean` (NEW)

---

### Phase 2: Chronicle-Level No-Gaps Proof [BLOCKED]

**BLOCKER** (Phase 2):
- **What failed**: The Prior-SZ contradiction argument (plan's alternative argument #5) requires a distinguishing formula phi that holds throughout the cut C but not in the complement C'. No such formula is guaranteed to exist -- the Z+Z counterexample with constant predicates satisfies ALL MCS axioms (Prior-UZ, Prior-SZ, C4, C5, Z1) but has a gap where all MCS's are identical.
- **What was tried**: (1) Direct Prior-SZ argument -- needs distinguishing formula, blocked by constant-MCS case. (2) Z1 axiom approach -- Z1 is satisfied with constant predicates, doesn't rule out gaps. (3) US expressive completeness on a custom structure with cut predicate -- needs semantic Prior-UZ/SZ for the custom structure, which doesn't follow from the MCS-level Prior-UZ/SZ. (4) Stage induction on omega-chain -- boundary cases intractable (succ of max(dom(N)) may enter at arbitrarily later stage).
- **Why it's stuck**: The abstract MCS axioms (Prior-UZ, Prior-SZ, C4, C5, Z1) are insufficient to rule out gaps. The Z+Z counterexample proves this. The proof MUST use a property specific to the chronicle's omega-chain construction that the abstract axioms don't capture. Three viable paths: (a) Show the omega-chain construction never produces constant-MCS gaps (requires deep omega-chain analysis). (b) Full Reynolds model surgery (Lemmas 6-13) with a faithfulness bridge from the chronicle. (c) Add a faithfulness hypothesis to the abstract theorem and verify the chronicle satisfies it.
- **What is needed**: Either formalize Reynolds Lemmas 6-13 (~400-600 lines of novel model-theoretic proofs involving R-intervals, model surgery, and temporal truth preservation under surgery), or prove that the omega-chain construction rules out the constant-MCS gap scenario.
- **Prohibited workarounds**: Do NOT use `sorry`, `def X := True`, or any vacuous placeholder

**Goal**: Prove `chronicle_no_gaps`: for any `ChronicleAsPriorModel`, the domain has no Dedekind gaps (`IsEmpty (Gap M.domain)`). This is the core mathematical content, implementing Reynolds' model surgery argument in the concrete MCS setting where faithfulness holds by construction.

**Mathematical argument** (Reynolds Theorem 14 adapted to the chronicle level):

Suppose for contradiction that gamma is a Gap in M.domain. Then:

1. **Gap formula R** (from Phase 1, Task 1.3): By `US_expressively_complete_over_prior`, there exists a temporal formula R equivalent (on the chronicle's monadic structure) to the FO formula "x's equivalence class extends to gamma on the right." By `chronicle_temporal_truth_effective`, R holding at a point t means `effectiveFormula(..., R) in M.fmcs t`.

2. **R characterization via MCS**: Points below gamma where R holds form a downward-unbounded set. Points above gamma do not satisfy R. This follows from the definition of rho and the gap structure.

3. **Prior-UZ gives structure to R-intervals**: Since Prior-UZ holds at the MCS level (`M.prior_UZ_valid`), the first-occurrence property constrains how R can change: if F(R) holds at some point, then U(R, not-R) holds, meaning R has a definite first occurrence. This means R-intervals (maximal connected sets where R holds) have structure -- they are open (no first/last R-point in an R-interval).

4. **Model surgery** (the core argument): Take a maximal R-interval Q containing a bad point. By the C4/C5 coherence conditions (`until_coherent_fwd`, `neg_until_coherent`, `since_coherent_fwd`, `neg_since_coherent`), we can reason about Until/Since truth within and across the interval boundary. The key insight: pick a point p in Q. Replace Q by the single equivalence class of p (in terms of temporal truth). By C4/C5 coherence and the structure of R-intervals, temporal truth is preserved for all formulas in the surgery model. But in the surgery model, R holds at p yet p's class cannot extend to the gap (the gap was removed). Contradiction with R characterizing gap-proximity.

5. **Alternative direct argument** (potentially simpler in the MCS setting): Suppose a gap gamma exists. The cut set C = {x : x < gamma-side} is successor-closed (from the gap definition and `gap_of_not_succ_archimedean`). By Prior-SZ at the MCS level: if any formula psi has a past occurrence (S direction), then it has a LAST occurrence. But the gap creates a situation where the cut C has no maximum, yet every point in C sees points in the complement above it. The LAST-occurrence property for a distinguishing formula (one that holds in C but not in the complement, or vice versa) leads to a point where the last occurrence is in the boundary region -- but no boundary exists (no max of C, no min of complement). This gives the contradiction.

**Tasks**:
- [ ] **Task 2.1**: Define `chronicle_rho_holds` -- the FO predicate "x's equivalence class ends at gap gamma on the right" expressed as MCS membership
  - This characterizes which domain points are "near the gap" in terms of their k-type
  - In the chronicle, this becomes: there exist points in the same equivalence class as x that are arbitrarily close to gamma from the left
  - File: `ChronicleNoGaps.lean`
  - ~50 lines

- [ ] **Task 2.2**: Prove `gap_formula_R_at_chronicle` -- the gap formula R from `US_expressively_complete_over_prior` correctly detects the gap in the chronicle's monadic structure
  - Input: gamma : Gap M.domain, the `chronicleAsMonadicStructure`, the atomMap
  - Output: exists temporal formula R such that `temporal_truth M_struct atomMap_fwd t R <-> chronicle_rho_holds M gamma t`
  - Uses `US_expressively_complete_over_prior` to get R, then `chronicle_temporal_truth_effective` to relate temporal_truth to MCS membership
  - File: `ChronicleNoGaps.lean`
  - ~80 lines

- [ ] **Task 2.3**: Prove `R_first_occurrence_at_chronicle` -- R-intervals in the chronicle have structure governed by Prior-UZ
  - If R holds at t and also at some s > t, then either R holds on all of (t, s), or R has a first occurrence in (t, s) with not-R on the interval before it
  - Uses `chronicle_semantic_prior_UZ` (Transfer.lean:887) and the C5 forward coherence
  - File: `ChronicleNoGaps.lean`
  - ~60 lines

- [ ] **Task 2.4**: Prove `R_interval_open_at_chronicle` -- maximal R-intervals in the chronicle have no first or last element
  - Uses Task 2.3 and the structure of the gap (R is determined by proximity to gamma, which is "open" in the sense that the gap has no boundary point)
  - File: `ChronicleNoGaps.lean`
  - ~60 lines

- [ ] **Task 2.5**: Prove `chronicle_model_surgery` -- replacing a bad R-interval by a single equivalence class preserves temporal truth
  - This is the core lemma. In the MCS setting, "temporal truth" means MCS membership of effective formulas.
  - The surgery replaces a convex subset Q of the domain with a single point p (representative of Q). The claim is that for all formulas psi, `effectiveFormula(..., psi) in M.fmcs p` iff it was in the MCS of the corresponding point in the original interval.
  - The proof goes by induction on formula structure. The Until/Since cases (13 subcases in Reynolds) use the C4/C5 coherence conditions.
  - In the MCS setting, this is simpler than the abstract case because MCS membership directly gives formula truth.
  - File: `ChronicleNoGaps.lean`
  - ~200 lines (the Until/Since case analysis is the bulk)

- [ ] **Task 2.6**: Prove `chronicle_no_gaps` -- the main theorem
  - Statement: `theorem chronicle_no_gaps (M : ChronicleAsPriorModel fc) : IsEmpty (Gap M.domain)`
  - Proof: by contradiction. Assume gamma : Gap M.domain. Construct gap formula R (Task 2.2). Show R-intervals are open (Task 2.4). Apply model surgery (Task 2.5) to get a contradiction. Conclude no gaps.
  - File: `ChronicleNoGaps.lean`
  - ~40 lines

- [ ] **Task 2.7**: Derive `chronicle_succ_archimedean` from `chronicle_no_gaps`
  - Statement: `theorem chronicle_succ_archimedean (M : ChronicleAsPriorModel fc) : IsSuccArchimedean M.domain`
  - Proof: by contradiction. If not archimedean, then by `gap_of_not_succ_archimedean`, a Gap exists. But `chronicle_no_gaps` says no gaps. Contradiction.
  - File: `ChronicleNoGaps.lean`
  - ~15 lines

**Timing**: 8 hours

**Depends on**: 1

**Files to modify/create**:
- `Theories/Bimodal/Metalogic/WeakCanonical/ChronicleNoGaps.lean` (EXTEND from Phase 1)

**Verification**:
- `#print axioms chronicle_no_gaps` shows no `sorryAx`
- `#print axioms chronicle_succ_archimedean` shows no `sorryAx`
- `lake build Bimodal.Metalogic.WeakCanonical.ChronicleNoGaps` succeeds
- No sorry sites in ChronicleNoGaps.lean

---

### Phase 3: Close succ_cofinal and Verify completeness_discrete [NOT STARTED]

**Goal**: Use `chronicle_succ_archimedean` to close the `succ_cofinal` sorry in ChronicleToCountermodel.lean, then verify `completeness_discrete` is sorry-free.

**Approach**: There are two options for closing `succ_cofinal`:

**Option A (preferred -- minimal changes)**: Prove `succ_cofinal` directly inside ChronicleToCountermodel.lean by instantiating `chronicle_succ_archimedean` on a locally-constructed `ChronicleAsPriorModel`. The `succ_cofinal` proof has access to all the chronicle construction parameters (`fc`, `A`, `h_mcs`, `h_discrete`). Construct a `ChronicleAsPriorModel` from these (mirroring `extract_chronicle_as_prior` but leaving `domain_succ_archimedean` unfilled initially), apply `chronicle_succ_archimedean` to get `IsSuccArchimedean`, then derive `succ_cofinal` from the `IsSuccArchimedean` instance.

**Option B (if Option A has circular dependency issues)**: Add `chronicle_succ_archimedean` as a new parameter to `limitDomSubtype_isSuccArchimedean`, breaking the current dependency on `succ_cofinal`. Or modify `extract_chronicle_as_prior` to use `chronicle_succ_archimedean` instead of `limitDomSubtype_isSuccArchimedean`.

**Tasks**:
- [ ] **Task 3.1**: Close the `succ_cofinal` sorry (ChronicleToCountermodel.lean:1497-1510)
  - Inside `succ_cofinal`, construct a `ChronicleAsPriorModel` from the available parameters: `fc`, `A`, `h_mcs`, `h_discrete` (these are exactly the parameters of `extract_chronicle_as_prior`, minus `domain_succ_archimedean`)
  - The construction needs: `domain := LimitDomSubtype fc A h_mcs`, all the typeclass instances (already available in scope), `fmcs := fun t => limit_f fc A h_mcs t.val`, etc.
  - CRITICAL: The `ChronicleAsPriorModel` structure has a `domain_succ_archimedean` field. This is circular if we try to construct a full `ChronicleAsPriorModel` inside `succ_cofinal`. Resolution options:
    - (a) Create a `ChronicleAsPriorModelPartial` structure without the `domain_succ_archimedean` field, prove `chronicle_no_gaps` on that, then derive `IsSuccArchimedean`. This requires refactoring `ChronicleAsPriorModel`.
    - (b) Prove `chronicle_no_gaps` with explicit parameters (not bundled in a structure) matching the chronicle's properties. The function takes `domain`, `fmcs`, `fmcs_is_mcs`, `prior_UZ_valid`, `prior_SZ_valid`, `until_coherent_fwd`, etc. as separate arguments.
    - (c) Use the existing `chronicleAsMonadicStructure` directly (which does not require `IsSuccArchimedean`) together with `chronicle_semantic_prior_UZ/SZ` and the gap-elimination argument.
  - Approach (c) is cleanest: `chronicle_no_gaps` should take a `chronicleAsMonadicStructure` (which has carrier = M.domain but does NOT require IsSuccArchimedean) plus the MCS-level Prior-UZ/SZ and coherence conditions as separate hypotheses. Then `succ_cofinal` instantiates this.
  - Actually, the simplest approach: prove `chronicle_no_gaps` directly on `LimitDomSubtype` using the chronicle's properties (limit_f, limit_c0, prior_UZ_in_limit_domain, etc.) without going through `ChronicleAsPriorModel` at all. This avoids the circularity entirely.
  - File: `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean`, lines 1497-1510
  - ~20 lines (call to new theorem from ChronicleNoGaps.lean)

- [ ] **Task 3.2**: Verify `limitDomSubtype_isSuccArchimedean` is now sorry-free
  - `limitDomSubtype_isSuccArchimedean` (line 1517) calls `succ_cofinal`. Once `succ_cofinal` is sorry-free, this is automatic.
  - `#print axioms limitDomSubtype_isSuccArchimedean` -- should show no `sorryAx`

- [ ] **Task 3.3**: Verify `succ_embed_surjective` is now sorry-free
  - `succ_embed_surjective` (line 2441) depends on `limitDomSubtype_isSuccArchimedean`
  - `#print axioms succ_embed_surjective` -- should show no `sorryAx`

- [ ] **Task 3.4**: Verify `dd_countermodel_chronicle_discrete` is now sorry-free
  - `dd_countermodel_chronicle_discrete` (line 2909) depends on `succ_embed_surjective`
  - `#print axioms dd_countermodel_chronicle_discrete` -- should show no `sorryAx`

- [ ] **Task 3.5**: Verify `countermodel_discrete_enriched` (Completeness.lean:222) is sorry-free
  - `countermodel_discrete_enriched` depends on `dd_countermodel_chronicle_discrete`
  - `#print axioms countermodel_discrete_enriched` -- should show no `sorryAx`

- [ ] **Task 3.6**: Full build verification
  - `lake build` -- full project, zero errors
  - `#print axioms completeness_discrete` -- no `sorryAx`
  - `grep -r "sorry" Theories/Bimodal/Metalogic/WeakCanonical/ChronicleNoGaps.lean` -- no sorry
  - `grep -c "sorry" Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` -- verify `succ_cofinal` sorry is gone
  - Existing dense completeness path unaffected (`#print axioms completeness_dense` unchanged)

**Timing**: 2 hours

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` -- close `succ_cofinal` sorry
- Possibly `Theories/Bimodal/Metalogic/WeakCanonical/ChronicleNoGaps.lean` -- adjust theorem signatures if circularity issues arise

**Verification**:
- `#print axioms succ_cofinal` or equivalent shows no `sorryAx`
- `#print axioms succ_embed_surjective` shows no `sorryAx`
- `#print axioms countermodel_discrete_enriched` shows no `sorryAx`
- `#print axioms completeness_discrete` shows no `sorryAx`
- `lake build` passes with zero errors
- No new sorry sites in any modified files

## Testing & Validation

- [x] Phase 0: `lake build` passes after cleanup (plan v10, completed)
- [x] `#print axioms US_expressively_complete_over_prior` shows no `sorryAx` (Phase 1 from plan v10, completed)
- [ ] `no_gaps_prior` has deprecation comment (Phase 1, Task 1.1)
- [ ] `ChronicleNoGaps.lean` created with module structure (Phase 1, Task 1.2)
- [ ] `#print axioms chronicle_no_gaps` shows no `sorryAx` (Phase 2)
- [ ] `#print axioms chronicle_succ_archimedean` shows no `sorryAx` (Phase 2)
- [ ] `#print axioms succ_cofinal` shows no `sorryAx` (Phase 3)
- [ ] `#print axioms succ_embed_surjective` shows no `sorryAx` (Phase 3)
- [ ] `#print axioms countermodel_discrete_enriched` shows no `sorryAx` (Phase 3)
- [ ] `#print axioms completeness_discrete` shows no `sorryAx` (Phase 3)
- [ ] `lake build` passes with zero errors (Phase 3)
- [ ] No new sorry sites introduced (grep across all modified/created files)
- [ ] Existing dense completeness path unaffected (`#print axioms completeness_dense` unchanged)

## Artifacts & Outputs

- `specs/202_reynolds_k_equivalence_bypass/plans/10_chronicle-level-plan.md` (this plan)
- `Boneyard/DeadConvergenceProof/succ_cofinal_convergence.lean` (EXISTING, Phase 0 from plan v10) -- archived dead proof
- `Theories/Bimodal/Metalogic/WeakCanonical/PriorExpressiveness.lean` (EXISTING, 395 lines) -- Theorem 5 (Phase 1 from plan v10, completed)
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/ReynoldsNoGaps.lean` (MODIFY) -- deprecation comments on `no_gaps_prior`
- `Theories/Bimodal/Metalogic/WeakCanonical/ChronicleNoGaps.lean` (NEW, ~500 lines) -- chronicle-level no-gaps proof
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` (MODIFY) -- close `succ_cofinal` sorry

## Rollback/Contingency

Phase 1 is non-destructive (adds comments and a new file). Phase 2 is self-contained in the new `ChronicleNoGaps.lean` file. Phase 3 modifies `ChronicleToCountermodel.lean` to close `succ_cofinal`. Reverting any phase restores the previous sorry state.

**Phase 2 contingencies**:
1. **If model surgery case analysis for Until/Since exceeds 200 lines**: Break into individual lemmas per case. The MCS setting should simplify most cases since the C4/C5 coherence conditions directly give the needed witnesses.
2. **If the gap formula R construction is difficult**: Use the alternative direct argument (see Phase 2 mathematical argument, point 5): the LAST-occurrence property from Prior-SZ contradicts the gap structure directly, without constructing an explicit gap formula. This may be shorter (~150 lines) but requires careful handling of the cut/complement boundary.
3. **If `US_expressively_complete_over_prior` is hard to apply at the chronicle level**: The key is that `chronicle_semantic_prior_UZ/SZ` (Transfer.lean) already provides exactly the semantic Prior-UZ/SZ hypotheses that `US_expressively_complete_over_prior` needs. The `chronicleAsMonadicStructure` provides the `OrderedMonadicStructure`. The connection should be direct.

**Phase 3 contingencies**:
1. **If circularity with `ChronicleAsPriorModel.domain_succ_archimedean` arises**: Prove `chronicle_no_gaps` taking explicit parameters (not a bundled structure) matching the raw chronicle properties from ChronicleToCountermodel.lean. The `succ_cofinal` proof passes `LimitDomSubtype`, `limit_f`, `limit_c0`, `prior_UZ_in_limit_domain`, etc. directly.
2. **If `extract_chronicle_as_prior` needs modification**: Only change it AFTER `succ_cofinal` is proved. Update `domain_succ_archimedean` to use `chronicle_succ_archimedean` instead of `limitDomSubtype_isSuccArchimedean` as a cleanup step.

**Fallback path (Path A from blocker handoff)**: If Path B fails, add a faithfulness hypothesis to `no_gaps_prior` and prove the corrected version. The chronicle satisfies faithfulness via `chronicle_temporal_truth_effective`. This is 600-1000 lines but follows the original plan v10 structure.
