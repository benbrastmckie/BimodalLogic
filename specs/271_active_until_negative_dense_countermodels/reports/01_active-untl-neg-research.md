# Research Report: Active Until-Negative Rule for Dense Countermodel Construction

## Task 271: Add active Until-negative rule for dense countermodel construction

## Executive Summary

The current `untlNeg` and `snceNeg` rules in `Tableau.lean` (lines 739-783) use a **passive** Reynolds co-decomposition strategy: they only decompose `F(U(event, guard))` at *existing* future time points (`timeOrd.futureOf l.time`). They never create fresh intermediate time points. When no future times exist yet for a given time label, `untlNeg` returns `notApplicable` (line 749: `| [] => (.notApplicable, timeOrd)`), causing premature saturation. This prevents the tableau from constructing countermodels that require dense temporal structure -- specifically, countermodels needing an intermediate time where certain formulas hold differently than at neighboring times.

The fix is to make `untlNeg`/`snceNeg` **active**: when no unprocessed future/past times exist, create a fresh intermediate time point and perform the Reynolds decomposition there. This mirrors how `allFutureNeg` (line 488-517) and `someFuturePos` (line 560-589) already create fresh time points.

## 1. Current Implementation Analysis

### 1.1 untlNeg Rule (Tableau.lean lines 739-758)

```lean
| .untlNeg, .neg, φ =>
    match asUntil? φ with
    | some (event, guard) =>
      let futureTimes := timeOrd.futureOf l.time
      -- Find first unprocessed future time (where decomposition hasn't been done yet)
      let unprocessed := futureTimes.filter fun t' =>
        let negEvent := SignedFormula.neg event { world := l.world, time := t' }
        let negGuard := SignedFormula.neg guard { world := l.world, time := t' }
        !branch.contains negEvent && !branch.contains negGuard
      match unprocessed with
      | [] => (.notApplicable, timeOrd)  -- All future times processed
      | t' :: _ =>
        let targetLabel : Label := { world := l.world, time := t' }
        let branch1 := [SignedFormula.neg event targetLabel, sf]
        let branch2 := [SignedFormula.neg guard targetLabel,
                         SignedFormula.neg (.untl event guard) targetLabel, sf]
        (.branching [branch1, branch2], timeOrd)
    | none => (.notApplicable, timeOrd)
```

**Key behavior**: The rule iterates over `timeOrd.futureOf l.time` (direct successors in the time ordering). If there are no future times, or all have been processed, it returns `notApplicable`. This means **the rule never creates new time points** -- it can only decompose at times created by other rules.

### 1.2 snceNeg Rule (Tableau.lean lines 764-783)

Symmetric to `untlNeg` but for past times. Same pattern: `timeOrd.pastOf l.time`, same `notApplicable` on empty list.

### 1.3 The Problem: Missing Dense Countermodels

Consider the formula `U(p, bot) -> U(p, p)` (informally: "bot until p implies p until p").

- Negation: `F(U(p, bot) -> U(p, p))` decomposes to `T(U(p, bot))` and `F(U(p, p))` at `(w0, t0)`.
- `T(U(p, bot))` is handled by `untlPos` (branching rule, creates fresh future time).
- `F(U(p, p))` is handled by `untlNeg` -- but it can only decompose at *existing* future times.

The problem: `untlPos` for `T(U(p, bot))` creates one fresh time `t1 > t0` with two branches:
  - Branch 1: `T(p)` at `t1` (event witnessed)
  - Branch 2: `T(bot)` at `t1` (guard holds, immediate closure)

On Branch 1, `T(p)` at `t1` and `F(U(p, p))` at `t0` with `t1` as a future of `t0`. When `untlNeg` processes `F(U(p, p))` at `t0`, it finds `t1` as an unprocessed future time and decomposes:
  - Sub-branch A: `F(p)` at `t1` -- contradicts `T(p)` at `t1`, closes
  - Sub-branch B: `F(p)` at `t1` (guard fails) AND `F(U(p, p))` at `t1` -- also contradicts `T(p)`, closes

So this particular formula closes correctly. But for formulas requiring an intermediate time where new information must be asserted, the current rule fails.

**The real failing pattern**: When the formula being tested requires the countermodel to have a time point that doesn't arise from any positive existential rule. For example, a formula like `G(p) -> U(p, p)` where the open branch has `F(G(p))` and `T(U(p, p))` -- the `untlNeg` rule applied to hypothetical `F(U(event, guard))` at some time `t` needs a future time to decompose at, but no rule has created one yet for that specific time label. The branch saturates prematurely, and the tableau either reports timeout or an incorrect open branch.

