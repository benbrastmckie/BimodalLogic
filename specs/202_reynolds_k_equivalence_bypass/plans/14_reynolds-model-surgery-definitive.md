# Implementation Plan: Reynolds Model Surgery -- Definitive Path to Sorry-Free completeness_discrete (v14)

- **Task**: 202 - Reynolds k-equivalence bypass for sorry-free completeness_discrete
- **Status**: [NOT STARTED]
- **Effort**: 18 hours
- **Dependencies**: None
- **Research Inputs**: reports/14_model-surgery-deep-research.md, reports/15_reynolds-pipeline-detailed-plan.md, handoffs/phase-1-h-surj-pivot-20260530.md, handoffs/phase-1-blocked-signature-20260529.md, handoffs/phase-2-blocked-counterexample-20260530.md, literature/Reynolds_1994_Axiomatising_U_and_S_over_integer_time.md (Sections 6-7)
- **Artifacts**: plans/14_reynolds-model-surgery-definitive.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

---

> **PLAN v14 -- DEFINITIVE PATH**: This plan supersedes plan v13 based on
> two new research reports (14, 15) and three implementation cycle handoffs.
>
> **Key findings incorporated**:
> 1. `prior_implies_archimedean_of_accessible` was FALSE with h_accessible.
>    Signatures already pivoted to h_surj (handoff: phase-1-h-surj-pivot).
> 2. Direct Prior-UZ shortcut FAILS in Case B -- predicate transitions at
>    successor pairs in the complement are legitimate, not contradictory
>    (report 15, Section A.4-A.6). Full model surgery IS required.
> 3. BX pipeline revival offers NO net savings (report 15, Part C).
> 4. Exactly 4 sorry sites remain; exactly 2 are mathematical, 2 engineering.
>
> **Pipeline structure** (v14, Reynolds pipeline):
> ```
> no_gaps_discrete_model_surgery (GoodStructuresModelSurgery.lean:348 -- SORRY #1)
>   -> no_gaps_discrete (GoodStructures.lean:852 -- SORRY #2, same blocker)
>     -> one_class (sorry-free given no_gaps_discrete)
>       -> chronicle_is_good_direct (sorry-free given one_class + h_surj)
>         -> countermodel_discrete_reynolds (Transfer.lean)
>           h_surj construction (Transfer.lean:1117 -- SORRY #3)
>           Z-interval TaskFrame packaging (Transfer.lean:1162 -- SORRY #4)
>             -> completeness_discrete (rewired in Completeness.lean)
> ```

---

## Overview

Plan v14 closes all 4 remaining sorry sites blocking sorry-free `completeness_discrete`
via the Reynolds pipeline. The mathematical core is Reynolds' Theorem 14 (model surgery
proving contemp_equiv class boundaries cannot end at gaps), implemented via Lemmas 6-13
in GoodStructuresModelSurgery.lean. Two engineering sorry sites in Transfer.lean handle
h_surj atom construction and Z-interval-to-TaskFrame packaging.

Research report 15 definitively established that the direct Prior-UZ contradiction proof
fails in Case B (when predicates vary across the gap, transitions can legitimately occur
at successor pairs in the complement). The full model surgery argument (Lemmas 6-13) is
therefore required. Report 14 confirmed h_surj (not h_accessible) is the correct
hypothesis and that all signature changes are already in place.

The plan has 5 phases matching the dependency structure: h_surj engineering (independent),
model surgery core (the main mathematical work), wiring no_gaps_discrete, TaskFrame
packaging, and completeness rewiring with verification.

### Research Integration

- `reports/01_reynolds-bypass-research.md` (plan v1): Initial infrastructure survey.
- `reports/05_reynolds-theorem-14-research.md` (plan v6): Full dependency chain.
- `reports/07_bfmcs-bypass-research.md` (plan v8): BFMCS sorry-free confirmation.
- `reports/08_succ-cofinal-dependency-trace.md` (plan v8): Full dependency trace.
- `reports/12_deviation-analysis.md` (plan v10): Phase 2 restructuring assessment.
- `reports/13_blocker-analysis-correct-path.md` (plan v13): Path B identification.
- `handoffs/phase-2-blocked-20260529.md` (plan v11): no_gaps_prior falsity.
- `handoffs/phase-2-blocked-counterexample-20260530.md` (plan v13): Z+Z counterexample.
- `handoffs/phase-1-blocked-signature-20260529.md` (plan v13): Missing accessibility.
- `handoffs/phase-1-h-surj-pivot-20260530.md` (plan v14): h_surj pivot, FALSE theorem removed.
- `reports/14_model-surgery-deep-research.md` (plan v14): Single mathematical sorry identified, proof strategy via gap detection + pigeonhole + Prior-UZ first-transition.
- `reports/15_reynolds-pipeline-detailed-plan.md` (plan v14): Direct shortcut FAILS in Case B; full model surgery required; 13 U/S subcases detailed; BX revival analyzed and rejected; box modality tension in TaskFrame packaging identified.
- `literature/Reynolds_1994_Axiomatising_U_and_S_over_integer_time.md`: Sections 6-7, Lemmas 6-13, Theorem 14.

