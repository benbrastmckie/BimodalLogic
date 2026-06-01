# Implementation Plan: Task #202 -- Reynolds Model Surgery v18

- **Task**: 202 - Reynolds k-equivalence bypass for sorry-free completeness_discrete
- **Status**: [IN PROGRESS]
- **Effort**: 10 hours
- **Dependencies**: None
- **Research Inputs**: reports/17_deep-research-synthesis.md (comprehensive synthesis of 17+ cycles), .blocker-research-findings.md (Phase 3 blocker resolution via Reynolds Lemmas 10-13)
- **Artifacts**: plans/19_reynolds-model-surgery-v18.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Plan v18 revises the blocked v17 plan to incorporate the correct Reynolds model surgery approach following the Phase 3 blocker analysis. The key insight: since `h_R_everywhere` proves R holds at every point, the entire carrier M is a "bad interval" (Reynolds' terminology). This eliminates Q- and Q+ entirely, simplifying Reynolds' Lemma 12 from 7 cases to 2. The revised approach constructs N = I (a single equivalence class) as the surgery model, proves temporal truth preservation via structural induction, and derives the final contradiction.

Phases 1-2 are complete. The remaining work (Phases 3-6) replaces the blocked v17 Phases 3-6 with the 4 missing pieces from Reynolds 1994: temporal class spread (Lemma 9 first part), bad interval density (Lemma 11), truth preservation for N = I (Lemma 12 simplified), and final contradiction (Lemma 13). Total remaining estimate: ~200-300 lines, ~7 hours.

### Research Integration

- **reports/17_deep-research-synthesis.md**: Root cause analysis of 17+ failed cycles, 11-piece decomposition, anti-patterns. Integrated in v17.
- **.blocker-research-findings.md**: Phase 3 blocker resolution. Identifies Reynolds Lemmas 10-13 as the correct path (not Doets 1.5 or Z+Z ~k Z). h_R_everywhere eliminates Q-/Q+, reducing Lemma 12 from 7 to 2 cases. Estimated 200-300 lines total.

### Prior Plan Reference

Plan v17 (6 phases, 16 hours) completed Phases 1-2 (gap formula construction, R-interval analysis). Phase 3 was blocked because R holds everywhere (h_R_everywhere), eliminating the assumed transition point. The v17 Phase 3-6 structure assumed a non-trivial surgery domain with Q-/I/Q+ regions. This v18 plan replaces Phases 3-6 with a streamlined approach where the surgery model N is simply one equivalence class I.

### Roadmap Alignment

Roadmap identifies task 202 as critical path: "Task 155 (EF-game infrastructure) -> Task 202 (Reynolds k-equivalence bypass) -> sorry-free completeness_discrete." This plan directly advances the Reynolds pipeline milestone.

## Goals & Non-Goals

**Goals**:
- Close `gap_prior_UZ_contradiction` sorry (GoodStructuresModelSurgery.lean:1181)
- Close `gap_prior_SZ_contradiction` sorry (already done in v17 -- reduces to UZ case)
- Wire `no_gaps_discrete` in GoodStructures.lean to `no_gaps_discrete_model_surgery`
- Produce sorry-free `no_gaps_discrete_model_surgery`, `gap_contradicts_prior`, `gap_contradicts_prior_below`, `reynolds_model_surgery_core`
- Make downstream chain sorry-free: `no_gaps_discrete` -> `one_class` -> `chronicle_is_good_direct`

**Non-Goals**:
- Transfer.lean `countermodel_discrete_reynolds` packaging sorry (not on critical path)
- Modifying the dense completeness path
- Doets Lemma 1.5 or Z+Z ~k Z (Reynolds approach does not need these)
- General-purpose bounded quantifier relativization

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Truth preservation U(A,B) forward case harder than estimated | M | 30% | Only 2 cases (not 7), each conceptually clear. Sorry individual subcases and fill independently. |
| Constructing N as OrderedMonadicStructure is type-class heavy | M | 25% | Use subtype of M.carrier with inherited instances. Lean 4 instance synthesis handles most cases. |
| Lemma 9 first part (class spread) needs careful MonadicFormula encoding | M | 20% | Infrastructure exists: `US_expressively_complete_over_prior`, `invariant_formula_constant`. The encoding of "A holds somewhere in class(x)" as a MonadicFormula is the key step. |
| Total LOC exceeds 300 | L | 30% | Range 200-400 is acceptable; structure allows partial delivery. |

## Anti-Patterns (DO NOT)

Based on 17+ failed cycles plus Phase 3 blocker analysis:

1. **DO NOT** attempt to derive False from h_R_everywhere without model surgery. Extensively analyzed; no shortcut exists. The structure Z+Z+...+Z with identical copies and gaps is consistent without Prior axioms.
2. **DO NOT** use Doets Lemma 1.5 or Z+Z ~k Z. Reynolds' proof does not need these. They are on a different proof path.
3. **DO NOT** construct a temporal formula detecting `contemp_equiv` class membership. Mathematically impossible: monadic FO with one free variable cannot reference a fixed element.
4. **DO NOT** bypass model surgery with a direct Prior-UZ argument on R. U(R, R.neg) is vacuously satisfied when R holds everywhere.
5. **DO NOT** expect class homogeneity alone to give contemp_equiv everywhere. It gives same class theory but not same 1-variable type in full M.
6. **DO NOT** reason about Q-/Q+ regions. Since h_R_everywhere, the entire carrier is "bad" -- Q- = Q+ = empty.

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5 | 4 |
| 6 | 6 | 5 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Gap Formula Construction -- De Bruijn Fix + Formula R (Pieces 1-3) [COMPLETED]

**Goal**: Fix the De Bruijn index blocker, prove `right_gap_class_formula_correct`, and obtain temporal formula R with `gap_formula_R_correct` connecting temporal truth to `right_gap_class_prop`.

**Tasks**:
- [x] **Task 1.1**: Fix `eval_good_rel_lifted` (piece 1, ~40 lines)
- [x] **Task 1.2**: Prove `right_gap_class_formula_correct` (piece 2, ~80 lines)
- [x] **Task 1.3**: Construct `gap_formula_R` and prove `gap_formula_R_correct` (piece 3, ~40 lines)

**Timing**: 3 hours
**Depends on**: none
**Completed**: 2026-05-31

---

### Phase 2: R-Interval Analysis + h_R_everywhere (Piece 4, partial) [COMPLETED]

**Goal**: Prove R holds at a, then prove R holds everywhere via Prior-UZ/SZ transition argument. Establish `invariant_formula_constant` (Reynolds Lemma 9 generalization).

**Tasks**:
- [x] **Task 2.1**: Prove `R_holds_at_a` (inline in gap_prior_UZ_contradiction)
- [x] **Task 2.2**: Prove `h_R_everywhere` -- R holds at every point of M (Prior transition + no_boundary_at_successor)
- [x] **Task 2.3**: Prove `invariant_formula_constant` -- any contemp_equiv-invariant MonadicFormula sig 1 is constant on M
- [x] **Task 2.4**: Reduce `gap_prior_SZ_contradiction` to `gap_prior_UZ_contradiction` via symmetry of contemp_equiv + no_boundary_at_successor (~15 lines)

**Timing**: 1.5 hours
**Depends on**: 1
**Completed**: 2026-06-01

**Deviation from v17**: Tasks 2.2 (R_false_somewhere) and 2.3 (R_first_transition) from v17 were deferred/abandoned because R actually holds everywhere. Instead, h_R_everywhere and invariant_formula_constant were proved, which are the correct infrastructure for the model surgery approach.

---

### Phase 3: Temporal Class Spread + Bad Interval Density (Lemmas 9.1, 11) [PARTIAL]

**Goal**: Prove Reynolds Lemma 9 first part (if temporal A holds somewhere in one class, it holds somewhere in every class) and Lemma 11 (formulas true in M are true arbitrarily close to class boundaries). These are prerequisites for truth preservation.

**Tasks**:
- [ ] **Task 3.1**: Prove temporal class spread (~50-80 lines)
  - **Statement**: If temporal formula A holds at some point in class C1, then A holds at some point in every contemp_equiv class.
  - **Proof sketch**: Given A holds in C1 but nowhere in C2. Using `US_expressively_complete_over_prior`, construct MonadicFormula phi_A(x) = "A holds somewhere in class(x)". phi_A is contemp_equiv-invariant by construction. By `invariant_formula_constant`, phi_A is constant on M. But phi_A is true in C1 and false in C2, contradiction.
  - **Key challenge**: Encoding "A holds somewhere in class(x)" as a MonadicFormula sig 1. This requires existential quantification over elements in the same class, using the monadic formula infrastructure for contemp_equiv membership.
  - **Infrastructure available**: `US_expressively_complete_over_prior` (sorry-free), `invariant_formula_constant` (sorry-free), `contemp_equiv_is_equiv` (sorry-free)
  - File: `GoodStructuresModelSurgery.lean`, inside `gap_prior_UZ_contradiction` after `invariant_formula_constant`
  - Success criterion: lemma compiles without sorry

- [ ] **Task 3.2**: Prove bad interval density (~30-50 lines)
  - **Statement**: If temporal formula A holds anywhere in M, then A holds at points arbitrarily close to each end of each class.
  - **Proof sketch**: By class spread (Task 3.1), A holds in every class. Since each class is infinite (succ-closed by `no_boundary_at_successor`) and successor-closed, A occurs arbitrarily far into each class from either end.
  - **Note**: Since h_R_everywhere means the entire M is the "bad interval," this applies to all of M.
  - File: `GoodStructuresModelSurgery.lean`, after Task 3.1
  - Success criterion: lemma compiles without sorry

**Timing**: 2 hours

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/GoodStructuresModelSurgery.lean` -- ~80-130 lines inside or after `gap_prior_UZ_contradiction`

**Verification**:
- Both lemmas compile without sorry
- `lake build Bimodal.Metalogic.WeakCanonical.IntegerModel.GoodStructuresModelSurgery` succeeds

---

### Phase 4: Truth Preservation for N = I (Lemma 12 simplified) [NOT STARTED]

**Goal**: Define surgery model N = M restricted to a single equivalence class I. Prove that temporal truth is preserved between M and N for all temporal formulas, for all points in I. This is the bulk of the proof.

**Strategy**: Define N as a subtype/substructure of M on a single class I. Prove truth preservation by structural induction on Formula. The h_R_everywhere simplification means Q- = Q+ = empty, reducing the U(A,B) case from 7 subcases (Reynolds) to 2.

**Tasks**:
- [ ] **Task 4.1**: Define surgery model N (~30 lines)
  - Let I be a single contemp_equiv class (e.g., class of point a)
  - Define N = M|I as an OrderedMonadicStructure with carrier = {x : M.carrier // contemp_equiv sig k M a x}
  - Inherit LinearOrder from M (subtype of linearly ordered set)
  - Inherit SuccOrder, PredOrder (class is succ-closed and pred-closed)
  - Inherit NoMaxOrder, NoMinOrder (class is unbounded on both sides -- follows from succ-closed + NoMax/NoMin on M)
  - Inherit monadic predicates from M (same predicate values at same points)
  - File: `GoodStructuresModelSurgery.lean`, inside or after `gap_prior_UZ_contradiction`
  - Success criterion: N type-checks as OrderedMonadicStructure sig with required instances

- [ ] **Task 4.2**: Prove truth preservation -- atom/bot/imp/box cases (~20 lines)
  - `atom`: same predicates at same points -- immediate
  - `bot`: always false -- immediate
  - `imp A B`: by induction hypothesis -- immediate
  - `box A`: S5 single-class identity, by IH (in N, the entire carrier is one class, so box reduces to universal quantification over I, same in M for the class)
  - File: same as Task 4.1
  - Success criterion: each case compiles without sorry

- [ ] **Task 4.3**: Prove truth preservation -- U(A,B) case (~60-80 lines)
  - **Forward (M -> N)**: M satisfies U(A,B)(t) with witness s > t
    - *Case 1*: s is in I. Since I is convex in M, all points between t and s are in I. By IH directly.
    - *Case 2*: s is NOT in I (in another class beyond a gap). By Lemma 11 (bad interval density), A holds arbitrarily close to end of I. So there exists s' in I with s' > t and M satisfies A(s'). B holds from t to s in M, so B holds for all u in I with t < u. By IH, N satisfies B(u) and N satisfies A(s'). Hence N satisfies U(A,B)(t).
  - **Backward (N -> M)**: N satisfies U(A,B)(t) with witness s in I. Since I is convex in M, all witnesses between t and s in N are exactly those in M between t and s that are in I. By IH, M satisfies A(s) and M satisfies B(u). Hence M satisfies U(A,B)(t).
  - File: same as Task 4.1
  - Success criterion: both directions compile without sorry

- [ ] **Task 4.4**: Prove truth preservation -- S(A,B) case (~50-70 lines)
  - Mirror of U(A,B) with time reversed (using Order.pred instead of Order.succ, s < t instead of s > t)
  - Same 2-case structure as Task 4.3
  - File: same as Task 4.1
  - Success criterion: both directions compile without sorry

- [ ] **Task 4.5**: Assemble `surgery_truth_preservation` by structural induction (~10 lines)
  - Combine all cases into the main theorem
  - `temporal_truth M atomMap t A <-> temporal_truth N atomMap_N t A` for all t in I, all A
  - File: same as Task 4.1
  - Success criterion: theorem compiles without sorry

**Timing**: 3 hours

**Depends on**: 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/GoodStructuresModelSurgery.lean` -- ~120-180 lines

**Verification**:
- `#check surgery_truth_preservation` type-checks with correct type
- Each subcase compiles independently
- No sorry in any subcase

---

### Phase 5: Final Contradiction (Lemma 13) [NOT STARTED]

**Goal**: Use truth preservation to derive contradiction, closing the `gap_prior_UZ_contradiction` sorry.

**Tasks**:
- [ ] **Task 5.1**: Prove N is a Prior structure (~15 lines)
  - truth preservation gives Prior-UZ for N: any counterexample in N would transfer to M, contradicting h_prior_UZ
  - similarly for Prior-SZ
  - File: `GoodStructuresModelSurgery.lean`, inside `gap_prior_UZ_contradiction`

- [ ] **Task 5.2**: Prove R holds in N at all t in I (~10 lines)
  - By truth preservation from M (h_R_everywhere)
  - gap_formula_R_correct on N: R true implies right_gap_class_prop at t in N

- [ ] **Task 5.3**: Prove right_gap_class_prop is FALSE in N (~20 lines)
  - In N = I, the class of any t is ALL of N (I is a single M-class, and N restricted to I means every point in N is contemp_equiv to every other point in N)
  - A class that IS the entire structure has no gap (no point outside the class, so no b with b > t and b not in class(t))
  - Therefore right_gap_class_prop is false at every point in N

- [ ] **Task 5.4**: Derive `False` and close the sorry (~5 lines)
  - R holds at a in N (Task 5.2) implies right_gap_class_prop at a in N (Task 5.2)
  - But right_gap_class_prop is false at a in N (Task 5.3)
  - Contradiction. Replaces sorry at GoodStructuresModelSurgery.lean:1181

**Timing**: 1 hour

**Depends on**: 4

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/GoodStructuresModelSurgery.lean` -- ~50 lines, replacing the sorry

**Verification**:
- `gap_prior_UZ_contradiction` compiles without sorry
- `gap_prior_SZ_contradiction` compiles without sorry (already reduces to UZ case)
- `grep -n "sorry" GoodStructuresModelSurgery.lean` shows zero active sorry
- `#print axioms no_gaps_discrete_model_surgery` shows no `sorryAx`

---

### Phase 6: Wiring + Cleanup + Verification (Piece 11) [NOT STARTED]

**Goal**: Wire `no_gaps_discrete` in GoodStructures.lean to `no_gaps_discrete_model_surgery`, verify the full build, and ensure the downstream sorry chain is eliminated.

**Tasks**:
- [ ] **Task 6.1**: Add import of `GoodStructuresModelSurgery` to `GoodStructures.lean` (~1 line)
- [ ] **Task 6.2**: Replace sorry at `no_gaps_discrete` (GoodStructures.lean) with delegation (~5 lines)
  - `exact no_gaps_discrete_model_surgery sig k M atomMap h_surj h_prior_UZ h_prior_SZ a b h_diff_class`
  - May need to massage hypothesis names to match signature
- [ ] **Task 6.3**: Run `lake build` and verify sorry count decreases (~10 min)
- [ ] **Task 6.4**: Verify downstream chain is sorry-free
  - `#print axioms no_gaps_discrete` -- no sorryAx
  - `#print axioms one_class` -- no sorryAx (inherits from no_gaps_discrete)
  - `#print axioms chronicle_is_good_direct` -- no sorryAx (inherits from one_class)
- [ ] **Task 6.5**: Remove any remaining sorry stubs from helper lemmas
- [ ] **Task 6.6**: Add documentation comments to key pieces

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

- [x] Phase 1: `eval_good_rel_lifted` compiles without sorry (De Bruijn fix confirmed)
- [x] Phase 1: `#check gap_formula_R_correct` type-checks with correct signature
- [x] Phase 2: `h_R_everywhere` proved sorry-free
- [x] Phase 2: `invariant_formula_constant` proved sorry-free
- [x] Phase 2: `gap_prior_SZ_contradiction` reduced to UZ case sorry-free
- [ ] Phase 3: temporal class spread compiles without sorry
- [ ] Phase 3: bad interval density compiles without sorry
- [ ] Phase 4: Each truth preservation case compiles independently
- [ ] Phase 4: `surgery_truth_preservation` assembles without sorry
- [ ] Phase 5: `gap_prior_UZ_contradiction` compiles without sorry
- [ ] Phase 5: `#print axioms no_gaps_discrete_model_surgery` shows no `sorryAx`
- [ ] Phase 6: `lake build` succeeds
- [ ] Phase 6: `#print axioms no_gaps_discrete` shows no `sorryAx`
- [ ] Phase 6: `#print axioms one_class` shows no `sorryAx`
- [ ] Phase 6: `#print axioms chronicle_is_good_direct` shows no `sorryAx`
- [ ] Final: No new sorry sites in any modified file

## Artifacts & Outputs

- `specs/202_reynolds_k_equivalence_bypass/plans/19_reynolds-model-surgery-v18.md` (this plan)
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/GoodStructuresModelSurgery.lean` (MODIFY, +~200-300 lines: Phases 3-5)
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/GoodStructures.lean` (MODIFY, +~6 lines: Phase 6 wiring)

## Rollback/Contingency

**Phase 3**: If encoding "A holds somewhere in class(x)" as a MonadicFormula proves intractable, consider alternative formulations: (a) encode via existential quantification in the monadic signature, (b) bypass Lemma 9.1 and prove density directly using h_R_everywhere and the specific structure of gap_formula_R.

**Phase 4**: If truth preservation exceeds 200 lines, split the U(A,B) case into a separate helper lemma. Each case is independent, so partial progress is preservable. If specific subcases resist completion, sorry them individually and move to Phase 5 to verify the contradiction structure.

**Phase 5**: If the N-as-subtype construction causes instance synthesis problems, define N using a simpler carrier type (e.g., `M.carrier` with a predicate for class membership) and prove the structural properties manually.

**General fallback**: If model surgery cannot be completed within 2 more implementation cycles, elevate the sorry at `gap_prior_UZ_contradiction` to a named `axiom` declaration, document as "unproved Reynolds Lemma 12-13 awaiting formalization," and proceed with downstream engineering. This preserves the proof architecture while acknowledging the formalization gap.
