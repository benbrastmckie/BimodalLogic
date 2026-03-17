# Research Report: Semantics Architecture Analysis for Dense Algebraic Completeness

**Task**: 988 - Dense Algebraic Completeness
**Session**: sess_1742162400_988r3
**Date**: 2026-03-17
**Focus**: "Study the semantics architecture - the distinction between world states (W) and durations (D), and how both must be constructed from syntax for algebraic completeness."

---

## Executive Summary

The semantics has **TWO distinct syntactic components** that must be constructed for completeness:

1. **World States (W)**: The set of possible states/valuations - constructed from MCS (Maximal Consistent Sets)
2. **Durations (D)**: The temporal domain - must be constructed to have appropriate order structure (dense/discrete)

A **World History** is a function `h: D -> W` mapping durations to world states, subject to constraints.

**Key Finding**: The previous research (research-002) correctly identifies the blocker but **misses a crucial architectural point**. The algebraic parametric approach in `ParametricRepresentation.lean` treats D as a **parameter** (importing Rat), not as constructed from syntax. This violates the pure-syntax constraint for standard completeness.

**The Gap**: The `construct_bfmcs` function required by `parametric_algebraic_representation_conditional` is exactly what needs to be built - a function that takes an MCS and returns a temporally coherent BFMCS. The non-algebraic approach (`CanonicalConstruction.lean`) provides this for D=Int, but the dense case needs both:
1. D to emerge from syntax via Cantor isomorphism (the order structure)
2. Temporal coherence witnesses (forward_F, backward_P) that survive the construction

**Recommended Path**: The semantics architecture tells us that World Histories are the fundamental objects. We need to:
1. Construct W (world states) from MCS - **already done** (ParametricCanonicalWorldState)
2. Construct D (durations) from syntax - **partially done** (TimelineQuot has order properties)
3. Define World Histories respecting task_rel - **needs wiring**

The missing piece is connecting the CanonicalMCS temporal coherence (which has proven witnesses) to the TimelineQuot order structure (which has proven Cantor embedding).

---

## 1. The Semantics Architecture

### 1.1 TaskFrame: The Foundation

From `Theories/Bimodal/Semantics/TaskFrame.lean`:

```lean
structure TaskFrame (D : Type*) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] where
  /-- Type of world states -/
  WorldState : Type
  /-- Task relation: task_rel w x u means u is reachable from w by task of duration x -/
  task_rel : WorldState -> D -> WorldState -> Prop
  /-- Axioms: nullity_identity, forward_comp, converse -/
```

**Critical Insight**: The TaskFrame separates two concerns:
- **WorldState**: An arbitrary type (typically MCS in canonical models)
- **D**: A totally ordered abelian group providing temporal structure

The task_rel connects them: `task_rel w d u` means "from world state w, after duration d, we can reach world state u".

### 1.2 WorldHistory: Trajectories Through Time

From `Theories/Bimodal/Semantics/WorldHistory.lean`:

```lean
structure WorldHistory {D : Type*} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    (F : TaskFrame D) where
  /-- Domain predicate (which times are in the history) -/
  domain : D -> Prop
  /-- Convexity: no temporal gaps -/
  convex : forall (x z : D), domain x -> domain z -> forall (y : D), x <= y -> y <= z -> domain y
  /-- State assignment: for each time t in domain, assigns a world state -/
  states : (t : D) -> domain t -> F.WorldState
  /-- Task relation respect: for s <= t in domain, states connected by task_rel -/
  respects_task : forall (s t : D) (hs : domain s) (ht : domain t),
    s <= t -> F.task_rel (states s hs) (t - s) (states t ht)
```

**This is the crucial structure!** A WorldHistory is:
1. A convex subset of time D (the domain)
2. A function assigning world states to each time in the domain
3. Satisfying the task relation constraint

### 1.3 TaskModel and Truth Evaluation

From `Theories/Bimodal/Semantics/Truth.lean`:

```lean
def truth_at (M : TaskModel F) (Omega : Set (WorldHistory F))
    (tau : WorldHistory F) (t : D) : Formula -> Prop
  | Formula.atom p => exists (ht : tau.domain t), M.valuation (tau.states t ht) p
  | Formula.bot => False
  | Formula.imp phi psi => truth_at M Omega tau t phi -> truth_at M Omega tau t psi
  | Formula.box phi => forall (sigma : WorldHistory F), sigma in Omega -> truth_at M Omega sigma t phi
  | Formula.all_past phi => forall (s : D), s <= t -> truth_at M Omega tau s phi
  | Formula.all_future phi => forall (s : D), t <= s -> truth_at M Omega tau s phi
```

**Key Semantic Points**:
1. **Atoms**: Evaluated at the current world state (requires t in domain)
2. **Box**: Quantifies over ALL histories in Omega at the SAME time t
3. **Temporal operators**: Quantify over times in D (not restricted to domain)

