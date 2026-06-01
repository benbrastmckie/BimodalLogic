# Research Report: S5 Modal Tableau Rules (Multi-World Bookkeeping)

- **Task**: 233 - S5 modal tableau rules (multi-world bookkeeping)
- **Status**: Researched
- **Session**: sess_1748788800_orch233
- **Date**: 2026-06-01

## Executive Summary

The current modal rules in `Tableau.lean` are identity-collapse placeholders that strip the box/diamond operator and keep the formula at the same label. This is unsound for S5: it neither introduces witness worlds (for existential rules) nor propagates to all known worlds (for universal rules). Correct S5 tableau rules require:

1. A branch-aware `applyRule` signature (or a new rule application layer) that can inspect the branch to determine known worlds and compute fresh world indices.
2. A distinction between **consumable** rules (existential: F(box), T(diamond)) and **persistent** rules (universal: T(box), F(diamond)) that must be re-applied when new worlds appear.
3. An auto-propagation mechanism so that when a witness world is introduced, all universal formulas are instantiated at the new world.

The change surface is concentrated in `Tableau.lean` and `Saturation.lean`, with minor adjustments to `Closure.lean` (already correct) and `SignedFormula.lean` (add helper functions).

## 1. Current Modal Rule Placeholders

In `Tableau.lean`, the four modal rules (lines 256-271) are identity-collapse placeholders:

```lean
-- T(box A) -> T(A) at same label (WRONG: should propagate to ALL worlds)
| .boxPos, .pos, .box psi => .linear [SignedFormula.pos psi l]

-- F(box A) -> F(A) at same label (WRONG: should introduce fresh world)
| .boxNeg, .neg, .box psi => .linear [SignedFormula.neg psi l]

-- T(diamond A) -> T(A) at same label (WRONG: should introduce fresh world)
| .diamondPos, .pos, phi =>
    match asDiamond? phi with
    | some psi => .linear [SignedFormula.pos psi l]

-- F(diamond A) -> F(A) at same label (WRONG: should propagate to ALL worlds)
| .diamondNeg, .neg, phi =>
    match asDiamond? phi with
    | some psi => .linear [SignedFormula.neg psi l]
```

All four simply strip the modal operator and keep the same label, which is the S5-reflexivity-only behavior. This is incomplete (misses other worlds) and unsound (a formula that should require a fresh world witness gets collapsed to the current world).

## 2. Label Infrastructure from Task 232

Task 232 established the following infrastructure:

- **`WorldIndex := Nat`** and **`TimeIndex := Nat`** -- type aliases for indices.
- **`Label`** structure with `world : WorldIndex` and `time : TimeIndex` fields.
- **`Label.initial`** at `(world := 0, time := 0)`.
- **`SignedFormula`** now carries a `label : Label` field.
- **`Branch.hasPosAt`** / **`Branch.hasNegAt`** -- check membership at specific labels.
- **`Branch.findContradiction`** -- only finds contradictions at the SAME label (correct for S5).
- **`ClosureReason`** constructors carry `Label` parameter.

**NOT yet created** (needed for this task):
- Branch-level world tracking functions (`collectWorlds`, `nextWorld`, `maxWorld`).
- Universal formula collection (`collectBoxPos`, `collectDiamondNeg`).
- The label helpers `hasPosAt`/`hasNegAt` exist but there are no helpers for iterating over all worlds in a branch.

## 3. Correct S5 Tableau Rules

### 3.1 Rule Classification

In S5, all worlds are mutually accessible (equivalence relation = universal relation). The four modal rules split into two categories:

**Existential rules** (introduce a fresh witness world, consumable):
- **F(box A) @ w**: "box A is false at w" means there exists some world where A is false. Introduce fresh world w_new and add F(A) @ w_new.
- **T(diamond A) @ w**: "diamond A is true at w" means there exists some world where A is true. Introduce fresh world w_new and add T(A) @ w_new.

**Universal rules** (propagate to ALL known worlds, persistent):
- **T(box A) @ w**: "box A is true at w" means A is true at every world. Add T(A) @ w' for ALL currently known worlds w'.
- **F(diamond A) @ w**: "diamond A is false at w" means A is false at every world. Add F(A) @ w' for ALL currently known worlds w'.

