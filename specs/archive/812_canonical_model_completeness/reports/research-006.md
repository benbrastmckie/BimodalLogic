# Research Report: Task #812

**Task**: Accessibility Relations for History-Based Semantics
**Date**: 2026-02-02
**Focus**: Defining accessibility between histories to enable completeness proofs
**Session ID**: sess_1770029184_9dae84

## Summary

This report addresses the core question from research-005.md: what would accessibility between histories mean, and how could it be derived rather than primitive? After analyzing the codebase's WorldHistory structure and reviewing relevant literature on branching time logics (Ockhamist, STIT, bundled trees), I identify three viable approaches and evaluate their fit with the codebase's constraints. **Recommendation**: the "same-MCS-at-time" approach provides the most natural derivable accessibility relation that enables a standard Henkin completeness proof while preserving the codebase's parametric time structure.

---

## 1. Current Semantics Analysis

### 1.1 The Box Semantics Problem

The current box semantics (Truth.lean:112) are:
```lean
| Formula.box phi => forall (sigma : WorldHistory F), truth_at M sigma t phi
```

This quantifies over **ALL** histories at time t with no restriction. The archived TruthLemma.lean (lines 371-413) documents why this blocks completeness:

> "An arbitrary history sigma can assign ANY world state to time t - not necessarily one with the family's MCS."

### 1.2 WorldHistory Structure

Histories in this codebase are **not primitive**. From WorldHistory.lean:69:
```lean
structure WorldHistory {D : Type*} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] (F : TaskFrame D) where
  domain : D -> Prop
  convex : ...
  states : (t : D) -> domain t -> F.WorldState
  respects_task : ...
```

Key observations:
1. A history is a **function** from time to world states (over a convex domain)
2. The `states` function assigns world states at each time in the domain
3. The `respects_task` constraint ensures temporal coherence within a single history
4. There is **no inter-history relation** defined

### 1.3 The Missing Piece

The completeness obstruction arises because:
- The canonical model valuation depends on MCS membership in world states
- An arbitrary history can assign any world state to time t
- Box quantifies over all histories, including non-canonical ones
- The truth lemma cannot bridge arbitrary semantic truth to MCS membership

**What's needed**: A way to restrict history quantification to "relevant" histories, or to define an accessibility relation that filters which histories matter for box evaluation.

---

## 2. Literature Review: Accessibility in History-Based Semantics

### 2.1 Ockhamist Branching Time

Per the [Stanford Encyclopedia of Philosophy (Temporal Logic)](https://plato.stanford.edu/entries/logic-temporal/):

> "The modal operators quantify over the set of histories passing through the current instant. The operator diamond is an existential quantifier over that set and captures possibility, while its dual box involves universal quantification and expresses 'inevitability' or 'historical necessity'."

**Key insight**: In Ockhamist semantics, box only quantifies over histories **passing through** the current moment. Two histories are related at moment m iff they both contain m.

**Formal definition**: For a tree T with moments, histories h and h' are "accessible" at moment m iff:
- m is in h (h passes through m)
- m is in h' (h' passes through m)

This is an equivalence relation at each moment.

### 2.2 Bundled Tree Semantics

