# Implementation Plan: Reynolds Pipeline Pivot -- no_gaps_discrete via Model Surgery (v13)

- **Task**: 202 - Reynolds k-equivalence bypass for sorry-free completeness_discrete
- **Status**: [NOT STARTED]
- **Effort**: 10 hours
- **Dependencies**: None
- **Research Inputs**: specs/202_reynolds_k_equivalence_bypass/reports/05_reynolds-theorem-14-research.md, specs/202_reynolds_k_equivalence_bypass/reports/13_blocker-analysis-correct-path.md, specs/202_reynolds_k_equivalence_bypass/handoffs/phase-2-blocked-counterexample-20260530.md, literature/Reynolds_1994_Axiomatising_U_and_S_over_integer_time.md (Sections 6-7, Lemmas 6-13, Theorem 14)
- **Artifacts**: plans/13_reynolds-pipeline-pivot.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

---

> **CRITICAL PIVOT -- READ BEFORE ANY WORK**:
>
> Plan v13 ABANDONS the BX pipeline approach (Path A) that was blocked
> because `no_gaps_faithful` is mathematically FALSE (Z+Z counterexample).
>
> Plan v13 PIVOTS to the Reynolds pipeline (Path B), which requires proving
> `no_gaps_discrete` in GoodStructures.lean -- a DIFFERENT theorem that IS
> provable. The key distinction:
>
> - `no_gaps_faithful` (FALSE): "no Dedekind gaps in any PriorModelData"
> - `no_gaps_discrete` (TRUE): "~M-class boundaries don't occur at gaps in
>   ordered monadic structures with semantic Prior-UZ/SZ"
>
> **Pipeline structure** (v13, Reynolds pipeline):
> ```
> no_gaps_discrete (GoodStructures.lean:843 -- the sorry to close)
>   -> one_class (GoodStructures.lean:884 -- sorry-free given no_gaps_discrete)
>     -> one_class_implies_very_good (ShiftAndGlue.lean:918 -- sorry-free)
>       -> very_good_implies_good (sorry-free)
>         -> chronicle_is_good_direct (ShiftAndGlue.lean:949 -- sorry-free given one_class)
>           -> countermodel_discrete_reynolds (Transfer.lean:1020 -- sorry-free given good)
>             -> completeness_discrete (rewired in Completeness.lean:309)
> ```
>
> `US_expressively_complete_over_prior` (Theorem 5) is already sorry-free
> in PriorExpressiveness.lean. Phase 1 is COMPLETED and preserved.

---

## Overview

Plan v13 resolves the sole remaining sorry blocking sorry-free `completeness_discrete`
by pivoting from the BX pipeline (Path A, BROKEN) to the Reynolds pipeline (Path B,
CORRECT). The sorry target is `no_gaps_discrete` at GoodStructures.lean:843,
which states that contemporaneous equivalence class boundaries cannot occur at
Dedekind gaps in ordered monadic structures satisfying semantic Prior-UZ/SZ.

Plan v12 Phase 2 was blocked because `no_gaps_faithful` (ReynoldsModelSurgery.lean:310)
is mathematically false: the Z+Z counterexample (two copies of Z with constant MCS)
satisfies all PriorModelData hypotheses yet has a Dedekind gap. The gap is non-definable
(no temporal formula detects it), which is precisely Reynolds' Theorem 5 in action.

The correct theorem `no_gaps_discrete` operates at the `OrderedMonadicStructure` level
(temporal/semantic), not the `PriorModelData` level (MCS/syntactic). It does NOT claim
gaps are impossible -- it claims equivalence class boundaries cannot occur at gaps.
In Z+Z with constant MCS, all points are in ONE equivalence class (trivially), so there
are no class boundaries at all; the theorem is vacuously satisfied.

The Reynolds pipeline Path B is already wired in Transfer.lean:
`countermodel_discrete_reynolds` calls `chronicle_is_good_direct`, which calls
`one_class`, which calls `no_gaps_discrete`. Once `no_gaps_discrete` is proved,
the entire pipeline becomes sorry-free. All that remains is:
1. Prove `no_gaps_discrete` via Reynolds Lemmas 6-13 + Theorem 14
2. Fix the sorry in `countermodel_discrete_reynolds` at Transfer.lean:1097
3. Rewire `completeness_discrete` to use the Reynolds pipeline
4. Mark BX pipeline artifacts as deprecated

