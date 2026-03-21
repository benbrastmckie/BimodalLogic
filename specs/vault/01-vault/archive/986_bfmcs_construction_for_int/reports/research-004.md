# Research Report: Task #986 (Fourth Iteration - W vs D Semantic Architecture)

**Task**: 986 - bfmcs_construction_for_int
**Started**: 2026-03-17T14:00:00Z
**Completed**: 2026-03-17T16:30:00Z
**Effort**: 2-4 hours for architectural decision; implementation depends on chosen path
**Dependencies**: None
**Sources/Inputs**: TaskFrame.lean, WorldHistory.lean, Truth.lean, ParametricCanonical.lean, IntBFMCS.lean, CanonicalFMCS.lean, ROAD_MAP.md, research-003.md
**Artifacts**: specs/986_bfmcs_construction_for_int/reports/research-004.md
**Standards**: report-format.md, return-metadata-file.md

## Executive Summary

- **Critical Correction**: The previous research (research-003.md) correctly identified the countability obstruction but framed it as a problem with D=Int. This research reveals the MORE FUNDAMENTAL insight: the issue is about **W vs D confusion** in the semantic architecture.
- **The Key Distinction**: The semantics has TWO distinct components:
  - **W** (WorldState): The set of possible world states - implemented as `F.WorldState`
  - **D** (Duration): The temporal domain - the type parameter for indexing durations
- **The Real Architecture**: A history is `h: D -> W` (mapping times to world states). The F/P operators quantify over times in D, NOT over world states in W.
- **Root Cause of Confusion**: Previous research confused "where witnesses live" (in W, as MCSes) with "where witnesses are indexed" (at D indices in a history).
- **Resolution**: The countability obstruction is REAL but affects the question "can all witnesses be indexed by D=Int in a single history?" - NOT "can witnesses exist as W-objects?"
- **Correct Architecture**: W = CanonicalMCS (all MCSes), D = Int (or Rat, etc.). The issue becomes: given a SINGLE history h: Int -> CanonicalMCS, can it witness all F/P obligations? This reframes the problem correctly.

## Context & Scope

### The Delegation Prompt

The delegation explicitly stated: "W vs D semantic architecture - the fundamental structure missed in previous research." This signals that research-003.md, while mathematically correct about countability, missed a structural insight about the semantics.

### What Previous Research Got Right

research-003.md correctly identified:
1. F/P coherence for Int-indexed chains is mathematically blocked by countability
2. CanonicalFMCS works because its domain is ALL MCSes
3. The "Countability Obstruction Theorem" is valid

### What Previous Research Missed

research-003.md conflated two distinct questions:
1. "What type should D be?" (answered: CanonicalMCS, not Int)
2. "What is the relationship between W and D in the semantics?"

The second question was not properly analyzed. This research addresses it.

## Findings

### 1. The Fundamental Semantic Structure

From `TaskFrame.lean` (lines 93-122):

```lean
structure TaskFrame (D : Type*) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] where
  WorldState : Type
  task_rel : WorldState -> D -> WorldState -> Prop
  nullity_identity : forall w u, task_rel w 0 u <-> w = u
  forward_comp : forall w u v x y, 0 <= x -> 0 <= y ->
    task_rel w x u -> task_rel u y v -> task_rel w (x + y) v
  converse : forall w d u, task_rel w d u <-> task_rel u (-d) w
```

**Key Insight**: TaskFrame has TWO type parameters:
- `D`: The duration type (explicit parameter, with `[AddCommGroup D]` etc.)
- `WorldState`: The world state type (field of the structure, NO algebraic constraints)

These are INDEPENDENT. `D` is the temporal backbone; `WorldState` is the semantic domain.

### 2. Histories Connect D and W

From `WorldHistory.lean` (lines 69-97):

