# Implementation Plan: Reynolds Pipeline Activation (v3 -- Post-Task-157)

- **Task**: 155 - reynolds_pipeline_activation
- **Status**: [NOT STARTED]
- **Effort**: 18 hours
- **Dependencies**: Task 154 (sum_preservation/doets_lemma_1_4, COMPLETED), Tasks 147-148 (table_correctness, COMPLETED), Task 157 (separation/expressive completeness, COMPLETED)
- **Research Inputs**: specs/155_reynolds_pipeline_activation/reports/03_post-157-status.md
- **Artifacts**: plans/02_reynolds-pipeline-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

---

## CRITICAL DIRECTIVE: NO DEVIATION FROM REYNOLDS 1994

**DO NOT deviate from the published proof structure without outstandingly good reason.**

The first implementation attempt (v1 Phases 2-4) deviated from Reynolds 1994 by adding `[IsSuccArchimedean M.carrier]` as hypothesis and using `orderIsoIntOfLinearSuccPredArch` to shortcut proofs. This approach created a circular dependency through `succ_cofinal` (task 129 sorry) and **failed completely**.

Agents MUST:
1. **READ the literature files** before attempting each phase
2. **Follow the paper step-by-step**
3. **NEVER add `IsSuccArchimedean` as a hypothesis** -- Reynolds does not use it
4. **NEVER use `orderIsoIntOfLinearSuccPredArch`** -- this is the shortcut that caused the failure
5. **If stuck, re-read the literature** -- the answer is in the paper

---

## Overview

This plan addresses the 4 critical-path sorry sites blocking sorry-free `bx_completeness`, plus 2 non-critical IntegerModel.lean sorries required for the Reynolds Lemma 16 path. The approach is a two-pronged attack: (1) fix the 3 Transfer.lean bridging sorries (trivial `Nonempty`, chronicle truth lemma, z_interval_countermodel with valuation bug), and (2) refactor the pipeline to eliminate the `IsSuccArchimedean` dependency by implementing gap elimination (Reynolds Theorem 14) using the now sorry-free `table_correctness` and `separation_theorem_int` from task 157, then routing `chronicle_is_good` through `one_class` + `very_good_implies_good` instead of `orderIsoIntOfLinearSuccPredArch`. Definition of done: `#print axioms bx_completeness` shows no `sorryAx`.

### Research Integration

Integrated from `reports/03_post-157-status.md`:
- Task 157 completed: `separation_theorem_int` and `table_correctness` are sorry-free
- 5 sorry sites identified across 2 files; 4 on critical path, 2 in IntegerModel.lean off critical path but needed for Option 1
- Valuation bug in `z_interval_countermodel`: uses `s.val` (fixed point) instead of varying with time parameter; `WorldState = Unit` prevents time-varying atoms
- Two propagation channels: Channel A (succ_cofinal via extract_chronicle_as_prior) and Channel B (3 explicit Transfer.lean sorries)
- Recommendation: Option 1 (refactor away IsSuccArchimedean) is cleanest

### Prior Plan Reference

v2 plan completed Phases 1, 2, 4, 5, 6 but Phases 3A/3B remained. Phase 3A was delegated to task 157 (now COMPLETED). Phase 3B (gap elimination) was blocked on 3A but is now unblocked. The pipeline is structurally wired (fallback removed) but 4 bridging sorries remain. Key lessons: do not deviate from Reynolds; budget generously for hard proofs; the Fintype path for k-equiv works well (validated in Phase 2).

### Roadmap Alignment

- Advances "sorry-free `bx_completeness`" (primary critical path item)
- Eliminates circular dependency through `succ_cofinal` (task 129)
- Closes the discrete completeness branch of the Reynolds pipeline

## Goals & Non-Goals

**Goals**:
- Close all 4 critical-path sorry sites in Transfer.lean
- Close 2 IntegerModel.lean helper sorries (`cofinal_decomposition_k_equiv`, `ordered_sum_of_good_bounded_is_good`)
- REMOVE `[IsSuccArchimedean M.carrier]` from `no_gaps_discrete` and `one_class`
- REWRITE `no_gaps_discrete` following Reynolds Theorem 14 (gap elimination)
- REWRITE `chronicle_is_good` to NOT use `orderIsoIntOfLinearSuccPredArch`
- Fix the valuation bug in `z_interval_countermodel` (WorldState must be Int, not Unit)
- Achieve `#print axioms bx_completeness` with no `sorryAx`

