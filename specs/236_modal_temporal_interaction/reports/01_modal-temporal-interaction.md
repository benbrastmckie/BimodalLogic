# Research Report: Cross-Modal-Temporal Tableau Rules (Task 236)

## 1. Executive Summary

This research analyzes the existing tableau implementation and identifies what cross-modal-temporal interaction rules are needed based on the `modal_future` axiom (`box phi -> box(G phi)`) and the derived `temp_future` principle (`box phi -> G(box phi)`). The current tableau handles modal and temporal rules independently -- when creating a new world (via `boxNeg`/`diamondPos`), only modal universal formulas (`T(box A)`, `F(diamond A)`) are propagated; when creating a new time (via `allFutureNeg`, `someFuturePos`, etc.), only temporal universal formulas (`T(GA)`, `F(FA)`, etc.) are propagated. There is no cross-propagation: modal information is not propagated to new times, and temporal information is not propagated to new worlds. This causes the tableau to fail on formulas involving the `modal_future` axiom and its consequences (perpetuity principles P1-P5).

## 2. Current Tableau Architecture

### 2.1 Data Structures

**Labels**: Each signed formula carries a `Label` with `(world : WorldIndex, time : TimeIndex)` (both `Nat`). This two-dimensional labeling is the foundation for cross-modal-temporal reasoning.

**TimeOrdering**: Tracks abstract temporal order via explicit constraint pairs `(a, b)` meaning `a < b`. Supports `futureOf`/`pastOf` queries for finding related time points. Each world has independent temporal structure tracked by this global ordering (since all worlds share the same time dimension in TM semantics).

**Branch**: A `List SignedFormula` with helper functions:
- `knownWorlds` / `nextWorld` -- world management
- `knownTimes` / `nextTime` -- time management  
- `boxPosFormulas` / `diamondNegFormulas` -- modal universal formulas
- `allFuturePosFormulas` / `someFutureNegFormulas` -- temporal-future universal formulas
- `allPastPosFormulas` / `somePastNegFormulas` -- temporal-past universal formulas
- `untlNegFormulas` / `snceNegFormulas` -- Until/Since negative persistent formulas

### 2.2 Existing Rules (26 total)

**Propositional** (8): `andPos`, `andNeg`, `orPos`, `orNeg`, `impPos`, `impNeg`, `negPos`, `negNeg`

**Modal S5** (4): 
- `boxPos` -- T(box A) persistent, propagates T(A) to all known worlds at same time
- `boxNeg` -- F(box A) creates fresh world, propagates T(box B) and F(diamond B) to it
- `diamondPos` -- T(diamond A) creates fresh world, propagates T(box B) and F(diamond B) to it  
- `diamondNeg` -- F(diamond A) persistent, propagates F(A) to all known worlds at same time

**Temporal** (14):
- `allFuturePos`, `allFutureNeg` -- G rules
- `allPastPos`, `allPastNeg` -- H rules
- `someFuturePos`, `someFutureNeg` -- F rules
- `somePastPos`, `somePastNeg` -- P rules
- `untlPos`, `untlNeg` -- Until rules
- `sncePos`, `snceNeg` -- Since rules

### 2.3 The Missing Cross-Propagation

**World creation** (`boxNeg`, `diamondPos`): When a fresh world `w'` is created at time `t`, the code propagates:
- All `T(box B)` formulas as `T(B)` at `(w', t_B)` where `t_B` is the time of each box formula
- All `F(diamond B)` formulas as `F(B)` at `(w', t_B)`

But it does NOT propagate:
- Temporal universal formulas like `T(G A)` at `(w, t)` to `(w', t)` -- new worlds should inherit temporal structure
- `F(F A)` at `(w, t)` to `(w', t)` -- similarly

**Time creation** (`allFutureNeg`, `someFuturePos`, etc.): When a fresh time `t'` is created at world `w`, the code propagates:
- All `T(G A)` formulas at time `t` to `T(A)` at `(w, t')`
- All `F(F A)` formulas at time `t` to `F(A)` at `(w, t')`

But it does NOT propagate:
- Modal universal formulas like `T(box A)` at `(w, t)` to `(w, t')` -- box formulas should persist across times (since they are about necessity at ANY time)
- This is the key insight from `modal_future`: if `box phi` holds at time `t`, then `box(G phi)` also holds, which means `G phi` holds at all worlds, and `phi` holds at all future times in all worlds.

## 3. The modal_future Axiom and Derived Principles

### 3.1 Axiom Definition

From `Axioms.lean` (line 297):
```
| modal_future (phi : Formula) : Axiom ((Formula.box phi).imp (Formula.box (Formula.all_future phi)))
```

This states: `box phi -> box(G phi)` -- if phi is necessarily true, then it is necessarily always going to be true.

