# Implementation Plan: Task #107 (v17 -- BurgessR3 Primary, Cruft Purge)

- **Task**: 107 - Burgess chronicle construction for BX representation theorem
- **Status**: [IN PROGRESS]
- **Effort**: 20 hours (remaining)
- **Dependencies**: None (irr_until branch)
- **Research Inputs**: [reports/28_team-research.md], [reports/29_team-research.md], [reports/30_team-research.md], [reports/30_teammate-a-findings.md], [reports/30_teammate-c-findings.md], [reports/30_teammate-d-findings.md]
- **Artifacts**: plans/30_implementation-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Round 30 team research (4 teammates, unanimous) resolved the fundamental blocker: the codebase's `rRelation` (obligation propagation, monotone in B) and Burgess's `r(A, B, C)` (content-based, anti-monotone in B) are genuinely different relations. R3Maximal does NOT imply burgessR3. The codebase already has sorry-free `burgessR3` infrastructure in RRelation.lean. The fix is to adopt `burgessR3` as the primary chronicle relation, define `BurgessR3Maximal`, replace `R3Maximal` with `BurgessR3Maximal` in ChronicleInvariant c2', seed with `deductiveClosure(g_content(f(x)) union h_content(f(y)))`, and reprove lemma_2_6 using burgessR3 maximality failure witness. This plan begins with a cruft purge (Phase 1.5) to remove dead code and failed approaches before the architectural changes.

### Research Integration

- Report 28 (team research): Identified root cause -- g-values never populated. Recommended Phases 2-6 for g-population.
- Report 29 (team research, 4 teammates): Debunked forward_G/C4 circularity claim. Density axioms NOT needed. C4 hard case resolves via Lemma 2.6.
- Report 30 (team research, 4 teammates): **Primary input for this revision.** Confirmed rRelation vs burgessR3 gap is real. Mapped existing sorry-free burgessR3 infrastructure. Resolved conflict: limit_forward_G IS circular (Teammate B wrong). Produced complete Burgess lemma map. Identified A3a/strict semantics risk for C5 n>0 case (mitigated: current code only uses n=0). Comprehensive cruft audit.
- Report 30 Teammate A: Definitive proof that rRelation and burgessR are independent properties. Neither implies the other. Mapped notation: Burgess U(alpha, beta) = codebase untl(beta, alpha).
- Report 30 Teammate C: Validated gap claim. Identified seed strategy for BurgessR3Maximal existence. Confirmed lemma_2_6_full needs burgessR3 maximality, not R3Maximal.
- Report 30 Teammate D: Complete Burgess Section 2 lemma map. Identified that Lemmas 2.7/2.8 use A3a (invalid under strict semantics), but only for C5 n>0 case which the current construction avoids.

### Prior Plan Reference

Plan v16 (artifact 29): 6-phase structure. Phase 1 [COMPLETED] (guard axioms). Phases 2-6 [NOT STARTED] or [IN PROGRESS]. Phase 5 used an r-relation bridging lemma based on the codebase's `R3Maximal`, which round 30 research proved is the WRONG relation. This revision replaces R3Maximal with BurgessR3Maximal throughout, adds a cruft purge phase, and restructures the C4 proof to use burgessR3 contradiction.

### Roadmap Alignment

- Advances: "TM is complete with respect to TaskFrames over totally ordered abelian groups" (representation theorem)
- Chronicle pathway is the primary completeness path (ROADMAP Section 2)
- Closing the final 4 sorry sites achieves the chronicle sorry-free milestone

## Goals & Non-Goals

