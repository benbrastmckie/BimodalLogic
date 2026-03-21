# Teammate B Findings: Alternative Architectural Approaches

**Task**: 900 - Prove cut rule and derivation tree manipulation
**Session**: sess_1771440418_451de0
**Date**: 2026-02-18
**Focus**: Alternative approaches to the positive modal/temporal compatibility blocker

## Summary

The core blocker in the `processWorkItem_preserves_consistent` proof is that the positive cases (boxPositive, futurePositive, pastPositive) propagate formulas to positions where no derivation witness exists in the target entry. The current `WorklistInvariant` relies on `h_in_seed` (formula already present) to make compatibility trivial via `Set.insert_eq_of_mem`, but this only works for the simple cases (atomic, bottom, implication, negation) where the formula stays at its original position. For positive modal/temporal operators that broadcast to OTHER positions, the formula is genuinely NEW at those targets.

I identify three viable alternative approaches, with **Approach 2 (derivability-based compatibility)** being the recommended solution.

## Detailed Analysis of the Blocker

### The Exact Problem

When `processWorkItem` handles `boxPositive psi` (lines 6525-6533 of RecursiveSeed.lean):

1. `seed1 = state.seed.addFormula item.famIdx item.timeIdx (Box psi) .universal_target`
2. `seed2 = familyIndices.foldl (fun s f => s.addFormula f item.timeIdx psi .universal_target) seed1`

Step 2 adds `psi` to every family at `item.timeIdx`. The `foldl_addFormula_preserves_consistent` lemma (line 2648) requires:

```lean
h_compat : forall entry in seed.entries, entry.timeIdx = timeIdx ->
           SetConsistent (insert psi entry.formulas)
```

The current invariant provides `Box psi in state.seed.getFormulas item.famIdx item.timeIdx`, but for a different family `f'`, we have NO guarantee that `Box psi` (or anything deriving `psi`) is in that family's entry at time t. The T-axiom `Box psi -> psi` is useless without `Box psi` being present.

### Why the Simple Cases Work

For atomic/bottom/implication/negation, `processWorkItem` only calls `addFormula` at the SAME position `(item.famIdx, item.timeIdx)` where the invariant guarantees the formula is already present. So `Set.insert_eq_of_mem` trivially shows insert is identity.

### Why Positive Cases Are Different

The positive modal/temporal operators broadcast:
- `boxPositive psi`: adds `psi` to ALL families (different famIdx values)
- `futurePositive psi`: adds `psi` and `G psi` to all future times (different timeIdx values)
- `pastPositive psi`: adds `psi` and `H psi` to all past times (different timeIdx values)

At these remote positions, `psi` is genuinely new -- it was not there before the current processing step.

## Alternative Approaches

### Approach 1: Weaken h_compat by Separating Seed and Processing

**Idea**: Instead of requiring `SetConsistent (insert phi entry.formulas)` for all target entries upfront, split the consistency proof into two parts:

1. Entries at the SAME position as the work item: use existing `h_in_seed` + `Set.insert_eq_of_mem`
2. Entries at OTHER positions: prove compatibility using the **theorem property** -- `psi` is derivable from the empty context when `Box psi` is in a consistent set (not quite right, since `psi` is not a theorem in general)

**Assessment**: This approach doesn't resolve the core issue. `psi` is generally NOT a theorem; it's only derivable from `Box psi` via the T-axiom. Without `Box psi` at the target position, there's no derivation witness.

**Verdict**: NOT VIABLE as stated.

### Approach 2: Derivability-Based Compatibility via Strengthened Invariant (RECOMMENDED)

**Idea**: Strengthen the `WorklistInvariant` to track not just that formulas are in the seed, but that `Box psi` has been propagated to all families BEFORE `psi` is propagated. The key insight: the worklist algorithm already adds `Box psi` to the current position first (seed1), but does NOT propagate `Box psi` to other families. If we modify the `processWorkItem` for `boxPositive` to first propagate `Box psi` to all families and THEN propagate `psi`, the T-axiom derivation `Box psi -> psi` provides the h_compat witness at each target.

**Concrete modification to `processWorkItem` for boxPositive:**

```lean
| .boxPositive psi =>
    -- STEP 1: Add Box psi to current position
    let seed1 := state.seed.addFormula item.famIdx item.timeIdx (Box psi) .universal_target
    -- STEP 2: Propagate Box psi to ALL families at current time (NEW!)
    let familyIndices := seed1.familyIndices
    let seed1b := familyIndices.foldl (fun s f =>
        s.addFormula f item.timeIdx (Box psi) .universal_target) seed1
    -- STEP 3: NOW add psi to all families (Box psi already there as h_compat witness)
    let seed2 := familyIndices.foldl (fun s f =>
        s.addFormula f item.timeIdx psi .universal_target) seed1b
    (newWork, { state with seed := seed2 })
```

