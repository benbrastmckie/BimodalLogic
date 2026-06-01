# Research Report: Tableau Termination via Subset Blocking

**Task**: 237 -- Implement blocking strategy ensuring tableau expansion terminates for all formulas
**Session**: sess_1780339480_ozo
**Date**: 2026-06-01

---

## 1. Current Tableau Architecture

### 1.1 Core Data Structures

The tableau implementation lives in `Theories/Bimodal/Metalogic/Decidability/` with four key modules:

| Module | File | Purpose |
|--------|------|---------|
| SignedFormula | `SignedFormula.lean` | Labels (world/time indices), signed formulas, branches, eventuality tracking, subformula closure |
| Tableau | `Tableau.lean` | Rule definitions (`TableauRule`), rule application (`applyRule`), single-step expansion (`expandOnce`) |
| Closure | `Closure.lean` | Branch closure detection (contradiction, botPos, axiomNeg) with monotonicity proofs |
| Saturation | `Saturation.lean` | Fuel-based expansion (`expandBranchWithFuel`), `buildTableau`, `recommendedFuel` |

### 1.2 Expansion Pipeline

The tableau starts with `F(phi)` at `Label.initial = (world=0, time=0)` and expands via:

```
buildTableau phi fuel
  -> expandBranchWithFuel initialBranch fuel
       -> findClosure (check closed)
       -> expandOnce (find unexpanded formula, apply rule)
            -> linear: remove source, add results
            -> branching: remove source, fork into sub-branches
            -> persistent: keep source, add propagations
       -> recurse (fuel - 1)
```

The expansion loop decrements a `fuel : Nat` counter and returns `none` when fuel reaches 0.

### 1.3 Rule Categories

Rules are classified by their structural behavior:

**Non-branching (linear)**: `andPos`, `orNeg`, `impNeg`, `negPos`, `negNeg` -- decompose a compound formula into sub-components on the same branch. The source formula is removed.

**Branching**: `andNeg`, `orPos`, `impPos` -- split into 2 sub-branches. Source removed.

**Persistent (universal modal/temporal)**: `boxPos`, `diamondNeg`, `allFuturePos`, `allPastPos`, `someFutureNeg`, `somePastNeg` -- propagate to all known worlds/times. Source formula is KEPT in the branch (may fire again when new worlds/times are introduced).

**Existential (world/time creating)**: `boxNeg`, `diamondPos`, `allFutureNeg`, `allPastNeg`, `someFuturePos`, `somePastPos` -- introduce a FRESH world or time index. Source is consumed.

**Until/Since positive (existential + branching)**: `untlPos`, `sncePos` -- create fresh time AND branch. Source is consumed, but the "guard + continue" branch re-introduces the Until/Since formula at the new time.

**Until/Since negative (persistent + branching)**: `untlNeg`, `snceNeg` -- decompose at known future/past times via Reynolds co-decomposition. Source re-included for persistence.

### 1.4 Current Fuel Heuristic

```lean
def recommendedFuel (phi : Formula) : Nat :=
  10 * phi.complexity + 100
```

This is acknowledged as ad hoc (the docstring says "heuristic upper bound"). For a formula with complexity `c`, fuel is `10c + 100`. The constant factor 10 and offset 100 have no theoretical justification.

**Problems with the current approach**:
1. **Unsound for large formulas**: A formula with deep Until nesting can generate exponentially many time points, exhausting fuel and returning `timeout` (which is treated as `none` / inconclusive).
2. **Overly generous for simple formulas**: Simple propositional formulas need far less than `10c + 100` steps.
3. **No blocking**: The expansion never checks whether a newly created time/world is "redundant" relative to an ancestor. This means Until formulas can indefinitely defer their eventuality, creating an infinite sequence of fresh time points.

### 1.5 Existing Eventuality Infrastructure

The `Eventuality` and `EventualityTracker` types are already defined in `SignedFormula.lean`:

```lean
structure Eventuality where
  formula : Formula
  label : Label
  isUntil : Bool

structure EventualityTracker where
  pending : List Eventuality
```

These types exist but are **currently unused** -- no code in Tableau.lean or Saturation.lean references `EventualityTracker`. The `Eventuality` structure's docstring explicitly references task 237: "Blocking logic (task 237) uses this to detect infinite deferral."

### 1.6 Subformula Closure

Two independent subformula closure computations exist:

1. **`Syntax.subformulaClosure`** (in `Syntax/SubformulaClosure/Closure.lean`): Finset-based, used by FMP. Includes membership lemmas, `closureWithNeg`, cardinality bounds.

2. **`Decidability.subformulaClosure`** (in `SignedFormula.lean`): List-based, duplicated for the tableau module. Computes `(b.flatMap sf.formula.subformulas).eraseDups` and signed versions thereof.

The Finset-based version is the one with proved cardinality bounds. The FMP module proves `closure_mcs_card_bound`: `|closureWithNeg phi| <= 2 * |subformulaClosure phi|`.

---

## 2. Why the Tableau Does Not Terminate

### 2.1 The Core Non-Termination Pattern

The non-termination arises from **Until/Since eventuality deferral**. Consider `T(U(event, guard))` at time `t`:

```
T(U(event, guard)) @ (w, t)
  -> Branch 1: T(event) @ (w, t')          [event witnessed]
  -> Branch 2: T(guard) @ (w, t'),          [guard continues]
               T(U(event, guard)) @ (w, t') [Until re-introduced at t']
```

Branch 2 re-introduces the SAME Until formula at a fresh time `t'`. When this formula is subsequently expanded, it creates another fresh time `t''`, and so on. Without blocking, this produces an infinite chain:

```
t -> t' -> t'' -> t''' -> ...
each with T(U(event, guard))
```

The guard branch is always chosen (since the event branch might close from other constraints), creating an unbounded sequence of fresh time points.

### 2.2 Modal Dimension

The S5 modal rules (`boxNeg`, `diamondPos`) also create fresh worlds. However, because S5 has the universal accessibility property, modal saturation is naturally bounded: once all box/diamond formulas from the closure are propagated to all known worlds, no new information can be gained by creating additional worlds. The number of worlds needed is bounded by the number of box/diamond subformulas.

The temporal dimension is harder because time is linearly ordered and Until/Since create directional obligations that propagate along the timeline.

---

## 3. FMP-Derived Size Bound

### 3.1 The Finite Model Property

The FMP module proves that if a formula is satisfiable, it is satisfiable in a finite model. The key theorems:

- `filtered_world_bound`: The number of worlds <= `2^|subformulaClosure phi|`
- `closure_mcs_card_bound`: `|closureWithNeg phi| <= 2 * |subformulaClosure phi|`
- `FilteredWorld.finite`: The filtered world type is finite (injective characteristic set)

### 3.2 Computing the Bound

For a formula `phi`:
- Let `n = |subformulaClosure phi|` = number of distinct subformulas
- The filtered model has at most `2^n` worlds
- Each world is characterized by its subset of the closure

For the tableau, a time/world point is characterized by the set of signed formulas it contains. Since all formulas in the tableau are from the signed subformula closure (which has `2n` elements -- each subformula with both positive and negative sign), there are at most `2^(2n)` distinct time/world "types".

### 3.3 Connecting FMP Bound to Tableau Fuel

The FMP tells us:
- **Worlds**: At most `2^n` distinct S5-equivalence classes (where `n = |subformulaClosure phi|`)
- **Times**: Along any branch of the linear temporal order, at most `2^(2n)` distinct time-types before one must repeat

Thus, a **sound fuel bound** should be:

```
soundFuel(phi) = 2^(2n) * (number of rules per step) * (propagation overhead)
```

In practice, this is astronomically large. A more practical approach uses the **blocking strategy** described below, which achieves termination structurally rather than through a large fuel counter.

---

## 4. Subset Blocking Strategy

### 4.1 Theory of Subset Blocking

Subset blocking is a standard technique for ensuring termination of tableau-based decision procedures for modal and temporal logics (Horrocks 1997, Goranko et al. 2006).

**Key idea**: When creating a new time point `t'` that is an extension of time `t`, compute the "type" of `t'` -- the set of signed formulas that hold at `t'`. If this type is a **subset** of the type at some ancestor time point `t_anc` on the same branch, then the new point `t'` is "blocked" by `t_anc`.

**Definition**: Let `type(t) = {sf in branch | sf.label.time = t}` be the set of signed formulas at time `t`. Time `t'` is **subset-blocked by** `t_anc` if `type(t') ⊆ type(t_anc)`.

**Semantics**: If every formula at `t'` already holds at `t_anc`, then any model satisfying the branch can "loop back" from `t'` to `t_anc` without losing any constraints. Since S5 modal logic is symmetric, the worlds accessible from `t'` are the same as those accessible from `t_anc`.