### 3.2 Rule Specifications

```
T(box A) @ w  -->  { T(A) @ w' | w' in knownWorlds(branch) }    [PERSISTENT]
F(box A) @ w  -->  F(A) @ nextWorld(branch)                       [CONSUMABLE]
T(diamond A) @ w  -->  T(A) @ nextWorld(branch)                   [CONSUMABLE]
F(diamond A) @ w  -->  { F(A) @ w' | w' in knownWorlds(branch) }  [PERSISTENT]
```

### 3.3 Auto-Propagation

When a fresh world w_new is introduced (by F(box) or T(diamond)):
- For every T(box B) @ w in the branch: add T(B) @ w_new.
- For every F(diamond B) @ w in the branch: add F(B) @ w_new.

This ensures completeness: universal formulas constrain ALL worlds, including newly created ones.

### 3.4 Persistence and Re-expansion

Universal formulas (T(box A), F(diamond A)) must NOT be removed from the branch after expansion. They must remain so that:
1. When new worlds are introduced, auto-propagation can find them.
2. They are correctly recognized as "already expanded for all current worlds" (saturation check).

This conflicts with the current `expandOnce` design, which removes the expanded formula. See Section 5 for the proposed solution.

## 4. Closure.lean Analysis

`Closure.lean` already handles label-aware contradiction detection correctly:

- **`checkContradiction`**: Finds T(phi) and F(phi) at the SAME label. This is correct -- contradictions in S5 tableaux are always within the same world.
- **`checkBotPos`**: Finds T(bot) at ANY label. Correct -- T(bot) is a contradiction regardless of world.
- **`checkAxiomNeg`**: Finds F(axiom) at any label. Correct -- axioms are valid at all worlds.

**No changes needed to Closure.lean.** The label-aware same-world contradiction detection from task 232 is exactly what S5 requires.

## 5. Architectural Design for Correct S5 Rules

### 5.1 Core Problem

The current `applyRule` has signature:
```lean
def applyRule (rule : TableauRule) (sf : SignedFormula) : RuleResult
```

This is **formula-local** -- it cannot see the branch. But S5 universal rules need to:
1. Know all worlds in the branch (for propagation).
2. Know the next fresh world index (for witness introduction).

And `expandOnce` removes the expanded formula, but universal formulas must persist.

### 5.2 Proposed Solution: Branch-Aware Modal Expansion

**Option A: Extend `applyRule` to take the branch as context.**

Change `applyRule` to:
```lean
def applyRule (rule : TableauRule) (sf : SignedFormula) (branch : Branch) : RuleResult
```

For propositional rules, the branch argument is ignored. For modal rules, it provides world information.

Extend `RuleResult` with a new constructor:
```lean
inductive RuleResult : Type where
  | linear (formulas : List SignedFormula)
  | branching (branches : List (List SignedFormula))
  | persistent (formulas : List SignedFormula)  -- NEW: add formulas but keep the source
  | notApplicable
```

The `persistent` variant tells `expandOnce` to add the new formulas WITHOUT removing the source formula.

**Option B: Separate modal expansion into a branch-level function.**

Keep `applyRule` formula-local for propositional rules. Add a new function:
```lean
def expandModal (b : Branch) (sf : SignedFormula) : Option (List SignedFormula × Bool)
```

Where the `Bool` indicates whether the source formula should be removed (`true` = consumable, `false` = persistent).

**Recommendation: Option A** is cleaner because it keeps a single expansion pipeline. The branch parameter is simply ignored for propositional rules.

### 5.3 Helper Functions Needed (in SignedFormula.lean)

