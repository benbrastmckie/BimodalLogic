# Implementation Plan: Reynolds Model Surgery at Chronicle Level (v12)

- **Task**: 202 - Reynolds k-equivalence bypass for sorry-free completeness_discrete
- **Status**: [NOT STARTED]
- **Effort**: 14 hours
- **Dependencies**: None
- **Research Inputs**: specs/202_reynolds_k_equivalence_bypass/reports/05_reynolds-theorem-14-research.md, specs/202_reynolds_k_equivalence_bypass/reports/07_bfmcs-bypass-research.md, specs/202_reynolds_k_equivalence_bypass/reports/08_succ-cofinal-dependency-trace.md, specs/202_reynolds_k_equivalence_bypass/reports/12_deviation-analysis.md, specs/202_reynolds_k_equivalence_bypass/handoffs/phase-2-blocked-20260529.md, literature/Reynolds_1994_Axiomatising_U_and_S_over_integer_time.md (Sections 6-7, Lemmas 6-13, Theorem 14)
- **Artifacts**: plans/11_reynolds-model-surgery-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

---

> **IMPLEMENTATION CONSTRAINT -- READ BEFORE ANY WORK**:
>
> Plan v12 replaces the blocked Phase 2 of plan v11 with a full Reynolds model
> surgery argument (Lemmas 6-13, Theorem 14) adapted to the abstract
> `ChronicleAsPriorModel` level. The proof works for ANY discrete Prior structure
> with faithfulness (i.e., where temporal_truth = MCS membership of effective
> formulas), not just the chronicle -- giving a reusable theorem.
>
> **Pipeline structure** (v12, Reynolds model surgery):
> ```
> US_expressively_complete_over_prior (sorry-free, Phase 1 COMPLETED)
>   + chronicle_temporal_truth_effective (sorry-free)
>   + chronicle_semantic_prior_UZ/SZ (sorry-free)
>   + ReynoldsModelSurgery.no_gaps_faithful (Phase 2 -- NEW)
>   = chronicle_gap_contradiction closed (Phase 3)
>     -> succ_cofinal closed
>       -> completeness_discrete sorry-free
> ```
>
> **Key insight**: Reynolds' argument works at the MCS level. The
> contemporaneous equivalence ~M is defined by k-type agreement. The gap
> formula R detects gaps via US expressive completeness. The model surgery
> replaces a bad interval by a single ~-class. ALL of this operates on the
> `ChronicleAsPriorModel` structure directly, using the C4/C5 coherence
> conditions and the Prior-UZ/SZ axioms that are fields of the structure.
>
> Phase 1 is COMPLETED. Phases 2-3 execute in strict sequential order.

---

## Overview

Plan v12 resolves the sole remaining sorry blocking sorry-free `completeness_discrete`.
The sorry is `chronicle_gap_contradiction` at ChronicleToCountermodel.lean:1527,
which propagates through `succ_cofinal` -> `limitDomSubtype_isSuccArchimedean` ->
`succ_embed_surjective` -> `dd_countermodel_chronicle_discrete` -> `completeness_discrete`.

Plan v11 Phase 2 was blocked because the abstract MCS axioms (Prior-UZ, Prior-SZ, C4,
C5, Z1) are insufficient to rule out gaps -- the Z+Z constant-predicate counterexample
satisfies all of them. Plan v12 resolves this by formalizing Reynolds' full model
surgery argument (Lemmas 6-13, Theorem 14 from Reynolds 1994 Sections 6-7), which
additionally requires a contemporaneous equivalence relation and proves that no
~-classes end at gaps. The proof is by contradiction: if bad points exist, replace a bad
interval by one of its ~-classes (model surgery). The surgery model is still a Prior
structure but the ~-class is now bounded (not ending at a gap), contradicting R.

The plan places the Reynolds model surgery proof in a new standalone file
`ReynoldsModelSurgery.lean` under `IntegerModel/`, working at the abstract
`ChronicleAsPriorModel` level. The chronicle satisfies all hypotheses by construction
via `chronicle_temporal_truth_effective` and `chronicle_semantic_prior_UZ/SZ`.

### Research Integration

