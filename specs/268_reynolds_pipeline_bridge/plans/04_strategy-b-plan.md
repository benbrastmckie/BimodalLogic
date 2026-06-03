# Implementation Plan: Strategy B -- Reynolds K-Equivalence Bypass (Revised)

- **Task**: 268 - Reynolds pipeline bridge (Strategy B: k-equivalence bypass)
- **Status**: [IN PROGRESS]
- **Effort**: 12 hours
- **Dependencies**: None (sorry-free infrastructure already exists)
- **Research Inputs**: specs/268_reynolds_pipeline_bridge/reports/04_team-research.md, specs/268_reynolds_pipeline_bridge/reports/04_teammate-a-findings.md, specs/268_reynolds_pipeline_bridge/reports/04_teammate-b-findings.md, specs/268_reynolds_pipeline_bridge/reports/04_teammate-c-findings.md, specs/268_reynolds_pipeline_bridge/reports/04_teammate-d-findings.md, specs/268_reynolds_pipeline_bridge/handoffs/phase-2-handoff-20260603.md, specs/268_reynolds_pipeline_bridge/handoffs/phase-1-2-handoff-20260603.md, specs/268_reynolds_pipeline_bridge/reports/01_bridge-research.md
- **Artifacts**: plans/04_strategy-b-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Refactor the discrete completeness path to follow Reynolds 1994 faithfully: use k-equivalence truth transfer instead of demanding `IsSuccArchimedean` for the chronicle limit domain. Phases 1-2 are complete and sorry-free (limitdom as OrderedMonadicStructure, Reynolds pipeline giving `limitdom_is_good`). Phase 3 was blocked because the original approach tried to build a TaskModel countermodel from the Z-interval using MCS-based world states, but the Z-interval only provides predicate interpretations, not MCS sets.

The revised Phase 3 uses a custom TaskFrame approach: define a TaskFrame on Z where WorldState = Unit (constant, as in the existing `zIntervalTaskFrame`), build a TaskModel where atom valuation is derived from the Z-interval's predicate interpretations, and prove the truth correspondence `truth_at <-> temporal_truth` by structural induction on formulas. This approach reuses the existing `zIntervalTaskFrame`, `zIntervalHistory`, `zIntervalOmega`, and `zIntervalBox_transparent` infrastructure from Transfer.lean, reducing the new code to building the TaskModel and proving `h_truth_corr`.

### Research Integration

Key findings integrated from blocker research (Phase 1-2 handoff, user revision instructions):

1. **Approach 3 (proving chronicle_gap_contradiction via gap_contradicts_prior) is FUNDAMENTALLY NON-VIABLE**: `one_class` proves ALL pairs are `contemp_equiv` at every depth k. `gap_contradicts_prior`'s `h_bounded_above` hypothesis is unprovable. The gap contradiction proves no gaps in `contemp_equiv` CLASSES, not succ-ORBITS.

2. **Custom TaskFrame from Z-interval IS viable**: Define TaskFrame on Z with WorldState = Unit (reusing `zIntervalTaskFrame`). Build TaskModel with position-dependent atom interpretation from the Z-interval's `interp` function. Prove `h_truth_corr` by structural induction.

3. **The existing infrastructure handles most of the work**: `truth_transfer` (Transfer.lean:337) transfers existential satisfaction via k-equivalence. `z_interval_countermodel` (Transfer.lean:633) packages the countermodel given a TaskModel and truth correspondence. The pipeline from `limitdom_is_good` produces unbounded Z-intervals (`lo = none`, `hi = none`) via shift-and-glue, satisfying `z_interval_countermodel`'s requirements.

4. **`effectiveFormula` identity lemmas are already proved**: `effectiveFormula_id_self`, `effectiveFormula_id_neg`, and `effectiveFormula_id_of_sub` are sorry-free in ReynoldsBridge.lean. These ensure truth transfer for `phi.neg` works correctly.

### Prior Plan Reference

Prior plan version attempted Phase 3 by building a BFMCS from Z-interval predicates, using `ParametricCanonicalTaskFrame` with MCS-based world states. This was blocked because the k-equivalence preserves monadic FO truth but not MCS structure. The revised Phase 3 bypasses this entirely by using the existing `zIntervalTaskFrame` (WorldState = Unit) and building the truth correspondence directly.