```lean
/-- Collect all distinct world indices appearing in a branch. -/
def Branch.knownWorlds (b : Branch) : List WorldIndex :=
  (b.map (fun sf => sf.label.world)).eraseDups

/-- Get the next fresh world index. -/
def Branch.nextWorld (b : Branch) : WorldIndex :=
  match b.knownWorlds.maximum? with
  | some maxW => maxW + 1
  | none => 0

/-- Collect all T(box A) formulas in the branch (for auto-propagation). -/
def Branch.boxPosFormulas (b : Branch) : List SignedFormula :=
  b.filter fun sf => sf.sign == .pos && match sf.formula with | .box _ => true | _ => false

/-- Collect all F(diamond A) formulas in the branch (for auto-propagation). -/
def Branch.diamondNegFormulas (b : Branch) : List SignedFormula :=
  b.filter fun sf => sf.sign == .neg && (asDiamond? sf.formula).isSome
```

### 5.4 Revised `applyRule` for Modal Cases

```lean
-- T(box A) @ w -> T(A) @ w' for all w' in knownWorlds(branch)
| .boxPos, .pos, .box psi =>
    let worlds := branch.knownWorlds
    let propagated := worlds.map fun w' => SignedFormula.pos psi { l with world := w' }
    -- Filter out already-present formulas to avoid infinite loops
    let newFormulas := propagated.filter (fun sf => !branch.contains sf)
    if newFormulas.isEmpty then .notApplicable  -- All propagations already present
    else .persistent newFormulas

-- F(box A) @ w -> F(A) @ fresh world + auto-propagate universals
| .boxNeg, .neg, .box psi =>
    let freshW := branch.nextWorld
    let freshLabel := { l with world := freshW }
    let witness := SignedFormula.neg psi freshLabel
    -- Auto-propagate: all T(box B) get T(B) @ freshWorld
    let boxProps := branch.boxPosFormulas.filterMap fun sf =>
      match sf.formula with
      | .box inner => some (SignedFormula.pos inner freshLabel)
      | _ => none
    -- Auto-propagate: all F(diamond B) get F(B) @ freshWorld
    let diaProps := branch.diamondNegFormulas.filterMap fun sf =>
      match asDiamond? sf.formula with
      | some inner => some (SignedFormula.neg inner freshLabel)
      | none => none
    .linear ([witness] ++ boxProps ++ diaProps)
```

(Symmetric for T(diamond) and F(diamond).)

### 5.5 Saturation: When Are Universal Formulas "Done"?

A universal formula T(box A) @ w is "fully expanded" when T(A) @ w' is already present in the branch for EVERY known world w'. Similarly for F(diamond A).

This means `isExpanded` for box-pos and diamond-neg must check the BRANCH, not just the formula. The `isExpanded` function currently takes only a `SignedFormula`. Two options:

**Option A**: Change `findUnexpanded` to pass the branch context:
```lean
def isExpandedInBranch (sf : SignedFormula) (b : Branch) : Bool :=
  match sf.sign, sf.formula with
  | .pos, .box psi =>
      b.knownWorlds.all fun w' => b.hasPosAt psi { sf.label with world := w' }
  | .neg, phi =>
      match asDiamond? phi with
      | some psi =>
          b.knownWorlds.all fun w' => b.hasNegAt psi { sf.label with world := w' }
      | none => (findApplicableRule sf).isNone
  | _, _ => (findApplicableRule sf).isNone
```

**Option B**: Use `applyRule` returning `notApplicable` when all propagations are already present (as shown in 5.4 above). Then `isExpanded` naturally works through `findApplicableRule` since `applyRule` with branch context returns `notApplicable` for fully-propagated universals.

**Recommendation: Option B** -- integrate the check into `applyRule` itself, which already has the branch context in the revised design.

### 5.6 Termination Considerations

The current termination measure is `totalUnexpandedComplexity`, which decreases as formulas are expanded. With S5 rules:

- **Existential rules** (F(box), T(diamond)): These are consumable (source removed). They increase the world count by 1 but reduce unexpanded complexity.
- **Universal rules** (T(box), F(diamond)): These are persistent but produce formulas at existing worlds. They produce only formulas of LOWER complexity at existing worlds.

**Key insight for termination**: The number of worlds is bounded by the number of existential formulas (each F(box) or T(diamond) creates at most one new world). The total number of signed formulas is bounded by `|subformulaClosure| * 2 * |knownWorlds| * 2` (signed formula at each sign at each world). Since both are finite, the expansion terminates.

