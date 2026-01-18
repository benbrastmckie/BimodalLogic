# Research Report: Task #570

**Task**: 570 - Analyze Compound Formula Proof Requirements
**Date**: 2026-01-18
**Focus**: Analyze the 4 compound formula cases in truth_at_implies_semantic_truth (lines 3627-3651 of FiniteCanonicalModel.lean)
**Session ID**: sess_1768708051_3f4c22
**Started**: 2026-01-18T03:50:00Z
**Completed**: 2026-01-18T04:15:00Z
**Effort**: 2-3 hours estimated
**Priority**: High
**Dependencies**: Task 566, Task 569
**Sources/Inputs**: Mathlib, lean_goal, lean_local_search, FiniteCanonicalModel.lean analysis
**Artifacts**: specs/570_analyze_compound_formula_proof_requirements/reports/research-001.md
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- Each of the 4 compound formula cases (imp, box, all_past, all_future) requires proving that `truth_at` (recursive semantic evaluation) implies the `assignment` being `true` (flat lookup)
- The fundamental obstacle is the **gap between semantic truth and syntactic membership** - specifically, showing that if semantic evaluation holds, the world state's assignment must record it
- The `SemanticWorldState` is constructed from `FiniteHistory` states, which come from closure-maximal consistent sets (closure MCS)
- The key missing infrastructure is **implication/modal/temporal completeness lemmas** that connect semantic truth to MCS membership
- The `semantic_truth_lemma_v2` sidesteps this by defining truth directly in terms of `models`, but `truth_at_implies_semantic_truth` needs to bridge the external `truth_at` definition

## Context & Scope

### What Was Researched

1. Exact proof goals for all 4 sorries via `lean_goal`
2. Definition of `truth_at` (recursive semantic evaluation)
3. Definition of `FiniteWorldState.assignment` and how it's computed
4. Relationship between `SemanticWorldState.toFiniteWorldState` and `FiniteHistory.states`
5. Existing lemmas: `IsLocallyConsistent`, `closure_mcs_negation_complete`, `finite_truth_lemma`
6. Prior research in Task 566 and Task 569

### Constraints

- Must work within existing `SemanticWorldState` architecture
- Cannot introduce new axioms
- Should leverage existing proven infrastructure where possible

## Findings

### 1. Exact Proof Goals for Each Case

#### Case 1: Implication (line 3635)

**Goal**:
```lean
phi psi chi : Formula
tau : WorldHistory (SemanticCanonicalFrame (psi.imp chi))
ht : tau.domain 0
h_mem : psi.imp chi ∈ closure (psi.imp chi)
h_truth : truth_at (SemanticCanonicalModel (psi.imp chi)) tau 0 (psi.imp chi)
|-
(SemanticWorldState.toFiniteWorldState (tau.states 0 ht)).assignment ⟨psi.imp chi, h_mem⟩ = true
```

**truth_at definition for imp**:
```lean
truth_at M tau t (psi.imp chi) = truth_at M tau t psi -> truth_at M tau t chi
```

**Requirement**: Show that if `truth_at psi -> truth_at chi` holds, the assignment for `psi.imp chi` is `true`.

#### Case 2: Box (line 3641)

**Goal**:
```lean
phi psi : Formula
tau : WorldHistory (SemanticCanonicalFrame psi.box)
ht : tau.domain 0
h_mem : psi.box ∈ closure psi.box
h_truth : truth_at (SemanticCanonicalModel psi.box) tau 0 psi.box
|-
(SemanticWorldState.toFiniteWorldState (tau.states 0 ht)).assignment ⟨psi.box, h_mem⟩ = true
```

**truth_at definition for box**:
```lean
truth_at M tau t (psi.box) = forall (sigma : WorldHistory F), truth_at M sigma t psi
```

**Requirement**: Show that if `psi` is true at all histories at time `t`, the assignment for `psi.box` is `true`.

#### Case 3: All Past (line 3646)

**Goal**:
```lean
phi psi : Formula
tau : WorldHistory (SemanticCanonicalFrame psi.all_past)
ht : tau.domain 0
h_mem : psi.all_past ∈ closure psi.all_past
h_truth : truth_at (SemanticCanonicalModel psi.all_past) tau 0 psi.all_past
|-
(SemanticWorldState.toFiniteWorldState (tau.states 0 ht)).assignment ⟨psi.all_past, h_mem⟩ = true
```

**truth_at definition for all_past**:
```lean
truth_at M tau t (psi.all_past) = forall (s : D), s < t -> truth_at M tau s psi
```

**Requirement**: Show that if `psi` is true at all times `s < t`, the assignment for `psi.all_past` is `true`.

#### Case 4: All Future (line 3651)