### Prior Plan Reference

Plans v1-v5 attempted direct approaches. Plan v6 took the Reynolds Theorem 14 route.
Plans v7-v8 refined the pipeline. Plan v9 added dead code cleanup. Plan v10 merged
Phases 2-4. Plan v11 attempted chronicle-level proof via Prior-SZ contradiction --
blocked (abstract MCS axioms insufficient). Plan v12 attempted full Reynolds model
surgery at the PriorModelData (MCS) level -- blocked (no_gaps_faithful is FALSE).
Plan v13 pivoted to no_gaps_discrete at the OrderedMonadicStructure (semantic/temporal)
level -- blocked during implementation (prior_implies_archimedean_of_accessible was
FALSE with h_accessible; pivoted to h_surj). Plan v14 incorporates all findings from
reports 14-15 and implementation handoffs: full model surgery (Lemmas 6-13) is required,
direct shortcut fails, h_surj is correct and signatures already updated.

## Goals & Non-Goals

**Goals**:
- Close `no_gaps_discrete_model_surgery` sorry (GoodStructuresModelSurgery.lean:348) via Reynolds Lemmas 6-13 + Theorem 14
- Close `no_gaps_discrete` sorry (GoodStructures.lean:852) by wiring to model surgery
- Close `h_surj` sorry (Transfer.lean:1117) by constructing enriched atomMap with fresh atoms
- Close `countermodel_discrete_reynolds` packaging sorry (Transfer.lean:1162) with TaskFrame construction
- Rewire `completeness_discrete` to use `countermodel_discrete_reynolds`
- Verify `completeness_discrete` has no `sorryAx`

**Non-Goals**:
- Fixing `no_gaps_faithful` (proven FALSE, dead BX pipeline code)
- Proving `chronicle_gap_contradiction` (dead BX pipeline code)
- Modifying the dense completeness path
- Closing `countermodel_discrete` sorry at Transfer.lean (Base frame class, not Discrete)
- BX pipeline revival (analyzed in report 15, Part C -- no net savings)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Monadic FO formula construction for rho(x) is complex | H | M | Use enriched signature approach: add right_gap_class as abstract monadic predicate, apply US_expressively_complete_over_prior on enriched signature. Avoids explicit formula construction. |
| Model surgery U(A,B) 13 subcases exceed estimates (7 forward + 6 backward) | M | M | Each subcase is independent (15-30 lines each). Can be parallelized. Break into separate lemmas per case. |
| Box modality tension in TaskFrame packaging (temporal_truth treats box as predicate, truth_at uses WorldHistory quantification) | H | H | Construct WorldHistory-based model where Omega = {tau_t : t in Z-interval}, ShiftClosed by successor shift. Box correspondence requires careful alignment. Estimated ~200 lines. |
| S(A,B) subcases (mirror of U) may require non-trivial adaptation | M | L | S is the strict time-reverse of U. Each forward subcase has a symmetric backward counterpart. Use `Order.dual` or manual mirroring. |
| Circular import between GoodStructures and GoodStructuresModelSurgery | L | L | Already addressed: GoodStructuresModelSurgery imports GoodStructures, not vice versa. The no_gaps_discrete sorry in GoodStructures.lean requires separate wiring (Phase 3). |
| Z-interval unboundedness: the good witness from chronicle_is_good_direct may be bounded | M | M | If bounded, use OrderIso to embed into Z and extend. Alternative: show chronicle unboundedness forces Z-interval unboundedness through the very_good_implies_good construction. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2 | -- |
| 2 | 3 | 2 |
| 3 | 4 | 1, 3 |
| 4 | 5 | 4 |

Phases within the same wave can execute in parallel.

---

### Phase 1: h_surj Construction at Call Site [COMPLETED]

**Goal**: Close the engineering sorry at Transfer.lean:1117 by constructing a
surjective atomMap (enriched with fresh atoms for non-atom predicates).

**Context**: The current `atomMap_fwd` maps `.atom a` to the corresponding
predicate in `mkSigFrom phi` when `.atom a` is in `phi.predFormulas`, and to
`defaultPred` otherwise. This fails h_surj for non-atom predicates (`.bot` and
`.box psi` entries). Since `Atom` is `Infinite` and `sig.preds` is `Fintype`,
we can pick distinct fresh atoms for each non-atom predicate.

