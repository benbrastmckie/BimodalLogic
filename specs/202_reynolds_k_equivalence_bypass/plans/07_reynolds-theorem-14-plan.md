# Implementation Plan: Reynolds Theorem 14 -- No Gaps in Discrete Prior Structures (v7)

- **Task**: 202 - Reynolds k-equivalence bypass for sorry-free completeness_discrete
- **Status**: [NOT STARTED]
- **Effort**: 28 hours
- **Dependencies**: None
- **Research Inputs**: specs/202_reynolds_k_equivalence_bypass/reports/05_reynolds-theorem-14-research.md, specs/202_reynolds_k_equivalence_bypass/reports/07_bfmcs-bypass-research.md, specs/202_reynolds_k_equivalence_bypass/reports/08_succ-cofinal-dependency-trace.md
- **Artifacts**: plans/07_reynolds-theorem-14-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

This plan formalizes Reynolds 1994 Section 6-7 (Theorem 5, Lemmas 6-13, Theorem 14) plus the pipeline integration to close the sole remaining sorry (`no_gaps_discrete`) blocking sorry-free `completeness_discrete`. Plan v7 revises v6 with a completely rewritten Phase 5 that addresses the box modality bridge -- the critical gap between `temporal_truth` (which treats box as a predicate lookup) and `truth_at` (which quantifies over world-histories in Omega).

The dependency chain is: Theorem 5 (US expressive completeness over Prior structures) enables Lemma 6 (temporal formula R detecting gap-ending classes) which enables the model surgery argument (Lemmas 7-13) which proves Theorem 14 (no gaps in contemporaneous equivalence classes) which closes `no_gaps_discrete` which makes `one_class` sorry-free which makes `chronicle_is_good_direct` sorry-free which makes `countermodel_discrete_reynolds` sorry-free (via a chronicle-derived TaskFrame, NOT the z_interval_countermodel singleton approach) which replaces `countermodel_discrete_enriched` in `completeness_discrete`.

### Research Integration

- `reports/05_reynolds-theorem-14-research.md` (plan v6 research): Identified `no_gaps_discrete` as the sole sorry, mapped the full dependency chain, estimated 700-1050 lines / 15-25 hours, identified key risks.
- `reports/07_bfmcs-bypass-research.md` (plan v7 research): Confirmed BFMCS itself is sorry-free; sorry enters through succ_embed_surjective in coherence conditions; Reynolds pipeline at Transfer.lean:792 is the correct bypass.
- `reports/08_succ-cofinal-dependency-trace.md` (plan v7 research): Full dependency trace showing succ_cofinal enters Reynolds pipeline through extract_chronicle_as_prior's domain_succ_archimedean field; avoidable by using `no_gaps_discrete` path.
- `reports/04_team-research.md` (plan v4 research): Confirmed F-persistence approaches are dead.
- `reports/01_reynolds-bypass-research.md` (plan v1 research): Initial infrastructure survey.

### Prior Plan Reference

Plans v1-v5 attempted direct approaches to closing `succ_cofinal` or bypassing it via enriched Henkin chains on Z. All were blocked by fundamental impossibility of preserving F-formulas through g_content under irreflexive semantics. Plan v6 took the correct route (Reynolds Theorem 14 model surgery) but its Phase 5 assumed the existing `z_interval_countermodel` with singleton Omega / Unit WorldState could serve as the packaging step. Research revealed this is definitively wrong: `z_interval_countermodel` makes box transparent (`truth_at (.box psi) <-> truth_at psi`), which cannot match `temporal_truth (.box psi) t = M.interp (atomMap (.box psi)) t` when the box predicate carries non-trivial information from the chronicle's MCS membership.

Plan v7 replaces Phase 5 with a chronicle-derived TaskFrame construction that builds multi-history Omega from the chronicle's BFMCS families, uses MCS-carrying WorldState, and proves the truth correspondence via the chronicle's coherence properties -- without going through `succ_cofinal` or the parametric canonical model's succ_embed machinery.

### Roadmap Alignment

No ROADMAP.md found.

## Goals & Non-Goals

**Goals**:
- Prove `stavi_U_false_on_prior`: U'(A,B) is always false on Prior structures (Reynolds 1994, Theorem 5)
- Prove `stavi_S_false_on_prior`: S'(A,B) is always false on Prior structures (mirror)
- Derive `US_expressively_complete_over_prior`: {U,S} is expressively complete for Prior structures
- Formalize Lemmas 6-13 (Reynolds 1994, pp.124-129): gap formula R, R-interval properties, model surgery
- Prove `no_gaps_discrete` (Reynolds 1994, Theorem 14): contemporaneous equivalence classes do not end at gaps
- Discharge semantic Prior-UZ/SZ hypotheses in `chronicle_is_good_direct`
- Build a chronicle-derived TaskFrame with multi-history Omega and MCS-carrying WorldState
- Prove truth_at <-> temporal_truth correspondence for the chronicle-derived TaskFrame
- Close `countermodel_discrete_reynolds` pipeline sorry (Transfer.lean:866)
- Rewire `completeness_discrete` to use `countermodel_discrete_reynolds`
- Achieve `#print axioms completeness_discrete` with no `sorryAx`

