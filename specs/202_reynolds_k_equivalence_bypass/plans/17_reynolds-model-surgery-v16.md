# Implementation Plan: Task #202 -- Reynolds Model Surgery v16

- **Task**: 202 - Reynolds k-equivalence bypass for sorry-free completeness_discrete
- **Status**: [NOT STARTED]
- **Effort**: 18 hours
- **Dependencies**: None
- **Research Inputs**: reports/16_team-research.md, reports/16_teammate-a-findings.md, reports/16_teammate-b-findings.md, reports/16_teammate-c-findings.md, reports/16_teammate-d-findings.md, plans/16_reynolds-model-surgery-v15.md (prior plan), handoffs/phase-1-monadic-formula-blocked-20260530.md (blocker analysis)
- **Artifacts**: plans/17_reynolds-model-surgery-v16.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Plan v16 revises v15 to address the Phase 1 blocker: constructing `MonadicFormula sig 1` encoding `right_gap_class_prop` requires bounded quantifier relativization infrastructure (~200 lines) not present in the codebase. The blocker handoff (2026-05-30) confirmed that all four attempted approaches (Classical.choice, direct NormalForm enumeration, table roundtrip, direct temporal formula) fail without formalizing how quantifiers over the full carrier relativize to quantifiers over a subinterval.

This plan adds a new Phase 0 that builds the relativization infrastructure in MonadicFO.lean, then the subsequent phases (renumbered from v15) proceed as before. The total effort increases from 16 to 18 hours to account for the new phase.

### Research Integration

- **reports/16_team-research.md**: Synthesis identifying the true blocker (MonadicFormula construction never attempted) and converging on 4-phase decomposition.
- **reports/16_teammate-a-findings.md**: Primary decomposition into 4 sub-tasks A-D with exact Lean signatures and line estimates.
- **reports/16_teammate-b-findings.md**: Inventory of 16+ sorry-free reusable lemmas.
- **reports/16_teammate-c-findings.md**: Root cause analysis of 17 failed cycles.
- **reports/16_teammate-d-findings.md**: Strategic assessment confirming model surgery path.
- **handoffs/phase-1-monadic-formula-blocked-20260530.md**: Blocker analysis confirming Option A (bounded quantifier relativization, ~200 lines in MonadicFO.lean) as the ONLY viable path. Option C (table roundtrip) does NOT avoid relativization because `contemp_equiv` is a 2-variable interval property requiring bounded quantification over subintervals.

### Prior Plan Reference

Plan v15 (4 phases, 16 hours) correctly decomposed the Reynolds model surgery into independently deliverable phases. Phase 1 was marked BLOCKED because constructing `MonadicFormula sig 1` for `right_gap_class_prop` requires expressing subinterval k-type checks (`nf_eval_nf` on `M.subinterval`) as MonadicFormula evaluations on the full structure with relativized quantifiers. This infrastructure does not exist in the codebase. The handoff analysis (2026-05-30) confirmed that the table roundtrip (Option C) does NOT bypass relativization, because `contemp_equiv sig k M t b` is itself defined via `very_good sig k (M.subinterval sig (min t b) (max t b))`, which requires bounded quantification over `[min t b, max t b]` to express as a formula on the full structure.

### Roadmap Alignment

No ROADMAP.md found.

## Goals & Non-Goals