## Goals & Non-Goals

**Goals**:
- Build `LimitDomSubtype` as an `OrderedMonadicStructure` with Prior-UZ/SZ [DONE]
- Apply the sorry-free Reynolds pipeline (`one_class` -> `very_good` -> `good`) [DONE]
- Extract a k-equivalent Z-interval structure [DONE]
- Transfer `neg phi` satisfiability to the Z-interval via `truth_transfer`
- Build TaskModel on Z using Z-interval predicate interpretations
- Prove `h_truth_corr` (truth_at <-> temporal_truth)
- Apply `z_interval_countermodel` to produce the countermodel existential
- Wire into `completeness_discrete` to eliminate sorryAx
- Mark bypassed sorry chain as dead code

**Non-Goals**:
- Proving `IsSuccArchimedean` for `LimitDomSubtype` (bypassed entirely)
- Fixing `chronicle_gap_contradiction` (bypassed entirely)
- Rewriting the Chronicle module architecture (task 176)
- Eliminating non-critical-path sorries in NEquivalence.lean or StaviCompleteness.lean
- Archiving the BXCanonical subtree (task 176)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Z-interval from `good` may have bounded `lo`/`hi` | H | L | Shift-and-glue construction in `very_good_implies_good` always produces `lo = none, hi = none`. Worst case: prove a lemma that `limitdom_is_good` gives unbounded Z-intervals, or generalize `z_interval_countermodel`. |
| `h_truth_corr` proof for Until/Since cases may be complex | M | M | Until/Since truth_at uses existential witnesses in Z; temporal_truth uses the same. Box transparency (`zIntervalBox_transparent`) eliminates box case complexity. |
| Signature mismatch: `z_interval_countermodel` returns existential without `SuccOrder`/`PredOrder`/`IsSuccArchimedean`/`IsPredArchimedean` | H | M | `z_interval_countermodel` returns `∃ D ... F TM ...` without those instances. But `completeness_discrete` destructures `countermodel_discrete_reynolds` which does provide them. Solution: either add these instances to `countermodel_discrete_reynolds_v2` (trivial for Z) or adjust `completeness_discrete` destructuring. |
| `effectiveFormula` identity may not hold for all relevant subformulas | M | L | Already proved: `effectiveFormula_id_of_sub` handles all subformulas of phi. `truth_transfer` works with `mkAtomMapFwd phi` which maps phi's subformulas identically. |

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

### Phase 1: LimitDomSubtype as OrderedMonadicStructure [COMPLETED]

**Goal**: Wrap the chronicle's limit domain as an `OrderedMonadicStructure` and prove it satisfies the preconditions for model surgery (`semantic_prior_UZ`, `semantic_prior_SZ`).

**Tasks**:
- [x] Create `ReynoldsBridge.lean` with imports from `Transfer`, `NoGapsDiscreteProof`, `ChronicleToCountermodelBasic`
- [x] Define `limitdom_monadic_structure`: `OrderedMonadicStructure sig` on `LimitDomSubtype`
- [x] Provide `SuccOrder`, `PredOrder`, `NoMaxOrder`, `NoMinOrder`, `Countable`, `Nonempty` instances
- [x] Prove `limitdom_temporal_truth_effective`: chronicle truth <-> effectiveFormula membership in MCS
- [x] Prove `limitdom_semantic_prior_UZ` and `limitdom_semantic_prior_SZ`

**Timing**: 4 hours

**Depends on**: none

**Completed**: 2026-06-03

---

### Phase 2: Apply Reynolds Pipeline to LimitDomSubtype [COMPLETED]

**Goal**: Apply the sorry-free Reynolds pipeline to the wrapped `LimitDomSubtype` structure to extract a k-equivalent Z-interval.

**Tasks**:
- [x] Prove `limitdom_is_good`: apply `one_class` -> `one_class_implies_very_good` -> `very_good_implies_good` to get `good sig k M`
- [x] Prove `effectiveFormula_id_of_sub`, `effectiveFormula_id_self`, `effectiveFormula_id_neg`
- [x] Prove `limitdom_root_neg_truth`: neg phi is temporally true at the root