**Existing infrastructure**:
- `Atom.fresh_for : Finset Atom -> Atom` (sorry-free)
- `Atom.fresh_for_not_mem : Atom.fresh_for S not in S` (sorry-free)
- `instance : Infinite Atom` (sorry-free)
- `chronicle_semantic_prior_UZ/SZ` works for ANY atomMap_fwd (sorry-free)

**Tasks**:
- [ ] **Task 1.1**: Enumerate non-atom predicates in `(mkSigFrom phi).preds` (~10 lines)
  - `(mkSigFrom phi).preds` = `Finset.cons bot phi.predFormulas`
  - Non-atom predicates: those of the form `.bot`, `.box psi`, or other non-`.atom a` constructors
  - Use `Decidable` instance on formula constructors to filter

- [ ] **Task 1.2**: Construct injection from non-atom predicates to fresh atoms (~20 lines)
  - Collect atoms already used in `phi.predFormulas`
  - Use `Atom.fresh_for` iteratively (or `Infinite.exists_not_injective`) to assign distinct fresh atoms
  - Build a lookup table `non_atom_pred_to_fresh_atom : sig.preds -> Option Atom`

- [ ] **Task 1.3**: Define enriched `atomMap_fwd` and prove h_surj (~20 lines)
  - Extend `atomMap_fwd` to map fresh atoms to their assigned non-atom predicates
  - Prove: for each `p : sig.preds`, either `p` comes from an existing atom in `predFormulas` or from a fresh atom
  - Verify section property is preserved: fresh atoms are not in `predFormulas`, so `atomMap_rev (atomMap_fwd f) = f` for `f in phi.predFormulas` still holds

- [ ] **Task 1.4**: Verify Prior-UZ/SZ and downstream compatibility (~10 lines)
  - `chronicle_semantic_prior_UZ/SZ` takes arbitrary `atomMap_fwd` -- no changes needed
  - `chronicle_temporal_truth` section property uses `atomMap_rev . atomMap_fwd = id` on `predFormulas` -- preserved

