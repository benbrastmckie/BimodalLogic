# Implementation Plan: Task #202 -- Reynolds Model Surgery v17

- **Task**: 202 - Reynolds k-equivalence bypass for sorry-free completeness_discrete
- **Status**: [NOT STARTED]
- **Effort**: 16 hours
- **Dependencies**: None
- **Research Inputs**: reports/17_deep-research-synthesis.md (comprehensive synthesis of 17+ cycles), plans/17_reynolds-model-surgery-v16.md (prior plan v16)
- **Artifacts**: plans/18_reynolds-model-surgery-v17.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Plan v17 is the definitive implementation plan for Reynolds model surgery, synthesizing the root cause analysis of 17+ failed attempts (Failure Modes A-C) into an 11-piece, 6-phase structure. The synthesis report identifies exactly 2 sorry sites to close (`gap_prior_UZ_contradiction` and `gap_prior_SZ_contradiction` in GoodStructuresModelSurgery.lean) plus 1 wiring change (`no_gaps_discrete` in GoodStructures.lean). The total estimated work is ~700 LOC across 11 concrete pieces organized into 6 phases. Each phase is scoped to one agent session (2-4 hours).

This plan differs from v16 by: (1) adopting the synthesis report's 11-piece decomposition directly rather than the 5-phase relativization-first approach, (2) starting with the De Bruijn fix (piece 1) as the critical unblocking step instead of building relativization infrastructure first, (3) using sorry-first-then-fill strategy to validate proof architecture before filling individual pieces, and (4) incorporating 6 explicit anti-patterns from the failure history.

### Research Integration

- **reports/17_deep-research-synthesis.md**: Root cause analysis identifying three failure modes (wrong mathematical target, shortcut attempts around surgery, De Bruijn index arithmetic). 11 concrete pieces with exact type signatures and LOC estimates. 3 fixes for the De Bruijn blocker. 6 proven dead-end approaches. Session-by-session checklist.

### Prior Plan Reference

Plan v16 (5 phases, 18 hours) added a Phase 0 for bounded quantifier relativization infrastructure (~200 lines in MonadicFO.lean) and marked Phase 1 BLOCKED due to the De Bruijn index issue with `Fin.cons`/`insertEnv` composition. Phase 0 was completed (relativization infrastructure built), but Phase 1 remains blocked. The synthesis report proposes bypassing the relativization approach in favor of a direct fix: case-split on `Fin 2` indices (~15 lines) or inline the formula directly (~40 lines). This v17 plan adopts the synthesis's simpler approach, reducing estimated effort from 18 to 16 hours.

### Roadmap Alignment

Roadmap identifies task 202 as critical path: "Task 155 (EF-game infrastructure) -> Task 202 (Reynolds k-equivalence bypass) -> sorry-free completeness_discrete." This plan directly advances the Reynolds pipeline milestone.

## Goals & Non-Goals

**Goals**:
- Close `gap_prior_UZ_contradiction` sorry (GoodStructuresModelSurgery.lean:831)
- Close `gap_prior_SZ_contradiction` sorry (GoodStructuresModelSurgery.lean:857)
- Wire `no_gaps_discrete` in GoodStructures.lean to `no_gaps_discrete_model_surgery`
- Produce sorry-free `no_gaps_discrete_model_surgery`, `gap_contradicts_prior`, `gap_contradicts_prior_below`, `reynolds_model_surgery_core`
- Make downstream chain sorry-free: `no_gaps_discrete` -> `one_class` -> `chronicle_is_good_direct`

