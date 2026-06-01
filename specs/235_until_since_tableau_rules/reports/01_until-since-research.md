# Research Report: Until/Since Tableau Rules (Task 235)

**Task**: Implement tableau rules for primitive Until (`untl`) and Since (`snce`) operators
**Session**: sess_1748795000_orch235
**Date**: 2026-06-01

---

## 1. Formula Constructors and Semantics

### 1.1 Constructor Arguments (Burgess Convention)

From `Formula.lean` (lines 70-85):

```
| untl : Formula -> Formula -> Formula   -- untl(event, guard)
| snce : Formula -> Formula -> Formula   -- snce(event, guard)
```

**Burgess convention** (confirmed in docstring): first argument is the **event** (eventually true), second argument is the **guard** (holds in between).

- `untl(psi, phi)` means "phi holds until psi becomes true": there exists s > t such that psi(s) and for all r in (t,s), phi(r).
- `snce(psi, phi)` means "phi has held since psi was true": there exists s < t such that psi(s) and for all r in (s,t), phi(r).

### 1.2 Truth Conditions (from Truth.lean, lines 128-131)

```lean
| Formula.untl phi psi => exists s, t < s /\ truth_at M Omega tau s phi /\
    forall r, t < r -> r < s -> truth_at M Omega tau r psi
| Formula.snce phi psi => exists s, s < t /\ truth_at M Omega tau s phi /\
    forall r, s < r -> r < t -> truth_at M Omega tau r psi
```

**Critical**: Open-guard semantics. The guard `psi` holds on the **open** interval `(t, s)`, not including endpoints `t` or `s`.

### 1.3 Derived Operators Already Handled

The existing tableau rules handle these special cases of `untl`/`snce`:

| Derived Operator | Definition | Existing Rules |
|---|---|---|
| `some_future(phi)` = `untl(phi, top)` | F(phi) | someFuturePos, someFutureNeg |
| `some_past(phi)` = `snce(phi, top)` | P(phi) | somePastPos, somePastNeg |
| `all_future(phi)` = `neg(untl(neg(phi), top))` | G(phi) | allFuturePos, allFutureNeg |
| `all_past(phi)` = `neg(snce(neg(phi), top))` | H(phi) | allPastPos, allPastNeg |

**What is MISSING**: Rules for generic `untl(event, guard)` and `snce(event, guard)` where the guard is not `top` (i.e., not `imp bot bot`). These are genuine Until/Since formulas with non-trivial guards.

---

## 2. Current Infrastructure Analysis

### 2.1 RuleResult Type (Tableau.lean, lines 121-131)

```lean
inductive RuleResult : Type where
  | linear (formulas : List SignedFormula)
  | branching (branches : List (List SignedFormula))
  | persistent (formulas : List SignedFormula)
  | notApplicable
```

**Branching is already supported.** The `branching` constructor takes a list of lists, where each inner list represents formulas to add to a separate branch. This is used by `andNeg`, `orPos`, and `impPos`. No new `RuleResult` variant is needed.

### 2.2 TableauRule Enumeration

Currently 18 rules (Tableau.lean, lines 67-108). No Until/Since rules exist. We need to add 4 new constructors:
- `untlPos` -- T(U(psi, phi)) rules
- `untlNeg` -- F(U(psi, phi)) rules
- `sncePos` -- T(S(psi, phi)) rules
- `snceNeg` -- F(S(psi, phi)) rules

### 2.3 Pattern Matching Considerations

Lean's pattern matching with `def` abbreviations means:
- `.some_future phi` matches `untl phi (imp bot bot)` (guard = top)
- `.all_future phi` matches `imp (untl (imp phi bot) (imp bot bot)) bot` (wrapped negation)
- `.some_past phi` matches `snce phi (imp bot bot)` (guard = top)
- `.all_past phi` matches `imp (snce (imp phi bot) (imp bot bot)) bot` (wrapped negation)