**Timing**: 2 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Transfer.lean` (replace sorry at line 1117)

**Verification**:
- `lake build Bimodal.Metalogic.WeakCanonical.Transfer` succeeds
- `grep -n "sorry" Transfer.lean` shows one fewer sorry (line 1117 gone, line 1162 remains)

---

### Phase 2: Reynolds Model Surgery Core (Lemmas 6-13 + Theorem 14) [IN PROGRESS]
*(deviation: altered -- contradiction setup complete, model surgery core (Lemmas 6-13) deferred to continuation)*

**Goal**: Close the mathematical sorry at GoodStructuresModelSurgery.lean:348
(`no_gaps_discrete_model_surgery`) by implementing the full Reynolds model
surgery argument.

**Mathematical argument** (Reynolds 1994, pp.124-129, adapted to
OrderedMonadicStructure level with h_surj):

The proof is by contradiction. Assume -(a ~M b) and that no successor boundary
exists (i.e., for all c, if a ~M c then a ~M succ(c)). Then the class of a is
succ-closed. Since -(a ~M b), the class is proper. By `class_gap_exists`
(sorry-free), a Dedekind gap exists. The Reynolds model surgery constructs a
temporal formula R detecting right-gap class boundaries, analyzes R-intervals,
defines bad intervals, proves formula propagation, performs domain surgery
(replacing a bad interval by one class), proves temporal truth preservation
(13 subcases for U/S), and derives contradiction (R holds in surgery model but
class no longer ends at gap).

**CRITICAL**: The direct Prior-UZ contradiction proof (avoiding model surgery)
was analyzed in report 15, Section A.4-A.6, and FAILS in Case B. When predicates
vary across the gap, predicate transitions at successor pairs in the complement
are legitimate and do not create contradictions. The full model surgery (Lemmas
6-13) is mathematically necessary.

**Existing sorry-free infrastructure to reuse**:
- `US_expressively_complete_over_prior` (PriorExpressiveness.lean) -- Theorem 5
- `contemp_equiv_is_equiv` (GoodStructures.lean) -- equivalence relation
- `no_boundary_at_successor` (GoodStructures.lean) -- c ~M succ(c)
- `contemp_equiv_convex` (GoodStructuresModelSurgery.lean) -- classes are convex
- `contemp_equiv_pred_closed` (GoodStructuresModelSurgery.lean)
- `contemp_equiv_succ_iterate` (GoodStructuresModelSurgery.lean)
- `class_gap_exists` (GoodStructuresModelSurgery.lean) -- gap construction
- `prior_UZ_first_transition` (GoodStructuresModelSurgery.lean)
- `temporal_truth_neg_iff_not` (GoodStructuresModelSurgery.lean)
- `gap_of_not_succ_archimedean` (ReynoldsNoGaps.lean)

**File**: `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/GoodStructuresModelSurgery.lean`
(existing file, currently ~350 lines; will grow to ~850 lines)

**Tasks**:
- [ ] **Task 2.1**: Definitions -- right_gap_class, left_gap_class, bad_point (~40 lines)
  - `right_gap_class sig k M t` := t's ~M-class is bounded above AND the upper boundary is a gap (not a successor boundary)
  - `left_gap_class sig k M t` := symmetric for left boundary
  - `bad_point sig k M t` := `right_gap_class t OR left_gap_class t`
  - These are Prop-valued predicates on `M.carrier`

- [ ] **Task 2.2**: Gap formula R construction via enriched signature (Lemma 6) (~80 lines)
  - Add `right_gap_class` as an abstract monadic predicate on an enriched signature `sig_enriched`
  - Show the enriched signature still satisfies Prior-UZ/SZ (since the new predicate is definable from the existing ones)
  - Apply `US_expressively_complete_over_prior` on `sig_enriched` to obtain temporal formula R
  - Prove `R_correct : forall t, temporal_truth M atomMap t R <-> right_gap_class sig k M t`
  - Similarly construct L for `left_gap_class`
  - **Note**: The enriched-signature approach avoids explicit monadic FO formula construction for rho(x). Instead, we treat right_gap_class as a new predicate and obtain its temporal equivalent via Theorem 5. This requires showing the enriched atomMap satisfies h_surj (add one fresh atom for the new predicate).

- [ ] **Task 2.3**: R-interval properties (Lemma 7) (~60 lines)
  - `R_holds_succ`: If R holds at t, R holds at succ(t). Proof: t and succ(t) are in the same class (by no_boundary_at_successor), so succ(t)'s class has the same right gap boundary.
  - `R_interval_excluded_endpoint`: If R holds at t and there exists s > t with not-R at s, then there is a first not-R point q after t, and R holds throughout (t, q). Proof: Prior-UZ applied to R.neg gives the first not-R point.
  - Symmetric results for L using Prior-SZ.

- [ ] **Task 2.4**: No first/last class in R-intervals (Lemma 8) (~60 lines)
  - `no_last_class_in_R_interval`: The last class in an R-interval would end at the R-interval boundary (a point, not a gap), contradicting R.
  - `no_first_class_in_R_interval`: Construct formula B = "my class is the first in this R-interval" via expressive completeness. B transitions at a successor pair (Prior-UZ), but the first class ends at a gap. Contradiction.

- [ ] **Task 2.5**: Class homogeneity (Lemma 9) (~80 lines)
  - `classes_elem_equiv_in_R_interval`: All ~M-classes in a maximal R-interval are elementarily equivalent (same monadic FO theory).
  - Proof: Suppose formula A holds in class C1 but not C2. Construct B = "A occurs in my class" via expressive completeness. B is true throughout C1, false throughout C2. By Prior-UZ, first not-B transition must be at a successor pair. But C1 ends at a gap (R holds). Contradiction.

- [ ] **Task 2.6**: Bad intervals and formula propagation (Lemmas 10-11) (~80 lines)
  - `bad_interval_both_R_and_L`: In any maximal bad interval (where R-or-L holds throughout), BOTH R and L hold throughout. Proof: If L fails somewhere in an R-interval, a class lacks a left-gap boundary, meaning it starts at a point (not a gap). Use expressive completeness + Prior-UZ to derive contradiction.
  - `formula_propagation_in_bad_interval`: If formula B holds for a while at the start of a class in a bad interval, then B holds throughout the bad interval. Proof: By Lemma 9, all classes agree on B. B propagates through class homogeneity.
  - `formula_near_class_boundaries`: If B holds anywhere in a bad interval, it holds arbitrarily close to each end of each class.

- [ ] **Task 2.7**: Model surgery construction (Lemma 12) -- domain and structure (~60 lines)
  - Choose a maximal bad interval Q0. Pick one ~M-class I inside Q0.
  - Define surgery domain: `Q_minus union I union Q_plus` as a subtype of `M.carrier`, where Q_minus = all points strictly below Q0, Q_plus = all points strictly above Q0.
  - Construct `OrderedMonadicStructure sig` on the surgery domain:
    - Carrier order: inherited from M (subtype order)
    - Predicate interpretation: inherited from M (restriction)
  - Prove the surgery model satisfies NoMaxOrder, NoMinOrder (Q_plus, Q_minus nonempty)

- [ ] **Task 2.8**: Model surgery truth preservation -- atom/bot/imp/box cases (~30 lines)
  - `surgery_truth_atom`: temporal_truth of `.atom a` is preserved (predicate interpretation is inherited)
  - `surgery_truth_bot`: trivial (both sides False)
  - `surgery_truth_imp`: from induction hypotheses on phi, psi
  - `surgery_truth_box`: temporal_truth of `.box phi` is preserved (predicate interpretation is inherited, since box is treated as a predicate in OrderedMonadicStructure)

- [ ] **Task 2.9**: Model surgery truth preservation -- U(A,B) forward direction (~100 lines)
  - Given: M |= U(A,B) at t (with witness s > t). Need: N |= U(A,B) at t.
  - 7 subcases based on position of t and s relative to Q_minus, I, Q_plus:

  | Subcase | t in | s in | Strategy |
  |---------|------|------|----------|
  | F1 | Q- | Q- | Direct IH: s is in N. B holds between t and s in M and N (all in Q-). |
  | F2 | Q- | Q0 | A holds somewhere in Q0, hence in I (class homogeneity, Lemma 9). B holds for a while into Q0, hence throughout Q0 (formula propagation, Lemma 11), hence throughout I. Take witness in I. |
  | F3 | Q- | Q+ | B holds throughout Q0 (by guard condition + Q0 between t and s), hence throughout I (restriction). A holds at s in Q+. IH gives A in N. B throughout I in N. |
  | F4 | I | I | Direct IH on both A at s and B between t and s (all in I, which is in N). |
  | F5 | I | Q0\I | A holds in Q0 at some class other than I. By class homogeneity (Lemma 9), A holds in I too. B holds from t to the boundary of Q0, hence throughout I (Lemma 11). Find witness in I. |
  | F6 | I | Q+ | B holds from t through end of Q0 (guard), hence throughout I (Lemma 11). A at s in Q+ by IH. |
  | F7 | Q+ | Q+ | Direct IH: both t and s in Q+, entirely within N. |

- [ ] **Task 2.10**: Model surgery truth preservation -- U(A,B) backward direction (~80 lines)
  - Given: N |= U(A,B) at t (with witness s > t in N). Need: M |= U(A,B) at t.
  - 6 subcases:

  | Subcase | t in | s in | Strategy |
  |---------|------|------|----------|
  | B1 | Q- | Q- | Direct IH. |
  | B2 | Q- | I | B holds from t to start of I in N (by guard). In M, B holds from t to start of Q0 (same points). B at start of Q0 in M, hence throughout Q0 (Lemma 11). A holds in I in M (by IH). |
  | B3 | Q- | Q+ | B holds from t through I in N. In M, B holds from t to start of Q0, and throughout Q0 (Lemma 11). A at s in Q+ by IH. |
  | B4 | I | I | Direct IH. |
  | B5 | I | Q+ | B holds from t through rest of I in N. In M, B holds from t through rest of Q0 (Lemma 11 + class homogeneity). A at s by IH. |
  | B6 | Q+ | Q+ | Direct IH. |

- [ ] **Task 2.11**: Model surgery truth preservation -- S(A,B) cases (~80 lines)
  - S(A,B) is the time-reverse of U(A,B). The subcases mirror U(A,B) with the direction reversed:
  - Forward S: M |= S(A,B) at t means exists s < t with A at s and B between. 7 subcases (mirror of U forward with < replacing >).
  - Backward S: N |= S(A,B) at t means exists s < t in N. 6 subcases (mirror of U backward).
  - Implementation: either manually mirror each case, or use an `Order.dual` trick to reduce to the U cases.

- [ ] **Task 2.12**: Contradiction and main theorem (Lemma 13 + Theorem 14) (~40 lines)
  - From surgery_truth_preservation: R holds at points of I in N (since R holds at I in M).
  - In N, the class containing I ends at the first point q of Q_plus (a successor boundary, not a gap, because Q_plus has a minimum element in N).
  - So right_gap_class does NOT hold at I in N (the class ends at q, a point, not at a gap).
  - R should be false at I in N. But surgery_truth_preservation says R is preserved. Contradiction.
  - Wire into `no_gaps_discrete_model_surgery`: replace sorry at line 348.

**Timing**: 12 hours

**Depends on**: none (but Phase 3 depends on this)

**Files to create/modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/GoodStructuresModelSurgery.lean` (MODIFY, add ~500 lines after line 348)