**Non-Goals**:
- Dense completeness (separate path, unaffected)
- Closing `succ_cofinal` (task 129) -- we bypass it entirely
- Frame-class completeness variants (Completeness.lean:254,279,288)
- Optimizing existing sorry-free infrastructure
- `countermodel_discrete_enriched` (Completeness.lean:225, separate wrapper)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Gap elimination (Reynolds Theorem 14) is genuinely hard (~6 pages) | H | H | Budget 6 hours; break into sub-lemmas (Lemmas 6-13); use `table_correctness` as expressive completeness tool; task 157 provides sorry-free `is_separable` |
| `z_interval_countermodel` refactor to WorldState=Int breaks downstream | M | L | `zIntervalTaskFrame` is only used within Transfer.lean; contained refactor |
| `cofinal_decomposition_k_equiv` EF-game argument is technical | M | M | Standard duplicator strategy; boundary point duplication is bounded |
| Chronicle truth lemma induction complex for Until/Since cases | M | M | Prior-UZ/SZ validity in chronicle provides the key induction step |
| `ordered_sum_of_good_bounded_is_good` shift-and-glue construction hard to formalize | M | M | Clear mathematical structure; use cumulative offset function |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2, 4 | -- |
| 2 | 3 | 1 |
| 3 | 5 | 2, 3, 4 |
| 4 | 6 | 5 |

Phases 1, 2, and 4 can execute in parallel (Wave 1). Phase 3 requires Phase 1 (Wave 2). Phase 5 requires all of Phases 2, 3, 4 (Wave 3). Phase 6 is the final verification (Wave 4).

---

### Phase 1: Fix Transfer.lean Bridging Sorries (Trivial + Valuation Bug) [NOT STARTED]

**Goal**: Close the `Nonempty sig.preds` sorry and fix the valuation bug in `z_interval_countermodel` by refactoring `zIntervalTaskFrame` to use `WorldState = Int`.

**Tasks**:
- [ ] **Task 1.1**: Fix `Nonempty sig.preds` (Transfer.lean:332). Handle the empty-predicate edge case: if `φ.predFormulas` is empty, φ is purely propositional (only `bot`/`imp`), and a simpler propositional countermodel suffices. Case-split on `Decidable (Nonempty sig.preds)`.
- [ ] **Task 1.2**: Refactor `zIntervalTaskFrame` to use `WorldState = Int` instead of `WorldState = Unit`. The new frame: `task_rel w1 w2 delta := w2 = w1 + delta`. This allows the valuation to vary with time position.
- [ ] **Task 1.3**: Update `zIntervalHistory` for the new frame: `states t h_dom := t` (the state at time t is the integer t itself). Domain is all of Z.
- [ ] **Task 1.4**: Fix the valuation in `z_interval_countermodel`: change from `fun _ a => Z.interp (atomMap_fwd (.atom a)) s.val` to `fun z a => Z.interp (atomMap_fwd (.atom a)) z` (valuation depends on the WorldState integer, not the fixed witness).
- [ ] **Task 1.5**: Prove the `truth_at` correspondence by structural induction on φ: `truth_at TM Omega tau t phi <-> temporal_truth (Z.toOrdered sig) atomMap_fwd (iso.symm t) phi`. Cases: atom (direct from valuation definition), neg (IH), imp (IH), box (trivial: single S5 class means all states accessible), until/since (Z order matches temporal order).
- [ ] **Task 1.6**: Also fix the same pattern in `countermodel_discrete` at Transfer.lean:275-276 (the inline `TM` construction there has the same bug).
- [ ] **Task 1.7**: Verify `lake build` passes with fixed Transfer.lean.

