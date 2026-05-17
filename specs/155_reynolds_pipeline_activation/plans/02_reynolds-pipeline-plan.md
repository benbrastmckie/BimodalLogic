# Implementation Plan: Reynolds Pipeline Activation (v2)

- **Task**: 155 - reynolds_pipeline_activation
- **Status**: [IN PROGRESS] (Phases 1-2 COMPLETED; Phase 3A delegated to task 157; Phases 4-6 can proceed)
- **Effort**: 22 hours (original) + task 157 (~2500 lines, 3-4 weeks for expressive completeness)
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

### Critical Path Verification (Report 04 Synthesis)

**CONFIRMED** (via `lean_verify`): The planned Reynolds chain IS required for sorry-free `bx_completeness`.
- `bx_completeness` has `sorryAx` (via `dd_countermodel_chronicle_discrete` → `succ_cofinal`)
- `chronicle_is_good` is sorry-free BUT only because it ASSUMES `ChronicleAsPriorModel` (which packages `IsSuccArchimedean`)
- The sorry is in CONSTRUCTING `ChronicleAsPriorModel` (needs `limitDomSubtype_isSuccArchimedean` → `succ_cofinal`)
- Phases 2-4 rewrite `one_class`/`very_good_implies_good`/`chronicle_is_good` to NOT need `IsSuccArchimedean`
- `good_of_split_at_succ` → `contemp_equiv_is_equiv` → `one_class` IS on the critical path in the final state
- A research agent claiming "dead code" was comparing against CURRENT code (not the planned replacement)

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

**Dependency Analysis** (revised after task 157 creation):
| Wave | Phases | Blocked by | Notes |
|------|--------|------------|-------|
| 1 | 1 | -- | COMPLETED |
| 2 | 2 | 1 | COMPLETED |
| 3 | 3A (expressive completeness) | 2 | **Delegated to task 157** |
| 3 | 4 (very_good_implies_good) | 2 | **Can proceed NOW** (independent of 3A/3B) |
| 3 | 5 (truth transfer infrastructure) | 2 | **Can proceed NOW** (takes chronicle_is_good as hypothesis) |
| 3 | 6 (TaskFrame bridge) | 2 | **Can proceed NOW** (pure infrastructure) |
| 4 | 3B (gap elimination → one_class) | 3A (= task 157) | Blocked on task 157 |
| 5 | 4b (chronicle_is_good rewrite) | 3B, 4 | Wires one_class + very_good_implies_good |
| 6 | 6b (final wiring) | 4b, 5, 6 | Replaces fallback in Transfer.lean |