### 4.2 Why Subset (Not Equality) Blocking

**Equality blocking** would check `type(t') = type(t_anc)`. This is sound but can miss blocking opportunities where a simpler point is subsumed by a richer ancestor. Subset blocking is more aggressive:

- If `type(t') ⊆ type(t_anc)`, all constraints at `t'` are already satisfied at `t_anc`
- The "extra" formulas at `t_anc` are irrelevant -- they provide additional truth but no additional obligations
- This catches more loops, leading to earlier termination

For TM bimodal logic specifically, subset blocking is appropriate because:
1. The temporal order is linear (each time has at most one successor/predecessor direction)
2. Modal S5 is fully symmetric (no directional constraints on world accessibility)
3. Until/Since have the subformula property (all generated formulas are from the closure)

### 4.3 Adaptation for Bimodal TM

The blocking check must be adapted for the two-dimensional (time x world) labeling:

**Temporal blocking**: Check subset relationship along the temporal dimension (same world, ancestor time).

```
isTemporallyBlocked(t', branch) :=
  exists t_anc in ancestors(t', branch) such that
    formulasAtTime(branch, t') ⊆ formulasAtTime(branch, t_anc)
```

**Modal blocking**: For S5, modal blocking is less critical (worlds are symmetric). However, checking for duplicate world types can still improve efficiency.

**Cross-modal-temporal blocking**: The full check should compare the complete label type:

```
type(w, t) = {sf.formula | sf in branch, sf.label = (w, t)}
```

But for practical purposes, temporal blocking is the critical dimension (modal expansion is naturally bounded in S5).

### 4.4 Eventuality Checking

Blocking must be compatible with eventualities. If `T(U(event, guard))` is pending (the event has not been witnessed), blocking must not prematurely close a branch that still has unfulfilled eventualities.

**Strategy**: Use the `EventualityTracker` already defined in `SignedFormula.lean`:

1. When `untlPos`/`sncePos` fires, register an eventuality for the event component
2. When the event is witnessed (appears as `T(event)` at a reachable time), mark the eventuality as fulfilled
3. When checking blocking: a time `t'` can be blocked by ancestor `t_anc` **only if** all pending eventualities at `t'` are also pending (or fulfilled) at `t_anc`

The subset condition `type(t') ⊆ type(t_anc)` already ensures that any pending Until formula at `t'` is also present at `t_anc`, so the eventuality obligation is inherited by the ancestor. This makes subset blocking automatically eventuality-safe: if the Until formula was going to be fulfilled from `t_anc`, it will be fulfilled from `t'` as well (since `t_anc` has at least the same obligations).

### 4.5 Termination Argument

**Claim**: With subset blocking, every branch of the tableau is finite.

**Proof sketch**:
1. All formulas in the branch are from the signed subformula closure of `phi`, which has `2 * |subformulaClosure phi|` elements.
2. Each time point is characterized by its subset of these formulas. There are at most `2^(2n)` distinct subsets.
3. Along any linearly ordered chain of time points, once a subset repeats (or is subsumed), blocking fires.
4. Therefore, the length of any temporal chain is bounded by `2^(2n)`.
5. At each time, the number of worlds is bounded by the number of box/diamond subformulas (S5 saturation).
6. Therefore, the total number of labels on any branch is bounded.

This gives a worst-case complexity that is doubly exponential in the closure size, which matches the known EXPSPACE complexity of bimodal temporal-S5 logics.

---

## 5. Completeness Preservation

### 5.1 Blocking Preserves Completeness

**Claim**: If a formula is satisfiable (has a model), the blocked tableau still produces an open branch.

**Argument**: The blocking check prevents expansion of a blocked time, but the open branch up to the blocked point still describes a satisfiable set of formulas. The key insight is:

1. If `type(t') ⊆ type(t_anc)`, then any model satisfying `type(t_anc)` also satisfies `type(t')` (by monotonicity -- a larger type contains all the required truth values).
2. The FMP guarantees that satisfiable formulas have finite models. In a finite model, the temporal trace eventually loops. Subset blocking detects this loop.
3. Therefore, the blocked open branch corresponds to a finite model fragment that can be "unrolled" into a full model.

### 5.2 Formal Connection to FMP

The FMP provides the theoretical justification:
- If `phi` is satisfiable, there exists a finite model `M` with at most `2^n` worlds (by filtration).
- In `M`, the temporal trace visits at most `2^(2n)` distinct types.
- The tableau expansion with blocking explores at most this many types per temporal chain.
- Therefore, the tableau will saturate (find an open branch) before blocking can falsely close it.