**Goal**:
```lean
phi psi : Formula
tau : WorldHistory (SemanticCanonicalFrame psi.all_future)
ht : tau.domain 0
h_mem : psi.all_future ∈ closure psi.all_future
h_truth : truth_at (SemanticCanonicalModel psi.all_future) tau 0 psi.all_future
|-
(SemanticWorldState.toFiniteWorldState (tau.states 0 ht)).assignment ⟨psi.all_future, h_mem⟩ = true
```

**truth_at definition for all_future**:
```lean
truth_at M tau t (psi.all_future) = forall (s : D), t < s -> truth_at M tau s psi
```

**Requirement**: Show that if `psi` is true at all times `s > t`, the assignment for `psi.all_future` is `true`.

### 2. How truth_at is Defined

The `truth_at` function is defined recursively in `Theories/Bimodal/Semantics/Truth.lean` (line 104):

```lean
def truth_at (M : TaskModel F) (tau : WorldHistory F) (t : D) : Formula -> Prop
  | Formula.atom p => exists (ht : tau.domain t), M.valuation (tau.states t ht) p
  | Formula.bot => False
  | Formula.imp phi psi => truth_at M tau t phi -> truth_at M tau t psi
  | Formula.box phi => forall (sigma : WorldHistory F), truth_at M sigma t phi
  | Formula.all_past phi => forall (s : D), s < t -> truth_at M tau s phi
  | Formula.all_future phi => forall (s : D), t < s -> truth_at M tau s phi
```

Key observations:
- **Atoms**: Existential over domain proof, then valuation lookup
- **Imp**: Material conditional (function type)
- **Box**: Universal over ALL histories (very strong)
- **Temporal**: Universal over ALL times in appropriate direction

### 3. How FiniteWorldState.assignment is Computed

The assignment is a function `closure phi -> Bool` (line 746):

```lean
def FiniteTruthAssignment (phi : Formula) := (closure phi) -> Bool
```

For a `FiniteWorldState`, the assignment comes from the `IsLocallyConsistent` constraint (line 759):

```lean
def IsLocallyConsistent (phi : Formula) (v : FiniteTruthAssignment phi) : Prop :=
  -- Bot is false
  (forall h : Formula.bot ∈ closure phi, v ⟨Formula.bot, h⟩ = false) /\
  -- Implications are respected (SOUNDNESS only)
  (forall psi chi,
    forall h_imp : Formula.imp psi chi ∈ closure phi,
    forall h_psi : psi ∈ closure phi,
    forall h_chi : chi ∈ closure phi,
    v ⟨Formula.imp psi chi, h_imp⟩ = true ->
    v ⟨psi, h_psi⟩ = true ->
    v ⟨chi, h_chi⟩ = true) /\
  -- Modal T axiom (box -> content)
  (forall psi, forall h_box : Formula.box psi ∈ closure phi,
    forall h_psi : psi ∈ closure phi,
    v ⟨Formula.box psi, h_box⟩ = true -> v ⟨psi, h_psi⟩ = true) /\
  -- Temporal reflexivity past (all_past -> content)
  (...) /\
  -- Temporal reflexivity future (all_future -> content)
  (...)
```

**Critical Observation**: `IsLocallyConsistent` only provides **soundness** (truth of compound implies truth of parts), NOT **completeness** (truth of parts implies truth of compound).

### 4. The SemanticWorldState to FiniteWorldState Bridge

`SemanticWorldState` is defined as (line 2146):
```lean
def SemanticWorldState (phi : Formula) := Quotient (htSetoid phi)
```

where `htSetoid` is based on history-time pairs with equivalence defined by same underlying world state.

`toFiniteWorldState` extracts the underlying `FiniteWorldState` (line 2169):
```lean
def toFiniteWorldState (w : SemanticWorldState phi) : FiniteWorldState phi :=
  Quotient.lift (fun p => p.1.states p.2) (fun _ _ h => h) w
```

The key insight: `SemanticWorldState` quotients are **defined** by their underlying `FiniteWorldState`. The `FiniteWorldState` itself comes from a `FiniteHistory`, which is constructed from closure MCS sets.

### 5. Required Bridge Lemmas

To prove each case, we need lemmas of the form:

**For Implication**:
```lean
theorem imp_semantic_completeness (phi : Formula) (w : SemanticWorldState phi)
    (psi chi : Formula)
    (h_imp : Formula.imp psi chi ∈ closure phi)
    (h_truth : truth_at (SemanticCanonicalModel phi) tau 0 (psi.imp chi)) :
    (SemanticWorldState.toFiniteWorldState w).assignment ⟨psi.imp chi, h_imp⟩ = true
```

This requires showing: **if the semantic implication holds, the closure MCS contains the implication formula**.

