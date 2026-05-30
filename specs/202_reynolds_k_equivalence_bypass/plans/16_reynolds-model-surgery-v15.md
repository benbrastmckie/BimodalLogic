# Implementation Plan: Task #202 -- Reynolds Model Surgery v15

- **Task**: 202 - Reynolds k-equivalence bypass for sorry-free completeness_discrete
- **Status**: [NOT STARTED]
- **Effort**: 16 hours
- **Dependencies**: None
- **Research Inputs**: reports/16_team-research.md, reports/16_teammate-a-findings.md, reports/16_teammate-b-findings.md, reports/16_teammate-c-findings.md, reports/16_teammate-d-findings.md, plans/14_reynolds-model-surgery-definitive.md (prior plan, reference only)
- **Artifacts**: plans/16_reynolds-model-surgery-v15.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Plan v15 closes the 2 remaining sorry sites in GoodStructuresModelSurgery.lean (`gap_prior_UZ_contradiction` at line 702 and `gap_prior_SZ_contradiction` at line 728) via the full Reynolds model surgery argument (Lemmas 6-13, Theorem 14). Team research across 4 parallel investigators confirmed that the TRUE blocker across 17 prior implementation cycles is that no agent has ever attempted the `MonadicFormula sig 1` construction encoding `right_gap_class_prop` (Reynolds Lemma 6). Every prior cycle instead tried bridge lemmas (class_temporal_formula, enriched-signature class membership) that are provably impossible. This plan decomposes the work into 4 independently deliverable phases with explicit Lean signatures, specific infrastructure reuse, and clear verification criteria.

### Research Integration

- **reports/16_team-research.md**: Synthesis identifying the true blocker (MonadicFormula construction never attempted) and converging on 4-phase decomposition.
- **reports/16_teammate-a-findings.md**: Primary decomposition into 4 sub-tasks A-D with exact Lean signatures and line estimates.
- **reports/16_teammate-b-findings.md**: Inventory of 16+ sorry-free reusable lemmas (right_gap_class_*, US_expressively_complete_over_prior, contemp_equiv_*, prior_UZ/SZ_first/last_transition, doets_lemma_1_1/1_4, orderedSum, k_equiv_of_iso).
- **reports/16_teammate-c-findings.md**: Root cause analysis of 17 failed cycles -- agents build scaffolding, not the building. Infrastructure trap pattern identified. MonadicFormula construction is ~100 lines of Lean term-level programming that has never been attempted.
- **reports/16_teammate-d-findings.md**: Strategic assessment confirming completeness_discrete is the right goal, model surgery is the only confirmed-correct path, and accept-and-defer (axiom) is premature.

### Prior Plan Reference

Plan v14 (5 phases, 18 hours) correctly identified the Reynolds model surgery as necessary but did not decompose Phase 2 into independently deliverable checkpoints. Phase 1 (h_surj construction) was completed. Phase 2 (model surgery core, 12 hours) was marked IN PROGRESS but the sorry sites remain. Lessons learned: (1) the task exceeds a single agent session at 580+ lines; (2) the enriched-signature approach for class membership is circular; (3) `right_gap_class_prop` (not class membership) is the correct intermediate target; (4) the work must be decomposed into phases small enough for a single session.

### Roadmap Alignment

No ROADMAP.md found.

## Goals & Non-Goals

**Goals**:
- Close `gap_prior_UZ_contradiction` sorry (GoodStructuresModelSurgery.lean:702) via Reynolds Lemmas 6-13
- Close `gap_prior_SZ_contradiction` sorry (GoodStructuresModelSurgery.lean:728) via Order.dual reduction or symmetric argument
- Produce sorry-free `reynolds_model_surgery_core`, `gap_contradicts_prior`, `gap_contradicts_prior_below`, and `no_gaps_discrete_model_surgery`

