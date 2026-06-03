# Implementation Plan: Task #273

- **Task**: 273 - Prove chronicle_gap_contradiction directly from the omega-chain construction
- **Status**: [BLOCKED]
- **Effort**: 8 hours
- **Dependencies**: None (all required infrastructure is sorry-free)
- **Research Inputs**: specs/273_chronicle_gap_contradiction_proof/reports/01_gap-contradiction-research.md
- **Artifacts**: plans/01_gap-contradiction-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

This plan addresses the sole remaining `sorry` blocking `completeness_discrete` in the BimodalLogic project. The sorry is at `chronicle_gap_contradiction` (ChronicleToCountermodel.lean:481), which feeds the chain: `succ_cofinal` -> `limitDomSubtype_isSuccArchimedean` -> `succ_embed_surjective` -> `cantor_bfmcs_discrete_restricted_tc/fuc` -> `countermodel_discrete_reynolds` -> `completeness_discrete`.

The research report concluded all three analyzed approaches (model surgery, stage induction, Z1 semantic) are blocked. However, careful codebase examination reveals that the research report's analysis of the model surgery approach missed a crucial detail: the `contemp_equiv` triviality argument (Section 5A of the report) is correct for *bounded* intervals, but `chronicle_gap_contradiction` operates on `LimitDomSubtype` which is *unbounded* (it has `NoMaxOrder` and `NoMinOrder`). The `one_class` theorem from `NoGapsDiscreteProof.lean` -- which IS sorry-free and does NOT require `IsSuccArchimedean` -- establishes that all points of `LimitDomSubtype` are `contemp_equiv`. Combined with the orbit being bounded by `b`, this means `a` and `b` are `contemp_equiv` at every depth, which is trivially true and provides no contradiction on its own. The report is correct that model surgery alone is insufficient.

The viable strategy is a **two-pronged approach**: (A) primarily, restructure the completeness pipeline to bypass `chronicle_gap_contradiction` entirely by completing `countermodel_discrete_reynolds_v2` (Strategy B from ReynoldsBridge.lean), which only needs a Z-interval-to-TaskModel conversion step; or (B) if Strategy B proves too complex, attempt a direct proof of `chronicle_gap_contradiction` using the Z1 axiom and well-founded induction on the gap structure.

### Research Integration

The research report (01_gap-contradiction-research.md) identified that:
1. The model surgery approach via `contemp_equiv` cannot detect gaps within bounded sub-intervals (Section 5A -- confirmed correct).
2. Stage induction on `succ_reaches_dom_N` is blocked at boundary cases (Section 5B -- confirmed, dead code at lines 80-381).
3. The Z1 axiom approach has circularity issues (Section 5C -- partially correct, but the report did not explore well-founded descent on domain index).
4. Strategy B (ReynoldsBridge.lean) is blocked on Z-interval-to-TaskModel conversion (Section 5D -- confirmed, sorry at line 489).

The research correctly identifies Strategy B (option c in Section 12) as potentially most tractable. This plan prioritizes completing Strategy B.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No ROADMAP.md found.

## Goals & Non-Goals

**Goals**:
- Eliminate `sorryAx` from `completeness_discrete` by removing the sorry at `chronicle_gap_contradiction` or bypassing it entirely
- Maintain all existing sorry-free lemmas and theorems
- Ensure `lake build` succeeds with no sorry in the completeness chain

**Non-Goals**:
- Fixing unrelated sorries (dead code `succ_reaches_dom_N` sorries at lines 218, 374)
- Modifying the dense completeness pipeline
- Changing the abstract model surgery infrastructure
- Completing the general `completeness` theorem (which has separate sorries via `countermodel_discrete` dead code)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Strategy B Z-interval conversion is harder than expected | H | M | Fall back to direct proof of chronicle_gap_contradiction via Z1/well-founded approach |
| k-equivalence truth transfer requires additional lemmas about effectiveFormula | M | M | The `effectiveFormula_id_self` and `effectiveFormula_id_neg` are already proved; extend pattern |
| Direct proof of chronicle_gap_contradiction encounters new circularity | H | M | Document blocker precisely and investigate alternative proof orderings |
| New code introduces import cycles | M | L | Follow existing file split architecture (ChronicleToCountermodelBasic vs ChronicleToCountermodel) |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Complete Strategy B -- Z-Interval to TaskModel Bridge [BLOCKED]