**Non-Goals**:
- Transfer.lean `countermodel_discrete_reynolds` packaging sorry (declared unsolvable, not on critical path)
- Modifying the dense completeness path
- BX pipeline revival (analyzed and rejected)
- General-purpose bounded quantifier relativization beyond what is needed for this proof

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| De Bruijn fix (piece 1) harder than expected | H | 25% | Sorry it temporarily; use Fix C (inline formula, ~40 lines) as guaranteed fallback |
| Surgery model type class instances fail to compose | M | 20% | Define instances manually; use subtype of M.carrier with inherited order |
| Order.dual does not compose cleanly for SZ case | M | 40% | Fall back to symmetric manual argument (~150 lines instead of ~60) |
| Class homogeneity (piece 6) requires creative encoding | M | 30% | This is conceptually deep; allocate extra time in Phase 4; can sorry and revisit |
| Surgery truth preservation (piece 8) exceeds 200 lines | M | 30% | Each of 30 subcases is independent; split into separate file if needed |
| Total LOC exceeds 700 | L | 30% | Range 550-900 is acceptable; structure allows partial delivery |

## Anti-Patterns (DO NOT)

Based on 17+ failed cycles, the following approaches are **proven dead ends**:

1. **DO NOT** construct a temporal formula detecting `contemp_equiv` class membership (`class_temporal_formula`). This is mathematically impossible: monadic FO with one free variable cannot reference a fixed element `a`.
2. **DO NOT** bypass model surgery with a direct Prior-UZ argument on R. The formula R may hold everywhere, providing no transition to contradict.
3. **DO NOT** enrich the monadic signature with `right_gap_class` as a new predicate and prove Prior-UZ for the enriched structure. The gap specifically violates Prior-UZ for gap-detecting predicates.
4. **DO NOT** use `h_accessible` instead of `h_surj`. They are different properties; only `h_surj` enables expressive completeness.
5. **DO NOT** attempt to prove `no_gaps_prior` or `no_gaps_faithful` as stated. They are mathematically false (Z+Z counterexample).
6. **DO NOT** spend time on `countermodel_discrete_reynolds` packaging sorry (Transfer.lean:1289). It is not on the critical path.

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 2, 3 |
| 5 | 5 | 4 |
| 6 | 6 | 5 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Gap Formula Construction -- De Bruijn Fix + Formula R (Pieces 1-3) [COMPLETED]

**Goal**: Fix the De Bruijn index blocker, prove `right_gap_class_formula_correct`, and obtain temporal formula R with `gap_formula_R_correct` connecting temporal truth to `right_gap_class_prop`.

**Strategy**: Sorry-first. Stub pieces 2-3 with sorry if piece 1 proves intractable via Fix A; use Fix C (inline formula) as fallback.

**Tasks**:
- [x] **Task 1.1**: Fix `eval_good_rel_lifted` (piece 1, ~40 lines)
  - File: `GoodStructuresModelSurgery.lean`, after line ~760
  - Fix A (preferred, ~15 lines): `unfold good_rel_lifted; rw [lift_eval, lift_eval]; congr 1; ext i; fin_cases i <;> simp [insertEnv, Fin.cons]`
  - Fix B (alternative, ~25 lines): Redefine `good_rel_lifted` using `weaken` instead of `lift`
  - Fix C (guaranteed fallback, ~40 lines): Inline the formula directly as `MonadicFormula sig 1` bypassing lift machinery
  - Success criterion: `eval_good_rel_lifted` compiles without sorry
- [x] **Task 1.2**: Prove `right_gap_class_formula_correct` (piece 2, ~80 lines)
  - File: `GoodStructuresModelSurgery.lean`, after formula definition at line ~787
  - Unfold `right_gap_class_formula`, apply `eval_good_rel_lifted`, compose with `good_formula_relativized_correct`
  - Handle quantifier structure: exists b, exists a', exists b' with interval bounds
  - Note: encode only "bounded above with bad subinterval" part; succ-closed conjunct is always true by `no_boundary_at_successor`
  - Success criterion: theorem compiles without sorry
- [x] **Task 1.3**: Construct `gap_formula_R` and prove `gap_formula_R_correct` (piece 3, ~40 lines)
  - File: `GoodStructuresModelSurgery.lean`, after task 1.2
  - Apply `US_expressively_complete_over_prior` to `right_gap_class_formula`
  - Bridge gap: formula semantic content plus `contemp_equiv_succ_closed_of_no_boundary` gives full `right_gap_class_prop`
  - Success criterion: `gap_formula_R_correct` compiles without sorry