**Goals**:
- Build bounded quantifier relativization infrastructure in MonadicFO.lean (new Phase 0)
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
| Bounded quantifier relativization correctness proof more complex than estimated (De Bruijn index interaction with interval bounds) | H | M | Start with the simplest formulation: relativize only closed formulas (n=0 lifted to n=2 with two bound variables for lo/hi). This avoids the general De Bruijn shift problem. If needed, generalize later. |
| MonadicFormula construction for right_gap_class_prop still exceeds estimates even with relativization | M | L | With relativization in hand, the construction is a finite disjunction over NormalFormIdx (which is Fintype). Each disjunct is a relativized NF check. This is straightforward term-level programming. |
| 26 U/S subcases in truth preservation exceed 300 lines | M | M | Each subcase is an independent named lemma (15-30 lines). Can be parallelized. Group by direction (U-forward, U-backward, S-forward, S-backward). |
| Order.dual reduction for SZ case has type class transfer issues | M | L | Fallback: implement SZ case independently by mirroring UZ argument (~150 additional lines). |
| Surgery model construction requires complex type-theoretic bookkeeping | M | M | Reuse orderedSum pattern from NEquivalence.lean and ShiftAndGlue.lean. Use Set.Elem (subtype of M.carrier) for domain. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 0 | -- |
| 2 | 1 | 0 |
| 3 | 2 | 1 |
| 4 | 3 | 1, 2 |
| 5 | 4 | 3 |

Phases within the same wave can execute in parallel.

---

### Phase 0: Bounded Quantifier Relativization Infrastructure [PARTIAL]

**Goal**: Build the infrastructure in MonadicFO.lean that allows expressing "formula phi holds on the subinterval [lo, hi]" as a MonadicFormula on the full structure where all quantifiers are relativized to the interval [lo, hi]. This is the missing ~200-line infrastructure identified by the Phase 1 blocker analysis.

**Mathematical content**: Bounded quantifier relativization is a standard model-theoretic technique. Given a MonadicFormula phi with n free variables, define `relativize phi` as a new formula with n+2 free variables (the extra two being the interval bounds lo, hi) where:
- `all alpha` becomes `all (imp (and (leq lo (var 0)) (leq (var 0) hi)) (relativize alpha))`
- `ex alpha` becomes `ex (and (and (leq lo (var 0)) (leq (var 0) hi)) (relativize alpha))`
- Atom and order comparisons unchanged (they reference free variables that are already in the interval)

The key correctness theorem: `eval M env (relativize phi lo_idx hi_idx)` is equivalent to `eval (M.subinterval lo hi) env_restricted phi`, where `env_restricted` maps each variable to its subtype witness in the subinterval.

**Strategy**: Two-tier approach:

1. **Tier 1 (preferred, ~120 lines)**: Define relativization for MonadicSentence (0 free variables, the case actually needed). A sentence relativized to [lo, hi] has 2 free variables (lo and hi). This avoids the general De Bruijn shifting problem.
   - `relativize_sentence : MonadicSentence sig -> MonadicFormula sig 2`
   - Correctness: `eval M (![lo, hi]) (relativize_sentence phi) <-> eval (M.subinterval sig lo hi) Fin.elim0 phi`
   - This suffices because `nf_eval_nf M k 0 Fin.elim0 nf` is evaluation of a sentence

2. **Tier 2 (fallback, ~200 lines)**: Define relativization for arbitrary `MonadicFormula sig n`, producing `MonadicFormula sig (n + 2)`. More general but requires careful De Bruijn index management. Only attempt if Tier 1 is insufficient.

**Tasks**:
- [x] **Task 0.1**: Define `MonadicFormula.leq` -- Order comparison `x_i <= x_j` as syntactic sugar (~10 lines) *(completed)*
  ```lean
  /-- x_i <= x_j, defined as not (x_j < x_i) -/
  def MonadicFormula.leq {sig : MonadicSignature} {n : Nat}
      (i j : Fin n) : MonadicFormula sig n :=
    .not (.lt j i)
  ```
  - Prove `eval M env (MonadicFormula.leq i j) <-> env i <= env j`