The proof would need:
1. Case split on whether `psi` is in the MCS
2. If `psi` is not in MCS: by `closure_mcs_negation_complete`, `psi.neg` is in MCS, so `psi.imp chi` should be derivable (vacuous)
3. If `psi` is in MCS: by semantic truth and IH, `chi` is in MCS, so `psi.imp chi` should be derivable (modus ponens converse)

**For Box**:
```lean
theorem box_semantic_completeness (phi : Formula) (w : SemanticWorldState phi)
    (psi : Formula) (h_box : Formula.box psi ∈ closure phi)
    (h_truth : forall sigma, truth_at (SemanticCanonicalModel phi) sigma 0 psi) :
    (SemanticWorldState.toFiniteWorldState w).assignment ⟨psi.box, h_box⟩ = true
```

This requires the **canonical property**: if psi holds at all accessible worlds (all histories at time t), then box(psi) is in the MCS.

**For Temporal Operators**: Similar to box, requiring temporal canonical properties.

### 6. Why These Are Difficult

The fundamental difficulty is the **direction of the implication**:

- **IsLocallyConsistent provides**: compound true => parts true (SOUNDNESS)
- **We need**: parts true => compound true (COMPLETENESS)

For completeness, we need **negation-completeness** of the MCS: for every formula in the closure, either it or its negation is true. This is provided by `closure_mcs_negation_complete`, but connecting it to the semantic evaluation is complex because:

1. The semantic evaluation (`truth_at`) operates on the recursive formula structure
2. The MCS membership is determined by a Lindenbaum construction
3. Bridging these requires showing the Lindenbaum construction "captures" semantic truth

### 7. Existing Related Lemmas

**closure_mcs_negation_complete** (line 669):
```lean
theorem closure_mcs_negation_complete {phi : Formula} {S : Set Formula}
    (h_mcs : ClosureMaximalConsistent phi S) (psi : Formula)
    (h_psi : psi ∈ closure phi) (h_neg : Formula.neg psi ∈ closure phi) :
    psi ∈ S \/ (Formula.neg psi) ∈ S
```

This lemma IS proven and provides the key negation-completeness property. The challenge is using it.

**finite_truth_lemma** (line 3770): Has the same 4 sorries in backward directions, with detailed comments explaining the issue.

**semantic_truth_lemma_v2** (line 2801): PROVEN because it defines semantic truth directly in terms of `models`:
```lean
def semantic_truth_at_v2 ... (psi : Formula) : Prop :=
  exists h_mem : psi ∈ closure phi, (SemanticWorldState.toFiniteWorldState w).models psi h_mem
```

This sidesteps the bridge entirely but doesn't help with `truth_at_implies_semantic_truth`.

### 8. Proof Strategy Recommendations

#### Strategy A: Use Negation-Completeness with Contrapositive

For the implication case:
1. Assume `assignment ⟨psi.imp chi, h_mem⟩ != true`, i.e., it's `false`
2. By negation-completeness, `(psi.imp chi).neg` is in the MCS
3. By syntactic analysis, `(psi.imp chi).neg` is equivalent to `psi /\ chi.neg`
4. So both `psi` and `chi.neg` are in the MCS
5. By IH, `truth_at psi` and NOT `truth_at chi`
6. But `h_truth` says `truth_at psi -> truth_at chi`, contradiction

**Difficulty**: This requires showing the syntactic properties of negation and the MCS.

#### Strategy B: Direct Semantic-to-Syntactic Bridge

Create a helper lemma:
```lean
theorem semantic_to_mcs_bridge (phi psi : Formula)
    (w : SemanticWorldState phi) (h_mem : psi ∈ closure phi)
    (h_truth : semantic_truth_at_v2 phi w t psi) :
    (SemanticWorldState.toFiniteWorldState w).assignment ⟨psi, h_mem⟩ = true
```

This is essentially tautological from the definition of `semantic_truth_at_v2`.

The actual bridge needed is:
```lean
theorem truth_at_to_semantic_truth_at (phi psi : Formula)
    (tau : WorldHistory (SemanticCanonicalFrame phi))
    (ht : tau.domain 0) (h_mem : psi ∈ closure phi)
    (h_truth : truth_at (SemanticCanonicalModel phi) tau 0 psi) :
    semantic_truth_at_v2 phi (tau.states 0 ht) (FiniteTime.origin ...) psi
```

This is exactly `truth_at_implies_semantic_truth`!

#### Strategy C: Restructure to Avoid the Bridge

Instead of proving `truth_at_implies_semantic_truth`, consider whether the theorem is needed at all.

Looking at how it's used in `semantic_consequence_implies_semantic_world_truth`, the goal is:
- Given `semantic_consequence [] phi` (phi valid in ALL models)
- Show phi is true at all `SemanticWorldState`s

The issue: `semantic_consequence` uses `truth_at`, but `semantic_weak_completeness` uses `semantic_truth_at_v2`.