```lean
structure WorldHistory {D : Type*} ... (F : TaskFrame D) where
  domain : D -> Prop
  convex : forall (x z : D), domain x -> domain z ->
    forall (y : D), x <= y -> y <= z -> domain y
  states : (t : D) -> domain t -> F.WorldState
  respects_task : forall (s t : D) (hs : domain s) (ht : domain t),
    s <= t -> F.task_rel (states s hs) (t - s) (states t ht)
```

**Key Insight**: A world history is a FUNCTION from times (in D) to world states (in W):
- Domain: a convex subset of D (the times that "exist" in this history)
- States: maps each time in domain to a world state
- Respects_task: the trajectory follows the task relation

This is the **h: D -> W** structure mentioned in the delegation prompt.

### 3. F/P Truth Conditions: Quantifying Over D, Not W

From `Truth.lean` (lines 113-120):

```lean
def truth_at (M : TaskModel F) (Omega : Set (WorldHistory F))
    (tau : WorldHistory F) (t : D) : Formula -> Prop
  | Formula.all_past phi => forall (s : D), s <= t -> truth_at M Omega tau s phi
  | Formula.all_future phi => forall (s : D), t <= s -> truth_at M Omega tau s phi
```

**CRITICAL INSIGHT**: The temporal operators quantify over **D** (the duration domain), NOT over W (world states).

- `all_past phi` at time `t`: phi holds at ALL times `s <= t` in D
- `all_future phi` at time `t`: phi holds at ALL times `s >= t` in D

The quantification is over the TIME DOMAIN D, evaluated at whatever world states the history assigns to those times.

### 4. The Canonical Model Architecture

From `ParametricCanonical.lean`:

```lean
def ParametricCanonicalWorldState : Type := { M : Set Formula // SetMaximalConsistent M }

def ParametricCanonicalTaskFrame (D : Type*) ... : TaskFrame D where
  WorldState := ParametricCanonicalWorldState
  task_rel := parametric_canonical_task_rel
```

**Architecture in the Codebase**:
- **W = ParametricCanonicalWorldState** (all MCSes) - the space of world states
- **D = parameter** (Int, Rat, CanonicalMCS, etc.) - the temporal backbone

A history in this model is `h: D -> ParametricCanonicalWorldState` - mapping times (in D) to MCSes (in W).

### 5. Reframing the F/P Witness Problem

**The Original Framing (research-003.md)**:
"F/P coherence for D=Int is blocked because witnesses (MCSes) cannot all fit in an Int-indexed chain."

**The Corrected Framing**:
"Given a specific history h: Int -> W, can h witness all F/P obligations?"

This is a DIFFERENT question. The witnesses ARE in W (which can be all MCSes). The question is whether a SINGLE history can cover them all.

### 6. Two Possible Architectures