- [x] **Task 0.2**: Define `MonadicFormula.imp` and `MonadicFormula.or` -- Boolean connectives as syntactic sugar (~10 lines) *(completed)*
  ```lean
  /-- Implication: not alpha or beta -/
  def MonadicFormula.imp {sig : MonadicSignature} {n : Nat}
      (alpha beta : MonadicFormula sig n) : MonadicFormula sig n :=
    .not (.and alpha (.not beta))

  /-- Disjunction: not (not alpha and not beta) -/
  def MonadicFormula.or {sig : MonadicSignature} {n : Nat}
      (alpha beta : MonadicFormula sig n) : MonadicFormula sig n :=
    .not (.and (.not alpha) (.not beta))
  ```
  - Prove eval lemmas for each

- [x] **Task 0.3**: Define `relativize_sentence` -- Sentence relativization to interval [lo, hi] (~40 lines) *(completed — defined as `relativize` for general n, then specialized)*
  ```lean
  /-- Relativize a sentence to the interval [var 0, var 1].
      Transforms MonadicSentence sig (= MonadicFormula sig 0) into
      MonadicFormula sig 2, where variable 0 = lo and variable 1 = hi.
      All quantifiers are bounded to [lo, hi]. -/
  noncomputable def relativize_sentence {sig : MonadicSignature}
      (phi : MonadicSentence sig) : MonadicFormula sig 2 :=
    relativize_aux phi 0
  ```
  where `relativize_aux` is a recursive function that:
  - For `all alpha`: produces `all (imp (and (leq lo_shifted (var 0)) (leq (var 0) hi_shifted)) (relativize_aux alpha (depth+1)))`
  - For `ex alpha`: produces `ex (and (and (leq lo_shifted (var 0)) (leq (var 0) hi_shifted)) (relativize_aux alpha (depth+1)))`
  - For `atom p i`: since phi is a sentence (0 free vars), all variables are bound. After relativization, variable indices reference bound variables that are within the interval. Unchanged structurally.
  - For `lt i j`: unchanged structurally (comparisons between bound variables)
  - For `not alpha`, `and alpha beta`: structural recursion
  - De Bruijn management: at quantifier depth `d`, the lo/hi variables have shifted indices `d` and `d+1` (since each `all`/`ex` shifts them up by 1)

- [x] **Task 0.4**: Prove `relativize_sentence_correct` -- Correctness theorem (~60 lines) *(completed — proved via general `relativize_correct` with `relativize_env` and commutation lemmas)*
  ```lean
  theorem relativize_sentence_correct {sig : MonadicSignature}
      (M : OrderedMonadicStructure sig)
      (lo hi : M.carrier) (h_le : lo <= hi)
      (phi : MonadicSentence sig) :
      eval M (![lo, hi]) (relativize_sentence phi) <->
      eval (M.subinterval sig lo hi) Fin.elim0 phi := by
    ...
  ```
  - Proof by structural induction on phi
  - Base cases (atom, lt): show that predicate/order on subinterval elements equals predicate/order on carrier elements (by definition of subinterval)
  - Quantifier cases: show that quantifying over `{x : M.carrier // lo <= x /\ x <= hi}` is the same as quantifying over `M.carrier` with the interval guard
  - The key lemma for quantifier cases: `(forall (x : (M.subinterval sig lo hi).carrier), P x.val) <-> (forall (x : M.carrier), lo <= x -> x <= hi -> P x)` and the existential dual

- [ ] **Task 0.5**: Define `nf_to_sentence` -- Convert NormalForm evaluation to sentence evaluation (~40 lines) *(not started — deferred to Phase 1)*
  ```lean
  /-- For each normal form index nf, construct a MonadicSentence that
      is true in M iff nf_eval_nf M k 0 Fin.elim0 nf holds.
      This uses the fact that NormalForm evaluation at depth 0 with
      0 free variables is a finite Boolean combination of:
      (a) predicate atoms P(x_i) for bound variables x_i
      (b) order atoms x_i < x_j for bound variables
      (c) quantified sub-sentences (for depth > 0) -/
  noncomputable def nf_to_sentence (sig : MonadicSignature) (k : Nat) :
      NormalFormIdx sig k 0 -> MonadicSentence sig := ...
  ```
  - Prove `nf_to_sentence_correct`: `eval M Fin.elim0 (nf_to_sentence sig k nf) <-> nf_eval_nf M k 0 Fin.elim0 nf`
  - This connects the NormalForm world (used in `very_good`/`contemp_equiv`) to the MonadicFormula world (used in `US_expressively_complete_over_prior`)