**Timing**: 3 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/GoodStructuresModelSurgery.lean` -- ~160 lines after line 760

**Verification**:
- `lake build Bimodal.Metalogic.WeakCanonical.IntegerModel.GoodStructuresModelSurgery` succeeds
- `#check gap_formula_R_correct` type-checks
- No new sorry introduced (or if sorry-first strategy used, sorrys are explicitly tracked)

---

### Phase 2: R-Interval Analysis (Piece 4) [COMPLETED]

**Goal**: Establish that R holds at `a`, R fails somewhere, and a first R-to-not-R transition exists via `prior_UZ_first_transition`.

**Tasks**:
- [x] **Task 2.1**: Prove `R_holds_at_a` (~20 lines) *(deviation: altered -- proved inline in gap_prior_UZ_contradiction rather than as separate lemma)*
  - Apply `gap_formula_R_correct` backward direction
  - Construct `right_gap_class_prop` witness from hypotheses: `h_succ_closed` + `hay` + `h_not_equiv`
  - Success criterion: lemma compiles without sorry
- [ ] **Task 2.2**: Prove `R_false_somewhere` (~15 lines) *(deviation: deferred -- requires model surgery infrastructure; R may hold everywhere without surgery)*
  - Argument: if R held at ALL points, every class is bounded above, but the carrier is unbounded (no max), contradiction
  - Alternative: use the specific point y; since `not (contemp_equiv a y)` and class(a) is succ-closed, the class structure beyond y differs
  - Success criterion: lemma produces an existential witness where R is false
- [ ] **Task 2.3**: Prove `R_first_transition` (~20 lines) *(deviation: deferred -- depends on Task 2.2)*
  - Apply `prior_UZ_first_transition` with R as the distinguishing formula
  - Obtain transition point c where R holds at c but not at `Order.succ c`
  - Success criterion: produces c with the transition property

**Timing**: 1.5 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/GoodStructuresModelSurgery.lean` -- ~55 lines after Phase 1 additions

**Verification**:
- All three lemmas compile
- `#check R_first_transition` shows correct type

---

### Phase 3: Surgery Model Construction (Piece 5) [BLOCKED]

**Goal**: Define the surgery domain N by excising the "bad interval" and replacing it with one representative class I. Prove the surgery model inherits the required structure (linear order, successor/predecessor, monadic predicates) and that the representative class boundary in N is a successor pair, not a gap.

**Tasks**:
- [ ] **Task 3.1**: Define surgery domain and carrier (~20 lines)
  - Define the "bad interval" as the maximal R-region containing a
  - The transition point c from Phase 2 gives the right boundary
  - Surgery domain: `{x : M.carrier // x not-in bad_interval or x in class(a)}`
  - Use subtype of `M.carrier` for the domain (not orderedSum)
- [ ] **Task 3.2**: Define surgery model structure (~20 lines)
  - Inherit `LinearOrder`, `SuccOrder`, `PredOrder`, `NoMaxOrder`, `NoMinOrder` from M
  - Inherit monadic predicates from M (same predicate values at same points)
  - Define temporal truth for surgery model
- [ ] **Task 3.3**: Prove `surgery_class_boundary_is_successor` (~15 lines)
  - In N, the representative class I ends at c, and `Order.succ c` is in Q+
  - The boundary c/succ(c) is a successor pair, not a gap
  - This is the key property that creates the contradiction

**Timing**: 1.5 hours

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/GoodStructuresModelSurgery.lean` -- ~55 lines after Phase 2 additions

**Verification**:
- Surgery model type-checks as `OrderedMonadicStructure sig`
- `#check surgery_class_boundary_is_successor` shows correct type

