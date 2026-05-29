# Implementation Plan: Reynolds Theorem 14 -- No Gaps in Discrete Prior Structures

- **Task**: 202 - Reynolds k-equivalence bypass for sorry-free completeness_discrete
- **Status**: [NOT STARTED]
- **Effort**: 20 hours
- **Dependencies**: None
- **Research Inputs**: specs/202_reynolds_k_equivalence_bypass/reports/05_reynolds-theorem-14-research.md
- **Artifacts**: plans/06_reynolds-theorem-14-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

This plan formalizes Reynolds 1994 Section 6-7 (Theorem 5, Lemmas 6-13, Theorem 14) plus the pipeline integration to close the sole remaining sorry (`no_gaps_discrete`) blocking sorry-free `completeness_discrete`. The approach is entirely semantic/model-theoretic -- it works on the already-built chronicle structure, not on Lindenbaum chains, thereby sidestepping the F-persistence obstacle that blocked plan versions 1-5.

The dependency chain is: Theorem 5 (US expressive completeness over Prior structures) enables Lemma 6 (temporal formula R detecting gap-ending classes) which enables the model surgery argument (Lemmas 7-13) which proves Theorem 14 (no gaps in contemporaneous equivalence classes) which closes `no_gaps_discrete` which makes `one_class` sorry-free which makes `chronicle_is_good_direct` sorry-free which makes `countermodel_discrete_reynolds` sorry-free which replaces `countermodel_discrete_enriched` in `completeness_discrete`.

### Research Integration

- `reports/05_reynolds-theorem-14-research.md` (plan v6 research): Identified `no_gaps_discrete` as the sole sorry, mapped the full dependency chain, estimated 700-1050 lines / 15-25 hours, identified key risks (substructure evaluation, non-constructive expressive completeness, semantic Prior hypothesis discharge).
- `reports/04_team-research.md` (plan v4 research): Confirmed F-persistence approaches are dead, Option C (direct Z completeness) blocked.
- `reports/01_reynolds-bypass-research.md` (plan v1 research): Initial infrastructure survey.

### Prior Plan Reference

Plans v1-v5 attempted direct approaches to closing `succ_cofinal` or bypassing it via enriched Henkin chains on Z. All were blocked by the fundamental impossibility of preserving F-formulas through g_content under irreflexive semantics. Plan v6 takes a completely different route: instead of building coherent chains, it proves a model-theoretic property (Theorem 14) about the already-built chronicle. This avoids Lindenbaum extensions entirely. Phase 1 of plan v4 (`henkin_bfmcs`, 426 lines) remains useful infrastructure but is NOT on the critical path for v6.

### Roadmap Alignment

No ROADMAP.md found.

## Goals & Non-Goals