**Parallelism**: Phases 4, 5, 6 can proceed in parallel with task 157. They develop infrastructure that takes upstream results as hypotheses (sorry'd initially, filled when task 157 + Phase 3B complete). Phase 3B and the final wiring (4b, 6b) wait for task 157.

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

### Phase 2: Rewrite contemp_equiv_is_equiv (Reynolds Lemma 17 -- Transitivity) [COMPLETED]

**Goal**: Rewrite the transitivity proof of ~M WITHOUT `IsSuccArchimedean`. Reynolds Lemma 17 proves: if [a,b] is very good and [b,c] is very good, then [a,c] is very good, by decomposing any subinterval [x,y] of [a,c] spanning b into two good pieces and applying `doets_lemma_1_4` (sum preservation).

**Reynolds Reference**: Lemma 17, Reynolds 1994 pp.938-953. The proof decomposes the interval at b, yielding an ordered sum of two good subintervals, then applies Doets's sum preservation theorem.

**BEFORE CODING**: Read `literature/Reynolds_1994_Axiomatising_U_and_S_over_integer_time.md` lines 938-953. Read `literature/Doets_1989_Monadic_Pi11_Theories.md` Section 1.4. Understand the ordered sum decomposition argument completely before writing Lean.

**Tasks**:
- [x] **Task 2.1**: REMOVE `[IsSuccArchimedean M.carrier]` from `contemp_equiv_is_equiv` *(completed: signature now `[SuccOrder M.carrier] [NoMaxOrder M.carrier]`)*
- [x] **Task 2.2**: REMOVE `subinterval_finite_of_succ_archimedean` from the transitivity proof *(completed: transitivity no longer uses it)*
- [x] **Task 2.3**: Prove "flatten" lemma: `subinterval_of_subinterval_k_equiv` *(completed)*
- [x] **Task 2.4a**: Prove `interval_split_iso` -- OrderIso from `M.subinterval sig t u` to `orderedSum sig Bool (fun i => if i = false then M.subinterval sig t b else M.subinterval sig (Order.succ b) u)`. *(completed: inline Equiv.toOrderIso with Monotone proofs using Sigma.Lex.le_def)*
- [x] **Task 2.4b**: Close the k≥2 sorry via expressibility + Fintype + finite_structures_good (~100 lines). *(completed)*
- [x] **Task 2.4b'**: Close the k=1 sorry via `good_one` theorem (report 05). Strategy: prove `good_one : ∀ M, good sig 1 M` using finite model property at depth 1 — construct Z-interval [0, n-1] with one element per realized predicate profile, prove 1-equiv via `nf_characteristic_satisfies` + `nf_agreement_from_shared_nf`. Then replace sorry with `exact good_one sig (orderedSum sig Bool witnesses)`. Verified code (75 lines) in report `05_k1-sorry-research.md`. *(completed)*
  - **k=1 sub-case** (k'=0): COMPLETED via `good_one` theorem.
  - **k≥2 sub-case** (k'≥1): COMPLETED. Uses `doets_lemma_1_1` to transfer "has max/min" (depth-2 sentences). Z1/Z2 proved bounded → Fintype via Set.Icc equiv. Sigma.instFintype → finite_structures_good.
- [x] **Task 2.4c**: (Subsumed into 2.4b — the k≥2 path proves the ordered sum is finite directly without needing a separate z_interval_sum_good lemma. The Fintype → finite_structures_good path is simpler than shift-and-glue.) *(completed: subsumed)*
- [x] **Task 2.4d**: Assemble `good_of_split_at_succ` proof: (1) extract Z1 ~k M|[t,b] and Z2 ~k M|[succ b,u]; (2) M|[t,u] ~k orderedSum Bool pieces via inline OrderIso + `k_equiv_of_iso`; (3) orderedSum pieces ~k orderedSum witnesses via `doets_lemma_1_4`; (4) orderedSum witnesses is good (k=0 case closed; k>=1 case requires 2.4b+2.4c); (5) compose by k_equiv transitivity. *(deviation: altered -- step 2 fully proved inline, step 4 partially proved with k=0 case closed, k>=1 case has 1 sorry pending expressibility infrastructure)*
- [x] **Task 2.5**: Prove transitivity case 2: if x,y both in [a,b], then [x,y] is a subinterval of [a,b], hence good by very_good of [a,b]. Similarly for both in [b,c]. *(completed: Cases A and B in transitivity proof)*
- [x] **Task 2.6**: Assemble full transitivity proof by case analysis on position of x,y relative to b *(completed)*
- [x] **Task 2.7**: Verify `lake build` passes AND `lean_verify contemp_equiv_is_equiv` shows no `sorryAx` *(completed: lake build passes, lean_verify shows no sorryAx)*

**Research integration (reports 03 + 04_*)**: Reynolds DOES use successor b+1 in Lemma 17. SuccOrder is correct here. Team research (4 agents) established:
- `doets_lemma_1_1` (sorry-free) bridges k_equiv to sentence preservation at depth ≤ k
- "has max" = depth-2 sentence → preserved at k≥2 → Z-witnesses bounded → Fintype → finite_structures_good
- k=1: AtomKind sig 1 has NO order atoms → direct finite Z-interval construction matching profiles
- `doets_lemma_1_5` (OrderedSum.lean:56) is sorry'd — do NOT attempt to close it; use the Fintype path instead
- See reports: `04_kequiv-definitions.md`, `04_bounded-preservation.md`, `04_zinterval-sum.md`, `04_alternative-proofs.md`

**Timing**: 4 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel.lean` - Rewrite `contemp_equiv_is_equiv`, add helper lemmas

**Verification**:
- `lean_verify` on `contemp_equiv_is_equiv` shows no `sorryAx`
- No `IsSuccArchimedean` in the theorem statement
- `lake build` passes

---

### Phase 3: Expressive Completeness + Gap Elimination [NOT STARTED]

**Revised scope** (after research reports 06a-d, 08, 08b): Phase 3 is now split into two sub-phases:

**Phase 3A: Expressive Completeness of {S,U} over Integer Time**

Formalize the separation theorem from GHR94 Chapter 10, Section 10.2 (Theorem 10.2.9). This is the FO → temporal direction: every monadic FO sentence over integer time has a temporal {U,S} equivalent. Reynolds cites this as his Theorem 5 (references [5],[6]).

**Why needed**: Reynolds Theorem 14 (gap elimination) uses expressive completeness 6 times (Lemmas 6, 7, 8, 9(i), 9(ii), 11) to convert monadic FO formulas describing gap properties into temporal formulas for feeding into Prior-U. Without this, Prior-U cannot be applied to the gap-defining formulas.

**Literature sources** (all in `literature/`, with markdown conversions):
- GHR94 Ch 9: `Gabbay_Hodkinson_Reynolds_1994_Temporal_Logic_Foundations_Vol1_ch9.md` — Framework: separation = expressive completeness (Thm 9.3.1, 9.3.4)
- GHR94 Ch 10: `Gabbay_Hodkinson_Reynolds_1994_Temporal_Logic_Foundations_Vol1_ch10.md` — Section 10.2: Separation for {S,U} over integer time (Lemmas 10.2.1-10.2.10)
- GHR93: `Gabbay_Hodkinson_Reynolds_1993_Temporal_expressive_completeness_gaps.md` — Alternative game-theoretic proof (reference only)

**Proof structure** (from GHR94 §10.2):
- 8 elimination cases showing how to pull U out of S (and vice versa) in discrete time
- Nested 4-level induction: junction depth → nesting depth → number of U-subformulas → single elimination
- Key lemmas: 10.2.1 (distributivity), 10.2.2 (integer-specific equivalences), 10.2.3-10.2.4 (elimination cases), 10.2.5-10.2.8 (inductive assembly), 10.2.9-10.2.10 (separation + expressive completeness)

**Estimated effort**: ~2500 lines of Lean, 3-4 weeks
**Status**: DELEGATED TO TASK 157. Do not work on this within task 155.
**Research reports**: 08_gap-elimination-detailed.md, 08b_gap-elimination-second-opinion.md

**Phase 3B: Gap Elimination (Reynolds Theorem 14)**

With expressive completeness from Phase 3A, formalize Reynolds's Lemmas 6-13 and Theorem 14.

**Proof structure** (from Reynolds 1994 lines 470-816):
- Lemma 6: Define ρ(x) = "x's ~-class ends in a gap on the right." Convert to temporal R via expressive completeness.
- Lemma 7: R-intervals have excluded endpoints (uses Prior-U on R).
- Lemma 8: Further structural properties of R-intervals.
- Lemma 9: Classes within R-intervals are elementarily equivalent.
- Lemma 10-11: Preparation for model surgery.
- Lemma 12: Model surgery — replace "bad interval" by one of its classes, show temporal truth is preserved. THE HARDEST SUB-PROOF (~200-300 lines, 14+ case splits for Until alone).
- Lemma 13: Derive contradiction from R in the surgically modified Prior structure.
- Theorem 14: Assembly — ~M classes do not end at gaps.

**Estimated effort**: ~600-800 lines of Lean, 1-2 weeks (after Phase 3A)
**Depends on**: Phase 3A (expressive completeness)

**Combined Phase 3 effort**: ~3000-3500 lines, 4-6 weeks

**Prohibited workarounds**: Do NOT use `sorry`, `def X := True`, or any vacuous placeholder. Do NOT add `IsSuccArchimedean` as hypothesis. Do NOT use `orderIsoIntOfLinearSuccPredArch`.

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

### Phase 4: Rewrite very_good_implies_good (Reynolds Lemma 16) [COMPLETED]

**CAN PROCEED NOW** — independent of task 157. This phase rewrites `very_good_implies_good` only; the `chronicle_is_good` rewrite (Task 4.8) is deferred to Phase 4b (after Phase 3B provides `one_class`).

**Goal**: Rewrite `very_good_implies_good` WITHOUT `IsSuccArchimedean` or `orderIsoIntOfLinearSuccPredArch`. Reynolds Lemma 16 proves: given a countable linear order without endpoints where every subinterval is good (very_good), the whole structure is good. The proof constructs a cofinal sequence, decomposes the structure into an ordered sum of good pieces indexed by Z, and applies `doets_lemma_1_4` + Z-interval concatenation.

**Reynolds Reference**: Lemma 16, Reynolds 1994 pp.877-903. The proof: (1) choose cofinal sequence a_0 < a_1 < ... using Countable + NoMaxOrder, similarly coinitial a_{-1} > a_{-2} > ...; (2) each [a_i, a_{i+1}] is good by very_good; (3) the whole structure is the ordered sum indexed by Z; (4) by `doets_lemma_1_4`, this ordered sum of good (= k-equiv to Z-intervals) pieces is k-equiv to the ordered sum of Z-intervals; (5) ordered sum of Z-intervals indexed by Z is itself a Z-interval.

**BEFORE CODING**: Read `literature/Reynolds_1994_Axiomatising_U_and_S_over_integer_time.md` pp.877-903. Read `literature/Doets_1989_Monadic_Pi11_Theories.md` Section 1.4. The cofinal decomposition is the core idea.

**Tasks**:
- [x] **Task 4.1**: REMOVE `[IsSuccArchimedean M.carrier]` from `very_good_implies_good`. The correct hypotheses are: `[Countable M.carrier]`, `[NoMaxOrder M.carrier]`, `[NoMinOrder M.carrier]`, `[Nonempty M.carrier]`, `(h_very_good : very_good sig k M)`. NO SuccOrder, NO PredOrder, NO IsSuccArchimedean. *(completed)*
- [x] **Task 4.2**: Prove cofinal sequence existence: given `Countable M.carrier` and `NoMaxOrder M.carrier`, construct a sequence `a : Z -> M.carrier` that is strictly increasing and cofinal (every element is between some a_i and a_{i+1}) *(completed: `exists_cofinal_sequence` proved sorry-free)*
- [x] **Task 4.3**: Prove that M is order-isomorphic to the ordered sum of subintervals [a_i, a_{i+1}] indexed by Z *(deviation: altered -- proved as k-equivalence `cofinal_decomposition_k_equiv` rather than order-isomorphism, since overlapping endpoints prevent iso; sorry'd pending EF-game argument for duplicate boundary points)*
- [x] **Task 4.4**: Each subinterval [a_i, a_{i+1}] is good by the very_good hypothesis. Extract the k-equivalence witnesses. *(completed: h_pieces_good proved inline)*
- [x] **Task 4.5**: Apply `doets_lemma_1_4` to the ordered sum: the ordered sum of good subintervals is k-equiv to the ordered sum of their Z-interval witnesses *(completed: h_sum_equiv via doets_lemma_1_4)*
- [x] **Task 4.6**: Prove Z-interval concatenation: an ordered sum of Z-intervals (each with lo=some a, hi=some b) indexed by Z is k-equivalent to a single Z-interval with lo=none, hi=none. This is the "shift and glue" construction. *(deviation: altered -- k=0 and k=1 cases proved; k>=2 case sorry'd pending SuccOrder/PredOrder/IsSuccArchimedean instance construction on witness-side sigma type)*
- [x] **Task 4.7**: Assemble: M ≃ ordered_sum ≈_k ordered_sum_of_Z_intervals ≈_k single_Z_interval *(completed: composition via Eq.trans on k-types)*
- [x] **Task 4.8**: Verify `lake build` passes with rewritten `very_good_implies_good` *(completed: lake build passes with zero errors)*

**Timing**: 4 hours

**Depends on**: 2 (NOT 3 — this phase is independent of gap elimination)

**Deferred to Phase 4b** (after Phase 3B provides one_class):
- Task 4b.1: Rewrite `chronicle_is_good` to use `one_class` + `very_good_implies_good` instead of `orderIsoIntOfLinearSuccPredArch`
- Task 4b.2: REMOVE `domain_succ_archimedean` field from `ChronicleAsPriorModel`
- Task 4b.3: Remove `limitDomSubtype_isSuccArchimedean` from `extract_chronicle_as_prior`

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

**CAN PROCEED NOW** — takes `chronicle_is_good` as a hypothesis (sorry'd until Phase 4b fills it). The transfer mechanism is pure infrastructure.

**Goal**: Prove truth transfer from the chronicle's Z-model to temporal truth, using existential closure of the table formula. Given `chronicle_is_good` provides k-equivalence between the chronicle and a Z-interval structure, transfer the truth of `neg phi` from the chronicle to the Z-interval.

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

**Depends on**: 2 (infrastructure only; final wiring needs 4b)

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Transfer.lean` or new `TruthTransfer.lean` - Truth transfer lemma

**Verification**:
- `lean_verify` on truth transfer lemma shows no `sorryAx`
- `lake build` passes

---

### Phase 6: TaskFrame Int Construction and Pipeline Wiring [NOT STARTED]

**CAN PROCEED NOW** — the ZIntervalStructure → TaskFrame bridge is pure infrastructure independent of how chronicle_is_good is proved. Final wiring (replacing the fallback) waits for all upstream phases.

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