**Timing**: 3 hours

**Depends on**: 1

**Completed**: 2026-06-03

---

### Phase 3: Custom TaskFrame Truth Transfer and Countermodel Construction [BLOCKED]

**Goal**: Complete `countermodel_discrete_reynolds_v2` by building a TaskModel from the Z-interval and proving the full truth correspondence, then packaging as the countermodel existential.

**Architecture**: The approach uses three steps:
1. **Truth transfer**: Use `truth_transfer` to move `neg phi` satisfaction from the limitdom monadic structure to the Z-interval
2. **TaskModel construction**: Build a `TaskModel zIntervalTaskFrame` where atom valuation at position `t` comes from the Z-interval's `interp` function (via `atomMap_fwd`)
3. **Truth correspondence**: Prove `h_truth_corr` by structural induction on formulas, showing `truth_at TM zIntervalOmega zIntervalHistory t psi <-> temporal_truth (Z.toOrdered sig) atomMap_fwd t_Z psi` for all subformulas `psi` and positions `t`

**BLOCKER** (Phase 3):
- **What failed**: The truth correspondence `h_truth_corr : ∀ ψ t, truth_at TM zIntervalOmega zIntervalHistory (iso t) ψ ↔ temporal_truth (Z.toOrdered sig) atomMap_fwd t ψ` is UNSATISFIABLE with the plan's `zIntervalTaskFrame` (WorldState = Unit).
- **What was tried**:
  1. **Plan's approach (zIntervalTaskFrame, WorldState = Unit, singleton Omega)**: With WorldState = Unit, `truth_at` for atoms evaluates `TM.valuation () a`, which is position-independent. But `temporal_truth` for atoms evaluates `Z.interp (atomMap_fwd (.atom a)) t.val`, which is position-dependent. The biconditional `truth_at ↔ temporal_truth` fails for ANY formula containing atoms whose Z-interval predicates are non-constant.
  2. **Predicate-tracking WorldState (WorldState = sig.preds → Prop, singleton Omega)**: With non-trivial WorldState, singleton Omega fails `ShiftClosed`: `τ.time_shift Δ` has different states at each position (states shift with Δ), so `τ.time_shift Δ ≠ τ`.
  3. **Orbit-based Omega (WorldState = sig.preds → Prop, Omega = orbit of τ)**: ShiftClosed holds, but box transparency breaks. `truth_at (.box ψ) t` quantifies over all shifted histories, requiring `∀ Δ, truth_at ... (τ.time_shift Δ) t ψ`, which equals `∀ s, temporal_truth ... s ψ`. This does NOT match `temporal_truth (.box ψ) = Z.interp (atomMap_fwd (.box ψ)) t.val` (a predicate lookup) unless an S5 transfer property holds: `Z.interp (atomMap_fwd (.box ψ)) t ↔ ∀ s, temporal_truth ... s ψ`. This S5 transfer is provable in principle (from one_class + k-equivalence) but requires substantial new infrastructure (200-400 lines of new lemmas).
  4. **Direct proof of chronicle_gap_contradiction via k-equivalence**: k-equivalence preserves FO sentences of bounded depth, but succ-orbit cofinality is NOT expressible as a single FO sentence (it quantifies over iteration counts). So k-equivalence cannot prove `chronicle_gap_contradiction`.
- **Why it's stuck**: There is a fundamental architectural incompatibility between `truth_at` (task-semantic truth with world-state-dependent atom valuation through history states) and `temporal_truth` (monadic FO truth with position-dependent predicate interpretation). The three requirements -- (1) position-dependent atoms, (2) box transparency, (3) shift-closed Omega -- are mutually exclusive under the current TaskFrame architecture.
- **What is needed**: One of:
  (A) **S5 orbit approach**: ~300 lines of new infrastructure: prove that Z-interval box predicates from one_class structures satisfy `Z.interp (atomMap_fwd (.box ψ)) t ↔ ∀ s, temporal_truth ... s ψ` via k-equivalence transfer of `∀x.P(x)` and `∃x.¬P(x)` sentences. Then build orbit-based Omega and prove truth correspondence with this S5 property handling the box case.
  (B) **Prove chronicle_gap_contradiction directly**: ~200-500 lines. The proof requires showing that in a discrete limit domain with NoMaxOrder, every bounded increasing succ-orbit sequence has a supremum IN the domain, and that supremum is in the orbit. This is equivalent to proving the limit domain has no ω-gaps. Requires new techniques beyond k-equivalence.
  (C) **Redesign the TaskFrame architecture**: Allow position-dependent atom valuation without going through WorldState. This would be a major refactor affecting the entire semantics module.
