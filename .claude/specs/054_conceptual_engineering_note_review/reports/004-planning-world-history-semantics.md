# Research Report: Planning Semantics and World-History Truth Conditions

**Report ID**: 004
**Topic**: Planning Semantics and World-History Truth Conditions
**Complexity**: 3
**Date**: 2025-12-09
**Context File**: `/home/benjamin/Documents/Philosophy/Projects/ProofChecker/Documentation/Research/CONCEPTUAL_ENGINEERING.md`

## Executive Summary

This research analyzes the semantics explanation for world-histories in planning contexts within the CONCEPTUAL_ENGINEERING.md document. The current explanation contains conceptual confusion between:
1. **Plans as world-histories** (semantic objects representing complete temporal evolutions)
2. **Plans as partial specifications** (pragmatic objects constraining but not fully determining temporal evolution)

This conflation obscures how tense operators quantify over times within a world-history and how the task relation constrains accessible world-histories. The Core Layer approximates partial plans via **sets of complete world-histories**, but this approximation isn't clearly explained, making the relationship between planning pragmatics and semantic foundations unclear.

## Key Issues Identified

### Issue 1: Confusion Between Complete and Partial World-Histories

**Location**: Lines 99-120, 172-186 in CONCEPTUAL_ENGINEERING.md

**Problem**: The document says "plans are classes of complete world-histories" (line 110) but then states "real plans specify only partial world-histories" (line 175). This creates conceptual tension:

- **Semantic Foundation**: World-histories are mathematically defined as **total functions** `w: T → S` (per WorldHistory.lean lines 86-97)
- **Planning Reality**: Practical plans specify only **partial constraints** on temporal evolution
- **Conflation**: Treating "partial plan specification" as if it were "partial world-history" conflates epistemic partiality (what the plan specifies) with semantic totality (what a world-history is)

**Current Text** (lines 175-181):
> A **partial world-history** specifies world-states for some times but leaves others indeterminate. For example, a plan to "launch product by Q4 2026" specifies:
> - **Specified**: Initial state (current product development status), target state (product launched by end of Q4 2026)
> - **Unspecified**: Intermediate states (exact development milestones, marketing strategies, resource allocation decisions)

**Issue**: This describes a **plan specification**, not a world-history. In the formal semantics (WorldHistory.lean), world-histories are complete functions with no "unspecified" times within their convex domain.

### Issue 2: Unclear Core Layer Approximation Strategy

**Location**: Lines 182-189

**Problem**: The explanation of how Core Layer approximates partial plans is terse and doesn't explain the semantic consequences:

**Current Text** (lines 182-186):
> **Approximating partiality via sets of complete world-histories**: The Core Layer approximates partial world-histories by representing a plan as a **set of complete world-histories** agreeing on the specified aspects.

**Missing Clarifications**:
1. How does quantification over sets of world-histories work semantically?
2. What does "agreeing on specified aspects" mean formally?
3. How do tense operators evaluate over such sets?
4. Why is this approximation adequate for Core Layer temporal reasoning but inadequate for Layer 1 counterfactuals?

### Issue 3: Tense Operator Truth Conditions Need Explicit Connection to Planning

**Location**: Lines 114-120

**Current Text** (lines 114-120):
> **Tense operators evaluated over world-histories**:
> - `Gφ` is true at `(w,t)` iff `φ` is true at `(w,t')` for all `t' > t` in `w`'s temporal domain
> - `Fφ` is true at `(w,t)` iff `φ` is true at `(w,t')` for some `t' > t` in `w`'s temporal domain
> [...]

**Missing Context**: This correctly states the truth conditions but doesn't explain how this relates to planning:
- How does quantifying over times **within a single world-history** represent "possible futures" in planning?
- How does the modal operator `◇` introduce **alternative** world-histories for plan comparison?
- Why do we need **both** tense (intra-world temporal quantification) and modal (inter-world alternative quantification) operators for planning?

### Issue 4: Task Relation Constraint Not Connected to Planning

**Location**: Line 112