**Timing**: 2 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Transfer.lean` -- refactor zIntervalTaskFrame, zIntervalHistory, z_interval_countermodel, fix Nonempty sorry

**Verification**:
- `lean_verify` on `z_interval_countermodel` shows no `sorryAx`
- `lake build` passes

---

### Phase 2: IntegerModel.lean Helper Sorries [NOT STARTED]

**Goal**: Close the 2 non-critical-path sorries in IntegerModel.lean that are needed for `very_good_implies_good` to be fully sorry-free: `cofinal_decomposition_k_equiv` (line 1079) and `ordered_sum_of_good_bounded_is_good` (line 1138, k>=2 case).

**Tasks**:
- [ ] **Task 2.1**: Prove `cofinal_decomposition_k_equiv` (IntegerModel.lean:1079). The proof: construct a duplicator strategy in the EF game showing M and orderedSum have the same k-types. The key insight: the ordered sum has duplicated boundary points (a(i+1) appears in both piece i and piece i+1), but these duplicates are adjacent and satisfy the same predicates, so any Spoiler choice in one can be matched in the other. Strategy: embed M into orderedSum via the canonical map (send x to the leftmost piece containing it), and show the embedding preserves k-types by induction on k using `nf_eval_nf` agreement.
- [ ] **Task 2.2**: Prove `ordered_sum_of_good_bounded_is_good` for k>=2 (IntegerModel.lean:1138). The proof uses: (a) each ms(i) has max/min, (b) witnesses Z_i inherit bounded (via `doets_lemma_1_1` at depth 2 transferring "has max/min" sentences), (c) Z_i bounded means `Z_i.lo = some _` and `Z_i.hi = some _`, (d) concatenation of bounded Z-intervals indexed by Z is order-isomorphic to a single unbounded Z-interval via cumulative-offset shift-and-glue, (e) `k_equiv_of_iso` gives the final goodness.
- [ ] **Task 2.3**: For Task 2.2, construct the shift-and-glue OrderIso: define `shift : Z -> Z` as cumulative offset function mapping the i-th Z-interval's elements to a contiguous segment of Z. Prove: strictly monotone, surjective, preserves predicates.
- [ ] **Task 2.4**: Verify `lean_verify` on `very_good_implies_good` shows no `sorryAx`.

**Timing**: 4 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel.lean` -- close cofinal_decomposition_k_equiv and ordered_sum_of_good_bounded_is_good

**Verification**:
- `lean_verify` on `cofinal_decomposition_k_equiv` shows no `sorryAx`
- `lean_verify` on `ordered_sum_of_good_bounded_is_good` shows no `sorryAx`
- `lean_verify` on `very_good_implies_good` shows no `sorryAx`
- `lake build` passes

---

### Phase 3: Gap Elimination and One-Class Theorem (Reynolds Theorem 14) [NOT STARTED]

**Goal**: Rewrite `no_gaps_discrete` WITHOUT `IsSuccArchimedean`, following Reynolds 1994 Section 7 (Lemmas 6-13, Theorem 14). Then rewrite `one_class` to use the genuine `no_gaps_discrete` + `no_boundary_at_successor` argument.

**BEFORE CODING**: Read `literature/Reynolds_1994_Axiomatising_U_and_S_over_integer_time.md` Section 7 (Lemmas 6-13, Theorem 14) IN FULL. These proofs are 6 pages of dense argument. Budget time accordingly.

**Reynolds Reference**: Theorem 14 proves that ~M classes cannot end at gaps in Prior structures. The argument: define rho(x) = "x's ~-class ends in a gap on the right", convert rho to temporal formula R via expressive completeness (`table_correctness` + `separation_theorem_int`), use Prior-UZ on R to derive contradiction. Key sub-lemmas establish structural properties of R-intervals.