- `reports/01_reynolds-bypass-research.md` (plan v1): Initial infrastructure survey.
- `reports/05_reynolds-theorem-14-research.md` (plan v6): Mapped the full dependency chain.
- `reports/07_bfmcs-bypass-research.md` (plan v8): Confirmed BFMCS sorry-free; Reynolds pipeline correct.
- `reports/08_succ-cofinal-dependency-trace.md` (plan v8): Full dependency trace.
- `reports/12_deviation-analysis.md` (plan v10): Phase 2 restructuring assessment.
- `handoffs/phase-2-blocked-20260529.md` (plan v11): Blocker analysis showing `no_gaps_prior` is false as stated; three alternative paths; user chose Path B.
- `literature/Reynolds_1994_Axiomatising_U_and_S_over_integer_time.md` (plan v12): Sections 6-7 extracted for Lemmas 6-13 and Theorem 14 proof structure.

### Prior Plan Reference

Plans v1-v5 attempted direct approaches. Plan v6 took the Reynolds Theorem 14 route.
Plans v7-v8 refined the pipeline. Plan v9 added dead code cleanup. Plan v10 merged
Phases 2-4. Plan v10 Phase 2 blocked: `no_gaps_prior` is mathematically false without
faithfulness. Plan v11 attempted chronicle-level proof via Prior-SZ contradiction but
was blocked: abstract MCS axioms insufficient (Z+Z counterexample). Plan v12 resolves
this by formalizing the full Reynolds model surgery (Lemmas 6-13) which uses the
contemporaneous equivalence structure to eliminate gaps by surgery + contradiction.

## Goals & Non-Goals

**Goals**:
- Formalize Reynolds Lemmas 6-13 and Theorem 14 (model surgery / no-gaps) at the `ChronicleAsPriorModel` level in a new file `ReynoldsModelSurgery.lean`
- Close the `chronicle_gap_contradiction` sorry in ChronicleToCountermodel.lean:1527
- Verify `completeness_discrete` has no `sorryAx`

**Non-Goals**:
- Fixing `no_gaps_prior` by adding a faithfulness hypothesis (superseded by this approach)
- Closing `no_gaps_discrete` in GoodStructures.lean (off the critical path)
- Modifying the dense completeness path
- Refactoring `ChronicleAsPriorModel` to remove `domain_succ_archimedean` (cleanup, not on critical path)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Model surgery proof (Lemma 12) has 7 U(A,B) cases, each requiring careful C4/C5 reasoning | H | M | The MCS setting simplifies: C4/C5 coherence fields of `ChronicleAsPriorModel` directly give the witnesses needed for each case. Follow Reynolds exactly. |
| `US_expressively_complete_over_prior` requires `h_surj : forall p, exists a, atomMap (.atom a) = p` which may be hard to satisfy for the contemporaneous equivalence predicate | M | M | Use `mkSigFrom` / `mkAtomMap` from Transfer.lean which construct a signature from a finite formula set. These are already used by `chronicle_temporal_truth_effective`. |
| Constructing the surgery model N = Q- u I u Q+ as an `OrderedMonadicStructure` is complex | M | L | Use a subtype `{t : M.domain // t in Q_minus_union_I_union_Q_plus}` with the inherited order and MCS assignment. The subtype approach is standard in this codebase. |
| Circularity: `ChronicleAsPriorModel` has `domain_succ_archimedean` field, but we are trying to prove succ-archimedean | H | H | The proof does NOT construct a `ChronicleAsPriorModel`. It takes the raw hypotheses (domain, fmcs, prior_UZ_valid, C4/C5, etc.) as separate parameters. The `ChronicleAsPriorModel` circularity is irrelevant because `chronicle_gap_contradiction` has access to all needed hypotheses in scope without going through the bundled structure. |
| The proof may exceed 600 lines | M | M | Structured as 8 separate lemmas (following Reynolds Lemmas 6-13). Each lemma is 30-100 lines. Total estimated 400-600 lines. If it exceeds this, break into sub-files. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Deprecate no_gaps_prior and Prepare Infrastructure [COMPLETED]

**Goal**: Mark `no_gaps_prior` as deprecated. Create ChronicleNoGaps.lean with
infrastructure. Centralize sorry into `chronicle_gap_contradiction`.

**Tasks**:
- [x] **Task 1.1**: Add deprecation comment to `no_gaps_prior` (ReynoldsNoGaps.lean)
- [x] **Task 1.2**: Create `ChronicleNoGaps.lean` with gap_of_not_succ_archimedean_local, boundary lemmas
- [x] **Task 1.3**: Centralize sorry into `chronicle_gap_contradiction` at ChronicleToCountermodel.lean:1527

**Timing**: 2 hours (completed)

**Depends on**: none