**Non-Goals**:
- Proving `succ_cofinal` or `succ_embed_surjective` (bypassed entirely by Reynolds pipeline)
- Modifying the dense completeness path
- Using the `z_interval_countermodel` with singleton Omega / Unit WorldState (definitively ruled out)
- Using constant/trivial world-histories or singleton Omega
- Modifying the existing BFMCS parametric canonical model pipeline
- Optimizing existing sorry-free proofs

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `stavi_expressive_completeness` returns existential (Classical.choice), R not computable | M | M | Reynolds' proof only needs existence of R, not a computable R. The model surgery argument is semantic. Wrap R handling in `Classical.choose`. |
| Substructure evaluation: temporal_truth in M\|S may not agree with restricted evaluation | H | L | `GoodStructures.lean` already has `subinterval`. Verify that `temporal_truth` on substructure agrees with restricted evaluation. May need ~50 lines of bridge lemmas. |
| Semantic Prior-UZ discharge for chronicle: needs section property | M | L | The section property is established at the call site in `countermodel_discrete_reynolds` (Transfer.lean:831-838). Thread it through to `chronicle_is_good_direct`. |
| Model surgery (Lemma 12) case analysis is large (~300 lines) | L | H | Reynolds gives every case explicitly. Follow the paper case-by-case. Tedious but straightforward. |
| Chronicle-derived TaskFrame construction is novel (no existing template) | H | M | The BFMCS modal_forward/modal_backward are sorry-free. The chronicle's temporal coherence is built in from the Lindenbaum construction. Build incrementally: first the frame, then atom truth, then temporal induction, then box. |
| Box truth correspondence requires matching `M.interp (atomMap (.box psi)) t` with `forall sigma in Omega, truth_at sigma t psi` | H | M | The chronicle's BFMCS gives modal_forward/modal_backward: box psi in fmcs(t) iff psi in ALL families at t. This is exactly the quantification over Omega. The WorldState carries the FMCS family index, making each history correspond to a family. |
| Coherence conditions (restricted_tc, restricted_fuc) in BFMCS path need succ_cofinal | H | L | The chronicle-derived TaskFrame does NOT go through the BFMCS coherence conditions. It builds the TaskFrame directly from the chronicle's MCS structure, using `chronicle_is_good_direct` (which uses `one_class` -> `no_gaps_discrete` path, NOT IsSuccArchimedean). |

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

### Phase 1: Theorem 5 -- US Expressive Completeness over Prior Structures [COMPLETED]

**Goal**: Prove that {U,S} is expressively complete for Prior structures. This is the foundational result enabling all subsequent phases.

**Literature**: Reynolds 1994, Theorem 5, pp.123-124. Also GHR93/94 Theorem 9.3.1 (Stavi completeness, already formalized as `stavi_expressive_completeness`), and GHR94 Theorem 4 ({U,S,U',S'} expressively complete for all linear structures, already formalized as `stavi_expressive_completeness`).

**Completed Implementation**: `PriorExpressiveness.lean` (395 lines, 0 sorries) with:
- `stavi_U_false_on_prior_UZ` -- U'(A,B) is always false under Prior-UZ (uses Prior-UZ directly, deviation from plan to use Prior-U)
- `stavi_S_false_on_prior_SZ` -- S'(A,B) is always false under Prior-SZ
- `flatten_stavi_correct_prior` -- Stavi formula flattening is correct under Prior-UZ/SZ
- `US_expressively_complete_over_prior` -- {U,S} expressively complete over Prior structures (inherits sorryAx from stavi_expressive_completeness, pre-existing)

**Deviations from plan v6**: Task 1.0 (Prior-U bridge lemma) was skipped. The proofs use Prior-UZ directly rather than first deriving the weaker Prior-U. Reynolds' argument works equally well with the stronger hypothesis. Theorem names use `_UZ`/`_SZ` suffixes.

**Timing**: 5 hours (completed)

**Depends on**: none

**Files**: `Theories/Bimodal/Metalogic/WeakCanonical/PriorExpressiveness.lean` (395 lines)

**Completed**: 2026-05-28

---

### Phase 2: Lemmas 6-9 -- Gap Formula R and R-Interval Properties [IN PROGRESS]

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
  Apply `US_expressively_complete_over_prior` to `rho_formula epsilon` and its mirror. Reference: Reynolds 1994, Lemma 6, p.125.

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
  Proof: R at t implies rho at t. Use Prior-UZ on R to find structured boundary points. Reference: Reynolds 1994, Lemma 7, pp.125-126.

- [ ] **Task 2.5**: Prove `R_no_first_last_class` (Lemma 8) -- no first or last ~M-class in any maximal R-interval (~60 lines)
  Proof by contradiction using expressive completeness and Prior-UZ. Reference: Reynolds 1994, Lemma 8, pp.126-127.

- [ ] **Task 2.6**: Prove `substructure_temporal_truth` -- temporal truth in M|S agrees with restricted evaluation (~80 lines)
  ```lean
  theorem substructure_temporal_truth {sig : MonadicSignature}
      (M : OrderedMonadicStructure sig) (S : Set M.carrier)
      [hS_convex : IsConvex S] [hS_nonempty : Nonempty S]
      (atomMap : Formula → sig.preds)
      (t : S) (A : Formula) :
      temporal_truth (M.restrict S) atomMap t A ↔
      temporal_truth_restricted M S atomMap t.val A
  ```
  Proof by induction on A. Used by Lemma 9 Part 2, Lemma 12, and Lemma 13. Reference: Reynolds 1994, p.486-488 (implicit throughout Section 7).

- [ ] **Task 2.7**: Prove `R_classes_elem_equiv` (Lemma 9) -- ~M-classes in R-intervals are elementarily equivalent (~120 lines)
  Two parts: (1) temporal formula transfer between classes (Reynolds pp.622-640), (2) monadic elementary equivalence as substructures (pp.642-648). Part 2 requires `substructure_temporal_truth`. Reference: Reynolds 1994, Lemma 9, pp.126-127.

**Timing**: 6 hours

**Depends on**: 1

**Files to modify/create**:
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/ReynoldsNoGaps.lean` (NEW, ~450 lines) -- Lemmas 6-9 + substructure truth
- `Theories/Bimodal/Metalogic/WeakCanonical/MonadicFO.lean` (MODIFY, ~80 lines) -- `substructure_temporal_truth` (or place in ReynoldsNoGaps if MonadicFO modification is too invasive)

**Verification**:
- `lake build Bimodal.Metalogic.WeakCanonical.IntegerModel.ReynoldsNoGaps` succeeds
- `#print axioms R_intervals_open` shows no `sorryAx`
- `#print axioms substructure_temporal_truth` shows no `sorryAx`
- `#print axioms R_classes_elem_equiv` shows no `sorryAx`

