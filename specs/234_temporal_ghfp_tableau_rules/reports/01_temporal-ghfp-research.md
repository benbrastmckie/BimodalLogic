# Research Report: Temporal G/H/F/P Tableau Rules (Time-Indexed)

- **Task**: 234 - Temporal G/H/F/P tableau rules with time-indexed branches
- **Status**: Researched
- **Session**: sess_1748790000_orch234
- **Date**: 2026-06-01

## Executive Summary

The current temporal rules in `Tableau.lean` (lines 324-334) are identity-collapse placeholders that strip the temporal operator and keep the formula at the same label. While these patterns DO fire (Lean 4 can pattern-match on `def` abbreviations like `.all_future`), they implement incorrect semantics -- collapsing the temporal quantifier to the current time point instead of introducing fresh time points or propagating to known time points. The repair follows the exact same architectural pattern established by task 233 (S5 modal rules), replacing worlds with time points and the S5 universal accessibility relation with strict linear order (<).

Key findings:

1. **Pattern matching works correctly**: `.all_future ψ` and `.all_past ψ` patterns in Lean 4 unfold through the `def` chain and match the correct formula trees. The issue is purely semantic, not syntactic.
2. **`asSomeFuture?` and `asSomePast?` are broken**: These helpers match the wrong encoding of F/P. They look for `¬G(¬φ)` patterns but actual `some_future`/`some_past` formulas are `untl`/`snce` constructors. They need complete rewriting.
3. **No time-specific branch helpers exist**: Task 232 added world helpers (`knownWorlds`, `maxWorld`, `nextWorld`) but no time analogs. These must be created.
4. **Eight rules needed**: Four for G/H (universal/existential for future/past) and four for F/P (dual roles). Additionally, the TableauRule enum lacks F/P constructors entirely.
5. **Auto-propagation design mirrors task 233**: When a fresh time point is created, all persistent temporal formulas at earlier/later times must propagate.

## 1. Current Temporal Rule Placeholders

### 1.1 Identity-Collapse Rules (Lines 324-334)

```lean
-- T(GA) -> T(A) (temporal: identity-collapse placeholder for task 234)
| .allFuturePos, .pos, .all_future ψ =>
    .linear [SignedFormula.pos ψ l]
-- F(GA) -> F(A) (temporal: identity-collapse placeholder for task 234)
| .allFutureNeg, .neg, .all_future ψ =>
    .linear [SignedFormula.neg ψ l]
-- T(HA) -> T(A) (temporal: identity-collapse placeholder for task 234)
| .allPastPos, .pos, .all_past ψ =>
    .linear [SignedFormula.pos ψ l]
-- F(HA) -> F(A) (temporal: identity-collapse placeholder for task 234)
| .allPastNeg, .neg, .all_past ψ =>
    .linear [SignedFormula.neg ψ l]
```

All four rules strip the temporal operator and add the subformula at the same label with `.linear` result. This is wrong:
- **T(GA) @ t** should propagate T(A) to ALL known times t' > t (universal, persistent)
- **F(GA) @ t** should introduce F(A) at a FRESH time t_new > t (existential, consumable)
- **T(HA) @ t** should propagate T(A) to ALL known times t' < t (universal, persistent)
- **F(HA) @ t** should introduce F(A) at a FRESH time t_new < t (existential, consumable)

### 1.2 Missing F/P Rules

The `TableauRule` enum has NO constructors for F (some_future) or P (some_past):
- No `someFuturePos`, `someFutureNeg`, `somePastPos`, `somePastNeg`
- The `asSomeFuture?` and `asSomePast?` decomposition helpers exist but are unused and broken (see Section 3)

### 1.3 Pattern Matching Mechanism

Lean 4 supports pattern matching on `def` abbreviations. `.all_future ψ` unfolds through:
```
all_future ψ = (some_future ψ.neg).neg
             = (untl (ψ.imp bot) (imp bot bot)).imp bot
             = imp (untl (imp ψ bot) (imp bot bot)) bot
```