**Non-Goals**:
- Wiring `no_gaps_discrete` in GoodStructures.lean (separate phase, plan v14 Phase 3)
- Transfer.lean packaging (plan v14 Phases 1, 4)
- Completeness.lean rewiring (plan v14 Phase 5)
- Modifying the dense completeness path
- BX pipeline revival (analyzed and rejected in report 15)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| MonadicFormula construction for right_gap_class_prop exceeds estimates (De Bruijn index arithmetic, Fintype enumeration) | H | M | Use Classical.choice existence proof: prove the Prop that such a formula exists (finite k-type disjunction argument), then use choice to extract. Avoids explicit formula construction. |
| 26 U/S subcases in truth preservation exceed 300 lines | M | M | Each subcase is an independent named lemma (15-30 lines). Can be parallelized. Group by direction (U-forward, U-backward, S-forward, S-backward). |
| Order.dual reduction for SZ case has type class transfer issues | M | L | Fallback: implement SZ case independently by mirroring UZ argument (~150 additional lines). Prior_SZ_last_transition provides the symmetric infrastructure. |
| Surgery model construction (orderedSum with 3 pieces) requires complex type-theoretic bookkeeping | M | M | Reuse orderedSum pattern from NEquivalence.lean and ShiftAndGlue.lean. Use Set.Elem (subtype of M.carrier) for domain, not a new type. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 1, 2 |
| 4 | 4 | 3 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Gap Formula R Construction (Reynolds Lemma 6) [NOT STARTED]

**Goal**: Construct a `MonadicFormula sig 1` encoding `right_gap_class_prop`, then apply `US_expressively_complete_over_prior` to obtain temporal formula R such that `temporal_truth M atomMap t R <-> right_gap_class_prop sig k M t`.

**Mathematical content**: Reynolds Lemma 6 states that the property "t's contemp_equiv class is bounded above and succ-closed" is expressible as a monadic first-order formula with one free variable. The key insight is that `contemp_equiv sig k M t y` expands to `very_good sig k (M.subinterval sig (min t y) (max t y))`, which is a bounded quantification over a finite set of k-types (`NormalFormIdx sig k 0` is `Fintype`). The entire condition reduces to a finite disjunction, which IS a monadic FO formula.

**Strategy**: Two approaches, ordered by preference:

1. **Classical.choice (preferred)**: Prove a Prop-level existence theorem `∃ (rho : MonadicFormula sig 1), ∀ (M : OrderedMonadicStructure sig) (t : M.carrier), eval M (fun _ => t) rho <-> right_gap_class_prop sig k M t`. Use `Classical.choice` to extract the formula. The existence proof argues: right_gap_class_prop is a Boolean combination of monadic FO sentences (the k-type conditions), all monadic FO sentences are expressible in monadic FO (tautological), and Boolean combinations preserve expressibility.

2. **Explicit construction (fallback)**: Build the `MonadicFormula sig 1` term directly by enumerating `NormalFormIdx sig k 0` values (via `Fintype.elems`), constructing formulas for each k-type check, and combining with disjunction/conjunction.

**Tasks**:
- [ ] **Task 1.1**: Define `right_gap_class_formula` -- Construct or postulate `MonadicFormula sig 1` encoding right_gap_class_prop (~40 lines)
  ```lean
  noncomputable def right_gap_class_formula (sig : MonadicSignature) (k : Nat)
      (atomMap : Formula -> sig.preds)
      (h_surj : forall p : sig.preds, exists a : Atom, atomMap (.atom a) = p) :
      MonadicFormula sig 1 := ...
  ```
  - Use `Classical.choice` if taking the existence approach
  - The formula must encode: `(exists b > x, not contemp_equiv x b) and (forall c, contemp_equiv x c -> contemp_equiv x (succ c))`
  - `contemp_equiv` reduces to `very_good`, which reduces to finite k-type checks over `NormalFormIdx sig k 0`

- [ ] **Task 1.2**: Prove `right_gap_class_expressible` -- The formula correctly encodes right_gap_class_prop (~30 lines)
  ```lean
  theorem right_gap_class_expressible (sig : MonadicSignature) (k : Nat)
      (M : OrderedMonadicStructure sig)
      [SuccOrder M.carrier] [NoMaxOrder M.carrier]
      (atomMap : Formula -> sig.preds)
      (h_surj : forall p : sig.preds, exists a : Atom, atomMap (.atom a) = p)
      (t : M.carrier) :
      eval M (fun _ => t) (right_gap_class_formula sig k atomMap h_surj) <->
      right_gap_class_prop sig k M t := ...
  ```
  - If using Classical.choice, this follows directly from the choice specification
  - If using explicit construction, prove by structural induction on the formula

- [ ] **Task 1.3**: Define `gap_formula_R` -- Apply US_expressively_complete_over_prior to get temporal formula R (~15 lines)
  ```lean
  noncomputable def gap_formula_R (sig : MonadicSignature) (k : Nat)
      (atomMap : Formula -> sig.preds)
      (h_surj : forall p : sig.preds, exists a : Atom, atomMap (.atom a) = p) :
      Formula :=
    (US_expressively_complete_over_prior atomMap h_surj
      (right_gap_class_formula sig k atomMap h_surj)).val
  ```

