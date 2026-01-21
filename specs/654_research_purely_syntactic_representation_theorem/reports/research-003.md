# Research Report: Algebraic Canonical Model Construction for TaskFrame

- **Task**: 654 - Research Purely Syntactic Representation Theorem
- **Started**: 2026-01-20T14:00:00Z
- **Completed**: 2026-01-20T16:00:00Z
- **Effort**: 2 hours
- **Priority**: High
- **Dependencies**: research-002.md (prior analysis of structural discrepancy)
- **Sources/Inputs**:
  - Existing codebase: TaskFrame.lean, Truth.lean, CanonicalModel.lean, SemanticCanonicalModel.lean
  - Mathlib: FreeAbelianGroup, LinearOrderedAddCommGroup, BooleanAlgebra
  - Literature: Blackburn et al. "Modal Logic", Goldblatt "Mathematical Modal Logic"
  - nLab: algebraic models for modal logics
  - Stanford Encyclopedia: Temporal Logic, Algebraic Propositional Logic
- **Artifacts**: This report (research-003.md)
- **Standards**: report-format.md, artifact-formats.md

## Executive Summary

- The key challenge is constructing a TaskFrame parametric over ANY totally ordered additive commutative group D, not committing to Int or any specific duration type
- **Approach 4 (Algebraic/Lindenbaum-Tarski)** is theoretically elegant but requires substantial infrastructure (Boolean algebras with operators, Stone duality) not currently in the codebase
- **Approach 5 (Parametric Time with Syntactic Duration)** attempts to build D from syntax, but requires the logic to express enough about durations to form an ordered group - which TM logic does not do
- **Recommended Approach**: Use a **universal construction** where the canonical model is parametric over D, with task_rel defined via a transitive closure that works for any D satisfying the typeclass constraints
- The construction works by treating time abstractly: MCS worlds are paired with abstract time points from D, and the task relation is defined to ensure nullity and compositionality hold by construction

## Context & Scope

### Problem Statement

The current implementation has two canonical model attempts:
1. **CanonicalFrame** (CanonicalModel.lean): Does not instantiate TaskFrame at all - uses separate accessibility relations
2. **SemanticCanonicalFrame** (SemanticCanonicalModel.lean): Instantiates TaskFrame Int but has a sorry on compositionality due to finite time domain bounds

Both approaches fail to produce a fully general canonical TaskFrame D for arbitrary D.

### Requirements for Solution

A valid canonical model construction must:
1. Produce a `TaskFrame D` for any `D` with `[AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]`
2. Have a well-defined task_rel that satisfies nullity and compositionality without sorry
3. Support a truth lemma connecting MCS membership to semantic truth
4. Maintain mathematical elegance and generality

### Scope of This Research

This report analyzes Approaches 4 and 5 from research-002.md in depth and proposes a concrete construction strategy.

## Findings

### Analysis of Approach 4: Algebraic Construction via Lindenbaum-Tarski

**Concept**: Form the Lindenbaum-Tarski algebra of TM formulas:
1. Quotient formulas by provable equivalence: `[phi] = [psi]` iff `|- phi <-> psi`
2. This forms a Boolean algebra (conjunction = meet, disjunction = join, negation = complement)
3. Add operators for box, H (all_past), G (all_future)
4. The Stone space (ultrafilters) of this algebra gives canonical worlds
5. Frame conditions correspond to algebraic properties

**Technical Requirements**:
- Need to show the quotient forms a Boolean algebra (distributivity, complementation)
- Need Boolean algebra with operators (BAO) structure for modal/temporal connectives
- Need Stone representation theorem to extract a task frame
- Need to extract a task_rel satisfying nullity/compositionality from the algebraic structure

**Advantages**:
- Mathematically principled and well-studied
- Compositionality becomes an algebraic consequence rather than direct proof
- Works uniformly for any normal modal logic