**Goals**:
- Prove `stavi_U_false_on_prior`: U'(A,B) is always false on Prior structures (Reynolds 1994, Theorem 5, p.123-124)
- Prove `stavi_S_false_on_prior`: S'(A,B) is always false on Prior structures (mirror of above)
- Derive `US_expressively_complete_over_prior`: {U,S} is expressively complete for Prior structures (Reynolds 1994, Theorem 5, p.123-124)
- Formalize Lemmas 6-13 (Reynolds 1994, pp.124-129): gap formula R, R-interval properties, model surgery
- Prove `no_gaps_discrete` (Reynolds 1994, Theorem 14, p.129): contemporaneous equivalence classes do not end at gaps
- Discharge semantic Prior-UZ/SZ hypotheses in `chronicle_is_good_direct` (currently sorry'd)
- Close `countermodel_discrete_reynolds` pipeline sorry (Transfer.lean:866)
- Rewire `completeness_discrete` to use `countermodel_discrete_reynolds`
- Achieve `#print axioms completeness_discrete` with no `sorryAx`

**Non-Goals**:
- Proving `succ_cofinal` or `succ_embed_surjective` (bypassed entirely by Reynolds pipeline)
- Modifying the dense completeness path
- Optimizing existing sorry-free proofs
- Archiving dead BXCanonical code (task 176 scope)
- The `henkin_bfmcs` infrastructure from plan v4 Phase 1 (orthogonal to this plan)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `stavi_expressive_completeness` returns existential (Classical.choice), R not computable | M | M | Reynolds' proof only needs existence of R, not a computable R. The model surgery argument is semantic. If needed, wrap R handling in `Classical.choose`. |
| Substructure evaluation: temporal_truth in M\|S may not agree with restricted evaluation | H | L | `GoodStructures.lean` already has `subinterval`. Verify that `temporal_truth` on substructure agrees with `temporal_truth` on parent restricted to subinterval domain. May need ~50 lines of bridge lemmas. |
| Semantic Prior-UZ discharge for chronicle: `chronicle_temporal_truth` needs section property | M | L | The section property (`atomMap_rev (atomMap_fwd f) = f` for relevant f) is established at the call site in `countermodel_discrete_reynolds` (Transfer.lean:831-838). Thread it through to `chronicle_is_good_direct`. |
| Model surgery (Lemma 12) case analysis is large (~300 lines) | L | H | Reynolds gives every case explicitly (7 forward, 6 backward for U(A,B)). Follow the paper case-by-case. This is tedious but straightforward. |
| FUC termination: BX5 deferral on Until within surgery model | M | L | The model surgery preserves all temporal truth (Lemma 12). BX5 deferral is a property of the temporal logic, not the model construction. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5 | 4 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Theorem 5 -- US Expressive Completeness over Prior Structures [NOT STARTED]

**Goal**: Prove that {U,S} is expressively complete for Prior structures. This is the foundational result enabling all subsequent phases.

**Literature**: Reynolds 1994, Theorem 5, pp.123-124. Also GHR93/94 Theorem 9.3.1 (Stavi completeness, already formalized as `stavi_expressive_completeness`), and GHR94 Theorem 4 ({U,S,U',S'} expressively complete for all linear structures, already formalized as `stavi_expressive_completeness`).

**Proof Strategy** (Reynolds p.123-124): By the expressive completeness of {U,S,U',S'} over all linear structures (Theorem 4 = `stavi_expressive_completeness`), it suffices to prove that for any {U,S,U',S'}-formula B', there is a {U,S}-formula B such that B' <-> B is valid in all Prior structures. By induction on formula construction: atoms, boolean, U, S cases are immediate. For U'(A,B): show U'(A,B) <-> bot in all Prior structures. Proof: Suppose M |= U'(A,B)(t) in some Prior structure M. Then B holds for a while up until a gap, after which ~B is true arbitrarily soon. By Prior-U applied to B: M |= U(~B V K+(~B), B)(t), contradiction (K+(~B) means ~B arbitrarily soon, which combined with U gives a first point of ~B, but Prior-U says either last B or first ~B with K-(B), and the gap structure contradicts both). S' is symmetric via Prior-S.

**Tasks**:
- [ ] **Task 1.1**: Define `stavi_U_false_on_prior` in a new file `Theories/Bimodal/Metalogic/WeakCanonical/PriorExpressiveness.lean` (~80 lines)
  ```lean
  theorem stavi_U_false_on_prior {sig : MonadicSignature}
      (M : OrderedMonadicStructure sig)
      [SuccOrder M.carrier] [PredOrder M.carrier]
      [NoMaxOrder M.carrier] [NoMinOrder M.carrier]
      (atomMap : Formula → sig.preds)
      (h_prior_UZ : ∀ (t : M.carrier) (ψ : Formula),
        (∃ s, t < s ∧ temporal_truth M atomMap s ψ) →
        ∃ s, t < s ∧ temporal_truth M atomMap s ψ ∧
          ∀ r, t < r → r < s → temporal_truth M atomMap r ψ.neg)
      (t : M.carrier) (A B : Formula) :
      ¬ stavi_U_truth M atomMap t A B
  ```
  Proof by contradiction. Assume `stavi_U_truth M atomMap t A B`. Extract the three witnesses from the definition: the main body, B-failure, and B-initial-segment. Apply h_prior_UZ to B at t: get `s` with `B(s)` and `¬B` on `(t,s)`, or `U(B, ¬B)` structure. The gap structure from U' contradicts the first-occurrence structure from Prior-UZ. Reference: Reynolds 1994, p.123, proof of Theorem 5, U' case.

- [ ] **Task 1.2**: Define `stavi_S_false_on_prior` (mirror of 1.1, ~80 lines)
  ```lean
  theorem stavi_S_false_on_prior {sig : MonadicSignature}
      (M : OrderedMonadicStructure sig)
      [SuccOrder M.carrier] [PredOrder M.carrier]
      [NoMaxOrder M.carrier] [NoMinOrder M.carrier]
      (atomMap : Formula → sig.preds)
      (h_prior_SZ : ∀ (t : M.carrier) (ψ : Formula),
        (∃ s, s < t ∧ temporal_truth M atomMap s ψ) →
        ∃ s, s < t ∧ temporal_truth M atomMap s ψ ∧
          ∀ r, s < r → r < t → temporal_truth M atomMap r ψ.neg)
      (t : M.carrier) (A B : Formula) :
      ¬ stavi_S_truth M atomMap t A B
  ```
  Reference: Reynolds 1994, p.124, dual of Theorem 5 proof.

- [ ] **Task 1.3**: Derive `flatten_stavi_correct_prior` -- the analogue of `flatten_stavi_correct` using Prior-UZ/SZ instead of `IsSuccArchimedean` (~60 lines)
  ```lean
  theorem flatten_stavi_correct_prior {sig : MonadicSignature}
      (M : OrderedMonadicStructure sig)
      [SuccOrder M.carrier] [PredOrder M.carrier]
      [NoMaxOrder M.carrier] [NoMinOrder M.carrier]
      (atomMap : Formula → sig.preds)
      (h_prior_UZ : ...) (h_prior_SZ : ...)
      (t : M.carrier) (sf : StaviFormula) :
      stavi_temporal_truth M atomMap t sf ↔
      temporal_truth M atomMap t (flatten_stavi sf)
  ```
  Proof by induction on sf. The existing `flatten_stavi_correct` handles all cases except U'/S' via `IsSuccArchimedean`. Here, the U' case uses `stavi_U_false_on_prior` (both sides false), and the S' case uses `stavi_S_false_on_prior`. All other cases are identical to the existing proof. Reference: Reynolds 1994, Theorem 5 combined with GHR93 Theorem 9.3.1.

- [ ] **Task 1.4**: Derive `US_expressively_complete_over_prior` -- compose `stavi_expressive_completeness` with `flatten_stavi_correct_prior` (~40 lines)
  ```lean
  noncomputable def US_expressively_complete_over_prior
      {sig : MonadicSignature}
      (atomMap : Formula → sig.preds)
      (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
      (h_prior_UZ : ...) (h_prior_SZ : ...)
      (psi : MonadicFormula sig 1) :
      { A : Formula //
        ∀ (t : M.carrier),
          eval M (fun _ => t) psi ↔
          temporal_truth M atomMap t A }
  ```
  Given any monadic FO formula psi, use `stavi_expressive_completeness` to get StaviFormula sf with sf <-> psi, then `flatten_stavi sf` gives a {U,S}-formula with the same truth via `flatten_stavi_correct_prior`. Reference: Reynolds 1994, Theorem 5, composition step.

**Timing**: 4 hours

**Depends on**: none

**Files to modify/create**:
- `Theories/Bimodal/Metalogic/WeakCanonical/PriorExpressiveness.lean` (NEW, ~260 lines) -- Theorem 5 and its components

**Verification**:
- `lake build Bimodal.Metalogic.WeakCanonical.PriorExpressiveness` succeeds
- `#print axioms stavi_U_false_on_prior` shows no `sorryAx`
- `#print axioms US_expressively_complete_over_prior` shows no `sorryAx`

---

### Phase 2: Lemmas 6-9 -- Gap Formula R and R-Interval Properties [NOT STARTED]

**Goal**: Define the temporal formula R that detects gap-ending equivalence classes, and prove its structural properties. This establishes the setting for the model surgery argument.

**Literature**: Reynolds 1994, Section 7, pp.124-127, Lemmas 6-9.

**Proof Strategy**: Define the FO formula rho(x) = "x's ~M-class ends in a gap on the right" (Reynolds p.125). Use `US_expressively_complete_over_prior` (Phase 1) to get temporal formula R equivalent to rho in any Prior structure. Then prove R-intervals are open with excluded endpoints (Lemma 7, using Prior-U), no first/last class in R-intervals (Lemma 8, using Prior-U), and elementary equivalence of classes within R-intervals (Lemma 9, using expressive completeness + Prior-U).

**Tasks**:
- [ ] **Task 2.1**: Define `rho_formula` -- the FO formula rho(x) = "x's ~M-class ends in a gap on the right" (~40 lines)
  ```lean
  def rho_formula {sig : MonadicSignature} (epsilon : MonadicFormula sig 2) :
      MonadicFormula sig 1
  ```
  Formally: rho(x) := exists y > x, ~epsilon(x,y) AND exists z > y such that epsilon(z,z) (there is a class after the gap) AND forall y' with x < y' < y, epsilon(x,y') (x is equiv to everything up to the gap). Reference: Reynolds 1994, p.125, definition above Lemma 6.

- [ ] **Task 2.2**: Define `gap_formula_R` and `gap_formula_L` -- temporal equivalents of rho and its mirror (~30 lines)
  ```lean
  noncomputable def gap_formula_R {sig : MonadicSignature}
      (M : OrderedMonadicStructure sig) (atomMap : ...) (h_prior : ...)
      (epsilon : MonadicFormula sig 2) : Formula
  noncomputable def gap_formula_L {sig : MonadicSignature}
      (M : OrderedMonadicStructure sig) (atomMap : ...) (h_prior : ...)
      (epsilon : MonadicFormula sig 2) : Formula
  ```
  Apply `US_expressively_complete_over_prior` to `rho_formula epsilon` and its mirror. The result R holds at t iff t's ~M-class ends in a gap on the right. L is the mirror for left gaps. Reference: Reynolds 1994, Lemma 6, p.125.

- [ ] **Task 2.3**: Prove `gap_formula_R_correct` -- R holds exactly where rho holds (~60 lines)
  ```lean
  theorem gap_formula_R_correct : ∀ (t : M.carrier),
      temporal_truth M atomMap t R ↔ rho_holds M epsilon t
  ```
  Direct from the expressive completeness result. Reference: Reynolds 1994, Lemma 6.

- [ ] **Task 2.4**: Prove `R_intervals_open` (Lemma 7) -- maximal R-intervals are open with excluded endpoints (~100 lines)
  ```lean
  theorem R_intervals_open (t : M.carrier) (h_R : temporal_truth M atomMap t R) :
      ∃ (a b : M.carrier), a < t ∧ t < b ∧
        (∀ u, a < u → u < b → temporal_truth M atomMap u R) ∧
        ¬ temporal_truth M atomMap a R ∧ ¬ temporal_truth M atomMap b R
  ```
  Proof: R at t implies rho at t, which implies t is in a non-singleton interval. Use Prior-U on R: either R holds forever after t, or there is a last R point (impossible given gap structure) or a first ~R point (giving the right endpoint). Similarly for the left endpoint using Prior-S. The left endpoint cannot be a first point of R with K-(~R) -- this would create a class whose gap structure contradicts Prior-U applied to a formula B expressing "in a class that begins with R AND K-(~R)". Reference: Reynolds 1994, Lemma 7, pp.125-126.

- [ ] **Task 2.5**: Prove `R_no_first_last_class` (Lemma 8) -- no first or last ~M-class in any maximal R-interval (~60 lines)
  ```lean
  theorem R_no_first_last_class (...) :
      -- No first class: for any class in a maximal R-interval,
      -- there exists an earlier class in the same interval
      ...
  ```
  Proof: The formula "in the first class of a maximal R-interval" is temporal (by expressive completeness). If such a first class exists, this formula holds up to a gap and is false arbitrarily soon after -- contradicting Prior-U. Reference: Reynolds 1994, Lemma 8, pp.126-127.

- [ ] **Task 2.6**: Prove `R_classes_elem_equiv` (Lemma 9) -- ~M-classes in R-intervals are elementarily equivalent (~80 lines)
  ```lean
  theorem R_classes_elem_equiv (...) :
      -- For any monadic sentence, it holds in ALL classes of a maximal
      -- R-interval or in NONE of them
      ...
  ```
  Proof in two parts. Part 1: If a temporal formula holds somewhere in one class but not in another class of the same R-interval, use expressive completeness to find B true throughout classes containing the formula and false throughout classes not containing it. Apply Prior-U to B to get contradiction. Part 2: Relativize any monadic sentence to ~M-classes, convert to temporal formula via expressive completeness, then apply Part 1. Reference: Reynolds 1994, Lemma 9, pp.126-127.

**Timing**: 5 hours

**Depends on**: 1

**Files to modify/create**:
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/ReynoldsNoGaps.lean` (NEW, ~370 lines) -- Lemmas 6-9

**Verification**:
- `lake build Bimodal.Metalogic.WeakCanonical.IntegerModel.ReynoldsNoGaps` succeeds
- `#print axioms R_intervals_open` shows no `sorryAx`
- `#print axioms R_classes_elem_equiv` shows no `sorryAx`

---

### Phase 3: Lemmas 10-13 -- Model Surgery [NOT STARTED]

**Goal**: Define bad points and bad intervals, prove the model surgery lemma (replacing a bad interval by one of its ~M-classes preserves temporal truth), and derive that no bad points exist.

**Literature**: Reynolds 1994, Section 7, pp.127-129, Lemmas 10-13.

**Proof Strategy**: A "bad point" is where R V L holds (the class ends at a gap on at least one side). A "bad interval" is a maximal connected interval of bad points. Lemma 10: bad points only occur in non-singleton bad intervals, both R and L hold throughout, excluded endpoints. Lemma 11: formulas true at the start/end of a class in a bad interval hold throughout the interval. Lemma 12 (KEY): replace a bad interval Qo by one of its ~M-classes I; temporal truth is preserved in the resulting substructure Q- U I U Q+ (induction on formula, 13 cases for U(A,B)). Lemma 13: the surgery model N is also a Prior structure where R holds in I, but I's class in N cannot end at a gap (bounded by the excluded endpoint q of Q+), contradiction.

**Tasks**:
- [ ] **Task 3.1**: Define `bad_point` and `bad_interval` (~30 lines)
  ```lean
  def bad_point (t : M.carrier) : Prop :=
      temporal_truth M atomMap t R ∨ temporal_truth M atomMap t L
  def bad_interval (a b : M.carrier) : Prop :=
      a < b ∧ (∀ u, a ≤ u → u ≤ b → bad_point u) ∧ ... -- maximal
  ```
  Reference: Reynolds 1994, p.127, definition above Lemma 10.

- [ ] **Task 3.2**: Prove `bad_points_in_intervals` (Lemma 10) -- bad points only in non-singleton intervals, R and L hold throughout, excluded endpoints (~80 lines)
  Proof: Show L holds wherever R does by contradiction: if some class in an R-interval has ~L, then either it includes its left endpoint (contradicting gap structure) or it starts just after a point r whose class cannot end at a gap (since r is its right endpoint). Then use Prior-U on a formula describing "not left endpoint of class". Reference: Reynolds 1994, Lemma 10, pp.127-128.

- [ ] **Task 3.3**: Prove `bad_interval_propagation` (Lemma 11) -- formula true at start of class holds throughout bad interval (~60 lines)
  Proof: If B holds for a while at start of a class but ~B holds somewhere in the bad interval, then ~B also holds in the same class (by Lemma 9). Find temporal C expressing "in a class after some ~B". C is true at end of class, false after gap. Contradicts Prior-U. Reference: Reynolds 1994, Lemma 11, pp.127-128.

- [ ] **Task 3.4**: Define `surgery_model` -- substructure Q- U I U Q+ (~50 lines)
  ```lean
  noncomputable def surgery_model (Q_minus I Q_plus : Set M.carrier) : 
      OrderedMonadicStructure sig
  ```
  Given a bad interval Qo and one of its ~M-classes I, form the substructure on Q- U I U Q+ where Q- = all points before Qo, Q+ = all points after Qo. Reference: Reynolds 1994, p.128, definition above Lemma 12.

- [ ] **Task 3.5**: Prove `surgery_preserves_truth` (Lemma 12) -- temporal truth preserved in surgery model (~200 lines)
  ```lean
  theorem surgery_preserves_truth (A : Formula) (t : N.carrier) :
      temporal_truth M atomMap t A ↔ temporal_truth N atomMap t A
  ```
  Proof by induction on formula A. Atomic and boolean cases immediate. For U(A,B): 13 cases based on locations of t and the Until witness s in Q-, I, or Q+. Cases 1,4,7 (both in same region): apply IH directly. Cases 2,3 (t in Q-, s in Qo or Q+): use Lemma 9 (elementary equivalence) to transfer A-witness from Qo to I, and Lemma 11 (propagation) to show B throughout. Cases 5,6 (t in I, s later in Qo or Q+): similarly use Lemma 9 for A and Lemma 11 for B. The reverse direction (N |= U -> M |= U) has 6 cases (mirror of the forward). Reference: Reynolds 1994, Lemma 12, pp.128-129.

- [ ] **Task 3.6**: Prove `no_bad_points` (Lemma 13) -- bad points cannot exist in any Prior structure (~80 lines)
  ```lean
  theorem no_bad_points (M : OrderedMonadicStructure sig)
      (h_prior_UZ : ...) (h_prior_SZ : ...) :
      ∀ (t : M.carrier), ¬ bad_point t
  ```
  Proof by contradiction. Assume bad point exists. Take a bad interval Qo containing it, choose any ~M-class I in Qo. Form surgery model N = Q- U I U Q+. By Lemma 12, R holds in I in N. But N is a Prior structure (any counterexample to Prior-U in N is also one in M). By Lemma 6, R holds iff class ends at gap. I's class in N is bounded above (Q+ is non-empty by Lemma 7, starts at excluded endpoint q). So I's class ends at q, not at a gap. Contradiction with R holding in I. Reference: Reynolds 1994, Lemma 13, p.129.

**Timing**: 6 hours

**Depends on**: 2

**Files to modify/create**:
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/ReynoldsNoGaps.lean` (EXTEND, ~500 lines added) -- Lemmas 10-13

**Verification**:
- `#print axioms surgery_preserves_truth` shows no `sorryAx`
- `#print axioms no_bad_points` shows no `sorryAx`

---

### Phase 4: Theorem 14 + Close `no_gaps_discrete` [NOT STARTED]

**Goal**: Prove Theorem 14 (no gaps in contemporaneous equivalence classes) and close the `no_gaps_discrete` sorry in GoodStructures.lean. Also close the secondary sorries in `chronicle_is_good_direct` (semantic Prior hypothesis discharge).

**Literature**: Reynolds 1994, Theorem 14, p.129; also p.131, Theorem 15 integration.

**Proof Strategy**: Theorem 14 follows immediately from `no_bad_points` (Lemma 13): if some ~M-class ended at a gap, then R would hold at points of that class (by definition of R), making those points bad -- contradiction. The discrete form `no_gaps_discrete` follows: given a ≁ b, if no boundary c exists with a ~ c and a ≁ succ(c), then a's class has no successor boundary, which in a discrete order means it extends indefinitely -- but it cannot reach b (contradiction with a ≁ b). The gap at the class boundary would make points bad, contradicting Theorem 14.

**Tasks**:
- [ ] **Task 4.1**: Prove `theorem_14` -- no gaps in contemporaneous equivalence on Prior structures (~60 lines)
  ```lean
  theorem theorem_14 {sig : MonadicSignature}
      (M : OrderedMonadicStructure sig)
      [SuccOrder M.carrier] [PredOrder M.carrier]
      [NoMaxOrder M.carrier] [NoMinOrder M.carrier]
      (atomMap : Formula → sig.preds)
      (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
      (h_prior_UZ : ...) (h_prior_SZ : ...)
      (k : Nat) (a b : M.carrier) (h_diff : ¬ contemp_equiv sig k M a b) :
      ∃ c, contemp_equiv sig k M a c ∧ ¬ contemp_equiv sig k M a (Order.succ c)
  ```
  Proof: By `no_bad_points`, no point is bad, so no ~M-class ends at a gap. Since a ≁ b, the class of a is bounded (does not contain b). Since it does not end at a gap, it must end at a successor boundary: ∃c with a ~ c and a ≁ succ(c). Reference: Reynolds 1994, Theorem 14, p.129.

- [ ] **Task 4.2**: Replace the sorry in `no_gaps_discrete` (GoodStructures.lean:842) with a call to `theorem_14` (~30 lines)
  The signature of `no_gaps_discrete` already matches `theorem_14`. Need to verify that the hypotheses align. The `atomMap` and `h_surj` parameters may need to be added to `no_gaps_discrete` or threaded through from `one_class`. Reference: Reynolds 1994, Theorem 14 applied in Theorem 15 (p.131).

- [ ] **Task 4.3**: Close the secondary sorries in `chronicle_is_good_direct` (ShiftAndGlue.lean:984, 990) -- discharge semantic Prior-UZ/SZ for the chronicle (~80 lines)
  The chronicle structure satisfies Prior-UZ syntactically: every MCS contains the Prior-UZ axiom instances. Use `chronicle_temporal_truth` to convert between MCS membership and `temporal_truth`. The section property (`atomMap_rev (atomMap_fwd f) = f`) is established at the call site in `countermodel_discrete_reynolds`. Either: (a) add the section property as a parameter to `chronicle_is_good_direct` and thread it from the caller, or (b) prove a weaker version of the semantic Prior-UZ that holds without section property (using the fact that the chronicle's coherence conditions directly imply the required ordering structure).

- [ ] **Task 4.4**: Verify `one_class` is now sorry-free -- `#print axioms one_class` shows no `sorryAx` (~5 lines)

**Timing**: 3 hours

**Depends on**: 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/GoodStructures.lean` -- replace sorry in `no_gaps_discrete` with call to `theorem_14`
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/ShiftAndGlue.lean` -- close sorries in `chronicle_is_good_direct`
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/ReynoldsNoGaps.lean` -- add `theorem_14` (if not placed in GoodStructures)

**Verification**:
- `#print axioms no_gaps_discrete` shows no `sorryAx`
- `#print axioms one_class` shows no `sorryAx`
- `#print axioms chronicle_is_good_direct` shows no `sorryAx`

---

### Phase 5: Pipeline Completion and Verification [NOT STARTED]

**Goal**: Close the `countermodel_discrete_reynolds` sorry (Transfer.lean:866), rewire `completeness_discrete` to use the Reynolds pipeline, and verify the full project builds sorry-free for `completeness_discrete`.

**Literature**: Reynolds 1994, Section 8, pp.130-131 (Theorem 15 usage in completeness proof). GHR94 Chapter 10 (integer completeness proof structure).

**Proof Strategy**: The sorry at Transfer.lean:866 is pipeline packaging: showing the Z-interval from `chronicle_is_good_direct` is unbounded (lo = none, hi = none) since the chronicle is unbounded, constructing the TaskModel, and proving truth_at <-> temporal_truth. Then replace `countermodel_discrete_enriched` in `completeness_discrete` (BXCanonical/Completeness.lean:368) with `countermodel_discrete_reynolds`.

**Tasks**:
- [ ] **Task 5.1**: Close the sorry in `countermodel_discrete_reynolds` (Transfer.lean:866) -- prove the Z-interval is unbounded, construct TaskModel, prove truth correspondence (~120 lines)
  Steps:
  (a) Show the Z-interval from `good` applied to the unbounded chronicle has `lo = none, hi = none` (the `very_good_implies_good` construction via cofinal decomposition preserves unboundedness)
  (b) Construct `TaskModel Int` with atom valuation from Z-interval's predicate interpretation
  (c) Prove `truth_at TM Omega tau t phi <-> temporal_truth Z_struct atomMap t phi` for formulas in the subformula closure of phi
  (d) Use the already-established `h_neg_Z` (Transfer.lean:847) to conclude `¬truth_at TM Omega tau s phi`

- [ ] **Task 5.2**: Rewire `completeness_discrete` to use `countermodel_discrete_reynolds` (~30 lines)
  In BXCanonical/Completeness.lean, line 368: replace the call to `countermodel_discrete_enriched` with `countermodel_discrete_reynolds`. The signatures are compatible (both produce `∃ (F : TaskFrame Int) (TM : TaskModel F) ...`). May need minor adaptation if the type of the existence quantifier differs (e.g., `countermodel_discrete_reynolds` returns `∃ (D : Type) ...` while `countermodel_discrete_enriched` returns `∃ (F : TaskFrame Int) ...`).

- [ ] **Task 5.3**: Full build verification (~10 lines)
  - `lake build` -- full project, zero errors
  - `#print axioms completeness_discrete` -- no `sorryAx`
  - `#print axioms Bimodal.Metalogic.BXCanonical.completeness` -- verify the general completeness theorem benefits
  - `grep -r "sorry" Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/` -- no sorry in the Reynolds pipeline files
  - `grep -r "sorry" Theories/Bimodal/Metalogic/WeakCanonical/PriorExpressiveness.lean` -- no sorry

- [ ] **Task 5.4**: Update docstrings in Completeness.lean, Transfer.lean, GoodStructures.lean, and ShiftAndGlue.lean to reflect sorry-free status (~20 lines)

**Timing**: 2 hours

**Depends on**: 4

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Transfer.lean` -- close sorry at line 866
- `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` -- rewire `completeness_discrete`
- Various files -- update docstrings

**Verification**:
- `lake build` passes with zero errors
- `#print axioms completeness_discrete` shows `{propext, Classical.choice, Lean.ofReduceBool, Lean.trustCompiler, Quot.sound}` -- no `sorryAx`
- No new sorry sites in any modified files

## Testing & Validation

- [ ] `#print axioms stavi_U_false_on_prior` shows no `sorryAx`
- [ ] `#print axioms US_expressively_complete_over_prior` shows no `sorryAx`
- [ ] `#print axioms R_intervals_open` shows no `sorryAx`
- [ ] `#print axioms R_classes_elem_equiv` shows no `sorryAx`
- [ ] `#print axioms surgery_preserves_truth` shows no `sorryAx`
- [ ] `#print axioms no_bad_points` shows no `sorryAx`
- [ ] `#print axioms no_gaps_discrete` shows no `sorryAx`
- [ ] `#print axioms one_class` shows no `sorryAx`
- [ ] `#print axioms chronicle_is_good_direct` shows no `sorryAx`
- [ ] `#print axioms countermodel_discrete_reynolds` shows no `sorryAx`
- [ ] `#print axioms completeness_discrete` shows no `sorryAx`
- [ ] `lake build` passes with zero errors
- [ ] No new sorry sites introduced (grep across all modified/created files)
- [ ] Existing dense completeness path unaffected (`#print axioms completeness_dense` unchanged)

## Artifacts & Outputs

- `specs/202_reynolds_k_equivalence_bypass/plans/06_reynolds-theorem-14-plan.md` (this plan)
- `Theories/Bimodal/Metalogic/WeakCanonical/PriorExpressiveness.lean` (NEW) -- Theorem 5
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/ReynoldsNoGaps.lean` (NEW) -- Lemmas 6-13, Theorem 14
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/GoodStructures.lean` (MODIFIED) -- sorry closed in `no_gaps_discrete`
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/ShiftAndGlue.lean` (MODIFIED) -- sorries closed in `chronicle_is_good_direct`
- `Theories/Bimodal/Metalogic/WeakCanonical/Transfer.lean` (MODIFIED) -- sorry closed in `countermodel_discrete_reynolds`
- `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` (MODIFIED) -- `completeness_discrete` rewired

## Rollback/Contingency

All new code goes into new files (`PriorExpressiveness.lean`, `ReynoldsNoGaps.lean`). Existing files are only modified in Phases 4-5 (sorry replacement and rewiring). Reverting Phase 5 (the rewiring in Completeness.lean) restores the previous state completely. Reverting Phase 4 (sorry replacement in GoodStructures.lean and ShiftAndGlue.lean) is a single-line `sorry` restoration per site.

If the model surgery argument (Phase 3, Lemma 12) proves too large:
1. Break the 13 cases into individual lemmas (e.g., `surgery_case_Q_minus_to_Q_minus`, `surgery_case_Q_minus_to_I`, etc.)
2. Use the existing `subinterval` infrastructure from GoodStructures.lean for substructure handling
3. If the substructure evaluation bridge is problematic, define a specialized `temporal_truth_on_subset` that restricts quantifiers to a subset

If Phase 1 (Theorem 5) encounters unexpected difficulties with the Prior-U contradiction argument:
1. The existing `flatten_stavi_correct` proof gives a template -- the only change is replacing `IsSuccArchimedean` well-founded descent with Prior-UZ contradiction
2. The `stavi_U_truth` definition (StaviConnectives.lean:74-91) is explicit and well-documented
3. Fallback: prove U' false on DISCRETE Prior structures specifically (using the fact that in discrete orders, the "gap" in U' cannot exist between successive elements), then argue that the chronicle IS discrete
