# Implementation Plan: Reynolds Pipeline Activation (v2)

- **Task**: 155 - reynolds_pipeline_activation
- **Status**: [NOT STARTED]
- **Effort**: 22 hours
- **Dependencies**: Task 154 (sum_preservation/doets_lemma_1_4, COMPLETED), Tasks 147-148 (table_correctness, COMPLETED)
- **Research Inputs**: specs/155_reynolds_pipeline_activation/reports/02_team-research.md
- **Artifacts**: plans/02_reynolds-pipeline-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

---

## CRITICAL DIRECTIVE: NO DEVIATION FROM REYNOLDS 1994

**DO NOT deviate from the published proof structure without outstandingly good reason.**

The first implementation attempt (v1 Phases 2-4) deviated from Reynolds 1994 by:
- Adding `[IsSuccArchimedean M.carrier]` as hypothesis to all theorems
- Using Mathlib's `orderIsoIntOfLinearSuccPredArch` to shortcut proofs
- Proving `no_gaps_discrete` vacuously (hypothesis unsatisfiable)
- Result: **circular dependency** through `succ_cofinal` (task 129 sorry)

**This approach failed completely and must be entirely replaced.**

The proofs in Reynolds 1994 Sections 7-8 are genuinely hard -- they span ~20 pages of dense mathematical argument. There is no shortcut. The difficulty is intrinsic to the mathematics. Agents MUST:

1. **READ the literature files** before attempting each phase:
   - `literature/Reynolds_1994_Axiomatising_U_and_S_over_integer_time.md` (primary)
   - `literature/Doets_1989_Monadic_Pi11_Theories.md` (for sum preservation)
2. **Follow the paper step-by-step** -- every lemma, every case split, every construction
3. **NEVER add `IsSuccArchimedean` as a hypothesis** -- Reynolds does not use it
4. **NEVER use `orderIsoIntOfLinearSuccPredArch`** -- this is the shortcut that caused the failure
5. **If stuck, re-read the literature** -- the answer is in the paper, not in Mathlib search
6. **Acknowledge that these proofs are hard** -- budget time accordingly, do not rush

**The literature provides the easiest path.** It is not an obstacle to be gotten around; it is the solution.

---

## Overview

Replace the failed IsSuccArchimedean-based implementation (v1 Phases 2-4) with a faithful formalization of Reynolds 1994 Sections 7-8. The key chain: Lemma 17 (transitivity of ~M via ordered sum decomposition) -> Theorem 14 (gap elimination via expressive completeness of {U,S}) -> one-class theorem -> Lemma 16 (very good implies good via cofinal decomposition) -> truth transfer -> TaskFrame construction. Phase 1 (finite_structures_good) is COMPLETED and correct. Definition of done: `#print axioms bx_completeness` shows no `sorryAx`, chronicle fallback removed from Transfer.lean.

### Research Integration

Integrated from `reports/02_team-research.md` (team research, 4 teammates, unanimous HIGH confidence):
- Diagnosis: v1 Phases 2-4 deviated from Reynolds by using IsSuccArchimedean, creating circular dependency
- Reynolds's actual Theorem 15 NEVER requires IsSuccArchimedean
- The fix: rewrite following Reynolds faithfully using `table_correctness` and `doets_lemma_1_4`
- Hardest part: Theorem 14 (gap elimination, ~6 pages in paper)
- All four researchers independently reached the same conclusion

### Prior Plan Reference

v1 plan (01_reynolds-pipeline-plan.md): Phase 1 validated (COMPLETED, correct approach via Doets 1.1). Phases 2-4 took shortcuts that introduced circular dependency. Phases 5-6 blocked as a result. Lesson: do not deviate from the published proof. Effort calibration: Phase 1 took 4 hours as planned; Phases 2-4 took 14 hours total despite "simpler" approach but produced unusable results. The genuine approach is harder per phase but produces correct results.

### Roadmap Alignment

- Advances "sorry-free `bx_completeness`" (the primary critical path item)
- Eliminates circular dependency through `succ_cofinal` (task 129)
- Closes the discrete completeness branch of the Reynolds pipeline

## Goals & Non-Goals