### Research Integration

- `reports/01_reynolds-bypass-research.md` (plan v1): Initial infrastructure survey.
- `reports/05_reynolds-theorem-14-research.md` (plan v6): Mapped the full dependency chain.
- `reports/07_bfmcs-bypass-research.md` (plan v8): Confirmed BFMCS sorry-free; Reynolds pipeline correct.
- `reports/08_succ-cofinal-dependency-trace.md` (plan v8): Full dependency trace.
- `reports/12_deviation-analysis.md` (plan v10): Phase 2 restructuring assessment.
- `handoffs/phase-2-blocked-20260529.md` (plan v11): Blocker analysis showing `no_gaps_prior` is false.
- `reports/13_blocker-analysis-correct-path.md` (plan v13): Identifies Path B (Reynolds pipeline) as correct path, `no_gaps_discrete` as the actual sorry target, model surgery operates at `OrderedMonadicStructure` level.
- `handoffs/phase-2-blocked-counterexample-20260530.md` (plan v13): Z+Z counterexample for `no_gaps_faithful`, h_fc propagation completed, detailed correct-path analysis.
- `literature/Reynolds_1994_Axiomatising_U_and_S_over_integer_time.md`: Sections 6-7, Lemmas 6-13, Theorem 14.

### Prior Plan Reference

Plans v1-v5 attempted direct approaches. Plan v6 took the Reynolds Theorem 14 route.
Plans v7-v8 refined the pipeline. Plan v9 added dead code cleanup. Plan v10 merged
Phases 2-4. Plan v11 attempted chronicle-level proof via Prior-SZ contradiction but
was blocked: abstract MCS axioms insufficient (Z+Z counterexample). Plan v12 attempted
full Reynolds model surgery at the `PriorModelData` (MCS) level -- BLOCKED because
`no_gaps_faithful` is FALSE. Plan v13 pivots to the correct target: `no_gaps_discrete`
at the `OrderedMonadicStructure` (semantic/temporal) level.

## Goals & Non-Goals

**Goals**:
- Close `no_gaps_discrete` sorry at GoodStructures.lean:843 via Reynolds Lemmas 6-13 + Theorem 14
- Fix the remaining sorry in `countermodel_discrete_reynolds` at Transfer.lean:1097
- Rewire `completeness_discrete` to use Reynolds pipeline (countermodel_discrete_reynolds)
- Verify `completeness_discrete` has no `sorryAx`
- Deprecate BX pipeline artifacts (`no_gaps_faithful`, `prior_model_is_succ_archimedean`, `chronicle_gap_contradiction`)

**Non-Goals**:
- Fixing `no_gaps_faithful` (proven FALSE, abandoned)
- Proving `chronicle_gap_contradiction` (BX pipeline, dead code after rewire)
- Modifying the dense completeness path
- Closing the `countermodel_discrete` sorry at Transfer.lean:1116 (Base frame class, not Discrete)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Model surgery lemmas (12-13) are complex at the semantic level, requiring formula induction with 7 U(A,B) subcases | H | M | `OrderedMonadicStructure` has clean `temporal_truth` induction. Follow Reynolds exactly. Each subcase is independent. |
| Gap formula R construction requires instantiating `US_expressively_complete_over_prior` with the right monadic predicate | M | L | The gap-boundary predicate is a monadic 1-predicate (characteristic function of a set). `mkSigFrom` infrastructure in Transfer.lean already handles this pattern. |
| `countermodel_discrete_reynolds` has a second sorry at Transfer.lean:1097 beyond `no_gaps_discrete` | H | M | The sorry is for packaging the Z-interval as a TaskFrame. This is engineering (subtype construction + truth correspondence), not a mathematical blocker. |
| Rewiring `completeness_discrete` may break other theorems that import from Completeness.lean | L | L | `completeness_discrete` is a leaf theorem -- nothing depends on it downstream. The BX pipeline functions remain importable for non-discrete uses. |
| Model surgery proof may exceed 500 lines | M | M | Structured as 8 separate lemmas. Each is 30-100 lines. If needed, create a new file `GoodStructuresModelSurgery.lean` imported by GoodStructures.lean. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3, 4 | 2 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Reynolds Model Surgery for no_gaps_discrete (Lemmas 6-13 + Theorem 14) [BLOCKED]