**Challenges for TM Logic**:
- TM is bimodal with interacting temporal and modal operators - standard BAO theory handles single operators
- The task relation combines temporal order with modal accessibility in a non-standard way
- Significant infrastructure development required (Mathlib has BooleanAlgebra but not full BAO machinery for modal logic)
- The connection between BAO structure and TaskFrame's compositionality axiom is not immediate

**Assessment**: High mathematical elegance but **high implementation cost**. Would require 1000+ lines of new infrastructure before addressing the specific TM logic requirements.

### Analysis of Approach 5: Parametric Time with Syntactic Duration Type

**Concept**: Define a syntactic duration type that represents equivalence classes of temporal expressions, inheriting ordered group structure from what the logic can prove about comparisons.

**Problem**: TM logic does NOT have explicit duration terms in its syntax:
```lean
inductive Formula where
  | atom : String -> Formula
  | bot : Formula
  | imp : Formula -> Formula -> Formula
  | box : Formula -> Formula
  | all_past : Formula -> Formula
  | all_future : Formula -> Formula
```

There are no duration constants, duration variables, or duration comparison operators. The logic only has:
- `H phi` (universally true in past)
- `G phi` (universally true in future)

**Attempted Solution**: Extend the language with explicit durations:
```
phi ::= ... | after(d, phi)  -- phi is true d time units from now
```

**Critical Flaw**: Adding duration terms requires specifying what algebraic structure they have:
- If we use Int for d, we've committed to discreteness
- If we use Rat for d, we've committed to density
- If we use an abstract ordered group, we need to specify its theory

Any choice bakes in assumptions about the time type, defeating the goal of parametric generality.

**Assessment**: **Not viable** for achieving parametric completeness. The language extension approach fundamentally conflicts with keeping D abstract.

### Proposed Approach: Universal Canonical Model Parametric Over D

**Key Insight**: Rather than extracting D from syntax, we can construct a canonical model that works for ANY D by using D abstractly in the construction.

**Construction Strategy**:

#### Step 1: Define Canonical Worlds

```lean
/-- A canonical world is a maximal consistent set paired with a time point -/
structure CanonicalWorld (D : Type*) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] where
  mcs : Set Formula
  time : D
  is_mcs : SetMaximalConsistent mcs
```

Note: The time parameter is from the abstract type D, not from syntax.

#### Step 2: Define Canonical Task Relation

```lean
/-- Two worlds are related by duration d if:
    1. Same MCS component (for box accessibility) OR
    2. Temporal witness exists in the MCS (for past/future) -/
def canonical_task_rel (w : CanonicalWorld D) (d : D) (v : CanonicalWorld D) : Prop :=
  if d = 0 then w.mcs = v.mcs ∧ w.time = v.time
  else if 0 < d then
    -- For positive d: w's future formulas propagate to v, and v's past formulas propagate back
    (∀ phi, Formula.all_future phi ∈ w.mcs → phi ∈ v.mcs) ∧
    (∀ phi, Formula.all_past phi ∈ v.mcs → phi ∈ w.mcs) ∧
    v.time = w.time + d
  else
    -- For negative d: symmetric
    (∀ phi, Formula.all_past phi ∈ w.mcs → phi ∈ v.mcs) ∧
    (∀ phi, Formula.all_future phi ∈ v.mcs → phi ∈ w.mcs) ∧
    v.time = w.time + d
```

#### Step 3: Prove Frame Conditions

**Nullity** (`task_rel w 0 w`):
- Trivially holds: same MCS, same time

**Compositionality** (`task_rel w d1 u ∧ task_rel u d2 v → task_rel w (d1+d2) v`):
- The time arithmetic is straightforward: `v.time = u.time + d2 = (w.time + d1) + d2 = w.time + (d1 + d2)`
- The formula propagation follows from transitivity of the H/G accessibility conditions