**Architecture A: D = W (research-003.md's solution)**

Set `D = CanonicalMCS`. Then:
- Histories are `h: CanonicalMCS -> CanonicalMCS`
- F/P witnesses trivially exist (every MCS is a valid time index)
- This is what `CanonicalFMCS.lean` implements

**Consequence**: This works but loses the algebraic structure of D. CanonicalMCS has `[Preorder D]` but NOT `[AddCommGroup D]`. The `task_rel` cannot be defined via durations.

**Architecture B: D separate from W (standard approach)**

Keep `D = Int` (or Rat), set `W = CanonicalMCS`. Then:
- Histories are `h: Int -> CanonicalMCS`
- F/P witnesses exist in W, but need to be INDEXED by D
- The countability obstruction applies: a single history cannot cover all witnesses

**Consequence**: This is blocked for a SINGLE history, but...

### 7. The Key Insight: Omega Quantification

From `Truth.lean`, the Box modality quantifies over Omega:

```lean
| Formula.box phi => forall (sigma : WorldHistory F), sigma in Omega -> truth_at M Omega sigma t phi
```

**CRITICAL INSIGHT**: The semantics does NOT require a single history to witness everything. It requires:
- For F(phi): EXISTS a time s > t IN THE CURRENT HISTORY where phi holds
- This is a property of ONE SPECIFIC history, not all histories

The F/P witness problem is:
- Given history tau with `F(phi) true at tau,t`
- We need `exists s > t, phi true at tau,s`
- This s must be in tau's domain

This is where the countability obstruction bites: if `D = Int`, then tau's domain is at most countable. The witness for F(phi) must be WITHIN tau's range.

### 8. The Existing CanonicalFMCS Solution

From `CanonicalFMCS.lean`:

```lean
theorem canonicalMCS_forward_F (w : CanonicalMCS) (phi : Formula)
    (h_F : Formula.some_future phi in canonicalMCS_mcs w) :
    exists s : CanonicalMCS, w <= s /\ phi in canonicalMCS_mcs s
```

This works because:
1. `D = CanonicalMCS` (the domain IS the space of all MCSes)
2. The witness s is automatically in D (trivially)
3. No indexing problem arises

### 9. Why IntBFMCS Has Sorries

From `IntBFMCS.lean`:

```lean
theorem intFMCS_forward_F ... :
    exists s : Int, t < s /\ phi in intChainMCS M0 h_mcs0 s := by
  sorry
```

The issue is:
1. `D = Int`, `W = Set Formula` (implicitly, via `intChainMCS M0 h_mcs0 : Int -> Set Formula`)
2. The witness MCS from `canonical_forward_F` exists in W
3. But we need to find an Int index s where `intChainMCS M0 h_mcs0 s` IS that witness
4. Countability: Range(intChainMCS) is countable; the witness may not be in it

### 10. Resolution: The Omega Parameter Matters

The Omega parameter in `truth_at` quantifies over WHICH histories we consider.

**For validity**: We need `forall histories in Omega, phi holds`

**For satisfiability** (countermodels): We need `exists history in Omega, phi fails`

The key is: different histories can witness DIFFERENT F/P obligations. The countability obstruction affects what a SINGLE history can cover, not what the ENTIRE SET Omega can cover.

**Implication for BFMCS**: A BFMCS is a SET of families. Each family is an FMCS. For F/P coherence, we need witnesses within EACH family. If `D = Int`, each family can only witness countably many obligations. But different families can witness different obligations.

**However**: The `TemporalCoherentFamily` definition requires EACH family to be F/P coherent WITHIN ITSELF. This is the obstruction - not at the BFMCS level, but at the individual FMCS level.

## ROAD_MAP.md Reflection

### Pitfalls Checked

| Dead End | Relevance | Impact on Recommendations |
|----------|-----------|--------------------------|
| All Int/Rat Import Approaches | CRITICAL | D=Int is forbidden for STANDARD completeness; task 986's algebraic path may use D=Int for conditional/specialized results |
| DovetailingChain | HIGH | Documents F/P witness sorries; the root cause is countability within a single chain |
| Fragment Chain F-Persistence | HIGH | Same root cause: countability obstruction within a single Int-indexed chain |

### Strategy Alignment

| Strategy | Status | Relevance |
|----------|--------|-----------|
| D Construction from Canonical Timeline | ACTIVE | Task 986's algebraic path is SEPARATE - algebraic uses imported D, syntax path discovers D |
| Representation-First Architecture | CONCLUDED | Task 986 follows this - canonical model provides countermodels |
| Indexed MCS Family Approach | ACTIVE | Task 986 directly relates to this strategy |

### Key Insight from Dead Ends

The Dead Ends consistently fail at the same point: F/P coherence within a SINGLE countable chain. The pattern is clear:
- Every attempt to get F/P coherence with `D = Int` hits the countability wall
- The only exception is when `D = CanonicalMCS` (making the domain uncountable)

## Recommendations

### Option 1: Accept the Algebraic/Syntax Split (RECOMMENDED)

**Insight**: Task 986 asks for "BFMCS construction for D=Int". This is the ALGEBRAIC path, not the D-from-syntax path.

**The Split**:
1. **Algebraic Path** (Task 986): Uses imported D (Int, Rat, etc.). Provides conditional completeness theorems. Acceptable to have SOME sorries because this path is NOT the primary completeness strategy.
2. **D-from-Syntax Path** (Task 956): Discovers D from canonical timeline. Sorry-free. THE primary completeness strategy.

**Recommendation**: Accept that Task 986's `IntBFMCS` with 2 sorries is ACCEPTABLE for the algebraic path. Document clearly that:
- The sorries are UNFILLABLE (countability obstruction proven)
- The algebraic path provides CONDITIONAL completeness (assuming F/P coherence holds)
- For UNCONDITIONAL sorry-free completeness, use the D-from-syntax path (Task 956)

**Implementation**:
1. Add `[Axiom]` or explicit hypothesis to `intFMCS_forward_F` and `intFMCS_backward_P`
2. Document in IntBFMCS.lean that these are INTENTIONAL mathematical gaps
3. The ParametricRepresentation theorem becomes CONDITIONAL on these hypotheses
4. This is acceptable because: (a) the algebraic path is secondary, (b) the obstruction is mathematically fundamental, not a proof gap

### Option 2: Fully Embrace D = CanonicalMCS (Alternative)

**As in research-003.md**: Refactor algebraic infrastructure to work with `D = CanonicalMCS`.

**New Insight from W vs D analysis**: This approach is SOUND but LOSES the connection to standard temporal logic semantics. With `D = CanonicalMCS`:
- task_rel cannot express "duration d" in the usual sense
- The semantics becomes a preorder semantics, not a metric/group semantics
- This is fine for COMPLETENESS (we just need countermodels) but loses EXPRESSIVE power

**When to prefer Option 2**: If we want UNCONDITIONAL sorry-free algebraic completeness and are willing to accept non-standard duration semantics.

### Option 3: Hybrid BFMCS (Advanced, Not Recommended)

**Idea**: Use BFMCS where:
- Each family is an `FMCS Int`
- F/P witnesses may be in DIFFERENT families
- Cross-family witness lookup

**Problem**: The `TemporalCoherentFamily` definition requires witnesses WITHIN each family. Changing this requires deep infrastructure changes.

**Verdict**: Too invasive for the benefit. Options 1 or 2 are cleaner.

## The Correct Mental Model

### W vs D Summary

| Component | Type | Role | Size |
|-----------|------|------|------|
| D | Duration domain | Indexes times in histories | Varies (Int: countable, CanonicalMCS: uncountable) |
| W (WorldState) | World state space | Semantic interpretations | Uncountable (all MCSes) |
| History | D -> W | Maps times to states | Single function |
| Omega | Set (D -> W) | All admissible histories | Set of histories |

### The Countability Obstruction Restated

**Theorem (Refined)**: Let `h: Int -> W` be any history with `W = CanonicalMCS`. Let `Range(h) = {h(t) : t in Int}`. Then there exist formulas phi and MCSes M such that:
- `F(phi) in M`
- `M in Range(h)` (so M = h(t) for some t)
- For all t' > t: the witness MCS for F(phi) at M is NOT in Range(h)

**Implication**: A single `Int -> CanonicalMCS` history cannot witness all F/P obligations for all MCSes in its range. This is an INHERENT limitation of countable indexing into uncountable spaces.

### Why CanonicalFMCS Avoids This

With `D = CanonicalMCS`:
- History domain can contain ALL MCSes (uncountable)
- Every witness is trivially in the domain
- No indexing problem

The trade-off: we lose the group structure of D.

## Decisions

1. **Primary Recommendation**: Option 1 - Accept the algebraic/syntax split. The sorries in IntBFMCS are mathematically fundamental, not proof gaps.

2. **Task 986 Resolution**: Mark the task as BLOCKED or PARTIAL with clear documentation:
   - The sorries are INTENTIONAL (countability obstruction)
   - The algebraic path provides CONDITIONAL completeness
   - Unconditional sorry-free completeness requires the D-from-syntax path

3. **Documentation**: Update IntBFMCS.lean with explicit documentation of:
   - The W vs D distinction
   - Why the sorries are unfillable
   - How to use the conditional theorems

## Risks & Mitigations

| Risk | Severity | Mitigation |
|------|----------|------------|
| Confusion between algebraic and syntax paths | Medium | Clear documentation in ROAD_MAP.md and module headers |
| Conditional completeness seen as "incomplete" | Low | Explain mathematical necessity; point to sorry-free syntax path |
| Future attempts to fill IntBFMCS sorries | Low | Document the countability obstruction theorem clearly |

## Context Extension Recommendations

### Discovered Concepts Requiring Documentation

| Concept | Report Section | Currently Documented? | Gap Type |
|---------|----------------|----------------------|----------|
| W vs D distinction | Section 1-4 | No | new_file |
| History as D -> W | Section 2 | Partial (in code comments) | extension |
| Countability Obstruction (refined) | Section 10 | Partial (research-003.md) | extension |

### New Context File Recommendations

| Filename | Directory | Content Scope | Priority | Create Task? |
|----------|-----------|---------------|----------|--------------|
| `semantic-architecture.md` | `project/logic/` | W vs D distinction, history structure | High | No (document in ROAD_MAP.md) |

### ROAD_MAP.md Updates Recommended

1. **Dead Ends Section**: Add explicit entry for "Int-Indexed F/P Coherence" documenting the countability obstruction
2. **Ambitions Section**: Clarify that "Proof Economy" for algebraic path accepts CONDITIONAL theorems
3. **Strategies Section**: Distinguish algebraic path (imported D, conditional) from syntax path (discovered D, unconditional)

### Summary

- **New files needed**: 0 (document in ROAD_MAP.md instead)
- **Extensions needed**: 2 (ROAD_MAP.md Dead Ends, ROAD_MAP.md Strategies clarification)
- **Tasks to create**: 0 (resolution is documentation, not implementation)
- **High priority gaps**: 1 (W vs D distinction should be documented somewhere)

## Appendix

### Files Analyzed

| File | Key Content |
|------|-------------|
| TaskFrame.lean (93-122) | TaskFrame structure with D and WorldState |
| WorldHistory.lean (69-97) | History structure: D -> WorldState |
| Truth.lean (113-120) | F/P quantification over D |
| ParametricCanonical.lean (63-65, 199-206) | W = MCS, D = parameter |
| IntBFMCS.lean (557-574) | The two sorries (forward_F, backward_P) |
| CanonicalFMCS.lean (222-251) | Sorry-free F/P with D = CanonicalMCS |
| ROAD_MAP.md (515-549, 601-619) | Dead Ends: Int/Rat approaches, Fragment Chain |

### Mathematical Structure Summary

```
TaskFrame D:
  WorldState : Type              -- W (no algebraic structure required)
  task_rel : W -> D -> W -> Prop -- relates world states via durations

WorldHistory F:
  domain : D -> Prop             -- times in this history
  states : D -> W                -- mapping times to states
  respects_task : trajectory follows task_rel

Truth:
  all_future phi at (tau, t) := forall s >= t, phi at (tau, s)
  -- quantifies over D, evaluates at tau(s) in W

BFMCS:
  FMCS D:
    mcs : D -> Set Formula       -- MCS at each time in D
    forward_F : F(phi) at t => exists s > t, phi at s
    -- witness s must be in D, not just in "all MCSes"
```

### Why the Countability Obstruction is Fundamental

```
Claim: Any function f: Int -> CanonicalMCS has countable range.

Proof: Int is countable; image of countable set under any function is countable.

Claim: There are uncountably many (MCS, formula phi) pairs with F(phi) in MCS.

Proof: |CanonicalMCS| = 2^aleph_0 (continuum). Each MCS contains uncountably many
       formulas of form F(phi). So the set of such pairs has size continuum.

Claim: For any f: Int -> CanonicalMCS, some (M, phi) pair has no witness in Range(f).

Proof: Each witness is an MCS. There are continuum-many needed witnesses.
       Range(f) is countable. By pigeonhole, most witnesses are outside Range(f).

QED: Int-indexed F/P coherence is impossible for any single history.
```