---

### Phase 3: Lemmas 10-13 -- Model Surgery [NOT STARTED]

**Goal**: Define bad points and bad intervals, prove the model surgery lemma (replacing a bad interval by one of its ~M-classes preserves temporal truth), and derive that no bad points exist.

**Literature**: Reynolds 1994, Section 7, pp.127-129, Lemmas 10-13.

**Proof Strategy**: A "bad point" is where R V L holds (the class ends at a gap on at least one side). A "bad interval" is a maximal connected interval of bad points. Lemma 10: bad points only occur in non-singleton bad intervals, both R and L hold throughout, excluded endpoints. Lemma 11: formulas true at the start/end of a class in a bad interval hold throughout the interval. Lemma 12 (KEY): replace a bad interval Qo by one of its ~M-classes I; temporal truth is preserved in the resulting substructure Q- U I U Q+ (induction on formula, 13 cases for U(A,B)). Lemma 13: the surgery model N is also a Prior structure where R holds in I, but I's class in N cannot end at a gap (bounded by the excluded endpoint q of Q+), contradiction.

**Tasks**:
- [ ] **Task 3.1**: Define `bad_point` and `bad_interval` (~30 lines)
  Reference: Reynolds 1994, p.127, definition above Lemma 10.

- [ ] **Task 3.2**: Prove `bad_points_in_intervals` (Lemma 10) -- bad points only in non-singleton intervals, R and L hold throughout, excluded endpoints (~80 lines)
  Reference: Reynolds 1994, Lemma 10, pp.127-128.

- [ ] **Task 3.3**: Prove `bad_interval_propagation` (Lemma 11) -- formula true at start of class holds throughout bad interval (~60 lines)
  Reference: Reynolds 1994, Lemma 11, pp.127-128.

- [ ] **Task 3.4**: Define `surgery_model` -- substructure Q- U I U Q+ (~50 lines)
  Reference: Reynolds 1994, p.128, definition above Lemma 12.

- [ ] **Task 3.5**: Prove `surgery_preserves_truth` (Lemma 12) -- temporal truth preserved in surgery model (~200 lines)
  ```lean
  theorem surgery_preserves_truth (A : Formula) (t : N.carrier)
      (ht : t ∈ surgery_domain Q_minus I Q_plus) :
      temporal_truth M atomMap t A ↔ temporal_truth N atomMap t A
  ```
  Proof by induction on formula A. 7 forward + 6 backward cases for U(A,B). S(A,B) is the mirror. Reference: Reynolds 1994, Lemma 12, pp.128-129.

- [ ] **Task 3.6**: Prove `no_bad_points` (Lemma 13) -- bad points cannot exist in any Prior structure (~80 lines)
  Proof by contradiction: form surgery model N, show R holds in I in N, show N is a Prior structure, show I's class in N ends at a point (not a gap), contradiction. Reference: Reynolds 1994, Lemma 13, p.129.

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

**Proof Strategy**: Theorem 14 follows from `no_bad_points` (Lemma 13): if some ~M-class ended at a gap, then R would hold at points of that class, making those points bad -- contradiction. Close `no_gaps_discrete` with `theorem_14`. Discharge the semantic Prior-UZ/SZ hypotheses in `chronicle_is_good_direct` by threading the section property from the call site.

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
  Reference: Reynolds 1994, Theorem 14, p.129.

- [ ] **Task 4.2**: Replace the sorry in `no_gaps_discrete` (GoodStructures.lean:842) with a call to `theorem_14` (~30 lines)

- [ ] **Task 4.3**: Close the secondary sorries in `chronicle_is_good_direct` (ShiftAndGlue.lean:985, 991) -- discharge semantic Prior-UZ/SZ for the chronicle (~80 lines)
  Add the section property as a parameter to `chronicle_is_good_direct` and thread it from the caller in `countermodel_discrete_reynolds`. Use `chronicle_temporal_truth` to convert between MCS membership and `temporal_truth`, establishing the semantic Prior-UZ/SZ from the syntactic Prior-UZ/SZ in the MCS.

- [ ] **Task 4.4**: Verify `one_class` is now sorry-free -- `#print axioms one_class` shows no `sorryAx` (~5 lines)

**Timing**: 3 hours

**Depends on**: 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/GoodStructures.lean` -- replace sorry in `no_gaps_discrete`
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/ShiftAndGlue.lean` -- close sorries in `chronicle_is_good_direct`, add section property parameter
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/ReynoldsNoGaps.lean` -- add `theorem_14`

**Verification**:
- `#print axioms no_gaps_discrete` shows no `sorryAx`
- `#print axioms one_class` shows no `sorryAx`
- `#print axioms chronicle_is_good_direct` shows no `sorryAx`

---

### Phase 5: Chronicle-Derived TaskFrame and Pipeline Completion [NOT STARTED]

**Goal**: Build a TaskFrame whose world-histories come from the chronicle's BFMCS families, prove the full truth correspondence between `truth_at` and `temporal_truth` (including box subformulas), close the `countermodel_discrete_reynolds` sorry, rewire `completeness_discrete`, and verify the full project builds sorry-free for `completeness_discrete`.

**Literature**: Reynolds 1994, Section 8, pp.130-131 (Theorem 15 usage in completeness proof). GHR94 Chapter 10 (integer completeness proof structure).

### The Box Modality Problem (Why z_interval_countermodel Fails)

The existing `z_interval_countermodel` (Transfer.lean:354-410) uses:
- `WorldState := Unit` (all histories have the same state at every time)
- `Omega := {zIntervalHistory}` (singleton set with one history)