### 1.4 Affected Formulas (from task description)

The task description says ~60% of dataset timeouts come from this pattern. The `decideAutoAdaptive` function uses fuel=500, and the `soundFuel` function caps at 100000. Formulas that require dense intermediate time points exhaust their fuel without making progress because `untlNeg` keeps returning `notApplicable`.

## 2. Time Point Management System

### 2.1 Data Structures

- **`TimeIndex`**: `abbrev TimeIndex := Nat` (SignedFormula.lean line 47)
- **`Label`**: `structure Label` with `world : WorldIndex` and `time : TimeIndex` (line 53)
- **`TimeOrdering`**: Tracks `constraints : List (TimeIndex x TimeIndex)` where each `(a, b)` means `a < b` (line 646-648)
- **`Branch.nextTime`**: Returns `maxTime + 1` -- the next globally fresh time index (line 356-357)

### 2.2 Time Creation Patterns

Rules that create fresh times (all use `branch.nextTime`):
1. **`allFutureNeg`** (line 488): `F(GA)` creates fresh future time with `F(A)`, propagates `T(GA)`, `F(FA)`, box/diamond
2. **`allPastNeg`** (line 529): `F(HA)` creates fresh past time with `F(A)`, propagates `T(HA)`, `F(PA)`, box/diamond
3. **`someFuturePos`** (line 560): `T(FA)` creates fresh future time with `T(A)`, propagates universals
4. **`somePastPos`** (line 602): `T(PA)` creates fresh past time with `T(A)`, propagates universals
5. **`untlPos`** (line 650): `T(U(event, guard))` creates fresh future time, branches event/guard+continue
6. **`sncePos`** (line 694): `T(S(event, guard))` creates fresh past time, branches event/guard+continue
7. **`densityRule`** (line 793): Creates intermediate time between existing times (Dense frame class only)

**Rules that do NOT create fresh times**:
- `untlNeg` (line 739): Passive -- only decomposes at existing future times
- `snceNeg` (line 764): Passive -- only decomposes at existing past times
- `allFuturePos` (line 480): Universal propagation to existing future times
- `allPastPos` (line 520): Universal propagation to existing past times
- `someFutureNeg` (line 590): Universal propagation to existing future times
- `somePastNeg` (line 634): Universal propagation to existing past times

### 2.3 Auto-Propagation on Time Creation

When a fresh time is created, the creating rule auto-propagates:
- `T(GA)` formulas: their inner formula at the new time
- `F(FA)` formulas: their inner formula at the new time
- `F(U(event, guard))` formulas: the negated formula itself at the new time (see `untlNegProps` in `untlPos`, lines 680-684)
- `T(box A)` and `F(diamond A)` formulas (cross-modal-temporal persistence, line 316-324)

This is critical: **`untlPos` already propagates `F(U(...))` formulas to new times it creates** (lines 680-684). So `untlNeg` formulas DO get propagated when `untlPos` creates a time. The gap is when ONLY `untlNeg` formulas need to trigger time creation.

## 3. Proposed Modification

### 3.1 Active untlNeg Rule

When `untlNeg` finds no unprocessed future times (`futureTimes` filtered to `[]`), instead of returning `notApplicable`, it should **create a fresh future time** and perform the Reynolds decomposition there.

**Modified rule logic** (pseudocode):

```
untlNeg for F(U(event, guard)) at (w, t):
  let futureTimes := timeOrd.futureOf t
  let unprocessed := futureTimes.filter (not already decomposed)
  match unprocessed with
  | t' :: _ =>
      -- EXISTING BEHAVIOR: decompose at first unprocessed time
      branch1: F(event) at (w, t'), source re-included
      branch2: F(guard) at (w, t'), F(U(event, guard)) at (w, t'), source re-included
  | [] =>
      -- NEW BEHAVIOR: create fresh future time and decompose there
      let freshTime := branch.nextTime
      let newOrd := timeOrd.addFuture t freshTime
      -- Auto-propagate universals to freshTime (same as allFutureNeg, someFuturePos, untlPos)
      let gProps := propagate T(GA) from time t to freshTime
      let fNegProps := propagate F(FA) from time t to freshTime  
      let untlNegProps := propagate OTHER F(U(...)) from time t to freshTime
      let modalProps := propagate T(box A), F(diamond A) to freshTime
      -- Reynolds decomposition at freshTime
      branch1: F(event) at (w, freshTime), source re-included, + autoProp
      branch2: F(guard) at (w, freshTime), F(U(event, guard)) at (w, freshTime), source re-included, + autoProp
```