### 3.2 Derived Principle: temp_future

From `Combinators.lean` (line 661):
```
def temp_future_derived (phi : Formula) :
    deriv[fc] (Formula.box phi).imp (Formula.all_future (Formula.box phi))
```

This derives: `box phi -> G(box phi)` -- if phi is necessarily true now, then box phi holds at all future times. The derivation chain is:
1. MF at `box phi`: `box(box phi) -> box(G(box phi))` 
2. T at `G(box phi)`: `box(G(box phi)) -> G(box phi)`
3. Chain (1,2): `box(box phi) -> G(box phi)`
4. Modal 4 at `phi`: `box phi -> box(box phi)`
5. Chain (4,3): `box phi -> G(box phi)` = TF

### 3.3 Perpetuity Principles

From `Perpetuity/Helpers.lean`:
- `box_to_future`: `box phi -> G phi` (via MF + T)
- `box_to_past`: `box phi -> H phi` (via temporal duality on box_to_future)
- `box_to_present`: `box phi -> phi` (via T axiom)
- Combined in P1: `box phi -> always phi` where `always phi = H phi /\ phi /\ G phi`

### 3.4 Semantic Interpretation

In TM semantics:
- `box phi` at `(M, tau, t)` means `phi` is true at ALL world histories sigma in Omega at time `t`
- `G phi` at `(M, tau, t)` means `phi` is true at ALL strictly future times `s > t` in the same history
- `box(G phi)` at `(M, tau, t)` means at ALL world histories and ALL strictly future times, phi holds

The modal_future axiom captures the fact that metaphysically necessary truths persist through time: if phi is true in all possible worlds now, it will be true in all possible worlds at all future times.

## 4. Required Cross-Modal-Temporal Rules

### 4.1 Rule: boxTemporalForward (MF-derived)

**Trigger**: `T(box phi)` at label `(w, t)` where there exist future times of `t`

**Action**: For each known future time `t'` of `t` in the TimeOrdering:
- Add `T(box(G phi))` at `(w, t)` -- this is what modal_future directly gives
- But more usefully, since we have T and MF: add `T(G phi)` at `(w, t)` and `T(phi)` at `(w, t')` for each `t' > t`

Actually, the most natural tableau rule combines the semantic consequences:

**Semantic rule**: When `T(box phi)` is on the branch at `(w, t)`:
1. By T axiom: `T(phi)` at `(w, t)` -- already handled by `boxPos` propagation to same world
2. By MF + T: `T(G phi)` at `(w, t)` -- NEW: box implies future
3. By temporal duality on MF + T: `T(H phi)` at `(w, t)` -- NEW: box implies past
4. By S5 universality: all of the above at every world at time `t`

But (2) and (3) are the key new additions. Once we add `T(G phi)` at `(w, t)`, the existing `allFuturePos` rule will propagate `T(phi)` to all known future times. Similarly for `T(H phi)`.

**However**, there is a cleaner approach. Rather than adding derived interaction rules, we should think about what cross-propagation is needed structurally:

### 4.2 Approach A: Direct Cross-Propagation (Recommended)

Add TWO new interaction rules to `TableauRule`:

**Rule `boxToTemporal`**: When `T(box phi)` at `(w, t)`:
- Generate `T(G phi)` at `(w, t)` and `T(H phi)` at `(w, t)` for all known worlds `w`
- This is persistent (like `boxPos`)
- The existing G/H rules then handle further propagation to known times

**Rule `temporalInheritWorld`**: When creating a new world `w'` at time `t` (in `boxNeg`/`diamondPos`):
- Propagate all `T(G phi)` at `(*, t)` to `(w', t)` -- new world inherits G-formulas
- Propagate all `T(H phi)` at `(*, t)` to `(w', t)` -- new world inherits H-formulas
- Propagate all `F(F phi)` at `(*, t)` to `(w', t)` -- new world inherits F-neg-formulas
- Propagate all `F(P phi)` at `(*, t)` to `(w', t)` -- new world inherits P-neg-formulas

### 4.3 Approach B: Augment Existing Rules (Alternative)

Instead of new named rules, augment the existing modal and temporal rules:

1. **Augment `boxNeg`/`diamondPos`**: When creating fresh world `w'` at time `t`, ALSO propagate:
   - All temporal universal formulas at time `t` from any world
   - All `T(G phi)`, `T(H phi)`, `F(F phi)`, `F(P phi)` at `(*, t)`

2. **Augment `allFutureNeg`/`someFuturePos`/etc.**: When creating fresh time `t'` at world `w`, ALSO propagate:
   - All `T(box phi)` at `(w, *)` as `T(box phi)` at `(w, t')` -- boxes persist across time
   - This follows from `box phi -> G(box phi)` (temp_future_derived)