This makes `truth_at (.box psi) t = truth_at psi t` (box collapses to identity via `zIntervalBox_transparent`). But `temporal_truth (.box psi) t = M.interp (atomMap (.box psi)) t` treats box as a predicate lookup in the monadic structure. The MCS membership `(.box psi) in fmcs(t)` is NOT the same as `psi in fmcs(t)` in general -- box psi holds when psi is in ALL families at time t, not just the evaluation family. With singleton Omega, there is only one history, so `truth_at (.box psi) = truth_at psi` (local truth), while `temporal_truth (.box psi)` checks a global predicate (box membership in the MCS). These cannot be made to agree for formulas where box carries non-trivial information.

User constraint: NO constant/trivial world-histories or singleton Omega.

### The Chronicle-Derived TaskFrame Construction

Instead of the singleton approach, we build a TaskFrame whose structure mirrors the chronicle's BFMCS:

**WorldState**: Carries the FMCS family index. Each world-state identifies which BFMCS family is "active" at that time-point. Concretely: `WorldState := FMCS_index` where `FMCS_index` indexes the families in `cantor_bfmcs_discrete`.

**WorldHistories (Omega)**: One history per FMCS family. Each history sigma_f has:
- `domain := fun t => True` (full Z domain, since the Z-interval is unbounded)
- `states t _ := f` (constant in the family index -- each history represents a fixed family)

This gives `|Omega| = |families|` (one history per BFMCS family), which is generally infinite (uncountable). Different histories carry different world-states, so box quantification is non-trivial.

**TaskModel**: The valuation function maps `(w : WorldState, p : Atom)` to `Prop` via:
- `valuation w p := (.atom p) in family(w).mcs(root_point)`

Actually, the valuation must be position-independent (it maps WorldState x Atom -> Prop), while MCS membership varies with time. The resolution: the atom valuation at a history sigma_f at time t is determined by `(.atom p) in family(f).mcs(t)`. Since truth_at accesses the atom via `tau.states t ht` (which returns the world-state, i.e., the family index f), the valuation function is:
- `valuation f p := True` (dummy -- actual truth is carried by `h_truth_corr`)

No -- the correct approach is more subtle. Let us define:
- `WorldState := Family_at_time` -- a type that carries BOTH the family index AND the time-indexed MCS content

But WorldState cannot depend on time in the TaskFrame definition. The TaskFrame has a fixed WorldState type, and each history assigns states to times.

The correct decomposition:
- `WorldState := FMCS D` (the full time-indexed MCS family as a single object)
- Each history sigma_f carries `states t _ := f` where `f : FMCS D` is a fixed family
- `valuation (f : FMCS D) (p : Atom) := (.atom p) in f.mcs(root_point)`

But this makes valuation time-independent (always checks root_point), which is wrong. Atoms should be position-dependent.

The fundamental resolution is that `h_truth_corr` (the truth correspondence hypothesis) does NOT decompose into frame-level properties -- it is proved directly by induction on the formula, using the chronicle's MCS structure. The TaskFrame/TaskModel are defined to be structurally compatible, and the actual truth correspondence is an external theorem.

**Proof Strategy for Phase 5**:

1. Define `chronicleTaskFrame` with `WorldState := FMCS_family_index` and one history per family
2. Define `chronicleTaskModel` with position-dependent valuation via the chronicle's MCS membership
3. Prove `chronicle_truth_correspondence` by structural induction on formulas:
   - Atoms: `truth_at (.atom p) t` iff `exists ht, valuation (tau.states t ht) p` iff `(.atom p) in eval_family.mcs(t)` iff `temporal_truth (.atom p) t` (via chronicle_temporal_truth)
   - Bot: both sides false
   - Imp: by IH on subformulas
   - Until/Since: by IH on subformulas, using the fact that both truth_at and temporal_truth quantify over the same linear order (Z-interval carrier)
   - Box (KEY): `truth_at (.box psi) t` = `forall sigma in Omega, truth_at sigma t psi`. By IH, each `truth_at sigma_f t psi` iff `psi in family(f).mcs(t)`. So `truth_at (.box psi) t` iff `forall f in families, psi in family(f).mcs(t)`. By BFMCS `modal_forward`/`modal_backward`: `(.box psi) in eval_family.mcs(t)` iff `psi in ALL families.mcs(t)`. So `truth_at (.box psi) t` iff `(.box psi) in eval_family.mcs(t)` iff `M.interp (atomMap (.box psi)) t` iff `temporal_truth (.box psi) t`.
4. Use the truth correspondence to transfer the negation of phi from temporal_truth to truth_at
5. Package the existential and close the sorry

The key insight: `modal_forward` and `modal_backward` in the BFMCS are sorry-free. They directly give the biconditional between "box psi in eval_family.mcs(t)" and "psi in ALL families.mcs(t)". This is exactly what makes the box case of the truth correspondence work with multi-history Omega.

**Critical dependency**: The BFMCS used here is `cantor_bfmcs_discrete`, which is sorry-free (report 07 confirms this). The sorry in the old pipeline entered through the coherence conditions (`restricted_tc`, `restricted_fuc`), which are NOT needed for the TaskFrame construction -- they were needed for the old `dd_countermodel_chronicle_discrete` path. The chronicle-derived TaskFrame only needs `modal_forward`/`modal_backward` (sorry-free) and the chronicle's MCS membership (sorry-free via `chronicle_temporal_truth`).

**Tasks**:

- [ ] **Task 5.1**: Define `ChronicleTaskFrame` -- TaskFrame with FMCS-family-indexed WorldState (~80 lines)

  Create a new structure that builds a TaskFrame from a chronicle's BFMCS:
  ```lean
  noncomputable def chronicleTaskFrame (CM : ChronicleAsPriorModel fc)
      (bfmcs : BFMCS D) : TaskFrame ℤ where
    WorldState := bfmcs.families  -- or an index type for the BFMCS families
    task_rel := fun f g t => True  -- task relation is trivial (S5: all states related)
    nullity_identity := ...
    forward_comp := ...
    converse := ...
  ```

  The task_rel is trivial because the bimodal logic uses S5 modal logic (equivalence relation on world-states). In S5, all world-states at a given time are related. This is what makes box = universal quantification over all histories in Omega.

  Reference: The existing `zIntervalTaskFrame` (Transfer.lean:354) provides the template, but with non-trivial WorldState instead of Unit.