### 5.3 What Would Need to be Proved

To formally prove blocking preserves completeness in Lean, one would need:

1. **Subformula property**: All formulas generated by tableau rules are from the signed subformula closure. This follows from the structure of rule definitions in `Tableau.lean` (each rule produces subformulas of the decomposed formula).

2. **Blocking soundness**: If `type(t') ⊆ type(t_anc)`, then any model satisfying the branch with the blocked extension also satisfies the branch with `t'` replaced by a "loop" to `t_anc`.

3. **Eventuality compatibility**: Pending eventualities are correctly handled through the subset relationship.

4. **Completeness**: If no blocking fires, the branch either closes or saturates in finitely many steps.

Items 1 and 4 are essentially the current subformula closure theory and rule exhaustion. Items 2 and 3 require new proofs connecting the blocking condition to model theory.

---

## 6. Implementation Plan Sketch

### Phase 1: Time-Type Computation and Blocking Predicate

Add to `SignedFormula.lean`:

```lean
/-- Signed formulas at a specific time on a branch. -/
def formulasAtTime (b : Branch) (t : TimeIndex) : List SignedFormula :=
  b.filter (fun sf => sf.label.time == t)

/-- The "type" of a time point: set of formulas (ignoring label). -/
def timeType (b : Branch) (t : TimeIndex) : List Formula :=
  (formulasAtTime b t).map (fun sf => sf.formula) |>.eraseDups

/-- Check if t' is subset-blocked by t_anc. -/
def isSubsetBlocked (b : Branch) (t' t_anc : TimeIndex) : Bool :=
  (timeType b t').all (fun f => (timeType b t_anc).contains f)
```

### Phase 2: Integrate Blocking into Expansion

Modify `expandBranchWithFuel` in `Saturation.lean` to check blocking before expanding:

```lean
def expandBranchWithFuel (b : Branch) (fuel : Nat)
    (timeOrd : TimeOrdering := TimeOrdering.empty)
    (ancestorTimes : List TimeIndex := [0]) : ... :=
  match fuel with
  | 0 => none
  | fuel + 1 =>
      match findClosure b with
      | some reason => some (.inl ⟨b, reason⟩)
      | none =>
          -- Check blocking before expansion
          let currentTime := b.maxTime
          let blocked := ancestorTimes.any (fun t_anc =>
            isSubsetBlocked b currentTime t_anc)
          if blocked then
            some (.inr b)  -- Treat blocked branch as saturated
          else
            match expandOnce b timeOrd with
            | ...
```

### Phase 3: Sound Fuel Bound from Closure Size

Replace `recommendedFuel` with an FMP-derived bound:

```lean
/-- Sound fuel bound derived from FMP. -/
def soundFuel (phi : Formula) : Nat :=
  let n := (subformulaClosure phi).length  -- Finset.card
  let maxTypes := 2 ^ (2 * n)  -- max distinct time types
  let maxWorlds := n + 1  -- rough bound on modal worlds
  let rulesPerStep := allRules.length  -- 24 rules
  maxTypes * maxWorlds * rulesPerStep
```

Note: This will be very large for non-trivial formulas. In practice, the blocking mechanism makes the fuel bound irrelevant for most inputs, since blocking fires long before the bound is reached. The fuel remains as a safety net.

### Phase 4: Eventuality Integration

Wire the `EventualityTracker` into the expansion pipeline:

1. When `untlPos`/`sncePos` fires, register the event component as a pending eventuality
2. When `T(event)` appears on the branch at a reachable time, mark it fulfilled
3. In the blocking check, verify that blocked branches have no unfulfilled eventualities that the ancestor does not also have

### Phase 5: Correctness Arguments

Prove or state as `theorem` stubs:
1. `subformula_property`: All rule outputs are from the closure
2. `blocking_sound`: Subset blocking does not prematurely close satisfiable branches
3. `blocking_terminates`: With blocking, every branch is finite
4. `blocking_preserves_completeness`: If `phi` is satisfiable, the blocked tableau has an open branch

---

## 7. Key Codebase References