The pattern `.all_future ψ` is equivalent to `.imp (.untl (.imp ψ .bot) (.imp .bot .bot)) .bot`. Lean resolves this at elaboration time, so the patterns DO match actual `all_future` formulas. Verified by compilation and testing.

## 2. Formula Encoding Reference

The six primitive Formula constructors are: `atom`, `bot`, `imp`, `box`, `untl`, `snce`.

All temporal operators are defined (`def`) abbreviations:

| Operator | Definition | Top-Level Constructor |
|----------|-----------|----------------------|
| `neg φ` | `φ.imp bot` | `imp` |
| `top` | `bot.imp bot` | `imp` |
| `some_future φ` (F) | `untl φ top` | `untl` |
| `some_past φ` (P) | `snce φ top` | `snce` |
| `all_future φ` (G) | `(some_future φ.neg).neg` | `imp` |
| `all_past φ` (H) | `(some_past φ.neg).neg` | `imp` |

**Critical distinction**: G/H formulas have `imp` at the top level (they are double negations of Until/Since), while F/P formulas have `untl`/`snce` at the top level.

### Pattern Matching Forms

For `isApplicable` and `applyRule`:

| Formula | Lean Pattern |
|---------|-------------|
| G(A) | `.all_future ψ` (Lean unfolds the `def`) |
| H(A) | `.all_past ψ` (Lean unfolds the `def`) |
| F(A) | `.some_future ψ` or equivalently `.untl ψ (.imp .bot .bot)` |
| P(A) | `.some_past ψ` or equivalently `.snce ψ (.imp .bot .bot)` |

Both `.some_future ψ` and `.untl ψ (.imp .bot .bot)` should work as patterns, since `some_future` is also a `def`. However, this requires verification since `some_future φ = untl φ (imp bot bot)` and the pattern extractor needs to handle the nested `def` for `top`.

## 3. Broken Decomposition Helpers

### 3.1 `asSomeFuture?` (Line 178)

```lean
def asSomeFuture? : Formula → Option Formula
  | .imp (.all_future (.imp φ .bot)) .bot => some φ
```

This matches `¬G(¬φ)` which is `(all_future (φ.imp bot)).imp bot`. But actual `some_future φ` = `untl φ (imp bot bot)` which is an `untl` node, not an `imp` node. The two are **semantically equivalent but structurally different**.

**Result**: `asSomeFuture?` returns `none` for all formulas constructed via `Formula.some_future`. Confirmed by testing.

### 3.2 `asSomePast?` (Line 169)

```lean
def asSomePast? : Formula → Option Formula
  | .imp (.all_past (.imp φ .bot)) .bot => some φ
```

Same issue: matches `¬H(¬φ)` but actual `some_past φ` = `snce φ (imp bot bot)`. Returns `none` for all `Formula.some_past` formulas.

### 3.3 Required Replacement

Both helpers must be replaced with patterns matching the ACTUAL structural form:

```lean
def asSomeFuture? : Formula → Option Formula
  | .some_future φ => some φ     -- or: .untl φ (.imp .bot .bot)
  | _ => none

def asSomePast? : Formula → Option Formula
  | .some_past φ => some φ       -- or: .snce φ (.imp .bot .bot)
  | _ => none
```

Note: these will also need `asAllFuture?` and `asAllPast?` helpers (currently nonexistent):

```lean
def asAllFuture? : Formula → Option Formula
  | .all_future φ => some φ
  | _ => none

def asAllPast? : Formula → Option Formula
  | .all_past φ => some φ
  | _ => none
```

## 4. Missing Time Infrastructure

### 4.1 Existing World Helpers (from Tasks 232-233)

In `SignedFormula.lean`, Branch namespace:
- `knownWorlds : Branch → List WorldIndex` -- collect distinct world indices
- `maxWorld : Branch → WorldIndex` -- max world index (0 if empty)
- `nextWorld : Branch → WorldIndex` -- maxWorld + 1
- `boxPosFormulas : Branch → List SignedFormula` -- filter T(box A)
- `diamondNegFormulas : Branch → List SignedFormula` -- filter F(diamond A)