**Current Text** (line 112):
> The task relation constrains which world-histories are accessible from a given world-state-time triple.

**Issue**: This is technically correct but doesn't explain the planning interpretation:
- What does "accessible world-histories" mean for planning? (Physically/causally achievable plan executions)
- How does the task relation model causal constraints on action sequences?
- Why does the task relation have compositionality and nullity properties? (Composing sequential tasks, identity task)

## Concrete Recommendations

### Recommendation 1: Clarify Semantic vs Pragmatic Levels

**Target Section**: Lines 99-120 ("World-Histories and Temporal Evolution")

**Recommended Revision Structure**:

```markdown
### World-Histories and Temporal Evolution

The semantic foundation for planning requires distinguishing two levels:

**Semantic Level (World-Histories)**: In the formal semantics (TaskFrame.lean, WorldHistory.lean),
a world-history is a **complete function** `w: T → S` where:
- `T` is a convex subset of times (no temporal gaps)
- `S` is a set of world-states
- `w(t)` determinately specifies the world-state at every time `t ∈ T`
- `w` respects the task relation: for all `s ≤ t` in `T`, `F.task_rel (w(s)) (t-s) (w(t))`

This completeness is essential for recursive truth evaluation: to evaluate `Gφ` at `(w,t)`,
we must check `φ` at all `t' > t` in `w`'s domain, which requires `w` to specify states at all such times.

**Pragmatic Level (Plan Specifications)**: Real-world plans do not specify complete world-histories.
A plan like "launch product by Q4 2026" provides only **partial constraints**:
- Initial state: current development status
- Target condition: product launched by end of Q4 2026
- Unspecified: intermediate milestones, resource allocations, specific implementation details

**Core Layer Approximation**: The Core Layer bridges these levels by representing a plan specification
as a **set of complete world-histories** that satisfy the plan's constraints. The plan "launch product
by Q4 2026" corresponds to:

```
Plan = {w : WorldHistory F |
  w(t_now) matches current state ∧
  w(t) satisfies "product launched" for t ∈ Q4_2026}
```

This set contains all physically possible complete temporal evolutions satisfying the plan's constraints.
```

**Rationale**: This revision clearly separates formal semantics (complete world-histories) from pragmatic planning (partial specifications) and explains how the set-based approximation bridges them.

### Recommendation 2: Add Explicit "Truth Conditions for Planning" Subsection

**Insertion Point**: After line 120, before "Expected Value via Counterfactual Comparison"

**Recommended New Subsection**:

```markdown
### Truth Conditions for Tense Operators in Planning Contexts

Tense operators quantify over times **within a single world-history**, enabling representation
of temporal evolution under a specific plan:

**Intra-World Temporal Quantification**:
- `Gφ` (always in the future): `φ` holds at **all** future times in the current world-history
  - **Planning Interpretation**: Under this plan, `φ` will hold throughout the future
  - **Truth Condition**: `truth_at M w t φ.all_future` iff `∀ t' > t, t' ∈ w.domain → truth_at M w t' φ`

- `Fφ` (sometime in the future): `φ` holds at **some** future time in the current world-history
  - **Planning Interpretation**: Under this plan, `φ` will eventually occur
  - **Truth Condition**: `truth_at M w t φ.all_future.not` iff `∃ t' > t, t' ∈ w.domain ∧ truth_at M w t' φ`

- `Hφ` (always in the past): `φ` held at **all** past times in the current world-history
  - **Planning Interpretation**: Looking back from now, `φ` has consistently held
  - **Truth Condition**: `truth_at M w t φ.all_past` iff `∀ t' < t, t' ∈ w.domain → truth_at M w t' φ`

- `Pφ` (sometime in the past): `φ` held at **some** past time in the current world-history
  - **Planning Interpretation**: Looking back from now, `φ` occurred at least once
  - **Truth Condition**: `truth_at M w t φ.all_past.not` iff `∃ t' < t, t' ∈ w.domain ∧ truth_at M w t' φ`