**Key Advantage**: This construction is parametric over D because:
- D is a type parameter, not fixed to Int
- The task_rel definition only uses D's algebraic operations (+, <, 0)
- The proofs only use D's typeclass properties

#### Step 4: Truth Lemma

For the truth lemma, we need to connect MCS membership to semantic truth:

```
phi ∈ w.mcs ↔ truth_at M (tau_w) (w.time) phi
```

where `tau_w` is a canonical history through world w.

The key cases:
- **Atoms**: By valuation construction
- **Temporal (H phi)**: `H phi ∈ w.mcs` iff `∀ s < w.time, phi` holds semantically (by MCS properties)
- **Temporal (G phi)**: `G phi ∈ w.mcs` iff `∀ s > w.time, phi` holds semantically
- **Box**: `box phi ∈ w.mcs` iff `phi` holds at all box-accessible MCS

### Comparison with Current SemanticCanonicalModel

| Aspect | SemanticCanonicalModel | Proposed Universal Approach |
|--------|------------------------|----------------------------|
| Time Type | Fixed to Int | Parametric D |
| Worlds | HistoryTimePair quotients | MCS + abstract time |
| Compositionality | Sorry (finite bounds) | Provable (time arithmetic) |
| Truth Lemma | Via FiniteWorldState | Via MCS properties |
| Complexity | Medium | Medium-High |

### Why Compositionality Succeeds in Universal Approach

The SemanticCanonicalModel's compositionality fails because:
- HistoryTimePair uses FiniteTime bounded by temporalBound(phi)
- Duration d1 + d2 can exceed bounds when both are near maximum

The universal approach avoids this because:
- Times are abstract elements of D, not bounded finite types
- The time arithmetic `w.time + (d1 + d2)` is always well-defined in the group D
- No finiteness constraints on time points

### Mathematical Foundation: Free Time Domain

An alternative perspective: we can view the canonical model as using a "free" time domain:

1. Define `CanonicalTime` as the free ordered additive group generated by time witnesses in MCS
2. Any concrete D maps into this structure via the universal property of free groups
3. The canonical frame works for the free time, which embeds into any concrete D

This connects to Approach 5's spirit but avoids extending the object language - the "duration terms" are meta-level constructions, not formula constituents.

## Decisions

1. **Reject Approach 4 (Pure Algebraic)**: Too much infrastructure cost for uncertain payoff in the TM-specific setting
2. **Reject Approach 5 (Syntactic Duration Type)**: Extending the language bakes in unwanted assumptions
3. **Adopt Universal Parametric Approach**: Construct canonical model parametric over abstract D, with explicit time component in worlds
4. **Use Abstract Time Arithmetic**: Task relation defined via D's group operations, not finite bounds

## Recommendations

### Phase 1: Refactor Canonical World Definition

1. Create `Metalogic_v2/Representation/UniversalCanonicalModel.lean`
2. Define `CanonicalWorld D` as MCS + time point from D
3. Prove basic properties (inherited from MCS theory)

**Files to modify**:
- Create: `Theories/Bimodal/Metalogic_v2/Representation/UniversalCanonicalModel.lean`

### Phase 2: Define Canonical Task Relation

1. Define `canonical_task_rel : CanonicalWorld D -> D -> CanonicalWorld D -> Prop`
2. Prove nullity (straightforward)
3. Prove compositionality (time arithmetic + formula propagation)

**Key insight**: Define the relation to make compositionality hold BY CONSTRUCTION, not as a difficult theorem.

### Phase 3: Construct Canonical WorldHistory

1. For each MCS Gamma, construct a canonical history through Gamma
2. Prove history satisfies respects_task condition
3. Show history has full domain (all times in D)

### Phase 4: Prove Truth Lemma

1. Induction on formula structure
2. Atom case: by valuation construction
3. Temporal cases: by MCS H/G accessibility properties
4. Box case: by MCS box accessibility property

### Phase 5: Instantiate TaskFrame