### 3.2 Active snceNeg Rule

Symmetric modification for `F(S(event, guard))` at known past times. When no unprocessed past times exist, create a fresh past time and decompose there.

### 3.3 Concrete Code Changes

**File**: `Theories/Bimodal/Metalogic/Decidability/Tableau.lean`

**Location**: Lines 739-758 (untlNeg) and 764-783 (snceNeg)

**untlNeg modification** (replace lines 748-757):

```lean
match unprocessed with
| [] =>
    -- Active: create fresh future time for Reynolds decomposition
    let freshTime := branch.nextTime
    let freshLabel : Label := { world := l.world, time := freshTime }
    let newOrd := timeOrd.addFuture l.time freshTime
    -- Auto-propagate T(GA) formulas from time t to freshTime
    let gProps := branch.allFuturePosFormulas.filterMap fun gsf =>
      match gsf.formula with
      | .all_future inner =>
        if gsf.label.time == l.time then
          let prop := SignedFormula.pos inner { world := gsf.label.world, time := freshTime }
          if branch.contains prop then none else some prop
        else none
      | _ => none
    -- Auto-propagate F(FA) formulas from time t to freshTime
    let fNegProps := branch.someFutureNegFormulas.filterMap fun fsf =>
      match fsf.formula with
      | .some_future inner =>
        if fsf.label.time == l.time then
          let prop := SignedFormula.neg inner { world := fsf.label.world, time := freshTime }
          if branch.contains prop then none else some prop
        else none
      | _ => none
    -- Auto-propagate OTHER F(U(event', guard')) formulas to freshTime
    let untlNegProps := branch.untlNegFormulas.filterMap fun usf =>
      if usf.label.time == l.time && usf != sf then
        let prop := SignedFormula.neg usf.formula { world := usf.label.world, time := freshTime }
        if branch.contains prop then none else some prop
      else none
    -- Cross-modal-temporal: propagate T(box A) and F(diamond A) to fresh time
    let modalProps := boxDiamondPersistence branch l.world l.time freshTime
    let autoProp := gProps ++ fNegProps ++ untlNegProps ++ modalProps
    -- Reynolds decomposition at the fresh time
    let branch1 := [SignedFormula.neg event freshLabel, sf] ++ autoProp
    let branch2 := [SignedFormula.neg guard freshLabel,
                     SignedFormula.neg (.untl event guard) freshLabel, sf] ++ autoProp
    (.branching [branch1, branch2], newOrd)
| t' :: _ =>
    -- Existing behavior: decompose at first unprocessed existing time
    let targetLabel : Label := { world := l.world, time := t' }
    let branch1 := [SignedFormula.neg event targetLabel, sf]
    let branch2 := [SignedFormula.neg guard targetLabel,
                     SignedFormula.neg (.untl event guard) targetLabel, sf]
    (.branching [branch1, branch2], timeOrd)
```

**snceNeg modification**: Mirror of above, using `pastOf`, `addPast`, `allPastPosFormulas`, `somePastNegFormulas`, `snceNegFormulas`.

### 3.4 Important Design Decision: Persistent vs Consumable

The `untlNeg` rule is **persistent** (the source formula `sf` is re-included in both branches). The proposed modification preserves this: the source `F(U(event, guard))` at the original label is re-included in both branches. This is essential because:

1. The formula may need to be decomposed at *additional* future times created later
2. The saturation check (via `findUnexpandedWithApplied` and the `AppliedSet`) prevents infinite re-application

### 3.5 Interaction with AppliedSet (Task 261)

The `AppliedSet` mechanism (Tableau.lean line 898) tracks signed formulas already produced by persistent rules. With the active modification:

- First application of `untlNeg` at `(w, t)` creates freshTime and decomposes -- the produced formulas enter the AppliedSet
- On revisit, the `findApplicableRuleWithApplied` (line 1028) filters out already-produced outputs
- If no new outputs remain, the rule is skipped (line 1040: `if newFormulas.isEmpty then none`)