**Goal**: Close the sorry at GoodStructures.lean:843 by proving `no_gaps_discrete` using
Reynolds' model surgery argument adapted to the `OrderedMonadicStructure` level.

**BLOCKER** (Phase 1):
- **What failed**: The existing `no_gaps_discrete` signature (GoodStructures.lean:820) is MISSING a predicate accessibility hypothesis. Without it, the theorem is **mathematically FALSE**.
- **What was tried**: (1) Attempted direct proof via Prior-UZ contradiction with gap structure. (2) Attempted to use `US_expressively_complete_over_prior` but it requires `h_surj` which the current signature doesn't provide. (3) Analyzed the call chain to see if `h_surj` could be added.
- **Why it's stuck**: Counterexample proves theorem false as stated: M = Z+Z with sig having two predicates, one constant and accessible, one differing across gap but inaccessible via atomMap. Prior-UZ/SZ trivially satisfied (all temporal formulas constant). Class boundary at gap with no successor boundary. The existing theorem signature allows this scenario.
- **What is needed**: Add `h_accessible : all_predicates_accessible M atomMap` (or equivalently `h_surj`) to `no_gaps_discrete`, `one_class`, and all downstream callers. The condition IS satisfied at the actual call site in Transfer.lean. Then prove the theorem using the accessibility condition.
- **Prohibited workarounds**: Do NOT use `sorry`, `def X := True`, or any vacuous placeholder.
- **Infrastructure completed**: `GoodStructuresModelSurgery.lean` created with helper lemmas (prior_UZ_first_transition, contemp_equiv_convex, contemp_equiv_pred_closed, contemp_equiv_succ_iterate, class_gap_exists, predicate_accessible definitions).

Unlike plan v12 which worked at the `PriorModelData` (MCS) level and proved the FALSE
theorem `no_gaps_faithful`, this phase works at the `OrderedMonadicStructure` level
with `temporal_truth` semantics and proves the TRUE theorem `no_gaps_discrete`.

**Key distinction**: `no_gaps_discrete` does NOT claim gaps are impossible. It claims
that if `a` and `b` are in different `contemp_equiv` classes, then there exists a
boundary at a successor pair (not at a gap). The proof is by contradiction: assume the
only boundary is at a gap, then apply model surgery to derive a contradiction.

**New file**: `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/GoodStructuresModelSurgery.lean`

**Imports**:
- `Bimodal.Metalogic.WeakCanonical.PriorExpressiveness` (for `US_expressively_complete_over_prior`)
- `Bimodal.Metalogic.WeakCanonical.IntegerModel.GoodStructures` (for `contemp_equiv`, `no_boundary_at_successor`)
- `Bimodal.Metalogic.WeakCanonical.EFGames.Defs` (for `Gap`, `gap_cut_succ_closed`)
- `Bimodal.Metalogic.WeakCanonical.NEquivalence` (for `temporal_truth`, `OrderedMonadicStructure`)

**Mathematical argument** (following Reynolds 1994, pp.124-129, adapted to semantic level):

The proof eliminates the possibility of class boundaries at gaps by contradiction.
Assume `a` and `b` are in different `contemp_equiv` classes but there is NO successor
pair where the class boundary falls. Then the boundary must fall at a Dedekind gap.

*Lemma 6 -- Gap formula R*: The predicate rho(x) = "x's ~M-class has a right gap
boundary" is a monadic predicate over M. By `US_expressively_complete_over_prior`,
there exists a temporal formula R equivalent to rho on any structure satisfying
semantic Prior-UZ/SZ. R holds at t iff `temporal_truth M atomMap t R` is true.

*Lemma 7 -- R-interval structure*: Maximal intervals where R holds are open with
excluded endpoints (using Prior-UZ/SZ for the boundary structure).

*Lemma 8 -- No first/last class*: No first or last ~M-class in any maximal R-interval.

*Lemma 9 -- Class homogeneity*: All ~M-classes in a maximal R-interval are
elementarily equivalent (monadic FO theory agreement).

*Lemma 10 -- Bad intervals*: Define "bad point" = R or L (left-gap analogue). Bad
points occur in non-singleton intervals where both R and L hold throughout.

*Lemma 11 -- Formula propagation*: In bad intervals, if a formula holds at the start
of a class, it holds throughout the bad interval.

*Lemma 12 -- Model surgery*: Replace a bad interval Q0 by one of its ~M-classes I.
The surgery model N has domain Q_minus union I union Q_plus (subtype of M.carrier).
N inherits the order and predicate interpretation from M. Prove temporal_truth is
preserved by structural induction on formulas.