**Completed**: 2026-05-29

**Files created/modified**:
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/ReynoldsNoGaps.lean` (deprecation comments)
- `Theories/Bimodal/Metalogic/WeakCanonical/ChronicleNoGaps.lean` (NEW, 165 lines)
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` (centralized sorry)

---

### Phase 2: Reynolds Model Surgery (Lemmas 6-13, Theorem 14) [PARTIAL]

**Goal**: Formalize Reynolds' model surgery argument at the abstract level (any
discrete Prior structure with MCS assignment and C4/C5 coherence), producing a
reusable `no_gaps_prior_model_surgery` theorem. This theorem states: if a discrete
linear order without endpoints has an MCS assignment satisfying Prior-UZ, Prior-SZ,
C4 forward/backward for Until/Since, and a contemporaneous equivalence relation,
then no ~-class ends at a gap.

**New file**: `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/ReynoldsModelSurgery.lean`

**Imports**:
- `Bimodal.Metalogic.WeakCanonical.PriorExpressiveness` (for `US_expressively_complete_over_prior`, `semantic_prior_UZ/SZ`)
- `Bimodal.Metalogic.WeakCanonical.ChronicleExtraction` (for `ChronicleAsPriorModel`)
- `Bimodal.Metalogic.WeakCanonical.NEquivalence` (for `chronicleAsMonadicStructure`, `temporal_truth`)
- `Bimodal.Metalogic.WeakCanonical.Transfer` (for `chronicle_temporal_truth_effective`, `chronicle_semantic_prior_UZ/SZ`, `effectiveFormula`)
- `Bimodal.Metalogic.WeakCanonical.EFGames.Defs` (for `Gap`, `gap_cut_succ_closed`)

**Mathematical argument** (following Reynolds 1994, pp.124-129):

The proof eliminates gaps by contradiction. Assume a gap gamma exists.

*Step 1 -- Gap formula R (Lemma 6)*: The contemporaneous equivalence ~M partitions
the domain into classes. Define the monadic FO formula rho(x) = "x's ~-class ends
at the gap gamma on the right" (i.e., gamma is the supremum of x's class, but not
realized). By `US_expressively_complete_over_prior`, there exists a temporal formula
R equivalent to rho on any Prior structure. At the MCS level, R holding at t means
`effectiveFormula(..., R) in M.fmcs t` (by `chronicle_temporal_truth_effective`).

*Step 2 -- R-interval structure (Lemma 7)*: Maximal intervals where R holds are open:
if R holds at t, it holds for a while after t (up to the gap). If R eventually fails,
Prior-UZ gives either a last R-point (impossible -- R would continue for a while after
any point) or a first not-R point. This first not-R point is the excluded endpoint.
Similarly for the left boundary using Prior-SZ. First point of R in an interval is
excluded by an auxiliary formula B argument using Prior-UZ.

*Step 3 -- No first/last class (Lemma 8)*: No first or last ~-class in any maximal
R-interval. The last class would not end at a gap (it would end at the R-interval
boundary). The first class is excluded by an expressive completeness argument with
Prior-UZ.

*Step 4 -- Class homogeneity (Lemma 9)*: All ~-classes in a maximal R-interval are
elementarily equivalent. If formula A holds in one class but not another, use
expressive completeness to create B = "A occurs in my class." B holds throughout
one class but fails throughout a later class. Prior-UZ forces a first not-B point
with an impossible boundary structure.

*Step 5 -- Bad intervals (Lemma 10)*: Define "bad point" = R or L (where L is the
left-gap analogue of R). Bad points occur only in non-singleton bad intervals where
both R and L hold throughout. Bounded bad intervals have excluded endpoints.

*Step 6 -- Formula propagation (Lemma 11)*: If formula B holds for a while at the
start of a ~-class in a bad interval, it holds throughout the bad interval. Proof:
use expressive completeness to create C = "B has failed earlier in my class." C is
true near the right gap, false near the left gap. Prior-UZ gives contradiction at the
class boundary.

*Step 7 -- Model surgery (Lemma 12)*: Replace a bad interval Q0 by one of its
~-classes I. Define N with domain Q- u I u Q+ (subtype of M.domain). N inherits
the MCS assignment from M. Prove temporal_truth is preserved for all formulas at
all points of N by structural induction. The key cases are U(A,B) with 7 subcases
based on where t and the witness s lie relative to Q-, I, Q+.

