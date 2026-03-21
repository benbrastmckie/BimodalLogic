# Team Research Report: Task #23 (Run 8) - ARCHITECTURE CORRECTION

**Task**: F/P temporal witness chain construction
**Date**: 2026-03-21
**Mode**: Team Research (2 teammates)
**Session**: sess_1774127008_34bd86
**Focus**: Correct architectural confusion, review reports 17-20

## Summary

**Previous research (runs 02-07) was fundamentally confused.**

The key misunderstanding: conflating CanonicalMCS with the duration domain D.

**CORRECTION**: CanonicalMCS is **WorldState** (the set of world states), NOT a duration domain. The TaskFrame has:
- `WorldState = CanonicalMCS` (MCSes - no algebraic requirements)
- `D = Int` (duration - has AddCommGroup, LinearOrder)
- `task_rel = CanonicalTask : MCS -> Int -> MCS -> Prop`

The AddCommGroup requirement applies to **Int**, not to CanonicalMCS. There was never a type mismatch.

## The Corrected Architecture

### What Reports 17-20 Establish

| Component | Definition | Role |
|-----------|------------|------|
| **CanonicalMCS** | `Set Formula` with `SetMaximalConsistent` | WorldState (possible worlds) |
| **CanonicalTask** | `MCS -> Int -> MCS -> Prop` | Three-place task relation |
| **CanonicalR** | `exists n > 0, CanonicalTask(u, n, v)` | Existential shadow (duration-blind) |
| **Succ** | `g_content(u) <= v /\ f_content(u) <= v \/ f_content(v)` | Immediate successor relation |

### TaskFrame Structure (CORRECT)

```
TaskFrame Int
  |-- WorldState = CanonicalMCS (all MCSes)
  |-- D = Int (has AddCommGroup, LinearOrder)
  |-- task_rel = CanonicalTask
```

**The AddCommGroup requirement is on Int, NOT on CanonicalMCS.**

## What Was Wrong in Previous Reports

### Report 02 Confusion

Said: "The gap is the Int-indexing requirement - the algebraic completeness infrastructure requires AddCommGroup D which CanonicalMCS lacks."

**WRONG**: CanonicalMCS is not D. CanonicalMCS is WorldState.

### Report 05 Confusion

Created a table comparing "IntBFMCS vs CanonicalFMCS" asking whether each has AddCommGroup.

**WRONG**: This question doesn't make sense. Both use:
- WorldState = CanonicalMCS
- D = Int

The difference is in chain CONSTRUCTION (Lindenbaum vs all-MCS), not in type structure.

### The "Impossible" Conclusion

Previous reports concluded: "Linear chains fundamentally cannot satisfy F/P"

**PARTIALLY CORRECT but MISAPPLIED**:
- TRUE for generic Lindenbaum extension (can kill F-obligations)
- FALSE for Succ-constrained construction (F-step condition tracks obligations)

## Task 23 IS SOLVABLE

### The Succ-Based Approach

Reports 17-20 from task 006 describe a viable path:

1. **Succ Relation** (already defined in SuccRelation.lean):
   - G-persistence: `g_content(u) <= v`
   - F-step: `f_content(u) <= v UNION f_content(v)`

2. **Bounded Witness Theorem** (already proven in CanonicalTaskRelation.lean):
   - If `F^n(phi) in u` but `F^{n+1}(phi) not in u`
   - Then phi is witnessed within n Succ steps

3. **Constrained Successor Construction** (SuccExistence.lean):
   - NOT generic Lindenbaum
   - Deferral seed: `g_content(u) UNION {phi OR F(phi) | F(phi) in u}`
   - F-step is guaranteed BY CONSTRUCTION

### Why This Works (Unlike Generic Lindenbaum)

Generic Lindenbaum extension can arbitrarily add `G(~phi)`, killing `F(phi)`.

Succ-constrained construction:
- Explicitly includes `phi OR F(phi)` for each F(phi)
- The F-step condition FORCES resolution or deferral
- Obligations can't be "silently killed"
- bounded_witness provides finite witness bounds

## What Work Actually Needs to Be Done

### Phase 1: Create SuccChainFMCS (New file)

Define `FMCS Int` using Succ-chain construction:
- At t=0: root MCS
- At t+1: Apply `successor_from_deferral_seed`
- At t-1: Apply `predecessor_from_deferral_seed`

### Phase 2: Prove Temporal Coherence

Using existing infrastructure:
- `forward_G`: From Succ G-persistence (easy)
- `backward_H`: Symmetric (easy)
- `forward_F`: From bounded_witness theorem (main work)
- `backward_P`: Symmetric

### Phase 3: Wire to Completeness

- Update `DirectMultiFamilyBFMCS` to use SuccChainFMCS
- Update `construct_bfmcs_from_mcs_Int` to new construction
- Mark IntBFMCS as deprecated

### Phase 4: Address Axioms

The 3 axioms in SuccExistence.lean:
- `successor_deferral_seed_consistent_axiom`
- `predecessor_deferral_seed_consistent_axiom`
- `predecessor_f_step_axiom`

Options:
1. Prove them (eliminate axioms entirely)
2. Accept as semantic axioms (cleaner than current 4 sorries + 1 axiom)

## Files Summary

| File | Status | Action |
|------|--------|--------|
| `SuccRelation.lean` | EXISTS | Provides Succ definition |
| `CanonicalTaskRelation.lean` | EXISTS | Provides bounded_witness |
| `SuccExistence.lean` | EXISTS (3 axioms) | Provides successor/predecessor existence |
| `SuccChainFMCS.lean` | NEW | Create FMCS Int via Succ chains |
| `IntBFMCS.lean` | EXISTS (4 sorries) | Deprecate |
| `DirectMultiFamilyBFMCS.lean` | EXISTS | Update to use SuccChain |

## Confidence Level

### HIGH Confidence
- CanonicalMCS is WorldState (definitional)
- Succ relation and bounded_witness are proven
- The architecture from reports 17-20 is sound

### MEDIUM Confidence
- Connecting Succ infrastructure to FMCS construction
- Proving F/P via bounded_witness (approach is clear, implementation details TBD)

### LOWER Confidence
- Eliminating the 3 SuccExistence axioms
- They may be provable or may be acceptable as semantic axioms

## Teammate Contributions

| Teammate | Focus | Key Finding |
|----------|-------|-------------|
| A | Reports 17-20 review | Clarified correct architecture (WorldState vs D) |
| B | Task 23 reconsideration | "Impossible" was wrong; Succ-based approach is viable |

## Conclusion

**Task 23 should be REVISED to use the Succ-based approach.**

Previous research incorrectly concluded impossibility based on:
1. Confused understanding of type architecture
2. Analyzing generic Lindenbaum (wrong construction)
3. Not recognizing that Succ provides constrained construction

The correct path forward:
1. Use SuccChain construction (F-step enforced by deferral seed)
2. Apply bounded_witness for F/P witnesses
3. The infrastructure exists; the work is integration

The 3 SuccExistence axioms are either provable or acceptable (better than current 4 sorries).