The fuel-based approach in `expandBranchWithFuel` sidesteps the termination proof -- fuel is sufficient for correctness. A proper termination measure for well-founded recursion would use a lexicographic product:
1. Number of missing propagations (strictly decreasing for universal rules).
2. Number of unexpanded existential formulas (strictly decreasing for existential rules).

For implementation, the existing fuel-based approach is adequate. Termination proofs can be added in task 237.

## 6. `expandOnce` Modifications (Saturation.lean)

The `expandOnce` function needs adjustment:

```lean
def expandOnce (b : Branch) : ExpansionResult :=
  match findUnexpanded b with
  | none => .saturated
  | some sf =>
      match findApplicableRule sf b with  -- pass branch
      | none => .saturated
      | some (_, result) =>
          match result with
          | .linear formulas =>
              let remaining := b.filter (· != sf)
              .extended (formulas ++ remaining)
          | .persistent formulas =>          -- NEW
              .extended (formulas ++ b)      -- Keep source formula
          | .branching branches =>
              let remaining := b.filter (· != sf)
              .split (branches.map fun newFormulas => newFormulas ++ remaining)
          | .notApplicable => .saturated
```

The key difference: `.persistent` does NOT remove the source formula from the branch.

## 7. Dependency and Compilation Analysis

### 7.1 Import DAG

```
SignedFormula.lean (add helpers)
    |
    v
Tableau.lean (revise applyRule, add RuleResult.persistent)
    |
    v
Closure.lean (NO CHANGES NEEDED)
    |
    v
Saturation.lean (revise expandOnce for persistent)
    |
    v
ProofExtraction.lean (may need minor adjustments)
DecisionProcedure.lean (no changes expected)
CountermodelExtraction.lean (no changes expected)
```

### 7.2 Change Surface

| File | Change Type | Scope |
|------|-------------|-------|
| `SignedFormula.lean` | Add helpers | ~30 new lines: `knownWorlds`, `nextWorld`, `boxPosFormulas`, `diamondNegFormulas` |
| `Tableau.lean` | Revise rules | ~60 lines changed: `applyRule` signature, 4 modal cases, `RuleResult`, `isApplicable`, `expandOnce` |
| `Saturation.lean` | Revise expansion | ~10 lines: handle `persistent` in `expandBranchWithFuel` |
| `Closure.lean` | None | Already correct from task 232 |
| `ProofExtraction.lean` | Minor | Pattern match on new `RuleResult.persistent` if needed |
| `CountermodelExtraction.lean` | Minor/None | May need world-aware countermodel extraction |

### 7.3 Downstream Impact Assessment

- **`Correctness.lean`**: No direct `SignedFormula`/`Branch` usage. No changes needed.
- **`FMP/`** (7 files): Separate filtration-based approach. No changes needed.
- **`EnrichedCountermodel.lean`**: Already serializes labels. No changes needed for this task, though multi-world countermodels would benefit from richer extraction (future task).

## 8. Risks and Mitigations

### 8.1 Infinite Loop Risk

Universal formulas are persistent. If `isExpanded` / `findApplicableRule` does not correctly detect "already fully propagated," the expansion loops forever (or until fuel exhaustion).

**Mitigation**: `applyRule` with branch context checks that all propagations are already present before returning `.notApplicable`. The fuel parameter in `expandBranchWithFuel` provides a hard safety net.

### 8.2 Monotonicity Lemma Impact

The `closed_extend_closed` and related monotonicity lemmas in `Closure.lean` should remain valid. Adding formulas to a branch cannot "undo" a closure. However, the proofs may need adjustment if `expandOnce` changes the shape of the branch differently.

**Mitigation**: The closure proofs depend only on `Branch` as `List SignedFormula` -- they do not depend on how the list was constructed. No changes expected.

### 8.3 Termination Measure

The current `totalUnexpandedComplexity` may not decrease for universal rule applications (the source formula persists). This is safe with fuel-based expansion but could complicate future well-founded termination proofs.

**Mitigation**: Task 237 (tableau termination) is explicitly designed to handle this. For now, fuel suffices.

### 8.4 `findApplicableRule` and `isExpanded` Signature Change