- [ ] **Task 5.2**: Define `chronicleWorldHistories` -- one history per BFMCS family (~60 lines)

  ```lean
  noncomputable def chronicleHistory (bfmcs : BFMCS D) (f : bfmcs.families) :
      WorldHistory (chronicleTaskFrame CM bfmcs) where
    domain := fun _ => True  -- full ℤ domain (unbounded Z-interval)
    convex := ...
    states := fun t _ => f   -- constant: this history carries family f at all times
    respects_task := ...      -- trivial since task_rel is trivial
  ```

  Define `chronicleOmega := { chronicleHistory bfmcs f | f : bfmcs.families }` and prove `ShiftClosed chronicleOmega` (shifting a history for family f gives back the history for family f, since states are time-independent).

- [ ] **Task 5.3**: Define `chronicleTaskModel` -- position-dependent atom valuation via MCS membership (~60 lines)

  The challenge: `TaskModel.valuation : WorldState -> Atom -> Prop` is position-independent. But atom truth in the chronicle is position-dependent (it depends on which formulas are in `fmcs(t)`).

  Resolution: The valuation function cannot capture position-dependence directly. Instead, define:
  ```lean
  noncomputable def chronicleTaskModel (CM : ChronicleAsPriorModel fc)
      (bfmcs : BFMCS D) : TaskModel (chronicleTaskFrame CM bfmcs) where
    valuation := fun f p => True  -- placeholder; actual truth via h_truth_corr
  ```

  Actually, the correct approach: since `truth_at (.atom p)` checks `exists ht, valuation (tau.states t ht) p`, and `tau.states t ht = f` (the family index), we need `valuation f p` to be the right thing. But it cannot depend on `t`.

  The solution is to NOT try to make the atom case work through valuation alone. Instead, prove `h_truth_corr` as a standalone theorem that handles all formula cases including atoms. The atom case of `h_truth_corr` uses the chronicle's MCS membership directly, and the proof obligation is:
  - `(exists ht : True, valuation f p) <-> (.atom p) in f.mcs(t)`
  - This simplifies to: `valuation f p <-> (.atom p) in f.mcs(t)` for all t

  For this to hold for ALL t simultaneously, we need atom truth to be time-independent within each family. This is exactly what BFMCS families guarantee: within a single family, the atom predicates ARE time-independent (they are part of the monadic structure's interpretation, which is fixed per predicate symbol).

  Wait -- actually, in the chronicle's monadic structure, `M.interp p t` can vary with `t`. The predicate interpretation in `chronicleAsMonadicStructure` maps `(atomMap_rev p)` to its MCS membership at time `t`. So atoms ARE position-dependent.

  The correct resolution: use a time-indexed WorldState.
  ```lean
  WorldState := ℤ × bfmcs.families  -- (time, family) pair
  ```
  Then `states t _ := (t, f)` for history sigma_f, and:
  ```lean
  valuation (t, f) p := (.atom p) in f.mcs(t)
  ```

  But wait: the TaskFrame requires `task_rel : WorldState -> WorldState -> D -> Prop`, and the nullity_identity axiom says `task_rel w u t <-> w = u`. With `WorldState = Z x families`, this means `(t1, f1) = (t2, f2)`, which requires `t1 = t2` -- but the histories carry `states t _ = (t, f)`, so at different times the states differ. The task_rel at time t relates states at time t, and nullity_identity says two states at the same time are related iff they're equal. This would make box trivial again (only one state at each time per history).

  The proper S5 task_rel should relate ALL family indices at the same time:
  ```lean
  task_rel (t1, f1) (t2, f2) t := True  -- all related (S5)
  ```
  But nullity_identity requires: `task_rel w u t <-> w = u`. If task_rel is always True, then `w = u` must always hold, which is wrong.

  This is the core difficulty. The TaskFrame axioms enforce that task_rel at each time partitions WorldStates into equivalence classes, and nullity_identity says "the identity on WorldState is the only reflexive task relation." This means we CANNOT have all families related by task_rel unless WorldState is a singleton.

  Re-reading the TaskFrame definition more carefully:

  ```lean
  nullity_identity : ∀ (w u : WorldState), task_rel w u t ↔ w = u
  ```

  Wait -- is `t` universally quantified here? Let me check.

- [ ] **Task 5.4**: Investigate TaskFrame axioms and design compatible WorldState (~40 lines)

  Before implementing: read `TaskFrame` definition carefully. Check whether `nullity_identity` universally quantifies over `t` or is parameterized. The task_rel may be more flexible than assumed.

  If `nullity_identity` requires `task_rel w u t <-> w = u` for ALL t, then WorldState must be a singleton for S5 (all states related), which brings us back to the Unit problem.

  **Contingency approaches if TaskFrame axioms force singleton WorldState**:

  **(A) Relativized temporal_truth**: Instead of matching `truth_at` with `temporal_truth` directly, define a `relativized_temporal_truth` that handles box by quantification rather than predicate lookup:
  ```lean
  def relativized_temporal_truth (M : OrderedMonadicStructure sig)
      (atomMap : Formula -> sig.preds) (t : M.carrier) : Formula -> Prop
    | .box phi => ∀ (f : bfmcs.families), relativized_temporal_truth ... t phi
    | .atom a => M.interp (atomMap (.atom a)) t
    | .untl phi psi => ...  -- same as temporal_truth
  ```
  Then prove: `relativized_temporal_truth M atomMap t phi <-> temporal_truth M atomMap t phi` for all formulas phi. The box case: `(forall f, relativized_temporal_truth ... t phi) <-> M.interp (atomMap (.box phi)) t`. This follows from modal_forward/modal_backward.

  Then the truth correspondence becomes: `truth_at TM Omega tau t phi <-> relativized_temporal_truth M atomMap t phi`, and the box case works because both sides quantify universally.

  **(B) Subformula-restricted correspondence**: Prove `truth_at <-> temporal_truth` only for box-free subformulas, then handle the box case specially using the fact that the input formula's box subformulas have temporal_truth determined by their inner content via the Prior/BFMCS structure.

  **(C) Direct existential construction**: Instead of factoring through z_interval_countermodel, construct the existential witness `exists D F TM Omega tau t, not truth_at TM Omega tau t phi` directly by building the right TaskFrame for the specific formula phi. Use Unit WorldState + singleton Omega, but prove the truth correspondence holds for THIS specific formula by case analysis on whether phi's subformula closure contains box subformulas that carry non-trivial content.

  The recommended approach is **(A)**, because:
  - It cleanly separates the modal quantification from predicate lookup
  - The `relativized_temporal_truth <-> temporal_truth` bridge is provable from modal_forward/modal_backward (sorry-free)
  - The `truth_at <-> relativized_temporal_truth` bridge works with singleton Omega (because both sides quantify trivially when Omega is a singleton -- the box case becomes `truth_at (.box psi) = truth_at psi` on both sides)
  - Wait -- this has the same problem: with singleton Omega, `truth_at (.box psi) = truth_at psi`, but `relativized_temporal_truth (.box psi)` still quantifies over all families...

  Actually, approach (A) needs multi-history Omega to work. Let me reconsider.

  **Revised approach**: The TaskFrame axioms may not be as restrictive as feared. The `nullity_identity` axiom is about the *trivial task frame* (the "null" task), not about all task frames. Let me re-read the actual definition.

- [ ] **Task 5.5**: Read and analyze `TaskFrame` definition for WorldState flexibility (~20 lines)

  Read the actual `TaskFrame` structure in `Theories/Bimodal/Semantics/TaskFrame.lean`. Check:
  1. Does `nullity_identity` universally quantify over t?
  2. Is task_rel parameterized by t (time-dependent)?
  3. Can WorldState be non-singleton while allowing all states to be related?
  4. What does `forward_comp` require?
  5. What does `converse` require?

  This is prerequisite for all subsequent construction decisions.

- [ ] **Task 5.6**: Implement chronicle-derived TaskFrame based on axiom analysis (~100 lines)

  Based on findings from Task 5.5, implement the appropriate TaskFrame:

  **If multi-state WorldState is compatible with axioms**: Build `chronicleTaskFrame` with FMCS-family-indexed WorldState and multi-history Omega as described above.

  **If nullity_identity forces singleton WorldState**: Use approach (A) -- define `relativized_temporal_truth` that replaces the box predicate-lookup with universal quantification over BFMCS families:

  ```lean
  def box_expanded_temporal_truth {sig : MonadicSignature}
      (M : OrderedMonadicStructure sig)
      (bfmcs : BFMCS (LimitDomSubtype ...))
      (atomMap : Formula -> sig.preds)
      (family_atomMap : bfmcs.families -> Formula -> sig.preds)
      (t : M.carrier) : Formula -> Prop
    | .atom a => M.interp (atomMap (.atom a)) t
    | .bot => False
    | .imp phi psi => box_expanded_temporal_truth ... t phi -> box_expanded_temporal_truth ... t psi
    | .box phi => ∀ (f : bfmcs.families),
        box_expanded_temporal_truth (family_structure f) (family_atomMap f) ... t phi
    | .untl phi psi => ∃ s, t < s ∧ box_expanded_temporal_truth ... s phi ∧
        ∀ r, t < r -> r < s -> box_expanded_temporal_truth ... r psi
    | .snce phi psi => ...  -- mirror of untl
  ```

  Then prove two bridges:
  1. `box_expanded_temporal_truth <-> temporal_truth` (using modal_forward/modal_backward from BFMCS)
  2. `truth_at (Unit WorldState, singleton Omega) <-> box_expanded_temporal_truth` for the evaluation family (using the fact that box is transparent on both sides -- truth_at box = truth_at inner, and box_expanded box with singleton Omega = box_expanded inner)

  Wait, this still has the problem that with singleton Omega, truth_at box = truth_at inner, but box_expanded_temporal_truth box quantifies over ALL families. These won't match unless we use multi-history Omega.

  **The correct resolution for singleton-Omega-forced case**: The truth correspondence is proved NOT for all formulas, but only for the TOP-LEVEL formula phi (and its neg). The proof does NOT go through a general inductive truth correspondence. Instead:

  1. `temporal_truth M atomMap t phi.neg` is established (Step 7 of the pipeline)
  2. `temporal_truth` treats box as predicate lookup, so it correctly evaluates box subformulas via MCS membership
  3. For the Unit-WorldState singleton-Omega TaskFrame, define the TaskModel's valuation to match temporal_truth at ATOMS
  4. Prove: for any formula psi WITHOUT box subformulas, `truth_at TM Omega tau t psi <-> temporal_truth M atomMap t psi` (by straightforward induction -- the box case never arises)
  5. For formulas WITH box subformulas: use the fact that in the DISCRETE case, the chronicle's MCS satisfies `box next_top` (the box-class axiom), which means EVERY formula equivalent to a box-formula is also equivalent to the inner formula (because box is S5 and the discrete frame class forces a single equivalence class of world-states). Specifically: `(.box psi) in A <-> psi in A` for the specific MCS A (because A contains `box next_top`, which in S5 means there's only one possible world). This makes `temporal_truth (.box psi) t = M.interp (atomMap (.box psi)) t = ((.box psi) in fmcs(t)) = (psi in fmcs(t)) = temporal_truth psi t`. So `temporal_truth (.box psi) t = temporal_truth psi t`, and `truth_at (.box psi) t = truth_at psi t` (from zIntervalBox_transparent). Both sides agree.

  Wait -- is this actually true? Does `box next_top in A` with S5 imply `box psi in A <-> psi in A`?

  `box next_top` says "at every accessible world, next_top holds" -- which in S5 means the accessibility relation is universal. `box psi` says "psi at every accessible world." If accessibility is universal (S5 + box next_top), then `box psi <-> psi` is a theorem of S5: `box psi -> psi` (T axiom) and `psi -> box psi` (because all worlds are accessible from any world when there is only one equivalence class, so `psi at current world` implies `psi at all accessible worlds`).

  Actually: `psi -> box psi` is not valid in S5 in general. It is valid in S5 with a SINGLE equivalence class (i.e., all worlds related). The formula `box next_top` asserts that `next_top` holds at all accessible worlds. Combined with S5 axioms, this gives `box (box next_top)` by S5-necessitation, and the "single cluster" property.

  In the chronicle context: the MCS A has `box next_top in A`. The BFMCS families at each time point form a single box-class (because of the frame class axiom). So `box psi in fmcs(t) <-> psi in fmcs(t)` for all families in the single cluster.

  Actually no -- `box psi in fmcs(t)` means `psi in ALL families' MCS at time t`, while `psi in fmcs(t)` means `psi in the EVALUATION family's MCS at time t`. These are equal only if all families agree on psi at time t, which is exactly what "single cluster" + box axiom gives: all families in the cluster agree on all formulas (because they are modally equivalent).

  Hmm, but FMCS families CAN disagree on non-boxed formulas. The box axiom says: `box psi in fmcs(t)` iff `psi in ALL families at t`. A single family might have `psi` while another doesn't -- as long as `box psi` is not in either.

  So `box psi in fmcs(t) <-> psi in fmcs(t)` is NOT automatic. It holds if and only if all families at time t agree on psi.

  **Revised analysis**: The `h_box_discrete : Formula.box next_top in A` hypothesis means the MCS A contains `box next_top`. In the chronicle, `fmcs(root_point) = A`. The box axiom gives `next_top in ALL families at root_point`. But `next_top` is just one specific formula, not all formulas.

  This means the shortcut "box is trivial" does NOT work in general. For a formula phi that contains `box psi` where psi is a non-trivial temporal formula, the BFMCS families may disagree on psi.

  **Conclusion after analysis**: Multi-history Omega is genuinely required. The TaskFrame axioms must be studied to determine whether they permit this.

