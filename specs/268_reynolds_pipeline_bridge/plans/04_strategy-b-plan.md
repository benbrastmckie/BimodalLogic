# Implementation Plan: Strategy B — Reynolds K-Equivalence Bypass

- **Task**: 268 - Reynolds pipeline bridge (Strategy B: k-equivalence bypass)
- **Status**: [NOT STARTED]
- **Effort**: 14 hours
- **Dependencies**: None (sorry-free infrastructure already exists)
- **Research Inputs**: specs/268_reynolds_pipeline_bridge/reports/04_team-research.md, specs/268_reynolds_pipeline_bridge/reports/04_teammate-a-findings.md, specs/268_reynolds_pipeline_bridge/reports/04_teammate-b-findings.md, specs/268_reynolds_pipeline_bridge/reports/04_teammate-c-findings.md, specs/268_reynolds_pipeline_bridge/reports/04_teammate-d-findings.md, specs/268_reynolds_pipeline_bridge/handoffs/phase-2-handoff-20260603.md, specs/268_reynolds_pipeline_bridge/reports/01_bridge-research.md
- **Artifacts**: plans/04_strategy-b-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Refactor the discrete completeness path to follow Reynolds 1994 faithfully: use k-equivalence truth transfer instead of demanding `IsSuccArchimedean` for the chronicle limit domain. The current architecture requires `succ_embed_surjective` (which needs `IsSuccArchimedean`, which needs the unprovable `chronicle_gap_contradiction`). Reynolds never proves the limit domain is Z-isomorphic -- he only needs k-equivalence to a Z-interval via `one_class` -> `very_good` -> `good` (Lemma 16). This plan builds a new `completeness_discrete` proof path that bypasses `succ_embed_surjective` entirely, eliminating the sorry chain at its architectural root.

### Research Integration

Key findings from team research (04_team-research.md, 4 teammates):

1. **Reynolds Theorem 15 is already sorry-free** (Teammate A): The full chain `no_boundary_at_successor` -> `gap_prior_UZ_contradiction` -> `reynolds_model_surgery_core` -> `no_gaps_discrete_model_surgery` -> `one_class` has zero sorry statements. Operates at the `OrderedMonadicStructure` level.

2. **The formalization over-engineers** (Teammate D): Reynolds only needs k-equivalence to Z, not Z-isomorphism. The `IsSuccArchimedean` requirement is an artifact of the BX pipeline's decision to embed directly into Z.

3. **Bypass requires refactoring** (Teammate B): The parametric truth lemma requires `D : Type` with `AddCommGroup`, instantiated as Z. `LimitDomSubtype` cannot serve as D. Therefore, the correct path is NOT to use `LimitDomSubtype` as D, but to extract a Z-interval via k-equivalence (Reynolds Stage 5).

4. **Sorry-free infrastructure available** (Teammate A + D): `one_class` (NoGapsDiscreteProof.lean), `very_good -> good` (ShiftAndGlue.lean), `good` gives k-equiv to Z-interval, `z_interval_countermodel` (Transfer.lean:633). All sorry-free.

5. **Phase 2 blocker diagnosis was correct but aimed wrong** (Teammate A): `gap_contradicts_prior` IS inapplicable to bounded subintervals. The fix is to apply sorry-free machinery to the FULL unbounded structure via k-equivalence.

### Prior Plan Reference

Prior plan `01_implementation-plan.md` attempted to fix the sorry in `chronicle_gap_contradiction` via `gap_contradicts_prior` (model surgery). Phase 2 was blocked because `contemp_equiv` is trivially true for bounded subintervals. Key lesson: the Phase 2 blocker was not a bug but evidence that the entire `IsSuccArchimedean` approach is wrong. Strategy B eliminates the need for `IsSuccArchimedean` entirely.

### Roadmap Alignment

This plan advances the critical path item in `specs/ROADMAP.md`: "sorry-free `completeness_discrete`" by implementing the Reynolds k-equivalence bypass recommended in the ROADMAP WARNING. Task 155 depends on task 268, and task 95 (completeness verification audit) depends on task 155.

## Goals & Non-Goals