*Lemma 13 + Theorem 14 -- Contradiction*: R holds in I in N. But I is bounded in N
(Q_plus is nonempty). The class containing I in N ends at the first point of Q_plus,
not at a gap. Contradiction with R saying the class ends at a gap.

**Tasks**:
- [x] **Task 1.1**: Create `GoodStructuresModelSurgery.lean` with imports and module docstring (~20 lines) *(deviation: altered -- file created with helper lemmas and infrastructure but no main proof due to blocker)*
  - Define the contemporaneous equivalence class boundary predicates at the semantic level
  - These operate on `OrderedMonadicStructure` with `temporal_truth`, NOT on MCS assignments
  - File: `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/GoodStructuresModelSurgery.lean`

- [ ] **Task 1.2**: Gap formula R construction (Lemma 6) (~60 lines) *(deviation: deferred -- requires fixing no_gaps_discrete signature first)*
  - Given a gap gamma in `M.carrier`, define the monadic FO formula rho(x) characterizing
    "x's ~M-class has gamma as a right boundary"
  - Apply `US_expressively_complete_over_prior` to obtain temporal formula R
  - Prove `R_holds_iff_right_gap_class`: R holds at t (via temporal_truth) iff t's
    contemp_equiv class has the gap as its right boundary
  - Note: this uses the SEMANTIC Prior-UZ/SZ hypotheses (h_prior_UZ, h_prior_SZ) that
    are parameters of `no_gaps_discrete`, matching the type signature at GoodStructures.lean:825-832
  - File: `GoodStructuresModelSurgery.lean`

- [ ] **Task 1.3**: R-interval properties (Lemma 7) (~80 lines)
  - Prove maximal R-intervals are open with excluded endpoints
  - If R holds at t, R holds at succ(t) (by `gap_cut_succ_closed` -- successor stays in cut)
  - If R eventually fails: apply Prior-UZ to get first not-R point (excluded endpoint)
  - Left boundary: apply Prior-SZ symmetrically
  - File: `GoodStructuresModelSurgery.lean`

- [ ] **Task 1.4**: No first/last class and class homogeneity (Lemmas 8-9) (~80 lines)
  - Lemma 8: No first/last ~M-class in any maximal R-interval
    - Last class: would end at the R-interval boundary, not at a gap
    - First class: use expressive completeness argument with Prior-UZ
  - Lemma 9: All classes in a maximal R-interval are elementarily equivalent
    - If formula A holds in one class but not another: define B = "A occurs in my class"
    - B holds throughout one class, fails in another. Prior-UZ gives impossible boundary.
  - File: `GoodStructuresModelSurgery.lean`

- [ ] **Task 1.5**: Bad intervals and formula propagation (Lemmas 10-11) (~80 lines)
  - Lemma 10: Define "bad point" = R or L. Bad intervals are non-singleton with both R and L.
  - Lemma 11: Formula propagation in bad intervals
    - B holds for a while at the start of a class -> B holds throughout the bad interval
    - Proof by contradiction using expressive completeness + Prior-UZ
  - File: `GoodStructuresModelSurgery.lean`

- [ ] **Task 1.6**: Model surgery construction (Lemma 12) (~150 lines)
  - Define surgery domain: Q_minus union I union Q_plus as subtype of M.carrier
  - Construct `OrderedMonadicStructure` on the surgery domain inheriting from M
  - Prove temporal_truth preservation by structural induction on formulas:
    - Atom, bot, imp cases: immediate from predicate interpretation preservation
    - Box case: not applicable (no box in ordered monadic structures)
    - U(A,B) forward (M to N): 7 subcases based on position of t, s relative to Q-, I, Q+
    - U(A,B) backward (N to M): 6 subcases
    - S(A,B): mirror of U(A,B)
  - File: `GoodStructuresModelSurgery.lean`

- [ ] **Task 1.7**: Contradiction and main theorem (Lemma 13 + Theorem 14) (~60 lines)
  - Lemma 13: R holds in I in N. N is a Prior structure. I is bounded in N.
    The class ends before the start of Q_plus, not at a gap. Contradiction.
  - Theorem 14: `no_gaps_discrete_model_surgery`
    - Statement: matches the type signature of `no_gaps_discrete` in GoodStructures.lean:820-835
    - Proof: by contradiction. Assume ¬contemp_equiv. Assume the only boundary is at a
      gap (contrapositives of no_boundary_at_successor). Construct R (Lemma 6). Find bad
      interval (Lemma 10). Apply model surgery (Lemma 12). Derive contradiction (Lemma 13).
  - File: `GoodStructuresModelSurgery.lean`