**Verification**:
- `lake build Bimodal.Metalogic.WeakCanonical.IntegerModel.GoodStructuresModelSurgery` succeeds
- `grep -n "sorry" GoodStructuresModelSurgery.lean` shows zero sorry
- `#print axioms no_gaps_discrete_model_surgery` shows no `sorryAx`

---

### Phase 3: Wire no_gaps_discrete to Model Surgery [NOT STARTED]

**Goal**: Close the sorry at GoodStructures.lean:852 by connecting `no_gaps_discrete`
to the sorry-free `no_gaps_discrete_model_surgery`.

**Context**: GoodStructures.lean imports from GoodStructuresModelSurgery.lean (no
circular import). The two theorems have identical signatures (both use h_surj).
The wiring is straightforward: replace the sorry body with a call to
`no_gaps_discrete_model_surgery`.

**Tasks**:
- [ ] **Task 3.1**: Wire no_gaps_discrete body (~5 lines)
  - Replace `sorry` at GoodStructures.lean:852 with:
    ```lean
    exact no_gaps_discrete_model_surgery sig k M atomMap h_surj h_prior_UZ h_prior_SZ a b h_diff_class
    ```
  - Verify import of GoodStructuresModelSurgery is present (it should already be imported by GoodStructures.lean; if not, add the import)