**Tasks**:
- [ ] **Task 3.1**: REMOVE `[IsSuccArchimedean M.carrier]` from `no_gaps_discrete` signature. Replace with `[SuccOrder M.carrier] [PredOrder M.carrier] [NoMaxOrder M.carrier] [NoMinOrder M.carrier]` plus a hypothesis providing Prior-UZ/SZ validity (or the chronicle model). The theorem must work for any discrete linear order without endpoints where Prior axioms hold.
- [ ] **Task 3.2**: Formalize Reynolds Lemma 6: define rho(a) = "there exists b > a such that a ~M b but not a ~M (b+1)" (the class of a has a gap on the right at b). Express this as a monadic FO formula and convert to temporal formula R via `table_correctness`.
- [ ] **Task 3.3**: Formalize Reynolds Lemmas 7-8: structural properties of R-intervals. R-intervals have excluded upper endpoints. Every point in an R-interval has the same ~M-class behavior.
- [ ] **Task 3.4**: Formalize Reynolds Lemma 9: ~M classes within R-intervals are elementarily equivalent. This uses `table_correctness` to express class membership as a temporal property.
- [ ] **Task 3.5**: Formalize Reynolds Lemmas 10-13: the model surgery argument. Replace a "bad interval" by one of its classes. Show temporal truth is preserved. This is THE HARDEST sub-proof. Derive contradiction from Prior-UZ validity on R.
- [ ] **Task 3.6**: Assemble `no_gaps_discrete` from Lemmas 6-13: ~M classes do not end at gaps. The proof by contradiction: assume a gap exists, construct R, apply Prior-UZ, get contradiction.
- [ ] **Task 3.7**: Rewrite `one_class` to use the genuine two-step argument: (a) `no_boundary_at_successor` (sorry-free, uses finite_structures_good) gives c ~M succ(c) for all c, (b) `no_gaps_discrete` (from Task 3.6) means classes don't end at gaps. Together: ~M classes span the entire order, so there is exactly one class.
- [ ] **Task 3.8**: Verify `lake build` passes and `lean_verify one_class` shows no `sorryAx`.

**Timing**: 6 hours

**Depends on**: 1 (needs sorry-free `table_correctness` infrastructure, which exists; Phase 1 ensures Transfer.lean compiles cleanly)

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel.lean` -- rewrite `no_gaps_discrete`, `one_class`, add gap elimination machinery (Lemmas 6-13)

**Verification**:
- `lean_verify` on `no_gaps_discrete` shows no `sorryAx`
- `lean_verify` on `one_class` shows no `sorryAx`
- No `IsSuccArchimedean` in `no_gaps_discrete` or `one_class` theorem statements
- `lake build` passes

---

### Phase 4: Chronicle Truth Lemma [NOT STARTED]

**Goal**: Close the `chronicle_temporal_truth` sorry (Transfer.lean:186) and the inline sorry at Transfer.lean:371. This connects MCS membership in the chronicle to `temporal_truth` on the chronicle-as-monadic-structure.

**Tasks**:
- [ ] **Task 4.1**: Prove `chronicle_temporal_truth` by structural induction on formula ψ. Cases:
  - **Atom**: `atomMap_fwd` maps atom a to its predicate symbol; `temporal_truth` for atoms checks `M_chron.interp (atomMap_fwd (atom a)) t`, which by definition of `chronicleAsMonadicStructure` is `(atomMap_rev (atomMap_fwd (atom a))) ∈ M.fmcs t`. The section hypothesis `h_section` gives `atomMap_rev (atomMap_fwd f) = f` for relevant f, so this reduces to `(atom a) ∈ M.fmcs t`.
  - **Bot**: `temporal_truth` for bot is False; bot is never in an MCS (by consistency).
  - **Imp**: `temporal_truth` for `ψ₁ → ψ₂` is `¬temporal_truth ψ₁ ∨ temporal_truth ψ₂`. MCS membership of imp follows from MCS closure under modus ponens and maximality.
  - **Box**: `temporal_truth` for `□ψ` checks all points in the carrier. MCS membership of `□ψ` at t means ψ is in every MCS (by the box axiom in the chronicle structure). Use `atomMap_fwd` mapping for `.box` predicate symbols.
  - **Until**: `temporal_truth` for `ψ₁ U ψ₂` checks existence of future witness. Prior-UZ validity in the chronicle (`M.prior_UZ_valid`) ensures that `(some_future ψ₂) ∈ fmcs t` implies `(ψ₂ U neg(ψ₂)) ∈ fmcs t`, which provides the witness structure. Standard temporal truth lemma argument.
  - **Since**: Symmetric to Until, using Prior-SZ validity (`M.prior_SZ_valid`).
- [ ] **Task 4.2**: Wire `chronicle_temporal_truth` into `countermodel_discrete` at Transfer.lean:366-371, replacing the inline sorry.
- [ ] **Task 4.3**: Verify `lake build` passes.

**Timing**: 3 hours

**Depends on**: none (chronicle truth lemma is pure infrastructure connecting MCS membership to temporal_truth; does not depend on gap elimination or IntegerModel fixes)

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Transfer.lean` -- prove chronicle_temporal_truth, wire into countermodel_discrete

