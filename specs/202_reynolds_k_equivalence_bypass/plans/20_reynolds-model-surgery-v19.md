# Implementation Plan: Task #202 -- Reynolds Model Surgery v19

- **Task**: 202 - Reynolds k-equivalence bypass for sorry-free completeness_discrete
- **Status**: [COMPLETED]
- **Effort**: 5 hours (0 remaining)
- **Dependencies**: None
- **Research Inputs**: reports/17_deep-research-synthesis.md (comprehensive synthesis of 17+ cycles), .blocker-research-findings.md (Phase 3 blocker resolution via Reynolds Lemmas 10-13), handoffs/phase-3-handoff-20260601.md, handoffs/phase-5-handoff-cycle5-20260601.md, handoffs/phase-4-handoff-density-20260601.md
- **Artifacts**: plans/20_reynolds-model-surgery-v19.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Plan v19 is an accuracy revision of v18, correcting phase statuses and task checkmarks to reflect actual implementation progress as of 2026-06-01. No structural changes to the plan -- the same 6-phase decomposition applies. The key corrections: Phase 3 is [PARTIAL] (not [COMPLETED]), Phase 4 is [PARTIAL] (not [BLOCKED]) with Tasks 4.1/4.2 done, and Phase 5 is [COMPLETED] with all subtasks marked done. The remaining work is concentrated in Task 3.2 (Reynolds Lemma 11 density, ~50-80 lines) which blocks Tasks 4.3/4.4 (ordered spread sorry sites, ~20 lines to apply). Total remaining: ~70-100 lines.

All 6 phases are complete. Phase 3: class_spread + ordered_spread_above/below (Reynolds Lemma 11 density) done. Phase 4: surgery model N defined, truth preservation by structural induction sorry-free. Phase 5: final contradiction chain wired sorry-free. Phase 6: wiring through ShiftAndGlue.lean (import cycle bypass). GoodStructuresModelSurgery.lean has zero sorry sites. completeness_discrete critical path is sorry-free.

### Research Integration

- **reports/17_deep-research-synthesis.md**: Root cause analysis of 17+ failed cycles, 11-piece decomposition, anti-patterns. Integrated in v17.
- **.blocker-research-findings.md**: Phase 3 blocker resolution. Identifies Reynolds Lemmas 10-13 as the correct path. h_R_everywhere eliminates Q-/Q+, reducing Lemma 12 from 7 to 2 cases. Integrated in v18.
- **handoffs/phase-5-handoff-cycle5-20260601.md**: Confirms contemp_eq_body_correct sorry closed, truth_pres proved (2 sorry sub-cases), Prior-UZ/SZ on N proved, final contradiction wired. Integrated in v19.
- **handoffs/phase-4-handoff-density-20260601.md**: Detailed analysis of ordered spread blocker, identifies Reynolds Lemma 11 density as correct approach, implementation plan for ~60-100 lines. Integrated in v19.

### Prior Plan Reference

Plan v18 (6 phases, 10 hours) had several status inaccuracies: Phase 3 marked [COMPLETED] despite Task 3.2 being unchecked and deferred; Phase 4 marked [BLOCKED] despite Tasks 4.1/4.2 being done; Phase 5 marked [COMPLETED] but with all subtasks unchecked despite the work being done. This v19 plan corrects all statuses and task checkmarks to match the actual codebase state.

### Roadmap Alignment

Roadmap identifies task 202 as critical path: "Task 155 (EF-game infrastructure) -> Task 202 (Reynolds k-equivalence bypass) -> sorry-free completeness_discrete." This plan directly advances the Reynolds pipeline milestone.

## Goals & Non-Goals

**Goals**:
- ~~Close `gap_prior_UZ_contradiction` sorry~~ **DONE** — GoodStructuresModelSurgery.lean has 0 sorry sites
- ~~Wire critical path to `no_gaps_discrete_model_surgery`~~ **DONE** — via ShiftAndGlue.lean (import cycle bypass; `no_gaps_discrete` in GoodStructures.lean retains sorry, off critical path)
- ~~Produce sorry-free `no_gaps_discrete_model_surgery`, `gap_contradicts_prior`, `gap_contradicts_prior_below`, `reynolds_model_surgery_core`~~ **DONE**
- ~~Make downstream chain sorry-free: `chronicle_is_good_direct` -> `completeness_discrete`~~ **DONE**