3. **Add new persistent rule**: `T(box phi)` at `(w, t)` generates `T(G phi)` and `T(H phi)` at `(w, t)`:
   - `box phi -> G phi` (via MF + T, = `box_to_future`)
   - `box phi -> H phi` (via temporal duality, = `box_to_past`)

### 4.4 Recommended Approach

**Approach B (augment existing rules)** is recommended because:

1. It avoids adding new `TableauRule` constructors (simpler)
2. It follows the pattern already used for temporal auto-propagation (e.g., `allFutureNeg` already auto-propagates `T(G A)` formulas)
3. The "interaction" is a propagation concern, not a rule decomposition concern

**Specific changes needed**:

1. **New persistent rule `boxTemporal`**: When `T(box phi)` is on the branch at `(w, t)`:
   - Add `T(G phi)` at `(w, t)` if not already present
   - Add `T(H phi)` at `(w, t)` if not already present
   - This rule should be persistent (box formula stays)
   - This is sound because `box phi -> G phi` and `box phi -> H phi` are derivable

2. **Augment `boxNeg`**: After creating fresh world `w'` at time `t`, also propagate:
   - All `T(G A)` at `(*, t)` as `T(G A)` at `(w', t)` -- temporal universals live at all worlds
   - All `T(H A)` at `(*, t)` as `T(H A)` at `(w', t)`
   - All `F(F A)` at `(*, t)` as `F(F A)` at `(w', t)`
   - All `F(P A)` at `(*, t)` as `F(P A)` at `(w', t)`
   - All Until/Since negative formulas at `(*, t)` as copies at `(w', t)`

3. **Augment `diamondPos`**: Same augmentation as `boxNeg` for the fresh world.

4. **Augment temporal existential rules** (`allFutureNeg`, `someFuturePos`, etc.): After creating fresh time `t'` at world `w`, also propagate:
   - All `T(box A)` formulas: since `box phi -> G(box phi)`, box formulas persist to all future times
   - This means adding `T(box A)` at `(w, t')` for each `T(box A)` at `(w, t)` where `t < t'`
   - Similarly `F(diamond A)` at `(w, t')` for each `F(diamond A)` at `(w, t)` (since `F(diamond A)` means `box(neg A)` which also persists)

## 5. Branch Helper Functions Needed

### 5.1 New Collection Functions

```lean
/-- Collect all T(G A) formulas at a specific time (across all worlds). -/
def allFuturePosAtTime (b : Branch) (t : TimeIndex) : List SignedFormula

/-- Collect all T(H A) formulas at a specific time (across all worlds). -/  
def allPastPosAtTime (b : Branch) (t : TimeIndex) : List SignedFormula

/-- Collect all F(F A) formulas at a specific time (across all worlds). -/
def someFutureNegAtTime (b : Branch) (t : TimeIndex) : List SignedFormula

/-- Collect all F(P A) formulas at a specific time (across all worlds). -/
def somePastNegAtTime (b : Branch) (t : TimeIndex) : List SignedFormula

/-- Collect all T(box A) formulas at a specific world. -/
def boxPosAtWorld (b : Branch) (w : WorldIndex) : List SignedFormula
```

### 5.2 Existing Functions to Reuse

The existing `boxPosFormulas`, `diamondNegFormulas`, `allFuturePosFormulas`, `someFutureNegFormulas`, `allPastPosFormulas`, `somePastNegFormulas` already filter by formula type. They just need to be filtered further by time/world where needed.

## 6. Soundness Considerations

### 6.1 boxTemporal Rule Soundness

The `boxTemporal` rule adds `T(G phi)` and `T(H phi)` when `T(box phi)` is present. This is sound because:
- `box phi -> G phi` is derivable via `box_to_future` (MF + T)
- `box phi -> H phi` is derivable via `box_to_past` (temporal duality on box_to_future)
- These are theorems of the base frame class (no frame conditions needed)

### 6.2 Temporal Propagation of Box Formulas

Propagating `T(box phi)` to fresh future times is sound because:
- `box phi -> G(box phi)` is the `temp_future_derived` theorem
- `box phi -> H(box phi)` follows by temporal duality

### 6.3 World Inheritance of Temporal Formulas

Propagating temporal universals to fresh worlds is sound because:
- In S5, all worlds are accessible, so `T(G phi)` at any world at time `t` means `G phi` holds at that world at that time
- Since `box(G phi)` follows from `box phi` (by MF), and box distributes over all worlds, `G phi` holds at ALL worlds
- More generally: temporal facts are world-independent in TM semantics (temporal operators quantify over the time line within a single world history, but necessity at a given time implies temporal persistence across all histories)

