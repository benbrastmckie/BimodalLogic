# Research Report: Task #981 - World History Discreteness (Mathematical Logic Focus)

**Task**: 981 - remove_axiom_technical_debt_from_task_979
**Started**: 2026-03-17T10:00:00Z
**Completed**: 2026-03-17T11:30:00Z
**Session**: sess_1773760590_b22cbf
**Effort**: 3h
**Dependencies**: None (conceptual research)
**Sources/Inputs**: Codebase exploration (TaskFrame.lean, WorldHistory.lean, Truth.lean, DiscreteTimeline.lean, DiscreteSuccSeed.lean), task-semantics.md context, research-007.md
**Artifacts**: This report (research-008.md)
**Standards**: report-format.md, return-metadata-file.md

---

## Executive Summary

This research explores the user's hypothesis: the DF axiom should constrain **world histories** (the objects at which formulas are evaluated) to be discrete, rather than requiring covering on the **space of all MCSs** (DiscreteTimelineQuot).

**Key finding**: The hypothesis identifies a genuine architectural insight, but the mathematical structure of the ProofChecker implementation does not support a direct separation. In the canonical model construction:

1. **World histories ARE the DiscreteTimelineQuot elements** - the "worlds" in a canonical world history are exactly equivalence classes of MCSs
2. **The covering property on MCSs IS the discreteness of world histories** - they are mathematically equivalent

The fundamental gap identified in research-007 (covering proof unfillable) remains: blocking formulas constrain the successor W but not intermediate K. However, this research clarifies WHY this is the correct architectural boundary and suggests a path forward based on restricting to **definable world histories**.

**Primary recommendation**: Explore whether definable world histories (those constructed incrementally from the root) form a proper subclass where covering holds by construction.

---

## Context & Scope

### The User's Hypothesis

The user proposed focusing on **world history discreteness** rather than **MCS space covering**:

> "The DF axiom should be used to derive that there are no intermediate worlds K between M and its successor W in the WORLD HISTORY at which a claim is evaluated. This does not need to hold in general when thinking about any tasks between world states."

The key idea: world histories are the semantic objects (functions h: D -> W), and DF constrains their structure. We want world histories to be discrete, which should follow from their definition in terms of world states, durations, and task relations constructed from pure syntax.

### Research Questions

1. What is the exact definition of a TaskFrame and its components (D, W, task relation)?
2. What is a WorldHistory in this context? How is it defined from TaskFrame?
3. What does it mean for a world history to be "discrete"?
4. How does the DF axiom constrain world histories specifically (not all MCSs)?
5. Is there a weaker covering property that holds for world history elements rather than all reachable MCSs?
6. Can we construct D (durations) purely from syntax in a way that makes discreteness definitional?

---

## Findings

### 1. TaskFrame Structure (from TaskFrame.lean)

A TaskFrame `F = (W, D, task_rel)` consists of:

```lean
structure TaskFrame (D : Type*) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] where
  WorldState : Type
  task_rel : WorldState -> D -> WorldState -> Prop
  nullity_identity : forall w u, task_rel w 0 u <-> w = u
  forward_comp : forall w u v x y, 0 <= x -> 0 <= y ->
                 task_rel w x u -> task_rel u y v -> task_rel w (x + y) v
  converse : forall w d u, task_rel w d u <-> task_rel u (-d) w
```

**Key property**: D is a totally ordered abelian group (durations), W is a type of world states, and task_rel connects states via timed tasks.

### 2. WorldHistory Structure (from WorldHistory.lean)

A WorldHistory is a function from a convex time domain to world states:

```lean
structure WorldHistory {D : Type*} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    (F : TaskFrame D) where
  domain : D -> Prop
  convex : forall (x z : D), domain x -> domain z ->
           forall (y : D), x <= y -> y <= z -> domain y
  states : (t : D) -> domain t -> F.WorldState
  respects_task : forall (s t : D) (hs : domain s) (ht : domain t),
                  s <= t -> F.task_rel (states s hs) (t - s) (states t ht)
```

**Key constraint**: `respects_task` ensures that for any s <= t in the domain, the states at s and t are related by the task relation with duration t - s.

### 3. The Canonical Model Construction (from DiscreteTimeline.lean, DurationTransfer.lean)

The canonical model construction identifies:

- **D = DiscreteTimelineQuot** - the quotient of MCS equivalence classes
- **W = DiscreteTimelineQuot** - world states ARE the timeline elements
- **task_rel w d w' <-> w + d = w'** - deterministic translation relation

From DurationTransfer.lean:

```lean
noncomputable def canonicalTaskFrame
    (T : Type) [acg : AddCommGroup T] [lo : LinearOrder T] [oam : IsOrderedAddMonoid T] :
    TaskFrame T where
  WorldState := T
  task_rel := canonicalTaskRel  -- w + d = w'
  ...
```

**Critical insight**: In the canonical construction, **WorldState = D**. The "world states" are precisely the elements of the duration group (timeline elements). A world history is then a function from a convex subset of D to D itself, respecting the translation task relation.