**Goal**: Close the sorry at `countermodel_discrete_reynolds_v2` (ReynoldsBridge.lean:489) by building a TaskModel on Z from the k-equivalent Z-interval structure.

**BLOCKER** (Phase 1):
- **What failed**: The Z-interval-to-TaskModel truth correspondence (`h_truth_corr`) is unsatisfiable under all three explored TaskFrame architectures.
- **What was tried**:
  1. **WorldState=Unit (zIntervalTaskFrame)**: `truth_at` atoms evaluate `TM.valuation () a` which is position-independent, but `temporal_truth` atoms evaluate `Z.interp (atomMapFwd (.atom a)) t.val` which is position-dependent. The biconditional fails for any formula with non-constant predicates.
  2. **WorldState=(sig.preds -> Prop), singleton Omega**: ShiftClosed fails because `tau.time_shift Delta` has different states at each position (states shift with Delta), so `tau.time_shift Delta != tau`.
  3. **WorldState=(sig.preds -> Prop), orbit-based Omega**: ShiftClosed holds, but box transparency breaks. `truth_at (.box psi) t` becomes `forall Delta, truth_at (tau.time_shift Delta) t psi = forall s, temporal_truth s psi`, which does NOT match `temporal_truth (.box psi) = Z.interp (atomMapFwd (.box psi)) t.val` (a predicate lookup). The S5 transfer property `Z.interp (atomMapFwd (.box psi)) t <-> forall s, temporal_truth s psi` IS provable in principle (from one_class + k-equivalence on universal sentences) but requires ~300 lines of new infrastructure.
  4. **Discrete fixpoint propagation**: Attempted to prove restricted_tc/restricted_fuc without succ_embed_surjective by propagating F(phi) through the succ chain. Blocked because `until_persists_through_succ` (SuccRelation.lean:588) has a sorry due to open-guard semantics (task 173 tombstone).
- **Why it's stuck**: Three mutually exclusive requirements -- (1) position-dependent atoms, (2) box transparency, (3) shift-closed Omega -- under the current TaskFrame architecture. The S5 orbit approach (option 3 above with additional infrastructure) is the most viable path but requires significant new lemma development.
- **What is needed**: Either (A) ~300 lines of S5 transfer infrastructure proving `Z.interp (atomMapFwd (.box psi)) t <-> forall s, temporal_truth s psi` via k-equivalence on universal sentences, OR (B) a different proof of chronicle_gap_contradiction (see Phase 3).
- **Prohibited workarounds**: Do NOT use `sorry`, `def X := True`, or any vacuous placeholder.