**Goals**:
- Build `LimitDomSubtype` as an `OrderedMonadicStructure` with Prior-UZ/SZ
- Apply the sorry-free Reynolds pipeline (`one_class` -> `very_good` -> `good`)
- Extract a k-equivalent Z-interval structure
- Build a new `countermodel_discrete_reynolds_v2` that uses k-equivalence truth transfer
- Wire into `completeness_discrete` to eliminate sorryAx
- Mark bypassed sorry chain as dead code

**Non-Goals**:
- Proving `IsSuccArchimedean` for `LimitDomSubtype` (this is the wrong approach)
- Fixing `chronicle_gap_contradiction` (bypassed entirely)
- Rewriting the Chronicle module architecture (task 176)
- Eliminating non-critical-path sorries in NEquivalence.lean or StaviCompleteness.lean
- Archiving the BXCanonical subtree (task 176)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `semantic_prior_UZ/SZ` proof on `LimitDomSubtype` is harder than expected | H | M | Commented-out code at ChronicleToCountermodel.lean:488-762 provides 80% of the machinery. Transfer.lean pattern is well-established. |
| `one_class` requires import not currently available in ChronicleToCountermodel.lean | M | M | `one_class` is in NoGapsDiscreteProof.lean. ChronicleToCountermodel imports GoodStructuresModelSurgery but NOT NoGapsDiscreteProof. Create new file or add import. NoGapsDiscreteProof has no downstream that would create a cycle. |
| `very_good -> good` (ShiftAndGlue) requires `Countable` instance | M | L | `LimitDomSubtype` is a subtype of Q (countable). Countable instance should be derivable. |
| `good` gives k-equiv to Z-interval but `z_interval_countermodel` expects specific packaging | H | M | Transfer.lean:633 `z_interval_countermodel` exists. Need to verify it takes a Z-interval + truth correspondence and returns the existential package matching `completeness_discrete`. |
| `h_truth_corr` (truth correspondence between chronicle and Z-interval) is non-trivial | H | M | K-equivalence preserves all sentences up to quantifier depth k. The table sentence `exists t. table(A_0)(t)` has bounded depth. Build `h_truth_corr` by composing k-equiv with the effective formula correspondence. |
| `effectiveFormula` mapping between chronicle MCS and monadic predicates is complex | M | M | Transfer.lean already has `mkSigFrom` and `mkAtomMapFwd` for enriched signatures. Adapt or reuse. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5 | 4 |

Phases within the same wave can execute in parallel.

---

### Phase 1: LimitDomSubtype as OrderedMonadicStructure [NOT STARTED]

**Goal**: Wrap the chronicle's limit domain as an `OrderedMonadicStructure` and prove it satisfies the preconditions for model surgery (`semantic_prior_UZ`, `semantic_prior_SZ`).

**Tasks**:
- [ ] Create new file `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/ReynoldsBridge.lean` that imports both `ChronicleToCountermodelBasic` (for `LimitDomSubtype`, `limit_dom`, `limit_f`, `limit_satisfies_c5_strong`, `limit_satisfies_c4`) and `NoGapsDiscreteProof` (for `one_class`), plus `ShiftAndGlue` (for `very_good -> good`), and `Transfer` (for truth-transfer infrastructure)
- [ ] Verify no import cycle: `ReynoldsBridge` imports `NoGapsDiscreteProof` (which imports `GoodStructuresModelSurgery`), and `ChronicleToCountermodelBasic` (which does NOT import `GoodStructuresModelSurgery` -- only `ChronicleToCountermodel` imports it). Check the actual import graph to confirm no cycle.
- [ ] Define `chronicle_monadic_structure`: Build `OrderedMonadicStructure sig` on `LimitDomSubtype` where `sig` uses `mkSigFrom phi` (the enriched signature from Transfer.lean) and `interp p x := effectiveFormula_membership p (limit_f x.val)`. Provide `SuccOrder`, `PredOrder`, `NoMaxOrder`, `NoMinOrder` instances (all already exist for `LimitDomSubtype` in the discrete case).
- [ ] Define `chronicle_atomMap`: Use `mkAtomMapFwd phi` from Transfer.lean, mapping formulas to signature predicates.
- [ ] Prove `chronicle_h_surj`: `forall p : sig.preds, exists a : Atom, chronicle_atomMap (.atom a) = p`. Use `mkAtomMapFwd_surj` from Transfer.lean.
- [ ] Prove `chronicle_temporal_truth_corr`: For each `t : LimitDomSubtype`, `temporal_truth M chronicle_atomMap t psi <-> effectiveFormula sig chronicle_atomMap psi in limit_f t.val`. This is the key bridge lemma. Prove by structural induction on formulas, using:
  - Atoms: by definition of `interp`
  - Bot: trivially false on both sides
  - Imp: by MCS negation-completeness of `limit_f`
  - Box: by the chronicle's S5 transfer (all worlds share the same modal class)
  - Until: forward direction uses `limit_satisfies_c5_strong` (the C5 property gives Until witnesses in `limit_dom`); backward uses MCS closure of `limit_f`
  - Since: symmetric, using `limit_satisfies_c4`