- [ ] **Task 3.2**: Verify downstream sorry-free propagation
  - `#print axioms no_gaps_discrete` shows no `sorryAx`
  - `#print axioms one_class` shows no `sorryAx`
  - `#print axioms chronicle_is_good_direct` shows no `sorryAx`

**Timing**: 0.5 hours

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/GoodStructures.lean` (replace sorry at line 852)

**Verification**:
- `lake build Bimodal.Metalogic.WeakCanonical.IntegerModel.GoodStructures` succeeds
- `grep "sorry" GoodStructures.lean` shows only documentation references (lines 813, 889-891), no active sorry
- `#print axioms one_class` shows no `sorryAx`

---

### Phase 4: Z-interval TaskFrame Packaging [NOT STARTED]

**Goal**: Close the engineering sorry at Transfer.lean:1162 by constructing a
TaskFrame countermodel from the Z-interval produced by `chronicle_is_good_direct`.

**Context**: After Phase 2+3, `chronicle_is_good_direct` is sorry-free and produces
a `ZIntervalStructure sig` called Z with k-equivalence to the chronicle monadic
structure. Step 7 (`truth_transfer`) gives a point s in Z where phi.neg holds under
temporal_truth. The remaining work is packaging Z as a `TaskFrame D` / `TaskModel` /
`truth_at` countermodel.

**Box modality tension** (identified in report 15, Section B.2-B.3):
- `temporal_truth` treats `.box phi` as a predicate: `M.interp(atomMap(.box phi)) t`
- `truth_at` treats `.box phi` via WorldHistory quantification: `forall tau in Omega, ...`
- Resolution: construct WorldHistory-based model where Omega captures the accessibility
  structure encoded in the box predicates. The chronicle's MCS assignment determines
  which box formulas hold at each point, and the WorldHistory encodes this as position-
  dependent world membership.

**Tasks**:
- [ ] **Task 4.1**: Prove Z-interval unboundedness (~30 lines)
  - Show that the Z-interval from `chronicle_is_good_direct` has `lo = none` and `hi = none`
  - The chronicle has `NoMaxOrder` and `NoMinOrder`. The `very_good_implies_good` construction via cofinal decomposition + shift-and-glue preserves unboundedness (each glue step adds an unbounded interval).
  - If unboundedness is hard to prove directly, use the alternative: show the Z-interval carrier is order-isomorphic to Z via `orderIsoIntOfLinearSuccPredArch` (which requires `IsSuccArchimedean` for the Z-interval -- but Z-intervals ARE archimedean by construction).

- [ ] **Task 4.2**: Construct TaskFrame and TaskModel (~60 lines)
  - `D = Int` (since the Z-interval is unbounded, carrier is isomorphic to Z)
  - `F : TaskFrame Int` using the default TaskFrame on Int (AddCommGroup, LinearOrder, etc.)
  - `TM : TaskModel F` with `task_atoms a t := temporal_truth Z.toOrdered atomMap_fwd (iso t) (.atom a)` where `iso : Int -> Z.carrier` is the order isomorphism
  - Define `Omega` (set of WorldHistories) and `ShiftClosed` to handle box modality:
    - `tau_t : WorldHistory := fun t' => { a : Atom | TM.task_atoms a (t + t') }` (shift by t)
    - `Omega := { tau_t | t : Int }`
    - `ShiftClosed` follows from shift definition

- [ ] **Task 4.3**: Prove truth_at correspondence for temporal connectives (~60 lines)
  - `truth_at TM Omega tau t (.atom a) <-> temporal_truth Z.toOrdered atomMap_fwd (iso t) (.atom a)` -- by definition of task_atoms
  - `truth_at TM Omega tau t (.bot) <-> False` -- both sides False
  - `truth_at TM Omega tau t (.imp phi psi) <-> ...` -- from IH
  - `truth_at TM Omega tau t (.untl phi psi) <-> temporal_truth ... (.untl phi psi)` -- by correspondence of Until quantification over the same linear order
  - `truth_at TM Omega tau t (.snce phi psi) <-> temporal_truth ... (.snce phi psi)` -- symmetric