- [ ] **Task 1.8**: Wire into GoodStructures.lean (~10 lines)
  - Import `GoodStructuresModelSurgery` in `GoodStructures.lean`
  - Replace sorry at line 843 with call to `no_gaps_discrete_model_surgery`
  - Ensure the theorem signature matches exactly (sig, k, M, atomMap, h_prior_UZ, h_prior_SZ, a, b, h_diff_class)
  - File: `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/GoodStructures.lean`

**Timing**: 6 hours

**Depends on**: none

**Files to create**:
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/GoodStructuresModelSurgery.lean` (NEW, ~500 lines)

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/GoodStructures.lean` (replace sorry at line 843)

**Verification**:
- `lake build Bimodal.Metalogic.WeakCanonical.IntegerModel.GoodStructures` succeeds
- `#print axioms no_gaps_discrete` shows no `sorryAx`
- `#print axioms one_class` shows no `sorryAx`
- `#print axioms chronicle_is_good_direct` shows no `sorryAx`
- No sorry sites in GoodStructuresModelSurgery.lean (grep)

---

### Phase 2: Fix countermodel_discrete_reynolds Packaging Sorry [NOT STARTED]

**Goal**: Close the remaining sorry in `countermodel_discrete_reynolds` at Transfer.lean:1097.
This sorry is for packaging the Z-interval witness as a TaskFrame Int countermodel
(Steps 7-8 of the Reynolds pipeline). This is engineering work, not a mathematical blocker.

**Context**: After Phase 1, the pipeline from `no_gaps_discrete` through
`chronicle_is_good_direct` produces a `good` certificate (Z-interval with k-equivalence).
The `truth_transfer` lemma already transfers formula truth from the chronicle to the
Z-interval. What remains is constructing the final `TaskFrame Int` + `TaskModel` + truth
correspondence from the Z-interval.

**Tasks**:
- [ ] **Task 2.1**: Analyze Z-interval structure from `good` (~30 min reading)
  - Examine what `good` produces: a `ZIntervalStructure` with `lo` and `hi` bounds
  - Determine if the chronicle's unboundedness (NoMaxOrder, NoMinOrder) guarantees
    `lo = none` and `hi = none` (unbounded Z-interval)
  - If bounded, determine how to handle the TaskFrame construction for bounded intervals

- [ ] **Task 2.2**: Construct TaskFrame Int countermodel from Z-interval (~100 lines)
  - If Z-interval is unbounded: use existing `z_interval_countermodel` or construct directly
  - Map Z-interval structure to `TaskFrame Int` (AddCommGroup Int, LinearOrder, etc.)
  - Construct `TaskModel` with atom valuation from the Z-interval's predicate interpretation
  - Prove truth correspondence: `truth_at TM Omega tau t phi <-> temporal_truth Z atomMap s phi`
    for the corresponding points
  - Replace sorry at Transfer.lean:1097 with the construction

- [ ] **Task 2.3**: Verify Reynolds pipeline is sorry-free
  - `#print axioms countermodel_discrete_reynolds` shows no `sorryAx`

**Timing**: 2 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Transfer.lean` (close sorry at line 1097)

**Verification**:
- `lake build Bimodal.Metalogic.WeakCanonical.Transfer` succeeds
- `#print axioms countermodel_discrete_reynolds` shows no `sorryAx`
- No sorry sites in the countermodel_discrete_reynolds proof (grep)

---

### Phase 3: Rewire completeness_discrete to Reynolds Pipeline [NOT STARTED]

**Goal**: Replace the BX pipeline (`countermodel_discrete_enriched`) with the Reynolds
pipeline (`countermodel_discrete_reynolds`) in `completeness_discrete`.

**Context**: Currently `completeness_discrete` (Completeness.lean:309) calls
`countermodel_discrete_enriched` (line 369), which uses the BX pipeline and carries
the sorry through `succ_cofinal` -> `chronicle_gap_contradiction`. After Phase 2,
`countermodel_discrete_reynolds` will be sorry-free and can replace it.