- [ ] **Task 1.4**: Prove `gap_formula_R_correct` -- R detects right_gap_class_prop via temporal_truth (~20 lines)
  ```lean
  theorem gap_formula_R_correct (sig : MonadicSignature) (k : Nat)
      (M : OrderedMonadicStructure sig)
      [SuccOrder M.carrier] [PredOrder M.carrier]
      [NoMaxOrder M.carrier] [NoMinOrder M.carrier]
      (atomMap : Formula -> sig.preds)
      (h_surj : forall p : sig.preds, exists a : Atom, atomMap (.atom a) = p)
      (h_prior_UZ : semantic_prior_UZ M atomMap)
      (h_prior_SZ : semantic_prior_SZ M atomMap)
      (t : M.carrier) :
      temporal_truth M atomMap t (gap_formula_R sig k atomMap h_surj) <->
      right_gap_class_prop sig k M t := ...
  ```
  - Compose `US_expressively_complete_over_prior` specification with `right_gap_class_expressible`

**Timing**: 4 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/GoodStructuresModelSurgery.lean` -- Add ~100 lines after line 659 (after right_gap_class_pred, before the Reynolds Theorem 14 section)

**Verification**:
- `lake build Bimodal.Metalogic.WeakCanonical.IntegerModel.GoodStructuresModelSurgery` succeeds
- `#check gap_formula_R_correct` type-checks
- `grep -c "sorry" GoodStructuresModelSurgery.lean` unchanged (sorries at gap_prior_UZ/SZ_contradiction remain, no new sorry introduced)

**Infrastructure used**:
- `right_gap_class_prop` (GoodStructuresModelSurgery.lean:592)
- `right_gap_class_invariant` (GoodStructuresModelSurgery.lean:603)
- `right_gap_class_succ` (GoodStructuresModelSurgery.lean:639)
- `right_gap_class_pred` (GoodStructuresModelSurgery.lean:650)
- `US_expressively_complete_over_prior` (PriorExpressiveness.lean:371)
- `MonadicFormula sig 1`, `eval` (MonadicFO.lean:63, line ~190)
- `NormalFormIdx sig k 0` and `Fintype` instance (MonadicFO.lean)

---

### Phase 2: R-Interval Analysis (Reynolds Lemmas 7-8) [NOT STARTED]

**Goal**: Establish that R holds throughout the class of `a` (under the hypotheses of `gap_prior_UZ_contradiction`), identify the first R-transition point via `prior_UZ_first_transition`, and show R-intervals have specific structural properties needed for the surgery argument.