**Goals**:
- Delete cruft: g_ordered, h_ordered, claim_2_11 stub, vacuous g := fun _ _ => empty, stale comments
- Define BurgessR3Maximal(A, B, C) using burgessR3 (anti-monotone, content-based)
- Replace R3Maximal with BurgessR3Maximal in ChronicleInvariant c2'
- Prove BurgessR3Maximal existence via seed with deductiveClosure(g_content(f(x)) union h_content(f(y)))
- Reprove lemma_2_6 using burgessR3 maximality failure witness
- Populate g-values in every elimination function using BurgessR3Maximal construction
- Close C4 hard sub-case: gamma not in g(x,y) by burgessR3 contradiction, then apply lemma_2_6
- Prove g-immutability and define proper limit_g with C3 at the limit
- Close restricted_fuc sorry sites via until_guard + limit_g + C3
- Delete dead code (chronicle_fmcs, chronicle_bfmcs)
- Achieve sorry-free dd_countermodel_chronicle
- Maintain lake build at each phase boundary

**Non-Goals**:
- Adding density axioms (GG->G, HH->H) -- debunked, wrong for BX
- Using limit_forward_G to close C4 (circular dependency)
- Proving R3Maximal implies burgessR3 (false in general)
- Bypassing finite-stage C4 proof -- follow Burgess's architecture exactly
- Case-splitting on G(gamma)/H(gamma) in C4 elimination
- Deleting rRelation or R3Maximal -- existing sorry-free code uses them; keep as derived properties
- General completeness for all strict linear orders (separate task)
- BXCanonical sorry closure (task 109)
- C5 n>0 case (insert between existing points) -- current construction avoids it

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| BurgessR3Maximal existence proof is non-trivial (Zorn's lemma on anti-monotone property) | H | M | The seed strategy (deductiveClosure of g_content union h_content) provides a concrete starting point. burgessR3 holds for the seed by construction. Use chain union argument: union of chain of burgessR3-satisfying DCS preserves burgessR3 (straightforward from definition). |
| Replacing R3Maximal with BurgessR3Maximal in ChronicleInvariant cascades through many files | H | H | Do the replacement surgically: only c2' field changes. Keep R3Maximal alive for any existing sorry-free code that depends on it. Derive R3Maximal from BurgessR3Maximal where needed (BurgessR3Maximal is strictly stronger). |
| burgessR3 maximality failure witness has a different form than R3Maximal failure witness | M | M | burgessR3 is anti-monotone: if B is BurgessR3Maximal and delta not in B, then adding delta to B breaks burgessR3. The witness is: there exist beta in B+delta, gamma in C such that untl(beta, gamma) not in A. This is the correct form for the C4 contradiction argument. |
| lemma_2_6_full interface may need rewriting for BurgessR3Maximal | M | M | Current lemma_2_6_full takes R3Maximal. Will need a BurgessR3Maximal variant. If the internal proof uses only DCS + maximality + negation completeness, a thin adapter suffices. If it uses rRelation-specific properties, more work needed. |
| A3a invalidity blocks Lemma 2.7/2.8 for C5 n>0 | L | L | The current omega chain construction only uses C5 n=0 (adding after all points). C5 n>0 is not needed. Do not implement it. |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 0 | 1 | -- (completed) |
| 1 | 1.5 | Phase 1 (completed) |
| 2 | 2 | 1.5 |
| 3 | 3 | 2 |
| 4 | 4, 5 | 3 |
| 5 | 6 | 4, 5 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Add until_guard / since_guard Axioms [COMPLETED]

**Goal**: Add sound axioms `until_guard : untl phi psi -> phi` and `since_guard : snce phi psi -> phi` to the BX axiom system, with soundness proofs.

**Tasks**:
- [x] Add `until_guard` constructor to the `Axiom` inductive type in `ProofSystem/Axioms.lean`
- [x] Add `since_guard` constructor (mirror)
- [x] Prove soundness of `until_guard` in `Soundness.lean`
- [x] Prove soundness of `since_guard` in `Soundness.lean`
- [x] Verify `DenseSoundness.lean` and `DiscreteSoundness.lean` still compile
- [x] Prove `until_guard_in_mcs` and `since_guard_in_mcs` for MCS S
- [x] Run lake build and verify no regressions

**Timing**: 2 hours (completed)

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/ProofSystem/Axioms.lean` -- new constructors
- `Theories/Bimodal/Metalogic/Soundness.lean` -- soundness cases
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/RRelation.lean` -- MCS-level lemmas

**Verification**:
- until_guard and since_guard in Axiom type
- Soundness.lean remains sorry-free
- MCS-level lemmas compile without sorry
- lake build succeeds

---

### Phase 1.5: Cruft Purge [COMPLETED]

**Goal**: Remove dead code, failed approaches, and stale artifacts before the architectural changes. Clean slate for BurgessR3 adoption.

**Tasks**:
- [ ] Delete `g_ordered` and `h_ordered` definitions (ChronicleTypes.lean, lines 449-473 approximately)
- [ ] Delete `claim_2_11` tautological stub (proves phi in f(x) iff phi in f(x))
- [ ] Replace the vacuous `g := fun _ _ => empty` in `singleton_chronicle` with `sorry` placeholder (to be filled in Phase 3 with actual BurgessR3Maximal construction)
- [ ] Remove stale "Phase 2" comments in PointInsertion.lean
- [ ] Remove stale "Phase 2" comments in CounterexampleElimination.lean
- [ ] Remove `g_content_chain_property` stale references/comments
- [ ] Delete dead code: `chronicle_fmcs`, `chronicle_bfmcs` and their 8 sorry sites in ChronicleToCountermodel.lean (confirmed dead -- dd_countermodel_chronicle uses only cantor_fmcs/cantor_bfmcs)
- [ ] Audit for any other vestiges of failed approaches (vacuous g-function usage, density axiom references)
- [ ] Run lake build and verify no regressions

**Timing**: 2 hours

**Depends on**: Phase 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleTypes.lean` -- delete g_ordered, h_ordered, claim_2_11
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleConstruction.lean` -- fix singleton_chronicle g, remove stale comments
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean` -- remove stale comments
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean` -- remove stale comments
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` -- delete chronicle_fmcs, chronicle_bfmcs

**Verification**:
- g_ordered, h_ordered, claim_2_11 no longer in codebase
- chronicle_fmcs, chronicle_bfmcs deleted (8 sorry sites removed)
- No vacuous g := fun _ _ => empty (except explicit sorry placeholder in singleton_chronicle)
- No stale "Phase 2" comments
- lake build succeeds
- Sorry count change: -8 (dead code deletion)

---

### Phase 2: Define BurgessR3Maximal and Prove Existence [COMPLETED]

**Goal**: Define BurgessR3Maximal as the primary r-maximality concept using burgessR3 (anti-monotone, content-based), prove existence via Zorn's lemma with seed construction, and update ChronicleInvariant c2' to use BurgessR3Maximal.

**Tasks**:
- [ ] Define `BurgessR3Maximal(A, B, C)` in ChronicleTypes.lean or RRelation.lean:
  ```
  def BurgessR3Maximal (A B C : Set Formula) : Prop :=
    SetDeductivelyClosed B ∧
    burgessR3 A B C ∧
    ∀ D, SetDeductivelyClosed D → B ⊂ D → ¬burgessR3 A D C
  ```
- [ ] Prove `BurgessR3Maximal_is_mcs`: BurgessR3Maximal(A, B, C) implies B is an MCS. Key: burgessR3 is anti-monotone in B, so maximality does NOT collapse to MCS trivially (unlike R3Maximal). Proof: assume B is not MCS, then there exists phi such that phi not in B and neg(phi) not in B. Adding phi preserves burgessR3 (anti-monotonicity argument with deductive closure), contradicting maximality.
- [ ] Prove BurgessR3Maximal existence: Given MCS A, C with appropriate content:
  - Define seed: `deductiveClosure(g_content(A) union h_content(C))` where g_content extracts guard formulas from Until formulas in A and h_content extracts guard formulas from Since formulas in C
  - Prove seed satisfies burgessR3(A, seed, C): for beta in seed and gamma in C, untl(beta, gamma) in A follows because beta is a guard for A's Until formulas by construction
  - Apply Zorn's lemma on the poset of DCS satisfying burgessR3(A, -, C), ordered by subset
  - Chain union preserves burgessR3: straightforward from definition (universal quantifier over elements of B)
  - Obtain maximal element
- [ ] Update ChronicleInvariant c2' field: replace `R3Maximal (chi.f x) (chi.g x y) (chi.f y)` with `BurgessR3Maximal (chi.f x) (chi.g x y) (chi.f y)`
- [ ] Prove `BurgessR3Maximal_implies_r3Relation`: derive r3Relation from burgessR3 + MCS, for backward compatibility with existing sorry-free lemmas that use r3Relation
- [ ] Update any code that directly pattern-matches on c2' to handle BurgessR3Maximal structure
- [ ] Run lake build and verify

**Timing**: 5 hours

**Depends on**: Phase 1.5

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/RRelation.lean` -- BurgessR3Maximal definition, existence proof, MCS proof, backward compatibility lemma
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleTypes.lean` -- update c2' in ChronicleInvariant
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean` -- update any c2' pattern matches
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean` -- update any c2' pattern matches

**Verification**:
- BurgessR3Maximal defined using burgessR3
- BurgessR3Maximal_is_mcs proved sorry-free
- BurgessR3Maximal existence proved sorry-free
- ChronicleInvariant c2' uses BurgessR3Maximal
- BurgessR3Maximal_implies_r3Relation proved sorry-free
- lake build succeeds
- No new sorry sites introduced (may temporarily add sorry in singleton_chronicle g-construction)

---

### Phase 3: Populate g-values in All Elimination Functions [BLOCKED]

**Goal**: Every elimination function (C5, C5', C4, C4', density, g_prop, h_prop) produces BurgessR3Maximal g-values for adjacent pairs. The singleton_chronicle also gets a proper g-construction. After this phase, g-values are non-empty at every finite stage.

**Tasks**:
- [ ] Extend EliminationResult with g-agreement field carrying BurgessR3Maximal condition for adjacent pairs in the new domain
- [ ] Implement singleton_chronicle g-construction: for the initial singleton domain {x}, there are no adjacent pairs, so g is vacuously satisfying. For the first extension to {x, y}, use BurgessR3Maximal existence (Phase 2) to construct g(x, y)
- [ ] Modify C5 elimination (`eliminate_C5_counterexample`): when inserting point z after all existing points, set g(prev, z) using BurgessR3Maximal existence with seed = deductiveClosure(g_content(f(prev)) union h_content(f(z))). Carry forward all existing g-values
- [ ] Modify C5' elimination (mirror)
- [ ] Modify C4 elimination (`eliminate_C4_counterexample`): when inserting point z between x and y, set g(x,z) and g(z,y) using Lemma 2.6 (interval splitting). The key: Lemma 2.6 takes BurgessR3Maximal(f(x), g(x,y), f(y)) and splits into BurgessR3Maximal(f(x), g(x,z), f(z)) and BurgessR3Maximal(f(z), g(z,y), f(y))
- [ ] Modify C4' elimination (mirror)
- [ ] Modify density elimination: construct g for new adjacent pairs using BurgessR3Maximal existence
- [ ] Modify g_prop and h_prop elimination: construct g using BurgessR3Maximal existence
- [ ] Prove g-preservation: for pairs (a,b) already in domain where neither is the new point, new_chi.g(a,b) = chi.g(a,b)
- [ ] Prove g-agreement: all new g-values satisfy BurgessR3Maximal
- [ ] Run lake build and verify

**Timing**: 5 hours

**Depends on**: Phase 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean` -- EliminationResult extension, all elimination functions
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleConstruction.lean` -- call sites, singleton_chronicle g, pass ChronicleInvariant
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean` -- Lemma 2.6 with BurgessR3Maximal

**Verification**:
- EliminationResult has g-agreement field using BurgessR3Maximal
- All elimination functions set non-empty g-values
- g-agreement proved for all cases
- g-preservation proved for all cases
- singleton_chronicle has proper g-construction (no sorry)
- lake build succeeds
- No new sorry sites

---

### Phase 4: Prove g-Immutability and Define limit_g with C3 [NOT STARTED]

**Goal**: Prove g-values are immutable once set, define limit_g as the stable finite-stage value, and prove C2' (BurgessR3Maximal) and C3 at the limit.

**Tasks**:
- [ ] Prove g-immutability lemma: for m >= n >= first_stage(x,y), `(omega_chain_val m).g x y = (omega_chain_val n).g x y`. Follows from Phase 3's g-preservation proof
- [ ] Define `limit_g(x,y) = (omega_chain_val N).g x y` where N is the first stage with both x and y in the domain. Use `Nat.find` with decidability
- [ ] Prove limit_g is well-defined: for any x,y in limit_dom, the required N exists
- [ ] Prove C2' at limit: `BurgessR3Maximal (limit_f x) (limit_g x y) (limit_f y)` for adjacent x,y. Reduce to C2' at finite stage N using f-immutability and g-immutability
- [ ] Prove limit_c3: `limit_g(x,z) = limit_g(x,y) inter limit_f(y) inter limit_g(y,z)` for x < y < z in limit_dom. Reduce to C3 at finite stage using immutability
- [ ] Prove `c3_interval_subset_point`: for x < y < z, `limit_g(x,z) subset limit_f(y)`. Immediate from limit_c3
- [ ] Prove `limit_g_is_mcs`: limit_g(x,y) is an MCS for adjacent x,y. From limit C2' + BurgessR3Maximal_is_mcs
- [ ] Run lake build and verify

**Timing**: 4 hours

**Depends on**: Phase 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleConstruction.lean` -- g-immutability, limit_g definition, limit_c3, c3_interval_subset_point

**Verification**:
- g-immutability proved sorry-free
- limit_g defined using Nat.find
- limit C2' (BurgessR3Maximal) proved sorry-free
- limit_c3 proved sorry-free
- c3_interval_subset_point proved sorry-free
- limit_g_is_mcs proved sorry-free
- lake build succeeds

---

### Phase 5: Close C4/C4' Hard Sub-Case via burgessR3 Contradiction + Lemma 2.6 (2 Sorry Sites) [NOT STARTED]

**Goal**: Close the 2 sorry sites at CounterexampleElimination.lean (C4 hard case and C4' hard case) using burgessR3 contradiction to show gamma not in g(x,y), then Lemma 2.6 to find the witness.

**Tasks**:
- [ ] Prove burgessR3 bridging lemma (in RRelation.lean):
  - Statement: `BurgessR3Maximal(A, B, C) -> untl(gamma, delta).neg in A -> delta in C -> gamma not in B`
  - Proof: Assume gamma in B. Since B satisfies burgessR3(A, B, C), by burgessRSet definition: for gamma in B and delta in C, untl(gamma, delta) in A. But untl(gamma, delta).neg in A. A is MCS, so contradiction.
  - Key difference from v16 plan: this uses burgessR3 (content-based: elements of B and C produce Until formulas in A), NOT rRelation (obligation propagation: A -> B). The old bridging lemma was wrong because rRelation does not give "gamma in B and delta in C implies untl(gamma, delta) in A".
- [ ] Prove dual: `BurgessR3Maximal(A, B, C) -> snce(gamma, delta).neg in C -> delta in A -> gamma not in B`
- [ ] Write BurgessR3Maximal variant of lemma_2_6: `BurgessR3Maximal(A, B, C) -> gamma.neg not in B -> gamma not in B -> exists D, BurgessR3Maximal(A, D, C) and gamma.neg in D`
  - Or: adapt existing lemma_2_6_full to accept BurgessR3Maximal. Maximality failure witness: since gamma not in B and B is BurgessR3Maximal, adding gamma to B breaks burgessR3. The failure witness provides the splitting construction.
- [ ] At the C4 sorry site: apply burgessR3 bridging lemma to get gamma not in g(x,y), then apply lemma_2_6 with BurgessR3Maximal to produce D containing gamma.neg. By C3: gamma.neg in f(z) for intermediate z. This is the C4 witness.
- [ ] Close C4' hard sub-case (mirror using Since)
- [ ] Remove any unnecessary G(gamma)/H(gamma) case-split code
- [ ] Run lake build and verify

**Timing**: 4 hours

**Depends on**: Phase 3 (needs populated g-values; does NOT need limit_g)

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/RRelation.lean` -- burgessR3 bridging lemma, BurgessR3Maximal lemma_2_6 variant
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean` -- C4/C4' hard sub-case proofs
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleConstruction.lean` -- update call sites if needed

**Verification**:
- burgessR3 bridging lemma proved sorry-free
- BurgessR3Maximal lemma_2_6 variant proved sorry-free
- C4 hard sub-case sorry-free (sorry at ~line 334 closed)
- C4' hard sub-case sorry-free (sorry at ~line 449 closed)
- lake build succeeds
- Sorry count reduction: -2

---

### Phase 6: Close restricted_fuc, Final Validation (2 Sorry Sites) [NOT STARTED]

**Goal**: Close the 2 restricted_fuc sorry sites using until_guard (base point) + limit_g + C3 (intermediates), and validate sorry-free dd_countermodel_chronicle.

**Tasks**:
- [ ] Close restricted_fuc Until (ChronicleToCountermodel.lean, ~line 964):
  - Given `untl(gamma,delta) in f(t)`, use `until_guard_in_mcs` from Phase 1 to get `gamma in f(t)` (base point)
  - Use C5 to get endpoint s > t with delta in f(s) and gamma in limit_g(t,s)
  - For intermediate r with t < r < s: by c3_interval_subset_point, `limit_g(t,s) subset limit_f(r)`, so gamma in f(r)
  - Transfer through Cantor isomorphism
- [ ] Close restricted_fuc Since (ChronicleToCountermodel.lean, ~line 968): mirror using since_guard + C5' + backward interval
- [ ] Remove placeholder limit_g artifacts and unused helper functions
- [ ] Clean up Adjacent-related dead comments
- [ ] Run `#print axioms dd_countermodel_chronicle` and verify only Lean axioms (propfunext, Quot.sound, Classical.choice) -- no sorryAx
- [ ] Verify zero sorry sites in Chronicle/ directory
- [ ] Full lake build verification
- [ ] Verify Soundness, FMP, ParametricTruthLemma remain sorry-free

**Timing**: 4 hours

**Depends on**: Phases 4, 5

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` -- restricted_fuc Until/Since proofs
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleConstruction.lean` -- cleanup

**Verification**:
- restricted_fuc Until sorry-free (line ~964 closed)
- restricted_fuc Since sorry-free (line ~968 closed)
- `#print axioms dd_countermodel_chronicle` shows NO sorryAx
- Zero sorry sites in Chronicle/ directory
- lake build succeeds (full clean build)
- Soundness, FMP, ParametricTruthLemma remain sorry-free
- Sorry count reduction: -2 (total -4 from active sites, -8 from dead code deletion in Phase 1.5)

## Testing & Validation

- [x] Phase 1: until_guard/since_guard axioms added; Soundness.lean sorry-free; MCS-level lemmas compile (COMPLETED)
- [ ] Phase 1.5: Cruft deleted; chronicle_fmcs/chronicle_bfmcs removed; lake build passes
- [ ] Phase 2: BurgessR3Maximal defined and proved; ChronicleInvariant c2' updated; lake build passes
- [ ] Phase 3: All elimination functions produce BurgessR3Maximal g-values; g-preservation proved; lake build passes
- [ ] Phase 4: g-immutability, limit_g, limit_c3, c3_interval_subset_point all sorry-free
- [ ] Phase 5: burgessR3 bridging lemma sorry-free; C4/C4' hard sub-case sorry-free (-2 sorry sites)
- [ ] Phase 6: restricted_fuc sorry-free (-2 sorry sites); `#print axioms dd_countermodel_chronicle` clean; zero sorry in Chronicle/
- [ ] No regression in existing sorry-free modules (Soundness, FMP, ParametricTruthLemma)
- [ ] lake build succeeds at each phase boundary

## Artifacts & Outputs

- `specs/107_.../plans/30_implementation-plan.md` (this file)
- Modified: `Theories/Bimodal/ProofSystem/Axioms.lean` (until_guard, since_guard) -- Phase 1 DONE
- Modified: `Theories/Bimodal/Metalogic/Soundness.lean` (soundness cases) -- Phase 1 DONE
- Modified: `Chronicle/ChronicleTypes.lean` (delete g_ordered/h_ordered/claim_2_11, update c2' to BurgessR3Maximal)
- Modified: `Chronicle/RRelation.lean` (BurgessR3Maximal definition, existence, bridging lemma, lemma_2_6 variant)
- Modified: `Chronicle/CounterexampleElimination.lean` (EliminationResult, g-population, C4 hard case via burgessR3)
- Modified: `Chronicle/ChronicleConstruction.lean` (g-immutability, limit_g, limit_c3, singleton_chronicle g, call sites, cleanup)
- Modified: `Chronicle/ChronicleToCountermodel.lean` (restricted_fuc closure, dead code deletion)
- Modified: `Chronicle/PointInsertion.lean` (stale comment removal, lemma_2_6 BurgessR3Maximal variant)

## Rollback/Contingency

- **Git safety**: The irr_until branch preserves the current state. All changes can be reverted to HEAD.
- **Phase 1.5 contingency (cruft purge)**: If deleting chronicle_fmcs/chronicle_bfmcs breaks something unexpected, check for hidden references via grep before proceeding.
- **Phase 2 contingency (BurgessR3Maximal existence)**: If the Zorn's lemma argument is too complex in Lean, use an explicit Lindenbaum-style extension: enumerate all formulas, try adding each, keep if burgessR3 preserved. This avoids the chain argument.
- **Phase 2 contingency (c2' replacement)**: If too many files break when replacing R3Maximal with BurgessR3Maximal in c2', add BurgessR3Maximal as an ADDITIONAL field (c2'_burgess) alongside the existing c2', prove the implication, and migrate incrementally.
- **Phase 3 contingency (g-population)**: If extending EliminationResult proves too disruptive, carry g-values in a separate side-channel structure parallel to the Chronicle.
- **Phase 5 contingency (bridging lemma)**: The burgessR3 bridging lemma should be straightforward from the definition of burgessRSet. If the Lean formalization has unexpected complications (e.g., guard/event argument swap), write the wrapper accounting for notation.
- **Phase 5 contingency (lemma_2_6_full)**: If adapting lemma_2_6_full to BurgessR3Maximal requires substantial rewriting, implement the splitting construction from scratch: use maximality failure witness to extract the contradiction, then build D via deductiveClosure.
- **Phase 6 contingency (restricted_fuc)**: If C5 does not thread the guard witness through to the limit, strengthen C5 EliminationResult to include gamma in limit_g(t,s) explicitly.
- **Budget overrun**: Phases 4+5 and Phase 6 are somewhat independent. Phase 5 (C4 hard case) can be shipped without Phase 6 (restricted_fuc), and vice versa.