This reveals the architecture:
- **Box (modal)**: varies the history, fixes the time
- **Past/Future (temporal)**: varies the time, fixes the history

### 1.4 The W-D Distinction

| Aspect | W (World States) | D (Durations) |
|--------|------------------|---------------|
| Type | `F.WorldState` | Type parameter |
| Structure | Unstructured set | Ordered abelian group |
| In canonical model | MCS | Int/Rat/constructed |
| Role in truth | Valuates atoms | Indexes temporal operators |
| Histories traverse | Space of W | Timeline D |

---

## 2. Non-Algebraic Representation Theorems

### 2.1 The CanonicalConstruction Approach

From `Theories/Bimodal/Metalogic/Bundle/CanonicalConstruction.lean`:

**World States**: `CanonicalWorldState := { M : Set Formula // SetMaximalConsistent M }`

**Duration Type**: D = Int (hardcoded)

**Task Relation**:
```lean
def canonical_task_rel (M : CanonicalWorldState) (d : Int) (N : CanonicalWorldState) : Prop :=
  if d > 0 then CanonicalR M.val N.val   -- Forward: g_content M <= N
  else if d < 0 then CanonicalR N.val M.val  -- Backward: converse
  else M = N  -- d = 0: identity
```

**History Conversion**: `to_history : FMCS Int -> WorldHistory CanonicalTaskFrame`
- domain = full (every integer)
- states t = the MCS at time t
- respects_task uses forward_G from FMCS

**Truth Lemma**: `canonical_truth_lemma` proves:
```
phi in fam.mcs t <-> truth_at CanonicalTaskModel (CanonicalOmega B) (to_history fam) t phi
```

**This works** because:
1. W is MCS (constructed from syntax)
2. D = Int (imported, NOT from syntax)
3. BFMCS provides modal saturation (forward/backward coherence)
4. Histories have full domain (simplifies proofs)

### 2.2 What the Non-Algebraic Approach Constructs

| Component | Construction | Source |
|-----------|--------------|--------|
| W (world states) | MCS via Lindenbaum | Syntax |
| D (durations) | Int | **Imported** |
| Histories | FMCS (indexed MCS families) | Syntax |
| Modal coherence | BFMCS (bundle of families) | Syntax |
| Temporal coherence | forward_G, backward_H | Syntax |

**The violation**: D is imported, not constructed from syntax.

---

## 3. Algebraic Representation Theorems

### 3.1 The Parametric Algebraic Approach

From `Theories/Bimodal/Metalogic/Algebraic/ParametricRepresentation.lean`:

**Key insight**: D is treated as a **parameter**:
```lean
variable {D : Type*} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
```

**The Conditional Representation Theorem**:
```lean
theorem parametric_algebraic_representation_conditional
    (phi : Formula) (h_not_prov : not Nonempty ([] |- phi))
    (construct_bfmcs : (M : Set Formula) -> SetMaximalConsistent M ->
      Sigma' (B : BFMCS D) (h_tc : B.temporally_coherent)
         (fam : FMCS D) (hfam : fam in B.families) (t : D),
         M = fam.mcs t) :
    exists (B : BFMCS D) (h_tc : ...) (fam : ...) ...,
      not (truth_at ParametricCanonicalTaskModel ... phi)
```

**What this says**: Given a function that constructs a temporally coherent BFMCS over D containing any MCS, non-provable formulas have countermodels.

### 3.2 The Dense Instantiation Gap

From `Theories/Bimodal/Metalogic/Algebraic/DenseInstantiation.lean`:

```lean
abbrev DenseCanonicalTaskFrame : TaskFrame Rat := ParametricCanonicalTaskFrame Rat
```

**The gap**: The file notes:
> "The full representation theorem for D = Rat requires constructing a temporally coherent BFMCS over Rat. This construction depends on: 1. The existence of F-witnesses (temporal forward coherence) 2. The existence of P-witnesses (temporal backward coherence)"

### 3.3 What the Algebraic Approach ASSUMES vs CONSTRUCTS

| Component | Status | Notes |
|-----------|--------|-------|
| W (world states) | Constructed | ParametricCanonicalWorldState = MCS |
| D (durations) | **ASSUMED** | Parameter (Rat imported) |
| task_rel | Constructed | Uses CanonicalR |
| FMCS over D | **NEEDS** | Requires `construct_bfmcs` |
| Temporal coherence | **NEEDS** | forward_F, backward_P |

---

## 4. The Architectural Gap Analysis

### 4.1 The Fundamental Problem

The semantics requires:
1. **W constructed from syntax** - DONE via MCS
2. **D constructed from syntax** - NOT DONE (D=Rat imported)
3. **Histories defined via task_rel** - DONE via parametric_to_history