**Goals**:
- REMOVE `[IsSuccArchimedean M.carrier]` from `contemp_equiv_is_equiv`, `no_gaps_discrete`, `one_class`, `very_good_implies_good`
- REWRITE these theorems following Reynolds 1994 Sections 7-8 faithfully
- Prove `chronicle_is_good` WITHOUT `orderIsoIntOfLinearSuccPredArch`
- Construct truth transfer via existential closure of table formula
- Construct TaskFrame Int and wire into Transfer.lean
- Achieve `#print axioms bx_completeness` with no `sorryAx`

**Non-Goals**:
- Dense completeness (separate, unaffected)
- Closing `succ_cofinal` (task 129) -- we bypass it entirely
- General `k_equiv_preserves_eval` for arbitrary formulas
- Optimizing existing sorry-free infrastructure
- Any Mathlib-shortcut approach to Z-classification

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Theorem 14 (gap elimination) is genuinely hard (~6 pages in Reynolds) | H | H | Budget 8 hours; break into sub-lemmas (Lemmas 6-13); use `table_correctness` as expressive completeness tool |
| Ordered sum decomposition for transitivity (Lemma 17) requires careful subtype manipulation | M | M | Follow Reynolds's interval decomposition exactly; use `doets_lemma_1_4` |
| Cofinal sequence construction for Lemma 16 may require new Mathlib lemmas | M | L | Standard construction from Countable + NoMaxOrder; may already exist in Mathlib |
| Z-interval concatenation (ordered sum of Z-intervals indexed by Z = single Z-interval) | M | M | Standalone helper; the math is straightforward (shift and glue) |
| Agent deviates from Reynolds's proof structure again | H | M | Explicit directive at top of plan; phase-level literature references; instruction to READ before coding |

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

All phases are strictly sequential. Each phase builds on the previous.

---

### Phase 1: finite_structures_good (Doets Theorem 1.1) [COMPLETED]

**Goal**: Prove every finite ordered monadic structure is k-equivalent to a Z-interval structure.

**Tasks**:
- [x] Redesign `ZIntervalStructure.toOrdered` carrier
- [x] Construct `ZIntervalStructure sig` with interval matching
- [x] Prove `k_equiv_of_iso`
- [x] Close the sorry via `k_equiv_of_iso`
- [x] Verify `lake build` passes

**Timing**: 4 hours (actual)

**Depends on**: none

**Completed**: 2026-05-16

**Verification**:
- `lean_verify` on `finite_structures_good`: no `sorryAx`

---

### Phase 2: Rewrite contemp_equiv_is_equiv (Reynolds Lemma 17 -- Transitivity) [PARTIAL]

**Goal**: Rewrite the transitivity proof of ~M WITHOUT `IsSuccArchimedean`. Reynolds Lemma 17 proves: if [a,b] is very good and [b,c] is very good, then [a,c] is very good, by decomposing any subinterval [x,y] of [a,c] spanning b into two good pieces and applying `doets_lemma_1_4` (sum preservation).

**Reynolds Reference**: Lemma 17, Reynolds 1994 pp.938-953. The proof decomposes the interval at b, yielding an ordered sum of two good subintervals, then applies Doets's sum preservation theorem.

**BEFORE CODING**: Read `literature/Reynolds_1994_Axiomatising_U_and_S_over_integer_time.md` lines 938-953. Read `literature/Doets_1989_Monadic_Pi11_Theories.md` Section 1.4. Understand the ordered sum decomposition argument completely before writing Lean.