**Key Semantic Property**: Tense operators do not introduce alternative worlds—they quantify
over times in the **same** world-history. This represents temporal evolution under a **fixed** plan execution.

**Inter-World Plan Comparison via Modal Operators**:

To compare alternative plans, we need modal operators quantifying over **different world-histories**:

- `◇Gφ` (possibly, always φ): There exists a plan where `φ` holds throughout the future
  - **Modal quantification**: There exists world-history `w'` accessible from current state
  - **Temporal quantification**: In `w'`, `φ` holds at all future times
  - **Truth Condition**: `∃ w' : WorldHistory F, w'.domain t ∧ (∀ t' > t, w'.domain t' → truth_at M w' t' φ)`

- `□Fφ` (necessarily, sometime φ): Under all possible plans, `φ` will eventually occur
  - **Modal quantification**: For all world-histories `w'` accessible from current state
  - **Temporal quantification**: In each `w'`, `φ` holds at some future time
  - **Truth Condition**: `∀ w' : WorldHistory F, w'.domain t → (∃ t' > t, w'.domain t' ∧ truth_at M w' t' φ)`

**Why Both Are Essential**: Planning requires comparing temporal evolutions (tense) across
alternative scenarios (modal). Pure temporal logic cannot represent alternative plans; pure modal
logic cannot represent temporal evolution within plans. The TM bimodal logic provides both dimensions.
```

**Rationale**: This subsection provides concrete truth conditions with explicit planning interpretations, showing how tense and modal operators work together for plan comparison.

### Recommendation 3: Clarify Task Relation as Causal Constraint

**Target Section**: Lines 108-112

**Recommended Revision**:

```markdown
The **task relation** `F.task_rel : WorldState → T → WorldState → Prop` constrains which
world-histories are accessible from a given world-state-time triple, modeling **physical and causal
constraints** on plan execution.

**Formal Constraint**: A world-history `w` is accessible from state `s` at time `t` only if `w`
respects the task relation: for all times `t₁ ≤ t₂` in `w`'s domain,
```
F.task_rel (w(t₁)) (t₂ - t₁) (w(t₂))
```

**Planning Interpretation**: This constraint ensures that only **physically achievable** temporal
evolutions are considered. If transitioning from state `s₁` to state `s₂` in duration `Δ` is
physically impossible (task relation does not hold), then no accessible world-history can have
`w(t) = s₁` and `w(t + Δ) = s₂`.

**Task Relation Properties**:

1. **Nullity** (`∀ w, task_rel w 0 w`): Every state can transition to itself in zero time
   - **Planning Interpretation**: The "identity task" (do nothing) is always achievable

2. **Compositionality** (`task_rel w x u ∧ task_rel u y v → task_rel w (x+y) v`):
   If state `w` can reach state `u` in time `x`, and `u` can reach `v` in time `y`,
   then `w` can reach `v` in time `x+y`
   - **Planning Interpretation**: Sequential task composition—executing Task₁ then Task₂
     achieves the combined effect in combined duration

**Why This Matters for Planning**: The task relation ensures modal operators `◇` and `□` quantify
over **achievable** plans, not arbitrary mathematical world-histories. When evaluating `◇Gφ`
("there exists an achievable plan where `φ` always holds"), the existential quantification is
restricted to world-histories satisfying the task relation from the current state.
```

**Rationale**: This revision explains the task relation's planning interpretation and why its mathematical properties (nullity, compositionality) correspond to natural properties of task execution.

### Recommendation 4: Expand "Partial vs Complete World-Histories" Section

**Target Section**: Lines 172-200 (entire subsection)

**Recommended Revision Structure**:

```markdown
### Partial Plan Specifications vs Complete World-Histories

**Conceptual Distinction**: We must carefully distinguish two concepts that are easily confused:

1. **Complete World-History (Semantic)**: A total function `w: T → S` specifying the world-state
   at every time in a convex temporal domain. This is the fundamental semantic object used in
   truth evaluation (see WorldHistory.lean lines 69-97).