The problem is NOT just temporal coherence witnesses. It is that **D itself must be constructed**.

### 4.2 What TimelineQuot Provides

From `Theories/Bimodal/Metalogic/StagedConstruction/`:

TimelineQuot provides:
- A countable dense linear order (no endpoints)
- Cantor isomorphism to Rat

TimelineQuot does NOT provide:
- Temporal coherence (forward_F, backward_P)
- A function `construct_bfmcs`

### 4.3 What CanonicalMCS Provides

CanonicalMCS (from CanonicalFrame.lean) provides:
- All MCS as world states
- Proven forward_F, backward_P via Lindenbaum
- Modal saturation

CanonicalMCS does NOT provide:
- Linear order (only preorder via CanonicalR)
- Embedding into Rat

### 4.4 The Synthesis Needed

The completeness proof needs to combine:
1. **Order structure from TimelineQuot**: D = TimelineQuot (which embeds into Rat)
2. **Witness structure from CanonicalMCS**: forward_F, backward_P work because ALL MCS are present

**The key insight**: These are NOT separate paths. They must be unified:
- Build World Histories over CanonicalMCS (which has witnesses)
- Quotient by CanonicalR-antisymmetrization to get linear order
- Apply Cantor to embed into Rat
- Transfer the World History structure

---

## 5. The Correct Path for Dense Algebraic Completeness

### 5.1 What the Semantics Architecture Demands

Given the semantics architecture (TaskFrame, WorldHistory, truth_at), the correct path is:

**Step 1**: Define W = CanonicalWorldState (MCS) - **DONE**

**Step 2**: Define D = CanonicalQuot = Antisymmetrization of CanonicalMCS
- This gives a linear order from the preorder
- Prove it is countable, dense, no endpoints

**Step 3**: Define task_rel over D
- Use the existing canonical_task_rel structure
- Verify it respects the quotient structure

**Step 4**: Define World Histories
- FMCS over CanonicalQuot
- Prove temporal coherence survives quotienting

**Step 5**: Apply Cantor isomorphism
- CanonicalQuot embeds into Rat
- Transfer World Histories to Rat

**Step 6**: Complete the truth lemma
- parametric_shifted_truth_lemma applied with the constructed BFMCS

### 5.2 Why CanonicalQuot Works

The crucial observation: Antisymmetrization does NOT lose witnesses.

If M and M' are in the same equivalence class (M <= M' and M' <= M via CanonicalR), then M.mcs = M'.mcs (proven in the codebase). So the MCS content is well-defined on equivalence classes.

This means:
- forward_F: F(phi) in [M] implies exists [W] with phi in [W] and CanonicalR [M] [W]
- The witness W may differ from canonical_forward_F's witness, but both are in the SAME equivalence class

### 5.3 The Missing Wiring

The current codebase has:
- TimelineQuot with order properties (separate construction)
- CanonicalMCS with witness properties (separate construction)

**Missing**: A single construction that has BOTH.

The solution is NOT to retrofit TimelineQuot with witnesses (as research-002 notes). The solution is to start from CanonicalMCS (which has witnesses) and quotient it to get the order.

---

## 6. ROAD_MAP.md Reflection

### 6.1 Pitfalls Checked

| Dead End | Relevance | Impact on Recommendations |
|----------|-----------|--------------------------|
| All Int/Rat Import Approaches | HIGH | Confirms D must emerge from syntax, not be imported as Rat |
| Single-Family BFMCS modal_backward | MEDIUM | Multi-family needed for modal coherence |
| Relational Completeness Detour | HIGH | Confirms we need D-construction, not relational completeness |

### 6.2 Strategy Alignment

| Strategy | Status | Relevance |
|----------|--------|-----------|
| D Construction from Canonical Timeline | ACTIVE | This IS the approach - Cantor iso from quotient |
| Representation-First Architecture | CONCLUDED | Provides foundation - representation before completeness |
| Reflexive G/H Semantics | ADOPTED | Current semantics uses reflexive (<=) |

### 6.3 Key Ambition

**Syntactically-Derived Duration Domain**:
> "The duration domain D is the algebraic backbone of task semantics... D-from-syntax is the PRIMARY path to sorry-free completeness."

The recommended path (CanonicalQuot -> Cantor -> Rat) achieves this ambition.

---

## 7. Concrete Recommendations

### 7.1 Immediate Next Steps

1. **Define CanonicalQuot**:
   ```lean
   def CanonicalQuot := Antisymmetrization CanonicalMCS (fun a b => CanonicalR a b)
   ```

2. **Prove order properties**:
   - LinearOrder (by Antisymmetrization construction)
   - Countable (formulas are countable)
   - DenselyOrdered (from DN axiom)
   - NoMinOrder, NoMaxOrder (from seriality)