**Tasks**:
- [x] **Task 2.1**: REMOVE `[IsSuccArchimedean M.carrier]` from `contemp_equiv_is_equiv` *(completed: signature now `[SuccOrder M.carrier] [NoMaxOrder M.carrier]`)*
- [x] **Task 2.2**: REMOVE `subinterval_finite_of_succ_archimedean` from the transitivity proof *(completed: transitivity no longer uses it)*
- [x] **Task 2.3**: Prove "flatten" lemma: `subinterval_of_subinterval_k_equiv` *(completed)*
- [ ] **Task 2.4**: Prove transitivity case 1: if x <= b <= y, decompose [x,y] into ordered sum of [x,b] and [b,y]. Both are subintervals of [a,b] or [b,c] respectively, hence good by very_good hypothesis. Apply `doets_lemma_1_4` to get [x,y] good. *(deviation: altered -- uses `good_of_split_at_succ` with sorry for the ordered-sum iso + Z-interval concatenation)*
- [x] **Task 2.5**: Prove transitivity case 2: if x,y both in [a,b], then [x,y] is a subinterval of [a,b], hence good by very_good of [a,b]. Similarly for both in [b,c]. *(completed: Cases A and B in transitivity proof)*
- [x] **Task 2.6**: Assemble full transitivity proof by case analysis on position of x,y relative to b *(completed)*
- [x] **Task 2.7**: Verify `lake build` passes with rewritten `contemp_equiv_is_equiv` *(completed: full lake build passes)*

**Remaining sorry**: `good_of_split_at_succ` (1 sorry) -- requires constructing OrderIso from subinterval to Sigma.Lex ordered sum and proving ordered sum of Z-intervals is good. Structural approach is correct but Lean encoding of the OrderIso is complex.

**Timing**: 4 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel.lean` - Rewrite `contemp_equiv_is_equiv`, add helper lemmas

**Verification**:
- `lean_verify` on `contemp_equiv_is_equiv` shows no `sorryAx`
- No `IsSuccArchimedean` in the theorem statement
- `lake build` passes

---

### Phase 3: Rewrite no_gaps_discrete (Reynolds Theorem 14 -- Gap Elimination) [NOT STARTED]

**Goal**: Rewrite the gap elimination theorem WITHOUT `IsSuccArchimedean`. This is THE HARD PHASE. Reynolds Theorem 14 proves that ~M classes cannot end at gaps in Prior structures, using expressive completeness of {U,S} (= `table_correctness`) combined with Prior-UZ axiom validity. The argument constructs explicit formulas that distinguish between "being in the same class" and "not being in the same class" and shows that a gap boundary leads to contradiction.

**Reynolds Reference**: Theorem 14, Reynolds 1994 Section 7, Lemmas 6-13 (~6 pages). The proof uses the fact that for any finite set of k-types, the temporal formulas {U,S} can express membership in each type (this is exactly what `table_correctness` provides). A gap boundary would yield a point where validity of Prior-UZ is violated.

**BEFORE CODING**: Read `literature/Reynolds_1994_Axiomatising_U_and_S_over_integer_time.md` Section 7 (Lemmas 6-13, Theorem 14) IN FULL. This is 6 pages of argument. Understand every step before writing Lean. The key insight: `table_correctness` is the formalized version of Reynolds's "expressive completeness of {U,S}" (his Theorem 5). Prior-UZ validity in the chronicle comes from `ChronicleAsPriorModel`.

**THESE PROOFS ARE GENUINELY HARD. Budget 8 hours. Do not rush.**

**Tasks**:
- [ ] **Task 3.1**: REMOVE `[IsSuccArchimedean M.carrier]` from `no_gaps_discrete`
- [ ] **Task 3.2**: Prove convexity of ~M classes: if a ~M b and a <= c <= b then a ~M c (follows from transitivity + subinterval reasoning from Phase 2)
- [ ] **Task 3.3**: State the gap elimination theorem correctly: given a,b in different ~M classes, construct a boundary point and derive contradiction using Prior-UZ + table_correctness
- [ ] **Task 3.4**: Construct the "bad interval" characterization (Reynolds Lemmas 6-8): formalize what it means for an interval endpoint to be a gap boundary
- [ ] **Task 3.5**: Prove that table formulas distinguish k-types at the boundary (using `table_correctness` as the expressive completeness tool)
- [ ] **Task 3.6**: Prove that Prior-UZ validity contradicts the existence of a gap boundary (Reynolds Lemmas 9-13): the key step where axiom validity eliminates gaps
- [ ] **Task 3.7**: Assemble the full no_gaps_discrete proof
- [ ] **Task 3.8**: Rewrite `one_class` to use the genuine `no_gaps_discrete` + `no_boundary_at_successor` argument (currently proved directly via IsSuccArchimedean; must be rewritten to use the two-step elimination)
- [ ] **Task 3.9**: Verify `lake build` passes

**Timing**: 8 hours (this is the hardest phase -- budget accordingly)

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel.lean` - Rewrite `no_gaps_discrete`, `one_class`, add gap elimination machinery