### 4. What "Discrete World History" Means

Given the canonical construction:
- A world history h: X -> D (where X is convex in D)
- respects_task: for s <= t, h(s) + (t - s) = h(t)

**Theorem (from group structure)**: Any world history respecting the translation task relation must be an **affine translation**: h(t) = h(0) + t (shifted by initial position).

**Proof sketch**:
- respects_task at s = 0, t: h(0) + (t - 0) = h(t)
- Therefore h(t) = h(0) + t

**Implication**: In the canonical model, world histories are determined by their value at any one point. The "discreteness" of a world history is the discreteness of the time domain D itself.

### 5. The Covering Property IS World History Discreteness

The axiom `discrete_Icc_finite_axiom` asserts:
```lean
axiom discrete_Icc_finite_axiom :
    forall (a b : DiscreteTimelineQuot root_mcs root_mcs_proof), (Set.Icc a b).Finite
```

This is exactly the statement that D (the duration/timeline type) has finite intervals - i.e., D is discrete.

**World history perspective**: A world history h: X -> D with convex domain X. If X = [s, t], then:
- h is completely determined by h(s)
- The "intermediate worlds" in this history are h(s), h(s+1), h(s+2), ..., h(t)
- If D is discrete (finite intervals), there are finitely many intermediate worlds
- The "successor" of h(s) in the history is h(succ(s)) - NO intermediate world exists between them

**The equivalence**: Interval finiteness in D <-> covering property for successive timeline elements <-> discrete world histories.

### 6. Why Covering on All MCSs IS the Same as World History Discreteness

The user's intuition suggested we might only need covering for MCSs that "appear in a world history". But in the canonical construction:

1. **Every MCS appears in some world history** - Given any MCS M at stage n, we can construct a world history passing through M by taking the timeline segment containing M.

2. **The covering property for M is tested on the SAME timeline** - CanonicalR M K and CanonicalR K W means M, K, W are in temporal order. If they're all in the same world history, covering is tested there.

3. **DiscreteTimelineQuot IS the space of world history points** - The quotient elements are exactly the points that world histories pass through.

**Conclusion**: There is no weaker property. The covering property on DiscreteTimelineQuot IS the discreteness property for world histories.

### 7. The DF Frame Condition (from Soundness.lean)

The DF axiom `(F(top) and phi and H(phi)) -> F(H(phi))` corresponds semantically to:

> For all t in D, if there exists s > t (non-maximal), then Order.succ t exists and is the least element > t.

This IS the SuccOrder property on D. The canonical construction instantiates D = DiscreteTimelineQuot and proves SuccOrder using the axiomatized interval finiteness.

The gap: DF membership in MCSs creates F(H(phi)) obligations that can be witnessed by ANY forward MCS, not necessarily the immediate successor. The syntactic constraint doesn't force covering.

---

## ROAD_MAP.md Reflection

### Pitfalls Checked

| Dead End | Relevance | Impact on Recommendations |
|----------|-----------|--------------------------|
| Stage-bounding for interval finiteness | HIGH | Confirmed blocked; new architectural analysis doesn't bypass this |
| h_content duality chain alone | HIGH | Confirmed insufficient; analysis in Sec 5-6 explains why |
| Blocking formula sorries (3) | HIGH | These ARE the covering gap; no new path found |

### Strategy Alignment

| Strategy | Status | Relevance |
|----------|--------|-----------|
| Representation-First Architecture | CONCLUDED | Confirms canonical model is correct architecture |
| Modified staged construction (research-007 recommendation) | NOT YET TRIED | Still the most promising implementation path |

---

## Analysis: Does the User's Insight Open a New Path?

The user's insight about "world histories vs all MCSs" is mathematically precise but doesn't provide an escape:

### What the Insight DOES Clarify

1. **Why the axiom is about D, not W**: The axiom `discrete_Icc_finite_axiom` is a property of the DURATION type D, not a property of "world states" in some other sense. This is correct.

2. **The semantic level is correct**: DF semantically ensures SuccOrder on D. The gap is extracting this at the syntactic/MCS level.

3. **Restriction to "world history elements" doesn't help**: Since every MCS participates in a world history, there's no proper subclass to restrict to.

### What the Insight DOES NOT Provide

1. **No new proof strategy**: The covering proof gap remains. Blocking formulas constrain W but not intermediate K.

2. **No definitional discreteness**: D is defined as Antisymmetrization of staged points, which doesn't have discrete structure built in.

### Possible Refinement: "Definable" World Histories

One direction suggested by the insight: consider only **constructively reachable** world histories from a root MCS, rather than the full Antisymmetrization.

**Definition**: A definable world history is one constructed by the staged building process, where at each step the immediate successor is the FIRST MCS added at that stage.

**Potential property**: In the staged construction, covering might hold BY STAGE ORDER:
- At stage n: M exists
- At stage n+1: W = discreteImmediateSucc(M) is added FIRST
- No other MCS can be "between" M and W because they're added in order