**Non-Goals**:
- Transfer.lean `countermodel_discrete_reynolds` packaging sorry (not on critical path)
- Modifying the dense completeness path
- Doets Lemma 1.5 or Z+Z ~k Z (Reynolds approach does not need these)
- General-purpose bounded quantifier relativization

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Lemma 11 density transition argument harder than estimated | M | 25% | Implementation plan in phase-4-handoff-density-20260601.md is detailed. Three components are well-understood. |
| Constructing the C formula for Lemma 11 | L | 20% | Similar to spread_formula construction (already done in class_spread). Infrastructure available: US_expressively_complete_over_prior, contemp_eq_body. |
| Applying Lemma 11 to sorry sites takes more than ~20 lines | L | 15% | Application is via exfalso -- assume negation, derive density contradiction, use witness. Pattern is clear. |

## Anti-Patterns (DO NOT)

Based on 17+ failed cycles plus Phase 3/4 blocker analysis:

1. **DO NOT** attempt to derive False from h_R_everywhere without model surgery. Extensively analyzed; no shortcut exists.
2. **DO NOT** use Doets Lemma 1.5 or Z+Z ~k Z. Reynolds' proof does not need these.
3. **DO NOT** construct a temporal formula detecting `contemp_equiv` class membership. Mathematically impossible.
4. **DO NOT** bypass model surgery with a direct Prior-UZ argument on R. U(R, R.neg) is vacuously satisfied when R holds everywhere.
5. **DO NOT** expect class homogeneity alone to give contemp_equiv everywhere.
6. **DO NOT** reason about Q-/Q+ regions. Since h_R_everywhere, the entire carrier is "bad."
7. **DO NOT** try to use invariant_formula_constant on spread_above. spread_above is NOT contemp_equiv-invariant (y > x doesn't transfer when x < x'). Only spread_below is invariant.

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 (specifically Task 3.2) |
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

### Phase 3: Temporal Class Spread + Bad Interval Density (Lemmas 9.1, 11) [COMPLETED]

**Goal**: Prove Reynolds Lemma 9 first part (if temporal A holds somewhere in one class, it holds somewhere in every class) and Lemma 11 (formulas true in M are true arbitrarily close to class boundaries). These are prerequisites for truth preservation.

**Tasks**:
- [x] **Task 3.1**: Prove temporal class spread (~50-80 lines)
  - **Statement**: If temporal formula A holds at some point in class C1, then A holds at some point in every contemp_equiv class.
  - **Implementation**: `class_spread` proved via `spread_formula = .ex (.and contemp_eq_body (table A).lift 1)` + `invariant_formula_constant`. The `contemp_eq_body_correct` sorry for Fin.cons De Bruijn bookkeeping has been CLOSED (technique: `show` + definitional equality to bypass Fin.cons reduction at non-canonical indices 2, 3).
  - **Status**: Sorry-free, compiling.
  - File: `GoodStructuresModelSurgery.lean`, inside `gap_prior_UZ_contradiction` after `invariant_formula_constant`

- [x] **Task 3.2**: Prove bad interval density / Reynolds Lemma 11 (~100 lines each direction) *(deviation: altered -- proof uses ordered_spread_above/below with MonadicFormula encoding of spread_below_A/spread_above_A, transition across gap via prior_UZ_first_transition + no_boundary_at_successor; spread_below is NOT invariant contrary to earlier analysis but invariance is not needed)*
  - **Statement**: For any t in class(a), if temporal formula A holds somewhere in M, then A holds at some point above t in class(a) (ordered_spread_above) and below t (ordered_spread_below).
  - **Implementation**: `ordered_spread_above` and `ordered_spread_below` (~100 lines each). Encodes spread_below_A as MonadicFormula, obtains temporal equivalent via US_expressively_complete_over_prior, shows it transitions TRUE→FALSE across gap boundary, derives contradiction via prior_UZ_first_transition + no_boundary_at_successor (discrete adjacency c/succ(c)).
  - **Status**: Done, sorry-free, compiling.
  - File: `GoodStructuresModelSurgery.lean`, inside `gap_prior_UZ_contradiction`