**Mathematical content**: Given `gap_formula_R_correct` from Phase 1, the hypotheses of `gap_prior_UZ_contradiction` (class of `a` succ-closed, bounded above) imply `right_gap_class_prop sig k M a` is true, hence R holds at `a`. Since `right_gap_class_prop` is preserved under succ/pred (by `right_gap_class_succ`/`right_gap_class_pred`), R is preserved under succ/pred. Since there exists `y > a` with `not (contemp_equiv a y)`, and `right_gap_class_prop y` may be false (y's class may not be succ-closed and bounded above), R may be false at some points. By `prior_UZ_first_transition`, there exists a first R-to-not-R transition point.

**Tasks**:
- [ ] **Task 2.1**: Prove `R_holds_at_a` -- R holds at `a` under gap_prior_UZ hypotheses (~20 lines)
  ```lean
  private theorem R_holds_at_a (sig : MonadicSignature) (k : Nat)
      (M : OrderedMonadicStructure sig)
      [SuccOrder M.carrier] [PredOrder M.carrier]
      [NoMaxOrder M.carrier] [NoMinOrder M.carrier]
      (atomMap : Formula -> sig.preds)
      (h_surj : forall p : sig.preds, exists a : Atom, atomMap (.atom a) = p)
      (h_prior_UZ : semantic_prior_UZ M atomMap)
      (h_prior_SZ : semantic_prior_SZ M atomMap)
      (a : M.carrier)
      (h_succ_closed : forall c, contemp_equiv sig k M a c ->
        contemp_equiv sig k M a (Order.succ c))
      (y : M.carrier) (hay : a < y)
      (h_not_equiv : not (contemp_equiv sig k M a y)) :
      temporal_truth M atomMap a (gap_formula_R sig k atomMap h_surj) := ...
  ```
  - Prove `right_gap_class_prop sig k M a` from hypotheses: bounded above (witness y, hay, h_not_equiv) and succ-closed (h_succ_closed)
  - Apply `gap_formula_R_correct` to convert to temporal_truth

- [ ] **Task 2.2**: Prove `R_not_holds_somewhere` -- R is false at some point above `a` (~15 lines)
  ```lean
  private theorem R_not_holds_somewhere (sig : MonadicSignature) (k : Nat)
      (M : OrderedMonadicStructure sig) ... (a y : M.carrier) (hay : a < y)
      (h_not_equiv : not (contemp_equiv sig k M a y)) :
      exists s : M.carrier, a < s /\
        not (temporal_truth M atomMap s (gap_formula_R sig k atomMap h_surj)) := ...
  ```
  - Show that sufficiently far from `a`, right_gap_class_prop eventually fails (the class of `a` ends at a gap, but points beyond the gap have different class structure)
  - Uses `h_not_equiv` and properties of contemp_equiv classes

- [ ] **Task 2.3**: Prove `R_first_transition` -- First R-to-not-R transition point exists (~20 lines)
  ```lean
  private theorem R_first_transition (sig : MonadicSignature) (k : Nat)
      (M : OrderedMonadicStructure sig) ...
      (a : M.carrier) ...
      (h_R_at_a : temporal_truth M atomMap a (gap_formula_R sig k atomMap h_surj))
      (h_not_R_somewhere : exists s, a < s /\
        not (temporal_truth M atomMap s (gap_formula_R sig k atomMap h_surj))) :
      exists c : M.carrier, a <= c /\
        temporal_truth M atomMap c (gap_formula_R sig k atomMap h_surj) /\
        not (temporal_truth M atomMap (Order.succ c) (gap_formula_R sig k atomMap h_surj)) := ...
  ```
  - Apply `prior_UZ_first_transition` (GoodStructuresModelSurgery.lean:116) directly
  - This gives the transition point `c` where R holds at `c` but not at `succ(c)`

**Timing**: 2 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/GoodStructuresModelSurgery.lean` -- Add ~55 lines after Phase 1 additions

**Verification**:
- `lake build Bimodal.Metalogic.WeakCanonical.IntegerModel.GoodStructuresModelSurgery` succeeds
- `#check R_first_transition` type-checks
- No new sorry introduced

**Infrastructure used**:
- `gap_formula_R_correct` (Phase 1)
- `prior_UZ_first_transition` (GoodStructuresModelSurgery.lean:116)
- `right_gap_class_prop` definition and properties (lines 592-659)
- `contemp_equiv_is_equiv` (GoodStructures.lean)

---

### Phase 3: Model Surgery Construction and Truth Preservation (Reynolds Lemmas 9-12) [NOT STARTED]

**Goal**: Construct the surgery model N by excising the "bad interval" (the R-region between the class of `a` and the gap) and replacing it with a single contemp_equiv class. Prove that temporal truth of all formulas is preserved between M and N for points in the surgery domain.

**Mathematical content**: This is the core of Reynolds' proof. Given the R-transition point `c` from Phase 2:
- `c` is in the class of `a` (R holds at c, so right_gap_class_prop c is true, class is succ-closed)
- `succ(c)` is NOT in the class of `a` (R is false at succ(c))
- The class of `a` restricted to [a, c] forms a convex interval by `contemp_equiv_convex`
- The surgery excises the R-region and keeps Q- (below the class), I (one representative class), Q+ (above the R-region)
- Temporal truth preservation across surgery requires case analysis for each formula constructor: atom (1 case), bot (1), imp (1), box (1), U (13 forward/backward subcases based on witness position relative to Q-/I/Q+), S (13 symmetric subcases)

**Strategy for surgery domain**: Use subtype `{x : M.carrier // x not-in bad_interval or x in I}` rather than `orderedSum`, to avoid the complexity of constructing order isomorphisms. The subtype inherits LinearOrder, SuccOrder, PredOrder from M. Predicate interpretation is inherited directly.

**Tasks**:
- [ ] **Task 3.1**: Define the surgery domain and model (~40 lines)
  ```lean
  -- The bad interval: points where R holds but are not in the representative class I
  private def bad_interval (sig : MonadicSignature) (k : Nat)
      (M : OrderedMonadicStructure sig)
      (atomMap : Formula -> sig.preds)
      (h_surj : ...) (a c : M.carrier) : Set M.carrier :=
    { x | temporal_truth M atomMap x (gap_formula_R sig k atomMap h_surj) /\
          not (contemp_equiv sig k M a x) /\ a < x /\ x <= c }

  -- Surgery domain: everything NOT in the bad interval
  private noncomputable def surgery_model (sig : MonadicSignature) (k : Nat)
      (M : OrderedMonadicStructure sig) ...
      (a c : M.carrier) : OrderedMonadicStructure sig where
    carrier := { x : M.carrier // x not-in (bad_interval sig k M atomMap h_surj a c) }
    interp p x := M.interp p x.val
    carrier_order := inferInstance  -- inherited Subtype order
  ```
  - Prove `NoMaxOrder` and `NoMinOrder` for surgery domain (Q+ and Q- are unbounded)
  - Prove `SuccOrder` and `PredOrder` for surgery domain (successor/predecessor within the subtype)

- [ ] **Task 3.2**: Prove class homogeneity in R-intervals (Reynolds Lemma 9) (~60 lines)
  ```lean
  private theorem classes_elem_equiv_in_R_interval (sig : MonadicSignature) (k : Nat)
      (M : OrderedMonadicStructure sig) ...
      (t1 t2 : M.carrier)
      (h_R_t1 : temporal_truth M atomMap t1 (gap_formula_R ...))
      (h_R_t2 : temporal_truth M atomMap t2 (gap_formula_R ...))
      (h_same_interval : ...) :
      k_equiv sig k (class_substructure M t1) (class_substructure M t2) := ...
  ```
  - All contemp_equiv classes within a maximal R-interval are k-equivalent
  - Proof: suppose formula A distinguishes classes C1 and C2. Construct B = "A occurs in my class" via expressive completeness. B transitions at a successor pair (Prior-UZ). But class boundaries in an R-interval are gaps (by definition of R = right_gap_class). Contradiction.
  - Uses `doets_lemma_1_1` (NormalForm.lean:433) for formula transfer between k-equivalent structures

- [ ] **Task 3.3**: Prove formula propagation in R-intervals (Reynolds Lemmas 10-11) (~40 lines)
  ```lean
  private theorem formula_propagation_in_R_interval (sig : MonadicSignature) (k : Nat)
      (M : OrderedMonadicStructure sig) ...
      (phi : Formula)
      (t1 t2 : M.carrier)
      (h_same_R_interval : ...)
      (h_phi_t1 : temporal_truth M atomMap t1 phi) :
      temporal_truth M atomMap t2 phi := ...
  ```
  - If formula phi holds somewhere in an R-interval, it holds throughout (by class homogeneity + Prior-UZ first-transition argument)

- [ ] **Task 3.4**: Prove surgery truth preservation -- atom/bot/imp/box cases (~20 lines)
  ```lean
  private theorem surgery_truth_atom ...
  private theorem surgery_truth_bot ...
  private theorem surgery_truth_imp ...
  private theorem surgery_truth_box ...
  ```
  - Atom: predicate interpretation inherited, trivial
  - Bot: both sides False, trivial
  - Imp: from induction hypotheses on phi, psi
  - Box: predicate interpretation inherited (box treated as predicate in OrderedMonadicStructure)

- [ ] **Task 3.5**: Prove surgery truth preservation -- U(A,B) forward direction (M to N) (~80 lines)
  ```lean
  private theorem surgery_preserve_untl_forward (sig : MonadicSignature) (k : Nat) ...
      (t : (surgery_model ...).carrier)
      (A B : Formula)
      (h_untl : temporal_truth M atomMap t.val (.untl A B)) :
      temporal_truth (surgery_model ...) atomMap_N t (.untl A B) := ...
  ```
  - 7 subcases based on position of t and witness s relative to Q-/I/Q+:
    - F1: t in Q-, s in Q- (direct, both outside surgery)
    - F2: t in Q-, s in bad interval (use class homogeneity to find witness in I)
    - F3: t in Q-, s in Q+ (B holds through bad interval by guard, transfer through I)
    - F4: t in I, s in I (direct, both in surgery domain)
    - F5: t in I, s in bad interval \ I (class homogeneity gives witness in I)
    - F6: t in I, s in Q+ (B holds through rest of I by propagation)
    - F7: t in Q+, s in Q+ (direct, both outside surgery)

- [ ] **Task 3.6**: Prove surgery truth preservation -- U(A,B) backward direction (N to M) (~60 lines)
  ```lean
  private theorem surgery_preserve_untl_backward (sig : MonadicSignature) (k : Nat) ...
      (t : (surgery_model ...).carrier)
      (A B : Formula)
      (h_untl : temporal_truth (surgery_model ...) atomMap_N t (.untl A B)) :
      temporal_truth M atomMap t.val (.untl A B) := ...
  ```
  - 6 subcases (B1-B6), symmetric to forward but transferring from N to M
  - Uses formula propagation (Lemma 11) to extend B through bad interval in M

- [ ] **Task 3.7**: Prove surgery truth preservation -- S(A,B) cases (~60 lines)
  ```lean
  private theorem surgery_preserve_snce_forward ...
  private theorem surgery_preserve_snce_backward ...
  ```
  - S is the time-reverse of U: 7 forward + 6 backward subcases
  - Mirror each U subcase with `<` replacing `>`, using `prior_SZ_last_transition` instead of `prior_UZ_first_transition`
  - Alternative: if type-theoretically clean, reduce S cases to U cases via order reversal

- [ ] **Task 3.8**: Assemble full truth preservation by structural induction on Formula (~30 lines)
  ```lean
  private theorem surgery_truth_preservation (sig : MonadicSignature) (k : Nat)
      (M : OrderedMonadicStructure sig) ...
      (t : (surgery_model ...).carrier)
      (phi : Formula) :
      temporal_truth M atomMap t.val phi <->
      temporal_truth (surgery_model ...) atomMap_N t phi := by
    induction phi with
    | atom a => exact surgery_truth_atom ...
    | bot => exact surgery_truth_bot ...
    | imp phi psi ih_phi ih_psi => exact surgery_truth_imp ... ih_phi ih_psi
    | box phi => exact surgery_truth_box ...
    | untl A B ih_A ih_B => constructor
      · exact surgery_preserve_untl_forward ...
      · exact surgery_preserve_untl_backward ...
    | snce A B ih_A ih_B => constructor
      · exact surgery_preserve_snce_forward ...
      · exact surgery_preserve_snce_backward ...
  ```

**Timing**: 8 hours

**Depends on**: 1, 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/GoodStructuresModelSurgery.lean` -- Add ~350 lines after Phase 2 additions

**Verification**:
- `lake build Bimodal.Metalogic.WeakCanonical.IntegerModel.GoodStructuresModelSurgery` succeeds
- `#check surgery_truth_preservation` type-checks
- No new sorry introduced
- Each subcase lemma (surgery_preserve_untl_F1 through F7, B1 through B6, and S equivalents) independently verifiable

**Infrastructure used**:
- `gap_formula_R_correct` (Phase 1)
- `R_first_transition` (Phase 2)
- `contemp_equiv_convex` (GoodStructuresModelSurgery.lean:247)
- `contemp_equiv_is_equiv` (GoodStructures.lean)
- `prior_UZ_first_transition` (GoodStructuresModelSurgery.lean:116)
- `prior_SZ_last_transition` (GoodStructuresModelSurgery.lean:180)
- `temporal_truth_neg_iff_not` (GoodStructuresModelSurgery.lean:90)
- `temporal_truth_neg_neg_elim` (GoodStructuresModelSurgery.lean:97)
- `doets_lemma_1_1` (NormalForm.lean:433)
- `doets_lemma_1_4` (OrderedSum.lean:34)
- `k_equiv_of_iso` (GoodStructures.lean:84)
- `cut_succ_closed` (GoodStructuresModelSurgery.lean:383)
- `complement_pred_closed` (GoodStructuresModelSurgery.lean:405)

---

### Phase 4: Contradiction Derivation and SZ Case (Reynolds Lemma 13 + Theorem 14) [NOT STARTED]

**Goal**: Use the surgery model N from Phase 3 to derive `False` for `gap_prior_UZ_contradiction`, then close `gap_prior_SZ_contradiction` via Order.dual reduction or symmetric argument.

**Mathematical content**: In the surgery model N, the representative class I ends at `succ(c)` (a successor-pair boundary, not a gap), so `right_gap_class_prop N i` is FALSE for any `i` in I. By `gap_formula_R_correct`, R is false at `i` in N. But `surgery_truth_preservation` gives `temporal_truth M atomMap i R <-> temporal_truth N atomMap_N i R`, and R is true at `i` in M (since `i` is in the class of `a` which has `right_gap_class_prop`). Contradiction.

For the SZ case: the downward argument uses `prior_SZ_last_transition` instead of `prior_UZ_first_transition`, and the surgery excises the R-interval below the class rather than above. The proof structure is identical with time-reversed orientation. Use `Order.dual` to map the SZ case to the UZ case if type class instances transfer cleanly; otherwise implement independently.

**Tasks**:
- [ ] **Task 4.1**: Prove `surgery_no_rgcp` -- right_gap_class_prop is false at representative point in surgery model (~25 lines)
  ```lean
  private theorem surgery_no_rgcp (sig : MonadicSignature) (k : Nat)
      (M : OrderedMonadicStructure sig) ...
      (i : (surgery_model ...).carrier)
      (h_i_in_class_a : contemp_equiv sig k M a i.val) :
      not (right_gap_class_prop sig k (surgery_model ...) i) := ...
  ```
  - In N, the class of `i` ends at `succ(c)` mapped into N, which is a successor-pair boundary
  - Therefore `right_gap_class_prop` fails: the class is NOT bounded above AND succ-closed (it has a successor-pair boundary, not a gap)
  - Uses the specific structure of the surgery domain (bad interval excised, so gap is replaced by successor pair)

- [ ] **Task 4.2**: Derive `gap_prior_UZ_contradiction` -- assemble the full contradiction (~40 lines)
  ```lean
  private theorem gap_prior_UZ_contradiction (sig : MonadicSignature) (k : Nat)
      (M : OrderedMonadicStructure sig)
      [SuccOrder M.carrier] [PredOrder M.carrier]
      [NoMaxOrder M.carrier] [NoMinOrder M.carrier]
      (atomMap : Formula -> sig.preds)
      (h_surj : forall p : sig.preds, exists a : Atom, atomMap (.atom a) = p)
      (h_prior_UZ : semantic_prior_UZ M atomMap)
      (h_prior_SZ : semantic_prior_SZ M atomMap)
      (a : M.carrier)
      (h_succ_closed : forall c, contemp_equiv sig k M a c ->
        contemp_equiv sig k M a (Order.succ c))
      (y : M.carrier) (hay : a < y)
      (h_not_equiv : not (contemp_equiv sig k M a y)) :
      False := by
    -- Step 1: R holds at a (Phase 1 + Phase 2)
    have h_R_a := R_holds_at_a sig k M atomMap h_surj h_prior_UZ h_prior_SZ
      a h_succ_closed y hay h_not_equiv
    -- Step 2: R is false somewhere above a (Phase 2)
    have h_not_R := R_not_holds_somewhere sig k M ...
    -- Step 3: First transition point c (Phase 2)
    obtain ⟨c, hac, h_R_c, h_not_R_succ_c⟩ := R_first_transition sig k M ... h_R_a h_not_R
    -- Step 4: Build surgery model N (Phase 3)
    let N := surgery_model sig k M atomMap h_surj a c
    -- Step 5: Pick representative i in class of a within N
    let i : N.carrier := ⟨a, ...⟩  -- a is in the surgery domain
    -- Step 6: R is true at a in M
    have h_R_M : temporal_truth M atomMap a (gap_formula_R ...) := h_R_a
    -- Step 7: Truth preservation gives R true at i in N
    have h_R_N := (surgery_truth_preservation ...).mp h_R_M
    -- Step 8: But right_gap_class_prop is false at i in N (Phase 4)
    have h_no_rgcp := surgery_no_rgcp sig k M ... i ...
    -- Step 9: gap_formula_R_correct for N gives R false at i in N
    have h_not_R_N := (gap_formula_R_correct sig k N ...).mpr.mt h_no_rgcp  -- needs adaptation
    -- Step 10: Contradiction
    exact h_not_R_N h_R_N
  ```
  - This replaces the `sorry` at line 702

- [ ] **Task 4.3**: Close `gap_prior_SZ_contradiction` -- symmetric argument for downward case (~60-100 lines)
  ```lean
  private theorem gap_prior_SZ_contradiction (sig : MonadicSignature) (k : Nat)
      (M : OrderedMonadicStructure sig) ...
      (a : M.carrier)
      (h_succ_closed : forall c, contemp_equiv sig k M a c ->
        contemp_equiv sig k M a (Order.succ c))
      (y : M.carrier) (hya : y < a)
      (h_not_equiv : not (contemp_equiv sig k M a y)) :
      False := ...
  ```
  - **Option A (Order.dual, preferred, ~60 lines)**: Apply gap_prior_UZ_contradiction to the dual order. Need to show:
    - `contemp_equiv` is preserved under Order.dual (uses min/max which are symmetric)
    - `semantic_prior_UZ` on dual <-> `semantic_prior_SZ` on original (and vice versa)
    - `right_gap_class_prop` on dual corresponds to `left_gap_class_prop` on original
    - h_succ_closed on dual follows from pred-closure (contemp_equiv_pred_closed)
  - **Option B (independent proof, fallback, ~100 lines)**: Mirror the UZ argument using `prior_SZ_last_transition` instead of `prior_UZ_first_transition`, constructing the surgery in the downward direction
  - This replaces the `sorry` at line 728

- [ ] **Task 4.4**: Verify downstream chain is sorry-free (~5 lines, verification only)
  - `#print axioms reynolds_model_surgery_core` -- no sorryAx
  - `#print axioms gap_contradicts_prior` -- no sorryAx
  - `#print axioms gap_contradicts_prior_below` -- no sorryAx
  - `#print axioms no_gaps_discrete_model_surgery` -- no sorryAx

**Timing**: 2 hours

**Depends on**: 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/GoodStructuresModelSurgery.lean` -- Replace sorry at lines 702 and 728 with completed proofs (~80-140 lines)

**Verification**:
- `lake build Bimodal.Metalogic.WeakCanonical.IntegerModel.GoodStructuresModelSurgery` succeeds
- `grep -n "sorry" GoodStructuresModelSurgery.lean` shows zero active sorry (only documentation references)
- `#print axioms no_gaps_discrete_model_surgery` shows no `sorryAx`
- `#print axioms reynolds_model_surgery_core` shows no `sorryAx`

**Infrastructure used**:
- All Phase 1-3 results
- `gap_formula_R_correct` (Phase 1)
- `surgery_truth_preservation` (Phase 3)
- `surgery_no_rgcp` (this phase)
- `contemp_equiv_pred_closed` (GoodStructuresModelSurgery.lean:288) -- for SZ case
- `prior_SZ_last_transition` (GoodStructuresModelSurgery.lean:180) -- for SZ case

## Testing & Validation

- [ ] Phase 1: `#check gap_formula_R_correct` type-checks with correct signature
- [ ] Phase 1: `#check right_gap_class_expressible` type-checks
- [ ] Phase 2: `#check R_first_transition` type-checks
- [ ] Phase 3: Each U/S subcase lemma type-checks independently
- [ ] Phase 3: `#check surgery_truth_preservation` type-checks
- [ ] Phase 4: `grep -n "sorry" GoodStructuresModelSurgery.lean` shows zero active sorry
- [ ] Phase 4: `#print axioms no_gaps_discrete_model_surgery` shows no `sorryAx`
- [ ] Phase 4: `#print axioms reynolds_model_surgery_core` shows no `sorryAx`
- [ ] Phase 4: `#print axioms gap_contradicts_prior` shows no `sorryAx`
- [ ] Phase 4: `#print axioms gap_contradicts_prior_below` shows no `sorryAx`
- [ ] Final: `lake build Bimodal.Metalogic.WeakCanonical.IntegerModel.GoodStructuresModelSurgery` succeeds with zero errors
- [ ] Final: No new sorry sites in any modified file

## Artifacts & Outputs

- `specs/202_reynolds_k_equivalence_bypass/plans/16_reynolds-model-surgery-v15.md` (this plan)
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/GoodStructuresModelSurgery.lean` (MODIFY, +~500 lines: ~100 Phase 1 + ~55 Phase 2 + ~350 Phase 3 - 2 sorry lines + ~120 Phase 4)

## Rollback/Contingency

**Phase 1**: Adds ~100 lines after line 659. If MonadicFormula construction via Classical.choice fails, fall back to explicit formula construction using NormalFormIdx Fintype enumeration. If both fail, consider enriched-signature approach (add right_gap_class as abstract predicate to sig, bypassing explicit formula construction) -- but note this approach was partially explored in prior cycles and requires careful handling to avoid the class-membership circularity. The enriched-signature approach for right_gap_class (structural property) is different from the failed enriched-signature approach for class membership.

**Phase 2**: Adds ~55 lines. Straightforward applications of existing lemmas. Low risk. Reverting removes the transition analysis infrastructure.

**Phase 3**: Adds ~350 lines (the bulk of the implementation). If U/S subcases exceed 350 lines, split into a separate file `GoodStructuresModelSurgeryTruth.lean` for truth preservation lemmas. Each subcase is an independent named lemma, so partial progress is preservable.

**Phase 4**: Replaces 2 sorry sites. If Order.dual reduction for SZ fails, implement independently using prior_SZ_last_transition (~100 additional lines vs ~60 for dual). If surgery_no_rgcp is difficult to prove directly (surgery domain structure complex), restructure the surgery domain to make the successor-pair boundary explicit in the type.

**General fallback**: If the full model surgery cannot be completed within 3 more implementation cycles, consider the axiom-elevation strategy (teammate D finding F2): elevate the two sorry sites to named `axiom` declarations, document as "unproved Reynolds lemmas awaiting formalization", and proceed with downstream engineering work (plan v14 Phases 3-5).