- [ ] **Task 4.4**: Handle box modality correspondence (~50 lines)
  - `truth_at TM Omega tau t (.box phi) <-> temporal_truth Z.toOrdered atomMap_fwd (iso t) (.box phi)`
  - Left side: `forall tau' in Omega, truth_at TM Omega tau' 0 phi`
  - Right side: `Z.toOrdered.interp (atomMap_fwd (.box phi)) (iso t)`
  - The chronicle construction ensures `.box phi in MCS(t)` iff `phi` holds at all accessible worlds. The Z-interval inherits this via k-equivalence (since box is treated as a predicate, k-equivalence preserves its truth value). The WorldHistory construction in Task 4.2 must make this correspondence hold.
  - This is the most delicate step. If direct correspondence is too complex, an alternative is to prove correspondence only for box-free formulas and handle the box case via the MCS structure. Since `completeness_discrete` works with arbitrary formulas (including box), this alternative requires showing that the countermodel construction preserves box truth.

- [ ] **Task 4.5**: Assemble countermodel and replace sorry (~20 lines)
  - Combine all components: F, TM, Omega, ShiftClosed, tau (WorldHistory for root point), truth_at correspondence
  - Construct the existential witness for `countermodel_discrete_reynolds`
  - Replace sorry at Transfer.lean:1162

**Timing**: 4 hours

**Depends on**: 1, 3 (needs h_surj sorry-free from Phase 1, and no_gaps_discrete sorry-free from Phase 3)

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Transfer.lean` (replace sorry at line 1162)

**Verification**:
- `lake build Bimodal.Metalogic.WeakCanonical.Transfer` succeeds
- `#print axioms countermodel_discrete_reynolds` shows no `sorryAx`
- `grep -n "sorry" Transfer.lean` shows only dead BX pipeline references (countermodel_discrete at line ~1206), not the Reynolds pipeline

---

### Phase 5: Rewire completeness_discrete and Full Verification [NOT STARTED]

**Goal**: Replace the BX pipeline (`countermodel_discrete_enriched`) with the Reynolds
pipeline (`countermodel_discrete_reynolds`) in `completeness_discrete`, then perform
full project verification.

**Tasks**:
- [ ] **Task 5.1**: Rewire completeness_discrete (~20 lines)
  - In Completeness.lean, replace the discrete case branch that calls
    `countermodel_discrete_enriched` with a call to `countermodel_discrete_reynolds`
  - Adjust type signature handling: `countermodel_discrete_reynolds` returns a more general
    existential (with `D : Type` instead of fixing `Int`). May need to match on the additional
    existentials.
  - Add import of Transfer.lean in Completeness.lean if not already present

- [ ] **Task 5.2**: Deprecate BX pipeline artifacts (~20 lines of comments)
  - Add deprecation comment to `no_gaps_faithful` in ReynoldsModelSurgery.lean
  - Add deprecation comment to `countermodel_discrete_enriched` in Completeness.lean
  - Update module docstring of ReynoldsModelSurgery.lean to reference GoodStructuresModelSurgery.lean

- [ ] **Task 5.3**: Full build verification
  - `lake build` -- full project, zero errors
  - `#print axioms completeness_discrete` -- no `sorryAx`
  - `#print axioms completeness_dense` -- unchanged (no regression)
  - `grep -rn "sorry" Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/GoodStructuresModelSurgery.lean` -- no sorry
  - `grep -rn "sorry" Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/GoodStructures.lean` -- no active sorry (only doc references)
  - Verify no new sorry sites in any modified file

- [ ] **Task 5.4**: Update sorry audit documentation
  - If axiom audit comments exist in Completeness.lean, update to reflect sorry-free status
  - Note remaining sorries outside the Discrete critical path (countermodel_discrete for Base frame class, CaseAnalysis.lean Cases III/IV, StaviCompleteness.lean)

**Timing**: 1.5 hours

**Depends on**: 4

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` (rewire discrete case)
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/ReynoldsModelSurgery.lean` (deprecation)

**Verification**:
- `lake build` passes with zero errors
- `#print axioms completeness_discrete` shows no `sorryAx`
- `completeness_dense` unaffected (`#print axioms completeness_dense` unchanged)
- No new sorry sites in any modified files

## Testing & Validation