**Tasks**:
- [x] **Task 1.1**: Examine the exact type obligations at ReynoldsBridge.lean:489 -- what existentials remain to be filled *(completed -- obligation is to produce the full countermodel existential package from the Z-interval)*
- [x] **Task 1.2**: Use `limitdom_is_good` (sorry-free) to obtain the Z-interval and k-equivalence *(completed -- already wired in existing code at line 478-480)*
- [ ] **Task 1.3**: Use `truth_transfer` to transfer `temporal_truth` of `phi.neg` *(deviation: deferred -- blocked by truth correspondence impossibility, see BLOCKER)*
- [ ] **Task 1.4**: Build a `BFMCS Int` from the Z-interval structure *(deviation: skipped -- approach proven non-viable, Z-interval only provides predicate info not MCS structure)*
- [ ] **Task 1.5**: Build TaskModel on Z-interval directly *(deviation: skipped -- WorldState=Unit gives position-independent atoms, see BLOCKER)*
- [ ] **Task 1.6**: Lift temporal_truth to truth_at *(deviation: skipped -- blocked by BLOCKER)*
- [ ] **Task 1.7**: Build on Z-interval carrier as finite subtype of Int *(deviation: skipped -- D must have AddCommGroup, subtype doesn't)*
- [ ] **Task 1.8**: Use parametric canonical model construction *(deviation: skipped -- requires BFMCS which needs succ_embed_surjective)*
- [ ] **Task 1.9**: Embed Z-interval periodically into Int *(deviation: skipped -- periodic extension still requires truth correspondence proof)*

**Timing**: 2 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/ReynoldsBridge.lean` -- complete the sorry at line 489

**Verification**:
- `lake build Bimodal.Metalogic.WeakCanonical.IntegerModel.ReynoldsBridge` succeeds
- `countermodel_discrete_reynolds_v2` compiles without sorry

---

### Phase 2: Rewire completeness_discrete to Use Strategy B [BLOCKED]

**Goal**: Replace the call to `countermodel_discrete_reynolds` (Transfer.lean:1203) with `countermodel_discrete_reynolds_v2` (ReynoldsBridge.lean:462) in `completeness_discrete` (Completeness.lean:369), eliminating the dependency on `succ_embed_surjective` and thus on `chronicle_gap_contradiction`.

**Tasks**:
- [ ] Compare the type signatures of `countermodel_discrete_reynolds` (Transfer.lean:1203) and `countermodel_discrete_reynolds_v2` (ReynoldsBridge.lean:462) -- they should both produce the same existential type
- [ ] Verify that `countermodel_discrete_reynolds_v2` only takes `FrameClass.Discrete` (not a general `fc`), while Completeness.lean also uses `FrameClass.Discrete` -- should be compatible
- [ ] Update `completeness_discrete` (Completeness.lean:369) to call `countermodel_discrete_reynolds_v2` instead of `countermodel_discrete_reynolds`
- [ ] Handle any argument differences (v2 may not take `h_fc` since it assumes `FrameClass.Discrete` directly)
- [ ] Update import statements in Completeness.lean if needed (add `import Bimodal.Metalogic.WeakCanonical.IntegerModel.ReynoldsBridge`)
- [ ] Verify no import cycles are introduced

**Timing**: 1 hour

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` -- change line 369 to use v2

**Verification**:
- `lake build Bimodal.Metalogic.BXCanonical.Completeness` succeeds
- `#print axioms completeness_discrete` shows no `sorryAx`

---

### Phase 3: Prove chronicle_gap_contradiction (Fallback / Parallel Goal) [BLOCKED]

**Goal**: If Strategy B (Phases 1-2) fails or proves too complex, prove `chronicle_gap_contradiction` directly. Even if Strategy B succeeds, this proof has independent value for closing dead code sorries and strengthening the theory.

**Strategy**: Use the Z1 axiom (`G(Gphi -> phi) -> (FGphi -> Gphi)`) with well-founded induction on a decreasing measure derived from the MCS structure at the gap boundary.

**BLOCKER** (Phase 3):
- **What failed**: All three analyzed direct proof approaches for `chronicle_gap_contradiction` are blocked.
- **What was tried**:
  1. **Model surgery approach (Case A: limit_f(a) != limit_f(b))**: The existing commented-out proof (ChronicleToCountermodel.lean lines 496-756) builds a one-predicate monadic structure and attempts to use `gap_contradicts_prior`. However, `one_class` (NoGapsDiscreteProof.lean, sorry-free) proves ALL points are `contemp_equiv` at every depth k. This means `gap_contradicts_prior`'s hypothesis `h_bounded_above` (exists y > a not contemp_equiv to a) is NEVER satisfiable -- the gap doesn't create a contemp_equiv class boundary. The two sub-sorries at lines 736 (k=0 vs k>=1 for h_not_equiv_ab) and 756 (symmetric case) are moot because even at k>=1, one_class still proves all pairs are contemp_equiv.
  2. **Model surgery approach (Case B: limit_f(a) = limit_f(b))**: When MCS values are identical at a and b, there is no distinguishing predicate. The Z+Z counterexample shows abstract model surgery cannot detect this gap. A proof requires omega-chain stage-level reasoning (300-600 lines of new infrastructure) showing that the limit successor function covers all domain points between any two points.
  3. **Z1 axiom approach**: The Z1 axiom `G(Gphi->phi) -> (FGphi->Gphi)` encodes IsSuccArchimedean, but applying it requires a formula phi whose truth pattern detects the gap. In Case B (constant MCS), no such formula exists in the object language since all points have identical MCS. In Case A, the argument leads to: Z1 + distinguishing formula -> well-founded descent on the gap -> requires showing succ-orbit accumulation point is in the domain, which is equivalent to proving the gap doesn't exist (circular).
  4. **Omega-chain stage argument**: At each finite stage N, the domain is finite and IsSuccArchimedean holds trivially. Both a and b appear at some stage N. At the limit, the successor function may differ from stage-N successor (new points inserted). Proving that the limit succ-orbit from a reaches b requires showing the orbit doesn't accumulate at a non-domain rational -- this is exactly the gap contradiction, making the argument circular without new infrastructure for stage-limit agreement of the successor function.
- **Why it's stuck**: The fundamental mathematical difficulty: in a general countable discrete linear order on rationals (with no max/no min), omega-gaps CAN exist (e.g., Z+Z). The proof that the chronicle construction's limit domain avoids such gaps requires exploiting the SPECIFIC structure of the counterexample enumeration and point insertion process, not just abstract properties like Prior-UZ/SZ or one_class. This stage-level reasoning has not been developed.
- **What is needed**: A proof approach that works at the omega-chain construction level, showing that for any two points a, b in the limit domain with a < b, the counterexample enumeration process ensures that the limit successor function covers all domain points between a and b. This likely requires ~300-600 lines of new infrastructure including: (a) lemmas about stage-N successor agreement with limit successor for co-stage points, (b) lemmas about how point insertion between stage-N adjacent pairs affects the succ chain, (c) a well-founded induction argument on the finite stage at which both a and b are present.
- **Prohibited workarounds**: Do NOT use `sorry`, `def X := True`, or any vacuous placeholder.

**Tasks**:
- [ ] Formalize the following argument outline:
  - Given `a < b` with `forall n, succ^[n] a < b`
  - The sequence `succ^[n] a` is strictly increasing (by `limitDomSubtype_succ_iter_lt`) and bounded above by `b`
  - Therefore `{succ^[n] a | n : Nat}` is a countable set of rationals with a supremum `c = sup{succ^[n](a).val | n}` satisfying `c <= b.val`
  - Since `limit_dom` is a countable union of finite sets, `c` may or may not be in `limit_dom`
  - **Case 1**: `c in limit_dom`. Then `succ(c)` is defined. Since `c >= succ^[n] a` for all `n`, and `succ^[n] a` approaches `c`, by discreteness `succ^[n] a = c` for some `n` (the orbit eventually stabilizes). But `succ(c) > c` and `succ(c) <= b` (since `c < b` and `succ_le_iff`). Then `succ^[n+1] a = succ(c) > c`, contradicting `c = sup`.
  - **Case 2**: `c not in limit_dom`. Then the orbit `{succ^[n] a.val}` converges to a non-domain rational. Pick any `d in limit_dom` with `d > c` (exists since `b > c` and `b in limit_dom`). Then `succ^[n] a < d` for all `n`. By `succ_le_iff`, `succ(succ^[n] a) <= d` for all `n`. But `succ(succ^[n] a) = succ^[n+1] a`, so `succ^[n+1] a <= d` for all `n`. Taking the supremum: `c <= d`. If `d <= b`: the orbit is bounded by `d < b` (if `d < b`), and the argument recurses.
  - The key mathematical point: the supremum argument requires showing that a monotone sequence of rationals from `limit_dom` that is bounded above must eventually reach its bound (since `limit_dom` is discrete and each step increments by at least the gap to the next successor). This is equivalent to IsSuccArchimedean and is therefore circular.
- [ ] **Alternative Z1 argument** (non-circular):
  - Consider the formula `psi` defined as `G(top) -> top`, which is trivially true
  - The Z1 instance `G(G(psi) -> psi) -> (FG(psi) -> G(psi))` for any `psi` is in every MCS
  - Choose `psi` to be a formula witnessing the gap: if `limit_f(a) != limit_f(b)`, pick `chi` in the symmetric difference
  - `G(chi)` fails at `a` (since `chi` fails somewhere in the orbit)
  - `FG(chi)` holds at `a` if `chi` eventually holds forever beyond some point
  - This seems to require knowing the MCS structure at every orbit point, which depends on the specific counterexample enumeration
- [ ] If the Z1 approach remains circular, document the precise mathematical obstruction and mark this phase [BLOCKED]
- [ ] If successful, replace the `sorry` at ChronicleToCountermodel.lean:481

**Timing**: 2 hours (may be marked BLOCKED)

**Depends on**: 2 (attempt after Strategy B is evaluated)

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` -- replace sorry at line 481

**Verification**:
- If successful: `lake build Bimodal.Metalogic.BXCanonical.Chronicle.ChronicleToCountermodel` with no sorry
- If blocked: document obstruction in plan, mark [BLOCKED]

---

### Phase 4: Full Build Verification and Axiom Audit [NOT STARTED]

**Goal**: Verify that the entire project builds without `sorryAx` in the completeness chain and document the resolution.

**Tasks**:
- [ ] Run `lake build` for the full project
- [ ] Run `#print axioms completeness_discrete` and verify `sorryAx` is absent
- [ ] If Phase 3 was successful, also verify `#print axioms chronicle_gap_contradiction` is sorry-free
- [ ] Update the docstring comments in ChronicleToCountermodel.lean (lines 55-74) to reflect the resolution
- [ ] Update the axiom audit block in Completeness.lean (lines 376-398) to document the new status
- [ ] If Strategy B was used: update comments noting that `chronicle_gap_contradiction` is no longer on the critical path for `completeness_discrete`

**Timing**: 1 hour

**Depends on**: 2 (or 3 if attempting direct proof)

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` -- update axiom audit comments
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` -- update docstrings

**Verification**:
- `lake build` succeeds for the full project
- `#print axioms completeness_discrete` shows only `[propext, Classical.choice, Lean.ofReduceBool, Lean.trustCompiler, Quot.sound]` (no `sorryAx`)

## Testing & Validation

- [ ] `lake build` completes without errors
- [ ] `#print axioms Bimodal.Metalogic.BXCanonical.completeness_discrete` does not include `sorryAx`
- [ ] Existing tests in `Tests/BimodalTest/` continue to pass
- [ ] No new `sorry` introduced (grep verification)
- [ ] Import graph remains acyclic

## Artifacts & Outputs

- `specs/273_chronicle_gap_contradiction_proof/plans/01_gap-contradiction-plan.md` (this file)
- Modified `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/ReynoldsBridge.lean`
- Modified `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean`
- Optionally modified `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean`
- `specs/273_chronicle_gap_contradiction_proof/summaries/01_gap-contradiction-summary.md`

## Rollback/Contingency

- If Strategy B (Phases 1-2) fails: the codebase remains unchanged; document the blocker and evaluate whether the Z-interval-to-TaskModel conversion needs its own research task
- If Phase 3 (direct proof) is blocked: this is expected and acceptable as long as Strategy B succeeds. The `chronicle_gap_contradiction` sorry can remain as dead code (not on the critical path)
- Git revert to the commit before implementation if any phase introduces regressions
- If import cycles are introduced: restore original import structure and restructure the new code into a separate file