This prevents infinite looping. However, we need to be careful: the active rule creates a NEW time, which means the propagated formulas at the new time are genuinely new (not in the AppliedSet). The `untlNeg` formula itself at `(w, t)` persists and can fire again, creating yet another fresh time.

**CRITICAL**: Without additional guards, this creates an infinite chain of fresh times. The existing **subset blocking** mechanism (SignedFormula.lean lines 597-629, 742-747) handles this: when a new time's type is a subset of an ancestor's type, blocking fires. This is the intended termination mechanism for temporal tableau procedures.

The eventuality-aware blocking (task 261 v3) at line 164 also helps: it checks `allEventualitiesFulfilledOrDuplicated` before allowing blocking, ensuring Until/Since obligations are properly tracked.

## 4. Soundness Argument

### 4.1 Why the Active Rule is Sound

The Reynolds decomposition for `F(U(event, guard))` at time `t` says:

> For every future time `t' > t`: either `F(event)` at `t'` or (`F(guard)` at `t'` and `F(U(event, guard))` at `t'`).

The current passive rule applies this only to *known* future times. The active rule additionally creates a fresh future time and applies the decomposition there. This is sound because:

1. **Soundness of time creation**: Creating a fresh time `t'` with `t < t'` is a Skolem witness for the universal quantifier "for ALL future times." Adding a witness time cannot introduce unsoundness -- it only constrains the model further.

2. **Soundness of propagation**: The auto-propagated formulas (`T(GA)` consequences, `F(FA)` consequences, box/diamond persistence) are consequences of formulas already on the branch. Specifically:
   - If `T(GA)` is at time `t` and `t' > t`, then `T(A)` at `t'` is semantically forced.
   - If `F(FA)` is at time `t` and `t' > t`, then `F(A)` at `t'` is semantically forced.
   - Modal persistence follows from S5 + modal-temporal interaction (boxTemporal rule).

3. **No new models excluded**: The active rule does not close any branch that should remain open. An open saturated branch still corresponds to a valid countermodel. The rule only adds consequences that are *already* semantically entailed by the branch contents.

### 4.2 Completeness Argument

The active rule preserves completeness because:
- If `F(U(event, guard))` at `t` is satisfiable, then in any model satisfying it, for every future time `t' > t`, either the event fails or the guard fails. The active rule creates exactly one such witness time and checks both cases. If the formula is satisfiable, at least one branch (typically the guard-fail + propagation branch) will remain open.

### 4.3 Impact on Existing Theorems

The following theorems in `CountermodelExtraction.lean` need verification after the change:

1. **`sat_untl_neg`** (line 739-793): This theorem states that in a saturated branch, for every future time `t'`, either `F(event)` or `F(guard)` is in the branch. The active rule strengthens this: it ensures decomposition happens even when no prior future times existed. The theorem remains valid because the saturation condition (`findUnexpanded = none`) now implies the active rule has fired.

2. **`sat_snce_neg`** (line 795-845): Mirror of above.

3. **`branchTruthLemma`** (line 1002-1018): The truth lemma's untl/snce negative cases use `sat_untl_neg`/`sat_snce_neg` to show that `branchTruth` is false. Since these saturation invariants are strengthened (more decompositions available), the truth lemma proof should still go through. However, the proof references `timeOrd.futureOf t` which now includes actively-created times, so it may need minor adjustments.

4. **`blocking_sound`** (Saturation.lean line 927): Unchanged -- blocking soundness depends on `expandBranchWithFuel` returning branches with `findClosure = none`, which is orthogonal to the `untlNeg` change.

5. **`expandBranchWithFuel_sound`** (Saturation.lean line 878): The proof uses strong induction on fuel. The active `untlNeg` creates a fresh time (consuming fuel via the branching case), so the induction step still applies. No change needed.

## 5. Termination Analysis

### 5.1 Will the Active Rule Cause Non-Termination?

The active `untlNeg` creates a fresh time on each activation when no unprocessed times exist. Without guards, this could loop:
1. `F(U(event, guard))` at `(w, t0)` -- creates `t1`, decomposes
2. Branch 2 has `F(U(event, guard))` at `(w, t1)` -- creates `t2`, decomposes
3. Branch 2 has `F(U(event, guard))` at `(w, t2)` -- creates `t3`, decomposes
4. ...

This is the **guard deferral chain** -- the standard challenge for Until/Since in temporal tableau procedures.

### 5.2 How Termination is Ensured