**Verification**:
- `lean_verify` on `no_gaps_discrete` shows no `sorryAx`
- `lean_verify` on `one_class` shows no `sorryAx`
- No `IsSuccArchimedean` in any theorem statement in this file
- `lake build` passes

---

### Phase 4: Rewrite very_good_implies_good and chronicle_is_good (Reynolds Lemma 16) [NOT STARTED]

**Goal**: Rewrite `very_good_implies_good` WITHOUT `IsSuccArchimedean` or `orderIsoIntOfLinearSuccPredArch`. Reynolds Lemma 16 proves: given a countable linear order without endpoints where every subinterval is good (very_good), the whole structure is good. The proof constructs a cofinal sequence, decomposes the structure into an ordered sum of good pieces indexed by Z, and applies `doets_lemma_1_4` + Z-interval concatenation.

**Reynolds Reference**: Lemma 16, Reynolds 1994 pp.877-903. The proof: (1) choose cofinal sequence a_0 < a_1 < ... using Countable + NoMaxOrder, similarly coinitial a_{-1} > a_{-2} > ...; (2) each [a_i, a_{i+1}] is good by very_good; (3) the whole structure is the ordered sum indexed by Z; (4) by `doets_lemma_1_4`, this ordered sum of good (= k-equiv to Z-intervals) pieces is k-equiv to the ordered sum of Z-intervals; (5) ordered sum of Z-intervals indexed by Z is itself a Z-interval.

**BEFORE CODING**: Read `literature/Reynolds_1994_Axiomatising_U_and_S_over_integer_time.md` pp.877-903. Read `literature/Doets_1989_Monadic_Pi11_Theories.md` Section 1.4. The cofinal decomposition is the core idea.

**Tasks**:
- [ ] **Task 4.1**: REMOVE `[IsSuccArchimedean M.carrier]` from `very_good_implies_good`. The correct hypotheses are: `[Countable M.carrier]`, `[NoMaxOrder M.carrier]`, `[NoMinOrder M.carrier]`, `[Nonempty M.carrier]`, `(h_very_good : very_good sig k M)`. NO SuccOrder, NO PredOrder, NO IsSuccArchimedean.
- [ ] **Task 4.2**: Prove cofinal sequence existence: given `Countable M.carrier` and `NoMaxOrder M.carrier`, construct a sequence `a : Z -> M.carrier` that is strictly increasing and cofinal (every element is between some a_i and a_{i+1})
- [ ] **Task 4.3**: Prove that M is order-isomorphic to the ordered sum of subintervals [a_i, a_{i+1}] indexed by Z
- [ ] **Task 4.4**: Each subinterval [a_i, a_{i+1}] is good by the very_good hypothesis. Extract the k-equivalence witnesses.
- [ ] **Task 4.5**: Apply `doets_lemma_1_4` to the ordered sum: the ordered sum of good subintervals is k-equiv to the ordered sum of their Z-interval witnesses
- [ ] **Task 4.6**: Prove Z-interval concatenation: an ordered sum of Z-intervals (each with lo=some a, hi=some b) indexed by Z is k-equivalent to a single Z-interval with lo=none, hi=none. This is the "shift and glue" construction.
- [ ] **Task 4.7**: Assemble: M ≃ ordered_sum ≈_k ordered_sum_of_Z_intervals ≈_k single_Z_interval
- [ ] **Task 4.8**: Rewrite `chronicle_is_good` to use `one_class` (Phase 3) + `very_good_implies_good` (this phase) instead of `orderIsoIntOfLinearSuccPredArch`. The chronicle satisfies Countable, NoMaxOrder, NoMinOrder, Nonempty; one_class gives very_good; then very_good_implies_good gives good.
- [ ] **Task 4.9**: REMOVE `domain_succ_archimedean` field from `ChronicleAsPriorModel` (or mark as unused/deprecated) and remove `limitDomSubtype_isSuccArchimedean` from `extract_chronicle_as_prior`
- [ ] **Task 4.10**: Verify `lake build` passes