Per the [Stanford Encyclopedia of Philosophy (Temporal Logic)](https://plato.stanford.edu/entries/logic-temporal/):

> "Quantification over histories is now restricted to histories from the bundle."

A **bundle** B is a designated subset of histories such that every moment belongs to some history in B. Box then quantifies over B rather than all mathematically possible histories.

**Relevance**: This approach requires a primitive "bundle" selection, not a derivable accessibility relation.

### 2.3 Indistinguishability Relations (Zanardo)

Zanardo's work on [indistinguishability relations](https://link.springer.com/article/10.1007/s10992-015-9369-3) generalizes Ockhamist semantics:

> "Trees with indistinguishability relations provide a semantics for a temporal language with tense and modal operators. In this semantics, truth is relative to pairs (t, pi), where t is a moment and pi is an indistinguishability class at t."

**Key concept**: An indistinguishability function I assigns to each moment m a partition of histories through m. Box quantifies over indistinguishability classes, not individual histories.

**Completeness result**: A finite axiomatization with strong completeness has been proven for bundled trees with indistinguishability relations.

### 2.4 STIT Logic (Belnap et al.)

Per the [Stanford Encyclopedia of Philosophy (Logic of Action)](https://plato.stanford.edu/entries/logic-action/):

> "For each moment m and agent i, C yields a partitioning C_i^m of the set H_m of all histories through m. An equivalence class in C_i^m is called a choice cell."

**Key insight**: STIT uses **choice cells** as equivalence classes of histories. Two histories are in the same choice cell at m if the agent's choice doesn't distinguish them.

### 2.5 T x W Frames (Kamp Frames)

Per the [Stanford Encyclopedia of Philosophy (Temporal Logic)](https://plato.stanford.edu/entries/logic-temporal/):

> "These kinds of frames build on a non-empty set of possible worlds, each of which is endowed with an internal linear temporal structure, and assume a time-relative, historical accessibility relation between possible worlds."

**Key insight**: In T x W frames, "overlap of histories is replaced by accessibility, and possible worlds are considered primitive elements."

---

## 3. Derivable Accessibility Approaches

Given that histories in the codebase are defined structures (not primitives), accessibility should be **derivable** from the existing components. I evaluate three approaches:

### 3.1 Approach A: Same-State-at-Time

**Definition**: Two histories are accessible at time t iff they assign the same world state at t.

```lean
def modal_accessible (F : TaskFrame D) (tau sigma : WorldHistory F) (t : D) : Prop :=
  exists (ht_tau : tau.domain t) (ht_sigma : sigma.domain t),
    tau.states t ht_tau = sigma.states t ht_sigma
```

**Interpretation**: Box means "true at all histories that agree with the current history at time t."

**Pros**:
- Fully derivable from existing structure
- Natural interpretation: "necessary" means "true in all worlds with the same current state"
- S5-style: reflexive, symmetric, transitive (equality is an equivalence)

**Cons**:
- May be too strong (too few accessible histories)
- Changes the meaning of necessity from "all possible" to "all currently indistinguishable"
- Different from the paper's intended semantics

**Completeness**: Enables standard Henkin proof. The canonical model's histories are indexed by MCS families, and accessibility becomes MCS equality at time t.

### 3.2 Approach B: Same-MCS-at-Time (Canonical Model Approach)

**Definition**: In the canonical model, histories are derived from indexed MCS families. Two canonical histories are accessible at time t iff their underlying MCS at t is the same.

```lean
-- For canonical model construction only
def canonical_accessible (family1 family2 : IndexedMCSFamily D) (t : D) : Prop :=
  family1.mcs t = family2.mcs t
```

**Interpretation**: Box quantifies over canonical histories that could have branched from the current epistemic state.

**Pros**:
- Directly solves the truth lemma obstruction
- The truth lemma's box case becomes: "box phi in MCS(t) iff phi in all MCSes at t that are R-accessible"
- With R defined as MCS equality: "box phi in MCS(t) iff phi in MCS(t)" (trivially true for modal T)
- Preserves parametric time

**Cons**:
- Only defined for canonical models, not general semantics
- Creates two notions of validity (general vs canonical)

**Completeness**: This is the Henkin technique. Define:
- Canonical worlds = MCSes
- Accessibility: MCS1 R MCS2 iff forall box phi in MCS1, phi in MCS2
- Truth lemma: phi in MCS iff (M, MCS) |= phi

The standard proof applies because box only quantifies over canonical worlds.

### 3.3 Approach C: Undividedness/Shared Future

**Definition**: Two histories are accessible at time t iff they share some future moment.

```lean
def undivided_at (F : TaskFrame D) (tau sigma : WorldHistory F) (t : D) : Prop :=
  exists (s : D) (hs_tau : tau.domain s) (hs_sigma : sigma.domain s),
    t < s /\ tau.states s hs_tau = sigma.states s hs_sigma
```

**Interpretation**: Box means "true at all histories that haven't yet diverged from the current one."

**Pros**:
- Matches the branching-time intuition
- Histories accessible at t are exactly those "still possible" given the past
- Gradual narrowing: fewer histories accessible as time progresses

**Cons**:
- Requires existence of shared future moments (may not exist in all histories)
- More complex to work with in proofs
- The codebase's histories can have disjoint domains

**Completeness**: Could work but requires careful handling of the domain structure.

---

## 4. Evaluation Against Codebase Constraints

### 4.1 Parametric Time (D any ordered abelian group)

All three approaches work with parametric time:
- Approach A: Only uses D for domain membership and equality
- Approach B: Works at the MCS level, independent of D
- Approach C: Uses D's ordering for the "future" notion

### 4.2 Preservation of Existing Semantics

**Current semantics change required**: Yes, for all approaches. The box clause must change from:
```lean
| Formula.box phi => forall (sigma : WorldHistory F), truth_at M sigma t phi
```
to:
```lean
| Formula.box phi => forall (sigma : WorldHistory F), accessible tau sigma t -> truth_at M sigma t phi
```

**Impact on soundness**: Must re-prove that axioms are sound w.r.t. new semantics.

### 4.3 Integration with TaskFrame

The current TaskFrame structure has:
- WorldState type
- task_rel relating states via durations
- nullity and compositionality constraints

**Approach A** adds a constraint at the WorldHistory level (comparing states).
**Approach B** only affects the canonical model construction.
**Approach C** requires domain overlap conditions.

### 4.4 Minimal Invasiveness

Ranked from least to most invasive:
1. **Approach B (Same-MCS)**: Only affects canonical model construction, not general semantics
2. **Approach A (Same-State)**: Requires adding accessibility to general semantics
3. **Approach C (Undividedness)**: Requires domain and future existence constraints

---

## 5. Concrete Lean 4 Type Signatures

### 5.1 Approach A: General Accessibility

```lean
-- Add to WorldHistory.lean or new Accessibility.lean

/-- Accessibility relation between histories at a time -/
def modal_accessible {D : Type*} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    {F : TaskFrame D} (tau sigma : WorldHistory F) (t : D) : Prop :=
  (tau.domain t ∧ sigma.domain t) ∧
  (∀ (ht_tau : tau.domain t) (ht_sigma : sigma.domain t),
    tau.states t ht_tau = sigma.states t ht_sigma)

-- Modified truth definition
def truth_at_with_accessibility (M : TaskModel F) (tau : WorldHistory F) (t : D) : Formula -> Prop
  | Formula.box phi => ∀ (sigma : WorldHistory F),
      modal_accessible tau sigma t -> truth_at_with_accessibility M sigma t phi
  | ... -- other cases unchanged
```

### 5.2 Approach B: Canonical Model Accessibility

```lean
-- In Representation/CanonicalModel.lean

/-- Accessibility between indexed MCS families at time t -/
def canonical_accessible (family1 family2 : IndexedMCSFamily D) (t : D) : Prop :=
  ∀ phi : Formula, Formula.box phi ∈ family1.mcs t → phi ∈ family2.mcs t

/-- Truth at in canonical model with canonical accessibility -/
def canonical_truth_at (family : IndexedMCSFamily D) (t : D) : Formula -> Prop
  | Formula.atom p => Formula.atom p ∈ family.mcs t
  | Formula.bot => False
  | Formula.imp phi psi => canonical_truth_at family t phi -> canonical_truth_at family t psi
  | Formula.box phi => ∀ (family' : IndexedMCSFamily D),
      canonical_accessible family family' t -> canonical_truth_at family' t phi
  | Formula.all_past phi => ∀ s, s ≤ t -> canonical_truth_at family s phi
  | Formula.all_future phi => ∀ s, t ≤ s -> canonical_truth_at family s phi
```

### 5.3 Approach C: Undividedness

```lean
-- Add to WorldHistory.lean

/-- Two histories are undivided at t if they share a common future state -/
def undivided_at {D : Type*} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    {F : TaskFrame D} (tau sigma : WorldHistory F) (t : D) : Prop :=
  ∃ (s : D) (hs : t < s) (ht_tau : tau.domain s) (ht_sigma : sigma.domain s),
    tau.states s ht_tau = sigma.states s ht_sigma
```

---

## 6. Recommendation

### 6.1 Primary Recommendation: Approach B (Same-MCS at Canonical Level)

**Rationale**:
1. **Minimal invasiveness**: Only affects the canonical model construction, not general semantics
2. **Direct solution**: Eliminates the truth lemma obstruction by design
3. **Standard technique**: This is exactly the Henkin canonical model approach used in classical modal logic
4. **Preserves interpretation**: For completeness purposes, "valid" becomes "valid in all canonical models" which is equivalent for deriving consistency results

**Implementation path**:
1. Define `canonical_accessible` on IndexedMCSFamily
2. Define `canonical_truth_at` using canonical accessibility for box
3. Prove truth lemma for `canonical_truth_at`
4. The box case becomes provable because we only quantify over canonical families
5. Representation theorem connects consistent formulas to canonical satisfaction

### 6.2 Secondary Recommendation: Approach A for General Semantics

If completeness for general validity (not just canonical model validity) is required:
1. Add `modal_accessible` to the semantics
2. Change box definition to use accessibility
3. Re-prove soundness for all axioms
4. This creates a standard Kripke-style logic that admits the Henkin technique

### 6.3 What This Means for the Paper

The paper's semantics (quantifying over ALL histories) represent a **second-order** notion of validity. The recommended approach changes to a **first-order** notion (quantifying over accessible histories).

This is not a weakness but a clarification: the logic axiomatized by TM is complete for accessible-history semantics, which is a standard modal logic. The universal-history semantics is more expressive but inherently second-order.

---

## 7. Next Steps

### 7.1 If Pursuing Approach B (Recommended)

1. Create `CanonicalAccessibility.lean` with:
   - `canonical_accessible` definition
   - Reflexivity, symmetry, transitivity proofs (S5 properties)

2. Modify `CanonicalHistory.lean`:
   - Add `canonical_truth_at` with accessibility-restricted box

3. Modify `TruthLemma.lean`:
   - Prove box case using accessibility restriction
   - Remove sorries for box forward/backward

4. Verify representation theorem still applies

### 7.2 If Pursuing Approach A (General Semantics Change)

1. Create `Accessibility.lean` with:
   - `modal_accessible` definition
   - Proofs that it's an equivalence relation

2. Modify `Truth.lean`:
   - Change box case to use `modal_accessible`

3. Re-prove soundness:
   - Modal K axiom: requires R closed under modal containment
   - Modal T axiom: requires R reflexive (already true for state equality)
   - Modal 4 axiom: requires R transitive (already true)
   - Modal 5 axiom: requires R Euclidean (true for equivalence relations)

4. Proceed with standard Henkin completeness proof

---

## 8. Conclusion

The blocking issue for completeness is not the universal history quantification per se, but the lack of a **relation** between histories that connects semantic truth to MCS membership. The literature on Ockhamist and branching-time logics provides several models for defining such relations.

**Key insight**: Accessibility between histories can be **derived** from existing structure (same state at time, same MCS at time, or shared future). The "same-MCS-at-time" approach (Approach B) is the most direct solution because it aligns with how canonical models are constructed in standard modal logic completeness proofs.

**The codebase's histories are definable, so accessibility should also be definable.** The recommended approach defines accessibility as MCS equality at the evaluation time, which:
- Is fully derivable from the IndexedMCSFamily structure
- Restricts box quantification to relevant histories
- Enables the standard Henkin truth lemma proof
- Preserves parametric time D
- Requires minimal changes to existing code

---

## References

### Academic Literature
- [Stanford Encyclopedia: Temporal Logic](https://plato.stanford.edu/entries/logic-temporal/) - Ockhamist semantics, bundled trees, completeness status
- [Stanford Encyclopedia: Branching Time](https://plato.stanford.edu/entries/branching-time/) - Histories, moments, accessibility
- [Stanford Encyclopedia: Logic of Action](https://plato.stanford.edu/entries/logic-action/) - STIT logic, choice cells
- [Zanardo: Indistinguishability Relations](https://link.springer.com/article/10.1007/s10992-015-9369-3) - I-trees, completeness for bundled trees
- [Ciuni & Zanardo: Branching-Time Logic with Possible Choices](https://link.springer.com/article/10.1007/s11225-010-9291-1) - BTC logic, completeness
- [FormalizedFormalLogic/Foundation](https://github.com/FormalizedFormalLogic/Foundation) - Lean 4 modal logic formalization

### Codebase Files
- `Theories/Bimodal/Semantics/Truth.lean` - Current box semantics (line 112)
- `Theories/Bimodal/Semantics/WorldHistory.lean` - History structure (lines 69-97)
- `Theories/Bimodal/Boneyard/Metalogic_v5/Representation/TruthLemma.lean` - Archived truth lemma with sorries
- `specs/812_canonical_model_completeness/reports/research-005.md` - Previous research identifying the obstruction

### Prior Research in This Task
- research-001.md: Initial analysis of Representation approach
- research-002.md: Plan evaluation and FMP-compactness analysis
- research-003.md: Two validity notions comparison
- research-004.md: Architectural alignment analysis
- research-005.md: Alternative methods analysis (identified universal history quantification as blocking issue)