**Subset blocking** (already implemented, SignedFormula.lean lines 597-629) ensures termination:

- Each new time `t_i` carries a "time type" = set of (sign, formula) pairs at that time.
- The time type is drawn from the finite subformula closure of the initial formula.
- There are at most `2^(2n)` distinct time types where `n = |subformulaClosure(phi)|`.
- By pigeonhole, after at most `2^(2n)` time points, a repeat must occur.
- When `isSubsetBlocked b t_new t_anc = true` (line 624), blocking fires.

**Eventuality-aware blocking** (task 261 v3, lines 715-729) prevents premature blocking:
- Blocking only fires when all pending Until/Since eventualities at the blocked time are either fulfilled or duplicated at the ancestor.
- This ensures the guard deferral chain eventually terminates: if the guard keeps holding, the eventuality remains unfulfilled, and blocking only fires when the ancestor also has the same unfulfilled eventuality (meaning the chain is genuinely repeating).

**Fuel division** (task 261 v3, Saturation.lean line 180):
- In the split case, fuel is divided among sub-branches: `branchFuel = fuel / max(1, branches.length)`.
- This bounds total work to `O(fuel)` instead of `O(2^fuel)`.

### 5.3 Potential Issue: Fuel Exhaustion

The active rule creates more branching points than before. Each active `untlNeg` application creates 2 branches and a fresh time. With fuel division, the fuel available to each sub-branch decreases. This could cause *more* timeouts for complex formulas, not fewer.

**Mitigation**: The key insight is that formulas previously timing out were doing so because `untlNeg` returned `notApplicable` repeatedly without making progress. The active rule trades fuel for progress -- each application advances the tableau state. Combined with blocking, the chain of fresh times is bounded, so the total fuel consumption is bounded.

**Recommendation**: After implementation, measure the fuel consumption for the c7 dataset and compare with the baseline. If fuel exhaustion increases, consider:
1. Increasing the default fuel in `decideAutoAdaptive` from 500 to 750-1000
2. Adding a guard to the active rule: only create a fresh time if no other existential rule can create one first

## 6. File Paths and Line Numbers

| File | Purpose | Key Lines |
|------|---------|-----------|
| `Theories/Bimodal/Metalogic/Decidability/Tableau.lean` | Tableau rules (untlNeg, snceNeg) | 739-758 (untlNeg), 764-783 (snceNeg), 316-324 (boxDiamondPersistence), 908-923 (allRules) |
| `Theories/Bimodal/Metalogic/Decidability/SignedFormula.lean` | Branch, TimeOrdering, blocking | 46-47 (TimeIndex), 53-58 (Label), 356-357 (nextTime), 597-629 (isSubsetBlocked), 646-677 (TimeOrdering), 742-747 (isTemporallyBlocked) |
| `Theories/Bimodal/Metalogic/Decidability/Saturation.lean` | Expansion, fuel, blocking integration | 143-193 (expandBranchWithFuel), 304-361 (buildTableau), 878-914 (expandBranchWithFuel_sound) |
| `Theories/Bimodal/Metalogic/Decidability/CountermodelExtraction.lean` | Countermodel, truth lemma | 257-276 (branchTruth), 739-793 (sat_untl_neg), 795-845 (sat_snce_neg), 1002-1018 (branchTruthLemma) |
| `Theories/Bimodal/Metalogic/Decidability/Closure.lean` | Branch closure detection | 116-117 (findClosure) |
| `Theories/Bimodal/Metalogic/Decidability/DecisionProcedure.lean` | Decision procedure, fuel | 120-148 (decide), 169-172 (decideAuto), 188-193 (decideAutoAdaptive) |
| `Theories/Bimodal/Automation/DatasetGenerator.lean` | Dataset generation, labeling | 351-359 (extractCountermodelData), 487-500 (labelFormula) |
| `Theories/Bimodal/ProofSystem/Axioms.lean` | FrameClass definition | 422-442 (FrameClass) |

## 7. Risk Assessment

### 7.1 Low Risk
- **Soundness**: The active rule is a standard technique in temporal tableau procedures. The Reynolds decomposition is applied to a fresh time that is a legitimate successor, and all propagated formulas are semantically entailed.
- **Existing tests**: The inline tests in `Saturation.lean` (lines 424-501, 508-545, 555-623, 630-689, 940-1095) cover the current behavior. The modification should not break any test where `untlNeg` was previously unnecessary.