| File | Key Definitions | Relevance |
|------|-----------------|-----------|
| `Decidability/SignedFormula.lean` | `Label`, `SignedFormula`, `Branch`, `Eventuality`, `EventualityTracker`, `TimeOrdering`, `subformulaClosure` | Core types; eventuality tracker ready for use |
| `Decidability/Tableau.lean` | `TableauRule`, `applyRule`, `expandOnce`, `allRules` | Rule definitions; expansion entry point |
| `Decidability/Closure.lean` | `findClosure`, `isClosed`, monotonicity lemmas | Closure detection; proved monotonic |
| `Decidability/Saturation.lean` | `expandBranchWithFuel`, `buildTableau`, `recommendedFuel` | Main modification target for blocking |
| `Decidability/DecisionProcedure.lean` | `decide`, `decideAuto` | Consumer of `buildTableau`; passes fuel |
| `Syntax/SubformulaClosure/Closure.lean` | `subformulaClosure` (Finset), `closureWithNeg`, card bounds | FMP-compatible closure; provides the `n` for bound |
| `Decidability/FMP/FMP.lean` | `fmp_size_bound`, `mcs_finite_model_property` | Theoretical justification for finiteness |
| `Decidability/FMP/FiniteModel.lean` | `FilteredWorld.finite`, `FiniteFilteredTaskFrame` | Finiteness proof via injective characteristic sets |
| `Decidability/FMP/ClosureMCS.lean` | `closure_mcs_card_bound` | `|closureWithNeg| <= 2 * |subformulaClosure|` |

---

## 8. Risks and Considerations

### 8.1 Performance

The sound fuel bound from FMP is doubly exponential (`2^(2n)` where `n` = subformula count). For practical use, the blocking mechanism should short-circuit well before this bound. However, worst-case formulas (deep Until nesting with many atoms) will still be slow.

**Mitigation**: Keep the linear `recommendedFuel` as a default option for interactive use, and provide the sound bound as an alternative that guarantees termination.

### 8.2 Blocking Granularity

The current branch representation (`List SignedFormula`) makes time-type computation O(|branch|) per check. For performance, consider adding a `HashMap TimeIndex (HashSet Formula)` index.

### 8.3 Ancestor Tracking

The temporal ordering is tracked via `TimeOrdering.constraints` (a list of `(TimeIndex, TimeIndex)` pairs). For blocking, we need the transitive closure of ancestors. The current `futureOf`/`pastOf` only give immediate successors/predecessors.

**Solution**: Maintain an explicit ancestor list per time point, or compute the transitive closure of the ordering constraints.

### 8.4 Interaction with Tasks 236, 238, 239-241

- **Task 236** (cross-modal-temporal rules): May introduce new rule types that interact with blocking. Blocking should be designed to be rule-agnostic (based on type subsumption, not specific rules).
- **Task 238** (frame-class-specific rules): Dense/discrete rules add constraints but don't change the blocking mechanism.
- **Tasks 239-241** (proof extraction, truth lemma, dataset rebuilding): These downstream tasks depend on a correct and terminating tableau. Blocking must not break the branch structure that proof extraction and countermodel extraction rely on.

### 8.5 Proof Obligations

For publication-quality formalization, the following would need to be proved:
1. `subformula_property` (all rules produce closure formulas) -- mechanical but tedious
2. `blocking_terminates` (finite bound on branch length) -- follows from FMP bound
3. `blocking_sound` (blocked open branch is satisfiable) -- requires model-theoretic argument
4. `blocking_complete` (satisfiable formulas produce open branch) -- follows from FMP

Items 1 and 2 are feasible in the current framework. Items 3 and 4 require connecting the tableau to the semantic model theory, which is the domain of the completeness proof pipeline.

---

## 9. Recommendations

1. **Implement subset blocking in `Saturation.lean`** as the primary termination mechanism, wiring the existing `EventualityTracker` types.

2. **Replace `recommendedFuel` with `soundFuel`** derived from `subformulaClosure` cardinality, keeping a practical cap (e.g., `min(soundFuel phi) 100000`).

3. **Add time-type index** (`HashMap TimeIndex (List Formula)`) to `Branch` or as a parallel data structure for efficient blocking checks.

4. **Preserve the current API**: `buildTableau` should have the same signature. Blocked branches should be returned as `hasOpen` (open saturated) since they describe satisfiable branch fragments.

5. **State correctness theorems** as `theorem` declarations (potentially with `sorry` initially, to be proved in downstream tasks 239/240) for the subformula property and blocking soundness.

6. **Phase the implementation** to minimize risk: first add blocking detection (Phase 1-2), then replace fuel (Phase 3), then integrate eventualities (Phase 4), then prove correctness (Phase 5).