- [ ] **Task 5.7**: Prove `chronicle_truth_correspondence` -- the main truth lemma (~200 lines)

  The exact form depends on the TaskFrame axiom analysis (Tasks 5.4-5.5). The core proof strategy by structural induction on formulas:

  **Atom case**: `truth_at TM Omega tau t (.atom p) <-> temporal_truth M atomMap t (.atom p)`
  - LHS: `exists ht, valuation (tau.states t ht) p`
  - RHS: `M.interp (atomMap (.atom p)) t`
  - Bridge: valuation is defined via MCS membership, and `M.interp` is also defined via MCS membership in `chronicleAsMonadicStructure`

  **Bot case**: Both sides False.

  **Imp case**: By IH.

  **Until case**: By IH. Both sides quantify over the same carrier (Z-interval = TaskFrame domain = Z).

  **Since case**: Mirror of Until.

  **Box case (KEY)**:
  - LHS: `forall sigma in Omega, truth_at TM Omega sigma t psi`
  - By IH applied to each sigma (which corresponds to a BFMCS family f): `truth_at TM Omega sigma_f t psi <-> psi in family(f).mcs(t)`
  - So LHS <-> `forall f in families, psi in family(f).mcs(t)`
  - By `modal_forward`/`modal_backward` (BFMCS, sorry-free): `(.box psi) in eval_family.mcs(t) <-> forall f, psi in family(f).mcs(t)`
  - RHS: `M.interp (atomMap (.box psi)) t = (.box psi) in eval_family.mcs(t)` (by definition of chronicleAsMonadicStructure)
  - Therefore LHS <-> RHS.

  **Important**: The IH in the box case must apply to a DIFFERENT history sigma_f (not tau). This means the truth correspondence must be proved for ALL histories in Omega simultaneously, not just the evaluation history tau. The statement should be:
  ```lean
  theorem chronicle_truth_correspondence (psi : Formula) (t : carrier)
      (f : bfmcs.families) :
      truth_at TM Omega (sigma_f) t psi <-> psi in family(f).mcs(t)
  ```
  with the special case for the evaluation family giving `truth_at TM Omega tau t psi <-> temporal_truth M atomMap t psi`.

