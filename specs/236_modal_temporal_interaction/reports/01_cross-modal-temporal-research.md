# Task 236: Cross-Modal-Temporal Tableau Rules Research Report

**Session**: sess_1780339480_wq08
**Date**: 2026-06-01

## 1. Current Tableau Architecture

### 1.1 File Layout

The decidability/tableau subsystem comprises six files in `Theories/Bimodal/Metalogic/Decidability/`:

| File | Purpose | Lines (approx) |
|------|---------|----------------|
| `SignedFormula.lean` | `Sign`, `SignedFormula`, `Branch`, `Label`, `TimeOrdering`, `EventualityTracker` | ~687 |
| `Tableau.lean` | `TableauRule` enum, `applyRule`, `expandOnce`, rule priority list | ~793 |
| `Closure.lean` | `ClosureReason`, `findClosure`, axiom-negation detection | ~120 |
| `Saturation.lean` | `expandBranchWithFuel`, `buildTableau`, fuel heuristic | ~189 |
| `ProofExtraction.lean` | Stub: closed branch -> `DerivationTree` (incomplete) | N/A |
| `CountermodelExtraction.lean` | `SimpleCountermodel` from open saturated branch | N/A |
| `DecisionProcedure.lean` | Top-level `decide`, fast-path via proof search | ~268 |

### 1.2 Signed Formula and Labeling

Each signed formula carries a `Label` consisting of a `WorldIndex` (Nat) and `TimeIndex` (Nat). This two-dimensional labeling is fundamental: modal rules manipulate the world index while temporal rules manipulate the time index.

```lean
structure Label : Type where
  world : WorldIndex  -- Nat
  time  : TimeIndex   -- Nat
```

Branches are `List SignedFormula`. The `Branch` namespace provides helpers:
- `knownWorlds` / `knownTimes`: collect distinct indices
- `nextWorld` / `nextTime`: fresh index = max + 1
- `boxPosFormulas` / `diamondNegFormulas`: universal modal formulas for propagation
- `allFuturePosFormulas` / `someFutureNegFormulas`: universal temporal formulas
- `untlNegFormulas` / `snceNegFormulas`: persistent Until/Since formulas

### 1.3 TimeOrdering

Abstract temporal ordering is tracked via `TimeOrdering` -- a list of `(TimeIndex x TimeIndex)` constraints where `(a, b)` means `a < b`. This is used by temporal rules:
- `addFuture t t_new`: records `t < t_new`
- `addPast t t_new`: records `t_new < t`
- `futureOf t`: all times known to be after `t`
- `pastOf t`: all times known to be before `t`

### 1.4 Rule Priority

The `allRules` list defines expansion order:
1. Negation (simplest)
2. Non-branching propositional (`impNeg`, `andPos`, `orNeg`)
3. Modal (`boxPos`, `boxNeg`, `diamondPos`, `diamondNeg`)
4. Temporal G/H (`allFuturePos/Neg`, `allPastPos/Neg`)
5. Temporal F/P (`someFuturePos/Neg`, `somePastPos/Neg`)
6. Until/Since (`untlPos/Neg`, `sncePos/Neg`)
7. Branching propositional (`impPos`, `andNeg`, `orPos`)

### 1.5 Expansion Loop

`expandOnce` finds the first unexpanded formula, applies the first applicable rule, and returns one of:
- `extended newBranch`: non-branching rule applied
- `split branches`: branching rule applied
- `saturated`: no rules apply

`expandBranchWithFuel` iterates this with a fuel counter, checking for closure at each step.

## 2. Existing Modal Rules

### 2.1 T(box phi) -- `boxPos` (Universal/Persistent)

When the branch contains `T(box phi)` at label `(w, t)`:
- For each known world `w'` in the branch, add `T(phi)` at `(w', t)` -- same time, different world
- Result type: `persistent` (source formula kept for propagation to future new worlds)
- Key invariant: S5 universal access -- all worlds are mutually accessible

### 2.2 F(box phi) -- `boxNeg` (Existential)