- [ ] Prove `chronicle_semantic_prior_UZ`: For all `t : LimitDomSubtype` and `psi : Formula`, the Prior-UZ semantic condition holds. Proof: from `temporal_truth_corr`, reduce to showing that if `F(eff(psi)) in limit_f(t.val)`, then `U(eff(psi), neg(eff(psi))) in limit_f(t.val)`. This follows from the Prior-UZ axiom being in the MCS: `prior_UZ(eff(psi)) in limit_f(t.val)` (since all MCS in the discrete case contain `box(next_top)`, making them discrete MCS with Prior-UZ as a theorem).
- [ ] Prove `chronicle_semantic_prior_SZ`: Symmetric to Prior-UZ using `limit_satisfies_c4` and the Prior-SZ axiom.

**Timing**: 4 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/ReynoldsBridge.lean` (NEW) -- core bridge file

**Verification**:
- `lake build Bimodal.Metalogic.WeakCanonical.IntegerModel.ReynoldsBridge` compiles with zero errors
- `chronicle_monadic_structure`, `chronicle_semantic_prior_UZ`, `chronicle_semantic_prior_SZ` are sorry-free
- `chronicle_temporal_truth_corr` is sorry-free

---

### Phase 2: Apply Reynolds Pipeline to LimitDomSubtype [NOT STARTED]

**Goal**: Apply the sorry-free Reynolds pipeline (`one_class` -> `very_good` -> `good`) to the wrapped `LimitDomSubtype` structure to extract a k-equivalent Z-interval.

**Tasks**:
- [ ] Apply `one_class` (from NoGapsDiscreteProof.lean) to `chronicle_monadic_structure` using `chronicle_h_surj`, `chronicle_semantic_prior_UZ`, `chronicle_semantic_prior_SZ`. Result: `forall (a b : LimitDomSubtype), contemp_equiv sig k M a b`.
- [ ] Derive `very_good`: From `one_class` (all points are contemp_equiv), every subinterval `M|[a,b]` is good. The proof: `one_class` says `a ~ b` for all `a, b`. By definition of `contemp_equiv`, `a ~ b` requires `M|[a,b]` to be good (at the subinterval level). The detailed argument: `contemp_equiv sig k M a b` for `a <= b` means `good sig k (M.subinterval sig a b)` (this IS the definition of `contemp_equiv` when `a <= b`). So `one_class` directly gives `very_good`.
- [ ] Apply `chronicle_is_good_direct` (from ShiftAndGlue.lean) or its equivalent: `very_good -> good` via the lexicographic sum construction (Reynolds Lemma 16). This requires:
  - `Countable LimitDomSubtype` instance (derive from `LimitDomSubtype` being a subtype of `Q`, which is countable)
  - `NoMaxOrder` and `NoMinOrder` (already have these)
  - The `very_good` proof from the previous task
- [ ] Extract the Z-interval from `good`: `good sig k M` says `exists (Z : ZIntervalStructure sig), k_equiv sig k M (Z.toOrdered sig)`. Use `.choose` to extract the `ZIntervalStructure` and `.choose_spec` to get the k-equivalence proof.
- [ ] Determine the correct value of `k`: Must be `k >= 1 + quantifier_depth(table(phi))` where `phi` is the formula being refuted. The `quantifier_depth` function should already exist or be definable. Reynolds Theorem 18 requires `k > quantifier_depth(exists t. table(A_0)(t))`.

**Timing**: 3 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/ReynoldsBridge.lean` -- add pipeline application