- **Prohibited workarounds**: Do NOT use `sorry`, `def X := True`, or any vacuous placeholder.

**Tasks**:
- [ ] **Task 3.1: Prove Z-interval unboundedness**. *(deviation: deferred — blocked by truth correspondence impossibility)* The Z-interval from `limitdom_is_good` (via `very_good_implies_good` -> `ordered_sum_of_good_bounded_is_good`) has `lo = none` and `hi = none` by construction (ShiftAndGlue.lean lines 607-609). Options: (a) prove a wrapper lemma `limitdom_is_good_unbounded` that returns the Z-interval with unboundedness proofs, OR (b) prove a general lemma that `good` for a NoMaxOrder/NoMinOrder structure always yields unbounded Z-intervals (via the shift-and-glue construction). The simplest approach is (a): factor out the `good` result with explicit bounds.
- [ ] **Task 3.2: Apply `truth_transfer`**. *(deviation: deferred — blocked by truth correspondence impossibility)* Given `limitdom_root_neg_truth` (neg phi is temporally true at root in the limitdom monadic structure) and `limitdom_is_good` (k-equivalence to Z-interval at depth `operator_depth phi + 2`), apply `truth_transfer` to get `exists s : Z.intervalCarrier, temporal_truth (Z.toOrdered sig) (mkAtomMapFwd phi) s phi.neg`. The depth bound `operator_depth phi + 1 <= operator_depth phi + 2` is immediate.
- [ ] **Task 3.3: Build TaskModel on Z from Z-interval**. *(deviation: skipped — plan's approach provably impossible, see BLOCKER)* Define `zIntervalTaskModel : TaskModel zIntervalTaskFrame` using the Z-interval's predicate interpretations. The atom valuation function is: `atom_val (a : Atom) (w : Unit) (t : Z) := Z.interp (atomMap_fwd (.atom a)) t`. This maps atoms at position t to the Z-interval's predicate value at that position. Key: `zIntervalTaskFrame` has `WorldState = Unit`, so the world state carries no information; all position-dependent truth comes from the TaskModel's atom valuation.
- [ ] **Task 3.4: Prove `h_truth_corr`**. *(deviation: skipped — provably impossible with WorldState=Unit, see BLOCKER)* Prove by structural induction on formulas that `truth_at TM zIntervalOmega zIntervalHistory (iso t) psi <-> temporal_truth (Z.toOrdered sig) atomMap_fwd t psi` where `iso = unboundedZIntervalEquiv Z h_lo h_hi`. Cases:
  - **Atom**: By definition of atom valuation in TaskModel and `Z.interp` in the ordered monadic structure. Need the `atomMap_fwd` section property to connect atom predicates to formula atoms.
  - **Bot**: Both sides false. `truth_at` of bot is False; `temporal_truth` of bot is False.
  - **Imp**: By MCS-free propositional logic: `truth_at (f1.imp f2)` is `truth_at f1 -> truth_at f2`; `temporal_truth (f1.imp f2)` is `temporal_truth f1 -> temporal_truth f2`. Follows from IH on f1 and f2.
  - **Box**: `truth_at (.box psi)` quantifies over all histories in Omega. Since `Omega = {zIntervalHistory}` (singleton), this reduces to `truth_at psi` by `zIntervalBox_transparent`. `temporal_truth (.box psi)` is `temporal_truth psi` (single monadic structure has no modal dimension). Both reduce to IH on psi.
  - **Until**: `truth_at (.untl f1 f2)` provides witness `s > t` with `truth_at f2 s` and `truth_at f1` at all `r` between `t` and `s`. `temporal_truth (.untl f1 f2)` provides analogous witness in the Z-interval. Need to transport witnesses via `iso` (the order isomorphism between `Z.intervalCarrier` and Z). Since `iso` is an `OrderIso`, it preserves `<` and betweenness. Apply IH to f1 and f2 at each witness/guard position.
  - **Since**: Symmetric to Until (backward direction).
- [ ] **Task 3.5: Apply `z_interval_countermodel`**. *(deviation: deferred — blocked by h_truth_corr impossibility)* With the TaskModel, truth correspondence, and unboundedness proofs, apply `z_interval_countermodel` to get the countermodel existential `exists D ... F TM Omega tau t, neg truth_at TM Omega tau t phi`. This provides `D = Z`, `F = zIntervalTaskFrame`, and all required instances.
- [ ] **Task 3.6: Package as `countermodel_discrete_reynolds_v2`**. *(deviation: deferred — blocked)* The current theorem signature includes `SuccOrder D`, `PredOrder D`, `IsSuccArchimedean D`, `IsPredArchimedean D` in the existential. For `D = Z`, all four are trivially available via `Int.instSuccOrder`, `Int.instPredOrder`, `Int.instIsSuccArchimedean`, `Int.instIsPredArchimedean`. Instantiate these in the existential. Alternatively, if `z_interval_countermodel`'s output does not include them, add them manually.
- [ ] **Task 3.7: Remove the sorry**. *(deviation: deferred — blocked)* Replace `sorry` at ReynoldsBridge.lean:489 with the complete proof from Tasks 3.1-3.6.

**Timing**: 5 hours

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/ReynoldsBridge.lean` -- complete `countermodel_discrete_reynolds_v2`

**Verification**:
- `countermodel_discrete_reynolds_v2` compiles sorry-free
- `lake build Bimodal.Metalogic.WeakCanonical.IntegerModel.ReynoldsBridge` with zero errors
- `#print axioms countermodel_discrete_reynolds_v2` shows no `sorryAx`

**Blocker Notes (from prior attempt)**:
The original Phase 3 was blocked because it tried to reconstruct MCS sets from the Z-interval's finite predicate information (requiring Lindenbaum extension). The revised approach avoids MCS reconstruction entirely: atom truth comes directly from the Z-interval's `interp` function, and the truth correspondence is proved by structural induction without reference to MCS sets. The key insight is that `zIntervalTaskFrame` has `WorldState = Unit` (no MCS needed), and all position-dependent truth is encoded in the TaskModel's atom valuation function.

---

### Phase 4: Wire into completeness_discrete and Dead Code Cleanup [NOT STARTED]

**Goal**: Wire `countermodel_discrete_reynolds_v2` into `completeness_discrete` and mark the bypassed sorry chain as dead code.

**Tasks**:
- [ ] **Task 4.1: Wire into `completeness_discrete`**. In `Completeness.lean` at line 369, replace the call to `countermodel_discrete_reynolds` with `countermodel_discrete_reynolds_v2`. Update the destructuring pattern to match the new signature (should be identical: both provide `D, AddCommGroup, LinearOrder, IsOrderedAddMonoid, Nontrivial, SuccOrder, PredOrder, IsSuccArchimedean, IsPredArchimedean, TaskFrame, TaskModel, Omega, ShiftClosed, tau, mem, t`).
- [ ] **Task 4.2: Add DEPRECATED docstrings to bypassed functions**:
  - `chronicle_gap_contradiction` in ChronicleToCountermodel.lean -- "BYPASSED by Strategy B (task 268)"
  - `succ_cofinal` -- same
  - `limitDomSubtype_isSuccArchimedean` -- same
  - `succ_embed_surjective` -- same
  - `cantor_bfmcs_discrete_restricted_tc` and `_fuc` -- same
  - `countermodel_discrete_reynolds` in Transfer.lean -- "SUPERSEDED by countermodel_discrete_reynolds_v2 (task 268 Strategy B)"
- [ ] **Task 4.3: Verify no transitive dependency**. Confirm that `completeness_discrete` no longer transitively depends on `succ_embed_surjective` or `chronicle_gap_contradiction` (it should not, since the new path goes through `countermodel_discrete_reynolds_v2` which uses `limitdom_is_good` -> `truth_transfer` -> `z_interval_countermodel`).
- [ ] **Task 4.4: Update axiom audit comments** in Completeness.lean to reflect sorry-free status.

**Timing**: 1 hour

**Depends on**: 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` -- wiring + axiom comments
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` -- DEPRECATED docstrings
- `Theories/Bimodal/Metalogic/WeakCanonical/Transfer.lean` -- DEPRECATED docstring

**Verification**:
- `lake build Bimodal.Metalogic.BXCanonical.Completeness` compiles with zero errors
- All deprecated functions have clear DEPRECATED/BYPASSED annotations
- `completeness_discrete` does not transitively depend on any sorry-tainted function

---

### Phase 5: Build Verification and Sorry Audit [NOT STARTED]

**Goal**: Full project build, axiom audit, and sorry census confirming `completeness_discrete` is sorry-free.

**Tasks**:
- [ ] Run `lake build` on the full project -- must complete with zero errors
- [ ] Run `#print axioms Bimodal.Metalogic.BXCanonical.completeness_discrete` -- must show NO `sorryAx`
- [ ] Run `#print axioms Bimodal.Metalogic.BXCanonical.completeness_dense` -- confirm still sorry-free
- [ ] Run `#print axioms countermodel_discrete_reynolds_v2` -- must show no `sorryAx`
- [ ] Run sorry census: `grep -rn "sorry" Theories/Bimodal/Metalogic/ --include="*.lean" | grep -v "^.*:.*--" | grep -v "Boneyard"` to count remaining sorries. Document which are on the critical path vs dead code.
- [ ] Verify ReynoldsBridge.lean has zero sorry statements

**Timing**: 2 hours

**Depends on**: 4

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` -- update `#print axioms` output comments

**Verification**:
- `lake build` succeeds (zero errors)
- `#print axioms completeness_discrete` shows no `sorryAx`
- Sorry census documented

---

## Testing & Validation

- [ ] `lake build` completes with zero errors
- [ ] `#print axioms Bimodal.Metalogic.BXCanonical.completeness_discrete` shows no `sorryAx`
- [ ] `#print axioms Bimodal.Metalogic.BXCanonical.completeness_dense` remains sorry-free
- [ ] `#print axioms Bimodal.Metalogic.WeakCanonical.countermodel_discrete_reynolds_v2` shows no `sorryAx`
- [ ] No new sorry introduced in `ReynoldsBridge.lean`
- [ ] Build does not regress -- all existing tests/checks still pass

## Artifacts & Outputs

- `specs/268_reynolds_pipeline_bridge/plans/04_strategy-b-plan.md` (this file)
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/ReynoldsBridge.lean` (core bridge implementation, 491 lines + Phase 3 additions)
- Updated `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` (new wiring)
- Updated `Theories/Bimodal/Metalogic/WeakCanonical/Transfer.lean` (docstring deprecation)
- Updated `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` (docstring deprecation)

## Rollback/Contingency

If the custom TaskFrame truth correspondence (`h_truth_corr`) proves harder than expected:

1. **Partial progress is safe**: All new code goes in `ReynoldsBridge.lean`. The existing code is unchanged until Phase 4 wiring. Rollback = revert the new file to the Phase 1-2 state.
2. **Fallback: Lindenbaum extension**: If the structural induction for `h_truth_corr` on Until/Since stalls, the alternative is to reconstruct MCS sets at each integer via Lindenbaum extension of the predicate set `{f | Z.interp (atomMapFwd f) z}`. This is more complex (300-500 lines) but mathematically sound.
3. **Fallback: Direct omega-chain**: Prove `chronicle_gap_contradiction` by a direct omega-chain argument on the limit domain (300-600 lines, no existing infrastructure). This is non-viable per research findings (see overview).
4. **Incremental value**: Phases 1-2 alone (chronicle as monadic structure + `limitdom_is_good`) are architecturally valuable infrastructure for any future completeness path.
5. **Git safety**: Each phase is independently committable. Phase 3 completion + Phase 4 wiring should be committed together to maintain build integrity.
