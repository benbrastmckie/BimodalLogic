# Implementation Plan: Reynolds Pipeline Activation

- **Task**: 155 - reynolds_pipeline_activation
- **Status**: [NOT STARTED]
- **Effort**: 22 hours
- **Dependencies**: Task 154 (sum_preservation, COMPLETED), Tasks 147-148 (table_correctness, COMPLETED)
- **Research Inputs**: specs/155_reynolds_pipeline_activation/reports/01_team-research.md
- **Artifacts**: plans/01_reynolds-pipeline-plan.md
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Replace the chronicle fallback in `Transfer.lean` with the full Reynolds Theorem 15 pipeline, achieving sorry-free `bx_completeness`. The implementation closes 5 sorries in `IntegerModel.lean` (following Reynolds 1994 Sections 7-8 and Doets 1989 Theorem 1.1), then constructs the truth transfer bridge from k-equivalence to `truth_at` semantics via a TaskFrame Int with single-history semantics (mathematically valid for the discrete single-S5-class case). Definition of done: `doets_countermodel_discrete` uses the Reynolds pipeline (no chronicle fallback), `#print axioms bx_completeness` shows no `sorryAx`, `lake build` passes.

### Research Integration

Integrated from `reports/01_team-research.md` (team research, 4 teammates):
- Sorry chain analysis identifying 5 sorries with strict dependency order
- Critical finding that `finite_structures_good` requires Doets Theorem 1.1 (k-type realizability), NOT sum_preservation
- Resolution of truth transfer approach: single-history model is correct for discrete single-S5-class case (all MCS's box-equivalent)
- Identification of `k_equiv_preserves_eval` as the key missing bridge lemma
- Implementation order recommendation (8 steps)

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

- Advances "sorry-free bx_completeness" (the primary critical path item in ROADMAP.md)
- Eliminates the last 5 sorries on the discrete branch (Reynolds pipeline)
- Eliminates the chronicle fallback in Transfer.lean

## Goals & Non-Goals

**Goals**:
- Close all 5 sorries in `IntegerModel.lean` following Reynolds 1994 faithfully
- Prove `k_equiv_preserves_eval` connecting k-type agreement to formula evaluation
- Construct TaskFrame Int from Z-model with single-history semantics
- Replace chronicle fallback in `Transfer.lean` with genuine pipeline
- Verify `#print axioms bx_completeness` shows no `sorryAx`

**Non-Goals**:
- Dense completeness (separate theorem, unaffected)
- Mixed case (already resolved by task 142)
- Doets Lemma 1.5 (type-matching variant, not on discrete critical path)
- Optimizing or refactoring existing sorry-free infrastructure
- Any "bridge" or "adapter" pattern (systematic constructions only)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `finite_structures_good` requires non-trivial EF argument (carrier mismatch) | H | M | Use predicate extension technique: pad outside interval with endpoint pattern, prove k-equivalence via normal form agreement |
| `k_equiv_preserves_eval` requires formula-to-normal-form compilation not yet explicit | H | M | Leverage existing `nf_eval_nf` + `nf_exists_unique` + `nf_characteristic`; the compilation step is implicit in these |
| `very_good_implies_good` cofinal decomposition requires careful Lean encoding | M | M | Use `Countable` + `NoMaxOrder` to construct explicit cofinal sequences; leverage existing `orderedSum` infrastructure |
| TaskFrame Int construction: box semantics for single-history model | M | L | Mathematically justified (discrete, single S5 class, all box-equivalent); straightforward once temporal truth transfer proved |
| `contemp_equiv_is_equiv.trans` sum decomposition | M | M | Apply `doets_lemma_1_4` on 2-element index set; standard application of existing sorry-free infrastructure |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 3 | 1 |
| 3 | 4 | 2, 3 |
| 4 | 5 | 4 |
| 5 | 6 | 5 |

Phases within the same wave can execute in parallel.

---

### Phase 1: finite_structures_good (Doets Theorem 1.1) [COMPLETED]

**Goal**: Close the foundational sorry proving every finite ordered monadic structure is k-equivalent to a Z-interval structure.

**Tasks**:
- [x] **Task 1.1**: Define predicate extension function *(deviation: altered — instead of predicate extension on all of Z, redesigned `ZIntervalStructure.toOrdered` to use the actual interval as carrier, making the proof a direct order-isomorphism argument)*
- [x] **Task 1.2**: Construct `ZIntervalStructure sig` with `lo = some 0`, `hi = some (n-1)`, `interp` matching M on [0, n-1] via `monoEquivOfFin` isomorphism
- [x] **Task 1.3**: Prove k-equivalence via `k_equiv_of_iso` theorem *(deviation: altered — used order-isomorphism preservation of NF evaluation instead of normal form agreement argument, since carrier is now the actual interval)*
- [x] **Task 1.4**: The key insight: `k_equiv_of_iso` proves that order-isomorphic structures with matching predicates have identical k-types by induction on quantifier depth
- [x] **Task 1.5**: Close the sorry in `IntegerModel.lean` (was line 90, now moved due to new code above)
- [x] **Task 1.6**: Verify `lake build` passes with `finite_structures_good` sorry-free — verified via `lean_verify`, axioms: propext, Classical.choice, Quot.sound

**Timing**: 4 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel.lean` - Close sorry at line 90

**Verification**:
- `lean_verify` on `finite_structures_good` shows no `sorryAx`
- `lake build` passes
- `no_boundary_at_successor` (which depends on `finite_structures_good`) also becomes sorry-free

---

### Phase 2: contemp_equiv_is_equiv Transitivity (Reynolds Lemma 17) [NOT STARTED]

**Goal**: Close the transitivity sorry for contemporaneous equivalence, proving that if [a,b] and [b,c] are very good, then [a,c] is very good.

**Tasks**:
- [ ] For any x, y in [min a c, max a c] with x <= y, decompose into cases: both in [a,b], both in [b,c], or spanning the boundary at b
- [ ] For the spanning case: M|[x,y] = M|[x,b] concatenated with M|[b+1,y] (in discrete order, using SuccOrder)
- [ ] Each piece [x,b] and [b+1,y] is a subinterval of [a,b] or [b,c] respectively, hence good by the very_good hypotheses
- [ ] Apply `doets_lemma_1_4` (sum_preservation) on a 2-element index set (`Bool` with `false < true`) to show the concatenation is good
- [ ] A concatenation of two Z-intervals IS a Z-interval (construct the combined Z-interval)
- [ ] Close the sorry at `IntegerModel.lean:128`

**Timing**: 3 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel.lean` - Close sorry in `contemp_equiv_is_equiv.trans`

**Verification**:
- `lean_verify` on `contemp_equiv_is_equiv` shows no `sorryAx`
- `one_class` theorem (which uses transitivity) becomes sorry-free

---

### Phase 3: no_gaps_discrete (Boundary Impossibility) [NOT STARTED]

**Goal**: Close the sorry proving that in a discrete order without endpoints, ~M class boundaries cannot exist (they would have to fall at some successor pair, contradicting `no_boundary_at_successor`).

**Tasks**:
- [ ] The proof uses well-founded induction: given a != b with different classes, find a boundary point
- [ ] Use `Order.succ` and `Order.pred` in the discrete order to construct a sequence from a toward b
- [ ] In a linearly ordered type with `NoMaxOrder`/`NoMinOrder`/`SuccOrder`/`PredOrder`: for any a < b, consider the set S = {c in [a,b] | c ~M a}. S is nonempty (a is in S). If b is not in S, S is bounded above by b.
- [ ] In discrete order, take c = max of S restricted to [a,b] (exists by well-founded descent from b). Then c ~M a but succ(c) is not ~M a (otherwise succ(c) would be in S, contradicting maximality)
- [ ] Handle the case a > b symmetrically (or reduce to a < b via symmetry of ~M class difference)
- [ ] Close the sorry at `IntegerModel.lean:145`

**Timing**: 3 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel.lean` - Close sorry in `no_gaps_discrete`

**Verification**:
- `lean_verify` on `no_gaps_discrete` shows no `sorryAx`
- Combined with `no_boundary_at_successor`, the `one_class` theorem is fully sorry-free

---

### Phase 4: very_good_implies_good and chronicle_is_good (Reynolds Lemma 16) [NOT STARTED]

**Goal**: Close the two remaining IntegerModel.lean sorries: `very_good_implies_good` (cofinal decomposition) and `chronicle_is_good` (one_class + very_good -> good chain).

**Tasks**:
- [ ] **very_good_implies_good**: For countable M without endpoints and very good at depth k:
  - [ ] Use `Countable` + `NoMinOrder` + `NoMaxOrder` to construct a cofinal sequence covering M (bi-infinite enumeration a_0, a_1, ...)
  - [ ] Partition M into intervals [a_i, pred(a_{i+1})] for each i (or use the ordered sum decomposition directly)
  - [ ] Each piece is a finite subinterval of M, hence good (by very_good + finite)
  - [ ] Apply `doets_lemma_1_4` (sum_preservation) on the Z-indexed family to get k-equiv to an ordered sum of Z-intervals
  - [ ] An ordered sum of Z-intervals indexed by Z IS a single Z-interval (unbounded both ways): construct the combined ZIntervalStructure with `lo = none, hi = none`
  - [ ] Close the sorry at `IntegerModel.lean:202`
- [ ] **chronicle_is_good**: Chain the completed results:
  - [ ] The chronicle is countable, discrete, without endpoints (from ChronicleAsPriorModel fields)
  - [ ] By `one_class` (now sorry-free from Phases 1-3): all points are contemporaneously equivalent
  - [ ] Therefore the chronicle is very_good (every subinterval is between contemporaneously equivalent points)
  - [ ] By `very_good_implies_good`: the chronicle is good
  - [ ] Close the sorry at `IntegerModel.lean:214`

**Timing**: 4 hours

**Depends on**: 2, 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel.lean` - Close sorries at lines 202 and 214

**Verification**:
- `lean_verify` on `chronicle_is_good` shows no `sorryAx`
- All 5 IntegerModel.lean sorries now closed
- `lake build` passes

---

### Phase 5: k_equiv_preserves_eval and Truth Transfer Bridge [NOT STARTED]

**Goal**: Prove the key bridge theorem connecting k-equivalence (normal form level) to formula evaluation agreement, then establish truth transfer from the Z-model to temporal truth.

**Tasks**:
- [ ] **k_equiv_preserves_eval**: Prove that k-equivalent structures agree on all monadic sentences of depth <= k
  - [ ] Statement: for M, N with `k_equiv sig k M N` and `alpha : MonadicFormula sig 0` with `alpha.quantifier_depth <= k`, `eval M Fin.elim0 alpha <-> eval N Fin.elim0 alpha`
  - [ ] Proof strategy: Use `nf_exists_unique` + `nf_characteristic`: M satisfies exactly one normal form (its characteristic). Since `k_equiv` means same k-type (same characteristic), M and N agree on which normal form they satisfy. Every sentence of depth <= k is determined by the characteristic (via `doets_lemma_1_1` bridge theorem from NormalForm.lean)
  - [ ] If `doets_lemma_1_1` provides the needed direction (nf agreement implies eval agreement), use it directly; otherwise construct the implication from `nf_characteristic_satisfies` + evaluation determinacy
- [ ] **k_equiv_preserves_temporal_truth**: Derive temporal truth preservation from k_equiv_preserves_eval + table_correctness
  - [ ] For formula phi with `operator_depth phi + 1 <= k`: if M k_equiv N, then `temporal_truth M atomMap t phi <-> temporal_truth N atomMap t' phi` (for corresponding points t, t')
  - [ ] Proof: `temporal_truth M atomMap t phi <-> eval M (fun _ => t) (table sig atomMap phi)` (by `table_correctness`) `<-> eval N (fun _ => t') (table sig atomMap phi)` (by `k_equiv_preserves_eval` since `(table phi).quantifier_depth <= operator_depth phi + 1 <= k`) `<-> temporal_truth N atomMap t' phi` (by `table_correctness` on N)
- [ ] Handle the point correspondence: k-equivalence is at the level of entire structures (0-ary sentences), so temporal truth transfer at EVERY point requires quantifier-depth analysis
  - [ ] The key: `table sig atomMap phi` is a 1-variable formula. Closing over a point t gives a 0-variable sentence. The depth bound `table_depth_bound` ensures this sentence has depth <= operator_depth phi <= k
- [ ] Construct forward atomMap: `atomMap_fwd : Formula -> sig.preds` from `mkSigFrom phi` (maps each temporal formula to its corresponding predicate symbol via the `predFormulas` membership proof)

**Timing**: 5 hours

**Depends on**: 4

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel.lean` or new file `Theories/Bimodal/Metalogic/WeakCanonical/TruthTransfer.lean` - `k_equiv_preserves_eval`, `k_equiv_preserves_temporal_truth`
- `Theories/Bimodal/Metalogic/WeakCanonical/Transfer.lean` - Add `atomMap_fwd` construction

**Verification**:
- `lean_verify` on `k_equiv_preserves_eval` shows no `sorryAx`
- `lean_verify` on `k_equiv_preserves_temporal_truth` shows no `sorryAx`
- `lake build` passes

---

### Phase 6: TaskFrame Int Construction and Pipeline Wiring [NOT STARTED]

**Goal**: Construct a TaskFrame Int countermodel from the Z-model and wire the full Reynolds pipeline into `Transfer.lean`, eliminating the chronicle fallback.

**Tasks**:
- [ ] **TaskFrame Int construction for discrete single-S5-class**: Define a TaskFrame on Int with:
  - [ ] `WorldState := Unit` (single world state -- all points box-equivalent in discrete single-class case)
  - [ ] `task_rel w d u := w = u` (deterministic: single state, identity relation)
  - [ ] `nullity_identity`: trivial (w = u <-> w = u)
  - [ ] `forward_comp`: trivial (Unit has one element)
  - [ ] `converse`: trivial
- [ ] **TaskModel construction**:
  - [ ] `valuation` at the single WorldState maps atom p to: the Z-model's predicate interpretation at the current integer time point (via `atomMap` connecting atoms to sig.preds)
  - [ ] This requires the Z-model's `interp` to determine atom truth at each time
- [ ] **WorldHistory construction**: Single history tau covering all of Int
  - [ ] `domain t := True` (defined everywhere on Int)
  - [ ] `states t _ := ()` (always the single state)
  - [ ] `respects_task`: trivial (task_rel is identity on Unit)
- [ ] **Omega construction**: `Omega := {tau}` (singleton set)
  - [ ] Prove `ShiftClosed Omega`: shifting the single history by any d gives the same history (states are always Unit)
- [ ] **truth_at correspondence**: Prove `truth_at TM Omega tau t phi <-> temporal_truth (Z.toOrdered sig) atomMap_fwd t phi` for all temporal formulas phi
  - [ ] Atom case: `truth_at ... (atom p)` = `exists ht, valuation (states t ht) p` = Z-model's `interp (atomMap_fwd (atom p)) t` = `temporal_truth ... (atom p)`
  - [ ] Bot/Imp: structural
  - [ ] Box case: `truth_at ... (box phi)` = `forall sigma in Omega, truth_at ... sigma t phi` = `truth_at ... tau t phi` (Omega is singleton) -- This reduces to the temporal_truth for box, which reads `interp (atomMap_fwd (box phi)) t`. The Z-model's predicate for box phi at time t captures exactly whether box phi holds. This is correct because in the single-S5-class discrete case, box phi at t <-> phi holds at ALL times <-> the Z-model's interp for box phi is true at t (set up this way by the chronicle extraction)
  - [ ] Temporal cases (G, H, U, S): direct from quantifier structure over Int matching Z-model carrier
- [ ] **Wire the pipeline into doets_countermodel_discrete**:
  - [ ] Step 1: `extract_chronicle_as_prior A h_mcs h_box_discrete`
  - [ ] Step 2: `mkSigFrom phi`, `mkAtomMap phi`, construct `atomMap_fwd`
  - [ ] Step 3: `chronicle_is_good M sig atomMap (operator_depth phi + 1)`
  - [ ] Step 4: `obtain Z, h_equiv from good`
  - [ ] Step 5: Use `k_equiv_preserves_temporal_truth` to transfer `neg phi` truth from chronicle to Z-model
  - [ ] Step 6: Construct TaskFrame Int, TaskModel, Omega, tau from Z-model; prove `neg truth_at`
  - [ ] Remove the chronicle fallback entirely
- [ ] **Final verification**: `#print axioms bx_completeness` shows no `sorryAx`

**Timing**: 5 hours

**Depends on**: 5

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Transfer.lean` - Replace fallback with full pipeline, add TaskFrame Int construction
- Possibly `Theories/Bimodal/Metalogic/WeakCanonical/TruthTransfer.lean` - TaskFrame correspondence theorem

**Verification**:
- `#print axioms doets_countermodel_discrete` shows no `sorryAx`
- `#print axioms bx_completeness` shows no `sorryAx`
- `lake build` passes cleanly
- Chronicle fallback code removed from Transfer.lean

---

## Testing & Validation

- [ ] `lake build` passes with zero errors
- [ ] `#print axioms bx_completeness` outputs only: `propext`, `Classical.choice`, `Quot.sound`, `Lean.ofReduceBool`, `Lean.trustCompiler` (NO `sorryAx`)
- [ ] `#print axioms doets_countermodel_discrete` shows no `sorryAx`
- [ ] `#print axioms chronicle_is_good` shows no `sorryAx`
- [ ] `#print axioms finite_structures_good` shows no `sorryAx`
- [ ] `#print axioms k_equiv_preserves_eval` shows no `sorryAx`
- [ ] The chronicle fallback (`dd_countermodel_chronicle_discrete`) is no longer called from Transfer.lean
- [ ] No new `sorry` introduced anywhere in the codebase

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel.lean` - All 5 sorries closed
- `Theories/Bimodal/Metalogic/WeakCanonical/Transfer.lean` - Full pipeline, no fallback
- `Theories/Bimodal/Metalogic/WeakCanonical/TruthTransfer.lean` (new) - k_equiv_preserves_eval, temporal truth transfer, TaskFrame Int construction
- `specs/155_reynolds_pipeline_activation/plans/01_reynolds-pipeline-plan.md` - This plan

## Rollback/Contingency

If implementation encounters a fundamental blocker (e.g., `finite_structures_good` requires infrastructure not present):

1. **Partial progress is safe**: Each phase closes independent sorries. Phases 1-4 can be committed individually without breaking the build (the chronicle fallback remains active until Phase 6).
2. **Revert pipeline wiring only**: If Phase 6 fails, Phases 1-5 still provide value (sorry-free IntegerModel.lean + truth transfer infrastructure). Revert Transfer.lean to fallback state.
3. **Alternative for Phase 1**: If predicate extension approach fails, consider redefining `ZIntervalStructure.toOrdered` to restrict carrier to the interval (approach A from research). This changes the meaning of `good` but may be simpler.
4. **Alternative for Phase 5**: If `k_equiv_preserves_eval` requires too much infrastructure, consider approach (C) from research: prove the chronicle's FMCS structure transfers through k-equivalence, reusing `ParametricCanonicalTaskFrame` directly.