3. **Build FMCS over CanonicalQuot**:
   - Transfer MCS assignment to equivalence classes
   - Prove forward_G, backward_H survive quotienting

4. **Prove forward_F, backward_P for CanonicalQuot FMCS**:
   - Use canonical_forward_F/backward_P
   - Key: witnesses are well-defined on equivalence classes

5. **Apply Cantor isomorphism**:
   - CanonicalQuot ~= Rat
   - Transfer FMCS to Rat

6. **Wire to dense_representation_conditional**:
   - Provide the `construct_bfmcs` function

### 7.2 Architectural Notes

The key architectural insight is that **World Histories are primary**. The truth evaluation happens at (history, time) pairs. To construct a canonical model:

1. Build the space of World Histories (from FMCS/BFMCS)
2. Build the TaskFrame (W, D, task_rel)
3. Verify histories respect task_rel
4. Prove the truth lemma

The algebraic approach (parametric in D) is the RIGHT abstraction. What's missing is the concrete instantiation for D = CanonicalQuot (or its Cantor image in Rat).

### 7.3 Risk Assessment

| Risk | Likelihood | Mitigation |
|------|------------|------------|
| Quotienting loses witnesses | LOW | `denseTimelineElem_mutual_le_implies_mcs_eq` proves MCS preserved |
| Order properties fail | LOW | DN, seriality axioms force correct structure |
| Cantor transfer is complex | MEDIUM | Mathlib provides isomorphism machinery |
| modal_backward issue | MEDIUM | May need multi-family BFMCS over CanonicalQuot |

---

## 8. Summary

**The Semantics Architecture**:
- TaskFrame: W (world states) + D (durations) + task_rel
- WorldHistory: trajectory through time, mapping D -> W
- Truth: evaluated at (history, time) pairs

**The Gap**:
- W is constructed (MCS) - DONE
- D is assumed (imported Rat) - VIOLATES pure-syntax constraint
- `construct_bfmcs` is unimplemented - the actual blocker

**The Path**:
1. CanonicalMCS has all witnesses (forward_F, backward_P proven)
2. Quotient by CanonicalR-antisymmetrization to get linear order
3. Prove order properties (countable, dense, no endpoints)
4. Apply Cantor: CanonicalQuot ~= Rat
5. Transfer FMCS/BFMCS to Rat
6. Wire to parametric representation theorem

**No Compromises**: This achieves D-from-syntax while preserving all witness properties.

---

## Context Extension Recommendations

### Discovered Concepts Requiring Documentation

| Concept | Report Section | Currently Documented? | Gap Type |
|---------|----------------|----------------------|----------|
| W-D architectural distinction | Section 1.4 | No | new_file |
| WorldHistory as primary object | Section 1.2 | Partial | extension |
| CanonicalQuot construction | Section 5.2 | No | new_file |

### New Context File Recommendations

| Filename | Directory | Content Scope | Priority | Create Task? |
|----------|-----------|---------------|----------|--------------|
| `semantics-architecture.md` | `domain/` | W-D distinction, WorldHistory structure, truth evaluation | High | Yes |
| `canonical-quotient-construction.md` | `processes/` | How to quotient CanonicalMCS to get linear order | High | Yes |

### Existing Context File Extensions

| File | Section to Add/Modify | Content to Add | Priority | Create Task? |
|------|----------------------|----------------|----------|--------------|
| `kripke-semantics-overview.md` | Add "TaskFrame vs Kripke Frame" | How TaskFrame generalizes Kripke semantics | Medium | No |

### Summary

- **New files needed**: 2
- **Extensions needed**: 1
- **Tasks to create**: 2
- **High priority gaps**: 2

---

## Decisions

1. **D must emerge from syntax**: Importing Rat violates the pure-syntax constraint
2. **CanonicalQuot is the right construction**: Quotient CanonicalMCS to get linear order while preserving witnesses
3. **World Histories are primary**: The semantics architecture centers on (history, time) pairs

---

## Risks & Mitigations

1. **modal_backward for singleton BFMCS fails**: Use multi-family construction
2. **Quotient structure is complex**: Mathlib Antisymmetrization provides the machinery
3. **Cantor transfer loses structure**: Cantor isomorphism preserves order AND can transfer functions

---

## References

1. `TaskFrame.lean` (lines 93-122) - TaskFrame structure definition
2. `WorldHistory.lean` (lines 69-97) - WorldHistory structure
3. `Truth.lean` (lines 113-120) - Truth evaluation
4. `CanonicalConstruction.lean` - Non-algebraic canonical model
5. `ParametricRepresentation.lean` - Algebraic representation theorem
6. `ParametricCanonical.lean` - D-parametric TaskFrame
7. research-002.md - Previous blocker analysis
8. ROAD_MAP.md Dead Ends - Documented failure modes