Raw `.untl event guard` will only match formulas where the guard is NOT `top` (since the more specific patterns are tried first in Lean's pattern matching). However, we need to be careful: in `isApplicable` and `applyRule`, the matching order is controlled by the `match rule, sf.sign, sf.formula` pattern. We should ensure that Until/Since rules only fire for formulas NOT already caught by someFuture/somePast/allFuture/allPast rules.

**Design decision**: Add explicit guard checks. In the `isApplicable` and `applyRule` match arms for `untlPos`/`untlNeg`/`sncePos`/`snceNeg`, match on `.untl event guard` / `.snce event guard` and explicitly verify the formula is NOT a `some_future`/`some_past` pattern (i.e., guard is not `top`). This prevents double-matching. Alternatively, rely on the `allRules` priority ordering to try G/H/F/P rules first, so that by the time untl/snce rules are tried, only genuine Until/Since formulas remain.

### 2.4 TimeOrdering Infrastructure (SignedFormula.lean, lines 406-449)

Already supports:
- `addFuture(t, t_new)` -- add constraint `t < t_new`
- `addPast(t, t_new)` -- add constraint `t_new < t`
- `futureOf(t)` -- all times strictly after t
- `pastOf(t)` -- all times strictly before t

This is exactly what we need for Until/Since time witnesses.

### 2.5 Branch Helpers (SignedFormula.lean, lines 299-401)

Already supports:
- `knownTimes`, `maxTime`, `nextTime` -- for fresh time allocation
- `allFuturePosFormulas`, `someFutureNegFormulas`, `allPastPosFormulas`, `somePastNegFormulas` -- for auto-propagation

**Missing**: No helpers for collecting Until/Since formulas on the branch. We will need:
- `untlPosFormulas(b)` -- collect all T(U(psi, phi)) formulas
- `untlNegFormulas(b)` -- collect all F(U(psi, phi)) formulas  
- `sncePosFormulas(b)` -- collect all T(S(psi, phi)) formulas
- `snceNegFormulas(b)` -- collect all F(S(psi, phi)) formulas

These are needed for auto-propagation when new time points are created.

---

## 3. Tableau Rule Design

### 3.1 T(U(psi, phi)) at time t -- Positive Until (Branching)

Semantics: There exists s > t such that psi(s) and for all r in (t,s), phi(r).

**Decomposition** (disjunctive/branching):

**Branch 1 -- Event Witness**: The event happens at the next available future time.
- Introduce fresh time t_new > t
- Add T(psi) @ (w, t_new) -- event witnessed
- Add TimeOrdering constraint: t < t_new

**Branch 2 -- Guard + Continue**: The guard holds now (at the next time), and the Until continues.
- Introduce fresh time t_new > t
- Add T(phi) @ (w, t_new) -- guard holds at t_new
- Add T(U(psi, phi)) @ (w, t_new) -- Until continues from t_new
- Add TimeOrdering constraint: t < t_new

Both branches need auto-propagation of universal temporal formulas (T(GA), F(FA)) to the fresh time.

**Rule classification**: `branching` (uses `RuleResult.branching`)

**Consumable vs Persistent**: The T(U(psi, phi)) source formula should be **consumable** (removed after application), since each application produces a fresh time with either the witness or the continuation. Keeping it persistent would cause infinite re-application. Termination is guaranteed by blocking (task 237) and the subformula property.

### 3.2 F(U(psi, phi)) at time t -- Negative Until (Universal/Persistent)

Semantics: For ALL s > t, either NOT psi(s) OR there exists r in (t,s) where NOT phi(r).

This is the negation: there is no future witness. At every future time, either the event fails or the guard was broken somewhere before.

**Decomposition** (universal propagation to all known future times):

For each known time t' in `futureOf(t)`:
- Add the pair: F(psi) @ (w, t') OR T(psi) @ (w, t') implies a guard violation somewhere.

Actually, the correct decomposition for F(U(psi, phi)) follows from the semantics of negation of Until:

NOT(exists s > t, psi(s) AND forall r in (t,s), phi(r))
= forall s > t, NOT psi(s) OR exists r in (t,s), NOT phi(r)

This is complex to decompose directly. The standard tableau approach uses the **fixed-point characterization**:

U(psi, phi) <=> psi OR (phi AND X(U(psi, phi)))   [for discrete time]

But for dense/arbitrary linear orders, the fixed-point is:
U(psi, phi) <=> F(psi) AND (psi OR (phi AND U(psi, phi)))   [self-accumulation BX5]

**Alternative approach -- Semantic decomposition for F(U(psi, phi))**:

The negation of Until at t means: for all s > t, if psi(s) then there exists r in (t,s) with NOT phi(r). This is equivalent to saying that at every future time where the event occurs, the guard was violated somewhere before it.

For tableau purposes, the practical decomposition is:

**F(U(psi, phi)) @ t**: At each future time t' > t (from TimeOrdering):
- **Add**: A branching formula that represents "either F(psi) @ t' or the guard was violated before t'"

But this branching-per-time-point approach is complex. A simpler standard approach:

**Approach: Direct negation propagation**

F(U(psi, phi)) @ t can be decomposed as:
- For all t' > t in the TimeOrdering:
  - BRANCH: F(psi) @ t' | F(phi) @ t' (the event fails, or the guard fails here)

Wait -- this is not quite right either. The correct negation is more nuanced.

**Correct approach using the contrapositive of BX axioms**:

From BX10 (until_F): U(psi, phi) -> F(psi). Contrapositive: NOT F(psi) -> NOT U(psi, phi).
So if F(U(psi, phi)) is on the branch, we can add F(F(psi)) = F(some_future(psi)).
But F(F(psi)) = negation of "eventually psi" = G(NOT psi) = all_future(neg(psi)).

This gives us one useful propagation but not a complete decomposition.

**Best approach: Open-guard fixed-point decomposition**

For the tableau, the cleanest decomposition of F(U(psi, phi)) at time t follows from the equivalence:

U(psi, phi) <=> (psi AND phi) OR (phi AND U(psi, phi) at some strictly later time)

Nah, that's not right either for open guard. Let me think more carefully.

Under open-guard semantics, U(psi, phi) at t means:
- There exists s > t with psi(s) AND for all r in (t,s), phi(r)

The negation F(U(psi, phi)) at t means:
- For all s > t: NOT psi(s) OR there exists r in (t,s) with NOT phi(r)

For a tableau, we propagate this to each known future time t' > t:
- At t': either F(psi) @ t', or there exists r in (t, t') with F(phi) @ r

The "exists r in (t, t')" part is problematic because it requires introducing yet another time point. 

**Practical tableau approach**: Use **co-decomposition** pattern.

For each future time t' > t in the ordering:
- BRANCH into: {F(psi) @ t'} | {F(phi) @ t', F(U(psi, phi)) @ t'}

This says: at t', either (a) the event fails at t', or (b) the guard fails at t' AND the Until still fails from t'. The second branch propagates the failure forward.

Actually, wait. Let me reconsider the correct decomposition more carefully by looking at how the BX axiom system handles this.

**BX5 (self-accumulation)**: U(psi, phi) -> U(psi, phi AND U(psi, phi))

This tells us that if U holds, the guard is enriched with the Until itself at intermediate points. Taking the contrapositive:

NOT U(psi, phi AND U(psi, phi)) -> NOT U(psi, phi)

**Correct F(U(psi, phi)) decomposition for open guard**:

The standard tableau approach (following Reynolds/Gore) for F(U(psi, phi)) at t propagates to each future t' > t:

BRANCH: {F(psi) @ t'} | {F(phi) @ t'}

This is a **persistent/universal** rule: it must be applied to EVERY future time, and the source formula persists. At each future time, either the event fails or the guard fails.

But this alone is incomplete -- it doesn't capture that the guard failure must be "before" the event. In practice, for soundness it suffices because if any branch survives with all guards holding and all events failing, we have a model of NOT U(psi, phi).

Actually, the simplest correct decomposition follows from:

NOT U(psi, phi) at t <=> for all t' > t: NOT psi(t') OR (NOT phi(t') AND NOT U(psi, phi) at t')

Wait, that's still not right. Let me just use the standard Reynolds-style decomposition.

**Reynolds decomposition (correct for open guard)**:

For F(U(psi, phi)) at time t, propagate to each future time t' > t:
- Add: F(psi) @ t' AND (F(phi) @ t' OR F(U(psi, phi)) @ t')

This is a conjunction at each future time, meaning it's a **linear (non-branching) propagation**:
- Add F(psi) @ t' -- the event must fail at t'

But we also need the guard failure propagation. The full correct decomposition:

For each future time t' > t:
- BRANCH: {F(psi) @ t'} | {F(phi) at some r in (t, t')}

This is hard to encode directly. 

**PRAGMATIC DESIGN DECISION**: Given the complexity, use the following approach which is standard in temporal tableau systems:

**F(U(psi, phi)) @ t -- Persistent Universal Rule**:
For each known future time t' > t:
- Add: F(psi) @ t' (the event must fail at every future time)

This corresponds to the contrapositive of BX10: U(psi,phi) -> F(psi), so NOT F(psi) (= G(NOT psi)) is necessary for NOT U(psi,phi). Combined with the guard check:

- Also add: Branching at each t' > t: {F(phi) @ t'} (guard must fail at some point)

But that's overkill. Let me settle on the clean design:

**Final Design for F(U(psi, phi)) @ t**:

Persistent rule that propagates to each future t' > t in TimeOrdering:
- BRANCH: {F(psi) @ t'} | {F(phi) @ t'}

This says at each future time, either the event fails or the guard fails. This is **sound** (if U held, psi would hold at some s and phi at all (t,s), so neither could fail there) and **complete** when combined with eventuality tracking (task 237 blocking).

### 3.3 T(S(psi, phi)) at time t -- Positive Since (Branching)

Symmetric to T(U(psi, phi)) but in the past direction:

**Branch 1 -- Event Witness**:
- Introduce fresh time t_new < t (past)
- Add T(psi) @ (w, t_new)
- Add TimeOrdering constraint: t_new < t

**Branch 2 -- Guard + Continue**:
- Introduce fresh time t_new < t
- Add T(phi) @ (w, t_new)
- Add T(S(psi, phi)) @ (w, t_new)
- Add TimeOrdering constraint: t_new < t

Auto-propagate universal past formulas (T(HA), F(PA)) to fresh time.

### 3.4 F(S(psi, phi)) at time t -- Negative Since (Persistent)

Symmetric to F(U(psi, phi)) but in the past direction.

For each known past time t' < t:
- BRANCH: {F(psi) @ t'} | {F(phi) @ t'}

---

## 4. Eventuality Tracking

### 4.1 The Infinite Deferral Problem

T(U(psi, phi)) can repeatedly choose the "guard + continue" branch, deferring the event witness indefinitely. This creates an infinite path through the tableau where the Until is never satisfied.

### 4.2 Solution: Eventuality Obligations

An **eventuality** is a T(U(psi, phi)) or T(S(psi, phi)) formula that has not yet produced an event witness. The tableau must ensure that on every infinite path, all eventualities are eventually fulfilled (event witness branch taken).

**Data structure**: Track a set of unfulfilled eventualities per branch.

```lean
structure Eventuality where
  formula : Formula        -- The Until/Since formula
  label : Label            -- Where it was introduced
  isUntil : Bool           -- true for Until, false for Since
```

When T(U(psi, phi)) is decomposed:
- Branch 1 (event witness): Remove the eventuality from the tracking set
- Branch 2 (guard + continue): The eventuality persists (now at a new time)

### 4.3 Scope: Task 235 vs Task 237

Task 237 handles blocking/termination. The eventuality tracking data structure should be introduced in task 235 (since the rules need to interact with it), but the actual blocking logic (subset blocking, loop detection) belongs in task 237.

**Recommendation**: Task 235 should:
1. Define the `Eventuality` structure
2. Add eventuality tracking to the branch state
3. Record when eventualities are created (guard+continue) and fulfilled (event witness)
4. NOT implement blocking -- just track the obligations

Task 237 will then use this tracking to implement actual blocking.

---

## 5. Auto-Propagation Requirements

When Until/Since rules create fresh time points, universal temporal formulas must be propagated. The existing pattern (from task 234) handles:

| Formula Type | Direction | Propagation |
|---|---|---|
| T(GA) | future | T(A) at all future times |
| F(FA) | future | F(A) at all future times |
| T(HA) | past | T(A) at all past times |
| F(PA) | past | F(A) at all past times |

For Until/Since rules:
- `untlPos` (T(U)) creates a **future** time -> propagate T(GA) and F(FA)
- `sncePos` (T(S)) creates a **past** time -> propagate T(HA) and F(PA)

Additionally, when new times are created by Until/Since rules, we should also propagate:
- F(U(psi, phi)) formulas: their negation propagates to the new future time
- F(S(psi, phi)) formulas: their negation propagates to the new past time

This requires the new branch helpers (`untlNegFormulas`, `snceNegFormulas`).

---

## 6. BX Axioms Testing

### 6.1 Axioms Involving Until/Since

The following BX axioms use `untl`/`snce` with non-trivial guards and should be tested:

| Axiom | Formula | Tests |
|---|---|---|
| BX2G (left_mono_until_G) | G(phi->chi) -> (U(psi,phi) -> U(psi,chi)) | Guard monotonicity |
| BX2H (left_mono_since_H) | H(phi->chi) -> (S(psi,phi) -> S(psi,chi)) | Guard monotonicity |
| BX3 (right_mono_until) | G(phi->psi) -> (U(phi,chi) -> U(psi,chi)) | Event monotonicity |
| BX3' (right_mono_since) | H(phi->psi) -> (S(phi,chi) -> S(psi,chi)) | Event monotonicity |
| BX5 (self_accum_until) | U(psi,phi) -> U(psi, phi AND U(psi,phi)) | Self-accumulation |
| BX5' (self_accum_since) | S(psi,phi) -> S(psi, phi AND S(psi,phi)) | Self-accumulation |
| BX6 (absorb_until) | U(phi AND U(psi,phi), phi) -> U(psi,phi) | Absorption |
| BX6' (absorb_since) | S(phi AND S(psi,phi), phi) -> S(psi,phi) | Absorption |
| BX7 (linear_until) | U(psi,phi) AND U(theta,chi) -> 3-way disjunction | Linearity |
| BX7' (linear_since) | S(psi,phi) AND S(theta,chi) -> 3-way disjunction | Linearity |
| BX10 (until_F) | U(psi,phi) -> F(psi) | Eventuality extraction |
| BX10' (since_P) | S(psi,phi) -> P(psi) | Eventuality extraction |
| BX12 (F_until_equiv) | F(phi) -> U(phi, top) | F-Until bridge |
| BX12' (P_since_equiv) | P(phi) -> S(phi, top) | P-Since bridge |
| BX13 (enrichment_until) | p AND U(psi,phi) -> U(psi AND S(p,phi), phi) | Enrichment |
| BX13' (enrichment_since) | p AND S(psi,phi) -> S(psi AND U(p,phi), phi) | Enrichment |
| Prior-UZ | F(phi) -> U(phi, NOT phi) | Prior axiom |
| Prior-SZ | P(phi) -> S(phi, NOT phi) | Prior axiom |
| Discrete symm fwd | U(top,bot) -> S(top,bot) | Uniformity |
| Discrete symm bwd | S(top,bot) -> U(top,bot) | Uniformity |
| Discrete propagate fwd | U(top,bot) -> G(U(top,bot)) | Uniformity |
| Discrete propagate bwd | U(top,bot) -> H(U(top,bot)) | Uniformity |
| Discrete box necessity | U(top,bot) -> box(U(top,bot)) | Uniformity |

Note: Some of these (BX5, BX6, BX7, BX13) are complex and may not close purely via tableau decomposition without blocking. They may require the blocking/loop-detection from task 237. The basic axioms (BX10, BX12, seriality) should close with just the decomposition rules.

---

## 7. Implementation Plan Outline

### 7.1 Change Surface

| File | Changes |
|---|---|
| `SignedFormula.lean` | Add branch helpers for collecting Until/Since formulas; add Eventuality type |
| `Tableau.lean` | Add 4 TableauRule constructors; add decomposition helpers (asUntil?, asSince?); implement applyRule arms; update allRules list and isApplicable |
| `Saturation.lean` | Thread eventuality tracking through expansion; update auto-propagation for Until/Since |
| `Closure.lean` | No changes needed (matchAxiom already handles BX axiom closure) |

### 7.2 Compilation Dependencies

```
Formula.lean (no changes)
  -> SignedFormula.lean (add helpers, Eventuality type)
    -> Tableau.lean (add rules)
      -> Closure.lean (no changes)
        -> Saturation.lean (thread eventuality tracking)
```

### 7.3 Decomposition Helper Functions

New helpers needed in Tableau.lean:

```lean
/-- Try to decompose a formula as a genuine Until (not some_future or all_future). -/
def asUntil? : Formula -> Option (Formula x Formula)
  | .untl event guard =>
    -- Exclude some_future pattern (guard = top)
    if guard == Formula.top then none
    else some (event, guard)
  | _ => none

/-- Try to decompose a formula as a genuine Since (not some_past or all_past). -/
def asSince? : Formula -> Option (Formula x Formula)
  | .snce event guard =>
    if guard == Formula.top then none
    else some (event, guard)
  | _ => none
```

### 7.4 Rule Priority

Until/Since rules should be placed AFTER the G/H/F/P rules in `allRules` (to ensure derived operators are handled by their specific rules first) but BEFORE branching propositional rules:

```lean
def allRules : List TableauRule := [
  .negPos, .negNeg,
  .impNeg,
  .andPos, .orNeg,
  .boxPos, .boxNeg,
  .diamondPos, .diamondNeg,
  .allFuturePos, .allFutureNeg,
  .allPastPos, .allPastNeg,
  .someFuturePos, .someFutureNeg,
  .somePastPos, .somePastNeg,
  -- NEW: Until/Since rules (after G/H/F/P, before branching propositional)
  .untlPos, .untlNeg,
  .sncePos, .snceNeg,
  .impPos,
  .andNeg, .orPos
]
```

### 7.5 Key Design Decisions

1. **Pattern matching guards**: Use `asUntil?`/`asSince?` helpers with explicit guard != top check to avoid overlap with existing someFuture/somePast rules.

2. **T(U) is branching + consumable**: Uses `RuleResult.branching` with two branches. Source formula removed (not persistent). Fresh time introduced in BOTH branches.

3. **F(U) is persistent**: Uses `RuleResult.persistent` or a new branching-persistent hybrid. Propagates to all known future times. Source formula persists for new times.

4. **F(U) decomposition at each future time**: BRANCH into {F(event)} | {F(guard)}. This is a branching-per-time operation. Since the existing `persistent` result type is linear (non-branching), we may need a new result type `branchingPersistent` or handle this differently.

5. **Actually**: Looking more carefully, F(U(psi,phi)) at each future time t' needs to produce a disjunction. The cleanest approach is to make F(U) a persistent rule that produces branching at each future time. But the current `RuleResult` doesn't support "persistent AND branching". 

   **Resolution**: F(U) can use `RuleResult.branching` where each branch includes the source formula. Since branching removes the source formula, we can manually re-include it in each branch's formula list. Or we extend RuleResult with a new variant.

   **Simplest approach**: For F(U(psi,phi)) at t, for each future t' > t:
   - Add F(psi) @ t' (the event fails everywhere) -- this is LINEAR, not branching
   - The guard failure is handled separately: we don't need to branch on guard failure at each point because the guard failure is captured by other mechanisms

   Actually, reconsidering: F(U(psi,phi)) means "there is no future s > t where psi holds with phi holding on (t,s)". The strongest decomposition for tableau completeness is:

   F(U(psi,phi)) at t propagated to future t':
   - Linear: F(psi) @ t' OR F(phi) @ t'   <-- this IS a disjunction

   But actually this is wrong for soundness! Consider: F(U(psi, phi)) at t=0 with t'=2. It could be that psi(2) is true and phi(1) is false. Then neither F(psi)@2 nor F(phi)@2 needs to hold. The guard failure is at time 1, not time 2.

   **Correct F(U) decomposition**: 
   
   F(U(psi,phi)) at t is best handled as:
   - Persistent: for each future t' > t, add F(psi) @ t' (event must fail everywhere)
   - This is incomplete on its own but becomes complete with the eventuality tracking and blocking from task 237
   
   **Alternative (more complete but more complex)**:
   F(U(psi,phi)) at t with future t':
   - BRANCH: {F(psi) @ t'} | {F(phi) @ t', F(U(psi, phi)) @ t'}
   
   This is the correct Reynolds decomposition. Branch 1: event fails at t'. Branch 2: guard fails at t' AND the Until still fails from t' onwards. The second branch is needed because if the guard fails at t', any witness s > t must have the guard broken in (t, s), and t' is a candidate breaking point only if the Until still fails from t'.

   **RECOMMENDED**: Use the Reynolds decomposition. For F(U(psi,phi)):
   - Make it persistent (keep source formula)
   - At each future t' > t, produce a branching: {F(psi) @ t'} | {F(phi) @ t', F(U(psi,phi)) @ t'}
   - Implementation: since we can't do "persistent + branching" directly, expand one future time at a time. Pick the first unprocessed future time and branch on it.

6. **Eventuality data structure**: Introduce a lightweight `Eventuality` record in SignedFormula.lean. Store eventualities as a list threaded through the expansion, similar to TimeOrdering.

---

## 8. Blocking Scope Assessment

**Task 235 scope**: Implement the rules and basic eventuality tracking. Do NOT implement the actual blocking/loop detection.

**Task 237 scope**: Use the eventuality tracking from 235 to implement:
- Subset blocking (if a new time has formulas that are a subset of an ancestor)
- Eventuality fulfillment checking (ensuring all eventualities on a path are eventually fulfilled)
- Sound fuel bounds based on subformula closure size

---

## 9. Risk Assessment

### 9.1 Pattern Matching Overlap

**Risk**: Raw `.untl`/`.snce` pattern in applyRule might accidentally catch `some_future`/`all_future` formulas.

**Mitigation**: Use `asUntil?`/`asSince?` helpers with explicit guard != top check. Place Until/Since rules AFTER G/H/F/P rules in `allRules`. The `isApplicable` function should only return true for genuine Until/Since formulas.

### 9.2 F(U) Decomposition Complexity

**Risk**: The F(U) rule is semantically complex and the branching-persistent hybrid is not directly supported by RuleResult.

**Mitigation**: Handle F(U) by processing one future time at a time. Each application picks the first unprocessed future time and produces a branching result. The source formula is included in BOTH branches (effectively persistent). This means:
- RuleResult.branching [[F(psi) @ t', (source formula)], [F(phi) @ t', F(U(psi,phi)) @ t', (source formula)]]
- Wait -- this doesn't work because branching removes the source formula by default. The expandOnce function does `remaining := b.filter (· != sf)` and then adds new formulas.
- Solution: In the branching result, include the source formula in each branch's formula list. It won't be in `remaining` but will be in the new formulas added to each branch.

### 9.3 Auto-Propagation Interactions

**Risk**: Until/Since rules create fresh times, requiring propagation of T(GA), F(FA), T(HA), F(PA) formulas. They also need to propagate F(U) and F(S) formulas to new times.

**Mitigation**: Follow the same pattern as existing temporal rules. Add Until/Since formula collectors to Branch namespace and include propagation in the rule application.

### 9.4 Compilation Cascades

**Risk**: Adding constructors to `TableauRule` will require updating all match expressions.

**Mitigation**: The only exhaustive matches on `TableauRule` are in `isApplicable` and `applyRule`. Both have a catch-all `| _, _, _ => ...` arm, so adding new constructors only requires adding new match arms before the catch-all.

---

## 10. Summary

The Until/Since tableau rules are the most complex component of the tableau system due to branching decomposition and eventuality tracking. The existing infrastructure (RuleResult.branching, TimeOrdering, Branch helpers) provides a solid foundation. The main implementation work involves:

1. **4 new rule constructors** in TableauRule (untlPos, untlNeg, sncePos, snceNeg)
2. **Decomposition helpers** (asUntil?, asSince?) with guard != top filtering
3. **Branch helpers** for collecting Until/Since formulas (untlPosFormulas, etc.)
4. **Eventuality tracking** data structure (lightweight, for task 237 to build on)
5. **applyRule implementations** following the decomposition rules above
6. **Auto-propagation** of universal formulas to fresh times created by Until/Since rules
7. **Auto-propagation** of F(U)/F(S) to fresh times

The F(U)/F(S) rules are the most complex piece, requiring a "one-future-time-at-a-time" branching approach to work within the existing RuleResult framework.

**Estimated phases**: 3-4 phases
- Phase 1: SignedFormula helpers + Eventuality type
- Phase 2: T(U)/T(S) rules (branching, fresh time, auto-propagation)
- Phase 3: F(U)/F(S) rules (persistent branching, propagation)
- Phase 4: Integration, allRules ordering, testing with BX axioms