When the branch contains `F(box phi)` at label `(w, t)`:
- Create fresh world `w_fresh = nextWorld`
- Add `F(phi)` at `(w_fresh, t)` -- witness at new world, same time
- Auto-propagate all `T(box psi)` formulas to `(w_fresh, _)` -- universal modal propagation
- Auto-propagate all `F(diamond psi)` formulas to `(w_fresh, _)`
- Result type: `linear` (source formula consumed)

### 2.3 Key Observation: No Cross-Modal-Temporal Propagation

Currently, when a new world `w_fresh` is created by `boxNeg` or `diamondPos`:
- Universal **modal** formulas (`T(box psi)`) are propagated to the new world
- Universal **temporal** formulas (`T(G psi)`, `F(F psi)`, etc.) are **NOT** propagated to the new world
- This is a gap: the `modal_future` axiom `box phi -> box(G phi)` implies that if `T(box phi)` holds at `(w, t)`, then `T(G phi)` should hold at ALL worlds at time `t`, including newly created ones

Similarly, when a new time `t_fresh` is created by temporal existential rules:
- Universal **temporal** formulas are propagated to the new time
- Universal **modal** formulas (`T(box psi)`) are **NOT** propagated to the new time
- The `temp_future_derived` theorem `box phi -> G(box phi)` implies `T(box phi)` at `(w, t)` should propagate `T(box phi)` to `(w, t_fresh)` for all future `t_fresh`

## 3. Existing Temporal Rules

### 3.1 Universal Temporal Rules (Persistent)

- `allFuturePos`: T(G phi) at (w,t) propagates T(phi) to all known future times of t (via TimeOrdering.futureOf)
- `allPastPos`: T(H phi) at (w,t) propagates T(phi) to all known past times of t
- `someFutureNeg`: F(F phi) at (w,t) propagates F(phi) to all known future times (universal by duality)
- `somePastNeg`: F(P phi) at (w,t) propagates F(phi) to all known past times

### 3.2 Existential Temporal Rules (Consumable)

- `allFutureNeg`: F(G phi) at (w,t) creates fresh `t_fresh > t`, adds F(phi) at (w, t_fresh), auto-propagates T(G psi) and F(F psi) from time t
- `allPastNeg`: F(H phi) at (w,t) creates fresh `t_fresh < t`, adds F(phi) at (w, t_fresh), auto-propagates T(H psi) and F(P psi) from time t
- `someFuturePos`: T(F phi) at (w,t) creates fresh `t_fresh > t`, adds T(phi) at (w, t_fresh), auto-propagates universals
- `somePastPos`: T(P phi) at (w,t) creates fresh `t_fresh < t`, adds T(phi) at (w, t_fresh), auto-propagates universals
- `untlPos`/`sncePos`: Branching with fresh time creation + auto-propagation of universals and persistent Until/Since negations

### 3.3 Key Observation: No Cross-Temporal-Modal Propagation

When a new time `t_fresh` is created:
- T(G psi) / F(F psi) / F(U(...)) are propagated (temporal universals)
- T(box psi) is **NOT** propagated from old times to the new time
- This means the tableau may miss that `box phi` persists through time

## 4. The Modal-Future Axiom and Its Tableau Implications

### 4.1 Axiom Statement

```lean
| modal_future (phi : Formula) : Axiom ((Formula.box phi).imp (Formula.box (Formula.all_future phi)))
```

Semantically: `box phi -> box(G phi)` -- "what is necessary is necessarily always going to be true."

### 4.2 Derived Principle: TF (temp_future_derived)

From MF + T + Modal 4, the codebase derives:
```
box phi -> G(box phi)    -- necessary truths will always be necessary
```

This is proved in `Combinators.lean` at line 661:
1. MF at `box phi`: `box(box phi) -> box(G(box phi))`
2. T at `G(box phi)`: `box(G(box phi)) -> G(box phi)`
3. Modal 4: `box phi -> box(box phi)`
4. Chain: `box phi -> G(box phi)`

By temporal duality, `box phi -> H(box phi)` also holds.