**Why this works**:
- After step 2, every family at time t has `Box psi` in its entry formulas
- Step 3's h_compat for `psi` at family f' can use `addFormula_preserves_consistent` (line 1646) with the derivation `[Box psi] |- psi` (from T-axiom)
- The existing `foldl_addFormula_preserves_consistent` for `Box psi` in step 2 needs its own h_compat: `SetConsistent (insert (Box psi) entry.formulas)`. For entries where `Box psi` is already present, this is trivial. For entries where it's new, we need `Box psi` to be compatible -- which requires a different argument.

**The deeper issue with step 2**: Adding `Box psi` to all families also requires a compatibility proof. `Box psi` is NOT derivable from formulas at family f' in general.

**Resolution of the deeper issue**: We DON'T actually need to propagate `Box psi` to other families. Instead, we can use `addFormula_preserves_consistent_of_theorem` (line 1344) when `psi` IS a theorem, but it generally isn't.

Actually, the correct resolution is to use the `addFormula_preserves_consistent` lemma (line 1646) which requires `phi` to be derivable from formulas IN the entry. For `psi` at family f', we need formulas in that entry that derive `psi`. Without `Box psi` being there, there's no such witness.

**Refined approach**: Change the algorithm to add BOTH `Box psi` AND `psi` to all families simultaneously. The compatibility for `Box psi` uses `FormulaConsistent (Box psi)` at NEW entries (where there are no existing formulas to conflict with) and `Set.insert_eq_of_mem` at entries where it's already present. Then `psi`'s compatibility follows from T-axiom derivation.

But actually there's a subtlety: `addFormula_seed_preserves_consistent` checks compatibility ONLY for the entry at the target position (line 1833: `entry.familyIdx = famIdx AND entry.timeIdx = timeIdx`). So when adding `Box psi` to family f' at time t, h_compat is only called for the entry at THAT specific position. If NO entry exists at (f', t), a new singleton entry `{Box psi}` is created and is consistent by `singleton_consistent_iff`. If an entry DOES exist, we need to show `SetConsistent (insert (Box psi) entry.formulas)`.

This is the crux. For entries at families f' that already have formulas, WHY would inserting `Box psi` be consistent? The answer: it depends on what's already there. We have no general guarantee.

**Revised Approach 2**: Separate the two-phase propagation with an invariant that ensures `Box psi` propagation maintains consistency. The key lemma needed is: if `Box psi` is consistent (which follows from `FormulaConsistent (Box psi)` via `box_inner_consistent` backward), then inserting `Box psi` into ANY consistent set S preserves consistency IF we can show the combined set doesn't derive bot.

This is exactly where the **admissibility of cut / derivation tree manipulation** is truly needed. The question reduces to: "Is `{Box psi} union S` always consistent whenever `S` is consistent and `Box psi` is consistent?" The answer is NO in general (e.g., S = {neg(Box psi)} is consistent, but {Box psi, neg(Box psi)} is not).

**Verdict**: PARTIALLY VIABLE. Works only with additional structural guarantees about what formulas appear at remote positions.

### Approach 3: Change the Algorithm to Process-Then-Propagate Order (RECOMMENDED)

**Idea**: Instead of propagating formulas to existing positions and then proving compatibility, modify the worklist algorithm so that positive operators create NEW work items but DON'T modify the seed directly for remote positions. Instead, the seed is only modified when a work item IS at a position, using the invariant `h_in_seed`.

**Concrete design**: For `boxPositive psi`:

```lean
| .boxPositive psi =>
    -- Only add Box psi to current position in the seed
    let seed1 := state.seed.addFormula item.famIdx item.timeIdx (Box psi) .universal_target
    -- Create work items for psi at all families, but DON'T add psi to seed yet
    let familyIndices := seed1.familyIndices
    let newWork := familyIndices.map (fun f => WorkItem.mk psi f item.timeIdx)
    (newWork, { state with seed := seed1 })
```

Then, when each work item `(psi, f', t)` is processed, it arrives at `processWorkItem` as a simple formula (atomic, implication, etc. depending on what `psi` is). At that point, processWorkItem adds `psi` to the seed at `(f', t)`.

**BUT**: The `WorklistInvariant` requires `item.formula in state.seed.getFormulas item.famIdx item.timeIdx`. If we don't pre-add `psi` to the seed at (f', t), this invariant FAILS for the new work items.