**Important caveat**: Not ALL temporal formulas should be blindly propagated across worlds. Only those that follow from box formulas. Specifically:
- `T(G phi)` derived from `T(box phi)` should propagate to new worlds (because `box(G phi)` holds)
- But a "bare" `T(G phi)` that was NOT derived from a box formula should NOT propagate to other worlds (it might only hold in the current world history)

This distinction is important for completeness. The simplest correct approach is: when creating a new world at time `t`, propagate `T(box phi)` (which the existing code already does), and then the `boxTemporal` rule will derive `T(G phi)` and `T(H phi)` at the new world.

## 7. Completeness Considerations

### 7.1 Interaction with Closure Detection

The closure detection (`Closure.lean`) already handles:
- `axiomNeg`: F(axiom) closes a branch via `matchAxiom`
- `matchAxiom` already recognizes `modal_future` at line 365 of `ProofSearch/Core.lean`

So `F(box phi -> box(G phi))` will already close branches via axiom negation detection. The new rules are needed for POSITIVE instances -- when `T(box phi)` is on the branch and we need to derive consequences.

### 7.2 Required for Valid Tableau

Without the cross-modal-temporal rules, the tableau cannot prove formulas like:
- `box p -> G p` (requires deriving T(G p) from T(box p))
- `box p -> always p` (perpetuity P1)
- `box(box p) -> G(box p)` (nested modal-temporal interaction)

The tableau may currently time out on these or leave branches open that should close.

## 8. Implementation Plan Outline

### Phase 1: Add boxTemporal Rule

1. Add `boxTemporal` to `TableauRule` enum
2. Implement `isApplicable` for the new rule
3. Implement `applyRule` for the new rule:
   - `T(box phi)` at `(w, t)` -> persistent result with `T(G phi)` and `T(H phi)` at `(w, t)`
4. Add `boxTemporal` to `allRules` list (after `boxPos`/`boxNeg`)

### Phase 2: Augment World-Creation Rules

1. In `boxNeg`: after creating fresh world, also propagate temporal universal formulas at the same time from any world
2. In `diamondPos`: same augmentation
3. Add helper functions as needed

### Phase 3: Augment Time-Creation Rules  

1. In `allFutureNeg`, `someFuturePos`, `untlPos`, `sncePos` etc.: after creating fresh time, also propagate `T(box A)` and `F(diamond A)` formulas from the same world at times that have ordering relation to the new time
2. This ensures box formulas persist through time creation

### Phase 4: Testing

1. Test `box p -> G p` (should close)
2. Test `box p -> H p` (should close)  
3. Test `box p -> always p` (P1, should close)
4. Test `modal_future` axiom instances (should close)
5. Test `temp_future_derived` instances (should close)
6. Test combined modal/temporal formulas

## 9. Files to Modify

1. **`Tableau.lean`**: Add `boxTemporal` rule, augment `boxNeg`/`diamondPos`/temporal-existential rules
2. **`SignedFormula.lean`**: Add helper collection functions if needed
3. **`Saturation.lean`**: Update integration tests with modal-temporal formulas

## 10. Risks and Mitigations

### Risk: Non-Termination from Cross-Propagation

The `boxTemporal` rule is persistent (generates new formulas without removing the source). Combined with the existing persistent rules, this could cause loops:
- `T(box phi)` -> `T(G phi)` -> propagate to future times -> no new box formulas generated

**Mitigation**: The rule only generates `T(G phi)` and `T(H phi)`, which are already-known formula types. The `isApplicable` check should verify the derived formulas are not already present. The existing pattern of checking `branch.contains` before adding prevents duplicates.

### Risk: Explosion of Propagated Formulas

Cross-propagation could generate many formulas per expansion step, slowing the tableau.

**Mitigation**: The existing auto-propagation patterns (in `boxNeg`, `allFutureNeg`, etc.) already handle this by filtering with `branch.contains`. The same pattern should be applied to cross-propagation.

### Risk: Ordering of Rules Matters

The `boxTemporal` rule must fire BEFORE temporal rules use the `T(G phi)` it generates.

**Mitigation**: Place `boxTemporal` in `allRules` list after modal rules but before temporal rules. Since the expansion loop (`expandOnce`) finds the first unexpanded formula and applies its first applicable rule, the ordering ensures `boxTemporal` fires when `T(box phi)` has new derivable consequences.

## 11. Dependencies and Task Order

- **Task 233** (S5 modal rules): COMPLETED -- prerequisite for correct modal behavior
- **Task 234** (G/H/F/P temporal rules): COMPLETED -- prerequisite for correct temporal behavior
- **Task 236** (this task): Cross-modal-temporal interaction -- builds on 233 and 234
- **Task 237** (blocking/termination): DEPENDS ON 236 -- termination analysis needs all rules present
- **Task 238** (frame-class rules): INDEPENDENT of 236 -- can proceed in parallel