- [ ] **Task 0.6**: Prove `good_as_monadic_sentence` -- Express `good sig k (M.subinterval sig lo hi)` as a MonadicFormula with 2 free vars (~30 lines) *(not started — deferred to Phase 1)*
  ```lean
  /-- The property good(M.subinterval(lo, hi)) is expressible as a
      MonadicFormula sig 2 evaluated at [lo, hi]. -/
  noncomputable def good_sentence_relativized (sig : MonadicSignature) (k : Nat) :
      MonadicFormula sig 2 := ...

  theorem good_sentence_relativized_correct (sig : MonadicSignature) (k : Nat)
      (M : OrderedMonadicStructure sig) (lo hi : M.carrier) (h_le : lo <= hi) :
      eval M (![lo, hi]) (good_sentence_relativized sig k) <->
      good sig k (M.subinterval sig lo hi) := by
    ...
  ```
  - `good sig k S` = `exists Z, k_equiv sig k S (Z.toOrdered sig)`. This is a sentence about S.
  - `good_sentence_relativized` = `relativize_sentence (good_as_sentence sig k)` where `good_as_sentence` encodes the good predicate
  - Alternative: since `good` reduces to `nf_eval_nf` equality checking, express as a finite disjunction over Z-interval k-types

**Timing**: 4 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/MonadicFO.lean` -- Add ~200 lines after the existing `weaken_eval` theorem (line 370) and before the Normal Form Count section (line 372). New section: `/-! ## Bounded Quantifier Relativization -/`

**Verification**:
- `lake build Bimodal.Metalogic.WeakCanonical.MonadicFO` succeeds
- `#check relativize_sentence_correct` type-checks
- `#check nf_to_sentence_correct` type-checks (if Task 0.5 is in this file; may be in NormalForm.lean instead)
- `grep -c "sorry" MonadicFO.lean` is 0
- No new sorry introduced

**Infrastructure used**:
- `MonadicFormula sig n` (MonadicFO.lean:63)
- `MonadicSentence sig` (MonadicFO.lean:73)
- `eval` (MonadicFO.lean:216)
- `MonadicFormula.weaken` (MonadicFO.lean:260)
- `MonadicFormula.lift` (MonadicFO.lean:244)
- `lift_eval` (MonadicFO.lean:333)
- `weaken_eval` (MonadicFO.lean:365)
- `OrderedMonadicStructure.subinterval` (MonadicFO.lean:129)
- `NormalFormIdx sig k n` (MonadicFO.lean:403)

---

### Phase 1: Gap Formula R Construction (Reynolds Lemma 6) [NOT STARTED]

**Goal**: Construct a `MonadicFormula sig 1` encoding `right_gap_class_prop`, then apply `US_expressively_complete_over_prior` to obtain temporal formula R such that `temporal_truth M atomMap t R <-> right_gap_class_prop sig k M t`.

**Mathematical content**: Reynolds Lemma 6 states that the property "t's contemp_equiv class is bounded above and succ-closed" is expressible as a monadic first-order formula with one free variable. With Phase 0's relativization infrastructure in hand, the construction proceeds:

1. `contemp_equiv sig k M t b` = `very_good sig k (M.subinterval sig (min t b) (max t b))`
2. `very_good sig k S` = `forall a b in S, a <= b -> good sig k (S.subinterval a b)`
3. Using Phase 0's `relativize_sentence`, express `good sig k (M.subinterval sig lo hi)` as a MonadicFormula evaluated at [lo, hi]
4. Build `right_gap_class_prop` as: `(ex b, t < b /\ not (contemp_equiv t b)) /\ (forall c, contemp_equiv t c -> contemp_equiv t (succ c))`
5. Each `contemp_equiv t b` occurrence uses `very_good (M.subinterval (min t b) (max t b))`, which via double relativization becomes a MonadicFormula with t and b as free variables
6. The entire expression is a MonadicFormula sig 1 (one free variable t, with b and c quantified)