**Verification**:
- `chronicle_is_good` (or similar name) is sorry-free and produces `good sig k chronicle_monadic_structure`
- Z-interval extraction produces a `ZIntervalStructure` with a k-equivalence proof

---

### Phase 3: K-Equivalence Truth Transfer and Countermodel Construction [NOT STARTED]

**Goal**: Build a new `completeness_discrete` proof path that uses the k-equivalent Z-structure, transfers satisfiability via k-equivalence, and packages the result as a countermodel.

**Tasks**:
- [ ] Build the truth transfer: From `k_equiv sig k M (Z.toOrdered sig)`, where M is the chronicle and Z is the Z-interval, transfer the existential sentence. The chronicle satisfies `exists t. table(A_0)(t)` by construction (the root MCS contains the formula being refuted). If `k > quantifier_depth(exists t. table(A_0)(t))`, then the Z-interval also satisfies this sentence.
- [ ] Formalize the truth transfer lemma: `k_equiv_preserves_sentence` or equivalent. If this is not already in the codebase, prove it: k-equivalence at depth k implies agreement on all sentences (closed formulas) of quantifier depth at most k. The existing `k_equiv` definition uses EF games; this should follow from the game characterization.
- [ ] Build `z_interval_to_countermodel`: Given the Z-interval structure satisfying `exists t. table(A_0)(t)`, extract a point `t_0 : Z.intervalCarrier` and a valuation. The Z-interval's carrier is `{z : Z // lo <= z /\ z <= hi}`, a subtype of Z. Build a BFMCS family on Z from the Z-interval's predicate interpretation, then construct `ParametricCanonicalTaskFrame`/`ParametricCanonicalTaskModel` on Z.
- [ ] Handle the existential packaging: `completeness_discrete` requires `exists (D : Type) (_ : AddCommGroup D) ... (F : TaskFrame D) (TM : TaskModel F) ... , not truth_at TM Omega tau t phi`. The Z-interval gives D = Z with all required typeclasses. Package the result to match this signature.
- [ ] Build `countermodel_discrete_reynolds_v2`: The top-level theorem combining all steps:
  1. Take an MCS `A` containing `neg phi` and `box(next_top)`
  2. Build the chronicle and limit domain
  3. Wrap as `OrderedMonadicStructure` (Phase 1)
  4. Apply Reynolds pipeline to get `good` (Phase 2)
  5. Extract Z-interval + k-equivalence
  6. Transfer satisfiability to Z-interval
  7. Build countermodel on Z from Z-interval
  8. Return the existential witness
- [ ] Wire into `completeness_discrete` (in `BXCanonical/Completeness.lean`): Replace the call to `countermodel_discrete_reynolds` at line 369 with `countermodel_discrete_reynolds_v2`. The new theorem must have the same signature (existential over `D` with `AddCommGroup D`, `IsSuccArchimedean D`, etc.).

**Timing**: 4 hours

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/ReynoldsBridge.lean` -- truth transfer and countermodel
- `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` -- wire new proof into `completeness_discrete`

**Verification**:
- `countermodel_discrete_reynolds_v2` compiles sorry-free
- `completeness_discrete` references `countermodel_discrete_reynolds_v2` instead of `countermodel_discrete_reynolds`
- `lake build Bimodal.Metalogic.BXCanonical.Completeness` compiles with zero errors

---

### Phase 4: Dead Code Cleanup [NOT STARTED]

**Goal**: Mark the bypassed sorry chain as dead code. Do not delete yet (leave for task 176 architectural cleanup), but annotate clearly and ensure it is not on any active import path for `completeness_discrete`.

**Tasks**:
- [ ] Add DEPRECATED docstrings to the bypassed functions in `ChronicleToCountermodel.lean`:
  - `chronicle_gap_contradiction` (line 473) -- mark as "BYPASSED by Strategy B (task 268)"
  - `succ_cofinal` (line 768) -- same
  - `limitDomSubtype_isSuccArchimedean` (line 784) -- same
  - `succ_embed_surjective` (line 1661) -- same
  - `cantor_bfmcs_discrete_restricted_tc` (line ~1987) -- mark as "BYPASSED: coherence proved via k-equiv path"
  - `cantor_bfmcs_discrete_restricted_fuc` (line ~2043) -- same
- [ ] Add DEPRECATED docstring to `countermodel_discrete_reynolds` in Transfer.lean (line 1203) -- mark as "SUPERSEDED by countermodel_discrete_reynolds_v2 (task 268 Strategy B)"
- [ ] Verify that `completeness_discrete` no longer transitively depends on `succ_embed_surjective` or `chronicle_gap_contradiction`
- [ ] Update `ChronicleToCountermodel.lean` header comments to reflect the new architecture
- [ ] Update any `#print axioms` comments in `Completeness.lean` to reflect sorry-free status