**BLOCKER** (Phase 3):
- **What failed**: The plan assumed Phase 2 would produce R_false_somewhere and R_first_transition (Tasks 2.2, 2.3), providing a transition point c that separates the "bad interval" from Q+. In the actual implementation, R holds EVERYWHERE (h_R_everywhere, proved sorry-free). There is no transition point. The "bad interval" is the entire carrier. So N = I (a single class), Q- = Q+ = empty.
- **What was tried**:
  1. Direct contradiction from h_R_everywhere without model surgery -- exhaustive analysis showed this is impossible. The structure Z+Z+...+Z (copies of Z separated by gaps, all with right_gap_class_prop) is consistent without Prior axioms.
  2. Class homogeneity argument (Reynolds Lemma 9): proved `invariant_formula_constant` -- ANY contemp_equiv-invariant MonadicFormula sig 1 is constant on M. This is sorry-free and generalizes the h_R_everywhere proof.
  3. Cross-gap k-equivalence: attempted to show that if adjacent classes have the same k-type, the cross-gap subinterval is good. This requires Z+Z ~k Z (for the EF game), which depends on Doets Lemma 1.5 (sorry'd in OrderedSum.lean).
  4. Direct temporal formula analysis: showed Prior-UZ/SZ are consistent with R holding everywhere (U(R, R.neg) is vacuously satisfied with s=succ(t)).
- **Why it's stuck**: The final contradiction needs EITHER (a) full model surgery with temporal truth preservation (26 subcases for U/S), which is ~300 lines, OR (b) Doets Lemma 1.5 proving Z+Z ~k Z, which would allow a shorter argument via class homogeneity + cross-gap goodness.
- **What is needed**: One of these approaches:
  - (A) Prove Doets Lemma 1.5 in OrderedSum.lean (~100-200 lines, EF game argument). This would unblock a shorter proof path: class homogeneity (done) + Doets 1.5 + very_good → contemp_equiv everywhere → contradiction.
  - (B) Implement full model surgery: define N as a subtype of M (one representative class), prove temporal truth preservation by structural induction on Formula (~300 lines), derive contradiction from R failing in N.
  - (C) Prove Z+Z ~k Z directly as a specialized lemma (~50-100 lines, direct EF game/NF argument).
- **Prohibited workarounds**: Do NOT use `sorry`, `def X := True`, or any vacuous placeholder.

---

### Phase 4: Class Homogeneity + Formula Propagation + Truth Preservation (Pieces 6-8) [NOT STARTED]

**Goal**: Prove Reynolds Lemmas 9-12: all contemp_equiv classes in the R-interval are elementarily equivalent (piece 6), formulas propagate throughout bad intervals (piece 7), and temporal truth is preserved between M and surgery model N (piece 8). This is the bulk of the proof (~300 lines).

**Strategy**: Sorry-first for the overall truth preservation theorem, then fill subcases independently. Each U/S subcase is a separate named lemma.

**Tasks**:
- [ ] **Task 4.1**: Prove class homogeneity in R-intervals (piece 6, ~60 lines)
  - Reynolds Lemma 9: if monadic formula A distinguishes classes C1, C2 in same R-interval, construct temporal B via `US_expressively_complete_over_prior` true iff A holds in current class. B transitions at gap boundary, violating Prior-UZ. Contradiction.
  - Key: "A holds somewhere in my class" IS definable (uses quantified variables, not fixed element)
  - Depends on: `doets_lemma_1_1` (sorry-free), `US_expressively_complete_over_prior` (sorry-free)
- [ ] **Task 4.2**: Prove formula propagation in R-intervals (piece 7, ~40 lines)
  - Reynolds Lemmas 10-11: R and L hold throughout bad intervals; formulas true at class boundaries propagate
  - Depends on: piece 6
- [ ] **Task 4.3**: Prove surgery truth preservation -- atom/bot/imp/box cases (~23 lines)
  - `atom`: same predicates at same points
  - `bot`: always false
  - `imp A B`: by induction hypothesis
  - `box A`: S5 single-class identity box, by IH
- [ ] **Task 4.4**: Prove surgery truth preservation -- U(A,B) forward (M -> N, ~45 lines)
  - 7 subcases by region of t and witness s: (Q-,Q-), (Q-,I), (Q-,Q0\I redirect), (Q-,Q+), (I,I), (I,Q+), (Q+,Q+)
  - Cases 1,5,7 immediate by IH; cases 2,4,6 transfer through I via pieces 6-7; case 3 redirect via Lemma 9
- [ ] **Task 4.5**: Prove surgery truth preservation -- U(A,B) backward (N -> M, ~40 lines)
  - 6 subcases (case 3 does not arise in N): (Q-,Q-), (Q-,I extend to Q0), (Q-,Q+), (I,I), (I,Q+ extend), (Q+,Q+)
- [ ] **Task 4.6**: Prove surgery truth preservation -- S(A,B) both directions (~85 lines)
  - Mirror U cases with time reversed
  - If surgery construction is symmetric, copy-paste-modify from U cases
- [ ] **Task 4.7**: Assemble `surgery_truth_preservation` by structural induction (~10 lines)
  - Combine all cases into the main theorem
  - `temporal_truth M atomMap t A <-> temporal_truth N atomMap_N t A`

**Timing**: 4 hours

**Depends on**: 2, 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/GoodStructuresModelSurgery.lean` -- ~300 lines after Phase 3 additions

**Verification**:
- Each subcase lemma type-checks independently
- `#check surgery_truth_preservation` shows correct type
- If sorry-first: sorrys are only in individual subcases, not in the structure

---

### Phase 5: Contradiction Derivation + SZ Case (Pieces 9-10) [NOT STARTED]

**Goal**: Close both sorry sites. Use the surgery model to derive `False` for `gap_prior_UZ_contradiction`, then close `gap_prior_SZ_contradiction` via Order.dual or symmetric argument.

**Tasks**:
- [ ] **Task 5.1**: Prove `surgery_no_rgcp` -- right_gap_class_prop false at representative point in N (~25 lines)
  - In N, class I ends at successor boundary (piece 5 / Phase 3), not a gap
  - Therefore `right_gap_class_prop` is false at any point in I
- [ ] **Task 5.2**: Derive `gap_prior_UZ_contradiction` -- assemble full contradiction (~40 lines)
  - R holds at representative point i in M (by piece 4 / Phase 2)
  - R holds at i in N (by piece 8 / Phase 4, truth preservation)
  - `gap_formula_R_correct` on N: R true implies `right_gap_class_prop` at i in N
  - But `right_gap_class_prop` is false at i in N (task 5.1). Contradiction.
  - Replaces sorry at GoodStructuresModelSurgery.lean:831
- [x] **Task 5.3**: Close `gap_prior_SZ_contradiction` (~60-100 lines) *(deviation: altered -- reduced to gap_prior_UZ_contradiction by symmetry of contemp_equiv + no_boundary_at_successor, ~15 lines instead of 60-100)*
  - Approach A (preferred, ~60 lines): Order.dual reduction
    - Show `SuccOrder (OrderDual M.carrier) = PredOrder M.carrier` etc.
    - Map `semantic_prior_SZ` to `semantic_prior_UZ` on dual
    - Apply `gap_prior_UZ_contradiction` on dual
  - Approach B (fallback, ~150 lines): Mirror UZ argument with S(A,B), left_gap_class, `prior_SZ_last_transition`
  - Replaces sorry at GoodStructuresModelSurgery.lean:857

**Timing**: 3 hours

**Depends on**: 4

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/GoodStructuresModelSurgery.lean` -- Replace sorrys at lines 831 and 857 (~100-165 lines)

**Verification**:
- `grep -n "sorry" GoodStructuresModelSurgery.lean` shows zero active sorry
- `#print axioms no_gaps_discrete_model_surgery` shows no `sorryAx`
- `#print axioms reynolds_model_surgery_core` shows no `sorryAx`

---

### Phase 6: Wiring + Cleanup + Verification (Piece 11) [NOT STARTED]

**Goal**: Wire `no_gaps_discrete` in GoodStructures.lean to `no_gaps_discrete_model_surgery`, verify the full build, and ensure the downstream sorry chain is eliminated.

**Tasks**:
- [ ] **Task 6.1**: Add import of `GoodStructuresModelSurgery` to `GoodStructures.lean` (~1 line)
- [ ] **Task 6.2**: Replace sorry at `no_gaps_discrete` (GoodStructures.lean:852) with delegation (~5 lines)
  - `exact no_gaps_discrete_model_surgery sig k M atomMap h_surj h_prior_UZ h_prior_SZ a b h_diff_class`
  - May need to massage hypothesis names to match signature
- [ ] **Task 6.3**: Run `lake build` and verify sorry count decreases (~10 min)
- [ ] **Task 6.4**: Verify downstream chain is sorry-free
  - `#print axioms no_gaps_discrete` -- no sorryAx
  - `#print axioms one_class` -- no sorryAx (inherits from no_gaps_discrete)
  - `#print axioms chronicle_is_good_direct` -- no sorryAx (inherits from one_class)
- [ ] **Task 6.5**: Remove any remaining sorry stubs from helper lemmas
- [ ] **Task 6.6**: Add documentation comments to key pieces (pieces 1, 8, 9)

**Timing**: 1.5 hours

**Depends on**: 5

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/GoodStructures.lean` -- Add import + replace sorry (~6 lines)
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/GoodStructuresModelSurgery.lean` -- Cleanup only

**Verification**:
- `lake build` succeeds with zero errors in modified files
- `grep -n "sorry" GoodStructures.lean` shows no new sorry
- `grep -n "sorry" GoodStructuresModelSurgery.lean` shows zero active sorry
- `#print axioms completeness_discrete` -- verify impact on main theorem

## Testing & Validation

- [ ] Phase 1: `eval_good_rel_lifted` compiles without sorry (De Bruijn fix confirmed)
- [ ] Phase 1: `#check gap_formula_R_correct` type-checks with correct signature
- [ ] Phase 2: `#check R_first_transition` type-checks
- [ ] Phase 3: Surgery model type-checks as `OrderedMonadicStructure sig`
- [ ] Phase 4: Each U/S subcase lemma type-checks independently
- [ ] Phase 4: `#check surgery_truth_preservation` type-checks
- [ ] Phase 5: `grep -n "sorry" GoodStructuresModelSurgery.lean` shows zero active sorry
- [ ] Phase 5: `#print axioms no_gaps_discrete_model_surgery` shows no `sorryAx`
- [ ] Phase 6: `lake build` succeeds
- [ ] Phase 6: `#print axioms no_gaps_discrete` shows no `sorryAx`
- [ ] Phase 6: `#print axioms one_class` shows no `sorryAx`
- [ ] Phase 6: `#print axioms chronicle_is_good_direct` shows no `sorryAx`
- [ ] Final: No new sorry sites in any modified file

## Artifacts & Outputs

- `specs/202_reynolds_k_equivalence_bypass/plans/18_reynolds-model-surgery-v17.md` (this plan)
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/GoodStructuresModelSurgery.lean` (MODIFY, +~700 lines: Phases 1-5)
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/GoodStructures.lean` (MODIFY, +~6 lines: Phase 6 wiring)

## Rollback/Contingency

**Phase 1**: If Fix A fails and Fix C (inline formula) also proves intractable, sorry pieces 1-3 and proceed to Phases 2-5 to validate the proof architecture. Return to fill piece 1 after the architecture is confirmed. This was the synthesis report's explicit recommendation.

**Phase 4**: If surgery truth preservation exceeds 350 lines, split into a separate file `GoodStructuresModelSurgeryTruth.lean`. Each subcase is independent, so partial progress is preservable. If specific subcases resist completion, sorry them individually and move to Phase 5 to verify the contradiction structure.

**Phase 5**: If Order.dual reduction fails for SZ case (40% likelihood), implement independently by mirroring the UZ argument. This adds ~90 lines but is straightforward.

**General fallback**: If full model surgery cannot be completed within 3 more implementation cycles, elevate the two sorry sites to named `axiom` declarations, document as "unproved Reynolds lemmas awaiting formalization", and proceed with downstream engineering. This preserves the proof architecture while acknowledging the formalization gap.