**Timing**: 6 hours

**Depends on**: 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel.lean` - Rewrite `very_good_implies_good`, `chronicle_is_good`, add cofinal sequence + concatenation helpers
- `Theories/Bimodal/Metalogic/WeakCanonical/ChronicleExtraction.lean` - Remove `domain_succ_archimedean` field or mark deprecated

**Verification**:
- `lean_verify` on `very_good_implies_good` shows no `sorryAx`
- `lean_verify` on `chronicle_is_good` shows no `sorryAx`
- No `IsSuccArchimedean` anywhere in `IntegerModel.lean`
- No `orderIsoIntOfLinearSuccPredArch` anywhere in `IntegerModel.lean`
- `lake build` passes

---

### Phase 5: Truth Transfer via Existential Closure [NOT STARTED]

**Goal**: Prove truth transfer from the chronicle's Z-model to temporal truth, using existential closure of the table formula. Given `chronicle_is_good` (now sorry-free from Phase 4) provides k-equivalence between the chronicle and a Z-interval structure, transfer the truth of `neg phi` from the chronicle to the Z-interval.

**Reynolds Reference**: The transfer argument uses the fact that k-equivalence preserves all sentences of quantifier depth <= k. The table formula (Reynolds Section 6, Doets Section 1) translates temporal truth into monadic FO truth. `table_correctness` (sorry-free) provides this bridge.

**BEFORE CODING**: Read `literature/Reynolds_1994_Axiomatising_U_and_S_over_integer_time.md` Section 6 (table translation). Understand how `table_correctness` connects temporal truth to monadic FO satisfaction. The existential closure construction is the standard way to transfer "there exists a point where phi holds."

**Tasks**:
- [ ] **Task 5.1**: State the transfer lemma: given k-equiv between chronicle and Z-interval, and temporal truth of `neg phi` at some point in the chronicle, derive temporal truth of `neg phi` at some point in the Z-interval
- [ ] **Task 5.2**: Construct existential closure: `sentence := MonadicFormula.ex (table sig atomMap (neg phi))`
- [ ] **Task 5.3**: Prove depth bound: `sentence.quantifier_depth <= k` (using `table_depth_bound`)
- [ ] **Task 5.4**: Show sentence is TRUE in chronicle using `table_correctness` (witness: the point where neg phi holds temporally)
- [ ] **Task 5.5**: Transfer via k-equivalence: sentence holds in Z-interval (by `doets_lemma_1_1` or k-equiv definition at appropriate depth)
- [ ] **Task 5.6**: Extract witness and convert back to temporal truth using `table_correctness` on Z-interval
- [ ] **Task 5.7**: Verify `lake build` passes

**Timing**: 3 hours

**Depends on**: 4

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Transfer.lean` or new `TruthTransfer.lean` - Truth transfer lemma

**Verification**:
- `lean_verify` on truth transfer lemma shows no `sorryAx`
- `lake build` passes

---

### Phase 6: TaskFrame Int Construction and Pipeline Wiring [NOT STARTED]

**Goal**: Construct a TaskFrame Int countermodel from the Z-interval structure and wire the full Reynolds pipeline into `doets_countermodel_discrete`, eliminating the chronicle fallback.

**Reynolds Reference**: This is the final packaging step. Reynolds proves the existence of a Z-model satisfying neg phi; we package it as a TaskFrame Int for our formalization's type signature.

**BEFORE CODING**: Review the TaskFrame/TaskModel API in `Theories/Bimodal/Semantics/`. Understand how `truth_at` relates to temporal truth on the carrier. The Z-interval with lo=none, hi=none has carrier `{z : Z // True}` which is trivially isomorphic to Z (= Int).