1. Define `UniversalCanonicalFrame (D : Type*) [...] : TaskFrame D`
2. Define `UniversalCanonicalModel : TaskModel (UniversalCanonicalFrame D)`
3. Prove representation theorem: consistent formulas satisfiable in UniversalCanonicalModel

### Estimated Effort

| Phase | Effort | Risk |
|-------|--------|------|
| Phase 1 | 4 hours | Low |
| Phase 2 | 8 hours | Medium (compositionality proof) |
| Phase 3 | 6 hours | Medium (history construction) |
| Phase 4 | 12 hours | High (truth lemma backward directions) |
| Phase 5 | 4 hours | Low |
| **Total** | **34 hours** | Medium overall |

## Risks & Mitigations

### Risk 1: Truth Lemma Backward Directions

**Risk**: The backward direction of truth lemma cases (semantic truth implies MCS membership) may require complex MCS closure arguments.

**Mitigation**: The MCS theory in MaximalConsistent.lean already proves key properties (negation completeness, deductive closure). Build directly on existing infrastructure.

### Risk 2: WorldHistory Construction Complexity

**Risk**: Constructing canonical histories with full time domain may be complex for abstract D.

**Mitigation**: Use Choice axiom to select history configurations. The construction is noncomputable, which is acceptable for completeness proofs.

### Risk 3: Interaction Between Box and Temporal Operators

**Risk**: TM logic has interacting modal and temporal operators; the canonical relation must handle both correctly.

**Mitigation**: Define task_rel to decouple: temporal part handles time arithmetic, modal part handles formula propagation. Interactions handled via MCS closure properties (proven in existing CanonicalModel.lean).

### Risk 4: Verification of Existing Semantics Compatibility

**Risk**: The new canonical model must be compatible with existing Truth.lean semantics definition.

**Mitigation**: The Truth.lean definition is already parametric over D. Carefully verify that canonical history construction aligns with WorldHistory type requirements.

## Appendix

### References

- Blackburn, de Rijke, Venema. "Modal Logic" (Cambridge Tracts in Theoretical Computer Science). Chapter 4: Completeness.
- [Goldblatt, R. "Mathematical Modal Logic: A View of Its Evolution"](https://homepages.ecs.vuw.ac.nz/~rob/papers/modalhist.pdf)
- [nLab: Algebraic model for modal logics](https://ncatlab.org/nlab/show/algebraic+model+for+modal+logics)
- [Stanford Encyclopedia: Temporal Logic](https://plato.stanford.edu/entries/logic-temporal/)
- [Stanford Encyclopedia: Algebraic Propositional Logic](https://plato.stanford.edu/entries/logic-algebraic-propositional/)

### Relevant Mathlib Types

```lean
-- Ordered group typeclass combination required by TaskFrame
[AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]

-- Alternative single typeclass (equivalent)
[LinearOrderedAddCommGroup D]

-- Free abelian group (potential meta-level construction)
FreeAbelianGroup : Type* -> Type*
```

### Existing Codebase Entry Points

- `Theories/Bimodal/Semantics/TaskFrame.lean` - Target structure definition
- `Theories/Bimodal/Metalogic_v2/Core/MaximalConsistent.lean` - MCS theory
- `Theories/Bimodal/Metalogic_v2/Representation/CanonicalModel.lean` - MCS canonical world
- `Theories/Bimodal/Semantics/Truth.lean` - Semantic truth definition (parametric over D)
- `Theories/Bimodal/Semantics/WorldHistory.lean` - History structure

### Key Insight Summary

The fundamental insight is that **parametric completeness** does not require extracting the time type D from the syntax. Instead:

1. Keep D as a type parameter throughout the construction
2. Use D's algebraic structure (group operations, order) abstractly
3. Define task_rel so frame conditions hold by construction
4. The canonical model works for ANY D satisfying the typeclasses

This is the standard approach in parametric type theory: work with abstract types constrained by typeclasses rather than concrete implementations.