**Tasks**:
- [ ] **Task 3.1**: Rewire completeness_discrete (~30 lines)
  - In Completeness.lean, replace the discrete case branch (lines 367-369):
    ```lean
    obtain <F, TM, Omega, h_sc, tau, h_mem, t, h_not_true> :=
      countermodel_discrete_enriched M hM_mcs (le_refl _) phi h_neg_in h_box_discrete
    ```
    with a call to `countermodel_discrete_reynolds`:
    ```lean
    obtain <D, h_acg, h_lo, h_oam, h_nt, F, TM, Omega, h_sc, tau, h_mem, t, h_not_true> :=
      countermodel_discrete_reynolds M hM_mcs phi h_neg_in h_box_discrete
    ```
  - Adjust type signature handling: `countermodel_discrete_reynolds` returns a more general
    existential (with D : Type instead of fixing Int). May need to match on the additional
    existentials or adjust the proof term.
  - Add import of Transfer.lean in Completeness.lean if not already present

- [ ] **Task 3.2**: Verify completeness_discrete is sorry-free
  - `#print axioms completeness_discrete` shows no `sorryAx`
  - `lake build Bimodal.Metalogic.BXCanonical.Completeness` succeeds

**Timing**: 1 hour

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` (rewire discrete case)

**Verification**:
- `#print axioms completeness_discrete` shows no `sorryAx`
- `lake build` succeeds (full project)
- `completeness_dense` unaffected (`#print axioms completeness_dense` unchanged)

---

### Phase 4: Deprecate BX Pipeline and Full Verification [NOT STARTED]

**Goal**: Mark BX pipeline components as deprecated (not dead code -- they may be
needed for the Base frame class completeness path). Perform full project verification.

**Tasks**:
- [ ] **Task 4.1**: Deprecate BX pipeline artifacts (~20 lines of comments)
  - Add deprecation comment to `no_gaps_faithful` in ReynoldsModelSurgery.lean:310
    (already has WARNING; strengthen to DEPRECATED with cross-reference to plan v13)
  - Add deprecation comment to `prior_model_is_succ_archimedean` in ReynoldsModelSurgery.lean:323
  - Add deprecation comment to `chronicle_gap_contradiction` in ChronicleToCountermodel.lean
    (note: this function still compiles and is used by the BX pipeline for Base completeness;
    it is only dead for the Discrete case)
  - Update module docstring of ReynoldsModelSurgery.lean to note it is superseded by
    GoodStructuresModelSurgery.lean for the Discrete completeness path

- [ ] **Task 4.2**: Full build verification
  - `lake build` -- full project, zero errors
  - `#print axioms completeness_discrete` -- no `sorryAx`
  - `#print axioms completeness_dense` -- unchanged (no regression)
  - `grep -r "sorry" Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/GoodStructuresModelSurgery.lean` -- no sorry
  - `grep -c "sorry" Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/GoodStructures.lean` -- verify no_gaps_discrete sorry is gone
  - Verify no new sorry sites introduced in any modified file

- [ ] **Task 4.3**: Update sorry audit documentation
  - If axiom audit comments exist in Completeness.lean (lines 377+), update them to reflect
    the new sorry-free status of `completeness_discrete`
  - Note remaining sorries: `countermodel_discrete` (Base frame class, Transfer.lean:1116)
    is still sorry'd -- this is expected and not on the Discrete critical path

**Timing**: 1 hour

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/ReynoldsModelSurgery.lean` (deprecation comments)
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` (deprecation comments)
- `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` (update axiom audit)

**Verification**:
- `lake build` passes with zero errors
- No new sorry sites in any modified files
- Existing dense completeness path unaffected

## Testing & Validation