**Tasks**:
- [ ] **Task 1.1**: Define `contemp_equiv_formula` -- MonadicFormula sig 2 encoding contemp_equiv (~30 lines)
  ```lean
  /-- MonadicFormula sig 2 encoding contemp_equiv sig k M (var 0) (var 1).
      Uses relativize_sentence to express very_good on the subinterval
      [min(var 0, var 1), max(var 0, var 1)]. -/
  noncomputable def contemp_equiv_formula (sig : MonadicSignature) (k : Nat) :
      MonadicFormula sig 2 := ...
  ```
  - Prove `contemp_equiv_formula_correct`: `eval M (![t, b]) (contemp_equiv_formula sig k) <-> contemp_equiv sig k M t b`

- [ ] **Task 1.2**: Define `right_gap_class_formula` -- MonadicFormula sig 1 encoding right_gap_class_prop (~40 lines)
  ```lean
  noncomputable def right_gap_class_formula (sig : MonadicSignature) (k : Nat) :
      MonadicFormula sig 1 := ...
  ```
  - Build from `contemp_equiv_formula` using existential/universal quantifiers and Boolean connectives
  - `right_gap_class_prop t` = `(ex b, t < b /\ not (contemp_equiv_formula t b)) /\ (all c, contemp_equiv_formula t c -> contemp_equiv_formula t (succ c))`
  - The `succ` reference requires encoding Order.succ as a MonadicFormula operation; since the structure is discrete, `succ c` is the least element > c, expressible as `ex s, c < s /\ (all u, c < u -> s <= u) /\ ...`

- [ ] **Task 1.3**: Prove `right_gap_class_expressible` -- The formula correctly encodes right_gap_class_prop (~30 lines)
  ```lean
  theorem right_gap_class_expressible (sig : MonadicSignature) (k : Nat)
      (M : OrderedMonadicStructure sig)
      [SuccOrder M.carrier] [NoMaxOrder M.carrier]
      (t : M.carrier) :
      eval M (fun _ => t) (right_gap_class_formula sig k) <->
      right_gap_class_prop sig k M t := ...
  ```
  - Compose `contemp_equiv_formula_correct` with the Boolean structure

- [ ] **Task 1.4**: Define `gap_formula_R` and prove correctness -- Apply US_expressively_complete_over_prior (~15 lines)
  ```lean
  noncomputable def gap_formula_R (sig : MonadicSignature) (k : Nat)
      (atomMap : Formula -> sig.preds)
      (h_surj : forall p : sig.preds, exists a : Atom, atomMap (.atom a) = p) :
      Formula :=
    (US_expressively_complete_over_prior atomMap h_surj
      (right_gap_class_formula sig k)).val

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

**Depends on**: 0

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/GoodStructuresModelSurgery.lean` -- Add ~100 lines after line 659 (after right_gap_class_pred, before the Reynolds Theorem 14 section)

**Verification**:
- `lake build Bimodal.Metalogic.WeakCanonical.IntegerModel.GoodStructuresModelSurgery` succeeds
- `#check gap_formula_R_correct` type-checks
- `grep -c "sorry" GoodStructuresModelSurgery.lean` unchanged (sorries at gap_prior_UZ/SZ_contradiction remain, no new sorry introduced)