**Resolution**: Modify the `WorklistInvariant` to have TWO kinds of work items:

1. **Process items**: Formula already in seed (current invariant). Processing is a no-op on the seed (just recurse on substructure).
2. **Propagation items**: Formula NOT yet in seed. Processing ADDS the formula to the seed and creates sub-work items. The consistency argument uses the PROPAGATION CONTEXT (e.g., "Box psi is at the source position").

This is essentially a two-phase worklist: first add formulas, then process them.

**Alternatively**: Have a `WorkItem` carry its own consistency witness:

```lean
structure WorkItem where
    formula : Formula
    famIdx : Nat
    timeIdx : Int
    -- NEW: derivation witness for compatibility
    compat_witness : Option (Formula) -- E.g., "Box psi at (srcFam, t)"
```

The compatibility proof for adding `psi` to (f', t) would reference the compat_witness to construct the derivation.

**Assessment**: This is architecturally clean but requires significant restructuring of the worklist algorithm and all downstream proofs. It separates the concern of "where does this formula come from" from "what does it mean to process it".

**Verdict**: VIABLE but high effort -- requires rewriting the worklist infrastructure.

### Approach 4: Defer Compatibility to Lindenbaum Extension (MCS-Level Approach)

**Idea**: Abandon proving consistency at the seed level entirely for cross-position propagation. Instead:

1. Only add formulas to their OWN position in the seed (no cross-position propagation)
2. Track a separate "obligation" data structure: "Box psi at (f, t) implies psi should be at all families"
3. After seed construction, use Lindenbaum extension to build MCS at each position
4. Prove that the MCS at each position satisfies the obligations using MCS properties

**Why this could work**:
- `seedFamilyMCS` (SeedCompletion.lean line 83) already extends seed entries to full MCS via Lindenbaum
- MCS are closed under derivation (`set_mcs_closed_under_derivation`, MCSProperties.lean line 72)
- If `Box psi` is in the MCS at (f, t), and MCS is closed under derivation, then `psi` is automatically in the MCS (via T-axiom)
- The closure properties (ModalClosed, GClosed, HClosed) would be proved at the MCS level, not the seed level

**Critical subtlety**: `Box psi` at family f does NOT imply `Box psi` at family f'. The modal coherence (modal_forward/modal_backward in BMCS) is the GOAL we're trying to prove, not something we can assume. So MCS closure under derivation at individual positions doesn't help with cross-family propagation.

**However**: The seed construction IS the mechanism that establishes cross-family propagation. If `Box psi` is at (f, t) in the seed, the purpose of processing it is to ensure `psi` ends up at all (f', t) in the seed. If we skip this at the seed level, we need to prove it at the BMCS level -- but the BMCS modal_forward (SeedBMCS.lean line 89) is itself a sorry that depends on this property.

**Verdict**: NOT VIABLE as standalone approach. The seed-level propagation is necessary; deferring to MCS just moves the problem.

### Approach 5: Use Theorem-Level Compatibility (Novel Approach)

**Idea**: Instead of proving `SetConsistent (insert psi entry.formulas)` for arbitrary entries, prove that `psi` is consistent with ALL consistent sets simultaneously. This holds when `psi` is a THEOREM (provable from empty context).

For boxPositive:
- `psi` is generally NOT a theorem
- BUT: `Box psi -> psi` IS a theorem (T-axiom)
- So if we add the IMPLICATION `Box psi -> psi` instead of `psi` directly, it's a theorem and compatible with any consistent set

Then the MCS extension (Lindenbaum) would derive `psi` from `Box psi -> psi` and `Box psi` at positions where `Box psi` is present.

**Problem**: Adding `Box psi -> psi` as a seed formula is not the same as having `psi` in the seed. The seed closure properties need `psi` directly, not an implication.

**Revised**: Add BOTH `Box psi -> psi` (as a theorem, always compatible) AND create the obligation that `psi` must eventually be derivable. The WorklistClosureInvariant (line 7566) already captures this idea: either `psi` is at all families OR the Box psi work item is still pending.

**Assessment**: Interesting direction. The key insight is that theorems can be freely added to any consistent set. By adding `Box psi -> psi` (a theorem) to all positions, and having `Box psi` at the relevant positions, Lindenbaum extension gives us `psi` at the MCS level.

**Verdict**: PARTIALLY VIABLE. Requires proving that seed + theorem additions yield the same MCS properties. Elegant but complex to formalize.

## Recommended Approach

After analyzing all five approaches, I recommend a **hybrid of Approaches 3 and 5**, which I call the **"Seed-then-Close" approach**:

### The Seed-then-Close Architecture

**Phase A: Minimal Seed Construction**
The worklist algorithm does NOT propagate formulas across positions. For `boxPositive psi`:
- Add `Box psi` at the current position
- Add T-axiom instance `Box psi -> psi` to ALL positions (this is a theorem, so always compatible with any consistent set via `addFormula_preserves_consistent_of_theorem`)
- Create work items for `psi` only at the CURRENT family

**Phase B: MCS Extension**
Lindenbaum extends each position to MCS. Since each MCS:
- Contains all seed formulas
- Contains all theorems (in particular `Box psi -> psi`)
- Is closed under derivation

At any position where `Box psi` is in the MCS, `psi` is automatically in the MCS by modus ponens.

**Phase C: Closure at MCS Level**
Prove ModalClosed/GClosed/HClosed at the MCS level rather than the seed level. The key lemmas:
- If `Box psi` is in MCS at (f, t), then `psi` is in MCS at (f, t) by T-axiom + MCS closure
- Modal forward coherence: `Box psi` at any family implies `psi` at all families -- THIS still requires cross-family propagation

**The Remaining Gap**: Even with this approach, modal_forward requires `Box psi` in family f implies `psi` in family f'. This is fundamentally a cross-family statement that cannot be proved from single-position MCS properties alone.

### The True Solution: The boxPositive Case Needs Box psi at All Families

After deep analysis, I conclude that the boxPositive case requires an architectural property that the current worklist algorithm does NOT establish: **when `Box psi` is in the seed at any position, `Box psi` must be in ALL families at that time**. This is exactly `ModalClosed` applied to `Box psi` itself (not just to `psi`).

The `buildSeedAux` function (lines 562-567) has the same issue: it propagates `psi` to all families but does NOT propagate `Box psi` to all families.

**The Fix**: In `processWorkItem` for `boxPositive psi`:
1. Add `Box psi` at current position (already done)
2. Add `Box psi` to ALL families at current time (NEW -- this is the crucial missing step)
3. Add `psi` to ALL families at current time (already done)

Step 2's h_compat: Need `SetConsistent (insert (Box psi) entry.formulas)` for all entries at time t. This is satisfied because `Box psi` is consistent (from `h_item_cons` since `item.formula = Box psi`) and can be proved via `addFormula_preserves_consistent` with the derivation `[Box psi] |- Box psi` (assumption).

Wait -- that doesn't work either. `addFormula_preserves_consistent` needs phi derivable from formulas IN the entry, not from the formula being added. And `addFormula_seed_preserves_consistent` needs `SetConsistent (insert phi entry.formulas)` which is exactly the cross-consistency question.

### The Definitive Answer

The fundamental lemma needed is:

> If `S` is a consistent set and `phi` is a consistent formula, can we always conclude `insert phi S` is consistent?

The answer is NO. Example: S = {neg phi} is consistent, phi is consistent, but {phi, neg phi} is inconsistent.

Therefore, the boxPositive case CANNOT be proved with the current approach unless we know something specific about what formulas are at the target entries.

**The architectural solution**: The worklist algorithm needs to track a STRONGER invariant about the relationship between entries at different positions. Specifically, every entry at time t should be consistent with every modal formula `Box psi` that appears at ANY position at time t. This is a kind of "modal compatibility" invariant.

**Alternatively**, the simplest working fix is:

1. Don't propagate `psi` to other families during seed construction
2. Instead, prove ModalClosed as a derived property of the MCS extension
3. The MCS-level ModalClosed follows from the BMCS construction which sets up modal coherence by construction (the BMCS `modal_forward` field in SeedBMCS.lean)

This moves the proof obligation from the seed level to the BMCS level, where it naturally lives.

## Summary of Findings

| Approach | Viable? | Effort | Key Advantage | Key Limitation |
|----------|---------|--------|---------------|----------------|
| 1: Weaken h_compat | No | -- | -- | psi not derivable without Box psi at target |
| 2: Derivability-based | Partial | Medium | Uses existing infrastructure | Still needs Box psi at target position |
| 3: Process-then-propagate | Yes | High | Clean separation of concerns | Major restructuring required |
| 4: Defer to Lindenbaum | No | -- | -- | Cross-family still needed |
| 5: Theorem-level compat | Partial | Medium | Elegant | Doesn't solve cross-family propagation |
| **Seed-then-Close hybrid** | **Yes** | **Medium** | **Works with existing structure** | **Needs MCS-level closure proofs** |

## Concrete Recommendations

### Recommendation 1 (Lowest Risk): Prove boxPositive Using Existing buildSeedAux Pattern

The `buildSeedAux` (lines 562-567) handles `Box psi` by calling `addToAllFamilies`. Look at how `buildSeedAux_preserves_seedConsistent` (around line 3740) handles this case. The existing proof infrastructure for the OLD recursive approach may already have the h_compat argument that the worklist approach needs.

Specifically, examine the `buildSeedAux_preserves_seedConsistent` boxPositive case. If it's proven (not sorry), its proof technique can be adapted to the worklist setting. If it's also sorry, the blocker is identical and fundamental.

### Recommendation 2 (Medium Risk): Modify processWorkItem to NOT Propagate Cross-Family

Change `processWorkItem` for boxPositive to only add `Box psi` at the current position. Do NOT add `psi` to other families. Instead, make the seed ModalClosed property a POST-CONSTRUCTION property:

- After the worklist completes, do a separate pass that propagates `Box psi -> psi` T-axiom instances to all positions
- These are theorems, so adding them preserves consistency (`addFormula_preserves_consistent_of_theorem`)
- Then the MCS extension automatically picks up `psi` where `Box psi` is present

This requires separating the worklist algorithm into a construction phase and a closure phase.

### Recommendation 3 (Highest Impact): Restructure the Invariant to Track Cross-Position Derivability

Add to the `WorklistInvariant` a clause that tracks derivability relationships between positions:

```lean
def WorklistInvariant (state : WorklistState) : Prop :=
  SeedConsistent state.seed /\
  SeedWellFormed state.seed /\
  (forall item in state.worklist,
    FormulaConsistent item.formula /\
    -- EITHER formula is in seed (existing)
    (item.formula in state.seed.getFormulas item.famIdx item.timeIdx \/
     -- OR formula is derivable from formulas at the source position via axiom
     exists src_famIdx src_timeIdx axiom_instance,
       axiom_instance in state.seed.getFormulas src_famIdx src_timeIdx /\
       Derivable [axiom_instance] item.formula))
```

This allows work items that reference their derivation source, enabling the h_compat proof to use the derivation witness.

## Evidence

### Verified Lemmas (via lean_local_search)
- `addFormula_preserves_consistent` -- derivability-based set consistency preservation (line 1646)
- `addFormula_preserves_consistent_of_theorem` -- theorem addition preserves consistency (line 1344)
- `addFormula_seed_preserves_consistent` -- seed-level consistency with h_compat (line 1828)
- `foldl_addFormula_preserves_consistent` -- foldl version for family propagation (line 2648)
- `addToAllFamilies_preserves_consistent` -- wrapper for Box propagation (line 2705)
- `createNewFamily_preserves_seedConsistent` -- new family is trivially consistent (line 3674)
- `createNewTime_preserves_seedConsistent` -- new time is trivially consistent

### Existing Infrastructure Patterns
- The `foldl_addFormula_times_preserves_consistent_with_gpsi` lemma (line 2903) already demonstrates the CORRECT pattern for temporal cases: it requires `G psi` to be at target entries and uses T-axiom derivation. The boxPositive case needs an analogous `foldl_addFormula_preserves_consistent_with_box_psi` that requires `Box psi` at target entries.
- The `addToAllFutureTimes_preserves_seedConsistent_with_gpsi` (line 3002) is the wrapper version.

### Key Observation
The futurePositive case in `processWorkItem` (lines 6544-6555) adds BOTH `psi` and `G psi` to future times. This means `G psi` IS at the target entries after propagation. The existing `foldl_addFormula_times_preserves_consistent_with_gpsi` lemma handles exactly this case. So the futurePositive case MAY already be provable using the existing infrastructure, provided the foldl adds `G psi` BEFORE `psi` at each time step.

Similarly, the pastPositive case adds `H psi` before `psi` and can use `foldl_addFormula_times_preserves_consistent_with_hpsi`.

The ONLY truly blocked case is `boxPositive`, because the algorithm does NOT propagate `Box psi` to other families before adding `psi`.

## Confidence Level

**Medium-High** for the diagnosis of the blocker and the identification that futurePositive/pastPositive may already be provable.

**Medium** for the recommended fix: modifying processWorkItem for boxPositive to propagate `Box psi` first, then `psi`. This requires:
1. Proving `SetConsistent (insert (Box psi) entry.formulas)` for arbitrary entries at time t -- this is the same cross-consistency problem unless `Box psi` is already there or derivable
2. Alternatively, adding `Box psi` only at NEW positions (where it's a singleton, trivially consistent)

The cleanest solution may be to first propagate `Box psi` to all families (using the fact that new positions are singletons, and existing positions at the current family already have it), then propagate `psi` using the T-axiom derivation. This requires the algorithm to ensure that every family at time t has a seed entry (even if empty) before Box propagation begins.