### 4.3 Combined Perpetuity

From P1 (perpetuity_1): `box phi -> always phi` = `box phi -> H phi AND phi AND G phi`

From P3 (perpetuity_3): `box phi -> box(always phi)` -- necessity of perpetuity.

### 4.4 Tableau Rules Needed

The MF axiom and its derived consequences create four cross-modal-temporal propagation obligations:

**Rule CMT1: T(box phi) propagation to future times**
- When T(box phi) holds at (w, t) and t' is a known future time of t:
  - Add T(box phi) at (w, t') -- boxed truths persist forward
  - This implements `box phi -> G(box phi)` (TF derived)

**Rule CMT2: T(box phi) propagation to past times**
- When T(box phi) holds at (w, t) and t' is a known past time of t:
  - Add T(box phi) at (w, t') -- boxed truths persist backward
  - This implements `box phi -> H(box phi)` (TF dual)

**Rule CMT3: T(box phi) at new world inherits temporal structure**
- When a new world w_fresh is created at time t:
  - For all T(G psi) at (w_old, t): add T(G psi) at (w_fresh, t)
  - For all T(H psi) at (w_old, t): add T(H psi) at (w_fresh, t)
  - This inherits the temporal neighborhood at the new world

  **Note**: This is partially implied by the MF axiom path:
  - T(box phi) at (w, t) gives T(G phi) at ALL worlds at t (via boxPos)
  - But the current boxNeg/diamondPos auto-propagation only propagates T(box psi), not T(G psi)

**Rule CMT4: T(box phi) at new time inherits modal structure**
- When a new time t_fresh is created for world w:
  - For all T(box psi) at (w, t_old): add T(box psi) at (w, t_fresh) if t_fresh is temporally related to t_old
  - This ensures boxed truths propagate to newly created times

### 4.5 Core Propagation: T(box phi) -> T(G phi)

The most fundamental cross-modal-temporal rule is:

**From T(box phi) at (w, t), derive T(G phi) at (w, t)**

This directly implements the MF axiom `box phi -> box(G phi)` combined with T axiom `box(G phi) -> G phi`. The effect is:
- T(box phi) at (w, t) yields T(G phi) at (w, t)
- The existing allFuturePos rule then propagates T(phi) to all known future times
- This creates a chain: T(box phi) -> T(G phi) -> T(phi) at all future times

Similarly, by the derived past dual:
- T(box phi) at (w, t) yields T(H phi) at (w, t)
- The existing allPastPos rule then propagates T(phi) to all known past times

## 5. Where Cross-Modal-Temporal Rules Should Be Integrated

### 5.1 Option A: Derive During Expansion (Eager)

Add T(G phi) and T(H phi) as immediate consequences of T(box phi) during the `boxPos` rule or as a separate rule triggered by T(box phi).

**Implementation**: Add a new rule `crossModalTemporal` to `TableauRule`:
```lean
| crossModalTemporal  -- T(box phi) -> T(G phi), T(H phi), T(phi)
```

When applied to T(box phi) at (w, t):
- Add T(G phi) at (w, t)
- Add T(H phi) at (w, t)
- Add T(phi) at (w, t) -- from modal_t

These derived formulas then participate in normal temporal propagation.

**Pros**: Clean separation of concerns. Each rule has single responsibility.
**Cons**: Adds formula proliferation. T(box phi) generates T(G phi) and T(H phi), which then generate more propagations.

### 5.2 Option B: Enhance Auto-Propagation (Implicit)

Enhance the existing world-creation and time-creation auto-propagation code to handle cross-modal-temporal interactions.

**For world creation** (boxNeg, diamondPos):
Add auto-propagation of T(G psi), T(H psi), F(F psi), F(P psi) to new worlds.

**For time creation** (allFutureNeg, allPastNeg, someFuturePos, somePastPos, untlPos, sncePos):
Add auto-propagation of T(box psi) to new times when appropriate.

**Pros**: Keeps auto-propagation centralized with world/time creation.
**Cons**: Mixes concerns; harder to reason about completeness.

### 5.3 Option C: Combined Approach (Recommended)

**Phase 1**: Add a new `crossModalTemporal` rule that derives T(G phi) and T(H phi) from T(box phi). Place it in `allRules` after modal rules but before temporal rules.

**Phase 2**: Enhance time-creation auto-propagation to also propagate T(box psi) formulas from the source time to the new time (when the source time has T(box psi) and the new time is in the correct temporal relation).

**Phase 3**: Enhance world-creation auto-propagation to also propagate universal temporal formulas (T(G psi), T(H psi), F(F psi), F(P psi)) to new worlds at the same time.

### 5.4 Where in Code

1. **New rule enum**: `TableauRule.crossModalTemporal` in Tableau.lean line ~115 (after `snceNeg`)

2. **isApplicable**: Add case for `crossModalTemporal` checking `sf.sign == .pos && sf.formula matches .box _`

3. **applyRule**: Add case that produces `T(G phi)` and `T(H phi)` from `T(box phi)`, plus `T(phi)` from modal_t. Must check that these are not already on the branch to avoid infinite loops.

4. **allRules**: Insert after `.diamondNeg` and before `.allFuturePos` (line ~701)

5. **Auto-propagation enhancements**:
   - `boxNeg`/`diamondPos` (lines ~337-380): Add propagation of `allFuturePosFormulas`, `allPastPosFormulas`, `someFutureNegFormulas`, `somePastNegFormulas`
   - `allFutureNeg`/`allPastNeg` (lines ~401-467): Add propagation of `boxPosFormulas`
   - `someFuturePos`/`somePastPos` (lines ~468-551): Add propagation of `boxPosFormulas`
   - `untlPos`/`sncePos` (lines ~556-635): Add propagation of `boxPosFormulas`

6. **Branch helpers** (SignedFormula.lean): May need new helper methods like `crossModalFormulas` to collect T(box psi) that should generate temporal universals.

## 6. Specific Technical Approach for T(box phi) -> T(G phi) Propagation

### 6.1 New TableauRule Constructor

```lean
inductive TableauRule : Type where
  ...
  | crossModalTemporal  -- T(box phi) -> T(G phi) + T(H phi) + T(phi)
```

### 6.2 Rule Semantics

The `crossModalTemporal` rule applies to `T(box phi)` at `(w, t)` and produces:

```
T(G phi) at (w, t)     -- from box phi -> G phi (box_to_future)
T(H phi) at (w, t)     -- from box phi -> H phi (box_to_past)
T(phi) at (w, t)       -- from box phi -> phi (modal_t)
```

This should be a `persistent` result (the source T(box phi) is kept) because:
1. boxPos already keeps T(box phi) persistent
2. The cross-modal rule should only fire once per T(box phi) formula
3. But the derived T(G phi) and T(H phi) need to participate in future propagation

**Avoiding infinite loops**: The rule should check whether T(G phi) and T(H phi) are already on the branch. If all three derived formulas already exist, return `notApplicable`.

### 6.3 Implementation Sketch

```lean
| .crossModalTemporal, .pos, .box phi =>
    let l := sf.label
    let gPhi := SignedFormula.pos phi.all_future l
    let hPhi := SignedFormula.pos phi.all_past l
    let phiHere := SignedFormula.pos phi l
    let newFormulas := [gPhi, hPhi, phiHere].filter (!branch.contains ·)
    if newFormulas.isEmpty then (.notApplicable, timeOrd)
    else (.persistent newFormulas, timeOrd)
```

### 6.4 Priority Placement

Place `crossModalTemporal` after modal rules but before temporal rules in `allRules`:
```lean
def allRules : List TableauRule := [
  .negPos, .negNeg,
  .impNeg,
  .andPos, .orNeg,
  .boxPos, .boxNeg,
  .diamondPos, .diamondNeg,
  .crossModalTemporal,         -- NEW: cross-modal-temporal
  .allFuturePos, .allFutureNeg,
  ...
]
```

This ensures that after T(box phi) is propagated to all worlds (boxPos), the cross-modal rule fires to derive temporal consequences before temporal rules process them.

## 7. World-Creation and Time-Creation Interaction Consistency

### 7.1 World Creation (boxNeg/diamondPos)

**Current behavior**: When fresh world `w_fresh` is created at time `t`:
- T(box psi) formulas propagate T(psi) to (w_fresh, t) -- for all times where the T(box psi) lives
- F(diamond psi) formulas propagate F(psi) to (w_fresh, t)

**Missing**: Temporal universals at (w_old, t) should also propagate to (w_fresh, t):
- T(G psi) at (w_old, t) should yield T(G psi) at (w_fresh, t) -- because box(G psi) holds (from MF + boxPos)
- T(H psi) at (w_old, t) should yield T(H psi) at (w_fresh, t)
- F(F psi) at (w_old, t) should yield F(F psi) at (w_fresh, t)
- F(P psi) at (w_old, t) should yield F(P psi) at (w_fresh, t)

**Justification**: If T(box phi) is on the branch, then by boxPos, T(phi) holds at all worlds. By crossModalTemporal, T(G phi) holds wherever T(box phi) holds. By boxPos again, T(G phi) holds at all worlds including w_fresh.

**However**, this propagation is actually handled by the two-step chain:
1. crossModalTemporal derives T(G phi) from T(box phi) at (w, t)
2. boxPos (applied to T(box(G phi)) from MF axiom pattern) would propagate T(G phi) to all worlds

The question is whether the current boxPos already covers this, or whether explicit propagation is needed. The answer: **currently it does NOT**, because:
- boxPos propagates T(phi) from T(box phi) -- it does not generate T(box(G phi)) from T(box phi)
- The MF axiom is only in matchAxiom (proof search), not in tableau expansion
- We need either: (a) explicit T(G phi) propagation to new worlds, or (b) ensure crossModalTemporal fires before world creation propagation catches up

**Recommended approach**: Enhance world-creation auto-propagation to include temporal universals. This is simpler and more complete than relying on iterative rule application.

### 7.2 Time Creation (allFutureNeg/allPastNeg/someFuturePos/somePastPos/untlPos/sncePos)

**Current behavior**: When fresh time `t_fresh` is created for world `w`:
- T(G psi) at (w, t_old) propagates T(psi) to (w, t_fresh) if t_fresh is future of t_old
- T(H psi) at (w, t_old) propagates T(psi) to (w, t_fresh) if t_fresh is past of t_old
- F(F psi) at (w, t_old) propagates F(psi) to (w, t_fresh) if t_fresh is future of t_old
- F(P psi) at (w, t_old) propagates F(psi) to (w, t_fresh) if t_fresh is past of t_old
- F(U(e,g)) and F(S(e,g)) are propagated similarly

**Missing**: T(box psi) at (w, t_old) should propagate to (w, t_fresh):
- T(box psi) at (w, t) and t_fresh future of t: add T(box psi) at (w, t_fresh)
  - Justification: box phi -> G(box phi) (TF derived), so T(box phi) at t implies T(box phi) at all future times
- T(box psi) at (w, t) and t_fresh past of t: add T(box psi) at (w, t_fresh)
  - Justification: box phi -> H(box phi) (TF dual), so T(box phi) at t implies T(box phi) at all past times

**Critical**: Box formulas must propagate to ALL new times (both future and past), because `box phi -> always(box phi)` (from P3 perpetuity_3).

**Recommended approach**: In each time-creation case of `applyRule`, add auto-propagation of `boxPosFormulas` to the new time. This requires:

```lean
-- Auto-propagate all T(box B) formulas to freshTime
let boxProps := branch.boxPosFormulas.filterMap fun bsf =>
  if bsf.label.time == l.time && bsf.label.world == l.world then
    let prop := SignedFormula.pos bsf.formula { world := l.world, time := freshTime }
    if branch.contains prop then none else some prop
  else none
```

And similarly for F(diamond psi) formulas (`diamondNegFormulas`).

### 7.3 Consistency Requirements

For the tableau to be sound and complete with cross-modal-temporal rules:

1. **Soundness**: Every propagation must be justified by a valid axiom/theorem
   - T(box phi) -> T(G phi): justified by `box_to_future` (MF + T)
   - T(box phi) -> T(H phi): justified by `box_to_past` (MF dual + T)
   - T(box phi) temporal persistence: justified by `temp_future_derived` (TF) and its dual
   - Temporal universals at new worlds: justified by boxPos + crossModalTemporal chain

2. **Completeness**: No derivable formula should be missing from saturated branches
   - If T(box phi) is on the branch, T(G phi) and T(H phi) must also be present
   - If T(box phi) is on the branch at (w, t), it must be present at all times
   - New worlds must inherit all temporal universals from the source time

3. **Termination**: Cross-modal-temporal rules must not cause infinite expansion
   - crossModalTemporal is persistent but guards against redundancy (check branch.contains)
   - Box propagation to new times is bounded by the subformula closure
   - The total number of distinct (formula, label) pairs is bounded by |sf_closure| * |worlds| * |times|

4. **No new-world/new-time cascading**: Creating a new world should not trigger creation of a new time, and vice versa. The cross-modal-temporal rules only ADD formulas at existing labels; they do not create new worlds or times.

## 8. Summary of Implementation Approach

### Phase 1: crossModalTemporal Rule
- Add `crossModalTemporal` to `TableauRule`
- Implement in `isApplicable` and `applyRule`
- Derives T(G phi), T(H phi), T(phi) from T(box phi)
- Persistent result with redundancy guard
- Place in `allRules` after modal rules, before temporal rules

### Phase 2: Time-Creation Box Propagation
- In `allFutureNeg`, `allPastNeg`, `someFuturePos`, `somePastPos`, `untlPos`, `sncePos`:
  - Add auto-propagation of T(box psi) formulas to the new time
  - Add auto-propagation of F(diamond psi) formulas to the new time (dual)
  - World stays the same; only time changes

### Phase 3: World-Creation Temporal Propagation
- In `boxNeg`, `diamondPos`:
  - Add auto-propagation of T(G psi), T(H psi) formulas to the new world
  - Add auto-propagation of F(F psi), F(P psi) formulas to the new world
  - Time stays the same; only world changes

### Phase 4: Testing
- Test against `modal_future` axiom instance: `box p -> box(G p)` should be valid
- Test against `temp_future_derived` instance: `box p -> G(box p)` should be valid
- Test against perpetuity P1: `box p -> H p AND p AND G p` should be valid
- Test combined formulas: `box(G p) -> G(box(G p))`, `diamond(F p) -> F(diamond p)`, etc.
- Test invalid formulas are still correctly identified as invalid

### Estimated Effort
- Phase 1: 1-2 hours (new rule enum + apply logic)
- Phase 2: 2-3 hours (6 time-creation rules to update)
- Phase 3: 1 hour (2 world-creation rules to update)
- Phase 4: 1 hour (test formulas)
- Total: 5-7 hours

### Dependencies
- Tasks 233, 234 (basic tableau correctness) are listed as dependencies but do not exist in state.json
- The implementation is self-contained within the Decidability/ directory
- No changes needed to Formula.lean, Axioms.lean, or Semantics/

## 9. Risks and Mitigations

1. **Termination risk**: Additional propagations increase branch size. Mitigation: all propagated formulas are in the subformula closure, and redundancy guards prevent duplicates.

2. **Performance risk**: Cross-modal-temporal rules add more formulas per expansion step. Mitigation: the crossModalTemporal rule is relatively cheap (3 formulas per T(box phi)), and auto-propagation is guarded by `branch.contains`.

3. **Soundness risk**: Incorrect propagation could allow closing branches that should remain open. Mitigation: each propagation is directly justified by a proved axiom/theorem in the proof system.

4. **Dependency risk**: Tasks 233 and 234 are listed as dependencies but don't exist. Mitigation: the cross-modal-temporal rules are orthogonal to basic tableau correctness; they can be implemented independently.