Both currently take only `SignedFormula`. If `applyRule` gains a `Branch` parameter, these need the branch too. This affects `findUnexpanded`, `countUnexpanded`, and `totalUnexpandedComplexity`.

**Mitigation**: These are all internal to the Decidability module. The change is self-contained. Pass the branch through all callers.

## 9. Implementation Recommendations

### Phase 1: SignedFormula.lean Helpers (~30 lines)

Add `Branch.knownWorlds`, `Branch.nextWorld`, `Branch.maxWorld`, `Branch.boxPosFormulas`, `Branch.diamondNegFormulas`. These are pure helper functions with no proof obligations.

### Phase 2: Tableau.lean Rule Revision (~80 lines)

1. Add `RuleResult.persistent` constructor.
2. Change `applyRule` to take `Branch` parameter.
3. Implement correct S5 modal rules with branch context.
4. Update `isApplicable`, `findApplicableRule`, `isExpanded`, `findUnexpanded`, `expandOnce` to pass branch context.
5. Update `countUnexpanded` and `totalUnexpandedComplexity` for branch-aware expansion check.

### Phase 3: Saturation.lean Expansion (~15 lines)

1. Handle `RuleResult.persistent` in `expandBranchWithFuel`.
2. Ensure the fuel decrements correctly (persistent expansions still consume fuel).

### Phase 4: Build Verification

1. `lake build Bimodal.Metalogic.Decidability.Tableau` -- verify core compiles.
2. `lake build Bimodal.Metalogic.Decidability.Saturation` -- verify expansion compiles.
3. `lake build` -- full project build to catch downstream issues.

## 10. Tactic Survey Results

Not applicable for this research phase -- the changes are primarily definitional (function implementations) rather than proof obligations. The existing proofs in `Closure.lean` should remain valid without change. New proofs may be needed if we want to prove properties of the S5 rules (e.g., "universal propagation is complete"), but those are deferred to task 237 (termination) and task 239 (proof extraction correctness).

## 11. Alternative Approaches Considered

### 11.1 Separate Modal Expansion Pass

Instead of integrating modal rules into `applyRule`, have a separate pass that runs after all propositional rules are saturated. This is conceptually cleaner but would require restructuring the expansion loop significantly.

**Rejected**: Too large a refactor for this task. The integrated approach (Option A) has smaller change surface.

### 11.2 Explicit World Set in Branch

Add an explicit `worlds : Finset WorldIndex` field to the branch type, rather than computing `knownWorlds` by scanning all formulas.

**Rejected**: Would require changing `Branch` from `List SignedFormula` to a structure, breaking many downstream definitions. Computing `knownWorlds` by scanning is O(n) but branches are small in practice.

### 11.3 Lazy Propagation (On-Demand)

Instead of eagerly propagating universal formulas when new worlds are created, check on-demand during saturation whether a universal formula has been propagated to all worlds.

**Considered but deferred**: This is essentially what Option B in Section 5.2 describes -- it works through `isExpanded` / `findApplicableRule` returning "needs expansion" when propagation is incomplete. This is actually what the recommended design does: `applyRule` for T(box A) checks if all propagations exist and returns `notApplicable` if they do. So the recommended design IS lazy propagation.

**However**, the auto-propagation in the existential rules (F(box), T(diamond)) eagerly propagates at world-introduction time. This is an optimization that reduces the number of expansion steps.

## 12. Summary of Findings

1. **Current state**: Four identity-collapse placeholders in `Tableau.lean` lines 256-271.
2. **Required changes**: Revise `applyRule` to take branch context, add `RuleResult.persistent`, implement correct S5 universal/existential rules.
3. **Helper functions needed**: `Branch.knownWorlds`, `Branch.nextWorld`, `Branch.boxPosFormulas`, `Branch.diamondNegFormulas` in `SignedFormula.lean`.
4. **Closure.lean**: Already correct. No changes needed.
5. **Saturation.lean**: Handle `persistent` result type, pass branch to `findApplicableRule`.
6. **Termination**: Fuel-based approach is sufficient; well-founded termination deferred to task 237.
7. **Estimated scope**: ~130 lines of changes across 3 files.
8. **No blockers identified**.