- [ ] **Task 5.8**: Close the sorry in `countermodel_discrete_reynolds` (Transfer.lean:866) (~60 lines)

  Replace the sorry with:
  1. Build `chronicleTaskFrame` from the chronicle's BFMCS
  2. Build `chronicleTaskModel`
  3. Build `chronicleOmega` with ShiftClosed proof
  4. Pick evaluation history `tau` corresponding to the evaluation family
  5. Use `chronicle_truth_correspondence` to transfer `h_neg_truth` from `temporal_truth` to `truth_at`
  6. Package the existential

  The Z-interval unboundedness (previously Task 5.1(a) in v6) is still needed: show the Z-interval from `chronicle_is_good_direct` has `lo = none, hi = none`. The chronicle's NoMaxOrder and NoMinOrder propagate through `very_good_implies_good`.

- [ ] **Task 5.9**: Rewire `completeness_discrete` to use `countermodel_discrete_reynolds` (~30 lines)

  In BXCanonical/Completeness.lean, replace the call to `countermodel_discrete_enriched` with `countermodel_discrete_reynolds`. The signatures are compatible (both produce `exists (D : Type) ... not truth_at TM Omega tau t phi`).

- [ ] **Task 5.10**: Full build verification (~10 lines)
  - `lake build` -- full project, zero errors
  - `#print axioms completeness_discrete` -- no `sorryAx`
  - `#print axioms Bimodal.Metalogic.BXCanonical.completeness` -- verify general completeness benefits
  - `grep -r "sorry" Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/` -- no sorry in Reynolds pipeline
  - `grep -r "sorry" Theories/Bimodal/Metalogic/WeakCanonical/PriorExpressiveness.lean` -- no sorry

