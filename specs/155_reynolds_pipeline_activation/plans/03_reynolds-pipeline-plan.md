# Implementation Plan: Reynolds Pipeline Activation (v4)

- **Task**: 155 - reynolds_pipeline_activation
- **Status**: [NOT STARTED]
- **Effort**: 28 hours
- **Dependencies**: Task 154 (sum_preservation/doets_lemma_1_4, COMPLETED), Tasks 147-148 (table_correctness, COMPLETED), Task 157 (separation/expressive completeness, COMPLETED)
- **Research Inputs**: specs/155_reynolds_pipeline_activation/reports/03_team-research.md
- **Artifacts**: plans/03_reynolds-pipeline-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

---

## CRITICAL DIRECTIVE: NO DEVIATION FROM REYNOLDS 1994

**DO NOT deviate from the published proof structure without outstandingly good reason.**

The first implementation attempt deviated from Reynolds 1994 by adding `[IsSuccArchimedean M.carrier]` as a hypothesis and using `orderIsoIntOfLinearSuccPredArch` to shortcut proofs. This approach created a circular dependency through `succ_cofinal` (task 129 sorry) and **failed completely**.

Agents MUST:
1. **READ the literature files** before attempting each phase
2. **Follow the paper step-by-step**
3. **NEVER add `IsSuccArchimedean` as a hypothesis** -- Reynolds does not use it
4. **NEVER use `orderIsoIntOfLinearSuccPredArch`** -- this is the shortcut that caused the failure
5. **If stuck, re-read the literature** -- the answer is in the paper

---

## Overview

This plan (v4) addresses the 7 remaining sorry sites blocking sorry-free `bx_completeness`. Four teammates independently verified the sorry chain in Round 3 research, converging on a clear picture: there are TWO independent sorry channels (Channel A: `succ_cofinal` via `extract_chronicle_as_prior`; Channel B: 4 Transfer.lean explicit sorries), and the Reynolds Lemma 16 bypass is the only viable path since `succ_cofinal` is mathematically unprovable from existing axioms (Z+Z gap scenario). The plan reorders phases based on research findings: start with the independent, highest-value work (chronicle truth lemma, trivial Nonempty sorry), then tackle the z_interval_countermodel bridge (with the corrected understanding that the box case requires an `h_box_correct` hypothesis), then the hard gap elimination (Reynolds Theorem 14), then IntegerModel sorries, and finally the chronicle_is_good rewrite. Definition of done: `#print axioms bx_completeness` shows no `sorryAx`, `lake build` passes.

### Research Integration