**Infrastructure used**:
- Phase 0: `relativize_sentence`, `relativize_sentence_correct`, `good_sentence_relativized`, `nf_to_sentence`
- `right_gap_class_prop` (GoodStructuresModelSurgery.lean:592)
- `right_gap_class_invariant` (GoodStructuresModelSurgery.lean:603)
- `right_gap_class_succ` (GoodStructuresModelSurgery.lean:639)
- `right_gap_class_pred` (GoodStructuresModelSurgery.lean:650)
- `US_expressively_complete_over_prior` (PriorExpressiveness.lean:371)
- `MonadicFormula sig 1`, `eval` (MonadicFO.lean:63, 216)
- `contemp_equiv`, `very_good`, `good` (GoodStructures.lean)

---

### Phase 2: R-Interval Analysis (Reynolds Lemmas 7-8) [NOT STARTED]

**Goal**: Establish that R holds throughout the class of `a` (under the hypotheses of `gap_prior_UZ_contradiction`), identify the first R-transition point via `prior_UZ_first_transition`, and show R-intervals have specific structural properties needed for the surgery argument.

**Mathematical content**: Given `gap_formula_R_correct` from Phase 1, the hypotheses of `gap_prior_UZ_contradiction` (class of `a` succ-closed, bounded above) imply `right_gap_class_prop sig k M a` is true, hence R holds at `a`. Since `right_gap_class_prop` is preserved under succ/pred (by `right_gap_class_succ`/`right_gap_class_pred`), R is preserved under succ/pred. Since there exists `y > a` with `not (contemp_equiv a y)`, and `right_gap_class_prop y` may be false, R may be false at some points. By `prior_UZ_first_transition`, there exists a first R-to-not-R transition point.

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

- [ ] **Task 2.2**: Prove `R_not_holds_somewhere` -- R is false at some point above `a` (~15 lines)

- [ ] **Task 2.3**: Prove `R_first_transition` -- First R-to-not-R transition point exists (~20 lines)
  - Apply `prior_UZ_first_transition` (GoodStructuresModelSurgery.lean:116) directly

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
- `c` is in the class of `a` (R holds at c, so right_gap_class_prop c is true)
- `succ(c)` is NOT in the class of `a` (R is false at succ(c))
- The surgery excises the R-region and keeps Q- (below the class), I (one representative class), Q+ (above the R-region)
- Temporal truth preservation across surgery requires case analysis for each formula constructor: atom (1), bot (1), imp (1), box (1), U (13 subcases), S (13 subcases)

**Strategy for surgery domain**: Use subtype `{x : M.carrier // x not-in bad_interval or x in I}` rather than `orderedSum`, to avoid the complexity of constructing order isomorphisms.

**Tasks**:
- [ ] **Task 3.1**: Define the surgery domain and model (~40 lines)
- [ ] **Task 3.2**: Prove class homogeneity in R-intervals (Reynolds Lemma 9) (~60 lines)
- [ ] **Task 3.3**: Prove formula propagation in R-intervals (Reynolds Lemmas 10-11) (~40 lines)
- [ ] **Task 3.4**: Prove surgery truth preservation -- atom/bot/imp/box cases (~20 lines)
- [ ] **Task 3.5**: Prove surgery truth preservation -- U(A,B) forward direction (M to N) (~80 lines)
- [ ] **Task 3.6**: Prove surgery truth preservation -- U(A,B) backward direction (N to M) (~60 lines)
- [ ] **Task 3.7**: Prove surgery truth preservation -- S(A,B) cases (~60 lines)
- [ ] **Task 3.8**: Assemble full truth preservation by structural induction on Formula (~30 lines)

**Timing**: 6 hours

**Depends on**: 1, 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/GoodStructuresModelSurgery.lean` -- Add ~350 lines after Phase 2 additions

**Verification**:
- `lake build Bimodal.Metalogic.WeakCanonical.IntegerModel.GoodStructuresModelSurgery` succeeds
- `#check surgery_truth_preservation` type-checks
- No new sorry introduced
- Each subcase lemma independently verifiable

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