**Verification**:
- `lean_verify` on `chronicle_temporal_truth` shows no `sorryAx`
- Sorry at Transfer.lean:371 is closed
- `lake build` passes

---

### Phase 5: Rewrite chronicle_is_good and Remove IsSuccArchimedean [NOT STARTED]

**Goal**: Rewrite `chronicle_is_good` to use `one_class` + `very_good_implies_good` instead of `orderIsoIntOfLinearSuccPredArch`. Remove `domain_succ_archimedean` from `ChronicleAsPriorModel`. Remove `orderIsoIntOfLinearSuccPredArch` from `countermodel_discrete`.

**Tasks**:
- [ ] **Task 5.1**: Rewrite `chronicle_is_good` (IntegerModel.lean:1189-1210). The new proof:
  (a) The chronicle domain has `SuccOrder`, `PredOrder`, `NoMaxOrder`, `NoMinOrder`, `Countable`, `Nonempty` (all from ChronicleAsPriorModel).
  (b) `no_boundary_at_successor` gives: for all c, contemp_equiv c (succ c). This is sorry-free (Phase 2 of v2 plan, COMPLETED).
  (c) `one_class` (from Phase 3 rewrite) gives: for all a b, contemp_equiv a b. This NO LONGER needs IsSuccArchimedean.
  (d) `one_class` implies `very_good` (every subinterval is good because all points are equivalent).
  (e) `very_good_implies_good` (from Phase 2, sorry-free) gives: M is good.
  Note: `one_class` needs Prior-UZ/SZ validity (from `no_gaps_discrete`), which the chronicle provides. The `one_class` rewrite in Phase 3 must accept Prior-UZ/SZ as hypotheses rather than requiring `IsSuccArchimedean`.
- [ ] **Task 5.2**: Remove `domain_succ_archimedean` field from `ChronicleAsPriorModel` (ChronicleExtraction.lean:103). Also remove the `attribute [instance]` declaration (line 129) and the assignment in `extract_chronicle_as_prior` (line 153).
- [ ] **Task 5.3**: In `countermodel_discrete` (Transfer.lean:344), remove `orderIsoIntOfLinearSuccPredArch`. Replace with the new `chronicle_is_good` proof (which no longer needs it). The k-equivalence between the chronicle and a Z-interval structure comes from `chronicle_is_good`'s output, not from an explicit OrderIso.
- [ ] **Task 5.4**: Update `countermodel_discrete` to use the Z-interval witness from `chronicle_is_good` instead of constructing it inline. The witness is the `Z` from `good sig k M_chron`, which has `lo = none` and `hi = none` (since the chronicle is unbounded). Extract it via `chronicle_is_good.choose` and `chronicle_is_good.choose_spec`.
- [ ] **Task 5.5**: Propagate removal of `IsSuccArchimedean` to any downstream code that depends on `ChronicleAsPriorModel.domain_succ_archimedean`. Check: `limitDomSubtype_isSuccArchimedean` is still defined in ChronicleToCountermodel.lean but is no longer called. Leave it in place (it is used by other code paths) but verify it is not on the critical path.
- [ ] **Task 5.6**: Verify `lake build` passes with all changes.

**Timing**: 2 hours

**Depends on**: 2, 3, 4 (Phase 2 provides sorry-free `very_good_implies_good`; Phase 3 provides sorry-free `one_class` without IsSuccArchimedean; Phase 4 provides sorry-free `chronicle_temporal_truth`)

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel.lean` -- rewrite `chronicle_is_good`
- `Theories/Bimodal/Metalogic/WeakCanonical/ChronicleExtraction.lean` -- remove `domain_succ_archimedean` from ChronicleAsPriorModel
- `Theories/Bimodal/Metalogic/WeakCanonical/Transfer.lean` -- remove `orderIsoIntOfLinearSuccPredArch` from `countermodel_discrete`, use chronicle_is_good witness

**Verification**:
- `lean_verify` on `chronicle_is_good` shows no `sorryAx`
- No `orderIsoIntOfLinearSuccPredArch` in Transfer.lean
- No `IsSuccArchimedean` in ChronicleAsPriorModel
- `lake build` passes

---

### Phase 6: Final Wiring and Verification [NOT STARTED]

**Goal**: Verify the entire pipeline is sorry-free. Close any remaining bridging sorries. Run `#print axioms bx_completeness`.