- [x] `#print axioms US_expressively_complete_over_prior` shows no `sorryAx` (prior plans)
- [x] h_surj signatures in place throughout chain (handoff: phase-1-h-surj-pivot)
- [x] GoodStructuresModelSurgery.lean infrastructure lemmas sorry-free (prior cycles)
- [x] h_accessible discharge in Transfer.lean sorry-free (plan v13 Phase 2 partial)
- [ ] h_surj sorry closed at Transfer.lean:1117 (Phase 1)
- [ ] Lemmas 6-13 proved in GoodStructuresModelSurgery.lean (Phase 2)
- [ ] `no_gaps_discrete_model_surgery` sorry closed (Phase 2)
- [ ] `no_gaps_discrete` sorry closed in GoodStructures.lean:852 (Phase 3)
- [ ] `#print axioms no_gaps_discrete` shows no `sorryAx` (Phase 3)
- [ ] `#print axioms one_class` shows no `sorryAx` (Phase 3)
- [ ] `#print axioms chronicle_is_good_direct` shows no `sorryAx` (Phase 3)
- [ ] Z-interval to TaskFrame packaging complete (Phase 4)
- [ ] `#print axioms countermodel_discrete_reynolds` shows no `sorryAx` (Phase 4)
- [ ] `completeness_discrete` rewired to Reynolds pipeline (Phase 5)
- [ ] `#print axioms completeness_discrete` shows no `sorryAx` (Phase 5)
- [ ] `lake build` passes with zero errors (Phase 5)
- [ ] No new sorry sites introduced (grep across all modified/created files)
- [ ] `completeness_dense` unaffected (Phase 5)

## Artifacts & Outputs

- `specs/202_reynolds_k_equivalence_bypass/plans/14_reynolds-model-surgery-definitive.md` (this plan)
- `Theories/Bimodal/Metalogic/WeakCanonical/PriorExpressiveness.lean` (EXISTING, sorry-free) -- Theorem 5
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/GoodStructuresModelSurgery.lean` (MODIFY, +~500 lines) -- Lemmas 6-13 + Theorem 14
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/GoodStructures.lean` (MODIFY) -- wire no_gaps_discrete
- `Theories/Bimodal/Metalogic/WeakCanonical/Transfer.lean` (MODIFY) -- close h_surj and packaging sorries
- `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` (MODIFY) -- rewire discrete case
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/ReynoldsModelSurgery.lean` (MODIFY) -- deprecation

## Rollback/Contingency

**Phase 1**: Modifies Transfer.lean to construct enriched atomMap. Reverting restores the sorry.
No side effects on other files.

**Phase 2**: Adds ~500 lines to GoodStructuresModelSurgery.lean (replacing the sorry at line 348).
Reverting restores the sorry. No changes to other files in this phase.

**Phase 3**: Changes one line in GoodStructures.lean (sorry -> call to model surgery).
Reverting restores the sorry.

**Phase 4**: Modifies Transfer.lean (packaging construction). Reverting restores the sorry.

**Phase 5**: Rewires Completeness.lean. Reverting restores the BX pipeline usage.

**Phase 2 contingencies**:
1. **If enriched-signature approach for Lemma 6 (R formula) is too complex**: Fall back to
   explicit monadic FO formula construction. The formula rho(x) can be built from the
   contemp_equiv definition using finitely many k-types. More verbose but conceptually
   simpler.
2. **If U(A,B) subcases exceed 200 lines**: Break each subcase into a separate lemma
   (`surgery_preserve_untl_F1`, ..., `surgery_preserve_untl_F7`, `surgery_preserve_untl_B1`,
   ..., `surgery_preserve_untl_B6`). Each is independent and self-contained.
3. **If model surgery domain construction is complex**: Use `Set.Elem` (subtype of
   M.carrier) rather than defining a new type. The OrderedMonadicStructure on the subtype
   inherits order and predicates trivially.
4. **If file exceeds 1000 lines**: Split into `GoodStructuresGapFormula.lean` (Lemmas 6-9)
   and `GoodStructuresModelSurgery.lean` (Lemmas 10-13 + Theorem 14).

**Phase 4 contingencies**:
1. **If box modality correspondence is intractable**: Factor completeness_discrete into
   box-free and box cases. For box-free formulas, packaging is straightforward. For box
   formulas, use the MCS structure directly.
2. **If Z-interval unboundedness is hard to establish**: Work with a possibly-bounded
   Z-interval and construct the TaskFrame on a bounded domain, using OrderIso to Int
   for the embedding.
3. **Ultimate fallback**: If both Reynolds packaging and the box modality correspondence
   prove intractable, consider the BX pipeline revival path (report 15, Part C). This
   avoids sorry #3 (packaging) by providing IsSuccArchimedean for the chronicle, but
   requires additional proof work beyond Theorem 14. This path was analyzed in report 15
   and found to offer no net savings, but may be preferable if the packaging challenge
   is specifically the blocking issue.

**General fallback**: Task 224 (finite insertion argument) provides an independent
approach to proving `IsSuccArchimedean` for the chronicle limit domain, which would
close `succ_cofinal` via the BX pipeline and achieve sorry-free `completeness_discrete`
without the Reynolds pipeline at all.