**Alternative**: Prove a different theorem that uses `semantic_truth_at_v2` directly, avoiding the bridge.

### 9. Complexity Assessment

| Case | Complexity | Key Challenge |
|------|------------|---------------|
| Implication | Medium | Negation-completeness and syntactic equivalence of negated implication |
| Box | High | Modal canonical property across histories |
| All Past | High | Temporal canonical property, time domain issues |
| All Future | High | Temporal canonical property, time domain issues |

**Estimated Effort**:
- Implication case: 2-3 hours (most tractable)
- Box case: 4-6 hours (requires canonical modal property)
- Temporal cases: 4-6 hours each (require temporal canonical properties)
- Total: 14-21 hours if done sequentially

## Decisions

1. **The implication case is the best starting point** - it requires only negation-completeness, not modal/temporal canonical properties
2. **The core issue is COMPLETENESS, not soundness** - IsLocallyConsistent only provides soundness
3. **closure_mcs_negation_complete is the key lemma** - it provides the negation-completeness needed
4. **A contrapositive approach may be simpler** - assume assignment is false, derive contradiction from truth_at hypothesis

## Recommendations

### Priority 1: Attempt Implication Case via Contrapositive

1. In the implication case, use a contrapositive argument:
   - Assume the assignment for `psi.imp chi` is not `true`
   - Since the world state comes from a closure MCS, by negation-completeness, `(psi.imp chi).neg` must be "true"
   - Unfold the negation: `(psi.imp chi).neg = (psi /\ chi.neg)` or syntactically equivalent
   - This implies both `psi` true and `chi.neg` true in the MCS
   - By some form of IH or bridge, `truth_at psi` and `NOT truth_at chi`
   - But `h_truth` is `truth_at psi -> truth_at chi`, contradiction

2. The challenge is connecting MCS truth to `truth_at`. This may require an auxiliary induction.

### Priority 2: Factor Out Common Infrastructure

All 4 cases need to convert from `truth_at` to MCS membership. Create a helper:

```lean
theorem truth_at_implies_in_mcs (phi psi : Formula)
    (tau : WorldHistory (SemanticCanonicalFrame phi))
    (ht : tau.domain 0) (h_mem : psi ∈ closure phi)
    (h_truth : truth_at (SemanticCanonicalModel phi) tau 0 psi) :
    psi ∈ underlying_MCS_of (tau.states 0 ht)
```

This centralizes the bridge lemma and can be proven by induction on `psi`.

### Priority 3: Consider Alternative Architecture

If the bridge proves too difficult, consider:

1. **Redefine semantic_consequence** to use `semantic_truth_at_v2` instead of `truth_at`
2. **Accept the sorries** as documented technical debt (the overall proof structure is sound)
3. **Create subtasks** for each case to parallelize the work

## Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Negation not directly in closure | High | May need `closureWithNeg` or syntactic equivalence lemmas |
| MCS construction details obscure | Medium | Trace through Lindenbaum construction carefully |
| Time domain complications for temporal cases | High | Start with implication case which avoids time issues |
| Universe level issues | Low | Use explicit type annotations |

## Appendix

### Search Queries Used

1. `lean_goal` at lines 3635, 3641, 3646, 3651 - extracted exact proof goals
2. `lean_local_search` for `closure_mcs_negation_complete` - verified existence
3. `lean_leansearch` for "material implication truth implies membership" - general patterns

### Key File Locations

- **Target file**: `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Completeness/FiniteCanonicalModel.lean`
- **truth_at definition**: `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Semantics/Truth.lean:104`
- **IsLocallyConsistent**: `FiniteCanonicalModel.lean:759-787`
- **closure_mcs_negation_complete**: `FiniteCanonicalModel.lean:669`
- **SemanticWorldState**: `FiniteCanonicalModel.lean:2146`
- **toFiniteWorldState**: `FiniteCanonicalModel.lean:2169`

### Goal State Summary Table

| Case | Line | Formula Type | Goal Pattern |
|------|------|--------------|--------------|
| imp | 3635 | `psi.imp chi` | `assignment ⟨psi.imp chi, h_mem⟩ = true` |
| box | 3641 | `psi.box` | `assignment ⟨psi.box, h_mem⟩ = true` |
| all_past | 3646 | `psi.all_past` | `assignment ⟨psi.all_past, h_mem⟩ = true` |
| all_future | 3651 | `psi.all_future` | `assignment ⟨psi.all_future, h_mem⟩ = true` |

All cases share: given `h_truth : truth_at (SemanticCanonicalModel phi) tau 0 phi`, prove the assignment equals true.

## Next Steps

1. Run `/plan 570` to create detailed implementation plan
2. Attempt implication case as proof-of-concept
3. If successful, apply pattern to other cases
4. If blocked, document findings and consider architecture changes