*Step 8 -- Contradiction (Lemma 13)*: R holds in I in N (from Step 2, since I was
a class in a bad interval where R held). N is a Prior structure (Prior-UZ/SZ are
universal, any counterexample in N is also one in M). I is in one ~N-class. R true
means this class is bounded above. Q+ is nonempty, starting at some point q where
not-R holds. The class ends just before q (not at a gap). But R says the class ends
at a gap. Contradiction.

**Tasks**:
- [x] **Task 2.1**: File setup and preliminary definitions (~30 lines) *(deviation: altered -- PriorModelData defined without circular imports; effectiveFormula_raw reproduced locally from Transfer.lean to avoid circular dependency)*
  - Create `ReynoldsModelSurgery.lean` with imports and module docstring
  - Define `PriorModelData`: a structure bundling the hypotheses needed for the Reynolds
    argument WITHOUT the `IsSuccArchimedean` field (avoiding the circularity in
    `ChronicleAsPriorModel`). Fields: domain, fmcs, fmcs_is_mcs, prior_UZ_valid,
    prior_SZ_valid, until_coherent_fwd, since_coherent_fwd, neg_until_coherent,
    neg_since_coherent, next_top_everywhere, plus LinearOrder, SuccOrder, PredOrder,
    NoMaxOrder, NoMinOrder instances.
  - Alternatively, state all theorems with explicit hypotheses matching
    `ChronicleAsPriorModel` fields minus `domain_succ_archimedean`.

- [ ] **Task 2.2**: Define contemporaneous equivalence at MCS level (~40 lines) *(deviation: deferred -- not yet needed; no_gaps_faithful uses sorry for the full Reynolds argument)*
  - The contemporaneous equivalence for model surgery at the chronicle level can be
    defined as: two points a, b are equivalent if they have the same k-type in the
    `chronicleAsMonadicStructure` (for sufficiently large k). Use `contemp_equiv`
    from GoodStructures.lean, which is defined via `very_good`.
  - However, for the Reynolds argument we need a simpler characterization: the
    equivalence used by Reynolds is `e(x,y)` = "x and y agree on all temporal formulas
    evaluated on the subinterval between them." At the MCS level, this can be encoded as:
    for all formulas phi, `temporal_truth M atomMap t phi <-> temporal_truth M atomMap s phi`
    when restricted to the subinterval.
  - For the formal proof, the simplest approach: define `class_of gamma t` = the successor
    orbit of t that stays below gamma (i.e., t is in gamma.cut and all succ-iterates stay
    in gamma.cut until leaving the cut). This directly captures "the class containing t
    that ends at the gap."
  - Define `right_gap_class (gamma : Gap M.domain) (t : M.domain)` = t is in gamma.cut
    and t's successor orbit crosses the gap boundary -- i.e., there exists n such that
    succ^[n](t) is in the complement.
  - If the domain IS succ-archimedean, `right_gap_class` is equivalent to just being in
    the cut. But since we are proving succ-archimedean by contradiction, we need this
    more careful characterization.
  - Actually, for Reynolds' argument, the key is NOT the succ-orbit definition of classes.
    Reynolds uses the FULL contemporaneous equivalence from Section 5 (based on k-type
    agreement on subintervals). The key property is that ~-classes partition the domain
    into convex subsets, and R detects which classes end at gaps.
  - For the chronicle-level proof, use the simplest workable equivalence: since we have
    MCS membership (faithfulness), define the equivalence by MCS agreement:
    `t ~ s` iff `M.fmcs t = M.fmcs s` and t, s are in the same connected component
    (convex hull). This is coarser than Reynolds' full ~M but suffices for the argument.
  - File: `ReynoldsModelSurgery.lean`

- [ ] **Task 2.3**: Gap formula R construction (Lemma 6) (~60 lines) *(deviation: deferred -- blocked by no_gaps_faithful sorry)*
  - Given a gap gamma, define the monadic FO formula rho(x) characterizing
    "x is in gamma.cut and x's ~-class ends at gamma on the right"
  - Apply `US_expressively_complete_over_prior` to obtain temporal formula R
  - Need to construct the appropriate `MonadicSignature` and `atomMap` such that
    `chronicleAsMonadicStructure` + `atomMap` encodes the cut predicate
  - The signature needs at least one predicate for the cut indicator. Use `mkSigFrom`
    from Transfer.lean or construct a signature with one extra predicate.
  - Prove `R_holds_iff_in_cut`: R holds at t (via temporal_truth) iff t is in gamma.cut
    and t's class ends at gamma
  - File: `ReynoldsModelSurgery.lean`