### 4.2 Required Time Analogs

The following must be added to `SignedFormula.lean`, Branch namespace:

```lean
/-- Collect all distinct time indices from signed formulas in the branch. -/
def knownTimes (b : Branch) : List TimeIndex :=
  (b.map (·.label.time)).eraseDups

/-- Maximum time index in the branch (0 if empty). -/
def maxTime (b : Branch) : TimeIndex :=
  b.foldl (fun acc sf => max acc sf.label.time) 0

/-- Next fresh time index (one past the maximum).
    Used by existential temporal rules to introduce witness times. -/
def nextTime (b : Branch) : TimeIndex :=
  b.maxTime + 1

/-- Collect all T(GA) formulas (positive all_future) in the branch.
    These are universal future formulas that must propagate to all future times. -/
def allFuturePosFormulas (b : Branch) : List SignedFormula :=
  b.filter fun sf =>
    match sf.sign, sf.formula with
    | .pos, .all_future _ => true
    | _, _ => false

/-- Collect all F(FA) formulas (negative some_future) in the branch.
    F(FA) = F(¬G¬A) means G¬A, so ¬A at all future times.
    These are universal future formulas that must propagate to all future times. -/
def someFutureNegFormulas (b : Branch) : List SignedFormula :=
  b.filter fun sf =>
    match sf.sign, sf.formula with
    | .neg, .some_future _ => true
    | _, _ => false

/-- Collect all T(HA) formulas (positive all_past) in the branch.
    These are universal past formulas that must propagate to all past times. -/
def allPastPosFormulas (b : Branch) : List SignedFormula :=
  b.filter fun sf =>
    match sf.sign, sf.formula with
    | .pos, .all_past _ => true
    | _, _ => false

/-- Collect all F(PA) formulas (negative some_past) in the branch.
    F(PA) = F(¬H¬A) means H¬A, so ¬A at all past times.
    These are universal past formulas that must propagate to all past times. -/
def somePastNegFormulas (b : Branch) : List SignedFormula :=
  b.filter fun sf =>
    match sf.sign, sf.formula with
    | .neg, .some_past _ => true
    | _, _ => false
```

### 4.3 Time Ordering Considerations

Unlike S5 worlds (which are all mutually accessible via the universal equivalence relation), time points are linearly ordered with strict inequality (<). The branch must track which time points are ordered by <.

**Key design decision**: Since `TimeIndex := Nat` and Nat has a natural linear order, we can use the **natural Nat ordering** as the time ordering. A fresh time `nextTime` is guaranteed to be > all existing times. For past-directed rules that need a fresh time t_new < t, we cannot simply use `maxTime + 1`. Options:

**Option A: Use Nat ordering directly (recommended)**

Use the convention that `nextTime` creates a NEW future time point. For past-directed existential rules, we can encode ordering constraints separately or allocate time indices that preserve the abstract ordering. The simplest approach: maintain a mapping from abstract time identifiers to their position in the linear order. But this adds complexity.

**Option B: Pre-allocate with interleaving**

Reserve even-numbered time slots for "regular" and odd-numbered for "inserted past" points. Complex and fragile.

**Option C: Separate time_lt relation (recommended for correctness)**

Add an explicit ordering relation to the Branch or as a separate data structure:

```lean
structure TimeConstraints where
  /-- Known ordering constraints: (t1, t2) means t1 < t2 -/
  constraints : List (TimeIndex × TimeIndex)
```

With helper functions:
- `addConstraint : TimeConstraints → TimeIndex → TimeIndex → TimeConstraints`
- `isKnownLessThan : TimeConstraints → TimeIndex → TimeIndex → Bool`
- `futureTimesOf : TimeConstraints → TimeIndex → List TimeIndex` (all t' where t < t')
- `pastTimesOf : TimeConstraints → TimeIndex → List TimeIndex` (all t' where t' < t)