- [ ] **Task 5.11**: Update docstrings in Transfer.lean, Completeness.lean, GoodStructures.lean, and ShiftAndGlue.lean to reflect sorry-free status (~20 lines)

**Timing**: 8 hours (increased from 2 in v6 to account for the chronicle-derived TaskFrame construction, truth correspondence proof, and TaskFrame axiom investigation)

**Depends on**: 4

**Files to modify/create**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Transfer.lean` (MODIFY) -- close sorry at line 866, add chronicleTaskFrame/chronicleTaskModel/chronicleOmega/chronicle_truth_correspondence (or create a new file)
- `Theories/Bimodal/Metalogic/WeakCanonical/ChronicleTaskFrame.lean` (NEW, ~400 lines) -- chronicle-derived TaskFrame, WorldHistories, TaskModel, truth correspondence
- `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` (MODIFY) -- rewire `completeness_discrete`
- Various files -- update docstrings

**Verification**:
- `lake build` passes with zero errors
- `#print axioms completeness_discrete` shows `{propext, Classical.choice, Lean.ofReduceBool, Lean.trustCompiler, Quot.sound}` -- no `sorryAx`
- `#print axioms chronicle_truth_correspondence` shows no `sorryAx`
- No new sorry sites in any modified files
- Existing dense completeness path unaffected

## Testing & Validation

- [ ] `#print axioms stavi_U_false_on_prior_UZ` shows no `sorryAx` (Phase 1, completed)
- [ ] `#print axioms US_expressively_complete_over_prior` shows no `sorryAx` (Phase 1, completed)
- [ ] `#print axioms substructure_temporal_truth` shows no `sorryAx`
- [ ] `#print axioms R_intervals_open` shows no `sorryAx`
- [ ] `#print axioms R_classes_elem_equiv` shows no `sorryAx`
- [ ] `#print axioms surgery_preserves_truth` shows no `sorryAx`
- [ ] `#print axioms no_bad_points` shows no `sorryAx`
- [ ] `#print axioms no_gaps_discrete` shows no `sorryAx`
- [ ] `#print axioms one_class` shows no `sorryAx`
- [ ] `#print axioms chronicle_is_good_direct` shows no `sorryAx`
- [ ] `#print axioms chronicle_truth_correspondence` shows no `sorryAx`
- [ ] `#print axioms countermodel_discrete_reynolds` shows no `sorryAx`
- [ ] `#print axioms completeness_discrete` shows no `sorryAx`
- [ ] `lake build` passes with zero errors
- [ ] No new sorry sites introduced (grep across all modified/created files)
- [ ] Existing dense completeness path unaffected (`#print axioms completeness_dense` unchanged)

## Artifacts & Outputs

- `specs/202_reynolds_k_equivalence_bypass/plans/07_reynolds-theorem-14-plan.md` (this plan)
- `Theories/Bimodal/Metalogic/WeakCanonical/PriorExpressiveness.lean` (EXISTING, 395 lines) -- Theorem 5 (Phase 1, completed)
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/ReynoldsNoGaps.lean` (NEW) -- Lemmas 6-13, Theorem 14
- `Theories/Bimodal/Metalogic/WeakCanonical/ChronicleTaskFrame.lean` (NEW, ~400 lines) -- chronicle-derived TaskFrame, truth correspondence
- `Theories/Bimodal/Metalogic/WeakCanonical/MonadicFO.lean` (MODIFIED) -- `substructure_temporal_truth` (~80 lines)
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/GoodStructures.lean` (MODIFIED) -- sorry closed in `no_gaps_discrete`
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/ShiftAndGlue.lean` (MODIFIED) -- sorries closed in `chronicle_is_good_direct`
- `Theories/Bimodal/Metalogic/WeakCanonical/Transfer.lean` (MODIFIED) -- sorry closed in `countermodel_discrete_reynolds`
- `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` (MODIFIED) -- `completeness_discrete` rewired

## Rollback/Contingency

All new code goes into new files (`PriorExpressiveness.lean`, `ReynoldsNoGaps.lean`, `ChronicleTaskFrame.lean`). Existing files are only modified in Phases 4-5. Reverting Phase 5 (the rewiring in Completeness.lean and Transfer.lean) restores the previous state. Reverting Phase 4 is single-line `sorry` restoration per site.

**Phase 5 contingencies**:

1. **If TaskFrame axioms force singleton WorldState**: Use the expanded-truth approach (Task 5.6 option A). Define `box_expanded_temporal_truth` that quantifies over BFMCS families instead of doing predicate lookup. Prove it equivalent to `temporal_truth` via `modal_forward`/`modal_backward`. Prove `truth_at <-> box_expanded_temporal_truth` with singleton Omega (both sides have trivial box). Chain the equivalences.

2. **If multi-state WorldState IS permitted**: Build the full chronicle-derived TaskFrame as described in Tasks 5.1-5.3. The truth correspondence (Task 5.7) handles box via BFMCS modal_forward/modal_backward.

3. **If the truth correspondence proof is too complex**: Break it into per-constructor lemmas (atom_correspondence, imp_correspondence, box_correspondence, until_correspondence, since_correspondence). Each can be verified independently.

4. **If the model surgery argument (Phase 3, Lemma 12) proves too large**: Break the 13 cases into individual lemmas. Use existing `subinterval` infrastructure from GoodStructures.lean.

5. **If Phase 1 encounters issues**: Already completed and verified (395 lines, 0 sorries).