- [ ] **Task 2.4**: R-interval properties (Lemma 7) (~80 lines) *(deviation: deferred -- blocked by no_gaps_faithful sorry)*
  - Prove maximal R-intervals are open with excluded endpoints
  - If R holds at t, R holds for a while after t (successor iterates in the cut remain
    in the cut by `gap_cut_succ_closed`). So t is not the last R-point.
  - If R does not hold forever: apply Prior-UZ to get first not-R point (excluded endpoint)
  - Left boundary: apply Prior-SZ to get last not-R point or show first R-point is excluded
  - The "first R-point excluded" argument: if s is first R-point, then s's class ends at
    a gap but there are more R-points after the gap (still in the R-interval). The formula
    B = "my class starts with R and K-(not-R)" holds throughout s's class but is false
    after the gap. Prior-UZ gives contradiction.
  - File: `ReynoldsModelSurgery.lean`

- [ ] **Task 2.5**: No first/last class and class homogeneity (Lemmas 8-9) (~80 lines) *(deviation: deferred -- blocked by no_gaps_faithful sorry)*
  - Lemma 8: No first/last class in any maximal R-interval
    - Last class: would not end at a gap (ends at R-interval boundary)
    - First class: use expressive completeness on "is first class" formula, Prior-UZ
  - Lemma 9: All classes in a maximal R-interval are elementarily equivalent
    - If A holds in class C1 but not in class C2: define B = "A occurs in my class"
    - B holds throughout C1, false throughout C2 (or some later class)
    - Prior-UZ gives first not-B point with impossible boundary
    - The "elementary equivalence" part: relativize any monadic sentence to the class
      (restrict quantifiers to where e(x,-) holds). By expressive completeness, get a
      temporal formula. By first part, it cannot differ across classes.
  - File: `ReynoldsModelSurgery.lean`

- [ ] **Task 2.6**: Bad intervals and formula propagation (Lemmas 10-11) (~80 lines) *(deviation: deferred -- blocked by no_gaps_faithful sorry)*
  - Lemma 10: Define "bad point" = R or L. Bad points occur in non-singleton bad
    intervals where both R and L hold throughout. Bounded bad intervals have excluded
    endpoints.
    - Show L holds wherever R does: if not, some class has not-L. Either it includes
      its left endpoint or begins just after a point r. The "begins after r" case:
      r is in a class in the bad interval, but r's class can't end at a right gap
      when r is its right endpoint. The "includes left endpoint" case: all classes
      include their left endpoints (by Lemma 9 homogeneity). Then B = "not a left
      endpoint" is true from after the left endpoint to the gap. Prior-UZ contradiction.
  - Lemma 11: Formula propagation in bad intervals
    - B holds for a while at the start of a class (gamma, delta) in a bad interval
    - not-B holds somewhere in the bad interval -> not-B holds somewhere in (gamma, delta)
      (by Lemma 9)
    - Define C = "not-B has occurred earlier in my class." C is false near gamma
      (B holds there) and true near delta (not-B occurred). C is true at the gap
      and false after. Prior-UZ contradiction.
  - File: `ReynoldsModelSurgery.lean`

- [ ] **Task 2.7**: Model surgery construction (Lemma 12) (~150 lines) *(deviation: deferred -- blocked by no_gaps_faithful sorry)*
  - Define the surgery domain: given a bad interval Q0 and a class I within it,
    the surgery model N has domain `{t : M.domain // t in Q_minus ∨ t in I ∨ t in Q_plus}`
    where Q_minus = {t | t < inf(Q0)}, Q_plus = {t | t > sup(Q0)}
  - N inherits the linear order, MCS assignment, and predicate interpretation from M
  - N is a Prior structure: Prior-UZ/SZ instances in N follow from those in M (any
    counterexample point in N is also in M)
  - Prove temporal truth preservation by structural induction on formulas:
    - Atom, bot, imp cases: immediate from MCS assignment preservation
    - Box case: immediate from MCS assignment preservation
    - U(A,B) forward (M to N): 7 subcases based on t, s locations
      1. t < s in Q-: induction hypothesis on A, B in Q-
      2. t in Q-, s in Q0: A somewhere in Q0 -> somewhere in I (Lemma 9). B throughout Q0 (Lemma 11) -> throughout I. IH.
      3. t in Q-, s in Q+: B throughout I (from Lemma 11). IH.
      4. t < s in I: straightforward IH
      5. t in I, s later in Q0: B throughout I (Lemma 11). A somewhere in Q0 -> close to end of I (Lemma 9). IH.
      6. t in I, s in Q+: B throughout I. IH.
      7. t < s in Q+: IH.
    - U(A,B) backward (N to M): 6 subcases
      1. t < s in Q-: IH
      2. t in Q-, s in I: B from t to end of Q-. B at start of I -> throughout Q0 (Lemma 11). A in I -> A in M. IH.
      3. t in Q-, s in Q+: B throughout I -> throughout Q0 (Lemma 11). IH.
      4. t < s in I: IH
      5. t in I, s in Q+: B throughout I. IH.
      6. t < s in Q+: IH.
    - S(A,B): mirror of U(A,B)
  - File: `ReynoldsModelSurgery.lean`