### 7.2 Medium Risk
- **Termination/fuel**: The active rule creates more branches and times. Subset blocking ensures theoretical termination, but practical fuel limits may need adjustment.
- **Proof obligations**: `sat_untl_neg` and `sat_snce_neg` in `CountermodelExtraction.lean` may need proof adjustments since the saturation invariant changes (more formulas present in saturated branches).
- **AppliedSet interaction**: The active rule produces genuinely new formulas (at a new time), so the AppliedSet does not prevent re-firing. Must rely on the "unprocessed" filter (which checks if `F(event)` or `F(guard)` already present at the new time) and blocking for termination.

### 7.3 High Risk
- **Regression on dataset labels**: If the active rule enables the tableau to close branches that were previously left open, some formulas currently labeled "invalid" might become "valid" or vice versa. This would show up in the regression check.
  - **Mitigation**: The active rule should not change validity -- it only helps find countermodels (open branches) that were previously missed due to premature saturation. A formula that closes (valid) should still close. A formula that was open should still be open (or now also open with a richer countermodel). The risk is primarily that timeouts become decisions (either valid or invalid), which is the desired outcome.

### 7.4 Self-Referential Propagation Guard

One subtle issue: when the active `untlNeg` for `F(U(event, guard))` creates a fresh time, it propagates OTHER `F(U(...))` formulas to that time (via `untlNegProps`). But should it also propagate ITSELF? Looking at the existing code:

- In `untlPos` (line 680-684): `branch.untlNegFormulas` includes ALL `F(U(...))` at the relevant time, including the one being decomposed. This propagates the current formula to the new time via `autoProp`.
- In the current passive `untlNeg`: the source formula `sf` is re-included directly (via `sf` in branch1/branch2), not via propagation.

For the active rule: Branch 2 already includes `F(U(event, guard))` at `freshLabel` directly. The `untlNegProps` should exclude `sf` itself to avoid duplication. This is handled by the `usf != sf` guard in the proposed code.

## 8. Implementation Plan Outline

### Phase 1: Core Rule Modification
1. Modify `untlNeg` in `Tableau.lean` to create fresh time when `unprocessed = []`
2. Modify `snceNeg` symmetrically
3. Add auto-propagation for universals (`T(GA)`, `F(FA)`, `F(U(...))`, box/diamond)

### Phase 2: Saturation and Correctness Updates
1. Verify `sat_untl_neg` and `sat_snce_neg` theorems still hold or update proofs
2. Verify `branchTruthLemma` propagation through the modified saturation invariants
3. Run `lake build` and fix any type errors

### Phase 3: Testing and Verification
1. Run inline `#eval` tests in `Saturation.lean`
2. Run `lake build` for full project
3. Check sorry/axiom counts with `lean_verify`
4. Test specific formulas that previously timed out

### Phase 4: Dataset Regeneration and Measurement
1. Regenerate c7 dataset
2. Measure timeout rate (target: from 4.8% to under 2%)
3. Run regression check (no previously-valid or previously-invalid formula changes label)

## 9. Alternative Approaches Considered

### 9.1 Dense-Only Activation (Rejected)

One option: only make `untlNeg` active when `fc >= .Dense`. This would limit the scope of change. However, the timeout problem affects the Base frame class too (the task description mentions ~60% of dataset timeouts). The active rule is sound for all frame classes, not just dense frames.

### 9.2 Demand-Driven Time Creation (Alternative)

Instead of always creating a fresh time when `unprocessed = []`, only create one when the `untlNeg` formula is the ONLY unexpanded formula on the branch (i.e., the branch would saturate without the active rule). This is more conservative but harder to implement and may not catch all cases.

### 9.3 Increasing Fuel Only (Rejected)

Simply increasing `decideAutoAdaptive`'s fuel from 500 to a higher value would not help: the passive `untlNeg` returns `notApplicable` immediately when no future times exist, so no amount of fuel helps -- the branch saturates prematurely regardless.

## 10. Conclusion

The active `untlNeg`/`snceNeg` modification is a well-motivated, soundness-preserving change that addresses a clear gap in the tableau's ability to construct countermodels. The main implementation risk is fuel exhaustion from increased branching, mitigated by existing subset blocking. The code change is localized to two rule cases in `Tableau.lean` (approximately 50 lines of new code per rule), with potential proof adjustments in `CountermodelExtraction.lean`.