**Timing**: 1 hour

**Depends on**: 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` -- docstring updates
- `Theories/Bimodal/Metalogic/WeakCanonical/Transfer.lean` -- docstring updates
- `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` -- axiom audit comments

**Verification**:
- All deprecated functions have clear DEPRECATED/BYPASSED annotations
- `completeness_discrete` does not transitively depend on any sorry-tainted function

---

### Phase 5: Build Verification and Sorry Audit [NOT STARTED]

**Goal**: Full project build, axiom audit, and sorry census confirming `completeness_discrete` is sorry-free.

**Tasks**:
- [ ] Run `lake build` on the full project -- must complete with zero errors
- [ ] Run `#print axioms Bimodal.Metalogic.BXCanonical.completeness_discrete` -- must show NO `sorryAx`
- [ ] Run `#print axioms Bimodal.Metalogic.BXCanonical.completeness_dense` -- confirm still sorry-free
- [ ] Run sorry census: `grep -rn "sorry" Theories/Bimodal/Metalogic/ --include="*.lean" | grep -v "^.*:.*--" | grep -v "Boneyard"` to count remaining sorries. Document which are on the critical path vs dead code.
- [ ] Verify that `countermodel_discrete_reynolds_v2` itself shows no `sorryAx` when checked via `#print axioms`
- [ ] Verify that the new `ReynoldsBridge.lean` has zero sorry statements

**Timing**: 2 hours

**Depends on**: 4

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` -- add/update `#print axioms` lines

**Verification**:
- `lake build` succeeds (zero errors)
- `#print axioms completeness_discrete` shows no `sorryAx`
- Sorry census documented

---

## Testing & Validation

- [ ] `lake build` completes with zero errors
- [ ] `#print axioms Bimodal.Metalogic.BXCanonical.completeness_discrete` shows no `sorryAx`
- [ ] `#print axioms Bimodal.Metalogic.BXCanonical.completeness_dense` remains sorry-free
- [ ] `#print axioms Bimodal.Metalogic.WeakCanonical.IntegerModel.countermodel_discrete_reynolds_v2` (or qualified name) shows no `sorryAx`
- [ ] No new sorry introduced in `ReynoldsBridge.lean`
- [ ] Build does not regress -- all existing tests/checks still pass

## Artifacts & Outputs

- `specs/268_reynolds_pipeline_bridge/plans/04_strategy-b-plan.md` (this file)
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/ReynoldsBridge.lean` (NEW -- core bridge implementation)
- Updated `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` (new wiring)
- Updated `Theories/Bimodal/Metalogic/WeakCanonical/Transfer.lean` (docstring deprecation)
- Updated `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` (docstring deprecation)

## Rollback/Contingency

If the k-equivalence truth transfer proves harder than expected (especially packaging the Z-interval countermodel to match the `completeness_discrete` signature):

1. **Partial progress is safe**: All new code goes in `ReynoldsBridge.lean` (new file). The existing code is unchanged until Phase 3 wiring. Rollback = delete the new file.
2. **Fallback to Strategy A**: If k-equivalence packaging fails, the `one_class` result from Phase 1-2 still provides value. It can be used for a Strategy A approach (prove `chronicle_gap_contradiction` using `one_class` applied to the FULL structure, avoiding the bounded-subinterval blocker).
3. **Incremental value**: Even Phases 1-2 alone (chronicle as monadic structure + one_class + good) are architecturally valuable infrastructure for any future completeness path.
4. **Git safety**: Each phase is independently committable. If blocked at Phase 3, Phases 1-2 represent meaningful sorry-free infrastructure.