**Timing**: 2 hours (1.5 hours spent on Task 3.1, 0.5 hours remaining for Task 3.2 estimate is ~1-2 hours)
**Depends on**: 2
**Started**: 2026-06-01

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/GoodStructuresModelSurgery.lean` -- ~50-80 lines for Task 3.2

**Verification**:
- [x] Task 3.1: class_spread compiles without sorry
- [x] Task 3.1: contemp_eq_body_correct compiles without sorry
- [x] Task 3.2: bad interval density compiles without sorry (ordered_spread_above/below)

---

### Phase 4: Truth Preservation for N = I (Lemma 12 simplified) [COMPLETED]

**Goal**: Define surgery model N = M restricted to a single equivalence class I. Prove that temporal truth is preserved between M and N for all temporal formulas, for all points in I.

**Strategy**: N is defined as a subtype/substructure of M on a single class I. Truth preservation by structural induction on Formula. The h_R_everywhere simplification means Q- = Q+ = empty, reducing the U(A,B) case from 7 subcases (Reynolds) to 2. The remaining 2 subcases (forward direction when witness is outside class) require Reynolds Lemma 11 density (Task 3.2).

**Tasks**:
- [x] **Task 4.1**: Define surgery model N (~30 lines)
  - N = M|I defined as OrderedMonadicStructure with carrier = {x : M.carrier // contemp_equiv sig k M a x}
  - All required instances proved: LinearOrder (inherited), SuccOrder, PredOrder (succ/pred-closed), NoMaxOrder, NoMinOrder (unbounded), monadic predicates (inherited)
  - Additional properties proved: `class_convex`, `h_N_one_class` (single class in N), `h_N_very_good` (all M-subintervals within class(a) are good)
  - File: `GoodStructuresModelSurgery.lean`, inside `gap_prior_UZ_contradiction`
  - **Status**: Done, sorry-free, compiling.

- [x] **Task 4.2**: Prove truth preservation -- atom/bot/imp/box cases (~20 lines)
  - `atom`: same predicates at same points -- Iff.rfl
  - `bot`: always false -- Iff.rfl
  - `imp A B`: by induction hypothesis
  - `box A`: S5 single-class identity, box is predicate -- Iff.rfl
  - File: same as Task 4.1
  - **Status**: Done, sorry-free, compiling.

- [x] **Task 4.3**: Prove truth preservation -- U(A,B) case (~60-80 lines)
  - **Forward (M -> N)**: M satisfies U(A,B)(t) with witness s > t
    - *Case 1*: s is in I. Direct via convexity + IH. Sorry-free.
    - *Case 2*: s is NOT in I. Uses `ordered_spread_above` (Task 3.2) to find A above t in class(a). Sorry-free.
  - **Backward (N -> M)**: N satisfies U(A,B)(t) with witness s in I. By convexity + IH. Sorry-free.
  - **Status**: Done, sorry-free, compiling.
  - File: same as Task 4.1

- [x] **Task 4.4**: Prove truth preservation -- S(A,B) case (~50-70 lines)
  - Mirror of U(A,B) with time reversed.
  - Uses `ordered_spread_below` (Task 3.2) for the forward case when witness outside class(a).
  - **Status**: Done, sorry-free, compiling.
  - File: same as Task 4.1

- [x] **Task 4.5**: Assemble `surgery_truth_preservation` by structural induction (~10 lines)
  - All cases sorry-free. Theorem compiles without sorry.
  - **Status**: Done, sorry-free, compiling.
  - File: same as Task 4.1

**Timing**: 3 hours (2.5 hours spent; ~0.5 hours remaining to apply Lemma 11 once Task 3.2 is done -- ~20 lines)
**Depends on**: 3 (specifically Task 3.2 for Tasks 4.3/4.4)
**Started**: 2026-06-01

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/GoodStructuresModelSurgery.lean` -- ~20 lines to apply Lemma 11 at the 2 sorry sites