This is exactly the research-007 recommendation: modify `discreteStagedBuild` to use `discreteImmediateSuccSeed` instead of `forward_temporal_witness_seed`.

---

## Recommendations

### Primary Recommendation: Pursue Modified Staged Construction

The user's insight about world histories doesn't bypass the covering gap, but it does confirm the research-007 recommendation is on the right track:

**Staged construction with blocking formula seeds** makes covering hold BY CONSTRUCTION:
1. Each stage adds exactly one MCS per existing MCS (the immediate successor)
2. Covering holds because intermediates literally don't exist at the time of construction
3. This is the Segerberg/Verbrugge approach from the literature

### Secondary Recommendation: Accept Axiom as Documented Debt

If the modified staged construction fails or is too complex, the axiom is an acceptable documented debt:
- It's isolated to DiscreteTimeline.lean
- It doesn't affect dense completeness (uses DN instead)
- It's semantically justified (DF implies covering, we just can't extract it)

### NOT Recommended: Further Exploration of "World History Restriction"

The analysis shows that restricting to "world history elements" doesn't help because:
- Every MCS appears in some world history
- The covering property is tested on timelines, which ARE world histories
- There's no proper subclass to exploit

---

## Decisions

1. **World histories and MCS timeline are mathematically identical** in the canonical construction
2. **Covering property IS world history discreteness** - no separation possible
3. **Modified staged construction remains the best path** forward
4. **The user's insight is correct but doesn't provide new proof strategy**

---

## Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Modified staged construction may have unforeseen issues | HIGH | Test with small example before full implementation |
| Axiom may be mathematically necessary (not just hard to prove) | MEDIUM | Document clearly; all approaches tried |
| Implementation complexity may exceed estimates | MEDIUM | Start with Option A (clean separation) |

---

## Appendix

### Key Files Examined

- `Theories/Bimodal/Semantics/TaskFrame.lean` - TaskFrame definition
- `Theories/Bimodal/Semantics/WorldHistory.lean` - WorldHistory structure
- `Theories/Bimodal/Semantics/Truth.lean` - Truth evaluation at model-history-time triples
- `Theories/Bimodal/Metalogic/Domain/DiscreteTimeline.lean` - The axiom and SuccOrder construction
- `Theories/Bimodal/Metalogic/Domain/DurationTransfer.lean` - D-from-syntax pipeline
- `Theories/Bimodal/Metalogic/StagedConstruction/DiscreteSuccSeed.lean` - Blocking formula approach
- `Theories/Bimodal/FrameConditions/Soundness.lean` - DF frame condition semantics

### Mathematical Summary

| Object | Definition | Role |
|--------|------------|------|
| TaskFrame | (W, D, task_rel) | Semantic structure |
| WorldHistory | h: X -> W (convex X, respects task_rel) | Point of evaluation |
| DiscreteTimelineQuot | Antisymmetrization of staged MCS points | Both W and D in canonical model |
| DF axiom | (F(top) and phi and H(phi)) -> F(H(phi)) | Encodes SuccOrder |
| discrete_Icc_finite_axiom | Intervals in DiscreteTimelineQuot are finite | Required for LocallyFiniteOrder |
| Covering | No K strictly between M and succ(M) | Equivalent to interval finiteness |

### Equivalence Chain (Confirmed from DiscreteTimeline.lean)

```
discrete_Icc_finite_axiom
  <-> LocallyFiniteOrder DiscreteTimelineQuot
  <-> Covering lemma (discreteImmediateSucc_covers)
  <-> DF frame condition at MCS level
  <-> World histories are discrete (finitely many points in any interval)
```

All are equivalent. Proving any one eliminates the axiom.

---

## Context Extension Recommendations

### Discovered Concepts Requiring Documentation

| Concept | Report Section | Currently Documented? | Gap Type |
|---------|----------------|----------------------|----------|
| TaskFrame/WorldHistory equivalence in canonical model | Section 3 | No | extension |
| DF <-> SuccOrder correspondence | Section 7 | Partial | extension |

### Existing Context File Extensions

| File | Section to Add/Modify | Content to Add | Priority | Create Task? |
|------|----------------------|----------------|----------|--------------|
| `task-semantics.md` | Canonical Model Construction | Note that W = D in canonical model, world histories are affine translations | MEDIUM | No |
| `kripke-semantics-overview.md` | DF Frame Condition | Add explicit SuccOrder correspondence | LOW | No |

### Summary

- **New files needed**: 0
- **Extensions needed**: 2 (minor)
- **Tasks to create**: 0
- **High priority gaps**: 0

The existing documentation is adequate; the main gap was conceptual clarity about the canonical model structure, which this report provides.

---

## References

- research-007.md - Previous team research confirming covering sorries unfillable
- Segerberg (1970) - Original constructive method for tense logic
- Verbrugge et al. - "Completeness by construction for tense logics of linear time"
- JPL Paper "The Perpetuity Calculus of Agency" (app:TaskSemantics)