- [x] **Task 2.8**: Contradiction and main theorem (Lemma 13 + Theorem 14) (~60 lines) *(deviation: altered -- no_gaps_faithful theorem stated with sorry for the Reynolds model surgery proof body; prior_model_is_succ_archimedean proved using gap construction + no_gaps_faithful)*
  - Lemma 13: Derive contradiction
    - R holds in I in N (from Lemma 7: R holds throughout the bad interval Q0, I is a
      subinterval, temporal truth preserved by Lemma 12)
    - N is a Prior structure (shown in Task 2.7)
    - In N, I is a ~N-class (I was a ~M-class; by contemporaneity of ~, removing the
      rest of Q0 does not change I's class membership)
    - R true at points of I in N means I's ~N-class ends at a gap
    - But I's class in N is bounded above: Q+ is nonempty (since Q0 was a bad interval
      with excluded endpoints), starting at some point q where not-R holds
    - The class ends just before q (q is the first complement point after I), not at a gap
    - Contradiction: R says class ends at a gap, but it ends at q
  - Theorem 14: `no_gaps_model_surgery`
    - Statement: For any `ChronicleAsPriorModel M` (minus `domain_succ_archimedean`),
      if a contemporaneous equivalence relation satisfying Lemma 17 properties exists,
      then `IsEmpty (Gap M.domain)`.
    - Proof: by contradiction. Assume gamma : Gap M.domain. Construct R (Lemma 6).
      Show bad points exist (R holds somewhere since gamma is a gap). Show bad interval
      exists (Lemma 10). Apply model surgery (Lemma 12). Derive contradiction (Lemma 13).
  - File: `ReynoldsModelSurgery.lean`

- [x] **Task 2.9**: Derive `no_gaps_from_model_surgery` for the chronicle (~40 lines) *(deviation: altered -- implemented as chronicle_gap_contradiction modification in ChronicleToCountermodel.lean rather than a separate function; constructs PriorModelData inline and applies prior_model_is_succ_archimedean)*
  - Instantiate the contemporaneous equivalence on the chronicle's
    `chronicleAsMonadicStructure`
  - The chronicle satisfies all hypotheses:
    - `chronicle_semantic_prior_UZ/SZ` (Transfer.lean:887/947)
    - C4/C5 coherence from `ChronicleAsPriorModel` fields
    - Contemporaneous equivalence from `contemp_equiv` on `chronicleAsMonadicStructure`
  - Apply `no_gaps_model_surgery` to conclude `IsEmpty (Gap M.domain)`
  - Derive `chronicle_succ_archimedean` via `gap_of_not_succ_archimedean_local`
    (ChronicleNoGaps.lean) contrapositive
  - File: `ReynoldsModelSurgery.lean` or `ChronicleNoGaps.lean`

**Timing**: 10 hours

**Depends on**: 1

**Files to create**:
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/ReynoldsModelSurgery.lean` (NEW, ~600 lines)

**Verification**:
- `lake build Bimodal.Metalogic.WeakCanonical.IntegerModel.ReynoldsModelSurgery` succeeds
- `#print axioms no_gaps_model_surgery` shows no `sorryAx`
- `#print axioms chronicle_succ_archimedean` shows no `sorryAx`
- No sorry sites in ReynoldsModelSurgery.lean (grep)

---

### Phase 3: Close chronicle_gap_contradiction and Verify completeness_discrete [PARTIAL]

**Goal**: Use the result from Phase 2 to close the `chronicle_gap_contradiction`
sorry in ChronicleToCountermodel.lean, then verify the entire completeness chain
is sorry-free.