**Verification**:
- [x] Task 4.1: N type-checks as OrderedMonadicStructure with all required instances
- [x] Task 4.2: atom/bot/imp/box cases compile without sorry
- [x] Task 4.3: U(A,B) forward case 2 compiles without sorry (uses ordered_spread_above)
- [x] Task 4.4: S(A,B) forward case 2 compiles without sorry (uses ordered_spread_below)
- [x] Task 4.5: truth_pres assembles without sorry

---

### Phase 5: Final Contradiction (Lemma 13) [COMPLETED]

**Goal**: Use truth preservation to derive contradiction, closing the `gap_prior_UZ_contradiction` sorry.

**Tasks**:
- [x] **Task 5.1**: Prove N is a Prior structure (~15 lines)
  - Prior-UZ/SZ on N proved sorry-free via truth preservation: any counterexample in N transfers to M via truth_pres backward direction, contradicting h_prior_UZ/h_prior_SZ. Key insight: first/last occurrence s0 is between t and s (both in class(a)), so s0 is in class(a) by convexity.
  - File: `GoodStructuresModelSurgery.lean`, lines ~1562-1601

- [x] **Task 5.2**: Prove R holds in N at all t in I (~10 lines)
  - By truth preservation from M (h_R_everywhere): R true in M at t implies R true in N at t.
  - File: same, part of final contradiction chain

- [x] **Task 5.3**: Prove right_gap_class_prop is FALSE in N (~20 lines)
  - `h_rgcf_false_N` proved sorry-free. In N = I, all N-subintervals are good (h_N_very_good). Uses `k_equiv_of_iso` to transfer between N.subinterval and M.subinterval via convexity of class(a).
  - File: same, lines ~1602-1650

- [x] **Task 5.4**: Derive `False` and close the sorry (~5 lines)
  - Final contradiction chain wired: R on N (truth_pres + h_R_everywhere) -> right_gap_class_formula on N (US_expressively_complete_over_prior) -> contradiction (h_rgcf_false_N).
  - File: same, part of final contradiction chain

**Timing**: 1 hour
**Depends on**: 4
**Completed**: 2026-06-01

**Note**: Phase 5 is structurally complete and sorry-free in its own right. The 2 sorry sites from Phase 4 (Tasks 4.3/4.4) propagate through truth_pres into Phase 5, but all Phase 5-specific logic is proven. Once Phase 4 is sorry-free, Phase 5 is automatically sorry-free.

