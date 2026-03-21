# Research Report: Task #654 (Part 2)

**Task**: 654 - Research Purely Syntactic Representation Theorem
**Date**: 2026-01-20
**Focus**: Structural discrepancy between CanonicalFrame and TaskFrame

## Summary

The CanonicalFrame definition in the current implementation does not instantiate the general TaskFrame structure from the semantics. This creates a fundamental disconnect: the representation theorem proves satisfiability in an ad-hoc frame structure that doesn't match the semantic model definition. A purely syntactic canonical model must produce a genuine `TaskFrame D` where D is a totally ordered commutative group, with proper task_rel, nullity, and compositionality properties derived syntactically.

## The Discrepancy: CanonicalFrame vs TaskFrame

### TaskFrame Definition (Semantics/TaskFrame.lean)

The TaskFrame is the **general semantic structure** for TM bimodal logic:

```lean
structure TaskFrame (D : Type*) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] where
  /-- Type of world states -/
  WorldState : Type
  /-- Task relation: `task_rel w x u` means u is reachable from w by task of duration x -/
  task_rel : WorldState → D → WorldState → Prop
  /-- Nullity: zero-duration task is identity -/
  nullity : ∀ w, task_rel w 0 w
  /-- Compositionality: tasks compose with time addition -/
  compositionality : ∀ w u v x y, task_rel w x u → task_rel u y v → task_rel w (x + y) v
```

**Key requirements**:
1. Time type D must be a **totally ordered additive commutative group** (not just Int or Nat)
2. The task_rel must satisfy **nullity** (reflexivity at 0) and **compositionality** (transitivity with time addition)
3. This is parametric over D - could be Int, Rat, Real, or any custom ordered group

### CanonicalFrame Definition (Metalogic_v2/Representation/CanonicalModel.lean)

The current CanonicalFrame is an **ad-hoc structure**:

```lean
structure CanonicalFrame where
  /-- All canonical worlds (maximal consistent sets) -/
  worlds : Set CanonicalWorldState
  /-- Box accessibility: w' is box-accessible from w if all box phi in w implies phi in w' -/
  box_accessibility : CanonicalWorldState → Set CanonicalWorldState
  /-- Past accessibility: for H (universal past) operator -/
  past_accessibility : CanonicalWorldState → Set CanonicalWorldState
  /-- Future accessibility: for G (universal future) operator -/
  future_accessibility : CanonicalWorldState → Set CanonicalWorldState
```

**Critical issues**:
1. **No time type parameter**: CanonicalFrame has no D parameter at all
2. **No task_rel**: Instead uses separate accessibility relations for box/past/future
3. **No nullity/compositionality**: These frame conditions are not represented
4. **Does not extend TaskFrame**: Cannot be used as a TaskFrame

### Structural Comparison

| Feature | TaskFrame | CanonicalFrame |
|---------|-----------|----------------|
| Time type | Parametric D (ordered group) | None |
| World states | F.WorldState | CanonicalWorldState |
| Task relation | task_rel : W -> D -> W -> Prop | Not present |
| Box relation | Derived from task_rel | Explicit box_accessibility |
| Temporal relations | Via task_rel and time ordering | Separate past/future_accessibility |
| Nullity | Required axiom | Not enforced |
| Compositionality | Required axiom | Not enforced |

### Why This Matters

The **representation theorem** should prove:

> For every consistent context Gamma, there exists a **TaskFrame D** and **TaskModel** such that Gamma is satisfiable.

But the current implementation proves:

> For every consistent context Gamma, there exists a **CanonicalFrame** (not a TaskFrame!) where Gamma is satisfiable.

This is a **different theorem** because CanonicalFrame is not a TaskFrame. The soundness theorem proves properties about TaskFrames, so completeness should produce TaskFrames.

## Analysis of SemanticCanonicalFrame

The SemanticCanonicalModel.lean file attempts to construct a proper TaskFrame:

```lean
noncomputable def SemanticCanonicalFrame (phi : Formula) : TaskFrame Int where
  WorldState := SemanticWorldState phi
  task_rel := semantic_task_rel phi
  nullity := semantic_task_rel_nullity phi
  compositionality := fun w u v d1 d2 => semantic_task_rel_compositionality phi w u v d1 d2
```