2. **Partial Plan Specification (Pragmatic)**: A set of constraints on world-states at some times,
   leaving other times and state features unspecified. This is what human planners actually create.

**Example**: Consider a plan to "launch product by Q4 2026":

**As Partial Plan Specification** (pragmatic level):
- Constraint at `t_now`: `product_status = "development"`
- Constraint for `t ∈ Q4_2026`: `product_status = "launched"`
- **Unspecified**: Exact development milestones, marketing strategies, resource allocations,
  team compositions, market conditions at intermediate times

**As Set of Complete World-Histories** (semantic level):
```
Plan = {w : WorldHistory F |
  w(t_now) satisfies "product_status = development" ∧
  (∀ t ∈ Q4_2026, w(t) satisfies "product_status = launched")}
```

Each `w ∈ Plan` is a **complete** world-history specifying states at all times in its domain.
The set contains all complete temporal evolutions compatible with the plan's constraints.

**Why Core Layer Uses Complete World-Histories**:

The recursive truth evaluation for tense operators **requires** complete world-histories:

```lean
-- From Truth.lean lines 110-111
| Formula.all_future φ =>
    ∀ (s : T) (hs : τ.domain s), t < s → truth_at M τ s hs φ
```

To evaluate `Gφ` ("always in the future φ") at world-history `τ` and time `t`, we must:
1. Identify all times `s > t` in `τ`'s domain
2. Evaluate `φ` at each such time-state pair `(τ(s), s)`
3. Check that `φ` holds at **all** such pairs

This quantification is only well-defined if `τ` specifies states for all times in its domain.
A "partial world-history" with "unspecified" times would make this evaluation undefined.

**Core Layer Approximation Strategy**:

The Core Layer approximates partial plan specifications using **sets of complete world-histories**:

**Representation**:
```
Partial_Plan_Spec ⟿ {w : WorldHistory F | w satisfies all specified constraints}
```

**Evaluation of Planning Claims**:
- "Under this plan, φ always holds": `∀ w ∈ Plan, truth_at M w t (Gφ)`
- "Under this plan, φ eventually occurs": `∀ w ∈ Plan, truth_at M w t (Fφ)`
- "There exists a way to execute this plan where φ holds": `∃ w ∈ Plan, truth_at M w t φ`

**Adequacy for Core Layer**: This approximation works well for temporal and modal reasoning
because tense and modal operators naturally quantify over sets:
- Tense operators: quantify over times within each world-history in the set
- Modal operators: quantify over alternative world-histories (the set members)

**Inadequacy for Layer 1 Counterfactuals**: The set-based approximation breaks down when evaluating
counterfactuals like "If we had allocated more resources to marketing, the launch would have succeeded."
The problem: which aspects of the plan should be held fixed (ceteris paribus) and which should vary
under the counterfactual supposition?

The set `{w | w satisfies plan constraints}` provides no way to distinguish:
- Plan-relevant features (should vary under counterfactual)
- Plan-independent features (should be held fixed under counterfactual)

This motivates Layer 1's **mereological structure** over world-states, enabling explicit representation
of which state features are specified by the plan versus unspecified (see lines 201-214 for details).
```

**Rationale**: This expanded explanation clarifies why complete world-histories are semantically necessary, how the set-based approximation works, and precisely where it breaks down (motivating Layer 1).

## Implementation Impact

### No Changes Required to LEAN Code

The current LEAN implementation in `WorldHistory.lean` and `Truth.lean` is **correct as-is**:
- World-histories are properly defined as complete functions (WorldHistory.lean lines 69-97)
- Truth evaluation correctly quantifies over domain-restricted times (Truth.lean lines 104-111)
- Task relation constraints are properly enforced (WorldHistory.lean lines 95-97)

### Documentation-Only Changes

All recommendations involve **documentation improvements** in CONCEPTUAL_ENGINEERING.md:
1. Clarifying the semantic vs pragmatic levels of analysis
2. Adding explicit truth condition explanations with planning interpretations
3. Expanding the explanation of how Core Layer approximates partial plans
4. Connecting formal properties (task relation, convexity) to planning concepts

## Alignment with Existing Documentation

### Architecture Guide Alignment

The ARCHITECTURE.md document (lines 411-424) correctly defines world-histories as complete functions:

```lean
structure WorldHistory {T : Type*} [LinearOrderedAddCommGroup T] (F : TaskFrame T) where
  domain : T → Prop
  convex : ∀ x z, domain x → domain z → ∀ y, x ≤ y → y ≤ z → domain y
  states : (t : T) → domain t → F.WorldState
  respects_task : ∀ s t (hs : domain s) (ht : domain t),
    s ≤ t → F.task_rel (states s hs) (t - s) (states t ht)