**Files modified**:
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/GoodStructuresModelSurgery.lean` -- lines ~1562-1650

---

### Phase 6: Wiring + Cleanup + Verification (Piece 11) [COMPLETED]

**Goal**: Wire the sorry-free `no_gaps_discrete_model_surgery` into the critical path for `completeness_discrete`.

*(Deviation: Cannot add import of GoodStructuresModelSurgery to GoodStructures.lean due to circular import — GoodStructuresModelSurgery imports GoodStructures. Wiring done at consumer level in ShiftAndGlue.lean instead.)*

**Tasks**:
- [x] **Task 6.1**: Add import of `GoodStructuresModelSurgery` to `ShiftAndGlue.lean` (~1 line) *(deviation: target file changed from GoodStructures.lean to ShiftAndGlue.lean due to import cycle)*
- [x] **Task 6.2**: Inline `one_class` proof in `chronicle_is_good_direct` using `no_gaps_discrete_model_surgery` (~7 lines) *(deviation: inlined rather than delegating through `no_gaps_discrete`, to bypass import cycle)*
- [x] **Task 6.3**: `lake build` passes (1680 jobs, zero errors)
- [x] **Task 6.4**: Verify downstream chain is sorry-free
  - `chronicle_is_good_direct` -- sorry-free (uses `no_gaps_discrete_model_surgery` directly)
  - `countermodel_discrete_enriched` -- sorry-free (uses `chronicle_is_good_direct`)
  - `completeness_discrete` -- sorry-free (uses `countermodel_discrete_enriched`)
  - Note: `no_gaps_discrete` and `one_class` in GoodStructures.lean retain sorry (import cycle), but are off the critical path
- [x] **Task 6.5**: GoodStructuresModelSurgery.lean has zero active sorry sites
- [x] **Task 6.6**: Added explanatory comment in GoodStructures.lean at `no_gaps_discrete` sorry explaining import cycle and ShiftAndGlue wiring

**Timing**: 0.5 hours
**Depends on**: 5
**Completed**: 2026-06-01

**Files modified**:
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/ShiftAndGlue.lean` -- Added import + inlined one_class proof (~8 lines)
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/GoodStructures.lean` -- Added comment explaining import cycle

## Testing & Validation

- [x] Phase 1: `eval_good_rel_lifted` compiles without sorry (De Bruijn fix confirmed)
- [x] Phase 1: `#check gap_formula_R_correct` type-checks with correct signature
- [x] Phase 2: `h_R_everywhere` proved sorry-free
- [x] Phase 2: `invariant_formula_constant` proved sorry-free
- [x] Phase 2: `gap_prior_SZ_contradiction` reduced to UZ case sorry-free
- [x] Phase 3 Task 3.1: temporal class spread (`class_spread`) compiles without sorry
- [x] Phase 3 Task 3.1: `contemp_eq_body_correct` compiles without sorry
- [x] Phase 3 Task 3.2: bad interval density (ordered_spread_above/below) compiles without sorry
- [x] Phase 4 Tasks 4.1-4.2: surgery model N defined, atom/bot/imp/box truth preservation sorry-free
- [x] Phase 4 Task 4.3: U(A,B) forward case 2 compiles without sorry (uses ordered_spread_above)
- [x] Phase 4 Task 4.4: S(A,B) forward case 2 compiles without sorry (uses ordered_spread_below)
- [x] Phase 4 Task 4.5: `surgery_truth_preservation` assembles without sorry
- [x] Phase 5: Prior-UZ/SZ on N proved sorry-free (assuming truth_pres)
- [x] Phase 5: `h_rgcf_false_N` proved sorry-free
- [x] Phase 5: Final contradiction chain wired sorry-free (assuming truth_pres)
- [x] Phase 6: `lake build` succeeds (1680 jobs)
- [x] Phase 6: `chronicle_is_good_direct` sorry-free (wired through ShiftAndGlue.lean)
- [x] Phase 6: `completeness_discrete` critical path sorry-free
- [x] Phase 6: Note: `no_gaps_discrete`/`one_class` in GoodStructures.lean retain sorry (import cycle, off critical path)
- [x] Final: GoodStructuresModelSurgery.lean has zero active sorry sites

## Completion Summary

All 6 phases are [COMPLETED]. GoodStructuresModelSurgery.lean has zero sorry sites. The `completeness_discrete` critical path is sorry-free via the wiring in ShiftAndGlue.lean.

**Final sorry count in GoodStructuresModelSurgery.lean**: 0
**Residual sorry**: `no_gaps_discrete` in GoodStructures.lean retains sorry due to import cycle (GoodStructuresModelSurgery imports GoodStructures). This is off the critical path — `chronicle_is_good_direct` uses `no_gaps_discrete_model_surgery` directly via ShiftAndGlue.lean.

## Artifacts & Outputs

- `specs/202_reynolds_k_equivalence_bypass/plans/20_reynolds-model-surgery-v19.md` (this plan)
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/GoodStructuresModelSurgery.lean` (MODIFIED, 0 sorry sites)
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/ShiftAndGlue.lean` (MODIFIED, +8 lines: Phase 6 wiring)
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/GoodStructures.lean` (MODIFIED, import cycle comment)

## Rollback/Contingency

**Task 3.2 (Lemma 11)**: If the transition argument with Prior-SZ proves harder than estimated, consider: (a) constructing C as a simpler temporal formula (e.g., using S(negB, Top) directly rather than the full "exists negB before me in my class" encoding), (b) using a weaker density statement that suffices for the specific sorry sites (we only need "if A holds somewhere in M and A is in one class via class_spread, then A holds above t in that class").

**Phase 6**: If the N-as-subtype construction causes instance synthesis problems at the wiring stage, define an adapter that translates between the surgery model's interface and GoodStructures.lean's expected signature.

**General fallback**: If Lemma 11 cannot be completed within 1 more implementation cycle, elevate the 2 sorry sites to named `axiom` declarations, document as "unproved Reynolds Lemma 11 (density) awaiting formalization," and proceed with Phase 6 wiring. This preserves the proof architecture while acknowledging the formalization gap.