**This is closer to correct**, but has problems:
1. Uses Int as the time type (acceptable for concrete instances)
2. The `semantic_task_rel_compositionality` theorem has a **sorry** due to finite time domain bounds
3. The construction uses **history-time pairs** as semantic objects, not purely syntactic MCS worlds

## The Fundamental Challenge

### Why Compositionality is Hard

The task_rel for a canonical model is typically defined as:

```
task_rel w d v iff "there exists a history through w and v with duration d"
```

Compositionality requires: if task_rel w d1 u and task_rel u d2 v, then task_rel w (d1+d2) v

This means: if we have histories witnessing w->u and u->v, we can combine them into a history witnessing w->v. For **infinite** models this works via concatenation. For **finite** models (bounded time domain), the combined duration d1+d2 might exceed the bounds.

### The Finite Model Dilemma

The codebase uses a finite time domain `[-k, k]` where k = temporalBound(phi). This bounds possible durations to `[-2k, 2k]`. But:
- d1 can be up to 2k
- d2 can be up to 2k
- d1 + d2 can be up to 4k

When d1+d2 exceeds 2k, no witness times exist, and compositionality fails.

## Approaches to Resolve the Discrepancy

### Approach 1: Pure MCS Canonical Model with Unbounded Time

**Key insight**: Use the infinite canonical model for the representation theorem, not a finite approximation.

**Construction**:
1. Worlds W = all maximal consistent sets of formulas
2. Time type D = Int (or any ordered group)
3. Task relation: `task_rel w d v` iff there exists a history (sequence of MCS) connecting w to v with duration d

**Nullity proof**:
- For any w, the constant history at w witnesses `task_rel w 0 w`

**Compositionality proof**:
- Given histories h1: w -[d1]-> u and h2: u -[d2]-> v
- Concatenate to get h: w -[d1+d2]-> v
- This works because we're not bounded by a finite domain

**Challenge**: Defining "history" purely syntactically requires specifying what formulas hold at each time, and ensuring consistency across the history.

### Approach 2: Syntactic Task Relation via Temporal Witnesses

**Define task_rel syntactically**:
```
task_rel w d v iff:
  - For all phi: if all_past(phi) in w, then (if d > 0 then phi in v else true)
  - For all phi: if all_future(phi) in w, then (if d < 0 then phi in v else true)
  - (Similar conditions for v's past/future)
```

This makes the relation dependent on what temporal formulas are in the MCS.

**Problem**: This doesn't obviously satisfy compositionality - the relation is about single-step witnesses, not transitive closure.

### Approach 3: Build Task Relation as Transitive Closure

**Define base relation**:
```
task_rel_step w d v iff (the MCS-based single-step condition)
```

**Define task_rel as transitive closure**:
```
task_rel = reflexive-transitive closure of task_rel_step with additive time composition
```

**Benefits**:
- Nullity is automatic (reflexive closure)
- Compositionality is automatic (transitive closure)

**Challenge**: Proving the truth lemma - need to show this definition matches the semantics.

### Approach 4: Algebraic Construction

**Use Lindenbaum-Tarski algebra**:
1. Form the quotient of formulas by provable equivalence
2. This is a Boolean algebra with operators for box, H, G
3. The Stone space of this algebra gives a frame
4. The frame satisfies the required properties by algebraic duality

**Benefits**:
- Well-understood mathematical foundations
- Compositionality follows from algebraic properties

**Challenge**: Significant infrastructure needed; mapping back to Kripke-style frames is non-trivial.

### Approach 5: Parametric Time with Syntactic Duration Type

**Observation**: The TaskFrame is parametric over any D satisfying the ordered group typeclass.

**Idea**: Define a **syntactic duration type** that represents equivalence classes of temporal expressions:
- Elements are "duration terms" like "0", "1", "-1", "d1 + d2", etc.
- The ordering is derived from what the logic can prove about comparisons
- This type inherits the ordered group structure

**Benefits**:
- Fully syntactic construction
- Automatically satisfies algebraic properties

**Challenge**: Defining this type rigorously and proving it satisfies the typeclasses.

## Recommended Approach

Based on the analysis, I recommend **Approach 1 (Pure MCS Canonical Model)** with **Approach 3 (Transitive Closure)** as a backup:

### Phase 1: Refactor CanonicalFrame to be a TaskFrame

Create a new definition that properly instantiates TaskFrame:

```lean
/-- The purely syntactic canonical frame for TM logic -/
noncomputable def SyntacticCanonicalFrame : TaskFrame Int where
  WorldState := CanonicalWorldState
  task_rel := syntactic_task_rel
  nullity := syntactic_task_rel_nullity
  compositionality := syntactic_task_rel_compositionality
```

### Phase 2: Define Syntactic Task Relation

Define the relation in terms of MCS containment:

```lean
/-- Two MCS are temporally related with duration d if there exists
    a consistent chain of MCS connecting them -/
def syntactic_task_rel (w : CanonicalWorldState) (d : Int) (v : CanonicalWorldState) : Prop :=
  if d = 0 then w = v
  else if d > 0 then ∃ chain : TemporalChain w v d, chain.consistent
  else ∃ chain : TemporalChain v w (-d), chain.consistent
```

Where `TemporalChain` is a sequence of MCS with appropriate temporal witness conditions.

### Phase 3: Prove Frame Properties

1. **Nullity**: When d = 0, task_rel w 0 w holds by reflexivity
2. **Compositionality**: Chain concatenation preserves consistency

### Phase 4: Truth Lemma

Prove that for formulas in the closure:
- `phi in w` iff `truth_at SyntacticCanonicalModel tau t phi` for appropriate tau/t

This requires showing the syntactic task relation matches semantic truth.

## Technical Requirements

### Time Type Flexibility

The solution should work with any D satisfying:
```lean
[AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
```

For the canonical model, Int suffices, but the architecture should be general.

### Consistency with Current Semantics

The truth_at definition (Semantics/Truth.lean) uses:
- Atoms: domain membership + valuation
- Box: quantification over all histories at current time
- Temporal: quantification over all times (not just domain)

The canonical model construction must produce a model where these definitions give the expected truth values.

### Finite Model Property Separation

The FMP should be treated separately from the representation theorem:
1. **Representation theorem**: Produces infinite canonical TaskFrame
2. **FMP**: Uses filtration to create finite TaskFrame from infinite one

## Risks and Mitigations

### Risk 1: Chain Consistency is Hard to Define
**Mitigation**: Use standard modal logic technique of "generated submodels" - define consistency inductively along the chain.

### Risk 2: Compositionality Proof Complex
**Mitigation**: Break into smaller lemmas; use the chain structure to enable inductive arguments.

### Risk 3: Truth Lemma Backward Directions
**Mitigation**: Use negation-completeness of MCS (already proven); the MCS properties in MaximalConsistent.lean are solid.

### Risk 4: Box Operator Semantics Mismatch
**Mitigation**: The box operator quantifies over all histories, which corresponds to quantifying over all MCS in the canonical model - this is the standard correspondence.

## Summary of Findings

1. **Current CanonicalFrame is structurally wrong**: It does not instantiate TaskFrame
2. **SemanticCanonicalFrame is closer but has a sorry**: Compositionality fails for unbounded durations in finite domain
3. **The solution requires an infinite canonical model**: Finite model property should be achieved via filtration, not by starting with finite structures
4. **Task relation must be defined syntactically**: Using MCS containment conditions for temporal operators
5. **Compositionality can be achieved via transitive closure**: Or by careful chain construction

## Next Steps

1. Define `SyntacticCanonicalFrame : TaskFrame Int` with MCS worlds
2. Define `syntactic_task_rel` based on temporal formula containment
3. Prove nullity and compositionality
4. Prove the truth lemma for this new frame
5. Update representation theorem to produce this TaskFrame
6. Implement filtration for FMP (separate concern)

## References

- TaskFrame definition: `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Semantics/TaskFrame.lean`
- Current CanonicalFrame: `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic_v2/Representation/CanonicalModel.lean`
- SemanticCanonicalFrame: `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic_v2/Representation/SemanticCanonicalModel.lean`
- Truth semantics: `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Semantics/Truth.lean`
- WorldHistory: `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Semantics/WorldHistory.lean`
- Previous research: `/home/benjamin/Projects/ProofChecker/specs/654_research_purely_syntactic_representation_theorem/reports/research-001.md`