**Tasks**:
- [ ] **Task 6.1**: Run `lean_verify countermodel_discrete` and inspect axiom list. Should show only `propext`, `Classical.choice`, `Quot.sound`.
- [ ] **Task 6.2**: Run `lean_verify bx_completeness` and inspect axiom list. Should show no `sorryAx`.
- [ ] **Task 6.3**: If any unexpected `sorryAx` remains, trace the dependency chain using `#print axioms` on intermediate theorems to identify the source. Fix any remaining sorry.
- [ ] **Task 6.4**: Run full `lake build` to ensure no regressions.
- [ ] **Task 6.5**: Verify no new `sorry` was introduced anywhere in the codebase: `grep -rn "sorry" Theories/Bimodal/Metalogic/WeakCanonical/` should show only pre-existing sorries outside the critical path (e.g., `doets_lemma_1_5`, TruthLemma.lean Until/Since backward, frame-class completeness variants).
- [ ] **Task 6.6**: Update file-level documentation comments in Transfer.lean and IntegerModel.lean to reflect the completed pipeline status.

**Timing**: 1 hour

**Depends on**: 5 (all upstream work must be complete before final verification)

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Transfer.lean` -- documentation updates
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel.lean` -- documentation updates

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

- `Theories/Bimodal/Metalogic/WeakCanonical/Transfer.lean` -- Fixed valuation bug, closed bridging sorries, removed orderIsoIntOfLinearSuccPredArch
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel.lean` -- Closed cofinal_decomposition_k_equiv and ordered_sum_of_good_bounded_is_good, rewrote no_gaps_discrete/one_class/chronicle_is_good without IsSuccArchimedean
- `Theories/Bimodal/Metalogic/WeakCanonical/ChronicleExtraction.lean` -- Removed domain_succ_archimedean from ChronicleAsPriorModel
- `specs/155_reynolds_pipeline_activation/plans/02_reynolds-pipeline-plan.md` -- This plan (v3)

## Rollback/Contingency

1. **Phase 1 (valuation bug fix)**: If WorldState=Int creates problems with TaskFrame axioms, consider an alternative: keep WorldState=Unit but change the WorldHistory to carry a mapping from time to integer position, and define `truth_at` accordingly. The math is equivalent.
2. **Phase 2 (IntegerModel sorries)**: If `cofinal_decomposition_k_equiv` is intractable via EF-game, try the alternative: prove the embedding M -> orderedSum is a k-equivalence by showing it preserves all NF evaluations directly (without the game abstraction).
3. **Phase 3 (gap elimination)**: THE HARDEST PHASE. If stuck after 6 hours, write a detailed handoff documenting: (a) which Reynolds sub-lemmas are proved, (b) which are stuck, (c) what the Lean goal state looks like. Mark [PARTIAL]. Consider: can we bypass gap elimination entirely? If the chronicle domain is a subtype of Q (which is dense in some places), the discrete restriction via `next_top` might give us IsSuccArchimedean for free on the restricted domain -- investigate as a last resort.
4. **Phase 4 (chronicle truth lemma)**: If the Until/Since induction is too complex, consider proving a weaker version first (atoms + box + propositional connectives only) and marking Until/Since cases as sorry with detailed goal states.
5. **Phase 5 (chronicle_is_good rewrite)**: Low risk given Phases 2-4 are complete. If the new `one_class` has unexpected signature requirements, adapt `chronicle_is_good` to provide the needed hypotheses from `ChronicleAsPriorModel` fields.
6. **NEVER fall back to IsSuccArchimedean**: If stuck, mark [BLOCKED] and request help. Do not reintroduce the shortcut that caused the v1 failure.