**Tasks**:
- [ ] **Task 6.1**: Construct carrier isomorphism: Z.intervalCarrier (= `{z : Z // True}`) ≃ Int via `Subtype.val`
- [ ] **Task 6.2**: Transfer temporal truth from Z-interval carrier to bare Int through the isomorphism
- [ ] **Task 6.3**: Construct TaskFrame Int (single-S5-class discrete case): `WorldState := Unit`, trivial task_rel
- [ ] **Task 6.4**: Construct TaskModel and WorldHistory: valuation from Z-model predicates, single history
- [ ] **Task 6.5**: Prove `truth_at` correspondence: `truth_at TM Omega tau t phi <-> temporal_truth Z.toOrdered atomMap t phi`
- [ ] **Task 6.6**: Wire pipeline into `doets_countermodel_discrete`: extract chronicle -> chronicle_is_good -> truth transfer -> carrier iso -> TaskFrame -> truth_at proves countermodel
- [ ] **Task 6.7**: REMOVE the chronicle fallback (lines 141-146 of Transfer.lean)
- [ ] **Task 6.8**: Final verification: `#print axioms bx_completeness` shows no `sorryAx`

**Timing**: 3 hours

**Depends on**: 5

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Transfer.lean` - Replace fallback with full pipeline, TaskFrame construction
- Possibly new `TruthTransfer.lean` if created in Phase 5

**Verification**:
- `#print axioms doets_countermodel_discrete` shows no `sorryAx`
- `#print axioms bx_completeness` shows no `sorryAx`
- `lake build` passes cleanly
- Chronicle fallback code removed from Transfer.lean

---

## Testing & Validation

- [ ] `lake build` passes with zero errors
- [ ] `#print axioms bx_completeness` outputs only: `propext`, `Classical.choice`, `Quot.sound` (NO `sorryAx`)
- [ ] `#print axioms doets_countermodel_discrete` shows no `sorryAx`
- [ ] `#print axioms chronicle_is_good` shows no `sorryAx`
- [ ] `#print axioms contemp_equiv_is_equiv` shows no `sorryAx`
- [ ] `#print axioms no_gaps_discrete` shows no `sorryAx`
- [ ] `#print axioms very_good_implies_good` shows no `sorryAx`
- [ ] No occurrence of `IsSuccArchimedean` in IntegerModel.lean theorem statements
- [ ] No occurrence of `orderIsoIntOfLinearSuccPredArch` in IntegerModel.lean
- [ ] The chronicle fallback is no longer called from Transfer.lean
- [ ] No new `sorry` introduced anywhere in the codebase

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel.lean` - Rewritten Phases 2-4, all sorries closed, no IsSuccArchimedean
- `Theories/Bimodal/Metalogic/WeakCanonical/Transfer.lean` - Full pipeline, no fallback
- `Theories/Bimodal/Metalogic/WeakCanonical/TruthTransfer.lean` (possibly new) - Truth transfer + TaskFrame Int
- `Theories/Bimodal/Metalogic/WeakCanonical/ChronicleExtraction.lean` - domain_succ_archimedean removed/deprecated
- `specs/155_reynolds_pipeline_activation/plans/02_reynolds-pipeline-plan.md` - This plan

## Rollback/Contingency

If implementation encounters a fundamental blocker:

1. **Phase 2 (transitivity)**: If ordered sum decomposition is too complex in Lean, consider an EF-game argument (duplicator composes strategies on overlapping intervals). But TRY the Reynolds approach first.
2. **Phase 3 (gap elimination)**: This is the hardest phase. If stuck after 8 hours, write a detailed handoff documenting: (a) which Reynolds sub-lemmas are proved, (b) which are stuck, (c) what the Lean goal state looks like. Mark [PARTIAL] and request additional research.
3. **Phase 4 (cofinal decomposition)**: If Z-interval concatenation is intractable, consider proving it as a separate task. The math is straightforward but the Lean encoding may require careful OrderIso construction.
4. **Phases 5-6 are low risk**: They depend only on already-proved infrastructure (`table_correctness`, `doets_lemma_1_4`, k-equiv definition).
5. **Partial progress is always safe**: Each phase can be committed independently. The chronicle fallback remains active until Phase 6 removes it.
6. **NEVER fall back to IsSuccArchimedean**: If stuck, mark [BLOCKED] and request help. Do not reintroduce the shortcut that caused the v1 failure.