```

The recommended revisions to CONCEPTUAL_ENGINEERING.md would bring it into alignment with this correct formal specification.

### Truth.lean Alignment

The Truth.lean implementation (lines 104-111) correctly implements domain-restricted temporal quantification:

```lean
def truth_at (M : TaskModel F) (τ : WorldHistory F) (t : T) (ht : τ.domain t) :
    Formula → Prop
  | Formula.all_past φ => ∀ (s : T) (hs : τ.domain s), s < t → truth_at M τ s hs φ
  | Formula.all_future φ => ∀ (s : T) (hs : τ.domain s), t < s → truth_at M τ s hs φ
```

The recommended "Truth Conditions for Planning" subsection would make this formal semantics accessible to readers from a planning perspective.

## Priority and Scope

### Priority: Medium-High

These clarifications are important for:
1. **Readers understanding the planning motivation** for TM bimodal logic
2. **Future Layer 1 implementers** understanding why mereological structure is needed
3. **Philosophical coherence** of the conceptual engineering methodology

However, they don't affect current Core Layer implementation or correctness.

### Scope: Documentation Review and Revision

**Estimated Effort**: 2-4 hours for careful revision integrating all recommendations

**Files to Modify**:
- `Documentation/Research/CONCEPTUAL_ENGINEERING.md` (primary target)
- Potentially `Documentation/UserGuide/ARCHITECTURE.md` (add cross-references to planning interpretation)

**Review Checkpoints**:
1. Verify revised text maintains philosophical rigor
2. Check that planning examples are realistic and illustrative
3. Ensure formal semantics references (WorldHistory.lean, Truth.lean) are accurate
4. Confirm Layer 1 motivation (mereological structure) follows clearly from Core Layer limitations

## Conclusion

The current CONCEPTUAL_ENGINEERING.md contains valuable philosophical framing but conflates partial plan specifications (pragmatic objects) with complete world-histories (semantic objects). This conflation obscures how truth conditions for tense operators work in planning contexts and why the Core Layer's set-based approximation is adequate for temporal-modal reasoning but inadequate for counterfactual reasoning.

The recommendations above provide concrete text revisions that:
1. Clearly distinguish semantic completeness from pragmatic partiality
2. Explain truth conditions for tense operators with explicit planning interpretations
3. Clarify how the task relation models causal constraints on achievable plans
4. Expand the explanation of Core Layer approximation and its limitations

These revisions would significantly improve philosophical clarity and accessibility for readers approaching Logos from a planning AI perspective, while maintaining full alignment with the correct formal semantics implemented in the LEAN codebase.

## References

- **Context Document**: `/home/benjamin/Documents/Philosophy/Projects/ProofChecker/Documentation/Research/CONCEPTUAL_ENGINEERING.md`
- **LEAN Implementation**:
  - `Logos/Core/Semantics/WorldHistory.lean` (world-history structure)
  - `Logos/Core/Semantics/Truth.lean` (truth evaluation)
  - `Logos/Core/Semantics/TaskFrame.lean` (task relation)
- **Architecture Reference**: `Documentation/UserGuide/ARCHITECTURE.md` (formal specifications)

---

**Report Status**: COMPLETE
**Next Steps**: Present recommendations to project maintainer for review and potential integration