**Mathematical content**: In the surgery model N, the representative class I ends at `succ(c)` (a successor-pair boundary, not a gap), so `right_gap_class_prop N i` is FALSE for any `i` in I. By `gap_formula_R_correct`, R is false at `i` in N. But `surgery_truth_preservation` gives `temporal_truth M atomMap i R <-> temporal_truth N atomMap_N i R`, and R is true at `i` in M. Contradiction.

For the SZ case: use `Order.dual` to map the SZ case to the UZ case if type class instances transfer cleanly; otherwise implement independently.

**Tasks**:
- [ ] **Task 4.1**: Prove `surgery_no_rgcp` -- right_gap_class_prop is false at representative point in surgery model (~25 lines)
- [ ] **Task 4.2**: Derive `gap_prior_UZ_contradiction` -- assemble the full contradiction (~40 lines)
  - This replaces the `sorry` at line 702
- [ ] **Task 4.3**: Close `gap_prior_SZ_contradiction` -- symmetric argument for downward case (~60-100 lines)
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
- All Phase 0-3 results
- `gap_formula_R_correct` (Phase 1)
- `surgery_truth_preservation` (Phase 3)
- `surgery_no_rgcp` (this phase)
- `contemp_equiv_pred_closed` (GoodStructuresModelSurgery.lean:288) -- for SZ case
- `prior_SZ_last_transition` (GoodStructuresModelSurgery.lean:180) -- for SZ case

## Testing & Validation

- [ ] Phase 0: `lake build Bimodal.Metalogic.WeakCanonical.MonadicFO` succeeds with zero errors
- [ ] Phase 0: `#check relativize_sentence_correct` type-checks
- [ ] Phase 0: `grep -c "sorry" MonadicFO.lean` is 0
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

- `specs/202_reynolds_k_equivalence_bypass/plans/17_reynolds-model-surgery-v16.md` (this plan)
- `Theories/Bimodal/Metalogic/WeakCanonical/MonadicFO.lean` (MODIFY, +~200 lines: Phase 0 relativization infrastructure)
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/GoodStructuresModelSurgery.lean` (MODIFY, +~500 lines: ~100 Phase 1 + ~55 Phase 2 + ~350 Phase 3 - 2 sorry lines + ~120 Phase 4)

## Rollback/Contingency

**Phase 0**: Adds ~200 lines to MonadicFO.lean. If the Tier 1 approach (sentence-only relativization) is insufficient for Phase 1's needs (e.g., `contemp_equiv` requires 2-variable relativization that cannot be reduced to sentence relativization), fall back to Tier 2 (general relativization). If bounded quantifier relativization proves too complex to formalize correctly within 6 hours, consider the alternative: add `relativize_sentence` as an `axiom` with its correctness statement, proceed with Phases 1-4, and return to prove the axiom in a follow-up task. This isolates the formalization risk.

**Phase 1**: Adds ~100 lines after line 659. With Phase 0's relativization in hand, the MonadicFormula construction is straightforward finite Boolean combination. If the `succ` encoding (expressing Order.succ as "least element strictly greater") creates complexity, use Classical.choice to postulate the successor formula's existence (since SuccOrder is decidable on finite intervals).

**Phase 2**: Adds ~55 lines. Straightforward applications of existing lemmas. Low risk.

**Phase 3**: Adds ~350 lines (the bulk of the implementation). If U/S subcases exceed 350 lines, split into a separate file `GoodStructuresModelSurgeryTruth.lean`. Each subcase is an independent named lemma, so partial progress is preservable.

**Phase 4**: Replaces 2 sorry sites. If Order.dual reduction for SZ fails, implement independently (~100 additional lines vs ~60 for dual).

**General fallback**: If the full model surgery cannot be completed within 3 more implementation cycles, consider the axiom-elevation strategy: elevate the two sorry sites to named `axiom` declarations, document as "unproved Reynolds lemmas awaiting formalization", and proceed with downstream engineering work.