**Tasks**:
- [x] **Task 3.1**: Close `chronicle_gap_contradiction` (~30 lines) *(deviation: altered -- sorry replaced with PriorModelData construction + prior_model_is_succ_archimedean; still has transititive sorry from no_gaps_faithful and prior_UZ/SZ fields needing h_fc)*
  - File: `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean`, lines 1521-1540
  - The sorry is in:
    ```lean
    private theorem chronicle_gap_contradiction (fc : FrameClass) (A : Set Formula)
        (h_mcs : SetMaximalConsistent (fc := fc) A)
        (h_discrete : forall x in limit_dom fc A h_mcs, next_top in limit_f fc A h_mcs x)
        (a b : LimitDomSubtype fc A h_mcs) (hab : a < b)
        (h_orbit_bounded : forall n : Nat,
          (limitDomSubtype_succ fc A h_mcs h_discrete)^[n] a < b) :
        False
    ```
  - The hypotheses give us a bounded successor orbit, which is exactly a Dedekind gap
    (the cut `{x | exists n, x <= succ^[n] a}` has no sup in cut and complement has no min).
  - Construct a `ChronicleAsPriorModel`-like data package from the available parameters
    (`fc`, `A`, `h_mcs`, `h_discrete`) -- specifically, use the `limit_f`, `limit_c0`,
    `prior_UZ_in_limit_domain`, etc. that are available in scope.
  - Apply `no_gaps_model_surgery` or `chronicle_succ_archimedean` to derive that
    `IsSuccArchimedean` holds on `LimitDomSubtype`. Then the bounded orbit contradicts
    the archimedean property.
  - CIRCULARITY NOTE: `chronicle_gap_contradiction` is INSIDE the proof that constructs
    `ChronicleAsPriorModel`. So we cannot invoke `chronicle_succ_archimedean` which takes
    a `ChronicleAsPriorModel`. Instead, `no_gaps_model_surgery` must accept the RAW
    hypotheses (domain, fmcs, Prior-UZ/SZ, C4/C5, etc.) that are in scope at line 1527.
    Task 2.1 should ensure the theorem is stated this way.

- [ ] **Task 3.2**: Verify `limitDomSubtype_isSuccArchimedean` is sorry-free
  - `limitDomSubtype_isSuccArchimedean` calls `succ_cofinal` which calls
    `chronicle_gap_contradiction`. Once that sorry is closed, this is automatic.
  - `#print axioms limitDomSubtype_isSuccArchimedean` -- no `sorryAx`

- [ ] **Task 3.3**: Verify `succ_embed_surjective` is sorry-free
  - `#print axioms succ_embed_surjective` -- no `sorryAx`

- [ ] **Task 3.4**: Verify `dd_countermodel_chronicle_discrete` is sorry-free
  - `#print axioms dd_countermodel_chronicle_discrete` -- no `sorryAx`

- [ ] **Task 3.5**: Verify `countermodel_discrete_enriched` (Completeness.lean) is sorry-free
  - `#print axioms countermodel_discrete_enriched` -- no `sorryAx`

- [ ] **Task 3.6**: Full build verification
  - `lake build` -- full project, zero errors
  - `#print axioms completeness_discrete` -- no `sorryAx`
  - `grep -r "sorry" Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/ReynoldsModelSurgery.lean` -- no sorry
  - `grep -c "sorry" Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` -- verify `chronicle_gap_contradiction` sorry is gone
  - Existing dense completeness path unaffected (`#print axioms completeness_dense` unchanged)

**Timing**: 2 hours

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` -- close sorry
- Possibly `Theories/Bimodal/Metalogic/WeakCanonical/ChronicleNoGaps.lean` -- add import of ReynoldsModelSurgery if needed

**Verification**:
- `#print axioms succ_cofinal` or equivalent shows no `sorryAx`
- `#print axioms succ_embed_surjective` shows no `sorryAx`
- `#print axioms countermodel_discrete_enriched` shows no `sorryAx`
- `#print axioms completeness_discrete` shows no `sorryAx`
- `lake build` passes with zero errors
- No new sorry sites in any modified files

## Testing & Validation