Integrated from `reports/03_team-research.md` (4-teammate synthesis):
- `chronicle_is_good` is already sorry-free (verified by all 4 teammates). The sorry propagates through `extract_chronicle_as_prior`, not through `chronicle_is_good` itself.
- The box modality mismatch in Phase 1 is real but solvable: WorldState = Z with `states t _ = t` makes all histories agree on atom truth. The box case requires an explicit `h_box_correct` hypothesis that IS satisfiable by the chronicle's Z-interval.
- `succ_cofinal` is mathematically unprovable (Z+Z gap scenario consistent with all axioms). Reynolds Lemma 16 bypass is the only viable path.
- `cofinal_decomposition_k_equiv` does NOT need a full EF framework -- normal-form evaluation preservation (~80-120 lines) suffices.
- Phase execution order should change: start with chronicle_temporal_truth (independent, medium, highest-value), then Nonempty sig.preds (trivial).
- Realistic effort is 24-38h (prior plan's 18h was optimistic). This plan budgets 28h as the median.
- Untracked sorry at OrderedSum.lean:56 (`doets_lemma_1_5`) needs critical-path verification in pre-flight.
- NEquivalence.lean cascade risk: removing `domain_succ_archimedean` may break an instance at line ~1215.

### Prior Plan Reference

The v3 plan (02_reynolds-pipeline-plan.md) had the correct architecture but several issues identified by the team research: (1) Phase ordering was suboptimal -- Phase 4 should execute first, not in parallel with Phases 1-2; (2) Task 1.5 "box trivial" claim was wrong -- the box case requires careful treatment, not a trivial single-S5-class argument; (3) Phase 2 is only needed conditionally after Phase 3 commits to the Lemma 16 path; (4) 18h estimate was optimistic -- 24-38h is realistic. The BLOCKER annotations on Phases 1 and 2 were accurate and informed the corrected approach in this plan. Key validated insight: the NF-evaluation approach for `cofinal_decomposition_k_equiv` (from Teammate A) is viable and avoids the full EF framework.

### Roadmap Alignment

- Advances "sorry-free `bx_completeness`" (primary critical path item)
- Eliminates circular dependency through `succ_cofinal` (task 129)
- Closes the discrete completeness branch of the Reynolds pipeline
- Unblocks downstream: dead code cleanup (21, 130, 173), module reorganization (131, 161), frame extensions (169, 170), algebraic representation (125), publication quality (95, 8)

## Goals & Non-Goals

**Goals**:
- Close all 4 critical-path sorry sites in Transfer.lean (chronicle_temporal_truth, z_interval_countermodel, Nonempty sig.preds, inline h_chronicle_truth)
- Close 2 IntegerModel.lean helper sorries (cofinal_decomposition_k_equiv, ordered_sum_of_good_bounded_is_good)
- REMOVE `[IsSuccArchimedean M.carrier]` from `no_gaps_discrete` and `one_class`
- REWRITE `no_gaps_discrete` following Reynolds Theorem 14 (gap elimination)
- REWRITE `chronicle_is_good` to NOT use `orderIsoIntOfLinearSuccPredArch`
- Fix the valuation bug in `z_interval_countermodel` (WorldState must be Int, not Unit)
- Add `h_box_correct` hypothesis to `z_interval_countermodel` for box case correspondence
- Achieve `#print axioms bx_completeness` with no `sorryAx`

**Non-Goals**:
- Dense completeness (separate path, unaffected)
- Closing `succ_cofinal` (task 129) -- we bypass it entirely
- Frame-class completeness variants (Completeness.lean:254,279,288)
- Optimizing existing sorry-free infrastructure
- `countermodel_discrete_enriched` (Completeness.lean:225, separate wrapper)
- Building a full EF-game framework (NF-evaluation approach instead)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Gap elimination (Reynolds Theorem 14) is genuinely hard (~6 pages, 9 sub-lemmas) | H | H | Budget 8 hours; break into sub-lemmas (Lemmas 6-13); use sorry-free `table_correctness` + `separation_theorem_int`; read Reynolds 1994 Section 7 IN FULL before coding |
| Box case in z_interval_countermodel harder than expected with h_box_correct | M | M | Use WorldState = Z with `states t _ = t` so all histories agree; add explicit `h_box_correct` hypothesis; discharge at call site using chronicle's S5 MCS properties |
| OrderedSum.lean:56 sorry (`doets_lemma_1_5`) may be on critical path | M | L | Verify in Phase 0 pre-flight; if on critical path, add to Phase 4 scope |
| NEquivalence.lean cascade when removing domain_succ_archimedean | M | M | Check NEquivalence.lean:1215 instance before Phase 6; `chronicleAsMonadicStructure_succ_archimedean` is already sorry-free (verified by Teammate B) so it may provide an independent instance |
| `cofinal_decomposition_k_equiv` NF-evaluation approach hits unforeseen boundary-point complexity | M | M | Attempt NF preservation (~80-120 lines); fall back to showing embedding preserves all quantifier-depth-k formulas directly |
| Until/Since cases in chronicle_temporal_truth require deep chronicle resolution lemma extraction | M | M | Prior-UZ/SZ validity is an explicit field in ChronicleAsPriorModel; use limit_F_resolution and limit_P_resolution from ChronicleToCountermodel |
| Phase 4 (gap elimination) takes 2-3x estimated time | H | M | Mark [PARTIAL] and write handoff if stuck after 8 hours; document which sub-lemmas are proved and which are stuck |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2, 3, 4 | -- |
| 2 | 5 | 4 |
| 3 | 6 | 1, 2, 3, 4, 5 |
| 4 | 7 | 6 |

Phases 1, 2, 3, and 4 can execute in parallel (Wave 1) -- they have no hard code dependencies between them. Phase 5 requires Phase 4 (Lemma 16 path is only meaningful once Phase 4 commits to gap elimination). Phase 6 requires Phases 1, 2, 4, 5 (assembly of all upstream results). Phase 7 is final verification. **Recommended execution order within Wave 1**: Phase 2 (trivial, instant win) -> Phase 1 (independent, high value) -> Phase 3 (medium, architectural) -> Phase 4 (hardest, most time).

---

### Phase 1: Chronicle Truth Lemma [COMPLETED]

**Goal**: Close the `chronicle_temporal_truth` sorry (Transfer.lean:186) and the inline sorry at Transfer.lean:371. This is the highest-value independent work item: it connects MCS membership in the chronicle to `temporal_truth` on the chronicle-as-monadic-structure.

**BEFORE CODING**: Read the `chronicle_temporal_truth` signature and understand the `chronicleAsMonadicStructure` definition. The key property: `M_chron.interp p t = (atomMap_rev p) \in M.fmcs t`, combined with `h_section : atomMap_rev (atomMap_fwd f) = f` for relevant formulas f.

**Tasks**:
- [x] **Task 1.1**: Prove `chronicle_temporal_truth` by structural induction on formula psi. Cases:
  - **Atom**: `temporal_truth M_chron atomMap_fwd t (atom a)` = `M_chron.interp (atomMap_fwd (atom a)) t` = `(atomMap_rev (atomMap_fwd (atom a))) \in M.fmcs t` = `(atom a) \in M.fmcs t` via section property `h_section`.
  - **Bot**: `temporal_truth` for bot is False; bot is never in a consistent MCS.
  - **Imp**: Standard MCS properties (implication closure, maximality, deduction).
  - **Box**: `temporal_truth M_chron atomMap_fwd t (box psi)` = `M_chron.interp (atomMap_fwd (box psi)) t` = `(box psi) \in M.fmcs t` via section property. This case is clean because `temporal_truth` for box IS a predicate lookup (not universal quantification) -- the section property directly applies.
  - **Until**: Use Prior-UZ validity (`M.prior_UZ_valid`). If `Until(psi1, psi2) \in fmcs t`, extract witness s > t with `psi2 \in fmcs s` and guard at intermediates. If `temporal_truth ... Until(psi1, psi2)`, use the existence of the future witness to show membership.
  - **Since**: Symmetric to Until, using Prior-SZ validity (`M.prior_SZ_valid`).
  *(deviation: altered -- the proof already existed but had bugs: imp case needed `.symm` on `imp_iff_mcs`, and Until/Since cases had `.mp`/`.mpr` directions swapped after `simp only [temporal_truth]` unfolding. Fixed all three issues.)*
- [x] **Task 1.2**: Wire `chronicle_temporal_truth` into `countermodel_discrete` at Transfer.lean:470-475, replacing the inline sorry for `h_chronicle_truth`. *(completed -- used section property on phi.neg.predFormulas = phi.predFormulas, then applied chronicle_temporal_truth.mpr with root_point_mcs + h_neg_in)*
- [x] **Task 1.3**: Verify `lake build` passes. *(completed -- build successful with 1644 jobs, no errors)*

**Timing**: 4 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Transfer.lean` -- prove chronicle_temporal_truth, wire into countermodel_discrete

**Verification**:
- `lean_verify` on `chronicle_temporal_truth` shows no `sorryAx`
- Sorry at Transfer.lean:371 is closed
- `lake build` passes

---

### Phase 2: Fix Nonempty sig.preds [NOT STARTED]

**Goal**: Close the trivial `Nonempty sig.preds` sorry at Transfer.lean:332. This is the easiest win.

**Tasks**:
- [ ] **Task 2.1**: Fix `Nonempty sig.preds` (Transfer.lean:332). Case-split on whether `phi.predFormulas` is empty. If empty, phi is purely propositional (only `bot`/`imp`) and a simpler propositional countermodel suffices (or the predicate machinery is vacuously satisfied). If nonempty, `Nonempty sig.preds` is immediate from the nonemptiness of `predFormulas`.
- [ ] **Task 2.2**: Verify `lake build` passes.

**Timing**: 1 hour

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Transfer.lean` -- close Nonempty sorry

**Verification**:
- Sorry at Transfer.lean:332 is closed
- `lake build` passes

---

### Phase 3: Fix z_interval_countermodel Architecture and Bridge [NOT STARTED]

**Goal**: Fix the valuation bug in `z_interval_countermodel` by refactoring `zIntervalTaskFrame` to use `WorldState = Int`. Add `h_box_correct` hypothesis for the box case. Prove the inductive truth correspondence.

**BEFORE CODING**: Read Teammate A's analysis of the box case mismatch (Finding 3 of team research). The key insight: with `WorldState = Z` and `states t _ = t`, ALL histories return state `t` at time `t`, so `truth_at` for atoms becomes independent of history choice. The box case still requires the explicit `h_box_correct` hypothesis because `temporal_truth (.box psi)` is a predicate lookup while `truth_at (.box psi)` is universal quantification.

**Tasks**:
- [ ] **Task 3.1**: Refactor `zIntervalTaskFrame` to use `WorldState = Int` instead of `WorldState = Unit`. The new frame: `task_rel w1 w2 delta := w2 = w1 + delta`. Prove the TaskFrame axioms (nullity_identity, additivity, etc.) for this construction.
- [ ] **Task 3.2**: Update `zIntervalHistory` for the new frame: `states t h_dom := t` (the world state at time t is the integer t itself). Domain is all of Z (`domain := fun _ => True`).
- [ ] **Task 3.3**: Fix the valuation in `z_interval_countermodel`: change from `fun _ a => Z.interp (atomMap_fwd (.atom a)) s.val` to `fun (z : Z) a => Z.interp (atomMap_fwd (.atom a)) z` (valuation depends on the WorldState integer, not the fixed witness).
- [ ] **Task 3.4**: Verify `zIntervalOmega_shiftClosed` still holds with the new WorldState = Z construction.
- [ ] **Task 3.5**: Add `h_box_correct` hypothesis to `z_interval_countermodel`: `h_box_correct : forall (psi : Formula) (s : Z.intervalCarrier), Z.interp (atomMap_fwd (.box psi)) s.val <-> temporal_truth Z atomMap_fwd s psi`. This hypothesis IS satisfiable by the specific Z-interval from `chronicle_is_good` (where `.box psi` predicates encode MCS membership, matching box truth via S5 single-class property).
- [ ] **Task 3.6**: Prove the truth correspondence by structural induction on phi:
  - **Atom**: `truth_at TM Omega tau t (atom a) = TM.valuation (tau.states t ht) a = Z.interp (atomMap_fwd (.atom a)) t` since `states t _ = t`. Matches `temporal_truth` atom case.
  - **Bot**: Both false.
  - **Imp**: Both material conditional, by IH.
  - **Box**: Use `h_box_correct` to bridge predicate lookup to universal quantification. With `states t _ = t`, all histories agree on atom truth at time t, so `truth_at TM Set.univ sigma t psi = truth_at TM Set.univ tau t psi` for all sigma, tau (by induction on psi). Thus `forall sigma in Set.univ, truth_at ... sigma t psi` reduces to `truth_at ... tau t psi`, which by IH corresponds to `temporal_truth ... psi`. The `h_box_correct` hypothesis then gives the predicate correspondence.
  - **Until/Since**: Z order on integers matches temporal order. By IH, truth correspondence propagates through witnesses.
- [ ] **Task 3.7**: Also fix the same pattern in `countermodel_discrete` at Transfer.lean:275-276 (the inline TM construction has the same bug).
- [ ] **Task 3.8**: (Deferred to Phase 6) At the call site in `countermodel_discrete`, discharge `h_box_correct` using the chronicle's MCS properties. This task requires `chronicle_temporal_truth` from Phase 1 and is therefore handled during Phase 6 wiring.
- [ ] **Task 3.9**: Verify `lake build` passes (z_interval_countermodel may still have sorry at call site for h_box_correct discharge -- this is expected and resolved in Phase 6).

**Timing**: 4 hours

**Depends on**: none (the h_box_correct discharge at the call site is deferred to Phase 6)

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Transfer.lean` -- refactor zIntervalTaskFrame, zIntervalHistory, z_interval_countermodel, fix inline construction

**Verification**:
- `lean_verify` on `z_interval_countermodel` shows no `sorryAx`
- `lake build` passes

---

### Phase 4: Gap Elimination (Reynolds Theorem 14) [BLOCKED]

**BLOCKER** (Phase 4):
- **What failed**: Tasks 4.2-4.6 (Reynolds Lemmas 6-13, `no_gaps_discrete` proof) cannot be completed yet.
- **What was tried**: (1) Full analysis of Reynolds Theorem 14 proof structure. (2) Investigation of available infrastructure (`US_expressively_complete_over_Z`, `table_correctness`, `contemp_equiv_is_equiv`, `no_boundary_at_successor`). (3) Direct proof attempt bypassing expressive completeness: construct temporal formula distinguishing two sides of a gap, apply Prior-UZ to derive contradiction. The direct approach works IF such a temporal formula exists, but its existence IS the expressive completeness question. (4) Analysis of whether K_plus_bot (K+ = false in discrete orders) suffices: K+ IS always false in discrete orders with SuccOrder (proof: U(top, not q) holds with witness s = succ(t), empty guard). This would imply U'(A,B) equiv bot in discrete Prior structures, which is step 1 of Reynolds Theorem 5. However, completing Theorem 5 also requires Theorem 4 (GHR94: {U,S,U',S'} expressiveness over all linear structures), which is NOT formalized (Stavi connectives not present in codebase).
- **Why it's stuck**: Reynolds Theorem 14 proof chain: Theorem 4 ({U,S,U',S'} over linear) -> Theorem 5 ({U,S} over Prior, via U' equiv bot) -> Theorem 14 (no gaps, via R formula). The codebase has `US_expressively_complete_over_Z` (carrier = Z) but NOT Theorem 4 or Theorem 5 for general Prior structures. The gap between "expressiveness over Z" and "expressiveness over arbitrary discrete Prior structures" cannot be bridged without one of: (a) formalizing Theorem 4 + Theorem 5, or (b) proving a direct transfer lemma from Z-expressiveness to Prior-expressiveness, or (c) finding an entirely different proof of no_gaps_discrete that avoids expressive completeness.
- **What was achieved**: Task 4.1 confirmed done (no IsSuccArchimedean in `no_gaps_discrete`). Task 4.7 COMPLETED: `one_class` rewritten to use `no_gaps_discrete` + `no_boundary_at_successor` + `contemp_equiv_is_equiv`, removing `IsSuccArchimedean` from `one_class` signature. Build passes. `contemp_equiv_is_equiv` and `no_boundary_at_successor` are sorry-free.
- **What is needed**: One of three paths to unblock:
  - **Path A** (Reynolds faithful): Formalize Stavi connectives U'/S', prove Theorem 4 ({U,S,U',S'} expressiveness over all linear structures), then Theorem 5 ({U,S} over Prior via U' equiv bot). Estimated: 300-500 lines, requires defining U'/S' semantics and proving GHR94 Theorem.
  - **Path B** (Transfer shortcut): Prove that `US_expressively_complete_over_Z` transfers to arbitrary discrete Prior structures via an embedding argument. Each discrete Prior structure embeds locally into Z (each class is Z-like), so Z-expressiveness may suffice. Estimated: 100-200 lines but mathematically non-trivial.
  - **Path C** (Direct gap elimination): Prove no_gaps_discrete by a direct combinatorial argument on k-types and the Prior-UZ hypothesis, avoiding expressive completeness entirely. The argument: if a gap exists, the k-type difference across the gap generates a distinguishing predicate at SOME depth, and Prior-UZ applied to the corresponding formula yields contradiction. Estimated: 150-300 lines, requires new lemma connecting k-type differences to temporal formula existence.
- **Prohibited workarounds**: Do NOT add IsSuccArchimedean back to `no_gaps_discrete` or `one_class`. Do NOT use `orderIsoIntOfLinearSuccPredArch` as a shortcut.

**Goal**: Rewrite `no_gaps_discrete` WITHOUT `IsSuccArchimedean`, following Reynolds 1994 Section 7 (Lemmas 6-13, Theorem 14). Then rewrite `one_class` to use the genuine `no_gaps_discrete` + `no_boundary_at_successor` argument.

**BEFORE CODING**: Read `literature/Reynolds_1994_Axiomatising_U_and_S_over_integer_time.md` Section 7 (Lemmas 6-13, Theorem 14) IN FULL. These proofs are 6 pages of dense argument. Budget time accordingly. Also read the existing `no_gaps_discrete` and `one_class` implementations to understand what structure can be preserved.

**Reynolds Reference**: Theorem 14 proves that ~M classes cannot end at gaps in Prior structures. The argument: define rho(x) = "x's ~-class ends in a gap on the right", convert rho to temporal formula R via expressive completeness (`table_correctness` + `separation_theorem_int`), use Prior-UZ on R to derive contradiction. Key sub-lemmas establish structural properties of R-intervals.

**Tasks**:
- [x] **Task 4.1**: REMOVE `[IsSuccArchimedean M.carrier]` from `no_gaps_discrete` signature. Replace with hypotheses providing Prior-UZ/SZ validity and the necessary order structure (`SuccOrder`, `PredOrder`, `NoMaxOrder`, `NoMinOrder`, `Countable`). *(deviation: altered — IsSuccArchimedean was already removed in prior work; signature with Prior-UZ/SZ hypotheses confirmed in place)*
- [ ] **Task 4.2**: Formalize Reynolds Lemma 6: define rho(a) = "there exists b > a such that a ~M b but not a ~M (succ b)" (the class of a has a gap on the right). Express this as a monadic FO formula and convert to temporal formula R via `table_correctness`. *(deviation: deferred — blocked by Reynolds Theorem 5, see BLOCKER below)*
- [ ] **Task 4.3**: Formalize Reynolds Lemmas 7-8: structural properties of R-intervals. R-intervals have excluded upper endpoints. Every point in an R-interval has the same ~M-class behavior. *(deviation: deferred — blocked by Task 4.2)*
- [ ] **Task 4.4**: Formalize Reynolds Lemma 9: ~M classes within R-intervals are elementarily equivalent. This uses `table_correctness` to express class membership as a temporal property. *(deviation: deferred — blocked by Task 4.2)*
- [ ] **Task 4.5**: Formalize Reynolds Lemmas 10-13: the model surgery argument. Replace a "bad interval" by one of its classes. Show temporal truth is preserved. This is THE HARDEST sub-proof. Derive contradiction from Prior-UZ validity on R. *(deviation: deferred — blocked by Task 4.2)*
- [ ] **Task 4.6**: Assemble `no_gaps_discrete` from Lemmas 6-13: ~M classes do not end at gaps. The proof by contradiction: assume a gap exists, construct R, apply Prior-UZ, get contradiction. *(deviation: deferred — blocked, `no_gaps_discrete` remains sorry'd)*
- [x] **Task 4.7**: Rewrite `one_class` to use the genuine two-step argument: (a) `no_boundary_at_successor` (sorry-free) gives c ~M succ(c) for all c, (b) `no_gaps_discrete` (from Task 4.6) means classes don't end at gaps. Together: ~M classes span the entire order, so there is exactly one class. *(completed — `IsSuccArchimedean` removed; `one_class` now calls `no_gaps_discrete` + `no_boundary_at_successor` + `contemp_equiv_is_equiv`)*
- [x] **Task 4.8**: Verify `lake build` passes and `lean_verify one_class` shows no `sorryAx`. *(deviation: altered — build passes; one_class inherits sorryAx from no_gaps_discrete which is expected)*

**Timing**: 8 hours

**Depends on**: none (uses sorry-free `table_correctness` and `separation_theorem_int` infrastructure)

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel.lean` -- rewrite `no_gaps_discrete`, `one_class`, add gap elimination machinery (Lemmas 6-13)

**Verification**:
- `lean_verify` on `no_gaps_discrete` shows no `sorryAx`
- `lean_verify` on `one_class` shows no `sorryAx`
- No `IsSuccArchimedean` in `no_gaps_discrete` or `one_class` theorem statements
- `lake build` passes

---

### Phase 5: IntegerModel.lean Helper Sorries (Reynolds Lemma 16) [NOT STARTED]

**Goal**: Close the 2 non-critical-path sorries in IntegerModel.lean needed for `very_good_implies_good`: `cofinal_decomposition_k_equiv` (line 1079) and `ordered_sum_of_good_bounded_is_good` (line 1138, k>=2 case).

**BEFORE CODING**: Read Teammate A's analysis of the NF-evaluation approach for `cofinal_decomposition_k_equiv` (Finding 4 of team research). The key insight: this does NOT require a full EF framework -- normal-form evaluation preservation (~80-120 lines) suffices using existing `nf_eval_nf` infrastructure. Also verify `OrderedSum.lean:56` (`doets_lemma_1_5`) critical-path status.

**Tasks**:
- [ ] **Task 5.0 (Pre-flight)**: Run `lean_verify doets_lemma_1_5` to check if OrderedSum.lean:56 sorry is on the critical path to `very_good_implies_good`. If it is, add closing this sorry to the phase scope.
- [ ] **Task 5.1**: Prove `cofinal_decomposition_k_equiv` (IntegerModel.lean:1079). Use the NF-evaluation preservation approach: construct an explicit embedding M -> orderedSum (send x to its canonical copy in the leftmost containing piece) and prove `nf_eval_nf M env nf = nf_eval_nf (orderedSum) (sigma . env) nf` by induction on nf. The key property: duplicated boundary points satisfy identical predicates, so the embedding preserves all NF evaluations. The existential/universal quantifier cases need careful treatment of boundary duplicates -- any witness in the ordered sum can be projected to a witness in M, and any witness in M can be lifted to its canonical copy.
- [ ] **Task 5.2**: Prove `ordered_sum_of_good_bounded_is_good` for k>=2 (IntegerModel.lean:1138). Steps: (a) transfer "has max/min" from ms(i) to Z_i via `doets_lemma_1_1` at depth 2, (b) Z_i bounded means `Z_i.lo = some _` and `Z_i.hi = some _`, (c) construct `SuccOrder` and `PredOrder` on the sigma type `Sigma (i : Z), Z_i.intervalCarrier`, (d) prove `IsSuccArchimedean` for the sigma type (safe here -- each piece is a finite bounded Z-interval, so successor iteration reaches boundary in finitely many steps), (e) apply `orderIsoIntOfLinearSuccPredArch` on the witness side (safe -- this is on the explicitly Z-like concatenated witness, NOT on M.domain), (f) apply `k_equiv_of_iso`.
- [ ] **Task 5.3**: For Task 5.2, construct the shift-and-glue OrderIso: define `shift : Z -> Z` as cumulative offset function mapping the i-th Z-interval's elements to a contiguous segment of Z. Prove: strictly monotone, surjective, preserves predicates.
- [ ] **Task 5.4**: Verify `lean_verify very_good_implies_good` shows no `sorryAx`.

**Timing**: 5 hours

**Depends on**: 4 (Phase 4 proves `one_class` without IsSuccArchimedean, which enables the `very_good` property needed for `very_good_implies_good` to be meaningful. Phase 5 is only valuable once Phase 4 commits to the Lemma 16 path.)

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel.lean` -- close cofinal_decomposition_k_equiv and ordered_sum_of_good_bounded_is_good
- `Theories/Bimodal/Metalogic/WeakCanonical/OrderedSum.lean` -- potentially close doets_lemma_1_5 if on critical path

**Verification**:
- `lean_verify` on `cofinal_decomposition_k_equiv` shows no `sorryAx`
- `lean_verify` on `ordered_sum_of_good_bounded_is_good` shows no `sorryAx`
- `lean_verify` on `very_good_implies_good` shows no `sorryAx`
- `lake build` passes

---

### Phase 6: Rewrite chronicle_is_good and Remove IsSuccArchimedean [NOT STARTED]

**Goal**: Rewrite `chronicle_is_good` to use `one_class` + `very_good_implies_good` instead of `orderIsoIntOfLinearSuccPredArch`. Remove `domain_succ_archimedean` from `ChronicleAsPriorModel`. Remove `orderIsoIntOfLinearSuccPredArch` from `countermodel_discrete`.

**BEFORE CODING**: Check NEquivalence.lean:1215 for cascade risk. Teammate B verified `chronicleAsMonadicStructure_succ_archimedean` is sorry-free -- if this provides an independent IsSuccArchimedean instance for NEquivalence code paths, the removal is safe.

**Tasks**:
- [ ] **Task 6.1**: Rewrite `chronicle_is_good` (IntegerModel.lean:~1189). New proof: (a) the chronicle domain has SuccOrder, PredOrder, NoMaxOrder, NoMinOrder, Countable, Nonempty (all from ChronicleAsPriorModel). (b) `no_boundary_at_successor` gives: for all c, contemp_equiv c (succ c) (sorry-free). (c) `one_class` (from Phase 4, no longer needs IsSuccArchimedean) gives: for all a b, contemp_equiv a b. Prior-UZ/SZ validity is provided by the chronicle. (d) `one_class` implies `very_good` (every subinterval is good because all points are equivalent). (e) `very_good_implies_good` (from Phase 5, sorry-free) gives: M is good.
- [ ] **Task 6.2**: Remove `domain_succ_archimedean` field from `ChronicleAsPriorModel` (ChronicleExtraction.lean:103). Also remove the `attribute [instance]` declaration (line 129) and the assignment in `extract_chronicle_as_prior` (line 153).
- [ ] **Task 6.3**: Check NEquivalence.lean:1215 for IsSuccArchimedean instance. If the instance depends on `ChronicleAsPriorModel.domain_succ_archimedean`, provide an alternative derivation from `chronicleAsMonadicStructure_succ_archimedean` (which is already sorry-free) or restructure the dependency.
- [ ] **Task 6.4**: In `countermodel_discrete` (Transfer.lean), remove `orderIsoIntOfLinearSuccPredArch`. Replace with the new `chronicle_is_good` proof output. The Z-interval witness comes from `chronicle_is_good`'s output (`good sig k M_chron` provides the witness Z-interval). Extract via `.choose` and `.choose_spec`.
- [ ] **Task 6.5**: Propagate removal of `IsSuccArchimedean` to any downstream code that depends on `ChronicleAsPriorModel.domain_succ_archimedean`. Verify `limitDomSubtype_isSuccArchimedean` in ChronicleToCountermodel.lean is no longer on the critical path (it should remain in place for other code paths but not be called by `extract_chronicle_as_prior`).
- [ ] **Task 6.6**: Verify `lake build` passes.

**Timing**: 3 hours

**Depends on**: 1, 2, 3, 4, 5 (Phase 1 provides sorry-free `chronicle_temporal_truth`; Phase 2 provides Nonempty fix; Phase 3 provides sorry-free `z_interval_countermodel` + h_box_correct discharge; Phase 4 provides sorry-free `one_class` without IsSuccArchimedean; Phase 5 provides sorry-free `very_good_implies_good`)

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel.lean` -- rewrite `chronicle_is_good`
- `Theories/Bimodal/Metalogic/WeakCanonical/ChronicleExtraction.lean` -- remove `domain_succ_archimedean` from ChronicleAsPriorModel
- `Theories/Bimodal/Metalogic/WeakCanonical/Transfer.lean` -- remove `orderIsoIntOfLinearSuccPredArch` from `countermodel_discrete`, use chronicle_is_good witness
- `Theories/Bimodal/Metalogic/WeakCanonical/NEquivalence.lean` -- fix cascade if needed

**Verification**:
- `lean_verify` on `chronicle_is_good` shows no `sorryAx`
- No `orderIsoIntOfLinearSuccPredArch` in Transfer.lean
- No `IsSuccArchimedean` in ChronicleAsPriorModel
- `lake build` passes

---

### Phase 7: Final Wiring and Verification [NOT STARTED]

**Goal**: Verify the entire pipeline is sorry-free. Close any remaining bridging sorries. Run `#print axioms bx_completeness`.

**Tasks**:
- [ ] **Task 7.1**: Run `lean_verify countermodel_discrete` and inspect axiom list. Should show only `propext`, `Classical.choice`, `Quot.sound`.
- [ ] **Task 7.2**: Run `lean_verify bx_completeness` and inspect axiom list. Should show no `sorryAx`.
- [ ] **Task 7.3**: If any unexpected `sorryAx` remains, trace the dependency chain using `#print axioms` on intermediate theorems to identify the source. Fix any remaining sorry.
- [ ] **Task 7.4**: Run full `lake build` to ensure no regressions.
- [ ] **Task 7.5**: Verify no new `sorry` was introduced on the critical path: `grep -rn "sorry" Theories/Bimodal/Metalogic/WeakCanonical/` should show only pre-existing sorries outside the critical path (e.g., `doets_lemma_1_5`, TruthLemma.lean Until/Since backward, frame-class completeness variants).
- [ ] **Task 7.6**: Update file-level documentation comments in Transfer.lean, IntegerModel.lean, and ChronicleExtraction.lean to reflect the completed pipeline status.

**Timing**: 1 hour

**Depends on**: 6 (all upstream work must be complete before final verification)

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Transfer.lean` -- documentation updates
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel.lean` -- documentation updates
- `Theories/Bimodal/Metalogic/WeakCanonical/ChronicleExtraction.lean` -- documentation updates

**Verification**:
- `#print axioms bx_completeness` shows: propext, Classical.choice, Quot.sound (NO sorryAx)
- `#print axioms countermodel_discrete` shows: propext, Classical.choice, Quot.sound (NO sorryAx)
- `lake build` passes with zero errors
- No new `sorry` in the WeakCanonical directory on the critical path

---

## Testing & Validation

- [ ] `lake build` passes with zero errors
- [ ] `#print axioms bx_completeness` outputs only: `propext`, `Classical.choice`, `Quot.sound` (NO `sorryAx`)
- [ ] `#print axioms countermodel_discrete` shows no `sorryAx`
- [ ] `#print axioms chronicle_is_good` shows no `sorryAx`
- [ ] `#print axioms one_class` shows no `sorryAx`
- [ ] `#print axioms no_gaps_discrete` shows no `sorryAx`
- [ ] `#print axioms very_good_implies_good` shows no `sorryAx`
- [ ] `#print axioms chronicle_temporal_truth` shows no `sorryAx`
- [ ] `#print axioms z_interval_countermodel` shows no `sorryAx`
- [ ] No occurrence of `IsSuccArchimedean` in `no_gaps_discrete`, `one_class`, or `chronicle_is_good` theorem statements
- [ ] No occurrence of `orderIsoIntOfLinearSuccPredArch` in Transfer.lean
- [ ] `domain_succ_archimedean` removed from `ChronicleAsPriorModel`
- [ ] No new `sorry` introduced on the critical path

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/WeakCanonical/Transfer.lean` -- Closed chronicle_temporal_truth, fixed valuation bug, closed z_interval_countermodel with h_box_correct, closed Nonempty sorry, removed orderIsoIntOfLinearSuccPredArch
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel.lean` -- Closed cofinal_decomposition_k_equiv and ordered_sum_of_good_bounded_is_good, rewrote no_gaps_discrete/one_class/chronicle_is_good without IsSuccArchimedean
- `Theories/Bimodal/Metalogic/WeakCanonical/ChronicleExtraction.lean` -- Removed domain_succ_archimedean from ChronicleAsPriorModel
- `Theories/Bimodal/Metalogic/WeakCanonical/NEquivalence.lean` -- Fixed cascade if needed
- `specs/155_reynolds_pipeline_activation/plans/03_reynolds-pipeline-plan.md` -- This plan (v4)

## Rollback/Contingency

1. **Phase 1 (chronicle truth lemma)**: If the Until/Since induction is too complex, prove atoms + box + propositional connectives only and mark Until/Since cases as sorry with detailed goal states. This gives partial progress toward Phase 6.
2. **Phase 3 (z_interval_countermodel)**: If the `h_box_correct` approach creates downstream issues at the call site, consider Alternative D (Teammate D): prove only the countermodel direction `temporal_truth -> not truth_at` rather than the full biconditional. This halves the proof obligation.
3. **Phase 4 (gap elimination)**: THE HARDEST PHASE. If stuck after 8 hours, write a detailed handoff documenting: (a) which Reynolds sub-lemmas are proved, (b) which are stuck, (c) what the Lean goal state looks like. Mark [PARTIAL]. Consider: can the model surgery argument (Lemmas 10-13) be simplified using the specific properties of the chronicle domain?
4. **Phase 5 (IntegerModel sorries)**: If `cofinal_decomposition_k_equiv` is intractable via NF-evaluation, try: prove the embedding M -> orderedSum preserves all quantifier-depth-k formulas by direct induction, bypassing the NF framework.
5. **Phase 6 (chronicle_is_good rewrite)**: Low risk given Phases 4-5 are complete. If the NEquivalence.lean cascade is severe, keep `domain_succ_archimedean` as a computed field (derived from the new sorry-free `one_class` proof chain) rather than removing it.
6. **NEVER fall back to IsSuccArchimedean**: If stuck, mark [BLOCKED] and request help. Do not reintroduce the shortcut that caused the v1 failure.