**Recommended approach**: Option C is the cleanest but increases implementation complexity. For the initial implementation, Option A with a convention is simpler: allocate fresh indices with `nextTime` for future-directed rules. For past-directed existential rules (F(HA), T(PA)), also use `nextTime` but add an explicit constraint that the new time is BEFORE the target time.

**Simplification for this task**: Since the temporal order is abstract (not literally Nat <), we can use Nat indices as opaque identifiers and maintain an explicit ordering structure. This is more correct and generalizable. However, for a first working implementation, we can use the **Nat-order convention**: future times get increasing indices (nextTime), past times also get increasing indices but are marked as "before" the current time via an ordering constraint list. The constraint list is consulted when determining which times are "future of" or "past of" a given time.

**Final recommendation**: Use the Nat-as-opaque-identifier approach with explicit time constraints. This mirrors how labeled tableaux work in the literature. Store constraints on the Branch or in an auxiliary structure passed to `applyRule`.

## 5. Correct Temporal Tableau Rules

### 5.1 Rule Classification

The eight temporal rules split into universal (persistent) and existential (consumable) pairs, mirroring the S5 modal pattern from task 233:

| Formula | Sign | Semantic | Rule Type | Analogy |
|---------|------|----------|-----------|---------|
| G(A) | T (pos) | A at all t' > t | Universal future | Like T(box A) |
| G(A) | F (neg) | exists t' > t with not A | Existential future | Like F(box A) |
| H(A) | T (pos) | A at all t' < t | Universal past | Like T(box A) |
| H(A) | F (neg) | exists t' < t with not A | Existential past | Like F(box A) |
| F(A) | T (pos) | exists t' > t with A | Existential future | Like T(diamond A) |
| F(A) | F (neg) | A false at all t' > t | Universal future | Like F(diamond A) |
| P(A) | T (pos) | exists t' < t with A | Existential past | Like T(diamond A) |
| P(A) | F (neg) | A false at all t' < t | Universal past | Like F(diamond A) |

### 5.2 Rule Specifications

**Universal rules (persistent, return `.persistent`)**:

```
T(GA) @ (w,t) --> { T(A) @ (w,t') | t' in futureTimes(t) }    [PERSISTENT]
F(FA) @ (w,t) --> { F(A) @ (w,t') | t' in futureTimes(t) }    [PERSISTENT]
T(HA) @ (w,t) --> { T(A) @ (w,t') | t' in pastTimes(t) }      [PERSISTENT]
F(PA) @ (w,t) --> { F(A) @ (w,t') | t' in pastTimes(t) }      [PERSISTENT]
```

**Existential rules (consumable, return `.linear`)**:

```
F(GA) @ (w,t) --> F(A) @ (w, t_new), t < t_new                [CONSUMABLE]
T(FA) @ (w,t) --> T(A) @ (w, t_new), t < t_new                [CONSUMABLE]
F(HA) @ (w,t) --> F(A) @ (w, t_new), t_new < t                [CONSUMABLE]
T(PA) @ (w,t) --> T(A) @ (w, t_new), t_new < t                [CONSUMABLE]
```

### 5.3 Auto-Propagation

When a new time point t_new is created by an existential rule:

**If t_new is a future time (t < t_new)**:
- For every T(GA) @ (w, t') in branch where t' < t_new: add T(A) @ (w, t_new)
- For every F(FA) @ (w, t') in branch where t' < t_new: add F(A) @ (w, t_new)

**If t_new is a past time (t_new < t)**:
- For every T(HA) @ (w, t') in branch where t_new < t': add T(A) @ (w, t_new)
- For every F(PA) @ (w, t') in branch where t_new < t': add F(A) @ (w, t_new)

### 5.4 Nat-Order Convention for Fresh Time Allocation

For the initial implementation, use the following convention:
- Fresh time indices are always allocated via `nextTime` (maxTime + 1)
- ALL fresh times are numerically greater than all existing times
- For **future-directed** existential rules: the fresh time IS genuinely in the future (Nat order = temporal order)
- For **past-directed** existential rules: the fresh time is numerically greater but logically BEFORE the target. Record this via an explicit time constraint.

**Time constraint tracking**:

```lean
/-- Time ordering constraints maintained by the branch.
    An entry (t1, t2) means t1 < t2 in the abstract temporal order. -/
def Branch.timeConstraints (b : Branch) : List (TimeIndex × TimeIndex) := ...
```

**Alternative (simpler for initial implementation)**: Since fresh times are allocated incrementally and future rules always create times with Nat > current, we can use a simpler convention:

For **past** rules (F(HA), T(PA)): allocate the fresh time as `nextTime` but invert the ordering. Since the constraint system needs to track t_new < t (even though numerically t_new > t), we store a `pastTimes` list on the branch: times that are logically before certain points even though their Nat index is larger.

Actually, the cleanest design: **embed the time constraint graph in Branch data**. Add a field to Branch (or use a wrapper):

```lean
structure TemporalBranch where
  formulas : Branch
  timeOrder : List (TimeIndex × TimeIndex)  -- (a, b) means a < b
```

But modifying Branch from `List SignedFormula` to a structure is a larger refactor. A lighter approach: **add time constraints as special "constraint" signed formulas** or **pass constraints as an additional parameter to `applyRule`**.

**Pragmatic recommendation**: For this task, use the simplest correct approach. Since all we need is to track which times are "before" which other times, and the Nat ordering works for future times, we only need to handle past times specially. The simplest approach:

1. Future times: use Nat ordering (t_new = nextTime, guaranteed t_new > all existing times)
2. Past times: also use nextTime for allocation, but add the constraint (t_new, t) meaning t_new < t
3. Store constraints as a list on the Branch via a helper, or pass separately

For the implementation plan, we should store constraints in a separate structure passed alongside the branch. The `applyRule` function already takes `branch : Branch := []`; we can extend it to also take time constraints, or embed constraint tracking in the branch expansion logic in `expandOnce`.

## 6. Required Changes

### 6.1 SignedFormula.lean

**New helpers** (~30 lines):
- `Branch.knownTimes : Branch → List TimeIndex`
- `Branch.maxTime : Branch → TimeIndex`
- `Branch.nextTime : Branch → TimeIndex`
- `Branch.allFuturePosFormulas : Branch → List SignedFormula`
- `Branch.someFutureNegFormulas : Branch → List SignedFormula`
- `Branch.allPastPosFormulas : Branch → List SignedFormula`
- `Branch.somePastNegFormulas : Branch → List SignedFormula`

These mirror `knownWorlds`, `maxWorld`, `nextWorld`, `boxPosFormulas`, `diamondNegFormulas`.

### 6.2 Tableau.lean

**New TableauRule constructors** (4 new):
```lean
| someFuturePos    -- T(FA) -> T(A) at fresh future time (existential)
| someFutureNeg    -- F(FA) -> propagate F(A) to all future times (universal, persistent)
| somePastPos      -- T(PA) -> T(A) at fresh past time (existential)
| somePastNeg      -- F(PA) -> propagate F(A) to all past times (universal, persistent)
```

**Fix decomposition helpers** (~10 lines):
- Rewrite `asSomeFuture?` to match `.some_future φ` (or `.untl φ (.imp .bot .bot)`)
- Rewrite `asSomePast?` to match `.some_past φ` (or `.snce φ (.imp .bot .bot)`)
- Add `asAllFuture?` and `asAllPast?` helpers

**Update `isApplicable`** (~8 new cases):
- Add cases for `.someFuturePos`, `.someFutureNeg`, `.somePastPos`, `.somePastNeg`

**Rewrite `applyRule` temporal cases** (~80 lines):
- Replace 4 identity-collapse G/H rules with correct universal/existential rules
- Add 4 new F/P rules
- Include auto-propagation logic in existential rules
- Handle time constraint tracking (future times via Nat ordering, past times via explicit constraints)

**Update `allRules`** list:
- Add F/P rules to the priority list

### 6.3 Saturation.lean

**Minor updates** (~5 lines):
- Ensure `expandOnce` handles temporal `.persistent` correctly (already handles modal `.persistent` from task 233)
- No structural changes needed beyond what task 233 already established

### 6.4 Time Constraint Design Decision

**For this task, recommend a lightweight constraint approach**:

Add to SignedFormula.lean:
```lean
/-- Collect future times of a given time point.
    In the initial implementation, this uses Nat ordering:
    future times are those with strictly greater Nat index.
    Task 234 note: past-allocated times would need constraint tracking. -/
def Branch.futureTimesOf (b : Branch) (t : TimeIndex) : List TimeIndex :=
  (b.knownTimes).filter (· > t)

/-- Collect past times of a given time point.
    In the initial implementation, uses Nat ordering:
    past times are those with strictly smaller Nat index. -/
def Branch.pastTimesOf (b : Branch) (t : TimeIndex) : List TimeIndex :=
  (b.knownTimes).filter (· < t)
```

**Limitation**: This only works correctly if we never allocate past times with indices greater than the reference time. Since past-directed existential rules (F(HA), T(PA)) create new time points that should be BEFORE the current time, using `nextTime` (which is always larger) breaks the Nat-order convention.

**Resolution options for past-directed allocation**:

1. **Reserve index 0 as the initial time, allocate past times below it**: Not possible with `Nat` (no negative indices).

2. **Use two counters**: `nextFutureTime` (counts up) and `nextPastTime` (counts down from some bound). But `Nat` has no negative numbers.

3. **Use Int instead of Nat for TimeIndex**: Allows negative indices for past times. `nextPastTime = minTime - 1`. This is a clean solution but changes the type alias.

4. **Explicit constraint list**: Keep `TimeIndex := Nat`, allocate all fresh times via `nextTime`, maintain an explicit `List (TimeIndex × TimeIndex)` of ordering constraints. `futureTimesOf`/`pastTimesOf` consult this list.

5. **Label-embedded constraints**: Add a `timeLt : List (TimeIndex × TimeIndex)` field to the Branch (requires changing Branch from type alias to structure).

**Recommendation**: Option 4 (explicit constraint list) is cleanest for this task scope. Pass the constraint list as an additional parameter or store it alongside the branch in the expansion logic. The constraint list is:
- Initially empty (time 0 is the only time)
- When a future-directed rule creates t_new: add (t, t_new) where t < t_new naturally
- When a past-directed rule creates t_new: add (t_new, t) meaning t_new < t even though numerically t_new > t
- `futureTimesOf(t)` returns all t' such that (t, t') is in transitive closure of constraints
- `pastTimesOf(t)` returns all t' such that (t', t) is in transitive closure of constraints

For the **initial implementation** (this task), a simpler approach works:
- Only use `nextTime` for future-directed rules (F(GA), T(FA))  
- For past-directed rules (F(HA), T(PA)), also use `nextTime` and **assume the caller knows** the ordering is inverted
- Store ordering constraints as `List (TimeIndex × TimeIndex)` on a wrapper around Branch
- Consultation of constraints replaces Nat comparison

**Concrete recommendation**: Define a `TemporalState` structure or thread constraints through the expansion:

```lean
/-- Time ordering constraints for the temporal tableau.
    Each pair (a, b) asserts a < b in the abstract temporal order.
    Fresh time indices are allocated via nextTime (always Nat-increasing),
    with explicit constraints recording the intended temporal ordering. -/
structure TimeOrdering where
  constraints : List (TimeIndex × TimeIndex)

namespace TimeOrdering

def empty : TimeOrdering := ⟨[]⟩

def addFuture (to : TimeOrdering) (t t_new : TimeIndex) : TimeOrdering :=
  ⟨(t, t_new) :: to.constraints⟩

def addPast (to : TimeOrdering) (t t_new : TimeIndex) : TimeOrdering :=
  ⟨(t_new, t) :: to.constraints⟩

/-- All times known to be strictly after t. -/
def futureOf (to : TimeOrdering) (t : TimeIndex) : List TimeIndex :=
  to.constraints.filterMap fun (a, b) => if a == t then some b else none

/-- All times known to be strictly before t. -/
def pastOf (to : TimeOrdering) (t : TimeIndex) : List TimeIndex :=
  to.constraints.filterMap fun (a, b) => if b == t then some a else none

end TimeOrdering
```

This can be threaded through `expandOnce` and `expandBranchWithFuel` without changing the Branch type alias.

## 7. Analogy Table: Modal vs Temporal Rules

| Modal (Task 233) | Temporal (Task 234) | Difference |
|-------------------|---------------------|------------|
| `WorldIndex := Nat` | `TimeIndex := Nat` | Same type |
| S5 universal accessibility | Strict linear order (<) | Directional |
| `knownWorlds` | `knownTimes` | Same pattern |
| `maxWorld` / `nextWorld` | `maxTime` / `nextTime` | Same pattern |
| `boxPosFormulas` | `allFuturePosFormulas` | Same pattern |
| `diamondNegFormulas` | `someFutureNegFormulas` | Same pattern |
| T(box A) -> persistent | T(GA), F(FA) -> persistent | Two directions |
| F(box A) -> existential | F(GA), T(FA) -> existential | Two directions |
| T(diamond A) -> existential | T(PA), T(FA) -> existential | Two directions |
| F(diamond A) -> persistent | F(PA), F(FA) -> persistent | Two directions |
| No ordering on worlds | Strict order on times | KEY DIFFERENCE |
| Auto-propagate box/diamond | Auto-propagate G/H + F/P | Same pattern |

**Key structural difference**: Modal S5 has SYMMETRIC accessibility (all worlds see all worlds), while temporal order is ASYMMETRIC (future vs past). This doubles the rule count: 4 modal rules become 8 temporal rules (4 future + 4 past).

## 8. Change Surface Assessment

### Files to Modify

| File | Changes | Estimated Lines |
|------|---------|----------------|
| `SignedFormula.lean` | Add 7 time helper functions | ~35 |
| `Tableau.lean` | 4 new rule constructors, fix 2 helpers, rewrite 4 rules, add 4 rules, update lists | ~120 |
| `Saturation.lean` | Thread TimeOrdering through expansion | ~15 |

**Total estimated**: ~170 lines changed/added.

### Files NOT Modified

- `Closure.lean`: Already handles label-aware contradictions correctly (same-label matching). No changes needed.
- `DecisionProcedure.lean`: Calls `buildTableau` which calls `expandBranchWithFuel`. If TimeOrdering is threaded through, minimal changes here.
- `Correctness.lean`: No changes needed.
- `ProofExtraction.lean`: May need minor updates if rule names change.
- `CountermodelExtraction.lean`: May need updates for time domain in countermodels.

### Compilation Dependencies

```
SignedFormula.lean (add time helpers)
  └─ Tableau.lean (new rules, fix helpers)
       └─ Closure.lean (no changes)
            └─ Saturation.lean (thread TimeOrdering)
                 └─ ProofExtraction.lean (minor)
                      └─ CountermodelExtraction.lean (minor)
                           └─ DecisionProcedure.lean (minor)
```

### Risk Assessment

1. **Low risk**: Adding time helpers to SignedFormula.lean -- pure additions, no existing code modified
2. **Medium risk**: Rewriting temporal rules in Tableau.lean -- must preserve compilation of all downstream modules
3. **Medium risk**: TimeOrdering threading -- changes function signatures which ripples through Saturation/DecisionProcedure
4. **Low risk**: Pattern matching on `.some_future`/`.some_past` -- verified that Lean 4 unfolds these `def`s
5. **Medium risk**: Past-time allocation -- the Nat-as-opaque-identifier approach with explicit constraints needs careful testing

## 9. Test Plan

### Validity Tests (should pass)

| Formula | Expected | Rationale |
|---------|----------|-----------|
| `G p -> G p` | VALID | Propositional tautology |
| `G (p -> q) -> (G p -> G q)` | VALID | Temporal K (distribution) |
| `H (p -> q) -> (H p -> H q)` | VALID | Past temporal K |
| `F p -> F p` | VALID | Propositional tautology |

### Invalidity Tests (should fail)

| Formula | Expected | Rationale |
|---------|----------|-----------|
| `G p -> p` | INVALID | T-axiom fails under strict semantics |
| `H p -> p` | INVALID | Past T-axiom fails under strict semantics |
| `p -> G p` | INVALID | Non-theorem |
| `F p -> p` | INVALID | Non-theorem |
| `p -> F p` | INVALID | Non-theorem (seriality is separate) |

### Cross-Modal-Temporal Tests (for task 236)

| Formula | Expected | Notes |
|---------|----------|-------|
| `box p -> box (G p)` | Depends | modal_future axiom -- tested in task 236 |

## 10. Implementation Phasing Recommendation

### Phase 1: Time Infrastructure (~35 lines)
Add time helpers to SignedFormula.lean:
- `knownTimes`, `maxTime`, `nextTime`
- `allFuturePosFormulas`, `someFutureNegFormulas`, `allPastPosFormulas`, `somePastNegFormulas`
- Verify: `lake build Bimodal.Metalogic.Decidability.SignedFormula`

### Phase 2: TimeOrdering Structure (~25 lines)
Add `TimeOrdering` structure (can go in SignedFormula.lean or a new file):
- `TimeOrdering` with `empty`, `addFuture`, `addPast`, `futureOf`, `pastOf`
- Verify: compilation

### Phase 3: Fix Decomposition Helpers (~15 lines)
In Tableau.lean:
- Rewrite `asSomeFuture?` and `asSomePast?`
- Add `asAllFuture?` and `asAllPast?`
- Verify: compilation (existing code unaffected since these helpers are currently unused)

### Phase 4: Add F/P Rule Constructors and Rewrite All Temporal Rules (~80 lines)
In Tableau.lean:
- Add 4 new constructors to TableauRule enum
- Rewrite 4 existing G/H rules (allFuturePos/Neg, allPastPos/Neg)
- Add 4 new F/P rules (someFuturePos/Neg, somePastPos/Neg)
- Include auto-propagation in existential rules
- Update `isApplicable`, `applyRule`, `allRules`
- Verify: `lake build Bimodal.Metalogic.Decidability.Tableau`

### Phase 5: Thread TimeOrdering Through Expansion (~20 lines)
In Saturation.lean (and possibly DecisionProcedure.lean):
- Pass TimeOrdering through `expandOnce`, `expandBranchWithFuel`
- Initialize with `TimeOrdering.empty` in `buildTableau`
- Verify: `lake build`

### Phase 6: Integration Testing (~10 lines)
- Add `#eval` tests for G/H/F/P formulas
- Verify expected validity/invalidity results
- Full `lake build`

## 11. Open Questions for Planning

1. **TimeOrdering threading depth**: Should TimeOrdering be a field on a wrapper around Branch, a parameter to applyRule, or a parameter to expandOnce/expandBranchWithFuel? The parameter approach is least invasive.

2. **Past-time allocation**: Can we simplify by using Nat ordering for everything (future times get high indices, past times get low indices via pre-allocation)? The initial time could be set to a large number (e.g., 1000) so that past times can be allocated below it. This avoids needing an explicit constraint list but limits the number of past-time allocations.

3. **Transitive closure**: Should `futureOf`/`pastOf` compute the transitive closure, or just immediate successors/predecessors? For correctness, they must return ALL times that are in the future/past, not just directly adjacent ones. A simple transitive closure computation on a small constraint list is acceptable.

4. **Cross-modal-temporal interaction**: When a new world is created (by modal rules), should existing temporal formulas be propagated to that world? This is task 236's scope, not task 234's.

5. **Termination impact**: Adding persistent temporal rules (like persistent modal rules) means the expansion loop must still terminate. The fuel-based approach from task 233 handles this: persistent expansions consume fuel. But with 8 temporal rules (some persistent), the fuel consumption rate increases. The `recommendedFuel` heuristic may need adjustment.