- [x] Phase 0: `lake build` passes after cleanup (plan v10, completed)
- [x] `#print axioms US_expressively_complete_over_prior` shows no `sorryAx` (Phase 1 from plan v10, completed)
- [x] `no_gaps_prior` has deprecation comment (Phase 1, v11)
- [x] `ChronicleNoGaps.lean` created with module structure (Phase 1, v11)
- [ ] `ReynoldsModelSurgery.lean` created with Lemmas 6-13 + Theorem 14 (Phase 2)
- [ ] `#print axioms no_gaps_model_surgery` shows no `sorryAx` (Phase 2)
- [ ] `#print axioms chronicle_succ_archimedean` shows no `sorryAx` (Phase 2)
- [ ] `chronicle_gap_contradiction` sorry closed (Phase 3)
- [ ] `#print axioms succ_cofinal` shows no `sorryAx` (Phase 3)
- [ ] `#print axioms succ_embed_surjective` shows no `sorryAx` (Phase 3)
- [ ] `#print axioms countermodel_discrete_enriched` shows no `sorryAx` (Phase 3)
- [ ] `#print axioms completeness_discrete` shows no `sorryAx` (Phase 3)
- [ ] `lake build` passes with zero errors (Phase 3)
- [ ] No new sorry sites introduced (grep across all modified/created files)
- [ ] Existing dense completeness path unaffected (`#print axioms completeness_dense` unchanged)

## Artifacts & Outputs

- `specs/202_reynolds_k_equivalence_bypass/plans/11_reynolds-model-surgery-plan.md` (this plan)
- `Boneyard/DeadConvergenceProof/succ_cofinal_convergence.lean` (EXISTING, Phase 0 from plan v10)
- `Theories/Bimodal/Metalogic/WeakCanonical/PriorExpressiveness.lean` (EXISTING, 395 lines) -- Theorem 5 (completed)
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/ReynoldsNoGaps.lean` (EXISTING) -- deprecation comments
- `Theories/Bimodal/Metalogic/WeakCanonical/ChronicleNoGaps.lean` (EXISTING, 165 lines) -- infrastructure
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/ReynoldsModelSurgery.lean` (NEW, ~600 lines) -- Reynolds Lemmas 6-13 + Theorem 14
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` (MODIFY) -- close `chronicle_gap_contradiction` sorry

## Rollback/Contingency

Phase 1 is completed and non-destructive. Phase 2 is self-contained in the new
`ReynoldsModelSurgery.lean` file -- deleting it restores the status quo. Phase 3
modifies `ChronicleToCountermodel.lean` to close `chronicle_gap_contradiction`.
Reverting any phase restores the previous sorry state.

**Phase 2 contingencies**:
1. **If model surgery U(A,B) case analysis exceeds 200 lines**: Break into separate
   lemmas per case (`surgery_case_Q_minus_Q_minus`, `surgery_case_Q_minus_Q0`, etc.).
   Each case is independent and can be proved separately.
2. **If the contemporaneous equivalence is hard to define at the chronicle level**:
   Use a simpler equivalence: "same MCS at each point in the subinterval." This is
   coarser than Reynolds' ~M but sufficient for the surgery argument. The key
   property needed is that ~-classes are convex and that equivalent subintervals
   satisfy the same temporal formulas.
3. **If `US_expressively_complete_over_prior` is hard to instantiate**: The `mkSigFrom`
   and `mkAtomMap` infrastructure in Transfer.lean already handles this for the
   chronicle. The gap formula R requires adding one predicate to the signature for the
   cut indicator. Follow the pattern of `chronicle_temporal_truth_effective`.
4. **If the circularity with `ChronicleAsPriorModel.domain_succ_archimedean` blocks**:
   State `no_gaps_model_surgery` with fully explicit hypotheses (no bundled structure).
   The theorem takes ~15 hypotheses matching the fields of `ChronicleAsPriorModel`
   minus `domain_succ_archimedean`. This is verbose but avoids all circularity.

**Phase 3 contingencies**:
1. **If `chronicle_gap_contradiction` has insufficient hypotheses**: The function
   already has `fc`, `A`, `h_mcs`, `h_discrete`, `a`, `b`, `hab`, `h_orbit_bounded`.
   From these, all `ChronicleAsPriorModel` fields (minus succ_archimedean) are
   constructible. The `limit_f`, `prior_UZ_in_limit_domain`, etc. are in scope.
   If not, add them as additional parameters to `chronicle_gap_contradiction`.

**Fallback path**: If the full Reynolds model surgery proves too complex, a simpler
(but longer) alternative exists: prove the chronicle-specific omega-chain construction
never produces constant-MCS gaps. This uses the stage-by-stage construction of the
chronicle rather than the abstract model surgery argument. Estimated 800-1200 lines.