- [x] Phase 0: `lake build` passes after cleanup (plan v10, completed)
- [x] `#print axioms US_expressively_complete_over_prior` shows no `sorryAx` (Phase 1 from plan v10, completed)
- [x] `no_gaps_prior` has deprecation comment (Phase 1 from plan v11, completed)
- [x] `ChronicleNoGaps.lean` created with module structure (Phase 1 from plan v11, completed)
- [ ] `GoodStructuresModelSurgery.lean` created with Lemmas 6-13 + Theorem 14 (Phase 1)
- [ ] `no_gaps_discrete` sorry closed in GoodStructures.lean:843 (Phase 1)
- [ ] `#print axioms no_gaps_discrete` shows no `sorryAx` (Phase 1)
- [ ] `#print axioms one_class` shows no `sorryAx` (Phase 1)
- [ ] `#print axioms chronicle_is_good_direct` shows no `sorryAx` (Phase 1)
- [ ] `countermodel_discrete_reynolds` sorry closed in Transfer.lean:1097 (Phase 2)
- [ ] `#print axioms countermodel_discrete_reynolds` shows no `sorryAx` (Phase 2)
- [ ] `completeness_discrete` rewired to Reynolds pipeline (Phase 3)
- [ ] `#print axioms completeness_discrete` shows no `sorryAx` (Phase 3)
- [ ] `lake build` passes with zero errors (Phase 4)
- [ ] No new sorry sites introduced (grep across all modified/created files)
- [ ] Existing dense completeness path unaffected (`#print axioms completeness_dense` unchanged)

## Artifacts & Outputs

- `specs/202_reynolds_k_equivalence_bypass/plans/13_reynolds-pipeline-pivot.md` (this plan)
- `Theories/Bimodal/Metalogic/WeakCanonical/PriorExpressiveness.lean` (EXISTING, sorry-free) -- Theorem 5 (Phase 1 from prior plans)
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/GoodStructuresModelSurgery.lean` (NEW, ~500 lines) -- Reynolds Lemmas 6-13 + Theorem 14 at OrderedMonadicStructure level
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/GoodStructures.lean` (MODIFY) -- close `no_gaps_discrete` sorry
- `Theories/Bimodal/Metalogic/WeakCanonical/Transfer.lean` (MODIFY) -- close `countermodel_discrete_reynolds` sorry
- `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` (MODIFY) -- rewire to Reynolds pipeline
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/ReynoldsModelSurgery.lean` (MODIFY) -- deprecation updates

## Rollback/Contingency

Phase 1 creates a new file (`GoodStructuresModelSurgery.lean`) -- deleting it restores
the status quo. The only modification to existing files is replacing the sorry in
GoodStructures.lean:843; reverting this one line restores the previous state.

Phase 2 modifies Transfer.lean to close a sorry. Reverting restores the sorry.

Phase 3 rewires Completeness.lean. Reverting restores the BX pipeline usage.

Phase 4 is pure documentation (deprecation comments). Fully reversible.

**Phase 1 contingencies**:
1. **If model surgery U(A,B) case analysis exceeds 200 lines**: Break into separate
   lemmas per case (`surgery_preserve_untl_Q_minus`, `surgery_preserve_untl_cross`, etc.).
   Each case is independent and can be proved separately.
2. **If the contemporaneous equivalence definition in GoodStructures.lean is not directly
   usable for the gap formula R**: Define a local equivalence relation matching Reynolds'
   definition. The key property: classes are convex and agree on temporal formulas
   evaluated on subintervals. `contemp_equiv` from GoodStructures.lean already captures
   this via k-type agreement on subintervals.
3. **If `US_expressively_complete_over_prior` is hard to instantiate**: Follow the pattern
   of `chronicle_temporal_truth_effective` in Transfer.lean, which already instantiates
   this theorem. The gap formula R requires encoding the gap-boundary predicate as a
   monadic signature predicate.
4. **If `no_gaps_discrete` proof becomes too long (>600 lines)**: Split
   `GoodStructuresModelSurgery.lean` into two files: `GoodStructuresGapFormula.lean`
   (Lemmas 6-9) and `GoodStructuresModelSurgery.lean` (Lemmas 10-13 + Theorem 14).

**Phase 2 contingencies**:
1. **If Z-interval is bounded (lo/hi not none)**: The countermodel construction needs
   adjustment. Use `OrderIso` to map the bounded Z-interval to an interval of Z, then
   embed into a full Z model. Alternatively, modify `z_interval_countermodel` to handle
   bounded intervals.
2. **If truth correspondence is complex**: The `truth_transfer` lemma already handles the
   k-equivalence direction. The remaining work is mapping from `temporal_truth` in the
   Z-interval to `truth_at` in the TaskFrame. This may require an intermediate
   `TruthCorrespondence` structure.

**Fallback path**: If the full Reynolds model surgery proves too complex at the
`OrderedMonadicStructure` level, task 224 (finite insertion argument) provides an
alternative approach to proving `IsSuccArchimedean` for the chronicle limit domain,
which would close `chronicle_gap_contradiction` via the BX pipeline instead.
